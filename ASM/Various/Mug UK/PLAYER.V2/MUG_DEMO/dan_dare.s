;---------------------------------
; Dan Dare Quartet Demo by MUG U.K
;---------------------------------

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

	move.w	#4,-(a7)	; store screen resolution
	trap	#14
	addq.l	#2,a7
	move.w	d0,resolut	

	jsr	chip_mus

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
loop	cmp.b	#$0b,$fffc02
	beq	hertz

	cmp.b	#$3b,$fffc02	; f1 = main title
	beq	tune_1

	cmp.b	#$3c,$fffc02
	beq	tune_2

	cmpi.b	#$39,$FFFC02 ; wait for space bar
	bne.s	loop	; not space bar - redo loop

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
;	play main .4V set
;
tune_1	jsr	_DeInstall(a6)
	lea	song1_s(PC),a5		address of song to play ->A5
	move.l	a5,_SongAddr(a6)	inform system of where song is
	lea	voice_s(PC),a5		address of voiceset to use ->A5
	move.l	a5,_VoiceAddr(a6)	...and where current kit is!
	jsr	_Start(a6)		let's go!
	bra	loop

;
; Alter to a second .4V set
;
tune_2	jsr	_DeInstall(a6)
	lea	song2_s(PC),a5		address of song to play ->A5
	move.l	a5,_SongAddr(a6)	inform system of where song is
	lea	voice_s(PC),a5		address of voiceset to use ->A5
	move.l	a5,_VoiceAddr(a6)	...and where current kit is!
	jsr	_Start(a6)		let's go!
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
song1_s	incbin	f:\quartet\hacked\dan_dare.iii\dantitle.4v ; 1st Song
	even
song2_s	incbin	f:\quartet\hacked\dan_dare.iii\hero.4v	; 2nd song
	even
voice_s	incbin	f:\quartet\hacked\dan_dare.iii\dandare.set ; Voice Set
	even
picture	incbin	f:\quartet\hacked\piccies\gazza2.pi1 ; Degas 
	even
;---------------------------------------------------
; Music Equalizer Bars by JFB & Dazzer
;
; Disassembled by MUG U.K for pure nosiness !!
;---------------------------------------------------

chip_mus	move.w	#3,-(a7)	; Get screen address into 'screen'
	trap	#14
	addq.l	#2,a7
	move.l	d0,screen
	addi.l	#$60e0,d0	; add 24800 to it to get 'screen1'
	move.l	d0,screen1

;	move.w	#4,-(a7)	; store screen resolution
;	trap	#14
;	addq.l	#2,a7
;	move.w	d0,resolut	

	bsr	mouseoff	; turn off mouse
	bsr	setscree	; set new screen address
	bsr	setpal	; store & set new palette
	bsr	print	; print text on screen
	bsr	musicon	; start music going on VBL
	MOVE.L	#rip,$4D6.W ; install music analyzer onto VBL

main	

t1	cmpi.b	#$02,$fffc02
	bne.s	t2
	moveq	#0,d0
	jsr	muz

t2	cmpi.b	#$03,$fffc02
	bne.s	t3
	moveq	#1,d0
	jsr	muz

t3	cmpi.b	#$04,$fffc02
	bne.s	t4
	moveq	#2,d0
	jsr	muz

t4	cmpi.b	#$05,$fffc02
	bne.s	sp
	moveq	#3,d0
	jsr	muz

sp	CMPI.B	#$39,$FFFC02 ; wait for space bar
	BNE.S	main	; not space bar - redo loop
	BRA	exit	; it is - so exit program
;
; Music Analyzer - installed on VBL
;
rip	MOVEQ	#0,D0
	MOVEQ	#$F,D1
	LEA	$FF8800,A3
	MOVE.B	#8,(A3)
	MOVE.B	(A3),D0
	AND.W	D1,D0
	MOVE.B	#1,(A3)
	MOVE.B	(A3),D1
	LSL.W	#8,D1
	MOVE.B	#0,(A3)
	MOVE.B	(A3),D1
	LEA	table(PC),A1
	ANDI.L	#$FF,D1
	LSL.W	#2,D1
	SUBA.L	D1,A1
	MOVE.W	2(A1),D5
	MOVEA.W	(A1),A1
	ADDA.L	screen1(PC),A1
	MOVEA.L	A1,A2
	ADDQ.W	#8,D0
L28C0C	OR.B	D5,(A1)
	OR.B	D5,2(A1)
	OR.B	D5,$A0(A2)
	OR.B	D5,$A2(A2)
	LEA	-$A0(A1),A1
	LEA	$A0(A2),A2
	DBF	D0,L28C0C
chanb	MOVEQ	#0,D0
	MOVEQ	#$F,D1
	MOVE.B	#9,(A3)
	MOVE.B	(A3),D0
	AND.W	D1,D0
	MOVE.B	#3,(A3)
	MOVE.B	(A3),D1
	LSL.W	#8,D1
	MOVE.B	#2,(A3)
	MOVE.B	(A3),D1
	LEA	table(PC),A1
	ANDI.L	#$FF,D1
	LSL.W	#2,D1
	SUBA.L	D1,A1
found2	MOVE.W	2(A1),D5
	MOVEA.W	(A1),A1
	ADDA.L	screen1(PC),A1
two	MOVEA.L	A1,A2
	ADDQ.W	#8,D0
L28C5C	OR.B	D5,(A1)
	OR.B	D5,$A0(A2)
	LEA	-$A0(A1),A1
	LEA	$A0(A2),A2
	DBF	D0,L28C5C
chanc	MOVEQ	#0,D0
	MOVEQ	#$F,D1
	MOVE.B	#$A,(A3)
	MOVE.B	(A3),D0
	AND.W	D1,D0
	MOVE.B	#5,(A3)
	MOVE.B	(A3),D1
	LSL.W	#8,D1
	MOVE.B	#4,(A3)
	MOVE.B	(A3),D1
	LEA	table(PC),A1
	ANDI.L	#$FF,D1
	LSL.W	#2,D1
	SUBA.L	D1,A1
found3	MOVE.W	2(A1),D5
	MOVEA.W	(A1),A1
	ADDA.L	screen1(PC),A1
three	MOVEA.L	A1,A2
	ADDQ.W	#8,D0
L28CA4	OR.B	D5,2(A1)
	OR.B	D5,$A2(A2)
	LEA	-$A0(A1),A1
	LEA	$A0(A2),A2
	DBF	D0,L28CA4
decay	MOVEQ	#$1F,D0
	MOVEA.L	screen1(PC),A0
	MOVEA.L	A0,A1
L28CC0	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	MOVE.W	-$A0(A0),(A0)
	MOVE.W	-$9E(A0),2(A0)
	MOVE.W	$A0(A1),(A1)
	MOVE.W	$A2(A1),2(A1)
	LEA	-8(A0),A0
	LEA	8(A1),A1
	DBF	D0,L28CC0
	RTS

exit	CLR.L	$4D6.W
	CLR.L	$4D2.W

offmusic
	jsr	muz+$1c		; switch music off
	LEA	$FF8800,A0
	MOVE.L	#$8080000,(A0)
	MOVE.L	#$9090000,(A0)
	MOVE.L	#$A0A0000,(A0)
	BSR	mouseon
	MOVEM.L	oldpal,D0-D7
	MOVEM.L	D0-D7,$FF8240

	move.w	resolut,-(sp)	; restore resolution 
	move.l	screen,-(sp)
	move.l	screen,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts			; return to Quartet demo

print	move.l	#text,-(a7)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	rts

setscree	MOVE.W	#0,-(A7)
	MOVE.L	screen,-(A7)
	MOVE.L	screen,-(A7)
	MOVE.W	#5,-(A7)
	TRAP	#14
	ADDA.L	#$C,A7
	RTS

setpal	MOVEM.L	$FF8240,D0-D7
	MOVEM.L	D0-D7,oldpal
	MOVEM.L	cols,D0-D7
	MOVEM.L	D0-D7,$FF8240
	RTS

vsync	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	#$25,-(A7)
	TRAP	#14
	ADDQ.L	#2,A7
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

mouseoff	MOVE.L	#moff,-(A7)
	CLR.W	-(A7)
	MOVE.W	#$19,-(A7)
	TRAP	#14
	ADDQ.L	#8,A7
	DC.W	$A00A
	RTS

mouseon	MOVE.L	#mon,-(A7)
	CLR.W	-(A7)
	MOVE.W	#$19,-(A7)
	TRAP	#14
	ADDQ.L	#8,A7
	DC.W	$A009
	RTS

moff	DC.W	$1212
	
mon	DC.W	$0808

musicon	MOVEQ 	#tune_no,D0
	JSR	muz
	MOVE.L	#play,$4D2.W
	RTS

tune_no	equ	0
vbl	equ	$e

play	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(muz+vbl)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

noise_ta	DC.B	0,0,0,$80,0,0,0,$40
	DC.B	0,0,0,$20,0,0,0,$10
	DC.B	0,0,0,8,0,0,0,4
	DC.B	0,0,0,2,0,0,0,1
	DC.B	0,1,0,$80,0,1,0,$40
	DC.B	0,1,0,$20,0,1,0,$10
	DC.B	0,1,0,8,0,1,0,4
	DC.B	0,1,0,2,0,1,0,1
	DC.B	0,8,0,$80,0,8,0,$40
	DC.B	0,8,0,$20,0,8,0,$10
	DC.B	0,8,0,8,0,8,0,4
	DC.B	0,8,0,2,0,8,0,1
	DC.B	0,9,0,$80,0,9,0,$40
	DC.B	0,9,0,$20,0,9,0,$10
	DC.B	0,9,0,8,0,9,0,4
	DC.B	0,9,0,2,0,9,0,1
	DC.B	0,$10,0,$80,0,$10,0,$40
	DC.B	0,$10,0,$20,0,$10,0,$10
	DC.B	0,$10,0,8,0,$10,0,4
	DC.B	0,$10,0,2,0,$10,0,1
	DC.B	0,$11,0,$80,0,$11,0,$40
	DC.B	0,$11,0,$20,0,$11,0,$10
	DC.B	0,$11,0,8,0,$11,0,4
	DC.B	0,$11,0,2,0,$11,0,1
	DC.B	0,$18,0,$80,0,$18,0,$40
	DC.B	0,$18,0,$20,0,$18,0,$10
	DC.B	0,$18,0,8,0,$18,0,4
	DC.B	0,$18,0,2,0,$18,0,1
	DC.B	0,$19,0,$80,0,$19,0,$40
	DC.B	0,$19,0,$20,0,$19,0,$10
	DC.B	0,$19,0,8,0,$19,0,4
	DC.B	0,$19,0,2,0,$19,0,1
	DC.B	0,$20,0,$80,0,$20,0,$40
	DC.B	0,$20,0,$20,0,$20,0,$10
	DC.B	0,$20,0,8,0,$20,0,4
	DC.B	0,$20,0,2,0,$20,0,1
	DC.B	0,$21,0,$80,0,$21,0,$40
	DC.B	0,$21,0,$20,0,$21,0,$10
	DC.B	0,$21,0,8,0,$21,0,4
	DC.B	0,$21,0,2,0,$21,0,1
	DC.B	0,$28,0,$80,0,$28,0,$40
	DC.B	0,$28,0,$20,0,$28,0,$10
	DC.B	0,$28,0,8,0,$28,0,4
	DC.B	0,$28,0,2,0,$28,0,1
	DC.B	0,$29,0,$80,0,$29,0,$40
	DC.B	0,$29,0,$20,0,$29,0,$10
	DC.B	0,$29,0,8,0,$29,0,4
	DC.B	0,$29,0,2,0,$29,0,1
	DC.B	0,$30,0,$80,0,$30,0,$40
	DC.B	0,$30,0,$20,0,$30,0,$10
	DC.B	0,$30,0,8,0,$30,0,4
	DC.B	0,$30,0,2,0,$30,0,1
	DC.B	0,$31,0,$80,0,$31,0,$40
	DC.B	0,$31,0,$20,0,$31,0,$10
	DC.B	0,$31,0,8,0,$31,0,4
	DC.B	0,$31,0,2,0,$31,0,1
	DC.B	0,$38,0,$80,0,$38,0,$40
	DC.B	0,$38,0,$20,0,$38,0,$10
	DC.B	0,$38,0,8,0,$38,0,4
	DC.B	0,$38,0,2,0,$38,0,1
	DC.B	0,$39,0,$80,0,$39,0,$40
	DC.B	0,$39,0,$20,0,$39,0,$10
	DC.B	0,$39,0,8,0,$39,0,4
	DC.B	0,$39,0,2,0,$39,0,1
	DC.B	0,$40,0,$80,0,$40,0,$40
	DC.B	0,$40,0,$20,0,$40,0,$10
	DC.B	0,$40,0,8,0,$40,0,4
	DC.B	0,$40,0,2,0,$40,0,1
	DC.B	0,$41,0,$80,0,$41,0,$40
	DC.B	0,$41,0,$20,0,$41,0,$10
	DC.B	0,$41,0,8,0,$41,0,4
	DC.B	0,$41,0,2,0,$41,0,1
	DC.B	0,$48,0,$80,0,$48,0,$40
	DC.B	0,$48,0,$20,0,$48,0,$10
	DC.B	0,$48,0,8,0,$48,0,4
	DC.B	0,$48,0,2,0,$48,0,1
	DC.B	0,$49,0,$80,0,$49,0,$40
	DC.B	0,$49,0,$20,0,$49,0,$10
	DC.B	0,$49,0,8,0,$49,0,4
	DC.B	0,$49,0,2,0,$49,0,1
	DC.B	0,$50,0,$80,0,$50,0,$40
	DC.B	0,$50,0,$20,0,$50,0,$10
	DC.B	0,$50,0,8,0,$50,0,4
	DC.B	0,$50,0,2,0,$50,0,1
	DC.B	0,$51,0,$80,0,$51,0,$40
	DC.B	0,$51,0,$20,0,$51,0,$10
	DC.B	0,$51,0,8,0,$51,0,4
	DC.B	0,$51,0,2,0,$51,0,1
	DC.B	0,$58,0,$80,0,$58,0,$40
	DC.B	0,$58,0,$20,0,$58,0,$10
	DC.B	0,$58,0,8,0,$58,0,4
	DC.B	0,$58,0,2,0,$58,0,1
	DC.B	0,$59,0,$80,0,$59,0,$40
	DC.B	0,$59,0,$20,0,$59,0,$10
	DC.B	0,$59,0,8,0,$59,0,4
	DC.B	0,$59,0,2,0,$59,0,1
	DC.B	0,$60,0,$80,0,$60,0,$40
	DC.B	0,$60,0,$20,0,$60,0,$10
	DC.B	0,$60,0,8,0,$60,0,4
	DC.B	0,$60,0,2,0,$60,0,1
	DC.B	0,$61,0,$80,0,$61,0,$40
	DC.B	0,$61,0,$20,0,$61,0,$10
	DC.B	0,$61,0,8,0,$61,0,4
	DC.B	0,$61,0,2,0,$61,0,1
	DC.B	0,$68,0,$80,0,$68,0,$40
	DC.B	0,$68,0,$20,0,$68,0,$10
	DC.B	0,$68,0,8,0,$68,0,4
	DC.B	0,$68,0,2,0,$68,0,1
	DC.B	0,$69,0,$80,0,$69,0,$40
	DC.B	0,$69,0,$20,0,$69,0,$10
	DC.B	0,$69,0,8,0,$69,0,4
	DC.B	0,$69,0,2,0,$69,0,1
	DC.B	0,$70,0,$80,0,$70,0,$40
	DC.B	0,$70,0,$20,0,$70,0,$10
	DC.B	0,$70,0,8,0,$70,0,4
	DC.B	0,$70,0,2,0,$70,0,1
	DC.B	0,$71,0,$80,0,$71,0,$40
	DC.B	0,$71,0,$20,0,$71,0,$10
	DC.B	0,$71,0,8,0,$71,0,4
	DC.B	0,$71,0,2,0,$71,0,1
	DC.B	0,$78,0,$80,0,$78,0,$40
	DC.B	0,$78,0,$20,0,$78,0,$10
	DC.B	0,$78,0,8,0,$78,0,4
	DC.B	0,$78,0,2,0,$78,0,1
	DC.B	0,$79,0,$80,0,$79,0,$40
	DC.B	0,$79,0,$20,0,$79,0,$10
	DC.B	0,$79,0,8,0,$79,0,4
	DC.B	0,$79,0,2,0,$79,0,1
	DC.B	0,$80,0,$80,0,$80,0,$40
	DC.B	0,$80,0,$20,0,$80,0,$10
	DC.B	0,$80,0,8,0,$80,0,4
	DC.B	0,$80,0,2,0,$80,0,1
	DC.B	0,$81,0,$80,0,$81,0,$40
	DC.B	0,$81,0,$20,0,$81,0,$10
	DC.B	0,$81,0,8,0,$81,0,4
	DC.B	0,$81,0,2,0,$81,0,1
	DC.B	0,$88,0,$80,0,$88,0,$40
	DC.B	0,$88,0,$20,0,$88,0,$10
	DC.B	0,$88,0,8,0,$88,0,4
	DC.B	0,$88,0,2,0,$88,0,1
	DC.B	0,$89,0,$80,0,$89,0,$40
	DC.B	0,$89,0,$20,0,$89,0,$10
	DC.B	0,$89,0,8,0,$89,0,4
	DC.B	0,$89,0,2,0,$89,0,1

table	DC.L	0
screen1	DC.L	0
screen	DC.L	0
resolut	dc.w	0
oldpal	DS.W	16
cols	DC.W	$000,$700,$777,$770,$000,$000,$000,$000
	DC.W	$000,$000,$000,$000,$000,$000,$000,$777

text	dc.b	27,"E"
	dc.b 	"  +---------------------------------+",$d,$a
	dc.b	"  | MUG U.K¿ presents: Dan Dare III |",$d,$a
	dc.b	"  +---------------------------------+",$d,$a,$a
	dc.b	"As you can hear, I've ripped the chip",$d,$a
	dc.b	"music from this game, as well as the",$d,$a
	dc.b	"Quartet music !!!  Press 1-4 for the",$d,$a
	dc.b	"various tunes.",$d,$a,$a
	dc.b	"Chip & Quartet Music by David Whittaker",$d,$a
	dc.b	"       Chip-Music Analyzer by JFB",$d,$a
	dc.b	"      All music hacks by: MUG U.K¿",$d,$a,$a,$a
	dc.b	"     Press space to start the music.",$d,$a
	dc.b	0
;
; Any music file (data) can go here - ensure that the correct VBL
; offset is used (eg. Mad Max = +8, David. W = +14, Count Zero = +2)
;
muz	incbin	"chip\dan_dare.img"	