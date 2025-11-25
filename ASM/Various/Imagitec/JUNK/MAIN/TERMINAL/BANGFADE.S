****************************
* Les's bankok nigits fade *
****************************
bang_fade_in
               move           #1,-(sp)
               moveq          #1,d4
               moveq          #0,d5
               bsr            setwhich
               moveq          #0,d4
               moveq          #1,d5 
               movem          d4-d5,-(sp)
               bra.s          fade_inout
bang_fade_out
               move           #0,-(sp)
               moveq          #0,d4
               moveq          #1,d5
               bsr            setwhich
               moveq          #1,d4
               moveq          #0,d5
               movem          d4-d5,-(sp)
               bra            fade_inout
*********************
* The actual doodah *
*********************
fade_inout
               lea            rastertab(pc),a6
               move           #32-1,d7
.clr_loop1
               clr.l          (a6)+
               dbf            d7,.clr_loop1

               moveq          #$20,d1
               moveq          #$1,d2
               move           #$80,d3
.fadein2
               movem          d1-d2,-(sp)
.fadein3
               bsr.s          fade_print
               sub.b          d2,d3
               subq.b         #1,d1
               bne.s          .fadein3
               movem          (sp)+,d1-d2
               lsr.b          d1
               lsl.b          d2
               cmp.b          #$10,d2         $10
               bne.s          .fadein2
               movem          (sp)+,d4-d5
               bsr.s          setwhich
.2b
               movem          d1-d2,-(sp)
.2
               bsr.s          fade_print
               add.b          d2,d3
               subq.b         #1,d1
               bne.s          .2
               movem          (sp)+,d1-d2
               lsl.b          d1
               lsr.b          d2
               tst.b          d2
               bne.s          .2b
               move           (sp)+,d0
               lea            rastertab(pc),a6
               move           #128-1,d7
.clr_loop2
               move.b         d0,(a6)+
               dbf            d7,.clr_loop2
               bra            fade_print
***********************
* Do the actual print *
***********************
fade_print
               movem          d1-d7,-(sp)
               bsr.s          settab
               bsr.s          display
               bsr            term_wait_vbl
               movem          (sp)+,d1-d7
               rts
**********************
* Set shich is which *
**********************
setwhich
               move           d5,mc2
               move           d4,mc3
               rts
***********************************************
* Set a table (the working part so lez sez!!) *
***********************************************
settab
               move           d3,mc1
               lea            rastertab(pc),a0
               moveq          #0,d2
.sloop
               move           mc1,d0
               lsr.b          d0
               addq.b         #1,d0
               move           d0,d1
.sloop2
               move           mc2,d0
               move.b         d0,(a0)+
               addq.b         #1,d2
               cmp.b          #136,d2
               beq.s          .exit
               subq.b         #1,d1
               bne.s          .sloop2
               moveq          #3,d1
.sloop3
               move           mc3,d0
               move.b         d0,(a0)+
               addq.b         #1,d2
               cmp.b          #136,d2
               beq.s          .exit
               subq.b         #1,d1
               bne.s          .sloop3
               bra.s          .sloop
.exit
               rts
**********************
* Display the screen *
**********************
display
               movem.l        d0-d7/a0-a6,-(sp)
               move.l         smaskp1(pc),a0
	       lea	      30*80(a0),a0
               move.l         tv_addr1,a1
               lea	      38*320+224(a1),a1
               lea            rastertab+64(pc),a2
               lea            bang_clear(pc),a6
               move           #30-1,d0
.loop
               tst.b          -(a2)
               beq.s          .erase
.draw
               movem.l        (a0),d1-d7/a3-a5
               movem.l        d1-d7/a3-a5,(a1)
               movem.l        40(a0),d1-d7/a3-a5
               movem.l        d1-d7/a3-a5,40(a1)
               lea            320(a1),a1
               lea            80(a0),a0
               dbf            d0,.loop
               bra.s          .other
.erase
               movem.l        (a6),d1-d7/a3-a5
               movem.l        d1-d7/a3-a5,(a1)
               movem.l        (a6),d1-d7/a3-a5
               movem.l        d1-d7/a3-a5,40(a1)
               lea            320(a1),a1
               lea            80(a0),a0
               dbf            d0,.loop
.other
               move.l         smaskp1,a0
               move.l         tv_addr1,a1
               lea            8*320+224(a1),a1
               lea            rastertab+34(pc),a2
               lea            bang_clear(pc),a6
               move           #30-1,d0
.loop1
               tst.b          (a2)+
               beq.s          .erase1
.draw1
               movem.l        (a0),d1-d7/a3-a5
               movem.l        d1-d7/a3-a5,(a1)
               movem.l        40(a0),d1-d7/a3-a5
               movem.l        d1-d7/a3-a5,40(a1)
               lea            320(a1),a1
               lea            80(a0),a0
               dbf            d0,.loop1
               movem.l        (sp)+,d0-d7/a0-a6
               rts
.erase1
               movem.l        (a6),d1-d7/a3-a5
               movem.l        d1-d7/a3-a5,(a1)
               movem.l        (a6),d1-d7/a3-a5
               movem.l        d1-d7/a3-a5,40(a1)
               lea            320(a1),a1
               lea            80(a0),a0
               dbf            d0,.loop1
               movem.l        (sp)+,d0-d7/a0-a6
               rts

bang_clear     dc.l           0,0,0,0,0,0,0,0,0,0,0,0,0,0
mc1            ds             1
mc2            ds             1
mc3            ds             1
rastertab      ds             200
