# Engineering Review & Modernization Notes

This document intentionally critiques the historical lab instead of presenting every 2025 step as production best practice.

## 1. Password policy

**2025 evidence:** periodic expiry, composition requirements, different Admin PSO values.

**2026 review:** retain the exercise evidence, but modern deployments should prioritize long passwords/passphrases, breached-password screening, MFA/phishing-resistant authentication for privileged access, and compromise-driven resets rather than blindly treating periodic password changes as universally stronger security.

## 2. Fine-grained password policy / PSO

The use of a Password Settings Object for higher-risk users is technically sound as an AD capability. It must be assigned to user objects or global security groups; an OU alone is not the direct PSO subject.

## 3. Inactive account detection

The retained script uses `lastLogonTimestamp` plus creation time. That attribute is replicated but intentionally not updated on every logon, so it is suitable for coarse inactivity analysis rather than exact login timing.

**Safer portfolio behavior:** report first, use a conservative threshold, exclude service/privileged/break-glass identities, review owners, then disable rather than delete.

## 4. Empty AD groups

An empty membership list does **not** prove a group is unused. A group can still be referenced by ACLs, GPO filtering, applications, scripts, or external systems.

The public portfolio therefore provides inventory only. Deletion requires owner/ACL/dependency review.

## 5. Kerberos pre-authentication

Disabling Kerberos pre-authentication can expose an account to AS-REP roasting. The historical wording occasionally treats this as immediate domain compromise; the portfolio narrows that claim. Actual impact depends on password strength, account privileges, and the subsequent attack chain.

## 6. PowerShell execution policy

Execution policy is useful for governance and accidental-execution control, but it is **not a security boundary**. For stronger application/script control, evaluate code signing plus AppLocker or Windows Defender Application Control where appropriate.

## 7. Listening ports

A listening port is not automatically unnecessary. Validate the owning process, server role, dependencies, source networks, and intended exposure before disabling a service or firewall rule.

## 8. Telemetry / service disablement

The historical exercise selected telemetry-related service hardening. Production decisions must consider endpoint-management, diagnostics, support, and compliance requirements before disabling services globally.

## 9. GPO design

Prefer dedicated, purpose-named GPOs and controlled linkage/security filtering over repeatedly editing Default Domain Policy / Default Domain Controllers Policy for unrelated settings. Preserve the default policies for the small set of settings that are appropriate there.

## 10. Audit policy

Audit configuration must include event-volume planning, Security log size/retention, SACL configuration where needed, and forwarding to a centralized collector/SIEM. Event IDs without collection/retention are not an operational detection capability.

## 11. Patch management

The retained material leaves part of WSUS setup incomplete. `PATCH_MANAGEMENT.md` completes it as a **2026 portfolio extension**. WSUS remains supported but is deprecated/no longer receiving new features, so modern endpoint strategy should evaluate supported cloud update-management options where appropriate.

## 12. BitLocker

The no-TPM setup is a valid lab scenario, not a preferred enterprise baseline. Production designs should use supported hardware-backed key protection and centralized recovery-key governance.

## 13. IAM architecture

The Capstone 2 workflow is a strong conceptual starting point, but production IGA also needs deterministic correlation, idempotent provisioning, reconciliation, approval ownership, SoD, certification, and failure recovery.
