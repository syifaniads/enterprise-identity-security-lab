# Portfolio Summary

## Enterprise Identity Security Lab — Active Directory & IGA

Reconstructed and hardened a Cyber Defense Academy identity-security lab covering Windows Server / Active Directory security, PowerShell automation, and Identity Governance & Administration. The portfolio combines retained 2025 evidence with clearly labeled 2026 engineering extensions.

### CV-ready bullets

- Developed and documented an Active Directory security-remediation case study covering fine-grained password policy, account lockout, privileged access controls, Kerberos pre-authentication review, auditing, RDP restrictions, legacy authentication hardening, endpoint policy, and recovery considerations.
- Built PowerShell automation for safe bulk identity provisioning, inactive-account review, account-control auditing, listening-port inventory, and AD security snapshots, with `ShouldProcess`, validation, structured outputs, and no plaintext credentials in source control.
- Designed a Greenfield IGA lifecycle around SailPoint IdentityIQ concepts, mapping JDBC-based authoritative records to Joiner/Mover/Leaver workflows, Active Directory provisioning, birthright roles, approvals, access certifications, and leaver deprovisioning.
- Converted classroom-style tasks into an evidence-based engineering portfolio with provenance, limitations, modern security review, reproducibility notes, and CI-based PowerShell quality checks.

### Interview topics

Be prepared to explain:

1. Why fine-grained password policies are applied to users/global security groups rather than directly to OUs.
2. Why `lastLogonTimestamp` is useful for inactivity analysis but not an exact last-login timestamp.
3. Why an empty AD group is not automatically safe to delete.
4. Why PowerShell execution policy is defense-in-depth rather than a security boundary.
5. How to stage an AD hardening change with inventory -> pilot -> validation -> rollback.
6. How IdentityIQ-style provisioning differs from authentication / SSO.
7. How Joiner, Mover, and Leaver events should change entitlements.
8. How access certification and SoD controls reduce accumulated privilege.
9. Why an identity source of truth must be clearly separated from target systems such as AD.
10. How audit evidence should be centralized and retained rather than treated as a screenshot-only validation.
