
{{
    config(
        materialized='ephemeral',
    )
}}

with source_data as (
    select
        to_varchar(order_id) as OrderId,
        to_varchar(customer_id) as CustomerId,
        to_varchar(order_date) as OrderDate,
        to_varchar(status) as OrderStatus,
        to_varchar(product_id) as ProductId,
        to_numeric(quantity) as QuantityOrdered,
        to_numeric(price) as price,
        to_double(total_amount) as TotalAmount,
        to_timestamp(SUBSTR(cdc_timestamp,1,19), 'YYYY-MM-DD HH24:MI:SS') as ChangeTime
    from
        {{ source('snowflake_source', 'orders') }}
)
select 
    *
from 
    source_data

