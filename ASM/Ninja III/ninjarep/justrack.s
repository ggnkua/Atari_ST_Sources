**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**

**	Ninja III Protracker Replay With Bottom Border - Nova '93

**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**

Start_	move.l	sp,Oldusp

	pea	stack
	move	#$20,-(sp)
	trap	#1
	move.l	d0,Oldssp

	bsr	flush
	move	#8,d0
	bsr	setkeybord
	move	#$12,d0
	bsr	setkeybord

	bsr	sysave
	bsr	syset

	move.l	#8000,d0
	moveq	#0,d1
	moveq	#0,d2
	lea	mod,a0
	jsr	play
	move.l	#vbi3,$70.w
	jsr	play+4

	bsr	init

	jsr	play+8

	bsr	sysrestore

	bsr	flush
	move	#8,d0
	bsr	setkeybord

	move.l	Oldssp,-(sp)
	move	#$20,-(sp)
	trap	#1
	move.l	Oldusp,sp

	clr	-(sp)
	trap	#1

**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
init
	move.l	phy,a0
	lea	199*160(a0),a0
	move.l	#$87654321,d0
	move.l	#(40*5)-1,d1
.loop	move.l	d0,(a0)+
	dbf	d1,.loop

	move.l	#vbi2,$70.w

	bsr	loop
	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
loop	bsr	waitvbi
	cmpi.b	#$39,$FFFFFC02.w
	bne	loop
	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
**	subroutines
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
flush	lea	$FFFFFC00.w,a0
.flush	move.b	2(a0),d0
	btst	#0,(a0)
	bne.s	.flush
	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
setkeybord
.wait	btst	#1,$fffffc00.w
	beq	.wait
	move.b	d0,$FFFFFC02.w
	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
waitvbi
	move	#-1,vflag
.wvbi	tst	vflag
	bmi.s	.wvbi
	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
vbi1	clr	vflag
	rte

vbi3	movem.l	d0-6/a0-a4,-(sp)
	jsr	play+12			call madmax
	movem.l	(sp)+,d0-6/a0-a4

	clr	vflag
	rte
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
kbi	tst.b	$FFFFFC02.w
	tst.b	$FFFFFC06.w
	bclr	#6,$FFFFFA11.w
	rte
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
vbi2	movem.l	d0-6/a0-a4,-(sp)

	clr	vflag

	lea	pal,a0
	move	#$8240,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	move.b	#0,$FFFFFA1b.w
	move.l	#hbi1,$120.w
	move.b	#198,$FFFFFA21.w
	move.b	#8,$FFFFFA1b.w

	jsr	play+12			call madmax

	movem.l	(sp)+,d0-6/a0-a4
	rte
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
hbi1	and.b	#$EF,$FFFFFA15.w

	move.b	#0,$FFFFFA1b.w
	move.l	#hbi,$120.w
	move.b	#1,$FFFFFA21.w
	move.b	#8,$FFFFFA1b.w

	bclr	#0,$FFFFFA0F.w
	rte

hbi	move	#$2700,sr
	move.b	#0,$FFFFFA1b.w

	movem.l	d0/a0,-(sp)

	move	#$8209,a0
	moveq.l	#0,d0

	move.b	(a0),d0
.sync	cmp.b	(a0),d0
	beq.s	.sync
	move.b	(a0),d0
	neg.b	d0
	rol.b	d0,d0

	moveq.l	#25,d0
.del	dbf	d0,.del

	move.b	#0,$FFFF820A.w
	nop
	nop
	nop
	nop
	move.b	#2,$FFFF820A.w

	movem.l	(sp)+,d0/a0

	bclr	#0,$FFFFFA0F.w
	or.b	#$10,$FFFFFA15.w
	rte
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
sysave
	move.l	$70.w,Oldvbi
	move.l	$118.w,Oldkbi
	move.l	$120.w,Oldhbi

	move	#$8240,a0
	lea	Oldpal,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move	(a0)+,Oldrez
	move.l	$FFFF8200.w,Oldscr

	move	#$FA00,a0
	movep	7(a0),d0
	movep	$13(a0),d1
	movem	d0/d1,Mfp1

	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
syset	move	#$2300,-(sp)

	move	#37,-(sp)
	trap	#14
	addq.l	#2,sp

	move	#$2700,sr

	move	#$8209,a0
	moveq.l	#0,d0

	move.b	(a0),d0
.sync	cmp.b	(a0),d0
	beq.s	.sync
	move.b	(a0),d0
	neg.b	d0
	rol.b	d0,d0

	move.l	#vbi1,$70.w
	move.l	#hbi,$120.w
	move.l	#kbi,$118.w

	lea	pal,a0
	move	#$8240,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	nop
	move.b	#0,(a1)

	move.l	#screen1,d0
	add.l	#256,d0
	clr.b	d0
	move.l	d0,log

	move.l	#screen2,d0
	add.l	#256,d0
	clr.b	d0
	move.l	d0,phy
	lsr	#8,d0
	move.l	d0,$FFFF8200.w

	move.b	#0,$FFFFFA1b.w

	move	#$FA00,a0
	move	#$140,d0
	movep	d0,7(a0)
	movep	d0,$13(a0)

	rte
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
sysrestore
	move	#$2300,-(sp)

	bsr	waitvbi

	move	#$2700,sr

	move	#$8209,a0
	moveq.l	#0,d0

	move.b	(a0),d0
.sync	cmp.b	(a0),d0
	beq.s	.sync
	move.b	(a0),d0
	neg.b	d0
	rol.b	d0,d0

	move.l	Oldvbi,$70.w
	move.l	Oldhbi,$120.w
	move.l	Oldkbi,$118.w

	lea	Oldpal,a0
	move	#$8240,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move	Oldrez,(a1)

	move.l	Oldscr,$FFFF8200.w

	move.b	#0,$FFFFFA1b.w

	move	#$FA00,a0
	movem	Mfp1,d0/d1
	movep	d0,7(a0)
	movep	d1,$13(a0)

	rte
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
	SECTION DATA
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
null	dc.l	0

pal	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$FFFF

	even
play	incbin	*.bin
	even
mod	incbin	*.mod

**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
	SECTION BSS
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
	ds.b	60000		don't move this

**	Storage Space For Hardware Status

Oldusp	ds.l	1
Oldssp	ds.l	1
Oldvbi	ds.l	1
Oldhbi	ds.l	1
Oldkbi	ds.l	1

Oldscr	ds.l	1
Oldrez	ds.l	1
Oldpal	ds.w	16

Mfp1	ds.w	1
Mfp2	ds.w	1

**	Bits used by menu

vflag	ds.w	1
log	ds.l	1
phy	ds.l	1
	ds.l	256
stack	ds.l	1
screen1	ds.b	(160*240)+256
screen2	ds.b	(160*240)+256


