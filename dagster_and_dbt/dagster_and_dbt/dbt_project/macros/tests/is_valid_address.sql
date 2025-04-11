{% test is_valid_address(model, column_name) %}

SELECT *
FROM {{ model }}
WHERE NOT (
    coalesce(trim(address), '') <> ''
    OR coalesce(trim(city), '') <> ''
    OR coalesce(trim(state), '') <> ''
    OR coalesce(trim(zip_code), '') <> ''
)

{% endtest %}
