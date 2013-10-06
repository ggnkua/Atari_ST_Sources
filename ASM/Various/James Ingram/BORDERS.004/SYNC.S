* Show how to syncronise the processor
* by James Ingram, April 1994

	opt	o-,ow-


* comment out next line to see un-syncronised processor!
sync_on	equ	1

	include	\includes\macros.s

	super_on

	c_off		; timer C off

	bsr	initialise

	move.l	$70.w,-(a7)
	move.l	#my_70,$70.w
	bsr	inp
	move.l	(a7)+,$70.w

	
	bsr	restore

	c_on		; timer C on

	super_off
	clr.w	-(a7)
	trap	#1


my_70:
* interrupts off
	move.w	sr,-(a7)
	or.w	#$0700,sr

	movem.l	d0-7/a0-6,-(a7)

	move.w	#$8209,a0	; get screen counter address
	moveq	#0,d0
	moveq	#16,d1		; prepare registers

	move.w	$ffff8240.w,d7
	move.w	#$f00,$ffff8240.w	; red band on
.wait:
	move.b	(a0),d0
	beq.s	.wait		; wait for counter to start

	sub.w	d0,d1		; get number of rotations to do

	ifd	sync_on
	lsl.w	d1,d0		; now syncronise!
	endc

	move.w	d7,$ffff8240.w	; restore background colour

	movem.l	(a7)+,d0-7/a0-6

	move.w	(a7)+,sr
	rte

my_pal	incbin	\includes\spr_pal.dat

	include	\includes\misc.s
	include	\includes\init.s

	section	bss

scrn:
	ds.b	256		; byte boundary
s:
	ds.b	32*160		; top border area
	ds.b	32000		; main screen
	ds.b	32000
screen_len	equ	*-s


screen	ds.l	1
