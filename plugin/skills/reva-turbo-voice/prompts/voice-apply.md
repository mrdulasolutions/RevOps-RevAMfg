# Voice Apply — Applying a Voice Profile to Output

## Purpose

This prompt defines how to apply a PM's voice profile to any engine-generated content. Every skill that produces text output must follow these rules to ensure consistent, personalized communications.

## Loading the Profile

Before generating any output:

1. Determine the active PM. Check `~/.reva-turbo/config.yaml` for the `active_pm` field, or use the PM slug provided by the calling skill.
2. Read `~/.reva-turbo/users/<pm-slug>/voice-profile.yaml`.
3. If the file does not exist or is unreadable, fall back to `references/voice-defaults.md`.
4. Parse all voice dimensions into working variables.

## Application Rules by Dimension

### 1. Greeting Style (`email.greeting_style`)

Apply to the opening line of every email, quote cover, and external communication.

- Use the exact greeting string from the profile
- Replace `[First]` with the recipient's first name
- Replace `[Last]` with the recipient's last name
- If `customer_tier_adaptation` is true and the recipient is a new or formal contact, consider upgrading one formality level (e.g., "Hi" to "Dear Mr./Ms.")

**Do NOT apply to:** Reports, internal documents, partner specs packages.

### 2. Signoff Style (`email.signoff_style`)

Apply to the closing line of every email and external communication.

- Use the exact signoff string from the profile
- Follow with the PM's name (from `pm.name`)

**Do NOT apply to:** Reports, internal documents that do not require a signoff.

### 3. Tone (`voice.tone`)

Apply to word choice and sentence construction throughout.

| Scale | Characteristics |
|-------|----------------|
| 1-3 | No contractions. Formal vocabulary ("regarding", "enclosed", "pursuant"). Third-person where appropriate. |
| 4-5 | Selective contractions. Professional vocabulary ("about", "attached", "following up"). First-person natural. |
| 6-7 | Regular contractions. Conversational vocabulary ("wanted to", "just a heads up", "sounds good"). |
| 8-10 | Heavy contractions. Informal vocabulary ("got it", "cool", "no worries"). Short sentences. |

### 4. Formality (`voice.formality`)

Overlaps with tone but controls structural elements:

| Scale | Characteristics |
|-------|----------------|
| 1-3 | Full sentences only. No fragments. No starting sentences with "And" or "But". Formal transitions ("Furthermore", "Additionally"). |
| 4-5 | Complete sentences with occasional fragments for emphasis. Standard transitions ("Also", "In addition"). |
| 6-7 | Fragments OK. Casual transitions ("Also", "Oh, and"). Starting with conjunctions fine. |
| 8-10 | Fragments, one-word sentences, dashes instead of formal punctuation. Stream-of-consciousness OK. |

### 5. Technical Depth (`voice.technical_depth`)

Controls how much spec detail appears in the body text:

- **Minimal:** Reference parts by name/description only. "Your order is in production." Specs stay in attachments.
- **Moderate:** Include key specs inline. "Your 6061-T6 aluminum housings are in machining." Reference drawing revisions, key tolerances.
- **Deep:** Full spec detail inline. Part numbers, material callouts, tolerance values, process steps, surface finish specs.

**Context override:** Some content types require technical depth regardless of profile setting (e.g., NCR notifications, inspection reports). In those cases, the skill requirement overrides the voice profile.

### 6. Sentence Length (`voice.sentence_length`)

Target average words per sentence:

- **Short:** 8-12 words. Crisp, punchy. Multiple short sentences.
- **Medium:** 13-20 words. Balanced, natural rhythm.
- **Long:** 21+ words. Flowing, detailed, compound sentences.

Mix sentence lengths for readability even when targeting a specific average. Do not make every sentence the exact same length.

### 7. Detail Level (`voice.detail_level`)

Controls context density:

- **Concise:** Core message only. No background, no explanation unless essential.
- **Standard:** Core message plus relevant context. Brief "why" when helpful.
- **Thorough:** Full context, background, rationale, options, and recommendations.

### 8. Email Length (`email.email_length`)

Target word count for standard emails:

- **Short:** 30-75 words (3-5 sentences)
- **Medium:** 75-200 words (1-2 paragraphs)
- **Long:** 200-400 words (3+ paragraphs)

**Adaptive:** Complex topics may require longer emails regardless of profile setting. The target is a guide, not a hard limit.

### 9. Bullet vs Prose (`voice.bullet_vs_prose`)

- **Bullets:** Use bullet points or numbered lists for all multi-item information. Introductory sentence + bullets.
- **Prose:** Write in flowing paragraphs. Avoid bullet points unless listing 5+ items.
- **Mixed:** Use prose for context and narrative. Switch to bullets for action items, specs, and lists of 3+ items.

### 10. Urgency Language (`voice.urgency_language`)

When the content requires urgency:

- **Measured:** "We would appreciate a response by [date]" / "At your earliest convenience" / "When you have a chance"
- **Direct:** "We need this by [date]" / "Please prioritize" / "Time-sensitive"
- **Strong:** "This requires immediate attention" / "URGENT" / "This is blocking progress"

When no urgency is needed, this dimension has no effect.

### 11. Humor Level (`voice.humor_level`)

- **None:** Strictly professional. No humor, analogies, or personality touches.
- **Occasional:** Light touches when the situation permits. Never in escalations, NCRs, or formal documents. OK in routine updates and positive communications.
- **Frequent:** Regular personality. Analogies, light humor, personal touches. Still professional -- never sarcastic or off-color.

### 12. Report Detail (`reports.report_detail`)

Apply to all reports and formal documents:

- **Executive summary:** 1 page max. Key metrics, decisions needed, recommendations. No supporting data in body (appendix OK).
- **Standard:** 2-3 pages. Situation, analysis, recommendations. Supporting data inline.
- **Comprehensive:** 4+ pages. Full detail, supporting data, analysis, context, and appendices.

### 13. Quote Cover Style (`reports.quote_cover_style`)

Apply to quote submission communications:

- **Formal letter:** Structured cover with "Re:" line, reference numbers, terms summary, formal closing.
- **Brief email:** Quick professional email. Quote attached, key highlights (price, lead time), call to action.
- **Detailed proposal:** Full proposal structure with executive summary, scope, pricing highlights, value proposition, and terms.

### 14. Partner Reference Style (`partners.partner_reference_style`)

When the content references manufacturing partners:

- Use the exact phrasing from the profile
- Apply consistently across all communications
- If set to "avoid mentioning," use "we" and "our team" language exclusively

### 15. Customer Tier Adaptation (`email.customer_tier_adaptation`)

If true, adjust tone and formality based on customer relationship data:

- **New customer / large enterprise:** Increase formality by 1-2 points, use more formal greeting
- **Established relationship / small company:** Use profile defaults or decrease formality by 1 point
- **Long-term partner:** Use profile defaults, allow maximum casualness from profile

If false, use the same voice for all customers.

### 16. Internal vs External (`adaptation.internal_vs_external`)

If true, apply different voice settings for internal communications:

- Load `adaptation.internal_override.tone` and `adaptation.internal_override.formality`
- Override the base tone and formality values
- Keep all other dimensions the same unless specifically overridden
- Internal = messages to Rev A team members, Donovan, other PMs
- External = messages to customers, partners, vendors

If false, use the same voice for all audiences.

### 17. Favorite Phrases (`phrases.favorites`)

- Review the list of favorite phrases before generating content
- Naturally incorporate 1-2 favorite phrases per communication where they fit
- Do not force them in. If none fit the context, skip them.
- Never use more than 2 favorites in a single email (sounds artificial)

### 18. Banned Phrases (`phrases.banned`)

- **CRITICAL:** Check every generated output against the banned list
- If a banned phrase appears, replace it with a neutral alternative
- This is a hard rule -- banned phrases must NEVER appear in output
- Run this check as the final step before presenting content to the PM

## Banned Phrase Alternatives

Common banned phrases and their alternatives:

| Banned | Alternative |
|--------|------------|
| "circle back" | "follow up" / "revisit" |
| "synergy" | "collaboration" / "alignment" |
| "leverage" (verb) | "use" / "take advantage of" |
| "move the needle" | "make progress" / "have an impact" |
| "low-hanging fruit" | "quick wins" / "easy improvements" |
| "touch base" | "check in" / "connect" |
| "per my last email" | "as I mentioned" / "as noted" |
| "going forward" | "from here" / "next" |
| "at the end of the day" | "ultimately" / "in the end" |

## Voice Compliance Audit Trail

When generating content with a voice profile applied, include a brief audit note (visible only to the engine, not in output):

```
[VOICE] Profile: ray-yeh v1.0.0 | Tone: 6 | Formality: 5 | Greeting: "Hi [First]," | Banned check: PASS
```

This helps with debugging if content does not match expectations.

## Fallback Behavior

If any voice dimension is missing or null in the profile:

1. Check `references/voice-defaults.md` for the Rev A Mfg default
2. Use the default value
3. Log a warning so the PM can fill in the missing dimension later

If the entire profile is missing:

1. Use `references/voice-defaults.md` in full
2. Note in the output that company defaults were used (the PM may want to create a personal profile)
