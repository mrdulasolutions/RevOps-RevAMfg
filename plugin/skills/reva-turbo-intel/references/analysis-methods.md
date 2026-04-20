# Intel Analysis Methods

Statistical and analytical methods available for REVA-TURBO intelligence analysis.

## 1. Trend Analysis (Linear Regression)

**Purpose:** Determine whether a KPI is improving, declining, or stable over time.

**Method:**
1. Collect time-series data points for the metric (e.g., monthly on-time delivery rate).
2. Fit a linear regression line: y = mx + b, where x is time and y is the metric value.
3. The slope (m) indicates the trend direction and rate of change.
4. Calculate R-squared to measure how well the trend line fits the data.

**Interpretation:**
- Slope > 0: improving trend
- Slope < 0: declining trend
- Slope near 0: stable
- R-squared > 0.7: strong trend (high confidence)
- R-squared 0.3-0.7: moderate trend (medium confidence)
- R-squared < 0.3: weak or no clear trend (low confidence)

**Output format:**
```
[METRIC] trend over [PERIOD]:
Direction: [improving/declining/stable]
Rate: [+/- X units per month]
Fit: R-squared = [value] ([strong/moderate/weak])
Current: [current value]
Projected (next month): [projected value] (95% CI: [low]-[high])
```

## 2. Pareto Analysis (80/20 Rule)

**Purpose:** Identify the vital few factors that drive the majority of outcomes.

**Method:**
1. Categorize items (defect types, customers by revenue, partners by NCR count).
2. Sort by frequency or impact (descending).
3. Calculate cumulative percentage.
4. Identify the cutoff where ~80% of the total is reached.

**Application areas:**
- Defect types: Which 20% of defect types cause 80% of NCRs?
- Customers: Which 20% of customers generate 80% of revenue?
- Partners: Which partners generate 80% of quality issues?
- Cost drivers: What are the biggest contributors to COPQ?

**Output format:**
```
Pareto Analysis: [CATEGORY]

| Rank | Item | Count/Value | % of Total | Cumulative % |
|------|------|-------------|-----------|--------------|
| 1    | ...  | ...         | ...       | ...          |

Top [N] items account for [X]% of total [metric].
```

## 3. Cohort Analysis

**Purpose:** Compare groups of entities to identify performance differences.

**Method:**
1. Define cohorts by a shared characteristic (customer acquired in Q1 vs Q2, orders using Partner A vs Partner B, CNC orders vs casting orders).
2. Measure the same KPIs for each cohort.
3. Compare using normalized metrics (rates, averages).
4. Test for statistical significance if sample sizes are adequate.

**Application areas:**
- Customer cohorts by acquisition quarter (retention, order frequency)
- Partner cohorts by quality grade (delivery performance, cost)
- Order cohorts by process type (lead time, margin, defect rate)
- Time cohorts by season (Q1 vs Q3 demand patterns)

**Output format:**
```
Cohort Comparison: [DIMENSION]

| Cohort | N | [Metric 1] | [Metric 2] | [Metric 3] |
|--------|---|-----------|-----------|-----------|
| A      | . | ...       | ...       | ...       |
| B      | . | ...       | ...       | ...       |

Significant differences: [list]
```

## 4. Anomaly Detection

**Purpose:** Flag unusual values that may indicate problems or opportunities.

**Method:**
1. Calculate the rolling mean and standard deviation for a metric over the analysis window.
2. For each current data point, calculate its z-score: z = (value - mean) / std_dev.
3. Flag values where |z| > 2 as anomalies.
4. Flag values where |z| > 3 as severe anomalies.

**Anomaly types:**
- **Point anomaly:** A single data point that deviates significantly (e.g., an order that took 3x the normal lead time).
- **Contextual anomaly:** A value that is normal in general but unusual in context (e.g., a delay from a partner that is normally on time).
- **Collective anomaly:** A sequence of values that together indicate an abnormal pattern (e.g., three consecutive deliveries each slightly later than the previous).

**Output format:**
```
Anomaly Detected: [METRIC]

Current value: [VALUE]
Expected range: [MEAN] +/- [2 * STD_DEV]
Z-score: [Z]
Severity: [anomaly/severe anomaly]
Context: [what makes this unusual]
Possible explanation: [hypothesis]
```

## 5. Correlation Analysis

**Purpose:** Identify which factors are associated with outcomes of interest.

**Method:**
1. Select the outcome variable (e.g., on-time delivery: yes/no).
2. Select candidate predictor variables (partner, process type, order size, rush flag, season).
3. Calculate correlation coefficients (Pearson for continuous, point-biserial for binary).
4. Rank predictors by strength of correlation.

**Interpretation:**
- |r| > 0.7: strong correlation
- |r| 0.4-0.7: moderate correlation
- |r| 0.2-0.4: weak correlation
- |r| < 0.2: negligible correlation

**Important caveats:**
- Correlation does not imply causation. Always state this.
- Small sample sizes can produce misleading correlations. Require N > 15 for any correlation claim.
- Look for confounding variables that might explain the relationship.

**Output format:**
```
Correlation Analysis: Predictors of [OUTCOME]

| Factor | Correlation (r) | Strength | Direction | N |
|--------|----------------|----------|-----------|---|
| ...    | ...            | ...      | ...       | . |

Top predictor: [FACTOR] (r = [VALUE])
Caveat: Correlation does not imply causation. [Additional context.]
```

## 6. Moving Averages

**Purpose:** Smooth noisy data to reveal underlying trends.

**Method:**
1. Select the window size (7-day, 30-day, or 90-day depending on data frequency).
2. For each data point, calculate the average of the surrounding window.
3. Plot the smoothed line against the raw data.

**Window selection guide:**
- Daily data: 7-day or 14-day moving average
- Weekly data: 4-week moving average
- Monthly data: 3-month moving average

**Output format:**
```
[METRIC] — [WINDOW]-day moving average

| Period | Raw Value | Moving Avg | Trend |
|--------|-----------|-----------|-------|
| ...    | ...       | ...       | ...   |

The smoothed trend shows [description of pattern].
```

## 7. Confidence Intervals

**Purpose:** Bound predictions and estimates with a range that reflects uncertainty.

**Method:**
1. Calculate the sample mean and standard error.
2. For a 95% confidence interval: mean +/- 1.96 * standard_error.
3. For a 90% confidence interval: mean +/- 1.645 * standard_error.

**Rules:**
- Always use 95% CI unless the PM requests otherwise.
- If sample size < 30, use t-distribution instead of z-distribution.
- State the confidence level and sample size with every interval.
- Wider intervals = more uncertainty. This is honest, not a weakness.

**Output format:**
```
Estimate: [METRIC] = [MEAN]
95% Confidence Interval: [LOWER] to [UPPER]
Based on N = [SAMPLE_SIZE] observations
Interpretation: We are 95% confident the true value falls between [LOWER] and [UPPER].
```

## Method Selection Guide

| Question Type | Primary Method | Supporting Method |
|--------------|---------------|-------------------|
| "Is it getting better or worse?" | Trend analysis | Moving averages |
| "What's causing the most problems?" | Pareto analysis | Correlation analysis |
| "How does A compare to B?" | Cohort analysis | Confidence intervals |
| "Is this normal?" | Anomaly detection | Moving averages |
| "What predicts success?" | Correlation analysis | Cohort analysis |
| "What will happen next?" | Trend analysis + CI | Correlation analysis |
| "Where should we focus?" | Pareto analysis | Trend analysis |
