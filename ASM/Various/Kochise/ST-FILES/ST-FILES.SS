; /// .ST Files -> Disk Converter - KOSS 1999 ///

	comment	HEAD=7

	SECTION	TEXT

	move.l	4(SP),A6		; Adresse de la BASEPAGE
	lea	$80(A6),A6	; Adresse de la COMMAND-TAIL
	move.b	(A6)+,D0	; Taille de la COMMAND-TAIL (ATTENTION : Format PASCAL)
	lea	STFileName,A5
	BNE	Copy_ST_Name	; Si la COMMAND-TAIL existe...
	move.b	#0,(A5)+	; Pas de COMMAND-TAIL
	clr.w	D0
	BRA	Greetings	; On n'a plus rien … faire

Copy_ST_Name	move.b	(A6)+,(A5)+	; Copie de la COMMAND-TAIL
	subq.b	#1,D0
	BNE	Copy_ST_Name
	
	clr.b	(A5)	; Mets un OCTET nul … la fin de la chaine (ATTENTION : Transformation au format C)
	move.l	-(A5),D0	; Les derniŠres lettres (.ST en principe)
	andi.l	#$FFFFFF,D0
	cmpi.l	#".ST",D0	; On v‚rifie … tout hasard
	BNE	Exit	; A la prochaine...

	movea.l	(4,SP),A6	; Adresse de la BASEPAGE
	move.l	($C,A6),D0	; Taille du SEGMENT TEXT
	add.l	($14,A6),D0	; Additionne la taille du SEGMENT DATA … D0
	add.l	($1C,A6),D0	; Additionne la taille du SEGMENT BSS … D0
	addi.l	#$100,D0	; Additionne la taille de la BASEPAGE … D0
	addi.l	#$400,D0	; Additionne la taille de la future PILE (Ici, 256 positions longues (1024 OCTETS))
	move.l	D0,D1	; Copie D0 dans D1 (Taille … r‚server)
	move.l	D0,D7
	add.l	A6,D1	; Additionne l'adresse du d‚but du programme avec D1 (La taille … r‚server)
	andi.l	#-2,D1	; Rend D1 pair (Au cas o— il ne l'‚tait pas)
	subq.l	#8,D1	; Garde de la place pour l'adresse de la BASEPAGE
	move.l	(4,SP),D2	; Sauvegarde l'adresse de la BASEPAGE
	movea.l	D1,SP	; Installe l'adresse de fin du programme+place nouvelle PILE dans la PILE
	move.l	D2,(4,SP)	; R‚installe l'adresse de la BASEPAGE
	move.l	D0,-(SP)	; EmPILE la taille … r‚server
	move.l	A6,-(SP)	; EmPILE l'adresse du programme
	clr.w	-(SP)	; R‚serv‚
	move.w	#$4A,-(SP)	; - M_SHRINK -
	trap	#1	; *** GEMDOS ***
	lea	(12,SP),SP

	BSR	PrintTitle
;	BSR	TabInfo
	
	pea	STFileLoading
	move.w	#9,-(SP)	; - C_CONWS -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP

	BSR	LoadSTFile
	BSR	GetFileParams
	
	pea	STFileWriting
	move.w	#9,-(SP)	; - C_CONWS -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP
	
	BSR	WriteSTFile
	BSR	WriteDone
	BSR	WaitKey

Exit	move.w	#$4C,-(SP)	; - P_TERM -
	trap	#1	; *** GEMDOS ***
	
Greetings	BSR	PrintTitle

	pea	STFileGreetings
	move.w	#9,-(SP)	; - C_CONWS -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP

	BSR	WaitKey
	
	clr.w	-(SP)	; - P_TERM0 -
	trap	#1	; *** GEMDOS ***	

PrintTitle	pea	STFileTitle
	move.w	#9,-(SP)	; - C_CONWS -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP
	
	RTS	

WaitKey	move.w	#7,-(SP)	; - C_RAWCIN -
	trap	#1	; *** GEMDOS ***
	addq.l	#2,SP
	
	RTS
	
;TabInfo	lea	STFileWriteInfo,A0
;	moveq.w	#1,D0
;	move.w	#15,D1
;	
;TabLoop	
;	
;
;	RTS
	
LoadSTFile	clr.w	-(SP)
	pea	STFileName
	move.w	#$3D,-(SP)	; - F_OPEN -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP
	
	move.w	D0,D7
	
	move.w	#2,-(SP)
	move.w	D0,-(SP)
	clr.l	-(SP)
	move.w	#$42,-(SP)	; - F_SEEK -
	trap	#1	; *** GEMDOS ***
	lea	(10,SP),SP
	
	move.l	D0,D6
	move.l	D0,FSize
	
	clr.w	-(SP)
	move.w	D7,-(SP)
	clr.l	-(SP)
	move.w	#$42,-(SP)	; - F_SEEK -
	trap	#1	; *** GEMDOS ***
	lea	(10,SP),SP

	move.w	#3,-(SP)
	move.l	D6,-(SP)
	move.w	#$44,-(SP)	; - M_XALLOC -
	trap	#1	; *** GEMDOS ***
	addq.l	#8,SP
	
	move.l	D0,MemoryImage
	
	move.l	D0,-(SP)
	move.l	D6,-(SP)	
	move.w	D7,-(SP)
	move.w	#$3F,-(SP)	; - F_READ -
	trap	#1	; *** GEMDOS ***
	lea	(12,SP),SP
	
	move.w	D7,-(SP)
	move.w	#$3E,-(SP)	; - F_CLOSE -
	trap	#1	; *** GEMDOS ***
	addq.l	#4,SP

	RTS

GetFileParams	move.w	([MemoryImage],26),D0
	ror.w	#8,D0
	move.w	D0,FSide
	
	move.w	([MemoryImage],24),D0
	ror.w	#8,D0
	move.w	D0,FSector
	
	clr.l	D0
	move.w	([MemoryImage],11),D0	; BytePerSector
	ror.w	#8,D0
	clr.l	D1
	move.w	FSector,D1
	mulu.l	D1,D0
	move.w	FSide,D1
	mulu.l	D1,D0
	
	move.l	FSize,D1
	divu.l	D0,D1
	
	move.w	D1,FTrack
	
	RTS
	
WriteSTFile	move.w	FTrack,D7
	subq.w	#1,D7
	clr.w	D6	; Track
	clr.w	D5	; Side
	move.w	FSide,D4
	subq.w	#1,D4
	move.l	MemoryImage,A3
	clr.l	D3
	move.w	FSector,D3
	clr.l	D0
	move.w	([MemoryImage],11),D0	; BytePerSector
	ror.w	#8,D0
	mulu.l	D0,D3

WriteTrackLoop	move.w	FSector,-(SP)	; NSector
	move.w	D5,-(SP)	; Side
	move.w	D6,-(SP)	; Track
	move.w	#1,-(SP)	; 1st Sector	
	clr.w	-(SP)	; A:
	clr.l	-(SP)	; Unused
	move.l	A3,-(SP)	; Buffer
	move.w	#9,-(SP)	; - FLOPWR -
	trap	#14	; *** XBIOS ***
	lea	(20,SP),SP

	adda.l	D3,A3

	addq.w	#1,D5
	cmp.w	D4,D5
	BLE	WriteTrackLoop

	clr.w	D5
	addq.w	#1,D6
	DBF	D7,WriteTrackLoop

	RTS

;InfoUpdate
;
;	RTS

WriteDone	pea	STFileWriteDone
	move.w	#9,-(SP)	; - C_CONWS -
	trap	#1	; *** GEMDOS ***
	addq.l	#6,SP
	
	RTS	

	SECTION	DATA
	
STFileTitle	dc.b	27,"E",27,"p"
	dc.b	"/// .ST Files -> Disk Converter - KOSS 1999 ///"
	dc.b	27,"q",13,10,0

STFileGreetings	dc.b	13,10
	dc.b	"  Hello Ev'ryBody, how're you nowadays?",13,10
	dc.b	"This little piece of code just writes",13,10
	dc.b	".ST files (from PaCifiST) to Floppy.",13,10
	dc.b	"Useful to play with games in DiskImgs.",13,10
	dc.b	"Work on Falcon030, and pleased with",13,10
	dc.b	"UltraHiSize Floppy (>562To) 8) ...",13,10
	dc.b	13,10
	dc.b	"  Just grab the .ST file on this Prog",13,10
	dc.b	"in order to write it on a Floppy",13,10,0

STFileLoading	dc.b	"  Loading .ST File...",13,10,0
STFileWriting	dc.b	"  Etching Floppy...",13,10,0

STFileWriteInfo	dc.b	13,10
	dc.b	"FileSize    :      *1111 Sectors",13,10
	dc.b	"                   *2222 Tracks",13,10
	dc.b	"                   *3333 Sides",13,10
	dc.b	"              *444444444 Bytes",13,10
	dc.b	"Writing     : Sector *5555",13,10
	dc.b	"               Track *6666",13,10
	dc.b	"                Side *7777",13,10
	dc.b	"               Bytes *888888888",13,10
	dc.b	"Average     : *9999%",13,10
	dc.b	"TimeElapsed : *AAAA Hours",13,10
	dc.b	"              *BBBB Minutes",13,10
	dc.b	"              *CCCC Seconds",13,10
	dc.b	"TimeToWait  : *DDDD Hours",13,10
	dc.b	"              *EEEE Minutes",13,10
	dc.b	"              *FFFF Seconds",13,10
	dc.b	13,10,0

STFileWriteDone	dc.b	"  OK, Floppy Etched...",0	
	
	SECTION	BSS
	
FSector	ds.w	1
FTrack	ds.w	1
FSide	ds.w	1
FSize	ds.l	1
WSector	ds.w	1
WTrack	ds.w	1
WSide	ds.w	1
WSize	ds.w	1
WAverage	ds.w	1
TEHour	ds.w	1
TEMin	ds.w	1
TESec	ds.w	1
TWHour	ds.w	1
TWMin	ds.w	1
TWSec	ds.w	1

STFileName	ds.b	80
MemoryImage	ds.l	1	