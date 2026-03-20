with source as (
    select * from {{ source('adventure_works', 'SalesOrderHeader') }}
),

renamed as (
    select
        salesorderid as sales_order_id,
        customerid as customer_id,
        totaldue as total_due,
        orderdate as order_at,
        modifieddate as modified_at
    from source
)

select * from renamed