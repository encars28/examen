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

if [[ $# -eq 0 ]]
then
    echo 'Por favor introduce un argumento'
    usage
    exit 1
fi

# getopts admite solo argumentos de un solo caracter (-h, -f...)
# Por lo tango, cuando metemos algo como -he, te lo interpreta como si metieses -h -e separadamente
# Eso significa que primero se mete en el case de la h, imprime lo que hay ahi y luego se mete en el case del incorrecto
# Eso tambien signica que si ponemos -fe, se tomara e como el argumento que tiene q ir con f obligatoriamente
# https://manpages.org/getopts

# Declaro las variables que se van a utilizar por defecto, salvo que el usuario diga lo contrario
numeroPreguntas=5
preguntasAleatorias=false 
respuestasAleatorias=false 
porcentaje=0

# Es un diccionario con valores de verdadero o falso, que indican si un argumento ha sido usado
# De esta manera, puedo evitar que un mismo parametro se use dos veces
declare -A usado=( [false]="archivo" [false]="numero" [false]="porcentaje" [false]="alpreguntas" [false]="alrespuestas")


# como getopts solo me lee valores de un solo caracter, voy a converitri -rr en -x
params=("$@")
declare -a newparams
for i in "${params[@]}"; do
    if [[ "$i" =~ ^-.*x ]]  
# el if coge cada parametro de los argumentos y comprueba que empieze por - y no tenga x
    then
        echo "Error: opcion -x no valida"
        usage
        exit 1
    fi

    if [[ "$i" == "-rr" ]]
    then 
        newparams+=( "-x" )
    else
        newparams+=( "$i" )
    fi
done

set -- "${newparams[@]}"


while getopts ":hf:n:p:rx" option;  do
    #echo "$OPTIND"
    #echo "$option"
    case $option in        
        h)  
            if [[ $# -eq 1 ]]
            then
                help
                exit 0
            else
                echo "Error: -h va solo"
                usage
                exit 5
            fi
            ;;
        f)  
            if [[ ! ${usado["archivo"]} ]]
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
            else
                echo "Error: -$option usado ya una vez"
                usage
                exit 6
            fi
            ;;
        n)
            if [[ ! ${usado["numero"]} ]]
            then
                if [[ $OPTARG != +([0-9]) && $OPTARG == 0 ]]
                then
                    echo "Error: $OPTARG es un numero negativo o es 0. El numero de preguntas debe de ser 1 o mas"
                    usage
                    exit 4
                fi
    
                numeroPreguntas=$OPTARG
                echo "$numeroPreguntas"
                usado["numero"]=true
            else
                echo "Error: -$option usado ya una vez"
                usage
                exit 6
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
                usado["porcentaje"]=true
            else
                echo "Error: -$option usado ya una vez"
                usage
                exit 6
            fi
            ;;
        r)
            if [[ ! ${usado["alpreguntas"]} ]]
            then
                preguntasAleatorias=true
                echo "Preguntas aleatorias = $preguntasAleatorias"
                usado["alpreguntas"]=true
            else
                echo "Error: -$option usado ya una vez"
                usage
                exit 6
            fi
            ;;
        x)
            if [[ ! ${usado["alrespuestas"]} ]]
            then
                respuestasAleatorias=true
                echo "Respuestas aleatorias = $respuestasAleatorias"
                usado["alrespuestas"]=true
            else
                echo "Error: -rr usado ya una vez"
                usage
                exit 6
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

# https://unix.stackexchange.com/questions/214141/explain-the-shell-command-shift-optind-1
shift "$((OPTIND - 1))" 
p=( "$@" )
count=0
for i in "${p[@]}";do
    if [[ "$i" == "-f" ]]
    then
        p[$((count + 1))]="-"
    fi
    
    if [[ ! ("$i" =~ ^-.*) ]]
    then
        echo "Error: opcion $i no valida"
        usage
        exit 1
    fi

    count=$((count + 1))
done

# el parametro f es obligatorio
if [[ ! (${usado["archivo"]}) ]]
then
    echo "Error: no se ha incluido fichero de preguntas"
    usage
    exit 7
fi

# r puede ser -r o -rr, tengo que procesarlo a mano
# params=("$@")
# readarray paramsAleatorios < <(printf '%s\n' "${params[@]}" | grep "r")
# for i in "${paramsAleatorios[@]}"; do
#     echo "$i"
#     if [[ ! ${usado["alpreguntas"]} && $i == "-r" ]]
#     then
#         preguntasAleatorias=true
#         echo 'Preguntas aleatorias activadas'
#         usado["alpreguntas"]=true
#     fi

#     if [[ ! ${usado["alrespuestas"]} && $i == "-rr" ]]
#     then
#         respuestasAleatorias=true
#         echo 'Respuestas aleatorias activadas'
#         usado["alrespuestas"]=true
#     fi

# done

# HOLA ENCARNA
