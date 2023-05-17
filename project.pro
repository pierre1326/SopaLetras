%Testo unicamente
example(FileName) :-
    read_words('words.txt'),
    expand_solutions([ [ [ [0,0], [0,4] ], [ [0,0], [4,0] ], [ [0,0], [4,4] ] ], [ [ [0,0], [0,4] ], [ [0,0], [4,0] ], [ [0,0], [4,4] ] ] ], ExpandedSolutions),
    write_solutions(FileName, ExpandedSolutions).

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

write_solutions(FileName, Solutions) :-
    words(Words),
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

%Unicamente para testeo
print_array([]).
print_array([ X | Rest ]) :-
    writeln(X),
    print_array(Rest).