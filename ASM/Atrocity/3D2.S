*** Routine trace 3D ***

Points	equ	20
Cos	equ	64
Centre_X	equ	160
Centre_Y	equ	100
Save_size	equ	3001
Ligne_seq	equ	%1111101101101111

	lea	Fin_coord(pc),a3
	moveq	#Points,d6

Calcul_des_points:
	move.b	-(a3),d1
	move.b	-(a3),d0
	ext.w	d0
	ext.w	d1
	
	move.w	d0,d2
	muls.w	Cos(a0),d0
	muls.w	(a0),d2
	asl.w	#7,d1
	
	move.w	d1,d3
	move.w	d2,d4
	muls.w	(a1),d4
	muls.w	Cos(a1),d1
	sub.l	d4,d1
	
	muls.w	(a1),d3
	muls.w	Cos(a1),d2
	add.l	d3,d2
	
	asr.l	#7,d1
	asr.l	#7,d2
	
	moveq	#127,d4
	asr.w	#8,d2
	sub.w	d2,d4
	divs	d4,d0
	divs	d4,d1
	addi.w	#Centre_X,d0
	addi.w	#Centre_Y,d1
	move.w	d1,-(sp)
	move.w	d0,-(sp)
	subq.w	#1,d6
	bne.s	Calcul_des_points	
	
Affichage:
	eori.w	#Save_size*4,(a5)
	adda.w	(a5)+,a5
	movea.l	(a5)+,a4
	movea.l	a5,a3
Cls:	move.l	(a3)+,d0
	beq.s	Ligne
	movea.l	d0,a2
	move.w	d6,(a2)
	bra.s	Cls
	
Ligne:
	move.l	a4,d5
	lsr.w	#8,d5
	move.l	d5,$ffff8200.w
	move.w	#Ligne_seq,d6
	
Tra‡age_de_la_ligne:
	bcs.s	Lbcl
	move.w	(sp)+,d0
	move.w	(sp)+,d1
Lbcl:	move.w	(sp)+,d2
	move.w	(sp)+,d3

Traces:
	movem.w	d0-3/d6,-(sp)
	move.l	d0,d4
	sub.w	d2,d4
	bpl.s	Traces_1
	neg.w	d4
	exg	d1,d3
	move.w	d2,d0
	
Traces_1:	move.w	#160,d6
	sub.w	d1,d3
	bpl.s	Traces_2
	neg.w	d3
	neg.w	d6
	
Traces_2	mulu.w	#160,d1
	move.l	a4,a0
	ror.l	#4,d0
	lsl.w	#3,d0
	add.w	d0,d1
	adda.w	d1,a0
	rol.l	#4,d0
	not.w	d0
	moveq	#0,d1
	bset	d0,d1
	swap	d1
	cmp.w	d4,d3
	bgt.s	Traces_suite_1
	
	move.w	d4,d2
	move.w	d4,d5
	lsr.w	#1,d2
	
Traces_3:	or.w	d1,(a0)
	move.l	a0,(a5)+
	rol.w	#1,d1
	bcc.s	Traces_4
	subq.l	#8,a0
	
Traces_4:	sub.w	d3,d2
	bgt.s	Traces_5
	adda.w	d6,a0
	add.w	d4,d2
	
Traces_5:	subq.w	#1,d5
	bgt.s	Traces_3
	
Traces_fin:	movem.w	(sp)+,d0-3/d6
	move.w	d3,d1
	move.w	d2,d0
	add.w	d6,d6
	bne.s	Tra‡age_de_la_ligne
	clr.l	(a5)
	rte
	
Traces_suite_1:
	move.w	d3,d2
	move.w	d3,d5
	lsr.w	#1,d2
Traces_suite_2:
	or.w	d1,(a0)
	move.l	a0,(a5)+
	adda.w	d6,a0
	sub.w	d4,d2
	bgt.s	Traces_suite_3
	add.w	d3,d2
	rol.w	#1,d1
	bcc.s	Traces_suite_3
	subq.l	#8,a0
Traces_suite_3:
	subq.w	#1,d5
	bpl.s	Traces_suite_2
	bra.s	Traces_fin
	
Debut_Coord:
	dc.b	-50,-20
	dc.b	-30,15
	dc.b	-20,-2
	dc.b	-20,15
	dc.b	15,15
	dc.b	25,5
	dc.b	30,15
	dc.b	40,15
	dc.b	20,-20
	dc.b	10,-20
	dc.b	20,-5
	dc.b	10,5
	dc.b	-10,5
	dc.b	-10,-10
	dc.b	5,-10
	dc.b	5,-20
	dc.b	-20,-20
	dc.b	-30,-3
	dc.b	-40,-20
	dc.b	-50,-20
Fin_coord:

SIN:	dc.b	128,128,127,126,125,123,122,119
	dc.b	117,117,111,108,105,101,097,093
	dc.b	088,084,079,074,068,063,058,052
	dc.b	046,040,034,028,022,016,009,003	



	
		