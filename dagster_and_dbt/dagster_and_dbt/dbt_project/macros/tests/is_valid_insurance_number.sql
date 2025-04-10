{% test is_valid_insurance_number(model, column_name) %}

SELECT *
FROM {{ model }}
WHERE {{ column_name }} IS NOT NULL
  AND {{ column_name }} !~* '^[A-Z]{2}[0-9]{9}$'

{% endtest %}
