# REVA-TURBO Ethos

The design philosophy behind the REVA-TURBO engine. These principles shaped every skill, every template, every decision gate, and every line of this system. They are non-negotiable.

---

## 1. Zero Tribal Knowledge

If it's in someone's head, it's not in the system. If it's not in the system, it doesn't exist when that person is on vacation, quits, or forgets.

REVA-TURBO exists because contract manufacturing runs on institutional knowledge — which PM handles which customer, what the tolerance for a specific partner's quality is, when to escalate, how to calculate a quote for injection molding vs CNC, what the customs threshold is for formal entry. Every one of those decisions is codified in this engine.

**The test:** If a new PM starts tomorrow, can they run the full RFQ-to-delivery lifecycle using only REVA-TURBO and CLIENT.md? If yes, we've succeeded. If no, we have more work to do.

---

## 2. Human-in-the-Loop, Always

REVA-TURBO is a copilot, not an autopilot. Even the Autopilot skill has safety gates.

- No email is sent without PM confirmation
- No quality gate is passed without PM sign-off
- No quote is delivered without PM review
- No escalation is triggered without PM awareness
- No order is accepted or rejected automatically

The engine prepares everything. The PM decides everything. The engine logs everything.

The only exception: business rules with `auto_approve` action type — and even those are logged and auditable, and the PM chose to set them up that way.

---

## 3. Every Decision is Auditable

If someone asks "why did we accept this order?" or "who approved this shipment?" or "when did this quote go out?" — the answer is in the audit trail. Always.

REVA-TURBO logs:
- Every workflow transition (skill start, skill end, stage change)
- Every gate decision (PROCEED, CONDITIONAL, DECLINE, PASS, FAIL)
- Every quality disposition (ACCEPT, REJECT, HOLD)
- Every escalation (trigger, route, resolution)
- Every rule evaluation (triggered, passed, overridden)
- Every communication draft (who, when, what)
- Every handoff (from PM, to PM, portfolio state)

The audit trail is append-only. You cannot edit history. You cannot delete decisions.

---

## 4. Documents, Not Conversations

The output of REVA-TURBO is documents, not chat messages. Quotes are `.docx` files. Reports are `.docx` files. Inspection checklists are `.docx` files. NCRs are `.docx` files.

Why? Because:
- Documents can be attached to emails, shared with customers, filed in CRM
- Documents survive the conversation — chat messages don't
- Documents are the record of truth for manufacturing
- Documents can be printed, signed, and archived
- Customers and partners expect documents, not screenshots of AI conversations

The `{{PLACEHOLDER}}` template system ensures consistency. The DOCX converter ensures professionalism. The naming convention (`REVA-TURBO-{Type}-{YYYY-MM-DD}-{ShortName}.docx`) ensures findability.

---

## 5. The PM's Time is Sacred

Every feature in REVA-TURBO exists to save PM time or prevent PM error. If a feature does neither, it doesn't belong.

- **Quick** exists because typing `/reva-turbo-rfq-intake` and filling 15 fields takes 10 minutes. Typing "quote Acme 500 aluminum brackets" takes 5 seconds.
- **Autopilot** exists because manually invoking the next skill in the lifecycle after every step is tedious when the answer is always "yes, proceed."
- **Pulse** exists because checking 6 different places for alerts (email, CRM, order tracker, quality log, partner updates, customer messages) takes 30 minutes. A morning digest takes 30 seconds.
- **Sync** exists because entering the same data in REVA-TURBO and CRM and email is triple-entry. The system should do that.
- **Rules** exists because making the same decision the same way 50 times is not a decision — it's a policy that should be automated.
- **Handoff** exists because "let me write up everything for the person covering me" shouldn't take half a day.

The Magic Layer isn't magic — it's respect for the PM's time.

---

## 6. Structured, Not Freeform

Every input has a schema. Every output has a template. Every workflow has stages. Every decision has options.

Freeform is the enemy of consistency:
- An RFQ intake that asks "tell me about this RFQ" will get 100 different formats from 100 different PMs
- An RFQ intake that asks "Customer name? Part number? Quantity? Material? Finish? Tolerances?" will get the same structured data every time

REVA-TURBO uses structured prompts (`AskUserQuestion` with lettered options) at every decision point. This isn't limiting — it's liberating. PMs don't have to remember what information to collect. The skill tells them.

---

## 7. Fail Loudly, Never Silently

If something goes wrong, REVA-TURBO tells you. Immediately.

- A quality gate fails? The PM sees FAIL in red with the specific criteria that failed and the recommended action.
- A rule conflicts with another rule? The PM sees both rules and chooses which applies.
- A partner's scorecard drops below C? The PM gets a pulse alert before the next order is placed.
- A delivery is 5 days late? Escalation triggers automatically.
- A margin drops below 25%? The quote is blocked with a clear explanation.

Silent failures are how manufacturing companies lose money, customers, and reputation. REVA-TURBO does not fail silently.

---

## 8. Modular by Design

Every skill is independent. Every skill can run alone. Every skill can run as part of the lifecycle chain.

This means:
- A PM can use just `/reva-turbo-rfq-quote` without the rest of the engine
- A PM can use just `/reva-turbo-inspect` for receiving
- A PM can run the full lifecycle through `/reva-turbo-engine`
- New skills can be added without modifying existing skills
- Skills can be updated independently

The `conductor.json` file defines the wiring between skills. The `reva-turbo-engine` orchestrator reads it. But each skill's `SKILL.md` contains everything needed to run that skill in isolation.

---

## 9. Connectors, Not Lock-In

REVA-TURBO connects to external systems (CRM, email, ERP) through adapter patterns that support multiple backends.

- CRM connector works with Power Apps, Dynamics 365, and HubSpot
- Email connector works with Hostinger, Gmail, and generic inbox
- ERP connector is designed for flexibility as Rev A's tooling evolves

Every connector has a manual fallback. If the MCP tool isn't available, the PM can paste data manually. The workflow doesn't break because an integration is down.

The data belongs to Rev A. The engine is portable. Nothing is locked to a specific vendor.

---

## 10. Built for Manufacturing

REVA-TURBO is not a generic project management tool. It is built specifically for contract manufacturing with China-based supply chains.

It knows:
- The difference between CNC machining and injection molding lead times
- That drawings going to China need metric conversion
- That formal customs entry is required above $2500
- That first article inspection is mandatory on new parts
- That partner scorecards track quality, delivery, cost, and communication
- That repackaging might mean relabeling, kitting, or full repack
- That ocean freight takes 4-6 weeks and air freight takes 5-7 days
- That tooling costs are amortized differently than material costs
- That IP protection requires specific agreements before sharing drawings

Generic tools don't know these things. REVA-TURBO does.

---

## 11. The Engine Learns

Every order that flows through REVA-TURBO makes the system smarter:

- **Intel** analyzes patterns across historical data to predict lead times, identify risk, and surface trends
- **Profit** compares estimated vs actual costs to improve future quotes
- **Partner Scorecard** tracks performance over time to inform routing decisions
- **Rules** captures PM decisions as reusable policies
- **Pulse** detects patterns in alerts to predict problems before they happen

The engine doesn't just process — it accumulates institutional intelligence. The longer Rev A uses REVA-TURBO, the more accurate its predictions, the tighter its estimates, the faster its decisions.

---

## 12. Respect the Craft

Product management in contract manufacturing is skilled, complex, high-stakes work. A single PM juggles dozens of active orders across multiple customers, partners, processes, and timelines. They make hundreds of decisions a day — many of them consequential.

REVA-TURBO respects that craft by:
- Never oversimplifying decisions that require judgment
- Providing data and recommendations, not mandates
- Making the mundane automatic so the PM can focus on the complex
- Documenting decisions so the PM is protected
- Scaling the PM's capacity without diluting their expertise

The best PM with REVA-TURBO should be 3x the PM they were without it — not because the AI is smarter, but because the AI handles the 80% that doesn't require human judgment, freeing the PM to excel at the 20% that does.

---

**These 12 principles are the foundation of REVA-TURBO. Every skill is measured against them. Every feature must serve at least one. If it doesn't, it doesn't ship.**

---

*Built by MrDula Solutions. Powered by Claude. Designed for the PMs who keep manufacturing moving.*
