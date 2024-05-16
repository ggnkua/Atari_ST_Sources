letgo2		
	bsr	maxx2
	tst.w	d5
	bmi	.next
	bsr	prod_vect2
	tst.l	d5
	bmi	.next
	bsr	glok
	tst.w	d5
	bmi	.next
	bsr	remplir
.next	rts


maxx2	
	moveq	#-1,d5
	lea	ready,a2
	lea	rec_point,a0	
	move.w	(a1)+,d0
	move.w	(a1)+,d0	
	beq.s	.rt‚s
	moveq	#0,d5
	move.w	d0,nb
.re	move.w	(a1)+,d1
	move.l	(a0,d1.w*2),d2
	move.l	d2,(a2)+
	dbf	d0,.re
.rt‚s	rts

prod_vect2:	
	lea	ready,a0
	movem.w	(a0),d0-5
	sub.w	d2,d0
	sub.w	d3,d1
	sub.w	d2,d4
	sub.w	d3,d5
	muls	d0,d5
	muls	d1,d4
	sub.l	d4,d5
	bpl	.rt‚s	
	addq	#4,a0
	movem.w	(a0),d0-5
	sub.w	d2,d0
	sub.w	d3,d1
	sub.w	d2,d4
	sub.w	d3,d5
	muls	d0,d5
	muls	d1,d4
	sub.l	d4,d5
.rt‚s
	rts



fill_inter
	lea	tab_offset,a0
	lea	stock_obj,a1
	move	(a1)+,d0
	subq	#1,d0
	bmi	.noth
.re	
	move.w	(a2)+,color
	lea	stock_obj,a1
	move.w	(a0),d1
	addq	#4,a0
	add.w	d1,a1	

	movem.l	d0-a6,-(sp)
	bsr	letgo2
	movem.l	(sp)+,d0-a6
	dbf	d0,.re
.noth
	rts



objet_to_dsp
	move.w	(a6)+,d7
	subq	#1,d7
.re
	move.l	(a6)+,d1
	ext.l	d1
	move.l	(a6)+,a0
	bsr	send_objet
	dbf	d7,.re	
	rts


traite_objet
	moveq	#0,d7
	lea	2(a3),a4
	lea	52(a3),a6
	move.w	d7,(a3)
	move.w	d7,50(a3)
	move.w	(a5)+,d6
	subq	#1,d6
.re
	move.l	(a5)+,d7
	move.l	(a5)+,a1
	bsr	maxx2
	bsr	prod_vect		
	tst.l	d5
	bmi	.invisible
	move.l	d7,(a4)+
	addq.w	#1,(a3)
	dbf	d6,.re
	rts
.invisible
	move.l	d7,(a6)+
	addq.w	#1,50(a3)
	dbf	d6,.re
	rts

lance_gros_calcul
	move.w	(a0)+,d2
	move.w	(a1)+,d3
	move.w	d2,d4
	mulu	d3,d4
	
	moveq	#3,d0
	bsr	send
	move.w	d4,d0
	ext.l	d0
	bsr	send
	subq	#1,d2
	subq	#1,d3		
.re0
	move.l	(a1)+,d7
	ext.l	d7
	move.w	d2,d4	
	move.l	a0,a3
.re1
	move.w	(a3)+,(a6)+
	move.w	(a3)+,d6
	ext.l	d6
	move.l	d6,d0
	bsr	send
	move.l	d7,d0
	bsr	send
	dbf	d4,.re1
	dbf	d3,.re0
	rts

lance_gros_calcul_bidouille
	move.w	(a0)+,d2
	move.w	(a1)+,d3
	move.w	d2,d4
	mulu	d3,d4
	
	moveq	#3,d0
	bsr	send
	move.w	d4,d0
	ext.l	d0
	bsr	send
	subq	#1,d2
	subq	#1,d3		
.re0
	move.l	(a1)+,d7
	ext.l	d7
	move.w	d2,d4	
	move.l	a0,a3
.re1
	move.w	(a3)+,d5
	cmp.w	#1,d5
	bne.s	.bid1
	move.w	#20,(a6)+
	bra.s	.fin_bid
.bid1
	cmp.w	#2,d5
	bne.s	.bid2
	move.w	#21,(a6)+
	bra.s	.fin_bid
.bid2
	move.w	#22,(a6)+	
.fin_bid
	move.w	(a3)+,d6
	ext.l	d6
	move.l	d6,d0
	bsr	send
	move.l	d7,d0
	bsr	send
	dbf	d4,.re1
	dbf	d3,.re0
	rts


receive_coor

	bsr	send
	move.w	d1,d0
	ext.l	d1
	bsr	send	
	move.w	d2,d0
	ext.l	d2
	bsr	send
	move.w	d3,d0
	ext.l	d3
	bsr	send
	addq	#1,d1
	add.l	d4,d1
	lea	rec_point,a0
	lea	(a0,d1.w*2),a0
	bsr	rec
	move.w	d0,d7
	subq	#1,d7
	bmi.s	.nopoint	

	bsr	rec
	move.w	d0,(a5)
	move.w	d0,4(a5)
	move.w	d0,(a0)+

	bsr	rec
	move.w	d0,2(a5)
	move.w	d0,6(a5)
	move.w	d0,(a0)+

	bsr	rec
	move.w	d0,(a0)+
	subq	#1,d7
	bmi.s	.nopoint	

.re
	bsr	rec
	cmp.w	(a5),d0
	bgt.s	.ne1
	move.w	d0,(a5)
.ne1	cmp.w	4(a5),d0
	blt.s	.ne2
	move.w	d0,4(a5)
.ne2	move.w	d0,(a0)+
	
	bsr	rec
	cmp.w	2(a5),d0
	bgt.s	.ne3
	move.w	d0,2(a5)
.ne3	cmp.w	6(a5),d0
	blt.s	.ne4
	move.w	d0,6(a5)
.ne4	move.w	d0,(a0)+

	bsr	rec
	move.w	d0,(a0)+
	dbf	d7,.re				
.nopoint
	rts

receive_coor_bidouille

	bsr	send
	move.w	d1,d0
	ext.l	d1
	bsr	send	
	move.w	d2,d0
	ext.l	d2
	bsr	send
	move.w	d3,d0
	ext.l	d3
	bsr	send
	addq	#1,d1
	add.l	d4,d1
	lea	rec_point,a0
	lea	(a0,d1.w*2),a0
	bsr	rec
	move.w	d0,d7
	subq	#1,d7
	bmi.s	.nopoint	

.re
	bsr	rec
	cmp.w	(a5),d0
	bgt.s	.ne1
	move.w	d0,(a5)
.ne1	cmp.w	4(a5),d0
	blt.s	.ne2
	move.w	d0,4(a5)
.ne2	move.w	d0,(a0)+
	
	bsr	rec
	cmp.w	2(a5),d0
	bgt.s	.ne3
	move.w	d0,2(a5)
.ne3	cmp.w	6(a5),d0
	blt.s	.ne4
	move.w	d0,6(a5)
.ne4	move.w	d0,(a0)+

	bsr	rec
	move.w	d0,(a0)+
	dbf	d7,.re				
.nopoint
	rts


receive_coor_sup

	bsr	send
	move.w	d1,d0
	ext.l	d1
	bsr	send	
	move.w	d2,d0
	ext.l	d2
	bsr	send
	move.w	d3,d0
	ext.l	d3
	bsr	send
	addq	#1,d1
	add.l	d4,d1
	lea	rec_point,a0
	lea	(a0,d1.w*2),a0
	bsr	rec
	move.w	d0,d7
	subq	#1,d7
	bmi	.nopoint	
.re
	bsr	rec
	move.w	d0,(a0)+
	bsr	rec
	move.w	d0,(a0)+
	bsr	rec
	move.w	d0,(a0)+
	dbf	d7,.re				
.nopoint
	rts


send_coor
	; dans a0 les coordonnees
	; dans d1 l adresse de chargement
	moveq	#1,d0
	bsr	send
	move.w	(a0)+,d0
	ext.l	d0
	move.l	d0,d2
	bsr	send
	move.l	d1,d0
	bsr	send
	subq	#1,d2
.re	
	move.w	(a0)+,d0
	ext.l	d0
	bsr	send
	move.w	(a0)+,d0
	ext.l	d0
	bsr	send
	move.w	(a0)+,d0
	ext.l	d0
	bsr	send
	dbf	d2,.re
	rts

send_objet
	; dans a0 l'objet
	; dans d1 l adresse de chargement
	moveq	#2,d0
	bsr	send
	move.w	(a0)+,d0
	ext.l	d0	
	move.l	d0,d2
	bsr	send
	move.l	d1,d0
	ext.l	d0
	bsr	send	
	subq	#1,d2

.re	
	move.w	(a0)+,d0
	ext.l	d0
	move.l	d0,d3
	bsr	send
.re1
	move.w	(a0)+,d0
	ext.l	d0
	bsr	send
	dbf	d3,.re1

	dbf	d2,.re
	rts

lance_rotation
	moveq	#0,d0
	bsr	send
	lea	sinus,a1
	lea	cosinus,a2
	moveq	#2,d7
.re
	move.w	(a0),d0
	move.w	(a2,d0.w*2),d0
	ext.l	d0
	asl.l	#8,d0
	bsr	send
	move.w	(a0)+,d0
	move.w	(a1,d0.w*2),d0
	ext.l	d0
	asl.l	#8,d0
	bsr	send
	dbf	d7,.re

	move.l	d1,d0
	bsr	send
	move.l	d2,d0
	bsr	send
	move.l	d3,d0
	bsr	send
	move.l	d4,d0
	bsr	send
	rts

receive_obj
	moveq	#6,d0
	bsr	send

	bsr	rec
	move.w	d0,(a0)
	move.w	d0,d7
	subq	#1,d7
	bmi	.nothing
.re	bsr	rec
	move.l	d5,d3
	sub.l	a6,d3
	neg.l	d3
	move.w	d3,(a5)
	addq	#4,a5

	move.w	d4,(a6)+
	move.w	d0,(a6)+
	move.w	d0,d6
	beq.s	.vide
.re1	
	bsr	rec
	move.w	d0,(a6)+
	dbf	d6,.re1
.vide
	dbf	d7,.re
.nothing
	rts
