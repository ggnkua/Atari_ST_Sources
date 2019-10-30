;
; Routine de point pour le GFA BASIC
; NON CLIPPE
; By Evil Metal Of DUNE
;
; Appel en gfa par ~C:PLOT%(L:xbios(2),nb%,L:adrspoint%,L:destpoint%)
;
; Registre utilis‚ :
;
; D0 D1 D7
; A0 A1 A2 A3 A4 A5
;
	
	movem.l	d0-d1/d7/a0-a5,-(sp)	Sauvegarde registre

	move.l	4+4*9(sp),a0	xbios(2)
	move.w	8+4*9(sp),d7	nbpoints
	move.l	10+4*9(sp),a1	adresse des points
	move.l	14+4*9(sp),a2	adresse de sauvegarde

	subq.w	#1,d7		Nb point -1
	lea	deca(pc),a3	Table de d‚calage
	lea	v(pc),a4		Table de forme
	lea	ytable(pc),a5	Table y *160

plot	movem.w	(a1)+,d0/d1	Charge X et Y
	add.w	d1,d1		Y * 2 
	move.w	(a5,d1.w),d1	Y * 160
	add.w	d0,d0		X * 2
	add.w	(a3,d0.w),d1	Decalage X
	move.w	(a4,d0.w),d0	Forme
	or.w	d0,(a0,d1.w) 	Affiche
	move.w	d1,(a2)+	Sauvegarde
	dbf	d7,plot		Boucle
	movem.l	(sp)+,d0-d1/d7/a0-a5	restitue registre
	rts			Retour au gfa

infos 	dc.b	'By Evil Metal/DUNE'
deca	incbin 	f:\genst\me\deca.inl	
v	incbin 	f:\genst\me\v.inl	
ytable	incbin 	f:\genst\me\ytable.inl		
