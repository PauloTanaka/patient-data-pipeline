-- models/quality/possible_duplicate_patients.sql
with base as (

    select
        insurance_number,
        full_name,
        birth_date,
        gender,
        --count(*) over (partition by insurance_number) as cnt,
        row_number() over (partition by insurance_number order by full_name) as row_num
    from {{ ref('stg_patient') }}
    where insurance_number is not null

),

candidates as (

    select
        a.insurance_number,
        a.full_name as full_name_1,
        b.full_name as full_name_2,
        a.birth_date,
        a.gender
    from base a
    join base b
        on a.insurance_number = b.insurance_number
       and a.full_name <> b.full_name
       and levenshtein(lower(a.full_name), lower(b.full_name)) <= 2  -- similar names
       and a.row_num < b.row_num
)

select * from candidates