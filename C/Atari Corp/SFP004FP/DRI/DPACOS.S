fpstat  equ     $fffa40         ; Response word of MC68881 read
fpcmd   equ     $fffa4a         ; Command  word of MC68881 write
fpop    equ     $fffa50         ; Operand  long of MC68881 read/write

        .globl _fpset2          ; globale Definitionen aus fset.s
        .globl _fpget1          ; globale Definitionen aus fget.s

        .globl _acos            ; acos(x)  -1 <= x <= 1
_acos:
          lea.l   $4(sp),a0     ; Adresse von x
          jsr     _fpset2       ; in FP2 schieben
L1:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L1
          move.w  #$089c,fpcmd  ; Funktion acos ausfhren
          jsr     _fpget1       ; und Ergebnis aus FP1 in d0-d1 schieben
          rts

        .end
