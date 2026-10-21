% Ejercicio 1 ---------------------------------------

padre(juan, carlos).
padre(juan, luis).
padre(carlos, daniel).
padre(carlos, diego).
padre(luis, pablo).
padre(luis, manuel).
padre(luis, ramiro).
abuelo(X,Y) :- padre(X,Z), padre(Z,Y). 

% ii) ---

% X es hijo de Y
hijo(X,Y) :- padre(Y,X).

% X es hermano de Y
hermano(X,Y) :- padre(Z,X), padre(Z,Y), X \= Y.

% X es descendiente de Y
descendiente(X,Y) :- padre(Y,X).
descendiente(X,Y) :- padre(Y,Z), descendiente(X,Z).


% vi) ---

ancestro(X, X).
ancestro(X, Y) :- ancestro(Z, Y), padre(X, Z).

% Ejercicio 3 ---------------------------------------

natural(0).
natural(suc(X)) :- natural(X).

% menorOIgual(X, suc(Y)) :- menorOIgual(X, Y).
% menorOIgual(X,X) :- natural(X).

menorOIgual(X,X) :- natural(X).
menorOIgual(X, suc(Y)) :- menorOIgual(X, Y).

% Ejercicio 4 ---------------------------------------

% juntar(?L1, ?L2, ?L3)
juntar([], L2, L2).
juntar([X | XS], L2, [X | L3]) :- juntar(XS, L2, L3).


% Ejercicio 5 ---------------------------------------

% i) ---

% last(?L, ?U)
last(L, U) :- append(_, [U], L), 

% ii) ---

% reverse(+L, ?R)
reverse([], []).
reverse([X | XS], R) :- reverse(XS, RS), append(RS, [X], R).

% iii) ---

% prefijo(?P, +L)
prefijo(P, L) :- append(P, _, L).

% iv) ---

% sufijo(?S, +L)
sufijo(S, L) :- append(_, S, L).

% v) ---

% sublista(?S, +L)
sublista(S, L) :- append(_, S, L), append(S, _, L).

% vi) ---

% pertenece(?X, +L)
pertenece(X, L) :- append(_, [X | _], L).
