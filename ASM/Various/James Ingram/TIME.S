* timer tester
* by James Ingram, Feb 1994

	opt	x+,o-,ow-

* just don't use reg d7 in your macros...

count	equ	2000
time	equ	50


first_init	macro
* initialise first macro

	move.l	#spare,a0

	endm


first	macro
	move.b	d0,(a0)
	move.b	d0,2(a0)
	move.b	d0,4(a0)
	move.b	d0,6(a0)
	endm


second_init	macro
* initialise second macro
	move.l	#spare,a0

	endm

second	macro
	movep.l	d0,(a0)
	endm



	move.w	#3,-(a7)
	trap	#14
	addq.l	#2,a7
	move.l	d0,a0
	
	move.w	#32000/4-1,d0
clr:
	clr.l	(a0)+
	dbra	d0,clr


	moveq	#-1,d0
	bsr	set_col0
	move.w	d0,-(a7)


first_loop:
	lea	first(pc),a0
	bsr	print_mes


loop1:
	bsr	sync
	move.w	#$700,d0
	bsr	set_col0

	move.w	#count,d7

	first_init
.loop:
	first
	dbra	d7,.loop

	move.w	#$777,d0
	bsr	set_col0
	
	bsr	testkey
	tst.w	d0
	beq	loop1
	cmp.w	#13,d0
	beq	stop



	lea	sec(pc),a0
	bsr	print_mes

loop2:
	bsr	sync
	move.w	#$077,d0
	bsr	set_col0


	second_init

	move.w	#count,d7
.loop:
	second
	dbra	d7,.loop

	move.w	#$777,d0
	bsr	set_col0

	bsr	testkey
	tst.w	d0
	beq	loop2
	cmp.w	#13,d0
	bne	first_loop

	
stop:
	move.w	(a7)+,d0
	bsr	set_col0

	clr.w	-(a7)
	trap	#1

	
print_mes:
	pea	(a0)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	rts


first:
	dc.b	27,"EFirst Macro...",0
sec:
	dc.b	27,"ESecond Macro...",0
	even

set_col0:
	move.w	d0,-(a7)
	move.w	#0,-(a7)
	move.w	#7,-(a7)
	trap	#14
	addq.l	#6,a7
	rts


sync:
	move.w	#37,-(a7)
	trap	#14
	addq.l	#2,a7
	rts

testkey:
	move.w	#$ff,-(a7)
	move.w	#6,-(a7)
	trap	#1
	addq.l	#4,a7
	rts


	section	bss

spare	ds.b	100000