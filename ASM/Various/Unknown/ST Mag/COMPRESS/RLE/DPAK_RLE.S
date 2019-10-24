	; D‚compresseur Run Lenght Encoding

	move.l	a7,a5
	lea	Pile(pc),a7
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
	bsr	DeCompressRLE
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

	lea	File(pc),a0
	add.l	DTABuffer+26(pc),a0	+Taille
	move.l	a0,d0
	addq	#1,d0
	bclr	#0,d0
	move.l	d0,AdrDePack		Adresse (paire) du code … compacter

	clr	-(sp)
	pea	PathName(pc)
	move	#$3d,-(sp)
	trap	#1		fopen
	addq	#8,sp
	move	d0,FileHandle

	pea	File(pc)
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

DeCompressRLE:
	lea	File(pc),a0
	move.l	AdrDePack(pc),a1
	cmp.l	#'RLE',(a0)+
	beq.s	OkRLE
	moveq	#-1,d0			Pas fichier RLE
	rts
EndRLE:
	sub.l	AdrDePack(pc),a1
	move.l	a1,LenghtDePack
	moveq	#0,d0
	rts

OkRLE:	move.l	(a0)+,d0		Taille du fichier d‚compress‚
	lea	(a1,d0.l),a6
BoucleDePack:
	cmp.l	a1,a6
	ble.s	EndRLE
	moveq	#0,d0
	move.b	(a0)+,d0		Code s‚quence
	bmi.s	Compresse
CopyInCompresse:
	move.b	(a0)+,(a1)+
	dbra	d0,CopyInCompresse
	bra.s	BoucleDePack
Compresse:
	sub	#128-3+1,d0
	move.b	(a0)+,d1
FillCompresse:
	move.b	d1,(a1)+
	dbra	d0,FillCompresse
	bra.s	BoucleDePack

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

TextIntro:	dc.b	27,'ED‚packeur RLE',$a,$d
		dc.b	'Selectionnez votre fichier … d‚compacter.',$a,$d,0
TextOK:		dc.b	27,'EFichier d‚compact‚.',$a,$d,0
		dc.b	'Selectionnez le nom de la sauvegarde.',$a,$d,0
TextNO:		dc.b	27,"ECe n'est pas un fichier compact‚ RLE.",$a,$d,0
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
		ds.b	8192
Pile:
File:
