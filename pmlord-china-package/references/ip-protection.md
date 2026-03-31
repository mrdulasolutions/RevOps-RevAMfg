# IP Protection Guidelines for Manufacturing Packages

## Principles

1. Protect the customer's intellectual property at all times.
2. Minimize the information shared to only what is necessary for manufacturing.
3. Maintain traceability and version control on all distributed documents.
4. Assume all manufacturing packages may be seen by unauthorized parties.

## Protection Measures

### 1. Customer Identity Redaction

- **Default:** Do NOT include end-customer name in any partner-facing document.
- Use Rev A Manufacturing part numbers only (e.g., RA-12345).
- If the PM explicitly authorizes sharing the customer name, document the authorization with date and PM name.
- Never include customer contact information, purchase order numbers, or pricing in the manufacturing package.

### 2. Specification Splitting

For high-IP-sensitivity parts, split the manufacturing package:

| Package | Contains | Shared With |
|---------|----------|-------------|
| **Package A — Geometry** | Dimensional drawings, GD&T, general tolerances | Manufacturing partner |
| **Package B — Process** | Material specs, finish requirements, special processes | Manufacturing partner |
| **Package C — Application** | End-use context, assembly instructions, functional requirements | Retained by Rev A only |

When to split:
- Customer has explicitly requested IP protection
- Part is for a defense, medical, or aerospace application
- Part design is novel or patentable
- Customer has an active NDA with Rev A

### 3. Drawing Watermarking

Add the following text as a watermark or header/footer on every drawing page:

```
CONFIDENTIAL — Rev A Manufacturing
Distribution: [Partner Name] only
NDA Ref: [NDA-XXXX] | Date: [YYYY-MM-DD]
Unauthorized reproduction or distribution prohibited.
```

### 4. NDA Reminders

Include in the package cover sheet:

```
This manufacturing package is provided under Non-Disclosure Agreement
[NDA Reference Number], dated [NDA Date], between Rev A Manufacturing
and [Partner Name]. All information herein is confidential and proprietary.
Recipient agrees to use this information solely for the purpose of
manufacturing the specified parts and shall not disclose to any third party.
```

### 5. Version Control

Every document in the package must include:

| Field | Format | Example |
|-------|--------|---------|
| Document version | Vx.y | V1.0 |
| Date issued | YYYY-MM-DD | 2026-03-30 |
| Issued by | PM name | Ray Yeh |
| Distribution list | Partner name(s) | Shenzhen MFG Co. |
| Supersedes | Previous version | V0.9 |

### 6. File Distribution Tracking

Log every package distribution:

```
Date: YYYY-MM-DD
Package: PMLORD-MFG-PKG-YYYY-MM-DD-PartName
Version: V1.0
Distributed to: [Partner Name]
Method: [Email / WeChat / File share]
PM: [PM Name]
```

Store distribution logs at: `~/.pmlord/state/distribution-log.jsonl`

### 7. Digital File Handling

- Do NOT upload drawings to public file sharing services.
- Use password-protected ZIP files for email distribution.
- Include file checksums (MD5/SHA256) for integrity verification.
- Remove metadata from files before distribution (EXIF, author info, etc.).

## IP Classification Levels

| Level | Description | Measures Required |
|-------|-------------|-------------------|
| **Standard** | General commercial part, no special IP concerns | Watermark, customer redaction, version control |
| **Elevated** | Customer NDA active, or proprietary design | All Standard + specification splitting + distribution tracking |
| **Restricted** | Defense, medical device, patentable design | All Elevated + PM and President approval required before distribution |

## Escalation

If there is any doubt about IP handling:
- **First:** Consult Senior PM (Ray Yeh or Harley Scott)
- **Second:** Escalate to Donovan Weber (President)
