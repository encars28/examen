#!/bin/bash

# [] Abrir el fichero con las preguntas e intentar:
#     [] Convertir cada pregunta en un solo string
#     [] Hacer un array de strings con todas las preguntas
#     [] Comprobar que el numero de preguntas dadas no sea mayor que las que hay en el fichero

numeroPreguntas=5
preguntasAleatorias=false
fichero=bancoPreguntas.txt

declare - preguntas

#if test -a fichero
#then
  #  echo "Error: el fichero no existe"
   # exit 8
#fi

declare count=6;
while read line
do
   temp=$(head -1 $fichero) 
   preguntas+=($temp)
   # temp=$(sed '1,7d' $fichero) 
    if[count ==]
    echo "${preguntas[@]}"
    
done < $fichero
