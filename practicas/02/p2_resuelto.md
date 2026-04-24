# Guía 2: Razonamiento ecuacional e Inducción estructural

_En las demostraciones por inducción estructural, justifique todos los pasos: por qué axioma, por qué lema, por qué puede aplicarse la hipótesis inductiva, etc. Es importante escribir el esquema de inducción, planteando claramente los casos base e inductivos, e identificando la hipótesis inductiva y la tesis inductiva.  
El alcance de todos los cuantificadores que se utilicen debe estar claramente definido (si no hay paréntesis, se entiende que llegan hasta el final).  
Demuestre todas las propiedades auxiliares (lemas) que utilice._


## Extensionalidad y Lemas de Generación

> ### Resumen: razonamiento ecuacional
> Razonamos ecuacionalmente usando tres principios:
> 1. **Principio de reemplazo**  
>   Si el programa declara que e1 = e2, cualquier instancia de e1 es igual a la correspondiente instancia de e2, y viceversa.
> 2. **Principio de inducción estructural**  
>   Para probar P sobre todas las instancias de un tipo T, basta probar P para cada uno de los constructores (asumiendo la H.I. para los constructores recursivos).
> 3. **Principio de extensionalidad funcional**  
>   Para probar que dos funciones son iguales, basta probar que son iguales punto a punto.

### Ejercicio 1

Dadas las siguientes definiciones de funciones:

```hs
- intercambiar (x,y) = (y,x)        {I}
- espejar (Left x) = Right x        {E1}
  espejar (Right x) = Left x        {E2}
- asociarI (x,(y,z)) = ((x,y),z)    {AI}
- asociarD ((x,y),z)) = (x,(y,z))   {AD}
- flip f x y = f y x                {F}
- curry f x y = f (x,y)             {C}
- uncurry f (x,y) = f x y           {U}
```

Demostrar las siguientes igualdades usando los lemas de generación cuando sea necesario:

> - **Lema de Generación de Pares:**  
> Dado p::(a,b), siempre podemos decir que ∃x::a, ∃y::b tales que p=(x,y)

1. 
    ```hs
    ∀ p::(a,b) . intercambiar (intercambiar p) = p

    -- Lema de Generación de Pares:         {GP}
    -- dado p::(a,b) ⇒ ∃x::a, ∃y::b. p=(x,y)

    intercambiar (intercambiar (x,y))
    {I}  = intercambiar (y,x)
    {I}  = (x,y)
    {GP} = p
    ```

2. 
    ```hs
    ∀ p::(a,(b,c)) . asociarD (asociarI p) = p

    -- Lema de Generación de Pares:         {GP}
    -- dado p::(a,(b,c)) ⇒ ∃x::a, ∃z::(b,c), ∃z1::b, ∃z2::c
    -- p=(x,z)

    asociarD (asociarI (x,(y,z)))
    {AI} = asociarD ((x,y),z)
    {AD} = (x,(y,z))
    {GP} = p
    ```

> - **Lema de generación para sumas**  
> Si e :: Either a b, siempre podemos decir que vale:
>   - o bien ∃x :: a. e = Left x
>   - o bien ∃y :: b. e = Right y

3. 
    ```hs
    ∀ p::Either a b . espejar (espejar p) = p
    
    -- Lema de generación para sumas        {GS}
    -- dado p :: Either a b:
    --  (∃x::a. p=Left x)  ∨  (∃y::b. p=Right y)

    -- caso p = Left x {GS}
    espejar (espejar (Left x))
    {E1} = espejar (Right x)
    {E2} = Left x
    {GS} = p

    -- caso p = Right y {GS}
    espejar (espejar (Right y))
    {E1} = espejar (Left y)
    {E2} = Right y
    {GS} = p
    ```


4. 
    ```hs
    ∀ f::a->b->c . ∀ x::a . ∀ y::b . flip (flip f) x y = f x y
    
    flip (flip f) x y
    {F} = (flip f) y x
    {F} = f x y
    ```

5. 
    ```hs
    ∀ f::a->b->c . ∀ x::a . ∀ y::b . curry (uncurry f) x y = f x y

    curry (uncurry f) x y
    {U} = (uncurry f) (x,y)
    {C} = f x y
    ```

    ---

### Ejercicio 2

Demostrar las siguientes igualdades utilizando el principio de extensionalidad funcional:

> - **Principio de extensionalidad funcional**
> Si (∀x :: a. f x = g x) entonces f = g.

> _Otras definiciones útiles_
> ```hs
> id x = x              {ID}
> (g . f) x = g (f x)   {COMP}
> const x _ = x         {CONST}
> ```

1. 
    ```hs
    flip . flip = id
    
    -- Gracias a exten. funcional, basta con ver:
    -- (∀x :: a. ∀y :: b. id f x y = (flip . flip) f x y)    {EF}
    -- ⇒
    -- id f = (flip . flip) f.
    -- veamoslo entonces para todo x y

    (flip . flip) f x y
    {COMP} = flip (flip (f x y))
    {F}    = flip f y x
    {F}    = f x y
    {ID}   = id f x y

    -- Vale para todo x y, luego por {EF} vale: id f = flip (flip f)
    ````

2. 
    ```hs
    ∀ f::(a,b)->c . uncurry (curry f) = f

    -- Por Lema de generación de pares, podemos decir que   {PAR}
    -- siempre existen x::a, y::b . p=(x,y)

    uncurry (curry f) p
    {PAR} = uncurry (curry f) (x,y)
    {U}   = (curry f) x y
    {C}   = f (x,y)
    {PAR} = f p

    -- Vale para todo p, luego por {EF} vale: f = uncurry (curry f)
    ```

3. 
    ```hs
    flip const = const id
    

    -- quiero ver que:
    -- {EF} (∀x :: a. ∀y :: b. flip const x y = const id x y)

    flip const x y
    {F}     = const y x
    {CONST} = y
    {ID}    = id y
    {CONST} = const (id y) x   -- ?????? me quedo al reves 🤔
    ```

4. 
    ```hs
    ∀ f::a->b . ∀ g::b->c . ∀ h::c->d . ((h . g) . f) = (h . (g . f))
    -- con la definición usual de la composición: (.) f g x = f (g x).

    -- quiero ver que:
    -- {EF} (∀x :: a. ∀y :: b. ∀z :: c. 
    --      ((h . g) . f) x = (h . (g . f)) x)

    ((h . g) . f) x 
    {COMP} = h (g (f x))
    {COMP} = h ((g . f) x)
    {COMP} = (h . (g . f)) x

    -- luego por {EF}: ((h . g) . f) = (h . (g . f)))
    ```

## Demostración de propiedades sobre listas

_En esta sección usaremos las siguientes definiciones (y las de `elem`, `foldr`, `foldl`, `map` y `alter` vistas en clase):_  **Leer `definiciones_utiles.md`**.

> #### Inducción en Listas
> 1. Pruebo P([ ])
> 2. Pruebo que si vale P(xs) entonces para todo elemento x vale P(x:xs).
>
> **Pasos a seguir:**
> 1. Leer la propiedad, entenderla y convencerse de que es verdadera.
> 2. Plantear la propiedad como predicado unario.
> 3. Plantear el esquema de inducci´on.
> 4. Plantear y resolver el o los caso(s) base.
> 5. Plantear y resolver el o los caso(s) inductivo(s).

### Ejercicio 3

Demostrar las siguientes propiedades:  

1. 
    ```hs
    ∀ xs::[a] . length (duplicar xs) = 2 * length xs

    -- Tengo que demostrar que vale
    -- ∀ xs::[a]. P(xs): length (duplicar xs) = 2 * length xs
    -- Veo por principio de inducción estructural sobre listas

    -- Caso base: P([]) ------
    -- length (duplicar []) = 2 * length []
    length (duplicar [])
    {D0} = length []
    {L0} = 0
         = 2 * 0
    {L0} = 2 * length [] -- ✓

    -- Paso inductivo: ------

    -- Hipótesis inductiva:
    -- P(xs) = length (duplicar xs) = 2 * length xs

    -- ∀x::a. ∀xs::[a]. Usando P(xs) como HI, QVQ vale P(x:xs).
    -- P(x:xs): length (duplicar (x:xs)) = 2 * length (x:xs)
    length (duplicar (x:xs))
    {D1} = length (x : x : duplicar xs)
    {L1} = 1 + length (x : duplicar xs)
    {L1} = 1 + 1 + length (duplicar xs)
    {HI} = 1 + 1 + 2 * length xs
         = 2 + 2 * length xs
         = 2 * (1 + length xs)
    {L1} = 2 * length (x:xs) -- ✓
    -- QED
    ```

2. 
    ```hs
    ∀ xs::[a] . ∀ ys::[a] . length (xs ++ ys) = length xs + length ys

    -- Tengo que demostrar que vale
    -- ∀ xs::[a] . ∀ ys::[a]. P(xs): length (xs ++ ys) = length xs + length ys

    -- Caso base: P([]) ------
    -- length ([] ++ ys) = length [] + length ys
    length ([] ++ ys)
    {++0} = length ys
          = 0 + length ys
    {L0}  = length [] + length ys -- ✓

    -- Paso inductivo: ------

    -- Hipótesis inductiva:
    -- P(xs) = length (xs ++ ys) = length xs + length ys

    -- ∀x::a. ∀xs::[a]. ∀ys::[a]. Usando P(xs) como HI, QVQ vale P(x:xs).
    -- P(x:xs): length ((x:xs) ++ ys) = length (x:xs) + length ys
    length ((x:xs) ++ ys)
    {++1} = length (x : (xs ++ ys))
    {L1}  = 1 + length (xs ++ ys)
    {HI}  = 1 + length xs + length ys
    {L1}  = length (x:xs) + length ys -- ✓
    -- ∎
    ```

3. 
    ```hs
    ∀ xs::[a] . ∀ x::a . [x] ++ xs = x:xs
    
    -- bruh... más de lo mismo
    ```

4. 
    ```hs
    ∀ xs::[a] . xs ++ [] = xs

    -- de vuelta... má' de lo mismo
    ```

5. 
    ```hs
    ∀ xs::[a] . ∀ ys::[a] . ∀ zs::[a] . (xs ++ ys) ++ zs = xs ++ (ys ++ zs)
    ```

6. 
    ```hs
    ∀ xs::[a] . ∀ f::(a->b) . length (map f xs) = length xs

    --- bla bla bla la inducción queda:

    -- Caso Base
    -- P([]): length (map f []) = length []
    length (map f [])
    {M0} = length [] -- ✓

    -- bla bla
    -- Paso Inductivo
    -- QVQ vale P(x) ⇒ P(x:xs) (la HI es lo que dice el enunciado...)
    -- P(x:xs): length (map f (x:xs)) = length (x:xs)
    length (map f (x:xs))
    {M1} = length (f x : map f xs)
    {L1} = 1 + length (map f xs)
    {HI} = 1 + length xs
    {L1} = length (x:xs) -- ✓
    -- ∎
    ```

7. 
    ```hs
    ∀ xs::[a] . ∀ p::a->Bool . ∀ e::a . (elem e (filter p xs) ⇒ elem e xs) (si vale Eq a)
    ```

### Ejercicio 4

Demostrar las siguientes propiedades:

1. 
    ```hs
    reverse = foldr (\x rec -> rec ++ (x:[])) []

    -- Quiero demostrar que ∀xs:[a].
    -- reverse xs = foldr (\x rec -> rec ++ (x:[])) [] xs
    -- por extensionalidad, ambas funciones son iguales si demuestro eso

    -- Sea P(xs):
    --    reverse xs
    --    = foldr (\x rec -> rec ++ (x:[])) [] xs
    --    = foldl (flip (:)) [] xs

    -- Veo por principio de inducción estructural sobre listas

    -- Caso Base: P([])
    -- reverse [] = foldr (\x rec -> rec ++ (x:[])) [] []
    reverse []
    {R0}  = foldl (flip (:)) [] [] -- {FL0} foldl f ac [] = ac
    {FL0} = []
          = foldr (\x rec -> rec ++ (x:[])) [] [] -- foldr f z [] = z
    {FR0} = [] -- ✓

    -- Paso inductivo
    -- HI: vale P(xs)
    -- QVQ: HI ⇒ P(x:xs)
    reverse (x:xs)
    {R0}  = foldl (flip (:)) [] (x:xs) -- {FL1} foldl f ac (x:xs) = foldl f (f ac x) xs
    {FL1} = foldl (flip (:)) ((flip (:)) [] x) xs
    {FL}  = foldl (flip (:)) ((:) x []) xs
    {:}   = foldl (flip (:)) [x] xs -- *1*

    foldr (\y rec -> rec ++ (y:[])) [] (x:xs) -- {FR1} foldr f z (x:xs) = f x (foldr f z xs)
    {FR1} = (\y rec -> rec ++ (y:[])) x (foldr (\y rec -> rec ++ (y:[])) [] xs) 
    {HI}  = (\y rec -> rec ++ (y:[])) x (reverse xs)
    {:}   = (\y rec -> rec ++ [y]) x (reverse xs) -- y ahora aplico la lambda con y=x y rec=(foldr...)
          = (reverse xs) ++ [x]
    {R0}  = (foldl (flip (:)) [] xs) ++ [x] -- *2*

    -- Entonces nos queda que:
    -- *1* = *2*
    foldl (flip (:)) [x] xs = (foldl (flip (:)) [] xs) ++ [x]

    -- Pruebo esto con OTRA INDUCCION (fuck my life)
    -- reemplazo [x] por ys ya que es una lista cualquiera
    
    -- De nuevo veo con extensionalidad
    -- ∀x:a. ∀xs:[a]. foldl (flip (:)) ys xs = (foldl (flip (:)) [] xs) ++ ys
    
    -- Sea P(xs): foldl (flip (:)) ys xs = (foldl (flip (:)) [] xs) ++ ys

    -- Caso Base.
    -- P([]): foldl (flip (:)) ys [] = (foldl (flip (:)) [] []) ++ ys
    foldl (flip (:)) ys []
    {FL0} = ys
          = (foldl (flip (:)) [] []) ++ ys
    {FL0} = [] ++ ys
    {++0} = ys -- ✓

    -- Paso Inductivo. Mi HI es que vale P(xs)
    -- QVQ: ∀x:a. ∀xs:[a]. P(xs) → P(x:xs) 
    -- P(x:xs) = foldl (flip (:)) ys (x:xs) = (foldl (flip (:)) [] (x:xs)) ++ ys
    foldl (flip (:)) ys (x:xs)
    {FL1} = foldl (flip (:)) ((flip (:)) ys x) xs
    {FL}  = foldl (flip (:)) ((:) x ys) xs
    {:}   = foldl (flip (:)) (x:ys) xs -- en este caso la ys' de HI es (x:ys)
    {HI}  = (foldl (flip (:)) [] xs) ++ (x:ys) -- *3*

    (foldl (flip (:)) [] (x:xs)) ++ ys
    {FL1} = (foldl (flip (:)) ((flip (:)) [] x) xs) ++ ys
    {FL}  = (foldl (flip (:)) ((:) x []) xs) ++ ys
    {:}   = (foldl (flip (:)) [x] xs) ++ ys -- en este caso la ys' de HI es [x]
    {HI}  = ((foldl (flip (:)) [] xs) ++ [x]) ++ ys
          = (foldl (flip (:)) [] xs) ++ [x] ++ ys
    {++1} = (foldl (flip (:)) [] xs) ++ x : ([] ++ ys)
    {++0} = (foldl (flip (:)) [] xs) ++ x : ys
    {:}   = (foldl (flip (:)) [] xs) ++ (x:ys) -- *4*

    -- *3* = *4*
    -- ✓

    -- El paso inductivo de la primera inducción dependía de esta igualdad de funciones,
    -- que acabamos de demostrar que es verdadera.
    -- ∎
    ```

2. 
    ```hs
    ∀ xs::[a] . ∀ ys::[a] . reverse (xs ++ ys) = reverse ys ++ reverse xs
    ```

3. 
    ```hs
    ∀ xs::[a] . ∀ x::a . reverse (xs ++ [x]) = x:reverse xs
    ```  

_Nota: en adelante, siempre que se necesite usar reverse, se podrá utilizar cualquiera de las dos definiciones, según se considere conveniente._