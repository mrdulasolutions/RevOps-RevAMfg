# reva-turbo-customer-profile

Customer profile management skill for the REVA-TURBO engine.

## What It Does

Builds and maintains comprehensive customer profiles that give PMs instant context on any customer:

1. **Company overview** -- Legal name, contacts, industry, size
2. **Order history** -- All RFQs, quotes, orders with summary metrics
3. **Quality profile** -- Tolerance expectations, required docs, NCR history
4. **Payment history** -- Terms, on-time rate, outstanding balances
5. **Relationship intelligence** -- Decision-makers, preferences, competitive landscape
6. **Customer tier** -- Platinum/Gold/Silver/Bronze classification

## Usage

```
/reva-turbo-customer-profile
```

Can be invoked anytime to build a new profile or update an existing one.

## Inputs

- Customer name or ID
- Order history data (from CRM or PM knowledge)
- PM relationship insights

## Outputs

- Customer profile document saved to `~/.reva-turbo/customers/{CUSTOMER_ID}/profile.md`
- CRM sync (if configured)
- Workflow state logged

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/profile-system.md` | System prompt for profile building |
| `prompts/profile-user-template.md` | Profile input variables |
| `references/profile-fields.md` | Complete field reference |
| `references/crm-field-mapping.md` | CRM sync mapping |
| `templates/Customer Profile.md` | Structured output template |

## Profile Maintenance

Profiles are living documents. Update after every completed order, quality event, contact change, or new relationship intelligence.
