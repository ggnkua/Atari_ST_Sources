fpstat  equ     $fffa40         ; Response word of MC68881 read
fpcmd   equ     $fffa4a         ; Command  word of MC68881 write
fpop    equ     $fffa50         ; Operand  long of MC68881 read/write

        .globl _fpset1          ; globale Definitionen aus fset.s
        .globl _fpset2
        .globl _fpget1          ; globale Definitionen aus fget.s
        .globl _fpget2

        .globl _acosh           ; acosh = ln(x+sqrt(x^2-1))   x >= 1
_acosh:
          lea.l   $4(sp),a0     ; Adresse von x
          jsr     _fpset1       ; in FP1 schieben
          lea.l   $4(sp),a0     ; und
          jsr     _fpset2       ; in FP2 schieben
L1:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L1
          move.w  #$08a3,fpcmd  ; x^2 berechnen, Ergebnis in FP1
          lea     one,a0        ; Adresse von "1"
          jsr     _fpset2       ; nach FP2 schieben
L2:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L2
          move.w  #$08a8,fpcmd  ; x^2 - 1 berechnen, Ergebnis in FP1
L3:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L3
          move.w  #$0504,fpcmd  ; sqrt(x^2 - 1) berechnen, Ergebnis in FP2
          lea     $4(sp),a0     ; Adresse von x
          jsr     _fpset1       ; nach FP1 schieben
L4:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L4
          move.w  #$08a2,fpcmd  ; x+sqrt(x^2-1) berechnen, Ergebnis in FP1
L5:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L5
          move.w  #$0514,fpcmd  ; ln(x+sqrt(x^2-1)) berechnen
          jsr     _fpget2       ; und Ergebnis auf FP2 in d0-d1 schieben
          rts

        .data
one:    .dc.l $3ff00000,00000000 ; double '1'

        .end
