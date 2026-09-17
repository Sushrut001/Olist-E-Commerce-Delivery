-- ============================================
-- Olist E-Commerce: Delivery Performance & Retention Analysis
-- ============================================

-- 1. Sanity check: view sample orders with delivery dates
SELECT 
    order_id,
    order_purchase_timestamp,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM orders
WHERE order_status = 'delivered'
LIMIT 10;


-- 2. Calculate delay in days (actual delivery vs estimated delivery)
-- Positive = late, negative/zero = on time or early
SELECT 
    order_id,
    julianday(order_delivered_customer_date) - julianday(order_estimated_delivery_date) AS delay_days
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
LIMIT 10;


-- 3. Overall split: how many orders are Late vs On Time
SELECT 
    CASE 
        WHEN julianday(order_delivered_customer_date) - julianday(order_estimated_delivery_date) > 0 
        THEN 'Late' 
        ELSE 'On Time' 
    END AS delivery_status,
    COUNT(*) AS total_orders
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;


-- 4. Core finding: does late delivery affect review score?
SELECT 
    CASE 
        WHEN julianday(o.order_delivered_customer_date) - julianday(o.order_estimated_delivery_date) > 0 
        THEN 'Late' 
        ELSE 'On Time' 
    END AS delivery_status,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    COUNT(*) AS total_orders
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;


-- 5. Worst-performing sellers by late-delivery percentage
-- (minimum 20 orders, to avoid small-sample noise)
SELECT 
    oi.seller_id,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN julianday(o.order_delivered_customer_date) - julianday(o.order_estimated_delivery_date) > 0 THEN 1 ELSE 0 END) AS late_orders,
    ROUND(100.0 * SUM(CASE WHEN julianday(o.order_delivered_customer_date) - julianday(o.order_estimated_delivery_date) > 0 THEN 1 ELSE 0 END) / COUNT(*), 1) AS late_pct
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY oi.seller_id
HAVING total_orders >= 20
ORDER BY late_pct DESC
LIMIT 10;


-- 6. Repeat purchase check: top customers by order count
SELECT 
    customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY customer_unique_id
ORDER BY total_orders DESC
LIMIT 10;


-- 7. Overall repeat-purchase rate: one-time vs repeat customers
SELECT 
    CASE WHEN order_count = 1 THEN 'One-time customer' ELSE 'Repeat customer' END AS customer_type,
    COUNT(*) AS num_customers
FROM (
    SELECT customer_unique_id, COUNT(DISTINCT o.order_id) AS order_count
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY customer_unique_id
)
GROUP BY customer_type;


-- 8. Delivery delay by product category (checks if delay is category-driven or not)
SELECT 
    p.product_category_name,
    COUNT(*) AS total_orders,
    ROUND(AVG(julianday(o.order_delivered_customer_date) - julianday(o.order_estimated_delivery_date)), 1) AS avg_delay_days
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY p.product_category_name
HAVING total_orders >= 50
ORDER BY avg_delay_days DESC
LIMIT 10;