;*
; Written by Rob Oct 90
; 
; Test code for driver binary... Loads in a tune and plays it
; continually inverting the screen..
; Hit a key to exit
	opt	p+	make position independent

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

;case of _SoundType.w=
	;[0] => internal
	;[1] => Replay 8-bit
	;[2] => Replay 12-bit 
	;[3] => Playbackint
	;[4] => STE sample hardware 

	pea	Prog(pc)
	move.w	#$26,-(sp)	Call SUPERVISOR routine.
	trap	#14
	addq.l	#6,sp
term
	move.w	#0,-(sp)	any value
	move.w	#$4c,-(sp)	P_Term/Quit.
	trap	#1

Prog

*********************************************************************
* Must be in supervisor mode to install and run quartet driver      *
* set up any other interupts you want running first.		    *
*********************************************************************

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


********************************************************************
* Next set up the pointers to the tune and voiceset and call the   *
* start routine to start up the music				   *
********************************************************************

	lea	song1_s(PC),a5		address of song to play ->A5
	move.l	a5,_SongAddr(a6)	inform system of where song is
	lea	voice_s(PC),a5		address of voiceset to use ->A5
	move.l	a5,_VoiceAddr(a6)	...and where current kit is!
	jsr	_Start(a6)		let's go!


*******************************************************************
* Any processing or animation you want to do can go in here	  *
*******************************************************************

main
	* nop

	cmp.b	#185,$fffffc02.w
	bne.s	main

*******************************************************************
* Just call Deinstall to turn everything off			  *
*******************************************************************
desinstall:

	jsr	_DeInstall(a6)

* Just turn the mouse back on
	lea	keydat(PC),A0
	move.b	#$8,(a0)
	bsr	keysend

	rts	return from Super call to Prog



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

* NB -- The following could be loaded into memory by the program
*       I just find it convienient to binary include them


* include the player binary code
sing_s
	incbin	rob5.bin
	even


* include the song and voiceset
song1_s	incbin	*.4V
	even
voice_s	incbin	*.SET
	even

	end

