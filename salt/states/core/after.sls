# Run after-tasks
{% from "vhosting/map.jinja" import webstack, webserver_edition, webserver with context %}
{%- set project_users = salt['pillar.get']('vhosting:users', {}) %}

{%- if project_users|length > 0 %}
# Add user to the Vagrant group
extend:
{%- for user in project_users %}
  {{ user }}:
    user.present:
      - groups:
        - vagrant
{%- endfor %}

# Create symlinks to the default Vagrant mountpoint
{%- for user in project_users %}
/srv/http/{{ user }}/current:
  file.symlink:
    - target: /vagrant
    - require:
      - user: {{ user }}
    - watch_in:
      - service: {{ webserver }}
{%- endfor %}

{%- endif %}
