	; Compresseur Run Lenght Encoding

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
	bsr	CompressRLE
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
	move.l	d0,AdrPack		Adresse (paire) du code … compacter

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

CompressRLE:
	lea	File(pc),a0
	move.l	AdrPack(pc),a1
	move.l	#'RLE',(a1)+
	move.l	DTABuffer+26(pc),d0	Taille du fichier
	move.l	d0,(a1)+
	lea	(a0,d0.l),a6		Fin du fichier
MainLoop:
	move.l	a6,d0
	sub.l	a0,d0
	cmp.l	#2,d0
	ble.s	AlgoEndCompress	;Si 0,1 ou 2 octets -> incompression
	;Donc ici 3 octets ou plus -> les deux algorithmes
	;sont utilisables...

	move.b	(a0),d0
	moveq	#1,d1
	cmp.b	1(a0),d0
	bne.s	InCompress
	;Deux octets identiques
	cmp.b	2(a0),d0
	beq.s	Compress	;Trois octets identiques
				;On envoie algorithme Compression
	addq	#1,d1
InCompress:
	lea	(a0,d1),a2
	move.b	-1(a2),d0	;Dernier octet lu
CountInCompress:
	cmp.l	a2,a6
	ble.s	EndInCompress
	move.b	-1(a2),d0
	cmp.b	(a2)+,d0
	bne.s	CountInCompress
	;Deux fois meme octets... trois ???
	cmp.l	a2,a6
	ble.s	EndInCompress
	cmp.b	(a2)+,d0
	bne.s	CountInCompress	;Seulement Deux identiques -> Rien
	;Au moins trois donc envoie s‚quence...
	subq	#3,a2	;Fin s‚quence Incompactable
EndInCompress:
	move.l	a2,d0
	sub.l	a0,d0		;Nombre d'octet de la s‚quence
BoucleInCompress:
	cmp.l	#128,d0
	ble.s	UneSequenceInCompress
	sub.l	#128,d0
	move.b	#127,(a1)+
	moveq	#127,d1
CopyInCompress1:
	move.b	(a0)+,(a1)+
	dbra	d1,CopyInCompress1
	bra.s	BoucleInCompress
UneSequenceInCompress:
	subq.l	#1,d0
	move.b	d0,(a1)+
CopyInCompress2:
	move.b	(a0)+,(a1)+
	dbra	d0,CopyInCompress2
	bra.s	MainLoop

AlgoEndCompress:	;Plus que 0,1 ou 2 octets … compacter
	subq	#1,d0
	bmi.s	.End
	move.b	d0,(a1)+
.Copy:	move.b	(a0)+,(a1)+
	dbra	d0,.Copy
.End:
	sub.l	AdrPack(pc),a1
	move.l	a1,LenghtPack

	cmp.l	DTABuffer+26(pc),a1
	bge.s	.NoPacked
	moveq	#0,d0		;Compression r‚ussie
	rts
.NoPacked:
	moveq	#-1,d0
	rts

Compress:
	lea	3(a0),a2
BoucleCompress:
	cmp.l	a2,a6
	ble.s	EndCompress
	cmp.b	(a2)+,d0
	beq.s	BoucleCompress
	subq	#1,a2
EndCompress:
	move.l	a2,d1
	sub.l	a0,d1		;Nombre d'octet de la s‚quence
SequenceCompress:
	cmp.l	#130,d1
	ble.s	UneSequenceCompress
	sub.l	#130,d1
	move.b	#255,(a1)+
	move.b	d0,(a1)+
	bra.s	SequenceCompress
UneSequenceCompress:
	cmp.l	#2,d1
	ble.s	OutOfDomain		;Moins de 3 octets ininterressants
	add.l	#$80-3,d1
	move.b	d1,(a1)+
	move.b	d0,(a1)+
	move.l	a2,a0		;Adresse nouveau compactage
	bra	MainLoop
OutOfDomain:
	move.l	a2,a0
	sub.l	d1,a0
	bra	MainLoop

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

TextIntro:	dc.b	27,'EPackeur RLE',$a,$d
		dc.b	'Selectionnez votre fichier … compacter.',$a,$d,0
TextOK:		dc.b	27,'ECompactage RLE r‚ussi.',$a,$d,0
		dc.b	'Selectionnez le nom de la sauvegarde.',$a,$d,0
TextNO:		dc.b	27,'ECompactage RLE impossible.',$a,$d,0
TextSave:	dc.b	27,'EErreur de sauvegarde.',$a,$d,0
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
AdrPack:	ds.l	1
LenghtPack:	ds.l	1
		ds.b	8192
Pile:
File:
