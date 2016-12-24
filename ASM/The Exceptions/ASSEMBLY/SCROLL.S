Charset equ  $70000
hoehe 	equ 32

Create:
	moveq	#5,d0
	lea	tabelle,a0
	move.l	#charset,d2
Spalte:	
	move.w	#9,d1
Zeile:
	move.l	d2,(a0)+
	add.l	#$10,d2
	dbf	d1,zeile
	add.l	#hoehe*160-160,d2
	dbf	d0,spalte
	move.w	#hoehe,zanz	
	move.l	#irq,$4d2

Scrollbase	equ $f8000
Block0	equ	$30000
block1 	equ	$32000
Block2	equ	$34000
block3	equ	$36000
block4	equ	$38000
block5	equ	$3a000
block6	equ	$3b000
block7	equ	$3c000

puff0	equ	$40000
puff1	equ	$40100
puff2	equ	$40200
puff3	equ	$40300
puff4	equ	$40400
puff5	equ	$40500
puff6	equ	$40600
puff7	equ	$40700

irq:
	move.w	nr,d2
	addq.w	#1,nr
	and.w	#$f,nr
	asl.w	#2,d2
	move.l	#irqtab,a4
	move.l	0(a4,d2.w),a2
	jmp	(a2)

no109:
	move.l	#block0,a6
	bsr	show
	move.l	#block1,a6
	move.l	#puff1,a5
	bra	linksw
no210:
	move.l	#block1,a6
	bsr	show
	move.l	#block2,a6
	move.l	#puff2,a5
	bra	linksw
no311:
	move.l	#block2,a6
	bsr	show
	move.l	#block3,a6
	move.l	#puff3,a5
	bra	linksw
no412:
	move.l	#block3,a6
	bsr	show
	move.l	#block4,a6
	move.l	#puff4,a5
	bra	linksw
no513:
	move.l	#block4,a6
	bsr	show
	move.l	#block5,a6
	move.l	#puff5,a5
	bra	linksw
no614:
	move.l	#block5,a6
	bsr	show
	move.l	#block6,a6
	move.l	#puff6,a5
	bra	linksw
no715:
	move.l	#block6,a6
	bsr	show
	move.l	#block7,a6
	move.l	#puff7,a5
	bra	linksw

no8:
	move.w	#8,teil
	move.l	#block7,a6
	bsr	show
	bsr	addbuff
	move.l	#block0,a6
	move.l	puff0,a5
	bra	linksw
no0:
	move.l	#block7,a6
	bsr	show
	move.l	#text,a0
	move.l	#tabelle,a1
	clr.w	teil

nochmal:
	move.w	zeiger,d0
	move.b	)(a0,d0.w),d1

noeffect:
	cmp.b	#$3f,d1
	bne	noch2
	clr.w	zeiger
	bra	nochmal

noch2:
	ext.w	d1
	asl.w	#2,d1
	move.l	0(a1,d1.w),zeichen1
	addq.w	#1,zeiger
	move.w	zeiger,d0

notex:
	move.b	0(a0,d0.w),d1
	cmp.b	#$3f,d1
	bne	noch3
	move.b	(a0),d1

noch3:
	ext.w	d1
	asl.w	#2,d1
	move.l	0(a1,d1.w),zeichen2
	bsr	addbuff
	move.l	#block0,a6
	move.l	#puff0,a5

linksw:
	move.w	zanz,d0
	subq.w	#1,d0

zeilen:
	movem.l	8(a6),d1-d7/a0-a4
	movem.l	d1-d7/a0-a4,(a6)
	movem.l	56(a6),d1-d7/a0-a4
	movem.l	d1-d7/a0-a4,48(a6)
	movem.l	104(a6),d1-d7/a0-a4
	movem.l	d1-d7/a0-a4,96(a6)
	add.l	#144,a6
	move.l	8(a6),(a6)+
	move.l	8(a6),(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	dbf	d0,zeilen
	rts

show:
	move.w	zanz,d0
	subq.w	#1,d0
	move.l	#scrollbase,a5

szeilen:	
	movem.l	(a6),d1-d7/a0-a4
	movem.l	d1-d7/a0-a4,(a5)
	movem.l	48(a6),d1-d7/a0-a4
	movem.l	d1-d7/a0-a4,48(a5)
	movem.l	96(a6),d1-d7/a0-a4
	movem.l	d1-d7/a0-a4,96(a5)
	movem.l	144(a6),d4-d7
	movem.l	d4-d7,144(a5)
	add.l	#160,a6
	add.l	#160,a5
	dbf	d0,szeilen
	rts

addbuff:
	movem.l	d0-d7/a0/a1,-(sp)
	move.w	zanz,d7
	subq.w	#1,d7
	move.w	teil,d6
	moveq	#8,d5
	move.l	zeichen1,d4
	cmp.w	#8,d6
	bne	puffer0
	move.l	zeichen2,d5
	sub.l	d4,d5

puffer0:
	move.w	d7,d0
	move.l	#puff0,a0
	move.l	d4,a1
	
puff0b:
	move.l	0(a1,d6.w),(a0)+
	move.l	4(a1,d6.w),(a0)+
	add.l	#160,a1
	dbf	d0,puff0b
	move.w	#$e,d2
	
puff1a:
	move.w	d2,d0
	move.w	d2,d3
	asl.w	#1,d0
	move.l	#puffer,a0
	move.l	0(a0,d0.w),a0
	move.l	d4,a1
	move.w	d7,d0

puff1b:
	move.w	0(a1,d5.l),d1
	swap	d1
	move.w	0(a1,d6.w),d1
	rol.l	d3,d1
	move.w	d1,(a0)+

	move.w	2(a1,d5.l),d1
	swap	d1
	move.w	2(a1,d6.w),d1
	rol.l	d3,d1
	move.w	d1,(a0)+

	move.w	4(a1,d5.l),d1
	swap	d1
	move.w	4(a1,d6.w),d1
	rol.l	d3,d1
	move.w	d1,(a0)+

	move.w	6(a1,d5.l),d1
	swap	d1
	move.w	6(a1,d6.w),d1
	rol.l	d3,d1
	move.w	d1,(a0)+

	add.l	#160,a1
	dbf	d0,puff1b
	
	subq.w	#2,d2
	bne	puff1a
	
	movem.l	(sp)+,d0-d7/a0/a1
	rts

nr:		dc.w 0
zanz:		dc.l 0
teil:		dc.l 0
zeiger:		dc.w 0
zeichen1:	dc.l 0
zeichen2:	dc.l 0
tabelle:	dc.l 64,0

puffer:	dc.l puff0,puff1,puff2,puff3,puff4,puff5,puff6,puff7	
irqtab:	dc.l no0,no109,no210,no311,no412,no513,no614,no715
	dc.l no8,no109,no210,no311,no412,no513,no614,no715

text:	dc.b	0,1,2,3,4,5,6,7,8,9,10,$3f
even
