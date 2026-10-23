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


% Ejercicio 6 ---------------------------------------

%! aplanar(+Xs, -Ys)
aplanar([], []).
aplanar([X | T], [X | L]) :- not(is_list(X)), aplanar(T, L).
aplanar([H | T], L) :- aplanar(H, U), aplanar(T, V), append(U, V, L).

% Ejercicio 7 ---------------------------------------

% i) ---

%! intersección(+L1, +L2, -L3)
% L3 es la intersección sin repeticiones de las listas L1 y L2, respetando en L3 el orden en que aparecen los elementos en L1

quitar_elemento([], _, []).
quitar_elemento([X | XS], X, L) :- quitar_elemento(XS, X, L).
quitar_elemento([X | XS], Y, [X | L]) :- X \= Y, quitar_elemento(XS, Y, L).

% Caso base
intersección([], _, []).

% Caso 1: H pertenece a L2 -> Se incluye H en L3 y se remueven sus repeticiones en T
intersección([H | T], L2, [H | L3]) :-
    member(H, L2),
    quitar_elemento(T, H, T_sin_H),
    intersección(T_sin_H, L2, L3).

% Caso 2: H no pertenece a L2 -> Se descarta H
intersección([H | T], L2, L3) :-
    not(member(H, L2)),
    intersección(T, L2, L3).

%! partir(N, L, L1, L2)
partir(0, L, [], L).
partir(suc(N), [H | T], [H | L1], L2) :- partir(N, T, L1, L2).

% ii) ---

% borrar(+ListaOriginal, +X, -ListaSinXs)
% es la misma que quitar_elemento que hice arriba
borrar([], _, []).
borrar([X | XS], X, L) :- borrar(XS, X, L).
borrar([X | XS], Y, [X | L]) :- X \= Y, borrar(XS, Y, L).

% iii) ---
%! sacarDuplicados(+L1, -L2)

% Caso base
sacarDuplicados([], []).
% Caso X es duplicado, queda sólo la 1ra aparición de X
sacarDuplicados([X | XS], [X | L]) :-
    member(X, XS),
    borrar(XS, X, XS_sin_X),
    sacarDuplicados(XS_sin_X, L).
% Caso X no es duplicado
sacarDuplicados([X | XS], [X | L]) :-
    not(member(X, XS)),
    sacarDuplicados(XS, L).

% iv) ---
% cantidadApariciones(X, L, N)
cantidadApariciones(_, [], 0).
cantidadApariciones(X, [X | XS], suc(M)) :-
    cantidadApariciones(X, XS, M).
cantidadApariciones(X, [Y | XS], M) :-
    X \= Y,
    cantidadApariciones(X, XS, M). 

%! permutación(+L1, +L2)
/*permutación([], []).
permutación([X | XS], L2) :-
    cantidadApariciones(X, XS, Apariciones_X_en_L1),
    cantidadApariciones(X, L2, Apariciones_X_en_L2),
    suc(Apariciones_X_en_L1) = Apariciones_X_en_L2,
    borrar(XS, X, L1_sin_X),
    borrar(L2, X, L2_sin_X),
    permutación(L1_sin_X, L2_sin_X).*/

%! permutación(+L1, ?L2)
permutación([], []).
permutación(L1, [Y | YS]) :-
    select(Y, L1, L1_sin_Y), % quita 1 aparición de Y sobre L1
    permutación(L1_sin_Y, YS).

%! permutación2(+L1, +L2)
% más eficiente para L2 definida
permutación2(L1, L2) :-
    msort(L1, L1_sorted),
    msort(L2, L2_sorted),
    L1_sorted = L2_sorted.

% v) ---

%! reparto(+L, +N, -LListas)
reparto([], 0, []).
reparto(L, suc(M), [X | LListas]) :- 
    append(X, L_resto, L),
    reparto(L_resto, M, LListas).

% vi) ---
% repartoSinVacías(+L, -LListas)
% [a,b] -> [[a,b]], [[a], [b]]
% [a,b,c] -> [[a,b,c]],  [[a,b], [c]],  [[a], [b,c]]
/*
repartoSinVacias([], []).
repartoSinVacias([X], [[X]]) :-
    not(is_list(X)).
repartoSinVacias(L, [X | LListas]) :- 
    append(X, L_resto, L),
    is_list(X),
    is_list(L_resto),
    X \= [],
    repartoSinVacias(L_resto, LListas).*/