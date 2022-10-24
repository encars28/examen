#!/bin/bash
opciones=( "A. Código que asigna a cada caracter un número." "B. Es un código internacional." "C. Es un código que se usa para pasar de decinal al binario." "D. Es un código que se usa para pasar de bianrio a decimal." )
declare -a indicesUsados
declare -a opcionesAleatorias

# check if a variable is in a list
# echo $list | grep -w -q $x

while true 
do
    echo "${#indicesUsados[@]}"
    if [[ ${#indicesUsados[@]} -ge 4 ]]
    then
        echo "a"
        break
    fi

    indice=$((RANDOM %4))
    check=$(echo "${indicesUsados[@]}" | grep -w "$indice")
    if [[ $check != "$indice" ]]
    then
        indicesUsados+=( "$indice" )
        enunciado=$( echo "${opciones[$indice]}" | cut -f 2- -d ' ' )

        case "${#indicesUsados[@]}" in
        0)
            opcionesAleatorias[0]="A. $enunciado"
        ;;
        1)
            opcionesAleatorias[1]="B. $enunciado"
        ;;
        2)
            opcionesAleatorias[2]="C. $enunciado"
        ;;
        3)
            opcionesAleatorias[3]="D. $enunciado"
        ;;
        *)
            echo "${#indicesUsados[@]}"
            echo "Error desconodico"
            exit
        ;;
        esac
    fi

done

declare -p opcionesAleatorias