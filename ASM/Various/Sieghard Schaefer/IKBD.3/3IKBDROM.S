*******************************************************
* Dieses Listing erm”glicht das Abspeichern des IKBD- *
* ROMs von 4kByte L„nge  als Datei 'IKBD_ROM.SYS' auf *
* dem aktuellen Laufwerk.  Sieghard Sch„fer, 21.11.89 *
*******************************************************

	pea	text(pc)
	move	#9,-(a7)
	trap	#1		Textausgabe
	addq.l	#6,a7

	lea	puffer(pc),a0	Pufferadresse..
	move.l	a0,-4(a0)	..in Pointer

	move	#34,-(a7)
	trap	#14		KBDVBASE
	addq.l	#2,a7
	move.l	d0,a0		nach a0 kopieren

	lea	intrpt(pc),a1	'intrpt'-Routine in a1
	lea	basis(pc),a2
	move.l	a0,(a2)+	a0 in basis retten
	move.l	12(a0),(a2)	alter Statusvektor &..
	move.l	a1,12(a0)	..Intrpt speichern
  
	move	#$f000,d4	Startadresse IKBD-ROM..
	lea	sign(pc),a6

main	lea	send+1(pc),a0
	move	d4,(a0)		 ..abspeichern

	sf	(a6)		sign l”schen
	pea	send(pc)	Startadresse ist send
	move	#2,-(a7)	3 Bytes senden
	move	#25,-(a7)
	trap	#14		IKBDWS
	addq.l	#8,a7

wait	cmp.b	#$20,(a6)	Daten angekommen ?
	bne.s	wait		nein, nochmal

	addq	#6,d4		Start-Adresse ROM bis..
	bmi.s	main		..$ffff um 6 erh”hen

	clr	-(a7)
	pea	fname(pc)
	move	#$3c,-(a7)
	trap	#1		FCREATE
	addq.l	#8,a7
	lea	handle(pc),a0
	move	d0,(a0)		Handle abspeichern

	pea	puffer(pc)
	move.l	#4096,-(a7)
	move	handle(pc),-(a7)
	move	#$40,-(a7)
	trap	#1		FWRITE
	lea	12(a7),a7

	move	handle(pc),-(a7)
	move	#$3e,-(a7)
	trap	#1		FCLOSE
	addq.l	#4,a7

	move.l	basis(pc),a0	alter Basis-Vektor &..
	move.l	status(pc),12(a0) ..Status-Vektor

	clr	-(a7)
	trap	#1		E N D E

*******************************************************
intrpt	movem.l	a2-a3,-(a7)	Register retten
	lea	pointer(pc),a2
	lea	sign(pc),a3

	moveq	#5,d0		6 Bytes kopieren
	move.l	(a2),a1		Pointer nach a1
	move.b	(a0)+,(a3)	Daten-Header $20
repeat	move.b	(a0)+,(a1)+	kopiert ankommende..
	dbf	d0,repeat	..Daten in 'puffer'

	move.l	a1,(a2)
	movem.l	(a7)+,a2-a3	Register zurck
	rts
*******************************************************

	section data

text	dc.b	'Bitte etwa 10 sec warten, die Daten-'
	dc.b	10,13,'bertragung IKBD --> ST l„uft.'
	dc.b	10,10,13,189,' 21.11.89 by Sieghard '
	dc.b	'Sch„fer',0
fname	dc.b	'IKBD_ROM.SYS'
	even
	dc.b	0		muss odd erzeugen!!!
send	dc.b	33		'Memory read'

	section bss

	ds.b	2		muss auf gerade Adresse
sign	ds.b	1		Speicherdaten-Header
	even
basis	ds.l	1		Basisadresse IKBD
status	ds.l	1		Alter Status-Vektor
handle	ds	1		Handle-Nummer
pointer	ds.l	1		Pointer auf puffer
puffer	ds.b	4096
