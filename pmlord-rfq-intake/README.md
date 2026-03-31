# pmlord-rfq-intake

RFQ intake and data extraction skill for the PMLORD engine.

## What It Does

Parses incoming RFQs from any source (email, website, CRM, phone, referral) and extracts structured data into a standardized Rev A Manufacturing intake record. The skill:

1. Checks data sensitivity (NDA status, PII, authorization)
2. Identifies the RFQ source
3. Extracts all relevant fields (customer, part, quantity, material, tolerances, timeline, etc.)
4. Presents a structured record for PM review and confirmation
5. Pushes the record to CRM (if configured)
6. Routes the RFQ to the qualification gate

## Usage

```
/pmlord-rfq-intake
```

Or paste/describe an RFQ and the PMLORD engine will auto-route to this skill.

## Inputs

- Raw RFQ text (email body, form submission, or transcribed phone notes)
- PM confirmation at the review checkpoint

## Outputs

- Structured intake record saved to `~/.pmlord/rfqs/{RFQ_ID}/intake-record.md`
- CRM push (if configured)
- Workflow state logged to `~/.pmlord/state/workflow-state.jsonl`

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/rfq-extraction-system.md` | System prompt for RFQ parsing |
| `prompts/rfq-user-template.md` | Field extraction variables |
| `references/rfq-field-mapping.md` | CRM field mapping |
| `references/email-patterns.md` | Common RFQ email patterns |
| `references/data-sensitivity.md` | Customer data handling rules |
| `templates/RFQ Intake Record.md` | Structured output template |

## Next Step

After intake completes, the skill suggests running `pmlord-rfq-qualify` for gate checks.
