# Voice Analysis — Sample Email Rules

## Purpose

This prompt defines how to analyze sample emails pasted by a PM during Phase 1 of voice profile creation. The goal is to extract a draft voice profile from real writing samples before the structured interview refines it.

## Input Requirements

- Minimum 2 sample emails, ideally 3-5
- Samples should include variety: different recipients, different situations, different urgency levels
- Both customer-facing and internal samples are valuable (if available)
- Samples must be emails the PM actually wrote (not forwarded or template-based)

## Analysis Process

### Step 1: Segment Each Email

Break each email into structural components:

1. **Greeting line** — The opening (e.g., "Hi John,")
2. **Opening sentence** — The first substantive sentence after the greeting
3. **Body** — The main content
4. **Closing line** — The sentence before the signoff
5. **Signoff** — The closing (e.g., "Best regards,")

### Step 2: Quantitative Analysis

Calculate these metrics across all samples:

#### Sentence Metrics
- **Average sentence length** — Total words / total sentences
  - Short: < 12 words
  - Medium: 12-20 words
  - Long: > 20 words
- **Sentence length variance** — Standard deviation of sentence lengths. High variance = dynamic writing. Low variance = consistent rhythm.

#### Paragraph Metrics
- **Average sentences per paragraph** — Total sentences / total paragraphs
- **Average paragraphs per email** — Count of paragraphs per email

#### Email Length
- **Average word count per email**
  - Short: < 75 words
  - Medium: 75-200 words
  - Long: > 200 words

#### Formality Markers
- **Contraction ratio** — Count all contractions (don't, we'll, I'm, etc.) and their full-form equivalents (do not, we will, I am). Calculate: contractions / (contractions + full forms)
  - High ratio (> 0.7) = casual
  - Medium ratio (0.3-0.7) = moderate
  - Low ratio (< 0.3) = formal
- **Passive voice ratio** — Count passive constructions ("was completed", "has been shipped") / total sentences
  - High (> 0.3) = formal
  - Low (< 0.1) = direct, active style
- **"Please" frequency** — Count instances of "please" / total sentences
  - High = polite/formal
  - Low = direct/casual

#### Structure Markers
- **Bullet point ratio** — Emails containing bullet points or numbered lists / total emails
  - > 0.5 = bullet preference
  - < 0.2 = prose preference
  - Between = mixed

### Step 3: Qualitative Analysis

#### Greeting Pattern
- Extract the exact greeting from each email
- Identify the pattern: Does the PM use the same greeting every time?
- Note any variation by recipient type
- Record the most common greeting

#### Signoff Pattern
- Extract the exact signoff from each email
- Identify the pattern: consistent or variable?
- Record the most common signoff

#### Tone Assessment
- Read each email holistically and rate on the 1-10 tone scale
- Look for warmth markers: personal questions, exclamation points, emoji (rare in business but possible), humor
- Look for distance markers: third-person references, passive voice, formal titles
- Average the tone ratings across samples

#### Technical Depth
- Count technical terms, part numbers, specs, tolerances, and process references
- Classify as:
  - **Minimal:** Rarely includes technical detail in emails
  - **Moderate:** Includes key specs when relevant
  - **Deep:** Regularly includes full spec detail

#### Urgency Language
- Search for urgency markers:
  - Measured: "at your convenience", "when you have a moment", "no rush"
  - Direct: "by Friday", "please prioritize", "time-sensitive"
  - Strong: "ASAP", "urgent", "immediately", "critical"
- Note the dominant pattern

#### Favorite Phrases
- Identify phrases that appear in 2+ emails
- Look for verbal tics: sentence starters ("Just wanted to...", "Quick update..."), transitions ("That said...", "On another note..."), closers ("Let me know if...", "Happy to discuss...")
- Record all detected recurring phrases

#### Humor and Personality
- Note any humor, analogies, personal references, or non-business content
- Classify as none / occasional / frequent

#### Internal vs External
- If samples include both internal and external emails, compare:
  - Tone difference
  - Formality difference
  - Length difference
  - Detail level difference

### Step 4: Draft Profile Assembly

Combine quantitative and qualitative findings into a draft profile:

```
Draft Voice Profile for [PM Name]
Based on analysis of [N] email samples

  tone: [1-10, with explanation]
  formality: [1-10, with explanation]
  technical_depth: [minimal/moderate/deep]
  sentence_length: [short/medium/long] (avg: X words)
  detail_level: [concise/standard/thorough]
  greeting_style: "[detected pattern]"
  signoff_style: "[detected pattern]"
  email_length: [short/medium/long] (avg: X words)
  bullet_vs_prose: [bullets/prose/mixed]
  urgency_language: [measured/direct/strong]
  humor_level: [none/occasional/frequent]
  favorite_phrases: [list]
```

### Step 5: Present to PM

Present the draft profile to the PM in a readable format. Explain why each value was chosen by referencing specific examples from their emails. Ask for confirmation or correction.

Markers to highlight:
- "I noticed you use '[phrase]' frequently -- I will incorporate that."
- "Your emails average [N] words, so I have you at [short/medium/long]."
- "You used contractions [frequently/rarely], suggesting a [casual/formal] style."
- "Your greeting is consistently '[greeting]' across all samples."

## Confidence Levels

For each dimension, assess confidence based on sample consistency:

- **High confidence** — All samples agree, clear pattern
- **Medium confidence** — Most samples agree, some variation
- **Low confidence** — Samples conflict, need interview to clarify

Flag low-confidence dimensions for extra attention during the Phase 2 interview.

## Edge Cases

- **Template-heavy emails:** If the PM's samples appear to be based on templates, note this and weight the non-template portions more heavily.
- **Very short samples:** If samples are extremely brief (< 30 words), note that email_length may be underestimated if the topics were simple.
- **Forwarded content:** If the PM included forwarded or quoted content, strip it before analysis.
- **Mixed audiences:** If some samples are to customers and others to partners or internal team, analyze separately and note the differences.
