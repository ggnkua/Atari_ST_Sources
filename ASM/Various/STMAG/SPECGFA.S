*************************************
*                                   *
*  68oooer ST-Magazin presents:     *
*                                   *
*  SPECTRUM 512(tm)-Picture-Loader  *
*            GFA-Version            *
*                                   *
*   written by Carsten Reinhardt    *
*                                   *
*   VBI-Routine based on source     *
*       of D. Mihocka/USA           *
*************************************
*  Assembler: HiSoft DevPac         *
*************************************
*  Date: 07.06.1988                 *
*************************************

 opt o+,p+

color0		equ $ff8240
color1		equ $ff8242
videolow	equ $ff8209
sync		equ $ff820a
nvbls		equ    $454
vblqueue	equ    $456


go:	move.l	4(sp),d0		; Filename abholen
	lea	file(pc),a0
	move.l	d0,(a0)
	move	8(sp),d0		; Modus abholen

	lea	sav_sp(pc),a0
	move.l	sp,(a0)
	lea	stack(pc),sp

	cmp	#1,d0
	beq.s	load			; 1  -> Laden
	bra	quit			; sonst Ausschalten

load:	bsr	getpal			; Alte Farbpalette holen
	bsr	lorez			; Umschalten auf Lo-Resolution
	bsr	logbase			; Hole Screen-Adresse

	lea	file(pc),a0		; File-Pointer
	move.l	(a0),d0
	bsr	open			; File îffnen

	lea	dark(pc),a0
	move.l	a0,d0
	bsr	setpal			; Bildschirm dunkel
	bsr	m_off			; Maus aus

	lea	spc_head(pc),a0
	move.l	#12,d0
	bsr	read			; File-Header lesen
	move.l	spc_head(pc),d0
	cmp.l	#$53500000,d0
	beq.s	spc			; Kennung stimmt -> weiter
	bra	spu			; ungepacktes File

spc:	move.l	#32000,d0		; Laden eines gepackten Bildes
	bsr	alloc			; Puffer fÅr Image
	lea	image_adr(pc),a0
	move.l	d0,(a0)
	move.l	d0,a0
	move.l	spc_head+4(pc),d0
	bsr	read			; Image lesen
	move.l	image_adr(pc),a0
	move.l	screen(pc),a1
	add.l	#160,a1			; Offset fÅr SYNC-Zeile
	move.l	spc_head+4(pc),d0
	bsr	unpack			; Image entpacken
	move.l	image_adr(pc),d0
	bsr	mfree			; Puffer wieder feigeben
	move.l	#19104,d0
	bsr	alloc			; Puffer zum Laden d. Farben
	lea	colbu_adr(pc),a0
	move.l	d0,(a0)
	move.l	d0,a0
	move.l	spc_head+8(pc),d0
	bsr	read			; Farben lesen
	move.l	#19200,d0
	bsr	alloc			; Puffer fÅr VBI-Farben
	lea	color_adr(pc),a0
	move.l	d0,(a0)
	move.l	spc_head+8(pc),d0
	move.l	colbu_adr(pc),a0
	move.l	color_adr(pc),a1
	addq.l	#2,d0
	bsr	delta			; Farben entpacken
	move.l	colbu_adr(pc),d0
	bsr	mfree			; Puffer wieder freigeben
	move	handle(pc),d0
	bsr	close			; Datei schlieûen
	bsr	inivbi			; VBI einschalten
	bra	ready

spu:	move	handle(pc),d0		; Laden eines ungepackten Bildes
	bsr	close			; erst mal schlieûen
	lea	file(pc),a0		; File-Pointer
	move.l	(a0),d0
	bsr	open			; ... dann wieder îffnen
	move.l	screen(pc),a0
	move.l	#32000,d0
	bsr	read
	move.l	#19108,d0
	bsr	alloc
	lea	color_adr(pc),a0
	move.l	d0,(a0)
	move.l	d0,a0
	move.l	#19104,d0
	bsr	read
	move	handle(pc),d0
	bsr	close			; Datei schlieûen
        bsr	border
	bsr	inivbi			; Interrupt ein
	bra	ready

border:	move.l	color_adr(pc),a0
	move	#198,d0
bor_1:	clr	(a0)
	add.l	#96,a0
	dbra	d0,bor_1
	rts

setpal:	move.l	d0,-(sp)		; Farbpalette setzen
	move	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	rts

getpal:	lea	oldpal(pc),a6		; Farbpalette holen
	move	#0,d6
gp_1:	move	#-1,-(sp)
	move	d6,-(sp)
	move	#7,-(sp)
 	trap	#14
 	addq.l	#6,sp
 	move	d0,(a6)+
	add	#1,d6
	cmp	#16,d6
	bne.s	gp_1
	rts

m_off:	move	#$12,-(sp)		; Maus aus
	move	#4,-(sp)
	move	#3,-(sp)
	trap	#13
	addq.l	#6,sp
	rts

m_on:	move	#8,-(sp)		; Maus ein
	move	#4,-(sp)
	move	#3,-(sp)
	trap	#13
	addq.l	#6,sp
	rts

inivbi:	pea	setup(pc)		; VBI-Install-Routine aufrufen
	move	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	rts

setup:	move	nvbls,d0		; Suchen nach freiem VBI-Slot,
	move.l	vblqueue,a0		; anschlieûend eintragen des
	lea	sav_vbi(pc),a1
	move.l	a0,(a1)			; eigenen Vektors im ersten
	subq	#1,d0			; feien Feld
	lea	vbis(pc),a1		; (alles im SUPERVISOR-Mod.!)
	move	d0,d1
copvbi:	move.l	(a0)+,(a1)+		; erst mal kopieren...
	dbra	d1,copvbi

	lea	vbis(pc),a0		; dann suchen
such:	move.l	(a0)+,d1
	beq	slotfnd
	dbra	d0,such
	rts				; kein Platz mehr frei!
slotfnd:btst	#1,sync
	beq	fnd1
	lea	vbi2(pc),a1
	bra.s	fnd2
fnd1:	lea	vbi1(pc),a1
fnd2:	move.l	a1,-(a0)		; eigene Routine in Slot
	lea	vbis(pc),a1
	move.l	a1,vblqueue		; Vektor 'umbiegen'
	rts

stovbi:	pea	restore(pc)		; VBI-Restore-Routine aufrufen
	move	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	rts

restore:move.l	sav_vbi(pc),vblqueue	; alten Vektor wieder installieren
	rts

vbi1:	move	sr,-(a7)		; Die eigentliche 60Hz-VBI-Routine.
	ori	#$700,sr		; Vorsicht! éuûerst zeitkritisch
	move	#198,d7			;  und rechenintensiv!
	move.l	#color0,a5		; Beansprucht teilweise 80% (!)
	clr	color0			;  der Prozessorleistung.
	move.l	color_adr(pc),a0
	clr	d0
	tst.b	videolow
	bne	ex_vbi1
sync1:	tst.b	videolow
	beq.s	sync1
	move.b	videolow,d0
	dc.l	$4efb0000		;jmp	0(pc,d0.w)

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	move.l	a5,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

main1:	move.l	a5,a1
	move.l	a5,a2
	move.l	a5,a3
	nop
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+

	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+

	dbra	d7,main1

ex_vbi1:move	#0,color0
	move	(a7)+,sr
	rts

vbi2:	move	sr,-(a7)		; Die eigentliche 50Hz-VBI-Routine.
	ori	#$700,sr		; Vorsicht! éuûerst zeitkritisch
	move	#198,d7			;  und rechenintensiv!
	move.l	#color0,a5		; Beansprucht teilweise 80% (!)
	clr	color0			;  der Prozessorleistung.
	move.l	color_adr(pc),a0
	clr	d0
	tst.b	videolow
	bne	ex_vbi2
sync2:	tst.b	videolow
	beq.s	sync2
	move.b	videolow,d0
	dc.l	$4efb0000		;jmp	0(pc,d0.w)

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	move.l	a5,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

main2:	move.l	a5,a1
	move.l	a5,a2
	move.l	a5,a3
	nop
	nop
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+

	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+

	dbra	d7,main2

ex_vbi2:move	#0,color0
	move	(a7)+,sr
	rts


delta:	lsr	#1,d0			; Entpacken des Farb-Teils
de_0:	subq	#1,d0
	tst	d0
	bmi.s	del_ex
	move	(a0)+,d1
	and	#$7ffe,d1
	move	#15,d2
de_1:	move	d1,d3
	and	#1,d3
	beq.s	de_2
	move	(a0)+,(a1)+
	subq	#1,d0
	bra.s	de_3
de_2:	clr	(a1)+
de_3:	lsr	#1,d1
	dbra	d2,de_1
	bra.s	de_0
del_ex:	rts

unpack:	sub.l	d3,d3			; Entpacken des Image-Teils
	move.l	a1,a2
up_0:	subq	#1,d0
	tst	d0
	bmi.s	up_ex
	sub	d1,d1
	move.b	(a0)+,d1
	btst	#7,d1
	bne.s	case2
	sub	d1,d0
	subq	#1,d0
case1:	move.b	(a0)+,(a2)+
	move.l	a2,d7
	btst	#0,d7
	bne	c1_1
	addq.l	#6,a2
c1_1:	addq	#1,d3
	cmp	#7960,d3
	blt.s	c1_2
	addq.l	#2,a1
	move.l	a1,a2
	sub.l	d3,d3
c1_2:	dbra	d1,case1	
	bra.s	up_0
case2:	neg.b	d1
	addq.b	#1,d1
	move.b	(a0)+,d2
	subq	#1,d0
up_1:	move.b	d2,(a2)+
	move.l	a2,d7
	btst	#0,d7
	bne	c2_1
	addq.l	#6,a2
c2_1:	addq	#1,d3
	cmp	#7960,d3
	blt.s	c2_2
	addq.l	#2,a1
	move.l	a1,a2
	sub.l	d3,d3
c2_2:	dbra	d1,up_1
	bra.s	up_0
up_ex:	rts

alloc:	move.l	d0,-(sp)		; Puffer-Speicher reservieren
	move	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.l	d0
	bmi	no_mem
	beq	no_mem
	rts

mfree:	move.l	d0,-(sp)		; freigeben des mit MALLOC
	move	#$49,-(sp)		; angeforderten Speichers
	trap	#1
	addq.l	#6,sp
	rts

open:	move	#0,-(sp)		; Datei zum Lesen îffnen
	move.l	d0,-(sp)
	move	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	lea	handle(pc),a0
	move	d0,(a0)
	bmi	error
	rts

close:	move	d0,-(sp)		; Datei schlieûen
	move	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst	d0
	bmi	error
	rts
					; (d0) Bytes nach (a0) lesen
read:	move.l	a0,-(sp)        	; Ladeadresse
	move.l	d0,-(sp)		; Anzahl Bytes
	move	handle(pc),-(sp)
	move	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	tst	d0
	bmi	error
	rts

no_mem:	pea	mem_err(pc)		; Fehler: zu wenig Speicher
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	bra.s	exkey

no_mono:pea	mon_err(pc)		; Fehler: nur Farbmonitor
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	bra.s	exkey

error:	pea	fil_err(pc)		; Fehler: Dateifehler
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp

exkey:	addq.l	#4,sp			; Stack-Korrektur
	lea	oldpal(pc),a0
	move.l	a0,d0
	bsr	setpal			; Farben restaurieren

ready:	move.l	sav_sp(pc),sp		; Stack restaurieren
	rts

quit:	move.l	sav_vbi(pc),d0
	tst.l	d0
	beq.s	no_vbi
	bsr	stovbi			; 512 Farben aus
no_vbi:	move.l	color_adr(pc),d0
	tst.l	d0
	beq.s	no_col
	bsr	mfree			; Puffer fÅr Farben freigeben
no_col:	lea	oldpal(pc),a0
	move.l	a0,d0
	bsr	setpal			; Farben restaurieren
	move	resolu(pc),-(sp)	; Bildschirmparameter wieder
	move.l	#-1,-(sp)		; herstellen
	move.l	#-1,-(sp)
	move	#5,-(sp)
	trap	#14
	add.l	#12,sp
	bsr	m_on			; Maus ein
	move.l	sav_sp(pc),sp		; Stack restaurieren
	rts

lorez:	move	#4,-(sp)		; Einschalten der niedrigsten
	trap	#14			; Auflîsung
	addq.l	#2,sp
	lea	resolu(pc),a0
	move	d0,(a0)
	beq.s	lor_ex
	cmp	#2,d0
	beq	no_mono
	move	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move	#5,-(sp)
	trap	#14
	add.l	#12,sp
lor_ex:	rts
	
logbase:move	#3,-(sp)		; Bildschirmadresse holen
	trap	#14
	addq.l	#2,sp
	lea	screen(pc),a0
	move.l	d0,(a0)
	rts
					; Variablen & Konstanten:

fil_err:	dc.b "File-error !",0
 even
mem_err:	dc.b "Not enough memory !",0
 even
mon_err:	dc.b "Sorry, color display only !",0
 even
file:		dc.l 0
sav_sp:		dc.l 0
handle:		dc.w 0
resolu:		dc.w 0
image_adr:	dc.l 0
color_adr:	dc.l 0
colbu_adr:	dc.l 0
screen:		dc.l 0
vbis:		dc.l 0,0,0,0,0,0,0,0	; 8 VBI-Slots
sav_vbi:	dc.l 0
dark:		dc.w 0,0,0,0,0,0,0,0	; Alle Farbregister schwarz
		dc.w 0,0,0,0,0,0,0,0
spc_head:	ds.l 3			; 3 Longs fÅr File-Header
oldpal:		ds.w 16
		ds.l 48
stack:		ds.l 1			; Eigener Stackbereich