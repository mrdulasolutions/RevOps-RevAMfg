# CRM Field Mapping — Customer Profile

Maps REVA-TURBO customer profile fields to CRM fields in Microsoft Power Apps / Dynamics 365.

## Account Entity Mapping

| Profile Field | CRM Field | Type | Sync Direction |
|--------------|-----------|------|---------------|
| Company name | `name` | Text | Bidirectional |
| DBA / trade name | `rev_dbaname` | Text | REVA-TURBO -> CRM |
| Website | `websiteurl` | URL | Bidirectional |
| Industry | `rev_industry` | Option Set | Bidirectional |
| Company size | `numberofemployees` | Number | REVA-TURBO -> CRM |
| HQ address | `address1_composite` | Address | Bidirectional |
| Phone | `telephone1` | Phone | Bidirectional |
| DUNS number | `rev_dunsnumber` | Text | REVA-TURBO -> CRM |
| Customer tier | `rev_customertier` | Option Set | REVA-TURBO -> CRM |
| Relationship strength | `rev_relationshipstrength` | Option Set | REVA-TURBO -> CRM |
| Assigned PM | `ownerid` | Lookup | Bidirectional |
| BD rep | `rev_bdrep` | Lookup | Bidirectional |
| Account status | `rev_accountstatus` | Option Set | Bidirectional |
| Lifetime value | `revenue` | Currency | CRM -> REVA-TURBO |
| Annual run rate | `rev_annualrunrate` | Currency | REVA-TURBO -> CRM |
| Growth potential | `rev_growthpotential` | Option Set | REVA-TURBO -> CRM |
| Credit tier | `rev_credittier` | Option Set | Bidirectional |
| Payment terms | `paymenttermscode` | Option Set | Bidirectional |

## Contact Entity Mapping

| Profile Field | CRM Field | Type | Sync Direction |
|--------------|-----------|------|---------------|
| Contact name | `fullname` | Text | Bidirectional |
| Title | `jobtitle` | Text | Bidirectional |
| Email | `emailaddress1` | Email | Bidirectional |
| Phone | `telephone1` | Phone | Bidirectional |
| Is primary | `rev_isprimarycontact` | Boolean | REVA-TURBO -> CRM |
| Contact role | `rev_contactrole` | Option Set | REVA-TURBO -> CRM |

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

1. **Profile build/update** — After REVA-TURBO generates or updates a profile, push mapped fields to CRM
2. **CRM changes** — When CRM data changes (detected during profile load), pull updates into REVA-TURBO profile
3. **Conflict resolution** — REVA-TURBO profile is the source of truth for relationship intelligence fields; CRM is source of truth for transactional data (orders, invoices)
4. **Sync log** — Record all sync events to `~/.reva-turbo/state/crm-sync-log.jsonl`
