; midtext.s
;
; Between effects text displayer to take attention away from precalcs


mt_border:	equ	0

		section	text

midtext_init:	rts

midtext_greets_runtime_init:
		subq.w	#1,.once
		bne	.no

		move.l	#160*240,midtext_scr_ofs
		move.l	#8*450,midtext_rasters_ofs
		move.l	#midtext_rasters,midtext_rasteradr
		move.w	#1,midtext_wait
		move.w	#2,midtext_wait2

		jsr	syncfix				;fix eventual bitplane corruption
		jsr	black_pal
		jsr	clear_screens

		move.l	screen_adr_base,a0
		add.l	#160*170,a0
		lea.l	midtext_greets,a1
		move.w	#200*20-1,d7
.gfx:
		move.l	(a1)+,(a0)+
		addq.l	#4,a0
		
		dbra	d7,.gfx

		bsr.w	midtext_copper_runtime_init

.no:		rts
.once:		dc.w	1

midtext_credits_runtime_init:
		subq.w	#1,.once
		bne	.no

		move.l	#160*240,midtext_scr_ofs
		move.l	#8*450,midtext_rasters_ofs
		move.l	#midtext_rasters,midtext_rasteradr
		move.w	#2,midtext_wait
		move.w	#6,midtext_wait2

		jsr	syncfix				;fix eventual bitplane corruption
		jsr	black_pal
		jsr	clear_screens

		move.l	screen_adr_base,a0
		add.l	#160*170,a0
		lea.l	midtext_credits,a1
		move.w	#200*20-1,d7
.gfx:
		move.l	(a1)+,(a0)+
		addq.l	#4,a0
		
		dbra	d7,.gfx

		bsr.w	midtext_copper_runtime_init

.no:		rts
.once:		dc.w	1



midtext_greets_runtime_exit:
		subq.w	#1,.once
		bne.s	.no

		bsr.w	midtext_copper_exit

.no:		rts
.once:		dc.w	1


midtext_credits_runtime_exit:
		subq.w	#1,.once
		bne.s	.no

		bsr.w	midtext_copper_exit

.no:		rts
.once:		dc.w	1
		


midtext_vbl:
		move.l	screen_adr_base,d0		;set screen
		add.l	midtext_scr_ofs,d0
		lea.l	$ffff8203.w,a0
		movep.l	d0,(a0)

		;move.l	screen_adr,d0			;swap screens
		;move.l	screen_adr2,screen_adr		;
		;move.l	d0,screen_adr2			;

		;movem.l	midtext_pal,d0-d7
		;movem.l	d0-d7,$ffff8240.w


		subq.w	#1,midtext_wait
		;bne.s	.norast
		move.w	#2,midtext_wait
		tst.l	midtext_rasters_ofs
		beq.s	.norast
		subq.l	#8,midtext_rasters_ofs
.norast:

		subq.w	#1,midtext_wait2
		bne.s	.noscr
		move.w	#2,midtext_wait2
		tst.l	midtext_scr_ofs
		beq.s	.noscr
		sub.l	#160,midtext_scr_ofs
.noscr:


		bsr.w	midtext_copper_vbl


		rts
midtext_wait:		dc.w	1
midtext_wait2:		dc.w	2


midtext_main:	rts



		ifne	mt_border
midtext_timer_a:	;remove top border
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		clr.b	$fffffa19.w

		dcb.w 	84,$4e71

		move.b	#0,$ffff820a.w			;remove top border
		dcb.w 	9,$4e71
		move.b	#2,$ffff820a.w

		;init low border timer-a
		move.b	#177,$fffffa1f.w
		move.b	#%0111,$fffffa19.w
		move.l	#midtext_timer_a_low,$134.w

		move.w	#$2300,sr
		rts

midtext_timer_a_low: ;remove low border
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		clr.b	$fffffa19.w


		movem.l	d0/d7,-(sp)
		move.w	#44-1,d7	;real ste 52, hatari 48
.loop:		nop
		dbra	d7,.loop

		move.b	#0,$ffff820a.w			;remove low border
		dcb.w	4,$4e71	;4
		move.b	#2,$ffff820a.w

		movem.l	(sp)+,d0/d7

		move.l	#timer_a,$134.w
		move.w	#$2300,sr
		rte
		endc
		
		ifeq	mt_border
midtext_timer_a:	rts
		endc


midtext_copper_runtime_init:
		move.w	sr,d0				;setup copper
		move.w	#$2700,sr
		move.l	#midtext_copper_interrupt,$120.w
		bset	#0,$fffffa07.w			;init mfp
		bset	#0,$fffffa0f.w
		bset	#0,$fffffa13.w
		clr.b	$fffffa1b.w			;stop tb
		move.w	d0,sr
		rts
		
midtext_copper_vbl:
		move.w	sr,d0
		move.w	#$2700,sr
		clr.b	$fffffa1b.w			;stop tb
		move.b	#1,$fffffa21.w			;scans before interupt
		move.b	#8,$fffffa1b.w			;start tb count
		move.w	d0,sr
		lea.l	midtext_rasters,a0
		add.l	midtext_rasters_ofs,a0
		move.l	a0,midtext_rasteradr
		rts

midtext_copper_interrupt:
		move.l	a0,-(sp)
		move.l	midtext_rasteradr,a0
		move.l	(a0)+,$ffff8240.w
		move.l	(a0)+,$ffff8244.w
		move.l	a0,midtext_rasteradr
		move.l	(sp)+,a0
		rte

midtext_copper_exit:
		clr.b	$fffffa1b.w
		move.l	save_buffer+8,$120.w
		rts


		section	data

midtext_scr_ofs:	dc.l	160*240
midtext_rasters_ofs:	dc.l	8*450
midtext_rasteradr:	dc.l	midtext_rasters
midtext_rasters:
		dcb.w	280*4,$0000

		ifeq	1
		dc.w	$0000,$0888,$0888,$0888
		dc.w	$0000,$0111,$0111,$0111
		dc.w	$0000,$0119,$0999,$0999
		dc.w	$0000,$011a,$0aaa,$0aaa
		dc.w	$0000,$0112,$0222,$0222
		dc.w	$0000,$011b,$022b,$0bbb
		dc.w	$0000,$0113,$0223,$0333
		dc.w	$0000,$0113,$022c,$0ccc
		dc.w	$0000,$0113,$0224,$0444
		dc.w	$0000,$0113,$022d,$044d
		dc.w	$0000,$0113,$0225,$0445
		dc.w	$0000,$0113,$0225,$044e
		rept	150
		dc.w	$0000,$0113,$0225,$0447
		endr
		dc.w	$0000,$0113,$0225,$044e
		dc.w	$0000,$0113,$0225,$0445
		dc.w	$0000,$0113,$022d,$044d
		dc.w	$0000,$0113,$0224,$0444
		dc.w	$0000,$0113,$022c,$0ccc
		dc.w	$0000,$0113,$0223,$0333
		dc.w	$0000,$011b,$022b,$0bbb
		dc.w	$0000,$0112,$0222,$0222
		dc.w	$0000,$011a,$0aaa,$0aaa
		dc.w	$0000,$0119,$0999,$0999
		dc.w	$0000,$0111,$0111,$0111
		dc.w	$0000,$0888,$0888,$0888
		endc

		ifeq	0
		dc.w	$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0000,$0888
		dc.w	$0000,$0000,$0000,$0111
		dc.w	$0000,$0000,$0000,$0999
		dc.w	$0000,$0000,$0000,$0222
		dc.w	$0000,$0000,$0888,$0aaa
		dc.w	$0000,$0000,$0111,$0333
		dc.w	$0000,$0000,$0999,$0bbb
		dc.w	$0000,$0000,$0222,$0444
		dc.w	$0000,$0888,$0aaa,$0ccc
		dc.w	$0000,$0111,$0333,$0555
		dc.w	$0000,$0999,$0bbb,$0ddd
		rept	150
		dc.w	$0000,$0222,$0444,$0666
		endr
		dc.w	$0000,$0999,$0bbb,$0ddd
		dc.w	$0000,$0111,$0333,$0555
		dc.w	$0000,$0888,$0aaa,$0ccc
		dc.w	$0000,$0000,$0222,$0444
		dc.w	$0000,$0000,$0999,$0bbb
		dc.w	$0000,$0000,$0111,$0333
		dc.w	$0000,$0000,$0888,$0aaa
		dc.w	$0000,$0000,$0000,$0222
		dc.w	$0000,$0000,$0000,$0999
		dc.w	$0000,$0000,$0000,$0111
		dc.w	$0000,$0000,$0000,$0888
		dc.w	$0000,$0000,$0000,$0000
		endc

		dcb.w	280*4,$0000

		

midtext_pal:		dc.w	$0000,$0222,$0444,$0666
			dcb.w	12,$0000

midtext_greets:		incbin	'midtext/greets.2pl'
			even
midtext_credits:	incbin	'midtext/credits.2pl'
			even
		
		section	bss

		section	text


