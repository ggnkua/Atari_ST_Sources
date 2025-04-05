; PP.LSP -- a pretty-printer for XLISP.

; Adapted by Jim Chapman (Bix: jchapman) from a program written originally
; for IQLISP by Don Cohen.  Copyright (c) 1984, Don Cohen; (c) 1987, Jim
; Chapman.  Permission for non-commercial use and distribution is hereby 
; granted.  Modified for XLISP 2.0 by David Betz.

; In addition to the pretty-printer itself, this file contains a few functions
; that illustrate some simple but useful applications.

; The basic function accepts two arguments:

;      (PP OBJECT STREAM)

; where OBJECT is any Lisp expression, and STREAM optionally specifies the
; output (default is *standard-output*).

; PP-FILE pretty-prints an entire file.  It is what I used to produce this
; file (before adding the comments manually).  The syntax is:

;       (PP-FILE "filename" STREAM)

; where the file name must be a string or quoted, and STREAM, again, is the
; optional output destination.

; PP-DEF works just like PP, except its first argument is assumed to be the
; name of a function or macro, which is translated back into the original
; DEFUN or DEFMACRO form before printing.


; MISCELLANEOUS USAGE AND CUSTOMIZATION NOTES:

; 1.  The program uses tabs whenever possible for indentation.
;     This greatly reduces the cost of the blank space.  If your output
;     device doesn't support tabs, set TABSIZE to NIL -- which is what I
;     did when I pretty-printed this file, because of uncertainty 
;     about the result after uploading.

; 2.  Printmacros are used to handle special forms.  A printmacro is not
;     really a macro, just an ordinary lambda form that is stored on the
;     target symbol's property list.  The default printer handles the form
;     if there is no printmacro or if the printmacro returns NIL.

; 3.  Note that all the pretty-printer subfunctions, including the
;     the printmacros, return the current column position.

; 4.  Miser mode is not fully implemented in this version, mainly because  
;     lookahead was too slow.  The idea is, if the "normal" way of
;     printing the current expression would exceed the right margin, then
;     use a mode that conserves horizontal space.

; 5.  When PP gets to the last 8th of the line and has more to print than
;     fits on the line, it starts near the left margin.  This is not 
;     wonderful, but neither are the alternatives.  If you have a better
;     idea, go for it.

;  6. Storage requirements are about 1450 cells to load.  

;  7. I tested this with XLISP 1.7 on an Amiga.

;(DEFUN SYM-FUNCTION (X)	;for Xlisp 1.7
;    (CAR (SYMBOL-VALUE X)))
(DEFUN SYM-FUNCTION (X)		;for Xlisp 2.0
    (GET-LAMBDA-EXPRESSION (SYMBOL-FUNCTION X)))

(SETQ TABSIZE 8)	;set this to NIL for no tabs

(SETQ MAXSIZE 50)	;for readability, PP tries not to print more
			;than this many characters on a line

(SETQ MISER-SIZE 2)	;the indentation in miser mode

(SETQ MIN-MISER-CAR 4)	;used for deciding when to use miser mode

(SETQ MAX-NORMAL-CAR 9)	;ditto


; The following function prints a file

(DEFUN PP-FILE (FILENAME &OPTIONAL STREAMOUT)
    (OR STREAMOUT (SETQ STREAMOUT *STANDARD-OUTPUT*))
    (PRINC "; Listing of " STREAMOUT)
    (PRINC FILENAME STREAMOUT)
    (TERPRI STREAMOUT)
    (TERPRI STREAMOUT)
    (DO* ((FP (OPENI FILENAME)) (EXPR (READ FP) (READ FP)))
         ((NULL EXPR) (CLOSE FP))
      (PP EXPR STREAMOUT)
      (TERPRI STREAMOUT)))


; Print a lambda or macro form as a DEFUN or DEFMACRO:

(DEFMACRO PP-DEF (WHO &OPTIONAL STREAM)
    `(PP (MAKE-DEF ,WHO) ,STREAM))

(DEFMACRO MAKE-DEF (NAME &AUX EXPR TYPE)
    (SETQ EXPR (SYM-FUNCTION NAME))
    (SETQ TYPE
          (CADR (ASSOC (CAR EXPR)
                       '((LAMBDA DEFUN) (MACRO DEFMACRO)))))
    (LIST 'QUOTE
          (APPEND (LIST TYPE NAME) (CDR EXPR))))



; The pretty-printer high level function:

(DEFUN PP (X &OPTIONAL STREAM)
    (OR STREAM (SETQ STREAM *STANDARD-OUTPUT*))
    (PP1 X STREAM 1 80)
    (TERPRI STREAM)
    T)

(DEFUN PP1 (X STREAM CURPOS RMARGIN &AUX SIZE POSITION WIDTH)
    (COND ((NOT (CONSP X)) (PRIN1 X STREAM) (+ CURPOS (FLATSIZE X)))
          ((PRINTMACROP X STREAM CURPOS RMARGIN))
          ((AND (> (FLATSIZE X) (- RMARGIN CURPOS))
                (< (* 8 (- RMARGIN CURPOS)) RMARGIN))
           (SETQ SIZE (+ (/ RMARGIN 8) (- CURPOS RMARGIN)))
           (MOVETO STREAM CURPOS SIZE)
           (SETQ POSITION (PP1 X STREAM SIZE RMARGIN))
           (MOVETO STREAM POSITION SIZE))
          (T (PRINC "(" STREAM)
             (SETQ POSITION
                   (PP1 (CAR X) STREAM (1+ CURPOS) RMARGIN))
             (COND ((AND (>= (SETQ WIDTH (- RMARGIN POSITION))
                             (SETQ SIZE (FLATSIZE (CDR X))))
                         (<= SIZE MAXSIZE))
                    (PP-REST-ACROSS (CDR X) STREAM POSITION RMARGIN))
                   ((CONSP (CAR X))
                    (MOVETO STREAM POSITION CURPOS)
                    (PP-REST (CDR X) STREAM CURPOS RMARGIN))
                   ((> (- POSITION CURPOS) MAX-NORMAL-CAR)
                    (MOVETO STREAM POSITION (+ CURPOS MISER-SIZE))
                    (PP-REST (CDR X) STREAM (+ CURPOS MISER-SIZE) RMARGIN))
                   (T (PP-REST (CDR X) STREAM POSITION RMARGIN))))))

; MOVETO controls indentating and tabbing.

(DEFUN MOVETO (STREAM CURPOS GOALPOS)
    (COND ((> CURPOS GOALPOS)
           (TERPRI STREAM)
           (SETQ CURPOS 1)
           (IF TABSIZE
               (DO NIL
                   ((< (- GOALPOS CURPOS) TABSIZE))
                 (PRINC "\t" STREAM)
                 (SETQ CURPOS (+ CURPOS TABSIZE))))))
    (SPACES (- GOALPOS CURPOS) STREAM)
    GOALPOS)

(DEFUN SPACES (N STREAM)
    (DOTIMES (I N) (PRINC " " STREAM)))

(DEFUN PP-REST-ACROSS (X STREAM CURPOS RMARGIN &AUX POSITION)
    (SETQ POSITION CURPOS)
    (PROG NIL
      LP
      (COND ((NULL X) (PRINC ")" STREAM) (RETURN (1+ POSITION)))
            ((NOT (CONSP X))
             (PRINC " . " STREAM)
             (PRIN1 X STREAM)
             (PRINC ")" STREAM)
             (RETURN (+ 4 POSITION (FLATSIZE X))))
            (T (PRINC " " STREAM)
               (SETQ POSITION
                     (PP1 (CAR X) STREAM (1+ POSITION) RMARGIN))
               (SETQ X (CDR X))
               (GO LP)))))

(DEFUN PP-REST (X STREAM CURPOS RMARGIN &AUX POSITION POS2)
    (SETQ POSITION CURPOS)
    (PROG NIL
      LP
      (COND ((NULL X) (PRINC ")" STREAM) (RETURN (1+ POSITION)))
            ((NOT (CONSP X))
             (AND (> (FLATSIZE X) (- (- RMARGIN POSITION) 3))
                  (SETQ POSITION (MOVETO STREAM POSITION CURPOS)))
             (PRINC " . " STREAM)
             (PRIN1 X STREAM)
             (PRINC ")" STREAM)
             (RETURN (+ POSITION 4 (FLATSIZE X))))
            ((AND (NOT (CONSP (CAR X)))
                  (<= (SETQ POS2 (+ 1 POSITION (FLATSIZE (CAR X))))
                      RMARGIN)
                  (<= POS2 (+ CURPOS MAXSIZE)))
             (PRINC " " STREAM)
             (PRIN1 (CAR X) STREAM)
             (SETQ POSITION POS2))
            (T (MOVETO STREAM POSITION (1+ CURPOS))
               (SETQ POSITION
                     (PP1 (CAR X) STREAM (1+ CURPOS) RMARGIN))))
      (COND ((AND (CONSP (CAR X)) (CDR X))
             (SETQ POSITION (MOVETO STREAM POSITION CURPOS))))
      (SETQ X (CDR X))
      (GO LP)))


; PRINTMACROP is the printmacro interface routine.  Note that the
; called function has the same argument list as PP1.  It may either
; decide not to handle the form, by returning NIL (and not printing)
; or it may print the form and return the resulting position.

(DEFUN PRINTMACROP (X STREAM CURPOS RMARGIN &AUX MACRO)
    (AND (SYMBOLP (CAR X))
         (SETQ MACRO (GET (CAR X) 'PRINTMACRO))
         (APPLY MACRO (LIST X STREAM CURPOS RMARGIN))))

; The remaining forms define various printmacros.

(DEFUN PP-BINDING-FORM (X STREAM POS RMAR &AUX CUR)
    (SETQ CUR POS)
    (COND ((AND (>= (- RMAR POS) (FLATSIZE X))
                (<= (FLATSIZE X) MAXSIZE)) NIL)
          ((> (LENGTH X) 2)
           (PRINC "(" STREAM)
           (PRIN1 (CAR X) STREAM)
           (PRINC " " STREAM)
           (SETQ CUR
                 (PP1 (CADR X)
                      STREAM
                      (+ 2 POS (FLATSIZE (CAR X)))
                      RMAR))
           (MOVETO STREAM CUR (+ POS 1))
           (PP-REST (CDDR X) STREAM (+ POS 1) RMAR))))

(DEFUN PP-DO-FORM (X STREAM POS RMAR &AUX CUR POS2)
    (SETQ CUR POS)
    (COND ((AND (>= (- RMAR POS) (FLATSIZE X))
                (<= (FLATSIZE X) MAXSIZE)) NIL)
          ((> (LENGTH X) 2)
           (PRINC "(" STREAM)
           (PRIN1 (CAR X) STREAM)
           (PRINC " " STREAM)
           (SETQ POS2 (+ 2 POS (FLATSIZE (CAR X))))
           (SETQ CUR (PP1 (CADR X) STREAM POS2 RMAR))
           (MOVETO STREAM CUR POS2)
           (SETQ CUR (PP1 (CADDR X) STREAM POS2 RMAR))
           (MOVETO STREAM CUR (+ POS 1))
           (PP-REST (CDDDR X) STREAM (+ POS 1) RMAR))))

(DEFUN PP-DEFINING-FORM (X STREAM POS RMAR &AUX CUR)
    (SETQ CUR POS)
    (COND ((AND (>= (- RMAR POS) (FLATSIZE X))
                (<= (FLATSIZE X) MAXSIZE)) NIL)
          ((> (LENGTH X) 3)
           (PRINC "(" STREAM)
           (PRIN1 (CAR X) STREAM)
           (PRINC " " STREAM)
           (PRIN1 (CADR X) STREAM)
           (PRINC " " STREAM)
           (SETQ CUR
                 (PP1 (CADDR X)
                      STREAM
                      (+ 3 POS (FLATSIZE (CAR X)) (FLATSIZE (CADR X)))
                      RMAR))
           (MOVETO STREAM CUR (+ 3 POS))
           (PP-REST (CDDDR X) STREAM (+ 3 POS) RMAR))))

(PUTPROP 'QUOTE
         '(LAMBDA (X STREAM POS RMARGIN)
            (COND ((AND (CDR X) (NULL (CDDR X)))
                   (PRINC "'" STREAM)
                   (PP1 (CADR X) STREAM (1+ POS) RMARGIN))))
         'PRINTMACRO)

(PUTPROP 'BACKQUOTE
         '(LAMBDA (X STREAM POS RMARGIN)
            (COND ((AND (CDR X) (NULL (CDDR X)))
                   (PRINC "`" STREAM)
                   (PP1 (CADR X) STREAM (1+ POS) RMARGIN))))
         'PRINTMACRO)

(PUTPROP 'COMMA
         '(LAMBDA (X STREAM POS RMARGIN)
            (COND ((AND (CDR X) (NULL (CDDR X)))
                   (PRINC "," STREAM)
                   (PP1 (CADR X) STREAM (1+ POS) RMARGIN))))
         'PRINTMACRO)

(PUTPROP 'COMMA-AT
         '(LAMBDA (X STREAM POS RMARGIN)
            (COND ((AND (CDR X) (NULL (CDDR X)))
                   (PRINC ",@" STREAM)
                   (PP1 (CADR X) STREAM (+ POS 2) RMARGIN))))
         'PRINTMACRO)

(PUTPROP 'FUNCTION
         '(LAMBDA (X STREAM POS RMARGIN)
            (COND ((AND (CDR X) (NULL (CDDR X)))
                   (PRINC "#'" STREAM)
                   (PP1 (CADR X) STREAM (+ POS 2) RMARGIN))))
         'PRINTMACRO)

(PUTPROP 'PROG
         'PP-BINDING-FORM
         'PRINTMACRO)

(PUTPROP 'PROG*
         'PP-BINDING-FORM
         'PRINTMACRO)

(PUTPROP 'LET
         'PP-BINDING-FORM
         'PRINTMACRO)

(PUTPROP 'LET*
         'PP-BINDING-FORM
         'PRINTMACRO)

(PUTPROP 'LAMBDA
         'PP-BINDING-FORM
         'PRINTMACRO)

(PUTPROP 'MACRO
         'PP-BINDING-FORM
         'PRINTMACRO)

(PUTPROP 'DO 'PP-DO-FORM 'PRINTMACRO)

(PUTPROP 'DO*
         'PP-DO-FORM
         'PRINTMACRO)

(PUTPROP 'DEFUN
         'PP-DEFINING-FORM
         'PRINTMACRO)

(PUTPROP 'DEFMACRO
         'PP-DEFINING-FORM
         'PRINTMACRO)

