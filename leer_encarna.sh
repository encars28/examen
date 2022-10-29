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
nota=0  # En esta variables se va a ir calculando la nota pregunta a pregunta
porcentaje=25

for ((i=0; i<numeroPreguntas; i++)); do

  #Primero pongo por pantalla el numero de pregunta, su enunciado y sus opciones
  echo "pregunta $((i + 1))"
  
  for j in pregunta opciones ; do
  
    echo "${preguntas[$i, $j]}"
    
  done
  
  # Después pedimos al usuario que introduzca la respuesta, que guardaremos en temporal para añadirla a el diccionario de Preguntas
  # En el momento en el que guardamos la respuesta, usamos ^^ para convertir las letras a mayusculas
  read -p "Respuesta: " temporal
  preguntas+=( [$i, respuestaUsuario]=${temporal^^} )
  
  #Ahora compruebo si la respuesta esta fuera de rango con expresiones regulares
  #[^ABCD] comprueba que la respuesta no sea A, B, C o D, [""] comprueba que la respuesta no este vacia y
  #[ABCD]{2,} comprueba que la respuesta tenga 2 caracteres o mas.
  
  while [[ ${preguntas[$i, respuestaUsuario]} =~ [^ABCD] || ${preguntas[$i, respuestaUsuario]} == "" || ${preguntas[$i, respuestaUsuario]} =~ [ABCD]{2,} ]]; do

    echo "Respuesta fuera de rango. Elige una opcion en rango (A, B, C, D)"
    read -p "Respuesta: " temporal
    preguntas[$i, respuestaUsuario]=${temporal^^} 
    
  done
  
  # Compruebo si la respuesta es Correcta o Incorrecta
  if [[ ${preguntas[$i, respuestaUsuario]} == ${preguntas[$i, respuesta]} ]]; then
  
  
  # Ahora calculo la nota correspondiente al valor de la pregunta. Bash no permite realizar operaciones con decimales,
  # por tanto tenemos que utilizar Bash Calculator para realizar dichas operaciones. bc <<< le dice al programa que 
  #use Bash calculator para realizar la operacion y scale=2 indica la cantidad de decimales a mostrar
     nota=$(bc <<< "scale=2; $nota + 1")
     
     preguntas+=( [$i, correcto]="PREGUNTA ACERTADA" )
    
  else  
  
  # En caso de que las preguntas falladas no resten, el porcentaje es 0 por tanto 0/100 es 0  
    nota=$(bc <<< "scale=2; $nota - 1*$porcentaje/100")
    preguntas+=( [$i, correcto]="PREGUNTA FALLADA" )
  fi 
  
  echo
  
# Compruebo si la nota es negativa con expresiones regulares. 
# - comprueba que haya un - en la cadena, [0-9]* comprueba que haya 0 o mas caracteres entre 0 y 9
# ([.][0-9]+)? comprueba que haya o 0 o 1 grupo de caracteres formado por un punto y 1 o mas caracteres entre 0 y 9
done


if  [[ "$nota" =~ -[0-9]*([.][0-9]+)? ]]; then
  
  nota=0
fi

# Cuando la nota esta entre 0 y 1, en la variable no se almacena el 0 que precede a los decimales.
# en caso de que nota empieze con un grupo de caracteres formado por un punto y 1 o mas caracteres entre 0 y 9
# le añadimos un 0 antes del punto.
if [[ "$nota" =~ ^([.][0-9]+)$ ]]; then

  nota=0$nota
  
fi  
echo "Nota final:  $nota/ $numeroPreguntas"


# CREACION DEL FICHERO DE REVISIÓN

# Para crear y rellenar el fichero de texto, redirijo la salida de echo a un fichero llamado revision.txt
# > indica a la orden echo que cree un fichero con ese nombre y si ya existia, que sobreescriba todo lo que hay
# por la informacion pasada. Usar >> le dice a echo que cree el fichero y si ya existia que añada la informacion
# al final del fichero

echo " -----Revision del examen----- " > revision.txt
echo "" >> revision.txt

# Con este bucle for presento en el fichero todo el diccionario de preguntas
for ((i=0;i<numeroPreguntas;i++)); do
  
  echo "pregunta $((i + 1))" >> revision.txt
  for j in pregunta opciones; do
    
    echo "${preguntas[$i, $j]}" >> revision.txt
    
  done
  
  echo "Respuesta proporcionada por el alumno:  ${preguntas[$i, respuestaUsuario]}" >> revision.txt
  echo "Respuesta correcta: ${preguntas[$i, respuesta]}" >> revision.txt
  echo "${preguntas[$i, correcto]}" >> revision.txt
  echo "" >> revision.txt
done

echo "Nota Final: $nota / $numeroPreguntas" >> revision.txt


