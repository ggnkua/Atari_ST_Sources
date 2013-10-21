*
* TEMPPTCH - schaltet den Bildschirmschoner in TEMPUS 2 ganz aus, damit
*	     er auch auf dem TT beendet werden kann.
*
* Bei meiner Version von TEMPUS 2.05 musste an 4 Stellen gepatcht werden.
*
* (c) 1990 Marcel Waldvogel
*

ssize	EQU 2048		;Stackgroesse
tsize	EQU 150000		;Buffergroesse

start:	lea	copr,A0
	bsr	Cconws

	clr.w	-(A7)		;Read only
	pea	tempprg
	move.w	#$3D,-(A7)	;Fopen()
	trap	#1
	addq.l	#8,A7
	tst.l	D0
	bmi	fnf		;File Not Found

	move.w	D0,-(A7)	;Vorbereitung fÅr Fclose()

	move.l	#tsize,D7
	pea	buf
	move.l	D7,-(A7)
	move.w	D0,-(A7)
	move.w	#$3F,-(A7)	;Fread()
	trap	#1
	lea	12(A7),A7
	move.l	D0,D6		;Speichern

	move.w	#$3E,-(A7)	;Fclose(), zweiter Teil
	trap	#1
	addq.l	#4,A7

	move.l	D6,D5		;Dateigrîsse von vorhin
	bmi	read		;Lesefehler!
	cmp.l	D6,D7		;Gelesene Bytes = Buffergrîsse?
	beq	long		;Dann Filesize >= Bufsize -> weg!

* Jetzt nach den öbeltÑtern suchen!

	move.w	#$820A,D0	;Zu suchendes Wort (Adresse syncmode)
	move.w	#$FF,D1 	;steht evt. davor -> kurze Adressierung
	move.l	#$4E714E71,D2	;2*NOP, einzutragende Worte
	lea	buf,A0		;Adresse des Buffers

loop:	subq.l	#2,D5		;Fertig?
	bcs.s	save
	cmp.w	(A0)+,D0	;Ist das zu suchende Wort da?
	bne.s	loop

	cmp.w	-4(A0),D1	;Absolute Long? (vereinfachter Test...)
	bne.s	not_8		;Offset -10 nicht lîschen
	move.w	D2,-8(A0)	;btst/bset/bclr bzw. nichts ausNOPpen
not_8:	move.w	D2,-6(A0)	;#0		bzw. btst/bset/bclr ausNOPpen
	move.l	D2,-4(A0)	;$00FF820A	bzw. #0,$FFFF820A.w ausNOPpen

	addq.b	#1,ptchmsg	;ZÑhler erhîhen
	bra.s	loop


save:	lea	ptchmsg,A0
	bsr	Cconws

	move.w	#$17,-(A7)
	pea	tempapp
	move.w	#$4E,-(A7)	;Fsfirst()
	trap	#1
	addq.l	#8,A7
	tst.l	D0
	beq.s	fex

	clr.w	-(A7)
	pea	tempapp
	move.w	#$3C,-(A7)	;Fcreate()
	trap	#1
	addq.l	#8,A7
	tst.l	D0
	bmi.s	werr

	move.w	D0,-(A7)	;Vorbereitung fÅr Fclose()

	pea	buf
	move.l	D6,-(A7)
	move.w	D0,-(A7)
	move.w	#$40,-(A7)	;Fwrite()
	trap	#1
	lea	12(A7),A7
	move.l	D0,D5

	move.w	#$3E,-(A7)	;Fclose() (mit D0 vom Stack)
	trap	#1
	addq.l	#4,A7

	cmp.l	D5,D6		;Stimmt die LÑnge?
	bne.s	werr
	bra.s	term


* Einige Fehlermeldungen und Programmtermination

fnf:	lea	fnfmsg,A0
	bra.s	msgterm

read:	lea	readmsg,A0
	bra.s	msgterm

long:	lea	longmsg,A0
	bra.s	msgterm

fex:	lea	fexmsg,A0
	bra.s	msgterm

werr:	lea	werrmsg,A0
msgterm:bsr.s	Cconws

term:	lea	pakmsg,A0
	bsr.s	Cconws

	move.w	#1,-(A7)	;Cconin()
	trap	#1
	addq.l	#2,A7

	clr.w	-(A7)		;Pterm0()
	trap	#1

Cconws: move.l	A0,-(A7)
	move.w	#9,-(A7)	;Cconws() (was denn sonst?)
	trap	#1
	addq.l	#6,A7
	rts


	DATA

copr:	DC.B 13,10,"TEMPPTCH - (c) 1990 Marcel Waldvogel",13,10,0


fnfmsg: DC.B "TEMPUS.PRG not found!",13,10,0
readmsg:DC.B "Error reading TEMPUS.PRG!",13,10,0
longmsg:DC.B "TEMPUS.PRG too long!",13,10,0

ptchmsg:DC.B "0 patches applied!",13,10,0
fexmsg: DC.B "TEMPUS.APP already exists! File not saved!",13,10,0
werrmsg:DC.B "Write error on TEMPUS.APP!",13,10,0

pakmsg: DC.B "Press any key...",0

tempprg:DC.B "TEMPUS.PRG",0
tempapp:DC.B "TEMPUS.APP",0

	BSS

	EVEN
buf:	DS.B tsize

	EVEN
	DS.B ssize
stack:
	END
