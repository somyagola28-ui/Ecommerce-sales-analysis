/*
Marketing funnel tables for seller acquisition analytics.

These tables represent the cleaned analytical layer derived from
CRM-style marketing data and are used to analyze seller onboarding,
conversion, and acquisition quality.

Source: Olist Marketing Funnel Dataset (Kaggle)
*/


CREATE SCHEMA IF NOT EXISTS marketing;

CREATE TABLE IF NOT EXISTS marketing.marketing_qualified_leads (
    mql_id TEXT PRIMARY KEY,
    first_contact_date DATE,
    landing_page_id TEXT,
    origin TEXT
);

CREATE TABLE IF NOT EXISTS marketing.marketing_closed_deals (
    mql_id TEXT PRIMARY KEY,
    seller_id TEXT,
    sdr_id TEXT,
    sr_id TEXT,
    won_date DATE,
    business_segment TEXT,
    business_type TEXT,
    lead_type TEXT,
    lead_behaviour_profile TEXT,
    has_company BOOLEAN,
    has_gtin BOOLEAN,
    average_stock TEXT,
    declared_product_catalog_size NUMERIC,
    declared_monthly_revenue NUMERIC,
    FOREIGN KEY (mql_id) REFERENCES marketing.marketing_qualified_leads(mql_id),
    FOREIGN KEY (seller_id) REFERENCES ecommerce.olist_sellers(seller_id)
);
