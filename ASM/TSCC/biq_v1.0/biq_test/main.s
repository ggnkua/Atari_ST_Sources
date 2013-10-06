*************************************************************************
*		    BiQ image codec test program			*
*************************************************************************
* Copyright (C) 2005 by 					   2006 *
* ray//.tSCc. <ray@tscc.de>						*
*									*
* This program is free software; you can redistribute it and/or modify	*
* it under the terms of the GNU General Public License as published by	*
* the Free Software Foundation; either version 2 of the License, or	*
* (at your option) any later version.					*
*************************************************************************

		opt	p=68030,d-,o+,ow+
		comment	HEAD=%111

GRY_8BPP	=	$00
PAL_8BPP	=	$01
RGB_24BPP	=	$02

MODE		=	GRY_8BPP	; Select between 8bpp grayscale/
					; colormapped and 24bpp RGB here
			
	ifeq	MODE-GRY_8BPP
		output	8bpp_gry.tos
	endc
	ifeq	MODE-PAL_8BPP
		output	8bpp_pal.tos
	endc
	ifeq	MODE-RGB_24BPP
		output	24bpprgb.tos
	endc

		include	'defs.i'

		section	text
main:		bsr.w	initAtari

	ifeq	MODE-RGB_24BPP			; Don't attempt to run the
;>		cmpi.w	#TT030,sysMachine	; truecolor mode on the TT
		tst.w	sysMachine
		bne.s	.f030

		lea.l	TT030Fail,a0	; Print out error message and exit
		bsr.w	writeln
		bra.s	.break
.f030:
	endc

		moveq.l	#MODE320192,d0	; Switch screen mode
		moveq.l	#RFRSH5060,d1
	ifeq	MODE-GRY_8BPP
		moveq.l	#TRUE,d3	; grayscale = false
	else
		moveq.l	#FALSE,d3	; grayscale = true
	endc
		bsr.w	setMode


; Decode image using the image

	ifeq	MODE-GRY_8BPP
		bsr.w	setGray		; Set up grayscale ramp

		lea.l	BiQ,a0
		lea.l	screen8bpp,a1
		lea.l	temp,a2
		bsr.w	d_BiQ_8bGray
	endc
	ifeq	MODE-PAL_8BPP
		lea.l	BiQ,a0   	; Set up color table
		move.l	a0,-(sp)
		bsr.w	setColors

		movea.l	(sp)+,a0
		lea.l	screen8bpp,a1
		lea.l	temp,a2
		bsr.w	d_BiQ_8bColor
	endc
	ifeq	MODE-RGB_24BPP
		lea.l	BiQ,a0
		lea.l	temp,a1
		movea.l	wrkScreen2(pc),a2
		bsr.w	d_BiQ_24bRGB
	endc


	ifne	MODE-RGB_24BPP
		lea.l	screen8bpp,a0
		movea.l	wrkScreen1(pc),a1
		bsr.w	blit8bpp

		moveq.l	#2,d0
	else
		moveq.l	#3,d0
	endc
		bsr.w	cycleScreens

.wait:		cmpi.b	#KEY_QUIT,$fffffc02.w
		bne.s	.wait

.break:		bra.w	restoreAtari


; Subroutines

		include	'atari.s'
		include	'video.s'

	ifeq	MODE-GRY_8BPP
		include	'biq8bppg.s'

		section	data
BiQ:		incbin	'images\8bpp_gry.biq'
	endc

	ifeq	MODE-PAL_8BPP
		include	'biq8bppc.s'

		section	data
BiQ:            incbin	'images\8bpp_pal.biq'
	endc

	ifeq	MODE-RGB_24BPP
		include	'biq24bpp.s'

                section	data
TT030Fail:	dc.b	10,'The 24bpp truecolor mode is not supported on TT030 hardware.',13,10,0
		even
BiQ:		incbin	'images\24bpprgb.biq'
	endc
        	even

		section	bss		; BiQ Workbuffer
temp:		ds.b	XRES*YRES*(COLORDEPTH/8)
		end
