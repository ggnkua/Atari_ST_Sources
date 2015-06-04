fpstat  equ     $fffa40         ; Response word of MC68881 read
fpcmd   equ     $fffa4a         ; Command  word of MC68881 write
fpop    equ     $fffa50         ; Operand  long of MC68881 read/write

        .globl _fpset1
_fpset1:
L1:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L1
          move.w  #$5480,fpcmd  ; FMOVE fÅr FP1 starten
          move.w  fpstat,d0     ; Status lesen und vergessen
          move.l  (a0)+,fpop    ; Daten in FP1 schreiben
          move.l  (a0)+,fpop
          rts 

        .globl _fpset2
_fpset2:
L2:       cmp.w   #$0802,fpstat ; auf MC68881 bereitschaft warten
          bne.s   L2
          move.w  #$5500,fpcmd  ; FMOVE fÅr FP2 starten
          move.w  fpstat,d0     ; Status lesen und vergessen
          move.l  (a0)+,fpop    ; Daten in FP2 schreiben
          move.l  (a0)+,fpop 
          rts 

        .end
