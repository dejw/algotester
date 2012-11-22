#!/bin/bash

# config

with_timeout=1
time_limit="1s"   # (float)
memory_limit=32   # (int) megs


if [ -z "$1" ]; then
  echo "usage: $0 program [testfile|testdir, ...]"
  exit 1
fi

program=$1
count=0
accepted=0
wrong_answer=0
time_limit_exceeded=0
memory_limit_exceeded=0

# drop program name
shift

function run() {
  # prepare script
  echo "ulimit -v ${memory_limit}000; (time -f '%es' ./$program < '${1}.in' > /tmp/$program.out) 2>&1" > /tmp/run_$program.sh
  chmod +x /tmp/run_$program.sh

  echo -n "   . "
  if [ $with_timeout = "1" ]; then
    timeout $time_limit /tmp/run_$program.sh 2> /dev/null
  else
    /tmp/run_$program.sh 2> /dev/null
  fi

  prog_status=$?

  if [ $prog_status = "124" ]; then
    echo "   [TLE] $1"
    ((time_limit_exceeded++))
  elif [ $prog_status = "2" -o $prog_status = "137" ]; then
    echo "   [ME] $1"
    ((memory_limit_exceeded++))
  else
    cmp /tmp/$program.out "${1}.out" --silent
    cmp_status=$?

    if [ ! $cmp_status = "0" ]; then
      echo "   [WA] $1"
      ((wrong_answer++))
    else
      ((accepted++))
    fi
  fi
  ((count++))
}

# Timeout check
timeout --help > /dev/null

if [ ! $? = "0" ]; then
  echo "!! timeout command not found, install using: sudo apt-get install coreutils"
  with_timeout=0
fi

echo ".. Compile"
make "CPPFLAGS=-O2 -static -lm" $program || exit 1

if [ $# -eq 0 ]; then
  echo ".. Run (interactive)"
  ./$program
else
  echo ".. Run"
  echo ".. Memory limit = ${memory_limit} megs"
  if [ $with_timeout = "1" ]; then
    echo ".. Time limit = $time_limit"
  fi

  for testfile in $@; do
    echo ".. Testing: $testfile"

    if [ -d $testfile ]; then
      for filename in $testfile/*.in; do
        testfile2=`basename $filename .in`
        run "$testfile/$testfile2"
      done
    elif [ -f $testfile ]; then
      run $testfile
    else
      echo "!! not found, skipping"
    fi
  done

  echo -e "\n.. $count tests run, $accepted ACC, $wrong_answer WA, $time_limit_exceeded TLE, $memory_limit_exceeded ME"
fi
