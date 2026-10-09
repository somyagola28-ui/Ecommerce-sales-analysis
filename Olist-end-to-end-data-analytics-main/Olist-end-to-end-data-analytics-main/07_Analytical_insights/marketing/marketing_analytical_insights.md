# Marketing Analytical Insights
## Olist Seller Acquisition Funnel – SQL Analysis
This document presents analytical insights derived from the **Olist Marketing Funnel dataset**.
The analysis focuses on evaluating seller acquisition performance, lead conversion efficiency,
revenue quality, and post-acquisition operational outcomes.

All insights are generated using SQL on validated analytical tables and are structured
to answer concrete business and growth-related questions.

---

## A. Funnel Overview

### 1. What is the overall conversion rate from MQLs to Closed Deals?

This metric evaluates the effectiveness of the seller acquisition funnel.
It measures how many Marketing Qualified Leads (MQLs) successfully convert into closed deals.

```sql
SELECT
    COUNT(DISTINCT m.mql_id) AS total_mqls,
    COUNT(DISTINCT c.mql_id) AS closed_mqls,
    ROUND(
        COUNT(DISTINCT c.mql_id)::NUMERIC / NULLIF(COUNT(DISTINCT m.mql_id), 0), 4)
   AS mql_to_close_conversion_rate
FROM marketing_qualified_leads m
LEFT JOIN marketing_closed_deals c
    ON m.mql_id = c.mql_id;
```

---

## B. Funnel Performance by Lead Origin

### 2. Which lead origins generate the highest conversion rates?

Understanding conversion performance by lead source helps optimize marketing channels
and prioritize high-quality acquisition sources.

```sql
SELECT
    COALESCE(m.origin, 'unknown_origin') AS origin,
    COUNT(DISTINCT m.mql_id) AS total_mqls,
    COUNT(DISTINCT c.mql_id) AS closed_mqls,
    ROUND(
        COUNT(DISTINCT c.mql_id)::NUMERIC / NULLIF(COUNT(DISTINCT m.mql_id), 0), 4)
      AS conversion_rate
FROM marketing_qualified_leads m
LEFT JOIN marketing_closed_deals c
    ON m.mql_id = c.mql_id
GROUP BY COALESCE(m.origin, 'unknown_origin')
ORDER BY conversion_rate DESC;
```

---

## C. Revenue Attribution

### 3. Which business types generate the highest declared revenue?

This analysis identifies seller business segments that contribute the most revenue,
helping assess acquisition quality beyond conversion volume.

```sql
SELECT
    business_type,
    COUNT(*) AS sellers_closed,
    ROUND(SUM(declared_monthly_revenue), 2) AS total_declared_revenue,
    ROUND(AVG(declared_monthly_revenue), 2) AS avg_declared_revenue
FROM marketing_closed_deals
GROUP BY business_type
ORDER BY total_declared_revenue DESC;
```

---

## D. Seller Quality Indicators

### 4. Do sellers with registered companies generate higher revenue?

This query evaluates whether formal business registration (`has_company`)
correlates with higher declared monthly revenue.

```sql
SELECT
    COALESCE(has_company::TEXT, 'unknown') AS has_company,
    COUNT(*) AS sellers,
    ROUND(AVG(declared_monthly_revenue), 2) AS avg_revenue
FROM marketing_closed_deals
GROUP BY COALESCE(has_company::TEXT, 'unknown')
ORDER BY avg_revenue DESC;
```

---

## E. Seller Geography & Revenue

### 5. Which seller regions generate higher average revenue?

Geographic analysis helps identify regions producing higher-value sellers
and supports regional targeting strategies.

```sql
SELECT
    s.seller_state,
    COUNT(*) AS sellers,
    COALESCE(
        ROUND(
            AVG(CASE WHEN c.declared_monthly_revenue > 0 THEN c.declared_monthly_revenue ELSE NULL END), 2), 0)
    AS avg_revenue
FROM marketing_closed_deals c
JOIN ecommerce.olist_sellers s
    ON c.seller_id = s.seller_id
GROUP BY s.seller_state
ORDER BY avg_revenue DESC;
```

---

## F. Acquisition Quality vs Operational Performance

### 6. Does seller business type impact delivery performance?

This analysis connects seller acquisition attributes with post-onboarding logistics outcomes.
It helps assess whether certain business types introduce operational risk after onboarding.

```sql
SELECT
    c.business_type,
    ROUND(
        AVG(o.order_delivered_customer_date::DATE - o.order_purchase_timestamp::DATE), 2)
   AS avg_delivery_days
FROM marketing_closed_deals c
JOIN ecommerce.olist_order_items oi
    ON c.seller_id = oi.seller_id
JOIN ecommerce.olist_orders o
    ON oi.order_id = o.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.business_type
ORDER BY avg_delivery_days;
```

---

## Summary

- The overall MQL → Closed Deal conversion rate quantifies acquisition efficiency.
- Lead origin significantly influences conversion quality.
- Certain business types contribute disproportionately to declared revenue.
- Sellers with registered companies tend to generate higher revenue.
- Geographic differences reveal regional seller value variations.
- Acquisition quality has measurable downstream effects on delivery performance.

These insights support **data-driven marketing optimization**, seller screening,
and operational planning.
