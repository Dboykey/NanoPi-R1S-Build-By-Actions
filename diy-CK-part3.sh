#!/bin/bash

. ../../remove_unused_config.sh
cat ../../app_config.seed >> configs/config_h5
echo '# CONFIG_V2RAY_COMPRESS_UPX is not set' >> configs/config_h5
sed -i '/docker/Id;/containerd/Id;/runc/Id;/iptparser/Id' configs/config_h5 #fix compile error

cd ..
git config --local user.email "action@github.com" && git config --local user.name "GitHub Action"
git remote add upstream https://github.com/coolsnowwolf/lede && git fetch upstream

cd friendlywrt
git rebase 0f0c3f1a251f636df68050b75e296c6cc6965590^ --onto upstream/master -X theirs
