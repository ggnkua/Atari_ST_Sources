fpstat  equ     $fffa40         ; Response word of MC68881 read
fpcmd   equ     $fffa4a         ; Command  word of MC68881 write
fpop    equ     $fffa50         ; Operand  long of MC68881 read/write

        .globl _fpset1          ; globale Definitionen aus fset.s
        .globl _fpset2
        .globl _fpget1          ; globale Definitionen aus fget.s
        .globl _fpget2

        .globl _dpmult          ; Funktion *
_dpmult:
          lea.l   $4(sp),a0     ; Adresse von x1
          jsr     _fpset1       ; nach FP1 schieben
          lea.l   $c(sp),a0     ; Adresse von x2
          jsr     _fpset2       ; nach FP2 schieben
L1:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L1
          move.w  #$08a3,fpcmd  ; * berechnen
          jsr     _fpget1       ; Ergebnis aus FP1 nach d0-d1 schieben
          rts

        .globl _MULL_
_MULL_:   movem.l  d0-d3,-(sp)
          bsr.s    _dpmult
          add.l    #$10,sp
          rts

        .end
