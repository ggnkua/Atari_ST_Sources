
	DC.W	$A00A
	MOVE.L	#$00000002,-(A7)
	MOVE.W	#21,-(A7)
	TRAP	#14
	ADDQ.L	#6,A7

	MOVE.L	$4(A7),A5
	MOVE.L	#$400,-(A7)
	MOVE.L	A5,-(A7)
	MOVE.W	#$0,-(A7)
	MOVE.W	#$4A,-(A7)
	TRAP	#$01
	ADD.L	#12,A7

	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	MOVE.L	D0,savesp
	lea	$70000,A7
	
clrpal	lea	$ffff8240,a0
	lea	defpal,a1
	move.w	#$f,d0
clrloop	move.w	(a0)+,(a1)+
	dbf	d0,clrloop
	
	clr.b	$484
normal	move.l	$44e,scrnpos
	clr.w	-(a7)
	move.l	scrnpos,-(a7)
	move.l	(a7),-(a7)
	move.w	#5,-(a7)
	trap	#$e
	lea.l	12(a7),a7
	
	lea	deadpal(pc),a0
	bsr	dofade
	
	lea	pic+$22(pc),a0
	move.l	scrnpos,a1
	move.w	#$1f3f,d0
picloop	move.l	(a0)+,(a1)+
	dbf	d0,picloop
	
	lea	pic+$2,a0
	bsr	dofade
	
	move.w	#$8,-(a7)
	trap	#$01
	addq.l	#2,a7
	
	move.b	#$7,$484
	
	lea	deadpal(pc),a0
	bsr	dofade
	
	move.l	scrnpos,a0
	move.w	#$1f3f,d0
clrloop2	clr.l	(a0)+
	dbf	d0,clrloop2
	
	lea	defpal,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240
	
	move.w	#$1,-(a7)
	move.l	scrnpos,-(a7)
	move.l	(a7),-(a7)
	move.w	#$5,-(a7)
	trap	#14
	add.l	#$c,a7
	
	dc.w	$a009
tt4	clr.l	$60000
	clr.w	-(sp)
	pea	$60000
	pea	$60000
fadd	pea	menurun(pc)
	move.l	#$4b0000,-(sp)
	trap	#1
	
	clr.l	-(a7)
	trap	#$01
	
dofade	movem.l	d0-d5/a0-a2/a5,-(a7)
	move.l	a0,a2
	moveq	#$7,d4
fade1	moveq	#$2,d2
fade2	lea	$ffff8240,a0
	move.l	a2,a1
	moveq	#$f,d3
fade3	move.w	(a0),d0
	move.w	(a1)+,d5
	move.w	d0,d1
	cmpi.b	#$2,d2
	beq.s	fade5
	cmpi.b	#$1,d2
	beq.s	fade4
	andi.b	#$7,d1
	andi.b	#$7,d5
	cmp.b	d1,d5
	beq.s	fade6
	addq.b	#1,d0
	bra.s	fade6
fade4	andi.b	#$70,d1
	andi.b	#$70,d5
	cmp.b	d1,d5
	beq.s	fade6
	addi.b	#$10,d0
	bra.s	fade6
fade5	andi.w	#$700,d1
	andi.w	#$700,d5
	cmp.w	d1,d5
	beq.s	fade6
	addi.w	#$100,d0
fade6	move.w	d0,(a0)+
	dbf	d3,fade3
	moveq	#$1,d1
	move.w	#$4000,d0		;delay for fade
waitup	dbf	d0,waitup
	move.w	#$25,-(a7)
	trap	#14
	addq.l	#2,a7
	dbf	d2,fade2
	dbf	d4,fade1
	movem.l	(a7)+,d0-d5/a0-a2/a5
	rts
	
	
menurun	dc.b	"AUTO.DAT",0

savesp	dc.l	0
scrnpos	dc.l	0
defpal	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	
deadpal	dc.w	$777,$777,$777,$777,$777,$777,$777,$777
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777
		
pic	incbin	"menu111\INFOCOM2.PI1"
