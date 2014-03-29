$www_root = "/var/www"

$project_name = 'unimods'

$project_home = "$www_root/$project_name"

$venv_home = "$project_home/venv.$project_name"

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
          'vim']:
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
}
