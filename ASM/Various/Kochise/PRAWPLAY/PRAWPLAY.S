; /// DMA Packed RAW Sound Player V1.28 For ATARI Falcon030 And STe By KOSS ///

	SECTION	TEXT

Start_Prog	move.l	4(SP),A6		; Adresse de la BASEPAGE
	lea	$80(A6),A6		; Adresse de la COMMAND-TAIL
	move.b	(A6)+,D0		; Taille de la COMMAND-TAIL (ATTENTION : Format PASCAL)
	lea	RAW_Name,A5
	bne	Copy_RAW_Name		; Si la COMMAND-TAIL existe...
	move.b	#0,(A5)+		; Pas de COMMAND-TAIL
	clr.w	D0
	bra	Greetings		; On n'a plus rien … faire

Copy_RAW_Name	move.b	(A6)+,(A5)+		; Copie de la COMMAND-TAIL
	subq.b	#1,D0
	bne	Copy_RAW_Name
	clr.b	(A5)		; Mets un OCTET nul … la fin de la chaine (ATTENTION : Transformation au format C)
	move.l	-(A5),D0		; Les derniŠres lettres (.RAW en principe)
	cmpi.l	#".PRW",D0		; On v‚rifie … tout hasard
	bne	Exit		; A la prochaine...

Init_PRG_Mem	movea.l	4(SP),A6		; Adresse de la BASEPAGE
	move.l	$C(A6),D0		; Taille du SEGMENT TEXT
	add.l	$14(A6),D0		; Additionne la taille du SEGMENT DATA … D0
	add.l	$1C(A6),D0		; Additionne la taille du SEGMENT BSS … D0
	addi.l	#$100,D0		; Additionne la taille de la BASEPAGE … D0
	addi.l	#$400,D0		; Additionne la taille de la future PILE (Ici, 256 positions longues (1024 OCTETS))
	move.l	D0,D1		; Copie D0 dans D1 (Taille … r‚server)
	add.l	A6,D1		; Additionne l'adresse du d‚but du programme avec D1 (La taille … r‚server)
	andi.l	#-2,D1		; Rend D1 pair (Au cas o— il ne l'‚tait pas)
	move.l	SP,Old_Stack
	movea.l	D1,SP		; Installe l'adresse de fin du programme+place nouvelle PILE dans la PILE
	move.l	D0,-(SP)		; EmPILE la taille … reserver	\
	move.l	A6,-(SP)		; EmPILE l'adresse du programme |-> Rend le reste de la m‚moire au systŠme
	clr.w	-(SP)		; R‚serv‚                       |
	move.w	#$4A,-(SP)		; - M_SHRINK -                  |
	trap	#1		; *** GEMDOS ***                /
	lea	12(SP),SP
	tst	D0		; Si D0<>0, problŠme grave
	bne	Exit

Main	pea	Prog_Title
	move.w	#9,-(SP)		; - C_CONWS -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP

	bsr	Load_RAW_File

	move.l	Packed_Data,D0		; Si les donn‚es n'ont pas ‚t‚ charg‚es
	beq	Exit		; On sort (D0 de toute maniŠre … 0 dans ce cas)

	bsr	Ice_UnPack
	bsr	Play_RAW_Sound
	bsr	Free_Memory
	
Exit	move.w	D0,-(SP)
	move.w	#$4C,-(SP)		; - P_TERM -
	trap	#1		; *** GEMDOS ***

Greetings	pea	Prog_Title
	move.w	#9,-(SP)		; - C_CONWS -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP

	pea	Greets_To
	move.w	#9,-(SP)		; - C_CONWS -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP

	move.w	#7,-(SP)		; - C_RAWCIN -
	trap	#1		; *** GEMDOS ***
	addq.l	#2,SP

	clr.w	D0		; No Problem...
	
	bra	Exit

Load_RAW_File	pea	Load_Text
	move.w	#9,-(SP)		; - C_CONWS -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP

	clr.w	-(SP)
	pea	RAW_Name
	move.w	#$3D,-(SP)		; - F_OPEN -
	trap	#1		; *** GEMDOS ***
	addq.l	#8,SP
	move.w	D0,D7		; Handle
	
	move.w	#2,-(SP)		; Fin
	move.w	D0,-(SP)
	clr.l	-(SP)		; Fin du fichier
	move.w	#$42,-(SP)		; - F_SEEK -
	trap	#1		; *** GEMDOS ***
	lea	10(SP),SP
	move.l	D0,D6		; Taille

	clr.w	-(SP)		; D‚but
	move.w	D7,-(SP)
	clr.l	-(SP)		; D‚but du fichier
	move.w	#$42,-(SP)		; - F_SEEK -
	trap	#1		; *** GEMDOS ***
	lea	10(SP),SP

	clr.w	-(SP)		; ST-RAM
	move.l	D6,-(SP)		; Taille du fichier
	move.w	#$44,-(SP)		; - M_XALLOC -
	trap	#1		; *** GEMDOS ***
	addq.l	#8,SP
	tst.l	D0
	beq	Close_File
	
	move.l	D0,Packed_Data
	move.l	D0,-(SP)		; Adresse du fichier
	move.l	D6,-(SP)		; Taille du fichier
	move.w	D7,-(SP)		; Handle
	move.w	#$3F,-(SP)		; - F_READ -
	trap	#1		; *** GEMDOS ***
	lea	12(SP),SP
	
Close_File	move.w	D7,-(SP)
	move.w	#$3E,-(SP)		; - F_CLOSE -
	trap	#1		; *** GEMDOS ***
	addq.l	#4,SP
	RTS

Ice_UnPack	pea	UnPack_Text
	move.w	#9,-(SP)		; - C_CONWS -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP

	move.l	Packed_Data,A0
	movem.l	D0-A6,-(SP)
	bsr	Ice04		; Identificateur
	cmpi.l	#'Ice!',D0		; Compact‚?
	bne	Ice03		; Non, alors sort...
	bsr	Ice04		; Taille compact‚
	lea	-8(A0,D0.l),A5
	bsr	Ice04		; Taille d‚compact‚
	move.l	D0,(SP)
	move.l	D0,UnPacked_Size
	
	movem.l	D0/D2-A6,-(SP)
	
	clr.w	-(SP)		; ST-RAM
	move.l	D0,-(SP)		; Taille des donn‚es
	move.w	#$44,-(SP)		; - M_XALLOC -
	trap	#1		; *** GEMDOS ***
	addq.l	#8,SP
	move.l	D0,D1		; Car D0 d‚j… occup‚ par la taille d‚compact‚e
	
	movem.l	(SP)+,D0/D2-A6
	
	tst.l	D1
	beq	Ice03	
	move.l	D1,UnPacked_Data
	movea.l	D1,A1
	movea.l	D1,A4		; D‚but d‚compact‚
	movea.l	D1,A6
	adda.l	D0,A6		; Fin d‚compact‚
	movea.l	A6,A3
	move.b	-(A5),D7
	bsr	Ice06
Ice03	movem.l	(SP)+,D0-A6
	RTS

Ice04	moveq	#3,D1
Ice05	lsl.l	#8,D0
	move.b	(A0)+,D0
	dbra	D1,Ice05
	RTS

Ice06	bsr.s	Ice0A
	bcc.s	Ice09
	moveq	#0,D1
	bsr.s	Ice0A
	bcc.s	Ice08
	lea	Ice17(pc),A1
	moveq	#4,D3
Ice07	move.l	-(A1),D0
	bsr.s	Ice0C
	swap	D0
	cmp.w	D0,D1
	dbne	D3,Ice07
	add.l	20(A1),D1
Ice08	move.b	-(A5),-(A6)
	dbra	D1,Ice08
Ice09	cmpa.l	A4,A6
	bgt.s	Ice0F
	RTS

Ice0A	add.b	D7,D7
	bne.s	Ice0B
	move.b	-(A5),D7
	addx.b	D7,D7
Ice0B	RTS

Ice0C	moveq	#0,D1
Ice0D	add.b	D7,D7
	bne.s	Ice0E
	move.b	-(A5),D7
	addx.b	D7,D7
Ice0E	addx.w	D1,D1
	dbra	D0,Ice0D
	RTS

Ice0F	lea	Ice18(pc),A1
	moveq	#3,D2
Ice10	bsr.s	Ice0A
	dbcc	D2,Ice10
	moveq	#0,D4
	moveq	#0,D1
	move.b	1(A1,D2.w),D0
	ext.w	D0
	bmi.s	Ice11
	bsr.s	Ice0C
Ice11	move.b	6(A1,D2.w),D4
	add.w	D1,D4
	beq.s	Ice13
	lea	Ice19(pc),A1
	moveq	#1,D2
Ice12	bsr.s	Ice0A
	dbcc	D2,Ice12
	moveq	#0,D1
	move.b	1(A1,D2.w),D0
	ext.w	D0
	bsr.s	Ice0C
	add.w	D2,D2
	add.w	6(A1,D2.w),D1
	bpl.s	Ice15
	sub.w	D4,D1
	bra.s	Ice15
Ice13	moveq	#0,D1
	moveq	#5,D0
	moveq	#-1,D2
	bsr.s	Ice0A
	bcc.s	Ice14
	moveq	#8,D0
	moveq	#$3f,D2
Ice14	bsr.s	Ice0C
	add.w	D2,D1
Ice15	lea	2(A6,D4.w),A1
	adda.w	D1,A1
	move.b	-(A1),-(A6)
Ice16	move.b	-(A1),-(A6)
	dbra	D4,Ice16
	bra	Ice06
	DC.B $7f,$ff,$00,$0e,$00,$ff,$00,$07
	DC.B $00,$07,$00,$02,$00,$03,$00,$01
	DC.B $00,$03,$00,$01
Ice17	DC.B $00,$00,$01,$0d,$00,$00,$00,$0e
	DC.B $00,$00,$00,$07,$00,$00,$00,$04
	DC.B $00,$00,$00,$01
Ice18	DC.B $09,$01,$00,$ff,$ff,$08,$04,$02
	DC.B $01,$00
Ice19	DC.B $0b,$04,$07,$00,$01,$1f,$ff,$ff
	DC.B $00,$1f

Play_RAW_Sound	pea	Play_Text
	move.w	#9,-(SP)		; - C_CONWS -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP
	
	clr.l	-(SP)
	move.w	#$20,-(SP)		; - SUPER -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP

	move.l	UnPacked_Data,D0
	move.l	UnPacked_Size,D1
	add.l	D0,D1
	addq.l	#1,D1
	andi.l	#-2,D1
	swap	D0
	swap	D1
	move.b	D0,$FFFF8903.w
	move.b	D1,$FFFF890F.w
	rol.l	#8,D0
	rol.l	#8,D1
	move.b	D0,$FFFF8905.w
	move.b	D1,$FFFF8911.w
	rol.l	#8,D0
	rol.l	#8,D1
	move.b	D0,$FFFF8907.w
	move.b	D1,$FFFF8913.w

	move.w	#%10000010,$FFFF8920.w	; Init. DMA
	move.w	#1,$FFFF8900.w		; Run DMA

TestDMA	tst.w	$FFFF8900.w
	nop
	BNE	TestDMA


	clr.l	-(SP)
	move.w	#$20,-(SP)		; - SUPER -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP

	RTS
	
Free_Memory	pea	Free_Text
	move.w	#9,-(SP)		; - C_CONWS -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP
	
	move.l	Packed_Data,-(SP)
	move.w	#$49,-(SP)		; - M_FREE -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP
	tst.w	D0
	bne	Free_Escape
	
	move.l	UnPacked_Data,-(SP)
	move.w	#$49,-(SP)		; - M_FREE -
	trap	#1		; *** GEMDOS ***
	addq.l	#6,SP
	tst.w	D0
	bne	Free_Escape

	clr.w	D0		; No error
	
Free_Escape	RTS

	SECTION	DATA

RAW_Name	ds.b	256
Old_Stack	ds.l	1
Packed_Data	ds.l	1
UnPacked_Data	ds.l	1
UnPacked_Size	ds.l	1

Prog_Title	dc.b	27,"E",27,"p DMA Packed RAW Sound Player V1.28 For ATARI Falcon030 And STe By KOSS ",27,"q",13,10,13,10,0
Load_Text	dc.b	"Loading Packed RAW File...",13,10,0
UnPack_Text	dc.b	"Unpacking RAW Data...",13,10,0
Play_Text	dc.b	"Play through DMA Channel the RAW Sound...",13,10,0
Free_Text	dc.b	"Free Memory from Previous Allocation...",13,10,0
Greets_To	dc.b	"Any File Draged...",13,10,13,10,"Let Me Put A Little Wavzez On Your Screen, Pleez...",13,10
	dc.b	"Thanks To Any People Using An ATARI, and Specialy (Wo)Men Who Are Making",13,10
	dc.b	"ATARI Survive Despite Their Death! Thiz Case Is Including Mags Of",13,10
	dc.b	"All Countries Of the World.",13,10
	dc.b	"Here A Call For ANY People Having Informations About Developpement",13,10
	dc.b	"On ATARI : Share Your Knowledge With ANY People Who Is Needing It,",13,10
	dc.b	"'Coz It's With Code That ATARI Will Stay Alive. So Many (Wo)Men Have",13,10
	dc.b	"Good Competence For Doing A Great Thing, But They Don't Know How To Do!",13,10,13,10
	dc.b	" Thiz Code Is ARTE-Ware",13,10,13,10
	dc.b	"       ",27,"p> Press ANY Keys... <",27,"q",13,10,0
	
	SECTION	BSS