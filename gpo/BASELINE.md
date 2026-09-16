# GPO Baseline — Lab Reference

This document translates the retained Capstone controls into reviewable policy groups. Exact production values must be risk- and compatibility-tested.

| GPO / control | Intended scope | Validation |
|---|---|---|
| Domain account baseline | Domain users | `Get-ADDefaultDomainPasswordPolicy` |
| Privileged FGPP / PSO | Privileged global security group | `Get-ADUserResultantPasswordPolicy` |
| Disable Guest | Domain computers | `net user Guest`, `gpresult` |
| UAC strengthening | Admin/Faculty endpoints | `gpresult`, local security policy |
| Screen lock | General endpoints; shorter privileged timeout | effective GPO + lock behavior |
| Disable anonymous SAM/share enumeration | Domain controllers | effective security options + test |
| Advanced audit | Domain controllers / critical endpoints | `auditpol`, Event Viewer/forwarding |
| RDP restriction | Sensitive servers | resultant User Rights Assignment |
| NTLMv1 disablement | Domain / DCs after compatibility audit | effective LAN Manager auth level + NTLM auditing |
| Defender baseline | Managed endpoints | Defender status/policy output |
| AutoRun/AutoPlay control | Endpoints | resultant GPO |
| BitLocker | Supported endpoints | `Get-BitLockerVolume` + recovery escrow check |
| Windows Update | Ring-based computer groups | client update source + compliance report |

## Fine-grained password policy note

A Password Settings Object is directly associated with users or **global security groups**, not with an OU as an OU policy object. Use an appropriate group representing the privileged population.

## Default policy hygiene

For portfolio hardening, prefer dedicated, descriptive GPOs and documented link/filter strategy. Avoid turning the Default Domain Policy into a catch-all security baseline.
