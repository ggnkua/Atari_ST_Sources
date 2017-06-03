***************************************************************************
* 	Routine de relocation 						  *
***************************************************************************

reloc:	move.l	a0,-(a7)		; Empile adresse du programme
	move.l	2(a0),d0		; D0 = Nombre octets zone texte
	add.l	6(a0),d0		; + Nombre octets zone data
	add.l	$e(a0),d0		; + Nombre octet table des symboles 
	lea	$1c(a0),a0		; A0 pointe sur debut code

	movea.l	a0,a1			; A1 = A0 = Adresse debut code
	movea.l	a0,a2			; A2 = A0 = Adresse debut code
	move.l	a0,d1			; D1 = A0 = Valeur adr debut code
	adda.l	d0,a1			; A1 = A1 + D0 
					; A1 = Adresse table de relocation
	move.l	(a1)+,d0		; D0 = Premier offset pour trouver
					; la prochaine adresse … modifier

	adda.l	d0,a2			; A2 = A2 + D0
					; A2 = Adresse de la relocation
	add.l	d1,(a2)			; A2 = A2 + D1
					; Ajoute l'adresse du debut du code
					; … la valeur … reloger
	moveq	#0,d0			; Raz de d0

reloc2:	move.b	(a1)+,d0		; D0 = Offset du mot long suivant
	beq.s	f_reloc			; Si d0 = 0, fin de la relocation
	cmp.b	#1,d0			; Si d0 = 1, c'est qu'il y … plus
	beq.s	reloc3			; de $fe octet avant la prochaine
					; info … reloger
	adda.l	d0,a2			; A2 = A2 + D0
					; A2 = Adresse de la relocation
	add.l	d1,(a2)			; A2 = A2 + D1
					; Ajoute l'adresse du debut du code
					; … la valeur … reloger
	bra.s	reloc2			; Reboucle
reloc3:	lea	$fe(a2),a2		; A2 = A2 + $FE
	bra.s	reloc2			; Reboucle
f_reloc:move.l	(a7)+,a0		; Restaure A0 
	rts				; Fin s/p
