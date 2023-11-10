#!/bin/sh
# TODO: figure out how to use highstate for this
# logs for domU are in /var/log/qubes/mgmt-<vm-name>
dev_vm_name="dev"
qubesctl state.sls separate-build-and-dev saltenv=user \
  && qubesctl --skip-dom0 --targets=builder-networking state.sls builder-networking saltenv=user \
  && qubesctl --skip-dom0 --targets=app-manager state.sls app-manager saltenv=user \
  && qubesctl --skip-dom0 --targets=$dev_vm_name state.sls dev saltenv=user \
  && qvm-sync-appmenus $dev_vm_name
# finished in 12m41s on my system!
