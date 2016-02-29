# Run before-tasks
{%- set server_timezone = salt['pillar.get']('timezone', 'Europe/Amsterdam') %}
# Install but disable Salt-minion
salt-minion:
  pkg:
    - installed
  service.running:
    - enable: False
    - reload: True

# Set timezone
{{ server_timezone }}:
  timezone.system
