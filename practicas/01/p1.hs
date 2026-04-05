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