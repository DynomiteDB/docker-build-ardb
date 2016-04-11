# Build ARDB

Build multiple variations of ARDB with the following backend database storage engines:

- LMDB: `dynomitedb-lmdb`
- LevelDB: `dynomitedb-leveldb`
- WiredTiger: `dynomitedb-wiredtiger`

Compiling ARDB has two discrete steps:

1. Build the `build-ardb` Docker image (automated via DockerHub)
2. Compile multiple ARDB binaries each with a different database storage engine: LMDB, LevelDB, WiredTiger

The `build-ardb` Docker image is a clean, reusable build environment for ARDB.

Run the `build-ardb` container to compile ARDB.

# Compile ARDB

Run `build-ardb` to compile ARDB with each of the following database storage engines:

- LMDB: `dynomitedb-lmdb`
- LevelDB: `dynomitedb-leveldb`
- WiredTiger: `dynomitedb-wiredtiger`

First, clone and `cd` into the `ardb` git repo.

```bash
mkdir -p ~/repos/ 

git clone https://github.com/DynomiteDB/ardb.git

cd ~/repos/ardb
```

Build ARDB.

```bash
docker run -it --rm -v $PWD:/src dynomitedb/build-ardb
```

Create a debug build of ARDB.

```bash
docker run -it --rm -v $PWD:/src dynomitedb/build-ardb -d
```

Clean the build directory.

```bash
docker run -it --rm -v $PWD:/src dynomitedb/build-ardb -t clean
```

# Manually build the `build-ardb` image

The `build-ardb` Docker image, which is used to compile ARDB, is automatically build via DockerHub.

The automated build is located at https://hub.docker.com/r/dynomitedb/build-ardb.

However, you can manually build the `build-ardb` image by executing the commands shown below.

First, clone the `docker-build-ardb` repo and `cd` into the `docker-build-ardb` directory.

```bash
mkdir -p ~/repos

git clone https://github.com/DynomiteDB/docker-build-ardb.git

cd ~/repos/docker-build-ardb
```

Create the `build-ardb` image.

```bash
docker build -t dynomitedb/build-ardb .
```

