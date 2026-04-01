# Root Cause Analysis Methods

## Method Selection

| NCR Severity | Recommended Method | Depth |
|-------------|-------------------|-------|
| Minor | 5-Why | Quick analysis, single cause chain |
| Major | 5-Why + Fishbone | Broader analysis, multiple cause categories |
| Critical | 8D Report | Comprehensive team-based problem solving |

---

## 1. Five-Why (5-Why) Analysis

### Purpose

Drill down from the observed problem to the root cause by asking "Why?" repeatedly until you reach an actionable root cause.

### How to Conduct

Start with the problem statement, then ask "Why?" at each level:

```
Problem: Bore diameter is 25.05 mm, specification is 25.00 +/- 0.02 mm.

Why 1: Why is the bore oversized?
  -> The boring tool removed too much material.

Why 2: Why did the boring tool remove too much material?
  -> The tool offset was set incorrectly.

Why 3: Why was the tool offset set incorrectly?
  -> The operator used the wrong offset value from the setup sheet.

Why 4: Why did the setup sheet have the wrong offset value?
  -> The setup sheet was not updated after the last tool change.

Why 5: Why was the setup sheet not updated?
  -> There is no procedure requiring setup sheet updates after tool changes.

ROOT CAUSE: No procedure for setup sheet updates after tool changes.
CORRECTIVE ACTION: Create mandatory setup sheet verification procedure.
```

### Rules

1. Each "Why" must be factual, not speculative.
2. Stop when you reach a cause that is within someone's control to fix.
3. If you reach a "human error" answer, ask why the error was possible (systemic cause).
4. Document evidence at each level when available.
5. The root cause should point to a process, procedure, or system gap — not blame an individual.

---

## 2. Fishbone (Ishikawa) Diagram

### Purpose

Identify all potential causes of a problem across six categories. Useful when the root cause is not immediately obvious or multiple factors may contribute.

### Six Categories (6M)

#### Man (People)

- Operator training adequate?
- Correct skill level assigned?
- Fatigue or workload issues?
- New operator or substitute?
- Instructions understood?

#### Machine (Equipment)

- Equipment calibrated?
- Tooling worn or damaged?
- Machine capability adequate?
- Preventive maintenance current?
- Correct machine for the job?

#### Material (Inputs)

- Raw material meets spec?
- Material from approved supplier?
- Material stored correctly?
- Batch/lot variation?
- Material certification valid?

#### Method (Process)

- Work instructions followed?
- Process validated?
- Correct sequence of operations?
- Process parameters in control?
- Adequate process capability (Cpk)?

#### Measurement (Inspection)

- Gauges calibrated?
- Correct measurement method?
- Measurement uncertainty acceptable?
- Inspection frequency adequate?
- Operator measurement technique consistent?

#### Environment (Milieu)

- Temperature/humidity controlled?
- Workspace clean and organized?
- Adequate lighting?
- Vibration or interference?
- Contamination sources present?

### How to Document

For each category, list potential causes and mark with evidence level:

- **Confirmed** — Evidence supports this as a contributing factor
- **Probable** — Likely based on available information
- **Possible** — Could contribute but no evidence yet
- **Eliminated** — Investigated and ruled out

---

## 3. 8D Report (Eight Disciplines)

### Purpose

A structured, team-based problem-solving methodology for critical non-conformances. Provides comprehensive documentation from discovery through verification.

### Eight Disciplines

#### D1 — Team Formation

- Identify team members with relevant expertise.
- Assign a team leader.
- Define roles and responsibilities.

| Role | Name | Responsibility |
|------|------|---------------|
| Team Leader | | Overall 8D coordination |
| Quality | | Inspection data, standards |
| Engineering | | Design/spec review |
| Manufacturing | | Process knowledge |
| PM | | Customer/partner coordination |

#### D2 — Problem Description

Use IS / IS NOT analysis:

| | IS | IS NOT |
|---|---|---|
| **What** | What defect was found? | What is NOT wrong? |
| **Where** | Where on the part? Which operation? | Where was the defect NOT found? |
| **When** | When discovered? When produced? | When was the problem NOT present? |
| **How Much** | How many affected? What magnitude? | What quantity is OK? |

#### D3 — Containment Actions

- Immediate actions to protect the customer.
- Same as NCR Step 3 containment.
- Verify containment effectiveness.

#### D4 — Root Cause Analysis

- Use 5-Why and Fishbone together.
- Verify root cause with data/evidence.
- Distinguish between occurrence cause (why it happened) and escape cause (why it was not detected).

#### D5 — Corrective Actions

- Define permanent corrective actions for both occurrence and escape causes.
- Verify actions will eliminate root cause (not just treat symptoms).

#### D6 — Implement Corrective Actions

- Implement the corrective actions.
- Remove containment actions once permanent corrections are verified.
- Update procedures, work instructions, inspection plans as needed.

#### D7 — Prevent Recurrence

- Systemic changes to prevent similar issues.
- Update standards, training, processes.
- Share lessons learned across similar parts/partners.
- Update FMEA if applicable.

#### D8 — Close and Recognize

- Verify all actions are effective.
- Close the 8D report.
- Document lessons learned.
- Recognize team contributions.
