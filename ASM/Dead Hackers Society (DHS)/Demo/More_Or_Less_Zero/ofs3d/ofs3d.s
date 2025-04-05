; ofs3d.s
;
; Offset map effect (3d-like)
; 416x136 2x2 pixel 4bpl

ofs3d_cpu:	equ	0

		section	text

;--- Init --------------------------------------------------------------------

ofs3d_init:	rts

ofs3d_runtime_init:
		subq.w	#1,.once
		bne.w	.no
		jsr	syncfix				;fix eventual bitplane corruption
		jsr	black_pal

		ifne	init_green
		move.w	#$0020,$ffff8240.w
		endc

		;jsr	clear_screens
		;jsr	init_c2p
		
		lea.l	ofs3d_texture,a0
		lea.l	ofs3d_texture_depack,a1
		jsr	lz77

		
		lea.l	ofs3d_texture_depack,a0		;preshift and double-copy 
		lea.l	ofs3d_txt1,a1
		lea.l	ofs3d_txt2,a2
		move.l	#256*256,d1
		move.w	#256*256-1,d7
.preshift:	moveq.l	#0,d0
		move.b	(a0)+,d0
	;	lsr.b	#4,d0
		move.b	d0,(a1,d1.l)
		move.b	d0,(a1)+
		lsl.w	#4,d0
		move.b	d0,(a2,d1.l)
		move.b	d0,(a2)+
		lsl.w	#4,d0
		dbra	d7,.preshift

		lea.l	ofs3d_scanlist1,a0
		lea.l	ofs3d_scanlist2,a1
		move.l	screen_adr,d0
		move.l	screen_adr2,d1
		move.w	#274/2-1,d7
.scan:
		move.l	d0,(a0)+
		move.l	d1,(a1)+
		move.l	d0,(a0)+
		move.l	d1,(a1)+

		add.l	#208,d0
		add.l	#208,d1
		dbra	d7,.scan
		
		move.l	#ofs3d_ofs+640*40+152,ofs3d_ofspos
		move.l	screen_adr,ofs3d_scrpos

		;make rasterlist from palette
		lea.l	ofs3d_rasters+118*2*2,a0
		lea.l	ofs3d_rastpal,a1
		move.w	#30-1,d7
.rasters:	move.w	(a1)+,d0
		move.w	(a1),d1
		rept	6
		move.w	d0,(a0)+
		endr
		rept	3
		move.w	d1,(a0)+
		move.w	d0,(a0)+
		endr
		dbra	d7,.rasters

		;precalc palette fade
		lea.l	ofs3d_fadepals+32,a6
		move.w	#15-1,d7
.fadepals:	movem.l	d0-a6,-(sp)
		lea.l	ofs3d_mainpal,a0
		lea.l	ofs3d_pal,a1
		jsr	fade
		movem.l	(sp)+,d0-a6
		movem.l	ofs3d_mainpal,d0-d6/a0
		movem.l	d0-d6/a0,(a6)
		lea.l	32(a6),a6
		dbra	d7,.fadepals


		ifne	init_green
		move.w	#$0070,$ffff8240.w
		endc	
	
.no:		rts
.once:		dc.w	1

;--- VBL ---------------------------------------------------------------------

Y_AMP	=	110
Y_OFS	=	55


ofs3d_vbl:
		lea.l	$ffff8203.w,a0
		move.l	empty_adr,d0
		movep.l	d0,(a0)

		move.l	ofs3d_paladr,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,$ffff8240.w
		
		add.l	#16,ofs3d_ysin
		and.l	#$1fff,ofs3d_ysin
		lea.l	sincos4000,a0
		move.l	ofs3d_ysin,d0
		move.w	(a0,d0.l),d1
               	muls.w	#Y_AMP,d1	;44	;y-sin amplitude
		asr.l	#8,d1
		asr.l	#7,d1
		move.l	d1,d2
		asl.l	#1,d2
		lea.l	ofs3d_rasters+118,a0	+118
		add.l	d2,a0
		add.w	ofs3d_rastofs,a0
		move.l	a0,ofs3d_rastpos
		muls.w	#640,d1
		move.l	d1,ofs3d_ysin_calced
		
		move.l	ofs3d_vbladr,a0
		jsr	(a0)
		rts

ofs3d_vbl1:
		move.l	screen_adr,d0				;swap screenbufs
		move.l	screen_adr2,screen_adr
		move.l	d0,screen_adr2

		move.l	ofs3d_scanadr1,d0			;swap copperlist bufs
		move.l	ofs3d_scanadr2,ofs3d_scanadr1
		move.l	d0,ofs3d_scanadr2
		move.l	#ofs3d_vbl2,ofs3d_vbladr

		lea.l	sincos4000,a0
		move.l	ofs3d_xsin,d0
		move.w	(a0,d0.l),d2
               	muls.w	#320-208,d2	;opt
		asr.l	#8,d2
		asr.l	#7,d2
		add.l	d2,d2

		move.l	#ofs3d_ofs+640*Y_OFS+112,ofs3d_ofspos
		move.l	ofs3d_ysin_calced,d1
		add.l	d1,ofs3d_ofspos
		add.l	d2,ofs3d_ofspos
		
		move.l	screen_adr,ofs3d_scrpos

		add.l	#46,ofs3d_xsin
		and.l	#$1fff,ofs3d_xsin
		
		add.l	#256*5,ofs3d_txtpos
		and.l	#$ffff,ofs3d_txtpos

		bsr.w	ofs3d_view

		rts

ofs3d_vbl2:	bsr.w	ofs3d_view
		move.l	#ofs3d_vbl3,ofs3d_vbladr
		rts

ofs3d_vbl3:	bsr.w	ofs3d_view
		move.l	#ofs3d_vbl4,ofs3d_vbladr
		rts

ofs3d_vbl4:	bsr.w	ofs3d_view
		move.l	#ofs3d_vbl5,ofs3d_vbladr
		rts

ofs3d_vbl5:	bsr.w	ofs3d_view
		move.l	#ofs3d_vbl1,ofs3d_vbladr
		rts


;--- Main --------------------------------------------------------------------

ofs3d_main_in:
		cmp.w	#(336+118)*2,ofs3d_rastofs
		beq.s	.rastok
		addq.w	#4,ofs3d_rastofs
.rastok:	subq.w	#1,.wait
		bne.s	.nofade
		move.w	#15,.wait
		cmp.l	#32*15,.fadepos
		beq.s	.nofade
		add.l	#32,.fadepos
		lea.l	ofs3d_fadepals,a0
		add.l	.fadepos,a0
		move.l	a0,ofs3d_paladr
.nofade:	rts
.wait:		dc.w	20
.fadepos:	dc.l	0

ofs3d_main_out:
		tst.w	ofs3d_rastofs
		beq.s	.rastok
		subq.w	#4,ofs3d_rastofs
.rastok:	subq.w	#1,.wait
		bne.s	.nofade
		move.w	#10,.wait
		tst.l	.fadepos
		beq.s	.nofade
		sub.l	#32,.fadepos
		lea.l	ofs3d_fadepals,a0
		add.l	.fadepos,a0
		move.l	a0,ofs3d_paladr
.nofade:	rts
.wait:		dc.w	20
.fadepos:	dc.l	32*15
		

;ofs3d_main:	rts

ofs3d_view:
		lea.l	c2ptable,a0
		lea.l	ofs3d_txt1+256*128+128,a1
		lea.l	ofs3d_txt2+256*128+128,a2
		add.l	ofs3d_txtpos,a1
		add.l	ofs3d_txtpos,a2
		move.l	ofs3d_ofspos,a5
		move.l	ofs3d_scrpos,a6
		moveq.l	#0,d0

		move.w	#4-1,d7
.y:
q:		set	0
		rept	26
		moveq.l	#0,d1				;1
		move.w	(a5)+,d0			;2
		or.b	(a2,d0.w),d1			;4
		move.w	(a5)+,d0			;2
		or.b	(a1,d0.w),d1			;4
		lsl.w	#8,d1				;6
		move.w	(a5)+,d0			;2
		or.b	(a2,d0.w),d1			;4 25
		move.w	(a5)+,d0			;2
		or.b	(a1,d0.w),d1			;4
		lsl.l	#2,d1				;3
		move.l	(a0,d1.l),d1			;5
		movep.l	d1,q(a6)			;6	
		moveq.l	#0,d1				;1
		move.w	(a5)+,d0			;2
		or.b	(a2,d0.w),d1			;4 27
		move.w	(a5)+,d0			;2
		or.b	(a1,d0.w),d1			;4
		lsl.w	#8,d1				;6
		move.w	(a5)+,d0			;2
		or.b	(a2,d0.w),d1			;4
		move.w	(a5)+,d0			;2
		or.b	(a1,d0.w),d1			;4 
		lsl.l	#2,d1				;3
		move.l	(a0,d1.l),d1			;5 32
		movep.l	d1,q+1(a6)			;6
q:		set	q+8
		endr
		lea.l	208(a6),a6
		lea.l	640-416(a5),a5
		dbra	d7,.y

		move.l	a6,ofs3d_scrpos
		move.l	a5,ofs3d_ofspos

		ifne	ofs3d_cpu
		move.w	#$0021,$ffff8240.w
		endc
		
		rts

;--- Timer A -----------------------------------------------------------------

ofs3d_timer_a:	
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		clr.b	$fffffa19.w


		movem.l d0-a6,-(sp)
		dcb.w 	52-2,$4e71

		moveq.l	#0,d7			;1
		moveq.l	#2,d6			;1

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

;		66 nops until the first scanline, use for inits etc
		dcb.w 	66-10-32-4-5-5-2-1-4,$4e71	

		lea.l	$ffff8203.w,a4			;2
		move.l	ofs3d_scanadr2,a3		;5
		move.l	(a3)+,d5			;3

		lea.l	c2ptable,a0			;3
		lea.l	ofs3d_txt1+256*128+128,a1	;3
		lea.l	ofs3d_txt2+256*128+128,a2	;3
		add.l	ofs3d_txtpos,a1			;6
		add.l	ofs3d_txtpos,a2			;6
		move.l	ofs3d_ofspos,a5			;5
		move.l	ofs3d_scrpos,a6			;5
		moveq.l	#0,d0				;1

		ifne	ofs3d_cpu
		move.w	#$0000,$ffff8240.w		;4
		endc
		ifeq	ofs3d_cpu
		dcb.w	4,$4e71
		endc

		move.l	a7,ofs3d_savea7			;5
		;lea.l	ofs3d_rasters,a7		;3
		move.l	ofs3d_rastpos,a7		;5
		move.w	#5-1,d2				;2
		move.w	(a7)+,$ffff8240.w		;4
		movep.l	d5,(a4)				;6-5

.loop:

q:		set	0
z:		set	0
		rept	26
		dcb.w	6-5,$4e71
		move.b	d6,$ffff8260.w			;3
		move.b	d7,$ffff8260.w			;3
		moveq.l	#0,d1				;1
		move.w	(a5)+,d0			;2
		or.b	(a2,d0.w),d1			;4
		move.w	(a5)+,d0			;2
		or.b	(a1,d0.w),d1			;4
		lsl.w	#8,d1				;6
		move.w	(a5)+,d0			;2
		or.b	(a2,d0.w),d1			;4 25
		move.w	(a5)+,d0			;2
		or.b	(a1,d0.w),d1			;4
		lsl.l	#2,d1				;3
		move.l	(a0,d1.l),d1			;5
		movep.l	d1,q(a6)			;6	
		moveq.l	#0,d1				;1
		move.w	(a5)+,d0			;2
		or.b	(a2,d0.w),d1			;4 27
		move.w	(a5)+,d0			;2
		or.b	(a1,d0.w),d1			;4
		lsl.w	#8,d1				;6
		move.w	(a5)+,d0			;2
		or.b	(a2,d0.w),d1			;4
		move.w	(a5)+,d0			;2
		or.b	(a1,d0.w),d1			;4 
		lsl.l	#2,d1				;3
		move.l	(a0,d1.l),d1			;5 32
		movep.l	d1,q+1(a6)			;6
		move.b	d7,$ffff820a.w			;3
		move.b	d6,$ffff820a.w			;3
		dcb.w	20-8,$4e71
		move.l	(a3)+,d5			;3
		move.w	(a7)+,$ffff8240.w		;4
		movep.l	d5,(a4)				;6-5
q:		set	q+8
z:		set	z+2
		endr

		dcb.w	6-5,$4e71
		move.b	d6,$ffff8260.w			;3
		move.b	d7,$ffff8260.w			;3
		movem.l	d0-a7,global_dump		;36
		movem.l	d0-a7,global_dump		;36
		movem.l	d0-d6,global_dump		;18
		move.b	d7,$ffff820a.w			;3
		move.b	d6,$ffff820a.w			;3
		dcb.w	5,$4e71
		move.l	(a3)+,d5			;3
		lea.l	208(a6),a6			;2
		lea.l	640-416(a5),a5			;2
		move.w	(a7)+,$ffff8240.w		;4
		movep.l	d5,(a4)				;6-5
		dbra	d2,.loop			;3

; last remaining overscan lines

q:		set	0
		;dcb.w	6-1,$4e71
		move.b	d6,$ffff8260.w			;3
		move.b	d7,$ffff8260.w			;3
		moveq.l	#0,d1				;1
		move.w	(a5)+,d0			;2
		or.b	(a2,d0.w),d1			;4
		move.w	(a5)+,d0			;2
		or.b	(a1,d0.w),d1			;4
		lsl.w	#8,d1				;6
		move.w	(a5)+,d0			;2
		or.b	(a2,d0.w),d1			;4 25
		move.w	(a5)+,d0			;2
		or.b	(a1,d0.w),d1			;4
		lsl.l	#2,d1				;3
		move.l	(a0,d1.l),d1			;5
		movep.l	d1,q(a6)			;6	
		moveq.l	#0,d1				;1
		move.w	(a5)+,d0			;2
		or.b	(a2,d0.w),d1			;4 27
		move.w	(a5)+,d0			;2
		or.b	(a1,d0.w),d1			;4
		lsl.w	#8,d1				;6
		move.w	(a5)+,d0			;2
		or.b	(a2,d0.w),d1			;4
		move.w	(a5)+,d0			;2
		or.b	(a1,d0.w),d1			;4 
		lsl.l	#2,d1				;3
		move.l	(a0,d1.l),d1			;5 32
		movep.l	d1,q+1(a6)			;6
		move.b	d7,$ffff820a.w			;3
		move.b	d6,$ffff820a.w			;3
		dcb.w	20-8,$4e71
		move.l	(a3)+,d5			;3
		move.w	(a7)+,$ffff8240.w		;4
		movep.l	d5,(a4)				;6-5
q:		set	q+8
		rept	4
		dcb.w	6-5,$4e71
		move.b	d6,$ffff8260.w			;3
		move.b	d7,$ffff8260.w			;3
		moveq.l	#0,d1				;1
		move.w	(a5)+,d0			;2
		or.b	(a2,d0.w),d1			;4
		move.w	(a5)+,d0			;2
		or.b	(a1,d0.w),d1			;4
		lsl.w	#8,d1				;6
		move.w	(a5)+,d0			;2
		or.b	(a2,d0.w),d1			;4 25
		move.w	(a5)+,d0			;2
		or.b	(a1,d0.w),d1			;4
		lsl.l	#2,d1				;3
		move.l	(a0,d1.l),d1			;5
		movep.l	d1,q(a6)			;6	
		moveq.l	#0,d1				;1
		move.w	(a5)+,d0			;2
		or.b	(a2,d0.w),d1			;4 27
		move.w	(a5)+,d0			;2
		or.b	(a1,d0.w),d1			;4
		lsl.w	#8,d1				;6
		move.w	(a5)+,d0			;2
		or.b	(a2,d0.w),d1			;4
		move.w	(a5)+,d0			;2
		or.b	(a1,d0.w),d1			;4 
		lsl.l	#2,d1				;3
		move.l	(a0,d1.l),d1			;5 32
		movep.l	d1,q+1(a6)			;6
		move.b	d7,$ffff820a.w			;3
		move.b	d6,$ffff820a.w			;3
		dcb.w	20-8,$4e71
		move.l	(a3)+,d5			;3
		move.w	(a7)+,$ffff8240.w		;4
		movep.l	d5,(a4)				;6-5
q:		set	q+8
		endr

; still in synclock synclock but not overscan

		ifne	ofs3d_cpu
		move.w	#$0210,$ffff8240.w
		endc
		ifeq	ofs3d_cpu
		clr.w	$ffff8240.w
		endc

; fill line started in the last overscan lines
		rept	21
		moveq.l	#0,d1				;1
		move.w	(a5)+,d0			;2
		or.b	(a2,d0.w),d1			;4
		move.w	(a5)+,d0			;2
		or.b	(a1,d0.w),d1			;4
		lsl.w	#8,d1				;6
		move.w	(a5)+,d0			;2
		or.b	(a2,d0.w),d1			;4 25
		move.w	(a5)+,d0			;2
		or.b	(a1,d0.w),d1			;4
		lsl.l	#2,d1				;3
		move.l	(a0,d1.l),d1			;5
		movep.l	d1,q(a6)			;6	
		moveq.l	#0,d1				;1
		move.w	(a5)+,d0			;2
		or.b	(a2,d0.w),d1			;4 27
		move.w	(a5)+,d0			;2
		or.b	(a1,d0.w),d1			;4
		lsl.w	#8,d1				;6
		move.w	(a5)+,d0			;2
		or.b	(a2,d0.w),d1			;4
		move.w	(a5)+,d0			;2
		or.b	(a1,d0.w),d1			;4 
		lsl.l	#2,d1				;3
		move.l	(a0,d1.l),d1			;5 32
		movep.l	d1,q+1(a6)			;6
q:		set	q+8
		endr
		lea.l	208(a6),a6			;2
		lea.l	640-416(a5),a5			;2

		move.w	#4-1,d2				;2
.loop2:

q:		set	0
		rept	26
		moveq.l	#0,d1				;1
		move.w	(a5)+,d0			;2
		or.b	(a2,d0.w),d1			;4
		move.w	(a5)+,d0			;2
		or.b	(a1,d0.w),d1			;4
		lsl.w	#8,d1				;6
		move.w	(a5)+,d0			;2
		or.b	(a2,d0.w),d1			;4 25
		move.w	(a5)+,d0			;2
		or.b	(a1,d0.w),d1			;4
		lsl.l	#2,d1				;3
		move.l	(a0,d1.l),d1			;5
		movep.l	d1,q(a6)			;6	
		moveq.l	#0,d1				;1
		move.w	(a5)+,d0			;2
		or.b	(a2,d0.w),d1			;4 27
		move.w	(a5)+,d0			;2
		or.b	(a1,d0.w),d1			;4
		lsl.w	#8,d1				;6
		move.w	(a5)+,d0			;2
		or.b	(a2,d0.w),d1			;4
		move.w	(a5)+,d0			;2
		or.b	(a1,d0.w),d1			;4 
		lsl.l	#2,d1				;3
		move.l	(a0,d1.l),d1			;5 32
		movep.l	d1,q+1(a6)			;6
q:		set	q+8
		endr

		lea.l	208(a6),a6			;2
		lea.l	640-416(a5),a5			;2

		dbra	d2,.loop2

		move.l	a6,ofs3d_scrpos
		move.l	a5,ofs3d_ofspos

		ifne	ofs3d_cpu
		move.w	#$0021,$ffff8240.w
		endc

		move.l	ofs3d_savea7,a7
		movem.l (sp)+,d0-a6
		move.w	#$2300,sr
		rts

;--- Data --------------------------------------------------------------------

		section	data

ofs3d_vbladr:		dc.l	ofs3d_vbl1
ofs3d_scrpos:		dc.l	0
ofs3d_ofspos:		dc.l	0
ofs3d_txtpos:		dc.l	0
ofs3d_scanadr1:		dc.l	ofs3d_scanlist1
ofs3d_scanadr2:		dc.l	ofs3d_scanlist2
ofs3d_set:		dc.l	0
ofs3d_listpos:		dc.l	ofs3d_scanlist1

ofs3d_rastpos:		dc.l	ofs3d_rasters

ofs3d_rastpal:
			dc.w	$0000,$0008,$0001,$0009,$0002,$000a,$0003,$000b
			dc.w	$0004,$000c,$0005,$000d,$0006,$000e,$0007,$000f

			dc.w	$088f,$011f,$099f,$022f,$0aaf,$033f,$0bbf,$044f
			dc.w	$0ccf,$055f,$0ddf,$066f,$0eef,$077f,$0fff,$0fff


ofs3d_paladr:		dc.l	ofs3d_fadepals
ofs3d_mainpal:		dcb.w	16,$0000
ofs3d_pal:		dc.w	$0000,$0fff,$0eff,$06ef,$0d67,$0777,$0edc,$0654
			dc.w	$0dcb,$0543,$0cba,$0432,$0ba9,$0321,$0a98,$0210


ofs3d_ofs:		incbin	'ofs3d/indoor.ofs'
			even
ofs3d_texture:		incbin	'ofs3d/text3.z77'	;lz77!

			even

ofs3d_xsin:		dc.l	0
ofs3d_ysin:		dc.l	3400	;start with sky view
ofs3d_rastsin:		dc.l	0
ofs3d_rastofs:		dc.w	0	;118*2
ofs3d_ysin_calced:	dc.l	0
ofs3d_savea7:		dc.l	0

		section	bss

ofs3d_scanlist1:	ds.l	600
ofs3d_scanlist2:	ds.l	600
ofs3d_rasters:		ds.w	596	;118+118+360
ofs3d_fadepals:		ds.w	16*16


		section	text

