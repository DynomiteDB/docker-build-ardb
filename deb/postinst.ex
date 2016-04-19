#!/bin/sh
# postinst script for dynomite
#
# see: dh_installdeb(1)

set -e

# summary of how this script can be called:
#        * <postinst> `configure' <most-recently-configured-version>
#        * <old-postinst> `abort-upgrade' <new version>
#        * <conflictor's-postinst> `abort-remove' `in-favour' <package>
#          <new-version>
#        * <postinst> `abort-remove'
#        * <deconfigured's-postinst> `abort-deconfigure' `in-favour'
#          <failed-install-package> <version> `removing'
#          <conflicting-package> <version>
# for details, see http://www.debian.org/doc/debian-policy/ or
# the debian-policy package

USER="dynomite"
GROUP="dynomite"
HOME="/usr/local/dynomitedb/home"

case "$1" in
    configure)
	# TODO: Set permissions
	chown -R $USER:$GROUP /usr/local/dynomitedb/home
	#chown $USER:$GROUP /var/dynomitedb/lmdb
	#chown $USER:$GROUP /var/log/dynomitedb/lmdb

	update-rc.d dynomitedb-lmdb defaults
	update-rc.d dynomitedb-leveldb defaults
	update-rc.d dynomitedb-rocksdb defaults
	update-rc.d dynomitedb-wiredtiger defaults

	# Start Dynomite with a Redis backend by default
	# Ensure that dynomitedb-lmdb is not started automatically
	# Do not run service xxx stop as it returns a non-zero status
	#service dynomitedb-lmdb stop
    ;;

    abort-upgrade|abort-remove|abort-deconfigure)
    ;;

    *)
        echo "postinst called with unknown argument \`$1'" >&2
        exit 1
    ;;
esac

exit 0
