group { "puppet":
    ensure => present
}

File{
    owner => 'www-data',
    group => 'www-data'
}

file { "/var/www":
    ensure => directory,
    mode => '2775';
}
file { "/var/www/unimods":
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

}
