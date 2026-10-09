/*
COPY commands for loading Olist e-commerce datasets into analytical tables.

These commands load raw CSV files into the ecommerce schema tables.
Update local file paths before execution.
*/

COPY ecommerce.olist_customers
FROM '<PATH_TO_olist_customers_dataset.csv>'
DELIMITER ','
CSV HEADER;

COPY ecommerce.olist_orders
FROM '<PATH_TO_olist_orders_dataset.csv>'
DELIMITER ','
CSV HEADER;

COPY ecommerce.olist_order_items
FROM '<PATH_TO_olist_order_items_dataset.csv>'
DELIMITER ','
CSV HEADER;

COPY ecommerce.olist_products
FROM '<PATH_TO_olist_products_dataset.csv>'
DELIMITER ','
CSV HEADER;

COPY ecommerce.olist_sellers
FROM '<PATH_TO_olist_sellers_dataset.csv>'
DELIMITER ','
CSV HEADER;

COPY ecommerce.olist_order_payments
FROM '<PATH_TO_olist_order_payments_dataset.csv>'
DELIMITER ','
CSV HEADER;

COPY ecommerce.olist_geolocation
FROM '<PATH_TO_olist_geolocation_dataset.csv>'
DELIMITER ','
CSV HEADER;

COPY ecommerce.olist_order_reviews
FROM '<PATH_TO_olist_order_reviews_dataset.csv>'
DELIMITER ','
CSV HEADER;

COPY ecommerce.product_category_name_translation
FROM '<PATH_TO_product_category_name_translation.csv>'
DELIMITER ','
CSV HEADER;
