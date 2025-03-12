	opt	d+

	include d:\nop\include\vector.mcr
	include	d:\nop\include\dsp.mcr
		
	pea	0			
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,save_stk
	move.l	usp,a0			
	move.l	a0,save_usp

	Dsp_lock
	Dsp_flushsubroutines
	Dsp_execprog dsp,dsp_size,3

send	btst	#1,$ffffa202.w
	beq.s	send	
	move.l	#$7fffff,d7
	moveq	#1,d6
	move.w	#255,d0
send2	move.l	d7,d5
	divu.l	d6,d5
	addq	#1,d6
	move.l	d5,$ffffa204.w
	dbf	d0,send2	



send3	btst	#1,$ffffa202.w
	beq.s	send3
	move.l	#96-1,$ffffa204.w	


send4	btst	#1,$ffffa202.w
	beq.s	send4

	lea	img1,a0
	move.w	#96-1,d0
re_l_img
	move.w	#96-1,d1
re_l_img1
	btst	#1,$ffffa202.w
	beq.s	re_l_img1
	moveq	#0,d2
	move.b	(a0)+,d2
	lsl.w	#4,d2
	move.w	d2,$ffffa206.w

	dbf	d1,re_l_img1
	add.l	#320-96,a0
	dbf	d0,re_l_img

	lea	palette,a0
	move.l	#$1ff,d5	
.send	btst	#1,$ffffa202.w
	beq.s	.send
	move.w	(a0)+,$ffffa206.w
	dbf	d5,.send

	bsr	prepare_mode

	move.w	#%01100100,-(sp)
	move.w	#3,-(sp)
	move.l	logique,-(sp)
	move.l	logique,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#14,sp

;	move.w	#$55,$ffff82a8	*
;	move.w	#$235,$ffff82aa	* fullscreen haut et bas
	
	move.l	logique,a0
	bsr	clear_scr
	move.l	physique,a0
	bsr	clear_scr
	bsr	affiche_img	

	lea	vect,a0
	save_vecteur a0
	clear_vecteur
	movec 	cacr,d0
	move.w	d0,save_cache
	bset	#0,d0	
	bset	#8,d0	
	movec	d0,cacr
	move.l	#0,$ffff9800
	move.w	#0,compte_eff
	bsr	init_effacement
	move.w	#1,compte_eff
	bsr	init_effacement
	move.w	#0,compte_eff

	move.w	#10,para1

	vbl	vbi
	jmp	start
demo_loop:
*****************************************************
;	move.l	#0,$ffff9800.w
	move.w	#0,flag_vbl
	bsr	interpole
	bsr	init_effacement
	bsr	increm
	bsr	calkul
	bsr	calkul_projection
	bsr	calckul_col
	lea	face,a1
	bsr	mapp_face
	lea	face1,a1
	bsr	mapp_face
	lea	face2,a1
	bsr	mapp_face
	lea	face3,a1
	bsr	mapp_face
	lea	face4,a1
	bsr	mapp_face
	lea	face5,a1
	bsr	mapp_face

	bsr	efface_bord

	move.w	wait_fin,d0
	tst.w	d0
	bpl.s	.gloubi
	move.l	#buffer_vide,adr_buffer
	clr.w	incremente_obj
	sub.w	#1,wait_fin2
	bpl.s	.gloubi	
	move.w	#2,decremente_obj
.gloubi
	sub.w	#1,wait_fin

	move.w	para1,d0
	cmp.w	#350,d0	;490
	bge.s	.grossissement_fini
	move.w	incremente_obj,d0
	add.w	d0,para1
.grossissement_fini

	move.w	decremente_obj,d0
	sub.w	d0,para1
	move.w	para1,d0
	cmp.w	#10,d0
	ble	fin	

	bsr	swap
;	move.l	#-1,$ffff9800.w

**************************************************
	cmp.b	#185,$fffc02	
	beq	fin		
start
	move.w	flag_vbl,d0
	cmp.w	#2,d0
	blt	start
	
	bra	demo_loop	

fin	
	move.w	save_cache,d0
	movec	d0,cacr
	lea	vect,a0
	load_vecteur a0		
	move.l	save_usp,a0
	move.l	a0,usp
	move.l	save_stk,-(sp)		
       	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	bsr	restore_mode

      	Dsp_unlock	

	clr.w	(sp)			
	trap	#1

flag_vbl	dc.w	0

coor_dep	
	dc.w	80,20,80
	dc.w	80,180,80	
	dc.w	240,180,80
	dc.w	240,20,80

	dc.w	80,20,-80
	dc.w	80,180,-80	
	dc.w	240,180,-80
	dc.w	240,20,-80
	dc.w	-1

coor_dep_dep	
	dc.w	100,40,60
	dc.w	100,160,60	
	dc.w	220,160,60
	dc.w	220,40,60

	dc.w	100,40,-60
	dc.w	100,160,-60	
	dc.w	220,160,-60
	dc.w	220,40,-60
	dc.w	-1

coor_dep_dep_dep	
	dc.w	100,40,60
	dc.w	100,160,60	
	dc.w	220,160,60
	dc.w	220,40,60

	dc.w	100,40,-60
	dc.w	100,160,-60	
	dc.w	220,160,-60
	dc.w	220,40,-60
	dc.w	-1


coor_pro	
	dc.w	160,100,0+127		; devant
	dc.w	160-127,100,0		; gauche
	dc.w	160,100+127,0		; dessous
	dc.w	160+127,100,0		; droite
	dc.w	160,100-127,0		; dessus
	dc.w	160,100,0-127		; derriere
	dc.w	-1

table_col_sommet
	dc.w	0,1,4
	dc.w	0,1,2
	dc.w	0,2,3
	dc.w	0,4,3

	dc.w	5,1,4
	dc.w	5,1,2
	dc.w	5,2,3
	dc.w	5,4,3
	
face	dc.w	0,1,2,3
face1	dc.w	0,4,5,1
face2	dc.w	5,6,2,1
face3	dc.w	2,6,7,3
face4	dc.w	0,3,7,4
face5	dc.w	7,6,5,4

vbi:	
	add.w	#1,flag_vbl
	rte

swap	
	move.l	logique,d0
	move.l	physique,d1
	exg	d0,d1
	move.l	d0,logique
	move.l	d1,physique
	move.l	d1,work
	bsr	adrscr
	rts
	

adrscr				; d0=adresse d1=decalage d2=saut
	move.b	d0,$ff820d
	lsr.l	#8,d0
	move.b	d0,$ff8203
	lsr.l	#8,d0
	move.b	d0,$ff8201
	rts

prepare_mode
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,physbase
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,logbase
	move.w	#-1,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp
	move.w	d0,mode
	rts

restore_mode
	move.w	mode,-(sp)
	move.w	#3,-(sp)
	move.l	physbase,-(sp)
	move.l	logbase,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#14,sp

	rts

mapp_face
	bsr	maxx
	bsr	prod_vect
	tst.w	d5
	bmi	.no_poly

	lea	ready,a0
	move.w	2(a0),d7
	move.w	2(a0),d5
	move.w	#2,d6
.repm
	cmp.w	6(a0),d7
	bgt	.next1
	move.w	6(a0),d7
.next1
	cmp.w	6(a0),d5
	blt	.next2
	move.w	6(a0),d5
.next2
	addq	#4,a0
	dbf	d6,.repm

.send6	btst	#1,$ffffa202.w
	beq.s	.send6
	
	lea	ready,a0
	move.w	(a0)+,$ffffa206.w
.send3	btst	#1,$ffffa202.w
	beq.s	.send3
	move.w	(a0)+,$ffffa206.w
.send4	btst	#1,$ffffa202.w
	beq.s	.send4
	move.w	(a0)+,$ffffa206.w
.send7	btst	#1,$ffffa202.w
	beq.s	.send7
	move.w	(a0)+,$ffffa206.w
.send8	btst	#1,$ffffa202.w
	beq.s	.send8
	move.w	(a0)+,$ffffa206.w
.send9	btst	#1,$ffffa202.w
	beq.s	.send9
	move.w	(a0)+,$ffffa206.w
.send11	btst	#1,$ffffa202.w
	beq.s	.send11
	move.w	(a0)+,$ffffa206.w
.send12	btst	#1,$ffffa202.w
	beq.s	.send12
	move.w	(a0)+,$ffffa206.w
	lea	ready,a0
.send13	btst	#1,$ffffa202.w
	beq.s	.send13
	move.w	(a0)+,$ffffa206.w
.send14	btst	#1,$ffffa202.w
	beq.s	.send14
	move.w	(a0)+,$ffffa206.w

.send15	btst	#1,$ffffa202.w
	beq.s	.send15
	move.w	d5,$ffffa206.w
	sub.w	d5,d7
.send16	btst	#1,$ffffa202.w
	beq.s	.send16
	move.w	d7,$ffffa206.w

	lea	ready_col,a0
.senda3	btst	#1,$ffffa202.w
	beq.s	.senda3
	move.w	(a0)+,$ffffa206.w
.senda4	btst	#1,$ffffa202.w
	beq.s	.senda4
	move.w	(a0)+,$ffffa206.w
.senda5	btst	#1,$ffffa202.w
	beq.s	.senda5
	move.w	(a0)+,$ffffa206.w
.sendb5	btst	#1,$ffffa202.w
	beq.s	.sendb5
	move.w	(a0)+,$ffffa206.w
	lea	ready_col,a0
.sendb3	btst	#1,$ffffa202.w
	beq.s	.sendb3
	move.w	(a0)+,$ffffa206.w

	move.w	compte_eff,d0
	lea	adr_buff_eff,a6
	move.l	(a6,d0.w*8),a6	
	lea	(a6,d5.w*4),a6


	move.l	work,a0
	ext.l	d5
	mulu.l	#768,d5
	add.l	d5,a0
	subq	#1,d7
.re_mapp
	btst	#0,$ffffa202.w
	beq.s	.re_mapp
	move.w	$ffffa206.w,d0

	cmp.w	(a6),d0
	bgt.s	.plus_grande1
	move.w	d0,(a6)
.plus_grande1

.re_mapp1
	btst	#0,$ffffa202.w
	beq.s	.re_mapp1
	move.w	$ffffa206.w,d1
	bmi	.bug
	lea	(a0,d0.w*2),a2

	add.w	d1,d0
	cmp.w	2(a6),d0
	blt.s	.plus_petite1
	move.w	d0,2(a6)
.plus_petite1


.re_mapp2
	btst	#0,$ffffa202.w
	beq.s	.re_mapp2
.re_fill
	move.w	$ffffa206.w,(a2)+
	dc.w	$4e71
	dbf	d1,.re_fill
.bug
	lea	768(a0),a0
	addq	#4,a6
	dbf	d7,.re_mapp
.no_poly		
	rts


maxx	lea	new_p(pc),a0
	lea	ready(pc),a2
	lea	new_col(pc),a6
	lea	ready_col(pc),a5
	rept	4
	move.w	(a1)+,d0
	move.l	(a0,d0.w*4),(a2)+	
	move.w	(a6,d0.w*2),(a5)+
	endr
	rts
ready_col
	ds.w	4
new_p	ds.w	100
new_pro	ds.w	10
new_col	ds.w	10
ready	ds.w	16

calckul_col
	lea	table_col_sommet,a0
	lea	new_pro,a1
	lea	new_col,a2
	moveq	#7,d7
.re	moveq	#0,d1
	moveq	#2,d6
.re1	move.w	(a0)+,d0
	move.w	(a1,d0.w*2),d0
	add.w	d0,d1
*.pas_re
	dbf	d6,.re1
	tst.w	d1
	bpl	.posi
	moveq	#0,d1
.posi
	divu	#14,d1
	move.w	d1,(a2)+
	dbf	d7,.re
	rts

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
	sub.w	#10,d5
	bpl.s	.rt‚s
	lea	ready+4(pc),a0
	movem.w	(a0)+,d0-5
	sub.w	d2,d0
	sub.w	d3,d1
	sub.w	d2,d4
	sub.w	d3,d5
	muls	d0,d5
	muls	d1,d4
	sub.l	d4,d5
	sub.w	#10,d5
	bpl.s	.rt‚s
	lea	ready+8(pc),a0
	movem.w	(a0)+,d0-3
	lea	ready(pc),a0
	movem.w	(a0)+,d4-5
	sub.w	d2,d0
	sub.w	d3,d1
	sub.w	d2,d4
	sub.w	d3,d5
	muls	d0,d5
	muls	d1,d4
	sub.l	d4,d5
	sub.w	#10,d5
	bpl.s	.rt‚s
	lea	ready+12(pc),a0
	movem.w	(a0)+,d0-1
	lea	ready(pc),a0
	movem.w	(a0)+,d2-5
	sub.w	d2,d0
	sub.w	d3,d1
	sub.w	d2,d4
	sub.w	d3,d5
	muls	d0,d5
	muls	d1,d4
	sub.l	d4,d5
	sub.w	#10,d5

.rt‚s
	rts


calkul	lea	new_p(pc),a6	
	lea	coor_dep_dep_dep(pc),a5	
.isb	move.w	(a5)+,X1	
	bmi	.plop		
	move.w	(a5)+,Y1	
	move.w	(a5)+,Z1	
	bsr	CALCUL		
	bsr	projection
	move.w	d0,(a6)+	
	move.w	d1,(a6)+	
	bra.s	.isb		
.plop	rts			

calkul_projection
	lea	new_pro(pc),a6	
	lea	coor_pro(pc),a5	
.isb	move.w	(a5)+,X1	
	bmi	.plop		
	move.w	(a5)+,Y1	
	move.w	(a5)+,Z1	
	bsr	CALCUL		
	move.w	d2,(a6)+	
	bra.s	.isb		
.plop	rts			

init_effacement
	move.w	compte_eff,d0
	lea	adr_buff_eff,a0
	move.l	(a0,d0.w*8),a0	
	move.l	#$7000ffff,d1
	move.w	#49,d7
.re	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbf	d7,.re
	rts	

efface_bord
	move.l	adr_buffer,a4
	move.w	compte_eff,d0
	lea	adr_buff_eff,a0
	lea	(a0,d0.w*8),a0
	move.l	(a0)+,a1	
	move.l	(a0)+,a2
	addq	#1,d0
	and.w	#1,d0
	move.w	d0,compte_eff	
	move.l	a2,d3
	move.l	a2,d0
	addq	#2,a2
	add.l	#1000,d3
	move.l	physique,a6
	move.l	logique,a0
.testa2
	tst.w	(a2)
	bpl.s	.ca_commence
	add.l	#768,a6
	add.l	#768,a0
	add.l	#768,a4
	addq.l	#4,a2
	cmp.l	a2,d3
	bgt.s	.testa2
	rts
.ca_commence
	subq	#2,a2
	move.l	a2,d1
	sub.l	d0,d1
	add.l	d1,a1
	moveq	#0,d7
.enkor_une_toute_petite_ligne
	move.l	a0,-(sp)
	movem.w	(a2)+,d0-d1
	movem.w	(a1)+,d2-d3
	tst.w	d3
	bmi.s	.efface_a2
	sub.w	d0,d2
	bmi.s	.no_eff1
	beq.s	.no_eff1
	lea	(a6,d0.w*2),a5
	lea	(a4,d0.w*2),a3
	lea	(a0,d0.w*2),a0
	subq	#1,d2
.re_eff1
	move.w	(a3)+,d4
	move.w	d4,(a5)+
	move.w	d4,(a0)+
	dbf	d2,.re_eff1

.no_eff1
	sub.w	d3,d1
	bmi.s	.no_eff2
	beq.s	.no_eff2
	subq	#1,d1
	lea	2(a6,d3.w*2),a5
	lea	2(a4,d3.w*2),a3
	move.l	(sp),a0
	lea	2(a0,d3.w*2),a0
.re_eff2
	move.w	(a3)+,d4
	move.w	d4,(a5)+
	move.w	d4,(a0)+
	dbf	d1,.re_eff2
.no_eff2
	move.l	(sp)+,a0
	lea	768(a0),a0
	lea	768(a6),a6
	lea	768(a4),a4
	tst.w	2(a2)
	bpl.s	.enkor_une_toute_petite_ligne			
	rts	

.efface_a2
	sub.w	d0,d1
	bmi.s	.bugg
	lea	(a6,d0.w*2),a5
	lea	(a4,d0.w*2),a3
	lea	(a0,d0.w*2),a0
.re_eff3
	move.w	(a3)+,d4
	move.w	d4,(a5)+
	move.w	d4,(a0)+
	dbf	d1,.re_eff3
.bugg
	move.l	(sp)+,a0
	lea	768(a0),a0
	lea	768(a4),a4
	lea	768(a6),a6
	tst.w	2(a2)
	bpl	.enkor_une_toute_petite_ligne			
	rts	

no_interpole		dc.w	0				
position_interpole	dc.w	0
interpole
	move.w	para1,d0
	cmp.w	#350,d0	
	blt	.rt‚s
	move.w	position_interpole,d0
	cmp.w	#64,d0
	beq.s	.change_inter
	lea	coor_dep,a0
	lea	coor_dep_dep,a1
	lea	coor_dep_dep_dep,a2
	move.w	no_interpole,d0
	mulu	#6,d0
	add.w	d0,a0			
	add.w	d0,a1			
	add.w	d0,a2
	movem.w	(a0),d0-d2			
	movem.w	(a1),d3-d5
	sub.w	d3,d0
	sub.w	d4,d1
	sub.w	d5,d2
	move.w	position_interpole,d7
	muls	d7,d0
	muls	d7,d1
	muls	d7,d2
	divs	#64,d0	
	divs	#64,d1	
	divs	#64,d2
	add.w	d0,d3		
	add.w	d1,d4		
	add.w	d2,d5		
	movem.w	d3-d5,(a2)
	add	#1,position_interpole
	rts			
				
.change_inter
	move.w	no_interpole,d0
	cmp.w	#7,d0
	beq.w	.rt‚s
	move.w	#0,position_interpole
	add.w	#1,no_interpole
.rt‚s
	rts
******** routine de transformation 3D autour des 3 axes **********
angle_rot	dc.w	3,2,1
X1	dc.w	0
Y1	DC.W	0
Z1	DC.W	0
ANGLEX	DC.W	72
ANGLEY	DC.W	56
ANGLEZ	DC.W	56
SINX	DC.W	0
COSX	DC.W	0
SINY	DC.W	0
COSY	DC.W	0
SINZ	DC.W	0
COSZ	DC.W	0
CALCUL	
	MOVEM.W	X1,D0-D5	
	SUB.W	#159,D0
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
	move.w	2(a3),d5
	muls	#90,d5	;66
	add.l	d5,d5
	swap	d5
	add.w	d5,d0
	move.w	2(a1),d5
	muls	#20,d5	;20
	add.l	d5,d5
	swap	d5
	add.w	d5,d1
	rts

projection
	move.w	para1,d5
	sub	para3,d2
	neg	d2
	muls	d5,d0	
	muls	d5,d1	
	DIVS	D2,D0
	DIVS	D2,D1
**********
	ADD.W	#192,D0
	ADD.W	#120,D1
	MOVE.W	D0,X1
	MOVE.W	D1,Y1
	RTs
************* routine d incremention *************
increm
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


clear_scr
	move.w	#240*48-1,d0
	moveq	#0,d7
.re
	move.l	d7,(a0)+
	move.l	d7,(a0)+
	move.l	d7,(a0)+
	move.l	d7,(a0)+
	dbf	d0,.re
	rts

affiche_img
	lea	buffer_texte+768*20,a0
	lea	logo,a1
	move.w	#200-1,d0
.re2
	move.w	#160-1,d1	
	add.l	#64,a0	
.re
	move.l	(a1)+,(a0)+
	dbf	d1,.re
	add.l	#64,a0
	dbf	d0,.re2	
	rts

para1		dc.w	490
para2		dc.w	135
para3		dc.w	500
para4		dc.w	30
logo		incbin	e:\logo_eko.dat
		even
img1		incbin	d:\nop\incbin\gour_im1.dat
		even
palette		incbin	d:\nop\incbin\gour_pa8.dat
		even
SINUS 		incbin	d:\nop\incbin\sinus.tab
		even
COSINUS		equ	SINUS+$B4
dsp		incbin	d:\texture\gouraud2.p56
dsp_size	equ	(*-dsp)/3
		even
adr_buff_eff	dc.l	buff_eff1,buff_eff3
		dc.l	buff_eff3,buff_eff1
adr_buffer	dc.l	buffer_texte
incremente_obj	dc.w	3
decremente_obj	dc.w	0
wait_fin	dc.w	30*25
wait_fin2	dc.w	190
work		dc.l	$300000
physique	dc.l	$300000
logique		dc.l	$280000
save_usp:	dc.l	0
save_stk:	dc.l	0

		section bss
save_cache	ds.w	1
adr_img		ds.l	1
logbase		ds.l	1
physbase	ds.l	1
mode		ds.l	1
vect		ds.l	20
compte_eff	ds.w	1
buff_eff1	ds.l	250
buff_eff3	ds.l	250
buffer_texte	ds.b	200000
buffer_vide	ds.b	200000
