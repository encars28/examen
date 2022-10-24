#!/bin/bash

# PROBLEMA: encina no lee las tildes 

# Esta funcion te comprueba si un determinado elemento esta en una lista
# Devuelve true en caso afirmativo y false en caso negativo

# is_contained elemento lista
function esta_contenido () {
    elemento="$1"
    shift
    lista=( "$@" )

    grp=$(printf "%s\n" "${lista[@]}" | grep -w "$elemento")
    if [[ $grp != "$elemento" ]]
    then 
        echo true
    else 
        echo false
    fi
}

function eliminar_retorno_carro () {
    tr -d '\r' < "$1"
}

numeroPreguntas=3
preguntasAleatorias=true
fichero=bancoPreguntas.txt
respuestasAleatorias=false

# declaro los dos diccionarios que voy a usar mas tarde
declare -A todasPreguntas
declare -A preguntas

# le quito el retorno de carro (en caso de que el fichero haya sido escrito en windows)
# para no tener problemas con los saltos de linea
temp=$(eliminar_retorno_carro $fichero)

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

    if [[ $respuestasAleatorias == true ]]
    then
        while true 
        do
            if [[ ${#indicesUsados[@]} -ge 4 ]]
            then
                break
            fi

            indice=$((RANDOM % 4))
            contenido=$(esta_contenido "$indice" "${indicesUsados[@]}")

            # check=$(printf "%s\n" "${indicesUsados[@]}" | grep -w "$indice")
            # if [[ $check != "$indice" ]]

            if [[ $contenido == true ]]
            then
                enunciado=$( echo "${opciones[$indice]}" | cut -f 2- -d ' ' )

                case "${#indicesUsados[@]}" in
                0)
                    opcionesAleatorias[0]="A. $enunciado"
                ;;
                1)
                    opcionesAleatorias[1]="B. $enunciado"
                ;;
                2)
                    opcionesAleatorias[2]="C. $enunciado"
                ;;
                3)
                    opcionesAleatorias[3]="D. $enunciado"
                ;;
                *)
                    echo "Error desconodico"
                    exit
                ;;
                esac

                indicesUsados+=( "$indice" )
            fi

        done

        indicesUsados=()
        opcionesCadena=$( printf '%s\n' "${opcionesAleatorias[@]}")

    else
        opcionesCadena=$( printf '%s\n' "${opciones[@]}")
    fi

    todasPreguntas+=( ["$contador, opciones"]="$opcionesCadena" )
    respuesta=$( echo "${lineas[@]:$((inicio + 5)):1}" | cut -f 2 -d ' ' )
    todasPreguntas+=( ["$contador, respuesta"]=$respuesta )

    contador=$((contador + 1))
    # cada pregunta esta formada por 6 lineas
    inicio=$((inicio + 6))
done

# compruebo que el numero de preguntas no sea mayor al que las que hay en el fichero
preguntasFichero=$contador
if [[ $numeroPreguntas -gt $preguntasFichero ]]
then
    echo "Error: el numero de preguntas introducido es mayor que el numero de preguntas del fichero"
    exit
fi

# Ajustar el numero de preguntas al dado
# TODO: comprobacion aleatorio
if [[ $preguntasAleatorias == false ]]
then
    i=0
    while [[ $i < $numeroPreguntas ]]
    do 
        preguntas+=( ["$i, pregunta"]="${todasPreguntas["$i, pregunta"]}" )
        preguntas+=( ["$i, opciones"]="${todasPreguntas["$i, opciones"]}" )
        preguntas+=( ["$i, respuesta"]="${todasPreguntas["$i, respuesta"]}" )
        i=$((i + 1))
    done
else
    while true 
    do
        if [[ ${#indicesUsados[@]} -ge $numeroPreguntas ]]
        then
            break
        fi

        indice=$((RANDOM % numeroPreguntas))
        contenido=$(esta_contenido "$indice" "${indicesUsados[@]}")

        # check=$(printf "%s\n" "${indicesUsados[@]}" | grep -w "$indice")
        # if [[ $check != "$indice" ]]

        if [[ $contenido == true ]]
        then
            for j in pregunta opciones respuesta
            do
                preguntas+=( ["${#indicesUsados[@]}, $j"]="${todasPreguntas["$indice, $j"]}" )
            done

            # preguntas+=( ["${#indicesUsados[@]}, pregunta"]="${todasPreguntas["$indice, pregunta"]}" )
            # preguntas+=( ["${#indicesUsados[@]}, opciones"]="${todasPreguntas["$indice, opciones"]}" )
            # preguntas+=( ["${#indicesUsados[@]}, respuesta"]="${todasPreguntas["$indice, respuesta"]}" )
            indicesUsados+=( "$indice" )
        fi

    done
fi

# Tenemos todas las preguntas para imprimir ya 😎
declare -p preguntas
