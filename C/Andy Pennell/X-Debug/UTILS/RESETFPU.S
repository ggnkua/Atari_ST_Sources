
* a TSR to ensure coproc reset on reset

	opt	p=68881
	comment	HEAD=%111		Fast,Load,Malloc
	output	.prg

	include	c:\help.s
	
start
	move.l	4(sp),a3
* print a message via GEMDOS - this should be before the vector patching
* in case Ctrl-C is pressed during the printing
	pea	hellotx(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
*-------	any initialisation for the TSR goes here

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp			into super

	move.l	#'_FPU',d1
	bsr	find_cookie
	bne.s	.bad
	swap	d0
	subq.w	#2,d0
	bcc.s	.good

.bad	pea	badtx(pc)
	move.w	#9,-(sp)
	trap	#1
	clr.w	(sp)
	trap	#1

.good	move.l	resvalid.w,old_resvalid
	move.l	resvector.w,old_resvector
	move.l	#myreset,resvector.w
	move.l	#$31415926,resvalid.w

*-------	end initialisation

	clr.w	-(sp)
	move.l	$c(a3),d0
	add.l	$14(a3),d0
	add.l	$1c(a3),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.w	#$31,-(sp)	p_termres
	trap	#1		that's the end

hellotx	dc.b	'RESETFPU installed ',189,' Andy Pennell 1992',13,10,0
badtx	dc.b	'** no FPU found **',13,10,0

myreset	frestore	.zero(pc)
	move.l	old_resvector,resvector.w
	move.l	old_resvalid,resvalid.w
	jmp	(a6)

.zero	dc.l	0

* given d1.l, find the cookie for it
* if found, returns EQ, d0=the value
* else NE
* needs supervisor mode, uses d0/a0
find_cookie
	move.l	$5a0.w,d0
	beq.s	.notfound		if none
	move.l	d0,a0
.cloop	move.l	(a0)+,d0
	beq.s	.notfound
	cmp.l	d0,d1
	beq.s	.gotm2
	addq.w	#4,a0
	bra.s	.cloop
.gotm2	move.l	(a0),d0
	cmp.b	d0,d0
	rts
.notfound
	moveq	#-1,d0
	rts

old_resvalid	ds.l	1
old_resvector	ds.l	1
