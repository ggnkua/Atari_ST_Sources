preparation_z1
	move.l	logique,a6
	jsr	clear_384_240
	move.l	physique,a6
	jsr	clear_384_240

	lea	palette_z1,a0
	jsr	put_palette

	lea	coor_0,a0
	move.l	#$400,d1
	bsr	send_coor
	lea	coor_1,a0
	move.l	#$500,d1
	bsr	send_coor

	lea	def_obj0,a6
	bsr	objet_to_dsp
	lea	def_obj1,a6
	bsr	objet_to_dsp
	rts

execute_z1

	move.l	adr_eff,a0
	lea	eff_bug,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	movem.w	crb1,d0-d3
	add.w	d1,d0
	add.w	d3,d2
	move.w	d0,crb1
	move.w	d2,crb2

	lea	rotation0,a0
	bsr	increm
	lea	rotation1,a0
	bsr	increm

	lea	rotation0,a0
	move.l	#$400,d1
	move.l	#$400,d2
	move.w	crb1,d3
	ext.l	d3
	move.l	d3,d4
	bsr	lance_rotation

	lea	rotation1,a0
	move.l	#$500,d1
	move.l	#$500,d2
	move.w	crb2,d3
	ext.l	d3
	move.l	d3,d4
	bsr	lance_rotation

	move.l	adr_eff,a5
	moveq	#4,d0
	move.w	#$400,d1
	move.w	#350,d2
	move.w	#700,d3
	moveq	#0,d4
	bsr	receive_coor

	move.l	adr_eff+4,a5
	moveq	#4,d0
	move.w	#$500,d1
	move.w	#350,d2
	move.w	#700,d3
	moveq	#0,d4
	bsr	receive_coor

	lea	def_obj0,a5
	lea	visible_obj0,a3
	bsr	traite_objet

	lea	def_obj1,a5
	lea	visible_obj1,a3
	bsr	traite_objet

	moveq	#7,d0
	bsr	send

	lea	serie_color,a6
	lea	visible_obj0,a0
	lea	visible_obj1+50,a1
	bsr	lance_gros_calcul	

	lea	eff_bug,a0
	bsr	efface_objet
	lea	eff_bug+8,a0
	bsr	efface_objet
	bsr	ech_adr

	lea	stock_obj,a0
	lea	tab_offset,a5
	move.l	#stock_obj,d5
	lea	stock_obj+2,a6
	bsr	receive_obj

	moveq	#5,d0
	move.w	#$e00,d1
	move.w	#350,d2
	move.w	#700,d3
	moveq	#1,d4
	bsr	receive_coor_sup

	lea	serie_color,a6
	lea	visible_obj0,a0
	lea	visible_obj1,a1
	bsr	lance_gros_calcul	

	lea	serie_color,a2
	bsr	fill_inter	

	move.w	#4,color
	lea	face0,a1
	bsr	letgo2
	move.w	#4,color
	lea	face1,a1
	bsr	letgo2
	move.w	#8,color
	lea	face2,a1
	bsr	letgo2
	move.w	#8,color
	lea	face3,a1
	bsr	letgo2
	move.w	#12,color
	lea	face4,a1
	bsr	letgo2
	move.w	#12,color
	lea	face5,a1
	bsr	letgo2

	lea	stock_obj,a0
	lea	tab_offset,a5
	move.l	#stock_obj,d5
	lea	stock_obj+2,a6
	bsr	receive_obj

	moveq	#5,d0
	move.w	#$e00,d1
	move.w	#350,d2
	move.w	#700,d3
	moveq	#1,d4
	bsr	receive_coor_sup
	lea	serie_color,a2
	bsr	fill_inter

	rts

def_obj0
	dc.w	6
	dc.w	16,$200
	dc.l	face00
	dc.w	16,$220
	dc.l	face01
	dc.w	17,$240
	dc.l	face02
	dc.w	17,$260
	dc.l	face03
	dc.w	22,$280
	dc.l	face04
	dc.w	22,$2a0
	dc.l	face05
def_obj1
	dc.w	6
	dc.w	9,$300
	dc.l	face0
	dc.w	9,$320
	dc.l	face1
	dc.w	11,$340
	dc.l	face2
	dc.w	11,$360
	dc.l	face3
	dc.w	12,$380
	dc.l	face4
	dc.w	12,$3a0
	dc.l	face5


coor_0
	dc.w	8
	dc.w	-60,60,60
	dc.w	60,60,60
	dc.w	60,-60,60
	dc.w	-60,-60,60
	dc.w	-60,60,-60
	dc.w	60,60,-60
	dc.w	60,-60,-60
	dc.w	-60,-60,-60

coor_1
	dc.w	8
	dc.w	-60,60,60
	dc.w	60,60,60
	dc.w	60,-60,60
	dc.w	-60,-60,60
	dc.w	-60,60,-60
	dc.w	60,60,-60
	dc.w	60,-60,-60
	dc.w	-60,-60,-60

rotation0	dc.w	0,0,0,3,2,1
rotation1	dc.w	128+64,64,128+64,1,2,3
crb1		dc.w	-300,1
crb2		dc.w	300,-1	

face00	dc.w	1
	dc.w	4,$400+0*3+1,$400+1*3+1,$400+2*3+1,$400+3*3+1,$400+0*3+1	
face01	dc.w	1
	dc.w	4,$400+7*3+1,$400+6*3+1,$400+5*3+1,$400+4*3+1,$400+7*3+1	
face02	dc.w	1
	dc.w	4,$400+3*3+1,$400+7*3+1,$400+4*3+1,$400+0*3+1,$400+3*3+1	
face03	dc.w	1
	dc.w	4,$400+1*3+1,$400+5*3+1,$400+6*3+1,$400+2*3+1,$400+1*3+1	
face04	dc.w	1
	dc.w	4,$400+0*3+1,$400+4*3+1,$400+5*3+1,$400+1*3+1,$400+0*3+1	
face05	dc.w	1
	dc.w	4,$400+7*3+1,$400+3*3+1,$400+2*3+1,$400+6*3+1,$400+7*3+1	

face0	dc.w	1
	dc.w	4,$500+0*3+1,$500+1*3+1,$500+2*3+1,$500+3*3+1,$500+0*3+1	
face1	dc.w	1
	dc.w	4,$500+7*3+1,$500+6*3+1,$500+5*3+1,$500+4*3+1,$500+7*3+1	
face2	dc.w	1
	dc.w	4,$500+3*3+1,$500+7*3+1,$500+4*3+1,$500+0*3+1,$500+3*3+1	
face3	dc.w	1
	dc.w	4,$500+1*3+1,$500+5*3+1,$500+6*3+1,$500+2*3+1,$500+1*3+1	
face4	dc.w	1
	dc.w	4,$500+0*3+1,$500+4*3+1,$500+5*3+1,$500+1*3+1,$500+0*3+1	
face5	dc.w	1
	dc.w	4,$500+7*3+1,$500+3*3+1,$500+2*3+1,$500+6*3+1,$500+7*3+1	

palette_z1		
	dc.b	0,0,0
	dc.b	24,30,24
	dc.b	24*2,30*2,24*2
	dc.b	24*3,30*3,24*3

	dc.b	30,24,24
	dc.b	24,30,24
	dc.b	24*2,30*2,24*2
	dc.b	24*3,30*3,24*3

	dc.b	30*2,24*2,24*2
	dc.b	24,30,24
	dc.b	24*2,30*2,24*2
	dc.b	24*3,30*3,24*3

	dc.b	30*3,24*3,24*3
	dc.b	24,30,24
	dc.b	24*2,30*2,24*2
	dc.b	24*3,30*3,24*3


	even

preparation_z2
	move.l	logique,a6
	jsr	clear_384_240
	move.l	physique,a6
	jsr	clear_384_240

	lea	palette_z2,a0
	jsr	put_palette

	lea	coor_3,a0
	move.l	#$400,d1
	bsr	send_coor
	lea	coor_4,a0
	move.l	#$500,d1
	bsr	send_coor

	lea	def_obj3,a6
	bsr	objet_to_dsp
	lea	def_obj4,a6
	bsr	objet_to_dsp
	rts

execute_z2
	move.l	adr_eff,a0
	lea	eff_bug,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	movem.w	crb3,d0-d3
	add.w	d1,d0
	add.w	d3,d2
	move.w	d0,crb3
	move.w	d2,crb4

	lea	rotation3,a0
	bsr	increm
	lea	rotation4,a0
	bsr	increm

	lea	rotation3,a0
	move.l	#$400,d1
	move.l	#$400,d2
	move.w	crb3,d3
	ext.l	d3
	moveq.l	#0,d4
	bsr	lance_rotation

	lea	rotation4,a0
	move.l	#$500,d1
	move.l	#$500,d2
	move.w	crb4,d3
	ext.l	d3
	moveq.l	#0,d4
	bsr	lance_rotation

	move.l	adr_eff,a5
	moveq	#4,d0
	move.w	#$400,d1
	move.w	#290,d2
	move.w	#700,d3
	moveq	#0,d4
	bsr	receive_coor

	move.l	adr_eff+4,a5
	moveq	#4,d0
	move.w	#$500,d1
	move.w	#290,d2
	move.w	#700,d3
	moveq	#0,d4
	bsr	receive_coor

	lea	def_obj3,a5
	lea	visible_obj0,a3
	bsr	traite_objet

	lea	def_obj4,a5
	lea	visible_obj1,a3
	bsr	traite_objet

	moveq	#7,d0
	bsr	send

	lea	serie_color,a6
	lea	visible_obj0,a0
	lea	visible_obj1+50,a1
	bsr	lance_gros_calcul	

	lea	eff_bug,a0
	bsr	efface_objet
	lea	eff_bug+8,a0
	bsr	efface_objet
	bsr	ech_adr

	lea	stock_obj,a0
	lea	tab_offset,a5
	move.l	#stock_obj,d5
	lea	stock_obj+2,a6
	bsr	receive_obj

	moveq	#5,d0
	move.w	#$e00,d1
	move.w	#290,d2
	move.w	#700,d3
	moveq	#1,d4
	bsr	receive_coor_sup

	lea	serie_color,a6
	lea	visible_obj0,a0
	lea	visible_obj1,a1
	bsr	lance_gros_calcul	

	lea	serie_color,a2
	bsr	fill_inter	

	move.w	#4,color
	lea	z1ce00,a1
	bsr	letgo2
	move.w	#4,color
	lea	z1ce01,a1
	bsr	letgo2
	move.w	#8,color
	lea	z1ce02,a1
	bsr	letgo2
	move.w	#8,color
	lea	z1ce03,a1
	bsr	letgo2
	move.w	#12,color
	lea	z1ce04,a1
	bsr	letgo2
	move.w	#12,color
	lea	z1ce05,a1
	bsr	letgo2

	lea	stock_obj,a0
	lea	tab_offset,a5
	move.l	#stock_obj,d5
	lea	stock_obj+2,a6
	bsr	receive_obj

	moveq	#5,d0
	move.w	#$e00,d1
	move.w	#290,d2
	move.w	#700,d3
	moveq	#1,d4
	bsr	receive_coor_sup

	lea	serie_color,a2
	bsr	fill_inter
	rts

def_obj4
	dc.w	6
	dc.w	18,$200
	dc.l	z1ce00
	dc.w	18,$220
	dc.l	z1ce01
	dc.w	19,$240
	dc.l	z1ce02
	dc.w	19,$260
	dc.l	z1ce03
	dc.w	19,$280
	dc.l	z1ce04
	dc.w	19,$2a0
	dc.l	z1ce05
def_obj3
	dc.w	6
	dc.w	20,$300
	dc.l	z1ce0
	dc.w	20,$320
	dc.l	z1ce1
	dc.w	21,$340
	dc.l	z1ce2
	dc.w	21,$360
	dc.l	z1ce3
	dc.w	22,$380
	dc.l	z1ce4
	dc.w	22,$3a0
	dc.l	z1ce5


coor_3
	dc.w	8
	dc.w	-60,60,60
	dc.w	60,60,60
	dc.w	60,-60,60
	dc.w	-60,-60,60
	dc.w	-60,60,-60
	dc.w	60,60,-60
	dc.w	60,-60,-60
	dc.w	-60,-60,-60

coor_4
	dc.w	8
	dc.w	-60,60,60
	dc.w	60,60,60
	dc.w	60,-60,60
	dc.w	-60,-60,60
	dc.w	-60,60,-60
	dc.w	60,60,-60
	dc.w	60,-60,-60
	dc.w	-60,-60,-60

rotation3	dc.w	0,64,0,3,1,1
rotation4	dc.w	32,0,32,1,3,2
crb3		dc.w	300,-1
crb4		dc.w	600,-2	

z1ce00	dc.w	1
	dc.w	4,$400+0*3+1,$400+1*3+1,$400+2*3+1,$400+3*3+1,$400+0*3+1	
z1ce01	dc.w	1
	dc.w	4,$400+7*3+1,$400+6*3+1,$400+5*3+1,$400+4*3+1,$400+7*3+1	
z1ce02	dc.w	1
	dc.w	4,$400+3*3+1,$400+7*3+1,$400+4*3+1,$400+0*3+1,$400+3*3+1	
z1ce03	dc.w	1
	dc.w	4,$400+1*3+1,$400+5*3+1,$400+6*3+1,$400+2*3+1,$400+1*3+1	
z1ce04	dc.w	1
	dc.w	4,$400+0*3+1,$400+4*3+1,$400+5*3+1,$400+1*3+1,$400+0*3+1	
z1ce05	dc.w	1
	dc.w	4,$400+7*3+1,$400+3*3+1,$400+2*3+1,$400+6*3+1,$400+7*3+1	

z1ce0	dc.w	1
	dc.w	4,$500+0*3+1,$500+1*3+1,$500+2*3+1,$500+3*3+1,$500+0*3+1	
z1ce1	dc.w	1
	dc.w	4,$500+7*3+1,$500+6*3+1,$500+5*3+1,$500+4*3+1,$500+7*3+1	
z1ce2	dc.w	1
	dc.w	4,$500+3*3+1,$500+7*3+1,$500+4*3+1,$500+0*3+1,$500+3*3+1	
z1ce3	dc.w	1
	dc.w	4,$500+1*3+1,$500+5*3+1,$500+6*3+1,$500+2*3+1,$500+1*3+1	
z1ce4	dc.w	1
	dc.w	4,$500+0*3+1,$500+4*3+1,$500+5*3+1,$500+1*3+1,$500+0*3+1	
z1ce5	dc.w	1
	dc.w	4,$500+7*3+1,$500+3*3+1,$500+2*3+1,$500+6*3+1,$500+7*3+1	

palette_z2		
	dc.b	0,0,0
	dc.b	36,40,44
	dc.b	36*2,40*2,44*2
	dc.b	36*3,40*3,44*3

	dc.b	40,24,36
	dc.b	36,40,44
	dc.b	36*2,40*2,44*2
	dc.b	36*3,40*3,44*3

	dc.b	40*2,24*2,36*2
	dc.b	36,40,44
	dc.b	36*2,40*2,44*2
	dc.b	36*3,40*3,44*3

	dc.b	40*3,24*3,36*3
	dc.b	36,40,44
	dc.b	36*2,40*2,44*2
	dc.b	36*3,40*3,44*3
	even

******************** objet 3 ***************************
preparation_z3
	move.l	logique,a6
	jsr	clear_384_240
	move.l	physique,a6
	jsr	clear_384_240

	lea	palette_z3,a0
	jsr	put_palette

	lea	coor_5,a0
	move.l	#$400,d1
	bsr	send_coor
	lea	coor_6,a0
	move.l	#$480,d1
	bsr	send_coor

	lea	def_obj5,a6
	bsr	objet_to_dsp
	lea	def_obj6,a6
	bsr	objet_to_dsp
	lea	def_obj7,a6
	bsr	objet_to_dsp
	rts

execute_z3
	move.l	adr_eff,a0
	lea	eff_bug,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	movem.w	crb5,d0-d3
	add.w	d1,d0
	add.w	d3,d2
	move.w	d0,crb5
	move.w	d2,crb6

	lea	rotation5,a0
	bsr	increm
	lea	rotation6,a0
	bsr	increm

	lea	rotation5,a0
	move.l	#$400,d1
	move.l	#$400,d2
	move.w	crb5,d3
	ext.l	d3
	move.l	#0,d4
	bsr	lance_rotation

	lea	rotation6,a0
	move.l	#$480,d1
	move.l	#$480,d2
	move.w	crb6,d3
	ext.l	d3
	move.l	#0,d4
	bsr	lance_rotation

	move.l	adr_eff,a5
	moveq	#4,d0
	move.w	#$400,d1
	move.w	#265,d2
	move.w	#700,d3
	moveq	#0,d4
	bsr	receive_coor

	move.l	adr_eff,a5
	moveq	#4,d0
	move.w	#$480,d1
	move.w	#265,d2
	move.w	#700,d3
	moveq	#0,d4
	bsr	receive_coor_bidouille

	lea	def_obj5,a5
	lea	visible_obj0,a3
	bsr	traite_objet

	lea	def_obj6,a5
	lea	visible_obj1,a3
	bsr	traite_objet

	lea	def_obj7,a5
	lea	visible_obj2,a3
	bsr	traite_objet

	moveq	#7,d0
	bsr	send

	lea	serie_color,a6
	lea	visible_obj0,a0
	lea	visible_obj2+50,a1
	bsr	lance_gros_calcul_bidouille	

	lea	eff_bug,a0
	bsr	efface_objet
*	lea	eff_bug+8,a0
*	bsr	efface_objet
	bsr	ech_adr

	lea	stock_obj,a0
	lea	tab_offset,a5
	move.l	#stock_obj,d5
	lea	stock_obj+2,a6
	bsr	receive_obj

	moveq	#5,d0
	move.w	#$e00,d1
	move.w	#265,d2
	move.w	#700,d3
	moveq	#1,d4
	bsr	receive_coor_sup

	lea	serie_color0,a6
	lea	visible_obj1,a0
	lea	visible_obj2+50,a1
	bsr	lance_gros_calcul_bidouille	

	lea	serie_color,a2
	bsr	fill_inter	


	lea	stock_obj,a0
	lea	tab_offset,a5
	move.l	#stock_obj,d5
	lea	stock_obj+2,a6
	bsr	receive_obj

	moveq	#5,d0
	move.w	#$e00,d1
	move.w	#265,d2
	move.w	#700,d3
	moveq	#1,d4
	bsr	receive_coor_sup

	lea	serie_color,a6
	lea	visible_obj1,a0
	lea	visible_obj2,a1
	bsr	lance_gros_calcul	

	lea	serie_color0,a2
	bsr	fill_inter	


	move.w	#18,color
	lea	z2ce00,a1
	bsr	letgo2
	move.w	#18,color
	lea	z2ce01,a1
	bsr	letgo2
	move.w	#19,color
	lea	z2ce02,a1
	bsr	letgo2
	move.w	#19,color
	lea	z2ce03,a1
	bsr	letgo2
	move.w	#25,color
	lea	z2ce04,a1
	bsr	letgo2
	move.w	#25,color
	lea	z2ce05,a1
	bsr	letgo2

	lea	stock_obj,a0
	lea	tab_offset,a5
	move.l	#stock_obj,d5
	lea	stock_obj+2,a6
	bsr	receive_obj

	moveq	#5,d0
	move.w	#$e00,d1
	move.w	#265,d2
	move.w	#700,d3
	moveq	#1,d4
	bsr	receive_coor_sup

	lea	serie_color,a2
	bsr	fill_inter
	rts


def_obj5
	dc.w	6
	dc.w	1,$500
	dc.l	z2ce6
	dc.w	1,$520
	dc.l	z2ce7
	dc.w	2,$540
	dc.l	z2ce8
	dc.w	2,$560
	dc.l	z2ce9
	dc.w	3,$580
	dc.l	z2ce10
	dc.w	3,$5a0
	dc.l	z2ce11
def_obj6
	dc.w	6
	dc.w	1,$300
	dc.l	z2ce0
	dc.w	1,$320
	dc.l	z2ce1
	dc.w	2,$340
	dc.l	z2ce2
	dc.w	2,$360
	dc.l	z2ce3
	dc.w	3,$380
	dc.l	z2ce4
	dc.w	3,$3a0
	dc.l	z2ce5

def_obj7
	dc.w	6
	dc.w	18,$200
	dc.l	z2ce00
	dc.w	18,$220
	dc.l	z2ce01
	dc.w	19,$240
	dc.l	z2ce02
	dc.w	19,$260
	dc.l	z2ce03
	dc.w	19,$280
	dc.l	z2ce04
	dc.w	19,$2a0
	dc.l	z2ce05


coor_5
	dc.w	8
	dc.w	-105,105,15
	dc.w	105,105,15
	dc.w	105,-105,15
	dc.w	-105,-105,15
	dc.w	-105,105,-15
	dc.w	105,105,-15
	dc.w	105,-105,-15
	dc.w	-105,-105,-15

coor_6
	dc.w	8
	dc.w	-60,60,60
	dc.w	60,60,60
	dc.w	60,-60,60
	dc.w	-60,-60,60
	dc.w	-60,60,-60
	dc.w	60,60,-60
	dc.w	60,-60,-60
	dc.w	-60,-60,-60

*rotation5	dc.w	64,16,64,2,2,1
*rotation6	dc.w	0,64,20,2,1,1
rotation5	dc.w	100,0,0,0,2,0
rotation6	dc.w	0,0,32,2,2,1
crb5		dc.w	-400,1
crb6		dc.w	-400,1	

z2ce00	dc.w	1
	dc.w	4,$400+0*3+1,$400+1*3+1,$400+2*3+1,$400+3*3+1,$400+0*3+1	
z2ce01	dc.w	1
	dc.w	4,$400+7*3+1,$400+6*3+1,$400+5*3+1,$400+4*3+1,$400+7*3+1	
z2ce02	dc.w	1
	dc.w	4,$400+3*3+1,$400+7*3+1,$400+4*3+1,$400+0*3+1,$400+3*3+1	
z2ce03	dc.w	1
	dc.w	4,$400+1*3+1,$400+5*3+1,$400+6*3+1,$400+2*3+1,$400+1*3+1	
z2ce04	dc.w	1
	dc.w	4,$400+0*3+1,$400+4*3+1,$400+5*3+1,$400+1*3+1,$400+0*3+1	
z2ce05	dc.w	1
	dc.w	4,$400+7*3+1,$400+3*3+1,$400+2*3+1,$400+6*3+1,$400+7*3+1	

z2ce0	dc.w	1
	dc.w	4,$480+0*3+1,$480+1*3+1,$480+2*3+1,$480+3*3+1,$480+0*3+1	
z2ce1	dc.w	1
	dc.w	4,$480+7*3+1,$480+6*3+1,$480+5*3+1,$480+4*3+1,$480+7*3+1	
z2ce2	dc.w	1
	dc.w	4,$480+3*3+1,$480+7*3+1,$480+4*3+1,$480+0*3+1,$480+3*3+1	
z2ce3	dc.w	1
	dc.w	4,$480+1*3+1,$480+5*3+1,$480+6*3+1,$480+2*3+1,$480+1*3+1	
z2ce4	dc.w	1
	dc.w	4,$480+0*3+1,$480+4*3+1,$480+5*3+1,$480+1*3+1,$480+0*3+1	
z2ce5	dc.w	1
	dc.w	4,$480+7*3+1,$480+3*3+1,$480+2*3+1,$480+6*3+1,$480+7*3+1	

z2ce6	dc.w	1
	dc.w	4,$480+0*3+1,$480+3*3+1,$480+2*3+1,$480+1*3+1,$480+0*3+1	
z2ce7	dc.w	1
	dc.w	4,$480+7*3+1,$480+4*3+1,$480+5*3+1,$480+6*3+1,$480+7*3+1	
z2ce8	dc.w	1
	dc.w	4,$480+3*3+1,$480+0*3+1,$480+4*3+1,$480+7*3+1,$480+3*3+1	
z2ce9	dc.w	1
	dc.w	4,$480+1*3+1,$480+2*3+1,$480+6*3+1,$480+5*3+1,$480+1*3+1	
z2ce10	dc.w	1
	dc.w	4,$480+0*3+1,$480+1*3+1,$480+5*3+1,$480+4*3+1,$480+0*3+1	
z2ce11	dc.w	1
	dc.w	4,$480+6*3+1,$480+2*3+1,$480+3*3+1,$480+7*3+1,$480+6*3+1	

palette_z3		
	dc.b	0,0,0
	dc.b	24*2,12*2,12*2
	dc.b	24*3,12*3,12*3
	dc.b	24*4,12*4,12*4

	dc.b	0,24,24
	dc.b	24*2,12*3,12*3
	dc.b	24*3,12*4,12*4
	dc.b	24*4,12*5,12*5


	dc.b	0,48,48
	dc.b	24*2,12*4,12*4
	dc.b	24*3,12*5,12*5
	dc.b	24*4,12*6,12*6

	dc.b	0,72,72

	dc.b	24*2,12*5,12*5
	dc.b	24*3,12*6,12*6
	dc.b	24*4,12*7,12*7
	even
