#!/bin/sh

usage="Usage: $0 PA_VOLUME_VALUE [DISP_ID]

DISP_ID is required if there're more than one running disp VMs. The respective disposable should exist."

if [ $# -lt 1 ]; then
  echo "$usage"
  exit 1
fi
value=$1
if [ $# -lt 2 ]; then
  set -- $(qvm-ls | grep '^disp\S*' -o)
  if [ $# -ne 1 ]; then
    echo "$usage"
    exit 1
  fi
  disp_name=$1
else
  disp_name=disp$2
fi

qvm-ls | grep $disp_name &> /dev/null
if [ $? -ne 0 ]; then
  echo "No such domain: $disp_name"
  exit 1
fi

qvm-run --user user ${disp_name} 'pactl set-sink-volume $(pactl get-default-sink) '$value
