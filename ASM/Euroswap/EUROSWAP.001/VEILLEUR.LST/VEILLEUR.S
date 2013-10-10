
;*****************************************************************
; programme VEILLEUSE (extinction de l'ecran au bout de n minutes)
; auteur  Simon de Givry	
;*****************************************************************

minutes		equ	2		;delai de n minutes

		section	text

debut
	move.l	sp,a5
	move.l	4(a5),a5		;a5=base page
	move.l	$c(a5),d0		;d0=taille text
	add.l	$14(a5),d0		;  +taille data
	add.l	$1c(a5),d0		;  +taille bss
	add.l	#256,d0			;  +base_page
	move.l	d0,taille_prg		;sauve la taille prg

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1			;superviseur
	addq.l	#6,sp

	move.l	d0,save_ssp		;sauve pile ssp
	move.w	sr,save_sr		;sauve sr
	move.w	#$2700,sr		;bloque interruptions

	moveq.l	#8,d1			;d1=frequence -> 70hz ..
	move.l	#vbl_monochrome,a2
	move.l	#new_clavier_mono,a3
	move.b	$ffff8260.w,d0		;d0=resolution
	and.b	#%11,d0
	cmp.b	#%10,d0			;est-on en 70Hz ?
	beq.s	freq
	move.l	#vbl_couleurs,a2
	move.l	#new_clavier_colo,a3
	moveq.l	#4,d1			;60hz
	move.b	$ffff820a.w,d0		;d0=mode de synchro
	and.b	#%10,d0
	tst.b	d0			;est-on en 60Hz ?
	beq.s	freq
	moveq.l	#0,d1			;50hz
freq
	lea	frequence(pc),a0
	move.l	(a0,d1.w),hertz		;initialise hertz

	clr.l	compteur_vbl		;initialise le compteur de Vbl
	move.w	#-1,allume		;ecran allume

	move.l	$118,ancien_clavier
	move.l	a3,$118			;detourne clavier

	move.l	$456.w,a0		;a0 pointeur sur adresses VBLs
	lea	4(a0),a0		;saute le pointeur GEM
	move.w	$454.w,d0		;nbre max de VBLs	
	subq.w	#2,d0			;pour le dbra .. et le ptr GEM
recherche	
	tst.l	(a0)+
	beq.s	trouve	
	dbra	d0,recherche
trouve	              ;REMARQUE : si pas de place alors ecrase derniere VBL
	move.l	a2,-(a0)		;installe notre routine vbl

	move.w	save_sr,sr		;restaure interruptions

	move.l  save_ssp,-(sp)	
	move.w	#$20,-(sp)
	trap	#1			;utilisateur
	addq.l	#6,sp

	move.w	#0,-(sp)
	move.l	taille_prg,-(sp)
	move.w	#$31,-(sp)
	trap	#1			;keep process
;bye bye ...

;*****************************************************************

new_clavier_colo		       ;appel midikey puis lance new_clavier
	clr.l	compteur_vbl		;reinitialise le compteur VBL
	move.l	ancien_clavier(pc),-(sp)	;appel de midikey
	rts

;*****************************************************************

new_clavier_mono		       ;appel midikey puis lance new_clavier
	clr.l	compteur_vbl		;reinitialise le compteur VBL
	tst.w	allume			;ecran eteint ?
	bne.s	continue
	movem.l	d0/d1/a0,-(sp)		;sauve registres dans pile
	lea	$ffff8200.w,a0		;a0=base reg video
	clr.l	d1
	movep.w	1(a0),d1	
	lsl.l	#8,d1			;d1=debut adr. ecran
attends					;attends debut affichage ecran ..
	movep.l	3(a0),d0
	and.l	#$00ffffff,d0		;d1=compteur video
	cmp.l	d0,d1
	bne.s	attends
	tst.b	$ffff8209.w
	bne.s	attends
	bclr.b	#0,$ffff820a.w		;allume ecran
	move.w	#-1,allume		;mise a jour de allume
	movem.l	(sp)+,d0/d1/a0		;restaure registres de la pile
continue
	move.l	ancien_clavier(pc),-(sp)	;appel de midikey
	rts

;*****************************************************************

liste_reg_vbl		reg	d0-d6/a0

vbl_couleurs				;notre routine vbl d'extinction
	move.l	compteur_vbl(pc),d7
allume_ecran
	tst.w	allume				;ecran eteint ?
	bne.s	eteint_ecran
	tst.l	d7				;compteur initialise ?
	bne.s	fin_vbl				;pas d'incrementation
	movem.l	couleurs(pc),liste_reg_vbl
	movem.l	liste_reg_vbl,$ffff8240.w		;allume l'ecran
	move.w	#-1,allume			;ecran allum‚
	bra.s	incremente
eteint_ecran
	cmp.l	hertz,d7			;compteur > hertz ?
	blo.s	incremente
	movem.l	$ffff8240.w,liste_reg_vbl
	movem.l	liste_reg_vbl,couleurs		;sauve les couleurs
	movem.l	eteint(pc),liste_reg_vbl
	movem.l	liste_reg_vbl,$ffff8240.w		;eteint l'ecran				
	clr.w	allume				;ecran eteint
	bra.s	fin_vbl				;pas d'incrementation
incremente
	addq.l	#1,compteur_vbl
fin_vbl
	rts

;*****************************************************************

vbl_monochrome				;notre routine vbl d'extinction
	move.l	compteur_vbl(pc),d7
	cmp.l	hertz,d7		;compteur > hertz ?
	blo.s	incremente2
	move.w	sr,save_sr_vbl
	move.w	#$2700,sr		;bloque les interruptions
	lea	$ffff8200.w,a0		;a0=base reg video
	clr.l	d1
	movep.w	1(a0),d1	
	lsl.l	#8,d1			;d1=debut adr. ecran
	movep.l	3(a0),d0
	and.l	#$00ffffff,d0		;d1=compteur video
	cmp.l	d0,d1
	bne.s	restaure_sr
	tst.b	$ffff8209.w		;au debut de l'ecran ? ...
	bne.s	restaure_sr
	bset.b	#0,$ffff820a.w		;eteint l'ecran
	clr.w	allume			;ecran eteint
restaure_sr
	move.w	save_sr_vbl,sr		;restaure le sr
	bra.s	fin_vbl2
incremente2
	addq.l	#1,compteur_vbl
fin_vbl2
	rts

;*****************************************************************

		section data

frequence
		dc.l	50*60*minutes	;delai d'effacement pour le 50Hz
		dc.l	60*60*minutes	;delai d'effacement pour le 60Hz
		dc.l	71*60*minutes	;delai d'effacement pour le 70Hz

eteint					;permet d'annuler les 16 couleurs
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
		dc.w	0

;*****************************************************************

		section	bss

compteur_vbl	ds.l	1	;compteur VBL
ancien_clavier	ds.l	1	;sauvegarde de la routine clavier du TOS
hertz		ds.l	1	;delai avant extinction
allume		ds.w	1	;booleen sur etat de l'ecran
				; -1 : allum‚ , 0 : eteint
save_ssp 	ds.l	1	;sauvegarde de la pile superviseur
save_sr		ds.w	1	;sauvegarde du reg. sr
taille_prg	ds.l	1	;sauvegarde de la taille du prg
couleurs	ds.w	16	;sauvegarde des couleurs
save_sr_vbl	ds.w	1	;sauvegarde du reg. sr ds vbl

