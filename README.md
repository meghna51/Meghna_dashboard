# Paid Media Funnel Efficiency Analysis

A reproducible SQL analysis of campaign delivery, clicks, leads, and approved
conversions. The project is designed to compare funnel efficiency across
campaign IDs and audience segments without changing the source data.

## Contents

- `campaign_data.csv` — supplied dataset (1,143 ad-level rows).
- `schema.sql` — SQLite table definition.
- `analysis.sql` — data checks and seven analysis views/queries.
- `FINDINGS.md` — concise, data-derived portfolio summary and caveats.

## Run it

Requires SQLite 3.25 or newer. From this directory, run:

```sh
sqlite3 campaign_review.db < schema.sql
sqlite3 campaign_review.db ".mode csv" ".import --skip 1 campaign_data.csv campaign_ads"
sqlite3 campaign_review.db < analysis.sql
```

The import command assumes a recent SQLite CLI that supports `.import --skip`.
If your SQLite build does not, upgrade SQLite or use a CSV import wizard and
map the 11 columns to the `campaign_ads` table in CSV header order.

Each `SELECT` in `analysis.sql` returns one result set. Save or export the
results separately if you want to chart them.

## Questions this analysis answers

1. Is the file structurally sound, and are ad IDs unique?
2. How does the recorded funnel move from impressions to clicks, leads, and
   approved conversions?
3. Which source campaign IDs have the lowest observed cost per purchase?
4. How do age/gender groups and campaign-audience combinations compare?
5. Do broad numeric interest-code bands differ in observed delivery and cost?
6. Which individual ads had spend but no approved conversions recorded?

## Metric definitions

- **CTR** = total clicks / total impressions.
- **Cost per click** = total spend / total clicks.
- **Lead rate from clicks** = total conversions / total clicks.
- **Purchase rate from clicks** = approved conversions / total clicks.
- **Lead-to-purchase rate** = approved conversions / total conversions.
- **Cost per lead / purchase** = total spend / corresponding conversion count.

Rates are calculated from summed counts, not by averaging ad-level rates.
`NULLIF` prevents division-by-zero errors. Costs are in the dataset's spend
units; the file does not state a currency, and it contains no revenue or
profit values, so this project does not claim ROI.

## Interpretation limits

This is descriptive analysis of an observational dataset. It does not establish
that a demographic or campaign caused a conversion difference, and it should
not be treated as a controlled experiment or a budget-allocation rule. The
interest values are numeric codes with no category labels in the file; bands
must not be described as named interests. Low-volume segment comparisons are
especially noisy.

## Data and attribution

The CSV was provided with the reference materials for this analysis. The
source identified in those materials is the Kaggle Facebook Ad Campaign EDA
input: <https://www.kaggle.com/code/joshuamiguelcruz/facebook-ad-campaign-eda/input>.
The dataset is not original to this project. Check the source's current license
and reuse terms before redistributing the CSV publicly.

The SQL, project structure, metric definitions, and documentation in this
package are a new analysis; the source dataset is retained with attribution.
