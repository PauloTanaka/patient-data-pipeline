-- models/staging/stg_patient.sql

with source as (

    select * from {{ source('raw', 'patient') }}

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
            when lower(gender) in ('non-binary', 'nonbinary', 'nb') then 'Non-Binary'
            else 'Unknown'
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
            when email ~* E'^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$' then true
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
        end as is_valid_state

    from source
)

select * from renamed;