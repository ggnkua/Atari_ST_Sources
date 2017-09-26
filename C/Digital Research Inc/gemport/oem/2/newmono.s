*************************************************************************
*									*
*				NEWMONO.S				*
*									*
*************************************************************************

*************************************************************************
*									*
*	This module contains the mono-spaced text blt for displays	*
*	with a consecutive video plane memory scheme.  It is heavily	*
*	optimized for the addressing modes of the 68000.  This code	*
*	can easily be modified to also support interleaved video	*
*	planes.								*
*									*
*************************************************************************

	.text
*************************************************************************
*									*
*			Public Routines					*
*									*
*************************************************************************

	.globl	_MONO8XH

	.page
*************************************************************************
*									*
*			External Variables				*
*									*
*************************************************************************

	.xdef	_DESTX		* x-coord of upper left corner of text rect
	.xdef	_DESTY		* y-coord of upper left corner of text rect
	.xdef	_DELY		* character height in scans
	.xdef	_FBASE		* base address of the font definition
	.xdef	_FWIDTH		* width of the font definition
	.xdef	_WRT_MOD	* writing mode flag
	.xdef	_CLIP		* clipping enabled/disabled flag
	.xdef	_XMN_CLI	* x-coord of upper left corner of clip rect
	.xdef	_XMX_CLI	* y-coord of upper left corner of clip rect
	.xdef	_YMN_CLI	* x-coord of lower right corner of clip rect
	.xdef	_YMX_CLI	* y-coord of lower right corner of clip rect
	.xdef	_INTIN		* base address of INTIN array
	.xdef	_CONTRL		* base address of CONTRL array
	.xdef	_v_bas_ad	* base address of screen
	.xdef	_v_lin_wr	* # of bytes in a single scan line
	.xdef	_TEXT_FG	* foreground color for text
	.xdef	_v_planes	* # of video planes


*************************************************************************
*									*
*			External Routines				*
*									*
*************************************************************************

	.xdef	concat

	.page
*************************************************************************
*									*
*			Local Constants					*
*									*
*************************************************************************

*
*	Constants for the Conditional Assembly of Code
*
v_pl_dspl	.equ	$10000	* # of bytes between VME/10 video planes

rev_vid		.equ	1	* for selecting reverse video style text

	.page
*************************************************************************
*									*
*	_MONO8XH							*
*									*
*	This routine performs text blt's on mono-spaced, 8-bit		*
*	wide fonts.  They can be arbitrarily tall.  This blt is		*
*	always byte-aligned and does not support clipping.		*
*									*
*	Inputs:								*
*	   _DESTX, _DESTY - x and y-coordinates of the character	*
*			    cell					*
*	   _DELY - character cell height				*
*	   _CLIP - clipping enabled flag				*
*	   _XMN_CLIP, _YMN_CLIP - x and y-coordinates of upper left	*
*				  corner of clipping rectangle		*
*	   _XMX_CLIP, _YMX_CLIP - x and y-coordinates of lower right	*
*				  corner of clipping rectangle		*
*	   _FBASE - base address of font definition			*
*	   _FWIDTH - width of font definition				*
*	   _WRT_MOD - current writing mode				*
*	   _TEXT_FG - text foreground color				*
*	   _v_bas_ad - base address of first video page			*
*	   _v_lin_wr - # of bytes in a single scan line			*
*	   _v_planes - # of video planes				*
*	   _CONTRL[3] - # of characters to display			*
*	   _INTIN - character string					*
*									*
*	Outputs:							*
*	   d0 - 0 = text blt could not be performed			*
*		1 = text blt was successfully performed			*
*									*
*	Registers Modified:						*
*									*
*	Author/Date:							*
*	   Jim Shillington, Bell Northern Research   5/15/85		*
*									*
*	Revisions:		None					*
*									*
*************************************************************************

*
*	If the destination for the text is not byte-aligned then this text
*	blt can not be used.  The function will need to be performed by
*	the general case text blt.
*
_MONO8XH:
	movem.l	d3-d7/a3-a6,-(a7)	* save registers used by C
	move.w	_DESTX,d0	* get x-coordinate of destination
	move.w	d0,d2		* get a temporary copy
	andi.w	#7,d2		* is the destination byte-aligned?
	bne	blt_fail	* nope - have to use general text blt

*
*	Get the number of characters to display.  If the length of the
*	string is 0 then there is nothing to do.  Take the exit for
*	successful completion.
*
	movea.l	_CONTRL,a0	* get address of _CONTRL array
	move.w	6(a0),d2	* get # of characters in string
	beq	blt_pass	* length = 0 - all done

*
*	If clipping is enabled then text the limits of the text extent
*	rectangle to determine whether the string falls entirely within
*	the clipping rectangle.  If it does not then this text blt can
*	not be used and the function will need to be performed by the
*	general case text blt.
*
	move.w	_DESTY,d1	* get y-coordinate of destination
	move.w	_DELY,d3	* get character cell height
	tst.w	_CLIP		* is clipping enabled?
	beq	no_clip		* nope - don't need to worry about clipping
	cmp.w	_YMN_CLI,d1	* top bound of clipping rectangle exceeded?
	blt	blt_fail	* yes - use general case text blt
	move.w	d1,d4		* get temp copy of top of text rectangle
	add.w	d3,d4		* compute bottom row + 1
	cmp.w	_YMX_CLI,d4	* bottom bound of clipping rectangle exceeded?
	bge	blt_fail	* yes - use general case text blt
	cmp.w	_XMN_CLI,d0	* left bound of clipping rectangle exceeded?
	blt	blt_fail	* yes - use general case text blt
	move.w	d2,d4		* get # of characters in string
	lsl.w	#3,d4		* convert to # of pixels
	add.w	d0,d4		* compute right pixel column + 1
	cmp.w	_XMX_CLI,d4	* right bound of clipping rectangle exceeded?
	bge	blt_fail	* yes - use general case text blt

*
*	Compute the starting address in the screen for the text extent
*	rectangle.  This is the address of the upper left corner of the
*	rectangle.
*
no_clip:
	jsr	concat		* compute offset into buffer
	tst.w	d0		* on an odd byte boundary?  (d0 = 8)
	beq	word_ok		* nope - on an even byte boundary  (d0 = 0)
	addq.w	#1,d1		* yes - increment the buffer offset
word_ok:
	movea.l	_v_bas_ad,a2	* get base address of the screen
	adda.l	d1,a2		* compute starting address within screen

*
*	Set up the rest of the parameters needed to draw the characters.
*
	movea.l	_FBASE,a1	* get base address of font definition
	movea.l	_INTIN,a0	* get base address of the character string
	move.w	_v_planes,d0	* get # of planes
	subq.w	#1,d0		* convert it to counter for dbra loop
	move.w	_FWIDTH,d4	* get width of font definition
	move.w	_v_lin_wr,a3	* get # of bytes in a scan line
	suba.w	d2,a3		* get offset to start of next scan of string
	subq.w	#1,d2		* convert character count to dbra loop counter
	subq.w	#1,d3		* get # of scans - 1
	move.w	_TEXT_FG,d1	* get bit plane flags for text fgnd color

*************************************************************************
*									*
*	At this point the register usage is as follows.			*
*									*
*	d0.w - plane loop counter					*
*	d1.w - text foreground color					*
*	d2.w - character loop counter					*
*	d3.w - scan loop counter					*
*	d4.w - width of font definition					*
*	d5.w - working copy of scan loop counter			*
*	d6.w - working copy of character loop counter			*
*	d7.w - index into jump table/scratch				*
*	a0.l - address of character string				*
*	a1.l - address of font definition				*
*	a2.l - starting address within current plane			*
*	a3.w - offset from end of text extent rectangle in one scan	*
*	       to start of text extent rectangle in next scan		*
*	a4.l - working copy of address of font definition		*
*	a5.l - working copy of address of character string		*
*	a6.l - working copy of starting address within current plane	*
*									*
*************************************************************************

*
*	Loop drawing all scans of every character to each video plane.
*	Each pass through the loop, set up the screen address and scan
*	loop counter and call the appropriate service routine.
*
mplan_lp:
	movea.l	a2,a6		* get starting address for this plane
	move.w	d3,d5		* get scan loop counter
	movea.l	a1,a4		* get base address of font definition
	move.w	_WRT_MOD,d7	* get the writing mode
	asl.w	#1,d7		* convert it to a word offset
	ror.w	#1,d1		* get next foreground bit plane flag
	bcc.b	bit_clr		* write plane with 0's
	addq.w	#8,d7		* write it with 1's - use 2nd half of table
bit_clr:
	move.w	mon_mode(pc,d7.w),d7	* get offset from table to routine
*	jsr	mon_mode(pc,d7.w)	* call the service routine
	lea	mon_mode(pc,d7.w),a5	* get address of service routine
	jsr	(a5)		* call it
	adda.l	#v_pl_dspl,a2	* get starting address in next plane
	dbra	d0,mplan_lp	* loop until all planes drawn

*
*	Exit for successful completion.  Return a 1 in register d0.
*
blt_pass:
	moveq	#1,d0		* signal successful completion
mono_exit:
	movem.l	(a7)+,d3-d7/a3-a6	* restore registers used by C
	rts

*
*	Exit for unsuccessful completion.  Return a 0 in register d0.
*
blt_fail:
	moveq	#0,d0		* signal unsuccessful completion
	bra	mono_exit	* restore registers and return

	.page
*************************************************************************
*									*
*	Jump Table for Drawing Text in the Different Writing Modes	*
*									*
*************************************************************************

ifne rev_vid
mon_mode:
	dc.w	mon_zer-mon_mode	* replace mode		0
	dc.w	mon_set0-mon_mode	* transparent mode	0
	dc.w	mon_xor-mon_mode	* exclusive or (xor)	0
	dc.w	mon_not0-mon_mode	* reverse transparent	0
	dc.w	mon_rep-mon_mode	* replace mode		1
	dc.w	mon_set1-mon_mode	* transparent mode	1
	dc.w	mon_xor-mon_mode	* exclusive or (xor)	1
	dc.w	mon_not1-mon_mode	* reverse transparent	1
endc
ifeq rev_vid
mon_mode:
	dc.w	mon_zer-mon_mode	* replace mode		0
	dc.w	mon_set1-mon_mode	* transparent mode	0
	dc.w	mon_xor-mon_mode	* exclusive or (xor)	0
	dc.w	mon_not1-mon_mode	* reverse transparent	0
	dc.w	mon_rep-mon_mode	* replace mode		1
	dc.w	mon_set0-mon_mode	* transparent mode	1
	dc.w	mon_xor-mon_mode	* exclusive or (xor)	1
	dc.w	mon_not0-mon_mode	* reverse transparent	1
endc

	.page
*************************************************************************
*									*
*	Replace Mode Text BLT -- Foreground Flag = 0			*
*									*
*	This routine performs a mono-spaced text blt in replace		*
*	mode for the case when the current plane should be written	*
*	with 0's to acheive the current foreground color.  This is	*
*	accomplished by clearing each target byte.
*									*
*	Inputs:								*
*	   d2.w - character loop count					*
*	   d5.w - scan loop count					*
*	   a3.w - offset to next scan line				*
*	   a6.l - starting address in plane				*
*									*
*	Outputs:	None						*
*									*
*	Registers Modified:	d5, d6, a6				*
*									*
*	Author/Date:							*
*	   Jim Shillington, Bell Northern Research   5/15/85		*
*									*
*	Revisions:	None						*
*									*
*************************************************************************

*
*	Bump the screen pointer to the starting point for the text in the
*	next scan line.
*
mon_zer1:
	adda.w	a3,a6		* bump screen pointer to next scan line

*
*	Get the character loop counter.
*
mon_zer:
	move.w	d2,d6		* get character loop count
ifne rev_vid
	clr.b	d7		* get a byte of 0's
endc
ifne rev_vid
	moveq.l	#-1,d7		* get a long word of 1's
endc
*
*	Loop clearing the current scan of all the characters in the string.
*	When that is done then loop to clear the next scan of the characters.
*
mon_zer2:
	move.b	d7,(a6)+	* clear byte for current character
	dbra	d6,mon_zer2	* loop until all characters cleared
	dbra	d5,mon_zer1	* loop until all scans cleared
	rts

	.page
*************************************************************************
*									*
*	Replace Mode Text BLT -- Foreground Flag = 1			*
*									*
*	This routine performs a mono-spaced text blt in replace		*
*	mode for the case when the current plane should be written	*
*	with 1's to acheive the current foreground color.		*
*									*
*	Inputs:								*
*	   d2.w - character loop count					*
*	   d4.w - offset to next row in font definition			*
*	   d5.w - scan loop count					*
*	   a0.l - address of character string				*
*	   a4.l - address of font definition				*
*	   a3.w - offset to next scan line				*
*	   a6.l - starting address in plane				*
*									*
*	Outputs:	None						*
*									*
*	Registers Modified:	d5, d6, d7, a4, a5, a6			*
*									*
*	Author/Date:							*
*	   Jim Shillington, Bell Northern Research   5/15/85		*
*									*
*	Revisions:	None						*
*									*
*************************************************************************

*
*	Bump the screen pointer to the starting point for the text in the
*	next scan line and bump the font definition pointer to the start
*	of the next row of definitions.
*
mon_rep1:
	adda.w	a3,a6		* bump screen pointer to next scan line
	adda.w	d4,a4		* bump font definition pointer to next row

*
*	Get the address of the character string and the character loop counter.
*
mon_rep:
	movea.l	a0,a5		* get address of character string
	move.w	d2,d6		* get character loop count

*
*	Loop writing the current scan of all the characters in the string.
*	When that is done then loop to draw the next scan of the characters.
*
mon_rep2:
	move.w	(a5)+,d7	* get next character code
ifne rev_vid
	move.b	0(a4,d7.w),(a6)+	* move scan byte from table to screen
endc
ifeq rev_vid
	move.b	0(a4,d7.w),d7	* move scan byte from table to register
	not.b	d7		* invert scan byte to get reverse video
	move.b	d7,(a6)+	* move reverse video scan byte to screen
endc
	dbra	d6,mon_rep2	* loop until all characters drawn
	dbra	d5,mon_rep1	* loop until all scans drawn
	rts

	.page
*************************************************************************
*									*
*	Transparent Mode Text BLT -- Foreground Flag = 0		*
*									*
*	This routine performs a mono-spaced text blt in transparent	*
*	mode for the case when the current plane should be written	*
*	with 0's to acheive the current foreground color.		*
*									*
*	Inputs:								*
*	   d2.w - character loop count					*
*	   d4.w - offset to next row in font definition			*
*	   d5.w - scan loop count					*
*	   a0.l - address of character string				*
*	   a4.l - address of font definition				*
*	   a3.w - offset to next scan line				*
*	   a6.l - starting address in plane				*
*									*
*	Outputs:	None						*
*									*
*	Registers Modified:	d5, d6, d7, a4, a5, a6			*
*									*
*	Author/Date:							*
*	   Jim Shillington, Bell Northern Research   5/15/85		*
*									*
*	Revisions:	None						*
*									*
*************************************************************************

*
*	Bump the screen pointer to the starting point for the text in the
*	next scan line and bump the font definition pointer to the start
*	of the next row of definitions.
*
mon_st0a:
	adda.w	a3,a6		* bump screen pointer to next scan line
	adda.w	d4,a4		* bump font definition pointer to next row

*
*	Get the address of the character string and the character loop counter.
*
mon_set0:
	movea.l	a0,a5		* get address of character string
	move.w	d2,d6		* get character loop count

*
*	Loop writing the current scan of all the characters in the string.
*	When that is done then loop to draw the next scan of the characters.
*
mon_st0b:
	move.w	(a5)+,d7	* get next character code
	move.b	0(a4,d7.w),d7	* get current scan of character definition
	not.b	d7		* invert the bits
	and.b	d7,(a6)+	* clear all the bits that get foreground color
	dbra	d6,mon_st0b	* loop until all characters drawn
	dbra	d5,mon_st0a	* loop until all scans drawn
	rts

	.page
*************************************************************************
*									*
*	Transparent Mode Text BLT -- Foreground Flag = 1		*
*									*
*	This routine performs a mono-spaced text blt in transparent	*
*	mode for the case when the current plane should be written	*
*	with 1's to acheive the current foreground color.		*
*									*
*	Inputs:								*
*	   d2.w - character loop count					*
*	   d4.w - offset to next row in font definition			*
*	   d5.w - scan loop count					*
*	   a0.l - address of character string				*
*	   a4.l - address of font definition				*
*	   a3.w - offset to next scan line				*
*	   a6.l - starting address in plane				*
*									*
*	Outputs:	None						*
*									*
*	Registers Modified:	d5, d6, d7, a1, a5, a6			*
*									*
*	Author/Date:							*
*	   Jim Shillington, Bell Northern Research   5/15/85		*
*									*
*	Revisions:	None						*
*									*
*************************************************************************

*
*	Bump the screen pointer to the starting point for the text in the
*	next scan line and bump the font definition pointer to the start
*	of the next row of definitions.
*
mon_st1a:
	adda.w	a3,a6		* bump screen pointer to next scan line
	adda.w	d4,a4		* bump font definition pointer to next row

*
*	Get the address of the character string and the character loop counter.
*
mon_set1:
	movea.l	a0,a5		* get address of character string
	move.w	d2,d6		* get character loop count

*
*	Loop writing the current scan of all the characters in the string.
*	When that is done then loop to draw the next scan of the characters.
*
mon_st1b:
	move.w	(a5)+,d7	* get next character code
	move.b	0(a4,d7.w),d7	* get current scan of character definition
	or.b	d7,(a6)+	* set all the bits that get foreground color
	dbra	d6,mon_st1b	* loop until all characters drawn
	dbra	d5,mon_st1a	* loop until all scans drawn
	rts

	.page
*************************************************************************
*									*
*	Reverse Transparent Mode Text BLT -- Foreground Flag = 0	*
*									*
*	This routine performs a mono-spaced text blt in reverse		*
*	transparent mode for the case when the current plane should	*
*	be written with 0's to acheive the current foreground color.	*
*	In this case, the bits that would normally be given the		*
*	background color are instead given the foreground color.	*
*									*
*	Inputs:								*
*	   d2.w - character loop count					*
*	   d4.w - offset to next row in font definition			*
*	   d5.w - scan loop count					*
*	   a0.l - address of character string				*
*	   a4.l - address of font definition				*
*	   a3.w - offset to next scan line				*
*	   a6.l - starting address in plane				*
*									*
*	Outputs:	None						*
*									*
*	Registers Modified:	d5, d6, d7, a4, a5, a6			*
*									*
*	Author/Date:							*
*	   Jim Shillington, Bell Northern Research   5/15/85		*
*									*
*	Revisions:	None						*
*									*
*************************************************************************

*
*	Bump the screen pointer to the starting point for the text in the
*	next scan line and bump the font definition pointer to the start
*	of the next row of definitions.
*
mon_nt0a:
	adda.w	a3,a6		* bump screen pointer to next scan line
	adda.w	d4,a4		* bump font definition pointer to next row

*
*	Get the address of the character string and the character loop counter.
*
mon_not0:
	movea.l	a0,a5		* get address of character string
	move.w	d2,d6		* get character loop count

*
*	Loop writing the current scan of all the characters in the string.
*	When that is done then loop to draw the next scan of the characters.
*
mon_nt0b:
	move.w	(a5)+,d7	* get next character code
	move.b	0(a4,d7.w),d7	* get current scan of character definition
	and.b	d7,(a6)+	* give the background bits the foreground color
	dbra	d6,mon_nt0b	* loop until all characters drawn
	dbra	d5,mon_nt0a	* loop until all scans drawn
	rts

	.page
*************************************************************************
*									*
*	Reverse Transparent Mode Text BLT -- Foreground Flag = 1	*
*									*
*	This routine performs a mono-spaced text blt in reverse		*
*	transparent mode for the case when the current plane should	*
*	be written with 1's to acheive the current foreground color.	*
*	In this case, the bits that would normally be given the		*
*	background color are instead given the foreground color.	*
*									*
*	Inputs:								*
*	   d2.w - character loop count					*
*	   d4.w - offset to next row in font definition			*
*	   d5.w - scan loop count					*
*	   a0.l - address of character string				*
*	   a4.l - address of font definition				*
*	   a3.w - offset to next scan line				*
*	   a6.l - starting address in plane				*
*									*
*	Outputs:	None						*
*									*
*	Registers Modified:	d5, d6, d7, a4, a5, a6			*
*									*
*	Author/Date:							*
*	   Jim Shillington, Bell Northern Research   5/15/85		*
*									*
*	Revisions:	None						*
*									*
*************************************************************************

*
*	Bump the screen pointer to the starting point for the text in the
*	next scan line and bump the font definition pointer to the start
*	of the next row of definitions.
*
mon_nt1a:
	adda.w	a3,a6		* bump screen pointer to next scan line
	adda.w	d4,a4		* bump font definition pointer to next row

*
*	Get the address of the character string and the character loop counter.
*
mon_not1:
	movea.l	a0,a5		* get address of character string
	move.w	d2,d6		* get character loop count

*
*	Loop writing the current scan of all the characters in the string.
*	When that is done then loop to draw the next scan of the characters.
*
mon_nt1b:
	move.w	(a5)+,d7	* get next character code
	move.b	0(a4,d7.w),d7	* get current scan of character definition
	not.b	d7		* invert the bits
	or.b	d7,(a6)+	* give the background bits the foreground color
	dbra	d6,mon_nt0b	* loop until all characters drawn
	dbra	d5,mon_nt0a	* loop until all scans drawn
	rts

	.page
*************************************************************************
*									*
*	Exclusive Or Mode Text BLT -- Foreground Flag = 0 or 1		*
*									*
*	This routine performs a mono-spaced text blt in exclusive	*
*	or mode.  The foreground color is not used in this opera-	*
*	tion.  The data from the text font definition is xor'ed		*
*	against the contents of each of the video planes.		*
*									*
*	Inputs:								*
*	   d2.w - character loop count					*
*	   d4.w - offset to next row in font definition			*
*	   d5.w - scan loop count					*
*	   a0.l - address of character string				*
*	   a4.l - address of font definition				*
*	   a3.w - offset to next scan line				*
*	   a6.l - starting address in plane				*
*									*
*	Outputs:	None						*
*									*
*	Registers Modified:	d5, d6, d7, a4, a5, a6			*
*									*
*	Author/Date:							*
*	   Jim Shillington, Bell Northern Research   5/15/85		*
*									*
*	Revisions:	None						*
*									*
*************************************************************************

*
*	Bump the screen pointer to the starting point for the text in the
*	next scan line and bump the font definition pointer to the start
*	of the next row of definitions.
*
mon_xor1:
	adda.w	a3,a6		* bump screen pointer to next scan line
	adda.w	d4,a4		* bump font definition pointer to next row

*
*	Get the address of the character string and the character loop counter.
*
mon_xor:
	movea.l	a0,a5		* get address of character string
	move.w	d2,d6		* get character loop count

*
*	Loop writing the current scan of all the characters in the string.
*	When that is done then loop to draw the next scan of the characters.
*
mon_xor2:
	move.w	(a5)+,d7	* get next character code
	move.b	0(a4,d7.w),d7	* get current scan of character definition
	eor.b	d7,(a6)+	* invert all foreground bits in the plane
	dbra	d6,mon_xor2	* loop until all characters drawn
	dbra	d5,mon_xor1	* loop until all scans drawn
	rts

	.end
