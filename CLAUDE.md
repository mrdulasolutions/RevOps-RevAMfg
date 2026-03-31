# PMLORD — Claude Code Project Instructions

This is the **PMLORD Skills Engine** for Rev A Manufacturing. It is a Claude Code skills engine that automates the Product Manager workflow from RFQ intake through customer delivery.

## Architecture

- Each skill lives in its own directory with `SKILL.md`, `skill.yaml`, `README.md`, and supporting files
- The master orchestrator is `pmlord-engine/SKILL.md`
- Runtime state is stored at `~/.pmlord/` (config, sessions, analytics, workflow state)
- All reports use `{{PLACEHOLDER}}` templates and are converted to `.docx` via `pmlord-docx/scripts/report-to-docx.mjs`

## Key Rules

1. **Always read CLIENT.md** before generating any customer-facing content for Rev A Mfg defaults
2. **Human-in-the-loop**: Never auto-send communications or auto-approve quality gates without PM confirmation
3. **Data sensitivity**: Customer specs, drawings, and pricing are confidential. Check before writing to unprotected locations
4. **Report naming**: `PMLORD-{Type}-{YYYY-MM-DD}-{ShortName}.docx`
5. **Escalation**: All escalation goes through the matrix in CLIENT.md. Donovan Weber is the final escalation

## Skill Invocation

Skills are invoked via `/pmlord-*` slash commands. The `pmlord-engine` orchestrator routes intent to the correct sub-skill automatically.

## File Structure

- `bin/` — Engine utilities (pmlord-config, pmlord-telemetry-log, etc.)
- `pmlord-docx/scripts/` — DOCX conversion script (report-to-docx.mjs)
- `pmlord-*/` — Individual skill directories
- `CLIENT.md` — Rev A Mfg company profile
- `conductor.json` — Skill routing configuration
