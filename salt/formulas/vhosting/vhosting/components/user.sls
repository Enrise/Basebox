# Creates a user and (optionally) a directory structure
{% from "vhosting/lib.sls" import path_join %}
{%- set baseroot = '/srv/http' %}

{% macro create_user(username, params={}) %}
{%- set homedir = path_join(username, baseroot) %}

# Ensure user {{ username }} is created
{{ username }}:
  user.present:
    - shell: {{ params.get('shell', '/bin/bash') }}
    - createhome: True
    - home: {{ homedir }}

# Create a domains folder too
{{ homedir }}/hosts:
  file.directory:
    - user: {{ username }}
    - group: {{ username }}
    - require:
      - user: {{ username }}

# Create a logs folder too
{{ homedir }}/logs:
  file.directory:
    - user: {{ username }}
    - group: {{ username }}
    - require:
      - user: {{ username }}

# And logrotate these logs
logrotate_{{ username }}:
  file.accumulated:
    - name: vhost_logrotate
    - filename: /etc/logrotate.d/vhosts
    - text: '{{ homedir }}/logs'
    - require:
      - file: {{ homedir }}/logs
    - require_in:
      - file: vhost_logrotate
{% endmacro %}
