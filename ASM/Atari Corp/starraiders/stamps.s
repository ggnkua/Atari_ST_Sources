*
*	STAMPS.S   16-Color Stamping Routines for ST Star-Raiders
*		 copyright 1985 ATARI Corp.
*		  (started 10/21/85 .. RZ)
*
	.text

*
*	PUBLIC SYMBOLS
*
	.globl	rplmasker
	.globl	windstamp
	.globl	viewstamp
	.globl	rplstamp
	.globl	xorstamp

*
*	SUBROUTINE AREA
*

*
*	RPLMASKER   Builds Masks for 16-Color REPLACE Stamps
*
*	Given:
*		Control
*
*	Returns:
*		w/ Stamp Masks Built in memory
*
*	Register Usage:
*		destroys a0-a3 and d0-d3
*
*	Externals:
*		none
*
rplmasker:
	movea.l	#maskbase,a0	* Build masks for REPLACE Stamps
	movea.l	#rplimages,a1
	movea.l	#rplmasks,a2
maskbuild:
	move.l	(a1)+,d3
	beq	mbldone		* WHILE (rpl-images remain) DO
	addq.l	#4,d3		* skip image-offset data
	move.l	d3,a3
	move.l	a0,(a2)+	* save pointer to mask
	move	(a3)+,d1	* d1 = height in lines
	subq	#1,d1
	move	(a3)+,d2	* d2 = width in words
	subq	#1,d2
maskimg:			* FOR (all lines) DO
	move	d2,d3
masklin:			* FOR (all words) DO
	move	(a3)+,d0
	or	(a3)+,d0
	or	(a3)+,d0
	or	(a3)+,d0	* d0 = OR of all planes data
	eor	#-1,d0		* invert to make mask
	move	d0,(a0)+	* save mask (same for all planes)
	dbra	d3,masklin
	dbra	d1,maskimg
	bra	maskbuild
mbldone:

	movea.l	#rplimages,a0
	movea.l	#rplmasks,a1
	movea.l	#solidimgs,a2
solidify:
	move.l	(a2)+,d0
	beq	mbldexit	* WHILE (solid-images remain) DO
	asl	#2,d0
	move.l	(a0,d0),a3
	addq.l	#4,a3
	move	(a3)+,d1
	subq	#1,d1		* d1 = image height - 1
	move	(a3)+,d2
	subq	#1,d2		* d2 = image width - 1
	move.l	(a1,d0),a3	* a3 = ptr to mask data
	swap	d0		* d0 = image pixel width
	and	#$0f,d0
	bne	solid0		* IF (pixel-width was 16)
	clr	d3		* THEN (fringe is entire word)
	bra	sldhi
solid0:	move	#-1,d3		* ELSE (compute fringe mask)
	lsr	d0,d3		* d3 = fringe mask
sldhi:				* FOR (height of mask) DO
	move	d2,d0		* FOR (width of mask) DO
sldwid:	tst	d0
	bne	solid1		* IF (this is the last word)
	move	d3,(a3)+	* THEN fringe-mask
	bra	solid2
solid1:	clr	(a3)+		* ELSE mask all
solid2:	dbra	d0,sldwid
	dbra	d1,sldhi
	bra	solidify
mbldexit:
	rts


*
*	WINDSTAMP   Replaces 16-Color Stamps into WINDOW Bit-Map
*			(w/ Clipping to WINDOW)
*
*	Given:
*		d0 = Xpos of stamp (0-319)
*		d1 = Ypos of stamp (14-133)
*		d2 = Stamp Number (0-??)
*		SCREEN = ptr to currently active screen
*		X160TBL = Multiples of 160 table
*		RPLIMAGES = Table of ptrs to Images
*			( STAMP = X-OFFSET(pixels),Y-OFFSET(pixels)
*				  HEIGHT(lines),WIDTH(words),DATA )
*		RPLMASKS = Table of ptrs to Masks
*
*	Returns:
*		w/ Stamp REPLACEd into memory
*
*	Register Usage:
*		destroys a0-a6 and d0-d7
*
*	Externals:
*		rplstamp(enterydone)
*
windstamp:
	asl	#2,d2		* d2 = offset into table of longwords
	movea.l	#rplimages,a0
	move.l	(a0,d2),a0	* a0 = ptr to Image data
	movea.l	#rplmasks,a1
	move.l	(a1,d2),a1	* a1 = ptr to Mask data
	sub	(a0)+,d0
	sub	(a0)+,d1	* apply image offsets to final position
	move	(a0)+,d5	* d5 = stamp height(lines)
	move	(a0)+,d6	* d6 = stamp width(words)
*
*	Clip Stamp to WINDOW (VERTICAL ONLY)
*
	cmp	#14,d1		* IF (Ypos < ScreenTop)
	bge	wdypos
	move	d5,d4		* THEN
	add	d1,d5		* height = height+Ypos
	cmp	#14,d5
	bgt	wdy1
	rts			* IF (Stamp off-screen) skipit
wdy1:	move	#14,d1		* Ypos = ScreenTop
	sub	#14,d5
	sub	d5,d4
	muls	d6,d4
	add	d4,d4
	adda	d4,a1		* MskPtr = MskPtr+2*(width*(oldheight-height))
	asl	#2,d4
	adda	d4,a0		* ImgPtr = ImgPtr+8*(width*(oldheight-height))
	bra	enterydone	* EXIT thru RPLSTAMP
wdypos:				* ELSE
	cmp	#134,d1
	blt	wdy2
	rts			* IF (Stamp off-screen) skipit
wdy2:	move	d5,d4
	add	d1,d4
	cmp	#134,d4
	ble	enterydone	* IF (Stamp wholly on screen) THEN accept it
	move	#134,d5		* ELSE
	sub	d1,d5		* Height = scrnbot - Ypos
	bra	enterydone	* EXIT thru RPLSTAMP


*
*	VIEWSTAMP   Replaces 16-Color Stamps into VIEWER Bit-Map
*			(w/ Clipping to VIEWER screen)
*
*	Given:
*		d0 = Xpos of stamp (0-319)
*		d1 = Ypos of stamp (0-199)
*		d2 = Stamp Number (0-??)
*		SCREEN = ptr to currently active screen
*		X160TBL = Multiples of 160 table
*		RPLIMAGES = Table of ptrs to Images
*			( STAMP = X-OFFSET(pixels),Y-OFFSET(pixels)
*				  HEIGHT(lines),WIDTH(words),DATA )
*		RPLMASKS = Table of ptrs to Masks
*
*	Returns:
*		w/ Stamp REPLACEd into memory
*
*	Register Usage:
*		destroys a0-a6 and d0-d7
*
*	Externals:
*		rplstamp(enteright,enterleft,enternone)
*
viewstamp:
	asl	#2,d2		* d2 = offset into table of longwords
	movea.l	#rplimages,a0
	move.l	(a0,d2),a0	* a0 = ptr to Image data
	movea.l	#rplmasks,a1
	move.l	(a1,d2),a1	* a1 = ptr to Mask data
	sub	(a0)+,d0
	sub	(a0)+,d1	* apply image offsets to final position
	move	(a0)+,d5	* d5 = stamp height(lines)
	move	(a0)+,d6	* d6 = stamp width(words)
*
*	Clip Stamp to View-Screen (VERTICAL)
*
	cmp	#scrntop,d1	* IF (Ypos < ScreenTop)
	bge	vwypos
	move	d5,d4		* THEN
	add	d1,d5		* height = height+Ypos
	cmp	#scrntop,d5
	bgt	vwy1
	rts			* IF (Stamp off-screen) skipit
vwy1:	move	#scrntop,d1	* Ypos = ScreenTop
	sub	#scrntop,d5
	sub	d5,d4
	muls	d6,d4
	add	d4,d4
	adda	d4,a1		* MskPtr = MskPtr+2*(width*(oldheight-height))
	asl	#2,d4
	adda	d4,a0		* ImgPtr = ImgPtr+8*(width*(oldheight-height))
	bra	vwydone
vwypos:				* ELSE
	cmp	#scrnbot,d1
	blt	vwy2
	rts			* IF (Stamp off-screen) skipit
vwy2:	move	d5,d4
	add	d1,d4
	cmp	#scrnbot,d4
	blt	vwydone		* IF (Stamp wholly on screen) THEN accept it
	move	#scrnbot,d5	* ELSE
	sub	d1,d5		* Height = scrnbot - Ypos
vwydone:
*
*	Test For HORIZONTAL Clipping (LEFT)
*
	cmp	#scrnleft,d0	* IF (Xpos<ScreenLeft)
	bge	vwxpos
	move	d6,d4		* THEN
	asl	#4,d4
	add	d0,d4		* d4 = Xpos + 16*Width
	cmp	#scrnleft,d4
	bgt	vwx1
	rts			* IF (Stamp Off-Screen) skipit
*
*	LEFT-Clipped Draw Set-Up
*
vwx1:	sub	#scrnleft,d0	* Imaginary Zero at screen left edge
	move	d0,d4
	and	#$0f,d4		* d4(lo) = (Xpos MOD 16) + 16 = shift-count
	swap	d4
	move	d0,d4
	eor	#$0ffff,d4
	lsr	#4,d4		* d4 = -(Xpos+1)/16 = #words to skip
	sub	d4,d6
	subq	#2,d6		* width = width - #words to skip - 2
	add	d4,d4
	adda	d4,a1		* MskPtr = MskPtr + 2*skipcount
	asl	#2,d4		* d4(hi) = 8*(#words to skip) = #bytes to skip
	adda	d4,a0		* ImgPtr = ImgPtr + 8*skipcount
	swap	d4

	movea.l	#x160tbl,a2
	add	d1,d1
	move	(a2,d1),d1	* d1 = line-offset into screen(bytes)
	add	#scrnbyte,d1	* FUDGE for aligning with view-screen
	movea.l	screen,a2
	adda	d1,a2		* a2 = pointer into display memory
	bra	enterleft	* BARFF .. jump to rplstamp entry
*
*	Test For HORIZONTAL Clipping (RIGHT)
*
vwxpos:
	cmp	#scrnrigh,d0
	blt	vwx2
	rts			* IF (Stamp Off-Screen) skipit
vwx2:	move	d6,d4
	asl	#4,d4
	add	d0,d4		* d4 = Xpos + 16*Width
	cmp	#scrnrigh,d4
	blt	enternone	* IF (Stamp wholly on screen) THEN accept it
*				  BARFF .. jump to rplstamp entry
*
*	RIGHT-Clipped Draw Set-Up
*
	sub	#scrnrigh,d4	* ELSE
	lsr	#4,d4		* d4 = ((Xpos + 16*Width) - edge)/16 = wordskip
	sub	d4,d6
	subq	#2,d6		* width = width - #words to skip - 2
	asl	#3,d4
	swap	d4		* d4(hi) = 8*(#words to skip) = #bytes to skip
	move	d0,d4
	and	#$0f,d4		* d4(lo) = shiftcount
	bra	enteright	* BARFF .. jump to rplstamp entry


*
*	RPLSTAMP   Replaces 16-Color Stamps into Bit-Map
*			(w/ Clipping to screen)
*
*	Given:
*		d0 = Xpos of stamp (0-319)
*		d1 = Ypos of stamp (0-199)
*		d2 = Stamp Number (0-??)
*		SCREEN = ptr to currently active screen
*		X160TBL = Multiples of 160 table
*		RPLIMAGES = Table of ptrs to Images
*			( STAMP = X-OFFSET(pixels),Y-OFFSET(pixels)
*				  HEIGHT(lines),WIDTH(words),DATA )
*		RPLMASKS = Table of ptrs to Masks
*
*	Returns:
*		w/ Stamp REPLACEd into memory
*
*	Register Usage:
*		destroys a0-a6 and d0-d7
*
*	Externals:
*		none
*
rplstamp:
	asl	#2,d2		* d2 = offset into table of longwords
	movea.l	#rplimages,a0
	move.l	(a0,d2),a0	* a0 = ptr to Image data
	movea.l	#rplmasks,a1
	move.l	(a1,d2),a1	* a1 = ptr to Mask data
	sub	(a0)+,d0
	sub	(a0)+,d1	* apply image offsets to final position
	move	(a0)+,d5	* d5 = stamp height(lines)
	move	(a0)+,d6	* d6 = stamp width(words)
*
*	Clip Stamp to Screen (VERTICAL)
*
	tst	d1		* IF (Ypos<0)
	bpl	rplypos
	move	d5,d4		* THEN
	add	d1,d5		* height = height+Ypos
	bgt	rply1
	rts			* IF (Stamp off-screen) skipit
rply1:	move	#0,d1		* Ypos = 0
	sub	d5,d4
	muls	d6,d4
	add	d4,d4
	adda	d4,a1		* MskPtr = MskPtr+2*(width*(oldheight-height))
	asl	#2,d4
	adda	d4,a0		* ImgPtr = ImgPtr+8*(width*(oldheight-height))
	bra	rplydone
rplypos:			* ELSE
	cmp	#200,d1
	blt	rply2
	rts			* IF (Stamp off-screen) skipit
rply2:	move	d5,d4
	add	d1,d4
	cmp	#200,d4
	blt	rplydone	* IF (Stamp wholly on screen) THEN accept it
	move	#200,d5		* ELSE
	sub	d1,d5		* Height = 200 - Ypos
*
*	Entry Point for WINDSTAMP
*
enterydone:
*
*	Test For HORIZONTAL Clipping (LEFT)
*
rplydone:
	tst	d0		* IF (Xpos<0)
	bpl	rplxpos
	move	d6,d4		* THEN
	asl	#4,d4
	add	d0,d4		* d4 = Xpos + 16*Width
	bgt	rplx1
	rts			* IF (Stamp Off-Screen) skipit
*
*	LEFT-Clipped Draw Loop
*
rplx1:	move	d0,d4
	and	#$0f,d4		* d4(lo) = (Xpos MOD 16) + 16 = shift-count
	swap	d4
	move	d0,d4
	eor	#$0ffff,d4
	lsr	#4,d4		* d4 = -(Xpos+1)/16 = #words to skip
	sub	d4,d6
	subq	#2,d6		* width = width - #words to skip - 2
	add	d4,d4
	adda	d4,a1		* MskPtr = MskPtr + 2*skipcount
	asl	#2,d4		* d4(hi) = 8*(#words to skip) = #bytes to skip
	adda	d4,a0		* ImgPtr = ImgPtr + 8*skipcount
	swap	d4

	movea.l	#x160tbl,a2
	add	d1,d1
	move	(a2,d1),d1	* d1 = line-offset into screen(bytes)
	movea.l	screen,a2
	adda	d1,a2		* a2 = pointer into display memory
*
*	kludgy entry point for code-sharing with viewstamp
*
enterleft:

	subq	#1,d5		* prepare for dbra loops
	swap	d6
	move	d5,d6		* d6(hi) = height count
lfreplin:			* FOR (height of stamp) DO
	swap	d6		* d6(lo) = width count
	move.l	a2,a3		* a3 = active pointer into display memory
	move	(a0)+,d0
	swap	d0
	move	(a0)+,d1
	swap	d1
	move	(a0)+,d2
	swap	d2
	move	(a0)+,d3
	swap	d3		* init. for first word ("discarded" data-fill)
	move	(a1)+,d5
	swap	d5		* init. for first mask
	move	d6,d7
	bmi	lfrepskp	* IF (more than one word)
lfrepcol:			* THEN FOR (width of stamp) DO
	move	(a1),d5
	lsr.l	d4,d5		* fetch and shift mask
	move	(a0),d0
	lsr.l	d4,d0		* fetch and shift data
	and	d5,(a3)		* mask-off old data
	or	d0,(a3)+	* draw into plane0
	move	(a0)+,d0
	swap	d0		* old data for shifting into next word
	move	(a0),d1
	lsr.l	d4,d1		* fetch and shift data
	and	d5,(a3)		* mask-off old data
	or	d1,(a3)+	* draw into plane1
	move	(a0)+,d1
	swap	d1		* old data for shifting into next word
	move	(a0),d2
	lsr.l	d4,d2		* fetch and shift data
	and	d5,(a3)		* mask-off old data
	or	d2,(a3)+	* draw into plane2
	move	(a0)+,d2
	swap	d2		* old data for shifting into next word
	move	(a0),d3
	lsr.l	d4,d3		* fetch and shift data
	and	d5,(a3)		* mask-off old data
	or	d3,(a3)+	* draw into plane3
	move	(a0)+,d3
	swap	d3		* old data for shifting into next word
	move	(a1)+,d5
	swap	d5		* old mask for shifting into next maskword
	dbra	d7,lfrepcol
lfrepskp:
	clr	d0
	clr	d1
	clr	d2
	clr	d3		* zero-right-fill
	move.w	#-1,d5		* mask nothing
	lsr.l	d4,d0
	lsr.l	d4,d1
	lsr.l	d4,d2
	lsr.l	d4,d3
	lsr.l	d4,d5		* shift-align data and mask
	and	d5,(a3)		* mask-off old data
	or	d0,(a3)+	* draw into plane0
	and	d5,(a3)		* mask-off old data
	or	d1,(a3)+	* draw into plane1
	and	d5,(a3)		* mask-off old data
	or	d2,(a3)+	* draw into plane2
	and	d5,(a3)		* mask-off old data
	or	d3,(a3)+	* draw into plane3

	swap	d4
	adda	d4,a0		* skip some of the image
	move	d4,d7
	lsr	#2,d7
	adda	d7,a1		* skip some of the mask
	swap	d4
	adda.w	#160,a2		* bump screen ptr to next line
	swap	d6
	dbra	d6,lfreplin
	rts
*
*	Test For HORIZONTAL Clipping (RIGHT)
*
rplxpos:
	cmp	#320,d0
	blt	rplx2
	rts			* IF (Stamp Off-Screen) skipit
rplx2:	move	d6,d4
	asl	#4,d4
	add	d0,d4		* d4 = Xpos + 16*Width
	cmp	#320,d4
	blt	rplxok		* IF (Stamp wholly on screen) THEN accept it
*
*	RIGHT-Clipped Draw Loop
*
	sub	#320,d4		* ELSE
	lsr	#4,d4		* d4 = ((Xpos + 16*Width) - 320)/16 = wordskip
	sub	d4,d6
	subq	#2,d6		* width = width - #words to skip - 2
	asl	#3,d4
	swap	d4		* d4(hi) = 8*(#words to skip) = #bytes to skip
	move	d0,d4
	and	#$0f,d4		* d4(lo) = shiftcount
*
*	kludgy entry point for code-sharing with viewstamp
*
enterigh:

	movea.l	#x160tbl,a2
	add	d1,d1
	move	(a2,d1),d1	* d1 = line-offset into screen(bytes)
	asr	#1,d0
	andi	#$fff8,d0	* d0 = (xpos/16)*8 = row-offset(bytes)
	movea.l	screen,a2
	add	d0,d1
	adda	d1,a2		* a2 = pointer into display memory

	subq	#1,d5		* prepare for dbra loops
	swap	d6
	move	d5,d6		* d6(hi) = height count
rtreplin:			* FOR (height of stamp) DO
	swap	d6		* d6(lo) = width count
	move.l	a2,a3		* a3 = active pointer into display memory
	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3		* init. for first word (zero-pad-left)
	move.l	#-1,d5		* init. mask to mask nothing
	move	d6,d7
	bmi	rtrepskp	* IF (more than one word)
rtrepcol:			* THEN FOR (width of stamp) DO
	move	(a1),d5
	lsr.l	d4,d5		* fetch and shift mask
	move	(a0),d0
	lsr.l	d4,d0		* fetch and shift data
	and	d5,(a3)		* mask-off old data
	or	d0,(a3)+	* draw into plane0
	move	(a0)+,d0
	swap	d0		* old data for shifting into next word
	move	(a0),d1
	lsr.l	d4,d1		* fetch and shift data
	and	d5,(a3)		* mask-off old data
	or	d1,(a3)+	* draw into plane1
	move	(a0)+,d1
	swap	d1		* old data for shifting into next word
	move	(a0),d2
	lsr.l	d4,d2		* fetch and shift data
	and	d5,(a3)		* mask-off old data
	or	d2,(a3)+	* draw into plane2
	move	(a0)+,d2
	swap	d2		* old data for shifting into next word
	move	(a0),d3
	lsr.l	d4,d3		* fetch and shift data
	and	d5,(a3)		* mask-off old data
	or	d3,(a3)+	* draw into plane3
	move	(a0)+,d3
	swap	d3		* old data for shifting into next word
	move	(a1)+,d5
	swap	d5		* old mask for shifting into next maskword
	dbra	d7,rtrepcol
rtrepskp:
	move	(a0)+,d0
	move	(a0)+,d1
	move	(a0)+,d2
	move	(a0)+,d3	* init. for last word ("discarded" data-fill)
	move	(a1)+,d5	* init. for last maskword
	lsr.l	d4,d0
	lsr.l	d4,d1
	lsr.l	d4,d2
	lsr.l	d4,d3
	lsr.l	d4,d5		* shift-align data and mask
	and	d5,(a3)		* mask-off old data
	or	d0,(a3)+	* draw into plane0
	and	d5,(a3)		* mask-off old data
	or	d1,(a3)+	* draw into plane1
	and	d5,(a3)		* mask-off old data
	or	d2,(a3)+	* draw into plane2
	and	d5,(a3)		* mask-off old data
	or	d3,(a3)+	* draw into plane3

	swap	d4
	adda	d4,a0		* skip some of the image
	move	d4,d7
	lsr	#2,d7
	adda	d7,a1		* skip some of the mask
	swap	d4
	adda.w	#160,a2		* bump screen ptr to next line
	swap	d6
	dbra	d6,rtreplin
	rts
*
*	kludgy entry point for code-sharing with viewstamp
*
enternone:
rplxok:
*
*	Non-Clipped Draw Loop
*
	movea.l	#x160tbl,a2
	add	d1,d1
	move	(a2,d1),d1	* d1 = line-offset into screen(bytes)
	move	d0,d4
	andi	#$0f,d4		* d4 = (xpos mod 16) = bit-offset
	asr	#1,d0
	andi	#$fff8,d0	* d0 = (xpos/16)*8 = row-offset(bytes)
	movea.l	screen,a2
	add	d0,d1
	adda	d1,a2		* a2 = pointer into display memory

	subq	#1,d6
	subq	#1,d5		* prepare for dbra loops
	swap	d6
	move	d5,d6		* d6(hi) = height count
linreplp:			* FOR (height of stamp) DO
	swap	d6		* d6(lo) = width count
	move.l	a2,a3		* a3 = active pointer into display memory
	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3		* init. for first word (zero-pad-left)
	move.l	#-1,d5		* init. mask to mask nothing
	move	d6,d7
colreplp:			* THEN FOR (width of stamp) DO
	move	(a1),d5
	lsr.l	d4,d5		* fetch and shift mask
	move	(a0),d0
	lsr.l	d4,d0		* fetch and shift data
	and	d5,(a3)		* mask-off old data
	or	d0,(a3)+	* draw into plane0
	move	(a0)+,d0
	swap	d0		* old data for shifting into next word
	move	(a0),d1
	lsr.l	d4,d1		* fetch and shift data
	and	d5,(a3)		* mask-off old data
	or	d1,(a3)+	* draw into plane1
	move	(a0)+,d1
	swap	d1		* old data for shifting into next word
	move	(a0),d2
	lsr.l	d4,d2		* fetch and shift data
	and	d5,(a3)		* mask-off old data
	or	d2,(a3)+	* draw into plane2
	move	(a0)+,d2
	swap	d2		* old data for shifting into next word
	move	(a0),d3
	lsr.l	d4,d3		* fetch and shift data
	and	d5,(a3)		* mask-off old data
	or	d3,(a3)+	* draw into plane3
	move	(a0)+,d3
	swap	d3		* old data for shifting into next word
	move	(a1)+,d5
	swap	d5		* old mask for shifting into next maskword
	dbra	d7,colreplp

	clr	d0
	clr	d1
	clr	d2
	clr	d3		* zero-right-fill
	move.w	#-1,d5		* mask nothing
	lsr.l	d4,d0
	lsr.l	d4,d1
	lsr.l	d4,d2
	lsr.l	d4,d3
	lsr.l	d4,d5		* shift-align data and mask
	and	d5,(a3)		* mask-off old data
	or	d0,(a3)+	* draw into plane0
	and	d5,(a3)		* mask-off old data
	or	d1,(a3)+	* draw into plane1
	and	d5,(a3)		* mask-off old data
	or	d2,(a3)+	* draw into plane2
	and	d5,(a3)		* mask-off old data
	or	d3,(a3)+	* draw into plane3

	adda.w	#160,a2		* bump screen ptr to next line
	swap	d6
	dbra	d6,linreplp
	rts


*
*	XORSTAMP   Exclusive-Ors 16-Color Stamps into Bit-Map
*			(w/ Clipping to screen)
*
*	Given:
*		d0 = Xpos of stamp (0-319)
*		d1 = Ypos of stamp (0-199)
*		d2 = Stamp Number (0-??)
*		SCREEN = ptr to currently active screen
*		X160TBL = Multiples of 160 table
*		XORIMAGES = Table of ptrs to Image data
*			( STAMP = X-OFFSET(pixels),Y-OFFSET(pixels)
*				  HEIGHT(lines),WIDTH(words),DATA )
*
*	Returns:
*		w/ Stamp XOR'ed into memory
*
*	Register Usage:
*		destroys a0-a2 and d0-d7
*
*	Externals:
*		none
*
xorstamp:
	asl	#2,d2		* d2 = offset into table of longwords
	movea.l	#xorimages,a0
	move.l	(a0,d2),a0	* a0 = ptr to Image data
	sub	(a0)+,d0
	sub	(a0)+,d1	* apply image offsets to final position
	move	(a0)+,d5	* d5 = stamp height(lines)
	move	(a0)+,d6	* d6 = stamp width(words)
*
*	Clip Stamp to Screen (VERTICAL)
*
	tst	d1		* IF (Ypos<0)
	bpl	xorypos
	move	d5,d4		* THEN
	add	d1,d5		* height = height+Ypos
	bgt	xory1
	rts			* IF (Stamp off-screen) skipit
xory1:	move	#0,d1		* Ypos = 0
	sub	d5,d4
	muls	d6,d4
	asl	#3,d4
	adda	d4,a0		* Ptr = Ptr + 8*(width*(oldheight-height))
	bra	xorydone
xorypos:			* ELSE
	cmp	#200,d1
	blt	xory2
	rts			* IF (Stamp off-screen) skipit
xory2:	move	d5,d4
	add	d1,d4
	cmp	#200,d4
	blt	xorydone	* IF (Stamp wholly on screen) THEN accept it
	move	#200,d5		* ELSE
	sub	d1,d5		* Height = 200 - Ypos
xorydone:
*
*	Test For HORIZONTAL Clipping (LEFT)
*
	tst	d0		* IF (Xpos<0)
	bpl	xorxpos
	move	d6,d4		* THEN
	asl	#4,d4
	add	d0,d4		* d4 = Xpos + 16*Width
	bgt	xorx1
	rts			* IF (Stamp Off-Screen) skipit
*
*	LEFT-Clipped Draw Loop
*
xorx1:	move	d0,d4
	and	#$0f,d4		* d4(lo) = (Xpos MOD 16) + 16 = shift-count
	swap	d4
	move	d0,d4
	eor	#$0ffff,d4
	lsr	#4,d4		* d4 = -(Xpos+1)/16 = #words to skip
	sub	d4,d6
	subq	#2,d6		* width = width - #words to skip - 2
	asl	#3,d4		* d4(hi) = 8*(#words to skip) = #bytes to skip
	adda	d4,a0		* Ptr = Ptr + 8*skipcount
	swap	d4

	movea.l	#x160tbl,a1
	add	d1,d1
	move	(a1,d1),d1	* d1 = line-offset into screen(bytes)
	movea.l	screen,a1
	adda	d1,a1		* a1 = pointer into display memory

	subq	#1,d5		* prepare for dbra loops
lfxstlin:			* FOR (height of stamp) DO
	move.l	a1,a2		* a2 = pointer into display memory
	move	(a0)+,d0
	swap	d0
	move	(a0)+,d1
	swap	d1
	move	(a0)+,d2
	swap	d2
	move	(a0)+,d3
	swap	d3		* init. for first word ("discarded" data-fill)
	move	d6,d7
	bmi	lfxstskp	* IF (more than one word)
lfxstcol:			* THEN FOR (width of stamp) DO
	move	(a0),d0
	lsr.l	d4,d0		* fetch and shift data
	eor	d0,(a2)+	* XOR into memory (plane0)
	move	(a0)+,d0
	swap	d0		* hi-word = old data
	move	(a0),d1
	lsr.l	d4,d1		* fetch and shift data
	eor	d1,(a2)+	* XOR into memory (plane1)
	move	(a0)+,d1
	swap	d1		* hi-word = old data
	move	(a0),d2
	lsr.l	d4,d2		* fetch and shift data
	eor	d2,(a2)+	* XOR into memory (plane2)
	move	(a0)+,d2
	swap	d2		* hi-word = old data
	move	(a0),d3
	lsr.l	d4,d3		* fetch and shift data
	eor	d3,(a2)+	* XOR into memory (plane3)
	move	(a0)+,d3
	swap	d3		* hi-word = old data
	dbra	d7,lfxstcol
lfxstskp:
	clr	d0
	clr	d1
	clr	d2
	clr	d3		* zero-right-fill
	lsr.l	d4,d0
	eor	d0,(a2)+	* shift and XOR into memory (plane0)
	lsr.l	d4,d1
	eor	d1,(a2)+	* shift and XOR into memory (plane1)
	lsr.l	d4,d2
	eor	d2,(a2)+	* shift and XOR into memory (plane2)
	lsr.l	d4,d3
	eor	d3,(a2)+	* shift and XOR into memory (plane3)

	swap	d4
	adda	d4,a0		* skip some of the image
	swap	d4
	adda.w	#160,a1		* bump screen ptr to next line
	dbra	d5,lfxstlin
	rts
*
*	Test For HORIZONTAL Clipping (RIGHT)
*
xorxpos:
	cmp	#320,d0
	blt	xorx2
	rts			* IF (Stamp Off-Screen) skipit
xorx2:	move	d6,d4
	asl	#4,d4
	add	d0,d4		* d4 = Xpos + 16*Width
	cmp	#320,d4
	blt	xorxok		* IF (Stamp wholly on screen) THEN accept it
*
*	RIGHT-Clipped Draw Loop
*
	sub	#320,d4		* ELSE
	lsr	#4,d4		* d4 = ((Xpos + 16*Width) - 320)/16 = wordskip
	sub	d4,d6
	subq	#2,d6		* width = width - #words to skip - 2
	asl	#3,d4
	swap	d4		* d4(hi) = 8*(#words to skip) = #bytes to skip
	move	d0,d4
	and	#$0f,d4		* d4(lo) = shiftcount

	movea.l	#x160tbl,a1
	add	d1,d1
	move	(a1,d1),d1	* d1 = line-offset into screen(bytes)
	asr	#1,d0
	andi	#$fff8,d0	* d0 = (xpos/16)*8 = row-offset(bytes)
	movea.l	screen,a1
	add	d0,d1
	adda	d1,a1		* a1 = pointer into display memory

	subq	#1,d5		* prepare for dbra loops
rtxstlin:			* FOR (height of stamp) DO
	move.l	a1,a2		* a2 = pointer into display memory
	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3		* init. for first word (zero-pad-left)
	move	d6,d7
	bmi	rtxstskp	* IF (more than one word)
rtxstcol:			* THEN FOR (width of stamp) DO
	move	(a0),d0
	lsr.l	d4,d0		* fetch and shift data
	eor	d0,(a2)+	* XOR into memory (plane0)
	move	(a0)+,d0
	swap	d0		* hi-word = old data
	move	(a0),d1
	lsr.l	d4,d1		* fetch and shift data
	eor	d1,(a2)+	* XOR into memory (plane1)
	move	(a0)+,d1
	swap	d1		* hi-word = old data
	move	(a0),d2
	lsr.l	d4,d2		* fetch and shift data
	eor	d2,(a2)+	* XOR into memory (plane2)
	move	(a0)+,d2
	swap	d2		* hi-word = old data
	move	(a0),d3
	lsr.l	d4,d3		* fetch and shift data
	eor	d3,(a2)+	* XOR into memory (plane3)
	move	(a0)+,d3
	swap	d3		* hi-word = old data
	dbra	d7,rtxstcol
rtxstskp:
	move	(a0)+,d0
	move	(a0)+,d1
	move	(a0)+,d2
	move	(a0)+,d3	* init. for last word ("discarded" data-fill)
	lsr.l	d4,d0
	eor	d0,(a2)+	* shift and XOR into memory (plane0)
	lsr.l	d4,d1
	eor	d1,(a2)+	* shift and XOR into memory (plane1)
	lsr.l	d4,d2
	eor	d2,(a2)+	* shift and XOR into memory (plane2)
	lsr.l	d4,d3
	eor	d3,(a2)+	* shift and XOR into memory (plane3)

	swap	d4
	adda	d4,a0		* skip some of the image
	swap	d4
	adda.w	#160,a1		* bump screen ptr to next line
	dbra	d5,rtxstlin
	rts

xorxok:
*
*	Non-Clipped Draw Loop
*
	movea.l	#x160tbl,a1
	add	d1,d1
	move	(a1,d1),d1	* d1 = line-offset into screen(bytes)
	move	d0,d4
	andi	#$0f,d4		* d4 = (xpos mod 16) = bit-offset
	asr	#1,d0
	andi	#$fff8,d0	* d0 = (xpos/16)*8 = row-offset(bytes)
	movea.l	screen,a1
	add	d0,d1
	adda	d1,a1		* a1 = pointer into display memory

	subq	#1,d5		* prepare for dbra loops
	subq	#1,d6
linxstlp:			* FOR (height of stamp) DO
	move.l	a1,a2		* a2 = pointer into display memory
	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3		* init. for first word (zero-pad-left)
	move	d6,d7

colxstlp:			* FOR (width of stamp) DO
	move	(a0),d0
	lsr.l	d4,d0		* fetch and shift data
	eor	d0,(a2)+	* XOR into memory (plane0)
	move	(a0)+,d0
	swap	d0		* hi-word = old data
	move	(a0),d1
	lsr.l	d4,d1		* fetch and shift data
	eor	d1,(a2)+	* XOR into memory (plane1)
	move	(a0)+,d1
	swap	d1		* hi-word = old data
	move	(a0),d2
	lsr.l	d4,d2		* fetch and shift data
	eor	d2,(a2)+	* XOR into memory (plane2)
	move	(a0)+,d2
	swap	d2		* hi-word = old data
	move	(a0),d3
	lsr.l	d4,d3		* fetch and shift data
	eor	d3,(a2)+	* XOR into memory (plane3)
	move	(a0)+,d3
	swap	d3		* hi-word = old data
	dbra	d7,colxstlp

	clr	d0
	clr	d1
	clr	d2
	clr	d3		* zero-right-fill
	lsr.l	d4,d0
	eor	d0,(a2)+	* shift and XOR into memory (plane0)
	lsr.l	d4,d1
	eor	d1,(a2)+	* shift and XOR into memory (plane1)
	lsr.l	d4,d2
	eor	d2,(a2)+	* shift and XOR into memory (plane2)
	lsr.l	d4,d3
	eor	d3,(a2)+	* shift and XOR into memory (plane3)
	
	adda.w	#160,a1		* bump screen ptr to next line
	dbra	d5,linxstlp

	rts


*
*	DATA STORAGE
*

	.bss
	.even

rplmasks:
	.ds.l	600		* REPLACE Mask Pointer Table
maskbase:
	.ds.w	$4000		* REPLACE Masks Data

	.end
