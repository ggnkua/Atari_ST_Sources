;-----------------------------------------------------------------------------
; Mini program to determine how many clock-cycles a routine takes!
; Coded by Tony B! (With some original non-working code by a German guy!).
; Setup variable 'regs' beforehand if needed!?
; Output in Hex, decimal and nop's.
;-----------------------------------------------------------------------------

	jmp	x

regs	dc.l	-1,1,0,0,0,0,0,0		;data regs
	dc.l	buff,$f0000,0,0,0,0,0	;address regs

testrout
*------------- slap your rout in here ....


	rts



*------------------- convert time to hex/dec/nops
x
	pea	.init(pc)
	move	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	lea	.inhex+1(pc),a1
	lea	.indec+9(pc),a3
	lea	.hexbits(pc),a2
	lea	.nops+9(pc),a4
	move.l	.clk(pc),d3
	move.l	d3,d2
	move.l	d3,d4
	lsr.l	#2,d4
	moveq	#8-1,d0
.output
	divu	#10,d4
	swap	d4
	add.b	d4,-(a4)
	clr	d4
	swap	d4
	rol.l	#4,d2
	move	d2,d1
	and	#$f,d1
	move.b	(a2,d1.w),(a1)+
	divu	#10,d3
	swap	d3
	add.b	d3,-(a3)
	clr	d3
	swap	d3

	dbf	d0,.output

*------------------- output data
	pea	.string(pc)
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	
	tst.l	.clk
	bne.s	.crap
	
	pea	.fnar(pc)
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
.crap
	move	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	clr	-(sp)
	trap	#1


*------------------- data
.string	dc.b	27,"E Your routine takes ...",10,10,13
.indec	dc.b	" 00000000 clock cycles in Decimal!",10,13
.inhex	dc.b	" 00000000 clock cycles in Hexadecimal!",10,10,13
	dc.b	" Phew! That's"
.nops	dc.b	" 00000000 nop instructions you know!!",10,10,13
	dc.b	" I think you need to speed it up.",0
	even
.fnar	dc.b	27,"lI couldn't have done it better myself.",0
	even
.hexbits	dc.b	"0123456789ABCDEF"
.clk	ds.l	1

*------------------- let the timing begin ....
.init
	move.b	#$12,$fffffc02.w

	move	$468.w,d0
.sync	cmp	$468.w,d0
	beq.s	.sync
	
	move	#$2700,sr

	lea	$ffff8209.w,a0
	lea	$ffff8207.w,a1

	bclr	#0,$fffffa07.w
	clr.b	$fffffa1b.w
	move.b	#201,$fffffa21.w

	move.b	$ffff8203.w,d0
.wait1	tst.b	(a0)
	bne.s	.wait1
	cmp.b	(a1),d0
	bne.s	.wait1
.wait2	move.b	(a0),d0
	tst.b	d0
	beq.s	.wait2
	
	move.b	#8,$fffffa1b.w

	moveq	#20,d1
	sub.b	d0,d1
	lsl.l	d1,d1

	movem.l	regs,d0-d7/a0-a6
	jsr	testrout
	move	#$337,$ffff8240.w

	lea	$ffff8209.w,a0
	lea	$ffff8207.w,a1
	lea	$ffff8203.w,a2

	moveq	#0,d0
	moveq	#0,d2
	moveq	#0,d5
.loop
	move.b	(a0),d1
	move.b	(a1),d0
	dcb.w	45,$4e71
	move.b	(a0),d3
	move.b	(a1),d2

	moveq	#0,d4
.mloop
	cmp.b	#$fa,d1
	bls.s	.skip
	subq.b	#1,d0
.skip
	sub.b	(a2),d0
	lsl	#8,d0
	move.b	d1,d0
	ext.l	d0
	divu	#160,d0
	tst	d0
	beq.s	.go
	nop
	nop
.go
	swap	d0
	tst	d0
	bne.s	.skip2
	tst	d4
	bne.s	.here
	move.b	d2,d0
	move.b	d3,d1
	move	#196,d4
	bra.s	.mloop
.here
	move.l	#4755,d5
.null	dbf	d5,.null
	moveq	#0,d5
	nop
	nop
	bra	.loop
.skip2
	move.b	(a2),d2
.wait3	tst.b	(a0)
	bne.s	.wait3
	cmp.b	(a1),d2
	bne.s	.wait3
.wait4	move.b	(a0),d2
	tst.b	d2
	beq.s	.wait4

	move.b	$fffffa21.w,d2
	subq	#1,d2
	clr.b	d2
	mulu	#626,d2
	lsl.l	#8,d2

	move	d0,d1
	add	d0,d1
	swap	d0
	mulu	#512,d0
	ext.l	d1
	add.l	d4,d5
	add.l	#324,d5
	sub.l	d5,d0
	add.l	d1,d2
	add.l	d2,d0
	move.l	d0,.clk

	clr.b	$fffffa1b.w
	
	move	#-1,$ffff8240.w
	move.b	#8,$fffffc02.w
	
	move	#$2300,sr
	rts

buff
