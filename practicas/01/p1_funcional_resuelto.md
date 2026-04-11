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

#### Testeado:
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
---

## Esquemas de Recursión

### Ejercicio 3

> `foldr` recorre una lista y va acumulando un resultado aplicando una función a cada elemento. Su tipo es:
> ```hs
> foldr :: (a -> b -> b) -> b -> [a] -> b
> ```
> donde:
> - El primer argumento es la función que combina cada elemento con el acumulador
> - El segundo es el valor inicial (caso base)
> - El tercero es la lista

#### i. Redefinir usando `foldr` las funciones `sum`, `elem`, `(++)`, `filter` y `map`.

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

#### ii. Definir la función `mejorSegún :: (a -> a -> Bool) -> [a] -> a`, que devuelve el máximo elemento de la lista según una función de comparación, utilizando `foldr1`. Por ejemplo, `maximum = mejorSegún (>)`.

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

#### iii. Definir la función `sumasParciales :: Num a => [a] -> [a]`, que dada una lista de números devuelve otra de la misma longitud, que tiene en cada posición la suma parcial de los elementos de la lista original desde la cabeza hasta la posición actual. Por ejemplo, `sumasParciales [1,4,-1,0,5] = [1,5,4,4,9]`.

-
    ```hs
    sumasParciales :: Num a => [a] -> [a]
    sumasParciales xs = tail (foldl (\acc x -> acc ++ [x + (last acc)]) [0] xs)

    sumasParciales' :: Num a => [a] -> [a]
    sumasParciales' xs = tail (scanl (+) 0 xs)
    ```

#### iv. Definir la función `sumaAlt`, que realiza la suma alternada de los elementos de una lista. Es decir, da como resultado: el primer elemento, menos el segundo, más el tercero, menos el cuarto, etc. Usar `foldr`.

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

#### v. Hacer lo mismo que en el punto anterior, pero en sentido inverso (el último elemento menos el anteúltimo, etc.). Pensar qué esquema de recursión conviene usar en este caso.

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
> #### 2. Recursión primitiva
> Caso especial de estructural donde además de la cola `xs`, se tiene acceso al **resultado de la llamada recursiva**. Es la que modela `foldr`.
>
> ```haskell
> -- primitiva: usa xs y también el resultado recursivo
> f [] = ...
> f (x:xs) = ... x ... (f xs) ...
> ```
>
> #### 3. Recursión global (general)
> No hay restricción sobre el argumento de la llamada recursiva. Si la estructura original es **modificada** antes de pasarla (por ejemplo con `tail xs`), entonces no cumple recursión estructural y es global.
>
> ```haskell
> -- global: se llama con tail xs, que modifica la estructura original
> f (x:xs) = ... f (tail xs) ...
> ```


### Ejercicio 5

#### Indicar si la recursión utilizada en cada una de ellas es o no estructural. Si lo es, reescribirla utilizando `foldr`. En caso contrario, explicar el motivo.

```hs
elementosEnPosicionesPares :: [a] -> [a]
elementosEnPosicionesPares [] = []
elementosEnPosicionesPares (x:xs) =
    if null xs
    then [x]
    else x : elementosEnPosicionesPares (tail xs)
```

1. No es recursión estructural ya que al hacer ell lamado recursivo utiliza `tail xs`, descartando elementos de la cola entera, `xs`.

```hs
entrelazar :: [a] -> [a] -> [a]
entrelazar [] = id
entrelazar (x:xs) =
    \ys -> if null ys
           then x : entrelazar xs []
           else x : head ys : entrelazar xs (tail ys)
```

2. Sí es recursión estructural, ya que hace recursión sobre la cola `xs`. Si bien usa `tail ys`, eso no rompe la recursión estructural ya que `ys` no es el argumento estructural de la recursión, si no que es sólo un parámetro que no define casos base ni guía la recursión.
Hecha con `foldr`:
- 
    ```hs
    entrelazar :: [a] -> [a] -> [a]
    entrelazar xs ys = foldr
        (\x acc ys ->
            if null ys then x : acc []
            else x : head ys : acc (tail ys)
        ) id xs ys
    ```

    ---

### Ejercicio 6

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
    -- quiero resolverlo con recr
    -- sacarUna 3 [1,3,2,3] = recr f z [1,3,2,3]
    -- = f 1 [3,2,3] (recr f z [3,2,3])
    -- = f 1 [3,2,3] (f 3 [2,3] (recr f z [2,3]))
    -- = f 1 [3,2,3] (f 3 [2,3] (f 2 [3] (recr f z [3])))
    -- = f 1 [3,2,3] (f 3 [2,3] (f 2 [3] (f 3 [] (recr f z [] ))))
    -- = f 1 [3,2,3] (f 3 [2,3] (f 2 [3] (f 3 [] z)))
    -- x=3, lo quiero descartar, devuelvo solo xs=[]
    -- = f 1 [3,2,3] (f 3 [2,3] (f 2 [3] [] ))
    -- x=2, no lo quiero descartar, reconstruyo rec=[2]
    -- = f 1 [3,2,3] (f 3 [2,3] [2] )
    -- de nuevo, x=3, lo quiero descartar, devuelvo directamete xs=[2,3]
    -- = f 1 [3,2,3] [2,3]
    -- x=1, no lo quiero descartar, reconstruyo rec=[1,2,3]
    -- [1,2,3]

    -- entonces f hace lo siguiente...
    -- dado f x xs rec
    --      si x == 3 -> lo quiero borrar -> devuelvo xs (no uso el rec acumulado)
    --      si x != 3 -> no lo quiero borrar -> reconstruyo con x : rec

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

### Ejercicio 7

#### Definir las siguientes funciones para trabajar sobre listas, y dar su tipo. Todas ellas deben poder aplicarse a listas finitas e infinitas.

#### i. `mapPares`, una versión de `map` que toma una función currificada de dos argumentos y una lista de pares de valores, y devuelve la lista de aplicaciones de la función a cada par. Pista: recordar `curry` y `uncurry`.

-
    ```hs
    mapPares :: (a -> b -> c) -> [(a,b)] -> [c]
    mapPares _ []     = []
    mapPares f (p:ps) = uncurry f p : mapPares f ps

    mapPares' :: (a -> b -> c) -> [(a,b)] -> [c]
    mapPares' f ps = map (uncurry f) ps
    ```
    - Funciona bien en listas infinitas:
        ```hs
        ghci> take 5 (mapPares (*) (zip [1..] [5..]))
        [5,12,21,32,45]
        ```

#### ii. `armarPares`, que dadas dos listas arma una lista de pares que contiene, en cada posición, el elemento correspondiente a esa posición en cada una de las listas. Si una de las listas es más larga que la otra, ignorar los elementos que sobran (el resultado tendrá la longitud de la lista más corta). Esta función en Haskell se llama `zip`. Pista: aprovechar la currificación y utilizar evaluación parcial.


-
    ```hs
    armarPares :: [a] -> [b] -> [(a,b)]
    armarPares _ []          = []
    armarPares [] _          = []
    armarPares (x:xs) (y:ys) = (x,y) : armarPares xs ys

    armarPares2 :: [a] -> [b] -> [(a, b)]
    armarPares2 = foldr (
        \x acc ys ->
            if null ys
                then []
            else
                (x, head ys) : acc (tail ys)
        ) (const [])
    ```

    - Funciona bien en listas infinitas:
        ```hs
        ghci> take 5 (armarPares [1..] [5..])
        [(1,5),(2,6),(3,7),(4,8),(5,9)]
        ```

#### iii. `mapDoble`, una variante de `mapPares`, que toma una función currificada de dos argumentos y dos listas (de igual longitud), y devuelve una lista de aplicaciones de la función a cada elemento correspondiente de las dos listas. Esta función en Haskell se llama `zipWith`.

- 
    ```hs
    mapDoble :: (a -> b -> c) -> [a] -> [b] -> [c]
    mapDoble _ [] _          = []
    mapDoble _ _ []          = []
    mapDoble f (x:xs) (y:ys) = f x y : mapDoble f xs ys
    ```

---
---

## Otras estructuras de datos
> En esta sección se permite (y se espera) el uso de recursión explícita únicamente para la definición de esquemas de recursión.

### Ejercicio 9

#### i. Definir y dar el tipo del esquema de recursión `foldNat` sobre los naturales. Utilizar el tipo `Integer` de Haskell (la función va a estar definida sólo para los enteros mayores o iguales que 0).

-
    ```hs
    foldNat :: (Int -> b -> b) -> b -> Int -> b
    foldNat _ z 0 = z
    foldNat f z n = f n (foldNat f z (n-1))
    ```

##### ii. Utilizando `foldNat`, definir la función potencia.