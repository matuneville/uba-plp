# Práctica 8 - Programación lógica

## El motor de búsqueda de Prolog

### Ejercicio 1

Considerar la siguiente base de conocimiento.

```prolog
padre(juan, carlos).
padre(juan, luis).
padre(carlos, daniel).
padre(carlos, diego).
padre(luis, pablo).
padre(luis, manuel).
padre(luis, ramiro).
abuelo(X,Y) :- padre(X,Z), padre(Z,Y).
```

#### i. Cuál el resultado de la consulta `abuelo(X, manuel)`?

- Consulta:
    ```prolog
    ?- abuelo(X, manuel).
    X = juan ;
    false.
    ```

#### ii. A partir del predicado binario padre, definir en Prolog los predicados binarios: hijo, hermano y descendiente.

- Cláusulas:

    ```plprolog
    % X es hijo de Y
    hijo(X,Y) :- padre(Y,X).

    % X es hermano de Y
    hermano(X,Y) :- padre(Z,X), padre(Z,Y), X \= Y.

    % X es descendiente de Y
    descendiente(X,Y) :- padre(Y,X).
    descendiente(X,Y) :- padre(Y,Z), descendiente(X,Z).
    ```

#### iii. Dibujar el árbol de búsqueda de Prolog para la consulta descendiente(Alguien, juan).

```text
descendiente(Alguien, juan)
├── [C1] padre(juan, Alguien)
│   ├── Alguien = carlos ---> ÉXITO
│   └── Alguien = luis   ---> ÉXITO
│
└── [C2] padre(juan, Z), descendiente(Alguien, Z)
    ├── Z = carlos ---> descendiente(Alguien, carlos)
    │   ├── [C1] padre(carlos, Alguien)
    │   │   ├── Alguien = daniel ---> ÉXITO
    │   │   └── Alguien = diego  ---> ÉXITO
    │   └── [C2] padre(carlos, Z2), descendiente(Alguien, Z2)
    │       ├── Z2 = daniel ---> descendiente(Alguien, daniel) ---> padre(daniel, _) ---> FALLO
    │       └── Z2 = diego  ---> descendiente(Alguien, diego)  ---> padre(diego, _)  ---> FALLO
    │
    └── Z = luis ---> descendiente(Alguien, luis)
        ├── [C1] padre(luis, Alguien)
        │   ├── Alguien = pablo  ---> ÉXITO
        │   ├── Alguien = manuel ---> ÉXITO
        │   └── Alguien = ramiro ---> ÉXITO
        └── [C2] padre(luis, Z2), descendiente(Alguien, Z2)
            └── Z2 ∈ {pablo, manuel, ramiro} ---> padre(Z2, _) ---> FALLO
```

#### iv. ¿Qué consulta habría que hacer para encontrar a los nietos de juan?

- 
    ```prolog
    abuelo(juan, X).
    ```

#### v. ¿Cómo se puede definir una consulta para conocer a todos los hermanos de pablo?

- 
    ```prolog
    hermano(pablo, X).
    ```

#### vi. Considerar el agregado del siguiente hecho y regla:

```prolog
ancestro(X, X).
ancestro(X, Y) :- ancestro(Z, Y), padre(X, Z).
```
y la base de conocimiento del ítem anterior.

#### vii. Explicar la respuesta a la consulta `ancestro(juan, X)`. ¿Qué sucede si se pide más de un resultado?

- 
    ```prolog
    ?- ancestro(juan, X).
    X = juan ;
    X = carlos ;
    X = luis ;
    X = daniel ;
    X = diego ;
    X = pablo ;
    X = manuel ;
    X = ramiro ;
    ^C^C
    ```

- Al ejecutar la consulta y pedir soluciones sucesivas mediante el operador de *backtracking* (`;`), se observan los siguientes comportamientos en el árbol de búsqueda SLD:

    1. **Primera solución**:
    Unifica directamente con el caso base `ancestro(X, X)` haciendo `X = juan`.
        - Resultado: `X = juan.`

    2. **Hijos** (`carlos`, `luis`):
    Al forzar *backtracking*, ingresa a la regla recursiva:
    `ancestro(juan, X) :- ancestro(Z1, X), padre(juan, Z1)`.
        - Resuelve el primer literal del cuerpo (de izq. a der.): `ancestro(Z1, X)`.
        - Entra en caso base: unifica `ancestro(Z1, X)` con `ancestro(X', X')`, concluyendo `X = Z1`; pasa a evaluar `padre(juan, Z1)`.
        - `padre(juan, Z1)` unifica con los hechos, produciendo:
            - `X = carlos.`
            - `X = luis.`

    3. **Nietos** (`daniel`, `diego`, `pablo`, `manuel`, `ramiro`):
    Al pedir más soluciones con `;`, vuelve a desplegar `ancestro(Z1, X)` aplicando la regla recursiva:
    `ancestro(Z1, X) :- ancestro(Z2, X), padre(Z1, Z2)`.
    La meta pasa a ser: `ancestro(Z2, X), padre(Z1, Z2), padre(juan, Z1)`.
        - Resuelve el primer literal `ancestro(Z2, X)` unificándolo con el caso base, concluyendo `X = Z2`.
        - Pasa a evaluar los literales restantes `padre(Z1, Z2), padre(juan, Z1)` con los hechos de la base de datos, produciendo:
            - Para `Z1 = carlos`: `padre(carlos, Z2)` genera `X = daniel` y `X = diego`.
            - Para `Z1 = luis`: `padre(luis, Z2)` genera `X = pablo`, `X = manuel` y `X = ramiro`.

    4. **Cuelgue (recursión infinita a la izquierda)**:
    Al solicitar otra solución, intenta desplegar `ancestro(Z2, X)` mediante la regla recursiva:
    `ancestro(Z2, X) :- ancestro(Z3, X), padre(Z2, Z3).`
    generando la meta: `ancestro(Z3, X), padre(Z2, Z3), padre(Z1, Z2), padre(juan, Z1)`.
        - En el caso base, unifica `ancestro(Z3, X)` con `ancestro(X', X')`, lo que concluye `X = Z3`.
        - Pasa a los literales restantes (cadena de padre): Quedan pendientes de resolver: `padre(Z2, Z3), padre(Z1, Z2), padre(juan, Z1)`.
            - Para satisfacer esto, `Z3` debe ser hijo de `Z2`.
            - Al intentar resolver `padre(Z2, Z3)` para cualquier nieto `Z2`, **falla**, porque ningún nieto tiene hijos en la base de hechos.
        - Al fallar la cadena de `padre`, Prolog retrocede (*backtracking*) a la última decisión tomada: `ancestro(Z3, X)`.
        - Prolog pregunta: *"¿Tengo otra regla para resolver* `ancestro(Z3, X)` *que no sea el caso base?"*
            - Sí: la Cláusula 2 (`ancestro(Z3, X) :- ancestro(Z4, X), padre(Z3, Z4)`).
        - Al aplicar la Cláusula 2 sobre `ancestro(Z3, X)`, la nueva meta pasa a ser: `ancestro(Z4, X), padre(Z3, Z4), padre(Z2, Z3), padre(Z1, Z2), padre(juan, Z1)`
        - Sigue así con `Z4`, `Z5`, etc.
        - Como el subobjetivo `ancestro(Z_n, X)` está a la izquierda y contiene variables libres, se genera una rama infinitamente profunda en el árbol SLD sin evaluar los fallos de la derecha, provocando el cuelgue por recursión infinita.

#### viii. Sugerir una solución al problema hallado en los puntos anteriores reescribiendo el programa de ancestro.

- Para solucionar la recursión infinita y asegurar que el espacio de búsqueda sea finito, se debe garantizar que el subobjetivo que acota el dominio (`padre/2`) se evalúe **antes** que la llamada recursiva. De este modo, la variable intermedia se instancia previamente.

- 
    ```prolog
    ancestro(X, X).
    ancestro(X, Y) :- padre(X, Z), ancestro(Z, Y).
    ```

    1. Al ubicar `padre(X, Z)` como primer literal del cuerpo en la regla recursiva, Prolog reduce inmediatamente el espacio de búsqueda a los hijos directos de `X` presentes en la base de hechos.
    2. La llamada inductiva `ancestro(Z, Y)` se realiza con el primer argumento `Z` debidamente instanciado, recorriendo el árbol genealógico de manera descendente hasta agotar las ramas y finalizando con un fallo finito al no encontrar más descendientes.

---

### Ejercicio 3

Considerar las siguientes definiciones:

```prolog
natural(0).
natural(suc(X)) :- natural(X).

menorOIgual(X, suc(Y)) :- menorOIgual(X, Y).
menorOIgual(X,X) :- natural(X).
```

#### i. Explicar qué sucede al realizar la consulta `menorOIgual(0,X)`.

- La consulta entra en una **recursión infinita a la izquierda** y se cuelga sin devolver ninguna solución.

    1. Prolog unifica el goal `menorOIgual(0, X)` con la cabeza de la primera regla `menorOIgual(X1, suc(Y1))` fijando `X = suc(Y1)` y `0 = X1`.
    2. Se genera el nuevo goal `menorOIgual(0, Y1)`.
    3. Al evaluarlo, vuelve a seleccionar la primera regla, generando `menorOIgual(0, Y2)` con `Y1 = suc(Y2)`.
    4. El motor continúa creando infinitos envoltorios `suc(...)` sobre la variable libre sin llegar jamás a la segunda cláusula (`menorOIgual(X, X)`), profundizando indefinidamente por la rama izquierda del árbol de búsqueda SLD.

#### ii. Describir las circunstancias en las que puede colgarse un programa en Prolog. Es decir, ejecutarse infinitamente sin arrojar soluciones.

- Un programa en Prolog entra en una ejecución infinita cuando el árbol de búsqueda SLD posee una rama de profundidad infinita a la izquierda por la cual el motor de inferencia (estrategia DFS de izquierda a derecha) desciende sin alcanzar la cláusula vacía ($\square$) ni generar un fallo finito . Las causas principales son:

    1. Falta de reducción estructural: la llamada recursiva no reduce el tamaño o complejidad del argumento ni acota las variables libres sobre la base de conocimientos.
    2. Orden de cláusulas y literales: ubicar la regla recursiva antes de los casos base o colocar la llamada recursiva como el primer literal a la izquierda del cuerpo (recursión infinita a la izquierda).

#### iii. Corregir la definición de menorOIgual para que funcione adecuadamente.

- La corrección más simple es cambiar el orden de las líneas, lo cual permite hacer `menorOIgual(0,X)`:
    ```prolog
    menorOIgual(X,X) :- natural(X).
    menorOIgual(X, suc(Y)) :- menorOIgual(X, Y).
    ````
---

### Ejercicio 4

Definir el predicado `juntar(?Lista1, ?Lista2, ?Lista3)`, que tiene éxito si `Lista3` es la concatenación de `Lista1` y `Lista2`. Por ejemplo:

```
?- juntar([a,b,c], [d,e], [a,b,c,d,e]). → true.
?- juntar([a,b,c], [d,e], L).           → L = [a,b,c,d,e].
?- juntar([a,b,c], L, [a,b,c,d,e]).     → L = [d,e].
?- juntar(L, [d,e], [a,b,c,d,e]).       → L = [a,b,c].
?- juntar(L1, L2, [1,2,3]).             →
    L1 = [], L2 = [1, 2, 3]; L1 = [1], L2 = [2, 3];
    L1 = [1,2], L2 = [3]; L1 = [1,2,3], L2 = [].
```

Al igual que la mayoría de los predicados, puede dar false después de agotar los resultados.  
*Nota: este predicado ya está definido en prolog con el nombre append.*

- Solución:
    ```prolog
    % juntar(?L1, ?L2, ?L3)
    juntar([], L2, L2).
    juntar([X | XS], L2, [X | L3]) :- juntar(XS, L2, L3).
    ```

    1. **Caso base (`juntar([], L2, L2).`):** Establece inductivamente que la concatenación de la lista vacía `[]` con cualquier término `L2` da como resultado idénticamente `L2`.

    2. **Paso recursivo (`juntar([X | XS], L2, [X | L3]) :- juntar(XS, L2, L3).`):** Descompone la primera lista mediante la unificación `[X | XS]` y se usa la cabeza `X` para el primer elemento de la lista resultante. La relación se resuelve recursivamente sobre la cola `XS`, la lista `L2` y la cola del resultado `L3`.

    - Esta implementación satisface la especificación del predicado (`?Lista1, ?Lista2, ?Lista3`), garantizando reversibilidad completa sobre cualquiera de sus tres argumentos.
 
---

### Ejercicio 5
Definir los siguientes predicados sobre listas usando append:

#### i. last(?L, ?U), donde U es el último elemento de la lista L.

- 
    ```prolog
    % last(?L, ?U)
    last(L, U) :- append(_, [U], L), 
    ```

#### ii. reverse(+L, ?R), donde R contiene los mismos elementos que L, pero en orden inverso.
*Ejemplo: reverse([a,b,c], [c,b,a]).*  
*Mostrar el árbol de búsqueda para el ejemplo dado.*

-
    ```prolog
    % reverse(+L, ?R)
    reverse([], []).
    reverse([X | XS], R) :- reverse(XS, RS), append(RS, [X], R).
    ```

#### iii. prefijo(?P, +L), donde P es prefijo de la lista L.

- 
    ```prolog
    %prefijo(?P, +L)
    prefijo(P, L) :- append(P, PS, L).
    ```

#### iv. sufijo(?S, +L), donde S es sufijo de la lista L.

- 
    ```prolog
    % sufijo(?S, +L)
    sufijo(S, L) :- append(_, S, L).
    ```

#### v. sublista(?S, +L), donde S es sublista de L.

- 
    ```prolog
    % sublista(?S, +L)
    sublista(S, L) :- append(_, S, L), append(S, _, L).
    ```

#### vi. pertenece(?X, +L), que es verdadero sii el elemento X se encuentra en la lista L.
*(Este predicado ya viene definido en Prolog y se llama member).*

- 
    ```prolog
    % pertenece(?X, +L)
    pertenece(X, L) :- append(_, [X | _], L).
    ```

---

### Ejercicio 7

Definir los siguientes predicados, usando `member` y/o `append` según sea conveniente:

#### i) `intersección(+L1, +L2, -L3)`, tal que `L3` es la intersección sin repeticiones de las listas `L1` y `L2`, respetando en `L3` el orden en que aparecen los elementos en `L1`. Y `partir(N, L, L1, L2)`, donde `L1` tiene los `N` primeros elementos de `L`, y `L2` el resto. Si `L` tiene menos de `N` elementos el predicado debe fallar. ¿Cuán reversible es este predicado? Es decir, ¿qué parámetros pueden estar indefinidos al momento de la invocación?



#### ii) `borrar(+ListaOriginal, +X, -ListaSinXs)`, que elimina todas las ocurrencias de `X` de la lista `ListaOriginal`.

#### iii) `sacarDuplicados(+L1, -L2)`, que saca todos los elementos duplicados de la lista `L1`.

#### iv) `permutación(+L1, ?L2)`, que tiene éxito cuando `L2` es permutación de `L1`. ¿Hay una manera más eficiente de definir este predicado para cuando `L2` está instanciada?

#### v) `reparto(+L, +N, -LListas)` que tenga éxito si `LListas` es una lista de `N` listas (`N ≥ 1`) de cualquier longitud - incluso vacías - tales que al concatenarlas se obtiene la lista `L`.

#### vi) `repartoSinVacías(+L, -LListas)` similar al anterior, pero ninguna de las listas de `LListas` puede ser vacía, y la longitud de `LListas` puede variar.