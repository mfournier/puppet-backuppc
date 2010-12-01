/*

== Definition: backuppc::client

Add a backuppc client to the hosts file of the server. Server is selected by $tag
*/
define backuppc::client($ensure=present, $email, $username='', $tag='backuppc-client') {
  # Write a line in server hosts file for every client
  @@common::concatfilepart {"$name":
    ensure  => $ensure,
    content => "${fqdn} 0 ${email} ${username}\n",
    tag     => $tag,
    notify  => Service["backuppc"],
    file    => "/etc/backuppc/hosts",
  }
}
