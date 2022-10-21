#!/bin/bash
prueba=(hola adios pepa)
unset 'prueba[1]'
echo "${prueba[@]}"
echo "${prueba[2]}"
