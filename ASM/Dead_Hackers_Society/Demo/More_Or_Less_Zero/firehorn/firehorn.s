; firehorn.s
;
; Fullscreen picture by gizmo / farbrausch

		section	text

;--- Init ----------------------------------------------------------------------------

firehorn_init:	move.l	screen_adr_base,firehorn_scradr
		rts

;--- Runtime Init ---------------------------------------------------------------------

firehorn_runtime_init:
		subq.w	#1,.once
		bne.w	.done

		jsr	clear_screens
		jsr	syncfix				;fix eventual bitplane corruption
		jsr	black_pal

		lea.l	firehorn_gfx,a0
		lea.l	firehorn_depack,a1
		jsr	lz77

		lea.l	firehorn_depack+32,a0
		move.l	screen_adr_base,a1
		lea.l	104(a1),a1
		move.w	#273-1,d7
.y:		move.w	#208/4-1,d6
.x:		move.l	(a0)+,(a1)+
		dbra	d6,.x
		lea.l	22(a0),a0
		lea.l	208(a1),a1
		dbra	d7,.y

;------------- copy overscan code
		lea.l	generic_code,a0

		move.l	#firehorn_code1_end,d0	;top 227 lines
		sub.l	#firehorn_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#227-1,d7
.code1a:	move.l	d0,d6
		lea.l	firehorn_code1_start,a1
.code1b:	move.w	(a1)+,(a0)+
		dbra	d6,.code1b
		dbra	d7,.code1a

		move.l	#firehorn_code2_end,d0	;2 midlines
		sub.l	#firehorn_code2_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#1-1,d7
.code2a:	move.l	d0,d6
		lea.l	firehorn_code2_start,a1
.code2b:	move.w	(a1)+,(a0)+
		dbra	d6,.code2b
		dbra	d7,.code2a

		move.l	#firehorn_code1_end,d0	;lower 44 lines (uses same code as top lines)
		sub.l	#firehorn_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#44-1,d7
.code3a:	move.l	d0,d6
		lea.l	firehorn_code1_start,a1
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


firehorn_runtime_exit:
		subq.w	#1,.once
		bne.s	.done

		clr.b	$ffff8265.w

.done:		rts
.once:		dc.w	1

;--- VBL ----------------------------------------------------------------------------

firehorn_vbl_in:	
		lea.l	$ffff8203.w,a0
		move.l	empty_adr,d0
		movep.l	d0,(a0)

		movem.l	firehorn_setpal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		subq.w	#1,.wait
		bne.s	.nofade
		move.w	#4,.wait
		lea.l	firehorn_setpal,a0
		lea.l	firehorn_depack,a1
		jsr	component_fade
.nofade:

		lea.l	sincos4000,a2
		add.l	#32,firehorn_sin
		and.l	#$1fff,firehorn_sin
		move.l	firehorn_sin,d0
		move.w	(a2,d0.l),d1
		move.w	.sinamp,d0
               	muls.w	d0,d1
		asr.l	#8,d1
		asr.l	#7,d1
		add.l	#208,d1
		move.l	d1,.pos

		tst.w	.sinamp
		beq.s	.done
		subq.w	#2,.sinamp
.done:

		; hardscroll 
		move.l	.pos,d0				
		move.l	d0,d1		
		and.l	#$0000000f,d1			;hscrolreg
		and.l	#$fffffff0,d0			;screenadr ofs
		lsr.l	#1,d0						
		move.b	d1,firehorn_hscrol
		move.l	screen_adr_base,d2
		add.l	d0,d2
		move.l	d2,firehorn_scradr

		rts

.pos:		dc.l	0
.sinamp:	dc.w	416
.wait:		dc.w	3


firehorn_vbl_out:
		lea.l	$ffff8203.w,a0
		move.l	empty_adr,d0
		movep.l	d0,(a0)

		movem.l	firehorn_setpal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		subq.w	#1,.wait
		bne.s	.nofade
		move.w	#3,.wait
		lea.l	firehorn_setpal,a0
		lea.l	firehorn_black,a1
		jsr	component_fade
.nofade:


		lea.l	sincos4000,a2
		add.l	#32,firehorn_sin
		and.l	#$1fff,firehorn_sin
		move.l	firehorn_sin,d0
		move.w	(a2,d0.l),d1
		move.w	.sinamp,d0
               	muls.w	d0,d1
		asr.l	#8,d1
		asr.l	#7,d1
		add.l	#208,d1
		move.l	d1,.pos

		cmp.w	#416,.sinamp
		beq.s	.done
		addq.w	#1,.sinamp
.done:

		; hardscroll 
		move.l	.pos,d0				
		move.l	d0,d1		
		and.l	#$0000000f,d1			;hscrolreg
		and.l	#$fffffff0,d0			;screenadr ofs
		lsr.l	#1,d0						
		move.b	d1,firehorn_hscrol
		move.l	screen_adr_base,d2
		add.l	d0,d2
		move.l	d2,firehorn_scradr

		rts

.pos:		dc.l	0
.sinamp:	dc.w	0
.wait:		dc.w	3


;--- Main ----------------------------------------------------------------------------

firehorn_main:	rts


;--- Timer A ------------------------------------------------------------------------------

firehorn_timer_a:
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
		dcb.w 	66-19-5,$4e71	
		lea.l	$ffff8203.w,a6		;2
		move.l	firehorn_scradr,d0	;5
		move.b	firehorn_hscrol,$ffff8265.w	;6
		movep.l	d0,(a6)			;6

		jsr	generic_code		;5

		move.l	empty_adr,d0
		movep.l	d0,(a6)
		
		clr.b	$ffff8265.w

		movem.l (sp)+,d0-a6
		move.w	#$2300,sr
		rts

firehorn_code1_start:
;line 1-227
		;rept	227
		movep.l	d0,(a6)			;6
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		movem.l	d0-a7,global_dump	;36
		movem.l	d0-a7,global_dump	;36
		dcb.w	18-4,$4e71
		add.l	#416,d0			;4
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w	20,$4e71		;20
		;endr
firehorn_code1_end:


firehorn_code2_start:
;line 228
		movep.l	d0,(a6)			;6
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		movem.l	d0-a7,global_dump	;36
		movem.l	d0-a7,global_dump	;36
		dcb.w	18-4,$4e71
		add.l	#416,d0			;4
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w	20-3,$4e71		;20
		movep.l	d0,(a6)			;3+ 3 on next line

;line 229
		;3 nops from previous line
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		move.b	d6,$ffff820a.w		;3
		movem.l	d0-a7,global_dump	;36
		movem.l	d0-a7,global_dump	;36
		dcb.w	15-4,$4e71
		add.l	#416,d0			;4
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w	20,$4e71		;20

firehorn_code2_end:

;--- Data ---------------------------------------------------------------------------------------------
		
		section	data
firehorn_scradr:	dc.l	0
firehorn_hscrol:	dc.w	0
firehorn_sin:		dc.l	0

firehorn_black:		dcb.w	16,$0fff
firehorn_setpal:	dcb.w	16,$0000	;$0ffd
firehorn_gfx:		incbin	'firehorn/firehorn.z77'	;lz77!
			even


		section	text
