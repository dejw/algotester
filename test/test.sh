#!/bin/bash

function runTester() {
  ../algotester.sh $1 testdir | tail -n1
}

function assertIn() {
  echo -n "."
  if [[ ! "$2" == *"$1"* ]]; then
    echo "FAIL: $3 test: '$1' not found in '$2'"
  fi
}

assertIn "1 ACC" "`runTester ok`" "ACC"
assertIn "1 WA" "`runTester wa`" "WA"
assertIn "1 TLE" "`runTester sleep2`" "TLE"
assertIn "1 ME" "`runTester mem_ex`" "ME"

echo