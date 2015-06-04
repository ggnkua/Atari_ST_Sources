fpstat  equ     $fffa40         ; Response word of MC68881 read
fpcmd   equ     $fffa4a         ; Command  word of MC68881 write
fpop    equ     $fffa50         ; Operand  long of MC68881 read/write

        .globl _fpset1          ; globale Definitionen aus fset.s
        .globl _fpset2
        .globl _fpget1          ; globale Definitionen aus fget.s
        .globl _fpget2

        .globl POW              ; Funktion x^y
                                ; z = exp(y*lnx)
POW:      move.l  (sp)+,a0      ; RÅcksprungadresse
          move.l  (sp)+,d5      ; 1. Teil von real y
          move.w  (sp)+,d6      ; 2. Teil von real
          move.l  (sp)+,d3      ; 1. Teil von real x
          move.w  (sp)+,d4      ; 2. Teil von real
          jsr     _fpset2       ; nach FP2 schieben
L1:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L1
          move.w  #$0894,fpcmd  ; lnx berechnen
          move.l  d5,d3         ; y
          move.w  d6,d4
          jsr     _fpset2       ; nach FP2 schieben
L2:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L2
          move.w  #$08a3,fpcmd  ; * berechnen
L3:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L3
          move.w  #$0510,fpcmd  ; exp berechnen
          jsr     _fpget2       ; Ergebnis aus FP2 nach d0-d1 schieben
          jmp     (a0)          ; zurÅck zum Aufrufer

        .end
