;------------------------------------------------------------------------
;                  TetraPacker V2.2 Decruncher ripped by                ;
;                                                                       ;
;                             NATIVE / EFFECT                           ;
;------------------------------------------------------------------------
>extern"in+",filecrd	;CR

lowmem = $20000		;40000
highmem = $40000	;50000
jumpadres = $30000	;42000
lengtecrd = $01ad4	;1a68

org	$1f000		;30020
load	$1f000		;30020

begin:	moveq	#$00,d7
	lea	Filecrd(pc),a1
	lea	$dff182.l,a5
	move.l	l300f0+2(pc),a4
	move.l	a4,a0
l30032:	add.l	#lengtecrd,a0	;	Lengte File Crunched !!
	cmp.l	a4,a1
	bgt	l30044
	move.l	a1,a0
	add.l	l30032+2(pc),a0
	bra	l3004a
l30044:	move.b	(a1)+,(a4)+
	cmp.l	a0,a4
	blt	l30044
l3004a:	lea	$03b697.l,a1	;4d2ad
	move.l	-(a0),a2
	add.l	a1,a2
	move.l	-(a0),d0
l30056:	lsr.l	#1,d0
	bne	l3005c
	bsr	l30090
l3005c:	bcs	l300c8
	moveq	#$08,d1
	moveq	#$01,d3
	lsr.l	#1,d0
	bne	l30068
	bsr	l30090
l30068:	bcs	l300a6
	moveq	#$03,d1
	moveq	#$00,d4
l3006e:	bsr	l300b6
	move.w	d2,d3
	add.w	d4,d3
l30074:	moveq	#$07,d1
l30076:	lsr.l	#1,d0
	bne	l3007c
	bsr	l30090
l3007c:	roxl.l	#1,d2
	dbf	d1,l30076
	move.b	d2,-(a2)
	dbf	d3,l30074
	bra	l300b0
l3008a:	moveq	#$07,d1
	moveq	#$08,d4
	bra	l3006e
l30090:	move.l	-(a0),d0
	move.b	d0,d7
	move.w	d7,(a5)
	move.w	#$0010,ccr
	roxr.l	#1,d0
	rts

l3009e:	moveq	#$09,d1
	move.w	d2,d3
	add.w	d2,d1
	addq.w	#2,d3
l300a6:	bsr	l300b6
l300a8:	move.b	$ff(a2,d2.w),-(a2)
	dbf	d3,l300a8
l300b0:	cmp.l	a2,a1
	blt	l30056
	bra	l300ee
l300b6:	subq.w	#1,d1
	moveq	#$00,d2
l300ba:	lsr.l	#1,d0
	bne	l300c0
	bsr	l30090
l300c0:	roxl.l	#1,d2
	dbf	d1,l300ba
	rts

l300c8:	moveq	#$02,d1
	bsr	l300b6
	cmp.b	#$0002,d2
	blt	l3009e
	cmp.b	#$0003,d2
	beq	l3008a
	moveq	#$08,d1
	bsr	l300b6
	move.w	d2,d3
	addq.w	#4,d3
	moveq	#$0b,d1
	bra	l300a6

credits:dc.b	" TETRAGON "
l300ee:	dc.w	$7e2f	;7e91

l300f0:	lea	lowmem.l,a0
	lea	highmem.l,a2
l300fc:	move.b	(a1)+,d0
	cmp.b	d7,d0
	bne	l30112
	moveq	#$00,d1
	move.b	(a1)+,d1
	beq	l30112
	move.b	(a1)+,d0
	addq.w	#1,d1
l3010c:	move.b	d0,(a0)+
	dbf	d1,l3010c
l30112:	move.w	d0,(a5)
	move.b	d0,(a0)+
	cmp.l	a2,a1
	blt	l300fc
	jmp	jumpadres
Filecrd:			;The Crunched Data File
				;Without decruncher ofcourse !!
