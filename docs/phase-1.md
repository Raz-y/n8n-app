# n8n on AWS — Phase 1: Local-Only Containerized Deployment

## Overview
This phase establishes a **minimal, reproducible foundation** for running **n8n** on AWS using **Docker Compose** on a single EC2 instance.

The goal is not production readiness yet.  
The goal is **learning, control, and correctness of fundamentals**.

At the end of Phase 1:
- n8n runs reliably in a Docker container
- Data is persisted via Docker volumes
- Access is restricted to `localhost` only
- The instance can be stopped/restarted safely
- No secrets are committed to Git

---

## Architecture (Phase 1)

- **Compute**: Single EC2 instance (Amazon Linux 2023)
- **Runtime**: Docker + Docker Compose
- **Application**: n8n official Docker image
- **Storage**: Docker named volume (`n8n_data`)
- **Access**: SSH tunnel → `localhost:5678`
- **Networking**: No public ports exposed
- **Security**: No TLS, no domain, no reverse proxy (by design)

---

## Why This Phase Exists

This phase intentionally avoids:
- Domains
- TLS / HTTPS
- Reverse proxies
- External databases
- Public exposure

Reason:
> You don’t harden or scale something you don’t understand.

Phase 1 ensures you fully understand:
- How containers run
- How configuration is injected
- How persistence works
- How processes start/stop cleanly
- How infra and app responsibilities are separated

---
