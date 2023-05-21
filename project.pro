%Testo unicamente
example(_) :-
    read_soup('alphabetSoup.txt'),
    read_words('words.txt'),
    soup(Lines),
    words(Words),
    find_solution(Lines, Words, Solutions),
    writeln(Solutions),
    expand_solutions(Solutions, ExpandedSolutions),
    writeln(ExpandedSolutions),
    write_solutions('solutions.txt', ExpandedSolutions, Words).

solve_soup(FileNameSoup, FileNameWords, FileNameSolutions) :-
    read_soup(FileNameSoup),
    read_words(FileNameWords),
    soup(Lines),
    words(Words),
    find_solution(Lines, Words, Solutions),
    writeln(Solutions),
    expand_solutions(Solutions, ExpandedSolutions),
    writeln(ExpandedSolutions),
    write_solutions(FileNameSolutions, ExpandedSolutions, Words).

find_solution(Lines, Words, Solutions) :-
    findall(Solution, (
        member(Word, Words),
        find_matching_positions(Lines, Word, Solution)
    ), Solutions).

find_matching_positions(Matrix, Substring, MatchingPositions) :-
    find_matching_positions_horizontal(Matrix, Substring, PositionsHorizontal),
    find_matching_positions_vertical(Matrix, Substring, PositionsVertical),
    find_matching_positions_diagonal(Matrix, Substring, PositionsDiagonal),
    concatenate_arrays([PositionsHorizontal, PositionsVertical, PositionsDiagonal], MatchingPositions).

find_matching_positions_diagonal(Matrix, Substring, MatchingPositions) :-
    transpose(Matrix, TransposedMatrix),
    get_diagonals(Matrix, 0, Diagonals),
    get_diagonals(TransposedMatrix, 1, TransposedDiagonals),
    find_matching_positions_diagonal_lower(Diagonals, Substring, MatchingPositionsLower),
    find_matching_positions_diagonal_superior(TransposedDiagonals, Substring, MatchingPositionsSuperior),
    append(MatchingPositionsLower, MatchingPositionsSuperior, MatchingPositions).

find_matching_positions_diagonal_lower(Matrix, Substring, MatchingPositions) :-
    findall([ [ StartRow, Start ], [ EndRow, End ] ], (
        nth1(IndexRow, Matrix, Row),
        atomic_list_concat(Row, '', RowAtom),
        (
            sub_atom(RowAtom, Before, Length, _, Substring)
        ;
            invert_word(Substring, Inverted),
            sub_atom(RowAtom, Before, Length, _, Inverted)
        ),
        Start is Before + 1,
        End is Start + Length - 1,
        StartRow is IndexRow + Start - 1,
        EndRow is IndexRow + End - 1
    ), MatchingPositions).

find_matching_positions_diagonal_superior(Matrix, Substring, MatchingPositions) :-
    findall([ [ Start, StartColumn ], [ End, EndColumn ] ], (
        nth1(IndexRow, Matrix, Row),
        atomic_list_concat(Row, '', RowAtom),
        (
            sub_atom(RowAtom, Before, Length, _, Substring)
        ;
            invert_word(Substring, Inverted),
            sub_atom(RowAtom, Before, Length, _, Inverted)
        ),
        Start is Before + 1,
        End is Start + Length - 1,
        StartColumn is IndexRow + Start,
        EndColumn is IndexRow + End
    ), MatchingPositions).

find_matching_positions_horizontal(Matrix, Substring, MatchingPositions) :-
    findall([ [ IndexRow, Start ], [ IndexRow, End ] ], (
        nth1(IndexRow, Matrix, Row),
        atomic_list_concat(Row, '', RowAtom),
        (
            sub_atom(RowAtom, Before, Length, _, Substring)
        ;
            invert_word(Substring, Inverted),
            sub_atom(RowAtom, Before, Length, _, Inverted)
        ),
        Start is Before + 1,
        End is Start + Length - 1
    ), MatchingPositions).

find_matching_positions_vertical(Matrix, Substring, MatchingPositions) :-
    transpose(Matrix, TransposedMatrix),
    findall([ [ Start, IndexColumn ], [ End, IndexColumn ] ], (
        nth1(IndexColumn, TransposedMatrix, Row),
        atomic_list_concat(Row, '', RowAtom),
        (
            sub_atom(RowAtom, Before, Length, _, Substring)
        ;
            invert_word(Substring, Inverted),
            sub_atom(RowAtom, Before, Length, _, Inverted)
        ),
        Start is Before + 1,
        End is Start + Length - 1
    ), MatchingPositions).

get_diagonals(Matrix, Start, Diagonals) :-
    length(Matrix, Length),
    N is Length - 1,
    findall(Diagonal, (
        between(Start, N, StartRow),
        get_diagonal(Matrix, StartRow, Diagonal)
    ), Diagonals).

get_diagonal(Matrix, StartRow, Diagonal) :-
    length(Matrix, N),
    findall(Element, (
        between(StartRow, N, I),
        J is I - StartRow,
        nth0(I, Matrix, Row),
        nth0(J, Row, Element)
    ), Diagonal).

expand_solutions([], []).
expand_solutions([Word | Words], ExpandedSolutions) :-
    expand_solutions_aux(Word, ExpandedSolution),
    expand_solutions(Words, TempExpandedSolutions),
    append([ExpandedSolution], TempExpandedSolutions, ExpandedSolutions).

expand_solutions_aux([], []).
expand_solutions_aux([Solution | Solutions], [ExpandedSolution | ExpandedSolutions]) :-
    expand_solution(Solution, ExpandedSolution),
    expand_solutions_aux(Solutions, ExpandedSolutions).

expand_solution([[X1, Y1], [X2, Y2]], ExpandedSolution) :-
    expand_solution_aux(X1, Y1, X2, Y2, ExpandedSolution).

expand_solution_aux(X1, Y1, X2, Y2, ExpandedSolution) :-
    X1 = X2,
    expand_horizontal(X1, Y1, Y2, ExpandedSolution).

expand_solution_aux(X1, Y1, X2, Y2, ExpandedSolution) :-
    Y1 = Y2,
    expand_vertical(X1, X2, Y1, ExpandedSolution).

expand_solution_aux(X1, Y1, X2, Y2, ExpandedSolution) :-
    expand_diagonal(X1, Y1, X2, Y2, ExpandedSolution).

expand_horizontal(_, Y1, Y2, []) :-
    Y1 > Y2.
expand_horizontal(X, Y1, Y2, [[X, Y1] | YValues]) :-
    Y1 =< Y2,
    Y1Next is Y1 + 1,
    expand_horizontal(X, Y1Next, Y2, YValues).

expand_vertical(X1, X2, _, []) :-
    X1 > X2.
expand_vertical(X1, X2, Y, [ [X1, Y] | XValues ]) :-
    X1 =< X2,
    X1Next is X1 + 1,
    expand_vertical(X1Next, X2, Y, XValues).

expand_diagonal(X1, _, X2, _, []) :-
    X1 > X2.
expand_diagonal(X1, Y1, X2, Y2, [ [X1, Y1] | Values ]) :-
    X1 =< X2,
    X1Next is X1 + 1,
    Y1Next is Y1 + 1,
    expand_diagonal(X1Next, Y1Next, X2, Y2, Values).

read_soup(FileName) :-
    open(FileName, read, Stream),
    read_lines(Stream, Lines),
    close(Stream),
    retractall(soup(_)),
    assertz(soup(Lines)).

read_words(FileName) :-
    open(FileName, read, Stream),
    read_line_to_string(Stream, Line),
    close(Stream),
    split_string(Line, ",", "", Words),
    retractall(words(_)),
    assertz(words(Words)).

write_solutions(FileName, Solutions, Words) :-
    open(FileName, write, Stream),
    write_file(Stream, Words, Solutions),
    close(Stream).

write_file(_, [], _).
write_file(Stream, [ Word | Words ], [ Solution | Solutions ]) :-
    write(Stream, Word),
    write(Stream, '\n'),
    write_matrix(Stream, Solution),
    write_file(Stream, Words, Solutions).

write_matrix(_, []).
write_matrix(Stream, [ Line | Lines ]) :-
    write(Stream, Line),
    write(Stream, '\n'),
    write_matrix(Stream, Lines).

read_lines(Stream, Lines) :-
    read_line(Stream, Line),
    (   Line = end_of_file
    ->  Lines = []
    ;   split_string(Line, ",", "", Letters),
        Lines = [Letters | RestLines],
        read_lines(Stream, RestLines)
    ).

read_line(Stream, Line) :-
    read_line_to_string(Stream, Line).

invert_word(Word, Result) :-
    atom_chars(Word, List),
    reverse(List, InvertedList),
    atom_chars(Result, InvertedList).

concatenate_arrays([], []).
concatenate_arrays([Array|Arrays], ConcatenatedArray) :-
    concatenate_arrays(Arrays, Rest),
    append(Array, Rest, ConcatenatedArray).

transpose([], []).
transpose([[]|_], []).
transpose(Matrix, [FirstCol|RestCols]) :-
    transpose_1st_col(Matrix, FirstCol, RestMatrix),
    transpose(RestMatrix, RestCols).

transpose_1st_col([], [], []).
transpose_1st_col([[First|Row]|Rows], [First|FirstCol], [Row|RestMatrix]) :-
    transpose_1st_col(Rows, FirstCol, RestMatrix).