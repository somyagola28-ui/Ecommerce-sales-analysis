/*
COPY commands for loading raw marketing funnel CSVs into staging tables.

These commands load raw CRM-style exports without transformations.
*/

COPY marketing.marketing_qualified_leads_staging
FROM '<PATH_TO_olist_marketing_qualified_leads_dataset.csv>'
DELIMITER ','
CSV HEADER
QUOTE '"'
ESCAPE '"';

COPY marketing.marketing_closed_deals_staging
FROM '<PATH_TO_olist_marketing_closed_deals_dataset.csv>'
DELIMITER ','
CSV HEADER
QUOTE '"'
ESCAPE '"';
