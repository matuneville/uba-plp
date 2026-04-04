# Guía 1: Programación Funcional

## Currificación y Tipos

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

```hs
-- a) ---

curry' :: ((a, b) -> c) -> a -> b -> c
curry' f x y = f (x, y)

-- b) ---

uncurry' :: (a -> b -> c) -> (a, b) -> c
uncurry' f (x, y) = f x y
```

#### Testeado:

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