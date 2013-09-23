; twist.s
;
; Fullscreen tripple twisters



		section	text

;--- Init ----------------------------------------------------------------------------

twist_init:	rts

;--- Runtime Init ---------------------------------------------------------------------

twist_runtime_init:
		subq.w	#1,.once
		bne.w	.done


		jsr	black_pal
		jsr	clear_screens
		jsr	syncfix				;fix eventual bitplane corruption
		jsr	black_pal

		ifne	init_green
		move.w	#$0020,$ffff8240.w
		endc

		lea.l	twist_gfxlz77,a0
		lea.l	twist_gfx,a1
		jsr	lz77

		lea.l	twist_gfx,a0
		lea.l	72(a0),a1
		lea.l	208*56(a1),a2
		move.w	#56-1,d7
.gfxy:		move.w	#64/4-1,d6
.gfxx:		move.l	(a0)+,d0
		move.l	d0,(a1)+
		move.l	d0,(a2)+
		dbra	d6,.gfxx
		lea.l	208-64+208(a0),a0
		lea.l	208-64(a1),a1
		lea.l	208-64(a2),a2
		dbra	d7,.gfxy

		lea.l	twist_gfx,a0
		lea.l	208*56(a0),a1
		lea.l	144(a0),a2
		lea.l	208*56(a2),a3
		move.w	#56-1,d7
.gfxy2:		move.w	#64/4-1,d6
.gfxx2:		move.l	(a0)+,(a3)+
		move.l	(a1)+,(a2)+
		dbra	d6,.gfxx2
		lea.l	208-64(a0),a0
		lea.l	208-64(a1),a1
		lea.l	208-64(a2),a2
		lea.l	208-64(a3),a3
		dbra	d7,.gfxy2


		lea.l	twist_reallist,a0		;build scanlist with real offsets
		moveq.l	#0,d0
		move.w	#112-1,d7
.real:		move.w	d0,112*2(a0)
		move.w	d0,112*4(a0)
		move.w	d0,112*6(a0)
		move.w	d0,(a0)+
		add.l	#208,d0
		dbra	d7,.real

		
		lea.l	twist_scanlist,a0		;build linear scanlist
		moveq.l	#0,d0
		move.w	#112-1,d7
.sl1:
		move.w	d0,112*2*1(a0)
		move.w	d0,112*2*2(a0)
		move.w	d0,(a0)+
		addq.w	#2,d0
		dbra	d7,.sl1


		lea.l	twist_scanlist2,a0		;build sin-scanlist
		lea.l	twist_scanlist,a1
		lea.l	sincos4000,a2
		move.w	#512-1,d7
.sinloop:	add.l	#16,.sin
		and.l	#$1fff,.sin
		move.l	.sin,d0
		move.w	(a2,d0.l),d1
               	muls.w	#112,d1
		asr.l	#8,d1
		asr.l	#7,d1
		add.l	d1,d1
		add.l	#224,d1	;pos
		move.w	(a1,d1.l),512*2(a0)
		move.w	(a1,d1.l),(a0)+
		dbra	d7,.sinloop

;------------- copy overscan code
		lea.l	generic_code,a0

		move.l	#twist_code1_end,d0	;top 227 lines
		sub.l	#twist_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#227-1,d7
.code1a:	move.l	d0,d6
		lea.l	twist_code1_start,a1
.code1b:	move.w	(a1)+,(a0)+
		dbra	d6,.code1b
		dbra	d7,.code1a

		move.l	#twist_code2_end,d0	;2 midlines
		sub.l	#twist_code2_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#1-1,d7
.code2a:	move.l	d0,d6
		lea.l	twist_code2_start,a1
.code2b:	move.w	(a1)+,(a0)+
		dbra	d6,.code2b
		dbra	d7,.code2a

		move.l	#twist_code1_end,d0	;lower 44 lines (uses same code as top lines)
		sub.l	#twist_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#44-1,d7
.code3a:	move.l	d0,d6
		lea.l	twist_code1_start,a1
.code3b:	move.w	(a1)+,(a0)+
		dbra	d6,.code3b
		dbra	d7,.code3a
		
		move.w	dummy,(a0)+
;-------------- end of overscan code -----------


		ifne	init_green
		move.w	#$0070,$ffff8240.w
		endc

.done:		rts
.once:		dc.w	1
.sin:		dc.l	0


;--- VBL ----------------------------------------------------------------------------

twist_vbl1:
		bsr.w	twist_vbl


		cmp.l	#273*2,twist_rastpos
		bgt.s	.norastadd
		addq.l	#4,twist_rastpos
		lea.l	twist_rasters,a0
		add.l	twist_rastpos,a0
		move.l	a0,twist_rasters_adr
.norastadd:

		subq.w	#1,.wait
		bne.s	.no
		move.w	#2,.wait

		movem.l	twist_setpal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		
		lea.l	twist_setpal,a0
		lea.l	twist_pal1,a1
		jsr	component_fade
		
.no:		rts
.wait:		dc.w	5


twist_vbl2:
		bsr.w	twist_vbl

		subq.w	#1,.wait
		bne.s	.no
		move.w	#2,.wait

		movem.l	twist_setpal2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		
		lea.l	twist_setpal2,a0
		lea.l	twist_pal2,a1
		jsr	component_fade
		
.no:		rts
.wait:		dc.w	5


twist_vbl3:
		bsr.w	twist_vbl

		tst.l	twist_rastpos
		beq.s	.norastsub
		subq.l	#4,twist_rastpos
		lea.l	twist_rasters,a0
		add.l	twist_rastpos,a0
		move.l	a0,twist_rasters_adr
.norastsub:
		rts

twist_vbl4:
		bsr.w	twist_vbl

		tst.l	twist_rastpos
		beq.s	.norastsub
		subq.l	#4,twist_rastpos
		lea.l	twist_rasters,a0
		add.l	twist_rastpos,a0
		move.l	a0,twist_rasters_adr
.norastsub:
		not.w	.wait
		bne.s	.no
		
		movem.l	twist_setpal2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		
		lea.l	twist_setpal2,a0
		lea.l	twist_blackpal,a1
		jsr	component_fade
		
.no:		rts
.wait:		dc.w	0



twist_vbl:
		move.l	empty_adr,d0			;set screen
		lea.l	$ffff8203.w,a0
		movep.l	d0,(a0)

		lea.l	sincos4000,a2
		add.l	#32,.sin
		and.l	#$1fff,.sin
		move.l	.sin,d0
		move.w	(a2,d0.l),d1
               	muls.w	#129,d1
		asr.l	#8,d1
		asr.l	#7,d1
		add.l	#129,d1
		add.l	d1,d1
		lea.l	twist_scanlist2,a0
		add.l	d1,a0
		move.l	a0,twist_scanadr1

		lea.l	twist_scanlist2,a0
		add.l	.pos,a0
		move.l	a0,twist_scanadr2
		add.l	#4,.pos
		cmp.l	#512*2,.pos
		blt.s	.noclr
		clr.l	.pos
.noclr:


		rts
.pos:		dc.l	0
.sin:		dc.l	0

;--- Main ----------------------------------------------------------------------------

twist_main:	rts


;--- Timer A ------------------------------------------------------------------------------

twist_timer_a:	
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
		dcb.w 	66-20-18-5,$4e71	

		lea.l	$ffff8203.w,a0		;2
		lea.l	twist_gfx,a1		;3
		move.l	twist_scanadr1,a2	;5
		move.l	twist_scanadr2,a4	;5
		move.l	twist_realadr,a5	;5

		move.l	a1,d1			;1
		move.l	d1,a3			;1
		move.l	a5,a6			;1
		add.w	(a2)+,a6		;3
		add.w	(a4)+,a6		;3
		add.w	(a6),a3			;3
		move.l	a3,d0			;1
		move.l	twist_rasters_adr,a1	;5

		jsr	generic_code		;5
		
		move.l	empty_adr,d0
		movep.l	d0,(a0)
		clr.w	$ffff8240.w

		movem.l (sp)+,d0-a6
		move.w	#$2300,sr
		rts


twist_code1_start:
;line 1-227
		;rept	227
		movep.l	d0,(a0)			;6
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		movem.l	d0-a7,twist_dump	;36
		movem.l	d0-a7,twist_dump	;36
		movem.l	d0-d6,twist_dump	;18
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w	20-16,$4e71
		move.l	d1,a3			;1
		move.l	a5,a6			;1
		add.w	(a2)+,a6		;3
		add.w	(a4)+,a6		;3
		add.w	(a6),a3			;3
		move.l	a3,d0			;1
		move.w	(a1)+,$ffff8240.w	;4
		;endr
twist_code1_end:

twist_code2_start:
;line 228
		movep.l	d0,(a0)			;6
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		movem.l	d0-a7,twist_dump	;36
		movem.l	d0-a7,twist_dump	;36
		movem.l	d0-d6,twist_dump	;18
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w	20-19,$4e71
		move.l	d1,a3			;1
		move.l	a5,a6			;1
		add.w	(a2)+,a6		;3
		add.w	(a4)+,a6		;3
		add.w	(a6),a3			;3
		move.l	a3,d0			;1
		move.w	(a1)+,$ffff8240.w	;4
		movep.l	d0,(a0)			;3 (plus 3 next scan)

;line 229
		;dcb.w	3,$4e71			;3 3 nops from previous line
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		move.b	d6,$ffff820a.w		;3
		movem.l	d0-a7,twist_dump	;36
		movem.l	d0-a7,twist_dump	;36
		movem.w	d0-a2,twist_dump	;15
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w	20-16,$4e71
		move.l	d1,a3			;1
		move.l	a5,a6			;1
		add.w	(a2)+,a6		;3
		add.w	(a4)+,a6		;3
		add.w	(a6),a3			;3
		move.l	a3,d0			;1
		move.w	(a1)+,$ffff8240.w	;4

twist_code2_end:


;--- Data ---------------------------------------------------------------------------------------------
		
		section	data


twist_blackpal:	dcb.w	16,$0000
twist_setpal:	dcb.w	16,$0000
twist_setpal2:	dc.w	$0000
		dcb.w	15,$0fff
twist_pal1:	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000


twist_pal2:	dc.w	$0000,$0800,$0100,$0900,$0280,$0a18,$0391,$0b29
		dc.w	$04a2,$0c3a,$05b3,$0d4b,$06c4,$0e65,$0f76,$0fff

twist_rastpos:		dc.l	0
twist_rasters_adr:	dc.l	twist_rasters
twist_rasters:
		dcb.w	273,$0000

		dcb.l	6,$00080000
		dcb.l	6,$00080008
		dcb.l	6,$00010000
		dcb.l	6,$00010001
		dcb.l	6,$00090001
		dcb.l	6,$00090009
		dcb.l	6,$00020009
		dcb.l	6,$00020002
		dcb.l	6,$000a0002
		dcb.l	6,$000a000a
		dcb.l	6,$0003000a
		dcb.l	6,$00030003
		dcb.l	6,$088b0003
		dcb.l	6,$088b088b
		dcb.l	6,$0114088b
		dcb.l	6,$01140114

		dcb.l	6,$099c0114
		dcb.l	6,$099c099c
		dcb.l	6,$0225099c
		dcb.l	6,$02250225
		dcb.l	6,$0aad0225
		dcb.l	6,$0aad0aad
		dcb.l	6,$03360aad
		dcb.l	6,$03360336
		dcb.l	6,$0bbe0336
		dcb.l	6,$0bbe0bbe
		dcb.l	6,$04470bbe
		dcb.l	6,$04470447
		dcb.l	6,$0ccf0447
		dcb.l	6,$0ccf0ccf
		dcb.l	6,$055f0ccf
		dcb.l	6,$055f055f

		dcb.l	6,$0ddf055f
		dcb.l	6,$0ddf0ddf
		dcb.l	6,$066f0ddf
		dcb.l	6,$066f066f
		dcb.l	6,$0eef066f
		dcb.l	6,$0eef0eef
		dcb.l	6,$077f0eef
		dcb.l	6,$077f077f
		dcb.l	6,$0fff077f
		dcb.l	6,$0fff0fff
		dcb.l	6,$00bf003f
		dcb.l	6,$00bf00bf
		dcb.l	6,$004f00bf
		dcb.l	6,$004f004f
		
twist_gfxlz77:		incbin	'twist/twist.z77'	;lz77!
			even

twist_scanadr1:		dc.l	twist_scanlist
twist_scanadr2:		dc.l	twist_scanlist2
twist_realadr:		dc.l	twist_reallist


		section	bss

twist_dump:		ds.l	16

		section	text
