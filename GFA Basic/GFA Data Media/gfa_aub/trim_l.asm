; File: trim_l.asm
;
;=======================================================
;
; triml
; =====
;
; Input: following the 68000-C convention:
;        L String address
;        W Length of string in bytes (characters)
;          (0 <= . <=32767)
;
; Output: d0.l  :  Length of string without blanks (byte: 32)
;                  on the left
;
; Changed registers: 01234567
;                   D:-------
;                   A--------
;
triml:       move.l    a0,-(sp)
             movea.l   8(sp),a0             ;fetch string address
             move.w    12(sp),d0            ;fetch string length
             cmp.w     d0,d0                ;set loop condition to false
             bra       .lp                  ;and using WHILE-begin
.nxtch:      cmpi.b    #" ",(a0)+           ;test character by character
.lp:         dbne      d0,.nxtch            ;as long as="  ",dec d0
;and repeat
             addq.w    #1,d0                ;correct counter
             ext.l     d0                   ;expand result to long
             movea.l   (sp)+,a0
             rts       

             .END 

