/*
Staging tables for raw marketing funnel data ingestion.

These tables store raw CRM-style exports with minimal typing
to allow controlled normalization into analytical tables.
*/

CREATE TABLE IF NOT EXISTS marketing.marketing_qualified_leads_staging (
    mql_id TEXT,
    first_contact_date TEXT,
    landing_page_id TEXT,
    origin TEXT
);

CREATE TABLE IF NOT EXISTS marketing.marketing_closed_deals_staging (
    mql_id TEXT,
    seller_id TEXT,
    sdr_id TEXT,
    sr_id TEXT,
    won_date TEXT,
    business_segment TEXT,
    business_type TEXT,
    lead_type TEXT,
    lead_behaviour_profile TEXT,
    has_company TEXT,
    has_gtin TEXT,
    average_stock TEXT,
    declared_product_catalog_size TEXT,
    declared_monthly_revenue TEXT
);
