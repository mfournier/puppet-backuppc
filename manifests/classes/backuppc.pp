class backuppc {
  include apache
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

  apache::vhost{"$fqdn":
    ensure => present,
  }

  apache::directive {"backuppc":
    ensure => present,
    vhost => $fqdn,
    directive => "Alias /backuppc /usr/share/backuppc/cgi-bin
<Location /backuppc>
    Options ExecCGI FollowSymlinks
    AddHandler cgi-script .cgi
    DirectoryIndex index.cgi
</Location>
",
  }
  
  apache::auth::basic::ldap{"backuppc":
    ensure => present,
    vhost => $fqdn,
    location => "/backuppc",
    authLDAPUrl => 'ldap://ldap.lsn.camptocamp.com ldap.cby.camptocamp.com/dc=ldap,dc=c2c?uid??(|(gidNumber=1029)(sambaSID=*))',
    authLDAPGroupAttribute => "memberUid",
  }

  file {"/var/lib/backuppc/.ssh":
    ensure => directory,
    require => Package["backuppc"],
    owner => backuppc,
    group => backuppc,
    mode => "0755",
  }

  file {"/var/lib/backuppc/.ssh/id_rsa":
    ensure => present,
    content => $backuppc_ssh_prv_key,
    owner => backuppc,
    group => backuppc,
    require => File["/var/lib/backuppc/.ssh"],
    mode    => "0600",
  }

  file {"/var/lib/backuppc/.ssh/id_rsa.pub":
    ensure => present,
    content => $backuppc_ssh_pub_key,
    owner => backuppc,
    group => backuppc,
    require => File["/var/lib/backuppc/.ssh"]
  }

  file {"/var/lib/backuppc/.ssh/config":
    ensure => present,
    owner => backuppc,
    group => backuppc,
    content => "Host *\n\tStrictHostKeyChecking no",
    require => File["/var/lib/backuppc/.ssh"]
  }

  @@ssh_authorized_key {"$fqdn":
    ensure => present,
    type => ssh-rsa,
    key => $backuppc_ssh_pub_key,
    tag => "backuppc",
    user => "root"
  }

  common::concatfilepart {"000-backuppc.hosts":
    file => "/etc/backuppc/hosts",
    content => "host        dhcp    user    moreUsers     # <--- do not edit this line\n",
  }

  Common::Concatfilepart <<| tag == "backuppc-client" |>> 

  service {"backuppc":
    ensure => running,
    restart => "/etc/init.d/backuppc reload",
    require => Package["backuppc"]
  }
}
