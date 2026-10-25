#lang eopl
;Autores: Josue David Cocoma Tascon 2477087, Juan Diego Montaño Vergara 2477334

;; Taller 2 — El intérprete de Cauca.
;; El valor procedimiento. Requiere sintaxis.rkt.
;;
;; Aquí se declara con define-datatype el tipo procval, con un solo
;; constructor:
;;
;;   cerradura(ids, body, env)
;;     ids   (list-of symbol?)  los parámetros del procedimiento
;;     body  expresion?         el cuerpo, guardado sin evaluar
;;     env                      el ambiente vigente donde se definió
;;
;; El campo env se declara con un predicado que acepta cualquier valor,
;; (env (lambda (v) #t)). Exigir ambiente? obligaría a requerir
;; ambiente.rkt desde aquí, y ambiente.rkt ya requiere este módulo para
;; construir clausuras al resolver letrec: Racket no carga dos módulos
;; que se requieran entre sí, levanta cycle in loading. Es el único
;; campo que queda sin verificar.

(require "sintaxis.rkt")

;; procval : tipo de dato
;; Contrato: cerradura(ids, body, env) -> procval
;; Representa un procedimiento como sus parametros, su cuerpo
;; sin evaluar y el ambiente vigente en el momento de la definicion
(define-datatype procval procval?
  (cerradura
   (ids (list-of symbol?))
   (body expresion?)
   (env (lambda (v) #t))))

(provide (all-defined-out))
