; tunnel.s
;
; Fullscreen tunnel (over three bitplanes)


		section	text

tunnel_init:

		rts

tunnel_runtime_init:		;75 vbl!
		subq.w	#1,.once
		bne.w	.done

		jsr	black_pal
		jsr	clear_screens
		jsr	syncfix				;fix eventual bitplane corruption
		jsr	black_pal

		move.l	screen_adr,tunnel_scradr

		lea.l	tunnel_1pl,a0
		lea.l	tunnel_1pl_depack,a1
		jsr	lz77


;		move.l	screen_adr,a0
;		move.l	screen_adr2,a1
;		addq.l	#6,a0
;		addq.l	#6,a1
;		lea.l	tunnel_1pl_depack+14196*16,a2
;		move.w	#273-1,d7
;.y:		move.w	#416/16-1,d6
;.x:		move.w	(a2)+,d0
;		move.w	d0,(a0)
;		move.w	d0,(a1)
;		addq.l	#8,a0
;		dbra	d6,.x
;		ifne	hatari
;		lea.l	230-208(a0),a0
;		lea.l	230-208(a1),a1
;		endc
;		ifeq	hatari
;		lea.l	224-208(a0),a0
;		lea.l	224-208(a1),a1
;		endc
;		dbra	d7,.y


		ifne	init_green
		move.w	#$0070,$ffff8240.w
		endc

.done:		rts
.once:		dc.w	1



tunnel_vbl_in:
		bsr.w	tunnel_vbl
		
		movem.l	tunnel_mainpal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		
		lea.l	tunnel_mainpal,a0
		;lea.l	tunnel_pal,a1
		move.l	tunnel_paladr1,a1
		jsr	component_fade

.no:	
		subq.w	#1,.wait2
		bne.s	.no2
		move.w	#75,.wait2
		move.l	tunnel_paladr1,d0
		move.l	tunnel_paladr2,tunnel_paladr1
		move.l	tunnel_paladr3,tunnel_paladr2
		move.l	tunnel_paladr4,tunnel_paladr3
		move.l	d0,tunnel_paladr4
.no2:		
		rts
.wait2:		dc.w	75

tunnel_vbl_in2:
		bsr.w	tunnel_vbl
		subq.w	#1,.wait
		bne.s	.no
		move.w	#3,.wait
		
		movem.l	tunnel_mainpal2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		
		lea.l	tunnel_mainpal2,a0
		lea.l	tunnel_pal2,a1
		jsr	component_fade

.no:

		rts
.wait:		dc.w	3


tunnel_vbl_out:
		bsr.w	tunnel_vbl

		subq.w	#1,.wait
		bne.s	.no
		move.w	#3,.wait
		
		movem.l	tunnel_mainpal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		
		lea.l	tunnel_mainpal,a0
		lea.l	tunnel_blackpal,a1
		jsr	component_fade

.no:		rts
.wait:		dc.w	3

tunnel_vbl:
		move.l	empty_adr,d0		;set screen
		lea.l	$ffff8203.w,a0
		movep.l	d0,(a0)

		rts

tunnel_main:	
		cmp.l	#60,.pos
		ble.s	.run
		clr.l	.pos
.run:
		lea.l	tunnel_1pl_list,a0
		move.l	.pos,d0
		move.l	(a0,d0.l),tunnel_1pl_adr
		addq.l	#4,.pos


		move.l	screen_adr,d0
		move.l	screen_adr2,screen_adr
		move.l	d0,screen_adr2

		lea.l	tunnel_bpl,a0
		move.w	(a0),d0
		rept	5
		move.w	2(a0),(a0)+
		endr
		move.w	d0,(a0)+

		move.l	screen_adr2,d0
		add.w	tunnel_bpl,d0
		move.l	d0,tunnel_scradr

		rts
.pos:		dc.l	0


tunnel_main2:	
		cmp.l	#60,.pos
		ble.s	.run
		clr.l	.pos
.run:
		lea.l	tunnel_1pl_list,a0
		move.l	.pos,d0
		move.l	(a0,d0.l),tunnel_1pl_adr
		addq.l	#4,.pos

		move.l	screen_adr,d0
		move.l	screen_adr2,screen_adr
		move.l	d0,screen_adr2

		lea.l	tunnel_bpl2,a0
		move.w	(a0),d0
		rept	5
		move.w	2(a0),(a0)+
		endr
		move.w	d0,(a0)+

		move.l	screen_adr2,d0
		add.w	tunnel_bpl2,d0
		move.l	d0,tunnel_scradr

		rts
.pos:		dc.l	0


		
tunnel_timer_a:	
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		clr.b	$fffffa19.w


		movem.l d0-a6,-(sp)
		dcb.w 	52-19,$4e71

		lea.l	$ffff8203.w,a2		;2

		move.l	screen_adr,d0		;5
		move.l	tunnel_1pl_adr,a1	;5
		move.l	tunnel_scradr,a0	;5
		moveq.l	#0,d7			;1
		moveq.l	#2,d6			;1


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


		dcb.w 	66-11-4,$4e71	


		move.l	tunnel_skip,d1		;5
		sub.l	d1,a0			;2
		move.w	#228-1,d4		;2
		movep.l	d0,(a2)			;6

;line 1-228
.loop:		;move.w	(a3)+,(a2)		;3 rasters
		dcb.w	3,$4e71
		add.l	d1,a0			;2
		dcb.w	6-5,$4e71		;6
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3 
		dcb.w	3,$4e71			;4
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
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		move.w	(a1)+,8*22(a0)		;4
		move.w	(a1)+,8*23(a0)		;4
		move.w	(a1)+,8*24(a0)		;4
		move.w	(a1)+,8*25(a0)		;4
		dcb.w	4-3,$4e71		;4
		dbra	d4,.loop		;3

;line 229
		dcb.w	3-1,$4e71		;3	-1 for dbra
		move.b	d7,$ffff820a.w		;3 60Hz
		move.b	d6,$ffff8260.w		;3 71Hz
		move.b	d7,$ffff8260.w		;3 60Hz
		move.b	d6,$ffff820a.w		;3 50Hz
		dcb.w	87,$4e71		;87	=102
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w 	20-2,$4e71		;20
		move.w	#44-1,d4		;2

; line 230-273

.loop2:		;move.w	(a3)+,(a2)		;3 rasters
		dcb.w	3,$4e71
		add.l	d1,a0			;2
		dcb.w	6-5,$4e71		;6
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3 
		dcb.w	3,$4e71			;4
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
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		move.w	(a1)+,8*22(a0)		;4
		move.w	(a1)+,8*23(a0)		;4
		move.w	(a1)+,8*24(a0)		;4
		move.w	(a1)+,8*25(a0)		;4
		dcb.w	4-3,$4e71		;4
		dbra	d4,.loop2		;3


		move.l	empty_adr,d0	;5
		movep.l	d0,(a2)			;6


		add.l	d1,a0			;2
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
		move.w	(a1)+,8*22(a0)		;4
		move.w	(a1)+,8*23(a0)		;4
		move.w	(a1)+,8*24(a0)		;4
		move.w	(a1)+,8*25(a0)		;4

		movem.l (sp)+,d0-a6
		move.w	#$2300,sr
		rts


		
		section	data

			ifne	hatari
tunnel_skip:		dc.l	230
			endc
			ifeq	hatari
tunnel_skip:		dc.l	224
			endc


tunnel_1pl:		incbin	'tunnel/tunnel.z77'		;lz77!	;416*273*17
			even
tunnel_1pl_adr:		dc.l	tunnel_1pl_depack
tunnel_scradr:		dc.l	0
tunnel_1pl_list:
			rept	2
			dc.l	tunnel_1pl_depack+0*14196,tunnel_1pl_depack+1*14196,tunnel_1pl_depack+2*14196,tunnel_1pl_depack+3*14196
			dc.l	tunnel_1pl_depack+4*14196,tunnel_1pl_depack+5*14196,tunnel_1pl_depack+6*14196,tunnel_1pl_depack+7*14196
			dc.l	tunnel_1pl_depack+8*14196,tunnel_1pl_depack+9*14196,tunnel_1pl_depack+10*14196,tunnel_1pl_depack+11*14196
			dc.l	tunnel_1pl_depack+12*14196,tunnel_1pl_depack+13*14196,tunnel_1pl_depack+14*14196,tunnel_1pl_depack+15*14196
			endr

tunnel_paladr1:		dc.l	tunnel_pal
tunnel_paladr2:		dc.l	tunnel_pal3
tunnel_paladr3:		dc.l	tunnel_pal4
tunnel_paladr4:		dc.l	tunnel_pal5


tunnel_mainpal:		dcb.w	16,$0fff
tunnel_mainpal2:	dcb.w	16,$0000
tunnel_blackpal:	dcb.w	16,$0000
tunnel_pal2:		dc.w	$0000,$0113
			dcb.w	14,$0000
tunnel_pal:
bgcol:			equ	$0000
colo1:			equ	$0003
colo2:			equ	$0025
colo3:			equ	$0247
			dc.w	bgcol,colo1,colo1,colo2,colo1,colo2,colo2,colo3
			dc.w	$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777
tunnel_pal3:
xbgcol:			equ	$0000
xcolo1:			equ	$0300
xcolo2:			equ	$0520
xcolo3:			equ	$0742
			dc.w	xbgcol,xcolo1,xcolo1,xcolo2,xcolo1,xcolo2,xcolo2,xcolo3
			dc.w	$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777
tunnel_pal4:
ybgcol:			equ	$0000
ycolo1:			equ	$0010
ycolo2:			equ	$0032
ycolo3:			equ	$0054
			dc.w	ybgcol,ycolo1,ycolo1,ycolo2,ycolo1,ycolo2,ycolo2,ycolo3
			dc.w	$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777
tunnel_pal5:
zbgcol:			equ	$0000
zcolo1:			equ	$0100
zcolo2:			equ	$0302
zcolo3:			equ	$0504
			dc.w	zbgcol,zcolo1,zcolo1,zcolo2,zcolo1,zcolo2,zcolo2,zcolo3
			dc.w	$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777
		
tunnel_bpl:		dc.w	0,0,2,2,4,4
tunnel_bpl2:		dc.w	0,0,0,0,0,0

		section	text
