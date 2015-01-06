# Deal with "deploy structure" for this user
{% macro create(salt, baseconf, owner, params, name) %}
{%- from "vhosting/lib.sls" import path_join with context %}
{%- set webroot_base = salt['pillar.get']('vhosting:server:basedir', '/srv/http') %}
{%- set homedir = path_join(owner, webroot_base) %}
# Deal with 'deploy structures' (this changes the deploy folder slightly)
# Ensure the webistrano deploy key is available for the given user
webistrano_key_{{ owner }}:
  ssh_auth.present:
    - user: {{ owner }}
    - source: 'salt://ssh/keys/webistrano.pub'
    - require:
      - user: {{ owner }}

# Ensure the homedirectory contains a "deploy stucture" with releases folder etc
{{ homedir }}/data:
  file.directory:
    - user: {{ owner }}
    - group: {{ owner }}
    - require:
      - user: {{ owner }}

{{ homedir }}/releases:
  file.directory:
    - user: {{ owner }}
    - group: {{ owner }}
    - require:
      - user: {{ owner }}
{%- endmacro %}
