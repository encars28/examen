#!/bin/bash
array=("$@")
array2=( "$(printf '%s\n' "${array[@]}" | grep "a")" )

printf '%s\n' "${array2[@]}"