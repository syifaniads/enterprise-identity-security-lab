# Active Directory Security Assessment — Capstone 1

## Evidence status

This chapter summarizes the retained **team-level** Capstone 1 documentation. Exact personal ownership of each remediation item is not asserted.

## Retained remediation areas

The team documentation covers the following control families:

| Control family | Retained implementation / validation evidence |
|---|---|
| Password policy | Domain password policy plus Admin fine-grained password policy / PSO; PowerShell resultant-policy validation |
| Account lockout | General and stricter Admin lockout thresholds/durations |
| Built-in accounts | Guest account disabled and checked with local/domain policy validation |
| Dormant identities | Student inactivity review based on replicated logon metadata with report-first workflow |
| Group hygiene | Empty group discovery in Admin OU |
| Account-control flags | `PasswordNotRequired` and Kerberos pre-authentication checks |
| Script governance | Admin PowerShell execution policy via GPO |
| Network exposure | Listening-port inventory and service/process mapping |
| Endpoint hardening | UAC, screen lock, Defender, AutoRun/AutoPlay, selected service hardening |
| Authentication | LM/NTLMv1 disablement / NTLMv2 requirement |
| Remote access | RDP user-right restriction |
| Auditing | Advanced audit categories plus directory-service event monitoring |
| Data protection | BitLocker lab exercise and AD recovery planning |
| Patch management | Windows Update/WSUS-related assignment work |
| Asset visibility | Installed-software inventory |

## Historical lab values worth preserving as evidence

The 2025 documentation records a general password policy with 8-character minimum length, 90-day maximum age, five-password history, and complexity enabled. A separate Admin PSO documents a 12-character minimum, 30-day maximum age, history of 10, and stronger lockout values.

These values are preserved as **historical exercise settings**, not as current universal recommendations. See `ENGINEERING_REVIEW.md` for the modernization analysis.

## Validation pattern

A senior-reviewable remediation should always end with an observable state check. The original work included examples such as:

```powershell
Get-ADDefaultDomainPasswordPolicy
Get-ADUserResultantPasswordPolicy -Identity <user>
Get-ADFineGrainedPasswordPolicy -Filter *
```

and policy verification via `gpresult`/Event Viewer. The portfolio expands this pattern into `Export-ADSecuritySnapshot.ps1`.
