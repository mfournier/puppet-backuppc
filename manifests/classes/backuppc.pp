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
    content => '-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEA16EyAo8oosOkTdEytXUnxxhMGFFADSYjVlms9E1RI086o7/I
PsApdZZhDoXmSPKRkjeLIH+nmnDErWX4gkJtSP+qdDKLho3xpTa7WFYrcxZW4een
6b9bcHs+ydUTAcNCuS0Hed/Bd2XmX19G8tGa1z5GKsiyGSULvKgG0fmNxZdukuOW
V1A0tNpdzOuoQBZZvWNCSVRs+ta6eDD8upSGJZqDqo6st99mLbhj2tChbgrisSwv
ZAaTLi3RJr8v5GP3tqPlbLVEPtFib7fC0mqaT/ceuHGFg8y0MjH/rnrjhjyBiLKC
KMd80WjXmQYWJoya2lWXxwINa1DW9Pxw/4LGpQIBIwKCAQAGKS1Qh79VG4hZ/qmt
ab9O1M75YWg649UfuWtXb+xgGDTgG2wfDM38C5xfgCsmp9hGAZZCwdGWssPKcKCz
Q7n6xXnmEBKdccUTWVXPUutMblpA9/17tQKc0FJAR+qZpn4/zhYoDbUSCjnINewV
kPXLorGMMZ6wQuMUBMz+r1vScf0K//RdSy1yRcjMtH+L3LCm6CRvLtA/ThIxv97s
MzxWfM8EuundSj6JJpLDR89HxhKbGwlVkAkac74p4DKX7k3OCE9Bc8vcEky1IslK
NmpYfoF1tQSXQD/8wJXmcPGTWpfngD3RD8Gtan66WzZNS+mWHvt2nP3KIcHJ3suH
q8ELAoGBAPFgvsBH6QWznzEaCcYCydy8SbRFe+qyCgUZ0ivO8cQ10LbDZKF+NQwM
PjPyqgOrwrsRTSBTC6ZTgMdfktKYHoxW2ejYvIW08NZRLAsdF97dKViMUZ+SSzU4
c30Z2dPxwf3JgimQTHG0PN8E6WVYfniXzDGbbqcAgDPTr74d21EFAoGBAOSxJm1O
H/hhsLi2NHIeIFYvXJLQcgmhIDiRI1agoYIcuX9BnBH4g81hNB81VUbyM5xrLMhe
Sa482goNhXKGsMg0pyahI99zYA9ayjKP4jFZghMUYEVDuL9ragQTMAhvF78Yp+UD
U5BnnKUZpEQ8rTK8TQT0HLPIMySH1t9VLBEhAoGBAOOVuypSbf4PwfsYjN9EdS81
L4y2isdXaIh3bmPRv2E6De4l8SqM8C/uSUbsHKRgHgDVzGBOTNAFlq1aHLfugzPc
3BYOLheqme6kThkbbkcoS44ApLsGRukJVvJLkt3Gr5eDerl5bKW4kSoL8gB4Ajcw
CasdhZYlCymNE2ocJo43AoGAdZzvMOZZla6VZk8TqGdD1I1izylfOCb6oL+rxia5
dh1mtnmDdvTWEdo4EAzMxWaeMy/N42Ow3UPd2UjISYcZFoF6iOUoZEn241NDanXi
CsBRhie8e2SoJ+4ZQ+ycXBvgU6ZHt5tPjBgHatn8tWEInb/tGH2LGqF5Yz6Lw1Bf
zksCgYEAkjoDF8a+lkIwtlE1g9CxKRI0aeyGLXsK0YaAr3wDFLC4SudgvEKBA4NB
9oJSq9kfcQS/SNaju8O9J1JcKvad9mCy/4q4GMiSo7HUJy2m2HUGLKuV0nWPC4TE
Q5OPobsspX75eNZ0m4cO4t9mjJhD5o0BuaWp43Deavypu5paEhI=
-----END RSA PRIVATE KEY-----',
    owner => backuppc,
    group => backuppc,
    require => File["/var/lib/backuppc/.ssh"],
    mode    => "0600",
  }


  file {"/var/lib/backuppc/.ssh/id_rsa.pub":
    ensure => present,
    content => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA16EyAo8oosOkTdEytXUnxxhMGFFADSYjVlms9E1RI086o7/IPsApdZZhDoXmSPKRkjeLIH+nmnDErWX4gkJtSP+qdDKLho3xpTa7WFYrcxZW4een6b9bcHs+ydUTAcNCuS0Hed/Bd2XmX19G8tGa1z5GKsiyGSULvKgG0fmNxZdukuOWV1A0tNpdzOuoQBZZvWNCSVRs+ta6eDD8upSGJZqDqo6st99mLbhj2tChbgrisSwvZAaTLi3RJr8v5GP3tqPlbLVEPtFib7fC0mqaT/ceuHGFg8y0MjH/rnrjhjyBiLKCKMd80WjXmQYWJoya2lWXxwINa1DW9Pxw/4LGpQ==',
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
    key => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA16EyAo8oosOkTdEytXUnxxhMGFFADSYjVlms9E1RI086o7/IPsApdZZhDoXmSPKRkjeLIH+nmnDErWX4gkJtSP+qdDKLho3xpTa7WFYrcxZW4een6b9bcHs+ydUTAcNCuS0Hed/Bd2XmX19G8tGa1z5GKsiyGSULvKgG0fmNxZdukuOWV1A0tNpdzOuoQBZZvWNCSVRs+ta6eDD8upSGJZqDqo6st99mLbhj2tChbgrisSwvZAaTLi3RJr8v5GP3tqPlbLVEPtFib7fC0mqaT/ceuHGFg8y0MjH/rnrjhjyBiLKCKMd80WjXmQYWJoya2lWXxwINa1DW9Pxw/4LGpQ==',
    tag => "backuppc",
    user => "root"
  }

  Line <<| tag == "backuppc-client" |>> 

  service {"backuppc":
    ensure => running,
    restart => "/etc/init.d/backuppc reload",
    require => Package["backuppc"]
  }
}
