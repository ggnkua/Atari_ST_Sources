fpstat  equ     $fffa40         ; Response word of MC68881 read
fpcmd   equ     $fffa4a         ; Command  word of MC68881 write
fpop    equ     $fffa50         ; Operand  long of MC68881 read/write

        .globl _fpget1
_fpget1:
L1:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L1
          move.w  #$7480,fpcmd  ; FMOVE starten fÅr FP1
          move.w  fpstat,d0     ; Status lesen und vergessen
L2:       cmp.w   #$b208,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L2
          move.l  fpop,d0       ; Daten auslesen
          move.l  fpop,d1
          rts

        .globl _fpget2
_fpget2:
L3:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L3
          move.w  #$7500,fpcmd  ; FMOVE starten fÅr FP2
          move.w  fpstat,d0     ; Status lesen und vergessen
L4:       cmp.w   #$b208,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L4
          move.l  fpop,d0       ; Daten auslesen
          move.l  fpop,d1
          rts

        .end
