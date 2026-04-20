# REVA-TURBO Shipping Defaults Reference

Default carrier, port, incoterms, and transit time reference data for Section 5 (Shipping & Logistics) of the setup wizard.

---

## Major China Origin Ports

| Port Name | UN/LOCODE | Region | Notes |
|---|---|---|---|
| Shanghai | CNSHA | East China | Largest port in the world by throughput |
| Shenzhen / Yantian | CNSZX | South China | Pearl River Delta, electronics hub |
| Ningbo-Zhoushan | CNNGB | East China | Zhejiang province, heavy industry |
| Qingdao | CNTAO | North China | Shandong province |
| Guangzhou / Nansha | CNGZH | South China | Pearl River Delta |
| Xiamen | CNXMN | Southeast China | Fujian province |
| Tianjin | CNTSN | North China | Near Beijing |
| Dalian | CNDLC | Northeast China | Liaoning province |
| Suzhou / Taicang | CNTAC | East China | Yangtze River Delta |
| Fuzhou | CNFOC | Southeast China | Fujian province |

---

## Major US Destination Ports

| Port Name | UN/LOCODE | Region | Notes |
|---|---|---|---|
| Los Angeles / Long Beach | USLAX | West Coast | Busiest US port complex, 40% of US imports |
| Oakland | USOAK | West Coast | Northern California gateway |
| Seattle / Tacoma | USSEA | Pacific NW | Northwest Alliance port |
| Newark / New York | USEWR | East Coast | Largest East Coast port |
| Savannah | USSAV | Southeast | Fast-growing, deepwater port |
| Houston | USHOU | Gulf Coast | Energy and industrial corridor |
| Charleston | USCHS | Southeast | Deepwater port, growing rapidly |
| Miami | USMIA | Southeast | Latin America gateway |
| Chicago | USCHI | Midwest | Major inland rail hub |
| Memphis | USMEM | Midwest | FedEx global hub |

---

## Incoterms Definitions (2020)

### FOB — Free On Board
- **Seller responsibility:** Deliver goods to the vessel at the port of origin, clear for export
- **Buyer responsibility:** Freight from origin port, insurance, import clearance, delivery to destination
- **Risk transfer:** At the ship's rail in the port of origin
- **Best for:** Most China manufacturing relationships. Buyer controls freight costs and carrier selection
- **Typical use:** Standard for Rev A Mfg China orders

### CIF — Cost, Insurance, and Freight
- **Seller responsibility:** Deliver to origin port, pay freight and insurance to destination port
- **Buyer responsibility:** Import clearance, duties, delivery from destination port
- **Risk transfer:** At the ship's rail in the port of origin (despite seller paying freight)
- **Best for:** When seller has better freight rates or buyer wants simplicity
- **Note:** Insurance is minimum coverage only; buyer should consider additional coverage

### DDP — Delivered Duty Paid
- **Seller responsibility:** Everything — freight, insurance, export clearance, import clearance, duties, delivery to buyer's door
- **Buyer responsibility:** Unload at destination
- **Risk transfer:** At buyer's premises
- **Best for:** Turn-key projects, sellers who want full control, buyers who want simplicity
- **Caution:** Seller must be able to clear customs in buyer's country

### EXW — Ex Works
- **Seller responsibility:** Make goods available at seller's premises
- **Buyer responsibility:** Everything — pickup, export clearance, freight, insurance, import clearance
- **Risk transfer:** At seller's premises
- **Best for:** When buyer has own freight forwarder in origin country
- **Caution:** Buyer may need export license in seller's country

### FCA — Free Carrier
- **Seller responsibility:** Deliver goods to carrier at named place, clear for export
- **Buyer responsibility:** Freight from named place, insurance, import clearance
- **Risk transfer:** At delivery to carrier
- **Best for:** Containerized cargo, multimodal transport
- **Note:** More flexible than FOB for non-port deliveries

### DAP — Delivered At Place
- **Seller responsibility:** Deliver to named destination (buyer's warehouse, etc.), not unloaded
- **Buyer responsibility:** Import clearance, duties, unloading
- **Risk transfer:** At named destination, before unloading
- **Best for:** When seller handles logistics but buyer handles customs

---

## Common Carrier Services

### Express Couriers (1-5 days)

| Carrier | Service | Transit (China to US) | Weight Limit | Notes |
|---|---|---|---|---|
| FedEx | International Priority | 1-3 days | 150 lbs/pkg | Door-to-door, tracking |
| FedEx | International Economy | 2-5 days | 150 lbs/pkg | Lower cost option |
| UPS | Worldwide Express | 1-3 days | 150 lbs/pkg | Door-to-door |
| UPS | Worldwide Expedited | 2-5 days | 150 lbs/pkg | Economy option |
| DHL | Express Worldwide | 1-3 days | 150 lbs/pkg | Strong Asia network |
| DHL | Express Economy | 3-7 days | No limit | Deferred service |

### Air Freight (3-7 days)

| Service | Transit | Notes |
|---|---|---|
| Direct air charter | 2-3 days | Expensive, for urgent large shipments |
| Consolidated air freight | 3-5 days | Shared aircraft, cost-effective for 100+ kg |
| Deferred air freight | 5-7 days | Lower cost, flexible timing |

### Ocean Freight (14-35 days)

| Route | Transit (Shanghai/Shenzhen) | Notes |
|---|---|---|
| To LA/Long Beach | 14-18 days | West Coast direct |
| To Oakland | 15-19 days | Northern California |
| To Seattle/Tacoma | 12-16 days | Shortest Pacific crossing |
| To Newark/NY | 25-35 days | Via Panama Canal or Suez |
| To Savannah | 28-35 days | Via Panama Canal |

| Container Type | Size | Capacity | Notes |
|---|---|---|---|
| 20' Standard (TEU) | 20' x 8' x 8'6" | ~28 CBM | Standard small load |
| 40' Standard | 40' x 8' x 8'6" | ~58 CBM | Most common |
| 40' High Cube (HQ) | 40' x 8' x 9'6" | ~68 CBM | Extra height, popular |
| LCL (Less than Container) | Shared | Per CBM | For partial loads |

---

## Default Insurance Recommendations

| Coverage Level | Description | When to Use |
|---|---|---|
| 100% declared value | Covers full invoice value | Minimum acceptable |
| 110% declared value | Industry standard — covers value + anticipated profit | **Recommended default** |
| 120% declared value | Extended coverage | High-value or fragile goods |
| All-risk marine cargo | Comprehensive coverage including damage | For sensitive equipment |

### Recommended Minimum
- All ocean shipments: 110% CIF value, all-risk marine cargo insurance
- All air shipments over $5,000: 110% declared value
- Express courier under $5,000: carrier's included coverage is typically sufficient

---

## Shipping Method Recommendations by Order Value

| Order Value | Recommended Method | Typical Cost % | Notes |
|---|---|---|---|
| Under $500 | Express courier (FedEx/DHL) | 15-25% of value | Speed justifies cost |
| $500 - $5,000 | Express courier or air freight | 8-15% of value | Balance of speed and cost |
| $5,000 - $25,000 | Air freight (consolidated) or LCL | 5-10% of value | Air for urgent, LCL for cost |
| $25,000 - $100,000 | Ocean LCL or FCL | 3-6% of value | FCL if volume justifies |
| Over $100,000 | Ocean FCL | 2-4% of value | Full container, best rates |
