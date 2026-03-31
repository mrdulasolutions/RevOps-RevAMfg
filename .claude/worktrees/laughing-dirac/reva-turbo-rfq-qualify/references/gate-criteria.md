# Gate Criteria — Decision Table

## Decision Matrix

| Gate 1 (Customer) | Gate 2 (Capability) | Gate 3 (Complexity) | Gate 4 (Capacity) | Gate 5 (Credit) | Decision |
|-------------------|--------------------|--------------------|-------------------|-----------------|----------|
| PASS | FULL MATCH | 1-3 | Available | Clear | **PROCEED** |
| PASS | FULL MATCH | 4-5 | Available | Clear | **PROCEED** (assign senior PM) |
| PASS | PARTIAL MATCH | 1-3 | Available | Clear | **CONDITIONAL** (evaluate gaps) |
| PASS | PARTIAL MATCH | 4-5 | Available | Clear | **CONDITIONAL** (senior PM + gap evaluation) |
| PASS | Any | Any | Tight | Clear | **CONDITIONAL** (negotiate timeline) |
| PASS | Any | Any | Unavailable | Clear | **CONDITIONAL** (timeline adjustment required) |
| PASS | Any | Any | Any | Pending | **CONDITIONAL** (credit check required) |
| PASS | NO MATCH | Any | Any | Any | **DECLINE** (capability gap) |
| FLAG | Any | Any | Any | Risk | **CONDITIONAL** (escalate to senior PM) |
| NEW | FULL MATCH | 1-3 | Available | Pending | **CONDITIONAL** (onboarding required) |
| NEW | FULL MATCH | 4-5 | Available | Pending | **CONDITIONAL** (onboarding + senior PM) |
| NEW | PARTIAL/NO MATCH | Any | Any | Any | **DECLINE** (too much risk for new customer) |
| Any | Any | Any | Any | Risk (delinquent) | **DECLINE** (credit block) |
| Any | Any | Any | Any | Any + Export Flag | **CONDITIONAL** (export review required) |

## Override Rules

- PM can override any CONDITIONAL to PROCEED with documented rationale
- PM can override DECLINE to CONDITIONAL with Donovan Weber approval
- DECLINE due to export control cannot be overridden without legal review
- DECLINE due to delinquent credit requires Donovan Weber approval to override

## Complexity Scoring Criteria

### Score 1: Simple
- Single manufacturing process
- Common material (6061 Al, 304 SS, ABS, etc.)
- Standard tolerances (+/- 0.005" or looser)
- No special finish requirements
- No certification requirements
- Quantity: any

### Score 2: Low
- Single process with minor customization
- Standard material with specific grade requirements
- Moderate tolerances (+/- 0.002" to 0.005")
- Standard finish (clear anodize, zinc plate)
- Basic quality docs (CoC)

### Score 3: Medium
- Two or more manufacturing processes
- Less common material or specific alloy requirements
- Tighter tolerances (+/- 0.001" to 0.002")
- Specialty finish (hard anodize, nickel plate, specific color match)
- Quality documentation required (FAIR, material certs)
- Assembly of 2-5 components

### Score 4: High
- Three or more manufacturing processes
- Specialty or exotic material (titanium, Inconel, PEEK)
- Tight tolerances (+/- 0.0005" to 0.001")
- Multiple finish requirements
- Certification requirements (AS9100, ISO 13485)
- Assembly of 5+ components
- Custom tooling required

### Score 5: Critical
- Complex multi-stage manufacturing
- Exotic materials with limited sourcing
- Ultra-precision tolerances (< +/- 0.0005")
- ITAR or EAR controlled
- PPAP or full qualification required
- Functional testing required
- Multi-material assembly with tight interfaces

## Red Flag Indicators

Automatic escalation triggers regardless of gate results:

- Order value > $100,000 from a new customer
- ITAR/EAR flagged content
- Customer requesting NDA before sharing specs (flag but do not block)
- Competitor company name detected
- Request for Rev A proprietary process information
- Customer insisting on unreasonable payment terms (Net 90+, consignment)
- Request for manufacturing in non-China locations (outside Rev A model)
