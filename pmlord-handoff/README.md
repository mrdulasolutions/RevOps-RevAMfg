# pmlord-handoff

Multi-PM collaboration and portfolio transfer skill for the PMLORD engine.

## What It Does

Enables seamless PM-to-PM portfolio management at Rev A Manufacturing:

1. **Vacation handoff** -- transfers entire portfolio to backup PM with full context, auto-reverts on return
2. **Permanent transfer** -- moves specific orders or customers to a different PM
3. **Shared ownership** -- adds secondary PM with configurable authority level
4. **Approval routing** -- routes documents to the correct approver based on type and value thresholds
5. **Workload balancing** -- monitors PM workload and suggests redistributions when imbalanced

## Usage

```
/pmlord-handoff
```

Select from five modes: vacation handoff, permanent transfer, shared ownership, approval request, or workload check.

## Inputs

- PM names and roles
- Vacation dates (for temporary handoff)
- Order/customer IDs (for transfers)
- Approval type and value (for approval routing)

## Outputs

- Handoff Briefing saved to `~/.pmlord/handoffs/{handoff-id}/`
- Return Briefing generated on PM return
- Handoff audit trail at `~/.pmlord/state/handoff-log.jsonl`
- Approval decisions at `~/.pmlord/state/approval-log.jsonl`
- Alert routing updates at `~/.pmlord/state/alert-routing.jsonl`

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill instructions and flow |
| `skill.yaml` | Skill manifest |
| `prompts/handoff-system.md` | Briefing generation and approval logic |
| `prompts/handoff-user-template.md` | Handoff request variables |
| `references/handoff-checklist.md` | Required items for every handoff |
| `references/approval-matrix.md` | Who approves what at which thresholds |
| `references/workload-model.md` | PM workload weighting and balance rules |
| `templates/Handoff Briefing.md` | Comprehensive handoff briefing template |
| `templates/Return Briefing.md` | Post-vacation return briefing template |

## Next Step

After a vacation handoff, the backup PM should review the briefing immediately. On return, the system generates a return briefing automatically.
