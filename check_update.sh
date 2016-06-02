#!/bin/bash

# Color Constants
RED="0;31";  GREEN="0;32";  BROWN="0;33"; BLUE="0;34";  PURPLE="0;35";  CYAN="0;36";  GRAY="0;37";
PINK="1;31"; LGREEN="1;32"; YELLOW="1;33" LBLUE="1;34"; MAGENTA="1;35"; LCYAN="1;37"; WHITE="1;37"

# Output functions with nice colors
#
function color_echo_nnl {
    echo -en "\033[$1m"
    echo -n "$2"
    echo -en "\033[0;37m"
}
function color_echo {
    echo -en "\033[$1m"
    echo -n "$2"
    echo -e "\033[0;37m"
}

# Check where we are
if [ ! -f 'Vagrantfile.local' ];
then
    color_echo $YELLOW "This box has not been configured yet or this command hasn't been ran from the root of the project"
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

# Checking for local changes
git diff --quiet --exit-code
if [ $? -ne 0 ]; then
    color_echo $YELLOW "Your basebox has local changes."
    color_echo $YELLOW "Customizations should be done in the Vagrantfile.local and dev/salt folders instead."
    color_echo $YELLOW "Please revert these changes where possible or commit them and issue a PR."
    exit 0;
fi

git fetch origin master --quiet
if [ $? -ne 0 ]; then
    color_echo $PINK "Unable to check for basebox updates."
    exit 1
fi

COMMITS_AHEAD=$(git rev-list --left-right --count master...origin/master | awk {'print $1'})
if [ $COMMITS_AHEAD -gt 0 ]; then
    color_echo $YELLOW "You made $COMMITS_AHEAD local commit(s) in the basebox."
    color_echo $YELLOW "Don't forget to open a Pull Request against the Enrise repo."
    exit 0;
fi

COMMITS_BEHIND=$(git rev-list --left-right --count master...origin/master | awk {'print $2'})
if [ $COMMITS_BEHIND -gt 0 ]; then
    color_echo $YELLOW "Your basebox is behind by $COMMITS_BEHIND commit(s) and requires an update."
    color_echo $YELLOW "Please make sure to update as soon as possible to prevent problems and technical debt."
    exit 0;
fi

color_echo $LGREEN "Your basebox is up-to-date."
