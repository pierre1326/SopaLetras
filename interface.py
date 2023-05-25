from pyswip import Prolog
from enum import Enum

#SOLUTION KEYS
class Solution(Enum):
    WORD = "word"
    LINES = "lines"

#DEFAULT PATHS
PROLOG_PATH = 'project.pl'
SOUP_PATH = 'alphabetSoup.txt'
WORDS_PATH = 'words.txt'
SOLUTIONS_PATH = 'solutions.txt'

#Prolog enviroment
prolog = Prolog()

#Load prolog project
def consult_project(path = PROLOG_PATH):
    prolog.consult(path)

#Resolve soup
def resolve_soup(path_soup = SOUP_PATH, path_words = WORDS_PATH, path_solutions = SOLUTIONS_PATH):
    query = "solve_soup('{}', '{}', '{}', Words, ExpandedSolutions)".format(path_soup, path_words, path_solutions)
    print(query)
    result = list(prolog.query(query))
    if result:
        expanded_solutions = result[0]["ExpandedSolutions"]
        words = result[0]["Words"]
        return words, expanded_solutions
    else :
        return None, None

def create_solution(word, expanded_solution):
    solutions = []
    result = {}
    result[Solution.WORD] = word
    for line in enumerate(expanded_solution):
        solutions.append(line)
    result[Solution.LINES] = solutions
    return result

""""
Result object format:

{
    Solution.Word: word -> string: apple, is, bird, etc...
    Solution.Lines: array: [ //All the solutions
        [ //One solution
            [x1, y1], //First letter of the word
            [x2, y2], //Second letter
            ... // Remaining letters
        ],
        ... //Remaining solutions
    ]
}
"""
def format_response(words, expanded_solutions):
    if len(words) == len(expanded_solutions):
        solutions = []
        for index, word in enumerate(words):
            expanded_solution = expanded_solutions[index]
            solutions.append(create_solution(word, expanded_solution))
        return solutions
    else:
        return None

def example(): #No paso parametros a funciones porque uso los default
    consult_project()
    words, expanded_solutions = resolve_soup() #Debes pasar los paths que selecciono el usuario
    solutions = format_response(words, expanded_solutions)
    print(solutions)

def load_interface():
    print("En este metodo debes iniciar tu interfaz")

def main():
    example()
    load_interface()

main()
