; plax.s
;
; Twin parallax effect

		section	text

;--- Init ----------------------------------------------------------------------------

plax_init:	rts

;--- Runtime Init ---------------------------------------------------------------------

plax_runtime_init:		;50 vbl!
		subq.w	#1,.once
		bne.w	.done

		jsr	black_pal
		jsr	clear_screens
		jsr	syncfix				;fix eventual bitplane corruption
		jsr	black_pal

		lea.l	plax_hrast,a0
		move.l	screen_adr_base,a1	;plax_hrast_depack,a1
		jsr	lz77

		lea.l	plax_hrast_depack,a0
		move.w	#70000/4-1,d7
		moveq.l	#0,d0
.clr:		move.l	d0,(a0)+
		dbra	d7,.clr

		lea.l	plax_vrast,a0
		lea.l	plax_vrast_depack+70000,a1
		jsr	lz77

;------------- copy overscan code
		lea.l	generic_code,a0

		move.l	#plax_code1_end,d0	;top 227 lines
		sub.l	#plax_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#227-1,d7
.code1a:	move.l	d0,d6
		lea.l	plax_code1_start,a1
.code1b:	move.w	(a1)+,(a0)+
		dbra	d6,.code1b
		dbra	d7,.code1a

		move.l	#plax_code2_end,d0	;2 midlines
		sub.l	#plax_code2_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#1-1,d7
.code2a:	move.l	d0,d6
		lea.l	plax_code2_start,a1
.code2b:	move.w	(a1)+,(a0)+
		dbra	d6,.code2b
		dbra	d7,.code2a

		move.l	#plax_code1_end,d0	;lower 44 lines (uses same code as top lines)
		sub.l	#plax_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#44-1,d7
.code3a:	move.l	d0,d6
		lea.l	plax_code1_start,a1
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

;--- VBL ----------------------------------------------------------------------------

plax_vbl_fadein:
		lea.l	$ffff8203.w,a0
		move.l	empty_adr,d0
		movep.l	d0,(a0)
		
		subq.w	#1,.wait
		bne.s	.no
		move.w	#6,.wait
		
		movem.l	plax_realpal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		clr.w	$ffff8240.w

		lea.l	plax_realpal,a0
		lea.l	plax_pal,a1
		jsr	fade

.no:
		rts
.wait:		dc.w	4


plax_vbl_fadein2:
		lea.l	$ffff8203.w,a0
		move.l	empty_adr,d0
		movep.l	d0,(a0)

		clr.w	$ffff8240.w

		lea.l	plax_hrast_depack,a0
		add.w	.pos,a0
		lea.l	plax_hrast_depack+272*2,a1
		sub.w	.pos,a1
		move.l	screen_adr_base,a2
		move.l	a2,a3
		add.l	#272*2,a3
		add.w	.pos,a2
		sub.w	.pos,a3
		
		moveq.l	#0,d0
		move.w	#126-1,d7
.clr:		move.w	(a2),(a0)
		move.w	(a3),(a1)
		lea.l	273*2(a0),a0
		lea.l	273*2(a1),a1
		lea.l	273*2(a2),a2
		lea.l	273*2(a3),a3
		dbra	d7,.clr

		addq.w	#2,.pos
		cmp.w	#273*2,.pos
		blt.s	.noclr
		clr.w	.pos
.noclr:
		rts
.pos:		dc.w	0

plax_vbl_fadeout:
		lea.l	$ffff8203.w,a0
		move.l	empty_adr,d0
		movep.l	d0,(a0)

		clr.w	$ffff8240.w

		subq.w	#1,.wait
		bne.s	.no
		move.w	#6,.wait
		
		movem.l	plax_realpal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		lea.l	plax_realpal,a0
		lea.l	plax_blackpal,a1
		jsr	fade

.no:
		rts
.wait:		dc.w	4


plax_vbl_fadeout_both:
		lea.l	$ffff8203.w,a0
		move.l	empty_adr,d0
		movep.l	d0,(a0)

		clr.w	$ffff8240.w

		lea.l	plax_hrast_depack,a0
		add.w	.pos,a0
		lea.l	plax_hrast_depack+272*2,a1
		sub.w	.pos,a1
		moveq.l	#0,d0
		move.w	#126-1,d7
.clr:		move.w	d0,(a0)
		move.w	d0,(a1)
		lea.l	273*2(a0),a0
		lea.l	273*2(a1),a1
		dbra	d7,.clr

		addq.w	#2,.pos
		cmp.w	#273*2,.pos
		blt.s	.noclr
		clr.w	.pos
.noclr:
		subq.w	#1,.wait
		bne.s	.no
		move.w	#8,.wait
		
		movem.l	plax_realpal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		lea.l	plax_realpal,a0
		lea.l	plax_blackpal,a1
		jsr	fade

.no:
		rts
.wait:		dc.w	8
.pos:		dc.w	0

;--- Main ----------------------------------------------------------------------------

plax_main_black:
		move.l	#plax_hrastblack,plax_hrast_adr

		add.l	#36,plax_vsin
		and.l	#$1fff,plax_vsin	;8192-1
		lea.l	sincos4000,a0

		move.l	plax_vsin,d0
		move.w	(a0,d0.l),d1
               	muls.w	#248,d1
		asr.l	#8,d1
		asr.l	#7,d1
		asl.l	#2,d1	;*4

		lea.l	plax_sinlistv+126*4,a0
		move.l	(a0,d1.l),d1
		lea.l	plax_hrast_depack+70000+208*63,a0
		add.l	d1,a0
		move.l	a0,plax_vrast_adr
		rts
		
plax_main:	
		add.l	#64,plax_hsin
		and.l	#$1fff,plax_hsin	;8192-1
		lea.l	sincos4000,a0

		move.l	plax_hsin,d0
		move.w	(a0,d0.l),d1
               	muls.w	#250,d1
		asr.l	#8,d1
		asr.l	#7,d1
		asl.l	#2,d1	;*4

		lea.l	plax_sinlisth+126*4,a0
		move.l	(a0,d1.l),d1
		lea.l	plax_hrast_depack+273*2*63,a0
		add.l	d1,a0
		move.l	a0,plax_hrast_adr


		add.l	#36,plax_vsin
		and.l	#$1fff,plax_vsin	;8192-1
		lea.l	sincos4000,a0

		move.l	plax_vsin,d0
		move.w	(a0,d0.l),d1
               	muls.w	#248,d1
		asr.l	#8,d1
		asr.l	#7,d1
		asl.l	#2,d1	;*4

		lea.l	plax_sinlistv+126*4,a0
		move.l	(a0,d1.l),d1
		lea.l	plax_hrast_depack+70000+208*63,a0
		add.l	d1,a0
		move.l	a0,plax_vrast_adr

		rts



;--- Timer A ------------------------------------------------------------------------------

plax_timer_a:	
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		clr.b	$fffffa19.w


		movem.l d0-a6,-(sp)
		dcb.w 	52-6,$4e71

		moveq.l	#0,d7			;1
		moveq.l	#2,d6			;1
		clr.w	$ffff8240.w		;4


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
		dcb.w 	66-19-5,$4e71	

		move.l	plax_hrast_adr,a0	;5
		lea.l	$ffff8240.w,a1		;2
		move.l	plax_vrast_adr,d0	;5
		lea.l	$ffff8203.w,a2		;2
		move.w	#227-1,d5		;2

		move.w	(a0)+,(a1)		;3
		
		jsr	generic_code		;5


		clr.w	(a1)
		move.l	empty_adr,d0
		movep.l	d0,(a2)

		movem.l (sp)+,d0-a6
		move.w	#$2300,sr
		rts


plax_code1_start:
;line 1-227
		;rept	227
		movep.l	d0,(a2)			;6
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		movem.l	d0-a7,plax_dump		;36
		movem.l	d0-a7,plax_dump		;36
		movem.l	d0-d6,plax_dump		;18
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w	20-3,$4e71		;
		move.w	(a0)+,(a1)		;3
		;endr
plax_code1_end:

plax_code2_start:
;line 228	
		movep.l	d0,(a2)			;6
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		movem.l	d0-a7,plax_dump		;36
		movem.l	d0-a7,plax_dump		;36
		movem.l	d0-d6,plax_dump		;18
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w	20-6,$4e71		;
		move.w	(a0)+,(a1)		;3
		movep.l	d0,(a2)			;3 (plus 3 on next line)
;line 229
		;3 nops from line above
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		move.b	d6,$ffff820a.w		;3
		movem.l	d0-a7,plax_dump		;36
		movem.l	d0-a7,plax_dump		;36
		movem.w	d0-a2,plax_dump		;15
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w	20-3,$4e71		;
		move.w	(a0)+,(a1)		;3
plax_code2_end:


;--- Data ---------------------------------------------------------------------------------------------
		
		section	data
plax_hsin:	dc.l	0
plax_vsin:	dc.l	0

plax_sinlisth:

q:		set	-63
		rept	125
		dc.l	q*273*2
q:		set	q+1
		endr

q:		set	-63
		rept	125
		dc.l	q*273*2
q:		set	q+1
		endr

q:		set	-63
		rept	125
		dc.l	q*273*2
q:		set	q+1
		endr

plax_sinlistv:
q:		set	-63
		rept	125
		dc.l	q*208
q:		set	q+1
		endr

q:		set	-63
		rept	125
		dc.l	q*208
q:		set	q+1
		endr

q:		set	-63
		rept	125
		dc.l	q*208
q:		set	q+1
		endr


plax_dump:	ds.l	16

plax_realpal:	dcb.w	16,$0000
plax_blackpal:	dcb.w	16,$0000
plax_hrastblack:dcb.w	273,$0000
plax_pal:
		dc.w	$0000,$0008,$0001,$0009,$0002,$088a,$0113,$099b
		dc.w	$0224,$0aac,$0335,$0bbd,$0446,$0cce,$0557,$0ddf


plax_hrast:	incbin	'plax/plax12.z77'	;lz77!
plax_hrast_adr:	dc.l	plax_hrast

plax_vrast:	incbin	'plax/plax4.z77'	;lz77!
plax_vrast_adr:	dc.l	plax_vrast+70000


		section	text
