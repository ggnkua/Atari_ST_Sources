; File: lr_show.asm
;============================================================================
;
; lr_show
; =======
;
; Input: following 68000-C convention:
;       L  Address of 64000 bytes intermediate format file
;       L  Address of 32000 bytes low resolution graphic
; Output: --


; Changed registers:   01234567
;                     D:-------
;                     A--------
;
;

             .CARGS #8*4+4,sadr.l,tadr.l
             .TEXT

lr_show:     movem.l    d1-d6/a0/a1,-(sp)
             movea.l    sadr(sp),a0
             movea.l    tadr(sp),a1

             move.w     #3999,d0           ;4000 units at 4 words each
.makepict:   move.w     #15,d1             ;each word with 16 bits
.makeword:   move.b     (a0)+,d2           ;read colour value
             lsr.b      #1,d2              ;distribute bits over words in planes
             roxl.w     #1,d3              ;until words are filled
             lsr.b      #1,d2
             roxl.w     #1,d4
             lsr.b      #1,d2
             roxl.w     #1,d5
             lsr.b      #1,d2
             roxl.w     #1,d6
             dbf        d1,.makeword
             move.w     d3,(a1)+           ;place words into picture
             move.w     d4,(a1)+
             move.w     d5,(a1)+
             move.w     d6,(a1)+
             dbf        d0,.makepict       ;continue with next words if required

             movem.l    (sp)+,d1-d6/a0/a1
             rts


             .END
