; Ancient Picture roll!
; by Tony -B-



	pea	0.w
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldstk
	
	clr	-(sp)
	pea	$70000
	pea	$70000
	move	#5,-(sp)
	trap	#14
	lea	$c(sp),sp

	move.l	#pic+2,$45a.w

	lea	$60000,a0
copy:	clr.l	(a0)+		;clear some screen memory
	cmpa.l	$80000,a0
	blt.s	copy
	
	lea	pic+34(pc),a0	;draw pic in memory just
	lea	$62000,a1		;below the real screen
	move	#7999,d0
draw:
	move.l	(a0)+,(a1)+
	dbf	d0,draw

	move.l	#$60660,d2	;setup screens
	move.l	#$6e660,d3
	move.l	#$64bc0,d4
	bsr.s	picroll		;roll 'em
	
*---------
scan:	stop	#$2300
	cmp.b	#57,$fffffc02.w
	bne.s	scan
*---------

	move.l	#gempal,$45a.w
	
	move.l	oldstk(pc),-(sp)
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr	-(sp)
	trap	#1



*---------
picroll:	move	$468.w,d0		;Vsync
.vs:	cmp	$468.w,d0
	beq.s	.vs
	
	movea.l	d2,a2
	movea.l	d3,a1
	bsr.s	move_gfx
	
	moveq	#0,d0
	bsr.s	control
	
	add.l	#160,d2
	add.l	#160,d3
	add.l	#160,d4
	
	cmp.l	#$77d00,d3
	bne.s	picroll
	rts


control:	lea	data(pc),a0
	addq	#2,d0		;increase offset in table
	move	(a0,d0),d1	;get offset
	sub.l	d1,d4
	movea.l	d4,a2
	lea	160(a1),a1	;one line down
	bsr.s	move_gfx
	cmp	#80,d0		;end of table?
	bne.s	control
	add.l	#11200,d4
	rts

move_gfx	cmpa.l	#$77c60,a1
	bgt.s	noty
	rept	40
	move.l	(a2)+,(a1)+	;draw onto screen
	endr
noty:	lea	-160(a2),a2	;next line
	lea	-160(a1),a1
	rts



*---------
	data

oldstk:	dc.l	0
gempal:	dc.w	$777,$700,$070,$000,$007,$707,$077,$555
	dc.w	$333,$733,$373,$773,$337,$737,$377,$000

data:	dc.w	160,960,640,480,480,320,320,320
	dcb.w	26,160
	dc.w	320,320,320,480,480,640,960,160

pic	incbin	b:\tbe.pi1
