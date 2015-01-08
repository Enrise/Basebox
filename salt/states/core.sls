# Minion specific settings
salt-minion:
  pkg:
    - installed
  service.running:
    - enable: False
    - reload: True
