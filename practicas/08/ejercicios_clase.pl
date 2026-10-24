% iseimo(+I, +L, -X)
% iesimo(0, [H | _], H).
% iesimo(I, [_ | T], X) :- I2 is I-1, iesimo(I2, T, X). % no puedo hacer iesimo(I-1, T, X).
% no tiene I reversible (no instanciado)
% ya que primero hace I-1, pero no sabe si I es un número o qué y pide instanciarlo

% con I reversible
% iseimo(-I, +L, -X)

% iesimo(I, L, X) :- append(L1, [X | _], L), length(L1, I).
iesimo(0, [H | _], H).
% primero descubre que I2 es un numero, entonces despues puede hacer el +
iesimo(I, [_ | T], X) :- iesimo(I2, T, X), I is I2+1.

% el unico meta-predicado que se puede usar es NOT
% un meta-predicado es aquel que toma términos como argumentos. 
% Ejemplo: not(es_primo(N))

% ---

% desde(+X, +Y)
desde(X, X).
desde(X, Y) :- N is X+1, desde(N, Y).

% desdeReversible(+X, ?Y)
desdeReversible(X, X).
desdeReversible(X, Y) :- var(Y), desde(X, Y).
desdeReversible(X, Y) :- nonvar(Y), X =< Y.

% ---

% pmq(+X, -Y): naturales pares Y menores o iguales que X
% pmq(X, Y) :- Resto is Y mod 2, Resto =:= 0, X =< Y.
pmq(X, Y) :- between(0, X, Y), Y mod 2 =:= 0.

% ---

coprimos(X, Y) :-
    % desde(1, X), desde(1, Y), gcd(X, Y) =:= 1.
    desde(1, N), between(1, N, X), Y is N-X, gcd(X, Y) =:= 1.

% ---

% corteMasParejo(+L, -L1, -L2, -D)
corteMasParejo(L, L1, L2, Dif) :-
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

% ---

primo(N) :- not((M is N-1, between(2, M, D), N mod D =:= 0)).

% próximoPrimo(+N, -P)
próximoPrimo(N, M) :- M is N+1, primo(M).
próximoPrimo(N, P) :- M is N+1, not(primo(M)), próximoPrimo(M,P).

% ---

esTriangulo(tri(A,B,C)) :- A < B+C, B < A+C, C < B+A.

% perimetro(?T, ?P)

/*

% -T, -P
perimetro(tri(A,B,C), P) :-
    desde(3,P),
    triplaQueSuma(P, A, B, C),
    esTriangulo(tri(A, B, C)).

el desde(X,Y) toma -Y, sin instanciar, asi que anda bien acá ya que -P.
pero si queremos +P o ?P, debemos usar desdeReversible(X, Y).

% -T, ?P
perimetro(tri(A,B,C), P) :-
    desdeReversible(3,P),
    triplaQueSuma(P, A, B, C),
    esTriangulo(tri(A, B, C)).

para +T, -P no vale, ya que, por más que encuentre el P que suma los
lados del T instanciado, luego seguirá buscando con el desdeReversible 
más P, inifinitamente.

% -T, ?P
perimetro(tri(A,B,C), P) :-
    TODO.

*/

% +T, ?P
perimetro(tri(A,B,C), P) :-
    ground(tri(A,B,C)),
    P is A+B+C, 
    esTriangulo(tri(A,B,C)).



% triplaQueSuma(+P, -A, -B, -C)
triplaQueSuma(P, A, B, C) :-
    between(1, P, A),
    P2 is P-A,
    between(1, P2, B),
    C is P2-B.


% ---

% triangulo(-T)
triangulo(T) :- perimetro(T, _).