; Altparty 2009 STe demo
; Fullscreen zooming scanlines
;
; linezoom.s

		section	text


;-------------- INIT
linezoom_init:	rts
		


;-------------- RUNTIME INIT
linezoom_runtime_init:
		subq.w	#1,.once
		bne.w	.done

		jsr	clear_screens
		jsr	syncfix				;fix eventual bitplane corruption
		jsr	black_pal

		ifne	init_finish
		move.w	#$0700,$ffff8240.w
		endc

		;copy static black palette
		;208 bytes between each palette to be able to use scanline datas unmodified as palette offset
		movem.l	linezoom_black,d0-d7
		move.w	#208-1,.count
.blackpal:	lea.l	linezoom_fade,a0
		add.l	.shadepos,a0
		add.l	#208,.shadepos
		movem.l	d0-d7,(a0)
		subq.w	#1,.count
		bpl.s	.blackpal

		;calculate black -> palette shades
		move.w	#48-1,.count
.pal2:		lea.l	linezoom_black,a0
		lea.l	linezoom_pal0,a1
		bsr.w	component_fade
		lea.l	linezoom_fade,a0
		add.l	.shadepos,a0
		add.l	#208,.shadepos
		movem.l	linezoom_black,d0-d7
		movem.l	d0-d7,(a0)
		movem.l	d0-d7,208(a0)
		subq.w	#1,.count
		bpl.s	.pal2

		;copy static standard (non shaded) palette
		movem.l	linezoom_pal0,d0-d7
		move.w	#112-1,.count
.stdpal:	lea.l	linezoom_fade,a0
		add.l	.shadepos,a0
		add.l	#208,.shadepos
		movem.l	d0-d7,(a0)
		subq.w	#1,.count
		bpl.s	.stdpal


		;calculate palette -> white shades (double values = 96 entries)
		move.w	#48-1,.count
.pal1:		lea.l	linezoom_black,a0
		lea.l	linezoom_pal1,a1
		bsr.w	component_fade
		lea.l	linezoom_fade,a0
		add.l	.shadepos,a0
		add.l	#208*2,.shadepos
		movem.l	linezoom_black,d0-d7
		movem.l	d0-d7,(a0)
		movem.l	d0-d7,208(a0)
		subq.w	#1,.count
		bpl.s	.pal1



		lea.l	linezoom_lz77,a0		;depack zoom datas
		lea.l	linezoom_data,a1
		bsr.w	lz77

.sinl:		bsr.w	linezoom_singen
		subq.w	#1,.singen
		bpl.s	.sinl


		lea.l	generic_code,a0			;copy overscan code
		move.l	#linezoom_code1_end,d0		;top 227 lines
		sub.l	#linezoom_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#227-1,d7
.code1a:	move.l	d0,d6
		lea.l	linezoom_code1_start,a1
.code1b:	move.w	(a1)+,(a0)+
		dbra	d6,.code1b
		dbra	d7,.code1a

		move.l	#linezoom_code2_end,d0		;2 midlines
		sub.l	#linezoom_code2_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#1-1,d7
.code2a:	move.l	d0,d6
		lea.l	linezoom_code2_start,a1
.code2b:	move.w	(a1)+,(a0)+
		dbra	d6,.code2b
		dbra	d7,.code2a

		move.l	#linezoom_code1_end,d0		;lower 44 lines (uses same code as top lines)
		sub.l	#linezoom_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#44-1,d7
.code3a:	move.l	d0,d6
		lea.l	linezoom_code1_start,a1
.code3b:	move.w	(a1)+,(a0)+
		dbra	d6,.code3b
		dbra	d7,.code3a
		move.w	dummy,(a0)+	;rts


		ifne	init_finish
		move.w	#$0070,$ffff8240.w
		endc


.done:		rts
.once:		dc.w	1
.singen:	dc.w	600
.count:		dc.w	0
.count2:	dc.w	0
.shadepos:	dc.l	0

;-------------- VBL
linezoom_vbl:
		move.l	empty_adr,d0
		lea.l	$ffff8203.w,a0
		movep.l	d0,0(a0)

		bsr.w	linezoom_singen

		;set first palette
		lea.l	linezoom_zoomlist,a3
		add.w	linezoom_listofs,a3
		lea.l	linezoom_zoomlist2+273*4,a4
		add.w	linezoom_listofs,a4
		move.l	linezoom_fadeadr,a2
		add.l	(a3)+,a2
		add.l	-(a4),a2
		movem.l	16(a2),d0-d3
		movem.l	d0-d3,$ffff8250.w
		rts

linezoom_fadein:
		bsr.w	linezoom_vbl

		clr.w	$ffff8240.w
		
		cmp.l	#255*208,linezoom_fadeofs
		bge.s	.no
		add.l	#208,linezoom_fadeofs

.no:
		lea.l	linezoom_fade+208*104,a0
		add.l	linezoom_fadeofs,a0
		move.l	a0,linezoom_fadeadr
		rts

linezoom_fadein2:
		bsr.w	linezoom_vbl

		subq.w	#1,.wait
		bne.s	.no
		move.w	#2,.wait
		
		movem.l	linezoom_white,d0-d3
		movem.l	d0-d3,$ffff8240.w

		lea.l	linezoom_white,a0
		lea.l	linezoom_pal0,a1
		jsr	component_fade

.no:		rts
.wait:		dc.w	2


linezoom_fadeout:
		bsr.w	linezoom_vbl
		
		tst.l	linezoom_fadeofs
		beq.s	.no
		sub.l	#208*2,linezoom_fadeofs

.no:		lea.l	linezoom_fade+208*104,a0
		add.l	linezoom_fadeofs,a0
		move.l	a0,linezoom_fadeadr
		rts

linezoom_fadeout2:
		bsr.w	linezoom_vbl

		subq.w	#1,.wait
		bne.s	.no
		move.w	#1,.wait
		
		movem.l	linezoom_white,d0-d3
		movem.l	d0-d3,$ffff8240.w

		lea.l	linezoom_white,a0
		lea.l	linezoom_black2,a1
		jsr	component_fade

.no:		rts
.wait:		dc.w	1


linezoom_singen:
		;first sinlist
		add.l   #34,.sin1
		and.l   #$1fff,.sin1
		lea.l	sincos4000,a0
		move.l  .sin1,d0
		move.w  (a0,d0.l),d1
		muls.w  #103,d1
		asr.l   #8,d1
		asr.l   #7,d1
		muls.w	#208,d1
		lea.l	linezoom_zoomlist,a0
		add.w	linezoom_listofs,a0
		move.l	d1,(a0)
		move.l	d1,300*4(a0)

		;second sinlist
		add.l   #70,.sin2
		and.l   #$1fff,.sin2
		lea.l	sincos4000,a0
		move.l  .sin2,d0
		move.w  (a0,d0.l),d2
		muls.w  #103,d2
		asr.l   #8,d2
		asr.l   #7,d2
		muls.w	#208,d2
		lea.l	linezoom_zoomlist2,a0
		add.w	linezoom_listofs,a0
		move.l	d2,(a0)
		move.l	d2,300*4(a0)
		
		
		
		cmp.w	#4*299,linezoom_listofs
		blt.s	.add
		clr.w	linezoom_listofs
		bra.s	.done
.add:		addq.w	#4,linezoom_listofs
.done:

		rts
.sin1:		dc.l	0
.sin2:		dc.l	0



;-------------- MAIN
linezoom_main:
		rts


;-------------- TIMER A
linezoom_timer_a:	
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		clr.b	$fffffa19.w


		movem.l d0-a6,-(sp)
		dcb.w 	52,$4e71



		move.b	#0,$ffff820a.w			;remove top border
		dcb.w 	6,$4e71
		lea.l	$ffff8209.w,a0			;2
		moveq.l	#127,d1				;1 = 9 nops wait for top border zap
		move.b	#2,$ffff820a.w


.sync:		tst.b	(a0)				;hardsync
		beq.s	.sync				;
		move.b	(a0),d2				;
		sub.b	d2,d1				;
		lsr.l	d1,d1				;


		dcb.w 	66-36,$4e71	

		moveq.l	#2,d7				;1
		lea.l	$ffff8203.w,a6			;2
		lea.l	linezoom_data+208*104,a5	;3
		lea.l	linezoom_zoomlist,a3		;3
		add.w	linezoom_listofs,a3		;5
		lea.l	linezoom_zoomlist2+273*4,a4	;3
		add.w	linezoom_listofs,a4		;5
		move.l	a5,d0				;1
		add.l	(a3)+,d0			;4
		add.l	-(a4),d0			;4

		jsr	generic_code			;5

		movem.l (sp)+,d0-a6
		move.w	#$2300,sr
		rts


linezoom_code1_start:
		movep.l	d0,0(a6)			;6
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		dcb.w	90-41,$4e71
		move.l	a5,d0				;1
		add.l	(a3),d0				;4
		add.l	(a4),d0				;4
		move.l	linezoom_fadeadr,a2		;5
		add.l	(a3)+,a2			;4
		add.l	-(a4),a2			;4
		movem.l	(a2),d1-d6/a0-a1		;19
		
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	20-11,$4e71
		movem.l	d5-d6/a0-a1,$ffff8250.w		;11

linezoom_code1_end:

linezoom_code2_start:
		movep.l	d0,0(a6)			;6
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		dcb.w	90-41,$4e71
		move.l	a5,d0				;1
		add.l	(a3),d0				;4
		add.l	(a4),d0				;4
		move.l	linezoom_fadeadr,a2		;5
		add.l	(a3)+,a2			;4
		add.l	-(a4),a2			;4
		movem.l	(a2),d1-d6/a0-a1		;19
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	17-11,$4e71
		movem.l	d5-d6/a0-a1,$ffff8250.w		;11
		movep.l	d0,0(a6)			;3+ 3 on next line
;line 229	;3 nops from previous line
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	87-41,$4e71
		move.l	a5,d0				;1
		add.l	(a3),d0				;4
		add.l	(a4),d0				;4
		move.l	linezoom_fadeadr,a2		;5
		add.l	(a3)+,a2			;4
		add.l	-(a4),a2			;4
		movem.l	(a2),d1-d6/a0-a1		;19
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	20-11,$4e71
		movem.l	d5-d6/a0-a1,$ffff8250.w		;11
linezoom_code2_end:




		section	data

linezoom_fadeofs:	dc.l	0
linezoom_fadeadr:	dc.l	linezoom_fade+208*104
linezoom_black:		dcb.w	16,$0000
linezoom_black2:	dcb.w	16,$0000
linezoom_white:		dc.w	$0000
			dcb.w	15,$0fff
linezoom_constant:	dc.l	0
linezoom_listofs:	dc.w	0
linezoom_zoomlist:	dcb.l	600,0
linezoom_zoomlist2:	dcb.l	600,0

linezoom_lz77:		incbin	'linezoom/linezoom.z77'
			even

linezoom_pal0:		dc.w	$0000,$0211,$0322,$0433,$0544,$0655,$0766,$0777
			dc.w	$0012,$0123,$0234,$0345,$0456,$0567,$0677,$0000

linezoom_pal1:		dc.w	0
			dcb.w	15,$0fff


		section	bss		
		
		section	text
