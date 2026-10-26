# Taller 2 — El intérprete de Cauca

Fundamentos de Interpretación y Compilación de Lenguajes de Programación
Escuela de Ingeniería de Sistemas y Computación, Universidad del Valle
Carlos Andrés Delgado Saavedra

Cauca es un lenguaje con números, booleanos, primitivas, condicional y
ligaduras locales, al que se le agregan procedimientos con clausuras y
ligadura recursiva. El intérprete se construye con `#lang eopl` y SLLGEN,
repartido en seis módulos dentro de `src/`. El enunciado completo, con la
gramática, las partes y las rúbricas, está publicado en el Campus Virtual.
Este repositorio es el punto de partida del grupo.

## Integrantes

Esta tabla es lo que identifica al grupo. Sin ella, o con algún dato
incompleto, la entrega pierde el 20 %; quien no aparezca aquí no cuenta como
parte del grupo.

| Nombre completo | Código | Correo institucional |
|---|---|---|
| Josue David Cocoma Tascon | 2477087 | COMPLETAR@correounivalle.edu.co |
| Juan Diego Montaño Vergara | 2477334 | COMPLETAR@correounivalle.edu.co |

## Cómo se entrega

1. **Se trabaja sobre un fork de este repositorio.** El grupo hace fork, lo
   deja público y trabaja ahí. Una entrega que no sea fork de este
   repositorio pierde el 30 % de la nota.
2. **El enlace del fork se pega en la actividad del taller en el Campus
   Virtual.** Nada más: ni archivos, ni comprimidos, ni código por correo.
3. **Se califica el último commit anterior a la fecha y hora de cierre**, el
   lunes 26 de octubre de 2026 a las 17:58:59. Lo que se suba después no se
   tiene en cuenta.
4. Solo archivos de texto: código `.rkt` en `src/` y en la raíz, e informes
   `.md` en `docs/`. Fórmulas en LaTeX y diagramas en Mermaid dentro del
   Markdown; no se aceptan PDF, DOCX ni imágenes.
5. Las primeras líneas de cada `.rkt` llevan los autores:
   `;Autores: Nombre1 Codigo1, Nombre2 Codigo2`.
6. Cada función va comentada con su nombre, su contrato (entrada -> salida) y
   su propósito.
7. El historial de commits se revisa para ver el aporte de cada integrante.
   Los cambios de puro formato o de comentarios no cuentan.

## Cómo está organizado

```
src/sintaxis.rkt             Especificación léxica y gramatical, scanner, parser
src/valores.rkt              El valor procedimiento: la clausura
src/ambiente.rkt             El TAD ambiente, apply-env y el ambiente inicial
src/primitivas.rkt           Las primitivas y sus verificaciones
src/interprete.rkt           La evaluación y la aplicación de procedimientos
src/interfaz.rkt             El punto de entrada y el REPL
interprete-cauca.rkt         La fachada: reúne los seis módulos y los reexporta
pruebas-cauca.rkt            La batería con rackunit; llega escrita y no se modifica
docs/informe-ast.md          Parte 5: se llena la plantilla
docs/informe-correccion.md   Parte 6: se llena la plantilla
```

Cada módulo exporta lo que define con `(provide (all-defined-out))` y la
fachada lo reexporta con `(provide (all-from-out ...))`. Los módulos no
contienen pruebas: las pruebas requieren la fachada, nunca un módulo de
`src/` por separado.

**Los `require` van en un solo sentido.** Racket no carga dos módulos que se
requieran entre sí: levanta `cycle in loading`. El único nudo real es que
`apply-env` construye clausuras al resolver `letrec` y la clausura guarda un
ambiente. Se corta declarando el campo del ambiente en `cerradura` con un
predicado que acepta cualquier valor, `(env (lambda (v) #t))`, y es
`ambiente.rkt` el que requiere a `valores.rkt`.

Las funciones llegan como huecos que levantan `eopl:error` con el mensaje
`"Sin implementar"`, con el nombre y el contrato comentados encima. Los
`define-datatype` de `valores.rkt` y de `ambiente.rkt` están descritos en la
cabecera de cada módulo, con sus variantes y sus campos. Las plantillas de
`docs/` se llenan en el mismo archivo, reemplazando los marcadores `{{...}}`
y sin quitar las secciones.

## Cómo se corre

```bash
racket pruebas-cauca.rkt
```

Mientras falten implementaciones la batería corre igual y reporta las
pruebas que fallan. En DrRacket, `(interpretador)` abre el REPL del lenguaje;
para evaluar un programa suelto:

```racket
(require "interprete-cauca.rkt")
(interpretar "let x = 2 y = 3 in *(x, y) end")
(parser "if >(n, m) then n else m end")
(scanner "add1(n)")
```

Los ejemplos del scanner, del parser y de ejecución que pide el enunciado van
en el bloque de comentario del final de `interprete-cauca.rkt`, cada uno con
su resultado al lado.
