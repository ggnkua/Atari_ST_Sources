*** Test Generateur de Line pour 3d ***
***   ZANAK / ATROCITY - Aout 1994  ***

	opt	o+
	
y1	equ	10
y2	equ	100
x1	equ	10
x2	equ	100

	section text
	
Trois_D

Test_des_coordonnees_Y
	move.w	y1,d5
	cmp.w	y2,d5
	beq	Trace_la_line_horizontale
Test_des_coordonnees_X
	move.w	x2,d5
	sub.w	x1,d5
	beq	Trace_la_line_verticale
	bmi.s	Line_quelconque_avec_x1_plus_grand_que_x2
	
Line_quelconque_avec_x2_plus_grand_que_x1
	move.w	x1,d0
	move.w	y1,d1
	lsl.w	#2,d1
	adda.w	d1,a5
	
	move.w	y2,d4
	sub.w	y1,d4		; Delta Y
	bra.s	Trace_la_line1
	
Line_quelconque_avec_x1_plus_grand_que_x2
	move.w	x2,d0
	move.w	y2,d1
	lsl.w	#2,d1
	adda.w	d1,a5
	
	neg.w	d5
	move.w	y1,d4
	sub.w	y2,d4		; Delta Y		
	
Trace_la_line1
	bpl.s	Trace_la_line2
	neg.w	d4
	neg.w	d7
	
Trace_la_line2
	cmp.w	d4,d5
	bmi.s	Trace_la_line_avec_dx_plus_petit_que_dy
	
Trace_la_line_avec_dx_plus_grand_ou_egale_a_dy
	move.w	d5,d2
	add.w	d4,d4
	move.w	d4,d3
	sub.w	d5,d4
	move.w	d4,d6
	sub.w	d5,d6	; d6=2*(dy-dx)
	
Lin1_lp1
	cmp.w	(a5),d0
	bgt.s	Lin1_lp2
	move.w	d0,(a5)
	
Lin1_lp2
	tst.w	d4
	bmi.s	Lin1_no_y
	add.w	d6,d4
	cmp.w	2(a5),d0
	blt.s	Lin1_end1
	move.w	d0,2(a5)

Lin1_end1
	adda.w	d7,a5
	addq.w	#1,d0
	dbf	d2,Lin1_lp1
	movem.l	(a7)+,d0-d7/a5
	rts
	
Lin1_no_y
	add.w	d3,d4
	cmp.w	2(a5),d0
	blt.s	Lin1_end2
	move.w	d0,2(a5)
	
Lin1_end2
	addq.w	#1,d0
	dbf	d2,Lin1_lp2
	movem.l	(a7)+,d0-d7/a5
	rts
	
Trace_la_line_avec_dx_plus_petit_que_dy
	exg	d4,d5
	move.w	d5,d2
	add.w	d4,d4
	move.w	d4,d3
	sub.w	d5,d4
	move.w	d4,d6
	sub.w	d5,d6	; d6=2*(dx-dy)
	
Lin2_lp
	tst.w	d4
	bmi.s	Lin2_no_x
	add.w	d6,d4
	cmp.w	(a5),d0
	bgt.s	Lin2_max1
	move.w	d0,(a5)
	
Lin2_max1
	cmp.w	2(a5),d0
	blt.s	Lin2_end1
	move.w	d0,2(a5)
	
Lin2_end1
	addq.w	#1,d0
	adda.w	d7,a5
	dbf	d2,Lin2_lp
	movem.l	(a7)+,d0-d7/a5
	
Lin2_no_x
	add.w	d3,d4
	cmp.w	(a5),d0
	bgt.s	Lin2_max2
	move.w	d0,(a5)
	
Lin2_max2
	cmp.w	2(a5),d0
	blt.s	Lin2_end2
	move.w	d0,2(a5)
	
Lin2_end2
	adda.w	d7,a5
	dbf	d2,Lin2_lp
	movem.l	(a7)+,d0-d7/a5
	rts
	
Trace_la_line_horizontale
	move.w	x1,d0
	move.w	x2,d1
	cmp.w	d0,d1
	bgt.s	Line_horizontale0
	exg	d0,d1
	
Line_horizontale0
	move.w	y1,d2
	lsl.w	#2,d2
	adda.w	d2,a5
	cmp.w	(a5),d0
	bgt.s	Line_horizontale1
	move.w	d0,(a5)

Line_horizontale1
	cmp.w	2(a5),d1
	blt.s	Line_horizontale2
	move.w	d1,2(a5)

Line_horizontale2
	movem.l	(a7)+,d0-d7/a5
	rts
	
Trace_la_line_verticale
	move.w	y1,d0
	move.w	d0,d1
	sub.w	y2,d1
	ble.s	Line_verticale0
	neg.w	d1
	move.w	y2,d0
	
Line_verticale0
	neg.w	d1
	lsl.w	#2,d0
	adda.w	d0,a5
	move.w	x1,d0
	
Line_verticale1
	cmp.w	(a5),d0
	bgt.s	Line_verticale2
	move.w	d0,(a5)
	
Line_verticale2
	cmp.w	2(a5),d0
	blt.s	Line_verticale3
	move.w	d0,2(a5)
	
Line_verticale3
	addq.l	#4,a5
	dbra	d1,Line_verticale1
	movem.l	(a7)+,d0-d7/a5
	rts
	
	
	
		

	
	