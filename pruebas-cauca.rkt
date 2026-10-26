#lang eopl
;Autores: Josue David Cocoma Tascon 2477087, Juan Diego Montaño Vergara 2477334

;; Taller 2 — El intérprete de Cauca.
;; Batería de pruebas con rackunit. Llega escrita en el fork y no se
;; modifica: las pruebas del grupo se agregan después, en suites nuevas
;; que se suman a la cuenta de fallidas del final.
;;
;; Requiere solamente la fachada, nunca un módulo de src/ por separado.
;;
;; Se ejecuta con:  racket pruebas-cauca.rkt

(require rackunit)
(require rackunit/text-ui)
(require (only-in racket/base exn:fail?))
(require (only-in racket/base with-handlers exn-message)) ; para hay-error? y mensaje-de
(require "interprete-cauca.rkt")

;; corre : string -> valor
(define corre (lambda (texto) (interpretar texto)))

(define base
  (test-suite
   "Parte 1: interprete base"
   (test-case "literales y variables del ambiente inicial"
              (check-equal? (corre "42") 42)
              (check-equal? (corre "-7") -7)
              (check-equal? (corre "3.5") 3.5)
              (check-equal? (corre "n") 10)
              (check-equal? (corre "r") 5))
   (test-case "booleanos"
              (check-equal? (corre "true") #t)
              (check-equal? (corre "false") #f))
   (test-case "primitivas aritmeticas n-arias"
              (check-equal? (corre "+(1, 2, 3)") 6)
              (check-equal? (corre "-(10, 3, 2)") 5)
              (check-equal? (corre "*(2, 3, 4)") 24)
              (check-equal? (corre "/(100, 5, 2)") 10))
   (test-case "primitivas unarias"
              (check-equal? (corre "add1(n)") 11)
              (check-equal? (corre "sub1(n)") 9)
              (check-equal? (corre "not(true)") #f))
   (test-case "primitivas relacionales"
              (check-equal? (corre ">(n, m)") #t)
              (check-equal? (corre ">=(m, m)") #t)
              (check-equal? (corre "<(q, r)") #t)
              (check-equal? (corre "<=(r, q)") #f)
              (check-equal? (corre "==(n, 10)") #t))
   (test-case "primitivas booleanas binarias"
              (check-equal? (corre "and(true, false)") #f)
              (check-equal? (corre "or(true, false)") #t))
   (test-case "condicional"
              (check-equal? (corre "if >(n, m) then n else m end") 10)
              (check-equal? (corre "if <(n, m) then n else m end") 3))
   (test-case "ligaduras locales"
              (check-equal? (corre "let x = 2 y = 3 in *(x, y) end") 6)
              (check-equal? (corre "let x = 1 in let x = 2 in x end end") 2)
              (check-equal? (corre "let x = 1 in +(x, n) end") 11))
   (test-case "el ejemplo del area del rectangulo"
              (check-equal? (corre "// el area de un rectangulo, con el condicional que valida los lados
let base = 8
    altura = 5
in
  if and(>(base, 0), >(altura, 0))
  then *(base, altura)
  else 0
  end
end") 40))
   (test-case "la condicion del if debe ser booleana"
              (check-exn exn:fail? (lambda () (corre "if n then 1 else 2 end"))))
   (test-case "una variable no ligada es un error"
              (check-exn exn:fail? (lambda () (corre "z"))))
   (test-case "los comentarios se ignoran"
              (check-equal? (corre "// esto no cuenta
7") 7))))

(define primitivas-nuevas
  (test-suite
   "Parte 2: primitivas nuevas"
   (test-case "abs"
              (check-equal? (corre "abs(-7)") 7)
              (check-equal? (corre "abs(7)") 7)
              (check-equal? (corre "abs(-3.5)") 3.5))
   (test-case "mcd"
              (check-equal? (corre "mcd(12, 18)") 6)
              (check-equal? (corre "mcd(7, 13)") 1)
              (check-equal? (corre "mcd(12, 18, 24)") 6))
   (test-case "mcm"
              (check-equal? (corre "mcm(4, 6)") 12)
              (check-equal? (corre "mcm(3, 5)") 15)
              (check-equal? (corre "mcm(2, 3, 4)") 12))
   (test-case "promedio"
              (check-equal? (corre "promedio(1, 2, 3, 4)") 5/2)
              (check-equal? (corre "promedio(10)") 10)
              (check-equal? (corre "promedio(n, m)") 13/2))
   (test-case "xor"
              (check-equal? (corre "xor(true, false)") #t)
              (check-equal? (corre "xor(true, true)") #f)
              (check-equal? (corre "xor(false, false)") #f))
   (test-case "implica"
              (check-equal? (corre "implica(true, false)") #f)
              (check-equal? (corre "implica(false, false)") #t)
              (check-equal? (corre "implica(true, true)") #t))
   (test-case "entre"
              (check-equal? (corre "entre(5, 1, 10)") #t)
              (check-equal? (corre "entre(1, 1, 10)") #t)
              (check-equal? (corre "entre(11, 1, 10)") #f))
   (test-case "las primitivas verifican el tipo de sus argumentos"
              (check-exn exn:fail? (lambda () (corre "mcd(1.5, 2)")))
              (check-exn exn:fail? (lambda () (corre "xor(1, true)")))
              (check-exn exn:fail? (lambda () (corre "abs(true)")))
              (check-exn exn:fail? (lambda () (corre "entre(1, 2)"))))))

(define procedimientos
  (test-suite
   "Parte 3: procedimientos y clausuras"
   (test-case "procedimiento de un parametro"
              (check-equal? (corre "let escalar = proc (v) *(v, 2) end
                                    in apply escalar (21) end") 42))
   (test-case "procedimiento sin parametros"
              (check-equal? (corre "let f = proc () 7 end in apply f () end") 7))
   (test-case "procedimiento de varios parametros"
              (check-equal? (corre "let f = proc (a, b, c) +(a, b, c) end
                                    in apply f (1, 2, 3) end") 6))
   (test-case "un procedimiento recibe otro como argumento"
              (check-equal? (corre "let aplicardos = proc (f, x) apply f (apply f (x)) end
                                        doble = proc (v) *(v, 2) end
                                    in apply aplicardos (doble, 5) end") 20))
   (test-case "un procedimiento retorna otro procedimiento"
              ;; el resultado de una aplicacion se liga antes de volver a
              ;; aplicarlo: <expresion> no puede empezar con parentesis
              (check-equal? (corre "let sumador = proc (a) proc (b) +(a, b) end end
                                    in let suma3 = apply sumador (3)
                                       in apply suma3 (4) end
                                    end") 7))
   (test-case "el cuerpo se evalua en el ambiente de la definicion"
              (check-equal? (corre "let factor = 10
in
  let escalar = proc (v) *(v, factor) end
  in
    let factor = 1000
    in
      apply escalar (5)
    end
  end
end") 50))
   (test-case "aplicar algo que no es procedimiento es un error"
              (check-exn exn:fail? (lambda () (corre "apply 5 (1)"))))
   (test-case "la cantidad de argumentos debe coincidir"
              (check-exn exn:fail?
                         (lambda () (corre "let f = proc (a, b) +(a, b) end
                                            in apply f (1) end"))))))

(define recursion-y-case
  (test-suite
   "Parte 4: recursion y seleccion por valor"
   (test-case "el ejemplo de potencia"
              (check-equal? (corre "letrec
  potencia (base, exp) = if ==(exp, 0)
                         then 1
                         else *(base, apply potencia (base, sub1(exp)))
                         end
in
  apply potencia (2, 10)
end") 1024))
   (test-case "recursion simple"
              (check-equal? (corre "letrec
  factorial (n) = if ==(n, 0) then 1 else *(n, apply factorial (sub1(n))) end
in apply factorial (5) end") 120))
   (test-case "recursion mutua en el mismo letrec"
              (check-equal? (corre "letrec
  par? (n) = if ==(n, 0) then true else apply impar? (sub1(n)) end
  impar? (n) = if ==(n, 0) then false else apply par? (sub1(n)) end
in apply par? (10) end") #t)
              (check-equal? (corre "letrec
  par? (n) = if ==(n, 0) then true else apply impar? (sub1(n)) end
  impar? (n) = if ==(n, 0) then false else apply par? (sub1(n)) end
in apply impar? (7) end") #t))
   (test-case "letrec con un procedimiento pasado como argumento"
              (check-equal? (corre "letrec
  aplicarn (f, x, veces) = if ==(veces, 0)
                           then x
                           else apply f (apply aplicarn (f, x, sub1(veces)))
                           end
in let doble = proc (v) *(v, 2) end
   in apply aplicarn (doble, 1, 5) end
end") 32))
   (test-case "el ejemplo de case"
              (check-equal? (corre "let dia = 3
in
  case dia
    of 1 => 100
    of 3 => 300
    of 7 => 700
    otherwise => 0
  end
end") 300))
   (test-case "case con la rama otherwise activa"
              (check-equal? (corre "let dia = 5
in case dia of 1 => 100 of 3 => 300 otherwise => 0 end end") 0))
   (test-case "case evalua la expresion de control una sola vez"
              (check-equal? (corre "case +(1, 2) of 2 => 20 of 3 => 30 otherwise => 0 end") 30))
   (test-case "el control de case debe ser numero"
              (check-exn exn:fail?
                         (lambda () (corre "case true of 1 => 1 otherwise => 0 end"))))))

; suites del grupo

; hay-error? : string -> boolean
; retorna #t si interpretar el texto levanta un error. Se usa para verificar los casos de error sin depender del texto del mensaje
(define hay-error?
  (lambda (texto)
    (with-handlers ((exn:fail? (lambda (e) #t)))
      (interpretar texto)
      #f)))

; mensaje-de : string -> string
; retorna el mensaje del error que levanta el programa, o "" si no levanta ninguno

(define mensaje-de
  (lambda (texto)
    (with-handlers ((exn:fail? (lambda (e) (exn-message e))))
      (interpretar texto)
      "")))

; contiene? : string x string -> boolean
; retorna #t si el primer texto contiene al segundo
(define contiene?
  (lambda (texto parte)
    (let ((n (string-length parte)))
      (letrec ((buscar (lambda (i)
                         (cond
                           ((> (+ i n) (string-length texto)) #f)
                           ((string=? (substring texto i (+ i n)) parte) #t)
                           (else (buscar (+ i 1)))))))
        (buscar 0)))))

(define scanner-pruebas
  (test-suite
   "Scanner"
   (test-case "numeros enteros y flotantes con signo"
              (check-equal? (scanner "42") '((numero 42 1)))
              (check-equal? (scanner "-7") '((numero -7 1)))
              (check-equal? (scanner "3.5") '((numero 3.5 1)))
              (check-equal? (scanner "-3.5") '((numero -3.5 1))))
   (test-case "identificadores con guion bajo, digitos e interrogacion"
              (check-equal? (scanner "valor_1?") '((identificador valor_1? 1)))
              (check-equal? (scanner "par?") '((identificador par? 1))))
   (test-case "los comentarios y los espacios se ignoran"
              (check-equal? (scanner "// nada\nx") '((identificador x 2)))
              (check-equal? (scanner "   x   ") '((identificador x 1)))
              (check-equal? (scanner "// solo comentario") '()))
   (test-case "una expresion produce un token por componente"
              (check-equal? (length (scanner "add1(n)")) 4)
              (check-equal? (length (scanner "<=(k, 3)")) 6)
              (check-equal? (length (scanner "if true then 1 else 0 end")) 7))
   (test-case "los simbolos se reconocen completos"
              (check-equal? (cadr (car (scanner "<="))) "<=")
              (check-equal? (cadr (car (scanner "=="))) "==")
              (check-equal? (cadr (car (scanner "=>"))) "=>"))))

(define parser-pruebas
  (test-suite
   "Parser"
   (test-case "literal y variable"
              (check-equal? (parser "42") (a-program (lit-exp 42)))
              (check-equal? (parser "n") (a-program (var-exp 'n))))
   (test-case "booleanos"
              (check-equal? (parser "true") (a-program (true-exp)))
              (check-equal? (parser "false") (a-program (false-exp))))
   (test-case "primitiva"
              (check-equal? (parser "add1(n)")
                            (a-program (prim-exp (add-prim) (list (var-exp 'n)))))
              (check-equal? (parser "+(1, 2)")
                            (a-program (prim-exp (sum-prim)
                                                 (list (lit-exp 1) (lit-exp 2))))))
   (test-case "condicional"
              (check-equal? (parser "if true then 1 else 2 end")
                            (a-program (if-exp (true-exp) (lit-exp 1) (lit-exp 2)))))
   (test-case "let con varias ligaduras"
              (check-equal? (parser "let x = 2 y = 3 in x end")
                            (a-program (let-exp '(x y)
                                                (list (lit-exp 2) (lit-exp 3))
                                                (var-exp 'x)))))
   (test-case "procedimiento y aplicacion"
              (check-equal? (parser "proc (a, b) a end")
                            (a-program (proc-exp '(a b) (var-exp 'a))))
              (check-equal? (parser "apply f (1, 2)")
                            (a-program (app-exp (var-exp 'f)
                                                (list (lit-exp 1) (lit-exp 2))))))
   (test-case "letrec y case"
              (check-equal? (parser "letrec f (x) = x in apply f (1) end")
                            (a-program (letrec-exp '(f) '((x)) (list (var-exp 'x))
                                                   (app-exp (var-exp 'f)
                                                            (list (lit-exp 1))))))
              (check-equal? (parser "case n of 1 => 2 otherwise => 0 end")
                            (a-program (case-exp (var-exp 'n) '(1) (list (lit-exp 2))
                                                 (lit-exp 0)))))
   (test-case "una gramatica mal formada levanta error"
              (check-exn exn:fail? (lambda () (parser "if true then 1 end")))
              (check-exn exn:fail? (lambda () (parser "let x = in x end")))
              (check-exn exn:fail? (lambda () (parser "apply (f) (1)"))))))

(define errores-pruebas
  (test-suite
   "Casos de error"
   (test-case "condicion no booleana"
              (check-true (hay-error? "if 1 then 2 else 3 end"))
              (check-true (contiene? (mensaje-de "if n then 1 else 2 end") "booleana")))
   (test-case "variable no ligada"
              (check-true (hay-error? "zzz"))
              (check-true (contiene? (mensaje-de "zzz") "no ligada"))
              ; la variable del let no existe fuera de su cuerpo
              (check-true (hay-error? "+(let w = 1 in w end, w)")))
   (test-case "operador que no es procedimiento"
              (check-true (hay-error? "apply 5 (1)"))
              (check-true (hay-error? "apply true ()"))
              (check-true (hay-error? "let x = 3 in apply x (1) end")))
   (test-case "cantidad de argumentos incorrecta en un procedimiento"
              (check-true (hay-error? "let f = proc (a) a end in apply f (1, 2) end"))
              (check-true (hay-error? "let f = proc () 1 end in apply f (1) end"))
              (check-true (hay-error? "letrec f (a, b) = a in apply f (1) end")))
   (test-case "argumento de tipo equivocado en una primitiva"
              (check-true (hay-error? "+(1, true)"))
              (check-true (hay-error? "not(1)"))
              (check-true (hay-error? "and(1, true)"))
              (check-true (hay-error? ">(true, 1)"))
              (check-true (hay-error? "mcm(1.5, 2)"))
              (check-true (hay-error? "promedio(true, 1)"))
              (check-true (hay-error? "implica(1, true)"))
              (check-true (hay-error? "entre(1, true, 3)")))
   (test-case "cantidad de argumentos incorrecta en una primitiva"
              (check-true (hay-error? "add1(1, 2)"))
              (check-true (hay-error? "mcd(4)"))
              (check-true (hay-error? "mcm(4)"))
              (check-true (hay-error? "promedio()"))
              (check-true (hay-error? "xor(true)"))
              (check-true (hay-error? "entre(1, 2)")))
   (test-case "division por cero, entera o flotante"
              (check-true (hay-error? "/(5, 0)"))
              (check-true (hay-error? "/(5, 0.0)"))
              (check-true (hay-error? "/(8, 2, 0)")))
   (test-case "valor de control de case no numerico"
              (check-true (hay-error? "case true of 1 => 1 otherwise => 0 end"))
              (check-true (hay-error? "case proc (x) x end of 1 => 1 otherwise => 0 end")))
   (test-case "let no permite recursion"
              (check-true
               (hay-error? "let f = proc (k) if ==(k, 0) then 0 else apply f (sub1(k)) end end
                            in apply f (3) end")))))

(define semantica-pruebas
  (test-suite
   "Semantica adicional"
   (test-case "shadowing"
              (check-equal? (corre "let n = 1 in n end") 1)
              (check-equal? (corre "let n = 1 in let n = +(n, 1) in n end end") 2)
              (check-equal? (corre "+(let n = 1 in n end, n)") 11))
   (test-case "let evalua sus ligaduras en el ambiente exterior"
              (check-equal? (corre "let x = 1 in let x = 2 y = x in y end end") 1))
   (test-case "if solo evalua la rama elegida"
              (check-equal? (corre "if true then 1 else zzz end") 1)
              (check-equal? (corre "if false then zzz else 2 end") 2))
   (test-case "los argumentos se evaluan de izquierda a derecha"
              (check-equal? (corre "-(10, 3, 2)") 5)
              (check-equal? (corre "/(100, 5, 2)") 10))
   (test-case "numeros flotantes"
              (check-equal? (corre "+(1.5, 2)") 3.5)
              (check-equal? (corre "*(2.5, 4)") 10.0)
              (check-equal? (corre "abs(-0.5)") 0.5))
   (test-case "primitivas nuevas dentro de otras expresiones"
              (check-equal? (corre "if entre(n, m, p) then 1 else 0 end") 0)
              (check-equal? (corre "if implica(false, true) then mcd(n, q) else 0 end") 2)
              (check-equal? (corre "mcm(abs(-4), 6)") 12))
   (test-case "una clausura recuerda el ambiente de su definicion"
              (check-equal? (corre "let contador = let paso = 5 in proc (x) +(x, paso) end end
                                    in let paso = 100 in apply contador (1) end end") 6))
   (test-case "la aplicacion evalua el operador antes que los argumentos"
              (check-equal? (corre "let f = proc (a, b) -(a, b) end in apply f (10, 4) end") 6))
   (test-case "los parametros ocultan a las variables del ambiente"
              (check-equal? (corre "let f = proc (n) add1(n) end in apply f (1) end") 2))
   (test-case "letrec: un procedimiento ve a sus companeros del mismo letrec"
              (check-equal? (corre "letrec
  sumahasta (k) = if ==(k, 0) then 0 else +(k, apply sumahasta (sub1(k))) end
in apply sumahasta (10) end") 55))
   (test-case "letrec con varios procedimientos independientes"
              (check-equal? (corre "letrec
  doble (v) = *(v, 2)
  triple (v) = *(v, 3)
in +(apply doble (4), apply triple (4)) end") 20))
   (test-case "letrec mutuamente recursivo con tres procedimientos"
              (check-equal? (corre "letrec
  a (k) = if ==(k, 0) then 0 else apply b (sub1(k)) end
  b (k) = if ==(k, 0) then 1 else apply c (sub1(k)) end
  c (k) = if ==(k, 0) then 2 else apply a (sub1(k)) end
in apply a (7) end") 1))
   (test-case "case: primera coincidencia, literales negativos y flotantes"
              (check-equal? (corre "case 5 of 5 => 1 of 5 => 2 otherwise => 3 end") 1)
              (check-equal? (corre "case -2 of -2 => 10 otherwise => 0 end") 10)
              (check-equal? (corre "case 2.5 of 2.5 => 1 otherwise => 0 end") 1))
   (test-case "case: solo se evalua la accion elegida"
              (check-equal? (corre "case 1 of 1 => 7 of 2 => zzz otherwise => zzz end") 7))
   (test-case "case anidado y dentro de un procedimiento"
              (check-equal? (corre "let nombre = proc (d) case d of 1 => 10 of 2 => 20 otherwise => 0 end end
                                    in +(apply nombre (1), apply nombre (2), apply nombre (9)) end") 30))
   (test-case "los programas de los informes"
              (check-equal? (corre "let umbral = promedio(n, m, p)
in
  letrec
    contar (k) = if <=(k, umbral)
                 then apply contar (add1(k))
                 else k
                 end
  in
    case apply contar (1)
      of 7 => abs(-(umbral, 7))
      otherwise => mcd(n, m)
    end
  end
end") 1/3)
              (check-equal? (corre "let desplazar = proc (x, d) +(x, d) end
in
  letrec
    acumular (i, total) = if >(i, m)
                          then total
                          else apply acumular
                                 (add1(i), apply desplazar (total, i))
                          end
  in
    apply acumular (1, q)
  end
end") 8))))

;; Las suites que agregue el grupo se declaran arriba y se suman aquí.

(define fallidas
  (+ (run-tests base)
     (run-tests primitivas-nuevas)
     (run-tests procedimientos)
     (run-tests recursion-y-case)
     (run-tests scanner-pruebas)
     (run-tests parser-pruebas)
     (run-tests errores-pruebas)
     (run-tests semantica-pruebas)))

(eopl:printf "~%==========================================~%")
(eopl:printf "  pruebas fallidas en total: ~s~%" fallidas)
(eopl:printf "==========================================~%")
