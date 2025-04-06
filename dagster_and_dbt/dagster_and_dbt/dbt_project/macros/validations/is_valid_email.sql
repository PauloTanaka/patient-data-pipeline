-- macros/validations/is_valid_email.sql

{% macro is_valid_email(column_name) %}
    {{ column_name }} ~* E'^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$'
{% endmacro %}