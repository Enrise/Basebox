# Create a vhost for the given webservers
{% macro create(salt, baseconf, owner, params, name) %}
{%- from "vhosting/lib.sls" import path_join, sls_block with context %}
{%- set domain = name|lower %}
{%- set domain_safe = domain|replace('.','_') %}

# grab all settings
{%- set vhosting = salt['pillar.get']('vhosting') %}
{%- set vhosting_server = vhosting.get('server') %}

{%- set webroot_base = vhosting_server.get('basedir', '/srv/http') %}

{%- set webserver = vhosting_server.get('webserver', 'nginx') %}
{%- set webserver_edition = vhosting_server.get('webserver_edition', 'vanilla') %}
{%- set vhost_template_path = 'salt://' ~ webserver ~ '/templates' %}

{%- set homedir = path_join(owner, webroot_base) %}
{%- set priority = params.get('priority', 50) %}
{%- set webroot = params.get('webroot', homedir ~ '/hosts/' ~ name ) %}
{%- set logdir = params.get('logdir', homedir ~ '/logs' ) %}
{%- set php = params.get('php', True) %}
{%- set ssl = params.get('ssl', False) %}
{%- set backup = params.get('backup', False) %}

{%- set vhost_file_available = baseconf.get('sites_available') ~ '/' ~ domain_safe ~ '.conf' %}
{%- set vhost_file_enabled = baseconf.get('sites_enabled') ~ '/' ~ priority ~ '-' ~ domain_safe ~ '.conf' %}

{%- if 'redirect_to' in params %}
# Redirect vhost, no need for directory structure etc
{%- set template_file = params.get('template_file', vhost_template_path ~ '/redirect.conf.jinja') %}
{%- else %}
# Normal vhost, required folders
{%- set template_file = params.get('template_file', vhost_template_path ~ '/default.conf.jinja') %}
{%- set deploy_structure = salt['pillar.get']('vhosting:users:' ~ owner ~ ':deploy_structure', False) %}

############################################################################################################################
{%- if deploy_structure %}
#xxx todo: create separate module for deploy structure for standalone usage
# The webserver directory is a symlink to the current release
{{ webroot }}:
  file.symlink:
    {%- if params.get('webroot_public', False) %}
    - target: '../current/public'
    {%- else %}
    - target: '../current'
    {%- endif %}
    - user: {{ owner }}
    - group: {{ owner }}
{%- else %}
# Ensure the homedirectory exists
{{ webroot }}:
  file.directory:
    - user: {{ owner }}
    - group: {{ owner }}
    - require:
      - file: {{ homedir }}/hosts
      - user: {{ owner }}
{%- endif %}
############################################################################################################################

############################################################################################################################
{%- if php and webserver == 'nginx' %}
# only enable php for true vhosts, not redirect/stubs
{%- from "phpfpm/lib.sls" import create_pool with context %}
{%- from "phpfpm/map.jinja" import phpfpm as phpfpm_map %}
{{ create_pool(salt, domain_safe, owner, phpfpm_map.dirs.config) }}
{%- endif %}
############################################################################################################################

{%- endif %} # close redirect_to params

############################################################################################################################
{%- if ssl is mapping %}
# Install the required certificate, key and chain for this domain
{%- from "vhosting/components/ssl.sls" import install_pair with context %}
{{ install_pair(salt, domain, ssl) }}
{%- endif %}
############################################################################################################################
# xxx todo: Create a macro for vhost generation for standalone usage

# Create vhost configuration
{{ vhost_file_available }}:
  file.managed:
  - source: {{ template_file }}
  - template: {{ params.get('template_engine', 'jinja') }}
  - watch_in:
    - service: {{ webserver }}
  - require:
    - pkg: {{ webserver }}
    - user: {{ owner }}
  - webroot: {{ webroot }}
  - logdir: {{ logdir }}
  - owner: {{ owner }}
  - domain: {{ domain }}
  - user: root
  - group: root
  {{- sls_block(params) }}
  - domain_safe: {{ domain_safe }}
  {%- if php and webserver == 'nginx' %}
  {%- from "phpfpm/map.jinja" import phpfpm as phpfpm_map %}
  - fpm_sock_dir: {{ phpfpm_map.dirs.socket }}
  {%- endif %}

# Enable vhost
{{ vhost_file_enabled }}:
  file.symlink:
  - target: {{ vhost_file_available }}
  - watch_in:
    - service: {{ webserver }}
  - require:
    - file: {{ vhost_file_available }}

# Check if backups are enabled
{%- if backup %}
# Create a backupninja config file for vhosts backups
# xxx: todo: Create a macro for this and include it
backup_job_vhost_{{ domain }}:
  file.managed:
    - name: /etc/backup.d/20-vhost_{{ domain }}.rdiff
    - template: jinja
    - source: salt://backupninja/templates/actions/rdiff.jinja
    - mode: '0600'
    - require:
      - pkg: backupninja
    - context:
        type: local
        #when: ''
        keep: '14D'
        include:
          - {{ webroot }}
        exclude: ['**/.git', '**/**.git', '**/.svn', '**/**.svn']
        dest:
          type: remote
          directory: 'backups/vhosts'
          host: {{ salt['pillar.get']('backupninja:server') }}
          user: 'bu_{{ salt['grains.get']('server_id')|string }}'
          #type: 'local'
          #directory: /var/backups/vhosts
{%- endif %}


{% endmacro %}
