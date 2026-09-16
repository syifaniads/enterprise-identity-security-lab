# Joiner / Mover / Leaver Workflow

## Joiner

1. Ingest new identity from authoritative source or staging table.
2. Validate required attributes and immutable identity key.
3. Correlate against existing identities to prevent duplicates.
4. Determine birthright role from approved attributes.
5. Evaluate SoD/policy constraints.
6. Create target AD/application accounts idempotently.
7. Assign minimum required entitlements.
8. Record provisioning result and failure reason.
9. Reconcile target state.

## Mover

1. Detect authoritative attribute change.
2. Recalculate birthright roles.
3. Add newly required access only after policy/approval.
4. Remove access no longer justified by the old role.
5. Trigger certification for sensitive retained access.
6. Reconcile and log final state.

## Leaver

1. Trigger from authoritative end-date/status.
2. Disable interactive authentication within the defined SLA.
3. Revoke requestable and privileged entitlements.
4. Transfer ownership of business data/workflows.
5. Move/archive the AD identity according to retention policy.
6. Preserve audit evidence.
7. Delete only after retention/recovery requirements permit.

## Design requirements

- Idempotent retries.
- Deterministic correlation.
- No username/email as the sole immutable identifier.
- Separation of birthright and requestable access.
- Manual exception flow for failed connectors.
- Full approval and reason-code auditability.
