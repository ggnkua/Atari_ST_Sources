fpstat  equ     $fffa40         ; Response word of MC68881 read
fpcmd   equ     $fffa4a         ; Command  word of MC68881 write
fpop    equ     $fffa50         ; Operand  long of MC68881 read/write

        .globl _fpset1          ; globale Definitionen aus fset.s
        .globl _fpset2
        .globl _fpget1          ; globale Definitionen aus fget.s

        .globl _dpadd           ; y = x1 + x2
_dpadd:
          lea.l   $4(sp),a0     ; Adresse von x1
          jsr     _fpset1       ; in FP1 schieben
          lea.l   $c(sp),a0     ; Adresse von x2
          jsr     _fpset2       ; in FP2 schieben
L1:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L1
          move.w  #$08a2,fpcmd  ; add
          jsr     _fpget1       ; und Ergebnis aus FP1 in d0-d1 schieben
          rts

        .globl _ADDL_           ; interne Funktion von DRI
_ADDL_:   movem.l  d0-d3,-(sp)  ; x1 & x2 stehen in d0-d3 -> auf Stack
          bsr.s    _dpadd       ; dann add durchfhren
          add.l    #$10,sp
          rts

        .end
