#!/bin/bash

set -eu
set -o pipefail

assert() {
  local pass=yes
  echo -n "$1: "
  if [ "$2" = "$3" ]; then
    echo OK
  else
    echo NG
    echo "  expected: $2"
    echo "    actual: $3"
    return 1
  fi
}

cmd="lisp"

passes=0
total=0
for file in **/*.txt; do
  total=$(($total+1))
  echo "[$file]"
  stdin=$(head -n 1 "$file")
  expected_status=$(sed -n 2p "$file")
  expected_stdout=""
  expected_stderr=""
  if [ "$expected_status" -eq 0 ]; then
    expected_stdout=$(tail -n +3 "$file")
  else
    expected_stderr=$(tail -n +3 "$file")
  fi

  stdout= stderr=
  eval "$( (echo ${stdin} | ${cmd}) 2> >(stderr=$(cat);typeset -p stderr) > >(stdout=$(cat);typeset -p stdout);status=$?;typeset -p status)"
  pass=yes
  assert status "$expected_status" "$status" || pass=no
  assert stdout "$expected_stdout" "$stdout" || pass=no
  assert stderr "$expected_stderr" "$stderr" || pass=no
  echo ""

  test "$pass" = yes && passes=$(($passes+1))
done

echo "Pass ${passes}/${total} cases"
test "${passes}" -eq "${total}"
