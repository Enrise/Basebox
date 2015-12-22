## Starting the VM

Ready, let's start!

Execute this in your shell:

```sh
vagrant up
```

The first boot takes some time.
The box will install Salt and runs (if enabled) the highstate which provisions the machine.

Once it has been completed, the box can be accessed:

```sh
vagrant ssh
```
