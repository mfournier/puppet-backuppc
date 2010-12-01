/*

== Class: backuppc

Installs backuppc server and client. Designed to have multiple backup servers. Servers select their clients by domain name extension.
You have to define following variables before including this class:
- $backuppc_xfer_method 
- $backuppc_admin_user 
- $backuppc_ssh_prv_key 
- $backuppc_ssh_pub_key

You can override following variables by defining them befor including this class:
- $backuppc_full_period
- $backuppc_incr_period
- $backuppc_full_keep_cnt
- $backuppc_full_age_max
- $backuppc_incr_age_max
- $backuppc_backup_files_exclude
*/
import "classes/*.pp"
import "definitions/*.pp"
