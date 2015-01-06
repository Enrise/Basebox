{% from "vhosting/map.jinja" import webstack, webserver_edition, webserver with context %}
{% from "vhosting/lib.sls" import call_macro with context %}

# Loops trough the users and create services for them
{%- for username, resources in salt['pillar.get']('vhosting:users', {}).items() %}

{%-  if 'vhost' in resources %}
{% from "vhosting/components/user.sls" import create_user with context %}
# Create user {{ username }}
{{ create_user(username, resources) }}
{% endif -%}

{%- for resource_type, resource_settings in resources.items() %}
# Resource: {{ resource_type }}
{%- if resource_settings is mapping %}
# Multi resource
{%- for resource_key, resource_settings in resource_settings.items() %}
# {{ resource_key }}
{{ call_macro(salt, webstack, username, resource_type, resource_settings, resource_key ) }}
{%- endfor %}
{%- else %}
# Single resource ({{resource_type}})
{{ call_macro(salt, webstack, username, resource_type, resource_settings) }}
{%- endif %}

{%- endfor %}

{%- endfor %}
