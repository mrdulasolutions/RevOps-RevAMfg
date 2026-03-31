# Section 4 of 7: Manufacturing Partners

## Overview

Build the manufacturing partner roster — the factories, suppliers, and subcontractors that REVA-TURBO will use for quoting, ordering, and quality tracking. Each partner gets a detailed profile with capabilities, lead times, quality ratings, and contact information.

This data drives:
- `reva-turbo-china-package` — knows which partners can handle which part types
- `reva-turbo-rfq-quote` — pulls lead times and quality ratings for quoting
- `reva-turbo-partner-scorecard` — tracks partner performance over time
- `reva-turbo-pulse` — sends alerts through preferred communication channels

## Questions (Per Partner)

Collect partners in a loop. At least one partner is recommended but not required.

### Q1: Partner Company Name (required)

> Manufacturing partner company name:
> Example: "Shenzhen Precision Machining Co., Ltd."

### Q2: Country (required)

> Where is this partner located?
> A) China
> B) Taiwan
> C) Vietnam
> D) India
> E) Mexico
> F) United States
> G) Other (specify)

### Q3: City (required)

> City:
> Example: "Shenzhen", "Dongguan", "Taipei"

### Q4: Primary Contact (required)

> Primary contact at [partner name]:
> - Full name:
> - Email:
> - Phone:
> - WeChat ID: (if China/Taiwan, optional otherwise)
> - WhatsApp: (optional)

Validation:
- Name: required
- Email: required, must contain @
- Phone: required
- WeChat: prompted only if country is China or Taiwan
- WhatsApp: always optional

### Q5: Capabilities (required, multi-select)

> What manufacturing capabilities does [partner name] offer?
> Enter all that apply (e.g., "A,B,F,G"):
>
> A) CNC Machining (milling, turning, EDM)
> B) Injection Molding (plastic, rubber, silicone)
> C) Sheet Metal / Stamping (laser, punching, forming)
> D) Die Casting (aluminum, zinc, magnesium)
> E) Investment Casting (steel, stainless, bronze)
> F) Assembly (mechanical, electromechanical)
> G) Surface Finishing / Plating (anodizing, powder coat, chrome, paint)
> H) 3D Printing / Additive Manufacturing (SLA, SLS, FDM, MJF)
> I) PCB / Electronics (board fab, SMT assembly, box build)
> J) Packaging (custom packaging, kitting, labeling)
> K) Other (specify)

At least one capability is required.

### Q6: Lead Times by Complexity (required)

> Typical lead times for [partner name]:
>
> Simple parts (basic geometry, single operation): ___ days
>   Example: turned spacers, simple brackets
>
> Moderate parts (multiple operations, tight tolerances): ___ days
>   Example: multi-axis machined housings, insert-molded parts
>
> Complex parts (assemblies, multiple processes): ___ days
>   Example: electromechanical assemblies, precision mechanisms

Validation: Positive integers. Warn if simple > moderate or moderate > complex.

### Q7: Quality Rating (required)

> Quality rating for [partner name]:
> A) A / Excellent — Consistently meets or exceeds specs, < 1% defect rate
> B) B / Good — Meets specs with rare issues, 1-3% defect rate
> C) C / Acceptable — Meets basic specs, occasional rework needed, 3-5%
> D) D / Probation — Quality issues documented, improvement plan required
> E) F / Blocked — Do not send new orders until resolved

For new partners without history, recommend starting at B or C.

### Q8: IP Protection Level (required)

> Intellectual property protection level with [partner name]:
> A) Full NNN Agreement — Non-disclosure, non-use, non-circumvention signed
> B) NDA Only — Standard non-disclosure agreement on file
> C) Limited Disclosure — No formal agreement, share minimum info only
> D) None / Pending — No IP protection in place

Warn if D: "Orders to partners without IP protection carry risk. Consider executing an NDA before sending technical packages."

### Q9: Communication Preference (required)

> Preferred communication method with [partner name]:
> A) Email
> B) WeChat
> C) WhatsApp
> D) Phone
> E) Mixed (email for formal, messaging for quick updates)

### Q10: Timezone (required)

> Partner's timezone:
> Example: Asia/Shanghai, Asia/Taipei, America/Mexico_City

Provide common options based on selected country. Default:
- China: Asia/Shanghai
- Taiwan: Asia/Taipei
- Vietnam: Asia/Ho_Chi_Minh
- India: Asia/Kolkata
- Mexico: America/Mexico_City
- USA: ask for specific timezone

### Q11: Payment Terms (required)

> Payment terms with [partner name]:
> A) Net 30 — Payment due 30 days after invoice
> B) Net 60 — Payment due 60 days after invoice
> C) 50/50 — 50% deposit at order, 50% before shipment
> D) T/T in Advance — Full payment before production starts
> E) Custom (specify)

---

## Partner Summary Card

After collecting all data for a partner, display:

```
┌─────────────────────────────────────────────────────┐
│  PARTNER: [Name]                                    │
├──────────────────┬──────────────────────────────────┤
│  Location        │  [City], [Country]               │
│  Contact         │  [Name] — [email]                │
│  Comms           │  [preference] | TZ: [timezone]   │
│  Capabilities    │  [comma-separated list]          │
│  Lead Times      │  S: [x]d / M: [x]d / C: [x]d    │
│  Quality         │  [rating letter] — [description] │
│  IP Protection   │  [level]                         │
│  Payment         │  [terms]                         │
└──────────────────┴──────────────────────────────────┘
```

Ask: "Is this partner info correct? A) Yes  B) Edit a field  C) Remove this partner"

Then: "Add another manufacturing partner? (Y/N)"

## Final Partner Roster

After all partners are entered, display the full roster as a compact table:

```
┌────┬────────────────────────┬──────────────┬───────┬──────────────────────┐
│  # │  Partner               │  Location    │  Qual │  Capabilities        │
├────┼────────────────────────┼──────────────┼───────┼──────────────────────┤
│  1 │  Shenzhen Precision    │  Shenzhen CN │   A   │  CNC, Sheet Metal    │
│  2 │  Dongguan Mold Works   │  Dongguan CN │   B   │  Injection Molding   │
│  3 │  ...                   │  ...         │  ...  │  ...                 │
└────┴────────────────────────┴──────────────┴───────┴──────────────────────┘
```

Confirm: A) Save all, B) Edit a partner, C) Add another, D) Start over.

## Output

Write to `~/.reva-turbo/config/partners.yaml` using `templates/partners.yaml.tmpl`.
