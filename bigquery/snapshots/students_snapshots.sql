{% snapshot students_hist %}

    {{
        config(
            target_schema ='dbt_dataset',
            unique_key = 'student_id',
            strategy = 'check',
            check_cols = 'all'
        )
    }}

    select 
        *
    from 
        {{ ref('students_prepared') }}

{% endsnapshot %}