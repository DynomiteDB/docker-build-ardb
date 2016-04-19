#!/bin/sh
# prerm script for dynomite
#
# see: dh_installdeb(1)

set -e

# summary of how this script can be called:
#        * <prerm> `remove'
#        * <old-prerm> `upgrade' <new-version>
#        * <new-prerm> `failed-upgrade' <old-version>
#        * <conflictor's-prerm> `remove' `in-favour' <package> <new-version>
#        * <deconfigured's-prerm> `deconfigure' `in-favour'
#          <package-being-installed> <version> `removing'
#          <conflicting-package> <version>
# for details, see http://www.debian.org/doc/debian-policy/ or
# the debian-policy package


case "$1" in
    remove|upgrade|deconfigure)
		if which service >/dev/null 2>&1; then
			if service dynomitedb-lmdb status >/dev/null 2>&1; then
				service dynomitedb-lmdb stop
			fi

			if service dynomitedb-leveldb status >/dev/null 2>&1; then
				service dynomitedb-leveldb stop
			fi

			if service dynomitedb-rocksdb status >/dev/null 2>&1; then
				service dynomitedb-rocksdb stop
			fi

			if service dynomitedb-wiredtiger status >/dev/null 2>&1; then
				service dynomitedb-wiredtiger stop
			fi
		elif which invoke-rc.d >/dev/null 2>&1; then
			invoke-rc.d dynomitedb-lmdb stop
			invoke-rc.d dynomitedb-leveldb stop
			invoke-rc.d dynomitedb-rocksdb stop
			invoke-rc.d dynomitedb-wiredtiger stop
		else
			/etc/init.d/dynomitedb-lmdb stop
			/etc/init.d/dynomitedb-leveldb stop
			/etc/init.d/dynomitedb-rocksdb stop
			/etc/init.d/dynomitedb-wiredtiger stop
		fi

    ;;

    failed-upgrade)
    ;;

    *)
        echo "prerm called with unknown argument \`$1'" >&2
        exit 1
    ;;
esac

exit 0
