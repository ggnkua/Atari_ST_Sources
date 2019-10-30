;
; Routine d'affichage d'une image Spectrum.
;
; Appel du Basic Omikron : Call Display(L Palettes)
;	Palettes : Adresse des palettes.
;
; Attention ! N‚cessit‚ absolue de :
;	1 - Sauver la palette courante
;	2 - Sauver r‚solution et synchro.
;	3 - Sauver vecteur de routine de la
;	    liste VBL.
;	4 - D‚connecter la souris.
;
	    
	    
synchro	equ	0		; 1 = 50 Hz
				; 0 = 60 Hz


	move.l	4(sp),d5		; On r‚cupŠre l'adresse pour les palettes.
	move.b	#0,$ff8260		; Passage en basse r‚solution,
	move.b	#synchro*2,$ff820a	; et … la fr‚qence souhait‚e.
	lea	spectrum(pc),a0		; Notre routine … la place de celle
	move.l	a0,$4ce			; de la liste VBL...
	rts				; Et c'est tout !
	
spectrum:
	tst	$43e.w			; Si le lecteur tourne,
	bne	spc_fin			; on ne peut rien afficher !
	move	sr,-(sp)		; On sauve le registre d'‚tat,
	ori	#$700,sr		; et on inhibe les interruptions.
	lea	spc_sync(pc),a0		; Adresse des NOPs,
	lea	$ff8240,a1		;         des couleurs,
	lea	$ff8209,a2		;         du pointeur vid‚o bas,
	move.l	d5,a3			;         et des palettes.
	lea	(a1),a4			; Affichage des couleurs.
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	moveq	#0,d0			; Pour 199 lignes.
	move	#197,d1			; (198 + la derniŠre)
	
spc_wait:
	tst.b	(a2)			; Attente du d‚but de l'‚cran.
	beq.s	spc_wait
	move.b	(a2),d0
	jmp	0(a0,d0)		; Et saut dans les NOPs.
	
spc_sync:
	rept	120
	nop
	endr
	
spc_bcl:
	rept	1+synchro
	nop
	endr
	
	lea	(a1),a4			; Affichage des couleurs...
	lea	(a1),a5
	lea	(a1),a6
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a5)+
	move.l	(a3)+,(a5)+
	move.l	(a3)+,(a5)+
	move.l	(a3)+,(a5)+
	move.l	(a3)+,(a5)+
	move.l	(a3)+,(a5)+
	move.l	(a3)+,(a5)+
	move.l	(a3)+,(a5)+
	move.l	(a3)+,(a6)+
	move.l	(a3)+,(a6)+
	move.l	(a3)+,(a6)+
	move.l	(a3)+,(a6)+
	move.l	(a3)+,(a6)+
	move.l	(a3)+,(a6)+
	move.l	(a3)+,(a6)+
	move.l	(a3)+,(a6)+
	dbra	d1,spc_bcl		; ... pour les 198 lignes.
	
	rept	4+synchro
	nop
	endr
	
	lea	(a1),a4			; Puis la derniŠre ligne !
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	
	move	(sp)+,sr		; On remet en place le registre d'‚tat.
	
spc_fin:
	rts
	
	end
	
	