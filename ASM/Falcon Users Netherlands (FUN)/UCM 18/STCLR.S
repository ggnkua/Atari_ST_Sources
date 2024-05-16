* Screenclearer demonstration.
* A small piece of code by earx/fun.
* Please run in ST-LOW.

* Change to supervisor-mode.
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

* Save old screenaddress.
	move	#2,-(sp)
	trap	#14
	addq	#2,sp
	move.l	d0,old_screenaddress

main_loop:
	move.l	old_screenaddress,a0		* Get screenaddress in a0
	add.l	#160*200,a0			* Get end of screen.
	moveq	#0,d0				* Clear all regs..
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	movea.l	d0,a1
	movea.l	d0,a2
	movea.l	d0,a3
	movea.l	d0,a4
	movea.l	d0,a5
	movea.l	d0,a6
	move.w	#153-1,d7

clearloop:
	movem.l	d0-d6/a1-a6,-(a0)               * Move 13 longs to mem.
	movem.l	d0-d6/a1-a6,-(a0)               * etc.
	movem.l	d0-d6/a1-a6,-(a0)               * etc.
	movem.l	d0-d6/a1-a6,-(a0)
	dbra	d7,clearloop

* Clear the tail.
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d5,-(a0)

	cmpi.b	#$39,$fffffc02.w		* Spacebar pressed?
	bne.s	main_loop			* If not, keep looping.

* Terminate program.
	clr.w	-(sp)
	trap	#1

	BSS

old_screenaddress:
	DS.L	1