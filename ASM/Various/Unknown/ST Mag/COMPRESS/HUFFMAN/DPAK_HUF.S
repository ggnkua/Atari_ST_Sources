	; D‚compresseur HUFFMAN

	move.l	a7,a5
	lea	Pile,a7
	move.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	clr	-(sp)
	move	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

	bsr	FSetDTA
	move	#$19,-(sp)
	trap	#1
	addq	#2,sp
	add.b	#'A',d0
	move.b	d0,Path

	clr	-(sp)
	pea	Path+1(pc)
	move	#$47,-(sp)
	trap	#1
	addq	#8,sp
	
	lea	Path+1(pc),a0
	move.b	#':',(a0)+
EndPath:tst.b	(a0)+
	bne.s	EndPath
	
	move.b	#'\',-1(a0)
	move.b	#'*',(a0)+
	move.b	#'.',(a0)+
	move.b	#'*',(a0)+
	clr.b	(a0)+

	lea	TextIntro(pc),a0
	bsr	PrintText

	bsr.s	FileSelect
	beq.s	End
	bsr	LoadFile
	bmi.s	End
	bsr	DeCompressHUFFMAN
	bmi.s	NoPacked

	lea	TextOK(pc),a0
	bsr	PrintText

	bsr.s	FileSelect
	beq.s	NoSave
	bsr	SaveFile
End:
	lea	TextFIN(pc),a0
	bsr	PrintText

	move	#7,-(sp)
	trap	#1
	addq	#2,sp

	clr	-(sp)
	trap	#1
NoPacked:
	lea	TextNO(pc),a0
	bsr	PrintText
	bra.s	End
NoSave:
	lea	TextSave(pc),a0
	bsr	PrintText
	bra.s	End

FileSelect:
	dc.w	$a009
	move.l	#Param,d1
	move.l	#200,d0
	trap	#2
	dc.w	$a00a
	tst	Int_Out+2
	beq.s	Cancel
	lea	Path(pc),a0
	lea	PathName(pc),a1
CopyPath:move.b	(a0)+,(a1)+
	bne.s	CopyPath

NoShlash:cmp.b	#'\',-(a1)
	bne.s	NoShlash

	addq	#1,a1

	lea	FileName(pc),a0
CopyName:move.b	(a0)+,(a1)+
	bne.s	CopyName
	moveq	#-1,d0		CCR pour chargement
Cancel:	rts

FSetDTA:pea	DTABuffer(pc)
	move	#$1a,-(sp)
	trap	#1
	addq	#6,sp
	rts

LoadFile:
	clr	-(sp)
	pea	PathName(pc)
	move	#$4e,-(sp)
	trap	#1	FSFirst
	addq	#8,sp
	tst	d0
	bmi.s	LoadError

	move.l	DTABuffer+26(pc),d0
	add.l	#File,d0		+Taille
	addq	#1,d0
	bclr	#0,d0
	move.l	d0,AdrDePack		Adresse (paire) du code … compacter

	clr	-(sp)
	pea	PathName(pc)
	move	#$3d,-(sp)
	trap	#1		fopen
	addq	#8,sp
	move	d0,FileHandle

	pea	File
	move.l	DTABuffer+26(pc),-(sp)
	move	d0,-(sp)
	move	#$3f,-(sp)
	trap	#1		fread
	lea	12(sp),sp

	move	FileHandle(pc),-(sp)
	move	#$3e,-(sp)
	trap	#1		fclose
	addq	#4,sp

	moveq	#0,d0
LoadError:
	rts

SaveFile:
	clr	-(sp)
	pea	PathName(pc)
	move	#$3c,-(sp)
	trap	#1
	addq	#8,sp
	move	d0,FileHandle

	move.l	AdrDePack(pc),-(sp)
	move.l	LenghtDePack(pc),-(sp)
	move	FileHandle(pc),-(sp)
	move	#$40,-(sp)
	trap	#1
	lea	12(sp),sp

	move	FileHandle(pc),-(sp)
	move	#$3e,-(sp)
	trap	#1
	addq	#4,sp
	rts

DeCompressHUFFMAN:
	lea	File,a0
	cmp.l	#'HUFF',(a0)+
	beq.s	OkHUFFMAN
	cmp.l	#'FNSH',-4(a0)
	beq.s	OkSHANNON
	moveq	#-1,d0			Pas fichier HUFFMAN ni SHANNON
	rts

OkHUFFMAN:
OkSHANNON:
	move.l	(a0)+,LenghtDePack	Taille du fichier d‚compress‚

	move.l	a0,CurrentRead
	move	#7,DecalageRead

	bsr.s	ReadHeader
	bsr.s	DepackCode

	moveq	#0,d0
	rts

ReadHeader:
	clr.l	-(sp)			Code
	clr	-(sp)			Taille du code
	bsr.s	ReadNoeud
	move.l	a2,AdrTree
	rts

ReadNoeud:
	move	4(sp),d0		Taille du code
	move.l	6(sp),d1		Code

	bsr	NoeudAlloc

	bsr.s	ReadBit
	beq.s	ReadFeuille

	move	#-1,(a1)		Noeud

	add.l	d1,d1
	move.l	a1,-(sp)
	move.l	d1,-(sp)		Code d‚cal‚
	addq	#1,d0
	move	d0,-(sp)		Taille du code+1
	bsr.s	ReadNoeud
	move.l	(sp)+,a1
	move.l	a2,2(a1)		Adresse fils gauche

	move	4(sp),d0
	move.l	6(sp),d1
	add.l	d1,d1
	move.l	a1,-(sp)
	move.l	d1,-(sp)
	addq	#1,d0
	move	d0,-(sp)
	bsr.s	ReadNoeud
	move.l	(sp)+,a1
	move.l	a2,6(a1)		Adresse fils droit

EndReadNoeud:
	move.l	a1,a2
	move.l	(sp),a3
	lea	10(sp),sp
	jmp	(a3)

ReadFeuille:
	moveq	#8,d7
	bsr.s	ReadCode
	move	d6,(a1)			Code feuille
	bra.s	EndReadNoeud

DepackCode:
	move.l	AdrDePack(pc),a5	Adresse de debut de code
	move.l	LenghtDePack(pc),d0
	lea	(a5,d0.l),a6		Adresse de fin de code
MainLoop:
	move.l	AdrTree(pc),a1
SecondLoop:
	tst	(a1)			On reconnait une feuille
	bpl.s	PutFeuille
	
	bsr.s	ReadBit
	bne.s	RightTree

	;Left tree
	move.l	2(a1),a1		Developpe branche gauche
	bra.s	SecondLoop
RightTree:
	move.l	6(a1),a1		Developpe branche droite
	bra.s	SecondLoop
PutFeuille:
	move.b	1(a1),(a5)+

	cmp.l	a5,a6
	bgt.s	MainLoop
	rts

ReadBit:
	movem.l	d0,-(sp)
	move.l	CurrentRead(pc),a4
	move	DecalageRead(pc),d0
	subq	#1,DecalageRead
	bpl.s	.NoNext
	move	#7,DecalageRead
	addq.l	#1,CurrentRead
.NoNext:btst.b	d0,(a4)
	movem.l	(sp)+,d0
	rts

ReadCode:
	moveq	#0,d6
	subq	#1,d7
.loop:	add	d6,d6
	bsr.s	ReadBit
	beq.s	.NoSet
	addq	#1,d6
.NoSet:	dbra	d7,.loop
	rts

NoeudAlloc:
	move.l	a0,-(sp)
	lea	DataMalloc(pc),a0
	lea	DataTree(pc),a1
.loop:	lea	10(a1),a1
	tst.b	(a0)+
	bne.s	.loop
	lea	-10(a1),a1		Remet bonne adresse
	st	-1(a0)			Positionne le flag
	move.l	(sp)+,a0
	rts

PrintText:
	pea	(a0)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	move	#50,d0
Wait:	move	d0,-(sp)
	move	#$25,-(sp)
	trap	#14		Vsync
	addq	#2,sp
	move	(sp)+,d0
	dbra	d0,Wait
	rts

	section	DATA

Param:	dc.l	Control,Global,Int_In,Int_Out,Adr_In,Adr_Out
Control:dc.w	90,0,2,2,0
Global:	dc.w	0
Int_In:	dc.w	0
Adr_In:	dc.l	Path,FileName

TextIntro:	dc.b	27,'ED‚packeur HUFFMAN/FANO-SHANNON',$a,$d
		dc.b	'Selectionnez votre fichier … d‚compacter.',$a,$d,0
TextOK:		dc.b	27,'EFichier d‚compact‚.',$a,$d,0
		dc.b	'Selectionnez le nom de la sauvegarde.',$a,$d,0
TextNO:		dc.b	27,"ECe n'est pas un fichier compact‚ HUFFMAN/FANO-SHANNON.",$a,$d,0
TextSave:	dc.b	27,'EErreur de sauvegarde. Pressez une touche.',$a,$d,0
TextFIN:	dc.b	27,'ESauvegarde faite, pressez une touche.',$a,$d,0

	section BSS

	even
FileHandle:	ds.w	1
Path:		ds.b	80
FileName:	ds.b	14
PathName:	ds.b	80
Int_Out:	ds.w	2
Adr_Out:	ds.l	1
DTABuffer:	ds.b	44
AdrDePack:	ds.l	1
LenghtDePack:	ds.l	1
CurrentRead:	ds.l	1
DecalageRead:	ds.w	1

		;Gestion de l'arbre
AdrTree:	ds.l	1
DataListe:	ds.l	2000*(1+1)		Adresse noeud+CritŠre
DataMalloc:	ds.b	2000			Flag noeud
DataTree:	ds.b	2000*(4+4+2)		Adresse FG, FD, CritŠre


		ds.b	8192
Pile:
File:
