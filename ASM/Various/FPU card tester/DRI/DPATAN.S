fpstat  equ     $fffa40         ; Response word of MC68881 read
fpcmd   equ     $fffa4a         ; Command  word of MC68881 write
fpop    equ     $fffa50         ; Operand  long of MC68881 read/write

        .globl _fpset1          ; globale Definitionen aus fset.s
        .globl _fpset2
        .globl _fpget1          ; globale Definitionen aus fget.s
        .globl _fpget2

        .globl _atan            ; Funktion atan(x)
_atan:
          lea.l   $4(sp),a0     ; Adresse von x
          jsr     _fpset2       ; in FP2 schieben
L1:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L1
          move.w  #$088a,fpcmd  ; atan berechnen, Ergebnis in FP1
          jsr     _fpget1       ; Ergebnis aus FP1 in d0-d1 schieben
          rts

        .globl _atan2           ; Funktion atan(x1/x2)
_atan2:
          lea     $4(sp),a0     ; Adresse von x1
          jsr     _fpset1       ; nach FP1 schieben
          lea     $c(sp),a0     ; Adresse von x2
          jsr     _fpset2       ; nach FP2 schieben
L2:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L2
          move.w  #$08a0,fpcmd  ; x1/x2 berechnen
L3:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L3
          move.w  #$050a,fpcmd  ; atan ausfÅhren
          jsr     _fpget2       ; Ergebnis aus FP2 nach d0-d1 schieben
          rts

        .end
