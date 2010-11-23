define backuppc::client($ensure=present, $email, $username='') {
  @@line {"":
    ensure => $ensure,
    line   => "${fqdn} 0 ${email} ${username}",
    tag    => "backuppc-client",
    notify => Service["backuppc"]
  }
}
