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
    owner => 'vagrant', group => 'vagrant',
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
postgresql::server::role { $db_user:
    password_hash => postgresql_password($db_user, $db_pass),
    login => true,
    createdb => true,
} ->
postgresql::server::database { $db_name:
    owner => $db_user,
}
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
    environment    => {
        'DB_NAME' => $db_name,
        'DB_USER' => $db_user,
        'DB_PASS' => $db_pass,
    },
    chdir          => "$project_home/$project_name",
    exec           => "$venv_home/bin/python manage.py run_gunicorn -w 4 -k gevent -b $gunicorn_socket --max-requests 1",
} ->
file { "nginx_vhost_$project_name":
    owner => vagrant, group => vagrant,
    path => "$project_home/conf/nginx_vhost.conf",
    content => template("$project_home/manifests/nginx_vhost.conf.erb"),
} ->
file { "nginx_vhost_$project_name-link":
    owner => root, group => root,
    ensure => link,
    path => "/etc/nginx/sites-enabled/$project_name.vhost.conf",
    target => "$project_home/conf/nginx_vhost.conf",
}

File["nginx_vhost_$project_name"] ~> Service['nginx']
