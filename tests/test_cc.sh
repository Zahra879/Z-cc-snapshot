#!/usr/bin/env bash

set -euo pipefail

echo "Running cc-snapshot interface tests..."

fail() {
  echo "FAIL: $1"
  exit 1
}

pass() {
  echo "PASS: $1"
}

# Test 1: Help option (-h)
output=$(sudo cc-snapshot -h 2>&1) || true
if [[ "$output" == *"usage:"* ]]; then
  pass "Help option (-h) shows usage"
else
  fail "Help option (-h) did not show usage"
fi

# Test 2: -e without folder
output=$(sudo cc-snapshot -e 2>&1) && status=0 || status=$?
if [[ $status -ne 0 && "$output" == *"Invalid option"* ]]; then
  pass "-e without folder fails with error"
else
  fail "-e without folder did not fail as expected"
fi

# Test 3: -f suppresses warnings
output=$(sudo cc-snapshot -f test-snapshot 2>&1) && status=0 || status=$?
if echo "$output" | grep -qi "warning"; then
  fail "-f did not ignore warnings"
else
  pass "-f ignored warnings as expected"
fi

#test 4: -y flage test 
output=$(sudo ./cc-snapshot -y 2>&1) || true
if echo "$output" | grep -qi "y/n"; then
  fail "With -y, script still prompted for confirmation"
else
  pass "With -y, script skipped confirmation as expected"
fi

# Test 3: Optional --version flag (if implemented)
#output=$(sudo ./cc-snapshot --version 2>&1) || true
#if [[ "$output" == *"cc-snapshot version"* ]]; then
#  pass "--version outputs version string"
#else
#  echo "NOTE: --version not supported or no version string found"
#fi

echo "All applicable interface tests passed."

