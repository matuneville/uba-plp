-- Ejercicio 2 -------------------------
----------------------------------------

-- i) ---

curry' :: ((a, b) -> c) -> a -> b -> c
curry' f x y = f (x, y)

-- ii) ---

uncurry' :: (a -> b -> c) -> (a, b) -> c
uncurry' f (x, y) = f x y

-- las pruebo con max

maxUncurried :: (Int, Int) -> Int
maxUncurried (x, y) 
    | x >= y    = x
    | otherwise = y

maxCurried :: Int -> Int -> Int
maxCurried x y 
    | x >= y    = x
    | otherwise = y


-- Ejercicio 3 -------------------------
----------------------------------------

-- i) ---

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

-- ii) ---
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

-- iii) ---

sumasParciales :: Num a => [a] -> [a]
sumasParciales xs = tail (foldl (\acc x -> acc ++ [x + (last acc)]) [0] xs)

sumasParciales' :: Num a => [a] -> [a]
sumasParciales' xs = tail (scanl (+) 0 xs)

-- iv) ---

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

-- v) ---

-- Dado [1 2 3 4],
-- (4 - 3 + 2 - 1) = 
-- = 4 - (3 - 2 + 1)
-- = 4 - (3 - (2 - 1))

sumaAltInversa :: [Int] -> Int
sumaAltInversa xs = foldl1 (flip (-)) xs
-- con flip (-) hace x-acc en vez de acc-x

-- Ejercicio 5 -------------------------
----------------------------------------

-- entrelazar [1,2,3] [4,5,6] = [1,4,2,5,3,6]

-- foldr f z [1,2,3] = f 1 (f 2 (f 3 z))

entrelazar :: [a] -> [a] -> [a]
entrelazar xs ys = foldr
    (\x acc ys ->
        if null ys then x : acc []
        else x : head ys : acc (tail ys)
    ) id xs ys

-- entrelazar [1,2] [4,5]
-- = foldr f z [1,2] [4,5]
-- pero foldr :: (a -> b -> b) -> b -> [a] -> b, por lo tanto [4,5] sobra
-- -> la idea seria hacer foldr sobre la primera lista, y que la segunda viaje dentro de z y f
-- = foldr f z [1,2]
-- = f 1 (f 2 z)
-- en cada paso tengo que intercalar un elemento de [3,4]
-- pero foldr no me da acceso a ella, por lo que la puedo esconder en acumulador o en funciones
--
-- sé que 'foldr f z []' es el caso base,
-- y sé que 'entrelazar [] ys = ys' también caso base,
-- parece que z = ys
-- pero necesito información extra que no viene en foldr,
-- no puedo “guardarla” en una lista... pero sí en una función
-- z = \ys -> ys
-- = (f 1 (f 2 z)) 



-- Ejercicio 6 -------------------------
----------------------------------------

recr :: (a -> [a] -> b -> b) -> b -> [a] -> b
recr _ z [] = z
recr f z (x : xs) = f x xs (recr f z xs)

sacarUna :: Eq a => a -> [a] -> [a]
sacarUna _ [] = []
sacarUna a (x:xs)
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

sacarUna' :: Eq a => a -> [a] -> [a]
sacarUna' a xs = recr f z xs
    where
        z = []
        f x xs rec
            | x == a = xs
            | otherwise = x : rec

-- c) ---

insertarOrdenado :: Ord a => a -> [a] -> [a]
insertarOrdenado a [] = [a]
insertarOrdenado a (x:xs)
    | a < x = a : (x:xs)
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

insertarOrdenado' :: Ord a => a -> [a] -> [a]
insertarOrdenado' a ys = recr insertar z ys
    where
        z = [a]
        insertar x xs acc
            | a < x = a:x:xs
            | otherwise = x:acc