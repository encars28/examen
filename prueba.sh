#!/bin/bash
# opciones=( "A. Código que asigna a cada caracter un número." "B. Es un código internacional." "C. Es un código que se usa para pasar de decinal al binario." "D. Es un código que se usa para pasar de bianrio a decimal." )

var=$'Hola esto es un texto\nAdios'
echo "$var" > prueba.txt
echo $'\nEsto es una linea extra' >> prueba.txt