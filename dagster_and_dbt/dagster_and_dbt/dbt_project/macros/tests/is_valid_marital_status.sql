{% test is_valid_marital_status(model, column_name) %}
SELECT *
FROM {{ model }}
WHERE {{ column_name }} IS NOT NULL
  AND {{ column_name }} NOT IN (
    {{ get_valid_marital_statuses() }}
  )
{% endtest %}