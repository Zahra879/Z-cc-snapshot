#!/bin/bash

set -e

# Create folder for logs
mkdir -p snapshot_test_logs

echo "Capturing pre-snapshot system state..."

# Save environment and system state before snapshot
printenv | sort > snapshot_test_logs/env_before.txt
ps aux > snapshot_test_logs/ps_before.txt
df -h > snapshot_test_logs/disk_before.txt
mount > snapshot_test_logs/mount_before.txt

echo ""
read -p " Run 'cc-snapshot <name>' in a different terminal, then press Enter to continue..."

echo " Capturing post-snapshot system state..."

# Save environment and system state after snapshot
printenv | sort > snapshot_test_logs/env_after.txt
ps aux > snapshot_test_logs/ps_after.txt
df -h > snapshot_test_logs/disk_after.txt
mount > snapshot_test_logs/mount_after.txt

echo ""
echo "Comparing environment and system state..."

# Compare each before/after file
compare_files() {
    local before="$1"
    local after="$2"
    local label="$3"

    if diff -u "$before" "$after" > snapshot_test_logs/diff_${label}.txt; then
        echo " No differences in $label"
    else
        echo "Differences found in $label:"
        cat snapshot_test_logs/diff_${label}.txt
    fi
}

compare_files snapshot_test_logs/env_before.txt snapshot_test_logs/env_after.txt "env"
compare_files snapshot_test_logs/ps_before.txt snapshot_test_logs/ps_after.txt "ps"
compare_files snapshot_test_logs/disk_before.txt snapshot_test_logs/disk_after.txt "disk"
compare_files snapshot_test_logs/mount_before.txt snapshot_test_logs/mount_after.txt "mount"

echo ""
echo "Snapshot test completed."

