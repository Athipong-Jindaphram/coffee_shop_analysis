--Staffing Optimization (Peak Hours Analysis)

WITH rush_hour AS (
    SELECT 
        store_location,
        EXTRACT(HOUR FROM transaction_time) AS hour_only,
        COUNT(transaction_id) AS total_order,
        ROW_NUMBER() OVER (
            PARTITION BY store_location
            ORDER BY COUNT(transaction_id) DESC
        ) AS rn
    FROM coffee_sales
    GROUP BY store_location, hour_only
)

SELECT 
    store_location,
    hour_only,
    total_order
FROM rush_hour
WHERE rn <= 3
ORDER BY store_location, total_order DESC;

--Menu Rationalization (The 80/20 Revenue Rule)

SELECT product_category,
ROUND(
    SUM(total_sales::numeric),
     2
     ) as totalsales,
ROUND(
        SUM(total_sales::numeric) * 100.0 /
        SUM(SUM(total_sales::numeric)) OVER (),
        2
    ) AS revenue_percentage
FROM coffee_sales
GROUP BY product_category
ORDER BY totalsales DESC;

--Inventory & Staffing Strategy (Weekday vs. Weekend Split)

SELECT
    store_location,
    CASE
        WHEN EXTRACT(ISODOW FROM transaction_date) IN (6, 7)
            THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    ROUND(SUM(total_sales::numeric), 2) AS total_revenue,
    ROUND(AVG(total_sales::numeric), 2) AS avg_spend_per_transaction
FROM coffee_sales
GROUP BY store_location, day_type
ORDER BY store_location, day_type;

--Customer Behavior & Bundling Strategy (Basket Size)

SELECT
    product_category,
    ROUND(AVG(transaction_qty), 2) AS avg_quantity_per_order,
    ROUND(AVG(total_sales::numeric), 2) AS avg_spend_per_order
FROM coffee_sales
GROUP BY product_category
ORDER BY avg_quantity_per_order DESC;

--Deep-Dive into Best Sellers (Product Detail Level)

WITH product_rank AS (
    SELECT
        product_category,
        product_detail,
        ROUND(SUM(total_sales::numeric), 2) AS item_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY product_category
            ORDER BY SUM(total_sales) DESC
        ) AS item_rank
    FROM coffee_sales
    GROUP BY product_category, product_detail
)

SELECT
    product_category,
    product_detail,
    item_revenue,
    item_rank
FROM product_rank
WHERE item_rank <= 2
ORDER BY product_category, item_rank;