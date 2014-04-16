; Altparty 2009 STe demo
; Fullscreen shaded vectors
;
; shadevec.s

see_cpu:	equ	0

		section	text

;-------------- INIT
shadevec_init:	rts
		
;-------------- RUNTIME INIT
shadevec_runtime_init:
		subq.w	#1,.once
		bne.w	.done

		jsr	black_pal
		jsr	clear_screens
		jsr	syncfix				;fix eventual bitplane corruption
		jsr	black_pal

		ifne	init_finish
		move.w	#$0700,$ffff8240.w
		endc

		lea.l	shadevec_slope_ice,a0		;depack 4pl slope
		lea.l	shadevec_slope,a1
		bsr.w	ice

		lea.l	shadevec_scanlines_ice,a0	;depack animation data
		lea.l	shadevec_scanlines,a1
		bsr.w	ice

		bsr	shadevec_calc_y_scale

		;overscan code copy
		lea.l	generic_code,a0
		move.l	#shadevec_code1_end,d0		;top 227 lines
		sub.l	#shadevec_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#227-1,d7
.code1a:	move.l	d0,d6
		lea.l	shadevec_code1_start,a1
.code1b:	move.w	(a1)+,(a0)+
		dbra	d6,.code1b
		dbra	d7,.code1a

		move.l	#shadevec_code2_end,d0		;2 midlines
		sub.l	#shadevec_code2_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#1-1,d7
.code2a:	move.l	d0,d6
		lea.l	shadevec_code2_start,a1
.code2b:	move.w	(a1)+,(a0)+
		dbra	d6,.code2b
		dbra	d7,.code2a

		move.l	#shadevec_code1_end,d0		;lower 44 lines (uses same code as top lines)
		sub.l	#shadevec_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#44-1,d7
.code3a:	move.l	d0,d6
		lea.l	shadevec_code1_start,a1
.code3b:	move.w	(a1)+,(a0)+
		dbra	d6,.code3b
		dbra	d7,.code3a
		move.w	dummy,(a0)+	;rts

		;calculate palette shades
		;white -> pal
.pw:		lea.l	shadevec_white,a0
		lea.l	shadevec_pal,a1
		bsr.w	component_fade
		lea.l	shadevec_fade,a0
		add.l	.shadepos,a0
		add.l	#32,.shadepos
		movem.l	shadevec_white,d0-d7
		movem.l	d0-d7,(a0)
		subq.w	#1,.pwcount
		bpl.s	.pw

		;pal -> black
.pb:		lea.l	shadevec_white,a0
		lea.l	shadevec_black,a1
		bsr.w	component_fade
		lea.l	shadevec_fade,a0
		add.l	.shadepos,a0
		add.l	#32,.shadepos
		movem.l	shadevec_white,d0-d7
		movem.l	d0-d7,(a0)
		subq.w	#1,.pbcount
		bpl.s	.pb

		ifne	init_finish
		move.w	#$0070,$ffff8240.w
		endc

.done:		rts
.once:		dc.w	1
.shadepos:	dc.l	0
.pwcount:	dc.w	48-1
.pbcount:	dc.w	48-1

		;calculate add table for y scaling
shadevec_calc_y_scale:
		lea	shadevec_addtab,a0
		move.w	#128-1,d6	;y scale value
.sv:
		move.w	d6,d0
		add.w	#273-128,d0
		move.l	#(273-20)<<8,d1	;FIXME: 20 is magic!
		divu	d0,d1
		clr.l	d0		
		move.w	#274-1,d7	;274 scanlines to calc
.cy:
		move.w	d0,d2	;last row
		lsr.w	#8,d2
		add.w	d1,d0	;curr row
		move.w	d0,d3
		lsr.w	#8,d3
		sub.w	d2,d3
;		subq.w	#1,d3	;compensate for inc in objdata
		move.w	d3,(a0)+
		dbra	d7,.cy
		dbra	d6,.sv
		rts

;-------------- VBL
shadevec_vbl:
		move.l	empty_adr,d0
		lea.l	$ffff8203.w,a0
		movep.l	d0,0(a0)

		movem.l	shadevec_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		;animating the vector object
		cmp.l	#(100-2)*273,shadevec_frame
		blt.s	.add
		move.l	#-273,shadevec_frame
.add:		add.l	#273,shadevec_frame

		bsr	shadevec_scale_calc

		;copy the current frame to display list
		lea	shadevec_scanlines,a0
		add.l	shadevec_frame,a0
		lea	shadevec_displist,a1
		lea	shadevec_addtab,a2
		
		move.l	shadevec_scale,d1
		asr.l	#2,d1		;de pre shift, 2steps...
		add.w	#64,d1		;0->127
		move.w	d1,d2
		mulu	#274,d1
		add.l	d1,a2
		add.l	d1,a2
		clr.l	d6
		move.w	#273,d7
		sub.w	d2,d7

		;fill with zero, upper and lower part
		move.b	#207,d4		;scanline 207 is 'black'
		lsr.w	#1,d2
	;	subq.w	#1,d2
		tst.w	d2
		blt.s	.noz0
		lea	(a1,d2),a3	;lower part
		lea	(a3,d7),a3
.z0:
		move.b	d4,(a1)+
		move.b	d4,(a3)+
		dbra	d2,.z0
.noz0:		

		;fill graphics
.cd:
		move.b	(a0),(a1)+	;3 get address to first scanline
		add.w	(a2)+,a0	;skip scans -> zoom/scale
		dbra	d7,.cd

		ifne	see_cpu
		move.w	#$0300,$ffff8240.w
		endc
		rts

shadevec_fadeout:
		bsr	shadevec_vbl
		cmp.w	#334*4,shadevec_palpos
		bge.s	.done
		addq.w	#4,shadevec_palpos
.done:		rts

shadevec_fadein:
		bsr	shadevec_vbl
		cmp.w	#208*4,shadevec_palpos
		ble.s	.done
		subq.w	#4,shadevec_palpos
.done:		rts

shadevec_scale_calc:
		add.w   #16,.sin
		and.w   #$1fff,.sin
		lea	sincos4000,a0
		move.w  .sin,d0
		move.w  (a0,d0.w),d1	;$4000
		muls	#127,d1
		asr.l   #8,d1
		asr.l   #7,d1		;$0040 = 64
		asl.l	#2,d1		;preshift for LUT
		move.l	d1,shadevec_scale
		
.no:
		rts
.sin:		dc.w	0

;-------------- MAIN
shadevec_main:
		rts

;-------------- TIMER A
shadevec_timer_a:	
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

		dcb.w 	66-38,$4e71	

		moveq.l	#2,d7				;1	for overscan flips
		lea.l	$ffff8203.w,a6			;2	
		lea.l	shadevec_displist,a5		;3
		lea.l	shadevec_lut,a4			;3	lookuptable for absolut addresses
		add.l	shadevec_scale,a4		;6
		lea.l	shadevec_pals,a3		;3	
		add.w	shadevec_palpos,a3		;5
		lea.l	$ffff8244.w,a2			;2

		moveq.l	#0,d1				;1	get address in d0 to the first scanline to display
		move.b	(a5)+,d1			;2
		move.l	empty_adr,d0			;5

		jsr	generic_code			;5

		movem.l (sp)+,d0-a6
		move.w	#$2300,sr
		rts


shadevec_code1_start:
		movep.l	d0,0(a6)		;6
		move.b	d7,$ffff8260.w		;3
		move.w	d7,$ffff8260.w		;3
		dcb.w	90-38,$4e71
		;scanline gfx
		moveq.l	#0,d1			;1
		move.b	(a5)+,d1		;2
		lsl.w	#2,d1			;3
		move.l	(a4,d1.w),d0		;5
		;raster
		move.l	(a3,d1.w),a1		;5
		movem.l	4(a1),d1-d6/a0		;18
		move.w	2(a1),-2(a2)		;5
		move.w	d7,$ffff820a.w		;3
		move.b	d7,$ffff820a.w		;3
		dcb.w	20-16,$4e71
		movem.l	d1-d6/a0,(a2)		;16
shadevec_code1_end:

shadevec_code2_start:
		movep.l	d0,0(a6)		;6
		move.b	d7,$ffff8260.w		;3
		move.w	d7,$ffff8260.w		;3
		dcb.w	90-38,$4e71
		;scanline gfx
		moveq.l	#0,d1			;1
		move.b	(a5)+,d1		;2
		lsl.w	#2,d1			;3
		move.l	(a4,d1.w),d0		;5
		;raster
		move.l	(a3,d1.w),a1		;5
		movem.l	4(a1),d1-d6/a0		;18
		move.w	2(a1),-2(a2)		;5
		move.w	d7,$ffff820a.w		;3
		move.b	d7,$ffff820a.w		;3
		dcb.w	17-16,$4e71
		movem.l	d1-d6/a0,(a2)		;16
		
		movep.l	d0,0(a6)		;3+ 3 on next line
;line 229	;3 nops from previous line
		move.w	d7,$ffff820a.w		;3
		move.b	d7,$ffff8260.w		;3
		move.w	d7,$ffff8260.w		;3
		move.b	d7,$ffff820a.w		;3
		dcb.w	87-38,$4e71
		;scanline gfx
		moveq.l	#0,d1			;1
		move.b	(a5)+,d1		;2
		lsl.w	#2,d1			;3
		move.l	(a4,d1.w),d0		;5
		;raster
		move.l	(a3,d1.w),a1		;5
		movem.l	4(a1),d1-d6/a0		;18
		move.w	2(a1),-2(a2)		;5
		move.w	d7,$ffff820a.w		;3
		move.b	d7,$ffff820a.w		;3
		dcb.w	20-16,$4e71
		movem.l	d1-d6/a0,(a2)		;16

shadevec_code2_end:




		section	data


shadevec_white:		dc.w	0
			dcb.w	15,$0fff
shadevec_black:		dcb.w	16,$0000

shadevec_palpos:	dc.w	334*4

shadevec_pals:
			rept	208
			dc.l	shadevec_fade
			endr
			rept	30
			dc.l	shadevec_fade
			endr
q:			set	0
			rept	96
			dc.l	shadevec_fade+q*32
q:			set	q+1
			endr
			rept	90+208
			dc.l	shadevec_fade+32*95
			endr

shadevec_frame:		dc.l	0
shadevec_scale:		dc.l	0

			rept	208
			dc.l	shadevec_slope
			endr
shadevec_lut:
q:			set	0
			rept	208
			dc.l	shadevec_slope+208*q
q:			set	q+1
			endr

			rept	208
			dc.l	shadevec_slope+208*207
			endr

shadevec_scanlines_ice:
			incbin	'shadevec/minima.ice'
			even

shadevec_slope_ice:	incbin	'shadevec/slope.ice'
			even

			
shadevec_pal:		
			;dc.w	$0000,$0F53,$07C3,$0E4A,$06BA,$0D32,$05A2,$0C29
			;dc.w	$0499,$0C22,$05AA,$0D33,$0633,$0EBB,$0744,$0FCC
	
			dc.w	$0000,$0819,$0192,$092A,$02A3,$023B,$0AB4,$034C
			dc.w	$0BC5,$045D,$0CD6,$056E,$056E,$0DE7,$067F,$0E7F	
			
			;dc.w	$0000,$0119,$0992,$0A2A,$03A3,$0B3B,$04B4,$0C4C
			;dc.w	$05C5,$055D,$0D5D,$0DD6,$06D6,$06DE,$0E67,$07EF
		section	text
