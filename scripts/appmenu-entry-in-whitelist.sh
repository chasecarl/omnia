#!/bin/sh
# TODO: check 'qvm-appmenus' vs 'qvm-features <vm> menu-items'
alias qvm-appmenus="qvm-appmenus --force-root"
vm=$1
desktop_entry_name=$2

whitelist=$(qvm-appmenus --get-whitelist $vm)

# if $desktop_entry_name is a substring of $whitelist...
# https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion
if [ -z ${whitelist##*$desktop_entry_name*} ] 2> /dev/null; then
  echo "changed='no' comment='The entry $desktop_entry_name is already enabled.'"
else
  # creating an array that represents the new whitelist
  set -- $whitelist $desktop_entry_name
  echo "$@" | qvm-appmenus --set-whitelist - $vm
  echo "changed='yes' comment='The entry $desktop_entry_name was added.'"
fi
