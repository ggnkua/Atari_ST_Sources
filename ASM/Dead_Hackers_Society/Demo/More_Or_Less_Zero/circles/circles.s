; circles.s
;
; Circle interference effect

		section	text

circles_init:	rts

circles_runtime_init:			;needs 75 vbls
		subq.w	#1,.once
		bne.w	.done

		movem.l	circles_mainpal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		;jsr	white_pal
		jsr	clear_screens
		jsr	syncfix				;fix eventual bitplane corruption
		;jsr	white_pal
		movem.l	circles_mainpal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		lea.l	circles_pic,a0
		lea.l	circles_pic_depack,a1
		jsr	lz77

		lea.l	circles_1pl,a0
		lea.l	circles_1pl_depack,a1
		jsr	lz77
		
		lea.l	circles_pic_depack+32,a0
		move.l	screen_adr_base,a1
		move.w	#512*512/2/4-1,d7
.copy:		move.l	(a0)+,(a1)+
		dbra	d7,.copy

		lea.l	circles_pic_depack+32+256*119+16,a0
		move.l	a0,circles_adr1

		move.l	screen_adr_base,a0
		add.l	#256*119+16,a0
		move.l	a0,circles_adr2

		ifne	init_green
		move.w	#$0070,$ffff8240.w
		endc

.done:		rts
.once:		dc.w	1

circles_runtime_exit:

		subq.w	#1,.once
		bne.s	.no

		clr.b	$ffff8265.w
		clr.b	$ffff820f.w

.no:		rts
.once:		dc.w	1


circles_vbl:
		clr.b	$ffff8265.w

		move.l	screen_adr,d0			;set screen
		lsr.w	#8,d0				;
		move.l	d0,$ffff8200.w			;

		
		subq.w	#1,.wait
		bne.s	.no
		move.w	#3,.wait

		movem.l	circles_mainpal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		lea.l	circles_mainpal,a0
		lea.l	circles_pal,a1
		jsr	component_fade
.no:		rts
.wait:		dc.w	3

circles_vbl_out:
		clr.b	$ffff8265.w

		move.l	screen_adr,d0			;set screen
		lsr.w	#8,d0				;
		move.l	d0,$ffff8200.w			;

		
		subq.w	#1,.wait
		bne.s	.no
		move.w	#3,.wait

		movem.l	circles_mainpal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		lea.l	circles_mainpal,a0
		lea.l	circles_blackpal,a1
		jsr	component_fade
.no:		rts
.wait:		dc.w	3

circles_main:	
		move.l	circles_4pl_adr,d0
		move.l	circles_4pl_adr2,circles_4pl_adr
		move.l	d0,circles_4pl_adr2

		move.w	circles_4pl_lw,d0
		move.w	circles_4pl_lw2,circles_4pl_lw
		move.w	d0,circles_4pl_lw2
		
		move.w	circles_4pl_hscrol,d0
		move.w	circles_4pl_hscrol2,circles_4pl_hscrol
		move.w	d0,circles_4pl_hscrol2
		
		move.l	circles_adr1,d0
		move.l	circles_adr2,circles_adr1
		move.l	d0,circles_adr2
		

		add.l	#32,.y1plsin
		and.l	#$1fff,.y1plsin
		lea.l	sincos4000,a0
		move.l	.y1plsin,d0
		move.l	(a0,d0.l),d1
               	muls.w	#238,d1
		asr.l	#8,d1
		asr.l	#7,d1
		asl.l	#6,d1	;*64

		lea.l	circles_1pl_depack+64*119+8,a0
		add.l	d1,a0
		move.l	a0,circles_1pl_adr


		add.l	#48,.x4plsin
		and.l	#$1fff,.x4plsin
		lea.l	sincos4000,a0
		move.l	.x4plsin,d0
		move.l	(a0,d0.l),d1
               	muls.w	#64,d1
		asr.l	#8,d1
		asr.l	#7,d1

		move.l	d1,d2
		and.b	#$0f,d2
		move.b	d2,circles_4pl_hscrol

		and.b	#%11110000,d1
		asr.l	#1,d1

		move.l	circles_adr1,a0
		add.l	d1,a0
		move.l	a0,circles_4pl_adr

		asr.l	#2,d1
		add.l	d1,circles_1pl_adr


		add.l	#44,.y4plsin
		and.l	#$1fff,.y4plsin
		lea.l	sincos4000,a0
		move.l	.y4plsin,d0
		move.l	(a0,d0.l),d1
               	muls.w	#238,d1
		asr.l	#8,d1
		asr.l	#7,d1
		asl.l	#8,d1	;*256
		add.l	d1,circles_4pl_adr



;-------------- code for hatari
		ifne	hatari
		tst.b	circles_4pl_hscrol
		bne.s	.hscrol
		move.b	#13,circles_4pl_lw		;26 bytes extra linewidth if hscrol =0
		bra.s	.hscrol_done
.hscrol:	move.b	#12,circles_4pl_lw		;24 bytes extra linewidth if hscrol >0
.hscrol_done:
		endc
;------------------------------------------

;-------------- code for ste
		ifeq	hatari
		tst.b	circles_4pl_hscrol
		bne.s	.hscrol
		move.b	#16,circles_4pl_lw		;32 bytes extra linewidth if hscrol =0
		bra.s	.hscrol_done
.hscrol:	move.b	#12,circles_4pl_lw		;24 bytes extra linewidth if hscrol >0
.hscrol_done:
		endc
;------------------------------------------


		rts
.y1plsin:	dc.l	0
.y4plsin:	dc.l	0
.x4plsin:	dc.l	0



		
circles_timer_a:	
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		clr.b	$fffffa19.w


		movem.l d0-a6,-(sp)
		dcb.w 	52-19-13,$4e71

		move.l	circles_4pl_adr,a0	;5
		lea.l	6(a0),a0		;2
		move.l	circles_1pl_adr,a1	;5
		lea.l	$ffff8260.w,a2		;2
		lea.l	$ffff820a.w,a3		;2
		moveq.l	#0,d7			;1
		moveq.l	#1,d6			;1
		moveq.l	#2,d5			;1

		lea.l	$ffff8203.w,a5		;2
		move.l	empty_adr,d0		;5
		movep.l	d0,(a5)			;6




		move.b	#0,$ffff820a.w			;remove top border
		dcb.w 	6,$4e71
		lea.l	$ffff8209.w,a6
		moveq.l	#127,d1
		move.b	#2,$ffff820a.w

.sync:		tst.b	(a6)				;hardsync
		beq.s	.sync				;
		move.b	(a6),d2				;
		sub.b	d2,d1				;
		lsr.l	d1,d1				;


;		66 nops until the first scanline, use for inits etc
		dcb.w 	66-12-6-13,$4e71	



		move.b	circles_4pl_lw2,$ffff820f.w	;6
		move.b	circles_4pl_hscrol2,$ffff8265.w	;6

		lea.l	-256(a0),a0		;2
		lea.l	-10(a1),a1		;2
		move.w	#228-1,d1		;2

		lea.l	$ffff8203.w,a6		;2
		move.l	circles_4pl_adr2,d0	;5
		movep.l	d0,(a6)			;6




;line 1-228	l/r (7-91-16)

.loop:
		lea.l	256(a0),a0		;2
		lea.l	10(a1),a1		;2
		move.w	(a1)+,d0		;2

		move.b	d5,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3 12

		move.w	d0,(a0)			;2
		move.w	(a1)+,8*1(a0)		;4
		move.w	(a1)+,8*2(a0)		;4
		move.w	(a1)+,8*3(a0)		;4
		move.w	(a1)+,8*4(a0)		;4
		move.w	(a1)+,8*5(a0)		;4
		move.w	(a1)+,8*6(a0)		;4
		move.w	(a1)+,8*7(a0)		;4
		move.w	(a1)+,8*8(a0)		;4
		move.w	(a1)+,8*9(a0)		;4
		move.w	(a1)+,8*10(a0)		;4
		move.w	(a1)+,8*11(a0)		;4
		move.w	(a1)+,8*12(a0)		;4
		move.w	(a1)+,8*13(a0)		;4
		move.w	(a1)+,8*14(a0)		;4
		move.w	(a1)+,8*15(a0)		;4
		move.w	(a1)+,8*16(a0)		;4
		move.w	(a1)+,8*17(a0)		;4
		move.w	(a1)+,8*18(a0)		;4
		move.w	(a1)+,8*19(a0)		;4
		move.w	(a1)+,8*20(a0)		;4
		move.w	(a1)+,8*21(a0)		;4
		move.w	(a1)+,8*22(a0)		;4 90
		move.b	d7,$ffff820a.w		;3
		move.b	d5,$ffff820a.w		;3
		move.w	(a1)+,8*23(a0)		;4
		move.w	(a1)+,8*24(a0)		;4
		move.w	(a1)+,8*25(a0)		;4
		move.w	(a1)+,8*26(a0)		;4
		dcb.w	1,$4e71
		dbra	d1,.loop		;3

;line 229	l/r/l (2-83-11)

		dcb.w	3-1,$4e71		;3	-1 for dbra
		move.b	d7,$ffff820a.w		;3 60Hz
		move.b	d5,$ffff8260.w		;3 71Hz
		move.b	d7,$ffff8260.w		;3 60Hz
		move.b	d5,$ffff820a.w		;3 50Hz
		dcb.w	87,$4e71		;87	=102
		move.b	d7,$ffff820a.w		;3
		move.b	d5,$ffff820a.w		;3
		dcb.w 	20-2,$4e71		;20
		move.w	#44-1,d1		;2

; line 230-273	l/r (7-91-16)
.loop2:
		lea.l	256(a0),a0		;2
		lea.l	10(a1),a1		;2
		move.w	(a1)+,d0		;2

		move.b	d5,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3 12

		move.w	d0,(a0)			;2
		move.w	(a1)+,8*1(a0)		;4
		move.w	(a1)+,8*2(a0)		;4
		move.w	(a1)+,8*3(a0)		;4
		move.w	(a1)+,8*4(a0)		;4
		move.w	(a1)+,8*5(a0)		;4
		move.w	(a1)+,8*6(a0)		;4
		move.w	(a1)+,8*7(a0)		;4
		move.w	(a1)+,8*8(a0)		;4
		move.w	(a1)+,8*9(a0)		;4
		move.w	(a1)+,8*10(a0)		;4
		move.w	(a1)+,8*11(a0)		;4
		move.w	(a1)+,8*12(a0)		;4
		move.w	(a1)+,8*13(a0)		;4
		move.w	(a1)+,8*14(a0)		;4
		move.w	(a1)+,8*15(a0)		;4
		move.w	(a1)+,8*16(a0)		;4
		move.w	(a1)+,8*17(a0)		;4
		move.w	(a1)+,8*18(a0)		;4
		move.w	(a1)+,8*19(a0)		;4
		move.w	(a1)+,8*20(a0)		;4
		move.w	(a1)+,8*21(a0)		;4
		move.w	(a1)+,8*22(a0)		;4 90
		move.b	d7,$ffff820a.w		;3
		move.b	d5,$ffff820a.w		;3
		move.w	(a1)+,8*23(a0)		;4
		move.w	(a1)+,8*24(a0)		;4
		move.w	(a1)+,8*25(a0)		;4
		move.w	(a1)+,8*26(a0)		;4
		dcb.w	1,$4e71
		dbra	d1,.loop2		;3

		lea.l	$ffff8203.w,a5		;2
		move.l	empty_adr,d0		;5
		movep.l	d0,(a5)			;6


		lea.l	256(a0),a0		;2
		lea.l	10(a1),a1		;2
		move.w	(a1)+,(a0)		;3
		move.w	(a1)+,8*1(a0)		;4
		move.w	(a1)+,8*2(a0)		;4
		move.w	(a1)+,8*3(a0)		;4
		move.w	(a1)+,8*4(a0)		;4
		move.w	(a1)+,8*5(a0)		;4
		move.w	(a1)+,8*6(a0)		;4
		move.w	(a1)+,8*7(a0)		;4
		move.w	(a1)+,8*8(a0)		;4
		move.w	(a1)+,8*9(a0)		;4
		move.w	(a1)+,8*10(a0)		;4
		move.w	(a1)+,8*11(a0)		;4
		move.w	(a1)+,8*12(a0)		;4
		move.w	(a1)+,8*13(a0)		;4
		move.w	(a1)+,8*14(a0)		;4
		move.w	(a1)+,8*15(a0)		;4
		move.w	(a1)+,8*16(a0)		;4
		move.w	(a1)+,8*17(a0)		;4
		move.w	(a1)+,8*18(a0)		;4
		move.w	(a1)+,8*19(a0)		;4
		move.w	(a1)+,8*20(a0)		;4
		move.w	(a1)+,8*21(a0)		;4
		move.w	(a1)+,8*22(a0)		;4 90
		move.w	(a1)+,8*23(a0)		;4
		move.w	(a1)+,8*24(a0)		;4
		move.w	(a1)+,8*25(a0)		;4
		move.w	(a1)+,8*26(a0)		;4


		movem.l (sp)+,d0-a6
		move.w	#$2300,sr
		rts

		
		section	data

circles_1pl_adr:	dc.l	circles_1pl_depack
circles_4pl_adr:	dc.l	circles_pic_depack
circles_4pl_adr2:	dc.l	circles_pic_depack
circles_4pl_hscrol:	dc.w	0
circles_4pl_lw:		dc.w	0
circles_4pl_hscrol2:	dc.w	0
circles_4pl_lw2:	dc.w	0
circles_adr1:		dc.l	0
circles_adr2:		dc.l	0


circles_pic:		incbin	'circles/circles4.z77'				;lz77! ;512x512 
			even
circles_1pl:		incbin	'circles/circles1.z77'				;lz77! ;512x512
			even

circles_mainpal:	dcb.w	16,$0fff
circles_blackpal:	dcb.w	16,$0000

circles_pal:
			dc.w	$0000,$0310,$0421,$0532,$0643,$0754,$0765,$0777 ;ok
			dc.w	$0777,$0567,$0457,$0346,$0235,$0124,$0013,$0000

		section	text
