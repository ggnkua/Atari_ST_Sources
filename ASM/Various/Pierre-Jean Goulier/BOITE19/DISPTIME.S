;
; Exemple de programme rÇsident en installant la routine en VBL-List.
; Cette routine affiche l'heure en permanence Ö la droite de la barre
; de menu.
; Ce programme ne peut pas àtre installÇ en AUTO, car la VBL-Queue est
; fixÇe apräs l'exÇcution des programmes AUTO.
;
; Programmation : Pierre-Jean Goulier.
; Ω Start Micro & PJG / 1994.
; Assembleur : ASSEMBLE Ω BRAINSTORM
;
	
	TEXT
	
	INCLUDE	MACROSYS.S		; Des fichiers de macros.
	INCLUDE	UTILES.S
	
vbl_ptr	EQU	$456
synchro	EQU	$FF820A
	
	getrez				; Quelle rÇsolution ?
	tst	d0
	bne.s	start			; Pas de basse rÇsolution.
	cconws	#text_norez
	crawcin
	bra.s	exit
start:	move	d0,rez			; sauvegarde de la rÇsolution.
	init_prgres			; Initialisation.
	move.l	d0,size			; Sauver la taille du programme.
	super_mode				; Passage en superviseur.
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
	add.l	#72,d0			; Si Med-Rez => Adr_Disp +144.
	move	#2,jump			;            => Saut de plan = 2.
	move	#50,sync		; Si Med-Rez, quelle est la frÇquence
	btst	#1,synchro		; de balayage ? 50 ou 60 Hz ?
	bne.s	.l1
	move	#60,sync
.l1	move.l	d0,adr_disp
	tgettime			; RÇcupÇration de l'heure systäme.
	move	d0,d1			; D1 sert de sauvegarde.
	and	#31,d0
	mulu	#2,d0			; RÇcupÇrer les secondes
	move	d0,sec			; et les ranger.
	move	d1,d0
	asr	#5,d0			; RÇcupÇrer les minutes.
	and	#63,d0
	move	d0,min
	move	d1,d0
	move	#11,d2			; RÇcupÇrer les heures.
	asr	d2,d0
	and	#31,d0
	move	d0,heu
	move.l	(sp)+,a1		; Coucou, la revoilÖ !
	move.l	#display_time,(a1)
	user_mode save_usp
	move.l	size,d0
	ptermres d0			; Fin de programme rÇsident.
	
display_time:
	move	sr,-(sp)		; Sauvegarde de tous les registres.
	movem.l	d0-a6,-(sp)
	moveq	#0,d3			; D3 = Offset d'affichage.
	move	heu(pc),d0		; Affichage de l'heure.
	bsr	cut_value
	inc	d3
	bsr	test_plan
	move	#10,d1			; Affichage des ":".
	bsr	print_char
	inc	d3
	bsr	test_plan
	move	min(pc),d0
	ext.l	d0
	bsr.s	cut_value
	inc	d3
	bsr	test_plan
	move	#10,d1
	bsr	print_char
	inc	d3
	bsr	test_plan
	move	sec(pc),d0
	ext.l	d0
	bsr.s	cut_value
	
	move	sec(pc),d0		; RÇcupÇrer les donnÇes pour les actualiser.
	move	min(pc),d1
	move	heu(pc),d2
	move	counter(pc),d4		; Compteur de VBL.
	inc	d4
	cmp	sync(pc),d4		; 72/60/50 VBL = 1 seconde.
	bne.s	.lbl1
	inc	d0			; IncrÇmenter les secondes.
	moveq	#0,d4
	cmp	#60,d0
	bne.s	.lbl1
	moveq	#0,d0
	inc	d1			; IncrÇmenter les minutes.
	cmp	#60,d1
	bne.s	.lbl1
	moveq	#0,d1
	inc	d2			; IncrÇmenter les heures
	cmp	#24,d2
	bne.s	.lbl1
	moveq	#0,d2
	
.lbl1	move	d0,sec
	move	d1,min
	move	d2,heu
	move	d4,counter
	movem.l	(sp)+,d0-a6		; Restauration des registres.
	move	(sp)+,sr
	rts				; Fin de la routine.
	
cut_value:				; La valeur est dans D0.
	divu	#10,d0
	move	d0,d1
	bsr.s	print_char
	inc	d3
	bsr.s	test_plan
	swap	d0
	move	d0,d1
	bsr.s	print_char
	rts	
					; D3 = Offset d'affichage.
print_char:				
	move.l	adr_disp,a2		; Adresse d'affichage +
	adda.l	d3,a2			; offset => A2.
	move	rez(pc),d7
	cmp	#2,d7
	bne.s	.med
	mulu	#16,d1			; 16 bytes pour un caractäre.
	lea	monaco_16x8(pc),a1	; DÇpart de la table + nb d'octets
	adda.l	d1,a1			; => A1 = Adresse du caractäre.
	move	#15,d2			; D2 = compteur de lignes.
.loop	move.b	(a1)+,(a2)		; Affichage du caractäre.
	adda.l	#80,a2
	dbra	d2,.loop
	rts
	
.med	mulu	#8,d1			; 8 bytes pour un caractäre.
	lea	monaco_8x8(pc),a1	; DÇpart de la table + nb d'octets
	adda.l	d1,a1			; => A1 = Adresse du caractäre.
	move	#7,d2			; D2 = compteur de lignes.
.loop1	move.b	(a1),(a2)		; Affichage du caractäre plan par plan.
	move.b	(a1)+,2(a2)
	adda.l	#160,a2
	dbra	d2,.loop1
	rts

test_plan:
	btst	#0,d3			; On teste la paritÇ de D3.
	bne.s	.imp
	add	jump(pc),d3		; On saute au plan suivant.	
.imp	rts

	
	DATA

text_norez:
	DC.B	10,13,"Display-Time installation aborted !"
	DC.B	10,13,"Only High or Medium resolution."
	DC.B	10,13,"Sorry, press any key.",0
text_good:
	DC.B	10,13,"Display-Time installed ! / Ω PJG 94",0
text_nogood:
	DC.B	10,13,"Display-Time installation aborted !"
	DC.B	10,13,"8 programs already in VBL !",0

	EVEN
		
monaco_16x8:
	DC.B	$00,$00,$00,$3C,$66,$6E,$6E,$76,$76,$66,$66,$3C,$00,$00,$00,$00	; 0
	DC.B	$00,$00,$00,$18,$38,$18,$18,$18,$18,$18,$18,$18,$00,$00,$00,$00	; 1
	DC.B	$00,$00,$00,$3C,$46,$06,$06,$0E,$1C,$38,$70,$7E,$00,$00,$00,$00	; 2
	DC.B	$00,$00,$00,$7E,$0C,$18,$3C,$06,$06,$06,$46,$3C,$00,$00,$00,$00	; 3
	DC.B	$00,$00,$00,$04,$0C,$1C,$2C,$4C,$8C,$FE,$0C,$0C,$00,$00,$00,$00	; 4
	DC.B	$00,$00,$00,$7E,$60,$60,$7C,$06,$06,$06,$46,$3C,$00,$00,$00,$00	; 5
	DC.B	$00,$00,$00,$1C,$20,$60,$7C,$66,$66,$66,$66,$3C,$00,$00,$00,$00	; 6
	DC.B	$00,$00,$00,$7E,$06,$06,$06,$0C,$18,$18,$18,$18,$00,$00,$00,$00	; 7
	DC.B	$00,$00,$00,$3C,$66,$66,$66,$3C,$66,$66,$66,$3C,$00,$00,$00,$00	; 8
	DC.B	$00,$00,$00,$3C,$66,$66,$66,$66,$3E,$06,$0C,$38,$00,$00,$00,$00	; 9
	DC.B	$00,$00,$00,$00,$00,$18,$18,$00,$00,$00,$18,$18,$00,$00,$00,$00	; :	
	
monaco_8x8:
	DC.B	$3C,$66,$6E,$76,$66,$66,$3C,$00	; 0
	DC.B	$18,$38,$18,$18,$18,$18,$18,$00	; 1
	DC.B	$3C,$66,$0E,$1C,$38,$70,$7E,$00	; 2
	DC.B	$7E,$0C,$18,$3C,$06,$46,$3C,$00	; 3
	DC.B	$0C,$1C,$2C,$4C,$7E,$0C,$0C,$00	; 4
	DC.B	$7E,$60,$7C,$06,$06,$46,$3C,$00	; 5
	DC.B	$1C,$20,$60,$7C,$66,$66,$3C,$00	; 6
	DC.B	$7E,$06,$0E,$1C,$18,$18,$18,$00	; 7
	DC.B	$3C,$66,$66,$3C,$66,$66,$3C,$00	; 8
	DC.B	$3C,$66,$66,$3E,$06,$0C,$38,$00	; 9
	DC.B	$18,$18,$00,$00,$00,$18,$18,$00	; :
	
sync:	DC.W	72
jump:	DC.W	0
	
	
	BSS

counter:
	DS.W	1	
heu:	DS.W	1
min:	DS.W	1
sec:	DS.W	1
rez:	DS.W	1	
size:	DS.L	1
save_usp:
	DS.L	1
adr_disp:
	DS.L	1
	