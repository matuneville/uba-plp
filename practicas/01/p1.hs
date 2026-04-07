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
-- = 2 - (1 - (3 - 4))

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

-- entrelazar [1,2,3] [4,5,6]
-- = foldr (\x acc ys -> ...) id [1,2,3] [4,5,6]
-- = (\x acc ys -> ...) 1 ((\x acc ys -> ...) 2 ((\x acc ys -> ...) 3 id)) [4,5,6]

-- paso 1: x=3, acc=id
-- f3 = \ys -> if null ys then 3 : id []
--             else 3 : head ys : id (tail ys)

-- paso 2: x=2, acc=f3
-- f2 = \ys -> if null ys then 2 : f3 []
--             else 2 : head ys : f3 (tail ys)

-- paso 3: x=1, acc=f2
-- f1 = \ys -> if null ys then 1 : f2 []
--             else 1 : head ys : f2 (tail ys)

-- ahora aplicando f1 a [4,5,6]
-- f1 [4,5,6]
-- = 1 : 4 : f2 [5,6]
-- = 1 : 4 : 2 : 5 : f3 [6]
-- = 1 : 4 : 2 : 5 : 3 : 6 : id []
-- = 1 : 4 : 2 : 5 : 3 : 6 : []
-- = [1,4,2,5,3,6]