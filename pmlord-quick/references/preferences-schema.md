# Preferences Schema

## File Location

`~/.pmlord/preferences.yaml`

## Full Schema

```yaml
# ~/.pmlord/preferences.yaml
# PM-specific preferences for PMLORD quick commands
# Updated by: set default [field] [value]
# Or edited directly

# --- PM Identity ---
pm_name: "Ray Yeh"
pm_email: "ray@revamanufacturing.com"
pm_role: "Senior PM"

# --- Default Values ---
# These are used when quick commands don't specify a value

default_partner: "partner-abc"          # Partner ID for new quotes
default_margin: 25                       # Target margin percentage
default_report_format: docx              # Output format: docx, pdf, md, xlsx
default_platform: mac                    # Operating system: mac, windows, linux
default_currency: USD                    # Currency for pricing
default_shipping: sea-freight            # Shipping method: sea-freight, air-freight, express, ground
default_incoterm: FOB                    # Incoterm: FOB, CIF, DDP, EXW

# --- Abbreviations ---
# Shortcuts for entities used in quick commands
# Usage: typing the abbreviation is equivalent to typing the full value

abbreviations:
  # Customers
  acme: "Acme Corporation"
  proto: "ProtoTech Industries"
  med: "MedDevice Solutions"
  aero: "AeroSpace Dynamics"

  # People
  ray: "Ray Yeh"
  harley: "Harley Scott"
  donovan: "Donovan Weber"

  # Partners
  sz: "Shenzhen MFG Co."
  gd: "Guangdong Precision"
  nb: "Ningbo Tooling"

  # Parts (optional, for frequently quoted parts)
  widget: "Widget-A Rev C"
  bracket: "Mounting Bracket Rev B"
  housing: "Sensor Housing Rev A"

# --- Quick Defaults ---
# Default values for frequently used fields in quotes and orders

quick_defaults:
  material: "Aluminum 6061-T6"
  finish: "Clear anodize"
  shipping: "sea-freight"
  packaging: "standard"
  inspection_level: "standard"           # standard, enhanced, full-cmm
  payment_terms: "Net 30"
  lead_time_buffer_days: 5               # Days added to partner lead time
  markup_freight: 10                     # Percentage markup on freight
  markup_tooling: 15                     # Percentage markup on tooling

# --- Notification Preferences ---
notifications:
  email_updates: true                    # Receive email for sync updates
  slack_alerts: false                    # Receive Slack notifications
  daily_digest: true                     # Daily summary of activity
  digest_time: "08:00"                   # When to send daily digest (local time)
  alert_on_delay: true                   # Alert when order is at risk of delay
  alert_on_ncr: true                     # Alert when NCR is created

# --- Display Preferences ---
display:
  date_format: "YYYY-MM-DD"             # Date display format
  currency_format: "$#,##0.00"          # Currency display format
  table_style: "markdown"               # Table rendering: markdown, ascii, compact
  show_confidence: false                 # Show parsing confidence scores
  show_source: true                      # Show where pre-filled values came from
  compact_mode: false                    # Minimal output mode

# --- History Settings ---
history:
  max_commands: 50                       # Commands to keep in history
  show_recent: 10                        # Commands to show in "history" view
  auto_suggest: true                     # Suggest from history on partial match
  context_timeout_minutes: 30            # How long active context persists
```

## Field Descriptions

### Abbreviations

Abbreviations are case-insensitive and can be used anywhere an entity is expected:

```
quote acme 5k widget
```

Is equivalent to:

```
quote "Acme Corporation" 5000 "Widget-A Rev C"
```

**Adding abbreviations:**
- Via command: `set alias acme = "Acme Corporation"`
- Via file: Edit `~/.pmlord/preferences.yaml` directly

**Rules:**
- Abbreviations must be unique (no two abbreviations can map to the same value type)
- Abbreviations are matched before fuzzy search
- Abbreviations can contain letters, numbers, and hyphens
- Minimum 2 characters, maximum 20 characters

### Quick Defaults

These values are used when the PM doesn't specify them in a quick command:

- `material` — Default material for new quotes
- `finish` — Default surface finish
- `shipping` — Default shipping method
- `packaging` — Default packaging type
- `inspection_level` — Default inspection rigor
- `payment_terms` — Default payment terms for new quotes
- `lead_time_buffer_days` — Safety buffer added to partner-quoted lead times
- `markup_freight` — Default markup on freight costs
- `markup_tooling` — Default markup on tooling costs

### Notification Preferences

Control how and when PMLORD notifies the PM:

- `email_updates` — Push email for important sync events
- `daily_digest` — Summary of all activity at a set time
- `alert_on_delay` — Proactive alert when an order is at risk

### History Settings

- `context_timeout_minutes` — How long the "active context" from the last command persists. During this window, the PM can use shorthand like "same customer" or "that order."
- `auto_suggest` — When the PM types a partial command, suggest matching commands from history.

## Initialization

If `~/.pmlord/preferences.yaml` doesn't exist, create it with sensible defaults on first use:

```bash
mkdir -p ~/.pmlord
if [ ! -f ~/.pmlord/preferences.yaml ]; then
  cat > ~/.pmlord/preferences.yaml << 'PREFS'
pm_name: ""
pm_email: ""
default_margin: 25
default_report_format: docx
default_shipping: sea-freight
abbreviations: {}
quick_defaults:
  material: "Aluminum 6061-T6"
  finish: "Clear anodize"
  shipping: "sea-freight"
history:
  max_commands: 50
  show_recent: 10
  context_timeout_minutes: 30
PREFS
fi
```
