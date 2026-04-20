# Handoff User Template

## Handoff Request Variables

### Common Fields (all modes)

- **Requesting PM:** {{REQUESTING_PM}}
- **Handoff mode:** {{HANDOFF_MODE}} (vacation / permanent / shared / approval / workload)
- **Date requested:** {{REQUEST_DATE}}

### Vacation Handoff

- **Departing PM:** {{DEPARTING_PM}}
- **Backup PM:** {{BACKUP_PM}}
- **Vacation start date:** {{VACATION_START}}
- **Vacation end date:** {{VACATION_END}}
- **Emergency contact:** {{EMERGENCY_CONTACT}}
- **Items excluded from transfer:** {{EXCLUDED_ITEMS}}
- **Special instructions:** {{SPECIAL_INSTRUCTIONS}}

### Permanent Transfer

- **Transferring PM:** {{FROM_PM}}
- **Receiving PM:** {{TO_PM}}
- **Transfer scope:** {{TRANSFER_SCOPE}} (specific orders / specific customers / criteria-based)
- **Items to transfer:** {{TRANSFER_ITEMS}}
- **Reason for transfer:** {{TRANSFER_REASON}}

### Shared Ownership

- **Order/RFQ ID:** {{SHARED_ITEM_ID}}
- **Primary PM:** {{PRIMARY_PM}}
- **Secondary PM:** {{SECONDARY_PM}}
- **Secondary role:** {{SECONDARY_ROLE}} (visibility / specific actions / full co-ownership)
- **Specific actions for secondary:** {{SECONDARY_ACTIONS}}
- **Duration:** {{SHARED_DURATION}}

### Approval Request

- **Approval type:** {{APPROVAL_TYPE}}
- **Item ID:** {{APPROVAL_ITEM_ID}}
- **Customer:** {{APPROVAL_CUSTOMER}}
- **Value/amount:** ${{APPROVAL_VALUE}}
- **Requesting PM:** {{REQUESTING_PM}}
- **PM recommendation:** {{PM_RECOMMENDATION}}
- **Approver (per matrix):** {{APPROVER}}
- **Time sensitivity:** {{TIME_SENSITIVITY}}
- **Context summary:** {{CONTEXT_SUMMARY}}

### Approval Decision

- **Approver:** {{APPROVER}}
- **Decision:** {{DECISION}} (approve / approve with conditions / reject / request info)
- **Conditions:** {{CONDITIONS}}
- **Rejection reason:** {{REJECTION_REASON}}
- **Information requested:** {{INFO_REQUESTED}}

### Workload Check

- **PMs to include:** {{PM_LIST}} (all / specific names)
- **Include RFQs in calculation:** {{INCLUDE_RFQS}} (yes/no)
- **Redistribution suggestions:** {{SUGGEST_REDISTRIBUTION}} (yes/no)
