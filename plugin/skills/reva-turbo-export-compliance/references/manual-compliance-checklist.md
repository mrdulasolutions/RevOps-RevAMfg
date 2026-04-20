# Manual Export Compliance Checklist

Use this checklist when ExChek is not available. This does NOT replace professional compliance screening — it is a minimum-viability fallback.

## 1. Item Classification

- [ ] Is the item described on the Commerce Control List (CCL)? → Check ECCN
- [ ] Is the item described on the USML (defense article)? → STOP, consult legal
- [ ] If not on CCL or USML → Classify as EAR99

### Common EAR99 Items (likely no license needed for most destinations)
- Standard machined parts (non-precision, commercial grade)
- Standard injection molded parts (commercial plastics)
- Standard sheet metal fabrications
- Common materials (aluminum 6061, steel 1018, ABS, nylon)
- Standard fasteners, brackets, housings, covers

### Items That MAY Be Controlled
- Precision machined components (tight tolerances for specific applications)
- Parts for aerospace, defense, nuclear, or marine applications
- Specialty alloys (Inconel, titanium for specific applications, beryllium)
- Encryption-capable electronics
- Sensors, optics, navigation equipment
- Parts designed for weapons systems or military platforms

## 2. Destination Check

- [ ] Is the destination country sanctioned? (Cuba, Iran, North Korea, Syria, Crimea/Donetsk/Luhansk)
  - If YES → BLOCK. Do not proceed.
- [ ] Is the destination China? → Additional scrutiny required:
  - Military end-use? → License likely required
  - Entity List partner? → Check step 3
  - General commercial? → Likely OK for EAR99

## 3. Party Screening

- [ ] Is the buyer/customer on the SDN list? → BLOCK
- [ ] Is the manufacturing partner on the Entity List? → BLOCK or license required
- [ ] Is any party on the Denied Persons List? → BLOCK
- [ ] Is any party on the Unverified List? → Enhanced due diligence required

### How to Check (without ExChek)
- OFAC SDN: https://sanctionssearch.ofac.treas.gov/
- BIS Entity List: https://www.bis.doc.gov/index.php/policy-guidance/lists-of-parties-of-concern
- Consolidated Screening List: https://www.trade.gov/consolidated-screening-list

## 4. End-Use Check

- [ ] Is the end-use commercial/civilian? → Lower risk
- [ ] Is the end-use military or defense? → Elevated risk, possible license requirement
- [ ] Is the end-use nuclear? → License required
- [ ] Is the end-use chemical/biological weapons? → BLOCK
- [ ] Is the end-use missile technology? → BLOCK

## 5. License Determination

Based on steps 1-4:
- EAR99 + non-sanctioned country + clean parties + commercial end-use = **NLR (No License Required)**
- Controlled ECCN + China = **Check License Exception availability or License Required**
- Any ITAR item = **License Required (DDTC)**
- Any sanctions match = **BLOCK**

## 6. Documentation

Record the following regardless of outcome:
- Date of screening
- Item description
- Destination and parties
- Classification result
- Screening result
- Decision (PROCEED/HOLD/BLOCK)
- PM name
