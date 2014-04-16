; Atari ST/e synclock demosystem
; June 8, 2008
;
; fullofs.s
;
; 8x5 mirroed chunky effect 1vbl fullscreen


		section	text

;--- Init ----------------------------------------------------------------------------

fullofs_init:
		

		rts


;--- Runtime Init ---------------------------------------------------------------------

fullofs_runtime_init:	;needs 200vbl
		subq.w	#1,.once
		bne.w	.done

		jsr	black_pal
		jsr	clear_screens
		jsr	syncfix				;fix eventual bitplane corruption
		jsr	black_pal

		lea.l	fullofs_txt,a0
		lea.l	fullofs_txt_depacked,a1
		jsr	lz77

		lea.l	fullofs_txt_depacked,a0
		move.l	a0,a1
		add.l	#256*256,a1
		move.w	#256*256-1,d7
.txtfix:	move.b	(a0),d0
		lsl.b	#4,d0
		or.b	4(a0),d0
		move.b	d0,(a0)+
		move.b	d0,(a1)+
		dbra	d7,.txtfix

		jsr	init_c2p



		move.l	screen_adr,d0			;generate quadline address list
		lea.l	fullofs_adrs,a0
		move.w	#28-1,d7
.generate:	move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		add.l	#208,d0
		dbra	d7,.generate
		sub.l	#208*2,d0
		move.w	#28-1,d7
.generate2:	move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		sub.l	#208,d0
		dbra	d7,.generate2
		add.l	#208,d0
		move.l	d0,(a0)+
		move.l	d0,(a0)+

		lea.l	fullofs_ofs,a0			;remove least significant bit from ofs
		lea.l	fullofs_ofs2,a1
		lea.l	fullofs_ofs3,a2
		lea.l	fullofs_ofs4,a3
		move.w	#2912/2-1,d7
.clrofs:	move.w	(a0),d0
		bclr	#0,d0
		move.w	d0,(a0)+
		move.w	(a1),d0
		bclr	#0,d0
		move.w	d0,(a1)+
		move.w	(a2),d0
		bclr	#0,d0
		move.w	d0,(a2)+
		move.w	(a3),d0
		bclr	#0,d0
		move.w	d0,(a3)+
		dbra	d7,.clrofs


;------------- copy overscan code
		lea.l	generic_code,a0

		move.l	#fullofs_code1_end,d0	;top 226 lines
		sub.l	#fullofs_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#113-1,d7
.code1a:	move.l	d0,d6
		lea.l	fullofs_code1_start,a1
.code1b:	move.w	(a1)+,(a0)+
		dbra	d6,.code1b
		dbra	d7,.code1a

		move.l	#fullofs_code2_end,d0	;3 midlines
		sub.l	#fullofs_code2_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#1-1,d7
.code2a:	move.l	d0,d6
		lea.l	fullofs_code2_start,a1
.code2b:	move.w	(a1)+,(a0)+
		dbra	d6,.code2b
		dbra	d7,.code2a

		move.l	#fullofs_code1_end,d0	;lower 44 lines (uses same code as top lines)
		sub.l	#fullofs_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#22-1,d7
.code3a:	move.l	d0,d6
		lea.l	fullofs_code1_start,a1
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

fullofs_vbl_out:
		move.l	empty_adr,d0		;set screen
		lea.l	$ffff8203.w,a0
		movep.l	d0,(a0)

		movem.l	fullofs_mainpal1,d0-d7
		movem.l	d0-d7,$ffff8240.w
		lea.l	fullofs_mainpal1,a0
		lea.l	fullofs_blackpal,a1
		jsr	component_fade

		add.l	#2,fullofs_pos
		and.l	#$ffff,fullofs_pos

		lea.l	fullofs_txt_depacked+127*256+128,a0
		add.l	fullofs_pos,a0
		move.l	a0,fullofs_txtadr

		move.l	#fullofs_ofs,fullofs_ofs_adr

		rts


fullofs_vbl1:
		move.l	empty_adr,d0		;set screen
		lea.l	$ffff8203.w,a0
		movep.l	d0,(a0)

		movem.l	fullofs_mainpal1,d0-d7
		movem.l	d0-d7,$ffff8240.w
		lea.l	fullofs_mainpal1,a0
		lea.l	fullofs_pal1,a1
		jsr	component_fade

		add.l	#2,fullofs_pos
		and.l	#$ffff,fullofs_pos

		lea.l	fullofs_txt_depacked+127*256+128,a0
		add.l	fullofs_pos,a0
		move.l	a0,fullofs_txtadr

		move.l	#fullofs_ofs,fullofs_ofs_adr

		rts

fullofs_vbl2:
		move.l	empty_adr,d0		;set screen
		lea.l	$ffff8203.w,a0
		movep.l	d0,(a0)
		
		movem.l	fullofs_mainpal2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		lea.l	fullofs_mainpal2,a0
		lea.l	fullofs_pal2,a1
		jsr	component_fade

		add.l	#256,fullofs_pos2
		and.l	#$ffff,fullofs_pos2

		lea.l	fullofs_txt_depacked+127*256+128,a0
		add.l	fullofs_pos2,a0
		move.l	a0,fullofs_txtadr

		move.l	#fullofs_ofs2,fullofs_ofs_adr

		rts

fullofs_vbl3:
		move.l	empty_adr,d0		;set screen
		lea.l	$ffff8203.w,a0
		movep.l	d0,(a0)
		
		movem.l	fullofs_mainpal3,d0-d7
		movem.l	d0-d7,$ffff8240.w
		lea.l	fullofs_mainpal3,a0
		lea.l	fullofs_pal3,a1
		jsr	component_fade

		add.l	#256,fullofs_pos3
		and.l	#$ffff,fullofs_pos3

		lea.l	fullofs_txt_depacked+127*256+128,a0
		add.l	fullofs_pos3,a0
		move.l	a0,fullofs_txtadr

		move.l	#fullofs_ofs3,fullofs_ofs_adr

		rts

fullofs_vbl4:
		move.l	empty_adr,d0		;set screen
		lea.l	$ffff8203.w,a0
		movep.l	d0,(a0)
		
		movem.l	fullofs_mainpal4,d0-d7
		movem.l	d0-d7,$ffff8240.w
		lea.l	fullofs_mainpal4,a0
		lea.l	fullofs_pal4,a1
		jsr	component_fade

		add.l	#256,fullofs_pos4
		and.l	#$ffff,fullofs_pos4

		lea.l	fullofs_txt_depacked+127*256,a0
		add.l	fullofs_pos4,a0
		move.l	a0,fullofs_txtadr

		move.l	#fullofs_ofs4,fullofs_ofs_adr

		rts


;--- Main ----------------------------------------------------------------------------

fullofs_main:	
		move.l	#fullofs_adrs,fullofs_adrs_adr
		move.l	screen_adr,fullofs_screenadr

		; fillup chunky code for the few pixels that didn't fit
		; inside the overscan lines
		move.l	fullofs_screenadr,a0
		lea.l	c2ptable,a1
		move.l	fullofs_ofs_adr,a2
		move.l	fullofs_txtadr,a3
		move.w	#47-1,d7
.chunkyfx:	moveq.l	#0,d1
		move.w	(a2)+,d2
		move.w	(a3,d2.w),d1
		lsl.l	#2,d1
		move.l	(a1,d1.l),d1
		movep.l	d1,(a0)
		moveq.l	#0,d1
		move.w	(a2)+,d2
		move.w	(a3,d2.w),d1
		lsl.l	#2,d1
		move.l	(a1,d1.l),d1
		movep.l	d1,1(a0)
		addq.l	#8,a0
		dbra	d7,.chunkyfx

		move.l	a0,fullofs_screenadr
		move.l	a2,fullofs_ofs_adr

		rts
		
;--- Timer A ------------------------------------------------------------------------------

fullofs_timer_a:	
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		clr.b	$fffffa19.w


		movem.l d0-a6,-(sp)
		dcb.w 	52-9,$4e71

		lea.l	$ffff8203.w,a6		;2
		move.l	fullofs_adrs_adr,a5	;5
		moveq.l	#0,d7			;1
		moveq.l	#2,d6			;1


		move.b	#0,$ffff820a.w		;remove top border
		dcb.w 	6,$4e71
		lea.l	$ffff8209.w,a0
		moveq.l	#127,d1
		move.b	#2,$ffff820a.w

.sync:		tst.b	(a0)			;hardsync
		beq.s	.sync			;
		move.b	(a0),d2			;
		sub.b	d2,d1			;
		lsr.l	d1,d1			;


;		66 nops until the first scanline, use for inits etc
		dcb.w 	66-21-5,$4e71	

		move.l	(a5)+,d0		;3
		;move.l	screen_adr,a0		;5 destination
		move.l	fullofs_screenadr,a0	;5
		lea.l	c2ptable,a1		;3
		;lea.l	fullofs_ofs,a2		;3
		move.l	fullofs_ofs_adr,a2	;5
		move.l	fullofs_txtadr,a3	;5

		jsr	generic_code		;5


		move.l	empty_adr,d0
		movep.l	d0,(a6)

		movem.l (sp)+,d0-a6
		move.w	#$2300,sr
		rts




fullofs_code1_start:
; ------------- line 1-226
;		rept	226/2
		movep.l	d0,(a6)			;6
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		dcb.w	90-3-84-1,$4e71		;90
		move.l	(a5)+,d0		;3
		moveq.l	#0,d1			;1
		move.w	(a2)+,d2		;2 ofs
		move.w	(a3,d2.w),d1		;4 gfx 
		lsl.l	#2,d1			;3
		move.l	(a1,d1.l),d1		;5
		movep.l	d1,(a0)			;6
		moveq.l	#0,d1			;1
		move.w	(a2)+,d2		;2 ofs
		move.w	(a3,d2.w),d1		;4 gfx 
		lsl.l	#2,d1			;3
		move.l	(a1,d1.l),d1		;5
		movep.l	d1,1(a0)		;6
		moveq.l	#0,d1			;1
		move.w	(a2)+,d2		;2 ofs
		move.w	(a3,d2.w),d1		;4 gfx 
		lsl.l	#2,d1			;3
		move.l	(a1,d1.l),d1		;5
		movep.l	d1,8(a0)		;6
		moveq.l	#0,d1			;1
		move.w	(a2)+,d2		;2 ofs
		move.w	(a3,d2.w),d1		;4 gfx 
		lsl.l	#2,d1			;3
		move.l	(a1,d1.l),d1		;5
		movep.l	d1,9(a0)		;6
		moveq.l	#0,d1			;1
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		;dcb.w	20,$4e71		;20
		move.w	(a2)+,d2		;2 ofs
		move.w	(a3,d2.w),d1		;4 gfx 
		lsl.l	#2,d1			;3
		move.l	(a1,d1.l),d1		;5
		movep.l	d1,16(a0)		;6
		;-
		movep.l	d0,(a6)			;6
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		;dcb.w	90-3-84-1-2,$4e71	;90
		move.l	(a5)+,d0		;3
		moveq.l	#0,d1			;1
		move.w	(a2)+,d2		;2 ofs
		move.w	(a3,d2.w),d1		;4 gfx 
		lsl.l	#2,d1			;3
		move.l	(a1,d1.l),d1		;5
		movep.l	d1,17(a0)		;6
		moveq.l	#0,d1			;1
		move.w	(a2)+,d2		;2 ofs
		move.w	(a3,d2.w),d1		;4 gfx 
		lsl.l	#2,d1			;3
		move.l	(a1,d1.l),d1		;5
		movep.l	d1,24(a0)		;6
		moveq.l	#0,d1			;1
		move.w	(a2)+,d2		;2 ofs
		move.w	(a3,d2.w),d1		;4 gfx 
		lsl.l	#2,d1			;3
		move.l	(a1,d1.l),d1		;5
		movep.l	d1,25(a0)		;6
		moveq.l	#0,d1			;1
		move.w	(a2)+,d2		;2 ofs
		move.w	(a3,d2.w),d1		;4 gfx 
		lsl.l	#2,d1			;3
		move.l	(a1,d1.l),d1		;5
		movep.l	d1,32(a0)		;6
		moveq.l	#0,d1			;1
		move.w	(a2)+,d2		;2 ofs
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		;dcb.w	20,$4e71		;20
		move.w	(a3,d2.w),d1		;4 gfx 
		lsl.l	#2,d1			;3
		move.l	(a1,d1.l),d1		;5
		movep.l	d1,33(a0)		;6
		lea.l	40(a0),a0		;2
		;endr
fullofs_code1_end:

fullofs_code2_start:
; ------------- line 227
		movep.l	d0,(a6)			;6
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		dcb.w	90-3-84,$4e71		;90
		move.l	(a5)+,d0		;3

		moveq.l	#0,d1			;1
		move.w	(a2)+,d2		;2 ofs
		move.w	(a3,d2.w),d1		;4 gfx 
		lsl.l	#2,d1			;3
		move.l	(a1,d1.l),d1		;5
		movep.l	d1,(a0)			;6
		moveq.l	#0,d1			;1
		move.w	(a2)+,d2		;2 ofs
		move.w	(a3,d2.w),d1		;4 gfx 
		lsl.l	#2,d1			;3
		move.l	(a1,d1.l),d1		;5
		movep.l	d1,1(a0)		;6
		moveq.l	#0,d1			;1
		move.w	(a2)+,d2		;2 ofs
		move.w	(a3,d2.w),d1		;4 gfx 
		lsl.l	#2,d1			;3
		move.l	(a1,d1.l),d1		;5
		movep.l	d1,8(a0)		;6
		moveq.l	#0,d1			;1
		move.w	(a2)+,d2		;2 ofs
		move.w	(a3,d2.w),d1		;4 gfx 
		lsl.l	#2,d1			;3
		move.l	(a1,d1.l),d1		;5
		movep.l	d1,9(a0)		;6
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w	20,$4e71		;20

; ------------- line 228
		movep.l	d0,(a6)			;6
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		dcb.w	90-3-84,$4e71		;90
		move.l	(a5)+,d0		;3
		moveq.l	#0,d1			;1
		move.w	(a2)+,d2		;2 ofs
		move.w	(a3,d2.w),d1		;4 gfx 
		lsl.l	#2,d1			;3
		move.l	(a1,d1.l),d1		;5
		movep.l	d1,16(a0)		;6
		moveq.l	#0,d1			;1
		move.w	(a2)+,d2		;2 ofs
		move.w	(a3,d2.w),d1		;4 gfx 
		lsl.l	#2,d1			;3
		move.l	(a1,d1.l),d1		;5
		movep.l	d1,17(a0)		;6
		moveq.l	#0,d1			;1
		move.w	(a2)+,d2		;2 ofs
		move.w	(a3,d2.w),d1		;4 gfx 
		lsl.l	#2,d1			;3
		move.l	(a1,d1.l),d1		;5
		movep.l	d1,24(a0)		;6
		moveq.l	#0,d1			;1
		move.w	(a2)+,d2		;2 ofs
		move.w	(a3,d2.w),d1		;4 gfx 
		lsl.l	#2,d1			;3
		move.l	(a1,d1.l),d1		;5
		movep.l	d1,25(a0)		;6
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w	20-3,$4e71		;20
		movep.l	d0,(a6)			;6 (three nops used in next scan)

; ------------- line 229
		;dcb.w	3,$4e71			;3
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		move.b	d6,$ffff820a.w		;3

		move.l	(a5)+,d0		;3

		moveq.l	#0,d1			;1
		move.w	(a2)+,d2		;2 ofs
		move.w	(a3,d2.w),d1		;4 gfx 
		lsl.l	#2,d1			;3
		move.l	(a1,d1.l),d1		;5
		movep.l	d1,32(a0)		;6
		moveq.l	#0,d1			;1
		move.w	(a2)+,d2		;2 ofs
		move.w	(a3,d2.w),d1		;4 gfx 
		lsl.l	#2,d1			;3
		move.l	(a1,d1.l),d1		;5
		movep.l	d1,33(a0)		;6
		moveq.l	#0,d1			;1
		move.w	(a2)+,d2		;2 ofs
		move.w	(a3,d2.w),d1		;4 gfx 
		lsl.l	#2,d1			;3
		move.l	(a1,d1.l),d1		;5
		movep.l	d1,40(a0)		;6
		moveq.l	#0,d1			;1
		move.w	(a2)+,d2		;2 ofs
		move.w	(a3,d2.w),d1		;4 gfx 
		lsl.l	#2,d1			;3
		move.l	(a1,d1.l),d1		;5
		movep.l	d1,41(a0)		;6

		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w	20-2,$4e71		;20
		lea.l	48(a0),a0		;2
fullofs_code2_end:




;--- Data ---------------------------------------------------------------------------------------------
		
		section	data

fullofs_adrs_adr:	dc.l	fullofs_adrs
fullofs_screenadr:	dc.l	0
fullofs_ofs_adr:	dc.l	fullofs_ofs

fullofs_mainpal1:	dcb.w	16,$0fff
fullofs_mainpal2:	dcb.w	16,$0fff
fullofs_mainpal3:	dcb.w	16,$0fff
fullofs_mainpal4:	dcb.w	16,$0fff
fullofs_blackpal:	dcb.w	16,$0000

fullofs_pal1:		dc.w	$0000,$0880,$0110,$0998,$0221,$0aa9,$0332,$0bba
			dc.w	$0443,$0ccb,$0554,$0ddc,$0665,$0ee6,$077e,$0fff

fullofs_pal2:		dc.w	$0000,$0808,$0101,$0989,$0212,$0a9a,$0323,$0bab
			dc.w	$0434,$0cbc,$0545,$0dcd,$0656,$0e6e,$07e7,$0fff

fullofs_pal3:		dc.w	$0000,$0088,$0011,$0899,$0122,$09aa,$0233,$0abb
			dc.w	$0344,$0bcc,$0455,$0cdd,$0566,$06ee,$0e77,$0fff

fullofs_pal4:		dc.w	$0000,$0080,$0010,$0898,$0121,$09a9,$0232,$0aba
			dc.w	$0343,$0bcb,$0454,$0cdc,$0565,$06e6,$0e77,$0fff

fullofs_txt:		incbin	'fullofs/flare1.z77'	;lz77!
			even

fullofs_pos:		dc.l	0
fullofs_pos2:		dc.l	0
fullofs_pos3:		dc.l	128
fullofs_pos4:		dc.l	0
fullofs_txtadr:		dc.l	fullofs_txt_depacked+127*256+128
		
fullofs_ofs:		incbin	'fullofs/torus.ofs'
			even
fullofs_ofs2:		incbin	'fullofs/jox.ofs'
			even
fullofs_ofs3:		incbin	'fullofs/swirl.ofs'
			even
fullofs_ofs4:		incbin	'fullofs/field.ofs'
			even
	
		section	text
