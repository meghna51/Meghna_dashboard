# Paid Media Funnel Efficiency Analysis — Findings

## Executive snapshot

Across 1,143 ad-level records, the campaigns recorded **213.4M impressions,
38,165 clicks, 3,264 leads, and 1,079 approved conversions** on **58,705.23**
spend units. The overall click-through rate was **0.0179%**, and observed
spend per approved conversion was **54.41**. The dataset does not identify
the currency or report revenue, so spend per conversion is not ROI.

## What stands out

**Campaign 1178 supplied most of the scale, not the lowest cost.** It recorded
872 approved conversions (about 81% of the total) and used 55,662.15 spend
units (about 95% of the total). Its observed spend per approved conversion was
63.83. Campaign 936 recorded 183 purchases at 15.81 per purchase. Campaign
916 recorded 24 at 6.24, but from only 54 ad rows and 113 clicks. The low
observed cost for 916 is a small-volume signal, not enough on its own to
justify shifting budget.

| Source campaign ID | Ad rows | Spend | Approved conversions | Spend per approved conversion |
| --- | ---: | ---: | ---: | ---: |
| 916 | 54 | 149.71 | 24 | 6.24 |
| 936 | 464 | 2,893.37 | 183 | 15.81 |
| 1178 | 625 | 55,662.15 | 872 | 63.83 |

**Men aged 30–34 were the largest pooled age/gender segment by purchases.**
They recorded 299 approved conversions at 25.55 spend units each. This
combines all three campaigns; it is a descriptive audience comparison, not
evidence that gender or age caused the difference.

**Interest-code bands show little basis for a strong targeting claim.** Bands
02–25 and 26–50 recorded 526 and 324 purchases, with spend per purchase of
53.20 and 55.90 respectively. These are unlabeled numeric codes, not named
interests. The 76–100 band contains only six ad rows, so its apparent result is
particularly uncertain.

## Practical next step

Use the results to frame a controlled follow-up test, not an automatic budget
shift: compare campaigns on a consistent audience and attribution window,
define an acceptable cost per purchase, and verify currency and campaign
definitions first. The source data has no revenue, profit, or experiment
design, so it cannot establish return on ad spend or causal lift.

## Method

Metrics use summed counts: CTR = clicks / impressions; spend per approved
conversion = spend / approved conversions. Segment rates are not averages of
per-ad rates. Campaign IDs are kept as supplied. The dataset source cited in
the supplied project materials is the
[Kaggle Facebook Ad Campaign EDA input](https://www.kaggle.com/code/joshuamiguelcruz/facebook-ad-campaign-eda/input).