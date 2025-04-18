{{ config(materialized='table') }}
with raw_patient_data_from_source as (

    select
        id,
        first_name,
        last_name,
        birth_date,
        gender,
        address,
        city,
        state,
        zip_code,
        phone_number,
        email,
        emergency_contact_name,
        emergency_contact_phone,
        blood_type,
        insurance_provider,
        insurance_number,
        marital_status,
        preferred_language,
        nationality,
        allergies,
        last_visit_date
    from {{ source('staging', 'raw_patient') }}

),

renamed_and_normalized_patient_fields_with_flags as (

    select
        id as patient_id,
        initcap(first_name) || ' ' || initcap(last_name) as full_name,
        birth_date,
        last_visit_date,
        case
            when lower(gender) in ('m', 'male') then 'Male'
            when lower(gender) in ('f', 'female') then 'Female'
            when gender is null or trim(gender) = '' or lower(gender) = 'unknown' then 'Unknown'
            else 'Other'
        end as gender,
        RTRIM(
            coalesce(trim(address) || ', ', '') || 
            coalesce(trim(city) || ', ', '') || 
            coalesce(trim(upper(state)) || ', ' , '')|| 
            coalesce(trim(zip_code), ''),
            ', '
        ) as address,
        address as line,
        city,
        upper(state) as state,
        zip_code,
        phone_number,
        email,
        emergency_contact_name,
        emergency_contact_phone,
        blood_type,
        insurance_provider,
        insurance_number,
        marital_status,
        preferred_language,
        nationality,
        allergies,

        -- Data quality flags
        case
            when birth_date is not null and birth_date <= current_date then true
            else false
        end as has_valid_birth_date,

        case
            when last_visit_date is null or last_visit_date <= current_date then true
            else false
        end as has_valid_visit_date,

        case
            when coalesce(trim(address), '') <> ''
            or coalesce(trim(city), '') <> ''
            or coalesce(trim(state), '') <> ''
            or coalesce(trim(zip_code), '') <> ''
            then true
            else false
        end as is_valid_address,

        case
            when state in {{ get_valid_us_states() }} then true
            else false
        end as is_valid_state,

        case
            when preferred_language in {{ get_valid_languages() }} then true
            else false
        end as is_valid_language,

        case
            when marital_status in {{ get_valid_marital_statuses() }} then true
            else false
        end as is_valid_marital_status,

        case
            when insurance_number ~* {{ get_insurance_number_pattern() }} then true
            else false
        end as is_valid_insurance_number

    from raw_patient_data_from_source
)

select
    patient_id,
    full_name,
    birth_date,
    last_visit_date,
    gender,
    address,
    line,
    city,
    state,
    zip_code,
    phone_number,
    email,
    emergency_contact_name,
    emergency_contact_phone,
    blood_type,
    insurance_provider,
    insurance_number,
    marital_status,
    preferred_language,
    nationality,
    allergies,
    has_valid_birth_date,
    has_valid_visit_date,
    is_valid_address,
    is_valid_state,
    is_valid_language,
    is_valid_marital_status,
    is_valid_insurance_number
from renamed_and_normalized_patient_fields_with_flags