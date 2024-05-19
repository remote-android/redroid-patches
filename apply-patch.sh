#!/usr/bin/env bash

usage() {
    echo "USAGE: $(basename "$0") AOSP-SRC [TAG]"
    exit 1
}

[[ "$#" -lt 1 ]] && usage

src=$1
tag=$2

if [[ -z $tag ]]; then
    echo "detect AOSP tag from manifest"
    tag=$(basename "$(xmllint --xpath "string(/manifest/default/@revision)" "$src"/.repo/manifests/default.xml)")
fi

echo "===== AOSP SRC: $src"
echo "===== AOSP TAG: $tag"

patch_dir=$(dirname "$(realpath "$0")")/$tag
if [[ ! -d $patch_dir ]]; then
    echo "patches for $tag not exist"
    exit 1
fi

cd "$patch_dir" || exit 1
while read -r p
do
    [[ $(find "$patch_dir/$p" -maxdepth 1 -name '*.patch' 2> /dev/null | wc -l) -eq 0 ]] && continue

    echo
    echo "process project: $p"
    git -C "$src/$p" am --reject "$patch_dir/$p"/* || echo "*****[ERROR]***** apply failed: $p"
done < <(find -- * -type d)
