# marketing_schema_design.md
## Analytical Data Model for Olist Marketing Funnel

---

### 1. Why No Star Schema for Marketing Data?

Unlike transactional e-commerce data, the Olist marketing funnel dataset represents a **process flow**, not repeated transactions.

Key reasons a traditional star schema is **not appropriate** here:

- The dataset consists of **two event-level tables**
- Each row already represents a **business event**
- There is no central transactional grain like orders or order items
- Metrics are derived through **funnel relationships**, not dimensional joins

For this reason, the marketing dataset is modeled as a **logical funnel model**, not a dimensional star schema.

---

### 2. Dataset Overview

The marketing funnel analysis uses **two core tables**:

| Table | Description |
|------|-------------|
| `marketing_qualified_leads` | Captures all marketing-qualified leads (top of funnel) |
| `marketing_closed_deals` | Captures sellers that successfully converted (bottom of funnel) |

These tables are linked through the shared business key **`mql_id`**.

---

### 3. Logical Relationship Design

```
             marketing_qualified_leads
                      |
                      | (mql_id)
                      |
             marketing_closed_deals
```

**Relationship Type**
- One-to-many (1 -> *)
- One MQL may convert into **zero or one** closed deal
- Not all MQLs convert

This structure naturally supports:
- Funnel drop-off analysis
- Conversion rate calculations
- Lead source effectiveness
- Seller acquisition quality analysis

---

### 4. Table Definitions & Grain

#### marketing_qualified_leads

**Grain:**  
1 row = 1 marketing-qualified lead

| Field | Description |
|------|-------------|
| mql_id | Unique identifier for each MQL |
| first_contact_date | Date the lead first interacted |
| landing_page_id | Landing page associated with lead |
| origin | Lead acquisition source (organic, paid, etc.) |

This table represents the **top of the funnel**.

---

#### marketing_closed_deals

**Grain:**  
1 row = 1 successfully acquired seller

| Field | Description |
|------|------------|
| mql_id | Links back to the originating MQL |
| seller_id | Seller acquired through the funnel |
| business_type | Seller classification (manufacturer, reseller, etc.) |
| lead_type | Lead classification |
| has_company | Whether seller has a registered company |
| declared_monthly_revenue | Seller self-declared revenue |
| declared_product_catalog_size | Approx. number of products |
| won_date | Deal closure date |

This table represents the **bottom of the funnel**.

---

### 5. Analytical Model Pattern Used

Instead of star schema, this dataset uses a **Funnel Analytics Pattern**:

- Top of funnel -> MQL count
- Bottom of funnel -> Closed deals
- Conversion metrics calculated via **controlled joins**
- Seller quality metrics evaluated post-acquisition


---

### 6. Supported Analytical Questions

This model enables insights such as:

- How many MQLs convert into sellers?
- Which lead origins convert best?
- Which sources bring higher-value sellers?
- How does seller quality differ by business type?
- What is the revenue profile of acquired sellers?

---

### 7. Why This Design Is Intentional

This approach was chosen because it:

- Reflects **real marketing analytics workflows**
- Avoids unnecessary dimensional over-modeling
- Keeps funnel logic transparent
- Aligns with BI tool usage (Power BI)

Recruiters and analytics teams expect **funnel datasets to remain event-based**, not star-modeled.

---

### 8. How This Model Is Used in the Project

- SQL queries calculate funnel performance and quality metrics
- Power BI dashboards visualize:
  - Funnel drop-offs
  - Conversion by origin
  - Revenue quality of acquired sellers
- The model supports cross-filtering without circular dependencies

---

### 9. Conclusion

The Olist marketing dataset is best represented as a **logical funnel data model**, not a star schema.

This design:
- Preserves business meaning
- Simplifies analysis
- Demonstrates correct analytical judgment

Knowing **when not to use star schema** is as important as knowing how to design one.
