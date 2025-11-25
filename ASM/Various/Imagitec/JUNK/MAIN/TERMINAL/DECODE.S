
; d0 = anim number

anim_play
hum_animplay:	move.b	#anim_speed,hum_andelay
		move.l	$70.w,-(sp)
		move.l	#vbl_anim,$70.w
		move.l	a0,hum_loadarea
		bsr	hum_ansetup		;setup screens
		move.l	hum_anphy,a1		;read screen base
		
		move.l	hum_loadarea,a1
hum_anplay4:	
		move.l	a1,a2			;copy address
		move.w	(a1)+,hum_anframes	;set number of frames
		lea.l	256*4(a1),a1		;past palette

		move.w	#1,hum_anframe		;start frame 2
		bsr	hum_andecode		;decode first frame
		;fade
		movem.l	d0-a6,-(sp)
		move.l	hum_loadarea,a0
		addq.l	#2,a0
		move.l	a0,hum_paladdr
		jsr	fade_up_anim
		movem.l	(sp)+,d0-a6

		move.l	#$00070007,hum_antriggr	;set trigger refresh
		move.w	hum_anframes,d0		;read number of frames
		subq.w	#2,d0			;minus 2 for count
		sf	hum_ancopy		;copy
		addq.w	#1,hum_anframe		;increment frame
hum_anplay7:	tst.b	hum_antrigger		;trigger?
		beq.s	hum_anplay7		;no -- wait
		clr.b	hum_antrigger		;reset
		
		bsr	hum_andecode		;decode the next frame
		addq.w	#1,hum_anframe		;increment frame
		dbra	d0,hum_anplay7		;play all the frames
		tst.b	hum_anloop		;loop this animation?
		beq.s	hum_anplay10		;no -- exit
hum_anplay8:	tst.b	hum_answap		;screen swapped?
		bne.s	hum_anplay8		;no -- wait
		move.w	#1,hum_anframe		;reset frame
		jsr	hum_waitvbl		;wait for frame to catch
		move.l	hum_ancomp,a0		;read compress base address
		move.w	#1599,d0		;loop
hum_anplay9:	clr.l	(a0)+			;clear 4
		clr.l	(a0)+			;clear 4
		clr.l	(a0)+			;clear 4
		clr.l	(a0)+			;clear 4
		clr.l	(a0)+			;clear 4
		clr.l	(a0)+			;clear 4
		clr.l	(a0)+			;clear 4
		clr.l	(a0)+			;clear 4
		clr.l	(a0)+			;clear 4
		clr.l	(a0)+			;clear 4
		dbra	d0,hum_anplay9		;clear base to zero
		move.l	a2,a1			;copy start address again
		move.w	(a1)+,d0		;get frames
		subq.w	#1,d0			;decrement for loop
		lea.l	256*4(a1),a1		;past palette to offsets
		st	hum_ancopy		;set copy flag
		bra	hum_anplay7		;repeat animation
hum_anplay10:	moveq.l	#19,d0			;wait 20 frames....
hum_anplay11:	tst.b	hum_antrigger		;trigger?
		beq.s	hum_anplay11		;no -- wait
		clr.b	hum_antrigger		;reset
		dbra	d0,hum_anplay11		;wait...
hum_anplay12:	
hum_anplay15:	
		; fade
		jsr	fade_down_anim
		move.l	(sp)+,$70.w
		rts

hum_ansetup:	
		move.l	#hum_anbuffers,d1	;address
		addq.l	#8,d1			;plus 8
		and.l	#$fffffff8,d1		;make long-word
		move.l	d1,a0			;copy it
		move.l	a0,hum_anlog		;set
		move.l	a0,hum_anphy		;set physical base
		add.l	#64000,hum_anphy	;frame 2
		move.l	hum_anlog,a1
		move.l	hum_anphy,a2
		move	#64000/4,d7
.lo
		clr.l	(a1)+
		clr.l	(a2)+
		dbf	d7,.lo

		move.w	#31999,d1		;loop
hum_ansetup2:	clr.l	(a0)+			;clear 4
		dbra	d1,hum_ansetup2		;clear whole area!
		rts

hum_andecode:	movem.l	d0-d7/a0-a6,-(sp)	;save all registers
		move.l	hum_anphy,a0
		move.l	hum_ancomp,a2
		move.w	#(64000/40)-1,d1
hum_ancopyback:	
		rept	10
		move.l	(a0)+,(a2)+
		endr
		dbra	d1,hum_ancopyback
		movem.l	(sp),d0-d7/a0-a6
		move.l	hum_ancomp,a0		;compressed data address
		move.l	(a1)+,d1		;read offset of frame
		add.l	d1,a2			;find start of data
		lea.l	25(a2),a3		;to first line data
		move.w	#199,d0			;200 lines to do
		moveq.l	#7,d1			;start bit 7
hum_andecode2:	btst.b	d1,(a2)			;do this line?
		beq.s	hum_andecode6		;yes
		moveq.l	#0,d2			;reset
		move.b	(a3)+,d2		;read offset
		lea.l	(a0,d2.w),a4		;find address
		move.b	(a3)+,d2		;read number of bytes to do
		move.l	d2,d3			;copy
		lsr.w	#3,d3			;divide by 8
		addq.w	#1,d3			;increment
		lea.l	(a3,d3.w),a5		;find address of data
		moveq.l	#7,d3			;start bit 7
		move.b	(a3)+,d4		;read data
hum_andecode3:	btst.l	d3,d4			;set?
		beq.s	hum_andecode4		;no
		move.b	(a5)+,(a4)		;copy byte
hum_andecode4:	addq.l	#1,a4			;increment
		dbra	d3,hum_andecode5	;do all bits
		moveq.l	#7,d3			;reset
		move.b	(a3)+,d4		;read data
hum_andecode5:	dbra	d2,hum_andecode3	;decode line
		move.l	a5,a3			;set data
hum_andecode6:	lea.l	320(a0),a0		;next line
		dbra	d1,hum_andecode7	;next bit
		moveq.l	#7,d1			;reset bit
		addq.l	#1,a2			;increment address
hum_andecode7:	dbra	d0,hum_andecode2	;decode whole frame
hum_andecode9:	movem.l	(sp)+,d0-d7/a0-a6	;restore all registers
		addq.l	#4,a1			;next offset
		st	hum_answap		;set to swap
		jsr	hum_waitvbl		;wait for swap!
		rts

vbl_anim	movem.l	d0-a6,-(sp)
		bsr.s	hum_anvbl
		subq.b	#1,hum_andelay
		bne.s	.no_set
		move.b	#anim_speed,hum_andelay
		st	hum_antrigger
.no_set		jsr	nt_vbl
		movem.l	(sp)+,d0-a6
		rte
hum_anvbl:	move.b	hum_anphy+1,$ff8201
		move.b	hum_anphy+2,$ff8203
		move.b	hum_anphy+3,$ff820d
		lea	hum_animpal,a0
		lea	atari_pal,a1
		move.w	#256-1,d0
.lp		move.l	(a0)+,(a1)+
		dbf	d0,.lp
		addq.l	#1,hum_vclock		;inc clock
		tst.b	hum_answap		;swap frames?
		beq.s	hum_anvbl2_3		;no -- leave
		lea.l	hum_anlog,a0		;address of logical
		move.l	(a0)+,d0		;read logical
		move.l	(a0),-4(a0)		;physical >> logical
		move.l	d0,(a0)			;logical >> physical	
		sf	hum_answap		;reset flag
hum_anvbl2_3:	lea.l	hum_antriggr,a0		;trigger rate
		subq.w	#1,(a0)+		;decrement
		bne.s	hum_anvbl2_4		;not counted out yet
		move.w	(a0),-(a0)		;refresh rate
		st	-(a0)			;set flag
hum_anvbl2_4:	rts

hum_waitvbl:	move.l	d0,-(sp)		;save
		move.l	hum_vclock,d0		;read clock
hum_waitvbl2:	cmp.l	hum_vclock,d0		;got it?
*andy		beq.s	hum_waitvbl2		;no!!!!
		move.l	(sp)+,d0		;restore
		rts

fade_down_anim
	moveq	#0,d7
	move.w	#128-1,d0		no times
	move.w	#255,d1			init value
	moveq	#-2,d2			increase
	bra.s	daz_fades
fade_up_anim
	moveq	#0,d7			fade speed
	move.w	#128-1,d0		no times
	moveq	#0,d1			init value
	moveq	#2,d2			increase
daz_fades
.lp	move.w	#256-1,d3		do all colours
	move.l	hum_paladdr,a0
	lea	hum_animpal,a1
.lp1	moveq	#0,d4
	move.b	(a0)+,d4
	mulu	d1,d4
	lsr.w	#8,d4
	move.b	d4,(a1)+		red
	move.b	(a0)+,d4
	mulu	d1,d4
	lsr.w	#8,d4
	move.b	d4,(a1)+		green
	clr.b	(a1)+
	addq.l	#1,a0			skip byte
	move.b	(a0)+,d4
	mulu	d1,d4
	lsr.w	#8,d4
	move.b	d4,(a1)+		blue
	dbf	d3,.lp1
	add.w	d2,d1
	move.w	d7,d4
.lp2	bsr	hum_waitvbl
	dbf	d4,.lp2
	dbf	d0,.lp
	rts
