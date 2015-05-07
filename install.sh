#!/bin/bash
echo "This will install the basebox to $PWD."
read -p "Are you sure? [y/n] " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Aborted"
    exit 1
fi

# Symlink the vagrantfile
if [[ ! -e Vagrantfile ]];
then
  ln -s dev/basebox/Vagrantfile .
fi

# Copy the local config file
if [[ ! -e Vagrantfile.local ]];
then
  cp dev/basebox/Vagrantfile.local.dist Vagrantfile.local
fi

# Copy the customization structure
if [[ ! -e dev/salt ]];
then
  cp dev/basebox/salt.dist dev/salt -r
fi

# Initiate the submodules
cd dev/basebox
git submodule sync
git submodule update --init --recursive

echo -e "\e[32m"
echo "****"
echo "Install complete"
echo ""
echo "Please modify Vagrantfile.local with your favorite text editor"
echo "See the readme.md for further instructions"
echo -e "\e[39m"
