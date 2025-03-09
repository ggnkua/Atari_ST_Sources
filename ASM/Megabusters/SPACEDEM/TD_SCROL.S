;	TD_SCROLL
;
;start: 25/03/91
;end  : 05/04/91
;
;	fichier a inclure:	logo2   .inc
;			wave1   .inc
;			wave2   .inc
;			wave3   .inc
;			wave4   .inc
;			wave5   .inc
;			wave9   .inc
;			font3232.inc
;			lapzic  .inc
;
;
;
;
;	code de PrinST
;-------------------------------------
;	constantes systeme
;-------------------------------------
adrhbl = $120
adrvbl = $070

;-------------------------------------
;	macro de copy de ligne
;     horizontal...
; ds a0: adresse depart ligne hz
; ds a1: adresse arrive ligne hz
;-------------------------------------
cpylin	macro
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	endm
;------------------------------------
;	affichage d'une section 
;	de 5 pixels de haut
;a1: adresse sur ecran
;d0-d7 :graph decaler...
;------------------------------------
affspr	macro
	swap	d0
	or	d0,(a1)
	addq.l	#8,a1
	swap	d0
	or	d0,(a1)
	addq.l	#8,a1
	swap	d1
	or	d1,(a1)
	lea	144(a1),a1
	swap	d1
	or	d1,(a1)
	addq.l	#8,a1
	swap	d2
	or	d2,(a1)
	addq.l	#8,a1
	swap	d2
	or	d2,(a1)
	lea	144(a1),a1
	swap	d3
	or	d3,(a1)
	addq.l	#8,a1
	swap	d3
	or	d3,(a1)
	addq.l	#8,a1
	swap	d4
	or	d4,(a1)	
	lea	144(a1),a1
	swap	d4
	or	d4,(a1)
	addq.l	#8,a1
	swap	d5
	or	d5,(a1)
	addq.l	#8,a1
	swap	d5
	or	d5,(a1)
	lea	144(a1),a1
	swap	d6
	or	d6,(a1)
	addq.l	#8,a1
	swap	d6
	or	d6,(a1)
	addq.l	#8,a1
	swap	d7
	or	d7,(a1)
	lea	144(a1),a1
	endm
;------------------------------------
;	affichage d'une boule
;a0:adresse du sprite
;a1:adresse de l'ecran
;d1:decalage pour etre au bon pixel
;------------------------------------
affcar	macro
	lea	adrtab,a3
	lsl.l	#2,d1
	move.l	(a3,d1.w),a3		
	movem.l	d0-d7/a0-a5,-(sp)
	
	movem.l	(a0)+,d0-d7
	clr	d7
	subq.l	#2,a0
	jsr	(a3)
	affspr
	movem.l	(a0)+,d0-d7
	clr	d7
	subq.l	#2,a0
	jsr	(a3)
	affspr
	movem.l	(a0)+,d0-d7
	clr	d7
	subq.l	#2,a0
	jsr	(a3)
	affspr
	movem.l	(a0)+,d0-d7
	clr	d7
	subq.l	#2,a0
	jsr	(a3)
	affspr
	movem.l	(a0)+,d0-d7
	clr	d7
	subq.l	#2,a0
	jsr	(a3)
	affspr
	movem.l	(a0)+,d0-d7
	clr	d7
	subq.l	#2,a0
	jsr	(a3)
	affspr
	movem.l	(sp)+,d0-d7/a0-a5
	endm
;------------------------------------
;	debut du programme...
;------------------------------------
	move	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move	#5,-(sp)
	trap	#14
	add.l	#12,sp
	
	move.l	#programme,-(sp)
	move	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
;------------------------------------
;	fin du programme...
;------------------------------------
	move	#1,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move	#5,-(sp)
	trap	#14
	add.l	#12,sp
	
	clr	-(sp)
	trap	#1
;------------------------------------
;	programme en super user  
;------------------------------------
programme	
;------------------------------------
;     initialisation des donnees
;------------------------------------
;
;	determiner l'adresse ecran
;
	move.l	$ffff8200.w,d0
	lsl	#8,d0
	move.l	d0,adrscr
;
;	init de la zicos...
;
;	moveq	#1,d0
;	jsr	music
;
;	init table de decalage
;	
	lea	adrtab,a0
	move.l	#decal0,(a0)+
	move.l	#decal1,(a0)+
	move.l	#decal2,(a0)+
	move.l	#decal3,(a0)+
	move.l	#decal4,(a0)+
	move.l	#decal5,(a0)+
	move.l	#decal6,(a0)+
	move.l	#decal7,(a0)+	
	move.l	#decal8,(a0)+
	move.l	#decal9,(a0)+
	move.l	#decal10,(a0)+
	move.l	#decal11,(a0)+
	move.l	#decal12,(a0)+
	move.l	#decal13,(a0)+
	move.l	#decal14,(a0)+
	move.l	#decal15,(a0)+
	move	#$2700,sr
;
;	init scrolling
;
	lea	carac,a0
	add.l	#4320*30,a0 
	lea	adrctx,a1
	rept	10
	move.l	a0,(a1)+
	endr
	move.l	#text,adrtxt
;
;	init ecran
;
	move.l	adrscr,a0
	move.l	#3999,d0
eff	clr	(a0)+
	clr	(a0)+
	clr	(a0)+
	clr	(a0)+
	dbra	d0,eff
	lea	$ffff8240.w,a0
	move.l	#$00000777,(a0)+
	move.l	#$00570767,(a0)+
	move.l	#$06560545,(a0)+
	move.l	#$04340777,(a0)+
	move.l	#$00000000,(a0)+
	move.l	#$00000000,(a0)+
	move.l	#$00000000,(a0)+
	move.l	#$00000000,(a0)+
	move.l	adrscr,a0
	lea	graph,a1
	add.l	#48,a0
	move.l	#119,d0
aff	rept	20
	move.l	(a1)+,(a0)+
	endr
	add.l	#80,a0
	dbra	d0,aff
;
;	init interruptions
;
	move.b    $fffa07,v_fffa07
	clr.b     $fffa07
	move.b    $fffa09,v_fffa09
	clr.b     $fffa09
	bset      #0,$fffa07	
	move.b    $fffa13,v_fffa13
	bset      #0,$fffa13	
	move.l    adrhbl,v_120
	move.l    #hbl,adrhbl	 
	move.b    $fffa1b,v_fffa1b
	move.b    #8,$fffa1b	
	move.b    $fffa21,v_fffa21
	move.b    #1,$fffa21	
	move.l    adrvbl,v_70
	move.l    #vbl,adrvbl	  
	move.b	#129,nolin
	move	#$2300,sr
;
;	init table de rasters
;
	lea.l	raster,a6
;
;	init table efface sprite
;
	move.l	#wave1,adrwav
	move.l	#wave1,adrpos
	lea	adrsp1,a0
	move.l	adrscr,(a0)+
	move.l	adrscr,(a0)+
	move.l	adrscr,(a0)+
	move.l	adrscr,(a0)+
	move.l	adrscr,(a0)+
	lea	adrsp2,a0
	move.l	adrscr,(a0)+
	move.l	adrscr,(a0)+
	move.l	adrscr,(a0)+
	move.l	adrscr,(a0)+
	move.l	adrscr,(a0)+
	move.l	#anr,adranr
	clr.b	clavier
;
;------------------------------------
;	   BIG BOUCLE...
;------------------------------------
;
big
;-----------------------------------
;  effacer les 10 sprites 
;-----------------------------------
	lea	adrsp1,a0
;	effacer boule1
	move.l	(a0)+,a1
	rept	30
	clr	(a1)
	addq.l	#8,a1
	clr	(a1)
	addq.l	#8,a1
	clr	(a1)
	lea	144(a1),a1
	endr
;	effacer boule2
	move.l	(a0)+,a1
	rept	30
	clr	(a1)
	addq.l	#8,a1
	clr	(a1)
	addq.l	#8,a1
	clr	(a1)
	lea	144(a1),a1
	endr
;	effacer boule3
	move.l	(a0)+,a1
	rept	30
	clr	(a1)
	addq.l	#8,a1
	clr	(a1)
	addq.l	#8,a1
	clr	(a1)
	lea	144(a1),a1
	endr
;	effacer boule4
	move.l	(a0)+,a1
	rept	30
	clr	(a1)
	addq.l	#8,a1
	clr	(a1)
	addq.l	#8,a1
	clr	(a1)
	lea	144(a1),a1
	endr
;	effacer boule5
	move.l	(a0)+,a1
	rept	30
	clr	(a1)
	addq.l	#8,a1
	clr	(a1)
	addq.l	#8,a1
	clr	(a1)
	lea	144(a1),a1
	endr
	lea	adrsp2,a0
;	effacer boule6
	move.l	(a0)+,a1
	rept	30
	clr	(a1)
	addq.l	#8,a1
	clr	(a1)
	addq.l	#8,a1
	clr	(a1)
	lea	144(a1),a1
	endr
;	effacer boule7
	move.l	(a0)+,a1
	rept	30
	clr	(a1)
	addq.l	#8,a1
	clr	(a1)
	addq.l	#8,a1
	clr	(a1)
	lea	144(a1),a1
	endr
;	effacer boule8
	move.l	(a0)+,a1
	rept	30
	clr	(a1)
	addq.l	#8,a1
	clr	(a1)
	addq.l	#8,a1
	clr	(a1)
	lea	144(a1),a1
	endr
;	effacer boule9
	move.l	(a0)+,a1
	rept	30
	clr	(a1)
	addq.l	#8,a1
	clr	(a1)
	addq.l	#8,a1
	clr	(a1)
	lea	144(a1),a1
	endr
;	effacer boule10
	move.l	(a0)+,a1
	rept	30
	clr	(a1)
	addq.l	#8,a1
	clr	(a1)
	addq.l	#8,a1
	clr	(a1)
	lea	144(a1),a1
	endr
;------------------------------------
;
;	affichage du scroll
;
;------------------------------------
	lea	adrsp1,a4
	move.l	#adrctx,adract
;------------------------------------
;	affichage du caractere 1
;------------------------------------
	move.l	adrpos,a2
	tst	(a2)
	bne	pass1
;------------------------------------
;     nouvelle lettre a scroller
;------------------------------------
	move.l	adrwav,a2
	lea	adrctx+40,a0
	lea	-4(a0),a1
	rept	9
	move.l	-(a1),-(a0)	
	endr
	addq.l	#1,adrtxt
	move.l	adrtxt,a0
	cmp.l	#endtext,a0
	bne.s	pass20
	move.l	#text,adrtxt
pass20
	clr.l	d0
	move.b	(a0),d0
	cmp.b	#32,d0
	bne.s	pass21
	move.b	#30,d0	
 	bra.s	pass27
pass21	cmp.b	#44,d0
	bne.s	pass22
	move.b	#26,d0
	bra.s	pass27
pass22	cmp.b	#46,d0
	bne.s	pass23
	move.b	#27,d0
	bra.s	pass27
pass23	cmp.b	#39,d0
	bne.s	pass24
	move.b	#28,d0
	bra.s	pass27
pass24	cmp.b	#33,d0
	bne.s	pass25
	move.b	#29,d0
	bra.s	pass27
pass25	sub.l	#65,d0
  
pass27	lsl.l	#2,d0
	lea	tabchr,a1
	move.l	(a1,d0.w),a1
	add.l	#carac,a1	
	
	lea	adrctx,a0
	move.l	a1,adrctx
pass1	clr.l	d0
	clr.l	d1
	clr.l	d2
	move	(a2)+,d0
	move.b	(a2)+,d1
	move.b	(a2)+,d2
	move.l	a2,adrpos
	mulu	#180,d2
	
	move.l	adract,a0
	move.l	(a0),a0
	
	add.l	d2,a0
	move.l	adrscr,a1
	lea	6(a1),a1
	add.l	d0,a1
	move.l	a1,(a4)+
	affcar	
;------------------------------------
;	affichage du caractere 2	
;------------------------------------
	move.l	adrpos,a2
	tst	(a2)
	bne.s	pass2
	move.l	adrwav,a2
pass2	clr.l	d0
	clr.l	d1
	clr.l	d2
	move	(a2)+,d0
	move.b	(a2)+,d1
	move.b	(a2)+,d2
	move.l	a2,adrpos
	mulu	#180,d2

	addq.l	#4,adract
	move.l	adract,a0
	move.l	(a0),a0

	add.l	d2,a0
	move.l	adrscr,a1
	lea	6(a1),a1
	add.l	d0,a1
	move.l	a1,(a4)+
	affcar	
;-------------------------------------
;	affichage du caractere 3	
;-------------------------------------
	move.l	adrpos,a2
	tst	(a2)
	bne.s	pass3
	move.l	adrwav,a2
pass3	clr.l	d0
	clr.l	d1
	clr.l	d2
	move	(a2)+,d0
	move.b	(a2)+,d1
	move.b	(a2)+,d2
	move.l	a2,adrpos
	
	addq.l	#4,adract
	move.l	adract,a0
	move.l	(a0),a0
	
	mulu	#180,d2
	add.l	d2,a0
	move.l	adrscr,a1
	lea	6(a1),a1
	add.l	d0,a1
	move.l	a1,(a4)+
	affcar	
;-----------------------------------
;      affichage du caractere	4
;-----------------------------------
	move.l	adrpos,a2
	tst	(a2)
	bne.s	pass4
	move.l	adrwav,a2
pass4	clr.l	d0
	clr.l	d1
	clr.l	d2
	move	(a2)+,d0
	move.b	(a2)+,d1
	move.b	(a2)+,d2
	move.l	a2,adrpos
	mulu	#180,d2
	
	addq.l	#4,adract
	move.l	adract,a0
	move.l	(a0),a0
	
	add.l	d2,a0
	move.l	adrscr,a1
	lea	6(a1),a1
	add.l	d0,a1
	move.l	a1,(a4)+
	affcar	
;------------------------------------
;	affichage du caractere 5
;------------------------------------
	move.l	adrpos,a2
	tst	(a2)
	bne.s	pass5
	move.l	adrwav,a2
pass5	clr.l	d0
	clr.l	d1
	clr.l	d2
	move	(a2)+,d0
	move.b	(a2)+,d1
	move.b	(a2)+,d2
	move.l	a2,adrpos
	mulu	#180,d2
	
	addq.l	#4,adract
	move.l	adract,a0
	move.l	(a0),a0
	
	add.l	d2,a0
	move.l	adrscr,a1
	lea	6(a1),a1
	add.l	d0,a1
	move.l	a1,(a4)+
	affcar
;------------------------------------
;	affichage du caractere 6
;------------------------------------
	lea	adrsp2,a4
	move.l	adrpos,a2
	tst	(a2)
	bne.s	pass8
	move.l	adrwav,a2
pass8	clr.l	d0
	clr.l	d1
	clr.l	d2
	move	(a2)+,d0
	move.b	(a2)+,d1
	move.b	(a2)+,d2
	move.l	a2,adrpos
	mulu	#180,d2
	
	addq.l	#4,adract
	move.l	adract,a0
	move.l	(a0),a0
	
	add.l	d2,a0
	move.l	adrscr,a1
	lea	6(a1),a1
	add.l	d0,a1
	move.l	a1,(a4)+
	affcar	
;------------------------------------
;	affichage du caractere 7	
;------------------------------------
	move.l	adrpos,a2
	tst	(a2)
	bne.s	pass9
	move.l	adrwav,a2
pass9	clr.l	d0
	clr.l	d1
	clr.l	d2
	move	(a2)+,d0
	move.b	(a2)+,d1
	move.b	(a2)+,d2
	move.l	a2,adrpos
	mulu	#180,d2
	
	addq.l	#4,adract
	move.l	adract,a0
	move.l	(a0),a0
	
	add.l	d2,a0
	move.l	adrscr,a1
	lea	6(a1),a1
	add.l	d0,a1
	move.l	a1,(a4)+
	affcar	
;-------------------------------------
;	affichage du caractere 8	
;-------------------------------------
	move.l	adrpos,a2
	tst	(a2)
	bne.s	pass10
	move.l	adrwav,a2
pass10	clr.l	d0
	clr.l	d1
	clr.l	d2
	move	(a2)+,d0
	move.b	(a2)+,d1
	move.b	(a2)+,d2
	move.l	a2,adrpos
	
	addq.l	#4,adract
	move.l	adract,a0
	move.l	(a0),a0
	
	mulu	#180,d2
	add.l	d2,a0
	move.l	adrscr,a1
	lea	6(a1),a1
	add.l	d0,a1
	move.l	a1,(a4)+
	affcar	
;-----------------------------------
;      affichage du caractere	9
;-----------------------------------
	move.l	adrpos,a2
	tst	(a2)
	bne.s	pass11
	move.l	adrwav,a2
pass11	clr.l	d0
	clr.l	d1
	clr.l	d2
	move	(a2)+,d0
	move.b	(a2)+,d1
	move.b	(a2)+,d2
	move.l	a2,adrpos
	mulu	#180,d2
	
	addq.l	#4,adract
	move.l	adract,a0
	move.l	(a0),a0
	
	add.l	d2,a0
	move.l	adrscr,a1
	lea	6(a1),a1
	add.l	d0,a1
	move.l	a1,(a4)+
	affcar	
;----------------------------------------
;	affichage du caractere 10
;----------------------------------------
	move.l	adrpos,a2
	tst	(a2)
	bne.s	pass12
	move.l	adrwav,a2
pass12	clr.l	d0
	clr.l	d1
	clr.l	d2
	move	(a2)+,d0
	move.b	(a2)+,d1
	move.b	(a2)+,d2
	move.l	a2,adrpos
	mulu	#180,d2
	
	addq.l	#4,adract
	move.l	adract,a0
	move.l	(a0),a0
	
	add.l	d2,a0
	move.l	adrscr,a1
	lea	6(a1),a1
	add.l	d0,a1
	move.l	a1,(a4)+
	affcar
;-----------------------------------
;	copy ecran inverse
;-----------------------------------
	move.l	adrscr,a0
	lea.l	160*115(a0),a0
	lea.l	160*47(a0),a1
	rept	29	
	cpylin
	lea	-800(a0),a0
	endr
	move.l	#adrctx,adract
;-----------------------------------
;     attendre synchro verticale
;-----------------------------------
	move.b	#1,vblflag
vsync	cmp.l	#lin128-32,a6
	bne.s	vsync
;-----------------------------------------
;	animation des rasters...
;-----------------------------------------
	lea	raster,a0
	addq.l	#2,adranr
	move.l	adranr,a1
	cmp.l	#endanr,a1
	bne.s	pass6
	move.l	#anr,adranr
pass6	rept	9
	move	(a1)+,(a0)
	addq.l	#4,a0
	move	(a1)+,(a0)
	addq.l	#4,a0
	move	(a1)+,(a0)
	add.l	#4,a0
	move	(a1)+,(a0)
	addq.l	#4,a0
	move	(a1)+,(a0)
	addq.l	#4,a0
	move	(a1)+,(a0)
	addq.l	#4,a0
	move	(a1)+,(a0)
	addq.l	#4,a0
	move	(a1)+,(a0)
	addq.l	#4,a0
	move	(a1)+,(a0)
	addq.l	#4,a0
	move	(a1)+,(a0)
	addq.l	#4,a0
	move	(a1)+,(a0)
	add.l	#4,a0
	move	(a1)+,(a0)
	addq.l	#4,a0
	move	(a1)+,(a0)
	addq.l	#4,a0
	move	(a1)+,(a0)
	addq.l	#4,a0
	move	(a1)+,(a0)
	addq.l	#4,a0
	move	(a1)+,(a0)
	lea	-32(a1),a1
	endr

;------------------------------------
;    gestion clavier....
;------------------------------------
	move.b	clavier,d0
	cmp.b	#$3b,d0
	bne.s	press1
	move.l	#wave1,adrwav
	bra	press10
press1	cmp.b	#$3c,d0
	bne.s	press2
	move.l	#wave2,adrwav
	bra	press10
press2	cmp.b	#$3d,d0
	bne.s	press3
	move.l	#wave3,adrwav
	bra.s	press10
press3	cmp.b	#$3e,d0
	bne.s	press4
	move.l	#wave4,adrwav
	bra.s	press10
press4	cmp.b	#$3f,d0
	bne.s	press5
	move.l	#wave5,adrwav
	bra.s	press10
press5	cmp.b	#$40,d0
	bne.s	press6
	move.l	#wave6,adrwav
	bra.s	press10
press6	cmp.b	#$41,d0
	bne.s	press7
	move.l	#wave7,adrwav
press7	
press10	cmp.b	#$39,clavier
	bne	big
;------------------------------------
;	sorti de la boucle 
;	   principale..
;------------------------------------
sorti    
	move	#$2700,sr
	move.l    v_70,adrvbl
	move.b    v_fffa21,$fffa21
	move.b    v_fffa1b,$fffa1b
	move.b    $fffa13,v_fffa13
	move.l    v_120,adrhbl
	move.b    v_fffa09,$fffa09
	move.b    v_fffa07,$fffa07
	lea	$ffff8240,a0
	move	#$777,(a0)+
	clr.l	d0
	rept	15
	move	d0,(a0)+
	endr
	move.l	#$80800000,$ffff8800.w
	move.l	#$90900000,$ffff8800.w
	move.l	#$a0a00000,$ffff8800.w
	move	#$2300,sr
;------------------------------------
;    fin du programme super user
;------------------------------------
	rts       
;====================================
;
;	routines de decalages...
;
;====================================
decal0	clr	d7
	rts
decal1	
	clr	d7
	roxr.l	d0
	roxr.l	d1
	roxr.l	d2
	roxr.l	d3
	roxr.l	d4
	roxr.l	d5
	roxr.l	d6
	roxr.l	d7
	rts
decal2
	clr	d7
	rept	2
	roxr.l	d0
	roxr.l	d1
	roxr.l	d2
	roxr.l	d3
	roxr.l	d4
	roxr.l	d5
	roxr.l	d6
	roxr.l	d7
	endr
	rts
decal3
	clr	d7
	rept	3
	roxr.l	d0
	roxr.l	d1
	roxr.l	d2
	roxr.l	d3
	roxr.l	d4
	roxr.l	d5
	roxr.l	d6
	roxr.l	d7
	endr
	rts
decal4
	clr	d7
	rept	4
	roxr.l	d0
	roxr.l	d1
	roxr.l	d2
	roxr.l	d3
	roxr.l	d4
	roxr.l	d5
	roxr.l	d6
	roxr.l	d7
	endr
	rts
decal5
	clr	d7
	rept	5
	roxr.l	d0
	roxr.l	d1
	roxr.l	d2
	roxr.l	d3
	roxr.l	d4
	roxr.l	d5
	roxr.l	d6
	roxr.l	d7
	endr
	rts
decal6
	clr	d7
	rept	6
	roxr.l	d0
	roxr.l	d1
	roxr.l	d2
	roxr.l	d3
	roxr.l	d4
	roxr.l	d5
	roxr.l	d6
	roxr.l	d7
	endr
	rts
decal7
	clr	d7
	rept	7
	roxr.l	d0
	roxr.l	d1
	roxr.l	d2
	roxr.l	d3
	roxr.l	d4
	roxr.l	d5
	roxr.l	d6
	roxr.l	d7
	endr
	rts
decal8	
	clr	d7
	rept	8
	roxr.l	d0
	roxr.l	d1
	roxr.l	d2
	roxr.l	d3
	roxr.l	d4
	roxr.l	d5
	roxr.l	d6
	roxr.l	d7
	endr
	rts
decal9
	clr	d7
	rept	9
	roxr.l	d0
	roxr.l	d1
	roxr.l	d2
	roxr.l	d3
	roxr.l	d4
	roxr.l	d5
	roxr.l	d6
	roxr.l	d7
	endr
	rts
decal10
	clr	d7
	rept	10
	roxr.l	d0
	roxr.l	d1
	roxr.l	d2
	roxr.l	d3
	roxr.l	d4
	roxr.l	d5
	roxr.l	d6
	roxr.l	d7
	endr
	rts
decal11
	clr	d7
	rept	11
	roxr.l	d0
	roxr.l	d1
	roxr.l	d2
	roxr.l	d3
	roxr.l	d4
	roxr.l	d5
	roxr.l	d6
	roxr.l	d7
	endr
	rts
decal12
	clr	d7
	rept	12
	roxr.l	d0
	roxr.l	d1
	roxr.l	d2
	roxr.l	d3
	roxr.l	d4
	roxr.l	d5
	roxr.l	d6
	roxr.l	d7
	endr
	rts
decal13
	clr	d7
	rept	13
	roxr.l	d0
	roxr.l	d1
	roxr.l	d2
	roxr.l	d3
	roxr.l	d4
	roxr.l	d5
	roxr.l	d6
	roxr.l	d7
	endr
	rts
decal14
	clr	d7
	rept	14
	roxr.l	d0
	roxr.l	d1
	roxr.l	d2
	roxr.l	d3
	roxr.l	d4
	roxr.l	d5
	roxr.l	d6
	roxr.l	d7
	endr
	rts
decal15	
	clr	d7
	rept	15
	roxr.l	d0
	roxr.l	d1
	roxr.l	d2
	roxr.l	d3
	roxr.l	d4
	roxr.l	d5
	roxr.l	d6
	roxr.l	d7
	endr
	rts
;=======================================
;
;	InTerruptions 
;
;	   VBL&HBL
;
;
;=======================================
hbl
	move	(a6)+,$ffff8240.w      
	move	(a6),$ffff8250.w
	move	(a6),$ffff8252.w
	move	(a6),$ffff8254.w
	move	(a6),$ffff8256.w
	move	(a6),$ffff8258.w
	move	(a6),$ffff825a.w
	move	(a6),$ffff825c.w
	move	(a6)+,$ffff825e.w
	subq.b	#1,nolin
	tst.b	nolin
	beq.s	hbl130
	bclr.b	#0,$fffffa0f.w
	rte
hbl130
	move	#$327,$ffff8242.w
	move.l	#$07770767,$ffff8244.w
	move.l	#$06570547,$ffff8248.w
	move	#$0437,$ffff824c.w
	move.b	#1,$fffffa21.w
	bclr      #0,$fffffa0f.w
	rte       
;-----------------------------------------
;	      VBL 
;-----------------------------------------
vbl	movem.l	d0-d7/a0-a6,-(sp)
;-----------------------------------------
;	jouer la music...
;-----------------------------------------
;	jsr	music+8
;-----------------------------------------
; initialisation compteur rasters 130
;-----------------------------------------
	move.b	#160,nolin
;-----------------------------------------
;	gestion clavier...
;-----------------------------------------
	move.b	$fffffc02.w,clavier
;-----------------------------------------
;	copy palette...
;-----------------------------------------
	lea	$ffff8240.w,a0
	move.l	#$00000323,(a0)+
	move.l	#$07770767,(a0)+
	move.l	#$06560545,(a0)+
	move.l	#$04340000,(a0)+
;-----------------------------------------
;   genere signal synchro verticale
;-----------------------------------------
	clr.b	vblflag
;-----------------------------------------
;	     fin vbl
;-----------------------------------------
	movem.l	(sp)+,d0-d7/a0-a6
;-----------------------------------------
;	resoration table rasters...
;-----------------------------------------	
	lea.l	raster,a6	

	rte       
;=========================================
;	section BSS...
;=========================================
	BSS 
	EVEN 
adrpos	ds.l 1
adrtxt	ds.l 1
adrwav	ds.l 1
adrras	ds.l 1
adranr	ds.l 1
adract	ds.l 1
adrtab	ds.l 16
adrctx	ds.l 10
adrsp1	ds.l 5
adrsp2	ds.l 5
adrscr	ds.l 1
v_70	ds.l 1
v_120	ds.l 1
v_fffa07    DS.b 1
v_fffa09  DS.b 1
v_fffa1b  DS.b 1
v_fffa21  DS.b 1
v_fffa13  DS.b 1
clavier	ds.b 1	
vblflag	ds.b 1
nolin	ds.b 1
ph	ds.b 10
;====================================
;	section data...
;====================================	
	data
;------------------------------------
;   couleurs de l'animation rasters
;------------------------------------
tabchr
	dc.l	0
	dc.l	4320
	dc.l	4320*2
	dc.l	4320*3
	dc.l	4320*4
	dc.l	4320*5
	dc.l	4320*6
	dc.l	4320*7
	dc.l	4320*8
	dc.l	4320*9
	dc.l	4320*10
	dc.l	4320*11
	dc.l	4320*12
	dc.l	4320*13
	dc.l	4320*14
	dc.l	4320*15
	dc.l	4320*16
	dc.l	4320*17
	dc.l	4320*18
	dc.l	4320*19
	dc.l	4320*20
	dc.l	4320*21
	dc.l	4320*22
	dc.l	4320*23
	dc.l	4320*24
	dc.l	4320*25
	dc.l	4320*26
	dc.l	4320*27
	dc.l	4320*28
	dc.l	4320*29
	dc.l	4320*30
	
anr	
	rept	3
	dc.w	$777
	dc.w	$077
	dc.w	$666
	dc.w	$066
	dc.w	$555
	dc.w	$055
	dc.w	$444
	dc.w	$044
	dc.w	$333
	dc.w	$033
	dc.w	$222
	dc.w	$022
	dc.w	$111
	dc.w	$011
	dc.w	$000
	dc.w	$000
	dc.w	$000
	dc.w	$000
	dc.w	$000
	endr
	rept	16
	dc.w	$0
	endr
	rept	5
	dc.w	$00
	dc.w	$11
	dc.w	$22
	dc.w	$33
	dc.w	$44
	dc.w	$55
	dc.w	$66
	dc.w	$77
	dc.w	$66
	dc.w	$55
	dc.w	$44
	dc.w	$33
	dc.w	$22
	dc.w	$11
	dc.w	$00
	endr
	rept	16
	dc.w	$000
	endr
	rept	5
	dc.w	$777
	dc.w	$707
	dc.w	$666
	dc.w	$606
	dc.w	$555
	dc.w	$505
	dc.w	$444
	dc.w	$404
	dc.w	$333
	dc.w	$303
	dc.w	$222
	dc.w	$202
	dc.w	$111
	dc.w	$101
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	endr
	rept	16
	dc.w	$000
	endr
	rept	5
	dc.w	$000
	dc.w	$110
	dc.w	$220
	dc.w	$330
	dc.w	$440
	dc.w	$550
	dc.w	$660
	dc.w	$770
	dc.w	$660
	dc.w	$550
	dc.w	$440
	dc.w	$330
	dc.w	$220
	dc.w	$110
	dc.w	$000
	endr
	rept	16
	dc.w	$000
	endr
	dc.w	$777
	dc.w	$770
	dc.w	$666
	dc.w	$660
	dc.w	$555
	dc.w	$550
	dc.w	$444
	dc.w	$440
	dc.w	$333
	dc.w	$330
	dc.w	$222
	dc.w	$220
	dc.w	$111
	dc.w	$110
	rept	16
	dc.w	$000
	endr
	rept	5
	dc.w	$000
	dc.w	$111
	dc.w	$222
	dc.w	$333
	dc.w	$444
	dc.w	$555
	dc.w	$666
	dc.w	$777
	dc.w	$666
	dc.w	$555
	dc.w	$444
	dc.w	$333
	dc.w	$222
	dc.w	$111
	dc.w	$000
	endr
	
	rept	16
	dc.w	$000 
	endr
endanr
	dc.w	$777
	dc.w	$077
	dc.w	$666
	dc.w	$066
	dc.w	$555
	dc.w	$055
	dc.w	$444
	dc.w	$044
	dc.w	$333
	dc.w	$033
	dc.w	$222
	dc.w	$022
	dc.w	$111
	dc.w	$011
	dc.w	$000
	dc.w	$000
;------------------------------------
;     liste des couleurs rasters	
;------------------------------------
raster
	rept	4
	dc.w	0,$770
	dc.w	0,$671
	dc.w	0,$572
	dc.w	0,$473
	dc.w	0,$374
	dc.w	0,$275
	dc.w	0,$176
	dc.w	0,$077
	dc.w	0,$067
	dc.w	0,$057
	dc.w	0,$047
	dc.w	0,$037
	dc.w	0,$027
	dc.w	0,$017
	dc.w	0,$007
	dc.w	0,$107
	dc.w	0,$207
	dc.w	0,$307
	dc.w	0,$407
	dc.w	0,$507
	dc.w	0,$607
	dc.w	0,$707
	dc.w	0,$716
	dc.w	0,$725
	dc.w	0,$734
	dc.w	0,$743
	dc.w	0,$752
	dc.w	0,$761
	dc.w	0,$770
	endr
lin128	dc.w	0,$770
	dc.w	0,$671
	dc.w	0,$572
	dc.w	0,$473
	dc.w	0,$374
	dc.w	0,$275
	dc.w	0,$176
	dc.w	0,$077
	dc.w	0,$067
	dc.w	0,$057
	dc.w	0,$047
	dc.w	0,$037
	dc.w	0,$027
	dc.w	0,$017
	dc.w	0,$007
	dc.w	0,$107
	dc.w	0,$207
	dc.w	0,$307
	dc.w	0,$407
	dc.w	0,$507
	dc.w	$100,$777
	dc.w	$900,$677
	dc.w	$200,$577
	dc.w	$a00,$477
	dc.w	$300,$377
	dc.w	$ba0,$277
	dc.w	$410,$177
	dc.w	$cb0,$077
	dc.w	$520,$067
	dc.w	$dc0,$057
	dc.w	$630,$047
	dc.w	$ed0,$037
	dc.w	$740,$027
	dc.w	$fe0,$017
	dc.w	$750,$007
	dc.w	$750,$107
	dc.w	$760,$207
	dc.w	$760,$307
	dc.w	$770,$407
	dc.w	$770,$507
	dc.w	$774,$607
	dc.w	$754,$707
	dc.w	$634,$717
	dc.w	$414,$727
	dc.w	$204,$737
	dc.w	$004,$747
	dc.w	$004,$757
	dc.w	$004,$767
	dc.w	$004,$777
	dc.w	$004,$677
	dc.w	$004,$577
	dc.w	$004,$477
	dc.w	$004,$377
	dc.w	$004,$277
	dc.w	$004,$177
	dc.w	$004,$077
	dc.w	$004,$067
	dc.w	$004,$057
	dc.w	$004,$047
	dc.w	$004,$037
	dc.w	$004,$027
	dc.w	$004,$017
	dc.w	$004,$007
	dc.w	$004,$017
	dc.w	$004,$027
	dc.w	$004,$037
	dc.w	$004,$047
	dc.w	$004,$057
	dc.w	$004,$067
	dc.w	$004,$077
	dc.w	$004,$177
	dc.w	$004,$277
	dc.w	$004,$377
	dc.w	$004,$477
	dc.w	$004,$577
	dc.w	$004,$677
	dc.w	$004,$777
	dc.w	$004,$667
	dc.w	$004,$557
	dc.w	$004,$447
	dc.w	$004,$227
	dc.w	$004,$007
	dc.w	$0,$007
;------------------------------------
;	donne du dessin logo 
;------------------------------------
graph	incbin	logo2.img
;------------------------------------
;  donne pour les mouvements distort
;------------------------------------
wave1	incbin	wave3.inc
	dc.w	0 
wave2	incbin	wave1.inc
	dc.w	0
wave3	incbin	wave2.inc
	dc.w	0
wave4	incbin	wave4.inc
	dc.w	0
wave5	incbin	wave5.inc
	dc.w	0
wave6	incbin	wave6.inc
	dc.w	0
wave7	incbin	wave9.inc
	dc.w	0
;------------------------------------
;	data de la zicos
;------------------------------------
	even
music	incbin lapzic
;------------------------------------
;	graph des fontes
;------------------------------------
	even
carac	incbin	font3232.inc
;------------------------------------
;	Text du Scrolling
;------------------------------------
text
	dc.b	"             EEH!! NOW YOU ARE IN THE SPACE SCROLL! THAT A NEW CODE OF"
	DC.B	" PRINST WITH THE GREET MB'S LOGO OF MAUPI DICK , AND WITH AN GREET MUSAXXX"
	DC.B 	" OF THE GIGA MEGA GREET MAD MAX!!!! SPECIAL MESSAGE TO HIM 'PLEASE ESCUSE"
	DC.B	" ME FOR THE RIPP,BUT WITH THE TRONIC MEGACARTE THAT REALY EASY AND WHEN I"
	DC.B	" HEAR THIS TUNE,.... YOU UNDERSTAND...'    GOOD.IF YOU THINK THAT ALL! PLEASE,PRESS F ONE....F SEVEN"
	DC.B	" AND YOU CAN'T SEE ALL TRIDI WAVEFORME! ONLY F ONE AND TOW WAS PLAN..."
	DC.B	" ...SOME FELICITATION FOR THE CARBEARS 'YOUR LAST GAME,ENCHANTED ISLAND,IS MERVEILLOUS!'"
	DC.B	" AND SOME OTHER FELICITATION FOR THE OVERLANDERS,WHEN I SEE THE INTRO OF TINTIN SUR LA LUNE."
	DC.B	" AND WHEN I SEE THE EUROPEEN DEMO, I THINK 'NOW ZIGGY IS HERE!' GREET THINK AT DIM,HOW ARE SIZETEEN"
	DC.B	" AND HOW MAKE BETTER THAN ME!!!  OTHER GREETING TO THE GUILD,PHENIX,ZOMBI CREW,REPLICANTS,EMPIRE"
	DC.B	",TEX,THE LOST BOY,THE INNER CIRCLE...ETC SORRY FOR THE CREW THAT I HAVE FORGET ...."
	DC.B	" AN OTHER SPECIAL MESSAGE TO SAMOS ' TON AGE N'ESCUSE PAS TON COMPORTEMENT DE CRETIN!!!!'"
	DC.B	"         THANK TO DAYJBEE AND GRIZZO FOR YOU GREETS WORKS!!! THANK TO GUNSTICK OF ULM FOR THE DARK SIDE OF THE SPOON DEMO!..."
	DC.B	" NOW THAT THE END OF THE TEXT LET ME WARP, BUT HAVE YOU PRESS CORRECTLY F ONE,F TWO,F TREE,F FOUR,F FIVE,F SIX,F SEVEN .... "
	DC.B	" GOOD BYE,AUF VIDER SEHEN,AU REVOIR  ET AVEC L'ESPOIR DE SE REVOIR BIENTOT... "   
endtext  	dc.b	"             "  
     	      