fpstat  equ     $fffa40         ; Response word of MC68881 read
fpcmd   equ     $fffa4a         ; Command  word of MC68881 write
fpop    equ     $fffa50         ; Operand  long of MC68881 read/write

        .globl _fpset1          ; globale Definitionen aus fset.s
        .globl _fpset2
        .globl _fpget1          ; globale Definitionen aus fget.s
        .globl _fpget2

        .globl sqrt             ; Funktion Wurzel
sqrt:     move.l  (sp)+,a0      ; RÅcksprungadresse
          move.l  (sp)+,d3      ; 1. Teil von real
          move.w  (sp)+,d4      ; 2. Teil von real
          jsr     _fpset2       ; nach FP2 schieben
L1:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L1
          move.w  #$0884,fpcmd  ; Wurzel berechnen
          jsr     _fpget1       ; Ergebnis aus FP1 nach d0-d1 schieben
          jmp     (a0)          ; zurÅck zum Aufrufer

        .end
