# R_profile::Nginx
#
# Support for Nginx webserver
class r_profile::nginx {
  class { "::nginx": }

  $www_root = "/var/nginx/nginx-default"

  #
  # Default virtual host
  #
  nginx::resource::server { $fqdn:
    listen_options => "default_server",
    www_root       => $www_root,
  }

  File {
    owner => "root",
    group => "root",
    mode  => "0755",
  }

  file { $www_root:
    ensure  => directory,
    require => Class["::nginx"],
  }

  #  nginx::resource::upstream { 'lsdserver':
  #    members => [
  #      'localhost:3000',
  #    ],
  #  }
  #
  #  nginx::resource::vhost { 'lsdserver.lan.asio':
  #    proxy => 'http://lsdserver',
  #  }
}
