****************************************************
* 50/60 Hertz changer for use with Colour monitors *
* Copyright 1990 - Andrew Younger.                 *
*                                                  *
* This was written on Hisoft's DEVPAC version 2.23 *
* This is Public Domain, pass it on!!!!!!!!!!!!!!! *
****************************************************

	OPT	O+, A+	; Devpac options - They help optimise!!

*************************************************

	SECTION	TEXT

*************************************************

; Routine to return all extra memory to GEMDOS

SHRINK:	move.l	a7,a5
	move.l	#USTK,a7

	move.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0

	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp

	bsr.b	MAIN

	move.w	#0,-(sp)
	trap	#1

***********************************************************

MAIN:
	bsr.b	DISPLAY_TITLE
	bsr.b	CHECK_CORRECT_RESOLUTION
	cmp.l	#0,d0	
	bne.b	ERROR_MESSAGE	

	bsr.b	SUPERVISOR_OFF
	bsr.b	HERTZ_FLICK
	bsr.b	SUPERVISOR_ON
	bsr.b	ANY_KEY
	rts
	
***********************************************************

CHECK_CORRECT_RESOLUTION:
	move.w	#2,-(sp)
	trap	#14		; Get resolution
	addq.l	#2,sp
	cmp.w	#3,d0		; Is it in High rez
	beq.b	FAIL		; If so fail
	moveq.l	#0,d0		; Falled through so rez fine!!
	rts
FAIL:	moveq.l	#1,d0		; Signal error!
	rts

***********************************************************

DISPLAY_TITLE:
	pea	START_TXT
	move.w	#9,-(sp)
	trap	#1		; Print title on screen
	addq.l	#6,sp
	rts

ERROR_MESSAGE:
	pea	ERR_TXT
	move.w	#9,-(sp)
	trap	#1		; Print error message onto screen
	addq.l	#6,sp
	bsr.b	ANY_KEY
	rts

***********************************************************

SUPERVISOR_OFF:
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1			; Switch off the supervisor
	addq.l	#6,sp
	move.l	d0,SUPERVISOR_STACK
	rts

SUPERVISOR_ON:
	move.l	SUPERVISOR_STACK,-(sp)
	move.w	#32,-(sp)
	trap	#1			; Switch him back on
	addq.l	#6,sp
	rts

***********************************************************

HERTZ_FLICK:
	bchg	#1,$ff820a	; flip between 50 and 60 hertz
	rts

***********************************************************

ANY_KEY:
	pea	KEY_TXT
	move.w	#9,-(sp)
	trap	#1		; print message
	addq.l	#6,sp

	move.w	#7,-(sp)
	trap	#1		; Wait for keypress
	addq.l	#2,sp
	rts

***********************************************************

	SECTION DATA

START_TXT:
	dc.b	27,"E",7	; clear screen and sound bell
	dc.b	"The 50/60 hertz changer",10,13
	dc.b	"Copyright 1990 Andrew Younger.",10,13
	dc.b	"This is PD - So copy it, but don't sell!",0

ERR_TXT:
	dc.b	10,13,10,13
	dc.b	"This only works on colour monitors!!!!",10,13,0

KEY_TXT:
	dc.b	10,13,10,13
	dc.b	"Press any key to exit!!!!!!",10,13,10,13,0

***********************************************************
	SECTION BSS

SUPERVISOR_STACK:
	ds.l	1

	ds.l	20	; Large enough for this utility!
USTK:	ds.l	1


