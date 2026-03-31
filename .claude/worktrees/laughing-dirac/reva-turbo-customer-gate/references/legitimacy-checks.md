# Legitimacy Checks — Customer Verification

## Check 1: Website Verification

**What to verify:**
- Company has a functioning website at the domain they claim
- Website content describes a real business with products/services
- Website is not a placeholder, parked domain, or recently created shell

**How to verify:**
- Visit the URL provided
- Check for: About page, product/service descriptions, contact information, physical address
- Note the domain age if possible (newer domains are not automatically suspicious but are worth noting)

**Results:**
- `Verified` — Website exists, appears legitimate, content is consistent with company claims
- `Not Found` — No website at the provided URL
- `Suspicious` — Website exists but has red flags (no content, very new, inconsistent with claims)

## Check 2: Email Domain Match

**What to verify:**
- Contact email domain matches the company website domain
- If contact uses a personal email (gmail, yahoo, etc.), determine why

**Results:**
- `Match` — Email domain matches company website (e.g., john@acmecorp.com + acmecorp.com)
- `Mismatch` — Email domain is different from company website (investigate)
- `Personal Email` — Contact uses a free email service (not automatically disqualifying, but note it)

**Personal email acceptable when:**
- Very small business (1-5 employees) that does not have a company domain
- Contact is a consultant or broker acting on behalf of the end customer
- PM has verified the contact through other means (phone call, in-person meeting)

## Check 3: Business Presence Confirmation

**What to verify:**
- The company exists as a registered business entity
- Independent sources confirm the company is real and operational

**Sources to check:**
1. **LinkedIn** — Company page with employees
2. **State business registration** — Secretary of State records (varies by state)
3. **Industry directories** — Thomasnet, GlobalSpec, industry association memberships
4. **Google Maps** — Business listing at the claimed address
5. **News/press** — Any press releases, news mentions, or industry publications
6. **D&B / Hoovers** — Business profile if DUNS number is available

**Minimum requirement:** At least one independent source confirms the company exists beyond their own website.

**Results:**
- `Confirmed` — Multiple independent sources confirm business exists
- `Unconfirmed` — Cannot find independent confirmation (not automatic disqualifier, but flag for PM review)
- `Concerns` — Contradictory information found or indicators of a non-legitimate entity

## Check 4: Red Flag Screening

**Automatic red flags (require escalation):**
- Company name matches a known Rev A competitor
- Company or contact appears on US sanctions lists (SDN, Entity List)
- Company is based in or ships to an embargoed country
- Contact provides false or contradictory information
- Multiple RFQ attempts from different contacts at the same company with no intent to order

**Yellow flags (note but do not block):**
- Company is very new (< 1 year old)
- Contact found Rev A through an unusual channel
- RFQ requests pricing for a very wide range of parts (may be shopping)
- Contact is reluctant to provide company details
- Company address is in a shared office space or co-working facility

**Not red flags (do not penalize):**
- Small company size
- Located in a rural area
- Industry that is unfamiliar to Rev A
- First-time RFQ with detailed specifications (this is normal)
- Requesting NDA before sharing drawings (this is standard practice)

## Export Control Screening

For all new customers, verify:
- Company is not on the BIS Entity List
- Company is not on the OFAC SDN List
- End use is not for prohibited applications (nuclear, chemical/biological weapons, missile technology)
- Destination country is not under comprehensive US sanctions

If export control concerns are identified, escalate to Donovan Weber before proceeding. Do not complete onboarding until cleared.

## Screening Documentation

Document all checks performed and their results in the onboarding record. Include:
- Date of check
- Sources consulted
- Results (pass/fail/flag)
- Any concerns and how they were addressed
- PM decision and rationale
