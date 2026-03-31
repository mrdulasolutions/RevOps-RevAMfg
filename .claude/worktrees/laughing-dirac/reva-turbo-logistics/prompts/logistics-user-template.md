# Logistics User Template

Use this template when interacting with the PM about shipping and logistics.

## Routing Decision

```
ROUTING DECISION for {{PO_NUMBER}} ({{CUSTOMER_COMPANY}})

Decision Factors:
- Order Value: ${{ORDER_VALUE}} {{VALUE_INDICATOR}}
- Customer Type: {{CUSTOMER_TYPE}} ({{ORDER_HISTORY}})
- Product Complexity: {{COMPLEXITY_LEVEL}}
- Partner Score: {{PARTNER_SCORE}} ({{PARTNER_NAME}})
- Customer Preference: {{CUSTOMER_PREFERENCE}}
- Regulatory Requirement: {{REGULATORY_FLAG}}

Matrix Result: {{MATRIX_RESULT}}
Recommendation: {{RECOMMENDED_ROUTING}}
Reason: {{ROUTING_REASON}}

Confirm routing? [direct-to-customer / inspect-and-forward]
```

## Shipment Setup

```
SHIPMENT SETUP for {{PO_NUMBER}}

Routing: {{ROUTING_TYPE}}
Origin: {{ORIGIN_CITY}}, {{ORIGIN_COUNTRY}}
Destination: {{DEST_CITY}}, {{DEST_STATE}} {{DEST_ZIP}}
Cargo: {{CARGO_DESCRIPTION}}
Weight: {{WEIGHT_KG}} kg / {{WEIGHT_LBS}} lbs
Dimensions: {{DIMENSIONS}}
Value: ${{DECLARED_VALUE}}

Shipping Mode Options:
1. {{MODE_1}} — {{TRANSIT_1}} — ${{COST_1}}
2. {{MODE_2}} — {{TRANSIT_2}} — ${{COST_2}}
3. {{MODE_3}} — {{TRANSIT_3}} — ${{COST_3}}

Recommended: {{RECOMMENDED_MODE}} ({{RECOMMENDATION_REASON}})

Select mode: [1/2/3]
```

## Shipment Status

```
SHIPMENT STATUS for {{PO_NUMBER}}

Carrier: {{CARRIER}}
Tracking: {{TRACKING_NUMBER}}
Mode: {{SHIPPING_MODE}}
Status: {{SHIP_STATUS}}
Origin: {{ORIGIN}}
Destination: {{DESTINATION}}
ETD: {{ETD}}
ETA: {{ETA}}
Last Update: {{LAST_UPDATE}}
Customs Status: {{CUSTOMS_STATUS}}
```

## Shipping Exception

```
SHIPPING EXCEPTION for {{PO_NUMBER}}

Exception Type: {{EXCEPTION_TYPE}}
Detail: {{EXCEPTION_DETAIL}}
Impact: {{IMPACT_DAYS}} day delay
Original ETA: {{ORIGINAL_ETA}}
Revised ETA: {{REVISED_ETA}}
Recommended Action: {{RECOMMENDED_ACTION}}

Proceed with recommended action? [Y/N]
```
