#!/bin/bash

# [] Abrir el fichero con las preguntas e intentar:
#     [] Convertir cada pregunta en un solo string
#     [] Hacer un array de strings con todas las preguntas
#     [] Comprobar que el numero de preguntas dadas no sea mayor que las que hay en el fichero

numeroPreguntas=5
preguntasAleatorias=false
fichero=bancoPreguntas.txt

declare -A pregunta
declare -a todasPreguntas

#if test -a fichero
#then
  #  echo "Error: el fichero no existe"
   # exit 8
#fi


temp=$(tr -d '\r' < $fichero)

# while temp != EOF
# do
    pregunta+=( ["enunciado"]="$(echo "$temp" | head -1 )")
    temp=$(echo "$temp" | sed '1d')

    readarray -t opciones < <(echo "$temp" | head -4)
    # hacer aqui una comprbacion de si las respuestas son aleatorias
    opcionesCadena=$( printf '%s\n' "${opciones[@]}")

    pregunta+=( ["opciones"]="$opcionesCadena")
    temp=$(echo "$temp" | sed '1,4d' )

    pregunta+=( ["respuesta"]=$(echo "$temp" | head -1 | cut -f 2 -d ' ') )
    temp=$(echo "$temp" | sed '1,2d')

    echo "${pregunta[@]}"

    # todasPreguntas+=( $pregunta )
# done

