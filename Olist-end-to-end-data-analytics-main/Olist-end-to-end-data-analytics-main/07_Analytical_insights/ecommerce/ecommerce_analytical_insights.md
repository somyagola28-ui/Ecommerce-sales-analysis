
# Ecommerce Analytical Insights
## Olist Brazilian E-Commerce Dataset - SQL Analysis

This document presents the business analysis and analytical insights derived from the Olist Brazilian E-commerce dataset.
The analysis is performed after data quality validation and star schema modeling, with each section answering a concrete
business question using SQL.


### How to read this analysis

Each section answers a specific business question using SQL.
The queries are written for analytical exploration, not data cleaning.
All metrics are derived from validated analytical tables following a star schema design.


## A. Customer & Geography Analysis

### 1. Which states have the highest number of customers?
Understanding customer distribution helps identify high-demand regions and target markets.
This query counts distinct customers per state and ranks states based on customer volume.
```
select customer_state, count(distinct customer_unique_id) as occurrences
from olist_customers
group by customer_state
order by occurrences desc;
```

### 2. Which cities generate the most orders?

This helps determine which cities drive the most sales, useful for logistics and regional marketing.
The query joins customers with orders and aggregates order counts by city.
```
select c.customer_city, count(o.order_id) as order_count
from olist_customers  c
join olist_orders o
    on c.customer_id = o.customer_id
group by c.customer_city 
order by order_count desc;
```

### 3. What % of customers return for repeat purchases?

Repeat customers are crucial for long-term revenue.
This query identifies how many unique customers placed more than one order and calculates their percentage.
```
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
```

### 4. What is the average number of orders per customer?

This metric helps estimate customer purchasing behavior and engagement.
The query calculates the average number of orders grouped by customer.
```
select round(avg(order_count), 2) as avg_no_of_orders
from (
    select customer_id, count(order_id) as order_count 
    from olist_orders 
    group by customer_id
) s;
```

### 5. Which states contribute the highest revenue?

Identifying revenue-heavy regions helps prioritize supply chain and delivery resources.
The query aggregates total item prices across orders by customer state.
```
select c.customer_state, sum(oi.price) as total_revenue
from olist_customers  c
join olist_orders o
    on c.customer_id = o.customer_id
join olist_order_items oi
    on o.order_id = oi.order_id
group by c.customer_state
order by total_revenue desc;
```

### 6. Top 10 highest spending customers (Customer Lifetime Value)

CLV helps businesses understand their most valuable customers.
This query sums total spending per customer and returns the top 10.
```
select c.customer_unique_id, sum(oi.price) as customer_spending
from olist_customers  c
join olist_orders o
    on c.customer_id = o.customer_id
join olist_order_items oi
    on o.order_id = oi.order_id
group by c.customer_unique_id
order by customer_spending desc
limit 10;
```

## B. Order & Logistics Performance

### 1. What is the average time from purchase to delivery?

Delivery time is a key metric for logistics efficiency.
This query computes the average duration between order placement and delivery.
```
select 
    date_trunc('day', avg(order_delivered_customer_date - order_purchase_timestamp)) as avg_days
from olist_orders;
```

### 2. What is the difference between estimated and actual delivery?
This helps measure delivery accuracy and customer experience.
The query returns delays or early deliveries for every order.
```
select 
    order_id, 
    order_delivered_customer_date, 
    order_estimated_delivery_date,
    (order_delivered_customer_date - order_estimated_delivery_date) as estimate_and_actual_diff
from olist_orders;
```

### 3. How many orders were delivered late?
Late deliveries directly impact customer satisfaction.
This query counts all orders delivered after the estimated delivery date.
```
select count(order_id)
from olist_orders
where order_delivered_customer_date > order_estimated_delivery_date;
```

### 4. How long do deliveries actually take vs estimates?

This query prepares delivery duration metrics used for SLA and delay analysis.
It computes actual delivery days and compares them with estimated delivery timelines.
```
select
    order_id,
    order_purchase_timestamp,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    (order_delivered_customer_date - order_purchase_timestamp) as actual_delivery_days,
    (order_estimated_delivery_date - order_purchase_timestamp) as estimated_delivery_days
from olist_orders
where order_delivered_customer_date is not null;
```

### 5. Which sellers have the best delivery performance?
This identifies sellers who ship quickly, helping improve marketplace quality.
The query calculates average shipping time between approval and carrier pickup.
```
select 
    oi.seller_id,
    date_trunc('second', avg(o.order_delivered_carrier_date - o.order_approved_at)) as avg_shipping_days
from olist_orders o
join olist_order_items oi
    on o.order_id = oi.order_id
where o.order_delivered_carrier_date is not null
  and o.order_approved_at is not null
  and o.order_delivered_carrier_date >= o.order_approved_at
group by oi.seller_id
order by avg_shipping_days;
```

### 6. Which sellers have the worst delivery delays?
Slow sellers impact overall marketplace ratings and logistics cost.
This query lists sellers with the longest average shipping duration.
```
select 
    oi.seller_id,
    date_trunc('second', avg(o.order_delivered_carrier_date - o.order_approved_at)) as avg_shipping_days
from olist_orders o
join olist_order_items oi
    on o.order_id = oi.order_id
where o.order_delivered_carrier_date is not null
  and o.order_approved_at is not null
  and o.order_delivered_carrier_date >= o.order_approved_at
group by oi.seller_id
order by avg_shipping_days desc;
```

### 7. Which states experience the slowest deliveries?
Delivery time varies by geography due to distance and logistics capacity.
This query calculates average delivery times per state.
```
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
```

### 8. What is the distribution of delivery times per category?
Some product types take longer to prepare or ship.
This query analyzes delivery speed across product categories.
```
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
```

## C. Product & Category Analytics

### 1. Which product categories sell the most units?

Understanding unit sales by category helps businesses identify popular product segments.
This query counts the number of items sold per category and ranks them from highest to lowest.
```
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
```

### 2. Which categories generate the highest revenue?

Revenue contribution per category helps identify top-performing product types.
This query sums item prices to determine total revenue by product category.
```
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
```
### 3. What is the average price by category?

Average price analysis helps identify premium vs. budget categories.
This query calculates the mean selling price for each product category.
```
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
````

### 4. Which category has the highest freight charges?

Freight cost insights help evaluate logistics expenses across categories.
This query computes the average freight value per category.
```
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
```

### 5. Are heavier items more expensive?

This helps determine whether product weight influences pricing.
The query uses PostgreSQL’s corr() function to calculate weight–price correlation.
```
select 
    corr(p.product_weight_g, oi.price) as weight_price_correlation 
from olist_products p 
join olist_order_items oi 
    on p.product_id = oi.product_id 
where p.product_weight_g is not null
  and oi.price is not null;
```

Bucket-based view of weight vs price.
This provides a clearer trend by grouping products into weight ranges.
```
select
    case 
        when p.product_weight_g < 500  then '0–500g'
        when p.product_weight_g < 1000 then '500–1000g'
        when p.product_weight_g < 2000 then '1000–2000g'
        when p.product_weight_g < 5000 then '2000–5000g'
        else '5000g+'
    end as weight_bucket,
    round(avg(oi.price), 2) as avg_price
from olist_products p
join olist_order_items oi
    on p.product_id = oi.product_id
where p.product_weight_g is not null
group by weight_bucket
order by avg_price;
```

###  6. Which categories have the highest late delivery percentage?

Late delivery trends by category help identify supply chain bottlenecks.
This query calculates the share of late orders for each product category.
```
select 
    p.product_category_name, 
    pct.product_category_name_english,
    round(count(case when o.order_delivered_customer_date > o.order_estimated_delivery_date 
        then 1 end) * 100.0 / count(*), 2) as late_delivery_percentage
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
```

### 7. Top 10 most profitable categories

Profitability gives a true measure of business value after deducting logistics costs.
This query computes profit = price – freight and returns the top 10 categories.
```
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
```


## D. Payment Analysis

### 1. What are the most common payment types?

This helps understand customer preferences in payment methods.
The query counts how often each payment type is used.
```
select payment_type, count(*) as count_payment_type
from olist_order_payments
group by payment_type
order by count_payment_type desc;
```

### 2. Which payment installment ranges are most used?

Installment behavior is important for financial planning and fraud prevention.
This query groups installment counts into meaningful ranges.
```
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
```

### 3. What % of orders are paid using multiple installments?

This indicates how often customers rely on credit-based payments.
The query calculates the percentage of orders with more than one installment.
```
select 
    round(count(case when payment_installments > 1 then 1 end) * 100.0 / count(*), 2) 
        as multiple_installment_percent
from olist_order_payments;
```

### 4. How much revenue comes from different payment types?

This helps identify which payment channels contribute the most sales.
The query sums revenue associated with each payment method.
```
select 
    op.payment_type, 
    sum(oi.price) as revenue
from olist_order_items oi
join olist_order_payments op
    on oi.order_id = op.order_id
group by op.payment_type
order by revenue desc;
```

### 5. Average order value by payment type

Customers using certain payment methods (like credit cards) may have higher order values.
This query calculates the mean order total grouped by payment type.
```
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
```

## E. Review & Customer Satisfaction

### 1. What is the average review score?

This is a baseline indicator for overall customer satisfaction.
The query computes the average star rating across all reviews.
```
select avg(review_score)
from olist_order_reviews;
```

### 2. Do late deliveries lead to lower review scores?

Delivery delays often reduce customer satisfaction.
This query compares average review scores between late and on-time orders.
```
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
```

### 3. What is the distribution of review scores?

Score distribution reveals how polarized customer feedback is.
This query counts reviews for each rating level (1–5).
```
select 
    review_score, 
    count(*) as count_review
from olist_order_reviews
group by review_score
order by review_score;
```

### 4. Which categories receive the lowest ratings?

Low-rated categories may suffer from quality issues or misleading listings.
This query finds categories with the poorest average review scores.
```
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
```

### 5. Which sellers receive the best and worst ratings?

Seller performance impacts customer trust and marketplace reputation.
These queries compute average ratings per seller.

#### Best-rated sellers
```
select 
    seller_id, 
    round(avg(review_score),2) as average_rating
from olist_order_items oi
join olist_order_reviews r
    on oi.order_id = r.order_id
group by seller_id
order by average_rating desc;
```
#### Worst-rated sellers
```
select 
    seller_id, 
    round(avg(review_score),2) as average_rating
from olist_order_items oi
join olist_order_reviews r
    on oi.order_id = r.order_id
group by seller_id
order by average_rating asc;
```

### 6. How long do customers take to respond with reviews?

Review response time reflects how quickly customers engage post-delivery.
This query computes the average time between review creation and answer timestamp.
```
select 
    date_trunc('second', avg(review_answer_timestamp - review_creation_date))
        as avg_time_to_respond
from olist_order_reviews
where review_answer_timestamp is not null 
  and review_creation_date is not null;
```
