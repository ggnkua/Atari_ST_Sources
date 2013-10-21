EXPORT sqrt_strt


sqrt_strt:
     cmpi.w    #2,d0       ; >2? dan wat doen, anders direct klaar
     bcc.s     .cont
     rts
.cont:
     movem.l   d2-d3,-(sp)
     move.l    d0,d1       ; uitvinden hoeveel bits gezet zijn
     swap      d1          
     tst.w     d1          ; bovenste bits gezet?
     bne.s     .32_bit     ; yep
 ; getal is 16 bits
     moveq     #16,d2      ; voorlopig is bit 15 gezet
     move.w    d0,d1       ; herstel do
     bmi.s     .start_w
.loop:
     subq.w    #1,d2       ; 15
     add.w     d1,d1       ; vind bit
     bge.s     .loop
.start_w:     
     lsr.w     #1,d2
     move.l    d0,d1       ; i
     lsr.w     d2,d1       ; tmp = i>>(bits/2) order 0
     move.l    d0,d3       ; i
     divu      d1,d3       ; i/tmp
     add.w     d3,d1       ; tmp+=i/tmp
     lsr.w     #1,d1       ; tmp/=2            order 1
;     move.l    d0,d3       ; i
;     divu      d1,d3       ; i/tmp
;     add.w     d3,d1       ; tmp+=i/tmp
;     lsr.w     #1,d1       ; tmp/=2            order 2
     move.w    d1,d0       ; copy answer
     movem.l   (sp)+,d2-d3
     rts

 ; getal is 32 bits
.32_bit:     
     moveq     #32,d2      ; voorlopig is bit 15 gezet
     bmi.s     .start_l
.loop2
     subq.w    #1,d2       ; 15
     add.w     d1,d1       ; vind bit
     bge.s     .loop2
.start_l:     
     lsr.w     #1,d2
     move.l    d0,d1       ; i
     lsr.l     d2,d1       ; tmp = i>>(bits/2) order 0
     move.l    d0,d3       ; i
     divu      d1,d3       ; i/tmp
     swap      d3
     clr.w     d3
     swap      d3
     add.l     d3,d1       ; tmp+=i/tmp
     lsr.l     #1,d1       ; tmp/=2            order 1
     move.l    d0,d3       ; i
     divu      d1,d3       ; i/tmp
     swap      d3
     clr.w     d3
     swap      d3
     add.l     d3,d1       ; tmp+=i/tmp
     lsr.l     #1,d1       ; tmp/=2            order 2
     move.l    d0,d3       ; i
     divu      d1,d3       ; i/tmp
     swap      d3
     clr.w     d3
     swap      d3
     add.l     d3,d1       ; tmp+=i/tmp
     lsr.l     #1,d1       ; tmp/=2            order 3
     move.l    d1,d0
     movem.l   (sp)+,d2-d3
     rts
