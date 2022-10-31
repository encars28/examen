#!/bin/bash
# opciones=( "A. Código que asigna a cada caracter un número." "B. Es un código internacional." "C. Es un código que se usa para pasar de decinal al binario." "D. Es un código que se usa para pasar de bianrio a decimal." )

readarray -t lineas < banco.txt
var=${lineas[62]}
echo "$var" | sed 's/\r$//'