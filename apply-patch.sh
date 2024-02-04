#!/usr/bin/env bash

usage() {
    script=`basename $0`
    echo "USAGE: $script AOSP-SRC [TAG]"
    exit 1
}

[[ "$#" -lt 1 ]] && usage

src=$1
tag=$2

if [ -z "$tag" ]; then
    echo "detect AOSP tag from manifest"
    tag=`grep revision $src/.repo/manifests/default.xml | cut -d\" -f 2 | cut -d/ -f 3`
fi

echo "===== AOSP SRC: $src"
echo "===== AOSP TAG: $tag"

patch_dir=$(dirname $(realpath $0))/$tag
if [ ! -d $patch_dir ];then
    echo "patches for $tag not exist"
    exit 1
fi

echo "Begin to apply patches from $patch_dir"
cd $patch_dir
pwd
for p in `find *`
do
    # if this is a patch file that ends with .patch
    if [[ $p == *.patch ]]; then
        project_dir=$(dirname $p)
        echo "process project: $project_dir"
        git -C $src/$project_dir apply --reject $patch_dir/$p || echo "*****[ERROR]***** apply failed: $p"
    fi
done
