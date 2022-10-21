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
preguntasAleatorias=1 
respuestasAleatorias=1 
porcentaje=0

# Declaro un diccionario que me indica si el argumento ha sido introducido 
# False: no ha sido introducido ninguna vez
# True: ha sido introducido
declare -A usado=( ["-f"]=false ["-n"]=false ["-p"]=false ["-r"]=false ["-rr"]=false)
parametro=false

# Despues, compruebo que todos los argumentos que me pasan son validos

# Meto todos los argumnentos en una lista, de manera el espacio en blanco sirva para 
# diferenciar un elemento de otro
params=( "$@" )
# Hago un buche for para recorrer la lista
for i in "${!params[@]}"
do
    if [[ $parametro == true ]]
    then
        parametro=false
        continue
    fi

   case "${params[$i]}" in
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
        if [[ ${usado["-f"]} == false ]]
        then
            if [[ "${params[$((i + 1))]}" =~ .+\.txt$ ]]
            then
                ficheroPreguntas=${params[$((i + 1))]}
                if ! test -r "$ficheroPreguntas"
                then
                     echo "Error: el fichero no existe"
                    exit 8
                fi
                echo "$ficheroPreguntas"
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
        if [[ ${usado["-n"]} == false ]]
        then
            if [[ "${params[$((i + 1))]}" != +([0-9]) || "${params[$((i + 1))]}" =~ [^1-9] ]]
            then
                echo "Error: ${params[$i]} requiere de un parametro que sea un numero mayor o igual a 1"
                usage
                exit 4
            fi

            numeroPreguntas="${params[$((i + 1))]}"
            echo "$numeroPreguntas"
            usado["-n"]=true
            parametro=true
        else
            echo "Error: ${params[$i]} usado ya una vez"
            usage
            exit 6
        fi
    ;;
    -p)
        if [[ ${usado["-p"]} == false ]]
        then
            if [[ "${params[$((i + 1))]}" != +([0-9]) || "${params[$((i + 1))]}" =~ [^1-9] ]]
            then
                echo "Error: ${params[$i]} requiere de un parametro que sea un numero mayor o igual a 1"
                usage
                exit 4
            fi
            porcentaje="${params[$((i + 1))]}"
            echo "$porcentaje"
            usado["-p"]=true
            parametro=true
        else
            echo "Error: ${params[$i]} usado ya una vez"
            usage
            exit 6
        fi
    ;;
    -r)
        if [[ ${usado["-r"]} == false ]]
        then
            preguntasAleatorias=true
            echo "Preguntas aleatorias = $preguntasAleatorias"
            usado["-r"]=true
        else
            echo "Error: ${params[$i]} usado ya una vez"
            usage
            exit 6
        fi
    ;;
    -rr)
        if [[ ${usado["-rr"]} == false ]]
        then
            respuestasAleatorias=true
            echo "Respuestas aleatorias = $respuestasAleatorias"
            usado["-rr"]=true
        else
            echo "Error: -rr usado ya una vez"
            usage
            exit 6
        fi
    ;;
    *)
        echo "Error: argumento ${params[$i]} no valido"
        usage
        exit 1
        ;;
   esac

done

# si no se ha incluido un fichero de texto, damos error
if [[ ${usado["-f"]} == false ]]
then
    echo "Error: no se ha incluido fichero de preguntas"
    usage
    exit 7
fi