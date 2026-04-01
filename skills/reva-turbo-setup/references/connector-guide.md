# REVA-TURBO Connector Setup Guide

Detailed instructions for configuring each external system connector. Use this reference during Section 3 (Connectors) of the setup wizard.

---

## HubSpot CRM

### Prerequisites
- HubSpot account with API access (Professional or Enterprise plan)
- API key or private app token

### API Key Setup
1. Log in to HubSpot -> Settings (gear icon) -> Integrations -> API Key
2. If no key exists, click "Generate API Key"
3. Copy the key and set it as an environment variable:
   ```bash
   export REVA-TURBO_HUBSPOT_API_KEY="pat-na1-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   ```
4. Add to your shell profile (`~/.zshrc` or `~/.bashrc`) for persistence

### Required Scopes (Private App)
If using a Private App instead of API Key:
- `crm.objects.contacts.read`
- `crm.objects.contacts.write`
- `crm.objects.deals.read`
- `crm.objects.deals.write`
- `crm.objects.companies.read`
- `crm.objects.companies.write`

### Field Mapping
REVA-TURBO maps to HubSpot deal properties:
| REVA-TURBO Field | HubSpot Property | Notes |
|---|---|---|
| Customer Name | `company` (associated) | Company object |
| RFQ Number | `dealname` prefix | "RFQ-" + number |
| Quote Amount | `amount` | Deal amount |
| Stage | `dealstage` | Mapped to pipeline stages |
| Priority | Custom property `reva-turbo_priority` | Create this property |
| PM Assigned | `hubspot_owner_id` | Owner assignment |

---

## Microsoft Dynamics 365

### Prerequisites
- Azure AD tenant with Dynamics 365 license
- App registration in Azure AD

### Azure AD App Registration
1. Go to Azure Portal -> Azure Active Directory -> App Registrations -> New Registration
2. Name: "REVA-TURBO Integration"
3. Redirect URI: `http://localhost` (for CLI auth)
4. After creation, note:
   - Application (client) ID
   - Directory (tenant) ID
5. Create a client secret: Certificates & Secrets -> New Client Secret
6. Set environment variables:
   ```bash
   export REVA-TURBO_AZURE_TENANT_ID="your-tenant-id"
   export REVA-TURBO_DYNAMICS_CLIENT_ID="your-client-id"
   export REVA-TURBO_DYNAMICS_CLIENT_SECRET="your-client-secret"
   ```

### API Permissions
Add these Dynamics CRM permissions:
- `user_impersonation` (Dynamics CRM)

---

## Microsoft Power Apps / Dataverse

### Prerequisites
- Power Platform environment with Dataverse
- App registration (same as Dynamics 365)

### Connection Setup
1. Identify your environment URL: `https://[org].crm.dynamics.com`
2. Use the same Azure AD app registration as Dynamics 365
3. Set environment variables:
   ```bash
   export REVA-TURBO_DATAVERSE_CLIENT_ID="your-client-id"
   export REVA-TURBO_DATAVERSE_CLIENT_SECRET="your-client-secret"
   ```

### Table Prefix
REVA-TURBO creates Dataverse tables with a configurable prefix (default: `reva-turbo_`):
- `reva-turbo_rfq` — RFQ records
- `reva-turbo_order` — Order tracking
- `reva-turbo_partner` — Partner scorecard data

---

## Gmail

### Prerequisites
- Google Workspace or Gmail account
- Gmail MCP server configured in Claude settings

### Gmail MCP Server Setup
1. Install the Gmail MCP server (if not already configured):
   ```bash
   # The Gmail MCP server should already be available in your Claude configuration
   # Check: Settings -> MCP Servers -> Gmail
   ```
2. Authorize Gmail access when prompted (OAuth flow)
3. No API key needed — Gmail MCP handles authentication via OAuth

### Configuration in REVA-TURBO
- Set the sending address (Gmail address)
- Configure signature text
- REVA-TURBO uses the Gmail MCP tool for send/read operations

---

## Hostinger Email

### Prerequisites
- Hostinger email account (comes with Hostinger hosting plans)
- SMTP/IMAP credentials

### SMTP/IMAP Settings
| Setting | Value |
|---|---|
| SMTP Host | `smtp.hostinger.com` |
| SMTP Port | 465 (SSL) or 587 (TLS) |
| IMAP Host | `imap.hostinger.com` |
| IMAP Port | 993 (SSL) |
| Authentication | Full email address + password |

### Environment Variable
```bash
export REVA-TURBO_EMAIL_PASSWORD="your-email-password"
```

### Hostinger Email MCP
If available, the Hostinger Email MCP server handles authentication. Check:
- Settings -> MCP Servers -> Hostinger Email
- Authorize when prompted

---

## Microsoft Outlook / Microsoft 365

### Prerequisites
- Microsoft 365 account
- Azure AD app registration (can share with Dynamics 365)

### Setup
1. Use the same Azure AD app registration, or create a new one
2. Add Mail.Send and Mail.Read permissions
3. Set environment variables:
   ```bash
   export REVA-TURBO_MS_TENANT_ID="your-tenant-id"
   export REVA-TURBO_MS_CLIENT_ID="your-client-id"
   ```

---

## Slack

### Prerequisites
- Slack workspace with admin access to create apps
- Slack app with bot token

### Slack App Creation
1. Go to https://api.slack.com/apps -> Create New App -> From Scratch
2. App Name: "REVA-TURBO"
3. Workspace: Select your workspace
4. After creation, go to "OAuth & Permissions"
5. Add Bot Token Scopes:
   - `chat:write` — Send messages
   - `chat:write.public` — Post to public channels without joining
   - `channels:read` — List channels
   - `channels:history` — Read channel messages
   - `incoming-webhook` — Post via webhook
6. Install to workspace
7. Copy the Bot User OAuth Token
8. Set environment variable:
   ```bash
   export REVA-TURBO_SLACK_BOT_TOKEN="xoxb-xxxxxxxxxxxx-xxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx"
   ```

### Recommended Channels
Create these channels in your Slack workspace:
- `#reva-turbo-alerts` — Automated alerts (SLA warnings, escalations)
- `#reva-turbo-orders` — Order status updates
- `#reva-turbo-escalation` — Escalation notifications (restricted to managers)

---

## SAP Business One

### Prerequisites
- SAP Business One with Service Layer enabled
- Service Layer URL and credentials

### Connection
```bash
export REVA-TURBO_SAP_USER="your-sap-username"
export REVA-TURBO_SAP_PASSWORD="your-sap-password"
```

### Sync Capabilities
- Inventory levels (read)
- Purchase orders (create/read)
- Sales orders (create/read)
- Business partner records (read/sync)

---

## Oracle NetSuite

### Prerequisites
- NetSuite account with SuiteScript/REST API access
- Token-based authentication

### Setup
1. Enable Token-Based Authentication in NetSuite: Setup -> Company -> Enable Features -> SuiteCloud -> Token-Based Authentication
2. Create an Integration Record
3. Create Token ID and Token Secret
4. Set environment variables:
   ```bash
   export REVA-TURBO_NETSUITE_ACCOUNT_ID="your-account-id"
   export REVA-TURBO_NETSUITE_TOKEN_ID="your-token-id"
   export REVA-TURBO_NETSUITE_TOKEN_SECRET="your-token-secret"
   ```

---

## QuickBooks

### Prerequisites
- QuickBooks Online account
- Intuit Developer account for OAuth

### Setup
1. Create an app at https://developer.intuit.com
2. Configure OAuth 2.0 redirect URIs
3. Obtain Client ID and Client Secret
4. Complete OAuth flow to get refresh token
5. Set environment variables:
   ```bash
   export REVA-TURBO_QB_CLIENT_ID="your-client-id"
   export REVA-TURBO_QB_CLIENT_SECRET="your-client-secret"
   export REVA-TURBO_QB_REFRESH_TOKEN="your-refresh-token"
   export REVA-TURBO_QB_COMPANY_ID="your-company-id"
   ```

---

## General Security Notes

1. **Never commit secrets to version control.** All sensitive values must be stored as environment variables.
2. **Rotate credentials regularly.** Set calendar reminders for API key and token rotation.
3. **Use least-privilege access.** Only grant the minimum permissions each connector needs.
4. **Monitor API usage.** Check connector dashboards for unusual activity.
5. **Document your env vars.** Keep a secure record of which env vars are set and where they reference.
