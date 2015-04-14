*************************************************************************
*                         Outline 2007 - Intro	                        *
*************************************************************************
* by ray//.tSCc.                                              2002-2007 *
* <ray@tscc.de>                                                         *
* http://ray.tscc.de                                                    *
*************************************************************************
* This program is free software; you can redistribute it and/or modify  *
* it under the terms of the GNU General Public License as published by  *
* the Free Software Foundation; either version 2 of the License, or     *
* (at your option) any later version.                                   *
*************************************************************************


		comment	HEAD=%011	; MallocAlt-, LoadAlt+, Fastload+
		opt	p=68000,o+,ow+	; Optimizations=On

;>DEBUG:
	ifd	DEBUG
		opt	x+,d+
	else
		opt	x-,d-
	endc


        	include	'main.i'


; Select screens to be shown or not

LOGO		=	1
SWIRL		=	1
FIELD		=	1
WATER		=	1
DOOM		=	1


; Demo object table (60Hz Ticks, Class, FunctionCall())
; NOTE: Must be terminated by a HALT object!
;
; Any negative tickvalue causes an init routine to be called once
; WITHOUT any timing.

		data
mainDemoObj:	dc.l	100,INIT,initFontLib

	ifne	SWIRL
		dc.l	1650,INIT,swirlInit
		dc.l	120,INIT,swirlInitFadeOut
		dc.l	650,INIT,showCredits
		dc.l	120,INIT,creditsFadeOut

		dc.l	-1,INIT,logoInit
		dc.l	120,MAIN,logoInMain

		dc.l	-1,INIT,swirlFadeIn
		dc.l	800,MAIN,swirlMain
		dc.l	120,MAIN,swirlFadeOut
		dc.l	-1,DEINIT,swirlDeinit
	endc
	ifne	FIELD
		dc.l	770,INIT,fieldInit
		dc.l	120,INIT,fieldInitFadeOut

		dc.l	-1,INIT,fieldFadeIn
		dc.l	1760,MAIN,fieldMain ;; 800
		dc.l	120,MAIN,fieldFadeOut
		dc.l	-1,DEINIT,fieldDeinit
	endc
	ifne	WATER
		dc.l	800,INIT,waterInit
		dc.l	120,INIT,waterInitFadeOut
		dc.l	-1,INIT,fadeInWater
		dc.l	1700,MAIN,waterMain
		dc.l	120,MAIN,fadeOutWater
		dc.l	10,DEINIT,restoreWater
	endc
	ifne	DOOM
		dc.l	-1,INIT,greetInit
		dc.l	10000,MAIN,greetMain	; Show greetings

		dc.l	600,INIT,initDoom
		dc.l	-1,INIT,fadeInDoom
		dc.l	1100,MAIN,doomMain
		dc.l	80,MAIN,fadeOutDoom
		dc.l	10,DEINIT,restoreDoom
	endc
	ifne	LOGO
		dc.l	120,MAIN,logoOutMain
	endc
		dc.l	60,INIT,endingInit
		dc.l	300000,MAIN,endingMain

		dc.l	-1,HALT,void		; Stop object



; Main program

		text
main:		bsr.w	AtariInit

		lea.l	msxTVS,a0	; Initialize SSD driver
		lea.l	msxTRI,a1
		jsr	ssdDriver


; Start demo

		lea.l	mainDemoObj,a0
		bsr.w	execDemo

		move.l	#msxDriver,VBLHookPtr2	; Install msx driver as 2nd VBL routine


; Main demo loop

.mainloop:	move.l	initPtr(pc),d0	; Call initialization routine, if any
		beq.s	.init_null

                movea.l	d0,a0
		jsr	(a0)
		clr.l	initPtr	; Set semaphore by removing the routine pointer
		bra.s	.break

.init_null:	move.l	mainPtr(pc),d0	; Call main routine, if any
		beq.s	.break

		movea.l	d0,a0
		jsr	(a0)

.break:		tst.b	halt		; Exit demo?
		bne.s	.exit

		cmpi.b	#$39,$fffffc02.w	; Exit on space
		bne.s	.mainloop

.exit:		jsr	ssdDriver+8	; Stop SSD player

		bra.w	AtariRestore


*************************************************
*  void void()
*
* Idle routine
*************************************************

void:		rts


*************************************************
*  void execDemo(a0.l * demoObject)
*
* Execute the given demo object.
*************************************************

execDemo:	move.l	a0,demoObjPtr

; Initialize first effect

		move.l	4(a0),d0	; Dispatch object type
		move.l	.jmptable(pc,d0.l),-(sp)
		rts

.jmptable:	dc.l	.init
		dc.l	.deinit
		dc.l	.main
		dc.l	.halt

.init:
.deinit:        move.l	8(a0),initPtr	; Initialize init routine pointer
		clr.l	mainPtr
		bra.s	.break

.main:          clr.l	initPtr
		move.l	8(a0),mainPtr	; Initialize main routine pointer
		bra.s	.break

.halt:		clr.l	initPtr
		clr.l	mainPtr
		st.b	halt

.break:		;;move.l	$114.w,saveTimerC
		;;move.l	#demoTimerC,$114.w	; Install demo Demo sequencer ISR
		move.l	#demoTimerC,VBLTailPtr
		rts


demoObjPtr:     dc.l	NULL		; Demo object pointer

initPtr:	dc.l	void		; Current init routine
mainPtr:	dc.l	void		; Current main routine

halt:		dc.b	FALSE		; Halt flag
		even

saveTimerC:	dc.l	NULL


*************************************************
*  void interrupt demoTimerC()
*
* 100Hz Demo sequencer ISR.
*************************************************

demoTimerC:	btst.b	#0,$4bd.w	; Execute each second event in order to
		bne.s	.odd		; obtain a 100Hz frequency

       		movem.l	d0/a0,-(sp)

		movea.l	demoObjPtr(pc),a0	; Retrieve demo object pointer

		subq.l	#1,(a0)		; --tick_value == 0?
		bne.s	.break

		lea.l	12(a0),a0	; Skip to next part
		move.l	a0,demoObjPtr

		move.l	4(a0),d0	; Dispatch object type
		move.l	.jmptable(pc,d0.l),-(sp)
		rts

.jmptable:	dc.l	.init
		dc.l	.deinit
		dc.l	.main
		dc.l	.halt

.init:
.deinit:        move.l	8(a0),initPtr	; Initialize init routine pointer
		clr.l	mainPtr
		bra.s	.break

.main:          clr.l	initPtr
		move.l	8(a0),mainPtr	; Initialize main routine pointer
		bra.s	.break

.halt:		clr.l	initPtr
		clr.l	mainPtr
		st.b	halt

.break:		movem.l	(sp)+,d0/a0
.odd:		;;move.l	saveTimerC(pc),-(sp)		; Execute previous ISR
		;;rts
		rte

*************************************************
*  void setSemaphore()
*
* Mark whether an init routine has been called
* already. This is supposed to be used for untimed
* init routines with a tickvalue of -1.
*************************************************

setSemaphore:	movea.l	demoObjPtr(pc),a0	; demoObjPtr->tics = 1
		move.l	#1,(a0)
		rts


*************************************************
*  void interrupt msxDriver()
*
* SSD music feeder, install as 60Hz VBL handler.
*************************************************

msxDriver:	subi.w	#50,._50hz		; 50Hz tickcounter, keep in mind this
		bpl.s	.break			; routine is called at a 60Hz frequency
		addi.w	#60,._50hz

		jmp	ssdDriver+4		; Call SSD feeder

.break:		rts

._50hz:		dc.w	60


; Includes

		include	'ATARI.S'	; System library

		include	'FLOORSKY.S'	; Effect modules
		include	'FLDLINES.S'
		include	'SWIRL.S'
		include	'WATER.S'
       		include	'LOGOS.S'
		include	'FONTLIB.S'
		include	'GREET.S'
		include	'ENDING.S'


		section	data
ssdDriver:	incbin	'ssd_acd.drv'		; Sid Sound music driver
		even
msxTRI:		incbin	'eshox.tri'
		even
msxTVS:		incbin	'eshox.tvs'
		even
                end

