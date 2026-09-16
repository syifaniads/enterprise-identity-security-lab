# Active Directory Recovery Runbook

> 2026 portfolio extension based on the Capstone 1 requirement to back up Active Directory.

## Recovery objectives

- Maintain restorable System State backups of domain controllers.
- Protect backup media from the same administrative failure/ransomware domain as the source server.
- Test restoration procedures, not just backup job success.

## Lab backup example

```powershell
wbadmin start systemstatebackup -backuptarget:E: -quiet
wbadmin get versions
```

Do not hard-code a production backup destination into a script. In real environments, use protected backup infrastructure with retention and access controls.

## Restore decision

Before restoration determine whether the incident requires:

- non-authoritative AD restore;
- authoritative restore of selected objects;
- full forest recovery;
- simple object recovery via AD Recycle Bin instead.

## DSRM lab outline

1. Confirm a valid, recent backup.
2. Isolate/understand the failure mode.
3. Boot the target DC into Directory Services Restore Mode where required.
4. Restore System State using supported Windows backup tooling.
5. Reboot and validate directory health/replication.
6. Check DNS, SYSVOL, authentication, time, and replication events.
7. Retain incident/recovery evidence.

A recovery procedure is incomplete until a restore test has succeeded.
