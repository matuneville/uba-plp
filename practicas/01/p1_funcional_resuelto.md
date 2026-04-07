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

Indicar si la recursión utilizada en cada una de ellas es o no estructural. Si lo es, reescribirla utilizando `foldr`. En caso contrario, explicar el motivo.

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