def get_diagonal(matrix, index):
    row = 0
    letters = []
    for column in range(index, len(matrix)):
        letters.append(matrix[row][column])
        row += 1
    return letters

def get_diagonals(matrix):
    result = []
    for i in range(len(matrix)):
        letters = get_diagonal(matrix, i)
        result.append(letters)
    return result

def example():
    matrix = [['a','p','p','l','e','s','i'],
              ['o','p','d','k','v','r','a'],
              ['u','x','e','r','j','q','d'],
              ['r','y','z','n','i','q','o'],
              ['a','z','y','u','x','b','s'],
              ['a','z','y','u','x','b','s'],
              ['a','z','y','u','x','b','s']]
    resultado = get_diagonals(matrix)
    print(resultado)
