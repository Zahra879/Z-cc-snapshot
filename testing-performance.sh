#!/usr/bin/env bash
set -euo pipefail

sudo sync
echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null

time sudo ./cc-snapshot -u -d testing-default

echo

echo "Uploading to Glance"
time sudo openstack image create testing-default \
     --disk-format qcow2 \
     --container-format bare \
     --file testing-default

