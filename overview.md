# ESTRUCTURA GENERAL

- [x] Validacion de argumentos de la linea de comando:
    - [x] Imprimir los mensajes de error correspndientes si los argumentos no son validos 
    - [x] Comprobar que obligatoriamente ha metido un fichero
        - [x] Comprobar que ese fichero sea de extension .txt
    - [x] Guardar en variables la informacion proporcionada: numero de preguntas, aleatorio...

- [x] Abrir el fichero con las preguntas e intentar:
    - [x] Convertir cada pregunta en un solo string
    - [x] Hacer un array de strings con todas las preguntas
    - [x] Comprobar que el numero de preguntas dadas no sea mayor que las que hay en el fichero
    - [x] Comprobar que el fichero existe

- [x] Quedarme solamente con el nuemro de preguntas que me piden (-n)
    - [x] Coger del array de preguntas solo la parte que va desde el indice 0 hasta numero de preguntas - 1

    - [x] CASO PREUGUNTAS ALEATORIO (-r):
        - [x] Conseguir numeros random desde 0 hasta el numero de preguntas (sin que se repitan)
        - [x] Hacer un nuevo array con los elementos de la lista de preguntas con los indices aleatorios calculados

- [x] Por cada pregunta individual del array dividirla en dos:
    - [x] Quedarnos por una parte con la letra de la respuesta
    - [x] Quedarnos por otra parte con el enunciado de la pregunta (resto del string)
        - [x] CASO DE RESPUESTAS ALEATORIO (-rr)
            - [x] Dividir el enunciado a su vez en dos, la pregutna y un array de 4 stirngs, q van a ser las opciones
            - [x] Volver a hacer lo de los indices aleatorios como para preguntas aleatorias
    
- [x] Imprimir el examen
    - [x] Poner un titulo
    - [x] Imprimir la parte del enunciado
    - [x] Leer la respuesta
    - [x] Hacer validacion de la respuesta (A, B, C o D)
    - [x] Si la respueta dada coincide con la respuesta guardada incrementar una variable que guarde el numero de preguntas correctas contestadas
    - [x] Anadir al array con el enunciado y la respuesta dos strings:
        - [x] Una que indique la respuesta dada por el alumno
        - [x] Otra que diga correcto o incorrecto
    
- [x] Calcular la nota
    - [x] La nota es el numero de pregutnas correctas
    - [x] CASO DE PORCENTAJE (-p)
        - [x] La nota es el numero de preguntas correctas - el nuemero de preguntas incorrectas*porcentaje

- [x] Hacer el archivo con la revision que contendra:
    - [x] La informacion que hemos guardado:
        - [x] Enunciado
        - [x] Respuesta correcta
        - [x] Respuesta dada
        - [x] Si es correcto o incorrecto
