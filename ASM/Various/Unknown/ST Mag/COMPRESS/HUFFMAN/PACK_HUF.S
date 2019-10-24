	; Compresseur Huffman

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
	bsr	CompressHUFFMAN
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

	lea	File,a0
	add.l	DTABuffer+26(pc),a0	+Taille
	move.l	a0,d0
	addq	#1,d0
	bclr	#0,d0
	move.l	d0,AdrPack		Adresse (paire) du code compactÇ
	move.l	d0,CurrentWrite		Adresse de l'octet Ö ecrire

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

	move.l	AdrPack(pc),-(sp)
	move.l	LenghtPack(pc),-(sp)
	move	FileHandle(pc),-(sp)
	move	#$40,-(sp)
	trap	#1
	lea	12(sp),sp

	move	FileHandle(pc),-(sp)
	move	#$3e,-(sp)
	trap	#1
	addq	#4,sp
	rts

CompressHUFFMAN:
	lea	File,a0
	move.l	AdrPack(pc),a1
	move.l	#'HUFF',(a1)+
	move.l	DTABuffer+26(pc),d0	Taille du fichier
	move.l	d0,(a1)+
	addq.l	#8,CurrentWrite

	lea	(a0,d0.l),a6		Fin du fichier

	bsr.s	CountByte
	bsr.s	CreateTree
	bsr	CopyHeader
	bsr	FoundCode
	bsr	CodeFile
	rts

CountByte:
	lea	TableCount(pc),a1
.loop:
	cmp.l	a0,a6
	ble.s	.EndOfFile
	moveq	#0,d0
	move.b	(a0)+,d0
	add	d0,d0
	add	d0,d0
	addq.l	#1,(a1,d0)
	bra.s	.loop
.EndOfFile:rts

CreateTree:
	bsr.s	InitFeuille
	bra.s	.start
.loop:	bsr.s	TriListe

	move	d7,d6
	lsl	#3,d6		*3
	lea	DataListe(pc),a0
	add	d6,a0		;Adresse entre dernier et avant-dernier sous-arbre
	bsr	NoeudAlloc
	move	#-1,(a1)	;Noeud
	move.l	(a0),2(a1)	;Fils gauche
	move.l	8(a0),6(a1)	;Fils droit
	move.l	12(a0),d0	;Critäre deuxiäme fils
	add.l	d0,4(a0)	;Nouveau critäre
	move.l	a1,(a0)		;Adresse du nouveau sous-arbre
.start:	dbra	d7,.loop
.EndCreateTree:
	move.l	DataListe(pc),AdrTree
	rts

InitFeuille:
	lea	TableCount(pc),a0
	lea	DataListe(pc),a2
	move	#255,d6
	moveq	#-1,d7
.loop:	move.l	(a0)+,d0
	beq.s	.NoCreateNoeud
	addq	#1,d7
	bsr.s	NoeudAlloc

	move	#255,d1
	sub	d6,d1
	move	d1,(a1)			;Critäre de l'arbre
	clr.l	2(a1)			;Feuille Pas de fils gauche
	clr.l	6(a1)			;Feuille Pas de fils droit
	move.l	a1,(a2)+
	move.l	d0,(a2)+		;Critäre de la liste
.NoCreateNoeud:
	dbra	d6,.loop
	rts

TriListe:
	;tri Ö bulle...
FirstLoop:
	lea	DataListe(pc),a0
	move	d7,d6
	moveq	#0,d4		;Flag de tri
SecondLoop:
	move.l	4(a0),d0
	move.l	12(a0),d1
	cmp.l	d0,d1
	ble.s	.ok
	;swappe les deux valeurs
	move.l	(a0),d2
	move.l	8(a0),(a0)	
	move.l	d2,8(a0)

	move.l	d0,12(a0)
	move.l	d1,4(a0)
	st	d4
.ok:
	addq	#8,a0		;Prochain couple
	dbra	d6,SecondLoop
	tst	d4
	bne.s	FirstLoop
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

CopyHeader:
	move.l	AdrTree(pc),-(sp)
	bsr.s	DeveloppeNoeud
	rts

DeveloppeNoeud:
	move.l	4(sp),a1		Adresse du noeud appelant

	move	(a1),d0			Critäre
	bpl.s	DeveloppeFeuille

	moveq	#-1,d1			;Code noeud
	bsr	PutBit

	move.l	2(a1),-(sp)		Adresse fils gauche
	bsr.s	DeveloppeNoeud		RÇcursion

	move.l	4(sp),a1		RÇcupäre adresse du noeud 
	;Evite de le sauver puis de le rÇcuperer

	move.l	6(a1),-(sp)		Adresse fils droit
	bsr.s	DeveloppeNoeud		RÇcursion
OutRecurse:
	move.l	(sp),a1			Adresse code appelant
	addq	#8,sp			Remet pile Ö niveau
	jmp	(a1)			Retour au programme appelant

DeveloppeFeuille:
	moveq	#0,d1			;Code feuille
	bsr	PutBit
	move	d0,d1
	moveq	#8,d7
	bsr	PutCode
	bra.s	OutRecurse

FoundCode:
	move.l	AdrTree(pc),-(sp)
	move.l	#0,-(sp)		;Code dÇjÖ existant
	move	#0,-(sp)		;Longueur du code
	bsr.s	DeveloppeCode
	rts

DeveloppeCode:
	move	4(sp),d7		;Longeur du code
	move.l	6(sp),d6		;Code existant
	move.l	10(sp),a1		;Adresse du noeud

	move	(a1),d0			;Critäre
	bpl.s	CodeFeuille

	move.l	2(a1),-(sp)
	lsl.l	d6
	move.l	d6,-(sp)		;Code Insertion d'un 0
	addq	#1,d7
	move	d7,-(sp)		;Longueur du code +1
	bsr.s	DeveloppeCode

	move	4(sp),d7
	move.l	6(sp),d6
	move.l	10(sp),a1
	lsl.l	d6
	addq	#1,d6			;Insertion d'un 1
	move.l	6(a1),-(sp)
	move.l	d6,-(sp)
	addq	#1,d7
	move	d7,-(sp)
	bsr.s	DeveloppeCode
OutRecurse2:
	move.l	(sp),a1
	lea	4+4+4+2(sp),sp
	jmp	(a1)
CodeFeuille:
	lea	CodeByte(pc),a0
	add	d0,d0		2*d0
	move	d0,d1		2*d0
	add	d0,d0		4*d0
	add	d1,d0		6*d0
	add	d0,a0
	move.l	d6,(a0)+
	move	d7,(a0)+
	bra.s	OutRecurse2

CodeFile:
	lea	File,a0			Debut du fichier Ö compacter
	move.l	a0,a1
	add.l	DTABuffer+26(pc),a1	Fin du fichier
	lea	CodeByte(pc),a2
.loop:	cmp.l	a0,a1
	ble.s	.EndPack
	moveq	#0,d0
	move.b	(a0)+,d0
	add	d0,d0
	move	d0,d1
	add	d0,d0
	add	d1,d0	6*d0
	move.l	a2,a3
	add	d0,a3			Adresse du code
	move.l	(a3)+,d1		Code
	move	(a3)+,d7		Taille du code
	bsr.s	PutCode
	bra.s	.loop
.EndPack:
	move.l	CurrentWrite(pc),a0
	cmp	#7,DecalageWrite
	beq.s	.NoInc
	addq	#1,a0
.NoInc:
	sub.l	AdrPack(pc),a0
	move.l	a0,LenghtPack
	rts

PutBit:
	movem.l	d2/a2,-(sp)

	move	DecalageWrite(pc),d2
	move.l	CurrentWrite(pc),a2

	add.l	d1,d1
	bcs.s	.Ok
	bclr	d2,(a2)
.EndPutBit:
	subq	#1,DecalageWrite
	bpl.s	.End2
	move	#7,DecalageWrite
	addq.l	#1,CurrentWrite
.End2:
	movem.l	(sp)+,d2/a2
	rts
.Ok:	bset	d2,(a2)
	bra.s	.EndPutBit

PutCode:ror.l	d7,d1		Met sur bit fort
	subq	#1,d7
.loop:	bsr.s	PutBit
	dbra	d7,.loop
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

TextIntro:	dc.b	27,'EPackeur HUFFMAN',$a,$d
		dc.b	'Selectionnez votre fichier Ö compacter.',$a,$d,0
TextOK:		dc.b	27,'ECompactage HUFFMAN rÇussi.',$a,$d,0
		dc.b	'Selectionnez le nom de la sauvegarde.',$a,$d,0
TextNO:		dc.b	27,'ECompactage HUFFMAN impossible.',$a,$d,0
TextSave:	dc.b	27,'EErreur de sauvegarde.',$a,$d,0
TextFIN:	dc.b	27,'ESauvegarde faite, pressez une touche.',$a,$d,0

	even
DecalageWrite:	dc.w	7

	section BSS

	even

FileHandle:	ds.w	1
Path:		ds.b	80
FileName:	ds.b	14
PathName:	ds.b	80
Int_Out:	ds.w	2
Adr_Out:	ds.l	1
DTABuffer:	ds.b	44
AdrPack:	ds.l	1
CurrentWrite:	ds.l	1
LenghtPack:	ds.l	1

TableCount:	ds.l	256
CodeByte:	ds.b	256*(4+2)

	;Gestion de l'arbre
AdrTree:	ds.l	1
DataListe:	ds.l	2000*(1+1)		Adresse noeud+Critäre
DataMalloc:	ds.b	2000			Flag noeud
DataTree:	ds.b	2000*(4+4+2)		Adresse FG, FD, Critäre

		ds.b	8192		Taille importante pour rÇcursion
Pile:
File:
