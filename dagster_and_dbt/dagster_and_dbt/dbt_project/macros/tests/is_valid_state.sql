{% test is_valid_state(model, column_name) %}
SELECT *
FROM {{ model }}
WHERE {{ column_name }} IS NOT NULL
  AND {{ column_name }} NOT IN
    {{ get_valid_us_states() }}

{% endtest %}