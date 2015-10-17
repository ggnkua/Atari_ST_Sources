	bra	path_calc
	bra	path_update
	bra	path_state
	bra	path_xy
	
MAX_PATHS	= 50
PATH_MODE	= 0
PATH_X		= 2
PATH_Y		= 6
PATH_XYINC	= 10
PATH_XINC	= 10
PATH_YINC	= 14
PATH_LENGTH	= 18
PATH_SIZE	= 20

	opt	o+
path_kill
	move.l	a0,-(a7)
	lea	points(pc),a0
	move	8(a7),d0
	bmi.s	.all
	mulu	#PATH_SIZE,d0
	add	d0,a0
	clr	PATH_MODE(a0)
	move.l	(a7)+,a0
	rts
.all	moveq	#MAX_PATHS-1,d0
.lp	clr	PATH_MODE(a0)
	lea	PATH_SIZE(a0),a0
	dbf	d0,.lp
	move.l	(a7)+,a0
	rts

path_calc
	movem.l	d1-7/a0,-(a7)
	move	36(a7),d5
	movem	38(a7),d0-4
	lea	points(pc),a0
	mulu	#PATH_SIZE,d5
	add	d5,a0
	bsr	calc_path
	move	#1,PATH_MODE(a0)
	move.l	d0,PATH_X(a0)
	move.l	d1,PATH_Y(a0)
	move.l	d2,PATH_XINC(a0)
	move.l	d3,PATH_YINC(a0)
	move	d7,PATH_LENGTH(a0)
	movem.l	(a7)+,d1-7/a0
	rts

path_update
	movem.l	d1-2/a0,-(a7)
	move	16(a7),d0
	lea	points(pc),a0
	mulu	#PATH_SIZE,d0
	add	d0,a0
	tst	PATH_MODE(a0)
	beq.s	.fin
	subq.w	#1,PATH_LENGTH(a0)
	bmi.s	.kill
	movem.l	PATH_XYINC(a0),d1-2
	add.l	d1,PATH_X(a0)
	add.l	d2,PATH_Y(a0)
	moveq	#0,d0
	bra.s	.end
.kill	clr	PATH_MODE(a0)
.fin	moveq	#-1,d0
.end	movem.l	(a7)+,d1-2/a0
	rts

path_state
	move.l	a0,-(a7)
	move	8(a7),d0
	lea	points(pc),a0
	mulu	#PATH_SIZE,d0
	add	d0,a0
	tst	PATH_MODE(a0)
	beq.s	.dead
	moveq	#0,d0
	move.l	(a7)+,a0
	rts
.dead	moveq	#-1,d0
	move.l	(a7)+,a0
	rts

path_xy	move.l	a0,-(a7)
	move	8(a7),d0
	lea	points(pc),a0
	mulu	#PATH_SIZE,d0
	add	d0,a0
	move	PATH_X(a0),d0
	swap	d0
	move	PATH_Y(a0),d0
.end	move.l	(a7)+,a0
	rts

*		
* Calculate path : D0=x1 D1=y1 D2=x2 D3=y2 D4=speed
*
calc_path
	subq	#1,d4
	bmi.s	.done
	move	d0,d5
	sub	d5,d2		; d2=x2-x1
	move	d1,d5
	sub	d5,d3		; d3=y2-y1
	move	d2,d5
 	bpl.s	.is_1
	neg	d5		; d5=abs(x2-x1)
.is_1	move	d3,d6
	bpl.s	.is_2	
	neg	d6		; d6=abs(y2-y1)
.is_2	cmp	d5,d6
	bgt.s	.is_3
	move	d5,d7		; d7=line length is abs(x2-x1)
	tst	d2
	bmi.s	.negx
.posx	move.l	#$00010000,d2	; x inc is 1, calc y ...
	bra.s	.xok
.negx	move.l	#$FFFF0000,d2	; x inc is -1, calc y ...
.xok	asl	#6,d3		; multiply by 64
	ext.l	d3		; make into .L for divs
	beq.s	.isd2		; avoid divide by zero
	divs	d7,d3
.isd2	ext.l	d3		; gid rid of remainder
	swap	d3		; \ These two instructions are
	asr.l	#6,d3		; / multiply by 1024
	lsl.l	d4,d3		; multiply by speed
	lsl.l	d4,d2
	bra.s	.done
.is_3	move	d6,d7		; line length is abs(y2-y1)
	tst	d3
	bmi.s	.negy
.posy	move.l	#$00010000,d3	; y inc is 1, calc x ...
	bra.s	.yok
.negy	move.l	#$FFFF0000,d3	; y inc is -1, calc x ...
.yok	asl	#6,d2
	ext.l	d2
	beq.s	.isd1
	divs	d7,d2
.isd1	ext.l	d2
	swap	d2
	asr.l	#6,d2
	lsl.l	d4,d2
	lsl.l	d4,d3
.done	lsr	d4,d7		; divide length by speed
	swap	d0
	swap	d1
	clr	d0		; remove low word rubbish
	clr	d1
	rts

points	ds.b	PATH_SIZE*MAX_PATHS
