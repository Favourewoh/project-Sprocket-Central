--
--
--The queries below provide results to question asked regarding the sprocket central
--transaction data for the year of 2017 in order to understand the data and draw insights for possible
-- decision making
--

--1. WHAT IS THE TOTAL NUMBER OF TRANSACTIONS FOR THE PERIOD?

SELECT  
    COUNT(*) AS Total_transactions,
    SUM(CASE WHEN order_status = 'Approved' THEN 1 ELSE 0 END) AS Approved_count,
    SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled_count,
    SUM(CASE WHEN online_order = 1 THEN 1 ELSE 0 END) AS online_orders,
    SUM(CASE WHEN online_order = 0 THEN 1 ELSE 0 END) AS store_orders
FROM kpmg.Transactions

-- the results showed that out of the 19445 transactions initiated, 19273 transactions
-- were approved and 172 where cancelled. We had 9739 online orders and 9706 store purchases.


--2. WHAT IS THE AVERAGE TRANSACTION VALUE?

SELECT 
    ROUND(SUM(list_price)/COUNT(*),2) AS Avg_transaction_value
FROM kpmg.Transactions
WHERE order_status='approved'

-- The average transaction value for the period is $1107.06

--3. WHAT IS THE TOTAL REVENUE GAINED AND COGS?

SELECT  
    SUM(list_price) AS Revenue_gained,
    SUM(standard_cost) AS COGS
FROM kpmg.Transactions
WHERE order_status = 'approved'

-- Revenue gained for the year summed up to $21,336,409.64, with of cost of goods sold summing up to $10,703,760.77

--4. LOOKING AT OUR GROSS PROFIT AND GROSS MARGIN

SELECT 
    ROUND(SUM(list_price)-SUM(standard_cost),2) AS Gross_profit,
    ROUND((SUM(list_price)-SUM(standard_cost))/SUM(list_price),3) AS Gross_margin
FROM kpmg.Transactions
WHERE order_status = 'Approved'

-- the gross profit amounted to $10,632,648.86 and our gross margin being 49.8%

-- 5. LOOKING AT THE REVENUE GROWTH BY MONTH

-- first we create a view holding our revenue by month

CREATE VIEW kpmg.sale_month AS

SELECT Month_id, SUM(list_price) Revenue
FROM (SELECT 
        * ,
        YEAR(transaction_date) Year_id, 
        MONTH(transaction_date) Month_id
    FROM kpmg.Transactions
    GROUP BY transaction_id,product_id,customer_id,transaction_date,
    online_order,order_status,brand,product_line,product_class,product_size,
    list_price,standard_cost,product_first_sold_date) sales
WHERE order_status = 'Approved'
GROUP BY Month_id

-- Next we use derive our revenue growth in cash and percentage.

SELECT
    Month_id,
    Revenue,
    Revenue-LAG(Revenue) OVER (ORDER BY Month_id ASC) AS Revenue_growth,
    ROUND(((Revenue-LAG(Revenue) OVER (ORDER BY Month_id ASC))/LAG(Revenue) OVER (ORDER BY Month_id ASC))*100,2) AS growth_percentage
FROM kpmg.sale_month

-- results shows that October, July, and May had the best growth. September, November,
-- and June had worst growth.

-- NEXT LOOK AT THE PRODUCT PERFORMANCE

--6. LOOKING AT THE PERFORMANCE OF EACH PRODUCT LINE

SELECT 
    product_line, 
    COUNT(*) AS No_of_purchase,
    SUM(list_price) Revenue
FROM kpmg.Transactions
WHERE order_status = 'Approved'
GROUP BY product_line
ORDER BY 3 DESC

-- The result show that the standard product line has the most quantity sold and revenue generated
-- with the Road product line coming in second.

-- LET'S BREAK THIS DOWN TO LOCATIONS

SELECT 
    [state] ,
    product_line,
    COUNT(product_line) AS no_of_purchases
FROM kpmg.Transactions T
JOIN kpmg.CustomerAddress CA
ON T.customer_id=CA.customer_id
WHERE order_status = 'Approved'
GROUP BY [state], product_line
ORDER BY 1,3 DESC

-- the standard product line performed best on all three states followed by the Road product line
-- the mountain and touring product line has the least performance on all locations


--7. FINALLY, WE WILL LOOK AT THE BRAND PERFORMANCE

SELECT 
    brand, 
    COUNT(*) AS no_of_purchases,
    SUM(list_price) Revenue
FROM kpmg.Transactions
WHERE order_status = 'Approved'
GROUP BY brand
ORDER BY 3 DESC

-- Solex is the most purchased brand from the company's stock with 4128 purchases for the year
-- WeareA2B and Giant Bicycles are basically tied at second most purchased brands.

--DRILLING DOWN TO THE LOCATIONS

SELECT 
    [state] ,
    brand,
    COUNT(brand) no_of_purchases
FROM kpmg.Transactions T
JOIN kpmg.CustomerAddress CA
ON T.customer_id=CA.customer_id
WHERE order_status = 'Approved'
GROUP BY [state], brand
ORDER BY 1,3 DESC

-- solex is the most purchased brand on all states
-- It can be seen that Trek bicycles have a greater customer likeability in the state of Victoria
-- in comparison with other state, this may be due to possible new customer preference in the state or other factors.

--THIS ENDS OUR ANALYSIS


--THANK YOU!!!