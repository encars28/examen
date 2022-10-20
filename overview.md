# ESTRUCTURA GENERAL

- [x] Validacion de argumentos de la linea de comando:
    - [x] Imprimir los mensajes de error correspndientes si los argumentos no son validos 
    - [x] Comprobar que obligatoriamente ha metido un fichero
        - [x] Comprobar que ese fichero sea de extension .txt
    - [x] Guardar en variables la informacion proporcionada: numero de preguntas, aleatorio...

- [] Abrir el fichero con las preguntas e intentar:
    - [] Convertir cada pregunta en un solo string
    - [] Hacer un array de strings con todas las preguntas
    - [] Comprobar que el numero de preguntas dadas no sea mayor que las que hay en el fichero
    - [] Comprobar que el fichero existe

- [] Quedarme solamente con el nuemro de preguntas que me piden (-n)
    - [] Coger del array de preguntas solo la parte que va desde el indice 0 hasta numero de preguntas - 1

    - [] CASO PREUGUNTAS ALEATORIO (-r):
        - [] Conseguir numeros random desde 0 hasta el numero de preguntas (sin que se repitan)
        - [] Hacer un nuevo array con los elementos de la lista de preguntas con los indices aleatorios calculados

- [] Por cada pregunta individual del array dividirla en dos:
    - [] Quedarnos por una parte con la letra de la respuesta
    - [] Quedarnos por otra parte con el enunciado de la pregunta (resto del string)
        - [] CASO DE RESPUESTAS ALEATORIO (-rr)
            - [] Dividir el enunciado a su vez en dos, la pregutna y un array de 4 stirngs, q van a ser las opciones
            - [] Volver a hacer lo de los indices aleatorios como para preguntas aleatorias
    
- [] Imprimir el examen
    - [] Poner un titulo
    - [] Imprimir la parte del enunciado
    - [] Leer la respuesta
    - [] Hacer validacion de la respuesta (A, B, C o D)
    - [] Si la respueta dada coincide con la respuesta guardada incrementar una variable que guarde el numero de preguntas correctas contestadas
    - [] Anadir al array con el enunciado y la respuesta dos strings:
        - [] Una que indique la respuesta dada por el alumno
        - [] Otra que diga correcto o incorrecto
    
- [] Calcular la nota
    - [] La nota es el numero de pregutnas correctas
    - [] CASO DE PORCENTAJE (-p)
        - [] La nota es el numero de preguntas correctas - el nuemero de preguntas incorrectas*porcentaje

- [] Hacer el archivo con la revision que contendra:
    - [] La informacion que hemos guardado:
        - [] Enunciado
        - [] Respuesta correcta
        - [] Respuesta dada
        - [] Si es correcto o incorrecto
