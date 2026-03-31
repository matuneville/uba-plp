---------------------------------------------------------------------
-- Ejercicio 2 ------------------------------------------------------

-- a) -------
valorAbsoluto :: Float -> Float
valorAbsoluto n
    | n < 0     = -n
    | otherwise = n

-- b) -------
bisiesto :: Int -> Bool
bisiesto anio = 
    (anio `mod` 4 == 0 && anio `mod` 100 /= 0) || (anio `mod` 400 == 0)

-- c) -------
factorial :: Int -> Int
factorial 0 = 1
factorial n
    | n > 0     = n * factorial (n-1)
    | otherwise = error "El factorial no está definido para números negativos"

-- d) -------
cantDivisoresPrimos :: Int -> Int
cantDivisoresPrimos n
    | n == 0             = 0
    | n > 0 && esPrimo n = 1 + cantDivisoresPrimos (n-1)
    | n > 0              =     cantDivisoresPrimos (n-1)
    | otherwise          = error "Función definida solo para enteros positivos"

esPrimo :: Int -> Bool
esPrimo n
    | n < 2 = False
    | otherwise = null [ d | d <- [2..n-1] , n `mod` d == 0]

-- [  d  |  d <- [2..n-1]  ,  n `mod` d == 0  ]
--   ^^^    ^^^^^^^^^^^^^     ^^^^^^^^^^^^^^^^
-- dame d    para cada d      solo si d divide a n
--          entre 2 y n-1
--
-- null [...] pregunta 'está vacía la lista?'

---------------------------------------------------------------------
-- Ejercicio 3 ------------------------------------------------------

-- a) -------
inverso :: Float -> Maybe Float
inverso 0 = Nothing
inverso x = Just (1/x)

-- b) -------
aEntero :: Either Int Bool -> Int
aEntero (Left n)      = n
aEntero (Right True)  = 1
aEntero (Right False) = 0

---------------------------------------------------------------------
-- Ejercicio 4 ------------------------------------------------------

-- a) -------
limpiar :: String -> String -> String
limpiar basura cadena = filter (\c -> not (elem c basura)) cadena


-- b) -------
difPromedio :: [Float] -> [Float]
difPromedio xs = map (\x -> x - promedio) xs
    where
        promedio = sum xs / fromIntegral (length xs)

-- 'promedio' se calcula una sola vez en el 'where'
-- 'map' aplica la resta a cada elemento (map funcion -> lista -> lista resultado)
-- 'fromIntegral' convierte el 'Int' de 'length' a 'Float' para poder dividir

-- otra forma
difPromedio2 :: [Float] -> [Float]
difPromedio2 xs = restarPromedio xs
    where
        promedio              = sum xs / fromIntegral (length xs)
        restarPromedio []     = []
        restarPromedio (x:xs) = (x - promedio) : (restarPromedio xs)
    
-- c) -------
todosIguales :: [Int] -> Bool
todosIguales []       = True
todosIguales [x]      = True
todosIguales (x:y:xs) = (x == y) && todosIguales xs

-- otra forma
todosIguales2 :: [Int] -> Bool
todosIguales2 []     = True
todosIguales2 (x:xs) = all (== x) xs

-- 'all (== x) xs' pregunta si todos los elementos de 'xs' son iguales a 'x', el primero.
-- Si es así, todos son iguales entre sí.


---------------------------------------------------------------------
-- Ejercicio 5 ------------------------------------------------------

data AB a = Nil | Bin (AB a) a (AB a) deriving Show

-- Visualmente:
--       5
--      / \
--     3   8
--    / \
--   1  Nil
--
-- se define como 'Bin (Bin (Bin Nil 1 Nil) 3 Nil) 5 (Bin Nil 8 Nil)'


-- a) -------
vacioAB :: AB a -> Bool
vacioAB Nil         = True
vacioAB (Bin _ _ _) = False

-- b) -------
negacionAB :: AB Bool -> AB Bool
negacionAB Nil                             = Nil
negacionAB (Bin nodoIzq nodoPadre nodoDer) =
    Bin (negacionAB nodoIzq) (not nodoPadre) (negacionAB nodoDer)

-- c) -------
productoAB :: AB Int -> Int
productoAB Nil                             = 1
productoAB (Bin nodoIzq nodoPadre nodoDer) =
    (productoAB nodoIzq) * nodoPadre * (productoAB nodoDer)