#lang eopl
;Autores: Josue David Cocoma Tascon 2477087, Juan Diego Montaño Vergara 2477334

;; Taller 2 — El intérprete de Cauca.
;; El punto de entrada y el REPL. Requiere sintaxis.rkt e interprete.rkt.

(require "sintaxis.rkt")
(require "interprete.rkt")

;; interpretar : string -> valor
;; Analiza el texto de un programa con el parser y evalúa el árbol
;; resultante con evaluar-programa.
(define interpretar
  (lambda (texto)
    (evaluar-programa (parser texto))))

;; interpretador : -> void
;; REPL de Cauca, que se abre con (interpretador). Se construye con
;; sllgen:make-rep-loop sobre evaluar-programa y el parser de flujo que
;; da sllgen:make-stream-parser.
(define interpretador
  (lambda ()
    ((sllgen:make-rep-loop "Cauca> "
                           evaluar-programa
                           (sllgen:make-stream-parser especificacion-lexica
                                                      especificacion-gramatical)))))

(provide (all-defined-out))
