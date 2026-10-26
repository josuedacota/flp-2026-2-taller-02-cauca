#lang eopl
;Autores: Josue David Cocoma Tascon 2477087, Juan Diego Montaño Vergara 2477334

;; Taller 2 — El intérprete de Cauca.
;; Fachada: reúne los seis módulos de src/ y reexporta todo lo que
;; definen, de modo que quien la requiera vea todos los nombres sin
;; requerir los módulos uno por uno.
;;
;;   src/sintaxis.rkt    especificación léxica y gramatical, scanner, parser
;;   src/valores.rkt     el valor procedimiento
;;   src/ambiente.rkt    el TAD ambiente y el ambiente inicial
;;   src/primitivas.rkt  las primitivas y sus verificaciones
;;   src/interprete.rkt  la evaluación y la aplicación de procedimientos
;;   src/interfaz.rkt    el punto de entrada y el REPL
;;
;; Los require van en un solo sentido. Racket no carga dos módulos que se
;; requieran entre sí.

(require "src/sintaxis.rkt")
(require "src/valores.rkt")
(require "src/ambiente.rkt")
(require "src/primitivas.rkt")
(require "src/interprete.rkt")
(require "src/interfaz.rkt")

(provide (all-from-out "src/sintaxis.rkt"
                       "src/valores.rkt"
                       "src/ambiente.rkt"
                       "src/primitivas.rkt"
                       "src/interprete.rkt"
                       "src/interfaz.rkt"))

;;; ==========================================================
;;; Ejemplos
;;; ==========================================================

#|
  Ejemplos del enunciado, con el resultado de cada uno escrito al lado.
  Todos se obtuvieron ejecutando (interpretar ...), (scanner ...) y
  (parser ...) sobre esta fachada. Las pruebas con rackunit viven en
  pruebas-cauca.rkt.

  Convenciones: "error: ..." es el mensaje del eopl:error que levanta el
  programa. El ambiente inicial es n = 10, m = 3, p = 7, q = 2, r = 5.
  Los nombres literal-string<N> que muestra el scanner para las palabras
  reservadas y los símbolos los numera SLLGEN.

  Scanner (5 ejemplos)
    (scanner "42")
      =>  ((numero 42 1))
    (scanner "-3.5")
      =>  ((numero -3.5 1))
    (scanner "// nada\nvalor_1?")
      =>  ((identificador valor_1? 2))
    (scanner "<=(k, 3)")
      =>  ((literal-string47 "<=" 1) (literal-string47 "(" 1) (identificador k 1) (literal-string47 "," 1) (numero 3 1) (literal-string47 ")" 1))
    (scanner "if true then 1 else 0 end")
      =>  ((literal-string47 "if" 1) (literal-string47 "true" 1) (literal-string47 "then" 1) (numero 1 1) (literal-string47 "else" 1) (numero 0 1) (literal-string47 "end" 1))

  Parser (8 ejemplos)
    (parser "42")
      =>  #(struct:a-program #(struct:lit-exp 42))
    (parser "add1(n)")
      =>  #(struct:a-program #(struct:prim-exp #(struct:add-prim) (#(struct:var-exp n))))
    (parser "if >(n, m) then n else m end")
      =>  #(struct:a-program #(struct:if-exp #(struct:prim-exp #(struct:mayor-prim) (#(struct:var-exp n) #(struct:var-exp m))) #(struct:var-exp n) #(struct:var-exp m)))
    (parser "let x = 2 y = 3 in *(x, y) end")
      =>  #(struct:a-program #(struct:let-exp (x y) (#(struct:lit-exp 2) #(struct:lit-exp 3)) #(struct:prim-exp #(struct:mult-prim) (#(struct:var-exp x) #(struct:var-exp y)))))
    (parser "proc (a, b) +(a, b) end")
      =>  #(struct:a-program #(struct:proc-exp (a b) #(struct:prim-exp #(struct:sum-prim) (#(struct:var-exp a) #(struct:var-exp b)))))
    (parser "apply f (1, 2)")
      =>  #(struct:a-program #(struct:app-exp #(struct:var-exp f) (#(struct:lit-exp 1) #(struct:lit-exp 2))))
    (parser "case n of 1 => 2 otherwise => 0 end")
      =>  #(struct:a-program #(struct:case-exp #(struct:var-exp n) (1) (#(struct:lit-exp 2)) #(struct:lit-exp 0)))
    (parser "letrec f (x) = x in apply f (1) end")
      =>  #(struct:a-program #(struct:letrec-exp (f) ((x)) (#(struct:var-exp x)) #(struct:app-exp #(struct:var-exp f) (#(struct:lit-exp 1)))))

  Ejecución del lenguaje base (Parte 1)
    (interpretar "42")   =>  42
    (interpretar "+(n, m, p)")   =>  20
    (interpretar "-(n, m, 2)")   =>  5
    (interpretar "*(2.5, 4)")   =>  10.0
    (interpretar "/(n, q)")   =>  5
    (interpretar "add1(sub1(r))")   =>  5
    (interpretar ">=(n, m)")   =>  #t
    (interpretar "and(true, not(false))")   =>  #t
    (interpretar "if <(n, m) then n else m end")   =>  3
    (interpretar "let x = 2 y = 3 in *(x, y) end")   =>  6
    (interpretar "let x = 1 in let x = 2 in +(x, n) end end")   =>  12
    (interpretar "// el area de un rectangulo, con el condicional que valida los lados
let base = 8
    altura = 5
in
  if and(>(base, 0), >(altura, 0))
  then *(base, altura)
  else 0
  end
end")
      =>  40
    (interpretar "if n then 1 else 2 end")   =>  error: if-exp: La condición debe ser booleana y llegó 10
    (interpretar "z")   =>  error: apply-env: Variable no ligada: z
    (interpretar "/(5, 0)")   =>  error: /: División por cero
    (interpretar "+(1, true)")   =>  error: +: Se esperaba un número y llegó #t

  Primitivas nuevas (Parte 2)
    (interpretar "abs(-7)")   =>  7
    (interpretar "abs(3)")   =>  3
    (interpretar "abs(-2.5)")   =>  2.5
    (interpretar "abs(true)")   =>  error: abs: Se esperaba un número y llegó #t
    (interpretar "mcd(12, 18)")   =>  6
    (interpretar "mcd(12, 18, 24)")   =>  6
    (interpretar "mcd(7, 13)")   =>  1
    (interpretar "mcd(1.5, 2)")   =>  error: mcd: Se esperaba un entero y llegó 1.5
    (interpretar "mcd(4)")   =>  error: mcd: Se esperaban al menos 2 argumentos y llegaron 1
    (interpretar "mcm(4, 6)")   =>  12
    (interpretar "mcm(2, 3, 4)")   =>  12
    (interpretar "mcm(3, 5)")   =>  15
    (interpretar "mcm(2, true)")   =>  error: mcm: Se esperaba un entero y llegó #t
    (interpretar "promedio(1, 2, 3, 4)")   =>  5/2
    (interpretar "promedio(10)")   =>  10
    (interpretar "promedio(n, m)")   =>  13/2
    (interpretar "promedio(true)")   =>  error: promedio: Se esperaba un número y llegó #t
    (interpretar "xor(true, false)")   =>  #t
    (interpretar "xor(true, true)")   =>  #f
    (interpretar "xor(false, false)")   =>  #f
    (interpretar "xor(1, true)")   =>  error: xor: Se esperaba un booleano y llegó 1
    (interpretar "implica(true, false)")   =>  #f
    (interpretar "implica(false, false)")   =>  #t
    (interpretar "implica(true, true)")   =>  #t
    (interpretar "implica(1, false)")   =>  error: implica: Se esperaba un booleano y llegó 1
    (interpretar "entre(5, 1, 10)")   =>  #t
    (interpretar "entre(1, 1, 10)")   =>  #t
    (interpretar "entre(11, 1, 10)")   =>  #f
    (interpretar "entre(true, 1, 2)")   =>  error: entre: Se esperaba un número y llegó #t

  Procedimientos y clausuras (Parte 3)
    (interpretar "let f = proc () 7 end in apply f () end")   =>  7
    (interpretar "let doble = proc (v) *(v, 2) end in apply doble (21) end")   =>  42
    (interpretar "let f = proc (a, b, c) +(a, b, c) end in apply f (1, 2, 3) end")   =>  6
    (interpretar "let aplicardos = proc (f, x) apply f (apply f (x)) end doble = proc (v) *(v, 2) end in apply aplicardos (doble, 5) end")   =>  20
    (interpretar "let sumador = proc (a) proc (b) +(a, b) end end in let suma3 = apply sumador (3) in apply suma3 (4) end end")   =>  7
    (interpretar "let factor = 10
in
  let escalar = proc (v) *(v, factor) end
  in
    let factor = 1000
    in
      apply escalar (5)
    end
  end
end")
      =>  50
    (interpretar "apply 5 (1)")   =>  error: app-exp: Se intentó aplicar algo que no es un procedimiento: 5
    (interpretar "let f = proc (a, b) +(a, b) end in apply f (1) end")   =>  error: apply-procedure: El procedimiento espera 2 argumentos y recibió 1

  Recursión (Parte 4.1)
    (interpretar "letrec
  potencia (base, exp) = if ==(exp, 0)
                         then 1
                         else *(base, apply potencia (base, sub1(exp)))
                         end
in
  apply potencia (2, 10)
end")
      =>  1024
    (interpretar "letrec factorial (k) = if ==(k, 0) then 1 else *(k, apply factorial (sub1(k))) end in apply factorial (5) end")   =>  120
    (interpretar "letrec
  par? (k) = if ==(k, 0) then true else apply impar? (sub1(k)) end
  impar? (k) = if ==(k, 0) then false else apply par? (sub1(k)) end
in apply par? (10) end")
      =>  #t
    (interpretar "letrec aplicarn (f, x, veces) = if ==(veces, 0) then x else apply f (apply aplicarn (f, x, sub1(veces))) end in let doble = proc (v) *(v, 2) end in apply aplicarn (doble, 1, 5) end end")   =>  32
    (interpretar "let potencia = proc (base, exp) if ==(exp, 0) then 1 else *(base, apply potencia (base, sub1(exp))) end end in apply potencia (2, 10) end")   =>  error: apply-env: Variable no ligada: potencia

  Selección por valor (Parte 4.2)
    (interpretar "let dia = 3
in
  case dia
    of 1 => 100
    of 3 => 300
    of 7 => 700
    otherwise => 0
  end
end")
      =>  300
    (interpretar "case +(2, 3) of 1 => 10 of 5 => 50 otherwise => 0 end")   =>  50
    (interpretar "let dia = 9 in case dia of 1 => 100 of 3 => 300 otherwise => 0 end end")   =>  0
    (interpretar "case true of 1 => 1 otherwise => 0 end")   =>  error: case-exp: El valor de control debe ser un número y llegó #t

  Programas de los informes (Parte 5)
    (interpretar "let umbral = promedio(n, m, p)
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
end")
      =>  1/3
    (interpretar "let desplazar = proc (x, d) +(x, d) end
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
end")
      =>  8
|#