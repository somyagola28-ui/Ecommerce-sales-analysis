/*
Marketing Funnel Data Validation Checks
Dataset: Olist Marketing Funnel
Purpose: Validate data integrity, completeness, and funnel consistency
before analytical use.
*/

SET search_path TO marketing;

-- MARKETING QUALIFIED LEADS (MQLs)
-- Purpose: Validate lead acquisition data quality


-- 1. Total MQL count
SELECT COUNT(*) AS total_mqls
FROM marketing_qualified_leads;


--2. Duplicate MQL IDs (should NEVER happen)
SELECT mql_id, COUNT(*) AS occurrences
FROM marketing_qualified_leads
GROUP BY mql_id
HAVING COUNT(*) > 1;


--3. NULL checks on critical fields
SELECT
    SUM(CASE WHEN mql_id IS NULL THEN 1 ELSE 0 END) AS null_mql_id,
    SUM(CASE WHEN first_contact_date IS NULL THEN 1 ELSE 0 END) AS null_contact_date,
    SUM(CASE WHEN origin IS NULL THEN 1 ELSE 0 END) AS null_origin
FROM marketing_qualified_leads;


-- 4. Date range validation (lead acquisition window)
SELECT
    MIN(first_contact_date) AS earliest_contact,
    MAX(first_contact_date) AS latest_contact
FROM marketing_qualified_leads;


--5. Lead origin distribution
SELECT origin, COUNT(*) AS leads
FROM marketing_qualified_leads
GROUP BY origin
ORDER BY leads DESC;



-- MARKETING CLOSED DEALS
-- Purpose: Validate seller acquisition and deal data


-- 1. Total closed deals count
SELECT COUNT(*) AS total_closed_deals
FROM marketing_closed_deals;


-- 2. NULL checks on key fields
SELECT
    SUM(CASE WHEN mql_id IS NULL THEN 1 ELSE 0 END) AS null_mql_id,
    SUM(CASE WHEN won_date IS NULL THEN 1 ELSE 0 END) AS null_won_date
FROM marketing_closed_deals;


-- 3.Duplicate MQLs in closed deals (should NOT happen)
SELECT mql_id, COUNT(*) AS occurrences
FROM marketing_closed_deals
GROUP BY mql_id
HAVING COUNT(*) > 1;


-- 4. Seller linkage integrity
SELECT COUNT(*) AS missing_seller_links
FROM marketing_closed_deals c
LEFT JOIN ecommerce.olist_sellers s
  ON c.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

/*Interpretation: 
Not all marketing-acquired sellers appear in the marketplace sellers table. 
This is expected, as the funnel includes leads that did not become active sellers. */

--5. Deal date vs lead date consistency
SELECT *
FROM marketing_closed_deals c
JOIN marketing_qualified_leads m
  ON c.mql_id = m.mql_id
WHERE c.won_date < m.first_contact_date;

/*Interpretation: 
One record shows a deal closure date earlier than the initial contact date. 
This appears to be an isolated CRM data entry inconsistency. */

--6. Boolean field distribution (data normalization check)
SELECT
    has_company,
    COUNT(*) AS count
FROM marketing_closed_deals
GROUP BY has_company;

/* Interpretation: NULL values indicate missing or unreported attributes rather than data errors.*/

SELECT
    has_gtin,
    COUNT(*) AS count
FROM marketing_closed_deals
GROUP BY has_gtin;

/*Interpretation: 
 GTIN information is not consistently captured in the marketing source data. 
 NULL values were preserved to avoid introducing assumptions during normalization.*/ 

-- 7. Deal date range validation
SELECT
    MIN(won_date) AS earliest_deal,
    MAX(won_date) AS latest_deal
FROM marketing_closed_deals;


-- 8. Revenue sanity check
SELECT
    MIN(declared_monthly_revenue) AS min_revenue,
    MAX(declared_monthly_revenue) AS max_revenue
FROM marketing_closed_deals;


-- 9. Percentage of closed deals with declared revenue
SELECT
    ROUND(SUM(
        CASE WHEN declared_monthly_revenue IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS pct_with_revenue
FROM marketing_closed_deals;


-- 10. Percentage of closed deals with non-zero declared revenue
SELECT
    ROUND(SUM(
        CASE WHEN declared_monthly_revenue IS NOT NULL 
                 AND declared_monthly_revenue > 0 
            THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)AS pct_with_nonzero_revenue
FROM marketing_closed_deals;


-- FUNNEL INTEGRITY CHECKS
-- Purpose: Validate MQL → Closed Deal relationship

--1. MQLs without closed deals (expected, but quantified)
SELECT COUNT(*) AS mqls_without_deals
FROM marketing_qualified_leads m
LEFT JOIN marketing_closed_deals c
  ON m.mql_id = c.mql_id
WHERE c.mql_id IS NULL;
