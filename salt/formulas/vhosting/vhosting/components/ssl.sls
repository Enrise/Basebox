# Deal with SSL
{% macro install_pair(salt, domain, config) %}
{%- set webserver = salt['pillar.get']('vhosting:server:webserver', 'nginx') %}

# SSL Certificate: {{ config.cert }}
ssl_cert_{{domain}}:
  file.managed:
    - name: /etc/ssl/certs/{{ config.cert }}
    - source: salt://ssl/{{ config.cert }}
    - watch_in:
      - service: {{ webserver }}

{%- if 'ca' in config %}
# SSL CA: {{ config.ca }}
ssl_chain_{{domain}}:
  file.managed:
    - name: /etc/ssl/certs/{{ config.ca }}
    - source: salt://ssl/{{ config.ca }}
    - watch_in:
      - service: {{ webserver }}
{%- endif %}

# SSL key: {{ config.key }}
ssl_key_{{domain}}:
  file.managed:
    - name: /etc/ssl/private/{{ config.key }}
    - source: salt://ssl/{{ config.key }}
    - watch_in:
      - service: {{ webserver }}
{% endmacro %}
