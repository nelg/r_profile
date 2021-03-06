# R_profile::Linux::Apt
#
# Setup of apt package manager
class r_profile::linux::apt(
    $include_src      = true,
    $auto_update      = true,
    $update_hour      = fqdn_rand(23),
    $update_minute    = fqdn_rand(59),
    $update_month     = "*",
    $update_monthday  = "*",
    $update_weekday   = "*",
) {
  class { "apt":
    purge  =>  {
      "sources.list"  => true,
    },
    update => {
      frequency       => 'daily',
    },
  }

  # only for ubuntu with lsb-release package installed...
  if $lsbdistcodename {
    case $operatingsystem {
      "Ubuntu": {
        $releases          = [
          $lsbdistcodename,
          "${::lsbdistcodename}-updates",
          "${::lsbdistcodename}-security",
        ]
        $repos             = "main restricted universe multiverse"
        $security_repos    = $repos
        $default_location  = "http://archive.ubuntu.com/ubuntu/"
        $security_location = "http://security.ubuntu.com/ubuntu/"
        $security_release  = "${::lsbdistcodename}-security"
      }
      "Debian": {
        $releases          = [
          $lsdbdistcodename,
          "${::lsbdistcodename}-updates",
          "${::lsbdistcodename}-backports",
        ]
        $repos             = "main" # removed non-free
        $security_repos    = "main"
        $default_location  = "http://ftp.debian.org/debian/"
        $security_location = "http://security.debian.org/"
        $security_release  = "${::lsbdistcodename}/updates"
      }
      default: {
        fail("Class ${name} does not support ${operatingsystem}")
      }
    }

    $os = downcase($operatingsystem)
    $location = hiera(
      "r_profile::apt::${os}::location",
      $default_location
    )

    # regular updates for each release
    $releases.each | $release | {
      apt::source { "apt_archive_${::lsbdistcodename}-${release}":
        location    => $location,
        release     => $release,
        repos       => $repos,
        include_src => $include_src,
      }
    }

    # security updates - always from main servers
    apt::source { "apt_security":
      location    => $security_location,
      release     => $security_release,
      repos       => $security_repos,
      include_src => $include_src,
    }
  }

  if $auto_update {
    cron { "apt_auto_update":
      ensure      => present,
      command     => "apt-get update && apt-get upgrade -y",
      user        => "root",
      environment => "PATH=/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin",
      hour        => $update_hour,
      minute      => $update_minute,
      month       => $update_month,
      monthday    => $update_monthday,
      weekday     => $update_weekday,
    }
  }

}
