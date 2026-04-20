# Profile Fields Reference

Complete list of all fields tracked in a Rev A Manufacturing customer profile.

## Section 1: Company Information

| Field | Type | Required | Source |
|-------|------|----------|--------|
| Company name | Text | Yes | Onboarding |
| Customer ID | Text | Yes | Auto-generated |
| DBA / trade name | Text | No | Onboarding |
| Website | URL | Yes | Onboarding |
| Industry / sector | Text | Yes | Onboarding / PM |
| Company size (employees) | Number | No | Onboarding |
| Location (HQ) | Address | Yes | Onboarding |
| Shipping address(es) | Address list | No | Order history |
| DUNS number | Text | No | Onboarding |
| What they make / do | Text | No | PM knowledge |
| End markets served | Text | No | PM knowledge |

## Section 2: Contacts

| Field | Type | Required | Source |
|-------|------|----------|--------|
| Primary contact name | Text | Yes | Onboarding |
| Primary contact title | Text | No | Onboarding |
| Primary contact email | Email | Yes | Onboarding |
| Primary contact phone | Phone | No | Onboarding |
| Additional contacts | Contact list | No | PM knowledge |
| Decision-maker (PO authority) | Text | No | PM knowledge |
| Technical contact (engineering) | Text | No | PM knowledge |
| Quality contact (inspection) | Text | No | PM knowledge |
| Accounts payable contact | Text | No | PM knowledge |
| Executive sponsor | Text | No | PM knowledge |

## Section 3: Order History

| Field | Type | Required | Source |
|-------|------|----------|--------|
| Order list | Table | Yes | CRM / records |
| Total completed orders | Number | Yes | Calculated |
| Lifetime revenue | Currency | Yes | Calculated |
| Average order value | Currency | Yes | Calculated |
| First order date | Date | Yes | Records |
| Most recent order date | Date | Yes | Records |
| Order frequency | Text | No | Calculated / PM |
| Typical part types | Text | No | Order analysis |
| Typical processes | Text | No | Order analysis |
| Typical materials | Text | No | Order analysis |
| Typical quantities | Text | No | Order analysis |
| Annual run rate | Currency | No | Calculated |

## Section 4: Quality Profile

| Field | Type | Required | Source |
|-------|------|----------|--------|
| Quality tier | Option | No | PM assessment |
| Required documentation | Text list | No | Customer requirements |
| Tolerance profile | Text | No | Order analysis |
| Total NCRs | Number | No | Quality records |
| NCR history summary | Text | No | Quality records |
| First-pass acceptance rate | Percentage | No | Calculated |
| Returned goods history | Text | No | Records |
| Certification requirements | Text | No | Customer requirements |
| Special inspection needs | Text | No | Customer requirements |

## Section 5: Payment Profile

| Field | Type | Required | Source |
|-------|------|----------|--------|
| Current payment terms | Text | Yes | Credit setup |
| Credit tier | Number | Yes | Credit check |
| Payment on-time rate | Percentage | No | Calculated |
| Current outstanding balance | Currency | No | AR records |
| Oldest outstanding invoice | Date | No | AR records |
| Average days to pay | Number | No | Calculated |
| Payment behavior summary | Text | No | PM / AR |
| Credit limit | Currency | No | Credit setup |

## Section 6: Relationship Intelligence

| Field | Type | Required | Source |
|-------|------|----------|--------|
| Assigned PM | Text | Yes | PM assignment |
| BD rep | Text | No | Onboarding |
| Relationship strength | Option | No | PM assessment |
| Communication preference | Text | No | PM knowledge |
| Pricing sensitivity | Option | No | PM assessment |
| Decision-making process | Text | No | PM knowledge |
| Budget cycle / timing | Text | No | PM knowledge |
| Known competitors | Text | No | PM knowledge |
| Win/loss history vs competitors | Text | No | PM knowledge |
| Growth potential | Option | No | PM assessment |
| Wallet share estimate | Percentage | No | PM estimate |
| Upcoming opportunities | Text | No | PM knowledge |
| Relationship risks | Text | No | PM assessment |
| Last face-to-face meeting | Date | No | PM knowledge |
| Account review schedule | Text | No | PM / tier-based |

## Section 7: Tier and Metadata

| Field | Type | Required | Source |
|-------|------|----------|--------|
| Customer tier | Option | Yes | Assessment |
| Tier rationale | Text | Yes | Assessment |
| Profile created date | Date | Yes | Auto |
| Last updated date | Date | Yes | Auto |
| Last reviewed date | Date | No | PM |
| Next review scheduled | Date | No | Tier-based |
| Profile version | Number | Yes | Auto |
