;Fichier exemple pour le source WD_1772.S
;Il vous montre comment appeler la routine de chargement.
;Evidemment, au lieu d'une bˆte attente au niveau du .wait
;vous pouvez mettre ce que bon vous semble...
;
;(C)oderigth Nullos//DNT-Crew 1992-93
;
	OPT	O+,W-
	SECTION	TEXT
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	include	tos_030.s
	include	hard_sys.s
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	StartUp			;Init la m‚moire
	clr.l	-(sp)		;
	Gemdos	Super		;Passe en superviseur
	move.l	d0,-(sp)		;Empile pour prochain Super
	move.l	V_DMA.w,-(sp)	;
	move.w	#$ff,flock.w	;Indique … la VBL que le
				;drive est utilis‚.

	lea	megabuff,a0	;Adresse de chargement
	move.l	#600,d0		;Charger du secteur 600..
	move.l	#899,d1		;au secteur 899.
	clr.w	Drive		;Lecteur A
	move.w	#80,Nb_Tracks	;80 pistes par face
	move.w	#9,Sect_Side	;10 secteurs par piste
	bsr	Load_Block		;hop

.wait	tst.w	End_Flag		;Transfert termin‚ ?
	bne.s	*-6		;non, attendre

the_end	bsr	Unset_drive	;EnlŠve la lampe du drive
	andi.b	#$7f,IERB+MFP_base.w	;arrˆte l'IT FDC
	andi.b	#$7f,IMRB+MFP_base.w	;
	move.l	(sp)+,V_DMA.w	;
	move.w	#$00,flock.w	;LibŠre le drive
	Gemdos	Super		;repasse en utilisateur
	Gemdos	Pterm0		;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	include	wd_1772.s
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	SECTION	BSS
megabuff	ds.b	300*512
stack	ds.b	512