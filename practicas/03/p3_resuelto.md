# Guía 3: Demostración en Lógica Proposicional

## Deducción Natural

### Ejercicio 5  
Demostrar en deducción natural que las siguientes fórmulas son teoremas sin usar principios de razonamiento clásicos salvo que se indique lo contrario.
Recordemos que una fórmula σ es un teorema si y sólo si vale ⊢ σ.

1. Modus ponens relativizado: (ρ ⇒ σ ⇒ τ ) ⇒ (ρ ⇒ σ) ⇒ ρ ⇒ τ

    ```hs
    (P => Q => R) => (P => Q) => P => R
    
    Contexto: Γ = {P ⇒ Q ⇒ R, P ⇒ Q, P}
    
    ___________ax      ________ax     __________ax     _______ax
     Γ ⊢ P⇒Q⇒R          Γ ⊢ P          Γ ⊢ P⇒Q         Γ ⊢ P
    _____________________E⇒          ________________________E⇒
     Γ:  P⇒Q⇒R, P ⊢ Q⇒R                 Γ: P⇒Q, P ⊢ Q
    ___________________________________________________E⇒
                        Γ:  Q⇒R, Q ⊢ R   
    ```