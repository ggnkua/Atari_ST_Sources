*************************************************************************
*		   Mandelbrot fractal explorer	                        *
*************************************************************************
* Copyright (C) 2005 by 						*
* ray//.tSCc. <ray@tscc.de>						*
*									*
* This program is free software; you can redistribute it and/or modify	*
* it under the terms of the GNU General Public License as published by	*
* the Free Software Foundation; either version 2 of the License, or	*
* (at your option) any later version.					*
*************************************************************************

		opt	p=68030,d-,o+,ow+
		comment	HEAD=%111
		output	mandel.prg

		include	'defs.i'

		section	text
main		bsr.w	buildSqrTable	; Generate s^2 table
		bsr.w	initAtari

		moveq.l	#MODE320480,d0	; Set 320x480x8bpl
		moveq.l	#RFRSH5060,d1
		moveq.l	#0,d3		; grayscale = off 
		bsr.w	setMode
		bsr.w	setGradient	; Set a nice color table

		bsr.w	paintCursor	; Enter mainloop
		bra.s	.repaint
		
.mainloop	bsr.w	wVbl
		bsr.w	paintCursor

		move.b	scanCode,d7
		cmpi.b	#KEY_QUIT,d7
		beq.s	.break

		btst.b	#1,mState
		bne.s	.dontClrRefr
		
		sf.b	.refSmphr

.dontClrRefr	btst.b	#1,mState	; Refresh view? (Left mouse button)
		beq.s	.dontRefr
		tas.s	.refSmphr	; only once please
		bne.s	.dontRefr
		
.repaint	movem.l	slctLeft(pc),d0-d1	; Update coordinates
		movem.l	d0-d1,xMin

		bsr.w	plotMandel	; Redraw the fractal
		clr.w	mXinc
		bsr.w	paintCursor	; Has a redrawing bug here...
		
.dontRefr	btst.b	#0,mState	; Reset the view? (Right mouse button)
		beq.s	.dontReset

		lea.l	mXfrac(pc),a0	; Reset cursor position
		move.l	#(XRES/2)<<8,(a0)+
		move.l	#(YRES/2)<<8,(a0)+

		move.l	#(XMIN<<16)|XMAX,slctLeft
		move.l	#(YMIN<<16)|YMAX,slctTop
		bra.s	.repaint
	
.dontReset	bsr.w	slctArea
		bra.w	.mainloop


.break		bra.w	restoreAtari

.refSmphr	ds.b	1
		even


; Subs
		include	'atari.s'
		include	'video.s'
		include	'fractal.s'	
		end
