

		section	text

spec29k_init:	rts

spec29k_runtime_init:
		subq.w	#1,.once
		bne.s	.done

		jsr	syncfix				;fix eventual bitplane corruption
		jsr	black_pal
		jsr	clear_screens

		ifne	init_finish
		move.w	#$0700,$ffff8240.w
		endc

		;clear areas
		jsr	clear_256k
		jsr	clear_128k

		;depack pics
		lea.l	spec29k_pic1_lz77,a0
		lea.l	spec29k_pic1,a1
		jsr	lz77
		
		lea.l	spec29k_pic2_lz77,a0
		lea.l	spec29k_pic2,a1
		jsr	lz77

		;clear all bg colours
		move.l	specscreen,a0
		move.l	specscreen2,a1
		move.w	#274-1,d7
.clrbg:		clr.w	(a0)
		clr.w	(a1)
		lea.l	96(a0),a0
		lea.l	96(a1),a1
		dbra	d7,.clrbg
		
		ifne	init_finish
		move.w	#$0070,$ffff8240.w
		endc

			
.done:		rts
.once:		dc.w	1





spec29k_vbl:	
		move.l	screen_adr,d0			;set screen
		lsr.w	#8,d0				;
		move.l	d0,$ffff8200.w			;

		clr.w	$ffff8240.w
		
		move.l	screen_adr,d0
		move.l	screen_adr2,screen_adr
		move.l	d0,screen_adr2

		move.l	specscreen,d0
		move.l	specscreen2,specscreen
		move.l	d0,specscreen2

		move.l	spec29k_picdata1,d0
		move.l	spec29k_picdata2,spec29k_picdata1
		move.l	d0,spec29k_picdata2

		rts

spec29k_fadein:
		move.w	#6-1,.count
.loop:
		lea.l	spec29k_fadetab,a4
		add.w	.fadepos,a4
		
		cmp.w	#20*17*2-2,.fadepos
		blt.s	.add
		move.w	#-2,.fadepos
.add:		addq.w	#2,.fadepos

		move.l	screen_adr,a0
		lea.l	160(a0),a0
		move.l	screen_adr2,a1
		lea.l	160(a1),a1
		move.l	spec29k_picdata1,a2
		move.l	spec29k_picdata2,a3

		moveq.l	#0,d0
		moveq.l	#0,d1
		move.b	(a4)+,d0
		move.b	(a4)+,d1
		
		mulu.w	#160,d0	;y-ofs
		lsl.l	#4,d0
		lsl.l	#3,d1		;x-ofs
		add.l	d1,d0
		
		add.l	d0,a0
		add.l	d0,a1
		add.l	d0,a2
		add.l	d0,a3

		moveq.l	#0,d0
		rept	16
		move.l	(a2,d0.l),(a0,d0.l)
		move.l	4(a2,d0.l),4(a0,d0.l)		
		move.l	(a3,d0.l),(a1,d0.l)
		move.l	4(a3,d0.l),4(a1,d0.l)		
		add.l	#160,d0
		endr

		subq.w	#1,.count
		bpl.w	.loop

		rts
.count:		dc.w	0
.fadepos:	dc.w	0


spec29k_fadeout:
		move.w	#6-1,.count
.loop:
		lea.l	spec29k_fadetab,a4
		add.w	.fadepos,a4
		
		cmp.w	#20*17*2-2,.fadepos
		blt.s	.add
		move.w	#-2,.fadepos
.add:		addq.w	#2,.fadepos

		move.l	screen_adr,a0
		lea.l	160(a0),a0
		move.l	screen_adr2,a1
		lea.l	160(a1),a1

		moveq.l	#0,d0
		moveq.l	#0,d1
		move.b	(a4)+,d0
		move.b	(a4)+,d1
		
		mulu.w	#160,d0	;y-ofs
		lsl.l	#4,d0
		lsl.l	#3,d1		;x-ofs
		add.l	d1,d0
		
		add.l	d0,a0
		add.l	d0,a1

		moveq.l	#0,d0
		moveq.l	#0,d1
		rept	16
		move.l	d1,(a0,d0.l)
		move.l	d1,4(a0,d0.l)		
		move.l	d1,(a1,d0.l)
		move.l	d1,4(a1,d0.l)		
		add.l	#160,d0
		endr

		subq.w	#1,.count
		bpl.w	.loop

		rts
.count:		dc.w	0
.fadepos:	dc.w	0


spec29k_main:	bsr.w	spec29k_fadein
		rts

spec29k_main_out:
		bsr.w	spec29k_fadeout
		rts

spec29k_timer_a:
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		clr.b	$fffffa19.w


		movem.l d0-a6,-(sp)
		dcb.w 	52,$4e71

		move.b	#0,$ffff820a.w			;remove top border
		dcb.w 	6,$4e71
		lea.l	$ffff8209.w,a0
		moveq.l	#127,d1
		move.b	#2,$ffff820a.w

.sync:		tst.b	(a0)				;hardsync
		beq.s	.sync				;
		move.b	(a0),d2				;
		sub.b	d2,d1				;
		lsr.l	d1,d1				;

;		line 0 (inits + first palette) 

		dcb.w 	89-2-50,$4e71

		moveq.l	#0,d7				;1
		moveq.l	#2,d6				;1

		move.l	specscreen,a0			;5
		lea.l	$ffff8240.w,a4			;2
		move.l	a4,a1				;1
		move.w	#227-1,d5			;2

		rept	8				;set first palette
		move.l	(a0)+,(a1)+			;40
		endr



;		line 1-227
.speclines:	dcb.w	2,$4e71		;2
		move.l	a4,a1		;1
		move.l	a4,a2		;1
		move.l	a4,a3		;1
		rept	8
		move.l	(a0)+,(a1)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a2)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a3)+	;5*8
		endr
		dbra	d5,.speclines	;3 (4 when exit)
		
;special case line for preparing lower border
		;dcb.w	1,$4e71		;1
		move.l	a4,a5		;1 special case for next line
		move.l	a4,a1		;1
		move.l	a4,a2		;1
		move.l	a4,a3		;1
		rept	8
		move.l	(a0)+,(a1)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a2)+	;5*8
		endr
		move.l	(a0)+,(a3)+	;5
		move.l	(a0)+,(a3)+	;5
		move.l	(a0)+,(a3)+	;5
		move.l	(a0)+,(a3)+	;5
		move.l	(a0)+,(a3)+	;5
		move.b	d7,$ffff820a.w	;3 60Hz Kill lower border
		move.l	(a0)+,(a3)+	;5
		move.b	d6,$ffff820a.w	;3 50Hz
		move.l	(a0)+,(a3)+	;5
		move.l	(a0)+,(a3)+	;5
		;dcb.w	3,$4e71
;lower border line
		;dcb.w	2,$4e71		;2
		move.l	a4,a2		;1
		move.l	a4,a3		;1
		rept	8
		move.l	(a0)+,(a5)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a2)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a3)+	;5*8
		endr
		dcb.w	3-2,$4e71
		move.w	#44-1,d5	;2
		

.speclines2:	dcb.w	2,$4e71		;2
		move.l	a4,a1		;1
		move.l	a4,a2		;1
		move.l	a4,a3		;1
		rept	8
		move.l	(a0)+,(a1)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a2)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a3)+	;5*8
		endr
		dbra	d5,.speclines2	;3 (4 when exit)
	
		clr.w	$ffff8240.w
	
		movem.l (sp)+,d0-a6
		move.w	#$2300,sr
		rts
		


		section	data

specscreen:		dc.l	spec29k_pic1+43680
specscreen2:		dc.l	spec29k_pic2+43680
spec29k_picdata1:	dc.l	spec29k_pic1
spec29k_picdata2:	dc.l	spec29k_pic2

spec29k_pic1_lz77:	incbin	'spec29k/pic1.z77'
			ds.w	1
			even
spec29k_pic2_lz77:	incbin	'spec29k/pic2.z77'
			ds.w	1
			even

spec29k_fadetab:	dc.b	0,0
			dc.b	1,0,0,1
			dc.b	2,0,1,1,0,2
			dc.b	3,0,2,1,1,2,0,3
			dc.b	4,0,3,1,2,2,1,3,0,4
			dc.b	5,0,4,1,3,2,2,3,1,4,0,5
			dc.b	6,0,5,1,4,2,3,3,2,4,1,5,0,6
			dc.b	7,0,6,1,5,2,4,3,3,4,2,5,1,6,0,7
			dc.b	8,0,7,1,6,2,5,3,4,4,3,5,2,6,1,7,0,8
			dc.b	9,0,8,1,7,2,6,3,5,4,4,5,3,6,2,7,1,8,0,9
			dc.b	10,0,9,1,8,2,7,3,6,4,5,5,4,6,3,7,2,8,1,9,0,10
			dc.b	11,0,10,1,9,2,8,3,7,4,6,5,5,6,4,7,3,8,2,9,1,10,0,11
			dc.b	12,0,11,1,10,2,9,3,8,4,7,5,6,6,5,7,4,8,3,9,2,10,1,11,0,12
			dc.b	13,0,12,1,11,2,10,3,9,4,8,5,7,6,6,7,5,8,4,9,3,10,2,11,1,12,0,13
			dc.b	14,0,13,1,12,2,11,3,10,4,9,5,8,6,7,7,6,8,5,9,4,10,3,11,2,12,1,13,0,14
			dc.b	15,0,14,1,13,2,12,3,11,4,10,5,9,6,8,7,7,8,6,9,5,10,4,11,3,12,2,13,1,14,0,15
			dc.b	16,0,15,1,14,2,13,3,12,4,11,5,10,6,9,7,8,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15,0,16
			dc.b	16,1,15,2,14,3,13,4,12,5,11,6,10,7,9,8,8,9,7,10,6,11,5,12,4,13,3,14,2,15,1,16,0,17
			dc.b	16,2,15,3,14,4,13,5,12,6,11,7,10,8,9,9,8,10,7,11,6,12,5,13,4,14,3,15,2,16,1,17,0,18
			dc.b	16,3,15,4,14,5,13,6,12,7,11,8,10,9,9,10,8,11,7,12,6,13,5,14,4,15,3,16,2,17,1,18,0,19
			dc.b	16,4,15,5,14,6,13,7,12,8,11,9,10,10,9,11,8,12,7,13,6,14,5,15,4,16,3,17,2,18,1,19
			dc.b	16,5,15,6,14,7,13,8,12,9,11,10,10,11,9,12,8,13,7,14,6,15,5,16,4,17,3,18,2,19
			dc.b	16,6,15,7,14,8,13,9,12,10,11,11,10,12,9,13,8,14,7,15,6,16,5,17,4,18,3,19			
			dc.b	16,7,15,8,14,9,13,10,12,11,11,12,10,13,9,14,8,15,7,16,6,17,5,18,4,19
			dc.b	16,8,15,9,14,10,13,11,12,12,11,13,10,14,9,15,8,16,7,17,6,18,5,19						
			dc.b	16,9,15,10,14,11,13,12,12,13,11,14,10,15,9,16,8,17,7,18,6,19
			dc.b	16,10,15,11,14,12,13,13,12,14,11,15,10,16,9,17,8,18,7,19			
			dc.b	16,11,15,12,14,13,13,14,12,15,11,16,10,17,9,18,8,19			
			dc.b	16,12,15,13,14,14,13,15,12,16,11,17,10,18,9,19
			dc.b	16,13,15,14,14,15,13,16,12,17,11,18,10,19			
			dc.b	16,14,15,15,14,16,13,17,12,18,11,19									
			dc.b	16,15,15,16,14,17,13,18,12,19																		
			dc.b	16,16,15,17,14,18,13,19
			dc.b	16,17,15,18,14,19
			dc.b	16,18,15,19			
			dc.b	16,19

			
		section	text


		
