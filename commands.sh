#!/usr/bin/env bash

function run_cmd(){
	echo "Running: $1"
	$1

	if [ "$?" -ne "0" ]; then
	  echo "command failed: $1"
	  exit 1
	fi
}

# Custom die function.
function die() { echo >&2 -e "\nERROR: $@\n"; exit 1; }