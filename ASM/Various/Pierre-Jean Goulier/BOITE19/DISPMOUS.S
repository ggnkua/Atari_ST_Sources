;
; Exemple de programme rÇsident en installant la routine en VBL-List.
; Cette routine affiche les coordonnÇes de la souris en permanence Ö la
; droite de la barre de menu.
; Ce programme ne peut pas àtre installÇ en AUTO, car la VBL-List est
; fixÇe apräs l'exÇcution des programmes AUTO.
;
; Programmation : Pierre-Jean Goulier.
; Ω Start Micro & PJG / 1994.
; Assembleur : ASSEMBLE Ω BRAINSTORM
;
	
	TEXT
	
	INCLUDE MACROSYS.S		; Des fichiers de macros.
	INCLUDE UTILES.S
	
vbl_ptr EQU	$456
	
	getrez				; Quelle rÇsolution ?
	tst	d0
	bne.s	start
	cconws	#text_norez		; Pas de basse rÇsolution !
	crawcin				; On attend une touche,
	bra.s	exit			; et on sort.
start:	move	d0,rez			; Sauvegarde de la rÇsolution.
	init_prgres			; Initialisation du prg rÇsident.
	move.l	d0,size 		; Sauver la taille du programme.
	super_mode			; Passage en superviseur.
	move.l	d0,save_usp		; Sauvegarde du ptr.
	
	move.l	vbl_ptr,a1		; Y-a-t'il de la place dans
	move	#7,d1			; la VBL-List ?
.loop	move.l	(a1)+,d0
	beq.s	ok			; Oui => OK.
	dbra	d1,.loop
	cconws	#text_nogood		; Non => Installation abandonnÇe.
	user_mode save_usp		; Passage en utilisateur.
exit:	pterm0				; Fin
	
					; Installation du programme.
ok:	suba.l	#4,a1			; L'adresse a ÇtÇ incrÇmentÇe par le dernier "(a1)+".
	move.l	a1,-(sp)		; On la sauve, car on a des choses Ö faire avant...
	cconws	#text_good
	physbase			; Adresse d'affichage => Adr_Disp.
	add.l	#72,d0
	move	rez(pc),d1		; D1 = RÇsolution.
	cmp	#1,d1
	bne.s	.l1
	add.l	#72,d0			; Si Med-Rez, Adr_Disp => +144.
	move	#2,jump 		; Si Med-Rez, saut de plan = 2.
.l1	move.l	d0,adr_disp
	init_linea			; Initialisation de la line A.
	move.l	d0,start_linea		
	move.l	(sp)+,a1		; Coucou, la revoilÖ !
	move.l	#display_mouse,(a1)
	user_mode save_usp
	move.l	size,d0
	ptermres d0			; Fin de programme rÇsident.

display_mouse:
	move	sr,-(sp)		; Sauvegarde de tous les registres.
	movem.l d0-a6,-(sp)
	moveq	#0,d3			; D3 = Offset d'affichage.
	move.l	start_linea,a0
	move	-602(a0),d0		; CoordonnÇe X de la souris.
	bsr.s	cut_value		; Analyse de la valeur.
	addq	#2,d3			; Un espace entre X et Y.
	bsr	test_plan		; + Çventuellement un saut de plan.
	move	-600(a0),d0		; CoordonnÇe Y de la souris.
	bsr.s	cut_value
	movem.l (sp)+,d0-a6		; Restauration des registres.
	move	(sp)+,sr
	rts				; Fin de la routine.
	
cut_value:				; La valeur est dans D0.
	ext.l	d0			; On annule les bits de gauche.
	divu	#100,d0 		; Fragmentation de D0 en base 10.
	move	d0,d1
	bsr.s	print_char		; Affichage du caractäre.
	inc	d3			; IncrÇmentation de l'offset.
	bsr.s	test_plan
	swap	d0			; etc...
	ext.l	d0
	divu	#10,d0
	move	d0,d1
	bsr.s	print_char
	inc	d3
	bsr.s	test_plan
	swap	d0
	move	d0,d1
	bsr.s	print_char
	rts
	
					; Affichage du caractäre.
					; D1 = Valeur Ö afficher.
					; D3 = Offset d'affichage.
print_char:				
	move.l	adr_disp,a2		; Adresse d'affichage +
	adda.l	d3,a2			; offset => A2.
	move	rez(pc),d7
	cmp	#2,d7
	bne.s	.med			; On est en moyenne rÇsolution.
	mulu	#16,d1			; 16 bytes pour un caractäre.
	lea	monaco_16x8(pc),a1	; DÇpart de la table + nb d'octets
	adda.l	d1,a1			; => A1 = Adresse du caractäre.
	move	#15,d2			; D2 = compteur de lignes.
.loop	move.b	(a1)+,(a2)		; Affichage du caractäre.
	adda.l	#80,a2			; 80 octets par ligne.
	dbra	d2,.loop
	rts

					; Affichage moyenne rÇsolution.	
.med	mulu	#8,d1			; 8 bytes pour un caractäre.
	lea	monaco_8x8(pc),a1	; DÇpart de la table + nb d'octets
	adda.l	d1,a1			; => A1 = Adresse du caractäre.
	move	#7,d2			; D2 = compteur de lignes.
.loop1	move.b	(a1),(a2)		; Affichage du caractäre plan par plan.
	move.b	(a1)+,2(a2)
	adda.l	#160,a2			; 160 octets par ligne.
	dbra	d2,.loop1
	rts

test_plan:
	btst	#0,d3			; On teste la paritÇ de D3.
	bne.s	.imp
	add	jump(pc),d3		; On saute au plan suivant.	
.imp	rts

	
	DATA

text_norez:
	DC.B	10,13,"Display-Mouse installation aborted !"
	DC.B	10,13,"Only High or Medium resolution."
	DC.B	10,13,"Sorry, press any key.",0
text_good:
	DC.B	10,13,"Display-Mouse installed ! / Ω PJG 94",0
text_nogood:
	DC.B	10,13,"Display-Mouse installation aborted !"
	DC.B	10,13,"8 programs already in VBL !",0

	EVEN
		
monaco_16x8:
	DC.B	$00,$00,$00,$3C,$66,$6E,$6E,$76,$76,$66,$66,$3C,$00,$00,$00,$00 ; 0
	DC.B	$00,$00,$00,$18,$38,$18,$18,$18,$18,$18,$18,$18,$00,$00,$00,$00 ; 1
	DC.B	$00,$00,$00,$3C,$46,$06,$06,$0E,$1C,$38,$70,$7E,$00,$00,$00,$00 ; 2
	DC.B	$00,$00,$00,$7E,$0C,$18,$3C,$06,$06,$06,$46,$3C,$00,$00,$00,$00 ; 3
	DC.B	$00,$00,$00,$04,$0C,$1C,$2C,$4C,$8C,$FE,$0C,$0C,$00,$00,$00,$00 ; 4
	DC.B	$00,$00,$00,$7E,$60,$60,$7C,$06,$06,$06,$46,$3C,$00,$00,$00,$00 ; 5
	DC.B	$00,$00,$00,$1C,$20,$60,$7C,$66,$66,$66,$66,$3C,$00,$00,$00,$00 ; 6
	DC.B	$00,$00,$00,$7E,$06,$06,$06,$0C,$18,$18,$18,$18,$00,$00,$00,$00 ; 7
	DC.B	$00,$00,$00,$3C,$66,$66,$66,$3C,$66,$66,$66,$3C,$00,$00,$00,$00 ; 8
	DC.B	$00,$00,$00,$3C,$66,$66,$66,$66,$3E,$06,$0C,$38,$00,$00,$00,$00 ; 9
	
monaco_8x8:
	DC.B	$3C,$66,$6E,$76,$66,$66,$3C,$00 ; 0
	DC.B	$18,$38,$18,$18,$18,$18,$18,$00 ; 1
	DC.B	$3C,$66,$0E,$1C,$38,$70,$7E,$00 ; 2
	DC.B	$7E,$0C,$18,$3C,$06,$46,$3C,$00 ; 3
	DC.B	$0C,$1C,$2C,$4C,$7E,$0C,$0C,$00 ; 4
	DC.B	$7E,$60,$7C,$06,$06,$46,$3C,$00 ; 5
	DC.B	$1C,$20,$60,$7C,$66,$66,$3C,$00 ; 6
	DC.B	$7E,$06,$0E,$1C,$18,$18,$18,$00 ; 7
	DC.B	$3C,$66,$66,$3C,$66,$66,$3C,$00 ; 8
	DC.B	$3C,$66,$66,$3E,$06,$0C,$38,$00 ; 9

jump:	dc.w	0
	
	
	BSS
	
rez:	DS.W	1	
size:	DS.L	1
save_usp:
	DS.L	1
start_linea:
	DS.L	1
adr_disp:
	DS.L	1
	