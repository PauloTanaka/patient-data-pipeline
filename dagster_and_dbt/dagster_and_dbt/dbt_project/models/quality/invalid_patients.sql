{{ config(materialized='table') }}

WITH staged_patient_data_with_error_classification AS (
    SELECT
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
        has_valid_birth_date,
        has_valid_visit_date,
        is_valid_address,
        is_valid_state,
        is_valid_language,
        is_valid_marital_status,
        is_valid_insurance_number,
        RTRIM(
            CASE WHEN patient_id IS NULL THEN 'patient_id_missing, ' ELSE '' END ||
            CASE WHEN full_name IS NULL THEN 'full_name_missing, ' ELSE '' END ||
            CASE WHEN gender IS NULL THEN 'gender_missing, ' ELSE '' END ||
            CASE WHEN NOT has_valid_birth_date THEN 'birth_date_invalid, ' ELSE '' END ||
            CASE WHEN NOT has_valid_visit_date THEN 'last_visit_date_invalid, ' ELSE '' END ||
            CASE WHEN NOT is_valid_address THEN 'address_invalid, ' ELSE '' END ||
            CASE WHEN NOT is_valid_state THEN 'state_invalid, ' ELSE '' END ||
            CASE WHEN NOT is_valid_language THEN 'language_invalid, ' ELSE '' END ||
            CASE WHEN NOT is_valid_marital_status THEN 'marital_status_invalid, ' ELSE '' END ||
            CASE WHEN NOT is_valid_insurance_number THEN 'insurance_number_invalid, ' ELSE '' END,
            ', '
        ) AS error_type

    FROM {{ ref('stg_patient') }}
)

SELECT
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
    has_valid_birth_date,
    has_valid_visit_date,
    is_valid_address,
    is_valid_state,
    is_valid_language,
    is_valid_marital_status,
    is_valid_insurance_number,
    error_type
FROM staged_patient_data_with_error_classification
WHERE error_type IS NOT NULL AND error_type <> ''