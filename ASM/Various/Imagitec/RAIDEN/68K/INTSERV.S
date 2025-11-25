	.include	'jaguar.inc'

LEVEL2		equ	$100

VIDINT		equ	1
GPUINT		equ	2
STOPINT		equ	4
TIMERINT	equ	8
DSPINT		equ	16
MOUSEINT	equ	32

TIMERINTBIT	equ	3

	.globl	IntInit
	.globl	EnableTimer		;xdef this
	.globl	DisableTimer		;and this
	.extern	Lister
	.extern nt_vbl

;	INTMASK	equ	VIDINT|TIMERINT
	INTMASK	equ	VIDINT

	saveregs reg d0-d1

DisableTimer:
	bclr	#TIMERINTBIT,intmask
	rts

EnableTimer:
	bset	#TIMERINTBIT,intmask
	rts

IntInit:
	move.l	#Handler,LEVEL2
	move.w	#451,VI

	move.w	pit0,PIT0		;set timer for mod player
	move.w	pit1,PIT1

	clr.w	d0
	move.b	intmask,d0
	move.w	d0,INT1

	move.w	sr,d0
	and.w	#$f8ff,d0
	move.w	d0,sr

	rts



Handler:
	movem.l	#saveregs,-(sp)

	move.w	INT1,d0
	btst	#3,d0
	beq.s	CheckVideo

	;handle timer interrupt for music
	move.l	#$0,BORD1
	bsr	nt_vbl
	move.l	#$ffffffff,BORD1

CheckVideo:
	btst	#0,d0
	beq.s	exit

	bsr	Lister


exit:
	lsl.w	#8,d0
	move.b	intmask,d0
	move.w	d0,INT1
	move.w	d0,INT2

	movem.l	(sp)+,#saveregs
	rte









.data

pit0: dc.w 999
pit1: dc.w 531
intmask:dc.b INTMASK

.phrase
