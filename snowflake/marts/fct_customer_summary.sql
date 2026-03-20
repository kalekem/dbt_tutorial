{{ config(
    description="Replaces legacy dbo.usp_GenerateCustomerSummary stored procedure."
) }}

with sales_summary as (
    -- This replaces the #CustomerSales Temp Table logic
    select 
        customer_id, 
        sum(total_due) as total_spend, 
        count(sales_order_id) as order_count
    from {{ ref('stg_sales_order_header') }}
    group by 1
),

customers as (
    select * from {{ ref('stg_customer') }}
),

people as (
    select * from {{ ref('stg_person') }}
),

final_join as (
    select 
        c.account_number,
        p.first_name,
        p.last_name,
        s.total_spend,
        s.order_count
    from sales_summary s
    join customers c on s.customer_id = c.customer_id
    join people p on c.person_id = p.business_entity_id
)

select * from final_join