```hs
curry :: ((a, b) -> c) -> (a -> b -> c)
{C} curry f = (\x y -> f (x, y))

uncurry :: (a -> b -> c) -> ((a, b) -> c)
{U} uncurry f = (\(x, y) -> f x y)

id :: a -> a
{ID} id x = x

(.) :: (b->c) -> (a-> b) -> a -> c
{COMP} (g . f) x = g (f x)

const :: a -> b -> c
{CONST} const x _ = x

length :: [a] -> Int
{L0} length [] = 0
{L1} length (x:xs) = 1 + length xs

duplicar :: [a] -> [a]
{D0} duplicar [] = []
{D1} duplicar (x:xs) = x : x : duplicar xs

(++) :: [a] -> [a] -> [a]
{++0} [] ++ ys = ys
{++1} (x:xs) ++ ys = x : (xs ++ ys)

append :: [a] -> [a] -> [a]
{A0} append xs ys = foldr (:) ys xs

reverse :: [a] -> [a]
{R0} reverse = foldl (flip (:)) []

map :: (a -> b) -> [a] -> [b]
{M0} map f [] = []
{M1} map f (x : xs) = f x : map f xs

elem :: Eq a => a -> [a] -> Bool
{E0} elem e [] = False
{E1} elem e (x:xs) = (e == x) || elem e xs

foldl :: (b -> a -> b) -> b -> [a] -> b
{FL0} foldl f ac [] = ac
{FL1} foldl f ac (x:xs) = foldl f (f ac x) xs

foldr :: (a -> b -> b) -> b -> [a] -> b
{FR0} foldr f z [] = z
{FR1} foldr f z (x:xs) = f x (foldr f z xs)

flip :: (a -> b -> c) -> (b -> a -> c)
{FL} flip f x y = f y x

maximum :: Ord a => [a] -> a
{M0} maximum [x] = x
{M1} maximum (x:y:ys) = max x (maximum (y:ys))
```