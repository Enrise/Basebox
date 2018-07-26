# Updating the basebox

Its expected that the Basebox will be extended and improved from time to time.

## Automatically

Execute the following command from your git repo on your development machine:

```sh
./dev/basebox/update.sh
```

This will execute everything listed under the manual steps below but will automatically find the actual checkout path
based on the settings in `Vagrantfile.local`.

## Manually

To pull in the changes you'll have to update the git submodule of the basebox:

```sh
cd dev/basebox
git pull origin master
git submodule sync  && git submodule update --init --recursive
```

> **Hint**: If you have the `vagrant-triggers` plugin installed (only required for Vagrant < 2.1.0) it will automatically check and notify you if there are
> updates upon the following tasks: up, resume and provision.
