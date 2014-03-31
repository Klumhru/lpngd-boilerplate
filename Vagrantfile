# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX = "hashicorp/precise64"

# Base variables. You can set these directly in the manifests/puppet.pp
# file if you want to be able to apply the puppet file locally - see bottom for fact names
# (with sudo puppet apply manifests/puppet.pp)
WWW_ROOT = "/var/www"
PROJECT_NAME = 'unimods'
PROJECT_HOME = "#{WWW_ROOT}/#{PROJECT_NAME}"
VENV_HOME = "#{PROJECT_HOME}/venv.#{PROJECT_NAME}"
GUNICORN_SOCKET = "unix:/tmp/#{PROJECT_NAME}.gunicorn.sock"

# You can use these in your django settings if you like
DB_NAME = PROJECT_NAME
DB_USER = PROJECT_NAME
DB_PASS = "ChangeMe!"

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = BOX
  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :forwarded_port, guest: 8000, host: 8001
  config.ssh.forward_agent = true
  config.vm.synced_folder "../#{PROJECT_NAME}", "/var/www/#{PROJECT_NAME}"

  config.vm.provision :shell do |shell|
    shell.inline = <<-eos
      mkdir -p /etc/puppet/modules
      sed -ie s/us.archive.ubuntu.com/is.archive.ubuntu.com/gi /etc/apt/sources.list
      apt-get update -qq
      test -f /usr/bin/git || apt-get install git -y
      test -f /usr/bin/pip || apt-get install python-pip -y
      test -f /usr/local/bin/pip || pip install --upgrade pip virtualenv
      puppet module list |grep inkblot-github || puppet module install inkblot-github
      puppet module list |grep puppetlabs-apt || puppet module install puppetlabs-apt
      puppet module list |grep puppetlabs-postgresql || puppet module install puppetlabs-postgresql
      puppet module list |grep jfryman-nginx || puppet module install jfryman-nginx
      puppet module list |grep stankevich-python || puppet module install stankevich-python
      puppet module list |grep krakatoa-upstart || puppet module install krakatoa-upstart
    eos
  end

  config.vm.provision :puppet do |puppet|
    puppet.facter = {
      "www_root" => WWW_ROOT,
      "project_name" => PROJECT_NAME,
      "project_home" => PROJECT_HOME,
      "venv_home" => VENV_HOME,
      "gunicorn_socket" => GUNICORN_SOCKET,
      "db_name" => DB_NAME,
      "db_user" => DB_USER,
      "db_pass" => DB_PASS
    }
    puppet.manifest_file  = "puppet.pp"
  end

  config.vm.provision :shell do |shell|
    shell.inline = 'service nginx restart'
  end
end
