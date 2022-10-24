#!/bin/bash

# TODO: implementacion de aleatorio

numeroPreguntas=5
# preguntasAleatorias=false
fichero=bancoPreguntas.txt

# declare -A pregunta
declare -a lineas
declare -A todasPreguntas
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
    todasPreguntas+=( ["$contador, pregunta"]="${lineas[@]:$inicio:1}" )
    # capturo las opciones en un array
    opciones=( "${lineas[@]:$((inicio + 1)):4}")
    # le hago la comprobacion de si es aleatorio y en ese caso cambio el orden
    opcionesCadena=$( printf '%s\n' "${opciones[@]}")
    todasPreguntas+=( ["$contador, opciones"]="$opcionesCadena" )
    respuesta=$( echo "${lineas[@]:$((inicio + 5)):1}" | cut -f 2 -d ' ' )
    todasPreguntas+=( ["$contador, respuesta"]=$respuesta )

    contador=$((contador + 1))
    # cada pregunta esta formada por 6 lineas
    inicio=$((inicio + 6))
done

# compruebo que el numero de preguntas no sea mayor al que las que hay en el fichero
preguntasFichero=$contador
echo "$preguntasFichero"
echo "$numeroPreguntas"
if [[ $numeroPreguntas -gt $preguntasFichero ]]
then
    echo "Error: el numero de preguntas introducido es mayor que el numero de preguntas del fichero"
    exit
fi

# Ajustar el numero de preguntas al dado
# TODO: comprobacion aleatorio
i=0
while [[ $i < $numeroPreguntas ]]
do 
    preguntas+=( ["$i, pregunta"]="${todasPreguntas["$i, pregunta"]}" )
    preguntas+=( ["$i, opciones"]="${todasPreguntas["$i, opciones"]}" )
    preguntas+=( ["$i, respuesta"]="${todasPreguntas["$i, respuesta"]}" )
    i=$((i + 1))
done

# Tenemos todas las preguntas para imprimir ya 😎


