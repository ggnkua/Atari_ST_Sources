******************************************************************
* Demo Delirious IV Avec HardScroll 7 Lignes 
*                     Et Hardscroll 4 Bit Sur Stf / Ste / Mega Ste
*            Avec Recherche de L'Overscan Haut         
*
* Registre Utilise d7/a5-a6
*
* Coded    By Biggles
* Add Code By Still 
* Gfx      By Phan
* Add Gfx  By Jack's Smiley KiKo
* Musaxx   By JSK
******************************************************************
vitesse_telex	equ	5
couleur_telex	equ	$0
fade_in_logo	equ	10
fade_inout_logo	equ	2
fade_in_info	equ	8
fade_in_intro	equ	8
fade_out_logo	equ	3
att_musaxx		equ	270
f_info		equ	400
******************************************************************
	opt	d+

***********
*********** Debut de la Sauvegarde de l'Environnement 
***********

	clr.l	-(sp)		;Passage en Superviseur
	move.w	#$20,-(sp)
	trap	#1
	addq	#6,sp
	move.l	d0,s_ssp

Main	move.w	#$2700,sr		;Coupe les Interruptions

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,s_pal		;Sauve la Palette

	move.l	$44e.w,s_scr	;Sauve Adresse Ecran
	move.b	$44c.w,s_res	;Sauve la Resolution
	move.l	$70.w,s_vbl		;Sauve la VBL
	move.l	$68.w,s_hbl		;Sauve la HBL
	move.l	$120.w,s_timerb	;Sauve la Timer_b

	jsr	save_mfp
	
	sf	$fffffa07.w
	sf	$fffffa09.w		;Coupe Tout

	move.l	#ecran_1+256,d0	;Addresse Ecran 1
	clr.b	d0
	move.l	d0,scr
	move.l	d0,scr+4

	lea	scr,a0		;Met Adresse Ecran_1
	move.b	1(a0),$ffff8201.w	
	move.b	2(a0),$ffff8203.w

	moveq	#6,d0		;Reset Shifter
	move.l	#reset_vbl,$70.w	

reset_s	move.b	#1,$ffff8260.w	;Passe en Moyenne Resolution
	stop	#$2300
	clr.b	$ffff8260.w		;Passe en Basse Resolution
	stop	#$2300
	dbra	d0,reset_s
	clr.b	$ffff8260.w		;Passe en Basse Resolution

***********
*********** Fin de la Sauvegarde de l'Environnement
*********** Debut de l'Initialisation de la Demo
***********

	movem.l	noir,d0-d7
	movem.l	d0-d7,$ffff8240.w	;Palette Noir
	jsr	init_full		;Recherche de L'Over_Haut
	
	jsr	info		;1er  Ecran
	jsr	intro_del_4		;2eme Ecran
	
	movem.l	c_col,d0-d7
	movem.l	d0-d7,$ffff8240.w
	
	moveq	#1,d0		;Init Musique
	jsr	musaxx
	
	move.l	#hard_sinb,add_hard	;Init Deformation
	move.l	#ecran_1,s_scr_4
	move.l	#texte,pos_texte
	move.w	#vitesse_telex,v_telex		
	move.l	#pos_telex,p_telex
	
	jsr	init_plasma
	jsr	init_raster
	jsr	logo

* Init Registre du Full
	lea	$ffff8260.w,a5	;Registre Resolution
	lea	$ffff820a.w,a6	;Registre Syncro
	move.l	#$100,d7

	jsr	init_hardscroll
	jsr	telex

	move.l	#vbl,$70.w		;Installe Nouvelle VBL
	move.l	#full,$120.w	;Installe Fullscreen

	lea	table_origine,a0	;Arriver du Plasma
	lea	color,a1
	lea	fcolor,a4
	lea	fcolor2,a2
	lea	fcolor3,a3
	move.l	#97-1,d2
only_for_fun
	move.b	vsync,d1
.syncro	cmp.b	vsync,d1
	beq.s	.syncro
	move.l	(a0)+,d0
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	move.l	d0,(a3)+
	move.l	d0,(a4)+
	dbra	d2,only_for_fun
	move.b	vsync,d1
.syncro1	cmp.b	vsync,d1
	beq.s	.syncro1
	move.w	(a0)+,d0
	move.w	d0,(a1)+
	move.w	d0,(a2)+
	move.w	d0,(a3)+
	move.w	d0,(a4)+

fade1	move.b	vsync,d1		;Teste de Yamaha
syncro_f1	cmp.b	vsync,d1
	beq.s	syncro_f1
	move.b	#8,$ffff8800.w
	tst.b	$ffff8800.w
	beq.s	fade1

	move.l	#56-1,d0		;MontÇe des Rasters

.m_raster	moveq	#2,d2
.m_raster1	move.b	vsync,d1
.syncro2	cmp.b	vsync,d1
	beq.s	.syncro2
        	dbra	d2,.m_raster1
        	sub.l	#230,auto_raster+2
        	dbra	d0,.m_raster
        
	move.l	#fade_inout_logo,d0	;Arriver du logo
	lea	pal_blanc,a0
	bsr	fade_in
	move.l	#fade_inout_logo,d0
	lea	pal_logo,a0
	bsr	fade_in_out
	
	moveq	#0,d0		;Attente Musique
.att	move.b	vsync,d2
.syncro1	cmp.b	vsync,d2
	beq.s	.syncro1
	addq.l	#1,d0
	cmp.l	#att_musaxx,d0
	bne.s	.att

    	move.b	#4,mk1+5		;Lance le Logo
	move.b	vsync,d2
syncro1	cmp.b	vsync,d2
	beq.s	syncro1
    	move.b	#4,mk+5
        
	clr.b	pause

att	move.b	vsync,d2		;Syncro VBL
syncro	cmp.b	vsync,d2
	beq.s	syncro

***********	Saut Programme

	
	move.b	$fffffc02.w,d0	;Recupere caractere
	cmp.b	tpre,d0
	beq.s	att
	move.b	d0,tpre
	
	cmp.b	#$99,d0		;Gestion de la Pause
	bne	.s1
	
	tst.b	pause
	bne.s	.s2
	move.b	#1,pause		;Pause
	move.b	#0,au_p1+3		;Plasma
	move.b	#0,au_p2+3
	move.b	#$32,au_p3
	move.b	#0,au_raster+3	;Raster
	move.b	#0,au_telex1+3	;Telex
	move.b	#0,au_telex2+3
	move.b	#0,au_telex3+3
    	move.b	#0,mk1+5		;Logo
	move.b	vsync,d2
.syncro	cmp.b	vsync,d2
	beq.s	.syncro
    	move.b	#0,mk+5
	
	bra.s	.s1
.s2	clr.b	pause		;Pas Pause
	move.b	#2,au_p1+3		;Plasma
	move.b	#2,au_p2+3
	move.b	#$30,au_p3
	move.b	#6,au_raster+3	;Raster
	move.b	#1,au_telex1+3	;Telex
	move.b	#2,au_telex2+3
	move.b	#2,au_telex3+3
    	move.b	#4,mk1+5		;Logo
	move.b	vsync,d2
.syncro1	cmp.b	vsync,d2
	beq.s	.syncro1	
    	move.b	#4,mk+5
	
.s1	cmp.b	#$b9,d0		;Sortie ?
	bne	att

				;Enleve la Pause si elle y est
	move.b	#2,au_p1+3		;Plasma
	move.b	#2,au_p2+3
	move.b	#$30,au_p3
	move.b	#6,au_raster+3	;Raster
	move.b	#1,au_telex1+3	;Telex
	move.b	#2,au_telex2+3
	move.b	#2,au_telex3+3
    	move.b	#4,mk1+5		;Logo
	move.b	vsync,d2
.syncro3	cmp.b	vsync,d2
	beq.s	.syncro3	
    	move.b	#4,mk+5

	move.l	#texte_vide,au_telex+2	;Efface le Scroll
	move.w	#2,au_vitesse2+2
	move.l	#texte_vide,pos_texte
	
	lea	pal_logo,a0		;Fade In sur le logo
	move.l	#fade_in_logo,d0
	bsr	fade_out 
	
	move.l	#56-1,d0		;Descente des Rasters

.m_raster	moveq	#2,d2
.m_raster1	move.b	vsync,d1
.syncro2	cmp.b	vsync,d1
	beq.s	.syncro2
        	dbra	d2,.m_raster1
        	move.l	scr_4_bit,a0
        	add.l	auto_raster+2,a0
        	movem.l	lblanc,d3-d6/a1-a4
	movem.l	d3-6,-14(a0)
x	set	0
	rept	7
        	movem.l	d3-d6/a1-a4,x(a0)
x	set	x+32
	endr
        	movem.l	d3-d6/a1,x(a0)
        	add.l	#230,auto_raster+2
        	dbra	d0,.m_raster

	lea	color,a0		;Enleve le Plasma
	lea	fcolor,a1
	lea	fcolor,a4
	lea	fcolor2,a2
	lea	fcolor3,a3
	moveq	#0,d0
burp	move.b	vsync,d1
.syncro	cmp.b	vsync,d1
	beq.s	.syncro
	move.l	d0,(a0)+
	move.l	d0,(a2)+
	move.l	d0,(a3)+
	move.l	d0,(a4)+
	cmp.l	a0,a1
	bge.s	burp
	
	move.w	#$777,auto_col+2	;Met message de fin
	move.l	#pos_telex,p_telex
	move.l	#texte_end,pos_texte
	move.w	#$23fc,au_telex4
	move.l	#texte_end,au_telex4+2
	move.l	#pos_texte,au_telex4+6

	move.w	#300,d0		;Attend pour le lire
just_for_fun
	move.b	vsync,d1
.syncro	cmp.b	vsync,d1
	beq.s	.syncro
	dbra	d0,just_for_fun

	move.l	#7-1,d2		;Fade sur le logo
fade_logo	move.w	#fade_out_logo,d0
just_for_fun1
	move.b	vsync,d1
.syncro	cmp.b	vsync,d1
	beq.s	.syncro
	dbra	d0,just_for_fun1
	sub.w	#$0111,auto_col+2
	dbra	d2,fade_logo

	move.w	#25,d0		;Petit Attente
just_for_fun2
	move.b	vsync,d1
.syncro	cmp.b	vsync,d1
	beq.s	.syncro
	dbra	d0,just_for_fun2

***********	
*********** Debut de la Restitution de l'Environnement
***********

restitution	move.w	#$2700,sr		;Coupe les Interruptions

	move.l	#$8080000,$ffff8800.w	;Reset Yamaha
	move.l	#$9090000,$ffff8800.w
	move.l	#$a0a0000,$ffff8800.w

	move.l	s_hbl,$68.w		;Remet Ancienne HBL
	move.l	s_timerb,$120.w	;Remet Ancien Timer_b 

	jsr	restore_mfp

	lea	s_scr,a0		;Remet Adresse Ecran
	move.b	1(a0),$ffff8201.w	
	move.b	2(a0),$ffff8203.w

	moveq	#6,d0		;Reset Shifter
	move.l	#reset_vbl,$70.w

reset_s_1	clr.b	$ffff8260.w		;Passe en Basse Resolution
	stop	#$2300
	move.b	s_res,$ffff8260.w	;Remet Ancienne Resolution
	stop	#$2300
	dbra	d0,reset_s_1
	move.b	s_res,$ffff8260.w	;Remet Ancienne Resolution

	move.l	s_vbl,$70.w		;Remet Ancienne VBL
	
	movem.l	s_pal,d0-d7		;Remet Ancienne Palette
	movem.l	d0-d7,$ffff8240.w

	move.l	s_ssp,-(sp)		;Retour Utilisateur
	move.w	#$20,-(sp)
	trap	#1
	addq	#6,sp

	clr.w	-(sp)		;Bye
	trap	#1

reset_vbl	rte

***********
*********** Fin de la Restitution de l'environnement
*********** Debut des Routines de la Demo
***********

vbl	sf	$fffffa1b.w		;On Coupe
mm2	move.b	#$0,$fffffa21.w	;Data Register
	move.l	#full,$120.w	;Remet Full
	move.b	#4,$fffffa1b.w	;Mode Delai,50 Pre_division
				;Le Full est Lance
	
	movem.l	d0-a6,-(sp)		;Sauve les Registres

	jsr	musaxx+8		;Joue Musique

	jsr	gest_4_bit
	jsr	trans_telex
	jsr	telex
	
	not.b	vsync		;Syncronisation
	
	movem.l	(sp)+,d0-a6		;Restitue les Registres

	rte

init_full	sf	$fffffa1b.w		;Timer Stoppe
	ori.b	#1,$fffffa07.w	;IERA
	ori.b	#1,$fffffa0f.w	;ISRA
	ori.b	#1,$fffffa13.w	;IMRA
	
	move.l	#vbl_init,$70.w
	move.l	#hbl_init,$68.w
	move.l	#timerb_init,$120.w
	
.att	cmp.w	#1,trouve
	bne.s	.att

	sf	$fffffa1b.w
	move.l	#fin,$70.w
	move.l	#fin1,$120.w
	move.b	mm1+3,mm2+3
	addq.b	#1,mm2+3		;A Tester
	
	rts

trouve	dc.w	0
		
fin1	bclr	#0,$fffffa0f.w	
fin	rte	

vbl_init	sf	$fffffa1b.w		;On Coupe
mm1	move.b	#$10,$fffffa21.w	;Data Register
	move.l	#timerb_init,$120.w
	move.b	#4,$fffffa1b.w	;Mode Delai,50 Pre_division
	
	rte

timerb_init	move.w	#$2100,sr
	sf	$fffffa1b.w
	stop	#$2100		;2 Raster_lignes 
	movem.l	d0-a6,-(sp)
	stop	#$2100		;Pour la Syncro
		
	move.w	#$2700,sr		;On Coupe Tout
	
	movem.l	noir,d0-d7
	movem.l	d0-d7,$ffff8240.w	;40
	
	moveq	#8,d2
.att1	dbra	d2,.att1
	moveq	#10,d2
	
	move.b	#0,$ffff820a.w	;60Hz
.att2	dbra	d2,.att2	;Tempo
	move.b	#2,$ffff820a.w	;50Hz
	
	moveq	#15,d2
.att	dbra	d2,.att
	
	tst.b	$ffff8209.w
	bne.s	.h2
	addq.b	#1,mm1+3
	movem.l	(sp)+,d0-a6
	bclr	#0,$fffffa0f.w
	rte

.h2	move.w	#1,trouve
	movem.l	(sp)+,d0-a6
	bclr	#0,$fffffa0f.w
	rte

hbl_init	rte

full	move.w	#$2100,sr
	sf	$fffffa1b.w
	stop	#$2100		;2 Raster_lignes 
	movem.l	d0-a6,-(sp)
	stop	#$2100		;Pour la Syncro
		
	move.w	#$2700,sr		;On Coupe Tout
	
	movem.l	noir,d0-d5/a0-a1
	movem.l	d0-d5/a0-a1,$ffff8240.w	;40
	
	moveq	#8,d2
.att1	dbra	d2,.att1
	moveq	#10,d2

	move.b	#0,$ffff820a.w	;60Hz
.att2	dbra	d2,.att2	;Tempo
	move.b	#2,$ffff820a.w	;50Hz

.syncro	move.b	$ffff8209.w,d2
	beq.s	.syncro
	neg	d2
	lsr	d2,d2
	
	lea	ligne_230,a0
	move.l	add_table,a1	;8
	
	rept	73-8-2-6
	nop
	endr

	move.w	(a1)+,d0		;2
	jsr	(a0,d0.w)		;6	;rts 4
	
	move.w	(a1)+,d0		;2
	jsr	(a0,d0.w)		;6	;rts 4
	
	move.w	(a1)+,d0		;2
	jsr	(a0,d0.w)		;6	;rts 4
	
	move.w	(a1)+,d0		;2
	jsr	(a0,d0.w)		;6	;rts 4
	
	move.w	(a1)+,d0		;2
	jsr	(a0,d0.w)		;6	;rts 4
	
	move.w	(a1)+,d0		;2
	jsr	(a0,d0.w)		;6	;rts 4
	
	move.w	(a1)+,d0		;2
	jsr	(a0,d0.w)		;6	;rts 4
	
	rept	8-4
	nop
	endr
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution
	
	movem.l	b_col,d0-d5/a0-a1
	movem.l	d0-d5/a0-a1,$ffff8240.w	;40
	
auto_col	move.w	#couleur_telex,$ffff8242.w	;4
	move.w	d0,au_col+2			;4
	rept	41
	nop
	endr						 
	
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a6)	; 50 hz	
	
	rept	13
	nop
	endr
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	rept	12-1
	nop
	endr
	moveq	#0,d0		;1

plasma	move.l	addcol,a2		;5	;25
au_p1	lea	2(a2),a2		;2
	cmp.l	#fcolor,a2		;4
	blt.s	.f2		;3 si Fait Sinon 2
	lea	color,a2		;3
	bra.s	.f1		;2	
.f2	rept	6
	nop
	endr
.f1	move.l	a2,addcol		;6

	move.l	addsin_1,a0		;5	;25
au_p2	lea	2(a0),a0		;2
	cmp.l	#fsin_1,a0		;4
	blt.s	.s2		;3/2
	lea	sin_1,a0		;3
	bra.s	.s1		;2
.s2	rept	6
	nop
	endr		
.s1	move.l	a0,addsin_1		;6
	
	move.l	addsin,a0		;5	;34
	move.l	addsin_1,a1		;5
au_p3	move.w	(a1),d0		;2
	lea	(a0,d0.w),a0	;4
	cmp.l	#fsin,a0		;4
	blt.s	.s3		;3/2
	lea	sin,a0		;3
	bra.s	.s4		;2
.s3	rept	6
	nop
	endr	
.s4	move.l	a0,addsin		;6
	
	lea	$ffff8240.w,a0	;2
	move.l	a2,a1		;1
	move.l	addsin,a3		;5
	moveq	#30-1,d0		;1

	rept	34
	nop
	endr
	
.pla	rept	38
	move.w	(a2)+,(a0)		;3 nops
	endr
	move.w	(a3),d1		;2
	lea	2(a1),a1		;2
	lea	8(a3),a3		;2
	lea	(a1,d1.w),a2	;4
	nop
	dbra	d0,.pla		;3
	move.w	#0,(a0)		;3

au_col	move.w	#$0,$ffff8242.w	;4

raster_verticaux
*
*	2 Lignes Apres le Plasma Ne Sont Pas En Hard 4 Bit
*
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution
	
	move.l	addsinras,a0	;5	;24
au_raster	lea	6(a0),a0		;2
	cmp.l	#f_sinras,a0	;4
	blt.s	.f2		;3 si Fait Sinon 2
	lea	sin_rast,a0		;3
	bra.s	.f1		;2	
.f2	rept	6
	nop
	endr
.f1	move.l	a0,addsinras	;6

	move.l	scr_4_bit,a0
auto_raster	add.l	#57*160+160*230+56*230,a0
	movem.l	lblanc,d0-d6/a1-a4	;36
	
	movem.l	d0-d6/a1-a4,(a0)	;24
	
	nop
	nop
	nop
	nop
	nop
							 
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a6)	; 50 hz	
	
	movem.l	d0-d4,44(a0)	;13
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	movem.l	d5-d6/a1-a2,64(a0)	;11
	nop

	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution
	
	movem.l	a3-a4,80(a0)	;7
	
	movem.l	d0-d6/a1-a4,88(a0)	;82
	movem.l	d0-d6/a1-a4,132(a0)
	movem.l	d0-d6/a1-a4,176(a0)
	movem.l	d0-d1,220(a0)
							 
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a6)	; 50 hz	
	
	lea	ve_rast,a1
	lea	me_rast,a2
	move.l	addsinras,a3	;11
	
	nop
	nop
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	movem.l	d0-d1,-8(a0)	;7 ;enleve decalage adresse ecran	
	nop		

	move.l	#26-1,d0		;3 ;171 lignes
	
	
bit	* debut ligne
	nop
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

m_4_bit	nop
	nop
	nop
	nop
	nop		
	
	move.l	d0,-(sp)		:3
	
	move.l	(a3),d0		;Recupere pos		
	lea	(a0,d0.l),a4	;Calcul pos ecran
	
	move.w	4(a3),d4		;10

	lea	6*3(a3),a3
	
	movem.l	(a1,d4.w),d0-d3	;Recupere Sprite
	movem.l	(a2,d4.w),d4-d7	;Recupere Mask
	and.l	d4,(a4)
	or.l	d0,(a4)+
	and.w	d5,(a4)
	or.w	d1,(a4)
	lea	4(a4),a4
	and.l	d6,(a4)
	or.l	d2,(a4)+
	and.w	d7,(a4)
	or.w	d3,(a4)		
	
	move.l	#$100,d7		;65
	
	nop
	nop
	nop
	nop
							 
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a6)	; 50 hz	
	
	nop		; 13 nops
	nop		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	nop		; 11 nops
	nop		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	
	include	4_bit_ra.s


	move.l	(sp)+,d0		;3
	dbra	d0,bit		;3 nop
	
 	* debut ligne

ent_p_droite
	moveq	#0,d0
	move.l	deca_logo,d0
	and.w	#%1111111111111000,d0
	lea	mulu_1200,a0
	move.l	(a0,d0.l),d0	;d0*1200
	lea	pic,a1
	add.l	d0,a1
	move.l	scr_4,d0
	and.w	#$fff8,d0
	move.l	d0,a0
	lea	160*31+230*5+16(a0),a0
	
	lea	27*1200-1200(a1),a3
	lea	216-8(a0),a2
	movem.l	a2-3,ras_save	;12	
	
	movem.l	(a1)+,d0-6/a2-a4
	movem.l	d0-d1,(a0)
	movem.l	d2-3,230(a0)
	movem.l	d4-d5,460(a0)
	movem.l	d6/a2,690(a0)
	movem.l	a3-4,920(a0)	;59
	lea	1150(a0),a0
	
	rept	29
	movem.l	(a1)+,d0-6/a2-a4
	movem.l	d0-d1,(a0)
	movem.l	d2-3,230(a0)
	movem.l	d4-d5,460(a0)
	movem.l	d6/a2,690(a0)
	movem.l	a3-4,920(a0)	;59
	lea	1150(a0),a0
	endr
	
	movem.l	pal_rast,d0-d3
	movem.l	d0-d3,$ffff8240.w	;24

eff_p_droite
	move.l	scr_4,d0
	and.w	#$fff8,d0
	move.l	d0,a0
	lea	160*31+230*5+8(a0),a0
	movem.l	lblanc,d0-6/a1-4	;34

	movem.l	d0-d1,(a0)		
	movem.l	d2-d3,230(a0)
	movem.l	d4-d5,460(a0)
	movem.l	d6/a1,690(a0)
	movem.l	a1-a2,920(a0)
	movem.l	a3-a4,1150(a0)
	lea	1380(a0),a0		;43

	rept	3
	nop
	endr
	
	* 1er changement de frequence pour le bas
	* le prochain sera 15 lignes plus loin
	
	* debut ligne
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution
	
	rept	2
	movem.l	d0-d1,(a0)		
	movem.l	d2-d3,230(a0)
	movem.l	d4-d5,460(a0)
	movem.l	d6/a1,690(a0)
	movem.l	a1-a2,920(a0)
	movem.l	a3-a4,1150(a0)
	lea	1380(a0),a0		;43

	endr
	
	rept	3
	nop
	endr
	
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a6)	; 50 hz	
	
	rept	11
	nop
	endr
	
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution
	
	rept	11
	nop
	endr
	
	* fin ligne

	* debut ligne
	
	move.w	a5,(a5)	; haute resolution
	move.w	a5,(a6)	; 50 hz	
	move.b	d7,(a5)	; basse resolution

	rept	2
	movem.l	d0-d1,(a0)		
	movem.l	d2-d3,230(a0)
	movem.l	d4-d5,460(a0)
	movem.l	d6/a1,690(a0)
	movem.l	a1-a2,920(a0)
	movem.l	a3-a4,1150(a0)
	lea	1380(a0),a0		;43

	endr
	
	rept	3
	nop
	endr
	
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a6)	; 50 hz	
	
	nop		; 13 nops
	nop		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	nop		; 12 nops
	nop		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	* fin ligne
	
	rept	20		
	movem.l	d0-d1,(a0)		
	movem.l	d2-d3,230(a0)
	movem.l	d4-d5,460(a0)
	movem.l	d6/a1,690(a0)
	movem.l	a1-a2,920(a0)
	movem.l	a3-a4,1150(a0)
	lea	1380(a0),a0		;43
	endr
	
	movem.l	ras_save,a0-a1		;9	
	
	rept	11
	movem.l	(a1)+,d2-6/a2-a4
	movem.l	d2-3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	d6/a2,460(a0)
	movem.l	a3-4,690(a0)	;48
	lea	920(a0),a0
	endr
	
	rept	11		;7 lignes
	nop
	endr

	
	rept	3

 	* debut ligne
 	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution
	
	movem.l	(a1)+,d2-6/a2-a4
	movem.l	d2-3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	d6/a2,460(a0)
	movem.l	a3-4,690(a0)	;48
	lea	920(a0),a0
	
	movem.l	(a1)+,d2-6/a2-a4
	movem.l	d2-3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	d6/a2,460(a0)	;39
	
	nop
	nop
					 
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a6)	; 50 hz	
	
	movem.l	a3-4,690(a0)	;9
	lea	920(a0),a0
	
	nop
	nop
	nop
	nop
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	nop		; 12 nops
	nop		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	* fin ligne
	
	endr
	
	* 2eme changement de frequence pour le bas

	* debut ligne
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	movem.l	(a1)+,d2-6/a2-a4
	movem.l	d2-3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	d6/a2,460(a0)
	movem.l	a3-4,690(a0)	;48
	lea	920(a0),a0
	
	movem.l	(a1)+,d2-6/a2-a4
	movem.l	d2-3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	d6/a2,460(a0)	;39
	
	nop
	nop
						 
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a6)	; 50 hz	
	
	movem.l	a3-4,690(a0)	;9
	lea	920(a0),a0
	nop
	nop
	
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution
	
	nop		; 11 nops
	nop		
	nop		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	* fin ligne

	* debut ligne
	
	move.w	a5,(a5)	; haute resolution
	move.w	a5,(a6)	; 50 hz	
	move.b	d7,(a5)	; basse resolution
	
	movem.l	(a1)+,d2-6/a2-a4
	movem.l	d2-3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	d6/a2,460(a0)
	movem.l	a3-4,690(a0)	;48
	lea	920(a0),a0
	
	movem.l	(a1)+,d2-6/a2-a4
	movem.l	d2-3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	d6/a2,460(a0)	;39
	
	nop
	nop
	
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a6)	; 50 hz	
	
	movem.l	a3-4,690(a0)	;9
	lea	920(a0),a0
	nop
	nop
	nop
	nop
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution 
	
	nop		; 12 nops
	nop		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	* fin ligne

	rept	7

 	* debut ligne
 	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution
	
	movem.l	(a1)+,d2-6/a2-a4
	movem.l	d2-3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	d6/a2,460(a0)
	movem.l	a3-4,690(a0)	;48
	lea	920(a0),a0
	
	movem.l	(a1)+,d2-6/a2-a4
	movem.l	d2-3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	d6/a2,460(a0)	;39
	
	nop
	nop
					 
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a6)	; 50 hz	
	
	movem.l	a3-4,690(a0)	;9
	lea	920(a0),a0
	
	nop
	nop
	nop
	nop
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	nop		; 12 nops
	nop		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	* fin ligne
	
	endr
	
	* debut ligne
 	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution
	
	movem.l	(a1)+,d2-6/a2-a4
	movem.l	d2-3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	d6/a2,460(a0)
	movem.l	a3-4,690(a0)	;48
	lea	920(a0),a0
	
	movem.l	(a1)+,d2-6/a2-a4
	movem.l	d2-3,(a0)
	movem.l	d4-d5,230(a0)
	movem.l	d6/a2,460(a0)	;39
	
	nop
	nop
					 
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a6)	; 50 hz	
	
	movem.l	a3-4,690(a0)	;9
	lea	920(a0),a0
	
	nop
	nop
	nop
	nop
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	movem.l	telex_save,a0-a1	;9
	lea	pos_telex,a2

	* fin ligne
	
	rept	21

	* debut ligne

	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	move.w	(a2),d0
	addq.l	#4,a2
	lea	(a0,d0.w),a4
	lea	(a1,d0.w),a3
x	set	0
	move.w	x(a3),x(a4)
	clr.w	x(a3)
x	set	x+160
	move.w	x(a3),x(a4)
	clr.w	x(a3)
x	set	x+160
	move.w	x(a3),x(a4)
	clr.w	x(a3)
x	set	x+160
	move.w	x(a3),x(a4)
	clr.w	x(a3)
x	set	x+160
	move.w	x(a3),x(a4)
	clr.w	x(a3)
x	set	x+160
	move.w	x(a3),x(a4)
	clr.w	x(a3)
x	set	x+160
	move.w	x(a3),x(a4)
	clr.w	x(a3)
x	set	x+160
	move.w	x(a3),x(a4)
	clr.w	x(a3)
x	set	x+160		;84

	nop
	nop
	nop
	nop
	nop
							 
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a6)	; 50 hz	
	
	nop		; 13 nops
	nop		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution 

	nop		; 12 nops
	nop		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	* fin ligne
	
	endr
	
	rept	1

	* debut ligne

	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution
	
	move.l	scr_4,d0
	and.w	#$fff8,d0
	move.l	d0,a0
	lea	160*31+230*5+2(a0),a0	;9

	movem.l	lblanc,d0-6/a1-4	;36
	movem.l	d0-d1,(a0)		
	movem.l	d2-d3,230(a0)
	movem.l	d4-d5,460(a0)
	movem.l	d6/a1,690(a0)
	movem.l	a1-a2,920(a0)
	movem.l	a3-a4,1150(a0)
	lea	1380(a0),a0		;43
	*nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
							 
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a6)	; 50 hz	
	
	nop		; 13 nops
	nop		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution 

	nop		; 12 nops
	nop		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	* fin ligne
	
	endr

	rept	12

	* debut ligne

	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution
	
	movem.l	d0-d1,(a0)		
	movem.l	d2-d3,230(a0)
	movem.l	d4-d5,460(a0)
	movem.l	d6/a1,690(a0)
	movem.l	a1-a2,920(a0)
	movem.l	a3-a4,1150(a0)
	lea	1380(a0),a0		;43
	movem.l	d0-d1,(a0)		
	movem.l	d2-d3,230(a0)
	movem.l	d4-d5,460(a0)
	movem.l	d6/a1,690(a0)
	movem.l	a1-a2,920(a0)
	movem.l	a3-a4,1150(a0)
	lea	1380(a0),a0		;43
	nop
	nop
	nop
							 
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a6)	; 50 hz	
	
	nop		; 13 nops
	nop		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution 

	nop		; 12 nops
	nop		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	* fin ligne
	
	endr

	rept	2

	* debut ligne

	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	move.l	#27,d0	;3	;89 nops
	dc.l	$51c8fffe	;27*3
	nop		;4+1
							 
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a6)	; 50 hz	
	
	nop		; 13 nops
	nop		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution 

	nop		; 12 nops
	nop		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	* fin ligne
	
	endr


	jsr	gest_hardscroll
	
	movem.l	(sp)+,d0-a6
	
	bclr	#0,$fffffa0f.w
	rte

ligne_230	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	rept	89
	nop
	endr
	
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a6)	; 50 hz	
	
	rept	13
	nop
	endr
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	rts

ligne_204	rept	94
	nop
	endr

	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a6)	; 50 hz	
	
	rept	13
	nop
	endr
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	rts

ligne_184	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	rept	88
	nop
	endr
	
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a6)	; 50 hz	
	
	rept	14
	nop
	endr
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	rts

ligne_160	rept	116
	nop
	endr
	
	rts
	
ligne_158	rept	52
	nop
	endr
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution
	
	
	rept	36
	nop
	endr
	
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a6)	; 50 hz	
	
	rept	19
	nop
	endr
	
	rts


ligne_80	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	rept	35
	nop
	endr
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	rept	71
	nop
	endr

	rts

ligne_54	rept	28
	nop
	endr
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	rept	7
	nop
	endr

	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	rept	66+5
	nop
	endr
	

	rts
	
logo	moveq	#0,d0
	lea	hard_sin,a0
	move.w	(a0),d0
	and.w	#%1111111111111000,d0
	move.l	d0,d1
	lea	mulu_1200,a0
	move.l	(a0,d0.l),d0	;d0*1200
	lea	pic,a2
	add.l	d0,a2
	sub.l	#1200*2,a2
	
	move.l	scr,a1
	lea	160*31+230*5(a1),a1
	add.l	d1,a1
	move.l	a1,a4
	move.l	#28-1,d0
.fill	move.l	#150-1,d1
.fill1	move.l	(a2)+,(a4)
	move.l	(a2)+,4(a4)
	lea	230(a4),a4
	dbf	d1,.fill1
	lea	8(a1),a1
	move.l	a1,a4
	dbf	d0,.fill

	rts

trans_telex	
	move.l	scr_4,a0
	lea	160*2+56(a0),a0
	move.l	s_scr_4,a1
	move.l	a0,s_scr_4
	cmp.l	a0,a1
	bne.s	.t1
	move.l	#f_ecran,a1
	move.l	a1,a0
.t1	movem.l	a0-a1,telex_save


	rts

telex	subq	#1,v_telex
	bne	ft
au_vitesse2	move.w	#vitesse_telex,v_telex

	move.l	p_telex,a2		;Recherche Position
	move.w	(a2),d0
au_telex2	lea	2(a2),a2
	cmp.w	#$ffff,d0
	bne.s	t2
	lea	pos_telex,a2
au_telex4	nop
	nop
	nop
	nop
	nop
	move.w	(a2),d0
au_telex3	lea	2(a2),a2
t2	move.l	a2,p_telex
	move.l	scr_4_bit,a0
	lea	160*2+56(a0),a0
	lea	(a0,d0.w),a0
	
	moveq	#0,d0		;recherche lettre
	move.l	pos_texte,a2
	move.b	(a2),d0
au_telex1	lea	1(a2),a2
	cmp.b	#$ff,d0
	bne.s	t1
au_telex	lea	texte,a2
	move.b	(a2)+,d0
t1	move.l	a2,pos_texte
	lsl	#3,d0
	lea	font_telex,a1
	lea	(a1,d0.w),a1

	
x	set	0
	rept	8
	move.b	(a1)+,x(a0)
x	set	x+160
	endr	
	
ft	rts

gest_hardscroll
	
	move.l	add_hard,a0
mk	add.l	#0,a0
	cmp.l	#f_hard_sin,a0
	ble.s	.s
	lea	hard_sin,a0
.s	move.l	a0,add_hard
	
	move.l	scr,d0		;Recupere Adresse Ecran 
	move.l	d0,d2
	add.w	(a0),d0
	move.l	d0,d1
	move.l	d0,scr_4_bit
	
	move.l	add_hard,a0
mk1	add.l	#0,a0
	cmp.l	#f_hard_sin,a0
	ble.s	.s1
	lea	hard_sin,a0
.s1	add.w	(a0),d2
	move.l	d2,scr_4
	moveq	#0,d2
	move.w	(a0),d2
	move.l	d2,deca_logo

	and.l	#$ff,d0		;Recupere Offset	
	add.w	d0,d0		;*2
	lea	mulu_18,a0
	move.w	(a0,d0.w),d0	;d0*18
	lea	table_hard,a0
	lea	(a0,d0.w),a0	;Recherche Bonne Combinaison
		 
	sub.l	(a0)+,d1
	lsr.w	#8,d1
	move.l	d1,$ffff8200.w
	move.l	a0,add_table
	
	rts

gest_4_bit	move.l	scr_4_bit,d2
	and.l	#$6,d2		;Recupere Offset	
	lea	mulu_10,a0
	move.w	(a0,d2.w),d2	;d2*10
	lea	t_4_bit,a0
	lea	(a0,d2.w),a0	;Recherche Bonne Combinaison
	lea	m_4_bit,a1
	lea	m_4_bit1,a2
	lea	m_4_bit2,a3
	lea	m_4_bit3,a4
	lea	m_4_bit4,a5
	
	movem.w	(a0),d0-d4	
	movem.w	d0-d4,(a1)
	movem.w	d0-d4,(a2)
	movem.w	d0-d4,(a3)
	movem.w	d0-d4,(a4)
	movem.w	d0-d4,(a5)
	lea	m_4_bit5,a1
	movem.w	d0-d4,(a1)
	
	rts
		
init_hardscroll
	move.l	#table_hard+4,add_table	;Init HardScroll
	jsr	gest_hardscroll
	
	lea	t_4_bit,a0		;Init 4 Bit
	lea	m_4_bit,a1
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	rts

init_plasma	move.l	#sin,addsin
	move.l	#sin_1,addsin_1
	move.l	#color,addcol

	rts

DECO_RVB	lea     	rvb,a1     
        	moveq   	#$F,d0     
LOOP_RVB
	move.w  	(a0)+,d2   
        	move.w  	d2,d3      
        	and.w   	#$700,d3   
        	lsr.w   	#8,d3      
       	move.w  	d3,(a1)+   
        	move.w  	d2,d3      
        	and.w   	#$070,d3   
        	lsr.w   	#4,d3      
        	move.w  	d3,(a1)+   
        	and.w   	#$007,d2   
        	move.w  	d2,(a1)+   
        	dbra     	d0,LOOP_RVB
        	rts

vbl_info	movem.l	d0-a6,-(sp)
	addq.l	#1,fintro
	not.b	vsync		
	movem.l	b_col,d0-d5/a0-a1
	movem.l	d0-d5/a0-a1,$ffff8240.w	
	movem.l	(sp)+,d0-a6
	rte

vbl_intro	movem.l	d0-a6,-(sp)
	
	movem.l	b_col,d0-d5/a0-a1
	movem.l	d0-d5/a0-a1,$ffff8240.w	
	
	addq.l	#1,fintro
	not.b	vsync		
	
	bsr	eff_pts
	jsr	musaxx_1+8
	
	movem.l	(sp)+,d0-a6
	
f_vbl	rte


intro_del_4	move.l	scr,d0
	lea	image1,a0
	lea	fin_image1,a5
	jsr	depack
	
	moveq	#1,d0		;Init Musique
	jsr	musaxx_1

	move.l	#vbl_intro,$70.w
	
	lea	intro_pal,a0
	move.l	#fade_in_intro,d0
	bsr	fade_in

.att	move.b	$fffffc02.w,d0
	cmp.b	#$b9,d0
	bne.s	.att
	move.b	d0,tpre
	
	lea	intro_pal,a0
	move.l	#fade_in_intro,d0
	bsr	fade_out

	move.b	vsync,d2
.syncro	cmp.b	vsync,d2
	beq.s	.syncro
	
	move.l	#f_vbl,$70.w
	
	move.l	#$8080000,$ffff8800.w	;Reset Yamaha
	move.l	#$9090000,$ffff8800.w
	move.l	#$a0a0000,$ffff8800.w

	move.l	scr,a0
	move.l	#8000-1,d0
.in1	clr.l	(a0)+
	dbra	d0,.in1
	
	rts

info	move.l	#vbl_info,$70.w
	
	move.l	scr,d0
	lea	image,a0
	lea	fin_image,a5
	jsr	depack

	lea	info_palette,a0
	move.l	#fade_in_info,d0
	bsr	fade_in
	
	clr.l	fintro
.att	cmp.l	#f_info,fintro
	bne.s	.att	

	lea	info_palette,a0
	move.l	#fade_in_info,d0
	bsr	fade_out
	
	move.b	vsync,d2
.syncro	cmp.b	vsync,d2
	beq.s	.syncro

	rts

*
* d0 = adr ecran
* a0 = debut image
* a5 = fin image
*
depack	lea	12(a0),a0
	move.l	d0,a4	* d0 = adr. ecran
	move.l	d0,a6
	adda.l	-4(a0),a6
	move.b	-(a5),d7

normal_bytes
	bsr.s	get_1_bit
	bcc.s	test_if_end
	moveq	#0,d1
	bsr.s	get_1_bit
	bcc.s	copy_direkt
	lea	direkt_tab+20,a1
	moveq	#4,d3
nextgb	move.l	-(a1),d0
	bsr.s	get_d0_bits
	swap	d0
	cmp.w	d0,d1
	dbne	d3,nextgb
no_more
	add.l	20(a1),d1
copy_direkt
	move.b	-(a5),-(a6)
	dbf	d1,copy_direkt
test_if_end	
	cmpa.l	a4,a6
	bgt.s	strings

* fin du depacking	
	rts

get_1_bit
	add.b	d7,d7
	bne.s	bitfound
	move.b	-(a5),d7
	addx.b	d7,d7
bitfound
	rts	

get_d0_bits
	moveq	#0,d1
hole_bit_loop	
	add.b	d7,d7
	bne.s	on_d0
	move.b	-(a5),d7
	addx.b	d7,d7
on_d0	addx.w	d1,d1
	dbf	d0,hole_bit_loop
	rts	



strings
	lea	length_tab,a1
	moveq	#3,d2
get_length_bit
	bsr.s	get_1_bit
	dbcc	d2,get_length_bit
no_length_bit	
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	no_Åber
get_Åber
	bsr.s	get_d0_bits
no_Åber
	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	get_offset_2


	lea	more_offset,a1
	moveq	#1,d2
getoffs
	bsr.s	get_1_bit
	dbcc	d2,getoffs
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	get_d0_bits
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	depack_bytes
	sub.w	d4,d1
	bra.s	depack_bytes


get_offset_2
	moveq	#0,d1
	moveq	#5,d0
	moveq	#-1,d2
	bsr.s	get_1_bit
	bcc.s	less_40
	moveq	#8,d0
	moveq	#$3f,d2
less_40
	bsr.s	get_d0_bits
	add.w	d2,d1

depack_bytes
	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
dep_b	move.b	-(a1),-(a6)
	dbf	d4,dep_b
	bra	normal_bytes

*
* d0 = vitesse fade out
* a0 = palette
*
fade_out	move.l	d0,au_vitesse1+2
	lea	rvb,a4
	move.w	#39,d0
.CLEAR	clr.l	(a4)+
	dbra	d0,.CLEAR
	
	bsr   	DECO_RVB

	moveq   	#7,d2         
ALL_COLORS1
       	lea	c_col,a0
        	lea     	rvb,a1    
        	moveq   	#15,d0        
.LOOP_FADING
	cmp.w 	(a1),d2       
        	bne.s  	.NO_ROUGE
        	subq.w  	#1,(a1)       
.NO_ROUGE
	cmp.w   	2(a1),d2      
 	bne.s   	.NO_VERT
        	subq.w  	#1,2(a1)      
.NO_VERT
	cmp.w   	4(a1),d2      
        	bne.S   	.NO_BLEU
        	subq.w  	#1,4(a1)      
.NO_BLEU
	move.w  	(a1)+,d3      
        	lsl.w   	#4,d3         
        	or.w    	(a1)+,d3      
        	lsl.w   	#4,d3         
        	or.w    	(a1)+,d3     
        	move.w  	d3,(a0)+
        	dbra    	d0,.LOOP_FADING

au_vitesse1	move.l	#0,d0
.fade	move.b	vsync,d1
.syncro_f	cmp.b	vsync,d1
	beq.s	.syncro_f
	dbra	d0,.fade

	move.l	d2,-(sp)
	movem.l	c_col,d0-d5/a0-a1
	movem.l	d0-d5/a0-a1,b_col
	move.l	(sp)+,d2
	subq.w	#1,d2
	bne	ALL_COLORS1
	
	rts

*
* d0 = vitesse fade in
* a0 = palette
*
fade_in	move.l	d0,au_vitesse+2
	lea	rvb,a4
	move.w	#55,d1
CLEAR	clr.l	(a4)+
	dbra	d1,CLEAR	
	
	bsr   	DECO_RVB
        	
        	moveq   	#6,d2         
LOOP2	lea	c_col,a0
        	lea     	rvb,a1    
	lea	rvb_ref,a2
	moveq   	#15,d0        
LOOP3	
	move.w	(a1)+,d3
	cmp.w   	(a2),d3
	beq.s   	ROUGE_OK
        	addq.w  	#1,(a2)       
ROUGE_OK
	move.w	(a1)+,d3
	cmp.w   	2(a2),d3
        	beq.s   	VERT_OK
        	addq.w  	#1,2(a2)      
VERT_OK
	move.w	(a1)+,d3
	cmp.w   	4(a2),d3
        	beq.s   	BLEU_OK
        	addq.w  	#1,4(a2)      
BLEU_OK
	move.w  	(a2)+,d3      
        	lsl.w   	#4,d3         
        	or.w    	(a2)+,d3      
        	lsl.w   	#4,d3         
        	or.w    	(a2)+,d3     
        	move.w  	d3,(a0)+
        	dbra    	d0,LOOP3

au_vitesse	move.l	#0,d0
fade	move.b	vsync,d1
syncro_f	cmp.b	vsync,d1
	beq.s	syncro_f
	dbra	d0,fade

	move.l	d2,-(SP)
	movem.l	c_col,d0-d5/a0-a1
	movem.l	d0-d5/a0-a1,b_col
	move.l	(SP)+,d2
	dbra	d2,LOOP2

	rts

*
* d0 = vitesse fade in out
* a0 = palette
*

fade_in_out
	move.l	d0,au_vitesse4+2
	lea	rvb_ref,a1
	moveq	#23,d0
.EffRvb4	
	move.l	#$00070007,(a1)+
	dbra	d0,.EffRvb4
        	BSR     DECO_RVB
        	MOVEQ   #6,D2         
LOOP4	LEA	c_col,A0
        	LEA     	rvb,A1    
	LEA	rvb_ref(PC),A2
        	MOVEQ   #15,D0        
.LOOP3	
	MOVE.W	(A1)+,D3
	CMP.W   (A2),D3
        	BEQ.S   .ROUGE_OK
        	SUBQ.W  #1,(A2)       
.ROUGE_OK
	MOVE.W	(A1)+,D3
	CMP.W   2(A2),D3
        	BEQ.S   .VERT_OK
        	SUBQ.W  #1,2(A2)      
.VERT_OK
	MOVE.W	(A1)+,D3
	CMP.W   4(A2),D3
        	BEQ.S   .BLEU_OK
        	SUBQ.W  #1,4(A2)      
.BLEU_OK
	MOVE.W  (A2)+,D3      
        	LSL.W   #4,D3         
        	OR.W    (A2)+,D3      
        	LSL.W   #4,D3         
        	OR.W    (A2)+,D3     
	MOVE.W  D3,(A0)+
        	DBRA    D0,.LOOP3

au_vitesse4	move.l	#0,d0
fade4	move.b	vsync,d1
syncro_f4	cmp.b	vsync,d1
	beq.s	syncro_f4
	dbra	d0,fade4

	move.l	d2,-(SP)
	movem.l	c_col,d0-d5/a0-a1
	movem.l	d0-d5/a0-a1,b_col
	move.l	(SP)+,d2
	dbra	d2,LOOP4

        	
        	RTS

eff_pts	move.l	#199,d0		nb de pts-1
	lea	eff_tab,a2
	move.l	a2,a1
	move.l	scr,a3
	moveq	#0,d2
	
s1	move.w	(a1)+,d1
	move.w	d2,(a3,d1.w)
	dbra	d0,s1

boule	move.l	#199,d0		nb de pts-1
	lea	cord,a0
	lea	sin_boule+64,a1
	lea	table_160,a4
	lea	line_table,a5
	*lea	eff_tab,a2
	*move.l	scr,a3
	moveq	#9,d6
	
suite	moveq	#0,d1
	moveq	#0,d2
	
	move.w	(a0)+,d1
	ext.l	d1
	move.w	(a0)+,d4
	move.b	1(a0),d2		ang	
	lsl	d2
	addq.w	#2,(a0)+		ang incremente
	move.w	-64(a1,d2.w),d3	z
	move.w	64(a1,d2.w),d2	x
	muls	d4,d2		rayon
	asr.l	d6,d2
	asr.l	d6,d1
	add.w	#159,d2
	add.w	#72,d1
	lsl	d1
	move.w	(a4,d1.w),d1
	lsl	#2,d2
	add.w	(a5,d2.w),d1
	move.w	2(a5,d2.w),d2
	move.w	(a3,d1.w),d7
	and.w	d2,d7
	beq.s	cont
	dbra	d0,suite	(il y avait deja un pt)
	rts
	
cont	tst.w	d3
	bmi.s	bit_plan_2
	or.w	d2,(a3,d1.w)
	move.w	d1,(a2)+
	dbra	d0,suite	
	rts

bit_plan_2	addq.w	#2,d1
	or.w	d2,(a3,d1.w)
	move.w	d1,(a2)+
	dbra	d0,suite	
	rts

init_raster	lea	v_rast,a5
	lea	ve_rast,a6
	bsr	predecale_logo
	lea	m_rast,a5
	lea	me_rast,a6
	bsr	predecale_mask
	move.l	#sin_rast,addsinras
	
	rts

predecale_logo

	clr.l	d4
	clr.l	d5
	clr.l	d6
	clr.l	d7
	
	movem.w	(a5),d0-d3
	
	rept	16
	exg	d2,d3
	exg	d6,d7
	movem.w	d0-d7,(a6)
	exg	d2,d3
	exg	d6,d7
	lea	16(a6),a6
	
	lsr.w	d0
	roxr.w	d4
	lsr.w	d1
	roxr.w	d5
	lsr.w	d2
	roxr.w	d6
	lsr.w	d3
	roxr.w	d7
	
	endr
	
	rts

predecale_mask

	moveq	#-1,d4
	moveq	#-1,d5
	moveq	#-1,d6
	moveq	#-1,d7
	
	rept	16
	exg	d2,d3
	exg	d6,d7
	movem.w	d0-d7,(a6)
	exg	d2,d3
	exg	d6,d7
	lea	16(a6),a6
	
	or.w	#$10,sr
	roxr.w	d0
	roxr.w	d4
	or.w	#$10,sr
	roxr.w	d1
	roxr.w	d5
	or.w	#$10,sr
	roxr.w	d2
	roxr.w	d6
	or.w	#$10,sr
	roxr.w	d3
	roxr.w	d7
	
	endr
	
	rts

* Thanks to Belzebub for the Mfp Registers Save

save_mfp	Lea	$FFFFFA00.w,A0
	Lea	MfpRegisters,A1
	Movep.l	$3(A0),D0
	Move.l	D0,(A1)+
	Movep.w	$13(A0),D0
	Move.w	D0,(A1)+
	Move.b	$19(A0),D0
	Move.b	$1B(A0),D1
	Move.b	$1D(A0),D2
	Moveq	#$1,D3
	Moveq	#$0,D4
	Lea	$1F(A0),A3
	Lea	$19(A0),A2
	Bsr	ReadDataRegister
	Lea	$1B(A0),A2
	Bsr	ReadDataRegister
	Moveq	#$10,D3
	Lea	$1D(A0),A2
	Bsr	ReadDataRegister
	Moveq	#$1,D3
	Bsr	ReadDataRegister
	Move.b	D0,$19(A0)
	Move.b	D1,$1B(A0)
	Move.b	D2,$1D(A0)
	Move.b	D0,(A1)+
	Move.b	D1,(A1)+
	Move.b	D2,(A1)+
	Move.b	$29(A0),(A1)+
	Move.b	$17(A0),(A1)+
	rts
	
ReadDataRegister
	Move.b	D3,(A2)
	Move.b	D4,(A2)
	Cmp.b	#$1,(A3)
	Bne.s	ReadDataRegister
ReadOffsetData
	Move.b	D3,(A2)
	Move.b	D4,(A2)
	Cmp.b	#$1,(A3)
	Beq.s	ReadOffsetData
	Move.b	(A3),(A1)+
	Addq.l	#$2,A3
	Rts
	
restore_mfp	Lea	MfpRegisters,A0
	Lea	$FFFFFA00.w,A1
	Move.l	(A0)+,D0
	Movep.l	D0,$3(A1)
	Move.w	(A0)+,D0
	Movep.w	D0,$13(A1)
	Clr.b	$19(A1)
	Clr.b	$1B(A1)
	Clr.b	$1D(A1)
	Move.l	(A0)+,D0
	Movep.l	D0,$1F(A1)
	Move.b	(A0)+,$19(A1)
	Move.b	(A0)+,$1B(A1)
	Move.b	(A0)+,$1D(A1)
	Move.b	(A0)+,$29(A1)
	Move.b	(A0)+,$17(A1)
	rts

*********** Data

	section	data		

mulu_18	
x	set	0
	rept	256
	dc.w	x
	dc.w	x
x	set	x+18
	endr
	
mulu_10	
x	set	0
	rept	5
	dc.w	x
x	set	x+10
	endr

mulu_1200
x	set	0
	rept	400
	dc.l	x
	dc.l	x
x	set	x+1200
	endr

pos_telex	
x	set	0
	rept	14/2		;nb_lettre/ligne
	dc.w	x
	dc.w	x+1
x	set	x+8
	endr
x	set	160*8+160*2
	rept	14/2		;nb_lettre/ligne
	dc.w	x
	dc.w	x+1
x	set	x+8
	endr
x	set	160*16+160*4
	rept	14/2		;nb_lettre/ligne
	dc.w	x
	dc.w	x+1
x	set	x+8
	endr
	dc.w	$ffff

table_hard	
	incbin	sync.tab
	even
noir	dcb.w	16,0
	even
musaxx	incbin	resetsng.mus
musaxx_1	incbin	mix.mus
	even
pal_logo	
	dc.w	$0000,$0223,$0334,$0445,$0556,$0667,$0012,$0023
	dc.w	$0034,$0044,$0054,$0065,$0202,$0303,$0404,$0505

rvb	dcb.b	96,0
rvb_ref 	dcb.b   	96,0
b_col	dcb.w	16,0
c_col	dcb.w	16,0

pic 	dcb.b	8*150*26,0
	incbin	logo_new.pic
	dcb.b	8*150*28,0
	even
t_4_bit	
	dc.w	$3a87
	dc.w	$4e71
	dc.w	$4e71
	dc.w	$1a87
	dc.w	$4e71
	
	dc.w	$3a87
	dc.w	$4e71
	dc.w	$4e71
	dc.w	$4e71
	dc.w	$1a87
	
	dc.w	$3a87
	dc.w	$1a87
	dc.w	$4e71
	dc.w	$4e71
	dc.w	$4e71
	
	dc.w	$3a87
	dc.w	$4e71
	dc.w	$1a87
	dc.w	$4e71
	dc.w	$4e71

table_origine
	DC.W  $777,$777,$667,$667,$557,$557,$447,$447,$337
	DC.W  $337,$227,$227,$117,$117,$007
 	DC.W  $007,$107,$107,$207,$207,$307,$307,$407,$407
 	DC.W  $507,$507,$607,$607,$707
 	DC.W  $707,$706,$706,$705,$705,$704,$704,$703,$703,$702
 	DC.W  $702,$701,$701,$700
 	DC.W  $700
 	DC.W  $710,$710,$720,$720,$730,$730,$740,$740,$750,$750
 	DC.W  $760,$760,$770
 	DC.W  $770,$670
 	DC.W  $670,$570
 	DC.W  $570,$470,$470,$370,$370,$270,$270,$170,$170,$070
 	DC.W  $070,$071,$071
 	DC.W  $072,$072,$073
 	DC.W  $073,$074,$074,$075,$075,$076,$076,$077
 	DC.W  $077,$177,$177,$277
 	DC.W  $277,$377,$377,$477,$477,$577,$577,$677,$677

color	dcb.w	195,0
fcolor	dcb.w	195,0
fcolor2	dcb.w	195,0
fcolor3	dcb.w	195,0


	dcb.l	10,0 


font_telex	incbin	del4_jsk.fnt
espace	dcb.b	8,0
	even
texte	incbin	texte.tab
	dc.b	$ff
	even
texte_end	incbin	text_end.tab
	dc.b	$ff
	even
texte_vide	dcb.b	14*3*2,$2f
	dc.b	$ff
	even
	rept	5
	incbin	sin.tab
	endr
sin	incbin	sin.tab
fsin	rept	10
	incbin	sin.tab
	endr
	even
sin_1	incbin	sin_1.tab
fsin_1	incbin	sin_1.tab
	even
hard_sinb	*dc.w	$b0
hard_sin	incbin	hard_tst.tab
	dc.w	$b0
f_hard_sin	incbin	hard_tst.tab

intro_pal	dc.w	$0000,$0750,$0740,$0760,$0677,$0566,$0455,$0344
	dc.w	$0773,$0630,$0530,$0320,$0233,$0122,$0011,$0777
info_palette
	dc.w	$0000,$0750,$0740,$0760,$0677,$0566,$0455,$0344
	dc.w	$0773,$0630,$0530,$0320,$0233,$0122,$0011,$0777
	even
pal_ras	dc.w	$0000,$0710,$0720,$0730,$0740,$0750,$0760,$0770
	dc.w	$0210,$0320,$0430,$0540,$0651,$0762,$0774,$0333
	even	
pal_rast	dc.w	$0000,$0000,$0223,$0334,$0445,$0556,$0667,$0777
	*dc.w	$0300,$0410,$0521,$0632,$0743,$0754,$0765,$0776
	even
pal_blanc	dc.w	$0000,$0777
	dcb.w	14,$0777
lblanc	dcb.b	230,0
lblan	dcb.b	230,255
	even

	dc.w	%1100110011001111
	dc.w	%0011110000111100
	dc.w	%0000001111111100
	dc.w	%0000000000000000

v_rast	dc.w	%1100011001100011	;2:3:2:2:2:3:2
	dc.w	%0011111000011111
	dc.w	%0000000111111111
	dc.w	%0000000000000000
	
m_rast	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000

ve_rast	ds.b	16*16
	even
me_rast	ds.b	16*16
	even
sin_rast	incbin	sin_ras1.tab
f_sinras	incbin	sin_ras1.tab

direkt_tab
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001
	dc.l     270-1,	15-1,	 8-1,	 5-1,	 2-1

length_tab
	dc.b 9,1,0,-1,-1
	dc.b 8,4,2,1,0

more_offset
	dc.b	  11,   4,   7,  0
	dc.w	$11f,  -1, $1f

palette	dc.w	$0,$111,$40,$222,$111,$333,$554,$654,$665
	dc.w	$765,$776,$641,$600,$210,$147,$777

image	incbin	first.ice
fin_image
	even
image1	incbin	del4_int.ice
fin_image1
	even
cord	incbin	ang3.tab

line_table
val	set	0
	rept	20
	dc.w	val,%1000000000000000
	dc.w	val,%0100000000000000
	dc.w	val,%0010000000000000
	dc.w	val,%0001000000000000
	dc.w	val,%0000100000000000
	dc.w	val,%0000010000000000
	dc.w	val,%0000001000000000
	dc.w	val,%0000000100000000
	dc.w	val,%0000000010000000
	dc.w	val,%0000000001000000
	dc.w	val,%0000000000100000
	dc.w	val,%0000000000010000
	dc.w	val,%0000000000001000
	dc.w	val,%0000000000000100
	dc.w	val,%0000000000000010
	dc.w	val,%0000000000000001
val	set	val+8
	endr

table_160
val	set	0
	rept	200
	dc.w	val*160
val	set	val+1
	endr

sin_boule	incbin	cos_512.dta
cos_boule	equ	sin_boule+128
	even
	
*********** Bss

	section	bss

addsin	ds.l	1
addsin_1	ds.l	1
addcol	ds.l	1
add_table	ds.l	1
add_hard	ds.l	1
addsinras	ds.l	1
s_scr	ds.l	1
s_pal	ds.l	8
s_vbl	ds.l	1
s_hbl	ds.l	1
s_timerb	ds.l	1
s_ssp	ds.l	1
scr	ds.l	2
scr_4_bit	ds.l	1
scr_4	ds.l	1
s_scr_4	ds.l	1
fintro	ds.l	1
deca_logo	ds.l	1
ras_save	ds.l	2
telex_save	ds.l	2
pos_texte	ds.l	1
p_telex	ds.l	1
	even

p4bit	ds.w	1
v_telex	ds.w	1
eff_tab	ds.w	1000
	even

MfpRegisters
	ds.b	$F
vsync	ds.b	1
s_res	ds.b	1
tempo	ds.b	1
tpre	ds.b	1
pause	ds.b	1
	even
	ds.b	230*5
ecran_1	ds.b	230*273+256
f_ecran	ds.b	230*56

 	end



