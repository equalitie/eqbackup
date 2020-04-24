#!/bin/bash


echo -n "Is this run to generate the secondary server key (y/n) ? "
read varsecondary
if [ "$varsecondary" == 'y' ]; then
	varhostname="secondary"
elif [ "$varsecondary" == 'n' ]; then
	echo
	echo -n "What is the hostname (the inventory name) ? "
	read varhostname
else
	echo "Please answer (y/n). Exiting ..."
	exit
fi

echo
echo "This passphrase will be asked for you to input at the end so that"
echo "the key can be exported"
echo
echo -n "what is you passphrase (warning this will print to screen) ? "
read varpassphrase

TMPFILE="$(mktemp)"
TMPWDIR="$(mktemp -d)"
export GNUPGHOME="$TMPWDIR"

cat > $TMPFILE <<EOF
 %echo Generating a default key
     Key-Type: default
     Subkey-Type: default
     Name-Real: $varhostname Backup 
     Name-Comment: Backup
     Name-Email: backup@$varhostname
     Expire-Date: 0
     Passphrase: $varpassphrase
     # Do a commit here, so that we can later print "done" :-)
     %commit
     %echo done
EOF

gpg --batch --generate-key $TMPFILE >/dev/null 2>&1
FINGERPRINT="$(gpg --list-signatures --with-colons backup@$varhostname | awk -F: '/^sig:/ { print $13; exit; }')"
ls gpg_keys/$varhostname.gpg >/dev/null 2>&1
EXISTS=$?

if [ $EXISTS -ne 0 ]; then
  gpg --export-secret-keys $FINGERPRINT > gpg_keys/$varhostname.gpg
else
	echo
	echo "gpg_keys/$varhostname.gpg already exists"
fi

# cleanup
rm $TMPFILE
rm -r $TMPWDIR

if [ $EXISTS -ne 0 ]; then 
	cat <<EOF

Add these to the inventory host variables

gpg_passphrase=$varpassphrase gpg_keyid=$FINGERPRINT

EOF
else
	echo "Key not created. Delete the existing and run again."
	echo
fi
