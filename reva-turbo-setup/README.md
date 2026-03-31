# reva-turbo-setup

Interactive onboarding wizard for the REVA-TURBO engine. Walks the PM through 7 configuration sections and generates 6 YAML config files that drive the entire Rev A Manufacturing workflow.

## When to Use

- First-time REVA-TURBO setup on a new machine or for a new company
- Reconfiguring a specific section (e.g., adding a new manufacturing partner)
- After upgrading REVA-TURBO to pick up new config options

## Invocation

```
/reva-turbo-setup              # Start full wizard (or resume if partial)
/reva-turbo-setup section:3    # Jump to a specific section
/setup                     # Alias (routed by reva-turbo-engine)
```

## Sections

| # | Section | Config File | Description |
|---|---------|-------------|-------------|
| 1 | Company Profile | `company-profile.yaml` | Legal name, address, team, escalation matrix |
| 2 | Workflow | `workflow-config.yaml` | Lifecycle stages, quality gates, SLAs |
| 3 | Connectors | `connector-config.yaml` | CRM, email, ERP, Slack, iMessage, webhooks |
| 4 | Partners | `partners.yaml` | Manufacturing partners, capabilities, contacts |
| 5 | Shipping | `shipping-config.yaml` | Carriers, ports, customs broker, incoterms |
| 6 | Documents | `document-config.yaml` | Report formatting, storage, backup |
| 7 | CoWork | _(updates workflow-config.yaml)_ | CoWork project organization |

## Config Files Created

All config files are written to `~/.reva-turbo/config/`:

- `company-profile.yaml` — Company identity, team roster, escalation matrix
- `workflow-config.yaml` — Active stages, gate thresholds, SLAs, CoWork settings
- `connector-config.yaml` — Integration credentials (env var references, not plaintext)
- `partners.yaml` — Manufacturing partner roster with capabilities and contacts
- `shipping-config.yaml` — Carriers, ports, customs broker, incoterms, insurance
- `document-config.yaml` — Report formatting, output paths, backup configuration

## Resume / Skip Behavior

- If setup was partially completed, the wizard detects existing config files and offers to resume from the next incomplete section.
- Any section can be skipped by saying "skip" — the wizard moves to the next section and records the skip.
- Skipped sections can be configured later via `/reva-turbo-setup section:N`.
- Re-running a completed section backs up the existing config before overwriting.

## Validation

Each section validates inputs before writing:
- Required fields must be populated
- Email, phone, URL formats are checked
- No raw API keys in config files (must use `${ENV_VAR}` references)
- Written YAML is checked for syntax and remaining placeholders

## Security

- API keys and tokens are stored as environment variable references, never as plaintext
- Config files are written with mode 600 (user-readable only)
- Existing configs are backed up before overwrite
