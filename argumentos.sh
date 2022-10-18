#!/bin/bash

function help () {
    echo 'Uso: ./examen.sh [-h] -f bancoPreguntas.txt [OPCIONES]...'
    echo 'Permite realizar en el terminal un examen tipo test, cuyas preguntas están en el archivo especificado con -f'
    echo 'Este archivo contendrá varias preguntas (con sus respectivas respuestas) de entre las cuales se seleccionara para hacer el examen'
    echo 'IMPORTANTE: debe de ser obligatoriamente de tipo .txt'
    echo 'Al finalizar la realización del examen se calcula la nota final.'
    echo 'Además de mostrar la nota por pantalla, se creará un fichero de texto (revision.txt) con la revisión del examen.'
    echo 'En el se incluirán las preguntas con su solución correcta, la solución proporcionada por el alumno y se mostrará si esta respuesta es correcta o incorrecta'
    echo ''
    echo 'Lista de argumentos'
    echo '-f    Indica el fichero donde están incluidas las preguntas. OBLIGATORIO'
    echo '-h    Ayuda de uso del programa'
    echo '-n    Indica el número de preguntas del examen. Si no se especifíca por defecto se incluyen 5 preguntas'
    echo '-p    Indica el porcentaje, sobre la puntuación total de la pregunta, que penalizar una pregunta incorrecta. Si no se indica las preguntas incorrectas no penalizan'
    echo '-r    Las preguntas se muestran de forma aleatoria'
    echo '-rr   Ordena de forma aleatoria las respuestas'
    echo ''
    echo 'Estado de salida:'
    echo '0 si todo va bien'
   
}

while getopts ":f:hn:p:rr:r:" option;  do
    case $option in
        h) # mostrar mensaje de aydua
            help
            exit 0;;
        *) # Opcion por defecto
            echo 'Error: opcion no valida'
            exit 1;;
    esac
done
