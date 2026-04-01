# reva-turbo-customer-gate

New customer onboarding gate skill for the REVA-TURBO engine.

## What It Does

Ensures every new customer is properly vetted and set up before Rev A Manufacturing accepts their first order:

1. **Collect information** -- Full company and contact details
2. **Verify legitimacy** -- Website, email domain, business presence, red flag screening
3. **CRM setup** -- Create Account and Contact records
4. **PM assignment** -- Assign based on workload, expertise, and relationship
5. **Credit terms** -- Establish initial payment terms

## Usage

```
/reva-turbo-customer-gate
```

Typically triggered by `reva-turbo-rfq-qualify` when Gate 1 identifies a new customer. Can also be invoked directly.

## Inputs

- Customer information (from RFQ intake or PM input)
- PM confirmation at legitimacy and credit checkpoints

## Outputs

- Customer onboarding record saved to `~/.reva-turbo/customers/{CUSTOMER_ID}/`
- CRM records created (Account + Contact)
- Workflow state logged to `~/.reva-turbo/state/workflow-state.jsonl`

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/onboarding-system.md` | System prompt for onboarding logic |
| `prompts/onboarding-user-template.md` | Onboarding input variables |
| `references/onboarding-checklist.md` | Complete onboarding checklist |
| `references/crm-setup.md` | CRM record creation guide |
| `references/legitimacy-checks.md` | Customer verification process |
| `templates/Customer Onboarding Gate.md` | Structured output template |

## Next Step

After onboarding completes, the skill routes back to `reva-turbo-rfq-quote` to continue the RFQ lifecycle.
