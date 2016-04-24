#!/bin/bash
set -e

# 
# The dynomite build container performs the following actions:
# 1. Checkout repo
# 2. Compile binary
# 3. Package binary in .tgz
# 4. Package binary in .deb
#
# Options:
# -v: tag version
# -d: debug
# -t <target>: add a make target
#

BUILD=/build/ardb
BUILD_ROCKSDB=/build/ardb-rocksdb
SRC=/src
PACKAGE=${SRC}/dynomitedb-backends
DEB=/deb


# Reset getopts option index
OPTIND=1

# Version is used for .deb package version, not for checking out git tags
version="0.0.1"
# If the -d flag is set then create a debug build of ardb
mode="production"
# Additional make target
target=""

while getopts "v:dt:" opt; do
    case "$opt" in
	v)  version=$OPTARG
		;;
    d)  mode="debug"
        ;;
    t)  target=$OPTARG
        ;;
    esac
done

#
# Get the source code
#
git clone https://github.com/DynomiteDB/ardb.git
# Create a copy of the repo for the RocksDB build
cp -pR $BUILD $BUILD_ROCKSDB
cd $BUILD
echo "Building branch: master"

#if [ "$target" == "clean" ] ; then
#    make clean
#    exit 0;
#fi

# Build the following backends
# - dynomitedb-lmdb
# - dynomitedb-leveldb
# - dynomitedb-wiredtiger
# - dynomitedb-rocksdb

# Create package base
rm -f $SRC/dynomitedb-backends_ubuntu-14.04.4-x64.tar.gz
rm -rf $PACKAGE
mkdir -p $PACKAGE

# Static files (common for all storage engines)
for s in "README.md" "LICENSE" "Changelog.md"
do
	cp $BUILD/$s $PACKAGE
done

# TODO: Static files for each backend (LMDB, LevelDB, RocksDB)

# Configuration files (common for all storage engines)
cp -R $BUILD/conf $PACKAGE/

# Build LMDB
echo "--------------------------------------------------------------------------------"
echo ""
echo "Building LMDB"
echo ""
echo "--------------------------------------------------------------------------------"
make clean
storage_engine=lmdb make
mv ${BUILD}/src/ardb-server ${PACKAGE}/dynomitedb-lmdb
mv ${BUILD}/src/ardb-test ${PACKAGE}/dynomitedb-lmdb-test
if [ "$mode" == "production" ] ; then
	cp ${PACKAGE}/dynomitedb-lmdb ${PACKAGE}/dynomitedb-lmdb-debug
	cp ${PACKAGE}/dynomitedb-lmdb-test ${PACKAGE}/dynomitedb-lmdb-test-debug
    strip --strip-debug --strip-unneeded ${PACKAGE}/dynomitedb-lmdb
    strip --strip-debug --strip-unneeded ${PACKAGE}/dynomitedb-lmdb-test
fi

# Build LevelDB
echo "--------------------------------------------------------------------------------"
echo ""
echo "Building LevelDB"
echo ""
echo "--------------------------------------------------------------------------------"
make clean
storage_engine=leveldb make
mv ${BUILD}/src/ardb-server ${PACKAGE}/dynomitedb-leveldb
mv ${BUILD}/src/ardb-test ${PACKAGE}/dynomitedb-leveldb-test
if [ "$mode" == "production" ] ; then
	cp ${PACKAGE}/dynomitedb-leveldb ${PACKAGE}/dynomitedb-leveldb-debug
	cp ${PACKAGE}/dynomitedb-leveldb-test ${PACKAGE}/dynomitedb-leveldb-test-debug
    strip --strip-debug --strip-unneeded ${PACKAGE}/dynomitedb-leveldb
    strip --strip-debug --strip-unneeded ${PACKAGE}/dynomitedb-leveldb-test
fi

# Build WiredTiger
echo "--------------------------------------------------------------------------------"
echo ""
echo "Building WiredTiger"
echo ""
echo "--------------------------------------------------------------------------------"
make clean
storage_engine=wiredtiger make
mv ${BUILD}/src/ardb-server ${PACKAGE}/dynomitedb-wiredtiger
mv ${BUILD}/src/ardb-test ${PACKAGE}/dynomitedb-wiredtiger-test
if [ "$mode" == "production" ] ; then
	cp ${PACKAGE}/dynomitedb-wiredtiger ${PACKAGE}/dynomitedb-wiredtiger-debug
	cp ${PACKAGE}/dynomitedb-wiredtiger-test ${PACKAGE}/dynomitedb-wiredtiger-test-debug
    strip --strip-debug --strip-unneeded ${PACKAGE}/dynomitedb-wiredtiger
    strip --strip-debug --strip-unneeded ${PACKAGE}/dynomitedb-wiredtiger-test
fi

# Build RocksDB
echo "--------------------------------------------------------------------------------"
echo ""
echo "Building RocksDB"
echo ""
echo "--------------------------------------------------------------------------------"
cd $BUILD_ROCKSDB
git checkout rocksdb-only
# Temporary: newer commits have build errors
#git checkout 2bbb51136e665ea30e8896f177f687376174e6b1
make
mv ${BUILD_ROCKSDB}/src/ardb-server ${PACKAGE}/dynomitedb-rocksdb
mv ${BUILD_ROCKSDB}/src/ardb-test ${PACKAGE}/dynomitedb-rocksdb-test
if [ "$mode" == "production" ] ; then
	cp ${PACKAGE}/dynomitedb-rocksdb ${PACKAGE}/dynomitedb-rocksdb-debug
	cp ${PACKAGE}/dynomitedb-rocksdb-test ${PACKAGE}/dynomitedb-rocksdb-test-debug
    strip --strip-debug --strip-unneeded ${PACKAGE}/dynomitedb-rocksdb
    strip --strip-debug --strip-unneeded ${PACKAGE}/dynomitedb-rocksdb-test
fi

#
# Create .tgz package
#
cd /src
tar -czf dynomitedb-backends_ubuntu-14.04.4-x64.tar.gz -C /src dynomitedb-backends

# Update .deb build files
export ARDB_VERSION=$version
sed -i 's/0.0.0/'${version}'/' $DEB/changelog
sed -i 's/0.0.0/'${version}'/' $DEB/control

$DEB/fpm-build-deb.sh

