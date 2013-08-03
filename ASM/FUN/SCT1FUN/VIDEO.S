; Sector One Falcon Video System
; 2001 - Zerkman * Sector One

	section	text

; Call the library code in code in supervisor mode
	pea	super(pc)
	move	#$26,-(sp)	; Supexec
	trap	#14
	addq.l	#6,sp

	clr	-(sp)
	trap	#1


super
	lea	zv(pc),a6

; Save the screen address
	move.l	$ffff8200.w,d0
	lsl	#8,d0
	move.b	$ffff820d.w,d0
	move.l	d0,-(sp)

; Save the ST video mode
	bra.s	iv_falc
	move.b	$ffff8260.w,svg_rez-zv(a6)

; Test if we're in a ST-compatible video mode
	pea	$58ffff		; XBIOS 88 mode
	trap	#14
	addq.l	#4,sp

	move.w	d0,d1
	and.w	#7,d1		; log2( number of bits/pixel )
	cmp.w	#1,d1		; 4 colours mode ?
	beq.s	iv_st		; Yes -> it's a ST compatible mode
	cmp.w	#2,d1		; 16 coulours ?
	bne.s	iv_falc		; No -> It's a Falcon mode
	btst	#7,d0		; ST Mode ?
	bne.s	iv_st		; Yes -> It's a ST 16 colours mode
iv_falc
	st	svg_rez-zv(a6)	; No -> mode = -1
iv_st

; Save the Falcon video mode
	lea	svg_flc(pc),a0	; save buffer for the Falcon regs
	lea	vecteurs_mode(pc),a1	; array of the video regs addresses

iv_svgbcl
	move.w	(a1)+,d0	; register's address
	beq.s	iv_fin_svgbcl
	move.w	d0,a3		; == ext.l
	move.w	(a3),(a0)+	; save the register
	bra.s	iv_svgbcl
iv_fin_svgbcl

; Save the Falcon palette registers
	lea	$ffff9800.w,a0
	lea	svg_pal(pc),a1
	move	#255,d0
iv_svgpalbcl
	move.l	(a0)+,(a1)+
	dbra	d0,iv_svgpalbcl

; Save the VBL pointer
	move.l	$70.w,-(sp)

****** End of init sequence *************
; Execute the main code
	bsr	main_code


****** Begin of restore sequence *************
; restore the VBL pointer
	move.l	(sp)+,$70.w

; restore the Falcon palette
	lea	$ffff9800.w,a0
	lea	svg_pal(pc),a1
	move	#255,d0
rv_rstpalbcl
	move.l	(a1)+,(a0)+
	dbra	d0,rv_rstpalbcl

; Restore the Falcon video mode
	move.b	svg_rez(pc),d1	; Previous ST mode value
	lea	svg_flc(pc),a0
	lea	vecteurs_mode(pc),a1	; video regs address array
rv_rstbcl
	move.w	(a1)+,d2	; reg address
	beq.s	rv_fin_rst

	move.w	d2,a2		; copy to addr reg. + ext.l
	cmp	#$8266,d2	; Spshift (Falcon video mode) ?
	bne.s	rv_rstbok	; No, let's go on

	tst.b	d1		; Test if we must restore the ST mode
	bmi.s	rv_pas_st	; if < 0, it's a Falcon mode.
	addq.l	#2,a0		; bypass the unuseful Spshift value
	move.b	d1,$ffff8260.w	; Restoration of the correct ST mode
	move	#$007,$ffff8240.w
	bra.s	rv_rstbcl

rv_pas_st
	btst	#10-8,(a0)	; 2 colours mode ?
	beq.s	rv_rstbok
	clr.w	(a2)		; first switch to 16 colours mode
	move.l	$466.w,d0	; wait a VBL, thus the restoration
rvw	cmp.l	$466.w,d0	; will be successfully performed.
	beq.s	rvw		;
rv_rstbok
	move.w	(a0)+,(a2)	; Restoration of the saved value
	bra.s	rv_rstbcl

rv_fin_rst

; Restore the screen address
	move.l	(sp)+,d0
	move.b	d0,d1
	lsr	#8,d0
	move.l	d0,$ffff8200.w
	move.b	d1,$ffff820d.w

; exit the program
	moveq	#0,d0
	rts

; Change the current video mode.
; d0 = number of video mode in either the VGA or RGB table, depending on
; the used monitor.
set_video_mode
	lea	vga_modes(pc),a0
	btst	#6,$ffff8006.w
	beq.s	.ok_vga
	lea	rgb_modes(pc),a0
.ok_vga
	move.l	(a0,d0.w*4),a0
	lea	vecteurs_mode(pc),a1
.bcl
	move.w	(a1)+,d0
	beq.s	.fin
	move.w	d0,a2
	move.w	(a0)+,(a2)
	bra.s	.bcl
.fin
	rts


	section data
; *** Video modes tables
vga_modes
	dc.l	vga_160x100_tc, vga_320x200_tc, vga_640x480_tc
rgb_modes
	dc.l	0

; 160x100 true color VGA
vga_160x100_tc
	dc.w	$6A,$46,$12,$25D,$46,$53,$245,$1FD,$6d,$6d,$1FD,$23F,$100,$0,$A0,$1,$186
vga_320x200_tc
	dc.w	$D5,$8E,$25,$2CB,$8E,$A6,$247,$1F5,$65,$65,$1F5,$241,$100,$0,$140,$4,$186
vga_640x480_tc
	dc.w	$18F,$151,$62,$31,$151,$160,$3EB,$3D1,$11,$11,$3D1,$3E5,$100,$0,$280,$4,$182

vecteurs_mode
	dc.w	$8282,$8284,$8286,$8288,$828A,$828C,$82A2,$82A4,$82A6,$82A8,$82AA,$82AC,$8266,$820E,$8210,$82C2,$82C0,0

	section	bss
zv
;svg_usp	ds.l	1	; Saved user stack pointer
;svg_scr	ds.l	1	; Saved video pointer
;svg_vbl	ds.l	1	; Saved VBL pointer
svg_rez	ds.b	1	; Saved ST video mode
	even
svg_flc	ds.w	17	; Saved Falcon video control registers
svg_pal	ds.l	256	; Saved Falcon palette registers

	section	text
main_code

