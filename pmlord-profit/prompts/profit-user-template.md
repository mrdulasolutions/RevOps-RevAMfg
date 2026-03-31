# Profit Analysis User Template

## Order Identification

- **Order ID:** {{ORDER_ID}}
- **Quote Number:** {{QUOTE_NUMBER}}
- **Customer:** {{CUSTOMER_COMPANY}}
- **Customer Contact:** {{CUSTOMER_CONTACT}}
- **Part Description:** {{PART_DESCRIPTION}}
- **Part Number:** {{PART_NUMBER}}
- **Quantity Ordered:** {{QUANTITY_ORDERED}}
- **Quantity Delivered:** {{QUANTITY_DELIVERED}}
- **Order Date:** {{ORDER_DATE}}
- **Delivery Date:** {{DELIVERY_DATE}}
- **Assigned PM:** {{ASSIGNED_PM}}
- **Manufacturing Partner:** {{MFG_PARTNER}}

## Estimated Costs (from Original Quote)

- **Material cost (extended):** ${{EST_MATERIAL_EXT}}
- **Manufacturing cost (extended):** ${{EST_MFG_EXT}}
- **Tooling cost (NRE):** ${{EST_TOOLING}}
- **Finishing cost (extended):** ${{EST_FINISH_EXT}}
- **Assembly cost (extended):** ${{EST_ASSEMBLY_EXT}}
- **Quality/Inspection cost:** ${{EST_QUALITY_EXT}}
- **Overhead allocation:** ${{EST_OVERHEAD_EXT}}
- **International shipping:** ${{EST_SHIP_INTL}}
- **Domestic shipping:** ${{EST_SHIP_DOMESTIC}}
- **Total estimated cost:** ${{EST_TOTAL_COST}}

## Quoted Revenue

- **Quoted unit price:** ${{QUOTED_PRICE_UNIT}}
- **Quoted extended price:** ${{QUOTED_PRICE_EXT}}
- **Tooling charged to customer:** ${{TOOLING_CHARGED}}
- **Shipping charged to customer:** ${{SHIPPING_CHARGED}}
- **Total quoted revenue:** ${{EST_TOTAL_REVENUE}}
- **Quoted margin %:** {{QUOTED_MARGIN}}%

## Actual Costs (from Invoices and Records)

### Material
- **Actual material cost:** ${{ACT_MATERIAL_EXT}}
- **Material invoice reference:** {{MATERIAL_INVOICE_REF}}
- **Material notes:** {{MATERIAL_NOTES}}

### Manufacturing
- **Actual manufacturing cost:** ${{ACT_MFG_EXT}}
- **Setup/changeover charges:** ${{ACT_SETUP}}
- **Partner invoice reference:** {{PARTNER_INVOICE_REF}}
- **Manufacturing notes:** {{MFG_NOTES}}

### Tooling
- **Actual tooling cost:** ${{ACT_TOOLING}}
- **Tooling shared across orders:** {{TOOLING_SHARED}} (yes/no)
- **If shared, total units across all orders:** {{TOOLING_TOTAL_UNITS}}
- **Tooling notes:** {{TOOLING_NOTES}}

### Finishing
- **Actual finishing cost:** ${{ACT_FINISH_EXT}}
- **Finishing notes:** {{FINISH_NOTES}}

### Shipping
- **Actual international shipping:** ${{ACT_SHIP_INTL}}
- **Customs duties and brokerage:** ${{ACT_CUSTOMS}}
- **Actual domestic shipping:** ${{ACT_SHIP_DOMESTIC}}
- **Shipping mode used:** {{SHIP_MODE}} (ocean/air/courier)
- **Shipping notes:** {{SHIP_NOTES}}

### Quality
- **Inspection labor cost (internal):** ${{ACT_INSPECTION}}
- **Third-party testing/certification:** ${{ACT_TESTING}}
- **Quality notes:** {{QUALITY_NOTES}}

### Scrap/Rework/Warranty
- **Scrap/rework cost:** ${{ACT_SCRAP}}
- **Number of NCRs:** {{NCR_COUNT}}
- **NCR IDs:** {{NCR_IDS}}
- **Warranty/return cost:** ${{ACT_WARRANTY}}
- **Warranty notes:** {{WARRANTY_NOTES}}

### Other
- **Repackaging cost:** ${{ACT_REPACK}}
- **Other costs:** ${{ACT_OTHER}}
- **Other cost description:** {{OTHER_DESCRIPTION}}

## Actual Revenue

- **Actual unit price (if different from quoted):** ${{ACT_PRICE_UNIT}}
- **Change order adjustments:** ${{CHANGE_ORDER_ADJ}}
- **Credits/refunds issued:** ${{CREDITS_ISSUED}}
- **Total actual revenue:** ${{ACTUAL_REVENUE}}

## Analysis Context

- **Process type:** {{PROCESS_TYPE}} (machining/molding/sheet metal/casting/other)
- **Customer tier:** {{CUSTOMER_TIER}} (Platinum/Gold/Silver/New)
- **Order complexity:** {{COMPLEXITY}} (1-5)
- **First order from this customer:** {{FIRST_ORDER}} (yes/no)
- **Any change orders during production:** {{CHANGE_ORDERS}} (yes/no)
- **Any quality issues during production:** {{QUALITY_ISSUES}} (yes/no)
- **PM notes on this order:** {{PM_NOTES}}
