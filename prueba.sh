#!/bin/bash

[[ $1 == +([0-9]) ]] && echo "$1 is an integer" && echo $(($1 + 1))