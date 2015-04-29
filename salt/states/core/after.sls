# Run after-tasks
{% from "vhosting/map.jinja" import webstack, webserver_edition, webserver with context %}

extend:
  {%- for user in salt['pillar.get']('vhosting:users') %}
  {{ user }}:
    user.present:
      - group:
        - project
        - vagrant
  {%- endfor %}

# Create symlinks to the default Vagrant mountpoint
{%- for user in salt['pillar.get']('vhosting:users') %}
/srv/http/{{ user }}/current:
  file.symlink:
    - target: /vagrant
    - require:
      - user: {{ user }}
    - watch_in:
      - service: {{ webserver }}
{%- endfor %}
