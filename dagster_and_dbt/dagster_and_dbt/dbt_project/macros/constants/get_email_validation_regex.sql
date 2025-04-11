{% macro get_email_validation_regex() %}
    '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
{% endmacro %}