# Quick Action User Template

## Input Variables

```yaml
# Raw input from PM
RAW_INPUT: "{{RAW_INPUT}}"

# Parsed intent
ACTION: "{{ACTION}}"

# Extracted entities
CUSTOMER: "{{CUSTOMER}}"
CUSTOMER_ID: "{{CUSTOMER_ID}}"
ORDER_ID: "{{ORDER_ID}}"
PO_NUMBER: "{{PO_NUMBER}}"
PART_NUMBER: "{{PART_NUMBER}}"
PART_NAME: "{{PART_NAME}}"
QUANTITY: "{{QUANTITY}}"
MATERIAL: "{{MATERIAL}}"
FINISH: "{{FINISH}}"
PARTNER: "{{PARTNER}}"
PARTNER_ID: "{{PARTNER_ID}}"
DATE: "{{DATE}}"
REASON: "{{REASON}}"
DEFECT: "{{DEFECT}}"

# Modifiers
URGENCY: "{{URGENCY}}"          # standard | urgent | critical
FORMAT: "{{FORMAT}}"            # default | pdf | docx | xlsx
DESTINATION: "{{DESTINATION}}"  # screen | email | slack

# Context (auto-loaded)
LAST_QUOTE_ID: "{{LAST_QUOTE_ID}}"
LAST_ORDER_ID: "{{LAST_ORDER_ID}}"
PREFERRED_PARTNER: "{{PREFERRED_PARTNER}}"
DEFAULT_MARGIN: "{{DEFAULT_MARGIN}}"
DEFAULT_MATERIAL: "{{DEFAULT_MATERIAL}}"
DEFAULT_FINISH: "{{DEFAULT_FINISH}}"

# PM info
PM_NAME: "{{PM_NAME}}"
PM_EMAIL: "{{PM_EMAIL}}"
```

## Pre-fill Confirmation Template

Present to PM before executing:

```
Quick Action: {{ACTION}} for {{CUSTOMER}}

| Field           | Value                | Source            |
|-----------------|----------------------|-------------------|
| Customer        | {{CUSTOMER}}         | {{CUSTOMER_SRC}}  |
| Order/PO        | {{ORDER_ID}}         | {{ORDER_SRC}}     |
| Part            | {{PART_NAME}}        | {{PART_SRC}}      |
| Quantity        | {{QUANTITY}}         | {{QTY_SRC}}       |
| Material        | {{MATERIAL}}         | {{MAT_SRC}}       |
| Finish          | {{FINISH}}           | {{FINISH_SRC}}    |
| Partner         | {{PARTNER}}          | {{PARTNER_SRC}}   |
| Additional      | {{ADDITIONAL}}       | {{ADD_SRC}}       |

A) Confirm and execute
B) Edit a field
C) Cancel
```

## Source Labels

Use these labels to show where each pre-filled value came from:

| Label | Meaning |
|-------|---------|
| `Input` | PM typed this value |
| `Customer profile` | Loaded from customer profile |
| `Last quote` | Loaded from most recent quote |
| `Last order` | Loaded from most recent order |
| `Saved preference` | From ~/.reva-turbo/preferences.yaml |
| `Default` | System default |
| `Calculated` | Computed from other values |
