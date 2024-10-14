* VU bars demo
* by James Ingram, April 1993


	opt	x+,o-,ow-

fade_pause	equ	10


	include	\includes\macros.s

	bsr	de_mus

* clear the screens
	move.l	#scrns,a0
	move.w	#64256/4-1,d0
clr:
	clr.l	(a0)+
	dbra	d0,clr

* get screen addresses
	move.l	#scrns,d0
	add.l	#255,d0
	clr.b	d0

	move.l	d0,screen1
	add.l	#32000,d0
	move.l	d0,screen2

	super_on
	bsr	initialise

	movem.l	bars_pal,d0-7
	movem.l	d0-7,$ffff8240.w

	bsr	main

	bsr	restore
	super_off
	clr.w	-(a7)
	trap	#1


main:
	move.l	$70.w,-(a7)
	move.l	#my_70,$70.w
	
	bsr	inp

	st	fade		; begin fade process
wait_fade:
	tst.w	fade_done
	beq.s	wait_fade	; wait for fade to be complete

	
	move.l	(a7)+,$70.w
	rts


my_70:
	movem.l	d0-7/a0-6,-(a7)

	move.l	screen1,d0	; get screen to work on

	move.l	screen2,d1	; swap screens for next time
	move.l	d0,screen2
	move.l	d1,screen1

	move.l	d0,cur_screen

	clr.b	$ffff820d.w	; this clears the STe extra byte
				; which otherwise could cause the
				; screen to look very odd on STes
	
	lsr.l	#8,d0
	move.b	d0,$ffff8203.w
	lsr.w	#8,d0
	move.b	d0,$ffff8201.w	; slap the screen address in!
				; only those bytes are needed...
	

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

* DO THE VU BARS!
* get the screen address I am working on
	move.l	cur_screen,a0

* go to bottom area
	add.l	#160*184,a0

* put in VU bars up to full!
	move.l	#bars,a1

coun	set	0
	rept	15
	movem.l	(a1)+,d0-1	; get line of VU bar
	movem.l	d0-1,coun(a0)
	movem.l	d0-1,coun+8(a0)
	movem.l	d0-1,coun+16(a0)
coun	set	coun+160
	endr


* now take away those lines which are not needed.

	moveq	#0,d6
	moveq	#0,d7

	moveq	#0,d0
	move.b	vol1,d0
	bsr	wipe_lines

	moveq	#0,d0
	move.b	vol2,d0
	addq.l	#8,a0
	bsr	wipe_lines

	moveq	#0,d0
	move.b	vol3,d0
	addq.l	#8,a0
	bsr	wipe_lines


	move.w	(a7)+,$ffff8240.w
	movem.l	(a7)+,d0-7/a0-6

	rte

wipe_lines:
* screen addr of top line in a0
* volume in d0
* d6 and d7 are value to clear with

	not.b	d0		; invert volume
	and.b	#$f,d0		; keep only lower nybble

* now volume 15 means take away 0 bars, and volume 0 takes away 16!

	move.l	#end_take,a1
	mulu	#6,d0		; skip past unwanted clearing instructions
	sub.l	d0,a1
	jmp	(a1)		; jump into wipe routine at correct place

coun	set	160*15
	rept	16
	movem.l	d6-7,coun(a0)
coun	set	coun-160
	endr

end_take:
	rts

bars:
* data for each line of bar colour

o	equ	$ffff
F	equ	0

	dc.w	o,o,o,o
	dc.w	F,o,o,o
	dc.w	o,F,o,o
	dc.w	F,F,o,o
	dc.w	o,o,F,o
	dc.w	F,o,F,o
	dc.w	o,F,F,o
	dc.w	F,F,F,o
	dc.w	o,o,o,F
	dc.w	F,o,o,F
	dc.w	o,F,o,F
	dc.w	F,F,o,F
	dc.w	o,o,F,F
	dc.w	F,o,F,F
	dc.w	o,F,F,F
	dc.w	o,F,F,F

bars_pal:
	dc.w	$000,$030,$0b0,$040,$0c0,$050,$0d0,$060
	dc.w	$0e0,$070,$0f0,$400,$500,$600,$700,$f00

	include	\includes\de_mus.s
	include	\includes\misc.s
	include	\includes\init.s

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
scrns:
	ds.b	256
	ds.b	32000
	ds.b	32000

screen1	ds.l	1
screen2	ds.l	1
cur_screen	ds.l	1

music_data	ds.b	45078
	even

fade	ds.w	1
fade_done	ds.w	1
fade_val	ds.w	1

