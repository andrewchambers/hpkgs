set -eux

dl () {
  if ! test -f $1
  then
    wget $2 -O $1.tmp
    mv $1.tmp $1
  fi
}

dl busybox.tar.bz2 \
  https://busybox.net/downloads/busybox-1.31.1.tar.bz2
dl musl-cross-make.tar.gz \
  https://github.com/richfelker/musl-cross-make/tarball/5086175f29021e3bebb7d9f5d83c4a796d96ebbd 

cat <<-EOF > mcm-stage1-config.mak
TARGET = x86_64-linux-musl
LINUX_VER = 4.19.90
COMMON_CONFIG += --enable-new-dtags --disable-nls CFLAGS=-O3 CXXFLAGS=-O3 LDFLAGS=-s
GCC_CONFIG += --disable-libquadmath --disable-decimal-float
GCC_CONFIG += --disable-libitm
GCC_CONFIG += --disable-fixed-point
GCC_CONFIG += --disable-lto --disable-bootstrap
EOF

cat <<-EOF > mcm-stage2-config.mak
TARGET = x86_64-linux-musl
LINUX_VER = 4.19.90
COMMON_CONFIG += --enable-new-dtags --disable-nls CFLAGS=-O3 CXXFLAGS=-O3 LDFLAGS=-s
COMMON_CONFIG += CC="x86_64-linux-musl-gcc -static --static" CXX="x86_64-linux-musl-g++ -static --static"
GCC_CONFIG += --disable-libquadmath --disable-decimal-float
GCC_CONFIG += --disable-libitm
GCC_CONFIG += --disable-fixed-point
GCC_CONFIG += --disable-lto
EOF

mcm_stage() {
  stage=$1
  if ! test -d mcm${stage}_out
  then
    rm -rf mcm${stage} mcm${stage}_out.tmp
    mkdir mcm${stage} mcm${stage}_out.tmp
    mcm_out_tmp="$(pwd)/mcm${stage}_out.tmp"
    cd mcm${stage}
    tar --strip-components 1 -zxf ../musl-cross-make.tar.gz
    cp ../mcm-stage${stage}-config.mak ./config.mak
    make extract_all
    make -j $(nproc)
    make install "OUTPUT=$mcm_out_tmp"
    cd ..
    mv mcm${stage}_out.tmp mcm${stage}_out
  fi  
}

ORIG_PATH="$PATH"
mcm_stage 1
export PATH="$(pwd)/mcm1_out/bin:$PATH"
mcm_stage 2
export PATH="$(pwd)/mcm2_out/bin:$ORIG_PATH"

if ! test -d busybox
then
  rm -rf busybox.tmp
  mkdir busybox.tmp
  cd busybox.tmp
  tar --strip-components 1 -jxf ../busybox.tar.bz2
  make CC=x86_64-linux-musl-gcc LDFLAGS=-static  defconfig
  make CC=x86_64-linux-musl-gcc LDFLAGS=-static -j $(nproc)
  cd ..
  mv busybox.tmp busybox
fi

if ! test -d seedfs
then
  rm -rf seedfs.tmp
  mkdir seedfs.tmp
  cd seedfs.tmp
  cp -r ../mcm2_out/* ./
  cp ../busybox/busybox ./bin/
  cd bin
  for app in $(./busybox --list)
  do
    ln -s ./busybox $app
  done
  ln -s ./x86_64-linux-musl-ar ar
  ln -s ./x86_64-linux-musl-as as
  ln -s ./x86_64-linux-musl-c++ c++
  ln -s ./x86_64-linux-musl-c++ g++
  ln -s ./x86_64-linux-musl-cpp cpp
  ln -s ./x86_64-linux-musl-gcc cc
  ln -s ./x86_64-linux-musl-gcc gcc
  ln -s ./x86_64-linux-musl-ld ld
  ln -s ./x86_64-linux-musl-nm nm
  ln -s ./x86_64-linux-musl-objcopy objcopy
  ln -s ./x86_64-linux-musl-objdump objdump
  ln -s ./x86_64-linux-musl-ranlib ranlib
  ln -s ./x86_64-linux-musl-readelf readelf
  ln -s ./x86_64-linux-musl-strings strings
  ln -s ./x86_64-linux-musl-strip strip
  cd ../../
  mv seedfs.tmp seedfs
fi

cd seedfs
find . \
  | LC_ALL=C sort \
  | tar --owner=root:0 --group=root:0 --mtime='UTC 2019-01-01' --no-recursion -T - -cf - \
  | gzip -9 > ../seed.tar.gz
