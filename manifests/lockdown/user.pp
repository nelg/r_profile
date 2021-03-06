# R_profile::Lockdown::User
#
# Lockdown users by disabling their passwords and or shells.  Alternatively, we
# will remove all users named in the delete parameter.  Note that it is an error
# to attempt to both disable and remove a user, since disabling requires that
# the user still be present to update /etc/shadow and /etc/password.  This will
# manifest as a duplicate declaration error if encountered in the field.
#
# @param disable_password Array of usernames who should have their password locked
# @param disable_shell Array of usernames who should have their shell disabled
# @param delete Array of usernames who should be deleted from the system
class r_profile::lockdown::user(
    Array[String] $disable_password = hiera("r_profile::lockdown::user::disable_password", []),
    Array[String] $disable_shell    = hiera("r_profile::lockdown::user::disable_shell", []),
    Array[String] $delete           = hiera("r_profile::lockdown::user::delete", []),
) {

  # figure out what unique users we have across both passed in arrays and then
  # change each user resource once, as required
  unique(concat($disable_password, $disable_shell)).each | $user | {
    if $user in $disable_password {
      $_disable_password = '*'
    } else {
      $_disable_password = undef
    }

    if $user in $disable_shell {
      $_disable_shell = '/usr/bin/false'
    } else {
      $_disable_shell = undef
    }

    user { $user:
      password => $_disable_password,
      shell    => $_disable_shell,
    }
  }

  user { $delete:
    ensure => absent,
  }
}
