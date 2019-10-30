;
;	Routine de d'effacement point pour le GFA BASIC
;	By Evil Metal Of DUNE
;
;	A0=xbios(2) A1=adresse table	D7=nbpoint
;
;	Appel en gfa par ~C:EFFACE%(L:xbios(2),nb%,L:adrspoint%)
;

	movem.l	d0-d1/d7/a0-a1,-(sp)	sauv. registre
	move.l	4+4*5(sp),a0		xbios(2)
	move.w	8+4*5(sp),d7		nbpoints
	move.l	10+4*5(sp),a1		adresse des points
	moveq	#0,d1			vide d1 pour motif d'eff.
	subq.w	#1,d7			Coz deb 0
efface	move.w	(a1)+,d0		Charge deca
	move.w	d1,(a0,d0)		efface
	dbf	d7,efface		boucle
	movem.l	(sp)+,d0-d1/d7/a0-a1 	rest. registre
	rts

infos 	dc.b	'By Evil Metal/DUNE'
