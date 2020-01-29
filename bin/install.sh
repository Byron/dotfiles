#!/bin/bash -u


read -p "Hit <enter> to idempotently setup everything Byron needs on OSX ..."

our_dir=$(cd "$(dirname $0)" && pwd)
for lib in utilities install; do
  source $our_dir/../lib/$lib.sh
done

echo LINKING DOTFILES
link_dotfiles "$(cd $our_dir/.. && pwd)" etc


echo DONE
