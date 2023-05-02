{% macro get_or_create_unit_test_table_relation(table_name,schema_name=none) %}
    {% set schema = (schema_name if schema_name else target.schema) %}
    {% set table_exists, table_relation = dbt.get_or_create_relation(database=elementary.target_database(),
                                                                     schema=schema,
                                                                     identifier=table_name,
                                                                     type='table') %}
    {{ return([table_exists, table_relation]) }}
{% endmacro %}

{% macro create_unit_test_table(table_name, table_schema, temp = True, schema_name=none, no_override_if_table_exists=False) %}
    {% set unit_test_table_exists, unit_test_table_relation = get_or_create_unit_test_table_relation(table_name,schema_name) %}
    {% if no_override_if_table_exists %}
      {% if unit_test_table_exists %}
        {% do return(unit_test_table_relation) %}
      {% endif %}
    {% endif %}
    {% set sql_query = get_empty_table(table_schema) %}
    {% do run_query(dbt.create_table_as(temp, unit_test_table_relation, sql_query)) %}
    {% do adapter.commit() %}
    {{ return(unit_test_table_relation) }}
{% endmacro %}

{% macro get_empty_table(table_schema) %}
    {{ elementary.empty_table(table_schema) }}
{% endmacro %}

{% macro drop_unit_test_table(table_name) %}
    {% set table_relation = adapter.get_relation(database=elementary.target_database(),
                                                                     schema=target.schema,
                                                                     identifier=table_name) %}
    {% if table_relation %}
        {% do adapter.drop_relation(table_relation) %}
    {% endif %}
{% endmacro %}
