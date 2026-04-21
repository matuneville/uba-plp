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
    i. ∀ p::(a,b) . intercambiar (intercambiar p) = p

    -- Lema de Generación de Pares:         {GP}
    -- dado p::(a,b) ⇒ ∃x::a, ∃y::b. p=(x,y)

    intercambiar (intercambiar (x,y))
    {I}  = intercambiar (y,x)
    {I}  = (x,y)
    {GP} = p
    ```

2. 
    ```hs
    ii. ∀ p::(a,(b,c)) . asociarD (asociarI p) = p

    -- Lema de Generación de Pares:         {GP}
    -- dado p::(a,(b,c)) ⇒ ∃x::a, ∃z::(b,c), ∃z1::b, ∃z2::c
    -- p=(x,z)

    asociarD (asociarI (x,(y,z)))
    {AI} = asociarD ((x,y),z)
    {AD} = (x,(y,z))
    {GP} = p
    ```

3. 
    ```hs
    iii. ∀ p::Either a b . espejar (espejar p) = p
    ```

4. 
    ```hs
    iv. ∀ f::a->b->c . ∀ x::a . ∀ y::b . flip (flip f) x y = f x y
    ```

5. 
    ```hs
    v. ∀ f::a->b->c . ∀ x::a . ∀ y::b . curry (uncurry f) x y = f x y
    ```