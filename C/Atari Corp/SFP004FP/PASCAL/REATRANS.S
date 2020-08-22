fpstat  equ     $fffa40         ; Response word of MC68881 read
fpcmd   equ     $fffa4a         ; Command  word of MC68881 write
fpop    equ     $fffa50         ; Operand  long of MC68881 read/write

        .globl _fpset1          ; globale Definitionen aus fset.s
        .globl _fpset2
        .globl _fpget1          ; globale Definitionen aus fget.s
        .globl _fpget2

        .globl ARCCOS           ; acos(x)  -1 <= x <= 1
ARCCOS:   move.l  (sp)+,a0      ; R…ksprungadresse
          move.l  (sp)+,d3      ; 1. Teil von real
          move.w  (sp)+,d4      ; 2. Teil von real
          jsr     _fpset2       ; in FP2 schieben
L1:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L1
          move.w  #$089c,fpcmd  ; Funktion acos ausf”ren
          jsr     _fpget1       ; und Ergebnis aus FP1 in d0-d1 schieben
          jmp     (a0)          ; zur…k zum Aufrufer

        .globl ARCSIN           ; asin(x)   -1 <= x <= 1
ARCSIN:   move.l  (sp)+,a0      ; R…ksprungadresse
          move.l  (sp)+,d3      ; 1. Teil von real
          move.w  (sp)+,d4      ; 2. Teil von real
          jsr     _fpset2       ; nach FP2 schieben
L7:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L7
          move.w  #$88c,fpcmd   ; asin berechnen
          jsr     _fpget1       ; und Ergebnis aus FP1 nach d0-d1 schieben
          jmp     (a0)          ; zur…k zum Aufrufer

        .globl arctan           ; Funktion atan(x)
arctan:   move.l  (sp)+,a0      ; R…ksprungadresse
          move.l  (sp)+,d3      ; 1. Teil von real
          move.w  (sp)+,d4      ; 2. Teil von real
          jsr     _fpset2       ; in FP2 schieben
L13:      cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L13
          move.w  #$088a,fpcmd  ; atan berechnen, Ergebnis in FP1
          jsr     _fpget1       ; Ergebnis aus FP1 in d0-d1 schieben
          jmp     (a0)          ; zur…k zum Aufrufer

        .globl ARCTAN2          ; Funktion atan(x1/x2)
ARCTAN2:  move.l  (sp)+,a0      ; R…ksprungadresse
          move.l  (sp)+,d3      ; 1. Teil von real
          move.w  (sp)+,d4      ; 2. Teil von real
          jsr     _fpset2       ; nach FP2 schieben
          move.l  (sp)+,d3      ; 1. Teil von real
          move.w  (sp)+,d4      ; 2. Teil von real
          jsr     _fpset1       ; nach FP1 schieben
L14:      cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L14
          move.w  #$08a0,fpcmd  ; x1/x2 berechnen
L15:      cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L15
          move.w  #$050a,fpcmd  ; atan ausf”ren
          jsr     _fpget2       ; Ergebnis aus FP2 nach d0-d1 schieben
          jmp     (a0)          ; zur…k zum Aufrufer

        .globl ARCTANH          ; Funktion atanh(x)
ARCTANH:  move.l  (sp)+,a0      ; R…ksprungadresse
          move.l  (sp)+,d3      ; 1. Teil von real
          move.w  (sp)+,d4      ; 2. Teil von real
          jsr     _fpset2       ; nach FP2 schieben
L16:      cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L16
          move.w  #$088d,fpcmd  ; atanh berechnen
          jsr     _fpget1       ; Ergebnis aus FP1 nach d0-d1 schieben
          jmp     (a0)          ; zur…k zum Aufrufer

        .globl cos              ; Funktion cos(x)
cos:     move.l  (sp)+,a0      ; R…ksprungadresse
          move.l  (sp)+,d3      ; 1. Teil von real
          move.w  (sp)+,d4      ; 2. Teil von real
          jsr     _fpset2       ; nach FP2 schieben
L17:      cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L17
          move.w  #$089d,fpcmd  ; cos berechnen
          jsr     _fpget1       ; Ergebnis aus FP1 nach d0-d1 schieben
          jmp     (a0)          ; zur…k zum Aufrufer

        .globl COSH             ; Funktion cosh(x)
COSH:     move.l  (sp)+,a0      ; R…ksprungadresse
          move.l  (sp)+,d3      ; 1. Teil von real
          move.w  (sp)+,d4      ; 2. Teil von real
          jsr     _fpset2       ; nach FP2 schieben
L18:      cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L18
          move.w  #$0899,fpcmd  ; cosh berechnen
          jsr     _fpget1       ; Ergebnis aus FP1 nach d0-d1 schieben
          jmp     (a0)          ; zur…k zum Aufrufer

        .globl sin              ; Funktion sin(x)
sin:      move.l  (sp)+,a0      ; R…ksprungadresse
          move.l  (sp)+,d3      ; 1. Teil von real
          move.w  (sp)+,d4      ; 2. Teil von real
          jsr     _fpset2       ; nach FP2 schieben
L19:      cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L19
          move.w  #$088e,fpcmd  ; sin(x) berechnen
          jsr     _fpget1       ; Ergebnis aus FP1 nach d0-d1 schieben
          jmp     (a0)          ; zur…k zum Aufrufer

        .globl SINH             ; Funktion sinh(x)
SINH:     move.l  (sp)+,a0      ; R…ksprungadresse
          move.l  (sp)+,d3      ; 1. Teil von real
          move.w  (sp)+,d4      ; 2. Teil von real
          jsr     _fpset2       ; nach FP2 schieben
L20:      cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L20
          move.w  #$0882,fpcmd  ; sinh berechnen
          jsr     _fpget1       ; Ergebnis aus FP1 nach d0-d1 schieben
          jmp     (a0)          ; zur…k zum Aufrufer

        .globl TAN              ; Funktion tan(x)
TAN:      move.l  (sp)+,a0      ; R…ksprungadresse
          move.l  (sp)+,d3      ; 1. Teil von real
          move.w  (sp)+,d4      ; 2. Teil von real
          jsr     _fpset2       ; nach FP2 schieben
L21:      cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L21
          move.w  #$088f,fpcmd  ; tan berechnen
          jsr     _fpget1       ; Ergebnis aus FP1 nach d0-d1 schieben
          jmp     (a0)          ; zur…k zum Aufrufer

        .globl TANH             ; Funktion tanh(x)
TANH:     move.l  (sp)+,a0      ; R…ksprungadresse
          move.l  (sp)+,d3      ; 1. Teil von real
          move.w  (sp)+,d4      ; 2. Teil von real
          jsr     _fpset2       ; nach FP2 schieben
L22:      cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L22
          move.w  #$0889,fpcmd  ; tanh berechnen
          jsr     _fpget1       ; Ergebnis aus FP1 nach d0-d1 schieben
          jmp     (a0)          ; zur…k zum Aufrufer

        .globl ARCSINH          ; asinh = ln(x+sqrt(x^2-1))   x >= 1
ARCSINH:  move.l  (sp)+,a0      ; R…ksprungadresse
          move.l  (sp)+,d5      ; 1. Teil von real
          move.w  (sp)+,d6      ; 2. Teil von real
          move.l  d5,d3
          move.w  d6,d4
          jsr     _fpset1       ; in FP1 schieben
          move.l  d5,d3
          move.w  d6,d4
          jsr     _fpset2       ; in FP2 schieben
L23:      cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L23
          move.w  #$08a3,fpcmd  ; x^2 berechnen, Ergebnis in FP1
          move.l  _one1,d3      ; "1"
          move.w  _one2,d4
          jsr     _fpset2       ; nach FP2 schieben
L24:      cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L24
          move.w  #$08a2,fpcmd  ; x^2 + 1 berechnen, Ergebnis in FP1
L25:      cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L25
          move.w  #$0504,fpcmd  ; sqrt(x^2 + 1) berechnen, Ergebnis in FP2
          move.l  d5,d3
          move.w  d6,d4
          jsr     _fpset1       ; nach FP1 schieben
L26:      cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L26
          move.w  #$08a2,fpcmd  ; x+sqrt(x^2+1) berechnen, Ergebnis in FP1
L27:      cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L27
          move.w  #$0514,fpcmd  ; ln(x+sqrt(x^2+1)) berechnen
          jsr     _fpget2       ; und Ergebnis auf FP2 in d0-d1 schieben
          jmp     (a0)          ; zur…k zum Aufrufer

        .globl ARCCOSH          ; acosh = ln(x+sqrt(x^2-1))   x >= 1
ARCCOSH:  move.l  (sp)+,a0      ; R…ksprungadresse
          move.l  (sp)+,d5      ; 1. Teil von real
          move.w  (sp)+,d6      ; 2. Teil von real
          move.l  d5,d3
          move.w  d6,d4
          jsr     _fpset1       ; in FP1 schieben
          move.l  d5,d3
          move.w  d6,d4
          jsr     _fpset2       ; in FP2 schieben
L28:      cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L28
          move.w  #$08a3,fpcmd  ; x^2 berechnen, Ergebnis in FP1
          move.l  _one1,d3      ; "1"
          move.w  _one2,d4
          jsr     _fpset2       ; nach FP2 schieben
L29:      cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L29
          move.w  #$08a8,fpcmd  ; x^2 - 1 berechnen, Ergebnis in FP1
L30:      cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L30
          move.w  #$0504,fpcmd  ; sqrt(x^2 - 1) berechnen, Ergebnis in FP2
          move.l  d5,d3
          move.w  d6,d4
          jsr     _fpset1       ; nach FP1 schieben
L31:      cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L31
          move.w  #$08a2,fpcmd  ; x+sqrt(x^2-1) berechnen, Ergebnis in FP1
L32:      cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L32
          move.w  #$0514,fpcmd  ; ln(x+sqrt(x^2-1)) berechnen
          jsr     _fpget2       ; und Ergebnis auf FP2 in d0-d1 schieben
          jmp     (a0)          ; zur…k zum Aufrufer

        .data
_one1:  .dc.l $00000000         ; double '1'
_one2:  .dc.w $0081
        .end
