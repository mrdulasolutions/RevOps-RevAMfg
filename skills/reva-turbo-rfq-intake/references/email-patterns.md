# Common RFQ Email Patterns

Reference for identifying and parsing RFQs from common email formats received by Rev A Manufacturing.

## Pattern 1: Direct RFQ Email

**Subject line indicators:**
- "RFQ", "Request for Quote", "Request for Quotation"
- "Quote request", "Pricing request", "Bid request"
- Part numbers in subject line
- "New project", "New part"

**Body structure:**
```
Hi [Rev A contact],

We are looking for a quote on the following:

Part: [description]
Material: [spec]
Quantity: [number]
Delivery: [timeline]

Please see attached drawing.

Thanks,
[Name]
[Title]
[Company]
[Phone]
[Email]
```

**Extraction notes:**
- Contact info often in email signature block
- Attachments referenced but not inline — note filenames
- Multiple parts may be listed in a table or bullet format

## Pattern 2: Forwarded from BD

**Subject line indicators:**
- "FW:", "Fwd:" prefix
- BD rep name in forwarding chain
- "New lead", "Hot lead", "Opportunity"

**Body structure:**
```
[BD rep note at top]:
"Hey team, got this from [source]. Can we quote?"

---------- Forwarded message ----------
[Original RFQ content]
```

**Extraction notes:**
- Extract BD source from the forwarding note
- The original sender is the customer contact
- BD rep notes may contain priority or relationship context

## Pattern 3: Website Form Submission

**Subject line indicators:**
- "New submission from revamfg.com"
- "Contact form", "Quote request form"
- Automated subject format

**Body structure:**
```
Name: [value]
Company: [value]
Email: [value]
Phone: [value]
Part Description: [value]
Quantity: [value]
Material: [value]
Additional Details: [value]
File Attachments: [list]
```

**Extraction notes:**
- Structured key-value pairs — direct mapping
- May have limited technical detail — flag for follow-up
- Attachments may be links rather than inline files

## Pattern 4: Reply to Existing Thread

**Subject line indicators:**
- "Re:" prefix
- Previous quote number or RFQ reference
- Customer name in subject

**Body structure:**
- References previous conversation
- May contain updated quantities, revised specs, or new parts
- Check thread for original RFQ context

**Extraction notes:**
- Link to existing RFQ if this is a revision
- Note what changed from the original request
- Customer type is likely "Returning"

## Pattern 5: Bulk / Multi-Part RFQ

**Subject line indicators:**
- "Multiple parts", "Part list", "BOM quote"
- Spreadsheet attachment referenced

**Body structure:**
```
Please quote the following parts per the attached BOM/spreadsheet:

1. Part A - [description] - Qty: [number]
2. Part B - [description] - Qty: [number]
3. Part C - [description] - Qty: [number]

Material and tolerance details in the attached files.
```

**Extraction notes:**
- Create separate extraction blocks for each part
- Common material/finish may apply to all parts
- Spreadsheet attachments need manual review — note filenames

## Pattern 6: Phone/Verbal Inquiry

**No email — PM is transcribing:**

Expected input format:
```
Got a call from [Name] at [Company]. Looking for [description].
Quantity: [number]. Needs it by [date]. Call back at [phone].
```

**Extraction notes:**
- Source should be tagged as "phone"
- May be incomplete — flag missing fields aggressively
- No attachments expected — request drawings via follow-up

## Red Flags in RFQs

Watch for and flag these patterns:
- **No company name** — Could be a competitor fishing for pricing
- **Personal email domain** (gmail, yahoo, hotmail) — May be legitimate small business, but verify
- **Unrealistic quantities** — Very high quantities from unknown companies
- **Export-controlled keywords** — Military, defense, ITAR, munitions, satellite, encryption
- **Competitor company names** — Flag for BD/leadership review
- **Rush timelines with no context** — "Need it tomorrow" with no explanation
