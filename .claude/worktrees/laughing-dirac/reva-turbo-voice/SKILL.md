---
name: reva-turbo-voice
preamble-tier: 2
version: 1.0.0
description: |
  Per-user voice and personality tuner for REVA-TURBO. Captures each PM's
  unique communication style through sample analysis, structured interview,
  and preference capture. Applies voice profile to ALL engine-generated
  content. Continuously learns from PM edits to improve over time.
compatibility: Claude Code, Claude desktop, Claude CoWork
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - AskUserQuestion
---

## Preamble (run first)

```bash
mkdir -p ~/.reva-turbo/analytics
echo '{"skill":"reva-turbo-voice","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> ~/.reva-turbo/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Purpose

Every PM communicates differently. One PM writes formal emails with "Dear Mr. Smith," while another writes "Hey John,". One PM writes three-paragraph emails; another writes bullet-point one-liners. This skill captures each PM's unique voice and applies it to ALL engine-generated content: emails, quotes, reports, partner communications, escalation notices, internal notes -- everything.

The goal is to make generated content indistinguishable from what the PM would write themselves.

## Reference Files

Before running any mode, load these references:

- `prompts/voice-system.md` — Voice tuning methodology and philosophy
- `prompts/voice-interview.md` — Complete structured interview script (Phase 2)
- `prompts/voice-analysis.md` — Sample email analysis rules (Phase 1)
- `prompts/voice-apply.md` — How to apply a voice profile to output
- `references/voice-dimensions.md` — Full dimension documentation
- `references/voice-defaults.md` — Rev A Mfg baseline voice profile
- `references/voice-examples.md` — Example PM archetypes

## Modes

This skill supports 4 modes: **create**, **edit**, **view**, **learn**.

---

### Mode: `create` — Full 3-Phase Onboarding

Run the complete voice profile creation process for a new PM.

#### Step 0: PM Identification

Determine which PM this profile is for:

> Who is this voice profile for?
>
> A) **Ray Yeh** — Senior Project Manager
> B) **Harley Scott** — Senior Project Manager
> C) **Other** — Enter name

If the user provides a name, use it. Create a slug from the name: lowercase, hyphens for spaces, strip special characters (e.g., "Ray Yeh" -> "ray-yeh").

Confirm the PM name and slug. Then create the user directory:

```bash
mkdir -p ~/.reva-turbo/users/{{PM_SLUG}}
```

#### Step 1: Phase 1 — Sample Analysis

Follow the rules in `prompts/voice-analysis.md`.

> I need to learn how you write. Please paste 2-3 recent emails you have sent to customers or partners.
>
> These can be any type: quotes, status updates, follow-ups, introductions. The more variety, the better I can capture your style.
>
> Paste them one at a time. Type **"done"** when you have shared all your samples.

For each pasted email, analyze:

1. Greeting pattern (e.g., "Hi John," or "Dear Mr. Smith,")
2. Signoff pattern (e.g., "Best regards," or "Thanks,")
3. Average sentence length (count words per sentence)
4. Formality markers: contractions vs full forms, passive vs active voice, "please" frequency
5. Bullet point vs prose preference
6. Technical depth (how much spec detail is included)
7. Humor or personality markers
8. Urgency language patterns
9. Favorite phrases and verbal tics
10. Email length (sentence count, paragraph count)

After analyzing all samples, present a draft voice profile summary:

> Based on your emails, here is what I see:
>
> - **Tone:** [description, scale value]
> - **Greeting:** [pattern detected]
> - **Signoff:** [pattern detected]
> - **Email length:** [short/medium/long]
> - **Style:** [bullets vs prose]
> - **Formality:** [scale value]
> - **Favorite phrases:** [list any detected]
> - **Technical depth:** [level]
>
> Does this look accurate? We will refine it in the next step.

#### Step 2: Phase 2 — Structured Interview

Follow the complete interview script in `prompts/voice-interview.md`.

Walk through all 18 voice dimensions. For each dimension:

1. Show a brief explanation of what the dimension controls
2. Present 2-4 concrete examples at different points on the scale
3. Ask the PM to pick the closest match or describe their own preference
4. If the draft profile from Phase 1 already captured a value, show it as the suggested default

Pre-populate answers from Phase 1 analysis where possible. The PM can accept the suggested value or override it.

Important: Do NOT rush through the interview. Each dimension matters. But also do not belabor dimensions where Phase 1 already gave a clear signal -- offer the detected value as the default and move on unless the PM wants to change it.

#### Step 3: Phase 3 — Preferences

Follow `prompts/voice-interview.md` section on preferences.

> Now let us talk about your workflow preferences -- what bugs you, what takes too long, and how you like things done.

Gather:

1. **Pain points** — What communications take too much time to write? What do you dread writing?
2. **Time sinks** — What repetitive communications could be fully automated?
3. **Defaults** — Preferred report format, default priority level, preferred communication channel
4. **Anti-patterns** — Phrases you NEVER want to see in your communications. Styles you hate. Things other people do in emails that annoy you.
5. **Workflow preferences** — Morning summary? End-of-day report? Notification frequency?

#### Step 4: Profile Writing

Write two files to `~/.reva-turbo/users/{{PM_SLUG}}/`:

1. **voice-profile.yaml** — Use `templates/voice-profile.yaml.tmpl` as the template. Fill in all `{{PLACEHOLDER}}` values from the interview and analysis results.

2. **preferences.yaml** — Use `templates/preferences.yaml.tmpl` as the template. Fill in all `{{PLACEHOLDER}}` values from the preferences interview.

```bash
# Write voice-profile.yaml
cat > ~/.reva-turbo/users/{{PM_SLUG}}/voice-profile.yaml << 'PROFILE'
[filled template content]
PROFILE

# Write preferences.yaml
cat > ~/.reva-turbo/users/{{PM_SLUG}}/preferences.yaml << 'PREFS'
[filled template content]
PREFS
```

#### Step 5: Profile Preview

Generate a sample email using the new voice profile. Use a realistic Rev A Mfg scenario:

> Here is a sample email I would generate for you, using your new voice profile:
>
> ---
> [Sample quote follow-up email written in the PM's captured voice]
> ---
>
> Does this sound like something you would write? If not, tell me what feels off and I will adjust.

If the PM requests changes, update the relevant voice dimensions and rewrite the profile files. Repeat the preview until the PM confirms it sounds right.

#### Step 6: Edit History Setup

Initialize the continuous learning system:

```bash
touch ~/.reva-turbo/users/{{PM_SLUG}}/edit-history.jsonl
echo '{"event":"profile_created","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","version":"1.0.0"}' >> ~/.reva-turbo/users/{{PM_SLUG}}/edit-history.jsonl
```

Confirm completion:

> Your voice profile is live. From now on, all engine-generated communications will use your personal style.
>
> Over time, if you edit content I generate, I will track those changes and suggest profile updates when I see consistent patterns.

---

### Mode: `edit` — Modify Voice Dimensions

Update specific voice dimensions for an existing profile.

#### Step 1: Identify PM

> Which PM's voice profile do you want to edit?

Load the existing profile from `~/.reva-turbo/users/{{PM_SLUG}}/voice-profile.yaml`.

If no profile exists, suggest running `create` mode first.

#### Step 2: Show Current Profile

Display the current voice profile in a readable format. Reference `references/voice-dimensions.md` for dimension descriptions.

> Here is your current voice profile:
>
> | Dimension | Current Value |
> |-----------|--------------|
> | Tone | [value] |
> | Formality | [value] |
> | ... | ... |
>
> Which dimension(s) would you like to change?

#### Step 3: Edit Dimensions

For each dimension the PM wants to change:

1. Show the current value
2. Show the same A/B/C/D options from the interview script
3. Let the PM pick a new value
4. Update the profile file

#### Step 4: Preview

Generate a sample email with the updated profile. Confirm the changes feel right.

#### Step 5: Save

Update `voice-profile.yaml` with new values. Update the `last_updated` timestamp. Log the edit:

```bash
echo '{"event":"profile_edited","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","dimensions_changed":["{{DIMS}}"]}' >> ~/.reva-turbo/users/{{PM_SLUG}}/edit-history.jsonl
```

---

### Mode: `view` — Display Current Profile

Read-only view of a PM's voice profile with examples.

#### Step 1: Identify PM

> Which PM's voice profile do you want to view?

#### Step 2: Load and Display

Read `~/.reva-turbo/users/{{PM_SLUG}}/voice-profile.yaml` and `preferences.yaml`.

Display in a formatted summary:

> ## Voice Profile: {{PM_NAME}}
>
> **Created:** {{date}} | **Last updated:** {{date}}
>
> ### Communication Style
> | Dimension | Value | What This Means |
> |-----------|-------|-----------------|
> | Tone | 6/10 | Leaning casual but still professional |
> | ... | ... | ... |
>
> ### Email Defaults
> - Greeting: "Hi [First],"
> - Signoff: "Thanks,"
> - Length: Medium (1-2 paragraphs)
>
> ### Phrases
> - **Favorites:** "happy to help", "let me know if you have questions"
> - **Banned:** "circle back", "synergy"
>
> ### Preferences
> - Pain points: [list]
> - Time sinks: [list]
> - Anti-patterns: [list]

#### Step 3: Sample

Offer to generate a sample communication:

> Want me to generate a sample email in this voice so you can see it in action?

---

### Mode: `learn` — Review Edit History

Analyze the PM's edit history and suggest profile updates.

#### Step 1: Identify PM

> Which PM's edit history do you want to review?

#### Step 2: Load History

Read `~/.reva-turbo/users/{{PM_SLUG}}/edit-history.jsonl`.

If no edit history exists or fewer than 5 edits recorded, report:

> Not enough edit data yet. I need at least 5 tracked edits to identify patterns.
> Continue using the engine and editing generated content -- I will learn from your changes.

#### Step 3: Pattern Analysis

Look for consistent patterns in the edit history:

1. **Greeting changes** — Does the PM consistently change greetings? (e.g., always changes "Hi" to "Hey")
2. **Length adjustments** — Does the PM consistently shorten or lengthen emails?
3. **Phrase replacements** — Are certain phrases consistently replaced or removed?
4. **Tone shifts** — Is the PM consistently making content more/less formal?
5. **Structural changes** — Does the PM consistently convert prose to bullets or vice versa?

#### Step 4: Suggest Updates

For each pattern detected (5+ consistent edits in the same direction):

> I have noticed a pattern in your edits:
>
> **[Pattern description]**
> - You have made this change [N] times in the last [timeframe]
> - Example: Changed "[original]" to "[edited version]"
>
> Should I update your voice profile to reflect this?
> A) Yes, update it
> B) No, keep current setting
> C) Sometimes -- it depends on context (tell me more)

#### Step 5: Apply Updates

For each accepted suggestion, update `voice-profile.yaml` and log the change:

```bash
echo '{"event":"learn_update","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","pattern":"{{PATTERN}}","accepted":true}' >> ~/.reva-turbo/users/{{PM_SLUG}}/edit-history.jsonl
```

---

## Integration with Other Skills

All output-generating skills should check for a voice profile before generating content:

1. Read `~/.reva-turbo/config.yaml` to find the active PM slug
2. Check `~/.reva-turbo/users/{{PM_SLUG}}/voice-profile.yaml`
3. If profile exists, apply it per `prompts/voice-apply.md`
4. If no profile exists, use defaults from `references/voice-defaults.md`

Skills that must integrate:

- `reva-turbo-customer-comms` — All customer emails
- `reva-turbo-rfq-quote` — Quote cover letters
- `reva-turbo-china-package` — Partner communications
- `reva-turbo-escalate` — Escalation notices
- `reva-turbo-report` — Report tone and detail level
- `reva-turbo-order-track` — Status update emails
- `reva-turbo-handoff` — Handoff communications
- `reva-turbo-ncr` — NCR notifications

## Edit Tracking (for continuous learning)

When any skill generates content and the PM edits it before finalizing:

1. Capture the original generated text and the PM's edited version
2. Diff the two to identify what changed
3. Categorize the change (greeting, tone, length, phrase, structure)
4. Log to `~/.reva-turbo/users/{{PM_SLUG}}/edit-history.jsonl`:

```json
{
  "event": "content_edit",
  "ts": "2026-03-30T14:22:00Z",
  "skill": "reva-turbo-customer-comms",
  "content_type": "quote_submission",
  "changes": [
    {"dimension": "greeting_style", "from": "Hi John,", "to": "Hey John,"},
    {"dimension": "email_length", "direction": "shortened"}
  ]
}
```

## Error Handling

- If `~/.reva-turbo/users/` directory does not exist, create it
- If voice profile is corrupted or unparseable, back it up and offer to recreate
- If PM slug conflicts with an existing profile, confirm before overwriting
- Always validate YAML syntax before writing profile files
