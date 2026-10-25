#lang eopl
;Autores: Josue David Cocoma Tascon 2477087, Juan Diego Montaño Vergara 2477334

;; Taller 2 — El intérprete de Cauca.
;; Las primitivas del lenguaje y las verificaciones de tipo y de
;; cantidad de argumentos que cada una exige. Requiere sintaxis.rkt.
;;
;; Aridades: +, -, *, / son n-arias; add1, sub1, not y abs son unarias;
;; las relacionales, and, or, xor e implica son binarias; entre es
;; ternaria; mcd y mcm son n-arias sobre enteros con al menos dos
;; argumentos; promedio es n-aria sobre números con al menos uno.

(require "sintaxis.rkt")

;; exigir-numeros : lista x symbol -> boolean
;; Retorna #t si todos los argumentos son números; si no, levanta
;; eopl:error a nombre de quien hizo la verificación.
(define exigir-numeros
  (lambda (args quien)
    (cond
      ((null? args) #t)
      ((number? (car args)) (exigir-numeros (cdr args) quien))
      (else (eopl:error quien "Se esperaba un número y llegó ~s" (car args))))))

;; exigir-enteros : lista x symbol -> boolean
;; Retorna #t si todos los argumentos son enteros; si no, levanta error.
(define exigir-enteros
  (lambda (args quien)
    (cond
      ((null? args) #t)
      ((and (number? (car args)) (integer? (car args)))
       (exigir-enteros (cdr args) quien))
      (else (eopl:error quien "Se esperaba un entero y llegó ~s" (car args))))))

;; exigir-booleanos : lista x symbol -> boolean
;; Retorna #t si todos los argumentos son booleanos; si no, levanta error.
(define exigir-booleanos
  (lambda (args quien)
    (cond
      ((null? args) #t)
      ((boolean? (car args)) (exigir-booleanos (cdr args) quien))
      (else (eopl:error quien "Se esperaba un booleano y llegó ~s" (car args))))))

;; exigir-cantidad : lista x int x symbol -> boolean
;; Retorna #t si llegaron exactamente n argumentos; si no, levanta error.
(define exigir-cantidad
  (lambda (args n quien)
    (if (= (length args) n)
        #t
        (eopl:error quien "Se esperaban ~s argumentos y llegaron ~s" n (length args)))))

;; exigir-minimo : lista x int x symbol -> boolean
;; Retorna #t si llegaron al menos n argumentos; si no, levanta error.
(define exigir-minimo
  (lambda (args n quien)
    (if (>= (length args) n)
        #t
        (eopl:error quien "Se esperaban al menos ~s argumentos y llegaron ~s" n (length args)))))

;; aplicar-division : lista de números -> número
;; Levanta error si algún divisor es cero.
(define aplicar-division
  (lambda (args)
    (if (member 0 (cdr args))
        (eopl:error '/ "División por cero")
        (apply / args))))

;; evaluar-primitiva : primitiva x lista de valores -> valor
;; Verifica la cantidad y el tipo de los argumentos y aplica la
;; primitiva. Se resuelve con cases sobre el datatype primitiva.
(define evaluar-primitiva
  (lambda (prim args)
    (cases primitiva prim

      (sum-prim ()
        (exigir-minimo args 1 '+) (exigir-numeros args '+)
        (apply + args))
      (minus-prim ()
        (exigir-minimo args 1 '-) (exigir-numeros args '-)
        (apply - args))
      (mult-prim ()
        (exigir-minimo args 1 '*) (exigir-numeros args '*)
        (apply * args))
      (div-prim ()
        (exigir-minimo args 1 '/) (exigir-numeros args '/)
        (aplicar-division args))
      
      (add-prim ()
        (exigir-cantidad args 1 'add1) (exigir-numeros args 'add1)
        (+ (car args) 1))
      (sub-prim ()
        (exigir-cantidad args 1 'sub1) (exigir-numeros args 'sub1)
        (- (car args) 1))
      (not-prim ()
        (exigir-cantidad args 1 'not) (exigir-booleanos args 'not)
        (not (car args)))
      (abs-prim ()
        (exigir-cantidad args 1 'abs) (exigir-numeros args 'abs)
        (abs (car args)))
      
      (mayor-prim ()
        (exigir-cantidad args 2 '>) (exigir-numeros args '>)
        (> (car args) (cadr args)))
      (mayorigual-prim ()
        (exigir-cantidad args 2 '>=) (exigir-numeros args '>=)
        (>= (car args) (cadr args)))
      (menor-prim ()
        (exigir-cantidad args 2 '<) (exigir-numeros args '<)
        (< (car args) (cadr args)))
      (menorigual-prim ()
        (exigir-cantidad args 2 '<=) (exigir-numeros args '<=)
        (<= (car args) (cadr args)))
      (igual-prim ()
        (exigir-cantidad args 2 '==) (exigir-numeros args '==)
        (= (car args) (cadr args)))
      
      (and-prim ()
        (exigir-cantidad args 2 'and) (exigir-booleanos args 'and)
        (and (car args) (cadr args)))
      (or-prim ()
        (exigir-cantidad args 2 'or) (exigir-booleanos args 'or)
        (or (car args) (cadr args)))
      (xor-prim ()
        (exigir-cantidad args 2 'xor) (exigir-booleanos args 'xor)
        (not (eq? (car args) (cadr args))))
      (implica-prim ()
        (exigir-cantidad args 2 'implica) (exigir-booleanos args 'implica)
        (or (not (car args)) (cadr args)))
      
      (entre-prim ()
        (exigir-cantidad args 3 'entre) (exigir-numeros args 'entre)
        (and (<= (cadr args) (car args)) (<= (car args) (caddr args))))
      
      (mcd-prim ()
        (exigir-minimo args 2 'mcd) (exigir-enteros args 'mcd)
        (apply gcd args))
      (mcm-prim ()
        (exigir-minimo args 2 'mcm) (exigir-enteros args 'mcm)
        (apply lcm args))
      
      (promedio-prim ()
        (exigir-minimo args 1 'promedio) (exigir-numeros args 'promedio)
        (/ (apply + args) (length args))))))

(provide (all-defined-out))
