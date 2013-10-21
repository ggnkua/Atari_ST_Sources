*	Spectrum decompressor.
*	Many thanks to Trio for making this PD.
*	Comments by dmj, May 9, 1992.

*	To get this code, I disassembled the Trio routines, then
*	went through and changed all the disassembly labels to
*	more meaningful ones.  I also added the comments, sorted
*	out the variables section, and other dull things like that.

*	Please remember that this is not my code.  It's the Trio
*	code.  Any glitches/faults are not my problem.  And I
*	-do- see a few spots where it could be improved.

Spc_D	bra     SpcMain		; Skip to main.

        dc.w $CE		; ID?
	dc.w 0
	dc.w 0
	dc.w 0
	dc.w 0
	dc.w 0
        dc.w -1

*	Make sure it's a Spectrum file.

SpcMain	movem.l d3-d7/a3-a6,-(a7) ; Save registers.
        movea.l 40(a7),a6	; Address to decompress from.
        cmpi.w  #$5350,(a6)	; Make sure ID bytes are there.
        bne     SpcDone		; Not there, abort.

*	Clear line 0 of image.

        movea.l 44(a7),a0	; Address for bitmap.
        moveq   #39,d0		; Clear 40 longwords (top line).

Spc1	clr.l   (a0)+		; Clear long.
        dbf     d0,Spc1		; Next long.

*	Uncompress bitmap.

        lea     12(a6),a0	; Get to bitmap data.
        movea.l 44(a7),a1	; Address of bitmap.
        move.w  #1,d1		; First add number.
        move.w  #7,d7		; Second add number.
        lea     32000(a1),a2	; End address of bitmap (for bitplane).
        lea     8(a2),a3	; End address after all bitplanes.

Spc2	lea     -31840(a2),a1	; -31840 bytes (pixel line 1).

Spc3	move.b  (a0)+,d6	; Read byte.
        ext.w   d6		; Extend the sign.
        bmi     Spc5		; Less than zero, repeat.

Spc4	move.b  (a0)+,(a1)	; Copy byte.
        adda.w  d1,a1		; Add the offset.
        exg     d1,d7		; Swap add bytes (add 1, then 7, then 1, etc.)
        dbf     d6,Spc4		; Next byte.
        bra     Spc7		; Next packet.

Spc5	neg.w   d6		; Flip byte.
        addq.w  #1,d6		; Add 1.
        move.b  (a0)+,d0	; Read byte to repeat.

Spc6	move.b  d0,(a1)		; Store byte.
        adda.w  d1,a1		; Add offset.
        exg     d1,d7		; Swap offsets.
        dbf     d6,Spc6		; Loop until done.

Spc7	cmpa.l  a2,a1		; End of this bitplane?
        bcs    	Spc3		; Less than, get next control byte.
        bne     SpcDone		; Should be exact, problem with image.

        addq.l  #2,a2		; Adjust for next bitplane.
        cmpa.l  a3,a2		; Finished all bitplanes?
        bcs     Spc2		; No, do next one.

*	Uncompress palettes.

        move.l  a0,d0		; Copy over address.
        addq.l  #1,d0		; Increment it.
        bclr    #0,d0		; And make sure it's even.
        subi.l  #12,d0		; Discount 12 bytes (for file header).
        sub.l   a6,d0		; Determine length of compressed data.
        cmp.l   4(a6),d0	; Match that of the file?
        bne     SpcDone		; No, error; abort.

        lea     12(a6),a0	; Address of start of compressed data.
        adda.l  4(a6),a0	; Add back in to offset.
        movea.l 48(a7),a1	; Address to store palettes.
        move.w  #596,d7		; Uncompress 597 palettes.
        clr.w   d0		; Make sure all of this is clear.

Spc8	move.w  #13,d6		; Extract 14 palette words.
        move.w  (a0)+,d1	; Read flag word.
        lsr.w   #1,d1		; Ignore low bit.
        move.w  d0,(a1)+	; Set color zero to black.

Spc9	lsr.w   #1,d1		; Shift over a bit.
        bcc     Spc10		; It was zero, use black.
        move.w  (a0)+,(a1)+	; Else copy palette word.
        dbf     d6,Spc9		; Next bit.
        bra     Spc11		; Next record.

Spc10	move.w  d0,(a1)+	; Store black.
        dbf     d6,Spc9		; Next bit.

Spc11	move.w  d0,(a1)+	; Store black for color 15.
        dbf     d7,Spc8		; Next record.

        lea     -12(a0),a0	; Discount 12 bytes (for file header).
        suba.l  a6,a0		; Subtract absolute address.
        suba.l  4(a6),a0	; Subtract length of bitmap data.
        cmpa.l  8(a6),a0	; Match size listed?

SpcDone	sne     d0		; Clear flag (if not equal).
        ext.w   d0		; Extend sign all the way across.
        ext.l   d0
        movem.l (a7)+,d3-d7/a3-a6 ; Restore registers.
        rts			; Return.
