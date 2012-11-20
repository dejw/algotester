#!/bin/bash

if [ -z $1 -o -z $2 ]; then
  echo "usage: $0 program [testfile|testdir]"
  exit 1
fi

program=$1
testfile=$2
count=0
wrong_answer=0

function run() {
  ./$program < "${1}.in" | cmp - "${1}.out"
  if [ ! $? = "0" ]; then
    ((wrong_answer++))
  fi
  ((count++))
}

echo ".. Compile"
make "CPPFLAGS=-O2 -static -lm" $program

echo ".. Run"
if [ -z $testfile ]; then
  ./$program
else
  if [ -d $testfile ]; then
    for filename in $testfile/*.in; do
      testfile2=`basename $filename .in`
      run "$testfile/$testfile2"
    done
  else
    run $testfile
  fi
  echo ".. $count tests run, $wrong_answer WA"
fi
