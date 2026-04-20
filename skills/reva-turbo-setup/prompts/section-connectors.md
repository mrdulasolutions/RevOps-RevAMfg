# Section 3 of 7: Connectors

## Overview

Configure integrations with external systems — CRM, email, ERP, Slack, iMessage, and webhooks. Connector settings let REVA-TURBO read from and push to your existing business tools.

**Security rule:** Never store API keys, tokens, or passwords as plaintext. Always use `${ENV_VAR_NAME}` references and instruct the PM to set the actual values in their shell profile.

## Questions

### Q1: CRM Connector

> Which CRM does your company use?
> A) Microsoft Power Apps / Dataverse
> B) Microsoft Dynamics 365
> C) HubSpot
> D) Salesforce
> E) None / Configure later

**If A (Power Apps):**
- Environment URL: (e.g., `https://org.crm.dynamics.com`)
- Dataverse table prefix: (default: `reva-turbo_`)
- Auth: "Set `REVA_TURBO_DATAVERSE_CLIENT_ID` and `REVA_TURBO_DATAVERSE_CLIENT_SECRET` in your shell profile"

**If B (Dynamics 365):**
- Organization URL
- Azure AD Tenant ID reference: `${REVA_TURBO_AZURE_TENANT_ID}`
- Client ID reference: `${REVA_TURBO_DYNAMICS_CLIENT_ID}`
- Client Secret reference: `${REVA_TURBO_DYNAMICS_CLIENT_SECRET}`

**If C (HubSpot):**
- Portal ID
- API key reference: `${REVA_TURBO_HUBSPOT_API_KEY}`
- Pipeline ID for deals (or "default")
- See `references/connector-guide.md` for required scopes

**If D (Salesforce):**
- Instance URL (e.g., `https://company.my.salesforce.com`)
- Auth: `${REVA_TURBO_SALESFORCE_TOKEN}`
- Opportunity record type for RFQs

**If E:** Record `crm_type: none` and skip CRM config.

### Q2: Email Connector

> Which email provider should REVA-TURBO use for sending communications?
> A) Hostinger (SMTP/IMAP)
> B) Gmail (via Gmail MCP server)
> C) Outlook / Microsoft 365 (via Graph API)
> D) None / Configure later

**If A (Hostinger):**
- Email address (sending/from address)
- SMTP host: (default: `smtp.hostinger.com`)
- SMTP port: (default: 465)
- IMAP host: (default: `imap.hostinger.com`)
- Password reference: `${REVA_TURBO_EMAIL_PASSWORD}`
- Signature: free text or "use company name as signature"

**If B (Gmail):**
- Gmail address
- Note: "Gmail integration uses the Gmail MCP server. Ensure it is configured in your Claude settings."
- Signature text

**If C (Outlook):**
- Email address
- Tenant ID reference: `${REVA_TURBO_MS_TENANT_ID}`
- Client ID reference: `${REVA_TURBO_MS_CLIENT_ID}`
- Signature text

**If D:** Record `email_provider: none`.

### Q3: ERP Connector

> Which ERP system do you use for inventory and financials?
> A) SAP Business One
> B) Oracle NetSuite
> C) QuickBooks (Online or Desktop)
> D) None / Configure later

**If A (SAP):**
- Service layer URL
- Company DB name
- Auth: `${REVA_TURBO_SAP_USER}` / `${REVA_TURBO_SAP_PASSWORD}`
- Sync frequency: A) Real-time, B) Hourly, C) Daily, D) Manual

**If B (NetSuite):**
- Account ID
- Token-based auth references
- Sync frequency

**If C (QuickBooks):**
- Company ID
- OAuth reference: `${REVA_TURBO_QB_REFRESH_TOKEN}`
- Sync frequency

**If D:** Record `erp_type: none`.

### Q4: Slack Integration

> Do you use Slack for team communications?
> A) Yes, configure Slack
> B) No / Configure later

**If A:**
- Workspace URL (e.g., `revamfg.slack.com`)
- Alert channel name (e.g., `#reva-turbo-alerts`)
- Orders channel name (e.g., `#orders`)
- Escalation channel name (e.g., `#escalation`)
- Bot token reference: `${REVA_TURBO_SLACK_BOT_TOKEN}`
- Note: "See `references/connector-guide.md` for Slack app setup instructions"

### Q5: iMessage Alerts

> Would you like to enable iMessage alerts for critical notifications?
> A) Yes, configure contacts
> B) No

**If A:**
Collect contacts in a loop:
- Name:
- Phone number (iMessage-capable):
- Alert types: A) All, B) Escalations only, C) Quality failures only, D) Custom

> Add another iMessage contact? (Y/N)

### Q6: External Webhooks

> Do you have any external webhook URLs for notifications?
> A) Yes, add webhook(s)
> B) No

**If A:**
- Webhook name/label:
- URL:
- Events to trigger: A) All, B) Stage changes, C) Escalations, D) Quality gates, E) Custom

> Add another webhook? (Y/N)

## Summary Display

```
┌─────────────────────────────────────────────────────┐
│  CONNECTOR CONFIGURATION SUMMARY                    │
├──────────────────┬──────────────────────────────────┤
│  CRM             │  [type] — [url/status]           │
│  Email           │  [provider] — [address]          │
│  ERP             │  [type] — [sync freq]            │
│  Slack           │  [workspace] — [N] channels      │
│  iMessage        │  [N] contacts configured         │
│  Webhooks        │  [N] endpoints configured        │
├──────────────────┴──────────────────────────────────┤
│  ENV VARS TO SET:                                   │
│  - REVA_TURBO_HUBSPOT_API_KEY (if HubSpot)              │
│  - REVA_TURBO_EMAIL_PASSWORD (if Hostinger)             │
│  - REVA_TURBO_SLACK_BOT_TOKEN (if Slack)                │
│  [... list all required env vars]                   │
└─────────────────────────────────────────────────────┘
```

Confirm: A) Save, B) Edit, C) Start over.

## Output

Write to `~/.reva-turbo/config/connector-config.yaml` using `templates/connector-config.yaml.tmpl`.
