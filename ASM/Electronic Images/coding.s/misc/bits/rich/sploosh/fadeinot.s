; Fade in and out routs...
; Written to be very easy to install into a demo.
; (C) 1991 Martin Griffiths

start		clr -(sp)
		pea -1.w
		pea -1.w
		move #5,-(sp)
		trap #14
		lea 12(sp),sp
		clr.l -(sp)
		move #$20,-(sp)
		trap #1
		addq.l #6,sp
		move #$8240,a0
		moveq #7,d0
.clp		clr.l (a0)+
		dbf d0,.clp
		move #2,-(sp)
		trap #14
		addq.l #2,sp
		lea pic+34(pc),a0
		move.l d0,a1
		move #3999,d0
.lp		move.l (a0)+,(a1)+
		move.l (a0)+,(a1)+
		dbf d0,.lp
		lea old_vbl(pc),a0
		move.l $70.w,(a0)
		lea my_vbl(pc),a0
		move.l a0,$70.w
		St fadeinflag			; remember true=-1 false=0!!!
.wait1	tst.b fadeinflag
		bne.s .wait1
		move #7,-(sp)
		trap #1
		addq.l #2,sp
		St fadeoutflag
.wait2	tst.b fadeoutflag
		bne.s .wait2
		move.l old_vbl(pc),$70.w
		move.l #$00000777,$ffff8240.w
		move.l #$07770777,$ffff8244.w
		clr -(sp)
		trap #1
old_vbl:	dc.l 0

; Vbl. Fading in or out takes about 7 scan lines of cpu time

my_vbl:	movem.l d0-d7/a0-a6,-(sp)
		tst.b fadeinflag
		beq.s nofadein
		bsr fadein
nofadein	tst.b fadeoutflag
		beq.s nofadeout
		bsr fadeout
nofadeout	movem.l (sp)+,d0-d7/a0-a6
		rte

; Fade in - to start simply "ST fadeinflag"
	
fadein:	move.l fadein_pal_ptr(pc),a0
		lea $ffff8240.w,a1
		move.w fadein_tim(pc),d0
		moveq #15,d7
.lp		bsr calc1
		move.w d3,(a1)+
		dbf d7,.lp
		addq #1,d0
		cmp #$11,d0
		bne.s .notendfade
		clr d0
		sf fadeinflag
.notendfade	move.w d0,fadein_tim
		rts

; Fade in - to start simply "ST fadeoutflag"

fadeout:	move.l fadeout_pal_ptr(pc),a0
		lea $ffff8240.w,a1
		moveq #$10,d0
		sub.w fadeout_tim(pc),d0
		moveq #15,d7
.lp		bsr calc1
		move.w d3,(a1)+
		dbf d7,.lp
		move.w fadeout_tim(pc),d0
		addq #1,d0
		cmp #$11,d0
		bne.s .notendfade
		clr d0
		sf fadeoutflag
.notendfade	move.w d0,fadeout_tim
		rts

calc1		move.w (a0)+,d1
		move.w d1,d2
		and #$007,d1
		mulu d0,d1
		lsr #4,d1
		move.w d1,d3
		move.w d2,d1
		and #$070,d1
		mulu d0,d1
		lsr #4,d1
		and #$070,d1
		or.w d1,d3
		and #$700,d2
		mulu d0,d2
		lsr #4,d2
		and #$700,d2
		or.w d2,d3
		rts

fadeinflag:	dc.b 0	
fadeoutflag:dc.b 0	
fadein_pal_ptr:
		dc.l pic+2
fadeout_pal_ptr:
		dc.l pic+2
fadein_tim	dc.w 0
fadeout_tim	dc.w 0

pic	incbin d:\oxygene.pi1
