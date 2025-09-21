
	section	text

	include	'octalyse.i'
	include	'gemlib.i'

;
;	OBS! F†r INTE anv„nda blittern n†gon annanstans „n i VBLen!!!!!!!!!
; Se vbl: f”r lite mera info!!!
;

OPTOFF	EQU	33-1	; Antal menyval i optionsmenyn n„r Termodyn „r AV
OPTON	EQU	19-1	; Antal menyval i optionsmenyn n„r Termodyn „r P
STATIONAR	EQU	53-1	; Antal menyer n„r sampleditorn inte „r p†

magicstart:
	bra	startoff
	dc.l	'0.96'		; Version av Octan
	dc.l	$12345678	; Speciellt nummer f”r vaje registrerare
	dc.l	regname+4-magicstart	; Offset till namn/adress/stad
basepage:
	dc.l	0
	CNOP	0,4
ordna_till_editorer:
	moveq	#0,d1
k”r1:	addq.w	#1,d1
	move.w	d1,d2
	mulu	#960,d2
	move.w	d2,(a0)+
	cmp.w	d1,d0
	bgt.s	k”r1
k”r2:	cmp.w	#-1,(a0)
	beq.s	avbrytk”r2
	move.w	d2,(a0)+
	bra.s	k”r2
avbrytk”r2:
	rts

startoff:
	move.l	4(a7),basepage	; get address of base page in a1

	move.l	a7,a5
	move.l	#theendofstack,a7
	move.l	4(a5),a5
	move.l	$2c(a5),env
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1			; Registrera programet s† att
	lea	12(sp),sp		; vi kan beg„ra minne...

	pea	testaomsteellermegasteellertt
	move.w	#38,-(sp)
	trap	#14		; Testa om det „r en STE/Mega STE/TT
	addq.l	#6,sp		; som anv„nds

	tst.w	falkrun
	bmi.s	.nofalk

	move.w	#-1,run60Hz

	move.w	#-1,-(sp)	; Get Falcon Rez BEFORE changing vector.
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp
	move.w	d0,falkrez
	and.w	#%000110000,d0
	or.w	#%010100010,d0	
	move.w	d0,InOctaFalkrez	; Uppl”sning f”r Falcon i Octan (VGA/NTSC/RGB).

	move.w	falkrez,d0
	btst	#4,d0
	bne.s	.its_PAL	; well, VGA actually, but we don't want the dialogbox anyway...

	btst	#5,d0
	bne.s	.its_PAL

	clr.w	run60Hz		; vi k”r i NTSC-l„ge.

.its_PAL
	move.w	#1,-(sp)	; STE-soundemulering p† (f”r TOS 4.1)
	move.w	#0,-(sp)
	move.w	#$87,-(sp)
	trap	#14
	addq.w	#6,sp

	move.w	#1,-(sp)
	clr.l	-(sp)
	move.w	#8,-(sp)
	clr.w	-(sp)
	move.w	#$8b,-(sp)
	trap	#14
	lea	$c(sp),sp



.nofalk:

	tst.w	run60Hz
	bne	rakar”r
	lea	”ver50Hzp†enRGBare,a1
	moveq	#1,d1			; Vi har en konstig svepfrekvens!
	jsr	form_alert
	cmp.w	#3,d0
	beq	direktur
	cmp.w	#1,d0
	beq	rakar”r
	and.w	#%11011111,InOctaFalkrez
	move.w	#1,runwithtimerA
	move.w	#1,hblisallreadyused	; Anv„nd 60 Hz
	move.b	#199,datainitto6850+5	; St„ll in musen till minst maxY
	lea	hurmycketaddera+32,a0
	moveq	#31,d0		; Upp till 31
	bsr	ordna_till_editorer
	lea	hurmycketaddera2+16,a0
	moveq	#49,d0		; Upp till 49
	bsr	ordna_till_editorer
	tst.w	falkrun
	beq.s	rakar”r
	lea	useborderornot,a1
	moveq	#1,d1			; Vi har en konstig svepfrekvens!
	jsr	form_alert
	cmp.w	#1,d0
	bne.s	rakar”r348
	clr.w	hblisallreadyused	; Ta bort bordern
	move.b	#216,datainitto6850+5	; St„ll in musen till l„gre maxY
	lea	hurmycketaddera+32,a0
	clr.l	(a0)+
	moveq	#28,d0		; Upp till 28
	bsr	ordna_till_editorer
	lea	hurmycketaddera2+16,a0
	clr.l	(a0)+
	moveq	#45,d0		; Upp till 45
	bsr	ordna_till_editorer
rakar”r348:
	move.w	#2,to601+2
	move.w	#0,to501+2
	move.w	#2,to602+2
	move.w	#0,to502+2
	move.w	#2,to603+2
	move.w	#0,to503+2
rakar”r:
	tst.w	VGArun
	bne.s	rakar”rmedVGAoxo
	move.w	#1,runwithtimerA
	move.w	#1,hblisallreadyused
rakar”rmedVGAoxo:

	jsr	appl_init
	tst.w	d0
	bmi	direktur

	tst.w	MiNTispresent		; Om MiNT, ers„tt texten med
	beq.s	mintfinnsintealls	; v†r egen i menyn
	move.l	d0,d1
	lea	MiNTmenutext,a1
	jsr	menu_register
mintfinnsintealls:

	move.w	#4,-(sp)
	trap	#14
	addq.w	#2,sp
	tst.w	falkrun
	beq.s	r„ttstuppl
	tst.w	d0
	beq.s	r„ttstuppl
	cmp.w	#1,d0
	beq.s	r„ttstuppl
	lea	konstiguppl”sning,a1
	moveq	#1,d1			; Vi har en konstig uppl”sning!
	jsr	form_alert
	cmp.w	#1,d0
	beq.s	r„ttstuppl
	jsr	appl_exit
	clr.w	-(sp)
	trap	#1
r„ttstuppl:
	jsr	makebusy

	clr.w	kanejg†uttillGEM
	move.w	#$19,-(sp)
	trap	#1
	addq.l	#2,sp		; Vilken „r aktiv drajv?
	move.w	d0,d1
	add.b	#'A',d0
	move.b	d0,path
	move.b	d0,modpath
	move.b	d0,delpath
	move.b	d0,blkpath
	move.b	d0,terpath
	move.b	d0,runpath
	move.b	d0,saveoptionspath
	move.b	#':',saveoptionspath+1
	addq.w	#1,d1
	move.w	d1,-(sp)
	pea	saveoptionspath+2	; Ta reda p† aktuell path till
	move.w	#$47,-(sp)		; octalysern
	trap	#1
	addq.w	#8,sp
	lea	saveoptionspath,a0
letaefterennollaipathen:
	tst.b	(a0)
	beq.s	nollan„rh„r
	addq.w	#1,a0
	bra.s	letaefterennollaipathen
nollan„rh„r:
	move.b	#'\',(a0)+
	move.b	#'O',(a0)+
	move.b	#'C',(a0)+
	move.b	#'T',(a0)+
	move.b	#'A',(a0)+
	move.b	#'L',(a0)+
	move.b	#'Y',(a0)+
	move.b	#'S',(a0)+
	move.b	#'E',(a0)+
	move.b	#'.',(a0)+
	move.b	#'I',(a0)+
	move.b	#'N',(a0)+
	move.b	#'F',(a0)+
	clr.b	(a0)

	bra	ignoreraregdatan		; ()()()

	move.l	a0,dummen

	move.l	dummen,a0
	move.b	#'G',-(a0)
	move.b	#'R',-(a0)
	move.b	#'P',-(a0)

	clr.w	-(sp)
	pea	saveoptionspath
	move.w	#$3d,-(sp)
	trap	#1
	addq.w	#8,sp
	tst.w	d0
	bmi	interegistrerad
	move.w	d0,handle

	move.w	#2,-(sp)
	move.w	handle,-(sp)
	move.l	#-(39*19+4),-(sp)
	move.w	#$42,-(sp)
	trap	#1			; Leta fram slutet av Octan
	lea	10(sp),sp

	pea	helpscreen9
	move.l	#39*19+4,-(sp)
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1			; L„s upp registreringsdatan
	lea	12(sp),sp

	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1			; St„ng filen
	addq.w	#4,sp

	move.w	#39*19-1,d0
	moveq	#0,d1
	moveq	#0,d3
	lea	helpscreen9,a0
eora:	eor.b	#42,(a0)		; "Skrapa" fram reg.data
	move.b	(a0)+,d3
	add.l	d3,d1
	dbra	d0,eora

	move.b	mm,d2
	lsl.l	#8,d2
	move.b	mm+1,d2
	lsl.l	#8,d2
	move.b	mm+2,d2
	lsl.l	#8,d2
	move.b	mm+3,d2
	cmp.l	d1,d2
	bne	interegistrerad

	move.l	dummen,a0
	move.b	#'F',-(a0)
	move.b	#'N',-(a0)
	move.b	#'I',-(a0)
ignoreraregdatan:

	clr.w	-(sp)
	pea	saveoptionspath
	move.w	#$3d,-(sp)
	trap	#1			; ™ppna options-filen
	addq.l	#8,sp
	tst.l	d0
	bmi.s	kanej”ppnaoptionsfilen
	move.w	d0,handle
	lea	termtonebuff,a0		; L„s .INFen
	move.l	#888,d0
	bsr	loadthisblock
	tst.l	d0
	bmi.s	kanej”ppnaoptionsfilen
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1			; St„ng fil
	addq.l	#4,sp
	move.w	#1,optionsloaded
	lea	termtonebuff,a0
	move.l	740(a0),MainMemLength
	move.w	738(a0),maxpatterns
kanej”ppnaoptionsfilen:
	lea	filename,a1
	jsr	rsrc_load		; Ladda in RSCfilen
	tst.w	d0
	bne.s	okvihittadeRSCfilen
	lea	notfoundstring,a1
	moveq	#1,d1			; Vi hittade inte filen, avsluta
	jsr	form_alert
	move.w	#1,kanejg†uttillGEM
	bra	inteinstallerapekaresomejfinns
okvihittadeRSCfilen:
	moveq	#0,d1
	moveq	#MENU,d2
	lea	menupointer,a1
	jsr	rsrc_gaddr		; F† reda p† adressen till MENU
	moveq	#0,d1
	moveq	#INFORMA,d2
	lea	infopointer,a1
	jsr	rsrc_gaddr		; F† reda p† adressen till INFORMA
	moveq	#0,d1
	moveq	#MENFORM,d2
	lea	hj„lpmen,a1
	jsr	rsrc_gaddr		; F† reda p† adressen till MENFORM
	moveq	#0,d1
	moveq	#EXFORM,d2
	lea	hj„lpexec,a1
	jsr	rsrc_gaddr		; F† reda p† adressen till EXFORM
	moveq	#0,d1
	moveq	#SHELLFOR,d2
	lea	hj„lpshelling,a1
	jsr	rsrc_gaddr		; F† reda p† adressen till SHELLFOR
	moveq	#0,d1
	moveq	#WINDOWFO,d2
	lea	window_form,a1
	jsr	rsrc_gaddr		; F† reda p† adressen till WINDOWFO
	moveq	#0,d1
	moveq	#COMMAND,d2
	lea	command_form,a1
	jsr	rsrc_gaddr		; F† reda p† adressen till COMMAND
	moveq	#0,d1
	moveq	#RUNNAMEF,d2
	lea	nametorun,a1
	jsr	rsrc_gaddr		; F† reda p† adressen till NAMERUNF
	moveq	#0,d1
	moveq	#DESKTOP,d2
	lea	desktopen,a1
	jsr	rsrc_gaddr		; F† reda p† adressen till DESKTOP
	moveq	#5,d1
	moveq	#QUITARE,d2
	lea	quitalert,a1
	jsr	rsrc_gaddr		; F† reda p† adressen till QUITARE
	moveq	#5,d1
	moveq	#NOSHELL,d2
	lea	nonoshell,a1
	jsr	rsrc_gaddr		; F† reda p† adressen till NOSHELL
	jsr	centerup_the_helpmenu
	move.l	command_form,a0
	move.w	#COMLINE,d0
	mulu	#SIZE_OBJECT,d0
	move.l	OB_SPEC(a0,d0.w),a1	; H„mta pekare till kommandlinjen
	move.l	TE_PTEXT(a1),commandline
	move.l	TE_PTEXT(a1),a2		; Ingen kommandlinje i starten
	clr.b	(a2)
	move.l	infopointer,a0
	move.w	#NAMEINFO,d0
	mulu	#SIZE_OBJECT,d0
	move.l	OB_SPEC(a0,d0.w),a1	; H„mta pekare till regnamnet i infoformen
	move.l	TE_PTEXT(a1),a2		; Kopiera ”ver regnamnet
	lea 	regname+4,a1
	jsr	loopaindata
	move.l	window_form,a0
	move.w	#NAMEWIND,d0
	mulu	#SIZE_OBJECT,d0
	move.l	OB_SPEC(a0,d0.w),a1	; H„mta pekare till regnamnet i windowformen
	move.l	TE_PTEXT(a1),a2		; Kopiera ”ver regnamnet
	lea 	regname+4,a1
	jsr	loopaindata
	add.l	#SIZE_OBJECT,d0
	move.l	OB_SPEC(a0,d0.w),a1	; H„mta pekare till regnamnet i windowformen
	move.l	TE_PTEXT(a1),a2		; Kopiera ”ver regnamnet
	lea 	regname+4+39,a1
	jsr	loopaindata
	add.l	#SIZE_OBJECT,d0
	move.l	OB_SPEC(a0,d0.w),a1	; H„mta pekare till regnamnet i windowformen
	move.l	TE_PTEXT(a1),a2		; Kopiera ”ver regnamnet
	lea 	regname+4+39+39,a1
	jsr	loopaindata
	jsr	setmyowndesktop
	jsr	forceredrawofGEMscreen
	tst.w	optionsloaded
	beq.s	inteinstallerapekaresomejfinns
	btst.b	#0,termtonebuff+674
	beq.s	inteinstallerapekaresomejfinns
	not.w	CallEvntTimerAsOftenAsPossible
	move.l	menupointer,a1
	move.w	#SHARE,d1
	moveq	#1,d2
	jsr	menu_icheck		; S„tt checked
inteinstallerapekaresomejfinns:

	move.l	#starter,bildminne
	move.l	bildminne,oldcursorpek
	add.l	#168*108+32,oldcursorpek
	move.l	#fontena,font
	move.l	#grafixs,d0
	addq.l	#4,d0
	move.l	d0,removeer


	move.l	MainMemLength,d0	; Antal bytes som ”nskas
	jsr	setupinternalmemhandler	; S„tt upp den interna minneshanteraren
	bmi	ingetminnekvar

	move.w	maxpatterns,d0
	mulu	#4*8*64,d0
	lea	patterns,a0		; Beg„r minne f”r alla
	moveq	#0,d1			; patterna av den interna
	jsr	malloc			; minneshanteraren
	beq	ingetminnekvar

	lea	fastapositioner+2+8*(5*2),a0
	move.w	#STATIONAR+8-8,d0
„ndrapositionerna1:
	add.w	#16,(a0)
	add.w	#16,4(a0)
	lea	10(a0),a0
	dbra	d0,„ndrapositionerna1

	lea	memkoors+2,a0
	move.w	#21-1,d0
„ndrapositionerna12:
	add.w	#16,(a0)
	add.w	#16,4(a0)
	lea	10(a0),a0
	dbra	d0,„ndrapositionerna12

	lea	makekoors,a0
	move.w	(a0)+,d0
„ndrapositionerna1442:
	add.w	#16,(a0)
	add.w	#16,4(a0)
	lea	10(a0),a0
	dbra	d0,„ndrapositionerna1442

	lea	huvudlospos+2,a0
	moveq	#27-1,d0
„ndrapositionerna2:
	add.w	#16,(a0)
	add.w	#16,4(a0)
	lea	10(a0),a0
	dbra	d0,„ndrapositionerna2

	lea	infokoors+2,a0
	moveq	#21-1,d0
„ndrapositionerna3:
	add.w	#16,(a0)
	add.w	#16,4(a0)
	lea	10(a0),a0
	dbra	d0,„ndrapositionerna3

	lea	editkoors+2,a0
	moveq	#24-1,d0
„ndrapositionerna4:
	add.w	#16,(a0)
	add.w	#16,4(a0)
	lea	10(a0),a0
	dbra	d0,„ndrapositionerna4

	lea	diskkoors+2,a0
	moveq	#25-1,d0
„ndrapositionerna5:
	add.w	#16,(a0)
	add.w	#16,4(a0)
	lea	10(a0),a0
	dbra	d0,„ndrapositionerna5

	lea	optionskoors+2,a0
	moveq	#OPTOFF,d0
„ndrapositionerna6:
	add.w	#16,(a0)
	add.w	#16,4(a0)
	lea	10(a0),a0
	dbra	d0,„ndrapositionerna6

	lea	numpattskoors+2,a0
	moveq	#4-1,d0
„ndrapositionerna7:
	add.w	#16,(a0)
	add.w	#16,4(a0)
	lea	10(a0),a0
	dbra	d0,„ndrapositionerna7

	lea	termodykoors+2,a0
	moveq	#12-1,d0
„ndrapositionerna8:
	add.w	#16,(a0)
	add.w	#16,4(a0)
	lea	10(a0),a0
	dbra	d0,„ndrapositionerna8

	lea	selectshowpattkoors+2,a0
	moveq	#3-1,d0
„ndrapositionerna9:
	add.w	#16,(a0)
	add.w	#16,4(a0)
	lea	10(a0),a0
	dbra	d0,„ndrapositionerna9

	lea	dummy,a0
	move.w	#1000-1,d0
rensadentommasamplingen:
	clr.l	(a0)+
	dbra	d0,rensadentommasamplingen

	lea	taltabell2,a5		; Pekare till taltabell
	move.l	(a5),a5 		; Fixa till talens invers
	moveq	#(6*16)-1,d0
llalfk: not.b	(a5)+
	dbra	d0,llalfk

	lea	numberfont3+1,a5	; Pekare till taltabell
	move.w	#(16*16/2)-1,d0
llalfk2:not.b	(a5)+
	addq.l	#1,a5
	dbra	d0,llalfk2

	lea	numberfont4+1,a5	; Pekare till taltabell
	move.w	#(16*16/2)-1,d0
llalfk3:not.b	(a5)+
	addq.l	#1,a5
	dbra	d0,llalfk3



	lea	tabelldata2,a0
	move.w	#1024-1,d0		; Fixa tabellen s† att den pekar
skrivforstnone2:			; p† en massa none
	clr.l	(a0)+
	dbra	d0,skrivforstnone2
	lea	tonisar,a5
	lea	pekaretillvilkenton,a0
	move.w	#1024-1,d0		; Fixa tabellen s† att den pekar
skrivforstnone3:			; p† en massa none
	move.l	a5,(a0)+
	dbra	d0,skrivforstnone3
	lea	oktasar,a5
	lea	pekaretillvilkenoktav,a0
	move.w	#1024-1,d0		; Fixa tabellen s† att den pekar
skrivforstnone4:			; p† en massa none
	move.l	a5,(a0)+
	dbra	d0,skrivforstnone4


	lea	tabelldata2,a0
	move.w	#24,a5
	lea	periods,a2		; Skriv pekare till tabellen
	moveq	#36-1,d0		; ”ver tonpekare
skrivutpekaretilltabellen:
	move.w	(a2)+,d1
	and.w	#%1111111111111100,d1
	move.l	a5,0(a0,d1.w)
	lea	24(a5),a5
	dbra	d0,skrivutpekaretilltabellen

	lea	pekaretillvilkenton,a0
	lea	tonisar+6,a5
	lea	periods,a2		; Skriv pekare till tabellen
	moveq	#36-1,d0		; ”ver tonpekare
skrivutpekaretilltabellen2:
	move.w	(a2)+,d1
	and.w	#%1111111111111100,d1
	move.l	a5,0(a0,d1.w)
	addq.w	#6,a5
	dbra	d0,skrivutpekaretilltabellen2

	lea	pekaretillvilkenoktav,a0
	lea	oktasar+12,a5
	lea	periods,a2		; Skriv pekare till tabellen
	moveq	#36-1,d0		; ”ver tonpekare
skrivutpekaretilltabellen3:
	move.w	(a2)+,d1
	and.w	#%1111111111111100,d1
	move.l	a5,0(a0,d1.w)
	lea	12(a5),a5
	dbra	d0,skrivutpekaretilltabellen3



	lea	numberfont2,a0		; S„tt upp en talbuffer
	lea	tolkednumbers,a1
	lea	tolkedbuffer,a2
	moveq	#0,d0
	move.w	#255,d7
loopauttalentillbuffern:
	move.l	a1,(a2)+
	moveq	#0,d1
	move.w	d0,d1
	and.w	#$F0,d1
	lsr.w	#4,d1
	move.l	a0,a3
	mulu	#6,d1
	add.l	d1,a3
	move.l	a0,a4
	move.w	d0,d2
	and.w	#$F,d2
	mulu	#6,d2
	add.l	d2,a4
	move.b	(a3)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a3)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a3)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a3)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a3)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a3)+,(a1)+
	move.b	(a4)+,(a1)+
	addq.l	#1,d0
	dbra	d7,loopauttalentillbuffern


	lea	superfastfinetune,a0
	moveq	#128-1,d0
	moveq	#0,d1		; Rensa buffern
rensasuperfastfinetune:
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbra	d0,rensasuperfastfinetune

	lea	superfastfinetune,a0
	moveq	#36-1,d0
	moveq	#0,d1		; Skriv dit superfast finetune
	lea	mt_PeriodTable,a1
monteraintalenisuperfastfinetune:
	move.w	(a1)+,d2
	move.b	d1,0(a0,d2.w)
	addq.w	#2,d1
	dbra	d0,monteraintalenisuperfastfinetune

	lea	ascii,a0
	move.l	font,d0
	move.w	#256-1,d7		; R„kna ut asciitabellen
fixaascii:
	move.l	(a0),d1
	mulu	#8*6,d1
	add.l	d0,d1
	move.l	d1,(a0)+
	dbra	d7,fixaascii

	lea	starter,a0
	lea	grafixs,a1
	move.w	#266-1,d0		; Fixa till huvudmenybilden
swapparuntenrasterrad:			; eftersom det „r 336 i xled
	clr.l	(a0)+			; och inte 320.
	clr.l	(a0)+
	moveq	#20-1,d1
koppaindengammalraden:
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d1,koppaindengammalraden
	dbra	d0,swapparuntenrasterrad

	move.l	bildminne,a0
	lea	168*105(a0),a0
	moveq	#127,d0			; Skriv dit ramen runt slidern
	or.w	#%1111111111111110,(a0)	; i v„nsterbordern
skrivditslidern:
	lea	168(a0),a0
	or.w	#%1000000000000010,(a0)
	dbra	d0,skrivditslidern
	lea	168(a0),a0
	or.w	#%1111111111111110,(a0)

	move.l	bildminne,a3		; Spar undan songnamnet
	lea	(74*168)+8(a3),a2	; a2 till bilden
	add.l	#101056+2128+4,a3	; a3 till menyn
	bsr	sparsongsampleval

	lea	buffrar,a0
	move.l	#sample,d0
	moveq	#0,d1
	moveq	#3-1,d2
keloop: move.w	d1,d3
	mulu	#504*2,d3
	add.l	d0,d3
	move.l	d3,(a0)+
	addq.w	#1,d1
	dbra	d2,keloop
	move.l	#sample,(a0)+

	move.w	#13,-(sp)
	move.w	#26,-(sp)
	trap	#14			; Timer A av
	addq.w	#4,sp

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa upp i super
	addq.l	#6,sp
	move.l	d0,oldstack


	move.w	#$07ff,$ffff8924.w
	move.w	#%10000000000,$ffff8922.w
	move.l	$47e.w,oldmedia+2
	move.l	#mymedia,$47e.w

;	move.b	$fffffa07.w,d0
;	and.b	#%00000001,d0		; Anv„nds HBLen?
;	beq.s	hblenanv„ndsej		; isf skall vi INTE anv„nda
;	move.w	#1,hblisallreadyused	; Octalyserns HBL
;hblenanv„ndsej:

	move.b	#2,$FF8921		    ; Frequency
	lea	$FF8907,a0
	move.l	#sample,d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)
	move.l	#sample+(252*3*2*2),d0
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)
	move.b	#3,$FF8901	    ; Start DMA

	move.b	$484.w,mkey+1
	move.w	rept,keyrepeatdatainfo2
	move.w	del,keydelayrepeatdatainfo2

	jsr	getallsysteminfo	; Ta reda p† alla gamla
					; systeminst„llningar
;	lea	musform,a0		; Sprite
;	moveq	#16,d7			; L„ngd
;	jsr	gor2planes1616mask	; G”r mask f”r spritarna

	move.w	#$07ff,$ffff8924.w
	move.w	#%10011000000,$ffff8922.w	; Ingen huvudvolym

	lea	musform,a0
	lea	128(a0),a1
	move.w	#15*16-1,d7
roteraframspriten:
	movem.w	(a0)+,d0-d3
	move.w	#$2300,sr
	roxr.w	#1,d0
	roxr.w	#1,d2
	move.w	#$2300,sr
	roxr.w	#1,d1
	roxr.w	#1,d3
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	dbra	d7,roteraframspriten

	lea	medmus,a0
	lea	96*2(a0),a1
	move.w	#2*15*16-1,d7
roteraframmedspriten:
	movem.w	(a0)+,d0-d2
	move.w	#$2300,sr
	roxr.w	#1,d0
	roxr.w	#1,d1
	roxr.w	#1,d2
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	dbra	d7,roteraframmedspriten

	jsr	showintropic

	lea	aaliasdata1,a0
	lea	aaliasdata2,a1
	jsr	flyttadatatillverkligbuffer
	jsr	refreshtheplayerpointers
	jsr	myownsystem		; S„tt upp TRACKERsystemet
	jsr	stopknapp

	tst.w	optionsloaded
	beq.s	intestartaUCDMen
	btst.b	#1,termtonebuff+674
	beq.s	intestartaUCDMen
	move.l	losapositioner,-(sp)
	move.l	losarutiner,-(sp)
	jsr	settermody
	jsr	usetermody
	jsr	exittermody
	move.l	(sp)+,losarutiner
	move.l	(sp)+,losapositioner
intestartaUCDMen:

	tst.w	mode
	bne.s	inten†getoningstjafs
	jsr	arbetaframf„rgerna
inten†getoningstjafs:
	move.w	#1,mode

	move.l	basepage,a1
	lea	$80(a1),a1	; get address of command tail
	moveq	#0,d2
	lea	wholename,a0
	move.b	(a1)+,d2	; get length of string
	subq.w	#1,d2		; for dbra
	bmi.s	asdfasdf
koppa:	move.b	(a1)+,(a0)+
	dbra	d2,koppa
asdfasdf:
	clr.b	(a0)+

	tst.b	wholename		; Finns det en startstr„ng?
	beq.s	majorloop		; Ladda isf in modulen och
	move.w	$ffff8900.w,gammalfart
	jsr	laddainenmodulochk”r	; starta den
	move.l	#huvudlospos,losapositioner
	move.l	#huvudlosrutiner,losarutiner
majorloop:
	bsr	testas†oftasomm”jligt	; Skriv ut tid o patternpos.

	jsr	isakeyready
	bne.s	tangentf„rdigatth„mtas
	jsr	ritapatternettrashat
	bra	ingentangentnertryckt
tangentf„rdigatth„mtas:
	jsr	getkeywithasciiandshifts
	cmp.b	#'',d0 		; Var det ESC, isf utf”r den
	bne.s	intetheend		; f”rsta rutinen i meny-
	tst.l	fulleditorpek
	beq.s	nnnmmnnnm
	jsr	fullsk„rmseditorNU
	moveq	#0,d0
	bra.s	intetheend
nnnmmnnnm:
	move.l	losarutiner,a0		; rutinlistan
	move.l	(a0),a0
	jsr	(a0)
	moveq	#0,d0
intetheend:
	swap	d0
	and.w	#%0000111111111111,d0

;	move.l	d0,blaster
;	move.l	d0,dummen
;	lea	blaster,a3		; Vilket tal skall konverteras
;	move.w	#0,d0			; x
;	move.w	#0,d1			; y
;	move.w	#8-1,d7 		; Hur m†nga siffror
;	jsr	skrivuthex		; Skriv ut i hex
;	move.l	dummen,d0

	cmp.w	#$402,d0
	blt.s	intekontroll18
	cmp.w	#$409,d0
	bgt.s	intekontroll18
	sub.w	#$401,d0
	move.w	d0,stepswhenpressing
	lea	stepswhenpressing+1,a3	; Vilket tal skall konverteras
	move.w	#96,d0			; x
	move.w	#97,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	jsr	skrivuthex		; Skriv ut i hex
	moveq	#0,d0
intekontroll18:

	cmp.w	#$263,d0
	blt.s	inteenshiftp†keypadden1
	cmp.w	#$272,d0		; Snabbval av sampling via
	bgt.s	inteenshiftp†keypadden1	; tangentbordet
	cmp.l	#colorkoors,losapositioner
	beq.s	inteenshiftp†keypadden1
	cmp.l	#optionskoors,losapositioner
	beq.s	inteenshiftp†keypadden1
	cmp.l	#numpattskoors,losapositioner
	beq.s	inteenshiftp†keypadden1
	cmp.l	#termodykoors,losapositioner
	beq.s	inteenshiftp†keypadden1
	cmp.l	#selectshowpattkoors,losapositioner
	beq.s	inteenshiftp†keypadden1
	and.l	#$FF,d0
	sub.b	#$63,d0
	move.w	d0,whichsample
	lea	whichsample+1,a3	; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#49,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	jsr	skrivuthex		; Skriv ut i hex
	bsr	skrivuttillhorandeinfo
	jsr	checkifsamplechanged
	moveq	#0,d0
inteenshiftp†keypadden1:

	cmp.w	#$663,d0
	blt.s	inteenshiftp†keypadden2
	cmp.w	#$672,d0		; Snabbval av sampling via
	bgt.s	inteenshiftp†keypadden2	; tangentbordet
	cmp.l	#colorkoors,losapositioner
	beq.s	inteenshiftp†keypadden2
	cmp.l	#optionskoors,losapositioner
	beq.s	inteenshiftp†keypadden2
	cmp.l	#numpattskoors,losapositioner
	beq.s	inteenshiftp†keypadden2
	cmp.l	#termodykoors,losapositioner
	beq.s	inteenshiftp†keypadden2
	cmp.l	#selectshowpattkoors,losapositioner
	beq.s	inteenshiftp†keypadden2
	and.l	#$FF,d0
	sub.b	#$63-$10,d0
	move.w	d0,whichsample
	lea	whichsample+1,a3	; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#49,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	jsr	skrivuthex		; Skriv ut i hex
	bsr	skrivuttillhorandeinfo
	jsr	checkifsamplechanged
	moveq	#0,d0
inteenshiftp†keypadden2:

	cmp.w	#$70,d0			; 0 p† keypadden
	bne.s	intesl†stoppmed0an
	jsr	stopknapp
	moveq	#0,d0
intesl†stoppmed0an:

	cmp.w	#$3a,d0
	bne.s	intecapslock		; Caps lock
	jsr	refreshtheplayerpointers
	moveq	#0,d0
intecapslock:

	cmp.w	#$66,d0
	bne.s	intestj„rnanp†keypadden	; º*º p† keypadden
	tst.l	playplay
	bne.s	sl†barap†editmoden
	jsr	patternknapp
	jsr	sl†p†editendirekt„nd†
	moveq	#0,d0
	bra.s	intestj„rnanp†keypadden
sl†barap†editmoden:
	jsr	editknapp
	moveq	#0,d0
intestj„rnanp†keypadden:

	cmp.w	#$72,d0
	beq.s	spelaiplaymode
	cmp.b	#$1c,d0			; Return
	bne.s	intereturn
	move.w	d0,d1
	and.w	#%0000001100000000,d1
	bne.s	spelapattern
spelaiplaymode:
	jsr	playknapp		; Play
	moveq	#0,d0
	bra.s	intereturn
spelapattern:
	jsr	patternknapp
	moveq	#0,d0
intereturn:

	cmp.b	#$47,d0			; Clr home
	bne.s	inteclrhome
	bsr	clrhome
inteclrhome:

	cmp.b	#$41,d0			; F7
	bne.s	intef7
	move.w	#$20*$0,pattpos		; G† till $00
	move.w	speed,counter
intef7:
	cmp.b	#$42,d0			; F8
	bne.s	intef8
	move.w	#$20*$10,pattpos	; G† till $10
	move.w	speed,counter
intef8:
	cmp.b	#$43,d0			; F9
	bne.s	intef9
	move.w	#$20*$20,pattpos	; G† till $20
	move.w	speed,counter
intef9:
	cmp.b	#$44,d0			; F10
	bne.s	intef10
	move.w	#$20*$30,pattpos	; G† till $30
	move.w	speed,counter
intef10:

	cmp.b	#$62,d0
	bne.s	inteenhelp
vv:	lea	ver1,a5			; Meddela versionens
	lea	ver2,a6			; datum
	jsr	makejeppform
inteenhelp:

	cmp.w	#$802,d0
	bne.s	intealt1		; Av/p† kanal 1
	jsr	onoffchannel1
	moveq	#0,d0
intealt1:
	cmp.w	#$803,d0
	bne.s	intealt2		; Av/p† kanal 2
	jsr	onoffchannel2
	moveq	#0,d0
intealt2:
	cmp.w	#$804,d0
	bne.s	intealt3		; Av/p† kanal 3
	jsr	onoffchannel3
	moveq	#0,d0
intealt3:
	cmp.w	#$805,d0
	bne.s	intealt4		; Av/p† kanal 4
	jsr	onoffchannel4
	moveq	#0,d0
intealt4:
	cmp.w	#$806,d0
	bne.s	intealt5		; Av/p† kanal 5
	jsr	onoffchannel5
	moveq	#0,d0
intealt5:
	cmp.w	#$807,d0
	bne.s	intealt6		; Av/p† kanal 6
	jsr	onoffchannel6
	moveq	#0,d0
intealt6:
	cmp.w	#$808,d0
	bne.s	intealt7		; Av/p† kanal 7
	jsr	onoffchannel7
	moveq	#0,d0
intealt7:
	cmp.w	#$809,d0
	bne.s	intealt8		; Av/p† kanal 8
	jsr	onoffchannel8
	moveq	#0,d0
intealt8:

	cmp.w	#$44d,d0		; Control ->
	beq.s	k”rentabnu
	cmp.w	#$44b,d0		; Control <-
	beq	enshifttab
	cmp.b	#$f,d0			; En TAB
	bne	inteentab
	move.w	d0,d1
	lsr.w	#8,d1
	and.w	#$3,d1
	bne	enshifttab
k”rentabnu:
	move.w	cursorx,d1
	cmp.w	#17,d1
	ble.s	intemaxatvanstermedtab
	move.w	antalkanaler,d1
	subq.w	#3,d1
	cmp.w	startkanal,d1
	beq.s	dumahelavarlden
	addq.w	#1,startkanal
	move.w	startkanal,d5
	lsl.w	#4,d5
	jsr	skrivutkanalinfon
dumahelavarlden:
	moveq	#0,d0
	move.w	#18,cursorx
	move.l	oldcursorpek,a6
	clr.b	(a6)
	clr.b	1848(a6)
	bra	inteentab
intemaxatvanstermedtab:
	cmp.w	#5,cursorx
	bgt.s	inteforstakanalentab
	move.w	#6,cursorx
	bra.s	tabbigt
inteforstakanalentab:
	cmp.w	#11,cursorx
	bgt.s	inteandrakanalentab
	move.w	#12,cursorx
	bra.s	tabbigt
inteandrakanalentab:
	cmp.w	#17,cursorx
	bgt.s	tabbigt
	move.w	#18,cursorx
tabbigt:
	move.l	oldcursorpek,a6
	clr.b	(a6)
	clr.b	1848(a6)
	moveq	#0,d0
	bra	inteentab
enshifttab:				; En shift-TAB
	move.w	cursorx,d1
	cmp.w	#0,d1
	bne.s	intemaxathogermedshifttab
	cmp.w	#1,startkanal
	beq.s	inteshiftahitshifttab
	subq.w	#1,startkanal
	move.w	startkanal,d5
	lsl.w	#4,d5
	jsr	skrivutkanalinfon
inteshiftahitshifttab:
	moveq	#0,d0
	clr.w	cursorx
	move.l	oldcursorpek,a6
	clr.b	(a6)
	clr.b	1848(a6)
	bra.s	inteenshifttab
intemaxathogermedshifttab:
	cmp.w	#6,d1
	bgt.s	inte0kanalertab
	clr.w	cursorx
	bra.s	tabbigtshift
inte0kanalertab:
	cmp.w	#12,d1
	bgt.s	inteforstakanalenshifttab
	move.w	#6,cursorx
	bra.s	tabbigtshift
inteforstakanalenshifttab:
	cmp.w	#18,d1
	bgt.s	inteandrakanalenshifttab
	move.w	#12,cursorx
	bra.s	tabbigtshift
inteandrakanalenshifttab:
	move.w	#18,cursorx
tabbigtshift:
	move.l	oldcursorpek,a6
	clr.b	(a6)
	clr.b	1848(a6)
	moveq	#0,d0
inteenshifttab:
inteentab:




	cmp.w	#$3b,d0			; F1
	bne.s	ingentab
	bsr	chfreq			; Žndra freq p† tang.bordet
ingentab:
	cmp.w	#$3c,d0			; F2
	bne.s	ingenF2
	bsr	chwrt			; Žndra wrtmoden f”r blockhanteringen
ingenF2:

	cmp.w	#$23b,d0
	beq.s	det„renshiftF1		; shift-F1
	cmp.w	#$13c,d0
	bne.s	det„rinteenshiftF1
det„renshiftF1:
	bsr	chedmod
det„rinteenshiftF1:
	cmp.w	#$23c,d0
	beq.s	det„renshiftF2		; shift-F2
	cmp.w	#$13c,d0
	bne.s	det„rinteenshiftF2
det„renshiftF2:
	bsr	chblkmod
det„rinteenshiftF2:



	cmp.w	#$412,d0		; Control-E
	bne.s	intesl†p†fulleditornalls
	jsr	fullsk„rmseditorNU
	moveq	#0,d0
intesl†p†fulleditornalls:
	cmp.w	#$61,d0			; UNDO
	bne.s	integ”raundo
	move.w	#1,uppdateranup†eng†ng
	bsr	undo
	moveq	#0,d0
integ”raundo:

	tst.l	edit			; Om vi inte „r i editmod skall
	beq	inte„ndran†geh„r†nu	; inte det h„r kunna utf”ras

	cmp.b	#$2c,d0			; Control-Z
	bne.s	intetabortblocket
	move.w	d0,d1
	and.w	#$400,d1
	beq.s	intetabortblocket
	move.w	#1,uppdateranup†eng†ng
	and.w	#$300,d0
	beq.s	inteenshiftZp†tang
	moveq	#1,d7
	bra.s	enshiftZp†tang
inteenshiftZp†tang:
	moveq	#0,d7
enshiftZp†tang:
	bsr	rensablocket
intetabortblocket:
	cmp.b	#$2e,d0			; Control-C
	bne.s	intekopierablocket
	move.w	d0,d1
	and.w	#$400,d1
	beq.s	intekopierablocket
	move.w	#1,uppdateranup†eng†ng
	and.w	#$300,d0
	beq.s	inteenshiftCp†tang
	moveq	#1,d7
	bra.s	enshiftCp†tang
inteenshiftCp†tang:
	moveq	#0,d7
enshiftCp†tang:
	bsr	kopierablocket
intekopierablocket:
	cmp.b	#$2d,d0			; Control-X
	bne.s	inteinverterablocket
	move.w	d0,d1
	and.w	#$400,d1
	beq.s	inteinverterablocket
	move.w	#1,uppdateranup†eng†ng
	and.w	#$300,d0
	beq.s	inteenshiftXp†tang
	moveq	#1,d7
	bra.s	enshiftXp†tang
inteenshiftXp†tang:
	moveq	#0,d7
enshiftXp†tang:
	bsr	inverterablocket
inteinverterablocket:
	cmp.b	#$2f,d0			; Control-V
	bne.s	inteflyttablocket
	move.w	d0,d1
	and.w	#$400,d1
	beq.s	inteflyttablocket
	move.w	#1,uppdateranup†eng†ng
	and.w	#$300,d0
	beq.s	inteenshiftVp†tang
	moveq	#1,d7
	bra.s	enshiftVp†tang
inteenshiftVp†tang:
	moveq	#0,d7
enshiftVp†tang:
	bsr	flyttablocket
inteflyttablocket:
	cmp.w	#$430,d0		; Control-B
	bne.s	inteblockb”rjan
	bsr	setblockstart
	moveq	#0,d0
inteblockb”rjan:
	cmp.w	#$425,d0		; Control-K
	bne.s	inteblockslut
	bsr	setblockend
	moveq	#0,d0
inteblockslut:

	cmp.w	#$3d,d0			; F3
	bne.s	ingenF3
	move.w	#1,uppdateranup†eng†ng
	moveq	#0,d7
	bsr	rensaaktuelltpattern
	moveq	#0,d0
ingenF3:
	cmp.w	#$13d,d0		; shift-F3
	beq.s	detvarenshiftF3
	cmp.w	#$23d,d0		; shift-F3
	bne.s	ingenshiftF3
detvarenshiftF3:
	move.w	#1,uppdateranup†eng†ng
	move.w	#1,d7
	bsr	rensaaktuelltpattern
	moveq	#0,d0
ingenshiftF3:

	cmp.b	#$3e,d0			; F4
	bne.s	intemarkerahelakanalen
	clr.w	blockstart		; Markera hela aktuella kanalen
	move.w	#$3F,blockend
	bsr	snabbtiniblockmarkeringen
intemarkerahelakanalen:

	cmp.b	#$52,d0		; Insert
	bne.s	inteeninsert
	move.w	#1,uppdateranup†eng†ng
	lsr.w	#8,d0
	and.w	#$3,d0
	beq.s	inteenshiftinsertp†tang
	moveq	#1,d0
	bra.s	enshiftinsertp†tang
inteenshiftinsertp†tang:
	moveq	#0,d0
enshiftinsertp†tang:
	bsr	insertinpattern
	moveq	#0,d0
inteeninsert:

	cmp.b	#$53,d0		; Delete
	bne.s	inteendelete
	move.w	#1,uppdateranup†eng†ng
	lsr.w	#8,d0
	and.w	#$3,d0
	beq.s	inteenshiftdeletep†tang
	moveq	#1,d0
	bra.s	enshiftdeletep†tang
inteenshiftdeletep†tang:
	moveq	#0,d0
enshiftdeletep†tang:
	bsr	deleteinpattern
	moveq	#0,d0
inteendelete:

	cmp.w	#$415,d0		; Control-Y
	bne.s	inteendeletehela
	move.w	#1,uppdateranup†eng†ng
	moveq	#0,d0
	bsr	deleteinpattern
	moveq	#0,d0
inteendeletehela:
	cmp.w	#$615,d0		; Shift-Control-Y
	beq.s	encontrolymedshift
	cmp.w	#$515,d0
	bne.s	inteencontrolymedshift
encontrolymedshift:
	move.w	#1,uppdateranup†eng†ng
	moveq	#1,d0
	bsr	deleteinpattern
	moveq	#0,d0
inteencontrolymedshift:

	cmp.w	#$417,d0		; Control-I
	bne.s	inteeninserthela
	move.w	#1,uppdateranup†eng†ng
	moveq	#0,d0
	bsr	insertinpattern
	moveq	#0,d0
inteeninserthela:
	cmp.w	#$617,d0		; Shift-Control-I
	beq.s	encontrolimedshift
	cmp.w	#$517,d0
	bne.s	inteencontrolimedshift
encontrolimedshift:
	move.w	#1,uppdateranup†eng†ng
	moveq	#1,d0
	bsr	insertinpattern
	moveq	#0,d0
inteencontrolimedshift:



inte„ndran†geh„r†nu:

	cmp.b	#$4a,d0			; - p† keypadden
	bne.s	inteminusp†keypaden
	lsr.w	#8,d0
	and.w	#$3,d0
	beq.s	inteenshiftminusp†keypadden
	bsr	subpos
	moveq	#0,d0
	bra.s	inteminusp†keypaden
inteenshiftminusp†keypadden:
	cmp.l	#colorkoors,losapositioner
	beq.s	hopp”verminusp†keypadden
	cmp.l	#optionskoors,losapositioner
	beq.s	hopp”verminusp†keypadden
	cmp.l	#numpattskoors,losapositioner
	beq.s	hopp”verminusp†keypadden
	cmp.l	#termodykoors,losapositioner
	beq.s	hopp”verminusp†keypadden
	cmp.l	#selectshowpattkoors,losapositioner
	beq.s	hopp”verminusp†keypadden
	bsr	sampleminus
hopp”verminusp†keypadden:
	moveq	#0,d0
inteminusp†keypaden:
	cmp.b	#$4e,d0			; + p† keypadden
	bne.s	inteplusp†keypaden
	lsr.w	#8,d0
	and.w	#$3,d0
	beq.s	inteenshiftplusp†keypadden
	bsr	addpos
	moveq	#0,d0
	bra.s	inteplusp†keypaden
inteenshiftplusp†keypadden:
	cmp.l	#colorkoors,losapositioner
	beq.s	hopp”verplusp†keypadden
	cmp.l	#optionskoors,losapositioner
	beq.s	hopp”verplusp†keypadden
	cmp.l	#numpattskoors,losapositioner
	beq.s	hopp”verplusp†keypadden
	cmp.l	#termodykoors,losapositioner
	beq.s	hopp”verplusp†keypadden
	cmp.l	#selectshowpattkoors,losapositioner
	beq.s	hopp”verplusp†keypadden
	bsr	sampleplus
hopp”verplusp†keypadden:
	moveq	#0,d0
inteplusp†keypaden:


	cmp.w	#$84b,d0
	bne.s	inteencontrolv„nster	; Alt <-
	bsr	subpatt
	moveq	#0,d0
inteencontrolv„nster:
	cmp.w	#$84d,d0		; Alt ->
	bne.s	inteencontrolh”ger
	bsr	addpatt
	moveq	#0,d0
inteencontrolh”ger:

	cmp.b	#$4b,d0
	bne	hoppaintemedcursornatvanster
	lsr.w	#8,d0
	and.w	#$3,d0
	beq.s	inteenshiftv„nster
	move.w	#1,startkanal
	moveq	#1,d5
	lsl.w	#4,d5
	jsr	skrivutkanalinfon
	clr.w	cursorx
	move.l	oldcursorpek,a6
	clr.b	(a6)
	clr.b	1848(a6)
	moveq	#0,d0
	bra.s	hoppaintemedcursornatvanster
inteenshiftv„nster:
	tst.w	cursorx 		; Hoppa †t v„nster med cursor
	bne.s	ingenscrollellersaatvanster
	cmp.w	#1,startkanal
	bne.s	detvarintedaxattwrappav„nster
	move.w	antalkanaler,d1
	subq.w	#3,d1
	move.w	d1,startkanal
	move.w	d1,d5
	lsl.w	#4,d5
	jsr	skrivutkanalinfon
	moveq	#0,d0
	move.w	#24,cursorx
	bra.s	ingenscrollellersaatvanster
detvarintedaxattwrappav„nster:
	subq.w	#1,startkanal
	move.w	startkanal,d5
	lsl.w	#4,d5
	jsr	skrivutkanalinfon
	moveq	#0,d0
	move.w	#6,cursorx
ingenscrollellersaatvanster:
	subq.w	#1,cursorx
	move.l	oldcursorpek,a6
	clr.b	(a6)
	clr.b	1848(a6)
hoppaintemedcursornatvanster:

	cmp.b	#$4d,d0
	bne	hoppaintemedcursornathoger
	lsr.w	#8,d0
	and.w	#$3,d0
	beq.s	inteenshifth”ger
	move.w	antalkanaler,d1
	subq.w	#3,d1
	move.w	d1,startkanal
	move.w	d1,d5
	lsl.w	#4,d5
	jsr	skrivutkanalinfon
	move.w	#18,cursorx
	move.l	oldcursorpek,a6
	clr.b	(a6)
	clr.b	1848(a6)
	moveq	#0,d0
	bra.s	hoppaintemedcursornathoger
inteenshifth”ger:
	cmp.w	#23,cursorx		; Hoppa †t h”ger med cursor
	bne.s	ingenscrollellersaathoger
	move.w	antalkanaler,d1
	subq.w	#3,d1
	cmp.w	startkanal,d1
	bne.s	intedaxattwrappa†th”ger
	move.w	#1,startkanal
	move.w	startkanal,d5
	lsl.w	#4,d5
	jsr	skrivutkanalinfon
	moveq	#0,d0
	move.w	#-1,cursorx
	bra.s	ingenscrollellersaathoger
intedaxattwrappa†th”ger:
	addq.w	#1,startkanal
	move.w	startkanal,d5
	lsl.w	#4,d5
	jsr	skrivutkanalinfon
	moveq	#0,d0
	move.w	#17,cursorx
ingenscrollellersaathoger:
	addq.w	#1,cursorx
	move.l	oldcursorpek,a6
	clr.b	(a6)
	clr.b	1848(a6)
hoppaintemedcursornathoger:

	cmp.b	#$39,d0 		; Var det space som blev nertryckt?
	bne.s	inteenspace
	lsr.w	#8,d0
	and.w	#$3,d0
	beq.s	inteenshiftspace
	tst.l	playplay
	bne.s	stoppabara
	tst.w	monitor
	bne.s	stoppabara
	jsr	monitorknapp
	moveq	#0,d0
	bra.s	inteenspace
inteenshiftspace:
	tst.l	playplay
	bne.s	stoppabara
	tst.w	edit
	bne.s	stoppabara
	jsr	editknapp
	moveq	#0,d0
	bra.s	inteenspace
stoppabara:
	jsr	stopknapp
	moveq	#0,d0
inteenspace:

	cmp.w	#$450,d0
	bne.s	intener†tmedcontrol
	move.w	pattpos,lastpos		; Control ner
	move.w	whichpatt,lastsongpatt
	add.w	#$20*$10,pattpos
	bra.s	adderatredantillpos
intener†tmedcontrol:
	cmp.b	#$50,d0			; Ner†t
	bne.s	intenermedpiltangent
	move.w	pattpos,lastpos
	move.w	whichpatt,lastsongpatt
	move.w	d0,d1
	lsr.w	#8,d1
	and.w	#$3,d1
	beq.s	adderaendast1tillpattpos
	moveq	#0,d1
	move.w	stepswhenpressing,d1
	lsl.l	#5,d1
	add.w	d1,pattpos		; Addera steppen till pos
	bra.s	adderatredantillpos
adderaendast1tillpattpos:
	add.w	#$20,pattpos
adderatredantillpos:
	cmp.w	#$800-$20,pattpos
	ble.s	intenermedpiltangent1
	sub.w	#$800,pattpos
intenermedpiltangent1:
	move.w	speed,counter
	move.w	#1,hoppa”veradderingendenh„rg†ngen
	bsr	spelapatternetoxo
	moveq	#0,d0
intenermedpiltangent:

	cmp.w	#$448,d0
	bne.s	inteupp†tmedcontrol
	move.w	pattpos,lastpos		; Control upp
	move.w	whichpatt,lastsongpatt
	sub.w	#$20*$10,pattpos
	bra.s	subbatsteppentillpattpos
inteupp†tmedcontrol:
	cmp.b	#$48,d0
	bne.s	inteuppmedpiltangent
	move.w	pattpos,lastpos
	move.w	whichpatt,lastsongpatt
	move.w	d0,d1
	lsr.w	#8,d1
	and.w	#$3,d1
	beq.s	subbaendast1tillpattpos
	moveq	#0,d1
	move.w	stepswhenpressing,d1
	lsl.l	#5,d1
	sub.w	d1,pattpos		; Addera steppen till pos
	bra.s	subbatsteppentillpattpos
subbaendast1tillpattpos:
	sub.w	#$20,pattpos		; Piltangent upp
subbatsteppentillpattpos:
	tst.w	pattpos
	bpl.s	inteuppmedpiltangent1
	add.w	#$800,pattpos
inteuppmedpiltangent1:
	move.w	speed,counter
	move.w	#1,hoppa”veradderingendenh„rg†ngen
	bsr	spelapatternetoxo
	moveq	#0,d0
inteuppmedpiltangent:

	move.w	d0,d1
	and.w	#%0000010000000000,d1
	bne	encontrolltangent
	swap	d0
	cmp.b	#'a',d0
	blt.s	intesmabokstaver
	cmp.b	#'z',d0 		; Konvertera sm† till stora
	bgt.s	intesmabokstaver	; bokst„ver
	add.b	#'A'-'a',d0
intesmabokstaver:
	cmp.w	#8,d0
	bne.s	intebackspace
	tst.l	edit
	beq.s	intebackspace
	bsr	gepekaretillpos 	; F† reda p† pekare
	lea	blkdata,a2
	move.w	bsmode,d2		; Ta reda p† flaggst„llningen
	add.w	d2,d2
	add.w	d2,d2
	move.l	(a2,d2.w),d3
	and.l	d3,(a4)			; Rensa det
	bsr	rds			; Hoppa fram l„mpligt m†nga steg
intebackspace:
	tst.w	d0
	beq.s	inteeditera
	lea	tahandominstrument,a0
	move.w	cursorx,d1
	add.w	d1,d1			; Utf”r testrutin beroende p†
	add.w	d1,d1			; var cursorn st†r
	move.l	0(a0,d1.w),a0
	jsr	(a0)
	tst.l	edit
	beq.s	inteeditera
	move.l	patterns,a4		; Ta redan p† aktuell pekare till
	moveq	#0,d1			; patternet
	move.w	lastsongpatt,d1
	asl.l	#8,d1
	asl.l	#3,d1
	add.l	d1,a4
	moveq	#0,d1
	move.w	lastpos,d1
	add.l	d1,a4
	lea	shortpattern,a5
	moveq	#8-1,d0
loopaframtillshortpatternet:
	move.l	(a4)+,d2
	move.w	d2,d1
	and.w	#%0000111100000000,d1
	cmp.w	#$900,d1
	beq.s	kommandotskallmedoxo
	cmp.w	#$C00,d1
	beq.s	kommandotskallmedoxo
	and.w	#%1111000000000000,d2
kommandotskallmedoxo:
	move.l	d2,(a5)+
	dbra	d0,loopaframtillshortpatternet
inteeditera:
encontrolltangent:


denspelar:

ingentangentnertryckt:
	btst.b	#1,mkey 		; V„nster musknapp nertryckt?
	beq	ingenmusknappheller
	tst.l	fulleditorpek
	bne.s	intedaxf”rslutet
	tst.l	x
	bne.s	intedaxf”rslutet
	bsr	terminateOctan
	bra	majorloop
intedaxf”rslutet:

	move.l	#baraenrts,afterthesetting

	clr.w	musrep+4

	move.w	x,d0			; mus x
	move.w	y,d1			; mus y

	tst.l	fulleditorpek
	bne.s	intekolladefastaposarna

	move.w	d0,d6
	move.w	d1,d7
	moveq	#0,d2			; Vilken rutin skall utf”ras senvariabel
	moveq	#0,d3			; Hittades det n†gonvariabel
	lea	fastapositioner,a0	; Koordinattabell
	move.w	(a0)+,d7		; Hur m†nga koordinater
loopaingenomdefasta:
	cmp.w	(a0),d0
	ble.s	loopavidarepadefasta
	cmp.w	2(a0),d1
	ble.s	loopavidarepadefasta
	cmp.w	4(a0),d0
	bge.s	loopavidarepadefasta
	cmp.w	6(a0),d1
	bge.s	loopavidarepadefasta
	move.w	8(a0),musrep+4
	moveq	#1,d3
	bra.s	slutameddefasta
loopavidarepadefasta:
	lea	10(a0),a0
	addq.w	#4,d2
	dbra	d7,loopaingenomdefasta
slutameddefasta:
	tst.w	d3			; Hittade vi en korrekt position?
	beq.s	ingenfastrutinattutfora
	lea	kommandorutiner,a0	; Utf”r isf rutinen
	move.l	0(a0,d2.w),a0
	move.l	a0,musrep
	move.w	x,d6
	move.w	y,d7
	move.b	mkey,d5
	jsr	(a0)
	bra.s	ingenlosrutinattutfora
ingenfastrutinattutfora:
intekolladefastaposarna:
	move.w	x,d6
	move.w	y,d7
	moveq	#0,d2			; Vilken rutin skall utf”ras senvariabel
	moveq	#0,d3			; Hittades det n†gonvariabel
	move.l	losapositioner,a0	; Koordinattabell
	move.w	(a0)+,d7		; Hur m†nga koordinater
loopaingenomdelosa:
	cmp.w	(a0),d0
	ble.s	loopavidarepadelosa
	cmp.w	2(a0),d1
	ble.s	loopavidarepadelosa
	cmp.w	4(a0),d0
	bge.s	loopavidarepadelosa
	cmp.w	6(a0),d1
	bge.s	loopavidarepadelosa
	move.w	8(a0),musrep+4
	moveq	#1,d3
	bra.s	slutameddelosa
loopavidarepadelosa:
	lea	10(a0),a0
	addq.w	#4,d2
	dbra	d7,loopaingenomdelosa
slutameddelosa:
	tst.w	d3			; Hittade vi en korrekt position?
	beq.s	ingenlosrutinattutfora
	move.l	losarutiner,a0	; Utf”r isf rutinen
	move.l	0(a0,d2.w),a0
	move.l	a0,musrep
	move.w	x,d6
	move.w	y,d7
	move.b	mkey,d5
	jsr	(a0)
ingenlosrutinattutfora:



	cmp.w	#2,musrep+4
	bne.s	intedirektrep
	clr.w	sync
	bra.s	vantapaslapptmusknapp
intedirektrep:
	move.w	mousedelay,sync
vantapaslapptmusknapp:
	bsr	testas†oftasomm”jligt	; Skriv ut tid o patternpos.
	jsr	ritapatternettrashat
	btst.b	#1,mkey 		; V„nta p† att anv„ndaren skall sl„ppa musknappen
	beq.s	ingenmusknappheller2
	tst.w	musrep+4		; Musrepetition?
	beq.s	vantapaslapptmusknapp
	btst.b	#0,mkey
	beq.s	testasyncen
	tst.w	sync
	ble.s	testasyncen
	clr.w	sync
testasyncen:
	tst.w	sync
	bpl.s	vantapaslapptmusknapp	; Ja, har delayen varit?
	clr.w	sync
	move.w	x,d6
	move.w	y,d7
	move.b	mkey,d5
	move.l	musrep,a0
	jsr	(a0)			; Ja, utf”r rutinen
	bra.s	vantapaslapptmusknapp
ingenmusknappheller2:
	move.w	x,d6
	move.w	y,d7
	move.b	mkey,d5			; Sista rycket..
	move.l	afterthesetting,a0
	jsr	(a0)
ingenmusknappheller:


	bra	majorloop
terminateOctan:
	lea	quitstrang,a5
	lea	dummystrang,a6
	jsr	makeform
	tst.w	d0
	bpl.s	xjkdfjghkcvbnm
	rts
xjkdfjghkcvbnm:
	move.l	(sp)+,d0
	move.l	#goodbyestring,messagepointer
	jsr	reinstallsystem		; Installera systemet igen

hoppainiavslutning:
	clr.b	$ffff8901.w		; Stop DMA

	move.b	mkey+1,$484.w
	move.w	#$07ff,$ffff8924.w
	move.w	#%10011101000,$ffff8922.w
	move.l	oldmedia+2,$47e.w

	move.l	oldstack,-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa tebax till user
	addq.l	#6,sp

	jsr	closeinternalmemhandler	; Sl„pp allt internt anv„nt minne
	jsr	forceredrawofGEMscreen
	jsr	makebusy
	tst.w	kanejg†uttillGEM
	bne.s	„hhden„rjuinteladdad
	jsr	rsrc_free		; Sl„pp RSCfilen i minnet
„hhden„rjuinteladdad:
	jsr	appl_exit
direktur:
	clr.w	-(sp)
	trap	#1			; Avsluta programet...

interegistrerad:
fel:	illegal

loopaindata:				; Kopierar regdata in i
	cmp.b	#'',(a1)		; GEMformerna
	beq.s	slutakopparegdata
	move.b	(a1)+,(a2)+
	bra.s	loopaindata
slutakopparegdata:
	clr.b	(a2)
	rts

testas†oftasomm”jligt:			; Denna rutin skall anropas
	tst.w	extratime		; s† ofta som m”jligt!!!!!!
	bmi.s	sammatid
	moveq	#0,d0
	move.w	currenttime,d0		; Kolla om vi skall skriva
	cmp.w	extratime,d0		; ut aktuell timer
	beq.s	sammatid
	move.w	d0,extratime
	moveq	#0,d1
	moveq	#0,d2
	move.w	d0,d1
	divu	#10,d1
	move.w	d1,d2
	mulu	#10,d2
	sub.w	d2,d0
	add.w	#'0',d0
	add.w	#'0',d1
	move.b	d1,tidsstr„ng+3
	move.b	d0,tidsstr„ng+4
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.w	h”gtimebit,d0
	move.w	d0,d1
	divu	#10,d1
	move.w	d1,d2
	mulu	#10,d2
	sub.w	d2,d0
	add.w	#'0',d0
	add.w	#'0',d1
	move.b	d1,tidsstr„ng
	move.b	d0,tidsstr„ng+1
	lea	tidsstr„ng,a3
	move.w	#272,d0			; x
	move.w	#86,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen
sammatid:
	move.b	songpos,d0
	cmp.b	screensongpos,d0
	beq.s	sk„rmenoverklighetenst„mmer
	move.b	d0,screensongpos
	lea	songpos,a3		; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#6,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	jsr	skrivuthex		; Skriv ut i hex
sk„rmenoverklighetenst„mmer:
	move.w	whichpatt,d0
	cmp.w	screenpatt,d0
	beq.s	sk„rmenoverklighetenst„mmerigen
	move.w	d0,screenpatt
	lea	whichpatt+1,a3		; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#16,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	jsr	skrivuthex		; Skriv ut i hex
sk„rmenoverklighetenst„mmerigen:
	tst.w	VUp†av
	beq	VUmetrarna„ravslagnaf”rst†rdu
	tst.w	VUchanged
	beq	VUmetrarna„ravslagnaf”rst†rdu
	clr.w	VUchanged
	moveq	#0,d1
	lea	converteradata,a0
	move.l	a0,a1
	moveq	#8-1,d0
	move.l	bildminne,a2
	addq.w	#2,a2
	lea	chanel8onoff+2,a3
	cmp.w	#4,antalkanaler
	bne.s	inte4astycken
	subq.w	#4,d0
	lea	13*4*168(a2),a2
	subq.w	#8,a1
	lea	chanel5onoff,a3
	bra.s	ritautallaVUmetrarna
inte4astycken:
	cmp.w	#6,antalkanaler
	bne.s	ritautallaVUmetrarna
	subq.w	#2,d0
	lea	13*2*168(a2),a2
	subq.w	#4,a1
	lea	chanel7onoff,a3
ritautallaVUmetrarna:		; Rita ut 12 raders VU-metrar
	tst.w	-(a3)
	bmi.s	dennakanal„rp†f”rVU
	moveq	#0,d2
	subq.w	#2,a1
	bra.s	skrivutVUNU
dennakanal„rp†f”rVU:
	move.w	-(a1),d1
	lsr.w	#1,d1
	and.w	#$FE,d1
	move.w	(a0,d1.w),d2
skrivutVUNU:
	move.w	d2,(a2)
	move.w	d2,(1*168)(a2)
	move.w	d2,(2*168)(a2)
	move.w	d2,(3*168)(a2)
	move.w	d2,(4*168)(a2)
	move.w	d2,(5*168)(a2)
	move.w	d2,(6*168)(a2)
	move.w	d2,(7*168)(a2)
	move.w	d2,(8*168)(a2)
	move.w	d2,(9*168)(a2)
	move.w	d2,(10*168)(a2)
	move.w	d2,(11*168)(a2)
	lea	(13*168)(a2),a2
	dbra	d0,ritautallaVUmetrarna
VUmetrarna„ravslagnaf”rst†rdu:
	tst.w	lowershower
	bmi.s	inter„knautsampleoffset
	cmp.w	#STATIONAR+8,fastapositioner
	bne.s	inter„knautsampleoffset
	cmp.l	#infokoors,losapositioner
	beq.s	inter„knautsampleoffset
	move.w	x,d0
	move.w	y,d1
	cmp.w	#112,d1
	ble.s	inter„knautsampleoffset
	cmp.w	#177,d1
	bge.s	inter„knautsampleoffset
	cmp.w	#7+16,d0
	ble.s	inter„knautsampleoffset
	cmp.w	#312+16,d0
	bge.s	inter„knautsampleoffset
	moveq	#0,d2
	tst.l	sample1len
	beq.s	tomsamplingskrivutnoll
	move.l	sample1len,d2
	sub.w	#16+8,d0
	mulu	d0,d2
	divu	#303,d2
tomsamplingskrivutnoll:
	move.w	d2,blaster
	lea	blaster,a3		; Vilket tal skall konverteras
	move.w	#144,d0			; x
	move.w	#84+106,d1			; y
	move.w	#4-1,d7 		; Hur m†nga siffror
	jsr	skrivuthex		; Skriv ut i hex
inter„knautsampleoffset:
	rts

VUchanged:
	dc.w	0
screensongpos:
	dc.w	0
screenpatt:
	dc.w	0

chedmod:
	addq.w	#1,edmode		; Žndrar p† editmoden
	cmp.w	#4,edmode
	blt.s	allt„rokofint
	clr.w	edmode
allt„rokofint:
	move.w	edmode,d0
	add.w	d0,d0
	lea	edonit,a3
	add.w	d0,a3
	move.w	#168,d0			; x
	move.w	#97,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen
	moveq	#0,d0
	rts

chblkmod:
	addq.w	#1,blkmode		; Žndrar p† blockmoden
	cmp.w	#7,blkmode
	blt.s	allt„rokofint2
	clr.w	blkmode
allt„rokofint2:
	move.w	blkmode,d0
	add.w	d0,d0
	lea	blkonit,a3
	add.w	d0,a3
	move.w	#176,d0			; x
	move.w	#97,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen
	moveq	#0,d0
	rts

chbkspcmod:
	addq.w	#1,bsmode		; Žndrar p† backspacemoden
	cmp.w	#7,bsmode
	blt.s	allt„rokofint3
	clr.w	bsmode
allt„rokofint3:
	move.w	bsmode,d0
	add.w	d0,d0
	lea	blkonit,a3
	add.w	d0,a3
	move.w	#169,d0			; x
	move.w	#97,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen
	moveq	#0,d0
	rts

clrhome:
	clr.w	cursorx
	move.l	oldcursorpek,a6
	clr.b	(a6)
	clr.b	1848(a6)
	clr.w	pattpos		; G† hem
	clr.w	lastpos
	move.w	#$1,startkanal
	move.w	startkanal,d5
	lsl.w	#4,d5
	jsr	skrivutkanalinfon
	moveq	#0,d0
	rts

spelapatternetoxo:
	tst.w	monitor
	beq.s	intespeladetmedmonitor
	move.l	patterns,a4		; Ta redan p† aktuell pekare till
	moveq	#0,d1			; patternet
	move.w	whichpatt,d1
	asl.l	#8,d1
	asl.l	#3,d1
	add.l	d1,a4
	moveq	#0,d1
	move.w	pattpos,d1
	add.l	d1,a4
	lea	shortpattern,a5
	moveq	#8-1,d0
loopaframtillshortpatternet2:
	move.l	(a4)+,d2
	move.w	d2,d1
	and.w	#%0000111100000000,d1
	cmp.w	#$900,d1
	beq.s	kommandotskallmedoxo2
	cmp.w	#$C00,d1
	beq.s	kommandotskallmedoxo2
	and.w	#%1111000000000000,d2
kommandotskallmedoxo2:
	move.l	d2,(a5)+
	dbra	d0,loopaframtillshortpatternet2
intespeladetmedmonitor:
	moveq	#0,d0
	rts

frekvensupp:			; Frekvens upp
	move.w	#1,uppdateranup†eng†ng
	jsr	copytoundobuffer
	tst.w	blockset
	beq.s	block„rintesattf”rfupp
	tst.w	blockcollect
	bne	integ”ran†got†tsakenfupp
	move.l	patterns,a4		; Ta redan p† aktuell pekare till
	moveq	#0,d1			; patternet
	move.w	blockpattern,d1
	asl.l	#8,d1
	asl.l	#3,d1
	add.l	d1,a4
	moveq	#0,d1
	move.w	blockchannel,d1
	subq.w	#1,d1		; Ta reda p† pekare till just den h„r
	add.w	d1,d1		; kanalen
	add.w	d1,d1
	add.w	d1,a4
	move.w	blockstart,d0
	lsl.w	#5,d0
	add.w	d0,a4
	move.w	blockend,d0
	sub.w	blockstart,d0
	bra.s	block„rsattf”rfupp
block„rintesattf”rfupp:
	move.l	patterns,a4		; Ta redan p† aktuell pekare till
	moveq	#0,d1			; patternet
	move.w	lastsongpatt,d1
	asl.l	#8,d1
	asl.l	#3,d1
	add.l	d1,a4
	moveq	#0,d1
	move.w	startkanal,d1
	subq.w	#1,d1		; Ta reda p† pekare till just den h„r
	add.w	d1,d1		; kanalen
	add.w	d1,d1
	add.l	d1,a4
	moveq	#0,d1
	bsr	vilkenaktivkanal
	add.l	d1,a4
	moveq	#64-1,d0
block„rsattf”rfupp:
fupp:					; Frekvensen p† v„g upp
	tst.w	blockhandling
	bne.s	allatonerskallp†verkas
	move.l	(a4),d1
	and.l	#%11110000000000001111000000000000,d1
	move.l	d1,d2
	lsr.l	#8,d2
	lsr.l	#4,d2
	and.l	#%11110000000000000000000000000000,d1
	beq.s	inteadderaen10tillfupp
	add.b	#$10,d2
inteadderaen10tillfupp:
	cmp.b	whichsample+1,d2
	bne.s	ingenfrekvensattarbetap†upp†t
allatonerskallp†verkas:
	move.l	(a4),d1
	and.l	#%00001111111111110000000000000000,d1
	beq.s	ingenfrekvensattarbetap†upp†t	; Ingen ton alls?
	swap	d1
	lea	mt_PeriodTable,a0
hittar„tttonf”rfupp:			; Hitta r„tt ton
	cmp.w	(a0)+,d1
	bne.s	hittar„tttonf”rfupp
	cmp.w	#850,(a0)		; Var det den sista?
	bne.s	intemaxfrekvens„n
	and.w	#%1111000000000000,(a4)
	or.w	#856,(a4)
	bra.s	ingenfrekvensattarbetap†upp†t
intemaxfrekvens„n:
	move.w	(a0),d1			; Skriv dit den h”gre frekvensen
	and.w	#%1111000000000000,(a4)
	or.w	d1,(a4)
ingenfrekvensattarbetap†upp†t:
	lea	32(a4),a4		; Loopa
	dbra	d0,fupp
integ”ran†got†tsakenfupp:
	rts

frekvensner:			; Frekvens ner
	move.w	#1,uppdateranup†eng†ng
	jsr	copytoundobuffer
	tst.w	blockset
	beq.s	block„rintesattf”rfner
	tst.w	blockcollect
	bne	integ”ran†got†tsakenfner
	move.l	patterns,a4		; Ta redan p† aktuell pekare till
	moveq	#0,d1			; patternet
	move.w	blockpattern,d1
	asl.l	#8,d1
	asl.l	#3,d1
	add.l	d1,a4
	moveq	#0,d1
	move.w	blockchannel,d1
	subq.w	#1,d1		; Ta reda p† pekare till just den h„r
	add.w	d1,d1		; kanalen
	add.w	d1,d1
	add.w	d1,a4
	move.w	blockstart,d0
	lsl.w	#5,d0
	add.w	d0,a4
	move.w	blockend,d0
	sub.w	blockstart,d0
	bra.s	block„rsattf”rfner
block„rintesattf”rfner:
	move.l	patterns,a4		; Ta redan p† aktuell pekare till
	moveq	#0,d1			; patternet
	move.w	lastsongpatt,d1
	asl.l	#8,d1
	asl.l	#3,d1
	add.l	d1,a4
	moveq	#0,d1
	move.w	startkanal,d1
	subq.w	#1,d1		; Ta reda p† pekare till just den h„r
	add.w	d1,d1		; kanalen
	add.w	d1,d1
	add.l	d1,a4
	moveq	#0,d1
	bsr	vilkenaktivkanal
	add.l	d1,a4
	moveq	#64-1,d0
block„rsattf”rfner:
fner:					; Frekvensen p† v„g ner
	tst.w	blockhandling
	bne.s	allatonerskallp†verkas2
	move.l	(a4),d1
	and.l	#%11110000000000001111000000000000,d1
	move.l	d1,d2
	lsr.l	#8,d2
	lsr.l	#4,d2
	and.l	#%11110000000000000000000000000000,d1
	beq.s	inteadderaen10tillfner
	add.b	#$10,d2
inteadderaen10tillfner:
	cmp.b	whichsample+1,d2
	bne.s	ingenfrekvensattarbetap†ner†t
allatonerskallp†verkas2:
	move.l	(a4),d1
	and.l	#%00001111111111110000000000000000,d1
	beq.s	ingenfrekvensattarbetap†ner†t	; Ingen ton alls?
	swap	d1
	lea	mt_PeriodTable,a0
hittar„tttonf”rfner:			; Hitta r„tt ton
	cmp.w	(a0)+,d1
	bne.s	hittar„tttonf”rfner
	cmp.w	#856,-2(a0)		; Var det den sista?
	bne.s	intemaxfrekvens„n2
	and.w	#%1111000000000000,(a4)
	or.w	#113,(a4)
	bra.s	ingenfrekvensattarbetap†ner†t
intemaxfrekvens„n2:
	move.w	-4(a0),d1		; Skriv dit den l„gre frekvensen
	and.w	#%1111000000000000,(a4)
	or.w	d1,(a4)
ingenfrekvensattarbetap†ner†t:
	lea	32(a4),a4		; Loopa
	dbra	d0,fner
integ”ran†got†tsakenfner:
	rts

blockhide:				; G”m blocket
	clr.w	blockset
	bsr	outputblockstatus
	rts

setblockstart:				; S„tt blockb”rjan
	move.w	lastpos,d7
	lsr.w	#5,d7
	move.w	d7,blockstart
snabbtiniblockmarkeringen:
	move.w	lastsongpatt,blockpattern
	clr.w	blockcollect
	bsr	vilkenaktivkanal
	lsr.w	#2,d1
	add.w	startkanal,d1
	move.w	d1,blockchannel
	tst.w	blockset
	bne.s	blocket„rredansatttestablockslutet
	move.w	#$3F,blockend
	bra.s	blockstartsatt	
blocket„rredansatttestablockslutet:
	move.w	blockend,d0
	cmp.w	d7,d0
	bge.s	blockstartsatt
	move.w	#$3F,blockend
blockstartsatt:
	move.w	#1,blockset
	bsr.s	outputblockstatus
	rts

setblockend:				; S„tt blockslut
	move.w	lastsongpatt,blockpattern
	move.w	lastpos,d7
	lsr.w	#5,d7
	move.w	d7,blockend
	clr.w	blockcollect
	bsr	vilkenaktivkanal
	lsr.w	#2,d1
	add.w	startkanal,d1
	move.w	d1,blockchannel
	tst.w	blockset
	bne.s	blocket„rredansatttestablockstart
	clr.w	blockstart
	bra.s	blockendsatt	
blocket„rredansatttestablockstart:
	move.w	blockstart,d0
	cmp.w	d7,d0
	ble.s	blockendsatt
	clr.w	blockstart
blockendsatt:
	move.w	#1,blockset
	bsr.s	outputblockstatus
	rts

outputblockstatus:			; Visar blockstatusen
	tst.w	blockset
	bne.s	blocket„rredansatt
	lea	noneblock,a3
	move.w	#224,d0 		; x
	move.w	#97,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen
	rts
blocket„rredansatt:
	move.b	blockchannel+1,blockstatus+6
	add.b	#'0',blockstatus+6	; Visa vilken kanal blocket ligger i
	tst.w	blockcollect
	beq.s	blockfinnsinteibuffern
	move.b	#'M',blockstatus+6	; Visa att det ligger i minnet redan (om blocket „r inladdad redan)
blockfinnsinteibuffern:
	move.w	blockstart,d0
	lea	blockstatus,a0
	bsr	converttoascii		; Convertera blockb”rjan till str„ngen
	move.w	blockend,d0
	lea	blockstatus+3,a0
	bsr	converttoascii		; Convertera blockslut till str„ngen
	lea	blockstatus,a3
	move.w	#224,d0 		; x
	move.w	#97,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen		
	rts

rensablocket:				; Rensar blockytan
	jsr	copytoundobuffer
	lea	blkdata,a2
	move.w	blkmode,d2
	add.w	d2,d2
	add.w	d2,d2
	move.l	(a2,d2.w),d3
	move.l	d3,d4		; d3 masken till rensningen av patternet
	not.l	d4		; d4 masken till datan som flyttas
	tst.w	blockset
	beq.s	blocketiminnet
	tst.w	blockcollect
	bne.s	blocketiminnet
	move.l	patterns,a4		; Ta redan p† aktuell pekare till
	moveq	#0,d1			; patternet
	move.w	blockpattern,d1
	asl.l	#8,d1
	asl.l	#3,d1
	add.l	d1,a4
	tst.w	d7		; En shift?
	bne.s	enshiftF32
	moveq	#0,d1
	move.w	blockchannel,d1
	subq.w	#1,d1		; Ta reda p† pekare till just den h„r
	add.w	d1,d1		; kanalen
	add.w	d1,d1
	add.w	d1,a4
	move.w	blockstart,d0
	lsl.w	#5,d0
	add.w	d0,a4
	move.w	blockend,d0
	sub.w	blockstart,d0
rensaenkanalbara2:		; Rensa block kanalen
	and.l	d3,(a4)
	lea	32(a4),a4
	dbra	d0,rensaenkanalbara2
	bra.s	blocketiminnet
enshiftF32:
	move.w	blockstart,d0
	lsl.w	#5,d0
	add.w	d0,a4
	move.w	blockend,d0
	sub.w	blockstart,d0
rensaallakanaler2:		; Rensa block patternet
	and.l	d3,(a4)+
	and.l	d3,(a4)+
	and.l	d3,(a4)+
	and.l	d3,(a4)+
	and.l	d3,(a4)+
	and.l	d3,(a4)+
	and.l	d3,(a4)+
	and.l	d3,(a4)+
	dbra	d0,rensaallakanaler2
blocketiminnet:
	clr.w	blockset
	bsr	outputblockstatus
	rts

undo:
	tst.l	undopek
	beq.s	finnsingenundoattg”ra
	lea	undobuffer,a0
	move.l	undopek,a1
	moveq	#64-1,d0
kopieraUNDOtillpatternet:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,kopieraUNDOtillpatternet
finnsingenundoattg”ra:
	rts

undobuffer:
	ds.l	64*8
undopek:dc.l	0

copytoundobuffer:
	lea	undobuffer,a0
	move.l	patterns,a1		; Ta redan p† aktuell pekare till
	moveq	#0,d1			; patternet
	move.w	lastsongpatt,d1
	asl.l	#8,d1
	asl.l	#3,d1
	add.l	d1,a1
	move.l	a1,undopek
	moveq	#64-1,d0
kopierapatternettillUNDO:
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d0,kopierapatternettillUNDO
	rts

kopierablocket:				; Kopierar blocket
	jsr	copytoundobuffer
	lea	blkdata,a2
	move.w	blkmode,d2
	add.w	d2,d2
	add.w	d2,d2
	move.l	(a2,d2.w),d3
	move.l	d3,d4		; d3 masken till rensningen av patternet
	not.l	d4		; d4 masken till datan som flyttas
	tst.w	blockset
	beq	finnsingetblockattkopiera
	move.l	patterns,a4		; Ta redan p† aktuell pekare till
	moveq	#0,d1			; patternet
	move.w	blockpattern,d1
	asl.l	#8,d1
	asl.l	#3,d1
	add.l	d1,a4
	tst.w	d7		; En shift?
	bne.s	kopieraallakanalertillbuffern
	moveq	#0,d1
	move.w	blockchannel,d1
	subq.w	#1,d1		; Ta reda p† pekare till just den h„r
	add.w	d1,d1		; kanalen
	add.w	d1,d1
	add.w	d1,a4
	move.w	blockstart,d0
	lsl.w	#5,d0
	add.w	d0,a4
	lea	blockbuffer,a0
	add.w	d1,a0
	move.w	blockend,d0
	sub.w	blockstart,d0
	move.l	a0,a6
	move.w	d0,d6
	tst.w	blockcollect
	bne.s	blocketibuffernnukopieratebaxdet
flyttaenkanaltillbuffern:	; Flytta en kanal till buffern
	move.l	(a4),(a0)
	lea	32(a4),a4
	lea	32(a0),a0
	dbra	d0,flyttaenkanaltillbuffern
	bra.s	blocketibuffernnukopieratebaxdet
kopieraallakanalertillbuffern:
	move.w	blockstart,d0
	lsl.w	#5,d0
	add.w	d0,a4
	move.w	blockend,d0
	sub.w	blockstart,d0
	lea	blockbuffer,a0
	move.l	a0,a6
	move.w	d0,d6
	tst.w	blockcollect
	bne.s	blocketibuffernnukopieratebaxdet
kopieraallakanaler:		; Kopiera alla kanaler till buffern
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	dbra	d0,kopieraallakanaler
blocketibuffernnukopieratebaxdet:
	move.l	patterns,a4		; Ta redan p† aktuell pekare till
	moveq	#0,d1			; patternet
	move.w	lastsongpatt,d1
	asl.l	#8,d1
	asl.l	#3,d1
	add.l	d1,a4
	add.w	lastpos,a4

	move.w	d6,d0
	move.w	lastpos,d1
	lsr.w	#5,d1			; Testa s† att inte blocket blir
	move.w	d1,d2			; f”r stort
	add.w	d0,d2
	cmp.w	#$3F,d2
	ble.s	inomgr„nsenf”rkopierandet
	neg.w	d1
	add.w	#$3f,d1
	move.w	d1,d6
inomgr„nsenf”rkopierandet:

	tst.w	d7		; Alla?
	bne.s	fr†nbuffertillpattalla
	moveq	#0,d1
	move.w	startkanal,d1
	subq.w	#1,d1		; Ta reda p† pekare till just den h„r
	add.w	d1,d1		; kanalen
	add.w	d1,d1
	add.l	d1,a4
	moveq	#0,d1
	bsr	vilkenaktivkanal
	add.l	d1,a4
	move.w	d6,d0
	move.l	a6,a0
	tst.w	wrtmode
	beq.s	orradit1pattern
	cmp.w	#2,wrtmode
	bne.s	flyttaenkanaltillpatternet
flyttaenkanaltillpatternet3:	; Flytta en kanal till patternet
	move.l	(a4),d5
	and.l	d4,d5
	bne.s	inteflyttaindatan3
	move.l	(a0),d5
	and.l	d4,d5
	and.l	d3,(a4)
	or.l	d5,(a4)
inteflyttaindatan3:
	lea	32(a4),a4
	lea	32(a0),a0
	dbra	d0,flyttaenkanaltillpatternet3
	bra	finnsingetblockattkopiera
flyttaenkanaltillpatternet:	; Flytta en kanal till patternet
	and.l	d3,(a4)
	move.l	(a0),d5
	and.l	d4,d5
	or.l	d5,(a4)
	lea	32(a4),a4
	lea	32(a0),a0
	dbra	d0,flyttaenkanaltillpatternet
	bra	finnsingetblockattkopiera
orradit1pattern:
flyttaenkanaltillpatternet2:	; Flytta en kanal till patternet
	move.l	(a0),d5
	and.l	d4,d5
	beq.s	inteflyttaindatan
	and.l	d3,(a4)
	or.l	d5,(a4)
inteflyttaindatan:
	lea	32(a4),a4
	lea	32(a0),a0
	dbra	d0,flyttaenkanaltillpatternet2
	bra	finnsingetblockattkopiera
fr†nbuffertillpattalla:
	move.w	d6,d0
	move.l	a6,a0
	tst.w	wrtmode
	beq.s	flyttamedorrmod
	cmp.w	#2,wrtmode
	bne.s	kopieraallakanalertillpatternet
	mulu	#8,d0
kopieraallakanalertillpatternet3:	; Kopiera alla kanaler till patternet
	move.l	(a4),d5
	and.l	d4,d5
	bne.s	inteflyttaindennu3
	move.l	(a0),d5
	and.l	d4,d5
	and.l	d3,(a4)
	or.l	d5,(a4)
inteflyttaindennu3:
	addq.w	#4,a0
	addq.w	#4,a4
	dbra	d0,kopieraallakanalertillpatternet3
	bra.s	finnsingetblockattkopiera
kopieraallakanalertillpatternet:; Kopiera alla kanaler till patternet
	rept	8
	and.l	d3,(a4)
	move.l	(a0)+,d5
	and.l	d4,d5
	or.l	d5,(a4)+
	endr
	dbra	d0,kopieraallakanalertillpatternet
	bra.s	finnsingetblockattkopiera
flyttamedorrmod:
	mulu	#8,d0
kopieraallakanalertillpatternet2:	; Kopiera alla kanaler till patternet
	move.l	(a0),d5
	and.l	d4,d5
	beq.s	inteflyttaindennu
	and.l	d3,(a4)
	or.l	d5,(a4)
inteflyttaindennu:
	addq.w	#4,a0
	addq.w	#4,a4
	dbra	d0,kopieraallakanalertillpatternet2
finnsingetblockattkopiera:
	rts


inverterablocket:			; Inverterar blocket
	jsr	copytoundobuffer
	lea	blkdata,a2
	move.w	blkmode,d2
	add.w	d2,d2
	add.w	d2,d2
	move.l	(a2,d2.w),d3
	move.l	d3,d4		; d3 masken till rensningen av patternet
	not.l	d4		; d4 masken till datan som flyttas
	tst.w	blockset
	beq	finnsingetblockattinvertera
	move.l	patterns,a4		; Ta redan p† aktuell pekare till
	moveq	#0,d1			; patternet
	move.w	blockpattern,d1
	asl.l	#8,d1
	asl.l	#3,d1
	add.l	d1,a4
	tst.w	d7		; En shift?
	bne.s	kopieraallakanalertillbuffern24
	moveq	#0,d1
	move.w	blockchannel,d1
	subq.w	#1,d1		; Ta reda p† pekare till just den h„r
	add.w	d1,d1		; kanalen
	add.w	d1,d1
	add.w	d1,a4
	move.w	blockstart,d0
	lsl.w	#5,d0
	add.w	d0,a4
	lea	blockbuffer,a0
	add.w	d1,a0
	move.w	blockend,d0
	sub.w	blockstart,d0
	move.w	d0,d6
	tst.w	blockcollect
	bne.s	blocketibuffernnuinverteratebaxdet
flyttaenkanaltillbuffern24:	; Flytta en kanal till buffern
	move.l	(a4),(a0)
	lea	32(a4),a4
	lea	32(a0),a0
	dbra	d0,flyttaenkanaltillbuffern24
	lea	-32(a0),a6
	bra.s	blocketibuffernnuinverteratebaxdet
kopieraallakanalertillbuffern24:
	move.w	blockstart,d0
	lsl.w	#5,d0
	add.w	d0,a4
	move.w	blockend,d0
	sub.w	blockstart,d0
	lea	blockbuffer,a0
	move.w	d0,d6
	tst.w	blockcollect
	bne.s	blocketibuffernnuinverteratebaxdet
kopieraallakanaler24:		; Kopiera alla kanaler till buffern
	move.l	(a4)+,28(a0)
	move.l	(a4)+,24(a0)
	move.l	(a4)+,20(a0)
	move.l	(a4)+,16(a0)
	move.l	(a4)+,12(a0)
	move.l	(a4)+,8(a0)
	move.l	(a4)+,4(a0)
	move.l	(a4)+,(a0)
	lea	32(a0),a0
	dbra	d0,kopieraallakanaler24
	lea	-4(a0),a6
blocketibuffernnuinverteratebaxdet:
	move.l	patterns,a4		; Ta redan p† aktuell pekare till
	moveq	#0,d1			; patternet
	move.w	lastsongpatt,d1
	asl.l	#8,d1
	asl.l	#3,d1
	add.l	d1,a4
	add.w	lastpos,a4

	move.w	d6,d0
	move.w	lastpos,d1
	lsr.w	#5,d1			; Testa s† att inte blocket blir
	move.w	d1,d2			; f”r stort
	add.w	d0,d2
	cmp.w	#$3F,d2
	ble.s	inomgr„nsenf”rinverterandet
	neg.w	d1
	add.w	#$3f,d1
	move.w	d1,d6
inomgr„nsenf”rinverterandet:

	tst.w	d7		; Alla?
	bne.s	fr†nbuffertillpattalla24
	moveq	#0,d1
	move.w	startkanal,d1
	subq.w	#1,d1		; Ta reda p† pekare till just den h„r
	add.w	d1,d1		; kanalen
	add.w	d1,d1
	add.l	d1,a4
	moveq	#0,d1
	bsr	vilkenaktivkanal
	add.l	d1,a4
	move.w	d6,d0
	move.l	a6,a0
	tst.w	wrtmode
	beq.s	orradit1pattern24
	cmp.w	#2,wrtmode
	bne.s	flyttaenkanaltillpatternet24
flyttaenkanaltillpatternet324:	; Flytta en kanal till patternet
	move.l	(a4),d5
	and.l	d4,d5
	bne.s	inteflyttaindatan324
	move.l	(a0),d5
	and.l	d4,d5
	and.l	d3,(a4)
	or.l	d5,(a4)
inteflyttaindatan324:
	lea	32(a4),a4
	lea	-32(a0),a0
	dbra	d0,flyttaenkanaltillpatternet324
	bra	finnsingetblockattinvertera
flyttaenkanaltillpatternet24:	; Flytta en kanal till patternet
	and.l	d3,(a4)
	move.l	(a0),d5
	and.l	d4,d5
	or.l	d5,(a4)
	lea	32(a4),a4
	lea	-32(a0),a0
	dbra	d0,flyttaenkanaltillpatternet24
	bra	finnsingetblockattinvertera
orradit1pattern24:
flyttaenkanaltillpatternet224:	; Flytta en kanal till patternet
	move.l	(a0),d5
	and.l	d4,d5
	beq.s	inteflyttaindatan24
	and.l	d3,(a4)
	or.l	d5,(a4)
inteflyttaindatan24:
	lea	32(a4),a4
	lea	-32(a0),a0
	dbra	d0,flyttaenkanaltillpatternet224
	bra	finnsingetblockattinvertera
fr†nbuffertillpattalla24:
	move.w	d6,d0
	move.l	a6,a0
	tst.w	wrtmode
	beq.s	flyttamedorrmod24
	cmp.w	#2,wrtmode
	bne.s	kopieraallakanalertillpatternet24
	mulu	#8,d0
kopieraallakanalertillpatternet324:	; Kopiera alla kanaler till patternet
	move.l	(a4),d5
	and.l	d4,d5
	bne.s	inteflyttaindennu324
	move.l	(a0),d5
	and.l	d4,d5
	and.l	d3,(a4)
	or.l	d5,(a4)
inteflyttaindennu324:
	subq.w	#4,a0
	addq.w	#4,a4
	dbra	d0,kopieraallakanalertillpatternet324
	bra.s	finnsingetblockattinvertera
kopieraallakanalertillpatternet24:; Kopiera alla kanaler till patternet
	rept	8
	and.l	d3,(a4)
	move.l	(a0),d5
	and.l	d4,d5
	or.l	d5,(a4)+
	subq.w	#4,a0
	endr
	dbra	d0,kopieraallakanalertillpatternet24
	bra.s	finnsingetblockattinvertera
flyttamedorrmod24:
	mulu	#8,d0
kopieraallakanalertillpatternet224:	; Kopiera alla kanaler till patternet
	move.l	(a0),d5
	and.l	d4,d5
	beq.s	inteflyttaindennu24
	and.l	d3,(a4)
	or.l	d5,(a4)
inteflyttaindennu24:
	subq.w	#4,a0
	addq.w	#4,a4
	dbra	d0,kopieraallakanalertillpatternet224
finnsingetblockattinvertera:
	rts


flyttablocket:				; Flyttar blocket
	jsr	copytoundobuffer
	tst.w	blockset
	beq	finnsingetblockattflytta
	move.l	patterns,a4		; Ta redan p† aktuell pekare till
	moveq	#0,d1			; patternet
	move.w	blockpattern,d1
	asl.l	#8,d1
	asl.l	#3,d1
	add.l	d1,a4
	tst.w	d7		; En shift?
	bne.s	flyttaallakanalertillbuffern
	moveq	#0,d1
	move.w	blockchannel,d1
	subq.w	#1,d1		; Ta reda p† pekare till just den h„r
	add.w	d1,d1		; kanalen
	add.w	d1,d1
	add.w	d1,a4
	move.w	blockstart,d0
	lsl.w	#5,d0
	add.w	d0,a4
	lea	blockbuffer,a0
	add.w	d1,a0
	move.w	blockend,d0
	sub.w	blockstart,d0
	move.l	a0,a6
	move.w	d0,d6
	tst.w	blockcollect
	bne.s	blocketibuffernnuflyttatebaxdet
flytta2enkanaltillbuffern:	; Flytta en kanal till buffern
	move.l	(a4),(a0)
	lea	32(a4),a4
	lea	32(a0),a0
	dbra	d0,flytta2enkanaltillbuffern
	bra.s	blocketibuffernnuflyttatebaxdet
flyttaallakanalertillbuffern:
	move.w	blockstart,d0
	lsl.w	#5,d0
	add.w	d0,a4
	move.w	blockend,d0
	sub.w	blockstart,d0
	lea	blockbuffer,a0
	move.l	a0,a6
	move.w	d0,d6
	tst.w	blockcollect
	bne.s	blocketibuffernnuflyttatebaxdet
flyttaallakanaler:		; Kopiera alla kanaler till buffern
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	dbra	d0,flyttaallakanaler
blocketibuffernnuflyttatebaxdet:

	bsr	rensablocket		; Rensa den gamla arean

	lea	blkdata,a2
	move.w	blkmode,d2
	add.w	d2,d2
	add.w	d2,d2
	move.l	(a2,d2.w),d3
	move.l	d3,d4		; d3 masken till rensningen av patternet
	not.l	d4		; d4 masken till datan som flyttas

	move.l	patterns,a4		; Ta redan p† aktuell pekare till
	moveq	#0,d1			; patternet
	move.w	lastsongpatt,d1
	asl.l	#8,d1
	asl.l	#3,d1
	add.l	d1,a4
	add.w	lastpos,a4

	move.w	d6,d0
;	add.w	blockstart,d0
	move.w	lastpos,d1
	lsr.w	#5,d1			; Testa s† att inte blocket blir
	move.w	d1,d2			; f”r stort
	add.w	d0,d2
	cmp.w	#$3f,d2
	ble.s	inomgr„nsenf”rflyttandet
	neg.w	d1
	add.w	#$3f,d1
	move.w	d1,d6
inomgr„nsenf”rflyttandet:

	tst.w	d7		; Alla?
	bne.s	fr†nbuffertillpattalla2
	moveq	#0,d1
	move.w	startkanal,d1
	subq.w	#1,d1		; Ta reda p† pekare till just den h„r
	add.w	d1,d1		; kanalen
	add.w	d1,d1
	add.l	d1,a4
	moveq	#0,d1
	bsr	vilkenaktivkanal
	add.l	d1,a4
	move.w	d6,d0
	move.l	a6,a0
	tst.w	wrtmode
	beq.s	orradit1pattern2
	cmp.w	#2,wrtmode
	bne.s	flyttaenkanaltillpatternet22
flyttaenkanaltillpatternet2223:	; Flytta en kanal till patternet
	move.l	(a4),d5
	and.l	d4,d5
	bne.s	inteflyttaindatan23
	move.l	(a0),d5
	and.l	d4,d5
	and.l	d3,(a4)
	or.l	d5,(a4)
inteflyttaindatan23:
	lea	32(a4),a4
	lea	32(a0),a0
	dbra	d0,flyttaenkanaltillpatternet2223
	bra	finnsingetblockattflytta
flyttaenkanaltillpatternet22:	; Flytta en kanal till patternet
	and.l	d3,(a4)
	move.l	(a0),d5
	and.l	d4,d5
	or.l	d5,(a4)
	lea	32(a4),a4
	lea	32(a0),a0
	dbra	d0,flyttaenkanaltillpatternet22
	bra	finnsingetblockattflytta
orradit1pattern2:
flyttaenkanaltillpatternet222:	; Flytta en kanal till patternet
	move.l	(a0),d5
	and.l	d4,d5
	beq.s	inteflyttaindatan2
	and.l	d3,(a4)
	or.l	d5,(a4)
inteflyttaindatan2:
	lea	32(a4),a4
	lea	32(a0),a0
	dbra	d0,flyttaenkanaltillpatternet222
	bra	finnsingetblockattflytta
fr†nbuffertillpattalla2:
	move.w	d6,d0
	move.l	a6,a0
	tst.w	wrtmode
	beq.s	flyttamedorrmod2
	cmp.w	#2,wrtmode
	bne.s	kopieraallakanalertillpatternet22
	mulu	#8,d0
kopieraallakanalertillpatternet2223:	; Kopiera alla kanaler till patternet
	move.l	(a4),d5
	and.l	d4,d5
	bne.s	inteflyttaindennu23
	move.l	(a0),d5
	and.l	d4,d5
	and.l	d3,(a4)
	or.l	d5,(a4)
inteflyttaindennu23:
	addq.w	#4,a0
	addq.w	#4,a4
	dbra	d0,kopieraallakanalertillpatternet2223
	bra.s	finnsingetblockattflytta
kopieraallakanalertillpatternet22:; Kopiera alla kanaler till patternet
	rept	8
	and.l	d3,(a4)
	move.l	(a0)+,d5
	and.l	d4,d5
	or.l	d5,(a4)+
	endr
	dbra	d0,kopieraallakanalertillpatternet22
	bra.s	finnsingetblockattflytta
flyttamedorrmod2:
	mulu	#8,d0
kopieraallakanalertillpatternet222:	; Kopiera alla kanaler till patternet
	move.l	(a0),d5
	and.l	d4,d5
	beq.s	inteflyttaindennu2
	and.l	d3,(a4)
	or.l	d5,(a4)
inteflyttaindennu2:
	addq.w	#4,a0
	addq.w	#4,a4
	dbra	d0,kopieraallakanalertillpatternet222
finnsingetblockattflytta:
	rts


sparablock:			; Spara ett aktivt block
	tst.w	blockset
	beq	intesparablockcancel
	tst.w	blockcollect
	bne	intesparablockcancel

	jsr	v„ntap†sl„pp2343434
	jsr	reinstallsystem 	; Installera systemet igen

	move.l	sp,dummen
	move.l	oldstack,-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa tebax till user
	addq.l	#6,sp

	jsr	forceredrawofGEMscreen
	lea	sblabel,a1
	lea	blkname,a2 		; Visa filv„ljaren
	lea	blkpath,a3
	jsr	fsel_exinput
	move.w	d0,dummen2
	move.w	d1,dummen2+2

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa upp i super
	addq.l	#6,sp
	move.l	dummen,sp

	jsr	myownsystem		; S„tt upp TRACKERsystemet
	tst.w	dummen2
	beq	gemerror
	tst.w	dummen2+2
	beq	intesparablockcancel

	lea	sample,a5
	move.w	#1100*3*2/4,d5
rensaspelbuffern6:			; Rensa playbuffern
	clr.l	(a5)+
	dbra	d5,rensaspelbuffern6

	move.b	#255,linestowait

	lea	blkpath,a0
	lea	blkname,a1
	bsr	makeawholename

	pea	dta2
	move.w	#$1a,-(sp)
	trap	#1		; S„tt r„tt dtabuffer
	addq.l	#6,sp
	clr.w	-(sp)
	pea	wholename
	move.w	#$4e,-(sp)
	trap	#1		; Leta efter filen
	addq.l	#8,sp
	tst.w	d0
	bne.s	filenotfoundthensavetheblock
	move.b	#199,linestowait
	lea	overwrite1,a5	; Fr†ga om jag verkligen skall spara
	lea	overwrite2,a6	; ”ver filen
	jsr	makeform
	move.b	#255,linestowait
	tst.w	d0
	bne.s	intesparablockcancel
filenotfoundthensavetheblock:
	clr.w	-(sp)
	pea	wholename
	move.w	#$3c,-(sp)
	trap	#1			; Skapa filen
	addq.w	#8,sp
	tst.l	d0
	bmi	couldnotcreatefile
	move.w	d0,handle

	lea	blockstart,a0
	moveq	#6,d0
	bsr	savethisblock		; Spara headern

	bsr.s	sparundanpatternet

	lea	blockbuffer,a0
	moveq	#0,d0
	move.w	d1,d0
	addq.w	#1,d0
	mulu	#32,d0
	bsr	savethisblock		; Spara blocket

	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1			; St„ng filen
	addq.w	#4,sp
	tst.w	d0
	bmi	kanejstanga
intesparablockcancel:
	move.b	#199,linestowait
	rts

sparundanpatternet:
	move.l	patterns,a4		; Ta redan p† aktuell pekare till
	moveq	#0,d1			; patternet
	move.w	blockpattern,d1
	asl.l	#8,d1
	asl.l	#3,d1
	add.l	d1,a4
	move.w	blockstart,d0
	lsl.w	#5,d0
	add.w	d0,a4
	move.w	blockend,d0
	sub.w	blockstart,d0
	lea	blockbuffer,a0
	move.w	d0,d1
kopieraallakanaler3:		; Kopiera alla kanaler till buffern
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	dbra	d0,kopieraallakanaler3
	rts

laddablock:			; Laddar in ett sparat block
	jsr	v„ntap†sl„pp2343434
	jsr	reinstallsystem 	; Installera systemet igen

	move.l	sp,dummen
	move.l	oldstack,-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa tebax till user
	addq.l	#6,sp

	jsr	forceredrawofGEMscreen
	lea	lblabel,a1
	lea	blkname,a2 		; Visa filv„ljaren
	lea	blkpath,a3
	jsr	fsel_exinput
	move.w	d0,dummen2
	move.w	d1,dummen2+2

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa upp i super
	addq.l	#6,sp
	move.l	dummen,sp

	jsr	myownsystem		; S„tt upp TRACKERsystemet
	tst.w	dummen2
	beq	gemerror
	tst.w	dummen2+2
	beq	inteladdablockcancel

	lea	sample,a5
	move.w	#1100*3*2/4,d5
rensaspelbuffern7:			; Rensa playbuffern
	clr.l	(a5)+
	dbra	d5,rensaspelbuffern7

	move.b	#255,linestowait

	lea	blkpath,a0
	lea	blkname,a1
	bsr	makeawholename

	pea	dta2
	move.w	#$1a,-(sp)
	trap	#1		; S„tt r„tt dtabuffer
	addq.l	#6,sp
	clr.w	-(sp)
	pea	wholename
	move.w	#$4e,-(sp)
	trap	#1		; Leta efter filen
	addq.l	#8,sp
	tst.w	d0
	bne	filenotfoundthenloading

	move.b	#255,linestowait

	clr.w	-(sp)
	pea	wholename
	move.w	#$3d,-(sp)
	trap	#1			; ™ppna blk-filen
	addq.l	#8,sp
	tst.l	d0
	bmi	kanejoppna
	move.w	d0,handle

	moveq	#6,d0
	lea	blockstart,a0		; Ladda headern
	bsr	loadthisblock
	tst.w	d0
	bpl.s	intefelvidl„sningavblock1
	bsr	blockhide
	bra.s	inteladdablockcancel
intefelvidl„sningavblock1:

	lea	blockbuffer,a0
	moveq	#0,d0
	move.w	blockend,d0
	sub.w	blockstart,d0
	addq.w	#1,d0			; Ladda blocket
	mulu	#32,d0
	bsr	loadthisblock
	tst.w	d0
	bpl.s	intefelvidl„sningavblock2
	bsr	blockhide
	bra.s	inteladdablockcancel
intefelvidl„sningavblock2:

	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1			; St„ng filen
	addq.w	#4,sp
	tst.w	d0
	bmi	kanejstanga
	move.w	#1,blockset
	move.w	#1,blockcollect
inteladdablockcancel:
	move.b	#199,linestowait
	bsr	outputblockstatus
	rts



blockstart:
	dc.w	0		; Start
blockend:
	dc.w	$3F		; End
blockchannel:
	dc.w	1		; Vilken kanal som blocket markerades i
blockpattern:
	dc.w	0
blockset:
	dc.w	0		; Om 1 „r blocket satt
blockcollect:
	dc.w	0		; Om 0 skall blocket f”rst till buffern
				; sen till dest.
				; Om 1 skall blocket direkt till dest.
blockbuffer:
	ds.l	8*64

noneblock:
	dc.b	'NONE   ',0	; Om blocket „r tomt
blockstatus:
	dc.b	'00-00:0',0	; H„r matas talen in
				; Efter : finns endera kanalangivelsen 1-8
				; eller M om blocket finns i minnet (vid laddning)
charascii:
	dc.b	'0123456789ABCDEF'
	even

converttoascii:			; d0 talet    a0 pekaren till str„ngen
	move.w	d0,d1		; Convertera en byte till en asciistr„ng
	and.w	#$F0,d0
	and.w	#$0F,d1
	lsr.w	#4,d0
	lea	charascii,a1
	move.b	(a1,d0.w),(a0)+
	move.b	(a1,d1.w),(a0)+	
	rts

calccursorplace:		; Placera cursorn d„r vi tryckte med
	cmp.w	editx,d6	; musen
	bgt.s	st”rre„neditx
	clr.w	cursor
	rts
st”rre„neditx:
	move.w	editx,d0
	move.w	maxstr„ngl„ngd,d1
	lsl.w	#3,d1
	add.w	d1,d0
	cmp.w	d0,d6
	bls.s	mindre„nallt
	move.w	maxstr„ngl„ngd,cursor
	rts
mindre„nallt:
	sub.w	editx,d6
	lsr.w	#3,d6
	move.w	d6,cursor
	rts

ritautsongsampleval:
	moveq	#8-1,d7
loopagjij:
	move.l	(a2),(a3)
	move.l	8(a2),8(a3)
	move.l	16(a2),16(a3)
	move.l	24(a2),24(a3)
	move.l	32(a2),32(a3)
	move.l	40(a2),40(a3)
	move.l	48(a2),48(a3)
	move.l	56(a2),56(a3)
	move.l	64(a2),64(a3)
	move.l	72(a2),72(a3)
	move.l	80(a2),80(a3)
	move.l	88(a2),88(a3)
	move.l	96(a2),96(a3)
	move.l	104(a2),104(a3)
	move.l	112(a2),112(a3)
	move.l	120(a2),120(a3)
	move.l	128(a2),128(a3)
	lea	168(a3),a3
	lea	136(a2),a2
	dbra	d7,loopagjij
	rts

sparsongsampleval:
	moveq	#8-1,d7
loopspargjij:
	move.l	(a2),(a3)
	move.l	8(a2),8(a3)
	move.l	16(a2),16(a3)
	move.l	24(a2),24(a3)
	move.l	32(a2),32(a3)
	move.l	40(a2),40(a3)
	move.l	48(a2),48(a3)
	move.l	56(a2),56(a3)
	move.l	64(a2),64(a3)
	move.l	72(a2),72(a3)
	move.l	80(a2),80(a3)
	move.l	88(a2),88(a3)
	move.l	96(a2),96(a3)
	move.l	104(a2),104(a3)
	move.l	112(a2),112(a3)
	move.l	120(a2),120(a3)
	move.l	128(a2),128(a3)
	lea	168(a2),a2
	lea	136(a3),a3
	dbra	d7,loopspargjij
	rts

bytsongsample:	; Shiftar mellan o visa songnamn o samplingsnummer
	not.w	showthebloodysongname

	move.l	bildminne,a2
	lea	(74*168)+8(a2),a3	; a3 till bilden
	add.l	#101056+2128,a2		; a2 till menyn
	tst.w	showthebloodysongname
	bne.s	daxattvisasamplemenyn
	addq.w	#4,a2
daxattvisasamplemenyn:
	bsr	ritautsongsampleval

	tst.w	showthebloodysongname
	bne.s	ret3
	lea	songname,a3		; Pekare till str„ng
	move.w	#80,d0			; x		Songnamn
	move.w	#75,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen
ret3:	rts

showthebloodysongname:	; 0 visar songnamnet     1 visar samplingar
	dc.w	0

editsongname:			; Editera songnamnet
	tst.w	showthebloodysongname
	beq	b”rjaediterasongnamnet
	cmp.l	#colorkoors,losapositioner
	beq.s	ret3
	cmp.l	#optionskoors,losapositioner
	beq.s	ret3
	cmp.l	#numpattskoors,losapositioner
	beq.s	ret3
	cmp.l	#termodykoors,losapositioner
	beq.s	ret3
	cmp.l	#selectshowpattkoors,losapositioner
	beq.s	ret3

	move.w	d6,d0
	sub.w	#$58,d0
	bpl.s	forfarandetillr„ckligtstort
	moveq	#0,d0
forfarandetillr„ckligtstort:
	and.w	#$FF,d0
	divu	#6,d0
	cmp.w	#$20,d0
	blo.s	intest”rre„nmaxspl
	moveq	#$1F,d0
intest”rre„nmaxspl:
	move.w	d0,whichsample
	lea	whichsample+1,a3	; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#49,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	jsr	skrivuthex		; Skriv ut i hex
	jsr	skrivuttillhorandeinfo
	jsr	checkifsamplechanged
	rts
b”rjaediterasongnamnet:
	move.l	bildminne,oldcursor
	move.w	#80+16,editx
	move.w	#75,edity
	clr.w	cursorblink
	move.w	#19,maxstr„ngl„ngd
	bsr	calccursorplace
	lea	songname,a0
	lea	str„ng,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	bsr	editeraenstr„ng

	lea	songname,a1
	lea	str„ng,a0
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	rts

editsamplename:			; Editera samplingsnamnet
	tst.w	whichsample
	beq.s	inte„ndraeftersomdet„r0an11
	move.l	bildminne,oldcursor
	move.w	#80+16,editx
	move.w	#85,edity
	clr.w	cursorblink
	move.w	#21,maxstr„ngl„ngd
	bsr	calccursorplace
	moveq	#0,d0
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsamsave,d0
	move.l	d0,a0
	lea	str„ng,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)+

	bsr.s	editeraenstr„ng

	moveq	#0,d0
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsamsave,d0
	move.l	d0,a1
	lea	str„ng,a0
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
inte„ndraeftersomdet„r0an11:
	rts

extracol:
	ds.w	16

editeraenstr„ng:
	move.w	#$8240,a0
	lea	extracol,a1		; Spara f„rgerna
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.w	#$8240,a1
	lea	texteditpalette,a0	; Ladda upp f„rgerna
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+


	move.w	#1,cursoronoff		; S„tt p† cursorn
	jsr	waittwovbls

huvudtexteditloop:
	btst.b	#0,mkey			; H”ger musknapp nertryckt?
	bne	enreturnhoppaureditmoden

	bsr	testas†oftasomm”jligt	; Skriv ut tid o patternpos.
	jsr	ritapatternettrashat

	jsr	isakeyready
	beq.s	huvudtexteditloop
	jsr	getkeywithasciiandshifts
	move.l	d0,d7

	swap	d7

	cmp.b	#$4b,d7			; V„nster
	bne.s	inte†tv„nstermedcursor
	tst.w	cursor
	beq.s	inte†tv„nstermedcursor
	subq.w	#1,cursor
	bra	skrivutdet„nd†
inte†tv„nstermedcursor:
	cmp.b	#$4d,d7			; H”ger
	bne.s	inte†th”germedcursor
	move.w	cursor,d0
	cmp.w	maxstr„ngl„ngd,d0
	bge.s	inte†th”germedcursor
	addq.w	#1,cursor
	bra	skrivutdet„nd†
inte†th”germedcursor:
	cmp.b	#$e,d7			; Backspace
	bne.s	inteenbackspaceistr„ngen
	tst.w	cursor
	beq.s	inteenbackspaceistr„ngen
	move.w	cursor,d0
	cmp.w	maxstr„ngl„ngd,d0
	bge.s	befinnersigp†max
	subq.w	#1,cursor
	bra.s	deleteskitennu
befinnersigp†max:		; Om l„ngst ut till h”ger i str„ngen,
	subq.w	#1,cursor	; f”r d† bara in en space
	lea	str„ng,a0
	add.w	maxstr„ngl„ngd,a0
	clr.b	(a0)
	move.b	#' ',-1(a0)
	bra	skrivutdet„nd†
inteenbackspaceistr„ngen:
	cmp.b	#$53,d7			; Delete
	bne.s	inteendeleteistr„ngen
deleteskitennu:
	move.w	cursor,d0
	move.w	maxstr„ngl„ngd,d1
	sub.w	d0,d1
	subq.w	#1,d1
	ble.s	ingenstr„ngattdeleta
	subq.w	#1,d1
	lea	str„ng,a0
	add.w	cursor,a0
koppastr„ngen†tv„nster:
	move.b	1(a0),(a0)
	addq.w	#1,a0				; Flytta det som „r †t h”ger i
	dbra	d1,koppastr„ngen†tv„nster	; f”rh†llande till cursorn
	lea	str„ng,a0			; ett steg †t v„nster
	add.w	maxstr„ngl„ngd,a0
	clr.b	(a0)
	move.b	#' ',-1(a0)
ingenstr„ngattdeleta:
	bra.s	skrivutdet„nd†
inteendeleteistr„ngen:

	swap	d7

	cmp.b	#13,d7
	beq	enreturnhoppaureditmoden

	cmp.w	#32,d7
	blt.s	inteenvanligf”rst†ligtangent

	move.w	cursor,d0
	cmp.w	maxstr„ngl„ngd,d0	; Kan vi mata in ett till tecken?
	bge.s	redanmaxl„ngd

	move.w	maxstr„ngl„ngd,d1
	sub.w	d0,d1
	beq.s	ingenstr„ngattinserta
	subq.w	#1,d1
	lea	str„ng,a0
	add.w	maxstr„ngl„ngd,a0
	subq.w	#1,a0
koppastr„ngen†th”ger:
	move.b	-1(a0),(a0)
	subq.w	#1,a0			; Flytta det som „r †t h”ger i
	dbra	d1,koppastr„ngen†th”ger	; f”rh†llande till kursorn
ingenstr„ngattinserta:			; ett steg †t h”ger
	lea	str„ng,a0
	add.w	maxstr„ngl„ngd,a0
	clr.b	(a0)
	lea	str„ng,a0
	add.w	cursor,a0
	move.b	d7,(a0)			; Flytta in tecknet i str„ngen
	addq.w	#1,cursor

skrivutdet„nd†:
	bsr.s	removecursor
	lea	str„ng,a3
	move.w	editx,d0 		; x
	sub.w	#16,d0
	move.w	edity,d1		; y
	jsr	skrivuttext		; Skriv ut textstr„ngen
	clr.w	cursorblink
redanmaxl„ngd:
inteenvanligf”rst†ligtangent:


	bra	huvudtexteditloop
enreturnhoppaureditmoden:


	clr.w	cursoronoff		; St„ng av cursorn
	bsr.s	removecursor

	move.w	#$8240,a1
	lea	extracol,a0		; Ladda upp f„rgerna
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	rts

removecursor:
	move.l	oldcursor,a0
	clr.b	(a0)
	clr.b	168(a0)
	clr.b	336(a0)
	clr.b	504(a0)
	clr.b	672(a0)
	clr.b	840(a0)
	rts

str„ng:	ds.b	30
maxstr„ngl„ngd:
	dc.w	0
editx:	dc.w	0
edity:	dc.w	0
cursor:	dc.w	0
oldcursor:
	dc.l	0
cursoronoff:
	dc.w	0
cursorblink:
	dc.w	0


ingetminnekvar:
	lea	slutirutantext,a1
	moveq	#1,d1			; Slut p† minne
	jsr	form_alert

	jsr	appl_exit

	clr.w	-(sp)
	trap	#1

slutirutantext:
	dc.b	'[1][Out of internal Memory!|Octalyser cannot start!][   Ok   ]',0
	even

testaomsteellermegasteellertt:
	tst.l	$5a0.w
	beq	inteensenSTE
	move.l	$5a0.w,a0
k”rvidareochtestan„stakaka:
	tst.l	(a0)
	beq	inteensenSTE
	cmp.l	#'Gnva',(a0)
	beq.s	Genevafinns
	cmp.l	#'MiNT',(a0)
	bne.s	mint„rinteinstallerat
Genevafinns:
	move.w	#1,MiNTispresent
mint„rinteinstallerat:
	cmp.l	#'_MCH',(a0)
	bne.s	intedennakaka
	cmp.w	#1,4(a0)		; Om 6(a0) == $10, „r det en MSTE
	beq.s	godk„nddator
	cmp.w	#3,4(a0)
	bge.s	falconellernyare
	bra.s	inteensenSTE
intedennakaka:
	addq.l	#8,a0
	bra.s	k”rvidareochtestan„stakaka
falconellernyare: 
	move.w	#1,hblisallreadyused
	move.w	#0,falkrun		; Falconmode p†!
	move.b	$ffff8006.w,d0
	btst	#6,d0
	beq.s	.VGA	; eller beq?
	move.w	#-1,VGArun
	bra.s	forts„ttletaefterMiNT
.VGA
	move.w	#0,VGArun
	bra.s	forts„ttletaefterMiNT

MiNTispresent:
	dc.w	0

godk„nddator:
	btst.b	#1,$ffff820a.w
	bne.s	inte60Hzp†enSTE
	clr.w	run60Hz
inte60Hzp†enSTE:
forts„ttletaefterMiNT:
	tst.l	(a0)
	beq.s	f„rdigletatf”ridag
	cmp.l	#'Gnva',(a0)
	beq.s	Genevafinns2
	cmp.l	#'MiNT',(a0)
	bne.s	mint„rinteinstallerat2
Genevafinns2:
	move.w	#1,MiNTispresent
mint„rinteinstallerat2:
	addq.l	#8,a0
	bra.s	forts„ttletaefterMiNT
f„rdigletatf”ridag:
	rts

inteensenSTE:
	lea	erroringenSTE,a1
	moveq	#1,d1			; Ingen STE
	jsr	form_alert
	move.l	(sp)+,d0
	clr.w	-(sp)
	trap	#1
erroringenSTE:
	dc.b	'[1][Not a STE or Falcon-computer!|Octalyser cannot start.][   Ok   ]',0
	even

baraenrts:
	rts

afterthesetting:		; Rutinen som utf”rs efter att jag sl„ppt
	dc.l	0		; musknappen

blaster:dc.l	0,0,0,0,0

insertinpattern:		; d0=0 endast aktuell kanal   d0=1 hela patternet
	lea	blkdata,a2
	move.w	bsmode,d2
	add.w	d2,d2
	add.w	d2,d2
	move.l	(a2,d2.w),d3
	move.l	d3,d4		; d3 masken till rensningen av patternet
	not.l	d4		; d4 masken till datan som flyttas
	tst.w	d0
	beq.s	enkanalsinsert
	bsr	r„knauthelapatternpekare	; Hela patternet
	subq.w	#1,d1
	bmi.s	baraattrensaalladessakanaler
	move.l	a5,a1
	lea	32(a1),a0
flyttaflerakanalerner†t:
	rept	8
	and.l	d3,-(a0)
	move.l	-(a1),d5
	and.l	d4,d5
	or.l	d5,(a0)
	endr
	dbra	d1,flyttaflerakanalerner†t
baraattrensaalladessakanaler:
	rept	8
	and.l	d3,(a4)+
	endr
	rts
enkanalsinsert:
	bsr.s	r„knautenkanalspekare		; Aktuell kanal
	subq.w	#1,d1
	bmi.s	baraattrensadennakanal
	move.l	a5,a0
flyttaenkanalner†t:
	and.l	d3,(a0)
	move.l	-32(a0),d5
	and.l	d4,d5
	or.l	d5,(a0)
	lea	-32(a0),a0
	dbra	d1,flyttaenkanalner†t
baraattrensadennakanal:
	and.l	d3,(a4)
	rts

r„knautenkanalspekare:		; a4 retunerar pekare  d0 aktuell pos
	move.l	patterns,a4	; d1 steg kvar till slutet  a5 pekare till slutet av patternet
	moveq	#0,d1
	move.w	lastsongpatt,d1
	asl.l	#8,d1
	asl.l	#3,d1
	add.l	d1,a4
	moveq	#0,d1
	move.w	startkanal,d1
	subq.w	#1,d1
	add.w	d1,d1
	add.w	d1,d1
	add.l	d1,a4
	move.l	a4,a5
	moveq	#0,d1
	move.w	lastpos,d1
	add.l	d1,a4
	bsr	vilkenaktivkanal
	add.l	d1,a4
	add.l	d1,a5
	lea	$800-$20(a5),a5

	moveq	#0,d0
	move.w	lastpos,d0
	lsr.w	#5,d0
	move.l	d0,d1
	neg.w	d1
	add.w	#64,d1
	rts

r„knauthelapatternpekare:	; a4 retunerar pekare  d0 aktuell pos
	move.l	patterns,a4	; d1 steg kvar till slutet  a5 pekare till slutet av patternet
	moveq	#0,d1
	move.w	lastsongpatt,d1
	asl.l	#8,d1
	asl.l	#3,d1
	add.l	d1,a4
	moveq	#0,d1
	move.w	startkanal,d1
	subq.w	#1,d1
	add.w	d1,d1
	add.w	d1,d1
	add.l	d1,a4
	move.l	a4,a5
	moveq	#0,d1
	move.w	lastpos,d1
	add.l	d1,a4
	lea	$800-$20(a5),a5

	moveq	#0,d0
	move.w	lastpos,d0
	lsr.w	#5,d0
	move.l	d0,d1
	neg.w	d1
	add.w	#64,d1
	rts




deleteinpattern:		; d0=0 endast aktuell kanal   d0=1 hela patternet
	lea	blkdata,a2
	move.w	bsmode,d2
	add.w	d2,d2
	add.w	d2,d2
	move.l	(a2,d2.w),d3
	move.l	d3,d4		; d3 masken till rensningen av patternet
	not.l	d4		; d4 masken till datan som flyttas
	tst.w	d0
	beq.s	enkanalsdelete
	bsr.s	r„knauthelapatternpekare	; Hela patternet
	subq.w	#1,d1
	bmi.s	baraattrensaallakanalerna
	move.l	a4,a0
	lea	32(a0),a1
flyttaallakanalerupp†t:
	rept	8
	and.l	d3,(a0)
	move.l	(a1)+,d5
	and.l	d4,d5
	or.l	d5,(a0)+	
	endr
	dbra	d1,flyttaallakanalerupp†t
baraattrensaallakanalerna:
	rept	8
	and.l	d3,(a5)+
	endr
	rts
enkanalsdelete:
	bsr	r„knautenkanalspekare		; Aktuell kanal
	subq.w	#1,d1
	bmi.s	baraattrensaenkanal
	move.l	a4,a0
flyttaenkanalupp†t:
	and.l	d3,(a0)
	move.l	32(a0),d5
	and.l	d4,d5
	or.l	d5,(a0)
	lea	32(a0),a0
	dbra	d1,flyttaenkanalupp†t
baraattrensaenkanal:
	and.l	d3,(a5)
	rts


rensaaktuelltpattern:
	jsr	copytoundobuffer
	lea	blkdata,a2
	move.w	bsmode,d2
	add.w	d2,d2
	add.w	d2,d2
	move.l	(a2,d2.w),d3
	move.l	d3,d4		; d3 masken till rensningen av patternet
	not.l	d4		; d4 masken till datan som flyttas
	move.l	patterns,a4		; Ta redan p† aktuell pekare till
	moveq	#0,d1			; patternet
	move.w	lastsongpatt,d1
	asl.l	#8,d1
	asl.l	#3,d1
	add.l	d1,a4
	tst.w	d7		; En shift?
	bne.s	enshiftF3
	moveq	#0,d1
	move.w	startkanal,d1
	subq.w	#1,d1		; Ta reda p† pekare till just den h„r
	add.w	d1,d1		; kanalen
	add.w	d1,d1
	add.l	d1,a4
	moveq	#0,d1
	bsr	vilkenaktivkanal
	add.l	d1,a4
	moveq	#64-1,d0
rensaenkanalbara:		; Rensa hela kanalen
	and.l	d3,(a4)
	lea	32(a4),a4
	dbra	d0,rensaenkanalbara
	rts
enshiftF3:
	moveq	#64-1,d0
rensaallakanaler:		; Rensa hela patternet
	and.l	d3,(a4)+
	and.l	d3,(a4)+
	and.l	d3,(a4)+
	and.l	d3,(a4)+
	and.l	d3,(a4)+
	and.l	d3,(a4)+
	and.l	d3,(a4)+
	and.l	d3,(a4)+
	dbra	d0,rensaallakanaler
	rts




chfreq:
	tst.w	freqonkeyboard
	beq.s	komigenda		; Žndra freq p† tangentbordet
	clr.w	freqonkeyboard
	lea	freqonit,a3
	bra.s	sattuppfreqonkey
komigenda:
	lea	freqonit+2,a3
	move.w	#1,freqonkeyboard
sattuppfreqonkey:
	move.w	#48,d0			; x
	move.w	#97,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen
	moveq	#0,d0
	rts

chwrt:
	addq.w	#1,wrtmode
	cmp.w	#2,wrtmode
	ble.s	komigenda1		; Žndra skrivmode f”r blocket
	clr.w	wrtmode
komigenda1:
	lea	wrtonit,a3
	move.w	wrtmode,d0
	lsl.w	#1,d0
	add.w	d0,a3
	move.w	#192,d0			; x
	move.w	#97,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen
	moveq	#0,d0
	rts

enteratone:
	bsr	gepekaretillpos
	tst.w	freqonkeyboard
	beq.s	lagtonattskriva
	lea	highfreq,a0
	bra.s	hogtonattskriva
lagtonattskriva:
	lea	lowfreq,a0
hogtonattskriva:
	moveq	#0,d1		; Skriv en H”g ton till aktuellt pattern
	swap	d0
	move.b	d0,d1
	add.w	d1,d1
	move.w	0(a0,d1.w),d1
	beq	rd
	cmp.w	#$F,whichsample
	ble.s	inteenstorsampling
	or.w	#$1000,d1
inteenstorsampling:
	move.w	whichsample,d2
	and.b	#$F,d2
	lsl.b	#4,d2
	tst.l	edit
	beq.s	skrivbaratillshorty
	tst.w	edmode
	bne.s	inteeditmode0
	and.w	#%1111000000000000,(a4)
	and.w	#%111111111111,d1
	or.w	d1,(a4)
	bra.s	skrivbaratillshorty
inteeditmode0:
	cmp.w	#1,edmode
	bne.s	inteeditmode1
	and.l	#%111111111111,(a4)
	or.w	d1,(a4)
	or.b	d2,2(a4)
	bra.s	skrivbaratillshorty
inteeditmode1:
	cmp.w	#2,edmode
	bne.s	inteeditmode2
	clr.l	(a4)
	or.w	d1,(a4)
	move.b	d2,2(a4)
	bra.s	skrivbaratillshorty
inteeditmode2:
	cmp.w	#3,edmode
	bne.s	inteeditmode3
	clr.l	(a4)
	or.w	d1,(a4)
	or.w	#$C,d2
	move.b	d2,2(a4)
	moveq	#0,d0
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsamsave,d0
	move.l	d0,a0
	move.b	25(a0),3(a4)
inteeditmode3:
skrivbaratillshorty:
	clr.l	(a5)
	or.w	d1,(a5)
	move.b	d2,2(a5)
	bra.s	rds

rd:	moveq	#0,d0
	rts

rds:
	tst.l	edit
	beq.s	rd
	moveq	#1-1,d7			; Antal rader
	move.w	speed,d1
	lsr.w	#1,d1			; 50%s chans u know!
	cmp.w	counter,d1
	bge.s	inte12333
	move.l	patterns,a4		; Pekaren till patternet
	moveq	#0,d0
	move.w	whichpatt,d0
	asl.l	#8,d0
	asl.l	#3,d0
	add.l	d0,a4
	add.w	pattpos,a4
	tst.l	fulleditorpek
	beq.s	laddaupp8editorn2
	move.l	fulleditorpek,a6
	bra.s	klarrrrrrrrrrrt2
laddaupp8editorn2:
	move.l	editorpek,a6
klarrrrrrrrrrrt2:
	move.w	pattpos,d0
	lsr.w	#5,d0
	mulu	#6*160,d0
	add.l	d0,a6
	bra.s	k”rp†mera
inte12333:
	move.l	patterns,a4		; Pekaren till patternet
	moveq	#0,d0
	move.w	lastsongpatt,d0
	asl.l	#8,d0
	asl.l	#3,d0
	add.l	d0,a4
	add.w	lastpos,a4
	tst.l	fulleditorpek
	beq.s	laddaupp8editorn3
	move.l	fulleditorpek,a6
	bra.s	klarrrrrrrrrrrt3
laddaupp8editorn3:
	move.l	editorpek,a6
klarrrrrrrrrrrt3:
	move.w	pattpos,d0
	lsr.w	#5,d0
	mulu	#6*160,d0
	add.l	d0,a6
k”rp†mera:
	tst.l	fulleditorpek
	bne.s	ritautdenh„rraden
	tst.l	editorpek
	beq.s	gl”mallt
	tst.w	falkrun
	bne.s	ritautdenh„rraden
	addq.l	#2,a6			; ()()() Nu uppdateras en patternrad p† r„tt bitplan
ritautdenh„rraden:
	jsr	skrivutenvissradifulleditmode
gl”mallt:
	tst.l	playplay
	bne	rd
	moveq	#0,d0
	move.w	stepswhenpressing,d0
	lsl.l	#5,d0
	add.w	d0,pattpos		; Addera steppen till pos
	cmp.w	#$800-$20,pattpos
	ble	rd
	sub.w	#$800,pattpos
	bra	rd

sl:
	tst.l	edit
	beq	rd
	bsr	gepekaretillpos 	; H„r skriver vi dit l†gdelen av
	cmp.b	#'0',d0 		; samplingen till patternet
	blt	rd	; Inte ens en bokstav el. siffre
	cmp.b	#'9',d0
	bgt.s	enbokstavkanske
	and.w	#$0FFF,2(a4)
	sub.w	#'0',d0
	and.l	#$f,d0
	swap	d0
	lsr.l	#4,d0
	or.w	d0,2(a4)
	bra	rds
enbokstavkanske:
	cmp.b	#'A',d0
	blt	rd
	cmp.b	#'F',d0
	bgt	rd
	and.w	#$0FFF,2(a4)
	sub.w	#'A'-10,d0
	and.l	#$f,d0
	swap	d0
	lsr.l	#4,d0
	or.w	d0,2(a4)
	bra	rds

kr:
	tst.l	edit
	beq	rd
	bsr	gepekaretillpos 	; H„r skriver vi dit kommandot
	cmp.b	#'0',d0 		; till patternet
	blt	rd	; Inte ens en bokstav el. siffre
	cmp.b	#'9',d0
	bgt.s	enbokstavkanske2
	and.w	#$F0FF,2(a4)
	sub.w	#'0',d0
	and.l	#$f,d0
	swap	d0
	lsr.l	#8,d0
	or.w	d0,2(a4)
	bra	rds
enbokstavkanske2:
	cmp.b	#'A',d0
	blt	rd
	cmp.b	#'F',d0
	bgt	rd
	and.w	#$F0FF,2(a4)
	sub.w	#'A'-10,d0
	and.l	#$f,d0
	swap	d0
	lsr.l	#8,d0
	or.w	d0,2(a4)
	bra	rds

hd:
	tst.l	edit
	beq	rd
	bsr	gepekaretillpos 	; H„r skriver vi dit h”gdelen av
	cmp.b	#'0',d0 		; kommandodatan till patternet
	blt	rd	; Inte ens en bokstav el. siffre
	cmp.b	#'9',d0
	bgt.s	enbokstavkanske3
	and.w	#$FF0F,2(a4)
	sub.w	#'0',d0
	and.l	#$f,d0
	lsl.l	#4,d0
	or.w	d0,2(a4)
	bra	rds
enbokstavkanske3:
	cmp.b	#'A',d0
	blt	rd
	cmp.b	#'F',d0
	bgt	rd
	and.w	#$FF0F,2(a4)
	sub.w	#'A'-10,d0
	and.l	#$f,d0
	lsl.l	#4,d0
	or.w	d0,2(a4)
	bra	rds

ld:
	tst.l	edit
	beq	rd
	bsr.s	gepekaretillpos 	; H„r skriver vi dit l†gdelen av
	cmp.b	#'0',d0 		; kommandodatan till patternet
	blt	rd	; Inte ens en bokstav el. siffre
	cmp.b	#'9',d0
	bgt.s	enbokstavkanske4
	and.w	#$FFF0,2(a4)
	sub.w	#'0',d0
	and.l	#$f,d0
	or.w	d0,2(a4)
	bra	rds
enbokstavkanske4:
	cmp.b	#'A',d0
	blt	rd
	cmp.b	#'F',d0
	bgt	rd
	and.w	#$FFF0,2(a4)
	sub.w	#'A'-10,d0
	and.l	#$f,d0
	or.w	d0,2(a4)
	bra	rds

endast1e0:
	tst.l	edit
	beq	rd
	bsr.s	gepekaretillpos 	; H„r skriver vi dit en 1 eller 0
	cmp.b	#'0',d0 		; i h”gdelen av samplingen till
	bne.s	skrivintediten0i1e0	; patternet
	and.w	#$0FFF,(a4)
	bra	rds
skrivintediten0i1e0:
	cmp.b	#'1',d0
	bne	rd
	or.w	#$1000,(a4)
	bra	rds

gepekaretillpos:
	tst.l	playplay
	beq.s	inte123
	tst.w	edit
	beq.s	inte123
				; Opps, vi skall r„kna med 50%!!!
	move.w	speed,d1
	lsr.w	#1,d1
	cmp.w	counter,d1
	bge.s	inte123

	lea	shortpattern,a5
	moveq	#0,d1
	move.w	startkanal,d1
	subq.w	#1,d1
	add.w	d1,d1
	add.w	d1,d1
	add.l	d1,a5
	bsr	vilkenaktivkanal
	add.l	d1,a5
	move.l	patterns,a4		; Ta redan p† aktuell pekare till
	moveq	#0,d1			; patternet
	move.w	whichpatt,d1
	asl.l	#8,d1
	asl.l	#3,d1
	add.l	d1,a4
	moveq	#0,d1
	move.w	startkanal,d1
	subq.w	#1,d1
	add.w	d1,d1
	add.w	d1,d1
	add.l	d1,a4
	moveq	#0,d1
	move.w	pattpos,d1
	add.l	d1,a4
	bsr.s	vilkenaktivkanal
	add.l	d1,a4
	rts
inte123:
	lea	shortpattern,a5
	moveq	#0,d1
	move.w	startkanal,d1
	subq.w	#1,d1
	add.w	d1,d1
	add.w	d1,d1
	add.l	d1,a5
	bsr.s	vilkenaktivkanal
	add.l	d1,a5
	move.l	patterns,a4		; Ta redan p† aktuell pekare till
	moveq	#0,d1			; patternet
	move.w	lastsongpatt,d1
	asl.l	#8,d1
	asl.l	#3,d1
	add.l	d1,a4
	moveq	#0,d1
	move.w	startkanal,d1
	subq.w	#1,d1
	add.w	d1,d1
	add.w	d1,d1
	add.l	d1,a4
	moveq	#0,d1
	move.w	lastpos,d1
	add.l	d1,a4
	bsr.s	vilkenaktivkanal
	add.l	d1,a4
	rts

vilkenaktivkanal:
	cmp.w	#5,cursorx
	bgt.s	inteforstakanalen
	moveq	#0,d1
	rts
inteforstakanalen:
	cmp.w	#11,cursorx
	bgt.s	inteandrakanalen
	moveq	#4,d1
	rts
inteandrakanalen:
	cmp.w	#17,cursorx
	bgt.s	intetredjekanalen
	moveq	#8,d1
	rts
intetredjekanalen:
	moveq	#12,d1
	rts


addstep:
	cmp.w	#$3f,stepswhenpressing
	beq.s	ingaflersteps
	addq.w	#1,stepswhenpressing
	lea	stepswhenpressing+1,a3	; Vilket tal skall konverteras
	move.w	#96,d0			; x
	move.w	#97,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
ingaflersteps:
	rts

substep:
	tst.w	stepswhenpressing
	beq.s	ingafarresteps
	subq.w	#1,stepswhenpressing
	lea	stepswhenpressing+1,a3	; Vilket tal skall konverteras
	move.w	#96,d0			; x
	move.w	#97,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
ingafarresteps:
	rts

;=========================================================== DISKrutiner ==

deleteafile:				; Ta bort en fil
	move.w	$ffff8900.w,gammalfart
	jsr	v„ntap†sl„pp2343434
	jsr	reinstallsystem 	; Installera systemet igen

	move.l	sp,dummen
	move.l	oldstack,-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa tebax till user
	addq.l	#6,sp

	jsr	forceredrawofGEMscreen
	lea	dellabel,a1
	lea	delname,a2 		; Visa filv„ljaren
	lea	delpath,a3
	jsr	fsel_exinput
	move.w	d0,dummen2
	move.w	d1,dummen2+2

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa upp i super
	addq.l	#6,sp
	move.l	dummen,sp

	jsr	myownsystem		; S„tt upp TRACKERsystemet
	tst.w	dummen2
	beq	gemerror
	tst.w	dummen2+2
	beq.s	intetabortcancel

	move.b	#255,linestowait

	lea	sample,a5
	move.w	#1100*3*2/4,d5
rensaspelbuffern4:			; Rensa playbuffern
	clr.l	(a5)+
	dbra	d5,rensaspelbuffern4

	tst.w	termodyonoff
	beq.s	intef”rs”kasl†avden34
	clr.w	$ffff8900.w
intef”rs”kasl†avden34:

	lea	delpath,a0
	lea	delname,a1
	bsr	makeawholename

	lea	delete,a5	; Fr†ga om jag verkligen skall ta
	lea	dummystrang,a6	; bort den h„r filen
	bsr	makeform
	tst.w	d0
	bne.s	intetabortcancel

	pea	wholename
	move.w	#$41,-(sp)
	trap	#1
	addq.w	#6,sp			; Ta bort filen
	tst.l	d0
	bpl.s	intetabortcancel

	move.b	#199,linestowait
	lea	deleteerror1,a5		; Meddela att det blev fel
	lea	deleteerror2,a6		; n„r filen skulle tas bort
	bsr	makejeppform
intetabortcancel:
	move.w	gammalfart,$ffff8900.w
	move.b	#199,linestowait
	rts

rutinatthoppatillsen:
	dc.l	basspeed16
thestatusbyte:
	dc.w	0

s„ttr„ttbasfrekvenssomvihoppartill:		; a0 pekar till headern
	cmp.b	#'2',thestatusbyte
	bne.s	intes„ttauppdentill20
	move.l	#basspeed20,rutinatthoppatillsen
	rts
intes„ttauppdentill20:
	cmp.b	#'3',thestatusbyte
	bne.s	intes„ttauppdentill25
	move.l	#basspeed25,rutinatthoppatillsen
	rts
intes„ttauppdentill25:
	move.l	#basspeed16,rutinatthoppatillsen
	rts

itsastar8mod:
	dc.w	0
antalaktivakanalerimodulenvidladdning:
	dc.w	0

v„ntap†sl„pp2343434:
	jsr	testas†oftasomm”jligt	; Skriv ut tid o patternpos.
	jsr	ritapatternettrashat
	btst.b	#1,mkey
	bne.s	v„ntap†sl„pp2343434
	rts

gammalfart:
	dc.w	0

laddaenmodul:
	jsr	v„ntap†sl„pp2343434
	move.w	$ffff8900.w,gammalfart
	jsr	reinstallsystem 	; Installera systemet igen

	move.l	sp,dummen
	move.l	oldstack,-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa tebax till user
	addq.l	#6,sp

	jsr	forceredrawofGEMscreen
	lea	lmlabel,a1
	lea	modname,a2 		; Visa filv„ljaren
	lea	modpath,a3
	jsr	fsel_exinput
	move.w	d0,dummen2
	move.w	d1,dummen2+2

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa upp i super
	addq.l	#6,sp
	move.l	dummen,sp

	jsr	myownsystem		; S„tt upp TRACKERsystemet
	tst.w	dummen2
	beq	gemerror
	tst.w	dummen2+2
	beq	inteladdamodulcancel

	move.w	#1,donotdoanymusicorsomeshit

	jsr	stopknapp

	lea	sample,a5
	move.w	#1100*3*2/4,d5
rensaspelbuffern3:			; Rensa playbuffern
	clr.l	(a5)+
	dbra	d5,rensaspelbuffern3

	tst.w	termodyonoff
	beq.s	intef”rs”kasl†avden
	clr.w	$ffff8900.w
intef”rs”kasl†avden:

	tst.w	lownoise
	beq.s	intes„nkahuvudvolymeniinstall2
	move.w	#$07ff,$ffff8924.w
	move.w	#%10011000000,$ffff8922.w
intes„nkahuvudvolymeniinstall2:


	lea	modpath,a0
	lea	modname,a1
	bsr	makeawholename


hoppadirektiniladdningen:
	move.b	#255,linestowait
	move.w	#1,donotdoanymusicorsomeshit


	pea	dta2
	move.w	#$1a,-(sp)
	trap	#1		; S„tt r„tt dtabuffer
	addq.l	#6,sp
	clr.w	-(sp)
	pea	wholename
	move.w	#$4e,-(sp)
	trap	#1		; Leta efter filen
	addq.l	#8,sp
	tst.w	d0
	bne	filenotfoundthenloading

	clr.w	newlooppattpos
	clr.b	newloopsongpos
	clr.w	newloopwhichpatt

	tst.w	fr†gainteladdabara
	bne.s	intefr†gaomviskallladdabarag”rdet15
	bsr	tadodpaallasamplingar	; Sl„pp alla samplingar
	bsr	rensaallapatternsochsongen	; Rensa songen
intefr†gaomviskallladdabarag”rdet15:

	clr.l	undopek
	move.b	#255,linestowait

	clr.w	-(sp)
	pea	wholename
	move.w	#$3d,-(sp)
	trap	#1			; ™ppna mod-filen
	addq.l	#8,sp
	tst.l	d0
	bmi	kanejoppna
	move.w	d0,handle

	lea	termtonebuff,a0
	move.l	#1084,d0		; Ladda in lite data s† att vi
	bsr	loadthisblock		; kan tolka vilken typ av modul
	tst.l	d0			; som det „r
	bmi	humk”rdetsomg†r

	clr.w	-(sp)
	move.w	handle,-(sp)
	clr.l	-(sp)
	move.w	#$42,-(sp)
	trap	#1			; Flytta tillbaka pekaren
	lea	10(sp),sp		; till b”rjan av filen
	tst.w	d0
	bmi	humk”rdetsomg†r

	clr.w	itsastar8mod
	move.l	#basspeed16,rutinatthoppatillsen
	lea	termtonebuff,a0		; Ok, tolka svaret
	move.b	1083(a0),thestatusbyte
	and.b	#%00111111,thestatusbyte
	cmp.w	#'CD',1080(a0)
	bne.s	detvarinteenCD1
	cmp.b	#'4',1082(a0)
	beq.s	laddaenvanligaAmiga
detvarinteenCD1:
	cmp.l	#'M!K!',1080(a0)
	beq.s	laddaenvanligaAmiga
	cmp.l	#'M&K&',1080(a0)
	beq.s	laddaenvanligaAmiga
	cmp.l	#'RASP',1080(a0)
	beq.s	laddaenvanligaAmiga
	cmp.l	#'FA04',1080(a0)
	beq.s	laddaenvanligaAmiga
	cmp.l	#'M.K.',1080(a0)
	beq.s	laddaenvanligaAmiga	; Testa om det „r en vanlig
	cmp.l	#'FLT4',1080(a0)	; Amigamodul
	bne.s	inteenvanligaAmiga
laddaenvanligaAmiga:
	tst.w	fr†gainteladdabara
	bne.s	intefr†gaomviskallladdabarag”rdet1
	lea	foundstring,a5			; Meddela vad vi hitta
	lea	Amiga,a6
	jsr	makeform
	tst.w	d0
	bmi	v„ljettannantformat
intefr†gaomviskallladdabarag”rdet1:
	bsr	s„ttr„ttbasfrekvenssomvihoppartill
	move.w	#4,antalaktivakanalerimodulenvidladdning
	move.l	#'M.K.',headerattplacera
	bra	laddavanligmod
inteenvanligaAmiga:

	cmp.l	#'FLT6',1080(a0)
	beq.s	laddanyasexan
	cmp.l	#'6CHN',1080(a0)
	beq.s	laddanyasexan
	cmp.w	#'CD',1080(a0)
	bne.s	detvarinteensexa
	cmp.b	#'6',1082(a0)
	bne.s	detvarinteensexa
	tst.w	fr†gainteladdabara
	bne.s	intefr†gaomviskallladdabarag”rdet6
	lea	foundstring,a5			; Meddela vad vi hitta
	lea	enstyckesexa,a6
	jsr	makeform
	tst.w	d0
	bmi	v„ljettannantformat
intefr†gaomviskallladdabarag”rdet6:
	cmp.b	#'1',thestatusbyte
	beq.s	laddanyasexan
	cmp.b	#'2',thestatusbyte
	beq.s	laddanyasexan
	cmp.b	#'3',thestatusbyte
	beq.s	laddanyasexan
	bra.s	intefr†gaomviskallladdabarag”rdet2
laddanyasexan:
	bsr	s„ttr„ttbasfrekvenssomvihoppartill
	move.w	#6,antalaktivakanalerimodulenvidladdning
	move.l	#'CD6 ',headerattplacera
	bra	laddavanligmod
detvarinteensexa:

	cmp.l	#'8CHN',1080(a0)	; '8CHN' „r FastTracker p† PC
	beq.s	laddaenvanligaOcta
	cmp.l	#'OCTA',1080(a0)
	beq.s	laddaenvanligaOcta
	cmp.l	#'FA08',1080(a0)
	beq.s	laddaenvanligaOcta
	cmp.l	#'FLT8',1080(a0)
	bne.s	inteenamigatracker8a
	move.w	#1,itsastar8mod
	bra.s	laddaenvanligaOcta
inteenamigatracker8a:
	move.b	#' ',1083(a0)		; Testa om det „r mitt Octalyser
	cmp.l	#'CD8 ',1080(a0)	; format
	bne.s	inteenvanligaOcta
laddaenvanligaOcta:
	tst.w	fr†gainteladdabara
	bne.s	intefr†gaomviskallladdabarag”rdet2
	lea	foundstring,a5			; Meddela vad vi hitta
	lea	Octalyser,a6
	jsr	makeform
	tst.w	d0
	bmi	v„ljettannantformat
intefr†gaomviskallladdabarag”rdet2:
	bsr	s„ttr„ttbasfrekvenssomvihoppartill
	move.w	#8,antalaktivakanalerimodulenvidladdning
	move.l	#'CD8 ',headerattplacera
	bra	laddavanligmod
inteenvanligaOcta:
				; H„r skall vi testa andra format!

	cmp.l	#'OKTA',(a0)
	bne.s	inteenamigaoctalysermodul
	cmp.l	#'SONG',4(a0)
	bne.s	inteenamigaoctalysermodul
	cmp.l	#'CMOD',8(a0)
	bne.s	inteenamigaoctalysermodul
	tst.w	fr†gainteladdabara
	bne.s	intefr†gaomviskallladdabarag”rdet4
	lea	foundstring,a5			; Meddela vad vi hitta
	lea	AmiOctalyser,a6
	jsr	makeform
	tst.w	d0
	bmi	v„ljettannantformat
intefr†gaomviskallladdabarag”rdet4:
	move.l	#'CMOD',termtonebuff+8
	bra	laddainenAmigaOctalysermodul
inteenamigaoctalysermodul:


				; Om inget av de andra formaten fungerade
				; anta att det „r en gammal Amigamodul
				; 4 kanaler 15 instrument
	tst.w	fr†gainteladdabara
	bne.s	intefr†gaomviskallladdabarag”rdet3
	lea	foundstring,a5			; Meddela vad vi hitta
	lea	OldAmiga,a6
	jsr	makeform
intefr†gaomviskallladdabarag”rdet3:
	bsr	s„ttr„ttbasfrekvenssomvihoppartill
	move.w	#4,antalaktivakanalerimodulenvidladdning
	move.l	#'M.K.',headerattplacera
	move.l	#'OLD!',termtonebuff+1080
	tst.w	d0
	bmi	v„ljettannantformat
laddavanligmod:
	lea	songname,a5		; T”m aktuellt songnamn
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#$20202000,(a5)+

	moveq	#20,d0
	lea	songname,a0		; Ladda s†ngnamnet
	bsr	loadthisblock
	tst.l	d0
	bpl.s	intefelvidladdningavmodul1
	bsr	tadodpaallasamplingar	; Sl„pp alla samplingar
	bsr	rensaallapatternsochsongen	; Rensa songen
	bra	humk”rdetsomg†r
intefelvidladdningavmodul1:

	lea	songname,a5
	moveq	#20-1,d0
loopaigenomsongnamnet:
	tst.b	(a5)
	bne.s	inteennollaatttabort
	move.b	#' ',(a5)		; S„tt en nolla i slutet
inteennollaatttabort:			; av hela str„ngen
	addq.w	#1,a5
	dbra	d0,loopaigenomsongnamnet
	clr.b	songname+19

	move.w	#1,whichsample
	bsr	skrivuttillhorandeinfo

	move.l	#30*31,d0
	cmp.l	#'OLD!',termtonebuff+1080
	bne.s	inteengammalAmigamod
	move.l	#30*15,d0
inteengammalAmigamod:
	lea	modsamsave,a0
	bsr	loadthisblock		; Ladda infon om samplingarna
	tst.l	d0
	bpl.s	intefelvidladdningavmodul2
	bsr	tadodpaallasamplingar	; Sl„pp alla samplingar
	bsr	rensaallapatternsochsongen	; Rensa songen
	bra	humk”rdetsomg†r
intefelvidladdningavmodul2:

	lea	modsamsave,a5
	move.l	a5,a6
	moveq	#22-1,d0
	moveq	#31-1,d1
loopaigenomssamplenamnet:
	tst.b	(a5)
	bne.s	inteennollaatttabort2
	move.b	#' ',(a5)		; S„tt en nolla i slutet
inteennollaatttabort2:			; av hela str„ngen
	addq.w	#1,a5
	dbra	d0,loopaigenomssamplenamnet
	clr.b	21(a6)
	lea	30(a6),a6
	move.l	a6,a5
	moveq	#22-1,d0
	dbra	d1,loopaigenomssamplenamnet

	lea	modsamsave,a0
	moveq	#32-1,d0
kollas†attloopen„rr„ttf”ross:
	tst.w	28(a0)			; Se till att loopl„ngden
	bne.s	denlooparok		; INTE „r noll
	move.w	#1,28(a0)
denlooparok:
	lea	30(a0),a0
	dbra	d0,kollas†attloopen„rr„ttf”ross

	lea	modsamsave,a0
	lea	modsam,a1		; Kopiera in inladdad data
	move.w	#30*32/8-1,d0		; till de interna variablerna
kopieraindatantilldenandra:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,kopieraindatantilldenandra


	move.l	#134,d0
	cmp.l	#'OLD!',termtonebuff+1080
	bne.s	inteengammalAmigamod2
	move.l	#130,d0
inteengammalAmigamod2:
	lea	songlength,a0
	bsr	loadthisblock		; Ladda infon om songen
	tst.l	d0
	bpl.s	intefelvidladdningavmodul3
	bsr	tadodpaallasamplingar	; Sl„pp alla samplingar
	bsr	rensaallapatternsochsongen	; Rensa songen
	bra	humk”rdetsomg†r
intefelvidladdningavmodul3:
	move.l	headerattplacera,songend


	move.b	songlength,d0
	move.b	songrestart,d1
	cmp.b	d0,d1
	blt.s	intenollsomrestartavdem
	clr.b	songrestart
intenollsomrestartavdem:

	jsr	skrivutlitekrafs

	move.l	#32*64,d7
	cmp.w	#6,antalaktivakanalerimodulenvidladdning
	bne.s	intesexkanalerattladda
	move.l	#24*64,d7
intesexkanalerattladda:
	cmp.w	#4,antalaktivakanalerimodulenvidladdning
	bne.s	intefyrakanalerattladda
	move.l	#16*64,d7
intefyrakanalerattladda:		; Dax att ladda alla patterns
	bsr	hittastorstapatternetisongen
	cmp.w	maxpatterns,d0
	blt.s	deng†riniminnet
	bsr	tadodpaallasamplingar	; Sl„pp alla samplingar
	bsr	rensaallapatternsochsongen	; Rensa songen
	bra	slutslutslut	
deng†riniminnet:
	addq.l	#1,d0
	move.l	d0,d6
	mulu	d7,d0
huvudloopvidladdningavpatterna:
	move.l	patterns,a0
	bsr	loadthisblock		; Ladda ett pattern
	tst.l	d0
	bpl.s	intefelvidladdningavmodul4
	bsr	tadodpaallasamplingar	; Sl„pp alla samplingar
	bsr	rensaallapatternsochsongen	; Rensa songen
	bra	humk”rdetsomg†r
intefelvidladdningavmodul4:
	lea	formbak,a0
	cmp.w	#4,antalaktivakanalerimodulenvidladdning
	bne.s	mer„n4kanalerattsladda
	move.l	patterns,a0
	move.l	a0,a1
	move.l	d6,d5
	mulu	#16*64,d5
	add.l	d5,a0
	lsl.l	#1,d5
	add.l	d5,a1
	mulu	#64,d6
	subq.l	#1,d6
	moveq	#0,d0
loopain4kanalertillkortbuffern2:
	move.l	d0,-(a1)
	move.l	d0,-(a1)
	move.l	d0,-(a1)
	move.l	d0,-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)		; 4 kanaler laddades,
	move.l	-(a0),-(a1)		; konvertera till 8 kanaler
	move.l	-(a0),-(a1)
	dbra	d6,loopain4kanalertillkortbuffern2
mer„n4kanalerattsladda:
	cmp.w	#6,antalaktivakanalerimodulenvidladdning
	bne.s	mer„n6kanalerattsladda
	move.l	patterns,a0
	move.l	a0,a1
	move.l	d6,d5
	move.l	d5,d4
	mulu	#24*64,d5
	add.l	d5,a0
	mulu	#32*64,d4
	add.l	d4,a1
	mulu	#64,d6
	subq.l	#1,d6
	moveq	#0,d0
loopain6kanalertillkortbuffern2:
	move.l	d0,-(a1)
	move.l	d0,-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)		; 6 kanaler laddades,
	move.l	-(a0),-(a1)		; konvertera till 8 kanaler
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	dbra	d6,loopain6kanalertillkortbuffern2
mer„n6kanalerattsladda:


	lea	modsam,a6
	lea	samplestarts,a5
	moveq	#31-1,d7
laddainsamplingarnaimodulen:
	movem.l	d7/a5/a6,-(sp)
	lea	whichsample+1,a3	; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#49,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
	bsr	skrivuttillhorandeinfo
	addq.w	#1,whichsample
	movem.l	(sp)+,d7/a5/a6

	and.b	#$f,32*30+24(a6)
	move.b	32*30+24(a6),24(a6)
	tst.w	32*30+22(a6)
	beq.s	entomsamplingladdaej

	moveq	#0,d0
	move.w	32*30+22(a6),d0
	add.l	d0,d0
	add.l	#2000,d0
	move.l	a5,a0
	moveq	#0,d1
	jsr	malloc		; Beg„r minne f”r samplingen
	bne.s	inteoutofmemoryerroriladda
slutslutslut:
	bsr	outofmemoryerror	; Opps, slut p† minne
	move.b	#255,linestowait	; Hur skall vi g”ra nu?
	bra.s	humk”rdetsomg†r
inteoutofmemoryerroriladda:
	move.l	d0,a0
	moveq	#0,d0
	move.w	32*30+22(a6),d0
	add.l	d0,d0
	move.l	d0,d1
	add.l	(a5),d1
	add.l	#1000,d1
	move.l	d1,32*4(a5)		; Spar undan vart samplingen finns att kopiera
	bsr	loadthisblock		; Ladda en sampling
	tst.l	d0
	bmi.s	humk”rdetsomg†r
entomsamplingladdaej:
	lea	30(a6),a6
	addq.w	#4,a5
	dbra	d7,laddainsamplingarnaimodulen

humk”rdetsomg†r:
	moveq	#31-1,d7
	move.w	#1,whichsample
loopaigenomallasamplingar:
	moveq	#0,d0
	move.w	whichsample,d0
	subq.w	#1,d0
	move.l	d0,d1
	add.w	d0,d0
	add.w	d0,d0
	add.l	#samplestarts,d0
	move.l	d0,a0
	cmp.l	#dummy,(a0)
	bne.s	inteensamplingsominteladdades
	move.l	d7,-(sp)
	bsr	hoppasnabbtf”rbi
	move.l	(sp)+,d7
	bra.s	denh„rsamplingenkakade
inteensamplingsominteladdades:
	bsr	s„ttlooplength
denh„rsamplingenkakade:
	addq.w	#1,whichsample
	dbra	d7,loopaigenomallasamplingar

	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1			; St„ng mod-filen
	addq.l	#4,sp
	tst.w	d0
	bmi	kanejstanga

	tst.w	itsastar8mod		; Om det „r en FLT8, konvertera
	beq.s	intekonverterapatternettillstar8
	bsr	blockhide
	bsr	hittastorstapatternetisongen
	move.l	patterns,a0
	lea	$400(a0),a2
konverteraallapatternfr†nFLT8:
	moveq	#64-1,d1
	lea	blockbuffer,a1
	move.l	a0,a3
tadatani1steg†tg†ngentillbockbuffern:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	dbra	d1,tadatani1steg†tg†ngentillbockbuffern
	lea	blockbuffer,a1
	moveq	#64-1,d1
tadatani1steg†tg†ngenfr†nbockbuffern:
	move.l	(a1)+,(a3)+
	move.l	(a1)+,(a3)+
	move.l	(a1)+,(a3)+
	move.l	(a1)+,(a3)+
	move.l	(a1)+,(a3)+
	move.l	(a1)+,(a3)+
	move.l	(a1)+,(a3)+
	move.l	(a1)+,(a3)+
	dbra	d1,tadatani1steg†tg†ngenfr†nbockbuffern
	dbra	d0,konverteraallapatternfr†nFLT8
intekonverterapatternettillstar8:

	move.w	#$06,speed
	move.b	song,whichpatt+1
	clr.b	songpos
	move.w	#125,tempo
	clr.l	tempor„knare
	move.l	#12500,tempoadder

	move.w	#1,whichsample
	jsr	skrivutlitekrafs
	bsr	skrivuttillhorandeinfo

	tst.w	termodyonoff
	beq.s	„rdennolls†beh”verviinteshifta23
	move.l	termodyshifts,d4
	tst.w	d4
	beq.s	„rdennolls†beh”verviinteshifta23
	lea	samplestarts,a0
	lea	modsamsave,a1
	moveq	#31-1,d0
shiftanerl„mpligt3:
	tst.w	22(a1)
	beq.s	entomsamplingingenshifth„rinte3
	moveq	#0,d1
	move.w	22(a1),d1
	add.l	d1,d1		; Shifta ner samplingarna s† att vi
	add.l	#2000,d1	; kan anv„nda TERMODYn
	lsr.l	#1,d1
	move.l	(a0),a2
shifta3:move.b	(a2),d3
	asr.b	d4,d3
	move.b	d3,(a2)+
	move.b	(a2),d3
	asr.b	d4,d3
	move.b	d3,(a2)+
	subq.l	#1,d1
	bne.s	shifta3
entomsamplingingenshifth„rinte3:
	lea	30(a1),a1
	addq.w	#4,a0
	dbra	d0,shiftanerl„mpligt3
„rdennolls†beh”verviinteshifta23:

	move.w	basspeed,-(sp)
	jsr	optionsrutin
	move.l	rutinatthoppatillsen,a0
	jsr	(a0)			; St„ll in r„tt basfrekvens
	jsr	slutamedoptions
	move.l	#diskkoors,losapositioner
	move.l	#diskrots,losarutiner
	move.w	(sp)+,d0
	cmp.w	basspeed,d0
	beq	neeegativt2
	tst.w	termodyonoff
	beq	neeegativt2
	move.w	termotones,d5
	addq.w	#1,d5
	lea	termtonebuff,a1
	lea	datareq,a0
	moveq	#37-1,d7		; R„kna ut hur m†nga steg
r„knautbeh”vligtantaltonerimellan22:	; somd det finns imellan
	move.w	(a0),d2			; varje rikigt ton
	sub.w	2(a0),d2
	cmp.w	d5,d2
	ble.s	intemaxtonerimellan22
	move.w	d5,d2
intemaxtonerimellan22:	; Nu inneh†ller d2 hur m†nga toner som skall in
	move.w	(a0),d3
	mulu	#100,d3
	move.w	2(a0),d4
	mulu	#100,d4	; R„kna om s† att vi kan r„kna med 2 decimaler
	move.w	d2,d0
	move.l	d3,d1
	sub.l	d4,d1
	divu	d2,d1	; d1 inneh†ller adderingskoefficienten
	and.l	#$ffff,d1
	subq.w	#1,d0
loopaframl„mpligamellanfrekv2:
	sub.l	d1,d3	; Stega fram r„tt antal mellanfrekvenser
	move.l	d3,d4
	add.l	#50,d4
	divu	#100,d4
	move.w	d4,(a1)+
	dbra	d0,loopaframl„mpligamellanfrekv2
	addq.w	#2,a0
	dbra	d7,r„knautbeh”vligtantaltonerimellan22
	move.w	#-1,(a1)

	move.l	#3546895,d3
	tst.w	basspeed
	beq.s	s„ttinteh”gfrek2
	bmi.s	special202
	move.l	#5320343,d3
	bra.s	s„ttinteh”gfrek2
special202:
	move.l	#4304818,d3
s„ttinteh”gfrek2:
	moveq	#0,d4
	lea	termtonebuff,a6
	lea	frekvensbuffer,a5	; R„kna fram frekvensbuffern
r„knautfrekv2:
	move.l	d3,d1
	moveq	#0,d2
	move.w	(a6)+,d2		; f=3579546/periods (Amigans perioder)
	bmi.s	slutp†intressantadata2
	divu	d2,d1
	swap	d1			; f*65536/50066
	move.w	d4,d1
	divu	#50066,d1
	and.l	#$FFFF,d1
	move.l	d1,(a5)+
	bra.s	r„knautfrekv2
slutp†intressantadata2:
	move.l	#-1,(a5)+

	jsr	clearthepattshower	; Tvinga den att bara visa
	move.l	currenttermody,a0
	move.l	16(a0),d0
	move.w	d0,patternupdate	; x patternrader

	move.l	currenttermody,a0
	move.l	(a0),a0
	addq.w	#4,a0		; S„tt vart den skall hoppa
	move.l	a0,inster+2
	move.l	termodypek,a0
	lea	frekvensbuffer,a1
	lea	kanal14rutin,a2
	lea	vtab,a3		; S„nd med en massa buffrar
	move.l	physbase,a4	; och variabler till rutinen
	lea	samplestarts,a5
	lea	modsamsave,a6
	moveq	#0,d0
	move.l	#'0.90',d4
	move.l	#musicwait,d1
	move.l	#itab0,d2
	move.l	#wiz1lc,d3
	move.l	#makejeppform,d6
	move.l	#makeform,d7
	move.l	#skrivuthex,d5
inster:	jsr	$12345678	; F”rbered spelaren
neeegativt2:

inteladdamodulcancel:
	move.w	#1,uppdateranup†eng†ng
	move.w	gammalfart,$ffff8900.w
	move.w	#-1,currentsample
	jsr	checkifsamplechanged
	clr.w	donotdoanymusicorsomeshit
	move.b	#199,linestowait
	rts


laddainenAmigaOctalysermodul:
	lea	termtonebuff,a0
	move.l	#$400+$146,d0		; Ladda in Amiga Octalyser
	bsr	loadthisblock		; headern
	tst.l	d0
	bmi	n†gefelbiddedetomvihoppahit

;	moveq	#0,d0
;	add.w	termtonebuff+16,d0
;	add.w	termtonebuff+16,d0
;	add.w	termtonebuff+18,d0
;	add.w	termtonebuff+18,d0
;	add.w	termtonebuff+20,d0
;	add.w	termtonebuff+20,d0
;	add.w	termtonebuff+22,d0
;	add.w	termtonebuff+22,d0
;	move.w	d0,par1
	move.w	termtonebuff+14,par1

	lea	songname,a5		; T”m aktuellt songnamn
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.w	#'  ',(a5)+
	move.w	#$2000,(a5)+	

	lea	termtonebuff+8,a0
	move.l	#'SAMP',d0
	bsr	findpointertothatinAmiOct
	move.l	a0,a1

	lea	modsamsave,a0
	moveq	#31-1,d0		; Kopiera in samplingarna
koppainantaletsamplingar:
	move.l	(a1),(a0)
	move.l	4(a1),4(a0)
	move.l	8(a1),8(a0)
	move.l	12(a1),12(a0)
	move.l	16(a1),16(a0)
	move.w	20(a1),20(a0)
	move.w	22(a1),22(a0)
	lsr.w	22(a0)
	move.w	28(a1),24(a0)
	clr.w	26(a0)
	move.w	30(a1),28(a0)
	lsr.w	28(a0)
	tst.w	28(a0)
	bne.s	alltokl„ngden„rintenoll
	move.w	#1,28(a0)
alltokl„ngden„rintenoll:
	lea	32(a1),a1
	lea	30(a0),a0
	dbra	d0,koppainantaletsamplingar

	lea	modsamsave,a5
	move.l	a5,a6
	moveq	#22-1,d0
	moveq	#31-1,d1
loopaigenomssamplenamnet28:
	tst.b	(a5)
	bne.s	inteennollaatttabort228
	move.b	#' ',(a5)		; S„tt en nolla i slutet
inteennollaatttabort228:		; av hela str„ngen
	addq.w	#1,a5
	dbra	d0,loopaigenomssamplenamnet28
	clr.b	21(a6)
	lea	30(a6),a6
	move.l	a6,a5
	moveq	#22-1,d0
	dbra	d1,loopaigenomssamplenamnet28

	lea	termtonebuff+8,a0
	move.l	#'SPEE',d0
	bsr	findpointertothatinAmiOct
	move.w	(a0),speed		; R„tt fart
	lea	termtonebuff+8,a0
	move.l	#'PLEN',d0
	bsr	findpointertothatinAmiOct
	move.b	1(a0),songlength	; R„tt l„ngd

	lea	termtonebuff+8,a0
	move.l	#'PATT',d0
	bsr	findpointertothatinAmiOct
	lea	song,a1			; Kopiera in songen
	moveq	#128-1,d0
koppainsongenisongen138:
	move.b	(a0)+,(a1)+
	dbra	d0,koppainsongenisongen138

	lea	termtonebuff+8,a0
	move.l	#'SLEN',d0
	bsr	findpointertothatinAmiOct
	move.w	(a0),d7			; Antal patterns att ladda in
	subq.w	#1,d7
	move.l	patterns,a6
laddainamigaoctalyserpatterns:
	lea	termtonebuff,a0
	moveq	#10,d0			; Ladda in ett Amiga Octalyser
	bsr	loadthisblock		; pattern
	tst.l	d0
	bmi	n†gefelbiddedetomvihoppahit

	cmp.l	#'PBOD',termtonebuff
	bne	humk”rdetsomg†r2
	move.w	termtonebuff+8,octapattbreak

	move.l	termtonebuff+4,d0
	subq.l	#2,d0			; Ber„kna l„ngden p† patternet
	lea	termtonebuff,a0		; Ladda in ett Amiga Octalyser
	bsr	loadthisblock		; pattern
	tst.l	d0
	bmi	n†gefelbiddedetomvihoppahit

	move.w	octapattbreak,d5
	subq.w	#1,d5
	lea	periods,a0
	lea	termtonebuff,a1
	moveq	#0,d4
	lea	CommandAmiOcttoSTEOct,a2
fixatillraden:
	move.w	par1,d0
	subq.w	#1,d0
konverteratonertillvanligatoner:
	moveq	#0,d1
	moveq	#0,d2
	move.b	(a1),d1
	beq.s	intenton
	subq.w	#1,d1
	add.w	d1,d1			; Konertera tonen
	move.w	(a0,d1.w),d2
	moveq	#0,d3
	move.b	1(a1),d3
	addq.w	#1,d3
	lsr.b	#4,d3
	swap	d3
	lsr.l	#4,d3			; L„gg in ”vre samplingdelen
	or.l	d3,d2	
	move.w	d2,(a6)
	move.b	1(a1),d4
	addq.w	#1,d4
	lsl.b	#4,d4
	move.b	d4,2(a6)		; L„gg in nedre delen av samplingen
intenton:
	move.b	2(a1),d4
	add.w	d4,d4
	move.w	(a2,d4.w),d4
	bmi.s	intekommando		; Se till att konvertera n†gra
	bne.s	intearpeggio
	cmp.b	#$B,2(a1)		; kommandon
	beq.s	intearpeggio
	move.b	3(a1),d3
	lsl.b	#4,d3
	move.b	d3,3(a1)
intearpeggio:
	or.b	d4,2(a6)
	move.b	3(a1),3(a6)
intekommando:
	moveq	#0,d4
	addq.w	#4,a6
	addq.w	#4,a1
	dbra	d0,konverteratonertillvanligatoner
	moveq	#32,d0
	sub.w	par1,d0
	sub.w	par1,d0
	sub.w	par1,d0
	sub.w	par1,d0
	add.w	d0,a6
	dbra	d5,fixatillraden

	cmp.w	#$40,octapattbreak
	beq.s	det„rr„ttl„ngdpatternet
	move.l	#$D00,(a6)+
	move.l	#$D00,(a6)+
	move.l	#$D00,(a6)+
	move.l	#$D00,(a6)+
	move.l	#$D00,(a6)+
	move.l	#$D00,(a6)+
	move.l	#$D00,(a6)+
	move.l	#$D00,(a6)+
	move.w	octapattbreak,d0
	sub.w	#8+1,d0
	bmi.s	det„rr„ttl„ngdpatternet
rensanedredelennup†eng†ng:
	clr.l	(a6)+
	clr.l	(a6)+
	clr.l	(a6)+
	clr.l	(a6)+
	clr.l	(a6)+
	clr.l	(a6)+
	clr.l	(a6)+
	clr.l	(a6)+
	dbra	d0,rensanedredelennup†eng†ng
det„rr„ttl„ngdpatternet:
	dbra	d7,laddainamigaoctalyserpatterns

	lea	modsam,a6
	lea	samplestarts,a5
	moveq	#31-1,d7
laddainsamplingarnaimodulen2:
	movem.l	d7/a5/a6,-(sp)
	lea	whichsample+1,a3	; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#49,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
	bsr	skrivuttillhorandeinfo
	addq.w	#1,whichsample
	movem.l	(sp)+,d7/a5/a6

	and.b	#$f,32*30+24(a6)
	move.b	32*30+24(a6),24(a6)
	tst.w	32*30+22(a6)
	beq.s	entomsamplingladdaej2

	lea	termtonebuff,a0
	moveq	#8,d0			; Ladda in Amiga header till
	bsr	loadthisblock		; samplingen
	tst.l	d0
	bmi	n†gefelbiddedetomvihoppahit

	moveq	#0,d0
	move.w	32*30+22(a6),d0
	add.l	d0,d0
	add.l	#2000,d0
	move.l	a5,a0
	moveq	#0,d1
	jsr	malloc		; Beg„r minne f”r samplingen
	bne.s	inteoutofmemoryerroriladda2
slutslutslut2:
	bsr	outofmemoryerror	; Opps, slut p† minne
	move.b	#255,linestowait	; Hur skall vi g”ra nu?
	bra.s	humk”rdetsomg†r2
inteoutofmemoryerroriladda2:
	move.l	d0,a0
	moveq	#0,d0
	move.w	32*30+22(a6),d0
	add.l	d0,d0
	move.l	d0,d1
	add.l	(a5),d1
	add.l	#1000,d1
	move.l	d1,32*4(a5)		; Spar undan vart samplingen finns att kopiera
	bsr	loadthisblock		; Ladda en sampling
	tst.l	d0
	bmi.s	humk”rdetsomg†r2
entomsamplingladdaej2:
	lea	30(a6),a6
	addq.w	#4,a5
	dbra	d7,laddainsamplingarnaimodulen2


humk”rdetsomg†r2:
	moveq	#31-1,d7
	move.w	#1,whichsample
loopaigenomallasamplingar2:
	moveq	#0,d0
	move.w	whichsample,d0
	subq.w	#1,d0
	move.l	d0,d1
	add.w	d0,d0
	add.w	d0,d0
	add.l	#samplestarts,d0
	move.l	d0,a0
	cmp.l	#dummy,(a0)
	bne.s	inteensamplingsominteladdades2
	move.l	d7,-(sp)
	bsr	hoppasnabbtf”rbi
	move.l	(sp)+,d7
	bra.s	denh„rsamplingenkakade2
inteensamplingsominteladdades2:
	bsr	s„ttlooplength
denh„rsamplingenkakade2:
	addq.w	#1,whichsample
	dbra	d7,loopaigenomallasamplingar2



n†gefelbiddedetomvihoppahit:
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1			; St„ng mod-filen
	addq.l	#4,sp
	tst.w	d0
	bmi	kanejstanga

	move.w	#1,whichsample
	jsr	skrivutlitekrafs
	bsr	skrivuttillhorandeinfo

	jsr	optionsrutin
	move.l	rutinatthoppatillsen,a0
	jsr	(a0)			; St„ll in r„tt basfrekvens
	jsr	slutamedoptions
	move.l	#diskkoors,losapositioner
	move.l	#diskrots,losarutiner
inteladdaAmiOctamodulcancel:
	move.w	gammalfart,$ffff8900.w
	move.w	#-1,currentsample
	jsr	checkifsamplechanged
	clr.w	donotdoanymusicorsomeshit
	move.b	#199,linestowait
	rts

findpointertothatinAmiOct:	; Rutinen som hittar pekaren i Amiga
	movem.l	(a0)+,d1-d2	; Octalyser-formatet
	cmp.l	d0,d1
	beq.s	harhittatr„ttpekare
	add.l	d2,a0
	bra.s	findpointertothatinAmiOct
harhittatr„ttpekare:
	rts


par1:	dc.w	0
octapattbreak:
	dc.w	0
CommandAmiOcttoSTEOct:
	dc.w	-1,2,1,-1,-1,-1
	dc.w	-1,-1,-1,-1,$0,$0
	dc.w	-1,-1,-1,-1,-1,-1
	dc.w	-1,-1,-1,-1,-1,-1
	dc.w	-1,$B,-1,$A,$F,-1
	dc.w	-1,$C,-1,-1,-1,-1


headerattplacera:
	dc.l	0

v„ljettannantformat:		; L†t anv„ndaren ange format vid laddning
	jsr	openchoise	; ™ppna valrutan

v„ntap†ettaktivtval:
	jsr	returnselection
	cmp.w	#8,d0
	beq.s	v„ntap†ettaktivtval
	cmp.w	#9,d0
	beq.s	v„ntap†ettaktivtval
	jsr	closechoise	; St„ng valrutan
	move.l	#basspeed16,rutinatthoppatillsen
	clr.w	itsastar8mod

	tst.w	d0
	bne.s	detvarinte4kanaler15instrument	; 4 kanaler 15 sam
	move.w	#4,antalaktivakanalerimodulenvidladdning
	move.l	#'OLD!',termtonebuff+1080
	move.l	#'M.K.',headerattplacera
	bra	laddavanligmod
detvarinte4kanaler15instrument:
	cmp.w	#1,d0
	bne.s	detvarinte4kanaler31instrument	; 4 kanaler 31 sam
	move.w	#4,antalaktivakanalerimodulenvidladdning
	move.l	#'M.K.',termtonebuff+1080
	move.l	#'M.K.',headerattplacera
	bra	laddavanligmod
detvarinte4kanaler31instrument:
	cmp.w	#7,d0		; Fasttracker f”r PC „r samma som Octan
	beq.s	det„rengammalsexaanv„ndarevillladda
	cmp.w	#5,d0
	beq.s	det„rengammalsexaanv„ndarevillladda
	cmp.w	#2,d0
	bne.s	detvarinte8kanaler31instrument	; 8 kanaler 31 sam
det„rengammalsexaanv„ndarevillladda:
	move.w	#8,antalaktivakanalerimodulenvidladdning
	move.l	#'CD8 ',termtonebuff+1080
	move.l	#'CD8 ',headerattplacera
	bra	laddavanligmod
detvarinte8kanaler31instrument:
	cmp.w	#3,d0
	bne.s	detvarinte8kanaler31instrumentFLT	; 8 kanaler 31 sam
	move.w	#8,antalaktivakanalerimodulenvidladdning
	move.l	#'CD8 ',termtonebuff+1080
	move.l	#'CD8 ',headerattplacera
	move.w	#1,itsastar8mod
	bra	laddavanligmod
detvarinte8kanaler31instrumentFLT:
	cmp.w	#4,d0
	bne.s	detvarinteAmigaoctainstrument	; Amiga Octalyser
	move.l	#'CMOD',termtonebuff+8
	bra	laddainenAmigaOctalysermodul
detvarinteAmigaoctainstrument:
	cmp.w	#6,d0
	bne.s	detvarinte6kanaler31instrument	; 6 kanaler 31 sam
	move.w	#6,antalaktivakanalerimodulenvidladdning
	move.l	#'CD6 ',termtonebuff+1080
	move.l	#'CD6 ',headerattplacera
	bra	laddavanligmod
detvarinte6kanaler31instrument:

	jsr	closechoise	; St„ng valrutan    CANCEL
	bra	humk”rdetsomg†r



loadthisblock:		; a0 buffer som skall laddas    d0 hur m†nga bytes som skall sparas
	move.l	d0,d4	; d4 extra bufferh†llare
	movem.l	d4/d5/d6/a4/a5/a6,-(sp)
	move.l	a0,-(sp)
	move.l	d0,-(sp)
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp
	movem.l	(sp)+,d4/d5/d6/a4/a5/a6
	cmp.l	d0,d4
	bne.s	filereaderror
	rts

filereaderror:
	move.b	#199,linestowait
	lea	noread1,a5		; Meddela att det blev fel
	lea	dummystrang,a6		; vid skrivning till filen
	bsr	makejeppform
	move.b	#255,linestowait
	move.w	gammalfart,$ffff8900.w
	moveq	#-1,d0
	rts

filenotfoundthenloading:
	move.b	#199,linestowait
	lea	filenotfounderror1,a5	; Meddela att det blev fel
	lea	dummystrang,a6		; vid skrivning till filen
	bsr	makejeppform
	clr.w	donotdoanymusicorsomeshit
	move.w	gammalfart,$ffff8900.w
	moveq	#-1,d0
	rts


sparaensampling:
	tst.w	termodyonoff
	bne	intesparasamplingcancel

	tst.w	whichsample
	beq	inte„ndraeftersomdet„r0an10
	moveq	#0,d0
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsamsave,d0
	move.l	d0,a6

	tst.w	22(a6)			; Som tom sampling, varf”r f”rs”ka
	beq	intesparasamplingcancel	; spara?

	jsr	v„ntap†sl„pp2343434
	jsr	reinstallsystem 	; Installera systemet igen

	move.l	sp,dummen
	move.l	oldstack,-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa tebax till user
	addq.l	#6,sp

	jsr	forceredrawofGEMscreen
	lea	slabel,a1
	lea	name,a2 		; Visa filv„ljaren
	lea	path,a3
	jsr	fsel_exinput
	move.w	d0,dummen2
	move.w	d1,dummen2+2

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa upp i super
	addq.l	#6,sp
	move.l	dummen,sp

	jsr	myownsystem		; S„tt upp TRACKERsystemet
	tst.w	dummen2
	beq	gemerror
	tst.w	dummen2+2
	beq	intesparasamplingcancel

	lea	sample,a5
	move.w	#1100*3*2/4,d5
rensaspelbuffern5:			; Rensa playbuffern
	clr.l	(a5)+
	dbra	d5,rensaspelbuffern5

	move.b	#255,linestowait

	lea	path,a0
	lea	name,a1
	bsr	makeawholename

	pea	dta2
	move.w	#$1a,-(sp)
	trap	#1		; S„tt r„tt dtabuffer
	addq.l	#6,sp
	clr.w	-(sp)
	pea	wholename
	move.w	#$4e,-(sp)
	trap	#1		; Leta efter filen
	addq.l	#8,sp
	tst.w	d0
	bne.s	filenotfoundthensavethesam
	move.b	#199,linestowait
	lea	overwrite1,a5	; Fr†ga om jag verkligen skall spara
	lea	overwrite2,a6	; ”ver filen
	bsr	makeform
	move.b	#255,linestowait
	tst.w	d0
	bne	intesparasamplingcancel
filenotfoundthensavethesam:
	clr.w	-(sp)
	pea	wholename
	move.w	#$3c,-(sp)
	trap	#1			; Skapa filen
	addq.w	#8,sp
	tst.l	d0
	bmi	couldnotcreatefile
	move.w	d0,handle

	moveq	#0,d0
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsamsave,d0
	move.l	d0,a6
	moveq	#0,d0
	move.w	whichsample,d0		; R„kna ut pekare
	subq.w	#1,d0
	add.w	d0,d0
	add.w	d0,d0
	add.l	#samplestarts,d0
	move.l	d0,a5

	move.l	32*4(a5),a0
	move.l	(a5),a1
	add.w	22(a6),a1
	add.w	22(a6),a1
	lea	1000(a1),a1		; Flytta tillbaka lite
	moveq	#125-1,d0		; samplingsdata
flyttatebaxsamplingsdata3:
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d0,flyttatebaxsamplingsdata3

	lea	termtonebuff,a0
	moveq	#32-1,d0
rensaheaderntillsamplingen:		; Rensa headern
	clr.l	(a0)+
	dbra	d0,rensaheaderntillsamplingen

	lea	termtonebuff,a0
	move.l	#'2BIT',(a0)+	; Tala om att det „r en AVR-sampling
	move.l	(a6),(a0)+	; 8 tecken av samplenamnet
	move.l	4(a6),(a0)+
	clr.w	(a0)+		; monosampling
	move.w	#8,(a0)+	; 8 bitar
	move.w	#-1,(a0)+	; Signerade samplingar
	clr.w	(a0)		; Loop p†/av
	cmp.l	#1,26(a6)
	beq.s	oloopadensomskallsparas
	move.w	#-1,(a0)
oloopadensomskallsparas:
	addq.w	#2,a0
	move.w	#-1,(a0)+	; Ingen MIDItangent kodad till samplingen
	move.l	#$FFCDC0DE,(a0)+; Samplingsfrekvensen
	moveq	#0,d0
	move.w	22(a6),d0
	add.l	d0,d0
	move.l	d0,(a0)+	; Samplingsl„ngden
	clr.l	(a0)
	move.l	d0,4(a0)
	cmp.l	#1,26(a6)	; Loop start och end
	beq.s	oloopadensomskallsparas2
	move.w	26(a6),d0
	add.l	d0,d0
	move.l	d0,(a0)
	moveq	#0,d1
	move.w	28(a6),d1
	add.l	d1,d1
	add.l	d0,d1
	move.l	d1,4(a0)
oloopadensomskallsparas2:
	addq.w	#8,a0
	clr.w	(a0)+		; MIDI keyboard split
	clr.w	(a0)+		; Samplecompression
	clr.w	(a0)+		; Unused
	move.l	8(a6),(a0)+	; Sista delen p† samplingnamnet
	move.l	12(a6),(a0)+
	move.l	16(a6),(a0)+
	move.w	20(a6),(a0)+
	clr.l	(a0)+
	clr.w	(a0)+
	move.l	#'SAVE',(a0)+	; Litet meddelande att samplingen
	move.l	#'D US',(a0)+	; blivit sparad med Octalysern
	move.l	#'ING ',(a0)+
	move.l	#'THE ',(a0)+
	move.l	#'OCTA',(a0)+
	move.l	#'LYSE',(a0)+
	move.l	#'R...',(a0)+

	lea 	wholename,a0
hittanollnu:
	tst.b	(a0)+
	bne.s	hittanollnu
	subq.w	#1,a0
	cmp.b	#'R',-(a0)
	bne.s	skallvisparaRAW
	cmp.b	#'V',-(a0)
	bne.s	skallvisparaRAW
	cmp.b	#'A',-(a0)
	beq.s	sparaAVR
skallvisparaRAW:
	movem.l	a5-a6,-(sp)
	lea	saveRAW1,a5
	lea	saveRAW2,a6
	jsr	makeform
	movem.l	(sp)+,a5-a6
	tst.w	d0
	bpl.s	sparaRAW
sparaAVR:
	lea.l	termtonebuff,a0
	move.l	#128,d0
	bsr	savethisblock		; Spara headern tillsamplingen
	tst.l	d0
	bmi.s	felvidsparningavsample
sparaRAW:
	move.l	(a5),a0
	moveq	#0,d0
	move.w	22(a6),d0
	add.l	d0,d0
	bsr	savethisblock		; Spara samplingsdatan
felvidsparningavsample:

	moveq	#0,d0
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsam,d0
	move.l	d0,a5
	moveq	#0,d0
	move.w	whichsample,d0
	subq.w	#1,d0			; Flytta tillbaka loopdata
	add.w	d0,d0			; in i samplingen igen
	add.w	d0,d0
	add.l	#samplestarts,d0
	move.l	d0,a6
	bsr	flyttaomsamplingsdatans†attvikanloopaden

	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1			; St„ng filen
	addq.w	#4,sp
	tst.w	d0
	bmi	kanejstanga
intesparasamplingcancel:
	move.b	#199,linestowait
inte„ndraeftersomdet„r0an10:
	rts

sparaenmodul:
	tst.w	termodyonoff
	bne	intesparamodulcancel

	cmp.w	#4,antalkanaler		; Skall vi spara 4 kanaler?
	bne.s	kanalernaanv„ndsej
	bsr	hittastorstapatternetisongen
	addq.l	#1,d0			; Isf, testa s† att det inte
	mulu	#64,d0			; sker av misstag, f”r d† f”rlorar
	subq.w	#1,d0			; anv„ndaren 4 kanaler! Det
	move.l	patterns,a0		; vore ju tr†kigt...
testaomkanalerfinns:
	tst.l	16(a0)
	bne.s	kanalfinns
	tst.l	20(a0)
	bne.s	kanalfinns
	tst.l	24(a0)
	bne.s	kanalfinns
	tst.l	28(a0)
	bne.s	kanalfinns
	lea	32(a0),a0
	dbra	d0,testaomkanalerfinns
	bra.s	kanalernaanv„ndsej
kanalfinns:
	lea	save4anyway1,a5	; Fr†ga om jag verkligen skall spara
	lea	save4anyway2,a6	; fyra kanaler n„r det finns flera
	bsr	makeform
	tst.w	d0
	bne	intesparamodulcancel
kanalernaanv„ndsej:
	cmp.w	#6,antalkanaler		; Skall vi spara 6 kanaler?
	bne.s	kanalernaanv„ndsej6
	bsr	hittastorstapatternetisongen
	addq.l	#1,d0			; Isf, testa s† att det inte
	mulu	#64,d0			; sker av misstag, f”r d† f”rlorar
	subq.w	#1,d0			; anv„ndaren 2 kanaler! Det
	move.l	patterns,a0		; vore ju tr†kigt...
testaomkanalerfinns6:
	tst.l	24(a0)
	bne.s	kanalfinns6
	tst.l	28(a0)
	bne.s	kanalfinns6
	lea	32(a0),a0
	dbra	d0,testaomkanalerfinns6
	bra.s	kanalernaanv„ndsej6
kanalfinns6:
	lea	save4anyway1,a5	; Fr†ga om jag verkligen skall spara
	lea	save4anyway2,a6	; sex kanaler n„r det finns flera
	bsr	makeform
	tst.w	d0
	bne	intesparamodulcancel
kanalernaanv„ndsej6:

	jsr	v„ntap†sl„pp2343434
	jsr	reinstallsystem 	; Installera systemet igen

	move.l	sp,dummen
	move.l	oldstack,-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa tebax till user
	addq.l	#6,sp

	jsr	forceredrawofGEMscreen
	lea	smlabel,a1
	lea	modname,a2 		; Visa filv„ljaren
	lea	modpath,a3
	jsr	fsel_exinput
	move.w	d0,dummen2
	move.w	d1,dummen2+2

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa upp i super
	addq.l	#6,sp
	move.l	dummen,sp

	jsr	myownsystem		; S„tt upp TRACKERsystemet
	tst.w	dummen2
	beq	gemerror
	tst.w	dummen2+2
	beq	intesparamodulcancel

	move.b	#255,linestowait

	lea	sample,a5
	move.w	#1100*3*2/4,d5
rensaspelbuffern2:			; Rensa playbuffern
	clr.l	(a5)+
	dbra	d5,rensaspelbuffern2

	tst.w	lownoise
	beq.s	intes„nkahuvudvolymeniinstall3
	move.w	#$07ff,$ffff8924.w
	move.w	#%10011000000,$ffff8922.w
intes„nkahuvudvolymeniinstall3:

	lea	modpath,a0
	lea	modname,a1
	bsr	makeawholename

	pea	dta2
	move.w	#$1a,-(sp)
	trap	#1		; S„tt r„tt dtabuffer
	addq.l	#6,sp
	clr.w	-(sp)
	pea	wholename
	move.w	#$4e,-(sp)
	trap	#1		; Leta efter filen
	addq.l	#8,sp
	tst.w	d0
	bne.s	filenotfoundthensaveit
	lea	overwrite1,a5	; Fr†ga om jag verkligen skall spara
	lea	overwrite2,a6	; ”ver filen
	bsr	makeform
	tst.w	d0
	bne	intesparamodulcancel
filenotfoundthensaveit:
	clr.w	-(sp)
	pea	wholename
	move.w	#$3c,-(sp)
	trap	#1			; Skapa filen
	addq.w	#8,sp
	tst.l	d0
	bmi	couldnotcreatefile
	move.w	d0,handle

	lea	song,a0
	moveq	#0,d0
	move.b	songlength,d0
	add.w	d0,a0
	neg.w	d0			; Se till s† att den delen
	add.w	#$80,d0			; av songen som ligger ”ver songl„ngden
	subq.w	#1,d0			; „r tom s† vi inte sparar en massa
	bmi.s	fulltanv„ndapattern	; on”dig data
rensadendelenavsongensominteanv„nds:
	clr.b	(a0)+
	dbra	d0,rensadendelenavsongensominteanv„nds
fulltanv„ndapattern:

	moveq	#20,d0
	lea	songname,a0		; Spara s†ngnamnet
	bsr	savethisblock
	tst.l	d0
	bmi	†terst„llsamplingefterfelvidsparning

	move.l	#30*31,d0
	lea	modsamsave,a0
	bsr	savethisblock		; Spara infon om samplingarna
	tst.l	d0
	bmi	†terst„llsamplingefterfelvidsparning

	lea	antalkanalertabell1,a0
	tst.w	basspeed
	beq.s	hastigheten„r16
	bpl.s	hastigheten„r25
	lea	antalkanalertabell2,a0
	bra.s	hastigheten„r16
hastigheten„r25:
	lea	antalkanalertabell3,a0
hastigheten„r16:
	move.w	antalkanaler,d0		; Markera i modulen hur m†nga kanaler
	subq.w	#4,d0			; som den anv„nder
	add.w	d0,d0
	add.w	d0,d0
	move.b	(a0,d0.w),songend
	move.b	1(a0,d0.w),songend+1
	move.b	2(a0,d0.w),songend+2
	move.b	3(a0,d0.w),songend+3

	move.l	#134,d0
	lea	songlength,a0
	bsr	savethisblock		; Spara infon om songen
	tst.l	d0
	bmi	†terst„llsamplingefterfelvidsparning

	move.l	#32*64,d7
	cmp.w	#4,antalkanaler
	bne.s	intefyrakanalerattspara
	move.l	#16*64,d7
intefyrakanalerattspara:		; Dax att spara alla patterns
	cmp.w	#6,antalkanaler
	bne.s	intesexkanalerattspara
	move.l	#24*64,d7
intesexkanalerattspara:			; Dax att spara alla patterns
	bsr	hittastorstapatternetisongen
	move.l	d0,d6
	move.l	patterns,a6
huvudloopvidsparningavpatterna:
	lea	formbak,a0
	cmp.w	#4,antalkanaler
	bne.s	mer„n4kanalerattspara
	move.w	#64-1,d0
loopain4kanalertillkortbuffern:
	move.l	(a6),(a0)+
	move.l	4(a6),(a0)+		; 4 kanaler till kortbuffern
	move.l	8(a6),(a0)+
	move.l	12(a6),(a0)+
	lea	32(a6),a6
	dbra	d0,loopain4kanalertillkortbuffern
	bra.s	fyrakanaler„rikortbuffern
mer„n4kanalerattspara:
	cmp.w	#6,antalkanaler
	bne.s	mer„n6kanalerattspara
	move.w	#64-1,d0
loopain6kanalertillkortbuffern:
	move.l	(a6),(a0)+
	move.l	4(a6),(a0)+		; 6 kanaler till kortbuffern
	move.l	8(a6),(a0)+
	move.l	12(a6),(a0)+
	move.l	16(a6),(a0)+	
	move.l	20(a6),(a0)+
	lea	32(a6),a6
	dbra	d0,loopain6kanalertillkortbuffern
	bra.s	fyrakanaler„rikortbuffern
mer„n6kanalerattspara:
	move.w	#64-1,d0
loopainmer„n4kanalertillkortbuffern:
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+		; 8 kanaler till kortbuffern
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	dbra	d0,loopainmer„n4kanalertillkortbuffern
fyrakanaler„rikortbuffern:
	lea	formbak,a0
	move.l	d7,d0
	bsr	savethisblock		; Spara ett pattern
	tst.l	d0
	bmi	†terst„llsamplingefterfelvidsparning
	dbra	d6,huvudloopvidsparningavpatterna

	move.w	#1,whichsample
	moveq	#31-1,d7
	lea	modsamsave,a6		; Spara alla anv„nda samplingar
	lea	samplestarts,a5
loopaigenomallasamplingar23:
	movem.l	d7/a5/a6,-(sp)
	lea	whichsample+1,a3	; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#49,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
	bsr	skrivuttillhorandeinfo
	addq.w	#1,whichsample
	movem.l	(sp)+,d7/a5/a6

	tst.w	22(a6)
	beq.s	entomsamplingingendataattspara
	move.l	32*4(a5),a0
	move.l	(a5),a1
	add.w	22(a6),a1
	add.w	22(a6),a1
	lea	1000(a1),a1		; Flytta tillbaka lite
	moveq	#125-1,d0		; samplingsdata
flyttatebaxsamplingsdata2:
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d0,flyttatebaxsamplingsdata2
	move.l	(a5),a0
	moveq	#0,d0
	move.w	22(a6),d0
	add.l	d0,d0
	bsr	savethisblock		; Spara en sampling
	tst.l	d0
	bmi.s	†terst„llsamplingefterfelvidsparning
entomsamplingingendataattspara:
	lea	30(a6),a6
	addq.w	#4,a5
	dbra	d7,loopaigenomallasamplingar23

†terst„llsamplingefterfelvidsparning:
	moveq	#31-1,d7
	lea	samplestarts,a6
	lea	modsam,a5
s„tttillbakaloopdatan:			; S„tt tillbaka s† att vi kan
	tst.w	32*30+22(a5)		; loopa samplingen igen
	beq.s	entomsamplingingetattpillap†
	bsr	flyttaomsamplingsdatans†attvikanloopaden
entomsamplingingetattpillap†:
	lea	30(a5),a5
	addq.w	#4,a6
	dbra	d7,s„tttillbakaloopdatan

	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1			; St„ng filen
	addq.w	#4,sp
	tst.w	d0
	bmi	kanejstanga

	move.w	#1,whichsample
	lea	whichsample+1,a3	; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#49,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
	bsr	skrivuttillhorandeinfo
intesparamodulcancel:
	move.b	#199,linestowait
	rts

antalkanalertabell1:
	dc.b	'M.K.'
	dc.b	'M.K.'
	dc.b	'CD61'
	dc.b	'CD61'
	dc.b	'CD81'
	dc.b	'CD81'

antalkanalertabell2:
	dc.b	'CD42'
	dc.b	'CD42'
	dc.b	'CD62'
	dc.b	'CD62'
	dc.b	'CD82'
	dc.b	'CD82'

antalkanalertabell3:
	dc.b	'CD43'
	dc.b	'CD43'
	dc.b	'CD63'
	dc.b	'CD63'
	dc.b	'CD83'
	dc.b	'CD83'

savethisblock:		; a0 buffer som skall sparas    d0 hur m†nga bytes som skall sparas
	move.l	d0,d4	; d4 extra bufferh†llare
	movem.l	d4/d5/d6/a4/a5/a6,-(sp)
	move.l	a0,-(sp)
	move.l	d0,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	movem.l	(sp)+,d4/d5/d6/a4/a5/a6
	cmp.l	d0,d4
	bne.s	filewriteerror
	rts

datasave:
	ds.l	16


filewriteerror:
	move.b	#199,linestowait
	lea	nowrite1,a5		; Meddela att det blev fel
	lea	nowrite2,a6		; vid skrivning till filen
	bsr	makejeppform
	move.b	#255,linestowait
	moveq	#-1,d0
	rts

couldnotcreatefile:
	move.b	#199,linestowait
	lea	nocreate1,a5
	lea	dummystrang,a6
	bsr	makejeppform
	moveq	#-1,d0
	rts

laddaensampling:
	tst.w	termodyonoff
	bne	inteladdasamplingcancel

	tst.w	whichsample
	beq	inte„ndraeftersomdet„r0an9
	move.l	#loadasamplestring,messagepointer

	jsr	v„ntap†sl„pp2343434
	jsr	reinstallsystem 	; Installera systemet igen

	move.l	sp,dummen
	move.l	oldstack,-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa tebax till user
	addq.l	#6,sp

	jsr	forceredrawofGEMscreen
	lea	label,a1
	lea	name,a2 		; Visa filv„ljaren
	lea	path,a3
	jsr	fsel_exinput
	move.w	d0,dummen2
	move.w	d1,dummen2+2

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa upp i super
	addq.l	#6,sp
	move.l	dummen,sp

	jsr	myownsystem		; S„tt upp TRACKERsystemet
	tst.w	dummen2
	beq	gemerror
	tst.w	dummen2+2
	beq	inteladdasamplingcancel

	bsr	stopknapp

	lea	sample,a5
	move.w	#1100*3*2/4,d5
rensaspelbuffern:			; Rensa playbuffern
	clr.l	(a5)+
	dbra	d5,rensaspelbuffern

	moveq	#0,d0
	move.w	whichsample,d0
	subq.w	#1,d0		; Žr jag p† v„g att ladda ”ver en sampling?
	add.w	d0,d0
	add.w	d0,d0
	add.l	#samplestarts,d0
	move.l	d0,a0
	move.l	a0,pekaretillsampekaretabellen
	cmp.l	#dummy,(a0)
	beq.s	laddainennysnu
	move.l	a0,-(sp)
	lea	overload1,a5	; Fr†ga om jag verkligen skall ladda ”ver den!
	lea	overload2,a6
	bsr	makeform
	move.l	(sp)+,a0
	tst.w	d0
	bne	inteladdasamplingcancel
	bsr	felvidlasningslappdenna
laddainennysnu:
	lea	path,a0
	lea	name,a1
	bsr	makeawholename

	move.b	#255,linestowait

	pea	dta2
	move.w	#$1a,-(sp)
	trap	#1		; S„tt r„tt dtabuffer
	addq.l	#6,sp
	clr.w	-(sp)
	pea	wholename
	move.w	#$4e,-(sp)
	trap	#1		; Leta efter filen
	addq.l	#8,sp
	tst.w	d0
	bne	filenotfound

	moveq	#11-1,d0
	lea	dta,a0
	lea	dta2,a1
	cmp.l	#$FFFE,26(a1)
	ble.s	inteinteitne
	move.l	#$FFFE,26(a1)
inteinteitne:
	and.l	#$FFFE,26(a1)
sdfsdsd:move.l	(a1)+,(a0)+
	dbra	d0,sdfsdsd

	lea	dta2,a0
	add.l	#2000,26(a0)	; 2000 s„kerhetsbytes
	move.l	26(a0),d0
	lea	pekaretillsampekaretabellen,a0
	move.l	(a0),a0
	moveq	#0,d1
	jsr	malloc		; Beg„r minne f”r samplingen
	tst.l	d0
	bne.s	inteoutofmemoryerror
	move.l	a0,-(sp)
	bsr	outofmemoryerror
	move.l	(sp)+,a0
	bra	felvidlasningslappdenna
inteoutofmemoryerror:

	move.l	pekaretillsampekaretabellen,a0
	move.l	d0,hum
	move.l	d0,d1
	lea	dta,a1		; Spar undan pekaren till vart gammal
	add.l	26(a1),d1	; samplingsdata finns
	add.l	#1000,d1
	move.l	d1,32*4(a0)

	lea	dta,a0
	move.l	#wholename,filnamn
	move.l	26(a0),laslangd 	; Ok, ladda in filen
	move.l	pekaretillsampekaretabellen,a0
	move.l	(a0),lasbuffer
	bsr	loadwholefile

	move.b	#199,linestowait

	move.l	pekaretillsampekaretabellen,a0
	tst.w	d0
	bpl.s	hopp23
	bsr	felvidlasningslappdenna
	bra	inteladdasamplingcancel
hopp23:
	move.l	lasbuffer,a0
	cmp.l	#'2BIT',(a0)
	beq	det„renAVR
	cmp.l	#'FORM',(a0)
	bne	det„rinteenAVRsampling

	move.l	lasbuffer,a1
	move.w	whichsample,d0
	subq.w	#1,d0			; Installera sampledata f”r
	mulu	#$1E,d0			; en IFF-sampling
	add.l	#modsam,d0
	move.l	d0,a5
	lea	32*30(a5),a5
	move.l	a5,a3
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.w	#$2000,(a5)+
	lea	name,a4
	bsr	kopieranamnet
	move.w	$16(a1),(a5)
	lsr.w	(a5)+
	move.w	$18(a1),-32*30(a5)
	move.w	$18(a1),(a5)+
	move.w	$1c(a1),(a5)
	lsr.w	(a5)+
	move.w	$20(a1),(a5)
	lsr.w	(a5)+

	lea	dta,a0
	move.l	26(a0),d0
	move.l	lasbuffer,a0
	lea.l	$2A(a0),a1
	sub.l	#$2A,d0		; Flytta bort headern i sampligen
	lsr.l	#1,d0
flyttabortheader2:
	move.w	(a1)+,(a0)+
	subq.l	#1,d0
	bne.s	flyttabortheader2

	move.l	hum,a2
	lea	1000(a0),a0
	move.w	#1000/4-1,d0		; Spar undan lite data
koppauppsamplingentilldeth”gre2232:
	move.l	(a2)+,(a0)+
	dbra	d0,koppauppsamplingentilldeth”gre2232

	bsr	s„ttlooplength		; S„tt loopl„ngden

	bra	detvarenAVRare
det„renAVR:
	tst.w	12(a0)
	beq.s	det„renmonosampling
	lea	warning,a5		; Varna om det „r en stereo-
	lea	stsam,a6		; sampling. Dock ingen konvertering
	bsr	makejeppform		; eftersom UCDM kan kanske spela
det„renmonosampling:			; stereosamplingar
	move.l	lasbuffer,a0
	cmp.w	#8,14(a0)
	beq.s	det„ren8bitarssampling
	lea	warning,a5		; Varna om det „r en 16-bits sampling
	lea	bit16sam,a6
	bsr	makejeppform
det„ren8bitarssampling:
	move.l	lasbuffer,a0
	tst.w	16(a0)			; Skall vi konvertera samplingen
	bne.s	det„rensigneradsampling	; till signerat format?
	lea	dta,a0
	move.l	26(a0),d0
	move.l	lasbuffer,a0
	sub.l	#128,d0
	move.w	#128,d1		; Konvertera sampligen till r„tt format
	lea	128(a0),a0
konverteratillsignerat:
	add.b	d1,(a0)+
	subq.l	#1,d0
	bne.s	konverteratillsignerat
det„rensigneradsampling:

	moveq	#0,d6
	moveq	#1,d7		; Kolla loopstart och loopend
	move.l	lasbuffer,a0
	tst.w	18(a0)
	beq.s	det„renoloopadsampling
	move.w	32(a0),d6
	move.l	34(a0),d0
	sub.l	30(a0),d0
	move.w	d0,d7
	lsr.w	#1,d6
	lsr.w	#1,d7
det„renoloopadsampling:
	lea	dta,a1
	move.w	whichsample,d0
	subq.w	#1,d0			; Installera sampledata
	mulu	#$1E,d0
	add.l	#modsam,d0
	move.l	d0,a5
	move.w	#$0040,24(a5)
	lea	32*30(a5),a5
	move.l	a5,a6
	move.l	4(a0),(a5)+	; Kopiera in namnet
	move.l	8(a0),(a5)+
	move.l	44(a0),(a5)+
	move.l	48(a0),(a5)+
	move.l	52(a0),(a5)+
	move.w	56(a0),(a5)+
	move.l	26(a1),d0
	sub.l	#128,d0
	lsr.w	#1,d0
	move.w	d0,(a5)+
	move.w	#$0040,(a5)+
	move.w	d6,(a5)+
	move.w	d7,(a5)+
	moveq	#21-1,d0
s„ttspaced„rdetfinnsnollor:
	tst.b	(a6)		; Se till att det inte finns n†gra nollor
	bne.s	det„rinteennollaiAVRen	; i namnet
	move.b	#' ',(a6)
det„rinteennollaiAVRen:
	addq.w	#1,a6
	dbra	d0,s„ttspaced„rdetfinnsnollor
	clr.b	(a6)

	lea	dta,a0
	move.l	26(a0),d0
	move.l	lasbuffer,a0
	lea.l	128(a0),a1
	sub.l	#128,d0		; Flytta bort headern i sampligen
	lsr.l	#1,d0
flyttabortheader:
	move.w	(a1)+,(a0)+
	subq.l	#1,d0
	bne.s	flyttabortheader

	move.l	hum,a2
	lea	1000(a0),a0
	move.w	#1000/4-1,d0		; Spar undan lite data
koppauppsamplingentilldeth”gre23:
	move.l	(a2)+,(a0)+
	dbra	d0,koppauppsamplingentilldeth”gre23

	bsr	s„ttlooplength		; S„tt loopl„ngden

	bra	detvarenAVRare
det„rinteenAVRsampling:
	lea	signerad1,a5
	lea	signerad2,a6
	jsr	makeform
	tst.w	d0
	bpl.s	intekonverteratillsignerad
	lea	dta,a0
	move.l	26(a0),d0
	move.l	lasbuffer,a0
	move.w	#128,d1		; Konvertera sampligen till r„tt format
konverteratillsignerat2:
	add.b	d1,(a0)+
	subq.l	#1,d0
	bne.s	konverteratillsignerat2
intekonverteratillsignerad:
	lea	dta,a1
	move.w	whichsample,d0
	subq.w	#1,d0			; Installera sampledata f”r
	mulu	#$1E,d0			; en RAW-sampling
	add.l	#modsam,d0
	move.l	d0,a5
	lea	32*30(a5),a6
	move.l	a5,a3
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	26(a1),(a5)+
	move.w	#$0040,(a5)+
	clr.l	(a5)+
	move.l	a6,a5
	move.l	a5,a3
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.w	#$2000,(a5)+
	lea	name,a4
	bsr.s	kopieranamnet
	move.w	28(a1),(a5)
	lsr.w	(a5)+
	move.w	#$0040,(a5)+
	clr.w	(a5)+
	move.w	#1,(a5)+
	move.l	hum,a2
	move.l	a2,a3
	add.l	26(a1),a3	; .w #28
	lea	1000(a3),a3
	move.w	#1000/4-1,d0
koppauppsamplingentilldeth”gre:
	move.l	(a2)+,(a3)+
	dbra	d0,koppauppsamplingentilldeth”gre
detvarenAVRare:
	bsr	skrivuttillhorandeinfo
inteladdasamplingcancel:
inte„ndraeftersomdet„r0an9:
	move.w	#-1,currentsample
	jsr	checkifsamplechanged
	rts


hum:	dc.l	0

kopieranamnet:
	tst.b	(a4)
	beq.s	slutauppmedattkopieranamnet
	move.b	(a4)+,(a3)+
	bra.s	kopieranamnet
slutauppmedattkopieranamnet:
	rts

felvidlasningslappdenna:
	move.l	a0,a1
	move.l	(a0),a0
	jsr	free
	move.l	a1,a0
	move.l	#dummy,(a0)

	move.b	#199,linestowait

	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsam,d0
	move.l	d0,a5			; terst„ll all sampledata
	lea	32*30(a5),a6
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#$20000000,(a5)+
	move.w	#$40,(a5)+
	clr.l	(a5)+
	move.l	a6,a5
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.w	#$2000,(a5)+
	clr.w	(a5)+
	move.w	#$40,(a5)+
	clr.w	(a5)+
	move.w	#1,(a5)+
	bsr	skrivuttillhorandeinfo
	rts

hoppasnabbtf”rbi:
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsam,d0
	move.l	d0,a5			; terst„ll all sampledata
	lea	32*30(a5),a6
	lea	20(a5),a5
	clr.l	(a5)+
	move.w	#$0,(a5)+
	clr.l	(a5)+
	move.l	a6,a5
	lea	22(a5),a5
	clr.w	(a5)+
	move.w	#$40,(a5)+
	clr.w	(a5)+
	move.w	#1,(a5)+
	bsr	skrivuttillhorandeinfo
	rts


loadwholefile:
	clr.w	-(sp)			; L„ser in en fil
	move.l	filnamn,-(sp)
	move.w	#$3d,-(sp)
	trap	#1			; ™ppna fil
	addq.l	#8,sp
	tst.l	d0
	bmi.s	kanejoppna
	move.w	d0,handle

	move.l	lasbuffer,-(sp)
	move.l	laslangd,-(sp)
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1			; L„s fil
	lea	12(sp),sp
	cmp.l	laslangd,d0
	bne.s	kanejlasainhela

	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1			; St„ng fil
	addq.l	#4,sp
	tst.w	d0
	bmi.s	kanejstanga
	clr.w	d0
	rts

kanejstanga:
	move.b	#199,linestowait
	lea	noclose1,a5
	lea	dummystrang,a6
	bsr	makejeppform
	moveq	#-1,d0
	rts

kanejlasainhela:
	move.b	#199,linestowait
	lea	noread1,a5
	lea	dummystrang,a6
	bsr	makejeppform
	moveq	#-1,d0
	rts

kanejoppna:
	move.b	#199,linestowait
	lea	noopen1,a5
	lea	dummystrang,a6
	bsr	makejeppform
	moveq	#-1,d0
	rts


pekaretillsampekaretabellen:
	dc.l	0

outofmemoryerror:
	move.b	#199,linestowait
	lea	outofmemoryerror1,a5
	lea	dummystrang,a6
	bsr	makejeppform
	rts

filenotfound:
	move.b	#199,linestowait
	lea	filenotfounderror1,a5
	lea	dummystrang,a6
	bsr	makejeppform
	rts

dta:	ds.b	44
dta2:	ds.b	44

makeawholename:
	lea	wholename,a2
	move.l	a0,a4
searchforendofpath:
	tst.b	(a0)			; Leta reda p† nollan
	beq.s	slutetpapath
	addq.l	#1,a0
	bra.s	searchforendofpath
slutetpapath:
	cmp.b	#'\',(a0)
	beq.s	forstaslachen		; Leta bak†t efter f”rsta \
	subq.l	#1,a0
	bra.s	slutetpapath
forstaslachen:
	move.l	a4,a3
skrivditnyapathen:
	cmp.l	a3,a0			; Kopiera ”ver pathen till wholename
	blt.s	skrivithelapathen
	move.b	(a3)+,(a2)+
	bra.s	skrivditnyapathen
skrivithelapathen:
	tst.b	(a1)
	beq.s	skrivithelanamnet
	move.b	(a1)+,(a2)+		; Kopiera ”ver filnamnet
	bra.s	skrivithelapathen
skrivithelanamnet:
	clr.b	(a2)+			; 0a p† slutet oxo
	rts

myerrorhandler: 		; Felhandler vid diskaccess
	move.l	sp,d0
	movem.l d1-d7/a0-a6,-(sp)
	lea	dummen2,a1
	move.w	#$8248,a0
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	d0,a0
	cmp.w	#-17,4(a0)		; Diskettbyte?
	beq.s	requirediskab
	move.w	4(a0),d0
	lea	errorcolor,a0
	move.w	#$8248,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	lea	diskerror1,a5
	neg.w	d0
	subq.w	#1,d0
	mulu	#15,d0
	add.w	d0,a5
	lea	diskerror2,a6
	bsr	makeform
	tst.w	d0
	bne.s	abortwitherror
	move.l	#$00010000,d0
	bra.s	aborta

abortwitherror:
	moveq	#-1,d0
aborta: lea	dummen2,a0
	move.w	#$8248,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	movem.l (sp)+,d1-d7/a0-a6
	rts

requirediskab:			; Byt till disk A/B
	move.w	6(a0),d0
	add.b	#'A',d0
	move.b	d0,diskbokstav
	lea	diskaberror1,a5
	lea	diskaberror2,a6
	bsr	makejeppform
	move.l	#$00010000,d0
	bra.s	aborta

dummen2:ds.w	16

gemerror:
	move.b	#199,linestowait
	lea	gemerror1,a5
	lea	gemerror2,a6
	bsr	makejeppform
	rts

;================================= Tar hand om infon om var, n„r hur h„r ==

moveuseingslider:
	sub.w	#106,d7
	bpl.s	den„rintemindre„nslidern
	clr.w	lastpos			; Slidern „r i toppen
	bra.s	s„ttpositioneneftermusen
den„rintemindre„nslidern:
	cmp.w	#128,d7
	blt.s	intemaxhellerp†slidern
	move.w	#$800-$20,lastpos	; Slidern „r i botten
	bra.s	s„ttpositioneneftermusen
intemaxhellerp†slidern:
	and.l	#$fffe,d7
	lsl.w	#5-1,d7			; S„tt slidern efter musen
	move.w	d7,lastpos
s„ttpositioneneftermusen:
	move.w	#-1,counter
	move.w	lastpos,pattpos
	rts

movecursor:			; Rutinen som tar hand om placeringen av
	tst.w	lowershower
	bne	vivisarsampleeditorintepatternet
	sub.w	#16,d6
	bpl.s	xharinteblivitnegativt
	clr.w	d6
xharinteblivitnegativt:
	lsr.w	#3,d6		; cursorn med musen
	lea	xsteppingrate,a0
	add.w	d6,d6
	move.w	(a0,d6.w),cursorx
	move.l	oldcursorpek,a6
	clr.b	(a6)
	clr.b	1848(a6)

	cmp.w	#156,d7
	bgt.s	inteminskapapatternet
	neg.w	d7
	add.w	#156,d7
	divu	#6,d7
	addq.w	#1,d7
	lsl.w	#5,d7
	and.l	#$7fff,d7
	sub.w	d7,pattpos
	tst.w	pattpos
	bpl.s	slutanu
	add.w	#$800,pattpos
slutanu:
	move.w	speed,counter
	move.w	#1,hoppa”veradderingendenh„rg†ngen
	rts
inteminskapapatternet:
	cmp.w	#183,d7
	blt.s	inteokapapatternetalls
	sub.w	#183,d7
	divu	#6,d7
	addq.w	#1,d7
	lsl.w	#5,d7
	and.l	#$7fff,d7
	add.w	d7,pattpos
	cmp.w	#$800-$20,pattpos
	ble.s	inteokapapatternet
	sub.w	#$800,pattpos
inteokapapatternet:
	move.w	speed,counter
	move.w	#1,hoppa”veradderingendenh„rg†ngen
inteokapapatternetalls:
	rts

vivisarsampleeditorintepatternet:
	sub.w	#16,d6
	bpl.s	xharinteblivitnegativtnu2
	clr.w	d6
xharinteblivitnegativtnu2:
	lsr.w	#2,d6		; cursorn med musen
	lea	medxsteppingrate,a0
	add.w	d6,d6
	add.w	d6,d6
	move.w	(a0,d6.w),cursorx
	move.w	2(a0,d6.w),startkanal
	cmp.w	#4,antalkanaler
	bne.s	intekollaom4kanaler„raktiva2
	cmp.w	#2,startkanal
	blt.s	intekollaom4kanaler„raktiva2
	move.w	#1,startkanal
	move.w	#23,cursorx
intekollaom4kanaler„raktiva2:
	cmp.w	#6,antalkanaler
	bne.s	intekollaom6kanaler„raktiva2
	cmp.w	#4,startkanal
	blt.s	intekollaom6kanaler„raktiva2
	move.w	#3,startkanal
	move.w	#23,cursorx
intekollaom6kanaler„raktiva2:
	move.l	oldcursorpek,a6
	clr.b	(a6)
	clr.b	1848(a6)

	move.w	lastpos,d0
	lsr.w	#5,d0
	add.w	d0,d0
	lea	hurmycketaddera2,a0
	move.w	(a0,d0.w),d1
	divu	#960/6,d1
	sub.w	#105,d7
	bpl.s	interensad7
	moveq	#0,d7
interensad7:
	add.w	d1,d7
	divu	#6,d7
	lsl.w	#5,d7
	and.l	#$7fff,d7
	move.w	d7,pattpos
	cmp.w	#$800-$20,pattpos
	ble.s	inteswappapatternet2
	move.w	#$800-$20,pattpos
inteswappapatternet2:
	move.w	speed,counter
	move.w	#1,hoppa”veradderingendenh„rg†ngen
	move.w	startkanal,d5
	lsl.w	#4,d5
	jsr	skrivutkanalinfon
	rts


xsteppingrate:
	dc.w	0,0,0,0,0,0,0,1,2,3,4,5,6,6,6,6,7,8,9,10,11,12,12,12,12,13,14,15
	dc.w	16,17,18,18,18,18,19,20,21,22,23,23,23,23,23,23




laggtill1isongen:		; L„gg till 1 i songen
	cmp.b	#$7f,songpos
	beq.s	ingenaddalls
	cmp.b	#$80,songlength
	beq.s	ingenaddalls
	moveq	#0,d0
	move.b	songpos,d0
	neg.w	d0
	add.w	#$7e,d0
	lea	songend,a0
	lea	-1(a0),a1
looparuntochlaggtillisong:
	move.b	-(a1),-(a0)
	dbra	d0,looparuntochlaggtillisong
	addq.b	#1,songlength
	lea	songlength,a3		; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#26,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
ingenaddalls:
	rts

draifran1isongen:		; Ta bort 1 i songen
	move.b	songpos,d0
	addq.b	#1,d0
	cmp.b	songlength,d0
	beq	ingensuballs
	cmp.b	#$1,songlength
	beq	ingensuballs
	moveq	#0,d0
	move.b	songpos,d0
	neg.w	d0
	add.w	#$7e,d0
	moveq	#0,d1
	move.b	songpos,d1
	add.l	#song,d1
	move.l	d1,a0
	lea	1(a0),a1
	move.b	1(a0),whichpatt+1
looparuntochdraifranisong:
	move.b	(a1)+,(a0)+
	dbra	d0,looparuntochdraifranisong
	subq.b	#1,songlength
	lea	songlength,a3		; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#26,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
	lea	whichpatt+1,a3		; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#16,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
	bsr	hittastorstapatternetisongen
	cmp.b	songrestart,d0
	bge.s	ingensuballs
	move.b	d0,songrestart
	lea	songrestart,a3		; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#36,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
ingensuballs:

	rts

addloopstart:				; ™ka loopstarten
	tst.w	whichsample
	beq.s	inte„ndraeftersomdet„r0an1
	move.l	#s„ttloopstart,afterthesetting
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsam,d0
	move.l	d0,a5
	lea	32*30(a5),a5
	tst.w	22(a5)
	beq.s	oppsentomsamplingiaddloopstart
	btst.l	#0,d5			; Testa om jag h†ller nere h”ger musknapp
	beq.s	inteh”geriaddloopstart
	add.w	#$10,26(a5)
	bra.s	h”geriaddloopstart
inteh”geriaddloopstart:
	addq.w	#$1,26(a5)
h”geriaddloopstart:
	moveq	#0,d2
	moveq	#0,d3
	move.w	26(a5),d2
	add.w	28(a5),d2		; Kolla s† att inte loopingen
	move.w	22(a5),d3
	cmp.l	d3,d2			; blir l„ngre „n l„ngden p†
	blt.s	intel„greaddloopstart	; samplingen
	moveq	#0,d2
	move.w	22(a5),d2
	sub.w	28(a5),d2
	move.w	d2,26(a5)
intel„greaddloopstart:
	bsr	skrivuttillhorandeinfo
oppsentomsamplingiaddloopstart:
inte„ndraeftersomdet„r0an1:
	rts

subloopstart:				; Minska loopstarten
	tst.w	whichsample
	beq.s	inte„ndraeftersomdet„r0an2
	move.l	#s„ttloopstart,afterthesetting
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsam,d0
	move.l	d0,a5
	lea	32*30(a5),a5
	tst.w	22(a5)
	beq.s	oppsentomsamplingisubloopstart
	btst.l	#0,d5			; Testa om jag h†ller nere h”ger musknapp
	beq.s	inteh”gerisubloopstart
	sub.w	#$10,26(a5)
	bra.s	h”gerisubloopstart
inteh”gerisubloopstart:
	subq.w	#$1,26(a5)
h”gerisubloopstart:
	tst.w	26(a5)			; Kolla s† att inte loopstarten
	bpl.s	intel„gresubloopstart	; blir negativ
	clr.w	26(a5)
intel„gresubloopstart:
	bsr	skrivuttillhorandeinfo
oppsentomsamplingisubloopstart:
inte„ndraeftersomdet„r0an2:
	rts


s„ttloopstart:				; Rutinen som verkligen s„tter
	moveq	#0,d0			; loopstarten i f”rh†llande
	move.w	whichsample,d0		; till inmatat v„rde
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsam,d0
	move.l	d0,a5
	moveq	#0,d0
	move.w	whichsample,d0
	subq.w	#1,d0
	add.w	d0,d0
	add.w	d0,d0
	add.l	#samplestarts,d0
	move.l	d0,a6
	tst.w	32*30+22(a5)
	beq.s	oppsdetvarentomdj„velistarten
	move.w	#1,donotdoanymusicorsomeshit	; Ge FAN i a5 o a6

	cmp.l	#1,32*30+26(a5)
	bne.s	intes†l„tt2
	move.w	32*30+22(a5),d0		; Ingen loop alls
	add.w	32*30+22(a5),d0
	move.l	d0,20(a5)
	clr.l	26(a5)
	bra.s	okletsgowiththis2
intes†l„tt2:


	moveq	#0,d0
	move.w	32*30+26(a5),d0
	add.w	d0,d0
	move.l	d0,20(a5)


okletsgowiththis2:
	bsr	flyttaomsamplingsdatans†attvikanloopaden
	clr.w	donotdoanymusicorsomeshit
oppsdetvarentomdj„velistarten:
	rts

gammall„ngd:
	dc.w	0

addsamlength:				; ™ka samplel„ngden
	tst.w	whichsample
	beq.s	inte„ndraeftersomdet„r0an155
	move.l	#s„ttsamlength,afterthesetting
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsam,d0
	move.l	d0,a5
	lea	32*30(a5),a5
	tst.w	22(a5)
	beq.s	oppsentomsamplingiaddsamlength
	tst.w	gammall„ngd
	bne.s	s„ttintegammall„ngdiaddsamlength
	move.w	22(a5),gammall„ngd
s„ttintegammall„ngdiaddsamlength:
	btst.l	#0,d5			; Testa om jag h†ller nere h”ger musknapp
	beq.s	inteh”geriaddsamlength
	add.w	#$10,22(a5)
	bra.s	h”geriaddsamlength
inteh”geriaddsamlength:
	addq.w	#$1,22(a5)
h”geriaddsamlength:
	tst.w	22(a5)
	bpl.s	intemaxl„ngdp†samen
	move.w	#$7FFF,22(a5)
intemaxl„ngdp†samen:
	bsr	skrivuttillhorandeinfo
oppsentomsamplingiaddsamlength:
inte„ndraeftersomdet„r0an155:
	rts

subsamlength:				; Minska samplel„ngden
	tst.w	whichsample
	beq.s	inte„ndraeftersomdet„r0an255
	move.l	#s„ttsamlength,afterthesetting
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsam,d0
	move.l	d0,a5
	lea	32*30(a5),a5
	tst.w	22(a5)
	beq.s	oppsentomsamplingisubsamlength
	tst.w	gammall„ngd
	bne.s	s„ttintegammall„ngdisubsamlength
	move.w	22(a5),gammall„ngd
s„ttintegammall„ngdisubsamlength:
	btst.l	#0,d5			; Testa om jag h†ller nere h”ger musknapp
	beq.s	inteh”gerisubsamlength
	sub.w	#$10,22(a5)
	bra.s	h”gerisubsamlength
inteh”gerisubsamlength:
	subq.w	#$1,22(a5)
h”gerisubsamlength:
	moveq	#0,d2
	move.w	26(a5),d2
	add.w	28(a5),d2
	cmp.w	22(a5),d2		; Kolla s† att inte loopstarten
	ble.s	intel„gresubsamlength	; blir mindre „n looptjossan
	move.w	d2,22(a5)
intel„gresubsamlength:
	bsr	skrivuttillhorandeinfo
oppsentomsamplingisubsamlength:
inte„ndraeftersomdet„r0an255:
	rts

s„ttsamlength:				; Rutinen som verkligen s„tter
	moveq	#0,d0			; samplel„ngden i f”rh†llande
	move.w	whichsample,d0		; till inmatat v„rde
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsam,d0
	move.l	d0,a5
	moveq	#0,d0
	move.w	whichsample,d0
	subq.w	#1,d0
	add.w	d0,d0
	add.w	d0,d0
	add.l	#samplestarts,d0
	move.l	d0,a6
	tst.w	32*30+22(a5)
	beq	oppsdetvarentomdj„velistarten12
	move.w	#1,donotdoanymusicorsomeshit	; Ge FAN i a5 o a6

	move.w	$ffff8900.w,-(sp)
	clr.b	$ffff8901.w

	move.l	32*4(a6),a0
	move.l	(a6),a1
	add.w	gammall„ngd,a1
	add.w	gammall„ngd,a1
	lea	1000(a1),a1		; Flytta tillbaka lite
	move.l	a1,a4			; samplingsdata
	moveq	#125-1,d0
flyttatebaxsamplingsdataisamset:
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	clr.l	-8(a1)
	clr.l	-4(a1)
	dbra	d0,flyttatebaxsamplingsdataisamset

	move.w	#-1,currentsample	; Se till att rita om samplingen
	movem.l	a5-a6,-(sp)
	move.l	(a6),a0
	moveq	#0,d0
	move.w	32*30+22(a5),d0
	add.w	d0,d0
	add.l	#2000,d0
	jsr	reformatmemory		; Žndra p† l„ngden
	bpl.s	detgickattformaomsamplingen
	jsr	outofmemoryerror
	moveq	#0,d0
	move.w	gammall„ngd,d0
	add.w	d0,d0
	add.l	#2000,d0
detgickattformaomsamplingen:
	sub.l	#2000,d0
	lsr.l	#1,d0
	movem.l	(sp)+,a5-a6
	move.w	d0,32*30+22(a5)

	move.l	(a6),a1
	add.w	32*30+26(a5),a1
	add.w	32*30+26(a5),a1
	add.w	32*30+28(a5),a1
	add.w	32*30+28(a5),a1
	move.l	a1,32*4(a6)
	move.l	(a6),a0
	add.w	32*30+22(a5),a0
	add.w	32*30+22(a5),a0
	lea	1000(a0),a0		; Spar undan data d„r vi skall vara
	moveq	#125-1,d0		; och pilla p† samplingen
flyttabortlitesamdataisamset:
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d0,flyttabortlitesamdataisamset

	bsr.s	s„ttlooplength
	bsr	skrivuttillhorandeinfo
	jsr	checkifsamplechanged
	move.w	(sp)+,$ffff8900.w
	clr.w	donotdoanymusicorsomeshit
	clr.w	gammall„ngd
oppsdetvarentomdj„velistarten12:
	rts




s„ttlooplength:				; Rutinen som verkligen s„tter
	moveq	#0,d0			; loopl„ngden i f”rh†llande
	move.w	whichsample,d0		; till inmatat v„rde
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsam,d0
	move.l	d0,a5
	moveq	#0,d0
	move.w	whichsample,d0
	subq.w	#1,d0
	add.w	d0,d0
	add.w	d0,d0
	add.l	#samplestarts,d0
	move.l	d0,a6
	tst.w	32*30+22(a5)
	beq.s	oppsdetvarentomdj„velil„ngden
	move.w	#1,donotdoanymusicorsomeshit	; Ge FAN i a5 o a6

	cmp.l	#1,32*30+26(a5)
	bne.s	intes†l„tt1
	move.w	32*30+22(a5),d0		; Ingen loop alls
	add.w	32*30+22(a5),d0
	move.l	d0,20(a5)
	clr.l	26(a5)
	bra.s	okletsgowiththis1
intes†l„tt1:


	moveq	#0,d0
	move.w	32*30+26(a5),d0
	add.w	d0,d0
	move.l	d0,20(a5)

	moveq	#0,d0
	move.w	32*30+28(a5),d0
	add.l	d0,d0
	move.l	d0,26(a5)


okletsgowiththis1:
	bsr.s	flyttaomsamplingsdatans†attvikanloopaden
	clr.w	donotdoanymusicorsomeshit
oppsdetvarentomdj„velil„ngden:
	rts

flyttaomsamplingsdatans†attvikanloopaden:
	move.l	32*4(a6),a0
	move.l	(a6),a1
	add.w	32*30+22(a5),a1
	add.w	32*30+22(a5),a1
	lea	1000(a1),a1		; Flytta tillbaka lite
	move.l	a1,a4			; samplingsdata
	moveq	#125-1,d0
flyttatebaxsamplingsdata:
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d0,flyttatebaxsamplingsdata	; a4 pekare mot databuffern

	move.l	(a6),a1
	add.w	32*30+26(a5),a1
	add.w	32*30+26(a5),a1
	add.w	32*30+28(a5),a1
	add.w	32*30+28(a5),a1
	move.l	a1,32*4(a6)
	move.l	a4,a0			; Spar undan data d„r vi skall vara
	moveq	#125-1,d0		; och pilla p† samplingen
flyttabortlitesamdata:
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d0,flyttabortlitesamdata

	move.l	a4,a0
	lea	-1000(a0),a0
	moveq	#0,d0			; T”m lite data i slutet
	moveq	#125-1,d1		; av samplingen
t”mf”rs„kerhetsskulllitedata:
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbra	d1,t”mf”rs„kerhetsskulllitedata

	cmp.l	#1,32*30+26(a5)		; Ifall om det inte skall vara n†gon loop
	beq.s	hoppa”verdeth„reftersomallt„rf„rdigt	; hoppa ”ver resten

	move.l	32*4(a6),a0
 	move.l	a0,a2
	move.l	(a6),a1
	add.w	32*30+26(a5),a1
	add.w	32*30+26(a5),a1
	move.w	32*30+28(a5),d0
	cmp.w	#1000/2,d0
	blt.s	intest”rre„nvaddetmaxf†rvara
	move.w	#1000/2,d0
intest”rre„nvaddetmaxf†rvara:
	move.w	d0,d1
	subq.w	#1,d0
skrivutloopdatans†l†ngtdetg†rif”rstasteget:
	move.w	(a1)+,(a0)+
	dbra	d0,skrivutloopdatans†l†ngtdetg†rif”rstasteget

	cmp.w	#1000/2,d1
	beq.s	hoppa”verdeth„reftersomallt„rf„rdigt
	move.w	#1000/2,d0
	sub.w	d1,d0
	subq.w	#1,d0
loopavidare:
	move.w	(a2)+,(a0)+
	dbra	d0,loopavidare
hoppa”verdeth„reftersomallt„rf„rdigt:

	rts

addlooplength:				; ™ka loopl„ngden
	tst.w	whichsample
	beq.s	inte„ndraeftersomdet„r0an3
	move.l	#s„ttlooplength,afterthesetting
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsam,d0
	move.l	d0,a5
	lea	32*30(a5),a5
	tst.w	22(a5)
	beq.s	oppsentomsamplingiaddlooplength
	btst.l	#0,d5			; Testa om jag h†ller nere h”ger musknapp
	beq.s	inteh”geriaddlooplength
	add.w	#$10,28(a5)
	bra.s	h”geriaddlooplength
inteh”geriaddlooplength:
	addq.w	#$1,28(a5)
h”geriaddlooplength:
	moveq	#0,d2
	moveq	#0,d3
	move.w	22(a5),d3
	move.w	26(a5),d2
	add.w	28(a5),d2		; Kolla s† att inte loopingen
	cmp.l	d3,d2			; blir l„ngre „n l„ngden p†
	blt.s	intel„greaddlooplength	; samplingen
	moveq	#0,d2
	move.w	22(a5),d2
	sub.w	26(a5),d2
	move.w	d2,28(a5)
intel„greaddlooplength:
	bsr	skrivuttillhorandeinfo
oppsentomsamplingiaddlooplength:
inte„ndraeftersomdet„r0an3:
	rts

sublooplength:
	tst.w	whichsample
	beq.s	inte„ndraeftersomdet„r0an4
	move.l	#s„ttlooplength,afterthesetting
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsam,d0
	move.l	d0,a5
	lea	32*30(a5),a5
	tst.w	22(a5)
	beq.s	oppsentomsamplingisublooplength
	btst.l	#0,d5			; Testa om jag h†ller nere h”ger musknapp
	beq.s	inteh”gerisublooplength
	sub.w	#$10,28(a5)
	bra.s	h”gerisublooplength
inteh”gerisublooplength:
	subq.w	#$1,28(a5)
h”gerisublooplength:
	cmp.w	#1,28(a5)		; Kolla s† att inte loopstarten
	bpl.s	intel„gresublooplength	; blir negativ
	move.w	#1,28(a5)
intel„gresublooplength:
	bsr	skrivuttillhorandeinfo
oppsentomsamplingisublooplength:
inte„ndraeftersomdet„r0an4:
	rts


addvolym:		; Aktuell samplevolym + 1
	tst.w	whichsample
	beq.s	inte„ndraeftersomdet„r0an5
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsam,d0
	move.l	d0,a5
	cmp.b	#$40,25(a5)
	beq.s	adderainteetttillvolym
	addq.b	#1,25(a5)
	addq.b	#1,32*30+25(a5)
	bsr	skrivuttillhorandeinfo
adderainteetttillvolym:
inte„ndraeftersomdet„r0an5:
	rts

subvolym:		; Aktuell samplevolym - 1
	tst.w	whichsample
	beq.s	inte„ndraeftersomdet„r0an6
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsam,d0
	move.l	d0,a5
	tst.b	25(a5)
	beq.s	subbainteetttillvolym
	subq.b	#1,25(a5)
	subq.b	#1,32*30+25(a5)
	bsr	skrivuttillhorandeinfo
subbainteetttillvolym:
inte„ndraeftersomdet„r0an6:
	rts

addfinetune:		; Aktuell samplefinetune + 1
	tst.w	whichsample
	beq.s	inte„ndraeftersomdet„r0an7
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsam,d0
	move.l	d0,a5
	cmp.b	#7,24(a5)
	beq.s	subbainteetttillfine
	addq.b	#1,24(a5)
	and.b	#$0F,24(a5)
	addq.b	#1,32*30+24(a5)
	and.b	#$0F,32*30+24(a5)
	bsr	skrivuttillhorandeinfo
subbainteetttillfine:
inte„ndraeftersomdet„r0an7:
	rts

subfinetune:		; Aktuell samplefinetune - 1
	tst.w	whichsample
	beq.s	inte„ndraeftersomdet„r0an8
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsam,d0
	move.l	d0,a5
	cmp.b	#8,24(a5)
	beq.s	addainteetttillfine
	subq.b	#1,24(a5)
	and.b	#$0F,24(a5)
	subq.b	#1,32*30+24(a5)
	and.b	#$0F,32*30+24(a5)
	bsr	skrivuttillhorandeinfo
addainteetttillfine:
inte„ndraeftersomdet„r0an8:
	rts


hittastorstapatternetisongen:
	lea	song,a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#127,d1
taredapastorstapatternet:
	cmp.b	(a0),d0
	bge.s	inteenstorreirestart
	move.b	(a0),d0
inteenstorreirestart:
	addq.l	#1,a0
	dbra	d1,taredapastorstapatternet
	rts

addrestart:
	moveq	#0,d0
	move.b	songlength,d0
	subq.w	#1,d0
	cmp.b	songrestart,d0
	beq.s	garinteattfastorrerestart
	addq.b	#1,songrestart
	lea	songrestart,a3		; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#36,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
garinteattfastorrerestart:
	rts

subrestart:
	tst.b	songrestart
	beq.s	salitensomrestartkanbli
	subq.b	#1,songrestart
	lea	songrestart,a3		; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#36,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
salitensomrestartkanbli:
	rts

addpatt:
	move.w	maxpatterns,d0
	subq.w	#1,d0
	cmp.b	whichpatt+1,d0
	beq.s	sorryinteflerpatt
	addq.b	#1,whichpatt+1
	moveq	#0,d0
	move.b	songpos,d0
	lea	song,a0
	add.l	d0,a0
	move.b	whichpatt+1,(a0)
	lea	whichpatt+1,a3		; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#16,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
sorryinteflerpatt:

	rts

subpatt:
	tst.b	whichpatt+1
	beq.s	sorryintefarrepatt
	subq.b	#1,whichpatt+1
	moveq	#0,d0
	move.b	songpos,d0
	lea	song,a0
	add.l	d0,a0
	move.b	whichpatt+1,(a0)
	lea	whichpatt+1,a3		; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#16,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
sorryintefarrepatt:
	rts

addpos:
	move.b	songlength,d0
	subq.b	#1,d0
	cmp.b	songpos,d0
	beq.s	samycketsomdetgarisongpos
	addq.b	#1,songpos
	lea	songpos,a3		; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#6,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
	moveq	#0,d0
	lea	song,a0
	move.b	songpos,d0
	add.l	d0,a0
	move.b	(a0),whichpatt+1
	lea	whichpatt+1,a3		; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#16,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
samycketsomdetgarisongpos:
	rts

subpos:
	tst.b	songpos
	beq.s	salitesomdetgarisongpos
	subq.b	#1,songpos
	lea	songpos,a3		; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#6,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
	moveq	#0,d0
	lea	song,a0
	move.b	songpos,d0
	add.l	d0,a0
	move.b	(a0),whichpatt+1
	lea	whichpatt+1,a3		; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#16,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
salitesomdetgarisongpos:
	rts


sampleplus:		; Adderar 1 till aktuell sampling
	cmp.w	#$1F,whichsample
	bge.s	inteentillsampling
	addq.w	#1,whichsample		; Skriv ut samplingstalet
	lea	whichsample+1,a3	; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#49,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
	bsr.s	skrivuttillhorandeinfo
	jsr	checkifsamplechanged
inteentillsampling:
	rts

sampleminus:		; Subtraherar 1 fr†n aktuell sampling
	tst.w	whichsample
	ble.s	inteenmindresampling
	subq.w	#1,whichsample		; Skriv ut samplingstalet
	lea	whichsample+1,a3	; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#49,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
	bsr.s	skrivuttillhorandeinfo
	jsr	checkifsamplechanged
inteenmindresampling:
	rts

skrivuttillhorandeinfo: 	; Skriver ut tillh”rande info till samplingen
	tst.w	whichsample
	beq	enfeaturesampling
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#30,d0
	add.l	#modsam,d0
	move.l	d0,a5
	lea	32*30(a5),a5

	lea	25(a5),a3		; Volym till samplingen
	move.w	#169,d0 		; x
	move.w	#7,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex

	moveq	#0,d0
	move.b	24(a5),d0
	and.b	#$F,d0
	add.b	d0,d0			; Skriv ut finetunen
	add.b	d0,d0
	add.l	#finetune,d0
	move.l	d0,a3
	move.w	#169,d0 		; x
	move.w	#17,d1			; y
	bsr	skrivuttext		; Skriv ut textstr„ngen

	move.w	22(a5),d0
	add.w	d0,d0
	move.w	d0,dummen
	lea	dummen,a3		; L„ngden p† samplingen
	move.w	#153,d0 		; x
	move.w	#27,d1			; y
	move.w	#4-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex

	move.w	26(a5),d0
	add.w	d0,d0
	move.w	d0,dummen
	lea	dummen,a3		; Loopstart p† samplingen
	move.w	#153,d0 		; x
	move.w	#37,d1			; y
	move.w	#4-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex

	move.w	28(a5),d0
	add.w	d0,d0
	move.w	d0,dummen
	lea	dummen,a3		; Loopl„ngden p† samplingen
	move.w	#153,d0 		; x
	move.w	#47,d1			; y
	move.w	#4-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex

	move.l	a5,a3			; Pekare till str„ng
	move.w	#80,d0			; x		Samplingsnamn
	move.w	#85,d1			; y
	bsr	skrivuttext		; Skriv ut textstr„ngen

	tst.w	showthebloodysongname
	bne	ret3
	lea	songname,a3		; Pekare till str„ng
	move.w	#80,d0			; x		Songnamn
	move.w	#75,d1			; y
	bsr	skrivuttext		; Skriv ut textstr„ngen

	rts
enfeaturesampling:
	lea	tom2,a3			; Volym till samplingen
	move.w	#169,d0 		; x
	move.w	#7,d1			; y
	bsr	skrivuttext		; T”m det som st†r d„r nu

	lea	tom2,a3			; Finetune
	move.w	#169,d0 		; x
	move.w	#17,d1			; y
	bsr	skrivuttext		; Skriv ut textstr„ngen

	lea	tom4,a3			; L„ngden p† samplingen
	move.w	#153,d0 		; x
	move.w	#27,d1			; y
	bsr	skrivuttext		; T”m det som st†r d„r nu

	lea	tom4,a3			; Loopstart p† samplingen
	move.w	#153,d0 		; x
	move.w	#37,d1			; y
	bsr	skrivuttext		; T”m det som st†r d„r nu

	lea	tom4,a3			; Loopl„ngden p† samplingen
	move.w	#153,d0 		; x
	move.w	#47,d1			; y
	bsr	skrivuttext		; T”m det som st†r d„r nu

	lea	tom21,a3		; Pekare till str„ng
	move.w	#80,d0			; x		Samplingsnamn
	move.w	#85,d1			; y
	bsr	skrivuttext		; Skriv ut textstr„ngen

	tst.w	showthebloodysongname
	bne	ret3
	lea	songname,a3		; Pekare till str„ng
	move.w	#80,d0			; x		Songnamn
	move.w	#75,d1			; y
	bsr	skrivuttext		; Skriv ut textstr„ngen
	rts
tom2:	dc.b	'  ',0
tom4:	dc.b	'    ',0
tom21:	dc.b	'(C) THE OCTALYSERTEAM',0
	even

addlength:		; Adderar 1 till l„ngden p† songen
	cmp.b	#$80,songlength
	beq.s	inteentilllength
	addq.b	#1,songlength		; Skriv ut samplingstalet
	lea	songlength,a3		; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#26,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
inteentilllength:
	rts

sublength:		; Subtraherar 1 fr†n length song
	moveq	#0,d0
	move.b	songpos,d0
	addq.b	#1,d0
	cmp.b	songlength,d0
	beq.s	inteenmindrelength
	move.b	songlength,d0
	subq.w	#1,d0
	cmp.b	songrestart,d0
	ble.s	inteenmindrelength
	subq.b	#1,songlength			; Skriv ut samplingstalet
	lea	song,a0
	moveq	#0,d0
	move.b	songlength,d0
	add.l	d0,a0
	clr.b	(a0)
	lea	songlength,a3		; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#26,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
	bsr	hittastorstapatternetisongen
inteenmindrelength:
	rts


;========================= H„r „r rutinerna som tar hand om OPTIONSmenyn ==

setmousedel:
	moveq	#88+8,d3
	lea	oldmousedel,a2
	move.l	bildminne,a0
	lea	88+8(a0),a0
	bsr	movestatusbartomousey
	lea	mousedel,a0
	add.w	d4,d4
	move.w	(a0,d4.w),mousedelay
	rts

mousedel:
	dc.w	0,2,4,6,8,10,12,14
	dc.w	16,18,20,22,24,28,30,32
	dc.w	34,36,38,40,42,44,46,48

mousedelay:
	dc.w	20

setkeydel:
	moveq	#81+8,d3
	lea	olddel,a2
	move.l	bildminne,a0
	lea	81+8(a0),a0
	bsr	movestatusbartomousey
	lea	keydel,a0
	add.w	d4,d4
	move.w	(a0,d4.w),del
	move.w	rept,keyrepeatdatainfo2
	move.w	del,keydelayrepeatdatainfo2
	rts

keydel:	dc.w	0,1,2,3,4,5,6,7,8
	dc.w	9,10,11,12,13,14,15,16
	dc.w	17,18,19,20,21,22,23,24

setkeyrep:
	moveq	#80+8,d3
	lea	oldrep,a2
	move.l	bildminne,a0
	lea	80+8(a0),a0
	bsr	movestatusbartomousey
	lea	keyrept,a0
	add.w	d4,d4
	move.w	(a0,d4.w),rept
	move.w	rept,keyrepeatdatainfo2
	move.w	del,keydelayrepeatdatainfo2
	rts

rept:	dc.w	1
del:	dc.w	10
oldrept:dc.w	0
olddela:dc.w	0

keyrept:dc.w	0,0,1,1,2,2,3,3,4,4
	dc.w	5,5,6,6,7,7,8,8
	dc.w	9,9,10,10,11,11

setmainvol:
	moveq	#65+8,d3
	lea	oldmain,a2
	move.l	bildminne,a0
	lea	65+8(a0),a0
	bsr	movestatusbartomousey
	lea	main,a0
	add.w	d4,d4
	tst.w	termodyonoff
	bne.s	s„ttvolymen„nd†eftersomenUCDManv„nds
	tst.w	lownoise
	bne.s	intes„ttavolymeneftersomallt„rtyst
s„ttvolymen„nd†eftersomenUCDManv„nds:
	move.w	#$07ff,$ffff8924.w
	move.w	(a0,d4.w),$ffff8922.w
intes„ttavolymeneftersomallt„rtyst:
	rts

main:	dc.w	%10011101000,%10011100111,%10011100110
	dc.w	%10011100101,%10011100100,%10011100011,%10011100010,%10011100001
	dc.w	%10011100000,%10011011111,%10011011110
	dc.w	%10011011101,%10011011100,%10011011011
	dc.w	%10011011010,%10011011001,%10011011000
	dc.w	%10011010111,%10011010110,%10011010101
	dc.w	%10011010100,%10011010011,%10011010010
	dc.w	%10011010001,%10011010000,%10011001111

setleftvol:
	moveq	#72+8,d3
	lea	oldleft,a2
	move.l	bildminne,a0
	lea	72+8(a0),a0
	bsr	movestatusbartomousey
setlefttooldvalue:
	lea	left,a0
	add.w	d4,d4
	move.w	#$07ff,$ffff8924.w
	move.w	(a0,d4.w),$ffff8922.w
	rts

left:	dc.w	%10101010100,%10101010011,%10101010010
	dc.w	%10101010001,%10101010000,%10101001111
	dc.w	%10101001110,%10101001101,%10101001100
	dc.w	%10101001011,%10101001010,%10101001001
	dc.w	%10101001000,%10101000111,%10101000110
	dc.w	%10101000101,%10101000100,%10101000011
	dc.w	%10101000010,%10101000001,%10101000000
	dc.w	%10101000000,%10101000000,%10101000000

setrightvol:
	moveq	#73+8,d3
	lea	oldright,a2
	move.l	bildminne,a0
	lea	73+8(a0),a0
	bsr	movestatusbartomousey
setrighttooldvalue:
	lea	right,a0
	add.w	d4,d4
	move.w	#$07ff,$ffff8924.w
	move.w	(a0,d4.w),$ffff8922.w
	rts

right:	dc.w	%10100010100,%10100010011,%10100010010
	dc.w	%10100010001,%10100010000,%10100001111
	dc.w	%10100001110,%10100001101,%10100001100
	dc.w	%10100001011,%10100001010,%10100001001
	dc.w	%10100001000,%10100000111,%10100000110
	dc.w	%10100000101,%10100000100,%10100000011
	dc.w	%10100000010,%10100000001,%10100000000
	dc.w	%10100000000,%10100000000,%10100000000




setbass:
	moveq	#57+8,d3
	lea	oldbass,a2
	move.l	bildminne,a0
	lea	57+8(a0),a0
	bsr	movestatusbartomousey
	lea	bass,a0
	add.w	d4,d4
	move.w	#$07ff,$ffff8924.w
	move.w	(a0,d4.w),$ffff8922.w
	rts

bass:	dc.w	%10001001100,%10001001011,%10001001011	; 0-2   +12,+10
	dc.w	%10001001010,%10001001010,%10001001001	; 3-5	+8 +6
	dc.w	%10001001001,%10001001000,%10001001000	; 6-8	+6 +4
	dc.w	%10001000111,%10001000111,%10001000110	; 9-11	+2 +0
	dc.w	%10001000101,%10001000101,%10001000100	; 12-14	-2 -4
	dc.w	%10001000100,%10001000011,%10001000011	; 15-17	-4 -6
	dc.w	%10001000010,%10001000010,%10001000001	; 18-20	-8 -10
	dc.w	%10001000001,%10001000000,%10001000000	; 21-23	-10 -12

settreble:
	moveq	#64+8,d3
	lea	oldtreble,a2
	move.l	bildminne,a0
	lea	64+8(a0),a0
	bsr.s	movestatusbartomousey
	lea	treble,a0
	add.w	d4,d4
	move.w	#$07ff,$ffff8924.w
	move.w	(a0,d4.w),$ffff8922.w
	rts

treble:	dc.w	%10010001100,%10010001011,%10010001011	; 0-2   +12,+10
	dc.w	%10010001010,%10010001010,%10010001001	; 3-5	+8 +6
	dc.w	%10010001001,%10010001000,%10010001000	; 6-8	+6 +4
	dc.w	%10010000111,%10010000111,%10010000110	; 9-11	+2 +0
	dc.w	%10010000101,%10010000101,%10010000100	; 12-14	-2 -4
	dc.w	%10010000100,%10010000011,%10010000011	; 15-17	-4 -6
	dc.w	%10010000010,%10010000010,%10010000001	; 18-20	-8 -10
	dc.w	%10010000001,%10010000000,%10010000000	; 21-23	-10 -12


movestatusbartomousey:		; d4 inneh†ller talet 0-22 (23 steg)
	subq.w	#2,d7		; 11 inneb„r mitten
	lea	statusbar,a1
	cmp.w	#28,d7
	bge.s	intemindreanmusy
	move.w	#28,d7
intemindreanmusy:
	cmp.w	#55-4,d7
	ble.s	intestorreanmusy
	move.w	#55-4,d7
intestorreanmusy:
	move.w	d7,d4
	sub.w	#28,d4
	move.w	(a2),d2
	move.w	d7,(a2)
	mulu	#168,d7
	mulu	#168,d2
	add.l	bildminne,d2
	add.l	d3,d2
	move.l	d2,a3
	and.b	#%10000001,(a3)
	and.b	#%10000001,2(a3)
	and.b	#%10000001,168(a3)
	and.b	#%10000001,170(a3)
	and.b	#%10000001,336(a3)
	and.b	#%10000001,338(a3)
	and.b	#%10000001,504(a3)
	and.b	#%10000001,506(a3)
	add.w	d7,a0
	move.b	(a1)+,(a0)
	move.b	(a1)+,2(a0)
	move.b	(a1)+,168(a0)
	move.b	(a1)+,170(a0)
	move.b	(a1)+,336(a0)
	move.b	(a1)+,338(a0)
	move.b	(a1)+,504(a0)
	move.b	(a1)+,506(a0)
	rts

oldbass:dc.w	39
oldtreble:
	dc.w	39
oldmain:dc.w	28
oldleft:dc.w	28
oldright:
	dc.w	28
oldrep:	dc.w	31
olddel:	dc.w	38
oldmousedel:
	dc.w	38

statusbar:
	dc.b	$FF,$7E,$C3,$7C
	dc.b	$C3,$7C,$FF,$40


okadbrasar:			; ™ka DBRAs-rutin
	cmp.w	#254,bordercounter
	bge.s	intenagraflerdbras
	clr.b	$ffff820a.w		; 60 Hz
	addq.w	#1,bordercounter
s„ttr„ttvidstartuppen:
	move.w	bordercounter,d0
	ext.l	d0
	divu	#3,d0
	move.w	d0,borderdelay
	swap	d0
	add.w	d0,d0
	add.w	d0,d0
	lea	vilkenhbl,a0
	move.l	(a0,d0.w),hbler
	move.w	bordercounter,dummen
	addq.w	#1,dummen
	lea	dummen+1,a3		; Vilket tal skall konverteras
	move.w	#281,d0 		; x
	move.w	#38,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
intenagraflerdbras:
	rts

dummen: dc.l	-32

minskadbrasar:			; Minska DBRAs-rutin
	cmp.w	#2,bordercounter
	ble.s	intenagrafarredbras
	clr.b	$ffff820a.w		; 60 Hz
	subq.w	#1,bordercounter
	move.w	bordercounter,dummen
	move.w	bordercounter,d0
	ext.l	d0
	divu	#3,d0
	move.w	d0,borderdelay
	swap	d0
	add.w	d0,d0
	add.w	d0,d0
	lea	vilkenhbl,a0
	move.l	(a0,d0.w),hbler
	addq.w	#1,dummen
	lea	dummen+1,a3		; Vilket tal skall konverteras
	move.w	#281,d0 		; x
	move.w	#38,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
intenagrafarredbras:
	rts

makeinversjamn: 		; G”r invers p† en bit x*8 stor   d7 = x
	not.b	(a2)
	not.b	168(a2)
	not.b	336(a2)
	not.b	504(a2)
	not.b	672(a2)
	not.b	840(a2)
	not.b	1008(a2)
	not.b	1176(a2)
	not.b	2(a2)
	not.b	170(a2)
	not.b	338(a2)
	not.b	506(a2)
	not.b	674(a2)
	not.b	842(a2)
	not.b	1010(a2)
	not.b	1178(a2)
	addq.l	#1,a2
	dbra	d7,makeinversojamn
	rts	

makeinversojamn:
	not.b	(a2)
	not.b	168(a2)
	not.b	336(a2)
	not.b	504(a2)
	not.b	672(a2)
	not.b	840(a2)
	not.b	1008(a2)
	not.b	1176(a2)
	not.b	2(a2)
	not.b	170(a2)
	not.b	338(a2)
	not.b	506(a2)
	not.b	674(a2)
	not.b	842(a2)
	not.b	1010(a2)
	not.b	1178(a2)
	addq.l	#7,a2
	dbra	d7,makeinversjamn
	rts	

till4kanaler:		; Rutinen som st„ller om till 4 kanaler
	cmp.w	#4,antalkanaler
	beq.s	harredandenhar4anmarkerad

	move.w	#$0010,d5
	jsr	skrivutkanalinfon

	move.l	bildminne,a0
	move.l	a0,a1			; a1 till bilden
	add.l	gamlakanalpek,a1
	move.l	a1,a2
	moveq	#1-1,d7 		; 1 bytes vidd p† notten
	bsr	makeinversjamn

	move.l	bildminne,a0
	lea	((20*168)+152)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#1-1,d7 		; 1 bytes vidd p† notten
	bsr	makeinversjamn

	move.l	#((20*168)+152)+8,gamlakanalpek
	move.w	#4,antalkanaler
	move.w	#$e580,d0
	move.w	#$e581,d1
	move.l	#128,mvol
	move.w	frekvens,d0
	add.w	d0,d0
	add.w	d0,d0
	lea	st„llinkanalerna,a0
	move.l	(a0,d0.w),a0		; Se till att installera playrutinen
	jsr	(a0)			; r„tt...
harredandenhar4anmarkerad:
	rts

till6kanaler:		; Rutinen som st„ller om till 6 kanaler
	cmp.w	#6,antalkanaler
	beq.s	harredandenhar6anmarkerad

	move.w	#$0010,d5
	jsr	skrivutkanalinfon

	move.l	bildminne,a0
	move.l	a0,a1			; a1 till bilden
	add.l	gamlakanalpek,a1
	move.l	a1,a2
	moveq	#1-1,d7 		; 1 bytes vidd p† notten
	bsr	makeinversjamn

	move.l	bildminne,a0
	lea	((28*168)+152)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#1-1,d7 		; 1 bytes vidd p† notten
	bsr	makeinversjamn

	move.l	#((28*168)+152)+8,gamlakanalpek
	move.w	#6,antalkanaler
	move.w	#$e780,d0
	move.w	#$e781,d1
	move.l	#192,mvol
	move.w	frekvens,d0
	add.w	d0,d0
	add.w	d0,d0
	lea	st„llinkanalerna,a0
	move.l	(a0,d0.w),a0		; Se till att installera playrutinen
	jsr	(a0)			; r„tt...
harredandenhar6anmarkerad:
	rts

till8kanaler:		; Rutinen som st„ller om till 8 kanaler
	cmp.w	#8,antalkanaler
	beq.s	harredandenhar8anmarkerad

	move.w	#$0010,d5
	jsr	skrivutkanalinfon

	move.l	bildminne,a0
	move.l	a0,a1			; a1 till bilden
	add.l	gamlakanalpek,a1
	move.l	a1,a2
	moveq	#1-1,d7 		; 1 bytes vidd p† notten
	bsr	makeinversjamn

	move.l	bildminne,a0
	lea	((36*168)+152)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#1-1,d7 		; 1 bytes vidd p† notten
	bsr	makeinversjamn

	move.l	#((36*168)+152)+8,gamlakanalpek
	move.w	#8,antalkanaler
	move.w	#$e780,d0
	move.w	#$e781,d1
	move.l	#256,mvol
	move.w	frekvens,d0
	add.w	d0,d0
	add.w	d0,d0
	lea	st„llinkanalerna,a0
	move.l	(a0,d0.w),a0		; Se till att installera playrutinen
	jsr	(a0)			; r„tt...
harredandenhar8anmarkerad:
	rts

st„llinkanalerna:
	dc.l	tt6,tt12,tt25,tt50


till125:		; Rutinen som st„ller om till 12.5 kHz
	cmp.w	#1,frekvens
	beq.s	harredandenhar125anmarkerad
tt12:	move.l	bildminne,a0
	move.l	a0,a1			; a1 till bilden
	add.l	gamlafrekvenspek,a1
	move.l	a1,a2
	moveq	#3-1,d7 		; 3 bytes vidd p† notten
	move.l	frekvensjsr,a5
	jsr	(a5)
	move.l	bildminne,a0
	lea	((20*168)+97)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#3-1,d7 		; 3 bytes vidd p† notten
	bsr	makeinversojamn
	move.l	#((20*168)+97)+8,gamlafrekvenspek
	move.l	#makeinversojamn,frekvensjsr


	bsr	stopknapp

	move.w	#1,frekvens
	bsr	s„ttregisterefterfreq
	bsr	setsamplereplayspeed
harredandenhar125anmarkerad:
	rts

termodyshifts:
	dc.l	0	; Hur mycket samplingarna skall shiftas
printitwhenloading:
	dc.w	0
oldtermovalpek:
	dc.l	57+(168*18)+8
currenttermody:
	dc.l	termodyn1
currenttermo:
	dc.w	0
termotones:
	dc.w	3
termodyonoff:		; 0=Off       1=On
	dc.w	0
termodypek:
	dc.l	0
termodychannels:
	dc.w	4
oldchannum:
	dc.w	0
empty8:	dc.b	'        ',0
	even
currenttermodyondisk:
	dc.l	termodyname1
termodyname1:
	dc.b	0
	ds.b	75
termodyname2:
	dc.b	0
	ds.b	75
termodyname3:
	dc.b	0
	ds.b	75
termodyname4:
	dc.b	0
	ds.b	75
vidproblemskippa:
	dc.w	0

releasecurrentplayer:
	tst.w	termodyonoff
	bne.s	finnsingenspelared„rredan
	move.l	currenttermody,a0
	tst.l	(a0)		; Om platsen redan anv„nd, sl„pp den
	beq.s	finnsingenspelared„rredan

	move.l	#-1,16(a0)	; Endast 1 patternrad skall anv„ndas vid
				; uppdatering

	move.l	(a0),a1
	clr.l	(a0)
	move.l	a1,a0
	jsr	free		; Sl„pp anv„nd spelare
	move.l	currenttermodyondisk,a0
	clr.b	(a0)		; Ingen path till spelaren

	move.l	bildminne,a0
	move.l	a0,a1			; a1 till bilden
	add.l	oldtermovalpek,a1
	move.l	a1,a2
	moveq	#8-1,d7 		; 8 bytes vidd p† notten
	bsr	makeinversojamn

	lea	empty8,a3
	move.l	bildminne,a2
	lea	168(a2),a2
	add.l	oldtermovalpek,a2
	lea	ascii,a4
	jsr	skrivuttextnastaloop	; Skriv ut textstr„ngen

	move.l	bildminne,a0
	move.l	a0,a1			; a1 till bilden
	add.l	oldtermovalpek,a1
	move.l	a1,a2
	moveq	#8-1,d7 		; 8 bytes vidd p† notten
	bsr	makeinversojamn

	bsr	skrivuthurm†ngabytes
finnsingenspelared„rredan:
	rts

loadatermody:
	tst.w	termodyonoff
	bne	inteladdatercancel
	move.w	#1,printitwhenloading
	jsr	v„ntap†sl„pp2343434
	jsr	reinstallsystem 	; Installera systemet igen

	move.l	sp,dummen
	move.l	oldstack,-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa tebax till user
	addq.l	#6,sp

	jsr	forceredrawofGEMscreen
	lea	ltlabel,a1
	lea	tername,a2 		; Visa filv„ljaren
	lea	terpath,a3
	jsr	fsel_exinput
	move.w	d0,dummen2
	move.w	d1,dummen2+2

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa upp i super
	addq.l	#6,sp
	move.l	dummen,sp

	jsr	myownsystem		; S„tt upp TRACKERsystemet
	tst.w	dummen2
	beq	gemerror
	tst.w	dummen2+2
	beq	inteladdatercancel

	move.b	#255,linestowait

	lea	sample,a5
	move.w	#1100*3*2/4,d5
rensaspelbuffern71:			; Rensa playbuffern
	clr.l	(a5)+
	dbra	d5,rensaspelbuffern71

	lea	terpath,a0
	lea	tername,a1
	bsr	makeawholename

	bsr	releasecurrentplayer	; Rensa aktuell player (om det finns n†gon)

laddainUCDM:
	pea	dta2
	move.w	#$1a,-(sp)
	trap	#1		; S„tt r„tt dtabuffer
	addq.l	#6,sp
	clr.w	-(sp)
	pea	wholename
	move.w	#$4e,-(sp)
	trap	#1		; Leta efter filen
	addq.l	#8,sp
	tst.w	d0
	beq.s	forts„ttladdabara
	tst.w	vidproblemskippa
	bne	skitilivet
	bra	filenotfoundthenloading
forts„ttladdabara:

	move.l	dta2+26,dta
	add.l	#500,dta2
	move.l	dta2+26,d0
	move.l	currenttermody,a0
	moveq	#0,d1
	jsr	malloc			; Beg„r minne f”r playern
	bne.s	forts„ttladdabara2
	tst.w	vidproblemskippa
	bne	skitilivet
	bra	ingetminnekvarf”rter
forts„ttladdabara2:

	clr.w	-(sp)
	pea	wholename
	move.w	#$3d,-(sp)
	trap	#1			; ™ppna ter-filen
	addq.l	#8,sp
	tst.l	d0
	bpl.s	forts„ttladdabara3
	tst.w	vidproblemskippa
	bne	skitilivet
	bra	kanejoppna
forts„ttladdabara3:
	move.w	d0,handle

	move.l	dta,d0		; L„ngden
	move.l	currenttermody,a0
	move.l	(a0),a0		; Ladda spelaren
	bsr	loadthisblock
	tst.w	d0
	bpl.s	intefelvidl„sningavter1
	bsr	releasecurrentplayer
	bra.s	st„ngskitennu
intefelvidl„sningavter1:
	lea	wholename,a1
	move.l	currenttermodyondisk,a2
	jsr	skrivtillsnolladockmax76tecken

	lea	tername,a0
letar„ttp†punktenistr„ngen:
	cmp.b	#'.',(a0)
	beq.s	slutmarkeranolld„r
	tst.b	(a0)
	beq.s	slutmarkeranolld„r
	addq.w	#1,a0
	bra.s	letar„ttp†punktenistr„ngen
slutmarkeranolld„r:
	clr.b	(a0)+

	move.l	bildminne,a0
	move.l	a0,a1			; a1 till bilden
	add.l	oldtermovalpek,a1
	move.l	a1,a2
	moveq	#8-1,d7 		; 8 bytes vidd p† notten
	bsr	makeinversojamn

	lea	tername,a3
	move.l	bildminne,a2
	add.l	oldtermovalpek,a2
	lea	168(a2),a2
	lea	ascii,a4
	jsr	skrivuttextnastaloop	; Skriv ut textstr„ngen

	move.l	bildminne,a0
	move.l	a0,a1			; a1 till bilden
	add.l	oldtermovalpek,a1
	move.l	a1,a2
	moveq	#8-1,d7 		; 8 bytes vidd p† notten
	bsr	makeinversojamn

	clr.b	tername

st„ngskitennu:
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1			; St„ng filen
	addq.w	#4,sp
	tst.w	d0
	bpl.s	inteladdatercancel
	tst.w	vidproblemskippa
	bne.s	skitilivet
	bra	kanejstanga
inteladdatercancel:
	bsr	skrivuthurm†ngabytes
	move.b	#199,linestowait
	clr.w	printitwhenloading
skitilivet:
	rts

ingetminnekvarf”rter:		; Finns inge minne kvar f”r spelaren
	move.b	#199,linestowait
	lea	outofmemoryerror1,a5
	lea	dummystrang,a6
	bsr	makejeppform
	bra.s	inteladdatercancel

supertermo:
	dc.l	termoval1,termoval2,termoval3,termoval4

termoval1:			; V„lj aktiv termoplayer 1
	tst.w	termodyonoff
	bne.s	termo1„rredanvald
	tst.w	currenttermo
	beq.s	termo1„rredanvald
	clr.w	currenttermo
	move.l	#termodyn1,currenttermody
	move.l	#termodyname1,currenttermodyondisk
	move.l	bildminne,a0
	move.l	a0,a1			; a1 till bilden
	add.l	oldtermovalpek,a1
	move.l	a1,a2
	moveq	#8-1,d7 		; 8 bytes vidd p† notten
	bsr	makeinversojamn
	move.l	bildminne,a0
	lea	((18*168)+57)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#8-1,d7 		; 8 bytes vidd p† notten
	bsr	makeinversojamn
	move.l	#((18*168)+57)+8,oldtermovalpek
	bsr	skrivuthurm†ngabytes
termo1„rredanvald:
	rts

termoval2:			; V„lj aktiv termoplayer 2
	tst.w	termodyonoff
	bne.s	termo2„rredanvald
	cmp.w	#1,currenttermo
	beq.s	termo2„rredanvald
	move.w	#1,currenttermo
	move.l	#termodyn2,currenttermody
	move.l	#termodyname2,currenttermodyondisk
	move.l	bildminne,a0
	move.l	a0,a1			; a1 till bilden
	add.l	oldtermovalpek,a1
	move.l	a1,a2
	moveq	#8-1,d7 		; 8 bytes vidd p† notten
	bsr	makeinversojamn
	move.l	bildminne,a0
	lea	((27*168)+57)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#8-1,d7 		; 8 bytes vidd p† notten
	bsr	makeinversojamn
	move.l	#((27*168)+57)+8,oldtermovalpek
	bsr	skrivuthurm†ngabytes
termo2„rredanvald:
	rts

termoval3:			; V„lj aktiv termoplayer 3
	tst.w	termodyonoff
	bne.s	termo3„rredanvald
	cmp.w	#2,currenttermo
	beq.s	termo3„rredanvald
	move.w	#2,currenttermo
	move.l	#termodyn3,currenttermody
	move.l	#termodyname3,currenttermodyondisk
	move.l	bildminne,a0
	move.l	a0,a1			; a1 till bilden
	add.l	oldtermovalpek,a1
	move.l	a1,a2
	moveq	#8-1,d7 		; 8 bytes vidd p† notten
	bsr	makeinversojamn
	move.l	bildminne,a0
	lea	((36*168)+57)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#8-1,d7 		; 8 bytes vidd p† notten
	bsr	makeinversojamn
	move.l	#((36*168)+57)+8,oldtermovalpek
	bsr	skrivuthurm†ngabytes
termo3„rredanvald:
	rts

termoval4:			; V„lj aktiv termoplayer 4
	tst.w	termodyonoff
	bne.s	termo4„rredanvald
	cmp.w	#3,currenttermo
	beq.s	termo4„rredanvald
	move.w	#3,currenttermo
	move.l	#termodyn4,currenttermody
	move.l	#termodyname4,currenttermodyondisk
	move.l	bildminne,a0
	move.l	a0,a1			; a1 till bilden
	add.l	oldtermovalpek,a1
	move.l	a1,a2
	moveq	#8-1,d7 		; 8 bytes vidd p† notten
	bsr	makeinversojamn
	move.l	bildminne,a0
	lea	((45*168)+57)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#8-1,d7 		; 8 bytes vidd p† notten
	bsr	makeinversojamn
	move.l	#((45*168)+57)+8,oldtermovalpek
	bsr	skrivuthurm†ngabytes
termo4„rredanvald:
	rts


usetermody:
	move.w	$ffff8900.w,gammalfart
	move.l	currenttermody,a0
	tst.l	(a0)
	beq	bahf”rs”ktes„ttaig†ngenspelaresomintefanns

	move.l	(a0),a6
	tst.w	356(a6)
	bpl.s	denklararavallafkommandons†des†
	tst.w	usetempo
	bne.s	denklararavallafkommandons†des†
	lea	notempo1,a5		; Meddela att denna spelar inte
	lea	notempo2,a6		; fungerar med tempokontroll
	jsr	makejeppform
	rts
denklararavallafkommandons†des†:
	tst.w	falkrun
	bmi.s	detta„renSTEforsure
	btst.b	#2,359(a6)		; Till Falcon?
	bne.s	denna„roxof”rSTE
	lea	notforFalc1,a5		; Meddela att denna spelar inte
	lea	notforFalc2,a6		; fungerar p† en Falcon
	jsr	makejeppform
	rts
detta„renSTEforsure:
	btst.b	#3,359(a6)
	beq.s	denna„roxof”rSTE	; Till STE?
	lea	notforSTE1,a5		; Meddela att denna spelar inte
	lea	notforSTE2,a6		; fungerar p† en STE
	jsr	makejeppform
	rts
denna„roxof”rSTE:

	move.w	#1,donotdoanymusic

	not.w	termodyonoff
	move.l	bildminne,a0
	lea	((42*168)+96)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#2-1,d7 		; 3 bytes vidd p† notten
	bsr	makeinversjamn

	move.w	oldleft,d4
	sub.w	#28,d4
	bsr	setlefttooldvalue

	tst.w	termodyonoff
	bne	sl†p†termody
	move.w	#1,donotdoanymusicorsomeshit
	tst.l	termodypek
	beq	intesl„ppatermodyneftersomdenintefinns
	move.l	termodypek,a0
	jsr	free		; Sl„pp minnet anv„nt av TERMODY
	clr.l	termodypek
	move.l	bildminne,a0
	addq.w	#2,a0		; Ta bort VU-metrarna
	move.w	#104-1,d0
	moveq	#0,d1
tabortallaVUmetrarna33:
	move.w	d1,(a0)
	lea	168(a0),a0
	dbra	d0,tabortallaVUmetrarna33

	move.l	currenttermody,a0
	move.l	(a0),a0
	jsr	8(a0)		; St„ng av TERMODYspelaren

	move.l	currenttermody,a0
	tst.l	(a0)
	beq.s	intevaltermodyatt125st„lla22
	move.l	(a0),a0
	tst.w	356(a0)
	bmi.s	intevaltermodyatt125st„lla22
	move.w	#125,356(a0)
intevaltermodyatt125st„lla22:

	move.l	termodyshifts,d4
	beq.s	„rdennolls†beh”verviinteshifta
	lea	samplestarts,a0
	lea	modsamsave,a1
	moveq	#31-1,d0
shiftauppl„mpligt:
	tst.w	22(a1)
	beq.s	entomsamplingingenshifth„rinte2
	moveq	#0,d1
	move.w	22(a1),d1
	add.l	d1,d1		; Shifta upp samplingarna s† att vi
	add.l	#2000,d1
	lsr.l	#1,d1
	move.l	(a0),a2		; igen...
shifta2:move.b	(a2),d3
	asl.b	d4,d3
	move.b	d3,(a2)+
	move.b	(a2),d3
	asl.b	d4,d3
	move.b	d3,(a2)+
	subq.l	#1,d1
	bne.s	shifta2
entomsamplingingenshifth„rinte2:
	lea	30(a1),a1
	addq.w	#4,a0
	dbra	d0,shiftauppl„mpligt
„rdennolls†beh”verviinteshifta:

	move.w	#2,roteranerplot+2
	move.w	#2,roteranertrue+2

	move.w	oldright,d4
	sub.w	#28,d4
	bsr	setrighttooldvalue

hoppahitomdetblevfelkodvidinitieringen:
	move.w	#OPTOFF,optionskoors

	move.w	oldchannum,d0
	cmp.w	antalkanaler,d0
	beq.s	beh”verinte„ndraeftersomde„rlika1
	move.w	d0,antalkanaler
	bsr	clrhome
beh”verinte„ndraeftersomde„rlika1:

intesl„ppatermodyneftersomdenintefinns:
	clr.l	oldoldoldvol
	bsr	s„ttregisterefterfreq	; terinstallera interna
	bsr	setsamplereplayspeed	; playrutinen

	clr.b	$ff8901
	lea	$FF8907,a0
	move.l	#sample,d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)		; S„tt ig†ng DMAt
	cmp.w	#1,frekvens
	bne.s	inteen252a1
	move.l	#(252*3*2),d0
	move.b	#1,$FF8921		    ; Frequency
	bra.s	inteen504a1
inteen252a1:
	move.b	#2,$FF8921		    ; Frequency
	cmp.w	#2,frekvens
	bne.s	en504a1
	move.l	#(502*3*2),d0
	bra.s	inteen504a1
en504a1:
	move.l	#(504*3*2),d0
inteen504a1:
	jsr	fixextra
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)
	move.b	#3,$FF8901	    ; Start DMA

	jsr	stopknapp
	jsr	clearthepattshower	; Tvinga den att bara visa

	move.w	#-1,mainisnotzero
	clr.w	donotdoanymusicorsomeshit
	clr.w	donotdoanymusic
	rts
sl†p†termody:
	jsr	stopknapp
	clr.w	donotdoanymusic

	move.w	#1,donotdoanymusicorsomeshit
	move.l	bildminne,a0
	addq.w	#2,a0		; Ta bort VU-metrarna
	move.w	#104-1,d0
	moveq	#0,d1
tabortallaVUmetrarna32:
	move.w	d1,(a0)
	lea	168(a0),a0
	dbra	d0,tabortallaVUmetrarna32

	lea	sample,a5
	move.w	#1100*3*2/4,d5
rensaspelbuffern68:			; Rensa playbuffern
	clr.l	(a5)+
	dbra	d5,rensaspelbuffern68

	clr.w	musicwait
	clr.b	mkey

	bsr	kalchowbiggadatarequired
	lea	termodypek,a0
	jsr	firstblockalloc		; Beg„r minne f”r playern
	beq	ingetminnekvarf”rtermody

	jsr	clearthepattshower	; Tvinga den att bara visa
	move.l	currenttermody,a0
	move.l	16(a0),d0
	move.w	d0,patternupdate	; x patternrader

	clr.b	$FF8901		    ; Stoppa DMAt

	move.w	#OPTON,optionskoors

r„kna:					; d5 antalet mellantoner
	move.w	termotones,d5
	addq.w	#1,d5
	lea	termtonebuff,a1
	lea	datareq,a0
	moveq	#37-1,d7		; R„kna ut hur m†nga steg
r„knautbeh”vligtantaltonerimellan2:	; somd det finns imellan
	move.w	(a0),d2			; varje rikigt ton
	sub.w	2(a0),d2
	cmp.w	d5,d2
	ble.s	intemaxtonerimellan2
	move.w	d5,d2
intemaxtonerimellan2:	; Nu inneh†ller d2 hur m†nga toner som skall in
	move.w	(a0),d3
	mulu	#100,d3
	move.w	2(a0),d4
	mulu	#100,d4	; R„kna om s† att vi kan r„kna med 2 decimaler
	move.w	d2,d0
	move.l	d3,d1
	sub.l	d4,d1
	divu	d2,d1	; d1 inneh†ller adderingskoefficienten
	and.l	#$ffff,d1
	subq.w	#1,d0
loopaframl„mpligamellanfrekv:
	sub.l	d1,d3	; Stega fram r„tt antal mellanfrekvenser
	move.l	d3,d4
	add.l	#50,d4
	divu	#100,d4
	move.w	d4,(a1)+
	dbra	d0,loopaframl„mpligamellanfrekv
	addq.w	#2,a0
	dbra	d7,r„knautbeh”vligtantaltonerimellan2
	move.w	#-1,(a1)

	move.w	oldmain,d4
	sub.w	#28,d4
	lea	main,a0			; S„tt volymen normalt
	add.w	d4,d4
	move.w	#$07ff,$ffff8924.w
	move.w	(a0,d4.w),$ffff8922.w

	move.l	#3546895,d3
	tst.w	basspeed
	beq.s	s„ttinteh”gfrek
	bmi.s	special20
	move.l	#5320343,d3
	bra.s	s„ttinteh”gfrek
special20:
	move.l	#4304818,d3
s„ttinteh”gfrek:
	moveq	#0,d4
	lea	termtonebuff,a6
	lea	frekvensbuffer,a5	; R„kna fram frekvensbuffern
r„knautfrekv:
	move.l	d3,d1
	moveq	#0,d2
	move.w	(a6)+,d2		; f=3579546/periods (Amigans perioder)
	bmi.s	slutp†intressantadata
	divu	d2,d1
	swap	d1			; f*65536/50066
	move.w	d4,d1
	divu	#50066,d1
	and.l	#$FFFF,d1
	move.l	d1,(a5)+
	bra.s	r„knautfrekv
slutp†intressantadata:
	move.l	#-1,(a5)+

	lea	termtonebuff,a6
	lea	AmigafrekvenstoTermodynfrekvens,a5
	moveq	#0,d6
r„knautkonverteringstab:
	move.w	(a6)+,d0
	bmi.s	neeegativt
	add.w	d0,d0
fyllhelalistan:
	move.w	d6,(a5,d0.w)		; R„kna ut konverteringstabellen
	subq.w	#2,d0
	bge.s	fyllhelalistan
	addq.w	#4,d6			; Amiga -> Termody
	bra.s	r„knautkonverteringstab
neeegativt:

	move.l	currenttermody,a0
	move.l	(a0),a0
	move.w	348(a0),termodychannels
	moveq	#0,d0
	move.w	350(a0),d0
	moveq	#8,d4
	sub.l	d0,d4
	move.l	d4,termodyshifts
	tst.w	d4
	beq.s	„rdennolls†beh”verviinteshifta2
	lea	samplestarts,a0
	lea	modsamsave,a1
	moveq	#31-1,d0
shiftanerl„mpligt:
	tst.w	22(a1)
	beq.s	entomsamplingingenshifth„rinte
	moveq	#0,d1
	move.w	22(a1),d1
	add.l	d1,d1		; Shifta ner samplingarna s† att vi
	add.l	#2000,d1	; kan anv„nda TERMODYn
	lsr.l	#1,d1
	move.l	(a0),a2
shifta:	move.b	(a2),d3
	asr.b	d4,d3
	move.b	d3,(a2)+
	move.b	(a2),d3
	asr.b	d4,d3
	move.b	d3,(a2)+
	subq.l	#1,d1
	bne.s	shifta
entomsamplingingenshifth„rinte:
	lea	30(a1),a1
	addq.w	#4,a0
	dbra	d0,shiftanerl„mpligt
	cmp.w	#1,d4
	bne.s	inte111
	move.w	#1,roteranerplot+2
	move.w	#1,roteranertrue+2
	bra.s	klartttttttttttt
inte111:
	move.w	#0,roteranerplot+2
	move.w	#0,roteranertrue+2
	bra.s	klartttttttttttt
„rdennolls†beh”verviinteshifta2:
	move.w	#2,roteranerplot+2
	move.w	#2,roteranertrue+2
klartttttttttttt:

	move.w	antalkanaler,oldchannum
	move.l	currenttermody,a0
	move.l	(a0),a0
	addq.w	#4,a0		; S„tt vart den skall hoppa
	move.l	a0,insterm+2
	move.l	termodypek,a0
	lea	frekvensbuffer,a1
	lea	kanal14rutin,a2
	lea	vtab,a3		; S„nd med en massa buffrar
	move.l	physbase,a4	; och variabler till rutinen
	lea	samplestarts,a5
	lea	modsamsave,a6
	moveq	#0,d0
	move.l	#'0.90',d4
	move.l	#musicwait,d1
	move.l	#itab0,d2
	move.l	#wiz1lc,d3
	move.l	#makejeppform,d6
	move.l	#makeform,d7
	move.l	#skrivuthex,d5
insterm:jsr	$12345678	; F”rbered spelaren
	tst.l	d0
	bpl.s	playenblevkorrektinstallerad
	move.l	termodypek,a0
	jsr	free		; Sl„pp minnet anv„nt av TERMODY
	clr.l	termodypek
	not.w	termodyonoff
	move.l	bildminne,a0
	lea	((42*168)+96)(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#2-1,d7 		; 3 bytes vidd p† notten
	bsr	makeinversjamn
	bra	hoppahitomdetblevfelkodvidinitieringen	
playenblevkorrektinstallerad:

	move.l	currenttermody,a0
	move.l	(a0),a0
	move.w	oldchannum,d0
	move.w	348(a0),antalkanaler
	cmp.w	348(a0),d0
	beq.s	beh”verinte„ndraeftersomde„rlika2
	bsr	clrhome
beh”verinte„ndraeftersomde„rlika2:

bahf”rs”ktes„ttaig†ngenspelaresomintefanns:
	clr.w	donotdoanymusicorsomeshit
	clr.w	donotdoanymusic
	clr.w	pattpos
	rts
ingetminnekvarf”rtermody:
	lea	term1,a5		; Meddela att det blev fel
	lea	term2,a6		; n„r minne skulle alloceras
	bsr	makejeppform

	not.w	termodyonoff
	move.l	bildminne,a0
	lea	((42*168)+96)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#2-1,d7 		; 3 bytes vidd p† notten
	bsr	makeinversjamn
	clr.w	donotdoanymusicorsomeshit
	clr.w	donotdoanymusic
	rts

konv:	dc.l	0
datareq:
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113,108

kalchowbiggadatarequired:	; d0 & konv = bytes   d1=toner
	moveq	#0,d0
	moveq	#0,d1
	move.l	currenttermody,a0
	tst.l	(a0)
	beq.s	entomtermodyspelarer„knainte

	move.l	(a0),a0

	moveq	#37,d1
	moveq	#37,d0
	move.l	336(a0),d6		; Konstanta toner
	mulu	d6,d0

	moveq	#0,d4
	move.w	termotones,d5
	lea	datareq,a1
	moveq	#37-1,d7		; R„kna ut hur m†nga steg
r„knautbeh”vligtantaltonerimellan:	; somd det finns imellan
	move.w	(a1),d2			; varje rikigt ton
	sub.w	2(a1),d2
	cmp.w	d5,d2
	ble.s	intemaxtonerimellan
	move.w	d5,d2
intemaxtonerimellan:
	add.w	d2,d4
	addq.w	#2,a1
	dbra	d7,r„knautbeh”vligtantaltonerimellan
	add.w	d4,d1
	mulu	d6,d4
	add.l	d4,d0

	add.l	332(a0),d0		; Konstant buffer
entomtermodyspelarer„knainte:
	move.l	d0,konv
	rts

addtones:
	tst.w	termodyonoff		; Žr termody p† redan?
	bne.s	maximaltantaltonerredan
	cmp.w	#50,termotones
	bge.s	maximaltantaltonerredan
	addq.w	#1,termotones
	lea	termotones+1,a3		; Skriv ut antalet toner
	move.w	#224,d0			; x
	move.w	#24,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex

skrivuthurm†ngabytes:
	bsr.s	kalchowbiggadatarequired
	lea	konv+1,a3		; Skriv ut antalet bytes
	move.w	#192,d0			; x
	move.w	#34,d1			; y
	move.w	#6-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
maximaltantaltonerredan:
	rts

subtones:
	tst.w	termodyonoff		; Žr termody p† redan?
	bne.s	minimaltantaltonerredan
	tst.w	termotones
	ble.s	minimaltantaltonerredan
	subq.w	#1,termotones
	lea	termotones+1,a3		; Skriv ut antalet toner
	move.w	#224,d0			; x
	move.w	#24,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex

	bsr	kalchowbiggadatarequired

	lea	konv+1,a3		; Skriv ut antalet bytes
	move.w	#192,d0			; x
	move.w	#34,d1			; y
	move.w	#6-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
minimaltantaltonerredan:
	rts

AmigafrekvenstoTermodynfrekvens:
	ds.w	1000

termtonebuff:
	ds.w	850

frekvensbuffer:
	ds.l	850
	dc.l	-1


settermody:			; Rutinen som ”ppnar Termody-menyn
	move.l	#termodykoors,losapositioner
	move.l	#termodyrots,losarutiner
	move.l	bildminne,a0
	lea	(16*168+56)+8(a0),a1		; a1 till bilden
	add.l	#66584+2128,a0	; a0 till termodyformen
	move.l	a1,a2
	lea	4(a0),a3		; Spar bakgrunden
	tst.w	termodykoors
	bne.s	harintevaltinfonimtermodyn
	move.w	#13-1,termodykoors
	bra.s	intesparabakgrunden
harintevaltinfonimtermodyn:
	bsr	sparlillstorform
intesparabakgrunden:
	move.l	a1,a3
	move.l	a0,a2		; Rita ut den
	bsr	ritautenlillstorform
„risampleeditoringentermod†:
	rts


showtermoinfo:
	move.w	#1-1,termodykoors

	move.l	bildminne,a0
	lea	(16*168+56)+8(a0),a1		; a1 till bilden
	add.l	#66584+2128,a0	; a0 till termodyformen
	move.l	a1,a2
	move.l	a0,a3			; Spar formen
	bsr	sparlillstorform

	move.l	bildminne,a0
	lea	(18*168+56)+8(a0),a0		; a0 till bilden
	move.l	#%11000000000000001111111111111111,d0
	move.l	#%00000000000000001111111111111111,d1
	move.l	#%00000000000000111111111111111100,d2
	moveq	#22,d3
andabortf”rstadelennu:
	move.l	d0,(a0)
	move.l	d1,8(a0)
	move.l	d1,16(a0)
	move.l	d1,24(a0)
	move.l	d1,32(a0)
	move.l	d1,40(a0)
	move.l	d1,48(a0)
	move.l	d1,56(a0)
	move.l	d1,64(a0)
	move.l	d2,72(a0)
	lea	168(a0),a0
	dbra	d3,andabortf”rstadelennu
	moveq	#11,d3
	move.w	#%0000000000111111,d2
	move.w	#%1111111111000000,d4
andabortandradelennu:
	move.l	d0,(a0)
	move.l	d1,8(a0)
	move.l	d1,16(a0)
	move.l	d1,24(a0)
	move.l	d1,32(a0)
	move.l	d1,40(a0)
	move.l	d1,48(a0)
	move.l	d1,56(a0)
	and.w	d2,64(a0)
	or.w	d4,66(a0)
	lea	168(a0),a0
	dbra	d3,andabortandradelennu

	move.l	currenttermody,a0
	tst.l	(a0)
	beq	finnsingenspelareskrivdet	; Ingen spelare?
	move.l	(a0),a6

	lea	rad1,a3
	move.b	#'0',d0
	move.b	#'0',d1
	add.b	349(a6),d0
	add.b	351(a6),d1
	move.b	d0,4(a3)
	move.b	d1,11(a3)
	clr.b	12(a3)		; Ta reda p† antal kanaler, bitar
	move.w	358(a6),d0	; och om en echofunktion finns
	and.w	#%1000000000000000,d0
	beq.s	ingenechofunktionidenh„rspelaren
	move.b	#' ',12(a3)
ingenechofunktionidenh„rspelaren:
	move.w	#113,d0			; x
	move.w	#21,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen


	move.w	#'  ',rad2+9
	move.w	#'  ',rad2v2+9
	move.w	#'  ',rad2v3+9
	lea	rad2v3,a3
	btst.b	#4,361(a6)
	bne.s	det„rvolymkontrollp†denh„r
	move.w	#'No',rad2+9
	move.w	#'No',rad2v2+9
	move.w	#'No',rad2v3+9
det„rvolymkontrollp†denh„r:
	btst.b	#2,361(a6)
	beq.s	inteenmultipexare
	lea	rad2v2,a3
inteenmultipexare:
	btst.b	#3,361(a6)
	beq.s	inteenantialias
	lea	rad2,a3
inteenantialias:
	move.w	#113,d0			; x
	move.w	#21+6,d1		; y
	jsr	skrivuttext		; Skriv ut textstr„ngen

	clr.b	rad3+10
	clr.b	rad3v2+10
	clr.b	rad3v3+10
	clr.b	rad3v4+10
	btst.b	#2,360(a6)
	beq.s	intestereosamplingar
	move.b	#' ',rad3+10
	move.b	#' ',rad3v2+10
	move.b	#' ',rad3v3+10
	move.b	#' ',rad3v4+10
intestereosamplingar:
	lea	rad3v3,a3
	tst.w	356(a6)
	bpl.s	denklararavallafkommandon
	lea	rad3v4,a3
denklararavallafkommandon:
	btst.b	#3,360(a6)
	beq.s	inte6vblare
	lea	rad3,a3
inte6vblare:
	btst.b	#4,360(a6)
	beq.s	inte4vblare
	lea	rad3v2,a3
inte4vblare:
	move.w	#113,d0			; x
	move.w	#21+6+6,d1		; y
	jsr	skrivuttext		; Skriv ut textstr„ngen


	lea	rad4,a0
	lea	362(a6),a1
	moveq	#17-1,d0
kopierainskaparnamnet:
	move.b	(a1)+,(a0)+
	dbra	d0,kopierainskaparnamnet

	lea	rad4,a3
	move.w	#113,d0			; x
	move.w	#21+6+6+6+4,d1		; y
	jsr	skrivuttext		; Skriv ut textstr„ngen
	rts
finnsingenspelareskrivdet:
	lea	ingenspelareallsstring,a3
	move.w	#113,d0			; x
	move.w	#30,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen
	rts

ingenspelareallsstring:
	dc.b	'No player selected',0
rad1:	dc.b	'Ch: 0 Bit: 0  Echo',0,0
rad2:	dc.b	'A-Alias  No VolCon',0,0
rad2v2:	dc.b	'M-Plex   No VolCon',0,0
rad2v3:	dc.b	'Normal   No VolCon',0
rad3:	dc.b	'6 VBL only  St SAM',0
rad3v2:	dc.b	'4 VBL only  St SAM',0
rad3v3:	dc.b	'Full F-Com  St SAM',0
rad3v4:	dc.b	'VBL F-Com   St SAM',0
rad4:	dc.b	'1234567801234567',0

	even


exittermody:
	tst.w	termodykoors
	beq	settermody
	move.l	#optionskoors,losapositioner
	move.l	#optionsrots,losarutiner
	move.l	bildminne,a0
	lea	(16*168+56)+8(a0),a1		; a1 till bilden
	add.l	#66584+2128,a0	; a0 till termodyformen
	move.l	a1,a2
	move.l	a0,a3			; Spar bakgrunden
	bsr.s	sparlillstorform
	move.l	bildminne,a0
	lea	(16*168+56)+8(a0),a1		; a1 till bilden
	move.l	a1,a3
	add.l	#66584+2128,a0	; a0 till termodyformen
	lea	4(a0),a2		; Ladda upp bakgrunden
	bsr.s	ritautenlillstorform
	rts

ritautenlillstorform:		; Skriver ut en lillstor form till bildminnet
	moveq	#39-1,d7
loopautenlillstorform:
	move.l	(a2),(a3)
	move.l	8(a2),8(a3)
	move.l	16(a2),16(a3)
	move.l	24(a2),24(a3)
	move.l	32(a2),32(a3)
	move.l	40(a2),40(a3)
	move.l	48(a2),48(a3)
	move.l	56(a2),56(a3)
	move.l	64(a2),64(a3)
	move.l	72(a2),72(a3)
	lea	168(a3),a3
	lea	80(a2),a2
	dbra	d7,loopautenlillstorform
	rts

sparlillstorform:	; Skriver ut en lillstor form till bildminnet
	moveq	#39-1,d7
loopsparlillstorform:
	move.l	(a2),(a3)
	move.l	8(a2),8(a3)
	move.l	16(a2),16(a3)
	move.l	24(a2),24(a3)
	move.l	32(a2),32(a3)
	move.l	40(a2),40(a3)
	move.l	48(a2),48(a3)
	move.l	56(a2),56(a3)
	move.l	64(a2),64(a3)
	move.l	72(a2),72(a3)
	lea	168(a2),a2
	lea	80(a3),a3
	dbra	d7,loopsparlillstorform
	rts


basspeed:
	dc.w	0	; 0=16 kHz    1=25 kHz     -1=20kHz
oldpointtospeed:
	dc.w	((48*168)+96)+8

basspeed16:			; S„tter bashastigheten till 16 kHz
	tst.w	basspeed
	beq.s	basspeed„rredan16

	clr.w	basspeed
	move.l	bildminne,a0
	move.l	a0,a2	; a1 till bilden
	add.w	oldpointtospeed,a2
	moveq	#2-1,d7 		; 2 bytes vidd p† notten
	bsr	makeinversjamn
	move.l	bildminne,a0
	lea	((48*168)+96)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#2-1,d7 		; 2 bytes vidd p† notten
	bsr	makeinversjamn
	move.w	#((48*168)+96)+8,oldpointtospeed

	bsr	s„ttregisterefterfreq
	bsr	setsamplereplayspeed
basspeed„rredan16:
	rts

basspeed25:			; S„tter bashastigheten till 25 kHz
	tst.w	basspeed
	bgt.s	basspeed„rredan25

	move.w	#1,basspeed
	move.l	bildminne,a0
	move.l	a0,a2	; a1 till bilden
	add.w	oldpointtospeed,a2
	moveq	#2-1,d7 		; 2 bytes vidd p† notten
	bsr	makeinversjamn
	move.l	bildminne,a0
	lea	((48*168)+112)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#2-1,d7 		; 2 bytes vidd p† notten
	bsr	makeinversjamn
	move.w	#((48*168)+112)+8,oldpointtospeed

	bsr	s„ttregisterefterfreq
	bsr	setsamplereplayspeed
basspeed„rredan25:
	rts


basspeed20:		; S„tter bashastigheten till 20 kHz
	tst.w	basspeed
	bmi.s	basspeed„rredan20

	move.w	#-1,basspeed
	move.l	bildminne,a0
	move.l	a0,a2	; a1 till bilden
	add.w	oldpointtospeed,a2
	moveq	#2-1,d7 		; 2 bytes vidd p† notten
	bsr	makeinversjamn
	move.l	bildminne,a0
	lea	((48*168)+104)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#2-1,d7 		; 2 bytes vidd p† notten
	bsr	makeinversjamn
	move.w	#((48*168)+104)+8,oldpointtospeed

	bsr	s„ttregisterefterfreq
	bsr	setsamplereplayspeed
basspeed„rredan20:
	rts



till625:		; Rutinen som st„ller om till 18.9 kHz
	tst.w	frekvens
	beq.s	harredandenhar625anmarkerad
tt6:	move.l	bildminne,a0
	move.l	a0,a1			; a1 till bilden
	add.l	gamlafrekvenspek,a1
	move.l	a1,a2
	moveq	#3-1,d7 		; 3 bytes vidd p† notten
	move.l	frekvensjsr,a5
	jsr	(a5)
	move.l	bildminne,a0
	lea	((28*168)+97)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#3-1,d7 		; 3 bytes vidd p† notten
	bsr	makeinversojamn
	move.l	#((28*168)+97)+8,gamlafrekvenspek
	move.l	#makeinversojamn,frekvensjsr

	bsr	stopknapp

	clr.w	frekvens
	bsr	s„ttregisterefterfreq
	bsr	setsamplereplayspeed
harredandenhar625anmarkerad:
	rts

till25: 	; Rutinen som st„ller om till 25 kHz
	cmp.w	#2,frekvens
	beq.s	harredandenhar25anmarkerad
tt25:	move.l	bildminne,a0
	move.l	a0,a1			; a1 till bilden
	add.l	gamlafrekvenspek,a1
	move.l	a1,a2
	moveq	#3-1,d7 		; 3 bytes vidd p† notten
	move.l	frekvensjsr,a5
	jsr	(a5)
	move.l	bildminne,a0
	lea	((28*168)+113)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#3-1,d7 		; 3 bytes vidd p† notten
	bsr	makeinversojamn
	move.l	#((28*168)+113)+8,gamlafrekvenspek
	move.l	#makeinversojamn,frekvensjsr

	bsr	stopknapp

	move.w	#2,frekvens
	bsr	s„ttregisterefterfreq
	bsr	setsamplereplayspeed
harredandenhar25anmarkerad:
	rts

till50: 	; Rutinen som st„ller om till 15.5 kHz
	cmp.w	#3,frekvens
	beq.s	harredandenhar50anmarkerad
tt50:	move.l	bildminne,a0
	move.l	a0,a1			; a1 till bilden
	add.l	gamlafrekvenspek,a1
	move.l	a1,a2
	moveq	#3-1,d7 		; 3 bytes vidd p† notten
	move.l	frekvensjsr,a5
	jsr	(a5)
	move.l	bildminne,a0
	lea	((20*168)+113)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#3-1,d7 		; 3 bytes vidd p† notten
	bsr	makeinversojamn
	move.l	#((20*168)+113)+8,gamlafrekvenspek
	move.l	#makeinversojamn,frekvensjsr


	bsr	stopknapp

	move.w	#3,frekvens
	bsr	s„ttregisterefterfreq
	bsr	setsamplereplayspeed
harredandenhar50anmarkerad:
	rts


speedandupdatingdata:	; 0=Hela patternet 1=3 rader -1=endast tjocka raden
	dc.w	0,0,0,0		; 4 kanaler   18.9, 12.5, 25.0, 15.5 kHz
	dc.w	1,0,-1,0	; 6 kanaler   18.9, 12.5, 25.0, 15.5 kHz
	dc.w	-1,0,-1,-1	; 8 kanaler   18.9, 12.5, 25.0, 15.5 kHz
				; A-Alias
	dc.w	0,0,0,0		; 4 kanaler   18.9, 12.5, 25.0, 15.5 kHz
	dc.w	-1,0,-1,-1	; 6 kanaler   18.9, 12.5, 25.0, 15.5 kHz
	dc.w	-1,0,-1,-1	; 8 kanaler   18.9, 12.5, 25.0, 15.5 kHz

alternativ:
	dc.w	0,0,0,0		; 4 kanaler   18.9, 12.5, 25.0, 15.5 kHz
	dc.w	0,0,1,0		; 6 kanaler   18.9, 12.5, 25.0, 15.5 kHz
	dc.w	1,0,-1,1	; 8 kanaler   18.9, 12.5, 25.0, 15.5 kHz
				; A-Alias
	dc.w	0,0,0,0		; 4 kanaler   18.9, 12.5, 25.0, 15.5 kHz
	dc.w	1,0,-1,0	; 6 kanaler   18.9, 12.5, 25.0, 15.5 kHz
	dc.w	-1,1,-1,-1	; 8 kanaler   18.9, 12.5, 25.0, 15.5 kHz

alternativ2:
	dc.w	0,0,0,0		; 4 kanaler   18.9, 12.5, 25.0, 15.5 kHz
	dc.w	0,0,0,0		; 6 kanaler   18.9, 12.5, 25.0, 15.5 kHz
	dc.w	1,0,-1,0	; 8 kanaler   18.9, 12.5, 25.0, 15.5 kHz
				; A-Alias
	dc.w	0,0,0,0		; 4 kanaler   18.9, 12.5, 25.0, 15.5 kHz
	dc.w	-1,0,-1,1	; 6 kanaler   18.9, 12.5, 25.0, 15.5 kHz
	dc.w	-1,0,-1,1	; 8 kanaler   18.9, 12.5, 25.0, 15.5 kHz


fixtheregs:
	tst.w	aalias
	beq.s	ingenaliasp†slagennu
	add.w	d5,d5
	addq.w	#1,d6
ingenaliasp†slagennu:
	rts

aalias:	dc.w	1	; 0 off     1 on

s„ttregisterefterfreq:
	cmp.w	#3,frekvens
	bne.s	inte50
	move.w	#504,d5
	move.w	#2,d6		; 15 kHz
	moveq	#3,d7
	tst.w	basspeed
	bgt.s	s„tth”g15
	beq.s	vanligamigaskit15
	lea	hz153,a6
	rts
vanligamigaskit15:
	lea	hz15,a6
	rts
s„tth”g15:
	lea	hz152,a6
	rts
inte50:	cmp.w	#2,frekvens
	bne.s	inte25
	move.w	#502,d5		; 25 kHz
	move.w	#2,d6
	moveq	#2,d7
	tst.w	basspeed
	bgt.s	s„tth”g25
	beq.s	vanligamigaskit25
	lea	hz253,a6
	rts
vanligamigaskit25:
	lea	hz25,a6
	rts
s„tth”g25:
	lea	hz252,a6
	rts
inte25:	cmp.w	#1,frekvens
	bne.s	inte125
	move.w	#252,d5
	move.w	#1,d6		; 12.5 kHz
	moveq	#1,d7
	tst.w	basspeed
	bgt.s	s„tth”g125
	beq.s	vanligamigaskit125
	lea	hz1253,a6
	rts
vanligamigaskit125:
	lea	hz125,a6
	rts
s„tth”g125:
	lea	hz1252,a6
	rts
inte125:
	move.w	#504,d5
	move.w	#2,d6
	moveq	#0,d7		; 18 kHz
	tst.w	basspeed
	bgt.s	s„tth”g18
	beq.s	vanligamigaskit18
	lea	hz183,a6
	rts
vanligamigaskit18:
	lea	hz18,a6
	rts
s„tth”g18:
	lea	hz182,a6
	rts

aaliasoff:
	clr.w	aalias
	move.l	bildminne,a0
	lea	((20*168)+129)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#4-1,d7 		; 4 bytes vidd p† notten
	bsr	makeinversojamn
	bsr	stopknapp

	lea	notaaliasdata1,a0
	lea	notaaliasdata2,a1
	bsr.s	flyttadatatillverkligbuffer

	bsr	s„ttregisterefterfreq
	bsr.s	setsamplereplayspeed
aliasen„rredanavslagen:
	rts

aaliason:
	tst.w	aalias
	bne.s	aaliasoff
	move.w	#1,aalias
	move.l	bildminne,a0
	lea	((20*168)+129)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#4-1,d7 		; 4 bytes vidd p† notten
	bsr	makeinversojamn
	bsr	stopknapp

	lea	aaliasdata1,a0
	lea	aaliasdata2,a1
	bsr.s	flyttadatatillverkligbuffer

	bsr	s„ttregisterefterfreq
	bsr.s	setsamplereplayspeed
aliasen„rredanp†slagen:
	rts


flyttadatatillverkligbuffer:
	lea	ptyp0,a2
	lea	ptl0,a3
	moveq	#18-1,d0
skuttigenom:
	move.l	(a0)+,(a2)+
	move.w	(a1)+,(a3)+
	dbra	d0,skuttigenom
	rts


setsamplereplayspeed:
	bsr	fixtheregs

	tst.w	mixison
	bne.s	denmixxar1
	move.w	#1,donotdoanymusicorsomeshit
	clr.b	$FF8901	    ; Stoppa DMAt
denmixxar1:
	move.w	#$7000,pattpos

	movem.l	d0-d7/a0-a6,-(sp)
	jsr	clearthepattshower
	movem.l	(sp)+,d0-d7/a0-a6


	tst.w	mixison
	bne.s	denmixxar3
	lea	speedandupdatingdata,a0
	tst.w	aalias
	beq.s	intedetalllsnu
	lea	24(a0),a0
intedetalllsnu:
	move.l	d7,d0
	move.w	antalkanaler,d1
	subq.w	#4,d1
	lsr.w	#1,d1
	add.w	d1,d1			; S„tt s† att det blir r„tt
	add.w	d1,d1			; patternbelastning
	add.w	d1,d1
	add.w	d0,d0
	add.w	d1,d0
	move.w	(a0,d0.w),patternupdate
denmixxar3:

	bsr	vol			; Calculate volume tables
	lea	stab0,a0
	move.l	(a6)+,d2
	bsr	incrcal 		; Calculate tonetables

	lea	buffrar,a0
	move.l	#sample,d0
	moveq	#0,d1
	moveq	#3-1,d2
keloop2:move.w	d1,d3
	mulu	d5,d3
	lsl.l	#1,d3
	add.l	d0,d3
	move.l	d3,(a0)+
	addq.w	#1,d1
	dbra	d2,keloop2
	move.l	#sample,(a0)+

	lea	sample,a0
	move.w	#(1100*3*2)-1,d0
rensahelaskitenidummen:
	clr.w	(a0)+
	dbra	d0,rensahelaskitenidummen

	tst.w	mixison
	bne.s	denmixxar2
	move.b	d6,$FF8921		    ; Frequency
	lea	$FF8907,a0
	move.l	#sample,d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)
	move.l	#sample,d0
	mulu	#3*2,d5
	add.l	d5,d0
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)
	move.b	#3,$FF8901	    ; Start DMA
denmixxar2:
	clr.w	pattpos

direktjumptocreate:

	lea	tempotabell504,a0
	cmp.w	#2,d7
	bne.s	inteen502a
	lea	tempotabell502,a0
inteen502a:
	moveq	#0,d1
	moveq	#125-1,d0		; Flytta in bastalet i tempotabellen
	lea	MSTE+(125*2),a1		; s† att vi kan r„kna p† det sen
	move.w	(a0),(a1)
;	move.w	(a0),2(a1)
	lea	h”gertabell,a2
	lea	v„nstertabell,a3
	lea	h”gertabell2,a4
	lea	v„nstertabell2,a5
	cmp.w	#1,d7
	bne.s	intefixaf”rattdet„r125kHz
flytta”verbastal:
	move.w	(a0)+,d1
	lsr.w	#1,d1
	move.l	d1,(a2)+
	move.l	d1,(a3)+
	move.l	d1,(a4)+
	move.l	d1,(a5)+
	move.w	d1,-(a1)
	dbra	d0,flytta”verbastal
	bra.s	klaaaaaaaaaaaaaaart
intefixaf”rattdet„r125kHz:
	move.w	(a0)+,d1
	move.l	d1,(a2)+
	move.l	d1,(a3)+
	move.l	d1,(a4)+
	move.l	d1,(a5)+
	move.w	d1,-(a1)
	dbra	d0,intefixaf”rattdet„r125kHz
klaaaaaaaaaaaaaaart:
;	clr.w	-(a1)

	clr.w	talattandamed
	clr.w	talattdelamed

	moveq	#26,d5
	moveq	#28,d6
	cmp.w	#6,antalkanaler
	bne.s	sexitv„rre
	moveq	#14,d5
	moveq	#16,d6
sexitv„rre:
	moveq	#26,d3
	moveq	#28,d4
	tst.w	aalias
	beq.s	aaliasen„rminsannav
	addq.w	#2,d3
	addq.w	#4,d4
	addq.w	#2,d5
	addq.w	#4,d6
aaliasen„rminsannav:
	cmp.w	#4,antalkanaler
	bne.s	fyrlingarblire
	moveq	#0,d5
	moveq	#0,d6
fyrlingarblire:
	cmp.w	#2,d7			; Fixa till tabellen f”r
	beq.s	okr„knamed25kHz		; 12.5 och 25 kHz
	cmp.w	#1,d7
	bne.s	detblirintel„ttor„kna
okr„knamed25kHz:
	lea	h”gertabell,a0
	move.l	d3,d1
	bsr	r„knal„tt
	lea	v„nstertabell,a0
	move.l	d4,d1
	bsr	r„knal„tt
	lea	h”gertabell2,a0
	move.l	d5,d1
	bsr	r„knal„tt
	lea	v„nstertabell2,a0
	move.l	d6,d1
	bsr	r„knal„tt
	bra	l„ttr„knatvardet
detblirintel„ttor„kna:
	cmp.w	#3,d7
	bne	r„knaf”rfanintemed15kHz		; R„kna ut tempot om
	lea	h”gertabell,a0			; frevkvensen „r 15.5kHz
	lea	frekvens15bash”ger,a1
	move.w	#136,d4
	tst.w	aalias
	beq.s	aaliasen„rav2
	lea	frekvens15basv„nster,a1
	move.w	#152,d4
aaliasen„rav2:
	moveq	#8,d5
	bsr	r„knautsv†rt
	lea	v„nstertabell,a0
	lea	frekvens15basv„nster,a1
	move.w	#152,d4
	tst.w	aalias
	beq.s	aaliasen„rav3
	lea	frekvens15basv„nsteraalias,a1
	move.w	#184,d4
aaliasen„rav3:
	moveq	#8,d5
	bsr	r„knautsv†rt
	cmp.w	#8,antalkanaler
	bne.s	n„h„detvar6kanaler15kHz
	lea	h”gertabell2,a0			; frevkvensen „r 15.5kHz
	lea	frekvens15bash”ger,a1
	move.w	#136,d4
	tst.w	aalias				; 8 kanaler
	beq.s	aaliasen„rav4
	lea	frekvens15basv„nster,a1
	move.w	#152,d4
aaliasen„rav4:
	moveq	#8,d5
	bsr	r„knautsv†rt
	lea	v„nstertabell2,a0
	lea	frekvens15basv„nster,a1
	move.w	#152,d4
	tst.w	aalias
	beq.s	aaliasen„rav5
	lea	frekvens15basv„nsteraalias,a1
	move.w	#184,d4
aaliasen„rav5:
	moveq	#8,d5
	bsr	r„knautsv†rt
	bra	l„ttr„knatvardet
n„h„detvar6kanaler15kHz:
	lea	h”gertabell2,a0			; frevkvensen „r 15.5kHz
	lea	frekvens15bash”ger6,a1
	move.w	#76,d4				; 6 kanaler
	tst.w	aalias
	beq.s	aaliasen„rav6
	lea	frekvens15basv„nster6,a1
	move.w	#92,d4
aaliasen„rav6:
	moveq	#8,d5
	bsr	r„knautsv†rt
	lea	v„nstertabell2,a0
	lea	frekvens15basv„nster6,a1
	move.w	#92,d4
	tst.w	aalias
	beq.s	aaliasen„rav7
	lea	frekvens15basv„nsteraalias6,a1
	move.w	#124,d4
aaliasen„rav7:
	moveq	#8,d5
	bsr	r„knautsv†rt
	bra	l„ttr„knatvardet
r„knaf”rfanintemed15kHz:
	lea	h”gertabell,a0			; Frevkvensen „r 18.9kHz
	lea	frekvens18bash”ger,a1
	move.w	#80,d4
	tst.w	aalias
	beq.s	aaliasen„rav12
	lea	frekvens18basv„nster,a1
	move.w	#88,d4
aaliasen„rav12:
	moveq	#4,d5
	bsr	r„knautsv†rt
	lea	v„nstertabell,a0
	lea	frekvens18basv„nster,a1
	move.w	#88,d4
	tst.w	aalias
	beq.s	aaliasen„rav13
	lea	frekvens18basv„nsteraalias,a1
	move.w	#104,d4
aaliasen„rav13:
	moveq	#4,d5
	bsr	r„knautsv†rt
	cmp.w	#4,antalkanaler
	bne.s	n„h„detvar6kanaler18kHz
	lea	h”gertabell2,a0			; frevkvensen „r 18.9kHz
	lea	frekvens18bash”ger,a1
	move.w	#80,d4
	tst.w	aalias				; 8 kanaler
	beq.s	aaliasen„rav14
	lea	frekvens18basv„nster,a1
	move.w	#88,d4
aaliasen„rav14:
	moveq	#4,d5
	bsr	r„knautsv†rt
	lea	v„nstertabell2,a0
	lea	frekvens18basv„nster,a1
	move.w	#88,d4
	tst.w	aalias
	beq.s	aaliasen„rav15
	lea	frekvens18basv„nsteraalias,a1
	move.w	#104,d4
aaliasen„rav15:
	moveq	#4,d5
	bsr	r„knautsv†rt
	bra.s	l„ttr„knatvardet
n„h„detvar6kanaler18kHz:
	lea	h”gertabell2,a0			; frevkvensen „r 18.9kHz
	lea	frekvens18bash”ger6,a1
	move.w	#44,d4				; 6 kanaler
	tst.w	aalias
	beq.s	aaliasen„rav16
	lea	frekvens18basv„nster6,a1
	move.w	#52,d4
aaliasen„rav16:
	moveq	#4,d5
	bsr	r„knautsv†rt
	lea	v„nstertabell2,a0
	lea	frekvens18basv„nster6,a1
	move.w	#52,d4
	tst.w	aalias
	beq.s	aaliasen„rav17
	lea	frekvens18basv„nsteraalias6,a1
	move.w	#68,d4
aaliasen„rav17:
	moveq	#4,d5
	bsr	r„knautsv†rt
l„ttr„knatvardet:


	cmp.w	#3,d7			; 15.5 kHz
	bne	intestallanerden

	move.w	#504,skapamax
	move.w	#$7,talattandamed
	move.w	#3,talattdelamed

	move.l	ptyp5,a6
	move.l	kanal23rutin,a0		; Kanal 2 o 3
	move.w	#63-1,d0
	move.w	ptl5,d7
	bsr	duppautskitentyp0
	move.w	typ4,(a0)+		; rts

	move.l	ptyp6,a6
	lea	kanal14rutin,a0		; Kanal 1 o 4
	move.w	#63-1,d0
	move.w	ptl6,d7
	bsr	duppautskitentyp0
	move.w	typ4,(a0)+		; rts

	cmp.w	#4,antalkanaler
	bne.s	inte4kanaleri3
	move.l	kanal67rutin,a5
	move.w	typ4,(a5)
	move.w	typ4,kanal58rutin
	bra	slutpadetta
inte4kanaleri3:

	cmp.w	#6,antalkanaler
	bne.s	†ttakanaleri151
	move.l	ptyp15,a6
	move.w	ptl15,d7
	bra.s	sexkanaleri151
†ttakanaleri151:
	move.l	ptyp7,a6
	move.w	ptl7,d7
sexkanaleri151:
	move.l	kanal67rutin,a0		; Kanal 6 o 7
	move.w	#63-1,d0
	bsr	duppautskitentyp0
	move.w	typ4,(a0)+		; rts

	cmp.w	#6,antalkanaler
	bne.s	†ttakanaleri152
	move.l	ptyp16,a6
	move.w	ptl16,d7
	bra.s	sexkanaleri152
†ttakanaleri152:
	move.l	ptyp8,a6
	move.w	ptl8,d7
sexkanaleri152:
	lea	kanal58rutin,a0		; Kanal 5 o 8
	move.w	#63-1,d0
	bsr	duppautskitentyp0
	move.w	typ4,(a0)+		; rts
	bra	slutpadetta
intestallanerden:
	cmp.w	#1,d7			; 12.5 kHz
	bne	intestallauppden

	move.w	#252,skapamax

	move.l	ptyp0,a6
	move.l	kanal23rutin,a0		; Kanal 2 o 3
	move.w	#252-1,d0
	move.w	ptl0,d7
	bsr	duppautskitentyp0
	move.w	typ4,(a0)+		; rts

	move.l	ptyp1,a6
	lea	kanal14rutin,a0		; Kanal 1 o 4
	move.w	#252-1,d0
	move.w	ptl1,d7
	bsr	duppautskitentyp0
	move.w	typ4,(a0)+		; rts

	cmp.w	#4,antalkanaler
	bne.s	inte4kanaleri1
	move.l	kanal67rutin,a5
	move.w	typ4,(a5)
	move.w	typ4,kanal58rutin
	bra	slutpadetta
inte4kanaleri1:

	cmp.w	#6,antalkanaler
	bne.s	†ttakanaleri121
	move.l	ptyp14,a6
	move.w	ptl14,d7
	bra.s	sexkanaleri121
†ttakanaleri121:
	move.l	ptyp2,a6
	move.w	ptl2,d7
sexkanaleri121:
	move.l	kanal67rutin,a0		; Kanal 6 o 7
	move.w	#252-1,d0
	bsr	duppautskitentyp0
	move.w	typ4,(a0)+		; rts

	cmp.w	#6,antalkanaler
	bne.s	†ttakanaleri122
	move.l	ptyp13,a6
	move.w	ptl13,d7
	bra.s	sexkanaleri122
†ttakanaleri122:
	move.l	ptyp3,a6
	move.w	ptl3,d7
sexkanaleri122:
	lea	kanal58rutin,a0		; Kanal 5 o 8
	move.w	#252-1,d0
	bsr	duppautskitentyp0
	move.w	typ4,(a0)+		; rts
	bra	slutpadetta
intestallauppden:
	tst.w	d7			; 18.9 kHz
	bne	intestallauppdentill18

	move.w	#504,skapamax
	move.w	#$3,talattandamed
	move.w	#2,talattdelamed

	move.l	ptyp9,a6
	move.l	kanal23rutin,a0		; Kanal 2 o 3
	move.w	#126-1,d0
	move.w	ptl9,d7
	bsr	duppautskitentyp0
	move.w	typ4,(a0)+		; rts

	move.l	ptyp10,a6
	lea	kanal14rutin,a0		; Kanal 1 o 4
	move.w	#126-1,d0
	move.w	ptl10,d7
	bsr	duppautskitentyp0
	move.w	typ4,(a0)+		; rts

	cmp.w	#4,antalkanaler
	bne.s	inte4kanaleri0
	move.l	kanal67rutin,a5
	move.w	typ4,(a5)
	move.w	typ4,kanal58rutin
	bra	slutpadetta
inte4kanaleri0:

	cmp.w	#6,antalkanaler
	bne.s	†ttakanaleri181
	move.l	ptyp17,a6
	move.w	ptl17,d7
	bra.s	sexkanaleri181
†ttakanaleri181:
	move.l	ptyp11,a6
	move.w	ptl11,d7
sexkanaleri181:
	move.l	kanal67rutin,a0		; Kanal 6 o 7
	move.w	#126-1,d0
	bsr	duppautskitentyp0
	move.w	typ4,(a0)+		; rts

	cmp.w	#6,antalkanaler
	bne.s	†ttakanaleri182
	move.l	ptyp18,a6
	move.w	ptl18,d7
	bra.s	sexkanaleri182
†ttakanaleri182:
	move.l	ptyp12,a6
	move.w	ptl12,d7
sexkanaleri182:
	lea	kanal58rutin,a0		; Kanal 5 o 8
	move.w	#126-1,d0
	bsr	duppautskitentyp0
	move.w	typ4,(a0)+		; rts
	bra	slutpadetta
intestallauppdentill18:

	cmp.w	#2,d7			; 25.0 kHz
	bne	intestallauppdentill25

	move.w	#502,skapamax

	move.l	ptyp0,a6
	move.l	kanal23rutin,a0		; Kanal 2 o 3
	move.w	#502-1,d0
	move.w	ptl0,d7
	bsr	duppautskitentyp0
	move.w	typ4,(a0)+		; rts

	move.l	ptyp1,a6
	lea	kanal14rutin,a0		; Kanal 1 o 4
	move.w	#502-1,d0
	move.w	ptl1,d7
	bsr	duppautskitentyp0
	move.w	typ4,(a0)+		; rts

	cmp.w	#4,antalkanaler
	bne.s	inte4kanaleri2
	move.l	kanal67rutin,a5
	move.w	typ4,(a5)
	move.w	typ4,kanal58rutin
	bra.s	slutpadetta
inte4kanaleri2:

	cmp.w	#6,antalkanaler
	bne.s	†ttakanaleri251
	move.l	ptyp14,a6
	move.w	ptl14,d7
	bra.s	sexkanaleri251
†ttakanaleri251:
	move.l	ptyp2,a6
	move.w	ptl2,d7
sexkanaleri251:
	move.l	kanal67rutin,a0		; Kanal 6 o 7
	move.w	#502-1,d0
	bsr	duppautskitentyp0
	move.w	typ4,(a0)+		; rts

	cmp.w	#6,antalkanaler
	bne.s	†ttakanaleri252
	move.l	ptyp13,a6
	move.w	ptl13,d7
	bra.s	sexkanaleri252
†ttakanaleri252:
	move.l	ptyp3,a6
	move.w	ptl3,d7
sexkanaleri252:
	lea	kanal58rutin,a0		; Kanal 5 o 8
	move.w	#502-1,d0
	bsr	duppautskitentyp0
	move.w	typ4,(a0)+		; rts

	bra	slutpadetta
intestallauppdentill25:

slutpadetta:
	clr.w	donotdoanymusicorsomeshit
	rts

r„knautsv†rt:			; a0 pekare mot tempotabell
	moveq	#0,d0		; a1 pekare mot adderingstabell
	tst.w	loopordupp
	bne.s	viskallloopamusikrutinen2
	move.l	(a0),d2		; d4 hel sekvens i bytes
n2:	move.l	d2,d0		; d5 Antal skapningar
	move.l	d0,d1
	divu	d5,d0
	move.w	d0,d3
	mulu	d4,d0
	mulu	d5,d3
	sub.l	d3,d1
	move.b	(a1,d1.w),d1
	and.l	#$FF,d1
	add.l	d1,d0
	and.w	#$FFFE,d0
	move.l	d0,(a0)+
	dbra	d2,n2
	move.l	d0,(a0)+
;	move.l	d0,(a0)+
	rts
viskallloopamusikrutinen2:
	add.w	d5,a1
	subq.w	#1,d5
r„knaframkortistabell:
	move.b	-(a1),d0
	addq.w	#2,d0
	move.l	d0,(a0)+
	dbra	d5,r„knaframkortistabell
	rts

frekvens15bash”ger:
	dc.b	0,26,28,54,56,82,108,110
frekvens15basv„nster:
	dc.b	0,26,32,58,64,92,118,124
frekvens15basv„nsteraalias:
	dc.b	0,30,40,70,80,112,142,152
frekvens15bash”ger6:
	dc.b	0,14,16,30,32,46,60,62
frekvens15basv„nster6:
	dc.b	0,14,20,34,40,56,70,76
frekvens15basv„nsteraalias6:
	dc.b	0,18,28,46,56,66,84,94
frekvens18bash”ger:
	dc.b	0,26,52,78
frekvens18basv„nster:
	dc.b	0,28,56,86
frekvens18basv„nsteraalias:
	dc.b	0,32,64,94
frekvens18bash”ger6:
	dc.b	0,14,28,42
frekvens18basv„nster6:
	dc.b	0,16,32,46
frekvens18basv„nsteraalias6:
	dc.b	0,20,40,60
talattandamed:
	dc.w	0
talattdelamed:
	dc.w	0

r„knal„tt:		; a0 pekare till tabellen    d1 mulu
	moveq	#0,d0
	move.l	(a0),d2
n1:	move.l	d2,d0
	mulu	d1,d0
	and.w	#$FFFE,d0
	move.l	d0,(a0)+
	dbra	d2,n1
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	rts

duppautskitentyp0:
	tst.w	loopordupp
	bne.s	viskallloopamusikrutinen
duppautskitentyp1:
	move.w	d7,d1
	move.l	a6,a1		; Duppar ut en bit kod
loptyp0:move.b	(a1)+,(a0)+
	dbra	d1,loptyp0
	dbra	d0,duppautskitentyp1
	rts
viskallloopamusikrutinen:
	move.l	a0,d0
	move.w	#$4847,(a0)+	; SWAP.W D7
loptyp1:move.b	(a6)+,(a0)+	; L„gger dit loopbiten
	dbra	d7,loptyp1
	move.w	#$4847,(a0)+	; SWAP.W D7
	move.w	#$51CF,(a0)+	; DBRA   D7,xxx
	sub.l	a0,d0
	move.w	d0,(a0)+	; $xxxx(PC)
	rts

ptyp0:	dc.l	typ0
ptyp1:	dc.l	typ1
ptyp2:	dc.l	typ2
ptyp3:	dc.l	typ3
ptyp5:	dc.l	typ5
ptyp6:	dc.l	typ6
ptyp7:	dc.l	typ7
ptyp8:	dc.l	typ8
ptyp9:	dc.l	typ9
ptyp10:	dc.l	typ10
ptyp11:	dc.l	typ11
ptyp12:	dc.l	typ12
ptyp13:	dc.l	typ13
ptyp14:	dc.l	typ14
ptyp15:	dc.l	typ15
ptyp16:	dc.l	typ16
ptyp17:	dc.l	typ17
ptyp18:	dc.l	typ18

ptl0:	dc.w	26-1
ptl1:	dc.w	28-1
ptl2:	dc.w	26-1
ptl3:	dc.w	28-1
ptl5:	dc.w	(26*5+3*2)-1
ptl6:	dc.w	(28*5+3*4)-1
ptl7:	dc.w	(26*5+3*2)-1
ptl8:	dc.w	(28*5+3*4)-1
ptl9:	dc.w	(26*3+2*1)-1
ptl10:	dc.w	(28*3+4*1)-1
ptl11:	dc.w	(26*3+2*1)-1
ptl12:	dc.w	(28*3+4*1)-1
ptl13:	dc.w	(16)-1
ptl14:	dc.w	(14)-1
ptl15:	dc.w	(14*5+3*2)-1
ptl16:	dc.w	(16*5+3*4)-1
ptl17:	dc.w	(14*3+2*1)-1
ptl18:	dc.w	(16*3+4*1)-1

notaaliasdata1:
	dc.l	typ0
	dc.l	typ1
	dc.l	typ2
	dc.l	typ3
	dc.l	typ5
	dc.l	typ6
	dc.l	typ7
	dc.l	typ8
	dc.l	typ9
	dc.l	typ10
	dc.l	typ11
	dc.l	typ12
	dc.l	typ13
	dc.l	typ14
	dc.l	typ15
	dc.l	typ16
	dc.l	typ17
	dc.l	typ18
notaaliasdata2:
	dc.w	26-1
	dc.w	28-1
	dc.w	26-1
	dc.w	28-1
	dc.w	(26*5+3*2)-1
	dc.w	(28*5+3*4)-1
	dc.w	(26*5+3*2)-1
	dc.w	(28*5+3*4)-1
	dc.w	(26*3+2*1)-1
	dc.w	(28*3+4*1)-1
	dc.w	(26*3+2*1)-1
	dc.w	(28*3+4*1)-1
	dc.w	(16)-1
	dc.w	(14)-1
	dc.w	(14*5+3*2)-1
	dc.w	(16*5+3*4)-1
	dc.w	(14*3+2*1)-1
	dc.w	(16*3+4*1)-1

aaliasdata1:
	dc.l	typ100
	dc.l	typ101
	dc.l	typ102
	dc.l	typ103
	dc.l	typ105
	dc.l	typ106
	dc.l	typ107
	dc.l	typ108
	dc.l	typ109
	dc.l	typ110
	dc.l	typ111
	dc.l	typ112
	dc.l	typ113
	dc.l	typ114
	dc.l	typ115
	dc.l	typ116
	dc.l	typ117
	dc.l	typ118
aaliasdata2:
	dc.w	(26+2)-1
	dc.w	(28+4)-1
	dc.w	(26+2)-1
	dc.w	(28+4)-1
	dc.w	(26*5+3*2+8*2)-1
	dc.w	(28*5+3*4+8*4)-1
	dc.w	(26*5+3*2+8*2)-1
	dc.w	(28*5+3*4+8*4)-1
	dc.w	(26*3+2*1+4*2)-1
	dc.w	(28*3+4*1+4*4)-1
	dc.w	(26*3+2*1+4*2)-1
	dc.w	(28*3+4*1+4*4)-1
	dc.w	(16+4)-1
	dc.w	(14+2)-1
	dc.w	(14*5+3*2+8*2)-1
	dc.w	(16*5+3*4+8*4)-1
	dc.w	(14*3+2*1+4*2)-1
	dc.w	(16*3+4*1+4*4)-1


mixtyp0:add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)+

mixtyp1:add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.b	d7,(a6)+

mixtyp2:add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	bvc.s	inteoverflow1	; +2
	bmi.s	tatminus1	; +2
	move.w	#$80,d7		; +4
	bra.s	inteoverflow1	; +2
tatminus1:
	move.w	#$7F,d7		; +4 = 14
inteoverflow1:
	move.b	d7,(a6)+	; = 40 bytes

mixtyp3:add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	bvc.s	inteoverflow2	; +2
	bmi.s	tatminus2	; +2
	move.w	#$80,d7		; +4
	bra.s	inteoverflow2	; +2
tatminus2:
	move.w	#$7F,d7		; +4 = 14
inteoverflow2:
	add.b	d7,(a6)
	bvc.s	inteoverflow3	; +2
	bmi.s	tatminus3	; +2
	move.b	#$80,(a6)		; +4
	bra.s	inteoverflow3	; +2
tatminus3:
	move.b	#$7F,(a6)	; +4 = 14
inteoverflow3:			; = 54
	addq.w	#1,a6		; = 56

typ0:	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+

typ1:	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	addq.w	#2,a6

typ2:	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.w	d7,(a6)+

typ3:	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.b	d7,(a6)
	addq.w	#2,a6

typ4:	rts			; 2 bytes

typ5:	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	move.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	move.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	move.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+


typ6:	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	move.b	d7,2(a6)
	addq.w	#4,a6
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	move.b	d7,2(a6)
	addq.w	#4,a6
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	addq.w	#2,a6
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	move.b	d7,2(a6)
	addq.w	#4,a6
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	addq.w	#2,a6




typ7:	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.w	d7,(a6)+


typ8:	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.b	d7,(a6)
	add.b	d7,2(a6)
	addq.w	#4,a6
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.b	d7,(a6)
	add.b	d7,2(a6)
	addq.w	#4,a6
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.b	d7,(a6)
	addq.w	#2,a6
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.b	d7,(a6)
	add.b	d7,2(a6)
	addq.w	#4,a6
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.b	d7,(a6)
	addq.w	#2,a6



typ9:	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	move.w	d7,(a6)+


typ10:	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	addq.w	#2,a6
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	addq.w	#2,a6
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	move.b	d7,2(a6)
	addq.w	#4,a6




typ11:	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.w	d7,(a6)+
	add.w	d7,(a6)+




typ12:	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.b	d7,(a6)
	addq.w	#2,a6
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.b	d7,(a6)
	addq.w	#2,a6
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.b	d7,(a6)
	add.b	d7,2(a6)
	addq.w	#4,a6

typ13:	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 16 bytes
	add.b	d7,(a6)
	addq.w	#2,a6

typ14:	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 14 bytes
	add.w	d7,(a6)+


typ15:	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 14 bytes
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 14 bytes
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 14 bytes
	add.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 14 bytes
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 14 bytes
	add.w	d7,(a6)+


typ16:	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 16 bytes
	add.b	d7,(a6)
	add.b	d7,2(a6)
	addq.w	#4,a6
	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 16 bytes
	add.b	d7,(a6)
	add.b	d7,2(a6)
	addq.w	#4,a6
	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 16 bytes
	add.b	d7,(a6)
	addq.w	#2,a6
	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 16 bytes
	add.b	d7,(a6)
	add.b	d7,2(a6)
	addq.w	#4,a6
	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 16 bytes
	add.b	d7,(a6)
	addq.w	#2,a6


typ17:	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 14 bytes
	add.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 14 bytes
	add.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 14 bytes
	add.w	d7,(a6)+
	add.w	d7,(a6)+



typ18:	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 16 bytes
	add.b	d7,(a6)
	addq.w	#2,a6
	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 16 bytes
	add.b	d7,(a6)
	addq.w	#2,a6
	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 16 bytes
	add.b	d7,(a6)
	add.b	d7,2(a6)
	addq.w	#4,a6






typ100:	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	move.w	d7,(a6)+	; +2


typ101:	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	move.b	d7,2(a6)	; +4
	addq.w	#4,a6

typ102:	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.w	d7,(a6)+
	add.w	d7,(a6)+	; +2

typ103:	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.b	d7,(a6)
	add.b	d7,2(a6)	; +4
	addq.w	#4,a6

typ105:	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	move.w	d7,(a6)+
	move.w	d7,(a6)+
	move.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	move.w	d7,(a6)+
	move.w	d7,(a6)+
	move.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	move.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	move.w	d7,(a6)+
	move.w	d7,(a6)+
	move.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	move.w	d7,(a6)+


typ106:	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	move.b	d7,2(a6)
	move.b	d7,4(a6)
	move.b	d7,6(a6)
	addq.w	#8,a6
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	move.b	d7,2(a6)
	move.b	d7,4(a6)
	move.b	d7,6(a6)
	addq.w	#8,a6
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	move.b	d7,2(a6)
	addq.w	#4,a6
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	move.b	d7,2(a6)
	move.b	d7,4(a6)
	move.b	d7,6(a6)
	addq.w	#8,a6
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	move.b	d7,2(a6)	; +5*4
	addq.w	#4,a6




typ107:	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.w	d7,(a6)+
	add.w	d7,(a6)+	; +5*2


typ108:	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.b	d7,(a6)
	add.b	d7,2(a6)
	add.b	d7,4(a6)
	add.b	d7,6(a6)
	addq.w	#8,a6
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.b	d7,(a6)
	add.b	d7,2(a6)
	add.b	d7,4(a6)
	add.b	d7,6(a6)
	addq.w	#8,a6
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.b	d7,(a6)
	add.b	d7,2(a6)
	addq.w	#4,a6
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.b	d7,(a6)
	add.b	d7,2(a6)
	add.b	d7,4(a6)
	add.b	d7,6(a6)
	addq.w	#8,a6
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.b	d7,(a6)
	add.b	d7,2(a6)
	addq.w	#4,a6



typ109:	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	move.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	move.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	move.w	d7,(a6)+
	move.w	d7,(a6)+
	move.w	d7,(a6)+


typ110:	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	move.b	d7,2(a6)
	addq.w	#4,a6
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	move.b	d7,2(a6)
	addq.w	#4,a6
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	move.b	d7,2(a6)
	move.b	d7,4(a6)
	move.b	d7,6(a6)
	addq.w	#8,a6




typ111:	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 26 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	d7,(a6)+




typ112:	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.b	d7,(a6)
	add.b	d7,2(a6)
	addq.w	#4,a6
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.b	d7,(a6)
	add.b	d7,2(a6)
	addq.w	#4,a6
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 28 bytes
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.b	d7,(a6)
	add.b	d7,2(a6)
	add.b	d7,4(a6)
	add.b	d7,6(a6)
	addq.w	#8,a6

typ113:	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 16 bytes
	add.b	d7,(a6)
	add.b	d7,2(a6)
	addq.w	#4,a6

typ114:	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 14 bytes
	add.w	d7,(a6)+
	add.w	d7,(a6)+


typ115:	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 14 bytes
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 14 bytes
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 14 bytes
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 14 bytes
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 14 bytes
	add.w	d7,(a6)+
	add.w	d7,(a6)+


typ116:	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 16 bytes
	add.b	d7,(a6)
	add.b	d7,2(a6)
	add.b	d7,4(a6)
	add.b	d7,6(a6)
	addq.w	#8,a6
	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 16 bytes
	add.b	d7,(a6)
	add.b	d7,2(a6)
	add.b	d7,4(a6)
	add.b	d7,6(a6)
	addq.w	#8,a6
	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 16 bytes
	add.b	d7,(a6)
	add.b	d7,2(a6)
	addq.w	#4,a6
	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 16 bytes
	add.b	d7,(a6)
	add.b	d7,2(a6)
	add.b	d7,4(a6)
	add.b	d7,6(a6)
	addq.w	#8,a6
	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 16 bytes
	add.b	d7,(a6)
	add.b	d7,2(a6)
	addq.w	#4,a6


typ117:	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 14 bytes
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 14 bytes
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 14 bytes
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	d7,(a6)+
	add.w	d7,(a6)+


typ118:	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 16 bytes
	add.b	d7,(a6)
	add.b	d7,2(a6)
	addq.w	#4,a6
	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 16 bytes
	add.b	d7,(a6)
	add.b	d7,2(a6)
	addq.w	#4,a6
	add.w	a4,d1
	addx.w	d2,d0
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7	; 16 bytes
	add.b	d7,(a6)
	add.b	d7,2(a6)
	add.b	d7,4(a6)
	add.b	d7,6(a6)
	addq.w	#8,a6






kanalvanster:
	cmp.w	#1,startkanal
	beq.s	redanlangstillvanster
	subq.w	#1,startkanal
	move.w	startkanal,d5
	lsl.w	#4,d5
	bsr	skrivutkanalinfon
redanlangstillvanster:
	rts

kanalhoger:
	move.w	antalkanaler,d0
	subq.w	#3,d0
	cmp.w	startkanal,d0
	beq.s	redanlangstillhoger
	addq.w	#1,startkanal
	move.w	startkanal,d5
	lsl.w	#4,d5
	bsr	skrivutkanalinfon
redanlangstillhoger:
	rts


;======================= Are you sure? Yes No rutinen och Understood yes ==

ritautenform:		; Skriver ut en liten form till bildminnet
	moveq	#41-1,d7
loopautenform:
	move.l	(a2),(a3)
	move.l	8(a2),8(a3)
	move.l	16(a2),16(a3)
	move.l	24(a2),24(a3)
	move.l	32(a2),32(a3)
	move.l	40(a2),40(a3)
	move.l	48(a2),48(a3)
	move.l	56(a2),56(a3)
	lea	168(a3),a3
	lea	64(a2),a2
	dbra	d7,loopautenform
	rts

sparform:		; Skriver ut en liten form till bildminnet
	moveq	#41-1,d7
loopsparform:
	move.l	(a2),(a3)
	move.l	8(a2),8(a3)
	move.l	16(a2),16(a3)
	move.l	24(a2),24(a3)
	move.l	32(a2),32(a3)
	move.l	40(a2),40(a3)
	move.l	48(a2),48(a3)
	move.l	56(a2),56(a3)
	lea	168(a2),a2
	lea	64(a3),a3
	dbra	d7,loopsparform
	rts

			; 14 * 2
makeform:		; a5 och a6 pekare till textstr„ng
	move.l	bildminne,a0
	lea	(8*168+64)+8(a0),a1		; a1 till bilden
	add.l	#((266*168)+(2*8*7*39)+(8*32*12)+(104*39)),a0	; a0 till infoformen
	move.l	a1,a2
	lea	4(a0),a3		; Spar bakgrunden
	bsr.s	sparform
	move.l	a1,a3
	move.l	a0,a2		; Rita ut den
	bsr	ritautenform

	move.l	a5,a3			; Pekare till str„ng
	move.w	#137,d0 		; x
	move.w	#13,d1			; y
	bsr	skrivuttext		; Skriv ut textstr„ngen

	move.l	a6,a3			; Pekare till str„ng
	move.w	#137,d0 		; x
	move.w	#21,d1			; y
	bsr	skrivuttext		; Skriv ut textstr„ngen

v„ntap†sl„pp2:
	jsr	testas†oftasomm”jligt	; Skriv ut tid o patternpos.
	jsr	ritapatternettrashat
	btst.b	#1,mkey
	bne.s	v„ntap†sl„pp2

formloop:
	jsr	testas†oftasomm”jligt	; Skriv ut tid o patternpos.
	jsr	ritapatternettrashat
	btst.b	#1,mkey
	beq.s	notformno
	move.w	x,d0
	move.w	y,d1
	cmp.w	#128+16,d0
	ble.s	notformyes
	cmp.w	#38,d1
	ble.s	notformyes
	cmp.w	#191+16,d0
	bge.s	notformyes
	cmp.w	#48,d1
	bge.s	notformyes
	moveq	#0,d0
	bra.s	formwait
notformyes:
	cmp.w	#192+16,d0
	ble.s	notformno
	cmp.w	#38,d1
	ble.s	notformno
	cmp.w	#255+16,d0
	bge.s	notformno
	cmp.w	#48,d1
	bge.s	notformno
	moveq	#-1,d0
	bra.s	formwait
notformno:
	bsr	isakeyready
	beq.s	formloop
	bsr	getkeywithasciiandshifts
	cmp.b	#'Y',d0 		; Test om det var y eller n
	bne.s	intestoray
	moveq	#0,d0
	bra.s	formend
intestoray:
	cmp.b	#'y',d0
	bne.s	intelillay
	moveq	#0,d0
	bra.s	formend
intelillay:
	cmp.b	#'N',d0
	bne.s	intestoran
	moveq	#-1,d0
	bra.s	formend
intestoran:
	cmp.b	#'n',d0
	bne.s	intelillan
	moveq	#-1,d0
	bra.s	formend
intelillan:
	swap	d0
	cmp.b	#1,d0
	bne.s	inteESCp
	moveq	#-1,d0
	bra.s	formend
inteESCp:
	cmp.b	#$1c,d0
	bne.s	intereturnnnn
	moveq	#0,d0
	bra.s	formend
intereturnnnn:
	cmp.b	#$72,d0
	bne.s	inteenter
	moveq	#0,d0
	bra.s	formend
inteenter:
	bra	formloop
formwait:
	move.l	d0,-(sp)
	jsr	testas†oftasomm”jligt
	jsr	ritapatternettrashat
	move.l	(sp)+,d0
	btst.b	#1,mkey
	bne.s	formwait
formend:

	move.l	bildminne,a0
	lea	(8*168+64)+8(a0),a1		; a1 till bilden
	move.l	a1,a3
	add.l	#((266*168)+(2*8*7*39)+(8*32*12)+(104*39)),a0	; a0 till infoformen
	lea	4(a0),a2		; Ladda upp bakgrunden
	bsr	ritautenform

	rts

			; 14 * 2
makejeppform:		; a5 och a6 pekare till textstr„ng
	move.l	bildminne,a0
	lea	(8*168+64)+8(a0),a1		; a1 till bilden
	add.l	#((266*168)+(2*8*7*39)+(8*32*12)+(104*39)+(64*41)),a0	; a0 till infoformen
	move.l	a1,a2
	lea	4(a0),a3		; Spar bakgrunden
	bsr	sparform
	move.l	a1,a3
	move.l	a0,a2		; Rita ut den
	bsr	ritautenform

	move.l	a5,a3			; Pekare till str„ng
	move.w	#137,d0 		; x
	move.w	#13,d1			; y
	bsr	skrivuttext		; Skriv ut textstr„ngen

	move.l	a6,a3			; Pekare till str„ng
	move.w	#137,d0 		; x
	move.w	#21,d1			; y
	bsr	skrivuttext		; Skriv ut textstr„ngen

v„ntap†sl„pp:
	jsr	testas†oftasomm”jligt	; Skriv ut tid o patternpos.
	jsr	ritapatternettrashat
	btst.b	#1,mkey
	bne.s	v„ntap†sl„pp

formjepploop:
	jsr	testas†oftasomm”jligt	; Skriv ut tid o patternpos.
	jsr	ritapatternettrashat
	btst.b	#1,mkey
	beq.s	notjeppform
	move.w	x,d0
	move.w	y,d1
	cmp.w	#128+16,d0
	ble.s	notjeppform
	cmp.w	#38,d1
	ble.s	notjeppform
	cmp.w	#255+16,d0
	bge.s	notjeppform
	cmp.w	#48,d1
	bge.s	notjeppform
	moveq	#0,d0
	bra.s	formjeppwait
notjeppform:
	bsr	isakeyready
	beq.s	formjepploop
	bsr	getkeywithasciiandshifts
	bra.s	formjeppend
formjeppwait:
	move.l	d0,-(sp)
	jsr	testas†oftasomm”jligt
	jsr	ritapatternettrashat
	move.l	(sp)+,d0
	btst.b	#1,mkey
	bne.s	formjeppwait
formjeppend:
	move.l	bildminne,a0
	lea	(8*168+64)+8(a0),a1		; a1 till bilden
	move.l	a1,a3
	add.l	#((266*168)+(2*8*7*39)+(8*32*12)+(104*39)+(64*41)),a0	; a0 till infoformen
	lea	4(a0),a2		; Ladda upp bakgrunden
	bsr	ritautenform
	rts

;============================================== Rutinen som fixar clear ==


clearknapp:
	cmp.l	#colorkoors,losapositioner
	beq	intetadodadennasong
	cmp.l	#optionskoors,losapositioner
	beq	intetadodadennasong
	cmp.l	#termodykoors,losapositioner
	beq	intetadodadennasong
	cmp.l	#selectshowpattkoors,losapositioner
	beq	intetadodadennasong
	cmp.l	#numpattskoors,losapositioner
	beq	intetadodadennasong
	tst.w	whichsample
	beq.s	intetadodadennasampling
	moveq	#0,d0
	move.w	whichsample,d0
	subq.w	#1,d0
	add.w	d0,d0
	add.w	d0,d0
	add.l	#samplestarts,d0
	move.l	d0,a0
	cmp.l	#dummy,(a0)
	beq.s	intetadodadennasampling
	move.l	a0,-(sp)
	lea	killthisoneor1,a5
	lea	killthisoneor2,a6
	bsr	makeform		; Ta bort aktuell sampling?
	move.l	(sp)+,a0
	tst.w	d0
	bmi.s	intetadodadennasampling
	move.l	a0,-(sp)
	bsr	stopknapp
	move.l	(sp)+,a0
	bsr	felvidlasningslappdenna
	move.w	#-1,currentsample
	jsr	checkifsamplechanged
	bra.s	intetadodaallasamplingar
intetadodadennasampling:
	lea	killalloneor1,a5
	lea	killalloneor2,a6
	bsr	makeform		; Ta bort alla	sampling?
	tst.w	d0
	bmi.s	intetadodaallasamplingar
	bsr	stopknapp
	bsr	tadodpaallasamplingar
	move.w	#-1,currentsample
	jsr	checkifsamplechanged
intetadodaallasamplingar:
	lea	killthissong1,a5
	lea	killthissong2,a6
	bsr	makeform		; Ta bort hela songen?
	tst.w	d0
	bmi	intetadodadennasong
	bsr	stopknapp
	jsr	sparundanpatternet
	lea	songname,a5		; T”m aktuellt songnamn
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.w	#'  ',(a5)+
	move.w	#$2000,(a5)+
rensaallapatternsochsongen:
	clr.w	newlooppattpos
	clr.b	newloopsongpos
	clr.w	newloopwhichpatt
	move.l	patterns,a0
	move.w	#64,d0
	mulu	maxpatterns,d0
	subq.w	#1,d0
	moveq	#0,d1
rensaallapatterns2:			; Rensa alla patterns
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbra	d0,rensaallapatterns2
	move.b	#1,songlength
	clr.w	whichpatt
	clr.b	songpos
	clr.b	songrestart
	lea	song,a0
	move.w	#128-1,d0
rensaalltisongen:
	move.b	d1,(a0)+
	dbra	d0,rensaalltisongen
	bsr	skrivutlitekrafs	; Skriv ut patternsdata..
	move.w	#$10,d5
	bsr	skrivutkanalinfon
	clr.w	pattpos
	move.l	oldcursorpek,a6
	clr.b	(a6)
	clr.b	1848(a6)
	clr.w	cursorx
	bsr	skrivuttillhorandeinfo
	move.w	#1,blockcollect
	jsr	outputblockstatus
intetadodadennasong:
	rts

tadodpaallasamplingar:		; Ta bort alla samplingar
	move.w	#$1f,whichsample
loopabortallasamplingar:
	moveq	#0,d0
	move.w	whichsample,d0
	subq.w	#1,d0
	add.w	d0,d0
	add.w	d0,d0
	add.l	#samplestarts,d0
	move.l	d0,a0
	cmp.l	#dummy,(a0)
	beq.s	tomsampling
	bsr	felvidlasningslappdenna
tomsampling:
	subq.w	#1,whichsample
	bne.s	loopabortallasamplingar
	move.w	#1,whichsample
	bsr	skrivuttillhorandeinfo
	lea	whichsample+1,a3	; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#49,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr.s	skrivuthex		; Skriv ut i hex
	rts

;========================================== Utskriftsrutiner f”r fonter ==


skrivuthex:	; d7  hur m†nga siffror skall skrivas ut - 1
		; d0  x     d1	y    a3 pekare till talet
	add.w	#16,d0
	move.l	bildminne,a2
	mulu	#168,d1 	; R„kna ut var i bildminnet som den
	add.l	d1,a2		; skall skriva
	move.w	d0,d1
	and.w	#%1111111111110000,d0
	lsr.w	#1,d0
	add.w	d0,a2
	lea	taltabell,a4
	moveq	#0,d0
	and.w	#$7,d1
	beq.s	inteextra
	addq.l	#1,a2
	bra	skrivuthexnastaloop2
inteextra:
skrivuthexloop: 
	move.b	(a3)+,d0
	move.w	d0,d1
	and.b	#$f0,d0
	lsr.w	#2,d0
	move.l	0(a4,d0.w),a0
	move.b	(a0)+,(a2)
	move.b	(a0)+,2(a2)
	move.b	(a0)+,168(a2)
	move.b	(a0)+,170(a2)
	move.b	(a0)+,336(a2)
	move.b	(a0)+,338(a2)
	move.b	(a0)+,504(a2)
	move.b	(a0)+,506(a2)
	move.b	(a0)+,672(a2)
	move.b	(a0)+,674(a2)
	move.b	(a0)+,840(a2)
	move.b	(a0)+,842(a2)
	addq.l	#1,a2
	dbra	d7,skrivuthexnastaloop
	rts

skrivuthexnastaloop:
	and.b	#$f,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a4,d1.w),a0
	move.b	(a0)+,(a2)
	move.b	(a0)+,2(a2)
	move.b	(a0)+,168(a2)
	move.b	(a0)+,170(a2)
	move.b	(a0)+,336(a2)
	move.b	(a0)+,338(a2)
	move.b	(a0)+,504(a2)
	move.b	(a0)+,506(a2)
	move.b	(a0)+,672(a2)
	move.b	(a0)+,674(a2)
	move.b	(a0)+,840(a2)
	move.b	(a0)+,842(a2)
	addq.l	#7,a2
	dbra	d7,skrivuthexloop
	rts

skrivuthexloop2:	
	and.b	#$f,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a4,d1.w),a0
	move.b	(a0)+,(a2)
	move.b	(a0)+,2(a2)
	move.b	(a0)+,168(a2)
	move.b	(a0)+,170(a2)
	move.b	(a0)+,336(a2)
	move.b	(a0)+,338(a2)
	move.b	(a0)+,504(a2)
	move.b	(a0)+,506(a2)
	move.b	(a0)+,672(a2)
	move.b	(a0)+,674(a2)
	move.b	(a0)+,840(a2)
	move.b	(a0)+,842(a2)
	addq.l	#1,a2
	dbra	d7,skrivuthexnastaloop2
	rts

skrivuthexnastaloop2:
	move.b	(a3)+,d0
	move.w	d0,d1
	and.b	#$f0,d0
	lsr.w	#2,d0
	move.l	0(a4,d0.w),a0
	move.b	(a0)+,(a2)
	move.b	(a0)+,2(a2)
	move.b	(a0)+,168(a2)
	move.b	(a0)+,170(a2)
	move.b	(a0)+,336(a2)
	move.b	(a0)+,338(a2)
	move.b	(a0)+,504(a2)
	move.b	(a0)+,506(a2)
	move.b	(a0)+,672(a2)
	move.b	(a0)+,674(a2)
	move.b	(a0)+,840(a2)
	move.b	(a0)+,842(a2)

	addq.l	#7,a2
	dbra	d7,skrivuthexloop2
	rts

enrts:	rts

skrivuttext:	; d0  x     d1	y    a3 pekare till textstr„ngen
	add.w	#16,d0
	move.l	bildminne,a2
	mulu	#168,d1 	; R„kna ut var i bildminnet som den
	add.l	d1,a2		; skall skriva
	move.w	d0,d1
	and.w	#%1111111111110000,d0
	lsr.w	#1,d0
	add.w	d0,a2
	lea	ascii,a4
	and.w	#$7,d1
	beq.s	inteextrabyte
	addq.w	#1,a2
	bra	skrivuttextnastaloop2
inteextrabyte:
skrivuttextloop:	
	moveq	#0,d0
	move.b	(a3)+,d0
	beq.s	enrts
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a4,d0.w),a0
	move.b	(a0),(a2)
	move.b	2(a0),2(a2)
	move.b	8(a0),168(a2)
	move.b	10(a0),170(a2)
	move.b	16(a0),336(a2)
	move.b	18(a0),338(a2)
	move.b	24(a0),504(a2)
	move.b	26(a0),506(a2)
	move.b	32(a0),672(a2)
	move.b	34(a0),674(a2)
	move.b	40(a0),840(a2)
	move.b	42(a0),842(a2)
	addq.l	#1,a2
skrivuttextnastaloop:
	moveq	#0,d0
	move.b	(a3)+,d0
	beq	enrts
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a4,d0.w),a0
	move.b	(a0),(a2)
	move.b	2(a0),2(a2)
	move.b	8(a0),168(a2)
	move.b	10(a0),170(a2)
	move.b	16(a0),336(a2)
	move.b	18(a0),338(a2)
	move.b	24(a0),504(a2)
	move.b	26(a0),506(a2)
	move.b	32(a0),672(a2)
	move.b	34(a0),674(a2)
	move.b	40(a0),840(a2)
	move.b	42(a0),842(a2)
	addq.l	#7,a2
	bra	skrivuttextloop

skrivuttextloop2:	
	moveq	#0,d0
	move.b	(a3)+,d0
	beq	enrts
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a4,d0.w),a0
	move.b	(a0),(a2)
	move.b	2(a0),2(a2)
	move.b	8(a0),168(a2)
	move.b	10(a0),170(a2)
	move.b	16(a0),336(a2)
	move.b	18(a0),338(a2)
	move.b	24(a0),504(a2)
	move.b	26(a0),506(a2)
	move.b	32(a0),672(a2)
	move.b	34(a0),674(a2)
	move.b	40(a0),840(a2)
	move.b	42(a0),842(a2)
	addq.l	#1,a2
skrivuttextnastaloop2:
	moveq	#0,d0
	move.b	(a3)+,d0
	beq	enrts
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a4,d0.w),a0
	move.b	(a0),(a2)
	move.b	2(a0),2(a2)
	move.b	8(a0),168(a2)
	move.b	10(a0),170(a2)
	move.b	16(a0),336(a2)
	move.b	18(a0),338(a2)
	move.b	24(a0),504(a2)
	move.b	26(a0),506(a2)
	move.b	32(a0),672(a2)
	move.b	34(a0),674(a2)
	move.b	40(a0),840(a2)
	move.b	42(a0),842(a2)
	addq.l	#7,a2
	bra	skrivuttextloop2


;=========== H„r „r alla rutiner som utf”rs n„r man trycker p† en knapp ==

ritautkanalpaav:
	moveq	#11-1,d7
loopparna:
	move.b	(a1),(a0)
	move.b	2(a1),2(a0)
	lea	168(a0),a0
	addq.l	#8,a1
	dbra	d7,loopparna
	rts

onoffchannel1:
	move.l	bildminne,a0
	move.l	a0,a1
	lea	(168*4)+105+8(a0),a0
	neg.w	chanel1onoff
	bpl.s	kanal1av
	add.l	#((266*168)+(2*8*7*39)+(8*32*12)+(104*39)+(64*41*2)+(8*11*8)),a1
	bra.s	kanal1pa
kanal1av:
	add.l	#((266*168)+(2*8*7*39)+(8*32*12)+(104*39)+(64*41*2)),a1
kanal1pa:
	bsr.s	ritautkanalpaav
	rts

onoffchannel2:
	move.l	bildminne,a0
	move.l	a0,a1
	lea	(168*4)+112+8(a0),a0
	neg.w	chanel2onoff
	bpl.s	kanal2av
	add.l	#((266*168)+(2*8*7*39)+(8*32*12)+(104*39)+(64*41*2)+(8*11*9)),a1
	bra.s	kanal2pa
kanal2av:
	add.l	#((266*168)+(2*8*7*39)+(8*32*12)+(104*39)+(64*41*2)+(8*11*1)),a1
kanal2pa:
	bsr.s	ritautkanalpaav
	rts

onoffchannel3:
	move.l	bildminne,a0
	move.l	a0,a1
	lea	(168*4)+113+8(a0),a0
	neg.w	chanel3onoff
	bpl.s	kanal3av
	add.l	#((266*168)+(2*8*7*39)+(8*32*12)+(104*39)+(64*41*2)+(8*11*10)),a1
	bra.s	kanal3pa
kanal3av:
	add.l	#((266*168)+(2*8*7*39)+(8*32*12)+(104*39)+(64*41*2)+(8*11*2)),a1
kanal3pa:
	bsr	ritautkanalpaav
	rts

onoffchannel4:
	move.l	bildminne,a0
	move.l	a0,a1
	lea	(168*4)+120+8(a0),a0
	neg.w	chanel4onoff
	bpl.s	kanal4av
	add.l	#((266*168)+(2*8*7*39)+(8*32*12)+(104*39)+(64*41*2)+(8*11*11)),a1
	bra.s	kanal4pa
kanal4av:
	add.l	#((266*168)+(2*8*7*39)+(8*32*12)+(104*39)+(64*41*2)+(8*11*3)),a1
kanal4pa:
	bsr	ritautkanalpaav
	rts

onoffchannel5:
	move.l	bildminne,a0
	move.l	a0,a1
	lea	(168*4)+121+8(a0),a0
	neg.w	chanel5onoff
	bpl.s	kanal5av
	add.l	#((266*168)+(2*8*7*39)+(8*32*12)+(104*39)+(64*41*2)+(8*11*12)),a1
	bra.s	kanal5pa
kanal5av:
	add.l	#((266*168)+(2*8*7*39)+(8*32*12)+(104*39)+(64*41*2)+(8*11*4)),a1
kanal5pa:
	bsr	ritautkanalpaav
	rts

onoffchannel6:
	move.l	bildminne,a0
	move.l	a0,a1
	lea	(168*4)+128+8(a0),a0
	neg.w	chanel6onoff
	bpl.s	kanal6av
	add.l	#((266*168)+(2*8*7*39)+(8*32*12)+(104*39)+(64*41*2)+(8*11*13)),a1
	bra.s	kanal6pa
kanal6av:
	add.l	#((266*168)+(2*8*7*39)+(8*32*12)+(104*39)+(64*41*2)+(8*11*5)),a1
kanal6pa:
	bsr	ritautkanalpaav
	rts

onoffchannel7:
	move.l	bildminne,a0
	move.l	a0,a1
	lea	(168*4)+129+8(a0),a0
	neg.w	chanel7onoff
	bpl.s	kanal7av
	add.l	#((266*168)+(2*8*7*39)+(8*32*12)+(104*39)+(64*41*2)+(8*11*14)),a1
	bra.s	kanal7pa
kanal7av:
	add.l	#((266*168)+(2*8*7*39)+(8*32*12)+(104*39)+(64*41*2)+(8*11*6)),a1
kanal7pa:
	bsr	ritautkanalpaav
	rts

onoffchannel8:
	move.l	bildminne,a0
	move.l	a0,a1
	lea	(168*4)+136+8(a0),a0
	neg.w	chanel8onoff
	bpl.s	kanal8av
	add.l	#((266*168)+(2*8*7*39)+(8*32*12)+(104*39)+(64*41*2)+(8*11*15)),a1
	bra.s	kanal8pa
kanal8av:
	add.l	#((266*168)+(2*8*7*39)+(8*32*12)+(104*39)+(64*41*2)+(8*11*7)),a1
kanal8pa:
	bsr	ritautkanalpaav
	rts


ritautenstorform:		; Skriver ut en stor form till bildminnet
	moveq	#39-1,d7
loopautenstorform:
	move.l	(a2),(a3)
	move.l	8(a2),8(a3)
	move.l	16(a2),16(a3)
	move.l	24(a2),24(a3)
	move.l	32(a2),32(a3)
	move.l	40(a2),40(a3)
	move.l	48(a2),48(a3)
	move.l	56(a2),56(a3)
	move.l	64(a2),64(a3)
	move.l	72(a2),72(a3)
	move.l	80(a2),80(a3)
	move.l	88(a2),88(a3)
	move.l	96(a2),96(a3)
	lea	168(a3),a3
	lea	104(a2),a2
	dbra	d7,loopautenstorform
	rts

sparstorform:		; Skriver ut en stor form till bildminnet
	moveq	#39-1,d7
loopsparstorform:
	move.l	(a2),(a3)
	move.l	8(a2),8(a3)
	move.l	16(a2),16(a3)
	move.l	24(a2),24(a3)
	move.l	32(a2),32(a3)
	move.l	40(a2),40(a3)
	move.l	48(a2),48(a3)
	move.l	56(a2),56(a3)
	move.l	64(a2),64(a3)
	move.l	72(a2),72(a3)
	move.l	80(a2),80(a3)
	move.l	88(a2),88(a3)
	move.l	96(a2),96(a3)
	lea	168(a2),a2
	lea	104(a3),a3
	dbra	d7,loopsparstorform
	rts

optionsrutin:			; Tar hand om n„r man trycker p† OPTIONS
	move.l	#optionskoors,losapositioner
	move.l	#optionsrots,losarutiner
	move.l	bildminne,a0
	lea	(18*168+56)+8(a0),a1		; a1 till bilden
	add.l	#((266*168)+(2*8*7*39)+(8*32*12)),a0	; a0 till infoformen
	move.l	a1,a2
	lea	4(a0),a3		; Spar bakgrunden
	bsr	sparstorform
	move.l	a1,a3
	move.l	a0,a2		; Rita ut den
	bsr	ritautenstorform
	rts

slutamedoptions:	; Tar hand om n„r man trycker p† Exit i OPTIONS
	move.l	#huvudlospos,losapositioner
	move.l	#huvudlosrutiner,losarutiner
	move.l	bildminne,a0
	lea	(18*168+56)+8(a0),a1		; a1 till bilden
	add.l	#((266*168)+(2*8*7*39)+(8*32*12)),a0	; a0 till infoformen
	move.l	a1,a2
	move.l	a0,a3			; Spar bakgrunden
	bsr	sparstorform
	move.l	bildminne,a0
	lea	(18*168+56)+8(a0),a1		; a1 till bilden
	move.l	a1,a3
	add.l	#((266*168)+(2*8*7*39)+(8*32*12)),a0	; a0 till infoformen
	lea	4(a0),a2		; Ladda upp bakgrunden
	bsr	ritautenstorform
	rts

tangrepp†av:
	dc.w	-1	; -1 p†   0 av

setreptonoff:
	not.w	tangrepp†av
	move.l	bildminne,a0
	lea	((39*168)+113)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#1-1,d7 		; 1 byte vidd p† notten
	bsr	makeinversojamn
	rts

loopordupp:		; 0 duppar       -1 loopar
	dc.w	0

doloopordupp:			; St„ller in om usern vill att vi skall
	not.w	loopordupp	; loopar eller duppa ut musikskaparkoden
	move.l	bildminne,a0
	lea	((39*168)+121)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#1-1,d7 		; 1 byte vidd p† notten
	bsr	makeinversojamn

	bsr	s„ttregisterefterfreq
	bsr	setsamplereplayspeed

	rts

ritapatternettrashat:		; Rutinen som fixar trashupdate p†
	tst.w	CallEvntTimerAsOftenAsPossible
	beq.s	intedelamedtidtillGEM
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	sp,dummen
	move.l	oldstack,-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa tebax till user
	addq.l	#6,sp
	moveq	#0,d1			; Dela med tid till GEM s† att en
	jsr	evnt_timer		; begr„nsad multitasking „r
	clr.l	-(sp)			; m”jlig
	move.w	#$20,-(sp)
	trap	#1			; Hoppa upp i super
	addq.l	#6,sp
	move.l	dummen,sp
	movem.l	(sp)+,d0-d7/a0-a6
intedelamedtidtillGEM:
	tst.l	editorpek
	bne.s	k”rp†mededitorpattern
	tst.l	fulleditorpek	; patterndatan
	beq.s	k”rp†meddetvanliga
k”rp†mededitorpattern:
	jmp	fixaihopfulleditorn
	rts
k”rp†meddetvanliga:
	tst.w	trashupdate
	beq.s	intevisaskitentrashat
	tst.w	lowershower
	bne.s	intevisaskitentrashat
	jsr	skrivutenhelskarmspattern
intevisaskitentrashat:
	rts

trashupdateonoff:		; St„ller in om patteruppdateraren skall
	tst.w	runwithtimerA
	bne.s	n„n„n„n„n„n„n
supertrashNOW:
	not.w	trashupdate	; ske i interupt eller n„r det finns tid
	move.l	bildminne,a0
	lea	((39*168)+128)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#1-1,d7 		; 1 byte vidd p† notten
	bsr	makeinversjamn
n„n„n„n„n„n„n:
	rts

trashupdate:
	dc.w	0	; 0 av    -1 p†

VUp†av:
	dc.w	-1	; -1 p†   0 av

setVUmeteronoff:
	not.w	VUp†av
	move.l	bildminne,a0
	lea	((39*168)+120)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#1-1,d7 		; 1 byte vidd p† notten
	bsr	makeinversjamn
	tst.w	VUp†av
	bne.s	intetabortVUmetrarna
	move.l	bildminne,a0
	addq.w	#2,a0		; Ta bort VU-metrarna
	move.w	#104-1,d0
	moveq	#0,d1
tabortallaVUmetrarna:
	move.w	d1,(a0)
	lea	168(a0),a0
	dbra	d0,tabortallaVUmetrarna
intetabortVUmetrarna:
	rts

VU1:	dc.w	0
VU2:	dc.w	0
VU3:	dc.w	0
VU4:	dc.w	0
VU5:	dc.w	0
VU6:	dc.w	0
VU7:	dc.w	0
VU8:	dc.w	0
converteradata:
	dc.w	%0000000000000000
	dc.w	%0000000000000001
	dc.w	%0000000000000011
	dc.w	%0000000000000111
	dc.w	%0000000000001111
	dc.w	%0000000000011111
	dc.w	%0000000000111111
	dc.w	%0000000001111111
	dc.w	%0000000011111111
	dc.w	%0000000111111111
	dc.w	%0000001111111111
	dc.w	%0000011111111111
	dc.w	%0000111111111111
	dc.w	%0001111111111111
	dc.w	%0011111111111111
	dc.w	%0111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111

drawVUmeters:			; Rita ut VU-metrarna
	tst.w	VUp†av
	beq.s	VUmetrarna„ravslagna

	move.w	#1,VUchanged

	subq.b	#1,VU1+1
	bpl.s	okvu1
	clr.w	VU1
okvu1:	subq.b	#1,VU2+1
	bpl.s	okvu2
	clr.w	VU2
okvu2:	subq.b	#1,VU3+1
	bpl.s	okvu3
	clr.w	VU3
okvu3:	subq.b	#1,VU4+1
	bpl.s	okvu4
	clr.w	VU4
okvu4:	subq.b	#1,VU5+1
	bpl.s	okvu5
	clr.w	VU5
okvu5:	subq.b	#1,VU6+1
	bpl.s	okvu6
	clr.w	VU6
okvu6:	subq.b	#1,VU7+1
	bpl.s	okvu7
	clr.w	VU7
okvu7:	subq.b	#1,VU8+1
	bpl.s	okvu8
	clr.w	VU8
okvu8:
VUmetrarna„ravslagna:
	rts

onlycurrent:			; S„tt s† att blockhanteringen bara p†verkar
	tst.w	blockhandling	; aktuell kanal
	beq.s	endastenkanalredanvald
	move.l	bildminne,a0
	lea	((22*168)+145)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#2-1,d7 		; 2 bytes vidd p† notten
	bsr	makeinversojamn
	move.l	bildminne,a0
	lea	((31*168)+145)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#2-1,d7 		; 2 bytes vidd p† notten
	bsr	makeinversojamn
	clr.w	blockhandling
endastenkanalredanvald:
	rts

allaktiv:			; S„tt s† att blockhanteringen p†verkar
	tst.w	blockhandling	; alla kanaler
	bne.s	allakanalerredanvald
	move.l	bildminne,a0
	lea	((22*168)+145)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#2-1,d7 		; 2 bytes vidd p† notten
	bsr	makeinversojamn
	move.l	bildminne,a0
	lea	((31*168)+145)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#2-1,d7 		; 2 bytes vidd p† notten
	bsr	makeinversojamn
	move.w	#1,blockhandling
allakanalerredanvald:
	rts

blockhandling:
	dc.w	0

musinsert:
	move.w	#1,uppdateranup†eng†ng
	move.w	blockhandling,d0
	jsr	insertinpattern
	rts

musdelete:
	move.w	#1,uppdateranup†eng†ng
	move.w	blockhandling,d0
	jsr	deleteinpattern
	rts

musclear:
	move.w	#1,uppdateranup†eng†ng
	tst.w	blockset
	bne.s	rensaettblockist„llet
	move.w	blockhandling,d7
	jsr	rensaaktuelltpattern
	rts
rensaettblockist„llet:
	move.w	blockhandling,d7
	jsr	rensablocket
	rts

muscopy:
	move.w	#1,uppdateranup†eng†ng
	move.w	blockhandling,d7
	jsr	kopierablocket
	rts

musinvers:
	move.w	#1,uppdateranup†eng†ng
	move.w	blockhandling,d7
	jsr	inverterablocket
	rts

musmove:
	move.w	#1,uppdateranup†eng†ng
	move.w	blockhandling,d7
	jsr	flyttablocket
	rts


editrutin:			; Tar hand om n„r man trycker p† EDIT
	move.l	#editkoors,losapositioner
	move.l	#editrots,losarutiner
	move.l	bildminne,a0
	lea	(18*168+96)+8(a0),a1	; a1 till bilden
	add.l	#60712+2128,a0		; a0 till editformen
	move.l	a1,a2
	lea	4(a0),a3		; Spar bakgrunden
	bsr	sparmellanstorform
	move.l	a1,a3
	move.l	a0,a2		; Rita ut den
	bsr.s	ritautenmellanstorform
	rts

slutamededit:		; Tar hand om n„r man trycker p† Exit i EDIT
	move.l	#huvudlospos,losapositioner
	move.l	#huvudlosrutiner,losarutiner
	move.l	bildminne,a0
	lea	(18*168+96)+8(a0),a1	; a1 till bilden
	add.l	#60712+2128,a0		; a0 till editformen
	move.l	a1,a2
	move.l	a0,a3			; Spar bakgrunden
	bsr.s	sparmellanstorform
	move.l	bildminne,a0
	lea	(18*168+96)+8(a0),a1	; a1 till bilden
	move.l	a1,a3
	add.l	#60712+2128,a0		; a0 till editformen
	lea	4(a0),a2		; Ladda upp bakgrunden
	bsr.s	ritautenmellanstorform
	rts

ritautenmellanstorform:		; Skriver ut en mellanstor form till bildminnet
	moveq	#40-1,d7
loopautenmellanstorform:
	move.l	(a2),(a3)
	move.l	8(a2),8(a3)
	move.l	16(a2),16(a3)
	move.l	24(a2),24(a3)
	move.l	32(a2),32(a3)
	move.l	40(a2),40(a3)
	move.l	48(a2),48(a3)
	move.l	56(a2),56(a3)
	lea	168(a3),a3
	lea	64(a2),a2
	dbra	d7,loopautenmellanstorform
	rts

sparmellanstorform:		; Skriver ut en mellanstor form till bildminnet
	moveq	#40-1,d7
loopsparmellanstorform:
	move.l	(a2),(a3)
	move.l	8(a2),8(a3)
	move.l	16(a2),16(a3)
	move.l	24(a2),24(a3)
	move.l	32(a2),32(a3)
	move.l	40(a2),40(a3)
	move.l	48(a2),48(a3)
	move.l	56(a2),56(a3)
	lea	168(a2),a2
	lea	64(a3),a3
	dbra	d7,loopsparmellanstorform
	rts

ritautenlitenform:		; Skriver ut en liten form till bildminnet
	moveq	#39-1,d7
loopautenlitenform:
	move.l	(a2),(a3)
	move.l	8(a2),8(a3)
	move.l	16(a2),16(a3)
	move.l	24(a2),24(a3)
	move.l	32(a2),32(a3)
	move.l	40(a2),40(a3)
	move.l	48(a2),48(a3)
	lea	168(a3),a3
	lea	8*7(a2),a2
	dbra	d7,loopautenlitenform
	rts

sparlitenform:		; Skriver ut en liten form till bildminnet
	moveq	#39-1,d7
loopsparlitenform:
	move.l	(a2),(a3)
	move.l	8(a2),8(a3)
	move.l	16(a2),16(a3)
	move.l	24(a2),24(a3)
	move.l	32(a2),32(a3)
	move.l	40(a2),40(a3)
	move.l	48(a2),48(a3)
	lea	168(a2),a2
	lea	8*7(a3),a3
	dbra	d7,loopsparlitenform
	rts

menumakeasample:		; ™ppnar menyn till make
	move.l	#makekoors,losapositioner
	move.l	#makerots,losarutiner
	move.l	bildminne,a0
	lea	(18*168+104)+8(a0),a1	; a1 till bilden
	add.l	#102144+2128,a0 	; a0 till infoformen
	move.l	a1,a2
	lea	4(a0),a3		; Spar bakgrunden
	bsr.s	sparlitenform
	move.l	a1,a3
	move.l	a0,a2		; Rita ut den
	bsr	ritautenlitenform
	rts

makecliponoff:
	dc.w	1	; 1 on  0 off
makesample:
	dc.w	1	; Sample som kommer att bli skapad
makefrequense:
	dc.w	24	; Bashastigheten p† samplingen
makevolume:
	dc.w	$40	; Makevolymen
lengthofmixsam:
	dc.l	0
mixison:dc.w	0
frequensetocreate:
	dc.l	0
totalinonevbl:
	dc.w	0	; Heltalsdelen av hur mycket vi skall skapa/vbl
totalinonevblrest:	; Restdelen av hur mycket vi skall skapa/vbl
	dc.w	0
rest:	dc.w	0	; Total rest
nowtotalcreated:	; Just nu totalt skapade bytes
	dc.l	0
created:dc.l	0
maxinthisvbl:		; Antal vi max skall skapa denna vbl
	dc.w	0
orginalpek:
	dc.l	0
laddaommedorginalpek:
	dc.w	0
oldmixpos:
	dc.w	0

skapamixmedtempokontroll:	; H„r anropar vi mixrutinen
				; d0 inneh†ller 1-125
	move.l	frequensetocreate,d1
	mulu	d0,d1
	divu	#125*50,d1
	and.l	#$FFFF,d1
	move.w	skapade,d2
	add.w	d1,d2
	cmp.w	maxinthisvbl,d2
	ble.s	okvikanskapas†mycketdennamix
	move.w	maxinthisvbl,d1
	sub.w	skapade,d1
okvikanskapas†mycketdennamix:
	add.w	d1,skapade
	tst.w	d1
	beq.s	struntaioskapan†geimix
	subq.w	#1,d1
	move.w	d1,skapa
	jsr	detvarenloopadkodh„r	; Skapa ett stycke musik
struntaioskapan†geimix:
	rts

blocket„rintesattf”rmixning:
	lea	pleasesetblock1,a5	; Meddela att blocket m†ste
	lea	pleasesetblock2,a6	; vara satt f”r att det skall
	jsr	makejeppform		; g† och mixa.
	rts

ingetminnekvarf”rmix:
	lea	full1,a5		; Meddela att det inte finns
	lea	full3,a6		; tillr„ckligt med minne kvar
	jsr	makejeppform		; f”r mixnig.
	move.w	(sp)+,$ffff8900.w
	clr.w	donotdoanymusicorsomeshit
	rts

startmixblock:
	tst.w	blockset		; Žr blocket satt?
	beq.s	blocket„rintesattf”rmixning

	jsr	stopknapp

	move.w	#1,donotdoanymusicorsomeshit
	move.w	$ffff8900.w,-(sp)
	clr.w	$ffff8900.w
	jsr	getmemstatus		; Ta reda p† minnesstatus
	cmp.l	#3000,d5		; d5 inneh†ller ledigt minne
	ble.s	ingetminnekvarf”rmix
	cmp.l	#$FFFE+2000,d5
	ble.s	mindre„nenFFFEsamplingkvar
	move.l	#$FFFE+2000,d5
mindre„nenFFFEsamplingkvar:		; d5 l„ngden p† samplingen + 2000
	moveq	#0,d0
	move.w	makesample,d0
	subq.w	#1,d0		; Leta r„tt p† vart vi skall stoppa
	add.w	d0,d0		; in pekaren till minnesblocket
	add.w	d0,d0
	add.l	#samplestarts,d0
	move.l	d0,a0
	move.l	a0,pekaretillsampekaretabellen
	move.l	d5,-(sp)
	cmp.l	#dummy,(a0)
	beq.s	detta„rentomsamplingf”rmix
	move.l	pekaretillsampekaretabellen,a0
	move.l	a0,a1
	move.l	(a0),a0
	jsr	free
	move.l	a1,a0
	move.l	#dummy,(a0)
detta„rentomsamplingf”rmix:
	move.l	(sp),d0
	move.l	pekaretillsampekaretabellen,a0
	moveq	#0,d1
	jsr	malloc		; Beg„r minne f”r samplingen

	lea	installmix,a3		; Pekare till str„ng
	move.w	#80,d0			; x		Songnamn
	move.w	#85,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen

	move.l	(sp)+,d5	; d5 l„ngden p† samplingen + 2000
	sub.l	#2000,d5
	move.l	pekaretillsampekaretabellen,a0
	move.l	(a0),d1
	add.l	d5,d1	; samplingsdata finns
	add.l	#1000,d1
	move.l	d1,32*4(a0)
	move.l	(a0),a5		; a5 pekare till sampleblocket
	move.l	d5,lengthofmixsam
				; Installera buffrar f”r mix h„r
	moveq	#0,d3
	move.w	makevolume,d3
	bsr	makevilfaaaaaast; Calculate volume tables
	lea	stab0,a0
	moveq	#0,d2
	move.w	makefrequense,d2
	add.w	d2,d2
	move.l	#3546895,d4
	tst.w	basspeed
	beq.s	s„ttinteh”gfrek24
	bmi.s	special2024
	move.l	#5320343,d4
	bra.s	s„ttinteh”gfrek24
special2024:
	move.l	#4304818,d4
s„ttinteh”gfrek24:
	moveq	#0,d3
	lea	mt_PeriodTable,a2
	move.w	(a2,d2.w),d3
	divu	d3,d4
	and.l	#$FFFF,d4
	move.l	d4,frequensetocreate
	move.w	(a2,d2.w),d2
	swap	d2
	clr.w	d2
	bsr	incrcal 	; Calculate tonetables

	lea	nowmixing,a3		; Pekare till str„ng
	move.w	#80,d0			; x		Songnamn
	move.w	#85,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen
				; Mixa h„r
	move.w	#1,donotdoanymusicorsomeshit
	move.w	antalkanaler,-(sp)
	move.w	#8,antalkanaler

	move.l	frequensetocreate,d0
	divu	#50,d0
	move.w	d0,totalinonevbl
	move.w	d0,maxinthisvbl
	clr.w	nowtotalcreated
	move.w	d0,nowtotalcreated+2
	addq.l	#1,nowtotalcreated
	clr.w	d0
	divu	#50,d0
	move.w	d0,totalinonevblrest

	lea	mixtyp0,a5
	lea	mixtyp1,a4
	moveq	#26-1,d5
	moveq	#26-1,d4
	tst.w	makecliponoff
	beq.s	k”rutanclippen
	lea	mixtyp2,a5
	lea	mixtyp3,a4
	moveq	#40-1,d5
	moveq	#56-1,d4
k”rutanclippen:

	move.l	a5,a6
	move.l	kanal23rutin,a0		; Kanal 2 o 3
	move.w	d5,d7
	bsr	viskallloopamusikrutinen
	move.w	typ4,(a0)+		; rts

	move.l	a4,a6
	lea	kanal14rutin,a0		; Kanal 1 o 4
	move.w	d4,d7
	bsr	viskallloopamusikrutinen
	move.w	typ4,(a0)+		; rts

	move.l	a4,a6
	move.w	d4,d7
	move.l	kanal67rutin,a0		; Kanal 6 o 7
	bsr	viskallloopamusikrutinen
	move.w	typ4,(a0)+		; rts

	move.l	a4,a6
	move.w	d4,d7
	lea	kanal58rutin,a0		; Kanal 5 o 8
	bsr	viskallloopamusikrutinen
	move.w	typ4,(a0)+		; rts

	move.l	kanal23rutin,ddddd+2	; offset
	addq.l	#2,ddddd+2
	move.l	kanal67rutin,eeeee+2
	addq.l	#2,eeeee+2
	move.l	#kanal14rutin,fffff+2
	addq.l	#2,fffff+2
	move.l	#kanal58rutin,ggggg+2
	addq.l	#2,ggggg+2

	move.l	pekaretillsampekaretabellen,a0
	move.l	(a0),samplepek
	move.l	(a0),newposinbuffer
	move.l	(a0),orginalpek
	move.w	#1,mixison
	move.w	loopordupp,-(sp)
	move.w	#1,loopordupp
	clr.w	musicwait
	move.w	#1,patternplay
	clr.w	pattpos
	clr.w	lastpos
	clr.w	oldmixpos
	move.w	#-1,counter
	clr.l	tempor„knare
	clr.l	created
	clr.w	laddaommedorginalpek
skapaensampling:
	clr.w	skapade
	cmp.l	#12500,tempor„knare
	bgt.s	k”rbaraskapandedennaframe23
	tst.l	tempor„knare
	beq.s	inteenlitenrestsenf”rraframen23
	move.l	tempor„knare,d0
	cmp.l	#12500,d0
	ble.s	detgickmindre„nenframe23
k”rbaraskapandedennaframe23:
	moveq	#125,d0
	bsr	skapamixmedtempokontroll
	bra	tempoteratklart23
detgickmindre„nenframe23:
	add.w	#50,d0
	divu	#100,d0
	tst.w	d0
	beq.s	inteenlitenrestsenf”rraframen23
	bsr	skapamixmedtempokontroll
inteenlitenrestsenf”rraframen23:
	move.l	tempor„knare,d0
	cmp.l	#12500,d0
	bgt	tempoteratklart23
	move.l	d0,d2
	add.l	tempoadder,d0
	move.l	d0,tempor„knare		; R„kna fram r„knaren
	move.l	#12500,d1
	sub.l	d2,d1
	cmp.l	tempoadder,d1
	ble.s	r„knaframenhalvmesyrinnanvislutar23
	jsr	music			; K”r lite musik
	tst.w	laddaommedorginalpek
	beq.s	inteladdaommedorginalpek1
	move.l	orginalpek,newposinbuffer
	clr.w	laddaommedorginalpek
inteladdaommedorginalpek1:
	move.l	tempoadder,d0		; Skapa en del
	add.w	#50,d0
	divu	#100,d0
	tst.w	d0
	beq.s	inteenlitenrestsenf”rraframen23
	bsr	skapamixmedtempokontroll
	bra.s	inteenlitenrestsenf”rraframen23
r„knaframenhalvmesyrinnanvislutar23:	; Skapa det sista innan vi slutar
	tst.l	d1
	bpl.s	intesetillattdetblirpositivt23
	add.l	tempoadder,d1
intesetillattdetblirpositivt23:
	move.l	d1,-(sp)
	jsr	music			; K”r lite musik
	tst.w	laddaommedorginalpek
	beq.s	inteladdaommedorginalpek2
	move.l	orginalpek,newposinbuffer
	clr.w	laddaommedorginalpek
inteladdaommedorginalpek2:
	move.l	(sp)+,d1
	divu	#100,d1
	move.w	d1,d0
	tst.w	d1
	beq	inteenlitenrestsenf”rraframen23
	bsr	skapamixmedtempokontroll
	bra	inteenlitenrestsenf”rraframen23
tempoteratklart23:
	sub.l	#12500,tempor„knare

	move.w	pattpos,d0
	cmp.w	oldmixpos,d0
	blt.s	inteladdaomstart
	lsr.w	#5,d0
	move.w	blockstart,d1
	cmp.w	d1,d0
	bgt.s	inteladdaomstart
	move.w	#1,laddaommedorginalpek
	move.l	orginalpek,newposinbuffer
inteladdaomstart:

	move.w	totalinonevblrest,d0
	move.w	rest,d1
	move.l	nowtotalcreated,d2
	moveq	#0,d3
	move.w	totalinonevbl,d3
	add.w	d0,d1
	addx.l	d3,d2
	move.w	d1,rest
	move.l	d2,nowtotalcreated
	moveq	#0,d4
	move.w	maxinthisvbl,d4
	add.l	d4,created
	move.l	created,d4
	sub.l	d4,d2
	move.w	d2,maxinthisvbl

	tst.w	lowershower
	bne.s	intevisapatterneteftersomvi„risameditorn
	jsr	skrivutenhelskarmspattern
intevisapatterneteftersomvi„risameditorn:

	tst.w	mixison
	beq.s	slutamixavi„rislutetavblocket
	move.w	blockend,d0
	move.w	lastpos,d1
	cmp.w	oldmixpos,d1
	blt.s	slutamixavi„rislutetavblocket
	move.w	d1,oldmixpos
	lsr.w	#5,d1
	cmp.w	d1,d0
	blt.s	slutamixavi„rislutetavblocket
	move.l	newposinbuffer,d0
	move.l	lengthofmixsam,d1
	move.l	pekaretillsampekaretabellen,a0
	add.l	(a0),d1
	cmp.l	d0,d1
	bgt	skapaensampling
slutamixavi„rislutetavblocket:
	move.w	#1,mixison
	jsr	stopknapp
	move.w	(sp)+,loopordupp
	move.w	(sp)+,antalkanaler
				; terst„ll spelaren
	jsr	stopknapp
	move.l	oldoldoldvol,d3
	bsr	makevilfaaaaaast; Calculate volume tables
	jsr	s„ttregisterefterfreq
	jsr	setsamplereplayspeed	; Fixa tillbaka tonerna
	jsr	fixatillsamnamnet
	clr.w	mixison

	move.l	lengthofmixsam,d5	; d5 l„ngden p† samplingen
	move.l	pekaretillsampekaretabellen,a0
	move.l	(a0),a0
	subq.l	#1,d5
letaefterslutet:
	tst.b	(a0,d5.l)
	bne.s	hittatslutetochbra„rv„ldet
	subq.l	#1,d5
	bne.s	letaefterslutet
hittatslutetochbra„rv„ldet:
	cmp.l	#2,d5
	bge.s	slutet„rnun„raf”rmixen
	moveq	#2,d5
slutet„rnun„raf”rmixen:
	addq.l	#1,d5
	and.l	#$FFFFFFFE,d5

	move.w	makesample,d0
	subq.w	#1,d0			; Installera sampledata efter
	mulu	#$1E,d0			; mixningen
	add.l	#modsam,d0
	move.l	d0,a5
	lea	32*30(a5),a6
	move.l	a5,a3
	move.l	#'MIXE',(a5)+
	move.l	#'D ..',(a5)+
	move.l	#'.   ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	d5,(a5)+
	move.w	#$0040,(a5)+
	clr.l	(a5)+
	move.l	a6,a5
	move.l	a5,a3
	move.l	#'MIXE',(a5)+
	move.l	#'D ..',(a5)+
	move.l	#'.   ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.w	#$2000,(a5)+
	move.w	d5,(a5)
	lsr.w	(a5)+
	move.w	#$0040,(a5)+
	clr.w	(a5)+
	move.w	#1,(a5)+
	move.l	pekaretillsampekaretabellen,a0
	move.l	(a0),a2
	move.l	a2,a3
	add.l	d5,a3
	move.w	#1000/4-1,d0
koppauppsamplingentilldeth”gre424444:
	clr.l	(a3)+
	dbra	d0,koppauppsamplingentilldeth”gre424444
	move.w	#1000/4-1,d0
koppauppsamplingentilldeth”gre424:
	move.l	(a2)+,(a3)+
	dbra	d0,koppauppsamplingentilldeth”gre424

	bsr	skrivuttillhorandeinfo
	move.w	(sp)+,$ffff8900.w
	clr.w	donotdoanymusicorsomeshit
	move.w	#-1,currentsample
	jsr	checkifsamplechanged
	rts

addfreq:cmp.w	#35,makefrequense
	bge.s	inteadderaeftersommaxfreq
	addq.w	#1,makefrequense
	bsr.s	showwhichtone
inteadderaeftersommaxfreq:
	rts

subfreq:tst.w	makefrequense
	ble.s	intesubberaeftersommaxfreq
	subq.w	#1,makefrequense
	bsr.s	showwhichtone
intesubberaeftersommaxfreq:
	rts

showwhichtone:
	move.l	bildminne,a6
	lea	168*28+128+2(a6),a6
	lea	mt_PeriodTable,a0
	move.w	makefrequense,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d1
	lea	tabelldata2,a2
	move.w	d1,d2
	and.w	#%0000001111111100,d1
	and.w	#%1111000000000000,d2
	bne.s	ingen1attskrivautfed444
	lea.l	jamnc1medtomhogsampling,a0
	bra.s	skriuten1afed444
ingen1attskrivautfed444:
	lea.l	jamnc1medenettahogsampling,a0
skriuten1afed444:
	add.l	0(a2,d1.w),a0
	move.w	(a0),(a6)
	move.b	2(a0),8(a6)
	move.w	4(a0),160+8(a6)
	move.b	6(a0),160+8+8(a6)
	move.w	8(a0),320+16(a6)		; R„tt ton
	move.b	10(a0),320+16+8(a6)
	move.w	12(a0),480+24(a6)
	move.b	14(a0),480+24+8(a6)
	move.w	16(a0),640+32(a6)
	move.b	18(a0),640+32+8(a6)
	rts

setclip:
	move.l	bildminne,a0
	lea	((35*168)+105)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#3-1,d7 		; 3 bytes vidd p† notten
	bsr	makeinversojamn
	tst.w	makecliponoff
	beq.s	clippen„rjustnuav
	clr.w	makecliponoff
	rts
clippen„rjustnuav:
	move.w	#1,makecliponoff
	rts

matainmakesample:		; Žnda p† vilken sampling som make
	move.b	makesample+1,numberin	; skall anv„nda
	move.w	#2,numberlen
	move.w	#297,numberx
	move.w	#21,numbery
	bsr	enteranumber	; L†t anv„ndaren mata in ett v„rde
	moveq	#1,d0		; Minv„rde
	moveq	#$1F,d1		; Maxv„rde
	bsr	checkbounding	; Kolla storleken p† den
	move.b	d2,makesample+1
	rts

matainmakevolume:		; Žnda p† vilken volym som make
	move.b	makevolume+1,numberin	; skall anv„nda
	move.w	#2,numberlen
	move.w	#297,numberx
	move.w	#36,numbery
	bsr	enteranumber
	moveq	#1,d0		; Minv„rde
	move.l	#$FFFF,d1	; Maxv„rde
	bsr	checkbounding	; Kolla storleken p† den
	move.b	d2,makevolume+1
	rts

exitmakeasample:		; St„nger menyn till make
	move.l	#huvudlospos,losapositioner
	move.l	#huvudlosrutiner,losarutiner
	move.l	bildminne,a0
	lea	(18*168+104)+8(a0),a1	; a1 till bilden
	add.l	#102144+2128,a0 	; a0 till infoformen
	move.l	a1,a2
	move.l	a0,a3		; Spar bakgrunden
	bsr	sparlitenform
	move.l	a1,a3
	lea	4(a0),a2		; H„mta bakgrunden
	bsr	ritautenlitenform
	rts

oldinfokoors:
	dc.l	0
oldinforots:
	dc.l	0
oldlowershower:
	dc.w	0
oldoldlowershower:
	dc.w	0

inforutinen:			; Tar hand om n„r man trycker p† INFO
	move.w	lowershower,oldlowershower
	tst.w	lowershower
	ble.s	vivisarpatternet
	move.l	bildminne,a3		; Spar bilden
	lea	106*168+8(a3),a2	; a3 till bilden
	add.l	#71960+2128,a3		; a2 till editorn
	bsr	sparsampleeditornelpatterbasen
vivisarpatternet:

	move.l	bildminne,d0
	add.l	#241*168,d0
	move.l	oldcursorpek,oldoldcursorpek
	move.l	d0,oldcursorpek
	move.w	movecursorkoors,muuuuu
	move.w	#1,lowershower
	move.w	#340,movecursorkoors
	move.l	losapositioner,oldinfokoors
	move.l	losarutiner,oldinforots
	move.l	#infokoors,losapositioner
	move.l	#inforots,losarutiner
	move.l	bildminne,a0
	lea	(18*168+104)+8(a0),a1		; a1 till bilden
	add.l	#((266*168)),a0 		; a0 till infoformen
	move.l	a1,a2
	lea	4(a0),a3		; Spar bakgrunden
	bsr	sparlitenform
	move.l	a1,a3
	move.l	a0,a2		; Rita ut den
	bsr	ritautenlitenform

	move.l	bildminne,a2
	move.l	a2,a3
	add.l	#98176+2128,a2
	lea	168*106+8(a3),a3
	moveq	#17,d0
	bsr	skrivutsampleeditorn
	move.w	#142-1,d5
rensarestenavinfon:
	moveq	#0,d0
	lea	-160(a2),a2
	bsr	skrivutsampleeditorn
	dbra	d5,rensarestenavinfon

	bsr.s	printoutthehelptext

skitiinfon:
	rts

helppoint:
	dc.w	0

printoutthehelptext:
	lea	helptable,a6
	add.w	helppoint,a6
	move.w	#19-1,d7
	move.l	(a6),a6
	moveq	#126,d6
k”ruthelptexten:
	move.l	a6,a3
	move.w	#9,d0			; x
	move.w	d6,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen
	move.l	a3,a6
	addq.w	#6,d6
	dbra	d7,k”ruthelptexten
	rts

nexthelpscreen:
	addq.w	#4,helppoint
	lea	helptable,a6
	add.w	helppoint,a6
	tst.l	(a6)
	bne.s	n„stasidatack
	subq.w	#4,helppoint
	rts
n„stasidatack:
	bsr.s	printoutthehelptext
	rts

prevhelpscreen:
	tst.w	helppoint
	beq	ret2
	subq.w	#4,helppoint
	bsr.s	printoutthehelptext
	rts

diskrutinen:			; Tar hand om n„r man trycker p† DISK
	move.l	#diskkoors,losapositioner
	move.l	#diskrots,losarutiner
	move.l	bildminne,a0
	lea	(18*168+104)+8(a0),a1		; a1 till bilden
	add.l	#((266*168))+(8*7*39),a0	; a0 till infoformen
	move.l	a1,a2
	lea	4(a0),a3		; Spar bakgrunden
	bsr	sparlitenform
	move.l	a1,a3
	move.l	a0,a2		; Rita ut den
	bsr	ritautenlitenform
	rts

muuuuu:	dc.w	0

slutamedinfo:		; Tar hand om n„r man trycker p† Exit i INFO
	move.w	muuuuu,movecursorkoors
	move.l	oldinfokoors,losapositioner
	move.l	oldinforots,losarutiner
	move.l	bildminne,a0
	lea	(18*168+104)+8(a0),a1		; a1 till bilden
	move.l	a1,a3
	add.l	#((266*168)),a0 		; a0 till infoformen
	lea	4(a0),a2		; Spar bakgrunden
	bsr	ritautenlitenform
	move.l	oldoldcursorpek,oldcursorpek
	tst.w	oldlowershower
	ble.s	ritatebaxpatternet
	move.l	bildminne,a2
	lea	106*168+8(a2),a3	; a3 till bilden
	add.l	#71960+2128,a2		; a2 till editorn
	bsr	ritautsampleeditornelpatterbasen
	bra.s	alltklartof„rdigt
ritatebaxpatternet:
	move.l	bildminne,a2
	lea	106*168+8(a2),a3	; a3 till bilden
	add.l	#71960+4+2128,a2	; a2 till patternbasen
	bsr	ritautsampleeditornelpatterbasen
alltklartof„rdigt:
	move.w	oldlowershower,lowershower
	jsr	checkifsamplechanged
	rts

slutameddisk:		; Tar hand om n„r man trycker p† Exit i DISK
	move.l	#huvudlospos,losapositioner
	move.l	#huvudlosrutiner,losarutiner
	move.l	bildminne,a0
	lea	(18*168+104)+8(a0),a1		; a1 till bilden
	move.l	a1,a3
	add.l	#((266*168))+(8*7*39),a0	; a0 till infoformen
	lea	4(a0),a2		; Spar bakgrunden
	bsr	ritautenlitenform
	rts

showmemmenu:			; Tar hand om n„r man trycker p† MEM
	move.l	#memkoors,losapositioner
	move.l	#memrots,losarutiner
	move.l	bildminne,a0
	lea	(18*168+104)+8(a0),a1		; a1 till bilden
	add.l	#95992+2128,a0 		; a0 till infoformen
	move.l	a1,a2
	lea	4(a0),a3		; Spar bakgrunden
	bsr	sparlitenform
	move.l	a1,a3
	move.l	a0,a2		; Rita ut den
	bsr	ritautenlitenform

	jsr	getmemstatus

	movem.l	d0-d7,-(sp)
	move.l	d0,blaster
	lea	blaster+1,a3		; Vilket tal skall konverteras
	move.w	#263,d0			; x
	move.w	#20,d1			; y
	move.w	#6-1,d7 		; Hur m†nga siffror
	jsr	skrivuthex		; Skriv ut i hex
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(sp)
	move.l	d1,blaster
	lea	blaster+1,a3		; Vilket tal skall konverteras
	move.w	#263,d0			; x
	move.w	#20+6,d1		; y
	move.w	#6-1,d7 		; Hur m†nga siffror
	jsr	skrivuthex		; Skriv ut i hex
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(sp)
	lea	modsamsave,a0
	moveq	#0,d2
	moveq	#0,d0
	moveq	#31-1,d1
r„knaframhurm†ngaanv„ndasamplebytes:
	move.w	22(a0),d2
	add.l	d2,d0
	add.l	d2,d0			; R„kna hur mycket minne
	lea	30(a0),a0		; samplingarna kr„ver
	dbra	d1,r„knaframhurm†ngaanv„ndasamplebytes
	move.l	d0,blaster
	lea	blaster+1,a3		; Vilket tal skall konverteras
	move.w	#263,d0			; x
	move.w	#20+12,d1		; y
	move.w	#6-1,d7 		; Hur m†nga siffror
	jsr	skrivuthex		; Skriv ut i hex
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(sp)
	lea	song,a0
	moveq	#0,d0
	move.b	songlength,d0
	add.w	d0,a0
	neg.w	d0			; Se till s† att den delen
	add.w	#$80,d0			; av songen som ligger ”ver songl„ngden
	subq.w	#1,d0			; „r tom s† vi inte r„knar med en massa
	bmi.s	fulltanv„ndapattern2	; on”dig data
rensadendelenavsongensominteanv„nds2:
	clr.b	(a0)+
	dbra	d0,rensadendelenavsongensominteanv„nds2
fulltanv„ndapattern2:
	bsr	hittastorstapatternetisongen
	addq.l	#1,d0
	move.l	d0,d3
	cmp.w	#4,antalkanaler
	bne.s	ejg†nger16		; R„kna ut hur m†nga
	mulu	#16*64,d3		; patterns som kommer att
	bra.s	redanmuluat		; sparas
ejg†nger16:
	cmp.w	#6,antalkanaler
	bne.s	ejg†nger24
	mulu	#24*64,d3
	bra.s	redanmuluat
ejg†nger24:
	mulu	#32*64,d3
redanmuluat:
	move.l	d3,blaster
	lea	blaster+1,a3		; Vilket tal skall konverteras
	move.w	#263,d0			; x
	move.w	#20+18,d1		; y
	move.w	#6-1,d7 		; Hur m†nga siffror
	jsr	skrivuthex		; Skriv ut i hex
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(sp)
	move.l	d4,blaster
	lea	blaster+1,a3		; Vilket tal skall konverteras
	move.w	#263,d0			; x
	move.w	#20+24,d1		; y
	move.w	#6-1,d7 		; Hur m†nga siffror
	jsr	skrivuthex		; Skriv ut i hex
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(sp)
	move.l	d5,blaster
	lea	blaster+1,a3		; Vilket tal skall konverteras
	move.w	#263,d0			; x
	move.w	#20+30,d1		; y
	move.w	#6-1,d7 		; Hur m†nga siffror
	jsr	skrivuthex		; Skriv ut i hex
	movem.l	(sp)+,d0-d7
	rts

slutamedmem:		; Tar hand om n„r man trycker p† memmenyn
	move.l	#huvudlospos,losapositioner
	move.l	#huvudlosrutiner,losarutiner
	move.l	bildminne,a0
	lea	(18*168+104)+8(a0),a1		; a1 till bilden
	move.l	a1,a3
	add.l	#95992+2128,a0 		; a0 till infoformen
	lea	4(a0),a2		; Spar bakgrunden
	bsr	ritautenlitenform
	rts




ritaen4knappjamnad:
	moveq	#12-1,d7		; Ritar en av play,pattern,edit eller stop-knappen
rita4knappennu:
	move.l	(a2),(a3)
	move.l	8(a2),8(a3)
	move.l	16(a2),16(a3)
	move.b	24(a2),24(a3)
	move.b	26(a2),26(a3)
	lea	168(a3),a3
	lea	32(a2),a2
	dbra	d7,rita4knappennu
	rts

ritaen4knappojamnad:
	moveq	#12-1,d7		; Ritar en av play,pattern,edit eller stop-knappen
rita4knappennu2:
	move.b	(a2),1(a3)
	move.b	2(a2),3(a3)
	move.b	1(a2),8(a3)
	move.b	3(a2),10(a3)
	move.b	8(a2),9(a3)
	move.b	10(a2),11(a3)
	move.b	9(a2),16(a3)
	move.b	11(a2),18(a3)
	move.b	16(a2),17(a3)
	move.b	18(a2),19(a3)
	move.b	17(a2),24(a3)
	move.b	19(a2),26(a3)
	move.b	24(a2),25(a3)
	move.b	26(a2),27(a3)
	lea	168(a3),a3
	lea	32(a2),a2
	dbra	d7,rita4knappennu2
	rts

playknapp:
	tst.w	edit
	bne.s	ieditmod2
	move.w	#$05F,thelinecolor
	lea	playcolor,a0
	move.w	#$8248,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
ieditmod2:
	move.w	#50,tidsr„knare
	move.w	#$0999,extratime
	clr.w	h”gtimebit
	clr.w	currenttime
	move.w	#1,playplay
	clr.w	pattpos
	clr.w	lastpos
	move.w	#$ff,counter
	clr.b	mkey
	clr.w	patternplay
	move.l	bildminne,a0
	lea	(59*168+8)+8(a0),a1		; a1 till bilden
	add.l	#((266*168)+(2*7*8*39)),a0	; a0 till 1:a playknappen
	lea	(4*384)(a0),a2		; a2 till nersjunken knapp
	move.l	a1,a3			; a3 till playposition
	bsr	ritaen4knappjamnad
	lea	(1*384)(a0),a2		; a2 till vanlig knapp
	lea	24(a1),a3		; a3 till patternposition
	bsr	ritaen4knappojamnad
	lea	(3*384)(a0),a2		; a2 till vanlig knapp
	lea	80(a1),a3		; a3 till stoposition
	bsr	ritaen4knappojamnad
	move.l	bildminne,a2		; a2 till ners„nkt knapp
	add.l	#69704+2128,a2
	lea	112(a1),a3		; a3 till stoposition
	bsr	ritaen4knappjamnad
	clr.w	monitor
	rts

patternknapp:
	tst.w	edit
	bne.s	ieditmod1
	move.w	#$0F5,thelinecolor
	lea	patterncolor,a0
	move.w	#$8248,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
ieditmod1:
	move.w	#50,tidsr„knare
	move.w	#$0999,extratime
	clr.w	h”gtimebit
	clr.w	currenttime
	move.w	#1,patternplay
	clr.w	playplay
	clr.w	pattpos
	clr.w	lastpos
	clr.b	mkey
	move.w	#$ff,counter
	move.l	bildminne,a0
	lea	(59*168+8)+8(a0),a1		; a1 till bilden
	add.l	#((266*168)+(2*7*8*39)),a0	; a0 till 1:a playknappen
	lea	(a0),a2 		; a2 till vanlig knapp
	move.l	a1,a3			; a3 till playposition
	bsr	ritaen4knappjamnad
	lea	(5*384)(a0),a2		; a2 till ners„nkt knapp
	lea	24(a1),a3		; a3 till patternposition
	bsr	ritaen4knappojamnad
	lea	(3*384)(a0),a2		; a2 till vanlig knapp
	lea	80(a1),a3		; a3 till stoposition
	bsr	ritaen4knappojamnad
	move.l	bildminne,a2		; a2 till ners„nkt knapp
	add.l	#69704+2128,a2
	lea	112(a1),a3		; a3 till stoposition
	bsr	ritaen4knappjamnad
	clr.w	monitor
	rts

editknapp:
	tst.w	edit
	bne.s	sl„ppuppediten
sl†p†editendirekt„nd†:
	jsr	copytoundobuffer
	move.w	#$50F,thelinecolor
	lea	editcolor,a0
	move.w	#$8248,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.w	#1,edit
	move.l	bildminne,a0
	lea	(59*168+8)+8(a0),a1		; a1 till bilden
	add.l	#((266*168)+(2*7*8*39)),a0	; a0 till 1:a playknappen
	lea	(6*384)(a0),a2		; a2 till ners„nkt knapp
	lea	56(a1),a3		; a3 till editposition
	bsr	ritaen4knappjamnad
	lea	(3*384)(a0),a2		; a2 till vanligt knapp
	lea	80(a1),a3		; a3 till stoposition
	bsr	ritaen4knappojamnad
	move.l	bildminne,a2		; a2 till ners„nkt knapp
	add.l	#69704+2128,a2
	lea	112(a1),a3		; a3 till stoposition
	bsr	ritaen4knappjamnad
	clr.w	monitor
	rts

sl„ppuppediten:
	move.w	#$F05,thelinecolor
	clr.w	edit
	move.l	bildminne,a0
	lea	(59*168+8)+8(a0),a1		; a1 till bilden
	add.l	#((266*168)+(2*7*8*39)),a0	; a0 till 1:a playknappen
	lea	(2*384)(a0),a2		; a2 till ners„nkt knapp
	lea	56(a1),a3		; a3 till editposition
	bsr	ritaen4knappjamnad
	tst.l	playplay
	bne.s	beh”verintes„nkanerstop
	move.l	bildminne,a0
	lea	(59*168+8)+8(a0),a1		; a1 till bilden
	add.l	#((266*168)+(2*7*8*39)),a0	; a0 till 1:a playknappen
	lea	(7*384)(a0),a2		; a2 till ners„nkt knapp
	lea	80(a1),a3		; a3 till stoposition
	bsr	ritaen4knappojamnad
	lea	stopcolor,a0
	move.w	#$8248,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	rts
beh”verintes„nkanerstop:
	tst.w	playplay
	beq.s	det„renpatternf„rgsomskalltill
	lea	playcolor,a0
	move.w	#$8248,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	rts
det„renpatternf„rgsomskalltill:
	lea	patterncolor,a0
	move.w	#$8248,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	rts

monitorknapp:
	bsr	snabbstopp
	jsr	copytoundobuffer
	lea	editcolor,a0
	move.w	#$50F,thelinecolor
	move.w	#$8248,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.w	#1,monitor
	move.l	bildminne,a0
	move.l	a0,a2
	lea	(59*168+8)+8(a0),a1		; a1 till bilden
	add.l	#((266*168)+(2*7*8*39)),a0	; a0 till 1:a playknappen
	add.l	#69704+384+2128,a2		; a2 till ners„nkt knapp
	lea	112(a1),a3		; a3 till monitorposition
	bsr	ritaen4knappjamnad
	lea	(3*384)(a0),a2		; a2 till vanligt knapp
	lea	80(a1),a3		; a3 till stoposition
	bsr	ritaen4knappojamnad
	rts

stopknapp:
	tst.l	playplay
	bne.s	stoppagenastutanclrhome
	tst.l	edit
	bne.s	stoppagenastutanclrhome
	jsr	clrhome
stoppagenastutanclrhome:
	lea	stopcolor,a0
	move.w	#$8248,a1
	tst.w	(a1)
	beq.s	struntaidettaNU
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
struntaidettaNU:
	move.w	#$F05,thelinecolor
	move.l	bildminne,a0
	lea	(59*168+8)+8(a0),a1		; a1 till bilden
	add.l	#((266*168)+(2*7*8*39)),a0	; a0 till 1:a playknappen
	lea	(7*384)(a0),a2		; a2 till ners„nkt knapp
	lea	80(a1),a3		; a3 till stoposition
	bsr	ritaen4knappojamnad
	move.l	bildminne,a2
	add.l	#69704+2128,a2
	lea	112(a1),a3		; a3 till monitor
	bsr	ritaen4knappjamnad
	clr.w	loopingpartofpatt
snabbstopp:
	move.w	#-1,extratime
	move.l	bildminne,a0
	lea	(59*168+8)+8(a0),a1		; a1 till bilden
	add.l	#((266*168)+(2*7*8*39)),a0	; a0 till 1:a playknappen
	clr.l	edit
	clr.l	playplay
	lea	(a0),a2 		; a2 till vanlig knapp
	move.l	a1,a3			; a3 till playposition
	bsr	ritaen4knappjamnad
	lea	(1*384)(a0),a2		; a2 till vanlig knapp
	lea	24(a1),a3		; a3 till patternposition
	bsr	ritaen4knappojamnad
	lea	(2*384)(a0),a2		; a2 till vanlig knapp
	lea	56(a1),a3		; a3 till editposition
	bsr	ritaen4knappjamnad
refreshtheplayerpointers:
        lea     wiz1lc,a0
        moveq   #8-1,d0
resetwiz:				; Sluta spela instrument
        move.l	#dummy,(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	move.l	#$454,(a0)+
        move.w	#$651c,(a0)+
        dbra    d0,resetwiz
        lea     aud1lc,a0
        moveq   #8-1,d0
resetaud:
        move.l  #dummy,(a0)+
	move.w	#$320,(a0)+
	move.w	#$358,(a0)+
	move.w	#$0,(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
        dbra    d0,resetaud
        lea     voice1,a0
        moveq   #8-1,d0
resetvoice:
	clr.l	(a0)+
	move.l	#dummy,(a0)+
	move.w	#$320,(a0)+
	move.l	dummy,(a0)+
	move.w	#$1f4,(a0)+
	move.w	#$358,(a0)+
	move.w	#$0,(a0)+
	addq.l	#2,a0
	clr.w	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	move.l	#$1f4,(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	move.l	#$FFFFFF,(a0)+
	clr.l	(a0)+
	dbra	d0,resetvoice
	lea	VU1,a0
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.w	mt_PattDelTime2
	clr.w	g”rDMAtigen

	tst.w	termodyonoff
	beq.s	interesettatermdyneftersomdeninte„rp†
	move.l	currenttermody,a0
	move.l	(a0),a0
	lea	12(a0),a0
	moveq	#8-1,d0
resettermodyn:
	clr.l	(a0)		; Frekvensen f”r kanalen
	move.l	#dummy,16*4(a0)	; Samplingspekare
	move.l	#1800,2*16*4(a0); Loopstart
	clr.l	3*16*4(a0)	; Loopl„ngd
	clr.l	4*16*4(a0)	; Volym
	addq.w	#4,a0
	dbra	d0,resettermodyn
interesettatermdyneftersomdeninte„rp†:
	move.w	lastpos,pattpos
	move.w	lastsongpatt,whichpatt
	rts


;==================================================== Interupthanterare ==

mt_PeriodTable:
; Tuning 0, Normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114

termoplay:
	tst.w	lownoise
	beq.s	s„„ttttttttintevolymen34534
	move.w	oldtreble,d4
	sub.w	#28,d4
	lea	treble,a0		; S„tt diskant
	add.w	d4,d4
	move.w	#$07ff,$ffff8924.w
	move.w	(a0,d4.w),$ffff8922.w
s„„ttttttttintevolymen34534:

	bsr.s	l†tUMPenskapamusiknu

	moveq	#0,d0
	cmp.l	#$00080008,mainwantzero+10
	bne.s	inteenvolyms„nkning2
	cmp.l	#$00080008,mainwantzero+6
	bne.s	inteenvolyms„nkning2
	cmp.l	#$00080008,mainwantzero+2
	bne.s	inteenvolyms„nkning2
	moveq	#1,d0
inteenvolyms„nkning2:
	tst.w	d0
	beq.s	s„ttvolymentillnormalmain2
	move.w	#%10011000000,d4
	move.w	d0,mainisnotzero	; S„nk volymen till 0
	bra.s	allt„rsomdetskallimainen2
s„ttvolymentillnormalmain2:
	move.w	oldmain,d4
	sub.w	#28,d4
	lea	main,a0			; S„tt volymen normalt
	add.w	d4,d4
	move.w	(a0,d4.w),d4
	move.w	d0,mainisnotzero
allt„rsomdetskallimainen2:
	tst.w	lownoise
	beq.s	s„„ttttttttintevolymen2
	move.w	#$07ff,$ffff8924.w
	move.w	d4,$ffff8922.w
s„„ttttttttintevolymen2:
	rts
l†tUMPenskapamusiknu:
	tst.w	usetempo	; Skall vi mata UMPen med tempo eller ej?
	bne	donotusetempocontrolonUMP
						; K”r tempo
	cmp.l	#12500,tempor„knare
	bgt.s	k”rbaraskapandedennaframe2
	tst.l	tempor„knare
	beq.s	inteenlitenrestsenf”rraframen2
	move.l	tempor„knare,d0
	cmp.l	#12500,d0
	ble.s	detgickmindre„nenframe2
k”rbaraskapandedennaframe2:
	move.l	currenttermody,a5
	move.l	(a5),a5
	move.w	#125,356(a5)
	bsr	skapaUMPdatamedtempokontroll
	bra	tempoteratklart2
detgickmindre„nenframe2:
	add.w	#50,d0
	divu	#100,d0
	move.l	currenttermody,a5
	move.l	(a5),a5
	move.w	d0,356(a5)
	tst.w	d0
	beq.s	inteenlitenrestsenf”rraframen2
	bsr	skapaUMPdatamedtempokontroll
inteenlitenrestsenf”rraframen2:
	move.l	tempor„knare,d0
	cmp.l	#12500,d0
	bgt.s	tempoteratklart2
	move.l	d0,d2
	add.l	tempoadder,d0
	move.l	d0,tempor„knare		; R„kna fram r„knaren
	move.l	#12500,d1
	sub.l	d2,d1
	cmp.l	tempoadder,d1
	ble.s	r„knaframenhalvmesyrinnanvislutar2
	jsr	music			; K”r lite musik
	move.l	tempoadder,d0		; Skapa en del
	add.w	#50,d0
	divu	#100,d0
	move.l	currenttermody,a5
	move.l	(a5),a5
	move.w	d0,356(a5)
	tst.w	d0
	beq.s	inteenlitenrestsenf”rraframen2
	bsr.s	skapaUMPdatamedtempokontroll
	bra.s	inteenlitenrestsenf”rraframen2
r„knaframenhalvmesyrinnanvislutar2:	; Skapa det sista innan vi slutar
	tst.l	d1
	bpl.s	intesetillattdetblirpositivt2
	add.l	tempoadder,d1
intesetillattdetblirpositivt2:
	move.l	d1,-(sp)
	jsr	music			; K”r lite musik
	move.l	(sp)+,d1
	divu	#100,d1
	move.l	currenttermody,a5
	move.l	(a5),a5
	move.w	d1,356(a5)
	tst.w	d1
	beq.s	inteenlitenrestsenf”rraframen2
	bsr.s	skapaUMPdatamedtempokontroll
	bra.s	inteenlitenrestsenf”rraframen2
tempoteratklart2:
	sub.l	#12500,tempor„knare
	rts			; Temporerat klart f”r denna VBL...

donotusetempocontrolonUMP:	; K”r direkt utan tempo!
	move.l	currenttermody,a5
	move.l	(a5),a5
skapaUMPdatamedtempokontroll:
	lea	AmigafrekvenstoTermodynfrekvens,a6

	move.w	aud1per,d1
	add.w	d1,d1
	moveq	#0,d2
	move.w	0(a6,d1.w),d2
	move.l	d2,0+12(a5)		; Frekvensen f”r kanal 1
	moveq	#0,d1
	tst.w	chanel1onoff
	bpl.s	kan1av
	tst.l	(0+12+(3*16*4))(a5)
	bne.s	loopp†1
	move.l	(0+12+(2*16*4))(a5),d0
	cmp.l	(0+12+(16*4))(a5),d0
	ble.s	kan1av
loopp†1:move.w	aud1vol,d1
	bne.s	fullv1
kan1av:	addq.w	#1,mainwantzero
fullv1:	lsl.w	#8,d1
	move.l	d1,(0+12+(4*16*4))(a5)	; Volym

	move.w	aud2per,d1
	add.w	d1,d1
	moveq	#0,d2
	move.w	0(a6,d1.w),d2
	move.l	d2,12+12(a5)		; Frekvensen f”r kanal 2
	moveq	#0,d1
	tst.w	chanel2onoff
	bpl.s	kan2av
	tst.l	(12+12+(3*16*4))(a5)
	bne.s	loopp†2
	move.l	(12+12+(2*16*4))(a5),d0
	cmp.l	(12+12+(16*4))(a5),d0
	ble.s	kan2av
loopp†2:move.w	aud2vol,d1
	bne.s	fullv2
kan2av:	addq.w	#1,mainwantzero
fullv2:	lsl.w	#8,d1
	move.l	d1,(12+12+(4*16*4))(a5)	; Volym

	move.w	aud3per,d1
	add.w	d1,d1
	moveq	#0,d2
	move.w	0(a6,d1.w),d2
	move.l	d2,4+12(a5)		; Frekvensen f”r kanal 3
	moveq	#0,d1
	tst.w	chanel3onoff
	bpl.s	kan3av
	tst.l	(4+12+(3*16*4))(a5)
	bne.s	loopp†3
	move.l	(4+12+(2*16*4))(a5),d0
	cmp.l	(4+12+(16*4))(a5),d0
	ble.s	kan3av
loopp†3:move.w	aud3vol,d1
	bne.s	fullv3
kan3av:	addq.w	#1,mainwantzero
fullv3:	lsl.w	#8,d1
	move.l	d1,(4+12+(4*16*4))(a5)	; Volym

	move.w	aud4per,d1
	add.w	d1,d1
	moveq	#0,d2
	move.w	0(a6,d1.w),d2
	move.l	d2,8+12(a5)		; Frekvensen f”r kanal 4
	moveq	#0,d1
	tst.w	chanel4onoff
	bpl.s	kan4av
	tst.l	(8+12+(3*16*4))(a5)
	bne.s	loopp†4
	move.l	(8+12+(2*16*4))(a5),d0
	cmp.l	(8+12+(16*4))(a5),d0
	ble.s	kan4av
loopp†4:move.w	aud4vol,d1
	bne.s	fullv4
kan4av:	addq.w	#1,mainwantzero
fullv4:	lsl.w	#8,d1
	move.l	d1,(8+12+(4*16*4))(a5)	; Volym

	move.w	aud5per,d1
	add.w	d1,d1
	moveq	#0,d2
	move.w	0(a6,d1.w),d2
	move.l	d2,16+0+12(a5)		; Frekvensen f”r kanal 5
	moveq	#0,d1
	tst.w	chanel5onoff
	bpl.s	kan5av
	tst.l	(16+0+12+(3*16*4))(a5)
	bne.s	loopp†5
	move.l	(16+0+12+(2*16*4))(a5),d0
	cmp.l	(16+0+12+(16*4))(a5),d0
	ble.s	kan5av
loopp†5:move.w	aud5vol,d1
	bne.s	fullv5
kan5av:	addq.w	#1,mainwantzero
fullv5:	lsl.w	#8,d1
	move.l	d1,(16+0+12+(4*16*4))(a5)	; Volym

	move.w	aud6per,d1
	add.w	d1,d1
	moveq	#0,d2
	move.w	0(a6,d1.w),d2
	move.l	d2,16+12+12(a5)		; Frekvensen f”r kanal 6
	moveq	#0,d1
	tst.w	chanel6onoff
	bpl.s	kan6av
	tst.l	(16+12+12+(3*16*4))(a5)
	bne.s	loopp†6
	move.l	(16+12+12+(2*16*4))(a5),d0
	cmp.l	(16+12+12+(16*4))(a5),d0
	ble.s	kan6av
loopp†6:move.w	aud6vol,d1
	bne.s	fullv6
kan6av:	addq.w	#1,mainwantzero
fullv6:	lsl.w	#8,d1
	move.l	d1,(16+12+12+(4*16*4))(a5)	; Volym

	move.w	aud7per,d1
	add.w	d1,d1
	moveq	#0,d2
	move.w	0(a6,d1.w),d2
	move.l	d2,16+4+12(a5)		; Frekvensen f”r kanal 7
	moveq	#0,d1
	tst.w	chanel7onoff
	bpl.s	kan7av
	tst.l	(16+4+12+(3*16*4))(a5)
	bne.s	loopp†7
	move.l	(16+4+12+(2*16*4))(a5),d0
	cmp.l	(16+4+12+(16*4))(a5),d0
	ble.s	kan7av
loopp†7:move.w	aud7vol,d1
	bne.s	fullv7
kan7av:	addq.w	#1,mainwantzero
fullv7:	lsl.w	#8,d1
	move.l	d1,(16+4+12+(4*16*4))(a5)	; Volym

	move.w	aud8per,d1
	add.w	d1,d1
	moveq	#0,d2
	move.w	0(a6,d1.w),d2
	move.l	d2,16+8+12(a5)		; Frekvensen f”r kanal 8
	moveq	#0,d1
	tst.w	chanel8onoff
	bpl.s	kan8av
	tst.l	(16+8+12+(3*16*4))(a5)
	bne.s	loopp†8
	move.l	(16+8+12+(2*16*4))(a5),d0
	cmp.l	(16+8+12+(16*4))(a5),d0
	ble.s	kan8av
loopp†8:move.w	aud8vol,d1
	bne.s	fullv8
kan8av:	addq.w	#1,mainwantzero
fullv8:	lsl.w	#8,d1
	move.l	d1,(16+8+12+(4*16*4))(a5)	; Volym



	jsr	(a5)			; Utf”r rutinen

	move.l	mainwantzero+6,mainwantzero+10
	move.l	mainwantzero+4,mainwantzero+6
	move.l	mainwantzero,mainwantzero+2
	clr.w	mainwantzero

	rts


; H„r finns det ett mycket enkelt s„tt att f”r interupter eller andra
; program att kolla om Octalysern „r ig†ng, samt vilken version det
; „r. Om antalet systemvbls „r 1 s† skall man kolla p† den f”rsta
; adressen dit systemet pekar p† tabellistan. Denna adress -30 ger
; pekaren till ver1:  (ver1 = 15 bytes, ver2 = 15  bytes)....

magiccolor:
	dc.w	0
ver1:
	dc.b	'OCTALYSER - RB',0
ver2:
	dc.b	' DATE 940731. ',0

vbl:	movem.l d0-d7/a0-a6,-(sp)

	clr.b	$fffffa1b.w
	tst.w	lowershower
	bpl.s	taendastbortl†gbordern
	move.b	#104,$fffffa21.w		; V„nta halva sk„rmen
	move.b	#8,$fffffa1b.w
	move.l	#splitter,$120.w		; HBL
	tst.l	editorpek
	beq.s	splittscreen
	move.l	oldeditorpek,d0
	add.l	#16,d0
	and.l	#$FFFFFFF0,d0
	move.l	d0,editorpek
	bra.s	splittscreen
taendastbortl†gbordern:
	move.b	linestowait,d0
	tst.w	hblisallreadyused
	beq.s	usehbl
	move.b	#255,d0
usehbl:
	move.b	d0,$fffffa21.w		; V„nta in nedre ramen
	move.b	#8,$fffffa1b.w
	move.l	hbler,$120.w		; HBL
splittscreen:

	tst.l	fulleditorpek
	bne.s	noSTEborder

	clr.b	$ffff8260.w		; L†g uppl”sning
	move.w	screenpalette+2,$ffff8242.w

	tst.w	falkrun
	beq.s	falk_split
	move.w	#1,$ffff8264.w		; Fixa till 16 extra pixels
	clr.b	$ffff8264.w		; i v„nsterbordern
	bra.s	noSTEborder
falk_split
	tst.w	VGArun
	beq.s	.falkborderVGA

.falkborderRGB
	move.w	falk_oldHDE,d0
	addq.w	#8,d0
	move.w	d0,$ffff828a.w	
	move.w	#$28,$ffff8284.w
	move.w	#$24f,$ffff82aa.w
	move.w	#$54,$ffff8210.w
	bra.s	noSTEborder
.falkborderVGA
	move.w	#12,$ffff8264.w

noSTEborder:


	tst.w	runwithtimerA
	bne.s	struntidetta
	tst.w	vblisstillworking
	bne	arbetarhoppaoverdenna
	move.w	#1,vblisstillworking
	move.w	#$2300,sr

	tst.w	extratime
	bmi.s	tidenskallejadderas
	subq.w	#1,tidsr„knare
	bgt.s	tidenskallejadderas
	move.w	#50,tidsr„knare
	addq.w	#1,currenttime
	cmp.w	#60,currenttime
	blt.s	tidenskallejadderas
	clr.w	currenttime
	addq.w	#1,h”gtimebit
tidenskallejadderas:
struntidetta:
	move.w	#$2300,sr

	move.l	bildminne,d0
	move.l	d0,d1
	add.l	#242*168,d1
	move.l	removeer,d2
	cmp.l	d2,d0
	bgt	vivetintevadvig”r
	cmp.l	d2,d1
	blt	vivetintevadvig”r

				; Ta bort musen
	tst.l	fulleditorpek
	beq	tabortdenvanligamusen
remove640mouse:
	move.l	oldfulleditormouse,a0
	moveq	#0,d0
	move.w	d0,(a0)
	move.w	d0,4(a0)
	move.w	d0,8(a0)
	move.w	d0,160(a0)
	move.w	d0,160+4(a0)
	move.w	d0,160+8(a0)
	move.w	d0,2*160(a0)
	move.w	d0,2*160+4(a0)
	move.w	d0,2*160+8(a0)
	move.w	d0,3*160(a0)
	move.w	d0,3*160+4(a0)
	move.w	d0,3*160+8(a0)
	move.w	d0,4*160(a0)
	move.w	d0,4*160+4(a0)
	move.w	d0,4*160+8(a0)
	move.w	d0,5*160(a0)
	move.w	d0,5*160+4(a0)
	move.w	d0,5*160+8(a0)
	move.w	d0,6*160(a0)
	move.w	d0,6*160+4(a0)
	move.w	d0,6*160+8(a0)
	move.w	d0,7*160(a0)
	move.w	d0,7*160+4(a0)
	move.w	d0,7*160+8(a0)
	move.w	d0,8*160(a0)
	move.w	d0,8*160+4(a0)
	move.w	d0,8*160+8(a0)
	move.w	d0,9*160(a0)
	move.w	d0,9*160+4(a0)
	move.w	d0,9*160+8(a0)
	move.w	d0,10*160(a0)
	move.w	d0,10*160+4(a0)
	move.w	d0,10*160+8(a0)
	move.w	d0,11*160(a0)
	move.w	d0,11*160+4(a0)
	move.w	d0,11*160+8(a0)
	move.w	d0,12*160(a0)
	move.w	d0,12*160+4(a0)
	move.w	d0,12*160+8(a0)
	move.w	d0,13*160(a0)
	move.w	d0,13*160+4(a0)
	move.w	d0,13*160+8(a0)
	move.w	d0,14*160(a0)
	move.w	d0,14*160+4(a0)
	move.w	d0,14*160+8(a0)
	move.w	d0,15*160(a0)
	move.w	d0,15*160+4(a0)
	move.w	d0,15*160+8(a0)
	bra	intetabortdenvanligamusen
tabortdenvanligamusen:
	move.l	removeer,a0
	moveq	#0,d0
	move.l	d0,(a0)
	move.l	d0,8(a0)
	move.l	d0,168(a0)
	move.l	d0,168+8(a0)
	move.l	d0,168*2(a0)
	move.l	d0,168*2+8(a0)
	move.l	d0,168*3(a0)
	move.l	d0,168*3+8(a0)
	move.l	d0,168*4(a0)
	move.l	d0,168*4+8(a0)
	move.l	d0,168*5(a0)
	move.l	d0,168*5+8(a0)
	move.l	d0,168*6(a0)
	move.l	d0,168*6+8(a0)
	move.l	d0,168*7(a0)
	move.l	d0,168*7+8(a0)
	move.l	d0,168*8(a0)
	move.l	d0,168*8+8(a0)
	move.l	d0,168*9(a0)
	move.l	d0,168*9+8(a0)
	move.l	d0,168*10(a0)
	move.l	d0,168*10+8(a0)
	move.l	d0,168*11(a0)
	move.l	d0,168*11+8(a0)
	move.l	d0,168*12(a0)
	move.l	d0,168*12+8(a0)
	move.l	d0,168*13(a0)
	move.l	d0,168*13+8(a0)
	move.l	d0,168*14(a0)
	move.l	d0,168*14+8(a0)
	move.l	d0,168*15(a0)
	move.l	d0,168*15+8(a0)
	tst.l	editorpek
	bne	remove640mouse
intetabortdenvanligamusen:

;	move.w	#$FFFF,$ffff8a28.w		; Ingen startmask
;	move.w	#$FFFF,$ffff8a2c.w		; Ingen slutmask						; F”rsta bitplanet
;	clr.b	$ffff8a3d.w			; Ingen SKEW, NFSR o FXSR
;	move.b	#3,$ffff8a3b.w			; Writing mode
;	clr.w	$ffff8a20.w			; Sorce add x (bytes)
;	clr.w	$ffff8a22.w			; Sorce add y (bytes)
;	move.w	#8,$ffff8a2e.w			; Dest add x (bytes)
;	move.l	#tomtminne,$ffff8a24.w		; Sorce adress
;	moveq	#16,d1				; En 16*16 figur att ta bort
;	move.w	#2,$ffff8a36.w			; X length (words)
;	move.w	#160,$ffff8a30.w		; Dest add y (bytes)
;tabortdennu:
;	move.w	d1,$ffff8a38.w			; Y length (lines)
;	move.l	removeer(pc),$ffff8a32.w	; Dest adress
;						; Ta bort f”rsta bitplanet
;	move.b	#$80+$40,$ffff8a3c.w		; Start blitter
;						; Andra bitplanet
;	bsr	v„ntap†blittret
;	move.l	removeer(pc),$ffff8a32.w	; Dest adress
;	addq.l	#2,$ffff8a32.w
;	move.w	d1,$ffff8a38.w			; Y length (lines)
;	move.b	#$80+$40,$ffff8a3c.w		; Start blitter
;	bsr	v„ntap†blittret
vivetintevadvig”r:
;	move.w	#$F,$ffff8240.w


	tst.w	cursoronoff		; Skall vi visa en textcursor?
	beq.s	intevisaencursor

	subq.w	#1,cursorblink
	bpl.s	inteblinkamedcursorn	; Dax att blinka med cursorn?
	move.w	#20,cursorblink

	move.w	editx,d0
	move.w	edity,d1
	move.w	cursor,d2
	lsl.w	#3,d2
	add.w	d2,d0
	move.l	bildminne,a3
	mulu	#168,d1 	; R„kna ut var i bildminnet som den
	add.l	d1,a3		; skall skriva
	move.w	d0,d1
	and.w	#%1111111111110000,d0
	lsr.w	#1,d0
	add.w	d0,a3
	and.l	#$8,d1
	beq.s	inteextrabyteicursorn
	addq.w	#1,a3
inteextrabyteicursorn:
	move.l	a3,oldcursor
	not.b	(a3)		; Skriv ut cursorn
	not.b	168(a3)
	not.b	336(a3)
	not.b	504(a3)
	not.b	672(a3)
	not.b	840(a3)
inteblinkamedcursorn:
intevisaencursor:

	tst.l	editorpek
	bne.s	skrivutstr„cket
	tst.l	fulleditorpek
	beq.s	intesuddauteftersomingenfulleditor
skrivutstr„cket:
	moveq	#0,d1			; Ta bort fulleditorns str„ck
	move.l	oldfulleditorcursor,a2	; och cursor
	move.l	oldfulleditorline,a3
	tst.l	oldfulleditorline
	beq.s	intesuddauteftersomingenfulleditor	; sefjtfijsfj
	moveq	#4-1,d4
ppppp:	move.b	d1,1(a3)
	move.w	d1,4(a3)
	move.w	d1,8(a3)
	move.b	d1,12(a3)
	move.b	d1,960+1(a3)
	move.w	d1,960+4(a3)
	move.w	d1,960+8(a3)
	move.b	d1,960+12(a3)
	move.w	d1,20(a3)
	move.w	d1,24(a3)
	move.w	d1,28(a3)
	move.w	d1,960+20(a3)
	move.w	d1,960+24(a3)
	move.w	d1,960+28(a3)
	lea	36(a3),a3
	dbra	d4,ppppp
sefjtfijsfj:
	move.b	d1,(a2)
	move.b	d1,160(a2)
	move.b	d1,320(a2)
	move.b	d1,480(a2)
	move.b	d1,640(a2)
	move.b	d1,800(a2)
	move.b	d1,960(a2)
intesuddauteftersomingenfulleditor:

	move.l	bildminne,d3
	addq.l	#4,d3
	move.w	x,d0
	move.w	y,d1
	lea	musform,a1
	moveq	#16,d7				; Rita ut musen
	bsr	drawsprite2plane1616

	tst.w	donotdoanymusicorsomeshit
	bne	hoppaoverdetmesta
	cmp.b	#255,linestowait
	beq	hoppaoverdetmesta

	tst.l	fulleditorpek
	bne	skitiattritap†slidern
	move.l	oldsliderpek,a0		; Sudda ut den gamla slidern
	move.w	oldsliderlength,d0
	bmi.s	intetabortsliderneftersomdenintefinns
	moveq	#0,d1
tabortdengamlaslidern:
	move.w	d1,(a0)
	lea	168(a0),a0
	dbra	d0,tabortdengamlaslidern
intetabortsliderneftersomdenintefinns:

	tst.w	lastpos
	bmi	skitiattritap†slidern
	cmp.w	#$800,lastpos		; Se till att inte slidern
	bge	skitiattritap†slidern	; dummar sig alltf”r mycket
	move.w	#%0011111111111000,d4
	move.l	bildminne,a0
	lea	168*106+2(a0),a0
	moveq	#0,d0			; Rita ut den nya slidern
	move.w	lastpos,d0
	lsr.w	#5,d0
	move.w	d0,d3
	move.w	patternupdate,d1
	addq.w	#1,d1
	add.w	d1,d1
	lea	patternupdatetabell,a1
	move.w	(a1,d1.w),d1		; d1 sliderns upp-l„ngd
	move.w	d1,d2			; d2 sliderns ner-l„ngd
	cmp.w	d1,d0
	bgt.s	slidernsuppl„ngdmindre
	move.w	d0,d1
slidernsuppl„ngdmindre:
	add.w	d1,d1
	add.w	d3,d3
	sub.w	d1,d3
	mulu	#168,d3
	add.w	d3,a0
	move.l	a0,oldsliderpek
	move.w	d1,d5
	subq.w	#1,d1
	bmi.s	ingen”versliderattritaut
skrivut”vreslidern:			; Skriv ut ”vre slidern
	move.w	d4,(a0)
	lea	168(a0),a0
	dbra	d1,skrivut”vreslidern
ingen”versliderattritaut:
	move.w	d4,(a0)			; Skriv ut centrumet f”r slidern
	lea	168(a0),a0
	move.w	d4,(a0)
	lea	168(a0),a0
	neg.w	d0
	add.w	#63,d0
	cmp.w	d2,d0
	bgt.s	slidernsnerl„ngdmindre
	move.w	d0,d2
slidernsnerl„ngdmindre:
	add.w	d2,d2
	move.w	d2,d6
	subq.w	#1,d2
	bmi.s	ingennedersliderattritaut
skrivutnederslidern:			; Skriv ut nedre slidern
	move.w	d4,(a0)
	lea	168(a0),a0
	dbra	d2,skrivutnederslidern
ingennedersliderattritaut:
	add.w	d5,d6
	addq.w	#1,d6
	move.w	d6,oldsliderlength
skitiattritap†slidern:

	jsr	drawVUmeters

	tst.l	fulleditorpek
	bne.s	visafulleditorn
	tst.l	editorpek
	beq	testaomviskallritavidare
	bra.s	skrivutstr„cket3
visafulleditorn:
	move.w	thelinecolor,$ffff8244.w

	moveq	#0,d1
	move.w	lastpos,d0
	lsr.w	#5,d0			; Om fullsk„rmseditorn „r ig†ng
	add.w	d0,d0			; se till att r„tt del av
	lea	hurmycketaddera,a0	; sk„rmen visas
	move.w	(a0,d0.w),d1
	move.l	fulleditorpek,a0
	add.l	d1,a0
	move.l	a0,extrabraattha

	move.b	extrabraattha+1,$ffff8205.w
	move.b	extrabraattha+2,$ffff8207.w
	move.b	extrabraattha+3,$ffff8209.w
	move.b	extrabraattha+1,$ffff8201.w
	move.b	extrabraattha+2,$ffff8203.w
	move.b	extrabraattha+3,$ffff820d.w
	bra.s	l†ngtvidare
skrivutstr„cket3:
	moveq	#0,d1
	move.w	lastpos,d0
	lsr.w	#5,d0			; Om 8editorn „r ig†ng
	add.w	d0,d0			; se till att r„tt del av
	lea	hurmycketaddera2,a0	; sk„rmen visas
	move.w	(a0,d0.w),d1
	move.l	editorpek,a0
	add.l	d1,a0
	subq.w	#2,a0
	move.l	a0,extrabraattha

l†ngtvidare:
	moveq	#0,d1
	move.l	oldfulleditorcursor,a2
	move.l	oldfulleditorline,a3
	move.w	lastpos,d0
	lsr.w	#5,d0
	add.w	d0,d0
	mulu	#3*160,d0
	add.l	#14,d0
	tst.l	fulleditorpek
	beq.s	laddaupp8editorn6
	add.l	fulleditorpek,d0
	bra.s	klarrrrrrrrrrrt6
laddaupp8editorn6:
	add.l	editorpek,d0
	subq.l	#4,d0
	tst.w	falkrun
	bne.s	klarrrrrrrrrrrt6
	addq.l	#2,d0			; ()()() strecken och cursorn kommer nu r„tt...
klarrrrrrrrrrrt6:
	move.l	d0,oldfulleditorline
	move.l	d0,a3
	move.w	startkanal,d2
	subq.w	#1,d2
	mulu	#6,d2
	add.w	cursorx,d2
	add.w	d2,d2
	lea	specialcursoradd,a1
	move.w	(a1,d2.w),d2
	add.w	d2,d0
	move.l	d0,oldfulleditorcursor
	moveq	#-1,d1
	move.l	d0,a0			; Skriv ut den nya cursorn
	move.b	d1,(a0)
	move.b	d1,160(a0)
	move.b	d1,320(a0)
	move.b	d1,480(a0)
	move.b	d1,640(a0)
	move.b	d1,800(a0)
	move.b	d1,960(a0)
	moveq	#4-1,d4
	lea	chanel1onoff,a0
pppppp:	tst.w	(a0)+
	bpl.s	ejf”rstaparet
	move.b	d1,1(a3)
	move.w	d1,4(a3)
	move.w	d1,8(a3)
	move.b	d1,12(a3)
	move.b	d1,960+1(a3)
	move.w	d1,960+4(a3)
	move.w	d1,960+8(a3)
	move.b	d1,960+12(a3)
ejf”rstaparet:
	tst.w	(a0)+
	bpl.s	ejandraparet
	move.w	d1,20(a3)
	move.w	d1,24(a3)
	move.w	d1,28(a3)
	move.w	d1,960+20(a3)
	move.w	d1,960+24(a3)
	move.w	d1,960+28(a3)
ejandraparet:
	lea	36(a3),a3
	dbra	d4,pppppp
	tst.w	runwithtimerA
	bne.s	dennabittartimerAhandom
	bra.s	intevisapatternet
testaomviskallritavidare:

	tst.w	runwithtimerA
	bne.s	dennabittartimerAhandom

	tst.w	lowershower
	bne.s	intevisapatternet
	tst.w	trashupdate
	bmi.s	intevisapatternet
	jsr	skrivutenhelskarmspattern
intevisapatternet:

	tst.w	donotdoanymusic
	bne.s	redanskapatmusik
	tst.w	termodyonoff
	bne.s	entermodyplayrutinp†
	jsr	playmusic
	bra.s	redanskapatmusik
entermodyplayrutinp†:
	jsr	termoplay	; H„r hoppar vi till TERMODYuppspelaren
redanskapatmusik:

	tst.w	cleartheshorty
	beq.s	interensashortynan
	lea	shortpattern,a0
	clr.l	(a0)+
	clr.l	(a0)+		; Rensa tillf„lligt pattern
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.w	cleartheshorty
interensashortynan:

	tst.w	musicwait	; Dax att v„nta in ljudchippet?
	bne.s	vantainmusikdmat
	tst.w	usetempo	; Om tempo, strunta i att anropa
	beq.s	vantainmusikdmat
	move.w	#$2400,sr
	jsr	music		; S„tt upp speladatan
vantainmusikdmat:
dennabittartimerAhandom:

harspelat:
hoppaoverdetmesta:

	bsr	fixthekeyboard

	tst.w	dontaskaboutthemouse
	bne.s	skitiattfr†gaommusen
	moveq	#0,d1
	moveq	#$d,d0
	move.w	#$fc00,a0
readshit2:				; Fr†ga hur det st†r till
	move.b	(a0),d1			; med musen
	btst	#1,d1
	beq.s	readshit2
skrivditdetdirekt:
	move.b	d0,2(a0)
skitiattfr†gaommusen:

	move.w	xhigh,x		; Ladda upp mus-x
	move.w	yhigh,y		; Ladda upp mus-y
	move.b	mkey,d0		; S„tt knappvalet som det skall
	move.b	button,d1
	btst	#0,d1
	beq.s	rightbuttnopress
	bset	#0,d0
rightbuttnopress:
	btst	#1,d1
	beq.s	rightbuttnorelease
	bclr	#0,d0
rightbuttnorelease:
	btst	#2,d1
	beq.s	leftbuttnopress
	bset	#1,d0
leftbuttnopress:
	btst	#3,d1
	beq.s	leftbuttnorelease
	bclr	#1,d0
leftbuttnorelease:
	move.b	d0,mkey

	clr.w	vblisstillworking
arbetarhoppaoverdenna:

	movem.l (sp)+,d0-d7/a0-a6
	subq.w	#1,sync

;	clr.w	$ffff8240.w

	rts

vj:	jmp	$12345678

donottrytorunviatimerC:
	dc.w	1
doaIPL2now:
	dc.w	0

runaIPL2:				; Denna rutin tar hand om
	tst.w	doaIPL2now		; uppdateringen av musiken d†
	bne.s	k”rh†rtp†medIPL2	; vi k”r den p† en timer
	rte
k”rh†rtp†medIPL2:
	clr.w	doaIPL2now

	tst.w	donotdoanymusicorsomeshit
	bne.s	arbetarhoppaoverdenna2

	tst.w	donotdoanymusic
	bne.s	arbetarhoppaoverdenna2

	tst.w	Aisstillworking
	bne.s	arbetarhoppaoverdenna2
	move.w	#1,Aisstillworking

	movem.l	d0-d7/a0-a6,-(sp)

	tst.w	donotdoanymusic
	bne.s	redanskapatmusik2
	tst.w	termodyonoff
	bne.s	entermodyplayrutinp†2
	jsr	playmusic
	bra.s	redanskapatmusik2
entermodyplayrutinp†2:
	jsr	termoplay	; H„r hoppar vi till TERMODYuppspelaren
redanskapatmusik2:

	tst.w	cleartheshorty
	beq.s	interensashortynan2
	lea	shortpattern,a0
	clr.l	(a0)+
	clr.l	(a0)+		; Rensa tillf„lligt pattern
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.w	cleartheshorty
interensashortynan2:

	tst.w	musicwait	; Dax att v„nta in ljudchippet?
	bne.s	vantainmusikdmat2
	tst.w	usetempo	; Om tempo, strunta i att anropa
	beq.s	vantainmusikdmat2
	jsr	music		; S„tt upp speladatan
vantainmusikdmat2:

	movem.l	(sp)+,d0-d7/a0-a6

	clr.w	Aisstillworking
arbetarhoppaoverdenna2:
	tst.w	extratime
	bmi.s	tidenskallejadderas2
	subq.w	#1,tidsr„knare
	bgt.s	tidenskallejadderas2
	move.w	#50,tidsr„knare
	addq.w	#1,currenttime
	cmp.w	#60,currenttime
	blt.s	tidenskallejadderas2
	clr.w	currenttime
	addq.w	#1,h”gtimebit
tidenskallejadderas2:
	rte

Aisstillworking:
	dc.w	0

setupperlinescorrect:
	move.b	#2,$ffff820a.w		; 50 Hz
	clr.b	$fffffa19.w
	move.l	#h”jfrekigen,$134.w
	move.b	#20,$fffffa1f.w
	move.b	#1,$fffffa19.w
	bclr.b	#5,$fffffa0f.w
	rte

h”jfrekigen:
	move.b	#0,$ffff820a.w		; 60 Hz
	clr.b	$fffffa19.w
	bclr.b	#5,$fffffa0f.w
	rte

splitter:
	move.w	#$2700,sr
	movem.l d0/a1/d1,-(sp)
	move.w	#$fa21,a1
	clr.b	$fffffa1b.w		; timer stop
	move.b	linestowait,d0
	sub.b	#104,d0
	move.b	d0,(a1)
	move.b	#8,$fffffa1b.w
	move.b	(a1),d0
	move.w	borderdelay(pc),d1
	clr.w	$ffff8264.w		; Normal v„nsterborder
	tst.w	falkrun
	bne.s	waitforhblreturnsplitter
	
	tst.w	VGArun
	beq.s	waitforhblreturnsplitter
	
	move.w	falk_oldHBB,$ffff8284.w
	move.w	falk_oldHDE,$ffff828a.w
;	move.w	falk_oldVDE,$ffff82aa.w
	move.w	falk_oldVwrap,$ffff8210.w

	move.w	falk_oldVBB,$ffff82a4.w
	move.w	falk_oldVBE,$ffff82a6.w
	move.w	falk_oldVDB,$ffff82a8.w




waitforhblreturnsplitter:		; wait for the end of the last line
	moveq.l	#1,d1
.loop
	cmp.b	(a1),d0
	beq.s	.loop
	move.b	d1,$ffff8260.w
	move.b	extrabraattha+1,$ffff8205.w	; Nytt bildminne
	move.b	extrabraattha+2,$ffff8207.w
	move.b	extrabraattha+3,$ffff8209.w
	move.w	thelinecolor,$ffff8242.w
	move.l	hbler,$120.w		; HBL
	movem.l (sp)+,d0/a1/d1
	bclr	#0,$fffffa0f.w
	tst.w	hblisallreadyused
	bne.s	dontuserestofhbl
	rte
dontuserestofhbl:
	clr.b	$fffffa1b.w		; timer stop
	rte

editorpek:
	dc.l	0

hbl1:					; Ta bort nedre ramen
	move.w	#$2700,sr
	movem.l d0/a1/d1,-(sp)
	move.w	#$fa21,a1
	clr.b	$fffffa1b.w		; timer stop
	move.b	#255,(a1)
	move.b	#8,$fffffa1b.w
	move.b	(a1),d0
	move.w	borderdelay(pc),d1
waitforhblreturn1:			; wait for the end of the last line
	cmp.b	(a1),d0
	beq.s	waitforhblreturn1
to601:	move.b	#0,$ffff820a.w		; 60 Hz
borderwait1:
	dbra	d1,borderwait1
to501:	move.b	#2,$ffff820a.w		; 50 Hz
	movem.l (sp)+,d0/a1/d1
	bclr	#0,$fffffa0f.w
	tst.w	runwithtimerA
	bne.s	startatimerA1
	rte
startatimerA1:
	tst.l	fulleditorpek
	beq.s	startaAtnu1
	rte
startaAtnu1:
	move.l	#setupperlinescorrect,$134.w
	clr.b	$fffffa19.w
	move.b	#71,$fffffa1f.w
	move.b	#4,$fffffa19.w
	rte

hbl2:					; Ta bort nedre ramen
	move.w	#$2700,sr
	movem.l d0/a1/d1,-(sp)
	move.w	#$fa21,a1
	clr.b	$fffffa1b.w		; timer stop
	move.b	#255,(a1)
	move.b	#8,$fffffa1b.w
	move.b	(a1),d0
	move.w	borderdelay(pc),d1
waitforhblreturn2:			; wait for the end of the last line
	cmp.b	(a1),d0
	beq.s	waitforhblreturn2
to602:	move.b	#0,$ffff820a.w		; 60 Hz
borderwait2:
	dbra	d1,borderwait2
	nop
to502:	move.b	#2,$ffff820a.w		; 50 Hz
	movem.l (sp)+,d0/a1/d1
	bclr	#0,$fffffa0f.w
	tst.w	runwithtimerA
	bne.s	startatimerA2
	rte
startatimerA2:
	tst.l	fulleditorpek
	beq.s	startaAtnu2
	rte
startaAtnu2:
	move.l	#setupperlinescorrect,$134.w
	clr.b	$fffffa19.w
	move.b	#71,$fffffa1f.w
	move.b	#4,$fffffa19.w
	rte

hbl3:					; Ta bort nedre ramen
	move.w	#$2700,sr
	movem.l d0/a1/d1,-(sp)
	move.w	#$fa21,a1
	clr.b	$fffffa1b.w		; timer stop
	move.b	#255,(a1)
	move.b	#8,$fffffa1b.w
	move.b	(a1),d0
	move.w	borderdelay(pc),d1
waitforhblreturn3:			; wait for the end of the last line
	cmp.b	(a1),d0
	beq.s	waitforhblreturn3
to603:	move.b	#0,$ffff820a.w		; 60 Hz
borderwait3:
	dbra	d1,borderwait3
	nop
	nop
to503:	move.b	#2,$ffff820a.w		; 50 Hz
	movem.l (sp)+,d0/a1/d1
	bclr	#0,$fffffa0f.w
	tst.w	runwithtimerA
	bne.s	startatimerA3
	rte
startatimerA3:
	tst.l	fulleditorpek
	beq.s	startaAtnu3
	rte
startaAtnu3:
	move.l	#setupperlinescorrect,$134.w
	clr.b	$fffffa19.w
	move.b	#71,$fffffa1f.w
	move.b	#4,$fffffa19.w
	rte

fixthekeyboard:
	move.w	#$2700,sr
	move.l	keypointbuffer,d0
	tst.w	whichbufferwaswritten	; Byt s† att inte interupten
	beq.s	nybuffer„r2		; skriver ”ver ”ver data
	lea	pressedkeybuffer2,a0
	sub.l	a0,d0
	move.l	#pressedkeybuffer1,keypointbuffer
	clr.w	whichbufferwaswritten
	bra.s	nybuffer„r1
nybuffer„r2:
	lea	pressedkeybuffer1,a0
	sub.l	a0,d0
	move.w	#1,whichbufferwaswritten
	move.l	#pressedkeybuffer2,keypointbuffer
nybuffer„r1:
	move.w	#$2400,sr	; a0 pekare till den nertryckta buffern
				; d0 antal tryckningar
	move.b	altctrlshiftregister,d3
	lea	checkifaltshiftorctrl,a3
	move.l	readdatapointer(pc),a1
	move.l	writedatapointer(pc),a2
	tst.w	d0
	beq	ingatryckningardenh„rVBLen
	subq.w	#1,d0
draigenomallatangenternu:
	moveq	#0,d1
	move.b	(a0)+,d1
	bmi.s	det„rentangentsl„ppning
	tst.b	(a3,d1.w)		; Kolla om det „r en specialtangent
	bmi.s	negativallts†ingencontrol
	moveq	#0,d2			; Isf s„tt registret som det skall
	move.b	(a3,d1.w),d2
	bset	d2,d3
	bra.s	intedaxattswappanerdenigen
negativallts†ingencontrol:
	move.b	d1,currentrepeating
	move.b	d1,d2
	or.b	#$80,d2			; S„tt upp s† att tangenten kommer
	move.b	d2,currentderepeatkey	; att repeteras
	move.w	keydelayrepeatdatainfo2(pc),keydelayrepeatdatainfo
	move.w	keyrepeatdatainfo2(pc),keyrepeatdatainfo
	cmp.l	a1,a2
	bne.s	beh”veriintetestaoverflow
	tst.b	(a1)			; Finns det risk f”r overflow
	bne.s	ajajOverFlowing		; i buffern?
beh”veriintetestaoverflow:
	move.b	d1,(a2)+		; Spar aktuell tangent
	cmp.l	#endofmainkeybuffer,a2
	blt.s	intedaxattswappanerdenigen
	lea	mainkeybuffer,a2	; Dax att swappa ner buffern
intedaxattswappanerdenigen:
ajajOverFlowing:
	dbra	d0,draigenomallatangenternu
	bra.s	ingatryckningardenh„rVBLen
det„rentangentsl„ppning:
	move.w	d1,d2
	and.w	#%01111111,d2
	tst.b	(a3,d2.w)		; Kolla om det „r en specialtangent
	bmi.s	negativallts†ingencontrol2	; Isf s„tt registret som det skall
	move.b	(a3,d2.w),d2
	bclr	d2,d3
	bra.s	intedenh„rtjossangrejjen
negativallts†ingencontrol2:
	cmp.b	currentderepeatkey,d1	; Dax att sluta repetera den
	bne.s	intedenh„rtjossangrejjen
	clr.b	currentderepeatkey	; just nu nertryckta tangenten?
	clr.b	currentrepeating
intedenh„rtjossangrejjen:
	dbra	d0,draigenomallatangenternu
ingatryckningardenh„rVBLen:
	move.l	a2,writedatapointer
	move.b	d3,altctrlshiftregister

	tst.b	currentrepeating	; H„r tar vi hand om repeteringen
	beq	inteentangentattrepeteraalls
	tst.w	keydelayrepeatdatainfo
	bmi.s	detharredanb”rjatrepetera
	subq.w	#1,keydelayrepeatdatainfo	; V„nta in f”rsta delayen
	bpl.s	inteentangentattrepeteraalls
	bra.s	repeteranup†eng†ng
detharredanb”rjatrepetera:
	subq.w	#1,keyrepeatdatainfo		; Repetitionsdelayen
	bpl.s	inteentangentattrepeteraalls
	move.w	keyrepeatdatainfo2(pc),keyrepeatdatainfo
repeteranup†eng†ng:
	move.l	readdatapointer(pc),a1
	move.l	writedatapointer(pc),a2
;	cmp.l	a1,a2
;	bne.s	beh”veriintetestaoverflow3
;	tst.b	(a1)			; Finns det risk f”r overflow
;	bne.s	ajajOverFlowing3	; i buffern?
;beh”veriintetestaoverflow3:
	tst.w	tangrepp†av
	bne.s	repen„rp†minsann	; Žr det begr„nsad rept?
	btst.b	#0,altctrlshiftregister
	bne.s	repen„rp†minsann
	btst.b	#1,altctrlshiftregister
	bne.s	repen„rp†minsann
	cmp.b	#$02,currentrepeating
	blt.s	inte”verstaraden
	cmp.b	#$0D,currentrepeating
	bgt.s	inte”verstaraden
	bra.s	intedaxattswappanerdenigen3
inte”verstaraden:
	cmp.b	#$10,currentrepeating
	blt.s	repen„rp†minsann
	cmp.b	#$35,currentrepeating
	ble.s	intedaxattswappanerdenigen3
repen„rp†minsann:
	move.b	currentrepeating(pc),(a2)+	; Spar aktuell tangent
	cmp.l	#endofmainkeybuffer,a2
	blt.s	intedaxattswappanerdenigen3
	lea	mainkeybuffer,a2	; Dax att swappa ner buffern
intedaxattswappanerdenigen3:
ajajOverFlowing3:
	move.l	a2,writedatapointer
inteentangentattrepeteraalls:

	rts


killrepeat:				; Rutinen som ser till att
	clr.b	currentderepeatkey	; tangentbordshanteraren slutar
	clr.b	currentrepeating	; repetera en tangent
	rts

flushbuffer:				; T”mmer buffern p† alla
	lea	mainkeybuffer,a0	; tangenttryckningar, samt gl”mmer
	moveq	#0,d0			; alla flaggor
	moveq	#5-1,d1
rensahelatangentbordsbuffern:
	move.l	d0,(a0)
	move.l	d0,(a0)
	dbra	d1,rensahelatangentbordsbuffern
	clr.b	altctrlshiftregister
	rts

flushonlybuffer:			; T”mmer buffern p† alla
	lea	mainkeybuffer,a0	; tangenttryckningar
	moveq	#0,d0
	moveq	#5-1,d1
rensahelatangentbordsbuffern2:
	move.l	d0,(a0)
	move.l	d0,(a0)
	dbra	d1,rensahelatangentbordsbuffern2
	rts

isakeyready:				; Rutinen som talar om om det
	move.l	readdatapointer,a0	; finns en tangent som „r
	tst.b	(a0)			; nertryckt/repeteras
	rts

getkeywithasciiandshifts:
	move.l	readdatapointer,a0
v„ntainentangent:
	move.b	(a0),d1
	beq.s	v„ntainentangent
	clr.b	(a0)
	addq.w	#1,a0
	cmp.l	#endofmainkeybuffer,a0
	blt.s	intedaxattswappanerden
	lea	mainkeybuffer,a0
intedaxattswappanerden:
	clr.b	(a0)
	move.l	a0,readdatapointer
	move.l	a0,writedatapointer
	and.l	#$FF,d1
	moveq	#0,d0
	move.l	d1,d2
	swap	d2
	or.l	d2,d0			; Den r†a tangentbordskoden
	moveq	#0,d2
	move.b	altctrlshiftregister,d2
	swap	d2
	lsl.l	#8,d2
	or.l	d2,d0			; altctrlshift-registret h”gst upp
	move.b	altctrlshiftregister,d3
	btst	#2,d3			; Control?
	bne.s	detvarenspecialareoxo
	btst	#3,d3			; Alternativ?
	bne.s	detvarenspecialareoxo
	move.l	tableofkeys,a1
	move.l	8(a1),a0
	btst	#0,d3			; H”ger-shift?
	beq.s	detvarintenh”gershiftattreagerap†
	move.l	4(a1),a0
detvarintenh”gershiftattreagerap†:
	btst	#1,d3			; V„nster-shift?
	beq.s	detvarintenv„nstershiftattreagerap†
	move.l	4(a1),a0
detvarintenv„nstershiftattreagerap†:
	or.b	0(a0,d1.w),d0		; Ge den r„tt ASCII, klarar bara
detvarenspecialareoxo:			; av Caps Lock ON hela tiden
	rts

checkifaltshiftorctrl:
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,2,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,0,-1,3,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
currentderepeatkey:
	dc.b	0
currentrepeating:
	dc.b	0
keydelayrepeatdatainfo:		; Hur l„nge den skall v„nta innan den
	dc.w	0		; b”rjar repetera (VBLs)
keyrepeatdatainfo:		; Hur snabbt den skall repetera (VBLs)
	dc.w	0
keydelayrepeatdatainfo2:
	dc.w	20
keyrepeatdatainfo2:
	dc.w	1
tableofkeys:
	dc.l	0
altctrlshiftregister:
	dc.b	0
	even
readdatapointer:
	dc.l	mainkeybuffer
writedatapointer:
	dc.l	mainkeybuffer
mainkeybuffer:			; Klarar av att h†lla max 50 tecken
	ds.b	40
endofmainkeybuffer:
whichbufferwaswritten:
	dc.w	0
keypointbuffer:			; Pekare till vilken buffer interupt $118
	dc.l	pressedkeybuffer1	; skall skriva till
pressedkeybuffer1:		; Tv† olika buffrar f”r att h†lla r„tt
	ds.b	60		; p† vilka tangenter som blir nertryckta
pressedkeybuffer2:		; under en VBL.
	ds.b	60
datainitto6850:
	dc.b	$15,$9,$1,$4f,$0,$eb,$b,$1,$1,$c,$1,$1,$e,$0
koors:	dc.b	$0,$0,$0,$0
	even
header:	dc.b	$F7	; Musdata-header som 6850n s„nder till 68k
button:	dc.b	0
xhigh:	dc.b	0
xlow:	dc.b	0
yhigh:	dc.b	0
ylow:	dc.b	0
status:	dc.w	0
keystat:dc.w	0

keyboard:
	move.w	#$2500,sr		; S„nk sr vid keyboardinterupt
;	subq.w	#1,$ffff8240.w
	move.b	$fffffc00.w,status+1
	and.b	#$81,status+1
	beq.s	callMIDI
	move.b	$fffffc02.w,header
	cmp.b	#$F7,header
	beq.s	enmusrapportp†G
	tst.w	dumpallcommingkeys
	bne.s	bl„„„„„„„„
	move.l	a0,-(sp)
	move.l	keypointbuffer(pc),a0
	move.b	header,(a0)		; Skriv ner tangenten till
	addq.l	#1,keypointbuffer	; aktuell buffer, som senare
	move.l	(sp)+,a0		; hanteras p† VBLen
	btst.b	#4,$fffffa01.w
	beq.s	keyboard
bl„„„„„„„„:
	bclr	#6,$fffffa11.w
	rte
enmusrapportp†G:
	move.l	#mymouse2,$118.w
	btst.b	#4,$fffffa01.w
	beq.s	mymouse2
	bclr	#6,$fffffa11.w
	rte
callMIDI:		; H„r f†r man anropa MIDIrutinerna ist„llet
	movem.l	d0-d3/a0-a3/a5,-(sp)
	sub.l	a5,a5
MIDI:	jsr	$12345678	; Anropa systmets MIDIrutiner
	movem.l	(sp)+,d0-d3/a0-a3/a5
	btst.b	#4,$fffffa01.w
	beq	keyboard
	bclr	#6,$fffffa11.w
	rte

mymouse2:		; Ta emot knappstatusen fr†n 6850n
	move.b	$fffffc02.w,button
	move.l	#mymouse3,$118.w
;	subq.w	#1,$ffff8240.w
	btst.b	#4,$fffffa01.w
	beq.s	mymouse3
	bclr	#6,$fffffa11.w
	rte

mymouse3:		; Ta emot xhigh fr†n 6850n
	move.b	$fffffc02.w,xhigh
	move.l	#mymouse4,$118.w
;	subq.w	#1,$ffff8240.w
	btst.b	#4,$fffffa01.w
	beq.s	mymouse4
	bclr	#6,$fffffa11.w
	rte

mymouse4:		; Ta emot xlow fr†n 6850n
	move.b	$fffffc02.w,xlow
	move.l	#mymouse5,$118.w
;	subq.w	#1,$ffff8240.w
	btst.b	#4,$fffffa01.w
	beq.s	mymouse5
	bclr	#6,$fffffa11.w
	rte

mymouse5:		; Ta emot yhigh fr†n 6850n
	move.b	$fffffc02.w,yhigh
	move.l	#mymouse6,$118.w
;	subq.w	#1,$ffff8240.w
	btst.b	#4,$fffffa01.w
	beq.s	mymouse6
	bclr	#6,$fffffa11.w
	rte

mymouse6:		; Ta emot ylow fr†n 6850n
	move.b	$fffffc02.w,ylow
	move.l	#keyboard,$118.w
;	clr.w	$ffff8240.w
	btst.b	#4,$fffffa01.w
	beq	keyboard
	bclr	#6,$fffffa11.w
	rte

kj:	jmp	$12345678

takeonlyfour:
	dc.w	0

c:
	move.w	#$2500,sr		; S„nk sr vid timer C
	tst.w	runwithtimerA
	beq.s	cj
	tst.w	donottrytorunviatimerC
	bne.s	cj
	subq.w	#1,takeonlyfour
	bgt.s	cj
	move.w	#4,takeonlyfour
	move.w	#1,doaIPL2now
cj:	jmp	$12345678

disk7:	move.w	#$2500,sr
dj:	jmp	$12345678

d:	move.w	#$2500,sr
jd:	jmp	$12345678

cent:	move.w	#$2500,sr
jc:	jmp	$12345678

new9:	move.w	#$2500,sr
j9:	jmp	$12345678

new10:	move.w	#$2500,sr
j10:	jmp	$12345678

new11:	move.w	#$2500,sr
j11:	jmp	$12345678

new12:	move.w	#$2500,sr
j12:	jmp	$12345678

new13:	move.w	#$2500,sr
j13:	jmp	$12345678

new14:	move.w	#$2500,sr
j14:	jmp	$12345678

new15:	move.w	#$2500,sr
j15:	jmp	$12345678

old7:	dc.l	0
oldd:	dc.l	0
oldcent:dc.l	0
old9:	dc.l	0
old10:	dc.l	0
old11:	dc.l	0
old12:	dc.l	0
old13:	dc.l	0
old14:	dc.l	0
old15:	dc.l	0

mymouse:				; Tar hand om musstyrningen
	rts

;============================================ Installera TRACKERsystemet ==

picpallette:
	dc.w	$0000,$0000,$0999,$0111,$0888,$04BB,$03AA,$0299
	dc.w	$0AA2,$0911,$033A,$0229,$0BB3,$0AA2,$0118,$0000
picname:dc.b	'OCTALYSE.DAT',0
inteenintrobild:
	dc.b	'[1][OCTALYSE.DAT missing!][   Ok   ]',0
	even
packed_length:
	dc.l	0
actual_length:
	dc.l	0
load_addr:
	dc.l	0

arbetaframf„rgerna:
	moveq	#16-1,d0
arbetanerf„rgernap†gemdesktop:
	clr.l	$466.w
loopanerdemnu:
	tst.l	$466.w
	beq.s	loopanerdemnu
	move.l	d0,-(sp)
	bsr	fade			; Simpelt...
	move.l	(sp)+,d0
	dbra	d0,arbetanerf„rgernap†gemdesktop
	rts

init_fade	
	cmp.w	#0,mode
	bne.s	not_fadein
	lea	currentpall,a0
;	rept	8
;	clr.l	(a0)+	
;	endr
	lea	finalpall,a0
	rept	8
	move.l	(a1)+,(a0)+
	endr
	clr.w	fade_mode
	bra	initdone

not_fadein
	cmp.w	#1,mode
	bne.s	not_fadeout
	lea	finalpall,a0
	rept	8
	clr.l	(a0)+	
	endr
	lea	currentpall,a0
.ok
	rept	8
	move.l	(a1)+,(a0)+
	endr
	move.w	#1,fade_mode
	bra.s	initdone

not_fadeout	
	cmp.w	#2,mode
	bne.s	not_fadeout2
	lea	finalpall,a0
	rept	16
	move.w	#$FFF,(a0)+	
	endr
	lea	currentpall,a0
	rept	8
	move.l	(a1)+,(a0)+
	endr
	clr.w	fade_mode
	bra.s	initdone
not_fadeout2	
	bra.s	noIDfound

initdone
	cmp.l	#1,d1
	bne.s	do_not_change_colours
	lea	currentpall,a0
	movem.l (a0),d0-d7
	movem.l	d0-d7,$ffff8240.w
do_not_change_colours	
noIDfound
	rts



fade	lea	currentpall,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.w	#15,d1
fade_routine
	lea	currentpall,a0		; Usch, en massa jobb f”r att
	lea	finalpall,a1		; f† fram RED/GREEN/BLUE...
	move.w	d1,d2			; P† b†de slutpalleten och
	asl.w	#1,d2			; den aktuella palleten...
	adda.w	d2,a0
	adda.w	d2,a1
	move.w	(a0),d2
	move.w	d2,d3
	move.w	d2,d4
	and.w	#$F00,d2
	and.w	#$0F0,d3
	and.w	#$00F,d4
	asr.w	#8,d2
	asr.w	#4,d3
	move.w	(a1),d5
	move.w	d5,d6
	move.w	d5,d7
	and.w	#$F00,d5
	and.w	#$0F0,d6
	and.w	#$00F,d7
	asr.w	#8,d5
	asr.w	#4,d6

	bsr.s	convert_from_ste	; $0,$8... till $0,$1...
	
	cmp.w	#0,fade_mode
	beq.s	sub_fadein
	cmp.w	#1,fade_mode
	beq.s	sub_fadeout
return_label				; Subrutinerna hoppar tebaka hit!

	bsr	convert_to_ste		; $0,$1... till $0,$8...
	bsr.s	create_colour
	dbra	d1,fade_routine
	rts		

; Subrutinerna f”ljer h„r:

sub_fadein
	cmp.w	d5,d2
	bge.s	nored1		
	addq.w	#1,d2
nored1	cmp.w	d6,d3
	bge.s	nogren1
	addq.w	#1,d3
nogren1	cmp.w	d7,d4
	bge.s	noblue1
	addq.w	#1,d4
noblue1
	bra.s	return_label

sub_fadeout
	cmp.w	d2,d5
	bge.s	nored2		
	subq.w	#1,d2
nored2	cmp.w	d3,d6
	bge.s	nogren2
	subq.w	#1,d3
nogren2	cmp.w	d4,d7
	bge.s	noblue2
	subq.w	#1,d4
noblue2
	bra.s	return_label

create_colour
	clr.w	colour
	move.w	d4,colour
	asl.w	#4,d3
	add.w	d3,colour
	asl.w	#8,d2
	add.w	d2,colour
	move.w	colour,(a0)
	rts

convert_from_ste
	lea	conv_table,a5
	asl.w	#1,d2
	move.w	(a5,d2.w),d2
	asl.w	#1,d3
	move.w	(a5,d3.w),d3
	asl.w	#1,d4
	move.w	(a5,d4.w),d4
	asl.w	#1,d5
	move.w	(a5,d5.w),d5
	asl.w	#1,d6
	move.w	(a5,d6.w),d6
	asl.w	#1,d7
	move.w	(a5,d7.w),d7
	rts

convert_to_ste
	lea	conv_table2,a5
	asl.w	#1,d2
	move.w	(a5,d2.w),d2
	asl.w	#1,d3
	move.w	(a5,d3.w),d3
	asl.w	#1,d4
	move.w	(a5,d4.w),d4
	asl.w	#1,d5
	move.w	(a5,d5.w),d5
	asl.w	#1,d6
	move.w	(a5,d6.w),d6
	asl.w	#1,d7
	move.w	(a5,d7.w),d7
	rts



showintropic:	; Rutinen som visar en introbild
	move.w	#2,mode		; mode = #0	-> Fade In
				;      = #1	-> Fade Out to Black
				;      = #2	-> Fade Out to White
	moveq	#1,d1		; d1.l = #1     -> Init-registers
				;        #0     -> Do not intitialise


	lea	emptypal,a1	; Falcon can NOT read $ff8240
	bsr	init_fade
	bsr	arbetaframf„rgerna

	move.w	#1,mode		; mode = #0	-> Fade In
				;      = #1	-> Fade Out to Black
				;      = #2	-> Fade Out to White
	moveq	#1,d1		; d1.l = #1     -> Init-registers
				;        #0     -> Do not intitialise
	lea	currentpall,a1	; Falcon can NOT read $ff8240
	bsr	init_fade
	bsr	arbetaframf„rgerna

	dc.w	$a00a

	move.l	linea,a0
	moveq	#0,d0
	move.w	-4(a0),d0
	mulu	#20,d0
	subq.w	#1,d0
	moveq	#0,d1
	move.l	physbase,a0
rensahelasytemsk„rmen:
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbra	d0,rensahelasytemsk„rmen


	move.w	#-1,-(sp)
	move.l	physbase,-(sp)
	move.l	logbase,-(sp)
	move.w	#5,-(sp)		; Se till att det „r l†guppl”sning
	trap	#14
	lea	12(sp),sp

	tst.w	falkrun
	beq.s	.blade_falkrez

	clr.w	-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)		; Se till att det „r l†guppl”sning
	trap	#14
	lea	12(sp),sp
	bra.s	.vidare

.blade_falkrez

	move.w	InOctaFalkrez,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp

	move.w	#37,-(sp)	
	trap	#14
	addq.l	#2,sp

	move.w	#37,-(sp)	
	trap	#14
	addq.l	#2,sp

	move.w	#37,-(sp)	
	trap	#14
	addq.l	#2,sp

	lea	$ffff8240.w,a0
	moveq.l	#0,d0
	move.l	d0,(a0)+	
	move.l	d0,(a0)+	
	move.l	d0,(a0)+	
	move.l	d0,(a0)+	
	move.l	d0,(a0)+	
	move.l	d0,(a0)+	
	move.l	d0,(a0)+	
	move.l	d0,(a0)+	
	
.vidare
	move.l	#makeonlyerror,$404.w

	clr.w	-(sp)
	pea	picname
	move.w	#$3d,-(sp)
	trap	#1			; ™ppna introbilden
	addq.l	#8,sp
	tst.l	d0
	bmi	kanej”ppnaintrobilden	; startinte
	move.w	d0,handle

	move.l	#24024,d0
	move.l	physbase,a0		; Ladda introbilden
	jsr	loadthisblock
	tst.w	d0
	bmi	kanej”ppnaintrobilden	; startinte

	move.l	#24024,d0
	move.l	physbase,a0

unpack:	movem.l	d0-d7/a0-a6,-(sp)
	move.l	d0,packed_length
	move.l	d0,actual_length
	move.l	a0,load_addr
	btst	#0,d0               ; odd length: not packed
	bne	kanej”ppnaintrobildenstartinte
	move.l	a0,d7               ; odd address of buffer
	btst	#0,d7
	bne	kanej”ppnaintrobildenstartinte
	adda.l	d0,a0
	move.l	-(a0),d0            ; check if crunched file
	cmpi.l	#'CODE',d0          ; crunched, last Longw. = 'CODE'
	bne	kanej”ppnaintrobildenstartinte
	move.l	-(a0),actual_length
	subq.l	#4,packed_length
	move.l	load_addr(pc),a0
	adda.l	packed_length(pc),a0
	move.l	load_addr(pc),a1
	move.l	-(a0),a2
	adda.l	a1,a2
	move.l	-(a0),d5
	move.l	-(a0),d0
	eor.l	d0,d5
L541f8:	lsr.l	#1,d0
	bne.s	L54200
	bsr	L542be
L54200:	bcs.s	L54242
	moveq	#8,d1
	moveq	#1,d3
	lsr.l	#1,d0
	bne.s	L5420e
	bsr	L542be
L5420e:	bcs.s	L5426e
	moveq	#3,d1
	clr.w	d4
L54214:	bsr	L542ca
	move.w	d2,d3
	add.w	d4,d3
L5421c:	moveq	#7,d1
L5421e:	lsr.l	#1,d0
	bne.s	L54226
	bsr	L542be
L54226:	roxl.l	#1,d2
	dbra	d1,L5421e
	move.b	d2,-(a2)
	dbra	d3,L5421c
	bra.s	L5427c
L5423c:	moveq	#8,d1
	moveq	#8,d4
	bra.s	L54214
L54242:	moveq	#2,d1
	bsr	L542ca
	cmpi.b	#2,d2
	blt.s	L54264
	cmpi.b	#3,d2
	beq.s	L5423c
	moveq	#8,d1
	bsr	L542ca
	move.w	d2,d3
	move.w	#$c,d1
	bra.s	L5426e
L54264:	move.w	#9,d1
	add.w	d2,d1
	addq.w	#2,d2
	move.w	d2,d3
L5426e:	bsr	L542ca
L54272:	subq.l	#1,a2
	move.b	0(a2,d2.w),(a2)
	dbra	d3,L54272
L5427c:	cmpa.l	a2,a1
	blt.s	L541f8
end_read: 
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	actual_length,d0


;	bsr	vantainmuseninnan2700sr
;	move.l	pointmouse,a0		; Installera egen musrutin
;	move.l	#mymouse,(a0)
;	move.w	#$2300,sr

	clr.w	mode		; mode = #0	-> Fade In
				;      = #1	-> Fade Out to Black
				;      = #2	-> Fade Out to White
	moveq	#1,d1		; d1.l = #1     -> Init-registers
				;        #0     -> Do not intitialise
	lea	picpallette(pc),a1	; a0.l = Pallete-adress
	bsr	init_fade
	bsr	arbetaframf„rgerna
kanej”ppnaintrobilden:

	move.l	bildminne,a3
	lea	106*168+8(a3),a2	; a2 till bilden
	add.l	#71960+4+2128,a3	; a3 till patternbasen
	bsr	sparsampleeditornelpatterbasen; Spar undan den

	jsr	vol			; Calculate volume tables
	lea	stab0,a0
	move.l	hz125,d2
	jsr	incrcal 		; Calculate tonetables

	clr.l	$466.w
	moveq	#5,d6
test2:	move.w	#32000,d7
test:	move.l	$466.w,d0
	move.l	d0,d1
	dbra	d7,test
	dbra	d6,test2

	move.w	#$D-1,bordercounter
	move.l	$466.w,d2
	cmp.l	#40,d2
	bgt.s	no16mhz
	lea	speedandupdatingdata,a1
	lea	alternativ,a0
	moveq	#6*4-1,d0
ksgjklsjgkjksg:
	move.w	(a0)+,(a1)+
	dbra	d0,ksgjklsjgkjksg
	move.w	#(3*6)-1,bordercounter
no16mhz:
	cmp.l	#30,d2
	bgt.s	no16mhzcache
	lea	speedandupdatingdata,a1
	lea	alternativ2,a0
	moveq	#6*4-1,d0
ksgjklsjgkjkesg:
	move.w	(a0)+,(a1)+
	dbra	d0,ksgjklsjgkjkesg
	move.w	#(3*10)-1,bordercounter
no16mhzcache:
	moveq	#16-1,d7
fixatillskitennup†eng†ng:
	move.w	#37,-(sp)
	trap	#14			; V„nta in syncen
	addq.w	#2,sp
;	move.w	#%10000000010,$ffff8922.w
	move.w	#37,-(sp)
	trap	#14			; V„nta in syncen
	addq.w	#2,sp
;	move.w	#%10000000001,$ffff8922.w
	dbra	d7,fixatillskitennup†eng†ng

;	move.w	#%10011101000,$ffff8922.w

	tst.w	optionsloaded		; Fixa till options fas 1
	beq	ingenoptionsfilblevladdad1
	lea	termtonebuff,a0
	lea	modpath,a2	; Modulpath
	lea	32(a0),a1
	bsr	koppainpathen
	lea	path,a2		; Samplingspath
	lea	96(a0),a1
	bsr	koppainpathen
	lea	terpath,a2	; UCDMpath
	lea	160(a0),a1
	bsr	koppainpathen
	lea	blkpath,a2	; Blockpath
	lea	224(a0),a1
	bsr	koppainpathen
	lea	delpath,a2	; Deletepath
	lea	288(a0),a1
	bsr	koppainpathen
	lea	runpath,a2	; Exekveringspath
	lea	824(a0),a1
	bsr	koppainpathen
	move.w	30(a0),bordercounter
	move.b	676(a0),edmode+1	; Editmode
	move.b	677(a0),bsmode+1	; Backspacemode
	move.b	678(a0),blkmode+1	; Blockmode
	move.b	679(a0),wrtmode+1	; Writningmode
	move.b	680(a0),d0
	lsr.w	#4,d0
	move.b	d0,freqonkeyboard+1	; Frekvens (Up/Low)
	move.b	681(a0),stepswhenpressing+1	; Step
	lea	682(a0),a1
	lea	speedandupdatingdata,a2
	moveq	#12-1,d0
skrivditmaxpattvisa:
	move.l	(a1)+,(a2)+
	dbra	d0,skrivditmaxpattvisa
	jsr	sattuppfreqonkey
	jsr	komigenda1
	jsr	allt„rokofint
	jsr	allt„rokofint2
	jsr	allt„rokofint3
	lea	termtonebuff,a0
	move.b	680(a0),d0
	and.b	#$0F,d0
	beq.s	intes„ttaalliedit	; Blocket skall p†verka (Cur/All)
	jsr	editrutin
	jsr	allaktiv
	jsr	slutamededit
intes„ttaalliedit:
	lea	termtonebuff,a0
	move.w	12(a0),screenpalette	; S„tt f„rgerna
	move.w	12(a0),texteditpalette
	move.w	14(a0),screenpalette+2
	move.w	14(a0),texteditpalette+2
	move.w	16(a0),screenpalette+4
	move.w	16(a0),texteditpalette+4
	move.w	18(a0),screenpalette+6
	move.w	18(a0),texteditpalette+6
	lea	oldR0,a0
	lea	screenpalette,a2
	lea	RGBdata,a1
	moveq	#4-1,d0
k”rigenomallaf„rgerna:
	move.w	(a2),d1
	lsr.w	#8,d1
	and.w	#$F,d1
	bsr	hittaf„rgv„rde
	add.w	#28,d2
	move.w	d2,(a0)+
	move.w	(a2),d1
	lsr.w	#4,d1
	and.w	#$F,d1
	bsr	hittaf„rgv„rde
	add.w	#28,d2
	move.w	d2,(a0)+
	move.w	(a2)+,d1
	and.w	#$F,d1
	bsr	hittaf„rgv„rde
	add.w	#28,d2
	move.w	d2,(a0)+
	dbra	d0,k”rigenomallaf„rgerna
	jsr	opencolormenu
	jsr	selectcolor3
	jsr	selectcolor0
	jsr	slutamedcolor
	lea	termtonebuff,a0
	move.b	730(a0),oldbass+1
	move.b	731(a0),oldtreble+1
	move.b	732(a0),oldmain+1
	move.b	733(a0),oldleft+1
	move.b	734(a0),oldright+1
	move.b	735(a0),oldrep+1
	move.b	736(a0),olddel+1
	move.b	737(a0),oldmousedel+1
	jsr	settermody
	move.w	#1,vidproblemskippa
	lea	wholename,a2		; Ladda in UCDMarna
	lea	termtonebuff+352,a1
	tst.b	(a1)
	beq.s	gl”mdennaden„rtom1
	bsr	skrivtillsnolladockmax76tecken
	bsr	fixatillternamnet
	jsr	laddainUCDM
gl”mdennaden„rtom1:
	jsr	termoval2
	lea	wholename,a2
	lea	termtonebuff+428,a1
	tst.b	(a1)
	beq.s	gl”mdennaden„rtom2
	bsr	skrivtillsnolladockmax76tecken
	bsr	fixatillternamnet
	jsr	laddainUCDM
gl”mdennaden„rtom2:
	jsr	termoval3
	lea	wholename,a2
	lea	termtonebuff+504,a1
	tst.b	(a1)
	beq.s	gl”mdennaden„rtom3
	bsr	skrivtillsnolladockmax76tecken
	bsr	fixatillternamnet
	jsr	laddainUCDM
gl”mdennaden„rtom3:
	jsr	termoval4
	lea	wholename,a2
	lea	termtonebuff+580,a1
	tst.b	(a1)
	beq.s	gl”mdennaden„rtom4
	bsr	skrivtillsnolladockmax76tecken
	bsr	fixatillternamnet
	jsr	laddainUCDM
gl”mdennaden„rtom4:
	clr.w	vidproblemskippa
	lea	termtonebuff,a0
	move.w	656(a0),d0
	ext.l	d0
	move.l	d0,hurh†rdbelastning	; Antal rader att visa
	move.w	658(a0),d0
	ext.l	d0
	move.l	d0,hurh†rdbelastning+4
	move.w	660(a0),d0
	ext.l	d0
	move.l	d0,hurh†rdbelastning+8
	move.w	662(a0),d0
	ext.l	d0
	move.l	d0,hurh†rdbelastning+12
	lea	supertermo,a1
	move.w	664(a0),d0		; Vilken termody „r vald
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a1,d0.w),a1
	jsr	(a1)
	move.w	termtonebuff+666,termotones	; Antal toner
	lea	termotones+1,a3		; Skriv ut antalet toner
	move.w	#224,d0			; x
	move.w	#24,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
	jsr	exittermody
ingenoptionsfilblevladdad1:

	move.w	#1,mode		; mode = #0	-> Fade In
				;      = #1	-> Fade Out to Black
				;      = #2	-> Fade Out to White
	moveq	#1,d1		; d1.l = #1     -> Init-registers
				;        #0     -> Do not intitialise
	lea	picpallette(pc),a1	; a0.l = Pallete-adress
	bsr	init_fade
	bsr	arbetaframf„rgerna

	tst.w	optionsloaded		; Fixa till options fas 2
	beq	ingenoptionsfilblevladdad2
	jsr	optionsrutin
	jsr	s„ttr„ttvidstartuppen	; S„tt r„tt sync f”r nedre bordern
	btst.b	#1,termtonebuff+675
	bne.s	lnoiseskallvarap†
	jsr	setlownoise		; Lownoise
lnoiseskallvarap†:
	btst.b	#4,termtonebuff+675
	bne.s	keyreskallvarap†
	jsr	setreptonoff		; Keyrep
keyreskallvarap†:
	tst.w	runwithtimerA
	bne.s	trashskalltvingas
	btst.b	#6,termtonebuff+675
	beq.s	trashskallvaraav
trashskalltvingas:
	jsr	supertrashNOW		; Trash
trashskallvaraav:
	btst.b	#7,termtonebuff+675
	bne.s	VUskallvarap†
	jsr	setVUmeteronoff		; VUmeters
VUskallvarap†:
	cmp.w	#4,termtonebuff+668	; 4 kanaler?
	bne.s	intest„llaomtill4
	jsr	till4kanaler
intest„llaomtill4:
	cmp.w	#6,termtonebuff+668	; 6 kanaler?
	bne.s	intest„llaomtill6
	jsr	till6kanaler
intest„llaomtill6:
	btst.b	#0,termtonebuff+675
	bne.s	AAliasskallvarap†
	jsr	aaliasoff		; Aalias
AAliasskallvarap†:
	tst.w	termtonebuff+672
	bne.s	intetill18kHz
	jsr	till625
intetill18kHz:
	cmp.w	#2,termtonebuff+672	; S„tt r„tt frekvens
	bne.s	intetill25kHz
	jsr	till25
intetill25kHz:
	cmp.w	#3,termtonebuff+672
	bne.s	intetill15kHz
	jsr	till50
intetill15kHz:
	tst.w	termtonebuff+670	; S„tt r„tt bashastighet
	ble.s	intetill25kHzbas
	jsr	basspeed25
intetill25kHzbas:
	tst.w	termtonebuff+670
	bpl.s	intetill20kHzbas
	jsr	basspeed20
intetill20kHzbas:
	btst.b	#3,termtonebuff+675
	beq.s	BPMskallvaraav
	jsr	setBPMonoff		; BPM
BPMskallvaraav:
	btst.b	#5,termtonebuff+675
	beq.s	loopskallvaraav
	jsr	doloopordupp		; Loop
loopskallvaraav:



	jsr	slutamedoptions
	bra.s	alltklartioptionernaiaf
ingenoptionsfilblevladdad2:
	jsr	optionsrutin
	jsr	s„ttr„ttvidstartuppen
	jsr	supertrashNOW
	jsr	till4kanaler
	jsr	till25
	jsr	setBPMonoff
	jsr	opencolormenu
	jsr	selectcolor3
	jsr	selectcolor0
	jsr	slutamedcolor
	jsr	slutamedoptions
alltklartioptionernaiaf:
	move.l	criticalerrorhandler,$404.w
	clr.w	mode		; mode = #0	-> Fade In
				;      = #1	-> Fade Out to Black
				;      = #2	-> Fade Out to White
	moveq	#1,d1		; d1.l = #1     -> Init-registers
				;        #0     -> Do not intitialise
	lea	screenpalette,a1	; a0.l = Pallete-adress
	bsr	init_fade

	dc.w	$a009
	rts

L542be:	move.l	-(a0),d0
	eor.l	d0,d5
	move.w	#$10,ccr
	roxr.l	#1,d0
	rts       
L542ca:	subq.w	#1,d1
	clr.w	d2
L542ce:	lsr.l	#1,d0
	bne.s	L542dc
	move.l	-(a0),d0
	eor.l	d0,d5
	move.w	#$10,ccr
	roxr.l	#1,d0
L542dc:	roxl.l	#1,d2
	dbra	d1,L542ce
	rts       

fixatillternamnet:
	cmp.b	#'\',(a2)
	beq.s	h„rharvitecknet
	subq.w	#1,a2
	bra.s	fixatillternamnet
h„rharvitecknet:
	lea	tername,a1
	addq.w	#1,a2
k”rh†rttillsnolla:
	tst.b	(a2)
	beq.s	sluuuuuuuuuuuta
	move.b	(a2)+,(a1)+
	bra.s	k”rh†rttillsnolla
sluuuuuuuuuuuta:
	clr.b	(a1)
	rts

makeonlyerror:
	moveq	#-1,d0
	rts

hittaf„rgv„rde:
	move.l	a1,a3
	moveq	#0,d2
testasomfan:
	cmp.w	(a3),d1
	beq.s	okretunera22222
	addq.w	#1,d2
	addq.w	#2,a3
	bra.s	testasomfan
okretunera22222:
	rts

kanej”ppnaintrobildenstartinte:
	move.l	(sp)+,d0

	jsr	reinstallsystem
	move.l	oldmedia+2,$47e.w

	lea	inteenintrobild,a1
	moveq	#1,d1			; Vi hittade inte filen, avsluta
	jsr	form_alert

	clr.w	-(sp)
	trap	#1		; Avsluta trackern

vbls:	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

myownsystem:
	jsr	installcrashsaver
	move.w	#1,donottrytorunviatimerC

	move.l	sp,dummen
	move.l	oldstack,-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa tebax till user
	addq.l	#6,sp

	moveq	#3,d1		; Till†t inte GEM att uppdatera sk„rmen
	jsr	wind_update

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa upp i super
	addq.l	#6,sp
	move.l	dummen,sp

	clr.b	$fffffa1b.w

	move.w	#1,dumpallcommingkeys
	clr.b	mkey
	dc.w	$a00a

	move.l	linea,a0		; Ladda upp pekaren till lineaa
	move.w	-602(a0),oldx
	move.w	-600(a0),oldy
	move.w	-602(a0),x
	move.w	-600(a0),y
	tst.w	rez
	beq.s	„rredanl†g1
	lsr.w	x
„rredanl†g1:
	move.w	-602(a0),xhigh
	move.w	-600(a0),yhigh
	tst.w	rez
	beq.s	„rredanl†g144
	lsr.w	xhigh
„rredanl†g144:
	add.w	#16,xhigh
	lea	xhigh,a0
	lea	koors,a1
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.w	koors,x
	move.w	koors+2,y

	pea	datainitto6850
	move.w	#18-1,-(sp)
	move.w	#25,-(sp)
	trap	#14			; Skriv data till 6850n
	addq.w	#8,sp

lopawerpasdghdf:
	move.w	oldrept,d0
	addq.w	#2,d0
tjingeling:
	clr.l	$466.w
hipphopp:
	tst.l	$466.w
	beq.s	hipphopp
	dbra	d0,tjingeling

	bsr	vantainmuseninnan2700sr
	move.l	oldvbl,vj+2
	move.l	oldkeyboard,kj+2
	move.l	oldc,cj+2
	move.l	old7,dj+2
	move.l	oldd,jd+2
	move.l	old9,j9+2
	move.l	old10,j10+2
	move.l	old11,j11+2
	move.l	old12,j12+2
	move.l	old13,j13+2
	move.l	old14,j14+2
	move.l	old15,j15+2


	move.l	#runaIPL2,$68.w
	move.l	oldcent,jc+2
	move.b	#%1010,$484.w		; Keyklick
	move.l	#keyboard,$118.w	; Keyboard
	move.l	#c,$114.w 		; timer C
	move.l	#disk7,$11c.w
	move.l	#d,$110.w
	move.l	#cent,$100.w
	move.l	#new9,$124.w
	move.l	#new10,$128.w
	move.l	#new11,$12c.w
	move.l	#new12,$130.w
	move.l	#new13,$134.w
	move.l	#new14,$138.w
	move.l	#new15,$13c.w

	move.w	#$2300,sr

;	move.w	#-1,-(sp)
;	move.l	physbase,-(sp)
;	move.l	logbase,-(sp)
;	move.w	#5,-(sp)		; Set physbase och logbase
;	trap	#14
;	lea	12(sp),sp

	tst.w	falkrun
	beq.s	.blade_falkrez

	clr.w	-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)		; Se till att det „r l†guppl”sning
	trap	#14
	lea	12(sp),sp
	bra.s	.vidare

.blade_falkrez
	move.w	InOctaFalkrez,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp
	
	
.vidare

	tst.w	falkrun
	beq.s	blade_falkborder

	move.w	#1,$ffff8264.w		; Fixa till 16 extra pixels
	clr.b	$ffff8264.w		; i v„nsterbordern
	bra	hit
blade_falkborder
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp

	move.w	#37,-(sp)	
	trap	#14
	addq.l	#2,sp

	move.w	#37,-(sp)	
	trap	#14
	addq.l	#2,sp

	move.w	$ffff8284.w,falk_oldHBB
	move.w	$ffff82aa.w,falk_oldVDE
	move.w	$ffff8210.w,falk_oldVwrap
	move.w	$ffff82a4.w,falk_oldVBB
	move.w	$ffff82a6.w,falk_oldVBE
	move.w	$ffff82a8.w,falk_oldVDB

	tst.w	VGArun
	beq.s	.falkborderVGA

.falkborderRGB
	move.w	$ffff828a.w,d0
	move.w	d0,falk_oldHDE
	addq.w	#8,d0
	move.w	d0,$ffff828a.w	
	move.w	#$28,$ffff8284.w
	move.w	#$24f,$ffff82aa.w
	move.w	#$54,$ffff8210.w
	bra.s	hit
.falkborderVGA
	move.w	$ffff828a.w,d0
	move.w	d0,falk_oldHDE
	move.w	d0,$ffff828a.w	
	move.w	#$24f*2,$ffff82aa.w
	move.w	#12,$ffff8264.w
	move.w	#$40f,$ffff82a4.w
	move.w	#$3f,$ffff82a6.w

	move.w	$ffff82a8.w,d0
	sub.w	#8*8,d0
	move.w	d0,$ffff82a8.w
		
hit	
	move.w	#-1,-(sp)
	move.l	bildminne,-(sp)
	move.l	bildminne,-(sp)
	move.w	#5,-(sp)		; Nytt bildminne
	trap	#14
	lea	12(sp),sp

;	tst.w	hblisallreadyused
;	bne.s	hblenanv„nds2
	move.l	hbler,$120.w		; HBL
	clr.b	$fffffa1b.w
	bset	#0,$fffffa07.w	    ;  Init rutiner
	bset	#0,$fffffa13.w
	move.b	#255,$fffffa21.w
	move.b	#8,$fffffa1b.w	    ;  Nasta en vbl
;hblenanv„nds2:

	tst.w	mode
	beq.s	niasgnjadfncjkadfajf

	move.w	#$8240,a1
	lea	screenpalette,a0	; Ladda upp f„rgerna
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

niasgnjadfncjkadfajf:

	move.w	#$8a00,a0	       ; Installera blittern !!!
	move.w	#16-1,d0
loopb1: move.w	#$ffff,(a0)+
	dbra	d0,loopb1

	move.w	#$ffff,$ffff8a28.w
	move.w	#$ffff,$ffff8a2a.w
	move.w	#$ffff,$ffff8a2c.w

	move.b	#2,$ffff8a3a.w
	clr.b	$ffff8a3d.w

	clr.w	$ffff8900.w
	move.w	#$07ff,$ffff8924.w

	bsr	skrivutlitekrafs

	move.w	#$0010,d5
	bsr	skrivutkanalinfon

	tst.w	printitwhenloading
	bne.s	neneneenenen
	jsr	skrivuttillhorandeinfo
neneneenenen:
	move.l	#myerrorhandler,$404.w	; Critical error handler

	jsr	outputblockstatus

	lea	stepswhenpressing+1,a3	; Vilket tal skall konverteras
	move.w	#96,d0			; x
	move.w	#97,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex

	tst.w	freqonkeyboard
	bne.s	komigenda32		; Freq p† tangentbordet
	lea	freqonit,a3
	bra.s	sattuppfreqonkey32
komigenda32:
	lea	freqonit+2,a3
sattuppfreqonkey32:
	move.w	#48,d0			; x
	move.w	#97,d1			; y
	bsr	skrivuttext		; Skriv ut textstr„ngen

	lea	wrtonit,a3
	move.w	wrtmode,d0
	lsl.w	#1,d0
	add.w	d0,a3
	move.w	#192,d0			; x
	move.w	#97,d1			; y
	bsr	skrivuttext		; Skriv ut textstr„ngen

	move.w	#1,donotdoanymusicorsomeshit

	lea	sample,a5
	move.w	#412-1,d5
	moveq	#0,d0
rensaspelbuffern666:			; Rensa playbuffern
	move.l	d0,(a5)+
	move.l	d0,(a5)+
	move.l	d0,(a5)+
	move.l	d0,(a5)+
	dbra	d5,rensaspelbuffern666


	tst.w	termodyonoff
	beq.s	s„ttuppf”rdeninterna
	move.l	FrameBaseAdress,a0
	move.l	FrameEndAdress,d0
	sub.l	a0,d0
	subq.l	#1,d0
	lsr.l	#1,d0
	moveq	#0,d1
rensaUMParean:
	move.w	d1,(a0)+
	dbra	d0,rensaUMParean
	move.b	FrameBaseAdress+1,$ffff8903.w
	move.b	FrameBaseAdress+2,$ffff8905.w
	move.b	FrameBaseAdress+3,$ffff8907.w
	move.b	FrameEndAdress+1,$ffff8909.w
	move.b	FrameEndAdress+2,$ffff890b.w
	move.b	FrameEndAdress+3,$ffff890d.w
	move.w	SoundModeControl,$ffff8920.w
	move.w	SoundDMAcontrol,$ffff8900.w
	bra.s	forts„tttack
s„ttuppf”rdeninterna:
	lea	$FF8907,a0
	move.l	#sample,d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)
	cmp.w	#1,frekvens
	bne.s	inteen252a
	move.l	#(252*3*2),d0
	move.b	#1,$FF8921		    ; Frequency
	bra.s	inteen504a
inteen252a:
	move.b	#2,$FF8921		    ; Frequency
	cmp.w	#2,frekvens
	bne.s	en504a
	move.l	#(502*3*2),d0
	bra.s	inteen504a
en504a:
	move.l	#(504*3*2),d0
inteen504a
	bsr	fixextra
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)
	move.b	#3,$FF8901	    ; Start DMA
forts„tttack:

	cmp.l	#termodykoors,losapositioner
	beq	struntidettadetgeringet
	move.l	losapositioner,-(sp)
	move.l	losarutiner,-(sp)
	jsr	optionsrutin
	move.w	oldbass,d7
	addq.w	#2,d7
	jsr	setbass
	move.w	oldtreble,d7
	addq.w	#2,d7
	jsr	settreble
	move.w	oldmain,d7
	addq.w	#2,d7
	jsr	setmainvol
	move.w	oldleft,d7
	addq.w	#2,d7
	jsr	setleftvol
	move.w	oldright,d7
	addq.w	#2,d7
	jsr	setrightvol
	move.w	oldrep,d7
	addq.w	#2,d7
	jsr	setkeyrep
	move.w	olddel,d7
	addq.w	#2,d7
	jsr	setkeydel
	move.w	oldmousedel,d7
	addq.w	#2,d7
	jsr	setmousedel
	jsr	slutamedoptions
	move.l	(sp)+,losarutiner
	move.l	(sp)+,losapositioner
struntidettadetgeringet:
	move.w	#1,donotdoanymusicorsomeshit

	clr.l	$466.w
asasdht:tst.l	$466.w
	beq.s	asasdht

	clr.w	musicwait
	jsr	s„ttregisterefterfreq
	bsr	fixtheregs
	jsr	direktjumptocreate
	move.l	#vbls,$456.w
	move.w	#16,$454.w

	move.w	#$2300,sr
	tst.w	runwithtimerA
	beq.s	inteaktiveraHBL
	move.w	#$2100,sr
inteaktiveraHBL:

	move.w	#0,donottrytorunviatimerC
	pea	setupperlinescorrect
	move.w	#0,-(sp)
	move.w	#0,-(sp)
	move.w	#0,-(sp)
	move.w	#31,-(sp)
	trap	#14
	lea	12(sp),sp

	bsr	killrepeat
	bsr	flushbuffer
	clr.w	dumpallcommingkeys
	rts

falk_oldHBB	ds.w	1
falk_oldHDE	ds.w	1
falk_oldVDE	ds.w	1
falk_oldVwrap	ds.w	1

falk_oldVBB	ds.w	1
falk_oldVBE	ds.w	1
falk_oldVDB	ds.w	1

emptypal	ds.w	16
			
falkrun:	dc.w	-1	; 0 = Falcon, -1 = ingen Falcon
VGArun:		dc.w	-1	; 0 = VGA monitor anv„nds
run60Hz:	dc.w	-1	; -1 = 50 Hz, 0 = annan frekvens.
runwithtimerA:	dc.w	0	; 0 Inte timer A    1 timer A

fixextra:
	tst.w	aalias
	beq.s	nixnix
	add.w	d0,d0
	addq.b	#1,$FF8921
nixnix:
	add.l	#sample,d0
	rts

skrivutlitekrafs:
	lea	songpos,a3		; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#6,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex

	lea	whichpatt+1,a3		; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#16,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i h

	lea	songlength,a3		; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#26,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex

	lea	songrestart,a3		; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#36,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex

	lea	whichsample+1,a3	; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#49,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex


	rts

skrivutkanalinfon:
	move.w	d5,d6
	lsr.w	#4,d6
	move.w	d6,startkanal
	move.w	d5,dummen
	lea	dummen+1,a3		; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#97,d1			; y
	move.w	#1-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
	add.w	#$10,d5
	move.w	d5,dummen
	lea	dummen+1,a3		; Vilket tal skall konverteras
	move.w	#137,d0 		; x
	move.w	#97,d1			; y
	move.w	#1-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
	add.w	#$10,d5
	move.w	d5,dummen
	lea	dummen+1,a3		; Vilket tal skall konverteras
	move.w	#208,d0 		; x
	move.w	#97,d1			; y
	move.w	#1-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
	add.w	#$10,d5
	move.w	d5,dummen
	lea	dummen+1,a3		; Vilket tal skall konverteras
	move.w	#288,d0 		; x
	move.w	#97,d1			; y
	move.w	#1-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
	rts

;=============================================== terst„ller OPsystemet ==

vantainmuseninnan2700sr:
	lea	$fffffc00.w,a0
testaikbd:
	move.b	(a0),d0
	btst	#1,d0
	beq.s	testaikbd
	move.w	#$2700,sr
	btst.b	#1,(a0)
	bne.s	ikbdok
	move.w	#$2300,sr
	bra.s	testaikbd
ikbdok:
	rts

writeto6850:			; d0 data till 6850  a0/d1 f”rst”rs
	move.w	#$fc00,a0
readshit:
	move.b	(a0),d1
	btst	#1,d1
	beq.s	readshit
	move.b	d0,2(a0)
	rts

SoundDMAcontrol:
	dc.w	0
FrameBaseAdress:
	dc.l	0
FrameEndAdress:
	dc.l	0
SoundModeControl:
	dc.w	0
oldIPL2:
	dc.l	0
dontaskaboutthemouse:
	dc.w	0

reinstallsystem:
	jsr	deinstallcrashsaver

	move.w	#$2300,sr

	move.w	#$8248,a0
	lea	screenpalette+8,a1	; Spara f„rgerna
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	tst.w	falkrun
	bmi.s	.nofalk

	move.w	#20000,d0
.loop
	nop
	dbf	d0,.loop
.nofalk

	move.w	#1,dontaskaboutthemouse
	clr.l	$466.w
asasdht33:
	tst.l	$466.w
	beq.s	asasdht33

	move.w	#13,-(sp)
	move.w	#26,-(sp)
	trap	#14			; Timer A av
	addq.w	#4,sp
	move.w	#1,donottrytorunviatimerC
	move.l	oldvbl,$70.w		; VBL
	clr.w	dontaskaboutthemouse
	move.l	oldIPL2,$68.w
	move.w	oldnumofvbls,$454.w
	move.l	oldvbls,$456.w
	moveq	#$12,d0			; Mus av
	bsr	writeto6850
	bsr	vantainmuseninnan2700sr
	move.l	oldkeyboard,$118.w	; Keyboard
	move.w	$ffff8900.w,SoundDMAcontrol
	move.b	$ffff8903.w,FrameBaseAdress+1
	move.b	$ffff8905.w,FrameBaseAdress+2
	move.b	$ffff8907.w,FrameBaseAdress+3
	move.b	$ffff8909.w,FrameEndAdress+1
	move.b	$ffff890b.w,FrameEndAdress+2
	move.b	$ffff890d.w,FrameEndAdress+3
	move.w	$ffff8920.w,SoundModeControl
	clr.b	$FF8901 	    ; Stop DMA
	move.l	x,extraxy
	move.w	keyklick,$484.w		; Keyklick
	move.l	oldhbl,$120.w		; HBL
	move.l	oldc,$114.w		; Timer C
	move.l	old7,$11c.w
	move.l	oldd,$110.w
	move.l	oldcent,$100.w
	move.l	old9,$124.w
	move.l	old10,$128.w
	move.l	old11,$12c.w
	move.l	old12,$130.w
	move.l	old13,$134.w
	move.l	old14,$138.w
	move.l	old15,$13c.w

	move.l	criticalerrorhandler,$404.w	; Critical error handler

;	tst.w	hblisallreadyused
;	bne.s	hblenanv„nds3
	move.w	#8,-(sp)
	move.w	#26,-(sp)
	trap	#14			; Sl† av HBL
	addq.l	#4,sp
	clr.b	$fffffa1b.w
;hblenanv„nds3:

	move.w	#$2300,sr

	moveq	#$8,d0			; Systemmus p†
	bsr	writeto6850

	clr.w	$ffff8264.w		; back to normal

	tst.w	falkrun
	bmi.s	ejfalk22

blade_falk_backtonormal
	move.w	falk_oldHBB,$ffff8284.w
	move.w	falk_oldHDE,$ffff828a.w
	move.w	falk_oldVDE,$ffff82aa.w
	move.w	falk_oldVwrap,$ffff8210.w
	move.w	falk_oldVBB,$ffff82a4.w
	move.w	falk_oldVBE,$ffff82a6.w
	move.w	falk_oldVDB,$ffff82a8.w

ejfalk22

	move.l	linea,a0
	moveq	#0,d0
	move.w	-4(a0),d0

.blade
	moveq	#0,d1
	tst.w	falkrun
	bne.s	.no_falk

	move.w	falkrez,d2
	btst	#3,d2
	beq.s	.fourtycolumns
.eightycolumns
	mulu.w	#10,d0
	bra.s	.hit
.fourtycolumns
	mulu.w	#5,d0
.hit
	btst	#6,d2
	beq.s	.noOverscan
.Overscan
	mulu.w	#12,d0
	divu.w	#10,d0
.noOverscan
	and.w	#%111,d2
	lsl.l	d2,d0		
	cmpi.w	#4,d2
	bne.s	.vidare
	moveq	#-1,d2
	bra.s	.vidare
.no_falk
	mulu.w	#20,d0
.vidare
	subq.w	#1,d0
	move.l	physbase,a0
rensahelasytemsk„rmen2:
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	subq.l	#1,d0			; DBRA might be too small
	bpl.s	rensahelasytemsk„rmen2

	tst.w	falkrun
	bmi.s	.nofalk

.blade_falksetbackoldres
	move.w	#-1,-(sp)
	move.l	physbase,-(sp)
	move.l	logbase,-(sp)
	move.w	#5,-(sp)		; Gammalt bildminne
	trap	#14
	lea	12(sp),sp

	move.w	falkrez,-(sp)
	move.w	#88,-(sp)		; Gammal uppl”sning
	trap	#14
	addq.l	#4,sp
	bra.s	.vidare
.nofalk
	move.w	rez,-(sp)
	move.l	physbase,-(sp)
	move.l	logbase,-(sp)
	move.w	#5,-(sp)		; Gammal uppl”sning och bildminne
	trap	#14
	lea	12(sp),sp

.vidare
	tst.w	lownoise
	beq.s	intes„nkahuvudvolymeniinstall
	move.w	#$07ff,$ffff8924.w
	move.w	#%10011000000,$ffff8922.w
intes„nkahuvudvolymeniinstall:

	move.w	oldrept,-(sp)
	move.w	olddela,-(sp)
	move.w	#35,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	#$8240,a1
	lea	oldcol,a0		; Ladda upp f„rgerna
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	sub.w	#16,x
	move.l	linea,a0		; Ladda upp pekaren till lineaa
	tst.w	rez
	beq.s	„rredanl†g2
	lsl.w	x
„rredanl†g2:
	move.w	x,oldx
	move.w	y,oldy	
	move.w	oldx,-602(a0)		; Gammal xmuskoordinat
	move.w	oldy,-600(a0)		; Gammal ymuskoordinat
	move.w	oldx,-344(a0)		; Gammal xmuskoordinat
	move.w	oldy,-342(a0)		; Gammal ymuskoordinat

	dc.w	$a009

	move.b	oldscreenfreq,$ffff820a.w

	move.l	sp,dummen
	move.l	oldstack,-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa tebax till user
	addq.l	#6,sp

	moveq	#2,d1		; Till†t GEM att uppdatera sk„rmen igen
	jsr	wind_update

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa upp i super
	addq.l	#6,sp
	move.l	dummen,sp

	rts

;================================== Ta reda p† alla gamla inst„llningar ==

getallsysteminfo:
	move.w	#2,-(sp)
	trap	#14			; Ta reda p† fysikaliska bildminnet
	addq.l	#2,sp
	move.l	d0,physbase
	move.l	d0,kanal23rutin
	move.l	d0,kanal67rutin
	add.l	#16000,kanal67rutin

	move.w	#3,-(sp)
	trap	#14			; Ta reda p† logiska bildminnet
	addq.l	#2,sp
	move.l	d0,logbase

	move.b	$ffff820a.w,oldscreenfreq

	move.w	#4,-(sp)
	trap	#14			; Ta reda p† uppl”sning
	addq.l	#2,sp
	move.w	d0,rez

	move.w	#-1,-(sp)
	move.w	#-1,-(sp)
	move.w	#35,-(sp)
	trap	#14
	addq.l	#6,sp
	move.b	d0,oldrept+1
	lsr.l	#8,d0
	move.b	d0,olddela+1

	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#16,-(sp)		; Systemets tangentbords-
	trap	#14			; konverteringstabeller
	lea	14(sp),sp
	move.l	d0,tableofkeys

	move.w	#34,-(sp)
	trap	#14			; Ta reda p† vart systemets
	addq.w	#2,sp
	add.l	#$20,d0
	move.l	d0,a0			; MIDIhanterare finns
	move.l	(a0),MIDI+2

	move.l	$68.w,oldIPL2
	move.l	$456.w,oldvbls
	move.w	$454.w,oldnumofvbls
	move.l	$404.w,criticalerrorhandler	; Critical error handler
	move.w	$484.w,keyklick		; Keyklick
	move.l	$70.w,oldvbl		; VBL
	move.l	$120.w,oldhbl		; HBL
	move.l	$118.w,oldkeyboard	; Keyboard
	move.l	$114.w,oldc		; Timer C
	move.l	$11c.w,old7
	move.l	$110.w,oldd
	move.l	$100.w,oldcent
	move.l	$124.w,old9
	move.l	$128.w,old10
	move.l	$12c.w,old11
	move.l	$130.w,old12
	move.l	$134.w,old13
	move.l	$138.w,old14
	move.l	$13c.w,old15
	lea	vbls,a1
	move.l	$456.w,a0
	move.w	$454.w,d0
	subq.w	#1,d0
koppaktuellatjommar:
	tst.l	(a0)
	beq.s	kllllllllart
	move.l	(a0)+,(a1)+
	dbra	d0,koppaktuellatjommar
kllllllllart:
	move.l	#vbl,(a1)+

	move.w	#$8240,a0
	lea	oldcol,a1		; Spar undan f„rgerna
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	dc.w	$a000
	move.l	a0,linea		; Spar undan pekaren till lineaa
	move.w	-602(a0),oldx		; Gammal xmuskoordinat
	move.w	-600(a0),oldy		; Gammal ymuskoordinat
	move.w	-12(a0),oldw		; Gammal sk„rmvidd
	move.w	-4(a0),oldh		; Gammal sk„rmh”jd
	move.w	(a0),oldplanes		; Gamla antal bitplanes
	move.w	2(a0),oldwinbytes	; Gamla bytes/rasterrad
	move.w	#$22,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,a0
	lea	$10(a0),a0
;	move.l	a0,pointmouse
;	move.l	(a0),oldmouse

onlyrts:
	rts

oldscreenfreq:
	dc.w	0

;======================================================== Spriterutiner ==

;gor2planes1616mask:	; a0  spritebuff     d7 length
;			; OBS! Se till att spriten har 2 bytes tomma 
;			; efter varje rads 16 pixlar!!!!! Spriten skall ocks† ha 
;			; 4 bytes tomma f”rst!!!!
;	subq.w	#1,d7
;	clr.w	(a0)+	; 2 tomma bytes f”rst!
;maskcopy:
;	moveq	#0,d0
;	or.w	(a0)+,d0	; Fixa mask f”r 16 pixlar
;	or.w	(a0)+,d0
;	clr.w	(a0)+
;	move.w	d0,(a0)+	; Mask
;	dbra	d7,maskcopy
;	rts

v„ntap†blittret:
	btst.b	#7,$ffff8a3c.w
	bne.s	v„ntap†blittret
	rts

zx:	dc.w	0
zy:	dc.w	0

drawsprite2plane1616:	; a1 sorce adress	d0 x-coor     d1 y-coor
			; d7 length	d3 bildminne
	tst.w	d0
	bmi	ret2
	cmp.w	#336,d0
	bge	ret2
	tst.w	d1
	bmi	ret2
	cmp.w	#242,d1
	bge	ret2
	move.w	d0,zx
	move.w	d1,zy
	tst.l	fulleditorpek
	beq	den„rintep†slagenf”rmusen
	moveq	#0,d4
	move.w	lastpos,d4
	lsr.w	#5,d4			; Om fullsk„rmseditorn „r ig†ng
	add.w	d4,d4			; se till att r„tt del av
	lea	hurmycketaddera,a0	; sk„rmen visas
	move.w	(a0,d4.w),d4
	move.l	fulleditorpek,d3
	add.l	d4,d3
	addq.l	#2,d3
	lea	medmus,a1
	moveq	#0,d5
	addq.w	#8,d0
	sub.w	#16,d0
	bpl.s	ingenv„nsterklipptyp2
	add.w	#16,d0
	bne.s	jajahoppp†bara
	moveq	#1,d0
jajahoppp†bara:
	moveq	#-1,d5
	sub.l	#12,d3
ingenv„nsterklipptyp2:
	tst.w	d5
	bmi.s	ingenv„nsterklipptyp1
	subq.w	#8,d0
	bpl.s	ingenv„nsterklipptyp1
	addq.w	#8,d0
	moveq	#1,d5
	subq.l	#4,d3
ingenv„nsterklipptyp1:
	add.w	d0,d0
	move.w	d0,d2
	addq.l	#1,d1
	mulu	#160,d1
	add.l	d1,d3	; Addera y till adressen	; 8
	move.w	d0,d1					; 4
	and.w	#$f,d1	; delayen till d1		; 8
	and.l	#$fff0,d0				; 16
	lsr.w	#2,d0					; 8
	add.l	d0,d3	; Addera x till adressen	;+8 = 76
	move.l	d3,oldfulleditormouse
	move.l	d3,a0
	mulu	#96*2,d1
	add.w	d1,a1
	tst.w	d5
	beq	hittillsoklippt
	bmi	h†rdklippningv„nster
sl”v„nsterklippning:
	addq.w	#2,a1
	move.w	(a1)+,4(a0)
	move.w	(a1)+,8(a0)
	addq.w	#2,a1
	move.w	(a1)+,160+4(a0)
	move.w	(a1)+,160+8(a0)
	addq.w	#2,a1
	move.w	(a1)+,2*160+4(a0)
	move.w	(a1)+,2*160+8(a0)
	addq.w	#2,a1
	move.w	(a1)+,3*160+4(a0)
	move.w	(a1)+,3*160+8(a0)
	addq.w	#2,a1
	move.w	(a1)+,4*160+4(a0)
	move.w	(a1)+,4*160+8(a0)
	addq.w	#2,a1
	move.w	(a1)+,5*160+4(a0)
	move.w	(a1)+,5*160+8(a0)
	addq.w	#2,a1
	move.w	(a1)+,6*160+4(a0)
	move.w	(a1)+,6*160+8(a0)
	addq.w	#2,a1
	move.w	(a1)+,7*160+4(a0)
	move.w	(a1)+,7*160+8(a0)
	addq.w	#2,a1
	move.w	(a1)+,8*160+4(a0)
	move.w	(a1)+,8*160+8(a0)
	addq.w	#2,a1
	move.w	(a1)+,9*160+4(a0)
	move.w	(a1)+,9*160+8(a0)
	addq.w	#2,a1
	move.w	(a1)+,10*160+4(a0)
	move.w	(a1)+,10*160+8(a0)
	addq.w	#2,a1
	move.w	(a1)+,11*160+4(a0)
	move.w	(a1)+,11*160+8(a0)
	addq.w	#2,a1
	move.w	(a1)+,12*160+4(a0)
	move.w	(a1)+,12*160+8(a0)
	addq.w	#2,a1
	move.w	(a1)+,13*160+4(a0)
	move.w	(a1)+,13*160+8(a0)
	addq.w	#2,a1
	move.w	(a1)+,14*160+4(a0)
	move.w	(a1)+,14*160+8(a0)
	addq.w	#2,a1
	move.w	(a1)+,15*160+4(a0)
	move.w	(a1)+,15*160+8(a0)
	rts
h†rdklippningv„nster:
	addq.w	#4,a1
	move.w	(a1)+,8(a0)
	addq.w	#4,a1
	move.w	(a1)+,160+8(a0)
	addq.w	#4,a1
	move.w	(a1)+,2*160+8(a0)
	addq.w	#4,a1
	move.w	(a1)+,3*160+8(a0)
	addq.w	#4,a1
	move.w	(a1)+,4*160+8(a0)
	addq.w	#4,a1
	move.w	(a1)+,5*160+8(a0)
	addq.w	#4,a1
	move.w	(a1)+,6*160+8(a0)
	addq.w	#4,a1
	move.w	(a1)+,7*160+8(a0)
	addq.w	#4,a1
	move.w	(a1)+,8*160+8(a0)
	addq.w	#4,a1
	move.w	(a1)+,9*160+8(a0)
	addq.w	#4,a1
	move.w	(a1)+,10*160+8(a0)
	addq.w	#4,a1
	move.w	(a1)+,11*160+8(a0)
	addq.w	#4,a1
	move.w	(a1)+,12*160+8(a0)
	addq.w	#4,a1
	move.w	(a1)+,13*160+8(a0)
	addq.w	#4,a1
	move.w	(a1)+,14*160+8(a0)
	addq.w	#4,a1
	move.w	(a1)+,15*160+8(a0)
	rts
hittillsoklippt:
	cmp.w	#640-17,d2
	bls.s	klippkanskeinteh”ger
	move.w	(a1)+,(a0)
	addq.w	#4,a1
	move.w	(a1)+,160(a0)
	addq.w	#4,a1
	move.w	(a1)+,2*160(a0)
	addq.w	#4,a1
	move.w	(a1)+,3*160(a0)
	addq.w	#4,a1
	move.w	(a1)+,4*160(a0)
	addq.w	#4,a1
	move.w	(a1)+,5*160(a0)
	addq.w	#4,a1
	move.w	(a1)+,6*160(a0)
	addq.w	#4,a1
	move.w	(a1)+,7*160(a0)
	addq.w	#4,a1
	move.w	(a1)+,8*160(a0)
	addq.w	#4,a1
	move.w	(a1)+,9*160(a0)
	addq.w	#4,a1
	move.w	(a1)+,10*160(a0)
	addq.w	#4,a1
	move.w	(a1)+,11*160(a0)
	addq.w	#4,a1
	move.w	(a1)+,12*160(a0)
	addq.w	#4,a1
	move.w	(a1)+,13*160(a0)
	addq.w	#4,a1
	move.w	(a1)+,14*160(a0)
	addq.w	#4,a1
	move.w	(a1)+,15*160(a0)
	rts
klippkanskeinteh”ger:
	cmp.w	#640-32,d2
	bls	klippabsolutinteh”ger
	move.w	(a1)+,(a0)
	move.w	(a1)+,4(a0)
	addq.w	#2,a1
	move.w	(a1)+,160(a0)
	move.w	(a1)+,160+4(a0)
	addq.w	#2,a1
	move.w	(a1)+,2*160(a0)
	move.w	(a1)+,2*160+4(a0)
	addq.w	#2,a1
	move.w	(a1)+,3*160(a0)
	move.w	(a1)+,3*160+4(a0)
	addq.w	#2,a1
	move.w	(a1)+,4*160(a0)
	move.w	(a1)+,4*160+4(a0)
	addq.w	#2,a1
	move.w	(a1)+,5*160(a0)
	move.w	(a1)+,5*160+4(a0)
	addq.w	#2,a1
	move.w	(a1)+,6*160(a0)
	move.w	(a1)+,6*160+4(a0)
	addq.w	#2,a1
	move.w	(a1)+,7*160(a0)
	move.w	(a1)+,7*160+4(a0)
	addq.w	#2,a1
	move.w	(a1)+,8*160(a0)
	move.w	(a1)+,8*160+4(a0)
	addq.w	#2,a1
	move.w	(a1)+,9*160(a0)
	move.w	(a1)+,9*160+4(a0)
	addq.w	#2,a1
	move.w	(a1)+,10*160(a0)
	move.w	(a1)+,10*160+4(a0)
	addq.w	#2,a1
	move.w	(a1)+,11*160(a0)
	move.w	(a1)+,11*160+4(a0)
	addq.w	#2,a1
	move.w	(a1)+,12*160(a0)
	move.w	(a1)+,12*160+4(a0)
	addq.w	#2,a1
	move.w	(a1)+,13*160(a0)
	move.w	(a1)+,13*160+4(a0)
	addq.w	#2,a1
	move.w	(a1)+,14*160(a0)
	move.w	(a1)+,14*160+4(a0)
	addq.w	#2,a1
	move.w	(a1)+,15*160(a0)
	move.w	(a1)+,15*160+4(a0)
	rts
klippabsolutinteh”ger:
	move.w	(a1)+,(a0)
	move.w	(a1)+,4(a0)
	move.w	(a1)+,8(a0)
	move.w	(a1)+,160(a0)
	move.w	(a1)+,160+4(a0)
	move.w	(a1)+,160+8(a0)
	move.w	(a1)+,2*160(a0)
	move.w	(a1)+,2*160+4(a0)
	move.w	(a1)+,2*160+8(a0)
	move.w	(a1)+,3*160(a0)
	move.w	(a1)+,3*160+4(a0)
	move.w	(a1)+,3*160+8(a0)
	move.w	(a1)+,4*160(a0)
	move.w	(a1)+,4*160+4(a0)
	move.w	(a1)+,4*160+8(a0)
	move.w	(a1)+,5*160(a0)
	move.w	(a1)+,5*160+4(a0)
	move.w	(a1)+,5*160+8(a0)
	move.w	(a1)+,6*160(a0)
	move.w	(a1)+,6*160+4(a0)
	move.w	(a1)+,6*160+8(a0)
	move.w	(a1)+,7*160(a0)
	move.w	(a1)+,7*160+4(a0)
	move.w	(a1)+,7*160+8(a0)
	move.w	(a1)+,8*160(a0)
	move.w	(a1)+,8*160+4(a0)
	move.w	(a1)+,8*160+8(a0)
	move.w	(a1)+,9*160(a0)
	move.w	(a1)+,9*160+4(a0)
	move.w	(a1)+,9*160+8(a0)
	move.w	(a1)+,10*160(a0)
	move.w	(a1)+,10*160+4(a0)
	move.w	(a1)+,10*160+8(a0)
	move.w	(a1)+,11*160(a0)
	move.w	(a1)+,11*160+4(a0)
	move.w	(a1)+,11*160+8(a0)
	move.w	(a1)+,12*160(a0)
	move.w	(a1)+,12*160+4(a0)
	move.w	(a1)+,12*160+8(a0)
	move.w	(a1)+,13*160(a0)
	move.w	(a1)+,13*160+4(a0)
	move.w	(a1)+,13*160+8(a0)
	move.w	(a1)+,14*160(a0)
	move.w	(a1)+,14*160+4(a0)
	move.w	(a1)+,14*160+8(a0)
	move.w	(a1)+,15*160(a0)
	move.w	(a1)+,15*160+4(a0)
	move.w	(a1)+,15*160+8(a0)
	rts
den„rintep†slagenf”rmusen:
	move.w	d0,d2
	mulu	#168,d1
	add.l	d1,d3	; Addera y till adressen	; 8
	move.w	d0,d1					; 4
	and.w	#$f,d1	; delayen till d1		; 8
	and.l	#$fff0,d0				; 16
	lsr.w	#1,d0					; 8
	add.l	d0,d3	; Addera x till adressen	;+8 = 76
	move.l	d3,removeer
	move.l	d3,a0
	lsl.w	#7,d1
	add.w	d1,a1
	cmp.w	#320,d2
	bls.s	inteenklippningpagang
	move.l	(a1)+,(a0)
	addq.w	#4,a1
	move.l	(a1)+,168(a0)
	addq.w	#4,a1
	move.l	(a1)+,168*2(a0)
	addq.w	#4,a1
	move.l	(a1)+,168*3(a0)
	addq.w	#4,a1
	move.l	(a1)+,168*4(a0)
	addq.w	#4,a1
	move.l	(a1)+,168*5(a0)
	addq.w	#4,a1
	move.l	(a1)+,168*6(a0)
	addq.w	#4,a1
	move.l	(a1)+,168*7(a0)
	addq.w	#4,a1
	move.l	(a1)+,168*8(a0)
	addq.w	#4,a1
	move.l	(a1)+,168*9(a0)
	addq.w	#4,a1
	move.l	(a1)+,168*10(a0)
	addq.w	#4,a1
	move.l	(a1)+,168*11(a0)
	addq.w	#4,a1
	move.l	(a1)+,168*12(a0)
	addq.w	#4,a1
	move.l	(a1)+,168*13(a0)
	addq.w	#4,a1
	move.l	(a1)+,168*14(a0)
	addq.w	#4,a1
	move.l	(a1)+,168*15(a0)
	tst.l	editorpek
	bne	rita640mus
	rts
inteenklippningpagang:
	move.l	(a1)+,(a0)
	move.l	(a1)+,8(a0)
	move.l	(a1)+,168(a0)
	move.l	(a1)+,168+8(a0)
	move.l	(a1)+,168*2(a0)
	move.l	(a1)+,168*2+8(a0)
	move.l	(a1)+,168*3(a0)
	move.l	(a1)+,168*3+8(a0)
	move.l	(a1)+,168*4(a0)
	move.l	(a1)+,168*4+8(a0)
	move.l	(a1)+,168*5(a0)
	move.l	(a1)+,168*5+8(a0)
	move.l	(a1)+,168*6(a0)
	move.l	(a1)+,168*6+8(a0)
	move.l	(a1)+,168*7(a0)
	move.l	(a1)+,168*7+8(a0)
	move.l	(a1)+,168*8(a0)
	move.l	(a1)+,168*8+8(a0)
	move.l	(a1)+,168*9(a0)
	move.l	(a1)+,168*9+8(a0)
	move.l	(a1)+,168*10(a0)
	move.l	(a1)+,168*10+8(a0)
	move.l	(a1)+,168*11(a0)
	move.l	(a1)+,168*11+8(a0)
	move.l	(a1)+,168*12(a0)
	move.l	(a1)+,168*12+8(a0)
	move.l	(a1)+,168*13(a0)
	move.l	(a1)+,168*13+8(a0)
	move.l	(a1)+,168*14(a0)
	move.l	(a1)+,168*14+8(a0)
	move.l	(a1)+,168*15(a0)
	move.l	(a1)+,168*15+8(a0)
	tst.l	editorpek
	bne.s	rita640mus
	rts

mm42:	dc.w	0

rita640mus:
	move.w	zx,d0
	move.w	zy,d1
	clr.w	mm42
	sub.w	#105,d1
	bpl.s	offfffffffffffk
	neg.w	d1
	move.w	#16*6,mm42
	cmp.w	#16,d1
	bge.s	skitskit
	mulu	#6,d1
	move.w	d1,mm42
skitskit:
	moveq	#0,d1
offfffffffffffk:
	moveq	#0,d4
	move.w	lastpos,d4
	lsr.w	#5,d4			; Om fullsk„rmseditorn „r ig†ng
	add.w	d4,d4			; se till att r„tt del av
	lea	hurmycketaddera2,a0	; sk„rmen visas
	move.w	(a0,d4.w),d4
	move.l	editorpek,d3
	subq.w	#4,d3
	add.l	d4,d3
	addq.l	#2,d3
	lea	medmus,a1
	moveq	#0,d5
	addq.w	#8,d0
	sub.w	#16,d0
	bpl.s	ingenv„nsterklipptyp22
	add.w	#16,d0
	bne.s	jajahoppp†bara2
	moveq	#1,d0
jajahoppp†bara2:
	moveq	#-1,d5
	sub.l	#12,d3
ingenv„nsterklipptyp22:
	tst.w	d5
	bmi.s	ingenv„nsterklipptyp12
	subq.w	#8,d0
	bpl.s	ingenv„nsterklipptyp12
	addq.w	#8,d0
	moveq	#1,d5
	subq.l	#4,d3
ingenv„nsterklipptyp12:
	add.w	d0,d0
	move.w	d0,d2
	addq.l	#1,d1
	mulu	#160,d1
	add.l	d1,d3	; Addera y till adressen	; 8
	move.w	d0,d1					; 4
	and.w	#$f,d1	; delayen till d1		; 8
	and.l	#$fff0,d0				; 16
	lsr.w	#2,d0					; 8
	add.l	d0,d3	; Addera x till adressen	;+8 = 76

	tst.l	fulleditorpek
	bne.s	.vidare
	tst.w	falkrun
	bne.s	.vidare
	addq.l	#2,d3				; ()()() Fixar s† att musen hamnar p† r„tt bitplan

	tst.w	VGArun
	beq.s	.vidare
	addq.l	#4,d3		; addera extra pga RGB-felet!!!
.vidare
	move.l	d3,oldfulleditormouse
	move.l	d3,a0
	mulu	#96*2,d1
	add.w	mm42,a1
	add.w	d1,a1
	tst.w	d5
	beq	hittillsoklippt
	bmi	h†rdklippningv„nster
	bra	sl”v„nsterklippning

;	moveq	#-40,d0 		; $80+$40
;	move.w	d1,d5
;	add.w	d1,d1
;	cmp.w	#320,d2
;	bls.s	inteenklippningpagang
;	move.w	32(a3,d1.w),$ffff8a2c.w ; Fixa till startmasken
;	bra.s	korstenhart
;inteenklippningpagang:
;	move.w	#$ffff,$ffff8a2c.w
;korstenhart:
;	or.b	#%11000000,d5		; NFSR & FXSR
;	move.b	d5,$ffff8a3d.w		; Skew & NFSR & FXSR
;	move.l	d3,removeer	; Spar undan bildminnet f”r att jag
;				; skall kunna sudda det sedan
;
;	move.w	0(a3,d1.w),$ffff8a28.w	; Fixa till startmasken
;	move.w	#2,$ffff8a36.w		; X length (words)
;	move.w	#8,$ffff8a2e.w		; Dest add x (bytes)
;	move.w	#160,$ffff8a30.w	; Dest add y (bytes)
;	move.w	#2*2+2,$ffff8a22.w	; Sorce add y (bytes)
;	move.w	#2,$ffff8a20.w		; Sorce add x (bytes)
;	move.b	#$7,$ffff8a3b.w 	; Writing mode
;	move.l	a1,$ffff8a24.w		; Sorce adress
;	move.l	d3,$ffff8a32.w		; Dest adress
;	move.w	d7,$ffff8a38.w		; Y length
;	move.b	d0,$ffff8a3c.w		; Start blitter
;	bsr	v„ntap†blittret
;	addq.w	#2,d3
;	addq.w	#2,a1
;	move.l	a1,$ffff8a24.w		; Sorce adress
;	move.l	d3,$ffff8a32.w		; Dest adress
;	move.w	d7,$ffff8a38.w		; Y length
;	move.b	d0,$ffff8a3c.w		; Start blitter
;	bsr	v„ntap†blittret
;	move.w	#$FFFF,$ffff8a28.w	; Ingen startmask
;
;	rts

;===================================================== Playrutinrutiner ==

;------------------------------------------------------ Increment-table --
incrcal:
	move.w	#$30,d1
	move.w	#$039F-$30,d0

recalc: swap	d2
	moveq	#0,d3
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	swap	d4

	swap	d2
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	move.l	d4,(a0)+

	addq.w	#1,d1
	dbra	d0,recalc
	rts

;---------------------------------------- R„kna ut volymkontrollbuffern --

oldoldoldvol:
	dc.l	0

vol:	move.l	oldoldoldvol,d0
	cmp.l	mvol,d0
	beq.s	varf”rr„knavolion”dan
	move.l	bildminne,a0
	addq.w	#2,a0		; Ta bort VU-metrarna
	move.w	#104-1,d0
	moveq	#0,d1
tabortallaVUmetrarna34:
	move.w	d1,(a0)
	lea	168(a0),a0
	dbra	d0,tabortallaVUmetrarna34
	move.l	mvol,oldoldoldvol
	move.l	mvol,d3
makevilfaaaaaast:
	moveq	#64,d0
	lea	vtabend,a0

.ploop	move.w	#255,d1
.mloop	move.w	d1,d2
	ext.w	d2
	muls	d0,d2
	divs	d3,d2	 	       ; <---- Master volume
	move.b	d2,-(a0)
	dbra	d1,.mloop
	dbra	d0,.ploop
varf”rr„knavolion”dan:
	rts

;------------------------------------ H„r f”ljer all styring av musiken --

music:;	move.w	#$F00,$ffff8240.w
	tst.l	playplay
	beq	getnewfromshortes
	addq.w	#$01,counter		; Dax att g† fram ett steg i patternet?
	move.w	counter(pc),d0
	cmp.w	speed(pc),d0
	blt	getnewfromshortes	;nonew			; Nix, forts„tt att spela p† instrumenten
	clr.w	counter 		; Jepp, rensa
	clr.w	internalplay
	tst.b	mt_PattDelTime2
	beq	getnew
	subq.b	#1,mt_PattDelTime2
	beq	getnew
	bra	getnewfromshortes	; Fix och trixa med kommandon mm

nonew:	lea	voice1(pc),a4	; a4 Pekare till ? 
	lea	aud1lc(pc),a3	; a3 Pekare till sampling och div data om den
	lea	VU1,a5
	move.w	#76,termoretrig
	bsr	checkcom	; Testa kommandon
	lea	voice2(pc),a4
	lea	aud2lc(pc),a3
	lea	VU2,a5
	move.w	#88,termoretrig
	bsr	checkcom
	lea	voice3(pc),a4
	lea	aud3lc(pc),a3
	lea	VU3,a5
	move.w	#80,termoretrig
	bsr	checkcom
	lea	voice4(pc),a4
	lea	aud4lc(pc),a3
	lea	VU4,a5
	move.w	#84,termoretrig
	bsr	checkcom
	cmp.w	#4,antalkanaler
	beq.s	okgoagain
	lea	voice5(pc),a4
	lea	aud5lc(pc),a3
	lea	VU5,a5
	move.w	#92,termoretrig
	bsr	checkcom
	lea	voice6(pc),a4
	lea	aud6lc(pc),a3
	lea	VU6,a5
	move.w	#104,termoretrig
	bsr	checkcom
	cmp.w	#6,antalkanaler
	beq.s	okgoagain
	lea	voice7(pc),a4
	lea	aud7lc(pc),a3
	lea	VU7,a5
	move.w	#96,termoretrig
	bsr	checkcom
	lea	voice8(pc),a4
	lea	aud8lc(pc),a3
	lea	VU8,a5
	move.w	#100,termoretrig
	bsr	checkcom
okgoagain:
	tst.l	playplay
	bne.s	inteuppdateranuhar
	move.w	pattpos(pc),lastpos
	move.w	whichpatt(pc),lastsongpatt
inteuppdateranuhar:
	tst.w	g”rDMAtigen
	bne	setdma
	bra	endread 		; G”r slut p†'t

arpeggio:			; Kommando 0, arpeggio
	moveq	#0,d0
	move.w	counter,d0
	divs	#3,d0
	swap	d0
	cmp.w	#1,d0
	beq.s	pt_Arpeggio1
	cmp.w	#2,d0
	beq.s	pt_Arpeggio2
pt_Arpeggio0:
	move.w	$10(a4),d2
	bra.s	pt_ArpeggioSet
pt_Arpeggio1:
	moveq	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	bra.s	pt_ArpeggioFind
pt_Arpeggio2:
	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$F,d0
pt_ArpeggioFind:
	asl.w	#1,d0
	moveq	#0,d1
	move.b	18(a4),d1
	mulu	#37*2,d1
	lea	mt_PeriodTable,a0
	add.w	d1,a0
	moveq	#0,d1
	move.w	$10(a4),d1
	moveq	#$24,d7
pt_arploop:
	move.w	0(a0,d0.W),d2
	cmp.w	(a0),d1
	bhs.s	pt_ArpeggioSet
	addq.w	#2,a0
	dbra	d7,pt_arploop
	rts
pt_ArpeggioSet:
	move.w	d2,$06(a3)
	rts

				; Fixa n„sta position och tolka den
getnew:	move.w	pattpos(pc),lastpos
	moveq	#0,d0			; Fixa framstegningen i patternlistan
	move.b	songpos,d0
	lea	song,a1
	move.b	0(a1,d0.w),d0
	move.b	d0,whichpatt+1
	move.w	whichpatt(pc),lastsongpatt

	move.l	patterns,a0		; Pekare till aktuella pattern
	lea	modsam-8,a2		; Pekare till samplingar? +C!
;	lea	song,a1 		; Pekare till songdatan

	moveq	#0,d0
	moveq	#0,d1
	move.b	songpos(pc),d0		; d0 vart i songen vi ligger
	move.b	0(a1,d0.w),d1		; Vilket pattern skall spelas nu?
	lsl.l	#8,d1			; *  2048
	lsl.l	#3,d1
	add.w	pattpos(pc),d1		; Addera vart i patternet vi ligger just nu
	clr.w	dmacon			; Ingen dmacon =  inga nya anslag „n d† l„nge
	bra	denspelarverkligen
getnewfromshortes:
	tst.l	shortpattern
	bne.s	hoppatytryckt
	tst.l	shortpattern+4
	bne.s	hoppatytryckt
	tst.l	shortpattern+8
	bne.s	hoppatytryckt
	tst.l	shortpattern+12
	bne.s	hoppatytryckt
	tst.l	shortpattern+16
	bne.s	hoppatytryckt
	tst.l	shortpattern+20
	bne.s	hoppatytryckt
	tst.l	shortpattern+24
	bne.s	hoppatytryckt
	tst.l	shortpattern+28
	bne.s	hoppatytryckt
	bra	nonew
hoppatytryckt:
	move.w	#1,internalplay
	clr.w	dmacon			; Ingen dmacon =  inga nya anslag „n d† l„nge
	moveq	#0,d1
	lea	shortpattern,a0
	tst.l	playplay
	bne.s	inteuppdateranuheller
	move.w	pattpos(pc),lastpos
	move.w	whichpatt(pc),lastsongpatt
inteuppdateranuheller:
	lea	modsam-8,a2		; Pekare till samplingsdatan
	lea	song,a1 		; Pekare till songdatan
	move.w	#1,cleartheshorty
denspelarverkligen:

	lea	aud1lc(pc),a3		; Pekare till samplingsdata
	lea	voice1(pc),a4		; Pekare till voiceinfon
	lea	VU1,a5
	move.w	#76,termoretrig
	bsr	playvoice		; Spela kanal
	lea	aud2lc(pc),a3		; G”r samma sak f”r resten av kanalerna
	lea	voice2(pc),a4
	lea	VU2,a5
	move.w	#88,termoretrig
	bsr	playvoice
	lea	aud3lc(pc),a3
	lea	voice3(pc),a4
	lea	VU3,a5
	move.w	#80,termoretrig
	bsr	playvoice
	lea	aud4lc(pc),a3
	lea	voice4(pc),a4
	lea	VU4,a5
	move.w	#84,termoretrig
	bsr.s	playvoice
	cmp.w	#4,antalkanaler
	beq	setdma
	lea	aud5lc(pc),a3
	lea	voice5(pc),a4
	lea	VU5,a5
	move.w	#92,termoretrig
	bsr.s	playvoice
	lea	aud6lc(pc),a3
	lea	voice6(pc),a4
	lea	VU6,a5
	move.w	#104,termoretrig
	bsr.s	playvoice
	cmp.w	#6,antalkanaler
	beq	setdma
	lea	aud7lc(pc),a3
	lea	voice7(pc),a4
	lea	VU7,a5
	move.w	#96,termoretrig
	bsr.s	playvoice
	lea	aud8lc(pc),a3
	lea	voice8(pc),a4
	lea	VU8,a5
	move.w	#100,termoretrig
	bsr.s	playvoice
	bra	setdma
				; Spela en kanal
playvoice:
	move.l	0(a0,d1.l),(a4) ; H„mta in kanalen till voice
	addq.l	#4,d1		; n„sta kanal i d1
	moveq	#0,d2
	move.b	$02(a4),d2
	and.b	#$F0,d2 	; Plocka ut om det finns n†gon instrument-data
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$F0,d0
	or.b	d0,d2
	tst.b	d2		; d2 vilket instrument 0-$1f
	beq.s	setregs 	; Inget nytt instrument?
	moveq	#0,d3
	lea	samplestarts(pc),a1	; Pekare till tabellen ”ver vart samplingarna b”rjar i minnet
	move.w	d2,d4		; d2 Instrument till d4
	subq.w	#$01,d2
	add.w	d2,d2
	add.w	d2,d2
	mulu	#$1E,d4		; R„tt offset f”r modulinstrumenten
	move.l	0(a1,d2.l),$04(a4)	; Pekare till sampling till voice
	move.w	0(a2,d4.l),$08(a4)	; L„ngden p† samplingen i bytes +22

	move.w	$02(a2,d4.l),$12(a4)	; Finetune + volym till voice	+24
					; Ingen looping h„r
	move.l	$04(a4),$0A(a4)		; Loopb”rjan till voice
	move.w	$06(a2,d4.l),$0E(a4)	; Loopl„ngd till voice
	move.l	$04(a2,d4.l),32(a4)	; Loopl„ngd till voice
	move.l	4(a4),d0
	add.l	32(a4),d0
	move.l	d0,44(a4)
	move.w	$12(a4),$08(a3) 	; voice-volym till aud
;	move.w	(a4),d0
;	and.w	#$0FFF,d0		; Finns det n†gon tonangivelse?
;	bne.s	setregs
	clr.l	48(a4)
setregs:move.w	(a4),d0
	and.w	#$0FFF,d0		; Finns det n†gon tonangivelse?
	beq	checkcom2		; Nix, kolla om det finns kommandon
	move.b	$02(a4),d0		; Effectkommando 3? (Slida till angiven ton?)
	and.b	#$0F,d0
	cmp.b	#$03,d0
	bne.s	setperiod		; Nix
	bsr	setmyport		; Jepp, slida p†
	bra	checkcom2		; Testa flera kommandon oxo

setperiod:			; S„tt frekvensen p† kanalen
	move.w	(a4),d0
	and.w	#$03FF,d0
	lea	superfastfinetune,a6
	moveq	#0,d6
	move.b	(a6,d0.w),d6
	moveq	#0,d7
	move.b	$12(a4),d7	; Finetunen
	mulu	#36*2,d7
	add.w	d6,d7
	lea	mt_PeriodTable,a6
	add.w	d7,a6
	move.w	(a6),$10(a4)

	move.w	$14(a4),d0
	move.w	d0,dmactrl

	BTST	#2,38(a4)
	BNE.S	mt_vibnoc
	CLR.B	$1b(a4)
mt_vibnoc:
	BTST	#6,38(a4)
	BNE.S	mt_trenoc
	CLR.B	37(a4)
mt_trenoc:

	move.l	$04(a4),(a3)
	move.w	$08(a4),$04(a3)
	move.w	2(a4),d0
	and.w	#$0FF0,d0
	cmp.w	#$0ED0,d0 ; Notedelay
	beq	checkcom2
	move.w	$14(a4),d0
	or.w	d0,dmacon
	move.l	48(a4),-132(a3)		; S„tt r„tt offset p† samplingen
	move.w	$10(a4),$06(a3)
	bra	checkcom2

setdma: move.w	dmacon,d0

	lea	AmigafrekvenstoTermodynfrekvens,a6
	move.l	currenttermody,a5
	move.l	(a5),a5

	btst	#0,d0			;-------------------
	beq.s	wz_nch1 		;
	move.l	aud1lc(pc),wiz1lc	; S„tt Wizcats uppspelare
	clr.w	mainwantzero
	move.b	aud1vol+1(pc),VU1+1
	moveq	#0,d1			; med data
	moveq	#0,d2			;
	move.w	aud1len(pc),d1		;
	move.l	voice1+32(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz1len		;
	move.l	d2,wiz1rpt		;
	clr.l	shortpattern

	tst.w	termodyonoff
	beq.s	wz_nch1		; Ladda TERMODYn med data
	move.l	aud1lc,d3		; Samplingspekare
	add.l	wiz1pos,d3
	move.l	d3,(0+12+(16*4))(a5)
	add.l	aud1lc,d1
	move.l	d1,(0+12+(2*16*4))(a5)	; Loopstart    d1
	move.l	d2,(0+12+(3*16*4))(a5)	; Loopl„ngd    d2

wz_nch1:btst	#1,d0			;
	beq.s	wz_nch2 		;
	move.l	aud2lc(pc),wiz2lc	;
	clr.w	mainwantzero
	move.b	aud2vol+1(pc),VU2+1
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud2len(pc),d1		;
	move.l	voice2+32(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz2len		;
	move.l	d2,wiz2rpt		;
	clr.l	shortpattern+4

	tst.w	termodyonoff
	beq.s	wz_nch2		; Ladda TERMODYn med data
	move.l	aud2lc,d3		; Samplingspekare
	add.l	wiz2pos,d3
	move.l	d3,(12+12+(16*4))(a5)
	add.l	aud2lc,d1
	move.l	d1,(12+12+(2*16*4))(a5)	; Loopstart    d1
	move.l	d2,(12+12+(3*16*4))(a5)	; Loopl„ngd    d2

wz_nch2:btst	#2,d0			;
	beq.s	wz_nch3 		;
	move.l	aud3lc(pc),wiz3lc	;
	clr.w	mainwantzero
	move.b	aud3vol+1(pc),VU3+1
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud3len(pc),d1		;
	move.l	voice3+32(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz3len		;
	move.l	d2,wiz3rpt		;
	clr.l	shortpattern+8

	tst.w	termodyonoff
	beq.s	wz_nch3		; Ladda TERMODYn med data
	move.l	aud3lc,d3		; Samplingspekare
	add.l	wiz3pos,d3
	move.l	d3,(4+12+(16*4))(a5)
	add.l	aud3lc,d1
	move.l	d1,(4+12+(2*16*4))(a5)	; Loopstart    d1
	move.l	d2,(4+12+(3*16*4))(a5)	; Loopl„ngd    d2


wz_nch3:btst	#3,d0			;
	beq.s	wz_nch4 		;
	move.l	aud4lc(pc),wiz4lc	;
	clr.w	mainwantzero
	move.b	aud4vol+1(pc),VU4+1
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud4len(pc),d1		;
	move.l	voice4+32(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz4len		;
	move.l	d2,wiz4rpt		;
	clr.l	shortpattern+12

	tst.w	termodyonoff
	beq.s	wz_nch4		; Ladda TERMODYn med data
	move.l	aud4lc,d3		; Samplingspekare
	add.l	wiz4pos,d3
	move.l	d3,(8+12+(16*4))(a5)
	add.l	aud4lc,d1
	move.l	d1,(8+12+(2*16*4))(a5)	; Loopstart    d1
	move.l	d2,(8+12+(3*16*4))(a5)	; Loopl„ngd    d2

wz_nch4:cmp.w	#4,antalkanaler
	beq	wz_nch8

	btst	#7,d0			;
	beq.s	wz_nch5 		;
	move.l	aud8lc(pc),wiz8lc	;
	clr.w	mainwantzero
	move.b	aud8vol+1(pc),VU8+1
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud8len(pc),d1		;
	move.l	voice8+32(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz8len		;
	move.l	d2,wiz8rpt		;
	clr.l	shortpattern+16

	tst.w	termodyonoff
	beq.s	wz_nch5		; Ladda TERMODYn med data
	move.l	aud8lc,d3		; Samplingspekare
	add.l	wiz8pos,d3
	move.l	d3,(24+12+(16*4))(a5)
	add.l	aud8lc,d1
	move.l	d1,(24+12+(2*16*4))(a5)	; Loopstart    d1
	move.l	d2,(24+12+(3*16*4))(a5)	; Loopl„ngd    d2

wz_nch5:btst	#4,d0			;
	beq.s	wz_nch6 		;
	move.l	aud5lc(pc),wiz5lc	;
	clr.w	mainwantzero
	move.b	aud5vol+1(pc),VU5+1
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud5len(pc),d1		;
	move.l	voice5+32(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz5len		;
	move.l	d2,wiz5rpt		;
	clr.l	shortpattern+20

	tst.w	termodyonoff
	beq.s	wz_nch6		; Ladda TERMODYn med data
	move.l	aud5lc,d3		; Samplingspekare
	add.l	wiz5pos,d3
	move.l	d3,(16+12+(16*4))(a5)
	add.l	aud5lc,d1
	move.l	d1,(16+12+(2*16*4))(a5)	; Loopstart    d1
	move.l	d2,(16+12+(3*16*4))(a5)	; Loopl„ngd    d2

wz_nch6:btst	#5,d0			;
	beq.s	wz_nch7 		;
	move.l	aud6lc(pc),wiz6lc	;
	clr.w	mainwantzero
	move.b	aud6vol+1(pc),VU6+1
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud6len(pc),d1		;
	move.l	voice6+32(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz6len		;
	move.l	d2,wiz6rpt		;
	clr.l	shortpattern+24

	tst.w	termodyonoff
	beq.s	wz_nch7		; Ladda TERMODYn med data
	move.l	aud6lc,d3		; Samplingspekare
	add.l	wiz6pos,d3
	move.l	d3,(28+12+(16*4))(a5)
	add.l	aud6lc,d1
	move.l	d1,(28+12+(2*16*4))(a5)	; Loopstart    d1
	move.l	d2,(28+12+(3*16*4))(a5)	; Loopl„ngd    d2

wz_nch7:btst	#6,d0			;
	beq.s	wz_nch8 		;
	move.l	aud7lc(pc),wiz7lc	;
	clr.w	mainwantzero
	move.b	aud7vol+1(pc),VU7+1
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud7len(pc),d1		;
	move.l	voice7+32(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz7len		;
	move.l	d2,wiz7rpt		;
	clr.l	shortpattern+28

	tst.w	termodyonoff
	beq.s	wz_nch8		; Ladda TERMODYn med data
	move.l	aud7lc,d3		; Samplingspekare
	add.l	wiz7pos,d3
	move.l	d3,(20+12+(16*4))(a5)
	add.l	aud7lc,d1
	move.l	d1,(20+12+(2*16*4))(a5)	; Loopstart    d1
	move.l	d2,(20+12+(3*16*4))(a5)	; Loopl„ngd    d2

wz_nch8:tst.w	g”rDMAtigen
	bne	endread
	tst.w	internalplay
	bne	endread
	tst.w	hoppa”veradderingendenh„rg†ngen
	bne.s	inteadderanu
	tst.b	mt_PattDelTime2
	bne.s	inteadderanu
	addi.w	#$20,pattpos
inteadderanu:
	clr.w	hoppa”veradderingendenh„rg†ngen
	tst.b	break
	bne.s	nex
	move.b	mt_PattDelTime,d0
	beq.s	senread
	move.b	d0,mt_PattDelTime2
	clr.b	mt_PattDelTime
senread:
	cmpi.w	#$0800,pattpos
	bne.s	endread
;	clr.w	mixison
	clr.w	laddaommedorginalpek
	clr.w	pattpos
nex4:	clr.b	break
	tst.w	patternplay
	bne.s	endread
	addq.b	#1,songpos
	andi.b	#$7F,songpos
	move.b	songpos(pc),d1
	cmp.b	songlength(pc),d1		;$03B6
	bne.s	endread
	move.w	#-1,extratime
set2:	move.b	songrestart(pc),songpos 	;$03B7
endread:tst.b	break
	bne.s	nex
	clr.w	dmacon
	clr.w	g”rDMAtigen
	rts
nex:	clr.w	mixison
	clr.w	laddaommedorginalpek
	tst.w	loopingpartofpatt
	beq.s	nex3
	move.w	newlooppattpos,pattpos
	move.b	newloopsongpos,songpos
	move.w	newloopwhichpatt,whichpatt
	clr.b	break
	move.b	mt_PattDelTime,d0
	beq.s	endread3
	move.b	d0,mt_PattDelTime2
	clr.b	mt_PattDelTime
endread3:
	rts
nex3:	sub.w	#$20,pattpos
	bra	nex4

setmyport:
	move.w	(a4),d2
	and.w	#$0FFF,d2
	move.w	d2,$18(a4)
	move.w	$10(a4),d0
	clr.b	$16(a4)
	cmp.w	d0,d2
	beq.s	clrport
	bge.s	rt
	move.b	#$01,$16(a4)
	rts

clrport:clr.w	$18(a4)
rt:	rts

myport: move.b	$03(a4),d0
	beq.s	myslide
	move.b	d0,$17(a4)
	clr.b	$03(a4)
myslide:tst.w	$18(a4)
	beq.s	rt
	moveq	#0,d0
	move.b	$17(a4),d0
	tst.b	$16(a4)
	bne.s	mysub
	add.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)

myok:	move.w	$10(a4),d2
	move.b	39(a4),d0
	and.b	#$0F,d0
	beq.s	pt_GlissSkip
	moveq	#0,d0
	move.b	$12(a4),d0
	mulu	#37*2,d0
	lea	mt_PeriodTable(PC),a0
	add.l	d0,a0
	moveq	#0,d0
pt_GlissLoop:
	cmp.w	0(a0,d0.w),d2
	bhs.s	pt_GlissFound
	addq.w	#2,d0
	cmp.w	#37*2,d0
	blo.s	pt_GlissLoop
	moveq	#35*2,d0
pt_GlissFound:
	move.w	0(a0,d0.w),d2
pt_GlissSkip:
	move.w	d2,$06(a3) 		;Set period
	rts

mysub:	sub.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	blt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)
	move.w	$10(a4),$06(a3)
	rts

vib:
	move.b	$03(a4),d0
	beq.s	vi
	move.b	$1a(a4),d2
	and.b	#$0F,d0
	beq.s	vibskip
	and.b	#$F0,d2
	or.b	d0,d2
vibskip:move.b	$03(a4),d0
	and.b	#$F0,d0
	beq.s	vibskip2
	and.b	#$0F,d2
	or.b	d0,d2
vibskip2:
	move.b	d2,$1A(a4)
vi:	move.b	$1B(a4),d0
	lea	sin(pc),a1
	lsr.w	#$02,d0
	and.w	#$1F,d0
	moveq	#0,d2
	move.b	38(a4),d2
	and.b	#$03,d2
	beq.s	vib_sin
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	vib_rampdown
	move.b	#255,d2
	bra.s	vib_set
vib_rampdown:
	tst.b	$1b(a4)
	bpl.s	vib_rampdown2
	move.b	#255,d2
	sub.b	d0,d2
	bra.s	vib_set
vib_rampdown2:
	move.b	d0,d2
	bra.s	vib_set
vib_sin:move.b	0(a1,d0.w),d2
vib_set:move.b	$1A(a4),d0
	and.w	#$0F,d0
	mulu	d0,d2
	lsr.w	#$07,d2
	move.w	$10(a4),d0
	tst.b	$1B(a4)
	bmi.s	vibmin
	add.w	d2,d0
	bra.s	vib2

vibmin: sub.w	d2,d0
vib2:	move.w	d0,$06(a3)
	move.b	$1A(a4),d0
	lsr.w	#$02,d0
	and.w	#$3C,d0
	add.b	d0,$1B(a4)
	rts

nopp:	move.w	$10(a4),$06(a3)
	rts

checkcom:
	bsr	pt_UpdateFunk
	move.w	$02(a4),d0	; Žr det ett effectkommando p† den h„r kanalen?
	and.w	#$0FFF,d0
	beq.s	nopp		; Nix
	move.b	$02(a4),d0	; Jepp, h„mta in vilket
	and.b	#$0F,d0 	; Plocka ut vilket kommando det „r
	tst.b	d0		; Inget h„r betyder arpeggio
	beq	arpeggio
	cmp.b	#$01,d0 	; Effectkommando 1, slida upp tonen
	beq	portup
	cmp.b	#$02,d0 	; Effectkommando 2, slida ner tonen
	beq	portdown
	cmp.b	#$03,d0 	; Effectkommando 3, slida mot ny not
	beq	myport
	cmp.b	#$04,d0 	; Effectkommando 4, Vibrato
	beq	vib
	cmp.b	#$05,d0 	; Effectkommando 5, Tone+vol slide
	beq	port_toneslide
	cmp.b	#$06,d0 	; Effectkommando 6, Vibrato+vol slide
	beq	vib_toneslide
	cmp.b	#$0E,d0
	beq	setallEcommands
SetBack:move.w	$10(a4),$06(a3) ; flytta period till aud
	cmp.b	#7,D0		; Effectkommando 7, Tremolo
	beq.s	mt_Tremolo
	cmp.b	#$0A,d0 	; Effectkommando A, slida volymen
	beq	volslide
ret2:	rts			; Slutjobbat

mt_Tremolo:			; n_tremolocmd +36
	move.b	3(a4),d0	; n_termolopos +37
	beq.s	mt_Tremolo2	; n_wavecontrol +38
	move.b	36(a4),d2
	and.b	#$0F,d0
	beq.s	mt_treskip
	and.b	#$F0,d2
	or.b	d0,d2
mt_treskip:
	move.b	3(a4),d0
	and.b	#$F0,d0
	beq.s	mt_treskip2
	and.b	#$0F,d2
	or.b	d0,d2
mt_treskip2:
	move.b	d2,36(a4)
mt_Tremolo2:
	move.b	37(a4),D0
	lea	sin(pc),a6	; a4 -> a6!
	lsr.w	#2,d0
	and.w	#$001F,d0
	moveq	#0,d2
	move.b	38(a4),d2
	lsr.b	#4,d2
	and.b	#$03,d2
	beq.s	mt_tre_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	mt_tre_rampdown
	move.b	#255,d2
	bra.s	mt_tre_set
mt_tre_rampdown:
	tst.b	37(a4)
	bpl.s	mt_tre_rampdown2
	move.b	#255,d2
	sub.b	d0,d2
	bra.s	mt_tre_set
mt_tre_rampdown2:
	move.b	d0,d2
	bra.s	mt_tre_set
mt_tre_sine:
	move.b	0(a6,d0.w),d2
mt_tre_set:
	move.b	36(a4),d0
	and.w	#15,d0
	mulu	d0,d2
	lsr.w	#6,d2
	moveq	#0,d0
	move.b	$13(a4),d0	; Volym
	tst.b	37(a4)
	bmi.s	mt_TremoloNeg
	add.w	d2,d0
	bra.s	mt_Tremolo3
mt_TremoloNeg:
	sub.w	d2,d0
mt_Tremolo3:
	bpl.s	mt_TremoloSkip
	moveq	#0,d0
mt_TremoloSkip:
	cmp.w	#$40,d0
	bls.s	mt_TremoloOk
	moveq	#$40,d0
mt_TremoloOk:
	move.b	d0,9(a3)
	move.b	36(a4),d0
	lsr.w	#2,d0
	and.w	#$003C,d0
	add.b	d0,37(a4)
	rts


volslide:			; Kommando A
	moveq	#0,d0
	move.b	$03(a4),d0	; Ta reda p† om den skall slida upp eller ner volymen
	lsr.b	#4,d0
	tst.b	d0
	beq.s	voldown
mt_VolSlideUp:
	add.b	d0,$13(a4)	; Slida upp volymen s† mycket som anges
	cmpi.b	#$40,$13(a4)	; full volym redan?
	bmi.s	vol2
	move.b	#$40,$13(a4)	; S„tt full volym
vol2:	move.w	$12(a4),$08(a3) ; S„tt volymen till aud
	move.b	$13(a4),1(a5)
	rts

voldown:moveq	#0,d0		; Tona ner volymen	A
	move.b	$03(a4),d0
	and.b	#$0F,d0
mt_VolSlideDown2:
	sub.b	d0,$13(a4)	; Minska volymen
	bpl.s	vol3
	clr.b	$13(a4) 	; S„tt till 0
vol3:	move.w	$12(a4),$08(a3) ; S„tt volymen till aud
	move.b	$13(a4),1(a5)
	rts

portup: moveq	#0,d0		; Kommando 1
	move.b	$03(a4),d0	; H„mta antal slidsteg
portupfast:
	sub.w	d0,$10(a4)	; Slida upp tonen
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$71,d0 	; H”sta tonen redan?
	bpl.s	por2
	andi.w	#$F000,$10(a4)
	ori.w	#$71,$10(a4)	; S„tt h”gsta ton isf
por2:	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)	; Ny period (ton = period)
	rts

port_toneslide:
	bsr	myslide
	bra	volslide

vib_toneslide:
	bsr	vi
	bra	volslide

portdown:
	moveq	#0,d0
	move.b	$03(a4),d0
portdownfast:
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$0358,d0
	bmi.s	por3
	andi.w	#$F000,$10(a4)
	ori.w	#$0358,$10(a4)
por3:	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

checkcom2:		; Fler kommandon...
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$09,d0		; Effectkommando 9, sample offset
	beq.s	setsampleoffset
	cmp.b	#$0D,d0 	; Effectkommando D, hoppa till n„sta pattern
	beq.s	pattbreak
	cmp.b	#$0B,d0 	; Effectkommando B, hoppa till angivet pattern
	beq.s	posjmp
	cmp.b	#$0C,d0 	; Effectkommando C, s„tt volym
	beq	setvol
	cmp.b	#$0E,d0
	beq	setallEcommands
	cmp.b	#$0F,d0 	; Effectkommando F, s„tt fart
	beq	setspeed
	rts


setsampleoffset:
	moveq	#0,d0
	moveq	#0,d7
	move.b	$03(a4),d0
	beq.s	inteennysampleoffset
	move.b	d0,12(a3)
inteennysampleoffset:
	move.b	12(a3),d0
	beq.s	skitideth„rihuvudtaget
	lsl.l	#8,d0			; * 256
	moveq	#0,d7
	move.w	8(a4),d7
	add.l	32(a4),d7
	cmp.l	d7,d0
	bge.s	skitideth„rihuvudtaget
	add.l	d0,48(a4)
	move.w	dmacon,d7
	move.w	20(a4),d6
	and.w	d6,d7
	bne.s	redansatts„ttoffsettendirekt
	rts
redansatts„ttoffsettendirekt:
	move.l	d0,-132(a3)
skitideth„rihuvudtaget:
	rts


pattbreak:			; Kommando D, n„sta pattern
	moveq	#0,d0
	move.b	$03(a4),d0
	cmp.w	#$3f,d0
	ble.s	intemaxatpattern
	moveq	#$3f,d0
intemaxatpattern:
	mulu	#32,d0
	move.w	d0,pattpos
	st	break
	rts

posjmp:	move.b	$03(a4),d0	; Kommando B, hoppa till angivet pattern
	subq.b	#$01,d0
	cmp.b	songpos,d0
	bgt.s	intestannatiden
	move.w	#-1,extratime
intestannatiden:
	move.b	d0,songpos	; L„gg det nya pattert i songpos
	clr.w	pattpos
	st	break
	rts

setvol: moveq	#0,d0		; Kommando C, s„tt volym
	move.b	$03(a4),d0
	cmp.w	#$40,d0 	; Full volym?
	bmi.s	vol4
	move.b	#$40,$03(a4)	; S„tt full volym
vol4:	move.b	$03(a4),$09(a3) ; S„tt volym i aud
	move.b	$03(a4),$13(a4) ; S„tt volym i voice
	move.b	$03(a4),1(a5)
	rts

setspeed:			; Kommando F, s„tt fart
	moveq	#0,d0
	move.b	$03(a4),d0
	beq.s	rts2
	clr.w	counter 	; Rensa counter
	cmp.b	#$1f,d0
	bhi.s	det„rentempos„ttning
	move.w	d0,speed	; S„tt fart
rts2:	rts
det„rentempos„ttning:
	move.b	d0,tempo+1
	move.l	#125*125,d7
	divu	d0,d7		; S„tt s† att det blir r„tt tempov„rden
	move.l	d7,d6
	mulu	#100,d7
	move.l	d7,tempoadder
	swap	d6
	mulu	#100,d6
	divu	d0,d6
	and.l	#$FFFF,d6
	add.l	d6,tempoadder
	rts

usetempo:
	dc.w	-1	; Tempo    0 p†      -1 av
tempo:	dc.w	125	; Tempo i BPM, 125 default
tempor„knare:
	dc.l	0
tempoadder:
	dc.l	12500	; 125,00 default

setBPMonoff:
	tst.w	termodyonoff
	beq.s	bahingenspelarallts†deninterna
	move.l	currenttermody,a0
	tst.l	(a0)
	beq.s	bahingenspelarallts†deninterna
	move.l	(a0),a6
	tst.w	356(a6)
	bpl.s	bahingenspelarallts†deninterna
	lea	notempo1,a5		; Meddela att denna spelar inte
	lea	notempo2,a6		; fungerar med tempokontroll
	jsr	makejeppform
	rts
bahingenspelarallts†deninterna:
	move.l	bildminne,a0
	lea	((39*168)+112)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#1-1,d7 		; 1 byte vidd p† notten
	jsr	makeinversjamn

	moveq	#0,d0
	move.w	tempo,d0
	bsr	det„rentempos„ttning
	not.w	usetempo

	move.l	currenttermody,a0
	tst.l	(a0)
	beq.s	intevaltermodyatt125st„lla
	move.l	(a0),a0
	tst.w	356(a0)
	bmi.s	intevaltermodyatt125st„lla
	move.w	#125,356(a0)
intevaltermodyatt125st„lla:

	rts


setallEcommands:
	moveq	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	cmp.b	#1,d0
	beq	mt_FinePortaUp
	cmp.b	#2,d0
	beq	mt_FinePortaDown
	cmp.b	#3,d0
	beq	pt_SetGlissControl
	cmp.b	#4,d0
	beq	setvibcontrol
	cmp.b	#5,d0
	beq	setfinetune
	cmp.b	#6,d0
	beq.s	startloopingpattern
	cmp.b	#7,d0
	beq	settremolocontrol
	cmp.b	#9,d0
	beq	mt_RetrigNote
	cmp.b	#$A,d0
	beq	mt_VolumeFineUp
	cmp.b	#$B,d0
	beq	mt_VolumeFineDown
	cmp.b	#$C,d0
	beq	notecut
	cmp.b	#$D,d0
	beq	mt_NoteDelay
	cmp.b	#$E,d0
	beq	mt_PatternDelay
	cmp.b	#$F,d0
	beq	pt_FunkIt
	bra	SetBack

startloopingpattern:
	tst.w	counter
	bne	ret2
	move.b	$03(a4),d0
	and.w	#$000F,d0
	beq.s	setloopinpattern
	tst.w	loopingpartofpatt
	beq.s	detta„rf”rstag†ngenipattloopen
	subq.w	#1,loopingpartofpatt
	beq.s	detvarsistaloopingen
	st	break
detvarsistaloopingen:
	rts
detta„rf”rstag†ngenipattloopen:
	move.w	d0,loopingpartofpatt
	st	break
	rts

setloopinpattern:
	tst.w	loopingpartofpatt
	bne.s	intes„ttapattloopen
	move.w	lastpos,newlooppattpos
	move.b	songpos,newloopsongpos
	move.w	lastsongpatt,newloopwhichpatt
intes„ttapattloopen:
	rts

loopingpartofpatt:
	dc.w	0
newlooppattpos:
	dc.w	0
newloopsongpos:
	dc.b	0,0
newloopwhichpatt:
	dc.w	0
termoretrig:
	dc.w	0

mt_RetrigNote:
	moveq	#0,d0
	move.b	$03(a4),d0
	and.w	#$0F,d0
	beq.s	mt_rtnend
	moveq	#0,d7
	move.w	counter,d7
	bne.s	mt_rtnskp
	move.w	(a4),d7
	and.w	#$0FFF,d7
	bne.s	mt_rtnend
	moveq	#0,d7
	move.w	counter,d7
mt_rtnskp:
	divu	d0,d7
	swap	d7
	tst.w	d7
	bne.s	mt_rtnend
mt_DoRetrig:
	clr.l	-132(a3)
	move.l	a5,-(sp)
	move.l	currenttermody,a5
	tst.l	(a5)
	beq.s	mt_rtnend2
	move.l	(a5),a5
	add.w	termoretrig,a5
	move.l	4(a4),(a5)
mt_rtnend2:
	move.l	(sp)+,a5
mt_rtnend:
	rts

g”rDMAtigen:
	dc.w	0

pt_SetGlissControl:
	move.b	$03(a4),d0
	and.b	#$0F,d0
	and.b	#$F0,39(a4)
	or.b	d0,39(a4)
	rts

pt_FunkIt:
	tst.w	counter
	bne	ret2
	move.b	$03(a4),d0
	and.b	#$0F,d0
	lsl.b	#4,d0
	and.b	#$0F,39(a4)
	or.b	d0,39(a4)
	tst.b	d0
	beq	ret2
pt_UpdateFunk:
	movem.l	a0/d1,-(sp)
	moveq	#0,d0
	move.b	39(a4),d0
	lsr.b	#4,d0
	beq.s	pt_funkend
	lea	pt_FunkTable(pc),a0
	move.b	0(a0,d0.w),d0
	add.b	d0,40(a4)
	btst.b	#7,40(a4)
	beq.s	pt_funkend
	clr.b	40(a4)
	move.l	4(a4),d0
	moveq	#0,d1
	move.w	8(a6),d1
	add.l	d1,d0
	add.l	#1000,d0
	move.l	44(a4),a0
	addq.w	#1,a0
	cmp.l	d0,a0
	blo.s	pt_funkok
	move.w	14(a4),d1
	sub.l	d1,d0
	move.l	d0,a0
pt_funkok:
	move.l	a0,44(a4)
	moveq	#-1,d0
	sub.b	(a0),d0
	move.b	d0,(a0)
pt_funkend:
	movem.l	(sp)+,a0/d1
	rts

pt_FunkTable
	dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128


mt_NoteDelay:
	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	tst.w	counter
	beq	ret2
	cmp.b	counter+1,d0
	bne	ret2
	move.w	(a4),d0
	and.w	#$0FFF,d0
	beq	ret2
	move.w	$14(a4),d0
	or.w	d0,dmacon
	move.l	48(a4),-132(a3)		; S„tt r„tt offset p† samplingen
	move.w	$10(a4),$06(a3)
	move.w	#1,g”rDMAtigen
	bra	mt_DoRetrig

mt_PatternDelay:
	tst.w	counter
	bne	ret2
	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	tst.b	mt_PattDelTime2
	bne	ret2
	addq.b	#1,d0
	move.b	d0,mt_PattDelTime
	rts

mt_PattDelTime2:
	dc.b	0
mt_PattDelTime:
	dc.b	0

setfinetune:
	move.b	$03(a4),d0
	and.b	#$0F,d0
	move.b	d0,$12(a4) 	; S„tt till 0
	move.w	$12(a4),$08(a3) ; S„tt volymen till aud
	move.w	(a4),d0
	and.w	#$0FFF,d0
	lea	superfastfinetune,a6
	moveq	#0,d6
	move.b	(a6,d0.w),d6
	moveq	#0,d7
	move.b	$12(a4),d7	; Finetunen
	mulu	#36*2,d7
	add.w	d6,d7
	add.l	#mt_PeriodTable,d7
	move.l	d7,a6
	move.w	(a6),$10(a4)
	move.w	$10(a4),$06(a3)
	rts

setvibcontrol:
	move.b	3(a4),d0
	and.b	#$F,d0
	and.b	#$F0,38(a4)
	or.b	d0,38(a4)
	rts

notecut:moveq	#0,d0
	move.b	$03(a4),d0
	and.w	#$0F,d0
	cmp.w	counter,d0
	bne	ret2
	clr.b	$09(a3) ; S„tt volym i aud
	clr.b	$13(a4) ; S„tt volym i voice
	clr.b	1(a5)
	rts

settremolocontrol:
	move.b	3(a4),d0
	and.b	#$F,d0
	lsl.b	#4,d0
	and.b	#$0F,38(a4)
	or.b	d0,38(a4)
	rts

mt_VolumeFineUp:
	tst.w	counter
	bne	ret2
	moveq	#0,d0
	move.b	3(a4),d0
	and.b	#$F,d0
	bra	mt_VolSlideUp

mt_VolumeFineDown:
	tst.w	counter
	bne	ret2
	moveq	#0,d0
	move.b	3(a4),d0
	and.b	#$0F,d0
	bra	mt_VolSlideDown2

mt_FinePortaUp:
	tst.w	counter
	bne	ret2
	moveq	#0,d0
	move.b	3(a4),d0
	and.b	#$F,d0
	bra	portupfast

mt_FinePortaDown:
	tst.w	counter
	bne	ret2
	moveq	#0,d0
	move.b	3(a4),d0
	and.b	#$F,d0
	bra	portdownfast







mataintoner:			; Žnda p† antal toner via tang.bordet
	tst.w	termodyonoff		; Žr termody p† redan?
	bne.s	termodynp†slagen123
	move.b	termotones+1,numberin
	move.w	#2,numberlen
	move.w	#224,numberx
	move.w	#24,numbery
	bsr	enteranumber	; L†t anv„ndaren mata in ett v„rde
	moveq	#0,d0		; Minv„rde
	moveq	#50,d1		; Maxv„rde
	bsr	checkbounding	; Kolla storleken p† den
	move.w	d2,termotones
	jsr	skrivuthurm†ngabytes
termodynp†slagen123:
	rts


matainpos:		; Žnda p† position via tang.bordet
	tst.w	playplay
	bne.s	kaninte„ndrap†poseftersomplay„rp†
	move.w	#1,stoppprintingthat
	move.b	songpos,numberin
	move.w	#2,numberlen
	move.w	#64,numberx
	move.w	#06,numbery
	bsr	enteranumber	; L†t anv„ndaren mata in ett v„rde
	moveq	#0,d0		; Minv„rde
	move.b	songlength,d1
	and.l	#$FF,d1
	subq.w	#1,d1
	bsr	checkbounding	; Kolla storleken p† den
	move.b	d2,songpos
	moveq	#0,d0
	lea	song,a0
	move.b	songpos,d0
	add.l	d0,a0
	move.b	(a0),whichpatt+1
	lea	whichpatt+1,a3		; Vilket tal skall konverteras
	move.w	#64,d0			; x
	move.w	#16,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
kaninte„ndrap†poseftersomplay„rp†:
	clr.w	stoppprintingthat
	rts

mataintrack:		; Žnda p† tracket via tang.bordet
	tst.w	playplay
	bne.s	kaninte„ndrap†poseftersomplay„rp†2
	move.w	#1,stoppprintingthat
	move.b	whichpatt+1,numberin
	move.w	#2,numberlen
	move.w	#64,numberx
	move.w	#16,numbery
	bsr	enteranumber	; L†t anv„ndaren mata in ett v„rde
	moveq	#0,d0		; Minv„rde
	moveq	#0,d1
	move.w	maxpatterns,d1
	subq.w	#1,d1
	bsr	checkbounding	; Kolla storleken p† den
	move.b	d2,whichpatt+1
	moveq	#0,d0
	move.b	songpos,d0
	lea	song,a0
	add.l	d0,a0
	move.b	whichpatt+1,(a0)
kaninte„ndrap†poseftersomplay„rp†2:
	clr.w	stoppprintingthat
	rts

matainlength:		; Žnda p† length via tang.bordet
	move.b	songlength,numberin
	move.w	#2,numberlen
	move.w	#64,numberx
	move.w	#26,numbery
	bsr	enteranumber	; L†t anv„ndaren mata in ett v„rde
	moveq	#0,d0
	move.b	songpos,d0
	cmp.b	songrestart,d0
	bge.s	songposen„rst”rre
	move.b	songrestart,d0
songposen„rst”rre:
	addq.l	#1,d0
	move.l	#$80,d1		; Maxv„rde
	bsr	checkbounding	; Kolla storleken p† den
	move.b	d2,songlength
	rts


matainrestart:		; Žnda p† restart via tang.bordet
	move.b	songrestart,numberin
	move.w	#2,numberlen
	move.w	#64,numberx
	move.w	#36,numbery
	bsr	enteranumber	; L†t anv„ndaren mata in ett v„rde
	moveq	#0,d0		; Minv„rde
	moveq	#0,d1
	move.b	songlength,d1
	subq.w	#1,d1
	bsr	checkbounding	; Kolla storleken p† den
	move.b	d2,songrestart
	rts

matainsteps:		; Žnda p† steps via tang.bordet
	move.b	stepswhenpressing+1,numberin
	move.w	#2,numberlen
	move.w	#96,numberx
	move.w	#97,numbery
	bsr	enteranumber	; L†t anv„ndaren mata in ett v„rde
	moveq	#0,d0		; Minv„rde
	moveq	#$3f,d1		; Maxv„rde
	bsr	checkbounding	; Kolla storleken p† den
	move.w	d2,stepswhenpressing
	rts

matainnoppar:		; Žnda p† antalet noppar via tang.bordet
	move.b	bordercounter+1,numberin
	addq.b	#1,numberin
	move.w	#2,numberlen
	move.w	#281,numberx
	move.w	#38,numbery
	bsr	enteranumber	; L†t anv„ndaren mata in ett v„rde
	moveq	#3,d0		; Minv„rde
	move.l	#$FF,d1		; Maxv„rde
	bsr	checkbounding	; Kolla storleken p† den
	subq.w	#1,d2
	move.w	d2,bordercounter
	jsr	s„ttr„ttvidstartuppen
	rts

matainsample:
	move.b	whichsample+1,numberin
	move.w	#2,numberlen
	move.w	#64,numberx
	move.w	#49,numbery
	bsr	enteranumber	; L†t anv„ndaren mata in ett v„rde
	moveq	#0,d0		; Minv„rde
	moveq	#$1f,d1		; Maxv„rde
	bsr	checkbounding	; Kolla storleken p† den
	move.w	d2,whichsample
	jsr	skrivuttillhorandeinfo
	bsr	checkifsamplechanged
	rts

matainvolym:			; Mata in ny samplingsvolym
	tst.w	whichsample
	beq.s	inte„ndraeftersomdet„r0an14
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsam,d0
	move.l	d0,a5
	move.l	a5,-(sp)
	move.b	25(a5),numberin
	move.w	#2,numberlen
	move.w	#169,numberx
	move.w	#7,numbery
	bsr	enteranumber	; L†t anv„ndaren mata in ett v„rde
	moveq	#0,d0		; Minv„rde
	moveq	#$40,d1		; Maxv„rde
	bsr	checkbounding	; Kolla storleken p† den
	move.l	(sp)+,a5
	move.b	d2,25(a5)
	move.b	d2,32*30+25(a5)
inte„ndraeftersomdet„r0an14:
	rts


matainloopstart:		; Mata in ny samplingsstart
	tst.w	whichsample
	beq.s	inte„ndraeftersomdet„r0an15
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsamsave,d0
	move.l	d0,a5
	tst.w	22(a5)
	beq.s	inte„ndraeftersomdet„r0an15
	move.l	a5,-(sp)
	move.w	26(a5),numberin
	lsl.w	numberin
	move.w	#4,numberlen
	move.w	#153,numberx
	move.w	#37,numbery
	bsr	enteranumber	; L†t anv„ndaren mata in ett v„rde
	moveq	#0,d0		; Minv„rde
	move.l	(sp)+,a5
	moveq	#0,d1
	move.w	22(a5),d1
	sub.w	28(a5),d1
	add.l	d1,d1
	and.l	#$FFFE,d2
	move.w	d2,numberin
	bsr	checkbounding	; Kolla storleken p† den
	lsr.l	#1,d2
	move.w	d2,26(a5)
	jsr	s„ttloopstart
	jsr	skrivuttillhorandeinfo
inte„ndraeftersomdet„r0an15:
	rts


matainsamlength:		; Mata in ny samplingsl„ngd
	tst.w	whichsample
	beq	inte„ndraeftersomdet„r0an157
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsamsave,d0
	move.l	d0,a5
	tst.w	22(a5)
	beq.s	inte„ndraeftersomdet„r0an157
	move.l	a5,-(sp)
	move.w	22(a5),numberin
	move.w	numberin,gammall„ngd
	lsl.w	numberin
	move.w	#4,numberlen
	move.w	#153,numberx
	move.w	#27,numbery
	bsr	enteranumber	; L†t anv„ndaren mata in ett v„rde
	move.l	#$FFFE,d1	; Maxv„rde
	move.l	(sp)+,a5
	moveq	#0,d0		; Minv„rde
	move.w	26(a5),d0
	add.w	28(a5),d0
	add.l	d0,d0
	and.l	#$FFFE,d2
	move.w	d2,numberin
	bsr	checkbounding	; Kolla storleken p† den
	lsr.l	#1,d2
	move.w	d2,22(a5)
	jsr	s„ttsamlength
	jsr	skrivuttillhorandeinfo
inte„ndraeftersomdet„r0an157:
	rts


matainloopl„ngd:		; Mata in ny samplingsl„ngd
	tst.w	whichsample
	beq.s	inte„ndraeftersomdet„r0an16
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsamsave,d0
	move.l	d0,a5
	tst.w	22(a5)
	beq.s	inte„ndraeftersomdet„r0an16
	move.l	a5,-(sp)
	move.w	28(a5),numberin
	lsl.w	numberin
	move.w	#4,numberlen
	move.w	#153,numberx
	move.w	#47,numbery
	bsr	enteranumber	; L†t anv„ndaren mata in ett v„rde
	moveq	#2,d0		; Minv„rde
	move.l	(sp)+,a5
	moveq	#0,d1
	move.w	22(a5),d1
	sub.w	26(a5),d1
	add.l	d1,d1
	and.l	#$FFFE,d2
	move.w	d2,numberin
	bsr	checkbounding	; Kolla storleken p† den
	lsr.l	#1,d2
	move.w	d2,28(a5)
	jsr	s„ttlooplength
	jsr	skrivuttillhorandeinfo
inte„ndraeftersomdet„r0an16:
	rts


matainfinetune:			; Mata in ny finetune
	tst.w	whichsample
	beq	inte„ndraeftersomdet„r0an17
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsam,d0
	move.l	d0,a5
	move.l	a5,-(sp)
	move.w	#1,signed
	move.w	#2,numberlen
	move.w	#169,numberx
	move.w	#17,numbery
	moveq	#0,d0
	move.b	24(a5),d0
	add.b	d0,d0			; Skriv ut finetunen
	add.b	d0,d0
	add.l	#finetune,d0
	move.l	d0,a0
	move.l	(a0),numberstring
	bsr	enteranumber	; L†t anv„ndaren mata in ett v„rde
	clr.w	signed
	lea	finetune,a0
	lea	numberstring,a1
	moveq	#0,d2
	moveq	#16-1,d1
taframr„ttfinetune:
	move.w	(a0),d3
	cmp.w	(a1),d3
	beq.s	okhittatr„ttfinetune
	addq.w	#1,d2
	addq.w	#4,a0
	dbra	d1,taframr„ttfinetune
okhittatr„ttfinetune:
	move.l	(sp)+,a5
	move.b	d2,24(a5)
	move.b	d2,32*30+24(a5)
	jsr	skrivuttillhorandeinfo
inte„ndraeftersomdet„r0an17:
	rts


checkbounding:		; Rutinen som kollar gr„nserna
	sub.w	#16,numberx
	cmp.l	d2,d0
	blt.s	intemindre„nminst
	move.l	d0,d2
	move.l	d2,numberin
	move.l	d2,-(sp)
	lea	numberin+4,a3		; Vilket tal skall konverteras
	move	numberlen,d7
	lsr.w	#1,d7
	sub.w	d7,a3
	move.w	numberx,d0		; x
	move.w	numbery,d1		; y
	move.w	numberlen,d7 		; Hur m†nga siffror
	subq.w	#1,d7
	bsr	skrivuthex		; Skriv ut i hex
	move.l	(sp)+,d2
	rts
intemindre„nminst:
	cmp.l	d2,d1
	bgt.s	alltvarinomboundingen
	move.l	d1,d2
	move.l	d2,numberin
	move.l	d2,-(sp)
	lea	numberin+4,a3		; Vilket tal skall konverteras
	move	numberlen,d7
	lsr.w	#1,d7
	sub.w	d7,a3
	move.w	numberx,d0		; x
	move.w	numbery,d1		; y
	move.w	numberlen,d7 		; Hur m†nga siffror
	subq.w	#1,d7
	bsr	skrivuthex		; Skriv ut i hex
	move.l	(sp)+,d2
	rts
alltvarinomboundingen:
	move.l	d2,-(sp)
	lea	numberin+4,a3		; Vilket tal skall konverteras
	move	numberlen,d7
	lsr.w	#1,d7
	sub.w	d7,a3
	move.w	numberx,d0		; x
	move.w	numbery,d1		; y
	move.w	numberlen,d7 		; Hur m†nga siffror
	subq.w	#1,d7
	bsr	skrivuthex		; Skriv ut i hex
	move.l	(sp)+,d2
	rts

stoppprintingthat:
	dc.w	0
numberin:
	dc.l	$00000000
numberstring:
	dc.b	'+00000000',0
numberstring2:
	dc.b	'+00000000',0
numberlen:
	dc.w	0
numberx:dc.w	0
numbery:dc.w	0
signed:	dc.w	0	; Om 1:a till†ts ett plus/minustecken f”rst
godk„ndatal:
	dc.b	'0123456789ABCDEFabcdef',0
	even

enteranumber:
	add.w	#16,numberx
	bsr	calccursorplaceinnumber
	move.w	numberx,editx
	move.w	numbery,edity

	tst.w	signed
	bne.s	intekonv
	move.w	numberlen,d0
	lsr.w	#1,d0
	subq.w	#1,d0
	lea	numberstring,a0		; Konvertera hex->ASCIIhex
	lea	numberin,a1
	lea	godk„ndatal,a2
kontoasciihex:
	moveq	#0,d1
	move.b	(a1)+,d1
	move.l	d1,d2
	lsr.l	#4,d1
	and.l	#$F,d2
	move.b	(a2,d1.w),(a0)+
	move.b	(a2,d2.w),(a0)+
	dbra	d0,kontoasciihex
	clr.b	(a0)+
intekonv:

	move.l	numberstring,numberstring2
	move.l	numberstring+4,numberstring2+4
	move.w	numberstring+8,numberstring2+8


	move.w	#$8240,a0
	lea	extracol,a1		; Spara f„rgerna
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.w	#$8240,a1
	lea	texteditpalette,a0	; Ladda upp f„rgerna
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	clr.w	cursorblink
	move.w	#1,cursoronoff		; S„tt p† cursorn
	jsr	waittwovbls

huvudtexteditloop2:
	btst.b	#0,mkey			; H”ger musknapp nertryckt?
	bne	enreturnhoppaureditmoden2

	jsr	testas†oftasomm”jligt	; Skriv ut tid o patternpos.
	jsr	ritapatternettrashat

	bsr	isakeyready
	beq.s	huvudtexteditloop2
	bsr	getkeywithasciiandshifts
	move.l	d0,d7

	swap	d7

	cmp.b	#$4b,d7			; V„nster
	bne.s	inte†tv„nstermedcursor2
	tst.w	cursor
	ble.s	inte†tv„nstermedcursor2
	subq.w	#1,cursor
	bra	skrivutdet„nd†2
inte†tv„nstermedcursor2:
	cmp.b	#$4d,d7			; H”ger
	bne.s	inte†th”germedcursor2
	move.w	cursor,d0
	addq.w	#1,d0
	cmp.w	numberlen,d0
	bge.s	inte†th”germedcursor2
	lea	numberstring,a0
	add.w	cursor,a0
	cmp.b	#'+',(a0)
	beq.s	det„rdenf”rstadelen
	cmp.b	#'-',(a0)
	beq.s	det„rdenf”rstadelen
	cmp.b	#'0',(a0)
	blt	skrivutdet„nd†2
	cmp.b	#'9',(a0)
	ble.s	det„rdenf”rstadelen
	cmp.b	#'A',(a0)
	blt	skrivutdet„nd†2
	cmp.b	#'F',(a0)
	bgt	skrivutdet„nd†2
det„rdenf”rstadelen:
	addq.w	#1,cursor
	bra	skrivutdet„nd†2
inte†th”germedcursor2:
	cmp.b	#$e,d7			; Backspace
	bne.s	inteenbackspaceistr„ngen2
	tst.w	cursor
	beq.s	inteenbackspaceistr„ngen2
	move.w	cursor,d0
	cmp.w	numberlen,d0
	bge.s	befinnersigp†max2
	subq.w	#1,cursor
	bra.s	deleteskitennu2
befinnersigp†max2:		; Om l„ngst ut till h”ger i str„ngen,
	subq.w	#1,cursor	; f”r d† bara in en space
	lea	numberstring,a0
	add.w	numberlen,a0
	clr.b	(a0)
	move.b	#' ',-1(a0)
	bra	skrivutdet„nd†2
inteenbackspaceistr„ngen2:
	cmp.b	#$53,d7			; Delete
	bne.s	inteendeleteistr„ngen2
deleteskitennu2:
	move.w	cursor,d0
	move.w	numberlen,d1
	sub.w	d0,d1
	subq.w	#1,d1
	ble.s	safasdfasdfasdf
	subq.w	#1,d1
	lea	numberstring,a0
	add.w	cursor,a0
koppastr„ngen†tv„nster2:
	move.b	1(a0),(a0)
	addq.w	#1,a0				; Flytta det som „r †t h”ger i
	dbra	d1,koppastr„ngen†tv„nster2	; f”rh†llande till cursorn
	lea	numberstring,a0			; ett steg †t v„nster
	add.w	numberlen,a0
	clr.b	(a0)
	move.b	#' ',-1(a0)
ingenstr„ngattdeleta2:
	bra	skrivutdet„nd†2
safasdfasdfasdf:
	lea	numberstring,a0
	add.w	cursor,a0
	move.b	#' ',(a0)
	bra	skrivutdet„nd†2
inteendeleteistr„ngen2:

	swap	d7

	cmp.b	#13,d7
	beq	enreturnhoppaureditmoden2

	cmp.w	#32,d7
	blt	inteenvanligf”rst†ligtangent2

	tst.w	signed
	beq.s	intetill†tetmedsigned
	tst.w	cursor
	bne.s	intetill†tetmedsigned
	cmp.b	#'+',d7
	beq.s	intesignerat2
	cmp.b	#'-',d7
	beq.s	intesignerat2
intetill†tetmedsigned:

	lea	godk„ndatal,a0
letaomdenblevgodk„nd:		; Leta om den „r godk„nd
	cmp.b	(a0),d7
	beq.s	engodk„nddj„vel
	tst.b	(a0)
	beq	inteenvanligf”rst†ligtangent2
	addq.w	#1,a0
	bra.s	letaomdenblevgodk„nd
engodk„nddj„vel:
	tst.w	signed
	beq.s	intesignerat2
	tst.w	cursor
	beq.s	skrivutdet„nd†2
intesignerat2:

	move.w	cursor,d0
	cmp.w	numberlen,d0	; Kan vi mata in ett till tecken?
	bge	redanmaxl„ngd2

	cmp.b	#'a',d7
	blt.s	inteettliteta
	cmp.b	#'z',d7		; Konvertera till stora bokst„ver
	bgt.s	inteettliteta
	sub.b	#'a'-'A',d7
inteettliteta:

	move.w	numberlen,d1
	sub.w	d0,d1
	beq.s	ingenstr„ngattinserta2
	subq.w	#1,d1
	lea	numberstring,a0
	add.w	numberlen,a0
	subq.w	#1,a0
koppastr„ngen†th”ger2:
	move.b	-1(a0),(a0)
	subq.w	#1,a0			; Flytta det som „r †t h”ger i
	dbra	d1,koppastr„ngen†th”ger2; f”rh†llande till kursorn
ingenstr„ngattinserta2:			; ett steg †t h”ger
	lea	numberstring,a0
	add.w	numberlen,a0
	clr.b	(a0)
	lea	numberstring,a0
	add.w	cursor,a0
	move.b	d7,(a0)			; Flytta in tecknet i str„ngen
	move.w	cursor,d0
	addq.w	#1,d0
	cmp.w	numberlen,d0	; Kan vi mata in ett till tecken?
	bge.s	skrivutdet„nd†2
	addq.w	#1,cursor
skrivutdet„nd†2:
	jsr	removecursor
	lea	numberstring,a3
	move.w	numberx,d0 		; x
	sub.w	#16,d0
	move.w	numbery,d1		; y
	bsr	skrivuttext		; Skriv ut textstr„ngen
	clr.w	cursorblink
redanmaxl„ngd2:
inteenvanligf”rst†ligtangent2:


	bra	huvudtexteditloop2
enreturnhoppaureditmoden2:


	clr.w	cursoronoff		; St„ng av cursorn
	jsr	removecursor

	move.w	#$8240,a1
	lea	extracol,a0		; Ladda upp f„rgerna
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	tst.w	signed		; Om signerat, konvertera inte
	beq.s	intesignerat
	cmp.b	#'+',numberstring
	beq.s	ettplussiaf
	cmp.b	#'-',numberstring
	bne.s	nixintegodk„nt	; Kolla om den signerade blev godk„nd
	cmp.b	#'0',numberstring+1
	beq.s	s„ttplusoretunera
	cmp.b	#'1',numberstring+1
	blt.s	nixintegodk„nt
	cmp.b	#'8',numberstring+1
	bgt.s	nixintegodk„nt
	rts
s„ttplusoretunera:
	move.b	#'+',numberstring
	rts
ettplussiaf:
	cmp.b	#'0',numberstring+1
	blt.s	nixintegodk„nt
	cmp.b	#'7',numberstring+1
	bgt.s	nixintegodk„nt
	rts
intesignerat:
	lea	numberstring,a0
	move.w	numberlen,d0	; Kolla s† att det finns tal inmatade
	subq.w	#1,d0		; i str„ngen
letaigenoms†attdet„rtalistr„ngen:
	cmp.b	#' ',(a0)
	beq.s	detfinnsintesiffroriden
	tst.b	(a0)
	bne.s	detfinnssiffroriden
detfinnsintesiffroriden:
	addq.w	#1,a0
	dbra	d0,letaigenoms†attdet„rtalistr„ngen
nixintegodk„nt:
	move.l	numberstring2,numberstring	; Om inte, konvertera
	move.l	numberstring2+4,numberstring+4	; ursprungsv„rdet
	move.w	numberstring2+8,numberstring+8
	tst.w	signed
	beq.s	detfinnssiffroriden
	rts
detfinnssiffroriden:
	move.w	numberlen,d0
	subq.w	#1,d0
	lea	numberstring,a0		; Konvertera ASCIIhex->hex
	lea	numberin,a1
	clr.l	(a1)
	moveq	#0,d2
	lea	godk„ndatal,a2
kontohexfromascii:
	cmp.b	#' ',(a0)
	beq.s	f„rdigtkonv
	tst.b	(a0)
	beq.s	f„rdigtkonv
	lsl.l	#4,d2
	moveq	#16-1,d1
	move.l	a2,a3
	moveq	#0,d3
letaframr„tt:
	move.b	(a3)+,d5
	cmp.b	(a0),d5
	beq.s	r„tttal
	addq.w	#1,d3
	dbra	d1,letaframr„tt
r„tttal:or.b	d3,d2
	addq.w	#1,a0
	dbra	d0,kontohexfromascii
f„rdigtkonv:
	move.l	d2,(a1)
	rts

waittwovbls:		; V„ntar p† vblen 2 ggr 
	moveq	#1,d0
vanta2ggr3:
	clr.l	$466.w
vantapasyncen3:
	tst.l	$466.w
	beq.s	vantapasyncen3
	dbra	d0,vanta2ggr3
	rts

calccursorplaceinnumber:	; Placera cursorn d„r vi tryckte med
	cmp.w	numberx,d6	; musen
	bgt.s	st”rre„nnumberx
	clr.w	cursor
	rts
st”rre„nnumberx:
	move.w	numberx,d0
	move.w	numberlen,d1
	lsl.w	#3,d1
	add.w	d1,d0
	cmp.w	d0,d6
	bls.s	mindre„nalltihopa
	move.w	numberlen,cursor
	subq.w	#8,cursor
	rts
mindre„nalltihopa:
	sub.w	numberx,d6
	lsr.w	#3,d6
	move.w	d6,cursor
	rts

matainmaxpatts:			; Mata in max antal patterns
	move.b	maxpatterns+1,numberin
	move.w	#2,numberlen
	move.w	#217,numberx
	move.w	#45,numbery
	bsr	enteranumber	; L†t anv„ndaren mata in ett v„rde
	jsr	hittastorstapatternetisongen	; Minv„rde
	addq.w	#1,d0
	move.l	#$80,d1		; Maxv„rde
	bsr	checkbounding	; Kolla storleken p† den
	move.w	d2,maxpatterns
	rts

s„ttminnes†tg†ng:
	tst.l	editorpek
	beq.s	okatt„ndraminnes†tg†ng
	lea	reformaterr1,a5
	lea	reformaterr2,a6
	jsr	makejeppform
	rts
okatt„ndraminnes†tg†ng:
	move.l	MainMemLength,d0
	lsl.l	#8,d0
	move.l	d0,numberin
	move.w	#6,numberlen
	move.w	#265,numberx
	move.w	#20+6,numbery
	bsr	enteranumber	; L†t anv„ndaren mata in ett v„rde
	addq.l	#1,d2
	and.l	#$FFFFFFFE,d2
	move.l	d2,dummen
	move.w	#64*32,d0
	mulu	maxpatterns,d0	; Minv„rde
	move.l	#$FFFFFE,d1	; Maxv„rde
	bsr	checkbounding	; Kolla storleken p† den
	cmp.l	MainMemLength,d2
	beq	ingenf”r„ndingavhuvudminnet
	move.l	d2,-(sp)
	lea	changemem1,a5
	lea	changemem2,a6
	jsr	makeform
	move.l	(sp)+,d2
	tst.w	d0
	bmi	ingenf”r„ndingavhuvudminnet
	move.l	d2,MainMemLength
	jsr	slutamedmem
	bsr	tadodpaallasamplingar	; Sl„pp alla samplingar
	lea	songname,a5		; T”m aktuellt songnamn
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.l	#'    ',(a5)+
	move.w	#'  ',(a5)+
	move.w	#$2000,(a5)+
	bsr	rensaallapatternsochsongen	; Rensa songen
	jsr	settermody	; D”da alla UCDMar
	tst.w	termodyonoff
	beq.s	termodyn„rredanavslagen
	jsr	usetermody
termodyn„rredanavslagen:
	jsr	termoval4
	jsr	releasecurrentplayer
	jsr	termoval3
	jsr	releasecurrentplayer
	jsr	termoval2
	jsr	releasecurrentplayer
	jsr	termoval1
	jsr	releasecurrentplayer
	jsr	exittermody
				; Beg„r om minnet
	clr.l	undopek
	move.w	#1,donotdoanymusicorsomeshit	; Inte skapa musik
						; eller pattern
	jsr	closeinternalmemhandler	; Sl„pp allt internt anv„nt minne

	move.l	MainMemLength,d0	; Antal bytes som ”nskas
	jsr	setupinternalmemhandler	; S„tt upp den interna minneshanteraren

	move.w	#64*32,d0
	mulu	maxpatterns,d0
	lea	patterns,a0		; Beg„r minne f”r alla
	moveq	#0,d1			; patterna av den interna
	jsr	malloc			; minneshanteraren

	clr.w	donotdoanymusicorsomeshit
	jsr	showmemmenu
	rts
ingenf”r„ndingavhuvudminnet:
	lea	MainMemLength+1,a3	; Vilket tal skall konverteras
	move.w	numberx,d0		; x
	move.w	numbery,d1		; y
	moveq	#6-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
	rts


addmaxpatts:			; L„gg till ett till maxpatterns
	cmp.w	#$80,maxpatterns
	bge.s	inteflerapatterns
	addq.w	#1,maxpatterns
	lea	maxpatterns+1,a3	; Vilket tal skall konverteras
	move.w	#217,d0			; x
	move.w	#45,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
inteflerapatterns:
	rts


submaxpatts:			; Dra ifr†n ett fr†n maxpatterns
	jsr	hittastorstapatternetisongen
	addq.w	#1,d0
	cmp.w	maxpatterns,d0
	bge.s	intef„rrepatterns
	subq.w	#1,maxpatterns
	lea	maxpatterns+1,a3	; Vilket tal skall konverteras
	move.w	#217,d0			; x
	move.w	#45,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
intef„rrepatterns:
	rts


setnumofpatts:
	move.l	#numpattskoors,losapositioner
	move.l	#numpattsrots,losarutiner
	move.l	bildminne,a0
	lea	(32*168+104)+8(a0),a1		; a1 till bilden
	add.l	#70472+2128,a0	; a0 till termodyformen
	move.l	a1,a2
	lea	4(a0),a3		; Spar bakgrunden
	bsr	sparlill2storform
	move.l	a1,a3
	move.l	a0,a2		; Rita ut den
	bsr	ritautenlill2storform
	move.w	maxpatterns,extrapatt
	lea	maxpatterns+1,a3	; Vilket tal skall konverteras
	move.w	#217,d0			; x
	move.w	#45,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
	rts

exitmaxpatt:
	move.l	#optionskoors,losapositioner
	move.l	#optionsrots,losarutiner
	move.l	bildminne,a0
	lea	(32*168+104)+8(a0),a1		; a1 till bilden
	add.l	#70472+2128,a0	; a0 till termodyformen
	move.l	a1,a2
	move.l	a0,a3			; Spar bakgrunden
	bsr	sparlill2storform
	moveq	#0,d0
	move.w	maxpatterns,d0
	cmp.w	extrapatt,d0
	beq.s	minnekvar

	clr.l	undopek

	move.l	patterns,a0
	move.w	#64*32,d0
	mulu	maxpatterns,d0
	jsr	reformatmemory		; Žndra p† l„ngden
	bpl.s	minnekvar
	jsr	outofmemoryerror
	jmp	skrivuttaletsamtresetta
minnekvar:
	move.l	bildminne,a0
	lea	(32*168+104)+8(a0),a1		; a1 till bilden
	move.l	a1,a3
	add.l	#70472+2128,a0	; a0 till termodyformen
	lea	4(a0),a2		; Ladda upp bakgrunden
	bsr.s	ritautenlill2storform
	rts
skrivuttaletsamtresetta:
	move.w	extrapatt,maxpatterns
	lea	maxpatterns+1,a3	; Vilket tal skall konverteras
	move.w	#217,d0			; x
	move.w	#45,d1			; y
	move.w	#2-1,d7 		; Hur m†nga siffror
	bsr	skrivuthex		; Skriv ut i hex
	move.l	bildminne,a0
	lea	(32*168+104)+8(a0),a1		; a1 till bilden
	add.l	#70472+2128,a0	; a0 till termodyformen
	move.l	a1,a2
	move.l	a0,a3			; Spar bakgrunden
	bsr.s	sparlill2storform
	bra.s	minnekvar

ritautenlill2storform:		; Skriver ut en lill2stor form till bildminnet
	moveq	#23-1,d7
loopautenlill2storform:
	move.l	(a2),(a3)
	move.l	8(a2),8(a3)
	move.l	16(a2),16(a3)
	move.l	24(a2),24(a3)
	lea	168(a3),a3
	lea	32(a2),a2
	dbra	d7,loopautenlill2storform
	rts

sparlill2storform:	; Skriver ut en lill2stor form till bildminnet
	moveq	#23-1,d7
loopsparlill2storform:
	move.l	(a2),(a3)
	move.l	8(a2),8(a3)
	move.l	16(a2),16(a3)
	move.l	24(a2),24(a3)
	lea	168(a2),a2
	lea	32(a3),a3
	dbra	d7,loopsparlill2storform
	rts


ritautenstorform2:		; Skriver ut en stor form till bildminnet
	moveq	#69-1,d7
loopautenstorform2:
	move.l	(a2),(a3)
	move.l	8(a2),8(a3)
	move.l	16(a2),16(a3)
	move.l	24(a2),24(a3)
	move.l	32(a2),32(a3)
	move.l	40(a2),40(a3)
	lea	168(a3),a3
	lea	48(a2),a2
	dbra	d7,loopautenstorform2
	rts

sparstorform2:		; Skriver ut en stor form till bildminnet
	moveq	#69-1,d7
loopsparstorform2:
	move.l	(a2),(a3)
	move.l	8(a2),8(a3)
	move.l	16(a2),16(a3)
	move.l	24(a2),24(a3)
	move.l	32(a2),32(a3)
	move.l	40(a2),40(a3)
	lea	168(a2),a2
	lea	48(a3),a3
	dbra	d7,loopsparstorform2
	rts

openchoise:			; Ritar ut laddavalsmenyn
	move.l	bildminne,a0
	lea	(8*168+72)+8(a0),a1		; a1 till bilden
	add.l	#63272+2128,a0		; a0 till laddavalformen
	move.l	a1,a2
	lea	4(a0),a3		; Spar bakgrunden
	bsr.s	sparstorform2
	move.l	a1,a3
	move.l	a0,a2		; Rita ut den
	bsr.s	ritautenstorform2
	rts

closechoise:			; St„nger ut laddavalsmenyn
	move.l	bildminne,a0
	lea	(08*168+72)+8(a0),a1		; a1 till bilden
	move.l	a1,a3
	add.l	#63272+2128,a0		; a0 till laddavalformen
	lea	4(a0),a2		; Ladda upp bakgrunden
	bsr	ritautenstorform2
	rts


returnselection:
	btst.b	#1,mkey 		; V„nster musknapp nertryckt?
	beq.s	returnselection

	cmp.w	#65,y		; Tryckte vi p† cancel-knappen?
	ble.s	inteencancelichioseen
	cmp.w	#74,y
	bge.s	inteencancelichioseen
	cmp.w	#146+16,x
	ble.s	inteencancelichioseen
	cmp.w	#237+16,x
	bge.s	inteencancelichioseen
	moveq	#10,d0
	rts
inteencancelichioseen:
	cmp.w	#9,y		; Tryckte vi inom form 1?
	ble.s	viintetrycktep†v„nstercolumnen
	cmp.w	#63,y
	bge.s	viintetrycktep†v„nstercolumnen
	cmp.w	#145+16,x
	ble.s	viintetrycktep†v„nstercolumnen
	cmp.w	#191+16,x
	bge.s	viintetrycktep†v„nstercolumnen
	moveq	#0,d1
	bra.s	r„knautvilkeniv„nstercolumn
viintetrycktep†v„nstercolumnen:
	cmp.w	#9,y		; Tryckte vi inom form 2?
	ble.s	returnselection
	cmp.w	#63,y
	bge.s	returnselection
	cmp.w	#194+16,x
	ble.s	returnselection
	cmp.w	#237+16,x
	bge	returnselection
	moveq	#5,d1
r„knautvilkeniv„nstercolumn:
	moveq	#0,d0
	move.w	y,d0		; Isf r„kna ut vilken ruta vi valde
	sub.w	#9,d0
	divu	#11,d0
	and.l	#$F,d0
	add.w	d1,d0
v„ntap†attanv„ndareskallsl„ppamusknappen:
	btst.b	#1,mkey 	; V„nster musknapp nertryckt?
	bne.s	v„ntap†attanv„ndareskallsl„ppamusknappen
	rts

ritautenstorform4:		; Skriver ut en stor form till bildminnet
	moveq	#30-1,d7
loopautenstorform4:
	move.l	(a2),(a3)
	lea	168(a3),a3
	addq.w	#8,a2
	dbra	d7,loopautenstorform4
	rts

sparstorform4:		; Skriver ut en stor form till bildminnet
	moveq	#30-1,d7
loopsparstorform4:
	move.l	(a2),(a3)
	lea	168(a2),a2
	addq.w	#8,a3
	dbra	d7,loopsparstorform4
	rts

selectnrofpatts:
	move.l	#selectshowpattkoors,losapositioner
	move.l	#selectshowpattrots,losarutiner
	move.l	bildminne,a0
	lea	(11*168+96)+8(a0),a1		; a1 till bilden
	add.l	#71208+2128,a0		; a0 till laddavalformen
	move.l	a1,a2
	lea	4(a0),a3		; Spar bakgrunden
	bsr.s	sparstorform4
	move.l	a1,a3
	move.l	a0,a2		; Rita ut den
	bsr.s	ritautenstorform4
	rts


hidethispattrowmeny:
	move.l	bildminne,a0
	lea	(11*168+96)+8(a0),a1		; a1 till bilden
	move.l	a1,a3
	add.l	#71208+2128,a0		; a0 till laddavalformen
	lea	4(a0),a2		; Ladda upp bakgrunden
	bsr.s	ritautenstorform4
	move.l	#termodykoors,losapositioner
	move.l	#termodyrots,losarutiner
	rts

s„ttdataompatternetr„tt:
	tst.w	termodyonoff
	beq.s	termodyn„ravslagen1
	move.l	currenttermody,a0
	moveq	#0,d0
	move.w	patternupdate,d0
	move.l	d0,16(a0)
	rts
termodyn„ravslagen1:
	jsr	s„ttregisterefterfreq
	lea	speedandupdatingdata,a0
	tst.w	aalias
	beq.s	intedetalllsnu2
	lea	24(a0),a0
intedetalllsnu2:
	move.l	d7,d0
	move.w	antalkanaler,d1
	subq.w	#4,d1
	lsr.w	#1,d1
	add.w	d1,d1			; S„tt s† att det blir r„tt
	add.w	d1,d1			; patternbelastning
	add.w	d1,d1
	add.w	d0,d0
	add.w	d1,d0
	move.w	patternupdate,(a0,d0.w)
	rts


showonly17rows:
	jsr	stopknapp
	jsr	clearthepattshower
	clr.w	patternupdate
	clr.w	donotdoanymusic
	clr.w	donotdoanymusicorsomeshit
	bsr	hidethispattrowmeny
	bsr.s	s„ttdataompatternetr„tt
	rts

showonly7rows:
	jsr	stopknapp
	jsr	clearthepattshower
	move.w	#1,patternupdate
	clr.w	donotdoanymusic
	clr.w	donotdoanymusicorsomeshit
	bsr	hidethispattrowmeny
	bsr	s„ttdataompatternetr„tt
	rts

showonly1rows:
	jsr	stopknapp
	jsr	clearthepattshower
	move.w	#-1,patternupdate
	clr.w	donotdoanymusic
	clr.w	donotdoanymusicorsomeshit
	bsr	hidethispattrowmeny
	bsr	s„ttdataompatternetr„tt
	rts


deinstallcrashsaver:	; terinstallera gamla felvektorer
	lea	oldvectors,a0
	lea	$8.w,a1
	moveq	#8-1,d0
kiwriwerwr:
	move.l	(a0)+,(a1)+
	dbra	d0,kiwriwerwr
	rts

installcrashsaver:
	lea	oldvectors,a1
	lea	$8.w,a0
	moveq	#8-1,d0
kiwriwerwr2:
	move.l	(a0)+,(a1)+
	dbra	d0,kiwriwerwr2
	lea	$8.w,a1
	moveq	#8-1,d0
kiwriwerwr3:
	move.l	#errorvector,(a1)+
	dbra	d0,kiwriwerwr3
	rts

mymedia:
	moveq	#0,d0
	move.w	4(sp),d0
	move.l	d1,-(sp)
	move.l	allmediachanged(pc),d1
	bclr.l	d0,d1
	beq.s	oldmedia2
	move.l	d1,allmediachanged
	move.l	(sp)+,d1
	moveq	#1,d0		; Retunera att disken kanske „r bytt
	rts			; n„r sk„rmarna swappas men inte sen
oldmedia2:
	move.l	(sp)+,d1
oldmedia:
	jmp	$12345678

allmediachanged:
	dc.l	$FFFFFFFF
allmediachanged2:
	dc.l	$FFFFFFFF

errorvector:		; Vid fel, hoppa hit
	move.w	#1,donotdoanymusicorsomeshit
	move.w	#$2300,sr
	clr.w	vblisstillworking
	lea	dummen2,a1
	move.w	#$8248,a0
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	lea	errorcolor,a0
	move.w	#$8248,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.w	#$F00,$ffff8240.w
	lea	excep1,a5
	lea	excep2,a6
	bsr	makeform
	move.w	screenpalette,$ffff8240.w
	lea	dummen2,a0
	move.w	#$8248,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	tst.w	d0
	bmi.s	f”rs”kforts„tta
	jmp	xjkdfjghkcvbnm
f”rs”kforts„tta:
	clr.w	donotdoanymusicorsomeshit
	jmp	majorloop

ritautenstorform34:	; Skriver ut vad sampleknappen har f”r status
	moveq	#8-1,d7
loopautenstorform43:
	move.l	(a2),(a3)
	move.l	8(a2),8(a3)
	move.l	16(a2),16(a3)
	move.l	24(a2),24(a3)
	lea	168(a3),a3
	lea	32(a2),a2
	dbra	d7,loopautenstorform43
	rts


ritautsampleeditornelpatterbasen:
	move.w	#160-1,d0
skrivutsampleeditorn:
	rept	19
	move.l	(a2),(a3)
	addq.w	#8,a2
	addq.w	#8,a3
	endr
	move.l	(a2),(a3)
	addq.w	#8,a2
	lea	16(a3),a3
	dbra	d0,skrivutsampleeditorn
	rts

sparsampleeditornelpatterbasen:
	move.w	#160-1,d0
sparsampleeditorn:
	rept	19
	move.l	(a2),(a3)
	addq.w	#8,a2
	addq.w	#8,a3
	endr
	move.l	(a2),(a3)
	addq.w	#8,a3
	lea	16(a2),a2
	dbra	d0,sparsampleeditorn
	rts


bytsamopatt:
	cmp.l	#infokoors,losapositioner
	beq.s	termodynanv„nds
	tst.w	lowershower
	bmi.s	byttillpatternet
	bne	byttill8kanalerimeny
	move.w	#1,lowershower

	move.l	bildminne,d0
	add.l	#241*168,d0
	move.l	oldcursorpek,oldoldcursorpek
	move.l	d0,oldcursorpek

	move.w	#340,movecursorkoors
	move.w	#109,movecursorkoors+2
	move.w	#231,movecursorkoors+6
	move.w	#STATIONAR+8,fastapositioner

	move.l	bildminne,a2
	lea	(45*168+128)+8(a2),a3	; a3 till bilden
	add.l	#71704+2128,a2		; a2 till knappen
	bsr	ritautenstorform34

	move.l	bildminne,a2
	lea	106*168+8(a2),a3	; a3 till bilden
	add.l	#71960+2128,a2		; a2 till editorn
	bsr	ritautsampleeditornelpatterbasen

	bsr	checkifsamplechanged
termodynanv„nds:
	rts
byttillpatternet:
	cmp.l	#huvudlospos,losapositioner
	bne.s	termodynanv„nds

	move.l	oldeditorpek,a0	; Sl„pp minnet som anv„nds till
	jsr	free			; bildminne
	clr.l	editorpek

kaninteinstallerahalveditor:
	move.w	#109,movecursorkoors+2
	move.w	#231,movecursorkoors+6

	move.l	bildminne,a2
	lea	(45*168+128)+8(a2),a3	; a3 till bilden
	add.l	#71448+2128,a2		; a2 till knappen
	bsr	ritautenstorform34

	move.l	oldoldcursorpek,oldcursorpek
	clr.l	oldfulleditorline

	move.l	bildminne,a2
	lea	106*168+8(a2),a3	; a3 till bilden
	add.l	#71960+4+2128,a2	; a2 till patternbasen
	bsr	ritautsampleeditornelpatterbasen

	clr.w	lowershower
	rts

byttill8kanalerimeny:		; Visa alla 8 kanalerna samtidigt som menyn
	cmp.l	#huvudlospos,losapositioner
	bne.s	termodynanv„nds

	move.w	#15,movecursorkoors
	move.w	#103,movecursorkoors+2
	move.w	#237,movecursorkoors+6
	move.w	#STATIONAR,fastapositioner

	move.l	bildminne,a2
	lea	(45*168+128)+8(a2),a3	; a3 till bilden
	add.l	#104328+2128,a2		; a2 till knappen
	bsr	ritautenstorform34

	move.l	bildminne,a3		; Spar bilden
	lea	106*168+8(a3),a2	; a3 till bilden
	add.l	#71960+2128,a3		; a2 till editorn
	bsr	sparsampleeditornelpatterbasen

	move.l	bildminne,a2
	lea	106*168+8(a2),a3	; a3 till bilden
	add.l	#71960+4+2128,a2	; a2 till patternbasen
	bsr	ritautsampleeditornelpatterbasen

	lea	installameddelande,a3	; Pekare till str„ng
	move.w	#80,d0			; x		Songnamn
	move.w	#85,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen

	move.l	#66*6*160+24,d0
	lea	oldeditorpek,a0	; Beg„r minne f”r sk„rmen
	moveq	#0,d1			; som kommer att visa patternet
	jsr	malloc
	beq	kaninteinstallerahalveditor
	move.l	oldeditorpek,d0
	add.l	#16,d0
	and.l	#$FFFFFFF0,d0
	move.l	d0,oldfulleditormouse
	move.l	d0,editorpek

	move.w	#-1,oldoldlowershower
	jsr	fixatillseparatbildminne
	move.w	#-1,lowershower
	rts

oldeditorpek:
	dc.l	0

setmix:			; Mixa samplingarna
	cmp.l	#infokoors,losapositioner
	beq.s	redanmixmode
	tst.w	samplemode
	beq.s	redanmixmode
	move.l	bildminne,a2
	lea	((188*168)+89)+8(a2),a2	; a1 till bilden
	moveq	#3-1,d7 		; 3 bytes vidd p† notten
	jsr	makeinversojamn
	cmp.w	#1,samplemode
	bne.s	inteover1
	move.l	bildminne,a2
	lea	((188*168)+104)+8(a2),a2	; a1 till bilden
	moveq	#3-1,d7 		; 3 bytes vidd p† notten
	jsr	makeinversjamn
	bra.s	klartslut1
inteover1:
	move.l	bildminne,a2
	lea	((188*168)+113)+8(a2),a2	; a1 till bilden
	moveq	#3-1,d7 		; 3 bytes vidd p† notten
	jsr	makeinversojamn
klartslut1:
	clr.w	samplemode
redanmixmode:
	rts

setover:		; Overwrite samplingarna
	cmp.l	#infokoors,losapositioner
	beq.s	redanovermode
	cmp.w	#1,samplemode
	beq.s	redanovermode
	move.l	bildminne,a2
	lea	((188*168)+104)+8(a2),a2	; a1 till bilden
	moveq	#3-1,d7 		; 3 bytes vidd p† notten
	jsr	makeinversjamn
	tst.w	samplemode
	bne.s	intemix1
	move.l	bildminne,a2
	lea	((188*168)+89)+8(a2),a2	; a1 till bilden
	moveq	#3-1,d7 		; 3 bytes vidd p† notten
	jsr	makeinversojamn
	bra.s	klartslut2
intemix1:
	move.l	bildminne,a2
	lea	((188*168)+113)+8(a2),a2	; a1 till bilden
	moveq	#3-1,d7 		; 3 bytes vidd p† notten
	jsr	makeinversojamn
klartslut2:
	move.w	#1,samplemode
redanovermode:
	rts

setins:		; Inserta samplingarna
	cmp.l	#infokoors,losapositioner
	beq.s	redaninsmode
	cmp.w	#2,samplemode
	beq.s	redaninsmode
	move.l	bildminne,a2
	lea	((188*168)+113)+8(a2),a2	; a1 till bilden
	moveq	#3-1,d7 		; 3 bytes vidd p† notten
	jsr	makeinversojamn
	tst.w	samplemode
	bne.s	intemix2
	move.l	bildminne,a2
	lea	((188*168)+89)+8(a2),a2	; a1 till bilden
	moveq	#3-1,d7 		; 3 bytes vidd p† notten
	jsr	makeinversojamn
	bra.s	klartslut3
intemix2:
	move.l	bildminne,a2
	lea	((188*168)+104)+8(a2),a2	; a1 till bilden
	moveq	#3-1,d7 		; 3 bytes vidd p† notten
	jsr	makeinversjamn
klartslut3:
	move.w	#2,samplemode
redaninsmode:
	rts

clearlowerbar:		; Rutinen som rensar dragbaren
	move.l	bildminne,a0	; Bildminne
	lea	168*182+2+8(a0),a0
	moveq	#0,d0
	bsr.s	flyttaenradtillf”nstret
	lea	168(a0),a0
	bsr.s	flyttaenradtillf”nstret
	rts

clearsamplewindow:	; Rutinen som rensar samplef”nstret
	move.l	bildminne,a0	; Bildminne
	lea	168*113+2+8(a0),a0
	moveq	#0,d0
	moveq	#31-1,d1
rensa”verdelenavsamplewindowet:
	bsr.s	flyttaenradtillf”nstret
	lea	168(a0),a0
	dbra	d1,rensa”verdelenavsamplewindowet
	moveq	#-1,d0
	bsr.s	flyttaenradtillf”nstret
	lea	168(a0),a0
	moveq	#0,d0
	moveq	#32-1,d1
rensanedredelenavsamplewindowet:
	bsr.s	flyttaenradtillf”nstret
	lea	168(a0),a0
	dbra	d1,rensanedredelenavsamplewindowet
	rts

flyttaenradtillf”nstret:
	move.b	d0,1(a0)
	move.w	d0,8(a0)
	move.w	d0,16(a0)
	move.w	d0,24(a0)
	move.w	d0,32(a0)
	move.w	d0,40(a0)
	move.w	d0,48(a0)
	move.w	d0,56(a0)
	move.w	d0,64(a0)
	move.w	d0,72(a0)
	move.w	d0,80(a0)
	move.w	d0,88(a0)
	move.w	d0,96(a0)
	move.w	d0,104(a0)
	move.w	d0,112(a0)
	move.w	d0,120(a0)
	move.w	d0,128(a0)
	move.w	d0,136(a0)
	move.w	d0,144(a0)
	move.b	d0,152(a0)
	rts

changeblkstart:			; Žndra blockstarten via str„cket
	rts
	not.w	$ffff8240.w
	not.w	$ffff8240.w
	rts

changeblkend:			; Žndra blockslutet via str„cket
	rts
	cmp.w	#7+16,d6
	bge.s	inteettminv„rdeiblklen
	moveq	#7+16,d6
inteettminv„rdeiblklen:
	cmp.w	#312+16,d6
	ble.s	inteettmaxv„rdeiblklen
	move.w	#312+16,d6
inteettmaxv„rdeiblklen:

	moveq	#0,d0
	bsr.s	ritautettstr„ck
	move.l	sample1len,d2
	sub.w	#16+8,d0
	mulu	d0,d2
	divu	#303,d2
	sub.w	blockstartsam,d2
	move.w	d2,blocklensam
	moveq	#0,d0
	bsr.s	ritautettstr„ck

	rts

blockstartsam:
	dc.w	0		; Sampleeditorns blockstart
blocklensam:
	dc.w	0		; Sampleeditorns blockl„ngd

ritautettstr„ck:
	subq.w	#1,d0
	moveq	#31,d2
	sub.w	d0,d2
	moveq	#5,d1

	move.l	bildminne,a0	; bildminne
	lea	vertikallinjerotering(pc),a1
	move.w	a2,d2		; R„tt position
	and.w	#$FFF0,d2
	lsr.w	#1,d2
	add.w	d2,a0
	move.w	a2,d2
	and.w	#$F,d2
	add.w	d2,d2
	move.w	(a1,d2.w),d2
	bsr.s	ritaenlinjesupersnabbt2
	rts

ritaenlinjesupersnabbt2:
	or.w	d2,(a0)
	lea	168(a0),a0
	dbra	d3,ritaenlinjesupersnabbt
	rts




calculatenewdata:	; Rutinen som r„knar ut nya r„knarvariabler
	tst.w	whichsample
	bne.s	den„rnolls„tts†attdeninteritarutden
	move.w	#1,sampledraw
	clr.l	sample1len
	rts
den„rnolls„tts†attdeninteritarutden:
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#$1E,d0
	add.l	#modsamsave,d0
	move.l	d0,a0
	tst.w	22(a0)
	bne.s	det„rensamplingmatadenmedv„rden
	move.w	#1,sampledraw
	clr.l	sample1len
	rts
det„rensamplingmatadenmedv„rden:
	clr.w	sampledraw
	moveq	#0,d0
	move.w	whichsample,d0
	subq.w	#1,d0
	add.w	d0,d0
	add.w	d0,d0
	add.l	#samplestarts,d0
	move.l	d0,a1
	move.l	(a1),sample1pek		; Installera data f”r
	moveq	#0,d0			; samplingsritningrutinen
	move.w	22(a0),d0
	add.l	d0,d0
	move.l	d0,sample1len
	add.l	#1000,d0
	move.l	d0,loop1data
	cmp.l	#$00000001,26(a0)
	bne.s	det„renloopadsampling
	move.l	#$FFFFFF,samloopstart
	rts
det„renloopadsampling:
	moveq	#0,d0
	move.w	26(a0),d0
	add.w	28(a0),d0
	add.l	d0,d0
	move.l	d0,samloopstart
	rts

drawsampleinwindow:	; Rita samplingen i f”nstret
	tst.w	sampledraw
	bne	felfel
	move.l	bildminne,a6
	addq.w	#2,a6
	lea	113*168(a6),a6
	tst.w	drawspeed		; Testa vilken utritningsmode
	beq.s	ritautensannsampling	; som „r vald
	move.l	sample1pek,a5		; Pekaren till sample i a5
	move.l	samloopstart,a4		; Loopstart i a4
	move.l	sample1len,d7
	divu	#304,d7			; Rita med plotmode
	move.w	d7,d6
	clr.w	d7
	divu	#304,d7
	move.w	d7,a3			; Br†kdel i a3
	move.w	#16+8,a2
	moveq	#0,d7
	move.w	d6,d7			; Heltalsdel i d7
	moveq	#0,d6
	moveq	#0,d5
	moveq	#0,d3
	moveq	#0,d0
	moveq	#31,d1
	move.w	#304-1,d4
ritautensamplingmedplotmode:
	move.b	(a5,d5.l),d3
ritautensamplingmedplotmode2:
roteranerplot:
	move.w	#2,d2
	asr.b	d2,d3
	neg.b	d3
	add.b	#31,d3
	move.b	d1,d0
	move.b	d3,d1
	bsr	drawsampleline
	add.w	a3,d6
	addx.l	d7,d5
	addq.w	#1,a2		; N„sta position
	cmp.l	d5,a4
	bgt.s	inteinomloop
	move.l	a4,d3
	add.l	#1000,d3
	cmp.l	d5,d3
	blt.s	inteinomloop
	move.l	d5,d3
	sub.l	a4,d3
	add.l	loop1data,d3
	move.b	(a5,d3.l),d3
	dbra	d4,ritautensamplingmedplotmode2
	bra.s	felfel
inteinomloop:
	dbra	d4,ritautensamplingmedplotmode
felfel:	rts
ritautensannsampling:			; Rita true
	move.l	bildminne,a6
	addq.w	#2,a6
	lea	113*168(a6),a6	; bildminne i a6

	move.w	#16+8,a2	; x-koordinat
	move.l	#304,d7
	divu	sample1len+2,d7
	move.w	d7,d6
	clr.w	d7
	divu	sample1len+2,d7
	move.w	d7,a3
	moveq	#0,d7
	move.w	d6,d7
	moveq	#0,d6		; d7, d6, d5 och a3 inneh†ller
	moveq	#0,d5		; adderingskoefficienter f”r linjen
				; Rita ut f”rsta delen
	move.l	sample1pek,a4	; a4 pekaren till datav„rdet
	move.l	sample1len,d4	; antal bytes vi skall kolla p† f”rsta
	subq.l	#1,d4		; g†ngen
	move.w	#31,a1		; a1 gamla max
	move.w	#31,a0		; a0 gamla min
	bsr.s	skapaentruesampling




	rts

skapaentruesampling:
roteranertrue:
	move.w	#2,d2
	moveq	#0,d1
	moveq	#63,d0		; d0 nya min
	move.b	#0,d1		; d1 nya max
skapatruennu:
	move.b	(a4)+,d3
	asr.b	d2,d3
	neg.b	d3
	add.b	#31,d3
	cmp.b	d1,d3
	ble.s	negativtv„rdeitrue
	move.b	d3,d1
negativtv„rdeitrue:
	cmp.b	d0,d3
	bge.s	harvaritpositivtv„rdeitrue
	move.b	d3,d0
harvaritpositivtv„rdeitrue:
	add.w	a3,d6
	addx.l	d7,d5
	cmp.w	#1,d5
	bge.s	daxattritalinjen
	dbra	d4,skapatruennu		; G† igenom all bytarna
	rts

daxattritalinjen:	; Dax att rita ut linjen f”r truemoden
	ext.w	d0
	ext.w	d1

	cmp.w	a0,d1
	bge.s	minstatrueok
	move.w	a0,d1
minstatrueok:		; Se till att samplingen blir hel
	cmp.w	a1,d0
	ble.s	st”rstatrueok
	move.w	a1,d0
st”rstatrueok:

	bsr.s	drawsampleline
	move.w	d0,a0
	move.w	d1,a1
	subq.l	#1,d5
	addq.w	#1,a2
	cmp.l	#1,d5
	blt.s	ritatklartdelitrue
	movem.l	a0-a1,-(sp)
rital„ngrelinje:	
	bsr.s	drawsampleline
	subq.l	#1,d5
	addq.w	#1,a2
	cmp.l	#1,d5
	bgt.s	rital„ngrelinje
	movem.l	(sp)+,a0-a1
ritatklartdelitrue:
	dbra	d4,roteranertrue
	rts

drawsampleline:		; Rita en linje i samplingsf”nstret
	move.l	a6,a0		; bildminne
	moveq	#0,d2
	moveq	#0,d3
	cmp.b	d0,d1
	blt.s	d1„rmindre„nd0
	move.b	d1,d3
	sub.b	d0,d3
	move.b	d0,d2
	mulu	#168,d2
	add.w	d2,a0
	bra.s	d0„rmindre„nd1
d1„rmindre„nd0:
	move.b	d0,d3
	sub.b	d1,d3
	move.b	d1,d2
	mulu	#168,d2
	add.w	d2,a0
d0„rmindre„nd1:
	lea	vertikallinjerotering(pc),a1
	move.w	a2,d2		; R„tt position
	and.w	#$FFF0,d2
	lsr.w	#1,d2
	add.w	d2,a0
	move.w	a2,d2
	and.w	#$F,d2
	add.w	d2,d2
	move.w	(a1,d2.w),d2
	bsr.s	ritaenlinjesupersnabbt
	rts

ritaenlinjesupersnabbt:
	or.w	d2,(a0)
	lea	168(a0),a0
	dbra	d3,ritaenlinjesupersnabbt
	rts

vertikallinjerotering:	; Anv„nds som rotering f”r en vertikal rotering
	dc.w	%1000000000000000
	dc.w	%0100000000000000
	dc.w	%0010000000000000
	dc.w	%0001000000000000
	dc.w	%0000100000000000
	dc.w	%0000010000000000
	dc.w	%0000001000000000
	dc.w	%0000000100000000
	dc.w	%0000000010000000
	dc.w	%0000000001000000
	dc.w	%0000000000100000
	dc.w	%0000000000010000
	dc.w	%0000000000001000
	dc.w	%0000000000000100
	dc.w	%0000000000000010
	dc.w	%0000000000000001


drawvertikalline:
	mulu	#168,d2
	adda.l	d2,a0
	move.l	a0,a1
	moveq	#15,d7
doit:	move.l	a1,a0
	move.w	d0,d3
	move.w	d3,d4
	and.w	#$FFF0,d3
	asr.w	#1,d3
	adda.l	d3,a0
	and.w	d7,d4
	tst.w	d4
	bne.s	nope
	move.w	d1,d6
	sub.w	d0,d6
check:	cmp.w	d7,d6
	blt.s	nope
	move.w	#%1111111111111111,(a0)
	addq	#8,a0
	add.w	#16,d0
	sub.w	#16,d6
	bra.s	check
nope:	sub.w	d7,d4
	neg.w	d4
	moveq	#0,d5
	bset.l	d4,d5
	or.w	d5,(a0)
	addq	#1,d0
next:	cmp.w	d0,d1
	bgt.s	doit
	rts


drawlowerbar:		; Ritar ut dragbaren
	move.l	bildminne,a0
	lea	2+8(a0),a0
	moveq	#8,d0		; X0
	move.w	#312,d1		; X1
	move.w	#182,d2		; Y
	bsr.s	drawvertikalline
	move.l	bildminne,a0
	lea	2+8(a0),a0
	moveq	#8,d0		; X0
	move.w	#312,d1		; X1
	move.w	#183,d2		; Y
	bsr.s	drawvertikalline
	rts


checkifsamplechanged:
	cmp.l	#infokoors,losapositioner
	beq.s	nochange
	tst.w	lowershower
	ble.s	nochange
	move.w	whichsample,d0
	cmp.w	currentsample,d0
	beq.s	nochange
	move.w	d0,currentsample

	bsr	clearlowerbar		; Rensa hela sampledatan
	bsr	clearsamplewindow	; ink. baren
	bsr	calculatenewdata	; R„kna ut nya data f”r utskriftsrutinerna
	bsr	drawsampleinwindow	; Rita ut samplingen
	bsr.s	drawlowerbar		; Rita ut baren

	move.l	readdatapointer,a0
	clr.b	(a0)			; D”da tangentbordsrep.
	move.l	readdatapointer,writedatapointer

nochange:
	rts


trueupdatespeed:
	cmp.l	#infokoors,losapositioner
	beq.s	redans†truesomdetg†r
	tst.w	drawspeed
	beq.s	redans†truesomdetg†r
	clr.w	drawspeed
	move.l	bildminne,a2
	lea	((188*168)+129)+8(a2),a2; a1 till bilden
	moveq	#3-1,d7 		; 3 bytes vidd p† notten
	jsr	makeinversojamn
	move.l	bildminne,a2
	lea	((188*168)+144)+8(a2),a2; a1 till bilden
	moveq	#3-1,d7 		; 3 bytes vidd p† notten
	jsr	makeinversjamn
	move.w	#-1,currentsample
	bsr	checkifsamplechanged
redans†truesomdetg†r:
	rts


plotupdatespeed:
	cmp.l	#infokoors,losapositioner
	beq.s	redans†plotsomdetg†r
	cmp.w	#16,drawspeed
	beq.s	redans†plotsomdetg†r
	move.w	#16,drawspeed
	move.l	bildminne,a2
	lea	((188*168)+129)+8(a2),a2; a1 till bilden
	moveq	#3-1,d7 		; 3 bytes vidd p† notten
	jsr	makeinversojamn
	move.l	bildminne,a2
	lea	((188*168)+144)+8(a2),a2; a1 till bilden
	moveq	#3-1,d7 		; 3 bytes vidd p† notten
	jsr	makeinversjamn
	move.w	#-1,currentsample
	bsr	checkifsamplechanged
redans†plotsomdetg†r:
	rts

setlownoise:			; Pendlar om LowNoise skall vara p†
	move.l	bildminne,a0
	lea	((28*168)+129)+8(a0),a1	; a1 till bilden
	move.l	a1,a2
	moveq	#4-1,d7 		; 4 bytes vidd p† notten
	jsr	makeinversojamn

	move.w	#$2700,sr
	not.w	lownoise
	move.w	#-1,mainisnotzero
	move.w	oldmain,d4
	sub.w	#28,d4
	lea	main,a0			; S„tt volymen normalt
	add.w	d4,d4
	move.w	#$07ff,$ffff8924.w
	move.w	(a0,d4.w),$ffff8922.w
	move.w	#$2300,sr
	tst.w	runwithtimerA
	beq.s	intestollar
	move.w	#$2100,sr
intestollar:
	rts


ritautencolorform:		; Skriver ut en color form till bildminnet
	moveq	#41-1,d7
loopautencolorform:
	move.l	(a2),(a3)
	move.l	8(a2),8(a3)
	move.l	16(a2),16(a3)
	move.b	24(a2),24(a3)
	move.b	26(a2),26(a3)
	lea	168(a3),a3
	lea	32(a2),a2
	dbra	d7,loopautencolorform
	rts

sparcolorform:		; Skriver ut en color form till bildminnet
	moveq	#41-1,d7
loopsparcolorform:
	move.l	(a2),(a3)
	move.l	8(a2),8(a3)
	move.l	16(a2),16(a3)
	move.b	24(a2),24(a3)
	move.b	26(a2),26(a3)
	lea	168(a2),a2
	lea	32(a3),a3
	dbra	d7,loopsparcolorform
	rts

opencolormenu:			; ™ppnar colormenyn
	move.l	#colorkoors,losapositioner
	move.l	#colorrots,losarutiner
	move.l	bildminne,a0
	lea	(18*168+88)+8(a0),a1		; a1 till bilden
	add.l	#94680+2128,a0		; a0 till colorformen
	move.l	a1,a2
	lea	4(a0),a3		; Spar bakgrunden
	bsr.s	sparcolorform
	move.l	a1,a3
	move.l	a0,a2		; Rita ut den
	bsr	ritautencolorform
	rts

slutamedcolor:		; Tar hand om n„r man trycker p† OK i Colormenyn
	move.l	#optionskoors,losapositioner
	move.l	#optionsrots,losarutiner
	move.l	bildminne,a0
	lea	(18*168+88)+8(a0),a1		; a1 till bilden
	add.l	#94680+2128,a0	; a0 till colorformen
	move.l	a1,a2
	move.l	a0,a3			; Spar bakgrunden
	bsr	sparcolorform
	move.l	bildminne,a0
	lea	(18*168+88)+8(a0),a1		; a1 till bilden
	move.l	a1,a3
	add.l	#94680+2128,a0	; a0 till colorformen
	lea	4(a0),a2		; Ladda upp bakgrunden
	bsr	ritautencolorform
	rts

empty1:	dc.b	' ',0
selectorstring:
	dc.b	'>',0

cleartheselector:
	lea	empty1,a3
	move.w	#208,d0			; x
	move.w	#21,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen
	lea	empty1,a3
	move.w	#208,d0			; x
	move.w	#28,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen
	lea	empty1,a3
	move.w	#208,d0			; x
	move.w	#35,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen
	lea	empty1,a3
	move.w	#208,d0			; x
	move.w	#42,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen
	rts

changesstatusbar:
	lea	statusbar,a1
	cmp.w	#28,d7
	bge.s	intemindreanmusy2
	move.w	#28,d7
intemindreanmusy2:
	cmp.w	#55-4,d7
	ble.s	intestorreanmusy2
	move.w	#55-4,d7
intestorreanmusy2:
	move.w	d7,d4
	sub.w	#28,d4
	move.w	(a2),d2
	mulu	#168,d7
	mulu	#168,d2
	add.l	bildminne,d2
	add.l	d3,d2
	move.l	d2,a3
	and.b	#%10000001,(a3)
	and.b	#%10000001,2(a3)
	and.b	#%10000001,168(a3)
	and.b	#%10000001,170(a3)
	and.b	#%10000001,336(a3)
	and.b	#%10000001,338(a3)
	and.b	#%10000001,504(a3)
	and.b	#%10000001,506(a3)
	add.w	d7,a0
	move.b	(a1)+,(a0)
	move.b	(a1)+,2(a0)
	move.b	(a1)+,168(a0)
	move.b	(a1)+,170(a0)
	move.b	(a1)+,336(a0)
	move.b	(a1)+,338(a0)
	move.b	(a1)+,504(a0)
	move.b	(a1)+,506(a0)
	rts

changethesliders:
	move.w	(a6)+,d7
	moveq	#97,d3
	move.l	oldR,a2
	move.l	bildminne,a0
	lea	97(a0),a0		; Žndra p† R-slidern
	bsr	changesstatusbar
	move.w	(a6)+,d7
	moveq	#104,d3
	move.l	oldG,a2
	move.l	bildminne,a0
	lea	104(a0),a0		; Žndra p† G-slidern
	bsr	changesstatusbar
	move.w	(a6)+,d7
	moveq	#105,d3
	move.l	oldB,a2
	move.l	bildminne,a0
	lea	105(a0),a0		; Žndra p† B-slidern
	bsr	changesstatusbar
	rts


selectcolor0:
	tst.w	selectedcolor
	beq.s	intev„lj0f„rgenigen
	clr.w	selectedcolor
	bsr	cleartheselector
	lea	selectorstring,a3
	move.w	#208,d0			; x
	move.w	#21,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen
	lea	oldR0,a6
	bsr.s	changethesliders
	move.l	#$FFFF8240,colorpointers
	move.l	#screenpalette,colorpointers+4
	move.l	#texteditpalette,colorpointers+8
	move.l	#oldR0,oldR
	move.l	#oldG0,oldG
	move.l	#oldB0,oldB
intev„lj0f„rgenigen:
	rts

selectcolor1:
	cmp.w	#1,selectedcolor
	beq.s	intev„lj1f„rgenigen
	move.w	#1,selectedcolor
	bsr	cleartheselector
	lea	selectorstring,a3
	move.w	#208,d0			; x
	move.w	#28,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen
	lea	oldR1,a6
	bsr	changethesliders
	move.l	#$FFFF8240+2,colorpointers
	move.l	#screenpalette+2,colorpointers+4
	move.l	#texteditpalette+2,colorpointers+8
	move.l	#oldR1,oldR
	move.l	#oldG1,oldG
	move.l	#oldB1,oldB
intev„lj1f„rgenigen:
	rts

selectcolor2:
	cmp.w	#2,selectedcolor
	beq.s	intev„lj2f„rgenigen
	move.w	#2,selectedcolor
	bsr	cleartheselector
	lea	selectorstring,a3
	move.w	#208,d0			; x
	move.w	#35,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen
	lea	oldR2,a6
	bsr	changethesliders
	move.l	#$FFFF8240+4,colorpointers
	move.l	#screenpalette+4,colorpointers+4
	move.l	#texteditpalette+4,colorpointers+8
	move.l	#oldR2,oldR
	move.l	#oldG2,oldG
	move.l	#oldB2,oldB
intev„lj2f„rgenigen:
	rts

selectcolor3:
	cmp.w	#3,selectedcolor
	beq.s	intev„lj3f„rgenigen
	move.w	#3,selectedcolor
	bsr	cleartheselector
	lea	selectorstring,a3
	move.w	#208,d0			; x
	move.w	#42,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen
	lea	oldR3,a6
	bsr	changethesliders
	move.l	#$FFFF8240+6,colorpointers
	move.l	#screenpalette+6,colorpointers+4
	move.l	#texteditpalette+6,colorpointers+8
	move.l	#oldR3,oldR
	move.l	#oldG3,oldG
	move.l	#oldB3,oldB
intev„lj3f„rgenigen:
	rts

oldR:	dc.l	oldR0
oldG:	dc.l	oldG0
oldB:	dc.l	oldB0

oldR0:	dc.w	28+23
oldG0:	dc.w	28+23
oldB0:	dc.w	28+23
oldR1:	dc.w	28+16
oldG1:	dc.w	28+16
oldB1:	dc.w	28+16
oldR2:	dc.w	28+11
oldG2:	dc.w	28+11
oldB2:	dc.w	28+11
oldR3:	dc.w	28+8
oldG3:	dc.w	28+8
oldB3:	dc.w	28+8

RGBdata:dc.w	$F,$F,$7
	dc.w	$7,$E,$6
	dc.w	$6,$D,$5
	dc.w	$C,$C,$4
	dc.w	$B,$3,$3
	dc.w	$A,$2,$9
	dc.w	$9,$1,$8
	dc.w	$8,$8,$0

setcolornow:
	lea	RGBdata,a0
	add.w	d4,d4
	move.w	(a0,d4.w),d2
	move.l	colorpointers+4,a0
	move.w	(a0),d3
	and.w	d1,d3
	lsl.w	d0,d2
	or.w	d2,d3		; d3 inneh†ller nu f„rgen
	lea	colorpointers,a0
	moveq	#3-1,d0
skrivinallaf„rgernaibuffrarnaoshiftern:
	move.l	(a0)+,a1
	move.w	numberofcolorwrites,d1
	subq.w	#1,d1
skrivnuenbuffer:
	move.w	d3,(a1)+
	dbra	d1,skrivnuenbuffer
	dbra	d0,skrivinallaf„rgernaibuffrarnaoshiftern
	rts


colorR:
	moveq	#97,d3
	move.l	oldR,a2
	move.l	bildminne,a0
	lea	97(a0),a0
	jsr	movestatusbartomousey
	moveq	#8,d0
	move.w	#$0FF,d1
	bsr.s	setcolornow
	rts

colorG:
	moveq	#104,d3
	move.l	oldG,a2
	move.l	bildminne,a0
	lea	104(a0),a0
	jsr	movestatusbartomousey
	moveq	#4,d0
	move.w	#$F0F,d1
	bsr.s	setcolornow
	rts

colorB:
	moveq	#105,d3
	move.l	oldB,a2
	move.l	bildminne,a0
	lea	105(a0),a0
	jsr	movestatusbartomousey
	moveq	#0,d0
	move.w	#$FF0,d1
	bsr	setcolornow
	rts

varsn„llk”pOctan:
	movem.l	d0-d7/a0-a6,-(sp)
	lea	intefardigstrang1,a5
	lea	intefardigstrang2,a6
	jsr	makejeppform
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SaveOptions:				; Rutinen som sparar aktuella
	move.w	$ffff8900.w,gammalfart
	lea	sparaopt1,a5		; inst„llningar
	lea	sparaopt2,a6
	jsr	makeform
	tst.w	d0
	bmi	sparainteoptionsen

	lea	termtonebuff,a0
	move.w	#(888/4)-1,d0
rensarentinnanspara:
	clr.l	(a0)+
	dbra	d0,rensarentinnanspara

	lea	termtonebuff,a0	; Kopiera ner inst„llningarna te buffern
	move.l	#'OCTA',(a0)	; Headern
	move.l	#'SAVE',4(a0)
	move.l	#'0.96',8(a0)	; Version av Octan som sparat .INFen

	move.w	$FFFF8240.w,12(a0)	; Defaultf„rger
	move.w	$FFFF8242.w,14(a0)
	move.w	$FFFF8244.w,16(a0)
	move.w	$FFFF8246.w,18(a0)

	move.w	bordercounter,30(a0)	; Antal defaultnoppar

	lea	modpath,a1	; Modulpath
	lea	32(a0),a2
	bsr	koppainpathen
	lea	path,a1		; Samplingspath
	lea	96(a0),a2
	bsr	koppainpathen
	lea	terpath,a1	; UCDMpath
	lea	160(a0),a2
	bsr	koppainpathen
	lea	blkpath,a1	; Blockpath
	lea	224(a0),a2
	bsr	koppainpathen
	lea	delpath,a1	; Deletepath
	lea	288(a0),a2
	bsr	koppainpathen

	lea	termodyname1,a1
	lea	352(a0),a2
	bsr	skrivtillsnolladockmax76tecken
	lea	termodyname2,a1
	lea	428(a0),a2
	bsr	skrivtillsnolladockmax76tecken
	lea	termodyname3,a1
	lea	504(a0),a2
	bsr	skrivtillsnolladockmax76tecken
	lea	termodyname4,a1
	lea	580(a0),a2
	bsr	skrivtillsnolladockmax76tecken
	move.w	hurh†rdbelastning+2,656(a0)	; Antal rader att visa
	move.w	hurh†rdbelastning+6,658(a0)
	move.w	hurh†rdbelastning+10,660(a0)
	move.w	hurh†rdbelastning+14,662(a0)
	move.w	currenttermo,664(a0)	; Vilken „r termody „r vald
	move.w	termotones,666(a0)	; Antal toner

	move.w	antalkanaler,668(a0)	; Antal kanaler
	tst.w	termodyonoff
	beq.s	antalkaneler„rdetr„tta
	move.w	oldchannum,668(a0)
antalkaneler„rdetr„tta:
	move.w	basspeed,670(a0)	; Grundfrekvens
	move.w	frekvens,672(a0)	; Uppspelningsfrekvens
	moveq	#0,d0
	or.w	aalias,d0	; AAlias
	tst.w	lownoise
	beq.s	lownoise„rav
	or.w	#%10,d0
lownoise„rav:
	tst.w	usetempo	; Tempo
	bne.s	tempo„rav
	or.w	#%1000,d0
tempo„rav:
	tst.w	tangrepp†av	; Tangentbordsrepetition
	beq.s	tangrep„rav
	or.w	#%10000,d0
tangrep„rav:
	tst.w	loopordupp	; Loopad
	beq.s	loop„rav
	or.w	#%100000,d0
loop„rav:
	tst.w	trashupdate	; Trashupdatering
	beq.s	trash„rav
	or.w	#%1000000,d0
trash„rav:
	tst.w	VUp†av		; VUmetrar
	beq.s	VU„rav
	or.w	#%10000000,d0
VU„rav:
	tst.w	CallEvntTimerAsOftenAsPossible
	beq.s	intedelatid	; Timeshare med GEM?
	or.w	#%100000000,d0
intedelatid:
	tst.w	termodyonoff
	beq.s	intetermodyp†	; Termody skall vara p† vid start
	or.w	#%1000000000,d0
intetermodyp†:

	move.w	d0,674(a0)	; Flaggor
	move.b	edmode+1,676(a0)	; Editmode
	move.b	bsmode+1,677(a0)	; Backspacemode
	move.b	blkmode+1,678(a0)	; Blockmode
	move.b	wrtmode+1,679(a0)	; Writningmode
	move.b	freqonkeyboard+1,d0	; Frekvens (Up/Low)
	lsl.b	#4,d0
	or.b	blockhandling+1,d0	; Blockhantering (All/curr)
	move.b	d0,680(a0)
	move.b	stepswhenpressing+1,681(a0)	; Step
	lea	682(a0),a2
	lea	speedandupdatingdata,a1
	moveq	#12-1,d0
skrivditmaxpattvisa2:
	move.l	(a1)+,(a2)+
	dbra	d0,skrivditmaxpattvisa2

	move.b	oldbass+1,730(a0)
	move.b	oldtreble+1,731(a0)
	move.b	oldmain+1,732(a0)
	move.b	oldleft+1,733(a0)
	move.b	oldright+1,734(a0)
	move.b	oldrep+1,735(a0)
	move.b	olddel+1,736(a0)
	move.b	oldmousedel+1,737(a0)

	move.w	maxpatterns,738(a0)	; Max pattern att reservera
	move.l	MainMemLength,740(a0)	; Minne att requesta vid startup

	lea	runpath,a1	; Exekveringspath
	lea	824(a0),a2
	bsr	koppainpathen

	move.b	#255,linestowait
	move.w	#1,donotdoanymusicorsomeshit
	clr.w	$ffff8900.w

	clr.w	-(sp)		; Skriv ner inst„llningarna
	pea	saveoptionspath
	move.w	#$3c,-(sp)
	trap	#1		; Skapa filen
	addq.w	#8,sp
	tst.l	d0
	bpl.s	alltokiinfet
	jmp	couldnotcreatefile
alltokiinfet:
	move.w	d0,handle
	move.l	#888,d0
	lea	termtonebuff,a0	; Spara infon
	jsr	savethisblock
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1		; St„ng filen
	addq.w	#4,sp
sparainteoptionsen:
	move.w	gammalfart,$ffff8900.w
	move.b	#199,linestowait
	clr.w	donotdoanymusicorsomeshit
	rts

saveoptionspath:
	ds.b	100
optionsloaded:
	dc.w	0

koppainpathen:			; Kopiera tills noll, dock max 63 tecken
	moveq	#63,d0
koppia:	tst.b	(a1)
	beq.s	slutamedkoppia
	move.b	(a1)+,(a2)+
	subq.w	#1,d0
	bne.s	koppia
slutamedkoppia:
	clr.b	(a2)
	rts

skrivtillsnolladockmax76tecken:
	moveq	#63,d0
koppia2:tst.b	(a1)
	beq.s	slutamedkoppia2
	move.b	(a1)+,(a2)+
	subq.w	#1,d0
	bne.s	koppia2
slutamedkoppia2:
	clr.b	(a2)
	rts


;===================================================== Minneshanteraren ==

				; Utf”rs vid startuppen av systemet
setupinternalmemhandler:	; d0 ”nskat antal bytes
	move.l	d0,d7
	move.l	d0,-(sp)
	move.w	#$48,-(sp)
	trap	#1		; F”rs”k beg„r ”nskad m„ngd minne
	addq.l	#6,sp
	tst.l	d0
	bne.s	vifickden”nskademinnesl„ngden
	move.l	#-1,-(sp)	; Vi fick inte ”nskat antal bytes
	move.w	#$48,-(sp)
	trap	#1		; Ta reda p† maximalt antal bytes
	addq.l	#6,sp
	and.l	#$FFFFFFFE,d0
	sub.l	#32000,d0
	cmp.l	#$80*64*32,d0	; Žr det tillr„ckligt med minne?
	bge.s	detr„ckertillf”rattstartaoctan
g†rejattstartaminneshanteraren:
	moveq	#-1,d0		; Nix, abort!
	rts
detr„ckertillf”rattstartaoctan:
	move.l	d0,d7
	move.l	d0,-(sp)
	move.w	#$48,-(sp)
	trap	#1		; Beg„r framr„knad m„ngd minne
	addq.l	#6,sp
	tst.l	d0
	bmi.s	g†rejattstartaminneshanteraren
vifickden”nskademinnesl„ngden:
	move.l	d0,MainMem	; Spar undan huvudminnespekarna + l„ngden
	move.l	d7,MainMemLength

	lea	mallocblock,a0
	moveq	#0,d1
	move.l	d0,(a0)+	; Se till att det finns topminne
	move.l	d1,(a0)+
	moveq	#98/2-1,d2	; Rensa, s† att det inte finns n†got beg„r minne
rensadeninternamallochanteraren:
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbra	d2,rensadeninternamallochanteraren
	add.l	d7,d0
	move.l	d0,(a0)+	; Se till att det finns bottenminne
	move.l	d1,(a0)+

	move.l	MainMemLength,d0
	tst.l	d0		; Returnera huvudblockets l„ngd
	rts			; Om -1 fel i startuppen

closeinternalmemhandler:
	move.l	MainMem,-(sp)
	move.w	#$49,-(sp)
	trap	#1		; Sl„pp huvudminnet, nu kan ej
	addq.l	#6,sp		; minneshanteraren anv„ndas l„ngre
	clr.l	MainMem
	tst.l	d0		; Returnera felkod vid sl„ppning av minnet
	rts

		; ™ka/minska l„ngden p† ett redan beg„rt minnesblock
reformatmemory:		; a0 pekar mot blocket   d0 nya l„ngden
	move.w	$ffff8900.w,-(sp)
	clr.b	$ffff8901.w		; Stop DMA
	move.w	donotdoanymusicorsomeshit,-(sp)
	move.w	#1,donotdoanymusicorsomeshit

	lea	mallocblock+8,a1
	lea	mallocpointers+4,a2
	moveq	#98-1,d1
letar„ttp†r„ttpositioniminneslistan24:
	cmp.l	(a1),a0		; Leta r„tt p† pekaren i minneslistan
	beq.s	nuhittadevidenviskullerensa24
	addq.w	#8,a1
	addq.w	#4,a2
	dbra	d1,letar„ttp†r„ttpositioniminneslistan24
	move.w	(sp)+,donotdoanymusicorsomeshit
	move.w	(sp)+,$ffff8900.w
	moveq	#-1,d0
	tst.l	d0
	rts
nuhittadevidenviskullerensa24:
	cmp.l	4(a1),d0
	beq	det„rsammal„ngdtillbakautanfelkod
	blt	minskablockstorleken
	move.l	(a2),-(sp)
	move.l	d0,-(sp)
	move.l	4(a1),-(sp)
	lea	8(a1),a4
	moveq	#98-1,d1
letar„ttp†r„ttpositioniminneslistan243:
	tst.l	(a4)		; Leta r„tt p† pekaren i minneslistan
	bne.s	nuhittadevidenviskullerensa243
	addq.w	#8,a4
	dbra	d1,letar„ttp†r„ttpositioniminneslistan243
	lea	12(sp),sp
	move.w	(sp)+,donotdoanymusicorsomeshit
	move.w	(sp)+,$ffff8900.w
	moveq	#-1,d0
	tst.l	d0
	rts
nuhittadevidenviskullerensa243:
	move.l	(a4),d5
	move.l	(a1),d4
	add.l	d0,d4
	cmp.l	d5,d4
	bgt.s	byggomminneteftersomviannarsskriver”verefterkommandedata
	move.l	d0,4(a1)
	moveq	#0,d0
	bra.s	rensadelen
byggomminneteftersomviannarsskriver”verefterkommandedata:
	move.l	a1,a6			; F”rs”k ”ka l„ngden p† minnet
	move.l	d0,d7
	bsr	koppatill”nskeminne
	sub.l	#mallocblock,a6
	add.l	#mallocblocksort,a6
	move.l	d7,4(a6)
	bsr	sortoutmemory		; Sortera minnet efter ”nskem†l
rensadelen:
	move.l	(sp)+,d1
	move.l	(sp)+,d2
	move.l	(sp)+,a2
	tst.l	d0
	bmi.s	ajajajajaj
	move.l	(a2),a2
	add.l	d1,a2
	move.l	d2,d3
	sub.l	d1,d2	
	lsr.l	#1,d2
	moveq	#0,d1
	movem.l	d0-d7/a0-a6,-(sp)
	lea	rensameddelande,a3	; Pekare till str„ng
	move.w	#80,d0			; x		Songnamn
	move.w	#85,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen
	movem.l	(sp)+,d0-d7/a0-a6
rensadennyadelenavminnet:
	move.w	d1,(a2)+
	subq.l	#1,d2
	bne.s	rensadennyadelenavminnet
	move.l	d3,-(sp)
	bsr	fixatillsamnamnet
	move.l	(sp)+,d0
ajajajajaj:
	move.w	(sp)+,donotdoanymusicorsomeshit
	move.w	(sp)+,$ffff8900.w
	tst.l	d0
	rts
minskablockstorleken:
	move.w	(sp)+,donotdoanymusicorsomeshit
	move.w	(sp)+,$ffff8900.w
	move.l	d0,4(a1)		; Minska l„ngden
	tst.l	d0
	rts
det„rsammal„ngdtillbakautanfelkod:	; Samma l„ngd
	move.w	(sp)+,donotdoanymusicorsomeshit
	move.w	(sp)+,$ffff8900.w
	tst.l	d0
	rts

koppatill”nskeminne:		; Skrivet ”ver minneslistan till
	lea	mallocblock,a0	; ”nskeminneslistan
	lea	mallocblocksort,a1
	moveq	#100-1,d0
kopiera”verminnetill”nskebuffern:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,kopiera”verminnetill”nskebuffern
	rts

sortoutmemory:		; Sorterar minneslistan efter ”nskeminneslistan
	move.w	$ffff8900.w,-(sp)
	clr.b	$ffff8901.w		; Stop DMA

	lea	v„ntameddelande,a3	; Pekare till str„ng
	move.w	#80,d0			; x		Songnamn
	move.w	#85,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen

	tst.l	editorpek
	bne	cantmovewhilein8editor

	lea	samplestarts,a0
	lea	datastarts+32*4,a1
	moveq	#32-1,d1
sparaundansambakpekarna:
	move.l	(a0)+,(a1)+
	dbra	d1,sparaundansambakpekarna

	lea	mallocblock,a0
	move.l	a0,a1
	moveq	#99-1,d0
letarr„ttp†sistanv„ndaunmoveableblocket:
	tst.l	4(a0)
	bpl.s	inteettoflyttbartblock
	move.l	a0,a1		; Leta r„tt p† sista unmoveable
inteettoflyttbartblock:		; blocket
	addq.w	#8,a0
	dbra	d0,letarr„ttp†sistanv„ndaunmoveableblocket

	move.l	a1,a4
	sub.l	#mallocblock,a4
	add.l	#mallocblocksort,a4
	move.l	4(a1),d4	; Ta reda p† pekaren till slutet av
	and.l	#$7FFFFFFF,d4	; det unmoveable-blocket
	add.l	(a1),d4

	addq.w	#8,a1
	moveq	#0,d3		; Ta reda p† hur ”nskeminnet skall se
hittaettv„lanv„ntblocksort:	; ut (storleksm„ssigt)
	cmp.l	#mallocblocksort+(99*2*4),a4
	bge.s	aborteraviharkommittillslutetsort
	tst.l	4(a4)			; Leta r„tt p† ett anv„nt block
	bne.s	ettv„lanv„ntblockharvinuhittatsort
	addq.w	#8,a4			; i listan
	bra.s	hittaettv„lanv„ntblocksort
ettv„lanv„ntblockharvinuhittatsort:
	add.l	4(a4),d3
	addq.w	#8,a4
	bra.s	hittaettv„lanv„ntblocksort
aborteraviharkommittillslutetsort:
	move.l	MainMem,d1
	add.l	MainMemLength,d1
	sub.l	d4,d1		; Ok, r„cker minnet till f”r att g”ra
	cmp.l	d1,d3		; om det till det ”nskade?
	bgt	den”nskningengickinteabortera

	move.l	MainMem,d0
	lea	mallocblocksort+8,a0	; St„ll in pekarna s† att det inte
	moveq	#98-1,d1		; blir n†gra tomma minnesluckor
r„knauthurpekarnaskallst†nu:
	tst.l	4(a0)
	beq.s	tomtomtomtom
	move.l	d0,(a0)
	add.l	4(a0),d0
tomtomtomtom:
	addq.w	#8,a0
	dbra	d1,r„knauthurpekarnaskallst†nu

	moveq	#0,d7			; Om denna „r 0 efter en loop, s†
flyttaomminnesblocken:			; „r minnesflyttningen klar
	lea	mallocblocksort+8,a0
	lea	mallocblock+8,a1
	moveq	#0,d7
	moveq	#98-1,d0
vilketblockskallviflytta:
	move.l	(a0),a2
	cmp.l	(a1),a2			; Ligger blocket p† samma plats?
	beq.s	blocketliggerp†sammaplats
	bgt.s	flyttablocketh”greuppiminnet
	addq.w	#1,d7
	move.l	(a0),a4
	move.l	(a1),a5
	move.l	4(a1),d3
	lsr.l	#1,d3
flyttaminnesblocketupp†tnu:
	move.w	(a5)+,(a4)+		; Flytta minnes upp†t
	subq.l	#1,d3
	bne.s	flyttaminnesblocketupp†tnu
	move.l	(a0),(a1)		; Žndra pekaren
	move.l	4(a0),4(a1)
inteflyttadennaupp†tf”rd†f”rst”rviminnesblocket:
	bra.s	harredanflyttatnerminnetenbit
flyttablocketh”greuppiminnet:
	addq.w	#1,d7
	lea	8(a0),a2
	lea	8(a1),a3
letaeftersenareblock:			; Leta r„tt p† ett senare
	tst.l	(a2)			; block
	bne.s	hittatettsenareblock
	addq.w	#8,a2
	addq.w	#8,a3
	bra.s	letaeftersenareblock
hittatettsenareblock:
	move.l	(a0),d2
	add.l	4(a0),d2
	cmp.l	(a3),d2
	bgt.s	inteflyttadennaner†tf”rd†f”rst”rviminnesblocket
	move.l	(a0),a4
	move.l	(a1),a5
	add.l	4(a1),a4
	add.l	4(a1),a5
	move.l	4(a1),d3
	lsr.l	#1,d3
flyttaminnesblocketner†tnu:
	move.w	-(a5),-(a4)		; Flytta minnes ner†t
	subq.l	#1,d3
	bne.s	flyttaminnesblocketner†tnu
	move.l	(a0),(a1)		; Žndra pekaren
	move.l	4(a0),4(a1)
inteflyttadennaner†tf”rd†f”rst”rviminnesblocket:
harredanflyttatnerminnetenbit:
blocketliggerp†sammaplats:
	addq.w	#8,a0
	addq.w	#8,a1
	dbra	d0,vilketblockskallviflytta
	tst.w	d7
	bne.s	flyttaomminnesblocken

	lea	mallocpointers+4,a1	; Dax att flytta om minneslistan
	lea	mallocblocksort+4*2,a0	; s† att det inte finns n†gra
	moveq	#97,d0			; tomma positioner som vi inte kan
fylligentomrumiminneslistan:		; anv„nda
	tst.l	(a0)			; Anv„nds denna?
	bne.s	denposenanv„ndsredansomtur„r
	lea	8(a0),a2		; Nej, leta fram en som anv„nds
	lea	4(a1),a3
letaefterenpossomanv„ndsefterdenna:
	cmp.l	#mallocblocksort+(99*4*2),a2	; Sista, avbryt
	bge.s	okviharsorteratf„rdigtlistan
	tst.l	(a2)			; Hittat en?
	bne.s	nuhittadevienilistan
	addq.w	#8,a2			; Nix, forts„tt leta
	addq.w	#4,a3
nuhittadevienilistan:
	move.l	(a2),(a0)		; Jeeepps, flytta ner den
	move.l	4(a2),4(a0)
	move.l	(a3),(a1)
	clr.l	(a2)
	clr.l	(a2)
	clr.l	(a3)
denposenanv„ndsredansomtur„r:
	addq.w	#8,a0
	addq.w	#4,a1
	dbra	d0,fylligentomrumiminneslistan
okviharsorteratf„rdigtlistan:

	lea	mallocpointers+4,a2	
	lea	mallocblock+4*2,a0	; Dax att klarg”ra att
	lea	mallocblocksort+4*2,a1	; ”nskelistan „r den
	moveq	#98,d0			; verkliga, samt skiva ner
flyttaom”nskebuffertillverklig:		; de nya pekarna
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	tst.l	(a2)+
	beq.s	inteskrivanypekareivariabeln
	move.l	-4(a2),a3		; Ny pekare
	move.l	-8(a1),(a3)
inteskrivanypekareivariabeln:
	dbra	d0,flyttaom”nskebuffertillverklig

	lea	samplestarts,a0
	lea	datastarts,a1
	lea	32*4(a1),a2
	moveq	#32-1,d1
r„knaombakpekarna:
	move.l	(a1),d2
	sub.l	(a2)+,d2
	add.l	(a0)+,d2
	move.l	d2,(a1)+
	dbra	d1,r„knaombakpekarna

	tst.l	editorpek
	beq.s	struntaiattkollauppdetta
	clr.l	oldfulleditorline
struntaiattkollauppdetta:

	bsr.s	fixatillsamnamnet
	move.w	(sp)+,$ffff8900.w
	moveq	#0,d0		; Meddela att allt gick fiiint
	tst.l	d0
	rts
den”nskningengickinteabortera:
	bsr.s	fixatillsamnamnet
	move.w	(sp)+,$ffff8900.w
	moveq	#-1,d0		; Abortera med felkod
	tst.l	d0
	rts
cantmovewhilein8editor:
	movem.l	d0-d7/a0-a6,-(sp)
	lea	reformaterr1,a5
	lea	reformaterr2,a6
	jsr	makejeppform
	movem.l	(sp)+,d0-d7/a0-a6
	bsr.s	fixatillsamnamnet
	move.w	(sp)+,$ffff8900.w
	moveq	#-1,d0		; Abortera med felkod
	tst.l	d0
	rts

fixatillsamnamnet:
	jsr	refreshtheplayerpointers
fixatillsamnamnetutanrefresh:
	lea	rensav„ntaameddelande,a3; Pekare till str„ng
	move.w	#80,d0			; x
	move.w	#85,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen
	tst.w	whichsample
	beq.s	enfeaturesamplingspecialare
	move.w	whichsample,d0
	subq.w	#1,d0
	mulu	#30,d0
	add.l	#modsam,d0
	move.l	d0,a3
	lea	32*30(a3),a3
	bra.s	skrivnur†
enfeaturesamplingspecialare:
	lea	tom21,a3
skrivnur†:
	move.w	#80,d0			; x		Songnamn
	move.w	#85,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen
	rts

rebuildmemory:		; Bygg om minnet
	move.w	donotdoanymusicorsomeshit,-(sp)
	move.w	#1,donotdoanymusicorsomeshit
	movem.l	a0-a6/d0-d7,-(sp)
	lea	sample,a5
	move.w	#1100*3*2/4,d5
rensaspelbuffern34:			; Rensa playbuffern
	clr.l	(a5)+
	dbra	d5,rensaspelbuffern34

	tst.l	editorpek
	beq.s	struntaiattkollauppdetta2
	clr.l	oldfulleditorline
struntaiattkollauppdetta2:

	bsr	koppatill”nskeminne
	bsr	sortoutmemory		; Sortera minnet efter ”nskem†l

	movem.l	(sp)+,a0-a6/d0-d7
	move.w	(sp)+,donotdoanymusicorsomeshit
	rts

		; L„mnar tillbaka beg„rt minne ur den interna buffern
free:		; a0 pekaren till blocket
	movem.l	a0/a1/d2,-(sp)
	lea	mallocblock+8,a1
	moveq	#98-1,d0
letar„ttp†r„ttpositioniminneslistan:
	cmp.l	(a1),a0		; Leta r„tt p† pekaren i minneslistan
	beq.s	nuhittadevidenviskullerensa
	addq.w	#8,a1
	dbra	d0,letar„ttp†r„ttpositioniminneslistan
	movem.l	(sp)+,a0/a1/d2
	moveq	#-1,d0		; Hittade inte pekaren i minneslistan
	tst.l	d0
	rts
nuhittadevidenviskullerensa:
	clr.l	(a1)		; Rensa minnet
	clr.l	4(a1)
	move.l	a1,d2
	sub.l	#mallocblock,d2
	lsr.l	#1,d2
	add.l	#mallocpointers,d2
	move.l	d2,a1		; Rensa pekaren till variabeln s† att
	clr.l	(a1)		; vi inte rebuildar det minnet oxo
	movem.l	(sp)+,a0/a1/d2
	moveq	#0,d0		; Ingen felkod
	tst.l	d0
	rts

				; d0 l„ngd    a0 pekare till variabel
firstblockalloc:		; Allocerar minnet f”rst i minnet
	addq.l	#4,d0
	movem.l	d0/a0,-(sp)
	bsr	getmemstatus
	movem.l	(sp)+,d0/a0
	cmp.l	d0,d5
	blt	kaaaaaaaaaaaaaaaaaaaak
	move.l	d0,d7
	move.l	a0,a6
	bsr	koppatill”nskeminne
	lea	mallocblock+8,a4
	lea	mallocblocksort+8,a0
	lea	mallocpointers+4,a2
	moveq	#-1,d1
	moveq	#98-1,d0		; Kolla igenom minneslistan
kollaomdetfinnsetttomtblock:		; om det finns n†gon ledig
	tst.l	(a0)			; position i minneslistan
	beq.s	detfinnsettledigtblock
	addq.w	#8,a0
	addq.w	#4,a2
	addq.w	#8,a4
	addq.w	#1,d1
	dbra	d0,kollaomdetfinnsetttomtblock
	moveq	#0,d0
	tst.l	d0
	rts
detfinnsettledigtblock:
	lea	-8(a0),a1
	lea	-4(a2),a3
	tst.w	d1
	bmi.s	f”rsta„rtom
kopieraneriminneslistan:	; Kopiera ner hela skiten i minneslistan
	move.l	(a1),(a0)
	move.l	4(a1),4(a0)
	move.l	(a1),(a4)
	move.l	4(a1),4(a4)
	move.l	(a3),(a2)
	subq.w	#8,a0
	subq.w	#8,a1
	subq.w	#8,a4
	subq.w	#4,a3
	subq.w	#4,a2
	dbra	d1,kopieraneriminneslistan
f”rsta„rtom:
	move.l	MainMem,mallocblocksort+8
	clr.l	mallocblocksort+12
	move.l	MainMem,mallocblock+8
	clr.l	mallocblock+12
	move.l	a6,mallocpointers+4
	move.l	MainMem,(a6)
	move.l	MainMem,a0
	move.l	d7,d0
	bsr	reformatmemory
	bpl.s	intefelvid„ndringenavminnet
	moveq	#0,d0
	tst.l	d0
	rts
kaaaaaaaaaaaaaaaaaaaak:
	moveq	#0,d0		; Det gick inte att flytta om som
	tst.l	d0		; vi ville
	rts
intefelvid„ndringenavminnet:
	move.l	mallocpointers+4,a0
	move.l	(a0),d0
	tst.l	d0
	rts


		; Beg„r minne av den interna buffern
malloc:		; d0 l„ngden  d1 om 1 unmoveble  a0 pekaren till variabeln
	addq.l	#1,d0			; Se till att det bara
	and.l	#$FFFFFFFE,d0		; „r j„mna words-l„ngder
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.s	mallocinternalmem	; F”rs”k (1) att f† minnet
	bne.s	vifickminnet		; Om det inte gick
	bsr	rebuildmemory		; bygg om minnet
	movem.l	(sp)+,d0-d7/a0-a6	; och
	movem.l	d0-d7/a0-a6,-(sp)	; f”rs”k (2) igen
	bsr.s	mallocinternalmem	; Om det inte g†r
	bne.s	vifickminnet
	movem.l	(sp)+,d0-d7/a0-a6
	moveq	#0,d0			; Abort
	tst.l	d0			; Returnera 0
	rts
vifickminnet:				; Vi fick minnet ok
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	(a0),d0
	tst.l	d0			; Returnet positivt
	rts

s”kr„ttp†enplatssomr„cker:
	move.l	a5,a1
	move.l	a5,a4
hittaetttomtblock:
	cmp.l	#mallocblock+(99*2*4),a1
	bge.s	aborteralistanfull
	tst.l	(a1)			; Leta r„tt p† ett tomt block
	beq.s	etttomtblockharvinuhittat
	move.l	a1,a4
	addq.w	#8,a1			; i listan
	bra.s	hittaetttomtblock
etttomtblockharvinuhittat:
	move.l	a1,a2
hittaettanv„ntblock:
	tst.l	(a2)			; Hitta n„sta anv„nda
	bne.s	ettanv„ntblockharvinuhittat
	addq.w	#8,a2
	bra.s	hittaettanv„ntblock
ettanv„ntblockharvinuhittat:
	move.l	(a2),d2		; N„sta blocks pekare
	sub.l	(a4),d2		; minus f”rra blockets pekare
	move.l	4(a4),d3	; minus f”rra blockets l„ngd
	and.l	#$7FFFFFFF,d3	; Anda bort unmovablebiten
	sub.l	d3,d2
	cmp.l	d2,d0		; Finns det tillr„ckligt med minne d„rimellan?
	bgt.s	k”rvidare	; Om inte leta vidare
	moveq	#0,d2		; Retunera pekaren till positionen i
	tst.l	d2		; lista i a1
	rts
k”rvidare:
	addq.w	#8,a1
	bra.s	hittaetttomtblock
aborteralistanfull:		; Listan/minnet fullt
	moveq	#-1,d2
	tst.l	d2
	rts

		; Beg„r minne av den interna buffern
mallocinternalmem:	; d0 l„ngden  d1 om 1 unmoveble  a0 pekaren till variabeln
	cmp.w	#1,d1
	beq.s	requestaettunmovebleminne

	move.l	MainMemLength,d6
	move.l	MainMem,a6
	lea	mallocblock,a5
	bsr.s	s”kr„ttp†enplatssomr„cker; Leta r„tt p† en ledig plats med minne
	bmi.s	couldnotgetmemory	; Listan full/inget minne, abort
	add.l	(a4),d3
	move.l	d3,(a0)		; Skriv ner det beg„rda minnet i listan
	move.l	d3,(a1)
	move.l	d0,4(a1)
	move.l	a1,d2
	sub.l	#mallocblock,d2
	lsr.l	#1,d2
	add.l	#mallocpointers,d2
	move.l	d2,a2		; Spar undan pekaren till variabeln
	move.l	a0,(a2)		; s† att vi kan g”ra en rebuild p† minnet
	move.l	d0,d1
	move.l	d3,a3
	moveq	#0,d2
	lsr.l	#1,d1		; T”m det beg„rda minnet oxo
setillattminnet„rtomt:
	move.w	d2,(a3)+
	subq.l	#1,d1
	bne.s	setillattminnet„rtomt
	tst.l	d0
	rts
requestaettunmovebleminne:	; Beg„r ett unmoveble minnesblock

couldnotgetmemory:
	moveq	#0,d0		; Meddela fel eftersom det inte g†r att
	tst.l	d0		; f† ett unmoveble „n, ej planerad att
	rts			; finnas med i Octalysern heller!

getmemstatus:		; Retunerar hur det st†r till med minnet
	move.l	#-1,-(sp)
	move.w	#$48,-(sp)
	trap	#1		; Ta reda p† systemminnet
	addq.l	#6,sp
	move.l	MainMemLength,d1
	moveq	#0,d2
	moveq	#0,d3
	lea	mallocblock+4,a0
	move.w	#100-1,d4
r„knautanv„ntminne:
	move.l	(a0),d5
	bmi.s	det„reenunmoveableminnesbit
	add.l	d5,d2
	bra.s	detvarinteenunmoveableminnesbit
det„reenunmoveableminnesbit:
	and.l	#$7FFFFFFF,d5
	add.l	d5,d3
detvarinteenunmoveableminnesbit:
	addq.w	#8,a0
	dbra	d4,r„knautanv„ntminne
	move.l	d1,d5
	sub.l	d3,d5	; Retunerar: d0 fritt systemminne
	sub.l	d2,d5	;	     d1 beg„rt internminne
	move.l	d3,d4	;	     d2 anv„nt moveableminne
	add.l	d2,d4	;	     d3 anv„nt unmoveableminne
	rts		;	     d4 totalt anv„nt internminne
			;	     d5 fritt internminne



;================================================ Minneshanterarbuffrar ==


MainMem:dc.l	0	; Huvudminnepekare
MainMemLength:
	dc.l	14680064; L„ngden p† huvudblocket (default 14Mb)
mallocblock:
	ds.l	100*2	; Inneh†ller pekare + l„ngden till mallocsen
mallocblocksort:	; Inneh†ller pekare + l„ngden till mallocsen
	ds.l	100*2	; till f”r sortering av blocket
mallocpointers:		; Pekare till variablerna som Octan h†ller
	ds.l	100	; som minnespekare (till f”r rebuildmem)
v„ntameddelande:
	dc.b	'>> REBUILDING MEMORY <<',0
rensameddelande:
	dc.b	'>>    CLEARING UP    <<',0
rensav„ntaameddelande:
	dc.b	'                       ',0
	even

;=============================================== Variabler samt buffrar ==


h”gtimebit:
	dc.w	$0000
tidsstr„ng:
	dc.b	'00:00',0
tidsr„knare:
	dc.w	50
currenttime:
	dc.w	$0000	; H†ller reda p† hur mycket tid som f”rflutit
extratime:
	dc.w	$FFFF	; Om denna != currenttime, skrivs tiden ut vid tillf„lle
hblisallreadyused:	; Talar om systemet anv„nder HBLen, om s† „r fallet
	dc.w	0	; skall Octalyserns HBL EJ anv„ndas
conv_table:
	dc.w 0,2,4,6,8,10,12,14,1,3,5,7,9,11,13,15
conv_table2:
	dc.w 0,8,1,9,2,10,3,11,4,12,5,13,6,14,7,15
currentpall:	ds.w	16
finalpall:	ds.w	16
colour:		dc.w	1
convert:	dc.w	1
mode:		dc.w	0
fade_mode:	dc.w	0

colorpointers:
	dc.l	$ffff8240,screenpalette,texteditpalette
numberofcolorwrites:
	dc.w	1
selectedcolor:
	dc.w	0
lownoise:
	dc.w	-1	; -1 P†    0 Av
patternupdatetabell:
	dc.w	0,8,4
oldsliderpek:
	dc.l	0
oldsliderlength:
	dc.w	-1
dumpallcommingkeys:
	dc.w	0
oldxforline:
	dc.w	8
drawspeed:
	dc.w	0	; 0 = True   8 = Fast   16 = Plot
oldoldcursorpek:
	dc.l	0
samloopstart:
	dc.l	0
loop1data:
	dc.l	0
sample1pek:
	dc.l	0	; Pekare mot sampling innan loop
sample1len:
	dc.l	0
sampledraw:
	dc.w	0	; 0 = Rita samplingen   1 = Rita ej samplingen
currentsample:
	dc.w	-1
samplemode:
	dc.w	0	; 0 = Mix          1 = Over
lowershower:
	dc.w	0	; 0 = patternet  1 = Sampleeditorn  -1 = 8 kanaler
oldvectors:
	ds.l	62
donotdoanymusic:
	dc.w	0
maxpatterns:
	dc.w	$80
extrapatt:
	dc.w	$80
computerpower:		; Denna variabel anger hur kraftigt processor man har..
	dc.w	0	; Skall testas automatiskt i framtiden. 0 = STe  1 = Hemmabyggd STe (16MHz)  2 = Mega STe   3 = TT
linestowait:
	dc.b	199,0
dowhich:dc.w	1
patternupdate:
	dc.w	0	; 0=Hela patternet 1=3 rader -1=endast tjocka raden
tahandominstrument:
	dc.l	enteratone,endast1e0,sl,kr,hd,ld,enteratone,endast1e0
	dc.l	sl,kr,hd,ld,enteratone,endast1e0,sl,kr
	dc.l	hd,ld,enteratone,endast1e0,sl,kr,hd,ld

freqonkeyboard:
	dc.w	1
freqonit:
	dc.b	'L',0,'U',0
wrtmode:dc.w	1
wrtonit:
	dc.b	'O',0,'R',0,'U',0
edmode:	dc.w	2
edonit:	dc.b	'F',0,'T',0,'A',0,'V',0
blkmode:dc.w	6
bsmode:	dc.w	6
blkonit:dc.b	'F',0,'T',0,'S',0,'C',0,'D',0,'E',0,'A',0
blkdata:dc.l	%11110000000000001111111111111111	; Frekvens
	dc.l	%00000000000000000000111111111111	; Tone
	dc.l	%00001111111111110000111111111111	; Sample
	dc.l	%11111111111111111111000011111111	; Command
	dc.l	%11111111111111111111111100000000	; Data
	dc.l	%11111111111111111111000000000000	; Effekt
	dc.l	%00000000000000000000000000000000	; All
stepswhenpressing:
	dc.w	$01

criticalerrorhandler:
	dc.l	0
mvol:	dc.l	256		; 512 f”r 8 o 6 kanaler samt $40 f”r 4

frekvensjsr:
	dc.l	makeinversojamn
frekvens:
	dc.w	1
gamlafrekvenspek:
	 dc.l	((20*168)+97)+8
antalkanaler:
	dc.w	8		; 8 kanaler default
gamlakanalpek:
	dc.l	36*168+152+8
musrep: dc.l	0		; Rutin att hoppa till vid repetition
	dc.w	0		; Talar om om det „r en rep.knapp
sync:	dc.w	-1
font:	dc.l	0
borderdelay:
	dc.w	6-1
bordercounter:
	dc.w	(3*6)-1
vilkenhbl:
	dc.l	hbl1,hbl2,hbl3
hbler:	dc.l	hbl1
edit:	dc.w	0
monitor:dc.w	0
playplay:
	dc.w	0
patternplay:
	dc.w	0
knappval:
	dc.w	0
fastapositioner:	; Knapptryckningssk„rmen
	dc.w	STATIONAR	; Antal rektanglar - 1 som har motsvarande rutin f”r nertryckning
	dc.w	-1,-1,16,12,0	; Kanal 1 p†/av-knapp
	dc.w	-1,12,16,25,0	; Kanal 2 p†/av-knapp
	dc.w	-1,25,16,38,0	; Kanal 3 p†/av-knapp
	dc.w	-1,38,16,51,0	; Kanal 4 p†/av-knapp
	dc.w	-1,51,16,64,0	; Kanal 5 p†/av-knapp
	dc.w	-1,64,16,77,0	; Kanal 6 p†/av-knapp
	dc.w	-1,77,16,90,0	; Kanal 7 p†/av-knapp
	dc.w	-1,90,16,103,0	; Kanal 8 p†/av-knapp
	dc.w	216,4,223,14,0	; Kanal 1 p†/av-knapp
	dc.w	224,4,231,14,0	; Kanal 2 p†/av-knapp
	dc.w	232,4,239,14,0	; Kanal 3 p†/av-knapp
	dc.w	240,4,247,14,0	; Kanal 4 p†/av-knapp
	dc.w	248,4,255,14,0	; Kanal 5 p†/av-knapp
	dc.w	256,4,263,14,0	; Kanal 6 p†/av-knapp
	dc.w	264,4,271,14,0	; Kanal 7 p†/av-knapp
	dc.w	272,4,279,14,0	; Kanal 8 p†/av-knapp
	dc.w	16,59,71,70,0	; Playknapp
	dc.w	72,59,127,70,0	; Patternknapp
	dc.w	128,59,183,70,0	; Editknapp
	dc.w	184,59,239,70,0	; Stopknapp
	dc.w	240,59,295,70,0	; Monitorknapp
	dc.w	269,73,314,82,0	; Clearknapp

	dc.w	83,3,92,12,1	; Position upp
	dc.w	93,3,102,12,1	; Position ner
	dc.w	83,13,92,22,1	; Pattern upp
	dc.w	93,13,102,22,1	; Pattern ner
	dc.w	83,23,92,32,1	; Length upp
	dc.w	93,23,102,32,1	; Length ner
	dc.w	83,33,92,42,1	; Restart upp
	dc.w	93,33,102,42,1	; Restart ner

	dc.w	3,94,12,103,0	; Scroll kanalerna †t v„nster
	dc.w	305,94,314,103,0; Scroll kanalerna †t h”ger

	dc.w	54,3,62,8,1	; L„gg till 1 i songen
	dc.w	54,8,62,12,1	; Ta bort 1 i songen

	dc.w	113,94,122,103,1; ™ka antal steg att hoppa
	dc.w	123,94,132,103,1; Minska antal steg att hoppa

	dc.w	17,94,59,104,0	; Žndra freq
	dc.w	185,94,203,104,0; Žndra wrtmode f”r blockhanteringen
	dc.w	159,94,168,104,0; Žndra editmoden
	dc.w	167,94,176,104,0; Žndra backspacemoden
	dc.w	175,94,184,104,0; Žndra blockmoden

	dc.w	3,73,70,82,0	; Byt mellan songnamn o samplingar
	dc.w	71,73,268,82,2	; Mata in ett songnamn/byt sample
	dc.w	71,83,268,92,2	; Mata in ett samplingsnamn

	dc.w	64,4,80,11,0	; Mata in pos via tang.bordet.
	dc.w	64,14,80,21,0	; Mata in track via tang.bordet.
	dc.w	64,24,80,31,0	; Mata in length via tang.bordet.
	dc.w	64,34,80,41,0	; Mata in restart via tang.bordet.
	dc.w	96,95,112,103,0	; Mata in steps via tang.bordet.

	dc.w	269,83,314,92,0	; Full editor skall sl†s p†

movecursorkoors:
	dc.w	-1,109,320,231,1; Hela patternet, f”r att placera cursorn
	dc.w	-16,105,-2,234,2; Slidern

	dc.w	316,-1,320,4,0	; G† direkt ut till GEM

	; Dessa anv„nds bara n„r sampleditorn „r p†
	dc.w	12,106,23,112,0		; St„ng sampleeditorn

	dc.w	183,187,208,196,0	; Mix samples
	dc.w	207,187,232,196,0	; Overwrite samples
	dc.w	231,187,256,196,0	; Insert samples

	dc.w	263,187,288,196,0	; True samplingsuppdatering
	dc.w	287,187,312,196,0	; Plot samplingsuppdatering

	dc.w	7,112,312,118,2		; Žndra blockstartpos via str„ck
	dc.w	7,138,312,144,2		; Žndra blockslutpos via str„ck


kommandorutiner:
	dc.l	onoffchannel8	; Kanal 1 p†/av-rutin
	dc.l	onoffchannel7	; Kanal 2 p†/av-rutin
	dc.l	onoffchannel6	; Kanal 3 p†/av-rutin
	dc.l	onoffchannel5	; Kanal 4 p†/av-rutin
	dc.l	onoffchannel4	; Kanal 5 p†/av-rutin
	dc.l	onoffchannel3	; Kanal 6 p†/av-rutin
	dc.l	onoffchannel2	; Kanal 7 p†/av-rutin
	dc.l	onoffchannel1	; Kanal 8 p†/av-rutin
	dc.l	onoffchannel1	; Kanal 1 p†/av-rutin
	dc.l	onoffchannel2	; Kanal 2 p†/av-rutin
	dc.l	onoffchannel3	; Kanal 3 p†/av-rutin
	dc.l	onoffchannel4	; Kanal 4 p†/av-rutin
	dc.l	onoffchannel5	; Kanal 5 p†/av-rutin
	dc.l	onoffchannel6	; Kanal 6 p†/av-rutin
	dc.l	onoffchannel7	; Kanal 7 p†/av-rutin
	dc.l	onoffchannel8	; Kanal 8 p†/av-rutin
	dc.l	playknapp	; Play-rutin
	dc.l	patternknapp	; Pattern-rutin
	dc.l	editknapp	; Edit-rutin
	dc.l	stopknapp	; Stop-rutin
	dc.l	monitorknapp	; Monitor-rutin
	dc.l	clearknapp	; Clear-rutin

	dc.l	addpos		; Position + 1
	dc.l	subpos		; Position - 1
	dc.l	addpatt 	; Pattern + 1
	dc.l	subpatt 	; Pattern - 1
	dc.l	addlength	; Length + 1
	dc.l	sublength	; Length - 1
	dc.l	addrestart	; Restart + 1
	dc.l	subrestart	; Restart - 1

	dc.l	kanalvanster	; Scrolla kanalerna †t v„nster
	dc.l	kanalhoger	; Scrolla kanalerna †t h”ger

	dc.l	laggtill1isongen; L„gg till 1 i songen
	dc.l	draifran1isongen; Ta bort 1 i songen

	dc.l	addstep 	; ™ka antal steg att hopp
	dc.l	substep 	; Minska antal steg att hoppa

	dc.l	chfreq		; Žndra freq p† tang.bordet
	dc.l	chwrt		; Žndra wrtmoden f”r blockhanteringen
	dc.l	chedmod		; Žndra editmoden
	dc.l	chbkspcmod	; Žndra backspacemoden
	dc.l	chblkmod	; Žndra blockmoden

	dc.l	bytsongsample	; Byt mellan songnamn o samplingar
	dc.l	editsongname	; Editera songnamnet/byt sample
	dc.l	editsamplename	; Editera samplingsnamnet

	dc.l	matainpos	; Mata in pos via tang.bordet.
	dc.l	mataintrack	; Mata in track via tang.bordet
	dc.l	matainlength	; Mata in length via tang.bordet
	dc.l	matainrestart	; Mata in restart via tang.bordet
	dc.l	matainsteps	; Mata in steps via tang.bordet

	dc.l	fullsk„rmseditorNU	; Installera fulleditorn

	dc.l	movecursor	; Flytta cursorn med hj„lp av musen
	dc.l	moveuseingslider; Flytta patternet med hj„lp av slidern

	dc.l	GoToGEM		; G† till GEM

	; Dessa anv„nds endast n„r sampleditorn „r p†
	dc.l	bytsamopatt	; St„ng sampleeditorn

	dc.l	setmix		; Mixa samplingarna
	dc.l	setover		; Overwrite samplingarna
	dc.l	setins		; Inserta samplingarna

	dc.l	trueupdatespeed	; True uppdatering av samplingen
	dc.l	plotupdatespeed	; Plot uppdatering av samplingen

	dc.l	changeblkstart	; Žndra blockstarten via str„ck
	dc.l	changeblkend	; Žndra blockslut via str„ck


losapositioner:
	dc.l	huvudlospos		; Pekare till knappar som „ndrar sig

losarutiner:
	dc.l	huvudlosrutiner

huvudlospos:		; Knapptryckningssk„rmen
	dc.w	27-1	; Antal rektanglar - 1 som har motsvarande rutin f”r nertryckning
	dc.w	0,0,0,0,0	; Avlusta proggetrutin
	dc.w	212,20,262,29,0 ; Option-knapp
	dc.w	212,32,262,41,0 ; Disk-knapp
	dc.w	212,44,239,53,0 ; Info-knapp
	dc.w	84,46,93,55,1	; Sampleknapp upp
	dc.w	94,46,103,55,1	; Sampleknapp ner
	dc.w	187,4,196,13,1	; Volym upp
	dc.w	197,4,206,13,1	; Volym ner
	dc.w	187,14,196,23,1 ; Finetune upp
	dc.w	197,14,206,23,1 ; Finetune ner
	dc.w	187,34,196,43,1	; Loopstart upp
	dc.w	197,34,206,43,1	; Loopstart ner
	dc.w	187,44,196,53,1	; Looplength upp
	dc.w	197,44,206,53,1	; Looplength ner
	dc.w	263,32,289,41,0	; Editmeny blev nedtryckt
	dc.w	290,32,315,41,0	; Make-knapp
	dc.w	263,20,315,29,0	; Fulleditor-knapp
	dc.w	64,47,80,54,0	; Mata in aktuell sampling
	dc.w	168,5,184,12,0	; Mata in samplingens volym
	dc.w	152,35,184,42,0	; Mata in loopstarten
	dc.w	152,45,184,52,0	; Mata in loopl„ngden
	dc.w	168,15,184,22,0	; Mata in finetunen
	dc.w	263,44,315,53,0	; Byt mellan att visa sampleeditorn o patternet
	dc.w	240,44,262,53,0	; Visa minnesinfon
	dc.w	187,24,196,33,1	; ™ka samplingsl„ngden
	dc.w	197,24,206,33,1	; Minska samplingsl„ngden
	dc.w	152,25,184,32,0	; Mata in samplingsl„ngden

huvudlosrutiner:
	dc.l	terminateOctan	; Avsluta Octalyser
	dc.l	optionsrutin	; Option-rutin
	dc.l	diskrutinen	; Disk-rutin
	dc.l	inforutinen	; Info-rutin
	dc.l	sampleplus	; Aktuell sample + 1
	dc.l	sampleminus	; Aktuell sample - 1
	dc.l	addvolym	; Aktuell samplevolym + 1
	dc.l	subvolym	; Aktuell samplevolym - 1
	dc.l	addfinetune	; Aktuell samplefinetune + 1
	dc.l	subfinetune	; Aktuell samplefinetune - 1
	dc.l	addloopstart	; Aktuell loopstart + 1
	dc.l	subloopstart	; Aktuell loopstart - 1
	dc.l	addlooplength	; Aktuell looplength + 1
	dc.l	sublooplength	; Aktuell looplength - 1
	dc.l	editrutin	; Edit-rutin
	dc.l	menumakeasample	; Make-meny
	dc.l	fullsk„rmseditorNU	; Installera fulleditorn
	dc.l	matainsample	; Mata in ny aktuell sampling
	dc.l	matainvolym	; Mata in ny samplingsvolym
	dc.l	matainloopstart	; Mata in ny samplingsstart
	dc.l	matainloopl„ngd	; Mata in ny samplingsl„ngd
	dc.l	matainfinetune	; Mata in ny finetune
	dc.l	bytsamopatt	; Byter bild sample/pattern
	dc.l	showmemmenu	; Visa minnesmenyn
	dc.l	addsamlength	; ™ka samplingsl„ngden
	dc.l	subsamlength	; Minska samplingsl„ngden
	dc.l	matainsamlength	; Mata in ny samplingsl„ngd

fullkoors:
	dc.w	2-1
	dc.w	-1,-1,16,246,0	; St„ng fulleditorn
	dc.w	16,-1,336,246,1	; Scrolla patternet

fullrots:
	dc.l	fullsk„rmseditorNU	; St„ng igen fulleditorn
	dc.l	scrollafullpatt	; Scrolla fulleditorpatternet


infokoors:		; Infoval
	dc.w	21-1	; Antal rektanglar - 1 som har motsvarande rutin f”r nertryckning
	dc.w	281,43,310,53,0	; Exit-knapp
	dc.w	249,43,278,53,1	; Next-knapp
	dc.w	217,43,246,53,1	; Prev-knapp
	dc.w	84,46,93,55,1	; Sampleknapp upp
	dc.w	94,46,103,55,1	; Sampleknapp ner
	dc.w	187,4,196,13,1	; Volym upp
	dc.w	197,4,206,13,1	; Volym ner
	dc.w	187,14,196,23,1 ; Finetune upp
	dc.w	197,14,206,23,1 ; Finetune ner
	dc.w	187,34,196,43,1	; Loopstart upp
	dc.w	197,34,206,43,1	; Loopstart ner
	dc.w	187,44,196,53,1	; Looplength upp
	dc.w	197,44,206,53,1	; Looplength ner
	dc.w	64,47,80,54,0	; Mata in aktuell sampling
	dc.w	168,5,184,12,0	; Mata in samplingens volym
	dc.w	152,35,184,42,0	; Mata in loopstarten
	dc.w	152,45,184,52,0	; Mata in loopl„ngden
	dc.w	168,15,184,22,0	; Mata in finetunen
	dc.w	187,24,196,33,1	; ™ka samplingsl„ngden
	dc.w	197,24,206,33,1	; Minska samplingsl„ngden
	dc.w	152,25,184,32,0	; Mata in samplingsl„ngden

inforots:
	dc.l	slutamedinfo	; Exit-rutin
	dc.l	nexthelpscreen	; N„sta hj„lpsk„rm
	dc.l	prevhelpscreen	; F”reg†ende hj„lpsk„rm
	dc.l	sampleplus	; Aktuell sample + 1
	dc.l	sampleminus	; Aktuell sample - 1
	dc.l	addvolym	; Aktuell samplevolym + 1
	dc.l	subvolym	; Aktuell samplevolym - 1
	dc.l	addfinetune	; Aktuell samplefinetune + 1
	dc.l	subfinetune	; Aktuell samplefinetune - 1
	dc.l	addloopstart	; Aktuell loopstart + 1
	dc.l	subloopstart	; Aktuell loopstart - 1
	dc.l	addlooplength	; Aktuell looplength + 1
	dc.l	sublooplength	; Aktuell looplength - 1
	dc.l	matainsample	; Mata in ny aktuell sampling
	dc.l	matainvolym	; Mata in ny samplingsvolym
	dc.l	matainloopstart	; Mata in ny samplingsstart
	dc.l	matainloopl„ngd	; Mata in ny samplingsl„ngd
	dc.l	matainfinetune	; Mata in ny finetune
	dc.l	addsamlength	; ™ka samplingsl„ngden
	dc.l	subsamlength	; Minska samplingsl„ngden
	dc.l	matainsamlength	; Mata in ny samplingsl„ngd

memkoors:		; Minnesval
	dc.w	21-1	; Antal rektanglar - 1 som har motsvarande rutin f”r nertryckning
	dc.w	212,17,315,25,0 ; Exit-knapp
	dc.w	257,25,311,31,0	; S„tt maxminnes†tg†ngen
	dc.w	212,17,315,56,0 ; Exit-knapp
	dc.w	84,46,93,55,1	; Sampleknapp upp
	dc.w	94,46,103,55,1	; Sampleknapp ner
	dc.w	187,4,196,13,1	; Volym upp
	dc.w	197,4,206,13,1	; Volym ner
	dc.w	187,14,196,23,1 ; Finetune upp
	dc.w	197,14,206,23,1 ; Finetune ner
	dc.w	187,34,196,43,1	; Loopstart upp
	dc.w	197,34,206,43,1	; Loopstart ner
	dc.w	187,44,196,53,1	; Looplength upp
	dc.w	197,44,206,53,1	; Looplength ner
	dc.w	64,47,80,54,0	; Mata in aktuell sampling
	dc.w	168,5,184,12,0	; Mata in samplingens volym
	dc.w	152,35,184,42,0	; Mata in loopstarten
	dc.w	152,45,184,52,0	; Mata in loopl„ngden
	dc.w	168,15,184,22,0	; Mata in finetunen
	dc.w	187,24,196,33,1	; ™ka samplingsl„ngden
	dc.w	197,24,206,33,1	; Minska samplingsl„ngden
	dc.w	152,25,184,32,0	; Mata in samplingsl„ngden

memrots:
	dc.l	slutamedmem	; Exit-rutin
	dc.l	s„ttminnes†tg†ng; S„tt minnes†tg†ng
	dc.l	slutamedmem	; Exit-rutin
	dc.l	sampleplus	; Aktuell sample + 1
	dc.l	sampleminus	; Aktuell sample - 1
	dc.l	addvolym	; Aktuell samplevolym + 1
	dc.l	subvolym	; Aktuell samplevolym - 1
	dc.l	addfinetune	; Aktuell samplefinetune + 1
	dc.l	subfinetune	; Aktuell samplefinetune - 1
	dc.l	addloopstart	; Aktuell loopstart + 1
	dc.l	subloopstart	; Aktuell loopstart - 1
	dc.l	addlooplength	; Aktuell looplength + 1
	dc.l	sublooplength	; Aktuell looplength - 1
	dc.l	matainsample	; Mata in ny aktuell sampling
	dc.l	matainvolym	; Mata in ny samplingsvolym
	dc.l	matainloopstart	; Mata in ny samplingsstart
	dc.l	matainloopl„ngd	; Mata in ny samplingsl„ngd
	dc.l	matainfinetune	; Mata in ny finetune
	dc.l	addsamlength	; ™ka samplingsl„ngden
	dc.l	subsamlength	; Minska samplingsl„ngden
	dc.l	matainsamlength	; Mata in ny samplingsl„ngd

makekoors:		; Makemenyns val
	dc.w	25-1	; Antal rektanglar - 1 som har motsvarande rutin f”r nertryckning
	dc.w	286,44,312,54,0 ; Exit-knapp
	dc.w	215,34,240,43,0	; Clipp on/off
	dc.w	295,20,311,26,0	; Sampling
	dc.w	295,35,311,41,0	; Volym
	dc.w	236,44,285,54,0	; Mixa blocket
	dc.w	241,34,250,43,1	; Tone upp
	dc.w	251,34,260,43,1	; Tone ner
	dc.w	84,46,93,55,1	; Sampleknapp upp
	dc.w	94,46,103,55,1	; Sampleknapp ner
	dc.w	187,4,196,13,1	; Volym upp
	dc.w	197,4,206,13,1	; Volym ner
	dc.w	187,14,196,23,1 ; Finetune upp
	dc.w	197,14,206,23,1 ; Finetune ner
	dc.w	187,34,196,43,1	; Loopstart upp
	dc.w	197,34,206,43,1	; Loopstart ner
	dc.w	187,44,196,53,1	; Looplength upp
	dc.w	197,44,206,53,1	; Looplength ner
	dc.w	64,47,80,54,0	; Mata in aktuell sampling
	dc.w	168,5,184,12,0	; Mata in samplingens volym
	dc.w	152,35,184,42,0	; Mata in loopstarten
	dc.w	152,45,184,52,0	; Mata in loopl„ngden
	dc.w	168,15,184,22,0	; Mata in finetunen
	dc.w	187,24,196,33,1	; ™ka samplingsl„ngden
	dc.w	197,24,206,33,1	; Minska samplingsl„ngden
	dc.w	152,25,184,32,0	; Mata in samplingsl„ngden

makerots:
	dc.l	exitmakeasample	; Exit-rutin
	dc.l	setclip		; Clipp on/off
	dc.l	matainmakesample; Vilken sampling make skall anv„nda
	dc.l	matainmakevolume; Vilken volym make skall anv„nda
	dc.l	startmixblock	; Mix block
	dc.l	addfreq		; ™ka tone
	dc.l	subfreq		; Minska tone
	dc.l	sampleplus	; Aktuell sample + 1
	dc.l	sampleminus	; Aktuell sample - 1
	dc.l	addvolym	; Aktuell samplevolym + 1
	dc.l	subvolym	; Aktuell samplevolym - 1
	dc.l	addfinetune	; Aktuell samplefinetune + 1
	dc.l	subfinetune	; Aktuell samplefinetune - 1
	dc.l	addloopstart	; Aktuell loopstart + 1
	dc.l	subloopstart	; Aktuell loopstart - 1
	dc.l	addlooplength	; Aktuell looplength + 1
	dc.l	sublooplength	; Aktuell looplength - 1
	dc.l	matainsample	; Mata in ny aktuell sampling
	dc.l	matainvolym	; Mata in ny samplingsvolym
	dc.l	matainloopstart	; Mata in ny samplingsstart
	dc.l	matainloopl„ngd	; Mata in ny samplingsl„ngd
	dc.l	matainfinetune	; Mata in ny finetune
	dc.l	addsamlength	; ™ka samplingsl„ngden
	dc.l	subsamlength	; Minska samplingsl„ngden
	dc.l	matainsamlength	; Mata in ny samplingsl„ngd

editkoors:		; Editval
	dc.w	23-1	; Antal rektanglar - 1 som har motsvarande rutin f”r nertryckning
	dc.w	295,44,317,55,0	; Exit-knapp
	dc.w	84,46,93,55,1	; Sampleknapp upp
	dc.w	94,46,103,55,1	; Sampleknapp ner
	dc.w	295,21,312,30,0	; Current kanalval
	dc.w	295,30,312,39,0	; All kanalval
	dc.w	260,18,293,27,1	; Insert
	dc.w	260,28,293,37,1	; Delete
	dc.w	226,38,259,47,0	; Clear
	dc.w	192,18,225,27,0	; Begin
	dc.w	192,28,225,37,0	; End
	dc.w	192,38,225,47,0	; Hide
	dc.w	226,18,259,27,0	; Copy
	dc.w	226,28,259,37,0	; Move
	dc.w	226,48,259,57,0	; Spara block
	dc.w	192,48,225,57,0	; Ladda block
	dc.w	260,48,275,57,1	; Frekvens upp
	dc.w	275,48,293,57,1	; Frekvens ner
	dc.w	260,38,293,47,0	; Invertera block
	dc.w	64,47,80,54,0	; Mata in aktuell sampling
	dc.w	168,5,184,12,0	; Mata in samplingens volym
	dc.w	152,35,184,42,0	; Mata in loopstarten
	dc.w	152,45,184,52,0	; Mata in loopl„ngden
	dc.w	168,15,184,22,0	; Mata in finetunen
	dc.w	152,25,184,32,0	; Mata in samplingsl„ngden


editrots:
	dc.l	slutamededit	; Exit-rutin
	dc.l	sampleplus	; Aktuell sample + 1
	dc.l	sampleminus	; Aktuell sample - 1
	dc.l	onlycurrent	; Block skall bara p†verka en kanal
	dc.l	allaktiv	; Block skall p†verka alla kanaler
	dc.l	musinsert	; Insert
	dc.l	musdelete	; Delete
	dc.l	musclear	; Clear
	dc.l	setblockstart	; Begin
	dc.l	setblockend	; End
	dc.l	blockhide	; Hide
	dc.l	muscopy		; Copy
	dc.l	musmove		; Move
	dc.l	sparablock	; Save block
	dc.l	laddablock	; Ladda block
	dc.l	frekvensupp	; Frekvens upp
	dc.l	frekvensner	; Frekvens ner
	dc.l	musinvers	; Invertera block
	dc.l	matainsample	; Mata in ny aktuell sampling
	dc.l	matainvolym	; Mata in ny samplingsvolym
	dc.l	matainloopstart	; Mata in ny samplingsstart
	dc.l	matainloopl„ngd	; Mata in ny samplingsl„ngd
	dc.l	matainfinetune	; Mata in ny finetune
	dc.l	matainsamlength	; Mata in ny samplingsl„ngd


diskkoors:		; Diskval
	dc.w	25-1	; Antal rektanglar - 1 som har motsvarande rutin f”r nertryckning
	dc.w	264,47,315,56,0 ; Exit-knapp
	dc.w	212,28,263,37,0 ; Load sample-knapp
	dc.w	264,18,315,27,0	; Save modul-knapp
	dc.w	212,18,263,27,0	; Load modul-knapp
	dc.w	84,46,93,55,1	; Sampleknapp upp
	dc.w	94,46,103,55,1	; Sampleknapp ner
	dc.w	187,4,196,13,1	; Volym upp
	dc.w	197,4,206,13,1	; Volym ner
	dc.w	187,14,196,23,1 ; Finetune upp
	dc.w	197,14,206,23,1 ; Finetune ner
	dc.w	187,34,196,43,1	; Loopstart upp
	dc.w	197,34,206,43,1	; Loopstart ner
	dc.w	187,44,196,53,1	; Looplength upp
	dc.w	197,44,206,53,1	; Looplength ner
	dc.w	212,47,237,56,0	; Delete a file
	dc.w	264,28,315,37,0	; Save a sample
	dc.w	64,47,80,54,0	; Mata in aktuell sampling
	dc.w	168,5,184,12,0	; Mata in samplingens volym
	dc.w	152,35,184,42,0	; Mata in loopstarten
	dc.w	152,45,184,52,0	; Mata in loopl„ngden
	dc.w	168,15,184,22,0	; Mata in finetunen
	dc.w	187,24,196,33,1	; ™ka samplingsl„ngden
	dc.w	197,24,206,33,1	; Minska samplingsl„ngden
	dc.w	152,25,184,32,0	; Mata in samplingsl„ngden
	dc.w	238,47,263,56,0	; GoTo GEM

diskrots:
	dc.l	slutameddisk	; Exit-rutin
	dc.l	laddaensampling ; Ladda sampling
	dc.l	sparaenmodul	; Spara modul
	dc.l	laddaenmodul	; Ladda modul
	dc.l	sampleplus	; Aktuell sample + 1
	dc.l	sampleminus	; Aktuell sample - 1
	dc.l	addvolym	; Aktuell samplevolym + 1
	dc.l	subvolym	; Aktuell samplevolym - 1
	dc.l	addfinetune	; Aktuell samplefinetune + 1
	dc.l	subfinetune	; Aktuell samplefinetune - 1
	dc.l	addloopstart	; Aktuell loopstart + 1
	dc.l	subloopstart	; Aktuell loopstart - 1
	dc.l	addlooplength	; Aktuell looplength + 1
	dc.l	sublooplength	; Aktuell looplength - 1
	dc.l	deleteafile	; Delete a file
	dc.l	sparaensampling	; Spara sampling
	dc.l	matainsample	; Mata in ny aktuell sampling
	dc.l	matainvolym	; Mata in ny samplingsvolym
	dc.l	matainloopstart	; Mata in ny samplingsstart
	dc.l	matainloopl„ngd	; Mata in ny samplingsl„ngd
	dc.l	matainfinetune	; Mata in ny finetune
	dc.l	addsamlength	; ™ka samplingsl„ngden
	dc.l	subsamlength	; Minska samplingsl„ngden
	dc.l	matainsamlength	; Mata in ny samplingsl„ngd
	dc.l	GoToGEM		; G† till GEM

optionskoors:		; Optionsval
	dc.w	OPTOFF	; Antal rektanglar - 1 som har motsvarande rutin f”r nertryckning
	dc.w	269,47,317,56,0 ; Exit-knapp
	dc.w	249,47,258,56,1 ; ™ka DBRAs
	dc.w	259,47,268,56,1 ; Minska DBRAs
	dc.w	119,27,126,55,2	; BASS
	dc.w	128,27,135,55,2	; Treble
	dc.w	136,27,143,55,2	; Main volume
	dc.w	160,27,167,55,2	; Keyboardrepeat
	dc.w	168,27,175,55,2	; Keyboarddelay
	dc.w	176,27,183,55,2	; Mouse delay
	dc.w	185,38,211,47,0	; TERMODY
	dc.w	280,37,296,43,0	; Mata in nytt antal noppar
	dc.w	212,38,222,47,0	; S„tt max antal patterns
	dc.w	185,28,198,37,0	; ™ppna Colormenyn
	dc.w	231,38,240,47,0	; S„tt tang.rept av/p†
	dc.w	185,18,198,27,0	; Save-options
	dc.w	239,38,248,47,0	; VU-metrar p†/av
	dc.w	223,38,232,47,0	; BPM av/p†
	dc.w	255,38,264,47,0	; Trashupdate
	dc.w	263,28,296,35,0	; Low-Noise

	dc.w	304,20,311,27,0 ; 4 kanaler
	dc.w	304,28,311,35,0 ; 6 kanaler
	dc.w	304,36,311,43,0 ; 8 kanaler
	dc.w	231,20,255,27,0 ; 12.5 kHz
	dc.w	200,20,223,27,0 ; 6.25 kHz
	dc.w	231,28,255,35,0 ; 50 kHz
	dc.w	200,28,223,35,0 ; 25 kHz
	dc.w	144,27,151,55,2	; Left volume
	dc.w	152,27,159,55,2	; Right volume
	dc.w	263,20,296,27,0	; A-Alias
	dc.w	191,47,208,56,0	; Basfrekvens 16 kHz
	dc.w	207,47,224,56,0	; Basfrekvens 20 kHz
	dc.w	223,47,240,56,0	; Basfrekvens 25 kHz
	dc.w	247,38,256,47,0	; S„tter s† att Octan loopar istf duppar


optionsrots:
	dc.l	slutamedoptions ; Exit-rutin
	dc.l	okadbrasar	; ™ka DBRAs-rutin
	dc.l	minskadbrasar	; Minska DBRAs-rutin
	dc.l	setbass		; Rutinen som st„ller in basen
	dc.l	settreble	; Rutinen som st„ller in diskanten
	dc.l	setmainvol	; Rutinen som st„ller in huvudvolymen
	dc.l	setkeyrep	; Rutinen som st„ller in tang.rep.
	dc.l	setkeydel	; Rutinen som st„ller in tang.del.
	dc.l	setmousedel	; Rutinen som st„ller in musrept.
	dc.l	settermody	; Rutinen som ”ppnar Termody-menyn
	dc.l	matainnoppar	; Mata in nytt antal noppar
	dc.l	setnumofpatts	; S„tt antalet patterns
	dc.l	opencolormenu	; ™ppnar colormenyn
	dc.l	setreptonoff	; S„tt tang.rept av/p†
	dc.l	SaveOptions	; Save options
	dc.l	setVUmeteronoff	; VU-metrar av/p†
	dc.l	setBPMonoff	; BPM av/p†
	dc.l	trashupdateonoff; Trashupdate
	dc.l	setlownoise	; Rutinen som pendlar LowNoise

	dc.l	till4kanaler	; Rutinen som st„ller om till 4 kanaler
	dc.l	till6kanaler	; Rutinen som st„ller om till 6 kanaler
	dc.l	till8kanaler	; Rutinen som st„ller om till 8 kanaler
	dc.l	till50 		; Rutinen som st„ller om till 15.5 kHz
	dc.l	till125	 	; Rutinen som st„ller om till 12.5 kHz
	dc.l	till25		; Rutinen som st„ller om till 18.9 kHz
	dc.l	till625		; Rutinen som st„ller om till 25.0 kHz
	dc.l	setleftvol	; Rutinen som st„ller in v„nster volym
	dc.l	setrightvol	; Rutinen som st„ller in h”ger volym
	dc.l	aaliason	; Rutinen som pendlar Aliasen
	dc.l	basspeed16	; S„tter bashastigheten till 16 kHz
	dc.l	basspeed20	; S„tter bashastigheten till 20 kHz
	dc.l	basspeed25	; S„tter bashastigheten till 25 kHz
	dc.l	doloopordupp	; S„tter s† att Octan loopar istf duppar



numpattskoors:
	dc.w	4-1
	dc.w	208,32,216,38,0		; St„ng formen
	dc.w	239,43,248,52,1		; ™ka antalet
	dc.w	249,43,258,52,1		; Minskal antalet
	dc.w	216,44,231,50,0		; Mata in max antalet via tang.

numpattsrots:
	dc.l	exitmaxpatt		; St„ng formen
	dc.l	addmaxpatts		; ™ka antalet max
	dc.l	submaxpatts		; Minska antalet max
	dc.l	matainmaxpatts		; Mata in max antalet via tang.


termodykoors:
	dc.w	13-1
	dc.w	250,41,267,50,0	; Termody Ok
	dc.w	119,17,184,26,0	; Val 1)
	dc.w	119,27,184,34,0	; Val 2)
	dc.w	119,35,184,43,0	; Val 3)
	dc.w	119,44,184,52,0	; Val 4)
	dc.w	209,41,226,50,0	; Ladda in en ump-rutin
	dc.w	227,41,249,50,0	; Rensa aktuell spelare
	dc.w	246,21,255,30,1	; ™ka antalet toner
	dc.w	256,21,265,30,1	; Minska antalet toner
	dc.w	187,21,200,30,0	; Antal patternsmenyn
	dc.w	191,41,208,50,0	; Use
	dc.w	224,23,239,29,0	; Mata in antal toner
	dc.w	201,21,232,30,0	; Visa UCDMinfon


termodyrots:
	dc.l	exittermody	; Ok
	dc.l	termoval1	; Termoval 1
	dc.l	termoval2	; Termoval 2
	dc.l	termoval3	; Termoval 3
	dc.l	termoval4	; Termoval 4
	dc.l	loadatermody	; Ladda in en rutin
	dc.l	releasecurrentplayer	; Sl„pp spelaren
	dc.l	addtones	; Addera antalet toner
	dc.l	subtones	; Subtrahera antalet toner
	dc.l	selectnrofpatts	; V„lj antal patterns som skall visas
	dc.l	usetermody	; Use
	dc.l	mataintoner	; Mata in antal toner
	dc.l	showtermoinfo	; Visar information om UCDMen


selectshowpattkoors:
	dc.w	3-1
	dc.w	192,11,207,20,0	; 17 rader skall visas
	dc.w	192,21,207,30,0	; 7 rader skall visas
	dc.w	192,31,207,40,0	; 1 rad skall visas

selectshowpattrots:
	dc.l	showonly17rows	; 17 rader
	dc.l	showonly7rows	; 7 rader
	dc.l	showonly1rows	; 1 rad

colorkoors:
	dc.w	8-1
	dc.w	227,49,245,59,0	; Ok-knappen
	dc.w	224,20,245,27,0	; F„rg 0
	dc.w	224,27,245,34,0	; F„rg 1
	dc.w	224,34,245,41,0	; F„rg 2
	dc.w	224,41,245,48,0	; F„rg 3
	dc.w	200,27,207,55,2	; Rgb
	dc.w	208,27,215,55,2	; rGb
	dc.w	216,27,223,55,2	; rgB

colorrots:
	dc.l	slutamedcolor	; St„ng colorf”nstret
	dc.l	selectcolor0	; V„lj f„rg 0
	dc.l	selectcolor1	; V„lj f„rg 1
	dc.l	selectcolor2	; V„lj f„rg 2
	dc.l	selectcolor3	; V„lj f„rg 3
	dc.l	colorR		; Rgb
	dc.l	colorG		; rGb
	dc.l	colorB		; rgB





formbak:ds.b	64*32

handle: dc.w	0
filnamn:dc.l	0
lasbuffer:
	dc.l	0
laslangd:
	dc.l	0

tomtminne:
	dc.l	0
removeer:
	 dc.l	0
;pointmouse:
;	dc.l	0
;oldmouse:
;	dc.l	0
linea:	dc.l	0
oldx:	dc.w	0
oldy:	dc.w	0
oldw:	dc.w	0
oldh:	dc.w	0
oldplanes:
	dc.w	0
oldwinbytes:
	dc.w	0
oldstack:
	dc.l	0
keyklick:
	dc.w	0
oldvbls:dc.l	0
oldnumofvbls:
	dc.w	0
oldvbl: dc.l	0
oldhbl: dc.l	0
oldkeyboard:
	dc.l	0
oldc:	dc.l	0
rez:	dc.w	0
falkrez	dc.w	0
InOctaFalkrez	dc.w	0
physbase:
	dc.l	0
logbase:dc.l	0
oldcol: ds.w	16
x:	dc.w	0
y:	dc.w	0
mkey:	dc.w	0
extraxy:dc.l	0

screenpalette:
	dc.w	$0000,$0222,$0444,$0555,$0020,$0020,$0020,$0020
	dc.w	$0030,$0030,$0030,$0030,$0040,$0040,$0040,$0040

texteditpalette:
	dc.w	$0000,$0222,$0444,$0555,$0202,$0202,$0202,$0202
	dc.w	$0303,$0303,$0303,$0303,$0404,$0404,$0404,$0404

stopcolor:
	dc.w	$020,$020,$020,$020,$030,$030,$030,$030,$040,$040,$040,$040
editcolor:
	dc.w	$02,$02,$02,$02,$03,$03,$03,$03,$04,$04,$04,$04
patterncolor:
	dc.w	$022,$022,$022,$022,$033,$033,$033,$033,$044,$044,$044,$044
playcolor:
	dc.w	$220,$220,$220,$220,$330,$330,$330,$330,$440,$440,$440,$440
errorcolor:
	dc.w	$200,$200,$200,$200,$300,$300,$300,$300,$400,$400,$400,$400

musform:dc.w	$FFFF,$0000,$0000,$0000,$8002,$7FFC,$0000,$0000
	dc.w	$BFF4,$7FF8,$0000,$0000,$BFE8,$7FF0,$0000,$0000
	dc.w	$BFD0,$7FE0,$0000,$0000,$BFE8,$7FF0,$0000,$0000
	dc.w	$BFF4,$7FF8,$0000,$0000,$BFFA,$7FFC,$0000,$0000
	dc.w	$BFFD,$7FFE,$0000,$0000,$BFFA,$7FFC,$0000,$0000
	dc.w	$B7F4,$7FF8,$0000,$0000,$ABE8,$77F0,$0000,$0000
	dc.w	$95D0,$63E0,$0000,$0000,$A2A0,$41C0,$0000,$0000
	dc.w	$C140,$0080,$0000,$0000,$8080,$0000,$0000,$0000
	ds.b	128*15



;maskrotering:			; Anv„nds som mask f”r v„nster word vid blittern
;	dc.w	%1111111111111111
;	dc.w	%0111111111111111
;	dc.w	%0011111111111111
;	dc.w	%0001111111111111
;	dc.w	%0000111111111111
;	dc.w	%0000011111111111
;	dc.w	%0000001111111111
;	dc.w	%0000000111111111
;	dc.w	%0000000011111111
;	dc.w	%0000000001111111
;	dc.w	%0000000000111111
;	dc.w	%0000000000011111
;	dc.w	%0000000000001111
;	dc.w	%0000000000000111
;	dc.w	%0000000000000011
;	dc.w	%0000000000000001
;
;	dc.w	%0000000000000000
;	dc.w	%0000000000000000
;	dc.w	%0000000000000000
;	dc.w	%0000000000000000
;	dc.w	%0000000000000000
;	dc.w	%0000000000000000
;	dc.w	%0000000000000000
;	dc.w	%0000000000000000
;	dc.w	%0000000000000000
;	dc.w	%0000000000000000
;	dc.w	%0000000000000000
;	dc.w	%0000000000000000
;	dc.w	%0000000000000000
;	dc.w	%0000000000000000
;	dc.w	%0000000000000000
;	dc.w	%0000000000000000


taltabell:
	dc.l	numberfont,numberfont+12,numberfont+24,numberfont+36
	dc.l	numberfont+48,numberfont+60,numberfont+72,numberfont+84
	dc.l	numberfont+96,numberfont+108,numberfont+120,numberfont+132
	dc.l	numberfont+144,numberfont+156,numberfont+168,numberfont+180

numberfont:
	dc.b	$0000,$C3,$0000,$91	; 0
	dc.b	$0000,$89,$0000,$99
	dc.b	$0000,$C3,$0000,$FF

	dc.b	$0000,$E7,$0000,$C7	; 1
	dc.b	$0000,$E7,$0000,$E7
	dc.b	$0000,$81,$0000,$FF

	dc.b	$0000,$C3,$0000,$B9	; 2
	dc.b	$0000,$F3,$0000,$E7
	dc.b	$0000,$81,$0000,$FF

	dc.b	$0000,$81,$0000,$E7	; 3
	dc.b	$0000,$F3,$0000,$B9
	dc.b	$0000,$C3,$0000,$FF

	dc.b	$0000,$F3,$0000,$C3	; 4
	dc.b	$0000,$93,$0000,$81
	dc.b	$0000,$F3,$0000,$FF

	dc.b	$0000,$81,$0000,$9F	; 5
	dc.b	$0000,$81,$0000,$F9
	dc.b	$0000,$83,$0000,$FF

	dc.b	$0000,$C3,$0000,$9F	; 6
	dc.b	$0000,$83,$0000,$99
	dc.b	$0000,$C3,$0000,$FF

	dc.b	$0000,$81,$0000,$F3	; 7
	dc.b	$0000,$E7,$0000,$CF
	dc.b	$0000,$CF,$0000,$FF

	dc.b	$0000,$C3,$0000,$99	; 8
	dc.b	$0000,$C3,$0000,$99
	dc.b	$0000,$C3,$0000,$FF

	dc.b	$0000,$C3,$0000,$99	; 9
	dc.b	$0000,$C1,$0000,$F9
	dc.b	$0000,$C7,$0000,$FF

	dc.b	$0000,$C3,$0000,$99	; A
	dc.b	$0000,$81,$0000,$99
	dc.b	$0000,$99,$0000,$FF

	dc.b	$0000,$83,$0000,$99	; B
	dc.b	$0000,$83,$0000,$99
	dc.b	$0000,$83,$0000,$FF

	dc.b	$0000,$C3,$0000,$9F	; C
	dc.b	$0000,$9F,$0000,$9F
	dc.b	$0000,$C1,$0000,$FF

	dc.b	$0000,$83,$0000,$99	; D
	dc.b	$0000,$99,$0000,$99
	dc.b	$0000,$87,$0000,$FF

	dc.b	$0000,$81,$0000,$9F	; E
	dc.b	$0000,$83,$0000,$9F
	dc.b	$0000,$81,$0000,$FF

	dc.b	$0000,$81,$0000,$9F	; F
	dc.b	$0000,$83,$0000,$9F
	dc.b	$0000,$9F,$0000,$FF

	even



numberfont2:
	dc.b	$C3,$91 ; 0
	dc.b	$89,$99
	dc.b	$C3,$FF

	dc.b	$E7,$C7 ; 1
	dc.b	$E7,$E7
	dc.b	$81,$FF

	dc.b	$C3,$B9 ; 2
	dc.b	$F3,$E7
	dc.b	$81,$FF

	dc.b	$81,$E7 ; 3
	dc.b	$F3,$B9
	dc.b	$C3,$FF

	dc.b	$F3,$C3 ; 4
	dc.b	$93,$81
	dc.b	$F3,$FF

	dc.b	$81,$9F ; 5
	dc.b	$81,$F9
	dc.b	$83,$FF

	dc.b	$C3,$9F ; 6
	dc.b	$83,$99
	dc.b	$C3,$FF

	dc.b	$81,$F3 ; 7
	dc.b	$E7,$CF
	dc.b	$CF,$FF

	dc.b	$C3,$99 ; 8
	dc.b	$C3,$99
	dc.b	$C3,$FF

	dc.b	$C3,$99 ; 9
	dc.b	$C1,$F9
	dc.b	$C7,$FF

	dc.b	$C3,$99 ; A
	dc.b	$81,$99
	dc.b	$99,$FF

	dc.b	$83,$99 ; B
	dc.b	$83,$99
	dc.b	$83,$FF

	dc.b	$C3,$9F ; C
	dc.b	$9F,$9F
	dc.b	$C1,$FF

	dc.b	$83,$99 ; D
	dc.b	$99,$99
	dc.b	$87,$FF

	dc.b	$81,$9F ; E
	dc.b	$83,$9F
	dc.b	$81,$FF

	dc.b	$81,$9F ; F
	dc.b	$83,$9F
	dc.b	$9F,$FF

empty:	dc.b	0,0,0,0,0,0

	even

ascii:	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,42,43,44,45,46,47,55,49,50,54,53,57,60,56,48
	dc.l	1,2,3,4,5,6,7,8,9,10,58,59,62,51,63,52
	dc.l	65,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25
	dc.l	26,27,28,29,30,31,32,33,34,35,36,68,67,69,64,61
	dc.l	70,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25
	dc.l	26,27,28,29,30,31,32,33,34,35,36,72,66,73,71,0
	dc.l	0,40,41,0,38,0,37,0,0,0,0,0,0,0,38,37
	dc.l	41,0,0,0,39,0,0,0,0,39,40,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

ultradummy:
	dc.l	0
musicwait:
	dc.w	0
hoppa”veradderingendenh„rg†ngen:
	dc.w	0
speed:	DC.W	$06	; Fart
counter:DC.W	$00	; R„knare f”r farten
songpos:DC.B	$00	; Vart i songen
break:	dc.b	0	; Dax att byta pattern?
pattpos:DC.W	$00	; Vart i patternet

whichpatt:
	dc.w	$00	; Patternt vi spelar p†
whichsample:
	dc.w	$01	; Vilken sampling „r den aktuella

;=========================== H„r „r songen (offset +950 bytes i modulen) ==


songlength:
	dc.b	$01	; Length
songrestart:
	dc.b	$00	; Vart skall vi †terstart songen?
song:	ds.b	128
songend:dc.b	'CD8 '	; 4 kanaler = M.K.   Om st”rre CDn d„r n „r antalet kanaler

songname:
	dc.b	'                   ',0

	even

mt_FunkTable:
	dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

sin:
	dc.b   0, 24, 49, 74, 97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120, 97, 74, 49, 24

	even

periods:DC.W $0358,$0328,$02FA,$02D0,$02A6,$0280,$025C,$023A,$021A,$01FC,$01E0
	DC.W $01C5,$01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$FE
	DC.W $F0,$E2,$D6,$CA,$BE,$B4,$AA,$A0,$97,$8F,$87
	DC.W $7F,$78,$71,$00,$00

dmacon: DC.W $00	; Vilka kanaler har anslagits? Uppdatera skapa-variabler isf
samplestarts:	; Pekare till samplingar
	dc.l	dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy
	dc.l	dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy
	dc.l	dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy
	dc.l	dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy

datastarts:		; Pekare till vart samplingarna gamla samplingsdata finns
	ds.l	32
	ds.l	32


voice1:	dc.l	0	; +0	Longwordet i songen
	dc.l	0	; +4	Pekare till samplingens b”rjan
	dc.w	0	; +8	L„ngden p† samplingen i bytes
	dc.l	0	; +10	Pekare till samplings b”rjan ?????????
	dc.w	0	; +14	Loopl„ngden p† samplingen
	dc.w	0	; +16	AmigaFrekvensen
	dc.w	0	; +18	Finetune samt Volym
	dc.w	$01	; +20	Till f”r DMACTRL
	dc.w	0	; +22	+22 Styr myport +23 = sista byten i slidekommandot
	dc.w	0	; +24	Frekvensen i myport?
	dc.w	0	; +26	Vibratofrekvensen
	dc.l	0	; +28	om 0 ingen loop alls
	dc.l	0	; +32	Samplel„ngden i longword
	dc.b	0	; +36	n_tremolocmd
	dc.b	0	; +37	n_tremolopos
	dc.b	0	; +38	n_wavecontrol
	dc.b	0	; +39	n_glissfunk
	dc.b	0	; +40	n_funkoffset
	dc.b	0	; +41	- unused -
	dc.w	0	; +42	- unused -
	dc.l	$FFFFFF	; +44	n_wavestart
	dc.l	0	; +48	SampleOffset
voice2	DS.W 10
	DC.W $02
	DS.W 3
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$FFFFFF
	dc.l	0
voice3	DS.W 10
	DC.W $04
	DS.W 3
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$FFFFFF
	dc.l	0
voice4	DS.W 10
	DC.W $08
	DS.W 3
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$FFFFFF
	dc.l	0
voice5	DS.W 10
	DC.W $10
	DS.W 3
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$FFFFFF
	dc.l	0
voice6	DS.W 10
	DC.W $20
	DS.W 3
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$FFFFFF
	dc.l	0
voice7	DS.W 10
	DC.W $40
	DS.W 3
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$FFFFFF
	dc.l	0
voice8	DS.W 10
	DC.W $80
	DS.W 3
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$FFFFFF
	dc.l	0

wiz1lc: DC.L sample		; Inneh†ller data om hur sampling skall skrivas till buffern
wiz1len:DC.L 0			; L„ngd
wiz1rpt:DC.L 0			; Repetition
wiz1pos:DC.L 0			; Vart ligger i dma-buffern
wiz1frc:DC.W 0			; Vilken frekvens spelar vi p†?

wiz2lc: DC.L sample
wiz2len:DC.L 0
wiz2rpt:DC.L 0
wiz2pos:DC.L 0
wiz2frc:DC.W 0

wiz3lc: DC.L sample
wiz3len:DC.L 0
wiz3rpt:DC.L 0
wiz3pos:DC.L 0
wiz3frc:DC.W 0

wiz4lc: DC.L sample
wiz4len:DC.L 0
wiz4rpt:DC.L 0
wiz4pos:DC.L 0
wiz4frc:DC.W 0

wiz5lc: DC.L sample
wiz5len:DC.L 0
wiz5rpt:DC.L 0
wiz5pos:DC.L 0
wiz5frc:DC.W 0

wiz6lc: DC.L sample
wiz6len:DC.L 0
wiz6rpt:DC.L 0
wiz6pos:DC.L 0
wiz6frc:DC.W 0

wiz7lc: DC.L sample
wiz7len:DC.L 0
wiz7rpt:DC.L 0
wiz7pos:DC.L 0
wiz7frc:DC.W 0

wiz8lc: DC.L sample
wiz8len:DC.L 0
wiz8rpt:DC.L 0
wiz8pos:DC.L 0
wiz8frc:DC.W 0

aud1lc: DC.L dummy		; Vart skall vi h„mta samplingen n†gonstans?
aud1len:DC.W 0			; L„ngd p† den
aud1per:DC.W 0			; Frekvens
aud1vol:DC.W 0			; Volym p† samplingen
aud1off:DC.W 0			; Sampleoffsetten
aud1lop:DC.W 0			; Om 0 skall normalvolym anv„ndas, annars
	DS.W 2			; skall volymen tvingas ner till 0 pga
				; att ljudet loopar
aud2lc: DC.L dummy
aud2len:DC.W 0
aud2per:DC.W 0
aud2vol:DC.W 0
aud2off:DC.W 0
aud2lop:DC.W 0
	DS.W 2

aud3lc: DC.L dummy
aud3len:DC.W 0
aud3per:DC.W 0
aud3vol:DC.W 0
aud3off:DC.W 0
aud3lop:DC.W 0
	DS.W 2

aud4lc: DC.L dummy
aud4len:DC.W 0
aud4per:DC.W 0
aud4vol:DC.W 0
aud4off:DC.W 0
aud4lop:DC.W 0
	DS.W 2

aud5lc: DC.L dummy
aud5len:DC.W 0
aud5per:DC.W 0
aud5vol:DC.W 0
aud5off:DC.W 0
aud5lop:DC.W 0
	DS.W 2

aud6lc: DC.L dummy
aud6len:DC.W 0
aud6per:DC.W 0
aud6vol:DC.W 0
aud6off:DC.W 0
aud6lop:DC.W 0
	DS.W 2

aud7lc: DC.L dummy
aud7len:DC.W 0
aud7per:DC.W 0
aud7vol:DC.W 0
aud7off:DC.W 0
aud7lop:DC.W 0
	DS.W 2

aud8lc: DC.L dummy
aud8len:DC.W 0
aud8per:DC.W 0
aud8vol:DC.W 0
aud8off:DC.W 0
aud8lop:DC.W 0
	DS.W 2

dmactrl:DC.W 0		; Har n†got med perioden att g”ra

	dc.b	0,0
dummy:	ds.b	4000	; Tom buffer att spela upp om samplingen inte finns

samplepek:
	DC.L	sample	; Vart ligger vi i dmabuffern?

sample: DS.W	2000*3*2 ; dma-buffern
dummymusic:
	ds.w	260*2
samdummy:
	dc.l	0	; Pekar ut var i buffern som vi skall skriva
vantapasam:
	dc.w	1	; Dax att v„nta in dmat?
buffrar:ds.l	4	; Tabell ”ver pekare till dmabuffern

itab0:	DS.L	$30	; Tabell ”ver adderingskoefficienter till dmabuffern
stab0:	DS.L	$03A0-$30
superfastfinetune:
	ds.b	1024

modsam:
	rept	32				; 30 bytes
	dc.b	'                     ',0	; Samplenamn
	dc.w	0				; Samplelength i words
	dc.b	$0,$40				; Finetune + volym
	dc.w	0,0				; Loop start, length
	endr

modsamsave:
	rept	32				; 30 bytes
	dc.b	'                     ',0	; Samplenamn
	dc.w	0				; Samplelength i words
	dc.b	$0,$40				; Finetune + volym
	dc.w	0,1				; Loop start, length
	endr

;============================================ Slut p† playrutinens data ==


diskerror1:
	dc.b	' ERROR ON DISK',0
	dc.b	'DISK NOT READY',0
	dc.b	'UNKNOWNCOMMAND',0
	dc.b	'   CRC ERROR  ',0
	dc.b	'  BAD REQUEST ',0
	dc.b	'  SEEK ERROR  ',0
	dc.b	' UNKOWN MEDIA ',0
	dc.b	'SECT NOT FOUND',0
	dc.b	' OUT OF PAPER ',0
	dc.b	'  WRITE FAULT ',0
	dc.b	'  READ FAULT  ',0
	dc.b	' UNUSED ERROR ',0
	dc.b	'WRITEPROTECTED',0
	dc.b	' MEDIA CHANGED',0
	dc.b	'UNKNOWN DEVICE',0
	dc.b	'  BAD SECTORS ',0
warning:dc.b	'    WARNING!  ',0
stsam:	dc.b	'STEREO-SAMPLE!',0
bit16sam:dc.b	'16-BIT SAMPLE!',0
excep1:	dc.b	'!OCTA FAILURE!',0
excep2:	dc.b	' TO DESKTOP.. ',0
sparaopt1:
	dc.b	' SAVE OPTIONS ',0
sparaopt2:
	dc.b	'      !!      ',0
foundstring:
	dc.b	'    FOUND:    ',0
Amiga:	dc.b	' 4 CH, 31 SAM ',0
Octalyser:
	dc.b	' 8 CH, 31 SAM ',0
enstyckesexa:
	dc.b	' 6 CH, 31 SAM ',0
AmiOctalyser:
	dc.b	'AMIGAOCTALYSER',0
OldAmiga:
	dc.b	' 4 CH, 15 SAM ',0
changemax1:
	dc.b	' CLEAR WHOLE  ',0
changemax2:
	dc.b	'   MODULE!    ',0
term1:
	dc.b	'NO MEMORY LEFT',0
term2:
	dc.b	'  FOR UCDM!! ',0
delete:
	dc.b	'DELETE A FILE!',0
deleteerror1:
	dc.b	' ERROR DURING ',0
deleteerror2:
	dc.b	'    DELETE    ',0
overwrite1:
	dc.b	'OVERWRITE THIS',0
overwrite2:
	dc.b	'     FILE!    ',0
save4anyway1:
	dc.b	' SOME CHANNELS',0
save4anyway2:
	dc.b	'WONT BE SAVED!',0
killthissong1:
	dc.b	'KILL THIS SONG',0
killthissong2:
	dc.b	'       !      ',0
killalloneor1:
	dc.b	'   KILL ALL   ',0
killalloneor2:
	dc.b	'   SAMPLES!   ',0
killthisoneor1:
	dc.b	'   KILL THIS  ',0
killthisoneor2:
	dc.b	'    SAMPLE!   ',0
noclose1:
	dc.b	'  CLOSE ERROR ',0
noread1:dc.b	'  READ ERROR  ',0
noopen1:dc.b	'  OPEN ERROR  ',0
nocreate1:
	dc.b	' CREATE ERROR ',0
nowrite1:
	dc.b	'  WRITE ERROR ',0
nowrite2:
	dc.b	'   DISK FULL? ',0
outofmemoryerror1:
	dc.b	' OUT OF MEMORY',0
filenotfounderror1:
	dc.b	'FILE NOT FOUND',0
overload1:
	dc.b	' OVERLOAD THIS',0
overload2:
	dc.b	'    SAMPLE!   ',0
diskaberror1:
	dc.b	' PLEASE INSERT',0
diskaberror2:
	dc.b	'     DISK '
diskbokstav:
	dc.b	'A:  ',0
diskerror2:
	dc.b	'    RETRY!!   ',0
gemerror1:
	dc.b	'  GEM ERROR!! ',0
gemerror2:
	dc.b	' NO SYSTEMMEM ',0
quitstrang:
	dc.b	'     QUIT     ',0
intefardigstrang1:
	dc.b	'     NOT      ',0
intefardigstrang2:
	dc.b	' IMPLEMENTED  ',0
full1:
	dc.b	'NO MEMORY LEFT',0
full2:
	dc.b	'FOR FULLEDITOR',0
full3:	dc.b	'  FOR MIXING  ',0
notempo1:
	dc.b	'THIS UMP CAN''T',0
notempo2:
	dc.b	'HANDLE TEMPO..',0
notforFalc1:
	dc.b	'THIS UMP WON''T',0
notforFalc2:
	dc.b	'RUN ON FALCON!',0
notforSTE1:
	dc.b	'THIS UMP WON''T',0
notforSTE2:
	dc.b	' RUN ON A STE!',0
changemem1:
	dc.b	' ALL DATA WILL',0
changemem2:
	dc.b	'   BE LOST!!  ',0
signerad1:
	dc.b	'IT''S  A SIGNED',0
signerad2:
	dc.b	'   SAMPLE ... ',0
pleasesetblock1:
	dc.b	'BLOCK  MUST BE',0
pleasesetblock2:
	dc.b	'SET BEFORE MIX',0
saveRAW1:
	dc.b	'SAVE SAMPLE AS',0
saveRAW2:
	dc.b	' RAW (SIGNED) ',0
reformaterr1:
	dc.b	'PLEASE DISABLE',0
reformaterr2:
	dc.b	'8CHANNELEDITOR',0
dummystrang:
	dc.b	0
MiNTmenutext:
	dc.b	'  Octalyser 0.96 ',0
	even

helptable:
	dc.l	helpscreen1
	dc.l	helpscreen2
	dc.l	helpscreen3
	dc.l	helpscreen4
	dc.l	helpscreen5
	dc.l	helpscreen6
	dc.l	helpscreen7
	dc.l	helpscreen8
	dc.l	helpscreen9
	dc.l	0

helpscreen1:		; Uppl”sning: 38 x 19
	dc.b	'  OCTALYSER STE IS PROBABLY THE BEST  ',0
	dc.b    '  8-BIT TRACKER PRESENTLY AVAILABLE!  ',0
	dc.b    ' ONE OF ITS STRONGEST FEATURES IS THE ',0
	dc.b    'ABILITY TO LOAD EXTERNAL REPLAY-ROUTS!',0
	dc.b	'                                      ',0
	dc.b    'AUTHORS: CHRISTIAN DAHL (CODE/TBL)    ',0
	dc.b	'         DAVOR SLUTEJ (ALAN F/REWARD) ',0
	dc.b    '         TORD JANSSON (BLADE/NEW CORE)',0
	dc.b    'GFX:     DAN ANDERSSON (CHAOS/REWARD) ',0
	dc.b	'                                      ',0
	dc.b	'THANX 2 OUR BETATESTERS:   HKAN BRATT',0
	dc.b	'ANDERS ERIKSSON,     ANDERS PETTERSSON',0
	dc.b	'UNIT 17, DANIEL BLOMQUIST.            ',0
	dc.b	'                                      ',0
	dc.b	'  SPECIAL GREETINGS TO OUR REGISTRED  ',0
	dc.b	'USERS.  IT WAS  REAL  NICE OF  YOU TO ',0
	dc.b	'         SUPPORT THE OCTALYSER!       ',0
	dc.b	'--------------------------------------',0
	dc.b	' PAGE 1 - THE INTRODUCTION            ',0

helpscreen2:		; Uppl”sning: 38 x 19
	dc.b	'0XY: NORMAL PLAY OR ARPEGGIO, X-FIRST ',0
	dc.b	'     HALFNOTE ADD, Y-SECONDS          ',0
	dc.b	'1XX: SLIDE UP, XX-SPEED               ',0
	dc.b	'2XX: SLIDE DOWN, XX-SPEED             ',0
	dc.b	'3XX: TONE PORTAMENTO, XX UP/DOWN SPEED',0
	dc.b	'4XY: VIBRATO, X-SPEED Y-DEPTH         ',0
	dc.b	'5XY: TONE PORTAMENTO + VOLUMESLIDE,   ',0
	dc.b	'     X-UPVOLUMESPEED,Y-DOWNVOLUMESPEED',0
	dc.b	'6XY: VIBRATO + VOLUMESLIDE,           ',0
	dc.b	'     X-UPVOLUMESPEED,Y-DOWNVOLUMESPEED',0
	dc.b	'7XY: TREMOLO, X-SPEED Y-DEPTH         ',0
	dc.b	'8XX: NOT USED (YET)                   ',0
	dc.b	'9XX: SET SAMPLE OFFSET, XX NEW OFFSET ',0
	dc.b	'     $26 -> $2600                     ',0
	dc.b	'AXY: VOLUMESLIDE,  X-UPSPEED          ',0
	dc.b	'     Y-DOWNSPEED                      ',0
	dc.b	'BXX: POSITION JUMP, XX SONGPOSITION   ',0
	dc.b	'--------------------------------------',0
	dc.b	' PAGE 2 - THE EFFECT-COMMAND LIST 1/3 ',0 

helpscreen3:		; Uppl”sning: 38 x 19
	dc.b	'CXX: SET VOLUME, XX VOLUME ($00->$40) ',0
	dc.b	'DXX: BREAK, JUMP TO NEXT POSITION     ',0
	dc.b	'EXX: E-COMMANDS                       ',0
	dc.b	'FXX: SET SPEED, $00-$1F SPEED         ',0
	dc.b	'     $20-$FF TEMPO (REQUIRES THE      ',0
	dc.b	'     B-FLAG SET IN THE OPTIONSMENU)   ',0
	dc.b	'--------------------------------------',0
	dc.b	'  E-COMMANDS:                         ',0
	dc.b	'E0X: SET FILTER ON/OFF, NOT USED ON   ',0
	dc.b	'     THE STE                          ',0
	dc.b	'E1X: FINESLIDE UP, X-STEP             ',0
	dc.b	'E2X: FINESLIDE DOWN, X-STEP           ',0
	dc.b	'E3X: GLISSANDO CONTROL, 0-OFF 1-ON    ',0
	dc.b	'E4X: SET VIBRATO WAVEFORM, 0-SINE     ',0
	dc.b	'     1-RAMP DOWN  2-SQUARE            ',0
	dc.b	'E5X: SET FINETUNE, X-FINETUNE         ',0
	dc.b	'                                      ',0
	dc.b	'--------------------------------------',0
	dc.b	' PAGE 3 - THE EFFECT-COMMAND LIST 2/3 ',0

helpscreen4:		; Uppl”sning: 38 x 19
	dc.b	'E6X: LOOP, 0-SET LOOP POSITION        ',0
	dc.b	'     $1-$F LOOP X TIMES               ',0
	dc.b	'E7X: SET TREMOLO WAVEFORM, 0-SINE     ',0
	dc.b	'     1-RAMP DOWN  2-SQUARE            ',0
	dc.b	'E8X: NOT USED                         ',0
	dc.b	'E9X: RETRIG NOTE, PLAY NOTE X TIMES   ',0
	dc.b	'EAX: FINE VOLUMESLIDE UP, ADD X       ',0
	dc.b	'EBX: FINE VOLUMESLIDE DOWN, SUB X     ',0
	dc.b	'ECX: NOTECUT, CUT NOTE AT X VBLANKS   ',0
	dc.b	'EDX: NOTE DELAY, DELAY NOTE X VBLANKS ',0
	dc.b	'EEX: PATTERNDELAY, DELAY PATTERN X    ',0
	dc.b	'     SPEED                            ',0
	dc.b	'EFX: INVERT LOOP, X-SPEED             ',0
	dc.b	'--------------------------------------',0
	dc.b	'ALL  COMMANDS  ARE   COMPATIBLE   WITH',0
	dc.b	'    NOISE/PROTRACKER ON THE AMIGA!    ',0
	dc.b	'                                  CODE',0
	dc.b	'--------------------------------------',0
	dc.b	' PAGE 4 - THE EFFECT-COMMAND LIST 3/3 ',0

helpscreen5:		; Uppl”sning: 38 x 19
	dc.b	'ESC       = QUIT MENU/OCTALYSER       ',0
	dc.b	'CURSOR UP = UP 1 STEP                 ',0
	dc.b	'CURSOR DN = DOWN 1 STEP               ',0
	dc.b	'SH CUR UP = UP STEP STEPS             ',0
	dc.b	'SH CUR DN = DOWN STEP STEPS           ',0
	dc.b	'CUR LEFT  = GO LEFT                   ',0
	dc.b	'CUR RIGHT = GO RIGHT                  ',0
	dc.b	'SH CUR LE = LEFTMOST CHANNEL  (1)     ',0
	dc.b	'SH CUR RI = RIGHTMOST CHANNEL (4/6/8) ',0
	dc.b	'AL CUR LE = PREVIOUS TRACK/PATTERN    ',0
	dc.b	'AL CUR RI = NEXT TRACK/PATTERN        ',0
	dc.b	'CLR HOME  = HOME                      ',0
	dc.b	'RETURN    = PLAY                      ',0
	dc.b	'SH RETURN = PATTERNPLAY               ',0
	dc.b	'SPACE     = STOP/TOGGLE EDIT          ',0
	dc.b	'SH SPACE  = STOP/TOGGLE MONITOR       ',0
	dc.b	'TAB       = NEXT CHANNEL              ',0
	dc.b	'--------------------------------------',0
	dc.b	' PAGE 5 - KEY COMMANDS            1/4 ',0

helpscreen6:		; Uppl”sning: 38 x 19
	dc.b	'SH TAB    = PREVIOUS CHANNEL          ',0
	dc.b	'F1        = TOGGLE OCTAVES (UP/LOW)   ',0
	dc.b	'F2        = TOGGLE WRITINGMODE        ',0
	dc.b	'            (REPLACE/OVERLAY/UNDERLAY)',0
	dc.b	'F3        = CLEAR CHANNEL(S)          ',0
	dc.b	'F4        = MARK WHOLE CURRENT CHANNEL',0
	dc.b	'            AS A BLOCK                ',0
	dc.b	'F7        = GOTO 00                   ',0
	dc.b	'F8        = GOTO 10                   ',0
	dc.b	'F9        = GOTO 20                   ',0
	dc.b	'F10       = GOTO 30                   ',0
	dc.b	'SH F1     = TOGGLE EDITMODE          (',0
	dc.b	'            FREQUENCE/TONE/ALL/VOLUME)',0
	dc.b	'SH F2     = TOGGLE BLOCKMODE          ',0
	dc.b	'            (FREQUENCE/TONE/SAMPLE/   ',0
	dc.b	'            COMMAND/DATA/EFFEKT/ALL)  ',0
	dc.b	'SH F3     = CLEAR (PATTERN/BLOCK)     ',0
	dc.b	'--------------------------------------',0
	dc.b	' PAGE 6 - KEY COMMANDS            2/4 ',0

helpscreen7:		; Uppl”sning: 38 x 19
	dc.b	'CO B      = BLOCK START               ',0
	dc.b	'CO K      = BLOCK END                 ',0
	dc.b	'CO C      = COPY BLOCK (IF SHIFT, ALL)',0
	dc.b	'CO V      = MOVE BLOCK  ---- " " ---- ',0
	dc.b	'CO Z      = CLEAR BLOCK ---- " " ---- ',0
	dc.b	'CO X      = INVERS BLOCK --- " " ---- ',0
	dc.b	'CO I/INS  = INSERT ROW  ---- " " ---- ',0
	dc.b	'CO Y/DEL  = DELETE ROW  ---- " " ---- ',0
	dc.b	'UNDO      = UNDO PREVIOUS COMMAND     ',0
	dc.b	'CO E      = TOGGLE FULLSCREEN EDITOR  ',0
	dc.b	'            ON/OFF (EXIT WITH CO E    ',0
	dc.b	'            OR ESC)                   ',0
	dc.b	'AL 1-8    = TOGGLE CHANNEL ON/OFF     ',0
	dc.b	'CO 1-8    = SET STEP ACCORDINGLY      ',0
	dc.b	'CAPS LOCK = STOP ALL SOUND            ',0
	dc.b	'CO UP/DWN = $10 STEPS UP/DOWN         ',0
	dc.b	'CO LE/RIG = CHANGE CHANNEL            ',0
	dc.b	'--------------------------------------',0
	dc.b	' PAGE 7 - KEY COMMANDS            3/4 ',0

helpscreen8:		; Uppl”sning: 38 x 19
	dc.b	'   ON KEYPAD:                         ',0
	dc.b	'--------------------------------------',0
	dc.b	'0         = STOP                      ',0
	dc.b	'*         = PATTERNPLAY/TOGGLE EDIT   ',0
	dc.b	'+         = NEXT SAMPLE               ',0
	dc.b	'-         = PREVIOUS SAMPLE           ',0
	dc.b	'SH +      = NEXT POSITION IN SONG     ',0
	dc.b	'SH -      = PREVIOUS POSITION IN SONG ',0
	dc.b	'ENTER     = PLAY                      ',0
	dc.b	'SH OTHER  = CHOOSE SAMPLE (=0  ENT=0F ',0
	dc.b	'CO OTHER  = CHOOSE SAMPLE (=10 ENT=1F ',0
	dc.b	'                                      ',0
	dc.b	'                                      ',0
	dc.b	'NOTE:  CO = CONTROL                   ',0
	dc.b	'       SH = SHIFT                     ',0
	dc.b	'       AL = ALTERNATE                 ',0
	dc.b	'                                      ',0
	dc.b	'--------------------------------------',0
	dc.b	' PAGE 8 - KEY COMMANDS            4/4 ',0

helpscreen9:		; Uppl”sning: 38 x 19
			; Denna laddas in fr†n Octalysern.
			; Patchas dit av REGISTER.TOS
	dc.b	'OCTALYSER STE IS A PRODUCT OF PAIN AND',0
	dc.b	'  SWEAT PLUS SOME  ASSEMBLER CODING.  ',0
	dc.b	'                                      ',0
	dc.b    '    THIS PROGRAM IS REGISTERED TO:    ',0
	dc.b	'                                      ',0
regname:dc.b 	'    Christian Dahl                   ',0 ; Max 30 i regnamn (ESC avslutar)
	dc.b	'    Fr”dingh”jd 21                   ',0 ; Max 30 i regadress (ESC avslutar)
	dc.b	'    654 73  Karlstad                 ',0 ; Max 30 i regstad (ESC avslutar)
	dc.b	'                                      ',0
	dc.b	'                                      ',0
	dc.b	' PLEASE READ THE MANUAL TO BE ABLE TO ',0
	dc.b	'UNDERSTAND AND USE ALL OF THE MEGATONS',0
	dc.b    'OF FUNCTIONS  THAT CAN BE FOUND IN THE',0
	dc.b	'            OCTALYSER STE!            ',0
	dc.b	'                                      ',0
	dc.b	'(C)1992, 1993, 1994 THE OCTALYSER-TEAM',0
	dc.b    '                                      ',0
	dc.b	'--------------------------------------',0
	dc.b	' PAGE 9 - PAIN AND SWEAT IS ALL U EARN',0
mm:	dc.b	0,0,0,0

	even

messagepointer:
	dc.l	goodbyestring

goodbyestring:
	dc.b	'GoodBye!',0
loadasamplestring:
	dc.b	'Load a sample',0
	even
finetune:
	dc.b	'+0',0,0
	dc.b	'+1',0,0
	dc.b	'+2',0,0
	dc.b	'+3',0,0
	dc.b	'+4',0,0
	dc.b	'+5',0,0
	dc.b	'+6',0,0
	dc.b	'+7',0,0
	dc.b	'-8',0,0
	dc.b	'-7',0,0
	dc.b	'-6',0,0
	dc.b	'-5',0,0
	dc.b	'-4',0,0
	dc.b	'-3',0,0
	dc.b	'-2',0,0
	dc.b	'-1',0,0

	even

terpath:dc.b	'A:\*.UMP',0
	ds.b	50
	even
tername:dc.b	0
	ds.b	15
	even
ltlabel:dc.b	'Load a UCDM player',0

path:	dc.b	'A:\*.AVR',0
	ds.b	50
	even
name:	dc.b	0
	ds.b	15
	even
label:	dc.b	'Load a Sample',0
	ds.b	30
	even
slabel:	dc.b	'Save a Sample',0
	ds.b	30
	even
wholename:
	ds.b	70
	even

modpath:dc.b	'A:\*.MOD',0
	ds.b	50
	even
modname:dc.b	0
	ds.b	15
	even
smlabel:dc.b	'Save a Module',0
	ds.b	30
	even
lmlabel:dc.b	'Load a Module',0
	ds.b	30
	even
delpath:dc.b	'A:\*.*',0
	ds.b	50
	even
delname:dc.b	0
	ds.b	15
	even
dellabel:
	dc.b	'DELETE a File',0
	ds.b	30
	even
blkpath:dc.b	'A:\*.BLK',0
	ds.b	50
	even
blkname:dc.b	0
	ds.b	15
	even
lblabel:dc.b	'Load a Block',0
	ds.b	30
	even
sblabel:dc.b	'Save a Block',0
	ds.b	30
	even
CallEvntTimerAsOftenAsPossible:
	dc.w	0
superoldstack2:
	dc.l	0

GoToGEM:
	tst.w	kanejg†uttillGEM
	bne	stoppibackeningeGEMh„rinte

;	move.l	(sp)+,superoldstack2

	jsr	v„ntap†sl„pp2343434
	jsr	reinstallsystem 	; Installera systemet igen
	move.l	sp,dummen
	move.l	oldstack,-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa tebax till user
	addq.l	#6,sp

	bsr	makebusy
	bsr	forceredrawofGEMscreen
	bsr	makearrow
	
	move.l	menupointer,a1
	moveq	#1,d1			; Visa menyn
	bsr	menu_bar

	bsr	setuptheinfowindow
v„ntap†meddelanden:
	lea	messbuffer,a1
	bsr	evnt_mesag		; Inv„nta ett meddelande

	clr.w	windupdate

	cmp.w	#WM_FULLED,messbuffer
	bne.s	intehoppatillbakatillOctan
	move.w	window_handle,d0	; Tryckte han p† FULL?
	cmp.w	messbuffer+6,d0		; Isf hoppa tillbaka till Octan
	bne.s	intehoppatillbakatillOctan
;	moveq	#0,d1
;	jsr	evnt_timer
	bra	tebaxtillOctan
intehoppatillbakatillOctan:

	cmp.w	#WM_CLOSED,messbuffer
	bne.s	inted”daOctan
	move.w	window_handle,d0	; Tryckte han p† CLOSE?
	cmp.w	messbuffer+6,d0		; Isf f”rs”k avsluta hela skiten
	bne.s	inted”daOctan
	move.w	#FILEMENU,messbuffer+6
	move.w	#1,windupdate
	moveq	#3,d1			; Upppdatera
	bsr	wind_update
	move.l	menupointer,a1
	move.w	messbuffer+6,d1
	moveq	#0,d2
	bsr	menu_tnormal		; Visa menyn vald
	bra	direktquit
inted”daOctan:

	cmp.w	#WM_MOVED,messbuffer	; Dax att flytta f”nstret?
	bne.s	inteflyttap†v†ratf”nster
	move.w	window_handle,d0
	cmp.w	messbuffer+6,d0
	bne.s	inteflyttap†v†ratf”nster
	move.l	messbuffer+8,fx
	move.l	messbuffer+12,fx+4
	lea	aespb(pc),a0
	move.w	#105,$18(a0)
	move.w	#6,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	window_handle,$30(a0)
	move.w	#WF_CURRXYWH,$32(a0)
	move.l	fx,$34(a0)
	move.l	fx+4,$38(a0)
	jsr	callaes		; Flytta f”nstret
inteflyttap†v†ratf”nster:

	cmp.w	#WM_REDRAW,messbuffer
	bne	interitaomf”nsterinfon	; Dax att rita om i f”nstret?
	move.w	window_handle,d0
	cmp.w	messbuffer+6,d0
	bne	interitaomf”nsterinfon
	moveq	#1,d1
	bsr	wind_update
	lea	aespb(pc),a0
	move.w	#104,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#5,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	window_handle,$30(a0)
	move.w	#WF_WORKXYWH,$32(a0)
	jsr	callaes		; Ta reda p† f”nsterkoordinaterna
	lea	aespb(pc),a0
	move.l	$432(a0),fx
	move.l	$436(a0),fx+4
	add.l	#$00030003,fx
	move.l	window_form,a0
	moveq	#FORMEN,d0
	mulu	#SIZE_OBJECT,d0
	add.l	d0,a0		; Fixa till s† objectet ligger vid
	move.l	fx,OB_X(a0)	; f”nstret
	lea	aespb(pc),a0
	move.w	#104,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#5,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	window_handle,$30(a0)
	move.w	#WF_FIRSTXYWH,$32(a0)
	jsr	callaes		; Ta reda p† f”rsta delen att uppdatera
	lea	aespb(pc),a0
	move.l	$432(a0),fx
	move.l	$436(a0),fx+4
	bsr	checkanddraw
loopaframhelaformenr„tt:
	lea	aespb(pc),a0
	move.w	#104,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#5,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	window_handle,$30(a0)
	move.w	#WF_NEXTXYWH,$32(a0)
	jsr	callaes		; Ta reda p† resten att uppdatera
	lea	aespb(pc),a0
	move.l	$432(a0),fx
	move.l	$436(a0),fx+4
	tst.l	fx+4
	beq.s	f„rdigmedritandet
	bsr	checkanddraw
	bra.s	loopaframhelaformenr„tt
f„rdigmedritandet:
	moveq	#0,d1
	bsr	wind_update
interitaomf”nsterinfon:

	cmp.w	#WM_TOPPED,messbuffer
	bne.s	intetoppaf”nstret	; Dax att placera f”nstret f”rst?
	move.w	window_handle,d0
	cmp.w	messbuffer+6,d0
	bne.s	intetoppaf”nstret
	lea	aespb(pc),a0
	move.w	#105,$18(a0)
	move.w	#6,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	window_handle,$30(a0)
	move.w	#WF_TOP,$32(a0)
	jsr	callaes		; S„tt f”nstret h”gst!
intetoppaf”nstret:

	cmp.w	#MN_SELECTED,messbuffer	; Žr det ett menymeddelande?
	bne	v„ntap†meddelanden

	cmp.w	#SHARE,messbuffer+8	; Toggla SHARE-time
	bne.s	intedaxatttogglaSHARE
	not.w	CallEvntTimerAsOftenAsPossible
	move.l	menupointer,a1
	move.w	#SHARE,d1
	moveq	#1,d2
	tst.w	CallEvntTimerAsOftenAsPossible
	bne.s	visachecked
	subq.w	#1,d2
visachecked:
	bsr	menu_icheck		; S„tt/bort med checked
intedaxatttogglaSHARE:

	cmp.w	#BACK,messbuffer+8	; BACK?
	bne.s	intetillbakatillOctalysern
tebaxtillOctan:
	bsr	killwinfowindow
	move.l	menupointer,a1
	move.w	messbuffer+6,d1
	moveq	#1,d2
	bsr	menu_tnormal		; Visa menynnormalt igen
	bra	tillbakatillOctan	; Tillbaka till Octalysern
intetillbakatillOctalysern:

	cmp.w	#SHELLNOW,messbuffer+8
	bne	integ†tillshell
letashell:
	moveq	#3,d1			; Upppdatera
	bsr	wind_update
	move.w	#1,windupdate
	move.l	env,a0
letar„ttp†SHELL:
	tst.b	(a0)
	bne.s	kanvaran†ge
	tst.b	1(a0)
	beq	ingetshellfinnesatttillg†
	addq.w	#1,a0
kanvaran†ge:
	cmp.b	#'S',(a0)
	bne.s	tan„sta
	cmp.b	#'H',1(a0)
	bne.s	tan„sta
	cmp.b	#'E',2(a0)
	bne.s	tan„sta
	cmp.b	#'L',3(a0)
	bne.s	tan„sta
	cmp.b	#'L',4(a0)
	bne.s	tan„sta
	cmp.b	#'=',5(a0)
	bne.s	tan„sta
	addq.w	#6,a0
	bra.s	hittatpathendit
tan„sta:
	addq.w	#1,a0
	bra.s	letar„ttp†SHELL
hittatpathendit:		; a0 inneh†ller pathen till SHELL nu
	move.l	a0,shellpath

	bsr	makebusy

	bsr	killwinfowindow

	moveq	#2,d1			; Upppdatera inte mer
	bsr	wind_update

	move.l	menupointer,a0
	moveq	#0,d1			; Sluta visa menyn
	bsr	menu_bar

	moveq	#0,d0
	move.l	shellpath,a0
	move.b	(a0),d0
	sub.b	#'A',d0
	move.w	d0,-(sp)
	move.w	#$e,-(sp)
	trap	#1			; R„tt aktiv drajv
	addq.w	#4,sp

	move.l	shellpath,a0
searchforendofpath23:
	tst.b	(a0)			; Leta reda p† nollan
	beq.s	slutetpapath23
	addq.w	#1,a0
	bra.s	searchforendofpath23
slutetpapath23:
	cmp.b	#'\',(a0)
	beq.s	forstaslachen23		; Leta bak†t efter f”rsta \
	subq.w	#1,a0
	bra.s	slutetpapath23
forstaslachen23:
	clr.b	(a0)
	move.l	a0,-(sp)
	lea.l	1(a0),a3
	move.l	nametorun,a0
	move.w	#RUNNAME,d0
	mulu	#SIZE_OBJECT,d0
	move.l	OB_SPEC(a0,d0.w),a1
	move.l	TE_PTEXT(a1),a2
	moveq	#12,d0
skrivtillfilnamnet:
	move.b	(a3)+,(a2)+
	dbra	d0,skrivtillfilnamnet
	lea	fx,a1
	move.l	nametorun,a2
	moveq	#0,d1
	moveq	#2,d2
	bsr	objc_draw		; Rita formen
	move.l	shellpath,-(sp)
	move.w	#$3b,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	(sp)+,a0
	move.b	#'\',(a0)

	lea	fx,a1
	move.l	nametorun,a2
	moveq	#0,d1
	moveq	#2,d2
	bsr	objc_draw		; Rita formen

	move.l	env,-(sp)
	move.l	commandline,-(sp)
	move.l	shellpath,-(sp)
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp

	tst.w	d0
	bge.s	alltok2			; Visa felkod om det finns
	neg.l	d0
	move.l	d0,d1
	bsr	form_error		; n†gon
alltok2:
	bsr	killallactivwindows

	bsr	setmyowndesktop

	bsr	forceredrawofGEMscreen
	bsr	makearrow
	move.l	menupointer,a1
	moveq	#1,d1			; Visa menyn
	bsr	menu_bar
	bsr	setuptheinfowindow
	moveq	#3,d1			; Upppdatera
	bsr	wind_update

	bra.s	integ†tillshell
ingetshellfinnesatttillg†:
	move.l	nonoshell,a1
	moveq	#1,d1			; Hittade inget skal
	bsr	form_alert
integ†tillshell:

	cmp.w	#LOADRUN,messbuffer+8
	bne	intestartaig†ngettprogg
	moveq	#3,d1			; Upppdatera
	bsr	wind_update
	move.w	#1,windupdate
	lea	runlabel,a1
	lea	runname,a2 		; Visa filv„ljaren
	lea	runpath,a3
	jsr	fsel_exinput
	tst.w	d0
	beq	intestartaig†ngettprogg
	tst.w	d1
	beq	intestartaig†ngettprogg

	bsr	makebusy

	bsr	killwinfowindow

	moveq	#2,d1			; Upppdatera inte mer
	bsr	wind_update

	move.l	menupointer,a0
	moveq	#0,d1			; Sluta visa menyn
	bsr	menu_bar

	move.l	nametorun,a0
	move.w	#RUNNAME,d0
	mulu	#SIZE_OBJECT,d0
	move.l	OB_SPEC(a0,d0.w),a1
	move.l	TE_PTEXT(a1),a2
	lea	runname,a3
	moveq	#12,d0
skrivtillfilnamnet2:
	move.b	(a3)+,(a2)+
	dbra	d0,skrivtillfilnamnet2

	lea	fx,a1
	move.l	nametorun,a2
	moveq	#0,d1
	moveq	#2,d2
	bsr	objc_draw		; Rita formen

	moveq	#0,d0
	move.b	runpath,d0
	sub.b	#'A',d0
	move.w	d0,-(sp)
	move.w	#$e,-(sp)
	trap	#1			; R„tt aktiv drajv
	addq.w	#4,sp

	lea	runpath,a0
searchforendofpath2:
	tst.b	(a0)			; Leta reda p† nollan
	beq.s	slutetpapath2
	addq.w	#1,a0
	bra.s	searchforendofpath2
slutetpapath2:
	cmp.b	#'\',(a0)
	beq.s	forstaslachen2		; Leta bak†t efter f”rsta \
	subq.w	#1,a0
	bra.s	slutetpapath2
forstaslachen2:
	clr.b	(a0)
	move.l	a0,-(sp)
	pea	runpath
	move.w	#$3b,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	(sp)+,a0
	move.b	#'\',(a0)

	lea	fx,a1
	move.l	nametorun,a2
	moveq	#0,d1
	moveq	#2,d2
	bsr	objc_draw		; Rita formen

	lea	runpath,a0
	lea	runname,a1
	jsr	makeawholename

	move.l	env,-(sp)
	move.l	commandline,-(sp)
	pea	wholename
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp

	tst.w	d0
	bge.s	alltok			; Visa felkod om det finns
	neg.l	d0
	move.l	d0,d1
	bsr	form_error		; n†gon
alltok:
	bsr	killallactivwindows

	bsr	setmyowndesktop

	bsr	forceredrawofGEMscreen
	bsr	makearrow
	move.l	menupointer,a1
	moveq	#1,d1			; Visa menyn
	bsr	menu_bar
	bsr	setuptheinfowindow
	moveq	#3,d1			; Upppdatera
	bsr	wind_update
intestartaig†ngettprogg:

	cmp.w	#SCOMLINE,messbuffer+8
	bne.s	intest„llaincomlinjen	; SCOMLINE?
	move.l	command_form,a0
	move.w	#COMLINE,d0
	mulu	#SIZE_OBJECT,d0
	move.l	OB_SPEC(a0,d0.w),a1
	move.l	TE_PTEXT(a1),a2
	clr.b	(a2)
	moveq	#3,d1			; Upppdatera
	bsr	wind_update
	move.w	#1,windupdate
	bsr	fixatillnytext
	lea	fx,a1
	move.l	command_form,a2
	bsr	form_center		; Centrera
	lea	fx,a1
	moveq	#0,d1
	bsr	form_dial		; Reservera
	lea	fx,a1
	move.l	command_form,a2
	moveq	#0,d1
	moveq	#2,d2
	bsr	objc_draw		; Rita formen
	move.l	command_form,a1
	moveq	#COMLINE,d1
	bsr	form_do			; V„nta p† aktion
	move.l	command_form,a1
	bsr	show_butt_normal	; Visa formknappen normalt igen
	lea	fx,a1
	moveq	#3,d1
	bsr	form_dial		; Sl„pp
intest„llaincomlinjen:

	cmp.w	#VERSION,messbuffer+8	; VERSION?
	bne.s	intevisainfon
	moveq	#3,d1			; Upppdatera
	bsr	wind_update
	move.w	#1,windupdate
	bsr	fixatillnytext
	move.l	infopointer,a1
	lea	nytext,a2
	moveq	#FREEMEM,d1
	bsr	menu_text		; Byt text
	lea	fx,a1
	move.l	infopointer,a2
	bsr	form_center		; Centrera
	lea	fx,a1
	moveq	#0,d1
	bsr	form_dial		; Reservera
	lea	fx,a1
	move.l	infopointer,a2
	moveq	#0,d1
	moveq	#2,d2
	bsr	objc_draw		; Rita formen
	move.l	infopointer,a1
	moveq	#0,d1
	bsr	form_do			; V„nta p† aktion
	move.l	infopointer,a1
	bsr	show_butt_normal	; Visa formknappen normalt igen
	lea	fx,a1
	moveq	#3,d1
	bsr	form_dial		; Sl„pp
intevisainfon:

	cmp.w	#SHELLING,messbuffer+8	; SHELLING?
	bne.s	intevisahj„lpshelling
	moveq	#3,d1			; Upppdatera
	bsr	wind_update
	move.w	#1,windupdate
	lea	fx,a1
	move.l	hj„lpshelling,a2
	bsr	form_center		; Centrera
	lea	fx,a1
	moveq	#0,d1
	bsr	form_dial		; Reservera
	lea	fx,a1
	move.l	hj„lpshelling,a2
	moveq	#0,d1
	moveq	#2,d2
	bsr	objc_draw		; Rita formen
	move.l	hj„lpshelling,a1
	moveq	#0,d1
	bsr	form_do			; V„nta p† aktion
	move.l	hj„lpshelling,a1
	bsr	show_butt_normal	; Visa formknappen normalt igen
	lea	fx,a1
	moveq	#3,d1
	bsr	form_dial		; Sl„pp
intevisahj„lpshelling:

	cmp.w	#MENUSYS,messbuffer+8	; MENUSYS?
	bne.s	intevisahj„lpmen
	moveq	#3,d1			; Upppdatera
	bsr	wind_update
	move.w	#1,windupdate
	lea	fx,a1
	move.l	hj„lpmen,a2
	bsr	form_center		; Centrera
	lea	fx,a1
	moveq	#0,d1
	bsr	form_dial		; Reservera
	lea	fx,a1
	move.l	hj„lpmen,a2
	moveq	#0,d1
	moveq	#2,d2
	bsr	objc_draw		; Rita formen
	move.l	hj„lpmen,a1
	moveq	#0,d1
	bsr	form_do			; V„nta p† aktion
	move.l	hj„lpmen,a1
	bsr	show_butt_normal	; Visa formknappen normalt igen
	lea	fx,a1
	moveq	#3,d1
	bsr	form_dial		; Sl„pp
intevisahj„lpmen:

	cmp.w	#EXEPROG,messbuffer+8	; EXEPROG?
	bne.s	intevisahj„lpexec
	moveq	#3,d1			; Upppdatera
	bsr	wind_update
	move.w	#1,windupdate
	lea	fx,a1
	move.l	hj„lpexec,a2
	bsr	form_center		; Centrera
	lea	fx,a1
	moveq	#0,d1
	bsr	form_dial		; Reservera
	lea	fx,a1
	move.l	hj„lpexec,a2
	moveq	#0,d1
	moveq	#2,d2
	bsr	objc_draw		; Rita formen
	move.l	hj„lpexec,a1
	moveq	#0,d1
	bsr	form_do			; V„nta p† aktion
	move.l	hj„lpexec,a1
	bsr	show_butt_normal	; Visa formknappen normalt igen
	lea	fx,a1
	moveq	#3,d1
	bsr	form_dial		; Sl„pp
intevisahj„lpexec:

	cmp.w	#QUIT,messbuffer+8	; QUIT?
	bne.s	intequitsomvarvald
direktquit:
	move.l	quitalert,a1
	moveq	#2,d1			; Vill anv„ndaren verkligen
	bsr	form_alert		; avsluta hela programmet?
	cmp.w	#1,d0
	beq.s	avslutaprogrammet
intequitsomvarvald:
	move.l	menupointer,a1
	move.w	messbuffer+6,d1
	moveq	#1,d2
	bsr	menu_tnormal		; Visa menynnormalt igen
	tst.w	windupdate
	beq	v„ntap†meddelanden
	moveq	#2,d1
	bsr	wind_update
	bra	v„ntap†meddelanden
avslutaprogrammet:
	move.l	menupointer,a0
	moveq	#0,d1			; Sluta visa menyn
	bsr	menu_bar
	bsr	killwinfowindow
	tst.w	windupdate
	beq.s	k”rvidarenup†eng†ng
	moveq	#2,d1
	bsr	wind_update
k”rvidarenup†eng†ng:
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa upp i super
	addq.l	#6,sp
	move.l	dummen,sp
	jmp	hoppainiavslutning
tillbakatillOctan:
	move.l	menupointer,a0
	moveq	#0,d1			; Sluta visa menyn
	bsr	menu_bar
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1			; Hoppa upp i super
	addq.l	#6,sp
	move.l	dummen,sp
	jsr	myownsystem		; S„tt upp TRACKERsystemet
;	move.l	superoldstack2,-(sp)
stoppibackeningeGEMh„rinte:
	rts

fixatillnytext:
	pea	-1
	move.w	#$48,-(sp)
	trap	#1			; Ta reda p† fritt minne
	addq.w	#6,sp

	lea	nytext+10,a0
	clr.b	-(a0)
	divu    #10000,D0
	movea.w	d0,a4           ;put d0 in a4 for later use
	move.w	#2,d5
tree_last:
	clr.w	d0
	swap	d0
	divu	#10,d0
	swap	d0
	add.b	#'0',d0
	move.b	d0,-(a0)
	dbra	d5,tree_last
	move.b	#'.',-(a0)
	clr.w	d0
	swap	d0
	divu	#10,d0
	swap	d0
	add.b	#'0',d0
	move.b	d0,-(a0)
	move.w	a4,d0
	swap	d0
	move.w	#1,d5
two_first:
	clr.w	d0
	swap	d0
	divu	#10,d0
	swap	d0
	add.b	#'0',d0
	move.b	d0,-(a0)
	dbra	d5,two_first
	move.b	#'.',-(a0)
	clr.w	d0
	swap	d0
	divu	#10,d0
	swap	d0
	add.b	#'0',d0
	move.b	d0,-(a0)
	rts

makebusy:
	tst.w	MiNTispresent
	bne.s	makearrow
	lea	0,a1
	moveq	#2,d1
	bsr	graf_mouse
	rts

makearrow:
	lea	0,a1
	moveq	#0,d1
	bsr	graf_mouse
	rts

forceredrawofGEMscreen:
	lea	aespb(pc),a0
	move.w	#104,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#5,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	#0,$30(a0)
	move.w	#4,$32(a0)
	jsr	callaes		; Ta reda p† max storlek p† ett f”nster
	lea	aespb(pc),a0
	move.w	#51,$18(a0)
	move.w	#9,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	#3,$30(a0)
	move.w	#0,$32(a0)
	move.w	#0,$34(a0)
	move.w	#0,$36(a0)
	move.w	#0,$38(a0)
	move.l	$432(a0),fx
	subq.w	#1,fx+2
	move.l	$436(a0),fx+4
	addq.w	#1,fx+6
	move.l	fx,$3a(a0)
	move.l	fx+4,$3e(a0)
	jsr	callaes		; Beg„r att GEM skall rita om sk„rmen

;	lea	aespb(pc),a0
;	move.w	#100,$18(a0)
;	move.w	#5,$1a(a0)
;	move.w	#1,$1c(a0)
;	move.w	#0,$1e(a0)
;	move.w	#0,$20(a0)
;	move.w	#0,$30(a0)
;	move.l	$432(a0),fx
;	subq.w	#1,fx+2
;	move.l	$436(a0),fx+4
;	addq.w	#1,fx+6
;	move.l	fx,$32(a0)
;	move.l	fx+4,$36(a0)
;	jsr	callaes		; Skapa ett f”nster
;	lea	aespb(pc),a0
;	tst.w	$430(a0)
;	bmi	detgickinteattf†ettf”nster
;	move.w	$430(a0),winhandle
;	move.w	#101,$18(a0)
;	move.w	#5,$1a(a0)
;	move.w	#1,$1c(a0)
;	move.w	#0,$1e(a0)
;	move.w	#0,$20(a0)
;	move.w	winhandle,$30(a0)
;	move.l	fx,$32(a0)
;	move.l	fx+4,$36(a0)
;	jsr	callaes		; ™ppna f”nstret
;	lea	aespb(pc),a0
;	move.w	#102,$18(a0)
;	move.w	#1,$1a(a0)
;	move.w	#1,$1c(a0)
;	move.w	#0,$1e(a0)
;	move.w	#0,$20(a0)
;	move.w	winhandle,$30(a0)
;	jsr	callaes		; St„ng f”nstret
;	lea	aespb(pc),a0
;	move.w	#103,$18(a0)
;	move.w	#1,$1a(a0)
;	move.w	#1,$1c(a0)
;	move.w	#0,$1e(a0)
;	move.w	#0,$20(a0)
;	move.w	winhandle,$30(a0)
;	jsr	callaes		; Ta bort f”nstret

	moveq	#0,d1		; Dela med lite tid s† att processerna
	jsr	evnt_timer	; hinner med att uppdatera sina f”nster
;detgickinteattf†ettf”nster:
	rts

;============================================================ GEMrutiner ==

setmyowndesktop:
	lea	aespb(pc),a0
	move.w	#105,$18(a0)
	move.w	#6,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	#0,$30(a0)
	move.w	#WF_NEWDESK,$32(a0)
	move.w	desktopen,$34(a0)
	move.w	desktopen+2,$36(a0)
	move.w	#DESKTOPP,$38(a0)
	jsr	callaes
	rts

killallactivwindows:
	lea	aespb(pc),a0
	move.w	#104,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#5,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	#0,$30(a0)
	move.w	#10,$32(a0)
	jsr	callaes		; Ta reda p† max storlek p† ett f”nster
	lea	aespb(pc),a0
	move.w	$432(a0),winhandle
	tst.w	$430(a0)
	beq.s	ingafleraf”nsteratttabort
	tst.w	$432(a0)
	ble.s	ingafleraf”nsteratttabort
	lea	aespb(pc),a0
	move.w	#102,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	winhandle,$30(a0)
	jsr	callaes		; St„ng f”nstret
	lea	aespb(pc),a0
	tst.w	$430(a0)
	beq.s	ingafleraf”nsteratttabort
	move.w	#103,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	winhandle,$30(a0)
	jsr	callaes		; Ta bort f”nstret
	lea	aespb(pc),a0
	tst.w	$430(a0)
	beq.s	ingafleraf”nsteratttabort
	bra	killallactivwindows
ingafleraf”nsteratttabort:
	rts

checkanddraw:
	movem.w	messbuffer+8,d0-d3
	add.w	d0,d2
	add.w	d1,d3			; Ser till att vi inte uppdaterar
	movem.w	fx,d4-d7		; mer „n n”dv„ndigt
	add.w	d4,d6
	add.w	d5,d7

;	bsr	skrivutdna

	cmp.w	d0,d4
	bge.s	n„n„n„x1
	move.w	d0,d4
n„n„n„x1:
	cmp.w	d1,d5
	bge.s	n„n„n„y1
	move.w	d1,d5
n„n„n„y1:
	cmp.w	d2,d6
	ble.s	n„n„n„x2
	move.w	d2,d6
n„n„n„x2:
	cmp.w	d3,d7
	ble.s	n„n„n„y2
	move.w	d3,d7
n„n„n„y2:
;	bsr	skrivutdna


	sub.w	d4,d6
	ble.s	beh”verinteritan†ge
	sub.w	d5,d7
	ble.s	beh”verinteritan†ge
	movem.w	d4-d7,fx
	move.l	window_form,a2
	lea	fx,a1
	moveq	#0,d1
	moveq	#2,d2
	bsr	objc_draw		; Rita en del av formen
beh”verinteritan†ge:
	rts

setuptheinfowindow:
	lea	fx,a1
	move.l	window_form,a2
	bsr	form_center	; Centrera f”nstret
	lea	aespb(pc),a0
	move.w	#108,$18(a0)
	move.w	#6,$1a(a0)
	move.w	#5,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	#0,$30(a0)
	move.w	#(NAME+CLOSER+MOVER+FULLER),$32(a0)
	move.l	fx,$34(a0)
	move.l	fx+4,$38(a0)
	jsr	callaes		; Ta reda p† max storlek p† ett f”nster
	lea	aespb(pc),a0
	move.w	#100,$18(a0)
	move.w	#5,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	#(NAME+CLOSER+MOVER+FULLER),$30(a0)
	move.l	$432(a0),fx
	move.l	$436(a0),fx+4
	move.l	fx,$32(a0)
	move.l	fx+4,$36(a0)
	jsr	callaes		; Skapa ett f”nster
	lea	aespb(pc),a0
	tst.w	$430(a0)
	bmi	detgickinteattf†ettf”nstertillinfon
	move.w	$430(a0),window_handle
	move.w	#105,$18(a0)
	move.w	#6,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	window_handle,$30(a0)
	move.w	#WF_NAME,$32(a0)
	move.l	#window_text,$34(a0)
	jsr	callaes
	lea	aespb(pc),a0
	move.w	#101,$18(a0)
	move.w	#5,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	window_handle,$30(a0)
	move.l	fx,$32(a0)
	move.l	fx+4,$36(a0)
	jsr	callaes		; ™ppna f”nstret
detgickinteattf†ettf”nstertillinfon:
	rts

killwinfowindow:
	tst.w	window_handle
	bmi.s	ingetf”nsteratttabort
	lea	aespb(pc),a0
	move.w	#102,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	window_handle,$30(a0)
	jsr	callaes		; St„ng f”nstret
	lea	aespb(pc),a0
	move.w	#103,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	window_handle,$30(a0)
	jsr	callaes		; Ta bort f”nstret
ingetf”nsteratttabort:
	rts

centerup_the_helpmenu:
	lea	aespb(pc),a0
	move.w	#104,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#5,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	#0,$30(a0)
	move.w	#4,$32(a0)
	jsr	callaes		; Ta reda p† max storlek p† ett f”nster
	lea	aespb(pc),a0
	move.l	$432(a0),fx
	move.l	$436(a0),fx+4	; Bredden p† sk„rmen i fx+4

	move.l	menupointer,a0
	moveq	#HEELP,d0
	mulu	#SIZE_OBJECT,d0
	add.l	d0,a0		; Fixa till s† att titeln HELP hamnar
	move.w	fx+4,d0		; r„tt oavsett uppl”sning
	sub.w	#32,d0
	sub.w	OB_WIDTH(a0),d0
	move.w	d0,OB_X(a0)

	move.l	nametorun,a0
	moveq	#RUNNAME,d0
	mulu	#SIZE_OBJECT,d0
	add.l	d0,a0		; Fixa till s† att titeln f”r prognamnet
	move.w	fx+4,OB_WIDTH(a0); hamnar r„tt oavsett uppl”sning

	move.l	menupointer,a0
	moveq	#HELPMENU,d0
	mulu	#SIZE_OBJECT,d0
	add.l	d0,a0		; Fixa till s† att boxen till HELP hamnar
	move.w	fx+4,d0		; r„tt oavsett uppl”sning
	subq.w	#8,d0
	sub.w	OB_WIDTH(a0),d0
	move.w	d0,OB_X(a0)

	move.l	menupointer,a0
	cmp.w	#18,OB_HEIGHT+MENCLEAR*SIZE_OBJECT(a0)
	ble.s	k”rmedSMALL
	lea	SIZE_OBJECT*SMALL(a0),a0
	or.w	#HIDETREE,OB_FLAGS(a0)
	bra.s	k”rmedBIGG
k”rmedSMALL:
	lea	SIZE_OBJECT*BIGG(a0),a0
	or.w	#HIDETREE,OB_FLAGS(a0)
k”rmedBIGG:

	move.l	menupointer,a0
	move.l	nametorun,a1
	move.w	fx+4,d0
	move.w	d0,OB_WIDTH(a0); hamnar r„tt oavsett uppl”sning
	add.w	#SIZE_OBJECT,a0
	move.w	d0,OB_WIDTH(a0)
	move.w	d0,OB_WIDTH(a1)
	add.w	#SIZE_OBJECT,a1
	move.w	d0,OB_WIDTH(a1)
	sub.w	#32,d0
	lea	SIZE_OBJECT(a0),a0
	move.w	d0,OB_WIDTH(a0)

	rts

show_butt_normal:	; Ta bort selected p† formknappen
	move.w	d0,d1
	mulu	#SIZE_OBJECT,d1
	add.l	d1,a1
	move.w	OB_STATE(a1),d1
	move.w	#SELECTED,d0
	not.w	d0
	and.w	d0,d1
	move.w	d1,OB_STATE(a1)
	rts

graf_mouse:		; a1 pekare till mus d1 mustyp
	lea	aespb(pc),a0
	move.w	#78,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a1,$230(a0)
	move.w	d1,$30(a0)
	jsr	callaes
	lea	aespb(pc),a0
	move.w	$430(a0),d0
	rts

menu_text:		; a1 tr„d a2 ny text d1 objekt
	lea	aespb(pc),a0
	move.w	#34,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#2,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a1,$230(a0)
	move.l	a2,$234(a0)
	move.w	d1,$30(a0)
	jsr	callaes
	lea	aespb(pc),a0
	move.w	$430(a0),d0
	rts

menu_register:		; a1 ny text d1 ID
	lea	aespb(pc),a0
	move.w	#35,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a1,$230(a0)
	move.w	d1,$30(a0)
	jsr	callaes
	lea	aespb(pc),a0
	move.w	$430(a0),d0
	rts

objc_draw:		; a1 fx a2 tr„d d1 start d2 djup
	lea	aespb(pc),a0
	move.w	#42,$18(a0)
	move.w	#6,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a2,$230(a0)
	move.w	d1,$30(a0)
	move.w	d2,$32(a0)
	move.l	(a1)+,$34(a0)
	move.l	(a1)+,$38(a0)
	jsr	callaes
	lea	aespb(pc),a0
	move.w	$430(a0),d0
	rts

evnt_timer:		; d1 Ticks att v„nta i millisekunder
	lea	aespb(pc),a0
	move.w	#24,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	d1,$30(a0)
	swap	d1
	move.w	d1,$32(a0)
	jsr	callaes
	lea	aespb(pc),a0
	move.w	$430(a0),d0
	rts

form_do:		; a1 tr„d d1 b”rjan
	lea	aespb(pc),a0
	move.w	#50,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a1,$230(a0)
	move.w	d1,$30(a0)
	jsr	callaes
	lea	aespb(pc),a0
	move.w	$430(a0),d0
	rts

form_dial:		; a1 pekare till fx d1 funktion
	lea	aespb(pc),a0
	move.w	#51,$18(a0)
	move.w	#9,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	lea	$30(a0),a2
	move.w	d1,(a2)+
	clr.l	(a2)+
	clr.l	(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	jsr	callaes
	lea	aespb(pc),a0
	move.w	$430(a0),d0
	rts

form_center:		; a1 pekare till fx a2 tr„d
	move.l	a1,-(sp)
	lea	aespb(pc),a0
	move.w	#54,$18(a0)
	move.w	#0,$1a(a0)
	move.w	#5,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a2,$230(a0)
	jsr	callaes
	lea	aespb(pc),a0
	move.l	(sp)+,a1
	move.w	$430(a0),d0
	move.l	$432(a0),(a1)+
	move.l	$436(a0),(a1)+
	rts

wind_update:		; d1 funktion
	lea	aespb(pc),a0
	move.w	#107,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	d1,$30(a0)
	jsr	callaes
	lea	aespb(pc),a0
	move.w	$430(a0),d0
	rts

menu_icheck:		; a1 meny d1 object
	lea	aespb(pc),a0
	move.w	#31,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a1,$230(a0)
	move.w	d1,$30(a0)
	move.w	d2,$32(a0)
	jsr	callaes
	lea	aespb(pc),a0
	move.w	$430(a0),d0
	rts

menu_tnormal:		; a1 meny d1 objekt
	lea	aespb(pc),a0
	move.w	#33,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a1,$230(a0)
	move.w	d1,$30(a0)
	move.w	d2,$32(a0)
	jsr	callaes
	lea	aespb(pc),a0
	move.w	$430(a0),d0
	rts

evnt_mesag:		; a1 messbuffer
	lea	aespb(pc),a0
	move.w	#23,$18(a0)
	move.w	#0,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a1,$230(a0)
	jsr	callaes
	lea	aespb(pc),a0
	move.w	$430(a0),d0
	rts

menu_bar:		; a1 menyn d1 visa/ta bort
	lea	aespb(pc),a0
	move.w	#30,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a1,$230(a0)
	move.w	d1,$30(a0)
	jsr	callaes
	lea	aespb(pc),a0
	move.w	$430(a0),d0
	rts

rsrc_gaddr:		; a1 pekare till variabel d1 typ d2 vilken
	move.l	a1,-(sp)
	lea	aespb(pc),a0
	move.w	#112,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#1,$20(a0)
	move.w	d1,$30(a0)
	move.w	d2,$32(a0)
	jsr	callaes
	lea	aespb(pc),a0
	move.l	(sp)+,a1
	move.l	$630(a0),(a1)
	move.w	$430(a0),d0
	rts

form_alert:		; a1 str„ng d1 huvudknapp
	lea	aespb(pc),a0
	move.w	#52,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a1,$230(a0)
	move.w	d1,$30(a0)
	jsr	callaes
	lea	aespb(pc),a0
	move.w	$430(a0),d0
	rts

shel_write:		; a1 filnamn a2 commandline
	lea	aespb(pc),a0
	move.w	#121,$18(a0)
	move.w	#3,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#2,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a1,$230(a0)
	move.l	a2,$234(a0)
	move.w	#0,$30(a0)
	move.w	#1,$32(a0)
	move.w	#1,$34(a0)
	jsr	callaes
	lea	aespb(pc),a0
	move.w	$430(a0),d0
	rts

form_error:		; d1 errorkod
	lea	aespb(pc),a0
	move.w	#53,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	d1,$30(a0)
	jsr	callaes
	lea	aespb(pc),a0
	move.w	$430(a0),d0
	rts

rsrc_load:		; a1 filnamn
	lea	aespb(pc),a0
	move.w	#110,$18(a0)
	move.w	#0,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a1,$230(a0)
	jsr	callaes
	lea	aespb(pc),a0
	move.w	$430(a0),d0
	rts

rsrc_free:
	lea	aespb(pc),a0
	move.w	#111,$18(a0)
	move.w	#0,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	jsr	callaes
	lea	aespb(pc),a0
	move.w	$430(a0),d0
	rts


appl_init:
	lea	aespb(pc),a0
	clr.w	$1a(a0)
	move.w	#1,$1c(a0)
	clr.w	$1e(a0)
	move.w	#$a,$18(a0)
	jsr	callaes
	lea	aespb(pc),a0
	move.w	$430(a0),d0
	rts

callaes:move.l	a0,d1
	move.w	#$c8,d0
	trap	#2
	rts

appl_exit:
	lea	aespb(pc),a0
	clr.w	$1a(a0)
	move.w	#1,$1c(a0)
	clr.w	$1e(a0)
	move.w	#$13,$18(a0)
	jsr	callaes
	lea	aespb(pc),a0
	move.w	$430(a0),d0
	rts

fsel_exinput:		; a1 label   a2 name	a3 path   d0 error   d1 button
	movem.l	a0-a3/d0-d1,-(sp)
	move.l	#$FFFFFFFF,allmediachanged
	moveq	#3,d1			; Upppdatera
	bsr	wind_update
	move.l	#$FFFFFFFF,allmediachanged
	movem.l	(sp)+,a0-a3/d0-d1

	lea	aespb(pc),a0
	move.l	a1,$238(a0)
	move.l	a2,$234(a0)
	move.l	a3,$230(a0)
	clr.w	$1a(a0)
	move.w	#2,$1c(a0)
	move.w	#3,$1e(a0)
	clr.w	$20(a0)
	move.w	#$5b,$18(a0)
	jsr	callaes
	moveq	#2,d1
	bsr	wind_update
	lea	aespb(pc),a0
	move.w	$432(a0),d1
	move.w	$430(a0),d0
	rts



aespb:	dc.l	contrl,global,intin,intout,ptsin,ptsout
contrl: ds.b	$18
intin:	ds.b	$200
ptsin:	ds.b	$200
intout: ds.b	$200
ptsout: ds.b	$200
global: ds.b	$20


desktopen:
	dc.l	0
nametorun:
	dc.l	0
command_form:
	dc.l	0
window_form:
	dc.l	0
window_handle:
	dc.w	-1
kanejg†uttillGEM:
	dc.w	0
windupdate:
	dc.w	0
winhandle:
	dc.w	0
messbuffer:
	ds.w	16
menupointer:
	dc.l	0
quitalert:
	dc.l	0
infopointer:
	dc.l	0
hj„lpshelling:
	dc.l	0
hj„lpmen:
	dc.l	0
hj„lpexec:
	dc.l	0
fx:	dc.w	0
fy:	dc.w	0
fw:	dc.w	0
fh:	dc.w	0
filename:
	dc.b	'OCTALYSE.RSC',0
	even
konstiguppl”sning:
	dc.b	'[1][Strange res.! Octa may krash!][  Cont  | Cancel ]',0
	even
”ver50Hzp†enRGBare:
	dc.b	'[2][Ohh, no! Not 50Hz! Should|I use a timer or set sync|to 50Hz?][  50Hz  | Timer | Abort ]',0
	even
useborderornot:
	dc.b	'[2][Should I remove border?][  Yes  |   No   ]',0
	even
notfoundstring:
	dc.b	'[1][OCTALYSE.RSC not found!|Cannot go to GEM!][   Ok   ]',0
	even
window_text:
	dc.b	' The Octalyser 0.96 ',0
nytext:	dc.b	'0.000.000',0
	even
runpath:dc.b	'A:\*.PRG',0
	ds.b	50
	even
runname:dc.b	0
	ds.b	15
	even
runlabel:
	dc.b	'Execute a Program',0
	even
commandline:
	dc.l	0
env:	dc.l	0

	ds.l	2000
stack:	dc.l	0
oldst:	dc.l	0
application:
	dc.w	0
nonoshell:
	dc.l	0
shellpath:
	dc.l	0
superoldstack:
	dc.l	0

vtab	DS.B 65*256	; Volymtabell
vtabend


numberfont3:
	dc.b	0,$C3,0,$91 ; 0
	dc.b	0,$89,0,$99
	dc.b	0,$C3,0,$FF
	dc.b	0,0,0,0

	dc.b	0,$E7,0,$C7 ; 1
	dc.b	0,$E7,0,$E7
	dc.b	0,$81,0,$FF
	dc.b	0,0,0,0

	dc.b	0,$C3,0,$B9 ; 2
	dc.b	0,$F3,0,$E7
	dc.b	0,$81,0,$FF
	dc.b	0,0,0,0

	dc.b	0,$81,0,$E7 ; 3
	dc.b	0,$F3,0,$B9
	dc.b	0,$C3,0,$FF
	dc.b	0,0,0,0

	dc.b	0,$F3,0,$C3 ; 4
	dc.b	0,$93,0,$81
	dc.b	0,$F3,0,$FF
	dc.b	0,0,0,0

	dc.b	0,$81,0,$9F ; 5
	dc.b	0,$81,0,$F9
	dc.b	0,$83,0,$FF
	dc.b	0,0,0,0

	dc.b	0,$C3,0,$9F ; 6
	dc.b	0,$83,0,$99
	dc.b	0,$C3,0,$FF
	dc.b	0,0,0,0

	dc.b	0,$81,0,$F3 ; 7
	dc.b	0,$E7,0,$CF
	dc.b	0,$CF,0,$FF
	dc.b	0,0,0,0

	dc.b	0,$C3,0,$99 ; 8
	dc.b	0,$C3,0,$99
	dc.b	0,$C3,0,$FF
	dc.b	0,0,0,0

	dc.b	0,$C3,0,$99 ; 9
	dc.b	0,$C1,0,$F9
	dc.b	0,$C7,0,$FF
	dc.b	0,0,0,0

	dc.b	0,$C3,0,$99 ; A
	dc.b	0,$81,0,$99
	dc.b	0,$99,0,$FF
	dc.b	0,0,0,0

	dc.b	0,$83,0,$99 ; B
	dc.b	0,$83,0,$99
	dc.b	0,$83,0,$FF
	dc.b	0,0,0,0

	dc.b	0,$C3,0,$9F ; C
	dc.b	0,$9F,0,$9F
	dc.b	0,$C1,0,$FF
	dc.b	0,0,0,0

	dc.b	0,$83,0,$99 ; D
	dc.b	0,$99,0,$99
	dc.b	0,$87,0,$FF
	dc.b	0,0,0,0

	dc.b	0,$81,0,$9F ; E
	dc.b	0,$83,0,$9F
	dc.b	0,$81,0,$FF
	dc.b	0,0,0,0

	dc.b	0,$81,0,$9F ; F
	dc.b	0,$83,0,$9F
	dc.b	0,$9F,0,$FF
	dc.b	0,0,0,0

numberfont4:
	dc.b	$18,$C3,$38,$91 ; 0
	dc.b	$18,$89,$18,$99
	dc.b	$7E,$C3,0,$FF
	dc.b	0,0,0,0

	dc.b	$18,$E7,$38,$C7 ; 1
	dc.b	$18,$E7,$18,$E7
	dc.b	$7E,$81,0,$FF
	dc.b	0,0,0,0

	dc.b	$18,$C3,$38,$B9 ; 2
	dc.b	$18,$F3,$18,$E7
	dc.b	$7E,$81,0,$FF
	dc.b	0,0,0,0

	dc.b	$18,$81,$38,$E7 ; 3
	dc.b	$18,$F3,$18,$B9
	dc.b	$7E,$C3,0,$FF
	dc.b	0,0,0,0

	dc.b	$18,$F3,$38,$C3 ; 4
	dc.b	$18,$93,$18,$81
	dc.b	$7E,$F3,0,$FF
	dc.b	0,0,0,0

	dc.b	$18,$81,$38,$9F ; 5
	dc.b	$18,$81,$18,$F9
	dc.b	$7E,$83,0,$FF
	dc.b	0,0,0,0

	dc.b	$18,$C3,$38,$9F ; 6
	dc.b	$18,$83,$18,$99
	dc.b	$7E,$C3,0,$FF
	dc.b	0,0,0,0

	dc.b	$18,$81,$38,$F3 ; 7
	dc.b	$18,$E7,$18,$CF
	dc.b	$7E,$CF,0,$FF
	dc.b	0,0,0,0

	dc.b	$18,$C3,$38,$99 ; 8
	dc.b	$18,$C3,$18,$99
	dc.b	$7E,$C3,0,$FF
	dc.b	0,0,0,0

	dc.b	$18,$C3,$38,$99 ; 9
	dc.b	$18,$C1,$18,$F9
	dc.b	$7E,$C7,0,$FF
	dc.b	0,0,0,0

	dc.b	$18,$C3,$38,$99 ; A
	dc.b	$18,$81,$18,$99
	dc.b	$7E,$99,0,$FF
	dc.b	0,0,0,0

	dc.b	$18,$83,$38,$99 ; B
	dc.b	$18,$83,$18,$99
	dc.b	$7E,$83,0,$FF
	dc.b	0,0,0,0

	dc.b	$18,$C3,$38,$9F ; C
	dc.b	$18,$9F,$18,$9F
	dc.b	$7E,$C1,0,$FF
	dc.b	0,0,0,0

	dc.b	$18,$83,$38,$99 ; D
	dc.b	$18,$99,$18,$99
	dc.b	$7E,$87,0,$FF
	dc.b	0,0,0,0

	dc.b	$18,$81,$38,$9F ; E
	dc.b	$18,$83,$18,$9F
	dc.b	$7E,$81,0,$FF
	dc.b	0,0,0,0

	dc.b	$18,$81,$38,$9F ; F
	dc.b	$18,$83,$18,$9F
	dc.b	$7E,$9F,0,$FF
	dc.b	0,0,0,0


tonisar:
	dc.b	$00
	dc.b	$00
	dc.b	$7E
	dc.b	$00
	dc.b	$00
	dc.b	$00

	dc.b	$3C
	dc.b	$60
	dc.b	$60
	dc.b	$60
	dc.b	$3C
	dc.b	$00

	dc.b	$3C
	dc.b	$60
	dc.b	$60
	dc.b	$60
	dc.b	$3C
	dc.b	$00

	dc.b	$7C
	dc.b	$66
	dc.b	$66
	dc.b	$66
	dc.b	$78
	dc.b	$00

	dc.b	$7C
	dc.b	$66
	dc.b	$66
	dc.b	$66
	dc.b	$78
	dc.b	$00

	dc.b	$7E
	dc.b	$60
	dc.b	$7C
	dc.b	$60
	dc.b	$7E
	dc.b	$00

	dc.b	$7E
	dc.b	$60
	dc.b	$7C
	dc.b	$60
	dc.b	$60
	dc.b	$00

	dc.b	$7E
	dc.b	$60
	dc.b	$7C
	dc.b	$60
	dc.b	$60
	dc.b	$00

	dc.b	$3E
	dc.b	$60
	dc.b	$6E
	dc.b	$66
	dc.b	$3E
	dc.b	$00

	dc.b	$3E
	dc.b	$60
	dc.b	$6E
	dc.b	$66
	dc.b	$3E
	dc.b	$00

	dc.b	$3C
	dc.b	$66
	dc.b	$66
	dc.b	$7E
	dc.b	$66
	dc.b	$00

	dc.b	$3C
	dc.b	$66
	dc.b	$66
	dc.b	$7E
	dc.b	$66
	dc.b	$00

	dc.b	$7C
	dc.b	$66
	dc.b	$7C
	dc.b	$66
	dc.b	$7C
	dc.b	$00
					; Ok, andra oktaven kommer h„r ...
	dc.b	$3C
	dc.b	$60
	dc.b	$60
	dc.b	$60
	dc.b	$3C
	dc.b	$00

	dc.b	$3C
	dc.b	$60
	dc.b	$60
	dc.b	$60
	dc.b	$3C
	dc.b	$00

	dc.b	$7C
	dc.b	$66
	dc.b	$66
	dc.b	$66
	dc.b	$78
	dc.b	$00

	dc.b	$7C
	dc.b	$66
	dc.b	$66
	dc.b	$66
	dc.b	$78
	dc.b	$00

	dc.b	$7E
	dc.b	$60
	dc.b	$7C
	dc.b	$60
	dc.b	$7E
	dc.b	$00

	dc.b	$7E
	dc.b	$60
	dc.b	$7C
	dc.b	$60
	dc.b	$60
	dc.b	$00

	dc.b	$7E
	dc.b	$60
	dc.b	$7C
	dc.b	$60
	dc.b	$60
	dc.b	$00

	dc.b	$3E
	dc.b	$60
	dc.b	$6E
	dc.b	$66
	dc.b	$3E
	dc.b	$00

	dc.b	$3E
	dc.b	$60
	dc.b	$6E
	dc.b	$66
	dc.b	$3E
	dc.b	$00

	dc.b	$3C
	dc.b	$66
	dc.b	$66
	dc.b	$7E
	dc.b	$66
	dc.b	$00

	dc.b	$3C
	dc.b	$66
	dc.b	$66
	dc.b	$7E
	dc.b	$66
	dc.b	$00

	dc.b	$7C
	dc.b	$66
	dc.b	$7C
	dc.b	$66
	dc.b	$7C
	dc.b	$00
				; H„r kommer trejde oktaven

	dc.b	$3C
	dc.b	$60
	dc.b	$60
	dc.b	$60
	dc.b	$3C
	dc.b	$00

	dc.b	$3C
	dc.b	$60
	dc.b	$60
	dc.b	$60
	dc.b	$3C
	dc.b	$00

	dc.b	$7C
	dc.b	$66
	dc.b	$66
	dc.b	$66
	dc.b	$78
	dc.b	$00

	dc.b	$7C
	dc.b	$66
	dc.b	$66
	dc.b	$66
	dc.b	$78
	dc.b	$00

	dc.b	$7E
	dc.b	$60
	dc.b	$7C
	dc.b	$60
	dc.b	$7E
	dc.b	$00

	dc.b	$7E
	dc.b	$60
	dc.b	$7C
	dc.b	$60
	dc.b	$60
	dc.b	$00

	dc.b	$7E
	dc.b	$60
	dc.b	$7C
	dc.b	$60
	dc.b	$60
	dc.b	$00

	dc.b	$3E
	dc.b	$60
	dc.b	$6E
	dc.b	$66
	dc.b	$3E
	dc.b	$00

	dc.b	$3E
	dc.b	$60
	dc.b	$6E
	dc.b	$66
	dc.b	$3E
	dc.b	$00

	dc.b	$3C
	dc.b	$66
	dc.b	$66
	dc.b	$7E
	dc.b	$66
	dc.b	$00

	dc.b	$3C
	dc.b	$66
	dc.b	$66
	dc.b	$7E
	dc.b	$66
	dc.b	$00

	dc.b	$7C
	dc.b	$66
	dc.b	$7C
	dc.b	$66
	dc.b	$7C
	dc.b	$00


oktasar:
	dc.b	$00,$00
	dc.b	$00,$00
	dc.b	$7E,$7E
	dc.b	$00,$00
	dc.b	$00,$00
	dc.b	$00,$00

	dc.b	$00,$18
	dc.b	$00,$38
	dc.b	$7E,$18
	dc.b	$00,$18
	dc.b	$00,$7E
	dc.b	$00,$00

	dc.b	$6C,$18
	dc.b	$FE,$38
	dc.b	$6C,$18
	dc.b	$FE,$18
	dc.b	$6C,$7E
	dc.b	$00,$00

	dc.b	$00,$18
	dc.b	$00,$38
	dc.b	$7E,$18
	dc.b	$00,$18
	dc.b	$00,$7E
	dc.b	$00,$00

	dc.b	$6C,$18
	dc.b	$FE,$38
	dc.b	$6C,$18
	dc.b	$FE,$18
	dc.b	$6C,$7E
	dc.b	$00,$00

	dc.b	$00,$18
	dc.b	$00,$38
	dc.b	$7E,$18
	dc.b	$00,$18
	dc.b	$00,$7E
	dc.b	$00,$00

	dc.b	$00,$18
	dc.b	$00,$38
	dc.b	$7E,$18
	dc.b	$00,$18
	dc.b	$00,$7E
	dc.b	$00,$00

	dc.b	$6C,$18
	dc.b	$FE,$38
	dc.b	$6C,$18
	dc.b	$FE,$18
	dc.b	$6C,$7E
	dc.b	$00,$00

	dc.b	$00,$18
	dc.b	$00,$38
	dc.b	$7E,$18
	dc.b	$00,$18
	dc.b	$00,$7E
	dc.b	$00,$00

	dc.b	$6C,$18
	dc.b	$FE,$38
	dc.b	$6C,$18
	dc.b	$FE,$18
	dc.b	$6C,$7E
	dc.b	$00,$00

	dc.b	$00,$18
	dc.b	$00,$38
	dc.b	$7E,$18
	dc.b	$00,$18
	dc.b	$00,$7E
	dc.b	$00,$00

	dc.b	$6C,$18
	dc.b	$FE,$38
	dc.b	$6C,$18
	dc.b	$FE,$18
	dc.b	$6C,$7E
	dc.b	$00,$00

	dc.b	$00,$18
	dc.b	$00,$38
	dc.b	$7E,$18
	dc.b	$00,$18
	dc.b	$00,$7E
	dc.b	$00,$00
					; Ok, andra oktaven kommer h„r ...
	dc.b	$00,$3C
	dc.b	$00,$46
	dc.b	$7E,$0C
	dc.b	$00,$18
	dc.b	$00,$7E
	dc.b	$00,$00

	dc.b	$6C,$3C
	dc.b	$FE,$46
	dc.b	$6C,$0C
	dc.b	$FE,$18
	dc.b	$6C,$7E
	dc.b	$00,$00

	dc.b	$00,$3C
	dc.b	$00,$46
	dc.b	$7E,$0C
	dc.b	$00,$18
	dc.b	$00,$7E
	dc.b	$00,$00

	dc.b	$6C,$3C
	dc.b	$FE,$46
	dc.b	$6C,$0C
	dc.b	$FE,$18
	dc.b	$6C,$7E
	dc.b	$00,$00

	dc.b	$00,$3C
	dc.b	$00,$46
	dc.b	$7E,$0C
	dc.b	$00,$18
	dc.b	$00,$7E
	dc.b	$00,$00

	dc.b	$00,$3C
	dc.b	$00,$46
	dc.b	$7E,$0C
	dc.b	$00,$18
	dc.b	$00,$7E
	dc.b	$00,$00

	dc.b	$6C,$3C
	dc.b	$FE,$46
	dc.b	$6C,$0C
	dc.b	$FE,$18
	dc.b	$6C,$7E
	dc.b	$00,$00

	dc.b	$00,$3C
	dc.b	$00,$46
	dc.b	$7E,$0C
	dc.b	$00,$18
	dc.b	$00,$7E
	dc.b	$00,$00

	dc.b	$6C,$3C
	dc.b	$FE,$46
	dc.b	$6C,$0C
	dc.b	$FE,$18
	dc.b	$6C,$7E
	dc.b	$00,$00

	dc.b	$00,$3C
	dc.b	$00,$46
	dc.b	$7E,$0C
	dc.b	$00,$18
	dc.b	$00,$7E
	dc.b	$00,$00

	dc.b	$6C,$3C
	dc.b	$FE,$46
	dc.b	$6C,$0C
	dc.b	$FE,$18
	dc.b	$6C,$7E
	dc.b	$00,$00

	dc.b	$00,$3C
	dc.b	$00,$46
	dc.b	$7E,$0C
	dc.b	$00,$18
	dc.b	$00,$7E
	dc.b	$00,$00
				; H„r kommer trejde oktaven

	dc.b	$00,$7E
	dc.b	$00,$18
	dc.b	$7E,$0C
	dc.b	$00,$06
	dc.b	$00,$3C
	dc.b	$00,$00

	dc.b	$6C,$7E
	dc.b	$FE,$18
	dc.b	$6C,$0C
	dc.b	$FE,$06
	dc.b	$6C,$3C
	dc.b	$00,$00

	dc.b	$00,$7E
	dc.b	$00,$18
	dc.b	$7E,$0C
	dc.b	$00,$06
	dc.b	$00,$3C
	dc.b	$00,$00

	dc.b	$6C,$7E
	dc.b	$FE,$18
	dc.b	$6C,$0C
	dc.b	$FE,$06
	dc.b	$6C,$3C
	dc.b	$00,$00

	dc.b	$00,$7E
	dc.b	$00,$18
	dc.b	$7E,$0C
	dc.b	$00,$06
	dc.b	$00,$3C
	dc.b	$00,$00

	dc.b	$00,$7E
	dc.b	$00,$18
	dc.b	$7E,$0C
	dc.b	$00,$06
	dc.b	$00,$3C
	dc.b	$00,$00

	dc.b	$6C,$7E
	dc.b	$FE,$18
	dc.b	$6C,$0C
	dc.b	$FE,$06
	dc.b	$6C,$3C
	dc.b	$00,$00

	dc.b	$00,$7E
	dc.b	$00,$18
	dc.b	$7E,$0C
	dc.b	$00,$06
	dc.b	$00,$3C
	dc.b	$00,$00

	dc.b	$6C,$7E
	dc.b	$FE,$18
	dc.b	$6C,$0C
	dc.b	$FE,$06
	dc.b	$6C,$3C
	dc.b	$00,$00

	dc.b	$00,$7E
	dc.b	$00,$18
	dc.b	$7E,$0C
	dc.b	$00,$06
	dc.b	$00,$3C
	dc.b	$00,$00

	dc.b	$6C,$7E
	dc.b	$FE,$18
	dc.b	$6C,$0C
	dc.b	$FE,$06
	dc.b	$6C,$3C
	dc.b	$00,$00

	dc.b	$00,$7E
	dc.b	$00,$18
	dc.b	$7E,$0C
	dc.b	$00,$06
	dc.b	$00,$3C
	dc.b	$00,$00



jamnc1medtomhogsampling:
	dc.b	$00,$00,$00,$00
	dc.b	$00,$00,$00,$00
	dc.b	$7E,$7E,$7E,$00
	dc.b	$00,$00,$00,$00
	dc.b	$00,$00,$00,$00
	dc.b	$00,$00,$00,$00


	dc.b	$3C,$00,$18,$00
	dc.b	$60,$00,$38,$00
	dc.b	$60,$7E,$18,$00
	dc.b	$60,$00,$18,$00
	dc.b	$3C,$00,$7E,$00
	dc.b	$00,$00,$00,$00

	dc.b	$3C,$6C,$18,$00
	dc.b	$60,$FE,$38,$00
	dc.b	$60,$6C,$18,$00
	dc.b	$60,$FE,$18,$00
	dc.b	$3C,$6C,$7E,$00
	dc.b	$00,$00,$00,$00

	dc.b	$7C,$00,$18,$00
	dc.b	$66,$00,$38,$00
	dc.b	$66,$7E,$18,$00
	dc.b	$66,$00,$18,$00
	dc.b	$78,$00,$7E,$00
	dc.b	$00,$00,$00,$00

	dc.b	$7C,$6C,$18,$00
	dc.b	$66,$FE,$38,$00
	dc.b	$66,$6C,$18,$00
	dc.b	$66,$FE,$18,$00
	dc.b	$78,$6C,$7E,$00
	dc.b	$00,$00,$00,$00

	dc.b	$7E,$00,$18,$00
	dc.b	$60,$00,$38,$00
	dc.b	$7C,$7E,$18,$00
	dc.b	$60,$00,$18,$00
	dc.b	$7E,$00,$7E,$00
	dc.b	$00,$00,$00,$00

	dc.b	$7E,$00,$18,$00
	dc.b	$60,$00,$38,$00
	dc.b	$7C,$7E,$18,$00
	dc.b	$60,$00,$18,$00
	dc.b	$60,$00,$7E,$00
	dc.b	$00,$00,$00,$00

	dc.b	$7E,$6C,$18,$00
	dc.b	$60,$FE,$38,$00
	dc.b	$7C,$6C,$18,$00
	dc.b	$60,$FE,$18,$00
	dc.b	$60,$6C,$7E,$00
	dc.b	$00,$00,$00,$00

	dc.b	$3E,$00,$18,$00
	dc.b	$60,$00,$38,$00
	dc.b	$6E,$7E,$18,$00
	dc.b	$66,$00,$18,$00
	dc.b	$3E,$00,$7E,$00
	dc.b	$00,$00,$00,$00

	dc.b	$3E,$6C,$18,$00
	dc.b	$60,$FE,$38,$00
	dc.b	$6E,$6C,$18,$00
	dc.b	$66,$FE,$18,$00
	dc.b	$3E,$6C,$7E,$00
	dc.b	$00,$00,$00,$00

	dc.b	$3C,$00,$18,$00
	dc.b	$66,$00,$38,$00
	dc.b	$66,$7E,$18,$00
	dc.b	$7E,$00,$18,$00
	dc.b	$66,$00,$7E,$00
	dc.b	$00,$00,$00,$00

	dc.b	$3C,$6C,$18,$00
	dc.b	$66,$FE,$38,$00
	dc.b	$66,$6C,$18,$00
	dc.b	$7E,$FE,$18,$00
	dc.b	$66,$6C,$7E,$00
	dc.b	$00,$00,$00,$00

	dc.b	$7C,$00,$18,$00
	dc.b	$66,$00,$38,$00
	dc.b	$7C,$7E,$18,$00
	dc.b	$66,$00,$18,$00
	dc.b	$7C,$00,$7E,$00
	dc.b	$00,$00,$00,$00
					; Ok, andra oktaven kommer h„r ...
	dc.b	$3C,$00,$3C,$00
	dc.b	$60,$00,$46,$00
	dc.b	$60,$7E,$0C,$00
	dc.b	$60,$00,$18,$00
	dc.b	$3C,$00,$7E,$00
	dc.b	$00,$00,$00,$00

	dc.b	$3C,$6C,$3C,$00
	dc.b	$60,$FE,$46,$00
	dc.b	$60,$6C,$0C,$00
	dc.b	$60,$FE,$18,$00
	dc.b	$3C,$6C,$7E,$00
	dc.b	$00,$00,$00,$00

	dc.b	$7C,$00,$3C,$00
	dc.b	$66,$00,$46,$00
	dc.b	$66,$7E,$0C,$00
	dc.b	$66,$00,$18,$00
	dc.b	$78,$00,$7E,$00
	dc.b	$00,$00,$00,$00

	dc.b	$7C,$6C,$3C,$00
	dc.b	$66,$FE,$46,$00
	dc.b	$66,$6C,$0C,$00
	dc.b	$66,$FE,$18,$00
	dc.b	$78,$6C,$7E,$00
	dc.b	$00,$00,$00,$00

	dc.b	$7E,$00,$3C,$00
	dc.b	$60,$00,$46,$00
	dc.b	$7C,$7E,$0C,$00
	dc.b	$60,$00,$18,$00
	dc.b	$7E,$00,$7E,$00
	dc.b	$00,$00,$00,$00

	dc.b	$7E,$00,$3C,$00
	dc.b	$60,$00,$46,$00
	dc.b	$7C,$7E,$0C,$00
	dc.b	$60,$00,$18,$00
	dc.b	$60,$00,$7E,$00
	dc.b	$00,$00,$00,$00

	dc.b	$7E,$6C,$3C,$00
	dc.b	$60,$FE,$46,$00
	dc.b	$7C,$6C,$0C,$00
	dc.b	$60,$FE,$18,$00
	dc.b	$60,$6C,$7E,$00
	dc.b	$00,$00,$00,$00

	dc.b	$3E,$00,$3C,$00
	dc.b	$60,$00,$46,$00
	dc.b	$6E,$7E,$0C,$00
	dc.b	$66,$00,$18,$00
	dc.b	$3E,$00,$7E,$00
	dc.b	$00,$00,$00,$00

	dc.b	$3E,$6C,$3C,$00
	dc.b	$60,$FE,$46,$00
	dc.b	$6E,$6C,$0C,$00
	dc.b	$66,$FE,$18,$00
	dc.b	$3E,$6C,$7E,$00
	dc.b	$00,$00,$00,$00

	dc.b	$3C,$00,$3C,$00
	dc.b	$66,$00,$46,$00
	dc.b	$66,$7E,$0C,$00
	dc.b	$7E,$00,$18,$00
	dc.b	$66,$00,$7E,$00
	dc.b	$00,$00,$00,$00

	dc.b	$3C,$6C,$3C,$00
	dc.b	$66,$FE,$46,$00
	dc.b	$66,$6C,$0C,$00
	dc.b	$7E,$FE,$18,$00
	dc.b	$66,$6C,$7E,$00
	dc.b	$00,$00,$00,$00

	dc.b	$7C,$00,$3C,$00
	dc.b	$66,$00,$46,$00
	dc.b	$7C,$7E,$0C,$00
	dc.b	$66,$00,$18,$00
	dc.b	$7C,$00,$7E,$00
	dc.b	$00,$00,$00,$00
				; H„r kommer trejde oktaven

	dc.b	$3C,$00,$7E,$00
	dc.b	$60,$00,$18,$00
	dc.b	$60,$7E,$0C,$00
	dc.b	$60,$00,$06,$00
	dc.b	$3C,$00,$3C,$00
	dc.b	$00,$00,$00,$00

	dc.b	$3C,$6C,$7E,$00
	dc.b	$60,$FE,$18,$00
	dc.b	$60,$6C,$0C,$00
	dc.b	$60,$FE,$06,$00
	dc.b	$3C,$6C,$3C,$00
	dc.b	$00,$00,$00,$00

	dc.b	$7C,$00,$7E,$00
	dc.b	$66,$00,$18,$00
	dc.b	$66,$7E,$0C,$00
	dc.b	$66,$00,$06,$00
	dc.b	$78,$00,$3C,$00
	dc.b	$00,$00,$00,$00

	dc.b	$7C,$6C,$7E,$00
	dc.b	$66,$FE,$18,$00
	dc.b	$66,$6C,$0C,$00
	dc.b	$66,$FE,$06,$00
	dc.b	$78,$6C,$3C,$00
	dc.b	$00,$00,$00,$00

	dc.b	$7E,$00,$7E,$00
	dc.b	$60,$00,$18,$00
	dc.b	$7C,$7E,$0C,$00
	dc.b	$60,$00,$06,$00
	dc.b	$7E,$00,$3C,$00
	dc.b	$00,$00,$00,$00

	dc.b	$7E,$00,$7E,$00
	dc.b	$60,$00,$18,$00
	dc.b	$7C,$7E,$0C,$00
	dc.b	$60,$00,$06,$00
	dc.b	$60,$00,$3C,$00
	dc.b	$00,$00,$00,$00

	dc.b	$7E,$6C,$7E,$00
	dc.b	$60,$FE,$18,$00
	dc.b	$7C,$6C,$0C,$00
	dc.b	$60,$FE,$06,$00
	dc.b	$60,$6C,$3C,$00
	dc.b	$00,$00,$00,$00

	dc.b	$3E,$00,$7E,$00
	dc.b	$60,$00,$18,$00
	dc.b	$6E,$7E,$0C,$00
	dc.b	$66,$00,$06,$00
	dc.b	$3E,$00,$3C,$00
	dc.b	$00,$00,$00,$00

	dc.b	$3E,$6C,$7E,$00
	dc.b	$60,$FE,$18,$00
	dc.b	$6E,$6C,$0C,$00
	dc.b	$66,$FE,$06,$00
	dc.b	$3E,$6C,$3C,$00
	dc.b	$00,$00,$00,$00

	dc.b	$3C,$00,$7E,$00
	dc.b	$66,$00,$18,$00
	dc.b	$66,$7E,$0C,$00
	dc.b	$7E,$00,$06,$00
	dc.b	$66,$00,$3C,$00
	dc.b	$00,$00,$00,$00

	dc.b	$3C,$6C,$7E,$00
	dc.b	$66,$FE,$18,$00
	dc.b	$66,$6C,$0C,$00
	dc.b	$7E,$FE,$06,$00
	dc.b	$66,$6C,$3C,$00
	dc.b	$00,$00,$00,$00

	dc.b	$7C,$00,$7E,$00
	dc.b	$66,$00,$18,$00
	dc.b	$7C,$7E,$0C,$00
	dc.b	$66,$00,$06,$00
	dc.b	$7C,$00,$3C,$00
	dc.b	$00,$00,$00,$00

jamnc1medenettahogsampling:
	dc.b	$00,$00,$00,$18
	dc.b	$00,$00,$00,$38
	dc.b	$7E,$7E,$7E,$18
	dc.b	$00,$00,$00,$18
	dc.b	$00,$00,$00,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$3C,$00,$18,$18
	dc.b	$60,$00,$38,$38
	dc.b	$60,$7E,$18,$18
	dc.b	$60,$00,$18,$18
	dc.b	$3C,$00,$7E,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$3C,$6C,$18,$18
	dc.b	$60,$FE,$38,$38
	dc.b	$60,$6C,$18,$18
	dc.b	$60,$FE,$18,$18
	dc.b	$3C,$6C,$7E,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$7C,$00,$18,$18
	dc.b	$66,$00,$38,$38
	dc.b	$66,$7E,$18,$18
	dc.b	$66,$00,$18,$18
	dc.b	$78,$00,$7E,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$7C,$6C,$18,$18
	dc.b	$66,$FE,$38,$38
	dc.b	$66,$6C,$18,$18
	dc.b	$66,$FE,$18,$18
	dc.b	$78,$6C,$7E,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$7E,$00,$18,$18
	dc.b	$60,$00,$38,$38
	dc.b	$7C,$7E,$18,$18
	dc.b	$60,$00,$18,$18
	dc.b	$7E,$00,$7E,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$7E,$00,$18,$18
	dc.b	$60,$00,$38,$38
	dc.b	$7C,$7E,$18,$18
	dc.b	$60,$00,$18,$18
	dc.b	$60,$00,$7E,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$7E,$6C,$18,$18
	dc.b	$60,$FE,$38,$38
	dc.b	$7C,$6C,$18,$18
	dc.b	$60,$FE,$18,$18
	dc.b	$60,$6C,$7E,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$3E,$00,$18,$18
	dc.b	$60,$00,$38,$38
	dc.b	$6E,$7E,$18,$18
	dc.b	$66,$00,$18,$18
	dc.b	$3E,$00,$7E,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$3E,$6C,$18,$18
	dc.b	$60,$FE,$38,$38
	dc.b	$6E,$6C,$18,$18
	dc.b	$66,$FE,$18,$18
	dc.b	$3E,$6C,$7E,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$3C,$00,$18,$18
	dc.b	$66,$00,$38,$38
	dc.b	$66,$7E,$18,$18
	dc.b	$7E,$00,$18,$18
	dc.b	$66,$00,$7E,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$3C,$6C,$18,$18
	dc.b	$66,$FE,$38,$38
	dc.b	$66,$6C,$18,$18
	dc.b	$7E,$FE,$18,$18
	dc.b	$66,$6C,$7E,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$7C,$00,$18,$18
	dc.b	$66,$00,$38,$38
	dc.b	$7C,$7E,$18,$18
	dc.b	$66,$00,$18,$18
	dc.b	$7C,$00,$7E,$7E
	dc.b	$00,$00,$00,$00
					; Ok, andra oktaven kommer h„r ...
	dc.b	$3C,$00,$3C,$18
	dc.b	$60,$00,$46,$38
	dc.b	$60,$7E,$0C,$18
	dc.b	$60,$00,$18,$18
	dc.b	$3C,$00,$7E,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$3C,$6C,$3C,$18
	dc.b	$60,$FE,$46,$38
	dc.b	$60,$6C,$0C,$18
	dc.b	$60,$FE,$18,$18
	dc.b	$3C,$6C,$7E,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$7C,$00,$3C,$18
	dc.b	$66,$00,$46,$38
	dc.b	$66,$7E,$0C,$18
	dc.b	$66,$00,$18,$18
	dc.b	$78,$00,$7E,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$7C,$6C,$3C,$18
	dc.b	$66,$FE,$46,$38
	dc.b	$66,$6C,$0C,$18
	dc.b	$66,$FE,$18,$18
	dc.b	$78,$6C,$7E,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$7E,$00,$3C,$18
	dc.b	$60,$00,$46,$38
	dc.b	$7C,$7E,$0C,$18
	dc.b	$60,$00,$18,$18
	dc.b	$7E,$00,$7E,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$7E,$00,$3C,$18
	dc.b	$60,$00,$46,$38
	dc.b	$7C,$7E,$0C,$18
	dc.b	$60,$00,$18,$18
	dc.b	$60,$00,$7E,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$7E,$6C,$3C,$18
	dc.b	$60,$FE,$46,$38
	dc.b	$7C,$6C,$0C,$18
	dc.b	$60,$FE,$18,$18
	dc.b	$60,$6C,$7E,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$3E,$00,$3C,$18
	dc.b	$60,$00,$46,$38
	dc.b	$6E,$7E,$0C,$18
	dc.b	$66,$00,$18,$18
	dc.b	$3E,$00,$7E,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$3E,$6C,$3C,$18
	dc.b	$60,$FE,$46,$38
	dc.b	$6E,$6C,$0C,$18
	dc.b	$66,$FE,$18,$18
	dc.b	$3E,$6C,$7E,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$3C,$00,$3C,$18
	dc.b	$66,$00,$46,$38
	dc.b	$66,$7E,$0C,$18
	dc.b	$7E,$00,$18,$18
	dc.b	$66,$00,$7E,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$3C,$6C,$3C,$18
	dc.b	$66,$FE,$46,$38
	dc.b	$66,$6C,$0C,$18
	dc.b	$7E,$FE,$18,$18
	dc.b	$66,$6C,$7E,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$7C,$00,$3C,$18
	dc.b	$66,$00,$46,$38
	dc.b	$7C,$7E,$0C,$18
	dc.b	$66,$00,$18,$18
	dc.b	$7C,$00,$7E,$7E
	dc.b	$00,$00,$00,$00
				; H„r kommer trejde oktaven

	dc.b	$3C,$00,$7E,$18
	dc.b	$60,$00,$18,$38
	dc.b	$60,$7E,$0C,$18
	dc.b	$60,$00,$06,$18
	dc.b	$3C,$00,$3C,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$3C,$6C,$7E,$18
	dc.b	$60,$FE,$18,$38
	dc.b	$60,$6C,$0C,$18
	dc.b	$60,$FE,$06,$18
	dc.b	$3C,$6C,$3C,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$7C,$00,$7E,$18
	dc.b	$66,$00,$18,$38
	dc.b	$66,$7E,$0C,$18
	dc.b	$66,$00,$06,$18
	dc.b	$78,$00,$3C,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$7C,$6C,$7E,$18
	dc.b	$66,$FE,$18,$38
	dc.b	$66,$6C,$0C,$18
	dc.b	$66,$FE,$06,$18
	dc.b	$78,$6C,$3C,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$7E,$00,$7E,$18
	dc.b	$60,$00,$18,$38
	dc.b	$7C,$7E,$0C,$18
	dc.b	$60,$00,$06,$18
	dc.b	$7E,$00,$3C,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$7E,$00,$7E,$18
	dc.b	$60,$00,$18,$38
	dc.b	$7C,$7E,$0C,$18
	dc.b	$60,$00,$06,$18
	dc.b	$60,$00,$3C,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$7E,$6C,$7E,$18
	dc.b	$60,$FE,$18,$38
	dc.b	$7C,$6C,$0C,$18
	dc.b	$60,$FE,$06,$18
	dc.b	$60,$6C,$3C,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$3E,$00,$7E,$18
	dc.b	$60,$00,$18,$38
	dc.b	$6E,$7E,$0C,$18
	dc.b	$66,$00,$06,$18
	dc.b	$3E,$00,$3C,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$3E,$6C,$7E,$18
	dc.b	$60,$FE,$18,$38
	dc.b	$6E,$6C,$0C,$18
	dc.b	$66,$FE,$06,$18
	dc.b	$3E,$6C,$3C,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$3C,$00,$7E,$18
	dc.b	$66,$00,$18,$38
	dc.b	$66,$7E,$0C,$18
	dc.b	$7E,$00,$06,$18
	dc.b	$66,$00,$3C,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$3C,$6C,$7E,$18
	dc.b	$66,$FE,$18,$38
	dc.b	$66,$6C,$0C,$18
	dc.b	$7E,$FE,$06,$18
	dc.b	$66,$6C,$3C,$7E
	dc.b	$00,$00,$00,$00

	dc.b	$7C,$00,$7E,$18
	dc.b	$66,$00,$18,$38
	dc.b	$7C,$7E,$0C,$18
	dc.b	$66,$00,$06,$18
	dc.b	$7C,$00,$3C,$7E
	dc.b	$00,$00,$00,$00


cursorx:
	dc.l	0
oldcursorpek:
	dc.l	0
cursortabell:
	dc.l	0,9,16,17,24,25,33,48,49,56,57,64,72,81,88,89,96,97
	dc.l	105,120,121,128,129,136

bildminne:
	dc.l	0
patterns:
	dc.l	0		; Pekaren till alla patterns
lastsongpatt:
	dc.w	0
startkanal:
	dc.w	0000
lastpos:dc.w	0
taltabell2:
	dc.l	numberfont2,numberfont2+6,numberfont2+12,numberfont2+18
	dc.l	numberfont2+24,numberfont2+30,numberfont2+36,numberfont2+42
	dc.l	numberfont2+48,numberfont2+54,numberfont2+60,numberfont2+66
	dc.l	numberfont2+72,numberfont2+78,numberfont2+84,numberfont2+90
tolkedbuffer:
	ds.l	256


skrivutenhelskarmspattern:
	neg.w	dowhich
	lea	tabelldata2(pc),a2
	tst.w	patternupdate
	bmi.s	endastenrad	; 1 rad (den tjocka)
	bgt.s	trerader	; 3 rader
	tst.w	dowhich		; Hela patternet
	bgt	fixaoverdelenavpatternet	; Žr den > 0 uppdatera ”verdelen av patternet
	bmi	fixaunderdelenavpatternet	; Žr den < 0 uppdatera nederdelen av patternet
trerader:
	tst.w	dowhich		; 3 rader
	bgt.s	fixaoverdelenavpatternet3	; Žr den > 0 uppdatera ”verdelen av patternet
	bmi	fixaunderdelenavpatternet3	; Žr den < 0 uppdatera nederdelen av patternet
endastenrad:			; 1 rad
	move.l	patterns(pc),a4
	moveq	#0,d0
	move.w	lastsongpatt(pc),d0
	asl.l	#8,d0
	asl.l	#3,d0
	add.l	d0,a4
	moveq	#0,d1
	move.w	startkanal(pc),d1
	subq.w	#1,d1
	add.w	d1,d1
	add.w	d1,d1
	add.l	d1,a4
	moveq	#0,d0
	move.w	lastpos(pc),d0
	add.l	d0,a4
	lea	taltabell2(pc),a5	; Pekare till taltabell
	move.l	bildminne(pc),a6
	lea	168*110+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	move.w	lastpos(pc),d7		; Vilken patternpos ligger vi p†
	lsr.w	#5,d7
	lea	tolkedbuffer(pc),a3

	move.l	bildminne(pc),a6
	tst.w	dowhich
	bmi.s	skrivenradlagre
	lea	168*165+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	bra.s	radenovanfor
skrivenradlagre:
	lea	168*166+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
radenovanfor:
	bsr	skrivutenpatternradextratjockmedfusk
	bsr	skrivutcursornmedfusk
	rts

fixaoverdelenavpatternet3:
	move.l	patterns(pc),a4
	moveq	#0,d0
	move.w	lastsongpatt(pc),d0
	asl.l	#8,d0
	asl.l	#3,d0
	add.l	d0,a4
	moveq	#0,d1
	move.w	startkanal(pc),d1
	subq.w	#1,d1
	add.w	d1,d1
	add.w	d1,d1
	add.l	d1,a4
	moveq	#0,d0
	move.w	lastpos(pc),d0
	sub.l	#32*4,d0
	add.l	d0,a4
	lea	taltabell2(pc),a5	; Pekare till taltabell
	move.l	bildminne(pc),a6
	lea	168*134+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	move.w	lastpos(pc),d7		; Vilken patternpos ligger vi p†
	lsr.w	#5,d7
	subq.w	#4,d7
	lea	tolkedbuffer(pc),a3
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	lea	168*140+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	lea	168*146+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	lea	168*152+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	tst.w	trashupdate	; patterndatan
	bmi.s	trashen„rp†”verarbetaej1

	move.l	bildminne(pc),a6
	lea	168*165+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternradextratjock
	lea	32(a4),a4

trashen„rp†”verarbetaej1:
	bsr	skrivutcursorn
	rts

fixaunderdelenavpatternet3:
	move.l	patterns(pc),a4	; Žr den = 0 uppdatera allt p† en g†ng
	moveq	#0,d0
	move.w	lastsongpatt(pc),d0
	asl.l	#8,d0
	asl.l	#3,d0
	add.l	d0,a4
	moveq	#0,d1
	move.w	startkanal(pc),d1
	subq.w	#1,d1
	add.w	d1,d1
	add.w	d1,d1
	add.l	d1,a4
	moveq	#0,d0
	move.w	lastpos(pc),d0
	add.l	d0,a4
	lea	taltabell2(pc),a5	; Pekare till taltabell
	move.w	lastpos(pc),d7		; Vilken patternpos ligger vi p†
	lsr.w	#5,d7
	subq.w	#1,d7
	lea	tolkedbuffer(pc),a3

	move.l	bildminne(pc),a6
	lea	168*165+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternradextratjock
	lea	32(a4),a4

	bsr	skrivutcursorn

	move.l	bildminne(pc),a6
	lea	168*183+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	lea	168*189+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	add.l	#168*195+3+8,a6		; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	add.l	#168*201+3+8,a6		; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	rts

skrivutcursornmedfusk:
	move.l	bildminne(pc),a6
	lea	168*164+16+2+8(a6),a5
	tst.w	dowhich
	bmi.s	skrivenradlagre1
	lea	168*164+16+2+8(a6),a6	; Pekare till vart raden skall skrivas ut
	bra.s	radenovanfor1
skrivenradlagre1:
	lea	168*165+16+2+8(a6),a6	; Pekare till vart raden skall skrivas ut
radenovanfor1:
	moveq	#0,d0
	lea	cursortabell(pc),a0
	move.w	cursorx(pc),d0		; Placera cursorn r„tt
	add.w	d0,d0
	add.w	d0,d0
	add.l	0(a0,d0.w),a6
	add.l	0(a0,d0.w),a5
	move.l	a5,oldcursorpek
	move.b	#$ff,(a5)
	tst.w	trashupdate
	bmi.s	ejenhelcursor1
	not.b	168(a6)
	not.b	504(a6)
	not.b	840(a6)
	not.b	1176(a6)
	not.b	1512(a6)
ejenhelcursor1:
	move.b	#$ff,1848(a5)
	rts

skrivutenpatternradextratjockmedfusk
	move.w	d7,d0
	bmi	negativrensadenhardelenextratjock
	cmp.w	#$3f,d0
	bgt	negativrensadenhardelenextratjock
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a3,d0.w),a0
	move.b	(a0)+,(a6)
	move.b	(a0)+,7(a6)
	move.b	(a0)+,336(a6)
	move.b	(a0)+,343(a6)
	move.b	(a0)+,672(a6)
	move.b	(a0)+,679(a6)
	move.b	(a0)+,1008(a6)
	move.b	(a0)+,1015(a6)
	move.b	(a0)+,1344(a6)
	move.b	(a0)+,1351(a6)

	move.w	(a4),d1
	move.w	d1,d2
	and.w	#%0000001111111100,d1
	and.w	#%1111000000000000,d2
	bne.s	ingen1attskrivaut1
	lea.l	jamnc1medtomhogsampling(pc),a0
	bra.s	skriuten1a1
ingen1attskrivaut1:
	lea.l	jamnc1medenettahogsampling(pc),a0
skriuten1a1:
	add.l	0(a2,d1.w),a0
	move.w	(a0)+,15(a6)
	move.w	(a0)+,15+8(a6)
	move.w	(a0)+,15+336(a6)			; R„tt ton
	move.w	(a0)+,15+344(a6)
	move.w	(a0)+,15+672(a6)
	move.w	(a0)+,15+680(a6)
	move.w	(a0)+,15+1008(a6)
	move.w	(a0)+,15+1016(a6)
	move.w	(a0)+,15+1344(a6)
	move.w	(a0)+,15+1352(a6)

	moveq	#0,d1
	move.b	2(a4),d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a3,d1.w),a0
	move.w	(a0)+,31(a6)		; L†gsampling + kommando
	move.w	(a0)+,31+336(a6)
	move.w	(a0)+,31+672(a6)
	move.w	(a0)+,31+1008(a6)
	move.w	(a0)+,31+1344(a6)
	moveq	#0,d1
	move.b	3(a4),d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a3,d1.w),a0
	move.w	(a0)+,39(a6)		; Kommandodata
	move.w	(a0)+,39+336(a6)
	move.w	(a0)+,39+672(a6)
	move.w	(a0)+,39+1008(a6)
	move.w	(a0)+,39+1344(a6)

	move.w	4(a4),d1
	and.w	#%0000001111111100,d1
	lea	pekaretillvilkenton(pc),a1
	move.l	0(a1,d1.w),a0
	move.b	(a0)+,48(a6)		; Ton
	move.b	(a0)+,48+336(a6)
	move.b	(a0)+,48+672(a6)
	move.b	(a0)+,48+1008(a6)
	move.b	(a0)+,48+1344(a6)
	lea	1024*4(a1),a1
	move.l	0(a1,d1.w),a0
	move.w	(a0)+,55(a6)		; Oktav
	move.w	(a0)+,55+336(a6)
	move.w	(a0)+,55+672(a6)
	move.w	(a0)+,55+1008(a6)
	move.w	(a0)+,55+1344(a6)

	move.w	4(a4),d2
	and.w	#%1111000000000000,d2
	bne.s	ingen2attskrivaut2
	lea	numberfont3(pc),a0
	bra.s	skriuten2a2
ingen2attskrivaut2:
	lea	numberfont4(pc),a0
skriuten2a2:
	moveq	#0,d0
	move.b	6(a4),d0
	and.b	#$f0,d0
	add.w	d0,a0
	move.w	(a0)+,63(a6)		; Sampling
	move.w	(a0)+,63+336(a6)
	move.w	(a0)+,63+672(a6)
	move.w	(a0)+,63+1008(a6)
	move.w	(a0)+,63+1344(a6)

	move.w	6(a4),d1
	and.w	#%111111110000,d1
	lsr.w	#2,d1
	move.l	0(a3,d1.w),a0
	move.w	(a0)+,71(a6)		; Kommando +  h”g kommandodata
	move.w	(a0)+,71+336(a6)
	move.w	(a0)+,71+672(a6)
	move.w	(a0)+,71+1008(a6)
	move.w	(a0)+,71+1344(a6)

	move.w	6(a4),d1
	and.w	#%1111,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a5,d1.w),a0
	move.b	(a0)+,79(a6)		; L†g kommandodata
	move.b	(a0)+,79+336(a6)
	move.b	(a0)+,79+672(a6)
	move.b	(a0)+,79+1008(a6)
	move.b	(a0)+,79+1344(a6)

	move.w	8(a4),d1
	move.w	d1,d2
	and.w	#%0000001111111100,d1
	and.w	#%1111000000000000,d2
	bne.s	ingen3attskrivaut3
	lea.l	jamnc1medtomhogsampling(pc),a0
	bra.s	skriuten3a3
ingen3attskrivaut3:
	lea.l	jamnc1medenettahogsampling(pc),a0
skriuten3a3:
	add.l	0(a2,d1.w),a0
	move.w	(a0)+,87(a6)
	move.w	(a0)+,87+8(a6)
	move.w	(a0)+,87+336(a6)			; R„tt ton
	move.w	(a0)+,87+344(a6)
	move.w	(a0)+,87+672(a6)
	move.w	(a0)+,87+680(a6)
	move.w	(a0)+,87+1008(a6)
	move.w	(a0)+,87+1016(a6)
	move.w	(a0)+,87+1344(a6)
	move.w	(a0)+,87+1352(a6)

	moveq	#0,d1
	move.b	10(a4),d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a3,d1.w),a0
	move.w	(a0)+,103(a6)		; L†gsampling + kommando
	move.w	(a0)+,103+336(a6)
	move.w	(a0)+,103+672(a6)
	move.w	(a0)+,103+1008(a6)
	move.w	(a0)+,103+1344(a6)
	moveq	#0,d1
	move.b	11(a4),d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a3,d1.w),a0
	move.w	(a0)+,111(a6)		; Kommandodata
	move.w	(a0)+,111+336(a6)
	move.w	(a0)+,111+672(a6)
	move.w	(a0)+,111+1008(a6)
	move.w	(a0)+,111+1344(a6)

	move.w	12(a4),d1
	and.w	#%0000001111111100,d1
	lea	pekaretillvilkenton(pc),a1
	move.l	0(a1,d1.w),a0
	move.b	(a0)+,120(a6)		; Ton
	move.b	(a0)+,120+336(a6)
	move.b	(a0)+,120+672(a6)
	move.b	(a0)+,120+1008(a6)
	move.b	(a0)+,120+1344(a6)
	lea	1024*4(a1),a1
	move.l	0(a1,d1.w),a0
	move.w	(a0)+,127(a6)		; Oktav
	move.w	(a0)+,127+336(a6)
	move.w	(a0)+,127+672(a6)
	move.w	(a0)+,127+1008(a6)
	move.w	(a0)+,127+1344(a6)


	move.w	12(a4),d2
	and.w	#%1111000000000000,d2
	bne.s	ingen4attskrivaut4
	lea	numberfont3(pc),a0
	bra.s	skriuten4a4
ingen4attskrivaut4:
	lea	numberfont4(pc),a0
skriuten4a4:
	moveq	#0,d0
	move.b	14(a4),d0
	and.b	#$f0,d0
	add.l	d0,a0
	move.w	(a0)+,135(a6)		; Sampling
	move.w	(a0)+,135+336(a6)
	move.w	(a0)+,135+672(a6)
	move.w	(a0)+,135+1008(a6)
	move.w	(a0)+,135+1344(a6)

	move.w	14(a4),d1
	and.w	#%111111110000,d1
	lsr.w	#2,d1
	move.l	0(a3,d1.w),a0
	move.w	(a0)+,143(a6)		; Kommando +  h”g kommandodata
	move.w	(a0)+,143+336(a6)
	move.w	(a0)+,143+672(a6)
	move.w	(a0)+,143+1008(a6)
	move.w	(a0)+,143+1344(a6)

	move.w	14(a4),d1
	and.w	#%1111,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a5,d1.w),a0
	move.b	(a0)+,151(a6)		; L†g kommandodata
	move.b	(a0)+,151+336(a6)
	move.b	(a0)+,151+672(a6)
	move.b	(a0)+,151+1008(a6)
	move.b	(a0)+,151+1344(a6)

	rts

negativrensadenhardelenextratjock:	; Rensa en del av raden
	moveq	#0,d2
	move.b	d2,(a6)
	move.b	d2,336(a6)
	move.b	d2,672(a6)
	move.b	d2,1008(a6)
	move.b	d2,1344(a6)
	addq.l	#7,a6
	move.b	d2,(a6)
	move.b	d2,336(a6)
	move.b	d2,672(a6)
	move.b	d2,1008(a6)
	move.b	d2,1344(a6)
	addq.l	#8,a6
	move.w	#4-1,d0
rensaforstakanalenet:
	move.b	d2,(a6)
	move.b	d2,336(a6)
	move.b	d2,672(a6)
	move.b	d2,1008(a6)
	move.b	d2,1344(a6)
	addq.l	#1,a6
	move.b	d2,(a6)
	move.b	d2,336(a6)
	move.b	d2,672(a6)
	move.b	d2,1008(a6)
	move.b	d2,1344(a6)
	addq.l	#7,a6
	dbra	d0,rensaforstakanalenet
	addq.l	#1,a6
	move.w	#4-1,d0
rensaandrakanalenet:
	move.b	d2,(a6)
	move.b	d2,336(a6)
	move.b	d2,672(a6)
	move.b	d2,1008(a6)
	move.b	d2,1344(a6)
	addq.l	#7,a6
	move.b	d2,(a6)
	move.b	d2,336(a6)
	move.b	d2,672(a6)
	move.b	d2,1008(a6)
	move.b	d2,1344(a6)
	addq.l	#1,a6
	dbra	d0,rensaandrakanalenet
	addq.l	#7,a6

	move.w	#4-1,d0
rensatredjekanalenet:
	move.b	d2,(a6)
	move.b	d2,336(a6)
	move.b	d2,672(a6)
	move.b	d2,1008(a6)
	move.b	d2,1344(a6)
	addq.l	#1,a6
	move.b	d2,(a6)
	move.b	d2,336(a6)
	move.b	d2,672(a6)
	move.b	d2,1008(a6)
	move.b	d2,1344(a6)
	addq.l	#7,a6
	dbra	d0,rensatredjekanalenet
	addq.l	#1,a6
	move.w	#4-1,d0
rensafjardekanalenet:
	move.b	d2,(a6)
	move.b	d2,336(a6)
	move.b	d2,672(a6)
	move.b	d2,1008(a6)
	move.b	d2,1344(a6)
	addq.l	#7,a6
	move.b	d2,(a6)
	move.b	d2,336(a6)
	move.b	d2,672(a6)
	move.b	d2,1008(a6)
	move.b	d2,1344(a6)
	addq.l	#1,a6
	dbra	d0,rensafjardekanalenet
	rts


fixaoverdelenavpatternet:
	move.l	patterns,a4
	moveq	#0,d0
	move.w	lastsongpatt,d0
	asl.l	#8,d0
	asl.l	#3,d0
	add.l	d0,a4
	moveq	#0,d1
	move.w	startkanal,d1
	subq.w	#1,d1
	add.w	d1,d1
	add.w	d1,d1
	add.l	d1,a4
	moveq	#0,d0
	move.w	lastpos,d0
	sub.l	#32*8,d0
	add.l	d0,a4
	lea	taltabell2(pc),a5	; Pekare till taltabell
	move.l	bildminne(pc),a6
	lea	168*110+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	move.w	lastpos,d7		; Vilken patternpos ligger vi p†
	lsr.w	#5,d7
	subq.w	#8,d7
	lea	tolkedbuffer(pc),a3
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	lea	168*116+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	lea	168*122+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	lea	168*128+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	lea	168*134+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	lea	168*140+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	lea	168*146+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	lea	168*152+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	tst.w	trashupdate	; patterndatan
	bmi.s	trashen„rp†”verarbetaej2

	move.l	bildminne(pc),a6
	lea	168*165+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternradextratjock
	lea	32(a4),a4

trashen„rp†”verarbetaej2:
	bsr	skrivutcursorn
	rts

fixaunderdelenavpatternet:
	move.l	patterns,a4	; Žr den = 0 uppdatera allt p† en g†ng
	moveq	#0,d0
	move.w	lastsongpatt,d0
	asl.l	#8,d0
	asl.l	#3,d0
	add.l	d0,a4
	moveq	#0,d1
	move.w	startkanal,d1
	subq.w	#1,d1
	add.w	d1,d1
	add.w	d1,d1
	add.l	d1,a4
	moveq	#0,d0
	move.w	lastpos,d0
	add.l	d0,a4
	lea	taltabell2(pc),a5	; Pekare till taltabell
	move.w	lastpos,d7		; Vilken patternpos ligger vi p†
	lsr.w	#5,d7
	subq.w	#1,d7
	lea	tolkedbuffer(pc),a3

	move.l	bildminne(pc),a6
	lea	168*165+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternradextratjock
	lea	32(a4),a4

	bsr	skrivutcursorn

	move.l	bildminne(pc),a6
	lea	168*183+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	lea	168*189+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	add.l	#168*195+3+8,a6		; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	add.l	#168*201+3+8,a6		; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	add.l	#168*207+3+8,a6		; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	add.l	#168*213+3+8,a6		; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	add.l	#168*219+3+8,a6		; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr.s	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	add.l	#168*225+3+8,a6		; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr.s	skrivutenpatternrad

	rts


skrivutcursorn:
	move.l	bildminne(pc),a6
	lea	168*164+16+2+8(a6),a6	; Pekare till vart cursorn skall skrivas ut
	moveq	#0,d0
	lea	cursortabell(pc),a0
	move.w	cursorx(pc),d0		; Placera cursorn r„tt
	add.w	d0,d0
	add.w	d0,d0
	add.l	0(a0,d0.w),a6
	move.l	a6,oldcursorpek
	move.b	#$ff,(a6)
	tst.w	trashupdate
	bmi.s	ejenhelcursor2
	not.b	168(a6)
	not.b	336(a6)
	not.b	504(a6)
	not.b	672(a6)
	not.b	840(a6)
	not.b	1008(a6)
	not.b	1176(a6)
	not.b	1344(a6)
	not.b	1512(a6)
	not.b	1680(a6)
ejenhelcursor2:
	move.b	#$ff,1848(a6)
	rts

extradata:
	dc.l	0

skrivutenpatternrad:
	move.w	d7,d0
	bmi	negativrensadenhardelen
	cmp.w	#$3f,d0
	bgt	negativrensadenhardelen
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a3,d0.w),a0
	move.b	(a0)+,(a6)
	move.b	(a0)+,7(a6)			; Vilket steg?
	move.b	(a0)+,168(a6)
	move.b	(a0)+,175(a6)
	move.b	(a0)+,336(a6)
	move.b	(a0)+,343(a6)
	move.b	(a0)+,504(a6)
	move.b	(a0)+,511(a6)
	move.b	(a0)+,672(a6)
	move.b	(a0)+,679(a6)

	move.w	(a4),d1
	move.w	d1,d2
	and.w	#%0000001111111100,d1
	and.w	#%1111000000000000,d2
	bne.s	ingen1attskrivaut
	lea.l	jamnc1medtomhogsampling(pc),a0
	bra.s	skriuten1a
ingen1attskrivaut:
	lea.l	jamnc1medenettahogsampling(pc),a0
skriuten1a:
	add.l	0(a2,d1.w),a0
	move.w	(a0)+,15(a6)
	move.w	(a0)+,15+8(a6)
	move.w	(a0)+,8+15+160(a6)
	move.w	(a0)+,8+15+168(a6)
	move.w	(a0)+,16+15+320(a6)		; R„tt ton
	move.w	(a0)+,16+15+328(a6)
	move.w	(a0)+,24+15+480(a6)
	move.w	(a0)+,24+15+488(a6)
	move.w	(a0)+,32+15+640(a6)
	move.w	(a0)+,32+15+648(a6)

	moveq	#0,d1
	move.b	2(a4),d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a3,d1.w),a0
	move.w	(a0)+,31(a6)		; L†gsampling + kommando
	move.w	(a0)+,31+168(a6)
	move.w	(a0)+,31+336(a6)
	move.w	(a0)+,31+504(a6)
	move.w	(a0)+,31+672(a6)
	moveq	#0,d1
	move.b	3(a4),d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a3,d1.w),a0
	move.w	(a0)+,39(a6)		; Kommandodata
	move.w	(a0)+,39+168(a6)
	move.w	(a0)+,39+336(a6)
	move.w	(a0)+,39+504(a6)
	move.w	(a0)+,39+672(a6)

	move.w	4(a4),d1
	and.w	#%0000001111111100,d1
	lea	pekaretillvilkenton(pc),a1
	move.l	0(a1,d1.w),a0
	move.b	(a0)+,48(a6)		; Ton
	move.b	(a0)+,48+168(a6)
	move.b	(a0)+,48+336(a6)
	move.b	(a0)+,48+504(a6)
	move.b	(a0)+,48+672(a6)
	lea	1024*4(a1),a1
	move.l	0(a1,d1.w),a0
	move.w	(a0)+,55(a6)		; Oktav
	move.w	(a0)+,55+168(a6)
	move.w	(a0)+,55+336(a6)
	move.w	(a0)+,55+504(a6)
	move.w	(a0)+,55+672(a6)

	move.w	4(a4),d2
	and.w	#%1111000000000000,d2
	bne.s	ingen2attskrivaut
	lea	numberfont3(pc),a0
	bra.s	skriuten2a
ingen2attskrivaut:
	lea	numberfont4(pc),a0
skriuten2a:
	moveq	#0,d0
	move.b	6(a4),d0
	and.b	#$f0,d0
	add.l	d0,a0
	move.w	(a0)+,63(a6)		; Sampling
	move.w	(a0)+,63+168(a6)
	move.w	(a0)+,63+336(a6)
	move.w	(a0)+,63+504(a6)
	move.w	(a0)+,63+672(a6)

	move.w	6(a4),d1
	and.w	#%111111110000,d1
	lsr.w	#2,d1
	move.l	0(a3,d1.w),a0
	move.w	(a0)+,71(a6)		; Kommando +  h”g kommandodata
	move.w	(a0)+,71+168(a6)
	move.w	(a0)+,71+336(a6)
	move.w	(a0)+,71+504(a6)
	move.w	(a0)+,71+672(a6)

	move.w	6(a4),d1
	and.w	#%1111,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a5,d1.w),a0
	move.b	(a0)+,79(a6)		; L†g kommandodata
	move.b	(a0)+,79+168(a6)
	move.b	(a0)+,79+336(a6)
	move.b	(a0)+,79+504(a6)
	move.b	(a0)+,79+672(a6)

	move.w	8(a4),d1
	move.w	d1,d2
	and.w	#%0000001111111100,d1
	and.w	#%1111000000000000,d2
	bne.s	ingen3attskrivaut
	lea.l	jamnc1medtomhogsampling(pc),a0
	bra.s	skriuten3a
ingen3attskrivaut:
	lea.l	jamnc1medenettahogsampling(pc),a0
skriuten3a:
	add.l	0(a2,d1.w),a0
	move.w	(a0)+,87(a6)
	move.w	(a0)+,87+8(a6)
	move.w	(a0)+,8+87+160(a6)
	move.w	(a0)+,8+87+168(a6)
	move.w	(a0)+,16+87+320(a6)		; R„tt ton
	move.w	(a0)+,16+87+328(a6)
	move.w	(a0)+,24+87+480(a6)
	move.w	(a0)+,24+87+488(a6)
	move.w	(a0)+,32+87+640(a6)
	move.w	(a0)+,32+87+648(a6)

	moveq	#0,d1
	move.b	10(a4),d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a3,d1.w),a0
	move.w	(a0)+,103(a6)		; L†gsampling + kommando
	move.w	(a0)+,103+168(a6)
	move.w	(a0)+,103+336(a6)
	move.w	(a0)+,103+504(a6)
	move.w	(a0)+,103+672(a6)
	moveq	#0,d1
	move.b	11(a4),d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a3,d1.w),a0
	move.w	(a0)+,111(a6)		; Kommandodata
	move.w	(a0)+,111+168(a6)
	move.w	(a0)+,111+336(a6)
	move.w	(a0)+,111+504(a6)
	move.w	(a0)+,111+672(a6)

	move.w	12(a4),d1
	and.w	#%0000001111111100,d1
	lea	pekaretillvilkenton(pc),a1
	move.l	0(a1,d1.w),a0
	move.b	(a0)+,120(a6)		; Ton
	move.b	(a0)+,120+168(a6)
	move.b	(a0)+,120+336(a6)
	move.b	(a0)+,120+504(a6)
	move.b	(a0)+,120+672(a6)
	lea	1024*4(a1),a1
	move.l	0(a1,d1.w),a0
	move.w	(a0)+,127(a6)		; Oktav
	move.w	(a0)+,127+168(a6)
	move.w	(a0)+,127+336(a6)
	move.w	(a0)+,127+504(a6)
	move.w	(a0)+,127+672(a6)

	move.w	12(a4),d2
	and.w	#%1111000000000000,d2
	bne.s	ingen4attskrivaut
	lea	numberfont3(pc),a0
	bra.s	skriuten4a
ingen4attskrivaut:
	lea	numberfont4(pc),a0
skriuten4a:
	moveq	#0,d0
	move.b	14(a4),d0
	and.b	#$f0,d0
	add.l	d0,a0
	move.w	(a0)+,135(a6)		; Sampling
	move.w	(a0)+,135+168(a6)
	move.w	(a0)+,135+336(a6)
	move.w	(a0)+,135+504(a6)
	move.w	(a0)+,135+672(a6)

	move.w	14(a4),d1
	and.w	#%111111110000,d1
	lsr.w	#2,d1
	move.l	0(a3,d1.w),a0
	move.w	(a0)+,143(a6)		; Kommando +  h”g kommandodata
	move.w	(a0)+,143+168(a6)
	move.w	(a0)+,143+336(a6)
	move.w	(a0)+,143+504(a6)
	move.w	(a0)+,143+672(a6)

	move.w	14(a4),d1
	and.w	#%1111,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a5,d1.w),a0
	move.b	(a0)+,151(a6)		; L†g kommandodata
	move.b	(a0)+,151+168(a6)
	move.b	(a0)+,151+336(a6)
	move.b	(a0)+,151+504(a6)
	move.b	(a0)+,151+672(a6)


	rts

negativrensadenhardelen:		; Rensa en del av raden
	moveq	#0,d2
	move.b	d2,(a6)
	move.b	d2,168(a6)
	move.b	d2,336(a6)
	move.b	d2,504(a6)
	move.b	d2,672(a6)
	addq.l	#7,a6
	move.b	d2,(a6)
	move.b	d2,168(a6)
	move.b	d2,336(a6)
	move.b	d2,504(a6)
	move.b	d2,672(a6)
	addq.l	#8,a6
	move.w	#4-1,d0
rensaforstakanalen:
	move.b	d2,(a6)
	move.b	d2,168(a6)
	move.b	d2,336(a6)
	move.b	d2,504(a6)
	move.b	d2,672(a6)
	addq.l	#1,a6
	move.b	d2,(a6)
	move.b	d2,168(a6)
	move.b	d2,336(a6)
	move.b	d2,504(a6)
	move.b	d2,672(a6)
	addq.l	#7,a6
	dbra	d0,rensaforstakanalen
	addq.l	#1,a6
	move.w	#4-1,d0
rensaandrakanalen:
	move.b	d2,(a6)
	move.b	d2,168(a6)
	move.b	d2,336(a6)
	move.b	d2,504(a6)
	move.b	d2,672(a6)
	addq.l	#7,a6
	move.b	d2,(a6)
	move.b	d2,168(a6)
	move.b	d2,336(a6)
	move.b	d2,504(a6)
	move.b	d2,672(a6)
	addq.l	#1,a6
	dbra	d0,rensaandrakanalen
	addq.l	#7,a6

	move.w	#4-1,d0
rensatredjekanalen:
	move.b	d2,(a6)
	move.b	d2,168(a6)
	move.b	d2,336(a6)
	move.b	d2,504(a6)
	move.b	d2,672(a6)
	addq.l	#1,a6
	move.b	d2,(a6)
	move.b	d2,168(a6)
	move.b	d2,336(a6)
	move.b	d2,504(a6)
	move.b	d2,672(a6)
	addq.l	#7,a6
	dbra	d0,rensatredjekanalen
	addq.l	#1,a6
	move.w	#4-1,d0
rensafjardekanalen:
	move.b	d2,(a6)
	move.b	d2,168(a6)
	move.b	d2,336(a6)
	move.b	d2,504(a6)
	move.b	d2,672(a6)
	addq.l	#7,a6
	move.b	d2,(a6)
	move.b	d2,168(a6)
	move.b	d2,336(a6)
	move.b	d2,504(a6)
	move.b	d2,672(a6)
	addq.l	#1,a6
	dbra	d0,rensafjardekanalen
	rts

skrivutenpatternradextratjock:
	move.w	d7,d0
	bmi	negativrensadenhardelenextratjock1
	cmp.w	#$3f,d0
	bgt	negativrensadenhardelenextratjock1
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a3,d0.w),a0
	move.b	(a0)+,(a6)
	move.b	(a0),7(a6)
	move.b	-1(a0),168(a6)
	move.b	(a0)+,175(a6)
	move.b	(a0)+,336(a6)
	move.b	(a0),343(a6)
	move.b	-1(a0),504(a6)
	move.b	(a0)+,511(a6)
	move.b	(a0)+,672(a6)
	move.b	(a0),679(a6)
	move.b	-1(a0),840(a6)
	move.b	(a0)+,847(a6)
	move.b	(a0)+,1008(a6)
	move.b	(a0),1015(a6)
	move.b	-1(a0),1176(a6)
	move.b	(a0)+,1183(a6)
	move.b	(a0)+,1344(a6)
	move.b	(a0),1351(a6)
	move.b	-1(a0),1512(a6)
	move.b	(a0),1519(a6)

	move.w	(a4),d1
	move.w	d1,d2
	and.w	#%0000001111111100,d1
	and.w	#%1111000000000000,d2
	bne.s	ingen1attskrivaut11
	lea	jamnc1medtomhogsampling(pc),a0
	bra.s	skriuten1a11
ingen1attskrivaut11:
	lea	jamnc1medenettahogsampling(pc),a0
skriuten1a11:
	add.l	0(a2,d1.w),a0
	move.w	(a0)+,15(a6)
	move.w	(a0),15+8(a6)
	move.w	-2(a0),8+15+160(a6)
	move.w	(a0)+,8+15+168(a6)
	move.w	(a0)+,16+15+320(a6)			; R„tt ton
	move.w	(a0),16+15+328(a6)
	move.w	-2(a0),24+15+480(a6)
	move.w	(a0)+,24+15+488(a6)
	move.w	(a0)+,32+15+640(a6)
	move.w	(a0),32+15+648(a6)
	move.w	-2(a0),40+15+800(a6)
	move.w	(a0)+,40+15+808(a6)
	move.w	(a0)+,48+15+960(a6)
	move.w	(a0),48+15+968(a6)
	move.w	-2(a0),56+15+1120(a6)
	move.w	(a0)+,56+15+1128(a6)
	move.w	(a0)+,64+15+1280(a6)
	move.w	(a0),64+15+1288(a6)
	move.w	-2(a0),72+15+1440(a6)
	move.w	(a0),72+15+1448(a6)

	moveq	#0,d1
	move.b	2(a4),d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a3,d1.w),a0
	move.w	(a0),31(a6)		; L†gsampling + kommando
	move.w	(a0)+,31+168(a6)
	move.w	(a0),31+336(a6)
	move.w	(a0)+,31+504(a6)
	move.w	(a0),31+672(a6)
	move.w	(a0)+,31+840(a6)
	move.w	(a0),31+1008(a6)
	move.w	(a0)+,31+1176(a6)
	move.w	(a0),31+1344(a6)
	move.w	(a0)+,31+1512(a6)
	moveq	#0,d1
	move.b	3(a4),d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a3,d1.w),a0
	move.w	(a0),39(a6)		; Kommandodata
	move.w	(a0)+,39+168(a6)
	move.w	(a0),39+336(a6)
	move.w	(a0)+,39+504(a6)
	move.w	(a0),39+672(a6)
	move.w	(a0)+,39+840(a6)
	move.w	(a0),39+1008(a6)
	move.w	(a0)+,39+1176(a6)
	move.w	(a0),39+1344(a6)
	move.w	(a0)+,39+1512(a6)

	move.w	4(a4),d1
	and.w	#%0000001111111100,d1
	lea	pekaretillvilkenton(pc),a1
	move.l	0(a1,d1.w),a0
	move.b	(a0),48(a6)		; Ton
	move.b	(a0)+,48+168(a6)
	move.b	(a0),48+336(a6)
	move.b	(a0)+,48+504(a6)
	move.b	(a0),48+672(a6)
	move.b	(a0)+,48+840(a6)
	move.b	(a0),48+1008(a6)
	move.b	(a0)+,48+1176(a6)
	move.b	(a0),48+1344(a6)
	move.b	(a0)+,48+1512(a6)
	lea	1024*4(a1),a1
	move.l	0(a1,d1.w),a0
	move.w	(a0),55(a6)		; Oktav
	move.w	(a0)+,55+168(a6)
	move.w	(a0),55+336(a6)
	move.w	(a0)+,55+504(a6)
	move.w	(a0),55+672(a6)
	move.w	(a0)+,55+840(a6)
	move.w	(a0),55+1008(a6)
	move.w	(a0)+,55+1176(a6)
	move.w	(a0),55+1344(a6)
	move.w	(a0)+,55+1512(a6)


	move.w	4(a4),d2
	and.w	#%1111000000000000,d2
	bne.s	ingen2attskrivaut21
	lea	numberfont3(pc),a0
	bra.s	skriuten2a21
ingen2attskrivaut21:
	lea	numberfont4(pc),a0
skriuten2a21:
	moveq	#0,d0
	move.b	6(a4),d0
	and.b	#$f0,d0
	add.l	d0,a0
	move.w	(a0),63(a6)		; Sampling
	move.w	(a0)+,63+168(a6)
	move.w	(a0),63+336(a6)
	move.w	(a0)+,63+504(a6)
	move.w	(a0),63+672(a6)
	move.w	(a0)+,63+840(a6)
	move.w	(a0),63+1008(a6)
	move.w	(a0)+,63+1176(a6)
	move.w	(a0),63+1344(a6)
	move.w	(a0)+,63+1512(a6)



	move.w	6(a4),d1
	and.w	#%111111110000,d1
	lsr.w	#2,d1
	move.l	0(a3,d1.w),a0
	move.w	(a0),71(a6)		; Kommando +  h”g kommandodata
	move.w	(a0)+,71+168(a6)
	move.w	(a0),71+336(a6)
	move.w	(a0)+,71+504(a6)
	move.w	(a0),71+672(a6)
	move.w	(a0)+,71+840(a6)
	move.w	(a0),71+1008(a6)
	move.w	(a0)+,71+1176(a6)
	move.w	(a0),71+1344(a6)
	move.w	(a0)+,71+1512(a6)


	move.w	6(a4),d1
	and.w	#%1111,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a5,d1.w),a0
	move.b	(a0),79(a6)		; L†g kommandodata
	move.b	(a0)+,79+168(a6)
	move.b	(a0),79+336(a6)
	move.b	(a0)+,79+504(a6)
	move.b	(a0),79+672(a6)
	move.b	(a0)+,79+840(a6)
	move.b	(a0),79+1008(a6)
	move.b	(a0)+,79+1176(a6)
	move.b	(a0),79+1344(a6)
	move.b	(a0)+,79+1512(a6)


	move.w	8(a4),d1
	move.w	d1,d2
	and.w	#%0000001111111100,d1
	and.w	#%1111000000000000,d2
	bne.s	ingen3attskrivaut31
	lea	jamnc1medtomhogsampling(pc),a0
	bra.s	skriuten3a31
ingen3attskrivaut31:
	lea	jamnc1medenettahogsampling(pc),a0
skriuten3a31:
	add.l	0(a2,d1.w),a0
	move.w	(a0)+,87(a6)
	move.w	(a0),87+8(a6)
	move.w	-2(a0),8+87+160(a6)
	move.w	(a0)+,8+87+168(a6)
	move.w	(a0)+,16+87+320(a6)			; R„tt ton
	move.w	(a0),16+87+328(a6)
	move.w	-2(a0),24+87+480(a6)
	move.w	(a0)+,24+87+488(a6)
	move.w	(a0)+,32+87+640(a6)
	move.w	(a0),32+87+648(a6)
	move.w	-2(a0),40+87+800(a6)
	move.w	(a0)+,40+87+808(a6)
	move.w	(a0)+,48+87+960(a6)
	move.w	(a0),48+87+968(a6)
	move.w	-2(a0),56+87+1120(a6)
	move.w	(a0)+,56+87+1128(a6)
	move.w	(a0)+,64+87+1280(a6)
	move.w	(a0),64+87+1288(a6)
	move.w	-2(a0),72+87+1440(a6)
	move.w	(a0),72+87+1448(a6)

	moveq	#0,d1
	move.b	10(a4),d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a3,d1.w),a0
	move.w	(a0),103(a6)		; L†gsampling + kommando
	move.w	(a0)+,103+168(a6)
	move.w	(a0),103+336(a6)
	move.w	(a0)+,103+504(a6)
	move.w	(a0),103+672(a6)
	move.w	(a0)+,103+840(a6)
	move.w	(a0),103+1008(a6)
	move.w	(a0)+,103+1176(a6)
	move.w	(a0),103+1344(a6)
	move.w	(a0)+,103+1512(a6)
	moveq	#0,d1
	move.b	11(a4),d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a3,d1.w),a0
	move.w	(a0),111(a6)		; Kommandodata
	move.w	(a0)+,111+168(a6)
	move.w	(a0),111+336(a6)
	move.w	(a0)+,111+504(a6)
	move.w	(a0),111+672(a6)
	move.w	(a0)+,111+840(a6)
	move.w	(a0),111+1008(a6)
	move.w	(a0)+,111+1176(a6)
	move.w	(a0),111+1344(a6)
	move.w	(a0)+,111+1512(a6)

	move.w	12(a4),d1
	and.w	#%0000001111111100,d1
	lea	pekaretillvilkenton(pc),a1
	move.l	0(a1,d1.w),a0
	move.b	(a0),120(a6)		; Ton
	move.b	(a0)+,120+168(a6)
	move.b	(a0),120+336(a6)
	move.b	(a0)+,120+504(a6)
	move.b	(a0),120+672(a6)
	move.b	(a0)+,120+840(a6)
	move.b	(a0),120+1008(a6)
	move.b	(a0)+,120+1176(a6)
	move.b	(a0),120+1344(a6)
	move.b	(a0)+,120+1512(a6)
	lea	1024*4(a1),a1
	move.l	0(a1,d1.w),a0
	move.w	(a0),127(a6)		; Oktav
	move.w	(a0)+,127+168(a6)
	move.w	(a0),127+336(a6)
	move.w	(a0)+,127+504(a6)
	move.w	(a0),127+672(a6)
	move.w	(a0)+,127+840(a6)
	move.w	(a0),127+1008(a6)
	move.w	(a0)+,127+1176(a6)
	move.w	(a0),127+1344(a6)
	move.w	(a0)+,127+1512(a6)


	move.w	12(a4),d2
	and.w	#%1111000000000000,d2
	bne.s	ingen4attskrivaut41
	lea	numberfont3(pc),a0
	bra.s	skriuten4a41
ingen4attskrivaut41:
	lea	numberfont4(pc),a0
skriuten4a41:
	moveq	#0,d0
	move.b	14(a4),d0
	and.b	#$f0,d0
	add.l	d0,a0
	move.w	(a0),135(a6)		; Sampling
	move.w	(a0)+,135+168(a6)
	move.w	(a0),135+336(a6)
	move.w	(a0)+,135+504(a6)
	move.w	(a0),135+672(a6)
	move.w	(a0)+,135+840(a6)
	move.w	(a0),135+1008(a6)
	move.w	(a0)+,135+1176(a6)
	move.w	(a0),135+1344(a6)
	move.w	(a0)+,135+1512(a6)


	move.w	14(a4),d1
	and.w	#%111111110000,d1
	lsr.w	#2,d1
	move.l	0(a3,d1.w),a0
	move.w	(a0),143(a6)		; Kommando +  h”g kommandodata
	move.w	(a0)+,143+168(a6)
	move.w	(a0),143+336(a6)
	move.w	(a0)+,143+504(a6)
	move.w	(a0),143+672(a6)
	move.w	(a0)+,143+840(a6)
	move.w	(a0),143+1008(a6)
	move.w	(a0)+,143+1176(a6)
	move.w	(a0),143+1344(a6)
	move.w	(a0)+,143+1512(a6)

	move.w	14(a4),d1
	and.w	#%1111,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a5,d1.w),a0
	move.b	(a0),151(a6)		; L†g kommandodata
	move.b	(a0)+,151+168(a6)
	move.b	(a0),151+336(a6)
	move.b	(a0)+,151+504(a6)
	move.b	(a0),151+672(a6)
	move.b	(a0)+,151+840(a6)
	move.b	(a0),151+1008(a6)
	move.b	(a0)+,151+1176(a6)
	move.b	(a0),151+1344(a6)
	move.b	(a0)+,151+1512(a6)

	rts

negativrensadenhardelenextratjock1:	; Rensa en del av raden
	clr.b	(a6)
	clr.b	168(a6)
	clr.b	336(a6)
	clr.b	504(a6)
	clr.b	672(a6)
	clr.b	840(a6)
	clr.b	1008(a6)
	clr.b	1176(a6)
	clr.b	1344(a6)
	clr.b	1512(a6)
	addq.l	#7,a6
	clr.b	(a6)
	clr.b	168(a6)
	clr.b	336(a6)
	clr.b	504(a6)
	clr.b	672(a6)
	clr.b	840(a6)
	clr.b	1008(a6)
	clr.b	1176(a6)
	clr.b	1344(a6)
	clr.b	1512(a6)
	addq.l	#8,a6
	move.w	#4-1,d0
rensaforstakanalenet1:
	clr.b	(a6)
	clr.b	168(a6)
	clr.b	336(a6)
	clr.b	504(a6)
	clr.b	672(a6)
	clr.b	840(a6)
	clr.b	1008(a6)
	clr.b	1176(a6)
	clr.b	1344(a6)
	clr.b	1512(a6)
	addq.l	#1,a6
	clr.b	(a6)
	clr.b	168(a6)
	clr.b	336(a6)
	clr.b	504(a6)
	clr.b	672(a6)
	clr.b	840(a6)
	clr.b	1008(a6)
	clr.b	1176(a6)
	clr.b	1344(a6)
	clr.b	1512(a6)
	addq.l	#7,a6
	dbra	d0,rensaforstakanalenet1
	addq.l	#1,a6
	move.w	#4-1,d0
rensaandrakanalenet1:
	clr.b	(a6)
	clr.b	168(a6)
	clr.b	336(a6)
	clr.b	504(a6)
	clr.b	672(a6)
	clr.b	840(a6)
	clr.b	1008(a6)
	clr.b	1176(a6)
	clr.b	1344(a6)
	clr.b	1512(a6)
	addq.l	#7,a6
	clr.b	(a6)
	clr.b	168(a6)
	clr.b	336(a6)
	clr.b	504(a6)
	clr.b	672(a6)
	clr.b	840(a6)
	clr.b	1008(a6)
	clr.b	1176(a6)
	clr.b	1344(a6)
	clr.b	1512(a6)
	addq.l	#1,a6
	dbra	d0,rensaandrakanalenet1
	addq.l	#7,a6

	move.w	#4-1,d0
rensatredjekanalenet1:
	clr.b	(a6)
	clr.b	168(a6)
	clr.b	336(a6)
	clr.b	504(a6)
	clr.b	672(a6)
	clr.b	840(a6)
	clr.b	1008(a6)
	clr.b	1176(a6)
	clr.b	1344(a6)
	clr.b	1512(a6)
	addq.l	#1,a6
	clr.b	(a6)
	clr.b	168(a6)
	clr.b	336(a6)
	clr.b	504(a6)
	clr.b	672(a6)
	clr.b	840(a6)
	clr.b	1008(a6)
	clr.b	1176(a6)
	clr.b	1344(a6)
	clr.b	1512(a6)
	addq.l	#7,a6
	dbra	d0,rensatredjekanalenet1
	addq.l	#1,a6
	move.w	#4-1,d0
rensafjardekanalenet1:
	clr.b	(a6)
	clr.b	168(a6)
	clr.b	336(a6)
	clr.b	504(a6)
	clr.b	672(a6)
	clr.b	840(a6)
	clr.b	1008(a6)
	clr.b	1176(a6)
	clr.b	1344(a6)
	clr.b	1512(a6)
	addq.l	#7,a6
	clr.b	(a6)
	clr.b	168(a6)
	clr.b	336(a6)
	clr.b	504(a6)
	clr.b	672(a6)
	clr.b	840(a6)
	clr.b	1008(a6)
	clr.b	1176(a6)
	clr.b	1344(a6)
	clr.b	1512(a6)
	addq.l	#1,a6
	dbra	d0,rensafjardekanalenet1
	rts

clearthepattshower:
	tst.w	lowershower
	bne	intet”mmaeftersomsampleeditornvisas
	move.w	#1,donotdoanymusicorsomeshit
	move.l	patterns,a4
	moveq	#0,d0
	move.w	lastsongpatt,d0
	asl.l	#8,d0
	asl.l	#3,d0
	add.l	d0,a4
	moveq	#0,d1
	move.w	startkanal,d1
	subq.w	#1,d1
	add.w	d1,d1
	add.w	d1,d1
	add.l	d1,a4
	moveq	#0,d0
	move.w	#18000,d0
	sub.l	#32*8,d0
	add.l	d0,a4
	lea	taltabell2(pc),a5	; Pekare till taltabell
	move.l	bildminne(pc),a6
	lea	168*110+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	move.w	#18000,d7		; Vilken patternpos ligger vi p†
	lsr.w	#5,d7
	subq.w	#8,d7
	lea	tolkedbuffer(pc),a3
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	lea	168*116+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	lea	168*122+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	lea	168*128+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	lea	168*134+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	lea	168*140+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	lea	168*146+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	lea	168*152+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	lea	168*165+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternradextratjock
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	lea	168*183+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	lea	168*189+3+8(a6),a6	; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	add.l	#168*195+3+8,a6		; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	add.l	#168*201+3+8,a6		; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	add.l	#168*207+3+8,a6		; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	add.l	#168*213+3+8,a6		; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	add.l	#168*219+3+8,a6		; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
	lea	32(a4),a4

	move.l	bildminne(pc),a6
	add.l	#168*225+3+8,a6		; Pekare till vart raden skall skrivas ut
	addq.w	#1,d7			; N„sta pattern
	bsr	skrivutenpatternrad
intet”mmaeftersomsampleeditornvisas:
	rts





highfreq:
	dc.w	0,0,0,202,180,0,151,135,120,0,0,0,0,0,0,0
	dc.w	214,190,170,160,143,127,113,0,0,0,0,0,0,0,0,404
	dc.w	360,0,302,269,240,0,202,180,0,0,0,0,428,381,339,320
	dc.w	285,254,226,214,190,170,160,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

lowfreq:
	dc.w	0,0,0,404,360,0,302,269,240,0,202,180,0,151,0,0
	dc.w	428,381,339,320,285,254,226,214,190,170,160,143,0,0,0,808
	dc.w	720,0,604,538,480,0,404,360,0,135,0,0,856,762,678,640
	dc.w	570,508,453,428,381,339,320,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


tabelldata2:
	ds.l	1024

pekaretillvilkenton:
	ds.l	1024

pekaretillvilkenoktav:
	ds.l	1024

chanel1onoff:
	dc.w	-1
chanel2onoff:
	dc.w	-1
chanel3onoff:
	dc.w	-1
chanel4onoff:
	dc.w	-1
chanel5onoff:
	dc.w	-1
chanel6onoff:
	dc.w	-1
chanel7onoff:
	dc.w	-1
chanel8onoff:
	dc.w	-1
extraoffsetadded1:
	dc.w	0
extraoffsetadded2:
	dc.w	0

laddainenmodulochk”r:		; Om det st†r ett namn i startstr„ngen
	move.w	#1,fr†gainteladdabara	; ladda in den modulen och spela den
	jsr	hoppadirektiniladdningen
	clr.w	fr†gainteladdabara
	jsr	playknapp
	rts

fr†gainteladdabara:
	dc.w	0

mainisnotzero:
	dc.w	0	; Om 1 „r mainen ej ners„nkt
mainwantzero:
	dc.w	0	; Om alla dessa blir 8 s† s„nks mainvolymen
	dc.w	0	; till 0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0

tempotabell502:
	dc.w	502,498,494,490,486,482,478,474,470,466,462,458,454,450,446,442,438,434,430,426,422,418,414,410,406
	dc.w	402,398,394,390,386,382,378,373,369,365,361,357,353,349,345,341,337,333,329,325,321,317,313,309,305
	dc.w	301,297,293,289,285,281,277,273,269,265,261,257,253,249,245,241,237,233,229,225,221,217,213,209,205
	dc.w	201,197,193,189,185,181,177,173,169,165,161,157,153,149,145,141,137,133,129,124,120,116,112,108,104
	dc.w	100,96,92,88,84,80,76,72,68,64,60,56,52,48,44,40,36,32,28,24,20,16,12,8,4
tempotabell504:
	dc.w	504,500,496,492,488,484,480,476,472,468,464,460,456,452,448,444,439,435,431,427,423,419,415,411,407
	dc.w	403,399,395,391,387,383,379,375,371,367,363,359,355,351,347,343,339,335,331,327,323,319,314,310,306
	dc.w	302,298,294,290,286,282,278,274,270,266,262,258,254,250,246,242,238,234,230,226,222,218,214,210,206
	dc.w	202,198,194,190,185,181,177,173,169,165,161,157,153,149,145,141,137,133,129,125,121,117,113,109,105
	dc.w	101,97,93,89,85,81,77,73,69,65,60,56,52,48,44,40,36,32,28,24,20,16,12,8,4

h”gertabell:
	ds.l	504
	dc.l	0,0
v„nstertabell:
	ds.l	504
	dc.l	0,0
h”gertabell2:
	ds.l	504
	dc.l	0,0
v„nstertabell2:
	ds.l	504
	dc.l	0,0
MSTE:	ds.w	125
	dc.w	504,504
skapa:	dc.w	0
skapade:dc.w	0
skapamax:
	dc.w	504
testy:	dc.w	0

playmusic:
	tst.w	lownoise
	beq.s	s„„ttttttttintevolymen345345
	move.w	oldtreble,d4
	sub.w	#28,d4
	lea	treble,a0		; S„tt diskant
	add.w	d4,d4
	move.w	#$07ff,$ffff8924.w
	move.w	(a0,d4.w),$ffff8922.w
s„„ttttttttintevolymen345345:

	clr.w	testy

	clr.w	skapade

	clr.w	musicwait
	addq.w	#1,vantapasam
	move.w	vantapasam,d0
	cmp.w	#2,d0
	bls.s	ejborjaom
	clr.w	vantapasam
ejborjaom:
	move.w	vantapasam,d0
	add.w	d0,d0
	add.w	d0,d0
	lea	buffrar,a0
	move.l	0(a0,d0.w),samplepek
	addq.w	#4,d0
	move.l	0(a0,d0.w),d1
	move.b	$ffff8909.w,ultradummy+1
	move.b	$ffff890b.w,ultradummy+2
	move.b	$ffff890d.w,ultradummy+3
	move.l	ultradummy,d0
	cmp.l	d1,d0
	bgt.s	hejhopp
	cmp.l	samplepek,d0
	bls.s	hejhopp
	subq.w	#1,vantapasam
	move.w	#1,musicwait
	move.l	#dummymusic,samplepek
	bra	hoppa”verskapandetdenh„rframen
hejhopp:
	move.l	samplepek,newposinbuffer

	tst.w	usetempo		; Tempokontroll
	beq.s	setillattanv„ndatempot

	move.w	skapamax,skapa
	bsr	skapaenskv„ttmusik	; Skapa p† utan tempot

	bra	fixatilllownoisetislutet
setillattanv„ndatempot:			; Ok, fixa till tempot nu

	cmp.l	#12500,tempor„knare
	bgt.s	k”rbaraskapandedennaframe
	tst.l	tempor„knare
	beq.s	inteenlitenrestsenf”rraframen	; Om f”rra framen l„mnade kvar
	lea	MSTE,a4			; en bit av skapandet till denna
	move.l	tempor„knare,d0		; frame, skapa det nu isf
	cmp.l	#12500,d0		; Žr f”rra biten st”rre „n en
	ble.s	detgickmindre„nenframe	; frame? Isf g”r bara en och
k”rbaraskapandedennaframe:		; spar resten till n„sta g†ng
	move.w	skapamax,skapa
	bsr	skapaenskv„ttmusik
	bra	tempoteratklart
detgickmindre„nenframe:
	add.w	#50,d0
	divu	#100,d0
	add.w	d0,d0
	move.w	(a4,d0.w),skapa
	bsr	skapaenskv„ttmusik
inteenlitenrestsenf”rraframen:
	move.l	tempor„knare,d0
	cmp.l	#12500,d0
	bgt.s	tempoteratklart
	move.l	d0,d2
	add.l	tempoadder,d0
	move.l	d0,tempor„knare		; R„kna fram r„knaren
	move.l	#12500,d1
	sub.l	d2,d1
	cmp.l	tempoadder,d1
	ble.s	r„knaframenhalvmesyrinnanvislutar
	lea	MSTE,a4			; Skapa en del
	move.l	tempoadder,d0
	add.w	#50,d0
	divu	#100,d0
	add.w	d0,d0
	move.w	(a4,d0.w),skapa
	jsr	music			; K”r lite musik
	bsr	skapaenskv„ttmusik
	bra.s	inteenlitenrestsenf”rraframen	
r„knaframenhalvmesyrinnanvislutar:
	lea	MSTE,a4			; Skapa det sista innan vi slutar
	tst.l	d1
	bpl.s	intesetillattdetblirpositivt
	add.l	tempoadder,d1
intesetillattdetblirpositivt:
	add.w	#50,d0
	divu	#100,d1
	add.w	d1,d1
	move.w	(a4,d1.w),skapa
	jsr	music			; K”r lite musik
	bsr	skapaenskv„ttmusik
	bra	inteenlitenrestsenf”rraframen
tempoteratklart:
	sub.l	#12500,tempor„knare
	move.w	skapade,d0
fixatilllownoisetislutet:
	moveq	#0,d0
	cmp.l	#$00080008,mainwantzero+10
	bne.s	inteenvolyms„nkning
	cmp.l	#$00080008,mainwantzero+6
	bne.s	inteenvolyms„nkning
	cmp.l	#$00080008,mainwantzero+2
	bne.s	inteenvolyms„nkning
	moveq	#1,d0
inteenvolyms„nkning:
	tst.w	d0
	beq.s	s„ttvolymentillnormalmain
	move.w	#%10011000000,d4
	move.w	d0,mainisnotzero	; S„nk volymen till 0
	bra.s	allt„rsomdetskallimainen
s„ttvolymentillnormalmain:
	move.w	oldmain,d4
	sub.w	#28,d4
	lea	main,a0			; S„tt volymen normalt
	add.w	d4,d4
	move.w	(a0,d4.w),d4
	move.w	d0,mainisnotzero
allt„rsomdetskallimainen:
	tst.w	lownoise
	beq.s	s„„ttttttttintevolymen
	move.w	#$07ff,$ffff8924.w
	move.w	d4,$ffff8922.w
s„„ttttttttintevolymen:

hoppa”verskapandetdenh„rframen:

	rts

gamlah”ger:
	dc.l	0
gamlav„nster:
	dc.l	0
gamlah”ger2:
	dc.l	0
gamlav„nster2:
	dc.l	0

skapaenskv„ttmusik:
;	move.w	#$F0,$ffff8240.w

	lea	MSTE,a4
	lea	h”gertabell2,a2
	lea	v„nstertabell2,a3
	lea	h”gertabell,a0
	lea	v„nstertabell,a1
	move.w	skapa,d0		; Kolla s† att vi inte skapar
	beq	muuuuuuuuuuuuuu
	move.w	d0,d1			; flera „n vi f†r
	add.w	skapade,d1
	cmp.w	skapamax,d1
	blt.s	detg†rs†fiiiiintattskapas†m†nga
	move.w	skapamax,d0
	sub.w	skapade,d0
detg†rs†fiiiiintattskapas†m†nga:
	add.w	d0,skapade
	move.w	d0,skapa
	tst.w	loopordupp
	beq	viharduppadkodh„r
	subq.w	#1,skapa
	bmi	muuuuuuuuuuuuuu
	tst.w	talattandamed
	beq.s	det„ren12aelleren25a
	subq.w	#1,d0
	move.w	d0,d2
	and.w	talattandamed,d0
	move.w	talattdelamed,d1
	lsr.w	d1,d2
	move.w	d2,skapa
	add.w	d0,d0
	add.w	d0,d0
	move.l	kanal23rutin,ddddd+2
	move.l	(a0,d0.w),d1
	add.l	d1,ddddd+2
	move.l	kanal67rutin,eeeee+2
	move.l	(a2,d0.w),d1
	add.l	d1,eeeee+2
	move.l	(a1,d0.w),d1
	move.l	#kanal14rutin,fffff+2
	add.l	d1,fffff+2
	move.l	#kanal58rutin,ggggg+2
	move.l	(a3,d0.w),d1
	add.l	d1,ggggg+2
	bra	detvarenloopadkodh„r
det„ren12aelleren25a:
	move.l	kanal23rutin,ddddd+2	; Vi har en loopad kod h„r bakom
	addq.l	#2,ddddd+2
	move.l	kanal67rutin,eeeee+2
	addq.l	#2,eeeee+2
	move.l	#kanal14rutin,fffff+2
	addq.l	#2,fffff+2
	move.l	#kanal58rutin,ggggg+2
	addq.l	#2,ggggg+2
	bra.s	detvarenloopadkodh„r
viharduppadkodh„r:
	add.w	d0,d0
	add.w	d0,d0
b”rjaskapanur†:				; St„ll in s† att vi hoppar till r„tt
	move.l	kanal23rutin,ddddd+2	; offset
	move.l	(a0,d0.w),d1
	add.l	d1,ddddd+2
	move.l	kanal67rutin,eeeee+2
	move.l	(a2,d0.w),d1
	add.l	d1,eeeee+2
	move.l	(a1,d0.w),d1
	move.l	#kanal14rutin,fffff+2
	add.l	d1,fffff+2
	move.l	#kanal58rutin,ggggg+2
	move.l	(a3,d0.w),d1
	add.l	d1,ggggg+2
detvarenloopadkodh„r:

	move.l	newposinbuffer,samplepek

	lea	aud1vol2,a0
	move.b	aud1vol+1,(a0)+
	move.b	aud2vol+1,(a0)+
	move.b	aud3vol+1,(a0)+
	move.b	aud4vol+1,(a0)+
	move.b	aud5vol+1,(a0)+
	move.b	aud6vol+1,(a0)+
	move.b	aud7vol+1,(a0)+
	move.b	aud8vol+1,(a0)+

	lea	itab0,a5
	lea	vtab,a3
	moveq	#0,d0
	moveq	#0,d4
	movea.l wiz2lc,a0
	move.l	wiz2pos,d0
	move.w	wiz2frc,d1
	clr.w	extraoffsetadded1
	cmp.l	#$7FFF,d0
	blt.s	inteenkonstigoffset2
	sub.l	#$8000,d0
	add.l	#$8000,a0
	move.w	#1,extraoffsetadded1
inteenkonstigoffset2:
	move.w	aud2per,d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2
	movea.w 2(a5,d7.w),a4
	move.w	aud2vol,d7
	and.w	#$00ff,d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2
	tst.w	chanel2onoff
	bmi.s	kanal2skallvaratyst
	lea	vtab,a2
	clr.b	aud2vol2
kanal2skallvaratyst:
	lea	itab0,a5
	movea.l wiz3lc,a1
	move.l	wiz3pos,d4
	move.w	wiz3frc,d5
	move.w	aud3per,d7
	clr.w	extraoffsetadded2
	cmp.l	#$8000,d4
	blt.s	inteenkonstigoffset3
	sub.l	#$8000,d4
	add.l	#$8000,a1
	move.w	#1,extraoffsetadded2
inteenkonstigoffset3:
	add.w	d7,d7
	add.w	d7,d7			; 8
	move.w	0(a5,d7.w),d6		; 14
	movea.w 2(a5,d7.w),a5		; 14
	move.w	aud3vol,d7		; 16
	and.w	#$00ff,d7
	asl.w	#8,d7			; 22
	lea	0(a3,d7.w),a3		; 12
	tst.w	chanel3onoff
	bmi.s	kanal3skallvaratyst
	lea	vtab,a3
	clr.b	aud3vol2
kanal3skallvaratyst:
	move.l	samplepek,a6		; 20
	moveq	#0,d3			; 4

	move.l	gamlah”ger,d7
	tst.w	loopordupp
	beq.s	ickeloopadbitkod1
	swap	d7
	move.w	skapa,d7
	swap	d7
ickeloopadbitkod1:

;	move.w	#$F,$ffff8240.w

ddddd:	jsr	$12345678

;	move.w	#$F0,$ffff8240.w

	move.l	d7,gamlah”ger

	move.l	a6,newposinbuffer

	tst.w	extraoffsetadded1
	beq.s	inteensubattg”ra2
	lea	-$8000(a0),a0
	add.l	#$8000,d0
inteensubattg”ra2:
	tst.w	extraoffsetadded2
	beq.s	inteensubattg”ra3
	lea	-$8000(a1),a1
	add.l	#$8000,d4
inteensubattg”ra3:

	tst.w	musicwait
	bne	intesparaundan2kanaler1
	cmp.l	wiz2len,d0
	blt.s	ok2
	move.l	wiz2rpt,d2
	cmp.l	#1000,d2
	bgt.s	onlysub2
	tst.l	wiz2rpt
	beq.s	rpt2„rnoll
	move.l	wiz2len,d3
	sub.l	wiz2rpt,d3
	sub.l	d3,d0
	move.l	d0,d2
	divu	wiz2rpt+2,d2
	mulu	wiz2rpt+2,d2
	sub.l	d2,d0
	add.l	wiz2rpt,d0
	add.l	d3,d0
onlysub2:
	sub.l	wiz2rpt,d0
	tst.l	wiz2rpt
	bne.s	ok2
rpt2„rnoll:
	move.l	wiz2len,d0
	addq.w	#1,mainwantzero
	bra.s	ok21
ok2:	tst.b	aud2vol2
	bne.s	ok21
	addq.w	#1,mainwantzero
ok21:	move.l	d0,wiz2pos
	move.w	d1,wiz2frc
	cmp.l	wiz3len,d4
	blt.s	ok3
	move.l	wiz3rpt,d2
	cmp.l	#1000,d2
	bgt.s	onlysub3
	tst.l	wiz3rpt
	beq.s	rpt3„rnoll
	move.l	wiz3len,d3
	sub.l	wiz3rpt,d3
	sub.l	d3,d4
	move.l	d4,d2
	divu	wiz3rpt+2,d2
	mulu	wiz3rpt+2,d2
	sub.l	d2,d4
	add.l	wiz3rpt,d4
	add.l	d3,d4
onlysub3:
	sub.l	wiz3rpt,d4
	tst.l	wiz3rpt
	bne.s	ok3
rpt3„rnoll:
	move.l	wiz3len,d4
	addq.w	#1,mainwantzero
	bra.s	ok31
ok3:	tst.b	aud3vol2
	bne.s	ok31
	addq.w	#1,mainwantzero
ok31:	move.l	d4,wiz3pos
	move.w	d5,wiz3frc
intesparaundan2kanaler1:

	lea	itab0,a5
	lea	vtab,a3
	moveq	#0,d0
	moveq	#0,d4
	movea.l wiz1lc,a0
	move.l	wiz1pos,d0
	move.w	wiz1frc,d1
	move.w	aud1per,d7
	clr.w	extraoffsetadded1
	cmp.l	#$8000,d0
	blt.s	inteenkonstigoffset1
	sub.l	#$8000,d0
	add.l	#$8000,a0
	move.w	#1,extraoffsetadded1
inteenkonstigoffset1:
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2
	movea.w 2(a5,d7.w),a4
	move.w	aud1vol,d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2
	tst.w	chanel1onoff
	bmi.s	kanal1skallvaratyst
	lea	vtab,a2
	clr.b	aud1vol2
kanal1skallvaratyst:
	lea	itab0,a5
	movea.l wiz4lc,a1
	move.l	wiz4pos,d4
	move.w	wiz4frc,d5
	move.w	aud4per,d7
	clr.w	extraoffsetadded2
	cmp.l	#$8000,d4
	blt.s	inteenkonstigoffset4
	sub.l	#$8000,d4
	add.l	#$8000,a1
	move.w	#1,extraoffsetadded2
inteenkonstigoffset4:
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d6
	movea.w 2(a5,d7.w),a5
	move.w	aud4vol,d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a3
	tst.w	chanel4onoff
	bmi.s	kanal4skallvaratyst
	lea	vtab,a3
	clr.b	aud4vol2
kanal4skallvaratyst:
	movea.l samplepek,a6
	moveq	#0,d3

	move.l	gamlav„nster,d7
	tst.w	loopordupp
	beq.s	ickeloopadbitkod2
	swap	d7
	move.w	skapa,d7
	swap	d7
ickeloopadbitkod2:

;	move.w	#$F,$ffff8240.w

fffff:	jsr	$12345678

;	move.w	#$0,$ffff8240.w

	move.l	gamlav„nster,d7

	tst.w	extraoffsetadded1
	beq.s	inteensubattg”ra1
	lea	-$8000(a0),a0
	add.l	#$8000,d0
inteensubattg”ra1:
	tst.w	extraoffsetadded2
	beq.s	inteensubattg”ra4
	lea	-$8000(a1),a1
	add.l	#$8000,d4
inteensubattg”ra4:

	tst.w	musicwait
	bne	intesparaundan2kanaler2
	cmp.l	wiz1len,d0
	blt.s	ok1
	move.l	wiz1rpt,d2
	cmp.l	#1000,d2
	bgt.s	onlysub1
	tst.l	wiz1rpt
	beq.s	rpt1„rnoll
	move.l	wiz1len,d3
	sub.l	wiz1rpt,d3
	sub.l	d3,d0
	move.l	d0,d2
	divu	wiz1rpt+2,d2
	mulu	wiz1rpt+2,d2
	sub.l	d2,d0
	add.l	wiz1rpt,d0
	add.l	d3,d0
onlysub1:
	sub.l	wiz1rpt,d0
	tst.l	wiz1rpt
	bne.s	ok1
rpt1„rnoll:
	move.l	wiz1len,d0
	addq.w	#1,mainwantzero
	bra.s	ok11
ok1:	tst.b	aud1vol2
	bne.s	ok11
	addq.w	#1,mainwantzero
ok11:	move.l	d0,wiz1pos
	move.w	d1,wiz1frc
	cmp.l	wiz4len,d4
	blt.s	ok4
	move.l	wiz4rpt,d2
	cmp.l	#1000,d2
	bgt.s	onlysub4
	tst.l	wiz4rpt
	beq.s	rpt4„rnoll
	move.l	wiz4len,d3
	sub.l	wiz4rpt,d3
	sub.l	d3,d4
	move.l	d4,d2
	divu	wiz4rpt+2,d2
	mulu	wiz4rpt+2,d2
	sub.l	d2,d4
	add.l	wiz4rpt,d4
	add.l	d3,d4
onlysub4:
	sub.l	wiz4rpt,d4
	tst.l	wiz4rpt
	bne.s	ok4
rpt4„rnoll:
	move.l	wiz4len,d4
	addq.w	#1,mainwantzero
	bra.s	ok41
ok4:	tst.b	aud4vol2
	bne.s	ok41
	addq.w	#1,mainwantzero
ok41:	move.l	d4,wiz4pos
	move.w	d5,wiz4frc
intesparaundan2kanaler2:

	cmp.w	#4,antalkanaler
	bne.s	forts„ttf”rhelvete
	addq.w	#4,mainwantzero
	bra	intesparaundan2kanaler4
forts„ttf”rhelvete:

	lea	itab0,a5
	lea	vtab,a3
	moveq	#0,d0
	moveq	#0,d4
	movea.l wiz6lc,a0
	move.l	wiz6pos,d0
	move.w	wiz6frc,d1
	move.w	aud6per,d7
	clr.w	extraoffsetadded1
	cmp.l	#$8000,d0
	blt.s	inteenkonstigoffset6
	sub.l	#$8000,d0
	add.l	#$8000,a0
	move.w	#1,extraoffsetadded1
inteenkonstigoffset6:
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2
	movea.w 2(a5,d7.w),a4
	move.w	aud6vol,d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2
	tst.w	chanel6onoff
	bmi.s	kanal6skallvaratyst
	lea	vtab,a2
	clr.b	aud6vol2
kanal6skallvaratyst:
	lea	itab0,a5
	movea.l wiz7lc,a1
	move.l	wiz7pos,d4
	move.w	wiz7frc,d5
	move.w	aud7per,d7
	clr.w	extraoffsetadded2
	cmp.l	#$8000,d4
	blt.s	inteenkonstigoffset7
	sub.l	#$8000,d4
	add.l	#$8000,a1
	move.w	#1,extraoffsetadded2
inteenkonstigoffset7:
	add.w	d7,d7
	add.w	d7,d7			; 8
	move.w	0(a5,d7.w),d6		; 14
	movea.w 2(a5,d7.w),a5		; 14
	move.w	aud7vol,d7		; 16
	asl.w	#8,d7			; 22
	lea	0(a3,d7.w),a3		; 12
	tst.w	chanel7onoff
	bmi.s	kanal7skallvaratyst
	lea	vtab,a3
	clr.b	aud7vol2
kanal7skallvaratyst:
	move.l	samplepek,a6		; 20
	moveq	#0,d3			; 4

	move.l	gamlah”ger2,d7
	tst.w	loopordupp
	beq.s	ickeloopadbitkod3
	swap	d7
	move.w	skapa,d7
	swap	d7
ickeloopadbitkod3:

;	move.w	#$F,$ffff8240.w

eeeee:	jsr	$12345678

;	move.w	#$F0,$ffff8240.w

	move.l	gamlah”ger2,d7

	tst.w	extraoffsetadded1
	beq.s	inteensubattg”ra6
	lea	-$8000(a0),a0
	add.l	#$8000,d0
inteensubattg”ra6:
	tst.w	extraoffsetadded2
	beq.s	inteensubattg”ra7
	lea	-$8000(a1),a1
	add.l	#$8000,d4
inteensubattg”ra7:

	tst.w	musicwait
	bne	intesparaundan2kanaler3
	cmp.l	wiz6len,d0
	blt.s	ok6
	move.l	wiz6rpt,d2
	cmp.l	#1000,d2
	bgt.s	onlysub6
	tst.l	wiz6rpt
	beq.s	rpt6„rnoll
	move.l	wiz6len,d3
	sub.l	wiz6rpt,d3
	sub.l	d3,d0
	move.l	d0,d2
	divu	wiz6rpt+2,d2
	mulu	wiz6rpt+2,d2
	sub.l	d2,d0
	add.l	wiz6rpt,d0
	add.l	d3,d0
onlysub6:
	sub.l	wiz6rpt,d0
	tst.l	wiz6rpt
	bne.s	ok6
rpt6„rnoll:
	move.l	wiz6len,d0
	addq.w	#1,mainwantzero
	bra.s	ok61
ok6:	tst.b	aud6vol2
	bne.s	ok61
	addq.w	#1,mainwantzero
ok61:	move.l	d0,wiz6pos
	move.w	d1,wiz6frc
	cmp.l	wiz7len,d4
	blt.s	ok7
	move.l	wiz7rpt,d2
	cmp.l	#1000,d2
	bgt.s	onlysub7
	tst.l	wiz7rpt
	beq.s	rpt7„rnoll
	move.l	wiz7len,d3
	sub.l	wiz7rpt,d3
	sub.l	d3,d4
	move.l	d4,d2
	divu	wiz7rpt+2,d2
	mulu	wiz7rpt+2,d2
	sub.l	d2,d4
	add.l	wiz7rpt,d4
	add.l	d3,d4
onlysub7:
	sub.l	wiz7rpt,d4
	tst.l	wiz7rpt
	bne.s	ok7
rpt7„rnoll:
	move.l	wiz7len,d4
	addq.w	#1,mainwantzero
	bra.s	ok71
ok7:	tst.b	aud7vol2
	bne.s	ok71
	addq.w	#1,mainwantzero
ok71:	move.l	d4,wiz7pos
	move.w	d5,wiz7frc
intesparaundan2kanaler3:

	lea	itab0,a5
	lea	vtab,a3
	moveq	#0,d0
	moveq	#0,d4
	movea.l wiz5lc,a0
	move.l	wiz5pos,d0
	move.w	wiz5frc,d1
	move.w	aud5per,d7
	clr.w	extraoffsetadded1
	cmp.l	#$8000,d0
	blt.s	inteenkonstigoffset5
	sub.l	#$8000,d0
	add.l	#$8000,a0
	move.w	#1,extraoffsetadded1
inteenkonstigoffset5:
	add.w	d7,d7
	add.w	d7,d7
ensolig125khz4:
	move.w	0(a5,d7.w),d2
	movea.w 2(a5,d7.w),a4
	move.w	aud5vol,d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2
	tst.w	chanel5onoff
	bmi.s	kanal5skallvaratyst
	lea	vtab,a2
	clr.b	aud5vol2
kanal5skallvaratyst:
	lea	itab0,a5
	movea.l wiz8lc,a1
	move.l	wiz8pos,d4
	move.w	wiz8frc,d5
	move.w	aud8per,d7
	clr.w	extraoffsetadded2
	cmp.l	#$8000,d4
	blt.s	inteenkonstigoffset8
	sub.l	#$8000,d4
	add.l	#$8000,a1
	move.w	#1,extraoffsetadded2
inteenkonstigoffset8:
	add.w	d7,d7
	add.w	d7,d7			; 8
	move.w	0(a5,d7.w),d6		; 14
	movea.w 2(a5,d7.w),a5		; 14
	move.w	aud8vol,d7		; 16
	asl.w	#8,d7			; 22
	lea	0(a3,d7.w),a3		; 12
	tst.w	chanel8onoff
	bmi.s	kanal8skallvaratyst
	lea	vtab,a3
	clr.b	aud8vol2
kanal8skallvaratyst:
	move.l	samplepek,a6		; 20
	moveq	#0,d3			; 4

	move.l	gamlav„nster2,d7
	tst.w	loopordupp
	beq.s	ickeloopadbitkod4
	swap	d7
	move.w	skapa,d7
	swap	d7
ickeloopadbitkod4:

;	move.w	#$F,$ffff8240.w

ggggg:	jsr	$12345678

;	move.w	#$F0,$ffff8240.w

	move.l	gamlav„nster2,d7

	tst.w	extraoffsetadded1
	beq.s	inteensubattg”ra5
	lea	-$8000(a0),a0
	add.l	#$8000,d0
inteensubattg”ra5:
	tst.w	extraoffsetadded2
	beq.s	inteensubattg”ra8
	lea	-$8000(a1),a1
	add.l	#$8000,d4
inteensubattg”ra8:

	tst.w	musicwait
	bne	intesparaundan2kanaler4
	cmp.l	wiz5len,d0
	blt.s	ok5
	move.l	wiz5rpt,d2
	cmp.l	#1000,d2
	bgt.s	onlysub5
	tst.l	wiz5rpt
	beq.s	rpt5„rnoll
	move.l	wiz5len,d3
	sub.l	wiz5rpt,d3
	sub.l	d3,d0
	move.l	d0,d2
	divu	wiz5rpt+2,d2
	mulu	wiz5rpt+2,d2
	sub.l	d2,d0
	add.l	wiz5rpt,d0
	add.l	d3,d0
onlysub5:
	sub.l	wiz5rpt,d0
	tst.l	wiz5rpt
	bne.s	ok5
rpt5„rnoll:
	move.l	wiz5len,d0
	addq.w	#1,mainwantzero
	bra.s	ok51
ok5:	tst.b	aud5vol2
	bne.s	ok51
	addq.w	#1,mainwantzero
ok51:	move.l	d0,wiz5pos
	move.w	d1,wiz5frc
	cmp.l	wiz8len,d4
	blt.s	ok8
	move.l	wiz8rpt,d2
	cmp.l	#1000,d2
	bgt.s	onlysub8
	tst.l	wiz8rpt
	beq.s	rpt8„rnoll
	move.l	wiz8len,d3
	sub.l	wiz8rpt,d3
	sub.l	d3,d4
	move.l	d4,d2
	divu	wiz8rpt+2,d2
	mulu	wiz8rpt+2,d2
	sub.l	d2,d4
	add.l	wiz8rpt,d4
	add.l	d3,d4
onlysub8:
	sub.l	wiz8rpt,d4
	tst.l	wiz8rpt
	bne.s	ok8
rpt8„rnoll:
	move.l	wiz8len,d4
	addq.w	#1,mainwantzero
	bra.s	ok81
ok8:	tst.b	aud8vol2
	bne.s	ok81
	addq.w	#1,mainwantzero
ok81:	move.l	d4,wiz8pos
	move.w	d5,wiz8frc
intesparaundan2kanaler4:

	move.l	mainwantzero+6,mainwantzero+10
	move.l	mainwantzero+4,mainwantzero+6
	move.l	mainwantzero,mainwantzero+2
	clr.w	mainwantzero
muuuuuuuuuuuuuu:
	rts

aud1vol2:
	dc.b	0
aud2vol2:
	dc.b	0
aud3vol2:
	dc.b	0
aud4vol2:
	dc.b	0
aud5vol2:
	dc.b	0
aud6vol2:
	dc.b	0
aud7vol2:
	dc.b	0
aud8vol2:
	dc.b	0

kanal23rutin:
	dc.l	0
kanal67rutin:
	dc.l	0

kanal14rutin:
	rept	252
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	addq.w	#2,a6
	endr
	rts

	ds.b	28*270+2200

kanal58rutin:
	rept 252
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	add.b	d7,(a6)
	addq.w	#2,a6
	endr
	rts

	ds.b	28*270+2200


tolkednumbers:
	ds.b	3072

shortpattern:
	dc.l	0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0

cleartheshorty:
	dc.w	0
internalplay:
	dc.w	0

donotdoanymusicorsomeshit:
	dc.w	0

hz125:	dc.l	18570688	; 3546895/12517*65536

hz15:	dc.l	14856787	; 3546895/15646*65536

hz18:	dc.l	12380788	; 3546895/18775*65536

hz25:	dc.l	9285715		; 3546895/25033*65536

hz1252:	dc.l	28210924	; 3546895/12517*65536*1.519110409

hz152:	dc.l	22569099	; 3546895/15646*65536*1.519110409

hz182:	dc.l	18807783	; 3546895/18775*65536*1.519110409

hz252:	dc.l	14106025	; 3546895/25033*65536*1.519110409

hz1253:	dc.l	22538990	; 3546895/12517*65536*1.213686261

hz153:	dc.l	18031478	; 3546895/15646*65536*1.213686261

hz183:	dc.l	15026392	; 3546895/18775*65536*1.213686261

hz253:	dc.l	11269944	; 3546895/25033*65536*1.213686261


vblisstillworking:
	dc.w	0

	CNOP	0,4

starter:
	ds.b	2128
grafixs:incbin	tracker.dat

	CNOP	0,4

fontena:incbin	trakfont.dat

termodyn1:		; Uppspelare
	dc.l	0
termodyn2:
	dc.l	0
termodyn3:
	dc.l	0
termodyn4:
	dc.l	0

hurh†rdbelastning:
	dc.l	-1,-1,-1,-1

newposinbuffer:
	dc.l	0

fulleditorpek:		; 0 av      annat p†
	dc.l	0

oldfulleditormouse:
	dc.l	0

oldl”sadata:
	dc.l	0,0

hurmycketaddera:
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,1*960,2*960,3*960,4*960
	dc.w	5*960,6*960,7*960,8*960,9*960,10*960,11*960,12*960
	dc.w	13*960,14*960,15*960,16*960,17*960,18*960,19*960,20*960
	dc.w	21*960,22*960,23*960,24*960,25*960,25*960,25*960,25*960
	dc.w	25*960,25*960,25*960,25*960,25*960,25*960,25*960,25*960
	dc.w	25*960,25*960,25*960,25*960,25*960,25*960,25*960,25*960
	dc.w	-1

hurmycketaddera2:
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,1*960,2*960,3*960,4*960
	dc.w	5*960,6*960,7*960,8*960,9*960,10*960,11*960,12*960
	dc.w	13*960,14*960,15*960,16*960,17*960,18*960,19*960,20*960
	dc.w	21*960,22*960,23*960,24*960,25*960,26*960,27*960,28*960
	dc.w	29*960,30*960,31*960,32*960,33*960,34*960,35*960,36*960
	dc.w	37*960,38*960,39*960,40*960,41*960,42*960,42*960,42*960
	dc.w	42*960,42*960,42*960,42*960,42*960,42*960,42*960,42*960
	dc.w	-1

extrabraattha:
	dc.l	0

oldfulleditorcursor:
	dc.l	0
oldfulleditorline:
	dc.l	0
mallocedblock:
	dc.l	0

installameddelande:
	dc.b	'>> INSTALLING EDITOR <<',0
installmix:
	dc.b	'>> INSTALLING  MIXER <<',0
nowmixing:
	dc.b	'>>     MIXING ...    <<',0
	even

thelinecolor:
	dc.w	$F05

specialcursoradd:
	dc.w	0,5,8,9,12,13,17,24,25,28,29,32
	dc.w	0+36,5+36,8+36,9+36,12+36,13+36,17+36,24+36,25+36,28+36,29+36,32+36
	dc.w	0+72,5+72,8+72,9+72,12+72,13+72,17+72,24+72,25+72,28+72,29+72,32+72
	dc.w	0+108,5+108,8+108,9+108,12+108,13+108,17+108,24+108,25+108,28+108,29+108,32+108

scrollafullpatt:	; Rutinen som scrollar patternet vid mustryckning
	sub.w	#16,d6
	bpl.s	xharinteblivitnegativtnu
	clr.w	d6
xharinteblivitnegativtnu:
	lsr.w	#2,d6		; cursorn med musen
	lea	medxsteppingrate,a0
	add.w	d6,d6
	add.w	d6,d6
	move.w	(a0,d6.w),cursorx
	move.w	2(a0,d6.w),startkanal
	cmp.w	#4,antalkanaler
	bne.s	intekollaom4kanaler„raktiva
	cmp.w	#2,startkanal
	blt.s	intekollaom4kanaler„raktiva
	move.w	#1,startkanal
	move.w	#23,cursorx
intekollaom4kanaler„raktiva:
	cmp.w	#6,antalkanaler
	bne.s	intekollaom6kanaler„raktiva
	cmp.w	#4,startkanal
	blt.s	intekollaom6kanaler„raktiva
	move.w	#3,startkanal
	move.w	#23,cursorx
intekollaom6kanaler„raktiva:
	move.l	oldcursorpek,a6
	clr.b	(a6)
	clr.b	1848(a6)

	move.w	lastpos,d0
	lsr.w	#5,d0
	add.w	d0,d0
	lea	hurmycketaddera,a0
	move.w	(a0,d0.w),d1
	divu	#960/6,d1
	add.w	d1,d7
	divu	#6,d7
	lsl.w	#5,d7
	and.l	#$7fff,d7
	move.w	d7,pattpos
	cmp.w	#$800-$20,pattpos
	ble.s	inteswappapatternet
	move.w	#$800-$20,pattpos
inteswappapatternet:
	move.w	speed,counter
	move.w	#1,hoppa”veradderingendenh„rg†ngen
	move.w	startkanal,d5
	lsl.w	#4,d5
	jsr	skrivutkanalinfon
	rts

medxsteppingrate:
	dc.w	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,1,1,2,1,3,1,4,1,5,1,5,1	; Kanal 1
	dc.w	6,1,6,1,6,1,7,1,8,1,9,1,10,1,11,1,11,1		; Kanal 2
	dc.w	12,1,12,1,12,1,13,1,14,1,15,1,16,1,17,1,17,1	; Kanal 3
	dc.w	18,1,18,1,18,1,19,1,20,1,21,1,22,1,23,1,23,1	; Kanal 4
	dc.w	18,2,18,2,18,2,19,2,20,2,21,2,22,2,23,2,23,2	; Kanal 5
	dc.w	18,3,18,3,18,3,19,3,20,3,21,3,22,3,23,3,23,3	; Kanal 6
	dc.w	18,4,18,4,18,4,19,4,20,4,21,4,22,4,23,4,23,4	; Kanal 7
	dc.w	18,5,18,5,18,5,19,5,20,5,21,5,22,5,23,5,23,5	; Kanal 8
	dc.w	23,5,23,5,23,5,23,5,23,5


fullsk„rmseditorNU:
	jsr	testas†oftasomm”jligt	; Skriv ut tid o patternpos.
	jsr	ritapatternettrashat
	btst.b	#1,mkey
	bne.s	fullsk„rmseditorNU

	tst.w	lowershower
	bmi	skippaminnesbeg„ring
	tst.l	fulleditorpek
	beq	s„ttp†fullsk„rmseditorn
	move.w	oldoldlowershower,lowershower

	tst.w	falkrun
	beq.s	.blade_falkrez

	move.w	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)		; L†g uppl”sning bildminne
	trap	#14
	lea	12(sp),sp
	bra.s	.vidare
	nop
.blade_falkrez

	move.w	InOctaFalkrez,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp
	
.vidare

	tst.w	falkrun
	beq.s	.blade_falkborder

	move.w	#1,$ffff8264.w		; Fixa till 16 extra pixels
	clr.b	$ffff8264.w		; i v„nsterbordern
	bra	.hit
.blade_falkborder

	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp

	move.w	#37,-(sp)	
	trap	#14
	addq.l	#2,sp

	move.w	#37,-(sp)	
	trap	#14
	addq.l	#2,sp

	tst.w	VGArun
	beq	.falkborderVGA

.falkborderRGB
	move.w	$ffff828a.w,d0
	addq.w	#8,d0
	move.w	d0,$ffff828a.w	
	move.w	#$28,$ffff8284.w
	move.w	#$24f,$ffff82aa.w
	move.w	#$54,$ffff8210.w
	bra	.hit
.falkborderVGA
	move.w	#$24f*2,$ffff82aa.w
	move.w	#$50,$ffff8210.w
	move.w	#12,$ffff8264.w
	move.w	#$40f,$ffff82a4.w
	move.w	#$3f,$ffff82a6.w

	move.w	$ffff82a8.w,d0
	sub.w	#8*8,d0
	move.w	d0,$ffff82a8.w

.hit	

	move.w	#$8240,a1
	lea	screenpalette,a0	; Ladda upp f„rgerna
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+


	move.w	#-1,-(sp)
	move.l	bildminne,-(sp)
	move.l	bildminne,-(sp)
	move.w	#5,-(sp)		; Nytt bildminne
	trap	#14
	lea	12(sp),sp

	tst.w	lowershower
	bmi.s	skippadetsista
	move.l	mallocedblock,a0	; Sl„pp minnet som anv„nds till
	jsr	free			; bildminne
	clr.l	oldfulleditorline
skippadetsista:

	clr.l	fulleditorpek		; terg† till den normala sk„rmen

	move.l	oldl”sadata,losapositioner
	move.l	oldl”sadata+4,losarutiner

	tst.l	editorpek
	beq.s	integ”ran†gotmeraf”r8an
	bsr	fixatillseparatbildminne
integ”ran†gotmeraf”r8an:
	rts
s„ttp†fullsk„rmseditorn:		; S„tt ig†ng fullsk„rmseditorn
	tst.l	editorpek
	bne	skippaminnesbeg„ring

	lea	installameddelande,a3	; Pekare till str„ng
	move.w	#80,d0			; x		Songnamn
	move.w	#85,d1			; y
	jsr	skrivuttext		; Skriv ut textstr„ngen

	move.l	#66*6*160+24,d0
	lea	mallocedblock,a0	; Beg„r minne f”r sk„rmen
	moveq	#0,d1			; som kommer att visa patternet
	jsr	malloc
	beq	ingeneditorm”jlig
	move.l	mallocedblock,d0
	add.l	#16,d0
	and.l	#$FFFFFFF0,d0
	move.l	d0,oldfulleditorcursor
	move.l	oldfulleditorcursor,oldfulleditormouse
	move.l	oldfulleditorcursor,fulleditorpek
	bra.s	kalgksdhbjksd
skippaminnesbeg„ring:
	move.l	editorpek,d0
	move.l	d0,oldfulleditorcursor
	move.l	oldfulleditorcursor,oldfulleditormouse
	move.l	oldfulleditorcursor,fulleditorpek
kalgksdhbjksd:

	move.l	losapositioner,oldl”sadata
	move.l	losarutiner,oldl”sadata+4
	move.l	#fullkoors,losapositioner
	move.l	#fullrots,losarutiner

	move.w	lowershower,oldoldlowershower
	clr.w	lowershower

	tst.w	falkrun
	beq	.blade_falkrez
	clr.w	$ffff8264.w		; Bort med de 16 extra pixlarna

	move.w	#1,-(sp)
	move.l	fulleditorpek,-(sp)
	move.l	fulleditorpek,-(sp)
	move.w	#5,-(sp)		; Nytt bildminne
	trap	#14
	lea	12(sp),sp
	bra	.vidare
	
.blade_falkrez
	move.w	#-1,-(sp)
	move.l	fulleditorpek,-(sp)
	move.l	fulleditorpek,-(sp)
	move.w	#5,-(sp)		; Nytt bildminne + ny uppl”sning
	trap	#14
	lea	12(sp),sp

	move.w	#$2700,sr
	move.w	InOctaFalkrez,d0
	and.w	#%000110000,d0
	or.w	#%010001001,d0	
	move.w	d0,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp
	move.w	#$2100,sr
	

	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp

	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp

	tst.w	VGArun
	beq	.falkborderVGA

.falkborderRGB
	move.w	#$28,$ffff8284.w
	move.w	#$24f,$ffff82aa.w
	bra	.vidare

.falkborderVGA
	move.w	#$24f*2,$ffff82aa.w
	move.w	#0,$ffff8264.w
	move.w	#$40f,$ffff82a4.w
	move.w	#$51,$ffff82a6.w

	move.w	$ffff82a8.w,d0
	sub.w	#8*8,d0
	move.w	d0,$ffff82a8.w


.vidare
	move.w	#$8240,a1
	move.w	screenpalette,(a1)+
	move.w	screenpalette+6,(a1)+
	move.w	#$F05,(a1)+
	move.w	screenpalette,(a1)+

fixatillseparatbildminne:

	jsr	fixatillsamnamnetutanrefresh

	move.w	#1,uppdateranup†eng†ng

	tst.l	fulleditorpek
	beq.s	laddaupp8editorn12
	move.l	fulleditorpek,a6
	bra.s	klarrrrrrrrrrrt12
laddaupp8editorn12:
	move.l	editorpek,a6
klarrrrrrrrrrrt12:
	move.w	#(66*6*160/4/8)-1,d0
	moveq	#0,d1
	addq.w	#2,a6
rensaettbitplan:
	move.l	d1,(a6)+
	move.l	d1,(a6)+
	move.l	d1,(a6)+
	move.l	d1,(a6)+
	move.l	d1,(a6)+
	move.l	d1,(a6)+
	move.l	d1,(a6)+
	move.l	d1,(a6)+
	dbra	d0,rensaettbitplan

	lea	tolkedbuffer,a3
	tst.l	fulleditorpek
	beq.s	laddaupp8editorn
	move.l	fulleditorpek,a6
	bra.s	klarrrrrrrrrrrt
laddaupp8editorn:
	move.l	editorpek,a6
	tst.w	falkrun
	bne.s	klarrrrrrrrrrrt
	addq.l	#2,a6			; ()()() Rita ut patternnumret + vertikala streck r„tt...
klarrrrrrrrrrrt:
	addq.w	#4,a6
	moveq	#0,d7
	moveq	#64-1,d6
	move.b	#%00101000,(a6)
	move.b	#%00101000,5(a6)
	move.b	#%00101000,24(a6)
	move.b	#%00101000,41(a6)
	move.b	#%00101000,60(a6)
	move.b	#%00101000,77(a6)
	move.b	#%00101000,96(a6)
	move.b	#%00101000,113(a6)
	move.b	#%00101000,132(a6)
	move.b	#%00101000,149(a6)
	move.b	#%00101000,160(a6)
	lea	160(a6),a6
skrivutkuldata:
	move.l	d7,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a3,d0.w),a0
	move.b	#%00101000,(a6)
	move.b	(a0)+,1(a6)
	move.b	(a0)+,4(a6)
	move.b	#%00101000,5(a6)
	move.b	#%00101000,24(a6)
	move.b	#%00101000,41(a6)
	move.b	#%00101000,60(a6)
	move.b	#%00101000,77(a6)
	move.b	#%00101000,96(a6)
	move.b	#%00101000,113(a6)
	move.b	#%00101000,132(a6)
	move.b	#%00101000,149(a6)
	move.b	#%00101000,160(a6)
	move.b	(a0)+,161(a6)
	move.b	(a0)+,164(a6)
	move.b	#%00101000,165(a6)
	move.b	#%00101000,184(a6)
	move.b	#%00101000,201(a6)
	move.b	#%00101000,220(a6)
	move.b	#%00101000,237(a6)
	move.b	#%00101000,256(a6)
	move.b	#%00101000,273(a6)
	move.b	#%00101000,292(a6)
	move.b	#%00101000,309(a6)
	move.b	#%00101000,320(a6)
	move.b	(a0)+,321(a6)
	move.b	(a0)+,324(a6)
	move.b	#%00101000,325(a6)
	move.b	#%00101000,344(a6)
	move.b	#%00101000,361(a6)
	move.b	#%00101000,380(a6)
	move.b	#%00101000,397(a6)
	move.b	#%00101000,416(a6)
	move.b	#%00101000,433(a6)
	move.b	#%00101000,452(a6)
	move.b	#%00101000,469(a6)
	move.b	#%00101000,480(a6)
	move.b	(a0)+,481(a6)
	move.b	(a0)+,484(a6)
	move.b	#%00101000,485(a6)
	move.b	#%00101000,504(a6)
	move.b	#%00101000,521(a6)
	move.b	#%00101000,540(a6)
	move.b	#%00101000,557(a6)
	move.b	#%00101000,576(a6)
	move.b	#%00101000,593(a6)
	move.b	#%00101000,612(a6)
	move.b	#%00101000,629(a6)
	move.b	#%00101000,640(a6)
	move.b	(a0)+,641(a6)
	move.b	(a0)+,644(a6)
	move.b	#%00101000,645(a6)
	move.b	#%00101000,664(a6)
	move.b	#%00101000,681(a6)
	move.b	#%00101000,700(a6)
	move.b	#%00101000,717(a6)
	move.b	#%00101000,736(a6)
	move.b	#%00101000,753(a6)
	move.b	#%00101000,772(a6)
	move.b	#%00101000,789(a6)
	move.b	#%00101000,800(a6)
	move.b	#%00101000,805(a6)
	move.b	#%00101000,824(a6)
	move.b	#%00101000,841(a6)
	move.b	#%00101000,860(a6)
	move.b	#%00101000,877(a6)
	move.b	#%00101000,896(a6)
	move.b	#%00101000,913(a6)
	move.b	#%00101000,932(a6)
	move.b	#%00101000,949(a6)
	addq.w	#1,d7
	lea	160*6(a6),a6
	dbra	d6,skrivutkuldata
	moveq	#10,d7
liiiiiitetill:
	move.b	#%00101000,(a6)
	move.b	#%00101000,5(a6)
	move.b	#%00101000,24(a6)
	move.b	#%00101000,41(a6)
	move.b	#%00101000,60(a6)
	move.b	#%00101000,77(a6)
	move.b	#%00101000,96(a6)
	move.b	#%00101000,113(a6)
	move.b	#%00101000,132(a6)
	move.b	#%00101000,149(a6)
	move.b	#%00101000,160(a6)
	lea	160(a6),a6
	dbra	d7,liiiiiitetill

	rts
ingeneditorm”jlig:
	lea	full1,a5	; Inget minne kvar f”r fullsk„rmseditorn
	lea	full2,a6
	jsr	makejeppform
	rts

uppdateranup†eng†ng:
	dc.w	0
fulluppdatera:
	dc.w	0

fixaihopfulleditorn:
	tst.w	uppdateranup†eng†ng
	bne.s	b”rjauppdatera
	move.w	fulluppdatera,d0
	cmp.w	lastsongpatt,d0
	bne.s	b”rjauppdatera
	rts
b”rjauppdatera:
	move.w	lastsongpatt,fulluppdatera
	clr.w	uppdateranup†eng†ng

	tst.l	fulleditorpek
	beq.s	laddaupp8editorn4
	move.l	fulleditorpek,a6
	bra.s	klarrrrrrrrrrrt4
laddaupp8editorn4:
	move.l	editorpek,a6
	tst.w	falkrun
	bne.s	klarrrrrrrrrrrt4
	addq.l	#2,a6				; ()()() Ritar ut patternraderna p† r„tt bitplan
klarrrrrrrrrrrt4:
	moveq	#64-1,d7
	move.l	patterns,a4
	moveq	#0,d0
	move.w	lastsongpatt,d0
	asl.l	#8,d0
	asl.l	#3,d0
	add.l	d0,a4
skrivutenvissradifulleditmode:
	moveq	#0,d1
	lea	taltabell2,a5
	lea	tolkedbuffer,a3
	lea	tabelldata2,a2
	lea	12+160(a6),a6
k”rh†rti64rader:
	moveq	#4-1,d5
k”rh†rtradenut:
	move.w	(a4),d1
	move.w	d1,d2
	and.w	#%0000001111111100,d1
	and.w	#%1111000000000000,d2
	bne.s	ingen1attskrivautfed
	lea.l	jamnc1medtomhogsampling,a0
	bra.s	skriuten1afed
ingen1attskrivautfed:
	lea.l	jamnc1medenettahogsampling,a0
skriuten1afed:
	add.l	0(a2,d1.w),a0
	move.w	(a0)+,(a6)
	move.w	(a0)+,4(a6)
	move.w	(a0)+,160(a6)
	move.w	(a0)+,164(a6)
	move.w	(a0)+,320(a6)		; R„tt ton
	move.w	(a0)+,324(a6)
	move.w	(a0)+,480(a6)
	move.w	(a0)+,484(a6)
	move.w	(a0)+,640(a6)
	move.w	(a0)+,644(a6)

	moveq	#0,d1
	move.b	2(a4),d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a3,d1.w),a0
	move.w	(a0)+,8(a6)		; L†gsampling + kommando
	move.w	(a0)+,168(a6)
	move.w	(a0)+,328(a6)
	move.w	(a0)+,488(a6)
	move.w	(a0)+,648(a6)
	moveq	#0,d1
	move.b	3(a4),d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a3,d1.w),a0
	move.w	(a0)+,12(a6)		; Kommandodata
	move.w	(a0)+,12+160(a6)
	move.w	(a0)+,12+320(a6)
	move.w	(a0)+,12+480(a6)
	move.w	(a0)+,12+640(a6)

	move.w	4(a4),d1
	and.w	#%0000001111111100,d1
	lea	pekaretillvilkenton,a1
	move.l	0(a1,d1.w),a0
	move.b	(a0)+,17(a6)		; Ton
	move.b	(a0)+,17+160(a6)
	move.b	(a0)+,17+320(a6)
	move.b	(a0)+,17+480(a6)
	move.b	(a0)+,17+640(a6)
	lea	1024*4(a1),a1
	move.l	0(a1,d1.w),a0
	move.w	(a0)+,20(a6)		; Oktav
	move.w	(a0)+,20+160(a6)
	move.w	(a0)+,20+320(a6)
	move.w	(a0)+,20+480(a6)
	move.w	(a0)+,20+640(a6)

	move.w	4(a4),d2
	and.w	#%1111000000000000,d2
	bne.s	ingen2attskrivautfed
	lea	numberfont3,a0
	bra.s	skriuten2afed
ingen2attskrivautfed:
	lea	numberfont4,a0
skriuten2afed:
	moveq	#0,d0
	move.b	6(a4),d0
	and.b	#$f0,d0
	add.l	d0,a0
	move.w	(a0)+,24(a6)		; Sampling
	move.w	(a0)+,24+160(a6)
	move.w	(a0)+,24+320(a6)
	move.w	(a0)+,24+480(a6)
	move.w	(a0)+,24+640(a6)

	move.w	6(a4),d1
	and.w	#%111111110000,d1
	lsr.w	#2,d1
	move.l	0(a3,d1.w),a0
	move.w	(a0)+,28(a6)		; Kommando +  h”g kommandodata
	move.w	(a0)+,28+160(a6)
	move.w	(a0)+,28+320(a6)
	move.w	(a0)+,28+480(a6)
	move.w	(a0)+,28+640(a6)

	move.w	6(a4),d1
	and.w	#%1111,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a5,d1.w),a0
	move.b	(a0)+,32(a6)		; L†g kommandodata
	move.b	(a0)+,32+160(a6)
	move.b	(a0)+,32+320(a6)
	move.b	(a0)+,32+480(a6)
	move.b	(a0)+,32+640(a6)

	addq.w	#8,a4
	lea	36(a6),a6
	dbra	d5,k”rh†rtradenut
	lea	16+160*5(a6),a6
	dbra	d7,k”rh†rti64rader

	rts

thebigstack:
	ds.b	5*1024			; 5kb stack b”r r„cka
theendofstack:
medmus:	dc.w	%1111111111111111,%1111111111111111,0
	dc.w	%1111111111111111,%1111111111111111,0
	dc.w	%1111111111111111,%1111111111111100,0
	dc.w	%1111111111111111,%1111111111110000,0
	dc.w	%1111111111111111,%1111111111000000,0
	dc.w	%1111111111111111,%1111111100000000,0
	dc.w	%1111111111111111,%1111111000000000,0
	dc.w	%1111111111111111,%1111111111000000,0
	dc.w	%1111111111111111,%1111111111110000,0
	dc.w	%1111111111111111,%1111111111111100,0
	dc.w	%1111111111111111,%1111111111111111,0
	dc.w	%1111111111111111,%1111111111111100,0
	dc.w	%1111111100001111,%1111111111100000,0
	dc.w	%1111110000000011,%1111111100000000,0
	dc.w	%1111000000000000,%1111100000000000,0
	dc.w	%1100000000000000,%0010000000000000,0
	ds.w	96*15*2+96

;	END

