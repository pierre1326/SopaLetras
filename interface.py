import tkinter as tk
import os

from tkinter import filedialog, messagebox
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
    for line in expanded_solution:
        solutions.append(line)
    result[Solution.LINES] = solutions
    return result

def format_response(words, expanded_solutions):
    if len(words) == len(expanded_solutions):
        solutions = []
        for index, word in enumerate(words):
            expanded_solution = expanded_solutions[index]
            solutions.append(create_solution(word, expanded_solution))
        return solutions
    else:
        return None

class ButtonWindow(tk.Tk):
    def __init__(self):
        tk.Tk.__init__(self)
        self.title("Word Search")
        self.geometry("500x100") 
        self.resizable(False, False)

        self.buttons_generated = False
        self.word_search_file = False
        self.word_list_file = False

        self.generate_button = tk.Button(self, text="Resolve Soup", command=self.generate_buttons)
        self.generate_button.grid(row=0, column=0, pady=10, padx=10)

        self.load_word_search_button = tk.Button(self, text="Load Word Search", command=self.select_word_search)
        self.load_word_search_button.grid(row=0, column=1, pady=10, padx=10)

        self.load_word_list_button = tk.Button(self, text="Load Word List", command=self.select_word_list)
        self.load_word_list_button.grid(row=0, column=2, pady=10, padx=10)

        self.word_search_state_label = tk.Label(self, width=20, text="Status: Not loaded")
        self.word_search_state_label.grid(row=1, column=1, pady=10, padx=10)

        self.word_list_state_label = tk.Label(self, width=20, text="Status: Not loaded")
        self.word_list_state_label.grid(row=1, column=2, pady=10, padx=10)

    def select_word_list(self):
        file = filedialog.askopenfilename(filetypes=[("Text files", "*.txt")])
        if file:
            self.word_list_file = file
            filename = os.path.basename(self.word_list_file)
            self.word_list_state_label.configure(text=f"File: {filename}")
            self.read_words()

    def select_word_search(self):
        file = filedialog.askopenfilename(filetypes=[("Text files", "*.txt")])
        if file:
            self.word_search_file = file
            filename = os.path.basename(self.word_search_file)
            self.word_search_state_label.configure(text=f"File: {filename}")

    def read_words(self):
        words = []
        with open(self.word_list_file, 'r') as file:
            for line in file:
                row = line.strip().split(',')
                words += row
        row = 0
        column = 0
        for word in words:
            if column >= 3:
                column = 0
                row += 1
            word_label = tk.Label(self, width=20, text=word)
            word_label.grid(row=row + 2, column=column, pady=10, padx=10)
            column += 1

    def read_file(self):
        matrix = []
        with open(self.word_search_file, 'r') as file:
            for line in file:
                row = line.strip().split(',')
                matrix.append(row)
        return matrix

    def execute_prolog(self):
        consult_project()
        words, expanded_solutions = resolve_soup(self.word_search_file, self.word_list_file)
        solutions = format_response(words, expanded_solutions)
        return solutions

    def generate_buttons(self):
        if self.buttons_generated:
            return
        if not self.word_search_file or not self.word_list_file:
            return messagebox.showerror("Error", "Please complete the information before continuing")

        solutions = self.execute_prolog()
        matrix = self.read_file()

        self.rows = len(matrix)
        self.columns = len(matrix[0])

        self.buttons = []
        for i in range(self.rows):
            row_buttons = []
            for j in range(self.columns):
                letter = matrix[i][j]
                button = tk.Button(self, text=letter, bg="white", state='disabled', height=1, width=4, fg="black")
                button.grid(row=i, column=j+5, padx=5, pady=5)
                row_buttons.append(button)
            self.buttons.append(row_buttons)

        window_width = self.columns * 50 
        height = (self.rows + 4) * 30
        self.geometry(f"{500 + window_width}x{height}")
        self.buttons_generated = True 
        self.update_buttons(solutions)

    def update_buttons(self, solutions):
        print(solutions)
        for solution in solutions:
            lines = solution[Solution.LINES]
            for line in lines:
                for point in line:
                    self.change_button_color(point[0] - 1, point[1] - 1, "light blue")

    def change_button_color(self, row, column, new_color):
        if not self.buttons_generated:
            return
        if row < 0 or row >= self.rows or column < 0 or column >= self.columns:
            return
        self.buttons[row][column].configure(bg=new_color)

window = ButtonWindow()
window.mainloop()
