with filtered_valid_patients as (
    select 
	    patient_id,
	    full_name,
	    birth_date,
	    last_visit_date,
	    gender,
	    address,
	    phone_number,
	    email,
	    insurance_provider,
	    insurance_number,
	    marital_status,
	    nationality
    from {{ ref('stg_patient') }}
	where insurance_number is not null
	  and insurance_provider is not null
),

deduplicated_patients_by_insurance as (
    select
        (array_agg(patient_id order by last_visit_date desc nulls last)
            filter (where patient_id is not null))[1] as patient_id,

        (array_agg(full_name order by last_visit_date desc nulls last)
            filter (where full_name is not null))[1] as full_name,

        (array_agg(birth_date order by last_visit_date desc nulls last)
            filter (where birth_date is not null))[1] as birth_date,

        (array_agg(gender order by last_visit_date desc nulls last)
            filter (where gender is not null))[1] as gender,

        (array_agg(address order by last_visit_date desc nulls last)
            filter (where address is not null))[1] as address,

        (array_agg(phone_number order by last_visit_date desc nulls last)
            filter (where phone_number is not null))[1] as phone_number,
		
        (array_agg(email order by last_visit_date desc nulls last)
            filter (where email is not null))[1] as email,

        (array_agg(marital_status order by last_visit_date desc nulls last)
            filter (where marital_status is not null))[1] as marital_status,

        insurance_number,

        (array_agg(nationality order by last_visit_date desc nulls last)
            filter (where nationality is not null))[1] as nationality

    from filtered_valid_patients
    group by insurance_provider, insurance_number
)

select
	patient_id as id,
	full_name,
	birth_date,
	gender,
	phone_number,
    jsonb_build_object(
        'phone', phone_number,
        'email', email
    ) as telecom,
	marital_status,
	insurance_number,
	nationality
from deduplicated_patients_by_insurance
