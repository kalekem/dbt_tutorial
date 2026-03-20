
{{
    config(
        materialized='incremental',
        unique_key='OrderId',
        alias = 'orders'
    )
}}

with incremental_data as (
    select
        *
    from
        {{ ref('stg_orders') }}

    {% if is_incremental() %}
    
  -- this filter will only be applied on an incremental run
  -- (uses >= to include records whose timestamp occurred since the last run of this model)
  -- (If ChangeTime is NULL or the table is truncated, the condition will always be true and load all records)
    where ChangeTime > (select coalesce(max(ChangeTime),'1900-01-01') from {{ this }} )

    {% endif %}
)
, final as (
    select distinct
        OrderId,
        CustomerId,
        OrderDate,
        OrderStatus,
        ProductId,
        QuantityOrdered,
        Price,
        TotalAmount,
        ChangeTime,
        '{{ invocation_id }}' as batch_id
    from 
        incremental_data
)
select 
    *
from 
    final



