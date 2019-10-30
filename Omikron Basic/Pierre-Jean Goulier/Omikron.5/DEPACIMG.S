;
; Routine de d‚compactage d'une image IMG.
; Appel du Basic : CALL Depac (L Source, L Objet, Plan, Largeur, Hauteur)
;
; Programmation : Pierre-Jean Goulier.
;

	subi	#1,16(sp)		; Nb lignes - 1.
	
	moveq	#0,d0
	moveq	#0,d6
	move	14(sp),d0		; Largeur d'une ligne.
	divu	#16,d0			; Combien de mots ?
	move	d0,d6
	swap	d0			; Test du reste de la division.
	tst	d0
	beq.s	nul
	addq	#1,d6
nul:	moveq	#0,d0
	move	12(sp),d0		; Nb de plans.
	mulu	d0,d6
	move	d6,20(sp)		; Range nb de mots.
	mulu	#2,d6			; Nb d'octets par lignes => D6.
	
	move.l	4(sp),a0		; Adresse source.
	move	6(a0),18(sp)		; Longueur du Pattern-Run.
	move	2(a0),d0		; Longueur de l'en-tˆte en mots,
	mulu	#2,d0			; puis en octets.
	adda.l	d0,a0			; Ajouter l'en-tˆte.
	move.l	a0,a2			; Nouvelle adresse source.
	
	subi	#1,18(sp)		; Longueur du Pattern-Run - 1.
	moveq	#0,d7
	move	12(sp),d7		; Nb de plans => D5.
	move	d7,d5
	subq	#1,d7			; D7 = Nb octets … sauter pour plan
	lsl	#1,d7			; suivant (4 plans -> 6 octets.)
	swap	d7			; On commence par mettre D7 … 0.
	move	16(sp),d4		; Nb de lignes => D4.
	move.l	8(sp),a4		; Adresse objet => A4.
	move.l	a4,a3			; Mais on travaille sur A3.
	
start_plan:
	move.l	a3,a0			; Adresse de la ligne => A0.
count_plan:
	clr	d3			; Largeur d'1 ligne => D3.
	clr	d0
	cmpi.b	#0,(a2) 		; D‚but de la ligne = $0000FF ?
	bne.s	depac_line		; Non, ligne pas r‚p‚t‚e.
	cmpi.b	#0,1(a2)
	bne.s	depac_line
	cmpi.b	#$ff,2(a2)
	bne.s	depac_line
	move.b	3(a2),d0
	subi	#1,d0			; Oui, nb r‚p‚titions (-1) => D0.
	addq.l	#4,a2			; Adresse source pointe sur octet
					; de contr“le.
	
depac_line:
	cmp	14(sp),d3		; Fin de la ligne ?
	bge.s	end_line		; Oui, -> End_Line.
	clr	d1			; Non, octet de contr“le => D1.
	move.b	(a2)+,d1
	beq.s	pattern_run		; D1 = $00, -> Pattern-Run.
	cmpi.b	#$80,d1
	beq.s	bit_string		; D1 = $80 -> Bit-String.
	
	move.b	#0,d2			; Sinon, Solid-Run. Si bit 7 de
	bclr	#7,d1			; D1 = 1, alors D2 = $FF, sinon
	beq.s	.suite			; D2 = $00.
	move.b	#$ff,d2
.suite: subi	#1,d1

loop_0:
	move.b	d2,(a3)+		; On copie D2 … l'adresse objet.
	addq	#8,d3			; 1 octet de plus dans D3.
	adda	d7,a3			; On saute les autres plans, mais
	swap	d7			; seulement tous les 2 octets..
	dbf	d1,loop_0
	bra.s	depac_line
	
pattern_run:
	clr	d2
	move.b	(a2)+,d2		; Nb de r‚p‚titions - 1 du PR => D2.
	subi	#1,d2
	move.l	a2,a5
	
loop_1:
	move.l	a5,a2
	move	18(sp),d1		; Longueur du PR => D1.
	
loop_2: move.b	(a2)+,(a3)+		; On recopie le PR par octet.
	addq	#8,d3			; 1 octet de plus dans D3.
	adda	d7,a3			; Sauter les autres plans tous les
	swap	d7			; mots...
	dbf	d1,loop_2		; Boucler pour la longueur du PR.
	
	dbf	d2,loop_1		; Boucler pour le nb de r‚p‚titions.
	bra.s	depac_line		; Octet de contr“le suivant...
	
bit_string:
	clr	d2
	move.b	(a2)+,d2		; Nb d'octets - 1 … recopier
	subi	#1,d2			; tels quels => D2
	
loop_3:
	move.b	(a2)+,(a3)+		; Les recopier...
	addq	#8,d3			; Mˆme cirque...
	adda	d7,a3
	swap	d7
	dbf	d2,loop_3
	bra.s	depac_line		; Octet de contr“le suivant.
	
end_line:
	tst	d7			; C'est la fin de la ligne, on
	beq.s	.suite			; force la bascule D7 … 0.
	swap	d7
.suite: subi	#1,d5			; On passe au plan suivant.
	beq.s	end_plan		; Fini ? Oui -> End_Plan
	
	addq.l	#2,a4			; Sinon, on ajoute un mot …
	move.l	a4,a3			; l'adresse source (sauv‚e)
	clr	d3
	bra.s	depac_line		; Octet de contr“le suivant.
	
end_plan:
	move	12(sp),d5		; On remet le nb de plans => D5.
	moveq	#0,d2
	move	20(sp),d2		; Nb de mots / ligne => D2.
	lsl.l	#1,d2			; Conversion en octets.
	add.l	d2,8(sp)		; On actualise l'adresse objet.
	move.l	8(sp),a4		; qu'on recopie dans A4
	move.l	a4,a3			; et dans A3.
	tst	d0			; La ligne est-elle … r‚p‚ter ? 
	beq.s	no_repeat		; Non -> No_Repeat.
	
repeat:
	move	d6,d1			; Nb octets d'une ligne => D1.
	move.l	a0,a5			; Adresse de la ligne => A5.
.loop:	move.b	(a5)+,(a3)+		; Recopier la ligne.
	subq	#1,d1
	bne.s	.loop
	adda.l	d2,a4			; On actualise l'adresse objet dans
	move.l	a4,a3			; A4 et dans A3.
	subq	#1,d4			; D‚cr‚menter le nb de lignes et
	subq	#1,d0			; le nb de r‚p‚titions...
	bne.s	repeat
	move.l	a4,8(sp)		; On actualise l'adresse objet.
	
no_repeat:
	subi	#1,d4			; D‚cr‚menter le nb de lignes.
	bpl	start_plan		; Ligne suivante...
	
	rts
	