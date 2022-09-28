#!/usr/bin/env bash

PY_VER="3.10.7"
CROSS_ROOT="/usr/local/oecore-x86_64"

if [[ ! -d $CROSS_ROOT ]]; then
    echo "Either you need to install the toolchain, or you haven't edited it's location in the build script"
    exit 1
fi

wget https://www.python.org/ftp/python/${PY_VER}/Python-${PY_VER}.tgz
tar -xvf Python-${PY_VER}.tgz

cd Python-${PY_VER}

source ${CROSS_ROOT}/environment-setup-cortexa7hf-neon-remarkable-linux-gnueabi

[[ -d _install ]] && rm -rf _install
mkdir _install

cp ${CROSS_ROOT}/site-config-cortexa7hf-neon-remarkable-linux-gnueabi ${CROSS_ROOT}/site-config-cortexa7hf-neon-remarkable-linux-gnueabi.save

echo >> ${CROSS_ROOT}/site-config-cortexa7hf-neon-remarkable-linux-gnueabi << EOF
# FOR PYTHON
# i'm just guessing tbh
ac_cv_file__dev_ptmx=yes
ac_cv_file__dev_ptc=no
EOF

./configure --host=x86_64-pc-linux-gnu --build=arm-remarkable-linux-gnueabi --prefix=$PWD/_install --enable-optimizations

make -j $(nproc)
make install

tar czf ../py.tgz --directory=_install .

cd ../
rm -rfv Python*
rm -rfv _install

rm ${CROSS_ROOT}/site-config-cortexa7hf-neon-remarkable-linux-gnueabi
mv ${CROSS_ROOT}/site-config-cortexa7hf-neon-remarkable-linux-gnueabi.save ${CROSS_ROOT}/site-config-cortexa7hf-neon-remarkable-linux-gnueabi
