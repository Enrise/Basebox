{% from "vhosting/map.jinja" import webstack, webserver_edition, webserver with context %}

# Set grains for easy targeting
webserver_grain:
  grains.present:
    - name: webserver
    - value: {{ webserver }}

webserver_edition_grain:
  grains.present:
    - name: webserver_edition
    - value: {{ webserver_edition }}

webstack_grain:
  grains.present:
    - name: webstack
    - value: {{webserver_edition}}.{{webserver}}
