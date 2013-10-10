 	opt	d+
	jmp	main			
save_ints:
	move.b	$fffffa07.w,mfpa07	
	move.b	$fffffa09.w,mfpa09
	move.b	$fffffa13.w,mfpa13
	move.b	$fffffa15.w,mfpa15
	move.b	$fffffa19.w,mfpa19
	move.b	$fffffa1f.w,mfpa1f
	move.l	$134,old134
	move.l	$70.w,oldvbl
	move.b	$ff8201,save81
	move.b	$ff8203,save82

	move.w	#-1,-(sp)	
	move.w	#88,-(sp)	
	trap	#14
	addq.l	#4,sp
	move.w	d0,oldmode
	rts
init_ints:	
	move.w	#3,-(sp)	
	move.w	#%011100010,-(sp)
	move.l	physique,-(sp)	
	move.l	physique,-(sp)	
	move.w	#5,-(sp)
	trap	#14
	add.l	#14,sp

	move.w	#%001100010,-(sp)
	move.w	#88,-(sp)	
	trap	#14
	addq.l	#4,sp

	move.l	#div_0,$14.w
	clr.b	$fffffa09.w		
	clr.b	$fffffa15.w
	move.b	#0,$fffffa1f.w
	move.b	#0,$fffffa19.w
	move.b	#1,$fffffa07.w
	move.b	#34,$fffffa21.w
	move.b	#1,$fffffa13.w
	bclr	#3,$fffffa17.w
	move.b	#0,$fffffa1b.w
	move.l	#vbi,$70.w
	rts
ret_ints:	
	move.b	mfpa07,$fffffa07.w	
	move.b	mfpa09,$fffffa09.w
	move.b	mfpa13,$fffffa13.w
	move.b	mfpa15,$fffffa15.w
	move.b	mfpa19,$fffffa19.w
	move.b	mfpa1f,$fffffa1f.w
	move.l	old134,$134
	move.l	oldvbl,$70.w
	move.b	save81,$ff8201
	move.b	save82,$ff8203
	rts
save81:	dc.b	0
save82:	dc.b	0
mfpa07:	dc.b	0			
mfpa09:	dc.b	0
mfpa13:	dc.b	0
mfpa15:	dc.b	0
mfpa19:	dc.b	0
mfpa1f:	dc.b	0
old134:	dc.l	0
oldvbl:	dc.l	0
oldmode	dc.w	0
main:	pea	0			
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,save_stk
	move.l	usp,a0			
	move.l	a0,save_usp

	jsr	clr_screen
	jsr	save_ints		
	jsr	init_ints		
	movec	cacr,d0
	bset	#0,d0
	bclr	#1,d0
	bset	#8,d0
	bset	#4,d0
	bset	#12,d0
	movec	d0,cacr
	move.l	#0,$ffff9800.w
	move.l	#$e0e0e0e0,$ffff9804.w


demo_loop:
*****************************************************
	bsr	efface

*	move.l	#-1,$ffff9800.w
	bsr	INCREM
	lea	coor_dep(pc),a5
	bsr	calkul
*	move.l	#0,$ffff9800.w

	lea	face0(pc),a1
	bsr	letgo1
	lea	face1(pc),a1                  
	bsr	letgo1
	lea	face2(pc),a1
	bsr	letgo1
	lea	face3(pc),a1
	bsr	letgo1
	lea	face4(pc),a1
	bsr	letgo1
	lea	face5(pc),a1
	bsr	letgo1
	lea	face6(pc),a1
	bsr	letgo1
	lea	face7(pc),a1
	bsr	letgo1
	lea	face8(pc),a1
	bsr	letgo1
	lea	face9(pc),a1
	bsr	letgo1
	lea	face10(pc),a1                  
	bsr	letgo1
	lea	face11(pc),a1                  
	bsr	letgo1


*	move.l	#-1,$ffff9800.w
	bsr	swap
*	move.l	#$0,$ffff9800.w
	
	cmp.b	#185,$fffc02		
	beq	fin
	cmp.b	#187,$fffc02		
	bne	.next
	sub.w	#2,perspec
.next
	cmp.b	#188,$fffc02		
	bne	.next1
	add.w	#2,perspec
.next1
	move.l	wfnc,d0
.looop	cmp.l	wfnc,d0
	beq	.looop
	bra	demo_loop
*******************************************************
fin	
	jsr	ret_ints		
	move.l	save_usp,a0
	move.l	a0,usp
	move.l	save_stk,-(sp)		
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	oldmode,-(sp)	
	move.w	#88,-(sp)	
	trap	#14
	addq.l	#4,sp


	clr.w	(sp)			
	trap	#1

vbi:	
	add.w	#1,wfnc
	rte
coor_dep
	dc.w	80,0,0	
	dc.w	0,200,0	
	dc.w	80,150,0	
	dc.w	140,105,0	
	dc.w	100,80,0	
	dc.w	140,50,0	
	dc.w	140,0,0	
	dc.w	170,150,0	
	dc.w	170,0,0	
	dc.w	210,0,0	
	dc.w	250,100,0	
	dc.w	220,200,0	
	dc.w	280,140,0	
	dc.w	350,0,0	
	dc.w	350,60,0	
	dc.w	305,105,0	
	dc.w	340,200,0	
	dc.w	420,200,0	
	dc.w	480,140,0	
	dc.w	480,60,0	
	dc.w	420,0,0	
	dc.w	380,0,0	
	dc.w	380,60,0	
	dc.w	410,60,0	
	dc.w	430,80,0	
	dc.w	430,130,0	
	dc.w	410,150,0	
	dc.w	350,150,0	
	dc.w	-1	
face0	dc.w	4,0,4,5,6
face1	dc.w	4,0,1,2,4
face2	dc.w	3,4,2,3
face3	dc.w	4,2,1,11,7
face4	dc.w	5,8,7,11,10,9
face5	dc.w	4,10,11,14,13
face6	dc.w	4,10,16,27,15
face7	dc.w	4,27,16,17,26
face8	dc.w	4,26,17,18,25
face9	dc.w	4,24,25,18,19
face10	dc.w	4,20,23,24,19
face11	dc.w	4,21,22,23,20

swap:	move.l	logique,d0
	move.l	physique,d1
	move.l	d0,physique
	move.l	d1,logique
	move.l	d1,work
	
	move.w	d0,d1
	swap	d0
	move.b	d0,$ffff8201.w
	swap	d0
	lsr.w	#8,d0
	move.b	d0,$ffff8203.w
	move.b	d1,$ffff820d.w	
	rts

new_p	ds.l	100

maxx
	lea	ready(pc),a2	* adresse du buffer de point pour la face
	lea	new_p(pc),a0	* d0:nombre de points pour la face
	move.w	(a1)+,d0	
	move.w	d0,nb		 
	lea	(a2,d0.w*4),a3
	subq	#1,d0
.re	move.w	(a1)+,d7
	move.l	(a0,d7.w*4),d6
	move.l	d6,(a2)+
	move.l	d6,(a3)+
	dbf	d0,.re
	rts

tri	move.w	nb,d4	; nombre d'iterations pour trouver le y max
	subq	#2,d4	; et le y min

	moveq	#1,d6
	moveq	#0,d7
	moveq	#0,d5
	lea	ready+2(pc),a0
	move.w	(a0),d0
	move.w	d0,d2
	addq.l	#4,a0
.re_tri	move.w	(a0),d1
	cmp.w	d0,d1
	blt	.exg	
	move.w	d1,d0
	move.w	d6,d7
.exg	cmp.w	d2,d1
	bgt	.exg1
	move.w	d1,d2
	move.w	d6,d5
.exg1	addq	#1,d6		* dans d7 no du point le plus bas
	addq.l	#4,a0		* dans d5 no de point le plus haut
	dbf	d4,.re_tri



	cmp.w	d5,d7		; 
	bge	.a_l_envers
	add.w	nb,d7
.a_l_envers
	move.w	d7,d6
	sub.w	d5,d6
	move.w	d6,d1

	lea	ready(pc),a0
	lea	gauche,a1
	lea	(a0,d5.w*4),a0
.re_g	move.l	(a0)+,(a1)+
	dbf	d6,.re_g
	move.w	#$aaaa,(a1)

	move.w	nb,d0
	sub.w	d1,d0
	lea	(a0,d0.w*4),a0

	lea	droite,a1
.re_d	move.l	-(a0),(a1)+
	dbf	d0,.re_d
	move.w	#$aaaa,(a1)		
	rts


nb	dc.w	0
ready	ds.l	20
droite	ds.l	20
gauche	ds.l	20
droite_bis	ds.l	20
gauche_bis	ds.l	20
final_fight	ds.l	40

letgo1		
	bsr	maxx

	move.w	nb,d0		
	subq	#1,d0		
	lea	ready,a0					
.re_test
	tst.w	(a0)
	bpl.s	.inside
	addq	#4,a0
	dbf	d0,.re_test	
	bra.s	.next
.inside

	move.w	nb,d0		
	subq	#1,d0		
	lea	ready+2,a0					
.re_test1
	tst.w	(a0)
	bpl.s	.inside1
	addq	#4,a0
	dbf	d0,.re_test1	
	bra.s	.next
.inside1

	move.w	nb,d0		
	subq	#1,d0		
	lea	ready,a0					
.re_test2
	cmp.w	#384,(a0)
	blt.s	.inside2
	addq	#4,a0
	dbf	d0,.re_test2	
	bra.s	.next
.inside2

	move.w	nb,d0		
	subq	#1,d0		
	lea	ready+2,a0					
.re_test3
	cmp.w	#240,(a0)
	blt.s	.inside3
	addq	#4,a0
	dbf	d0,.re_test3	
	bra.s	.next
.inside3

*	bsr	prod_vect
*	bmi	.next
	bsr	tri

	bsr	no_problemo
	move.w	#$aaaa,(a2)
	bsr	remplir
.next	rts

no_problemo
	lea 	gauche,a0
	lea	gauche_bis,a2	
	bsr	glok
	move.l	#$aaaaaaaa,(a2)
	lea 	droite,a0
	lea	droite_bis,a2	
	bsr	glok
	move.l	#$aaaaaaaa,(a2)


	lea	droite_bis,a1
	lea	gauche_bis,a0	
	lea	final_fight,a2
	move.w	#-1,(a2)+
	move.l	(a0),(a2)+
	move.l	(a1),(a2)+
.bcl_principal
	move.w	4(a0),d0
	move.w	4(a1),d1

	cmp.w	d0,d1

	beq	.d_et_g
	bgt	.d

	move.w	d1,(a2)+
	sub.w	d1,d0
	move.w	d0,4(a0)
	addq.l	#6,a1

	cmp.l	#$aaaaaaaa,(a1)
	beq	.rt‚s
	move.w	#1,(a2)+
	move.l	(a1),(a2)+

	bra.s	.bcl_principal

.d	move.w	d0,(a2)+
	sub.w	d0,d1
	move.w	d1,4(a1)

	addq.l	#6,a0
	cmp.l	#$aaaaaaaa,(a0)
	beq	.rt‚s
	move.w	#0,(a2)+
	move.l	(a0),(a2)+

	bra.s	.bcl_principal

.d_et_g
	move.w	d0,(a2)+

	addq.l	#6,a0
	addq.l	#6,a1
	cmp.l	#$aaaaaaaa,(a0)
	beq	.rt‚s
	cmp.l	#$aaaaaaaa,(a1)
	beq	.rt‚s

	move.w	#-1,(a2)+
	move.l	(a0),(a2)+
	move.l	(a1),(a2)+
	bra	.bcl_principal
.rt‚s	rts

glok	
	moveq	#0,d3
	moveq	#0,d2
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.w	(a0),d2
	cmp.w	#$aaaa,d2
	beq	.rt‚s
	move.w	2(a0),d3
	sub.w	d1,d3		* delta y
	addq	#1,d3
	sub.w	d0,d2	
	swap	d2

	divs.l	d3,d2
	swap	d2		* inverse poids fort et poids faible pour les addx
	move.l	d2,(a2)+
	move.w	d3,(a2)+

	bra.s	glok
.rt‚s	rts

prod_vect:	
	lea	ready(pc),a0
	movem.w	(a0)+,d0-5
	sub.w	d2,d0
	sub.w	d3,d1
	sub.w	d2,d4
	sub.w	d3,d5
	muls	d0,d5
	muls	d1,d4
	sub.l	d4,d5
	
	move.w	d5,testeur
	sub.w	#1,d5
	move.w	d5,test
	rts

test	ds.w	1
testeur	ds.w	1

remplir	
	lea	droite,a6
	moveq	#0,d0
	moveq	#0,d5
	move.w	(a6)+,d0
	move.l	d0,d1
	move.w	(a6),d2

	move.l	work,a1
	move.l	#mul160,a5
	add.l	(a5,d2.w*4),a1
	


	lea	mega_tab,a4
	lea	mega_tab1,a2
	move.l	#-1,a0


	lea	final_fight,a5

isa	cmp.w	#$aaaa,(a5)
	beq	.rt‚s
	tst.w	(a5)+
	bmi	.iza
	beq	.belle

	swap	d3
	move.w	(a5)+,d3
	swap	d3

	swap	d0
	move.w	#$8000,d0
	swap	d0

	move.w	(a5)+,d4

	bra.s	.lance
.belle
	move.l	#$80000000,d5

	move.w	(a5)+,d3
	swap	d3
	move.l	d3,a3
	swap	d3
	move.w	(a5)+,d3

	bra.s	.lance
.iza	
	move.l	#$80000000,d5
	swap	d0
	move.w	#$8000,d0
	swap	d0


	moveq	#0,d3
	move.w	(a5)+,d3
	swap	d3
	move.l	d3,a3

	move.w	(a5)+,d3
	swap	d3	
	move.w	(a5)+,d3
	swap	d3

	move.w	(a5)+,d4
	
.lance	move.w	(a5)+,d2
	subq	#1,d2
 	bsr	re_lign
	bra.s	isa			
.rt‚s	rts

meme_mot
	swap	d6
	swap	d7
	and.w	d6,d7
	or.w	d7,(a6)
	lea	192(a1),a1
	dbf	d2,re_lign
	rts

bug	
	lea	192(a1),a1
	dbf	d2,re_lign
	rts


re_lign
	add.l	a3,d5
	addx.l	d3,d0
	addx.w	d4,d1

	move.l	(a4,d0.w*4),d6
	move.l	(a2,d1.w*4),d7

 	lea	(a1,d7.w*2),a6
	sub.w	d6,d7                               

	beq.s	meme_mot		
	bmi.s	bug

	neg.w	d7

	swap	d6
 	or.w	d6,(a6,d7.w*2)

	jmp	adr_fill_poly(pc,d7.w)

	move.w	a0,-192(a6)
	move.w	a0,-184(a6)
	move.w	a0,-176(a6)
	move.w	a0,-168(a6)
	move.w	a0,-160(a6)
	move.w	a0,-152(a6)
	move.w	a0,-144(a6)
	move.w	a0,-136(a6)
	move.w	a0,-128(a6)
	move.w	a0,-120(a6)
	move.w	a0,-112(a6)
	move.w	a0,-104(a6)
	move.w	a0,-96(a6)
	move.w	a0,-88(a6)
	move.w	a0,-80(a6)
	move.w	a0,-72(a6)
	move.w	a0,-64(a6)
	move.w	a0,-56(a6)
	move.w	a0,-48(a6)
	move.w	a0,-40(a6)
	move.w	a0,-32(a6)
	move.w	a0,-24(a6)
	move.w	a0,-16(a6)
	move.w	a0,-8(a6)
	swap	d7
	or.w	d7,(a6)
adr_fill_poly
	lea	192(a1),a1		
	dbf	d2,re_lign
	rts

************* routine d incremention *************
INCREM	
	movem.w	angle_rot(pc),d2-d4	
	LEA	ANGLEX(PC),A0
	MOVE.W	(A0),D0
	ADD	d2,D0
	MOVE.W	#359,D1
	SUB	D1,D0
	BPL	MAXI2
	ADD	D1,D0
MAXI2	MOVE.W	D0,(A0)	
	LEA	ANGLEY(PC),A0
	MOVE.W	(A0),D0
	ADD	d3,D0
	MOVE.W	#359,D1
	SUB	D1,D0
	BPL	MAXI3
	ADD	D1,D0
MAXI3	MOVE.W	D0,(A0)	
	LEA	ANGLEZ(PC),A0
	MOVE.W	(A0),D0
	ADD	d4,D0
	MOVE.W	#359,D1
	SUB	D1,D0
	BPL	MAXI4
	ADD	D1,D0
MAXI4	MOVE.W	D0,(A0)	
	RTS
******** routine de transformation 3D autour des 3 axes **********
X1	dc.w	0
Y1	DC.W	0
Z1	DC.W	0
ANGLEX	DC.W	0                                             
ANGLEY	DC.W	0
ANGLEZ	DC.W	0
SINX	DC.W	0
COSX	DC.W	0
SINY	DC.W	0
COSY	DC.W	0
SINZ	DC.W	0
COSZ	DC.W	0
angle_rot	dc.w	3,0,0
perspec		dc.w	200,150,300                                                    
dec_x		dc.w	175
dec_y		dc.w	99
traject		dc.w	50
CALCUL	
	MOVEM.W	X1,D0-D5	
	SUB.W	#239,D0
	SUB.W	#99,D1
	ADD.W	D3,D3
	ADD.W	D4,D4
	ADD.W	D5,D5
	LEA	SINUS,A0
	LEA	SINX(PC),A1
	LEA	SINY(PC),A3
	LEA	SINZ(PC),A4
	MOVE.W	(A0,D3.W),(A1)
	MOVE.W	(A0,D4.W),$4(A1)
	MOVE.W	(A0,D5.W),$8(A1)
	LEA	COSINUS,A0
	LEA	COSX(PC),A2
	MOVE.W	(A0,D3.W),(A2)
	MOVE.W	(A0,D4.W),$4(A2)
	MOVE.W	(A0,D5.W),$8(A2)
	MOVEM.W	(A1),D3-D4	
       	MULS	D0,D4		
	NEG	D3	
	MULS	D1,D3
	ADD.L	D3,D4
	ADD.L	D4,D4
	SWAP	D4		* cos a*x-sin a*y= X=d4
	MOVEM.W	(A1),D5-D6	
       	MULS	D0,D5
	MULS	D1,D6
	ADD.L	D6,D5
	ADD.L	D5,D5
	SWAP	D5		* sin a*x+cos a*y= Y=d5
	MOVEM.W	(A3),D0-D1	* z= Z=d2
	MULS	D4,D1
	MULS	D2,D0
	ADD.L	D1,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVEM.W	(A3),D6-D7	* cos b*X+sin b*Z=X' =d0 
	NEG	D6		
	MULS	D4,D6		
	MULS	D2,D7		
	ADD.L	D6,D7		
	ADD.L	D7,D7		
	SWAP 	D7		
	MOVEM.W	(A4),D1-D2	* cos b*Z-sin b*X=Z' =d7  
	MULS	D5,D2 		* Y= Y'=D5
	NEG	D1
	MULS	D7,D1
	ADD.L	D2,D1
	ADD.L	D1,D1
	SWAP 	D1		* cos c*Y'-sin c*Z'= YY''=D1
**********
	MOVEM.W	(A4),D2-D3	
	MULS	D5,D2 		
	MULS	D7,D3
	ADD.L	D3,D2
	ADD.L	D2,D2		 
	SWAP 	D2		*	XX''=D0    ZZ''=D2
**********	
	movem.w	perspec(pc),d3-d5
	move.w	(a4),d7
	muls	d4,d7
	add.l	d7,d7
	swap	d7
	add.w	d7,d3

	sub	d5,d2
	neg	d2
	muls	d3,d0	
	muls	d3,d1	
	DIVS	D2,D0
	DIVS	D2,D1
**********
	move.w	traject,d7
	move.w	(a1),d6
	muls	d7,d6
	add.l	d6,d6
	swap	d6
	add.w	d6,d0
	ADD.W	dec_x,D0
	ADD.W	dec_y,D1
	MOVE.W	D0,X1
	MOVE.W	D1,Y1
	RTS	
*****************************************
					*
efface	
	move.w	#8,$ff8a2e
	move.w	#1,$ff8a30

 
	move.l	work,d0
	move.w	d0,$ff8a34
	swap	d0
	move.w	d0,$ff8a32
	
	move.w	#24*240,$ff8a36	* taille horizontale
	move.w	#1,$ff8a38	* taille verticale

	move.b	#2,$ff8a3a	* pas operation avec ram demi teinte
	move.b	#0,$ff8a3b	* nouvelle destination : source
	
	move.b	#128+64,$ff8a3c
	nop
	rts				*
*****************************************
calkul	
	lea	new_p(pc),a6	*
isb	move.w	(a5)+,X1	*
	bmi	plop		*
	move.w	(a5)+,Y1	*
	move.w	(a5)+,Z1	*
	bsr	CALCUL		*
	move.w	d0,(a6)+	*
	move.w	d1,(a6)+	*
	bra.s	isb		*
plop	rts			*
*********************************
clr_screen
	move.l	logique,a0
	move.l	physique,a1
	move.w	#11519,d0
re	clr.l	(a0)+
	clr.l	(a1)+
	dbf	d0,re
	rts
*********************************
div_0	rte
																																
SINUS		incbin	e:\oula\3d_1plan\sinus.tab
		EVEN
COSINUS		EQU	SINUS+$B4


COMPT	SET	-1000*192
	REPT	999
	DC.l	COMPT
COMPT	SET	COMPT+192
	ENDR

COMPT	SET	0
mul160	REPT	1350
	DC.l	COMPT
COMPT	SET	COMPT+192
	ENDR

	rept	4*24*16
	dc.w	$ffff
	dc.w	0
	endr
mega_tab
ouaip	set	0
	rept	24                  
	dc.w	%1111111111111111
	dc.w	ouaip
	dc.w	%111111111111111
	dc.w	ouaip
	dc.w	%11111111111111
	dc.w	ouaip
	dc.w	%1111111111111
	dc.w	ouaip
	dc.w	%111111111111
	dc.w	ouaip
	dc.w	%11111111111
	dc.w	ouaip
	dc.w	%1111111111
	dc.w	ouaip
	dc.w	%111111111
	dc.w	ouaip
	dc.w	%11111111
	dc.w	ouaip
	dc.w	%1111111
	dc.w	ouaip
	dc.w	%111111
	dc.w	ouaip
	dc.w	%11111
	dc.w	ouaip
	dc.w	%1111
	dc.w	ouaip
	dc.w	%111
	dc.w	ouaip
	dc.w	%11
	dc.w	ouaip
	dc.w	%1
	dc.w	ouaip
ouaip	set	ouaip+4
	endr

	rept	4*24*16
	dc.w	$0
	dc.w	96
	endr

	rept	4*24*16
	dc.w	$0
	dc.w	0
	endr

mega_tab1
plomp	set	0
	rept	24
	dc.w	%1000000000000000
	dc.w	plomp
	dc.w	%1100000000000000
	dc.w	plomp
	dc.w	%1110000000000000
	dc.w	plomp
	dc.w	%1111000000000000
	dc.w	plomp
	dc.w	%1111100000000000
	dc.w	plomp
	dc.w	%1111110000000000
	dc.w	plomp
	dc.w	%1111111000000000
	dc.w	plomp
	dc.w	%1111111100000000
	dc.w	plomp
	dc.w	%1111111110000000
	dc.w	plomp
	dc.w	%1111111111000000
	dc.w	plomp
	dc.w	%1111111111100000
	dc.w	plomp
	dc.w	%1111111111110000
	dc.w	plomp
	dc.w	%1111111111111000
	dc.w	plomp
	dc.w	%1111111111111100
	dc.w	plomp
	dc.w	%1111111111111110
	dc.w	plomp
	dc.w	%1111111111111111
	dc.w	plomp
plomp	set	plomp+4
	endr
	rept	4*24*16
	dc.w	$0
	dc.w	96            
	endr

work		dc.l	$3b0000
logique		dc.l	$3b0000
physique	dc.l	$3d0000
save_usp:	dc.l	0
wfnc:		dc.w	0
save_stk:	dc.l	0
	section bss
	end

