;SPRITESTARSROUTINE ==============================

initstars:		;jump to this only once.
	move.l #StarSprite,d0
	move.w d0,spritepointers+6
	move.w d0,spritepointers2+6
	swap d0
	move.w d0,spritepointers+2
	move.w d0,spritepointers2+2

	move.l	#StarSprite,a0
	move.l	#StarAdd,a1
	move.l	#StarBlebb,a2
	moveq	#$20,d0			;YposStart of stars
	move.l	#148-1,d7		;No of Stars [max. 148]

instlp:	jsr	random			;returns random value in d6
	move.l	d0,d1
	lsl.w	#8,d1
	move.l	d1,d2
	lsr.w	#3,d6
	move.w	d6,(a2)+
	lsr.w	#5,d6
	add.w	d6,d1			;first spritedataword in d1
	move.w	d1,(a0)+


	add.w	#$0100,d2		;Sprites are 1 pixel high
	btst	#8,d0
	beq.s	Skipadd
	move.b	#$06,d2			;second spritedataword in d2
SkipAdd:move.w	d2,(a0)+
TryAga:	jsr	random
	lsr.w	#8,d6

	btst	#0,d6
	bne.s	NotW1
	btst	#3,d6
	bne.s	NotW1
	btst	#5,d6
	bne.s	NotW1
	move.l	#$00000001,(a0)+
	jsr	random
	swap	d6
	and.w	#$001f,d6
	add.w	#15,d6
	move.w	#$065b,(a1)+
	move.w	d6,(a1)+
	bra.s	DataWritten
NotW1:	btst	#0,d6
	bne.s	NotW2
	btst	#3,d6
	beq.s	NotW2
	btst	#5,d6
	bne.s	NotW2
	move.l	#$00010000,(a0)+
	jsr	random
	swap	d6
	and.w	#$000f,d6
	add.w	#7,d6
	move.w	#$065b,(a1)+
	move.w	d6,(a1)+
	bra.s	DataWritten
NotW2:;	btst	#0,d6
;	beq.s	TryAga
;	btst	#3,d6
;	bne.s	TryAga
	move.l	#$00010001,(a0)+
	jsr	random
	swap	d6
	and.w	#$0007,d6
	add.w	#1,d6
	move.w	#$065b,(a1)+
	move.w	d6,(a1)+

DataWritten:
	addq.w	#2,d0
	dbf	d7,instlp
	rts

random:movem.l	a0-a6/d0-d5,-(a7)
	movem.l	rnd,d0/d1
	and.b	#$e,d0
	or.b	#$20,d0
	move.l	d0,d2
	move.l	d1,d3
	add.l	d2,d2
	addx.l	d3,d3
	add.l	d2,d0
	addx.l	d3,d1
	swap	d3
	swap	d2
	move.w	d2,d3
	clr.l	d2
	add.l	d2,d0
	addx.l	d3,d1
	movem.l	d0/d1,rnd
	move.l	d1,d6
	movem.l	(a7)+,a0-a6/d0-d5
	rts

rnd:	dc.l	$a46fc297,$3650eab3

stars:			;jump to this once every scan!

	lea.l	StarBlebb,a3

staradd:blk.l	148,0	;nice "add.w #xx,(a3)+", isn't it?!?! (148 st.)

	lea.l	StarSprite+1,a0
	lea.l	StarBlebb,a3

	move.w	#148-1,d7

starloop:
	move.w	(a3)+,d0
	lsr.w	#5,d0
	bcs.s	stset
	bclr	#0,2(a0)
	bra.s	stok
stset:	bset	#0,2(a0)
stok:	move.b	d0,(a0)
	addq.l	#8,a0
	dbf	d7,starloop
	rts

