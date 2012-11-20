#!/bin/bash

if [ -z $1 -o -z $2 ]; then
  echo "usage: $0 program [testfile|testdir]"
  exit 1
fi

program=$1
testfile=$2
count=0
wrong_answer=0
time_limit_exceeded=0
with_timeout=1
time_limit="1s"

function run() {
  if [ $with_timeout = "1" ]; then
    echo "./$program < '${1}.in' | cmp - '${1}.out' --silent" > /tmp/_test.sh
    chmod +x /tmp/_test.sh
    timeout $time_limit /tmp/_test.sh
  else
    ./$program < "${1}.in" | cmp - "${1}.out"
  fi

  status=$?
  if [ $status = "124" ]; then
    echo "   [TLE] $1"
    ((time_limit_exceeded++))
  elif [ ! $status = "0" ]; then
    echo "   [WA] $1"
    ((wrong_answer++))
  fi
  ((count++))
}

# Timeout check
timeout --help > /dev/null

if [ ! $? = "0" ]; then
  echo ".. timeout command not found, install using: sudo apt-get install coreutils"
  with_timeout=0
fi

echo ".. Compile"
make "CPPFLAGS=-O2 -static -lm" $program

echo ".. Run"
if [ -z $testfile ]; then
  ./$program
else
  if [ $with_timeout = "1" ]; then
    echo ".. Time limit = $time_limit"
  fi

  if [ -d $testfile ]; then
    for filename in $testfile/*.in; do
      testfile2=`basename $filename .in`
      run "$testfile/$testfile2"
    done
  else
    run $testfile
  fi
  echo ".. $count tests run, $wrong_answer WA, $time_limit_exceeded TLE"
fi
