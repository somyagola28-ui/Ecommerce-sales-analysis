/*
Marketing Analytical Insights
Dataset: Olist Marketing Funnel
Purpose:
Analyze seller acquisition funnel performance, lead conversion,
revenue quality, and post-acquisition operational outcomes
to support growth and marketing strategy decisions.
*/


SET search_path TO marketing;


-- 1. Funnel overview
-- MQLs → Closed Deals (overall conversion rate)
SELECT
    COUNT(DISTINCT m.mql_id) AS total_mqls,
    COUNT(DISTINCT c.mql_id) AS closed_mqls,
    ROUND(
        COUNT(DISTINCT c.mql_id)::NUMERIC / NULLIF(COUNT(DISTINCT m.mql_id), 0), 4) AS mql_to_close_conversion_rate
FROM marketing.marketing_qualified_leads m
LEFT JOIN marketing.marketing_closed_deals c
    ON m.mql_id = c.mql_id;



-- 2. Funnel performance by lead origin
SELECT
    COALESCE(m.origin, 'unknown_origin') AS origin,
    COUNT(DISTINCT m.mql_id) AS total_mqls,
    COUNT(DISTINCT c.mql_id) AS closed_mqls,
    ROUND(
        COUNT(DISTINCT c.mql_id)::NUMERIC / NULLIF(COUNT(DISTINCT m.mql_id), 0), 4) AS conversion_rate
FROM marketing.marketing_qualified_leads m
LEFT JOIN marketing.marketing_closed_deals c
    ON m.mql_id = c.mql_id
GROUP BY COALESCE(m.origin, 'unknown_origin')
ORDER BY conversion_rate DESC;

-- Note: 'unknown' is a valid CRM value; NULL origins are labeled as 'unknown_origin'


-- 3. Revenue attribution by business type
SELECT
    business_type,
    COUNT(*) AS sellers_closed,
    ROUND(SUM(declared_monthly_revenue), 2) AS total_declared_revenue,
    ROUND(AVG(declared_monthly_revenue), 2) AS avg_declared_revenue
FROM marketing.marketing_closed_deals
GROUP BY business_type
ORDER BY total_declared_revenue DESC;


-- 4. Seller quality indicators
SELECT
    COALESCE(has_company::TEXT, 'unknown') AS has_company,
    COUNT(*) AS sellers,
    ROUND(AVG(declared_monthly_revenue), 2) AS avg_revenue
FROM marketing.marketing_closed_deals
GROUP BY COALESCE(has_company::TEXT, 'unknown')
ORDER BY avg_revenue DESC;


--5. Seller geography vs revenue
SELECT
    s.seller_state,
    COUNT(*) AS sellers,
    COALESCE(
        ROUND(
            AVG(
                CASE
                    WHEN c.declared_monthly_revenue > 0 THEN c.declared_monthly_revenue ELSE NULL END), 2), 0) AS avg_revenue
FROM marketing.marketing_closed_deals c
JOIN public.olist_sellers s
    ON c.seller_id = s.seller_id
GROUP BY s.seller_state
ORDER BY avg_revenue DESC;



--6. Seller acquisition quality vs delivery performance
SELECT
    c.business_type,
    ROUND(
        AVG(o.order_delivered_customer_date::DATE - o.order_purchase_timestamp::DATE), 2)
  AS avg_delivery_days
FROM marketing.marketing_closed_deals c
JOIN public.olist_order_items oi
    ON c.seller_id = oi.seller_id
JOIN public.olist_orders o
    ON oi.order_id = o.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.business_type
ORDER BY avg_delivery_days;
