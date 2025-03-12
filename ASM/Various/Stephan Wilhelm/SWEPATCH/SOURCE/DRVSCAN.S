; Auswahl der Bootsequenz mit den Funktionstasten bei Kaltstart
; Durch die freie Bestimmung der Bootsequenz kînnen einzelne Laufwerke
; vom Bootversuch ausgeschlossen werden.
; Dadurch hat man die Mîglichkeit,auch bei einem System ohne Floppy
; das System korrekt von einem anderen Laufwerk zu booten,falls das
; Laufwerk durch einen zerstîrten Festplattentreiber (z.B. durch Viren
; oder durch abgestÅrzte Programme,die "wildgeworden" auf die Platte schreiben)
; das System zum Absturz bringt oder nicht mehr bootfÑhig ist.
; Dadurch kann man z.B. auch auf die normale Floppy verzichten,und ein
; LS120-Floppylaufwerk (liest und schreibt 1.4MB HD und 120MB Superfloppys)
; am IDE-Port betreiben.Mit einer bootfÑhigen Diskette kann man das System
; nun problemlos mit dem LS120 (oder ZIP) hochfahren,und den
; Festplattentreiber auf dem fehlerhaften Laufwerk ersetzen.
;
; Diese Version ist fÅr Rechner mit SCSI- und ACSI
; 
; RETURN: Abbruch des Speichertest,Standard-Bootsequenz IDE0-1 SCSI0-6 ACSI0-6
;
; F1: SCSI1-6 ACSI0-6 IDE0-1
; F2: SCSI2-6,0 ACSI0-6 IDE0-1
; ...
; F6: SCSI6,0-4 ACSI0-6 IDE0-1
; F7: SCSI0-5 ACSI0-6 IDE0-1
;
; SHIFT F1: ACSI1-6 IDE0-1 SCSI0-7
; SHIFT F2: ACSI2-6,0 IDE0-1 SCSI0-7
; ...
; SHIFT F6: ACSI6,0-4 IDE0-1 SCSI0-7
; SHIFT F7: ACSI0-5 IDE0-1 SCSI0-7
;
; CTRL F1: IDE1 SCSI0-6 ACSI0-6
; CTRL F2: IDE0 SCSI0-6 ACSI0-6

		org $7fe60700

		move.b	$5d1,d0
		cmp.b	#4,$5d0		; control gedrÅckt ?
		beq	tstctrl
		cmp.b	#59,d0		; SCSI kleiner F1 ?
		blt	nochange
		cmp.b	#65,d0		; SCSI grîûer F7 ? 
		bgt	tstshift
		lea.l	scsilist(pc),a0
		sub.b	#59,d0
		movem.l	d0-a6,-(sp)
		move.w	d0,-(sp)
		pea	seqtxt(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		pea	scsitxt(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		move.w	(sp)+,d0
		lea.l	devtx1(pc),a0
		and.l	#$ff,d0
		lsl.w	#3,d0
		add.l	d0,a0
		move.l	a0,-(sp)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		move.w	#32,-(sp)
		move.w	#2,-(sp)
		trap	#1
		addq.w	#4,sp
		pea	acsitxt(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		pea 	fulldev(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		move.w	#32,-(sp)
		move.w	#2,-(sp)
		trap	#1
		addq.w	#4,sp
		pea	fullide(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		pea	return(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		movem.l	(sp)+,d0-a6
		bra	getdrive
tstshift:	cmp.b	#84,d0		; ACSI kleiner SHIFT F1 ?
		blt	nochange
		cmp.b	#90,d0		; ACSI grîûer SHIFT F7 ?
		bgt	nochange
		lea.l	acsilist(pc),a0
		sub.b	#84,d0
		movem.l	d0-a6,-(sp)
		move.w	d0,-(sp)
		pea	seqtxt(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		pea	acsitxt(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		move.w	(sp)+,d0
		lea.l	devtx1(pc),a0
		and.l	#$ff,d0
		lsl.w	#3,d0
		add.l	d0,a0
		move.l	a0,-(sp)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		move.w	#32,-(sp)
		move.w	#2,-(sp)
		trap	#1
		addq.w	#4,sp
		pea	fullide(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		move.w	#32,-(sp)
		move.w	#2,-(sp)
		trap	#1
		addq.w	#4,sp
		pea 	scsitxt(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		pea	fulldev(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		pea	return(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		movem.l	(sp)+,d0-a6
		bra	getdrive
tstctrl:	cmp.b	#59,d0		; IDE kleiner CTRL F1 ?
		blt	nochange
		cmp.b	#60,d0		; IDE grîûer CTRL F2 ?
		bgt	nochange
		lea.l	idelist(pc),a0
		sub.b	#59,d0
		movem.l	d0-a6,-(sp)
		move.w	d0,-(sp)
		pea	seqtxt(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		move.w	(sp)+,d0
		lea.l	idetx1(pc),a0
		and.l	#$ff,d0
		lsl.w	#3,d0
		add.l	d0,a0
		move.l	a0,-(sp)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		move.w	#32,-(sp)
		move.w	#2,-(sp)
		trap	#1
		addq.w	#4,sp
		pea	scsitxt(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		pea 	fulldev(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		move.w	#32,-(sp)
		move.w	#2,-(sp)
		trap	#1
		addq.w	#4,sp
		pea	acsitxt(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		pea	fulldev(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		pea	return(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		movem.l	(sp)+,d0-a6
		bra.s	getdrive
nochange:	lea.l	normlist(pc),a0
		moveq.l	#0,d0
		movem.l	d0-a6,-(sp)
		pea	seqtxt(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		pea	normtxt(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		pea	return(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		movem.l	(sp)+,d0-a6
getdrive:	move.w	#0,$5d0		; bootkey lîschen
		andi.l	#$ff,d0
		lsl.w	#4,d0
		add.l	d0,a0
		move.w	#0,$aa0		; readcookie
		move.w	#1,d1		; zwei leseversuche
nxtdev:		clr.l	d4
		move.b	(a0)+,d4	; devnr holen
		move.l	a0,-(sp)	; devlist-pointer retten
nxtread:	move.w	d1,-(sp)	; leseversuch-zaehler retten
		move.w	d4,-(sp)	; devno
		move.l	$4c6,-(sp)	; bootbuffer 1024 byte
		move.w	#1,-(sp)	; count
		clr.l	-(sp)		; startsector
		jsr	$7fe0186c	; IDE-Booter
		adda.w	#$c,sp
		move.w	(sp)+,d1	; leseversuch-zaehler holen
		tst.l	d0		; bootblock-read ok ?
		beq.s	crctest		; dann crc-test
		addq.l	#1,d0
		dbeq	d1,nxtread
		bra.s	gonxtdev	; nÑchstes device holen
crctest:	movea.l	$4c6,a0		; crc-prÅfsumme ermitteln
		move.w	#$ff,d0
		moveq.l	#0,d1
crcloop:	add.w	(a0)+,d1
		dbra	d0,crcloop
		cmp.w	#$1234,d1	; crc korrekt ?
		beq.s	bootfound
gonxtdev:	movea.l	(sp)+,a0
		cmp.b	#$ff,(a0)	; ende der devliste erreicht ?
		bne.s	nxtdev
		rts
bootfound:	addq.w	#4,sp		; devlist-pointer von stack holen
		jmp	$7fe00b94

seqtxt:		dc.b	13,10
		dc.b	"bootsequen"
		dc.b	"ce ",0
normtxt:	dc.b	"standard"
		dc.b	" IDE0-1 "
		dc.b	"SCSI0-6 "
		dc.b	"ACSI0-6",0
scsitxt:	dc.b	"SCSI",0,0
acsitxt:	dc.b	"ACSI",0,0
fulldev:	dc.b	"0-6",0
fullide:	dc.b	"IDE0-1",0,0		
idetx1:		dc.b	"IDE1",0,0,0,0
idetx2:		dc.b	"IDE0",0,0,0,0
return:		dc.b	13,10,0,0
devtx1:		dc.b	"1-6",0,0,0,0,0
devtx2:		dc.b	"2-6,0",0,0,0
devtx3:		dc.b	"3-6,0-1",0
devtx4:		dc.b	"4-6,0-2",0
devtx5:		dc.b	"5-6,0-3",0
devtx6:		dc.b	"6,0-4",0,0,0
devtx7:		dc.b	"0-5",0,0,0,0,0

normlist:	dc.b	16,17,8,9,10,11,12,13
		dc.b    14,0,1,2,3,4,5,6,$ff,0	; IDE,SCSI,ACSI

scsilist:	dc.b	9,10,11,12,13,14,0,1
		dc.b	2,3,4,5,6,16,17,$ff	; ab SCSI 1
		dc.b	10,11,12,13,14,9,0,1
		dc.b	2,3,4,5,6,16,17,$ff    	; ab SCSI 2
		dc.b	11,12,13,14,8,9,0,1
		dc.b	2,3,4,5,6,16,17,$ff	; ab SCSI 3
		dc.b	12,13,14,8,9,10,0,1
		dc.b	2,3,4,5,6,16,17,$ff	; ab SCSI 4
		dc.b	13,14,8,9,10,11,0,1
		dc.b	2,3,4,5,6,16,17,$ff	; ab SCSI 5
		dc.b	14,8,9,10,11,12,0,1
		dc.b	2,3,4,5,6,16,17,$ff	; ab SCSI 6
		dc.b	8,9,10,11,12,13,0,1
		dc.b	2,3,4,5,6,16,17,$ff	; ab SCSI 7

acsilist:	dc.b	1,2,3,4,5,6,16,17
		dc.b	8,9,10,11,12,13,14,$ff	; ab ACSI 1
		dc.b	2,3,4,5,6,0,16,17
		dc.b	8,9,10,11,12,13,14,$ff	; ab ACSI 2
		dc.b	3,4,5,6,0,1,16,17
		dc.b	8,9,10,11,12,13,14,$ff	; ab ACSI 3
		dc.b    4,5,6,0,1,2,16,17
		dc.b	8,9,10,11,12,13,14,$ff	; ab ACSI 4
		dc.b	5,6,0,1,2,3,16,17
		dc.b	8,9,10,11,12,13,14,$ff	; ab ACSI 5
		dc.b	6,0,1,2,3,4,16,17
		dc.b	8,9,10,11,12,13,14,$ff	; ab ACSI 6
		dc.b	0,1,2,3,4,5,16,17
		dc.b	8,9,10,11,12,13,14,$ff	; ab ACSI 7

idelist		dc.b	17,8,9,10,11,12,13,14
		dc.b	0,1,2,3,4,5,6,$ff	; ab IDE1
		dc.b	16,8,9,10,11,12,13,14
		dc.b	0,1,2,3,4,5,6,$ff	; ab IDE2

