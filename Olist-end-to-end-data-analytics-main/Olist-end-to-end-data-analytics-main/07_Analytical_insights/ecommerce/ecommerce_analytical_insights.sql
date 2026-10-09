/*
E-commerce Analytical Insights
Dataset: Olist Brazilian E-commerce
Purpose:
Derive customer, revenue, logistics, product, payment,
and satisfaction insights to support business decision-making.
*/


SET search_path TO ecommerce;

-- A. CUSTOMER & GEOGRAPHY ANALYSIS

-- 1. States with highest number of customers
select customer_state, count(distinct customer_unique_id) as occurrences
from olist_customers
group by customer_state
order by occurrences desc;

-- 2. Cities generating the most orders
select c.customer_city, count(o.order_id) as order_count
from olist_customers  c
join olist_orders o
    on c.customer_id = o.customer_id
group by c.customer_city 
order by order_count desc;

-- 3. Percentage of repeat customers
with order_counts as (
    select customer_unique_id, count(order_id) as order_count
    from olist_orders o
    join olist_customers c
        on c.customer_id = o.customer_id
    group by customer_unique_id	
)
select 
    round(count(case when order_count > 1 then 1 end) * 100.00 / count(*), 2) 
        as repeat_customer_percentage
from order_counts;

-- 4. Average number of orders per customer
select round(avg(order_count),2) as avg_no_of_orders
from (
    select customer_id, count(order_id) as order_count 
    from olist_orders 
    group by customer_id
) s;

-- 5. States contributing the highest revenue
select c.customer_state, sum(oi.price) as total_revenue
from olist_customers  c
join olist_orders o
    on c.customer_id = o.customer_id
join olist_order_items oi
    on o.order_id = oi.order_id
group by c.customer_state
order by total_revenue desc;

-- 6. Top 10 highest spending customers (CLV)
select c.customer_unique_id, sum(oi.price) as customer_spending
from olist_customers  c
join olist_orders o
    on c.customer_id = o.customer_id
join olist_order_items oi
    on o.order_id = oi.order_id
group by c.customer_unique_id
order by customer_spending desc
limit 10;




-- B. ORDER & LOGISTICS PERFORMANCE

-- 1. Average time from purchase to delivery
SELECT
  date_trunc('day', avg(order_delivered_customer_date - order_purchase_timestamp)) AS avg_days
FROM olist_orders;

-- 2. Difference between estimated and actual delivery
select 
    order_id, 
    order_delivered_customer_date, 
    order_estimated_delivery_date,
    (order_delivered_customer_date - order_estimated_delivery_date) as estimate_and_actual_diff
from olist_orders;

-- 3. Count of late deliveries
select count(order_id)
from olist_orders
where order_delivered_customer_date > order_estimated_delivery_date;

-- 4. Days taken from purchase -> delivery 
SELECT
    order_id,
    order_purchase_timestamp,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    (order_delivered_customer_date - order_purchase_timestamp) AS actual_delivery_days,
    (order_estimated_delivery_date - order_purchase_timestamp) AS estimated_delivery_days
FROM olist_orders
WHERE order_delivered_customer_date IS NOT NULL;

-- 5. Sellers with best delivery performance
select 
    oi.seller_id,
    date_trunc('second',
    AVG(o.order_delivered_carrier_date - o.order_approved_at)) as avg_shipping_days
from olist_orders o
join olist_order_items oi
    on o.order_id = oi.order_id
where o.order_delivered_carrier_date is not null
  and o.order_approved_at is not null
  and o.order_delivered_carrier_date >= o.order_approved_at
group by oi.seller_id
order by avg_shipping_days;

-- 6. Sellers with worst delivery delays
select 
    oi.seller_id,
    date_trunc('second',
    AVG(o.order_delivered_carrier_date - o.order_approved_at)) as avg_shipping_days
from olist_orders o
join olist_order_items oi
    on o.order_id = oi.order_id
where o.order_delivered_carrier_date is not null
  and o.order_approved_at is not null
  and o.order_delivered_carrier_date >= o.order_approved_at
group by oi.seller_id
order by avg_shipping_days desc;

-- 7. States with slowest delivery times
select 
    c.customer_state, 
    date_trunc('second', avg(o.order_delivered_customer_date - o.order_purchase_timestamp)) 
        as avg_delivery_days
from olist_customers c
left join olist_orders o
    on o.customer_id = c.customer_id
where o.order_delivered_customer_date is not null
group by c.customer_state
order by avg_delivery_days desc;

-- 8. Delivery time distribution per category
select 
    p.product_category_name,
    date_trunc('second', avg(o.order_delivered_customer_date - o.order_purchase_timestamp))
        as avg_delivery_duration
from olist_orders o
join olist_order_items oi 
    on o.order_id = oi.order_id
join olist_products p
    on p.product_id = oi.product_id
where o.order_delivered_customer_date is not null
group by p.product_category_name
order by avg_delivery_duration;




-- C. PRODUCT & CATEGORY ANALYTICS

-- 1. Units sold per category
select 
    p.product_category_name,
    pct.product_category_name_english,
    count(*) as units_sold
from olist_order_items oi
join olist_products p
    on oi.product_id = p.product_id
left join product_category_name_translation pct
    on p.product_category_name = pct.product_category_name
group by p.product_category_name, pct.product_category_name_english
order by units_sold desc;

-- 2. Revenue by category
select 
    p.product_category_name,
    pct.product_category_name_english, 
    sum(oi.price) as total_revenue
from olist_order_items oi
join olist_products p
    on oi.product_id = p.product_id
left join product_category_name_translation pct
    on p.product_category_name = pct.product_category_name
group by p.product_category_name, pct.product_category_name_english
order by total_revenue desc;

-- 3. Average price by category
select 
    p.product_category_name, 
    pct.product_category_name_english, 
    round(avg(oi.price),2) as avg_price
from olist_products p
join olist_order_items oi
    on oi.product_id = p.product_id
left join product_category_name_translation pct
    on p.product_category_name = pct.product_category_name
group by p.product_category_name, pct.product_category_name_english
order by avg_price;

-- 4. Average freight cost by category
select 
    p.product_category_name, 
    pct.product_category_name_english, 
    round(avg(freight_value),2) as avg_freight_charges
from olist_order_items oi
join olist_products p
    on oi.product_id = p.product_id
left join product_category_name_translation pct
    on p.product_category_name = pct.product_category_name
group by p.product_category_name, pct.product_category_name_english
order by avg_freight_charges desc;

-- 5. a. Correlation between weight and price
select 
    corr(p.product_weight_g, oi.price) as weight_price_correlation 
from olist_products p 
join olist_order_items oi 
    on p.product_id = oi.product_id 
where p.product_weight_g is not null
  and oi.price is not null;

-- 5. b. Weight bucket price analysis
select
    case 
        when p.product_weight_g < 500  then '0–500g'
        when p.product_weight_g < 1000 then '500–1000g'
        when p.product_weight_g < 2000 then '1000–2000g'
        when p.product_weight_g < 5000 then '2000–5000g'
        else '5000g+'
    end as weight_bucket,
    round(avg(oi.price),2) as avg_price
from olist_products p
join olist_order_items oi
    on p.product_id = oi.product_id
where p.product_weight_g is not null
group by weight_bucket
order by avg_price;

-- 6. Late delivery percentage per category
select 
    p.product_category_name, 
    pct.product_category_name_english,
    round(count(case when o.order_delivered_customer_date > o.order_estimated_delivery_date 
        then 1 end) * 100.0 / count(*),2) as late_delivery_percentage
from olist_orders o
join olist_order_items oi
    on o.order_id = oi.order_id
join olist_products p
    on p.product_id = oi.product_id
left join product_category_name_translation pct
    on p.product_category_name = pct.product_category_name
where o.order_delivered_customer_date is not null
group by p.product_category_name, pct.product_category_name_english
order by late_delivery_percentage;

-- 7. Top 10 most profitable categories
select 
    p.product_category_name, 
    pct.product_category_name_english, 
    sum(oi.price - oi.freight_value) as profit
from olist_products p
join olist_order_items oi
    on p.product_id = oi.product_id
left join product_category_name_translation pct
    on p.product_category_name = pct.product_category_name
group by p.product_category_name, pct.product_category_name_english
order by profit desc
limit 10;




-- D. PAYMENT ANALYSIS

-- 1. Most common payment types
select payment_type, count(*) as count_payment_type
from olist_order_payments
group by payment_type
order by count_payment_type desc;

-- 2. Installment ranges usage
select
    case
        when payment_installments = 1 then '1 installment'
        when payment_installments between 2 and 3 then '2–3 installments'
        when payment_installments between 4 and 6 then '4–6 installments'
        when payment_installments between 7 and 12 then '7–12 installments'
        else '13+ installments'
    end as installment_range,
    count(*) as installment_count
from olist_order_payments
group by installment_range
order by installment_count desc;

-- 3. Percentage of multiple-installment payments
select 
    round(count(case when payment_installments > 1 then 1 end) * 100.0 / count(*),2) 
        as multiple_installment_percent
from olist_order_payments;

-- 4. Revenue by payment type
select 
    op.payment_type, 
    sum(oi.price) as revenue
from olist_order_items oi
join olist_order_payments op
    on oi.order_id = op.order_id
group by op.payment_type
order by revenue desc;

-- 5. Average order value by payment type
with order_total as (
    select order_id, sum(price) as order_value
    from olist_order_items
    group by order_id
)
select 
    payment_type, 
    round(avg(order_value), 2) as avg_order_value
from order_total o
join olist_order_payments p 
    on o.order_id = p.order_id
group by payment_type
order by avg_order_value desc;




-- E. REVIEW & CUSTOMER SATISFACTION

-- 1. Average review score
select avg(review_score)
from olist_order_reviews;

-- 2. Late delivery impact on reviews
select
    case 
        when o.order_delivered_customer_date > o.order_estimated_delivery_date then 'Late Delivery'
        else 'On-Time Delivery'
    end as delivery_status,
    round(avg(r.review_score), 2) as avg_review_score
from olist_orders o
join olist_order_reviews r
    on o.order_id = r.order_id
where o.order_delivered_customer_date is not null
group by delivery_status;

-- 3. Distribution of review scores
select 
    review_score, 
    count(*) as count_review
from olist_order_reviews
group by review_score
order by review_score;

-- 4. Lowest-rated categories
select 
    p.product_category_name, 
    pct.product_category_name_english, 
    round(avg(review_score),2) as avg_review_score 
from olist_order_items oi
join olist_products p 
    on oi.product_id = p.product_id
join olist_order_reviews r
    on r.order_id = oi.order_id
left join product_category_name_translation pct
    on p.product_category_name = pct.product_category_name
group by p.product_category_name, pct.product_category_name_english
order by avg_review_score;

-- 5. a. Best-rated sellers
select 
    seller_id, 
    round(avg(review_score),2) as average_rating
from olist_order_items oi
join olist_order_reviews r
    on oi.order_id = r.order_id
group by seller_id
order by average_rating desc;

-- 5. b. Worst-rated sellers
select 
    seller_id, 
    round(avg(review_score),2) as average_rating
from olist_order_items oi
join olist_order_reviews r
    on oi.order_id = r.order_id
group by seller_id
order by average_rating asc;

-- 6. Average time to respond to reviews
select 
    date_trunc('second', avg(review_answer_timestamp - review_creation_date))  
        as avg_time_to_respond
from olist_order_reviews
where review_answer_timestamp is not null 
  and review_creation_date is not null;
