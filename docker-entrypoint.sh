#!/bin/bash
set -e

#
# Build with debug: -d
# Add a target to make: -t <target>
#

# Reset getopts option index
OPTIND=1

# Additional make target
target=""
# If the -d flag is set then create a debug build of dynomite
mode="production"

while getopts "dt:" opt; do
    case "$opt" in
    d)  mode="debug"
        ;;
    t)  target=$OPTARG
        ;;
    esac
done

if [ "$target" == "clean" ] ; then
    make clean
    exit 0;
fi

# Build the following backends
# - dynomitedb-lmdb
# - dynomitedb-leveldb
# - dynomitedb-wiredtiger

# Create package base
rm -f /src/dynomitedb-backends_ubuntu-14.04.4-x64.tar.gz
rm -rf /src/dynomitedb-package
mkdir -p /src/dynomitedb-package

# Static files (common for all storage engines)
for s in "README.md" "LICENSE" "Changelog.md"
do
	cp /src/$s /src/dynomitedb-package/
done

# TODO: Static files for each backend (LMDB, LevelDB, RocksDB)

# Configuration files (common for all storage engines)
cp -R /src/conf /src/dynomitedb-package/

# Build LMDB
echo "--------------------------------------------------------------------------------"
echo ""
echo "Building LMDB"
echo ""
echo "--------------------------------------------------------------------------------"
make clean
storage_engine=lmdb make
mv /src/src/ardb-server /src/dynomitedb-package/dynomitedb-lmdb
mv /src/src/ardb-test /src/dynomitedb-package/dynomitedb-lmdb-test
if [ "$mode" == "production" ] ; then
	cp /src/dynomitedb-package/dynomitedb-lmdb /src/dynomitedb-package/dynomitedb-lmdb-debug
	cp /src/dynomitedb-package/dynomitedb-lmdb-test /src/dynomitedb-package/dynomitedb-lmdb-test-debug
    strip --strip-debug --strip-unneeded /src/dynomitedb-package/dynomitedb-lmdb
    strip --strip-debug --strip-unneeded /src/dynomitedb-package/dynomitedb-lmdb-test
fi

# Build LevelDB
echo "--------------------------------------------------------------------------------"
echo ""
echo "Building LevelDB"
echo ""
echo "--------------------------------------------------------------------------------"
make clean
storage_engine=leveldb make
mv /src/src/ardb-server /src/dynomitedb-package/dynomitedb-leveldb
mv /src/src/ardb-test /src/dynomitedb-package/dynomitedb-leveldb-test
if [ "$mode" == "production" ] ; then
	cp /src/dynomitedb-package/dynomitedb-leveldb /src/dynomitedb-package/dynomitedb-leveldb-debug
	cp /src/dynomitedb-package/dynomitedb-leveldb-test /src/dynomitedb-package/dynomitedb-leveldb-test-debug
    strip --strip-debug --strip-unneeded /src/dynomitedb-package/dynomitedb-leveldb
    strip --strip-debug --strip-unneeded /src/dynomitedb-package/dynomitedb-leveldb-test
fi

# Build WiredTiger
echo "--------------------------------------------------------------------------------"
echo ""
echo "Building WiredTiger"
echo ""
echo "--------------------------------------------------------------------------------"
make clean
storage_engine=wiredtiger make
mv /src/src/ardb-server /src/dynomitedb-package/dynomitedb-wiredtiger
mv /src/src/ardb-test /src/dynomitedb-package/dynomitedb-wiredtiger-test
if [ "$mode" == "production" ] ; then
	cp /src/dynomitedb-package/dynomitedb-wiredtiger /src/dynomitedb-package/dynomitedb-wiredtiger-debug
	cp /src/dynomitedb-package/dynomitedb-wiredtiger-test /src/dynomitedb-package/dynomitedb-wiredtiger-test-debug
    strip --strip-debug --strip-unneeded /src/dynomitedb-package/dynomitedb-wiredtiger
    strip --strip-debug --strip-unneeded /src/dynomitedb-package/dynomitedb-wiredtiger-test
fi

# Compress package
mv /src/dynomitedb-package /src/dynomitedb-backends
tar -czf dynomitedb-backends_ubuntu-14.04.4-x64.tar.gz -C /src dynomitedb-backends/

