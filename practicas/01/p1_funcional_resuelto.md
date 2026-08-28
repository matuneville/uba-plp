# Guía 1: Programación Funcional

## Currificación y Tipos

> ### Tipos
> Un tipo es una especificación del invariante de un dato o de una función.
> **Ejemplo:**
> - `99 :: Int`
> - `not :: Bool -> Bool`
> - `not True :: Bool`
> - `(+) :: Int -> (Int -> Int)`
> - `(+) 1 :: Int -> Int`
> - `((+) 1) 2 :: Int`
> - `f :: a -> a`  
> El tipo de una función expresa un contrato.


> ### Currificación
> La currificación es la idea de que una función de varios argumentos se representa como una secuencia de funciones de un solo argumento.
>
> #### Función currificada
> - `suma :: Int -> Int -> Int`
> - `suma x y = x + y`
>
> En Haskell, **todas** las funciones toman 1 solo argumento, y se van pasando de a 1.
>
> `suma 1` devuelve una función: `suma 1 :: Int -> Int`
>
> #### Función no currificada (usa tupla)
> - `suma' :: (Int, Int) -> Int`
> - `suma' (x, y) = x + y`
>
> Acá no podés hacer aplicación parcial directamente (`suma' 1` no tiene sentido).


### Ejercicio 1

#### i. Cuál es el tipo de cada función? (Suponer que todos los números son de tipo Float).  

#### ii. Indicar cuáles de las funciones anteriores no están currificadas. Para cada una de ellas, definir la función currificada correspondiente. Recordar dar el tipo de la función.

#### Solución

1. `max2 :: (Float, Float) -> Float`
    - No está currificada, ya que recibe los argumentos empaquetados en tupla.
    - Versión currificada:
        ```hs
        max2_curr :: Float -> Float -> Float
        max2_curr x y
            | x >= y    = x
            | otherwise = y
        ```

2. `normaVectorial :: (Float, Float) -> Float`
    - No está currificada
    - Versión currificada:
        ```hs
        normaVectorial_curr :: Float -> Float -> Float
        normaVectorial_curr x y = sqrt (x^2 + y^2)
        ```

3. `subtract :: Float -> Float -> Float`
    - Está currificada
    - `subtract = flip (-)`
    - (-) tiene tipo `Float -> Float -> Float`, y flip intercambia los dos primeros argumentos. 
    - Resultado: `subtract x y = flip (-) x y = (-) y x = y - x`.

4. `predecesor :: Float -> Float`
    - Está currificada
    - `predecesor = subtract 1`
    - Es subtract aplicacado parcialmente con 1:
        ```hs
        predecesor x = subtract 1 x   -- explícita
        predecesor   = subtract 1     -- por aplicación parcial (point-free)
        ```
    - Resultado: `predecedor x = subtract 1 x = x - 1`

5. `evaluarEnCero :: (Float -> a) -> a`
    - Está currificada
    - Recibe una función que recibe un `Float` y devuelve algo de tipo `a`, y luego devuelve algo de tipo `a`.
    - `evaluarEnCero = \f -> f 0` usa una lambda que recibe `f`y devuelve `f`aplicada en 0.
        ```hs
        -- Son lo mismo:
        evaluarEnCero = \f -> f 0   -- f está "dentro" de la lambda
        evaluarEnCero f = f 0       -- f está explícita a la izquierda

        -- En los dos casos Haskell entiende que hay un argumento esperando,
        ```

6. `dosVeces :: (a -> a) -> a -> a`
    - Está currificada
    - `dosVeces = \f -> f . f` aplica `f` dos veces, y debe ser `a -> a` para poder componerse consigo misma.

7. `flipAll :: [a -> b -> c] -> [b -> a -> c]`
    - Está currificada
    - `flipAll = map flip` , y map lo aplica a cada elemento de una lista de funciones.

    ---

### Ejercicio 2

#### i. Definir la función `curry`, que dada una función de dos argumentos, devuelve su equivalente currificada.


#### ii. Definir la función `uncurry`, que dada una función currificada de dos argumentos, devuelve su versión no currificada equivalente. Es la inversa de la anterior.


#### iii. Se podría definir una función `curryN`, que tome una función de un número arbitrario de argumentos y devuelva su versión currificada? (Sugerencia: pensar cuál sería el tipo de la función).

#### Solución

#### i) y ii)
- 
    ```hs
    -- a) ---

    curry' :: ((a, b) -> c) -> a -> b -> c
    curry' f x y = f (x, y)

    -- b) ---

    uncurry' :: (a -> b -> c) -> (a, b) -> c
    uncurry' f (x, y) = f x y
    ```
- 
    ```hs
    ghci> maxCurried 3 5
    5
    ghci> maxUncurried (3, 5)
    5
    ghci> curry' maxUncurried 3 5
    5
    ghci> uncurry' maxCurried (3, 5)
    5
    ```

#### iii)

- 
    No se puede definir de forma general en Haskell. El problema está en el tipo: una función de 2 argumentos, 3 argumentos y 4 argumentos tienen tipos completamente distintos:
    ```hs
    (a, b) -> c
    (a, b, c) -> d
    (a, b, c, d) -> e
    ...
    ```

    No hay forma de escribir un único tipo que capture "tupla de n elementos" para cualquier n, porque en Haskell **las tuplas de distinto tamaño son tipos distintos** y el sistema de tipos es estático, Haskell necesita saber en tiempo de compilación cuantós argumentos tiene la función.

    ```hs
    curry  :: ((a, b) -> c)         -> a -> b -> c
    curry3 :: ((a, b, c) -> d)      -> a -> b -> c -> d
    curry4 :: ((a, b, c, d) -> e)   -> a -> b -> c -> d -> e
    ```

    Se podría definir `curry3`, `curry4`, etc. por separado, pero una `curryN` arbitrario no es posible.  

    No existe en Haskell un tipo como `(tupla de n elementos -> c) -> arg1 -> arg2 -> ... -> argN -> c` para n arbitrario.

---

### Ejercicio 4

#### Definir la lista infinita `paresDeNat::[(Int,Int)]`, que contenga todos los pares de números naturales: (0,0), (0,1), (1,0), etc.


- 
    ```hs
    paresDeNat :: [(Int,Int)]
    paresDeNat = [(x,y) | s <- [0..], x <- [0..s], let y = s - x]
    ```

- 
    ```hs
    ghci> take 10 $ paresDeNat 
    [(0,0),(0,1),(1,0),(0,2),(1,1),(2,0),(0,3),(1,2),(2,1),(3,0)]
    ```


### Ejercicio 6 📝 TODO

Escribir la función `listasQueSuman :: Int -> [[Int]]` que, dado un número natural n, devuelve todas las listas de enteros positivos (es decir, mayores o iguales que 1) cuya suma sea n. Para este ejercicio se permite usar recursión explícita. Pensar por qué la recursón utilizada no es estructural. (Este ejercicio no es de generación infinita, pero puede ser útil para otras funciones que generen listas infinitas de listas).

### Ejercicio 7 📝 TODO

Definir en Haskell una lista que contenga todas las listas finitas de enteros positivos (esto es, con elementos mayores o iguales que 1).

---
---

## Esquemas de Recursión

> `foldr` recorre una lista y va acumulando un resultado aplicando una función a cada elemento. Su tipo es:
> ```hs
> foldr :: (a -> b -> b) -> b -> [a] -> b
> ```
> donde:
> - El primer argumento es la función que combina cada elemento con el acumulador
> - El segundo es el valor inicial (caso base)
> - El tercero es la lista
>
> ```hs
> -- ejecución mental
> foldr (+) 0 [1,2,3,4] = 
> 1 + (2 + (3 + (4 + 0)))
> = 1 + (2 + (3 + 4))
> = 1 + (2 + 7)
> = 1 + 9
> = 10
> ```
>
> `foldl` en cambio: 
> 
> ```hs
> foldl (+) 0 [1,2,3,4] = 
> ((((0 + 1) + 2) + 3) + 4)
> = (((1 + 2) + 3) + 4)
> = ((3 + 3) + 4)
> = (6 + 4)
> = 10
> ```

### Ejercicio 8

#### i. Definir utilizando map y filter:
1. Una función que dada una lista de palabras devuelve una lista con aquellas que tienen menos de 5 letras.
2. Una función que dada una lista de notas devuelve una lista de booleanos que indiquen si la nota está aprobada (es mayor a 6).
3. Una función que dada una lista de números devuelve una lista que contiene solo los números pares elevados al cuadrado.

- 
    ```hs
    palabrasCortas :: [String] -> [String]
    palabrasCortas = filter esCorta
        where
            esCorta = \s -> length s < 5

    notasAprobadas :: [Int] -> [Bool]
    notasAprobadas = map esAprobada
        where
            esAprobada = \n -> n >= 6

    numerosParesAlCuadrado :: [Int] -> [Int]
    numerosParesAlCuadrado = map alCuadrado . filter esPar
    -- numerosParesAlCuadrado xs = map alCuadrado $ filter esPar xs
    -- numerosParesAlCuadrado xs = map alCuadrado (filter esPar xs)
        where
            esPar = \n -> n `mod` 2 == 0
            alCuadrado = \n -> n * n
    ```

#### ii. Redefinir usando `foldr` las funciones `sum`, `elem`, `(++)`, `filter` y `map`.

1. 
    ```hs
    sum' :: [Float] -> Float
    sum' = foldr (+) 0
    ```

2. 
    ```hs
    elem' :: (Eq a) => a -> [a] -> Bool
    elem' x = foldr (\y acc -> y == x || acc) False
    
    -- Por cada elemento y pregunta si es igual a x, el caso base es False.  
    -- Ejemplo:  
    
    -- elem' 3 [1, 2, 3]
    -- = foldr (\y acc -> y == 3 || acc) False [1, 2, 3]
    -- = (1 == 3 || (2 == 3 || (3 == 3 || False)))
    -- = (False   || (False   || (True   || False)))
    -- = True
    ```

3.
    ```hs
    (+++) :: [a] -> [a] -> [a]
    (+++) xs ys = foldr (:) ys xs

    -- Ejemplo: 
    -- [1, 2] +++ [3, 4]
    -- = foldr (:) [3, 4] [1, 2]
    -- = (:) 1 ((:) 2 [3, 4])
    -- = (:) 1 (2 : [3, 4])
    -- = (:) 1 [2, 3, 4]
    -- = 1 : [2, 3, 4]
    -- = [1, 2, 3, 4]
    ```

4.
    ```hs
    filter' :: (a -> Bool) -> [a] -> [a]
    filter' p = foldr (\x acc -> if p x then x : acc else acc) []
    ```

5.
    ```hs
    map' :: (a -> b) -> [a] -> [b]
    map' f = foldr (\x acc -> f x : acc) []
    ```

#### iii. Definir la función `mejorSegún :: (a -> a -> Bool) -> [a] -> a`, que devuelve el máximo elemento de la lista según una función de comparación, utilizando `foldr1`. Por ejemplo, `maximum = mejorSegún (>)`.

- 
    > `foldr1` es igual a `foldr` pero no necesita caso base, usa el último elemento de la lista como valor inicial. Su tipo es:
    > ```hs
    > foldr1 :: (a -> a -> a) -> [a] -> a
    > ```

    ```hs
    mejorSegun :: (a -> a -> Bool) -> [a] -> a
    mejorSegun f xs = foldr1 (\x acc -> if f x acc then x else acc) xs

    -- Ejemplo
    -- mejorSegun (>) [1, 3, 2]
    -- = foldr1 (\x acc -> if x > acc then x else acc) [1, 3, 2]
    -- y esto lo resuelve como
    -- f 1 (f 3 2) = f 1 3 = 3
    -- donde f es la lambda

    -- primero le pasa 3 y 2 (x = 3, acc = 2)
    -- = (\x acc -> if x > acc then x else acc) 3 2
    -- = if 3 > 2 then 3 else 2
    -- = 3

    -- luego le pasa 1 y el resultado anterior (x = 1, acc = 3)
    -- = (\x acc -> if x > acc then x else acc) 1 3
    -- = if 1 > 3 then 1 else 3
    -- = 3
    ```

#### iv. Definir la función `sumasParciales :: Num a => [a] -> [a]`, que dada una lista de números devuelve otra de la misma longitud, que tiene en cada posición la suma parcial de los elementos de la lista original desde la cabeza hasta la posición actual. Por ejemplo, `sumasParciales [1,4,-1,0,5] = [1,5,4,4,9]`.

-
    ```hs
    sumasParciales :: Num a => [a] -> [a]
    sumasParciales xs = tail (foldl (\acc x -> acc ++ [x + (last acc)]) [0] xs)

    sumasParciales' :: Num a => [a] -> [a]
    sumasParciales' xs = tail (scanl (+) 0 xs)
    ```

#### v. Definir la función `sumaAlt`, que realiza la suma alternada de los elementos de una lista. Es decir, da como resultado: el primer elemento, menos el segundo, más el tercero, menos el cuarto, etc. Usar `foldr`.

- 
    ```hs
    -- El truco está en ver que:
    --
    -- Dado [2 1 3 4],
    -- 2 - 1 + 3 - 4 = 
    -- = 2 - 1 + 3 - 4
    -- = 2 - (1 - 3 + 4)
    -- = 2 - (1 - (3 - 4))

    sumaAlt :: [Int] -> Int
    sumaAlt xs = foldr1 (-) xs
    ```

#### vi. Hacer lo mismo que en el punto anterior, pero en sentido inverso (el último elemento menos el anteúltimo, etc.). Pensar qué esquema de recursión conviene usar en este caso.

- 
    ```hs
    -- Dado [1 2 3 4],
    -- (4 - 3 + 2 - 1) = 
    -- = 4 - (3 - 2 + 1)
    -- = 4 - (3 - (2 - 1))

    sumaAltInversa :: [Int] -> Int
    sumaAltInversa xs = foldl1 (flip (-)) xs
    -- con flip (-) hace x-acc en vez de acc-x
    ```

    ---

> ### Tipos de recursión
>
> #### 1. Recursión estructural
> Siempre se hace recursión sobre una **parte estrictamente más pequeña** de la original. En listas, cada llamado recursivo usa la **cola** (`xs`) de la lista original, **sin modificarla**.
>
> ```haskell
> -- estructural: siempre se llama con xs, la cola de (x:xs)
> f [] = ...
> f (x:xs) = ... f xs ...
> ```
>
> Se resuelven con `foldr`:
>
> ```hs
> foldr :: (a -> b -> b) -> b -> [a] -> b
> foldr f z []     = z
> foldr f z (x:xs) = f x (foldr f z xs)
> ```
>
>
> #### 2. Recursión primitiva
> Caso especial de estructural donde además de la cola `xs`, se tiene acceso al **resultado de la llamada recursiva**. Es la que modela `foldr`.
>
> ```haskell
> -- primitiva: usa xs y también el resultado recursivo
> f [] = ...
> f (x:xs) = ... x ... (f xs) ...
> ```
>
> Se resuelven con `recr`:
>
> ```hs
> recr :: (a -> [a] -> b -> b) -> b -> [a] -> b
> recr _ z []       = z
> recr f z (x : xs) = f x xs (recr f z xs)
> ```
>
> #### 3. Recursión global (general)
> No hay restricción sobre el argumento de la llamada recursiva. Si la estructura original es **modificada** antes de pasarla (por ejemplo con `tail xs`), entonces no cumple recursión estructural y es global.
>
> ```haskell
> -- global: se llama con tail xs, que modifica la estructura original
> f (x:xs) = ... f (tail xs) ...
> ```

### Ejercicio 10

#### El siguiente esquema captura la recursión primitiva sobre listas.

```hs
recr :: (a -> [a] -> b -> b) -> b -> [a] -> b
recr _ z [] = z
recr f z (x : xs) = f x xs (recr f z xs)
```

#### a. Definir la función `sacarUna :: Eq a => a -> [a] -> [a]`, que dados un elemento y una lista devuelve el resultado de eliminar de la lista la primera aparición del elemento (si está presente).

- Recursivo normal:
    ```hs
    sacarUna :: Eq a => a -> [a] -> [a]
    sacarUna _ [] = []
    sacarUna a (x:xs)
        | a == x = xs
        | otherwise = x : sacarUna a xs
    ```
- Usando `recr`:
    ```hs
    sacarUna' :: Eq a => a -> [a] -> [a]
    sacarUna' a xs = recr f z xs
        where
            z = []
            f x xs rec
                | x == a = xs
                | otherwise = x : rec
    ```

#### b. Explicar por qué el esquema de recursión estructural (foldr) no es adecuado para implementar la función sacarUna del punto anterior.

- El esquema de recursión `foldr` no es adecuado para implementar `sacarUna` porque la función que recibe solo tiene acceso al elemento actual y al resultado de la recursión sobre la cola, pero no a la cola original.

- En `sacarUna`, cuando se encuentra el elemento a eliminar, es necesario devolver la cola original sin procesar. Esto no puede hacerse con `foldr`, ya que la cola ya fue procesada en el resultado recursivo.

    - `foldr f z (x:xs) = f x (foldr f z xs)`: en cada paso, `f`recibe `x` y `acc`(resultado de procesar `xs`) pero no recibe `xs`.

- En cambio, el esquema `recr` sí permite acceder a la cola original (xs), lo que hace posible implementar correctamente la función.

    - `recr f z (x : xs) = f x xs (recr f z xs)`: en cada paso, `f` recibe también `xs`

#### c. Definir la función `insertarOrdenado :: Ord a => a -> [a] -> [a]` que inserta un elemento en una lista ordenada (de manera creciente), de manera que se preserva el ordenamiento.

- 
    ```hs
    insertarOrdenado' :: Ord a => a -> [a] -> [a]
    insertarOrdenado' a ys = recr insertar z ys
        where
            z = [a]
            insertar x xs acc
                | a < x = a:x:xs
                | otherwise = x:acc
    ```

    ---

### Ejercicio 11

#### Indicar qué tipo de recursión se utiliza en cada una de las siguientes definiciones. Para los esquemas estructural y primitivo reescribir utilizando `recr` y `foldr`.

1. 
    ```hs
    elementosEnPosicionesPares :: [a] -> [a]
    elementosEnPosicionesPares [] = []
    elementosEnPosicionesPares (x:xs) =
        if null xs
        then [x]
        else x : elementosEnPosicionesPares (tail xs)
    ```

No es recursión estructural ni primitiva ya que al hacer ell lamado recursivo utiliza `tail xs`, descartando elementos de la cola entera, `xs`. Por esta modificación de la estructura original, decimos que es global.

2. 
    ```hs
    entrelazar :: [a] -> [a] -> [a]
    entrelazar [] = id
    entrelazar (x:xs) =
        \ys -> if null ys
            then x : entrelazar xs []
            else x : head ys : entrelazar xs (tail ys)
    ```

Sí es recursión estructural, ya que hace recursión sobre la cola `xs`. Si bien usa `tail ys`, eso no rompe la recursión estructural ya que `ys` no es el argumento estructural de la recursión, si no que es sólo un parámetro que no define casos base ni guía la recursión.
Hecha con `foldr`:

- 
    ```hs
    entrelazar' :: [a] -> [a] -> [a]
    entrelazar' =
        foldr
            (\x rec -> \ys -> if (null ys) then (x : rec []) else (x : head ys : rec (tail ys)))
            id
    ```

3. 
    ```hs
    slowSort :: Ord a => [a] -> [a]
    slowSort [] = []
    slowSort (p:xs) = slowSort menores ++ [p] ++ slowSort mayores
        where
            menores = [x | x <- xs, x <= p]
            mayores = [x | x <- xs, x > p]
    ```

Es global, ya que esta modificando la estructura original en el llamado recursivo al usar `mayores` y `menores`.

4. 
    ```hs
    sufijos :: [a] -> [[a]]
    sufijos [] = [[]]
    sufijos (x:xs) = (x:xs) : sufijos xs
    ``` 

Es primitiva ya que hace uso de la cola xs. Con recr:

- 
    ```hs
    sufijos' :: [a] -> [[a]]
    sufijos' = recr (\x xs rec -> (x : xs) : rec) [[]]
    -- sufijos = foldr (\x rec -> (x : head rec) : rec) [[]]
    ````



    ---

### Ejercicio 12

#### Definir las siguientes funciones para trabajar sobre listas, y dar su tipo. Todas ellas deben poder aplicarse a listas finitas e infinitas.

#### i. `mapPares`, una versión de `map` que toma una función currificada de dos argumentos y una lista de pares de valores, y devuelve la lista de aplicaciones de la función a cada par. Pista: recordar `curry` y `uncurry`.

-
    ```hs
    mapPares :: (a -> b -> c) -> [(a, b)] -> [c]
    mapPares _ [] = []
    mapPares f (x : xs) = uncurry f x : rec
    where
        rec = mapPares f xs

    mapPares' :: (a -> b -> c) -> [(a, b)] -> [c]
    mapPares' f = foldr (\x rec -> uncurry f x : rec) []
    ```
    - Funciona bien en listas infinitas:
        ```hs
        take 5 $ mapPares' (+) [(x,y) | x <- [1..], y <- [3..]]
        [4,5,6,7,8]
        ```

#### ii. `armarPares`, que dadas dos listas arma una lista de pares que contiene, en cada posición, el elemento correspondiente a esa posición en cada una de las listas. Si una de las listas es más larga que la otra, ignorar los elementos que sobran (el resultado tendrá la longitud de la lista más corta). Esta función en Haskell se llama `zip`. Pista: aprovechar la currificación y utilizar evaluación parcial.


-
    ```hs
    armarPares :: [a] -> [b] -> [(a, b)]
    armarPares [] = const []
    armarPares (x : xs) = \ys -> if null ys then [] else (x, head ys) : rec (tail ys)
    where
        rec = armarPares xs

    armarPares' :: [a] -> [b] -> [(a, b)]
    armarPares' =
    foldr
        (\x rec -> \ys -> if null ys then [] else (x, head ys) : rec (tail ys))
        (const [])
    ```

    - Funciona bien en listas infinitas:
        ```hs
        ghci> take 5 $ armarPares' [1..] [3..]
        [(1,3),(2,4),(3,5),(4,6),(5,7)]
        ```

#### iii. `mapDoble`, una variante de `mapPares`, que toma una función currificada de dos argumentos y dos listas (de igual longitud), y devuelve una lista de aplicaciones de la función a cada elemento correspondiente de las dos listas. Esta función en Haskell se llama `zipWith`.

- 
    ```hs
    ```

---
---

## Otras estructuras de datos

> En esta sección se permite (y se espera) el uso de recursión explícita únicamente para la definición de esquemas de recursión.

### Ejercicio 14

#### i. Definir y dar el tipo del esquema de recursión `foldNat` sobre los naturales. Utilizar el tipo `Integer` de Haskell (la función va a estar definida sólo para los enteros mayores o iguales que 0).

-
    ```hs
    foldNat :: (Int -> b -> b) -> b -> Int -> b
    foldNat _ z 0 = z
    foldNat f z n = f n (foldNat f z (n-1))
    ```

##### ii. Utilizando `foldNat`, definir la función `potencia`.

- 
    ```hs
    potencia :: Int -> Int -> Int
    potencia a 0 = 1
    potencia a b = a * rec
    where
        rec = potencia a (b - 1)

    potencia' :: Int -> Int -> Int
    potencia' a = foldNat (\n rec -> a * rec) 1
    ```

    ---

### Ejercicio 17 

Considerar el siguiente tipo, que representa a los árboles binarios:  
- `data AB a = Nil | Bin (AB a) a (AB a)`

#### i. Usando recursión explícita, definir los esquemas de recursión estructural (`foldAB`) y primitiva (`recAB`), y dar sus tipos.

- 
    ```hs
    {-
    recibe:
        - funcion caso Nil (caso base)
        - funcion caso SubArbol (caso recursivo) que recibe:
            - resultado recursivo sobre subarbol izquierdo
            - valor nodo
            - resultado recursivo sobre subarbol derecho
        - Arbol
    -}
    foldAB :: b -> (b -> a -> b -> b) -> AB a -> b
    foldAB fNil fSubAb ab = case ab of
    Nil -> fNil
    Bin izq n der -> fSubAb recIzq n recDer
        where
        recIzq = foldAB fNil fSubAb izq
        recDer = foldAB fNil fSubAb der
    ```

- 
    ```hs
    {-
    recibe:
        - funcion caso Nil (caso base)
        - funcion caso SubArbol (caso recursivo) que recibe:
            - subarbol izquierdo
            - subarbol derecho
            - resultado recursivo sobre subarbol izquierdo
            - valor nodo
            - resultado recursivo sobre subarbol derecho
        - Arbol
    -}
    recAB :: b -> (AB a -> AB a -> b -> a -> b -> b) -> AB a -> b
    recAB fNil fSubAb ab = case ab of
    Nil -> fNil
    Bin izq n der -> fSubAb izq der recIzq n recDer
        where
        recIzq = recAB fNil fSubAb izq
        recDer = recAB fNil fSubAb der
    ```

#### ii. Definir las funciones `esNil`, `altura` y `cantNodos` (para `esNil` puede utilizarse `case` en lugar de `foldAB` o `recAB`).

- 
    ```hs
    ```

#### iii. Definir la función `mejorSegún :: (a -> a -> Bool) -> AB a -> a`, análoga a la del ejercicio 3, para árboles. Se recomienda definir una función auxiliar para comparar la raíz con un posible resultado de la recursión para un árbol que puede o no ser Nil.

- 
    ```hs
    
    ```

#### iv. Definir la función `esABB :: Ord a => AB a -> Bool` que chequea si un árbol es un árbol binario de búsqueda. Recordar que, en un árbol binario de búsqueda, el valor de un nodo es mayor o igual que los valores que aparecen en el subárbol izquierdo y es estrictamente menor que los valores que aparecen en el subárbol derecho.

- 
    ```hs
    
    ```

#### v. Justificar la elección de los esquemas de recursión utilizados para los tres puntos anteriores.

- Para **esNil** no hace falta ningún esquema de recursión, porque solo distinguimos entre `Nil` y `Bin`. Con pattern matching alcanza.
- Para **altura** y **cantNodos** usamos **recursión estructural (`foldAB`)** porque:
    - solo necesitamos combinar resultados de los subárboles
    - no hace falta mirar la estructura original
    - en cada nodo usamos únicamente: resultado izquierdo, valor (a veces ni se usa), resultado derecho.

- Para **mejorSegunAB** usamos también recursión estructural (`foldAB`) porque:
    - queremos obtener un único valor a partir del árbol
    - en cada nodo alcanza con:
        - el mejor del subárbol izquierdo
        - el valor actual
        - el mejor del subárbol derecho
    - no necesitamos acceder a los subárboles originales

- Para **esABB** usamos **recursión primitiva (`recAB`)** porque:
    - necesitamos información de los subárboles **y también la estructura original**
    - en particular, tenemos que:
        - comparar la raíz con valores del subárbol izquierdo y derecho
        - eso requiere acceder a `izq` y `der`, no solo a `resIzq` y `resDer`
    - Con `foldAB` perderíamos esa información, o tendríamos que complicar el tipo resultado.