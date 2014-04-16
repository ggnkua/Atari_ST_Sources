; Altparty 2009 STe demo
; Parallax fullscreen (credits screen?)
;
; parall.s

		section	text


;-------------- INIT
parall_init:	rts
		


;-------------- RUNTIME INIT
parall_runtime_init:
		subq.w	#1,.once
		bne.w	.done

		ifne	init_finish
		move.w	#$0700,$ffff8240.w
		endc

		jsr	clear_screens
		jsr	syncfix				;fix eventual bitplane corruption
		jsr	black_pal

		;init plotsofs
		bsr.w	parall_init_plotofs

		;depack layer 1
		lea.l	parall_layer1_lz77,a0
		move.l	screen_adr,a1
		bsr.w	lz77

		;depack layer 2
		lea.l	parall_layer2_lz77,a0
		move.l	screen_adr2,a1
		bsr.w	lz77

		;duplicate layer 1 and 2 for seamless loop
		move.l	screen_adr,a0
		move.l	screen_adr2,a1
		move.w	#416*140/2/4-1,d7
.copy:
		move.l	(a0),d0
		move.l	d0,208*140(a0)
		addq.l	#4,a0

		move.l	(a1),d0
		move.l	d0,208*140(a1)
		addq.l	#4,a1
		
		dbra	d7,.copy


		;depack text layer
		lea.l	parall_text_ice,a0		
		lea.l	parall_text,a1
		bsr.w	ice

		;copy overscan code
		lea.l	generic_code,a0
		move.l	#parall_code1_end,d0		;top 227 lines
		sub.l	#parall_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#227-1,d7
.code1a:	move.l	d0,d6
		lea.l	parall_code1_start,a1
.code1b:	move.w	(a1)+,(a0)+
		dbra	d6,.code1b
		dbra	d7,.code1a

		move.l	#parall_code2_end,d0		;2 midlines
		sub.l	#parall_code2_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#1-1,d7
.code2a:	move.l	d0,d6
		lea.l	parall_code2_start,a1
.code2b:	move.w	(a1)+,(a0)+
		dbra	d6,.code2b
		dbra	d7,.code2a

		move.l	#parall_code1_end,d0		;lower 44 lines (uses same code as top lines)
		sub.l	#parall_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#44-1,d7
.code3a:	move.l	d0,d6
		lea.l	parall_code1_start,a1
.code3b:	move.w	(a1)+,(a0)+
		dbra	d6,.code3b
		dbra	d7,.code3a
		move.w	dummy,(a0)+	;rts


		ifne	init_finish
		move.w	#$0070,$ffff8240.w
		endc

.done:		rts
.once:		dc.w	1

;-------------- VBL
parall_vbl_in:
		movem.l	parall_black1,d0-d7
		movem.l	d0-d7,$ffff8240.w
		bsr.s	parall_vbl
		subq.w	#1,.wait
		bne.s	.no
		move.w	#4,.wait
		lea.l	parall_black1,a0
		lea.l	parall_pal,a1
		jsr	component_fade
		clr.l	parall_pos3
.no:		rts
.wait:		dc.w	4
parall_vbl_out:	
		movem.l	parall_black1,d0-d7
		movem.l	d0-d7,$ffff8240.w
		bsr.s	parall_vbl
		subq.w	#1,.wait
		bne.s	.no
		move.w	#2,.wait
		lea.l	parall_black1,a0
		lea.l	parall_black2,a1
		jsr	component_fade
.no:		rts
.wait:		dc.w	2
parall_vbl:
		move.l	empty_adr,d0
		lea.l	$ffff8203.w,a0
		movep.l	d0,0(a0)


		cmp.l	#208*139,parall_pos1
		blt.s	.add1
		clr.l	parall_pos1
		bra.s	.done1
.add1:		add.l	#208,parall_pos1
.done1:
		not.w	.var
		bne.s	.done2
		cmp.l	#208*139,parall_pos2
		blt.s	.add2
		clr.l	parall_pos2
		bra.s	.done2
.add2:		add.l	#208,parall_pos2
.done2:
;		subq.w	#1,.var2
;		bne.s	.done3
;		move.w	#3,.var2
		cmp.l	#44*749*3,parall_pos3
		blt.s	.add3
		clr.l	parall_pos3
		bra.s	.done3
.add3:		add.l	#44,parall_pos3
.done3:


		move.l	screen_adr,d0
		move.l	screen_adr2,screen_adr
		move.l	d0,screen_adr

		rts
.var:		dc.w	0
.var2:		dc.w	3
parall_pos1:	dc.l	0
parall_pos2:	dc.l	0
parall_pos3:	dc.l	0

;-------------- MAIN
parall_main_nerve:
		rept	18
		lea.l	parall_layer3+44*190*3,a0
		lea.l	parall_text+44*288*4,a1
		bsr.w	parall_logoplot
		endr
		rts

parall_main_gizmofr:
		rept	18
		lea.l	parall_layer3+44*290*3,a0
		lea.l	parall_text+44*288*1,a1
		bsr.w	parall_logoplot
		endr
		rts

parall_main_505:
		rept	18
		lea.l	parall_layer3+44*390*3,a0
		lea.l	parall_text+44*288*0,a1
		bsr.w	parall_logoplot
		endr
		rts


parall_main_gizmo:
		rept	18
		lea.l	parall_layer3+44*490*3,a0
		lea.l	parall_text+44*288*2,a1
		bsr.w	parall_logoplot
		endr
		rts

parall_main_evil:
		rept	18
		lea.l	parall_layer3+44*590*3,a0
		lea.l	parall_text+44*288*3,a1
		bsr.w	parall_logoplot
		endr
		rts




parall_logoplot:
;in: a0 = layer3 address
;    a1 = logo address
; logo size 384*96 (48*12 8x8 squares)

		cmp.l	.old,a1
		beq.s	.go
		move.l	a1,.old
		clr.w	.pos
.go:

		cmp.w	#1584*2,.pos
		blt.s	.noreset
		clr.w	.pos
.noreset:	lea.l	parall_plotofs,a2
		add.w	.pos,a2
		move.w	(a2),d0
		add.w	d0,a0
		add.w	d0,a1

q:		set	0
		rept	8
		move.b	q(a1),q(a0)
q:		set	q+44
		endr

		addq.w	#2,.pos
		rts

.old:		dc.l	0
.pos:		dc.w	0

parall_init_plotofs:
		lea.l	parall_plotofs,a0
		moveq.l	#0,d0
		move.w	#44-1,d7
.l1:		move.w	#36-1,d6
		move.l	d0,d1
.l2:
		move.w	d1,(a0)+
		add.w	#44*8,d1

		dbra	d6,.l2
		addq.w	#1,d0
		dbra	d7,.l1
		rts


;-------------- TIMER A
parall_timer_a:	
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


		dcb.w 	66-42,$4e71	


		lea.l	$ffff8203.w,a6			;2
		move.l	screen_adr,d0			;5
		move.l	screen_adr2,d1			;5
		add.l	parall_pos1,d0			;5
		add.l	parall_pos2,d1			;5
		moveq.l	#2,d7				;1

		lea.l	parall_layer3,a5		;3 text layer
		add.l	parall_pos3,a5			;5
		move.l	d0,a3				;1
		move.l	d1,a4				;1
		lea.l	16+6(a3),a3			;2
		lea.l	16+6(a4),a4			;2

		jsr	generic_code			;5

		movem.l (sp)+,d0-a6
		move.w	#$2300,sr
		rts


parall_code1_start:
		movep.l	d0,0(a6)		;6
		move.b	d7,$ffff8260.w		;3
		move.w	d7,$ffff8260.w		;3
		dcb.w	90-87,$4e71
		move.w	(a5)+,(a3)		;3
		move.w	(a5)+,8*1(a3)		;4
		move.w	(a5)+,8*2(a3)		;4
		move.w	(a5)+,8*3(a3)		;4
		move.w	(a5)+,8*4(a3)		;4
		move.w	(a5)+,8*5(a3)		;4
		move.w	(a5)+,8*6(a3)		;4
		move.w	(a5)+,8*7(a3)		;4
		move.w	(a5)+,8*8(a3)		;4
		move.w	(a5)+,8*9(a3)		;4
		move.w	(a5)+,8*10(a3)		;4
		move.w	(a5)+,8*11(a3)		;4
		move.w	(a5)+,8*12(a3)		;4
		move.w	(a5)+,8*13(a3)		;4
		move.w	(a5)+,8*14(a3)		;4
		move.w	(a5)+,8*15(a3)		;4
		move.w	(a5)+,8*16(a3)		;4
		move.w	(a5)+,8*17(a3)		;4
		move.w	(a5)+,8*18(a3)		;4
		move.w	(a5)+,8*19(a3)		;4
		move.w	(a5)+,8*20(a3)		;4
		move.w	(a5)+,8*21(a3)		;4
		move.w	d7,$ffff820a.w		;3
		move.b	d7,$ffff820a.w		;3
		dcb.w	6,$4e71
		lea.l	88(a5),a5		;2
		lea.l	208(a3),a3		;2
		move.l	a3,a2			;1
		move.l	a4,a3			;1
		move.l	a2,a4			;1
		add.l	#208,d0			;4
		move.l	d0,d2			;1
		move.l	d1,d0			;1
		move.l	d2,d1			;1
parall_code1_end:

parall_code2_start:
		movep.l	d0,0(a6)		;6
		move.b	d7,$ffff8260.w		;3
		move.w	d7,$ffff8260.w		;3
		move.l	d0,d2			;1
		move.l	d1,d0			;1
		move.l	d2,d1			;1
		add.l	#208,d1			;4
		move.w	(a5)+,(a3)		;3
		move.w	(a5)+,8*1(a3)		;4
		move.w	(a5)+,8*2(a3)		;4
		move.w	(a5)+,8*3(a3)		;4
		move.w	(a5)+,8*4(a3)		;4
		move.w	(a5)+,8*5(a3)		;4
		move.w	(a5)+,8*6(a3)		;4
		move.w	(a5)+,8*7(a3)		;4
		move.w	(a5)+,8*8(a3)		;4
		move.w	(a5)+,8*9(a3)		;4
		move.w	(a5)+,8*10(a3)		;4
		move.w	(a5)+,8*11(a3)		;4
		move.w	(a5)+,8*12(a3)		;4
		move.w	(a5)+,8*13(a3)		;4
		move.w	(a5)+,8*14(a3)		;4
		move.w	(a5)+,8*15(a3)		;4
		move.w	(a5)+,8*16(a3)		;4
		move.w	(a5)+,8*17(a3)		;4
		move.w	(a5)+,8*18(a3)		;4
		move.w	(a5)+,8*19(a3)		;4
		move.w	(a5)+,8*20(a3)		;4
		move.w	d7,$ffff820a.w		;3
		move.b	d7,$ffff820a.w		;3
		move.w	(a5)+,8*21(a3)		;4
		dcb.w	6,$4e71
		lea.l	88(a5),a5		;2
		lea.l	208(a3),a3		;2
		move.l	a3,a2			;1
		move.l	a4,a3			;1
		move.l	a2,a4			;1
		movep.l	d0,0(a6)		;3+ 3 on next line
;line 229	;3 nops from previous line
		move.w	d7,$ffff820a.w		;3
		move.b	d7,$ffff8260.w		;3
		move.w	d7,$ffff8260.w		;3
		move.b	d7,$ffff820a.w		;3
		move.w	(a5)+,(a3)		;3
		move.w	(a5)+,8*1(a3)		;4
		move.w	(a5)+,8*2(a3)		;4
		move.w	(a5)+,8*3(a3)		;4
		move.w	(a5)+,8*4(a3)		;4
		move.w	(a5)+,8*5(a3)		;4
		move.w	(a5)+,8*6(a3)		;4
		move.w	(a5)+,8*7(a3)		;4
		move.w	(a5)+,8*8(a3)		;4
		move.w	(a5)+,8*9(a3)		;4
		move.w	(a5)+,8*10(a3)		;4
		move.w	(a5)+,8*11(a3)		;4
		move.w	(a5)+,8*12(a3)		;4
		move.w	(a5)+,8*13(a3)		;4
		move.w	(a5)+,8*14(a3)		;4
		move.w	(a5)+,8*15(a3)		;4
		move.w	(a5)+,8*16(a3)		;4
		move.w	(a5)+,8*17(a3)		;4
		move.w	(a5)+,8*18(a3)		;4
		move.w	(a5)+,8*19(a3)		;4
		move.w	(a5)+,8*20(a3)		;4
		move.w	(a5)+,8*21(a3)		;4
		move.w	d7,$ffff820a.w		;3
		move.b	d7,$ffff820a.w		;3
		dcb.w	6,$4e71
		lea.l	88(a5),a5		;2
		lea.l	208(a3),a3		;2
		move.l	a3,a2			;1
		move.l	a4,a3			;1
		move.l	a2,a4			;1
		add.l	#208,d0			;4
		move.l	d0,d2			;1
		move.l	d1,d0			;1
		move.l	d2,d1			;1
parall_code2_end:




		section	data
		
parall_black1:		dcb.w	16,$0000
parall_black2:		dcb.w	16,$0000
parall_pal:		dc.w	$0000,$0001,$0012,$0123,$0234,$0345,$0456,$0567
			dc.w	$0234,$0345,$0456,$0567,$067f,$07ff,$0fff,$0fff
		
parall_layer1_lz77:	incbin	'parall/clouds16.z77'
			even

parall_layer2_lz77:	incbin	'parall/thorns16.z77'
			even

parall_text_ice:	incbin	'parall/text.ice'
			even

		section	text
