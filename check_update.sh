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

# Update checking time
git fetch origin master -q
if [ $? -eq 0 ]; then
  LOCAL=$(git rev-parse @)
  REMOTE=$(git rev-parse @{u})
  BASE=$(git merge-base @ @{u})

  if [[ $LOCAL == $REMOTE ]]; then
    echo -n -e "\e[92m"
    echo -n "Your basebox is up-to-date."
  elif [[ $LOCAL == $BASE ]]; then
    echo -n -e "\e[36m"
    echo -n "Your basebox requires an update."
  elif [[ $REMOTE == $BASE ]]; then
    echo -n -e "\e[33m"
    echo "Your basebox has local changes."
    echo "Customizations should be done in the Vagrantfile.local and dev/salt folders instead!"
    echo -n "Please revert these changes where possible"
  else
    echo -n -e "\e[31m"
    echo -n "Unable to check for basebox updates"
  fi
  echo -e "\e[0m"
fi
