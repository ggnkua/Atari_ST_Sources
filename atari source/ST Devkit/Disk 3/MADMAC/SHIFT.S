;--- Exports:
	.globl	mksh


;--- Imports:
	.globl	_images
	.globl	_masks


;+
;  Construct shifted images and masks
;
;    Passed:	a1 -> free memory
;
;-
mksh::
	lea	_images,a5
.1:	tst.l	(a5)
	beq.s	.2
	move.l	(a5)+,a0
	bsr	mkshimg
	bra.s	.1

.2:	lea	_masks,a5
.3:	tst.l	(a5)
	beq.s	.4
	move.l	(a5)+,a0
	bsr	mkshmsk
	bra.s	.3

.4:	rts


;+
;  Complete shifted entries in an image table.
;
;    Passed:	a0 -> image table with one aligned image in it
;		a1 -> free memory
;
;    Returns:	table filled in with 15 more (shifted) entries
;		a0 -> next table (probably)
;		a1 -> next location in free memory
;
;    Uses:	d0-d4/a0-a4
;
;-
mkshimg:
	move.l	(a0)+,a3		; a3 -> original image
	moveq	#1,d2			; d2 = shift amount {1, 2, .. 15}

.3:	move.l	a1,(a0)+		; fill in table address
	moveq	#16-1,d4		; d4 = scanline count
	move.l	a3,a2			; a2 -> original image

.4:	moveq	#0,d1			; d1 = plane count {0, 2, 4, 6}
.1:	move.w	(a2,d1.w),d0
	lsr.w	d2,d0
	move.w	d0,(a1,d1.w)
	addq.w	#2,d1
	cmp.w	#8,d1
	bne.s	.1

	moveq	#16,d3			; d3 = left-shift count
	sub.w	d2,d3			;    = 16 - shiftCount
	moveq	#0,d1			; d1 = plane count {0, 2, 4, 6}
.2:	move.w	(a2,d1.w),d0
	lsl.w	d3,d0
	move.w	d0,8(a1,d1.w)
	addq.w	#2,d1
	cmp.w	#8,d1
	bne.s	.2

	add.w	#16,a1			; bump dest to next free spot
	addq.w	#8,a2			; bump to next 4-plane entry in src
	dbra	d4,.4		; do another scanline

	addq.w	#1,d2			; bump shift count
	cmp.w	#16,d2			; if (shiftCount != 16)
	bne.w	.3			;    loop for more shifted tables
	rts


;+
;  Complete shifted images in a mask table.
;
;    Passed:	a0 -> mask table with one aligned mask in it
;		a1 -> free memory
;
;    Returns:	table filled in with 15 more (shifted) entries
;		a0 -> next table (probably)
;		a1 -> next location in free memory
;
;    Uses:	d0-d5/a0-a4
;
;-
mkshmsk:
	move.l	(a0)+,a3		; a2 -> original image
	moveq	#2,d1			; d1 = lmask[], rmask[] index
	moveq	#1,d2			; d2 = shift amount {1, 2, .. 15}

.3:	move.l	a1,(a0)+		; fill in table address
	moveq	#16-1,d4		; d4 = scanline count
	move.l	a3,a2			; a2 -> original image

.4:	move.w	(a2),d0
	lsr.w	d2,d0
	or.w	lmask(pc,d1.w),d0
	move.w	d0,(a1)

	moveq	#16,d3			; d3 = left-shift count
	sub.w	d2,d3			;    = 16 - shiftCount
	move.w	(a2),d0
	lsl.w	d3,d0
	or.w	rmask(pc,d1.w),d0
	move.w	d0,2(a1)

	addq.w	#2,a2			; bump src to next mask entry
	addq.w	#4,a1			; bump dest to next free spot
	dbra	d4,.4			; loop for more scanlines

	addq.w	#2,d1			; bump mask table index
	addq.w	#1,d2			; bump shift count
	cmp.w	#16,d2			; if (shiftCount != 16)
	bne.w	.3			;    loop for more shifted tables
	rts


lmask:	dc.w	$0000			; >> 0
	dc.w	$8000,$c000,$e000,$f000	; >> 1 (etc.)
	dc.w	$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0
	dc.w	$fff8,$fffc,$fffe	; >>15

rmask:
	dc.w	$ffff			; << 0
	dc.w	$7fff,$3fff,$1fff,$0fff	; << 1 (etc.)
	dc.w	$07ff,$03ff,$01ff,$00ff
	dc.w	$007f,$003f,$001f,$000f
	dc.w	$0007,$0003,$0001	; << 15
