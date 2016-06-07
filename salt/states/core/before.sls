# Run before-tasks
{%- set server_timezone = salt['pillar.get']('basebox:timezone', 'Europe/Amsterdam') %}
{%- set locales = salt['pillar.get']('basebox:locales', ['nl_NL.UTF-8', 'en_US.UTF-8']) %}
# Install but disable Salt-minion
salt-minion:
  pkg.installed: []
  service.running:
    - enable: False
    - reload: True

# Set timezone
{{ server_timezone }}:
  timezone.system

system_locales:
  locale.present:
    - names:
{%- for locale in locales %}
      - {{ locale }}
{%- endfor %}
