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
}

# getopts admite solo argumentos de un solo caracter (-h, -f...)
# Por lo tango, cuando metemos algo como -he, te lo interpreta como si metieses -h -e separadamente
# Eso significa que primero se mete en el case de la h, imprime lo que hay ahi y luego se mete en el case del incorrecto
# Eso tambien signica que si ponemos -fe, se tomara e como el argumento que tiene q ir con f obligatoriamente
# https://manpages.org/getopts

# Declaro las variables que se van a utilizar por defecto, salvo que el usuario diga lo contrario
numeroPreguntas=5
preguntasAleatorias=1 # False
respuestasAleatorias=1 # False

# Es un diccionario con valores de verdadero o falso, que indican si un argumento ha sido usado
# De esta manera, puedo evitar que un mismo parametro se use dos veces
declare -A usado=( [1]="archivo" [1]="numero" [1]="porcentaje" [1]="alpreguntas" [1]="alrespuestas")

while getopts ":hf:n:p:r" option;  do
    case $option in
        h)  
            if [[ $# -eq 1 ]]
            then
                help
                exit 0
            else
                echo "Error"
                usage
                exti 5
            fi
            ;;
        f)  
            if [[ ! ${usado["archivo"]} ]]
            then
                if [[ $OPTARG != *.txt ]]
                then
                    echo "Error: $OPTARG no es un archivo .txt"
                    usage
                    exit 3
                fi

                ficheroPreguntas=$OPTARG
                echo "$ficheroPreguntas"
                usado["archivo"]=0
            fi
            ;;
        n)
            if [[ ! ${usado["numero"]} ]]
            then
                if [[ $OPTARG != +([0-9]) ]]
                then
                    echo "Error: $OPTARG no es un numero positivo"
                    usage
                    exit 4
                fi
    
                numeroPreguntas=$OPTARG
                echo "$numeroPreguntas"
                usado["numero"]=0
            fi
            ;;
        p)
            if [[ ! ${usado["porcentaje"]} ]]
            then
                if [[ $OPTARG != +([0-9]) ]]
                then
                    echo "Error: $OPTARG no es un numero positivo"
                    usage
                    exit 4
                fi

                porcentaje=$OPTARG
                echo "$porcentaje"
                usado["porcentaje"]=0
            fi
            ;;
        r)
            if [[ ! ${usado["alpreguntas"]} && ($OPTIND -ne $(($OPTIND - 1))) ]]
            then
                preguntasAleatorias=0 # 0 es true en bash
                echo 'Preguntas aleatorias activadas'
                usado["alpreguntas"]=0
            elif [[ ! ${usado["alrespuestas"]} && ($OPTIND -eq $(($OPTIND - 1))) ]]
            then
                respuestasAleatorias=0
                echo 'Respuestas aleatorias activadas'
                usado["alrespuestas"]=0
            fi
            ;;
        :)
            echo "Error: -$OPTARG requiere un parámetro"
            usage
            exit 2
            ;;
        ?) # Opcion por defecto
            echo "Error: opcion -$OPTARG no valida"
            usage
            exit 1
            ;;
    esac
done
