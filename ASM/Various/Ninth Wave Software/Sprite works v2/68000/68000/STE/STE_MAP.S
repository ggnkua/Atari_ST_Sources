;
; ~C:ste_map%(x,y,height,L:map,L:gfx,L:screen)
;

ste_map movem.l	d1-7/a0-6,-(a7)
	lea	height(pc),a0
	movem	60(a7),d0-1
	move	64(a7),(a0)
	move.l	66(a7),a6
	move.l	70(a7),a4
	move.l	74(a7),a5
	move	(a6),d2
	lsl	#2,d2
	sub	#(21*4),d2
	lea	map_inc(pc),a0
	move	d2,(a0)

	ext.l	d0
	bpl.s	.c1
	moveq	#0,d0
.c1	move	(a6),d2
	sub	#21,d2
	ext.l	d2
	lsl.l	#4,d2
	cmp.l	d2,d0
	ble.s	.c2
	move.l	d2,d0
.c2	ext.l	d1
	bpl.s	.c3
	moveq	#0,d1
.c3	move	2(a6),d2
	sub	4(a0),d2
	ext.l	d2
	lsl.l	#4,d2
	cmp.l	d2,d1
	ble.s	.c4
	move.l	d2,d1
.c4	move	d0,d2
	and.l	#$f,d2
	move.l	d2,-(a7)
	lsr.l	#2,d0
	and	#$fffc,d0

	move	d1,d2
	lsr.l	#4,d1
	mulu	(a6),d1
	lsl.l	#2,d1
	add.l	d1,a6
	add.l	d0,a6
	
	lea	10(a6),a6
	clr	2(a0)
	and	#$f,d2
	beq.s	.int
	st	2(a0)

	move	d2,d7
	move	d7,-(a7)
	neg	d7
	add	#15,d7

	lsl	#3,d2
	move.l	a4,-(a7)
	add	d2,a4
	
	moveq	#4,d0
.txlp	movem.l	d0/d7/a5,-(a7)
	movem.l	(a6)+,a0-3
	add.l	a4,a0
	add.l	a4,a1
	add.l	a4,a2
	add.l	a4,a3
.tylp	move	d7,-(a7)	
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a1)+,d2
	move.l	(a1)+,d3
	move.l	(a2)+,d4
	move.l	(a2)+,d5
	move.l	(a3)+,d6
	move.l	(a3)+,d7
	movem.l	d0-7,(a5)
	lea	168(a5),a5
	move	(a7)+,d7
	dbf	d7,.tylp
	movem.l	(a7)+,d0/d7/a5
	lea	32(a5),a5
	dbf	d0,.txlp
	movem.l	(a6)+,a0
	add.l	a4,a0
.tylpe	move.l	(a0)+,(a5)
	move.l	(a0)+,4(a5)
	lea	168(a5),a5
	dbf	d7,.tylpe
	lea	-160(a5),a5
	add	map_inc(pc),a6
	move.l	(a7)+,a4
	
.int	move	height(pc),d7
	subq	#1,d7
	lea	map_int(pc),a0
	tst	(a0)
	beq.s	.ylp
	subq	#1,d7
.ylp	swap	d7
	move	#4,d7
.xlp	movem.l	(a6)+,a0-3
	add.l	a4,a0
	add.l	a4,a1
	add.l	a4,a2
	add.l	a4,a3
	move.l	d7,-(a7)
line set 0
	rept	16
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a1)+,d2
	move.l	(a1)+,d3
	move.l	(a2)+,d4
	move.l	(a2)+,d5
	move.l	(a3)+,d6
	move.l	(a3)+,d7
	movem.l	d0-7,line(a5)
line set line+168
	endr
	
	move.l	(a7)+,d7
	lea	32(a5),a5
	dbf	d7,.xlp

	move.l	(a6)+,a0
	add.l	a4,a0
line set 0
	rept	16
	move.l	(a0)+,line(a5)
	move.l	(a0)+,line+4(a5)
line set line+168
	endr
		
	add	map_inc(pc),a6
	lea	(15*168)+8(a5),a5
	swap	d7
	dbf	d7,.ylp

	lea	map_int(pc),a0
	tst	(a0)
	bne.s	.bottom
	move.l	(a7)+,d0
	movem.l	(a7)+,d1-7/a0-6
	rts

.bottom	move	(a7)+,d7
	subq	#1,d7
	move	#4,d0
.bxlp	movem.l	d0/d7/a5,-(a7)
	movem.l	(a6)+,a0-3
	add.l	a4,a0
	add.l	a4,a1
	add.l	a4,a2
	add.l	a4,a3
.bylp	move	d7,-(a7)	
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a1)+,d2
	move.l	(a1)+,d3
	move.l	(a2)+,d4
	move.l	(a2)+,d5
	move.l	(a3)+,d6
	move.l	(a3)+,d7
	movem.l	d0-7,(a5)
	lea	168(a5),a5
	move	(a7)+,d7
	dbf	d7,.bylp
	movem.l	(a7)+,d0/d7/a5
	lea	32(a5),a5
	dbf	d0,.bxlp
	movem.l	(a6)+,a0
	add.l	a4,a0
.bylpe	move.l	(a0)+,(a5)
	move.l	(a0)+,4(a5)
	lea	168(a5),a5
	dbf	d7,.bylpe
	move.l	(a7)+,d0
	movem.l	(a7)+,d1-7/a0-6
	rts
map_inc	ds.w	1
map_int	ds.w	1
height	ds.w	1	
