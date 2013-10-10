; Routine d'affichage de sprites
; au Blitter, mode 256 couleurs du
; Falcon 030
; (C'est pas universel, c'est pour mon jeu)
;
; By Dumbo, XXŠme siŠcle
;

	MC68030
	OPT	x+


; Macro de routine d'affichage de sprites
; Sauvegarde du d‚cor, puis affichage
; ParamŠtres :
;    - Num‚ro d'‚cran,
;    - Largeur en octets de l'‚cran
; Format des sprites :
;    - 1 plan de masque du sprite
;    - 6 plans successifs (non entrelac‚s) du sprite
;    - 1 plan d'ombre

affiche_sprites:	MACRO

	move.l	ecran\1,a0		; a0 = adresse ‚cran
	lea.l	sauve_decor\1,a1	; a1 = sauvegarde d‚cor
	lea.l	tab_affspr\1,a2	; a2 = adresse du tableau d'index
	move.l	#\2,d0		; d0 = largeur ‚cran en octets
	move.w	nbr_spr\1,d1	; d1 = nombre - 1 de sprites … afficher
	move.w	#-1,$ffff8a2a.w	; Pas de masque au centre
	move.b	#2,$ffff8a3a.w	; Pas de demi-teinte

affspr_mainloop\@:
; Sauvegarde du d‚cor
	move.b	#3,$ffff8a3b.w	; Source
	move.w	#-1,$ffff8a28.w	; On affiche tout au bord
	move.w	#-1,$ffff8a2c.w
	move.l	a1,(a2)		; Adresse de sauvegarde d‚cor
	move.w	#16,$ffff8a20.w	; Source d‚cor sur 8 plans
	move.w	#2,$ffff8a2e.w	; Dest. d‚cor sur 7 plans
	move.w	#2,$ffff8a30.w	; Inc. Vertical Destination
	move.w	10(a2),d3	; d3 = Y
	muls.w	d0,d3
	move.l	a0,a3		; a3 = adresse du sprite
	add.l	d3,a3		; Ajoute Y
	move.w	8(a2),d3	; d3 = X
	move.w	d3,d4
	and.w	#15,d3		; d3 = X and 15
	sub.w	d3,d4		; d4 = X and -16
	ext.l	d4
	add.l	d4,a3		; Ajoute X
	move.w	#6,d7		; 6+1 plans
	move.w	12(a2),d2	; d2 = largeur d'un plan en mots
	tst.b	d3		; (X and 15) = 0 ?
	beq.s	no_bleme1\@
	
	move.w	#$C090,d5
	sub.w	d3,d5		; d5 = $8080 + 16 - (X and 15)
	move.w	d0,d6
	lsl.w	#4,d2
	sub.w	d2,d6
	lsr.w	#4,d2
	move.w	d6,$ffff8a22.w	; Inc. Vertical source
	move.l	a1,$ffff8a32.w	; Adresse sauvegarde d‚cor
blt_lp_bl2\@:
	move.l	a3,$ffff8a24.w	; Adresse source
	move.w	14(a2),$ffff8a38.w	; Hauteur
	move.w	d2,$ffff8a36.w	; Largeur
	move.w	d5,$ffff8a3c.w	; Blitter en route
;	nop
blt_lp_bl1\@:
;	bset.b	#7,$ffff8a3c.w
;	nop
;	bne.s	blt_lp_bl1\@	; Continue jusqu'… la fin
	addq.l	#2,a3		; Plan suivant
	dbra	d7,blt_lp_bl2\@
	bra.s	fin_bleme1\@
	
no_bleme1\@:			; (X and 15) = 0
	move.w	#(\2)+16,d5
	lsl.w	#4,d2
	sub.w	d2,d5
	lsr.w	#4,d2
	move.w	d5,$ffff8a22.w	; Inc. Vertical Source
	move.l	a1,$ffff8a32.w	; Adresse destination
blt_lp_nb2\@:
	move.l	a3,$ffff8a24.w	; Adresse source
	move.w	14(a2),$ffff8a38.w	; Hauteur
	move.w	d2,$ffff8a36.w	; Largeur
	move.w	#$C000,$ffff8a3c.w	; Va, blitter !
;	nop
blt_lp_nb1\@:	
;	bset.b	#7,$ffff8a3c.w
;	nop
;	bne.s	blt_lp_nb1\@
	addq.l	#2,a3
	dbra	d7,blt_lp_nb2\@

fin_bleme1\@:
	subq.l	#2,a3		; a3 sur le 7Šme plan
	move.l	$ffff8a32.w,a1	; R‚cupŠre la nouvelle adresse du d‚cor

; Affichage du sprite
; Pose du masque
	move.l	4(a2),a4	; a4 = adresse du sprite (masque)
	addq.w	#6,d7		; d7 = 5+1 plans … masquer
	move.w	#2,$ffff8a20.w	; Inc. Hor. Source
	move.w	#2,$ffff8a22.w	; Inc. Vertical Source
	move.w	#16,$ffff8a2e.w	; Inc. Hor. Destination
	move.b	#4,$ffff8a3b.w	; NOT source AND destination
	move.w	d2,d4		; d4 = largeur du sprite
	tst.b	d3		; (X and 15) = 0 ?
	beq.s	no_bleme2\@

	addq.w	#1,d4
	move.w	d0,d5
	lsl.w	#4,d2
	sub.w	d2,d5
	lsr.w	#4,d2
	move.w	d5,$ffff8a30.w	; Inc. vertical destination
	move.w	#$C040,d5
	add.w	d3,d5
	move.l	#$ffff0000,d6
	lsr.l	d3,d6
	move.w	d6,$ffff8a2c.w	; Masque … droite
	swap	d6
	move.w	d6,$ffff8a28.w	; et … gauche
	bra.s	blt_lp_pm1\@

no_bleme2\@:
	move.w	#(\2)+16,d5
	lsl.w	#4,d2
	sub.w	d2,d5
	lsr.w	#4,d2
	move.w	d5,$ffff8a30.w	; Inc. Vertical destination
	move.w	#$C000,d5

blt_lp_pm1\@:
	subq.l	#2,a3		; Descend a3 d'un plan
	move.l	a4,$ffff8a24.w	; Source = masque
	move.l	a3,$ffff8a32.w	; Destination = a3
	move.w	14(a2),$ffff8a38.w	; Hauteur
	move.w	d4,$ffff8a36.w	; Largeur du sprite
	move.w	d5,$ffff8a3c.w
;	nop
blt_lp_pm2\@:
;	bset.b	#7,$ffff8a3c.w
;	nop
;	bne.s	blt_lp_pm2\@
	dbra	d7,blt_lp_pm1\@	; Prochain plan

	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#$20002,-(sp)
	trap	#13
	addq.l	#4,sp
	movem.l	(sp)+,d0-d7/a0-a6


; Affichage du sprite + ombre
	move.b	#7,$ffff8a3b.w	; Source OR destination
	addq.w	#7,d7		; d7 = 6 plans de sprite + 1 plan d'ombre
	addq.l	#4,a2
	move.l	a3,(a2)+		; Sauve adresse dest.
	move.w	d3,(a2)+		; Sauve (X and 15)
	move.w	d5,(a2)+		; Sauve la mise en route du blitter
	move.w	d4,(a2)+		; Sauve largeur du sprite
blt_lp_as1\@:
	move.l	a3,$ffff8a32.w	; Destination = a3
	move.w	(a2),$ffff8a38.w	; Hauteur
	move.w	d4,$ffff8a36.w	; Largeur du sprite
	move.w	d5,$ffff8a3c.w
;	nop
blt_lp_as2\@:
;	bset.b	#7,$ffff8a3c.w
;	nop
;	bne.s	blt_lp_as2\@
	addq.w	#2,a3		; et en destination
	dbra	d7,blt_lp_as1\@	; Prochain plan
	addq.l	#2,a2		; a2 pointe sur prochain spr.

	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#$20002,-(sp)
	trap	#13
	addq.l	#4,sp
	movem.l	(sp)+,d0-d7/a0-a6

	dbra	d1,affspr_mainloop\@

;	rts

	ENDM


; Macro de routine d'effa‡age des sprites
; R‚affichage du d‚cor
; ParamŠtres :
;    - Num‚ro de l'‚cran
;    - Largeur en octets de l'‚cran

recolle_decor:	MACRO

	lea.l	tab_affspr\1,a2	; a2 sur tableau
	move.w	nbr_spr\1,d1	; d1 = nbr de sprites - 1
	move.w	d1,d0
	addq.w	#1,d0
	lsl.w	#4,d0
	ext.l	d0
	add.l	d0,a2		; a2 pointe le sprite d'aprŠs
	move.w	#-1,$ffff8a2a.w	; Pas de masque central
	move.w	#$203,$ffff8a3a.w	; Pas de demi-teinte, source
	move.w	#2,$ffff8a20.w	; Inc. Hor. Source
	move.w	#2,$ffff8a22.w	; Inc. Vertical Source
	move.w	#16,$ffff8a2e.w	; Inc. Hor. Destination

affdcr_mainloop\@:
	move.w	-(a2),d0		; d0 = hauteur du sprite
	move.w	-(a2),d2		; d2 = nombre de mots/ligne … transf‚rer
	move.w	#(\2)+16,d4
	move.w	d2,d5
	lsl.w	#4,d5
	sub.w	d5,d4
	move.w	d4,$ffff8a30.w	; Inc. Vertical Destination
	move.w	-(a2),d4		; d4 = mise en route du blitter
	move.w	-(a2),d3		; d3 = X and 15
	move.l	-(a2),a1		; a1 = adresse d'affichage
	move.l	-(a2),a0		; a0 = adresse du d‚cor
	tst.b	d3		; (X and 15) = 0 ?
	beq.s	dcr_no_bleme\@

	move.l	#$ffff0000,d5
	lsr.l	d3,d5		; Rotation du masque
	move.w	d5,$ffff8a2c.w	; Masque … droite
	swap	d5
	move.w	d5,$ffff8a28.w	; et … gauche
	bra.s	dcr_fin_bleme\@

dcr_no_bleme\@:
	move.w	#-1,$ffff8a28.w	; Pas de masque
	move.w	#-1,$ffff8a2c.w

dcr_fin_bleme\@:
	move.l	a0,$ffff8a24.w	; Source : d‚cor
	move.w	#6,d5		; 7 plans
dcr_loop1\@:
	move.l	a1,$ffff8a32.w	; Adresse destination
	move.w	d2,$ffff8a36.w	; Mots par ligne
	move.w	d0,$ffff8a38.w	; Nombre de lignes
	move.w	d4,$ffff8a3c.w	; Blitter ON
;	nop
dcr_loop2\@:
;	bset.b	#7,$ffff8a3c.w
;	nop
;	bne.s	dcr_loop2\@
	addq.l	#2,a1
	dbra	d5,dcr_loop1\@

	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#$20002,-(sp)
	trap	#13
	addq.l	#4,sp
	movem.l	(sp)+,d0-d7/a0-a6

	dbra	d1,affdcr_mainloop\@

;	rts

	ENDM



	TEXT
	
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#2,sp
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,ecran1

	move.l	d0,a0
	move.w	#3999,d0
looloop:	move.l	#$55555555,(a0)+
	move.l	#$55555555,(a0)+
	move.l	#$55555555,(a0)+
	clr.l	(a0)+
	dbra	d0,looloop


;	movec	cacr,d0
;	and.w	#$fefe,d0
;	movec	d0,cacr


	affiche_sprites	1,320
	recolle_decor	1,320
	
	clr.w	-(sp)
	trap	#1



	DATA


; Sprites de l'‚cran 1
nbr_spr1:
	Dc.w	1		; Nombre de sprites - 1
tab_affspr1:
	dc.l	0,sprites+32
	dc.w	0,0,3,32
	dc.l	0,sprites+32+192*8
	dc.w	8,0,2,32
	
sprites:	incbin	'A:\ESSAISPR.SPR'

	bss

sauve_decor1:			; Tampon pour la sauvegarde
	DS.b	16384		; du d‚cor de l'‚cran 1

ecran1:	DS.l	1		; Adresse de l'‚cran 1
