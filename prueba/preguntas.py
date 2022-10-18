#from time import sleep
from random import choice, shuffle

with open('./../bancoPreguntas.txt', 'r') as f:
    Lines = f.readlines()

# these are the arguments we'll have to ask for
# we probably should make some comprobations here too
numero_preguntas = 5
total_questions = 10
preguntas_aleatorio = False
respuestas_aleatorio = False
porcentaje = 0.5

# get all the questions on a list
questions_list = []
while True:
    try:
        #print(Lines)
        i = Lines.index('\n')
        questions_list.append(''.join(Lines[:i]))
        #print(questions)
        #print()
        Lines = Lines[i + 1:]
        #sleep(5)
    except ValueError: # the index function cannot find anymore elements '\n'
        questions_list.append(''.join(Lines))
        break

# now I only pick the number of questions specified
if not preguntas_aleatorio:
    questions_list = questions_list[:numero_preguntas]
else:
    # picks a random element from the list and removes it
    # we do this total_questions - numero_preguntas times
    for i in range(total_questions - numero_preguntas):
        questions_list.remove(choice(questions_list))

# it would be more efficient to create a sepparate list and append the elements
# when the choice functions chooses them, but I don't want to create another variable

# separate the text block and make a dictionary
questions = []
for i, question in enumerate(questions_list):
    questions_list[i] = question.strip().split('\n')
    if not respuestas_aleatorio:
        question_text = '\n'.join(questions_list[i][:-1])
    else: 
        questions_random = questions_list[i][:-1]
        shuffle(questions_random)
        question_text = '\n'.join(questions_random)


    q = { 
        'question': question_text,
        'answer': questions_list[i][5].split()[1] # only the letter remains
        }
    questions.append(q)

# now we ask the user to do the exam
print('EXAMEN\n')

correct = 0
wrong = 0
for question in questions:
    print(question['question'])
    # we make sure the answer given it's either 'A', 'B', 'C' or 'D'
    ex = False
    answer = ''
    while not ex:
        answer = input('> ')
        if answer.upper() in ('A', 'B', 'C', 'D'):
            ex = True
        else:
            print('La respuesta tiene que ser una de las dadas')

    # we check if the answer is correct
    if answer.upper() == question['answer']:
        correct += 1
        question.update({'correct': 'CORRECT!', 
                         'answer_given': answer})
    else: 
        wrong += 1
        question.update({'correct': 'INCORRECT :(', 
                         'answer_given': answer})
    
    print()

# Now we calculate the grade, which is the number of correct answers
# Unless it's not
if porcentaje != None:
    total = correct - wrong*porcentaje
else:
    total = correct
    
# We make the text file for the revision
revision = ''
for question in questions:
    revision += question['correct'] + '\n\n' + question['question'] + '\n' + 'ANSWER GIVEN: ' + question['answer_given'] + '\n' + 'CORRECT ANSWER: ' + question['answer'] + '\n\n'

revision += f'PUNTUACION TOTAL: {total}'

with open('revision.txt', 'w') as f:
    f.write(revision)
    print('\nArchivo con la revision creado')
    print(f'\nPUNTUACION TOTAL: {total}')