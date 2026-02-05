# Changelog

Project history and key decisions for n8n on AWS.

---

## [2026-02-05] Documentation & Setup

### Added
- Comprehensive README with architecture and learning path
- Copilot instructions for AI-assisted development
- Project documentation structure

### Changed
- `.github` folder gitignored (local AI context only)

---

## [2026-01-30] Production Hardening

### Added
- **Systemd service** for automatic n8n startup
- **AWS SSM Session Manager** for secure access (no SSH keys)
- **IAM roles** for SSM permissions
- **Health checks** for n8n container
- Modularized Terraform configuration

### Key Decision
Chose SSM Session Manager over SSH for better security and audit logging. No keys to manage or rotate.

---

## [2026-01-25] Security Best Practices

### Added
- Pinned Docker image versions (n8n:2.4.4, caddy:2.10.2)
- IMDSv2 enforcement on EC2
- Encrypted EBS volumes (gp3)
- EBS lifecycle protection

### Key Decision
Never use `:latest` tags. Explicit versions ensure reproducibility and controlled updates.

---

## [2026-01-16 to 2026-01-21] Core Infrastructure

### Added
- **Caddy reverse proxy** with automatic HTTPS/TLS
- **Docker Compose** for container orchestration
- **EBS volume** (30GB gp3) for persistent storage
- **Route53** DNS with hosted zone
- **Bootstrap script** for automated EC2 setup

### Key Decisions
- **Caddy over nginx/ALB**: Free automatic TLS, simple config, appropriate for learning phase
- **EBS over instance storage**: Data persists across instance recreation
- **gp3 over gp2**: 20% cost savings with better performance

---

## [2026-01-10 to 2026-01-16] Initial Setup

### Added
- Terraform configuration (EC2, networking, storage)
- Elastic IP for static addressing
- Docker Compose for n8n
- Security groups and IAM roles

### Key Decisions
- **t3a.small over t3.small**: 10% cost savings, same performance
- **Amazon Linux 2023**: Latest AMI, long-term support
- **Infrastructure as Code**: All infrastructure in version control from day one
- **eu-west-1 region**: Primary deployment region

---

## Architecture Decisions Summary

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Instance Type** | t3a.small | Cost-optimized, sufficient for workload |
| **Storage** | gp3 EBS | 20% cheaper than gp2, better IOPS |
| **TLS/HTTPS** | Caddy | Free automatic certificates |
| **Access** | SSM Session Manager | No SSH keys, audit logging |
| **IaC Tool** | Terraform | Industry standard, AWS provider maturity |
| **Secrets** | terraform.tfvars | Simple for learning, will migrate to Secrets Manager |

---

## Cost Evolution

| Phase | Monthly Cost | Services |
|-------|--------------|----------|
| Phase 1-2 | ~$20-25 | EC2, EBS, EIP, Route53 |
| Future | ~$50-70 | + RDS, CloudWatch |
| Production | ~$100-150 | + ALB, Multi-AZ |

---

**Project Start**: January 10, 2026  
**Current Status**: Phase 1-2 Transition  
**Last Updated**: February 5, 2026