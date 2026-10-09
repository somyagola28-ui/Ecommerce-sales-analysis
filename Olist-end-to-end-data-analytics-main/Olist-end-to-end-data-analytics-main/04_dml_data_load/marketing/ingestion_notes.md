## Data Ingestion Approach

The marketing funnel datasets originate from CRM-style exports and contain
inconsistent data representations, including mixed boolean formats,
numeric values stored as text, and categorical ranges.

To ensure accurate ingestion and prevent data loss, a staged loading
approach was used:

1. Raw data was first loaded into staging tables with text-based columns.
2. Column alignment and data validity were verified.
3. Data was normalized and cast into analytical tables using controlled
   transformations.

This approach mirrors real-world analytics engineering pipelines, where
raw source data is validated before being made available for analysis.
