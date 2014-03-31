LNGD Boilerplate
=======

This is a simple Linux Nginx Gunicorn Django boilerplate Vagrant setup.

# Installation

Start by cloning and removing the git binding
````
git clone git@github.com:Klumhru/lngd-boilerplate.git <projecname>
cd <projectname>
rm -rf .git
git init # optional
````

Edit Vagrantfile and set PROJECT_NAME to whatever you want. Feel free to edit the other configuration variables if you like. Run vagrant.
````
vagrant up
````

Connect to your new box
````
vagrant ssh
````

By default the vagrant box will bind its http port to you local 8080 so point your browser to:
````
http://localhost:8080
````

# Hacking the config

The project is set up as your project name and then run from gunicorn pointing to the default manage.py script with the command run_gunicorn. The gunicorn is set to run on a socket but you can change that in the Vagrantfile.

Some puppet and vagrant knowledge is assumed.

# Production

The puppet.pp script is not standalone and requires facts set by the Vagrant file.

To deploy your project you can hack the puppet.pp file to set local variables if you want.

# Supported platforms

The Vagrant file has been tested on Ubuntu primarily (12.04, 13.10) and windows (yes, really).