#!/usr/bin/env bash

set -ex

PY_VER="3.10.7"
CROSS_ROOT="/usr/local/oecore-x86_64"

TOOLCHAIN_VER="3.1.15"

if [[ ! -d $CROSS_ROOT ]]; then
    if [[ "$1" == "-y" || "$1" == "-g" ]]; then
        wget https://storage.googleapis.com/remarkable-codex-toolchain/codex-x86_64-cortexa7hf-neon-rm11x-toolchain-${TOOLCHAIN_VER}.sh
        chmod +x codex-x86_64-cortexa7hf-neon-rm11x-toolchain-${TOOLCHAIN_VER}.sh
        ./codex-x86_64-cortexa7hf-neon-rm11x-toolchain-${TOOLCHAIN_VER}.sh -y -d /usr/local/oecore-x86_64
    else
        echo "Either no toolchain or wrong path"
        exit 1
    fi
fi

if [[ "$1" == "-g" ]]; then
    sudo pacman -S python python-pip
fi

wget https://www.python.org/ftp/python/${PY_VER}/Python-${PY_VER}.tgz
tar -xvf Python-${PY_VER}.tgz

cd Python-${PY_VER}

source ${CROSS_ROOT}/environment-setup-cortexa7hf-neon-remarkable-linux-gnueabi

[[ -d _install ]] && rm -rf _install
mkdir _install

sudo cp ${CROSS_ROOT}/site-config-cortexa7hf-neon-remarkable-linux-gnueabi ${CROSS_ROOT}/site-config-cortexa7hf-neon-remarkable-linux-gnueabi.save

echo | sudo tee -a ${CROSS_ROOT}/site-config-cortexa7hf-neon-remarkable-linux-gnueabi << EOF
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

if [[ ! "$1" == "-y" ]]; then
    sudo rm ${CROSS_ROOT}/site-config-cortexa7hf-neon-remarkable-linux-gnueabi
    sudo mv ${CROSS_ROOT}/site-config-cortexa7hf-neon-remarkable-linux-gnueabi.save ${CROSS_ROOT}/site-config-cortexa7hf-neon-remarkable-linux-gnueabi
fi