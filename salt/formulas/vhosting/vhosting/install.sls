#!py
def run():
    '''
    Install roles based on which features are configured
    '''
    packages = []

    for user, user_services in __salt__['pillar.get']('vhosting:users', {}).iteritems():
      if 'vhost' in user_services:
        packages.append('vhosting.webstack')
      if 'mysql_database' in user_services:
        packages.append('mariadb')

    if __salt__['pillar.get']('vhosting:server:force_install_webstack', False) == True:
      packages.append('vhosting.webstack')

    return {'include': packages}
