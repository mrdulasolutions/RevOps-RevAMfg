# Voice Defaults — Rev A Manufacturing Baseline

This is the default voice profile used when no PM-specific profile exists. It represents the Rev A Manufacturing company voice: professional, direct, relationship-building, and reliable.

## Baseline Profile

```yaml
voice:
  tone: 5                              # Professional and balanced
  formality: 5                         # Moderately formal
  technical_depth: "moderate"          # Include key specs when relevant
  sentence_length: "medium"            # 13-20 words average
  detail_level: "standard"             # Core message plus relevant context
  bullet_vs_prose: "mixed"             # Prose for narrative, bullets for lists
  humor_level: "none"                  # No humor in customer-facing comms
  urgency_language: "direct"           # Clear and direct when urgency needed

email:
  greeting_style: "Hi [First],"       # Professional but warm
  signoff_style: "Best regards,"      # Professional standard
  email_length: "medium"              # 1-2 paragraphs
  customer_tier_adaptation: false     # Same voice for all customers

reports:
  report_detail: "standard"           # 2-3 pages with context
  quote_cover_style: "brief_email"    # Professional email with attachment

partners:
  partner_reference_style: "our manufacturing partner in [City]"

phrases:
  favorites: []                       # No default favorites
  banned:
    - "synergy"
    - "leverage"
    - "circle back"
    - "move the needle"
    - "low-hanging fruit"
    - "touch base"
    - "per my last email"

adaptation:
  internal_vs_external: false
  internal_override:
    tone: 7
    formality: 7
```

## Baseline Voice Characteristics

### Tone: Professional and balanced (5/10)

Rev A's default voice is neither stiff nor casual. It reads as a competent professional who respects the reader's time and values the relationship.

**Do:** "Thanks for sending this over. I have attached the quote for your review -- lead time is approximately 6 weeks from PO receipt."

**Don't:** "We hereby acknowledge receipt of your request for quotation and are pleased to provide the enclosed pricing documentation." (too formal)

**Don't:** "Got your RFQ -- quote's attached. 6 weeks. LMK." (too casual)

### Formality: Moderate (5/10)

Common contractions are fine (don't, we'll, I've). Full sentences preferred but the occasional fragment for emphasis is OK. Standard business vocabulary.

### Technical Depth: Moderate

Include key specs when relevant but do not overload the email. Material callouts, key tolerances, and process references are appropriate. Save full spec breakdowns for attached documents.

### Email Length: Medium (75-200 words)

Enough to be helpful without being overwhelming. The core message plus enough context for the reader to understand and take action.

### Structure: Mixed bullets and prose

Use prose for context, framing, and relationship language. Switch to bullets for:
- Action items
- Spec summaries
- Multiple deliverables or options
- Lists of 3 or more items

### Partner References

Refer to China manufacturing partners as "our manufacturing partner in [City]" (e.g., "our manufacturing partner in Shenzhen"). This acknowledges the relationship while positioning Rev A as the customer's primary point of contact.

**Do:** "Our manufacturing partner in Shenzhen has confirmed the tooling schedule."

**Don't:** "The Chinese factory says tooling is on track." (too casual, potentially offensive)

**Don't:** "Our overseas vendor has confirmed." (too vague)

### Banned Phrases

These phrases are banned from all Rev A communications by default:

| Banned Phrase | Why | Alternative |
|---------------|-----|-------------|
| "synergy" | Corporate jargon | "collaboration" or "alignment" |
| "leverage" (verb) | Overused buzzword | "use" or "take advantage of" |
| "circle back" | Overused, vague | "follow up" or "revisit" |
| "move the needle" | Corporate jargon | "make progress" or "improve" |
| "low-hanging fruit" | Cliche | "quick wins" or "easy improvements" |
| "touch base" | Overused | "check in" or "connect" |
| "per my last email" | Passive-aggressive | "as I mentioned" or "as noted" |

### Quote Presentation

Default approach is a brief professional email with the quote as an attachment. Include:
- Reference to the RFQ or request
- Key highlights (total price, lead time, quantity)
- Any important notes or conditions
- Clear call to action ("Let me know if you have questions or would like to proceed.")

### Reports

Standard detail level: 2-3 pages covering the situation, analysis, and recommendations with enough supporting data to justify conclusions. Not so dense that it requires 30 minutes to read, but thorough enough that the reader does not need to ask follow-up questions.

## When to Use Defaults

The baseline profile is used when:

1. No PM-specific voice profile exists in `~/.pmlord/users/<pm-slug>/`
2. A PM's profile has a missing or null dimension
3. A new PM has not yet completed voice onboarding
4. The active PM cannot be determined

When defaults are applied, the engine should note this so the PM can create a personal profile if desired.
