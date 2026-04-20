# Voice Dimensions — Full Reference

This document provides the complete specification for all 18 voice dimensions used in REVA-TURBO voice profiles. Each dimension includes its name, description, type, scale/options, default value, examples at each level, and which output types it affects.

---

## 1. tone

**Description:** The overall emotional temperature of communications. Affects word choice, sentence openings, and the general feel.

**Type:** Integer scale 1-10

**Default:** 5

| Level | Label | Example |
|-------|-------|---------|
| 1-2 | Very formal | "We wish to inform you that your quotation has been completed and is enclosed herewith." |
| 3-4 | Professional | "I am pleased to let you know that your quote is ready. Please find it attached." |
| 5-6 | Balanced | "Your quote is ready -- I have attached it here. Let me know if you have any questions." |
| 7-8 | Warm | "Great news -- your quote is done! Take a look and let me know what you think." |
| 9-10 | Casual | "Quote's done! Check it out and holler if anything looks off." |

**Affects:** All customer emails, partner communications, quote covers, status updates, escalation notices.

**Interactions:** Works in tandem with `formality`. High tone + low formality = casual and direct. Low tone + high formality = reserved and structured.

---

## 2. formality

**Description:** Language register and structural formality. Independent of emotional tone. Controls contractions, vocabulary level, sentence structure, and grammatical strictness.

**Type:** Integer scale 1-10

**Default:** 5

| Level | Label | Markers |
|-------|-------|---------|
| 1-2 | Very formal | Zero contractions. "Pursuant to", "enclosed herewith", "kindly". No sentence fragments. Passive voice common. |
| 3-4 | Formal | Rare contractions. "Regarding", "attached", "please". Complete sentences. Active voice preferred. |
| 5-6 | Professional | Selective contractions (common ones like "don't", "we'll"). Standard business vocabulary. Natural flow. |
| 7-8 | Relaxed | Regular contractions. Sentence fragments for emphasis OK. Conversational transitions. |
| 9-10 | Casual | Heavy contractions. Fragments, dashes, incomplete sentences. Stream-of-thought acceptable. |

**Affects:** All text output.

---

## 3. technical_depth

**Description:** How much technical and specification detail appears in communications. Controls whether part numbers, tolerances, materials, and processes are referenced in the body text.

**Type:** Enum: "minimal" | "moderate" | "deep"

**Default:** "moderate"

| Level | Example (describing a machined part order) |
|-------|---------------------------------------------|
| Minimal | "Your parts are in production and on track for the March 15 ship date." |
| Moderate | "Your aluminum housings (6061-T6, anodized) are in machining now -- on track for March 15 shipment." |
| Deep | "The 6061-T6 housings are in 3-axis CNC machining, holding +/-0.005 on the bore diameter per drawing Rev C. Anodizing (Type II, Class 2, black) scheduled for next week. On track for March 15." |

**Affects:** Customer emails, status updates, NCR notifications, partner communications, reports.

**Override:** NCR notifications and inspection reports always use at least "moderate" depth regardless of profile setting.

---

## 4. sentence_length

**Description:** The average complexity and word count of sentences. Affects readability and perceived pace.

**Type:** Enum: "short" | "medium" | "long"

**Default:** "medium"

| Level | Avg Words/Sentence | Example |
|-------|-------------------|---------|
| Short | 8-12 | "Quote attached. Lead time is 6 weeks. Let me know if you have questions." |
| Medium | 13-20 | "I have attached the quote for your review, and we are looking at about six weeks for lead time." |
| Long | 21+ | "I have attached the completed quotation for the machined aluminum housings, which includes our standard terms and reflects a lead time of approximately six weeks from receipt of your purchase order." |

**Affects:** All text output.

---

## 5. detail_level

**Description:** How much context, background, and explanation is included beyond the core message. Distinct from technical_depth, which is about spec detail. This is about narrative context.

**Type:** Enum: "concise" | "standard" | "thorough"

**Default:** "standard"

| Level | Example (sending a quote) |
|-------|---------------------------|
| Concise | "Quote attached. Please review and let me know." |
| Standard | "Quote attached for the 500-piece order. I included two pricing options -- one standard and one with an alternative material that saves 12%." |
| Thorough | "I have completed the quote for your 500-piece order per RFQ-2024-0847. I included two pricing options: Option A uses the 304 stainless you specified at $14.50/unit, while Option B uses 303 stainless at $12.75/unit. The 303 machines faster which drives the savings. Both meet your tolerance requirements. I would suggest discussing the material choice before we proceed." |

**Affects:** Customer emails, reports, quote covers, status updates.

---

## 6. greeting_style

**Description:** The opening line of emails and external communications.

**Type:** String (freeform, with common patterns)

**Default:** "Hi [First],"

| Pattern | Formality | Use Case |
|---------|-----------|----------|
| "Dear Mr./Ms. [Last]," | Very formal | First contact, government, large enterprise |
| "Good morning/afternoon [First]," | Formal-moderate | Time-aware, slightly traditional |
| "Hi [First]," | Professional | Most common business greeting |
| "Hey [First]," | Casual | Established relationships |
| "[First]," | Direct | Gets right to it, no greeting word |

**Affects:** All emails and external communications.

---

## 7. signoff_style

**Description:** The closing line before the signature on emails and external communications.

**Type:** String (freeform, with common patterns)

**Default:** "Best regards,"

| Pattern | Formality |
|---------|-----------|
| "Respectfully," | Very formal |
| "Sincerely," | Formal |
| "Best regards," | Professional standard |
| "Regards," | Professional, brief |
| "Thank you," | Formal-appreciative |
| "Thanks," | Warm, appreciative |
| "Best," | Modern professional |
| "Cheers," | Casual, friendly |
| "Talk soon," | Casual, relationship-oriented |

**Affects:** All emails and external communications.

---

## 8. favorite_phrases

**Description:** Phrases the PM uses frequently that should be naturally incorporated into generated content.

**Type:** Array of strings

**Default:** [] (empty)

**Usage rules:**
- Incorporate 1-2 per communication where they fit naturally
- Never force them in -- skip if no natural fit
- Never use more than 2 in a single email

**Affects:** All text output.

---

## 9. banned_phrases

**Description:** Phrases that must NEVER appear in generated content. Hard rule, no exceptions.

**Type:** Array of strings

**Default:** ["synergy", "leverage", "circle back", "move the needle"]

**Usage rules:**
- Check every output against the banned list before presenting
- Replace banned phrases with neutral alternatives
- This is the highest-priority voice rule

**Affects:** All text output.

---

## 10. email_length

**Description:** Target word count for standard customer emails.

**Type:** Enum: "short" | "medium" | "long"

**Default:** "medium"

| Level | Word Count | Sentence Count |
|-------|-----------|----------------|
| Short | 30-75 | 3-5 sentences |
| Medium | 75-200 | 6-12 sentences (1-2 paragraphs) |
| Long | 200-400 | 12-25 sentences (3+ paragraphs) |

**Affects:** Customer emails, quote covers, partner communications.

**Note:** Complex topics may exceed the target. The target is a guide, not a hard cap.

---

## 11. report_detail

**Description:** Level of detail in reports and formal documents.

**Type:** Enum: "executive_summary" | "standard" | "comprehensive"

**Default:** "standard"

| Level | Pages | Content |
|-------|-------|---------|
| Executive summary | 1 max | Key metrics, decisions needed, recommendations |
| Standard | 2-3 | Situation, analysis, recommendations, supporting data |
| Comprehensive | 4+ | Full detail, data, analysis, context, appendices |

**Affects:** Reports, formal summaries, project reviews.

---

## 12. quote_cover_style

**Description:** The format and approach for presenting quotes to customers.

**Type:** Enum: "formal_letter" | "brief_email" | "detailed_proposal"

**Default:** "brief_email"

| Level | Description |
|-------|-------------|
| Formal letter | Structured cover letter with reference numbers, terms, formal language |
| Brief email | Quick professional email with quote attached and key highlights |
| Detailed proposal | Full proposal: executive summary, scope, pricing, value proposition, terms |

**Affects:** Quote submission communications (reva-turbo-rfq-quote, reva-turbo-customer-comms).

---

## 13. partner_reference_style

**Description:** How to refer to Rev A's China manufacturing partners in customer-facing communications.

**Type:** String (freeform)

**Default:** "our manufacturing partner in [City]"

| Pattern | Positioning |
|---------|------------|
| "Our manufacturing partner" | Generic, professional |
| "Our manufacturing partner in [City]" | Acknowledges location |
| "The factory" / "our factory" | Direct, implies ownership |
| [Company name] | Transparent |
| "Our team in [Country/City]" | Integration, team unity |
| Avoid mentioning | Use "we" exclusively |

**Affects:** Customer emails, status updates, reports -- any content referencing manufacturing operations.

---

## 14. urgency_language

**Description:** How time pressure and urgency are communicated.

**Type:** Enum: "measured" | "direct" | "strong"

**Default:** "direct"

| Level | Examples |
|-------|---------|
| Measured | "At your earliest convenience" / "We would appreciate a response by [date]" |
| Direct | "We need this by [date]" / "Please prioritize this" |
| Strong | "This requires immediate attention" / "URGENT: action needed today" |

**Affects:** All communications when urgency is required. No effect when urgency is not relevant.

---

## 15. bullet_vs_prose

**Description:** Structural preference for organizing multi-item information.

**Type:** Enum: "bullets" | "prose" | "mixed"

**Default:** "mixed"

| Level | Description |
|-------|-------------|
| Bullets | Almost always use bullets/numbered lists. Intro sentence + list. |
| Prose | Flowing paragraphs. Avoid bullets unless 5+ items. |
| Mixed | Prose for narrative, bullets for action items, specs, and 3+ item lists. |

**Affects:** All text output with multi-item information.

---

## 16. humor_level

**Description:** Whether and how often humor, personality, or light touches appear.

**Type:** Enum: "none" | "occasional" | "frequent"

**Default:** "none"

| Level | Description |
|-------|-------------|
| None | Strictly business. No humor, analogies, or personality touches. |
| Occasional | Light touches when appropriate. Never in formal or sensitive content. |
| Frequent | Regular personality, analogies, humor. Professional but human. |

**Affects:** Customer emails, status updates, internal communications. NEVER applied to NCRs, escalations, or formal quality documents.

---

## 17. customer_tier_adaptation

**Description:** Whether the voice adjusts based on the customer's size, spend, or relationship maturity.

**Type:** Boolean

**Default:** false

**When true:**
- New/large/formal customers: increase formality by 1-2 points, use more formal greeting
- Established/casual relationships: use profile defaults or reduce formality by 1 point
- The PM's profile captures the adaptation rules during the interview

**Affects:** Tone, formality, greeting_style for all customer-facing output.

---

## 18. internal_vs_external

**Description:** Whether the PM uses a different communication style for internal (team) vs external (customer/partner) audiences.

**Type:** Boolean

**Default:** false

**When true:**
- Internal communications use `adaptation.internal_override.tone` and `adaptation.internal_override.formality`
- All other dimensions remain the same unless specifically overridden
- Internal = Rev A team, Donovan, other PMs
- External = customers, partners, vendors

**Affects:** Tone and formality for all internal communications.

---

## Dimension Interaction Matrix

Some dimensions interact in predictable ways. Understanding these interactions helps produce natural-sounding output.

| Combination | Result |
|-------------|--------|
| High tone + high formality | Warm but structured. "I appreciate you sending this over! I will have the quote prepared and returned to you by end of week." |
| High tone + low formality | Casual and breezy. "Got it! Quote coming your way by Friday." |
| Low tone + high formality | Reserved and proper. "Your inquiry has been received. We shall provide a quotation by the close of business Friday." |
| Low tone + low formality | Terse and direct. "Received. Quote by Friday." |
| Short sentences + thorough detail | Many short sentences covering lots of ground. Dense but scannable. |
| Long sentences + concise detail | Few flowing sentences that get to the point. Elegant but brief. |
| Bullets + thorough detail | Comprehensive bullet lists. Lots of information, well-organized. |
| Prose + concise detail | Brief paragraphs. Clean and readable. |
