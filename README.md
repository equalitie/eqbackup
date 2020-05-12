eqbackup
========

eqbackup is a set of ansible recipes developed for the setup of a
comprehensive backup system on Debian systems, with a secondary backup
of the backups. Backups are encrypted and all remote file accesses are
restricted by SSHd's chroot functionality and the use of per-host SSH
keys.

eqbackup will:
* Install and configure backupninja and duplicity on all hosts except
  for the secondary backup, which is not backed up.
* Install SSH and GPG keys as appropriate around the system.
* Configure SSHd on both backup primary and secondary to restrict
  accesses by backup clients and to force SSH key logins for all
  users - not just backup users. Be warned!
* Open firewall to on backup primary server to allow clients ssh and
  open firewall on backup secondary server to allow primary ssh.
  We do not enable the firewall. This is add just in case there is
  a firewall blocking ssh.
  Note: This expects that some other firewall was set to allow ssh
  from our controller, ie; eQ cityhall

Configuring eqbackup
-------

Almost all configuration of eqbackup is done in inventory, example hosts.yml. All
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

The easy way to start is to copy the `hosts.yml` file to `inventory`
and edit the `inventory` file to fit you hosts. We will default to use
the file `inventory` for your production setup. If you change this use the
-i my_inventory on you command line.

Warning: You will need to manually set systems timezone since we do not
want to overwrite any existing time zone setting deployed by other methods.

Also these roles expect Debian 9+ and Ansible 2.8+

Generating SSH keys for a client host
--------

Each client host needs its own SSH key pair so as to access the primary backup
host. SSH keys file names follow a strict naming rule, as represented by this
command to generate such files:

    You can manually generate keys but now the role will do it automatically for
    you if the key does not exist

    ssh-keygen -f ssh_keys/THE_EXACT_HOSTNAME.id_rsa -t rsa -b 4096

    No need to add passphrase on your key since we do not support it here.

Generating GPG keys for a client host
--------

Each client host also needs its own PGP key pair, for encryption and decryption
of its own backups:

    You can manually generate if you know what you are doing and do not
    want default gpg keys generate or run the interactive script

    contrib/gpg-genkey.sh

    Manual method:

    gpg --gen-key # Follow instructions as usual

    Adding a passphrase here is recommented and supported. Passphrase should
    not have any quotes.

    gpg --export-secret-keys THE_KEY_ID > gpg_keys/THE_EXACT_HOSTNAME.gpg

SSH and PGP keys for backup from primary to secondary
--------

The primary backup server acts as a client of the secondary. Its PGP and SSH
keys must generated exactly like client hosts, but have to be prefixed with
"secondary" (i.e. filenames will be `secondary.gpg`, `secondary.id_rsa` and
`secondary.id_rsa.pub`).
