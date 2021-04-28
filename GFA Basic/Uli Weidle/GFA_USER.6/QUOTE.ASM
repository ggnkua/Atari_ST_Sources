; File: quote.asm
;
;=================================================
;
; quote
; =====
;
; Input: following 68000-C convention:
;          L  string address
;          W  ASCII: nesting on
;          W  ASCII: nesting off
;          W  Position of character analysed in the string
;
; Output: D0.l : nesting depth of character
;
; Changed registers: 01234567
;                   D:-------
;                   A--------
;
             .CARGS #4*4+4,adr.l,qon.w,qoff.w,pos.w
quote:       movem.l   d1-d3/a0,-(sp)       ;read in parameters: The use
             movea.l   adr(sp),a0           ;of symbolic constants defined
             move.w    qon(sp),d1           ;with CARGS reduces
             move.w    qoff(sp),d2          ;the probability of an error
             move.w    pos(sp),d3           ;when parameter passing is changed.

             move.w    #0,d0                ;No quotation marks at first
             bra       .loop                ;begin testing now
.nxtch:      cmp.b     (a0),d1              ;compare character with qon
             bne       .noqon               ;No, then continue
             addi.w    #1,d0                ;else a level deeper
.noqon:      cmp.b     (a0)+,d2             ;compare character with qoff
;and increment pointer
             bne       .loop                ;no, then continue
             subi.w    #1,d0                ;otherwise a level deeper
.loop:       dbf       d3,.nxtch            ;until position is reached
             ext.l     d0                   ;nesting depth into long
             movem.l   (sp)+,d1-d3/a0       ;and back as usual.
             rts       
             .END 

