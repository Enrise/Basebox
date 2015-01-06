# Install a webstack based on Zend Server
{%- set webserver = salt['pillar.get']('vhosting:server:webserver', 'nginx') %}
{%- set disable_webserver = salt['pillar.get']('vhosting:server:disable_webserver', False) %}
{%- set enable_zray = salt['pillar.get']('vhosting:server:enable_zray', False) %}

include:
  - zendserver
{%- if not disable_webserver %}
{%- if webserver == 'nginx' %}
  - {{ webserver }}.light
{%- else %}
  - {{ webserver }}
{%- endif %}
{%- endif %}

{%- if webserver == 'nginx' %}
# Symlink php-fpm as an init script (only required for nginx+fpm)
/etc/init.d/php5-fpm:
  file.symlink:
    - target: /usr/local/zend/bin/php-fpm.sh
    - require:
      - pkg: zendserver
{%- endif %}

{%- if webserver == 'nginx' and not disable_webserver %}
# Re-configure PHP-FPM to allow multiple pools to be used
/usr/local/zend/etc/fpm.d:
  file.directory:
  - require:
    - pkg: zendserver

/usr/local/zend/etc/php-fpm.conf:
  file.uncomment:
    - regex: ^include=etc
    - char: ;
    - require:
      - pkg: zendserver
    - watch_in:
      - service: zendserver

# this is not very DRY but since we cannot *extend*
php5-fpm:
  service.running:
    - enable: True
    - reload: True
    - require:
      - pkg: zendserver
      - file: /usr/local/zend/etc/fpm.d
      - file: /etc/init.d/php5-fpm
      - file: /usr/local/zend/etc/php-fpm.conf
{%- endif %}

# Zend-server is ... a service. This is not included in the Zendserver formula (yet)
#zend-server:
#  service.running:
#    - enable: True
#    - restart: True
#    - watch:
#      - pkg: zendserver
#    - require:
#      - pkg: zendserver

{%- if disable_webserver %}
# Stop & disable the webserver
extend:
  {{ webserver }}:
    service:
      - disabled

kill_webserver:
  service.dead:
    - name: {{ webserver }}

#php5-fpm:
#  service:
#    - disabled
#
#kill_fpm:
#  service.dead:
#    - name: php5-fpm
{%- endif %}

{%- if not enable_zray %}
# Disable ZRay
/usr/local/zend/etc/conf.d/zray.ini:
  file.replace:
    - pattern: 'zray.enable=1'
    - repl: 'zray.enable=0'
    - watch_in:
      - service: zendserver
{%- if webserver == 'nginx' %}
      - service: php5-fpm
{% endif -%}
{%- endif %}
