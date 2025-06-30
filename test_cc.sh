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

CC_SNAPSHOT=./snapshot-z

# Test 1: Help option (-h)
output=$(TESTING_SKIP_ROOT_CHECK=1 "$CC_SNAPSHOT" -h 2>&1) || true
if [[ "$output" == *"usage:"* ]]; then
  pass "Help option (-h) shows usage"
else
  fail "Help option (-h) did not show usage"
fi

# Test 2: -e without folder
output=$(TESTING_SKIP_ROOT_CHECK=1 "$CC_SNAPSHOT" -e 2>&1) && status=0 || status=$?
if [[ $status -ne 0 && "$output" == *"usage:"* ]]; then
  pass "-e without folder fails with error"
else
  fail "-e without folder did not fail as expected"
fi

#test 3: running with an invalid flag (-z)
output=$(TESTING_SKIP_ROOT_CHECK=1 "$CC_SNAPSHOT" -z 2>&1) && status=0 || status=$?
if [[ $status -ne 0 && "$output" == *"usage:"* ]]; then
  pass "Invalid flag (-z) is handled with error"
else
  fail "Invalid flag (-z) did not trigger error as expected"
fi

echo "All applicable interface tests passed."
# Test 3: -f suppresses warnings
#output=$(sudo ./snapshot-z -f test-snapshot 2>&1) && status=0 || status=$?
#if echo "$output" | grep -qi "warning"; then
#  fail "-f did not ignore warnings"
#else
#  pass "-f ignored warnings as expected"
#fi

#test 4: -y flage test 
#output=$(sudo ./snapshot-z -y 2>&1) || true
#if echo "$output" | grep -qi "y/n"; then
#  fail "With -y, script still prompted for confirmation"
#else
#  pass "With -y, script skipped confirmation as expected"
#fi
### Testing check_size and prepare_tarball

dd if=/dev/zero of=/tmp/fake.tar bs=1M count=10 status=none

# Run the check_size function and capture its output
echo "entring to script from test file"
#output=$(DUMMY_STAGE=check_size ./snapshot-z mytest 2>&1)
output=$(echo yes |sudo env \
  CC_SNAPSHOT_TAR_PATH=/tmp/fake.tar \
  CC_SNAPSHOT_MAX_TARBALL_SIZE=5 \
  IGNORE_WARNING=false \
  DUMMY_STAGE=check_size \
  ./snapshot-z mytest 2>&1)
echo "working 3"
if echo "$output" | grep -q "snapshot is too large"; then
  pass "check_size correctly detected large snapshot"
else
  fail "check_size did not detect large snapshot"
fi
echo "working4"
#clean
rm -f /tmp/fake.tar
echo "working 5"

#Test : Dry-run does not error and prints each step 
output=$(TESTING_SKIP_ROOT_CHECK=1 "$CC_SNAPSHOT" -d mytest 2>&1) || status=$?
if [[ $status -eq 0 && "output" == *"[DRY-RUN]"* ]]; then
  pass "Dry-run flag prints steps without error"
else
  fail "Dry-run did not behave as expected"
fi 

echo " end of dry run test"
