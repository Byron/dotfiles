#!/bin/bash -u


our_dir=$(cd "$(dirname $0)" && pwd)
source $our_dir/../lib/utilities.sh

echo Updating everything
update_everything
echo DONE


