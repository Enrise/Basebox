nullmailer:
  pkg.installed: []
  service.running:
    - enable: True

/etc/nullmailer/remotes:
  file.managed:
    - contents: "localhost smtp --port=1025"
    - require:
      - pkg: nullmailer
    - watch:
      - service: nullmailer

/opt/mailhog:
  file.directory: []

download-mailhog:
  cmd.run:
    - name: wget -qO /opt/mailhog/mailhog https://github.com/mailhog/MailHog/releases/download/v0.1.7/MailHog_linux_amd64 && chmod +x /opt/mailhog/mailhog
    - creates: /opt/mailhog/mailhog
    - requires:
      - file: /opt/mailhog

/etc/init.d/mailhog:
  file.managed:
    - source: salt://mailhog/initscript
    - mode: 755

mailhog:
  service.running:
    - enable: True
    - require:
      - cmd: download-mailhog
      - file: /etc/init.d/mailhog
