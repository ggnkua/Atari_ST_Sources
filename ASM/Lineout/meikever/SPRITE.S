	text

Sprite.SCAN_CHUNKS:=	1
Sprite.SHIFTSCAN_SIZE:=	((Sprite.SCAN_CHUNKS+1)*8)
Sprite.SHITSCAN32_SIZE:=((2+1)*8)

			rsreset
Sprite.SLAB_ADR:	rs.l	1
Sprite.SLAB_WIDTH:	rs.w	1
Sprite.SLAB_HEIGHT:	rs.w	1
Sprite.SLAB_STATE:	rs.w	1
Sprite.SLAB_SIZE:	rs.w	0

; input:
; d4.w=size of pre-shifted sprite
; d7.w=number of scan lines
; a0: dst buffer for shifted sprite
; a1: degas pi1 + offset (source)
Sprite.preshift_16pix:
	subq.w	#1,d7
	bmi.s	.end

; clear before orring stuff here..
	movea.l	a0,a6
	moveq	#0,d6
	move.w	d4,d6
	subq.w	#1,d6
	moveq	#0,d0
.clear_loop:
	move.l	d0,(a6)+
	move.l	d0,(a6)+
	move.l	d0,(a6)+
	move.l	d0,(a6)+
	dbf	d6,.clear_loop

.yloop:	moveq	#4*Sprite.SCAN_CHUNKS-1,d6	; chunks of 4 planes

.word_loop:
	moveq	#0,d0
	move.w	(a1)+,d0
	moveq	#16-1,d5

.shift_loop:
	move.l	d0,d1
	swap	d1
	or.w	d0,(a0)
	move.w	d1,8(a0)
	ror.l	#1,d0
	adda.w	d4,a0				; a0: current word in next shifted sprite
	dbf	d5,.shift_loop

	move.w	d4,d3
	lsl.w	#4,d3
	subq.w	#2,d3
	suba.w	d3,a0				; a0: next word in first shifted sprite
	dbf	d6,.word_loop

	addq	#8,a0
;	moveq	#0,d0
;	move.l	d0,(a0)+
;	move.l	d0,(a0)+			; a0: next scan in first shifted logo

	lea	(20-Sprite.SCAN_CHUNKS)*8(a1),a1
						; a1: next degas scanline
	dbf	d7,.yloop

.end:	rts

; extracts masks from preshifted sprite.
; stores doubled words (for speed optimisation of the paint rout).
; input:
; d7.w=number of scan lines
; a0: dst mask
; a1: src sprite
Sprite.extract_16pix_mask:
	subq.w	#1,d7
	bmi.s	.end

.yloop:	moveq	#16*Sprite.SHIFTSCAN_SIZE/8-1,d6	; chunks of 4 planes
.chunk_loop:
	move.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	not.w	d0
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	dbf	d6,.chunk_loop
	dbf	d7,.yloop
.end:	rts

; input:
; d4.w=size of pre-shifted sprite
; d7.w=number of scan lines
; a0: dst buffer for shifted sprite
; a1: degas pi1 + offset (source)
Sprite.preshift_32pix:
	move.w	#(20-2)*8,d2			; d2.w= source stride (ST low width -32 pixels)

Sprite.preshift_32pix_stride:
	subq.w	#1,d7
	bmi.s	.end

; clear before orring stuff here..
	movea.l	a0,a6
	moveq	#0,d6
	move.w	d4,d6
	subq.w	#1,d6
	moveq	#0,d0
.clear_loop:
	move.l	d0,(a6)+
	move.l	d0,(a6)+
	move.l	d0,(a6)+
	move.l	d0,(a6)+
	dbf	d6,.clear_loop

.yloop:	moveq	#4*2-1,d6			; 2 16 pixel chunks of 4 planes

.word_loop:
	moveq	#0,d0
	move.w	(a1)+,d0
	moveq	#16-1,d5

.shift_loop:
	move.l	d0,d1
	swap	d1
	or.w	d0,(a0)
	move.w	d1,8(a0)
	ror.l	#1,d0
	adda.w	d4,a0				; a0: current word in next shifted sprite
	dbf	d5,.shift_loop
; a0: start+16*shiftedspritesize

	move.w	d4,d3				; shifted sprite size
	lsl.w	#4,d3				; x16 shifts
	subq.w	#2,d3				; -2 for next word
	suba.w	d3,a0				; a0: next word in first shifted sprite
; a0: start+2
	dbf	d6,.word_loop

	addq	#8,a0
;	moveq	#0,d0
;	move.l	d0,(a0)+
;	move.l	d0,(a0)+			; a0: next scan in first shifted logo
;	lea	(20-2)*8(a1),a1			; a1: next degas scanline
	adda.w	d2,a1
	dbf	d7,.yloop

.end:	rts

; extracts masks from preshifted sprite.
; stores doubled words (for speed optimisation of the paint rout).
; input:
; d7.w=number of scan lines
; a0: dst mask
; a1: src sprite
Sprite.extract_32pix_mask:
	subq.w	#1,d7
	bmi.s	.end

.yloop:	moveq	#16*Sprite.SHITSCAN32_SIZE/8-1,d6	; chunks of 4 planes
.chunk_loop:
	move.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	not.w	d0
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	dbf	d6,.chunk_loop
	dbf	d7,.yloop
.end:	rts

; 32x32 sprite!
; input:
; d0.w=x (trashed)
; d1.w=y (trashed)
; a0: screen (constant)
; a1: scan offset table (constant) (can also handle negative indices!)
; a2: mask (trashed)
; a3: sprite (trashed)
; a6: slab entry to be written to (trashed)
Sprite.paint_3232:

; vertical clipping..
	moveq	#0,d4			; d4.w=initial code table offset (=0)
	move.w	d1,d2
	bpl.s	.top_ok
	cmpi.w	#-32,d2
	bgt.s	.clip_top
; culled at the top..
	rts
.clip_top:
	neg.w	d2

	moveq	#32,d3
	sub.w	d2,d3
	move.w	d3,Sprite.SLAB_HEIGHT(a6)

; TODO!!
	lsl.w	#3,d2
	adda.w	d2,a2				; a2: mask start
	add.w	d2,d2
	adda.w	d2,a3				; a3: sprite start
	add.w	d2,d2				; TODO!!
	move.w	d2,d4				; a4: code start
	bra.s	.bottom_ok
.top_ok:

	subi.w	#200-32,d2
	ble.s	.bottom_ok
	cmpi.w	#32,d2
	blt.s	.clip_bottom
; culled at the bottom..
	rts
.clip_bottom:

	move.w	d1,d3
	sub.w	d2,d3
	move.w	d3,Sprite.SLAB_HEIGHT(a6)

	sub.w	d2,d1				; compensate for screen offset in code table!
	add.w	d2,d2				; x2
	move.w	d2,d3				; x2
	lsl.w	#4,d2				; x32
	add.w	d3,d2				; x(32+2)
	add.w	d3,d3				; x4
	add.w	d3,d3				; x8
	add.w	d3,d2				; x(32+2+8=42)
	adda.w	d2,a4				; a4: code start
	move.w	d2,d4
.bottom_ok:

; calc screen offset and shift..
	add.w	d1,d1
	move.w	(a1,d1.w),d1
	move.w	d0,d2
	move.w	d0,d6
	andi.w	#$000F,d6
	sub.w	d6,d2
	bmi.s	.l_clipped
	lsr.w	d2
	add.w	d2,d1
.l_clipped:

	move.l	a0,d3
	ext.l	d1
	bpl.s	.scan_ok
	moveq	#0,d5
	move.w	d2,d5
	add.l	d5,d3
	move.l	d3,Sprite.SLAB_ADR(a6)
	move.l	a0,d3
	add.l	d1,d3
	movea.l	d3,a6
	bra.s	.scr_addr_done
.scan_ok:
	add.l	d1,d3
	move.l	d3,Sprite.SLAB_ADR(a6)
	movea.l	d3,a6
.scr_addr_done:

; add offset to shifted version.. 
	lsl.w	#7,d6				; d6.w=128*s
	move.w	d6,d5
	add.w	d5,d5
	add.w	d5,d6				; d6.w=384*s

	add.w	d6,a2
	add.w	d6,d6
	add.w	d6,a3

; d4.w= code table offset
	move.w	d0,d2
	bmi	Sprite.paint_lclip_3232
	subi.w	#320-16,d2
	bpl	Sprite.paint_rclip_3232

; normal horizontal case
	jmp	.yloop(pc,d4.w)

.yloop:
off	set	0

	rept	32

; 32+10=42
	movem.l	off(a6),d1-d6			; 12+48
	move.l	(a2)+,d0			; 12
	and.l	d0,d1				;  8
	and.l	d0,d2				;  8
	move.l	(a2)+,d0			; 12
	and.l	d0,d3				;  8
	and.l	d0,d4				;  8
	move.l	(a2)+,d0			; 12
	and.l	d0,d5				;  8
	and.l	d0,d6				;  8
	or.l	(a3)+,d1			; 12
	or.l	(a3)+,d2			; 12
	or.l	(a3)+,d3			; 12
	or.l	(a3)+,d4			; 12
	or.l	(a3)+,d5			; 12
	or.l	(a3)+,d6			; 12
	movem.l	d1-d6,off(a6)			; 12+48
off	set	off+160

	endr

	rts

; horizontally clipped versions..
Sprite.paint_lclip_3232:
	cmpi.w	#-32,d0
	bgt.s	.left_ok
; culled at the left..
	rts
.left_ok:
; todo: additional case?
	addq	#4,a2
	addq	#8,a3
	bra.s	Sprite.paint_hclip_3232

Sprite.paint_rclip_3232:
	cmpi.w	#320,d0
	blt.s	.right_ok
; culled at the right..
	rts
.right_ok:

; input:
; d4.w= code table offset
Sprite.paint_hclip_3232:
	ifne	0
; todo: needs 2 horizontal cases *sigh*.. maybe better to make it all dbf
; instead of jump table city..
	jmp	.yloop(pc,d4.w)

.yloop:
off	set	0
	rept	32
	move.l	(a2)+,d0			;  2
	movem.l	off(a6),d1-d2			;  6
	and.l	d0,d1				;  2
	and.l	d0,d2				;  2
	or.l	(a3)+,d1			;  2
	or.l	(a3)+,d2			;  2
	movem.l	d1-d2,off(a6)			;  6
	addq	#4,a2				;  2
	addq	#8,a3				;  2
	nop
	nop
	nop
off	set	off+160
	endr
	endc
	rts

; 24 scans!
; input:
; d0.w=x (trashed)
; d1.w=y (trashed)
; a0: screen (constant)
; a1: scan offset table (constant) (can also handle negative indices!)
; a2: mask (trashed)
; a3: sprite (trashed)
; a6: slab entry to be written to (trashed)
Sprite.paint_24:

; vertical clipping..
	moveq	#0,d4			; d4.w=initial code table offset (=0)
	move.w	d1,d2
	bpl.s	.top_ok
	cmpi.w	#-24,d2
	bgt.s	.clip_top
; culled at the top..
	rts
.clip_top:
	neg.w	d2

	moveq	#24,d3
	sub.w	d2,d3
	move.w	d3,Sprite.SLAB_HEIGHT(a6)

	lsl.w	#3,d2
	adda.w	d2,a2				; a2: mask start
	add.w	d2,d2
	adda.w	d2,a3				; a3: sprite start
	add.w	d2,d2
	move.w	d2,d4				; a4: code start
	bra.s	.bottom_ok
.top_ok:

	subi.w	#200-24,d2
	ble.s	.bottom_ok
	cmpi.w	#24,d2
	blt.s	.clip_bottom
; culled at the bottom..
	rts
.clip_bottom:

	move.w	d1,d3
	sub.w	d2,d3
	move.w	d3,Sprite.SLAB_HEIGHT(a6)

	sub.w	d2,d1				; compensate for screen offset in code table!
	lsl.w	#5,d2
	adda.w	d2,a4				; a4: code start
	move.w	d2,d4
.bottom_ok:

; calc screen offset and shift..
	add.w	d1,d1
	move.w	(a1,d1.w),d1
	move.w	d0,d2
	move.w	d0,d6
	andi.w	#$000F,d6
	sub.w	d6,d2
	bmi.s	.l_clipped
	lsr.w	d2
	add.w	d2,d1
.l_clipped:

	move.l	a0,d3
	ext.l	d1
	bpl.s	.scan_ok
	moveq	#0,d5
	move.w	d2,d5
	add.l	d5,d3
	move.l	d3,Sprite.SLAB_ADR(a6)
	move.l	a0,d3
	add.l	d1,d3
	movea.l	d3,a6
	bra.s	.scr_addr_done
.scan_ok:
	add.l	d1,d3
	move.l	d3,Sprite.SLAB_ADR(a6)
	movea.l	d3,a6
.scr_addr_done:

; add offset to shifted version.. (for 24 scans high this is shit..)
	lsl.w	#6,d6
	move.w	d6,d7
	add.w	d6,d6
	add.w	d7,d6

	add.w	d6,a2
	add.w	d6,d6
	add.w	d6,a3

; d4.w= code table offset
	move.w	d0,d2
	bmi	Sprite.paint_lclip_24
	subi.w	#320-16,d2
	bpl	Sprite.paint_rclip_24

; normal horizontal case
	jmp	.yloop(pc,d4.w)

.yloop:
off	set	0

	rept	24

; movem stuff, 9% faster..
	movem.l	off(a6),d1-d4			; 12+32
	move.l	(a2)+,d0			; 12
	and.l	d0,d1				;  8
	and.l	d0,d2				;  8
	move.l	(a2)+,d0			; 12
	and.l	d0,d3				;  8
	and.l	d0,d4				;  8
	or.l	(a3)+,d1			; 12
	or.l	(a3)+,d2			; 12
	or.l	(a3)+,d3			; 12
	or.l	(a3)+,d4			; 12
	movem.l	d1-d4,off(a6)			; 12+32
off	set	off+160

	endr

	rts

; horizontally clipped versions..
Sprite.paint_lclip_24:
	cmpi.w	#-16,d0
	bgt.s	.left_ok
; culled at the left..
	rts
.left_ok:
	addq	#4,a2
	addq	#8,a3
	bra.s	Sprite.paint_hclip_24

Sprite.paint_rclip_24:
	cmpi.w	#320,d0
	blt.s	.right_ok
; culled at the right..
	rts
.right_ok:

; input:
; d4.w= code table offset
Sprite.paint_hclip_24:
	jmp	.yloop(pc,d4.w)

.yloop:
off	set	0
	rept	24
	move.l	(a2)+,d0
	movem.l	off(a6),d1-d2
	and.l	d0,d1
	and.l	d0,d2
	or.l	(a3)+,d1
	or.l	(a3)+,d2
	movem.l	d1-d2,off(a6)
	addq	#4,a2
	addq	#8,a3
	nop
	nop
	nop
off	set	off+160
	endr

	rts

; 16 scans!
; input:
; d0.w=x (trashed)
; d1.w=y (trashed)
; a0: screen (constant)
; a1: scan offset table (constant) (can also handle negative indices!)
; a2: mask (trashed)
; a3: sprite (trashed)
; a6: slab entry to be written to (trashed)
Sprite.paint:

; vertical clipping..
	moveq	#0,d4			; d4.w=initial code table offset (=0)
	move.w	d1,d2
	bpl.s	.top_ok
	cmpi.w	#-16,d2
	bgt.s	.clip_top
; culled at the top..
	rts
.clip_top:
	neg.w	d2

	moveq	#16,d3
	sub.w	d2,d3
	move.w	d3,Sprite.SLAB_HEIGHT(a6)

	lsl.w	#3,d2
	adda.w	d2,a2				; a2: mask start
	add.w	d2,d2
	adda.w	d2,a3				; a3: sprite start
	add.w	d2,d2
	move.w	d2,d4				; a4: code start
	bra.s	.bottom_ok
.top_ok:

	subi.w	#200-16,d2
	ble.s	.bottom_ok
	cmpi.w	#16,d2
	blt.s	.clip_bottom
; culled at the bottom..
	rts
.clip_bottom:

	move.w	d1,d3
	sub.w	d2,d3
	move.w	d3,Sprite.SLAB_HEIGHT(a6)

	sub.w	d2,d1				; compensate for screen offset in code table!
	lsl.w	#5,d2
	adda.w	d2,a4				; a4: code start
	move.w	d2,d4
.bottom_ok:

; calc screen offset and shift..
	add.w	d1,d1
	move.w	(a1,d1.w),d1
	move.w	d0,d2
	move.w	d0,d6
	andi.w	#$000F,d6
	sub.w	d6,d2
	bmi.s	.l_clipped
	lsr.w	d2
	add.w	d2,d1
.l_clipped:

	move.l	a0,d3
	ext.l	d1
	bpl.s	.scan_ok
	moveq	#0,d5
	move.w	d2,d5
	add.l	d5,d3
	move.l	d3,Sprite.SLAB_ADR(a6)
	move.l	a0,d3
	add.l	d1,d3
	movea.l	d3,a6
	bra.s	.scr_addr_done
.scan_ok:
	add.l	d1,d3
	move.l	d3,Sprite.SLAB_ADR(a6)
	movea.l	d3,a6
.scr_addr_done:

; add offset to shifted version..
	lsl.w	#7,d6

	add.w	d6,a2
	add.w	d6,d6
	add.w	d6,a3

; d4.w= code table offset
	move.w	d0,d2
	bmi	Sprite.paint_lclip#
	subi.w	#320-16,d2
	bpl	Sprite.paint_rclip

; normal horizontal case
	jmp	.yloop(pc,d4.w)

.yloop:
off	set	0

	rept	16

; movem stuff, 9% faster..
	movem.l	off(a6),d1-d4			; 12+32
	move.l	(a2)+,d0			; 12
	and.l	d0,d1				;  8
	and.l	d0,d2				;  8
	move.l	(a2)+,d0			; 12
	and.l	d0,d3				;  8
	and.l	d0,d4				;  8
	or.l	(a3)+,d1			; 12
	or.l	(a3)+,d2			; 12
	or.l	(a3)+,d3			; 12
	or.l	(a3)+,d4			; 12
	movem.l	d1-d4,off(a6)			; 12+32
off	set	off+160

	endr

	rts

	ifne	0

	move.l	(a2)+,d0			; 12
	move.l	(a6),d1				; 12
	and.l	d0,d1				;  8
	or.l	(a3)+,d1			; 12
	move.l	d1,(a6)+			; 12
	move.l	(a6),d1				; 12
	and.l	d0,d1				;  8
	or.l	(a3)+,d1			; 12
	move.l	d1,(a6)+			; 12
;100
	move.l	(a2)+,d0			; 12
	move.l	(a6),d1				; 12
	and.l	d0,d1				;  8
	or.l	(a3)+,d1			; 12
	move.l	d1,(a6)+			; 12
	move.l	(a6),d1				; 12
	and.l	d0,d1				;  8
	or.l	(a3)+,d1			; 12
	move.l	d1,(a6)+			; 12
;100
	lea	160-16(a6),a6

	endc

; horizontally clipped versions..
Sprite.paint_lclip:
	cmpi.w	#-16,d0
	bgt.s	.left_ok
; culled at the left..
	rts
.left_ok:
	addq	#4,a2
	addq	#8,a3
	bra.s	Sprite.paint_hclip

Sprite.paint_rclip:
	cmpi.w	#320,d0
	blt.s	.right_ok
; culled at the right..
	rts
.right_ok:

; input:
; d4.w= code table offset
Sprite.paint_hclip:
	jmp	.yloop(pc,d4.w)

.yloop:
off	set	0
	rept	16
	move.l	(a2)+,d0
	movem.l	off(a6),d1-d2
	and.l	d0,d1
	and.l	d0,d2
	or.l	(a3)+,d1
	or.l	(a3)+,d2
	movem.l	d1-d2,off(a6)
	addq	#4,a2
	addq	#8,a3
	nop
	nop
	nop
off	set	off+160
	endr

	rts

