#!/bin/bash

# Check where we are
if [ ! -f 'Vagrantfile.local' ];
then
  echo "This box has not been configured yet or this command hasn't been ran from the root of the project"
  exit 1
fi

# Load the config
BBPATH=$(grep -v "^#" Vagrantfile.local | grep basebox_path | awk {'print $4'})
if [[ $BBPATH -eq '' ]]
then
  BBPATH='dev/basebox'
fi

# Check if basebox path exists
if [[ ! -d $BBPATH ]]
then
  echo "Unable to find the basebox in $BBPATH"
  exit 1
fi

cd $BBPATH
git pull origin master -q
if [ $? -eq 0 ]; then
  git submodule sync
  git submodule update --init --recursive
fi
