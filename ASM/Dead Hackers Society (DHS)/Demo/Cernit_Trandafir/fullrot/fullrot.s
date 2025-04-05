; Altparty 2009 STe demo
; Fullscreen ofsmap at 50 fps 
;
; fullrot.s

		section	text

		;include	'fullrot/rotator.s'
		include	'fullrot/ofsmap.s'

;-------------- INIT
fullrot_init:	rts
		


;-------------- RUNTIME INIT
fullrot_runtime_init:
		subq.w	#1,.once
		bne.w	.done

		jsr	clear_screens
		jsr	syncfix				;fix eventual bitplane corruption
		jsr	black_pal

		ifne	init_finish
		move.w	#$0700,$ffff8240.w
		endc

		;create displaylist (4 pix high)
		lea.l	fullrot_displist,a0
		move.l	screen_adr,a1
		move.l	screen_adr2,a3
		move.w	#272/4-1,d7
.displist:	move.l	a1,(a0)+
		move.l	a3,(a0)+
		add.w	#208,a3
		move.l	a1,(a0)+
		move.l	a3,(a0)+
		add.w	#208,a1
		add.w	#208,a3
		dbra	d7,.displist
		sub.w	#208,a1
		sub.w	#208,a3
		move.l	a1,(a0)+

		;depack background
		lea.l	fullrot_bg_ice,a0
		move.l	screen_adr2,a1
		jsr	ice
		
		;depack c2p mask
		lea.l	fullrot_c2p_ice,a0
		lea.l	fullrot_c2p,a1
		jsr	ice

		;create c2p mask
		lea.l	fullrot_c2p,a0
		lea.l	8*64(a0),a1
		move.w	#64-1,d7
.mask:		move.w	(a0)+,d0
		or.w	(a0)+,d0
		or.w	(a0)+,d0
		or.w	(a0)+,d0
		not.w	d0
		move.w	d0,(a1)+
		move.w	d0,(a1)+
		move.w	d0,(a1)+
		move.w	d0,(a1)+
		dbra	d7,.mask

		;ofsmap depack texture
		lea.l	fullrot_ofstxt_lz77,a0
		lea.l	fullrot_tmp,a1
		jsr	lz77
		
		;ofsmap texture nibble -> byte and 3bit-shift to c2p-align
		lea.l	fullrot_tmp,a0
		lea.l	fullrot_ofstxt,a1
		move.w	#256*256/2-1,d7
.shift2:	move.b	(a0)+,d0
		move.b	d0,d1
		lsr.b	#4,d0
		lsl.b	#3,d0
		lsl.b	#4,d1
		lsr.b	#1,d1
		move.b	d0,(a1)+
		move.b	d1,(a1)+
		dbra	d7,.shift2
		
		;ofsmap texture doublecopy
		lea.l	fullrot_ofstxt,a0
		lea.l	fullrot_ofstxt+256*256,a1
		move.w	#256*256/4-1,d7
.cptxt:		move.l	(a0)+,(a1)+
		dbra	d7,.cptxt

		;create fadein/out lists
		move.w	#48-1,.count
		move.l	#fullrot_fadein_list,.adr
.fadein:	lea.l	fullrot_black,a0
		lea.l	fullrot_pal_spiral,a1
		jsr	component_fade
		move.l	.adr,a0
		movem.l	fullrot_black,d0-d7
		movem.l	d0-d7,(a0)
		add.l	#32,.adr
		subq.w	#1,.count
		bpl.s	.fadein

		move.w	#48-1,.count
		move.l	#fullrot_fadeout_list,.adr
.fadeout:	lea.l	fullrot_black2,a0
		lea.l	fullrot_pal_waveout,a1
		jsr	component_fade
		move.l	.adr,a0
		movem.l	fullrot_black2,d0-d7
		movem.l	d0-d7,(a0)
		add.l	#32,.adr
		subq.w	#1,.count
		bpl.s	.fadeout

		move.w	#48-1,.count
.fadeout2:	lea.l	fullrot_black2,a0
		lea.l	fullrot_pal_wave,a1
		jsr	component_fade
		move.l	.adr,a0
		movem.l	fullrot_black2,d0-d7
		movem.l	d0-d7,(a0)
		add.l	#32,.adr
		subq.w	#1,.count
		bpl.s	.fadeout2
		
		
		;copy overscan code
		lea.l	generic_code,a0			;
		move.l	#fullrot_code1_end,d0		;top 221 lines with c2p code
		sub.l	#fullrot_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#17-1,d7			;13 lines per copy = 221 total
.code1a:	move.l	d0,d6
		lea.l	fullrot_code1_start,a1
.code1b:	move.w	(a1)+,(a0)+
		dbra	d6,.code1b
		dbra	d7,.code1a

		move.l	#fullrot_code3_end,d0		;6 lines with dummy code before lower border
		sub.l	#fullrot_code3_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#6-1,d7
.code4a:	move.l	d0,d6
		lea.l	fullrot_code3_start,a1
.code4b:	move.w	(a1)+,(a0)+
		dbra	d6,.code4b
		dbra	d7,.code4a

		move.l	#fullrot_code2_end,d0		;2 midlines for lower border
		sub.l	#fullrot_code2_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#1-1,d7
.code2a:	move.l	d0,d6
		lea.l	fullrot_code2_start,a1
.code2b:	move.w	(a1)+,(a0)+
		dbra	d6,.code2b
		dbra	d7,.code2a

		move.l	#fullrot_code3_end,d0		;lower 44 lines dummy code
		sub.l	#fullrot_code3_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#44-1,d7
.code3a:	move.l	d0,d6
		lea.l	fullrot_code3_start,a1
.code3b:	move.w	(a1)+,(a0)+
		dbra	d6,.code3b
		dbra	d7,.code3a

		move.w	dummy,(a0)+	;rts

		jsr	clear_256k



		ifne	init_finish
		move.w	#$0070,$ffff8240.w
		endc

.done:		rts
.once:		dc.w	1
.singen:	dc.w	300
.count:		dc.w	0
.count2:	dc.w	0
.shadepos:	dc.l	0
.adr:		dc.l	0

;-------------- VBL


fullrot_fadein:
		lea.l	fullrot_fadein_list,a0
		add.w	fullrot_fadepos,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,$ffff8240.w

		bsr.s	fullrot_vbl_spiral

		subq.w	#1,.wait
		bne.s	.done
		move.w	#2,.wait
		cmp.w	#32*47,fullrot_fadepos
		bge.s	.done
		add.w	#32,fullrot_fadepos
.done:		rts

.wait:		dc.w	2

fullrot_fadeout1:
		bsr.s	fullrot_vbl_wave
		cmp.w	#32*46,fullrot_fadepos
		ble.s	.done
		sub.w	#32,fullrot_fadepos
.done:		rts

fullrot_fadeout2:
		bsr.s	fullrot_vbl_wave
		tst.w	fullrot_fadepos
		ble.s	.done
		sub.w	#32,fullrot_fadepos
.done:		rts

fullrot_vbl_spiral:
		clr.w	$ffff8240.w
		bsr.w	fullrot_vbl		
		cmp.b	#$2a,$fffffc02.w
		beq.s	.noadd
		add.l	#1+256,fullrot_t
		and.l	#$ffff,fullrot_t
.noadd:		move.l	#fullrot_ofslut_spiral,fullrot_ofsadr
		bsr.w	fullrot_ofsmap
		rts

fullrot_vbl_wave:
		lea.l	fullrot_fadeout_list,a0
		add.w	fullrot_fadepos,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,$ffff8240.w
		clr.w	$ffff8240.w
		bsr.w	fullrot_vbl		
		cmp.b	#$2a,$fffffc02.w
		beq.s	.noadd
		add.l	#1+256,fullrot_t
		and.l	#$ffff,fullrot_t
.noadd:		move.l	#fullrot_ofslut_wave,fullrot_ofsadr
		bsr.w	fullrot_ofsmap
		rts

fullrot_vbl_polar:
		movem.l	fullrot_pal_polar,d0-d7
		movem.l	d0-d7,$ffff8240.w
		clr.w	$ffff8240.w
		bsr.w	fullrot_vbl		
		cmp.b	#$2a,$fffffc02.w
		beq.s	.noadd
		add.l	#256,fullrot_t
		and.l	#$ffff,fullrot_t
.noadd:		move.l	#fullrot_ofslut_polar,fullrot_ofsadr
		bsr.w	fullrot_ofsmap
		move.w	#95*32,fullrot_fadepos ;init fadeout palette position in advance
		rts

fullrot_vbl_tunnel:
		movem.l	fullrot_pal_tunnel,d0-d7
		movem.l	d0-d7,$ffff8240.w
		clr.w	$ffff8240.w
		bsr.w	fullrot_vbl		
		cmp.b	#$2a,$fffffc02.w
		beq.s	.noadd
		add.l	#1+256,fullrot_t
		and.l	#$ffff,fullrot_t
.noadd:		move.l	#fullrot_ofslut_tunnel,fullrot_ofsadr
		bsr.w	fullrot_ofsmap
		rts
		
fullrot_vbl:
		move.l	empty_adr,d0
		lea.l	$ffff8203.w,a0
		movep.l	d0,0(a0)

		lea.l	.plotlist,a0
		add.w	.pos,a0
		lea.l	fullrot_chunky_xofs,a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+

		cmp.w	#8*15,.pos
		blt.s	.add
		move.w	#-8,.pos
.add:		addq.w	#8,.pos

		rts
.pos:		dc.w	0

		;chunky_x, chunky_y, c2p_ofs (scr_x), scr_y
.plotlist:
		dc.w	0,104*0,128*0,208*0 ;1
		dc.w	3,104*2,128*3,208*2
		dc.w	3,104*3,128*3,208*3 ;1
		dc.w	1,104*0,128*1,208*0
		dc.w	2,104*2,128*2,208*2 ;1
		dc.w	0,104*1,128*0,208*1
		dc.w	1,104*3,128*1,208*3 ;1
		dc.w	3,104*0,128*3,208*0
		dc.w	1,104*1,128*1,208*1 ;1
		dc.w	0,104*3,128*0,208*3
		dc.w	3,104*1,128*3,208*1 ;1
		dc.w	2,104*3,128*2,208*3
		dc.w	0,104*2,128*0,208*2 ;1
		dc.w	2,104*1,128*2,208*1
		dc.w	2,104*0,128*2,208*0 ;1
		dc.w	1,104*2,128*1,208*2

;-------------- MAIN
fullrot_main:
		rts


;-------------- TIMER A
fullrot_timer_a:
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


		dcb.w 	66-48-5,$4e71	

		moveq.l	#2,d7				;1
		lea.l	$ffff8203.w,a6			;2
		lea.l	fullrot_displist,a5		;3
		move.l	(a5)+,d0			;3

		lea.l	fullrot_chunky,a4		;3
		lea.l	fullrot_c2p,a3			;3 c2p
		lea.l	8*64(a3),a2			;2 mask
		move.l	screen_adr,a1			;5
		moveq.l	#0,d4				;1 chunkypixel

		add.w	fullrot_chunky_xofs,a4		;4
		add.w	fullrot_chunky_yofs,a4		;4
		add.w	fullrot_c2p_ofs,a3		;4
		add.w	fullrot_c2p_ofs,a2		;4
		add.w	fullrot_scr_ofs,a1		;4

		jsr	generic_code			;5

		movem.l (sp)+,d0-a6
		move.w	#$2300,sr
		rts


fullrot_code1_start:

		rept	13-1
		movep.l	d0,0(a6)			;6
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		dcb.w	90-73,$4e71

		move.b	(a4),d4				;2
		movem.l	(a3,d4.w),d1-d2			;9
		move.l	(a2,d4.w),d3			;5
		and.l	d3,(a1)				;5
		or.l	d1,(a1)+			;5
		and.l	d3,(a1)				;5
		or.l	d2,(a1)+			;5

		move.b	4(a4),d4			;3
		movem.l	(a3,d4.w),d1-d2			;9
		move.l	(a2,d4.w),d3			;5
		and.l	d3,(a1)				;5
		or.l	d1,(a1)+			;5
		and.l	d3,(a1)				;5
		or.l	d2,(a1)+			;5

		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	20-5,$4e71

		move.l	(a5)+,d0			;3
		lea.l	8(a4),a4			;2
		endr

		movep.l	d0,0(a6)			;6
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		dcb.w	90-73,$4e71

		move.b	(a4),d4				;2
		movem.l	(a3,d4.w),d1-d2			;9
		move.l	(a2,d4.w),d3			;5
		and.l	d3,(a1)				;5
		or.l	d1,(a1)+			;5
		and.l	d3,(a1)				;5
		or.l	d2,(a1)+			;5

		move.b	4(a4),d4			;3
		movem.l	(a3,d4.w),d1-d2			;9
		move.l	(a2,d4.w),d3			;5
		and.l	d3,(a1)				;5
		or.l	d1,(a1)+			;5
		and.l	d3,(a1)				;5
		or.l	d2,(a1)+			;5

		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	20-7,$4e71

		move.l	(a5)+,d0			;3
		lea.l	8+104*3(a4),a4			;2
		lea.l	208*3(a1),a1			;2
fullrot_code1_end:



fullrot_code2_start:
		movep.l	d0,0(a6)			;6
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		dcb.w	90,$4e71
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	20-6,$4e71
		move.l	(a5)+,d0			;3
		movep.l	d0,0(a6)			;3+ 3 on next line
;line 229	;3 nops from previous line
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	87,$4e71
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	20-3,$4e71
		move.l	(a5)+,d0			;3
fullrot_code2_end:

fullrot_code3_start:
		movep.l	d0,0(a6)			;6
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		dcb.w	90,$4e71
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	20-3,$4e71
		move.l	(a5)+,d0			;3
fullrot_code3_end:



		section	data

fullrot_c2p_ice:	incbin	'fullrot/c2pmask.ice'
			even

fullrot_c2p:			
fullrot_bg_ice:		incbin	'fullrot/bg.ice'
			even
	
fullrot_black:		dcb.w	16,$0000
fullrot_black2:		dcb.w	16,$0000
fullrot_fadepos:	dc.w	0

; 0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 
; 0  8  1  9  2  a  3  b  4  c   5  d  6  e  7  f
fullrot_pal_spiral:	dc.w	$0000,$0999,$0322,$0cb3,$0e5c,$0392,$034a,$0830	;background
			dc.w	$0280,$0B18,$0598,$0E21,$0732,$07CB,$0F6D,$0FF7 ;pal5 half
			
fullrot_pal_tunnel:	dc.w	$0000,$0999,$0322,$0cb3,$0e5c,$0392,$034a,$0830	;background
			dc.w	$0280,$0299,$0A23,$0A3C,$03B6,$04C7,$0D67,$0FF7 ;pal6 half

fullrot_pal_polar:	dc.w	$0000,$0999,$0322,$0cb3,$0e5c,$0392,$034a,$0830	;background
			dc.w	$0100,$0210,$0321,$0432,$0543,$0654,$0765,$0776 ;pal6 half

fullrot_pal_wave:	dc.w	$0000,$0999,$0322,$0cb3,$0e5c,$0392,$034a,$0830	;background
			dc.w	$0111,$0222,$0333,$0444,$0555,$0666,$0777,$0fff ;pal6 half

fullrot_pal_waveout:	dc.w	$0000,$0999,$0322,$0cb3,$0e5c,$0392,$034a,$0830	;background
			dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000 ;



fullrot_t:		dc.l	0

;---------------------- don't change order of these four variables!
fullrot_chunky_xofs:	dc.w	0
fullrot_chunky_yofs:	dc.w	0
fullrot_c2p_ofs:	dc.w	0
fullrot_scr_ofs:	dc.w	0
;------------------------------------------------------------------


		
		section	text
