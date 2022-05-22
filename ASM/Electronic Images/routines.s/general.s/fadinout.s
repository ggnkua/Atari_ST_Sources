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
.wait1		tst.b fadeinflag
		bne.s .wait1
		move #7,-(sp)
		trap #1
		addq.l #2,sp
		St fadeoutflag
.wait2		tst.b fadeoutflag
		bne.s .wait2
		move #7,-(sp)
		trap #1
		addq.l #2,sp

		move.l old_vbl(pc),$70.w
		move.l #$00000777,$ffff8240.w
		move.l #$07770777,$ffff8244.w
		clr -(sp)
		trap #1
old_vbl:	dc.l 0

; Fading in or out takes about 3 scan lines of cpu time

my_vbl:		movem.l d0-d7/a0-a6,-(sp)
		movem.l currpal(pc),d0-d7
		movem.l d0-d7,$ffff8240.w
		bsr Fade_in
		bsr Fade_out
		movem.l (sp)+,d0-d7/a0-a6
		rte
; Fade routines

fadespeed	equ 2

; Colour Fade-In the screen.

Fade_in		lea fadein_vars(pc),a5
		tst.b 7(a5)		; fading in?
		beq.s .nofadein	
		subq.b #1,6(a5)		; vbl count-1
		bge.s .nofadein
		move.b #fadespeed,6(a5)	; reset vbl count
		subq #1,4(a5)		; faded in totally?
		bne.s .okstillfade
		sf.b 7(a5)		; yes signal fade done.
		move.w #8,4(a5)		; and reset for next fade. 
.okstillfade	lea.l currpal(pc),a0	; ptr to curr pal 
		move.l (a5),a1		; ptr to dest pal
		move  #$700,d4		; R mask
		moveq #$070,d5		; G mask
		moveq #$007,d6		; B mask
		move.w #$100,a2
		move.w #$010,a3
		moveq #15,d7
.col_lp		move.w (A0),d0		; curr value
		move.w (A1)+,d1		; dest value
		move.w d0,d2
		move.w d1,d3
		and.w d4,d2
		and.w d4,d3
		cmp d2,d3		
		ble.s .R_done
		add.w a2,d0
.R_done		move.w d0,d2
		move.w d1,d3
		and d5,d2
		and d5,d3
		cmp d2,d3
		ble.s .G_done
		add a3,d0
.G_done 	move.w d0,d2
		move.w d1,d3
		and.w d6,d2
		and.w d6,d3
		cmp.w d2,d3
		ble.s .B_done
		addq #$001,d0
.B_done		move.w d0,(a0)+
		dbf d7,.col_lp
.nofadein	rts

fadein_vars
fadein_palptr:	dc.l pic+2
fadein_cnt	dc.w 8
fadein_tim	dc.b 0
fadeinflag:	dc.b 0	

; Colour Fade-Out the screen.

Fade_out	lea fadeout_vars(pc),a5
		tst.b 7(a5)		; fading out?
		beq.s .nofadeout	
		subq.b #1,6(a5)		; vbl count-1
		bge.s .nofadeout
		move.b #fadespeed,6(a5)	; reset vbl count
		subq #1,4(a5)		; faded out totally?
		bne.s .okstillfade
		sf.b 7(a5)		; yes signal fade done.
		move.w #8,4(a5)		; and reset for next fade. 
.okstillfade	move.l (a5),a0		; ptr to pal to fade down.
		move  #$700,d4		; R mask
		moveq #$070,d5		; G mask
		moveq #$007,d6		; B mask
		move.w #$100,a2
		move.w #$010,a3
		moveq #15,d7
.col_lp		move.w (a0),d0		; curr value
		move.w d0,d2
		and.w d4,d2
		beq.s .R_done
		sub.w a2,d0
.R_done		move.w d0,d2
		and.w d5,d2
		beq.s .G_done
		sub.w a3,d0
.G_done 	move.w d0,d2
		and.w d6,d2
		beq.s .B_done
		subq.w #$001,d0
.B_done		move.w D0,(a0)+
		dbf d7,.col_lp
.nofadeout	rts

fadeout_vars
fadeout_palptr:	dc.l currpal
fadeout_cnt	dc.w 8
fadeout_tim	dc.b 0
fadeoutflag:	dc.b 0	

currpal		ds.w 16

pic		incbin \oxygene.pi1
