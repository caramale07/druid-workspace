-- Total Sales by Product
SELECT
    p.product_name,
    p.category,
    SUM(s.total_amount) AS total_sales,
    SUM(s.quantity) AS total_quantity_sold,
    AVG(s.total_amount) AS avg_sale_amount
FROM
    products p
JOIN
    sales s ON p.product_id = s.product_id
GROUP BY
    p.product_name, p.category
ORDER BY
    total_sales DESC;

-- Top 5 customers by total spent
SELECT
    c.customer_name,
    c.location,
    SUM(s.total_amount) AS total_spent,
    COUNT(s.sale_id) AS total_purchases
FROM
    customers c
JOIN
    sales s ON c.customer_id = s.customer_id
GROUP BY
    c.customer_name, c.location
ORDER BY
    total_spent DESC
LIMIT 5;

-- Sales Trend Over Time
SELECT
    d.year,
    d.month_name,
    SUM(s.total_amount) AS total_sales
FROM
    sales s
JOIN
    dates d ON s.date_id = d.date_id
GROUP BY
    d.year, d.month_name
ORDER BY
    d.year, d.month_name;

-- Top Selling Product by Category
WITH ProductSales AS (
    SELECT
        p.category,
        p.product_name,
        SUM(s.total_amount) AS total_sales
    FROM
        products p
    JOIN
        sales s ON p.product_id = s.product_id
    GROUP BY
        p.category, p.product_name
)
SELECT
    category,
    product_name,
    total_sales
FROM
    (
        SELECT
            category,
            product_name,
            total_sales,
            ROW_NUMBER() OVER (PARTITION BY category ORDER BY total_sales DESC) AS rank
        FROM
            ProductSales
    )
WHERE rank = 1;

-- Customer age group analaysis
SELECT
    CASE
        WHEN c.age BETWEEN 18 AND 25 THEN '18-25'
        WHEN c.age BETWEEN 26 AND 35 THEN '26-35'
        WHEN c.age BETWEEN 36 AND 50 THEN '36-50'
        WHEN c.age > 50 THEN '50+'
    END AS age_group,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    SUM(s.total_amount) AS total_spent
FROM
    customers c
JOIN
    sales s ON c.customer_id = s.customer_id
GROUP BY
    age_group
ORDER BY
    total_spent DESC;

-- Percentage Contribution of each category
SELECT
    p.category,
    SUM(s.total_amount) AS category_sales,
    (SUM(s.total_amount) / SUM(SUM(s.total_amount)) OVER()) * 100 AS percentage_of_total
FROM
    products p
JOIN
    sales s ON p.product_id = s.product_id
GROUP BY
    p.category
ORDER BY
    category_sales DESC;

-- Daily Sales with Cumulative Total
SELECT
    d.date_id,
    SUM(s.total_amount) AS daily_sales,
    SUM(SUM(s.total_amount)) OVER (ORDER BY d.date_id) AS cumulative_sales
FROM
    sales s
JOIN
    dates d ON s.date_id = d.date_id
GROUP BY
    d.date_id
ORDER BY
    d.date_id;


-- Products Never Sold
SELECT
    p.product_id,
    p.product_name,
    p.category
FROM
    products p
LEFT JOIN
    sales s ON p.product_id = s.product_id
WHERE
    s.sale_id IS NULL;

-- Customers Who Purchased All Product Categories

WITH Categories AS (
    SELECT DISTINCT category FROM products
),
CustomerCategories AS (
    SELECT
        c.customer_id,
        p.category
    FROM
        customers c
    JOIN
        sales s ON c.customer_id = s.customer_id
    JOIN
        products p ON s.product_id = p.product_id
    GROUP BY
        c.customer_id, p.category
)
SELECT
    customer_id
FROM
    CustomerCategories
GROUP BY
    customer_id
HAVING
    COUNT(DISTINCT category) = (SELECT COUNT(*) FROM Categories);

-- Average Sales by Day of the Week
SELECT
    d.day_name,
    AVG(s.total_amount) AS avg_sales
FROM
    sales s
JOIN
    dates d ON s.date_id = d.date_id
GROUP BY
    d.day_name
ORDER BY
    FIELD(d.day_name, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');


SELECT
    age_group,
    HLL_COUNT.DISTINCT(customer_id) AS total_customers,
    total_spent
FROM (
    SELECT
        CASE
            WHEN c.age BETWEEN 18 AND 25 THEN '18-25'
            WHEN c.age BETWEEN 26 AND 35 THEN '26-35'
            WHEN c.age BETWEEN 36 AND 50 THEN '36-50'
            WHEN c.age > 50 THEN '50+'
        END AS age_group,
        c.customer_id,
        SUM(s.total_amount) AS total_spent
    FROM customers c
    JOIN "sales_transactions_1m" s ON c.customer_id = s.customer_id
    GROUP BY age_group, c.customer_id
) subquery
GROUP BY age_group
ORDER BY total_spent DESC;
