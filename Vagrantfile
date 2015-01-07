# -*- mode: ruby -*-
# vi: set ft=ruby :

# You can set these variables in ~/.vagrant.d/Vagrantfile, if you wish to change the defaults.
# or override these values in a Vagrantfile.local.
$vm_memory        ||= "1024"
$vm_cpus          ||= nil
$use_nfs          ||= true
$vm_hostname      ||= 'unconfigured.vagrant.box'
$vm_aliases       ||= nil
$vm_ip            ||= '192.168.56.100'
$salt_highstate   ||= true
$salt_custom_path ||= "salt"
$salt_root        ||= nil

# Determine where Salt is located
if File.exists?("node_modules/enrise-basebox")
  $salt_root = "node_modules/enrise-basebox"
elsif File.exists?("vendor/enrise/basebox")
  $salt_root = "vendor/enrise/basebox"
end

# Salt path with custom configs
if not File.exists?($salt_custom_path)
  Dir.mkdir($salt_custom_path)
end

# Include Vagrantfile.local if it exists to overwrite the variables.
if File.exists?("Vagrantfile.local")
  eval File.read("Vagrantfile.local")
end

# Use nfs by default, but don't if $use_nfs is false.
$type = $use_nfs ? "nfs" : nil

Vagrant.configure("2") do |config|
  # Configure the hostname.
  hostname = $vm_hostname

  config.vm.box = "ubuntu/trusty64"

  config.vm.hostname = hostname
  config.vm.network "private_network", ip: $vm_ip
  config.ssh.forward_agent = true

  config.vm.synced_folder ".", "/vagrant", type: $type

  if !$vm_aliases.nil?
    aliases = [
      $vm_aliases
    ]
  end

  # Create synchronised folders for salt.
  config.vm.synced_folder $salt_root + "/salt", "/srv/salt/base", type: $type
  config.vm.synced_folder $salt_custom_path, "/srv/salt/custom", type: $type

  config.vm.provider "virtualbox" do |v|
    v.name = hostname

    v.customize [
      "modifyvm", :id,
      "--natdnshostresolver1", "on",
      "--natdnsproxy1", "on",
      "--memory", $vm_memory,
    ]

    if !$vm_cpus.nil?
      v.customize [
        "modifyvm", :id,
        "--cpus", $vm_cpus,
      ]
    end
  end

  # Add aliases to the hosts-file.
  if Vagrant.has_plugin?("vagrant-hostsupdater")
    config.hostsupdater.aliases = aliases
  end

  # Apt-cache for SPEED.
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box

    if $type == "nfs" then
      config.cache.synced_folder_opts = {
        type: $type,
        mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
      }
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
    salt.minion_config = $salt_root + "/salt/minion"
    salt.run_highstate = $salt_highstate

    salt.colorize = true
    salt.log_level = "info"
    salt.verbose = true
  end

end
