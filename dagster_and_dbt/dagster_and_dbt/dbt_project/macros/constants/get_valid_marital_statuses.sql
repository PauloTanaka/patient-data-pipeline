
{% macro get_valid_marital_statuses() %}
(
    'Annulled', 'Divorced', 'Interlocutory', 'Legally Separated', 'Married',
    'Common Law', 'Polygamous', 'Domestic partner', 'unmarried',
    'Never Married', 'Widowed', 'unknown'
)
{% endmacro %}
