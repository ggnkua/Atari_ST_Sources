;
; Routine de point pour le GFA BASIC
; CLIPPE sans SAUVEGARDE
; By Evil Metal Of DUNE
;
; Appel en gfa par ~C:PLOT%(L:xbios(2),nb%,L:adrspoint%)
;
; Registre utilis‚ :
;
; D0 D1 D7
; A0 A1 A3 A4 A5
;
	
	movem.l	d0-d1/d7/a0-a1/a3-a5,-(sp) 	Sauvegarde registre

	move.l	4+4*8(sp),a0	xbios(2)
	move.w	8+4*8(sp),d7	nbpoints
	move.l	10+4*8(sp),a1	adresse des points

	subq.w	#1,d7		Nb point -1
	lea	deca(pc),a3	Table de d‚calage
	lea	v(pc),a4		Table de forme
	lea	ytable(pc),a5	Table y *160

plot	movem.w	(a1)+,d0/d1	Charge X et Y
	cmpi.w	#319,d0		clip en x
	bhi.s	.clip		
	cmpi.w	#199,d1		clip en y
	bhi.s	.clip
	add.w	d1,d1		Y * 2 
	move.w	(a5,d1.w),d1	Y * 160
	add.w	d0,d0		X * 2
	add.w	(a3,d0.w),d1	Decalage X
	move.w	(a4,d0.w),d0	Forme
	or.w	d0,(a0,d1.w) 	Affiche
.clip
	dbf	d7,plot		Boucle
	movem.l	(sp)+,d0-d1/d7/a0-a1/a3-a5	restitue registre
	rts			Retour au gfa

infos 	dc.b	'By Evil Metal/DUNE'
deca	incbin 	deca.inl	
v	incbin 	v.inl	
ytable	incbin 	ytable.inl		
