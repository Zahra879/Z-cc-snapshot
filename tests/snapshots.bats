#!/usr/bin/env bats

@test "cc-snapshot shows usage with -h" {
  run sudo cc-snapshot -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"usage:"* ]]
}
#bats cc-snapshot.bats

