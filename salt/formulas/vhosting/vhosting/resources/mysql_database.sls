# Create a MySQL Database pair (db + user + grants)
{% macro create(salt, baseconf, owner, params, name) %}
{%- if 'password' in params %}
mysqldb_{{ owner }}_{{ name }}:
  mysql_database.present:
    - name: {{ name }}
  mysql_user.present:
    - name: {{ name }}
    - password: {{ params.get('password')|json() }}
    - host: {{ params.get('host', 'localhost')|json() }}
  mysql_grants.present:
    - grant: ALL
    - database: {{ name }}.*
    - user: {{ name }}
    - host: {{ params.get('host', 'localhost')|json() }}
  require:
    - pkg: python-mysqldb
    - pkg: mysql-server
    - service: mysql-server
    - file: salt_mysql_config

{%- if 'hosts' in params %}
# Extra grants required
{%- for host in params.get('hosts', []) %}
mysqldb_{{ owner }}_{{ name }}_grant_{{ host }}:
  mysql_user.present:
    - name: {{ name }}
    - password: {{ params.get('password')|json() }}
    - host: {{ host|json() }}
  mysql_grants.present:
    - grant: ALL
    - database: {{ name }}.*
    - user: {{ name }}
    - host: {{ host|json() }}
    - require:
      - mysql_database: {{ name }}
      - file: salt_mysql_config
{%- endfor -%}
{%- endif %} #hosts in params

{%- if params.get('backup', False) and salt['pillar.get']('backups:enable', True) %}
# Create a backupninja config file for MySQL database backups
backup_mysqldb_{{ owner }}_db_{{ name }}:
  file.managed:
    - name: /etc/backup.d/10-db_{{ name }}.mysql
    - template: jinja
    - source: salt://backupninja/templates/actions/mysql.jinja
    - mode: '0600'
    - require:
      - pkg: backupninja
    - context:
        keep: '14D'
        hotcopy: no
        sqldump: yes
        compress: yes
        backupdir: /var/backups/mysql
        databases:
          - {{ name }}
{%- endif %} # backup in params

{% endif -%} # password in params
{% endmacro %}
