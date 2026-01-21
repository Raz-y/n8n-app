#!/bin/bash
set -euo pipefail
exec > >(tee /var/log/user-data.log) 2>&1

dnf update -y

# Install Docker + Compose plugin
dnf install -y docker
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
systemctl enable --now docker
usermod -aG docker ec2-user

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
echo "UUID=$UUID /opt/n8n ext4 defaults,nofail 0 2" >> /etc/fstab
mount /opt/n8n

# Create directory structure for volumes
mkdir -p /opt/n8n/{app,n8n_data,caddy/data,caddy/config}
chown -R 1000:1000 /opt/n8n/n8n_data  # n8n runs as UID 1000

# Clone app files
dnf install -y git
git clone https://github.com/Raz-y/n8n-app.git /tmp/n8n-repo
cp /tmp/n8n-repo/app/n8n/docker-compose.yml /opt/n8n/app/
cp /tmp/n8n-repo/app/n8n/caddy/Caddyfile /opt/n8n/caddy/

# Create .env file (variables injected by Terraform)
cat > /opt/n8n/app/.env << 'ENVFILE'
N8N_HOST=${n8n_host}
WEBHOOK_URL=https://${n8n_host}
N8N_BASIC_AUTH_USER=${n8n_user}
N8N_BASIC_AUTH_PASSWORD=${n8n_password}
ENVFILE

# Start containers
cd /opt/n8n/app
docker compose up -d