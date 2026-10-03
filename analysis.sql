-- Paid Media Funnel Efficiency Analysis
-- SQLite 3.25+; run after importing campaign_data.csv into campaign_ads.
-- The source campaign IDs are retained as supplied; no source rows are updated.

-- 1) Dataset health checks: expected one row per ad_id.
SELECT
    COUNT(*) AS row_count,
    COUNT(DISTINCT ad_id) AS distinct_ads,
    SUM(CASE WHEN ad_id IS NULL THEN 1 ELSE 0 END) AS missing_ad_ids,
    SUM(CASE WHEN Impressions < 0 OR Clicks < 0 OR Spent < 0 THEN 1 ELSE 0 END)
        AS invalid_delivery_or_spend_rows,
    SUM(CASE WHEN Clicks > Impressions THEN 1 ELSE 0 END) AS clicks_over_impressions
FROM campaign_ads;

-- 2) Overall funnel and cost metrics.
-- Rates are percentages. Costs use the dataset's supplied spend units.
WITH totals AS (
    SELECT
        SUM(Impressions) AS impressions,
        SUM(Clicks) AS clicks,
        SUM(Spent) AS spend,
        SUM(Total_Conversion) AS leads,
        SUM(Approved_Conversion) AS purchases
    FROM campaign_ads
)
SELECT
    impressions,
    clicks,
    ROUND(spend, 2) AS spend,
    leads,
    purchases,
    ROUND(100.0 * clicks / NULLIF(impressions, 0), 3) AS ctr_pct,
    ROUND(spend / NULLIF(clicks, 0), 3) AS cost_per_click,
    ROUND(100.0 * leads / NULLIF(clicks, 0), 3) AS lead_rate_from_click_pct,
    ROUND(100.0 * purchases / NULLIF(clicks, 0), 3) AS purchase_rate_from_click_pct,
    ROUND(100.0 * purchases / NULLIF(leads, 0), 3) AS lead_to_purchase_pct,
    ROUND(spend / NULLIF(leads, 0), 3) AS cost_per_lead,
    ROUND(spend / NULLIF(purchases, 0), 3) AS cost_per_purchase
FROM totals;

-- 3) Campaign comparison. These are descriptive results, not causal lift.
SELECT
    xyz_campaign_id,
    COUNT(*) AS ad_rows,
    SUM(Impressions) AS impressions,
    SUM(Clicks) AS clicks,
    ROUND(SUM(Spent), 2) AS spend,
    SUM(Total_Conversion) AS leads,
    SUM(Approved_Conversion) AS purchases,
    ROUND(100.0 * SUM(Clicks) / NULLIF(SUM(Impressions), 0), 3) AS ctr_pct,
    ROUND(SUM(Spent) / NULLIF(SUM(Clicks), 0), 3) AS cost_per_click,
    ROUND(SUM(Spent) / NULLIF(SUM(Total_Conversion), 0), 3) AS cost_per_lead,
    ROUND(SUM(Spent) / NULLIF(SUM(Approved_Conversion), 0), 3) AS cost_per_purchase,
    ROUND(100.0 * SUM(Approved_Conversion) /
          NULLIF(SUM(Total_Conversion), 0), 3) AS lead_to_purchase_pct
FROM campaign_ads
GROUP BY xyz_campaign_id
ORDER BY cost_per_purchase ASC, purchases DESC;

-- 4) Audience-segment funnel. Aggregation uses summed counts, not averages
-- of per-ad rates, so larger delivery contributes proportionally.
SELECT
    age,
    gender,
    COUNT(*) AS ad_rows,
    SUM(Impressions) AS impressions,
    SUM(Clicks) AS clicks,
    ROUND(SUM(Spent), 2) AS spend,
    SUM(Total_Conversion) AS leads,
    SUM(Approved_Conversion) AS purchases,
    ROUND(100.0 * SUM(Clicks) / NULLIF(SUM(Impressions), 0), 3) AS ctr_pct,
    ROUND(SUM(Spent) / NULLIF(SUM(Clicks), 0), 3) AS cost_per_click,
    ROUND(SUM(Spent) / NULLIF(SUM(Approved_Conversion), 0), 3) AS cost_per_purchase
FROM campaign_ads
GROUP BY age, gender
ORDER BY purchases DESC, cost_per_purchase ASC;

-- 5) Campaign x audience cut. The 5-purchase floor reduces noise from
-- tiny cells; it is a screening choice, not a statistical significance test.
SELECT
    xyz_campaign_id,
    age,
    gender,
    COUNT(*) AS ad_rows,
    SUM(Clicks) AS clicks,
    ROUND(SUM(Spent), 2) AS spend,
    SUM(Approved_Conversion) AS purchases,
    ROUND(100.0 * SUM(Clicks) / NULLIF(SUM(Impressions), 0), 3) AS ctr_pct,
    ROUND(SUM(Spent) / NULLIF(SUM(Approved_Conversion), 0), 3) AS cost_per_purchase
FROM campaign_ads
GROUP BY xyz_campaign_id, age, gender
HAVING SUM(Approved_Conversion) >= 5
ORDER BY cost_per_purchase ASC, purchases DESC;

-- 6) Interest bands are descriptive groupings of numeric codes, not named
-- interests. Keep this distinction when communicating results.
WITH banded AS (
    SELECT
        CASE
            WHEN interest <= 25 THEN '02-25'
            WHEN interest <= 50 THEN '26-50'
            WHEN interest <= 75 THEN '51-75'
            WHEN interest <= 100 THEN '76-100'
            ELSE '101+'
        END AS interest_band,
        xyz_campaign_id,
        Impressions,
        Clicks,
        Spent,
        Total_Conversion,
        Approved_Conversion
    FROM campaign_ads
)
SELECT
    interest_band,
    xyz_campaign_id,
    COUNT(*) AS ad_rows,
    SUM(Impressions) AS impressions,
    SUM(Clicks) AS clicks,
    ROUND(SUM(Spent), 2) AS spend,
    SUM(Total_Conversion) AS leads,
    SUM(Approved_Conversion) AS purchases,
    ROUND(100.0 * SUM(Clicks) / NULLIF(SUM(Impressions), 0), 3) AS ctr_pct,
    ROUND(SUM(Spent) / NULLIF(SUM(Approved_Conversion), 0), 3) AS cost_per_purchase
FROM banded
GROUP BY interest_band, xyz_campaign_id
ORDER BY interest_band, cost_per_purchase ASC;

-- 7) Ads that spent money but recorded no approved conversions.
-- Investigate these individually; the dataset has no time, attribution-window,
-- or revenue fields, so this is not proof an ad performed poorly.
SELECT
    ad_id,
    xyz_campaign_id,
    age,
    gender,
    interest,
    Impressions,
    Clicks,
    ROUND(Spent, 2) AS spend,
    Total_Conversion AS leads
FROM campaign_ads
WHERE Spent > 0
  AND Approved_Conversion = 0
ORDER BY Spent DESC
LIMIT 25;