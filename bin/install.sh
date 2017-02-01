#!/bin/bash -u


read -p "Hit <enter> to idempotently setup everything Byron needs on OSX ..."

our_dir=$(cd "$(dirname $0)" && pwd)
for lib in utilities install; do
  source $our_dir/../lib/$lib.sh
done

echo CLONING REPOSITORIES
clone_repositories
echo SETTING UP RUST
setup_rust
echo DONE


