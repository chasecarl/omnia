#!/bin/sh

action=$1
shift
flags=""

case $action in
  "detach")
    :
  ;;
  "attach")
    flags="--persistent --option no-strict-reset=true"
  ;;
  *)
    echo "Unsupported action $action"
    exit -1
  ;;
esac

qvm-shutdown sys-usb
sleep 10

for device_id in "$@"; do
  qvm-device pci $action $flags sys-usb $device_id
done

sleep 10
qvm-start sys-usb
