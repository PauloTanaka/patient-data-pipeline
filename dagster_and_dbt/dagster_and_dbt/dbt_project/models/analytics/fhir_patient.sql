with base as (
    select *
    from {{ ref('stg_patient') }}
    where is_valid_email
      and has_valid_birth_date
      and has_valid_visit_date
      and is_valid_state
      and is_valid_language
      and is_valid_marital_status
),

deduplicated as (
    select distinct
        insurance_provider,
        insurance_number,

        -- Para cada campo, pega o valor não nulo mais recente
        first_value(full_name) 
            over (partition by insurance_provider, insurance_number order by 
                  case when full_name is not null then 0 else 1 end,
                  last_visit_date desc nulls last) as full_name,

        first_value(birth_date)
            over (partition by insurance_provider, insurance_number order by 
                  case when birth_date is not null then 0 else 1 end,
                  last_visit_date desc nulls last) as birth_date,

        first_value(gender)
            over (partition by insurance_provider, insurance_number order by 
                  case when gender is not null then 0 else 1 end,
                  last_visit_date desc nulls last) as gender,

        first_value(address)
            over (partition by insurance_provider, insurance_number order by 
                  case when address is not null then 0 else 1 end,
                  last_visit_date desc nulls last) as address,

        first_value(phone_number)
            over (partition by insurance_provider, insurance_number order by 
                  case when phone_number is not null then 0 else 1 end,
                  last_visit_date desc nulls last) as phone_number,

        first_value(email)
            over (partition by insurance_provider, insurance_number order by 
                  case when email is not null then 0 else 1 end,
                  last_visit_date desc nulls last) as email,

        first_value(marital_status)
            over (partition by insurance_provider, insurance_number order by 
                  case when marital_status is not null then 0 else 1 end,
                  last_visit_date desc nulls last) as marital_status,

        first_value(nationality)
            over (partition by insurance_provider, insurance_number order by 
                  case when nationality is not null then 0 else 1 end,
                  last_visit_date desc nulls last) as nationality,

        max(last_visit_date) as last_visit_date
    from base
)

select
    md5(
        coalesce(full_name, '') ||
        coalesce(cast(birth_date as text), '') ||
        coalesce(insurance_provider, '') ||
        coalesce(insurance_number, '')
    ) as id,
    full_name,
    birth_date,
    gender,
    address,
    jsonb_build_object('phone', phone_number, 'email', email) as telecom,
    marital_status,
    insurance_number,
    nationality,
    last_visit_date
from deduplicated