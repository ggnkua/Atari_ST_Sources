; ***********************************************************************
;
; sndlow.s
;
;	The Low level sound function calls.
;
;	Copyright Atari Corporation 1992
;
;	Started:	06/12/92
;	Last Update:	07/06/92
;
;
; UPDATES:
; 07/15/92  MS Changed setinterrupt due to doc error.
; 07/13/92 MS  Changed buffoper to return the current setting if mode = -1
;	   MS  Added function buffptr to return the play and record buffer
;		pointers.
;
; ***********************************************************************

.include "e:\\include\\spardef.inc"



;
; Added SOUND BIOS Errors.
;
SNDNOTLOCK	=	-128
SNDLOCKED	=	-129


; --------------------------------------------------
; Internal routines.
; --------------------------------------------------
	.globl	locksnd			; $80 Open a sound channel
	.globl	unlocksnd		; $81 Close a sound channel.
	.globl	soundcmd		; $82 Perform a sound functions.
	.globl	setbuffer		; $83 play or record buffer pointers.
	.globl	setmode			; $84 play mode 8/16 bit Mono/Stereo
	.globl	settrack		; $85 number of tracks and monitor track
	.globl	setmontrack		; $86 Set monitor track.
	.globl	setinterrupt		; $87 interrupt type
	.globl	buffoper		; $88 Set buffer operation.
	.globl	dsptristate		; $89 Tristates DSP bus
	.globl	gpio			; $8A Talks to gpio acording to mode.
	.globl	devconnect		; $8B connects src to dst devices.
	.globl	sndstatus		; $8C Get the current codec status.
	.globl	buffptr			; $8D Return current play/record pointers
	.globl	func_error		; $8E - $9f 

	.text
;************************************************************************
; $80 locksnd		Lock sound system from other devices.
;
;	LONG locksnd();
;
;	GIVEN:
;		nothing
;
;	RETURNS:
;		1  for sound channel ID.
;		or SNDLOCKED
;
;************************************************************************
locksnd:
	bset	#1,chanlock		; KLUDGE KLUDGE
	bne	.error
	st	chanlock
	move.l	#1,d0
	rts
.error:
	move.l	#SNDLOCKED,d0		; Else error
	rts
	
;************************************************************************
; $81 unlocksnd		Only one sound channel availabel one (0)
;
;	LONG unlocksnd();
;
;	GIVEN:		
;		4(sp)	Sound channel to close.
;
;	RETURNS:
;		0 Sound channel closed
;		or SNDNOTLOCK
;
;************************************************************************
unlocksnd:
	tst.b	chanlock
	beq	.error
	sf	chanlock
	clr.l	d0
	rts
.error:
	move.l	#SNDNOTLOCK,d0
	rts


;************************************************************************
; setbuffer
;
;	Given:		4(sp)	Opcode
;			6(sp)	register to set 0 - Play 1 - Record
;			8(sp)	Beggining addr
;			12(sp)	Ending Addr
;
;	Returns:	d0	0 - No Error.
;				MI  Error
;	
;************************************************************************
setbuffer:
	tst.w	6(sp)
	beq	.play
	bset	#RS,snd_dmsctl+1	; Setting record registers.
	bra	.cont
.play:
	bclr	#RS,snd_dmsctl+1	; Setting play registers.
.cont:
	clr.w	d0
	move.b	11(sp),d0
	move.w	d0,ST_SNDL		; set DMA destination address
	move.b	10(sp),d0
	move.w	d0,ST_SNDM
	move.b	9(sp),d0
	move.w	d0,ST_SNDH
;
	move.b	15(sp),d0
	move.w	d0,END_SNDL		; set DMA destination address
	move.b	14(sp),d0
	move.w	d0,END_SNDM
	move.b	13(sp),d0
	move.w	d0,END_SNDH
	clr.l	d0
	rts


;************************************************************************
; setmode
;
;	Set the type of sound to play.
;
;	Given:		4(sp)	Opcode
;			6(sp)	0 - 8 bit Mono, 1 - 16 Bit Stereo,
;				2 - 8 Bit Stereo.
;
;	Returns:	d0	0 - No Error.
;				MI  Error
;	
;************************************************************************
setmode:
	move.w	6(sp),d0
	asl.w	#6,d0			; Align it
	and.w	#$FF3F,snd_modectl	; Strip old mode
	or.w	d0,snd_modectl		; Set it.		
	clr.l	d0
	rts

;************************************************************************
; settrack
;
;	Set the number of tracks to play and the track the monitor should
;	play.
;
;	Given:		4(sp)	Opcode
;			6(sp)	Number of play tracks (0-3)
;			8(sp)	Number of record tracks (0-3)
;
;	Returns:	d0	0 - No Error.
;				MI  Error
;	
;************************************************************************
settrack:
	move.w	6(sp),d0		; Number of play tracks.
	asl.w	#8,d0			; Align Number of tracks
	and.w	#$FCFF,	snd_modectl	; Strip old number
	or.w	d0,snd_modectl		; Set Play tracks
;
.if FALCON
	move.w	8(sp),d0		; Set number of record tracks.
	asl.w	#8,d0			; Align Number of tracks
	and.w	#$FCFF,dacrec_ctl	; Strip old number
	or.w	d0,dacrec_ctl		; Set it.		
.endif
;
	clr.l	d0
	rts

;************************************************************************
; setmontrack	 Set monitor track.
;
;	Set the monitor track to play.
;
;	Given:		4(sp)	Opcode
;			6(sp)	Monitor track.
;
;	Returns:	d0	0 - No Error.
;				MI  Error
;************************************************************************
setmontrack:
	move.w	6(sp),d0		; Track to monitor
	asl.w	#8,d0			; Align Number of tracks
	asl.w	#4,d0
	and.w	#$CFFF,	snd_modectl	; Strip old number
	or.w	d0,snd_modectl		; Set it.		
	clr.l	d0
	rts


;************************************************************************
; setinterrupt
;
;	Set the type ot interrupt timer A or MFP i7
;
;
;	Given:		4(sp)	Opcode
;			6(sp)	0 - TimerA, 1 - MFP i7
;			8(sp)	type 1 - Play, 2 - Record, 3 - play or Record
;
;	Returns:	d0	0 - No Error.
;				MI  Error
;	
;************************************************************************
setinterrupt:
	move.w	snd_dmsctl,d1
	move.w	8(sp),d0
	asl.w	#8,d0			; Aligned for MFPI7 interrupt
	tst.w	6(sp)
	bne	.mfpi7
	asl.w	#2,d0			; Allign for timerA
	and.w	#$F3FF,d1		; Strip old timerA setting
	bra	.cont
.mfpi7:
	and.w	#$FCFF,d1		; Strip old mfpi7 setting
.cont:
	or.w	d1,d0
	move.w	d0,snd_dmsctl		; Set it
	clr.l	d0
	rts

;************************************************************************
; func_error	The user requested a reserved CD Bios function that
;		is not (Yet) included in this driver. This function
;		terninates the call with an error.
;***********************************************************************
func_error:
	move.l	#-1,d0		; Set d0  to general error condition.
	rts


;***********************************************************************
; dsptristate	Tristates DSP bus
;
;	Given:		4(sp)	Opcode
;			6(sp).w	DSPXMIT	1 enables output, 0 disables
;			8(sp).w	DSPRECV 1 Disables tristate, 0 tristates.
;
;	Returns:	d0	0 - No Error.
;	
;***********************************************************************
dsptristate:
	tst.w	6(sp)
	beq	.cont
	bset	#7,src_pathclk+1	; DSPXMIT enable
	bra	.cont1
.cont:
	bclr	#7,src_pathclk+1	; DSPXMIT tristate
.cont1:
	tst.w	8(sp)
	beq	.cont2
	bset	#7,recv_pathclk+1	; DSPRECV enable
	bra	.cont3
.cont2:
	bclr	#7,recv_pathclk+1	; DSPRECV tristate
.cont3:
	clr.l	d0
	rts

;***********************************************************************
; gpio		Talks to gpio acording to mode.
;
;	Given:		4(sp)	Opcode
;			6(sp).w	mode (0) set, (1) read, (2) write
;			8(sp).w	data
;
;	Returns:	d0	0 - No Error.
;	
;***********************************************************************
gpio:
	clr.l	d0
	tst.w	6(sp)
	beq	.set
	cmp.w	#1,6(sp)
	beq	.read
;
; Must be write.
;
	move.w	8(sp),d0	; Get data
	move.w	d0,gpio_data	; Write it
	clr.l	d0
	rts	
.read:
	move.w	gpio_data,d0	; Read it
	and.w	#$0007,d0
	rts	
.set:
	move.w	8(sp),d0	; Get data
	and.w	#$0007,d0
	move.w	d0,gpio_ctl	; Set direction bits.
	clr.l	d0
	rts


;***********************************************************************
; devconnect	Connects src to dst devices.
;
;
;
;	Given:		4(sp)		Opcode
;			6(sp).w		source	3-ADC,2-extinp,
;						1-dspxmit,0-dmaplay
;			8(sp).w		destination (bit map)
;					bit	3 2 1 0
;						| | | - DMARECV
;						| | --- DSPRECV
;						| ----- EXTOUT
;						------- DAC
;			10(sp).w	source clock
;					0-int 25.175,1-external,2-23MHz	
;			12(sp).w	Clock prescale
;					Valid rates are:
;					Invalid prescale 6,8,10 >=12
;			14(sp).w	protocol
;
;	Returns:	d0	0 - No Error.
;***********************************************************************
devconnect:
	move.w	6(sp),d0
	bmi	.error
	cmp.w	#3,d0
	bgt	.error
	asl.w	#2,d0
	lea	devoperation,a0
	move.l	(a0,d0),a0
	jmp	(a0)

.error:
	clr.l	d0		; Returns complete as per L.T.
	rts	


;	10(sp).w		source clock
micpsg:
	and.w	#$0FFF,src_pathclk
	btst	#0,10+1(sp)
	beq	intclk
	or.w	#$2000,src_pathclk
	bra	extclk

;	10(sp).w		source clock
extinp:
 	move.w	10(sp),d0
	asl.w	#8,d0
	asl.w	#1,d0
	and.w	#$F0FF,src_pathclk
	or.w	d0,src_pathclk
	bset	#0,src_pathclk		; No handshaking
	tst.w	14(sp)
	bne	do_prescale		; IF(1) No handshake mode.
	bclr	#0,src_pathclk		; No handshaking	
	bra	do_prescale
		
;	10(sp).w	source clock
dspxmit:
	move.w	10(sp),d0
	asl.w	#5,d0
	and.w	#$FF8F,src_pathclk
	or.w	d0,src_pathclk
	bset	#4,src_pathclk+1	; No handshaking
	tst.w	14(sp)
	bne	do_prescale		; IF(1) No handshake mode.
	bclr	#4,src_pathclk+1	; No handshaking	
	bra	do_prescale

;	10(sp).w		source clock
dmaplay:
	move.w	10(sp),d0
	asl.w	#1,d0
	and.w	#$FFF0,src_pathclk
	or.w	d0,src_pathclk
;
	bset	#0,src_pathclk+1	; Disable handshaking.
	tst.w	14(sp)
	bne	do_prescale		; IF(1) No handshake mode.
	bclr	#3,src_pathclk+1	; Assume DSPRECV
	btst	#1,8+1(sp)		; If(DSPRECV) Good assume enable
	bne	denable
	bset	#3,src_pathclk+1	; ELSE bad assume
denable:
	bclr	#0,src_pathclk+1	; Enables handshaking.

; Setup Prescaler
do_prescale:
	btst	#0,10+1(sp)
	beq	intclk

; Setup external prescaler
extclk:
	move.w	12(sp),d0
	and.w	#$00FF,prescale
	asl.w	#8,d0
	or.w	d0,prescale	
	bra	dmarec

intclk:
	move.w	12(sp),d0
	and.w	#$FF00,prescale
	or.w	d0,prescale	
;
; <<<<< FALL THROUGH >>>>>>>>>>>
;
	move.w	recv_pathclk,d2	; d2 = recv_pathclk
;
dmarec:
	move.w	8(sp),d1	; d1 = destination bitmap
	btst	#0,d1
	beq	dsprecv
	move.w	6(sp),d0	; d0 = source
	asl.w	#1,d0
	and.w	#$FFF0,d2
	or.w	d0,d2		; or in source.	
;
	bset	#0,d2		; Assume no handshaking
	tst.w	14(sp)		; IF(1) NO Handshaking
	bne	dsprecv
	bclr	#0,d2		; Enables handshaking.
	bclr	#3,d2		; Assume handshaking source DSPXMIT
	cmp.w	#1,6(sp)	; IF(source == DSPXMIT) good assume
	beq	dsprecv		
	bset	#3,d2		; ELSE EXTINP bad assume
;
dsprecv:
	btst	#1,d1
	beq	extout
	move.w	6(sp),d0	; d0 = source
	asl.w	#5,d0
	and.w	#$FF8F,d2	; Retain tristate bit
	or.w	d0,d2		; or in source.	
	bset	#4,d2		; Assume NO handshakeing
	tst.w	14(sp)		; Protocol
	bne	extout
	bclr	#4,d2		; Handshaking BAD assume
extout:
 	btst	#2,d1
	beq	hphones
	move.w	6(sp),d0	; d0 = source
	asl.w	#8,d0
	asl.w	#1,d0
	and.w	#$F0FF,d2
	or.w	d0,d2		; or in source.	
	or.w	#$0100,d2	; assume NO handshaking
	tst.w	14(sp)		; Protocol
	bne	hphones
	and.w	#$FEFF,d2	; BAD Assume handshaking
hphones:
	btst	#3,d1
	beq	skip
	move.w	6(sp),d0	; d0 = source
	asl.w	#8,d0
	asl.w	#5,d0
	and.w	#$0FFF,d2
	or.w	d0,d2		; or in source.	
skip:
	move.w	d2,recv_pathclk
	rts


;************************************************************************
; sndstatus
;
;	Get the current status of the codec. If a mute condition occured
;	then unmute the codec.
;
;	Given:		4(sp)	Opcode
;			6(sp)	Reset if one (1).
;
;	Returns:	d0	Current status of the codec.
;				MI  Error
;************************************************************************
sndstatus:
	tst.w	6(sp)
	beq	.cont
	bsr	mute
	bsr	unmute
.cont:
	move.w	auxa_inp,d0
	asr.w	#4,d0
	and.w	#$003F,d0
 	rts


; ************************************************************************
; mute	Mute the system to reset the codec.
; ************************************************************************
mute:
	move.w	auxb_ctl,oldvol
	and.w	#$F00F,oldvol		; Save old volume setting
	and.w	#$F11F,auxb_ctl		; Clear muted volume
	and.w	#$F22F,auxb_ctl		; Clear muted volume
	and.w	#$F44F,auxb_ctl		; Clear muted volume
	and.w	#$F88F,auxb_ctl		; Clear muted volume
	bset	#2,auxa_ctl		; Mute it
	rts

; ************************************************************************
; unmute	Unmute the system if a mute condition occurs.
; ************************************************************************
unmute:
	and.w	#$F00F,auxb_ctl		; Clear muted volume
	move.w	oldvol,d0
	and.w	d0,auxb_ctl
	and.w	#$F3FF,auxa_ctl		; Unmute
	nop
	nop
	nop
	nop				; Wait some cycles fo4r codec.
	rts

;************************************************************************
; buffoper
;
;	Set the type or buffer operation the user wants.
;
;	Given:		4(sp)	Opcode
;			6(sp)	-1 return current settings or
;
;				    3  2  1  0
;			6(sp)	bitmap 0000 rr re pr pe
;
;	Returns:	d0	0 - No Error.
;
;************************************************************************
buffoper:
	move.w	6(sp),d0
	bmi	.settings
	move.w	snd_dmsctl,d1
	and.w	#$FF00,d1		; d1 = play and record all off
	btst	#1,d0			; Record repeat
	beq	.cont1
	bset	#PF,d1			; Play repeat On
.cont1:
	btst	#3,d0			; Record repeat
	beq	.cont2
	bset	#RF,d1			; Repeat repeat ON
.cont2:
	btst	#0,d0			; Play enable
	beq	.cont3
	bset	#PE,d1			; Play enable ON
.cont3:
	btst	#2,d0			; Record enable
	beq	.cont4
	bset	#RE,d1			; Record enable ON
.cont4:
	move.w	d1,snd_dmsctl		; Set them
	clr.l	d0
	rts

; Return the buffer current settings.
.settings:
	clr.l	d0
	btst	#PF,snd_dmsctl+1	; Play repeat On?
	beq	.cont5
	bset	#1,d0			; Set play repeat.
.cont5:
	btst	#RF,snd_dmsctl+1	; Repeat repeat ON?
	beq	.cont6
	bset	#3,d0			; Set record repeat bit.
.cont6:
	btst	#PE,snd_dmsctl+1	; Play enable ON?
	beq	.cont7
	bset	#0,d0			; Set play enable
.cont7:
	btst	#RE,snd_dmsctl+1	; Record enable ON?
	beq	.cont8
	bset	#2,d0			; Set record enabled bit.
.cont8:
	rts


;************************************************************************
; buffptr
;
;	Returns the current play and record pointers to a user buffer
;	of 4 longs. Structure:
;
;		(long) Play buffer pointer.
;		(long) Record buffer pointer.
;		(long Reserved.
;		(long Reserved.
;
;	Given:		4(sp)	Opcode
;			6(sp)	pointer to 4 longs.
;
;	Returns:	d0	0 - No Error.
;
;************************************************************************
buffptr:
	move.l	6(sp),a0	; a0 -> users buffer.
	movem.l	d1-d3,-(sp)	; Registers used.
	move.l	#0,-(sp)	; Space to place stuff.
;
; Play buffer first.
;
	bclr	#RS,snd_dmsctl+1	; Looking at play registers.
	move.w	CUR_SNDL,d1
	move.w	CUR_SNDM,d2
	move.w	CUR_SNDH,d3
	move.b	d1,3(sp)
	move.b	d2,2(sp)
	move.b	d3,1(sp)
	move.l	(sp),(a0)+
;
; Record buffer next.
;
	bset	#RS,snd_dmsctl+1	; Looking at record registers.
	move.w	CUR_SNDL,d1
	move.w	CUR_SNDM,d2
	move.w	CUR_SNDH,d3
	move.b	d1,3(sp)
	move.b	d2,2(sp)
	move.b	d3,1(sp)
	move.l	(sp),(a0)		; Set user buffer.
;
	add.l	#4,sp
	movem.l	(sp)+,d1-d3		; Registers used.
	clr.l	d0
	rts

	.data
devoperation:
	.dc.l	dmaplay
	.dc.l	dspxmit
	.dc.l	extinp
	.dc.l	micpsg
	.end
