#  star_schema_design.md
## Star Schema Design for Olist E-Commerce Analytics Project

### 1. Why Star Schema?
This project uses the raw Olist dataset (9 tables), which is normalized.
For analysis, dashboards, and business insights, analysts typically reorganize data into a star schema because it:
-	Makes queries faster
-	Simplifies analytics
-	Groups business entities clearly
-	Supports BI tools (Power BI / Tableau)
-	Reduces repeated joins in analysis


### 2. Star Schema Overview
The star schema for this project uses:

 **1 Fact Table**
-	Fact_Order_Items

 **8 Dimension Tables**
-	Dim_Customers
-	Dim_Products
-	Dim_Sellers
-	Dim_Orders
-	Dim_Order_Payments
-	Dim_Order_Reviews
-	Dim_Geolocation
-	Dim_Product_Category_Translation

Everything centers around Fact_Order_Items, because every transaction involves:
-	A customer
-	A product
-	A seller
-	A payment
-	A delivery
-	A review

**Why Fact_Order_Items Is the Fact Table (Not Orders)**

E-commerce analysis is done at the item level because:
- Each order can contain multiple items  
- Products have different prices, freight values, and sellers  
- Most KPIs (GMV, revenue, freight cost, top products) depend on item-level granularity  

Therefore, Fact_Order_Items is the correct fact table for retail analytics.

### 3. Fact Table Definition
  Fact: fact_order_items
  
Each row represents one product item within an order.
| Field | Description |
|-------|-------------|
| order_id | Links to order-level attributes |
| order_item_id | Item number within the order |
| customer_id | Buyer of the item |
| product_id | Product purchased |
| seller_id | Seller who shipped the item |
| price | Item price |
| freight_value | Shipping fee |
| payment_value | Payment amount associated with the order |
| review_score | Customer review rating |
| purchase_date | Order purchase date |
| delivered_date | Final delivery date |
| estimated_delivery_date | Expected delivery date |


**Fact Table Grain**  
1 row = 1 product item sold in 1 order  
Example: If an order contains 3 products, Fact_Order_Items will contain 3 rows.


**Logical SQL (not executed in database)**
   ```sql
SELECT 
      oi.order_id,
      oi.order_item_id,
      o.customer_id,
      oi.product_id,
      oi.seller_id,
      oi.price,
      oi.freight_value,
      op.payment_value,
      r.review_score,
      o.order_purchase_timestamp::date AS purchase_date,
      o.order_delivered_customer_date::date AS delivered_date,
      o.order_estimated_delivery_date::date AS estimated_delivery_date
FROM olist_order_items oi
LEFT JOIN olist_orders o ON oi.order_id = o.order_id
LEFT JOIN olist_order_payments op ON oi.order_id = op.order_id
LEFT JOIN olist_order_reviews r ON oi.order_id = r.order_id;

```

### 4. Dimension Tables

Below are the logical definitions (NOT physically created).

**Dim_Customers**

| Field                    | Description       |
| ------------------------ | ----------------- |
| customer_id              | Unique per order  |
| customer_unique_id       | Unique per person |
| customer_zip_code_prefix | ZIP prefix        |
| customer_city            | Customer city     |
| customer_state           | Customer state    |


**Dim_Products**

| Field                         | Description               |
| ----------------------------- | ------------------------- |
| product_id                    | Unique product identifier |
| product_category_name         | Category (Portuguese)     |
| product_category_name_english | Translated category       |
| product_weight_g              | Product weight            |
| product_length_cm             | Product length            |
| product_height_cm             | Product height            |
| product_width_cm              | Product width             |


**Dim_Sellers**

| Field                  | Description      |
| ---------------------- | ---------------- |
| seller_id              | Unique seller ID |
| seller_zip_code_prefix | ZIP prefix       |
| seller_city            | Seller city      |
| seller_state           | Seller state     |

**Dim_Orders**

| Field                         | Description                                      |
| ----------------------------- | ------------------------------------------------ |
| order_id                      | Unique order identifier                          |
| customer_id                   | Customer who placed the order                    |
| order_status                  | Current status (delivered / shipped / cancelled) |
| order_purchase_timestamp      | Order purchase datetime                          |
| order_approved_at             | Payment approval datetime                        |
| order_delivered_carrier_date  | Date order sent to carrier                       |
| order_delivered_customer_date | Date delivered to customer                       |
| order_estimated_delivery_date | Estimated delivery date                          |


**Dim_Order_Payments**

| Field                | Description                                |
| -------------------- | ------------------------------------------ |
| order_id             | Links to orders + fact table               |
| payment_sequential   | Payment number (1st, 2nd…)                 |
| payment_type         | Payment method (credit_card, boleto, etc.) |
| payment_installments | Number of installments                     |
| payment_value        | Payment amount                             |



**Dim_Order_Reviews**

| Field                   | Description                |
| ----------------------- | -------------------------- |
| review_id               | Unique review identifier   |
| order_id                | Order being reviewed       |
| review_score            | Rating score (1–5)         |
| review_comment_title    | Title of comment           |
| review_comment_message  | Customer’s review message  |
| review_creation_date    | When the review was posted |
| review_answer_timestamp | When seller responded      |


**Dim_Geolocation**

| Field                       | Description |
| --------------------------- | ----------- |
| geolocation_zip_code_prefix | ZIP prefix  |
| geolocation_lat             | Latitude    |
| geolocation_lng             | Longitude   |
| geolocation_city            | City        |
| geolocation_state           | State       |


**Dim_Category_Translation**

| Field                         | Description                    |
| ----------------------------- | ------------------------------ |
| product_category_name         | Original category (Portuguese) |
| product_category_name_english | Translated category (English)  |


### 5. Schema Diagram (Conceptual)

```
                 Dim_Customers
                      |
                      |
                 Dim_Orders
                      |
                      |
Dim_Products — — Fact_Order_Items — — Dim_Sellers
                      |
                      |
              Dim_Order_Payments
                      |
                      |
             Dim_Order_Reviews
                      |
                      |
              Dim_Geolocation 
                      |
                      |
          Dim_Product_Category_Translation 

```

  Legend:  
    • Fact table = center of the star  
    • Dimension tables = surrounding entities providing descriptive attributes  

This shows everything radiates from Fact_Order_Items.

Note:
Some dimensions (such as Geolocation and Category Translation)
act as supporting lookup dimensions rather than direct joins
in all analytical queries. These dimensions are used selectively
based on analysis requirements.


### 6. How This Schema Helps Analysis

This structure enables fast, simple queries like:
-	Most profitable product categories
-	Delivery time performance
-	Customer purchase behaviour
-	Seller performance ranking
-	Freight cost vs product price
-	Review score impact on repeat purchases

Structured data → faster insights → cleaner dashboards.

### 7. Why I Included the Star Schema in This Project

Even though I did not physically create the fact/dim tables in SQL, including a star schema:
-	Shows understanding of analytics modelling
-	Demonstrates ability to structure data for BI
-	Mimics how real companies organize data
-	Elevates the quality of the portfolio
-	Helps recruiters see business thinking


### 8. Conclusion
The star schema is a logical analytics foundation for this Olist dataset.
It clarifies relationships, simplifies BI development, and supports deeper business insights.
The next steps in this project will include:
-	Creating analytical SQL queries
-	Generating final insights
-	Building dashboards
-	Preparing a case study

### 9. How to Use This Schema
This star schema acts as the logical blueprint for all analysis in the project.  
Use these relationships when writing analytical SQL, building dashboards, or creating business insights.
