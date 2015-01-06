# Create a cronjob
{% macro create(salt, baseconf, owner, params, name) %}
cron_{{ owner }}_{{ name }}:
  cron.present:
    - name: '{{ params.get('cmd') }}'
    - user: '{{ params.get('user', owner ) }}'
    - minute: '{{ params.get('minute', '*') }}'
    - hour: '{{ params.get('hour', '*') }}'
    - daymonth: '{{ params.get('daymonth', '*') }}'
    - month: '{{ params.get('month', '*') }}'
    - dayweek: '{{ params.get('day', '*') }}'
    - comment: '{{ params.get('comment', '') }}'
    - identifier: '{{ owner }}_{{ name }}'
{% endmacro %}
