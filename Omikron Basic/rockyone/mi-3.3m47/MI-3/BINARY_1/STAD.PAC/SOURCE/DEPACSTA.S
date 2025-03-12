;
; Routine de d‚compactage d'une image STAD (*.PAC).
; Appel du Basic : CALL Depac (L Source, L Objet)
;
; Programmation : Pierre-Jean Goulier.
;
	movem.l	d0-d7/a0-a6,-(a7)

	move.l	4(sp),a0		; Adresse source.
	move.l	8(sp),a1		; Adresse objet
	
	move.b	4(a0),d1		; Id_Byte => D1.
	move.b	5(a0),d2		; Pack_Byte => D2.
	move.b	6(a0),d3		; Special_Byte => D3.
	
	cmpi.l	#$704d3835,(a0) 	; 1er long = "pM85" ?
	bne.s	depac_hori		; Non, d‚compactage horizontal.
	
depac_vert:
	clr.l	d0
	adda	#7,a0			; Adresse des donn‚es.
	
main_loop_vert:
	clr	d4
	move.b	(a0)+,d0		; Prendre octet de contr“le.
	cmp.b	d1,d0			; D0 = Id_Byte ?
	bne.s	special_byte_vert
	
id_byte_vert:
	move.b	(a0)+,d4		; D4 = Count.
	move.b	d2,d0			; D0 = Pack_Byte.
	bra.s	poke_vert
	
special_byte_vert:
	cmp.b	d3,d0			; D0 = Special_Byte ?
	bne.s	normal_vert
	move.b	(a0)+,d0		; D0 = Octet de donn‚e.
	bne.s	lbl10			; Si 2 octets nuls aprŠs le
	tst.b	(a0)			; Special_Byte => Fin.
	beq	exit
lbl10:	move.b	(a0)+,d4		; D4 = Count.
	bra.s	poke_vert
	
normal_vert:
	move.b	d0,(a1)+		; Recopier l'octet simplement.
	bra.s	main_loop_vert

poke_vert:
	move.b	d0,(a1)+		; Recopier N fois l'octet.
	dbra	d4,poke_vert
	bra.s	main_loop_vert
*--------------------------------------------------------------------------	
depac_hori:
	cmpi.l	#$704d3836,(a0) 	; 1er long = "pM86" ?
	bne.s	exit			; Non, fin.
	
	clr.l	d0
	adda	#7,a0			; Adresse des donn‚es.
	clr	d5			; D5 = Nombre de lignes.
	
main_loop_hori:
	clr	d4
	move.b	(a0)+,d0		; Prendre octet de contr“le.
	cmp.b	d1,d0			; D0 = Id_Byte ?
	bne.s	special_byte_hori
	
id_byte_hori:
	move.b	(a0)+,d4		; D4 = Count.
	move.b	d2,d0			; D0 = Pack_Byte.
	bra.s	poke_hori
	
special_byte_hori:
	cmp.b	d3,d0			; D0 = Special_Byte ?
	bne.s	normal_hori
	move.b	(a0)+,d0		; D0 = Octet de donn‚e.
	bne.s	lbl20			; Si 2 octets nuls aprŠs le
	tst.b	(a0)			; Special_Byte => Fin.
	beq	exit
lbl20:	move.b	(a0)+,d4		; D4 = Count.
	bra.s	poke_hori
	
normal_hori:
	move.b	d0,(a1) 		; Recopier l'octet simplement.
	adda	#80,a1			; Sauter … la ligne suivante.
	addq	#1,d5			; Incr‚menter le line count.
	cmpi	#400,d5 		; Line count = 400 ?
	bne.s	lbl30			; Non, continuer.
	clr	d5			; Oui, line count = 0.
	suba	#31999,a1		; Sauter … la ligne 1 + 1 octet.
lbl30:	bra.s	main_loop_hori
	
poke_hori:
	move.b	d0,(a1) 		; Recopier l'octet N fois.
	adda	#80,a1			; Sauter … la ligne suivante.
	addq	#1,d5			; Incr‚menter le line count.
	cmpi	#400,d5 		; Line count = 400 ?
	bne.s	lbl40			; Non, continuer.
	clr	d5			; Oui, line count = 0.
	suba	#31999,a1		; Sauter … la ligne 1 + 1 octet.
lbl40:	dbra	d4,poke_hori
	bra.s	main_loop_hori
	
exit:	
	Movem.l	(a7)+,d0-d7/a0-a6
	rts