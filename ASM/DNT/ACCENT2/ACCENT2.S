;Cette version de ACCENT.PRG est tirÇ de celle publiÇe dans ST-MAG No56
;par Feroce Lapin (the savage rabbit,qui se goinfre avec de l'Authentique).
;
;Petites amÇliorations de NulloS//DNT:
;	_les accents graves sont gÇrÇs,
;	_tous les trÇmas aussi,
;	_Le code est plus optimisÇ,
;	_prend moins de place en TSR,
;	_y'a un bug en moins.
;
; Ah oui: ce petit programme doit àtre placÇ dans le dossier AUTO.
; Il permet d'avoir les caractäres accentuÇs de la fonte systäme.
; Par exemple, essayez de taper les lettres suivantes sans son aide:
; ÉàåìñÑâãîÅòï
; VoilÖ. Il est extràmement utile, croyez-moi.
;
;A++

	OUTPUT	.PRG

	SECTION	TEXT
depart	bra	start
XBRAbase	dc.b	"XBRA"
	dc.b	"ACC2"
ANC_TRAP	dc.l	0
NEW_TRAP	lea	6(a7),a0
	btst.b	#5,(a7)
	bne.s	super
	move.l	usp,a0

super	cmpi.w	#2,(a0)
	bne.s	no_bconin
	cmpi.w	#2,2(a0)
	beq.s	clavier
	bra.s	jmp_old

no_bconin	cmpi.w	#1,(a0)+
	bne.s	jmp_old
	cmpi.w	#2,(a0)
	bne.s	jmp_old
	lea	sauve_code(pc),a0
	tst.l	(a0)
	beq.s	jmp_old
	moveq.l	#-1,d0
	rte

clavier	lea	sauve_code(pc),a1
	move.l	(a1),d0
	beq.s	read_it
	clr.l	(a1)
	rte

bios_call	move.l	a0,-(sp)
	move.l	#$20002,-(sp)
	pea	retour(pc)
	move.w	sr,-(sp)
jmp_old	movea.l	ANC_TRAP(pc),a0
	jmp	(a0)
retour	addq.l	#4,sp
	movea.l	(sp)+,a0
	rts

read_it	bsr.s	bios_call
	move.l	d0,d2
	lea	tab_circonflexe(pc),a0
	cmpi.b	#"^",d0
	beq.s	traite
	lea	tab_trema(pc),a0
	cmpi.b	#"π",d0
	beq.s	traite
	lea	tab_grave(pc),a0
	cmpi.b	#"`",d0
	beq.s	traite
	rte

traite	bsr.s	bios_call
	moveq	#0,d1
	move.b	(a0),d1
	swap	d1
	move.b	(a0)+,d1
boucle	cmp.b	(a0)+,d0
	beq.s	find_it
	dbf	d1,boucle
	cmp.b	d0,d2
	beq.s	its_accent
	lea	sauve_code(pc),a1
	move.l	d0,(a1)
its_accent	move.l	d2,d0
	rte

find_it	moveq	#0,d0
	swap	d1
	move.b	0(a0,d1.w),d0
	rte

sauve_code	dc.l	0

tab_circonflexe
	dc.b	$05-1
	dc.b	$61,$65,$69,$6f,$75
	dc.b	$83,$88,$8c,$93,$96
;Dans l'ordre,	 a   e   i   o   u

tab_trema
	dc.b	$09-1
	dc.b	$61,$65,$69,$41,$6f,$4f,$55,$75,$79
	dc.b	$84,$89,$8b,$8e,$94,$99,$9a,$81,$98
;		 a   e   i   A   o   O   U   u   y
tab_grave
	dc.b	$06-1
	dc.b	$6f,$75,$65,$69,$61,$41
	dc.b	$95,$97,$8a,$8d,$85,$b6
;		 o   u   e   i   a   A  
;--------------------------------------------------------
FinTSR	equ	*
	EVEN
start	clr.l	-(sp)		;superviseur
	move.w	#$20,-(sp)		;hop
	trap	#1
	move.l	d0,2(sp)		;direct appel Super suivant
	movea.l	$b4.w,a0		;cherche vecteur BIOS
cherche	cmpi.l	#"XBRA",-12(a0)	;XBRA chunck ?
	bne.s	mise_en_place	;non,on est pas lÖ
	cmpi.l	#"ACC2",-8(a0)	;c'est nous ?
	movea.l	-4(a0),a0		;prochain XBRA,conserve CCR
	bne.s	cherche		;c'etait pas nous

its_me	trap	#1		;si,c'Çtait nous
	addq.l	#6,sp		;passe en user,rÇtablit pile
	pea	deja_la(pc)	;affiche
	move.w	#9,-(sp)		;vroom
	trap	#1		;hop
	clr.w	(sp)		;maintenant,cassos
	trap	#1

mise_en_place
	move.l	$b4.w,ANC_TRAP	;ancienne vecteur du BIOS

	lea	XBRAbase(pc),a0	;Installe routines dans la
	lea	-128-4(a0),a1	;ligne de commande de notre
binst	move.b	(a0)+,(a1)+	;BasePage.Attention, surtout
	cmpa.l	#FinTSR,a0		;ne pas se servir de la DTA
	bne.s	binst		;(FSFIRST et autres) sinon la
				;ligne de commande est ÇcrasÇe.

	move.l	#NEW_TRAP-132,$b4.w	;Nouveau vecteur.
	trap	#1		;repasse en user
	addq.l	#6,sp
	pea	en_place(pc)	;affiche une petite bienvenue
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	clr.w	-(sp)		;fill-byte
	move.l	#FinTSR-XBRAbase+128,-(sp) ;taille Ö conserver
	move.w	#$31,-(sp)		;PtermRes
	trap	#1		;go!


	SECTION	DATA
en_place	dc.b	13,10,27,"pAccent 2 installÇ !",27,"q",13,10,0
deja_la	dc.b	13,10,27,"pAccent 2 dÇjÖ rÇsident...",27,"q",13,10,0


