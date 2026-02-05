# n8n on AWS

> **A progressive learning project** to master DevOps/SRE fundamentals.

[![Phase](https://img.shields.io/badge/Phase-1--2_Transition-blue.svg)](docs/phase-1.md)
[![Infrastructure](https://img.shields.io/badge/IaC-Terraform-623CE4.svg)](infra/terraform/)
[![AWS](https://img.shields.io/badge/AWS-EC2_|_EBS_|_Route53-FF9900.svg)]()

---

## 🎯 Project Goals

1. **Learn by Building** - Of course. 
2. **Production-Ready** - For personal use and later, public use.
4. **AI-Ready** - Prepare infrastructure for future AI agent integration

---

## 🏗️ Architecture

```
Internet
   ↓
Route53 (DNS: n8n.yourdomain.com)
   ↓
EC2 Instance (t3a.small)
   ├─ Caddy (HTTPS/TLS)
   └─ n8n (Docker)
       ↓
   EBS Volume (30GB encrypted storage)
```

**What's Running:**
- **Caddy**: Reverse proxy with automatic HTTPS
- **n8n**: Workflow automation (Docker container)
- **Storage**: EBS volume for persistent data

---

## 📁 Project Structure

```
├── app/          # Application configs (Docker Compose, Caddy)
├── infra/        # Infrastructure as Code (Terraform)
├── docs/         # Documentation and changelog
└── .github/      # AI assistant instructions
```

---

## 🎓 Learning Path

**Current**: Phase 1-2 (Foundation + Infrastructure)

- **Foundation** ✅ - Compute, storage, networking basics
- **Infrastructure** 🔄 - DNS, TLS, security, IaC
- **Observability** 📋 - Monitoring, logging, alerting
- **Scalability** 📋 - Load balancing, auto-scaling, HA
- **Automation** 📋 - CI/CD, secret management
- **AI Integration** 📋 - Agent infrastructure, workflows

---


## 📚 Documentation

- [Phase 1 Details](docs/phase-1.md) - Foundation phase documentation
- [Changelog](docs/CHANGELOG.md) - Project history and decisions
- [Copilot Instructions](.github/copilot-instructions.md) - AI assistant context - private. 


---


## 📝 License

This project is for educational purposes. n8n is licensed under the [Sustainable Use License](https://docs.n8n.io/choose-n8n/faircode/).

---