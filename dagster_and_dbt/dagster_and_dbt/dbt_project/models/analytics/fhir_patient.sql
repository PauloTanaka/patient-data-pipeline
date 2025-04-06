{{ config(materialized='table') }}
-- models/marts/fhir_patient.sql

with base as (

    select * from {{ ref('stg_patient') }}
    where is_valid_email = true
      and has_valid_birth_date = true
      and is_valid_state = true

),

final as (

    select
        -- Generate a stable hash ID based on key attributes
        md5(
            coalesce(full_name, '') || 
            coalesce(cast(birth_date as text), '') || 
            coalesce(nationality, '') || 
            coalesce(insurance_number, '')
        ) as id,

        full_name,
        birth_date,
        gender,
        address,

        -- Contact information as JSONB
        to_jsonb(
            jsonb_build_object(
                'phone', phone_number,
                'email', email
            )
        ) as telecom,

        marital_status,
        insurance_number,
        left(nationality, 20) as nationality

    from base

)

select * from final;