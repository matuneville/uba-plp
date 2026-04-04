-- Ejercicio 2 -------------------------
----------------------------------------

-- a) ---

curry' :: ((a, b) -> c) -> a -> b -> c
curry' f x y = f (x, y)

-- b) ---

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
