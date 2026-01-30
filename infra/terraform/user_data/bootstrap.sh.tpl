#!/bin/bash
set -euo pipefail
exec > >(tee /var/log/user-data.log) 2>&1

dnf update -y

# Ensure SSM Agent is installed and running (required for Session Manager)
if ! systemctl is-enabled --quiet amazon-ssm-agent 2>/dev/null; then
  dnf install -y amazon-ssm-agent
fi
systemctl enable --now amazon-ssm-agent

# Install Docker + Compose plugin
dnf install -y docker
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
systemctl enable --now docker

# Wait for EBS volume to be attached (up to 2 minutes)
DATA_DEV=""
echo "Waiting for EBS volume to attach..."
for i in {1..24}; do
  for dev in /dev/nvme1n1 /dev/xvdf /dev/sdf; do
    if [ -b "$dev" ]; then
      DATA_DEV="$dev"
      echo "Found data volume at $DATA_DEV"
      break 2
    fi
  done
  echo "Attempt $i/24: Volume not yet available, waiting 5s..."
  sleep 5
done

if [ -z "$DATA_DEV" ]; then
  echo "ERROR: No data volume found after 2 minutes!" >&2
  exit 1
fi

# Format only if not already formatted (preserves data on instance replacement)
if ! blkid "$DATA_DEV" | grep -q 'TYPE='; then
  mkfs.ext4 -L n8n-data "$DATA_DEV"
fi

# Mount at /opt/n8n
mkdir -p /opt/n8n
UUID=$(blkid -s UUID -o value "$DATA_DEV")

# Add to fstab only if mountpoint not already configured
if ! grep -qE '^\s*UUID=.*\s+/opt/n8n\s+' /etc/fstab; then
  echo "UUID=$UUID /opt/n8n ext4 defaults,nofail 0 2" >> /etc/fstab
fi

# Mount volume (will also work on reboot via fstab)
mount /opt/n8n

# Verify mount succeeded
if ! mountpoint -q /opt/n8n; then
  echo "ERROR: Failed to mount /opt/n8n!" >&2
  exit 1
fi
echo "Successfully mounted EBS volume at /opt/n8n"

# Create directory structure
mkdir -p /opt/n8n/{app,n8n_data,caddy}

# Set ownership: n8n runs as node (UID 1000)
chown -R 1000:1000 /opt/n8n/n8n_data

# Write docker-compose.yml from repo content
cat > /opt/n8n/app/docker-compose.yml << 'COMPOSE'
${docker_compose}
COMPOSE

# Write Caddyfile from repo content (templated with host)
cat > /opt/n8n/caddy/Caddyfile << 'CADDY'
${caddyfile}
CADDY

# Create .env file with variables from Terraform
cat > /opt/n8n/app/.env << 'ENVFILE'
N8N_HOST=${n8n_host}
WEBHOOK_URL=https://${n8n_host}
N8N_BASIC_AUTH_USER=${n8n_user}
N8N_BASIC_AUTH_PASSWORD=${n8n_password}
N8N_ENCRYPTION_KEY=${n8n_encryption_key}
ENVFILE

# Create systemd service for n8n stack
cat > /etc/systemd/system/n8n.service << 'SYSTEMD'
${n8n_service}
SYSTEMD

# Enable and start the n8n service
systemctl daemon-reload
systemctl enable --now n8n.service

echo "Bootstrap complete. n8n stack is managed by systemd."