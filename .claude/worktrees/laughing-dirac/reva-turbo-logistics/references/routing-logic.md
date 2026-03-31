# Routing Logic: Direct-to-Customer vs Inspect-and-Forward

## Decision Matrix

Each factor is scored. If ANY factor scores "Inspect Required," the default routing is **inspect-and-forward**. The PM can override with documented justification.

### Factor 1: Order Value

| Value Range | Score | Routing |
|------------|-------|---------|
| < $10,000 | Low | Direct eligible |
| $10,000 - $25,000 | Medium | Direct eligible with caution |
| > $25,000 | High | Inspect required |

### Factor 2: Customer Relationship

| Relationship | Score | Routing |
|-------------|-------|---------|
| New customer (0 prior orders) | New | Inspect required |
| Developing (1-2 prior orders) | Developing | Inspect required |
| Established (3-5 prior orders, no issues) | Established | Direct eligible |
| Strategic (6+ orders, strong relationship) | Strategic | Direct eligible |

### Factor 3: Product Complexity

| Complexity | Score | Routing |
|-----------|-------|---------|
| Standard catalog part | Low | Direct eligible |
| Modified standard | Medium | Direct eligible with caution |
| Custom engineered | High | Inspect required |
| Tight tolerance (< 0.005") | Critical | Inspect required |

### Factor 4: Manufacturing Partner Score

| Partner Score | Routing |
|--------------|---------|
| A+ (98%+ quality, on-time) | Direct eligible |
| A (95-97% quality, on-time) | Direct eligible |
| B (90-94% quality, on-time) | Inspect required |
| C (80-89% quality, on-time) | Inspect required |
| D (< 80% quality, on-time) | Inspect required, consider partner change |

### Factor 5: Customer Preference

| Preference | Routing |
|-----------|---------|
| Customer requests direct ship | Direct eligible (if other factors allow) |
| Customer requests inspection | Inspect required |
| No preference stated | Use matrix result |

### Factor 6: Regulatory / Compliance

| Requirement | Routing |
|------------|---------|
| No special requirements | Direct eligible |
| Customer requires CoC from Rev A | Inspect required |
| Product requires safety testing | Inspect required |
| Export control applies | Inspect required |
| Customer audit rights clause in PO | Inspect required |

## Decision Algorithm

```
IF any factor = "Inspect required"
  THEN routing = inspect-and-forward
ELSE IF all factors = "Direct eligible"
  THEN routing = direct-to-customer
ELSE
  THEN routing = inspect-and-forward (default safe)
```

## Override Policy

The PM may override the matrix recommendation with documented justification. Overrides must be logged:

```bash
echo '{"ts":"...","po":"...","matrix_result":"inspect-and-forward","override_to":"direct-to-customer","reason":"...","pm":"..."}' >> ~/.reva-turbo/state/routing-overrides.jsonl
```

Overrides are reviewed in the monthly performance report.

## Cost Impact of Routing

| Routing | Additional Cost | Additional Time |
|---------|----------------|----------------|
| Direct-to-customer | None | None |
| Inspect-and-forward | $500-2,000 (handling, inspection, repack) | 3-7 days |

## Risk Impact of Routing

| Routing | Quality Risk | Customer Risk |
|---------|-------------|---------------|
| Direct-to-customer | Higher (no Rev A QC check) | Higher (defects reach customer) |
| Inspect-and-forward | Lower (Rev A catches issues) | Lower (defects caught before ship) |
