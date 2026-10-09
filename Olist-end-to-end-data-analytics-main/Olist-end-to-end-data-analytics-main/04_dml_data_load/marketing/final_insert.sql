/*
Normalize and load marketing funnel data from staging into analytical tables.
*/

INSERT INTO marketing.marketing_qualified_leads (
    mql_id,
    first_contact_date,
    landing_page_id,
    origin
)
SELECT
    mql_id,
    first_contact_date::DATE,
    landing_page_id,
    origin
FROM marketing.marketing_qualified_leads_staging;


INSERT INTO marketing.marketing_closed_deals (
    mql_id,
    seller_id,
    sdr_id,
    sr_id,
    won_date,
    business_segment,
    business_type,
    lead_type,
    lead_behaviour_profile,
    has_company,
    has_gtin,
    average_stock,
    declared_product_catalog_size,
    declared_monthly_revenue
)
SELECT
    mql_id,
    seller_id,
    sdr_id,
    sr_id,
    won_date::DATE,
    business_segment,
    business_type,
    lead_type,
    lead_behaviour_profile,

    CASE
        WHEN LOWER(has_company) IN ('true', 'yes', '1') THEN TRUE
        WHEN LOWER(has_company) IN ('false', 'no', '0') THEN FALSE
        ELSE NULL
    END AS has_company,

    CASE
        WHEN LOWER(has_gtin) IN ('true', 'yes', '1') THEN TRUE
        WHEN LOWER(has_gtin) IN ('false', 'no', '0') THEN FALSE
        ELSE NULL
    END AS has_gtin,

    average_stock,
    NULLIF(declared_product_catalog_size, '')::NUMERIC,
    NULLIF(declared_monthly_revenue, '')::NUMERIC
FROM marketing.marketing_closed_deals_staging;
