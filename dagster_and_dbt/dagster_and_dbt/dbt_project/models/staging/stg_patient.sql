with source as (

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

renamed as (

    select
        -- IDs and names
        id as patient_id,
        initcap(first_name) || ' ' || initcap(last_name) as full_name,

        -- Dates
        birth_date,
        last_visit_date,

        -- Gender normalization
        case
            when lower(gender) in ('m', 'male') then 'Male'
            when lower(gender) in ('f', 'female') then 'Female'
            when gender is null or trim(gender) = '' or lower(gender) = 'unknown' then 'Unknown'
            else 'Other'
        end as gender,

        -- Address
        address,
        city,
        upper(state) as state,
        zip_code,

        -- Contact
        phone_number,
        email,

        -- Emergency contact
        emergency_contact_name,
        emergency_contact_phone,

        -- Other fields
        blood_type,
        insurance_provider,
        insurance_number,
        marital_status,
        preferred_language,
        nationality,
        allergies,

        -- Data quality flags
        case 
            when email ~* '{{ get_email_validation_regex() }}' then true
            else false
        end as is_valid_email,

        case
            when birth_date is not null and birth_date <= current_date then true
            else false
        end as has_valid_birth_date,

        case
            when last_visit_date is null or last_visit_date <= current_date then true
            else false
        end as has_valid_visit_date,

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
        end as is_valid_marital_status

    from source
)

select
    patient_id,
    full_name,
    birth_date,
    last_visit_date,
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
    is_valid_email,
    has_valid_birth_date,
    has_valid_visit_date,
    is_valid_state,
    is_valid_language,
    is_valid_marital_status
from renamed