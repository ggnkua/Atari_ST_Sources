	opt	l2
;for rev 5 14/07/92
	XDEF	IsSndDrv			;+
	XDEF	SndLock,SndUnlock,SndCmd,SndSetBuffer,SndSetMode,SndSetTracks
	XDEF	SndSetMonTracks,SndSetInterrupt,SndBufOper,SndDspTriState
	XDEF	SndGpio,SndDevConnect,SndStatus,SndBufPtr

	output	.lib

SND_BASE	equ	$80
LOCKSND	equ	0
UNLOCKSND	equ	1
SOUNDCMD	equ	2
SETBUFFER	equ	3
SETMODE		equ	4
SETTRACKS	equ	5
SETMONTRACKS	equ	6
SETINTERRUPT	equ	7
BUFFOPER	equ	8
DSPTRISTATE	equ	9
GPIO	equ	10
DEVCONNECT	equ	11
SNDSTATUS	equ	12
BUFFPTR	equ	13

CALLDRVR	MACRO
	move.w	\1+SND_BASE,-(sp)
	trap	#14
	ENDM

	TEXT

IsSndDrv:
	bsr	SndLock
	cmp.w	#LOCKSND+SND_BASE,d0
	bne.s	.is
	moveq	#0,d0
	rts
.is:	subq.w	#1,d0
	bne.s	.good
	bsr	SndUnlock
.good:	moveq	#1,d0
	rts

SndLock:
	move.l	a2,-(sp)
	CALLDRVR	#LOCKSND
	addq.w	#2,sp
	move.l	(sp)+,a2
	rts

SndUnlock:
	move.l	a2,-(sp)
	CALLDRVR	#UNLOCKSND
	addq.w	#2,sp
	move.l	(sp)+,a2
	rts

;short	mode
;short	data
SndCmd:
	move.l	a2,-(sp)
	move.w	d1,-(sp)
	move.w	d0,-(sp)
	CALLDRVR	#SOUNDCMD
	addq.w	#6,sp
	move.l	(sp)+,a2
	rts

;short	reg
;void	*begaddr
;void	*endaddr
SndSetBuffer:
	move.l	a2,-(sp)
	move.l	a1,-(sp)
	move.l	a0,-(sp)
	move.w	d0,-(sp)
	CALLDRVR	#SETBUFFER
	lea	12(sp),sp
	move.l	(sp)+,a2
	rts

;short	mode
SndSetMode:
	move.l	a2,-(sp)
	move.w	d0,-(sp)
	CALLDRVR	#SETMODE
	addq.w	#4,sp
	move.l	(sp)+,a2
	rts

;short	playtracks
;short	rectracks
SndSetTracks:
	move.l	a2,-(sp)
	move.w	d1,-(sp)
	move.w	d0,-(sp)
	CALLDRVR	#SETTRACKS
	addq.w	#6,sp
	move.l	(sp)+,a2
	rts

;short	montrack
SndSetMonTracks:
	move.l	a2,-(sp)
	move.w	d0,-(sp)
	CALLDRVR	#SETMONTRACKS
	addq.w	#4,sp
	move.l	(sp)+,a2
	rts

;short	src_inter
;short	cause
SndSetInterrupt:
	move.l	a2,-(sp)
	move.w	d1,-(sp)
	move.w	d0,-(sp)
	CALLDRVR	#SETINTERRUPT
	addq.w	#6,sp
	move.l	(sp)+,a2
	rts

;short	mode
SndBufOper:
	move.l	a2,-(sp)
	move.w	d0,-(sp)
	CALLDRVR	#BUFFOPER
	addq.w	#4,sp
	move.l	(sp)+,a2
	rts

;short	dspxmit
;short	dsprec
SndDspTriState:
	move.l	a2,-(sp)
	move.w	d1,-(sp)
	move.w	d0,-(sp)
	CALLDRVR	#DSPTRISTATE
	addq.w	#6,sp
	move.l	(sp)+,a2
	rts

;short	mode
;short	data
SndGpio:
	move.l	a2,-(sp)
	move.w	d1,-(sp)
	move.w	d0,-(sp)
	CALLDRVR	#GPIO
	addq.w	#6,sp
	move.l	(sp)+,a2
	rts

;short	src
;short	dst
;short	srcclk
;short	prescale
;short	protocol
SndDevConnect:
	move.l	a2,-(sp)
	move.w	10(sp),-(sp)
	move.w	10(sp),-(sp)
	move.w	d2,-(sp)
	move.w	d1,-(sp)
	move.w	d0,-(sp)
	CALLDRVR	#DEVCONNECT
	lea	12(sp),sp
	move.l	(sp)+,a2
	rts

;short	reset
SndStatus:
	move.l	a2,-(sp)
	move.w	d0,-(sp)
	CALLDRVR	#SNDSTATUS
	addq.w	#4,sp
	move.l	(sp)+,a2
	rts

;void	**ptr
SndBufPtr:
	move.l	a2,-(sp)
	move.l	a0,-(sp)
	CALLDRVR	#BUFFPTR
	addq.w	#6,sp
	move.l	(sp)+,a2
	rts


