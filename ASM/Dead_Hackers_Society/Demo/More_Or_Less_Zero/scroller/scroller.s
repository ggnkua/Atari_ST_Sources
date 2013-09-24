; scroller.s
;
; Zooming scroller effect

		section	text

;		include	'hatari/hatari.s'

;%%% Init %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

scroller_init:
		lea.l	scroller_zoomtab,a0
		move.l	#256+8,d0
		move.w	#256-1,d7
.zoomtab:
		move.l	#256,d2
		lsl.l	#8,d2
		divu	d7,d2
		and.l	#255,d2
		move.w	d0,(a0)+
		subq.w	#1,d0
		dbra	d7,.zoomtab

		rts		

;%%% Runtime init %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

scroller_runtime_init:		;50 vbl!
		subq.w	#1,.once
		bne.w	.done

		;jsr	clear_screens
		;jsr	syncfix				;fix eventual bitplane corruption
		;jsr	black_pal

		ifne	init_green
		move.w	#$0020,$ffff8240.w
		endc

		bsr	scroller_init_bg

		jsr	clear_128k

		lea.l	scroller_fontlz77,a0
		lea.l	scroller_fontdata+9000,a1
		jsr	lz77
		
		lea.l	scroller_font,a0
		move.w	#30*305/4-1,d7
		move.l	#$0fff0fff,d0
.white2:	move.l	d0,(a0)+
		dbra	d7,.white2


;------------- copy overscan code
		lea.l	generic_code,a0

		move.l	#scroller_code1_end,d0	;top 227 lines
		sub.l	#scroller_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#227-1,d7
.code1a:	move.l	d0,d6
		lea.l	scroller_code1_start,a1
.code1b:	move.w	(a1)+,(a0)+
		dbra	d6,.code1b
		dbra	d7,.code1a

		move.l	#scroller_code2_end,d0	;2 midlines
		sub.l	#scroller_code2_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#1-1,d7
.code2a:	move.l	d0,d6
		lea.l	scroller_code2_start,a1
.code2b:	move.w	(a1)+,(a0)+
		dbra	d6,.code2b
		dbra	d7,.code2a

		move.l	#scroller_code1_end,d0	;lower 43 lines (uses same code as top lines) 
		sub.l	#scroller_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#43-1,d7
.code3a:	move.l	d0,d6
		lea.l	scroller_code1_start,a1
.code3b:	move.w	(a1)+,(a0)+
		dbra	d6,.code3b
		dbra	d7,.code3a

		move.l	#scroller_code3_end,d0	;2 midlines
		sub.l	#scroller_code3_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#1-1,d7
.code4a:	move.l	d0,d6
		lea.l	scroller_code3_start,a1
.code4b:	move.w	(a1)+,(a0)+
		dbra	d6,.code4b
		dbra	d7,.code4a
		
		move.w	dummy,(a0)+
;-------------- end of overscan code -----------

		ifne	init_green
		move.w	#$0070,$ffff8240.w
		endc

.done:		rts
.once:		dc.w	1

scroller_init_bg:
		;generate zoom table scanline gfx
		move.l	scroller_bg_adr,a0
		move.l	a0,.bg_adr
		move.w	#256-1,d7
.loop:
		lea	.scanline,a0
		move.w	d7,d0		;FIXME: should be zoom dep
		move.l	#512,d1		;scanline length
		bsr	scroller_scale
		
		lea	.scanline,a0
		move.l	.bg_adr,a1
		add.l	#256,.bg_adr
		move.w	#512,d0
		bsr	scroller_c2p
		dbra	d7,.loop
		
		rts

.scanline:	ds.b	512
.bg_adr:	dc.l	0

;convert 8bit chunky to 4bit planar
;parameters:
; a0 ptr to 8bit chunky pixels
; a1 ptr to 4bit planar
; d0 num pixels
scroller_c2p:
	movem.l	d0-d7/a0/a1,-(sp)
	lsr.w	#4,d0
	subq.w	#1,d0
.cp:
	clr.w	d1
	clr.w	d2
	clr.w	d3
	clr.w	d4
	move.w	#16-1,d6
.pix16:
	move.b	(a0)+,d7	;get chunky pixel
	lsl.b	#4,d7
	add.b	d7,d7
	addx.w	d1,d1
	add.b	d7,d7
	addx.w	d2,d2
	add.b	d7,d7
	addx.w	d3,d3
	add.b	d7,d7
	addx.w	d4,d4
	dbra	d6,.pix16

	move.w	d4,(a1)+
	move.w	d3,(a1)+
	move.w	d2,(a1)+
	move.w	d1,(a1)+	
	dbra	d0,.cp
	movem.l	(sp)+,d0-d7/a0/a1
	rts

;scale one line
;parameters:
; a0 ptr to destination 8bit chunky pixels
; d0 num pixels in source
; d1 num pixels in destination
scroller_scale:
	movem.l	d0-d4/a0,-(sp)
	ext.l	d0		;should already be word...
	swap	d0		;fixed point
	move.l	d0,d3		;save for start value
	divu	d1,d0		;dx, TODO: this should be inverted???
	lsr.l	#1,d3
	neg.l	d3		;start at -0.5x
	subq.w	#1,d1
.fill:
	move.l	d3,d2
	swap	d2
	move.w	d2,d4
;	and.b	#15,d4
	ext.l	d4
	add.l	#32767,d4
	divu	#20,d4
	swap	d4
	cmp	#15,d4
	ble.s	.nospace
	clr.w	d4
.nospace:

	move.b	d4,(a0)+
	add.l	d0,d3
	dbra	d1,.fill
	movem.l	(sp)+,d0-d4/a0
	rts

scroller_vbl_fadein:
		movem.l	scroller_setpal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		lea.l	scroller_setpal,a0
		lea.l	scroller_white,a1
		jsr	component_fade
		rts

scroller_vbl:
		movem.l	scroller_white,d0-d7
		movem.l	d0-d6,$ffff8240.w

		move.l	empty_adr,d0
		lea.l	$ffff8203.w,a0
		movep.l	d0,(a0)

		move.l	#scroller_zoomlist,scroller_zoomadr
		rts

;%%% Main %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

scroller_main:	
		add.l	#30,.scrollpos
		cmp.l	#30*(4096+300-274),.scrollpos
		blt.s	.noreset
		move.l	#30,.scrollpos
.noreset:	lea.l	scroller_font,a0
		add.l	.scrollpos,a0
		move.l	a0,scroller_font_adr
		;move.l	#scroller_font+30*400,scroller_font_adr

		; scroller movement in x 
		add.l	#48,.x4plsin
		and.l	#$1fff,.x4plsin
		lea.l	sincos4000,a0
		move.l	.x4plsin,d0
		move.w	(a0,d0.l),d1
               	muls.w	#95,d1
		asr.l	#8,d1
		asr.l	#7,d1
		add.l	#50,d1
		move.l	d1,d2
		and.b	#$0f,d2
		move.b	d2,scroller_hscrol
		and.l	#$fffffff0,d1
		asr.l	#1,d1
		move.l	d1,scroller_scanofs

		; zoom in and out
		add.l	#20,.y4plsin ;12
		and.l	#$1fff,.y4plsin
		lea.l	sincos4000,a0
		move.l	.y4plsin,d0
		move.w	(a0,d0.l),d1	;40 00

		; zoom = 2*sin(t)^4 - 1
		add.w	#$4000,d1
		rept	1
		mulu	d1,d1
		swap	d1
		endr
		muls	#500,d1
		lsr.l	#8,d1
		move.l	d1,d2		;zoomfactor = the line to use
		sub.l	#$4000,d1
		asr.l	#7,d1		;00 08 00
		asl.l	#8,d1		;*256 linewidth
		move.l	#scroller_bg_depack+256*128,scroller_bg_adr
		add.l	d1,scroller_bg_adr

		lea.l	scroller_zoomlist,a1

		neg.l	d2
		add.l	#$8000,d2
		mulu	#156,d2
		asr.l	#8,d2
		clr.l	d1			;y = 0
		clr.l	d5			;delta value, 2bits...
		move.l	#30,d5			;offset to next row
		move.w	#273-1,d7
.zoom:
		add.w	d2,d1		;inc y
		bcc.s	.nostep		;no
.step:					;yes
		move.l	d5,(a1)+	;move offset add to next line to adr ptr
		dbra	d7,.zoom
		rts	
.nostep:
		clr.l	(a1)+		;no offset add
		dbra	d7,.zoom
.done:
		rts
		
.bgofs:		dc.l	26
.x4plsin:	dc.l	0
.y4plsin:	dc.l	3000
.rastsin:	dc.l	0
.scrollpos:	dc.l	30*280
.scrollwait:	dc.w	2

;%%% Timer-A fullscreen %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

scroller_timer_a:	
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		clr.b	$fffffa19.w

		movem.l d0-a6,-(sp)
		dcb.w 	52-23,$4e71

		moveq.l	#0,d7			;1
		moveq.l	#2,d6			;1

		move.l	scroller_font_adr,a6	;5
		lea.l	$ffff8244.w,a2		;2

		lea.l	$ffff8203.w,a3		;2
		move.l	scroller_bg_adr,d5	;5
		move.l	scroller_scanofs,d0	;5
		add.l	d0,d5			;2
		
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
		dcb.w 	66-60-5,$4e71	

		move.l	scroller_zoomadr,a0	;5 yzoom
		addq.l	#4,scroller_zoomadr	;7
		add.l	(a0),a6			;4

		move.w	(a6),-2(a2)		;4
		movem.l	2(a6),d0-d3/a0-a1/a4	;18
		movem.l	d0-d3/a0-a1/a4,(a2)	;16

		move.b	scroller_hscrol,$ffff8265.w	;6

		jsr	generic_code		;5


		
		move.l	empty_adr,d0		;5
		movep.l	d0,(a3)			;6

		movem.l	scroller_white,d0-d7
		movem.l	d0-d7,-4(a2)

		clr.b	$ffff8265.w

		movem.l (sp)+,d0-a6
		move.w	#$2300,sr
		rts


scroller_code1_start:
;line 1-227
		;rept	227
		movep.l	d5,(a3)			;6
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		dcb.w	90-34,$4e71		;

		move.l	scroller_zoomadr,a0	;5 yzoom
		addq.l	#4,scroller_zoomadr	;7
		add.l	(a0),a6			;4
		movem.l	2(a6),d0-d3/a0-a1/a4	;18

		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3

		move.w	(a6),-2(a2)		;4
		movem.l	d0-d3/a0-a1/a4,(a2)	;16
		;endr
scroller_code1_end:		


scroller_code2_start:
;line 228
		movep.l	d5,(a3)			;6
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		dcb.w	90-38,$4e71		;

		move.l	scroller_zoomadr,a0	;5 yzoom
		addq.l	#4,scroller_zoomadr	;7
		add.l	(a0),a6			;4
		movem.l	2(a6),d0-d3/a0-a1/a4	;18
		move.w	(a6),-2(a2)		;4

		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3

		nop
		movem.l	d0-d3/a0-a1/a4,(a2)	;16
		movep.l	d5,(a3)			;6

;line 229
		;3 nops overflow from scanline above
		move.b	d7,$ffff820a.w		;3 60Hz
		move.b	d6,$ffff8260.w		;3 71Hz
		move.b	d7,$ffff8260.w		;3 60Hz
		move.b	d6,$ffff820a.w		;3 50Hz
		dcb.w	87-34,$4e71		;
		
		move.l	scroller_zoomadr,a0	;5 yzoom
		addq.l	#4,scroller_zoomadr	;7
		add.l	(a0),a6			;4
		movem.l	2(a6),d0-d3/a0-a1/a4	;18

		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		move.w	(a6),-2(a2)		;4
		movem.l	d0-d3/a0-a1/a4,(a2)	;16

scroller_code2_end:


scroller_code3_start:

; line 273
		movep.l	d5,(a3)			;6
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		dcb.w	90-34,$4e71		;

		move.l	scroller_zoomadr,a0	;5 yzoom
		addq.l	#4,scroller_zoomadr	;7
		add.l	(a0),a6			;4
		movem.l	2(a6),d0-d3/a0-a1/a4	;18

		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
scroller_code3_end:



;%%% Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		section	data

scroller_hscrol:	dc.w	0
scroller_scanofs:	dc.l	0
scroller_font_adr:	dc.l	scroller_font+30
scroller_fontlz77:	incbin	'scroller/font3.z77'		;lz77!
			even
		
scroller_bg_adr:	dc.l	scroller_bg_depack
			even

scroller_setpal:	dcb.w	16,$0000
scroller_white:		dcb.w	16,$0fff

scroller_zoomlist:	dcb.l	273,$00000000
scroller_zoomadr:	dc.l	scroller_zoomlist

		section	bss

scroller_zoomtab:	ds.w	256
scroller_scrolltext:	ds.w	273*2

p2c_buf:		ds.b	320
p2c_buf2:		ds.b	320

		section	text

