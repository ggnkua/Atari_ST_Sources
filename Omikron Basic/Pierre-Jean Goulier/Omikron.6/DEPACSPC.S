;
; Routine de d‚compactage d'images Spectrum (*.SPC)
;
; Appel en Basic Omikron : Call Depac(L Source, L Ecran, L Palettes, Couleur_15)
;	Source     : Adresse du fichier … d‚compacter.
;	Ecran      : Adresse physique de l'‚cran.
;	Palettes   : Adresse du buffer recevant les palettes.
;	Couleur_15 : Couleur no 15. Blanc ($777) le plus fr‚quemment.
;
; Retour : D0 = 0 => OK.
;	   D0 =-1 => Erreur.
;

	movem.l	d1-a6,-(sp)		; Sauvegarde des registres.
	lea	60(sp),a5		; R‚cup‚ration des paramŠtres.
	move.l	(a5),a6
	cmp	#$5350,(a6)		; "SP" au d‚but ?
	bne	exit			; Non => Fin.
	lea	12(a6),a0		; Adresse source.
	move.l	4(a5),a1		; Adresse ‚cran.
	moveq	#1,d1			; Saut de plans.
	moveq	#7,d2
	lea	32000(a1),a2		; Fin de l'‚cran.
	lea	8(a2),a3
	
	moveq	#39,d0			; Effacement de la 1Šre ligne.
clear:
	clr.l	(a1)+
	dbra	d0,clear
	
depac:
	move.b	(a0)+,d3		; D‚but du d‚compactage.
	ext.w	d3			; M‚thode des pack-bits.
	bpl	copy
	neg	d3
	addq	#1,d3
	move.b	(a0)+,d0
	
full:
	move.b	d0,(a1)
	add.l	d1,a1			; Saut de plan.
	exg	d1,d2
	dbra	d3,full
	bra	depac_end
	
copy:
	move.b	(a0)+,(a1)
	add.l	d1,a1
	exg	d1,d2
	dbra	d3,copy
	
depac_end:
	cmp.l	a2,a1			; Fin de l'‚cran ?
	bcs	depac			; Non => on y retourne.
	bne	exit
	addq.l	#2,a2			; On passe au plan suivant.
	lea	-31840(a2),a1
	cmp.l	a3,a2			; Fin de l'image ?
	bcs	depac			; Non => on continue.
	
	move.l	a0,d0			; On d‚compacte la palette.
	addq.l	#1,d0			; Il faut calculer le nombre
	bclr	#0,d0			; d'octets d‚compact‚s...
	lea	12(a6),a0
	sub.l	a0,d0			; On compare avec l'en-tˆte du fichier.
	cmp.l	4(a6),d0
	bne	exit			; Erreur ! => Fin.
	lea	12(a6,d0),a0		; On pointe sur la palette.
	lea	(a0),a2
	move.l	8(a5),a1
	move	#$254,d4		; Nb de palettes - 1.
	moveq	#0,d0
	move	12(a5),d1		; Couleur 15 => D1.
	
pal:
	moveq	#13,d2			; D‚compactage de la palette.
	move	(a0)+,d3
	lsr	#1,d3
	move	d0,(a1)+
	
color:
	lsr	#1,d3
	bcc	empty
	move	(a0)+,(a1)+
	dbra	d2,color
	bra	pal_end
	
empty:
	move	d0,(a1)+
	dbra	d2,color
	
pal_end:
	move	d1,(a1)+
	dbra	d4,pal
	sub.l	a2,a0			; On calcule la taille du bloc des palettes,
	cmp.l	8(a6),a0		; et on compare avec l'en-tˆte du fichier.
	
exit:
	sne	d0			; Pr‚aparation du registre D0 pour
	ext.w	d0			; le code d'erreur ‚ventuel.
	ext.l	d0
	movem.l	(sp)+,d1-a6		; On remet tout en place.
	rts				; Ciao.
	
	