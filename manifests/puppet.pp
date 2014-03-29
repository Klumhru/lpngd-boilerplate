$www_root = "/var/www"

$project_name = 'unimods'

$project_home = "$www_root/$project_name"

$venv_home = "$project_home/venv.$project_name"

include nginx

group { "puppet":
    ensure => present
}

File{
    owner => 'www-data',
    group => 'www-data'
}

file { $www_root:
    ensure => directory,
    mode => '2775';
}
file { $project_home:
    ensure => directory,
    mode => '2775';
}

user { "vagrant":
    groups => ['www-data'],
}

package{ ['language-pack-is',
          'vim',
          'curl']:
    ensure => present
} ->
class { "postgresql::globals":
    manage_package_repo => true,
    version => '9.3',
    encoding => 'UTF8',
    locale => 'is_IS.utf-8'
} ->
class { 'postgresql::server':
    ensure => present,
} ->
package { 'libpq-dev':
    ensure => present,
} ->
class { 'python':
    dev        => true,
    pip        => true,
    virtualenv => true,
    gunicorn   => true,
} ->
python::virtualenv { $venv_home:
    requirements => "$project_home/conf/requirements.txt",
    owner => 'vagrant',
    group => 'www-data',
} ->
class { 'upstart':
    user_jobs => true,
} ->
upstart::job { "gunicorn_$project_name":
    description    => "basic runserver for $project_name",
    respawn        => true,
    respawn_limit  => '5 10',
    ensure         => 'present',
    user           => 'www-data',
    group          => 'www-data',
    chdir          => "$project_home/$project_name",
    exec           => "$venv_home/bin/python manage.py run_gunicorn -w 4 -k gevent --max-requests 1",
} ->
nginx::resource::upstream { 'gunicorn_unimods':
    members => [
        'localhost:8000'
    ]
} ->
nginx::resource::vhost { 'mods.amyingoh.org':
    proxy => 'http://gunicorn_unimods'
}
