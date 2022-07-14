;-------------------------------------------------------------------------
;ROCKYONE 		10.2020
;
;Erreur dans le tri des raster avec certaine image compress‚e dans:
;
;  "FillPalBuffer:" line 279
;
;-------------------------------------------------------------------------
start	Bra	AtariMagTrap
	dc.l	AtariMagGfa-start
AtariMagTrap
	movem.l	d1-d7/a0-a6,-(sp)
	move	usp,a6
	btst	#5,56(sp)
	beq.s	User
	lea	56+6(sp),a6
User	moveq	#0,d0
	move.w	(a6)+,d0
	cmp.w	#NbrFonctions,d0
	bpl.s	Erreur
	lea	Fonctions(pc),a5
	add.l	d0,d0
	add.l	d0,d0
	add.l	(a5,d0.l),a5
	jsr	(a5)
	movem.l	(sp)+,d1-d7/a0-a6
	rte
Erreur	movem.l	(sp)+,d1-d7/a0-a6
	moveq	#-1,d0
	rte
AtariMagGfa
	pea	Gfa(pc)
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	rts
Gfa	movem.l	d1-d7/a0-a6,-(sp)
	lea	56+12(sp),a6
	moveq	#0,d0
	move.w	(a6)+,d0
	cmp.w	#NbrFonctions,d0
	bpl.s	GfaErreur
	lea	Fonctions(pc),a5
	add.l	d0,d0
	add.l	d0,d0
	add.l	(a5,d0.l),a5
	jsr	(a5)
	movem.l	(sp)+,d1-d7/a0-a6
	rts
GfaErreur
	movem.l	(sp)+,d1-d7/a0-a6
	moveq	#-1,d0
	rts
Fonctions	dc.l	Rien-Fonctions,Rien-Fonctions
		dc.l	Rien-Fonctions,Rien-Fonctions
		dc.l	NeoMaster-Fonctions
EndFonctions
NbrFonctions	equ	(EndFonctions-Fonctions)/4
************************************************************
* Place occupee par les fonctions du DMA                   *
************************************************************
Rien	moveq	#-1,d0
	rts
************************************************************
* Affichage des images Neochrome Master                    *
* au format compacte ou non compacte '*.iff'               *
* avec 16 couleurs par ligne                               *
************************************************************
NeoMaster
	move.w	(a6)+,d0
	tst.w	d0
	beq.s	StopNeoMaster
	cmp.w	#1,d0
	beq.s	ShowNeoMaster
	moveq	#-1,d0
	rts
StopNeoMaster
	move.w	sr,-(sp)
	move.w	#$2700,sr
	lea	SystemInfo(pc),a0
	move.l	(a0),$4ce.w
	movem.l	OldColors(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.w	(sp)+,sr
	moveq	#0,d0
	rts
ShowNeoMaster
	move.w	sr,-(sp)
	move.w	#$2700,sr
	lea	OldColors(pc),a0
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)
	lea	SystemInfo(pc),a0
	move.l	$4ce.w,(a0)+
	movem.l	BlackColors(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr.s	NeochromePicture
	lea	Show3200colors(pc),a0
	move.l	a0,$4ce.w
	move.w	(sp)+,sr
	rts
NeochromePicture
; a0 contient l'adresse de base du fichier IFF
	move.l	(a6)+,a0
; a1 correspond a l'adresse fournit en parametre
; cela est en general l'adresse ecran
	move.l	(a6)+,a1

	cmp.l	#'FORM',(a0)+
	bne.s	erreur
	move.l	(a0)+,d0
	and.l	#1,d0
	bne.s	erreur
	cmp.l	#'ILBM',(a0)+
	bne.s	erreur

	moveq	#6-1,d7
.CheckChunk
	cmp.l	#'BMHD',(a0)
	bne.s	.Chunk1
	bsr.s	ReadBMHD
.Chunk1	cmp.l	#'CMAP',(a0)
	bne.s	.Chunk2
	bsr.s	ReadCMAP
.Chunk2	cmp.l	#'CRNG',(a0)
	bne.s	.Chunk3
	bsr	ReadCRNG
.Chunk3	cmp.l	#'CAMG',(a0)
	bne.s	.Chunk4
	bsr	ReadCAMG
.Chunk4	cmp.l	#'BODY',(a0)
	bne.s	.Chunk5
	bsr	ReadBODY
.Chunk5	cmp.l	#'RAST',(a0)
	bne.s	.Chunk6
	bsr	ReadRAST
.Chunk6	dbra	d7,.CheckChunk
	moveq	#0,d0
	rts
erreur	moveq	#-1,d0
	rts

ReadBMHD
	addq.l	#4,a0
	cmp.l	#20,(a0)+
	bne.s	erreurBMHD
	addq.l	#8,a0
	cmp.b	#4,(a0)+
	bne.s	erreurBMHD
	tst.b	(a0)+
	lea	FlagCompression(pc),a2
	move.b	(a0)+,(a2)
	addq.l	#5,a0
	cmp.w	#320,(a0)+
	bne.s	erreurBMHD
	cmp.w	#200,(a0)+
	bne.s	erreurBMHD
	rts
erreurBMHD
	addq.l	#4,sp
	bra.s	erreur

ReadCMAP
	addq.l	#4,a0
	cmp.l	#3*16,(a0)+
	bne.s	erreurCMAP
	lea	PalBuffer(PC),a2
	moveq	#15,d0
.ReadPalette
	move.b	(a0)+,d1
	lsl.w	#4,d1
	move.b	(a0)+,d1
	lsl.w	#4,d1
	move.b	(a0)+,d1
	lsr.w	#4,d1
	move.w	d1,d2
	and.w	#$EEE,d1
	lsr.w	d1
	and.w	#$111,d2
	lsl.w	#3,d2
	or.w	d2,d1
	move.w	d1,(a2)+
	dbra	d0,.ReadPalette
	movem.l	-32(a2),d1-d6/a3-a4
	move.w	#198,d0
.FillPalBuffer
	movem.l	d1-d6/a3-a4,(a2)
	lea	32(a2),a2
	dbra	d0,.FillPalBuffer
	rts
erreurCMAP
	addq.l	#4,sp
	bra.s	erreur

ReadCRNG
	addq.l	#4,a0
	add.l	(a0)+,a0
	rts

ReadCAMG
	addq.l	#4,a0
	add.l	(a0)+,a0
	rts

ReadBODY
	addq.l	#8,a0
	move.l	a0,a3
	add.l	-4(a3),a3

	lea	FlagCompression(pc),a2
	tst.b	(a2)
	bne.s	DepackPicture

	move.w	#199,d6
.Print0	moveq	#3,d5
.Print1	moveq	#19,d4
.Print2	move.w	(a0)+,(a1)
	addq.l	#8,a1
	dbra	d4,.Print2
	lea	-158(a1),a1
	dbra	d5,.Print1
	lea	152(a1),a1
	dbra	d6,.Print0
	exg.l	a3,a0
	rts

DepackPicture
	move.w	#199,d6
Print0	moveq	#3,d5
Print1	moveq	#40,d4
	lea	BufferDecompactage(pc),a2
Cont	move.b	(a0)+,d0
	blt.s	Nop?
	addq.b	#1,d0 
	ext.w	d0
	sub.w	d0,d4 
	bra.s	Copy0
Loop0	move.b	(a0)+,(a2)+ 
Copy0	dbra	d0,Loop0
	bra.s	Nop 
Nop?	cmp.b	#$80,d0
	beq.s	Nop
	ext.w	d0
	neg.w	d0
	addq.w	#1,d0 
	sub.w	d0,d4 
	move.b	(a0)+,d1
	bra.s	Copy1
Loop1	move.b	d1,(a2)+
Copy1	dbra	d0,Loop1
Nop	tst.w	d4
	bne.s	Cont
	lea	BufferDecompactage(pc),a2
	moveq	#19,d4
Print2	move.w	(a2)+,(a1)
	addq.l	#8,a1
	dbra	d4,Print2
	lea	-158(a1),a1
	dbra	d5,Print1
	lea	152(a1),a1
	dbra	d6,Print0
	exg.l	a3,a0
	rts

ReadRAST
	addq.l	#4,a0

	lea	PalBuffer(pc),a2
	move.l	(a0)+,d0
	divu	#34,d0
	and.w	#$ff,d0
	subq.w	#1,d0
	bmi.s	erreurRAST
	subq.w	#1,d0
	moveq	#0,d1
	move.w	(a0),d1
	lsl.w	#4,d1
	add.l	d1,a2
	move.w	(a0)+,d1
....................................error !!!  rockyone 10.2020
FillPalBuffer
	movem.l	(a0)+,d3-d6/a3-a6
Fill1:	movem.l	d3-d6/a3-a6,(a2)
	lea	32(a2),a2
	addq.w	#1,d1
	cmp.w	(a0),d1
	bne.s	Fill1
	addq.l	#2,a0
	dbra	d0,FillPalBuffer
........................................................
	movem.l	(a0)+,d3-d6/a3-a6
Fill2	movem.l	d3-d6/a3-a6,(a2)
	lea	32(a2),a2
	addq.w	#1,d1
	cmp.w	#200,d1
	bne.s	Fill2
	rts
erreurRAST
	addq.l	#4,sp
	bra	erreur

Show3200colors
	btst.b	#1,$ffff820a.w
	beq	Show3200colors60Hz
	tst.w	$43e.w
	bne	EndShow3200colors
	move.w	sr,-(sp)
	movem.l	d0-d7/a0-a6,-(sp)
	or.w	#$700,sr
	lea	PalBuffer+32(pc),a0
	move.w	#$8240,a1
	move.w	#$8209,a5
	lea	WaitNeoMaster(pc),a6
	move.w	#198,d7
	moveq	#0,d0
WaitDisplayNeoMaster
	tst.b	(a5)
	beq.s	WaitDisplayNeoMaster
	move.b	(a5),d0
	add.l	d0,a6
	jmp	(a6)
WaitNeoMaster
	rept	75
	nop
	endr
DisplayMultiColorsNeoMaster
	movem.l	(a0)+,d0-d6/a2
	movem.l	d0-d6/a2,(a1)
	rept	88
	nop
	endr
	dbra	d7,DisplayMultiColorsNeoMaster
	lea	PalBuffer(pc),a0
	movem.l	(a0)+,d0-d6/a2
	movem.l	d0-d6/a2,(a1)

	movem.l	(sp)+,d0-d7/a0-a6
	move.w	(sp)+,sr
EndShow3200colors
	rts
Show3200colors60Hz
	tst.w	$43e.w
	bne	EndShow3200colors60Hz
	move.w	sr,-(sp)
	movem.l	d0-d7/a0-a6,-(sp)
	or.w	#$700,sr
	lea	PalBuffer+32(pc),a0
	move.w	#$8240,a1
	move.w	#$8209,a5
	lea	WaitNeoMaster60Hz(pc),a6
	move.w	#198,d7
	moveq	#0,d0
WaitDisplayNeoMaster60Hz
	tst.b	(a5)
	beq.s	WaitDisplayNeoMaster60Hz
	move.b	(a5),d0
	add.l	d0,a6
	jmp	(a6)
WaitNeoMaster60Hz
	rept	74
	nop
	endr
DisplayMultiColorsNeoMaster60Hz
	movem.l	(a0)+,d0-d6/a2
	movem.l	d0-d6/a2,(a1)
	rept	87
	nop
	endr
	dbra	d7,DisplayMultiColorsNeoMaster60Hz
	lea	PalBuffer(pc),a0
	movem.l	(a0)+,d0-d6/a2
	movem.l	d0-d6/a2,(a1)

	movem.l	(sp)+,d0-d7/a0-a6
	move.w	(sp)+,sr
EndShow3200colors60Hz
	rts
************************************************************
* Datas..........                                          *
************************************************************
BlackColors	dc.l	0,0,0,0,0,0,0,0
OldColors	ds.l	8
SystemInfo	ds.l	1
FlagCompression	ds.w	1
BufferDecompactage	ds.l	10
PalBuffer	ds.l	32*200/4
