================
vhosting-formula
================

A saltstack formula to manage ... a lot actually :-).

This module has been developed with flexibility in mind and to be as least "in the way" as possible.

The ``pillar.example`` provides an complete overview of the possibilities but there is more...

.. note::
    This formula has **only been tested on Ubuntu 14.04**.
    It will most likely not work on other platforms due to hardcoded package names and Ubuntu-specific commands.

Getting started
================

The package only installs a webstack (configured as vanilla-nginx by default) when:
 * there are users with vhosts defined;
 * the force-flag (``vhosting:server:force_install_webstack``) is set to ``True``

Same applies for databases, if there is no ``mysql_database`` key underneath the users MySQL-server is not being installed.

The 'username' for DB-only has no effect (e.g. it doesn't create) system users since we won't need them and is only to allow for easy grouping.

Only one webstack is possible at the time, but multiple databases are possible (e.g. MySQL and Postgresql). Depending on the needs you could only use one or more of the components (vhosts, mysql_databases, cronjobs etc) or all. The installer automatically takes care of the installation of the necessary components to get this to work.

Configuration
================

.. contents::
    :local:

``Server``
----------------
The ``server`` part of the Pillar data contains which edition of webserver (vanilla or zendserver) and which webserver (apache or nginx) should be used.

.. code:: yaml

    vhosting:
      server:
        webserver: nginx
        edition: vanilla

.. note::
    If ``zendserver`` is being configured as edition this formula should be available and configured as well.
    This does duplicate the webserver part since this particular formula only reads its own information.
    If the formula is not available it cannot install ZendServer (and components) and if the Pillar data is missing it will install it with default values which may differ from your requirements.

``Users``
----------------
A user is only created when a 'vhost' is set, since this the only reason (currently) why
a user would be needed.

For users two individual flags can be set:

**keyhost**
           Install the key for the ``keyhost`` server *[ENRISE-ONLY]*
**deploy_structure**
           Create a ``data`` and a ``releases`` folder.
           The webroot is a symlinked to ``../releases/current`` unless the vhost is set to use 'public' (more about this later)

``Vhosts``
----------------
If at least one ``vhost`` key is specified in the user-tree of the vhosting pillar it will automatically install the configured webstack.

Vhosts depend on users.
A user will be created automatically and will be used for all of the domains that belong to this user.

The minimal configuration for a vhost is:

.. code:: yaml

    vhosting:
      users:
        example:
          vhost:
            example.com: {}


.. note::
    An empty dictionary is mandatory if no parameters are specified.
    All default values will be used instead.

The following keys can be defined:

**webroot_public**
              A boolean value (False by default) telling the webserver configuration to use `/public` as entry point.
              This is required for some frameworks such as Laravel or Zend Framework.
**webroot**
       A string with the desired webroot location. **NOT YET IMPLEMENTED**
**aliases**
       A list of aliasses (with a dash in front of them) that need to be added to the vhost.
**redirect_to**
            A string which will - if set - redirect the domain to the given URL and uses the ``redirect`` vhost.
            This may be used in conjunction with ``ssl``
**ssl**
   A dictionary containing at least ``key`` and ``cert``, optionally ``ca`` for the CA chain (required for certain SSL providers) and boolean ``forward`` to force non-ssl to SSL.
**listen_ip**
         A string containing the listen IP (any IP by default, may be set to a specific one.
         Please note: all vhosts should be explicitly set if this is being used!)
**listen_port**
           The webserver listens on port 80, can be overruled using this.
**listen_port_ssl**
               Same as ``listen_port`` but for SSL.

Depending on the vhost template more parameters may be provided (e.g for nginx: ``logdir``, ``try_files``, ``index``, ``fastcgi_pass``, ``fastcgi_params`` or ``extra_config``)

``MySQL Databases``
-------------------
If the ``mysql_database`` key is specified in the user-tree of the vhosting pillar it will automatically install MariaDB 10.0 via the built-in state.
A user can have one or more databases and will always get a 'pair' consisting of: a database, a user and the specified password.

The minimal configuration for a MySQL database is:

.. code:: yaml

    vhosting:
      users:
        example:
          mysql_database:
            example:
              password: 'topsecret'

The following keys can be defined:

**host**
    A string containing the host the grant should be made on.
    By default this is localhost, but you can set this to any host (including ``%``).
**hosts**
     A list (with a dash) containing all hosts and IP's additional grants should be created for.
     All privileges are granted with the same password as the global user.

``Cronjobs``
-------------------
Since the ``cron`` daemon is always installed and running it is not being installed by this formula.
If one or more cronjobs are specified for a user they will be installed. Cronjobs are created under the user they belong to in the tree.

The minimal configuration for a cronjob is:

.. code:: yaml

    vhosting:
      users:
        example:
          cronjob:
            example:
              cmd: '/tmp/test.sh'

If no times are set, the ``*`` value is being used (run every minute on every day etc).

Optionally the following keys can be specified:

**user**
    A string the cronjob should run as, by default the owner where the cron is placed under
**minute**
      The minute(s) the cron should run on
**hour**
    The hour(s) the cron should run on
**daymonth**
        The day of the month the cron should run on
**month**
     The month the cron should run on
**dayweek**
       The day of the week the cron should run on
**comment**
       An optional comment

Extending
================
The formula is very flexible. It allows you simply extend the system by configuring more in Pillar and creating macro-files.

It makes use of macro's placed in the ``resources`` folder which all provide the ``create`` macro.
For instance if you want redis databases to be created, create ``redis_database.sls`` in the resources folder and execute all configured commands in this macro.

In some cases you may need to retrieve additional information from pillars (e.g 'higher' values).

.. code:: jinja

    {% macro create(salt, baseconf, owner, params={}, name=None) %}
    # Do stuff here.
    {% endmacro %}

Description of the macro parameters:

**salt**
       The ``salt`` object can be used to query Salt directly (grains, pillars) which is not possible in macro's otherwise.
**baseconf**
       This exposes the ``webstack`` generated in the ``map.jinja`` containing paths/defaults depending on the enviroment.
**owner**
       The key this object is located under, which is generally considered the owner of the resource.
**params**
       A single-value (string, bool) or a dictionary consisting of the given params. If it is a dictionary it can be queried like ``params.get('keyname', 'default_value)``.
**name**
       An optional parameter which may contain a the individual key name (in case of nested-dictionaries such as implemented with the vhosts or mysql_databases which are available by default.
