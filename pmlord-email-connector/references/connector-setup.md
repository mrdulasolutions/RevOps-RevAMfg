# Email Connector Setup Guide

Step-by-step instructions for connecting each email provider to PMLORD.

---

## Native Claude Microsoft 365 Connector (Recommended Primary)

**Best for:** Any organization using Microsoft 365. This is Claude's built-in, first-party integration — no MCP server installation needed.

**Plan requirement:** Claude **Team or Enterprise plan** only. Not available on Free or Pro plans.

**Auth method:** Microsoft OAuth 2.0 via Microsoft Entra ID (formerly Azure AD). All permissions are delegated and read-only.

### Setup Steps

#### Phase 1: Admin Setup (one-time)

1. **Prerequisites:**
   - Organization Owner or Primary Owner role on Claude Team/Enterprise plan
   - Microsoft Entra ID Global Administrator access

2. **Enable the connector:**
   - Go to Claude organization settings
   - Navigate to **Settings > Connectors**
   - Locate **Microsoft 365** and click **Connect**
   - Complete the OAuth consent flow by signing in with your Microsoft admin account
   - Grant the requested permissions (all read-only, delegated)

3. **Alternative manual setup:**
   - Use Microsoft Graph Explorer to add two service principals
   - Grant admin pre-consent through consent URLs for M365 MCP Client and Server applications
   - See https://support.claude.com/en/articles/12542951-enabling-and-using-the-microsoft-365-connector

#### Phase 2: Team Member Setup (per user)

1. Navigate to **Settings > Connectors** in Claude
2. Locate **Microsoft 365**
3. Click **Connect** and authenticate with your Microsoft 365 credentials
4. Done — Claude can now access your Outlook, Teams, SharePoint, and OneDrive

### What Claude Can Access

| Service | Access |
|---------|--------|
| Outlook Email | Search, read emails, read threads, view attachment metadata |
| Teams Chat | Read chat messages and threads |
| Teams Calendar | View meetings, schedules |
| SharePoint | Search and retrieve documents |
| OneDrive | Search and retrieve files |

### Limitations

- **Read-only** — Cannot send, reply, delete, create drafts, or modify emails
- **Delegated permissions** — Can only access data the authenticated user already has permission to view
- **Cloud only** — Cannot access local files, only cloud-stored documents
- **Private Teams channels** — Only accessible if the user is a member
- **SharePoint search** — Searches span the entire tenant (no site-specific filtering)

### For Sending Emails

Since the native M365 connector is read-only, pair it with:
- **Hostinger MCP** — For sending from @revamfg.com (recommended)
- **MCP Inbox connector** — For sending via Microsoft 365 / Outlook (requires separate OAuth setup, see below)
- **Gmail MCP** — For sending via Gmail (creates drafts)

### Optional: Restrict Access to Specific Users

Admins can limit connector access to specific user groups via the Microsoft Entra admin center:
1. Go to Entra ID > Enterprise Applications
2. Find the Claude M365 connector app
3. Enable "Assignment required"
4. Assign specific users or groups

---

## Hostinger Email (revamfg.com)

**Best for:** Rev A Manufacturing's primary domain email (pm@revamfg.com).

**Auth method:** IMAP/SMTP credentials stored in the MCP server config.

### Setup Steps

1. **Install the Hostinger Email MCP server** in Claude Code:
   - Go to Claude Code Settings > MCP Servers
   - Add the `hostinger-email` server
   - Or use the Claude MCP marketplace if available

2. **Configure credentials:**
   ```json
   {
     "mcpServers": {
       "hostinger-email": {
         "command": "npx",
         "args": ["-y", "@anthropic/hostinger-email-mcp"],
         "env": {
           "HOSTINGER_EMAIL": "pm@revamfg.com",
           "HOSTINGER_PASSWORD": "your-email-password",
           "HOSTINGER_IMAP_HOST": "imap.hostinger.com",
           "HOSTINGER_SMTP_HOST": "smtp.hostinger.com"
         }
       }
     }
   }
   ```

3. **Verify:** Run `/pmlord-email-connector mode:setup` — the connector will test the connection.

### Multiple Hostinger Accounts

To monitor multiple revamfg.com accounts (e.g., sales@revamfg.com, quotes@revamfg.com):
- Each account can be added as a separate label in the MCP config
- Use `mcp__hostinger-email__list_accounts` to see all connected accounts

### Capabilities

| Feature | Supported |
|---------|-----------|
| Read emails | Yes |
| Search (full-text, date, sender) | Yes |
| Send emails | Yes |
| Reply to emails | Yes |
| Mark read/unread | Yes |
| Move to folder | Yes |
| Delete (to trash) | Yes |
| Attachments (view) | Flag only |
| Drafts | No |

---

## Gmail

**Best for:** PMs who use personal or company Gmail accounts.

**Auth method:** Google OAuth 2.0 — one-click authorization in Claude.

### Setup Steps

1. **Install the Gmail MCP server** in Claude Code:
   - Go to Claude Code Settings > MCP Servers
   - Add the `gmail` MCP server
   - Claude will prompt for Google OAuth authorization
   - Sign in with your Google account and grant permissions

2. **Required OAuth scopes:**
   - `gmail.readonly` — read emails and threads
   - `gmail.compose` — create drafts
   - `gmail.labels` — manage labels
   - `gmail.modify` — mark as read (optional)

3. **Verify:** Run `mcp__gmail_get_profile` — should return your email address.

### Security Notes

- OAuth tokens are managed by the MCP server — no passwords stored
- Tokens can be revoked at any time from Google Account > Security > Third-party access
- Gmail MCP creates **drafts**, not sent emails — PM must click Send in Gmail (human-in-the-loop)

### Capabilities

| Feature | Supported |
|---------|-----------|
| Read emails | Yes |
| Search (Gmail query syntax) | Yes (powerful) |
| Send emails | Via draft (PM sends manually) |
| Reply to emails | Via draft in thread |
| Read full threads | Yes |
| List labels | Yes |
| Create drafts | Yes |
| Attachments (view) | Flag only |

### Gmail Search Tips

Gmail has the most powerful search syntax:
```
is:unread from:customer@acme.com has:attachment after:2026/3/25
subject:"quote request" -label:processed
```

---

## Microsoft 365 / Outlook

**Best for:** Companies using Microsoft 365, Outlook, or Exchange Online.

**Auth method:** OAuth 2.0 via Microsoft identity platform (Azure AD / Entra ID).

### Setup Steps

#### Option A: Claude MCP Connector (Recommended)

1. **Install the Generic Inbox MCP server** in Claude Code:
   - Go to Claude Code Settings > MCP Servers
   - Add the inbox/email MCP connector
   - When prompted, authenticate with your Microsoft 365 account
   - Grant the requested permissions

2. **Verify:** Run `mcp__82432f48__list_inboxes` — should return your Microsoft inboxes.

#### Option B: Manual Azure AD App Registration

If you need to configure OAuth manually (enterprise environments):

1. **Register an app in Azure AD / Entra ID:**
   - Go to https://portal.azure.com > Azure Active Directory > App registrations
   - Click "New registration"
   - Name: "PMLORD Email Connector"
   - Supported account types: "Accounts in this organizational directory only"
   - Redirect URI: per MCP server requirements

2. **Configure API permissions:**
   - Microsoft Graph > Delegated permissions:
     - `Mail.Read` — Read user mail
     - `Mail.ReadWrite` — Read and write user mail
     - `Mail.Send` — Send mail as user
     - `User.Read` — Sign in and read user profile
   - Click "Grant admin consent" (requires admin)

3. **Get credentials:**
   - Application (client) ID → `MICROSOFT_CLIENT_ID`
   - Create a client secret → `MICROSOFT_CLIENT_SECRET`
   - Directory (tenant) ID → `MICROSOFT_TENANT_ID`

4. **Configure MCP server:**
   ```json
   {
     "mcpServers": {
       "microsoft-email": {
         "command": "npx",
         "args": ["-y", "@anthropic/inbox-mcp"],
         "env": {
           "PROVIDER": "microsoft",
           "MICROSOFT_CLIENT_ID": "your-client-id",
           "MICROSOFT_CLIENT_SECRET": "your-client-secret",
           "MICROSOFT_TENANT_ID": "your-tenant-id"
         }
       }
     }
   }
   ```

### Capabilities

| Feature | Supported |
|---------|-----------|
| Read emails | Yes |
| List threads | Yes (with date filtering) |
| Send emails | Yes (direct send) |
| Reply to emails | Yes (reply / reply-all) |
| Forward emails | Yes |
| Get attachments | Yes (download) |
| Update messages | Yes (mark read, flag) |
| Create inbox | Yes |

### Microsoft-Specific Features

- **Reply All:** The `reply_to_message` tool supports `replyAll: true` for replying to all recipients
- **Forward:** The `forward_message` tool forwards emails with optional added text
- **Attachments:** The `get_attachment` tool can download attachments (PDF, DWG, etc.) — most capable provider for attachment handling
- **Direct Send:** Unlike Gmail, Microsoft connector sends immediately (with PM confirmation in PMLORD)

---

## Multi-Provider Setup

PMLORD supports connecting multiple email providers simultaneously. Common setups:

### Setup 1: Hostinger Primary + Gmail Personal
```yaml
# In ~/.pmlord/connector-config.yaml
email:
  provider: "hostinger"
  providers_available:
    - type: hostinger
      account: "pm@revamfg.com"
      use_for: [send, receive, search]
    - type: gmail
      account: "pm.personal@gmail.com"
      use_for: [receive, search]
```

### Setup 2: Microsoft 365 Primary
```yaml
email:
  provider: "microsoft"
  providers_available:
    - type: microsoft
      account: "pm@revamfg.onmicrosoft.com"
      use_for: [send, receive, search]
```

### Setup 3: All Providers (scan all inboxes)
```yaml
email:
  provider: "auto"
  scan_all: true
  providers_available:
    - type: hostinger
      account: "pm@revamfg.com"
      use_for: [send, receive, search]
    - type: gmail
      account: "pm@gmail.com"
      use_for: [receive, search]
    - type: microsoft
      account: "pm@revamfg.onmicrosoft.com"
      use_for: [receive, search]
```

When `scan_all: true`, the email connector scans ALL connected providers during an inbox scan and presents a unified classification table.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "No email connectors detected" | Check MCP server configuration in Claude settings |
| Hostinger connection fails | Verify IMAP/SMTP credentials, check Hostinger email settings for "Allow less secure apps" or app passwords |
| Gmail OAuth expired | Re-authenticate: remove and re-add the Gmail MCP server |
| Microsoft 401 Unauthorized | Token expired — re-authenticate, or check Azure AD app permissions |
| Microsoft "insufficient privileges" | Admin consent not granted — ask your M365 admin to approve the app |
| Emails being processed twice | Check `~/.pmlord/state/email-routing-log.jsonl` — dedup uses message_id |
| Attachments can't be viewed | Only Microsoft/Generic connector supports attachment download. For Gmail/Hostinger, note the filename and ask PM to open in their email client |

---

## Security Best Practices

1. **OAuth over passwords** — Use Gmail OAuth and Microsoft OAuth. Avoid storing plain-text passwords.
2. **Least privilege** — Only request the OAuth scopes you need (read + send).
3. **Token storage** — MCP servers manage tokens. Don't store tokens in PMLORD config files.
4. **Credential rotation** — Rotate Hostinger passwords and Microsoft client secrets periodically.
5. **Audit log** — All email routing is logged to `email-routing-log.jsonl` for compliance.
6. **No body logging** — PMLORD never stores full email bodies in log files.
