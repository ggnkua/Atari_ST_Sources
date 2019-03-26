mfp		equ	40	; dÇlai mpf Ö partir duquel on teste.

		OPT D+	; êtiquettes dans le dÇbuggeur
Startup_Seq_Flag:	; Variable Interne (dÇclaration mÇmoire Gem)
Save_Vex_Flag:		; Idem (Sauvegarde de l'Çtat du systäme)
Reset_Intercept:	; Idem (Retour Ö Genst sur RESET)

**********************************************************************
; DÇclarations	diverses pour le Gem.

	bsr.s	Startup_Sequence	; Taille mÇmoire utilisÇe
	bsr.s	Attente_Gem
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

Code:
; Routine principale
	move	#$2700,sr
	bsr.s	Sauvegarde_êtat		; Sauvegarde Çtat machine
	bsr	DÇmonstration
	bsr	Restaurer_êtat		; Restaurer Çtat machine
Quit_Code
	move	#$2300,sr
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
* DêMONSTRATION
**********************************************************************

DÇmonstration
	bsr	CLS			; êffacement Çcran
	move.b	#mfp,mfp_Ada+3		; Lancement du test adaptatif
	bsr	Adapt
	bsr	Set_Up_Hardware
	stop	#$2300
	stop	#$2300
	move.l	#VBL,$70.w
me	addq.w	#1,d6
	cmp.b	#$B9,$fffffc02.w
	bne.s	me
	move.w	#$2700,sr
	rts

CLS	move.l	$ffff8200,d0
	lsl.w	#8,d0
	move.l	d0,a0
	move.w	#160*200/4-1,d0
.loop	move.l	#-1,(a0)+
	dbra	d0,.loop
	rts

Set_Up_Hardware			; Initialisation du hardware.
	clr.l	$fffffa06.w	; On interdit les intÇrruptions
	clr.l	$fffffa12.w	; mfp.
	move.l	#RTE,$70.w	; Reset Shifter
	stop	#$2300	
	stop	#$2300	
	clr.b	$ffff820a.w
	stop	#$2300	
	move.b	#2,$ffff820a.w
	move.w	#$2700,sr	; Mise en Basse rÇsolution et en
	clr.b	$ffff8260.w	; 50 Hz
	move.b	#$2,$ffff820a.w
	lea	$fffffa00.w,a0	; Initialisation mpf
	clr.l	$0A(a0)
	clr.b	$19(a0)
	clr.b	$1B(a0)
	clr.b	$1D(a0)
	move.b	mfp_Ada+3(pc),$1f(a0)	; dÇlai mfp avant sa prochaine
	bclr	#3,$17(a0)		; intÇrruption
	move.w	#%0010000100000000,d0
	movep.w	d0,$7(a0)
	movep.w	d0,$13(a0)
	move.l	#TIMERB,$120.w
	move.l	#MFP,$134.w
	rts

Adapt:	bsr	Set_Up_Hardware		; Code adaptatif qui dÇcouvre 
	move.l	#.TIMERB,$120.w		; le dÇlai correct du timer A
	stop	#$2300			; pour l'obtention d'un over-
	stop	#$2300			; scan
	move.l	#VBL,$70.w
.again	moveq	#1,d2
.again2	moveq	#0,d1

.attente_fin_Çcran			; Attente que les 199 lignes
	tst.b	d1			; d'overscan aient ÇtÇ montrÇs
	beq.s	.attente_fin_Çcran

	move.l	Final_Screen_Address(pc),d0	; Test par rapport au
	and.l	#$ffffff,d0		; compteur vidÇo pour savoir si 
	move.l	$ffff8200.w,d1		; l'overscan a bien ÇtÇ dÇclechÇ
	lsl.w	#8,d1	
	and.l	#$ffff00,d1
	sub.l	d1,d0
	cmp.l	#199*230,d0
	bpl.s	.Ok
	dbra	d2,.again2		; on fait le test 2 fois pour
	subq.b	#1,mfp_Ada+3		; àtre sñr. Sinon, on dÇcrÇmente
	bne.s	.again			; le dÇlai.
	bra	Adapt
.Ok	subq.b	#1,mfp_Ada+3
	move.w	#$2700,sr
	rts

.TIMERB	clr.b	$fffffa19.w	; IntÇrruption locale de timer B qui
	clr.b	$fffffa1B.w	; s'assure que seuls 199 lignes
	clr.l	$fffffa0a.w	; d'overscan sont affichÇs.
.loop	move.b	(a1),d1		; Attente de la fin de la ligne 199
	cmp.b	(a1),d1
	bne.s	.loop
	movep.l	-6(a1),d1	; sauvegarde addresse Çcran atteinte
	move.l	d1,Final_Screen_Address
	moveq	#-1,d1
	rte

Final_Screen_Address	dc.l	0


TIMERB	clr.b	$fffffa19.w		; IntÇrruption  TimerB
	clr.b	$fffffa1B.w		; qui arràte l'intÇrruption
	clr.l	$fffffa0a.w		; Timer A d'overscan
	move.w	d6,$6C.w
RTE:	rte

VBL:	move	#$2700,sr		; La Vbl qui initialise les
	move.b	#200-1,$fffffa21.w	; registres et commence
	move.b	#8,$fffffa1B.w		; l'overscan
	moveq	#0,d6
.sync	cmp.b	#$6E,$FFFF8209.w
	bmi.s	.sync
	move.l	#$920092,d0
	lea	$ffff8209.w,a1

MFP	sub.b	(a1)+,d0		; On se synchronise par
	lsr.w	d0,d0			; rapport au compteur
	nop				; VidÇo
	move.b	d0,(a1)			; Overcan gauche
	move.w	a1,(a1)
	move.b	d0,$fffffa19.w		; 16
mfp_Ada	move.b	#mfp,$fffffa1f.w	; 20
	move.w	#1,d0			;  8
	lea	$ffff8260.w,a0		;  8
	move.w	a0,(a0)			; Stabilisateur
	clr.b	(a0)
	move.b	d0,$fffffa19.w		; 16
	swap	d0			;  4
	add.b	#230,d0			;  8 une ligne overscan prend
	move.w	d0,a1			;  4 230 octets: calcul de la
	swap	d0			;  4 prochaine adresse Çcran
	move.w	a1,d0			;  4 pour se synchroniser la
	lea	$ffff8209.w,a1		;  8 prochaine fois
	move.w	a0,(a0)			; Overcan droite
	clr.b	(a0)
	rte

