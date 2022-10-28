#!/bin/bash

function usage () {
    echo 'Uso: ./examen.sh -f bancoPreguntas.txt [-n numeroPreguntas][-p porcentajeError][-r preguntasAleatorias][-rr respuestasAleatorias]'
    echo 'Pista: ./examen.sh -h'
}

function help () {
    echo 'Uso: ./examen.sh -f bancoPreguntas.txt [-n numeroPreguntas][-p porcentajeError][-r preguntasAleatorias][-rr respuestasAleatorias]'
    echo
    echo 'Permite realizar en el terminal un examen tipo test, cuyas preguntas están en un archivo .txt especificado con -f. Al finalizar la realización del examen se calcula la nota final.'
    echo 'Además de mostrar la nota por pantalla, se creará un fichero de texto (revision.txt) con la revisión del examen. En el se incluirán las preguntas con su solución correcta, la solución proporcionada por el alumno y se mostrará si esta respuesta es correcta o incorrecta'
    echo 
    echo 'Lista de argumentos'
    echo '-f        Indica el fichero donde están incluidas las preguntas entre las cuales se seleccionara para hacer el examen. OBLIGATORIO'
    echo '-h        Ayuda de uso del programa'
    echo '-n        Indica el número de preguntas del examen. Si no se especifíca por defecto se incluyen 5 preguntas'
    echo '-p        Indica el porcentaje, sobre la puntuación total de la pregunta, que penalizar una pregunta incorrecta. Si no se indica las preguntas incorrectas no penalizan'
    echo '-r        Las preguntas se muestran de forma aleatoria'
    echo '-rr       Ordena de forma aleatoria las respuestas'
    echo 
    echo 'Estado de salida:'
    echo '0 si todo va bien'
    echo '1 si el argumento pasado no es válido'
    echo '2 si el argumento requiere obligatoriamente un parámetro y no se ha incluido'
    echo '3 si el archivo de preguntas no es de tipo .txt'
    echo '4 si el parámetro no es un número mayor que 0'
    echo '5 si se ha utilizado el argumento de ayuda con otros'
    echo '6 si se ha repetido el mismo argumento 2 veces'
    echo '7 si no se ha pasado archivo de preguntas'
    echo '8 si el fichero no existe'
}

function numero_mayor_0 () {
    if [[ "$1" != +([0-9]) || "$1" =~ ^[^1-9] ]]
    then
        echo false
    else
        echo true
    fi
}

# Esta funcion te comprueba si un determinado elemento esta en una lista
# Devuelve true en caso afirmativo y false en caso negativo

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

# Lo primero que hacemos es comprobar que hay al menos un argumento
# En caso contrario, devuelve error
if [[ $# -eq 0 ]]
then
    echo 'Por favor introduce un argumento'
    usage
    exit 1
fi

# Por defecto, el numero de preguntas es 5, las preguntas no restasn (por lo que porcentaje=0)
# y las respuestas y las preguntas aleatorias estan desactivadas
numeroPreguntas=5
preguntasAleatorias=false
respuestasAleatorias=false
porcentaje=0

# Declaro un diccionario que me indica si el argumento ha sido introducido 
# False: no ha sido introducido ninguna vez
# True: ha sido introducido
declare -A usado=( ["-f"]=false ["-n"]=false ["-p"]=false ["-r"]=false ["-rr"]=false)

# Esta variable se pone a true con parametros como -p -n -f, para indicar que el siguiente elemento
# de la lista no tiene q entrar en el switch (ya que es un parametro que ya ha sido analizado) 
parametro=false

# Ahora, compruebo que todos los argumentos que me pasan son validos

# Meto todos los argumnentos en una lista, de manera el espacio en blanco sirva para 
# diferenciar un elemento de otro
params=( "$@" )
# Hago un bucle for para recorrer la lista
for i in "${!params[@]}"
do
    # nos saltamos el parametro
    if [[ $parametro == true ]]
    then
        parametro=false
        continue
    fi

   case "${params[$i]}" in
    -h)
        # Comprobamos que no se han pasado mas argumentos con -h
        # En caso contrario devolvemos un error
        if [[ $# -eq 1 ]]
        then
            help
            exit 0
        else
            echo "Error: Uso incorrecto de -h"
            usage
            exit 5
        fi
    ;;
    -f)
        # Primero comprobamos que el parametro -f no haya sido introducido ya
        # Despues comprobamos que el siguiente elemento de la lista sea el fichero
        # con las preguntas. En caso afirmativo activamos parametro y en caso negativo
        # devolvemos error
        if [[ ${usado["-f"]} == false ]]
        then
            # Para comprobar que es un fichero de texto usamos reegular expresions
            # .+\.txt$ significa una cadena de texto con cualquier caracter, una o mas veces, que termine en .txt
            if [[ "${params[$((i + 1))]}" =~ .+\.txt$ ]]
            then
                # Una vez que hemos comprobado que existe el parametro, comprobamos que existe la ruta que nos
                # han pasado del fichero de texto y que este fichero tenga permisos de lectura
                ficheroPreguntas=${params[$((i + 1))]}
                if ! test -r "$ficheroPreguntas"
                then
                    echo "Error: el fichero no existe"
                    exit 8
                fi
                usado["-f"]=true
                parametro=true
            else
                echo "Error: ${params[$i]} requiere un parámetro de tipo .txt"
                usage
                exit 2
            fi
        else
            echo "Error: ${params[$i]} usado ya una vez"
            usage
            exit 6
        fi
    ;;
    -n)
        # Al igual que antes, comprobamos que -n no haya sido usada mas veces, y que despues de ella exista 
        # un parametro que indique el numero de pregutnas
        if [[ ${usado["-n"]} == false ]]
        then
            # Aqui usamos tambien regular expresions para asegurarnos de que el parametro sea un mayor que 0
            # +([0-9]) signifiva cualquier combinaciond de numeros del 0 al 9, y ^[^1-9] significa cualqier cadena que empiece 
            # por un caracter distinto del 1 o del 9 (de esta manera eliminamos posibles 0s)
            valido=$(numero_mayor_0 "${params[$((i + 1))]}")
            if [[ $valido == false ]]
            then
                echo "Error: ${params[$i]} requiere de un parametro que sea un numero mayor o igual a 1"
                usage
                exit 4
            fi

            numeroPreguntas="${params[$((i + 1))]}"
            usado["-n"]=true
            parametro=true
        else
            echo "Error: ${params[$i]} usado ya una vez"
            usage
            exit 6
        fi
    ;;
    -p)
        # Hacemos exactamente las mismas comprobaciones que para -n, nada mas que ahora hay que comprobar que el porcentaje
        # que nos pasen no sea mayor que 100
        if [[ ${usado["-p"]} == false ]]
        then
            valido=$(numero_mayor_0 "${params[$((i + 1))]}")
            if [[ $valido == false || "${params[$((i + 1))]}" -gt 100 ]]
            then
                echo "Error: ${params[$i]} requiere de un parametro que sea un numero mayor o igual a 1"
                usage
                exit 4
            fi
            porcentaje="${params[$((i + 1))]}"
            usado["-p"]=true
            parametro=true
        else
            echo "Error: ${params[$i]} usado ya una vez"
            usage
            exit 6
        fi
    ;;
    -r)
        # Aqui solo comprobamos que -r no haya sido usado anteriormente
        if [[ ${usado["-r"]} == false ]]
        then
            preguntasAleatorias=true
            usado["-r"]=true
        else
            echo "Error: ${params[$i]} usado ya una vez"
            usage
            exit 6
        fi
    ;;
    -rr)
        # Al igual que antes, comprobamos que no haya sido usado anteriormente
        if [[ ${usado["-rr"]} == false ]]
        then
            respuestasAleatorias=true
            usado["-rr"]=true
        else
            echo "Error: -rr usado ya una vez"
            usage
            exit 6
        fi
    ;;
    *)
        # Respuesta por defecto
        echo "Error: argumento ${params[$i]} no valido"
        usage
        exit 1
        ;;
   esac

done

# Comprobamos que se incluya un fichero de preguntas
if [[ ${usado["-f"]} == false ]]
then
    echo "Error: no se ha incluido fichero de preguntas"
    usage
    exit 7
fi

# PROBLEMA: encina no lee las tildes 

# declaro los dos diccionarios que voy a usar mas tarde
declare -A todasPreguntas
declare -A preguntas

# le quito el retorno de carro (en caso de que el fichero haya sido escrito en windows)
# para no tener problemas con los saltos de linea
temp=$(eliminar_retorno_carro "$ficheroPreguntas")

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
    read -r -a indices < <(indicesAleatorios "$numeroPreguntas")
    for ((i=0; i<numeroPreguntas; i++))
    do
        for j in pregunta opciones respuesta
        do
            preguntas+=( ["$i, $j"]="${todasPreguntas["${indices[$i]}, $j"]}" )
        done
    done 
fi

# Tenemos todas las preguntas para imprimir ya 😎
declare -p preguntas
