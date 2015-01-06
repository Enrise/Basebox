# Include the appropriate webstack
{%- set webserver_edition = salt['pillar.get']('vhosting:server:webserver_edition', 'vanilla') %}
{%- set webroot_base = salt['pillar.get']('vhosting:server:basedir', '/srv/http') %}

include:
  - .{{webserver_edition}}
  - .grains

# Create base root for vhosts
{{ webroot_base }}:
  file.directory

# Ensure the custom-logs vhosting are being rotated
vhost_logrotate:
  file.managed:
    - name: /etc/logrotate.d/vhosts
    - source: {{ salt['pillar.get']('vhosting:server:logrotate_template', 'salt://vhosting/templates/logrotate.conf.jinja') }}
    - template: {{ salt['pillar.get']('vhosting:server:logrotate_template_type', 'jinja') }}
