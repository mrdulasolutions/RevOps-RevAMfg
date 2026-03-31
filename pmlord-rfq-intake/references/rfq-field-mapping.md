# RFQ Field Mapping — CRM Integration

Maps PMLORD intake record fields to CRM fields in Microsoft Power Apps / Dynamics 365.

## Field Mapping Table

| PMLORD Field | CRM Entity | CRM Field | Type | Notes |
|-------------|-----------|-----------|------|-------|
| `{{RFQ_ID}}` | Opportunity | `rev_rfqid` | Text | Auto-generated, unique |
| `{{CUSTOMER_COMPANY}}` | Account | `name` | Text | Match existing or create new |
| `{{CONTACT_NAME}}` | Contact | `fullname` | Text | Link to Account |
| `{{CONTACT_EMAIL}}` | Contact | `emailaddress1` | Email | Primary email |
| `{{CONTACT_PHONE}}` | Contact | `telephone1` | Phone | Primary phone |
| `{{CONTACT_TITLE}}` | Contact | `jobtitle` | Text | |
| `{{CUSTOMER_ADDRESS}}` | Account | `address1_composite` | Address | Ship-to address |
| `{{PART_DESCRIPTION}}` | Opportunity | `description` | Multiline | Part/assembly description |
| `{{PART_NUMBER}}` | Opportunity | `rev_partnumber` | Text | Customer part number |
| `{{DRAWING_REF}}` | Opportunity | `rev_drawingref` | Text | Drawing/CAD references |
| `{{MATERIAL}}` | Opportunity | `rev_material` | Text | Material specification |
| `{{FINISH}}` | Opportunity | `rev_finish` | Text | Finish/coating |
| `{{TOLERANCES}}` | Opportunity | `rev_tolerances` | Text | Critical tolerances |
| `{{MANUFACTURING_PROCESS}}` | Opportunity | `rev_processtype` | Option Set | Machining, Molding, Sheet Metal, etc. |
| `{{QUANTITY}}` | Opportunity | `rev_quantity` | Text | May include tiers |
| `{{DELIVERY_TIMELINE}}` | Opportunity | `rev_deliverytimeline` | Text | Requested delivery |
| `{{TARGET_PRICE}}` | Opportunity | `rev_targetprice` | Currency | Customer stated target |
| `{{ANNUAL_USAGE}}` | Opportunity | `rev_annualusage` | Number | Expected annual volume |
| `{{SPECIAL_REQUIREMENTS}}` | Opportunity | `rev_specialrequirements` | Multiline | Certs, testing, etc. |
| `{{RFQ_SOURCE}}` | Opportunity | `rev_source` | Option Set | email, website, crm, phone, referral, tradeshow |
| `{{DATE_RECEIVED}}` | Opportunity | `rev_datereceived` | Date | YYYY-MM-DD |
| `{{ASSIGNED_PM}}` | Opportunity | `ownerid` | Lookup (User) | Ray Yeh or Harley Scott |
| `{{BD_SOURCE}}` | Opportunity | `rev_bdsource` | Lookup (User) | BD rep who sourced lead |
| `{{PRIORITY}}` | Opportunity | `rev_priority` | Option Set | Standard, Rush, Critical |
| `{{CUSTOMER_TYPE}}` | Account | `rev_customertype` | Option Set | New, Returning |

## CRM Push Process

1. **Account lookup** — Search CRM for existing Account by company name or email domain
2. **Contact lookup** — Search for existing Contact linked to the Account
3. **Create if missing** — If Account or Contact does not exist, create new records
4. **Create Opportunity** — Create a new Opportunity record with all mapped fields
5. **Attach files** — If drawings or documents were provided, note them in the Opportunity for manual upload
6. **Set pipeline stage** — Set Opportunity stage to "RFQ Received"

## Option Set Values

### Manufacturing Process (`rev_processtype`)
- 1: CNC Machining
- 2: Injection Molding
- 3: Prototyping
- 4: Sheet Metal
- 5: Finishing
- 6: Assembly
- 7: Multiple Processes

### RFQ Source (`rev_source`)
- 1: Email
- 2: Website
- 3: CRM
- 4: Phone
- 5: Referral
- 6: Trade Show

### Priority (`rev_priority`)
- 1: Standard
- 2: Rush
- 3: Critical
