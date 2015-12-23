# Installing

Add the basebox as a Git submodule to your project from the root of your project:

```sh
git submodule add git@github.com:enrise/basebox dev/basebox
```

> **Note**: You may use a custom path to check it out to, but this value must also be set accordingly in
`Vagrantfile.local` (parameter: $basebox_path)

Once the basebox has been added as a submodule to your project, it should pull in its own dependencies. To do so,
instruct git to update in the submodules:

```sh
git submodule sync && git submodule update --init --recursive
```

Once this has been completed you have the basebox and its dependencies and can proceed with the configuration.
