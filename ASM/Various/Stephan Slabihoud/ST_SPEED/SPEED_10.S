*
* Utility Programm "ST-SPEED" - (c) St.Slabihoud 1987-1990
*
* Wichtig! Dieser Programmcode muû voll verschiebbar sein!
*          (deshalb die vielen LEA xxx(pc),Ax  TST (Ax) !)
*
* Das Programm unterstÅtzt die XBRA-Methode (Hallo, Julian Reschke!).
* Die Kennung ist "SPxx". xx gibt die Versionsnummer an.
*
* Geschrieben wurde das Programm mit dem Devpac-ST V2.0 von HiSoft.
*

		plen	60
		llen	120					* 15 CPI (Semi-Schmalschrift)
		opt	o+,p+				* Optimieren, Absoluter Code

zeilen:		equ	12*16*80-1
etv_critic:	equ	$404				* Critical-Error-Handler
hdv_bpb:		equ	$472				* GETBPB-Vektor
hdv_rw:		equ	$476				* RWABS-Vektor
hdv_mediach:	equ	$47e				* Mediach-Vektor
drvbits:		equ	$4c2				* Drvbits-Systemvariable
_vblqueue:	equ	$456				* VBL-Liste
_dumpflg:		equ	$4ee				* Hardcopy-Flag
_sysbase:		equ	$4f2
_bootdev.hi:	equ	$446
_bootdev.lo:	equ	$447
vbl_slot:		equ	28				* VBL-Slot #7
kennung:		equ	'SP10'
version:		equ	'1'
revision:		equ	'0'

		output	\st_speed.bin

PRINT:	MACRO
		pea		\1
		move.w	#9,-(sp)			* PRINT
		trap		#1
		addq.l	#6,sp
		ENDM
SUP_EXEC:	MACRO
		pea		\1
		move.w	#$26,-(sp)		* SUP_EXEC
		trap		#14
		addq.l	#6,sp
		ENDM
MALLOC:	MACRO
		move.l	\1,-(sp)
		move.w	#$48,-(sp)		* MALLOC
		trap		#1
		addq.l	#6,sp
		ENDM
SETBLOCK:	MACRO
		move.l	\1,-(sp)
		move.l	\2,-(sp)
		clr.w	-(sp)
		move.w	#$4a,-(sp)		* SETBLOCK
		trap		#1
		lea		12(sp),sp
		ENDM
FCREATE:	MACRO
		clr.w	-(sp)			* Normale Datei
		pea		\1				* Dateiname
		move.w	#$3c,-(sp)		* FCREATE
		trap		#1
		addq.l	#8,sp
		ENDM
FWRITE:	MACRO
		pea		\1				* Adresse
		move.l	\2,-(sp)			* Bytes
		move.w	\3,-(sp)
		move.w	#$40,-(sp)		* FWRITE
		trap		#1
		lea		$c(sp),sp
		ENDM
FCLOSE:	MACRO
		move.w	\1,-(sp)
		move.w	#$3e,-(sp)		* FCLOSE
		trap		#1
		addq.l	#4,sp
		ENDM
FOPEN:	MACRO
		clr.w	-(sp)			* Lesen
		pea		\1				* Dateiname
		move.w	#$3d,-(sp)		* FOPEN
		trap		#1
		addq.l	#8,sp
		ENDM
FREAD:	MACRO
		pea		\1				* Save-Area
		move.l	\2,-(sp)			* Bytes
		move.w	\3,-(sp)
		move.w	#$3f,-(sp)		* FREAD
		trap		#1
		lea		$c(sp),sp
		ENDM
REINS_VEC:MACRO
		lea		\1,a0			* Vector-Adresse
		move.l	\2,d0			* Alter Inhalt
		bsr		vector_reinstall
		ENDM


progstart:dc.l		$12123456			* TOS-MAGIC 1
		dc.l		0				* TOS-ADRESS
		bra.s	res_mem			* TOS-START
		dc.w		0,$1029,$3847		* ALIGN + MY-MAGIC

***************************************** Einsprung vom Lader aus

		movem.l	d0-d7/a0-a6,-(sp)
		bsr		m_load2			* Parameter laden
		SUP_EXEC	installvec(pc)		* Programm in VBL-Queue eintragen
		SUP_EXEC	initoldvec1(pc)	* RAMDISK	(hdv_)
		SUP_EXEC	initoldvec2(pc)	* FILE-Protect (TRAP-1)
		PRINT	install(pc)
		moveq.l	#-1,d0
		moveq.l	#1,d1
njump:	mulu		#9999,d1
		mulu		#9999,d1
		dbra		d0,njump			* kurze Zeitverzîgerung
		movem.l	(sp)+,d0-d7/a0-a6
		lea		res_end(pc),a0
		add.l	#zeilen+1,a0		* Ende zurÅckmelden
		rts

***************************************** Programm in die VBL-QUEUE einbinden
* Einsprung vom TOS nach einem RESET

res_mem:	movem.l	d0-d7/a0-a6,-(sp)
		MALLOC	#80000			* Viel zu viel Speicher reservieren
		lea		res_end(pc),a1		* TatsÑchlich benîtigte Menge
		add.l	#zeilen+1,a1		* berechnen und Speicherbereich
		move.l	a1,d1			* verkleinern
		sub.l	d0,d1
		SETBLOCK	d1,d0			* Speicherbereich schÅtzen

		bsr		file_reinstall		* alten Vektor eintragen
		lea		fileflag(pc),a0	* Fileprotect erwÅnscht ?
		tst.w	(a0)
		beq.s	res_mem1			* Nein...
		bsr		file_install		* Vektoren eintragen

res_mem1:	bsr		ramdisk_vec_reinstall	* RAMDISK-Vektoren reinstallieren
		bsr		initoldvec1		* alte RAMDISK-Vektoren erneuern

		lea		installflag(pc),a0
		tst.w	(a0)
		beq		no_ramdisk		* keine RAMDISK vorhanden

		lea		resident(pc),a0
		tst.w	(a0)
		bne.s	resdisk			* reset-residente Disk

		lea		installflag(pc),a0	* wenn nicht resident, dann
		clr.w	(a0)				* Disk abmelden

		move.l	drvbits,d0		* Bit in der Systemvariablen
		clr.l	d1				* lîschen
		move.w	driveno(pc),d1
		tst.w	d1
		beq.s	no_ramdisk
		bclr		d1,d0
		move.l	d0,drvbits
		bra.s	no_ramdisk

resdisk:	MALLOC	#-1				* RAMDISK-Bereich schÅtzen
		sub.l	#30000,d0			* 30 KByte Sicherheit
		MALLOC	d0
		lea		mfree(pc),a0
		clr.l	(a0)				* nach RESET keine reinstallation
		move.l	puffer(pc),d1		* Adresse der RAMDISK
		add.l	groesse(pc),d1		* + Grîûe der RAMDISK
		sub.l	d0,d1			* - Blockanfang
		SETBLOCK	d1,d0
		move.l	drvbits,d0		* RAMDISK anmelden
		clr.l	d1
		move.w	driveno(pc),d1
		bset		d1,d0
		move.l	d0,drvbits
no_ramdisk:
		movem.l	(sp)+,d0-d7/a0-a6
installvec:
		movem.l	d0/a0/a2,-(sp)
		lea		start(pc),a2		* Start des Programmes
		move.l	_vblqueue,a0		* Start der VBLANK-Tabelle
		move.l	a2,vbl_slot(a0)	* in VBL-Slot eintragen

		move		sr,-(sp)			* Floppy-Motor ausschalten
		or.w		#$700,sr
		move.b	#14,$ffff8800.w	* Port A selektieren
		move.b	$ffff8800.w,d0		* aktuellen Wert holen
		and.b	#$f8,d0
		or.b		#5,d0			* Laufwerk A, Seite 0
		move.b	d0,$ffff8802.w		* in Port A zurÅckschreiben
		move		(sp)+,sr

		movem.l	(sp)+,d0/a0/a2
		rts
initoldvec1:
		lea		o_bpb(pc),a0		* alter BPB-Vektor
		move.l	hdv_bpb,(a0)
		lea		o_rw(pc),a0		* alter RW-Vektor
		move.l	hdv_rw,(a0)
		lea		o_media(pc),a0		* alter MEDIA-Vektor
		move.l	hdv_mediach,(a0)
		lea		mybpb(pc),a0		* Vektoren installieren
		move.l	a0,hdv_bpb
		lea		myrwabs(pc),a0
		move.l	a0,hdv_rw
		lea		mymedia(pc),a0
		move.l	a0,hdv_mediach
		rts
initoldvec2:
		lea		trap1_old(pc),a0	* alter TRAP-1-Vektor
		move.l	$84.w,(a0)
		lea		fileflag(pc),a0
		tst.w	(a0)
		beq.s	kein_fileprotect1	* kein Fileprotect erwÅnscht
		bsr		file_install		* Vektoren eintragen
		bra.s	initoldvecend
kein_fileprotect1:
		bsr		file_reinstall		* Vektoren lîschen
initoldvecend:
		rts

***************************************** Anfang Hauptroutine

		dc.b		'XBRA'
		dc.l		kennung
		dc.l		0
start:	move.l	a0,-(sp)
		lea		speedflag(pc),a0
		tst.w	(a0)		 		* Computer verlangsamen ?
		bne.s	speedwait			* Ja...
timeout:	move.l	(sp)+,a0
		tst.w	$4ee.w    		* ALT+HELP gedrÅckt ? (_dumpflg)
		beq.s	haupt     		* Ja !
		rts

speedwait:move.l	d0,-(sp)
		move.l	speedtime(pc),d0
time1:	nop
		dbra		d0,time1
		move.l	(sp)+,d0
		bra.s	timeout

***************************************** ALT+HELP wurde gedrÅckt

haupt:	lea		menueflag(pc),a0
		tst.w	(a0)				* MenÅ anzeigen
		bne.s	schleife			* Nein
		bsr 		maus_aus			* Maus ausschalten
		bsr 		sichere_screen		* Screenbereich sichern
menue:	bsr		loesche_screen		* Screenbereich lîschen
		PRINT	text(pc)			* Text ausgeben

schleife:	bsr		inkey			* Tastatur-Abfrage
		bset		#5,d0			* Nur Kleinbuchstaben

		cmpi.b	#'h',d0			* Hardcopy
		beq		m_hardcopy		* drucken !!!
		cmpi.b	#'q',d0			* ZurÅck zum
		beq.s	m_quit			* Programm (GEM-Desktop)
		cmpi.b	#' ',d0			* wie Q
		beq.s	m_quit
		cmpi.b	#'c',d0			* Synchronisation
		beq		m_sync			* 50 <--> 60 Hz
		cmpi.b	#'a',d0			* Menuemeldung ein/aus
		beq		m_menueaa
		cmpi.b	#'p',d0			* RESET cold
		beq.s	m_reset
		cmpi.b	#'r',d0			* RESET warm
		beq		m_reset1
		cmpi.b	#'d',d0			* RAMDISK
		beq		m_startram
		cmpi.b	#'b',d0			* BOOT - Device
		beq		m_bootdevice
		cmpi.b	#'w',d0			* WRITE - Protect
		beq		m_write
		cmpi.b	#'s',d0			* SAVE - Default
		beq		m_save
		cmpi.b	#'l',d0			* LOAD - Default
		beq		m_load
		cmpi.b	#'x',d0			* XBRA - List
		beq		m_xbra
		cmpi.b	#'i',d0			* System - Info
		beq		m_stspeed
		cmpi.b	#'f',d0			* File - Protect
		beq		m_file
		cmpi.b	#'0',d0			* Tastencode >= '0'
		bge.s	speed			* Ja !
notspeed:	bra		schleife
speed:	cmpi.b	#'9',d0			* Tastencode <= '9'
		ble 		speed1			* Ja !
		bra.s	notspeed

***************************************** ZurÅck zum Programm oder GEM-Desktop

m_quit:	lea		menueflag(pc),a0
		tst.w	(a0)
		bne.s	ende
		bsr 		hole_screen		* Screenbereich zurÅckholen
ende:	move.w	#-1,_dumpflg		* Hardcopy-Flag auf -1 setzen
		lea		menueflag(pc),a0
		tst.w	(a0)
		bne.s	ende1
		bsr 		maus_an			* Maus wieder anschalten
ende1:	rts						* ZurÅck zum Programm

***************************************** RESET

m_reset:	lea		progstart(pc),a0	* TOS-Magic lîschen
		clr.l	(a0)

		REINS_VEC	$84,trap1_old(pc)	* TRAP-1 Vector reinstallieren

		lea		installflag(pc),a0	* RAMDISK vorhanden ?
		tst.w	(a0)
		beq.s	m_reset1			* Nein...

		bsr		ramdisk_vec_reinstall

		move.l	drvbits,d0
		clr.l	d1
		move.w	driveno(pc),d1
		tst.w	d1
		beq.s	m_reset1
		bclr		d1,d0
		move.l	d0,drvbits
m_reset1:	move.l	_sysbase,a0		* in den RESET-Vektor springen
		jmp		(a0)

***************************************** Ausgabe einer Hardcopy

m_hardcopy:
		lea		menueflag(pc),a0
		tst.w	(a0)
		bne.s	hard1
		bsr 		hole_screen
hard1:	move.w	#20,-(sp)			* XBIOS 20 -> Hardcopy
		trap		#14
		addq.l	#2,sp
		bra.s	ende

***************************************** Synchronisation  50 <--> 60 Hz

m_sync:	bchg.b	#1,$ffff820a.w
		bra		menue

***************************************** VerÑndern der Geschwindigkeit

speed1:	cmpi.b	#'0',d0
		beq.s	speednormal
		clr.l	d1
		move.b	d0,d1
		sub.b	#48,d1			* Taste 1 bis 9
		mulu		#1070,d1
		lea		speedtime(pc),a0
		move.l	d1,(a0)
		lea		speedflag(pc),a0
		move.w	#-1,(a0)
		bra 		m_quit
speednormal:
		lea		speedflag(pc),a0
		clr.w	(a0)
		lea		speedtime(pc),a0
		clr.l	(a0)
		bra 		m_quit

***************************************** MenÅflag invertieren

m_menueaa:lea		menueflag(pc),a0
		not.w	(a0)
		move.w	#-1,_dumpflg
		tst.w	(a0)
		beq 		ende1
		bsr 		hole_screen
		bsr 		maus_an
		bra 		ende1
	
***************************************** RAMDISK

m_startram:
		lea		menueflag(pc),a0
		tst.w	(a0)
		bne		m_quit
		bsr 		loesche_screen
		lea		installflag(pc),a0
		tst.w	(a0)				* Ist bereits eine RAMDISK vorhanden ?
		bne		reinstall			* Ja, dann evtl. reinstallieren

		lea		resident(pc),a0
		clr.w	(a0)				* nicht resident
		lea		residentchar(pc),a0
		move.b	#'q',(a0)
warte3b:	PRINT	installram(pc)
warte3:	bsr		inkey
		bset		#5,d0
		cmp.b	#'q',d0			* ZurÅck zum MenÅ
		beq		menue
		cmp.b	#'t',d0			* Resident <-> Normal
		beq.s	resjump
		cmp.b	#'c',d0			* andere Laufwerkskennung
		bcc.s	char1			* BHS
		cmp.b	#'0',d0
		bcs.s	warte3			* BLO
		cmp.b	#'9',d0
		bhi.s	warte3			* BHI
		bsr		initram			* RAMDISK einrichten
		bmi		raushier			* ein Fehler ist aufgetreten
		lea		installflag(pc),a0
		move.w	#-1,(a0)			* RAMDISK installiert

warte6:	bsr 		wait
		bra		menue
char1:	cmp.b	#'p',d0			* maximal 14 Laufwerke als
		bhi.s	warte3			* RAMDISK mîglich
		bclr		#5,d0
		lea		drivechar(pc),a0
		move.b	d0,(a0)
		sub.b	#65,d0
		lea		drivenr(pc),a0		* andere Laufwerkskennung
		move.b	d0,(a0)
		bra.s	warte3b
resjump:	lea		residentchar(pc),a0
		cmp.b	#'q',(a0)			* VT-52 Code (ESC q)
		beq.s	nowresident
		move.b	#'q',(a0)
		lea		resident(pc),a0
		clr.w	(a0)
		clr.w	d0
		bra.s	warte3b
nowresident:
		move.b	#'p',(a0)			* VT-52 Code (ESC p)
		lea		resident(pc),a0
		move.w	#-1,(a0)
		clr.w	d0
		bra		warte3b

reinstall:lea		mfree(pc),a0		* RAMDISK reinstallieren
		tst.l	(a0)				* Reinstallieren mîglich ?
		bne.s	reinstallok		* Ja...
		PRINT	impossible(pc)
		bsr		ramdisksize
		bra.s	warte6
reinstallok:
		PRINT	reinstallmenu(pc)
		bsr		ramdisksize		* Grîûe der RAMDISK ausgeben
warte5:	bsr		inkey
		bset		#5,d0
		cmp.b	#'q',d0			* ZurÅck zum MenÅ
		beq		menue
		cmp.b	#'r',d0			* Reinstallieren
		bne.s	warte5
		
		move.l	drvbits,d0
		clr.l	d1
		move.w	driveno(pc),d1
		tst.w	d1
		beq.s	exitus2
		bclr		d1,d0			* Laufwerk abmelden
		move.l	d0,drvbits
exitus2:	move.l	mfree(pc),-(sp)	* Speicher freigeben
		move.w	#$49,-(sp)		* MFREE
		trap		#1
		addq.l	#6,sp
		bsr 		loesche_screen
		PRINT	reinstallram(pc)
		lea		installflag(pc),a0
		clr.w	(a0)
		bsr 		wait
		bra 		menue

raushier:	move.l	drvbits,d0
		clr.l	d1
		move.w	driveno(pc),d1
		beq.s	exitus
		bclr		d1,d0
		move.l	d0,drvbits
exitus:	bsr 		loesche_screen
		PRINT	errorram(pc)		* Fehlermeldung
		bsr 		wait
		bra		menue

ramdisksize:
		PRINT	disksize(pc)		* Grîûe, der RAMDISK ausgeben
		move.l	groesse(pc),d1
		lea		freezahl(pc),a2
		bsr		binasc
		PRINT	freezahl(pc)
		rts

initram:	ext.w	d0
		sub.w	#48,d0			* ASCII nach Zahl wandeln
		bne.s	keinenull			* gleich null?
		move.w	#10,d0			* ja, dann 1 MB
keinenull:mulu		#100,d0
		lea		numcl(pc),a0
		move.w	d0,(a0)			* Anzahl der freien Cluster
		add.l	#9,d0			* 9 KB Verwaltung
		lsl.l	#8,d0			* mal 1024
		lsl.l	#2,d0
		lea		groesse(pc),a0
		move.l	d0,(a0)			* Gesamtgrîûe

		MALLOC	d0				* Speicher reservieren
		tst.l	d0
		beq.s	error

		lea		puffer(pc),a0
		move.l	d0,(a0)			* Pufferadresse retten
		lea		mfree(pc),a0		* ... um die RAMDISK
		move.l	d0,(a0)			* wieder zu lîschen

		move.l	d0,a0			* Adresse des RAM-Disk-Puffers
		move.l	#18*128-1,d0		* Grîûe der Verwaltungssektoren
clearit:	clr.l	(a0)+			* Boot-Sektor und FATs lîschen
		dbra		d0,clearit

		move.l	drvbits,d0		* Drvbits holen
		clr.w	d1
		move.b	drivenr(pc),d1		* Startwert, Laufwerk X-1
		subq.b	#1,d1
fdlp:	addq.w	#1,d1			* nÑchstes Laufwerk
		cmp.w	#16,d1			* schon bei 16 angekommen?
		beq.s	error			* ja, dann Fehler
		btst		d1,d0			* Laufwerk installiert?
		bne.s	fdlp				* ja, weitersuchen

		bset		d1,d0			* Bit fÅr Laufwerk setzen
		move.l	d0,drvbits		* Drvbits auffrischen
		lea		driveno(pc),a0
		move.w	d1,(a0)			* Laufwerksnummer merken

		add.w	#65,d1			* in ASCII wandeln
		lea		drvstr(pc),a0
		move.b	d1,(a0)			* in String schreiben
		bsr 		loesche_screen
		PRINT	drivemsg(pc)		* Laufwerksmessage

		clr.l	d0				* kein Fehler passiert
		rts
error:	moveq	#-1,d0
		rts

ramdisk_vec_reinstall:
		REINS_VEC	hdv_rw,o_rw(pc)
		REINS_VEC	hdv_bpb,o_bpb(pc)
		REINS_VEC	hdv_mediach,o_media(pc)
		rts

		dc.b 	'XBRA'
		dc.l		kennung
o_bpb:	dc.l 	0
mybpb:	lea		installflag(pc),a0
		tst.w	(a0)
		beq.s	mybpb1			* keine RAMDISK vorhanden
		move.w	driveno(pc),d0
		cmp.w	4(sp),d0
		beq.s	newbpb
mybpb1:	move.l	o_bpb(pc),a0
		jmp		(a0)
newbpb:	lea		protobpb(pc),a0
		move.l	a0,d0
		rts

		dc.b 	'XBRA'
		dc.l		kennung
o_rw:	dc.l 	0
myrwabs:	move.w	14(sp),d0			* Disknummer
		move.l	protect(pc),d1
		btst		d0,d1			* Ist Bit gesetzt ?
		bne.s	no_write			* Ja, dann nicht schreiben...
is_read:	lea		installflag(pc),a0
		tst.w	(a0)
		beq.s	myrwabs1			* keine RAMDISK vorhanden
		move.w	driveno(pc),d0
		cmp.w	14(sp),d0
		beq.s	newrw
myrwabs1:	move.l	o_rw(pc),a0
		jmp		(a0)
no_write:	move.w	4(sp),d0
		btst		#0,d0			* Lesen oder schreiben ?
		beq.s	is_read			* Lesen, dann nichts machen...
retry:	move.l	#-13,d0			* Schreiben -> Fehler...
		move.w	14(sp),-(sp)		* Disknummer
		move.w	d0,-(sp)			* Error
		moveq	#-1,d0
		move.l	etv_critic,a0		* ETV_CRITIC
		jsr		(a0)				* Toll! Eine schreibgeschÅtzte
		addq.l	#4,sp			* RAMDISK
		cmp.l	#$10000,d1		* -XX=Abbruch, $10000=Retry
		beq.s	retry
		move.l	#-13,d0
		rts

newrw:	clr.l	d0				* d0.l vorbereiten
		move.w	12(sp),d0			* Sektoranzahl
		lsl.l	#8,d0
		lsl.l	#1,d0
		move.l	6(sp),a0			* Pufferadresse
		move.w	10(sp),d1			* Sektoranzahl

		move.l	puffer(pc),a1
		add.l	d0,a1			* plus Offset
		move.w	4(sp),d0			* R/W-Flag
		btst		#0,d0			* Lesen oder schreiben?
		beq.s	copysec			* Lesen
		exg		a0,a1			* zum Schreiben nur Pufferadressen vertauschen

copysec:	move.l	a0,d0			* Adresse gerade?
		btst		#0,d0			* Bit 0 gesetzt?
		bne.s	ungerade			* ja
		move.l	a1,d0			* Adresse gerade?
		btst		#0,d0
		beq.s	gerade			* nein

ungerade:	subq.l	#1,d1
ram_1:	moveq.l	#63,d0
ram_lp:	move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		dbra		d0,ram_lp
		dbra		d1,ram_1
		bra.s	newmedia
gerade:	movem.l	d2-d7/a2-a6,-(sp)
		move.w	d1,-(sp)
ram_even:	movem.l	(a1)+,d0-d7/a2-a6	* Diese superschnelle Kopierroutine
		movem.l	d0-d7/a2-a6,(a0)	* geht auf's Luftschloû
		movem.l	(a1)+,d0-d7/a2-a6	* (Scheibenkleister) zurÅck.
		movem.l	d0-d7/a2-a6,52(a0)	* Ist Åber 13.5 MBit/s schnell...
		movem.l	(a1)+,d0-d7/a2-a6
		movem.l	d0-d7/a2-a6,104(a0)
		movem.l	(a1)+,d0-d7/a2-a6
		movem.l	d0-d7/a2-a6,156(a0)
		movem.l	(a1)+,d0-d7/a2-a6
		movem.l	d0-d7/a2-a6,208(a0)
		movem.l	(a1)+,d0-d7/a2-a6
		movem.l	d0-d7/a2-a6,260(a0)
		movem.l	(a1)+,d0-d7/a2-a6
		movem.l	d0-d7/a2-a6,312(a0)
		movem.l	(a1)+,d0-d7/a2-a6
		movem.l	d0-d7/a2-a6,364(a0)
		movem.l	(a1)+,d0-d7/a2-a6
		movem.l	d0-d7/a2-a6,416(a0)
		movem.l	(a1)+,d0-d7/a2-a4
		movem.l	d0-d7/a2-a4,468(a0)
		lea		512(a0),a0
		subq.w	#1,(sp)
		bne.s	ram_even
		tst.w	(sp)+
		movem.l	(sp)+,d2-d7/a2-a6
newmedia:	moveq.l	#0,d0
		rts

		dc.b 	'XBRA'
		dc.l		kennung
o_media:	dc.l 	0
mymedia:	lea		installflag(pc),a0
		tst.w	(a0)
		beq.s	mymedia1			* keine RAMDISK vorhanden
		move.w	driveno(pc),d0
		cmp.w	4(sp),d0
		beq.s	newmediax
mymedia1:	move.l	o_media(pc),a0
		jmp		(a0)
newmediax:clr.l	d0
		rts

***************************************** BOOT - Device

m_bootdevice:
		lea		menueflag(pc),a0
		tst.w	(a0)
		bne		m_quit
		bsr 		loesche_screen
		PRINT	boottext(pc)

		move.l	drvbits,d0		* Drvbits holen
		move.w	#-1,d1			* Startwert, Laufwerk A-1
ffdlp:	addq.w	#1,d1			* nÑchstes Laufwerk
		cmp.w	#16,d1			* schon bei 16 angekommen?
		beq.s	fende			* ja, dann Fehler
		btst		d1,d0			* Laufwerk installiert?
		beq.s	ffdlp
		movem.l	d0/d1,-(sp)
		add.w	#65,d1			* ASCII
		move.w	d1,-(sp)			* Laufwerk
		move.w	#2,-(sp)
		trap		#1
		addq.l	#4,sp
		PRINT	spaces(pc)
		movem.l	(sp)+,d0/d1
		bra.s	ffdlp
fende:	bsr 		inkey
		bclr		#5,d0
		cmp.b	#'Q',d0
		beq		menue
		ext.w	d0
		sub.w	#65,d0
		move.l	drvbits,d1
		btst		d0,d1
		bne.s	fok
		bra.s	fende
fok:		move.b	d0,_bootdev.hi		* Laufwerk in LOW- und HIGH-Byte
		move.b	d0,_bootdev.lo		* eintragen. Falls ein gepatchtes TOS
		bra		menue			* verwendet wird, durch 
								* MOVE.W D0,_BOOTDEV.HI ersetzen.

***************************************** WRITE - Protect

m_write:	lea		menueflag(pc),a0
		tst.w	(a0)
		bne		m_quit
		bsr 		loesche_screen
write2:	PRINT	writetext(pc)

		bsr.s	show_protected		* geschÅtzte Laufwerke anzeigen

		bsr 		inkey
		bclr		#5,d0
		cmp.b	#'Q',d0			* Abbruch
		beq		menue
		ext.w	d0
		sub.w	#65,d0
		move.l	drvbits,d6
		btst		d0,d6			* Ist das Laufwerk vorhanden ?
		bne.s	wok				* Ja...
		bra.s	wende
wok:		move.l	protect(pc),d7		* Laufwerk (ent-)schÅtzen
		bchg		d0,d7
		lea		protect(pc),a0
		move.l	d7,(a0)
		bra.s	write2

show_protected:
		move.w	#-1,d6			* Startwert, Laufwerk A-1
ffdlpw:	move.l	drvbits,d5		* Drvbits holen
		move.l	protect(pc),d7		* Protect Bits
		addq.w	#1,d6			* nÑchstes Laufwerk
		cmp.w	#16,d6			* schon bei 16 angekommen?
		beq.s	wende			* ja, dann Fehler
		btst		d6,d5			* Laufwerk installiert?
		beq.s	ffdlpw			* Nein !
		btst		d6,d7
		beq.s	wjump1			* WRITE Protect off
		PRINT	inv_on(pc)
wjump1:	move.l	d6,d1
		add.w	#65,d1			* ASCII
		move.w	d1,-(sp)			* Laufwerk
		move.w	#2,-(sp)
		trap		#1
		addq.l	#4,sp
		btst		d6,d7
		beq.s	wjump2			* WRITE Protect off
		PRINT	inv_off(pc)
wjump2:	PRINT	spaces(pc)
		bra.s	ffdlpw
wende:	rts

***************************************** SAVE - Default

m_save:	bsr		file_reinstall		* Schutz deaktivieren
		bsr.s	m_save2
		lea		fileflag(pc),a0
		tst.w	(a0)
		beq		menue			* Schutz nicht mehr aktivieren
		bsr		file_install		* Schutz wieder an
		bra		menue
m_save2:	FCREATE	infoname(pc)		* Datei erstellen
		tst.w	d0
		bmi.s	serror
		move.w	d0,d7
		FWRITE	save_area(pc),#40,d7	* Daten schreiben
		FCLOSE	d7				* Datei schlieûen
serror:	rts

***************************************** LOAD - Default

m_load:	bsr.s	m_load2
		bra		menue
m_load2:	FOPEN	infoname(pc)		* Datei îffnen
		tst.w	d0
		bmi.s	lerror
		move.w	d0,d7
		FREAD	save_area(pc),#40,d7	* Daten laden
		FCLOSE	d7				* Datei schlieûen
lerror:	rts

***************************************** XBRA - List

m_xbra:	lea		menueflag(pc),a0
		tst.w	(a0)
		bne		m_quit
		bsr 		loesche_screen
		PRINT	xbra_home(pc)

		clr.l	d6				* ZeilenzÑhler = 0

		move.w	#8,a6			* a6 - Vector
xbra_a:	move.l	(a6),d7			* d7 - Start
		btst		#0,d7			* Gerade Adresse
		bne		xbra_next			* Nein !
		cmp.l	#12,d7			* Grîûergleich 12
		bcs		xbra_next			* Lower (LO)
		cmp.l	#$3ffffc,d7		* <= $3ffffe
		bhi		xbra_next			* Grîûer
xbra_rep:	move.l	d7,a5
		cmp.l	#'XBRA',-12(a5)	* XBRA ?
		bne		xbra_next			* kein XBRA

		lea		xbra_kennung(pc),a2
		move.l	-8(a5),(a2)		* Kennung eintragen

		lea		xbra_vector(pc),a2	* Vector-Adresse
		move.l	a6,d1			* Wert
		moveq.l	#4,d0			* LÑnge
		bsr		binhex

		lea		xbra_adresse(pc),a2	* Adresse
		move.l	d7,d1			* Start
		moveq.l	#8,d0
		bsr		binhex
		
		lea		xbra_old(pc),a2	* Adresse
		move.l	-4(a5),d1			* Old
		moveq.l	#8,d0
		bsr		binhex
		
		movem.l	d0-d7/a0-a6,-(sp)
		PRINT	xbra_text(pc)		* Ausgeben
		movem.l	(sp)+,d0-d7/a0-a6
		addq.l	#1,d6			* Zeile + 1
		cmp.l	#10,d6			* 10 Zeilen ausgegeben ?
		bcs.s	xbra_max			* Nein! (LO)
		clr.l	d6				* ZeilenzÑhler = 0
		bsr		wait
		bsr		loesche_screen
		movem.l	d0-d7/a0-a6,-(sp)
		PRINT	xbra_home(pc)
		movem.l	(sp)+,d0-d7/a0-a6
xbra_max:	move.l	-4(a5),d7			* Neuer Start
		btst		#0,d7			* ungerade ?
		bne.s	xbra_next			* Ja...
		cmp.l	#12,d7			* < 12
		bcs.s	xbra_next			* Ja (LO)
		cmp.l	#$3ffffc,d7		* > $3ffffe
		bhi.s	xbra_next			* Ja
		bra		xbra_rep			* gleicher Vector...
xbra_next:addq.l	#2,a6
		cmp.l	#$1000,a6			* Nur bis Adresse $1000
		bls		xbra_a

		bsr 		wait
		bra 		menue

***************************************** System - Info

m_stspeed:lea		menueflag(pc),a0
		tst.w	(a0)
		bne		m_quit
		bsr 		loesche_screen

		PRINT	st_speed1(pc)		* Freier Speicher
		MALLOC	#-1
		move.l	d0,d1
		lea		freezahl(pc),a2
		bsr		binasc
		PRINT	freezahl(pc)		* Memory
		PRINT	st_speed2(pc)		* Drives
		bsr		show_protected
		PRINT	st_speed3(pc)		* Message
		lea		installflag(pc),a0	* Ramdisk vorhanden ?
		tst.w	(a0)
		bne		memdisk			* Ja...
		PRINT	line(pc)
		bra.s	st_jump
memdisk:	move.l	groesse(pc),d1
		lea		freezahl(pc),a2
		bsr		binasc
		PRINT	freezahl(pc)
st_jump:	lea		filepmode(pc),a0	* File-protect
		move.b	#'O',(a0)+		* = An
		move.b	#'N',(a0)+
		move.b	#' ',(a0)+
		lea		fileflag(pc),a1
		tst.w	(a1)
		bne.s	st_jump1
		move.b	#'F',-(a0)		* File-protect aus
		move.b	#'F',-(a0)
st_jump1:	PRINT	fileptext(pc)
		PRINT	filetext1(pc)
		PRINT	fileptext1(pc)
		bsr 		wait
		bra 		menue

***************************************** File - Protect

m_file:	lea		menueflag(pc),a0
		tst.w	(a0)
		bne		m_quit
		bsr 		loesche_screen

		lea		filechar+1(pc),a0	* File-protect an oder aus
		move.b	#'N',(a0)+
		move.b	#' ',(a0)+
		lea		fileflag(pc),a1
		tst.w	(a1)
		bne.s	file3
		move.b	#'F',-(a0)
		move.b	#'F',-(a0)

file3:	PRINT	filetext(pc)
file2:	bsr		inkey
		bclr		#5,d0
		cmpi.b	#'Q',d0
		beq		menue
		cmpi.b	#'M',d0			* SOFT <-> HARD
		beq.s	file_h_s
		cmpi.b	#'S',d0			* File-protect-status Ñndern
		bne.s	file2
		lea		fileflag(pc),a0
		not.w	(a0)
		bsr.s	file_on_off
		bra.s	file3
file_h_s:	lea		fileflag2(pc),a0
		not.w	(a0)
		bsr.s	file_hard_soft
		bra.s	file3

file_on_off:
		lea		fileflag(pc),a0
		tst.w	(a0)				* <>0 -> Protection an
		bne.s	filep_is_on
		lea		filechar+1(pc),a0
		move.b	#'F',(a0)+
		move.b	#'F',(a0)+
		bsr.s	file_reinstall
		rts
filep_is_on:
		lea		filechar+1(pc),a0
		move.b	#'N',(a0)+
		move.b	#' ',(a0)+
		bsr.s	file_install
		rts

file_hard_soft:
		lea		filetext1(pc),a1
		lea		fileflag2(pc),a0
		tst.w	(a0)
		bne.s	file_is_hard
		move.b	#'S',(a1)+
		move.b	#'o',(a1)+
		move.b	#'f',(a1)+
		move.b	#'t',(a1)+
		rts
file_is_hard:
		move.b	#'H',(a1)+
		move.b	#'a',(a1)+
		move.b	#'r',(a1)+
		move.b	#'d',(a1)+
		rts

file_install:
		lea		trap1_old(pc),a0
		move.l	$84.w,(a0)		* alten Vektor merken
		lea		trap1(pc),a0
		move.l	a0,$84.w			* und Neuen eintragen
		rts
file_reinstall:
		REINS_VEC	$84,trap1_old(pc)	* TRAP-1 Vector reinstallieren
		rts

vector_reinstall:
		move.l	a0,a2
		move.l	(a0),a1			* Start der Routine
		addq.l	#4,a0
xbra_1:	cmp.l	#'XBRA',-12(a1)	* XBRA-Struktur ?
		bne.s	no_xbra			* Nein
		cmp.l	#kennung,-8(a1)	* ST-SPEED Vektor ?
		bne.s	not_found			* Nein
		move.l	-4(a1),-4(a0)
		rts
not_found:move.l	a1,a0
		move.l	-4(a0),a1
		bra.s	xbra_1
no_xbra:	move.l	d0,(a2)			* Brutal reinstallieren
		rts

		dc.l		'XBRA'
		dc.l		kennung
trap1_old:dc.l		0
trap1:	move.l	sp,a0
		btst		#5,(a0)
		beq.s	from_user
		addq.l	#6,a0
		bra.s	trap1jump
from_user:move.l	usp,a0
trap1jump:cmpi.w	#$3d,(a0)			* Fopen? (FP = Soft,Hard)
		beq.s	file_fopen
		cmpi.w	#$3c,(a0)			* Fcreate? (FP = Soft)
		beq		file_fcreate
		cmpi.w	#$41,(a0)			* Fdelete? (FP = Soft)
		beq		file_fdelete

		lea		fileflag2(pc),a1
		tst.w	(a1)				* Soft ?
		beq.s	trap1back			* Ja, zurÅck...
		
		cmpi.w	#$4b,(a0)			* Pexec? (FP = Hard)
		beq		file_pexec

trap1back:move.l	trap1_old(pc),-(sp)
		rts						* Alte ROM-Routine

file_fopen:
		lea		fileflag2(pc),a1
		tst.w	(a1)				* Hard? (Ja, dann auch Meldung beim lesen)
		bne.s	ignore_mode		* Ja...
		move.w	6(a0),d0			* Modus
		tst.w	d0
		beq.s	trap1back			* NUR LESEN
ignore_mode:
		move.l	2(a0),a0			* Filename
		movem.l	d0-d7/a0-a6,-(sp)	* Register retten
		move.l	a0,a6
		bsr		maus_aus
		bsr 		sichere_screen		* Screenbereich sichern
		bsr		loesche_screen
		PRINT	file_otext(pc)
		move.l	a6,-(sp)
		move.w	#9,-(sp)
		trap		#1
		addq.l	#6,sp
		PRINT	file_etext(pc)
		bsr		wait
		bclr		#5,d0
		cmpi.w	#'E',d0			* Fehler erzeugen ?
		beq		file_error		* Ja
		bsr		hole_screen
		bsr		maus_an
		movem.l	(sp)+,d0-d7/a0-a6
		bra.s	trap1back
file_fcreate:
		move.l	2(a0),a0
		movem.l	d0-d7/a0-a6,-(sp)	* Register retten
		move.l	a0,a6
		bsr		maus_aus
		bsr 		sichere_screen		* Screenbereich sichern
		bsr		loesche_screen
		PRINT	file_ctext(pc)
		move.l	a6,-(sp)
		move.w	#9,-(sp)
		trap		#1
		addq.l	#6,sp
		PRINT	file_etext(pc)
		bsr		wait
		bclr		#5,d0
		cmpi.w	#'E',d0			* Fehler erzeugen ?
		beq.s	file_error		* Ja
		bsr		hole_screen
		bsr		maus_an
		movem.l	(sp)+,d0-d7/a0-a6
		bra		trap1back
file_fdelete:
		move.l	2(a0),a0
		movem.l	d0-d7/a0-a6,-(sp)	* Register retten
		move.l	a0,a6
		bsr		maus_aus
		bsr 		sichere_screen		* Screenbereich sichern
		bsr		loesche_screen
		PRINT	file_dtext(pc)
		move.l	a6,-(sp)
		move.w	#9,-(sp)
		trap		#1
		addq.l	#6,sp
		PRINT	file_etext(pc)
		bsr		wait
		bclr		#5,d0
		cmpi.w	#'E',d0			* Fehler erzeugen ?
		beq.s	file_error		* Ja
		bsr		hole_screen
		bsr		maus_an
		movem.l	(sp)+,d0-d7/a0-a6
		bra		trap1back
file_error:
		bsr		hole_screen
		bsr		maus_an
		movem.l	(sp)+,d0-d7/a0-a6
		move.l	#-36,d0
		rte
file_pexec:
		move.w	2(a0),d0			* Mode
		move.l	4(a0),d1			* Path
		move.l	8(a0),a1			* Com
		movem.l	d0-d7/a0-a6,-(sp)	* Register retten
		move.l	d0,d5
		move.l	d1,a4
		move.l	a1,a5
		bsr		maus_aus
		bsr 		sichere_screen		* Screenbereich sichern
		bsr		loesche_screen
		add.b	#$30,d5
		lea		file_ptextm(pc),a0
		move.b	d5,(a0)
		PRINT	file_ptext1(pc)
		move.l	a4,-(sp)			* Filename
		move.w	#9,-(sp)
		trap		#1
		PRINT	file_ptext2(pc)
		addq.l	#1,a5
		move.l	a5,-(sp)			* Commandline
		move.w	#9,-(sp)
		trap		#1
		lea		12(sp),sp

		PRINT	file_etext(pc)
		bsr		wait
		bclr		#5,d0
		cmpi.w	#'E',d0			* Fehler erzeugen ?
		beq		file_error		* Ja
		bsr		hole_screen
		bsr		maus_an
		movem.l	(sp)+,d0-d7/a0-a6
		bra		trap1back


*####################################################################*
*                           Unterprogramme                           *
*####################################################################*

***************************************** Wandelt BIN -> DEZ

binasc:	moveq	#10,d3
		move.l	#'0000',(a2)+		* mit fÅhrenden Nullen
		move.l	#'0000',(a2)+
binweiter:bsr.s	division
		or.b		#$30,d2
		move.b	d2,-(a2)
		tst.l	d1
		bne.s	binweiter
		rts

division:	movem.l	d0/d3/d4,-(sp)		* 32-Bit Divisionsroutine
		move.l	d3,d4			* D1.L = D1.L / D3.L   Rest: D2.L
		moveq.l	#31,d0
		clr.l	d2
		clr.l	d3
naechstesbit:
		roxl.l	#1,d1
		roxl.l	#1,d2
		asl.l	#1,d3
		sub.l	d4,d2
		bmi.s	unterlauf
		addq.l	#1,d3
endediv:	dbra		d0,naechstesbit
		move.l	d3,d1
		movem.l	(sp)+,d0/d3/d4
		rts
unterlauf:add.l	d4,d2
		bra.s	endediv

***************************************** Umwandlung BIN -> HEX

binhex:	subq.w	#1,d0
		move.w	d0,d3
binhex1:	move.b	#' ',(a2)+		* Text auf ' ' setzen
		dbra		d3,binhex1
binhex3:	move.b	d1,d4
		and.b	#$f,d4			* Nibble holen
		or.b		#$30,d4			* nach ASCII
		cmp.b	#'9',d4			* grîûer ?
		bls.s	binhex2			* nein !
		addq.b	#7,d4			* ASCII-Zeichen A-F
binhex2:	move.b	d4,-(a2)			* Zeichen ablegen
		lsr.l	#4,d1			* nÑchstes Nibble
		dbra		d0,binhex3
		rts

***************************************** Anfang des Screens

screen_start:
		move.w	#2,-(sp)
		trap		#14
		addq.l	#2,sp
		rts

***************************************** Bildschirm sichern

sichere_screen:
		bsr.s	screen_start
		move.l	d0,a0
		lea		screen_buf(pc),a1
		bra.s	move_screen

***************************************** Bildschirm zurÅckholen

hole_screen:
		bsr.s	screen_start
		move.l	d0,a1
		lea		screen_buf(pc),a0
move_screen:
		move.l	#zeilen,d0
jump3:	move.b	(a0)+,(a1)+
		dbra		d0,jump3
		rts

***************************************** Bildschirm lîschen

loesche_screen:
		bsr.s	screen_start
		move.l	d0,a0
		move.l	#zeilen,d0
jump2:	clr.b	(a0)+
		dbra		d0,jump2
		rts

***************************************** Tastatur-Abfrage

inkey:	move.w	#$b,-(sp)
		trap		#1
		addq.l	#2,sp
		tst.w	d0
		beq.s	endinkey
		move.w	#7,-(sp)
		trap		#1
		addq.l	#2,sp
		bra.s	inkey
endinkey:	move.w	#7,-(sp)
		trap		#1
		addq.l	#2,sp
		rts

***************************************** Warte auf Tastendruck

wait:	bsr.s	inkey
		tst.w	d0
		beq.s	wait
		rts

***************************************** Maus anschalten

maus_an:	dc.w		$a000
		dc.w		$a009
		rts

***************************************** Maus ausschalten

maus_aus:	dc.w		$a000
		dc.w		$a00a
		rts

***************************************** Variablen

		section data

text:	dc.b	27,'Y',32,32
		dc.b	' ST-Speed V',version,'.',revision,'    (c) Stephan Slabihoud '
		dc.b	13,10,13,10
		dc.b	' 0-9 -> System speed   L -> Load default',13,10
		dc.b	'  A  -> Menu on/off    S -> Save default',13,10
		dc.b	'  B  -> BOOT device    W -> WR-protect  ',13,10
		dc.b	'  C  -> 50/60 Hz       X -> XBRA list   ',13,10
		dc.b	'  D  -> Ramdisk        F -> Fileprotect ',13,10
		dc.b	'  I  -> System info                     ',13,10
		dc.b	'  H  -> Hardcopy                        ',13,10
		dc.b	13,10
		dc.b	'  Q  -> Quit   R/P -> RESET (warm/cold)',13,10
		dc.b	0
install:	dc.b	13,10,13,10
		dc.b	' ST-Speed V',version,'.',revision,'   Now reset-resident !'
		dc.b	13,10,13,10
		dc.b	' (c) by St.Slabihoud in 1987,88,89,90',13,10
		dc.b	0
		even

**************************
******** 40 Bytes ******** SAVE - Area
**************************
save_area:
menueflag:	dc.w	0	* 0 = MenÅ-An
protect:		dc.l	0	* 0 = Nicht resident (RAMDISK)
fileflag:		dc.w	0	* 0 = Kein File-Protect
fileflag2:	dc.w	0	* 0 = Protect=SOFT
_free:		ds.b	30
**************************

sfileflag:	dc.w	0

speedflag:	dc.w	0
speedtime:	dc.l	0

puffer:		dc.l 0
mfree:		dc.l	0

protobpb:		dc.w  512,   2,1024,   7,   5,   6,    18
*			      BPS, SPC, BPC, DIR, FAT,FAT2,DATREC

numcl:		dc.w 0				* Grîûe in freien Clustern
			dc.w 0				* 12-Bit-FAT
			dc.l 0
driveno:		dc.w 0				* Nr. des installierten Drives
drivenr:		dc.b	2				* Hilfsflag (Start mit C:)
groesse:		dc.l 0
installflag:	dc.w	0
resident:		dc.w	0

infoname:		dc.b	'\st_speed.inf',0,0

drivemsg:		dc.b	27,'Y',32,32,13,10
			dc.b	'  RAMDISK installed as drive '
drvstr:		dc.b	'C.',0
reinstallram:	dc.b	27,'Y',32,32,13,10
			dc.b	' ',27,'p RAMDISK is reinstalled. ',27,'q',0
errorram:		dc.b	27,'Y',32,32,13,10
			dc.b	'  Error! RAMDISK not installed.',0
impossible:	dc.b	27,'Y',32,32,13,10
			dc.b	'  Reinstallation impossible after RESET.',0
installram:	dc.b 27,'Y',32,32,13,10
			dc.b	'  Install RAMDISK (Start with Drive '
drivechar:	dc.b	'C:)',13,10
			dc.b	13,10
			dc.b	'  1 - 9 :  * 100 KBytes',13,10
			dc.b '    0   :      1 MByte',13,10
			dc.b	13,10
			dc.b	'    T   : ',27
residentchar:	dc.b	'q reset-resident ',27,'q',13,10
			dc.b	13,10
			dc.b '    Q   : Quit',0,0
reinstallmenu:	dc.b	27,'Y',32,32,13,10
			dc.b	'  RAMDISK just installed.',13,10
			dc.b	13,10
			dc.b	'  R -> Reinstall    Q -> Quit',0
disksize:		dc.b	27,'Y',37,32,'  Ramdisk: ',0
boottext:		dc.b	27,'Y',32,32,13,10
			dc.b	'  BOOT - Device :',13,10
			dc.b	13,10
			dc.b	'  Q  : Quit',13,10
			dc.b	13,10,13,10
			dc.b	'  ==>  ',0
writetext:	dc.b	27,'Y',32,32,13,10
			dc.b	'  WRITE-PROTECT Device (Inv=ON):',13,10
			dc.b	13,10
			dc.b	'  Q  : Quit',13,10
			dc.b	13,10,13,10
			dc.b	'  ==>  ',0
spaces:		dc.b	'  ',0
inv_on:		dc.b	27,'p',0
inv_off:		dc.b	27,'q',0

st_speed1:	dc.b	27,'Y',32,32,13,10
			dc.b	' Memory : ',0
			even
freezahl:		dc.b	'00000000 Bytes',0
st_speed2:	dc.b	13,10
			dc.b	13,10
			dc.b	' Drives : ',0
st_speed3:	dc.b	13,10
			dc.b	13,10
			dc.b	' Ramdisk: ',0
line:		dc.b	'-------- Bytes',0,0
fileptext:	dc.b	13,10,13,10
			dc.b	' File-protect is '
filepmode:	dc.b	'XXX ! (',0
fileptext1:	dc.b	')',0 

xbra_home:	dc.b	27,'Y',32,32,13,10,0
			even
xbra_text:	dc.b	' XBRA:'
xbra_kennung:	dc.b	'XXXX  VEC:'
xbra_vector:	dc.b	'XXXX  ADR:'
xbra_adresse:	dc.b	'XXXXXXXX  OLD:'
xbra_old:		dc.b	'XXXXXXXX',13,10,0,0

filetext:		dc.b 27,'Y',32,32,13,10
			dc.b	' File-Protection is '
filechar:		dc.b	'OFF !',13,10
			dc.b	13,10,13,10
			dc.b	' Q -> Quit    S -> Switch    M -> '
filetext1:	dc.b	'Soft',0,0
file_otext:	dc.b	27,'j',27,'Y',32,32,13,10
			dc.b	' Something tries to OPEN ',13,10,13,10
			dc.b	' ==> ',0,0
file_ctext:	dc.b	27,'j',27,'Y',32,32,13,10
			dc.b	' Something tries to CREATE ',13,10,13,10
			dc.b	' ==> ',0,0
file_dtext:	dc.b	27,'j',27,'Y',32,32,13,10
			dc.b	' Something tries to DELETE ',13,10,13,10
			dc.b	' ==> ',0,0
file_ptext1:	dc.b	27,'j',27,'Y',32,32,13,10
			dc.b	' Something tries to Pexec ('
file_ptextm:	dc.b	'0) ',13,10,13,10
			dc.b	' ==> ',0
file_ptext2:	dc.b	13,10,' C=> ',0

file_etext:	dc.b	13,10,13,10
			dc.b	' Press <E> to generate a file error !'
			dc.b	27,'k',0,0

			even
screen_buf:	ds.w	1
res_end:		end
