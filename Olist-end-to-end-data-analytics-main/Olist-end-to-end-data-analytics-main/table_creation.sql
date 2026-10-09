
-- Table creation
CREATE TABLE olist_customers (
    customer_id varchar(50),
    customer_unique_id varchar(50),
    customer_zip_code_prefix int,
    customer_city varchar(100),
    customer_state varchar(5)
);

CREATE TABLE olist_orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE olist_order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2)
);

CREATE TABLE olist_products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

CREATE TABLE olist_sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(5)
);

CREATE TABLE olist_order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value NUMERIC(10,2)
);

CREATE TABLE olist_geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat NUMERIC(10,6),
    geolocation_lng NUMERIC(10,6),
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(5)
);

CREATE TABLE olist_order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title VARCHAR(255),
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);


CREATE TABLE product_category_name_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);

-- Data Loading

COPY olist_customers
FROM 'C:/Program Files/PostgreSQL/17/data/olist dataset/olist_customers_dataset.csv'
DELIMITER ','
CSV HEADER;

COPY olist_orders
FROM 'C:/Program Files/PostgreSQL/17/data/olist dataset/olist_orders_dataset.csv'
DELIMITER ','
CSV HEADER;

COPY olist_order_items
FROM 'C:/Program Files/PostgreSQL/17/data/olist dataset/olist_order_items_dataset.csv'
DELIMITER ','
CSV HEADER;

COPY olist_products
FROM 'C:/Program Files/PostgreSQL/17/data/olist dataset/olist_products_dataset.csv'
DELIMITER ','
CSV HEADER;

COPY olist_sellers
FROM 'C:/Program Files/PostgreSQL/17/data/olist dataset/olist_sellers_dataset.csv'
DELIMITER ','
CSV HEADER;

COPY olist_order_payments
FROM 'C:/Program Files/PostgreSQL/17/data/olist dataset/olist_order_payments_dataset.csv'
DELIMITER ','
CSV HEADER;

COPY olist_geolocation
FROM 'C:/Program Files/PostgreSQL/17/data/olist dataset/olist_geolocation_dataset.csv'
DELIMITER ','
CSV HEADER;

COPY olist_order_reviews
FROM 'C:/Program Files/PostgreSQL/17/data/olist dataset/olist_order_reviews_dataset.csv'
DELIMITER ','
CSV HEADER;

COPY product_category_name_translation
FROM 'C:/Program Files/PostgreSQL/17/data/olist dataset/product_category_name_translation.csv'
DELIMITER ','
CSV HEADER;
