# Run before-tasks
salt-minion:
  pkg:
    - installed
  service.running:
    - enable: False
    - reload: True
