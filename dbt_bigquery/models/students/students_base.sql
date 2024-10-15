{{
    config(
        unique_key = 'student_id'
    )
}}

select distinct 
    student_id,
    student_age,
    first_name,
    last_name,
    major,
    event_time,
    case when dbt_valid_to is null then TIMESTAMP('2999-12-31') else dbt_valid_to end as dteEndDte

from 
    {{ ref('students_hist') }}
{% if is_incremental %}

where 1=1
    and dbt_valid_to is null --only bring in new or changed/updated records
    -- and event_time >= (select coalesce(max(event_time),TIMESTAMP('1900-01-01')) from {{ this }} )

{% endif %}