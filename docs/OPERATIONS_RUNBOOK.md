# Operations Runbook

## Change flow

```text
Discover -> classify -> review exclusions -> report-only -> pilot -> validate
         -> broader rollout -> monitor -> retain evidence -> rollback if needed
```

## Identity provisioning

1. Validate authoritative record and unique identifier.
2. Validate target OU and role mapping.
3. Search for existing username/UPN collisions.
4. Run `Import-ADUsers.ps1 -WhatIf`.
5. Review log/output.
6. Provision disabled account first unless a secure activation path is available.
7. Assign only birthright groups justified by the role model.
8. Validate resultant group/access state.

## Dormant account workflow

1. Generate candidate report.
2. Exclude service accounts, SPN-bearing accounts, break-glass accounts, and privileged identities.
3. Contact owner/manager where applicable.
4. Disable first; do not delete immediately.
5. Monitor for impact during quarantine period.
6. Archive/delete only after retention and recovery requirements are satisfied.

## Privileged policy change

1. Export current policy/GPO evidence.
2. Apply to a pilot Admin group/OU.
3. Verify login and operational tooling still works.
4. Validate event generation.
5. Expand scope in stages.

## IGA connector failure

1. Stop repeated destructive retries if target state is uncertain.
2. Preserve request/provisioning-plan identifiers.
3. Reconcile target account state.
4. Decide whether operation is retryable/idempotent.
5. Requeue or manually remediate with documented reason.
6. Re-run aggregation/correlation after recovery.
