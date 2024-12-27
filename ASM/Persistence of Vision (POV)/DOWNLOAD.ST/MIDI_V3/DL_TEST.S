*************************************************************************
*			Widget down loader test code			*
*			----------------------------			*
*									*
*									*
*									*
* Written by:	Mac Sys Data of Persistence Of Vision			*
*									*
*									*
* Date:		29-March-1995						*
*									*
*									*
*************************************************************************
*
* All code ½ Persistence Of Vision 1995
*
* Based on original code by LEO SKIRENKO and PHILIP WATTS.
*
* This code is for Version 3.0 of the Widget 'home brew' PDS system
*************************************************************************


		include	sttx.s		;include Transmit code


		org	$30000		;origin to start of code in memory
exec_addr
mycode
;bit of example code...
		clr.w	$ffff8240.w	;make background colour black

		move.l	$44e.w,a0	;get screen base
		move.w	#32000-1,d0	;get ST screen size
fill		move.b	#-1,(a0)+	;fill screen byte
		move.w	#100-1,d1	;do pause so you can see it
pause		nop
		dbf	d1,pause
		dbf	d0,fill

		move.l	4.w,a0		;reset ST ready for next download
		jmp	(a0)
myend


CODE_LENGTH	equ	myend-mycode


