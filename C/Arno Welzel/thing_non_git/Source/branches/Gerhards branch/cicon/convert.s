; convert.s dated 02/23/97
;
; Contains an assembler optimized version of the routine used in
; reuse_bitmap to split a four-plane-bitmap into 16 one-plane-
; bitmaps. Written in Pure Assembler for Pure C, so you most probably
; won't be able to directly use it with other compilers.
;
; Of course, you may try to adapt it for your compiler/assembler. If
; you succeed in doing so, it would be nice if you sent me your
; result.
;
; For copyright information, copying and use of this routine see
; drawcicn.c!
;
; History:
; 02/09/97: Creation
; 02/13/97: Small speed optimizations
; 02/23/97: More speed optimizations

	export	convert_data
	import	_lmul

; void convert_data(WORD *dest, WORD *plane_used, WORD *source, 
;	LONG *pixel_mult, LONG wdwxh);
;
; Input:
; dest (a0): Pointer to memory area with place for the 16 one-plane-
;            bitmaps
; plane_used (a1): Pointer to 16 words. If word n is 1 after the
;                  routine has been called, then color n (hardware-
;                  pixel-index) has been used in the source bitmap
; source (on stack): Pointer to the source bitmap with 4 planes
; pixel_mult (on stack): Pointer to 16 longs which will be filled
;                        with word-offsets (i.e. half of the offset
;                        in bytes) for the 16 one-plane-bitmaps in
;                        dest
; wdwxh (d0): Size of one plane in source in words
;
module convert_data

; Assign some registers to names of variables to ease the reading of
; the code
	equ		dest, a0
	equ		plane_used, a1
	equ		spos1, a2
	equ		spos2, a3
	equ		spos3, a4
	equ		spos4, a5
	equ		pixel_mult, a6
	equ		s1, d0
	equ		s2, d1
	equ		s3, d2
	equ		s4, d3
	equ		pixel, d4
	equ		k, d5

; Save registers, get stack parameters and initialise pointers to the
; 4 planes in the source area
	movem.l	d3-d7/a2-a6,-(sp)
	move.l	44(sp),d6
	move.l	48(sp),pixel_mult
	subq.l	#4,sp
	add.l	d0,d0
	move.l	d6,spos1
	add.l	d0,d6
	move.l	d6,spos2
	add.l	d0,d6
	move.l	d6,spos3
	add.l	d0,d6
	move.l	d6,spos4
	lsr.l	#1,d0

; Calculate the 16 offsets for pixel_mult and clear plane_used
	move.l	d0,d4
	movem.l	a0-a1,-(sp)
	moveq	#15,d5
l1:
	move.w	d5,d6
	add.w	d6,d6
	clr.w	(plane_used,d6.w)
	move.l	d5,d0
	move.l	d4,d1
	jsr		_lmul
	add.w	d6,d6
	move.l	d0,(pixel_mult,d6.w)
	dbra	d5,l1
	movem.l	(sp)+,a0-a1

; Loop over all words in one plane
	move.l	d4,(sp)
	beq.s	empty_planes
l2:
; Read one word from each of the four source planes
	move.w	(spos1)+,s1
	move.w	(spos2)+,s2
	move.w	(spos3)+,s3
	move.w	(spos4)+,s4

; Loop over all 16 bits of the four words
	move.w	#32768,k
l3:
; Calculate the pixel value of the current pixel represented by bit k
; in the four words. This looks a bit tricky, but works very well.
	clr.w	pixel
	add.w	s4,s4
	addx.w	pixel,pixel
	add.w	s3,s3
	addx.w	pixel,pixel
	add.w	s2,s2
	addx.w	pixel,pixel
	add.w	s1,s1
	addx.w	pixel,pixel

; Mark the pixel used in plane_used and set the correct pixel in the
; corresponding destination bitmap
	move.w	pixel,d7
	add.w	d7,d7
	move.w	#1,(plane_used,d7.w)
	add.w	d7,d7
	move.l	(pixel_mult,d7.w),d6
	add.l	d6,d6
	add.l	d6,dest
	or.w	k,(dest)
	sub.l	d6,dest
	lsr.w	#1,k
	bne.s	l3

	addq.l	#2,dest
	subq.l	#1,(sp)
l2_check:
	bne.s	l2

empty_planes:
	addq.l	#4,sp
	movem.l	(sp)+,d3-d7/a2-a6
	rts

endmod

; EOF