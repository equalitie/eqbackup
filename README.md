eqbackup
-------

eqbackup is a set of ansible recipes developed for the setup of a
comprehensive backup system on Debian systems, with a secondary backup
of the backups. Backups are encrypted and all remote file accesses are
restricted by SSHd's chroot functionality and the use of per-host SSH
keys.

eqbackup will:
* Install and configure backupninja and duplicity on all hosts except
  for the secondary backup, which is not backed up.
* On Debian wheezy, download and manually install duplicity due to
  problems in wheezy's version of duplicity. In turn, backupninja's
  dup job is patched to account for this.
* Install SSH and GPG keys as appropriate around the system.
* Configure SSHd on both backup primary and secondary to restrict
  accesses by backup clients and to force SSH key logins for all
  users - not just backup users. Be warned!

Configuring eqbackup
========

Almost all configuration of eqbackup isdone via hosts.yml. All
`gpg_keyid` varaibles should be specified as full fingerprints with no
spaces and not as 8 digit key IDs.

`backup_primary`: this group should consist of a single host, the
server that will be receiving the backups from groups in the
`backup_clients` group. This server should have the `secondary_server`
hostname specified, and the self-explanatory `gpg_keyid` and
`gpg_passphrase` variables.

`backup_secondary`: This group takes no configuration options and
should contain a single host.

`backup_clients`: This group features the same GPG options as in
backup_primary. The remote user used to back up the specific system
should be specified as `backup_user` (in order to avoid creating
invalid usernames featuring "." characters etc). In addition to the
backup paths configured by default in `vars.yml`, per-host rules can
be set via `backup_exclude` and `backup_include` to customise the list
of directories to be backed up.

Some additional configuration can be changed in `vars.yml`, such as the
username used for secondary backups, the duplicity version and the
default backup paths.

Generating SSH keys for a host
========
* `ssh-keygen -f ssh_keys/THE_EXACT_HOSTNAME.id_rsa -t rsa -b 4096`

Generating GPG keys for a host
========
* `gpg --gen-key` (Follow instructions as usual)
* `gpg --export-secret-keys THE_KEY_ID > gpg_keys/THE_EXACT_HOSTNAME.gpg`
