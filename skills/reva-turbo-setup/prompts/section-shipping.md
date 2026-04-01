# Section 5 of 7: Shipping & Logistics

## Overview

Configure shipping carriers, customs brokers, origin/destination ports, incoterms, insurance, and freight forwarders. This data drives `reva-turbo-logistics`, `reva-turbo-export-compliance`, and `reva-turbo-import-compliance`.

Reference `references/shipping-defaults.md` for port codes, incoterms definitions, and carrier details.

## Questions

### Q1: Preferred Carriers (multi-select)

> Select your preferred shipping carriers (enter all that apply):
> A) FedEx (express, ground, freight)
> B) UPS (express, ground, freight)
> C) DHL (express, global forwarding)
> D) USPS (domestic small packages)
> E) Freight forwarder — specify name
> F) Other — specify

For each selected carrier, ask:
> Account number for [carrier] (optional, or "N/A"):

### Q2: Customs Broker

> Do you use a customs broker for import clearance?
> A) Yes, configure customs broker
> B) No / Handle in-house
> C) Configure later

**If A:**
- Broker company name:
- Contact person:
- Phone:
- Email:
- Customs broker license number (optional):
- Preferred port of entry:

### Q3: Origin Ports (multi-select)

> Which origin ports do your manufacturing partners typically ship from?
> Select all that apply:
>
> A) Shanghai (CNSHA) — China's largest port
> B) Shenzhen / Yantian (CNSZX) — South China / Pearl River Delta
> C) Ningbo (CNNGB) — Zhejiang province
> D) Qingdao (CNTAO) — North China
> E) Guangzhou (CNGZH) — Pearl River Delta
> F) Xiamen (CNXMN) — Fujian province
> G) Tianjin (CNTSN) — North China
> H) Other — specify port and code

At least one origin port is recommended if international manufacturing is used.

### Q4: Destination Ports (multi-select)

> Which US (or other) destination ports do you receive shipments at?
> Select all that apply:
>
> A) Los Angeles / Long Beach (USLAX) — West Coast primary
> B) Oakland (USOAK) — Northern California
> C) Seattle / Tacoma (USSEA) — Pacific Northwest
> D) Newark / New York (USEWR) — East Coast primary
> E) Savannah (USSAV) — Southeast
> F) Houston (USHOU) — Gulf Coast
> G) Chicago (USCHI) — Inland rail hub
> H) Miami (USMIA) — Florida / Latin America
> I) Other — specify port and code

### Q5: Default Incoterms

> What are your default trade terms (Incoterms)?
> A) FOB (Free On Board) — Seller delivers to port of origin, buyer pays freight
> B) CIF (Cost, Insurance, Freight) — Seller pays to destination port
> C) DDP (Delivered Duty Paid) — Seller delivers to your door, all costs included
> D) EXW (Ex Works) — Buyer picks up at factory, handles everything
> E) FCA (Free Carrier) — Seller delivers to carrier at named place
> F) DAP (Delivered At Place) — Seller delivers to destination, buyer handles import

Show a brief definition for each (from `references/shipping-defaults.md`). Recommend FOB for most China manufacturing relationships.

### Q6: Insurance

> Shipping insurance configuration:
>
> Insurance provider name (or "TBD"):
> Default coverage level:
>   A) Full declared value
>   B) 110% of declared value (industry standard)
>   C) Custom percentage — specify

### Q7: Freight Forwarder

> Do you use a freight forwarder for ocean/air freight?
> A) Yes, configure
> B) No / Configure later

**If A:**
- Company name:
- Contact person:
- Phone:
- Email:
- Specialization: A) Ocean freight, B) Air freight, C) Both

### Q8: Shipping Method by Order Value

> Set default shipping methods based on order value:
>
> Under $500:
>   A) Express courier (FedEx/UPS/DHL Express)
>   B) Economy courier
>   C) Other
>
> $500 — $5,000:
>   A) Express courier
>   B) Air freight (consolidated)
>   C) Other
>
> $5,000 — $25,000:
>   A) Air freight
>   B) Ocean freight LCL (less than container)
>   C) Other
>
> Over $25,000:
>   A) Ocean freight FCL (full container)
>   B) Ocean freight LCL
>   C) Air freight (urgent)
>   D) Other

## Summary Display

```
┌─────────────────────────────────────────────────────┐
│  SHIPPING & LOGISTICS SUMMARY                       │
├──────────────────┬──────────────────────────────────┤
│  Carriers        │  [list]                          │
│  Customs Broker  │  [name] or "Not configured"      │
│  Origin Ports    │  [list with codes]               │
│  Dest. Ports     │  [list with codes]               │
│  Incoterms       │  [default term]                  │
│  Insurance       │  [provider] — [coverage]         │
│  Freight Fwd     │  [name] or "Not configured"      │
│  Ship by Value   │  <$500: [method]                 │
│                  │  $500-5K: [method]               │
│                  │  $5K-25K: [method]               │
│                  │  >$25K: [method]                 │
└──────────────────┴──────────────────────────────────┘
```

Confirm: A) Save, B) Edit, C) Start over.

## Output

Write to `~/.reva-turbo/config/shipping-config.yaml` using `templates/shipping-config.yaml.tmpl`.
