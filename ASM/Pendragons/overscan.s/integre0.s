**********************************************************************
*                                                                    *
*  INTêGRATEUR PAR SENGAN SHORT. (C) 1991 L'AUTEUR                   *
*    En aucun cas l'auteur serait responsable d'un quelconque domage *
*  du Ö l'utilisation ou l'incapacitÇ Ö utiliser ce programme. C'est *
*  Ö dire vous l'utilisez Ö vos risques et pÇrils. Vous avez intÇràt *
*  Ö sauvegarder votre code source avant de dÇmarrer l'intÇgrateur.  *
*   L'intÇgrateur ne fonctionne que sur ATARI STF/STE standard avec  *
* un 68000 tournant Ö 8 MHz...                                       *
*                                                                    *
**********************************************************************

; Commentaires
; Les lignes annotÇs de ;; comme commentaire indiquent le code source
; en exemple.
; Tout commentaire devent une dirrective Ö l'assembleur reconnue par
; l'intÇgrateur (REPT et ENDR dans ce cas) ne sera pas inclus dans le
; code source gÇnÇrÇ.
; REPT 0 marche pas: le rÇsultat sera REPT 1

**********************************************************************

		OPT D+	; êtiquettes dans le dÇbuggeur
Startup_Seq_Flag:	; Variable Interne (dÇclaration mÇmoire Gem)
Save_Vex_Flag:		; Idem (Sauvegarde de l'Çtat du systäme)
Reset_Intercept:	; Idem (Retour Ö Genst sur RESET)
ZÇro	equ	%00100	; Bit zÇro du CCR

**********************************************************************
; DÇclarations	diverses pour le Gem.

	bsr.s	Startup_Sequence	; Taille mÇmoire utilisÇe
	bsr	Attente_Gem
	clr.l	-(a7)			; Passage en mode superviseur
	move.w	#$20,-(a7)
	trap	#1
	move.l	d0,2(a7)
	move.w	#$20,(a7)
	bsr.s	Code
	trap	#1
	addq.w	#4,a7
	clr.w	(a7)
	trap	#1

**********************************************************************

ERREUR	macro
	 pea	.Message(pc)
	 move.w	#9,-(a7)
	 trap	#1
	 addq	#6,a7
	endm

**********************************************************************

Code:
; Routine principale
	move	#$2700,sr
	bsr.s	Sauvegarde_êtat		; Sauvegarde Çtat machine
	bsr	PRêPARER_LISTE		; CrÇer	Liste chainÇe
	move.l	a7,IntÇgration_TerminÇe+2 ; Sauvegarde a7
	bsr	INTêGRER		; L'intÇgration

IntÇgration_TerminÇe:
	movea.l	#0,a7
	move.l	a5,Code_Objet		; Fin Code Objet
	bsr	TEST_CODE		; Tester le code
	bsr	Restaurer_êtat		; Restaurer Çtat machine
	move	#$2300,sr
	bsr	êCRIRE_SOURCE		; GÇnÇrer et sauver le code
Quit_Code
	rts				; source intÇgrÇ

**********************************************************************
* GESTION DE L'êTAT DE LA MACHINE
**********************************************************************

	IFD  Startup_Seq_Flag
Startup_Sequence:			; DÇclaration MÇmoire
	movea.l	(a7)+,a6
	movea.l	a7,a5
	movea.l	4(a5),a5
	move.l	$0C(a5),d0
	add.l	$14(a5),d0
	add.l	$1C(a5),d0
	add.l	#$0200,d0
	move.l	d0,d1
	add.l	a5,d1
	and.l	#$FFFFFFFE,d1
	movea.l	d1,a7
	move.l	d0,-(a7)
	move.l	a5,-(a7)
	clr.w	-(a7)
	move.w	#$4A,-(a7)
	trap	#1
	lea	12(a7),a7
	jmp	(a6)
	ENDC

	IFD  Save_Vex_Flag
Attente_Gem:
	moveq	#20,d7
.loop	move.w	#$25,-(a7)
	trap	#14
	addq	#2,a7
	dbra	d7,.loop
	rts

Sauvegarde_êtat:
	lea	êtat(pc),a0
	ENDC

	IFD	Reset_Intercept
	move.l	a7,Save_Ssp-êtat(a0)
	move.l	usp,a1
	move.l	a1,Save_Usp-êtat(a0)
	move.l	$426.w,Previous_Reset_Validity-êtat(a0)
	move.l	$42A.w,Previous_Reset_Routine-êtat(a0)
	lea	Reset(pc),a1
	move.l	#$31415926,$426.w	; Reset_Valid.w
	move.l	a1,$42A.w		; Reset_Vector
	move.l	#$752019F3,$420.w	; Memvalid
	move.l	#$237698AA,$43A.w	; Memvalid
	move.l	#$5555AAAA,$51A.w	; Memvalid
	ENDC
				
	IFD  Save_Vex_Flag
	lea	$FFFF8200.w,a1
	lea	$24(a0),a0
	move.b	$0A(a1),d0		; 50/60 Hz
	and.b	#2,d0
	move.b	d0,-(a0)
	move.b	$60(a1),-(a0)		; RÇsolution
	movem.l	$40(a1),d0-d7		; Palette
	movem.l	d0-d7,-(a0)
	movep.w	$01(a1),d0		; Adresse êcran
	move.w	d0,-(a0)
	lea	$24(a0),a0
	moveq	#$0F,d0			; Puce sonore
.Save_Yamaha
	move.b	d0,$FFFF8800.w
	move.b	$FFFF8800.w,(a0)+
	dbra	d0,.Save_Yamaha
	lea	$FFFFFA00.w,a1		; MFP
	movep.l	$03(a1),d0
	move.l	d0,(a0)+
	movep.w	$13(a1),d0
	move.w	d0,(a0)+
	move.b	$17(a1),(a0)+
	move.b	$19(a1),(a0)+
	move.b	$1B(a1),(a0)+
	move.b	$1D(a1),(a0)+
	moveq	#$01,d3
	moveq	#$00,d4
	lea	$1F(a1),a3
	lea	$19(a1),a2
	bsr.s	.ReadMfpDataRegister
	lea	$1B(a1),a2
	bsr.s	.ReadMfpDataRegister
	moveq	#$10,d3
	lea	$1D(a1),a2
	bsr.s	.ReadMfpDataRegister
	moveq	#$01,d3
	bsr.s	.ReadMfpDataRegister
	move.b	$29(a1),(a0)+
	addq.w	#1,a0
	move.l	$08.w,(a0)+		; êtat
	move.l	$68.w,(a0)+
	move.l	$70.w,(a0)+
	move.l	$0120.w,(a0)+
	move.l	$0134.w,(a0)+
	rts

.ReadMfpDataRegister:		; Routine par BelzÇbub
	move.b	d3,(a2)		; modifiÇe par Alien.
	move.b	d4,(a2)
	cmpi.b	#$01,(a3)
	bne.s	.ReadMfpDataRegister
.ReadOffsetData:
	move.b	d3,(a2)
	move.b	d4,(a2)
	cmpi.b	#$01,(a3)
	beq.s	.ReadOffsetData
	move.b	(a3),(a0)+
	addq.l	#$02,a3
	rts
	ENDC

	IFD	Reset_Intercept
Reset	move	#$2700,sr		; Sur Reset, restaurer
	move.l	Save_Ssp(pc),a7		; les piles et prÇparer
	move.l	Save_Usp(pc),a0		; la sortie du programme
	move.l	a0,usp
	lea	Quit_Code(pc),a0
	move.l	a0,(a7)
	ENDC

	IFD  Save_Vex_Flag
Restaurer_êtat
	move	#$2700,sr
	ENDC
	IFD	Reset_Intercept
	move.l	Previous_Reset_Validity(pc),$426.w
	move.l	Previous_Reset_Routine(pc),$42A.w
	ENDC
	IFD  Save_Vex_Flag
	lea	.Rte(pc),a0
	move.l	a0,$70.w
	lea	êtat(pc),a0
	lea	$FFFF8200.w,a1
	clr.l	$fffffa06.w
	clr.l	$fffffa12.w
	stop	#$2300
	stop	#$2300
	reset
	move	#$2700,sr
	move.w	(a0)+,d0
	movep.w	d0,$01(a1)		; Adresse êcran
	movem.l	(a0)+,d0-d7		; Couleurs
	movem.l	d0-d7,$40(a1)
	stop	#$2300
	move	#$2700,sr
	move.b	(a0)+,$60(a1)		; RÇsolution
	move.b	(a0)+,$0A(a1)		; 50/60 Hz
	lea	$FFFFFC00.w,a1		; ATTENTION RESET CLAVIER
	move.b	#$97,(a1)		; NE MARCHE PAS	SUR MEGA ST
	move.b	#$93,$04(a1)		; LE 6301 N'êTANT PAS RELIê ∂
	moveq	#127,d0			; LA BROCHE RESET !
.Wait_6301_1				; Attente neccessaire pour
	dbra	d0,.Wait_6301_1		; Çviter errur 6301
	move.b	#$96,(a1)		; (entrÇe en mode 1)
	move.b	#$91,$04(a1)
	move.w	#$0180,d0
.Wait_6301_2
	btst	#1,(a1)
	beq.s	.Wait_6301_2
	move.b	d0,2(a1)
	lsr.w	#8,d0
	bne.s	.Wait_6301_2
.Wait_6301_3
	btst	#0,(a1)
	beq.s	.Wait_6301_3
	tst.b	$FFFFFC02.w
	beq	Restaurer_êtat		; crash 6301, rÇessayer...
	moveq	#$0F,d0
.Restore_Yamaha
	move.b	d0,$FFFF8800.w		; Puce sonore
	move.b	(a0)+,$FFFF8802.w
	dbra	d0,.Restore_Yamaha
	lea	$FFFFFA00.w,a1		; Mfp
	move.l	(a0)+,d0
	movep.l	d0,$03(a1)
	move.w	(a0)+,d0
	movep.w	d0,$13(a1)
	clr.b	$19(a1)
	clr.b	$1B(a1)
	clr.b	$1D(a1)
	move.l	4(a0),d0
	movep.l	d0,$1F(a1)
	move.b	(a0)+,$17(a1)
	move.b	(a0)+,$19(a1)
	move.b	(a0)+,$1B(a1)
	move.b	(a0)+,$1D(a1)
	lea	6(a0),a0
	move.b	-2(a0),$29(a1)
	move.l	(a0)+,$08.w
	move.l	(a0)+,$68.w
	move.l	(a0)+,$70.w
	move.l	(a0)+,$0120.w
	move.l	(a0)+,$0134.w
	rts
.Rte	rte

êtat			DS.W	44
Save_Ssp		DS.L	1
Save_Usp		DS.L	1
Previous_Reset_Routine	DS.L	1
Previous_Reset_Validity	DS.L	1
	ENDC

**********************************************************************
* TEST DE LA ROUTINE INTêGRêE
**********************************************************************

TEST_CODE:
	movea.l	Code_Objet(pc),a0	; Fin Code Objet
	move.w	#$4EF9,(a0)+		; jmp $000000
	lea	END_VBL(pc),a1		; Retour apräs le code
	move.l	a1,(a0)+		; objet
	clr.l	$FFFFFA06.w		; Interdit intÇrruptions MFP

	move.l	$FFFF8200.w,d0		; Adresse Çcran
	lsl.w	#8,d0			; Remplir l'Çcran de couleur
	movea.l	d0,a0			; 15 pour voir que
	move.w	#32000/4-1,d1		; l'overscan est bien
.Cls	move.l	#-1,(a0)+		; dÇclenchÇ
	dbra	d1,.Cls

	lea	rte(pc),a0		; IntÇrruptions	en attente.
	move.l	a0,$70.w
	stop	#$2300
	stop	#$2300
	lea	VBL(pc),a0		; Le Test.
	move.l	a0,$70.w

Attente	cmpi.b	#$81,$FFFFFC02.w	; Sortie en appuyant sur
	bne.s	Attente			; la touche 'Esc'

	move	#$2700,sr
	rts

VBL:	movem.l	d0-a6,-(a7)		; La Vbl de test.
	move	#$2700,sr
	bsr	SOURCE_REGISTERS
	lea	$FFFF8260.w,a0
	lea	$FFFF820A.w,a1

.sync	move.b	$FFFF8209.w,d0		; Se synchroniser
	cmp.b	#$60,d0			; par raport au compteur
	bmi.s	.sync			; video
	moveq	#0,d0
	sub.b	$FFFF8209.w,d0
	lsl.l	d0,d0
	moveq	#0,d0
	REPT	40
	nop
	ENDR

	bra	CODE_OBJET		; Tester Code intÇgrÇ

END_VBL	move.w	#$0777,$FFFF8240.w	; Quitter.
	movem.l	(a7)+,d0-a6
rte:	rte

**********************************************************************
* INTêGRATION
**********************************************************************

; Structure de	chaque noeud de	la liste:

; longmot :	Adresse de dÇbut de la section
;		du code source (0 si fin source)
; mot :		Longueur de la section du code
;		source
; mot : 	Nombre de nops Ö intÇgrer avant
;		cette section du code source.
; longmot :	Adresse du prochain noeud

Tab		EQU $09
Fin_De_Ligne	EQU $0A

; Structure de liste chainÇe permettant d'integrer le code au niveau
; source.
				rsreset
Adresse_Source			rs.l	1
Longueur_Source			rs.w	1
Nombre_Nops_PrÇcÇdent		rs.w	1
Prochain_Noeud			rs.l	1
Longueur_êlÇment_Liste		rs.w	0

**********************************************************************

Nombre_De_Lignes	EQU	190	; Derniäre ligne avant attente
					; VBL
Nombre_Lignes_Overscan	EQU	118	; Nombre lignes	intÇgrÇs.
Instr_Addresse		EQU	2+2+4*5	; Position sur la pile du PC

INTêGRER:
; Initialisation des variables/hardware pour l'exception trace et
; dÇmarrage de l'intÇgration...
	lea	Variables(pc),a6
	clr.b	$FFFF8260.w		; 320 cycles par ligne vidÇo
	lea	IntÇgrer_Trace(pc),a0	; On se	sert de	l'exception
	move.l	a0,$24.w		; Trace.

	lea	CODE_SOURCE(pc),a0	; Adresse de l'intruction qui
	move.l	a0,Ancienne_Addresse-V(a6) ; vient d'àtre ÇffectuÇe
	move.w	#3*Nombre_Lignes_Overscan+1,NumÇro_De_Zone-V(a6)
	lea	CODE_OBJET(pc),a1	; Code que l'on gÇnärera et
	move.l	a1,Code_Objet-V(a6)	; que l'on testera

	pea	(a5)

	lea	$FFFF8200.w,a5		; VÇrifier qu'on a encore
Attendre_VBL2				; assez de temps avant la VBL
	movep.l	3(a5),d1		; pour dÇmarrer une exception
	move.w	2(a5),d0		; trace
	lsl.w	#8,d0
	sub.w	d0,d1
	cmp.w	#Nombre_De_Lignes*160,d1
	bpl.s	Attendre_VBL2

	movea.l	(a7)+,a5
	bsr	SOURCE_REGISTERS	; Inits	registres pour Code
	move.w	d0,-(a7)

	pea	(a6)
	lea	Variables(pc),a6

.Sync1	move.b	$FFFF8209.w,d0
	cmp.b	$FFFF8209.w,d0		; Attente de la	fin d'une
	bne.s	.Sync1			; ligne
.Sync2	cmp.b	$FFFF8209.w,d0		; Attente dÇbut	d'une ligne
	beq.s	.Sync2

.Sync3	move.b	$FFFF8209.w,d0
	cmp.b	$FFFF8209.w,d0		; Attente de la	fin d'une
	bne.s	.Sync3			; ligne
	move.b	d0,Old_Raster-V(a6)
	movea.l	(a7)+,a6
.Sync4	cmp.b	$FFFF8209.w,d0		; Attente dÇbut	d'une ligne
	beq.s	.Sync4
	sub.b	$FFFF8209.w,d0
	add.w	#28-6,d0
	lsl.w	d0,d0
	move.w	(a7)+,d0
	bra	CODE_SOURCE-6

			*********************

; L'exception Trace:
; Registres: d0/d1/a3/a4 = Travail
;            a5 = Code Objet que nous gÇnÇrons
;            a6 = Pointeur sur Variables

IntÇgrer_Trace:
	move.w	d0,-(a7)
	move.b	$FFFF8209.w,d0		; DÇterminer le	temps pris
	movem.l	d1/a3-a6,-(a7)		; par l'instruction
	lea	Variables(pc),a6
	sub.b	Old_Raster(pc),d0
	sub.b	#$4E,d0			; Temps	pris pour 0 cycles
	and.w	#$FE,d0
	ori.w	#$8700,Instr_Addresse-2(a7) ; SR
	movea.l	Code_Objet(pc),a5	; Code que l'on gÇnäre

Tester_Temps:
	sub.w	d0,Nombre_Cycles_Restants-V(a6) ; A t'on le temps pour
	bpl.s	Pas_De_Fausse_Interruption ; rajouter une instruction?

Ajouter_Fausse_Interruption:		; Non: rajouter	la fausse
	movea.l	Espace_Libre(pc),a3	; interruption.	DÇvier la
	movea.l	Current_Element(pc),a4	; liste chaånÇe pour y inclure
	move.l	Prochain_Noeud(a4),Prochain_Noeud(a3)
					; la fausse intÇrruption
	move.l	a3,Prochain_Noeud(a4)	; dÇclarÇe en mÇmoire libre
	move.l	a3,Current_Element-V(a6)

	move.w	Nombre_Cycles_Restants(pc),d1	; Calcul du nombre
	add.w	d0,d1				; de nops Ö rajouter
	move.w	d1,Nombre_Nops_PrÇcÇdent(a4)	; devant l'instruction

CrÇer_Attente:
	subq.w	#2,d1			; Rajouter les nops pour
	bmi.s	Fin_CrÇer_Attente	; faire perdre le temps
	move.w	#$4E71,(a5)+		; nÇcessaire au programme
	bra.s	CrÇer_Attente		; objet.

Fin_CrÇer_Attente:			; On est Ö la niäme fausse
	subq.w	#1,NumÇro_De_Zone-V(a6)	; interruption:	Est-ce la
	beq	IntÇgration_TerminÇe	; dernäre ?

	movea.l	Zone_Suivante(pc),a4	; Rajouter la fausse
	move.w	(a4)+,d1		; interruption
	move.w	(a4)+,Nombre_Cycles_Restants-V(a6)
	move.l	(a4)+,Zone_Suivante-V(a6)

Copie_FausseInt
	move.w	(a4)+,(a5)+	; Copie du code objet de la fausse
	dbra	d1,Copie_FausseInt ; interuption dans le code objet.

	move.l	(a4)+,Adresse_Source(a3)	; Copie de l'ÇlÇment
	move.w	(a4)+,Longueur_Source(a3)	; de la liste chainÇe
	clr.w	Nombre_Nops_PrÇcÇdent(a3)	; qui fait rÇfÇrence
	lea	Longueur_êlÇment_Liste(a3),a3	; au source de la
	move.l	a3,Espace_Libre-V(a6)	; fausse intrruption dans 1
	bra.s	Tester_Temps		; nouveau ÇlÇment de la liste

Pas_De_Fausse_Interruption
	; Passer au prochain ÇlÇment de la liste chainÇe
	movea.l	Current_Element(pc),a3
	move.l	Prochain_Noeud(a3),Current_Element-V(a6)

	; Copie de l'instruction dont on vient de dÇterminer la durÇe
	movea.l	Instr_Addresse(a7),a4	 ; Fin de l'instruction
	movea.l	Ancienne_Addresse(pc),a3 ; DÇbut de l'instruction

.Copier_Instruction:
	cmpa.l	a3,a4
	beq.s	.Fin_Copier_Instruction
	move.w	(a3)+,(a5)+
	bra.s	.Copier_Instruction

.Fin_Copier_Instruction:
	move.w	(a4),d0			; VÇrifier si l'instruction
	move.w	d0,d1			; qui suit est la commande
	and.w	#$F000,d1		; d'intÇgration de bloc.
	cmp.w	#$A000,d1
	bne.s	Pas_IntÇgration_de_Bloc

	move.l	a4,Ancienne_Addresse-V(a6)
	eor.w	d1,d0			; Nombre de cycles restants
	sub.w	d0,Nombre_Cycles_Restants-V(a6) ; suffisant pour
	bmi	Ajouter_Fausse_Interruption ; l'intÇgration ?

	addq.w	#2,a4			; Copie des instructions du
	move.w	(a4)+,d1		; bloc
Copier_Bloc:
	move.w	(a4)+,(a5)+
	dbra	d1,Copier_Bloc
	move.l	a4,Instr_Addresse(a7)

Pas_IntÇgration_de_Bloc:
	move.l	a4,Ancienne_Addresse-V(a6)
	move.l	a5,Code_Objet-V(a6)

	lea	$FFFF8200.w,a5		; VÇrifier s'il reste
Attendre_VBL:
	movep.l	3(a5),d1		; suffisament de temps
	move.w	2(a5),d0		; pour dÇmarrer une nouvelle
	lsl.w	#8,d0			; Çtape d'intÇgration
	sub.w	d0,d1			; (execution instruction
	cmp.w	#Nombre_De_Lignes*160,d1 ; + exception trace)
	bpl.s	Attendre_VBL

	movem.l	(a7)+,d1/a3-a5

.Sync1	move.b	$FFFF8209.w,d0
	cmp.b	$FFFF8209.w,d0		; Attente de la	fin d'une
	bne.s	.Sync1			; ligne
.Sync2	cmp.b	$FFFF8209.w,d0		; Attente dÇbut	d'une ligne
	beq.s	.Sync2

.Sync3	move.b	$FFFF8209.w,d0
	cmp.b	$FFFF8209.w,d0		; Attente de la	fin d'une
	bne.s	.Sync3			; ligne
	move.b	d0,Old_Raster-V(a6)
	movea.l	(a7)+,a6
.Sync4	cmp.b	$FFFF8209.w,d0		; Attente dÇbut	d'une ligne
	beq.s	.Sync4
	sub.b	$FFFF8209.w,d0

	add.w	#28,d0
	lsl.w	d0,d0
	move.w	(a7)+,d0
	rte

**********************************************************************
* PRêPARATION DU CODE SOURCE
**********************************************************************
; Cette partie crÇe la liste chainÇe qui dÇcrit le code source.
; Registres: a0: Code Source
;            a1: Liste ChainÇe
;            a2/a3: Registres de Travail
;            d0/d1: Idem

PRêPARER_LISTE
P	equ	PRêPARER_LISTE		; abbrÇviation !
	movem.l	d0-d1/a0-a3,-(a7)
	lea	PRêPARER_LISTE(pc),a6
	lea	LISTE,a1
	lea	CODE_ASCII,a0
	clr.w	Compteur_REPT-P(a6)
	move.l	a0,Adresse_Source(a1)

; D'abord l'on traite les lignes de code qui ne comportent pas
; d'instructions assembleurs: lignes vides, de commentaires, ou de
; directives d'assemblage.

Analyse	cmpa.l	#FIN_CODE_ASCII,a0
	beq.s	Fin_Du_Source

	move.b	(a0)+,d0
	cmp.b	#';',d0		; symbole ';' en dÇbut de
	beq	Commentaire	; ligne: Commentaire
	cmp.b	#' ',d0		; Tab etc pris en charge
	ble.s	Analyse

	lsl.w	#8,d0		; Lit les 3 octets qui suivent
	move.b	(a0),d0		; pour former un long mot
	swap	d0
	movep.w	1(a0),d0
	move.b	2(a0),d0
	and.l	#$DFDFDFDF,d0

	cmp.l	#'REPT',d0
	beq.s	Rept
	cmp.l	#'ENDR',d0
	beq	Endr

	bsr.s	Trouver_Ligne_Suivante
	bne.s	Fin_Du_Source

; Il s'agit donc d'une ligne comportant ce qui est reconnu comme une
; instruction assembleur.

	move.l	a0,d0
	sub.l	Adresse_Source(a1),d0
	move.w	d0,Longueur_Source(a1)
	clr.w	Nombre_Nops_PrÇcÇdent(a1)
	lea	Longueur_êlÇment_Liste(a1),a1
	move.l	a1,Prochain_Noeud-Longueur_êlÇment_Liste(a1)
	move.l	a0,Adresse_Source(a1)
	bra.s	Analyse

Fin_Du_Source:
; On finit l'insertion de la ligne source dans la liste chainÇe et on
; termine cette liste chainÇe en mettant la prochaine adresse de
; source Ö zÇro. On verifie aussi si tous les boucles rept ont ÇtÇ
; complÇtÇs (vÇrification essentielle puisque les informations pour le
; REPT sont sauvegardÇes sur la pile.

	move.l	a0,d0
	sub.l	Adresse_Source(a1),d0
	move.w	d0,Longueur_Source(a1)
	clr.w	Nombre_Nops_PrÇcÇdent(a1)
	lea	Longueur_êlÇment_Liste(a1),a1
	move.l	a1,Prochain_Noeud-Longueur_êlÇment_Liste(a1)
	clr.l	Adresse_Source(a1)	; Marqueur fin de liste
	lea	Longueur_êlÇment_Liste(a1),a1
	tst.w	Compteur_REPT-P(a6)
	bne	Erreur_Rept
	move.l	a1,Espace_Libre-P(a6)
	movem.l	(a7)+,d0-d1/a0-a3
	rts

Commentaire:
; Les commentaires sont considÇrÇs comme des charactäres sans validitÇ
; (comme l'espace ou la tabulation) devant une instruction assembleur.
	bsr.s	Trouver_Ligne_Suivante
	bne.s	Fin_Du_Source
	bra	Analyse

Trouver_Ligne_Suivante:
; Cette routine positionne a0 au dÇbut de la ligne suivante.
; le bit Z du CCR est Ö 0 si la fin du source a ÇtÇ atteint.
	cmpa.l	#FIN_CODE_ASCII,a0
	beq.s	.Fin_Du_Source
	cmpi.b	#Fin_De_Ligne,(a0)+
	bne.s	Trouver_Ligne_Suivante
	or.b	#ZÇro,ccr
	rts
.Fin_Du_Source
	and.b	#~ZÇro,ccr
	rts

Rept:
; Le REPT est ignorÇ. C'est Ö dire qu'il n'est màme pas inclus dans la
; liste chainÇe. La routine sauve le noeud de la liste chainÇe
;  correspondant au dÇbut du code Ö rÇpÇter, ainsi que le nombre de
; fois qu'il doit àtre rÇpÇtÇ.
	lea	3(a0),a0	; On saute les letrres 'EPT'
	pea	Adresse_Source(a1)	; Sauver noeud de rÇpÇtition
	addq.w	#1,Compteur_REPT-P(a6)	; Un niveau de REPT de plus

	moveq	#0,d1
.Rept_Analyse1
	move.b	(a0)+,d1		; Analyse du premier chiffre
	cmp.b	#Fin_De_Ligne,d1	; sans lequel le REPT a ÇtÇ
	beq	Erreur_Parametre_Rept	; mal dÇfini
	cmp.b	#' ',d1
	ble.s	.Rept_Analyse1
	cmp.b	#';',d1
	beq	Erreur_Parametre_Rept
	cmp.b	#'0',d1
	blt	Erreur_Parametre_Rept
	cmp.b	#'9',d1
	bgt	Erreur_Parametre_Rept

	sub.b	#'0',d1
	moveq	#0,d0

.Rept_Analyse2:
	move.b	(a0)+,d0		; Analyse des chiffres
	cmp.b	#'0',d0			; suivants, et conversion
	blt.s	.Fin_Rept_Analyse2	; dÇcimal -> binaire
	cmp.b	#'9',d0
	bgt.s	.Fin_Rept_Analyse2
	mulu	#10,d1
	sub.b	#'0',d0
	add.l	d0,d1
	bra.s	.Rept_Analyse2

.Fin_Rept_Analyse2:
	move.l	d1,-(a7)		; Sauvegarde du nombre de
	bsr	Trouver_Ligne_Suivante	; fois qu'il faut rÇpÇter.
	bne	Fin_Du_Source
	move.l	a0,Adresse_Source(a1)
	bra	Analyse

Endr:
; L'ENDR est aussi ignorÇ: non-inclus dans la liste chainÇe. Par
; contre c'est ici qu'est ÇffectuÇe la rÇpetition de la partie de la
; liste chainÇe correspondant au code Ö rÇpÇter.
	subq.w	#1,Compteur_REPT-P(a6)
	bmi.s	Erreur_Rept
	move.l	(a7)+,d1
	movea.l	(a7)+,a2

.Copier_Rept1
	subq.l	#1,d1
	ble.s	.Fin_Copier_Rept
	movea.l	a1,a3
.Copier_Rept2
	cmpa.l	a2,a3
	beq.s	.Copier_Rept1
	move.l	Adresse_Source(a2),Adresse_Source(a1)
	move.w	Longueur_Source(a2),Longueur_Source(a1)
	move.w	Nombre_Nops_PrÇcÇdent(a2),Nombre_Nops_PrÇcÇdent(a1)
	lea	Longueur_êlÇment_Liste(a2),a2
	lea	Longueur_êlÇment_Liste(a1),a1
	move.l	a1,Prochain_Noeud-Longueur_êlÇment_Liste(a1)
	bra.s	.Copier_Rept2

.Fin_Copier_Rept
	bsr	Trouver_Ligne_Suivante
	bne	Fin_Du_Source
	move.l	a0,Adresse_Source(a1)	; Nouveau ÇlÇment de liste
	bra	Analyse

Erreur_Rept:	ERREUR
.ici		bra.s	.ici
.Message	dc.b	"Erreur: le nombre de REPT et de ENDR n'est "
		dc.b    "pas identique !",0
		even
Erreur_Parametre_Rept:
		ERREUR
.ici		bra.s	.ici
.Message	dc.b	"Erreur: REPT n'est pas suivit par un nombre "
		dc.b	" dÇcimal !",0
		even

Compteur_REPT:	DS.W 1

**********************************************************************
* SAUVER LE SOURCE GêNêRê
**********************************************************************

; registres utilisÇs
;            d0/a0 par le Gemdos
;            d4 = Travaux temporaires
;            d5 = Addresse de fin de la section de source
;            d6 = Longueur de la section de source traitÇe
;            a4 = Travaux temporaires
;            a5 = Adresse du noeud de la liste chainee de source
;            a6 = Adresse de la section de source traitÇe

êCRIRE_SOURCE:
	bsr	Initialiser_Liste_Des_êtiquettes
	bsr	Ouvrir_Fichier
	movea.l	LISTE2+Prochain_Noeud,a5

GÇnÇrer_Source:
	tst.l	Adresse_Source(a5)	; Marqueur de fin de la
	bne	.Continuer_êcrire_Source ; liste chainÇe ?
	bsr	Fermer_Fichier
	rts

.Continuer_êcrire_Source:
	move.l	Adresse_Source(a5),a6
	moveq	#0,d6
	move.w	Longueur_Source(a5),d6
	move.l	d6,d5
	add.l	a6,d5

Trouver_êtiquette_Initiale:
; On vÇrifie d'abord si une Çtiquette initiale est dÇclarÇe (c'est Ö
; dire prÇsente au dÇbut de la ligne).
	cmp.l	a6,d5
	ble	Aucune_êtiquette_OpÇrande

	cmpi.b	#' ',(a6)
	ble.s	Aucune_êtiquette_Initiale
	cmpi.b	#';',(a6)
	beq.s	Ligne_Commentaire

	st	êtiquette_∂_DÇclarer
	bsr	Traiter_êtiquette

Aucune_êtiquette_Initiale:
; Puis on verifie s'il y a une Çtiquette dans les opÇrandes de
;  l'instruction assembleur traitÇe.
	movea.l	a6,a4

Trouver_êtiquette_OpÇrande:
	move.b	(a4)+,d4
	cmp.l	a4,d5
	ble.s	Aucune_êtiquette_OpÇrande
	cmp.b	#Fin_De_Ligne,d4
	beq.s	Fin_de_Ligne
	cmp.b	#'›',d4
	bne.s	Trouver_êtiquette_OpÇrande

	move.l	a4,d4		; Une êtiquette parmi les
	sub.l	a6,d4		; opÇrandes a ÇtÇ trouvÇe:
	sub.l	d4,d6		; Il faut donc Çcrire
	subq.l	#1,d4		; l'instruction assembleur
	movem.l	d4/a6,-(a7)	; dans le fichier avant
	bsr	êcrire_Fichier	; l'Çtiquette
	movea.l	a4,a6		; Puis on traite l'Çtiquette
	sf	êtiquette_∂_DÇclarer
	bsr	Traiter_êtiquette
	movea.l	a6,a4
	bra.s	Trouver_êtiquette_OpÇrande

Fin_de_Ligne:
	move.l	a4,d4		; On copie ce qui se trouve apräs
	sub.l	a6,d4		; les opÇrandes (comme les
	sub.l	d4,d6		; commentaires)
	movem.l	d4/a6,-(a7)
	bsr	êcrire_Fichier
	movea.l	a4,a6
	bra.s	Trouver_êtiquette_Initiale

Ligne_Commentaire:
; On Çcrit la ligne commentaire dans le fichier source, puis on passe
; Ö la ligne suivante de la section source.
	pea	(a6)
.Boucle	cmp.l	a6,d5		; Trouve la ligne suivante
	ble.s	.Aucune_êtiquette_OpÇrande
	cmpi.b	#Fin_De_Ligne,(a6)+
	bne.s	.Boucle
	move.l	(a7),-(a7)	; êcrit la ligne commentaire
	move.l	a6,d4		; dans le fichier source
	sub.l	(a7),d4
	move.l	d4,(a7)
	bsr	êcrire_Fichier
	move.l	d5,d6		; change la longueur de la section
	sub.l	a6,d6		; source qui ne contient plus le
	bra	Trouver_êtiquette_Initiale	; commentaire

.Aucune_êtiquette_OpÇrande
	move.l	(a7)+,a6	; ligne commentaire seule

Aucune_êtiquette_OpÇrande
; Il ne reste plus d'Çtiquettes Ö traiter.
	movem.l	d6/a6,-(a7)
	bsr	êcrire_Fichier

	move.w	Nombre_Nops_PrÇcÇdent(a5),d6	; GÇnÇrer les nops
GÇnÇrer_Nops
	subq.w	#2,d6
	bmi.s	Ligne_Suivante
	pea	NOP(pc)				; On Çcrit un NOP
	move.l	#NOP_FIN-NOP,-(a7)		; dans le fichier
	bsr	êcrire_Fichier
	bra.s	GÇnÇrer_Nops

Ligne_Suivante
	movea.l	Prochain_Noeud(a5),a5
	bra	GÇnÇrer_Source

			*********************

; La Base_êtiquette est construite aprÇs l'Espace_Libre. C'est lÖ oó
; la table des Çtiquettes sera construite. ∂ chaque Çtiquette
; correspondront les champs suivants:
; Mot Long: Adresse de l'Çtiquette dans le code source (ou 0 si c'est
;           la derniere Çtiquette de la table)
; Mot     : Longeur de l'Çtiquette
; Mot     : NumÇro de l'Çtiquette (pour l'Çtiquette initiale)
; Mot     : NumÇro de l'Çtiquette (pour l'Çtiquette de l'opÇrande
;           d'une commande assembleur.)

				rsreset
Adresse_êtiquette		rs.l	1
Longueur_êtiquette		rs.w	1
NumÇro_Extention_Initiale	rs.w	1
NumÇro_Extention_OpÇrande	rs.w	1
Longueur_êlement_êtiquette	rs.w	0

Initialiser_Liste_Des_êtiquettes
	movea.l	Espace_Libre(pc),a6
	move.l	a6,Base_êtiquette
	clr.l	(a6)
	rts

			**********************

; NumÇrotation des Çtiquettes
; registres: d2/d3/a3/a5 travail
;            a4          Adresse de l'ÇlÇment de la table Çtiquette
;                        traitÇ
; en entrÇe: a6          Adresse de la section du code source traitÇe
;            d6          Longueur de la section du code source traitÇe
; et êtiquette_∂_DÇclarer = Vrai (-1) si on traite une Çtiquette
;                        initiale

Traiter_êtiquette:
	movem.l	d2-d3/a3-a5,-(a7)
	movea.l	Base_êtiquette(pc),a4
	bra.s	.over

; On tente d'abord de trouver l'Çtiquette dans la table d'Çtiquettes.
; En màme temps on vÇrifie que l'on a pas dÇpassÇ la fin de
; l'Çtiquette Ö trouver avec la sous-routine Charactäre_D_êtiquette?.
.Mauvaise_êtiquette:
	lea	Longueur_êlement_êtiquette(a4),a4
.over	movea.l	a6,a5
	move.l	Adresse_êtiquette(a4),d2
	beq	Ajouter_êtiquette_∂_La_Table
	movea.l	d2,a3
	move.w	Longueur_êtiquette(a4),d3
	subq.w	#1,d3
.Comparer_êtiquettes
	move.b	(a3)+,d2
	bsr	Charactäre_D_êtiquette?
	bne.s	.Mauvaise_êtiquette
	cmp.b	(a5)+,d2
	bne.s	.Mauvaise_êtiquette
	dbra	d3,.Comparer_êtiquettes
	move.b	(a3)+,d2
	bsr	Charactäre_D_êtiquette?
	beq.s	.Mauvaise_êtiquette
	bra.s	êtiquette_TrouvÇe

Ajouter_êtiquette_∂_La_Table:
; L'Çtiquette n'ayant pas ÇtÇ trouvÇe il faut la rajouter Ö la table.
	move.l	a5,Adresse_êtiquette(a4)
.DÇterminer_Longueur_êtiquette:
	move.b	(a5)+,d2
	bsr	Charactäre_D_êtiquette?
	beq.s	.DÇterminer_Longueur_êtiquette
	subq.w	#1,a5
	move.l	a5,d2
	sub.l	a6,d2
	move.w	d2,Longueur_êtiquette(a4)
	clr.w	NumÇro_Extention_Initiale(a4)
	clr.w	NumÇro_Extention_OpÇrande(a4)
	clr.l	Longueur_êlement_êtiquette+Adresse_êtiquette(a4)

êtiquette_TrouvÇe:
; DÇsormais a4 contient la rÇfÇrence Ö l'Çtiquette dans la table des
; Çtiquettes. On Çcrit l'Çtiquette dans le fichier de source gÇnÇrÇ.
	pea	(a6)
	move.l	a5,d3
	sub.l	a6,d3
	sub.l	d3,d6			; Corriger d6
	move.l	d3,-(a7)
	bsr	êcrire_Fichier
	move.l	a5,a6

; Il ne reste plus qu'Ö Çcrire le numÇro de l'Çtiquette. Il faut donc
; distinguer la dÇclaration initiale de l'Çtiquette dans l'opÇrande
; d'une instruction assembleur.
	tst.b	êtiquette_∂_DÇclarer
	bne.s	.êtiquette_Initiale
offset	set	NumÇro_Extention_OpÇrande-NumÇro_Extention_Initiale
	lea	offset(a4),a3
	bra.s	.over
.êtiquette_Initiale
	movea.l	a4,a3

.over	moveq	#0,d3
	move.w	NumÇro_Extention_Initiale(a3),d3
	addq.w	#1,NumÇro_Extention_Initiale(a3)

Conversion_DÇcimale:
; Routine de conversion en dÇcimal (limitÇe Ö des nombres de taille
; maximale $7FFF*10... ce qui devrait suffire pour la numÇrotation des
; Çtiquettes. La routine est fondÇe sur le fait que divu met le reste
; dans le mot fort du rÇsultat.
; NB: Attention on travaille avec la pile pour retourner le nombre
; gÇnÇrÇ, donc il faut Çviter de quitter cette routine avant la fin !

	lea	Espace_Nombre(pc),a5	; Espace de travail pour
	movea.l	a5,a3			; les nombres crÇÇs.
	clr.b	-(a7)			; Pointeur de fin du nombre
					; convertit.
.prochain_chiffre
	tst.w	d3
	beq.s	.retourner_nombre
	divu	#10,d3
	swap	d3
	add.b	#'0',d3
	move.b	d3,-(a7)
	clr.w	d3
	swap	d3
	bra.s	.prochain_chiffre

.retourner_nombre:	
	move.b	(a7)+,(a5)+		; Remettre dans le bon ordre !
	bne.s	.retourner_nombre

	move.l	a5,d3			; VÇrifier taille du nombre
	sub.l	a3,d3			; ainsi crÇÇ.
	subq.l	#1,d3
	ble.s	.êtiquette_Non_NumÇrotÇe

	movem.l	d3/a3,-(a7)
	bsr	êcrire_Fichier

.êtiquette_Non_NumÇrotÇe:
	movem.l	(a7)+,d2-d3/a3-a5
	rts

Charactäre_D_êtiquette?:
; Cette routine vÇrifie si le charactäre en entrÇe Char peut
; appartenir Ö une Çtiquette. Si tel est le cas il revient avec le bit
; Z de CCR Ö 1. Il faut savoir que la liste des charactäres traitÇes
; n'est pas exhaustive puisqu'elle dÇpend de l'assembleur employÇ.
	cmp.b	#'_',d2
	beq.s	.êtiquette_Char_Ok
	cmp.b	#'0',d2
	blt.s	.êtiquette_Char_Ko
	cmp.b	#'9',d2
	ble.s	.êtiquette_Char_Ok
	cmp.b	#'A',d2
	blt.s	.êtiquette_Char_Ko
	cmp.b	#'Z',d2
	ble.s	.êtiquette_Char_Ok
	cmp.b	#'a',d2
	blt.s	.êtiquette_Char_Ko
	cmp.b	#'z',d2
	ble.s	.êtiquette_Char_Ok
.êtiquette_Char_Ko
	;and.b #~ZÇro,ccr
	rts
.êtiquette_Char_Ok
	or.b #ZÇro,ccr
	rts

		even
êtiquette_∂_DÇclarer	ds.w	1
Base_êtiquette:		DS.L 1
Espace_Nombre:		DS.B 8
		even

**********************************************************************
; Routines de gestion de la sauvegarde du source par le GEMDOS.

GEMDOS	macro	\0,\1,\2
	move.w	#\1,-(a7)		; existe dÇjÖ.
	trap	#1
	lea	\2(a7),a7
	tst.\0	d0
	endm

Ouvrir_Fichier
	move.w	#2,-(a7)
	pea	nom_fichier(pc)		; Fopen si le fichier
	GEMDOS.w $3D,8			; existe dÇjÖ, on va le
	bmi.s	.Fichier_Inexistant	; dÇtruire de faáon Ö
	move.w	d0,-(a7)		; ce si le fichier original
	GEMDOS.w $3E,4			; Çtait plus long que celui
	bmi.s	Erreur_Gemdos		; que nous allons gÇnÇrer,
	pea	nom_fichier(pc)		; nous n'aurons pas de datas
	GEMDOS.w $41,6			; anciens Ö la fin du
	bmi.s	Erreur_Gemdos		; fichier final

.Fichier_Inexistant
	clr.w	-(a7)			; Fcreate
	pea	nom_fichier(pc)		; (sur certains tos,
	GEMDOS.w $3C,8			; si vous crÇez	un fichier
	bmi.s	Erreur_Gemdos		; qui existe dÇjÖ, vous	en
	move.w	d0,Identificateur_Fichier ; obtiendrez 2 avec le
	rts				; màme nom !

êcrire_Fichier
	move.l	8(a7),d0	; On prend les mots longs A B C
	move.l	(a7),8(a7)	; et on les met dans l'ordre
	move.l	4(a7),(a7)	; B C A (A correspondant Ö
	move.l	d0,4(a7)	; l'adresse de retour)
	move.w	Identificateur_Fichier(pc),-(a7)
	GEMDOS.l $40,12		; FWrite
	bmi.s	Erreur_Gemdos
	rts

Fermer_Fichier
	move.w	Identificateur_Fichier(pc),-(a7)
	GEMDOS.w $3E,4
	bmi.s	Erreur_Gemdos
	rts

Erreur_Gemdos
	ERREUR
	illegal
.Message	dc.b	"Erreur Gemdos lors de la sauvegarde du "
		dc.b	"fichier de source gÇnÇrÇ !",0
		even

Identificateur_Fichier	ds.w	1
nom_fichier:		DC.B	'f:\op.s',0
		even

**********************************************************************
* CODE SOURCE ASSEMBLê
**********************************************************************

SOURCE_REGISTERS:
; Ici on doit initialiser les registres dont le code source aura
;  besoin.
	move.l	$FFFF8200.w,d0	;;
	lsl.w	#8,d0		;;
	addq.w	#2,d0		;;
	movea.l	d0,a2		;; a2: position Çcran des sprites
	lea	230*10(a2),a2	;; a3 pointe sur les graphismes
	move.l	$4.w,a3		;; pour ne pas avoir Ö en faire
	movea.l	d0,a4		;; on affiche la rom !
	lea	160+230(a4),a4	;; a4: position Çcran du scroll
	lea	Carte(pc),a6	;; Carte pour le dÇcor Ö imprimer
	moveq	#0,d1		;; en fond
	rts

Carte:		DS.W 14		;;
Offset:		DC.L 0		;;
Fond:				;;

	nop				; Ce code doit toujours
	move	#$A700,sr		; prÇcÇder code	source
CODE_SOURCE:

; C'est ici qu'il faut mettre son source Ö intÇgrer.
;; L'exemple ci-dessous montre le code de base d'une dÇmo telle que le
;; main menu de la Lightening Demo, par Pendragons: Il nous faut
;; afficher un sprite de 32*32 comme personnage Ö dirriger. Ensuite
;; nous avons un scroller horizontal non-optimisÇ, de 7 lignes de haut
;; et de 1 plan. Suit le code pour afficher le fond. Ici on a affaire
;; Ö 1 HARDSCROLL, et on a besoin d'avoir 1 Çcran logique et 1 Çcran
;; physique Ö cause des sprites Pendragons qui parcourrent l'image
;; entiäre. Donc il nous faut 3 images en mÇmoire, et il faut afficher
;; l'image en haut/bas de l'image 3 fois.
;; Comme vous voyez, màme si l'efficacitÇ de l'intÇgration est
;; mÇdiocre, le code pour cette dÇmo s'intägre en 118 lignes seulement
;; dont 72 pour les 9 sprites 'Pendragons'.


	REPT 32			;; Le sprite 32*32
	movem.l	(a2),d2-d7	;; (le petit bonhomme qui se
	and.l	(a3),d2		;; promäne sur le dÇcor)
	and.l	(a3)+,d3	;;
	or.l	(a3)+,d2	;;
	or.l	(a3)+,d3	;;
	and.l	(a3),d4		;;
	and.l	(a3)+,d5	;;
	or.l	(a3)+,d4	;;
	or.l	(a3)+,d5	;;
	and.l	(a3),d6		;;
	and.l	(a3)+,d7	;;
	or.l	(a3)+,d6	;;
	or.l	(a3)+,d7	;;
	movem.l	d2-d7,(a2)	;;
	lea	230(a2),a2	;;
	ENDR			;;

Intern1	SET 27*8		;; Scroller du scrolltext 1 plan
	lsl.w	Intern1(a4)	;; (qui a 7 lignes)
	REPT 26			;;
Intern1	SET Intern1-8		;;
	roxl.w	Intern1(a4)	;;
	ENDR			;;
	roxl.w	(a4)		;;
	lea	230(a4),a4	;;

Intern2	SET 27*8		;;
	lsl.w	Intern2(a4)	;;
	REPT 26			;;
Intern2	SET Intern2-8		;;
	roxl.w	Intern2(a4)	;;
	ENDR			;;
	roxl.w	(a4)		;;
	lea	230(a4),a4	;;

Intern3	SET 27*8		;;
	lsl.w	Intern3(a4)	;;
	REPT 26			;;
Intern3	SET Intern3-8		;;
	roxl.w	Intern3(a4)	;;
	ENDR			;;
	roxl.w	(a4)		;;
	lea	230(a4),a4	;;

Intern4	SET 27*8		;;
	lsl.w	Intern4(a4)	;;
	REPT 26			;;
Intern4	SET Intern4-8		;;
	roxl.w	Intern4(a4)	;;
	ENDR			;;
	roxl.w	(a4)		;;
	lea	230(a4),a4	;;

Intern5	SET 27*8		;;
	lsl.w	Intern5(a4)	;;
	REPT 26			;;
Intern5	SET Intern5-8		;;
	roxl.w	Intern5(a4)	;;
	ENDR			;;
	roxl.w	(a4)		;;
	lea	230(a4),a4	;;

Intern6	SET 27*8		;;
	lsl.w	Intern6(a4)	;;
	REPT 26			;;
Intern6	SET Intern6-8		;;
	roxl.w	Intern6(a4)	;;
	ENDR			;;
	roxl.w	(a4)		;;
	lea	230(a4),a4	;;

Intern7	SET 27*8		;;
	lsl.w	Intern7(a4)	;;
	REPT 26			;;
Intern7	SET Intern7-8		;;
	roxl.w	Intern7(a4)	;;
	ENDR			;;
	roxl.w	(a4)		;;
	lea	230(a4),a4	;;

	REPT 144		;; 9 sprites 16*16
	movem.l	(a2),d2-d5	;; 'PENDRAGONS'
	and.l	(a3),d2		;;
	and.l	(a3)+,d3	;;
	or.l	(a3)+,d2	;;
	or.l	(a3)+,d3	;;
	and.l	(a3),d4		;;
	and.l	(a3)+,d5	;;
	or.l	(a3)+,d4	;;
	or.l	(a3)+,d5	;;
	movem.l	d2-d5,(a2)	;;
	lea	0(a2),a2	;;
	ENDR			;;

	adda.l	Offset,a4	;; Affichage du	fond
	movea.l	a4,a2		;; a2,a3,a4 servent
	movea.l	a4,a3		;; pour les 3 Çcrans
	adda.l	#0,a2		;; permettant le scroll
	adda.l	#0,a3		;; donc il faut mettre
	REPT 14			;; 1 fois et 2 fois la
	lea	Fond(pc),a5	;; longueur d'1 Çcran
	adda.l	d1,a5		;; dans les opÇrandes
	adda.w	(a6)+,a5	;; immÇdiates des deux
	movem.l	(a5)+,d2-d5	;; adds, respectivement
	movem.l	d2-d5,(a2)	;;
	movem.l	d2-d5,(a3)	;;
	movem.l	d2-d5,(a4)	;;
	lea	16(a2),a2	;;
	lea	16(a3),a3	;;
	lea	16(a4),a4	;;
	ENDR			;;

	DC.W $A000+500			; Ceci doit toujours suivre
	DC.W 0				; votre	code source.
	illegal

	move	#$2700,sr		; Code de fin, dans le cas
	illegal				; d'une erreur de
					; l'intÇgrateur

**********************************************************************
* TEMPS OVERSCAN
**********************************************************************
; Le programme	gÇnÇrÇ commence	par l'overscan gauche.

Variables
V		equ	Variables		; abbrÇviation !
Current_Element	DC.L LISTE2
Zone_Suivante	DC.L Overscan_Gauche
Espace_Libre	DC.L 0

Overscan_Gauche
	DC.W Ov_Gauche_Longueur/2-1	; Longueur Code
	DC.W 89*2			; Temps	machine	en cycles/2
	DC.L Overscan_Droite		; Fausse Interruption suivante
Ov_Gauche1
	move.w	a0,(a0)			; Code Fausse IntÇrruption
	nop				; DonnÇes suivantes au màme
	move.w	d0,(a0)			; format !
Ov_Gauche2
Ov_Gauche_Longueur EQU	Ov_Gauche2-Ov_Gauche1
	DC.L OV_GAUCHE_ASCII
	DC.W OV_GAUCHE_ASCII_FIN-OV_GAUCHE_ASCII

Overscan_Droite
	DC.W Ov_Droite_Longueur/2-1
	DC.W 13*2
	DC.L Overscan_Stabilisateur
Ov_Droite1
	move.w	d0,(a1)
	move.w	a0,(a1)
Ov_Droite2
Ov_Droite_Longueur EQU	Ov_Droite2-Ov_Droite1
	DC.L OV_DROITE_ASCII
	DC.W OV_DROITE_ASCII_FIN-OV_DROITE_ASCII

Overscan_Stabilisateur:
	DC.W Ov_Stabil_Longueur/2-1
	DC.W 12*2
	DC.L Overscan_Gauche
Ov_Stabil1
	move.w	a0,(a0)
	nop
	move.w	d0,(a0)
Ov_Stabil2
Ov_Stabil_Longueur EQU	Ov_Stabil2-Ov_Stabil1
	DC.L OV_STABIL_ASCII
	DC.W OV_STABIL_ASCII_FIN-OV_STABIL_ASCII

OV_GAUCHE_ASCII
	DC.B Tab,Tab,'move.w  a0,(a0)',$0D,$0A
	DC.B Tab,Tab,'nop',$0D,$0A
	DC.B Tab,Tab,'move.w  d0,(a0)',$0D,$0A
OV_GAUCHE_ASCII_FIN:

OV_DROITE_ASCII
	DC.B Tab,Tab,'move.w  d0,(a1)',$0D,$0A
	DC.B Tab,Tab,'move.w  a0,(a1)',$0D,$0A
OV_DROITE_ASCII_FIN

OV_STABIL_ASCII
	DC.B Tab,Tab,'move.w  a0,(a0)',$0D,$0A
	DC.B Tab,Tab,'nop',$0D,$0A
	DC.B Tab,Tab,'move.w  d0,(a0)',$0D,$0A
OV_STABIL_ASCII_FIN:

NOP:	DC.B Tab,Tab,'nop',$0D,$0A
NOP_FIN:

Old_Raster:	DS.B 1
		even

NumÇro_De_Zone		DS.W 1
Nombre_Cycles_Restants	DS.W 1
Ancienne_Addresse	DS.L 1
Code_Objet		DS.L 1

CODE_OBJET:		; Espace mÇmoire pour le code objet gÇnÇrÇ
		DS.W $8000
LISTE2:			; Espace mÇmoire pour la liste chainÇe du
		DS.L 2	; code source, et pour la table des
		DC.L LISTE ; Çtiquettes
LISTE:		DS.W $A000
CODE_ASCII		; Le code source originel.
		incbin	"F:\INTEGRC1.S"
		DC.B $0D,$0A	; Marqueur fin de ligne au cas oó il
FIN_CODE_ASCII:			; serait absent
		END
