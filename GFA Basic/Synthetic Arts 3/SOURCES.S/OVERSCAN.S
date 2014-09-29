*-------------------------------------------------------------------------*
*									  *
* 	-SYNTHETIC ARTS 3-						  *
*									  *
*	ROUTINE OVERSCAN AVEC FLIP PALETTE			  	  *
*									  *
*-------------------------------------------------------------------------*

	opt	o+,a+,p+

	output	e:\code\synthy.art\curent\fichiers.inl\over.inl

	SECTION TEXT
	
nnop	macro				Macro pour nbre de nop
	dcb.w	\1,$4e71
	endm
	
	lea	table(pc),a6
	move.l	4(sp),a0
	lea	pals(pc),a1
	moveq.l	#15,d0
copy:	move.l	(a0)+,(a1)+
	dbra.w	d0,copy

	clr.l	-(sp)			
	move.w	#$20,-(sp)		Fonction super
	trap	#1
	addq.l	#6,sp
	
	lea	stack(pc),a5
	move.l	d0,(a5)

	lea	sync(pc),a5
	move.b	$ffff820a.w,(a5)
	move.b	#2,$ffff820a.w
	move.b	#$12,$fffffc02.w	Desactive la souris		
	
	bsr.s	initmfp		      	Initialise le mfp
	
mainloop:
	tst.w	(a6)			teste le flag vbl
	beq.s	mainloop
	
	clr.w	(a6)			efface le flag
	
	move.b	$fffffc02.w,d0		registre de donnees en d0
	cmpi.b	#$39,d0			compare a barre d'espace
	beq.s	fin			si oui fin
	
	bra.s	mainloop		reboucle a mainloop

fin:
	
	move.b	sync(pc),$ffff820a.w	Passe en 50 Hz
	clr.b	$ffff8260.w		Restitue la resolution

	move	#$2700,sr		stop les interrup.

	bsr	finmfp			Restaure le mfp
	bsr	error_clavier		Vide le clavier

	move	#$2300,sr		active les interrup.

	move.b	#8,$fffffc02.w		Reactive la souris
	
	move.l	stack(pc),-(sp)		* Utilisateur
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	rts				Return to GFA

initmfp:
	move	sr,-(sp)		Sauve le sr
	move	#$2700,sr		Stop les interrup.
	
	lea	$fffffa01.w,a0		Adr depart registre general du mfp
	lea	oldmfp(pc),a1		adr dest sauvegarde
	move	#16,d0			nbre de registre a sauver
	
savemfp:
	move.b	(a0),(a1)+		Transfert des registres 	
	addq.l	#2,a0			Decalage sur le mfp

	dbra.w	d0,savemfp		Reboucle 
	
	movem.l	$100.w,d0-d7		On sauvegarde les vecteurs mfp
	movem.l	d0-d7,2(a6)			"
	movem.l	$120.w,d0-d7		Et le timer B
	movem.l	d0-d7,$22(a6)		"
	movem.l	$58.w,d0-d7		ainsi que le 68000...
	movem.l	d0-d7,$42(a6)		"
	
	bsr.s	finmfp			Branchement sur la fin d'init
	
	bclr.b	#3,$fffffa17.w		vide le bit 3 (fin d'interrup.)
	
	move.b	#%00100000,$fffffa07.w	init. timer A ( iera )
	move.b	#%00100000,$fffffa13.w	init. timer A ( imera )
	
	move.b	#%00000000,$fffffa09.w	inibe ierb 
	move.b	#%00000000,$fffffa15.w	inibe imr B
	
	lea	vbl(pc),a5
	move.l	a5,$70.w		rxestaure la vbl
	lea	hbl(pc),a5
	move.l	a5,$68.w		restaure la hbl
	lea	timera(pc),a5
	move.l	a5,$134.w		restaure le timer A
	
	move.w	(sp)+,sr		restaure le sr
	rts				fin de s/prg
	
*****************************************
*	RESTAURE LE MFP			*
*****************************************
finmfp:
	move.w	sr,-(sp)		Sauve le sr
	move.w	#$2700,sr		stop les interrup.

	lea	oldmfp(pc),a0		Restaure les vecteurs mfp
	lea	$fffffa01.w,a1			"
	move	#16,d0				 "
	
restmfp:

	move.b	(a0)+,(a1)			"
	addq.l	#2,a1				"
	dbra.w	d0,restmfp			"
	
	movem.l	2(a6),d0-d7		Restaure les vecteurs mfp	
	movem.l	d0-d7,$100.w			"
	movem.l	$22(a6),d0-d7	avec le timer B
	movem.l	d0-d7,$120.w			"
	movem.l	$42(a6),d0-d7	et le 68000
	movem.l	d0-d7,$58.w			"
	
	move	(sp)+,sr		Restaure le sr
	rts				fin de s/prg
	
error_clavier: 
	btst	#5,$fffffc00.w		vide le buffer clavier
	beq.s	noerror
	
	tst.b	$fffffc02.w
	bra.s	error_clavier
noerror:

	btst	#0,$fffffc00.w
	beq.s	vidbuff
	
	tst.b	$fffffc02.w
	bra.s	error_clavier
vidbuff:

	rts
*****************************************
*	HBL				*
*****************************************
	
hbl:
	rte
	
*****************************************
*	TIMER A				*
*****************************************

timera:
	move.w	#$2100,sr	
	stop	#$2100		; Synchro HBL
	move.w	#$2700,sr

	lea	$ffff820a.w,a0	; Overscan haut registre synchro ecran
	lea	$ffff8260.w,a1	; registre resolution
	moveq	#0,d0		; Prepare le 60 Hz
	moveq	#2,d1		; Prepare le 50 Hz
	nnop	 82
	move.b	#0,(a0)		; Passe en 60 Hz
	nnop	15
	move.b	#2,(a0)		; Passe en 50 Hz

	nnop	20		; Synchro SHIFTER
	moveq	#0,d2
	move.b	$ffff8209.w,d2
	neg.w	d2
	lsl.w	d2,d2
	

	nnop	41
	
	move.b	d0,(a0)		; Passe en 60 hz   Border droit
	move.b	d1,(a0)		; passe en 50 hz
	
	nnop	13
	         
	move.b	d1,(a1)		; Passe en haute resol  Border gauche
	nop
	move.b	d0,(a1)		; Passe en basse resol
	
	nnop	12
	
	move.b	d1,(a1)		; Passe en haute
	nop
	move.b	d0,(a1)		; Passe en basse

	nop	
	move.w	#211-1,d7
full1:
	nnop	86
	
	move.b	d0,(a0)
	move.b	d1,(a0)
	
	nnop	13
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	
	nnop	12
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	
	dbra	d7,full1
	
	nnop	85
	
	move.b	d0,(a0)
	move.b	d1,(a0)
	
	nnop	13
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	move.b	d0,(a0)	
	
	nnop	8
	
	nop
	move.b	d1,(a1)
	move.b	d1,(a0)	
	move.b	d0,(a1)
	
	move.w	#16-1-1,d7
	nop
	
full2:
	nnop	86
	
	move.b	d0,(a0)
	move.b	d1,(a0)
	
	nnop	13
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	
	nnop	12
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	
	dbra	d7,full2
	
	nnop	85
	
	move.b	d0,(a0)
	move.b	d1,(a0)
	
	nnop	13
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	move.b	d0,(a0)	
	
	nnop	8
	
	nop
	move.b	d1,(a1)
	move.b	d1,(a0)	
	move.b	d0,(a1)
	
	move.w	#43-1,d7
	nop
	
full3:
	nnop	86
	
	move.b	d0,(a0)
	move.b	d1,(a0)
	
	nnop	13
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	
	nnop	12
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	
	dbra	d7,full3
	
	nnop	85		
	
	move.b	d0,(a0)
	move.b	d1,(a0)
	
	nnop	13
	
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	
	clr.b	$fffffa07.w
	rte

*****************************************
*	VBL				*
*****************************************
vbl:
	clr.b	$fffffa19.w		Vide timer A
	move.b	#$65,$fffffa1f.w	data register
	move.b	#4,$fffffa19.w		mode delai 50 pre divisions
	move.b	#%00100000,$fffffa07.w	init. timer A
	
	move.w	#1,(a6)			flag a 1
	
	move.w	flip-table(a6),d6
	bchg.b	#5,flip-table+1(a6)
	lea	pals(pc,d6.w),a3
	lea	$ffff8240.w,a4
	rept	8
	move.l	(a3)+,(a4)+
	endr

	rte

*****************************************
*	DATA				*
*****************************************

pals:	ds.w	32

table:	dc.w	0
	ds.l	24
sync:	dc.w	0
oldmfp:	ds.b	24
stack:	dc.l	0
flip:	dc.w	0