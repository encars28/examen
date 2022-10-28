#!/bin/bash

#
# PRIMERA PRÁCTICA EVALUABLE
# Grupo de prácticas PB1
#
# María Encarnación Sánchez Sánchez - 71062694P
# Alejnadro Martín Martín           - 70832662E
#

#
# ========= FUNCIONES =========
#

###################################################################################
# Imprime un mensaje que recuerda el uso del programa y sus argumentos
# Uso: uso

# ARGUMENTOS
    # Ninguno
###################################################################################
function uso () {
    echo 'Uso: ./examen.sh -f bancoPreguntas.txt [-n numeroPreguntas][-p porcentajeError][-r preguntasAleatorias][-rr respuestasAleatorias]'
    echo 'Pista: ./examen.sh -h'
}

###################################################################################
# Imprime un mensaje que especifíca un funcionamiento más detallado del programa
# Uso: help

# ARGUMENTOS
    # Ninguno
###################################################################################
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

############################################################################
# Indica si una variable es un número entero (int) mayor que 0
# Uso: numero_mayor_0 variable

# ARGUMENTOS
    # Variable a comprobar

# RETURN 
    # True si es un número entero mayor que 0
    # False en caso contrario
############################################################################
function numero_mayor_0 () {
    # Usamos expresiones regulares
    # +([0-9]) signifiva cualquier combinaciond de numeros del 0 al 9, y ^[^1-9] significa cualqier cadena que empiece 
    # por un caracter distinto del 1 o del 9 (de esta manera eliminamos posibles 0s)
    if [[ "$1" != +([0-9]) || "$1" =~ ^[^1-9] ]]
    then
        echo false
    else
        echo true
    fi
}

############################################################################
# Indica si una variable esta contenida dentro de una lista
# Uso: esta_contenido variable ${lista[@]}

# ARGUMENTOS
    # 1: Variable a comprobar
    # 2: Lista (de forma como indicado en uso)

# RETURN 
    # True si la variable esta contenida en la lista
    # False en caso contrario
############################################################################
function esta_contenido () {
    # Capturo el elemento a comprobar
    elemento="$1"
    shift
    # Capturo la lista
    lista=( "$@" )

    # Aplico un filtrado con grep del elemento sobre la lista y lo almaceno en grp
    grp=$(printf "%s\n" "${lista[@]}" | grep -w "$elemento")

    # Si el elemento está contenido el filtrado habrá dado como resultado el mismo elemento
    # En caso contrario habrá devuelto una cadena vacía
    if [[ $grp == "$elemento" ]]
    then 
        echo true
    else 
        echo false
    fi
}

############################################################################
# Elimina los retornos de carro ('\r') de un fichero dado
# Uso: eliminar_retorno_carro fichero

# ARGUMENTOS
    # Fichero
############################################################################
function eliminar_retorno_carro () {
    # tr con la opción -d nos permite eliminar un caracter determinado de un fichero
    tr -d '\r' < "$1"
}

############################################################################
# Pasa de codigo ascii a caracter
# Uso: char codigo

# ARGUMENTOS
    # Codigo ascii en decimal

# RETURN 
    # Caracter asociado al codigo ascii
############################################################################
function char () {
    # la función awk te permite seleccionar distintas partes de un fichero o un texto
    # y realizar sobre ellas distintas operaciones
    echo "$1" | awk '{printf("%c",$1)}'

    # En este caso awk implementa una función printf muy parecida a la de c, 
    # que a diferencia de la función printf de bash nos permite imprimir como 
    # caracter una variable que en principio es un número
}

############################################################################
# Genera un vector de una longitud dada (por la variable limite) de numeros aleatorios,
# que irán desde 0 hasta el limite (no inclusive) -> [0, limite)
# Uso: indicesAleatorios longitud

# ARGUMENTOS
    # limite 

# RETURN 
    # Vector con numeros aleatorios (de la forma ${lista[@]})
############################################################################
function indicesAleatorios () {
    # Capturo el limite
    numeroOpciones=$1
    # do-while
    while true
    do 
        longitud=${#indicesUsados[@]}
        # condicion de salida del bucle
        if [[ $longitud -ge $numeroOpciones ]]
        then
            break
        fi

        # Genero el número aleatorio con la vairable random
        # Al aplicar la operación módulo nos aseguramos de que el número aleatorio
        # va a ser siempre menor que el limite que hemos proporcionado
        indice=$((RANDOM % numeroOpciones))

        # contenido será true o false, dependiendo de si indice está en indicesUsados
        contenido=$(esta_contenido "$indice" "${indicesUsados[@]}")

        # Si no lo está lo añadimos. En caso contrario continuamos con otra iteración del bucle
        if [[ $contenido == false ]]
        then 
            indicesUsados+=( "$indice" )
        fi

    done

    # devuelvo el vector con los números aleatorios
    echo "${indicesUsados[@]}"
}

#
# ========= PROGRAMA =========
#

# COMPROBACIÓN Y VALIDACIÓN DE ARGUMENTOS

# Comprobamos que hay al menos un argumento. En caso contrario, devolvemos error
if [[ $# -eq 0 ]]
then
    echo 'Por favor introduce un argumento'
    uso
    exit 1
fi

# Declaramos los valores por defecto: 
numeroPreguntas=5               # Examen de 5 preguntas
preguntasAleatorias=false       # Sin preguntas aleatorias
respuestasAleatorias=false      # Sin respuestas aleatorias
porcentaje=0                    # Sin que las preguntas restes

# Declaramos un diccionario que me indica para cada argumento si el usuario
# lo ha introducido al menos una vez. De esta manera podemos comprobar que no haya
# ningún argumento repetido
declare -A usado=( ["-f"]=false ["-n"]=false ["-p"]=false ["-r"]=false ["-rr"]=false)

# Esta variable se pone a true con argumentos como -p -n -f, para indicar que el siguiente elemento
# de la lista de argumentos no tiene q entrar en el switch. 
# Esto se debe a que este elemento es un parametro que ya ha sido analizado, ya que acompaña a uno
# de estos argumentos que acabamos de mencionar.
parametro=false

# Ahora, compruebo que todos los argumentos que me pasan son validos

# Capturo todos los elementos en una lista, de manera el espacio en blanco sirva para 
# diferenciar un elemento de otro
params=( "$@" )

# Hago un bucle for para recorrer la lista de argumentos, de manera que 
# la variable i irá adoptando los valores de los índices de params.
# Es decir, i irá desde 0 hasta longtidud(params) - 1
for i in "${!params[@]}"
do
    # nos saltamos el parametro y pasamos a otra iteración del bucle
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
            uso
            exit 5
        fi
    ;;
    -f)
        # Primero comprobamos que el parametro -f no haya sido introducido ya
        # Despues comprobamos que el siguiente elemento de la lista sea un fichero
        # con las preguntas y que tenga permisos de lectura
        # En caso afirmativo activamos parametro y en caso negativo devolvemos error
        if [[ ${usado["-f"]} == false ]]
        then
            # Para comprobar que es un fichero de texto usamos expresiones regulares
            # .+\.txt$ significa una cadena de texto con cualquier caracter, una o mas veces, que termine en .txt
            if [[ "${params[$((i + 1))]}" =~ .+\.txt$ ]]
            then

                # Comprobamos que la ruta que nos han pasado del fichero existe, y que tiene permisos de lectura
                ficheroPreguntas=${params[$((i + 1))]}
                if ! test -r "$ficheroPreguntas"
                then
                    echo "Error: el fichero no existe"
                    exit 8
                fi

                usado["-f"]=true        # Indicamos que ya han introducido un parámetro -f
                parametro=true          # Indicamos que el siguiente elemento en la lista es un parámetro que hay que saltarse
            else
                echo "Error: ${params[$i]} requiere un parámetro de tipo .txt"
                uso
                exit 2
            fi
        else
            echo "Error: ${params[$i]} usado ya una vez"
            uso
            exit 6
        fi
    ;;
    -n)
        # Al igual que antes, comprobamos que -n no haya sido usada mas veces, y que después de ella exista 
        # un parámetro que indique el numero de preguntas
        if [[ ${usado["-n"]} == false ]]
        then

            valido=$(numero_mayor_0 "${params[$((i + 1))]}")
            if [[ $valido == false ]]
            then
                echo "Error: ${params[$i]} requiere de un parametro que sea un numero mayor o igual a 1"
                uso
                exit 4
            fi

            numeroPreguntas="${params[$((i + 1))]}"         
            usado["-n"]=true                            # Indicamos que ya han introducido un parámetro -n
            parametro=true                              # Indicamos que el siguiente elemento en la lista es un parámetro que hay que saltarse
        else
            echo "Error: ${params[$i]} usado ya una vez"
            uso
            exit 6
        fi
    ;;
    -p)
        # Hacemos exactamente las mismas comprobaciones que para -n, añadiendo que el porcentaje tenga que ser menor que 100
        if [[ ${usado["-p"]} == false ]]
        then
            valido=$(numero_mayor_0 "${params[$((i + 1))]}")
            if [[ $valido == false || "${params[$((i + 1))]}" -gt 100 ]]
            then
                echo "Error: ${params[$i]} requiere de un parametro que sea un numero mayor o igual a 1"
                uso
                exit 4
            fi
            porcentaje="${params[$((i + 1))]}"
            usado["-p"]=true                        # Indicamos que ya han introducido un parámetro -p
            parametro=true                          # Indicamos que el siguiente elemento en la lista es un parámetro que hay que saltarse
        else
            echo "Error: ${params[$i]} usado ya una vez"
            uso
            exit 6
        fi
    ;;
    -r)
        # Aqui solo comprobamos que -r no haya sido usado anteriormente, ya que no tiene parámetros
        if [[ ${usado["-r"]} == false ]]
        then
            preguntasAleatorias=true
            usado["-r"]=true
        else
            echo "Error: ${params[$i]} usado ya una vez"
            uso
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
            uso
            exit 6
        fi
    ;;
    *)
        # Respuesta por defecto
        echo "Error: argumento ${params[$i]} no valido"
        uso
        exit 1
        ;;
   esac

done

# Comprobamos que se incluya un fichero de preguntas
if [[ ${usado["-f"]} == false ]]
then
    echo "Error: no se ha incluido fichero de preguntas"
    uso
    exit 7
fi

# LECTURA DE PREGUNTAS DEL FICHERO

# declaramos los dos diccionarios que voy a usar mas tarde
declare -A todasPreguntas       # Almacenará todas las preguntas del fichero
declare -A preguntas            # Almacenará solo el número de preguntas pedido

# Como bash no permite arrays bidimensionales, hemos creado estos dos diccionarios, que intentan similar cada uno un array bidimensional
# 
# Ejemplo: Acceder al elemento ij 
    # Normalmente se accedería así: todasPreguntas[i][j]
    # Para simular esa sintaxis, hemos utilizado una cadena de caracteres, de manera que los dos índices están separados por una coma
    # Por lo tanto, para acceder al elemento ij haríamos esto: todasPreguntas["$i, $j"]
#
# Descripción de los índices:
    # Primer índice(i) -> con este indicaremos el número de la pregunta. Es decir, identificaresmos la pregunta 0, la pregunta 1, la pregunta 2...
    # Segundo índice(j) -> indica la "parte" de la pregunta con la que estamos tratando. Tendrá solo 5 valores distintos:
        # "pregunta": almacena el enunciado de la pregunta
        # "opciones": almacena una cadena con las cuatro opcioens (A, B, C, D). Contiene saltos de línea entre las opciones
        # "respuesta": almacena la respuesta correcta (A, B, C o D)
        # "respuestaUsuario": almacena la respuesta introducida por el usuario (A, B, C o D)
        # "correcto": almacena una cadena que será "CORRECTO" o "INCORRECTO" dependiendo de si la respuesta del usuario es la correcta
#
# Ejemplo con dos preguntas:
# Columnas(j) ->   "pregunta"               |   "opciones"    |   "respuesta"    |    "respuestaUsuario"  |   "correcto"  |
# Filas (i) ------------------------------------------------------------------------------------------------------------------
#   0       | "¿Qué es el código..."        | "A. Código ..." |       "A"        |           "B"          | "INCORRECTO"  |
# ----------------------------------------------------------------------------------------------------------------------------
#   1       | "El sistema de numeración..." | "A. Es ..."     |      "B"         |           "B"          |   "CORRECTO"  |
# ---------------------------------------------------------------------------------------------------------------------------
# ...

# le quitamos el retorno de carro (en caso de que el fichero haya sido escrito en windows)
# para no tener problemas con los saltos de linea
temp=$(eliminar_retorno_carro "$ficheroPreguntas")

# Leemos el fichero linea a linea, eliminando los \n
readarray -t lineas < <(echo "$temp")

# Recorro el vector con las líneas
inicio=0        # Indica la línea del fichero donde empieza la siguiente pregutna
contador=0      # Indica el número de la pregunta
while [[ $inicio -lt ${#lineas[@]} ]]
do
    # Guardo el enunciado en el campo pregunta
    # ${lineas[@]:$inicio:1} -> A partir del elemento indicada por inicio, coge 1 elemento
    todasPreguntas+=( ["$contador, pregunta"]="${lineas[@]:$inicio:1}" )

    # Guardamos las opciones como un vector y luego lo convierto a cadena, ya que así
    # podemos añadir los saltos de línea más fácilmente 
    # ${lineas[@]:$((inicio + 1)):4} -> A partir del elemento indicada por inicio + 1, coge 4 elementos
    opciones=( "${lineas[@]:$((inicio + 1)):4}" )
    printf -v opcionesCadena '%s\n' "${opciones[@]}"

    if [[ $respuestasAleatorias == true ]]
    then
        # Guardamos los índices, generados de manera aleatoria
        read -r -a indices < <(indicesAleatorios 4)
        for (( i=0; i<4; i++))
        do
            # Le cortamos la parte de la letra, para poder ponerlas de forma aleatoria
            enunciado=$( echo "${opciones[${indices[$i]}]}" | cut -f 2- -d ' ' ) 

            # 65 es el codigo char de la "A", por lo que cuando i=0 letra será "A", cuando i=1 letra="B"...
            letra=$(char $((i + 65)))

            # Juntamos el enunciado con su letra correspondiente y lo metemos en un vector
            opcionesAleatorias[$i]="$letra. $enunciado"
        done

        printf -v opcionesCadena '%s\n' "${opcionesAleatorias[@]}"  
    fi

    todasPreguntas+=( ["$contador, opciones"]="$opcionesCadena" )

    # Guardamos la respuesta de manera que solo se guarde A, B, C o D
    # ${lineas[@]:$((inicio + 5)):1} -> A partir del elemento indicado por inicio + 5, cogemos un elemento
    respuesta=$( echo "${lineas[@]:$((inicio + 5)):1}" | cut -f 2 -d ' ' )
    todasPreguntas+=( ["$contador, respuesta"]=$respuesta )

    # Esta variable va a ir contando cuantas pregutnas tiene el fichero
    contador=$((contador + 1))

    # Esta variable se incrementa de 7 en 7 porque cada pregunta esta formada por 6 lineas + 1 salto de linea
    inicio=$((inicio + 7))
done

# Coomprobamos que el numero de preguntas no sea mayor al que las que hay en el fichero
# En caso contrario devolvemos error
preguntasFichero=$contador
if [[ $numeroPreguntas -gt $preguntasFichero ]]
then
    echo "Error: el numero de preguntas introducido es mayor que el numero de preguntas del fichero"
    exit
fi

# Ajustamos el numero de preguntas al dado o al que viene por defecto (5)
if [[ $preguntasAleatorias == false ]]
then
    # Copiamos los 5 primeros elemnetos de todasPreguntas en preguntsa
    for ((i=0; i<numeroPreguntas; i++))
    do 
        for j in pregunta opciones respuesta
        do
            preguntas+=( ["$i, $j"]="${todasPreguntas["$i, $j"]}" )
        done
    done
else
    # Generamos un vector de longitud numeroPreguntas, con números aleatorios
    # que nos servirán de índices para elegir la pregunta en todasPreguntas
    read -r -a indices < <(indicesAleatorios "$numeroPreguntas")
    for ((i=0; i<numeroPreguntas; i++))
    do
        for j in pregunta opciones respuesta
        do
            preguntas+=( ["$i, $j"]="${todasPreguntas["${indices[$i]}, $j"]}" )
        done
    done 
fi
