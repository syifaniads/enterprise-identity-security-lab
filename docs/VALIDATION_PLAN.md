# Validation Plan

## Before change

Capture baseline evidence:

```powershell
Get-ADDomain
Get-ADDefaultDomainPasswordPolicy
Get-ADFineGrainedPasswordPolicy -Filter *
Get-ADDomainController -Filter *
Get-ADUser -Filter { Enabled -eq $true -and PasswordNotRequired -eq $true }
Get-ADUser -Filter { Enabled -eq $true -and DoesNotRequirePreAuth -eq $true }
```

Generate a repository-specific snapshot with:

```powershell
.\active-directory\Export-ADSecuritySnapshot.ps1 -OutputPath .\out\snapshot.json
```

## After policy change

Validate three levels:

1. **Configuration exists** — inspect GPO/AD object.
2. **Configuration applies** — `gpresult`, resultant password policy, effective audit policy.
3. **Behavior matches expectation** — test a dedicated lab account/device.

Examples:

```powershell
Get-ADUserResultantPasswordPolicy -Identity lab.admin1
gpresult /h C:\Temp\gpresult.html /scope computer
auditpol /get /category:*
```

## Rollback evidence

For each change record:

- policy/object name;
- previous value;
- target scope;
- operator/change ticket;
- validation output;
- rollback command or GPO restore point.

## Never use screenshots as the only evidence

Screenshots are useful context, but exported state, commands, logs, and versioned configuration are easier to review and reproduce.
