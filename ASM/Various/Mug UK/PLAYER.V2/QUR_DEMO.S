;-------------------------------------------------
; Original source was written by Rob Oct 90
;-------------------------------------------------

	opt	d+

;Constant Offsets from start of DRIVER.BIN
_Install equ	$0000		sets up timer A & C vectors & installs
_DeInstall equ	$0004		restores old vectors etc
_Start	equ	$0008		start playing tune (_SongAddr,_VoiceAddr)
_Stop	equ	$000C		stop playing current tune
_Restart equ	$0010		restart playing current tune
_SongAddr equ	$002C	.l	holds address of song
_VoiceAddr equ	$0030	.l	holds address of 20-voice kit
_IRQmask equ	$0038	.w	holds normal IRQ mask to write to MFP
_SoundType equ	$003a	.w	holds low level sound driver type number


Prog	clr.w	-(sp)
	move.w	#$20,-(sp)	Call SUPERVISOR
	trap	#1
	addq.l	#4,sp
	move.l	d0,oldsp

* Turn mouse off at Keyboard processor to avoid noise
* If you want to use the mouse you will have to install your
* own keyboard routine (See manual)

	lea	keydat(PC),a0
	move.b	#$12,(a0)
	bsr	keysend

*********************************************************************
* First you must install the quartet driver for a given output type *
*  Specify the MFP interupts you want to remain enabled by putting  *
*  a mask into _IRQmask. the first byte goes to IMRA and IERA, the  *
*  second goes to IMRB and IERB					    *
*********************************************************************

	lea	sing_s(pc),a6		get playback routine start address
	move.w	#$1e64,_IRQmask(a6)	; stick $40 in for keyboard only
	move.w	#0,_SoundType(a6)	default, ie internal sound
	jsr	_Install(a6)

;case of _SoundType.w=
	;[0] => internal
	;[1] => Replay 8-bit
	;[2] => Replay 12-bit 
	;[3] => Playbackint
	;[4] => STE sample hardware 

********************************************************************
* Next set up the pointers to the tune and voiceset and call the   *
* start routine to start up the music				   *
********************************************************************

	lea	song1_s(PC),a5		address of song to play ->A5
	move.l	a5,_SongAddr(a6)	inform system of where song is
	lea	voice_s(PC),a5		address of voiceset to use ->A5
	move.l	a5,_VoiceAddr(a6)	...and where current kit is!
	bsr	initial
	jsr	_Start(a6)		let's go!

*******************************************************************
* Any processing or animation you want to do can go in here	  *
*******************************************************************
loop	move.w	#$ff,-(sp)		* use gem key scan cause I'm lazy
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	
zero	cmp.b	#$30,d0		; 0 = 50/60hz toggle
	beq	hertz
	
uno	cmp.b	#$31,d0		; 1 = File one
	beq	one
	
	tst.w	d0
	beq	loop

*******************************************************************
* Just call Deinstall to turn everything off			  *
*******************************************************************

exit	jsr	_DeInstall(a6)

	lea	keydat(PC),A0	; restore mouse
	move.b	#$8,(a0)
	bsr	keysend

quit	movem.l	oldcols,d0-d7
	movem.l	d0-d7,$ff8240
	
	move.w	rez,-(sp)
	move.l	screen,-(sp)
	move.l	screen,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	move.l	oldsp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp	

	move.w	#0,-(sp)	any value
	move.w	#$4c,-(sp)	P_Term/Quit.
	trap	#1

keysend:
	pea	keydat(PC)
	move.w	#0,-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp
	rts

keydat	dc.w	0

*******************************************************************
* This can be used to temporarilly stop a song			  *
*******************************************************************
stopsong
	lea	sing_s(pc),a6
	jmp	_Stop(a6)		stop!

*******************************************************************
* This can be used to restart a stopped song			  *
*******************************************************************
restartsong
	;should have started (& stopped) a song before calling this!
	;but the program double-checks anyway
	lea	sing_s(pc),a6
	jmp	_Restart(a6)		restart!

*******************************************
* Screen Set up & other routines for demo *
*******************************************
initial	movem.l	$ff8240,d0-d7	; save current palette
	movem.l	d0-d7,oldcols

getrez	move.w	#4,-(sp)		; get current resolution
	trap	#14
	addq.l	#2,sp
	move.w	d0,rez

getscr	move.w	#2,-(sp)		; get current screen address
	trap	#14
	addq.l	#2,sp
	move.l	d0,screen

setscr	clr.w	-(sp)
	move.l	screen,-(sp)
	move.l	screen,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

setpal	move.l	#picture+2,-(sp)
	move.w	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	
putpic	move.l	#$7d00-1,d0
	move.l	#picture+34,a0
	move.l	screen,a1
.1	move.b	(a0)+,(a1)+
	dbf	d0,.1
	rts

vsync	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d7/a0-a6
	rts

hertz	eori.b	#$fe,$ffff820a
	bra	loop

one	eor.w	#$777,$ff8240
	bra	loop

oldcols	ds.w	16
oldsp	ds.l	1
rez	dc.w	0
screen	ds.l	1

*****************************************************************
* External Data Files Go Here !!
*****************************************************************

sing_s	incbin	rob5.bin		; Quarter Player Routine
	even

song1_s	incbin	e:\quartet\hacked\killing.4v	 ; Song Data
	even
voice_s	incbin	e:\quartet\hacked\killing.set ; Voice Set
	even
picture	incbin	e:\quartet\hacked\piccies\killing.pi1 ; Degas 
	even
