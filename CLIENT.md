# Rev A Mfg — Client Profile

This engine is tailored for **Rev A Manufacturing** (Rev A Mfg). Use this for default company name, escalation, PM assignments, and capability references across all PMLORD skills.

## Company

| Field | Value |
|-------|--------|
| **Legal name** | Rev A Manufacturing |
| **Short name** | Rev A Mfg |
| **Industry** | Contract manufacturing — production machining, injection tooling & molding, prototyping, sheet metal, finishing & assembly. Sources manufacturing from partners in China; performs inspection, repackaging, and fulfillment domestically. |
| **Website** | [revamfg.com](https://www.revamfg.com) |
| **Business model** | Receive RFQ -> Qualify -> Quote -> Send specs to China partners -> Receive goods -> Inspect/Repackage -> Ship to customer |

## Leadership & Escalation

| Role | Name / Contact |
|------|----------------|
| **President & Co-founder** | Donovan Weber |
| **Escalation (all)** | Donovan Weber |

## Product Management Team

| Name | Role | Region / Focus |
|------|------|----------------|
| **Ray Yeh** | Senior Project Manager | — |
| **Harley Scott** | Senior Project Manager | — |

## Business Development

| Name | Role | Region |
|------|------|--------|
| **Matt Nebo** | Director of Business Development | West Coast |
| **Barry Coyle** | Director of Business Development | Midwest |
| **Bryce Martel** | Director of Business Development | East Coast |
| **Ryan Knight** | Business Development | — |

## Manufacturing Capabilities

Rev A Mfg offers these services (sourced via China manufacturing partners):

- **Production machining** — CNC milling, turning, multi-axis
- **Injection tooling & molding** — mold design, tooling fabrication, injection molding
- **Prototyping** — rapid prototyping, 3D printing, short-run production
- **Sheet metal** — laser cutting, bending, forming, welding
- **Finishing** — anodizing, plating, powder coating, painting, polishing
- **Assembly** — mechanical assembly, sub-assembly, kitting, packaging

## CRM & Systems

| System | Details |
|--------|---------|
| **CRM** | Microsoft Power Apps / Dynamics 365 (confirm with client) |
| **RFQ sources** | Email, website (revamfg.com), CRM |
| **Record storage** | Confirm with client (likely SharePoint or shared drive) |

## PM Assignment Logic

New RFQs are assigned to a PM based on:
1. **Current load** — assign to PM with lowest active order count
2. **Expertise** — match PM experience to part complexity and process type
3. **Customer relationship** — returning customers stay with their existing PM

## Escalation Matrix

| Issue Type | First Escalation | Second Escalation |
|-----------|-----------------|-------------------|
| Quality issue | Senior PM (Ray Yeh / Harley Scott) | Donovan Weber |
| Delivery delay (>2 weeks) | Senior PM | Donovan Weber |
| Customer complaint | Senior PM | Donovan Weber |
| New capability request | BD Director (regional) | Donovan Weber |
| Payment / credit issue | Senior PM | Donovan Weber |
| Legal / contractual | Donovan Weber (direct) | — |

## Template Defaults

When generating reports, quotes, communications, or other documents, use:

- **Company:** Rev A Manufacturing
- **Escalation contact:** Donovan Weber, President & Co-founder
- **Report prefix:** PMLORD
- **Report naming:** `PMLORD-{Type}-{YYYY-MM-DD}-{ShortName}.docx`
