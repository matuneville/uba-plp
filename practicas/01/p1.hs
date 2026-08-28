-- Ejercicio 2 -------------------------
----------------------------------------

-- i) ---

curry' :: ((a, b) -> c) -> a -> b -> c
-- curry' f = \x -> \y -> f (x, y)
curry' f x y = f (x, y)

-- ii) ---

uncurry' :: (a -> b -> c) -> (a, b) -> c
uncurry' f (x, y) = f x y

-- las pruebo con max

maxUncurried :: (Int, Int) -> Int
maxUncurried (x, y)
  | x >= y = x
  | otherwise = y

maxCurried :: Int -> Int -> Int
maxCurried x y
  | x >= y = x
  | otherwise = y

-- Ejercicio 4 -------------------------
-- -------------------------------------

paresDeNat :: [(Int, Int)]
paresDeNat = [(x, y) | s <- [0 ..], x <- [0 .. s], let y = s - x]

-- Ejercicio 8 -------------------------
----------------------------------------

-- i) ---

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
  where
    -- numerosParesAlCuadrado xs = map alCuadrado $ filter esPar xs
    -- numerosParesAlCuadrado xs = map alCuadrado (filter esPar xs)

    esPar = \n -> n `mod` 2 == 0
    alCuadrado = \n -> n * n

-- ii) ---

sum' :: [Float] -> Float
sum' xs = foldr (+) 0 xs

elem' :: (Eq a) => a -> [a] -> Bool
elem' x xs = foldr (\y acc -> y == x || acc) False xs

(+++) :: [a] -> [a] -> [a]
(+++) xs ys = foldr (:) ys xs

-- en cada paso, : agrega el elemento actual al frente del acumulador,
-- que arranca siendo ys

filter' :: (a -> Bool) -> [a] -> [a]
filter' p xs = foldr (\x acc -> if p x then x : acc else acc) [] xs

map' :: (a -> b) -> [a] -> [b]
map' f xs = foldr (\x acc -> f x : acc) [] xs

-- en cada paso, : agrega f x, el elemento mapeado, al frente del acumulador,
-- que arranca siendo vacio

-- iii) ---
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

-- iv) ---

sumasParciales :: (Num a) => [a] -> [a]
sumasParciales xs = tail (foldl (\acc x -> acc ++ [x + (last acc)]) [0] xs)

sumasParciales' :: (Num a) => [a] -> [a]
sumasParciales' xs = tail (scanl (+) 0 xs)

-- v) ---

-- El truco está en ver que:
--
-- Dado [2 1 3 4],
-- 2 - 1 + 3 - 4 =
-- = 2 - 1 + 3 - 4
-- = 2 - (1 - 3 + 4)
-- = 2 - (1 - (3 - 4)) = f 2 (f 1 (f 3 4)) = foldr1 f [2 1 3 4],
-- donde f = (-)

sumaAlt :: [Int] -> Int
sumaAlt xs = foldr1 (-) xs

-- vi) ---

-- Dado [1 2 3 4],
-- (4 - 3 + 2 - 1) =
-- = 4 - (3 - 2 + 1)
-- = 4 - (3 - (2 - 1))

sumaAltInversa :: [Int] -> Int
sumaAltInversa xs = foldl1 (flip (-)) xs -- con flip (-) hace x-acc en vez de acc-x

-- Ejercicio 10 -------------------------
----------------------------------------

recr :: (a -> [a] -> b -> b) -> b -> [a] -> b
recr _ z [] = z
recr f z (x : xs) = f x xs (recr f z xs)

sacarUna :: (Eq a) => a -> [a] -> [a]
sacarUna _ [] = []
sacarUna a (x : xs)
  | a == x = xs
  | otherwise = x : sacarUna a xs

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

sacarUna' :: (Eq a) => a -> [a] -> [a]
sacarUna' a xs = recr f z xs
  where
    z = []
    f x xs rec
      | x == a = xs
      | otherwise = x : rec

-- c) ---

insertarOrdenado :: (Ord a) => a -> [a] -> [a]
insertarOrdenado a [] = [a]
insertarOrdenado a (x : xs)
  | a < x = a : (x : xs)
  | otherwise = x : insertarOrdenado a xs

-- recr _ z [] = z
-- recr f z (x : xs) = f x xs (recr f z xs)

-- insertarOrdenado 2 [0,1,4,5] = recr f z [0,1,4,5]
-- = f 0 [1,4,5] (recr f z [1,4,5])
-- = f 0 [1,4,5] (f 1 [4,5] (recr f z [4,5]))
-- = f 0 [1,4,5] (f 1 [4,5] (f 4 [5] (recr f z [5])))
-- = f 0 [1,4,5] (f 1 [4,5] (f 4 [5] (f 5 [] (recr f z []))))
-- = f 0 [1,4,5] (f 1 [4,5] (f 4 [5] (f 5 [] z )))
-- 2 < x=5 -> uso xs=[] y no rec=z -> 2:5:xs = 2:5:[] = [2,5] = rec resultado
-- = f 0 [1,4,5] (f 1 [4,5] (f 4 [5] [2,5]))
-- 2 < x=4 -> uso xs=[5] y no rec=[2,5] -> 2:4:xs = 2:4:[5] = [2,4,5] = rec resultado
-- = f 0 [1,4,5] (f 1 [4,5] [2,4,5])
-- 2 /< x=1 -> uso rec=[2,4,5] y no xs=[4,5] -> 1:rec = 1:[2,4,5] = [1,2,4,5] = rec rto
-- = f 0 [1,4,5] [1,2,4,5])
-- 2 /< x=0 -> uso rec=[1,2,4,5] y no xs=[1,4,5] -> 0:rec = 0:[1,2,4,5] = [0,1,2,4,5] = rec rto
-- resultado -> rec = [0,1,2,4,5]

-- insertarOrdenado 1 [0,2,4,5] = recr f z [0,2,4,5]
-- = f 0 [2,4,5] (recr f z [2,4,5])
-- = f 0 [2,4,5] (f 2 [4,5] (recr f z [4,5]))
-- = f 0 [2,4,5] (f 2 [4,5] (f 4 [5] (recr f z [5])))
-- = f 0 [2,4,5] (f 2 [4,5] (f 4 [5] (f 5 [] (recr f z []))))
-- = f 0 [2,4,5] (f 2 [4,5] (f 4 [5] (f 5 [] z)))
-- 1 < x=5 -> uso xs=[] y no rec=z -> 1:5:xs = 1:5:[] = [1,5] = rec resultado
-- = f 0 [2,4,5] (f 2 [4,5] (f 4 [5] [1,5]))
-- 1 < x=4 -> uso xs=[5] y no rec=[1,5] -> 1:4:xs = 1:4:[5] = [1,4,5] = rec resultado
-- = f 0 [2,4,5] (f 2 [4,5] [1,4,5])
-- 1 < x=2 -> uso xs=[4,5] y no rec=[1,4,5] -> 1:2:xs = 1:2:[4,5] = [1,2,4,5] = rec rto
-- = f 0 [2,4,5] [1,2,4,5]
-- 1 /< x=0 -> uso rec=[1,2,4,5] y no xs -> 0:rec = 0:[1,2,4,5] = [0,1,2,4,5]

-- entonces f lo que hace es
-- si a < x -> devuelvo a:x:xs
-- si no -> devuelvo x:rec
-- el caso base z sería [a], se ve a ojo
-- luego llamo 'insertar' a f, queda un poco mejor

insertarOrdenado' :: (Ord a) => a -> [a] -> [a]
insertarOrdenado' a ys = recr insertar z ys
  where
    z = [a]
    insertar x xs acc
      | a < x = a : x : xs
      | otherwise = x : acc

-- Ejercicio 11 -------------------------
-----------------------------------------

elementosEnPosicionesPares :: [a] -> [a]
elementosEnPosicionesPares [] = []
elementosEnPosicionesPares (x : xs) =
  if null xs
    then [x]
    else x : rec
  where
    rec = elementosEnPosicionesPares (tail xs)

-- el llamado recursivo usa (tail xs), modificando la cola entera xs
-- luego, es recursion global

entrelazar :: [a] -> [a] -> [a]
entrelazar [] = id
entrelazar (x : xs) =
  \ys ->
    if null ys
      then x : rec []
      else x : head ys : rec (tail ys)
  where
    rec = entrelazar xs

entrelazar' :: [a] -> [a] -> [a]
entrelazar' =
  foldr
    (\x rec -> \ys -> if (null ys) then (x : rec []) else (x : head ys : rec (tail ys)))
    id

--

slowSort :: (Ord a) => [a] -> [a]
slowSort [] = []
slowSort (p : xs) = slowSort menores ++ [p] ++ slowSort mayores
  where
    menores = [x | x <- xs, x <= p]
    mayores = [x | x <- xs, x > p]

--

sufijos :: [a] -> [[a]]
sufijos [] = [[]]
sufijos (x : xs) = (x : xs) : rec
  where
    rec = sufijos xs

sufijos' :: [a] -> [[a]]
sufijos' = recr (\x xs rec -> (x : xs) : rec) [[]]

-- sufijos = foldr (\x rec -> (x : head rec) : rec) [[]]

--

miScanr :: (a -> b -> b) -> b -> [a] -> [b]
miScanr f n [] = [n]
miScanr f n (x : xs) =
  let (y : ys) = miScanr f n xs
   in (f x y) : (y : ys)

-- Ejercicio 12 -------------------------
----------------------------------------

-- i) ----
mapPares :: (a -> b -> c) -> [(a, b)] -> [c]
mapPares _ [] = []
mapPares f (x : xs) = uncurry f x : rec
  where
    rec = mapPares f xs

mapPares' :: (a -> b -> c) -> [(a, b)] -> [c]
mapPares' f = foldr (\x rec -> uncurry f x : rec) []

-- ii) ----

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

-- iii) ----
mapDoble :: (a -> b -> c) -> [a] -> [b] -> [c]
mapDoble _ [] _ = []
mapDoble _ _ [] = []
mapDoble f (x : xs) (y : ys) = f x y : mapDoble f xs ys

-- Ejercicio 14 -------------------------
----------------------------------------
-- para listas tengo foldr:
-- foldr :: (a -> b -> b) -> b -> [a] -> b
-- foldr f z []     = z
-- foldr f z (x:xs) = f x (foldr f z xs)

-- y en foldr
--      - si la lista es [], devuelvo z (caso base)
--      - aplico f con x y uso xs en el paso recursivo

-- quiero lo mismo para los naturales, donde:
--      - si el numero es 0, devuelvo z (caso base)
--      - aplico f con n y uso n-1 en el paso recursivo

-- i) ----

foldNat :: (Int -> b -> b) -> b -> Int -> b
foldNat _ z 0 = z
foldNat f z n = f n (foldNat f z (n - 1))

-- ii) ----

potencia :: Int -> Int -> Int
potencia a 0 = 1
potencia a b = a * rec
  where
    rec = potencia a (b - 1)

potencia' :: Int -> Int -> Int
potencia' a = foldNat (\n rec -> a * rec) 1

-- Ejercicio 17 -------------------------
----------------------------------------

data AB a = Nil | Bin (AB a) a (AB a) deriving (Eq, Show)

-- i)
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

{-
-- ii) ----
esNil :: AB a -> Bool
esNil Nil = True
esNil _ = False

altura :: AB a -> Int
altura = foldAB 0 fMaxAltSub
  where
    fMaxAltSub = (\altIzq _ altDer -> 1 + max altIzq altDer)

cantNodos :: AB Int -> Int
cantNodos = foldAB 0 fCantSubnodos
  where
    fCantSubnodos = (\sizeIzq _ sizeDer -> 1 + sizeIzq + sizeDer)

-- iii) ----

-- Idea:
-- Usar foldAB
-- Arrancar con la raíz r
-- En cada nodo comparar:
--     el valor actual x
--     con el mejor entre los hijos
mejorSegunAB :: (a -> a -> Bool) -> AB a -> a
mejorSegunAB _ Nil = error "No hay mejor en árbol vacío"
mejorSegunAB f (Bin izq raiz der) = foldAB raiz fBin (Bin izq raiz der)
  where
    fBin mejorIzq x mejorDer =
      if f x mejorHijo
        then x
        else
          mejorHijo
      where
        mejorHijo = if f mejorIzq mejorDer then mejorIzq else mejorDer

-- iv) ----
-- En cada nodo verificar:
--     1. izq es ABB
--     2. der es ABB
--     3. todos los de izq ≤ x
--     4. todos los de der > x

-- Problema: Las condiciones 3 y 4 necesitan:
--     máximo del izquierdo
--     mínimo del derecho
-- o sea, se necesita info global del subárbol, no solo un booleano

-- lo que puedo hacer entonces es:
--      esABB izq &&
--      esABB der &&
--      (max izq <= x) &&
--      (min der > x)

-- recAB :: b -> (AB a -> b -> a -> AB a -> b -> b) -> AB a -> b

esABB :: (Ord a) => AB a -> Bool
esABB Nil = True
esABB (Bin izq raiz der) = recAB True fBin (Bin izq raiz der)
  where
    fBin izq resIzq x der resDer =
      resIzq
        && resDer
        && (esNil izq || (mejorSegunAB (>) izq) <= x)
        && (esNil der || (mejorSegunAB (<) der) > x) -- el mayor de izq es menor que raiz
        -- el menor de der es mayor que raiz

        -}