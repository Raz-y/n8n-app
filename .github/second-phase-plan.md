Here is the formatted Markdown file.

```markdown
# Phase 2 Plan: Hardening & Production Readiness

## Executive Summary
Phase 1 established a working n8n instance. Phase 2 focuses on **security, reliability, and maintainability** before building the personal trainer agent workflows.

**Key Insight from Reviews:** Current implementation is actually "Phase 1.5" — it's already public with TLS, but lacks production hardening.

---

## Critical Issues (Must Fix Before Phase 2)

### 1. Secrets Management
**Problem:** Secrets in `user_data` are visible in EC2 metadata and Terraform state.
**All 3 reviews flagged this as HIGH priority.**

**Solution:**
- Move secrets to AWS Systems Manager Parameter Store
- Grant EC2 IAM role `ssm:GetParameter` permission
- Fetch secrets at runtime in bootstrap script
- Keep encryption key stable across deployments (or lose credential access)

**Files affected:** `compute.tf`, `bootstrap.sh.tpl`, `iam.tf`

---

### 2. Data Protection
**Problem:** `prevent_destroy = false` allows accidental data loss.
**Flagged by:** ChatGPT (HIGH), Opus (CRITICAL), Gemini (⚠️)

**Solution:**
```hcl
lifecycle {
  prevent_destroy = true
}

```

**Add:** AWS Backup / Data Lifecycle Manager for automated EBS snapshots.

---

### 3. State Management

**Problem:** Local Terraform state risks resource orphaning and secrets exposure.
**Flagged by:** All 3 reviews

**Solution:**

```hcl
terraform {
  backend "s3" {
    bucket         = "n8n-terraform-state"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "n8n-terraform-locks"
  }
}

```

---

### 4. Encryption Key Not Passed to Container

**Problem:** `N8N_ENCRYPTION_KEY` in `.env` but missing from `docker-compose.yml`.
**Flagged by:** ChatGPT (HIGH)

**Solution:** Add to environment section in `docker-compose.yml`:

```yaml
environment:
  - N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}

```

---

### 5. Documentation Drift

**Problem:** `phase-1.md` claims "local-only" but infrastructure is public.
**Flagged by:** Gemini, Opus

**Solution:**

* Rename current state to "Phase 1.5: Public Access with Auto-TLS"
* Update architecture diagram
* Document current security posture

---

## High Priority Improvements

### Security

* [ ] Fix healthcheck to not rely on wget (ChatGPT, Medium)
* [ ] Replace basic auth with n8n built-in user management (Opus)
* [ ] Pin Docker Compose version with checksum (ChatGPT, Opus)
* [ ] Decide on network stance: truly public vs private (SSM tunnel only)

### Reliability

* [ ] Automated EBS snapshots (DLM policy)
* [ ] CloudWatch alarms: CPU, disk, instance status
* [ ] Backup restoration playbook

### Maintainability

* [ ] Create `.env.example` template
* [ ] Document secret rotation procedure
* [ ] Add restore-from-snapshot procedure

---

## Personal Trainer Agent Requirements

*From Opus: For AI-powered automation with potential scale:*

### Infrastructure Upgrades

* Upgrade to `t3.small` (1GB RAM insufficient for AI APIs)
* Add PostgreSQL (SQLite won't scale)
* S3 bucket for workout plans, progress photos
* Timezone: `GENERIC_TIMEZONE=Asia/Jerusalem` (Gemini)

### Integration Planning

* Telegram/WhatsApp (notifications)
* OpenAI/Claude API (AI coach logic)
* Google Calendar (scheduling)
* Google Sheets (tracking)

### Data Model Considerations

* User profiles & preferences
* Workout history & metrics
* Program templates
* Privacy policy & retention rules

---

## Implementation Order

### Sprint 1: Fix Critical Issues (1-2 days)

1. Remove duplicate shebang in `bootstrap.sh.tpl`
2. Add `n8n_encryption_key` to `terraform.tfvars` (`openssl rand -hex 32`)
3. Set `prevent_destroy = true` on EBS volume
4. Pass encryption key to Docker container
5. Update Phase 1 documentation

### Sprint 2: Security Hardening (2-3 days)

1. Create S3 + DynamoDB for Terraform state
2. Migrate state to remote backend
3. Move secrets to SSM Parameter Store
4. Update IAM role permissions
5. Update bootstrap script to fetch secrets

### Sprint 3: Reliability (2-3 days)

1. Configure AWS Backup for EBS snapshots
2. Add CloudWatch alarms
3. Fix Docker Compose healthcheck
4. Test backup/restore procedure
5. Document recovery playbook

### Sprint 4: App Preparation (2-3 days)

1. Upgrade instance to `t3.small`
2. Add PostgreSQL container
3. Migrate n8n data from SQLite
4. Configure timezone
5. Replace basic auth with n8n users

---

## Review Consensus Matrix

| Issue | Gemini | ChatGPT | Opus | Priority |
| --- | --- | --- | --- | --- |
| Secrets in user_data | ⚠️ | HIGH | ✅ | **CRITICAL** |
| Local state | ⚠️ | Medium | HIGH | **HIGH** |
| prevent_destroy | ⚠️ | HIGH | CRITICAL | **CRITICAL** |
| Encryption key not passed | — | HIGH | ✅ | **HIGH** |
| No backups | ✓ | — | HIGH | **HIGH** |
| Documentation drift | ⚠️ | LOW | ✅ | **MEDIUM** |
| Healthcheck issue | — | Medium | — | **MEDIUM** |
| Basic auth deprecated | — | — | ✅ | **MEDIUM** |
| Pin Docker Compose | — | Medium | — | **LOW** |

*Legend: ⚠️ = Warning, ✅ = Mentioned, ✓ = Recommended, — = Not flagged*

---

## Open Decisions

* **Network stance:** Public internet vs SSM-only access?
* **Database timing:** PostgreSQL now or after Phase 2?
* **Cost tolerance:** Willing to pay for RDS/Backup/CloudWatch?
* **Scope:** Fix issues only, or start building trainer workflows?

## Resources & References

* [n8n Environment Variables](https://docs.n8n.io/hosting/environment-variables/environment-variables/)
* AWS SSM Parameter Store
* Terraform S3 Backend
* AWS Backup for EBS

```

```