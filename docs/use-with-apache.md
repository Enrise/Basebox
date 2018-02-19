# Using with Apache2
By default the basebox uses nginx, but if you want to use the [apache2](https://httpd.apache.org/) webserver instead there is some manual labour involved.

## Configure vhosting to use apache
```yaml
# dev/salt/pillars/custom.sls
vhosting:
  lookup:
    ## For ZendServer
    webstack: 'zendserver.apache'
    php_config_dir: '/usr/local/zend/etc/conf.d'
    ##

    ## For Vanilla
    webstack: 'vanilla.apache'
    php_config_dir: '/etc/php5/conf.d'
    ###

    webserver_config_dir: '/etc/apache2'    
    sites_available: '/etc/apache2/sites-available'
    sites_enabled: '/etc/apache2/sites-enabled'
  server:
    webserver: apache
    webserver_edition: vanilla
```

**Note:** Make sure you remove the section you are not using ("For Zendserver" or "For Vanilla")

## Add the Apache2 formula
The basebox does not come with the [apache2 salt formula](https://github.com/Enrise/apache-formula) but it is easy to add it to your basebox setup.
Add the apache2 formula to your repository and create a link to it in the `states/` directory like so:

```bash
# From your project root
git submodule add git@github.com:Enrise/apache-formula.git dev/salt/formulas/apache-formula
ln -s ../../formulas/apache-formula/apache dev/salt/states/apache
```

## Remove the nginx pillar configuration
By default the nginx pillar file is included, and if you use Apache it should not use that it at all.

You can prevent salt from loading the nginx pillar configuration by placing an empty version of the file in the default folder with the following content:

```yaml
# File: dev/salt/pillars/defaults/nginx.sls
nginx: ~
```
