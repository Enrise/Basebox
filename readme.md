# Enrise basebox
This box serves as a standardized version of Vagrant box and should be used for new projects.

Provisioning is done using [Saltstack](http://saltstack.org), which uses various default [Saltstack-formulas](https://github.com/saltstack-formulas) and [custom Enrise formulas](https://github.com/enrise/?query=formula) to provide featurepacks.

This box provides a default webstack (ZendServer 7.0 + Nginx + MariaDB) using the [enrise/vhosting-formula](https://github.com/enrise/vhosting-formula) formula.

Further requirements (e.g. Node, Postgres, Composer etc) can be added by the user of this box.

## Installing
Add the basebox as a Git submodule to your project from the root of your project:
```
git submodule add git@github.com:enrise/basebox dev/basebox
```
> **Note**: You may use a custom path to check it out to, but this value must also be set accordingly in `Vagrantfile.local` (parameter: $basebox_path)

Once the basebox has been added as a submodule to your project, it should pull in its own dependencies. To do so, instruct git to update in the submodules:
```
git submodule sync && git submodule update --init --recursive
```

Once this has been completed you have the basebox and its dependencies and can proceed with the configuration.

## Configuration
Once the basebox package has been installed you can proceed with its configuration.

### Vagrant
In order to benefit from base updates you should symlink the Vagrantfile to the root of your project:
```
ln -s dev/basebox/Vagrantfile .
```
You could also copy this file instead of symlinking, but this would require a manual action to update which is not recommended.

The configuration of the Vagrantbox should always be done in `Vagrantfile.local`.
A default is provided but should be copied/renamed to the root of your project:
```
cp dev/basebox/Vagrantfile.local.dist Vagrantfile.local
```
You should change the parameters (e.g. ip, hostname) to match your project before booting.

### Salt
By default Salt will install Zendserver (7.0) + Nginx once you have created vhosts. If you specify databases, it will install MySQL-server as well.

For this a dist structure has been provided which is the `salt.dist` folder located in `dev/basebox`. This will need to be copied to `./dev/salt`:
```
cp dev/basebox/salt.dist dev/salt -r
```
> **Note:** This path is configurable in `Vagrantfile.local` (parameter: $salt_custom_path)

The Salt fileserver will look for the files configured in the topfile.
For this is will search in both the "core" module as customizations.

The priority of loading is:
- Custom files
- Core files

Salt stops searching as soon as it has reached a matching file.
This may or may not be desirable so be careful with the naming of your states and files.

If you want to add custom states or pillars, you'll have to manage a custom `top.sls`. This will completely override the defaults.
> For this its also required that your topfile includes `core` and `vhosting`.

#### Custom vhosts
The `vhosts.sls` state will be loaded. In the core, this is an empty state which means no vhosts or databases will be available.

In order to get this to work you'll have to rename distributed vhost file:
```
mv dev/salt/pillars/vhosts.sls.dist dev/salt/pillars/vhosts.sls
```
and edit it accordingly. A basic vhost could look like this:
```yaml
vhosting:
  users:
    projectname:
      deploy_structure: True
      vhost:
        projectname-dev.enrise.com:
          webroot_public: True
      mysql_database:
        projectname:
          password: changeme
```

This will create paths (using default deploy structure), install the webserver, creates a vhost and enables it and creates a MySQL user/db pair.

A description of options for the vhosting is available in the [vhosting formula documentation](https://github.com/enrise/vhosting-formula).

> **Note:**: If you do not specify vhosts, no webserver will be installed. The same applies on mysql_database: no databases = no MySQL installed.

If you use the config as above it will create a folder structure:
```
/srv/http/projectname/hosts/projectname-dev.enrise.net
```

This folder (used in the vhost) contains a symlink to `../current/public`.
The only thing that remains is a symlink:
```
cd /srv/http/projectname
ln -s /vagrant current
```

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
Add a submodule in `salt/formulas` and symlink the folder (in its `name/name` form) into the states folder.
This may also be used to get newer versions of formulas since the fileserver will automatically take the custom one over the core.

#### Customizing pillars
Certain formulas may require specific pillars to change their default behavior.
For this you should use the `custom.sls` file located in the pillar folder.

#### Customizing states
If you want to extend the basebox, e.g. you have added a formula and want to use it you can customize the `custom` state.
The `custom.sls` file is located in the `states` folder and allows you to specify your own Salt states.

You can use this to include formulas or add in specific requirements for your box.

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

## Updating the basebox
Its expected that the basebox will be extended and improved from time to time.

### Automatic
Execute the following command from your git repo on your development machine:
```
./dev/basebox/update.sh
```

This will execute everything listed under the manual steps below but will automatically find the actual checkout path based on the settings in `Vagrantfile.local`.

### Manual
To pull in the changes you'll have to update the git submodule of the basebox:
```
cd dev/basebox
git pull origin master
git submodule sync  && git submodule update --init --recursive
```
> If you have the `vagrant-triggers` plugin installed it will automatically check and notify you if there are updates upon the following tasks: up, resume and provision.

## Known issues
Currently there are some known issues:
* Salt-minion service shows up as changed every run (07-01-2015). This has no adverse effects whatsoever and can be ignored safely.
