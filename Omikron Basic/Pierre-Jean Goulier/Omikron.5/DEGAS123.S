;
; D‚compactage d'une image DEGAS compact‚e dans les 3 r‚solutions.
; Appel du Basic : CALL Depac (L Source, L Objet, Plan%)
;
; Programmation : Pierre-Jean Goulier.
;


	move.l	4(sp),a0		; Adresse source.
	add	#34,a0			; + l'en-tˆte => A0.
	move.l	8(sp),a1		; Adresse objet => A1.
	move	12(sp),d3		; Nb de plans => D3.
	
	clr.l	d1			; Count line = 0
	clr.l	d2			; Count word = 0
	clr.l	d7			; Count = 0
	clr.l	d4			; Autres registres = 0
	clr.l	d5
	
	move	d3,d4			; Nb d'octets … sauter pour
	sub	#1,d4			; passer au plan suivant => D4.
	lsl	#1,d4
	
	move	#160,d5 		; Nb d'octets que contient un
	divu	d3,d5			; plan par ligne => D5.
	
	
main:
	clr.l	d0
	move.b	(a0)+,d0		; Prendre octet de contr“le.
	cmp	#$80,d0 		; Le comparer … 128.
	bmi.s	normal			; Inf‚rieur => Normal.
	sub	#256,d0 		; d0=256-d0.
	neg	d0
	
loop:
	move.b	(a0),(a1)+		; Recopier l'octet suivant.
	cmp	#1,d3			; Si c'est du mono, on gagne
	beq.s	.mono			; du temps...
	bsr	cross_plan		; Sinon, entrelacer les plans !
.mono	addq	#1,d7			; Incr‚menter count.
	dbra	d0,loop 		; Le tout d0 fois.
	addq	#1,a0			; Incr‚menter la source.
	bra.s	cont
	
normal:
	move.b	(a0)+,(a1)+		; Recopier les octets suivants.
	cmp	#1,d3			; Si c'est du mono, on gagne
	beq.s	.mono			; du temps...
	bsr	cross_plan		; Sinon, entrelacer les plans !
.mono	addq	#1,d7
	dbra	d0,normal		; d0 fois.
	
cont:
	cmp	#32000,d7		; Count => 32000 ?
	ble	main			; Non, on boucle.
	rts				; Oui, fin.
	
cross_plan:
	addq	#1,d1			; Incr‚menter count line.
	cmp	#160,d1 		; Fin de la ligne ?
	bne	no_end_line		; Non, continuer.
	clr	d1			; Oui, count line = 0
	clr	d2			; Count word = 0
	rts				; Retour
	
no_end_line:
	clr.l	d6
	move	d1,d6			; Count line multiple de D5 ?
	divu	d5,d6			; C.a.d : fin d'un plan ?
	swap	d6
	tst	d6
	bne	no_end_plan		; Non, continuer.
	sub	#158,a1 		; Oui, c'est la fin d'un plan.
					; Reculer d'une ligne - 1 plan.
no_end_plan:
	addq	#1,d2			; Incr‚menter count word.
	cmp	#2,d2			; Fin d'un mot ?
	bne	no_end_word		; Non, continuer.
	clr	d2			; Oui, count word = 0.
	adda	d4,a1			; Sauter au plan suivant.
	
no_end_word:
	rts				; Retour

