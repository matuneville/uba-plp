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