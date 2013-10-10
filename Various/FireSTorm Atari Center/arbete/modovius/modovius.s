
MAXMOD		EQU	20	; Maximalt antal moduler
RECORD		EQU	44	; 44 bytes header
VA_START	EQU	$4711	; VA_STARTmeddelande (se Gemini!)
CPUUPDATE	EQU	8	; 1/8 uppdateringshast. pÜ CPUlasten
BITMAPWIDTH	EQU	(9*8+2)	; 56 (Vidden i bytes)
UPDATEINONEGEM	EQU	8	; (Antal rader som skall uppdateras/GEMuppdatering)
AP_TERM		EQU	50	; Avsluta programmet
WM_ICONIFY	EQU	34
ICONIFIER	EQU	$4000
WM_ONTOP	EQU	31

	include	'modovius.i'
	include	'gemlib.i'
 	
	section	TEXT

	bra	 start
				; Variabler att kunna spara vid
				; vid instÑllningar
updatetime:			; Antal ms mellan uppdateringarna
	dc.w	20		; i GEMfînstret
updateonoff:
	dc.w	-1		; 0 = on   -1 = off
useemulatedtempo:
	dc.w	1		; Emulering av tempokontroll
infosize:
	dc.w	0		; 0 = litet fînster   -1 = stort fînster
colorbars:
	dc.w	0		; Visa fÑrger vid spelning
closebeforeload:		; 0 = StÑng ej  1 = StÑng
	dc.w	0
modules:
	rept	MAXMOD	; Max 20 fînster aktiva Üt gÜngen
	dc.w	-1	;   +0  Fînsterhandle (-1 inget fînster)
	dc.l	0	;   +2  Modulminnesarea (0 ingen area)
	ds.b	20	;   +6  Modulnamn (Filnamnet pÜ modulen)
	dc.w	4	;  +26  Antal kanaler (4/6/8)
	dc.l	0	;  +28  Antal bytes reserverade fîr modulen
	dc.w	0	;  +32  Divider (16/24/32 beroende pÜ kanalantal)
	dc.w	15	;  +34  Window X
	dc.w	50	;  +36  Window Y
	dc.w	0	;  +38  Window Width
	dc.w	0	;  +40  Window Height
	dc.w	0	;  +42  Window hidden (1=hidden, 0=showing)
	endr		; = 44 bytes

ctrlxy:	dc.w	100,50
controlhandle:		; Fînsterhandlet till controlfînstret
	dc.w	10

selectedUMP:
	dc.w	1	; 0 = 68k/DSP  1 = BLiTTER

path:	dc.b	'D:\MODDAR\4\*.MOD',0	; Pathen till modulerna
	ds.b	78
name:	dc.b	0		; Namn
	ds.b	79

;==========================================================================

start:
	cmp.l	#0,a7
	bne.s	stackfinns
	move.l	sp,oldst	; Installera stack om det inte finns
	lea	stack,sp
stackfinns:

	move.l	4(a7),basepage	; get address of base page in a1
	clr.w	noACC
	tst.l	4(a7)
	bne.s	harbasepage
	move.w	#1,noACC	; Startad som en ACC
	clr.b	wholename
	bra.s	skippinit
harbasepage:
	move.l	a7,a5
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
	trap	#1			; Registrera programet sÜ att
	lea	12(sp),sp		; vi kan begÑra minne...

	move.l	basepage,a1
	lea	$80(a1),a1	; get address of command tail
	moveq	#0,d2
	lea	wholename,a0
	lea	name,a2
	move.b	(a1)+,d2	; get length of string
	bsr	setstringfromkommando

	move.l	sp,oldst
	lea	stack,sp
skippinit:

	pea	DiskTransferAdress
	move.w	#26,-(sp)
	trap	#1			; SÑtt rÑtt DTA
	addq.w	#6,sp

	pea	kollaomMiNT
	move.w	#38,-(sp)
	trap	#14			; Finns MiNT mÜne?
	addq.l	#6,sp

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

	lea	modules,a0
	moveq	#MAXMOD-1,d0	; Inga inladdade moddar frÜn
fixatilltomt:			; bîrjan
	move.w	#-1,(a0)
	lea	RECORD(a0),a0
	dbra	d0,fixatilltomt

	bsr	appl_init		; Initera GEM
	tst.w	d0
	bmi	slutagenastdethÑrgÜrinte
	move.w	d0,application

	tst.w	noACC
	bne.s	installerasomACC
	tst.w	MiNTispresent		; Om MiNT, ersÑtt texten med
	beq.s	mintfinnsintealls	; vÜr egen i menyn
installerasomACC:
	move.l	d0,d1
	lea	MiNTmenutext,a1
	jsr	menu_register
	move.w	d0,menuID
	bmi	slutagenastdethÑrgÜrinte
mintfinnsintealls:
	bsr	makebusy

	lea	filename,a1
	bsr	rsrc_load		; Ladda in RSCfilen
	tst.w	d0
	bne.s	okvihittadeRSCfilen
	lea	notfoundstring,a1
	moveq	#1,d1			; Vi hittade inte filen, avsluta
	bsr	form_alert
	bra	avbrythelaGEM
okvihittadeRSCfilen:

	bsr	install_pointers
	bsr	open_work_station
	bsr	general_setup

	bsr	makearrow

	bsr	setupform
	bsr	check_window_vs_menu

	tst.w	noACC
	bne.s	inteenACC
	move.l	menupointer,a1
	moveq	#1,d1			; Visa menyn
	bsr	menu_bar
inteenACC:

	tst.w	controlhandle
	bmi.s	inteîppnacontrollen
	bsr	createCONTROL
inteîppnacontrollen:

	tst.b	wholename		; NÜgon kommandorad?
	beq.s	vÑntapÜmeddelanden	; Isf ladda in modulen
	bsr	load_a_mod		; Spela modulen
	bsr	play_current
	bsr	check_window_vs_menu
vÑntapÜmeddelanden:
	move.w	action,d0		; Kolla om vi tryckt pÜ en tang.
	and.w	#MU_KEYBD,d0
	beq	nokeyboard
runkeys:
	clr.w	action

;	lea	test+8,a0
;	move.w	keybd,d0		; keybd
;	move.w	d0,d1
;	and.w	#$F,d1
;	lsr.w	#4,d0
;	add.w	#'0',d1
;	move.b	d1,-(a0)
;	move.w	d0,d1
;	and.w	#$F,d1
;	lsr.w	#4,d0
;	add.w	#'0',d1
;	move.b	d1,-(a0)
;	move.w	d0,d1
;	and.w	#$F,d1
;	lsr.w	#4,d0
;	add.w	#'0',d1
;	move.b	d1,-(a0)
;	move.w	d0,d1
;	and.w	#$F,d1
;	lsr.w	#4,d0
;	add.w	#'0',d1
;	move.b	d1,-(a0)
;	lea	test,a1
;	moveq	#1,d1
;	bsr	form_alert

	lea	fastkeys,a0
	move.w	(a0)+,d0
	move.w	keybd,d1
checkiffastkey:
	cmp.w	(a0),d1		; Leta efter en giltig tangent
	beq.s	ensnabbistang
	addq.w	#6,a0
	dbra	d0,checkiffastkey
	bsr	showHELP
	bra.s	nokeyboard
ensnabbistang:

	move.l	menupointer,a1
	move.w	2(a0),d0
	mulu	#SIZE_OBJECT,d0
	move.w	OB_STATE(a1,d0.w),d0
	and.w	#DISABLED,d0
	bne.s	nokeyboard

	move.w	#MN_SELECTED,messbuffer
	move.w	4(a0),messbuffer+6
	move.w	2(a0),messbuffer+8

	move.l	menupointer,a1
	move.w	4(a0),d1
	moveq	#0,d2
	bsr	menu_tnormal		; Visa menynnormalt igen

	bra	scanmessages
nokeyboard:

	tst.w	controlhandle
	bmi.s	intemusknapp
	move.w	action,d0
	and.w	#MU_BUTTON,d0		; Trycktes en musknapp?
	beq.s	intemusknapp
	bra	checkCONTROL
intemusknapp:

	move.w	action,d0		; Timer?
	and.w	#MU_TIMER,d0
	beq.s	notthetimer
	tst.l	current_playing_mod
	beq.s	notthetimer
	bsr	shownewinfo
notthetimer:

	bsr	evnt_multi		; Kolla meddelande + tang.
	move.w	d0,action
	move.w	d5,keybd

	move.w	action,d0		; Meddelande?
	and.w	#MU_MESAG,d0
	beq	vÑntapÜmeddelanden

scanmessages:
	clr.w	windupdate

	cmp.w	#VA_START,messbuffer	; VA_START?
	bne.s	inteenvastart
	move.l	messbuffer+6,d0
	beq.s	inteenvastart
	move.l	d0,a0
	move.l	a0,a1
	moveq	#0,d2
find_length:
	tst.b	(a0)+			; Hitta lÑngden pÜ strÑngen
	beq.s	hittat_lÑngden
	addq.w	#1,d2
	bra.s	find_length
hittat_lÑngden:
	lea	wholename,a0		; Fixa till kommandoraden
	lea	name,a2
	bsr	setstringfromkommando	
	tst.b	wholename		; NÜgon kommandorad?
	beq.s	inteenvastart		; Isf ladda in modulen
	tst.w	closebeforeload
	beq.s	intestÑnga
	bsr	closeshit
intestÑnga:
	bsr	load_a_mod		; Spela modulen
	tst.w	d0
	bne.s	noplay
	bsr	play_current
noplay:	bsr	check_window_vs_menu
inteenvastart:

	cmp.w	#WM_ICONIFY,messbuffer	; Gîm ett fînster
	bne.s	integîmmaettfînster
	move.w	messbuffer+6,d0
	bsr	hidethiswindow
integîmmaettfînster:

	cmp.w	#WM_CLOSED,messbuffer	; StÑng en modul
	bne.s	intedîdaOctan
close_it:
	move.w	#1,windupdate
	moveq	#1,d1			; Uppdatera
	bsr	wind_update
	move.l	menupointer,a1
	move.w	#FILEMENU,d1
	moveq	#0,d2
	bsr	menu_tnormal		; Visa menyn vald
	move.w	messbuffer+6,d0		; Fînsterhandlet
	cmp.w	controlhandle,d0
	bne.s	hejhopp			; StÑnga control-fînstret?
	bsr	killCONTROL
	bra	contrldîd
hejhopp:
	bsr	find_mod		; VÑlj om aktiv modul
	move.w	messbuffer+6,d0
	bsr	kill_window		; Ta bort fînstret
	move.l	current_mod,a0
	move.w	#-1,(a0)		; Markera ledigt pos i fînsterlistan
	move.l	2(a0),d0
	bsr	slÑpp_minne		; SlÑpp modulminne
contrldîd:
	move.w	#FILEMENU,messbuffer+6
	bsr	check_window_vs_menu
	bsr	fixloadedmods
	bra	intequitsomvarvald
intedîdaOctan:

	cmp.w	#WM_MOVED,messbuffer	; Dax att flytta fînstret?
	bne	inteflyttapÜvÜratfînster
	move.w	messbuffer+6,d0
	cmp.w	controlhandle,d0
	bne.s	flyttaintecontrollen
	move.l	messbuffer+8,ctrlxy	; Kom ihÜg fînsterpos
	bsr	movewindowout
	bra.s	inteflyttapÜvÜratfînster
flyttaintecontrollen:
	bsr	find_mod
	move.l	current_mod,a0
	tst.w	42(a0)
	bne.s	inteflyttapÜvÜratfînster
	move.l	messbuffer+8,34(a0)	; Kom ihÜg fînsterpos
	move.l	messbuffer+12,38(a0)
	bsr	movewindowout
inteflyttapÜvÜratfînster:

	cmp.w	#30,messbuffer		; WM_UNTOPPED
	bne.s	inteuntopped
	bsr	check_window_vs_menu
inteuntopped:


	cmp.w	#WM_REDRAW,messbuffer
	bne	interitaomfînsterinfon	; Dax att rita om i fînstret?
	move.w	messbuffer+6,d0
	cmp.w	controlhandle,d0
	bne.s	intectrl
	move.w	#1,wasctrl
	move.w	d0,window_handle
	bra.s	draaaaaaaaaaaaaaaw
intectrl:
	tst.l	current_playing_mod
	beq.s	interitaomfînsterinfon
	move.l	current_playing_mod,a0
	move.w	(a0),window_handle
	move.w	window_handle,d0
	cmp.w	messbuffer+6,d0
	bne	interitaomfînsterinfon
draaaaaaaaaaaaaaaw:
	moveq	#1,d1
	bsr	wind_update
	bsr	redrawpartofwindow
	moveq	#0,d1
	bsr	wind_update
	clr.w	wasctrl
interitaomfînsterinfon:

	cmp.w	#WM_ONTOP,messbuffer	; Toppa menyn under MagiC
	bne.s	intefÜmenynattvisas
	tst.w	MagX
	beq.s	intefÜmenynattvisas
	bsr	fixmenuunderMagiC
	bsr	check_window_vs_menu
intefÜmenynattvisas:

	cmp.w	#WM_TOPPED,messbuffer
	bne.s	intetoppafînstret	; Dax att placera fînstret fîrst?
	lea	aespb,a0
	move.w	#105,$18(a0)
	move.w	#6,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	messbuffer+6,$30(a0)
	move.w	#WF_TOP,$32(a0)
	jsr	callaes		; SÑtt fînstret hîgst!
	bsr	check_window_vs_menu
intetoppafînstret:

	cmp.w	#WM_FULLED,messbuffer	; WM_FULLED
	bne.s	intevÑxlavisamod
	bsr	vaxlavisamod
intevÑxlavisamod:

	cmp.w	#AC_OPEN,messbuffer	; AC_OPEN?
	bne.s	notopenedACC
	move.w	menuID,d0
	cmp.w	messbuffer+8,d0
	bne.s	notopenedACC
	bsr	get_used_mods
	tst.w	d0
	beq.s	îppnavidare
	cmp.w	d0,d3
	beq.s	îppnavidare
	bsr	showallhiddenwindows
	bra.s	notopenedACC
îppnavidare:
	bsr	open_new_mod
	bsr	check_window_vs_menu
notopenedACC:

	cmp.w	#AC_CLOSE,messbuffer	; AC_CLOSE?
	bne.s	notreinstallWindows
	bsr	reinstallthousewindows
notreinstallWindows:

	cmp.w	#AP_TERM,messbuffer
	beq	avslutaprogrammet

	cmp.w	#MN_SELECTED,messbuffer	; ér det ett menymeddelande?
	bne	vÑntapÜmeddelanden


	cmp.w	#MINFO,messbuffer+8	; VERSION?
	bne.s	intevisainfon
	bsr	show_version
intevisainfon:

	cmp.w	#PAUS,messbuffer+8	; PAUS?
	bne.s	intepausa
	bsr	pausanu
intepausa:

	cmp.w	#MGENERAL,messbuffer+8
	bne.s	integeneral		; MGENERAL?
	bsr	setupform
	bsr	general
integeneral:

	cmp.w	#MLOAD,messbuffer+8	; MLOAD?
	bne.s	inteîppnaennymodd
	bsr	open_new_mod
	bsr	check_window_vs_menu
inteîppnaennymodd:

	cmp.w	#MCLOSE,messbuffer+8	; MCLOSE
	bne.s	intestÑngfînster
	bsr	get_aktiv_window
	bmi.s	intestÑngfînster
	move.w	d7,messbuffer+6
	bra	close_it
intestÑngfînster:

	cmp.w	#MNEXT,messbuffer+8	; MNEXT
	bne.s	intenextwind
	bsr	cyklewindow
	bsr	check_window_vs_menu
intenextwind:

	cmp.w	#GOM,messbuffer+8	; GOM
	bne.s	gominte
	bsr	get_aktiv_window
	move.l	current_mod,a0
	move.w	(a0),d0
	bsr	hidethiswindow
gominte:

	cmp.w	#GOMD,messbuffer+8	; GOMD
	bne.s	visainte
	bsr	showallhiddenwindows
	bsr	check_window_vs_menu
visainte:

	cmp.w	#MSTOPPIT,messbuffer+8
	bne.s	intestoppmodden		; MSTOPPIT
	bsr	kill_current_player
	bsr	check_window_vs_menu
intestoppmodden:

	cmp.w	#MAKTUELL,messbuffer+8	; MAKTUELL
	bne.s	intespelaaktuellmodul
	bsr	play_current
	bsr	check_window_vs_menu
intespelaaktuellmodul:

	cmp.w	#MFORWARD,messbuffer+8	; MFORWARD
	bne.s	inteforward
	pea	forwarder
	move.w	#38,-(sp)
	trap	#14
	addq.w	#6,sp
inteforward:

	cmp.w	#MBAKWARD,messbuffer+8	; MBAKWARD
	bne.s	intebackward
	pea	backwarder
	move.w	#38,-(sp)
	trap	#14
	addq.w	#6,sp
intebackward:


	cmp.w	#MQUIT,messbuffer+8	; QUIT?
	bne.s	intequitsomvarvald
direktquit:
	tst.w	noACC			; Inte kunna avsluta en ACC
	bne.s	intequitsomvarvald
	tst.l	current_playing_mod
	beq.s	avslutaprogrammet
	move.l	quitalert,a1
	moveq	#2,d1			; Vill anvÑndaren verkligen
	bsr	form_alert		; avsluta hela programmet?
	cmp.w	#1,d0
	beq	avslutaprogrammet
intequitsomvarvald:
	move.l	menupointer,a1
	move.w	messbuffer+6,d1
	moveq	#1,d2
	bsr	menu_tnormal		; Visa menynnormalt igen
	tst.w	windupdate
	beq	vÑntapÜmeddelanden
	moveq	#0,d1
	bsr	wind_update
	bra	vÑntapÜmeddelanden
avslutaprogrammet:
	move.l	menupointer,a0
	moveq	#0,d1			; Sluta visa menyn
	bsr	menu_bar

	bsr	kill_current_player

	tst.w	controlhandle
	bmi.s	ingetcontrolfînster
	bsr	killCONTROL
ingetcontrolfînster:

	lea	modules,a6
	moveq	#MAXMOD-1,d7
kill_all:
	tst.w	(a6)			; Ta bort alla anvÑnda fînster
	bmi.s	kill_on
	move.w	(a6),d0
	bsr	kill_window		; Ta bort fînstret
	move.l	2(a6),d0
	bsr	slÑpp_minne		; SlÑpp modulminne
kill_on:lea	RECORD(a6),a6
	dbra	d7,kill_all

	bsr	removeupdate

	tst.w	windupdate
	beq	kîrvidare
	moveq	#0,d1
	bsr	wind_update
kîrvidare:

	bsr	close_work_station
	bsr	rsrc_free		; SlÑpp RSCfilen i minnet
avbrythelaGEM:
	bsr	appl_exit		; SlÑpp GEM

slutagenastdethÑrgÜrinte:
	move.l	oldst,sp

	clr.w	-(sp)
	trap	#1			; Avsluta programmet

nameofapp:
	dc.b	'SCRENMGR',0,0
aesmsg:	dc.w	0,0,0,0,0,0,0,0

fixmenuunderMagiC:
	moveq	#1,d1			; Uppdatera
	bsr	wind_update
	lea	aespb,a0
	move.w	#13,$18(a0)
	move.w	#0,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.l	#nameofapp,$230(a0)
	jsr	callaes		; appl_find
	lea	aespb,a0
	move.w	$430(a0),d0	; AP-ID
	bmi.s	skippppppppppppp

	lea	aesmsg,a1
	move.w	#101,(a1)+
	move.w	application,(a1)+
	move.w	#0,(a1)+
	move.w	#0,(a1)+	; Ordna till ett meddelande
	move.l	#'MAGX',(a1)+
	move.w	#2,(a1)+
	move.w	application,(a1)+

	move.w	#12,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.w	d0,$30(a0)
	move.w	#16,$32(a0)
	move.l	#aesmsg,$230(a0)
	jsr	callaes		; appl_write
skippppppppppppp:
	moveq	#0,d1			; Uppdatera
	bsr	wind_update
	rts

checkCONTROL:
	move.w	d1,-(sp)
	move.w	d2,-(sp)
	lea	aespb,a0
	move.w	#104,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#5,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	controlhandle,$30(a0)
	move.w	#WF_WORKXYWH,$32(a0)
	jsr	callaes		; Ta reda pÜ fînsterkoordinaterna
	lea	aespb,a0
	move.l	controlpointer,a3
	move.l	$432(a0),OB_X(a3)
	move.w	(sp),d2
	move.w	2(sp),d1
	bsr	wind_find
	move.w	(sp)+,d4
	move.w	(sp)+,d3
	cmp.w	controlhandle,d0	; i controlfînstret?
	bne.s	ingetkuliCONTROL2
	move.l	controlpointer,a1
	moveq	#0,d1
	moveq	#3,d2
	bsr	objc_find
hittat:
	clr.w	keybd
	cmp.w	#BAK,d0
	bne.s	ejbak1
	move.w	#$3000,keybd
ejbak1:	cmp.w	#FRAM,d0
	bne.s	ejfram1
	move.w	#$2100,keybd
ejfram1:cmp.w	#NYMOD,d0
	bne.s	ejny1
	move.w	#$180F,keybd
ejny1:	cmp.w	#STOPP,d0
	bne.s	ejsto1
	move.w	#$1F00,keybd
ejsto1:	cmp.w	#PAUSA,d0
	bne.s	ejpaus1
	move.w	#$1910,keybd
ejpaus1:
	tst.w	keybd
	beq.s	ingetkuliCONTROL
	bra	runkeys
ingetkuliCONTROL:
	bra	intemusknapp

ingetkuliCONTROL2:	; Kolla om vi klickade i spelande fînster
	move.w	d3,-(sp)
	move.w	d4,-(sp)
	tst.l	current_playing_mod
	beq.s	ingetkuliCONTROL	; Spelar vi nÜgon modul?
	tst.w	updateonoff
	bne.s	ingetkuliCONTROL
	tst.w	infosize		; Spelar vi med pattervisare?
	bpl.s	ingetkuliCONTROL
	move.l	current_playing_mod,a0
	move.w	(a0),d0
	lea	aespb,a0
	move.w	#104,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#5,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	d0,$30(a0)
	move.w	#WF_WORKXYWH,$32(a0)
	jsr	callaes		; Ta reda pÜ fînsterkoordinaterna
	lea	aespb,a0
	move.l	biggplay,a3
	move.l	$432(a0),OB_X(a3)
	move.w	(sp),d2
	move.w	2(sp),d1
	bsr	wind_find
	move.w	(sp)+,d4
	move.w	(sp)+,d3
	moveq	#0,d7
	move.w	d3,d7
	move.l	current_playing_mod,a0
	move.w	(a0),d1
	cmp.w	d1,d0		; i aktuellt spelarfînster?
	bne	ingetkuliCONTROL
	move.l	biggplay,a1
	moveq	#0,d1
	moveq	#3,d2
	bsr	objc_find
	cmp.w	#BLITAREA,d0
	blt	ingetkuliCONTROL
	move.l	biggplay,a0
	move.w	#BLITAREA,d0
	mulu	#SIZE_OBJECT,d0
	sub.w	OB_X(a0,d0.w),d7
	sub.w	OB_X(a0),d7
	sub.w	#16,d7
	bmi	intemusknapp
	divu	#9*8,d7			; Vilken kanal
	add.w	d7,d7
	lea	chanel1onoff,a0
	not.w	(a0,d7.w)		; VÑxla kanal pÜ/av
	bra	intemusknapp


hidethiswindow:
	move.l	messbuffer+6,-(sp)
	bsr	find_mod
	move.l	current_mod,a0
	move.w	(a0),messbuffer+6
	move.w	#1,42(a0)		; Gîm fînstret
	bsr	cyklasnabbt
	bsr	check_window_vs_menu
	move.l	#$10001000,messbuffer+8
	move.l	#$10001000,messbuffer+12
	bsr	movewindowout
	move.l	(sp)+,messbuffer+6
	rts

showallhiddenwindows:
	move.l	messbuffer+6,-(sp)
	moveq	#MAXMOD-1,d7
	lea	modules,a6
checkall:
	tst.w	(a6)
	bmi.s	ingetattha
	tst.w	42(a6)
	beq.s	ingetattha
	clr.w	42(a6)
	move.w	(a6),messbuffer+6
	move.l	34(a6),messbuffer+8
	move.l	38(a6),messbuffer+12
	bsr	movewindowout
ingetattha:
	lea	RECORD(a6),a6
	dbra	d7,checkall
	move.l	(sp)+,messbuffer+6
	rts

movewindowout:
	move.l	messbuffer+8,fx
	move.l	messbuffer+12,fx+4
	lea	aespb,a0
	move.w	#105,$18(a0)
	move.w	#6,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	messbuffer+6,$30(a0)
	move.w	#WF_CURRXYWH,$32(a0)
	move.l	fx,$34(a0)
	move.l	fx+4,$38(a0)
	jsr	callaes		; Flytta fînstret
	lea	aespb,a0
	move.w	#104,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#5,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	window_handle,$30(a0)
	move.w	#WF_WORKXYWH,$32(a0)
	jsr	callaes		; Ta reda pÜ fînsterkoordinaterna
	lea	aespb,a0
	move.l	$432(a0),fx
	move.l	$436(a0),fx+4
	move.l	noupdate,a2
	move.l	biggplay,a1
	move.l	playing,a0	; Fixa till sÜ objectet ligger vid
	move.l	fx,OB_X(a0)	; fînstret
	move.l	fx,OB_X(a1)
	move.l	fx,OB_X(a2)
	rts

forwarder:
	move.w	#$2700,sr
;	clr.w	direction
;	move.b	#1,break
	not.w	chosedmap2
	move.b	songpos,d0
	addq.b	#1,d0
	cmp.b	songlength,d0
	blt.s	vscvkmvsk
	move.b	songrestart,d0
vscvkmvsk:
	move.b	d0,songpos
	clr.w	pattpos
	move.w	#$2300,sr
	rts

backwarder:
	move.w	#$2700,sr
;	move.w	#1,direction
;	move.b	#1,break
	not.w	chosedmap2
	subq.b	#1,songpos
	bpl.s	okkfsdf
	clr.b	songpos
okkfsdf:
	clr.w	pattpos
	move.w	#$2300,sr
	rts

closeshit:
	tst.l	current_mod
	beq.s	nomodsloaded
	bsr	kill_current_player
	move.l	current_mod,a0
	move.w	(a0),d0
	bsr	kill_window		; Ta bort fînstret
	move.l	current_mod,a0
	move.w	#-1,(a0)		; Markera ledigt pos i fînsterlistan
	move.l	2(a0),d0
	bsr	slÑpp_minne		; SlÑpp modulminne
	move.w	#FILEMENU,messbuffer+6
	bsr	check_window_vs_menu
	bsr	fixloadedmods
nomodsloaded:
	rts

vaxlavisamod:
	move.w	messbuffer+6,d0
	bsr	find_mod
	tst.l	current_playing_mod
	beq.s	inteÑndraspelarfînstret
	move.l	current_playing_mod,a0
	move.l	current_mod,a1
	move.w	(a0),d0
	move.w	(a1),d1
	cmp.w	d1,d0
	bne.s	inteÑndraspelarfînstret
	tst.w	updateonoff
	beq.s	on
	clr.w	updateonoff
	bra.s	off
on:	tst.w	infosize
	bmi.s	slÜavupp
	move.w	#-1,infosize
	bra.s	off
slÜavupp:
	clr.w	infosize
	move.w	#-1,updateonoff
off:
changewindow:
	bsr	removeupdate
	move.l	playing,d0
	tst.w	infosize
	beq.s	intestooor
	move.l	biggplay,d0
	bsr	installupdate
	tst.w	d7
	bmi.s	vaxlavisamod
intestooor:
	move.l	current_playing_mod,a0
	move.l	(a0),window_handle
	bsr	set_size
	moveq	#0,d0
	bsr	updatethisareaofwindow2
	rts
inteÑndraspelarfînstret:
	bsr	kill_current_player
	move.w	messbuffer+6,d0
	bsr	find_mod
	bsr	letsrockandstuff
	bsr	check_window_vs_menu
	rts

installupdate:
	tst.l	mstart
	bne	norestart14
	movem.l	d0-d6/a0-a6,-(sp)
	move.l	#6*64*2*BITMAPWIDTH,d0
	move.w	nrofrows,d1
	lsr.w	#1,d1
	addq.w	#2,d1
	mulu	#6*BITMAPWIDTH,d1
	move.l	d1,d6
	mulu	#3,d1
	add.l	d1,d0
	add.l	#4096+1184+512+256+2368+4096,d0
	move.l	d0,d7
	bsr	fÜ_minne		; BegÑr minne till uppdateringsarea
	beq	failed
	move.l	d0,a0
	move.l	d0,mstart
	move.l	d0,pekarsteg2+4
	move.l	d0,pekarsteg2+8
	move.l	d0,pekarsteg1+8
	add.l	#4096,d0		; Ordna till pekarna
	move.l	d0,pekarsteg1
	add.l	#1184,d0
	move.l	d0,pekarsteg1+4
	add.l	#512,d0
	move.l	d0,pekarsteg1+12
	add.l	#256,d0
	move.l	d0,pekarsteg2
	add.l	#2368+2,d0
	move.l	d0,taltabell
	add.l	#4096,d0
	move.l	d0,bitmap1
	add.l	#BITMAPWIDTH*6*64+2+6*BITMAPWIDTH*2,d0
	add.l	d6,d0
	move.l	d0,bitmap2
	lsr.l	#2,d7
	subq.w	#1,d7
	moveq	#0,d0
clearthebuffers:			; Rensa bufferna
	move.l	d0,(a0)+
	dbra	d7,clearthebuffers

ehhh:
	move.l	bitmap1(pc),source
	subq.l	#2,source

	bsr	fixfonts
	bsr	drawbitmapfromstart

	movem.l	(sp)+,d0-d6/a0-a6
norestart14:
	moveq	#0,d7
	rts
failed:	movem.l	(sp)+,d0-d6/a0-a6
	moveq	#-1,d0
	rts

removeupdate:
	tst.l	mstart
	beq.s	failedagain
	move.l	mstart,d0
	bsr	slÑpp_minne		; SlÑpp minne fîr uppdatering
	clr.l	mstart
	moveq	#0,d0
	rts
failedagain:
	moveq	#-1,d0
	rts

fixfonts:
	move.l	raktalbuffer,a0		; 00-FF
	lea	font,a1
	moveq	#0,d0
	move.w	#256-1,d7
fixaraktalbuffer:
	move.w	d0,d1
	move.w	d0,d2
	and.w	#$F0,d1
	lsr.w	#4,d1
	and.w	#$F,d2
	lsl.w	#3,d1
	lsl.w	#3,d2
	lea	(a1,d1.w),a2
	lea	(a1,d2.w),a3
	move.b	(a2)+,(a0)+
	move.b	(a3)+,(a0)+
	move.b	(a2)+,(a0)+
	move.b	(a3)+,(a0)+
	move.b	(a2)+,(a0)+
	move.b	(a3)+,(a0)+
	move.b	(a2)+,(a0)+
	move.b	(a3)+,(a0)+
	move.b	(a2)+,(a0)+
	move.b	(a3)+,(a0)+
	addq.w	#3*2,a0
	addq.w	#1,d0
	dbra	d7,fixaraktalbuffer

	move.l	pekarsteg1+12(pc),a0
	moveq	#0,d0
	move.w	#16-1,d7
fixa1_:
	move.w	d0,d1
	and.w	#$0F,d1
	lsl.w	#3,d1
	lea	(a1,d1.w),a2
	move.b	(a2)+,(a0)+
	clr.b	(a0)+
	move.b	(a2)+,(a0)+
	clr.b	(a0)+
	move.b	(a2)+,(a0)+
	clr.b	(a0)+
	move.b	(a2)+,(a0)+
	clr.b	(a0)+
	move.b	(a2)+,(a0)+
	clr.b	(a0)+
	addq.w	#3*2,a0
	addq.w	#1,d0
	dbra	d7,fixa1_

	move.l	pekarsteg1+4(pc),a0
	moveq	#0,d0
	move.w	#16-1,d7
fixa_F:
	move.w	d0,d1
	and.w	#$0F,d1
	lsl.w	#3,d1
	lea	(a1,d1.w),a2
	clr.b	(a0)+
	move.b	(a2)+,(a0)+
	clr.b	(a0)+
	move.b	(a2)+,(a0)+
	clr.b	(a0)+
	move.b	(a2)+,(a0)+
	clr.b	(a0)+
	move.b	(a2)+,(a0)+
	clr.b	(a0)+
	move.b	(a2)+,(a0)+
	addq.w	#3*2,a0
	addq.w	#1,d0
	dbra	d7,fixa_F

	moveq	#0,d0
	move.w	#16-1,d7
fixa1F:
	move.w	d0,d1
	and.w	#$0F,d1
	lsl.w	#3,d1
	lea	(a1,d1.w),a2
	lea	font+8,a3
	move.b	(a3)+,(a0)+
	move.b	(a2)+,(a0)+
	move.b	(a3)+,(a0)+
	move.b	(a2)+,(a0)+
	move.b	(a3)+,(a0)+
	move.b	(a2)+,(a0)+
	move.b	(a3)+,(a0)+
	move.b	(a2)+,(a0)+
	move.b	(a3)+,(a0)+
	move.b	(a2)+,(a0)+
	addq.w	#3*2,a0
	addq.w	#1,d0
	dbra	d7,fixa1F

	move.l	pekarsteg1(pc),a0
	lea	middle,a1
	clr.b	(a0)+
	move.b	(a1),(a0)+
	move.b	(a1),(a0)+
	move.b	(a1)+,(a0)+
	clr.b	(a0)+
	move.b	(a1),(a0)+
	move.b	(a1),(a0)+
	move.b	(a1)+,(a0)+
	clr.b	(a0)+
	move.b	(a1),(a0)+
	move.b	(a1),(a0)+
	move.b	(a1)+,(a0)+
	clr.b	(a0)+
	move.b	(a1),(a0)+
	move.b	(a1),(a0)+
	move.b	(a1)+,(a0)+
	clr.b	(a0)+
	move.b	(a1),(a0)+
	move.b	(a1),(a0)+
	move.b	(a1)+,(a0)+
	lea	12(a0),a0
	moveq	#3-1,d1			; _C#2
	lea	font+8,a1
loop11:	moveq	#12-1,d0
	lea	style,a2
loop12:	move.b	(a2)+,d2
	move.w	d2,d3
	and.w	#$F0,d2
	lsr.w	#4,d2
	and.w	#$F,d3
	lsl.w	#3,d2
	lsl.w	#3,d3
	lea	signs,a4
	add.w	d3,a4
	lea	middle,a3
	add.w	d2,a3
	move.l	a1,a5
	clr.b	(a0)+
	move.b	(a4)+,(a0)+
	move.b	(a3)+,(a0)+
	move.b	(a5)+,(a0)+
	clr.b	(a0)+
	move.b	(a4)+,(a0)+
	move.b	(a3)+,(a0)+
	move.b	(a5)+,(a0)+
	clr.b	(a0)+
	move.b	(a4)+,(a0)+
	move.b	(a3)+,(a0)+
	move.b	(a5)+,(a0)+
	clr.b	(a0)+
	move.b	(a4)+,(a0)+
	move.b	(a3)+,(a0)+
	move.b	(a5)+,(a0)+
	clr.b	(a0)+
	move.b	(a4)+,(a0)+
	move.b	(a3)+,(a0)+
	move.b	(a5)+,(a0)+
	lea	12(a0),a0
	dbra	d0,loop12
	addq.w	#8,a1
	dbra	d1,loop11

	move.l	pekarsteg2(pc),a0
	lea	middle,a1
	move.b	(a1),(a0)+
	move.b	(a1),(a0)+
	move.b	(a1)+,(a0)+
	clr.b	(a0)+
	move.b	(a1),(a0)+
	move.b	(a1),(a0)+
	move.b	(a1)+,(a0)+
	clr.b	(a0)+
	move.b	(a1),(a0)+
	move.b	(a1),(a0)+
	move.b	(a1)+,(a0)+
	clr.b	(a0)+
	move.b	(a1),(a0)+
	move.b	(a1),(a0)+
	move.b	(a1)+,(a0)+
	clr.b	(a0)+
	move.b	(a1),(a0)+
	move.b	(a1),(a0)+
	move.b	(a1)+,(a0)+
	clr.b	(a0)+
	lea	12(a0),a0
	moveq	#3-1,d1			; C#21
	lea	font+8,a1
loop21:	moveq	#12-1,d0
	lea	style,a2
loop22:	move.b	(a2)+,d2
	move.w	d2,d3
	and.w	#$F0,d2
	lsr.w	#4,d2
	and.w	#$F,d3
	lsl.w	#3,d2
	lsl.w	#3,d3
	lea	signs,a4
	add.w	d3,a4
	lea	middle,a3
	add.w	d2,a3
	move.l	a1,a5
	move.b	(a4)+,(a0)+
	move.b	(a3)+,(a0)+
	move.b	(a5)+,(a0)+
	clr.b	(a0)+
	move.b	(a4)+,(a0)+
	move.b	(a3)+,(a0)+
	move.b	(a5)+,(a0)+
	clr.b	(a0)+
	move.b	(a4)+,(a0)+
	move.b	(a3)+,(a0)+
	move.b	(a5)+,(a0)+
	clr.b	(a0)+
	move.b	(a4)+,(a0)+
	move.b	(a3)+,(a0)+
	move.b	(a5)+,(a0)+
	clr.b	(a0)+
	move.b	(a4)+,(a0)+
	move.b	(a3)+,(a0)+
	move.b	(a5)+,(a0)+
	clr.b	(a0)+
	lea	12(a0),a0
	dbra	d0,loop22
	addq.w	#8,a1
	dbra	d1,loop21

	lea	middle,a1
	lea	font+8,a2
	move.b	(a1),(a0)+
	move.b	(a1),(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a2)+,(a0)+
	move.b	(a1),(a0)+
	move.b	(a1),(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a2)+,(a0)+
	move.b	(a1),(a0)+
	move.b	(a1),(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a2)+,(a0)+
	move.b	(a1),(a0)+
	move.b	(a1),(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a2)+,(a0)+
	move.b	(a1),(a0)+
	move.b	(a1),(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a2)+,(a0)+
	lea	12(a0),a0
	moveq	#3-1,d1			; C#21
	lea	font+8,a1
loop31:	moveq	#12-1,d0
	lea	style,a2
loop32:	move.b	(a2)+,d2
	move.w	d2,d3
	and.w	#$F0,d2
	lsr.w	#4,d2
	and.w	#$F,d3
	lsl.w	#3,d2
	lsl.w	#3,d3
	lea	signs,a4
	add.w	d3,a4
	lea	middle,a3
	add.w	d2,a3
	move.l	a1,a5
	lea	font+8,a6
	move.b	(a4)+,(a0)+
	move.b	(a3)+,(a0)+
	move.b	(a5)+,(a0)+
	move.b	(a6)+,(a0)+
	move.b	(a4)+,(a0)+
	move.b	(a3)+,(a0)+
	move.b	(a5)+,(a0)+
	move.b	(a6)+,(a0)+
	move.b	(a4)+,(a0)+
	move.b	(a3)+,(a0)+
	move.b	(a5)+,(a0)+
	move.b	(a6)+,(a0)+
	move.b	(a4)+,(a0)+
	move.b	(a3)+,(a0)+
	move.b	(a5)+,(a0)+
	move.b	(a6)+,(a0)+
	move.b	(a4)+,(a0)+
	move.b	(a3)+,(a0)+
	move.b	(a5)+,(a0)+
	move.b	(a6)+,(a0)+
	lea	12(a0),a0
	dbra	d0,loop32
	addq.w	#8,a1
	dbra	d1,loop31

; Nu Ñr fontena klara. LÜt oss nu fixa till en pekartabell som hÑnvisar
; till vilken offset som skall anvÑndas inom frekvensfonsterna

	move.l	taltabell,a0
	moveq	#32,d0
	lea	periods,a2
	moveq	#36-1,d1	; Antal toner
fixatilltonoffsetter:
	move.w	(a2)+,d2
	and.w	#%1111111111111100,d2
	move.w	d0,(a0,d2.w)
	add.w	#32,d0
	dbra	d1,fixatilltonoffsetter

	rts

;
;  Denna rutin skriver ut data fullstÑndigt till hela bitmappen
;
drawbitmapfromstart:
	tst.l	mstart
	beq	nodrawingtodohere
	move.w	antalkanaler,d0
	lsr.w	#1,d0
	subq.w	#1,d0			; Ange antal kanalpar
	move.w	d0,kanalpar
	moveq	#0,d6		; Bîrja med radnummer 0
	move.l	bitmap1,a6	; Fîrsta bildminnet
	move.w	nrofrows,d0
	lsr.w	#1,d0
	mulu	#6*BITMAPWIDTH,d0
	add.w	d0,a6		; Fixa till offsetten
	move.l	patterns,a0	; Aktuell patterndata
	move.l	song,a1
	moveq	#0,d0
	moveq	#0,d1
	move.b	lastsongpos,d0		; d0 vart i songen vi ligger
	move.l	song,a1
	move.b	0(a1,d0.w),d1		; Vilket pattern skall spelas nu?
	move.b	d1,map1
	moveq	#64,d0
	mulu	divider,d0
	mulu	d0,d1
	add.l	d1,a0		; R‰tt pattern
	move.w	kanalpar,d7
	moveq	#64-1,d5	; Antal rader att skriva ut nu
fixfirstpart:
	move.w	d6,d0		; Radnummer
	bsr	burstonerowwithnumbers
	lea	6*BITMAPWIDTH(a6),a6
	addq.w	#1,d6
	dbra	d5,fixfirstpart
	moveq	#0,d6		; Bîrja med radnummer 0
	move.l	bitmap2,a6	; Fîrsta bildminnet
	move.w	nrofrows,d0
	lsr.w	#1,d0
	mulu	#6*BITMAPWIDTH,d0
	add.w	d0,a6		; Fixa till offsetten
	move.l	patterns,a0	; Aktuell patterndata
	move.l	song,a1
	moveq	#0,d0
	moveq	#0,d1
	move.b	lastsongpos,d0		; d0 vart i songen vi ligger
	move.l	song,a1
	move.b	0(a1,d0.w),d1		; Vilket pattern skall spelas nu?
	move.b	d1,map2
	moveq	#64,d0
	mulu	divider,d0
	mulu	d0,d1
	add.l	d1,a0		; R‰tt pattern
	move.w	kanalpar,d7
	moveq	#64-1,d5	; Antal rader att skriva ut nu
fixsecondpart:
	move.w	d6,d0		; Radnummer
	bsr	burstonerowwithnumbers
	lea	6*BITMAPWIDTH(a6),a6
	addq.w	#1,d6
	dbra	d5,fixsecondpart
	clr.w	chosedmap2
	clr.w	chosedmap		; Bitmap 1 innehÂller aktuellt pattern
	move.l	bitmap1(pc),a0
	move.b	map1(pc),d0
	move.w	nrofrows(pc),d1
	lsr.w	#1,d1
	mulu	#6*BITMAPWIDTH,d1
	add.l	d1,a0
	lea	-8*BITMAPWIDTH(a0),a0
	and.w	#$FF,d0
	lsl.w	#4,d0
	move.l	raktalbuffer(pc),a1
	add.w	d0,a1
	move.w	(a1)+,(a0)
	move.w	(a1)+,BITMAPWIDTH(a0)
	move.w	(a1)+,2*BITMAPWIDTH(a0)
	move.w	(a1)+,3*BITMAPWIDTH(a0)
	move.w	(a1)+,4*BITMAPWIDTH(a0)
	move.l	bitmap2(pc),a0
	move.b	map2(pc),d0
	move.w	nrofrows(pc),d1
	lsr.w	#1,d1
	mulu	#6*BITMAPWIDTH,d1
	add.l	d1,a0
	lea	-8*BITMAPWIDTH(a0),a0
	and.w	#$FF,d0
	lsl.w	#4,d0
	move.l	raktalbuffer(pc),a1
	add.w	d0,a1
	move.w	(a1)+,(a0)
	move.w	(a1)+,BITMAPWIDTH(a0)
	move.w	(a1)+,2*BITMAPWIDTH(a0)
	move.w	(a1)+,3*BITMAPWIDTH(a0)
	move.w	(a1)+,4*BITMAPWIDTH(a0)
nodrawingtodohere:
	rts

;
;  Att kolla upp:
;
;   Kan man ersÑtta move.w med movem istÑllet fîr att spara tid?
;   LÑgga in talet 4 fîr att spara tid vid shiftningarna?
;   lea fram bitmappekaren istÑllet fîr att anvÑnda offseter?
;   AnvÑnds den sista raden i fonten? Eller kan man skippa den moven?
;

;
;  Denna rutin skriver ut en rad av patterndata till bitmappen
;  a6 = bildminne  d0 = radnummer  a0 = sourcepatterndata  d7 = antal kanalpar-1
burstonerowwithnumbers:		; Skriver ut med radnummer
	move.l	taltabell(pc),a5
	lsl.w	#4,d0
	move.l	raktalbuffer,a1			; BerÑkna pekare till radnummret
	add.w	d0,a1
	move.w	(a1)+,-2(a6)
	move.w	(a1)+,BITMAPWIDTH-2(a6)		; Rita ut talet pÜ bitmappen
	move.w	(a1)+,2*BITMAPWIDTH-2(a6)
	move.w	(a1)+,3*BITMAPWIDTH-2(a6)
	move.w	(a1)+,4*BITMAPWIDTH-2(a6)

fasterthanlight:		; Skriver ut utan radnummer
	movem.l	a6/d7,-(sp)

pair:	move.l	(a0)+,d0			; HÑmta fˆrsta/nÑsta patterndatan
	move.l	d0,d1
	and.w	#$F,d0				; LÜgbit kommandodata
	lsr.w	#4,d1
	move.l	d1,d2
	and.w	#$FF,d1				; Kommando + hîg
	lsr.w	#8,d2
	swap.w	d1
	move.w	d1,d3
	and.w	#$F000,d1
	beq.s	ejhîgsampling1
	add.w	#$10,d2				; Ordna till samplingsnummret
ejhîgsampling1:
	swap.w	d1
	and.w	#%0000111111111100,d3		; Ordna till frekvensen
	move.w	(a5,d3.w),d3

	movem.l	pekarsteg1(pc),a1-a4
	lsl.w	#4,d0				; RÑkna fram pekarna
	lsl.w	#4,d1
	lsl.w	#4,d2
	add.w	d0,a4
	add.w	d1,a3
	add.w	d2,a2
	add.w	d3,a1

	move.l	(a1)+,(a6)+			; Flytta ut till bitmappen
	move.w	(a2)+,(a6)+
	move.w	(a3)+,(a6)+
	move.w	(a4)+,(a6)+
	move.l	(a1)+,BITMAPWIDTH-10(a6)
	move.w	(a2)+,BITMAPWIDTH-6(a6)
	move.w	(a3)+,BITMAPWIDTH-4(a6)
	move.w	(a4)+,BITMAPWIDTH-2(a6)
	move.l	(a1)+,2*BITMAPWIDTH-10(a6)
	move.w	(a2)+,2*BITMAPWIDTH-6(a6)
	move.w	(a3)+,2*BITMAPWIDTH-4(a6)
	move.w	(a4)+,2*BITMAPWIDTH-2(a6)
	move.l	(a1)+,3*BITMAPWIDTH-10(a6)
	move.w	(a2)+,3*BITMAPWIDTH-6(a6)
	move.w	(a3)+,3*BITMAPWIDTH-4(a6)
	move.w	(a4)+,3*BITMAPWIDTH-2(a6)
	move.l	(a1)+,4*BITMAPWIDTH-10(a6)
	move.w	(a2)+,4*BITMAPWIDTH-6(a6)
	move.w	(a3)+,4*BITMAPWIDTH-4(a6)
	move.w	(a4)+,4*BITMAPWIDTH-2(a6)

	move.l	(a0)+,d0			; NÑsta patterndata
	move.l	d0,d1
	and.w	#$FF,d0			; Hîg + lÜg
	move.l	d1,d2
	lsr.w	#8,d1
	swap.w	d2
	swap.w	d0
	and.w	#%0000111111111100,d2
	move.w	(a5,d2.w),d2
	and.w	#$F000,d0
	beq.s	ejhîgsampling2
	add.w	#37*4*8,d2
ejhîgsampling2:
	swap.w	d0

	movem.l	pekarsteg2(pc),a1-a3
	lsl.w	#4,d0
	lsl.w	#4,d1
	add.w	d0,a3			; Ordna till pekare
	add.w	d1,a2
	add.w	d2,a1

	move.l	(a1)+,(a6)+
	move.w	(a2)+,(a6)+
	move.w	(a3)+,(a6)+
	move.l	(a1)+,BITMAPWIDTH-8(a6)
	move.w	(a2)+,BITMAPWIDTH-4(a6)
	move.w	(a3)+,BITMAPWIDTH-2(a6)
	move.l	(a1)+,2*BITMAPWIDTH-8(a6)
	move.w	(a2)+,2*BITMAPWIDTH-4(a6)
	move.w	(a3)+,2*BITMAPWIDTH-2(a6)
	move.l	(a1)+,3*BITMAPWIDTH-8(a6)
	move.w	(a2)+,3*BITMAPWIDTH-4(a6)
	move.w	(a3)+,3*BITMAPWIDTH-2(a6)
	move.l	(a1)+,4*BITMAPWIDTH-8(a6)
	move.w	(a2)+,4*BITMAPWIDTH-4(a6)
	move.w	(a3)+,4*BITMAPWIDTH-2(a6)

	dbra	d7,pair

	movem.l	(sp)+,a6/d7
runempty:
	rts

chosedmap:			; Bitmap som innehÂller aktuellt pattern
	dc.w	0		; 0 = bitmap 1    1 = bitmap2
chosedmap2:
	dc.w	0
map1:	dc.b	0
map2:	dc.b	0
taltabell:
	dc.l	0
kanalpar:
	dc.w	0
pairdummy:
	dc.w	0
nrofrows:
	dc.w	20	; Antal rader - 1 som bitmappen skall innehÜlla
bitmap1:dc.l	0	; Pekar mot den fîrsta bitmappen
bitmap2:dc.l	0	; Pekar mot den andra bitmappen

raktalbuffer:		; Pekar mot den raka talbuffern (00-FF)
mstart:	dc.l	0

pekarsteg1:		; _C#21FC21
	dc.l	0	; Pekare mot _C#2 (frekvens)
	dc.l	0	; Pekare mot 1F	(samplingsnummer)
	dc.l	0	; Pekare mot C2 (raka talbuffer)
	dc.l	0	; Pekare mot 1_ (lÜg kommandodata)

pekarsteg2:		; C#21FC21
	dc.l	0	; Pekare mot C#21 (frekvens + hîg sampling)
	dc.l	0	; Pekare mot FC (LÜg sampling + kommando)
	dc.l	0	; Pekare mot 21 (Hîg + lÜg kommandodata)

CPU:	dc.w	0

chooseblitt:
	dc.w	0

cleararea:		; Pekare till utritade VUmetrar
	ds.l	8
clearlength:		; LÑngd pÜ utritade VUmetrar
	ds.w	8

posnu:	dc.w	$90

;
;  Den h‰r rutinen ser till att blitta bitmappen, scrolla den och uppdatera dem
;
visastort:
	moveq	#0,d0
	move.w	lastpos,d0		; Fixa till r‰tt offset i bitmappen
	bpl.s	ok
	moveq	#0,d0
ok:
	divu	divider,d0
	mulu	#6*BITMAPWIDTH,d0
	move.l	bitmap1(pc),d3
	tst.w	chosedmap
	beq.s	rattval			; V‰lj bitmap att visa
	move.l	bitmap2(pc),d3
rattval:add.l	d0,d3
	subq.l	#2,d3
	move.l	d3,source		; Bitmapspekare att visa

	move.w	nrofrows,d0
	lsr.w	#1,d0
	addq.w	#1,d0
	mulu	#6*BITMAPWIDTH,d0
	add.l	d3,d0			; Mitten till rÑtt bitmap

	addq.l	#4,d0
	move.l	d0,a0			; Pekare till VUtstart
	lea	VU1,a1			; VUmeter
	move.w	antalkanaler,d1
	subq.w	#1,d1			; Antal kanaler att fixa
	lea	cleararea(pc),a2
	lea	clearlength(pc),a3
	lea	hejhooooooooop(pc),a4
	lea	chanel1onoff,a5
fixatillVUen:
	move.w	(a1)+,d2
	tst.w	(a5)+
	bmi.s	kanalenÑrpÜ
	moveq	#0,d2
kanalenÑrpÜ:
	lsr.w	#1,d2
	add.w	d2,d2
	add.w	d2,d2
	neg.w	d2
	move.w	d2,(a3)+
	move.l	a0,(a2)+
	jmp	(a4,d2.w)
	not.b	-32*BITMAPWIDTH(a0)
	not.b	-31*BITMAPWIDTH(a0)
	not.b	-30*BITMAPWIDTH(a0)
	not.b	-29*BITMAPWIDTH(a0)
	not.b	-28*BITMAPWIDTH(a0)
	not.b	-27*BITMAPWIDTH(a0)
	not.b	-26*BITMAPWIDTH(a0)
	not.b	-25*BITMAPWIDTH(a0)
	not.b	-24*BITMAPWIDTH(a0)
	not.b	-23*BITMAPWIDTH(a0)
	not.b	-22*BITMAPWIDTH(a0)
	not.b	-21*BITMAPWIDTH(a0)
	not.b	-20*BITMAPWIDTH(a0)
	not.b	-19*BITMAPWIDTH(a0)
	not.b	-18*BITMAPWIDTH(a0)
	not.b	-17*BITMAPWIDTH(a0)
	not.b	-16*BITMAPWIDTH(a0)
	not.b	-15*BITMAPWIDTH(a0)
	not.b	-14*BITMAPWIDTH(a0)
	not.b	-13*BITMAPWIDTH(a0)
	not.b	-12*BITMAPWIDTH(a0)
	not.b	-11*BITMAPWIDTH(a0)
	not.b	-10*BITMAPWIDTH(a0)
	not.b	-9*BITMAPWIDTH(a0)
	not.b	-8*BITMAPWIDTH(a0)
	not.b	-7*BITMAPWIDTH(a0)
	not.b	-6*BITMAPWIDTH(a0)
	not.b	-5*BITMAPWIDTH(a0)
	not.b	-4*BITMAPWIDTH(a0)
	not.b	-3*BITMAPWIDTH(a0)
	not.b	-2*BITMAPWIDTH(a0)
	not.b	-1*BITMAPWIDTH(a0)
hejhooooooooop:
	not.b	(a0)
	add.w	#9,a0
	dbra	d1,fixatillVUen

	move.w	redrawoption,d1		; Uppdatera
	bsr	wind_update
	tst.w	d0
	beq.s	quitedrawlocked

	moveq	#BLITAREA,d0
	move.w	#1,chooseblitt
	bsr	updatethisareaofwindow
	clr.w	chooseblitt

	move.b	lastsongpos,d0
	cmp.b	posnu(pc),d0
	beq.s	behîvsinteÑndras
	move.l	biggplay,a1
	moveq	#POS,d2
	mulu	#SIZE_OBJECT,d2
	move.l	OB_SPEC(a1,d2),a0
	move.l	(a0),a0
	move.b	d0,posnu
	move.b	d0,d1
	and.w	#$F0,d0
	lsr.w	#4,d0
	and.w	#$F,d1
	lea	conver(pc),a3
	move.b	(a3,d0.w),(a0)+
	move.b	(a3,d1.w),(a0)+
	clr.b	(a0)+
	moveq	#POS,d0
	bsr	updatethisareaofwindow
behîvsinteÑndras:

	moveq	#$0,d1			; Sluta upppdatera
	bsr	wind_update
quitedrawlocked:

	lea	hejhooooooooop2(pc),a4
	lea	cleararea(pc),a2
	lea	clearlength(pc),a3
	move.w	antalkanaler,d1
	subq.w	#1,d1
tabort:	move.l	(a2)+,a0
	move.w	(a3)+,d2
	jmp	(a4,d2.w)
	not.b	-32*BITMAPWIDTH(a0)
	not.b	-31*BITMAPWIDTH(a0)
	not.b	-30*BITMAPWIDTH(a0)
	not.b	-29*BITMAPWIDTH(a0)
	not.b	-28*BITMAPWIDTH(a0)
	not.b	-27*BITMAPWIDTH(a0)
	not.b	-26*BITMAPWIDTH(a0)
	not.b	-25*BITMAPWIDTH(a0)
	not.b	-24*BITMAPWIDTH(a0)
	not.b	-23*BITMAPWIDTH(a0)
	not.b	-22*BITMAPWIDTH(a0)
	not.b	-21*BITMAPWIDTH(a0)
	not.b	-20*BITMAPWIDTH(a0)
	not.b	-19*BITMAPWIDTH(a0)
	not.b	-18*BITMAPWIDTH(a0)
	not.b	-17*BITMAPWIDTH(a0)
	not.b	-16*BITMAPWIDTH(a0)
	not.b	-15*BITMAPWIDTH(a0)
	not.b	-14*BITMAPWIDTH(a0)
	not.b	-13*BITMAPWIDTH(a0)
	not.b	-12*BITMAPWIDTH(a0)
	not.b	-11*BITMAPWIDTH(a0)
	not.b	-10*BITMAPWIDTH(a0)
	not.b	-9*BITMAPWIDTH(a0)
	not.b	-8*BITMAPWIDTH(a0)
	not.b	-7*BITMAPWIDTH(a0)
	not.b	-6*BITMAPWIDTH(a0)
	not.b	-5*BITMAPWIDTH(a0)
	not.b	-4*BITMAPWIDTH(a0)
	not.b	-3*BITMAPWIDTH(a0)
	not.b	-2*BITMAPWIDTH(a0)
	not.b	-1*BITMAPWIDTH(a0)
hejhooooooooop2:
	not.b	(a0)
	dbra	d1,tabort

	tst.w	runningupdate		; Dax att uppdatera bitmappen?
	bne	koruppdateringredan
	moveq	#0,d0
	move.b	lastsongpos(pc),d0	; d0 vart i songen vi ligger
	addq.b	#1,d0
	cmp.b	songlength,d0
	bne.s	alltinomramen
	move.b	songrestart,d0
alltinomramen:
	move.l	song,a1
	move.b	0(a1,d0.w),d0		; Vilket pattern skall spelas n‰sta gÂng?
	tst.w	chosedmap
	beq.s	ejojÑmn2
	cmp.b	map1,d0			; Redan uppdaterat?
	beq	ingennyuppdatering
	move.b	d0,map1
	clr.w	kîrt
	move.w	#1,runningupdate
	move.l	bitmap1,bitmappek
	move.w	nrofrows(pc),d1
	lsr.w	#1,d1
	mulu	#6*BITMAPWIDTH,d1
	add.l	d1,bitmappek
	moveq	#64,d1
	mulu	divider,d1
	mulu	d1,d0
	add.l	patterns,d0
	move.l	d0,patternpek
	move.l	bitmappek(pc),a0
	move.b	map1(pc),d0
	bra.s	fixaîvretal		; Bˆrja uppdatera
ejojÑmn2:
	cmp.b	map2,d0			; Redan uppdaterat?
	beq	ingennyuppdatering
	move.b	d0,map2
	clr.w	kîrt
	move.w	#1,runningupdate
	move.l	bitmap2,bitmappek
	move.w	nrofrows(pc),d1
	lsr.w	#1,d1
	mulu	#6*BITMAPWIDTH,d1
	add.l	d1,bitmappek
	moveq	#64,d1
	mulu	divider,d1
	mulu	d1,d0
	add.l	patterns,d0
	move.l	d0,patternpek
	move.l	bitmappek(pc),a0
	move.b	map2(pc),d0
fixaîvretal:			; Skriver ut vilket pattern det hÑr Ñr
	lea	-8*BITMAPWIDTH(a0),a0
	and.w	#$FF,d0
	lsl.w	#4,d0
	move.l	raktalbuffer(pc),a1
	add.w	d0,a1
	move.w	(a1)+,(a0)
	move.w	(a1)+,BITMAPWIDTH(a0)
	move.w	(a1)+,2*BITMAPWIDTH(a0)
	move.w	(a1)+,3*BITMAPWIDTH(a0)
	move.w	(a1)+,4*BITMAPWIDTH(a0)
koruppdateringredan:
	move.l	patternpek(pc),a0
	move.l	bitmappek(pc),a6
	move.w	kanalpar(pc),d7
	move.w	kîrt(pc),d6
	move.w	d6,d4
	moveq	#UPDATEINONEGEM,d5
	add.w	d5,d6
	cmp.w	#64,d6
	ble.s	kîrfulluppdatering
	sub.w	#63,d6
	move.w	d6,d5
	clr.w	runningupdate		; N‰sta varv ‰r uppdateringen klar
kîrfulluppdatering:
	subq.w	#1,d5
	move.w	d6,kîrt
	move.w	d4,d6
	move.l	taltabell(pc),a5
	move.l	raktalbuffer,a1
running:
	bsr	fasterthanlight
	lea	BITMAPWIDTH*6(a6),a6	; Ny rad
	dbra	d5,running
	cmp.w	#64,kîrt
	blt.s	intefÑrdigt
	clr.w	runningupdate
intefÑrdigt:
	move.l	a6,bitmappek
	move.l	a0,patternpek
ingennyuppdatering:

	rts

patternpek:
	dc.l	0			; Pekar mot pattern som uppdateras
bitmappek:
	dc.l	0			; Pekar mot bitmapp som uppdateras
kîrt:	dc.w	0			; Hur mÂnga rader som uppdaterats

runningupdate:
	dc.w	0	; Talar om om en uppdatering hÂller pÂ att ske

extra1:	dc.b	0,0,0
extra2:	dc.b	0,0,0
extra3:	dc.b	0,0,0
	even
blittwidth:
	dc.w	0

blitt:
	move.w	#129,contrl
	move.w	#2,contrl+2
	move.w	#1,contrl+6
	move.w	handle,contrl+$c
	move.w	#1,global		; SÑtt igÜng clippen
	movem.w	fx,d0-d3
	move.w	d0,intin
	move.w	d1,intin+2
	add.w	d0,d2
	add.w	d1,d3
	movem.w	d0-d3,pxyarea
	subq.w	#1,d2
	subq.w	#1,d3
	move.w	d2,intin+4
	move.w	d3,intin+6
	lea	aespb,a0
	jsr	callaes2		; Klipp igÜng nu
	move.l	blitarea,a4
	move.l	biggplay,a3
	move.w	OB_X(a3),d4
	move.w	OB_Y(a3),d5
	add.w	OB_X(a4),d4
	add.w	OB_Y(a4),d5
	move.w	d4,d6
	move.w	d5,d7
	add.w	blittwidth,d6		; Vidden pÂ blitten
	add.w	OB_HEIGHT(a4),d7
	move.w	#1,global		; Writingmode
	move.l	#source,contrl+$e	; Source
	move.l	#dest,contrl+$12	; Dest
	move.w	#2,global+2		; Col1
	move.w	#0,global+4		; Col0
	move.w	#4,contrl+2
	move.w	#3,contrl+6
	move.w	handle,contrl+$c	; Handle
	move.w	#$79,contrl
	move.w	#0,intin		; x1
	move.w	#0,intin+2		; y1
	move.w	blittwidth,intin+4		; x2 503
	cmp.w	#8,antalkanaler
	bne.s	sjkfmsjdk
	move.w	#607,intin+4		; x2
sjkfmsjdk:
	move.w	OB_HEIGHT(a4),intin+6	; y2
	move.w	d4,intin+8		; x1
	move.w	d5,intin+10		; y1
	move.w	d6,intin+12		; x2
	move.w	d7,intin+14		; y2
	movem.w	pxyarea2,d0-d7
	cmp.w	d6,d0
	bgt.s	pausabaramusen
	cmp.w	d7,d1
	bgt.s	pausabaramusen
	cmp.w	d2,d4
	bgt.s	pausabaramusen
	cmp.w	d3,d5
	bgt.s	pausabaramusen
	move.w	#1,inside
	dc.w	$a00a
	bra.s	goooooooooo
pausabaramusen:
	move.w	#1,pausmouse
goooooooooo:
	lea	aespb,a0
	jsr	callaes2
	clr.w	pausmouse
	tst.w	inside
	beq.s	intevisaalls
	dc.w	$a009
	clr.w	inside
intevisaalls:
	bra	behîverinteritanÜge

dest:	dc.l	0	; Blitta till bildminnet
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0

source:	dc.l	0		; Pekare till objektet
	dc.w	BITMAPWIDTH*8	; Width
	dc.w	176		; Height
	dc.w	BITMAPWIDTH/2	; Width in words
	dc.w	1		; Format flag
	dc.w	1		; BitPlanes
	dc.w	0		; Reserved1
	dc.w	0		; Reserved2
	dc.w	0		; Reserved3


shownewinfo:
	tst.w	infosize
	bne	visastort
	subq.w	#1,CPU
	bpl.s	donthavetoredraw2
	move.w	#CPUUPDATE,CPU
	move.w	cpuload,d0
	neg.w	d0
	add.w	#245,d0
	move.l	playing,a1
	moveq	#BASE,d2
	mulu	#SIZE_OBJECT,d2
	mulu	OB_WIDTH(a1,d2.w),d0
	divu	#245,d0
	move.l	playing,a1
	moveq	#PERCENT,d2
	mulu	#SIZE_OBJECT,d2
	cmp.w	OB_WIDTH(a1,d2),d0
	beq.s	donthavetoredraw2
	move.w	d0,OB_WIDTH(a1,d2)
	moveq	#BASE,d0
	bsr	updatethisareaofwindow
donthavetoredraw2:
	lea	extra4(pc),a2
	lea	conver(pc),a0
	moveq	#0,d0
	move.b	songpos,d0
	lsr.w	#4,d0
	move.b	(a0,d0.w),d1
	move.b	d1,(a2)+
	move.b	songpos,d0
	and.w	#$F,d0
	move.b	(a0,d0.w),d2
	move.b	d2,(a2)+
	move.w	lastpos,d0
	divu	divider,d0
	lsr.w	#4,d0
	move.b	(a0,d0.w),d3
	move.b	d3,(a2)+
	move.w	lastpos,d0
	divu	divider,d0
	and.w	#$F,d0
	move.b	(a0,d0.w),d4
	move.b	d4,(a2)+
	move.l	playing,a0
	moveq	#POSITION,d0
	mulu	#SIZE_OBJECT,d0
	move.l	OB_SPEC(a0,d0),a0
	move.l	(a0),a0
	cmp.b	(a0),d1
	bne.s	upppppppppdatera
	cmp.b	1(a0),d2
	bne.s	upppppppppdatera
	cmp.b	3(a0),d3
	bne.s	upppppppppdatera
	cmp.b	4(a0),d4
	beq.s	skitupppppppppdatera
upppppppppdatera:
	move.b	d1,(a0)+
	move.b	d2,(a0)+
	move.b	#':',(a0)+
	move.b	d3,(a0)+
	move.b	d4,(a0)+
	clr.b	(a0)+
	moveq	#POSITION,d0
	bsr	updatethisareaofwindow
skitupppppppppdatera:
	rts

conver:	dc.b	'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'
divider:dc.w	16
extra4:	dc.b	0,0,0,0

kill_if_current_playing:	; d0 fînsterhandle
	tst.l	current_playing_mod
	beq.s	nokill
	move.l	current_playing_mod,a0
	cmp.w	(a0),d0
	beq.s	kill_current_player
nokill:	rts
kill_current_player:			; Stoppa aktuell spelare
	tst.l	current_playing_mod
	beq.s	nothing_to_kill
	move.l	current_playing_mod,a0
	move.w	(a0),window_handle

	move.w	#13,-(sp)
	move.w	#26,-(sp)
	trap	#14			; StÑng av timer A
	addq.w	#4,sp

	pea	deinstallUMP
	move.w	#38,-(sp)
	trap	#14
	addq.w	#6,sp			; Deinstallera UMPn

	move.l	playarea,d0
	bsr	slÑpp_minne		; SlÑpp minne anvÑnt av UMPn
	clr.l	playarea

	bsr	removeupdate

	tst.w	settheheight
	bne.s	nope
	moveq	#0,d0
	bsr	set_height
nope:
	clr.l	current_playing_mod
nothing_to_kill:
	rts

deinstallUMP:
	move.w	#$2700,sr
	move.l	oldVBL+2(pc),$70.w
	and.b	#$0F,$fffffa1d.w	; Stoppa timer C
	move.b	#$c0,$fffffa23.w		; Ny data till timer C
	or.b	#$50,$fffffa1d.w	; Kîr vidare med timer C
	move.l	oldtimerC1+2(pc),$114.w	; Tillbaka till systemets timer C
	move.b	#%11111111,$fffffa15.w
	move.w	#$2300,sr
	move.l	aktivUMP,a2
	jsr	8(a2)			; StÑng av UMPn
	rts

pausanu:				; Pausar musiken
	moveq	#1,d2
	not.w	paused
	bmi.s	ingencheckning
	moveq	#0,d2
ingencheckning:
	move.l	menupointer,a1
	move.w	#PAUS,d1	; Next Window
	bsr	menu_icheck
	rts

paused:	dc.w	0		; 0 = ej pausad   -1 = pausad

current_playing_mod:
	dc.l	0
aktivUMP:
	dc.l	0

play_current:				; Spela aktuell modul
	bsr	get_aktiv_window
	bmi	playimpossible
	move.l	current_mod,a0
	move.w	26(a0),d0	; Antal kanaler
	bsr	kill_current_player	; Stoppa aktuell spelare
	bmi	playimpossible
	bsr	get_aktiv_window
	bmi	playimpossible
letsrockandstuff:
	pea	check_interupts
	move.w	#38,-(sp)
	trap	#14
	addq.w	#6,sp			; Koll om uppspelning Ñr mîjlig
	cmp.w	#TIMER,d0
	beq	timererror
	cmp.w	#DMA,d0
	beq	dmaerror
	bsr	makebusy
	move.l	current_mod,a0
	move.l	a0,current_playing_mod
	move.w	(a0),window_handle
	move.w	26(a0),antalkanaler
	move.l	2(a0),a1
	move.l	a1,d0
	add.l	#952,d0			; SÑtt upp vÑrden fîr
	move.l	d0,song			; musikhanteraren
	move.b	950(a1),songlength
	move.b	951(a1),songrestart
	move.w	#6,speed
	move.w	#125,tempo
	move.l	#12500,tempoadder
	clr.l	temporÑknare
	move.w	#$ff,counter
	clr.w	pattpos
	clr.b	songpos
	clr.b	lastsongpos
	clr.w	lastsongpatt
	clr.w	lastpos
	clr.w	newlooppattpos
	clr.b	newloopsongpos
	clr.w	newloopwhichpatt
	clr.w	loopingpartofpatt
	move.l	a1,d0
	add.l	#1084,d0
	move.l	d0,patterns
	move.l	a1,d0
	add.l	#20-8,d0
	move.l	d0,modsam
	move.l	current_playing_mod,a0
	move.l	2(a0),a1
	lea	920(a1),a4		; Sista samplingsinfon i a4
	move.l	28(a0),d2		; LÑngden i d2
	add.l	a1,d2
	lea	samplestarts+31*4,a5	; Samplebîrjan i a5
	moveq	#31-1,d0
calculatesamplestarts:
	move.l	16(a4),-(a5)
	lea	-30(a4),a4
	dbra	d0,calculatesamplestarts
	move.w	32(a0),divider
	cmp.w	#4,26(a0)
	bne.s	inte4senread
	move.w	#$400,senread+2
inte4senread:
	cmp.w	#6,26(a0)
	bne.s	inte6senread
	move.w	#$600,senread+2
inte6senread:
	cmp.w	#8,26(a0)
	bne.s	inte8senread
	move.w	#$800,senread+2
inte8senread:
inst:

	tst.w	selectedUMP		; Vilken UMP skall anvÑndas?
	beq.s	anvÑndMAIN
	move.l	#2000*2+900*16,d0	; AnvÑnd Blittern
	move.l	#BLiTTER4+28,aktivUMP
	bra.s	anvÑnderBLiTTER
anvÑndMAIN:				; AnvÑnd Lance
	move.l	#360000,d0		; 358 522
	move.l	#UMP8,aktivUMP
	cmp.w	#4,26(a0)
	bne.s	inte4kanalersstuk
	move.l	#200000,d0		; 196 230
	move.l	#UMP4,aktivUMP
inte4kanalersstuk:
anvÑnderBLiTTER:
	bsr	fÜ_minne		; BegÑr minne fîr UMP-area
	beq	slutpÜminnet
	move.l	d0,playarea

	lea	AmigatoUMP,a6
	moveq	#100,d2			; Amiga-frekvens
	move.w	#900-1,d0		; Antal toner
	moveq	#0,d4
beraknatoner:
	move.l	#3546895,d3
	divu	d2,d3			; BerÑkna frekvens i Herz
	swap	d3
	move.w	d4,d3
	divu	#50066,d3
	and.l	#$FFFF,d3		; Konvertera till UMPfrekvens
	move.l	d3,(a6)+
	addq.w	#1,d2
	dbra	d0,beraknatoner
	move.l	#-1,(a6)+

	pea	installUMP
	move.w	#38,-(sp)
	trap	#14
	addq.w	#6,sp			; Installera UMPn

	lea	AmigatoUMP,a0
	moveq	#0,d0
	move.w	#900-1,d1		; Fixa till konverteringstabellen
fixatillkonverteringstabell:
	move.w	d0,(a0)+
	addq.w	#4,d0
	dbra	d1,fixatillkonverteringstabell

	pea	start_interupts
	move.w	#38,-(sp)
	trap	#14
	addq.w	#6,sp			; Starta uppspelningen

	move.w	#(9*4+2)*8-1,blittwidth	; Blittwidth fˆr 4 kanaler
	move.w	#320,d1
	move.w	#28*16,source+4
	cmp.w	#6,antalkanaler
	bne.s	inte6igt
	move.w	#464,d1
	move.w	#(9*6+2)*8-1,blittwidth	; Blittwidth fˆr 6 kanaler
inte6igt:
	cmp.w	#8,antalkanaler
	bne.s	kîrmedmindrefînster
	move.w	#(9*8+2)*8-1,blittwidth	; Blittwidth fˆr 8 kanaler
	move.w	#608,d1
	move.w	#36*16,source+4
kîrmedmindrefînster:	
	move.l	biggplay,a0
	move.w	d1,OB_WIDTH(a0)		; SÑtt bigplay till rÑtt storlek
	move.w	#BLITAREA,d0
	mulu	#SIZE_OBJECT,d0
	move.w	blittwidth,d1
	addq.w	#1,d1
	move.w	d1,OB_WIDTH(a0,d0.w)
	move.w	#INDICATO,d0
	mulu	#SIZE_OBJECT,d0
	addq.w	#8,d1
	move.w	d1,OB_WIDTH(a0,d0.w)

	move.l	playing,a1
	move.w	OB_HEIGHT(a1),d0
	bsr	set_height

	move.l	current_playing_mod,a0
	move.l	2(a0),a3
	move.b	950(a3),d2
	move.l	biggplay,a1
	moveq	#LENGTH,d1
	mulu	#SIZE_OBJECT,d1
	move.l	OB_SPEC(a1,d1),a2	; Visa lÑngden
	bsr	fixittohex
	move.b	951(a3),d2
	moveq	#RESTART,d1
	mulu	#SIZE_OBJECT,d1
	move.l	OB_SPEC(a1,d1),a2	; Visa restarten
	bsr	fixittohex
	move.l	28(a0),d0
	moveq	#MODBYTES,d1
	mulu	#SIZE_OBJECT,d1
	move.l	OB_SPEC(a1,d1),a2	; Visa minnesÜtgÜng
	bsr	fixbytes
	moveq	#SONGNAME,d1
	mulu	#SIZE_OBJECT,d1
	move.l	OB_SPEC(a1,d1),a2
	move.l	noupdate,a4
	moveq	#SONGNAM2,d1
	mulu	#SIZE_OBJECT,d1
	move.l	OB_SPEC(a4,d1),a4
	bsr	fixaanamnet		; Visar songnamnet
playimpossible:
	bsr	makearrow
	rts

fixbytes:
	lea	10(a2),a2
	clr.b	-(a2)
	divu    #10000,D0
	movea.w	d0,a4           ;put d0 in a4 for later use
	move.w	#2,d5
tree_last:
	clr.w	d0
	swap	d0
	divu	#10,d0
	swap	d0
	add.b	#'0',d0
	move.b	d0,-(a2)
	dbra	d5,tree_last
	move.b	#'.',-(a2)
	clr.w	d0
	swap	d0
	divu	#10,d0
	swap	d0
	add.b	#'0',d0
	move.b	d0,-(a2)
	move.w	a4,d0
	swap	d0
	move.w	#1,d5
two_first:
	clr.w	d0
	swap	d0
	divu	#10,d0
	swap	d0
	add.b	#'0',d0
	move.b	d0,-(a2)
	dbra	d5,two_first
	move.b	#'.',-(a2)
	clr.w	d0
	swap	d0
	divu	#10,d0
	swap	d0
	add.b	#'0',d0
	move.b	d0,-(a2)
	rts

fixaanamnet:			; Kopierar 20 bytes
	moveq	#20-1,d0	; a3 source  a2 dest
îkkkkkk:move.b	(a3),(a2)+
	move.b	(a3)+,(a4)+
	dbra	d0,îkkkkkk
	clr.b	(a2)+
	clr.b	(a4)+
	rts

fixittohex:			; Konverterar till hex
	and.w	#$00FF,d2	; a2 pekare  d2 tal
	move.w	d2,d1
	lea	conver(pc),a4
	lsr.w	#4,d2
	move.b	(a4,d2.w),(a2)+
	and.w	#$F,d1
	move.b	(a4,d1.w),(a2)+
	clr.b	(a2)+
	rts

installUMP:
	move.l	playarea,a0
	lea	AmigatoUMP,a1
	lea	blitter,a3
	moveq	#0,d0
	move.l	aktivUMP,a2
	jsr	4(a2)			; Installera UMPn
	rts

slutpÜminnet:
	move.l	playarea,d0
	bsr	slÑpp_minne
	clr.l	playarea
	clr.l	current_playing_mod
	move.l	slutpÜminne,a1
	moveq	#1,d1		; Slut pÜ minne
	bsr	form_alert
	bsr	makearrow
	rts	

check_interupts:
	move.w	$ffff8900.w,d0		; Kolla att DMAt inte anvÑnds
	and.w	#%11,d0			; till nÜgot annat
	beq.s	DMAtinteigÜng
	moveq	#DMA,d0
	rts
DMAtinteigÜng:
	btst.b	#5,$fffffa07.w		; Kolla om timer A anvÑnds
	beq.s	timeraanvÑndsej		; redan
	moveq	#TIMER,d0
	rts
timeraanvÑndsej:
	moveq	#0,d0
	rts

start_interupts:
	move.l	$114.w,oldtimerC1+2

	move.l	$70.w,oldVBL+2
	move.l	#myVBL,$70.w

	pea	musik_interupt
	move.w	#245,-(sp)
	move.w	#7,-(sp)		; Starta igÜng timern
	move.w	#0,-(sp)
	move.w	#31,-(sp)
	trap	#14
	lea	12(sp),sp

	dc.w	$a000
	move.l	a0,linea

	moveq	#0,d0
	rts


myVBL:	movem.l	a0-a6/d0-d7,-(sp)

	move.l	linea(pc),a0
	move.w	$29C4-$2B1C(a0),d0
	move.w	$29C4-$2B1C+2(a0),d1
	sub.w	$27C4-$2B1C(a0),d0
	sub.w	$27C4-$2B1C+2(a0),d1
	and.w	#%1111111111110000,d0
	move.w	d0,d2
	tst.w	d0
	bpl.s	ingaproblemmedmindre
	neg.w	d2
	moveq	#0,d0
ingaproblemmedmindre:
	move.w	d1,d3
	add.w	#32,d2
	cmp.w	-12(a0),d2
	blt.s	ingaproblemmedbredare
	sub.w	-12(a0),d2
	sub.w	d2,d0
	move.w	-12(a0),d2
ingaproblemmedbredare:
	add.w	#16,d3
	movem.w	d0-d3,pxyarea2
	tst.w	pausmouse
	beq.s	utanfîrarean
	movem.w	pxyarea,d4-d7

	cmp.w	d6,d0
	bgt.s	utanfîrarean
	cmp.w	d7,d1
	bgt.s	utanfîrarean
	cmp.w	d2,d4
	bgt.s	utanfîrarean
	cmp.w	d3,d5
	bgt.s	utanfîrarean
innanfîrarean:
	tst.w	inside
	bne.s	slutpÜVBL
	move.w	#1,inside	; Mus innafîr, gîm den
	dc.w	$a00a
utanfîrarean:
slutpÜVBL:
	movem.l	(sp)+,a0-a6/d0-d7
oldVBL:	jmp	oldVBL
linea:	dc.l	0
blitarea:
	dc.l	0
pxyarea2:
	dc.w	0,0,0,0
pxyarea:dc.w	0,0,0,0

pausmouse:
	dc.w	0		; 1 = pausa musen
inside:	dc.w	0		; 1 = mus innanfîr

busy:	dc.w	0

nooverload:
	move.w	#1,overload
	move.w	#12,countshit
	move.b	#%11111111,$fffffa15.w
	move.b	#245,cpuload+1		; Visa 100% belastning
	bclr.b	#5,$fffffa0f.w
	rte

pausMagX:
	dc.l	0
blitter:dc.w	0
overload:
	dc.w	0

musik_interupt:				; Interuptrutin fîr Timer A
	tst.w	busy			; Ingen overload!
	bne.s	nooverload
	move.b	$ffff8a3c.w,-(sp)	; Blitterstatus
	clr.b	$ffff8a3c.w		; Pausa blittern ifall den arbetar
	tst.w	paused
	bmi.s	kîrvidare1
	movem.l	d0-d4/a0-a3/a6,-(sp)
	move.l	aktivUMP,a0
	jsr	362(a0)
	movem.l	(sp)+,d0-d4/a0-a3/a6
kîrvidare1:
	move.l	#mytimerC,$114.w	; Egen timer Crutin
	and.b	#$0F,$fffffa1d.w	; Stoppa timer C
	move.b	#8,$fffffa23.w		; Ny data till timer C
	or.b	#$50,$fffffa1d.w	; Kîr vidare med timer C
	move.b	(sp)+,$ffff8a3c.w
	bclr.b	#5,$fffffa0f.w
	rte

mytimerC:
	and.b	#$0F,$fffffa1d.w	; Stoppa timer C
	bclr.b	#5,$fffffa11.w
	move.b	#$B8,$fffffa23.w	; Ny data till timer C  $B8
	or.b	#$50,$fffffa1d.w	; Kîr vidare med timer C
	move.l	#mytimerC1,$114.w
	move.w	#3,countshit
	move.b	#%11111111,$fffffa15.w

	move.w	#1,busy
	movem.l	d0-d7/a0-a6,-(sp)
	tst.w	MagX
	beq.s	inteladdatMagX1
	cmp.w	#$0201,MagicVersion
	beq.s	MagX201a
	move.w	$d60.w,pausMagX
	move.w	#-1,$d60.w
	bra.s	inteladdatMagX1
MagX201a:
	move.l	$df2.w,pausMagX		; Quick and dirty pause the 
	move.l	#-1,$df2.w		; Mag!X taskcontroller!
inteladdatMagX1:
	move.b	$ffff8a3c.w,blitter	; Blitterstatus
	clr.b	$ffff8a3c.w		; Pausa blittern ifall den arbetar
	tst.w	colorbars
	beq.s	intevisafÑrger1
	sub.w	#$111,$ffff8240.w
intevisafÑrger1:

	move.w	#$2300,sr		; SÑnk sr och bîrja skapa musik

	tst.w	paused
	bmi.s	kîrvidare2
	bsr	callUMP
kîrvidare2:
	move.w	#$2600,sr		; Inga stîrningar

	tst.w	overload
	bne.s	lksblkl
	move.b	$fffffa1f.w,cpuload+1	; Visa CPUload
lksblkl:clr.w	overload
	move.b	blitter(pc),$ffff8a3c.w	; Starta blittern

	tst.w	MagX
	beq.s	inteladdatMagX2
	cmp.w	#$0201,MagicVersion
	beq.s	MagX201b
	move.w	pausMagX(pc),$d60.w
	bra.s	inteladdatMagX2
MagX201b:
	move.l	pausMagX(pc),$df2.w
inteladdatMagX2:

	tst.w	colorbars
	beq.s	intevisafÑrger2
	add.w	#$111,$ffff8240.w
intevisafÑrger2:
	movem.l	(sp)+,d0-d7/a0-a6
	clr.w	busy
oldtimerC1:
	jmp	$12345678

countshit:
	dc.w	0

mytimerC1:
	subq.w	#1,countshit
	bpl.s	gogogogo
	move.b	#%00100000,$fffffa15.w
	bclr.b	#5,$fffffa11.w
	move.w	#$2500,sr
	bclr.b	#5,$fffffa11.w
	rte
gogogogo:
	tst.w	MiNT
	beq.s	oldtimerC1
	tst.w	busy
	beq.s	oldtimerC1
	bclr.b	#5,$fffffa11.w
	rte

cpuload:
	dc.w	0

timererror:
	move.l	playarea,d0
	bsr	slÑpp_minne
	clr.l	playarea
	clr.l	current_playing_mod
	move.l	timererrorpointer,a1
	moveq	#1,d1			; Fel, gÜr ej att spela
	bsr	form_alert		; ty timer Ñr upptagen
	bsr	makearrow
	rts

dmaerror:
	move.l	playarea,d0
	bsr	slÑpp_minne
	clr.l	playarea
	clr.l	current_playing_mod
	move.l	dmaerrorpointer,a1
	moveq	#1,d1			; Fel, gÜr ej att spela
	bsr	form_alert		; ty DMA Ñr upptaget
	bsr	makearrow
	rts

set_height:	; d0 ny hîjd
	move.w	d0,d7
	move.w	window_handle,d0
	bsr	find_mod
	move.l	current_mod,a0
	move.l	a0,-(sp)
	move.w	d7,-(sp)
	lea	aespb,a0
	move.w	#104,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#5,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)		; Ta reda pÜ koordinater
	move.w	window_handle,$30(a0)
	move.w	#WF_WORKXYWH,$32(a0)
	jsr	callaes
	lea	aespb,a0
	move.w	#108,$18(a0)
	move.w	#6,$1a(a0)
	move.w	#5,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	#0,$30(a0)
	move.w	#(NAME+CLOSER+MOVER+FULLER+ICONIFIER),$32(a0)
	move.l	$432(a0),$34(a0)
	move.w	$436(a0),$38(a0)
	move.w	(sp)+,d0
	move.l	noupdate,a1
	move.w	OB_WIDTH(a1),$38(a0)
	tst.w	d0
	bne.s	intesÑttaWIDTHenoxo
	move.l	playing,a1
	move.w	OB_WIDTH(a1),$38(a0)
	bra.s	allok
intesÑttaWIDTHenoxo:
	tst.w	infosize
	beq.s	allok
	bsr	installupdate
	move.l	biggplay,a1
	move.w	OB_WIDTH(a1),$38(a0)
	move.w	OB_HEIGHT(a1),d0
allok:	move.w	d0,$3a(a0)
	jsr	callaes		; Ta reda pÜ max storlek pÜ ett fînster
	lea	aespb,a0
	move.l	$432(a0),$34(a0)
	move.l	$436(a0),$38(a0)
	move.l	(sp)+,a1
	tst.w	42(a1)
	beq.s	ejdoltfînster
	move.l	$38(a0),38(a1)
	bra.s	doltfînster
ejdoltfînster:
	move.l	$34(a0),34(a1)	; Kom ihÜg ny storlek
	move.l	$38(a0),38(a1)
	move.w	#105,$18(a0)
	move.w	#6,$1a(a0)
	move.w	#1,$1c(a0)		; SÑtt nya koordinater
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	window_handle,$30(a0)
	move.w	#WF_CURRXYWH,$32(a0)
	jsr	callaes
doltfînster:
	rts

set_size:	; d0 objekt
	move.l	d0,d7
	move.w	window_handle,d0
	bsr	find_mod
	move.l	current_mod,a2
	move.l	a2,-(sp)
	move.l	d7,-(sp)
	lea	aespb,a0
	move.w	#104,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#5,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)		; Ta reda pÜ koordinater
	move.w	window_handle,$30(a0)
	move.w	#WF_WORKXYWH,$32(a0)
	jsr	callaes
	lea	aespb,a0
	move.w	#108,$18(a0)
	move.w	#6,$1a(a0)
	move.w	#5,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	#0,$30(a0)
	move.w	#(NAME+CLOSER+MOVER+FULLER+ICONIFIER),$32(a0)
	move.l	$432(a0),$34(a0)
	move.l	(sp)+,a1
	move.l	OB_WIDTH(a1),$38(a0)
	jsr	callaes		; Ta reda pÜ max storlek pÜ ett fînster
	lea	aespb,a0
	move.l	$432(a0),$34(a0)
	move.l	$436(a0),$38(a0)
	move.l	(sp)+,a1
	tst.w	42(a1)
	bne.s	cvkmxkm
	move.l	$34(a0),34(a1)	; Kom ihÜg ny storlek
cvkmxkm:
	move.l	$38(a0),38(a1)
	move.w	#105,$18(a0)
	move.w	#6,$1a(a0)
	move.w	#1,$1c(a0)		; SÑtt nya koordinater
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	window_handle,$30(a0)
	move.w	#WF_CURRXYWH,$32(a0)
	jsr	callaes
	rts

cyklewindow:
	bsr	get_aktiv_window
	bmi.s	cykelimpossible
cyklasnabbt:
	move.w	d3,d6
	bpl	topp_it
	move.w	d2,d6
	bpl	topp_it
	rts
topp_it:lea	aespb,a0
	move.w	#105,$18(a0)
	move.w	#6,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	d6,$30(a0)
	move.w	#WF_TOP,$32(a0)
	jsr	callaes		; SÑtt fînstret hîgst!
cykelimpossible:
	rts

get_aktiv_window:
	lea	aespb,a0
	move.w	#104,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#5,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	window_handle,$30(a0)
	move.w	#WF_TOP,$32(a0)
	jsr	callaes
	lea	aespb,a0
	move.w	$432(a0),d0
	move.w	d0,d7
	bsr	find_mod
	rts

check_window_vs_menu:		; Ser till att allt Ñr rÑtt i menyn i
	bsr	get_aktiv_window; fîrhÜllande till aktiva fînster
	bpl.s	own_aktiv_window
	moveq	#0,d7
	move.w	d7,d5
	bra.s	nowindow
own_aktiv_window:
	bsr	get_used_mods
	move.w	d0,d7
	move.w	d3,d5
nowindow:

	moveq	#0,d2
	cmp.w	#2,d7
	blt.s	notabletoNext
	cmp.w	#1,d5
	ble.s	notabletoNext
	moveq	#1,d2
notabletoNext:
	move.l	menupointer,a1
	move.w	#MNEXT,d1	; Next Window
	bsr	menu_ienable

	moveq	#0,d2
	moveq	#MAXMOD-1,d0
	lea	modules,a0
leeeeeeeeeta:
	tst.w	(a0)
	bmi.s	nix444
	tst.w	42(a0)
	beq.s	nix444
	moveq	#1,d2
nix444:	lea	RECORD(a0),a0
	dbra	d0,leeeeeeeeeta
	move.l	menupointer,a1
	move.w	#GOMD,d1	; Fînster gîmda
	bsr	menu_ienable

	moveq	#0,d2
	tst.w	d7
	beq.s	notabletoClose
	moveq	#1,d2
notabletoClose:
	move.l	menupointer,a1
	move.w	#MCLOSE,d1	; Close Window
	bsr	menu_ienable

	moveq	#0,d2
	tst.w	d5
	beq.s	notabletoGom
	moveq	#1,d2
notabletoGom:
	move.l	menupointer,a1
	move.w	#GOM,d1		; Gîm Window
	bsr	menu_ienable

	moveq	#0,d6
	tst.l	current_playing_mod
	beq.s	notabletostopp
	moveq	#1,d6
notabletostopp:
	move.w	d6,d2
	move.l	menupointer,a1
	move.w	#MSTOPPIT,d1	; Stopp
	bsr	menu_ienable
	move.w	d6,d2
	move.l	menupointer,a1
	move.w	#MFORWARD,d1	; FramÜt
	bsr	menu_ienable
	move.w	d6,d2
	move.l	menupointer,a1
	move.w	#MBAKWARD,d1	; BakÜt
	bsr	menu_ienable

	moveq	#0,d2
	tst.l	current_playing_mod
	beq.s	notabletopaus
	moveq	#1,d2
notabletopaus:
	move.l	menupointer,a1
	move.w	#PAUS,d1	; Paus
	bsr	menu_ienable

	moveq	#0,d2
	tst.w	d7
	beq.s	notabletoPlay
	tst.l	current_playing_mod
	beq.s	abletoPlay
	move.l	current_playing_mod,a0
	move.l	current_mod,a1	; Om aktuell modul redan spelas skall
	move.w	(a0),d0		; vi inte kunna spela den igen
	cmp.w	(a1),d0
	beq.s	notabletoPlay
abletoPlay:
	moveq	#1,d2
notabletoPlay:
	move.l	menupointer,a1
	move.w	#MAKTUELL,d1	; Play Aktuell
	bsr	menu_ienable
	rts

showHELP:
	moveq	#1,d1			; Upppdatera
	bsr	wind_update
	move.w	#1,windupdate
	lea	fx,a1
	move.l	HELPpointer,a2
	bsr	form_center		; Centrera
	lea	fx,a1
	moveq	#0,d1
	bsr	form_dial		; Reservera
	lea	fx,a1
	move.l	HELPpointer,a2
	moveq	#0,d1
	moveq	#4,d2
	bsr	objc_draw		; Rita formen
	move.l	HELPpointer,a1
	moveq	#0,d1
	bsr	form_do			; VÑnta pÜ aktion
	move.l	HELPpointer,a1
	bsr	show_butt_normal	; Visa formknappen normalt igen
	lea	fx,a1
	moveq	#3,d1
	bsr	form_dial		; SlÑpp
	moveq	#0,d1			; Sluta upppdatering
	bsr	wind_update
	rts

show_version:
	moveq	#1,d1			; Upppdatera
	bsr	wind_update
	move.w	#1,windupdate
	lea	fx,a1
	move.l	infopointer,a2
	bsr	form_center		; Centrera
	lea	fx,a1
	moveq	#0,d1
	bsr	form_dial		; Reservera
	lea	fx,a1
	move.l	infopointer,a2
	moveq	#0,d1
	moveq	#4,d2
	bsr	objc_draw		; Rita formen
	move.l	infopointer,a1
	moveq	#0,d1
	bsr	form_do			; VÑnta pÜ aktion
	move.l	d0,-(sp)
	move.l	infopointer,a1
	bsr	show_butt_normal	; Visa formknappen normalt igen
	lea	fx,a1
	moveq	#3,d1
	bsr	form_dial		; SlÑpp
	move.l	(sp)+,d0
	cmp.w	#MERA,d0
	bne.s	intevisameraformen
	lea	fx,a1
	move.l	merpointer,a2
	bsr	form_center		; Centrera
	lea	fx,a1
	moveq	#0,d1
	bsr	form_dial		; Reservera
	lea	fx,a1
	move.l	merpointer,a2
	moveq	#0,d1
	moveq	#4,d2
	bsr	objc_draw		; Rita formen
	move.l	merpointer,a1
	moveq	#0,d1
	bsr	form_do			; VÑnta pÜ aktion
	move.l	merpointer,a1
	bsr	show_butt_normal	; Visa formknappen normalt igen
	lea	fx,a1
	moveq	#3,d1
	bsr	form_dial		; SlÑpp
intevisameraformen:
	rts

installPID:
	movem.l	d0-d7/a0-a6,-(sp)
	tst.w	noACC
	beq.s	noinstallofPID1
	tst.w	MiNTispresent
	bne.s	noinstallofPID1
	tst.w	MagX
	bne.s	noinstallofPID1
	pea	installPIDnow
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp
noinstallofPID1:
	movem.l	(sp)+,d0-d7/a0-a6
	rts
installPIDnow:
	move.l	$4f2.w,a0
	move.l	$28(a0),a0
	move.l	(a0),apPID
	move.l	osPID,(a0)
	rts

removePID:
	movem.l	d0-d7/a0-a6,-(sp)
	tst.w	noACC
	beq.s	noinstallofPID2
	tst.w	MiNTispresent
	bne.s	noinstallofPID2
	tst.w	MagX
	bne.s	noinstallofPID2
	pea	removePIDnow
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp
noinstallofPID2:
	movem.l	(sp)+,d0-d7/a0-a6
	rts
removePIDnow:
	move.l	$4f2.w,a0
	move.l	$28(a0),a0
	move.l	apPID,(a0)
	rts

osPID:	dc.l	0
apPID:	dc.l	0

kollaomMiNT:
	move.l	#ACCbasepage,osPID
	tst.l	$5a0.w
	beq	fÑrdigletatfîridag
	move.l	$5a0.w,a0
kîrvidareochtestanÑstakaka:
fortsÑttletaefterMiNT:
	tst.l	(a0)
	beq.s	fÑrdigletatfîridag
	cmp.l	#'Gnva',(a0)
	beq.s	Genevafinns2
	cmp.l	#'MiNT',(a0)
	bne.s	mintÑrinteinstallerat2
	move.w	#1,mtask
	move.w	#1,MiNT
Genevafinns2:
	move.w	#1,MiNTispresent
mintÑrinteinstallerat2:
	cmp.l	#'MagX',(a0)
	bne.s	intemtask
	move.w	#$101,redrawoption
	move.l	4(a0),a1
	move.l	8(a1),a1
	move.w	48(a1),MagicVersion
	move.w	#1,MagX
	move.w	#1,mtask
intemtask:
	addq.l	#8,a0
	bra.s	fortsÑttletaefterMiNT
fÑrdigletatfîridag:
	rts

redrawoption:			; Uppdateringstyp ($001 eller $101)
	dc.w	1
MiNT:
	dc.w	0
MagX:
	dc.w	0
MagicVersion:
	dc.w	0


makebusy:
	tst.w	mtask
	bne.s	visaejbusytyMiNT
	lea	0,a1
	moveq	#2,d1
	bsr	graf_mouse
visaejbusytyMiNT:
	rts

makearrow:
	lea	0,a1
	moveq	#0,d1
	bsr	graf_mouse
	rts

setstringfromkommando:
	subq.w	#1,d2		; for dbra
	bmi.s	asdfasdf
koppa:	move.b	(a1)+,d3
	move.b	d3,(a0)+
	move.b	d3,(a2)+
	cmp.b	#':',d3
	beq.s	bîrjaom
	cmp.b	#'\',d3
	bne.s	loppvidare
bîrjaom:lea	name,a2
loppvidare:
	dbra	d2,koppa
asdfasdf:
	clr.b	(a0)+
	clr.b	(a2)+
	rts

redrawpartofwindow:
	lea	aespb,a0
	move.w	#104,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#5,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	window_handle,$30(a0)
	move.w	#WF_WORKXYWH,$32(a0)
	jsr	callaes		; Ta reda pÜ fînsterkoordinaterna
	lea	aespb,a0
	move.l	$432(a0),fx
	move.l	$436(a0),fx+4
	move.l	controlpointer,a3
	move.l	noupdate,a2
	move.l	biggplay,a1
	move.l	playing,a0	; Fixa till sÜ objectet ligger vid
	move.l	fx,OB_X(a0)	; fînstret
	move.l	fx,OB_X(a1)
	move.l	fx,OB_X(a2)
	move.l	fx,OB_X(a3)
	lea	aespb,a0
	move.w	#104,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#5,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	window_handle,$30(a0)
	move.w	#WF_FIRSTXYWH,$32(a0)
	jsr	callaes		; Ta reda pÜ fîrsta delen att uppdatera
	lea	aespb,a0
	move.l	$432(a0),fx
	move.l	$436(a0),fx+4
	bsr	checkanddraw
loopaframhelaformenrÑtt:
	lea	aespb,a0
	move.w	#104,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#5,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	window_handle,$30(a0)
	move.w	#WF_NEXTXYWH,$32(a0)
	jsr	callaes		; Ta reda pÜ resten att uppdatera
	lea	aespb,a0
	move.l	$432(a0),fx
	move.l	$436(a0),fx+4
	tst.l	fx+4
	beq.s	fÑrdigmedritandet
	bsr	checkanddraw
	bra.s	loopaframhelaformenrÑtt
fÑrdigmedritandet:
	rts

checkanddraw:
	movem.w	messbuffer+8,d0-d3
	add.w	d0,d2
	add.w	d1,d3			; Ser till att vi inte uppdaterar
	movem.w	fx,d4-d7		; mer Ñn nîdvÑndigt
	add.w	d4,d6
	add.w	d5,d7

	cmp.w	d0,d4
	bge.s	nÑnÑnÑx1
	move.w	d0,d4
nÑnÑnÑx1:
	cmp.w	d1,d5
	bge.s	nÑnÑnÑy1
	move.w	d1,d5
nÑnÑnÑy1:
	cmp.w	d2,d6
	ble.s	nÑnÑnÑx2
	move.w	d2,d6
nÑnÑnÑx2:
	cmp.w	d3,d7
	ble.s	nÑnÑnÑy2
	move.w	d3,d7
nÑnÑnÑy2:
	sub.w	d4,d6
	ble.s	behîverinteritanÜge
	sub.w	d5,d7
	ble.s	behîverinteritanÜge
	movem.w	d4-d7,fx
	tst.w	chooseblitt
	bne	blitt
	move.l	biggplay,a2
	tst.w	infosize
	bne.s	bigg
	move.l	playing,a2
bigg:	tst.w	updateonoff
	beq.s	dfgdfg
	move.l	noupdate,a2
dfgdfg:	tst.w	wasctrl
	beq.s	skflkf
	move.l	controlpointer,a2
skflkf:
	lea	fx,a1
	moveq	#0,d1
	moveq	#4,d2
	bsr	objc_draw		; Rita en del av formen
behîverinteritanÜge:
	rts

wasctrl:dc.w	0

updatethisareaofwindow:	; d0 vilken del av fînstret som skall uppdateras
	move.l	current_playing_mod,a0
	move.w	(a0),window_handle
	move.l	playing,a0
	tst.w	infosize
	beq.s	kkokkok
	move.l	biggplay,a0
kkokkok:lea	messbuffer+8,a1
	mulu	#SIZE_OBJECT,d0
	move.w	OB_X(a0,d0),d1
	move.w	OB_Y(a0,d0),d2
	move.w	OB_WIDTH(a0,d0),d3
	move.w	OB_HEIGHT(a0,d0),d4
	add.w	OB_X(a0),d1
	add.w	OB_Y(a0),d2
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	move.w	d4,(a1)+
	tst.w	chooseblitt
	bne.s	sdfjskf
	moveq	#1,d1			; Uppdatera
	bsr	wind_update
sdfjskf:bsr	redrawpartofwindow
	tst.w	chooseblitt
	bne.s	sdfjskf2
	moveq	#0,d1			; Sluta uppdatera
	bsr	wind_update
sdfjskf2:
	rts

updatethisareaofwindow2:	; d0 vilken del av fînstret som skall uppdateras
	tst.l	current_playing_mod
	beq.s	noooooooope
	move.l	current_playing_mod,a0
	move.w	(a0),window_handle
	lea	messbuffer+8,a0
	clr.l	(a0)+
	move.w	#2000,(a0)+
	move.w	#2000,(a0)+
	moveq	#1,d1			; Uppdatera
	bsr	wind_update
	bsr	redrawpartofwindow
	moveq	#0,d1			; Sluta uppdatera
	bsr	wind_update
noooooooope:
	rts

;============================================================ GEMrutiner ==


kill_window:
	move.w	d0,window_handle
	bsr	kill_if_current_playing
	lea	aespb,a0
	move.w	#102,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	window_handle,$30(a0)
	jsr	callaes		; StÑng fînstret
	lea	aespb,a0
	move.w	#103,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	window_handle,$30(a0)
	jsr	callaes		; Ta bort fînstret
	rts

general_setup:
	clr.l	current_playing_mod

	move.l	setup_form,a0
	move.w	#TONER,d0
	mulu	#SIZE_OBJECT,d0
	move.l	OB_SPEC(a0,d0.w),a1	; HÑmta pekare till kommandlinjen
	move.l	TE_PTEXT(a1),pointertoupdatetime

	move.l	biggplay,a0
	move.l	a0,a1
	move.w	#BLITAREA,d0
	mulu	#SIZE_OBJECT,d0
	add.w	d0,a0
	move.l	a0,blitarea
	move.w	OB_HEIGHT(a0),d0
	divu	#6,d0
	move.w	d0,nrofrows
	move.w	d0,d1
	mulu	#6,d0			; Se till att arean platsar fˆr fonten (6 pixels)
	move.w	d0,OB_HEIGHT(a0)
	add.w	OB_Y(a0),d0
	move.w	d0,OB_HEIGHT(a1)	; Ordna till huvudboxen
	lsr.w	#1,d1
	mulu	#6,d1
	subq.w	#1,d1
	add.w	OB_Y(a0),d1
	move.w	#INDICATO,d2
	mulu	#SIZE_OBJECT,d2
	move.w	d1,OB_Y(a1,d2.w)	; Ordna till mittenvisaren
	move.w	#7,OB_HEIGHT(a1,d2.w)

	move.l	controlpointer,a0
	moveq	#5-1,d7
	lea	SIZE_OBJECT(a0),a1
	move.w	OB_X(a1),d0		; Ordna till control
	move.w	OB_Y(a1),d2
	add.w	d2,d2
	add.w	height,d2
	move.w	d2,OB_HEIGHT(a0)
	move.w	d0,d1
fixcontrol:
	move.w	d1,OB_X(a1)
	move.w	#32,OB_WIDTH(a1)
	move.w	height,OB_HEIGHT(a1)
	add.w	#32,d1
	add.w	d0,d1
	lea	SIZE_OBJECT(a1),a1
	dbra	d7,fixcontrol
	move.w	d1,OB_WIDTH(a0)
	rts

height:	dc.w	16

show_butt_normal:	; Ta bort selected pÜ formknappen
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
	lea	aespb,a0
	move.w	#78,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a1,$230(a0)
	move.w	d1,$30(a0)
	jsr	callaes
	lea	aespb,a0
	move.w	$430(a0),d0
	rts

menu_text:		; a1 trÑd a2 ny text d1 objekt
	lea	aespb,a0
	move.w	#34,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#2,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a1,$230(a0)
	move.l	a2,$234(a0)
	move.w	d1,$30(a0)
	jsr	callaes
	lea	aespb,a0
	move.w	$430(a0),d0
	rts

objc_draw:		; a1 fx a2 trÑd d1 start d2 djup
	lea	aespb,a0
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
	lea	aespb,a0
	move.w	$430(a0),d0
	rts

objc_find:		; a1 trÑd d1 start d2 djup d3 x d4 y
	lea	aespb,a0
	move.w	#43,$18(a0)
	move.w	#4,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a1,$230(a0)
	move.w	d1,$30(a0)
	move.w	d2,$32(a0)
	move.w	d3,$34(a0)
	move.w	d4,$36(a0)
	jsr	callaes
	lea	aespb,a0
	move.w	$430(a0),d0
	rts

evnt_timer:		; d1 Ticks att vÑnta i millisekunder
	lea	aespb,a0
	move.w	#24,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	d1,$30(a0)
	swap	d1
	move.w	d1,$32(a0)
	jsr	callaes
	lea	aespb,a0
	move.w	$430(a0),d0
	rts

form_do:		; a1 trÑd d1 bîrjan
	lea	aespb,a0
	move.w	#50,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a1,$230(a0)
	move.w	d1,$30(a0)
	jsr	callaes
	lea	aespb,a0
	move.w	$430(a0),d0
	rts

form_dial:		; a1 pekare till fx d1 funktion
	lea	aespb,a0
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
	lea	aespb,a0
	move.w	$430(a0),d0
	rts

form_center:		; a1 pekare till fx a2 trÑd
	move.l	a1,-(sp)
	lea	aespb,a0
	move.w	#54,$18(a0)
	move.w	#0,$1a(a0)
	move.w	#5,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a2,$230(a0)
	jsr	callaes
	lea	aespb,a0
	move.l	(sp)+,a1
	move.w	$430(a0),d0
	move.l	$432(a0),(a1)+
	move.l	$436(a0),(a1)+
	rts

wind_update:		; d1 funktion
	lea	aespb,a0
	move.w	#107,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	d1,$30(a0)
	jsr	callaes
	lea	aespb,a0
	move.w	$430(a0),d0
	rts

wind_find:		; d1 x   d2 y
	lea	aespb,a0
	move.w	#106,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	d1,$30(a0)
	move.w	d2,$32(a0)
	jsr	callaes
	lea	aespb,a0
	move.w	$430(a0),d0
	rts

menu_icheck:		; a1 meny d1 object
	lea	aespb,a0
	move.w	#31,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a1,$230(a0)
	move.w	d1,$30(a0)
	move.w	d2,$32(a0)
	jsr	callaes
	lea	aespb,a0
	move.w	$430(a0),d0
	rts

menu_ienable:		; a1 meny d1 object
	lea	aespb,a0
	move.w	#32,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a1,$230(a0)
	move.w	d1,$30(a0)
	move.w	d2,$32(a0)
	jsr	callaes
	lea	aespb,a0
	move.w	$430(a0),d0
	rts

menu_tnormal:		; a1 meny d1 objekt
	tst.w	noACC
	bne.s	kîrssomACC1
	lea	aespb,a0
	move.w	#33,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a1,$230(a0)
	move.w	d1,$30(a0)
	move.w	d2,$32(a0)
	jsr	callaes
	lea	aespb,a0
	move.w	$430(a0),d0
kîrssomACC1:
	rts

evnt_mesag:		; a1 messbuffer
	lea	aespb,a0
	move.w	#23,$18(a0)
	move.w	#0,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a1,$230(a0)
	jsr	callaes
	lea	aespb,a0
	move.w	$430(a0),d0
	rts

evnt_multi:
	lea	aespb,a0
	move.w	#25,$18(a0)
	move.w	#16,$1a(a0)
	move.w	#7,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	lea	$30(a0),a2
	tst.l	current_playing_mod
	beq.s	no_update_due_no_playing
	tst.w	updateonoff
	beq.s	updateon
no_update_due_no_playing:
	move.w	#MU_KEYBD+MU_MESAG+MU_BUTTON,(a2)+
	bra.s	updateoff
updateon:
	move.w	#MU_KEYBD+MU_MESAG+MU_TIMER+MU_BUTTON,(a2)+	; Actions to wait for
updateoff:
	move.w	#1,(a2)+		; Mouseclicks
	move.w	#1,(a2)+		; Mousebuttons
	move.w	#1,(a2)+		; Button up/down
	move.w	#0,(a2)+		; mm1flags
	move.w	#0,(a2)+		; mm1x
	move.w	#0,(a2)+		; mm1y
	move.w	#0,(a2)+		; mm1width
	move.w	#0,(a2)+		; mm1height
	move.w	#0,(a2)+		; mm2flags
	move.w	#0,(a2)+		; mm2x
	move.w	#0,(a2)+		; mm2y
	move.w	#0,(a2)+		; mm2width
	move.w	#0,(a2)+		; mm2height
	move.w	updatetime,(a2)+	; Timer low
	move.w	#0,(a2)+		; Timer high
	move.l	#messbuffer,$230(a0)	; Message buffer
	jsr	callaes
	lea	aespb,a0
	lea	$430(a0),a1
	move.w	(a1)+,d0		; which
	move.w	(a1)+,d1		; mmox
	move.w	(a1)+,d2		; mmoy
	move.w	(a1)+,d3		; mmobutton
	move.w	(a1)+,d4		; mmokstate
	move.w	(a1)+,d5		; mkreturn
	move.w	(a1)+,d6		; mbreturn
	rts

menu_bar:		; a1 menyn d1 visa/ta bort
	lea	aespb,a0
	move.w	#30,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a1,$230(a0)
	move.w	d1,$30(a0)
	jsr	callaes
	lea	aespb,a0
	move.w	$430(a0),d0
	rts

menu_register:		; a1 ny text d1 ID
	lea	aespb,a0
	move.w	#35,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a1,$230(a0)
	move.w	d1,$30(a0)
	jsr	callaes
	lea	aespb,a0
	move.w	$430(a0),d0
	rts

rsrc_gaddr:		; a1 pekare till variabel d1 typ d2 vilken
	move.l	a1,-(sp)
	lea	aespb,a0
	move.w	#112,$18(a0)
	move.w	#2,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#1,$20(a0)
	move.w	d1,$30(a0)
	move.w	d2,$32(a0)
	jsr	callaes
	lea	aespb,a0
	move.l	(sp)+,a1
	move.l	$630(a0),(a1)
	move.w	$430(a0),d0
	rts

form_alert:		; a1 strÑng d1 huvudknapp
	lea	aespb,a0
	move.w	#52,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a1,$230(a0)
	move.w	d1,$30(a0)
	jsr	callaes
	lea	aespb,a0
	move.w	$430(a0),d0
	rts

shel_write:		; a1 filnamn a2 commandline
	lea	aespb,a0
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
	lea	aespb,a0
	move.w	$430(a0),d0
	rts

form_error:		; d1 errorkod
	lea	aespb,a0
	move.w	#53,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	d1,$30(a0)
	jsr	callaes
	lea	aespb,a0
	move.w	$430(a0),d0
	rts

rsrc_load:		; a1 filnamn
	lea	aespb,a0
	move.w	#110,$18(a0)
	move.w	#0,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#1,$1e(a0)
	move.w	#0,$20(a0)
	move.l	a1,$230(a0)
	jsr	callaes
	lea	aespb,a0
	move.w	$430(a0),d0
	rts

rsrc_free:
	lea	aespb,a0
	move.w	#111,$18(a0)
	move.w	#0,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	jsr	callaes
	lea	aespb,a0
	move.w	$430(a0),d0
	rts

open_work_station:
	lea	aespb(pc),a0
	move.w	#77,$18(a0)
	move.w	#0,$1a(a0)
	move.w	#5,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	jsr	callaes
	lea	aespb(pc),a0
	move.w	$430(a0),handle
	lea	aespb(pc),a0
	move.w	#100,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#11,$1e(a0)
	move.w	handle,$24(a0)
	lea	$30(a0),a2
	move.w	#1,(a2)+
	move.w	#1,(a2)+
	move.w	#1,(a2)+
	move.w	#1,(a2)+
	move.w	#1,(a2)+
	move.w	#1,(a2)+
	move.w	#1,(a2)+
	move.w	#1,(a2)+
	move.w	#1,(a2)+
	move.w	#1,(a2)+
	move.w	#2,(a2)+
	jsr	callaes2
	lea	aespb(pc),a0
	move.w	$24(a0),handle
	move.w	$430(a0),d0	; Intout 0
	rts

close_work_station:
	lea	aespb(pc),a0
	move.w	#101,$18(a0)
	move.w	#0,$1a(a0)
	move.w	#0,$1e(a0)
	move.w	handle,$24(a0)
	jsr	callaes2
	rts

handle:	dc.w	0

appl_init:
	lea	aespb,a0
	clr.w	$1a(a0)
	move.w	#1,$1c(a0)
	clr.w	$1e(a0)
	move.w	#$a,$18(a0)
	jsr	callaes
	cmp.w	#$400,contrl
	blt.s	ingensupportfîrlockandhold
	move.w	#$101,redrawoption
ingensupportfîrlockandhold:
	lea	aespb,a0
	move.w	$430(a0),d0
	rts




callaes:move.l	a0,d1
	move.w	#$c8,d0
	trap	#2
	rts

callaes2:
	move.l	a0,d1
	move.w	#$73,d0
	trap	#2
	rts

appl_exit:
	lea	aespb,a0
	clr.w	$1a(a0)
	move.w	#1,$1c(a0)
	clr.w	$1e(a0)
	move.w	#$13,$18(a0)
	jsr	callaes
	lea	aespb,a0
	move.w	$430(a0),d0
	rts

fsel_exinput:		; a1 label   a2 name	a3 path   d0 error   d1 button
	movem.l	a0-a3/d0-d1,-(sp)
	moveq	#3,d1			; Upppdatera
	bsr	wind_update
	movem.l	(sp)+,a0-a3/d0-d1

	lea	aespb,a0
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
	lea	aespb,a0
	move.w	$432(a0),d1
	move.w	$430(a0),d0
	rts

merpointer:
	dc.l	0
filejfunnen:
	dc.l	0
felvidinst:
	dc.l	0
slutpÜminne:
	dc.l	0
playing:dc.l	0
biggplay:
	dc.l	0
lÑsfel:	dc.l	0
unknown_format:
	dc.l	0
fyra:	dc.l	0
Ütta:	dc.l	0
sex:	dc.l	0
timererrorpointer:
	dc.l	0
dmaerrorpointer:
	dc.l	0
noupdate:
	dc.l	0
byteavUMP:
	dc.l	0

install_pointers:
	moveq	#0,d1
	moveq	#MENY,d2
	lea	menupointer,a1
	bsr	rsrc_gaddr		; FÜ reda pÜ adressen till MENU
	moveq	#0,d1
	moveq	#INFOMATI,d2
	lea	infopointer,a1
	bsr	rsrc_gaddr		; FÜ reda pÜ adressen till INFORMA
	moveq	#0,d1
	moveq	#MER,d2
	lea	merpointer,a1
	bsr	rsrc_gaddr		; FÜ reda pÜ adressen till MER
	moveq	#0,d1
	moveq	#INST,d2
	lea	setup_form,a1
	bsr	rsrc_gaddr		; FÜ reda pÜ adressen till INST
	moveq	#0,d1
	moveq	#BIGPLAY,d2
	lea	biggplay,a1
	bsr	rsrc_gaddr		; FÜ reda pÜ adressen till BIGGPLAY
	moveq	#0,d1
	moveq	#NOUPDATE,d2
	lea	noupdate,a1
	bsr	rsrc_gaddr		; FÜ reda pÜ adressen till NOUPDATE
	moveq	#0,d1
	moveq	#PLAYING,d2
	lea	playing,a1
	bsr	rsrc_gaddr		; FÜ reda pÜ adressen till PLAYING
	moveq	#0,d1
	moveq	#CONTROL,d2
	lea	controlpointer,a1
	bsr	rsrc_gaddr		; FÜ reda pÜ adressen till CONTROL
	move.l	controlpointer,a1
	cmp.w	#16,OB_HEIGHT(a1)
	bgt.s	hîjdenok
	moveq	#0,d1
	moveq	#CONTROL2,d2
	lea	controlpointer,a1	; Om medium:
	bsr	rsrc_gaddr		; FÜ reda pÜ adressen till CONTROL2
	move.w	#8,height
hîjdenok:
	moveq	#0,d1
	moveq	#HELP,d2
	lea	HELPpointer,a1
	bsr	rsrc_gaddr		; FÜ reda pÜ adressen till HELP
	moveq	#5,d1
	moveq	#AVSLUT,d2
	lea	quitalert,a1
	bsr	rsrc_gaddr		; FÜ reda pÜ adressen till QUITARE
	moveq	#5,d1
	moveq	#LABEL,d2
	lea	label,a1
	bsr	rsrc_gaddr		; FÜ reda pÜ adressen till LABEL
	moveq	#5,d1
	moveq	#FILEN,d2
	lea	filejfunnen,a1
	bsr	rsrc_gaddr		; FÜ reda pÜ adressen till FILEN
	moveq	#5,d1
	moveq	#SAVE,d2
	lea	felvidinst,a1
	bsr	rsrc_gaddr		; FÜ reda pÜ adressen till SAVE
	moveq	#5,d1
	moveq	#MINNE,d2
	lea	slutpÜminne,a1
	bsr	rsrc_gaddr		; FÜ reda pÜ adressen till MINNE
	moveq	#5,d1
	moveq	#READ,d2
	lea	lÑsfel,a1
	bsr	rsrc_gaddr		; FÜ reda pÜ adressen till READ
	moveq	#5,d1
	moveq	#UNKNOWN,d2
	lea	unknown_format,a1
	bsr	rsrc_gaddr		; FÜ reda pÜ adressen till UNKNOWN
	moveq	#5,d1
	moveq	#FYRA,d2
	lea	fyra,a1
	bsr	rsrc_gaddr		; FÜ reda pÜ adressen till FYRA
	moveq	#5,d1
	moveq	#ATTA,d2
	lea	Ütta,a1
	bsr	rsrc_gaddr		; FÜ reda pÜ adressen till ATTA
	moveq	#5,d1
	moveq	#SEX,d2
	lea	sex,a1
	bsr	rsrc_gaddr		; FÜ reda pÜ adressen till SEX
	moveq	#5,d1
	moveq	#TIMER,d2
	lea	timererrorpointer,a1
	bsr	rsrc_gaddr		; FÜ reda pÜ adressen till TIMER
	moveq	#5,d1
	moveq	#DMA,d2
	lea	dmaerrorpointer,a1
	bsr	rsrc_gaddr		; FÜ reda pÜ adressen till DMA
	moveq	#5,d1
	moveq	#CHANGE,d2
	lea	byteavUMP,a1
	bsr	rsrc_gaddr		; FÜ reda pÜ adressen till CHANGE
	rts

wholename:
	ds.b	70
	even
makeawholename:
	lea	wholename,a2
	move.l	a0,a4
searchforendofpath:
	tst.b	(a0)			; Leta reda pÜ nollan
	beq.s	slutetpapath
	addq.l	#1,a0
	bra.s	searchforendofpath
slutetpapath:
	cmp.b	#'\',(a0)
	beq.s	forstaslachen		; Leta bakÜt efter fîrsta \
	subq.l	#1,a0
	bra.s	slutetpapath
forstaslachen:
	move.l	a4,a3
skrivditnyapathen:
	cmp.l	a3,a0			; Kopiera îver pathen till wholename
	blt.s	skrivithelapathen
	move.b	(a3)+,(a2)+
	bra.s	skrivditnyapathen
skrivithelapathen:
	tst.b	(a1)
	beq.s	skrivithelanamnet
	move.b	(a1)+,(a2)+		; Kopiera îver filnamnet
	bra.s	skrivithelapathen
skrivithelanamnet:
	clr.b	(a2)+			; 0a pÜ slutet oxo
	rts

current_mod:
	dc.l	modules

get_new_mod:			; Retunerar en ny pos fîr en modul
	moveq	#MAXMOD-1,d0
	lea	modules,a0
checkiffree:
	tst.w	(a0)
	bmi.s	gotonefreepos
	lea	RECORD(a0),a0
	dbra	d0,checkiffree
	tst.w	d0
	rts
gotonefreepos:
	move.l	a0,current_mod
	moveq	#0,d0
	rts

get_used_mods:
	moveq	#0,d0
	moveq	#0,d3
	moveq	#MAXMOD-1,d1
	lea	modules,a0
checkifused:
	tst.w	(a0)
	bmi.s	notusedrightnow
	addq.w	#1,d0
	tst.w	42(a0)
	bne.s	notusedrightnow
	addq.w	#1,d3
notusedrightnow:
	lea	RECORD(a0),a0
	dbra	d1,checkifused
	moveq	#MAXMOD,d1	; d0 antal anvÑnda moduler
	move.w	d1,d2		; d1 antal lediga moduler
	sub.w	d0,d1		; d2 max antal moduler
	rts			; d3 antal moduler icke gîmda


find_mod:		; Letar rÑtt pÜ en modul via fînsterhandlet (d0)
	moveq	#-1,d2	; Fîrsta fînster
	moveq	#-1,d3	; Fînster efter aktuellt
	moveq	#MAXMOD-1,d1
	lea	modules,a0
checkiffound:
	cmp.w	(a0),d0
	beq.s	gotone
	tst.w	(a0)
	bmi.s	ingetfînster
	tst.w	d2
	bpl.s	ingetfînster
	tst.w	42(a0)
	bne.s	ingetfînster
	move.w	(a0),d2
ingetfînster:
	lea	RECORD(a0),a0
	dbra	d1,checkiffound
	moveq	#-1,d0
	tst.w	d0
	rts
gotone:
	move.l	a0,current_mod
	lea	RECORD(a0),a0
	dbra	d1,find_one_after
	moveq	#-1,d0
	rts
find_one_after:
	tst.w	(a0)
	bmi.s	ingetfînster2
	tst.w	42(a0)
	bne.s	ingetfînster2
	move.w	(a0),d3
	moveq	#0,d0
	rts
ingetfînster2:
	lea	RECORD(a0),a0
	dbra	d1,find_one_after
	move.l	current_mod,a0
	moveq	#0,d0
	rts

open_new_mod:
	move.l	label,a1
	lea	name,a2 		; Visa filvÑljaren
	lea	path,a3
	jsr	fsel_exinput
	tst.w	d0
	beq	inteladdaennymodd
	tst.w	d1
	beq	inteladdaennymodd

	lea	path,a0
	lea	name,a1
	bsr	makeawholename

	tst.w	closebeforeload
	beq.s	intestÑnga2
	bsr	closeshit
intestÑnga2:
load_a_mod:

	bsr	makebusy
	bsr	get_new_mod
	bmi	inteladdaennymodd

	moveq	#1,d7
	moveq	#0,d0
	lea	wholename,a0
	bsr	open			; ôppna filen
	bmi	inteladdaennymodd

	clr.w	-(sp)
	pea	wholename
	move.w	#$4e,-(sp)
	trap	#1			; Ta reda pÜ lÑngden pÜ filen
	addq.w	#8,sp
	tst.l	d0
	bne	fel

	move.w	#$2f,-(sp)
	trap	#1
	addq.w	#2,sp
	move.l	d0,a0
	lea	DiskTransferAdress,a1
	moveq	#11-1,d0
lllllllll:
	move.l	(a0)+,(a1)+
	dbra	d0,lllllllll

	move.l	DiskTransferAdress+26,d0
	add.l	#32000,d0		; Kom ihÜg 1k xtra av samplingarna
	bsr	fÜ_minne		; BegÑr minne fîr modulen
	beq	slutpÜminnefîrmodul
	move.l	current_mod,a0
	move.l	d0,2(a0)		; Kom ihÜg minnesarean
	move.l	DiskTransferAdress+26,d1
	move.l	d1,28(a0)		; Kom ihÜg lÑngden pÜ arean
					; LÑs in och tolka modulen
	move.l	d0,a0
	move.l	DiskTransferAdress+26,d0
	bsr	read
	bmi	felvidinlÑsning

	bsr	close			; StÑng filen

init:
	move.l	current_mod,a0
	move.l	2(a0),a1
	cmp.l	#'M.K.',1080(a1)
	bne.s	inteMK
	move.w	#4,26(a0)	; 4 kanaler
	move.l	fyra,a3
	moveq	#1,d7
	move.w	#16,32(a0)
	bra	okformat
inteMK:
	cmp.l	#'4CHN',1080(a1)
	bne.s	inte4CHN
	move.w	#4,26(a0)	; 4 kanaler
	move.l	fyra,a3
	moveq	#1,d7
	move.w	#16,32(a0)
	bra	okformat
inte4CHN:
	cmp.l	#'FA04',1080(a1)
	bne.s	inteFA04
	move.w	#4,26(a0)	; 4 kanaler
	move.l	fyra,a3
	moveq	#1,d7
	move.w	#16,32(a0)
	bra	okformat
inteFA04:
	cmp.l	#'CD61',1080(a1)
	bne.s	inteCD6
	move.w	#6,26(a0)	; 6 kanaler
	move.l	sex,a3
	moveq	#2,d7
	move.w	#24,32(a0)
	bra	okformat
inteCD6:
	cmp.l	#'6CHN',1080(a1)
	bne.s	inte6CHN
	move.w	#6,26(a0)	; 6 kanaler
	move.l	sex,a3
	moveq	#2,d7
	move.w	#24,32(a0)
	bra	okformat
inte6CHN:
	cmp.l	#'CD81',1080(a1)
	bne.s	inteCD8
	move.w	#8,26(a0)	; 8 kanaler
	move.l	Ütta,a3
	moveq	#2,d7
	move.w	#32,32(a0)
	bra.s	okformat
inteCD8:
	cmp.l	#'8CHN',1080(a1)
	bne.s	inte8CHN
	move.w	#8,26(a0)	; 8 kanaler
	move.l	Ütta,a3
	moveq	#2,d7
	move.w	#32,32(a0)
	bra.s	okformat
inte8CHN:
	move.l	2(a0),d0
	bsr	slÑpp_minne
	move.l	unknown_format,a1
	moveq	#1,d1		; Felaktigt format
	bsr	form_alert
	bra	inteladdaennymodd
okformat:
	move.l	current_mod,a0
	addq.w	#6,a0
koppatillprocent:
	cmp.b	#'%',(a3)
	beq.s	skrivditnamnet
	move.b	(a3)+,(a0)+
	bra.s	koppatillprocent
skrivditnamnet:
	lea	name,a1
	moveq	#8+3,d0
koppavidare:
	move.b	(a1)+,(a0)+
	dbra	d0,koppavidare
	clr.b	(a0)+

	move.l	current_mod,a0
	move.l	2(a0),a1		; a1 pekar mot modulen
	move.w	26(a0),d1		; d1 antal kanaler
	lea	20(a1),a2		; a2 pekar mot sampleinfon
	lea	952(a1),a3		; a3 pekar mot songen

	move.b	950(a1),d0		; Kolla att restarten Ñr korrekt
	cmp.b	951(a1),d0
	bhi.s	ingetfelpÜrestarten
	clr.b	951(a1)
ingetfelpÜrestarten:

	lea	920(a1),a4		; Sista samplingsinfon i a4
	move.l	28(a0),a6
	add.l	#32000,a6
	add.l	a1,a6			; a6 Sista byten i mallocarean
	move.l	28(a0),a5
	add.l	a1,a5			; a5 Sista byten i modulen
	moveq	#31-1,d0		; 31 samplingar att vandra igenom
roterarattsamplingarna:			; Fixa till samplingarna
	tst.w	22(a4)			; Finns det en sampling pÜ denna
	bne.s	ensamplingÑrdet		; position?
	move.l	#dummy,16(a4)
	clr.l	20(a4)
	clr.l	26(a4)
	bra	ingensamplingtanÑsta
ensamplingÑrdet:
	moveq	#125-1,d5
	moveq	#0,d6
rensa1000sistabyten:			; Rensa 1000 sista bytsen i
	move.l	d6,-(a6)		; samplingen
	move.l	d6,-(a6)
	dbra	d5,rensa1000sistabyten

	moveq	#0,d5
	move.w	22(a4),d5
	subq.l	#1,d5
roteranersamplingenrÑtt:		; Rotera ner samplingarna rÑtt
	move.b	-(a5),d6
	asr.b	d7,d6
	move.b	d6,-(a6)
	move.b	-(a5),d6
	asr.b	d7,d6
	move.b	d6,-(a6)
	dbra	d5,roteranersamplingenrÑtt

	move.l	a6,16(a4)

	and.b	#$F,24(a4)		; RÑtt finetune
	cmp.b	#$40,25(a4)
	blo.s	volumeok
	move.b	#$40,25(a4)		; RÑtt volym
volumeok:
	cmp.l	#1,26(a4)
	beq.s	looplÑngdverkarstÑmma
	moveq	#0,d5
	moveq	#0,d6
	move.w	22(a4),d5
	move.w	26(a4),d6		; Kontrollera att looplÑngden
	add.w	28(a4),d6		; Ñr riktig
	sub.l	d6,d5
	bpl.s	looplÑngdverkarstÑmma
	neg.l	d5
	move.w	28(a4),d6
	sub.w	d5,d6
	move.w	d6,28(a4)
looplÑngdverkarstÑmma:

	moveq	#0,d5
	moveq	#0,d6
	move.w	26(a4),d5
	add.l	d5,d5
	moveq	#0,d6
	move.w	28(a4),d6
	add.l	d6,d6
	add.l	d5,d6
	move.l	d6,a2
	add.l	a6,a2
	move.l	a6,a3			; Fixa till loopningen
	add.l	d5,a3			; av samplingen pÜ slutet
	moveq	#125-1,d6
	cmp.l	#1,26(a4)
	bne.s	fixatillloopen
	move.w	22(a4),d5
	add.l	d5,d5
	move.l	d5,a2
	add.l	a6,a2
	moveq	#0,d5
fixatilltomloop:
	move.l	d5,(a2)+
	move.l	d5,(a2)+
	dbra	d6,fixatilltomloop
	bra.s	tomloopfixad
fixatillloopen:
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	dbra	d6,fixatillloopen
tomloopfixad:

	moveq	#0,d5
	cmp.l	#1,26(a4)
	bne.s	detÑrenloopadsam
	move.w	22(a4),d5
	add.l	d5,d5
	move.l	d5,20(a4)
	clr.l	26(a4)
	bra.s	oloopadklar
detÑrenloopadsam:
	move.w	26(a4),d5
	add.w	d5,d5
	move.l	d5,20(a4)
	move.w	28(a4),d5
	add.w	d5,d5
	move.l	d5,26(a4)
oloopadklar:
ingensamplingtanÑsta:
	lea	-30(a4),a4
	dbra	d0,roterarattsamplingarna

	move.l	current_mod,a0
	clr.w	42(a0)			; Fînstret ej gîmt
	addq.w	#6,a0
	bsr	get_a_window		; FÜ ett fînster till modulen
	bmi	slutpÜfînster
	move.l	current_mod,a0
	move.w	window_handle,(a0)

	bsr	fixloadedmods

	bsr	makearrow
	moveq	#0,d0
	rts
inteladdaennymodd:
	bsr	makearrow
	moveq	#-1,d0
	rts

fixloadedmods:			; Ordnar till laddadstrÑngen
	bsr	get_used_mods
	move.b	d0,d2
	move.l	biggplay,a1
	moveq	#LOADED,d1
	mulu	#SIZE_OBJECT,d1
	move.l	OB_SPEC(a1,d1),a2	; Fixa till laddade moddar
	move.l	(a2),a2
	bsr	fixittohex

	tst.l	current_playing_mod	; Uppdatera del
	beq.s	spelaringenmoduluppdateraej
	tst.w	infosize
	beq.s	spelaringenmoduluppdateraej
	moveq	#LOADED,d0
	bsr	updatethisareaofwindow
spelaringenmoduluppdateraej:
	rts

settheheight:
	dc.w	0

reinstallthousewindows:		; Reinstallera alla fînster till
	tst.w	MiNTispresent
	bne	noreisntallofwindows
	tst.w	MagX
	bne	noreisntallofwindows
	moveq	#0,d1		; modulen
	bsr	evnt_timer
	moveq	#0,d1
	bsr	evnt_timer
	moveq	#0,d1
	bsr	evnt_timer
	tst.w	controlhandle
	bmi.s	ingetcontrolfînster4
	bsr	createCONTROL
ingetcontrolfînster4:
	moveq	#MAXMOD-1,d7
	lea	modules,a6
checkifawindowandreinstallit:
	tst.w	(a6)
	bmi	notawindow
	movem.l	d7/a6,-(sp)
	tst.w	42(a6)
	beq.s	vanligakoors
	move.l	#$10001000,fx
	move.l	#$10001000,fx+4
	bra.s	gîmdakoors
vanligakoors:
	move.l	34(a6),fx
	move.l	38(a6),fx+4
gîmdakoors:
	addq.w	#6,a6
	bsr	fixitrightin		; Kolla om vi fick nytt fînster
	movem.l	(sp)+,d7/a6
	bpl.s	alltok			; annars dîda modulen
	tst.l	current_playing_mod
	beq.s	intedîdaspelaren
	move.l	current_playing_mod,a0
	move.w	(a0),d0
	cmp.w	(a6),d0
	bne.s	intedîdaspelaren
	move.w	#1,settheheight
	movem.l	d7/a6,-(sp)
	bsr	kill_current_player
	movem.l	(sp)+,d7/a6
	clr.w	settheheight
intedîdaspelaren:
	move.w	#-1,window_handle	; Markera ledigt pos i fînsterlistan
	move.l	2(a6),d0
	bsr	slÑpp_minne		; SlÑpp modulminne
alltok:
	move.w	window_handle,(a6)
notawindow:
	lea	RECORD(a6),a6
	dbra	d7,checkifawindowandreinstallit
	bsr	fixloadedmods
noreisntallofwindows:
	rts

felvidinlÑsning:
	bsr	close
	move.l	current_mod,a0
	move.l	2(a0),d0
	bsr	slÑpp_minne
	move.l	lÑsfel,a1
	moveq	#1,d1		; Slut pÜ minne
	bsr	form_alert
	bsr	makearrow
	moveq	#-1,d0
	rts

fel:	bsr	close
	move.l	filejfunnen,a1
	moveq	#1,d1			; Filen ej funnen
	bsr	form_alert
	bsr	makearrow
	moveq	#-1,d0
	rts

slÑpp_minne:	; d0 pekare till blocket
	bsr	installPID
	move.l	d0,-(sp)
	move.w	#$49,-(sp)
	trap	#1		; SlÑpp minnesarea
	bsr	removePID
	addq.w	#6,sp
	rts

fÜ_minne:	; d0 antal bytes
	bsr	installPID
	addq.l	#1,d0
	and.l	#$FFFFFFFE,d0
	move.l	d0,d7
	move.l	d0,-(sp)
	move.w	#$48,-(sp)
	trap	#1		; Fîrsîk begÑr înskad mÑngd minne
	bsr	removePID
	addq.w	#6,sp
	tst.l	d0
	rts

slutpÜminnefîrmodul:
	bsr	close
	move.l	slutpÜminne,a1
	moveq	#1,d1		; Slut pÜ minne
	bsr	form_alert
	bsr	makearrow
	moveq	#-1,d0
	rts

slutpÜfînster:
	move.l	slutpÜminne,a1
	moveq	#1,d1		; Slut pÜ fînster
	bsr	form_alert
	bsr	makearrow
	moveq	#-1,d0
	rts

get_a_window:			; a0 pekare till windownamnet
	move.l	a0,a6
	lea	fx,a1
	move.w	#0,(a1)+
	move.w	#0,(a1)+
	move.l	playing,a0
	move.w	OB_WIDTH(a0),(a1)+
	move.w	#0,(a1)+
	lea	aespb,a0
	move.w	#108,$18(a0)
	move.w	#6,$1a(a0)
	move.w	#5,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	#0,$30(a0)
	move.w	#(NAME+CLOSER+MOVER+FULLER+ICONIFIER),$32(a0)
	move.l	fx,$34(a0)
	move.l	fx+4,$38(a0)
	jsr	callaes		; Ta reda pÜ max storlek pÜ ett fînster
	lea	aespb,a0
	move.l	current_mod,a1
	move.l	34(a1),fx
	move.l	$436(a0),fx+4
fixitrightin:
	lea	aespb,a0
	move.w	#100,$18(a0)
	move.w	#5,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	#(NAME+CLOSER+MOVER+FULLER+ICONIFIER),$30(a0)
	move.l	fx,$32(a0)
	move.l	fx+4,$36(a0)
	jsr	callaes		; Skapa ett fînster
	lea	aespb,a0
	tst.w	$430(a0)
	bmi	detgickinteattfÜettfînstertillinfon
	move.w	$430(a0),window_handle
	move.w	#105,$18(a0)
	move.w	#6,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	window_handle,$30(a0)
	move.w	#WF_NAME,$32(a0)
	move.l	a6,$34(a0)
	jsr	callaes
	lea	aespb,a0
	move.w	#101,$18(a0)
	move.w	#5,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	window_handle,$30(a0)
	move.l	fx,$32(a0)
	move.l	fx+4,$36(a0)
	tst.w	42-6(a6)
	bne.s	sparejvÑrde
	move.l	$32(a0),34-6(a6)
	move.l	$36(a0),38-6(a6)
sparejvÑrde:
	jsr	callaes		; ôppna fînstret
	moveq	#0,d0
	rts
detgickinteattfÜettfînstertillinfon:
	moveq	#-1,d0
	rts

createCONTROL:		; ôppna controlfînstret
	move.l	controlpointer,a0
	lea	fx,a1
	move.l	#0,(a1)+
	move.w	OB_WIDTH(a0),(a1)+
	move.w	OB_HEIGHT(a0),(a1)+
	lea	aespb,a0
	move.w	#108,$18(a0)
	move.w	#6,$1a(a0)
	move.w	#5,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	#0,$30(a0)
	move.w	#(NAME+MOVER),$32(a0)
	move.l	fx,$34(a0)
	move.l	fx+4,$38(a0)
	jsr	callaes		; Ta reda pÜ max storlek pÜ ett fînster
	lea	aespb,a0
	move.l	ctrlxy,fx
	move.l	$436(a0),fx+4
	lea	aespb,a0
	move.w	#100,$18(a0)
	move.w	#5,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	#(NAME+MOVER),$30(a0)
	move.l	fx,$32(a0)
	move.l	fx+4,$36(a0)
	jsr	callaes		; Skapa ett fînster
	lea	aespb,a0
	tst.w	$430(a0)
	bmi	detgickinteattfÜettfînstertillinfon2
	move.w	$430(a0),controlhandle
	move.w	#105,$18(a0)
	move.w	#6,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	controlhandle,$30(a0)
	move.w	#WF_NAME,$32(a0)
	move.l	#nix,$34(a0)
	jsr	callaes
	lea	aespb,a0
	move.w	#101,$18(a0)
	move.w	#5,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	controlhandle,$30(a0)
	move.l	fx,$32(a0)
	move.l	fx+4,$36(a0)
	move.l	$32(a0),ctrlxy
	move.l	controlpointer,a1
	move.l	$32(a0),OB_X(a1)
	jsr	callaes		; ôppna fînstret
	moveq	#0,d0
	rts
detgickinteattfÜettfînstertillinfon2:
	move.w	#-1,controlhandle
	moveq	#-1,d0
	rts

nix:	dc.b	0,0

killCONTROL:		; StÑng controlfînstret
	lea	aespb,a0
	move.w	#102,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	controlhandle,$30(a0)
	jsr	callaes		; StÑng fînstret
	lea	aespb,a0
	move.w	#103,$18(a0)
	move.w	#1,$1a(a0)
	move.w	#1,$1c(a0)
	move.w	#0,$1e(a0)
	move.w	#0,$20(a0)
	move.w	controlhandle,$30(a0)
	jsr	callaes		; Ta bort fînstret
	move.w	#-1,controlhandle
	rts

general:
	lea	fx,a1
	move.l	setup_form,a2
	bsr	form_center		; Centrera
	lea	fx,a1
	moveq	#0,d1
	bsr	form_dial		; Reservera
	lea	fx,a1
	move.l	setup_form,a2
	moveq	#0,d1
	moveq	#4,d2
	bsr	objc_draw		; Rita formen
	move.l	setup_form,a1
	moveq	#TONER,d1
	bsr	form_do			; VÑnta pÜ aktion
	move.l	d0,-(sp)
	move.l	setup_form,a1
	bsr	show_butt_normal	; Visa formknappen normalt igen
	lea	fx,a1
	moveq	#3,d1
	bsr	form_dial		; SlÑpp
	move.l	(sp)+,d0
	cmp.w	#SPARA,d0
	bne.s	intesparainstÑllningar
	bsr	installera
	bra	sparainstÑllningar
intesparainstÑllningar:
	cmp.w	#AVBRYT,d0
	beq	setupform
installera:
	move.l	pointertoupdatetime,a0
	moveq	#3-1,d2
	moveq	#0,d0
fixit:	moveq	#0,d1
	move.b	(a0)+,d1
	beq.s	noll
	mulu	#10,d0
	sub.b	#'0',d1
	add.w	d1,d0	
	dbra	d2,fixit
noll:
	move.w	d0,updatetime

	move.l	setup_form,a0
	move.w	#MAIN,d0		; Kollar om det vi skall byta
	mulu	#SIZE_OBJECT,d0		; UMP
	move.w	OB_STATE(a0,d0.w),d1
	and.w	#SELECTED,d1
	beq.s	anvÑndBLiTTER
	tst.w	selectedUMP
	beq.s	alltklarthÑr
	bsr	get_used_mods
	tst.w	d0
	bne.s	nochangeofUMPnow
	clr.w	selectedUMP		; Byt till MAIN-UMP
	bra.s	alltklarthÑr
anvÑndBLiTTER:
	tst.w	selectedUMP
	bne.s	alltklarthÑr
	bsr	get_used_mods
	tst.w	d0
	bne.s	nochangeofUMPnow
	move.w	#1,selectedUMP		; Byte till BLiTTER-UMP
	bra.s	alltklarthÑr
nochangeofUMPnow:
	move.l	byteavUMP,a1
	moveq	#1,d1			; Kan ej byta UMP
	bsr	form_alert
alltklarthÑr:

	move.l	setup_form,a0
	move.w	#TEMPO,d0		; Kollar om det vi skall ha
	mulu	#SIZE_OBJECT,d0		; tempokontroll
	move.w	OB_STATE(a0,d0.w),d1
	clr.w	useemulatedtempo
	and.w	#SELECTED,d1
	beq.s	ingentempotack
	move.w	#1,useemulatedtempo
ingentempotack:

	move.l	setup_form,a0
	move.w	#VISACTRL,d0		; Kollar om det vi skall visa
	mulu	#SIZE_OBJECT,d0		; controlfînstret
	move.w	OB_STATE(a0,d0.w),d1
	and.w	#SELECTED,d1
	beq.s	ingetctrlfînster
	tst.w	controlhandle
	bpl.s	fînstretfinnsredan
	bsr	createCONTROL
	bra.s	fînstretfinnsredan
ingetctrlfînster:
	tst.w	controlhandle
	bmi.s	fînstretfinnsredan
	bsr	killCONTROL
fînstretfinnsredan:

	move.l	setup_form,a0
	move.w	#COLBARS,d0		; Kollar om det vi skall ha
	mulu	#SIZE_OBJECT,d0		; fÑrgvisning
	move.w	OB_STATE(a0,d0.w),d1
	clr.w	colorbars
	and.w	#SELECTED,d1
	beq.s	ingenfÑrgtack
	move.w	#1,colorbars
ingenfÑrgtack:

	move.l	setup_form,a0
	move.w	#STANG,d0		; Kollar om det vi skall
	mulu	#SIZE_OBJECT,d0		; stÑnga fînstret innan laddning
	move.w	OB_STATE(a0,d0.w),d1
	clr.w	closebeforeload
	and.w	#SELECTED,d1
	beq.s	ingenstÑngningtack
	move.w	#1,closebeforeload
ingenstÑngningtack:

	move.l	setup_form,a0
	move.w	#STOR,d0		; Kollar om det vi skall 
	mulu	#SIZE_OBJECT,d0		; uppdatera fînstret i tidsint.
	move.w	OB_STATE(a0,d0.w),d1
	and.w	#SELECTED,d1
	beq.s	intestoruppdatering1
	move.w	#-1,infosize
	clr.w	updateonoff
	bra.s	kollaomÑndrafînstret
intestoruppdatering1:
	move.l	setup_form,a0
	move.w	#LITEN,d0		; Kollar om det vi skall 
	mulu	#SIZE_OBJECT,d0		; uppdatera fînstret i tidsint.
	move.w	OB_STATE(a0,d0.w),d1
	and.w	#SELECTED,d1
	beq.s	intelitenuppdatering1
	clr.w	infosize
	clr.w	updateonoff
	bra.s	kollaomÑndrafînstret
intelitenuppdatering1:
	clr.w	infosize
	move.w	#-1,updateonoff
kollaomÑndrafînstret:
	tst.l	current_playing_mod
	beq.s	ingetsomspelar
	bsr	changewindow
ingetsomspelar:

	rts
sparainstÑllningar:
	moveq	#0,d7
	moveq	#2,d0		; Read + Write
	lea	magic,a0
	bsr	open
	bpl.s	koskit

	moveq	#1,d7
	moveq	#2,d0		; Read + Write
	lea	magicACC,a0
	bsr	open
	bmi.s	skit
koskit:
	move.l	#28+4,d0	; Sîk rÑtt i .PRGen
	bsr	seek
	bmi.s	felvidsparningavinstÑllningar

	move.l	#start-updatetime,d0
	lea	updatetime,a0	; Skriv ner instÑllningarna
	bsr	write
	bmi.s	felvidsparningavinstÑllningar

	bsr	close		; StÑng
	bmi.s	felvidsparningavinstÑllningar
skit:
	rts
felvidsparningavinstÑllningar:
	move.l	felvidinst,a1
	moveq	#1,d1		; Fel vid sparning
	bsr	form_alert
	rts

setupform:
	move.l	pointertoupdatetime,a0
	moveq	#0,d0
	move.w	updatetime,d0
	clr.b	3(a0)
	divu	#10,d0
	swap	d0
	add.b	#'0',d0
	move.b	d0,2(a0)
	clr.w	d0
	swap	d0
	divu	#10,d0
	add.b	#'0',d0
	move.b	d0,(a0)
	swap	d0
	add.b	#'0',d0
	move.b	d0,1(a0)

	move.l	setup_form,a0
	move.l	a0,a1
	move.w	#MAIN,d0		; Kollar vilken UMP som anvÑnds
	mulu	#SIZE_OBJECT,d0
	move.w	d0,d1
	add.w	#SIZE_OBJECT,d1
	or.w	#SELECTED,OB_STATE(a0,d0.w)
	and.w	#~SELECTED,OB_STATE(a0,d1.w)
	tst.w	selectedUMP
	beq.s	klllart07
	or.w	#SELECTED,OB_STATE(a0,d1.w)
	and.w	#~SELECTED,OB_STATE(a0,d0.w)
klllart07:
	move.l	setup_form,a0
	move.w	#VISACTRL,d0		; Kollar om det vi visar
	mulu	#SIZE_OBJECT,d0		; controlfînstret
	and.w	#~SELECTED,OB_STATE(a0,d0.w)
	tst.w	controlhandle
	bmi.s	klllart05
	or.w	#SELECTED,OB_STATE(a0,d0.w)
klllart05:
	move.l	setup_form,a0
	move.w	#TEMPO,d0		; Kollar om det vi skall ha
	mulu	#SIZE_OBJECT,d0		; tempokontroll
	and.w	#~SELECTED,OB_STATE(a0,d0.w)
	tst.w	useemulatedtempo
	beq.s	klllart
	or.w	#SELECTED,OB_STATE(a0,d0.w)
klllart:
	move.l	setup_form,a0
	move.w	#COLBARS,d0		; Kollar om det vi skall ha
	mulu	#SIZE_OBJECT,d0		; fÑrger nÑr vi spelar
	and.w	#~SELECTED,OB_STATE(a0,d0.w)
	tst.w	colorbars
	beq.s	klllart12
	or.w	#SELECTED,OB_STATE(a0,d0.w)
klllart12:
	move.l	setup_form,a0
	move.w	#STANG,d0		; Kollar om det vi skall
	mulu	#SIZE_OBJECT,d0		; stÑnga innan vi laddar
	and.w	#~SELECTED,OB_STATE(a0,d0.w)
	tst.w	closebeforeload
	beq.s	klllart121
	or.w	#SELECTED,OB_STATE(a0,d0.w)
klllart121:
	move.l	setup_form,a0
	move.w	#STOR,d0		; Kollar om det vi skall 
	mulu	#SIZE_OBJECT,d0		; uppdatera i tidsint.
	move.w	#LITEN,d1
	mulu	#SIZE_OBJECT,d1
	move.w	#OFF,d2
	mulu	#SIZE_OBJECT,d2
	tst.w	updateonoff
	beq.s	uppdateringpÜ
	and.w	#~SELECTED,OB_STATE(a0,d0.w)
	and.w	#~SELECTED,OB_STATE(a0,d1.w)
	or.w	#SELECTED,OB_STATE(a0,d2.w)
	bra.s	klllart122
uppdateringpÜ:
	tst.w	infosize
	bne.s	visaliteuppdatering
	and.w	#~SELECTED,OB_STATE(a0,d0.w)
	and.w	#~SELECTED,OB_STATE(a0,d2.w)
	or.w	#SELECTED,OB_STATE(a0,d1.w)
	bra.s	klllart122
visaliteuppdatering:
	and.w	#~SELECTED,OB_STATE(a0,d1.w)
	and.w	#~SELECTED,OB_STATE(a0,d2.w)
	or.w	#SELECTED,OB_STATE(a0,d0.w)
klllart122:
	rts

pointertoupdatetime:
	dc.l	0

open:		; a0 filnamn   d0 îppningsstatus
	move.w	d0,-(sp)
	move.l	a0,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.w	#8,sp
	tst.l	d0
	bpl.s	allokopen
	tst.w	d7
	beq.s	îk
	move.l	filejfunnen,a1
	moveq	#1,d1			; Filen ej funnen
	bsr	form_alert
îk:	moveq	#-1,d0
	rts
allokopen:
	move.w	d0,f_handle
	rts

seek:	clr.w	-(sp)
	move.w	f_handle,-(sp)
	move.l	d0,-(sp)
	move.w	#$42,-(sp)
	trap	#1
	lea	10(sp),sp
	tst.l	d0
	rts

write:	move.l	a0,-(sp)
	move.l	d0,-(sp)
	move.w	f_handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	rts

read:	move.l	a0,-(sp)
	move.l	d0,-(sp)
	move.w	f_handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	rts

close:	move.w	f_handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.w	#4,sp
	tst.w	d0
	rts


callUMP:			; Skapa lite musik!
	tst.w	useemulatedtempo	; Skall vi mata UMPen med tempo eller ej?
	bne.s	emulerainskiten
	move.w	#-1,emulation
	bsr	donotusetempocontrolonUMP
	bsr	music
	rts
emulerainskiten:
	move.w	#1,emulation
						; Kîr tempo
	cmp.l	#12500,temporÑknare
	bgt.s	kîrbaraskapandedennaframe2
	tst.l	temporÑknare
	beq.s	inteenlitenrestsenfîrraframen2
	move.l	temporÑknare,d0
	cmp.l	#12500,d0
	ble.s	detgickmindreÑnenframe2
kîrbaraskapandedennaframe2:
	move.l	aktivUMP,a5
	move.w	#125,356(a5)
	bsr	skapaUMPdatamedtempokontroll
	bra	tempoteratklart2
detgickmindreÑnenframe2:
	add.w	#50,d0
	divu	#100,d0
	move.l	aktivUMP,a5
	move.w	d0,356(a5)
	tst.w	d0
	beq.s	inteenlitenrestsenfîrraframen2
	bsr	skapaUMPdatamedtempokontroll
inteenlitenrestsenfîrraframen2:
	move.l	temporÑknare,d0
	cmp.l	#12500,d0
	bgt.s	tempoteratklart2
	move.l	d0,d2
	add.l	tempoadder,d0
	move.l	d0,temporÑknare		; RÑkna fram rÑknaren
	move.l	#12500,d1
	sub.l	d2,d1
	cmp.l	tempoadder,d1
	ble.s	rÑknaframenhalvmesyrinnanvislutar2
	bsr	music			; Kîr lite musik
	move.l	tempoadder,d0		; Skapa en del
	add.w	#50,d0
	divu	#100,d0
	move.l	aktivUMP,a5
	move.w	d0,356(a5)
	tst.w	d0
	beq.s	inteenlitenrestsenfîrraframen2
	bsr.s	skapaUMPdatamedtempokontroll
	bra.s	inteenlitenrestsenfîrraframen2
rÑknaframenhalvmesyrinnanvislutar2:	; Skapa det sista innan vi slutar
	tst.l	d1
	bpl.s	intesetillattdetblirpositivt2
	add.l	tempoadder,d1
intesetillattdetblirpositivt2:
	move.l	d1,-(sp)
	bsr	music			; Kîr lite musik
	move.l	(sp)+,d1
	divu	#100,d1
	move.l	aktivUMP,a5
	move.w	d1,356(a5)
	tst.w	d1
	beq.s	inteenlitenrestsenfîrraframen2
	bsr.s	skapaUMPdatamedtempokontroll
	bra.s	inteenlitenrestsenfîrraframen2
tempoteratklart2:
	sub.l	#12500,temporÑknare
	move.l	aktivUMP,a5
	move.w	#-1,356(a5)
defklart:
	rts			; Temporerat klart fîr denna VBL...

skapaUMPdatamedtempokontroll:
	tst.w	emulation
	bmi.s	skapaUMPdatamedtempokontrollNU
	beq.s	slutaskapa
	clr.w	emulation
	bra.s	skapaUMPdatamedtempokontrollNU
slutaskapa:
	rts

emulation:
	dc.w	-1

donotusetempocontrolonUMP:	; Kîr direkt utan tempo!
	move.l	aktivUMP,a5
skapaUMPdatamedtempokontrollNU:
	lea	AmigatoUMP-200,a6

	move.w	aud1per,d1
	add.w	d1,d1
	moveq	#0,d2
	move.w	0(a6,d1.w),d2
	move.l	d2,0+12(a5)		; Frekvensen fîr kanal 1
	moveq	#0,d1
	tst.w	chanel1onoff
	bpl.s	kan1av
	tst.l	(0+12+(3*16*4))(a5)
	bne.s	looppÜ1
	move.l	(0+12+(2*16*4))(a5),d0
	cmp.l	(0+12+(16*4))(a5),d0
	ble.s	kan1av
looppÜ1:move.w	aud1vol,d1
	bne.s	fullv1
kan1av:	addq.w	#1,mainwantzero
fullv1:	lsl.w	#8,d1
	move.l	d1,(0+12+(4*16*4))(a5)	; Volym

	move.w	aud2per,d1
	add.w	d1,d1
	moveq	#0,d2
	move.w	0(a6,d1.w),d2
	move.l	d2,12+12(a5)		; Frekvensen fîr kanal 2
	moveq	#0,d1
	tst.w	chanel2onoff
	bpl.s	kan2av
	tst.l	(12+12+(3*16*4))(a5)
	bne.s	looppÜ2
	move.l	(12+12+(2*16*4))(a5),d0
	cmp.l	(12+12+(16*4))(a5),d0
	ble.s	kan2av
looppÜ2:move.w	aud2vol,d1
	bne.s	fullv2
kan2av:	addq.w	#1,mainwantzero
fullv2:	lsl.w	#8,d1
	move.l	d1,(12+12+(4*16*4))(a5)	; Volym

	move.w	aud3per,d1
	add.w	d1,d1
	moveq	#0,d2
	move.w	0(a6,d1.w),d2
	move.l	d2,4+12(a5)		; Frekvensen fîr kanal 3
	moveq	#0,d1
	tst.w	chanel3onoff
	bpl.s	kan3av
	tst.l	(4+12+(3*16*4))(a5)
	bne.s	looppÜ3
	move.l	(4+12+(2*16*4))(a5),d0
	cmp.l	(4+12+(16*4))(a5),d0
	ble.s	kan3av
looppÜ3:move.w	aud3vol,d1
	bne.s	fullv3
kan3av:	addq.w	#1,mainwantzero
fullv3:	lsl.w	#8,d1
	move.l	d1,(4+12+(4*16*4))(a5)	; Volym

	move.w	aud4per,d1
	add.w	d1,d1
	moveq	#0,d2
	move.w	0(a6,d1.w),d2
	move.l	d2,8+12(a5)		; Frekvensen fîr kanal 4
	moveq	#0,d1
	tst.w	chanel4onoff
	bpl.s	kan4av
	tst.l	(8+12+(3*16*4))(a5)
	bne.s	looppÜ4
	move.l	(8+12+(2*16*4))(a5),d0
	cmp.l	(8+12+(16*4))(a5),d0
	ble.s	kan4av
looppÜ4:move.w	aud4vol,d1
	bne.s	fullv4
kan4av:	addq.w	#1,mainwantzero
fullv4:	lsl.w	#8,d1
	move.l	d1,(8+12+(4*16*4))(a5)	; Volym

	move.w	aud5per,d1
	add.w	d1,d1
	moveq	#0,d2
	move.w	0(a6,d1.w),d2
	move.l	d2,16+0+12(a5)		; Frekvensen fîr kanal 5
	moveq	#0,d1
	tst.w	chanel5onoff
	bpl.s	kan5av
	tst.l	(16+0+12+(3*16*4))(a5)
	bne.s	looppÜ5
	move.l	(16+0+12+(2*16*4))(a5),d0
	cmp.l	(16+0+12+(16*4))(a5),d0
	ble.s	kan5av
looppÜ5:move.w	aud5vol,d1
	bne.s	fullv5
kan5av:	addq.w	#1,mainwantzero
fullv5:	lsl.w	#8,d1
	move.l	d1,(16+0+12+(4*16*4))(a5)	; Volym

	move.w	aud6per,d1
	add.w	d1,d1
	moveq	#0,d2
	move.w	0(a6,d1.w),d2
	move.l	d2,16+12+12(a5)		; Frekvensen fîr kanal 6
	moveq	#0,d1
	tst.w	chanel6onoff
	bpl.s	kan6av
	tst.l	(16+12+12+(3*16*4))(a5)
	bne.s	looppÜ6
	move.l	(16+12+12+(2*16*4))(a5),d0
	cmp.l	(16+12+12+(16*4))(a5),d0
	ble.s	kan6av
looppÜ6:move.w	aud6vol,d1
	bne.s	fullv6
kan6av:	addq.w	#1,mainwantzero
fullv6:	lsl.w	#8,d1
	move.l	d1,(16+12+12+(4*16*4))(a5)	; Volym

	move.w	aud7per,d1
	add.w	d1,d1
	moveq	#0,d2
	move.w	0(a6,d1.w),d2
	move.l	d2,16+4+12(a5)		; Frekvensen fîr kanal 7
	moveq	#0,d1
	tst.w	chanel7onoff
	bpl.s	kan7av
	tst.l	(16+4+12+(3*16*4))(a5)
	bne.s	looppÜ7
	move.l	(16+4+12+(2*16*4))(a5),d0
	cmp.l	(16+4+12+(16*4))(a5),d0
	ble.s	kan7av
looppÜ7:move.w	aud7vol,d1
	bne.s	fullv7
kan7av:	addq.w	#1,mainwantzero
fullv7:	lsl.w	#8,d1
	move.l	d1,(16+4+12+(4*16*4))(a5)	; Volym

	move.w	aud8per,d1
	add.w	d1,d1
	moveq	#0,d2
	move.w	0(a6,d1.w),d2
	move.l	d2,16+8+12(a5)		; Frekvensen fîr kanal 8
	moveq	#0,d1
	tst.w	chanel8onoff
	bpl.s	kan8av
	tst.l	(16+8+12+(3*16*4))(a5)
	bne.s	looppÜ8
	move.l	(16+8+12+(2*16*4))(a5),d0
	cmp.l	(16+8+12+(16*4))(a5),d0
	ble.s	kan8av
looppÜ8:move.w	aud8vol,d1
	bne.s	fullv8
kan8av:	addq.w	#1,mainwantzero
fullv8:	lsl.w	#8,d1
	move.l	d1,(16+8+12+(4*16*4))(a5)	; Volym

	jsr	(a5)			; Utfîr rutinen

	rts

tempo:	dc.w	125	; Tempo i BPM, 125 default
temporÑknare:
	dc.l	0
tempoadder:
	dc.l	12500	; 125,00 default

music:
	lea	VU1,a0
	subq.w	#1,(a0)+
	bpl.s	noll1
	clr.w	-2(a0)
noll1:	subq.w	#1,(a0)+
	bpl.s	noll2
	clr.w	-2(a0)
noll2:	subq.w	#1,(a0)+
	bpl.s	noll3
	clr.w	-2(a0)
noll3:	subq.w	#1,(a0)+
	bpl.s	noll4
	clr.w	-2(a0)
noll4:	subq.w	#1,(a0)+
	bpl.s	noll5
	clr.w	-2(a0)
noll5:	subq.w	#1,(a0)+
	bpl.s	noll6
	clr.w	-2(a0)
noll6:	subq.w	#1,(a0)+
	bpl.s	noll7
	clr.w	-2(a0)
noll7:	subq.w	#1,(a0)+
	bpl.s	noll8
	clr.w	-2(a0)
noll8:

	addq.w	#$01,counter		; Dax att gÜ fram ett steg i patternet?
	move.w	counter(pc),d0
	cmp.w	speed(pc),d0
	blt	getnewfromshortes	;nonew			; Nix, fortsÑtt att spela pÜ instrumenten
	clr.w	counter 		; Jepp, rensa
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
	tst.w	gîrDMAtigen
	bne	setdma
	bra	endread 		; Gîr slut pÜ't

gîrDMAtigen:
	dc.w	0

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

song:	dc.l	0

				; Fixa nÑsta position och tolka den
getnew:	move.l	patterns,a0		; Pekare till aktuella pattern
	move.l	modsam,a2		; Pekare till samplingar? +C!
	move.l	song,a1

	move.w	pattpos(pc),lastpos
	move.w	whichpatt(pc),lastsongpatt
	move.w	chosedmap2,chosedmap
	move.b	songpos,lastsongpos

	moveq	#0,d0
	moveq	#0,d1
	move.b	songpos(pc),d0		; d0 vart i songen vi ligger
	move.b	0(a1,d0.w),d1		; Vilket pattern skall spelas nu?
	move.w	d1,whichpatt
	moveq	#64,d0
	mulu	divider,d0
	mulu	d0,d1
	add.w	pattpos(pc),d1		; Addera vart i patternet vi ligger just nu
	clr.w	dmacon			; Ingen dmacon =  inga nya anslag Ñn dÜ lÑnge
	bra	denspelarverkligen
getnewfromshortes:
	bra	nonew
denspelarverkligen:

	lea	aud1lc(pc),a3		; Pekare till samplingsdata
	lea	voice1(pc),a4		; Pekare till voiceinfon
	lea	VU1,a5
	move.w	#76,termoretrig
	bsr	playvoice		; Spela kanal
	lea	aud2lc(pc),a3		; Gîr samma sak fîr resten av kanalerna
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
	move.l	0(a0,d1.l),(a4) ; HÑmta in kanalen till voice
	addq.l	#4,d1		; nÑsta kanal i d1
	moveq	#0,d2
	move.b	$02(a4),d2
	and.b	#$F0,d2 	; Plocka ut om det finns nÜgon instrument-data
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$F0,d0
	or.b	d0,d2
	tst.b	d2		; d2 vilket instrument 0-$1f
	beq.s	setregs 	; Inget nytt instrument?
	moveq	#0,d3
	lea	samplestarts(pc),a1	; Pekare till tabellen îver vart samplingarna bîrjar i minnet
	move.w	d2,d4		; d2 Instrument till d4
	subq.w	#$01,d2
	add.w	d2,d2
	add.w	d2,d2
	mulu	#$1E,d4		; RÑtt offset fîr modulinstrumenten
	move.l	0(a1,d2.l),$04(a4)	; Pekare till sampling till voice
	move.w	0(a2,d4.l),$08(a4)	; LÑngden pÜ samplingen i bytes +22

	move.w	$02(a2,d4.l),$12(a4)	; Finetune + volym till voice	+24
					; Ingen looping hÑr
	move.l	$04(a4),$0A(a4)		; Loopbîrjan till voice
	move.w	$06(a2,d4.l),$0E(a4)	; LooplÑngd till voice
	move.l	$04(a2,d4.l),32(a4)	; LooplÑngd till voice
	move.l	4(a4),d0
	add.l	32(a4),d0
	move.l	d0,44(a4)
	move.w	$12(a4),$08(a3) 	; voice-volym till aud
;	move.w	(a4),d0
;	and.w	#$0FFF,d0		; Finns det nÜgon tonangivelse?
;	bne.s	setregs
	clr.l	48(a4)
setregs:move.w	(a4),d0
	and.w	#$0FFF,d0		; Finns det nÜgon tonangivelse?
	beq	checkcom2		; Nix, kolla om det finns kommandon
	move.b	$02(a4),d0		; Effectkommando 3? (Slida till angiven ton?)
	and.b	#$0F,d0
	cmp.b	#$03,d0
	bne.s	setperiod		; Nix
	bsr	setmyport		; Jepp, slida pÜ
	bra	checkcom2		; Testa flera kommandon oxo

setperiod:			; SÑtt frekvensen pÜ kanalen
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
	move.l	48(a4),-132(a3)		; SÑtt rÑtt offset pÜ samplingen
	move.w	$10(a4),$06(a3)
	bra	checkcom2

setdma: move.w	dmacon,d0

	lea	AmigatoUMP-200,a6
	move.l	aktivUMP,a5

	btst	#0,d0			;-------------------
	beq.s	wz_nch1 		;
	move.l	aud1lc(pc),wiz1lc	; SÑtt Wizcats uppspelare
	clr.w	mainwantzero
	move.b	aud1vol+1(pc),VU1+1
	moveq	#0,d1			; med data
	moveq	#0,d2			;
	move.w	aud1len(pc),d1		;
	move.l	voice1+32(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz1len		;
	move.l	d2,wiz1rpt		;

	move.l	aud1lc,d3		; Samplingspekare
	add.l	wiz1pos,d3
	move.l	d3,(0+12+(16*4))(a5)
	add.l	aud1lc,d1
	move.l	d1,(0+12+(2*16*4))(a5)	; Loopstart    d1
	move.l	d2,(0+12+(3*16*4))(a5)	; LooplÑngd    d2

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

	move.l	aud2lc,d3		; Samplingspekare
	add.l	wiz2pos,d3
	move.l	d3,(12+12+(16*4))(a5)
	add.l	aud2lc,d1
	move.l	d1,(12+12+(2*16*4))(a5)	; Loopstart    d1
	move.l	d2,(12+12+(3*16*4))(a5)	; LooplÑngd    d2

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

	move.l	aud3lc,d3		; Samplingspekare
	add.l	wiz3pos,d3
	move.l	d3,(4+12+(16*4))(a5)
	add.l	aud3lc,d1
	move.l	d1,(4+12+(2*16*4))(a5)	; Loopstart    d1
	move.l	d2,(4+12+(3*16*4))(a5)	; LooplÑngd    d2


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

	move.l	aud4lc,d3		; Samplingspekare
	add.l	wiz4pos,d3
	move.l	d3,(8+12+(16*4))(a5)
	add.l	aud4lc,d1
	move.l	d1,(8+12+(2*16*4))(a5)	; Loopstart    d1
	move.l	d2,(8+12+(3*16*4))(a5)	; LooplÑngd    d2

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

	move.l	aud8lc,d3		; Samplingspekare
	add.l	wiz8pos,d3
	move.l	d3,(24+12+(16*4))(a5)
	add.l	aud8lc,d1
	move.l	d1,(24+12+(2*16*4))(a5)	; Loopstart    d1
	move.l	d2,(24+12+(3*16*4))(a5)	; LooplÑngd    d2

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

	move.l	aud5lc,d3		; Samplingspekare
	add.l	wiz5pos,d3
	move.l	d3,(16+12+(16*4))(a5)
	add.l	aud5lc,d1
	move.l	d1,(16+12+(2*16*4))(a5)	; Loopstart    d1
	move.l	d2,(16+12+(3*16*4))(a5)	; LooplÑngd    d2

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

	move.l	aud6lc,d3		; Samplingspekare
	add.l	wiz6pos,d3
	move.l	d3,(28+12+(16*4))(a5)
	add.l	aud6lc,d1
	move.l	d1,(28+12+(2*16*4))(a5)	; Loopstart    d1
	move.l	d2,(28+12+(3*16*4))(a5)	; LooplÑngd    d2

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

	move.l	aud7lc,d3		; Samplingspekare
	add.l	wiz7pos,d3
	move.l	d3,(20+12+(16*4))(a5)
	add.l	aud7lc,d1
	move.l	d1,(20+12+(2*16*4))(a5)	; Loopstart    d1
	move.l	d2,(20+12+(3*16*4))(a5)	; LooplÑngd    d2

wz_nch8:tst.w	gîrDMAtigen
	bne	endread
	tst.b	mt_PattDelTime2
	bne.s	inteadderanu
	move.w	divider,d0
	add.w	d0,pattpos
inteadderanu:
	tst.b	break
	bne	nex
	move.b	mt_PattDelTime,d0
	beq.s	senread
	move.b	d0,mt_PattDelTime2
	clr.b	mt_PattDelTime
senread:
	cmpi.w	#$0800,pattpos
	bne.s	endread
	clr.w	pattpos
nex4:	clr.b	break
	not.w	chosedmap2
	tst.w	direction
	beq.s	forward
	clr.w	direction
	subq.b	#1,songpos
	bpl.s	endread
	move.b	songlength,songpos
	subq.b	#1,songpos
forward:
	addq.b	#1,songpos
	andi.b	#$7F,songpos
	move.b	songpos(pc),d1
	cmp.b	songlength(pc),d1		;$03B6
	bne.s	endread
set2:	move.b	songrestart(pc),songpos 	;$03B7
endread:tst.b	break
	bne.s	nex
	clr.w	dmacon
	clr.w	gîrDMAtigen
	rts
nex:	tst.w	loopingpartofpatt
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
nex3:	move.w	divider,d0
	sub.w	d0,pattpos
	bra	nex4

direction:
	dc.w	0

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
	move.w	$02(a4),d0	; ér det ett effectkommando pÜ den hÑr kanalen?
	and.w	#$0FFF,d0
	beq.s	nopp		; Nix
	move.b	$02(a4),d0	; Jepp, hÑmta in vilket
	and.b	#$0F,d0 	; Plocka ut vilket kommando det Ñr
	tst.b	d0		; Inget hÑr betyder arpeggio
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
	move.b	$03(a4),d0	; Ta reda pÜ om den skall slida upp eller ner volymen
	lsr.b	#4,d0
	tst.b	d0
	beq.s	voldown
mt_VolSlideUp:
	add.b	d0,$13(a4)	; Slida upp volymen sÜ mycket som anges
	cmpi.b	#$40,$13(a4)	; full volym redan?
	bmi.s	vol2
	move.b	#$40,$13(a4)	; SÑtt full volym
vol2:	move.w	$12(a4),$08(a3) ; SÑtt volymen till aud
	move.b	$13(a4),1(a5)
	rts

voldown:moveq	#0,d0		; Tona ner volymen	A
	move.b	$03(a4),d0
	and.b	#$0F,d0
mt_VolSlideDown2:
	sub.b	d0,$13(a4)	; Minska volymen
	bpl.s	vol3
	clr.b	$13(a4) 	; SÑtt till 0
vol3:	move.w	$12(a4),$08(a3) ; SÑtt volymen till aud
	move.b	$13(a4),1(a5)
	rts

portup: moveq	#0,d0		; Kommando 1
	move.b	$03(a4),d0	; HÑmta antal slidsteg
portupfast:
	sub.w	d0,$10(a4)	; Slida upp tonen
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$71,d0 	; Hîsta tonen redan?
	bpl.s	por2
	andi.w	#$F000,$10(a4)
	ori.w	#$71,$10(a4)	; SÑtt hîgsta ton isf
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
	cmp.b	#$0D,d0 	; Effectkommando D, hoppa till nÑsta pattern
	beq.s	pattbreak
	cmp.b	#$0B,d0 	; Effectkommando B, hoppa till angivet pattern
	beq.s	posjmp
	cmp.b	#$0C,d0 	; Effectkommando C, sÑtt volym
	beq	setvol
	cmp.b	#$0E,d0
	beq	setallEcommands
	cmp.b	#$0F,d0 	; Effectkommando F, sÑtt fart
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
	beq.s	skitidethÑrihuvudtaget
	lsl.l	#8,d0			; * 256
	moveq	#0,d7
	move.w	8(a4),d7
	add.l	32(a4),d7
	cmp.l	d7,d0
	bge.s	skitidethÑrihuvudtaget
	add.l	d0,48(a4)
	move.w	dmacon,d7
	move.w	20(a4),d6
	and.w	d6,d7
	bne.s	redansattsÑttoffsettendirekt
	rts
redansattsÑttoffsettendirekt:
	move.l	d0,-132(a3)
skitidethÑrihuvudtaget:
	rts


pattbreak:			; Kommando D, nÑsta pattern
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
	move.b	d0,songpos	; LÑgg det nya pattert i songpos
	clr.w	pattpos
	st	break
	rts

setvol: moveq	#0,d0		; Kommando C, sÑtt volym
	move.b	$03(a4),d0
	cmp.w	#$40,d0 	; Full volym?
	bmi.s	vol4
	move.b	#$40,$03(a4)	; SÑtt full volym
vol4:	move.b	$03(a4),$09(a3) ; SÑtt volym i aud
	move.b	$03(a4),$13(a4) ; SÑtt volym i voice
	move.b	$03(a4),1(a5)
	rts

setspeed:			; Kommando F, sÑtt fart
	moveq	#0,d0
	move.b	$03(a4),d0
	beq.s	rts2
	clr.w	counter 	; Rensa counter
	cmp.b	#$1f,d0
	bhi.s	detÑrentemposÑttning
	move.w	d0,speed	; SÑtt fart
rts2:	rts
detÑrentemposÑttning:
	move.b	d0,tempo+1
	move.l	#125*125,d7
	divu	d0,d7		; SÑtt sÜ att det blir rÑtt tempovÑrden
	move.l	d7,d6
	mulu	#100,d7
	move.l	d7,tempoadder
	swap	d6
	mulu	#100,d6
	divu	d0,d6
	and.l	#$FFFF,d6
	add.l	d6,tempoadder
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
	beq.s	dettaÑrfîrstagÜngenipattloopen
	subq.w	#1,loopingpartofpatt
	beq.s	detvarsistaloopingen
	st	break
detvarsistaloopingen:
	rts
dettaÑrfîrstagÜngenipattloopen:
	move.w	d0,loopingpartofpatt
	st	break
	rts

setloopinpattern:
	tst.w	loopingpartofpatt
	bne.s	intesÑttapattloopen
	move.w	lastpos,newlooppattpos
	move.b	songpos,newloopsongpos
	move.w	lastsongpatt,newloopwhichpatt
intesÑttapattloopen:
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
	move.l	aktivUMP,a5
	add.w	termoretrig,a5
	move.l	4(a4),(a5)
	move.l	(sp)+,a5
mt_rtnend2:
mt_rtnend:
	rts

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
	move.l	48(a4),-132(a3)		; SÑtt rÑtt offset pÜ samplingen
	move.w	$10(a4),$06(a3)
	move.w	#1,gîrDMAtigen
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
	move.b	d0,$12(a4) 	; SÑtt till 0
	move.w	$12(a4),$08(a3) ; SÑtt volymen till aud
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
	clr.b	$09(a3) ; SÑtt volym i aud
	clr.b	$13(a4) ; SÑtt volym i voice
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





noACC:	dc.w	0
menuID:	dc.w	-1

fastkeys:		; Snabbtangenter
	dc.w	13-1
	dc.w	$1709,MINFO,INFOMENU
	dc.w	$180F,MLOAD,FILEMENU
	dc.w	$1117,MNEXT,FILEMENU
	dc.w	$1615,MCLOSE,FILEMENU
	dc.w	$1900,MAKTUELL,FILEMENU
	dc.w	$1F00,MSTOPPIT,FILEMENU
	dc.w	$1910,PAUS,FILEMENU
	dc.w	$2100,MFORWARD,FILEMENU
	dc.w	$3000,MBAKWARD,FILEMENU
	dc.w	$2200,MGENERAL,FILEMENU
	dc.w	$1011,MQUIT,FILEMENU
	dc.w	$2308,GOM,FILEMENU
	dc.w	$2004,GOMD,FILEMENU

keybd:	dc.w	0
magic:	dc.b	'MODOVIUS.PRG',0
	even
magicACC:
	dc.b	'MODOVIUS.ACC',0
	even
f_handle:
	dc.w	0
setup_form:
	dc.l	0
messbuffer:
	ds.w	16
menupointer:
	dc.l	0
quitalert:
	dc.l	0
infopointer:
	dc.l	0
HELPpointer:
	dc.l	0
controlpointer:
	dc.l	0
fx:	dc.w	0
fy:	dc.w	0
fw:	dc.w	0
fh:	dc.w	0
	dc.w	0
windupdate:
	dc.w	0
window_handle:
	dc.w	0	; MèSTE BORT!!!!!!
filename:
	dc.b	'MODOVIUS.RSC',0
	even
label:
	dc.l	0
notfoundstring:
	dc.b	'[1][Where is MODOVIUS.RSC?][  Abort  ]',0
	even
test:
	dc.b	'[1][....!][   Ok   ]',0
	even
MiNTmenutext:
	dc.b	'  MOD Player ',0
	even

oldst:	dc.l	0
application:
	dc.w	0
MiNTispresent:
	dc.w	0
mtask:	dc.w	0
basepage:
	dc.l	0
env:	dc.l	0

playarea:		; Pekar till arean som UMPmodulen anvÑnder
	dc.l	0

UMP4:	incbin	lancev4.prg
	even

UMP8:	incbin	lancev8.prg
	even

BLiTTER4:
	incbin	blitump4.prg

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


VU1:	dc.w	0
VU2:	dc.w	0
VU3:	dc.w	0
VU4:	dc.w	0
VU5:	dc.w	0
VU6:	dc.w	0
VU7:	dc.w	0
VU8:	dc.w	0

antalkanaler:
	dc.w	0

modsam:	dc.l	0
patterns:
	dc.l	0
songlength:
	dc.b	0
songrestart:
	dc.b	0
speed:	dc.w	$06	; Fart
counter:dc.w	$00	; RÑknare fîr farten
songpos:dc.b	$00	; Vart i songen
break:	dc.b	0	; Dax att byta pattern?
pattpos:dc.w	$00	; Vart i patternet

whichpatt:
	dc.w	$00	; Patternt vi spelar pÜ

lastsongpatt:
	dc.w	0
lastpos:dc.w	0
lastsongpos:
	dc.w	0

mainwantzero:
	dc.w	0
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


voice1:	dc.l	0	; +0	Longwordet i songen
	dc.l	0	; +4	Pekare till samplingens bîrjan
	dc.w	0	; +8	LÑngden pÜ samplingen i bytes
	dc.l	0	; +10	Pekare till samplings bîrjan ?????????
	dc.w	0	; +14	LooplÑngden pÜ samplingen
	dc.w	0	; +16	AmigaFrekvensen
	dc.w	0	; +18	Finetune samt Volym
	dc.w	$01	; +20	Till fîr DMACTRL
	dc.w	0	; +22	+22 Styr myport +23 = sista byten i slidekommandot
	dc.w	0	; +24	Frekvensen i myport?
	dc.w	0	; +26	Vibratofrekvensen
	dc.l	0	; +28	om 0 ingen loop alls
	dc.l	0	; +32	SamplelÑngden i longword
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

wiz1lc: DC.L sample		; InnehÜller data om hur sampling skall skrivas till buffern
wiz1len:DC.L 0			; LÑngd
wiz1rpt:DC.L 0			; Repetition
wiz1pos:DC.L 0			; Vart ligger i dma-buffern
wiz1frc:DC.W 0			; Vilken frekvens spelar vi pÜ?

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

aud1lc: DC.L dummy		; Vart skall vi hÑmta samplingen nÜgonstans?
aud1len:DC.W 0			; LÑngd pÜ den
aud1per:DC.W 0			; Frekvens
aud1vol:DC.W 0			; Volym pÜ samplingen
aud1off:DC.W 0			; Sampleoffsetten
aud1lop:DC.W 0			; Om 0 skall normalvolym anvÑndas, annars
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

dmactrl:DC.W 0		; Har nÜgot med perioden att gîra

	dc.b	0,0
dummy:	ds.b	4000	; Tom buffer att spela upp om samplingen inte finns

sample: DS.W	1 ; dma-buffern
samdummy:
	dc.l	0	; Pekar ut var i buffern som vi skall skriva
vantapasam:
	dc.w	1	; Dax att vÑnta in dmat?

itab0:	DS.L	$30	; Tabell îver adderingskoefficienter till dmabuffern
stab0:	DS.L	$03A0-$30

style:	dc.b	$02,$12
	dc.b	$03,$13
	dc.b	$04
	dc.b	$05,$15
	dc.b	$06,$16
	dc.b	$00,$10
	dc.b	$01


	; 8x5, skrivs ut med ett tomt mellanrum, lagrad som 8x8
font:
	dc.b	%00111100
	dc.b	%11001110		; 0
	dc.b	%11010110
	dc.b	%11100110
	dc.b	%01111100
	dc.b	0,0,0

	dc.b	%00011000		; 1
	dc.b	%00111000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%01111110
	dc.b	0,0,0

	dc.b	%01110000
	dc.b	%10011000		; 2
	dc.b	%00110000
	dc.b	%01100000
	dc.b	%11111110
	dc.b	0,0,0

	dc.b	%01111000
	dc.b	%00001100		; 3
	dc.b	%00011100
	dc.b	%00001110
	dc.b	%11111100
	dc.b	0,0,0

	dc.b	%11000110
	dc.b	%11000110		; 4
	dc.b	%11111110
	dc.b	%00000110
	dc.b	%00000110
	dc.b	0,0,0

	dc.b	%11111110
	dc.b	%11000000		; 5
	dc.b	%11111100
	dc.b	%00001110
	dc.b	%11111110
	dc.b	0,0,0

	dc.b	%00001110
	dc.b	%00111000		; 6
	dc.b	%11111100
	dc.b	%11000110
	dc.b	%01111100
	dc.b	0,0,0

	dc.b	%11111110
	dc.b	%00001100		; 7
	dc.b	%00111100
	dc.b	%00110000
	dc.b	%00110000
	dc.b	0,0,0

	dc.b	%00111000
	dc.b	%01100110		; 8
	dc.b	%00111100
	dc.b	%01100110
	dc.b	%00111100
	dc.b	0,0,0

	dc.b	%00111100
	dc.b	%11001110		; 9
	dc.b	%01111110
	dc.b	%00000110
	dc.b	%00000110
	dc.b	0,0,0

signs:
	dc.b	%00111000
	dc.b	%01101100		; A (0)
	dc.b	%11000110
	dc.b	%11111110
	dc.b	%11000110
	dc.b	0,0,0

	dc.b	%11111000
	dc.b	%11001100		; B (1)
	dc.b	%11111000
	dc.b	%11001110
	dc.b	%11111100
	dc.b	0,0,0

	dc.b	%00111100
	dc.b	%11100000		; C (2)
	dc.b	%11000000
	dc.b	%11100000
	dc.b	%01111110
	dc.b	0,0,0

	dc.b	%11111100
	dc.b	%11000110		; D (3)
	dc.b	%11001100
	dc.b	%11011000
	dc.b	%11110000
	dc.b	0,0,0

	dc.b	%11111100
	dc.b	%11000000		; E (4)
	dc.b	%11110000
	dc.b	%11000000
	dc.b	%11111110
	dc.b	0,0,0

	dc.b	%11111110
	dc.b	%11000000		; F (5)
	dc.b	%11110000
	dc.b	%11000000
	dc.b	%11000000
	dc.b	0,0,0

	dc.b	%01111100
	dc.b	%11000000		; G (6)
	dc.b	%11011110
	dc.b	%11000110
	dc.b	%01111110
	dc.b	0,0,0

middle:
	dc.b	%00000000
	dc.b	%00000000		; - (0)
	dc.b	%00111100
	dc.b	%00000000
	dc.b	%00000000
	dc.b	0,0,0

	dc.b	%01101100
	dc.b	%11111110		; # (1)
	dc.b	%01101100
	dc.b	%11111110
	dc.b	%01101100
	dc.b	0,0,0

aespb:	dc.l	contrl,global,intin,intout,ptsin,ptsout
	section	BSS
contrl: ds.b	$18
intin:	ds.b	$200
ptsin:	ds.b	$200
intout: ds.b	$200
ptsout: ds.b	$200
global: ds.b	$20

superfastfinetune:
	ds.b	1024

action:	ds.w	1

ACCbasepage:
	ds.b	2000
stack:	ds.l	1

header_buffer:
	ds.b	24
DiskTransferAdress:
	ds.b	44
OrginalModul:
	ds.l	1

AmigatoUMP:
	ds.l	901

* END
