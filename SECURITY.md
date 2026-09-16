# Security Policy

## Scope

All code is intended for isolated labs or environments where the operator has explicit administrative authorization.

## Secret handling

Do not commit:

- passwords or temporary passwords;
- real `.env` files;
- private certificates or keys;
- production domain information;
- session/cookie data;
- private screenshots or exports containing personal information.

The sample provisioning flow intentionally avoids a password column in CSV. Account enablement requires an explicit secure password input at runtime.

## Change safety

For any mutating script:

1. run inventory/report mode first;
2. review targets and exclusions;
3. use `-WhatIf` where supported;
4. test in an isolated OU/pilot group;
5. document rollback;
6. verify effective state after change.

## Responsible use

The auditing and hardening examples should be used to improve systems you own or are authorized to administer. They are not instructions to access third-party systems.
