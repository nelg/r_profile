# R_profile::Web_service::Tomcat
#
# Install and configure tomcat application server
class r_profile::web_service::tomcat(
    $source_url       = 'http://apache.mirror.amaze.com.au/tomcat/tomcat-8/v8.5.14/bin/apache-tomcat-8.5.14.tar.gz',
    $catalina_home    = '/opt/tomcat',
    $service          = 'tomcat',
    $user             = 'tomcat',
    $group            = 'tomcat',
    $port             = 8080,
    $lb               = true,
    $nagios_monitored = true,
    $open_firewall    = false,
){

  # for processing .war files
  ensure_packages('unzip', {'ensure' => 'present'})

  include r_profile::java

  class { 'tomcat':
    catalina_home => $catalina_home,
    user          => $user,
    group         => $group,
  }

  tomcat::install { $catalina_home:
    source_url => $source_url,
  }

  tomcat::service { $service:
    require => Tomcat::Install[$catalina_home]
  }

  if $lb {

    # setup the FACT that will tell us what IP address to use (run n)
    if is_string($lb) {
      $lb_address = $lb
    } else {
      # attempt to lookup which nodes are classified as Haproxies and use first
      # check storedconfigs to ensure we are not running under rspec/puppet apply
      $lb_addresses = $::settings::storeconfigs ? {
        true    => query_nodes('Class[R_profile::Monitor::Haproxy]'),
        default => false,
      }
      if is_array($lb_addresses) {
        $lb_address = $lb_addresses[0]
      } else {
        $lb_address = false
      }
    }

    if $lb_address and is_string($lb) {
      $source_ip = $source_ipaddress[$lb_address]
    } else {
      $source_ip = undef
    }

    # export the IP address (run n+1)
    @@haproxy::balancermember { "${service}-${::fqdn}":
      listening_service => 'tomcat',
      server_names      => $::fqdn,
      ipaddresses       => $source_ip,
      ports             => $port,
      options           => 'check',
    }

    # runs will be collected on the loadbalancer next time it runs puppet
  }

  if $nagios_monitored {
    nagios::nagios_service_http { 'tomcat':
      port => $port,
      url  => '/',
    }
  }

  if $open_firewall and !defined(Firewall["100 ${::fqdn} HTTP ${port}"]) {
    firewall { "100 ${::fqdn} HTTP ${port}":
      dport  => $port,
      proto  => 'tcp',
      action => 'accept',
    }
  }
}
