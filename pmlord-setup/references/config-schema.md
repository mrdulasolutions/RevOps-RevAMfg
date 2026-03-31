# PMLORD Configuration Schema Reference

Complete YAML schema documentation for all 6 configuration files written by `pmlord-setup`. All files are stored at `~/.pmlord/config/`.

---

## 1. company-profile.yaml

Company identity, team roster, and escalation matrix.

### Fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `company.legal_name` | string | yes | — | Full legal company name |
| `company.dba` | string | no | same as legal_name | Doing Business As name |
| `company.address.street` | string | yes | — | Street address |
| `company.address.city` | string | yes | — | City |
| `company.address.state` | string | no | — | State/Province |
| `company.address.zip` | string | yes | — | ZIP/Postal code |
| `company.address.country` | string | yes | — | Country |
| `company.phone` | string | yes | — | Main phone number |
| `company.fax` | string | no | — | Fax number |
| `company.website` | string | yes | — | Company website URL |
| `company.logo_path` | string | no | — | Path to logo file (PNG/SVG) |
| `company.timezone` | string | yes | US/Eastern | IANA timezone |
| `company.fiscal_year_start` | integer | yes | 1 | Month number (1-12) |
| `team[]` | array | yes (min 1) | — | Team member list |
| `team[].name` | string | yes | — | Full name |
| `team[].role` | string | yes | — | One of: PM, Engineer, QC, Executive, Admin, Other |
| `team[].email` | string | yes | — | Email address |
| `team[].phone` | string | no | — | Phone number |
| `escalation_matrix[]` | array | yes (4 items) | — | Escalation chain |
| `escalation_matrix[].level` | integer | yes | — | 1-4 |
| `escalation_matrix[].role` | string | yes | — | Role title |
| `escalation_matrix[].name` | string | yes | — | Person name |
| `escalation_matrix[].email` | string | yes | — | Person email |

---

## 2. workflow-config.yaml

Lifecycle pipeline, quality gates, SLAs, and CoWork settings.

### Fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `stages[]` | array | yes | all 15 active | Lifecycle stage definitions |
| `stages[].id` | string | yes | — | Internal stage identifier |
| `stages[].display_name` | string | yes | — | Human-readable name |
| `stages[].active` | boolean | yes | true | Whether stage is enabled |
| `stages[].auto_advance` | boolean | yes | varies | Auto-advance to next stage |
| `stages[].sla_days` | integer | yes | varies | Target completion days |
| `stages[].order` | integer | yes | — | Stage sequence number (1-15) |
| `quality_gates` | object | yes | — | Gate threshold configuration |
| `quality_gates.G1_drawing_review` | number | yes | 100 | Minimum pass % for G1 |
| `quality_gates.G2_first_article` | number | yes | 95 | Minimum pass % for G2 |
| `quality_gates.G3_production_sample` | number | yes | 98 | Minimum pass % for G3 |
| `quality_gates.G4_final_inspection` | number | yes | 99 | Minimum pass % for G4 |
| `priority_levels` | object | yes | — | Priority definitions |
| `priority_levels.critical` | string | yes | "same-day" | Response time for critical |
| `priority_levels.high` | string | yes | "24h" | Response time for high |
| `priority_levels.medium` | string | yes | "48h" | Response time for medium |
| `priority_levels.low` | string | yes | "1w" | Response time for low |
| `default_priority` | string | yes | medium | Default for new projects |
| `cowork` | object | no | — | CoWork space settings |
| `cowork.structure` | string | no | recommended | "recommended" or "custom" |
| `cowork.projects[]` | array | no | — | Project names |
| `cowork.pinned_skills[]` | array | no | — | Skills pinned to sidebar |
| `cowork.notifications.escalation` | string | no | immediate | immediate/batched/daily |
| `cowork.notifications.order_status` | string | no | batched | immediate/batched/daily/off |
| `cowork.notifications.quality_gates` | string | no | immediate | immediate/batched/daily |
| `cowork.isolation` | string | no | strict | strict/standard/open |

---

## 3. connector-config.yaml

External system integrations.

### Fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `crm.type` | string | yes | none | powerapps/dynamics/hubspot/salesforce/none |
| `crm.url` | string | conditional | — | API or instance URL |
| `crm.auth_env_var` | string | conditional | — | Env var name for auth token |
| `crm.settings` | object | no | — | Type-specific settings |
| `email.provider` | string | yes | none | hostinger/gmail/outlook/none |
| `email.address` | string | conditional | — | Sending address |
| `email.smtp_host` | string | conditional | — | SMTP server (Hostinger) |
| `email.smtp_port` | integer | conditional | 465 | SMTP port |
| `email.imap_host` | string | conditional | — | IMAP server |
| `email.password_env_var` | string | conditional | — | Env var for password |
| `email.signature` | string | no | — | Email signature text |
| `erp.type` | string | yes | none | sap/netsuite/quickbooks/none |
| `erp.url` | string | conditional | — | Connection URL |
| `erp.auth_env_var` | string | conditional | — | Env var for auth |
| `erp.sync_frequency` | string | no | daily | realtime/hourly/daily/manual |
| `slack.enabled` | boolean | yes | false | Slack integration on/off |
| `slack.workspace_url` | string | conditional | — | Workspace URL |
| `slack.channels.alerts` | string | no | — | Alert channel name |
| `slack.channels.orders` | string | no | — | Orders channel name |
| `slack.channels.escalation` | string | no | — | Escalation channel name |
| `slack.bot_token_env_var` | string | conditional | — | Env var for bot token |
| `imessage.enabled` | boolean | yes | false | iMessage alerts on/off |
| `imessage.contacts[]` | array | no | — | Contact list |
| `imessage.contacts[].name` | string | yes | — | Contact name |
| `imessage.contacts[].phone` | string | yes | — | Phone number |
| `imessage.contacts[].alert_types` | string | yes | all | all/escalations/quality/custom |
| `webhooks[]` | array | no | — | External webhook endpoints |
| `webhooks[].name` | string | yes | — | Webhook label |
| `webhooks[].url` | string | yes | — | Webhook URL |
| `webhooks[].events` | string | yes | all | all/stage_changes/escalations/quality/custom |

---

## 4. partners.yaml

Manufacturing partner roster.

### Fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `partners[]` | array | no | — | Partner list |
| `partners[].name` | string | yes | — | Company name |
| `partners[].country` | string | yes | — | Country |
| `partners[].city` | string | yes | — | City |
| `partners[].contact.name` | string | yes | — | Primary contact name |
| `partners[].contact.email` | string | yes | — | Contact email |
| `partners[].contact.phone` | string | yes | — | Contact phone |
| `partners[].contact.wechat` | string | no | — | WeChat ID |
| `partners[].contact.whatsapp` | string | no | — | WhatsApp number |
| `partners[].capabilities[]` | array | yes (min 1) | — | Manufacturing capabilities |
| `partners[].lead_times.simple` | integer | yes | — | Days for simple parts |
| `partners[].lead_times.moderate` | integer | yes | — | Days for moderate parts |
| `partners[].lead_times.complex` | integer | yes | — | Days for complex parts |
| `partners[].quality_rating` | string | yes | — | A/B/C/D/F |
| `partners[].ip_protection` | string | yes | — | nnn/nda/limited/none |
| `partners[].communication_preference` | string | yes | — | email/wechat/whatsapp/phone/mixed |
| `partners[].timezone` | string | yes | — | IANA timezone |
| `partners[].payment_terms` | string | yes | — | net30/net60/50-50/tt_advance/custom |
| `partners[].payment_terms_custom` | string | no | — | Custom terms description |

---

## 5. shipping-config.yaml

Shipping, customs, and logistics configuration.

### Fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `carriers[]` | array | no | — | Preferred carriers |
| `carriers[].name` | string | yes | — | Carrier name |
| `carriers[].account_number` | string | no | — | Account number |
| `customs_broker.name` | string | no | — | Broker company |
| `customs_broker.contact` | string | no | — | Contact person |
| `customs_broker.phone` | string | no | — | Phone |
| `customs_broker.email` | string | no | — | Email |
| `customs_broker.license` | string | no | — | License number |
| `customs_broker.preferred_port` | string | no | — | Preferred port of entry |
| `origin_ports[]` | array | no | — | Origin port list |
| `origin_ports[].name` | string | yes | — | Port name |
| `origin_ports[].code` | string | yes | — | UN/LOCODE |
| `destination_ports[]` | array | no | — | Destination port list |
| `destination_ports[].name` | string | yes | — | Port name |
| `destination_ports[].code` | string | yes | — | UN/LOCODE |
| `default_incoterms` | string | yes | FOB | FOB/CIF/DDP/EXW/FCA/DAP |
| `insurance.provider` | string | no | — | Insurance provider |
| `insurance.coverage` | string | no | 110% | Coverage level |
| `freight_forwarder.name` | string | no | — | Forwarder company |
| `freight_forwarder.contact` | string | no | — | Contact person |
| `freight_forwarder.phone` | string | no | — | Phone |
| `freight_forwarder.email` | string | no | — | Email |
| `freight_forwarder.specialization` | string | no | both | ocean/air/both |
| `shipping_by_value` | object | yes | — | Method by order value |
| `shipping_by_value.under_500` | string | yes | express | Shipping method |
| `shipping_by_value.500_to_5000` | string | yes | express | Shipping method |
| `shipping_by_value.5000_to_25000` | string | yes | air_freight | Shipping method |
| `shipping_by_value.over_25000` | string | yes | ocean_fcl | Shipping method |

---

## 6. document-config.yaml

Report formatting, storage, and backup.

### Fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `logo_path` | string | no | — | Logo for report headers |
| `header_text` | string | yes | "[Company] -- Confidential" | Report header |
| `footer_text` | string | yes | "Generated by PMLORD \| {date}" | Report footer |
| `default_format` | string | yes | docx | docx/pdf/both |
| `templates_dir` | string | yes | ~/.pmlord/templates/ | Custom template directory |
| `output_dir` | string | yes | ~/Documents/PMLORD-Reports/ | Local output directory |
| `cloud_sync.enabled` | boolean | yes | false | Cloud sync on/off |
| `cloud_sync.provider` | string | conditional | — | gdrive/onedrive/dropbox/s3 |
| `cloud_sync.path` | string | conditional | — | Cloud folder/bucket |
| `backup.enabled` | boolean | yes | false | Backup on/off |
| `backup.frequency` | string | conditional | weekly | daily/weekly/monthly |
| `backup.destination` | string | conditional | local | local/cloud/both |
| `backup.local_path` | string | no | ~/.pmlord/backups/ | Local backup directory |
| `backup.cloud_provider` | string | no | — | Cloud backup provider |
| `backup.cloud_path` | string | no | — | Cloud backup path |
| `naming_convention` | string | yes | "PMLORD-{Type}-{YYYY-MM-DD}-{ShortName}" | File naming pattern |
