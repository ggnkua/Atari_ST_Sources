* Demonstartion of how to fade music out
* when leaving a program

	opt	o-,ow-

fade_pause	equ	10


	include	\includes\macros.s

	bsr	de_mus

	super_on

	move.l	$70.w,-(a7)
	move.l	#my_70,$70.w	; install music player
	
	bsr	inp		; wait for keypress

	st	fade		; begin fade process
wait_fade:
	tst.w	fade_done
	beq.s	wait_fade	; wait for fade to be complete

	move.l	(a7)+,$70.w	; then disable sound routine

	super_off
	clr.w	-(a7)
	trap	#1


my_70:
	movem.l	d0-7/a0-6,-(a7)


* SYNCRONISE SCREEN!
	move.w	#$8209,a0	; get screen counter address
	moveq	#0,d0
	moveq	#16,d1		; prepare registers

.wait:
	move.b	(a0),d0
	beq.s	.wait		; wait for counter to start

	sub.w	d0,d1		; get number of rotations to do

	lsl.w	d1,d0		; now syncronise!

	move.w	$ffff8240.w,-(a7)
	move.w	#$f00,$ffff8240.w

* play music...
	move.l	mus_addr,a6	; get address of data
	move.l	#nos,a5		; and numbers for chip

	move.b	(a6)+,2(a5)	; put data into correct positions
	move.b	(a6)+,6(a5)
	move.b	(a6)+,$a(a5)
	move.b	(a6)+,$e(a5)
	move.b	(a6)+,$12(a5)
	move.b	(a6)+,$16(a5)
	move.b	(a6)+,$1a(a5)
	move.b	(a6)+,$1e(a5)
	move.b	(a6)+,$22(a5)
	move.b	(a6)+,$26(a5)
	move.b	(a6)+,$2a(a5)

* am I fading???
	tst.b	fade
	beq.s	no_fade

* get fade number
	move.w	fade_val,d0

* am I adding 1 this time?
	subq.w	#1,fade_count
	bne.s	.no_add

* restart counter
	move.w	#fade_pause,fade_count

* add 1 for next time
	addq.w	#1,d0

* am I on the last one?
	cmp.b	#$f,d0
	seq	fade_done	; if so, set the finished flag

	move.w	d0,fade_val	; keep value for next time.

.no_add:
* subtract this number from the volumes - put them back at 0 if they go negative
	move.l	#vol1,a0
	move.b	(a0),d1
	sub.b	d0,d1
	bpl.s	.not_zed

	moveq	#0,d1
.not_zed:
	move.b	d1,(a0)

	move.b	4(a0),d1
	sub.b	d0,d1
	bpl.s	.not_zed2

	moveq	#0,d1
.not_zed2:
	move.b	d1,4(a0)

	move.b	8(a0),d1
	sub.b	d0,d1
	bpl.s	.not_zed3

	moveq	#0,d1
.not_zed3:
	move.b	d1,8(a0)

no_fade:
	movem.l	(a5),a0-2/d0-7	; slap all data into sound chip
	movem.l	a0-2/d0-7,$ffff8800.w

	subq.w	#1,mus_count
	bne.s	.not_loop

* loop back to start of sound!
	move.l	#music_data,a6
	move.w	#$1002,mus_count

.not_loop:
	move.l	a6,mus_addr	; keep address of music!

	move.w	(a7)+,$ffff8240.w


	movem.l	(a7)+,d0-7/a0-6

	rte


	include	\includes\de_mus.s
	include	\includes\misc.s


nos:	DC.B	0,0,$3E,0
	dc.b	1,1,1,0
	DC.B	2,2,$EE,0
	dc.b	3,3,0,0
	DC.B	4,4,$59,0
	dc.b	5,5,2,0
	DC.B	6,6,7,0
	dc.b	7,7,$F8,$FF
vols:
	DC.B	8,8
vol1	dc.b	$E,0
	DC.B	9,9
vol2	dc.b	$E,0
	DC.B	$A,$A
vol3	dc.b	$F,0


mus_addr	dc.l	music_data
mus_count	dc.w	$1002

fade_count	dc.w	fade_pause

	section	bss
music_data	ds.b	45078
	even

fade	ds.w	1
fade_done	ds.w	1
fade_val	ds.w	1


