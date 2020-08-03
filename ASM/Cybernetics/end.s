*-------------------------------------------------------------------------*
*									  *
*	END SCREEN 'RELAPSE'			- CYBERNETICS 1992 -	  *
*									  *
*	'BOBS MIGRATION OVER A ZOOM LAND'				  *
*									  *
*-------------------------------------------------------------------------*

	output	e:\code\effects.grx\nosystem\end.inl

		opt	o+

aigus:		set	8
graves:		set	10
cpu:		set	0
nbre_image:	set	12
*-------------------------------------------------------------------------*
		bsr	initsound

		move.l	#buffer_ec,d0
		clr.b	d0
		move.l	d0,bufferec
		move.l	d0,ecran
		move.l	d0,physb
		
		moveq.l	#0,d1
		move.l	d0,a0
		move.w	#(70000+252000)/16,d0
effbss:		rept	4
		move.l	d1,(a0)+
		endr
		dbra.w	d0,effbss
		
		jsr	muson
		
		move.b	#4,$ffff820f.w

		move.w	#2,$ffff8a20.w		* Inc x source
		move.w	#2,$ffff8a22.w		* Inc y source
		move.w	#8,$ffff8a2e.w		* Inc x dest
		move.b	#2,$ffff8a3a.w
		move.b	#7,$ffff8a3b.w
		move.w	#-1,$ffff8a2a.w
		move.w	#-1,$ffff8a28.w
		move.w	#-1,$ffff8a2c.w

*-------------------------------------------------------------------------*
*	MAIN LOOP							  *
*-------------------------------------------------------------------------*
	
		bra	construc

main:		stop 	#$2300

		ifne	cpu
		move.w	#7,$ffff8240.w
		endc

		move.l	bufferec(pc),a0
		move.l	flipec(pc),d0
		and.l	#132*256,d0
		add.l	d0,a0
		move.l	a0,ecran
		move.l	a0,physb
		not.l	flipec

		move.w	cpt(pc),d0
		tst.w	d0
		beq	zoomin
		clr.w	calc
		cmp.w	#1,d0
		beq	calctraj
		cmp.w	#210,d0
		blt	anim	
		cmp.w	#210,d0
		beq	construc
		move.w	#-1,calc
		cmp.w	#211,d0
		beq	calctraj
		cmp.w	#415,d0
		blt	anim
		bra	zoomout
return:		addq.w	#1,cpt

		ifne	cpu
		move.w	#0,$ffff8240.w
		endc
		
		tst.w	cptimage
		bne	main
		
fin:		move.w	#-1,exit2
		move.w	#$2300,sr

		lea	$ffff8240.w,a0
		lea	dep3(pc),a1
		moveq.l	#7,d0
deppal:		move.l	(a0)+,(a1)+
		dbra.w	d0,deppal
		
		lea	dep3(pc),a0
		lea	zero(pc),a2
		moveq.l	#-1,d1
		bsr.s	light2

		bsr	fadesound
		
		clr.b	$ffff820f.w
		
		jsr	musoff
		
		illegal

zero:	ds.w	16
dep3:	ds.w	16

*----------------------------- FADE ROUTINE ------------------------------*
*	A0 = adr palette depart						  *
* 	A2 = adr palette arrivee					  *
* 	D1 = masque							  *
*-------------------------------------------------------------------------*

light2:	
	move.w		d1,a5			* Sauve le mot de test couleurs
	clr.w		rd4			* Compteur de boucles: nbre d'etapes
.looplight:					* Boucle principale
	move.l		a0,a1			* Adresse palette
	move.l		a2,a3			* Adresse palette
	move.w		rd4(pc),d2		* Compteur boucle (‚tape fade)
	lsl.w		#4,d2			*
	lea		$ffff8240.w,a4		* Adr palette
	move.w		a5,d1
	move.w		#15,rd6
	
.light_colors:
	move.w  	(a1)+,d4		* Couleur de depart
	move.w		(a3)+,d5 		* Couleur d'arrivee
	
	add.w		d1,d1			* Test si il faut modifier
	bcc.s		.nocol			* ce registre de couleur
	
	moveq.l		#0,d3			* Registre pour couleur finale
	moveq.l		#0,d0			* Indice boucle: 0-4-8 (decalage composante r-v-b)

.compo:	move.w		d4,d7			* Color dep
	bsr.s		rol4bits		*  
	move.w		d7,d6			* => valeur composante de 0 … 15
	move.w		d5,d7			* Color arr
	bsr.s		rol4bits		* => valeur composante de 0 … 15
	sub.w		d6,d7			* delta composante: Dc
	muls.w		d2,d7			* Dc * 256 / nb ‚tape 
	asr.w		#8,d7			* Dc / 256
	add.w		d6,d7			* Dc + color dep 
	bsr.s		ror4bits		* composante de 0 … 15 => ste color 
	lsl.w		d0,d7
	or.w		d7,d3			* D3 : resultat couleur

	lsr.w		#4,d4			* Decalage pour composante
	lsr.w		#4,d5
	
	addq.w		#4,d0			* Boucle composante
	cmp.w		#12,d0
	bne.s		.compo
	
	move.w		d3,(a4)			* Fixe couleur
.nocol:	addq.w		#2,a4
	
	subq.w		#1,rd6			* Boucle couleur
	bge.s 		.light_colors

	move.w		#5000,d5		* Temporisation
.temp:	move.l		4(sp),4(sp)  
	dbra.w		d5,.temp
	
	addq.w		#1,rd4			* Boucle etape
	cmp.w		#17,rd4
	bne.s		.looplight
	rts


rd4:	dc.w	0
rd6:	dc.w	0


rol4bits:
	add.w		d7,d7		* D7: couleur shift‚e (selon Composante voulue)
	btst.l		#4,d7
	beq.s		.nobit1_1
	or.w		#1,d7	
.nobit1_1:
	and.w		#15,d7		* D7: compsante de 0 … 15
	rts

	
ror4bits:
	ror.w		#1,d7
	bcc.s		.nobit1_2
	or.w		#8,d7
.nobit1_2:
	and.w		#15,d7
	rts


exit2:		dc.w	0


initsound:
	move.w		#$7ff,$ffff8924.w		* Init microwire
dmwr:	cmp.w		#$7ff,$ffff8924.w
	bne.s		dmwr
	move.w		#%10011101000,d0		* Volume max
	bsr.s		microwrite
	move.w		#%10010000000+aigus,d0		* Aigus 
	bsr.s		microwrite
	move.w		#%10001000000+graves,d0		* Graves
	bsr.s		microwrite
	rts

microwrite:
	moveq.l		#127,d1
waitdma:dbra.w		d1,waitdma
	move.w		d0,$ffff8922.w
	rts


fadesound:	
	moveq.l		#20,d0
temp2:	move.w		#$4c0,d2
	or.w		d0,d2
	add.w		#20,d2
	move.w		d2,$ffff8922.w
	move.w		#5000,d1
temp1:	move.l		4(sp),4(sp)
	dbra.w		d1,temp1
	dbra.w		d0,temp2
	rts


*-------------------------------------------------------------------------*
*	Calcul trajectoires: apparition					  *
*-------------------------------------------------------------------------*
calctraj:	lea	pospr(pc),a1		* Position des sprites
		lea	arrpos(pc),a2		* Position d'arr des sprites
		lea	tx(pc),a3		* Taux pour deplacement
		lea	tabtext(pc),a4
		move.w	nbimage(pc),d0
		add.w	d0,d0
		move.l	(a4,d0.w),a4		* Texte
		move.l	aleopos(pc),a5		* Table aleatoire
		lea	bobs_tab(pc),a6		* Table de sprites
		
		moveq.l	#0,d5			
		moveq.l	#4,d6
		moveq.l	#10,d7
		move.w	#-1,nb			

traj:		move.b	(a4)+,d0		* Caractere dans le texte
		cmp.b	#32,d0			* Si espace pas de sprite a gerer
		beq	nogest
		cmp.b	#".",d0
		bne.s	okette
		addq.w	#8,d5		
		bra	nogest
okette:		cmp.b	#"@",d0			* Si arobace fin generation trajectoire
		beq	fintraj

		addq.w	#1,nb			* Nb de sprite … gerer

		sub.b	#65,d0
		ext.w	d0
		lsl.w	#6,d0
		lea	sprite(pc),a0
		add.w	d0,a0
		move.l	a0,(a6)+

		move.w	(a5)+,d1		* Nb d'etapes

		tst.w	calc
		bne.s	calc2		
						*--------- X
		move.l	d5,d2			* X arrivee
		asl.l	d7,d2
		move.l	d2,(a2)+		

		move.w	(a5)+,d3		* Nombre aleo
		ext.l	d3
		asl.l	d7,d3
		move.l	d3,(a1)+		
		
		sub.l	d3,d2
		divs.w	d1,d2
		ext.l	d2
		move.l	d2,(a3)+

						*--------- Y
		move.l	d6,d2			* Y arrivee
		asl.l	d7,d2
		move.l	d2,(a2)+		

		move.w	(a5)+,d3		* Nombre aleo
		ext.l	d3
		asl.l	d7,d3
		move.l	d3,(a1)+
		
		sub.l	d3,d2
		divs.w	d1,d2
		ext.l	d2
		move.l	d2,(a3)+
		bra.s	endcalc

calc2:
						*--------- X
		move.l	d5,d3			* X arrivee
		asl.l	d7,d3
		move.l	d3,(a1)+		

		move.w	(a5)+,d2		* Nombre aleo
		ext.l	d2
		asl.l	d7,d2
		move.l	d2,(a2)+		
		
		sub.l	d3,d2
		divs.w	d1,d2
		ext.l	d2
		move.l	d2,(a3)+

						*--------- Y
		move.l	d6,d3			* Y arrivee
		asl.l	d7,d3
		move.l	d3,(a1)+		

		move.w	(a5)+,d2		* Nombre aleo
		ext.l	d2
		asl.l	d7,d2
		move.l	d2,(a2)+
		
		sub.l	d3,d2
		divs.w	d1,d2
		ext.l	d2
		move.l	d2,(a3)+

endcalc:	cmp.l	#aleo+3000,aleopos
		bne.s	nogest
		move.l	#aleo,aleopos
nogest:		
		add.w	#16,d5	
		cmp.w	#320,d5
		blt.s	noligne
		moveq.l	#0,d5
		add.w	#17,d6
noligne:
		bra	traj
fintraj:
		bra	return

calc:		dc.w	0

*-------------------------------------------------------------------------*
*	ANIMATION DES SPRITES						  *
*-------------------------------------------------------------------------*

anim:		
		move.w	#2,$ffff8a20.w		* Inc x source
		move.w	#2,$ffff8a22.w		* Inc y source
		move.w	#8,$ffff8a2e.w		* Inc x dest

		move.l	ecran(pc),d0
		addq.l	#6,d0
		move.l	d0,$ffff8a32.w		* Effacage ecran
		move.w	#20,$ffff8a36.w		* Hori size
		move.w	#200,$ffff8a38.w	* Vert size
 		move.b	#0,$ffff8a3a.w		* Mode HOG
		move.b	#0,$ffff8a3b.w		* 0 Bits
		move.w	#8+8,$ffff8a30.w	* Inc y dest
		move.b	#%11000000,$ffff8a3c.w  * GO
noeff:
		cmp.w	#-1,nb
		bne.s	oktrac
		bra	return
		
oktrac:		move.b	#2,$ffff8a3a.w		* Mode HOG
		move.b	#7,$ffff8a3b.w		* Or
		move.w	#2,$ffff8a36.w		* Hori size
		move.w	#168-16+8,$ffff8a30.w	* Inc y dest

		move.w	nb(pc),d0		* Nb of sprites
		moveq.l	#10,d7			* Nombre de decalages pour calcul
		lea	$ffff8a24.w,a0		* Adr blitter
		lea	pospr(pc),a1		* Position sprites
		lea	tx(pc),a4		* Taux pour trajectoires
		lea	arrpos(pc),a5		* Position d'arrivee
		lea	bobs_tab(pc),a6		* Liste des sprites a afficher
		move.l	ecran(pc),a2		* Adr affichage
		addq.w	#6,a2
		
aff_spr:	move.l	(a1)+,d1		* X pos
		move.l	(a1)+,d2		* Y pos

		move.l	(a5)+,d3
		move.l	(a5)+,d4

		sub.l	d1,d3
		bpl.s	ok1
		neg.l	d3
ok1:		sub.l	d2,d4
		bpl.s	ok2
		neg.l	d4
ok2:		and.l	#$fffffe00,d3
		bne.s	dep
		and.l	#$fffffe00,d4
 		bne.s	dep  
		
		move.l	-8(a5),d1
		move.l	-4(a5),d2
		
		addq.w	#8,a4
		bra.s	nodep
		
dep:		add.l	(a4)+,d1
		move.l	d1,-8(a1)
		add.l	(a4)+,d2
		move.l	d2,-4(a1)
nodep:
		asr.l	d7,d1
		asr.l	d7,d2
		move.l	(a6)+,a3

		moveq.l	#16,d3
		cmp.w	#184,d2
		ble.s	noclipy1
		move.w	#200,d3
		sub.w	d2,d3
noclipy1:
		tst.w	d2
		bge.s	noclipy2
		add.w	d2,d3
		add.w	d2,d2
		add.w	d2,d2
		sub.w	d2,a3
		moveq.l	#0,d2
noclipy2:
		cmp.w	#-16,d1
		bge.s	noclipx1
		moveq.l	#0,d3	
noclipx1:
		cmp.w	#320,d1
		blt.s	noclipx2
		moveq.l	#0,d3
noclipx2:	
		tst.w	d3
		ble.s	noaff
		move.w	d3,$8a38-$8a24(a0)	* Vert size
    		move.l	a3,(a0)			* Adr source
		mulu.w	#168,d2
		lea	(a2,d2.l),a3
		move.w	d1,d2
		and.w	#$fff0,d1
		asr.w	#1,d1
		add.w	d1,a3
		and.w	#15,d2
		move.b	d2,$8a3d-$8a24(a0)	* Decalage & Go
		move.l	a3,$8a32-$8a24(a0)	* Adr dest
		move.b	#%11000000,$8a3c-$8a24(a0)
noaff:
		dbra.w	d0,aff_spr		

		bra	return

*-------------------------------------------------------------------------*
*	ZOOM IN								  *
*-------------------------------------------------------------------------*
construc:	
		move.w	tempcpt(pc),d0
		lea	tabtemp(pc),a0
		add.w	d0,a0
		move.w	(a0)+,d0
temps:		stop	#$2300
		dbra.w	d0,temps
		addq.w	#2,tempcpt

		move.l	actimg(pc),ancimg
		lea	tabimg(pc),a0
		add.w	cptimage(pc),a0
		addq.w	#4,cptimage
		cmp.w	#nbre_image*4,cptimage
		bne.s	okimg
		clr.w	cptimage	
okimg:		move.l	(a0),actimg

		moveq.l	#16,d5
		moveq.l	#10,d6
		moveq.l	#18,d7

		move.l	(a0),a0
		lea	128(a0),a0
		lea	zoom,a2

zoomloop1:				*** CONSTRUCTION
		move.w	d5,d2
		move.w	d6,d3
			
		move.w	#320,d0
		sub.w	d2,d0
		lsr.w	#1,d0
		move.w	d0,d4
		and.w	#15,d4
		and.w	#$fff0,d0
		lsr.w	#3,d0
		mulu.w	#3,d0
		lea	(a2,d0.w),a1

		move.w	#320,d0
		move.w	#200,d1
		movem.l	a0-a2/d5-d7,-(sp)
		bsr	zoomer
		movem.l	(sp)+,a0-a2/d5-d7

		move.w	d6,d4
		mulu.w	#120,d4
		add.w	d4,a2

		add.w	#16,d5
		add.w	#10,d6
		
		dbra.w	d7,zoomloop1

		move.l	actimg(pc),a0
		lea	128(a0),a0
		move.w	#3999,d0
copy:		move.l	(a0)+,(a2)+
		move.w	(a0)+,(a2)+
		addq.w	#2,a0
		dbra.w	d0,copy

		bra	return

zoomin:		move.l	actimg(pc),a0
		addq.w	#4,a0
		lea	$ffff8240.w,a1
		rept	8
		move.l	(a0)+,(a1)+
		endr

		moveq.l	#16,d5
		moveq.l	#10,d6
		moveq.l	#19,d7
		lea	zoom,a2
		move.l	ecran(pc),a1

		move.w	#6,$ffff8a20.w		* Inc x source
		move.w	#6,$ffff8a22.w		* Inc y source
		move.w	#8,$ffff8a2e.w		* Inc x dest
		move.w	#8+8,$ffff8a30.w	* Inc y dest
		move.b	#2,$ffff8a3a.w
		move.b	#3,$ffff8a3b.w
		move.b	#0,$ffff8a3d.w
		move.w	#20,$ffff8a36.w		* Hori size

zoomloop2:				*** AFFICHAGE
		move.w	#200,d0
		sub.w	d6,d0
		lsr.w	#1,d0
		mulu.w	#168,d0
		lea	(a1,d0.w),a0

		stop	#$2300

		ifne	cpu
		move.w	#$70,$ffff8240.w		
		endc

		move.l	a2,a3

		rept	3
		move.w	d6,$ffff8a38.w		* Vert size
		move.l	a0,$ffff8a32.w		* Dest
		move.l	a3,$ffff8a24.w		* Source
		move.b	#%11000000,$ffff8a3c.w	* Go
		addq.w	#2,a3
		addq.w	#2,a0
		endr

		move.w	d6,d4
		mulu.w	#120,d4
		add.w	d4,a2
	
		add.w	#16,d5
		add.w	#10,d6

		ifne	cpu
		move.w	#$0,$ffff8240.w		
		endc

		dbra.w	d7,zoomloop2

		move.l	ecran(pc),a2
		move.l	bufferec,a0
		move.l	a0,a1
		add.l	#132*256,a1
		move.w	#199,d0
copy3:		rept	40
		move.l	(a2),(a0)+
		move.l	(a2)+,(a1)+
		endr
		addq.w	#8,a0	
		addq.w	#8,a1
		addq.w	#8,a2
		dbra.w	d0,copy3
		
		bra	return

*-------------------------------------------------------------------------*
*	ZOOM OUT							  *
*-------------------------------------------------------------------------*
zoomout:	
	move.l	ancimg(pc),a0
	addq.w	#4,a0
	move.w	#-1,d0
light:	
	moveq.l		#0,d4			* Compteur de boucles
	cmp.w		#1,d0			* Increment (fade in/out)
	beq.s		oklight
	moveq.l		#15,d4
oklight:
	
looplight:					* Boucle principale
	move.l		a0,a1			* Adresse palette
	move.l		d4,d2
	lsl.w		#4,d2	
	lea		$ffff8240.w,a2
	moveq.l		#15,d6
	
light_colors:
	move.w  	(a1)+,d7		* Couleur de la palette (1 mot)
	
	move.w		d7,d1			* Bleu
	and.w		#15,d1
	add.w		d1,d1		
	btst.l		#4,d1
	beq.s		nobit1_1
	or.w		#1,d1	
nobit1_1:
	and.w		#15,d1
	move.w		d2,d5
	mulu.w		d1,d5
	lsr.w		#8,d5
	ror.w		#1,d5	
	btst.l		#15,d5
	beq.s		nobit1_2
	or.w		#8,d5	
nobit1_2:
	and.w		#15,d5
	move.w		d5,d3	

	
	move.w		d7,d1			* Vert
	lsr.w		#4,d1
	and.w		#15,d1
	add.w		d1,d1		
	btst.l		#4,d1
	beq.s		nobit2_1
	or.w		#1,d1	
nobit2_1:
	and.w		#15,d1
	move.w		d2,d5
	mulu.w		d1,d5
	lsr.w		#8,d5
	ror.w		#1,d5	
	btst.l		#15,d5
	beq.s		nobit2_2
	or.w		#8,d5	
nobit2_2:
	and.w		#15,d5
	lsl.w		#4,d5
	or.w		d5,d3	
	
	
	move.w		d7,d1			* Rouge
	lsr.w		#8,d1
	and.w		#15,d1
	add.w		d1,d1		
	btst.l		#4,d1
	beq.s		nobit3_1
	or.w		#1,d1	
nobit3_1:
	and.w		#15,d1
	move.w		d2,d5
	mulu.w		d1,d5
	lsr.w		#8,d5
	ror.w		#1,d5	
	btst.l		#15,d5
	beq.s		nobit3_2
	or.w		#8,d5	
nobit3_2:
	and.w		#15,d5
	lsl.w		#8,d5
	or.w		d5,d3	
	
	move.w		d3,(a2)+
	
	dbra.w		d6,light_colors

	move.w		#5000,d6
temp:	move.l		4(sp),4(sp)  
	dbra.w		d6,temp
	
	add.w		d0,d4
	beq.s		exit
	cmp.w		#17,d4
	beq.s		exit
	bra		looplight
exit:	
	move.l	bufferec(pc),a0
	move.w	#132*256*2/4-1,d0
	moveq.l	#0,d1
eff:	move.l	d1,(a0)+
	dbra.w	d0,eff

	move.w	#-1,cpt
	addq.w	#2,nbimage
	cmp.w	#nbre_image*2,nbimage
	bne.s	okimg2
	clr.w	nbimage	
okimg2:
	bra	return

*-------------------------------------------------------------------------*
plane:		set	3			* Nombre de plan
endline:	set	1			* Endline creation (on/off)

*-------------------------------------------------------------------------*
*      ZOOMER Source>Dest						  *
*									  *
*      Routine generale (pas d'optimisation selon cas particuliers)	  *
*-------------------------------------------------------------------------*

zoomer:		* Parametrages & autogeneration
		
		ifne		cpu
		move.w		#7,$ffff8240.w	* Cpu time
		endc
		
		move.l		a0,-(sp)	* Sauve adresse de depart
		move.l		a1,-(sp)	* Sauve adresse d'affichage
		
		swap		d2		* Dxdest*65536
		clr.w		d2
		divu.w		d0,d2		* Coef x: Dxdest*65536/Dxsource
		moveq.l		#0,d5		* Accumulateur … z‚ro
		lea		code(pc),a2	* Buffer pour g‚n‚ration
		tst.w		d4		*
		beq.s		nomoveq		*
		move.w		#$7c00,(a2)+	*
nomoveq:	moveq.l		#0,d7		* Compteur pour pixels dest
		bset.l		d4,d7		* initialise selon offset pixel
	
		lea		$de47,a3	* Add.w   d7,d7
		lea		$dd46,a4	* Addx.w  d6,d6
		lea		$3e185c48,a5	* Move.w  (a0)+,d7 & Addq.w #6,a0
		lea		$32c65849,a6	* Move.w  d6,(a1)+ & Addq.w #4,a1
		
		add.w		d0,d0		* Calcul adresse de retour
		lea		table(pc),a0	* dans la routine d'autogeneration
		move.w		(a0,d0.w),d0	*
		lea		auto_g1(pc),a1	* Pointe sur debut routine d'autogeneration
		lea		(a1,d0.w),a0	* Position de retour dans la routine d'autogeneration
		move.w		(a0),-(sp)	* Sauve mot dans la routine
		move.w		#$4e75,(a0)	* Place un Rts dans la routine (selon longueur)
		jsr		(a1)		* Saut a la routine d'autogen 
		move.w		(sp)+,(a0)	* Restaure mot dans la routine
		ifne		endline		* Si option activee
		cmp.w		#1,d7		* Teste si le dernier mot de destination
		beq.s		dadadou		* a ete affiche
		moveq.l		#0,d6		* sinon
bibili:		addq.w		#1,d6		* recherche le decalage
		add.w		d7,d7		* a effectue sur d6
		bcc.s		bibili		* et le genere:
		move.l		#$7e00ef6e,(a2) * Moveq.l #x,d7 & Lsl.w	d7,d6 
		move.b		d6,1(a2)	*
		addq.l		#4,a2		*
		move.w		#$32c6,(a2)+	* Move.w d6,(a1)+
dadadou:	
		endc
		move.w		#$4e75,(a2)+	* On place un Rts … la fin du code g‚n‚r‚
		move.l		(sp)+,a1	* Restaure l'adresse d'affichage 
		move.l		(sp)+,a0	* Restaure l'adresse de depart

nogen:		
		ifne		cpu		
		move.w		#$70,$ffff8240.w * Cpu time
		endc

		swap		d3		* Hauteur dest * 65536
		clr.w		d3
		divu.w		d1,d3		* Coef x: Dxdest*65536/Dxsource
		moveq.l		#0,d5		* Accumulateur … z‚ro
		move.l		a0,a3		* Adresses video dans a3 & a4
		move.l		a1,a4		*

		* Appel routine autogeneree : Zoom 	(non optimisee)

		ifeq	plane-3
haut3:		add.w	d3,d5		* Taux d'erreur
		bcc.s	noaff3		* Si taux>=1
		move.l	a3,a0		
		move.l	a4,a1		
		bsr	code
		lea	2(a3),a0		
		lea	2(a4),a1		
		bsr	code
		lea	4(a3),a0		
		lea	4(a4),a1		
		bsr	code
		lea	120(a4),a4
noaff3:		lea	160(a3),a3
		ifne	cpu
		not.w	$ffff8240.w
		endc
		dbra.w	d1,haut3
		endc

		ifne	cpu
		clr.w	$ffff8240.w
		endc
		
		rts

*-------------------------------------------------------------------------*
*     ROUTINE D'AUTOGENERATION						  *
*-------------------------------------------------------------------------*

tagada:		macro
		move.w		a3,(a2)+	  * Add.w  d7,d7
		add.w		d2,d5		  * Tx d'erreur
		dc.w		$640A             * Si tx>=1
		move.w		a4,(a2)+          * Addx d6,d6
		add.w		d7,d7	          * Si seize pixels destination
		dc.w		$6404		  * Bcc.s + 4
		move.l		a6,(a2)+          * Pose le plan sur l'ecran
		moveq.l		#1,d7		  * compteur
		endm

auto_g1:	
		Rept		20
		move.l		a5,(a2)+ 	  * d7 ... (move & addq)
		move.w		a3,(a2)+	  * Add.w d7,d7
		add.w		d2,d5		  * Tx d'erreur
		dc.w		$640A             * Si tx>=1
		move.w		a4,(a2)+          * Addx d6,d6
		add.w		d7,d7	          * Si seize pixels destination
		dc.w		$6404		  * Bcc.s + 4 
		move.l		a6,(a2)+          * Pose le plan sur l'ecran
		moveq.l		#1,d7		  * compteur

		tagada
		tagada
		tagada
		tagada
		tagada
		tagada
		tagada
		tagada
		tagada
		tagada
		tagada
		tagada
		tagada
		tagada
		tagada
		Endr
		rts				* Au cas ou
*-------------------------------------------------------------------------*
* Buffer pour code genere	
	
code:		DS.B	1600

*-------------------------------------------------------------------------*
	
i:		set	0
table:		rept	20		* Plan de la routine d'autogeneration
		dc.w	i
i:		set	i+18
		dc.w	i
i:		set	i+16
		dc.w	i
i:		set	i+16
		dc.w	i
i:		set	i+16
		dc.w	i
i:		set	i+16
		dc.w	i
i:		set	i+16
		dc.w	i
i:		set	i+16
		dc.w	i
i:		set	i+16
		dc.w	i
i:		set	i+16
		dc.w	i
i:		set	i+16
		dc.w	i
i:		set	i+16
		dc.w	i
i:		set	i+16
		dc.w	i
i:		set	i+16
		dc.w	i
i:		set	i+16
		dc.w	i
i:		set	i+16
		dc.w	i
i:		set	i+16
		endr
		dc.w	i

*-------------------------------------------------------------------------*
ecran:		dc.l	0
bufferec:	dc.l	0
flipec:		dc.l	0
physb:		dc.l	0
*-------------------------------------------------------------------------*
cpt:		dc.w	-1
nbimage:	dc.w	0
*-------------------------------------------------------------------------*
sprite:		incbin	conclus.bin
nb:		dc.w	0
pospr:		ds.l	100*2
arrpos:		ds.l	100*2
etap:		ds.w	100
tx:		ds.l	100*2
aleo:		incbin	aleo.bin
aleopos:	dc.l	aleo
bobs_tab:	ds.l	100
tempcpt:	dc.w	0
*-------------------------------------------------------------------------*
tabtemp:	dc.w	80
		dc.w	280
		dc.w	250
		dc.w	290
		dc.w	40
		dc.w	250
		dc.w	320
		dc.w	30
		dc.w	50
		dc.w	300
		dc.w	400
		dc.w	1

tabtext:	dc.l	text1
		dc.l	text2
		dc.l	text3
		dc.l	text4
		dc.l	text5
		dc.l	text6
		dc.l	text7
		dc.l	text8
		dc.l	text9
		dc.l	text10
		dc.l	text11

text1:		dc.b	'    INTRO SCREEN    '
		dc.b	'                    '
		dc.b	'        CODE        '
		dc.b    '     METAL AGES     '
		dc.b	'                    '
		dc.b	'      .MUSIC        '
		dc.b	'       .BIP         '
		dc.b	'                    '
		dc.b	'   RAYTRACE WORKS   '
		dc.b	'  .BRAIN BLASTER@   '

text2:		dc.b	'   LIQUID OSMOSIS   '
		dc.b	'                    '
		dc.b	'        CODE        '
		dc.b    '     METAL AGES     '
		dc.b	'                    '
		dc.b	'      .MUSIC        '
		dc.b	'      .SINIS        '
		dc.b	'                    '
	 	dc.b	'   .VIDEO WORKS     '
		dc.b	'  .BRAIN BLASTER@   '

text3:		dc.b	'     .EGYPTIA       '
		dc.b	'                    '
		dc.b	'        CODE        '
		dc.b	'        KRAG        '
		dc.b    '     METAL AGES     '
		dc.b	'                    '
		dc.b	'      .MUSIC        '
		dc.b	'       .BIP         '
		dc.b	'                    '
	 	dc.b	'     .GRAPHIX       '
		dc.b	'     METAL AGES@    '

text4:		dc.b	'  GRAPHIK SOUND II  '
		dc.b	'                    '
		dc.b	' CODE    METAL AGES '
		dc.b	'         PIPOZOR    '
		dc.b	' MUSIC              '
		dc.b	'  BIP AND METAL AGES'
		dc.b	'  SINIS             ' 
		dc.b	'            GRAPHIX '
		dc.b	' BRAIN BLASTER      '
		dc.b	' POLARIS            '
		dc.b	' METAL AGES@        '

text5:		dc.b	'                    '
		dc.b	'CYBERNETICS ROULENT '
		dc.b	'.NAME AS PAM HOUSE  '
		dc.b	'                    '
		dc.b	'CODE                '
		dc.b    ' METAL AGES         '
		dc.b	'              MUSIC '
		dc.b	'        ART OF NOISE'
		dc.b	'GRAPHIX             '
		dc.b	' BRAIN BLASTER      '
		dc.b	' POLARIS@           '

text6:		dc.b	'     .CASCADE       '
		dc.b	'                    '
		dc.b	'        CODE        '
		dc.b    '     METAL AGES     '
		dc.b    '     POSITRONIC     '
		dc.b	'                    '
		dc.b	'     .GRAPHIX       '
		dc.b	'     .POLARIS       '
		dc.b	'                    '
		dc.b	'      .MUSIC        '
		dc.b	'      .SINIS@       '

text7:		dc.b	'    SPACE FILLER    '
		dc.b	'                    '
		dc.b	'                    '
		dc.b	'        CODE        '
		dc.b    '     METAL AGES     '
		dc.b	'                    '
		dc.b	'      .MUSIC        ' 
		dc.b	'      .SINIS        '
		dc.b	'                    '
		dc.b	'   .VIDEO WORKS     '
		dc.b	'  .BRAIN BLASTER@   '


text8:		dc.b	'SHADED VISION OF ART'
		dc.b	'                    '
		dc.b	'        CODE        '
		dc.b	'        KRAG        '
		dc.b    '     METAL AGES     '
		dc.b	'                    '
		dc.b	'      .MUSIC        '
		dc.b	' THE VARIOUS ARTIST@'

text9:		dc.b	'BOBS MIGRATIONeee   '
		dc.b	' CODE    METAL AGES '
		dc.b	' MUSIC   BIP        '
		dc.b	'                    '
		dc.b	'FASTMENU            '
		dc.b	' CODE    KRAG       '
		dc.b	'                    '
		dc.b	'INFO SCREEN         '
		dc.b	' CODE   METAL AGES  '
		dc.b	' MUSIC  BIP AND REMI@'

text10:		dc.b	'       LOADER       '
		dc.b	'CODE                '
		dc.b    ' METAL AGES   MUSIC '
		dc.b	' POSITRONIC    SINIS'
		dc.b	' PIPOZOR            '
		dc.b	'            GRAPHIX '
		dc.b	'       BRAIN BLASTER'
		dc.b	'             POLARIS'
		dc.b	'                    '
		dc.b	'BOOT SECTORS        '
		dc.b	' METAL AGES@        '

text11:		dc.b	'@'

*-------------------------------------------------------------------------*
tabimg:		dc.l		image1
		dc.l		image2
		dc.l		image3
		dc.l		image4
		dc.l		image5
		dc.l		image6
		dc.l		image7
		dc.l		image8
		dc.l		image9
		dc.l		image10
		dc.l		image9
		dc.l		image9
cptimage:	dc.w		0
actimg:		dc.l		image1
ancimg:		dc.l		0

image1:		incbin		loader.neo
		ds.l		40
image2:		incbin		liquid.neo
		ds.L		40
image3:		incbin		egyptia2.neo
		ds.l		40
image4:		incbin		grafiks2.neo
		ds.l		40
image5:		incbin		motif2_2.neo
		ds.l		40
image7:		incbin		space_f.neo
		ds.l		40
image6:		incbin		cascade.neo
		ds.l		40
image9:		incbin		the_end.neo
		ds.l		40
image8:		incbin		player.neo
		ds.l		40
image10:	incbin		barload.neo
		ds.l		40

*-------------------------------------------------------------------------*
nbre_div:	set	2

MVOL	EQU $80
FREQ	EQU 1				; 0=6.259, 1=12.517, 2=25.036
					; 3=50.072 (MegaSTe/TT)

	IFEQ FREQ
LEN	EQU 125
INC	EQU $023BF313			; 3579546/6125*65536
	ELSEIF
	IFEQ FREQ-1
LEN	EQU 250
INC	EQU $011DF989			; 3579546/12517*65536
	ELSEIF
	IFEQ FREQ-2
LEN	EQU 500
INC	EQU $008EFB4E			; 3579546/25035*65536
	ELSEIF
	IFEQ FREQ-3
LEN	EQU 1000
INC	EQU $00477CEC			; 3579546/50072*65536
	ELSEIF
	FAIL
	END
	ENDC
	ENDC
	ENDC
	ENDC

;---------------------------------------------------- Interrupts on/off --
muson	bsr	vol			; Calculate volume tables
	bsr	incrcal			; Calculate tonetables

	jsr	init			; Initialize music
	jsr	prepare			; Prepare samples

	move.w	#$2700,sr
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	move.l	#stereo,$70.w
	move.b	#FREQ+1,$FFFF8921.w	; Frequency
	lea	$FFFF8907.w,a0
	move.l	#sample1,d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)
	move.l	#sample1+LEN*4,d0
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)
	move.b	#1,$FFFF8901.w		; Start DMA
	move	#$2300,sr

	rts

musoff:
	move	#$2700,sr
	clr.b	$FFFF8901.w		; Stop DMA
	rts

;--------------------------------------------------------- Volume table --
vol	moveq	#64,d0
	lea	vtabend(pc),a0

.ploop	move.w	#255,d1
.mloop	move.w	d1,d2
	ext.w	d2
	muls	d0,d2
	divs	#MVOL,d2		; <---- Master volume
	move.b	d2,-(a0)
	dbra	d1,.mloop
	dbra	d0,.ploop

	rts

vtab	DS.B 65*256
vtabend

;------------------------------------------------------ Increment-table --
incrcal	lea	stab(pc),a0
	move.w	#$30,d1
	move.w	#$039F-$30,d0
	move.l	#INC,d2

recalc	swap	d2
	moveq	#0,d3
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	swap	d4

	swap	d2
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	move.l	d4,(a0)+

	addq.w	#1,d1
	dbra	d0,recalc
	rts

itab	DS.L $30
stab	DS.L $03A0-$30

;-------------------------------------------------------- DMA interrupt --
mul:	macro
	ifeq		nbre_div-1
	elseif
	ifeq		nbre_div-2
	add.w		d0,d0
	add.w		d1,d1
	add.w		d4,d4
	add.w		d5,d5
	elseif
	ifeq		nbre_div-4
	rept		2
	add.w		d0,d0
	add.w		d1,d1
	add.w		d4,d4
	add.w		d5,d5
	endr
	elseif
	ifeq		nbre_div-8
	moveq.l		#3,d6
	lsl.w		d6,d0
	lsl.w		d6,d1
	lsl.w		d6,d4
	lsl.w		d6,d5
	else
	mulu.w	#nbre_div,d0
	mulu.w	#nbre_div,d1
	mulu.w	#nbre_div,d4
	mulu.w	#nbre_div,d5
	endc
	endc
	endc
	endc
	endm
*-------------------------------------------
tch:	dc.w	0

stereo:	
	move.b	#1,$FFFF8901.w		; Start DMA
	move.b	$fffffc02.w,tch

	movem.l	d0-a6,-(sp)
	
	ifne	cpu
	move.w	#$7,$ffff8240.w
	endc

	lea	$ffff8203.w,a0
	move.l	physb,d0
	movep.l	d0,(a0)

	move.l	samp1,d0
	move.l	samp2,samp1
	move.l	d0,samp2

	lea	$FFFF8907.w,a0

	move.l	samp1,d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)
	
	move.l	samp1,d0
	add.l	#LEN*4,d0
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)
	
	jsr	music

	lea	itab(pc),a5
	lea	vtab(pc),a3
	moveq.l	#0,d0
	moveq.l	#0,d4

v1:	movea.l	wiz2lc,a0

	move.w	wiz2pos,d0
	move.w	wiz2frc,d1

	move.w	aud2per,d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2

	movea.w	2(a5,d7.w),a4

	move.w	aud2vol,d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2

	movea.l	wiz3lc,a1

	move.w	wiz3pos,d4
	move.w	wiz3frc,d5

	move.w	aud3per,d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d6
	movea.w	2(a5,d7.w),a5

	move.w	aud3vol,d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a3

	lea	2+create1(pc),a6

	moveq.l	#20,d7
	rept	len/nbre_div
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.w	d0,(a6)
	move.w	d4,8(a6)
	add.w	d7,a6
	endr
	
	sub.w	wiz2pos(pc),d0
	sub.w	wiz2frc(pc),d1
	sub.w	wiz3pos(pc),d4
	sub.w	wiz3frc(pc),d5

	movea.l	samp1(pc),a6
	moveq.l	#0,d3
	moveq.l	#nbre_div-1,d6
create1:	
	REPT LEN/nbre_div
	move.b	2(a0),d3
	move.b	0(a2,d3.w),d7
	move.b	2(a1),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	move.w	d7,(a6)+
	ENDR
	add.w	d0,a0
	add.w	d4,a1
	dbra.w	d6,create1
	
	rept	nbre_div
	move.w	d7,(a6)+
	endr

	mul

	add.w	wiz2pos(pc),d0
	add.w	wiz2frc(pc),d1
	add.w	wiz3pos(pc),d4
	add.w	wiz3frc(pc),d5

	cmp.l	wiz2len(pc),d0
	blt.s	.ok2
	sub.w	wiz2rpt(pc),d0

.ok2	move.w	d0,wiz2pos
	move.w	d1,wiz2frc

	cmp.l	wiz3len(pc),d4
	blt.s	.ok3
	sub.w	wiz3rpt(pc),d4

.ok3	move.w	d4,wiz3pos
	move.w	d5,wiz3frc

	lea	itab,a5
	lea	vtab,a3
	moveq	#0,d0
	moveq	#0,d4

v2	movea.l	wiz1lc(pc),a0

	move.w	wiz1pos(pc),d0
	move.w	wiz1frc(pc),d1

	move.w	aud1per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2
	movea.w	2(a5,d7.w),a4

	move.w	aud1vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2

	movea.l	wiz4lc(pc),a1

	move.w	wiz4pos(pc),d4
	move.w	wiz4frc(pc),d5

	move.w	aud4per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d6
	movea.w	2(a5,d7.w),a5

	move.w	aud4vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a3

	lea	create2+2(pc),a6
	moveq.l	#24,d7
	rept	len/nbre_div
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.w	d0,(a6)
	move.w	d4,8(a6)
	add.w	d7,a6
	endr
	
	sub.w	wiz1pos(pc),d0
	sub.w	wiz1frc(pc),d1
	sub.w	wiz4pos(pc),d4
	sub.w	wiz4frc(pc),d5

	movea.l	samp1(pc),a6
	moveq.l	#0,d3
	moveq.l	#nbre_div-1,d6
var:	set	0
create2:	
	opt	o-
	REPT LEN/nbre_div
	move.b	2(a0),d3
	move.b	0(a2,d3.w),d7
	move.b	2(a1),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,var(a6)
	move.b	d7,var+2(a6)
var:	set	var+4
	ENDR
	
	opt	o+
	add.w	d0,a0
	add.w	d4,a1
	lea	(len/nbre_div)*4(a6),a6
	dbra.w	d6,create2

var:	set	0	
	rept	nbre_div
	move.B	d7,var(a6)
var:	set	var+2
	endr
	
	mul

	add.w	wiz1pos(pc),d0
	add.w	wiz1frc(pc),d1
	add.w	wiz4pos(pc),d4
	add.w	wiz4frc(pc),d5

	cmp.l	wiz1len(pc),d0
	blt.s	.ok1
	sub.w	wiz1rpt(pc),d0

.ok1	move.w	d0,wiz1pos
	move.w	d1,wiz1frc

	cmp.l	wiz4len(pc),d4
	blt.s	.ok4
	sub.w	wiz4rpt(pc),d4

.ok4	move.w	d4,wiz4pos
	move.w	d5,wiz4frc

	movem.l	(sp)+,d0-a6

	tst.w	exit2
	bne.s	okfin
	tst.w	$206.w
	beq.s	defile
	cmp.b	#57,tch
	bne.s	okfin
	jmp	fin
defile:	cmp.b	#$62,tch
	bne.s	okfin
	move.w	#-1,$206.w
	jmp	fin
okfin:
	ifne	cpu
	move.w	#$0,$ffff8240.w
	endc
	
	rte

;-------------------------------------------- Hardware-registers & data --
wiz1lc	DC.L sample1
wiz1len	DC.L 0
wiz1rpt	DC.W 0
wiz1pos	DC.W 0
wiz1frc	DC.W 0

wiz2lc	DC.L sample1
wiz2len	DC.L 0
wiz2rpt	DC.W 0
wiz2pos	DC.W 0
wiz2frc	DC.W 0

wiz3lc	DC.L sample1
wiz3len	DC.L 0
wiz3rpt	DC.W 0
wiz3pos	DC.W 0
wiz3frc	DC.W 0

wiz4lc	DC.L sample1
wiz4len	DC.L 0
wiz4rpt	DC.W 0
wiz4pos	DC.W 0
wiz4frc	DC.W 0

aud1lc	DC.L dummy
aud1len	DC.W 0
aud1per	DC.W 0
aud1vol	DC.W 0
	DS.W 3

aud2lc	DC.L dummy
aud2len	DC.W 0
aud2per	DC.W 0
aud2vol	DC.W 0
	DS.W 3

aud3lc	DC.L dummy
aud3len	DC.W 0
aud3per	DC.W 0
aud3vol	DC.W 0
	DS.W 3

aud4lc	DC.L dummy
aud4len	DC.W 0
aud4per	DC.W 0
aud4vol	DC.W 0

dmactrl	DC.W 0

dummy	DC.L 0

samp1	DC.L sample1
samp2	DC.L sample2

sample1	DS.W LEN*2+nbre_div*2
sample2	DS.W LEN*2+nbre_div*2

;========================================================= EMULATOR END ==

prepare	lea	workspc,a6
	movea.l	samplestarts(pc),a0
	movea.l	end_of_samples(pc),a1

tostack	move.w	-(a1),-(a6)
	cmpa.l	a0,a1			; Move all samples to stack
	bgt.s	tostack

	lea	samplestarts(pc),a2
	lea	data(pc),a1		; Module
	movea.l	(a2),a0			; Start of samples
	movea.l	a0,a5			; Save samplestart in a5

	moveq	#30,d7

roop	move.l	a0,(a2)+		; Sampleposition

	tst.w	$2A(a1)
	beq.s	samplok			; Len=0 -> no sample

	tst.w	$2E(a1)			; Test repstrt
	bne.s	repne			; Jump if not zero


repeq	move.w	$2A(a1),d0		; Length of sample
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a0,a4
fromstk	move.w	(a6)+,(a0)+		; Move all samples back from stack
	dbra	d0,fromstk

	bra.s	rep



repne	move.w	$2E(a1),d0
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a6,a4
get1st	move.w	(a4)+,(a0)+		; Fetch first part
	dbra	d0,get1st

	adda.w	$2A(a1),a6		; Move a6 to next sample
	adda.w	$2A(a1),a6



rep	movea.l	a0,a5
	moveq	#0,d1
toosmal	movea.l	a4,a3
	move.w	$30(a1),d0
	subq.w	#1,d0
moverep	move.w	(a3)+,(a0)+		; Repeatsample
	addq.w	#2,d1
	dbra	d0,moverep
	cmp.w	#320*5,d1		; Must be > 320
	blt.s	toosmal

	move.w	#320*5/2-1,d2
last320	move.w	(a5)+,(a0)+		; Safety 320 bytes
	dbra	d2,last320

done	add.w	d4,d4

	move.w	d4,$2A(a1)		; length
	move.w	d1,$30(a1)		; Replen
	clr.w	$2E(a1)

samplok	lea	$1E(a1),a1
	dbra	d7,roop

	cmp.l	#workspc,a0
	bgt.s	.nospac

	rts

.nospac	illegal

end_of_samples	DC.L 0

;------------------------------------------------------ Main replayrout --
init	lea	data(pc),a0
	lea	$03B8(a0),a1

	moveq.l	#$7F,d0
	moveq.l	#0,d1
loop	move.l	d1,d2
	subq.w	#1,d0
lop2	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	loop
	dbra.w	d0,lop2
	addq.b	#1,d2

	lea	samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$043C,d2
	add.l	a0,d2
	movea.l	d2,a2

	moveq.l	#$1E,d0
lop3	clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	add.l	d1,d1
	adda.l	d1,a2
	adda.l	#$1E,a0
	dbra.w	d0,lop3

	move.l	a2,end_of_samples	;
	rts

music	lea	data(pc),a0
	addq.w	#$01,counter
	move.w	counter(pc),d0
	cmp.w	speed(pc),d0
	blt.s	nonew
	clr.w	counter
	bra	getnew

nonew	lea	voice1(pc),a4
	lea	aud1lc(pc),a3
	bsr	checkcom
	lea	voice2(pc),a4
	lea	aud2lc(pc),a3
	bsr	checkcom
	lea	voice3(pc),a4
	lea	aud3lc(pc),a3
	bsr	checkcom
	lea	voice4(pc),a4
	lea	aud4lc(pc),a3
	bsr	checkcom
	bra	endr

arpeggio
	moveq	#0,d0
	move.w	counter(pc),d0
	divs	#$03,d0
	swap	d0
	tst.w	d0
	beq.s	arp2
	cmp.w	#$02,d0
	beq.s	arp1

	moveq	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	bra.s	arp3

arp1	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	bra.s	arp3

arp2	move.w	$10(a4),d2
	bra.s	arp4

arp3	add.w	d0,d0
	moveq	#0,d1
	move.w	$10(a4),d1
	lea	periods(pc),a0
	moveq	#$24,d4
arploop	move.w	0(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	arp4
	addq.l	#2,a0
	dbra	d4,arploop
	rts

arp4	move.w	d2,$06(a3)
	rts

getnew	lea	data+$043C(pc),a0
	lea	-$043C+$0C(a0),a2
	lea	-$043C+$03B8(a0),a1

	moveq	#0,d0
	move.l	d0,d1
	move.b	songpos(pc),d0
	move.b	0(a1,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	pattpos(pc),d1
	clr.w	dmacon

	lea	aud1lc(pc),a3
	lea	voice1(pc),a4
	bsr.s	playvoice
	lea	aud2lc(pc),a3
	lea	voice2(pc),a4
	bsr.s	playvoice
	lea	aud3lc(pc),a3
	lea	voice3(pc),a4
	bsr.s	playvoice
	lea	aud4lc(pc),a3
	lea	voice4(pc),a4
	bsr.s	playvoice
	bra	setdma

playvoice
	move.l	0(a0,d1.l),(a4)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$02(a4),d2
	and.b	#$F0,d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$F0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	setregs
	moveq	#0,d3
	lea	samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$01,d2
	asl.l	#2,d2
	mulu	#$1E,d4
	move.l	0(a1,d2.l),$04(a4)
	move.w	0(a2,d4.l),$08(a4)
	move.w	$02(a2,d4.l),$12(a4)
	move.w	$04(a2,d4.l),d3
	tst.w	d3
	beq.s	noloop
	move.l	$04(a4),d2
	add.w	d3,d3
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$04(a2,d4.l),d0
	add.w	$06(a2,d4.l),d0
	move.w	d0,8(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
	bra.s	setregs

noloop	move.l	$04(a4),d2
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
setregs	move.w	(a4),d0
	and.w	#$0FFF,d0
	beq	checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$03,d0
	bne.s	setperiod
	bsr	setmyport
	bra	checkcom2

setperiod
	move.w	(a4),$10(a4)
	andi.w	#$0FFF,$10(a4)
	move.w	$14(a4),d0
	move.w	d0,dmactrl
	clr.b	$1B(a4)

	move.l	$04(a4),(a3)
	move.w	$08(a4),$04(a3)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	move.w	$14(a4),d0
	or.w	d0,dmacon
	bra	checkcom2

setdma	move.w	dmacon(pc),d0

	btst	#0,d0			;-------------------
	beq.s	wz_nch1			;
	move.l	aud1lc(pc),wiz1lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud1len(pc),d1		;
	move.w	voice1+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz1len		;
	move.w	d2,wiz1rpt		;
	clr.w	wiz1pos			;

wz_nch1	btst	#1,d0			;
	beq.s	wz_nch2			;
	move.l	aud2lc(pc),wiz2lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud2len(pc),d1		;
	move.w	voice2+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz2len		;
	move.w	d2,wiz2rpt		;
	clr.w	wiz2pos			;

wz_nch2	btst	#2,d0			;
	beq.s	wz_nch3			;
	move.l	aud3lc(pc),wiz3lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud3len(pc),d1		;
	move.w	voice3+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz3len		;
	move.w	d2,wiz3rpt		;
	clr.w	wiz3pos			;

wz_nch3	btst	#3,d0			;
	beq.s	wz_nch4			;
	move.l	aud4lc(pc),wiz4lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud4len(pc),d1		;
	move.w	voice4+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz4len		;
	move.w	d2,wiz4rpt		;
	clr.w	wiz4pos			;-------------------

wz_nch4	addi.w	#$10,pattpos
	cmpi.w	#$0400,pattpos
	bne.s	endr
nex	clr.w	pattpos
	clr.b	break
	addq.b	#1,songpos
	andi.b	#$7F,songpos
	move.b	songpos(pc),d1
	cmp.b	data+$03B6(pc),d1
	bne.s	endr
	move.b	data+$03B7(pc),songpos
endr:	tst.b	break
	bne.s	nex
	rts

setmyport
	move.w	(a4),d2
	and.w	#$0FFF,d2
	move.w	d2,$18(a4)
	move.w	$10(a4),d0
	clr.b	$16(a4)
	cmp.w	d0,d2
	beq.s	clrport
	bge.s	rt
	move.b	#$01,$16(a4)
	rts

clrport	clr.w	$18(a4)
rt	rts

myport	move.b	$03(a4),d0
	beq.s	myslide
	move.b	d0,$17(a4)
	clr.b	$03(a4)
myslide	tst.w	$18(a4)
	beq.s	rt
	moveq	#0,d0
	move.b	$17(a4),d0
	tst.b	$16(a4)
	bne.s	mysub
	add.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)

myok	move.w	$10(a4),$06(a3)
	rts

mysub	sub.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	blt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)
	move.w	$10(a4),$06(a3)
	rts

vib	move.b	$03(a4),d0
	beq.s	vi
	move.b	d0,$1A(a4)

vi	move.b	$1B(a4),d0
	lea	sin(pc),a1
	lsr.w	#$02,d0
	and.w	#$1F,d0
	moveq	#0,d2
	move.b	0(a1,d0.w),d2
	move.b	$1A(a4),d0
	and.w	#$0F,d0
	mulu	d0,d2
	lsr.w	#$06,d2
	move.w	$10(a4),d0
	tst.b	$1B(a4)
	bmi.s	vibmin
	add.w	d2,d0
	bra.s	vib2

vibmin	sub.w	d2,d0
vib2	move.w	d0,$06(a3)
	move.b	$1A(a4),d0
	lsr.w	#$02,d0
	and.w	#$3C,d0
	add.b	d0,$1B(a4)
	rts

nop:	move.w	$10(a4),$06(a3)
	rts

checkcom
	move.w	$02(a4),d0
	and.w	#$0FFF,d0
	beq.s	nop
	move.b	$02(a4),d0
	and.b	#$0F,d0
	tst.b	d0
	beq	arpeggio
	cmp.b	#$01,d0
	beq.s	portup
	cmp.b	#$02,d0
	beq	portdown
	cmp.b	#$03,d0
	beq	myport
	cmp.b	#$04,d0
	beq	vib
	cmp.b	#$05,d0
	beq	port_toneslide
	cmp.b	#$06,d0
	beq	vib_toneslide
	move.w	$10(a4),$06(a3)
	cmp.b	#$0A,d0
	beq.s	volslide
	rts

volslide
	moveq	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	voldown
	add.w	d0,$12(a4)
	cmpi.w	#$40,$12(a4)
	bmi.s	vol2
	move.w	#$40,$12(a4)
vol2	move.w	$12(a4),$08(a3)
	rts

voldown	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	sub.w	d0,$12(a4)
	bpl.s	vol3
	clr.w	$12(a4)
vol3	move.w	$12(a4),$08(a3)
	rts

portup	moveq	#0,d0
	move.b	$03(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$71,d0
	bpl.s	por2
	andi.w	#$F000,$10(a4)
	ori.w	#$71,$10(a4)
por2	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

port_toneslide
	bsr	myslide
	bra.s	volslide

vib_toneslide
	bsr	vi
	bra.s	volslide

portdown
	clr.w	d0
	move.b	$03(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$0358,d0
	bmi.s	por3
	andi.w	#$F000,$10(a4)
	ori.w	#$0358,$10(a4)
por3	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$0D,d0
	beq.s	pattbreak
	cmp.b	#$0B,d0
	beq.s	posjmp
	cmp.b	#$0C,d0
	beq.s	setvol
	cmp.b	#$0F,d0
	beq.s	setspeed
	rts

pattbreak
	st	break
	rts

posjmp	move.b	$03(a4),d0
	subq.b	#$01,d0
	move.b	d0,songpos
	st	break
	rts

setvol	moveq	#0,d0
	move.b	$03(a4),d0
	cmp.w	#$40,d0
	ble.s	vol4
	move.b	#$40,$03(a4)
vol4	move.b	$03(a4),$09(a3)
	move.b	$03(a4),$13(a4)
	rts

setspeed
	cmpi.b	#$1F,$03(a4)
	ble.s	sets
	move.b	#$1F,$03(a4)
sets	move.b	$03(a4),d0
	beq.s	rts2
	move.w	d0,speed
	clr.w	counter
rts2	rts

sin	DC.B $00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
	DC.B $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1,$8D,$78,$61,$4A,$31,$18

periods	DC.W $0358,$0328,$02FA,$02D0,$02A6,$0280,$025C,$023A,$021A,$01FC,$01E0
	DC.W $01C5,$01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$FE
	DC.W $F0,$E2,$D6,$CA,$BE,$B4,$AA,$A0,$97,$8F,$87
	DC.W $7F,$78,$71,$00,$00

speed	DC.W $06
counter	DC.W $00
songpos	DC.B $00
break	DC.B $00
pattpos	DC.W $00

dmacon		DC.W $00
samplestarts	DS.L $1F

voice1	DS.W 10
	DC.W $01
	DS.W 3
voice2	DS.W 10
	DC.W $02
	DS.W 3
voice3	DS.W 10
	DC.W $04
	DS.W 3
voice4	DS.W 10
	DC.W $08
	DS.W 3

data:	dc.b	'Here'

	Section	 Bss

		DS.b	40000+81242-4		; Workspace
workspc:	DS.W	1

		ds.b	256
buffer_ec:	ds.b	256*132*2

zoom:		ds.b	252000

 