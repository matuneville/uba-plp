import Prelude hiding (foldr)

-- ejercicio de clase
--
-- Recursion Estructural

foldr :: (a -> b -> b) -> b -> [a] -> b
foldr f z [] = z
foldr f z (x : xs) = f x (foldr f z xs)

take' :: [a] -> Int -> [a]
take' [] = const []
take' (x : xs) = \n -> if n == 0 then [] else x : rec (n - 1)
  where
    rec = take' xs

take'' :: [a] -> Int -> [a]
take'' =
  foldr
    (\x rec -> \n -> if n == 0 then [] else x : rec (n - 1))
    (const [])

-- take'' [10, 20, 30] 2
-- = (foldr (\x rec n -> if n == 0 then [] else x : rec (n - 1)) (const []) [10, 20, 30]) 2
-- = (\n -> if n == 0 then [] else 10 : (f 20 (f 30 z)) (n - 1)) 2
-- = if 2 == 0 then [] else 10 : (f 20 (f 30 z)) (2 - 1)
-- = 10 : (f 20 (f 30 z)) 1
-- = 10 : (\n -> if n == 0 then [] else 20 : (f 30 z) (n - 1)) 1
-- = 10 : (if 1 == 0 then [] else 20 : (f 30 z) (1 - 1))
-- = 10 : 20 : (f 30 z) 0
-- = 10 : 20 : (\n -> if n == 0 then [] else 30 : z (n - 1)) 0
-- = 10 : 20 : (if 0 == 0 then [] else 30 : z (0 - 1))
-- = 10 : 20 : []
-- = [10, 20]

--
-- Recursion Primitiva

recr :: (a -> [a] -> b -> b) -> b -> [a] -> b
recr _ z [] = z
recr f z (x : xs) = f x xs (recr f z xs)

sacarElem :: (Eq a) => a -> [a] -> [a]
sacarElem _ [] = []
sacarElem y (x : xs) = if x == y then xs else x : rec
  where
    rec = sacarElem y xs

sacarElem' :: (Eq a) => a -> [a] -> [a]
sacarElem' y = recr (\x xs rec -> if x == y then xs else x : rec) []