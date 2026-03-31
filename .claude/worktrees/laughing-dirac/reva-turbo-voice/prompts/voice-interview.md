# Voice Interview Script

This is the complete structured interview for Phase 2 of voice profile creation. Walk through each dimension sequentially. For each dimension, show the explanation, present the options, and ask the PM to choose.

If Phase 1 analysis detected a value for a dimension, present it as the suggested default: "Based on your emails, I would suggest [value]. Does that feel right, or would you prefer something different?"

---

## Dimension 1: Tone (scale 1-10)

**What this controls:** The overall emotional temperature of your communications. This affects word choice, sentence openings, and the general feel of every email and document.

> How would you describe the overall tone of your customer communications?
>
> A) **Formal and reserved** (1-3) — "We appreciate your inquiry and look forward to providing a comprehensive quotation at your earliest convenience."
> B) **Professional and balanced** (4-5) — "Thanks for sending this over. We will have a quote ready for you by end of week."
> C) **Warm and approachable** (6-7) — "Great to hear from you! We will get this quoted up and back to you shortly."
> D) **Casual and direct** (8-10) — "Got it -- quote coming your way by Friday."
>
> Pick A, B, C, or D, or give me a number from 1-10.

Record as `voice.tone` (integer 1-10).

---

## Dimension 2: Formality (scale 1-10)

**What this controls:** Language register, independent of tone. You can be warm but still use formal language, or cool but use casual phrasing. This affects contractions, vocabulary, and sentence structure.

> Tone and formality are related but different. You can be warm AND formal, or cool AND casual. How formal is your writing style?
>
> A) **Very formal** (1-3) — No contractions, complete sentences, traditional structure. "I would like to inform you that..." / "Please do not hesitate to contact us."
> B) **Moderately formal** (4-5) — Occasional contractions, professional vocabulary. "I wanted to let you know that..." / "Feel free to reach out."
> C) **Relaxed professional** (6-7) — Regular contractions, straightforward language. "Just wanted to let you know..." / "Let me know if you have questions."
> D) **Casual** (8-10) — Frequent contractions, conversational. "Quick heads up..." / "Shoot me a note if anything comes up."
>
> Pick A, B, C, or D, or give me a number from 1-10.

Record as `voice.formality` (integer 1-10).

---

## Dimension 3: Technical Depth

**What this controls:** How much technical and specification detail you include in communications. This affects whether you reference part numbers, tolerances, materials, and processes in emails or keep things high-level.

> When writing to customers about their parts, how much technical detail do you typically include?
>
> A) **Minimal** — Keep it high-level. "Your parts are in production and on track." Specs stay in attachments, not email body.
> B) **Moderate** — Include key specs when relevant. "Your aluminum housings (6061-T6, anodized) are in machining now -- expecting completion by March 15."
> C) **Deep** — Full spec detail in the email. "The 6061-T6 housings are currently in 3-axis CNC machining. We are holding +/-0.005 on the bore diameter per your drawing Rev C. Anodizing (Type II, Class 2, black) will follow next week."
>
> Pick A, B, or C.

Record as `voice.technical_depth` (string: "minimal" | "moderate" | "deep").

---

## Dimension 4: Sentence Length

**What this controls:** The average complexity and length of your sentences. This has a big impact on readability and perceived pace.

> How do your sentences tend to run?
>
> A) **Short and punchy** — "Quote attached. Lead time is 6 weeks. Let me know if you have questions." (Under 12 words per sentence on average)
> B) **Medium and balanced** — "I have attached the quote for your review, and we are looking at approximately six weeks for lead time." (12-20 words per sentence)
> C) **Long and detailed** — "I have attached the completed quotation for the machined aluminum housings you requested, which includes our standard terms and reflects a lead time of approximately six weeks from receipt of your purchase order." (20+ words per sentence)
>
> Pick A, B, or C.

Record as `voice.sentence_length` (string: "short" | "medium" | "long").

---

## Dimension 5: Detail Level

**What this controls:** How much context and background you include in communications. Separate from technical depth -- this is about how much you explain the "why" and "what" beyond the core message.

> How much context do you typically provide in your emails?
>
> A) **Concise** — Just the essential information. "Quote attached. Please review and let me know."
> B) **Standard** — Core message plus relevant context. "Quote attached for the 500-piece order. I included two options: one with your specified material and one with an alternative that could reduce cost by 12%. Happy to discuss either approach."
> C) **Thorough** — Full context, background, and explanation. "I have completed the quote for your 500-piece order per RFQ-2024-0847. I included two pricing options: Option A uses the 304 stainless you specified at $14.50/unit, while Option B uses 303 stainless at $12.75/unit -- the 303 machines faster which drives the cost reduction. Both options include the black oxide finish and meet your +/-0.003 tolerance requirements. I would recommend discussing the material options before we proceed, as the 303 may work for your application."
>
> Pick A, B, or C.

Record as `voice.detail_level` (string: "concise" | "standard" | "thorough").

---

## Dimension 6: Greeting Style

**What this controls:** The opening line of every email and communication generated on your behalf.

> How do you typically open emails to customers?
>
> A) **"Dear Mr./Ms. [Last],"** — Formal, traditional. Used for first contact or formal customers.
> B) **"Hi [First],"** — Professional but warm. The most common professional greeting.
> C) **"Hey [First],"** — Casual, friendly. For established relationships.
> D) **"[First],"** — Direct, no greeting word. Gets right to it.
> E) **"Good morning/afternoon [First],"** — Time-aware, slightly formal.
> F) **Something else** — Tell me your preferred greeting.
>
> Do you vary this by customer relationship? (New customer vs long-term?)

Record as `email.greeting_style` (string). Also note if the PM wants variation by customer tier.

---

## Dimension 7: Signoff Style

**What this controls:** The closing line before your signature on every email.

> How do you typically sign off on emails?
>
> A) **"Best regards,"** — Professional standard.
> B) **"Regards,"** — Slightly more formal, shorter.
> C) **"Thanks,"** — Warm, appreciative.
> D) **"Thank you,"** — More formal version of Thanks.
> E) **"Best,"** — Brief, modern professional.
> F) **"Cheers,"** — Casual, friendly.
> G) **"Talk soon,"** — Casual, relationship-oriented.
> H) **Something else** — Tell me your preferred signoff.

Record as `email.signoff_style` (string).

---

## Dimension 8: Email Length

**What this controls:** The target length for standard customer emails. Does not apply to reports or formal documents.

> How long are your typical customer emails?
>
> A) **Short** (3-5 sentences) — Get in, deliver the message, get out. "Hi John, Quote attached for your review. Lead time is 6 weeks ARO. Let me know if you have any questions. Thanks, [Name]"
> B) **Medium** (1-2 paragraphs) — Enough context to be helpful without being overwhelming. The message plus a brief explanation or next steps.
> C) **Long** (3+ paragraphs) — Full detail, context, options, and explanation. You believe in giving the customer everything they need in one email.
>
> Pick A, B, or C.

Record as `email.email_length` (string: "short" | "medium" | "long").

---

## Dimension 9: Bullet vs Prose

**What this controls:** Whether you structure information as bullet points, flowing prose, or a mix. This significantly affects readability and email feel.

> When you need to communicate multiple pieces of information, how do you structure it?
>
> A) **Bullets** — Almost always use bullet points or numbered lists. Clean, scannable, organized.
> B) **Prose** — Write in flowing paragraphs. More personal, narrative feel.
> C) **Mixed** — Prose for context and framing, bullets for action items and specs. Best of both.
>
> Pick A, B, or C.

Record as `voice.bullet_vs_prose` (string: "bullets" | "prose" | "mixed").

---

## Dimension 10: Urgency Language

**What this controls:** How you communicate time pressure and urgency in your emails. This ranges from polite and measured to direct and forceful.

> When something needs urgent attention, how do you convey that?
>
> A) **Measured** — "At your earliest convenience" / "When you have a moment" / "We would appreciate a response by [date]"
> B) **Direct** — "We need this by Friday" / "Please prioritize this" / "Time-sensitive -- please review today"
> C) **Strong** — "This needs immediate attention" / "URGENT" / "We cannot proceed until this is resolved"
>
> Pick A, B, or C.

Record as `voice.urgency_language` (string: "measured" | "direct" | "strong").

---

## Dimension 11: Humor Level

**What this controls:** Whether and how often humor, personality, or light touches appear in your communications.

> Do you use humor or light personality touches in professional emails?
>
> A) **None** — Strictly business. Professional at all times. Humor could be misread.
> B) **Occasional** — A light touch when appropriate. "I promise the quote is worth the wait" or "If only all our customers were this organized." Never in formal or sensitive situations.
> C) **Frequent** — You believe personality builds relationships. Regular use of humor, analogies, and personal touches. You want emails to feel human, not corporate.
>
> Pick A, B, or C.

Record as `voice.humor_level` (string: "none" | "occasional" | "frequent").

---

## Dimension 12: Report Detail Level

**What this controls:** How much detail goes into reports, summaries, and formal documents (separate from email length).

> When you deliver a report or formal summary, how detailed should it be?
>
> A) **Executive summary** — Key metrics, decisions needed, and recommendations. One page max. Decision-makers do not have time to read more.
> B) **Standard** — Core information with enough context to understand the situation. 2-3 pages. Covers what happened, why, and next steps.
> C) **Comprehensive** — Full detail, supporting data, analysis, and appendices. 4+ pages. Thorough enough that someone unfamiliar with the project could understand it completely.
>
> Pick A, B, or C.

Record as `reports.report_detail` (string: "executive_summary" | "standard" | "comprehensive").

---

## Dimension 13: Quote Cover Style

**What this controls:** How you present quotes to customers -- the format and formality of the cover communication that accompanies a pricing document.

> When you send a quote to a customer, how do you present it?
>
> A) **Formal letter** — Structured cover letter with reference numbers, terms summary, and formal language. Suitable for large customers and government contracts.
> B) **Brief email** — Quick professional email with quote attached. "Hi John, Quote attached for your review. Lead time is 6 weeks. Let me know if you have questions."
> C) **Detailed proposal** — Full proposal-style cover: executive summary, scope, pricing highlights, value proposition, and terms. Used when competing against other vendors.
>
> Pick A, B, or C.

Record as `reports.quote_cover_style` (string: "formal_letter" | "brief_email" | "detailed_proposal").

---

## Dimension 14: Partner Reference Style

**What this controls:** How you refer to Rev A's China manufacturing partners in customer-facing communications. This is important for brand positioning.

> When you mention our manufacturing partners to customers, how do you refer to them?
>
> A) **"Our manufacturing partner"** — Generic, professional. Does not specify location.
> B) **"Our manufacturing partner in [City]"** — Acknowledges the location (e.g., "our manufacturing partner in Shenzhen").
> C) **"The factory" / "our factory"** — Direct, implies ownership or close relationship.
> D) **By company name** — Use the actual partner company name when relevant.
> E) **"Our team in [Country/City]"** — Implies integration, team unity. "Our team in China" or "our Shenzhen team."
> F) **Avoid mentioning** — You prefer not to reference manufacturing partners at all. Just "we" and "us."
>
> Pick A-F.

Record as `partners.partner_reference_style` (string).

---

## Dimension 15: Customer Tier Adaptation

**What this controls:** Whether you adjust your communication style based on the customer's size, spend, or relationship stage. Some PMs write the same way to everyone; others calibrate.

> Do you change your communication style based on the customer?
>
> A) **No** — I write the same way to everyone. Consistency is key.
> B) **Yes** — I am more formal with large/new customers and more casual with established/smaller ones. My style adapts to the relationship.
>
> If B, describe how your style changes.

Record as `email.customer_tier_adaptation` (boolean). If true, capture notes on how style varies.

---

## Dimension 16: Internal vs External Voice

**What this controls:** Whether you communicate differently with internal team members (colleagues, leadership) vs external contacts (customers, partners).

> Do you write differently when communicating internally (to your team or leadership) vs externally (to customers or partners)?
>
> A) **No** — My style is consistent regardless of audience.
> B) **Yes** — I am more casual/direct internally and more polished externally.
>
> If B:
> - How casual are you internally? (scale 1-10)
> - How formal are you externally? (already captured above)

Record as `adaptation.internal_vs_external` (boolean). If true, capture `adaptation.internal_override.tone` and `adaptation.internal_override.formality`.

---

## Dimension 17: Favorite Phrases

**What this controls:** Specific phrases, expressions, or sentence patterns you use regularly. The engine will naturally incorporate these into generated content to make it sound more like you.

> Are there phrases or expressions you use frequently in your emails? Things people might associate with your writing style?
>
> Examples:
> - "Happy to help"
> - "Let me know if you have any questions"
> - "Looking forward to working together"
> - "Just to confirm"
> - "Quick update"
> - "Wanted to circle back" (some people love this; others hate it)
>
> List as many as come to mind. These will be woven into generated content.

Record as `phrases.favorites` (array of strings).

---

## Dimension 18: Banned Phrases

**What this controls:** Phrases the engine must NEVER use in your communications. These are words or expressions you actively dislike or find unprofessional.

> Are there phrases or expressions you never want to see in your emails? Things that make you cringe or feel "off"?
>
> Common banned phrases:
> - "Circle back"
> - "Synergy" / "synergize"
> - "Leverage" (used as a verb)
> - "Move the needle"
> - "Low-hanging fruit"
> - "Touch base"
> - "Per my last email"
> - "Going forward"
> - "At the end of the day"
> - "It is what it is"
>
> List any phrases you want permanently banned from your communications.

Record as `phrases.banned` (array of strings).

---

## Preferences Section

After completing all 18 dimensions, transition to preferences:

> Great -- I have a solid picture of your communication style. Now let us talk about your workflow preferences.

### Pain Points

> What types of communications take you the most time to write? What do you dread writing?
>
> Examples:
> - "Quote follow-up emails when the customer has not responded"
> - "Explaining delays to customers"
> - "Writing detailed status reports"
> - "First-contact emails to new customers"
> - "NCR notifications"

Record as `pain_points` (array of strings).

### Time Sinks

> What communications feel repetitive -- things you write over and over with small variations?
>
> Examples:
> - "RFQ acknowledgment emails"
> - "Weekly status updates"
> - "Quote cover letters"
> - "Shipment notifications"

Record as `time_sinks` (array of strings).

### Defaults

> A few quick defaults:
>
> 1. **Preferred report format:** PDF, DOCX, or either?
> 2. **Auto-attach specs to communications?** Yes or no?
> 3. **Default priority for new tasks:** Low, Medium, or High?
> 4. **Preferred communication channel:** Email, Teams, Slack, or other?

Record as `defaults.*` fields.

### Anti-Patterns

> Finally, are there any communication styles or patterns that really annoy you? Things other people do in emails that you never want the engine to replicate?
>
> Examples:
> - "Overly apologetic language"
> - "Too many exclamation points"
> - "Using 'just' as a softener (just wanted to check in...)"
> - "Walls of text with no structure"
> - "Corporate jargon"
> - "Passive-aggressive tone"

Record as `anti_patterns` (array of strings).

### Workflow Preferences

> Two more questions:
>
> 1. **Morning summary?** Do you want a daily morning briefing of what needs attention? Yes/No
> 2. **End-of-day report?** Do you want a summary of what was accomplished each day? Yes/No
> 3. **Notification frequency:** Real-time (as things happen), Batched (a few times a day), or Daily (one digest)?

Record as `workflow_preferences.*` fields.

---

## Wrap-Up

After all dimensions and preferences are captured:

> I have everything I need. Let me build your voice profile and show you a sample email to make sure it sounds right.

Proceed to Phase 4 (Profile Writing) and Phase 5 (Profile Preview) as defined in SKILL.md.
