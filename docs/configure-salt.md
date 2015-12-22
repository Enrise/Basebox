# Salt

By default Salt will install Zendserver (7.0) + Nginx once you have created vhosts. If you specify databases, it
will install MySQL-server as well.

For this a dist structure has been provided which is the `salt.dist` folder located in `dev/basebox`. This will
need to be copied to `./dev/salt`:

```sh
cp -r dev/basebox/salt.dist dev/salt
```

> **Note:** This path is configurable in `Vagrantfile.local` (parameter: $salt_custom_path)

The Salt fileserver will look for the files configured in the topfile.
For this is will search in both the "core" module as customizations.

The priority of loading is:

1. Custom files
1. Core files

Salt stops searching as soon as it has reached a matching file.
This may or may not be desirable so be careful with the naming of your states and files.

If you want to add custom states or pillars, you'll have to manage a custom `top.sls`.
This will completely override the defaults.

> For this its also required that your topfile includes `core` and `vhosting`.

## Custom vhosts

The `vhosts.sls` state will be loaded. In the core, this is an empty state which means no vhosts or databases
will be available.

In order to get this to work you'll have to rename distributed vhost file:

```sh
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

This will create paths (using default deploy structure), install the webserver, creates a vhost and enables
it and creates a MySQL user/db pair.

A description of options for the vhosting is available in the
[vhosting formula documentation](https://github.com/enrise/vhosting-formula).

> **Note:**: If you do not specify vhosts, no webserver will be installed. The same applies on mysql_database:
> no databases = no MySQL installed.

If you use the config as above it will create a folder structure:

```sh
/srv/http/projectname/hosts/projectname-dev.enrise.net
```

This folder (used in the vhost) contains a symlink to `../current/public`.
The only thing that remains is a symlink:

```sh
cd /srv/http/projectname
ln -s /vagrant current
```

## Custom webserver

Default behavior (e.g. Zendserver+Nginx) can be overruled by creating a file in `salt/pillars/defaults` with
just the information you want to override or extend.

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

> **Note:** When changing webservers and using the `vhosting` module, do not forget to override its
> configuration as well (in `defaults/vhosting.sls`)

The custom file will always take precedence.

## Adding formulas

Its recommended to use git submodules.
Add a submodule in `salt/formulas` and symlink the folder (in its `name/name` form) into the states folder.
This may also be used to get newer versions of formulas since the fileserver will automatically take the
custom one over the core.

## Customizing pillars

Certain formulas may require specific pillars to change their default behavior.
For this you should use the `custom.sls` file located in the pillar folder.

## Customizing states

If you want to extend the basebox, e.g. you have added a formula and want to use it you can customize
the `custom` state. The `custom.sls` file is located in the `states` folder and allows you to specify
your own Salt states.

You can use this to include formulas or add in specific requirements for your box.
