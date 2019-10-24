
	.globl	DoFir
	
; void DoFir(int *in,int *out,long nspl);

DoFir:
	movem.l	d0-a6,-(sp)

	move.l	a0,a5	; adresse source
	move.l	a1,a6	; adresse destination
	move.l	d0,d7	; nombre d'‚chantillons

	; Passage en superviseur
	
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,-(sp)
	
	; Filtrage
	
	lea		$FFFFA200.W,a2	; Adresse de base DSP
		
	; Tout d'abord, vider la memoire du dsp
	; en envoyant des echantillons nuls
	
	move.w	#62,d0
.FluchDsp:
	btst	#0,2(a2)		; Le DSP a-t-il fini le calcul?
	beq.s	.FluchDsp
	tst.l	4(a2)			; Lire 
	tst.l	4(a2)
	clr.l	4(a2)			; Ecrire 0
	clr.l	4(a2)
	dbf		d0,.FluchDsp

	; Envoyer les 31 premiers echantillons
	; Pour etre en phase avec la sortie du filtre
	
	move.w	#30,d0
.Phase:
	btst	#0,2(a2)		; Le DSP a-t-il fini le calcul?
	beq.s	.Phase
	tst.l	4(a2)			; Lire 
	tst.l	4(a2)
	move.w	(a5)+,5(a2)		; ecrire voie droite
	clr.b	7(a2)
	move.w	(a5)+,5(a2)		; ecrire voie gauche
	clr.b	7(a2)
	dbf		d0,.Phase

	; Puis s'occuper du reste - 32
	; On envoie un echantillon et on en lit un 

	sub.l	#32,d7
.Fir:
	btst	#0,2(a2)		; Le DSP a-t-il fini le calcul?
	beq.s	.Fir
	move.w	5(a2),(a6)+		; Lire voie droite 
	tst.b	7(a2)
	move.w	5(a2),(a6)+		; Lire voie gauche
	tst.b	7(a2)
	move.w	(a5)+,5(a2)		; ecrire voie droite
	clr.b	7(a2)
	move.w	(a5)+,5(a2)		; ecrire voie gauche
	clr.b	7(a2)
	subq.l	#1,d7
	bpl.s	.Fir

	; Enfin, on termine par les 32 derniers echantillons
	
	move.w	#31,d0
.End:
	btst	#0,2(a2)		; Le DSP a-t-il fini le calcul?
	beq.s	.End
	move.w	5(a2),(a6)+		; Lire voie droite 
	tst.b	7(a2)
	move.w	5(a2),(a6)+		; Lire voie gauche
	tst.b	7(a2)
	clr.l	4(a2)			; zero
	clr.l	4(a2)			; zero
	dbf		d0,.End

	; retour en utilisateur 

	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	movem.l	(sp)+,d0-a6
	rts
	