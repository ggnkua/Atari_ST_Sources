;***********************************************************************
;
; SOUNDCMD.S
;
;	Atari MetaDOS sound selection functions		Mike Schmal
;
;	Started:	04/24/92
;	Last Update:	07/08/92
;
;	Copyright Atari Corporation 1992
;
; Updates:
;
;	
;
;************************************************************************

.include "spardef.inc"


; soundcmd sub-opcodes
LTATTEN		=	0
RTATTEN		=	1
LTGAIN		=	2
RTGAIN		=	3
ADDERIN		=	4
ADCINPUT	=	5
SETPRESCALE	=	6
LASTCMD		=	SETPRESCALE

; --------------------------------------------------
; Internal variables
; --------------------------------------------------
	.globl	oldvol

; --------------------------------------------------
; Internal Routines
; --------------------------------------------------
	.globl	soundcmd		; Perform a sound functions.


	.text
;************************************************************************
; soundcmd 	Performs one of several sound setup commands.
;
;	GIVEN:
;		4(sp)	Opcode
;		6(sp)	mode.w
;		8(sp)	data.w
;
;	RETURNS:
;		Never fails
;
;************************************************************************
; stack args:
snd_op		equ 4
snd_data	equ 6
;
soundcmd:
	move.w	snd_op(sp),d0
	cmp.w	#LASTCMD,d0
	bgt	.error
	tst.w	d0
	blt	.error
	asl.w	#2,d0
	lea	selectsnd,a0
	move.l	(a0,d0),a0
	jmp	(a0)

.error:
	clr.l	d0	; Returns complete as per L.T.
	rts

; ************************************************************************
; ltatten	Set or get left attenuation
;
;	Given:		8(sp).w	attenuation
;			IF(-1) return attenuation.
;
;	Returns:	d0 = current left volume setting.
;	uses:		d0
; ************************************************************************

ltatten:
	move.w	snd_data(sp),d0
	bmi	.get
	asl.w	#4,d0		; Align
	and.w	#$0F00,d0
	and.w	#$F0FF,auxb_ctl	; Strip it
	or.w	d0,auxb_ctl
	move.w	auxb_ctl,oldvol
.get:
	clr.l	d0
	move.w	auxb_ctl,d0
	and.w	#$0F00,d0
	asr.w	#4,d0
	rts


; ************************************************************************
; rtatten	Set or get rightattenuation
;
;	Given:		8(sp).w	rightattenuation
;			IF(-1) return attenuation.
;
;	Returns:	d0 = current right attenuation
;	uses:		d0
; ************************************************************************
rtatten:
	move.w	snd_data(sp),d0
	bmi	.get
	and.w	#$00F0,d0
	and.w	#$FF0F,auxb_ctl	; Strip it
	or.w	d0,auxb_ctl	; Setit.
	move.w	auxb_ctl,oldvol
.get:
	clr.l	d0
	move.w	auxb_ctl,d0
	and.w	#$00F0,d0
	rts

; ************************************************************************
; ltgain	Set or get left gain
;
;	Given:		8(sp).w left gain
;			IF(-1) return gain
;
;	Returns:	d0 = current left gain
;	uses:		d0
; ************************************************************************
ltgain:
	move.w	snd_data(sp),d0
	bmi	.get
	and.w	#$00F0,d0
	and.w	#$FF0F,auxa_ctl
	or.w	d0,auxa_ctl	; Setit.
.get:
	clr.l	d0
	move.w	auxa_ctl,d0
	and.w	#$00F0,d0
	rts

; ************************************************************************
; rtgain:	Set or get right gain
;
;	Given:		8(sp).w	right attenuation
;			IF(-1) return attenuation.
;
;	Returns:	d0 = current left volume setting.
;	uses:		d0
; ************************************************************************
rtgain:
	move.w	snd_data(sp),d0
	bmi	.get
	asr.w	#4,d0		; Align
	and.w	#$000F,d0
	and.w	#$FFF0,auxa_ctl	; Strip it
	or.w	d0,auxa_ctl
.get:
	clr.l	d0
	move.w	auxa_ctl,d0
	and.w	#$000F,d0
	asl.w	#4,d0
	rts

; ************************************************************************
; adderout	Set or get the output of the adder.
;
;	Given:		8(sp).w	output src
;			IF(-1) return attenuation.
;
;	Returns:	Output source bitmap:
;			bit
;			  0	- ADC
;			  1	- Matrix
;	uses:		d0
; ************************************************************************
adderout:
	move.w	snd_data(sp),d0
	bmi	.get
	and.w	#$0003,d0
	and.w	#$FFFC,dacrec_ctl
	or.w	d0,dacrec_ctl
.get:
	clr.l	d0
	move.w	dacrec_ctl,d0
	and.w	#$0003,d0
	rts

; ************************************************************************
; adcinput	Set or get the input to the acd.
;
;	Given:		8(sp).w	output src
;			IF(-1) return attenuation.
;
;			00 - Left and Right are Microphone input
;			11 - Left and Right are PSG input
;
;	Returns:	adc input.
;	uses:		d0
; ************************************************************************
adcinput:
	move.w	snd_data(sp),d0
	bmi	.get
	asl.w	#8,d0
	and.w	#$0300,d0
	and.w	#$FCFF,auxa_ctl
	or.w	d0,auxa_ctl
.get:
	clr.l	d0
	move.w	auxa_ctl,d0
	asr.w	#8,d0
	rts

; ************************************************************************
; setprescale	Set or get compatability prescale.
;
;	Given:		8(sp).w	attenuation
;			IF(-1) return attenuation.
;
;	Returns:	d0 = current prescaler setting.
;	uses:		d0
; ************************************************************************
setprescale:
	move.w	snd_data(sp),d0
	bmi	.get
	and.w	#$0003,d0
	and.w	#$FFFC,snd_modectl
	or.w	d0,snd_modectl
.get:
	clr.l	d0
	move.w	snd_modectl,d0
	and.w	#$0003,d0	
	rts



	.data
	.even
selectsnd:				; selectSND function table.
	.dc.l	ltatten		; 0 
	.dc.l	rtatten		; 1
	.dc.l	ltgain		; 2 
	.dc.l	rtgain		; 3 
	.dc.l	adderout	; 4
	.dc.l	adcinput	; 5
	.dc.l	setprescale	; 6


