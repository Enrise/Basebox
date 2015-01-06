# Enrise basebox
This box serves as a standardized version of Vagrant box and should be used for new projects.

Provisioning is done using [Saltstack](http://saltstack.org), which uses various default [Saltstack-formulas](https://github.com/saltstack-formulas) and [custom Enrise formulas](https://github.com/enrise/?query=formula) to provide featurepacks.

This box provides a default webstack (ZendServer 7.0 + Nginx + MariaDB) using the [enrise/vhosting](https://github.com/enrise/vhosting) formula.

Further requirements (e.g. Node, Postgres, Composer etc) can be added by the user of this box.

## Installing
### Using Composer

Add the repository and require the package:
```
composer config repositories.enrise-basebox vcs git@github.com:enrise/basebox.git
composer require enrise/basebox:dev-master
```

### Using npm
This package is also npm compatible.

In order to install it, run the following command from the root of your project:
```
npm install enrise/basebox
```

## Configuration
Once the vendor package has been installed you can proceed with its configuration.

### Vagrant
In order to benefit from base updates you should symlink the Vagrantfile to the root of your project:
```
ln -s vendor/enrise/basebox/Vagrantfile .
```
> If you have installed it via NPM you should use `node_modules/enrise-basebox/Vagrantfile` instead.

You can also copy the file, but this would require a manual action to update.

Configuration for the Vagrantfile is being dealt with via `Vagrantfile.local`.
A default is provided but should be renamed from the base:
```
cp vendor/enrise/basebox/Vagrantfile.local.dist Vagrantfile.local
```
You should change the parameters to match your project.

### Salt
By default Salt will install Zendserver + Nginx and creates a vhost called "project-dev.enrise.com". If you want to override this, or do not want it to do the defaults you'll need to customize it.

For this a dist structure has been provided which is the `salt.dist` folder located in either `vendor/enrise/basebox` or `node_modules/enrise-basebox`.
This will need to be **copied** to the root of your project.

The Salt fileserver will look for the files configured in the topfile. For this is will search in both the "core" module as customizations.

The priority of loading is:
- Custom files
- Core files

Salt stops searching as soon as it has reached a matching file.
This may or may not be desirable so be careful with the naming of your states and files.

If you want to add custom states or pillars, you'll have to manage a custom `top.sls`. This will completely override the defaults.

If you only want to modify the vhost/domains created you should create a file named `salt/pillars/project.sls` and configure it using the custom [enrise/vhosting](https://github.com/enrise/vhosting) package.

#### Custom vhosts
By default `vhosts.sls` is loaded wich contains a default vhost based on the [enrise/vhosting](https://github.com/enrise/vhosting) package:
```yaml
vhosting:
  users:
    project:
      deploy_structure: True
      vhost:
        project-dev.enrise.com:
          webroot_public: True
      mysql_database:
        project:
          password: changeme
```

Its recommended to create `salt/vhosts.sls` in your custom folder and configure it as you see fit. It will be loaded instead of the default.

> **Note:**: If you do not specify vhosts, no webserver will be installed. The same applies on mysql_database: no databases = no MySQL installed.

#### Custom webserver
Default behavior (e.g. Zendserver+Nginx) can be overruled by creating a file in `salt/pillars/defaults` with just the information you want to override or extend.

For instance, the default is Zendserver + Nginx:
```yaml
# Zendserver
zendserver:
  version:
    zend: 7.0
  webserver: nginx
  bootstrap: False
```

But you want Apache2 (on Ubuntu so its 2.4, requiring a special ZS Repo).
Create `salt/pillars/defaults/zendserver.sls` and set the changed value:

```yaml
zendserver:
  webserver: apache2  
  version:
    apache: 2.4
```
> **Note:** When changing webservers and using the `vhosting` module, do not forget to override its configuration as well (in `defaults/vhosting.sls`)

The custom file will always take precedence.

#### Adding formulas
Its recommended to use git submodules.
Add a submodule in `salt/formulas` and symlink the folder (in its `name/name` form) into the states folder. This may also be used to get newer versions of formulas since the fileserver will automatically take the custom one over the core.

## Starting the VM

Ready, let's start!

Execute this in your shell:
```
vagrant up
```

The first boot takes some time.
The box will install Salt and runs (if enabled) the highstate which provisions the machine.

Once it has been completed, the box can be accessed:

```
vagrant ssh
```
