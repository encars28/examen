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
    echo '4 si el parámetro no es un número positivo'
    echo '5 si se ha utilizado el argumento de ayuda con otros'
    echo '6 si se ha repetido el mismo argumento 2 veces'
    echo '7 si no se ha pasado archivo de preguntas'
    echo '8 si el fichero no existe'
}


# Lo primero que hago es comprobar que nos pasan al menos un argumento
# En caso contrario, devuelve error
if [[ $# -eq 0 ]]
then
    echo 'Por favor introduce un argumento'
    usage
    exit 1
fi

# Por defecto, el numero de preguntas es 5, las pregutnas no restasn (por lo que no hay porcentaje)
# y las respuestas y las preguntas aleatorias estan desactivadas
numeroPreguntas=5
preguntasAleatorias=false 
respuestasAleatorias=false 
porcentaje=0

# Declaro un diccionario que me indica si el argumento ha sido introducido 
# False: no ha sido introducido ninguna vez
# True: ha sido introducido
declare -A usado=( ["-f"]=false ["-n"]=false ["-p"]=false ["-r"]=false ["-rr"]=false)

# Despues, compruebo que todos los argumentos que me pasan son validos

# Meto todos los argumnentos en una lista, de manera el espacio en blanco sirva para 
# diferenciar un elemento de otro
params=( "$@" )
# Hago un buche for para recorrer la lista
for argumento in "${params[@]}"
do
   case "${argumento}" in
    -h)
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
        if [[ ! ${usado["archivo"]} ]]
        then
            if [[  ]]
            then
                if [[ ! ($OPTARG =~ .+\.txt$) ]]
                then
                    echo "Error: $OPTARG no es un archivo .txt"
                    usage
                    exit 3
                fi

                ficheroPreguntas=$OPTARG
                echo "$ficheroPreguntas"
                usado["archivo"]=true
            fi
        else
            echo "Error: $argumento usado ya una vez"
            usage
            exit 6
        fi
    ;;
    -n)
        echo "n"
    ;;
    -p)
        echo "p"
    ;;
    -r)
        echo "r"
    ;;
    -rr)
        echo "rr"
    ;;
    *)
        echo "Error: argumento $argumento no valido"
        usage
        exit 1
        ;;
   esac

done