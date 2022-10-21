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