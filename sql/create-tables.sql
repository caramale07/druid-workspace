CREATE TABLE products (
    product_id BIGINT,
    product_name STRING,
    category STRING,
    price FLOAT
) PARTITIONED BY TIMESTAMP '2025-01-01 00:00:00';

CREATE TABLE customers (
    customer_id BIGINT,
    customer_name STRING,
    location STRING,
    age INT
) PARTITIONED BY TIMESTAMP '2025-01-01 00:00:00';

CREATE TABLE dates (
    date_id TIMESTAMP,
    day_name STRING,
    month_name STRING,
    year INT
) PARTITIONED BY date_id;

CREATE TABLE sales (
    sale_id BIGINT,
    product_id BIGINT,
    customer_id BIGINT,
    date_id TIMESTAMP,
    quantity INT,
    total_amount FLOAT
) PARTITIONED BY date_id;
