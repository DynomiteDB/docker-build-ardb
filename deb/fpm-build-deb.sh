#!/bin/bash

#
# Build: DynomiteDB - persistent backends (LMDB, RocksDB, LevelDB, WiredTiger)
# Debs:  1. Production
#        2. Debug `-debug`
# OS:    Ubuntu 14.04
# Type:  .deb
#

# The ARDB package is different from other packages b/c it contains 4 separate
# backend binaries.
# PACKAGE_NAME
PACKAGE_NAME="backends"
BACKENDS="lmdb rocksdb leveldb wiredtiger"
VERSION=$ARDB_VERSION
BIN_BINARIES=""
SBIN_BINARIES="dynomitedb-lmdb dynomitedb-rocksdb dynomitedb-leveldb dynomitedb-wiredtiger"
STATIC_FILES="README.md LICENSE Changelog.md"

#
# ****************************
# ** DO NOT EDIT BELOW HERE **
# ****************************
#

DEB=/deb
SRC=/src
REPO=/build/ardb
BUILD=${SRC}/dynomitedb-${PACKAGE_NAME}

package_types="optimized debug"

# Provide a clean build environment
rm -rf ${DEB}/tmp

for pt in $package_types
do

	if [ "$pt" == "optimized" ] ; then
		PACKAGE_ROOT=${DEB}/tmp/dynomitedb
	else
		PACKAGE_ROOT=${DEB}/tmp/dynomitedb-debug
	fi

	#ETC=${PACKAGE_ROOT}/etc
	DEFAULT=${PACKAGE_ROOT}/etc/default
	INITD=${PACKAGE_ROOT}/etc/init.d
	CONF=${PACKAGE_ROOT}/etc/dynomitedb
	LOGROTATED=${PACKAGE_ROOT}/etc/logrotate.d
	BIN=${PACKAGE_ROOT}/usr/local/bin/
	SBIN=${PACKAGE_ROOT}/usr/local/sbin/
	MAN1=${PACKAGE_ROOT}/usr/local/share/man/man1
	MAN8=${PACKAGE_ROOT}/usr/local/share/man/man8
	LINTIAN=${PACKAGE_ROOT}/usr/share/lintian/overrides
	# STATIC contains shared ARDB static files
	# STATIC_ROOT is dynamically generated for each backend
	# HOME is the dynomite user's home directory
	STATIC=${PACKAGE_ROOT}/usr/local/dynomitedb/${PACKAGE_NAME}
	STATIC_ROOT=${PACKAGE_ROOT}/usr/local/dynomitedb
	HOME=${PACKAGE_ROOT}/usr/local/dynomitedb/home
	# DATA is dynamically generated in this package
	#DATA=${PACKAGE_ROOT}/var/dynomitedb/${PACKAGE_NAME}/data
	DATA_ROOT=${PACKAGE_ROOT}/var/dynomitedb
	# LOGS is dynamically generated in this package
	#LOGS=${PACKAGE_ROOT}/var/log/dynomitedb/${PACKAGE_NAME}
	LOGS_ROOT=${PACKAGE_ROOT}/var/log/dynomitedb
	PIDDIR=${PACKAGE_ROOT}/var/run

	DDB="dynomitedb"

	#
	# Create a packaging directory structure
	# --------------------------------------
	#

	mkdir -p $PACKAGE_ROOT

	if [ "$pt" == "optimized" ] ; then
		# Defaults
		mkdir -p $DEFAULT

		# init scripts
		mkdir -p $INITD

		# Configuration files
		mkdir -p $CONF

		# Log configuration
		mkdir -p $LOGROTATED

		# Binaries
		#mkdir -p $BIN
	fi

	# System binaries
	mkdir -p $SBIN

	if [ "$pt" == "optimized" ] ; then
		# Man pages
		#mkdir -p $MAN1
		#mkdir -p $MAN8

		# Static files
		for b in $BACKENDS
		do
			mkdir -p ${STATIC_ROOT}/${b}
		done
		mkdir -p $STATIC
		mkdir -p $HOME

		# Data dirs
		for b in $BACKENDS
		do
			mkdir -p ${DATA_ROOT}/${b}/data
			mkdir -p ${DATA_ROOT}/${b}/backups
		done

		# Logs
		for b in $BACKENDS
		do
			mkdir -p ${LOGS_ROOT}/${b}
		done

		# PID files
		mkdir -p $PIDDIR
	fi

	# lintian
	mkdir -p $LINTIAN

	# Set directory permissions for the package
	chmod -R 0755 $PACKAGE_ROOT

	# lintian
	if [ "$pt" == "optimized" ] ; then
		cp ${DEB}/${DDB}-${PACKAGE_NAME}.lintian-overrides ${LINTIAN}/${DDB}-${PACKAGE_NAME}
		chmod 0644 ${LINTIAN}/${DDB}-${PACKAGE_NAME}
	else
		cp ${DEB}/${DDB}-${PACKAGE_NAME}-debug.lintian-overrides ${LINTIAN}/${DDB}-${PACKAGE_NAME}-debug
		chmod 0644 ${LINTIAN}/${DDB}-${PACKAGE_NAME}-debug
	fi


	#
	# Copy the package files into the packaging directory structure
	# -------------------------------------------------------------
	#
	# DynomiteDB backends: LMDB, RocksDB, LevelDB, WiredTiger
	#

	# System binaries
	if [ "$pt" == "optimized" ] ; then
		for sb in $SBIN_BINARIES
		do
			cp ${BUILD}/${sb} $SBIN
		done
	else
		for sb in $SBIN_BINARIES
		do
			cp ${BUILD}/${sb}-debug $SBIN
		done
	fi

	if [ "$pt" == "optimized" ] ; then
		# User binaries - do not include debug binaries
		# NONE

		# Man pages
		# NONE

		# Configuration (default dynomite.yaml is for single server Redis)
		for b in $BACKENDS
		do
			cp ${REPO}/conf/${b}.conf $CONF
			cp ${DEB}/etc/default/dynomitedb-${b} $DEFAULT
			cp ${DEB}/etc/init.d/dynomitedb-${b} $INITD
			cp ${DEB}/etc/logrotate.d/dynomitedb-${b} $LOGROTATED
		done

		# Logs
		for b in $BACKENDS
		do
			echo "# DynomiteDB: ${b} backend logs" > ${LOGS_ROOT}/${b}/README.md
		done

		# Data directories
		for b in $BACKENDS
		do
			echo "# DynomiteDB: ${b} data files" > ${DATA_ROOT}/${b}/data/README.md
			echo "# DynomiteDB: ${b} backups" > ${DATA_ROOT}/${b}/backups/README.md
		done

		# Backend specific static files
		for b in $BACKENDS
		do
			cp ${DEB}/usr/local/dynomitedb/${b}/* ${STATIC_ROOT}/${b}
		done

		# Static files
		for s in $STATIC_FILES
		do
			cp ${BUILD}/${s} $STATIC
		done

		# Home directory for dynomite user
		cp ${DEB}/usr/local/dynomitedb/home/README-BACKENDS.md ${HOME}
	fi

	#
	# General perms
	#

	chmod 0755 ${SBIN}/*

	if [ "$pt" == "optimized" ] ; then
		#chmod 0755 ${BIN}/*

		chmod 0644 ${DEFAULT}/*
		chmod 0644 ${CONF}/*
		chmod 0755 ${INITD}/*
		chmod 0644 ${LOGROTATED}/*

		#chmod 0644 ${MAN1}/*
		#chmod 0644 ${MAN8}/*

		# DATA, STATIC, LOGS are dynamic for this package

		# Backend specific static files
		for b in $BACKENDS
		do
			chmod 0644 ${STATIC_ROOT}/${b}/*
		done

		# Shared static files
		chmod 0644 ${STATIC}/*

		# dynomite user's home directory
		chmod 0644 ${HOME}/*

		# Data dirs
		for b in $BACKENDS
		do
			chmod 0644 ${DATA_ROOT}/${b}/data/README.md
			chmod 0644 ${DATA_ROOT}/${b}/backups/README.md
		done

		# Logs
		for b in $BACKENDS
		do
			chmod 0644 ${LOGS_ROOT}/${b}/README.md
		done
	fi

	if [ "$pt" == "optimized" ] ; then
		fpm \
			-f \
			-s dir \
			-t deb \
			-C ${PACKAGE_ROOT}/ \
			--directories ${PACKAGE_ROOT}/ \
			--config-files /etc/dynomitedb/ \
			--deb-custom-control ${DEB}/control \
			--deb-changelog ${DEB}/changelog \
			--before-install ${DEB}/preinst.ex \
			--after-install ${DEB}/postinst.ex \
			--before-remove ${DEB}/prerm.ex \
			--after-remove ${DEB}/postrm.ex \
			-n "${DDB}-${PACKAGE_NAME}" \
			-v ${VERSION} \
			--epoch 0
	else
		fpm \
			-f \
			-s dir \
			-t deb \
			-C ${PACKAGE_ROOT}/ \
			--directories ${PACKAGE_ROOT}/ \
			--deb-custom-control ${DEB}/control-debug \
			--deb-changelog ${DEB}/changelog-debug \
			-n "${DDB}-${PACKAGE_NAME}-debug" \
			-v ${VERSION} \
			--epoch 0
	fi

done

# Run lintian
lintian *.deb

