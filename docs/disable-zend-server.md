# Disable zend server

If you want to use the Basebox without Zend Server, that is very possible. There are some tips and tricks
on how you can achieve this.

## Overwriting defaults

In this example we will be using Vanilla instead of Zend Server. To disable Zend Server we need to override
some default config files. Once those are overriden by your default files, Zend Server should no longer get installed.

- `./[dev/salt/]pillars/defaults/phpfpm.sls`

```yaml
phpfpm: ~
```

- `./[dev/salt/]pillars/defaults/vhosting.sls`

```yaml
vhosting:
  server:
    webserver: nginx
    webserver_edition: vanilla
```

## Installing php-cli

Without the Zend Server package, no PHP command line interface is installed. We need to add this manually.
The Basebox installation includes the installation of composer, it is important that we add the php-cli module
before we install the composer package. To do so, add the following to your `./[dev/salt/]states/custom.sls`:

```yaml
install-php-cli:
  pkg.installed:
    - pkgs:
      - php5-cli
    - require_in:
      - cmd: get-composer
      - cmd: install-composer
```

## Build the box

If you already built your box before, you might want to remove your box and make sure you have a clean start.

```sh
vagrant destroy
```

If you're ready to give it another go, run

```sh
vagrant up
```

After everything installed successfully you should be running a web-server without Zend Server.
