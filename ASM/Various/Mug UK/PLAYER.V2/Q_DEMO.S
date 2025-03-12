;---------------------------------------------------------
; Quartet Demo by MUG U.K - uses original Quartet Tunes !!
;---------------------------------------------------------

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
start	move.l a7,a5		; reserve memory
	move.l 4(a5),a5
	move.l $c(a5),d0
	add.l $14(a5),d0
	add.l $1c(a5),d0
	add.l #$100,d0
	move.l d0,-(sp)
	move.l a5,-(sp)
	move.w #0,-(sp)
	move.w #$4a,-(sp)
	trap #1
	add.l #12,sp

	clr.w	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#4,sp
	move.l	d0,old_sp

	bclr	#0,$484.w	; turn off key-click
	bclr	#1,$484.w ; turn off key-repeat

flush	btst.b	#0,$fffc00	IS A CHARACTER WAITING ?
	beq.s	prog		BR. IF NOT
	move.b	$fffc02,d0	READ CHARACTER (& IGNORE IT)
	bra.s	flush		CHECK FOR ANOTHER

* Turn mouse off at Keyboard processor to avoid noise
* If you want to use the mouse you will have to install your
* own keyboard routine (See manual)

prog	lea	keydat(PC),a0
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
loop	
	cmp.b	#$0b,$fffc02
	beq	hertz

	cmp.b	#$02,$fffc02	; 1 = main title
	beq	tune_1

	cmp.b	#$03,$fffc02	; 2 = second tune
	beq	tune_2

	cmp.b	#$04,$fffc02	; 3 = third tune
	beq	tune_3

	cmp.b	#$05,$fffc02	; 4 = fourth tune
	beq	tune_4

	cmp.b	#$06,$fffc02	; 5 = fifth tune
	beq	tune_5

	cmp.b	#$07,$fffc02	; 6 = sixth tune
	beq	tune_6

	cmp.b	#$08,$fffc02	; 7 = seventh tune
	beq	tune_7

	cmp.b	#$09,$fffc02	; 8 = eighth tune
	beq	tune_8

	cmpi.b	#$39,$FFFC02 ; wait for space bar
	bne	loop	; not space bar - redo loop

*******************************************************************
* Just call Deinstall to turn everything off			  *
*******************************************************************

leave	jsr	_DeInstall(a6)

	lea	keydat(PC),A0	; restore mouse
	move.b	#$8,(a0)
	bsr	keysend

	movem.l	oldcols,d0-d7
	movem.l	d0-d7,$ff8240
	
	move.w	rez,-(sp)
	move.l	scr,-(sp)
	move.l	scr,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	bset	#0,$484.w	; turn off key-click
	bset	#1,$484.w ; turn off key-repeat

	move.l	old_sp,-(sp)
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
	move.l	d0,scr

setscr	clr.w	-(sp)
	move.l	scr,-(sp)
	move.l	scr,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	move.l	#picture+2,-(sp)	; new palette
	move.w	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	
	move.l	#$7d00-1,d0	; set up picture
	move.l	#picture+34,a0	
	move.l	scr,a1
.1	move.b	(a0)+,(a1)+
	dbf	d0,.1
	rts


hertz	eori.b	#$fe,$ffff820a
	bra	loop

one	eor.w	#$777,$ff8240
	bra	loop
;
;	Play different tunes
;
tune_1	jsr	_DeInstall(a6)
	lea	song1_s(PC),a5
	move.l	a5,_SongAddr(a6)
	bra.s	exitune

tune_2	jsr	_DeInstall(a6)
	lea	song2_s(PC),a5
	move.l	a5,_SongAddr(a6)
	bra.s	exitune

tune_3	jsr	_DeInstall(a6)
	lea	song3_s(PC),a5	
	move.l	a5,_SongAddr(a6)	
	bra.s	exitune

tune_4	jsr	_DeInstall(a6)
	lea	song4_s(PC),a5
	move.l	a5,_SongAddr(a6)
	bra.s	exitune

tune_5	jsr	_DeInstall(a6)
	lea	song5_s(PC),a5
	move.l	a5,_SongAddr(a6)
	bra.s	exitune

tune_6	jsr	_DeInstall(a6)
	lea	song6_s(PC),a5
	move.l	a5,_SongAddr(a6)
	bra.s	exitune

tune_7	jsr	_DeInstall(a6)
	lea	song7_s(PC),a5
	move.l	a5,_SongAddr(a6)
	bra.s	exitune

tune_8	jsr	_DeInstall(a6)
	lea	song8_s(PC),a5
	move.l	a5,_SongAddr(a6)

exitune	lea	voice_s(PC),a5
	move.l	a5,_VoiceAddr(a6)
	jsr	_Start(a6)
	bra	loop

oldcols	ds.w	16
old_sp	ds.l	1
rez	dc.w	0
scr	ds.l	1

*****************************************************************
* External Data Files Go Here !!
*****************************************************************

sing_s	incbin	rob5.bin		; Quarter Player Routine
	even
song1_s	incbin	e:\quartet\demo1.4v	; 1st Song
	even
song2_s	incbin	e:\quartet\demo2.4v	; 2nd song
	even
song3_s	incbin	e:\quartet\demo3.4v	; 3rd song
	even
song4_s	incbin	e:\quartet\demo4.4v	; 4th song
	even
song5_s	incbin	e:\quartet\demo5.4v	; 5th song
	even
song6_s	incbin	e:\quartet\demo6.4v	; 6th song
	even
song7_s	incbin	e:\quartet\demo7.4v	; 7th song
	even
song8_s	incbin	e:\quartet\demo8.4v	; 8th song
	even
voice_s	incbin	e:\quartet\voice.set	; Voice Set
	even
picture	incbin	e:\quartet\hacked\piccies\spindizy.pi1 ; Degas 
	even
