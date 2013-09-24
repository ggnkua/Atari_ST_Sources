; green.s
;
; Fullscreen gizmo/farbrausch picture

scanline_effect:	equ	0

		section	text

;--- Init ----------------------------------------------------------------------------

green_init:	rts

;--- Runtime Init ---------------------------------------------------------------------

green_runtime_init:
		subq.w	#1,.once
		bne.w	.done

		jsr	white_pal
		jsr	clear_screens
		jsr	syncfix				;fix eventual bitplane corruption
		jsr	white_pal

		ifne	init_green
		move.w	#$0020,$ffff8240.w
		endc

		lea.l	green_gfx,a0
		lea.l	green_depack,a1
		jsr	lz77

	ifne	scanline_effect
		jsr	green_make_dispcurve
	endc
	
	ifeq	scanline_effect
		lea.l	green_displist,a0
		lea.l	green_depack+32,a1
		move.w	#273-1,d7
.displist:	move.l	a1,(a0)+
		lea.l	208(a1),a1
		dbra	d7,.displist
	endc

;------------- copy overscan code
		lea.l	generic_code,a0

		move.l	#green_code1_end,d0	;top 227 lines
		sub.l	#green_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#227-1,d7
.code1a:	move.l	d0,d6
		lea.l	green_code1_start,a1
.code1b:	move.w	(a1)+,(a0)+
		dbra	d6,.code1b
		dbra	d7,.code1a

		move.l	#green_code2_end,d0	;2 midlines
		sub.l	#green_code2_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#1-1,d7
.code2a:	move.l	d0,d6
		lea.l	green_code2_start,a1
.code2b:	move.w	(a1)+,(a0)+
		dbra	d6,.code2b
		dbra	d7,.code2a

		move.l	#green_code1_end,d0	;lower 44 lines (uses same code as top lines)
		sub.l	#green_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#44-1,d7
.code3a:	move.l	d0,d6
		lea.l	green_code1_start,a1
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

	ifne	scanline_effect
green_make_dispcurve:
		lea	green_dispcurve,a1
		
		move.w	#2048/4-1,d7		;no picture
.l1:		
		move.l	#-208,(a1)+
		dbra	d7,.l1

		lea	sincos4000+1024*2,a0	;cos
		move.w	#2048-1,d7		;fade in
.l2:
		move.w	(a0)+,d0
		neg.w	d0
		muls	#273*2,d0
		swap	d0
		add.w	#273/2,d0
		mulu	#208,d0
		move.l	d0,(a1)+
		dbra	d7,.l2
				
		move.w	#2048-1,d7		;show picture
.l3:
		move.l	d0,(a1)+
		dbra	d7,.l3
		
		move.w	#2048-1,d7		;fade out
.l4:
		move.w	d7,d0
		eor.w	#2048-1,d0
		lsl.w	#2,d0
		mulu	d0,d0
		swap	d0
		muls	#208,d0
		add.l	#208*273,d0
		move.l	d0,(a1)+
		dbra	d7,.l4
		
		rts
	endc

;--- VBL ----------------------------------------------------------------------------

green_vbl_in:
		bsr.s	green_vbl
	
		subq.w	#1,.wait
		bne.s	.no
		move.w	#3,.wait
		movem.l	green_mainpal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		
		lea.l	green_mainpal,a0
		lea.l	green_depack,a1
		jsr	component_fade
		
.no:		rts
.wait:		dc.w	1

green_vbl_out:
		bsr.s	green_vbl
	
		subq.w	#1,.wait
		bne.s	.no
		move.w	#3,.wait
		movem.l	green_mainpal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		
		lea.l	green_mainpal,a0
		lea.l	green_blackpal,a1
		jsr	component_fade
		
.no:		rts
.wait:		dc.w	1


green_vbl:
		move.l	empty_adr,d0			;set screen
		lea.l	$ffff8203.w,a0
		movep.l	d0,(a0)

		rts

;--- Main ----------------------------------------------------------------------------

green_main:	
	ifne	scanline_effect
		bsr	green_update_displist
	endc
		rts

	ifne	scanline_effect
green_update_displist:
		lea	green_dispcurve,a0
		lea	green_displist,a1
		lea	green_depack+32-208*273,a2
		move.l	a2,d2
		move.l	#208,d3

		move.l	green_pos,d6
		add.l	#4*8,green_pos
		add.l	d6,a0
		clr.l	d1
		
		move.w	#273-1,d7
.loop:
		move.l	(a0)+,d0
	;	add.l	#4*1,a0
	;	cmp.l	d0,d1
	;	beq.s	.nonewline	
	;	move.l	d0,d1
	
		add.l	d2,d0
		add.l	d3,d2
		move.l	d0,(a1)+
		dbra	d7,.loop	
		rts
		
.nonewline:
		move.l	d0,d1
		move.l	a2,(a1)+
		add.l	d3,d2
		dbra	d7,.loop	

		rts
	endc

;--- Timer A ------------------------------------------------------------------------------

green_timer_a:	
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
		dcb.w 	66-8-5,$4e71	

		lea.l	$ffff8203.w,a0		;2
		lea.l	green_displist,a1	;3
		move.l	(a1)+,d0		;3


		jsr	generic_code		;5

		move.l	empty_adr,d0
		movep.l	d0,(a0)
		
		movem.l (sp)+,d0-a6
		move.w	#$2300,sr
		rts


green_code1_start:
;line 1-227
		;rept	227
		movep.l	d0,(a0)			;6
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		movem.l	d0-a7,global_dump	;36
		movem.l	d0-a7,global_dump	;36
		movem.l	d0-d6,global_dump	;18
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w	20-3,$4e71
		move.l	(a1)+,d0		;3
		;endr
green_code1_end:


green_code2_start:

;line 228
		movep.l	d0,(a0)			;6
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		movem.l	d0-a7,global_dump	;36
		movem.l	d0-a7,global_dump	;36
		movem.l	d0-d6,global_dump	;18
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w	20-6,$4e71
		move.l	(a1)+,d0		;3
		movep.l	d0,(a0)			;6 (3 here and 3 at next line)

;line 229
		;3 nops from the above line
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		move.b	d6,$ffff820a.w		;3
		movem.l	d0-a7,global_dump	;36
		movem.l	d0-a7,global_dump	;36
		movem.w	d0-a2,global_dump	;15
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w	20-3,$4e71
		move.l	(a1)+,d0		;3
green_code2_end:



;--- Data ---------------------------------------------------------------------------------------------
		
		section	data

green_pos:		dc.l	0
green_blackpal:		dcb.w	16,$0000
green_mainpal:		dcb.w	16,$0fff

green_gfx:		incbin	'green/green.z77'	;lz77!
			even

		section	text
