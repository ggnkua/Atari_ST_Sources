;
; test efficacit‚ de la topographie
;
; test sur 12 bytes
;
max:	equ	3
freq:	equ	$57000
debut:	equ	$20000
fin:	equ	debut+222000

	moveq	#0,d7	;nb octets gagn‚s
	moveq	#256/2-1,d0
	lea	freq,a6
	move.l	a6,a0
clrf:
	move	d7,(a0)+
	dbra	d0,clrf

	lea	debut,a0
	lea	fin,a1
	moveq	#0,d0
suite:
	move.b	(a0)+,d0	;0
	addq.b	#1,0(a6,d0.w)
	move.b	(a0)+,d0	;1
	addq.b	#1,0(a6,d0.w)
	move.b	(a0)+,d0	;2
	addq.b	#1,0(a6,d0.w)
	move.b	(a0)+,d0	;3
	addq.b	#1,0(a6,d0.w)
	move.b	(a0)+,d0	;4
	addq.b	#1,0(a6,d0.w)
	move.b	(a0)+,d0	;5
	addq.b	#1,0(a6,d0.w)
	move.b	(a0)+,d0	;6
	addq.b	#1,0(a6,d0.w)
	move.b	(a0)+,d0	;7
	addq.b	#1,0(a6,d0.w)
	move.b	(a0)+,d0	;8
	addq.b	#1,0(a6,d0.w)
	move.b	(a0)+,d0	;9
	addq.b	#1,0(a6,d0.w)
	move.b	(a0)+,d0	;10
	addq.b	#1,0(a6,d0.w)
	move.b	(a0)+,d0	;11
	addq.b	#1,0(a6,d0.w)
	lea	-12(a0),a0

	moveq	#0,d6

	move.b	(a0)+,d0
	cmp.b	0(a6,d0.w),d6
	bhs.s	not1
	move.b	0(a6,d0.w),d6
not1:
	clr.b	0(a6,d0.w)
	move.b	(a0)+,d0
	cmp.b	0(a6,d0.w),d6
	bhs.s	not2
	move.b	0(a6,d0.w),d6
not2:
	clr.b	0(a6,d0.w)
	move.b	(a0)+,d0
	cmp.b	0(a6,d0.w),d6
	bhs.s	not3
	move.b	0(a6,d0.w),d6
not3:
	clr.b	0(a6,d0.w)
	move.b	(a0)+,d0
	cmp.b	0(a6,d0.w),d6
	bhs.s	not4
	move.b	0(a6,d0.w),d6
not4:
	clr.b	0(a6,d0.w)
	move.b	(a0)+,d0
	cmp.b	0(a6,d0.w),d6
	bhs.s	not5
	move.b	0(a6,d0.w),d6
not5:
	clr.b	0(a6,d0.w)
	move.b	(a0)+,d0
	cmp.b	0(a6,d0.w),d6
	bhs.s	not6
	move.b	0(a6,d0.w),d6
not6:
	clr.b	0(a6,d0.w)
	move.b	(a0)+,d0
	cmp.b	0(a6,d0.w),d6
	bhs.s	not7
	move.b	0(a6,d0.w),d6
not7:
	clr.b	0(a6,d0.w)
	move.b	(a0)+,d0
	cmp.b	0(a6,d0.w),d6
	bhs.s	not8
	move.b	0(a6,d0.w),d6
not8:
	clr.b	0(a6,d0.w)
	move.b	(a0)+,d0
	cmp.b	0(a6,d0.w),d6
	bhs.s	not9
	move.b	0(a6,d0.w),d6
not9:
	clr.b	0(a6,d0.w)
	move.b	(a0)+,d0
	cmp.b	0(a6,d0.w),d6
	bhs.s	not10
	move.b	0(a6,d0.w),d6
not10:
	clr.b	0(a6,d0.w)
	move.b	(a0)+,d0
	cmp.b	0(a6,d0.w),d6
	bhs.s	not11
	move.b	0(a6,d0.w),d6
not11:
	clr.b	0(a6,d0.w)
	move.b	(a0)+,d0
	cmp.b	0(a6,d0.w),d6
	bhs.s	not12
	move.b	0(a6,d0.w),d6
not12:
	clr.b	0(a6,d0.w)

	add.l	d6,d7

	cmp.l	a1,a0
	blo	suite
	illegal
