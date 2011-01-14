/*

== Class  backuppc
Install a backuppc server with ldap authentication.
You must define variables $backuppc_ssh_prv_key; $backuppc_ssh_pub_key and $backuppc_server_tag before including this class

BackupPC documentation:
http://backuppc.sourceforge.net/faq/BackupPC.html

Example:
node "ns1.domain.tld" {
    $backuppc_server_tag="backuppc-client-lsn"
    include apache
    include srv-basic

    $backuppc_xfer_method = 'rsync'
    $backuppc_admin_users = 'sysadmin jbove mbornoz marc cjeanneret ckaenzig mremy'
    $backuppc_ssh_prv_key = put your ssh private key here
    $backuppc_ssh_pub_key = put your ssh public key here
    $backuppc_topdir = '/var/lib/backuppc'
    $backuppc_full_period = '6.97'
    $backuppc_incr_period = '6.97'
    $backuppc_full_keep_cnt = '1'
    $backuppc_full_age_max = '90'
    $backuppc_incr_age_max = '30'
    $backuppc_backup_files_exclude = "{
        '*' => ['/chroots', 
                '/chroot',
                '/chroot',
                '/chroots',
                '/vmware',
                '/proc',
                '/proc',
                '/nobackup',
                '/Music',
                '/tmp',
                '/vmware',
                '*.vmdk',
                '*.iso',
                '*.mp3',
                '*.avi',
                '/.Trash*',
                '*.ogg',
                '*.wav',
                '*.wma',
                '*.mpg',
                '*.mov',
                '*.wmv',
                '*.flac',
                '*.m4a',
                '*.m4v',
                '*.mkv',
                '*.mp4',
                '/Video',
                '*.vdi',
            ],
      }" 
    include backuppc
}

*/

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

  # Configure the web interface
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
  
  # Configure the ldap authentication
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
    
  # Write server ssh private key in a file
  file {"/var/lib/backuppc/.ssh/id_rsa":
    ensure => present,
    content => $backuppc_ssh_prv_key,
    owner => backuppc,
    group => backuppc,
    require => File["/var/lib/backuppc/.ssh"],
    mode    => "0600",
  }
    
  # Write server ssh public key in a file
  file {"/var/lib/backuppc/.ssh/id_rsa.pub":
    ensure => present,
    content => $backuppc_ssh_pub_key,
    owner => backuppc,
    group => backuppc,
    require => File["/var/lib/backuppc/.ssh"]
  }

  # Create a ssh config file
  file {"/var/lib/backuppc/.ssh/config":
    ensure => present,
    owner => backuppc,
    group => backuppc,
    content => "Host *\n\tStrictHostKeyChecking no",
    require => File["/var/lib/backuppc/.ssh"]
  }

  # Export ssh public key to allow backuppc server to connect to each client (used by rsync)
  @@ssh_authorized_key {"$fqdn":
    ensure => present,
    type => ssh-rsa,
    key => $backuppc_ssh_pub_key,
    tag => "backuppc",
    user => "root"
  }
  
  # Create header of /etc/backuppc/hosts file
  common::concatfilepart {"000-backuppc.hosts":
    file => "/etc/backuppc/hosts",
    content => "host        dhcp    user    moreUsers     # <--- do not edit this line\n",
  }

  # Write a line in /etc/backuppc/hosts to include every clients
  Common::Concatfilepart <<| tag == 'backuppc_client' |>> 

  # Reload backuppc server to refresh hosts list
  service {"backuppc":
    ensure => running,
    restart => "/etc/init.d/backuppc reload",
    require => Package["backuppc"]
  }
}
