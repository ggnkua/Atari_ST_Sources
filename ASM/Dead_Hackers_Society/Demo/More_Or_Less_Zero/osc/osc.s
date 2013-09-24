; osc.s
;
; Simple oscilloscope effect with chunky area

osc_no_dma:	equ	0		;1=dma music is off, use fake oscdata instead


		section	text

;--- Init ----------------------------------------------------------------------------

osc_init:	lea	osc_tex_tga16,a0
		move.l	#32*32,d0
		bsr	convert_tga16_ste

		lea.l	osc_ofs,a0	;pre-add offset table
		move.w	#26*28-1,d7
.ofs:		move.w	(a0),d0
		add.w	d0,d0
		move.w	d0,(a0)+
		dbra	d7,.ofs

		rts

; Convert a TGA 16bit truecolor image to ST 12bit truecolor
; in: a0.l <-- ptr to 16 bit truecolor TGA
;     d0.w <-- length of image data
convert_tga16_ste:
		lea	18(a0),a1		;ptr to pixeldata
		lea	real2ste,a2
		sub	#1,d0
		blt	.nopixels
.copy:
		move.w	(a1)+,d1	;16bit rrrrr gggggg bbbbb
		ror.w	#8,d1
		move.w	d1,d2
		move.w	d1,d3
		and.w	#%11111,d1	;5 bit b
		lsr.w	#5,d2
		and.w	#%11111,d2	;6 bit g
		lsr.w	#5,d3
		lsr.w	#5,d3
		and.w	#%11111,d3	;5 bit r
		
		lsr.w	#1,d1		;4 bit b
		lsr.w	#1,d2		;4 bit g
		lsr.w	#1,d3		;4 bit r
		move.b	(a2,d1.w),d1			;convert to STe-palette format
		move.b	(a2,d2.w),d2
		move.b	(a2,d3.w),d3
		lsl.w	#4,d2
		lsl.w	#8,d3
		or.w	d2,d1
		or.w	d3,d1
		;not.w	d1
		move.w	d1,(a0)+
	
		dbra	d0,.copy

.nopixels:

		rts

real2ste:	dc.b	$8,$1,$9,$2,$a,$3,$b,$4,$c,$5,$d,$6,$e,$7,$f,$f
;real2ste:	dc.b	$0,$8,$1,$9,$2,$a,$3,$b,$4,$c,$5,$d,$6,$e,$7,$f

; Tile a 32x32 16bit truecolor image to 256x256
; in: a0.l destination 256x256 16 bit image
;     a1.l source 32x32 16bit image
tile_32_256:
	;	lea	osc_tex,a0
	;	lea	osc_tex_tga16,a1
		move.l	#256*256-1,d7
.tile:
		move.l	d7,d0
		not.w	d0
		and.w	#%0001111100011111,d0
		lsl.b	#3,d0
		lsr.w	#3,d0
		add.w	d0,d0
		move.w	(a1,d0.l),(a0)+
		dbra	d7,.tile
		rts

;--- Runtime Init ---------------------------------------------------------------------

osc_runtime_init:
		subq.w	#1,.once
		bne.w	.done

		jsr	black_pal
		jsr	clear_screens
		jsr	syncfix				;fix eventual bitplane corruption
		jsr	black_pal


		move.l	screen_adr,a0			;fill pattern
		move.w	#256-1,d7
.y:		move.w	#416/16-1,d6
		lea.l	osc_line,a1
.x:		move.l	(a1)+,(a0)
		addq.l	#8,a0
		dbra	d6,.x
		dbra	d7,.y

		move.l	screen_adr,a0
		add.l	#208*128,a0
		lea.l	208-8(a0),a1
		move.l	a0,a2
		move.l	a1,a3

		move.w	#128/16-1,d7			;mask pattern (slope)
.y2:
		move.w	#16-1,d5

		move.l	#$ffffffff,d0
		move.l	#$ffffffff,d1

.y3:
		move.w	.clrx,d6
		ble.s	.nox
		
.x2:		clr.l	(a0)
		clr.l	(a1)
		addq.l	#8,a0
		subq.l	#8,a1
		subq.w	#1,d6
		bgt.s	.x2
		;dbra	d6,.x2
.nox:
		not.l	d0
		not.l	d1
		and.l	d0,(a0)
		and.l	d1,(a1)
		not.l	d0
		not.l	d1
		lsl.w	#1,d0
		lsr.w	#1,d1
		swap	d0
		lsl.w	#1,d0
		swap	d1
		lsr.w	#1,d1

		lea.l	208(a2),a2
		move.l	a2,a0
		lea.l	208(a3),a3
		move.l	a3,a1

		dbra	d5,.y3
		subq.w	#1,.clrx
		dbra	d7,.y2

		move.l	screen_adr,a0
		add.l	#208*128,a0
		lea.l	-208(a0),a1
		move.w	#128-1,d7
.yy:		move.w	#208/4-1,d6
.xx:
		move.l	(a0)+,(a1)+
		dbra	d6,.xx
		lea.l	-416(a1),a1
		dbra	d7,.yy


		move.l	screen_adr,d0
		lea.l	osc_gfxtab,a0
		move.l	#256-1,d7
.tab:		move.l	d0,(a0)+
		add.l	#208,d0
		dbra	d7,.tab
		move.l	empty_adr,d0
		move.l	#280-1,d7
.tab2:		move.l	d0,(a0)+
		dbra	d7,.tab2


		jsr	clear_256k

		lea.l	osc_tex,a0
		lea.l	osc_tex_tga16,a1
		bsr.w	tile_32_256


;------------- copy overscan code
		lea.l	generic_code,a0

		move.l	#osc_code1_end,d0	;top 227 lines
		sub.l	#osc_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#227-1,d7
.code1a:	move.l	d0,d6
		lea.l	osc_code1_start,a1
.code1b:	move.w	(a1)+,(a0)+
		dbra	d6,.code1b
		dbra	d7,.code1a

		move.l	#osc_code2_end,d0	;2 midlines
		sub.l	#osc_code2_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#1-1,d7
.code2a:	move.l	d0,d6
		lea.l	osc_code2_start,a1
.code2b:	move.w	(a1)+,(a0)+
		dbra	d6,.code2b
		dbra	d7,.code2a

		move.l	#osc_code1_end,d0	;lower 44 lines (uses same code as top lines)
		sub.l	#osc_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#44-1,d7
.code3a:	move.l	d0,d6
		lea.l	osc_code1_start,a1
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
.clrx:		dc.w	8-1

;--- VBL ----------------------------------------------------------------------------

osc_vbl_in:
		bsr.w	osc_vbl
		tst.l	osc_gfxtabofs
		beq.s	.no
		subq.l	#4,osc_gfxtabofs
.no:
		rts


osc_vbl:
		lea.l	$ffff8203.w,a6
		move.l	empty_adr,d1
		movep.l	d1,(a6)

		movem.l	osc_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		rts

;--- Main ----------------------------------------------------------------------------

osc_main:	
		ifeq	osc_no_dma
		moveq.l	#0,d0
		move.b	$ffff8909.w,d0
		lsl.l	#8,d0
		move.b	$ffff890b.w,d0
		lsl.l	#8,d0
		move.b	$ffff890d.w,d0
		move.l	d0,audio
		endc

		ifne	osc_no_dma
		move.l	#osc_fake,audio
		endc

		bsr	osc_view_ofs

		
		rts
.var:		dc.l	0
audio:		dc.l	osc_line
		
osc_view_ofs:
		lea	osc_tex+(127*256+128)*2,a2
		add.w	osc_ofs_pos,a2
		add.w	#2+-512,osc_ofs_pos
		lea	osc_ofs,a1
		lea	osc_chunky,a0

		rept	26*28/8
		movem.w	(a1)+,d0-d7
		move.w	(a2,d0.w),(a0)+
		move.w	(a2,d1.w),(a0)+
		move.w	(a2,d2.w),(a0)+
		move.w	(a2,d3.w),(a0)+
		move.w	(a2,d4.w),(a0)+
		move.w	(a2,d5.w),(a0)+
		move.w	(a2,d6.w),(a0)+
		move.w	(a2,d7.w),(a0)+
		endr

		;move.w	#$0700,$ffff8240.w
		rts


;--- Timer A ------------------------------------------------------------------------------

osc_timer_a:	
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		clr.b	$fffffa19.w


		movem.l d0-a6,-(sp)
		dcb.w 	52-4,$4e71

		lea.l	$ffff8203.w,a6		;2
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
		dcb.w 	66-16-13-13-4-6-5,$4e71	;

		lea.l	osc_gfxtab+4*128,a4	;3
		add.l	osc_gfxtabofs,a4	;6
		move.l	audio,a5		;5
		lea.l	$ffff8242.w,a3		;2
		lea.l	osc_chunkyadrs,a1	;3
		move.l	#$0fff0fff,d2		;3
		;move.l	osc_rasters_adr1,a0	;5

		move.l	(a1),a2			;3
		move.w	4(a2),d3		;3	start of next line colour
		swap	d3			;1
		move.w	4(a2),d3		;3
		move.l	d3,(a3)			;3

		moveq.l	#0,d1			;1
		move.b	(a5),d1			;2
		addq.l	#1,a5			;2
		ext.w	d1			;1
		asl.w	#2,d1			;3
		move.l	(a4,d1.w),d0		;4

		;move.w	#$0812,$ffff8240.w	;4
		move.w	#$0000,$ffff8240.w	;4

		jsr	generic_code		;5
		

		move.l	empty_adr,d0
		movep.l	d0,(a6)

		clr.w	$ffff8240.w
		movem.l	.black,d0-d7
		movem.l	d0-d7,$ffff8240.w

		movem.l (sp)+,d0-a6
		move.w	#$2300,sr
		rts
.black:		dcb.w	16,$0000


;line 1-227
		;rept	227

osc_code1_start:
		movep.l	d0,(a6)
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
	ifeq	hatari
		dcb.w	4,$4e71			;
	endc
	ifne	hatari
		dcb.w	3,$4e71			;
	endc
		moveq.l	#0,d1			;1
		move.b	(a5)+,d1		;2
 		move.l	(a1)+,a2		;3
		move.w	46(a2),d2		;3	end of this line colour
		swap	d2			;1
		move.w	46(a2),d2		;3
		move.w	4(a2),d3		;3	start of next line colour
		swap	d3			;1
		move.w	4(a2),d3		;3 20
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5 85
	ifeq	hatari
		dcb.w	1,$4e71
	endc
	ifne	hatari
		dcb.w	2,$4e71
	endc
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3

		dcb.w	6,$4e71
		move.l	d2,(a3)			;3
		ext.w	d1			;1
		asl.w	#2,d1			;3
		move.l	(a4,d1.w),d0		;4
		move.l	d3,(a3)			;3
osc_code1_end:

		;endr

;line 228
osc_code2_start:
		movep.l	d0,(a6)			;6
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
	ifeq	hatari
		dcb.w	4,$4e71			;
	endc
	ifne	hatari
		dcb.w	3,$4e71			;
	endc
		move.l	(a1)+,a2		;3
		move.w	46(a2),d2		;3	end of this line colour
		swap	d2			;1
		move.w	46(a2),d2		;3
		move.w	4(a2),d3		;3	start of next line colour
		swap	d3			;1
		move.w	4(a2),d3		;3
		moveq.l	#0,d1			;1
		move.b	(a5)+,d1		;2 20
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5 85
	ifeq	hatari
		dcb.w	1,$4e71
	endc
	ifne	hatari
		dcb.w	2,$4e71
	endc
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		move.l	d2,(a3)			;3
		dcb.w	3,$4e71
		ext.w	d1			;1
		asl.w	#2,d1			;3
		move.l	(a4,d1.w),d0		;4
		move.l	d3,(a3)			;3
		movep.l	d0,(a6)			;3 + 3 on next line

;line 229
		;dcb.w	3,$4e71			;70
		move.b	d7,$ffff820a.w		;3 60Hz
		move.b	d6,$ffff8260.w		;3 71Hz
		move.b	d7,$ffff8260.w		;3 60Hz
		move.b	d6,$ffff820a.w		;3 50Hz
	ifeq	hatari
		nop
	endc
		move.l	(a1)+,a2		;3
		move.w	46(a2),d2		;3	end of this line colour
		swap	d2			;1
		move.w	46(a2),d2		;3
		move.w	4(a2),d3		;3	start of next line colour
		swap	d3			;1
		move.w	4(a2),d3		;3 
		moveq.l	#0,d1			;1
		move.b	(a5)+,d1		;2 20
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5
		move.l	(a2)+,(a3)		;5 85
	ifeq	hatari
		dcb.w	1,$4e71
	endc
	ifne	hatari
		dcb.w	2,$4e71
	endc
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		move.l	d2,(a3)			;3 
		dcb.w	20-14,$4e71

		ext.w	d1			;1
		asl.w	#2,d1			;3
		move.l	(a4,d1.w),d0		;4
		move.l	d3,(a3)			;3

osc_code2_end:



;--- Data ---------------------------------------------------------------------------------------------
		
		section	data

osc_ofs_pos:		dc.w	0
osc_gfxtabofs:		dc.l	0	;280*4
osc_ofs:		incbin	'osc/ofs.bin'	;word offset map
osc_tex_tga16:		incbin	'osc/tex3.tga'	;32x32 16-bit TGA

			ifne	osc_no_dma
osc_fake:		dcb.b	512,127
;q:			set	-128
;			rept	256
;			dc.b	q
;q:			set	q+1
;			endr
			endc

osc_chunkyadrs:
q:			set	0
			rept	27
			dc.l	osc_chunky+q*52
			dc.l	osc_chunky+q*52
			dc.l	osc_chunky+q*52
			dc.l	osc_chunky+q*52
			dc.l	osc_chunky+q*52
			dc.l	osc_chunky+q*52
			dc.l	osc_chunky+q*52
			dc.l	osc_chunky+q*52
			dc.l	osc_chunky+q*52
			dc.l	osc_chunky+q*52
q:			set	q+1
			endr
		
			dc.l	osc_chunky+q*52
			dc.l	osc_chunky+q*52
			dc.l	osc_chunky+q*52
			dc.l	osc_chunky+q*52
			dc.l	osc_chunky+q*52

osc_line:
			rept	11
			;	 0123456789abcdef

			dc.w	%1111111000000000
			dc.w	%0000000111111111
			
			dc.w	%0111111111100000
			dc.w	%1000000000011111
			
			dc.w	%0000011111111110
			dc.w	%1111100000000001
			
			dc.w	%0000000001111111
			dc.w	%1111111110000000
			
			dc.w	%1110000000000111
			dc.w	%0001111111111000

			endr

osc_pal:		dcb.w	16,$0000

		section	text
