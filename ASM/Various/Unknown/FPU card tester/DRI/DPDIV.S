fpstat  equ     $fffa40         ; Response word of MC68881 read
fpcmd   equ     $fffa4a         ; Command  word of MC68881 write
fpop    equ     $fffa50         ; Operand  long of MC68881 read/write

        .globl _fpset1          ; globale Definitionen aus fset.s
        .globl _fpset2
        .globl _fpget1          ; globale Definitionen aus fget.s
        .globl _fpget2

        .globl _dpdiv           ; Funktion x1/x2
_dpdiv:
          lea.l   $4(sp),a0     ; Adresse von x1 
          jsr     _fpset1       ; nach FP1 schieben
          lea.l   $c(sp),a0     ; Adresse von x2
          jsr     _fpset2       ; nach FP2 schieben
L1:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L1
          move.w  #$08a0,fpcmd  ; Division berechnen
          jsr     _fpget1       ; Ergebnis aus FP1 nach d0-d1 schieben
          rts

        .globl _DIVL_
_DIVL_:   movem.l  d0-d3,-(sp)
          bsr.s    _dpdiv
          add.l    #$10,sp
          rts

        .end
