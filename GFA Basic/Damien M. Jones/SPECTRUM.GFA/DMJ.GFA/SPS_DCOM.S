*	Spectrum Smooshed Decompressor
*	by dmj, 6/23/92
*	This routine _does_ fall under my copyright.

*	Many thanks to David Baggett et. al. for ST Picture Formats,
*	which provided all the excellent information used to write
*	this routine.  It supports the .SPS format as used by the
*	SPC Deluxe slideshower.

SpsDcom	movem.l d3-d7/a3-a6,-(a7) ; Save C registers.

	move.l 40(a7),a0	; Address of the compressed data.
	move.l 44(a7),a1	; Address to store bitmap.

	lea 12(a0),a0		; Move past file's header info.
	lea 160(a1),a1		; Start with line 1, not line 0.
	lea 31840(a1),a2	; End-of-screen address.
	lea 8(a1),a3		; End-of-compression address.

	move.l #1,d0		; Two different step rates.
	move.l #7,d1

	move.l a0,a4		; Address of compressed data.
	adda.l -8(a0),a4	; Add in length of compressed bitmap.
	adda.l -4(a0),a4	; Add in length of compressed colormap.
	btst.b #0,-1(a4)	; Which compression method?
	beq Spsv		; Vertical...

Sps1	clr.w d2		; Make sure this is clear.
	move.b (a0)+,d2		; Read control byte.
	btst #7,d2		; Check the high bit.
	beq Sps4		; It's clear, repeat byte.

	and.w #$7F,d2		; Reset this.

Sps2	move.b (a0)+,(a1)	; Copy byte.
	adda.l d0,a1		; Move to next storage location.
	exg d0,d1		; Swap the add bytes.

	cmp.l a2,a1		; End of screen?
	blt Sps3		; Nope.
	lea -31838(a1),a1	; Move to start of next bitplane.
	cmp.l a3,a1		; Finished whole pic?
	bge Spsp		; Yes, bail now.

Sps3	dbra d2,Sps2		; Copy next byte.
	bra Sps1		; And get next packet.

Sps4	addq.w #2,d2		; 0 means repeat three times.
	move.b (a0)+,d3		; Get byte to repeat.

Sps5	move.b d3,(a1)		; Store byte.
	adda.l d0,a1		; Move to next storage location.
	exg d0,d1		; Swap the add bytes.

	cmp.l a2,a1		; End of screen?
	blt Sps6		; Nope.
	lea -31838(a1),a1	; Move to start of next bitplane.
	cmp.l a3,a1		; Finished whole pic?
	bge Spsp		; Yes, bail now.

Sps6	dbra d2,Sps5		; Copy next byte.
	bra Sps1		; And get next packet.

*	Vertical decompressor.

Spsv	lea 160(a1),a4		; End-of-bitplane address.

Spsv1	clr.w d2		; Make sure this is clear.
	move.b (a0)+,d2		; Read control byte.
	btst #7,d2		; Check the high bit.
	beq Spsv4		; It's clear, repeat byte.

	and.w #$7F,d2		; Reset this.

Spsv2	move.b (a0)+,(a1)	; Copy byte.
	lea 160(a1),a1		; Move to next line.

	cmp.l a2,a1		; End of screen?
	blt Spsv3		; Nope.
	lea -31840(a1),a1	; Move to start of column.
	adda.l d0,a1		; Move to next column.
	exg d0,d1		; Swap column increments.
	cmp.l a4,a1		; End of this bitplane?
	blt Spsv3		; Nope.
	lea -158(a1),a1		; Move to start of bitplane.
	cmp.l a3,a1		; Finished whole pic?
	bge Spsp		; Yes, bail now.

Spsv3	dbra d2,Spsv2		; Copy next byte.
	bra Spsv1		; And get next packet.

Spsv4	addq.w #2,d2		; 0 means repeat three times.
	move.b (a0)+,d3		; Get byte to repeat.

Spsv5	move.b d3,(a1)		; Store byte.
	lea 160(a1),a1		; Move to next line.

	cmp.l a2,a1		; End of screen?
	blt Spsv6		; Nope.
	lea -31840(a1),a1	; Move to start of column.
	adda.l d0,a1		; Move to next column.
	exg d0,d1		; Swap column increments.
	cmp.l a4,a1		; End of this bitplane?
	blt Spsv6		; Nope.
	lea -158(a1),a1		; Move to start of bitplane.
	cmp.l a3,a1		; Finished whole pic?
	bge Spsp		; Yes, bail now.

Spsv6	dbra d2,Spsv5		; Copy next byte.
	bra Spsv1		; And get next packet.

*	This chunk decompresses the colors from the bitstream.
*	(I *hate* bitstream compression!)

Spsp	move.l 48(a7),a1	; Address to store palette.
	move.w #596,d0		; Decompress 597 palettes.
	sub.l a2,a2		; Bit offset from (a0).
	move.w #3,d1		; Eight bits to the byte.
	move.w #8,d2		; Eight bits to the byte.

Spsp1	move.l a2,d3		; Copy the bit offset.
	lsr.l d1,d3		; Get number of bytes.

	move.b 0(a0,d3.w),d4	; Read first byte.
	lsl.w d2,d4		; Move to nlsb.
	move.b 1(a0,d3.w),d4	; Read next byte.
	lsl.l d2,d4		; Shift these over.
	move.b 2(a0,d3.w),d4	; Read third byte.

	move.l a2,d3		; Get the bit offset.
	and.w #7,d3		; Just the offset within a byte.
	move.w #10,d5		; 24 (what we read) -14 (what we want) =10
	sub.w d3,d5		; How much to shift to the right.
	lsr.l d5,d4		; Now d4 has, in bits 0-13, what we want.

	lea 14(a2),a2		; 14 more bits read.
	clr.w (a1)+		; Color 0 is always black.
	move.w #13,d6		; Do 14 colors.

Spsp2	btst d6,d4		; Is this color present?
	bne Spsp3		; Yes, handle it.

	clr.w (a1)+		; Else store black.
	bra Spsp4		; And move to next color.

Spsp3	move.l a2,d3		; Copy the bit offset.
	lsr.l d1,d3		; Get number of bytes.

	move.b 0(a0,d3.w),d7	; Read first byte.
	lsl.w d2,d7		; Move to nlsb.
	move.b 1(a0,d3.w),d7	; Read next byte.

	move.l a2,d3		; Get the bit offset.
	and.w #7,d3		; Just the offset within a byte.
	move.w #7,d5		; 16 (what we read) -9 (what we want) =7
	sub.w d3,d5		; How much to shift to the right.
	lsr.l d5,d7		; Now d7 has, in bits 0-8, what we want.

	lea 9(a2),a2		; 9 more bits read.

	move.w d7,d5		; Make a copy.
	and.w #%111000000,d5	; Just the red.
	lsl.w #2,d5		; Put it in the proper place.
	move.w d5,d3		; Save it for now.

	move.w d7,d5		; Make a copy.
	and.w #%111000,d5	; Just the green.
	add.w d5,d5		; Shift to the proper place.
	or.w d5,d3		; Merge with the red.

	and.w #%111,d7		; Just the blue.
	or.w d7,d3		; Merge with red and green.

	move.w d3,(a1)+		; Store in palette space.

Spsp4	dbra.w d6,Spsp2		; Next color.

	clr.w (a1)+		; Color 15 is always black.
	dbra.w d0,Spsp1		; Next palette.

	movem.l (a7)+,d3-d7/a3-a6 ; Restore registers.
	rts			; All done.


