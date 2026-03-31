# Repackaging User Template

Use this template when interacting with the PM about repackaging tasks.

## Work Order Request

```
REPACKAGING WORK ORDER REQUEST

PO Number: {{PO_NUMBER}}
Customer: {{CUSTOMER_COMPANY}}
Part: {{PART_DESCRIPTION}}
Quantity: {{QUANTITY}}
Inspection Status: {{INSPECTION_STATUS}}

Customer Packaging Requirements:
{{PACKAGING_REQUIREMENTS}}

Labeling Requirements:
{{LABELING_REQUIREMENTS}}

Special Instructions:
{{SPECIAL_INSTRUCTIONS}}

Target Completion: {{TARGET_DATE}}

Generate work order? [Y/N]
```

## Packaging Plan Review

```
PACKAGING PLAN for {{PO_NUMBER}}

Package Type: {{PACKAGING_TYPE}}
Inner Protection: {{INNER_PACKAGING}}
Additional Materials: {{ADDITIONAL_MATERIALS}}
Labels Required:
  - Product Label: {{PRODUCT_LABEL_SPEC}}
  - Shipping Label: {{SHIPPING_LABEL_SPEC}}
  - Origin Marking: {{ORIGIN_MARKING}}
  - Customer Labels: {{CUSTOMER_LABELS}}
  - Regulatory Labels: {{REGULATORY_LABELS}}

Estimated Completion: {{EST_COMPLETION}}
Estimated Packages: {{EST_PACKAGES}}

Approve? [Y/N/Modify]
```

## Completion Report

```
REPACKAGING COMPLETE for {{PO_NUMBER}}

Work Order: {{WO_NUMBER}}
Completed By: {{COMPLETED_BY}}
Completion Date: {{COMPLETION_DATE}}
Packages: {{NUM_PACKAGES}}
Total Weight: {{TOTAL_WEIGHT}}
Dimensions: {{PACKAGE_DIMENSIONS}}

All labels applied: {{LABELS_VERIFIED}}
Ready for shipment: {{READY_FOR_SHIP}}

Next: Set up domestic shipping? [Y/N]
```
