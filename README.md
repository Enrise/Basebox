# Archived and unmaintained

This is an old repository that is no longer used or maintained. We advice to no longer use this repository.

## Original README can be found below:

# Enrise Basebox

[![Documentation](https://readthedocs.org/projects/enrise-basebox/badge/?version=master)](https://enrise-basebox.readthedocs.io/)
[![Travis branch](https://img.shields.io/travis/Enrise/Basebox/master.svg?style=flat-square)](https://travis-ci.org/Enrise/Basebox)

This box serves as a standardized version of Vagrant box and could be used to provide a standardized base for new projects.

Provisioning is done using [Saltstack](http://saltstack.org), which uses various default
[Saltstack-formulas](https://github.com/saltstack-formulas) and
[custom Enrise formulas](https://github.com/enrise/?query=formula) to provide featurepacks.

This box provides a default web-stack (Nginx + PHP + MariaDB) using the
[enrise/vhosting-formula](https://github.com/enrise/vhosting-formula) formula.
The box should be built on a Debian or Ubuntu VM.

Further requirements (e.g. Node, Postgres, Composer etc) can be added by the user of this box.

For more information and installation details check
[the documentation](https://enrise-basebox.readthedocs.io/).
