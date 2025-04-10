{{ config(materialized='table') }}

with repeated_insurance_numbers as (
    select
        insurance_number
    from {{ ref('stg_patient') }}
    where insurance_number is not null
    group by insurance_number
    having count(*) > 1
),

duplicated_patient_records as (
    select
        patient_id,
        full_name,
        birth_date,
        last_visit_date,
        gender,
        address,
        phone_number,
        email,
        insurance_number,
        marital_status,
        nationality
    from {{ ref('stg_patient') }}
    where insurance_number in (select insurance_number from repeated_insurance_numbers)
)

select
    patient_id,
    full_name,
    birth_date,
    last_visit_date,
    gender,
    address,
    phone_number,
    email,
    insurance_number,
    marital_status,
    nationality
from duplicated_patient_records