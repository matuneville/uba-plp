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


% Ejercicio 9 ---------------------------------------

% desde(+X, -Y)
desde(X,X).
desde(X,Y) :- N is X+1, desde(N,Y).

% desdeReversible(+X, ?Y)
desdeReversible(X,Y) :-
    % si Y variable, entonces funciona desde
    var(Y),
    desde(X,Y). 
desdeReversible(X,Y) :-
    % si Y instanciada, chequeo que sea mayor o igual
    nonvar(Y),
    Y >= X. 


% Ejercicio 11 ---------------------------------------

% vacio(+AB)
vacio(nil).

% raiz(+AB, ?V)
raiz(bin(_, V, _), V).

% altura(+AB, ?H)
altura(nil, 0).
altura(bin(Izq, _, Der), H) :-
    altura(Izq, H_Izq),
    altura(Der, H_Der),
    Sub_H_max is max(H_Izq, H_Der),
    H is 1+Sub_H_max.

% cantidadDeNodos(+AB, ?N)
cantidadDeNodos(nil, 0).
cantidadDeNodos(bin(Izq, _, Der), N) :-
    cantidadDeNodos(Izq, N_Izq),
    cantidadDeNodos(Der, N_Der),
    N is 1 + N_Izq + N_Der.


% Ejercicio 13 ---------------------------------------

coprimos(X, Y) :-
    % desde(1, X), desde(1, Y), gcd(X, Y) =:= 1.
    desde(1, N), between(1, N, X), Y is N-X, gcd(X, Y) =:= 1.

% Ejercicio 14 ---------------------------------------

% i) ---

% filaLargoNQueSumaS(N, S, F)
filaLargoNQueSumaS(0, 0, []).
filaLargoNQueSumaS(N, S, [H | T]) :-
    N > 0,
    between(0, S, H),
    S_resto is S-H,
    N_resto is N-1,
    filaLargoNQueSumaS(N_resto, S_resto, T).

% rectanguloSemiMagico(+N, +M, +S, -R)
rectanguloSemiMagico(_, 0, _, []).
rectanguloSemiMagico(N, M, S, [F | FS]) :-
    M > 0,
    filaLargoNQueSumaS(N, S, F),
    M_resto is M-1,
    rectanguloSemiMagico(N, M_resto, S, FS).

% cuadradoSemiMágico(+N, -XS)
cuadradoSemiMágico(0, []).
cuadradoSemiMágico(N, XS) :-
    N > 0,
    desde(0, S),
    rectanguloSemiMagico(N, N, S, XS).

% ii) ---

% Tengo que readaptar la solucion anterior para que use Gen & Test.
% No me sirve el filaLargoNQueSumaS actual ya que las genera segun restricciones.
% lo que hago es generar filas de largo N. Pero como son infinitas, genero 
% todas las posibles donde el máximo número es S. Asi da un subconjunto acotado

% filaLargoN(+N, +S, -L)
filaLargoN(0, _, []).
filaLargoN(N, S, [H | T]) :-
    N > 0,
    between(0, S, H),
    M is N-1,
    filaLargoN(M, S, T).

% Mismo concepto pero formando rectangulos

% rectangulo(+N, +M, +S, -R)
rectangulo(_, 0, _, []).
rectangulo(N, M, S, [F | FS]) :-
    M > 0,
    filaLargoN(N, S, F),
    M_resto is M-1,
    rectangulo(N, M_resto, S, FS).

% cuadradoMagico(+N, -XS)
cuadradoMagico(N, XS) :-
    desde(0, S), rectangulo(N, N, S, XS), % <-- GENERATE
    esMagico(XS, S). % <-- TEST: las filas ya suman S, queda chequear columnas

% esMagico(+Matriz, +S)
esMagico([], _).
esMagico([[] | _], _).
esMagico(Matriz, S) :-
    extraerColumna(Matriz, Columna, SubMatriz),
    sum_list(Columna, S),
    esMagico(SubMatriz, S).

% extraerColumna(+Matriz, -Columna, -SubMatriz)
extraerColumna([], [], []).
extraerColumna([[X | Xs] | Filas], [X | Col], [Xs | RestoFilas]) :-
    extraerColumna(Filas, Col, RestoFilas).
% extraerColumna([[1, 2, 3], [4, 5, 6], [7, 8, 9]], Col, SubMatriz)
% Col = [1, 4, 7], SubMatriz = [[2, 3], [5, 6], [8, 9]]


% Ejercicio 16 ---------------------------------------

frutal(frutilla).
frutal(banana).
frutal(manzana).
cremoso(banana).
cremoso(americana).
cremoso(frutilla).
cremoso(dulceDeLeche).
leGusta(X) :- frutal(X), cremoso(X).
cucurucho(X,Y) :- leGusta(X), leGusta(Y).


% Ejercicio 18 ---------------------------------------

% corteMasParejo(+L, -L1, -L2)
corteMasParejo(L, L1, L2) :-
    corteConDif(L, L1, L2, Dif),
    not((
        corteConDif(L, _, _, Dif2),
        Dif2 < Dif
    )).
    
corteConDif(L, L1, L2, D) :-
    append(L1, L2, L),
    sumlist(L1, S1),
    sumlist(L2, S2),
    D is abs(S2-S1).

% Ejercicio 20 ---------------------------------------

% primo(+N)
primo(N) :- not((M is N-1, between(2, M, D), N mod D =:= 0)).

% poderoso(+N)
numeroPoderoso(N) :- not((
    between(2, N, P),
    primo(P),
    N mod P =:= 0,
    PP is P*P,
    N mod PP =\= 0
    )).

% proximoNumeroPoderoso(+X,-Y)
proximoNumeroPoderoso(X,P) :-
    P is X+1,
    numeroPoderoso(P).
proximoNumeroPoderoso(X,Y) :-
    Z is X+1,
    not(numeroPoderoso(Z)),
    proximoNumeroPoderoso(Z,Y).

% Ejercicio 23 ---------------------------------------

% i) ---

% arbol(-A)
arbol(A) :- desde(0, N), arbolNNodos(N, A).

% arbolNNodos(+N, -A)
arbolNNodos(0, nil).
arbolNNodos(N, bin(AI, _, AD)) :-
    N > 0,
    M is N-1,
    between(0, M, NI),
    ND is N-1-NI,
    arbolNNodos(NI, AI),
    arbolNNodos(ND, AD).

% ii) ---

% nodosEn(?A, +L)
nodosEn(nil, _).
nodosEn(bin(AI, V, AD), L) :-
    member(V, L),
    nodosEn(AI, L),
    nodosEn(AD, L).

% iii) ---

% sinRepEn(-A, +L)
sinRepEn(A, L) :-
    % GENERATE
    length(L, MaxN),        % cant. de nodos acotada por cant. de elemenos de L
    between(0, MaxN, N),    % para cada posible cantidad de nodos distintos:
    arbolNNodos(N, A),      % genero todos los posibles árboles, con nodos vacios
    nodosEn(A, L),          % le seteo como nodos los elementos de L, incluyendo repetidos
    % TEST
    nodos(A, ListaNodos),   % obtengo los nodos del arbol y
    sinReps(ListaNodos).    % filtro los arboles sin nodos repetidos 

% nodos(+A, -L)
nodos(nil, []).
nodos(bin(AI, V, AD), [V | L]) :-
    nodos(AI, LI),
    nodos(AD, LD),
    append(LI, LD, L).

% sinReps(+L)
sinReps([]).
sinReps([X | XS]) :-
    not(member(X, XS)),
    sinReps(XS).