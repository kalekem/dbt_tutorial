with prepared as (
    select 
        id as student_id,
        age as student_age,
        fname as first_name,
        lname as last_name,
        major,
        event_time

    from 
        {{ source('students', 'students_raw') }}
)
select 
    *
from 
    prepared