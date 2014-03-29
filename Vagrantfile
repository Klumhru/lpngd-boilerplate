# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "precise64"
  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.ssh.forward_agent = true
  config.vm.synced_folder "../unimods", "/var/www/unimods"

  config.vm.provision :shell do |shell|
    shell.inline = <<-eos
      mkdir -p /etc/puppet/modules
      sed -ie s/us.archive.ubuntu.com/is.archive.ubuntu.com/gi /etc/apt/sources.list
      apt-get update -qq
      test -f /usr/bin/pip || apt-get install python-pip -y
      pip install --upgrade pip virtualenv
      puppet module list |grep puppetlabs-apt || puppet module install puppetlabs-apt
      puppet module list |grep puppetlabs-postgresql || puppet module install puppetlabs-postgresql
      puppet module list |grep puppetlabs-nginx || puppet module install puppetlabs-nginx
      puppet module list |grep stankevich-python || puppet module install stankevich-python
      puppet module list |grep ajcrowe-supervisord || puppet module install ajcrowe-supervisord
    eos
  end

  config.vm.provision :puppet do |puppet|
    puppet.manifest_file  = "puppet.pp"
  end
end
