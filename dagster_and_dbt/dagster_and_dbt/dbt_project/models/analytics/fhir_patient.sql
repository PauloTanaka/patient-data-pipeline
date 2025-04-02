{{ config(materialized='table') }}
WITH patient AS (
    SELECT 
        id,
        first_name || ' ' || last_name AS full_name,
        birth_date,
        gender,
        address || ', ' || city || ', ' || state || ', ' || zip_code AS address,
        jsonb_build_object(
            'phone', phone_number, 
            'email', email
        ) AS telecom,
        marital_status,
        insurance_number,
        nationality
    FROM {{ source('staging', 'raw_patient') }}
)

SELECT * FROM patient