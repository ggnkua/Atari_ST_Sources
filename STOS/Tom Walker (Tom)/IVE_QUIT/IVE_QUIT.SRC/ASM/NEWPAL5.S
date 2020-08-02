;	INTERRUPT HANDLERS!
;	This routine is responsible for the palsplits, colour cycling for scrollers, and border removal
;	Uses the following elements:
;		- a disassembled executable by Neil Stewart off of the
;		  Cunning Demos disk.  This installs a timer B raster routine
;		  in STOS.  It's a SUPER minimal timer B rout and the vbl returns back to
;		  to the STOS vbl routine.  My own vbl routines did not work in STOS so
;		  this rout (from something like 1990) was very important here!
;		- border code by James Ingram - freely available
;	Rest put together by Tom..............


;	d0 = palette buffer address
;	d1 = pointer to STOS control variable for y scroll (takes values between 1-4 - controls size of first pal split)
;	d2 = RETURNS- pointer to palette data to allow fade out of scroll on exit


		tst.l	d0
		beq	stop

start:		move.l	d0,bufadr
		move.l	d1,ofsadr
		move.l	#scrlpal,d2
		
		move.b 	$fffa07,b1
		move.b 	$fffa09,b2
		clr.b	$fffa07
		clr.b	$fffa09

		move.l 	$120,old_b 	;backup vector $120 (timer b)
		move.l 	$70,old_vbl 	;backup vector $70 (vbl)
		move.l 	#timer_b,$120 	;move in my timer b address
		move.l	#vbl,$70	;move in my vbl

		move.b	$fffa13,b3
		clr.b	$fffa1b
		ori.b	#$1,$fffa13
		ori.b	#$1,$fffa07

		rts
		

stop:		move.b	b1,$fffa07
		move.b	b2,$fffa09
		move.l	old_b,$120
		move.l	old_vbl,$70
		move.b	b3,$fffa13

		rts



vbl:		move.w	sr,-(a7)		;turn off interrupts
		or.w	#$0700,sr
		movem.l d0-d7/a0-a6,-(a7) 	;backup registers

		move.w	#1064,d0
.tb:		nop
		dbra	d0,.tb
		eor.b	#2,$ffff820a.w
		REPT	8
		nop
		ENDR
		eor.b	#2,$ffff820a.w

* this bit should do the palette for the scroll
		lea	$ffff8242.w,a0		; cl1 in a0
		lea	scrlpal,a1		; scroll pal in a1
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		movem.l	(a1),d3-d6
		move.w	d0,(a0)+
		movem.l	d0-d6,(a0)

* this bit work outs out where to start the raster 		
		move.l	bufadr,a0
		move.l	a0,pBuf

		move.l	ofsadr,a0
		move.l	(a0),d2
		addq	#3,d2			; added
		move.b	#11,d1
		sub.b	d2,d1
		move.b	d1,lb
		add.b	#29,d2

		clr.b	$fffa1b
		move.b 	d2,$fffa21 		;initial count
		move.b 	#8,$fffa1b 		;set timer b to event count mode
		move.l	#timer_b,$120

		movem.l (a7)+,d0-d7/a0-a6 	;restore registers
		move.w	(a7)+,sr
		move.l	old_vbl,-(a7)
		rts 				;finished


timer_b:	movem.l	a0-a1,-(a7)
		move.l	pBuf,a0
		lea	$ffff8242.w,a1

		REPT	7
		move.l	(a0)+,(a1)+
		ENDR
		move.w	(a0)+,(a1)

		move.l	a0,pBuf
		move.b	#1,count
	
		clr.b	$fffa1b
		move.b	#4,$FFFa21
		move.b	#8,$fffa1b
		move.l	#timer_b1,$120

		bclr 	#0,$fffa0f 		;tell ST interrupt is done
		movem.l	(a7)+,a0-a1
		rte 				;exit interrupt


timer_b1:	movem.l	a0-a1,-(a7)
		move.l	pBuf,a0
		lea	$ffff8242.w,a1

		REPT	7
		move.l	(a0)+,(a1)+
		ENDR
		move.w	(a0)+,(a1)

		move.l	a0,pBuf
		add.b	#1,count
	
		cmp.b	#48,count
		bne	.b1end

		clr.b	$fffa1b
		move.b	lb,$FFFa21
		move.b	#8,$fffa1b
		move.l	#lborder,$120

.b1end:		bclr 	#0,$fffa0f 		;tell ST interrupt is done
		movem.l	(a7)+,a0-a1
		rte 				;exit interrupt



lborder:	movem.l	d0/a0,-(a7)
		move.w	#$fa21,a0
		move.b	(a0),d0
.wait:
		cmp.b	(a0),d0
		beq.s	.wait

		eor.b	#2,$ffff820a.w		;60hz

		REPT	15
		nop
		ENDR

		eor.b	#2,$ffff820a.w		;50hz

		move.w	#$777,$ffff8242.w

		clr.b	$fffa1b
		move.b	#1,$FFFa21
		move.b	#8,$fffa1b
		move.l	#tb_spal,$120

		bclr 	#0,$fffa0f 		; tell ST interrupt is done
		movem.l	(a7)+,d0/a0
		rte 		


tb_spal:	movem.l	d0-d6/a0-a2,-(a7)

		lea	$ffff8242.w,a0		; cl1 in a0
		lea	scrlpal,a1		; scroll pal in a1
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		movem.l	(a1),d3-d6
		move.w	d0,(a0)+
		movem.l	d0-d6,(a0)

* now scroll the cols
		lea	2(a1),a0
		lea	scrlpalend,a2
		move.w	(a1),(a2)
		REPT	8
		move.w	(a0)+,(a1)+
		ENDR

		clr.b	$fffa1b
		move.b	#50,$FFFa21
		move.b	#8,$fffa1b

		bclr 	#0,$fffa0f 		tell ST interrupt is done
		movem.l	(a7)+,d0-d6/a0-a2
	
		rte


		section	data

b1		dc.b	0
b2		dc.b	0
b3		dc.b	0
count		dc.b	0
lb		dc.b	0
		even
bufadr		dc.l	0
pBuf		dc.l	0
ofsadr		dc.l	0


old_b		dc.l	0
old_vbl		dc.l	0

scrlpal		dc.w	$555,$556,$456,$457,$447,$347,$337,$237
scrlpalend	dc.w	0