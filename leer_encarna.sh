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
    if [[ $grp == "$elemento" ]]
    then 
        echo true
    else 
        echo false
    fi
}

function eliminar_retorno_carro () {
    tr -d '\r' < "$1"
}

# convertir ascii en caracter
function char () {
    echo "$1" | awk '{printf("%c",$1)}'
}

function indicesAleatorios () {
    numeroOpciones=$1
    while true
    do 
        longitud=${#indicesUsados[@]}
        # condicion de salida del bucle
        if [[ $longitud -ge $numeroOpciones ]]
        then
            break
        fi

        indice=$((RANDOM % numeroOpciones))
        contenido=$(esta_contenido "$indice" "${indicesUsados[@]}")

        if [[ $contenido == false ]]
        then 
            indicesUsados+=( "$indice" )
        fi
    done

    # devuelvo el array con los indices aleatorios
    echo "${indicesUsados[@]}"
}

numeroPreguntas=3
preguntasAleatorias=false
fichero=bancoPreguntas.txt
respuestasAleatorias=false

# declaro los dos diccionarios que voy a usar mas tarde
declare -A todasPreguntas
declare -A preguntas

# le quito el retorno de carro (en caso de que el fichero haya sido escrito en windows)
# para no tener problemas con los saltos de linea
temp=$(eliminar_retorno_carro $fichero)

# Leemos el fichero linea a linea, eliminando los \n
readarray -t lineas < <(echo "$temp")

# Uno todas las lineas en preguntas, creando un arrray de preguntas
inicio=0
contador=0

while [[ $inicio -lt ${#lineas[@]} ]]
do
    todasPreguntas+=( ["$contador, pregunta"]="${lineas[@]:$inicio:1}" )

    opciones=( "${lineas[@]:$((inicio + 1)):4}" )
    printf -v opcionesCadena '%s\n' "${opciones[@]}"

    if [[ $respuestasAleatorias == true ]]
    then
        read -r -a indices < <(indicesAleatorios 4)
        for (( i=0; i<4; i++))
        do
            enunciado=$( echo "${opciones[${indices[$i]}]}" | cut -f 2- -d ' ' ) 
            letra=$(char $((i + 65)))
            opcionesAleatorias[$i]="$letra. $enunciado"
        done

        printf -v opcionesCadena '%s\n' "${opcionesAleatorias[@]}"  
    fi

    todasPreguntas+=( ["$contador, opciones"]="$opcionesCadena" )

    respuesta=$( echo "${lineas[@]:$((inicio + 5)):1}" | cut -f 2 -d ' ' )
    todasPreguntas+=( ["$contador, respuesta"]=$respuesta )


    contador=$((contador + 1))
    # cada pregunta esta formada por 6 lineas + 1 salto de linea
    inicio=$((inicio + 7))
done

# compruebo que el numero de preguntas no sea mayor al que las que hay en el fichero
preguntasFichero=$contador
if [[ $numeroPreguntas -gt $preguntasFichero ]]
then
    echo "Error: el numero de preguntas introducido es mayor que el numero de preguntas del fichero"
    exit
fi

# Ajustar el numero de preguntas al dado
if [[ $preguntasAleatorias == false ]]
then
    for ((i=0; i<numeroPreguntas; i++))
    do 
        for j in pregunta opciones respuesta
        do
            preguntas+=( ["$i, $j"]="${todasPreguntas["$i, $j"]}" )
        done
    done
else
    read -r -a indices < <(indicesAleatorios $numeroPreguntas)
    for ((i=0; i<numeroPreguntas; i++))
    do
        for j in pregunta opciones respuesta
        do
            preguntas+=( ["$i, $j"]="${todasPreguntas["${indices[$i]}, $j"]}" )
        done
    done 
fi

# Tenemos todas las preguntas para imprimir ya
# Pongo por pantalla pregunta a pregunta con las opciones y pido la respuesta al usuario
nota=0
porcentaje=25

for ((i=0; i<numeroPreguntas; i++)); do

  echo "pregunta $((i + 1))"
  
  for j in pregunta opciones ; do
  
    echo "${preguntas[$i, $j]}"
    
  done
  
  read -p "Respuesta: " temporal
  preguntas+=( [$i, respuestaUsuario]=${temporal^^} )

  while [[ ${preguntas[$i, respuestaUsuario]} =~ [^ABCD] ]]; do

    echo "Respuesta fuera de rango. Elige una opcion en rango (A, B, C, D)"
    read -p "Respuesta: " temporal
    preguntas[$i, respuestaUsuario]=${temporal^^} 
    
  done
  
  if [[ ${preguntas[$i, respuestaUsuario]} == ${preguntas[$i, respuesta]} ]]; then
  
# con bc le estoy diciendo al programa que use el bash calculator, y con el Scale la precision de decimales
     nota=$(bc <<< "scale=2; $nota + 1")
     preguntas+=( [$i, correcto]="RESPUESTA CORRECTA" )
    
  else  
    
    nota=$(bc <<< "scale=2; $nota - $porcentaje/100")
    preguntas+=( [$i, correcto]="RESPUESTA INCORRECTA" )
  fi 
  
  echo
done

echo "Nota final: $nota / $numeroPreguntas"
