# Install vanilla webstack with configured webserver
{%- set webserver = salt['pillar.get']('vhosting:server:webserver', 'nginx') %}

include:
  - {{ webserver }}
  {% if webserver == 'nginx' -%}
  - phpfpm
  {% endif -%}

# Extra wijzigingen voor de webserver ({{webserver}}) voor vanilla mode
