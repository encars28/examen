#!/bin/bash
prueba=(hola adios pepa)
delete="adios"
prueba=( "${prueba[@]/$delete}" )
printf '%s\n' "${prueba[@]}"
