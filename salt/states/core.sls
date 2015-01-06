# Minion specific settings
salt-minion:
  pkg:
    - installed
  service.running:
    - enable: False
    - reload: True

# Temporary workaround for vhosting limitation
exclude:
  - id: webistrano_key_project
