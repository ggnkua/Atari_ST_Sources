* Music player using virtually no processor time!
* By James Ingram, April 1994


	opt	x+,o-,ow-


	include	\includes\macros.s


	bsr	de_mus

	super_on
	
	move.l	$70.w,-(a7)
	move.l	#my_70,$70.w	; install music player
	
	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7
	
	move.l	(a7)+,$70.w
	
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
	include	\includes\load.s



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

	section	bss
music_data	ds.b	45078
	even


