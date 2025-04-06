-- models/quality/invalid_patients.sql
with stg as (
    select * from {{ ref('stg_patient') }}
),

invalids as (
    select *
    from stg
    where not is_valid_email
       or not has_valid_birth_date
       or not has_valid_visit_date
       or not is_valid_state
)

select * from invalids
