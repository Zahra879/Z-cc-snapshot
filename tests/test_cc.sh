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
if [[ $status -ne 0 && "$output" == *"usage:"* ]]; then
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
#test 5: running with an invalid flag (-z)
output=$(sudo ./cc-snapshot -z 2>&1) && status=0 || status=$?
if [[ $status -ne 0 && "$output" == *"usage:"* ]]; then
  pass "Invalid flag (-z) is handled with error"
else
  fail "Invalid flag (-z) did not trigger error as expected"
fi
# Test 3: Optional --version flag (if implemented)
#output=$(sudo ./cc-snapshot --version 2>&1) || true
#if [[ "$output" == *"cc-snapshot version"* ]]; then
#  pass "--version outputs version string"
#else
#  echo "NOTE: --version not supported or no version string found"
#fi

echo "All applicable interface tests passed."
# If i can run cc-snapshot once and test it with diff flags? Is it possible since the outputs are diff and can i include all flags and test it 
# is there a way so it does not run the cc snapshot each time wehn i test for interface and flags or possibly run it once and test the flags?
#should i test for sudo ? 
# how to test the coding part?
# are the files created or delete when doing snapshot
# Are the dir actually excluded using -e
# does the files contain the right content?
# what happens if run with combination of arguments ?

