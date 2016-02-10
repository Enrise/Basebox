# Use with apache2

If you want to use the [apache2](https://httpd.apache.org/) webserver there is some manual labour involved. 

## Configure vhosting to use apache
```yaml
# dev/salt/pillars/defaults/vhosting.sls
vhosting:
  server:
    webserver: apache
    webserver_edition: vanilla
```

## Override the project.sls file
By default the nginx state file is included, and if you use apache it should not run it at all.
You can prevent salt from running the nginx state by removing the reference to it from the project.sls file.

The project.sls file does not exist in your custom salt directory, so you have to create it.

```yaml
# dev/salt/pillars/project.sls
include:
  - defaults.mysql
#  - defaults.nginx # Remove or comment this line
  - defaults.phpfpm
  - defaults.zendserver
  - defaults.vhosting
  - vhosts
```
