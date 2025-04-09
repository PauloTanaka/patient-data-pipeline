{% test is_valid_email(model, column_name) %}

SELECT *
FROM {{ model }}
WHERE {{ column_name }} IS NOT NULL
  AND {{ column_name }} != ''
  AND {{ column_name }} !~* '{{ get_email_validation_regex() }}'

{% endtest %}