-- 1. Revenue Distribution by Gender
-- Purpose: Calculate the total financial contribution of male vs. female customer segments.
SELECT gender, SUM(purchase_amount) AS revenue
FROM customer
GROUP BY gender;


-- 2. High-Value Discount Users
-- Purpose: Identify customers who applied a discount but still spent above the overall average purchase value.
SELECT customer_id, purchase_amount 
FROM customer 
WHERE discount_applied = 'Yes' 
  AND purchase_amount >= (SELECT AVG(purchase_amount) FROM customer);


-- 3. Top-Rated Inventory
-- Purpose: List the top 5 products based on customer satisfaction (average review rating).
SELECT item_purchased, ROUND(AVG(review_rating::numeric), 2) AS "Average Product Rating"
FROM customer
GROUP BY item_purchased
ORDER BY AVG(review_rating) DESC
LIMIT 5;


-- 4. Shipping Logistics Comparison
-- Purpose: Analyze if there is a significant difference in average transaction value between Standard and Express shipping.
SELECT shipping_type, ROUND(AVG(purchase_amount), 2) AS avg_purchase
FROM customer
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type;


-- 5. Subscription Impact Analysis
-- Purpose: Determine if members of the subscription program yield higher average spend and total revenue compared to non-members.
SELECT subscription_status,
       COUNT(customer_id) AS total_customers,
       ROUND(AVG(purchase_amount), 2) AS avg_spend,
       ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer
GROUP BY subscription_status
ORDER BY total_revenue DESC, avg_spend DESC;


-- 6. Discount Penetration by Product
-- Purpose: Identify the top 5 products most frequently purchased using a discount code.
SELECT item_purchased,
       ROUND(100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS discount_rate
FROM customer
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;


-- 7. Customer Loyalty Segmentation
-- Purpose: Categorize the database into 'New', 'Returning', and 'Loyal' based on historical purchase frequency.
WITH customer_type AS (
    SELECT customer_id, previous_purchases,
    CASE 
        WHEN previous_purchases = 1 THEN 'New'
        WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
        ELSE 'Loyal'
    END AS customer_segment
    FROM customer
)
SELECT customer_segment, COUNT(*) AS "Number of Customers" 
FROM customer_type 
GROUP BY customer_segment;


-- 8. Top Products per Category
-- Purpose: Use window functions to rank and retrieve the 3 most popular items within every product category.
WITH item_counts AS (
    SELECT category,
           item_purchased,
           COUNT(customer_id) AS total_orders,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT item_rank, category, item_purchased, total_orders
FROM item_counts
WHERE item_rank <= 3;


-- 9. Repeat Buyer Conversion to Subscriptions
-- Purpose: Evaluate the correlation between high purchase frequency (5+ orders) and subscription program enrollment.
SELECT subscription_status,
       COUNT(customer_id) AS repeat_buyers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;


-- 10. Demographic Revenue Contribution (Age Groups)
-- Purpose: Analyze which age groups generate the highest total revenue for the business.
SELECT 
    age_group,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC;