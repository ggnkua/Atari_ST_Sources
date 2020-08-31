; compression CRAM

; version 2.1
; j'ai inclus la m‚thode 'brutale' de Didier Mequignon, et la routine tient
; dans le cache !!! Enfin, c'est encore un peu limite, mais c'est mieux.
; Je ne pensais pas que je pourrais gagner 26 octets sur la version 2.0 !

; Stabylo / The Removers

; ATTENTION. S'il y a une chose difficile … comprendre, c'est qu'on peut
; tomber en cours de d‚compression sur un mot de contr“le nul qui correspond
; en fait … un codage de 2 ou 8 couleurs. Il faut donc se brancher sur cette
; routine le cas ‚ch‚ant !!!! (mˆme avec le source C j'avais pas vu ‡a !)
********************************************************************************
	TEXT
********************************************************************************
precalculs_cram
	moveq	#-1,d0
	lea	bits_entrelaces_cram,a0
	; a b c d e f g h 
	; devient
	; a e b f c g d h
	; c'est … dire que les bits sont d'unn certaine maniŠre entrelac‚s.
.bcl	move.w	d0,d1
	move.w	d0,d2
	lsr.w	#4,d2
	clr.w	d3
	REPT	4	; octet 1
	roxr.w	#1,d1
	roxr.w	#1,d3
	roxr.w	#1,d2
	roxr.w	#1,d3
	ENDR
	lsr.w	#4,d1
	lsr.w	#4,d2
	REPT	4	; octet 2
	roxr.w	#1,d1
	roxr.w	#1,d3
	roxr.w	#1,d2
	roxr.w	#1,d3
	ENDR
	move.w	d3,(a0,d0.w*2)
	dbf	d0,.bcl
	rts
decompresse_cram8_vga
	; a0 : pointe sur le buffer de l'image copress‚e
	; d0 : taille du chunk
	; variables utilis‚es :
	;	palette_tc
	;	fin_ecran
	;	passe_ligne_cram:taille_ligne
	; nb_blocs_par_ligne ne sert plus.
	add.l	a0,d0		; fin du chunk
	move.l	d0,fin_chunk
	lea	palette_tc(pc),a1
	move.l	fin_ecran(pc),a2
	move.l	passe_ligne_cram(pc),d5
	move.w	height(pc),d4
	subq.w	#4,d4	; un bloc fait 4 lignes de hauteur !!!
	swap	d4
	move.w	d5,d4
	lsl.w	#2,d4	; taille de 4 lignes
	move.l	a2,a3
	sub.w	d5,a3	; une ligne plus bas
	move.l	a2,a5
	move.w	width(pc),d0
	lea	(a5,d0.w*2),a5	; fin de la ligne courante
	add.w	d5,d5		; taille de deux lignes
	lea	bits_entrelaces_cram,a4
	move.w	d0,d3		; nombre de blocs par ligne
	lsr.w	#2,d3		; un bloc fait 4 pixels de large
	swap	d3
	bra.s	entree_boucle_blocs_vga
***********************
code_nul_vga
	cmp.l	fin_chunk(pc),a0
	blo.s	code_2_couleurs_vga
fini_vga	rts
***********************
code_1_couleur_vga		; 40 octets
	bfextu	d0{24:8},d1
;	clr.l	d1
;	move.b	d0,d1
	move.w	(a1,d1.w*2),d2
	bfins	d2,d2{0:16}
	move.l	d2,(a2)+
	move.l	d2,(a2)+
	sub.w	d5,a2
	move.l	d2,(a3)+
	subq.w	#8,a2
	move.l	d2,(a3)+
	sub.w	d5,a3
	move.l	d2,(a2)+
	subq.w	#8,a3
	move.l	d2,(a2)+
	add.w	d5,a2
	move.l	d2,(a3)+
	move.l	d2,(a3)+
	add.w	d5,a3
***********************
		; 40+14+24+30+26+118 = 252 octets, ca passe !
		; et tout est en registre !
		; (sauf la fin du chunk qui ne sert qu'une fois par image)
boucle_blocs_vga		; 16 octets
	cmp.l	a2,a5
	bhi.s	entree_boucle_blocs_vga
;	cmp.l	fin_chunk(pc),a0
;	bhs.s	fini_vga
	sub.l	#$40000,d4
	bmi.s	fini_vga
	sub.w	d4,a5	; 4 lignes plus haut
	swap	d5
	sub.w	d5,a2	; passe … la ligne (4 lignes, plus le retour chariot)
	sub.w	d5,a3
	swap	d5
entree_boucle_blocs_vga	; 24 octets
	move.w	(a0)+,d0	; code0:code1 format intel 
	beq.s	code_nul_vga
	rol.w	#8,d0
	bpl.s	code_2_couleurs_vga	; teste si d0<$8000 non sign‚.
	clr.l	d7
	cmp.w	#$9000,d0
	bpl.s	code_8_couleurs_vga
;	move.w	d0,d1
;	and.w	#$fc00,d1
;	cmp.w	#$8400,d1	; teste si $84 <= code1 <= $87
	bfextu	d0{17:5},d1	; (on sait que le bit 15 est mis, il suffit
	subq.w	#1,d1		;  donc de tester si le champ d0{17:5} vaut 1)
	bne.s	code_1_couleur_vga
***********************
saute_blocs_vga		; 30 octets
	; on saute d0.w-$8400 blocs
	swap	d3	; nb de blocs par ligne
	sub.w	#$8400,d0	; nombre de blocs … sauter
	bra.s	.tst_vga
.bcl_vga	sub.w	d3,d0	; saute 4 lignes tant qu'on peut
	sub.w	d4,a2
	sub.w	d4,a3
	sub.w	d4,a5
	sub.l	#$40000,d4
	bmi.s	fini_vga
.tst_vga	cmp.w	d3,d0	; reste-t-il assez pour une ligne ?
	bpl.s	.bcl_vga
	lsl.w	#3,d0	; un bloc fait 8 octets de large
	add.w	d0,a2
	add.w	d0,a3
	swap	d3
	bra.s	boucle_blocs_vga
***********************
code_2_couleurs_vga		; 26 octets
	clr.l	d1
	clr.l	d2
	move.b	(a0)+,d1
	move.b	(a0)+,d2
	move.w	(a1,d1.w*2),d1
	move.w	(a1,d2.w*2),d2
	bfins	d1,d1{0:16}
	bfins	d2,d2{0:16}
	moveq	#entree_bcl2_2c_vga-entree_bcl1_vga,d7
;	lea	entree_bcl2_2c(pc),a6
;	bra.s	entree_2_couleurs
***********************
code_8_couleurs_vga		; 118 octets
	; d0 : code1:code0			a0 : flux entrant (buffer)
	; d1 : couleur 1			a1 : palette_tc
	; d2 : couleur 2			a2 : ecran
	; d3 : couleur choisie … afficher	a3 : ecran, une ligne plus bas
	; d4 : taille_ligne*4			a4 : pr‚calculs entrelas
	; d5 : passe_ligne_cram:taille_ligne*2	a5 : fin de la ligne … l'‚cran
	; d6 : compteur dbf 1			a6 : adresse de saut
	; d7 : compteur dbf 2
	lea	entree_bcl1_vga(pc,d7),a6
;	lea	entree_bcl1(pc),a6
;entree_2_couleurs
	move.w	(a4,d0.w*2),d0	; valeur pr‚calcul‚e : bits 'entrelac‚s'
	moveq	#1,d7
	moveq	#1,d6	; compteur pour bcl2
	jmp	(a6)
bcl3_vga	sub.w	d5,a2
	subq.w	#8,a2
	sub.w	d5,a3
	subq.w	#8,a3
	moveq	#1,d6	; remet le compteur pour bcl2
	jmp	(a6)
entree_bcl1_vga
	clr.l	d1
	move.b	(a0)+,d1
	clr.l	d2
	move.b	(a0)+,d2
	move.w	(a1,d1.w*2),d1	; B0
	swap	d1
	move.w	(a1,d2.w*2),d2	; A0
	swap	d2
	move.b	(a0)+,d1
	move.b	(a0)+,d2
	move.w	(a1,d1.w*2),d1	; B1
	move.w	(a1,d2.w*2),d2	; A1
bcl2_vga	swap	d1
	swap	d2
entree_bcl2_2c_vga
	move.w	d1,d3
	ror.w	#1,d0
	bcs.s	.bit_mis1_vga
	move.w	d2,d3
.bit_mis1_vga
	move.w	d3,(a2)+
	move.w	d1,d3
	ror.w	#1,d0
	bcs.s	.bit_mis2_vga
	move.w	d2,d3
.bit_mis2_vga
	move.w	d3,(a3)+
	move.w	d1,d3
	ror.w	#1,d0
	bcs.s	.bit_mis3_vga
	move.w	d2,d3
.bit_mis3_vga
	move.w	d3,(a2)+
	move.w	d1,d3
	ror.w	#1,d0
	bcs.s	.bit_mis4_vga
	move.w	d2,d3
.bit_mis4_vga
	move.w	d3,(a3)+
	dbf	d6,bcl2_vga
	dbf	d7,bcl3_vga
	add.w	d5,a2
	add.w	d5,a3
	bra	boucle_blocs_vga
******************************************************
decompresse_cram16_vga
	; a0 : pointe sur le buffer de l'image copress‚e
	; d0 : taille du chunk
	; variables utilis‚es :
	;	precalc_cram16
	;	fin_ecran
	;	passe_ligne_cram:taille_ligne
	; nb_blocs_par_ligne ne sert plus.
	
	; les labels sont les mˆmes qu'avec le CRAM8, donc ils prennent
	; tous un pr‚fixe '_'. Les variables utilis‚es sont les mˆmes
	add.l	a0,d0		; fin du chunk
	move.l	d0,fin_chunk
	lea	precalc_cram16,a1
	move.l	fin_ecran(pc),a2
	move.l	passe_ligne_cram(pc),d5
	move.w	height(pc),d4
	subq.w	#4,d4	; un bloc fait 4 lignes de hauteur !!!
	swap	d4
	move.w	d5,d4
	lsl.w	#2,d4	; taille de 4 lignes
	move.l	a2,a3
	sub.w	d5,a3	; une ligne plus bas
	move.l	a2,a5
	move.w	width(pc),d0
	lea	(a5,d0.w*2),a5	; fin de la ligne courante
	add.w	d5,d5		; taille de deux lignes
	lea	bits_entrelaces_cram,a4
	move.w	d0,d3		; nombre de blocs par ligne
	lsr.w	#2,d3		; un bloc fait 4 pixels de large
	swap	d3
	bra.s	_entree_boucle_blocs_vga
***********************
_code_nul_vga
	cmp.l	fin_chunk(pc),a0
	blo.s	_code_2_ou_8_couleurs_vga
_fini_vga	rts
***********************
_code_1_couleur_vga		; 40 octets
	rol.w	#8,d0
	move.w	(a1,d0.w*2),d2
	bfins	d2,d2{0:16}
	move.l	d2,(a2)+
	move.l	d2,(a2)+
	sub.w	d5,a2
	move.l	d2,(a3)+
	subq.w	#8,a2
	move.l	d2,(a3)+
	sub.w	d5,a3
	move.l	d2,(a2)+
	subq.w	#8,a3
	move.l	d2,(a2)+
	add.w	d5,a2
	move.l	d2,(a3)+
	move.l	d2,(a3)+
	add.w	d5,a3
***********************
		; 40+14+8+24+30+28+116 = 260 octets
		; et tout est en registre !
		; (sauf la fin du chunk qui ne sert qu'une fois par image)
_boucle_blocs_vga		; 14+8 octets
	cmp.l	a2,a5
	bhi.s	_entree_boucle_blocs_vga
;	cmp.l	fin_chunk(pc),a0
;	bhs.s	_fini_vga
	sub.l	#$40000,d4
	bmi.s	_fini_vga
	sub.w	d4,a5	; 4 lignes plus haut
	swap	d5
	sub.w	d5,a2	; passe … la ligne (4 lignes, plus le retour chariot)
	sub.w	d5,a3
	swap	d5
_entree_boucle_blocs_vga	; 24 octets
	move.w	(a0)+,d0	; code0:code1
	beq.s	_code_nul_vga
	rol.w	#8,d0		; format intel
	bpl.s	_code_2_ou_8_couleurs_vga	; teste si d0<$8000 non sign‚.
;	move.w	d0,d1
;	and.w	#$fc00,d1
;	cmp.w	#$8400,d1	; teste si $84 <= code1 <= $87
	bfextu	d0{17:5},d1	; (on sait que le bit 15 est mis, il suffit
	subq.w	#1,d1		;  donc de tester si le champ d0{17:5} vaut 1)
	bne.s	_code_1_couleur_vga
***********************
_saute_blocs_vga		; 30 octets
	; on saute d0.w-$8400 blocs
	swap	d3	; nb de blocs par ligne
	sub.w	#$8400,d0	; nombre de blocs … sauter
	bra.s	.tst_vga
.bcl_vga
	sub.w	d3,d0	; saute 4 lignes tant qu'on peut
	sub.w	d4,a2
	sub.w	d4,a3
	sub.w	d4,a5
	sub.l	#$40000,d4
	bmi.s	_fini_vga
.tst_vga
	cmp.w	d3,d0	; reste-t-il assez pour une ligne ?
	bpl.s	.bcl_vga
	lsl.w	#3,d0	; un bloc fait 8 octets de large
	add.w	d0,a2
	add.w	d0,a3
	swap	d3
	bra.s	_boucle_blocs_vga
***********************
_code_2_ou_8_couleurs_vga		; 28 octets
	move.w	(a0)+,d1	; 2 couleurs format intel
	clr.l	d7
	tst.b	d1
	bmi.s	_8_couleurs_vga
	move.w	(a0)+,d2
	move.w	(a1,d1.w*2),d1
	move.w	(a1,d2.w*2),d2
	bfins	d1,d1{0:16}
	bfins	d2,d2{0:16}
	moveq	#_entree_bcl2_2c_vga-_entree_bcl1_vga,d7
***********************		; 116 octets
	; d0 : code1:code0			a0 : flux entrant (buffer)
	; d1 : couleur 1			a1 : palette_tc
	; d2 : couleur 2			a2 : ecran
	; d3 : couleur choisie … afficher	a3 : ecran, une ligne plus bas
	; d4 : taille_ligne*4			a4 : pr‚calculs entrelas
	; d5 : passe_ligne_cram:taille_ligne*2	a5 : fin de la ligne … l'‚cran
	; d6 : compteur dbf 1			a6 : adresse de saut
	; d7 : compteur dbf 2
_8_couleurs_vga
	lea	_entree_bcl1_vga(pc,d7),a6
	move.w	(a4,d0.w*2),d0	; valeur pr‚calcul‚e : bits 'entrelac‚s'
	moveq	#1,d7
	moveq	#1,d6	; compteur pour bcl2
	jmp	(a6)
_bcl3_vga	sub.w	d5,a2
	subq.w	#8,a2
	sub.w	d5,a3
	subq.w	#8,a3
	moveq	#1,d6	; remet le compteur pour bcl2
	jmp	-2(a6)
	move.w	(a0)+,d1
_entree_bcl1_vga
	move.w	(a0)+,d2
	move.w	(a1,d1.w*2),d1	; B0
	swap	d1
	move.w	(a1,d2.w*2),d2	; A0
	swap	d2
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a1,d1.w*2),d1	; B1
	move.w	(a1,d2.w*2),d2	; A1
_bcl2_vga	swap	d1
	swap	d2
_entree_bcl2_2c_vga
	move.w	d1,d3
	ror.w	#1,d0
	bcs.s	.bit_mis1_vga
	move.w	d2,d3
.bit_mis1_vga
	move.w	d3,(a2)+
	move.w	d1,d3
	ror.w	#1,d0
	bcs.s	.bit_mis2_vga
	move.w	d2,d3
.bit_mis2_vga
	move.w	d3,(a3)+
	move.w	d1,d3
	ror.w	#1,d0
	bcs.s	.bit_mis3_vga
	move.w	d2,d3
.bit_mis3_vga
	move.w	d3,(a2)+
	move.w	d1,d3
	ror.w	#1,d0
	bcs.s	.bit_mis4_vga
	move.w	d2,d3
.bit_mis4_vga
	move.w	d3,(a3)+
	dbf	d6,_bcl2_vga
	dbf	d7,_bcl3_vga
	add.w	d5,a2
	add.w	d5,a3
	bra	_boucle_blocs_vga



******************************************************
	BSS
******************************************************
;nb_blocs_par_ligne
;	ds.w	1
;palette_tc	ds.l	1
;width	ds.l	1
fin_ecran
	ds.l	1
fin_chunk
	ds.l	1
passe_ligne_cram
	ds.l	1
