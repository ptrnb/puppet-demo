# vim: set filetype=ruby : #
Vagrant.configure("2") do |config|
  config.vm.box = "puppetlabs/centos-7.0-64-puppet"

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.
  config.vm.synced_folder "share", "/vagrant-share"
  config.vm.synced_folder "puppet", "/puppet"

  config.vm.network "forwarded_port", guest: 80, host: 9080
  config.vm.network "forwarded_port", guest: 443, host: 9443 

  config.vm.host_name = "pnb.vagrant.example"
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "512"]
  end

  config.vm.provision "shell", path: "share/scripts/bootstrap-centos.sh"

  config.vm.provision "puppet" do |puppet|
    puppet.environment = "production"
    puppet.environment_path = "../../"
    puppet.manifests_path = "puppet/manifests"
    puppet.module_path = "puppet/modules"
    puppet.manifest_file = "site.pp"
  end
end
