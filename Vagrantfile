# -*- mode: ruby -*-
# vi: set ft=ruby :

# You can set these variables in ~/.vagrant.d/Vagrantfile, if you wish to change the defaults.
# or override these values in a Vagrantfile.local.
$vm_memory                ||= 1024
$vm_cpus                  ||= 1
$vm_linked_clone          ||= true
$mount_type               ||= 'virtualbox'
$mount_options_virtualbox ||= ['dmode=777', 'fmode=777']
$mount_options_nfs        ||= ['vers=3', 'nolock', 'rw', 'tcp', 'fsc', 'actimeo=2']
$mount_options_rsync      ||= []
$vm_hostname              ||= 'unconfigured.vagrant.box'
$vm_box                   ||= 'ubuntu/trusty64'
$vm_aliases               ||= nil
$vm_mounts                ||= { '.' => '/vagrant' }
$vm_ip                    ||= '192.168.56.100'
$basebox_path             ||= 'dev/basebox'
$salt_highstate           ||= true
$salt_custom_path         ||= 'dev/salt'
$salt_log_level           ||= 'info'
$salt_verbose             ||= true
$salt_version             ||= 'stable'
$salt_bootstrap_options   ||= '-P -X -x python3.6'
$salt_install_args        ||= ''
$salt_version             ||= 'stable 3003'

# Include Vagrantfile.local if it exists to overwrite the variables.
eval File.read('Vagrantfile.local') if File.exist?('Vagrantfile.local')

Vagrant.configure('2') do |config|
  # Configure the hostname.
  hostname = $vm_hostname

  config.vm.box = $vm_box

  config.vm.hostname = hostname
  config.vm.network 'private_network', ip: $vm_ip
  config.ssh.forward_agent = true

  config.vm.define $vm_hostname do |_t|
  end

  # Mounts
  if $mount_type == 'virtualbox'
    $vm_mounts.each do |source_path, target_path|
      config.vm.synced_folder source_path, target_path, owner: 'vagrant', group: 'vagrant', type: 'virtualbox', mount_options: $mount_options_virtualbox
    end
    config.vm.synced_folder $basebox_path + '/salt', '/srv/salt/base', type: 'virtualbox'
    if File.exist?($salt_custom_path)
      config.vm.synced_folder $salt_custom_path, '/srv/salt/custom', type: 'virtualbox'
    end
  end

  if $mount_type == 'nfs'
    $vm_mounts.each do |source_path, target_path|
      config.vm.synced_folder source_path, target_path, type: 'nfs', mount_options: $mount_options_nfs
    end

    config.vm.synced_folder $basebox_path + '/salt', '/srv/salt/base', type: 'nfs', mount_options: $mount_options_nfs
    if File.exist?($salt_custom_path)
      config.vm.synced_folder $salt_custom_path, '/srv/salt/custom', type: 'nfs', mount_options: $mount_options_nfs
    end
  end

  if $mount_type == 'rsync'
    # TODO: Add the proper rsync mounts in the future if this is being used.
    # If the need arises, we gladly accept PRs or work with you on adding this!
  end

  config.vm.provider :virtualbox do |v|
    v.linked_clone = $vm_linked_clone if Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new('1.8.0')
    v.customize [
      'modifyvm', :id,
      '--natdnshostresolver1', 'on',
      '--natdnsproxy1', 'on',
      '--memory', $vm_memory,
      '--cpus', $vm_cpus
    ]
  end

  config.vm.provider :libvirt do |v|
    v.memory = $vm_memory
    v.cpus = $vm_cpus
    v.cpu_mode = 'host-passthrough'
  end

  # Add aliases to the hosts-file.
  if Vagrant.has_plugin?('vagrant-hostsupdater')
    # Deal with aliases if set (used in hosts updater)
    aliases = $vm_aliases unless $vm_aliases.nil?
    config.hostsupdater.aliases = aliases
  end

  # Apt-cache for SPEED.
  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :box

    if $mount_type == 'nfs'
      config.cache.synced_folder_opts = {
        type: 'nfs',
        mount_options: $mount_options_nfs
      }
    else
      config.cache.auto_detect = true
    end
  end

  # Check if vagrant-triggers is available for update checks (for Vagrant < 2.1.0)
  if Vagrant.has_plugin?('vagrant-triggers')
    {
      [:up, :resume, :provision] => $basebox_path + '/check_update.sh'
    }.each do |command, trigger|
      config.trigger.before command, stdout: true do
        run trigger.to_s
      end
    end
  end

  # Do update checks natively if Vagrant >= 2.1.0 is being used
  if Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new('2.1.0')
    config.trigger.before :up, :resume, :provision,
      run: {path: $basebox_path + '/check_update.sh'}
  end

  config.vm.post_up_message = <<MSG
  Your Vagrant box is now ready to be used!

  Please see the the readme of the basebox for instructions on how to customize this VM.
  Afterwards either run "vagrant provision" or "salt-call state.highstate" from inside the box to apply the config.

  Type "vagrant ssh" to login to the shell.
MSG

  # Temp fix for Vagrant 1.8.5
  if Vagrant::VERSION =~ /^1.8.5/
    config.vm.provision "shell",
      inline: "chmod 0600 /home/vagrant/.ssh/authorized_keys"
  end

  # And start the provisioning run!
  config.vm.provision :salt do |salt|
    salt.minion_config = $basebox_path + '/salt/minion'
    salt.run_highstate = $salt_highstate

    salt.bootstrap_options = $salt_bootstrap_options
    salt.install_args = $salt_version + ' ' + $salt_install_args

    salt.colorize = true
    salt.log_level = $salt_log_level
    salt.verbose = $salt_verbose
  end

end
