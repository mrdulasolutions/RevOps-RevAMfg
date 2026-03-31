# Dynamics 365 Field Mapping

## Account (Customer)

| PMLORD Field | Dynamics 365 Field | Dynamics API Name | Type |
|-------------|-------------------|-------------------|------|
| Customer Company | Account Name | `name` | String |
| Customer Address | Address 1 | `address1_composite` | String |
| Customer City | City | `address1_city` | String |
| Customer State | State/Province | `address1_stateorprovince` | String |
| Customer ZIP | ZIP/Postal Code | `address1_postalcode` | String |
| Customer Country | Country | `address1_country` | String |
| Customer Phone | Main Phone | `telephone1` | String |
| Customer Website | Website | `websiteurl` | String |
| Customer Tier | Account Category | `accountcategorycode` | OptionSet |
| Assigned PM | Owner | `ownerid` | Lookup |
| Relationship Start | Created On | `createdon` | DateTime |

## Contact

| PMLORD Field | Dynamics 365 Field | Dynamics API Name | Type |
|-------------|-------------------|-------------------|------|
| Contact Name (First) | First Name | `firstname` | String |
| Contact Name (Last) | Last Name | `lastname` | String |
| Contact Email | Email | `emailaddress1` | String |
| Contact Phone | Business Phone | `telephone1` | String |
| Contact Title | Job Title | `jobtitle` | String |
| Contact Company | Company Name | `parentcustomerid` | Lookup |

## Opportunity (RFQ)

| PMLORD Field | Dynamics 365 Field | Dynamics API Name | Type |
|-------------|-------------------|-------------------|------|
| RFQ ID | Opportunity Number | `opportunitynumber` | String (auto) |
| Customer Company | Account | `parentaccountid` | Lookup |
| Contact Name | Primary Contact | `parentcontactid` | Lookup |
| Part Description | Description | `description` | Memo |
| Estimated Value | Est. Revenue | `estimatedvalue` | Money |
| RFQ Source | Lead Source | `leadsourcecode` | OptionSet |
| RFQ Date | Created On | `createdon` | DateTime |
| Stage | Pipeline Phase | `stepname` | String |
| Status | Status Reason | `statuscode` | OptionSet |
| Close Date | Est. Close Date | `estimatedclosedate` | DateTime |
| Assigned PM | Owner | `ownerid` | Lookup |

## Sales Order (Order)

| PMLORD Field | Dynamics 365 Field | Dynamics API Name | Type |
|-------------|-------------------|-------------------|------|
| PO Number | Order Number | `ordernumber` | String |
| Customer Company | Account | `customerid` | Lookup |
| Order Date | Date Fulfilled | `datefulfilled` | DateTime |
| Total Price | Total Amount | `totalamount` | Money |
| Order Status | Status Reason | `statuscode` | OptionSet |
| Current Stage | Custom: pmlord_stage | `pmlord_currentstage` | String (custom) |
| Routing Type | Custom: pmlord_routing | `pmlord_routing` | String (custom) |
| Manufacturing Partner | Custom: pmlord_partner | `pmlord_mfgpartner` | String (custom) |
| Delivery Date | Custom: pmlord_deliverydate | `pmlord_deliverydate` | DateTime (custom) |
| Assigned PM | Owner | `ownerid` | Lookup |

## Custom Fields Required in Dynamics 365

The following custom fields must be created in Dynamics 365 for full PMLORD integration:

| Display Name | API Name | Entity | Type | Description |
|-------------|----------|--------|------|-------------|
| PMLORD Stage | pmlord_currentstage | Sales Order | Single Line Text | Current order stage (01-12) |
| PMLORD Routing | pmlord_routing | Sales Order | Option Set | direct-to-customer / inspect-and-forward |
| Mfg Partner | pmlord_mfgpartner | Sales Order | Single Line Text | China manufacturing partner name |
| Delivery Date | pmlord_deliverydate | Sales Order | Date Only | Promised customer delivery date |
| Partner Score | pmlord_partnerscore | Account | Single Line Text | Partner scorecard grade |
| Last PMLORD Sync | pmlord_lastsync | Multiple | Date and Time | Timestamp of last PMLORD sync |

## Dynamics 365 API Patterns

### Authentication
- Use OAuth 2.0 with client credentials or user delegation
- Token endpoint: `https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token`
- Resource: `https://{org}.api.crm.dynamics.com`

### Read (GET)
```
GET /api/data/v9.2/accounts?$filter=name eq '{company_name}'
GET /api/data/v9.2/salesorders?$filter=ordernumber eq '{po_number}'
```

### Create (POST)
```
POST /api/data/v9.2/salesorders
Content-Type: application/json
{...order data...}
```

### Update (PATCH)
```
PATCH /api/data/v9.2/salesorders({order_id})
Content-Type: application/json
{...updated fields...}
```
