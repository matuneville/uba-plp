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
sum' = foldr (+) 0

elem' :: (Eq a) => a -> [a] -> Bool
elem' x = foldr (\y acc -> y == x || acc) False

(+++) :: [a] -> [a] -> [a]
(+++) xs ys = foldr (:) ys xs

filter' :: (a -> Bool) -> [a] -> [a]
filter' p = foldr (\x acc -> if p x then x : acc else acc) []

map' :: (a -> b) -> [a] -> [b]
map' f = foldr (\x acc -> f x : acc) []