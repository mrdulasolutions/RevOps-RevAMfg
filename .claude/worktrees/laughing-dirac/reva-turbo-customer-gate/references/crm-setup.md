# CRM Setup Guide — New Customer

## CRM Platform

Microsoft Power Apps / Dynamics 365 (confirm configuration with Rev A IT).

## Account Record

Create a new Account entity with the following fields:

| CRM Field | Source | Required |
|-----------|--------|----------|
| `name` | Legal company name | Yes |
| `rev_dbaname` | DBA/trade name | No |
| `websiteurl` | Company website | Yes |
| `address1_line1` | Street address | Yes |
| `address1_city` | City | Yes |
| `address1_stateorprovince` | State | Yes |
| `address1_postalcode` | ZIP code | Yes |
| `address1_country` | Country | Yes |
| `telephone1` | Main phone | Yes |
| `rev_industry` | Industry/sector | Yes |
| `rev_companysize` | Employee count range | No |
| `rev_customertype` | "New" | Yes |
| `rev_accountstatus` | "Onboarding" | Yes |
| `rev_source` | How they found Rev A | Yes |
| `rev_bdrep` | BD rep (lookup) | If applicable |
| `rev_dunsnumber` | DUNS number | No |
| `rev_annualspendpotential` | Estimated annual spend | No |
| `rev_onboardingdate` | Today's date | Yes |
| `ownerid` | Assigned PM (lookup) | Yes |

## Contact Record

Create a new Contact entity linked to the Account:

| CRM Field | Source | Required |
|-----------|--------|----------|
| `firstname` | Contact first name | Yes |
| `lastname` | Contact last name | Yes |
| `emailaddress1` | Email | Yes |
| `telephone1` | Direct phone | No |
| `jobtitle` | Title/role | No |
| `parentcustomerid` | Link to Account | Yes |
| `rev_isprimarycontact` | True | Yes |

## Additional Contacts

If multiple contacts are identified during onboarding, create additional Contact records linked to the same Account. Only one should be marked as primary.

## Relationship Setup

After creating Account and Contact:

1. Set the Account-Contact relationship (primary contact)
2. Link the originating RFQ Opportunity (if applicable) to the Account
3. Set the PM as the Account owner
4. If a BD rep is assigned, add them as a team member on the Account

## Account Status Lifecycle

```
Onboarding -> Active -> Inactive -> Archived
```

- **Onboarding:** New customer, first order in progress or pending
- **Active:** At least one completed order, ongoing relationship
- **Inactive:** No orders in 12+ months
- **Archived:** Customer no longer active, records retained per retention policy

## Verification Notes

Add a note to the Account record documenting:
- Legitimacy check results and any concerns
- Credit terms established and rationale
- PM assignment reason
- Any special requirements or preferences noted during onboarding

Use the CRM Notes entity or a custom `rev_onboardingnotes` field.
