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

## Add the apache2 formula
The basebox does not come with the [apache2 salt formula](https://github.com/Enrise/apache-formula) but it is easy to add it to your basebox setup.
Add the apache2 formula to your repository and create a link to it in the `states/` directory like so:

```bash
# From your project root
git submodule add git@github.com:Enrise/apache-formula.git dev/salt/formulas/apache-formula
ln -s ../../formulas/apache-formula/apache dev/salt/states/apache
```

## Remove the nginx pillar configuration
By default the nginx pillar file is included, and if you use Apache it should not use that it at all.
You can prevent salt from loading the nginx pillar configuration by placing an empty version of the file in the default folder.

```yaml
# File: dev/salt/pillars/defaults/nginx.sls
nginx: ~
```
