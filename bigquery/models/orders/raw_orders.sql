
{{
    config(
        alias ='transformed_orders',
        materialized = 'table'
    )
}}

WITH prepared AS (
    SELECT
        order_id,
        DATE(order_date) AS order_date,
        customer_name,
        order_amount,
        order_status,
        ROUND(order_amount * 0.1, 2) AS tax_amount, -- 10% of order_amount for tax
        CASE
            WHEN order_status = "Shipped" THEN "Completed"
            ELSE "Pending"
        END AS final_status -- Completed for shipped orders and Pending
    FROM
        {{ source('orders_tbl', 'raw_orders') }}

    ORDER BY
        1
)
SELECT
    *
FROM 
    prepared