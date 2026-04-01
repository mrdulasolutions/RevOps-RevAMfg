# REVA-TURBO — Claude Code Project Instructions

This is the **REVA-TURBO Skills Engine** for Rev A Manufacturing. It is a Claude Code skills engine that automates the Product Manager workflow from RFQ intake through customer delivery.

## Architecture

- Each skill lives in its own directory with `SKILL.md`, `skill.yaml`, `README.md`, and supporting files
- The master orchestrator is `skills/revmyengine/SKILL.md`
- Runtime state is stored at `~/.reva-turbo/` (config, sessions, analytics, workflow state)
- All reports use `{{PLACEHOLDER}}` templates and are converted to `.docx` via `skills/reva-turbo-docx/scripts/report-to-docx.mjs`

## Key Rules

1. **Always read CLIENT.md** before generating any customer-facing content for Rev A Mfg defaults
2. **Human-in-the-loop**: Never auto-send communications or auto-approve quality gates without PM confirmation
3. **Data sensitivity**: Customer specs, drawings, and pricing are confidential. Check before writing to unprotected locations
4. **Report naming**: `REVA-TURBO-{Type}-{YYYY-MM-DD}-{ShortName}.docx`
5. **Escalation**: All escalation goes through the matrix in CLIENT.md. Donovan Weber is the final escalation

## Skill Invocation

Skills are invoked via `/reva-turbo-*` slash commands. The `revmyengine` orchestrator routes intent to the correct sub-skill automatically.

## File Structure

- `bin/` — Engine utilities (reva-turbo-config, reva-turbo-telemetry-log, etc.)
- `skills/reva-turbo-docx/scripts/` — DOCX conversion script (report-to-docx.mjs)
- `skills/reva-turbo-*/` — Individual skill directories
- `CLIENT.md` — Rev A Mfg company profile
- `conductor.json` — Skill routing configuration
