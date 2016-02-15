# -*- mode: ruby -*-
# vi: set ft=ruby :

# You can set these variables in ~/.vagrant.d/Vagrantfile, if you wish to change the defaults.
# or override these values in a Vagrantfile.local.
$vm_memory                ||= 1024
$vm_cpus                  ||= 1
$mount_type               ||= "virtualbox"
$mount_options_virtualbox ||= ["dmode=777", "fmode=777"]
$mount_options_nfs        ||= ["actimeo=2"]
$mount_options_rsync      ||= []
$vm_hostname              ||= "unconfigured.vagrant.box"
$vm_box                   ||= "ubuntu/trusty64"
$vm_aliases               ||= nil
$vm_ip                    ||= "192.168.56.100"
$basebox_path             ||= "dev/basebox"
$salt_highstate           ||= true
$salt_custom_path         ||= "dev/salt"
$salt_log_level           ||= "info"
$salt_verbose             ||= false

# Include Vagrantfile.local if it exists to overwrite the variables.
if File.exists?("Vagrantfile.local")
  eval File.read("Vagrantfile.local")
end

Vagrant.configure("2") do |config|
  # Configure the hostname.
  hostname = $vm_hostname

  config.vm.box = $vm_box

  config.vm.hostname = hostname
  config.vm.network "private_network", ip: $vm_ip
  config.ssh.forward_agent = true

  config.vm.define $vm_hostname do |t|
  end

  # Mounts
  if $mount_type == "virtualbox"
    config.vm.synced_folder ".", "/vagrant", owner: "vagrant", group: "vagrant", type: "virtualbox", mount_options: $mount_options_virtualbox
    config.vm.synced_folder $basebox_path + "/salt", "/srv/salt/base", type: "virtualbox"
    if File.exists?($salt_custom_path)
      config.vm.synced_folder $salt_custom_path, "/srv/salt/custom", type: "virtualbox"
    end
  end

  if $mount_type == "nfs"
    config.vm.synced_folder ".", "/vagrant", type: "nfs", mount_options: $mount_options_nfs
    config.vm.synced_folder $basebox_path + "/salt", "/srv/salt/base", type: "nfs"
    if File.exists?($salt_custom_path)
      config.vm.synced_folder $salt_custom_path, "/srv/salt/custom", type: "nfs"
    end
  end

  if $mount_type == "rsync"
    # Todo : Add the proper rsync mounts in the future if this is being used.
    # If the need arises, we gladly accept PRs or work with you on adding this!
  end

  config.vm.provider :virtualbox do |v|
    v.customize [
      "modifyvm", :id,
      "--natdnshostresolver1", "on",
      "--natdnsproxy1", "on",
      "--memory", $vm_memory,
      "--cpus", $vm_cpus,
    ]
  end

  config.vm.provider :libvirt do |v|
    v.memory = $vm_memory
    v.cpus = $vm_cpus
  end

  # Add aliases to the hosts-file.
  if Vagrant.has_plugin?("vagrant-hostsupdater")
    # Deal with aliases if set (used in hosts updater)
    if !$vm_aliases.nil?
      aliases = $vm_aliases
    end
    config.hostsupdater.aliases = aliases
  end

  # Apt-cache for SPEED.
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box

    if $mount_type == "nfs" then
      config.cache.synced_folder_opts = {
        type: "nfs",
        mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
      }
    end
  end

  # Check if vagrant-triggers is available for update checks
  if Vagrant.has_plugin?("vagrant-triggers")
    {
      [:up, :resume, :provision] => $basebox_path + "/check_update.sh",
    }.each do |command, trigger|
      config.trigger.before command, :stdout => true do
        run "#{trigger}"
      end
    end
  end

  config.vm.post_up_message = <<MSG
  Your Vagrant box is now ready to be used!

  Please see the the readme of the basebox for instructions on how to customize this VM.
  Afterwards either run "vagrant provision" or "salt-call state.highstate" from inside the box to apply the config.

  Type "vagrant ssh" to login to the shell.
MSG

  # And start the provisioning run!
  config.vm.provision :salt do |salt|
    salt.minion_config = $basebox_path + "/salt/minion"
    salt.run_highstate = $salt_highstate

    # Start Temporary Workaround for Vagrant Issues #6011, #6029
    salt.install_args = "-P"
    salt.bootstrap_options = "-F -c /tmp -P"
    # End Temporary Workaround

    salt.colorize = true
    salt.log_level = $salt_log_level
    salt.verbose = $salt_verbose
  end

end
