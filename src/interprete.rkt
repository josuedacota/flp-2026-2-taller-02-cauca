#lang eopl
;Autores: Josue David Cocoma Tascon 2477087, Juan Diego Montaño Vergara 2477334

;; Taller 2 — El intérprete de Cauca.
;; El recorrido de la sintaxis abstracta y la aplicación de
;; procedimientos. Requiere sintaxis.rkt, valores.rkt, ambiente.rkt y
;; primitivas.rkt.
;;
;; apply-procedure vive aquí y no en valores.rkt porque llama a
;; evaluar-expresion.

(require "sintaxis.rkt")
(require "valores.rkt")
(require "ambiente.rkt")
(require "primitivas.rkt")

;; apply-procedure : procval x lista de valores -> valor
;; Verifica que la cantidad de argumentos coincida con la de parámetros
;; y evalúa el cuerpo en el ambiente de la clausura extendido con las
;; ligaduras de los parámetros, no en el ambiente de la llamada.
(define apply-procedure
  (lambda (proc args)
    (cases procval proc
      (cerradura (ids body saved-env)
        (if (= (length ids) (length args))
            (evaluar-expresion body (ambiente-extendido ids args saved-env))
            (eopl:error 'apply-procedure
                        "El procedimiento espera ~s argumentos y recibió ~s"
                        (length ids) (length args)))))))

;; evaluar-programa : programa -> valor
;; Punto de entrada: evalúa la expresión del programa en el ambiente
;; inicial.
(define evaluar-programa
  (lambda (pgm)
    (cases programa pgm
      (a-program (exp)
        (evaluar-expresion exp (ambiente-inicial))))))

;; evaluar-rands : lista de expresiones x ambiente -> lista de valores
;; Evalúa las expresiones de izquierda a derecha en el mismo ambiente.
(define evaluar-rands
  (lambda (rands env)
    (if (null? rands)
        '()
        (let ((primero (evaluar-expresion (car rands) env)))
          (cons primero (evaluar-rands (cdr rands) env))))))

;; seleccionar-rama : numero x lista de numeros x lista de expresiones x
;;                    expresion x ambiente -> valor
;; Evalúa la acción de la primera rama cuyo literal es igual al valor de
;; control, o la rama otherwise si no hay ninguna coincidencia
(define seleccionar-rama
  (lambda (control valores acciones default env)
    (cond
      ((null? valores) (evaluar-expresion default env))
      ((= control (car valores)) (evaluar-expresion (car acciones) env))
      (else (seleccionar-rama control (cdr valores) (cdr acciones) default env)))))

;; evaluar-expresion : expresion x ambiente -> valor
;; Recorre el árbol de sintaxis abstracta con cases y evalúa cada
;; variante según la semántica del enunciado. El if liga el resultado de
;; la condición a test-value, lo verifica con boolean? y solo entonces
;; ramifica; el case evalúa la expresión de control una sola vez.
(define evaluar-expresion
  (lambda (exp env)
    (cases expresion exp
      (lit-exp (dato) dato)
      (var-exp (id) (apply-env env id))
      (true-exp () #t)
      (false-exp () #f)
      (prim-exp (prim rands)
        (evaluar-primitiva prim (evaluar-rands rands env)))
      (if-exp (test rama-then rama-else)
        (let ((test-value (evaluar-expresion test env)))
          (if (boolean? test-value)
              (if test-value
                  (evaluar-expresion rama-then env)
                  (evaluar-expresion rama-else env))
              (eopl:error 'if-exp "La condición debe ser booleana y llegó ~s"
                          test-value))))
      (let-exp (ids rands body)
        (let ((valores (evaluar-rands rands env)))
          (evaluar-expresion body (ambiente-extendido ids valores env))))
      (proc-exp (ids body)
        (cerradura ids body env))
      (app-exp (rator rands)
        (let ((proc (evaluar-expresion rator env)))
          (if (procval? proc)
              (let ((args (evaluar-rands rands env)))
                (apply-procedure proc args))
              (eopl:error 'app-exp "Se intentó aplicar algo que no es un procedimiento: ~s"
                          proc))))
      (letrec-exp (proc-names idss bodies body)
        (evaluar-expresion body
                           (ambiente-recursivo proc-names idss bodies env)))
      (case-exp (control valores acciones default)
        (let ((valor-control (evaluar-expresion control env)))
          (if (number? valor-control)
              (seleccionar-rama valor-control valores acciones default env)
              (eopl:error 'case-exp "El valor de control debe ser un número y llegó ~s"
                          valor-control)))))))

(provide (all-defined-out))
