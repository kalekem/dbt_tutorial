
{{
    config(
        materialized='incremental',
        unique_key='customer_id',
        alias = 'customers_dbt'
    )
}}

with source_data as (
    select 
        customer_id,
        first_name,
        last_name,
        email,
        signup_date,
        status,
        active,
        updated_at
    from 
        {{ source('bigquery_source', 'customers_update') }}
    {% if is_incremental() %}
    where updated_at > (select coalesce(max(updated_at),'1900-01-01') from {{ this }})
    {% endif %}
),
updates as (
    select 
        customer_id,
        first_name,
        last_name,
        email,
        signup_date,
        status,
        active,
        updated_at
    from 
        source_data
    
    {% if is_incremental() %} 
        where customer_id in (select customer_id from {{ this }})
    {% endif %}

),
inserts as (
    select 
        customer_id,
        first_name,
        last_name,
        email,
        signup_date,
        status,
        active,
        updated_at
    from 
        source_data
    where customer_id not in (select customer_id from updates )
),
final as (
    select * from updates
    union distinct
    select * from inserts
)
select 
    *
from 
    final
