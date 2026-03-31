# CRM Field Mapping — Customer Profile

Maps PMLORD customer profile fields to CRM fields in Microsoft Power Apps / Dynamics 365.

## Account Entity Mapping

| Profile Field | CRM Field | Type | Sync Direction |
|--------------|-----------|------|---------------|
| Company name | `name` | Text | Bidirectional |
| DBA / trade name | `rev_dbaname` | Text | PMLORD -> CRM |
| Website | `websiteurl` | URL | Bidirectional |
| Industry | `rev_industry` | Option Set | Bidirectional |
| Company size | `numberofemployees` | Number | PMLORD -> CRM |
| HQ address | `address1_composite` | Address | Bidirectional |
| Phone | `telephone1` | Phone | Bidirectional |
| DUNS number | `rev_dunsnumber` | Text | PMLORD -> CRM |
| Customer tier | `rev_customertier` | Option Set | PMLORD -> CRM |
| Relationship strength | `rev_relationshipstrength` | Option Set | PMLORD -> CRM |
| Assigned PM | `ownerid` | Lookup | Bidirectional |
| BD rep | `rev_bdrep` | Lookup | Bidirectional |
| Account status | `rev_accountstatus` | Option Set | Bidirectional |
| Lifetime value | `revenue` | Currency | CRM -> PMLORD |
| Annual run rate | `rev_annualrunrate` | Currency | PMLORD -> CRM |
| Growth potential | `rev_growthpotential` | Option Set | PMLORD -> CRM |
| Credit tier | `rev_credittier` | Option Set | Bidirectional |
| Payment terms | `paymenttermscode` | Option Set | Bidirectional |

## Contact Entity Mapping

| Profile Field | CRM Field | Type | Sync Direction |
|--------------|-----------|------|---------------|
| Contact name | `fullname` | Text | Bidirectional |
| Title | `jobtitle` | Text | Bidirectional |
| Email | `emailaddress1` | Email | Bidirectional |
| Phone | `telephone1` | Phone | Bidirectional |
| Is primary | `rev_isprimarycontact` | Boolean | PMLORD -> CRM |
| Contact role | `rev_contactrole` | Option Set | PMLORD -> CRM |

## Custom Entities

### Customer Profile Summary (`rev_customerprofile`)

| Profile Field | CRM Field | Type |
|--------------|-----------|------|
| Profile summary text | `rev_profilesummary` | Multiline |
| Quality tier | `rev_qualitytier` | Option Set |
| Required docs | `rev_requireddocs` | Text |
| Communication preference | `rev_commpref` | Option Set |
| Pricing sensitivity | `rev_pricingsensitivity` | Option Set |
| Competitors | `rev_competitors` | Multiline |
| Growth notes | `rev_growthnotes` | Multiline |
| Last profile update | `rev_lastprofileupdate` | Date |

## Option Set Values

### Customer Tier (`rev_customertier`)
- 1: Platinum
- 2: Gold
- 3: Silver
- 4: Bronze
- 5: New

### Relationship Strength (`rev_relationshipstrength`)
- 1: Strong
- 2: Moderate
- 3: Developing
- 4: At Risk

### Growth Potential (`rev_growthpotential`)
- 1: High
- 2: Moderate
- 3: Low
- 4: Declining

### Quality Tier (`rev_qualitytier`)
- 1: Standard
- 2: High
- 3: Critical

### Pricing Sensitivity (`rev_pricingsensitivity`)
- 1: Price-driven
- 2: Value-driven
- 3: Relationship-driven

### Contact Role (`rev_contactrole`)
- 1: Buyer/Purchasing
- 2: Engineering/Technical
- 3: Quality
- 4: Executive
- 5: Accounts Payable
- 6: Other

## Sync Process

1. **Profile build/update** — After PMLORD generates or updates a profile, push mapped fields to CRM
2. **CRM changes** — When CRM data changes (detected during profile load), pull updates into PMLORD profile
3. **Conflict resolution** — PMLORD profile is the source of truth for relationship intelligence fields; CRM is source of truth for transactional data (orders, invoices)
4. **Sync log** — Record all sync events to `~/.pmlord/state/crm-sync-log.jsonl`
