	bra	nodebug
	
	pea	0
	move	#$20,-(a7)
	trap	#1
	addq	#6,a7
	
	move	#$777,$ffff8240.w
	
	pea	0
	trap	#1

screen	equ	$f0000
screen1	equ	$f0000-32000-48*160
	opt	d+

	text
			
nodebug	pea	0
	move	#$20,-(a7)
	trap	#1
	addq	#6,a7

	clr.b	$ffff8260.w
	move.l	#screen,d0
	lea	$ffff8200.w,a0
	lsr.l	#8,d0
	movep	d0,1(a0)
	
	move.l	#screen,physic
	move.l	#screen1,logic
	
	move.l	#coo_phys,s_phys
	move.l	#coo_log,s_log
		
	lea	pic_dat,a0
	lea	screen,a1
	lea	screen1,a2
	move	#(150*40)-1,d0
eef	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbra	d0,eef
	
	moveq	#4,d0
	jsr	zak
	
	lea	coo_log,a0	* On met des coordonnees pour pas que
	lea	coo_phys,a1	* ca plante
	move	#1000-1,d0
coord	move.l	#screen1,(a0)+
	move.l	#screen,(a1)+
	dbra	d0,coord
	move	#$ffff,(a0)	* On marque la fin
	move	#$ffff,(a1)	* On marque la fin

	move	#$3b,d0
	bsr	star_demo
	
	move.w	#1,cnt_scro
	clr	cnt_let
	lea	message,a0
	bsr	cod_mes
		
	move	#1,activ_pan
	move	#-1,bring_pan
	sf	choice_pos
	sf	wait_key
	st	predef
	clr	synchro
	move.l	#boing,s_boing
				
	movem.l	pic_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	
	move	#$2700,sr
	
	move.l	$70,s_vbl
	move.l	#my_vbl,$70
	move.l	$118,s_key
	move.l	#my_key,$118
	move.b	$fffffa07.w,mfpiea
	move.b	$fffffa09.w,mfpieb
	move.b	$fffffa13.w,mfpima
	move.b	$fffffa15.w,mfpimb
	move.b	$fffffa1b.w,mfptbc
	move.b	$fffffa21.w,mfptbd

	move	#$2300,sr
	
	clr	synchro
						
main	tst	synchro
	beq.s	main
	clr	synchro

main2	tst	synchro
	beq.s	main2
	clr	synchro
	
	
	bsr	transfos	
	bsr	new_shape
	bsr	rotat_shape
	bsr	clear_screen
	bsr	line_draw
	
	move.l	s_log,d0
	move.l	s_phys,s_log
	move.l	d0,s_phys
	
	move.l	logic,d0
	move.l	physic,logic
	move.l	d0,physic
	
	lea	$ffff8200.w,a0
	lsr.l	#8,d0
	movep	d0,1(a0)
	
	cmp.b	#$39,$fffffc02.w
	bne	main
	
	move	#$2700,sr
	move.l	s_key,$118
	move.l	s_vbl,$70
	move.b	mfpiea,$fffffa07.w
	move.b	mfpieb,$fffffa09.w
	move.b	mfpima,$fffffa13.w
	move.b	mfpimb,$fffffa15.w
	move.b	mfptbc,$fffffa1b.w
	move.b	mfptbd,$fffffa21.w
	move	#$2300,sr
	
	move.l	#$08080000,$ffff8800.w
	move.l	#$09090000,$ffff8800.w
	move.l	#$0a0a0000,$ffff8800.w
	
	move	#$666,$ffff8240.w
	clr	$ffff8246.w	
	pea	0
	trap	#1

my_vbl	movem.l	d0-d7/a0-a6,-(a7)
	bsr	help_?	* Ca: en VBL
	
	bsr	scroll
	bsr	scroll
	bsr	scro_fiche
	bsr	mirror	* Ca aussi
	
	jsr	zak+8
	move	#1,synchro
	movem.l	(a7)+,d0-d7/a0-a6
	rte

my_key	bclr	#6,$fffffa11.w
	rte

scro_fiche	lea	ad_scrol,a0
	move.l	physic,a1
	lea	160*120+2(a1),a1

	move.l	s_boing,a2
	add	(a2)+,a1
	tst	(a2)
	bpl.s	zolttt
	lea	boing,a2
zolttt	move.l	a2,s_boing

	moveq	#6,d0
afich	
gizi	set	0
	rept	2
	movem	(a0)+,d1-d7/a2-a4
	move	d1,gizi*80(a1)
	move	d2,gizi*80+8(a1)
	move	d3,gizi*80+16(a1)
	move	d4,gizi*80+24(a1)
	move	d5,gizi*80+32(a1)
	move	d6,gizi*80+40(a1)
	move	d7,gizi*80+48(a1)
	move	a2,gizi*80+56(a1)
	move	a3,gizi*80+64(a1)
	move	a4,gizi*80+72(a1)
gizi	set	gizi+1
	endr
	lea	160(a1),a1
	addq	#2,a0
	dbra	d0,afich
	rts

mirror	move.l	physic,a0
	
	lea	150*160(a0),a0
	lea	(a0),a1
	moveq	#49,d0
moir	
	movem.l	16+96(a0),d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,16+96(a1)
	
	movem.l	16+48(a0),d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,16+48(a1)
	
	movem.l	16(a0),d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,16(a1)
	movem.l	(a0),d1-d4
	movem.l	d1-d4,(a1)
	
	lea	-320(a0),a0
	lea	160(a1),a1
	dbra	d0,moir
	
	rts

scroll	lea	ad_scrol,a1	* ADDRESSE PREMIERE LIGNE DU SCROLL 
	moveq	#6,d1		* NBRE DE LIGNES DU SCROLL
start	
adre	set	20		* COMPTEUR PAR BLOCS DE 16 PIXELS
	rept	21		* NOMBRE DE BLOCS A PASSER AVANT CHGT DE LIGNE
	roxl.w	adre*2(a1)		* DECALAGE POUR ALLER D'1 PLAN D'1 PIXEL AU MEME PLAN D'1 AUTRE PIXEL
adre	set	adre-1
	endr
	move.w	sr,d0		* NETTOYAGE DU BIT EXTEND POUR EVITER LES HORREURS
	bclr	#4,d0		* SUR L'ECRAN
	move.w	d0,sr

	lea	42(a1),a1		* PLUS DE PLANS SUR CETTE LIGNE ? ON PASSE A LA SUIVANTE
	dbra	d1,start		* PLUS DE LIGNES A SCROLLER? C'EST FINI, ON REPART A 0

	subq	#1,cnt_scro
	bpl.s	contscro
	bsr.s	entrys
	move	#8,cnt_scro
contscro	rts

* Routine d'entree de lettre a ne faire q'une fois que
* le scroll a deplace l'ensemble de 32 pixels(largeur d'une lettre)
* Et en appel BSR
entrys    
	lea	message,a0     ;a0 pointe sur le debut du message
   	lea	lettres,a1     ;a1 pointe sur la table d'adresse des lettres

enscro1	move.w	cnt_let,d0
	move.b	(a0,d0.w),d1 ; d1= code de la lettre
	cmpi.b	#51,d1	; fin de chaine??
	bne.s	endotr
	clr.w	cnt_let
	bra.s	enscro1

endotr	ext.w	d1
	asl.w	#2,d1
	move.l	(a1,d1.w),a2	; addresse lettre
	
	addq.w	#1,cnt_let
* On met la lettre ds le buffer de scroll, a droite de
* ce qui est affiche a l'ecran. Ca va etre dur...
	lea	ad_scrol,a3	* address buffer scroll
	moveq	#6,d3		* 26 lignes a aff.
insc	move.b	(a2),40(a3)	* 2 plans d'1 coup
	lea	42(a3),a3		* une ligne de plus
	lea	160(a2),a2
	dbra	d3,insc		* idem...
	rts			* nb: les lignes du buffer
				* font 352 pix de large

cod_mes	 lea 	codage,a1      ; pointe la table des codes
      	 moveq   #0,d0
ch_me1 	 move.b  (a0),d0         ; charge la lettre
       	 subi.b  #$20,d0         ; je commence par ESP (donc ESP=0)
      	 move.b  (a1,d0.w),(a0)+ ; remplace la lettre par son code
      	 cmpi.b  #$3b,d0         ; est-ce la fin
      	 bne ch_me1              ; non continuer
      	 rts
	
new_shape	move.b	$fffffc02.w,d0
star_demo	cmp.b	#$3b,d0
	bne.s	unio
	st	predef
	
	lea	repli_sha,a0
	lea	actual_shap,a1
	move	#repli_pts-1,d0
	move.l	#repli_lin,actual_lias
	lea	choices_val,a2
	move	d0,8(a2)
	
	move	#$32,14(a2)	* Depart d'effet
	clr	20(a2)
	move	#4,24(a2)
	clr.l	rotates
	clr	rotates+4
	clr	22(a2)
	clr	26(a2)
	clr	18(a2)
	clr	16(a2)
	clr	12(a2)
	clr	10(a2)
	move	#0,Trans_x_sp
	move	#0,Trans_y_sp
	move	#-45,Trans_z_sp	
	
	bra	copy_sha
unio	cmp.b	#$3c,d0
	bne.s	pent
	st	predef
	
	lea	union_coo,a0
	lea	actual_shap,a1
	move	#union_pts-1,d0
	move.l	#union_lin,actual_lias

	lea	choices_val,a2
	move	d0,8(a2)

	move	#15,12(a2)	* Depart d'effet
	move	#$32,14(a2)
	clr	10(a2)
	clr	18(a2)
	clr	16(a2)
	clr	20(a2)
	move	#2,22(a2)
	move	#4,24(a2)
	clr	26(a2)

	move	#0,Trans_x_sp
	move	#-45,Trans_y_sp
	move	#-45,Trans_z_sp	
	bra	copy_sha
pent
	cmp.b	#$3d,d0
	bne.s	chopp
	st	predef
	
	lea	pent_coo,a0
	lea	actual_shap,a1
	move	#pent_pts-1,d0
	move.l	#pent_lin,actual_lias
	
	lea	choices_val,a2
	move	d0,8(a2)

	move	#$f4,12(a2)	* Depart d'effet
	move	#$28,14(a2)
	clr	10(a2)
	clr	18(a2)
	clr	16(a2)
	clr	20(a2)
	move	#2,22(a2)
	move	#4,24(a2)
	clr	26(a2)

	move	#0,Trans_x_sp
	move	#0,Trans_y_sp
	move	#-45,Trans_z_sp	
	bra	copy_sha
chopp	cmp.b	#$3e,d0
	bne	nav
	st	predef
	
	lea	heli_coo,a0
	lea	actual_shap,a1
	move	#heli_pts-1,d0
	move.l	#heli_lin,actual_lias
	
	lea	choices_val,a2
	move	d0,8(a2)

	move	#$20,10(a2)	* Depart d'effet
	move	#15,12(a2)
	clr	14(a2)
	move	#4,16(a2)
	clr	18(a2)
	clr	20(a2)
	clr	22(a2)
	move	#4,24(a2)
	clr	26(a2)
	
	move	#30,rotates
	clr	rotates+2
	clr	rotates+4
	
	clr	Trans_x_sp
	move	#-45,Trans_y_sp
	clr	Trans_z_sp	
	
	bra	copy_sha
nav	cmp.b	#$3f,d0
	bne.s	diam
	st	predef
	
	lea	nav_coo,a0
	lea	actual_shap,a1
	move	#nav_pts-1,d0
	move.l	#nav_lin,actual_lias
	
	lea	choices_val,a2
	move	d0,8(a2)

	clr	12(a2)	* Depart d'effet
	clr	14(a2)
	clr	10(a2)
	clr	18(a2)
	clr	16(a2)
	move	#3,20(a2)
	move	#1,22(a2)
	clr	24(a2)
	move	#2,26(a2)

	clr	Trans_x_sp
	clr	Trans_y_sp
	move	#-25,Trans_z_sp	
	
	bra	copy_sha
diam	cmp.b	#$40,d0
	bne.s	user_def
	
	st	predef
	
	lea	diam_coo,a0
	lea	actual_shap,a1
	move	#dia_pts-1,d0
	move.l	#diam_lin,actual_lias
	move	d0,choices_val+8
	
	lea	choices_val,a2
	move	d0,8(a2)

	move	#15,12(a2)	* Depart d'effet
	move	#$32,14(a2)
	clr	10(a2)
	clr	18(a2)
	clr	16(a2)
	clr	20(a2)
	move	#2,22(a2)
	move	#4,24(a2)
	clr	26(a2)

	move	#0,Trans_x_sp
	move	#-45,Trans_y_sp
	move	#-45,Trans_z_sp	
	
	
	bra	copy_sha
user_def	cmp.b	#$41,d0
	bne.s	clear_sre
	
	sf	predef
	lea	user_coo,a0
	lea	actual_shap,a1
	move	#$fe,d0
	move	#$ffff,user_lin+4
	move.l	#user_lin,actual_lias
	move	#1,choices_val+8
	bra	copy_sha
clear_sre	cmp.b	#$61,d0
	bne.s	ze_end
	move.l	logic,a0
	move.l	physic,a1
	move	#150*20,d0
effaxe	clr	(a0)
	clr	(a1)
	addq	#6,a0
	addq	#6,a1
	dbra	d0,effaxe
ze_end	
	rts
	
copy_sha	move	(a0)+,(a1)+
	move	(a0)+,(a1)+
	move	(a0)+,(a1)+
	dbra	d0,copy_sha
	
	lea	mut_x_tab,a0
	move	#770,d0	* On efface toutes les Mutations
effa_tout	clr	(a0)+
	dbra	d0,effa_tout
		
	rts
	
transfos	lea	choices_val,a0
	lea	sintab,a1
* Translation
	move	16(a0),d0
	add	d0,Trans_x_sp
	move	18(a0),d2
	add	d2,Trans_y_sp
	move	20(a0),d4
	add	d4,Trans_z_sp
	
	move	Trans_x_sp,d0
	move	Trans_y_sp,d2
	move	Trans_z_sp,d4
	
	CMP	#360,D0
	BMI.S	go_y
	sub	#360,Trans_x_sp
go_y	CMP	#360,D2
	BMI.S	go_z
	sub	#360,Trans_y_sp
go_z	CMP	#360,D4
	BMI.S	go_g
	sub	#360,Trans_z_sp
go_g
	tst	d0
	bpl.s	noaddx
	add	#360,d0
noaddx	add	d0,d0
	move	(a1,d0),d0	* Sin
	move	10(a0),d1
	muls	d0,d1
	add.l	d1,d1
	add.l	d1,d1
	swap	d1
	move	d1,translate
	
	tst	d2
	bpl.s	noaddy
	add	#360,d2
noaddy	add	d2,d2
	move	(a1,d2),d2	* Sin
	move	12(a0),d3
	muls	d2,d3
	add.l	d3,d3
	add.l	d3,d3
	swap	d3
	move	d3,translate+2
	
	tst	d4
	bpl.s	noaddz
	add	#360,d4
noaddz	add	d4,d4
	move	(a1,d4),d4	* Sin
	move	14(a0),d5
	muls	d4,d5
	add.l	d5,d5
	add.l	d5,d5
	swap	d5
	move	d5,translate+4

* Rotation
	move	22(a0),d0
	add	d0,rotates
	move	24(a0),d2
	add	d2,rotates+2
	move	26(a0),d4
	add	d4,rotates+4
	
	move	rotates,d0
	move	rotates+2,d2
	move	rotates+4,d4
	
	CMP	#360,D0
	BMI.S	go_y_r
	sub	#360,rotates
go_y_r	CMP	#360,D2
	BMI.S	go_zr
	sub	#360,rotates+2
go_zr	CMP	#360,D4
	BMI.S	go_gr
	sub	#360,rotates+4
go_gr	CMP	#-360,D0
	Bpl.S	go_y_s
	add	#360,rotates
go_y_s	CMP	#-360,D2
	Bpl.S	go_zs
	add	#360,rotates+2
go_zs	CMP	#-360,D4
	Bpl.S	go_gs
	add	#360,rotates+4
go_gs

* Mutation
	lea	objet,a5
	lea	mutates,a6
	lea	mut_x_tab,a2
	lea	mut_y_tab,a3
	lea	mut_z_tab,a4
	move	8(a0),d7	* Nbre de points
mut_bucl	move	(a2)+,d1	* Offset X
	move	(a2)+,d0	* Speed X
	add	d0,mut_x_s
	move	mut_x_s,d0

	tst	d0
	beq.s	goto_y	* On va pas perdre pleins de cycles 
			* pour rien. Car Sin(0)=0
	
	CMP	#360,D0
	BMI.S	go_my
	sub	#360,mut_x_s
go_my	
	tst	d0
	bpl.s	noaddxm
	add	#360,d0
noaddxm	add	d0,d0
	move	(a1,d0),d0	* Sin
	muls	d0,d1
	add.l	d1,d1
	add.l	d1,d1
	swap	d1
	move	d1,(a6)+
	
	bra.s	zlto
	
goto_y	addq	#2,a6
zlto	move	(a3)+,d1	* Offset Y
	move	(a3)+,d0	* Speed Y
	add	d0,mut_y_s
	move	mut_y_s,d0

	tst	d0
	beq.s	goto_z	* On va pas perdre pleins de cycles 
			* pour rien	
	
	CMP	#360,D0
	BMI.S	go_myy
	sub	#360,mut_y_s
go_myy
	tst	d0
	bpl.s	noaddym
	add	#360,d0
noaddym	add	d0,d0
	move	(a1,d0),d0	* Sin
	muls	d0,d1
	add.l	d1,d1
	add.l	d1,d1
	swap	d1
	move	d1,(a6)+
	bra.s	zltob
	
goto_z	addq	#2,a6
zltob	move	(a4)+,d1	* Offset Z
	move	(a4)+,d0	* Speed Z
	add	d0,mut_z_s
	move	mut_z_s,d0

	tst	d0
	beq.s	end	* On va pas perdre pleins de cycles 
			* pour rien	
	
	CMP	#360,D0
	BMI.S	go_myz
	sub	#360,mut_z_s
go_myz
	tst	d0
	bpl.s	noaddzm
	add	#360,d0
noaddzm	add	d0,d0
	move	(a1,d0),d0	* Sin
	muls	d0,d1
	add.l	d1,d1
	add.l	d1,d1
	swap	d1
	move	d1,(a6)+
	bra.s	zltoc
	
end	addq	#2,a6
zltoc	dbra	d7,mut_bucl

	rts

help_?	move.b	$fffffc02.w,d0

	subq	#1,wait_key
	bpl	no_activ
	
	move	#3,wait_key
	
	tst	bring_pan
	bne.s	n_act_dsa
	
	move	activ_pan,d2
	
	cmp.b	#$62,d0
	bne.s	n_act_dsa
	neg	activ_pan
	tst	d2
	bmi.s	remove
	move	#7,bring_pan
	bra.s	n_act_dsa
remove	tst	d2
	bpl.s	n_act_dsa
	move	#-7,bring_pan
n_act_dsa	move	bring_pan,d1
	TST	D1
	BEQ	zlotaba
	tst	d1
	bmi.s	zlotob
	add	d1,d1
	add	d1,d1
	lea	pal_corres,a0
	move.l	(a0,d1),a0
	move.l	(a0)+,$ffff8240.w
	move.l	(a0),$ffff8244.w
	subq	#1,bring_pan
	bra.s	zlotaba
zlotob	tst	d1
	bpl.s	zlotaba
	add	d1,d1
	add	d1,d1
	lea	pal_corres,a0
	move.l	(a0,d1),a0
	move.l	(a0)+,$ffff8240.w
	move.l	(a0),$ffff8244.w
	addq	#1,bring_pan
zlotaba	tst	d2
	bpl	no_activ
	
	move	choice_pos,d1
	
	cmp.b	#$4b,d0
	bne.s	not_left
	tst	d1
	beq.s	not_left
	subq	#1,choice_pos
not_left	cmp.b	#$4d,d0
	bne.s	not_right
	cmp	#19,d1
	beq.s	not_right
	addq	#1,choice_pos
not_right	
	move.l	logic,a0
	move.l	physic,a1
	lea	corresp_ch,a2
	add	d1,d1
	move	(a2,d1),d1
	sf.b	(a0,d1)
	sf.b	(a1,d1)
	
	move	choice_pos,d1
	add	d1,d1
	move	d1,d3
	move	(a2,d1),d2
	st.b	(a0,d2)
	st.b	(a1,d2)
	
	lea	choices_val,a3

	tst	d1
	bne	coords	
* First: Point Number
	cmp.b	#$48,d0	* Touche Haut
	bne.s	bas
	tst	(a3,d3)
	beq.s	bas
	subq	#1,(a3,d3)
bas	cmp.b	#$50,d0	* Touche Bas
	bne.s	affich
	move	8(a3),d7
	move	(a3,d3),d6
	cmp	d7,d6
	beq.s	affich
	addq	#1,(a3,d3)
affich	lea	160*49+59(a0),a0	* Point Number
	lea	160*49+59(a1),a1
	bsr	nbre_aff

	lea	actual_shap,a3
	move	choices_val,d5
	mulu	#6,d5
	move.l	logic,a0
	move.l	physic,a1
	lea	160*49+91(a0),a0
	lea	160*49+91(a1),a1
	move	d5,d3
	bsr	nbre_aff
	addq	#2,d3
	move.l	logic,a0
	move.l	physic,a1
	lea	160*49+115(a0),a0
	lea	160*49+115(a1),a1
	bsr	nbre_aff
	addq	#2,d3
	move.l	logic,a0
	move.l	physic,a1
	lea	160*49+147(a0),a0
	lea	160*49+147(a1),a1
	bsr	nbre_aff

	move	d1,d3
	addq	#6,d3
	lea	choices_val,a3
	addq	#2,d3
	move.l	logic,a0
	move.l	physic,a1
	lea	75+160*57(a0),a0
	lea	75+160*57(a1),a1
	bsr	nbre_aff
	
	addq	#2,d3	
	move.l	logic,a0
	move.l	physic,a1
	lea	91+160*65(a0),a0
	lea	91+160*65(a1),a1
	bsr	nbre_aff
	
	addq	#2,d3	
	move.l	logic,a0
	move.l	physic,a1
	lea	115+160*65(a0),a0
	lea	115+160*65(a1),a1
	bsr	nbre_aff
	
	addq	#2,d3	
	move.l	logic,a0
	move.l	physic,a1
	lea	147+160*65(a0),a0
	lea	147+160*65(a1),a1
	bsr	nbre_aff
	
	addq	#2,d3	
	move.l	logic,a0
	move.l	physic,a1
	lea	91+160*73(a0),a0
	lea	91+160*73(a1),a1
	bsr	nbre_aff
	
	addq	#2,d3	
	move.l	logic,a0
	move.l	physic,a1
	lea	115+160*73(a0),a0
	lea	115+160*73(a1),a1
	bsr	nbre_aff
	
	addq	#2,d3	
	move.l	logic,a0
	move.l	physic,a1
	lea	147+160*73(a0),a0
	lea	147+160*73(a1),a1
	bsr	nbre_aff
	
	addq	#2,d3	
	move.l	logic,a0
	move.l	physic,a1
	lea	91+160*81(a0),a0
	lea	91+160*81(a1),a1
	bsr	nbre_aff
	
	addq	#2,d3	
	move.l	logic,a0
	move.l	physic,a1
	lea	115+160*81(a0),a0
	lea	115+160*81(a1),a1
	bsr	nbre_aff
	
	addq	#2,d3	
	move.l	logic,a0
	move.l	physic,a1
	lea	147+160*81(a0),a0
	lea	147+160*81(a1),a1
	bsr	nbre_aff

* Mutation	
	move	choices_val,d5
	add	d5,d5
	add	d5,d5
	
	lea	mut_x_tab,a3
	move	d5,d3
	move.l	logic,a0
	move.l	physic,a1
	lea	91+160*89(a0),a0
	lea	91+160*89(a1),a1
	bsr	nbre_aff
	
	lea	mut_y_tab,a3
	move	d5,d3
	move.l	logic,a0
	move.l	physic,a1
	lea	115+160*89(a0),a0
	lea	115+160*89(a1),a1
	bsr	nbre_aff
	
	lea	mut_z_tab,a3
	move	d5,d3
	move.l	logic,a0
	move.l	physic,a1
	lea	147+160*89(a0),a0
	lea	147+160*89(a1),a1
	bsr	nbre_aff
	
	lea	mut_x_tab+2,a3
	move	d5,d3
	move.l	logic,a0
	move.l	physic,a1
	lea	91+160*97(a0),a0
	lea	91+160*97(a1),a1
	bsr	nbre_aff
	
	lea	mut_y_tab+2,a3
	move	d5,d3
	move.l	logic,a0
	move.l	physic,a1
	lea	115+160*97(a0),a0
	lea	115+160*97(a1),a1
	bsr	nbre_aff
	
	lea	mut_z_tab+2,a3
	move	d5,d3
	move.l	logic,a0
	move.l	physic,a1
	lea	147+160*97(a0),a0
	lea	147+160*97(a1),a1
	bsr	nbre_aff
	
	bra	no_activ

* Second: Coordinates modifications	
coords	cmp	#2,d1	* C'est X
	bne.s	c_y
	
	lea	actual_shap,a3
	move	choices_val,d5
	mulu	#6,d5
	
	cmp.b	#$48,d0	* Touche Haut
	bne.s	bas_a
	cmp	#-70,(a3,d5)
	beq.s	bas_a
	subq	#1,(a3,d5)
bas_a	cmp.b	#$50,d0	* Touche Bas
	bne.s	affich_a
	cmp	#70,(a3,d5)
	beq.s	affich_a
	addq	#1,(a3,d5)
affich_a	lea	160*49+91(a0),a0
	lea	160*49+91(a1),a1
	move	d5,d3
	
	bsr	nbre_aff
	bra	no_activ
	
c_y	cmp	#4,d1	* C'est Y
	bne.s	c_z
	lea	actual_shap,a3
	move	choices_val,d5
	mulu	#6,d5
	
	addq	#2,d5
	
	cmp.b	#$48,d0	* Touche Haut
	bne.s	bas_ab
	cmp	#-70,(a3,d5)
	beq.s	bas_ab
	subq	#1,(a3,d5)
bas_ab	cmp.b	#$50,d0	* Touche Bas
	bne.s	affich_ab
	cmp	#70,(a3,d5)
	beq.s	affich_ab
	addq	#1,(a3,d5)
affich_ab	lea	160*49+115(a0),a0
	lea	160*49+115(a1),a1
	move	d5,d3
	
	bsr	nbre_aff
	bra	no_activ
	
c_z	cmp	#6,d3	* C'est Z
	bne.s	end_coord

	lea	actual_shap,a3
	move	choices_val,d5
	mulu	#6,d5
	
	addq	#4,d5	
		
	cmp.b	#$48,d0	* Touche Haut
	bne.s	bas_ac
	cmp	#-70,(a3,d5)
	beq.s	bas_ac
	subq	#1,(a3,d5)
bas_ac	cmp.b	#$50,d0	* Touche Bas
	bne.s	affich_ac
	cmp	#70,(a3,d5)
	beq.s	affich_ac
	addq	#1,(a3,d5)
affich_ac	lea	160*49+147(a0),a0
	lea	160*49+147(a1),a1
	move	d5,d3
	
	bsr	nbre_aff
	bra	no_activ
	
end_coord	
* Third: number of points counter
	cmp	#8,d1
	bne	transfo
	
	tst	predef	* Est-ce un motif predefini?
	bmi	affichd	* Oui? Alors pas de chgt du nbre de pts
	
	cmp.b	#$48,d0	* Touche Haut
	bne.s	basd
	cmp	#2,(a3,d3)	* Il faut au moins 2 points!
	bmi.s	basd
	subq	#2,(a3,d3)
	
	move	(a3,d3),d4
	add	d4,d4
	lea	user_lin,a4
	move	#$ffff,2(a4,d4)
	
basd	cmp.b	#$50,d0	* Touche Bas
	bne.s	affichd
	cmp	#$ff,(a3,d3)
	bpl.s	affichd
	addq	#2,(a3,d3)

	move	(a3,d3),d4
	move	d4,d5
	add	d4,d4
	lea	user_lin,a4
	move	#$ffff,2(a4,d4)
	move	d5,(a4,d4)
	subq	#1,d5
	move	d5,-2(a4,d4)
	
affichd	lea	75+160*57(a0),a0
	lea	75+160*57(a1),a1
	
	bsr	nbre_aff
	
	bra	no_activ

transfo	cmp	#10,d1	* Translation offset X
	bne.s	trans_y
	
	cmp.b	#$48,d0	* Touche Haut
	bne.s	base
	cmp	#-50,(a3,d3)
	beq.s	base
	subq	#1,(a3,d3)
base	cmp.b	#$50,d0	* Touche Bas
	bne.s	afficheg
	cmp	#50,(a3,d3)
	beq.s	afficheg
	addq	#1,(a3,d3)
afficheg	lea	91+160*65(a0),a0
	lea	91+160*65(a1),a1
	bsr	nbre_aff
	
	bra	no_activ

trans_y	cmp	#12,d1
	bne.s	trans_z
	
	cmp.b	#$48,d0	* Touche Haut
	bne.s	basf
	cmp	#-50,(a3,d3)
	beq.s	basf
	subq	#1,(a3,d3)
basf	cmp.b	#$50,d0	* Touche Bas
	bne.s	affichf
	cmp	#50,(a3,d3)
	beq.s	affichf
	addq	#1,(a3,d3)
affichf	lea	115+160*65(a0),a0
	lea	115+160*65(a1),a1
	bsr	nbre_aff
	
	bra	no_activ

trans_z	cmp	#14,d1
	bne.s	trans_s_x
	
	cmp.b	#$48,d0	* Touche Haut
	bne.s	basg
	cmp	#-50,(a3,d3)
	beq.s	basg
	subq	#1,(a3,d3)
basg	cmp.b	#$50,d0	* Touche Bas
	bne.s	affichg
	cmp	#50,(a3,d3)
	beq.s	affichg
	addq	#1,(a3,d3)
affichg	lea	147+160*65(a0),a0
	lea	147+160*65(a1),a1
	bsr	nbre_aff
	
	bra	no_activ
trans_s_x	
	cmp	#16,d1	* Translation speed X
	bne.s	trans_s_y
	
	cmp.b	#$48,d0	* Touche Haut
	bne.s	bash
	tst	(a3,d3)
	beq.s	bash
	subq	#1,(a3,d3)
bash	cmp.b	#$50,d0	* Touche Bas
	bne.s	afficheh
	cmp	#$ff,(a3,d3)
	beq.s	afficheh
	addq	#1,(a3,d3)
afficheh	lea	91+160*73(a0),a0
	lea	91+160*73(a1),a1
	
	bsr	nbre_aff
	
	bra	no_activ

trans_s_y	cmp	#18,d1
	bne.s	trans_s_z
	
	cmp.b	#$48,d0	* Touche Haut
	bne.s	basi
	tst	(a3,d3)
	beq.s	basi
	subq	#1,(a3,d3)
basi	cmp.b	#$50,d0	* Touche Bas
	bne.s	affichi
	cmp	#$ff,(a3,d3)
	beq.s	affichi
	addq	#1,(a3,d3)
affichi	lea	115+160*73(a0),a0
	lea	115+160*73(a1),a1
	
	bsr	nbre_aff
	
	bra	no_activ

trans_s_z	cmp	#20,d1
	bne.s	rot_spd_x
	
	cmp.b	#$48,d0	* Touche Haut
	bne.s	basj
	tst	(a3,d3)
	beq.s	basj
	subq	#1,(a3,d3)
basj	cmp.b	#$50,d0	* Touche Bas
	bne.s	affichj
	cmp	#$ff,(a3,d3)
	beq.s	affichj
	addq	#1,(a3,d3)
affichj	lea	147+160*73(a0),a0
	lea	147+160*73(a1),a1
	
	bsr	nbre_aff
	
	bra	no_activ
rot_spd_x	cmp	#22,d1	* Translation speed X
	bne.s	rot_spd_y
	
	cmp.b	#$48,d0	* Touche Haut
	bne.s	bask
	cmp	#-128,(a3,d3)
	beq.s	bask
	subq	#1,(a3,d3)
bask	cmp.b	#$50,d0	* Touche Bas
	bne.s	affichek
	cmp	#127,(a3,d3)
	beq.s	affichek
	addq	#1,(a3,d3)
affichek	lea	91+160*81(a0),a0
	lea	91+160*81(a1),a1
	
	bsr	nbre_aff
	
	bra	no_activ

rot_spd_y	cmp	#24,d1
	bne.s	rot_spd_z
	
	cmp.b	#$48,d0	* Touche Haut
	bne.s	basl
	cmp	#-128,(a3,d3)
	beq.s	basl
	subq	#1,(a3,d3)
basl	cmp.b	#$50,d0	* Touche Bas
	bne.s	affichl
	cmp	#127,(a3,d3)
	beq.s	affichl
	addq	#1,(a3,d3)
affichl	lea	115+160*81(a0),a0
	lea	115+160*81(a1),a1
	bsr	nbre_aff
	
	bra	no_activ

rot_spd_z	cmp	#26,d1
	bne.s	mut_x
	
	cmp.b	#$48,d0	* Touche Haut
	bne.s	basm
	cmp	#-128,(a3,d3)
	beq.s	basm
	subq	#1,(a3,d3)
basm	cmp.b	#$50,d0	* Touche Bas
	bne.s	affichm
	cmp	#127,(a3,d3)
	beq.s	affichm
	addq	#1,(a3,d3)
affichm	lea	147+160*81(a0),a0
	lea	147+160*81(a1),a1
	
	bsr	nbre_aff
	
	bra	no_activ
mut_x	cmp	#28,d1	* Mutation offset X
	bne.s	mut_y
	
	move	(a3),d7
	lea	mut_x_tab,a3
	add	d7,d7
	add	d7,d7
	
	cmp.b	#$48,d0	* Touche Haut
	bne.s	basn
	cmp	#-50,(a3,d7)
	beq.s	basn
	subq	#1,(a3,d7)
basn	cmp.b	#$50,d0	* Touche Bas
	bne.s	affichen
	cmp	#50,(a3,d7)
	beq.s	affichen
	addq	#1,(a3,d7)
affichen	lea	91+160*89(a0),a0
	lea	91+160*89(a1),a1
	move	d7,d3
	bsr	nbre_aff
	
	bra	no_activ

mut_y	cmp	#30,d1
	bne.s	mut_z
	
	move	(a3),d7
	lea	mut_y_tab,a3
	add	d7,d7
	add	d7,d7
	
	cmp.b	#$48,d0	* Touche Haut
	bne.s	baso
	cmp	#-50,(a3,d7)
	beq.s	baso
	subq	#1,(a3,d7)
baso	cmp.b	#$50,d0	* Touche Bas
	bne.s	afficho
	cmp	#50,(a3,d7)
	beq.s	afficho
	addq	#1,(a3,d7)
afficho	lea	115+160*89(a0),a0
	lea	115+160*89(a1),a1
	move	d7,d3
	
	bsr	nbre_aff
	
	bra	no_activ

mut_z	cmp	#32,d1
	bne.s	mut_spd_x
	
	move	(a3),d7
	lea	mut_z_tab,a3
	add	d7,d7
	add	d7,d7
	
	cmp.b	#$48,d0	* Touche Haut
	bne.s	basp
	cmp	#-50,(a3,d7)
	beq.s	basp
	subq	#1,(a3,d7)
basp	cmp.b	#$50,d0	* Touche Bas
	bne.s	affichp
	cmp	#50,(a3,d7)
	beq.s	affichp
	addq	#1,(a3,d7)
affichp	lea	147+160*89(a0),a0
	lea	147+160*89(a1),a1
	move	d7,d3
	
	bsr	nbre_aff
	
	bra	no_activ

mut_spd_x
	cmp	#34,d1	* Mutation offset X
	bne.s	mut_spd_y
	
	move	(a3),d7
	lea	mut_x_tab,a3
	add	d7,d7
	add	d7,d7
	
	addq	#2,d7
	
	cmp.b	#$48,d0	* Touche Haut
	bne.s	basq
	cmp	#-128,(a3,d7)
	beq.s	basq
	subq	#1,(a3,d7)
basq	cmp.b	#$50,d0	* Touche Bas
	bne.s	afficheq
	cmp	#127,(a3,d7)
	beq.s	afficheq
	addq	#1,(a3,d7)
afficheq	lea	91+160*97(a0),a0
	lea	91+160*97(a1),a1
	move	d7,d3
	
	bsr	nbre_aff
	
	bra	no_activ

mut_spd_y	cmp	#36,d1
	bne.s	mut_spd_z
	
	move	(a3),d7
	lea	mut_y_tab,a3
	add	d7,d7
	add	d7,d7
	addq	#2,d7
	
	cmp.b	#$48,d0	* Touche Haut
	bne.s	basr
	cmp	#-128,(a3,d7)
	beq.s	basr
	subq	#1,(a3,d7)
basr	cmp.b	#$50,d0	* Touche Bas
	bne.s	affichr
	cmp	#50,(a3,d7)
	beq.s	affichr
	addq	#1,(a3,d7)
affichr	lea	115+160*97(a0),a0
	lea	115+160*97(a1),a1
	move	d7,d3
	
	bsr	nbre_aff
	
	bra	no_activ

mut_spd_z	cmp	#38,d1
	bne.s	no_activ
	
	move	(a3),d7
	lea	mut_z_tab,a3
	add	d7,d7
	add	d7,d7
	addq	#2,d7
	
	cmp.b	#$48,d0	* Touche Haut
	bne.s	bass
	cmp	#-128,(a3,d7)
	beq.s	bass
	subq	#1,(a3,d7)
bass	cmp.b	#$50,d0	* Touche Bas
	bne.s	affichs
	cmp	#127,(a3,d7)
	beq.s	affichs
	addq	#1,(a3,d7)
affichs	lea	147+160*97(a0),a0
	lea	147+160*97(a1),a1
	move	d7,d3
	
	bsr	nbre_aff

no_activ	rts

nbre_aff	lea	numb,a4
	move	(a3,d3),d0
	moveq	#1,d2
	
affffff	move	d0,d6
	and	#$f,d6
	lsr	#4,d0
	add	d6,d6
	add	d6,d6
	move.l	(a4,d6),a5
	moveq	#6,d4
affiche	move.b	(a5),(a0)
	move.b	(a5),(a1)
	lea	160(a5),a5
	lea	160(a0),a0
	lea	160(a1),a1
	dbra	d4,affiche
	lea	-160*7-1(a0),a0
	lea	-160*7-1(a1),a1
	dbra	d2,affffff
	rts
			
shades	
	lea	$ffff8242.w,a2
	move	objet+4,d0
	cmp	#100,d0
	bpl.s	zlot0
	move	#$700,(a2)
	bra.s	zend
zlot0	cmp	#200,d0
	bpl.s	zlot1
	move	#$600,(a2)
	bra.s	zend
zlot1	cmp	#500,d0
	bpl.s	zlot2
	move	#$500,(a2)
	bra.s	zend
zlot2	cmp	#1000,d0
	bpl.s	zlot3
	move	#$400,(a2)
	bra.s	zend
zlot3	cmp	#1500,d0
	bpl.s	zlot4
	move	#$300,(a2)
	bra.s	zend
zlot4	cmp	#2000,d0
	bpl.s	zlot5
	move	#$200,(a2)
	bra.s	zend
zlot5	cmp	#2500,d0
	bpl.s	zlot6
	move	#$100,(a2)
	bra.s	zend
zlot6	cmp	#3000,d0
	bpl.s	zend
	move	#$0,(a2)
zend
	rts
	
clear_screen
	move.l	s_log,a0
efff	move.l	(a0)+,a1
	clr	(a1)
	tst	(a0)
	bpl.s	efff
	rts

rotat_shape	
	lea	actual_shap,a0	* Forme
	move	choices_val+8,d0	* Nbr de points
	lea	objet,a1
copynak	rept	3
	move	(a0)+,(a1)+
	endr
	dbra	d0,copynak

	lea	sintab,a0
	lea	rotates,a1

* Rotation autour de l'axe des X:
* Y'=ycos@+zsin@
* Z'=-ysin@+zcos@
	move	(a1)+,d0
	
	tst	d0	* Y-a-t-il rotation?
	beq	end_x
	
	bsr	sincos
	lea	objet+2,a2
	move	choices_val+8,d7	* Nbr de points
bucle_x	move	(a2)+,d2	* Y
	move	(a2)+,d3	* Z
	subq	#4,a2
	move	d2,d4
	move	d3,d5
	
	muls	d0,d4	* ycos@
	muls	d1,d5	* zsin@
	
	add.l	d4,d4
	add.l	d5,d5
	swap	d4
	swap	d5
	
	add	d5,d4	* Y'=ycos@+zsin@
	
	move	d2,d5
	move	d3,d6
	
	muls	d1,d5	* ysin@
	muls	d0,d6	* zcos@
	
	add.l	d5,d5
	add.l	d6,d6
	swap	d5
	swap	d6
	neg	d5	* -ysin@
	add	d6,d5	* Z'=-ysin@+zcos@
	
	move	d4,(a2)+
	move	d5,(a2)+
	addq	#2,a2
	dbra	d7,bucle_x
	
end_x
* Rotation autour de l'axe des Y:
* X'=xcos@-zsin@
* Z'=xsin@+zcos@
	move	(a1)+,d0
	
	tst	d0	* Y-a-t-il rotation?
	beq	end_y
	
	bsr	sincos
	lea	objet,a2
	move	choices_val+8,d7	* Nbr de points
bucle_y	move	(a2)+,d2	* X
	move	2(a2),d3	* Z
	subq	#2,a2
	move	d2,d4
	move	d3,d5
	
	muls	d0,d4	* xcos@
	muls	d1,d5	* zsin@
	
	add.l	d4,d4
	add.l	d5,d5
	swap	d4
	swap	d5

	neg	d5	* -zsin@	
	add	d5,d4	* X'=xcos@-zsin@
	
	move	d2,d5
	move	d3,d6
	
	muls	d1,d5	* xsin@
	muls	d0,d6	* zcos@
	
	add.l	d5,d5
	add.l	d6,d6
	swap	d5
	swap	d6
	add	d6,d5	* Z'=xsin@+zcos@
	
	move	d4,(a2)+
	addq	#2,a2
	move	d5,(a2)+
	dbra	d7,bucle_y
	
end_y	
* Rotation autour de l'axe des Z:
* X'=xcos@+ysin@
* Y'=-xsin@+ycos@
	move	(a1)+,d0
	
	tst	d0	* Y-a-t-il rotation?
	beq	end_z
	
	bsr	sincos
	lea	objet,a2
	move	choices_val+8,d7	* Nbr de points
bucle_z	move	(a2)+,d2	* X
	move	(a2)+,d3	* Y
	subq	#4,a2
	move	d2,d4
	move	d3,d5
	
	muls	d0,d4	* xcos@
	muls	d1,d5	* ysin@
	
	add.l	d4,d4
	add.l	d5,d5
	swap	d4
	swap	d5

	add	d5,d4	* X'=xcos@+ysin@
	
	move	d2,d5
	move	d3,d6
	
	muls	d1,d5	* xsin@
	muls	d0,d6	* ycos@
	
	add.l	d5,d5
	add.l	d6,d6
	swap	d5
	swap	d6
	neg	d5	* -xsin@
	add	d6,d5	* Y'=-xsin@+ycos@
	
	move	d4,(a2)+
	move	d5,(a2)+
	addq	#2,a2
	dbra	d7,bucle_z
	
* Et maintenant, on donne une perspective a tout le bazard
* Formule: X'=X_fuite+(X_fuite-X)*Z_fuite/(Z-Z_fuite)
*          Y'=Y_fuite+(Y_fuite-Y)*Z_fuite/(Z-Z_fuite)
* z_fuite doit etre <0
* Et on en profite pour effectuer les translations de la forme!!!
x_fuite	equ	0
y_fuite	equ	0
z_fuite	equ	-200
	
end_z	lea	translate,a1
	LEA	mutates,A6
	move	(a1)+,a3
	move	(a1)+,a4
	move	(a1)+,a5
	
	lea	objet,a0
	lea	be_drawn,a1
	
	move	#x_fuite,d1
	move	#y_fuite,d2
	move	#z_fuite,d3
	move	choices_val+8,d0	* Nbr de points
perspec	move	d1,d4	* X_fuite
	sub	(a0)+,d4	* X_fuite-X
	add	a3,d4	* Et oui! On fait une translation
			* sur X!
	add	(a6)+,d4
	
	muls	d3,d4	* (X_fuite-X)*Z_fuite
	move	(a0)+,d5	* Y
	add	a4,d5	* Et oui! On fait une translation
			* sur Y!
	add	(a6)+,d5
	
	move	(a0)+,d6	* Z
	add	a5,d6	* Et oui! On fait une translation
			* sur Z!
	add	(a6)+,d6
	
	sub	d3,d6	* Z-Z_fuite
	divs	d6,d4	* (X_fuite-X)*Z_fuite/(Z-Z_fuite)
	add	d1,d4  * X'=X_fuite+(X_fuite-X)*Z_fuite/(Z-Z_fuite)
	
	move	d2,d7	* Y_fuite
	sub	d5,d7	* Y_fuite-Y
	muls	d3,d7	* (Y_fuite-Y)*Z_fuite
	divs	d6,d7	* (Y_fuite-Y)*Z_fuite/(Z-Z_fuite)
	add	d2,d7  * Y'=Y_fuite+(Y_fuite-Y)*Z_fuite/(Z-Z_fuite)
	
	cmp	#-99,d7
	bpl.s	no_up
	move	#-99,d7
no_up	cmp	#99,d7
	bmi.s	no_down
	move	#99,d7
no_down	cmp	#159,d4
	bmi.s	no_right
	move	#159,d4
no_right	cmp	#-159,d4
	bpl.s	no_left
	move	#-159,d4

no_left	move	d4,(a1)+
	move	d7,(a1)+
	dbra	d0,perspec
	
	rts
	
sincos	
* On recupere la chose avec lsl #2 et swap d2	
	tst	d0
	bpl.s	noadd
	add	#360,d0
noadd	move	d0,d1
	move	d0,d2
	
	add	d1,d1
	move	(a0,d1),d1	* Sin
	
	cmp	#270,d0
	blt.s	plus9
	sub	#270,d0
	bra.s	gosin
plus9	add	#90,d0
gosin	add	d0,d0
	move	(a0,d0),d0	* Cos
	
	rts

* d0=X1  d1=Y1
* d2=X2  d3=Y2
line_draw	lea	multab,a1
	lea	be_drawn,a6	* Coordonnees des points
	move.l	actual_lias,a3	* Relie points
	move.l	logic,a5
	move.l	s_log,a4

draw_stuff	lea	(a5),a0
	
	move	(a3)+,d0
	add	d0,d0
	add	d0,d0
	move	2(a6,d0),d1	* Y1
	move	(a6,d0),d0	* X1
	
	move	(a3)+,d2
	add	d2,d2
	add	d2,d2
	move	2(a6,d2),d3	* Y2
	move	(a6,d2),d2	* X2
	
	add	#160,d0	* On se centre sur l'ecran
	add	#100,d1
	add	#160,d2	* On se centre sur l'ecran
	add	#100,d3
		
	move	d0,d4	* X1
	move	d4,d5
	
	and	#$fff0,d4	* Abscisse adresse de depart
	lsr	#1,d4
	
	and	#$f,d5
	moveq	#15,d6
	sub	d5,d6
	moveq	#0,d7
	bset	d6,d7	* Position initiale du point au depart
	
	move	d1,d6	* Y1
	add	d6,d6
	add	(a1,d6),a0	* Ordonnee de depart
	
	add	d4,a0	* Adresse de depart de la ligne
	
	or	d7,(a0)	* First Plot
	
	move.l	a0,(a4)+	* On sauvegarde

	sub	d0,d2	* Dx
	bpl.s	positx
	st	d4	* Sens de variation de x
	neg	d2
	bra.s	contx
positx	sf	d4	* Sens de variation de x

contx	sub	d1,d3	* Dy
	bpl.s	posity
	move	#-160,a2	* y2<y1
	neg	d3
	bra.s	conty
posity	move	#160,a2	* y2>y1
conty	
	move	d2,d0
	add	d0,d0
	
	move	d3,d1
	add	d1,d1
	
	cmp	d2,d3	* Dx>Dy
	bpl	y_superior

* X change plus vite
	* Init
	move	d1,d6	* S=Dy2-Dx
	sub	d2,d6
	
	move	d1,d5
	sub	d0,d5
	
	tst	d2	* Si d2=0
	beq	pointa_0	* La, il n'y a qu'un point
	
	subq	#1,d2	* Dx-1: Dbra
	
	tst.b	d4
	beq.s	end_last
	
	move	a2,d4
	* Draw	
bucle_drawx	tst	d6
	bmi.s	infe_0_x
	add	d4,a0
	add	d5,d6
	bra.s	contix

infe_0_x	add	d1,d6
contix	cmp	#%1000000000000000,d7
	bne.s	not_yet
	subq	#8,a0
not_yet	rol	d7
	
	or	d7,(a0)
	
	move.l	a0,(a4)+	* On sauvegarde
	
	dbra	d2,bucle_drawx
pointa_0	tst	(a3)
	bpl	draw_stuff
	
	move	#$ffff,(a4)	* On marque la fin de la sauvegarde
	
	rts

end_last	move	a2,d4
	* Draw	
bucle_drax	tst	d6
	bmi.s	infe_0_x_l
	add	d4,a0
	add	d5,d6
	bra.s	contix_l

infe_0_x_l	add	d1,d6
contix_l	cmp	#1,d7
	bne.s	not_yet_l
	addq	#8,a0
not_yet_l	ror	d7	* =rol d7
	
	or	d7,(a0)
	
	move.l	a0,(a4)+	* On sauvegarde
	
	dbra	d2,bucle_drax
	tst	(a3)
	bpl	draw_stuff
	
	move	#$ffff,(a4)	* On marque la fin de la sauvegarde
	
	rts

y_superior	
	* Init
	move	d0,d6	* S=Dy2-Dx
	sub	d3,d6
	
	move	d0,d5
	sub	d1,d5
	
	tst	d3	* Si d3=0
	beq.s	pointb_0	* La, il n'y a qu'un point
	
	subq	#1,d3	* Dx-1: Dbra
	
	tst.b	d4
	beq.s	end_last_y
	
	move	a2,d4
	* Draw	
bucle_drawy	tst	d6
	bmi.s	infe_0_y
	cmp	#%1000000000000000,d7
	bne.s	not_yet_y
	subq	#8,a0
not_yet_y	rol	d7
	add	d5,d6
	bra.s	contiy

infe_0_y	add	d0,d6
contiy	add	d4,a0
	
	or	d7,(a0)
	
	move.l	a0,(a4)+	* On sauvegarde
	
	dbra	d3,bucle_drawy
pointb_0	tst	(a3)
	bpl	draw_stuff
	
	
	move	#$ffff,(a4)	* On marque la fin de la sauvegarde
	
	rts

end_last_y	move	a2,d4
	* Draw	
bucle_dray	
	tst	d6
	bmi.s	infe_0_y_l
	cmp	#1,d7
	bne.s	not_yet_y_l
	addq	#8,a0
not_yet_y_l	ror	d7	* =rol d7
	add	d5,d6
	bra.s	contiy_l

infe_0_y_l	add	d0,d6
contiy_l	add	d4,a0
	
	or	d7,(a0)
	
	move.l	a0,(a4)+	* On sauvegarde
	
	dbra	d3,bucle_dray
	tst	(a3)
	bpl	draw_stuff
	
	move	#$ffff,(a4)	* On marque la fin de la sauvegarde
	rts

	data
	dc.l	pal_8,pal_7,pal_6,pal_5,pal_4,pal_3,pal_2,pal_1
pal_corres	dc.l	pal_8,pal_7,pal_6,pal_5,pal_4,pal_3,pal_2,pal_1
pal_1	dc.w	0,$700,$0,$700
pal_2	dc.w	0,$700,$111,$700
pal_3	dc.w	0,$700,$222,$700
pal_4	dc.w	0,$700,$333,$700
pal_5	dc.w	0,$700,$444,$700
pal_6	dc.w	0,$700,$555,$700
pal_7	dc.w	0,$700,$666,$700
pal_8	dc.w	0,$700,$777,$700

boing	
gizi	set	0
	rept	20
	dc.w	gizi*160
gizi	set	gizi+1
	endr
	rept	20
	dc.w	gizi*160
gizi	set	gizi-1
	endr
	dc.w	$ffff
corresp_ch	
	dc.w	56+2+160*56
	dc.w	81+2+160*56
	dc.w	105+2+160*56
	dc.w	137+2+160*56
	dc.w	72+2+160*64
gizi	set	0
	rept	5
	dc.w	81+2+160*72+gizi*8*160
	dc.w	105+2+160*72+gizi*8*160
	dc.w	137+2+160*72+gizi*8*160
gizi	set	gizi+1
	endr

choices_val	dc.w	0	* N= de point
	dc.w	0,0,0	* Coord: non utilisees
	dc.w	0	* Nbre de points
	dc.w	0,0,0	* Translation Offset
	dc.w	0,0,0	*      ""     Speed
	dc.w	0,0,0	* Rotation Speed
	dc.w	0,0,0	* Mutation Offset
	dc.w	0,0,0	*    ""    Speed

numb	dc.l	pic_dat+160*151+2+104
	dc.l	pic_dat+160*151+2+105
	dc.l	pic_dat+160*151+2+112
	dc.l	pic_dat+160*151+2+113
	dc.l	pic_dat+160*151+2+120
	dc.l	pic_dat+160*151+2+121
	dc.l	pic_dat+160*151+2+128
	dc.l	pic_dat+160*151+2+129
	dc.l	pic_dat+160*151+2+136
	dc.l	pic_dat+160*151+2+137
	dc.l	pic_dat+160*151+2
	dc.l	pic_dat+160*151+2+1
	dc.l	pic_dat+160*151+2+8
	dc.l	pic_dat+160*151+2+9
	dc.l	pic_dat+160*151+2+16
	dc.l	pic_dat+160*151+2+17
	
* Helicoptere
heli_pts	equ	29
heli_coo	dc.w	25,20,40,25,20,0,-25,20,40,-25,20,0	* Train
	dc.w	25,20,25,25,20,5,-25,20,25,-25,20,5	* Atterrissage
	dc.w	20,10,20,20,10,10,-20,10,20,-20,10,10
	dc.w	20,10,0,20,10,35,-20,10,35,-20,10,0	* Bas de cabine
	dc.w	5,0,-10,-5,0,-10,10,-10,10,-10,-10,10,0,-10,-60
	dc.w	0,-10,0,0,-13,0	* Joint helice
	dc.w	2,-13,50,-2,-13,50,2,-13,-50,-2,-13,-50 * Grde helice
	dc.w	0,-15,-60,0,-5,-60	* Petite helice
heli_lin	dc.w	0,1,2,3,4,8,5,9,6,10,7,11,12,13,13,14,14,15,15,12
	dc.w	12,16,15,17,16,17,13,18,14,19,18,19,18,20,19,20
	dc.w	16,20,17,20,16,18,17,19,12,18,15,19,21,22
	dc.w	23,24,24,25,25,26,26,23,27,28
	dc.w	$ffff
	
* Pentacle
pent_pts	equ	9
pent_coo	dc.w	0,0,-60,60,0,-20,40,0,60
	dc.w	-40,0,60,-60,0,-20
	dc.w	-15,20,-15,15,20,-15,0,20,15,0,35,0
pent_lin	dc.w	0,2,2,4,4,1,1,3,3,0
	dc.w	5,6,6,7,7,5,5,8,6,8,7,8
	dc.w	$ffff
* Navette
nav_pts	equ	9
nav_coo	dc.w	-60,-10,-40,-20,0,-40,20,0,-40
	dc.w	60,-10,-40,60,-10,-20,0,0,60,-60,-10,-20
	dc.w	0,30,-40,0,-20,-40
nav_lin	dc.w	0,1,1,2,2,3,3,4,4,5,5,6,6,0
	dc.w	1,7,2,7,5,7,1,5,2,5,0,8,3,8,5,8
	dc.w	$ffff
* Periscope
peris_pts	equ	16
peris_coo	dc.w	-10,-20,0,0,-19,0,5,-15,0,5,15,0
	dc.w	-10,-15,0,-5,-15,0,0,-10,0,0,15,0
	dc.w	-10,-19,3,-5,-19,3,3,-13,3,3,15,3
	dc.w	-10,-19,-3,-5,-19,-3,3,-13,-3,3,15,-3
peris_lin	dc.w	0,1,1,2,2,3,4,5,5,6,6,7
	dc.w	8,9,9,10,10,11,12,13,13,14,14,15
	dc.w	0,8,8,4,4,12,12,0,1,9,9,5,5,13,13,1
	dc.w	2,10,10,6,6,14,14,2
	dc.w	$ffff	
	
* Logo Union: U
union_pts	equ	20
union_coo	dc.w	-25,-30,5,-15,-30,5,-15,15,5,-10,20,5
	dc.w	15,20,5,15,-30,5,25,-30,5,25,30,5,-20,30,5
	dc.w	-25,25,5,-25,-30,-5,-15,-30,-5,-15,15,-5,-10,20,-5
	dc.w	15,20,-5,15,-30,-5,25,-30,-5,25,30,-5,-20,30,-5
	dc.w	-25,25,-5
union_lin	dc.w	0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,0
	dc.w	10,11,11,12,12,13,13,14,14,15,15,16,16,17
	dc.w	17,18,18,19,19,10
	dc.w	0,10,1,11,2,12,3,13,4,14,5,15,6,16,7,17,8,18
	dc.w	9,19
	dc.w	$ffff	
* Diamant
dia_pts	equ	10
diam_coo	dc.w	-20,0,-20,-30,0,0,-20,0,20
	dc.w	0,0,30,20,0,20,30,0,0,20,0,-20
	dc.w	0,0,-30,0,30,0,0,-20,0
diam_lin	dc.w	0,1
	dc.w	1,2,2,3,3,4,4,5,5,6,6,7,7,0
	dc.w	8,0,8,1,8,2,8,3,8,4,8,5,8,6,8,7
	dc.w	9,0,9,1,9,2,9,3,9,4,9,5,9,6,9,7
	dc.w	$ffff

* Logo Replicants	
repli_pts	equ	38
repli_sha	dc.w	-65,10,0,-65,0,0,-65,-10,0,-55,-5,0,-55,10,0	* R
	dc.w	-45,10,0,-55,0,0,-45,-10,0,-45,0,0		* E
	dc.w	-40,10,0,-40,0,0,-40,-10,0,-30,-5,0		* P
	dc.w	-25,10,0,-25,-10,0,-15,10,0		* L
	dc.w	-10,10,0,-10,-10,0			* I
	dc.w	5,10,0,-5,0,0,5,-10,0			* C
	dc.w	10,10,0,12,0,0,15,-10,0,17,0,0,20,10,0	* A
	dc.w	25,10,0,25,-10,0,35,10,0,35,-10,0		* N
	dc.w	45,10,0,40,-10,0,45,-10,0,50,-10,0		* T
	dc.w	50,10,0,60,0,0,50,-5,0,60,-10,0		* S
repli_lin	dc.w	0,2,2,3,3,1,1,4	* R
	dc.w	5,6,6,7,6,8		* E
	dc.w	9,11,11,12,12,10	* P
	dc.w	13,14,13,15		* L
	dc.w	16,17		* I
	dc.w	18,19,19,20		* C
	dc.w	21,23,23,25,22,24	* A
	dc.w	26,27,27,28,28,29	* N
	dc.w	30,32,31,33		* T
	dc.w	34,35,35,36,36,37	* S
	dc.w	$ffff
		
user_coo	dcb.w	3*256,0

user_lin	dc.w	0,1
	dc.w	$ffff
	dcb.w	2*256,0
	
	dcb.w	50,-160
multab	
gizi	set	0
	rept	200
	dc.w	gizi*160
gizi	set	gizi+1
	endr
	dcb.w	50,201*160
	
sintab:	
	dc.w	0,571,1143,1714,2285,2855,3425,3993,4560,5125
	dc.w	5689,6252,6812,7370,7927,8480,9031,9580,10125
	dc.w	10667,11206,11742,12274,12803,13327,13847,14364,14875,15383
	dc.w	15885,16383,16876,17363,17846,18323,18794,19259,19719
	dc.w	20173,20620,21062,21497,21925,22347,22761,23169
	dc.w	23570,23964,24350,24729,25100,25464,25820,26168
	dc.w	26509,26841,27165,27480,27787,28086,28377,28658
	dc.w	28931,29195,29450,29696,29934,30162,30381,30590
	dc.w	30790,30981,31163,31335,31497,31650,31793,31927
	dc.w	32050,32164,32269,32363,32448,32522,32587,32642
	dc.w	32687,32722,32747,32762,32767,32762,32747,32722
	dc.w	32687,32642,32587,32522,32448,32363,32269,32164,32050,31927
	dc.w	31793,31650,31497,31335,31163,30981,30790,30590,30381,30162,29934
	dc.w	29696,29450,29195,28931,28658,28377,28086,27787,27480,27165,26841
	dc.w	26509,26168,25820,25464,25100,24729,24350,23964,23570,23169
	dc.w	22761,22347,21925,21497,21062,20620,20173,19719,19259
	dc.w	18794,18323,17846,17363,16876,16383,15885,15383,14875,14364,13847
	dc.w	13327,12803,12274,11742,11206,10667,10125,9580,9031,8480
	dc.w	7927,7370,6812,6252,5689,5125,4560,3993,3425
	dc.w	2855,2285,1714,1143,571,0,-572,-1144,-1715,-2286
	dc.w	-2856,-3426,-3994,-4561,-5126,-5690,-6253,-6813,-7371,-7928,-8481
	dc.w	-9032,-9581,-10126,-10668,-11207,-11743,-12275,-12804,-13328,-13848,-14365
	dc.w	-14876,-15384,-15886,-16384,-16877,-17364,-17847,-18324,-18795,-19260
	dc.w	-19720,-20174,-20621,-21063,-21498,-21926,-22348,-22762,-23170,-23571
	dc.w	-23965,-24351,-24730,-25101,-25465,-25821,-26169,-26510,-26842,-27166
	dc.w	-27481,-27788,-28087,-28378,-28659,-28932,-29196,-29451,-29697,-29935
	dc.w	-30163,-30382,-30591,-30791,-30982,-31164,-31336,-31498,-31651,-31794,-31928
	dc.w	-32051,-32165,-32270,-32364,-32449,-32523,-32588,-32643,-32688
	dc.w	-32723,-32748,-32763,-32767,-32763,-32748,-32723,-32688,-32643,-32588,-32523
	dc.w	-32449,-32364,-32270,-32165,-32051,-31928,-31794,-31651,-31498,-31336,-31164
	dc.w	-30982,-30791,-30591,-30382,-30163,-29935,-29697,-29451,-29196,-28932,-28659
	dc.w	-28378,-28087,-27788,-27481,-27166,-26842,-26510,-26169,-25821,-25465
	dc.w	-25101,-24730,-24351,-23965,-23571,-23170,-22762,-22348,-21926
	dc.w	-21498,-21063,-20621,-20174,-19720,-19260,-18795,-18324,-17847,-17364
	dc.w	-16877,-16384,-15886,-15384,-14876,-14365,-13848,-13328,-12804,-12275,-11743
	dc.w	-11207,-10668,-10126,-9581,-9032,-8481,-7928,-7371,-6813,-6253,-5690
	dc.w	-5126,-4561,-3994,-3426,-2856,-2286,-1715,-1144,-572
	dc.w	0,571,1143,1714,2285,2855,3425,3993,4560,5125
	dc.w	5689,6252,6812,7370,7927,8480,9031,9580,10125
	dc.w	10667,11206,11742,12274,12803,13327,13847,14364,14875,15383
	dc.w	15885,16383,16876,17363,17846,18323,18794,19259,19719
	dc.w	20173,20620,21062,21497,21925,22347,22761,23169
	dc.w	23570,23964,24350,24729,25100,25464,25820,26168
	dc.w	26509,26841,27165,27480,27787,28086,28377,28658
	dc.w	28931,29195,29450,29696,29934,30162,30381,30590
	dc.w	30790,30981,31163,31335,31497,31650,31793,31927
	dc.w	32050,32164,32269,32363,32448,32522,32587,32642
	dc.w	32687,32722,32747,32762,32767

zak	incbin	"jambala.b"

lettres:	dc.l 	fonts+0  	; A              
        	dc.l 	fonts+1  	; B              
        	dc.l 	fonts+8  	; C              
        	dc.l 	fonts+9  	; D
        	dc.l 	fonts+16  	; E
        	dc.l 	fonts+17  	; F
        	dc.l 	fonts+24  	; G
        	dc.l 	fonts+25  	; H
        	dc.l 	fonts+32  	; I
        	dc.l 	fonts+33  	; J
        	dc.l 	fonts+40  	; K              
        	dc.l 	fonts+41  	; L              
        	dc.l 	fonts+48  	; M              
        	dc.l 	fonts+49  	; N
        	dc.l 	fonts+56  	; O
        	dc.l 	fonts+57  	; P
        	dc.l 	fonts+64  	; Q
        	dc.l 	fonts+65 	; R
        	dc.l 	fonts+72  	; S
        	dc.l 	fonts+73  	; T
        	dc.l 	fonts+80  	; U              
        	dc.l 	fonts+81  	; V              
        	dc.l 	fonts+88  	; W              
        	dc.l 	fonts+89 	; X
        	dc.l 	fonts+96 	; Y
        	dc.l 	fonts+97  	; Z
        	dc.l 	fonts+104  	; 0
        	dc.l 	fonts+105  	; 1
        	dc.l 	fonts+112	 	; 2
        	dc.l 	fonts+113  	; 3
        	dc.l 	fonts+120  	; 4
        	dc.l 	fonts+121  	; 5
        	dc.l 	fonts+128  	; 6
        	dc.l 	fonts+129  	; 7
        	dc.l 	fonts+136  	; 8
        	dc.l 	fonts+137  	; 9
        	dc.l 	fonts+144  	; ,
        	dc.l 	fonts+145  	; -
        	dc.l 	fonts+152  	; .
        	dc.l 	fonts+153		; /
	dc.l 	fonts+7*160+0  	; '              
        	dc.l 	fonts+7*160+1  	; (             
        	dc.l 	fonts+7*160+8 	; )             
        	dc.l 	fonts+7*160+9 	; :
        	dc.l 	fonts+7*160+16 	; ;
        	dc.l 	fonts+7*160+17  	; espace
        
;les codes suivants sont dans l'ordre ASCII mais les nombres
;correspondent a la place qu'occupent les sprites en memoire
;par exemple : le A est le 1er sprite donc il porte le no 0, mais dans
;la table ASCII il occupe la 34e place apres l'ESP

codage: dc.b 45,45               ; code de ESP et !
        dc.b 45,45,45,45,45      ; code de " et de l'autre "(#) et de $%& 
        dc.b 40,41,42            ; code de ' ( )
        dc.b 45,45               ; non definies
        dc.b 36,37               ; code de , -
        dc.b 38                  ; code de .
        dc.b 39
        dc.b 26,27,28,29,30,31,32,33,34,35 ; code des chiffres 0 a 9
        dc.b 43                  ; code de :
        dc.b 45,45,45,45         ; non definies et special R.al('< >')
        dc.b 45,45               ; ? et non def
;34e place:
        dc.b 0,1,2,3,4,5,6,7,8,9,10,11,12            ; code des
        dc.b 13,14,15,16,17,18,19,20,21,22,23,24,25  ; lettres
        dc.b 51              ; fin de chaine

message	DC.B	" THE REPLICANTS 0 1 2 3 4 5 6 7 8 9 / ()-,;:.'"
	DC.B	"["
	even

pici	incbin	"littlefo.pi1"
pic_pal	equ	pici+2
pic_dat	equ	pici+34
fonts	equ	pic_dat+151*160+2

	bss
s_boing	ds.l	1
synchro	ds.w	1
actual_shap	ds.w	256*3
actual_lias	ds.l	1
predef	ds.w	1
wait_key	ds.w	1
choice_pos	ds.w	1
cnt_let	ds.l	1
cnt_scro	ds.l	1
ad_scrol	ds.b	168*7

activ_pan	ds.l	1
bring_pan	ds.w	1
s_vbl	ds.l	1
s_key	ds.l	1

mfpiea	ds.w	1
mfpieb	ds.w	1
mfpima	ds.w	1
mfpimb	ds.w	1
mfptbc	ds.w	1
mfptbd	ds.w	1

logic	ds.l	1
physic	ds.l	1	
s_phys	ds.l	1
s_log	ds.l	1
tab_pos	ds.l	1

Trans_x_sp	ds.w	1
Trans_y_sp	ds.w	1
Trans_z_sp	ds.w	1
translate	ds.w	3
rotates	ds.w	3

mut_x_tab	ds.l	256
mut_y_tab	ds.l	256
mut_z_tab	ds.l	256
mut_x_s	ds.w	1
mut_y_s	ds.w	1
mut_z_s	ds.w	1

mutates	ds.w	3*256
objet	ds.w	3*256
be_drawn	ds.w	2*256
coo_phys	ds.l	10001
coo_log	ds.l	10000