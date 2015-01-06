# Ensure the keyhost-key is added to this user
{% macro create(salt, baseconf, username, enabled) -%}
{% if enabled %}
keyhost_key_{{ username }}:
  ssh_auth.present:
    - user: {{ username }}
    - source: 'salt://ssh/keys/keyhost.pub'
    - require:
      - user: {{ username }}
{% endif %}
{%- endmacro %}
