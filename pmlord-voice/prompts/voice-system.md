# Voice System — Tuning Methodology

## Philosophy

Voice is not just tone. It is the complete communication fingerprint of a human being. Two people can both be "professional" yet write in completely different ways. Voice encompasses:

- **Word choice** — "utilize" vs "use", "regarding" vs "about", "kindly" vs "please"
- **Sentence structure** — Short, punchy sentences vs complex, flowing ones
- **Paragraph density** — One idea per paragraph vs multi-layered paragraphs
- **Greeting and signoff rituals** — These are deeply personal and habitual
- **Formality calibration** — How formal vs casual, and whether this varies by audience
- **Technical precision** — How much spec detail to include vs abstracting for the reader
- **Rhythm and pacing** — How the email flows from opening to close
- **Personality markers** — Humor, empathy, directness, warmth, assertiveness

## Core Principles

### 1. Voice profiles are per-PM, not per-company

The company (Rev A Manufacturing) has a baseline voice defined in `references/voice-defaults.md`. But each PM's profile overrides the baseline. The PM's individual style takes priority because customers build relationships with people, not companies.

### 2. Every dimension has concrete examples

Abstract descriptions like "friendly tone" are useless. Every voice dimension must be illustrated with concrete examples at each point on its scale. The PM chooses between real examples, not abstract labels.

### 3. The test is indistinguishability

A voice profile is good when someone who knows the PM cannot tell whether the PM wrote the email or the engine generated it. This is the bar. If generated content sounds generic, the profile needs refinement.

### 4. Continuous learning is passive

The engine tracks edits to generated content but never interrupts workflow to ask about voice. Edit tracking happens silently. Profile update suggestions only appear when the PM explicitly runs the `learn` mode or during periodic check-ins.

### 5. Context matters

A PM may write differently to:
- A major OEM customer vs a small startup
- A new customer vs a long-standing relationship
- An internal team member vs an external contact
- A routine update vs an escalation

The voice profile captures these contextual variations through dimensions like `customer_tier_adaptation` and `internal_vs_external`.

## Where Voice Applies

Voice profiles are applied to ALL engine-generated content:

| Content Type | Skill | Voice Dimensions Applied |
|--------------|-------|--------------------------|
| Customer emails | pmlord-customer-comms | greeting, signoff, tone, formality, email_length, bullet_vs_prose, urgency_language |
| Quote cover letters | pmlord-rfq-quote | greeting, signoff, tone, formality, quote_cover_style, detail_level |
| Partner communications | pmlord-china-package | tone, formality, technical_depth, partner_reference_style |
| Status updates | pmlord-order-track | tone, detail_level, urgency_language, email_length |
| Reports | pmlord-report | report_detail, technical_depth, detail_level |
| Escalation notices | pmlord-escalate | urgency_language, formality, tone |
| NCR notifications | pmlord-ncr | tone, formality, technical_depth, urgency_language |
| Handoff documents | pmlord-handoff | detail_level, technical_depth |
| Internal notes | any | internal_vs_external overrides (if enabled) |

## Analysis Methodology

When analyzing sample emails (Phase 1), use quantitative and qualitative measures:

### Quantitative
- **Words per sentence** — Count total words / total sentences. Short: <12, Medium: 12-20, Long: >20
- **Sentences per paragraph** — Count total sentences / total paragraphs
- **Contraction ratio** — Count contractions / (contractions + full forms). High = casual, Low = formal
- **Passive voice ratio** — Count passive constructions / total sentences
- **Bullet point ratio** — Emails containing bullets / total emails
- **Email word count** — Total words per email. Short: <75, Medium: 75-200, Long: >200

### Qualitative
- **Greeting pattern** — Exact greeting used, consistency across samples
- **Signoff pattern** — Exact signoff used, consistency across samples
- **Personality markers** — Humor, personal touches, empathy statements
- **Urgency expression** — How the PM communicates time pressure
- **Technical depth** — How much spec detail appears vs being abstracted
- **Favorite phrases** — Repeated phrases, verbal tics, go-to expressions

## Profile Versioning

Voice profiles include a version marker. When the profile is updated (via `edit` or `learn` mode), the version increments and the change is logged. This allows rollback if a profile update does not feel right.

## Conflict Resolution

If a dimension conflicts with a skill-specific requirement:
1. Skill requirements override voice profile (e.g., an NCR must include technical detail regardless of the PM's `technical_depth` setting)
2. Voice profile overrides company defaults
3. Company defaults override generic engine behavior

Priority chain: **Skill requirement > PM voice profile > Company default > Engine generic**
