# reva-turbo-voice

Per-user voice and personality tuner for the REVA-TURBO Skills Engine.

## What It Does

Every PM communicates differently. This skill captures each PM's unique writing style, tone, and preferences through a structured onboarding process, then applies that voice profile to ALL engine-generated content: customer emails, partner communications, quotes, reports, escalation notices, and internal notes.

The goal: make generated content indistinguishable from what the PM would write themselves.

## 3-Phase Onboarding

### Phase 1: Sample Analysis

The PM pastes 2-3 recent emails they have sent. The engine analyzes:

- Greeting and signoff patterns
- Sentence length and complexity
- Formality markers (contractions, passive voice, "please" usage)
- Bullet vs prose preference
- Technical depth
- Humor and personality markers
- Urgency language
- Favorite phrases

### Phase 2: Structured Interview

Walk through 18 voice dimensions with concrete A/B/C/D examples. The PM picks the option closest to their style, or describes their own preference. Phase 1 results pre-populate suggested defaults.

### Phase 3: Preferences

Capture workflow preferences, pain points, time sinks, anti-patterns, and defaults. This goes beyond voice into how the PM wants the engine to behave.

## Voice Dimensions (18)

| # | Dimension | Type | Description |
|---|-----------|------|-------------|
| 1 | `tone` | Scale 1-10 | Formal to casual |
| 2 | `technical_depth` | Choice | minimal / moderate / deep |
| 3 | `sentence_length` | Choice | short / medium / long |
| 4 | `detail_level` | Choice | concise / standard / thorough |
| 5 | `greeting_style` | Text | How emails open |
| 6 | `signoff_style` | Text | How emails close |
| 7 | `favorite_phrases` | Array | Phrases the PM uses often |
| 8 | `banned_phrases` | Array | Phrases to NEVER use |
| 9 | `email_length` | Choice | short / medium / long |
| 10 | `report_detail` | Choice | executive_summary / standard / comprehensive |
| 11 | `formality` | Scale 1-10 | Independent of tone |
| 12 | `partner_reference_style` | Text | How to refer to China partners |
| 13 | `quote_cover_style` | Choice | formal_letter / brief_email / detailed_proposal |
| 14 | `urgency_language` | Choice | measured / direct / strong |
| 15 | `bullet_vs_prose` | Choice | bullets / prose / mixed |
| 16 | `humor_level` | Choice | none / occasional / frequent |
| 17 | `customer_tier_adaptation` | Boolean | Vary tone by customer tier |
| 18 | `internal_vs_external` | Boolean | Different voice for team vs customer |

## Continuous Learning

After profile creation, the engine passively tracks PM edits to generated content:

- When a PM modifies an engine-generated email before sending, the edit is logged
- After 5+ consistent edits in the same direction, the engine suggests a profile update
- Example: if the PM always changes "Dear Mr. Smith" to "Hi John," the engine suggests updating `greeting_style`
- Edit history stored at `~/.reva-turbo/users/<pm-slug>/edit-history.jsonl`

## 4 Modes

| Mode | Command | Description |
|------|---------|-------------|
| `create` | `/reva-turbo-voice create` | Full 3-phase onboarding |
| `edit` | `/reva-turbo-voice edit` | Modify specific dimensions |
| `view` | `/reva-turbo-voice view` | Display current profile |
| `learn` | `/reva-turbo-voice learn` | Review edit history, suggest updates |

## File Structure

```
reva-turbo-voice/
  SKILL.md              — Main skill definition
  skill.yaml            — Skill metadata
  README.md             — This file
  prompts/
    voice-system.md     — Voice tuning methodology
    voice-interview.md  — Complete structured interview script
    voice-analysis.md   — Sample email analysis rules
    voice-apply.md      — How to apply profiles to output
  references/
    voice-dimensions.md — Full dimension documentation
    voice-defaults.md   — Rev A Mfg baseline profile
    voice-examples.md   — Example PM archetypes
  templates/
    voice-profile.yaml.tmpl  — Voice profile template
    preferences.yaml.tmpl    — Preferences template
  bin/
    voice-check.sh      — Read PM voice profile (CLI)
```

## Integration

All output-generating skills check for a voice profile before generating content. If a profile exists for the active PM, it is applied. If not, the Rev A Mfg baseline defaults are used.

## Storage

- Profiles: `~/.reva-turbo/users/<pm-slug>/voice-profile.yaml`
- Preferences: `~/.reva-turbo/users/<pm-slug>/preferences.yaml`
- Edit history: `~/.reva-turbo/users/<pm-slug>/edit-history.jsonl`
