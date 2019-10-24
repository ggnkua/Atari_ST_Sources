	; Comparateur de fichier

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
	bsr	LoadFile1
	bmi.s	End

	lea	TextIntro2(pc),a0
	bsr	PrintText

	bsr.s	FileSelect
	beq.s	End
	bsr	LoadFile2
	bmi.s	End

	bsr	CompareFile
	bmi.s	Different

	lea	TextOK(pc),a0
	bsr	PrintText

End2:
	move	#7,-(sp)
	trap	#1
	addq	#2,sp

	clr	-(sp)
	trap	#1
Different:
	lea	TextErreur(pc),a0
	bsr	PrintText
	bra.s	End2

End:	lea	TextKey(pc),a0
	bsr	PrintText
	bra.s	End2

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

LoadFile1:
	clr	-(sp)
	pea	PathName(pc)
	move	#$4e,-(sp)
	trap	#1	FSFirst
	addq	#8,sp
	tst	d0
	bmi.s	LoadError1

	lea	File1(pc),a0
	move.l	DTABuffer+26(pc),d0
	move.l	d0,LenghtFile1
	add.l	a0,d0
	move.l	d0,AdrFile2	Adresse du deuxiäme fichier

	clr	-(sp)
	pea	PathName(pc)
	move	#$3d,-(sp)
	trap	#1		fopen
	addq	#8,sp
	move	d0,FileHandle

	pea	File1(pc)
	move.l	LenghtFile1(pc),-(sp)
	move	d0,-(sp)
	move	#$3f,-(sp)
	trap	#1		fread
	lea	12(sp),sp

	move	FileHandle(pc),-(sp)
	move	#$3e,-(sp)
	trap	#1		fclose
	addq	#4,sp

	moveq	#0,d0
LoadError1:
	rts

LoadFile2:
	clr	-(sp)
	pea	PathName(pc)
	move	#$4e,-(sp)
	trap	#1	FSFirst
	addq	#8,sp
	tst	d0
	bmi.s	LoadError2

	move.l	DTABuffer+26(pc),LenghtFile2

	clr	-(sp)
	pea	PathName(pc)
	move	#$3d,-(sp)
	trap	#1		fopen
	addq	#8,sp
	move	d0,FileHandle

	move.l	AdrFile2(pc),-(sp)
	move.l	LenghtFile2(pc),-(sp)
	move	d0,-(sp)
	move	#$3f,-(sp)
	trap	#1		fread
	lea	12(sp),sp

	move	FileHandle(pc),-(sp)
	move	#$3e,-(sp)
	trap	#1		fclose
	addq	#4,sp

	moveq	#0,d0
LoadError2:
	rts

CompareFile:
	move.l	LenghtFile1(pc),d0
	cmp.l	LenghtFile2(pc),d0
	bne.s	.Different
	;DÇjÖ ils ont meme longueur, bon signe...

	lea	File1(pc),a0
	move.l	AdrFile2(pc),a1
.Compare:subq.l	#1,d0
	bmi.s	.FinFichier
	cmpm.b	(a0)+,(a1)+
	beq.s	.Compare
.Different:
	moveq	#-1,d0
	rts
.FinFichier:
	moveq	#0,d0
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

TextIntro:	dc.b	27,'EComparateur de fichier.',$a,$d
		dc.b	'Selectionnez votre premier fichier Ö comparer.',$a,$d,0
TextIntro2:	dc.b	27,'ESelectionnez votre deuxiäme fichier Ö comparer.',$a,$d,0
TextOK:		dc.b	27,'EFichiers identiques.',$a,$d
		dc.b	'Pressez une touche.',$a,$d,0
TextErreur:	dc.b	27,'EFichiers differents.',$a,$d
		dc.b	'Pressez une touche.',$a,$d,0
TextKey:	dc.b	27,'EPressez une touche.',$a,$d,0

	section BSS

	even
FileHandle:	ds.w	1
Path:		ds.b	80
FileName:	ds.b	14
PathName:	ds.b	80
Int_Out:	ds.w	2
Adr_Out:	ds.l	1
DTABuffer:	ds.b	44
LenghtFile1:	ds.l	1
LenghtFile2:	ds.l	1
AdrFile2:	ds.l	1
		ds.b	8192
Pile:
File1:
	ds.b	1500000
