-- PROJECT 1 (Magist): ANSWERING BUSINESS QUESTIONS WITH TABLEAU (see. project description for more details)


-- 1. How many orders are there in the dataset (i.e. orders table)?
SELECT *
FROM orders;

SELECT COUNT(*) as 'Total number of orders'
FROM orders;

-- 2. Are orders actually delivered (i.e. order_status)?
# With a delivery rate above 98,7% of active or delivered orders (i.e. approved, created, processing, invoiced, shipped), and 1.2% of orders cancelled or unavailable, delivery appears to be generally reliable. 

SELECT order_status, COUNT(order_status) as 'Total number' 
FROM orders
WHERE order_status IN ('delivered', 'shipped', 'invoiced', 'processing', 'created', 'approved')
GROUP BY order_status
ORDER BY COUNT(order_status) DESC;

WITH deliveries as (
SELECT COUNT(*) as delivered_orders
,(SELECT COUNT(*) FROM orders) as total_orders
FROM orders
WHERE order_status IN ('delivered', 'shipped', 'invoiced', 'processing', 'created', 'approved')
) 
SELECT ((100/total_orders)*delivered_orders) as 'Ratio'
FROM deliveries
;


--  3) Is Magist experiencing user growth? Number of orders grouped by year and month. 
-- 	With an average monthly order growth of 23% Magist experienced a strong year in 2017. 
-- In 2018, however, order growth was stagnant at 2% up until August and then broke down almost entirely in September and October

SELECT YEAR(order_purchase_timestamp) as 'Year', COUNT(YEAR(order_purchase_timestamp)) as 'Number of Orders'
FROM orders
GROUP BY YEAR(order_purchase_timestamp);

SELECT YEAR(order_purchase_timestamp) as 'Year', MONTH(order_purchase_timestamp) as 'MONTH', COUNT(MONTH(order_purchase_timestamp)) as 'Number of Orders'
FROM orders
GROUP BY YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp);


--  4)  How many products are there on the products table (excl. duplicates)? 
-- With 32951 distinct products, Magist has a very large range of goods

SELECT COUNT(DISTINCT(product_id)) as 'Distinct product IDs'
FROM products;


-- 5) Which are the categories with the most products? 
-- The top 20, reflecting approx. 83% of the entire product range, feature three relevant product categories: computer accessories (7th, 4.97%) and telephony (10th, 3,44%), and elecronics (18th, 1.57).
-- Caution: This says nothing about their share in actual orders 

SELECT pcnt.product_category_name_english AS 'Product category', COUNT(DISTINCT(p.product_id)) AS 'Number of products'
FROM products as p
JOIN product_category_name_translation as pcnt
	ON p.product_category_name = pcnt.product_category_name
GROUP BY pcnt.product_category_name_english
-- GROUP BY product_category_name
ORDER BY COUNT(DISTINCT(product_id)) DESC;

-- 6) How many of those products were present in actual transactions? (Check products and orders_items table)

SELECT pcnt.product_category_name_english AS 'Product_Category'
	, COUNT(oi.order_id) AS 'Items_ordered'
    , ROUND((100/      
    (SELECT COUNT(*) from order_items) -- WHERE order_status IN ('delivered', 'shipped', 'invoiced', 'processing', 'created', 'approved'))
     )*COUNT(oi.order_id), 2) AS 'Percentage_Share'
 --   , (SELECT COUNT(*) FROM order_items) as 'All_items_ordered' 
 --   , ((100/All_items_ordered)*Items_ordered) as 'Percentage_share'
FROM orders as o
JOIN order_items as oi
	on o.order_id = oi.order_id
JOIN products as p
	on p.product_id = oi.product_id
JOIN product_category_name_translation as pcnt
	ON p.product_category_name = pcnt.product_category_name
-- JOIN All_items_ordered as aio
-- 	ON aio.order_id = oi.order_id
WHERE o.order_status IN ('delivered', 'shipped', 'invoiced', 'processing', 'created', 'approved')
GROUP BY pcnt.product_category_name_english
ORDER BY 2 DESC
LIMIT 20;

-- 7.) What’s the price for the most expensive and cheapest products? Basing range of prices and min and max
-- Price-category analysis of total orders: 
-- Calculating sales and average prices per product and price category yieled various interesting results.
-- Looking at the importance of highly priced tech gear (i.e. telephony, electronics, computers accessories)  
-- much seems to speak again cooperating with Magist. With 35% and 29% low and lower medium price goods under 50€ and 100€, make up 35% and 29% of total orders, respectively. 
-- As an example, sales in telephony goods are dominated by low cost (⦰27€) and lower medium cost (⦰74€) goods, ranking 2nd with 3.508 and 74th with 290 sales, respectively, out of a total of 328 price-product categories in Magist's overall orders.  
-- Telephony goods with an upper medium price (⦰309€), in contrast only rank 93th with 182 items sold. High priced telephony goods (⦰909€) rank even lower as 148th with only 75 items sold.
-- The pattern is the same for high priced computer accessories (⦰997€), which with 158 items sold rank 100th.
-- Electronics upper medium (⦰359€) price category ranks 161th with 59 items sold; eletronics with a high price (⦰1.095€) follow on rank 230 with a mere 19 sales.

-- This table is good to understand the price-category distribution of tech goods. Uncomment the second condition of the WHERE statement to see tech in relation to the whole market
SELECT 
	pcnt.product_category_name_english AS 'Product Category' -- Use the english translation of the product category
-- 	,CASE													  -- Subdivides the selection in price categories
-- 		-- WHEN oi.price <= 50 THEN 'Low'
--         -- WHEN oi.price <= 100 THEN 'Lower medium'
--         WHEN oi.price <= 250 THEN 'Low'
--         WHEN oi.price <= 750 THEN 'Medium'
--         WHEN oi.price > 750 THEN 'High'
--         ELSE 'Unknown'
-- 	END AS 'Price category'   
    , COUNT(oi.order_id) AS 'Items ordered' 					  -- Counts individual items ordered
    , ROUND((100/112101)*COUNT(oi.order_id), 2) AS 'Percentage_Share'
	, ROUND(AVG(oi.price), 0) AS 'Average price'				  -- Calculates the average price
FROM orders as o
JOIN order_items as oi										-- joins tables 
	on o.order_id = oi.order_id
JOIN products as p
	on p.product_id = oi.product_id
JOIN product_category_name_translation as pcnt
	ON p.product_category_name = pcnt.product_category_name
WHERE o.order_status 										-- ensures that item was actually part of a transaction and is a tech product
	IN ('delivered', 'shipped', 'invoiced', 'processing', 'created', 'approved') 
-- AND pcnt.product_category_name_english IN ('audio', 'cine_photo', 'computers_accessories', 'consoles_games', 'electronics', 'cds_dvds_musicals', 'dvds_blu_ray', 'pc_gamer', 'telephony', 'tablets_printing_image', 'fixed_telephony')
GROUP BY 1												-- groups by product and price category
ORDER BY 2 DESC
LIMIT 20
;											-- orders by the number of items sold


SELECT 
	pcnt.product_category_name_english AS 'Product Category', -- Use the english translation of the product category
	COUNT(oi.order_id) AS 'Items ordered', 					  -- Counts individual items ordered
	ROUND(AVG(oi.price), 0) AS 'Average price',				  -- Calculates the average price
	CASE													  -- Subdivides the selection in price categories
		WHEN pcnt.product_category_name_english LIKE '%phon%' THEN 'Tech'
        WHEN pcnt.product_category_name_english LIKE '%tablet%'  THEN 'Tech'
        WHEN pcnt.product_category_name_english LIKE '%game%'  THEN 'Tech'
        WHEN pcnt.product_category_name_english LIKE '%electronic%'  THEN 'Tech'
        WHEN pcnt.product_category_name_english LIKE '%audio%'  THEN 'Tech'
        WHEN pcnt.product_category_name_english LIKE '%dvd%'  THEN 'Tech'
	END AS 'Tech'     
FROM orders as o
JOIN order_items as oi										-- joins tables 
	on o.order_id = oi.order_id
JOIN products as p
	on p.product_id = oi.product_id
JOIN product_category_name_translation as pcnt
	ON p.product_category_name = pcnt.product_category_name
WHERE o.order_status 										-- ensures that item was actually part of a transaction
	IN ('delivered', 'shipped', 'invoiced', 'processing', 'created', 'approved') 
-- AND pcnt.product_category_name_english IN ('Tech')
GROUP BY 1, 4 												-- groups by product and price category
ORDER BY 2 DESC;											-- orders by the number of items sold




-- 2. SELECT IN SELECT: Percentage of High Tech products : how much % of total products sold are from High_Tech categories
with tech_items_Sold_q as(
select count(order_item_id) as High_Tech_Items_Sold 
        ## TODO : add the order_status condition as != cancelled
        ,(select count(order_item_id) from order_items) as All_Items_Sold
from product_category_name_translation
join products         using (product_category_name)
join order_items     using (product_id)
where product_category_name_english in  ("computers")
    and price > 500

order by price desc
)
select * , ((High_Tech_Items_Sold/All_Items_Sold)*100) as percent_High_Tech_Items_Sold
from tech_items_Sold_q;







SELECT count(order_id) AS 'Number of sales',
	CASE
		WHEN price <= 50 THEN 'Low price' -- exclude the categories
        WHEN price <= 100 THEN 'Lower medium'
        WHEN price <= 250 THEN 'Medium price'
        WHEN price <= 500 THEN 'Upper medium'
        WHEN price > 500 THEN 'High'
        ELSE 'Unknown'
	END AS price_ranges
FROM order_items
GROUP BY price_ranges
ORDER BY count(*) DESC;

SELECT MAX(price)
FROM order_items;

SELECT MIN(price)
FROM order_items;

SELECT AVG(price)
FROM order_items;

-- 8) What are the highest and lowest payment values? 
-- Some orders contain multiple products. What’s the highest someone has paid for an order? 
-- Look at the order_payments table and try to find it out.

SELECT MAX(payment_value), MIN(payment_value) 
FROM order_payments;

-- ORDER BY payment_value DESC;



-- Questions relating to sellers:
--  How many months of data included? 22 months
-- How many tech sellers (total and share of sellers)? Total amount earned by tech sellers?
-- There are 3095 total sellers, 483 of which are tech sellers (computer accessories = 287, electronics = 149, telephony = 149).
-- Average monthly income of tech sellers has varied between €75 in September 2016 and €1.924 in February 2018 in comparison to all sellers. Overall, it has been at €1.091. 
-- That contrasts with €1.044 for all sellers, where over the course of almost two years the minimu was €20 and the maximum €1.641.


SELECT YEAR(order_purchase_timestamp) AS 'Year',
	   MONTH(order_purchase_timestamp) AS 'Month', 
       -- pcnt.product_category_name_english AS 'Product category',
	   (ROUND((SUM(op.payment_value)) / COUNT(DISTINCT(oi.seller_id)),0)) AS 'Income per seller'
FROM order_items AS oi
JOIN sellers AS s
	ON s.seller_id = oi.seller_id
JOIN orders AS o
	ON o.order_id = oi.order_id
JOIN order_payments AS op
	ON op.order_id = oi.order_id
JOIN products AS p
	ON p.product_id = oi.product_id
JOIN product_category_name_translation AS pcnt
	ON p.product_category_name = pcnt.product_category_name
-- WHERE pcnt.product_category_name_english IN ('audio', 'cine_photo', 'computers', 'computers_accessories', 'consoles_games', 'electronics', 'pc_games', 'telephony')
GROUP BY 1, MONTH(o.order_purchase_timestamp);


-- This table is good to understand the price-category distribution of tech goods. Uncomment the second condition of the WHERE statement to see tech in relation to the whole market
SELECT 
	pcnt.product_category_name_english AS 'Product Category', -- Use the english translation of the product category
	COUNT(oi.order_id) AS 'Items ordered', 					  -- Counts individual items ordered
	ROUND(AVG(oi.price), 0) AS 'Average price',				  -- Calculates the average price
	CASE													  -- Subdivides the selection in price categories
		-- WHEN oi.price <= 50 THEN 'Low'
        -- WHEN oi.price <= 100 THEN 'Lower medium'
        WHEN oi.price <= 250 THEN 'Low'
        WHEN oi.price <= 750 THEN 'Medium'
        WHEN oi.price > 750 THEN 'High'
        ELSE 'Unknown'
	END AS 'Price category'     
FROM orders as o
JOIN order_items as oi										-- joins tables 
	on o.order_id = oi.order_id
JOIN products as p
	on p.product_id = oi.product_id
JOIN product_category_name_translation as pcnt
	ON p.product_category_name = pcnt.product_category_name
WHERE o.order_status 										-- ensures that item was actually part of a transaction and is a tech product
	IN ('delivered', 'shipped', 'invoiced', 'processing', 'created', 'approved') 
AND pcnt.product_category_name_english IN ('audio', 'cine_photo', 'computers_accessories', 'consoles_games', 'electronics', 'cds_dvds_musicals', 'dvds_blu_ray', 'pc_gamer', 'telephony', 'tablets_printing_image', 'fixed_telephony')
GROUP BY 1, 4 												-- groups by product and price category
ORDER BY 2 DESC;											-- orders by the number of items sold

-- DELIVERIES

-- What’s the average time between the order being placed and the product being delivered?
-- The average difference between placement and approval of order is 0.5 days. 
-- There is an average 9.3 day difference between the delivery date issued by the carrier and the customer

-- How many orders are delivered on time vs orders delivered with a delay?
-- Is there any pattern for delayed orders, e.g. big products being delayed more often?

-- 1) difference between order_purchase_timestamp and order_approved_at to understand duration of processing
-- difference between order_delivered_carrier_date and order_delivered_customer_date
-- difference between order_estimated_delivery_date and (order_approved_at - order_delivered
-- join with products via order items to fetch product dimensions

-- The average difference between placement and approval of order is 0.5 days. 
SELECT order_id, AVG(DATEDIFF(order_purchase_timestamp, order_approved_at))
FROM orders
;

-- The average estimated delivery time is 24.3 days.
SELECT order_id, AVG(DATEDIFF(order_purchase_timestamp, order_estimated_delivery_date))
FROM orders
;

-- There is an average 12.5 day difference between purchase and the carrier delivery date 
SELECT AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp))
FROM orders
;

-- There is an average 3.2 day difference between purchase and the carrier delivery date 
SELECT AVG(DATEDIFF(order_delivered_carrier_date, order_purchase_timestamp))
FROM orders
;

-- There is an average 9.3 day difference between the delivery date issued by the carrier and the customer
SELECT AVG(DATEDIFF(order_delivered_customer_date, order_delivered_carrier_date))
FROM orders
;
-- On average, it takes Magist 3.2 days to process an order and the carrier 9.3 days to deliver it, making it a total of 12.5 days between between order purchase and arrival.

-- There is an average 11.8 day difference between the estimated delivery time and the actual customer delivery date
SELECT order_id, AVG(DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date))
FROM orders
;

SELECT AVG(DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date))
FROM orders
;

SELECT 
	CASE 
		WHEN product_weight_g < 500 THEN 'Light'
        WHEN product_weight_g < 5000 THEN 'Medium'
        WHEN product_weight_g > 5000 THEN 'Heavy'
        ELSE 'Unknown'
	END AS weight_category
    , COUNT(*) 
FROM products
GROUP BY 1
ORDER BY product_weight_g DESC;


SELECT 
	CASE 
		WHEN product_length_cm < 50 THEN 'Short'
        WHEN product_length_cm < 100 THEN 'Medium'
        WHEN product_length_cm > 100 THEN 'Long'
        ELSE 'Unknown'
	END AS length_category
    , COUNT(*) 
FROM products
GROUP BY 1
ORDER BY 3 DESC;

SELECT 
	CASE 
		WHEN product_width_cm < 50 THEN 'Short'
        WHEN product_width_cm < 100 THEN 'Medium'
        WHEN product_width_cm > 100 THEN 'Long'
        ELSE 'Unknown'
	END AS width_category
    , COUNT(*) 
FROM products
GROUP BY 1
ORDER BY 2 DESC;

SELECT 
	CASE 
		WHEN product_height_cm + product_width_cm + product_length_cm  < 100 THEN 'Small'
        WHEN product_height_cm + product_width_cm + product_length_cm < 200 THEN 'Medium'
        WHEN product_height_cm + product_width_cm + product_length_cm > 200 THEN 'Large'
        ELSE 'Unknown'
	END AS size_category
    , COUNT(*) 
FROM products
GROUP BY 1
ORDER BY 2 DESC;

SELECT state, COUNT(state)
FROM geo
GROUP BY state
ORDER BY COUNT(state) DESC;

SELECT city, COUNT(city)
FROM geo
GROUP BY city
ORDER BY COUNT(city) DESC;




-- UNFINISHED BUSINESS

with delivery_time_q as
(
select 	order_status
        ,order_delivered_customer_date
        ,order_estimated_delivery_date
        ,case
            when order_delivered_customer_date <= o.order_estimated_delivery_date then "OnTime"
            else "Delayed"
            end as delivered_on_Time
from orders 
where order_status = "Delivered" and order_delivered_customer_date is not null
)
select pcnt.product_category_name_english, count(o.order_id) as delayed_deliveries
from orders AS o
JOIN order_items AS oi
	ON o.order_id = oi.order_id
JOIN products AS p
	ON p.product_id = oi.product_id
JOIN product_category_name_translation as pcnt
	ON pcnt.product_category_name = p.product_category_name
JOIN delivery_time_q AS dtq
	ON o.order_status = dtq.order_status
WHERE dtq.delivered_on_Time = "Delayed"
GROUP BY pcnt.product_category_name_english
;

-- SECOND ATTEMPT
-- First With clause

-- Second With clause subdivides the selection in price categories
WITH tech_goods_filter as  				
(
SELECT product_category_name_english,
	  CASE							  
			WHEN product_category_name_english LIKE '%phon%' THEN 'Tech'
			WHEN product_category_name_english LIKE '%tablet%'  THEN 'Tech'
			WHEN product_category_name_english LIKE '%game%'  THEN 'Tech'
			WHEN product_category_name_english LIKE '%electronic%'  THEN 'Tech'
			WHEN product_category_name_english LIKE '%audio%'  THEN 'Tech'
			WHEN product_category_name_english LIKE '%dvd%'  THEN 'Tech'
            ELSE 'Other'
	   END AS tech_goods 
--       (SELECT COUNT(order_item_id) from order_items JOIN orders using (order_id)) as all_items_sold,
--       (SELECT COUNT(order_item_id) from order_items JOIN orders using (order_id) WHERE tech_goods = 'Tech') as tech_items_sold
       FROM product_category_name_translation
       JOIN products using (product_category_name)
	   JOIN order_items using (product_id)
       JOIN orders using (order_id)
       
),

delivery_time_q as					-- WITH clause counts delayed and on time deliveries
(
select order_id
		,order_status
        ,order_delivered_customer_date
        ,order_estimated_delivery_date
        ,case
            when order_delivered_customer_date <= order_estimated_delivery_date then "OnTime"
            else "Delayed"
            end as delivered_on_Time
from orders 
where order_status = "Delivered" and order_delivered_customer_date is not null
),

  -- Third with clause counts tech items sold
ratio_tech_all_goods_delayed AS
 	(
    SELECT
		CASE
			WHEN tech_goods = 'Tech' and delivered_on_Time = 'Delayed' THEN 'delayed_tech_deliveries'
			WHEN tech_goods = 'Tech' and delivered_on_Time = 'OnTime' THEN 'ontime_tech_deliveries'
			WHEN tech_goods = 'Other' and delivered_on_Time = 'Delayed' THEN 'delayed_other_deliveries'
			WHEN tech_goods = 'Other' and delivered_on_Time = 'OnTime' THEN 'ontime_other_deliveries'
		END AS delay_category
	FROM delivery_time_q as dtq
    JOIN order_items as oi
		ON oi.order_id = dtq.order_id
    JOIN tech_goods_filter as tgf
        ON dtq.order_status = tgf.order_status
	)
-- End WITH clause, begin main query
SELECT COUNT(delay_category)
	--    , pcnt.product_category_name_english -- #1 Shows product category
 --      ,count(delivered_on_Time) as delayed_deliveries -- #2  Counts delays
      , CASE										  -- #3 Subdivides the selection in price categories
		-- WHEN oi.price <= 50 THEN 'Low'
        -- WHEN oi.price <= 100 THEN 'Lower medium'
        WHEN oi.price <= 300 THEN 'Low'
        -- WHEN oi.price <= 750 THEN 'Medium'
        WHEN oi.price > 300 THEN 'High'
        ELSE 'Unknown'
	END AS price_category
    , CASE 												-- #4 Show product weight category
		WHEN product_weight_g < 500 THEN 'Light'
        WHEN product_weight_g < 5000 THEN 'Medium'
        WHEN product_weight_g > 5000 THEN 'Heavy'
        ELSE 'Unknown'
	END AS weight_category
    , CASE 												-- # 5 Show product size category
		WHEN product_height_cm + product_width_cm + product_length_cm  < 100 THEN 'Small'
        WHEN product_height_cm + product_width_cm + product_length_cm < 200 THEN 'Medium'
        WHEN product_height_cm + product_width_cm + product_length_cm > 200 THEN 'Large'
        ELSE 'Unknown'
	END AS size_category
    -- , g.state
    , (SELECT COUNT(order_item_id) WHERE delivered_on_Time = "Delayed" AND order_status IN ('delivered', 'shipped', 'invoiced', 'processing', 'created', 'approved') AND tech_goods = 'Tech') as 'Tech delays'   
    , (SELECT COUNT(order_item_id) WHERE delivered_on_Time = "Delayed" AND order_status IN ('delivered', 'shipped', 'invoiced', 'processing', 'created', 'approved') AND tech_goods = 'Other') as 'Other delays'
   
   -- JOINS TABLES
    
from delivery_time_q as dtq
JOIN order_items as oi										
	on oi.order_id = dtq.order_id
JOIN products as p
	on p.product_id = oi.product_id
JOIN product_category_name_translation as pcnt
	ON p.product_category_name = pcnt.product_category_name
JOIN tech_goods_filter as tgf
 	on tgf.product_category_name_english = pcnt.product_category_name_english
JOIN sellers as s
	ON s.seller_id = oi.seller_id
JOIN geo as g
	on s.seller_zip_code_prefix = g.zip_code_prefix
JOIN ratio_tech_all_goods_delayed as rtagd
 	ON rtagd.tech_goods = tgf.tech_goods

-- DEFINES CONDITIONS

GROUP BY pcnt.product_category_name_english, price_category , weight_category, size_category -- , g.state
HAVING delayed_deliveries > 30
ORDER BY 2 DESC, 3
;




