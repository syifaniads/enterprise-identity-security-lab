# Architecture

## 2025 lab model

The retained CDA artifacts describe a Windows/identity environment centered on Active Directory, organizational units for different populations, supporting applications/databases, and a later IGA design that introduces SailPoint IdentityIQ-style governance.

```mermaid
flowchart TB
    USER[Students / Faculty / Admins]
    AD[(Active Directory)]
    GPO[Group Policy]
    PS[PowerShell administration]
    DB[(JDBC identity tables)]
    IIQ[IdentityIQ / IGA]
    APP[Portal / applications]
    AUDIT[Windows Security logs]

    GPO --> AD
    PS <--> AD
    USER --> AD
    DB --> IIQ
    IIQ --> AD
    IIQ --> APP
    AD --> AUDIT
    APP --> AUDIT
```

## 2026 portfolio control planes

This portfolio separates the system into four conceptual control planes:

1. **Identity source plane** — authoritative user lifecycle data.
2. **Governance plane** — correlation, roles, approvals, SoD, certification.
3. **Enforcement plane** — AD groups/accounts, application entitlements, GPO.
4. **Evidence plane** — logs, inventory exports, approvals and certification history.

That separation is intentional: authentication is not the same as governance, and a directory is not automatically an authoritative HR/SIS source.
