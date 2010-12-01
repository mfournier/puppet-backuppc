define backuppc::client($ensure=present, $email, $username='') {
  @@common::concatfilepart {"$name":
    ensure  => $ensure,
    content => "${fqdn} 0 ${email} ${username}\n",
    tag     => "backuppc-client",
    notify  => Service["backuppc"],
    file    => "/etc/backuppc/hosts",
  }
}
