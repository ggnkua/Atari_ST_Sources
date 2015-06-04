fpstat  equ     $fffa40         ; Response word of MC68881 read
fpcmd   equ     $fffa4a         ; Command  word of MC68881 write
fpop    equ     $fffa50         ; Operand  long of MC68881 read/write

        .globl _fpset1          ; globale Definitionen aus fset.s
        .globl _fpset2
        .globl _fpget1          ; globale Definitionen aus fget.s
        .globl _fpget2

        .globl exp              ; Funktion exp(x)
exp:      move.l  (sp)+,a0      ; R…ksprungadresse
          move.l  (sp)+,d3      ; 1. Teil von real
          move.w  (sp)+,d4      ; 2. Teil von real
          jsr     _fpset2       ; nach FP2 schieben
L1:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L1
          move.w  #$0890,fpcmd  ; exp(x) berechnen
          jsr     _fpget1       ; Ergebnis aus FP1 nach d0-d1 schieben
          jmp     (a0)          ; zur…k zum Aufrufer

        .globl EXP2             ; Funktion 2^x
EXP2:     move.l  (sp)+,a0      ; R…ksprungadresse
          move.l  (sp)+,d3      ; 1. Teil von real
          move.w  (sp)+,d4      ; 2. Teil von real
          jsr     _fpset2       ; nach FP2 schieben
L2:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L2
          move.w  #$0891,fpcmd  ; 2^x berechnen
          jsr     _fpget1       ; Ergebnis aus FP1 nach d0-d1 schieben
          jmp     (a0)          ; zur…k zum Aufrufer

        .globl EXP10            ; Funktion 10^x
EXP10:    move.l  (sp)+,a0      ; R…ksprungadresse
          move.l  (sp)+,d3      ; 1. Teil von real
          move.w  (sp)+,d4      ; 2. Teil von real
          jsr     _fpset2       ; nach FP2 schieben
L3:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L3
          move.w  #$0892,fpcmd  ; 10^x berechnen
          jsr     _fpget1       ; Ergebnis aus FP1 nach d0-d1 schieben
          jmp     (a0)          ; zur…k zum Aufrufer

        .globl ln               ; Funktion log zur Basis e
ln:       move.l  (sp)+,a0      ; R…ksprungadresse
          move.l  (sp)+,d3      ; 1. Teil von real
          move.w  (sp)+,d4      ; 2. Teil von real
          jsr     _fpset2       ; nach FP2 schieben
L4:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L4
          move.w  #$0894,fpcmd  ; log berechnen
          jsr     _fpget1       ; Ergebnis aus FP1 nach d0-d1 schieben
          jmp     (a0)          ; zur…k zum Aufrufer

        .globl LOG2             ; Funktion log zur Basis 2
LOG2:     move.l  (sp)+,a0      ; R…ksprungadresse
          move.l  (sp)+,d3      ; 1. Teil von real
          move.w  (sp)+,d4      ; 2. Teil von real
          jsr     _fpset2       ; nach FP2 schieben
L5:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L5
          move.w  #$0896,fpcmd  ; log2 berechnen
          jsr     _fpget1       ; Ergebnis aus FP1 nach d0-d1 schieben
          jmp     (a0)          ; zur…k zum Aufrufer

        .globl LOG10            ; Funktion log zur Basis 10
LOG10:    move.l  (sp)+,a0      ; R…ksprungadresse
          move.l  (sp)+,d3      ; 1. Teil von real
          move.w  (sp)+,d4      ; 2. Teil von real
          jsr     _fpset2       ; nach FP2 schieben
L6:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L6
          move.w  #$0895,fpcmd  ; log10 berechnen
          jsr     _fpget1       ; Ergebnis aus FP1 nach d0-d1 schieben
          jmp     (a0)          ; zur…k zum Aufrufer

        .end
