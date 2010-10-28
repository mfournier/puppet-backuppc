class backuppc {
  package {"backuppc":
    ensure => present,
  }
  
  file  {"/etc/backuppc/config.pl":
    content => template("backuppc/config.pl.erb"),
    ensure => present,
    owner => backuppc,
    group => www-data,
    require => Package['backuppc']
  }

  Line <<| tag == "backuppc-client" |>> 

}
