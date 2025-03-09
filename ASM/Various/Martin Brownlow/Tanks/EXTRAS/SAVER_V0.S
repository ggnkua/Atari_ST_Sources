*	Screen Saver V1.0
*	By
*	Martin Brownlow

*	Simply changes all colours to black.

time_to_activate	equ	6000

start	pea	string
	move.w	#9,-(Sp)
	trap	#1
	addq.l	#6,sp
	
	pea	install
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	
	move.w	#0,-(sp)
	move.l	#(end-start)+256,-(sp)
	move.w	#$31,-(sp)
	trap	#1

install	move.w	#34,-(sp)
	trap	#14
	addq.l	#2,sp

	move.l	d0,a0
	move.l	32(a0),oldkey
	move.l	#key,32(a0)

	move.l	$456,a0
	move.l	28(a0),a1
	cmp.l	#0,a1
	bne	a1not0
	lea	newvbl,a1
a1not0	move.l	a1,oldvbl
	move.l	#vbl,28(a0)
	rts
newvbl	rts
key	move.w	#1,moved
	move.l	oldkey,-(sp)
	rts
	
vbl	cmp.w	#time_to_activate,time
	beq	activ8
	bgt	doit
	cmp.w	#0,moved
	bne	clrtime
	add.w	#1,time
	move.l	oldvbl,-(sp)
	rts
clrtime	move.w	#0,moved
	move.w	#0,time	
	cmp.w	#0,$4ee
	bne	outvbl2
	movem.l	d0-a6,-(sp)
	move.w	#-1,$4ee
	move.l	$456,a0
	move.l	oldvbl,28(a0)
	move.w	#34,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,a0
	move.l	oldkey,32(a0)
	movem.l	(sp)+,d0-a6
outvbl2	move.l	oldvbl,-(sp)
	rts
activ8	movem.l	d0-d7,-(sp)
	movem.l	$ff8240,d0-d7
	movem.l	d0-d7,oldpal
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	movem.l	d0-d7,$ff8240
	movem.l	(sp)+,d0-d7
	add.w	#1,time
outvbl	move.l	oldvbl,-(sp)
	rts
doit	cmp.w	#0,moved
	beq	outvbl
	movem.l	d0-d7,-(sp)
	movem.l	oldpal,d0-d7
	movem.l	d0-d7,$ff8240
	movem.l	(sp)+,d0-d7
	bra	clrtime

string	dc.b	$0d,$0a,27,"BScreen Saver V1.0 Installed",$0d,$0a
	dc.b	"Use Alt+Help to disable.",$0d,$0a,0
			
	section bss
	
oldkey	ds.l	1
oldvbl	ds.l	1
moved	ds.w	1
time	ds.w	1
oldpal	ds.l	8

end