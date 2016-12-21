class r_profile::puppet::master::auto_sign(
    Enum['policy', 'absent', 'accept_all'] $ensure = 
      hiera('r_profile::puppet::master::auto_sign::ensure', 'absent'),
    $template = hiera('r_profile::puppet::master::auto_sign::template', "${module_name}/autosign.sh.erb"),
    $secret   = hiera('r_profile::puppet::master::auto_sign::secret',undef),
) {

  $autosign_script = "/usr/local/bin/puppet_enterprise_autosign.sh"

  if $ensure == 'policy' and ! $autosign_secret {
    fail("Cannot enable policy based autosigning without a valid shared secret")
  }

  $autosign_all_ensure = $ensure ? {
    'accept_all'  => 'present',
    default       => 'absent'
  }

  $autosign_policy_ensure = $ensure ? {
    'policy'      => 'present',
    default       => 'absent'
  }


  file { "autosign":
    ensure  => $autosign_all_ensure,
    content => "*",
    path    => "${::settings::confdir}/autosign.conf",
    notify  => Service["pe-puppetserver"]
  }

  # enable/disable autosign script in puppet.conf
  ini_setting { "puppet_conf_autosign_script":
    ensure  => $autosign_policy_ensure,
    path    => "${::settings::confdir}/puppet.conf",
    section => "master",
    setting => "autosign",
    value   => $autosign_script,
    notify  => Service["pe-puppetserver"],
  }

  # the autosigning script
  file { $autosign_script:
    ensure  => $autosign_policy_ensure,
    owner   => "root",
    group   => "pe-puppet",
    mode    => "0770",
    content => template($template),
  }
}
