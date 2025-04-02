{{ config(materialized='table') }}
WITH validation AS (
    SELECT
        *,
        RTRIM(
			CASE WHEN id IS NULL THEN 'id_missing, ' ELSE '' END ||
			CASE WHEN full_name IS NULL THEN 'full_name_missing, ' ELSE '' END ||
			CASE WHEN birth_date IS NULL THEN 'birth_date_missing, ' ELSE '' END ||
			CASE WHEN gender IS NULL THEN 'gender_missing, ' ELSE '' END ||
			CASE WHEN gender IS NOT NULL AND gender NOT IN ('Male', 'Female', 'Other', 'Unknown') THEN 'gender_invalid, ' ELSE '' END ||
			CASE WHEN address IS NULL THEN 'address_missing, ' ELSE '' END ||
			CASE WHEN telecom IS NULL THEN 'telecom_missing, ' ELSE '' END
		, ', ') AS error_type
    FROM {{ ref('fhir_patient') }}
)
SELECT *
FROM validation
WHERE error_type IS NOT NULL AND error_type <> ''