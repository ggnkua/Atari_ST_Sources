; Screen routines based on Earx's ones

; ------------------------------------------------------
		section	text
; ------------------------------------------------------

; ******************************************************
; ******************* Videl routines *******************
; ******************************************************

; Changes screenresolution the fast way..
; Note: Takes one vbl, necessary to avoid monochrome sync errors.
; INPUT: a0: address of scp buffer
set_res_scp:	lea	122(a0),a0
		move.l	(a0)+,$ffff8282.w
		move.l	(a0)+,$ffff8286.w
		move.l	(a0)+,$ffff828a.w
		move.l	(a0)+,$ffff82a2.w
		move.l	(a0)+,$ffff82a6.w
		move.l	(a0)+,$ffff82aa.w
		move.w	(a0)+,$ffff820a.w
		move.w	(a0)+,$ffff82c0.w
		clr.w	$ffff8266.w
		tst.w	(a0)+
		bne.b	.st

.falcon:	move.w	(a0)+,$ffff8266.w
		bra.b	.skip

.st:		addq.l	#1,a0
		move.b	(a0)+,$ffff8260.w
		
.skip:		move.w	(a0)+,$ffff82c2.w
		move.w	(a0)+,$ffff8210.w
		rts
		
; Sets a new falcon palette
; INPUT: a1: palette
set_palette:	lea	$ffff9800.w,a0
		moveq	#128-1,d7
.loop:		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		dbra	d7,.loop
		rts
		
; Clears a Falcon palette
blackpal:	lea	$ffff9800.w,a0
		moveq	#128-1,d7
.loop:		clr.l	(a0)+
		clr.l	(a0)+
		dbra	d7,.loop
		rts
		
; *******************************************************
; ********** High color pixelhandling routines **********
; *******************************************************

; Doubles high color bitmap in vertical direction.
; (1*1) -> (1*2)
; INPUT: d0.w: width of buffer
;        d1.w: height of buffer
;        a0: destination buffer
;        a1: source buffer
double_pix_v:	subq.w	#1,d1
		bmi.s	.end
		move.w	d0,d2
		ble.s	.end
		subq.w	#1,d2
		ext.l	d0
		add.l	d0,d0
		lea	(a0,d0.l),a2
.yloop:		move.w	d2,d7
.xloop:		move.w	(a1),(a0)+
		move.w	(a1)+,(a2)+
		dbra	d7,.xloop
		adda.l	d0,a0
		adda.l	d0,a2
		dbra	d1,.yloop
.end:		rts

; Doubles high color bitmap in horizontal direction.
; (1*1) -> (2*1)
; INPUT: d0.w: width of buffer
;        d1.w: height of buffer
;        a0: destination buffer
;        a1: source buffer
double_pix_h:	subq.w	#1,d1
		bmi.s	.end
		move.w	d0,d2
		ble.s	.end
		subq.w	#1,d2
.yloop:		move.w	d2,d7
.xloop:		move.w	(a1),(a0)+
		move.w	(a1)+,(a0)+
		dbra	d7,.xloop
		dbra	d1,.yloop
.end:		rts

; Doubles high color bitmap in horizontal and vertical direction.
; (1*1) -> (2*2)
; INPUT: d0.w: width of buffer
;        d1.w: height of buffer
;        a0: destination buffer
;        a1: source buffer
double_pix:	subq.w	#1,d1
		bmi.s	.end
		move.w	d0,d2
		ble.s	.end
		subq.w	#1,d2
		ext.l	d0
		lsl.l	#2,d0
		lea	(a0,d0.l),a2
.yloop:		move.w	d2,d7
.xloop:		move.w	(a1)+,d0
		move.w	d0,(a0)+
		move.w	d0,(a0)+
		move.w	d0,(a2)+
		move.w	d0,(a2)+
		dbra	d7,.xloop
		adda.l	d0,a0
		adda.l	d0,a2
		dbra	d1,.yloop
.end:		rts

; Mirrors high color bitmap along X axis
; INPUT: d7.w: height
;        d6.w: width
;        a0:   source buffer
;        a1:   destination buffer
mirror_x:	subq.w	#1,d7

.yloop:		move.w	d6,d5
		subq.w	#1,d5
		lea	(a1,d6.w*2),a1			; end of line
		
.xloop:		move.w	(a0)+,-(a1)
		dbra	d5,.xloop

		lea	(a1,d6.w*2),a1			; next line
		dbra	d7,.yloop
		rts
		
; Mirrors high color bitmap along Y axis
; INPUT: d7.w: height
;        d6.w: width
;        a0:   source buffer
;        a1:   destination buffer
mirror_y:	subq.w	#1,d7
		move.w	d6,d5
		mulu.w	d7,d5				; width*(height-1)
		lea	(a1,d5.l*2),a1			; last line

.yloop:		move.w	d6,d5
		subq.w	#1,d5

.xloop:		move.w	(a0)+,(a1)+
		dbra	d5,.xloop
		
		move.w	d6,d5
		lsl.w	#2,d5
		suba.w	d5,a1
		dbra	d7,.yloop
		rts
		
; Copies source picture to destination one
; INPUT: d7.w: height
;        d6.w: width
;        a0:   source buffer
;        a1:   destination buffer
copy_pic:	subq.w	#1,d7

.yloop:		move.w	d6,d5
		subq.w	#1,d5
		
.xloop:		move.w	(a0)+,(a1)+
		dbra	d5,.xloop
		
		dbra	d7,.yloop
		rts
		
; Sets new background colour
; INPUT: d0.w HC colour
set_background:	move.w	d0,background_colour
		rts
		
; Clears 300x200 or 300x100 high color screen
; INPUT: a0:   screen address
movem_screen_clear:
		tst.w	half_y_flag
		beq.w	.hires
		
.lowres:	andi.w	#%1101111111111111,sr		; S = 0 -> User mode
		move.l	a7,save_usp			; save User SP

		adda.l	#300*200*2/2,a0
		move.w	background_colour,d0		; d0.l: $xxxxcccc
		move.w	d0,d1				; d1.l: $xxxxcccc
		swap	d0				; d0.l: $ccccxxxx
		move.w	d1,d0				; d0.l: $cccccccc
		move.l	d0,d1
		move.l	d0,d2
		move.l	d0,d3
		move.l	d0,d4
		move.l	d0,d5
		move.l	d0,d6
		movea.l	d0,a1
		movea.l	d0,a2
		movea.l	d0,a3
		movea.l	d0,a4
		movea.l	d0,a5
		movea.l	d0,a6
		movea.l	d0,a7
		moveq	#(34/2)-1,d7
		
.loop1:		REPT	63
		movem.l	d0-d6/a1-a7,-(a0)
		ENDR
		dbra	d7,.loop1
		movem.l	d0-d5,-(a0)
		
		movea.l	save_usp,a7			; restore user SP
		trap	#0				; switch to supervisor
		rts
		
.hires:		andi.w	#%1101111111111111,sr		; S = 0 -> User mode
		move.l	a7,save_usp			; save User SP

		adda.l	#300*200*2,a0
		move.w	background_colour,d0		; d0.l: $xxxxcccc
		move.w	d0,d1				; d1.l: $xxxxcccc
		swap	d0				; d0.l: $ccccxxxx
		move.w	d1,d0				; d0.l: $cccccccc
		move.l	d0,d1
		move.l	d0,d2
		move.l	d0,d3
		move.l	d0,d4
		move.l	d0,d5
		move.l	d0,d6
		movea.l	d0,a1
		movea.l	d0,a2
		movea.l	d0,a3
		movea.l	d0,a4
		movea.l	d0,a5
		movea.l	d0,a6
		movea.l	d0,a7
		moveq	#(34)-1,d7
		
.loop:		REPT	63
		movem.l	d0-d6/a1-a7,-(a0)
		ENDR
		dbra	d7,.loop
		movem.l	d0-d6/a1-a5,-(a0)
		
		movea.l	save_usp,a7			; restore user SP
		trap	#0				; switch to supervisor
		rts
				
; ******************************************************
; ************* Bitmap conversion routines *************
; ******************************************************

; Converts 24 bit true color palette to 16 bit high color one
; INPUT: d7.l: #entries
;        a0: dst hc palette (%rrrrrggggggbbbbb)
;        a1: src tc palette ($rrggbb)
convert_tcpal:	subq.l	#1,d7
		bmi.s	.end
		swap	d7
		move.w	#$F800,d3
		move.w	#$07E0,d4
.outerloop:	swap	d7
.innerloop:	clr.l	d1
		move.b	(a1)+,d0
		move.b	(a1)+,d1
		move.b	(a1)+,d2
		lsl.w	#8,d0
		lsl.w	#3,d1
		lsr.b	#3,d2
		and.w	d3,d0
		and.w	d4,d1
		or.w	d1,d0
		or.b	d2,d0
		move.w	d0,(a0)+
		dbf	d7,.innerloop
		swap	d7
		dbf	d7,.outerloop
.end:		rts

; Converts a picture in BP format to high color one
; INPUT: d0.w: width
;        d1.w: height
;        d2.w: #bitplanes
;        a0: dst high color picture
;        a1: src BP picture
;        a2: high color pal (2^#bitplanes entries)
convert_bp2hc:	lsr.w	#4,d0				; width/16
		subq.w	#1,d1
		bmi.s	.end
		move.w	d0,d7				; d7.w=width
		beq.s	.end
		subq.w	#1,d7
		subq.w	#1,d2
		movea.w	d2,a6				; a6=#bitplanes-1
.yloop:		move.w	d7,d0
.xloop:		moveq	#16-1,d6
.pixel_loop:	move.l	a6,d5				; d5.w=#bitplanes-1
		lea	2(a1,d5.w*2),a3			; a3: next chunk
		clr.l	d3				; d3.b=pixel
.plane_loop:	add.b	d3,d3				; d3.b=pixel=oldpixel<<1
		move.w	-(a3),d2
		lsr.w	d6,d2
		andi.b	#1,d2				; d2.w=masked bit
		or.b	d2,d3				; d3.b=pixel|masked bit
		dbf	d5,.plane_loop
		move.w	(a2,d3.l*2),(a0)+		; Store pixel.
		dbf	d6,.pixel_loop
		lea	2(a1,a6.l*2),a1			; a1: next chunk
		dbf	d0,.xloop
		dbf	d1,.yloop
.end:		rts

; Converts BP picture into classic chunky one (colour 0 = $00 etc)
; INPUT: d0.w: width
;        d1.w: height
;        d2.w: #bitplanes
;        a0: dst chunky picture (hibyte: offset lobyte: $00)
;        a1: src BP picture
convert_p2c:	lsr.w	#4,d0				; width/16
		subq.w	#1,d1
		bmi.s	.end
		move.w	d0,d7				; d7.w=width
		beq.s	.end
		subq.w	#1,d7
		subq.w	#1,d2
		movea.w	d2,a6				; a6=#bitplanes-1
.yloop:		move.w	d7,d0
.xloop:		moveq	#16-1,d6
.pixel_loop:	move.l	a6,d5				; d5.w=#bitplanes-1
		lea	2(a1,d5.w*2),a3			; a3: next chunk
		clr.l	d3				; d3.b=pixel
.plane_loop:	add.b	d3,d3				; d3.b=pixel=oldpixel<<1
		move.w	-(a3),d2
		lsr.w	d6,d2
		andi.b	#1,d2				; d2.w=masked bit
		or.b	d2,d3				; d3.b=pixel|masked bit
		dbf	d5,.plane_loop
		;lsl.w	#8,d3				; prepare for lighting
		move.w	d3,(a0)+			; store palette offset
		;move.b	d3,(a0)+
		dbf	d6,.pixel_loop
		lea	2(a1,a6.l*2),a1			; a1: next chunk
		dbf	d0,.xloop
		dbf	d1,.yloop
.end:		rts

; INPUT:  d4.w: src/dst colour (hc format)
;         d5.w: 0 = fade in (src -> colour), 1 = fade out (colour -> dst)
;         d6.w: number of shades
;         d7.l: number of colours
;         a0:   src hc palette (number of colours entries)
;         a1:   dst shadetab: WORD lookupTable[i][j]: i = 0 ~ number of shades - 1
;                                                     j = 0 ~ number of colours - 1
generate_shadetab:
		move.w	d4,d0
		lsr.w	#(11-8),d0
		and.w	#$1f00,d0			; r << 8
		move.w	d0,fade_r
		
		move.w	d4,d0
		lsl.w	#(8-5),d0
		and.w	#$3f00,d0			; g << 8
		move.w	d0,fade_g
		
		move.w	d4,d0
		lsl.w	#(8-0),d0
		and.w	#$1f00,d0			; b << 8
		move.w	d0,fade_b

		tst.w	d5
		bne.w	shadetab_fade_out
		
shadetab_fade_in:
		move.l	d7,d3				; d3.l: number of colours
		subq.l	#1,d7
		
.colour:	move.w	(a0)+,d0			; d0.w: r:g:b [5:6:5] (base colour)
		move.w	d0,d1
		move.w	d0,d2
		lsr.w	#(11-8),d0
		lsl.w	#(8-5),d1
		lsl.w	#(8-0),d2
		and.w	#$1f00,d0			; d0.w: base r << 8
		and.w	#$3f00,d1			; d1.w: base g << 8
		and.w	#$1f00,d2			; d2.w: base b << 8
		
		move.w	#$0080,fade_add_r		; 0.5 << 8
		move.w	#$0100,fade_add_g		; 1.0 << 8
		move.w	#$0080,fade_add_b		; 0.5 << 8
		
		move.w	fade_r,d4
		cmp.w	d4,d0
		bpl.b	.red_add_ok
		neg.w	fade_add_r
.red_add_ok:	move.w	d0,fade_final_r
		move.w	d4,d0				; d0.w: starting r << 8
		
		move.w	fade_g,d4
		cmp.w	d4,d1
		bpl.b	.green_add_ok
		neg.w	fade_add_g
.green_add_ok:	move.w	d1,fade_final_g
		move.w	d4,d1				; d1.w: starting g << 8

		move.w	fade_b,d4
		cmp.w	d4,d2
		bpl.b	.blue_add_ok
		neg.w	fade_add_b
.blue_add_ok:	move.w	d2,fade_final_b
		move.w	d4,d2				; d2.w: starting b << 8

		move.w	d6,d5
		subq.w	#1,d5
		movea.l	a1,a2
		
.shade:		move.w	d0,d4
		clr.b	d4
		lsl.w	#(11-8),d4
		move.w	d4,(a2)
		
		move.w	d1,d4
		clr.b	d4
		lsr.w	#(8-5),d4
		or.w	d4,(a2)
		
		move.w	d2,d4
		clr.b	d4
		lsr.w	#(8-0),d4
		or.w	d4,(a2)
		
		cmp.w	fade_final_r,d0
		beq.b	.red_done
		add.w	fade_add_r,d0
		
.red_done:	cmp.w	fade_final_g,d1
		beq.b	.green_done
		add.w	fade_add_g,d1
		
.green_done:	cmp.w	fade_final_b,d2
		beq.b	.blue_done
		add.w	fade_add_b,d2

.blue_done:	lea	(a2,d3.l*2),a2			; move to the next shade
		dbra	d5,.shade

		addq.l	#2,a1				; next colour
		dbra	d7,.colour
		rts

shadetab_fade_out:
		rts
		
; ------------------------------------------------------
		section	data
; ------------------------------------------------------

hc_rgb_300x200:	incbin	'sys\scp\300x200r.scp'
		even
hc_vga_300x200:	incbin	'sys\scp\300x200v.scp'
		even
hc_rgb_300x100:	incbin	'sys\scp\300x100r.scp'
		even
hc_vga_300x100:	incbin	'sys\scp\300x100v.scp'
		even

; ------------------------------------------------------
		section	bss
; ------------------------------------------------------

fade_r:		ds.w	1
fade_g:		ds.w	1
fade_b:		ds.w	1

fade_add_r:	ds.w	1
fade_add_g:	ds.w	1
fade_add_b:	ds.w	1

fade_final_r:	ds.w	1
fade_final_g:	ds.w	1
fade_final_b:	ds.w	1

background_colour:
		ds.w	1
		
; ------------------------------------------------------
		section	text
; ------------------------------------------------------