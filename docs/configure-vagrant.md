# Vagrant

In order to benefit from base updates you should symlink the Vagrantfile to the root of your project:

```sh
ln -s dev/basebox/Vagrantfile .
```

You could also copy this file instead of symlinking, but this would require a manual action to update which
is not recommended.

The configuration of the Vagrantbox should always be done in `Vagrantfile.local`.
A default is provided but should be copied/renamed to the root of your project:

```sh
cp dev/basebox/Vagrantfile.local.dist Vagrantfile.local
```

You should change the parameters (e.g. ip, hostname) to match your project before booting.
