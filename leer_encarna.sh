#!/bin/bash

# [] Abrir el fichero con las preguntas e intentar:
#     [] Convertir cada pregunta en un solo string
#     [] Hacer un array de strings con todas las preguntas
#     [x] Comprobar que el numero de preguntas dadas no sea mayor que las que hay en el fichero

numeroPreguntas=5
preguntasAleatorias=false
fichero=bancoPreguntas.txt

# declare -A pregunta
declare -a lineas
declare -A preguntas

# le quito el retorno de carro (en caso de que el fichero haya sido escrito en windows)
# para no tener problemas con los saltos de linea
temp=$(tr -d '\r' < $fichero)

# Leemos el fichero linea a linea, eliminando los \n
while read -r line
do
    # De esta manera elimino las nuevas lineas entre pregunta y pregunta
    if [[ $line != "" ]]
    then
        lineas+=( "$line" )
    fi
done < <(echo "$temp")

# Uno todas las lineas en preguntas, creando un arrray de preguntas
inicio=0
contador=0
while [[ $inicio < ${#lineas[@]} ]]
do
    preguntas+=( ["$contador, pregunta"]="${lineas[@]:$inicio:1}" )
    # capturo las opciones en un array
    opciones=( "${lineas[@]:$((inicio + 1)):4}")
    # le hago la comprobacion de si es aleatorio y en ese caso cambio el orden
    opcionesCadena=$( printf '%s\n' "${opciones[@]}")
    preguntas+=( ["$contador, opciones"]="$opcionesCadena" )
    respuesta=$( echo "${lineas[@]:$((inicio + 5)):1}" | cut -f 2 -d ' ' )
    preguntas+=( ["$contador, respuesta"]=$respuesta )

    contador=$((contador + 1))
    # cada pregunta esta formada por 6 lineas, 
    inicio=$((inicio + 6))
done

preguntasFichero=$contador
if [[ $numeroPreguntas > $preguntasFichero ]]
then
    echo "Error: el numero de preguntas introducido es mayor que el numero de preguntas del fichero"
    exit
fi



# do
#     preguntas+=( "$(echo "$temp" | head -6)" )
#     temp=$(echo "$temp" | sed '1,7d')
#     echo "${#preguntas[@]}"
# done < <(echo "$temp")

# declare -p preguntas

# temp=$(echo "$temp" | sed '1,70d')
# cat -A < <(echo "$temp")

# while temp != EOF
# do
    # pregunta+=( ["enunciado"]="$(echo "$temp" | head -1 )")
    # temp=$(echo "$temp" | sed '1d')

    # readarray -t opciones < <(echo "$temp" | head -4)
    # # hacer aqui una comprbacion de si las respuestas son aleatorias
    # opcionesCadena=$( printf '%s\n' "${opciones[@]}")

    # pregunta+=( ["opciones"]="$opcionesCadena")
    # temp=$(echo "$temp" | sed '1,4d' )

    # pregunta+=( ["respuesta"]=$(echo "$temp" | head -1 | cut -f 2 -d ' ') )
    # temp=$(echo "$temp" | sed '1,2d')

    # echo "${pregunta[@]}"

    # todasPreguntas+=( $pregunta )
# done

