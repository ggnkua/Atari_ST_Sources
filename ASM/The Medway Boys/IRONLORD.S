	opt	o+,ow-,a+		; Optimierung einschalten
start:	bra.s atex
	dc.b 'IRON LORD - HACKED AND PACKED BY GL 20/09/91'
atex:	move.l	#stackend,d0
	subi.l	#start-$120,d0
	move.l	d0,-(sp)
	pea	start-$100(pc)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	adda.l	#$c,sp
	bsr.s	super
	move.l	$84.w,old_trap1+2	;store & change TRAP #1 vector
	move.l	$84.w,$80.w		;my trap #0
	move.l	#my_trap1,$84.w
	move.l	#my_trap15,$bc.w
	bsr.s	user
	pea	null(pc)
	pea	null(pc)
	pea	file_name(pc)
	move.w	#0,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea.l	16(sp),sp
	bsr.s	super
	move.l	old_trap1+2(pc),$84.w
	bsr.s	user
	clr.w	-(sp)
	trap	#1

null:	dc.l 0,0

file_name:	dc.b 'ironlord',0,0	; nachgeladenes Programm (pexec)

super:	clr.l	-(sp)		;supervisor state
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,d7
	rts	
user:	move.l	d7,-(sp)		;user state
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts	
my_trap15:
		cmp.b	#'A',(a1)
		bne.s notus
		cmp.b	#':',1(a1)
		bne.s notus
		cmp.b	#'\',2(a1)
		bne.s notus
		cmp.b	#'D',3(a1)
		bne.s notus
		cmp.b	#'I',4(a1)
		bne.s notus
		cmp.b	#'S',5(a1)
		bne.s notus
		addq.b #1,clogg
		cmp.b #'4',clogg
		bne.s new15a
		move.b #'1',clogg
new15a		move.b clogg,6(a1)
notus		clr.w -(sp)
		pea (a1)
		move.w #$3d,-(sp)
		trap #1
		addq.l #8,sp
		rte
clogg		dc.b '1',0
my_trap1: 
	movea.l	sp,a0
	btst	#$d-8,(sp)
	bne.s	supervisor
	move.l	usp,a0
	subq.l	#6,a0
supervisor:	
	addq.l	#6,a0
	cmpi.w	#$3f,(a0) 	; read
	beq.s	func_3f
	cmpi.w	#$3d,(a0)	; open
	bne.s	old_trap1
	move.l	2(a0),a1	;file name address
	cmp.b	#'A',(a1)
	bne.s old_trap1
	cmp.b	#':',1(a1)
	bne.s old_trap1
	cmp.b	#'\',2(a1)
	bne.s old_trap1
	cmp.b	#'D',3(a1)
	bne.s old_trap1
	cmp.b	#'I',4(a1)
	bne.s old_trap1
	cmp.b	#'S',5(a1)
	bne.s old_trap1
	move.b clogg,6(a1)
old_trap1:	
	jmp	0.l

func_3f:	
	move.l	8(a0),puffer
	lea 12(a0),a0
	moveq #5,d0
clog	move.w -(a0),-(a7)
	dbf d0,clog
	trap #0
	lea 12(a7),a7
	tst.l d0
	bmi ret_addr5
	movea.l	puffer(pc),a0	; Puffer
	bsr.s	decrunch
ret_addr5:	
	rte

decrunch
	link	a3,#-120
	movem.l	d0-a6,-(sp)
	lea	120(a0),a4	; a4 = Anfang entpackte Daten
	move.l	a4,a6		; a6 = Ende entpackte Daten
	bsr.s	.getinfo
	cmpi.l	#'ICE!',d0	; Kennung gefunden?
	bne	.not_packed
	bsr.s	.getinfo		; gepackte LÑnge holen
	lea.l	-8(a0,d0.l),a5	; a5 = Ende der gepackten Daten
	bsr.s	.getinfo		; ungepackte LÑnge holen (original)
	move.l	d0,(sp)		; OriginallÑnge: spÑter nach d0
	adda.l	d0,a6		; a6 = Ende entpackte Daten
	move.l	a6,a1

	moveq	#119,d0		; 120 Bytes hinter entpackten Daten
.save:	move.b	-(a1),-(a3)	; in sicheren Bereich sichern
	dbf	d0,.save
	move.l	a6,a3		; merken fÅr Picture decrunch
	move.b	-(a5),d7		; erstes Informationsbyte
	bsr.s	.normal_bytes
	move.l	a3,a5		; fÅr 120 Bytes restore

.no_picture
	movem.l	(sp),d0-a3	; hole nîtige Register

.move	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0		; um Åberschriebenen Bereich
.rest	move.b	-(a3),-(a5)	; wieder herzustellen
	dbf	d0,.rest
.not_packed:
	movem.l	(sp)+,d0-a6
	unlk	a3
	rts

.getinfo: moveq	#3,d1		; ein Langwort vom Anfang
.getbytes: lsl.l	#8,d0		; der Daten lesen
	move.b	(a0)+,d0
	dbf	d1,.getbytes
	rts

.normal_bytes:	
	bsr.s	.get_1_bit
	bcc.s	.test_if_end	; Bit %0: keine Daten
	moveq.l	#0,d1		; falls zu copy_direkt
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt	; Bitfolge: %10: 1 Byte direkt kop.
	lea.l	.direkt_tab+20(pc),a1
	moveq.l	#4,d3
.nextgb:	move.l	-(a1),d0		; d0.w Bytes lesen
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1		; alle gelesenen Bits gesetzt?
	dbne	d3,.nextgb	; ja: dann weiter Bits lesen
.no_more: add.l	20(a1),d1 	; Anzahl der zu Åbertragenen Bytes
.copy_direkt:	
	move.b	-(a5),-(a6)	; Daten direkt kopieren
	dbf	d1,.copy_direkt	; noch ein Byte
.test_if_end:	
	cmpa.l	a4,a6		; Fertig?
	bgt.s	.strings		; Weiter wenn Ende nicht erreicht
	rts	

;************************** Unterroutinen: wegen Optimierung nicht am Schluû

.get_1_bit:
	add.b	d7,d7		; hole ein bit
	bne.s	.bitfound 	; quellfeld leer
	move.b	-(a5),d7		; hole Informationsbyte
	addx.b	d7,d7
.bitfound:
	rts	

.get_d0_bits:	
	moveq.l	#0,d1		; ergebnisfeld vorbereiten
.hole_bit_loop:	
	add.b	d7,d7		; hole ein bit
	bne.s	.on_d0		; in d7 steht noch Information
	move.b	-(a5),d7		; hole Informationsbyte
	addx.b	d7,d7
.on_d0:	addx.w	d1,d1		; und Åbernimm es
	dbf	d0,.hole_bit_loop	; bis alle Bits geholt wurden
	rts	

;************************************ Ende der Unterroutinen


.strings: lea.l	.length_tab(pc),a1	; a1 = Zeiger auf Tabelle
	moveq.l	#3,d2		; d2 = Zeiger in Tabelle
.get_length_bit:	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit	; nÑchstes Bit holen
.no_length_bit:	
	moveq.l	#0,d4		; d4 = öberschuû-LÑnge
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0	; d2: zw. -1 und 3; d3+1: Bits lesen
	ext.w	d0		; als Wort behandeln
	bmi.s	.no_Åber		; kein öberschuû nîtig
.get_Åber:
	bsr.s	.get_d0_bits
.no_Åber:	move.b	6(a1,d2.w),d4	; Standard-LÑnge zu öberschuû add.
	add.w	d1,d4		; d4 = String-LÑnge-2
	beq.s	.get_offset_2	; LÑnge = 2: Spezielle Offset-Routine


	lea.l	.more_offset(pc),a1 ; a1 = Zeiger auf Tabelle
	moveq.l	#1,d2
.getoffs: bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.l	#0,d1		; Offset-öberschuû
	move.b	1(a1,d2.w),d0	; request d0 Bits
	ext.w	d0		; als Wort
	bsr.s	.get_d0_bits
	add.w	d2,d2		; ab jetzt: Pointer auf Worte
	add.w	6(a1,d2.w),d1	; Standard-Offset zu öberschuû add.
	bpl.s	.depack_bytes	; keine gleiche Bytes: String kop.
	sub.w	d4,d1		; gleiche Bytes
	bra.s	.depack_bytes


.get_offset_2:	
	moveq.l	#0,d1		; öberschuû-Offset auf 0 setzen
	moveq.l	#5,d0		; standard: 6 Bits holen
	moveq.l	#-1,d2		; Standard-Offset auf -1
	bsr.s	.get_1_bit
	bcc.s	.less_40		; Bit = %0
	moveq.l	#8,d0		; quenty fourty: 9 Bits holen
	moveq.l	#$3f,d2		; Standard-Offset: $3f
.less_40: bsr.s	.get_d0_bits
	add.w	d2,d1		; Standard-Offset + öber-Offset

.depack_bytes:			; d1 = Offset, d4 = Anzahl Bytes
	lea.l	2(a6,d4.w),a1	; Hier stehen die Originaldaten
	adda.w	d1,a1		; Dazu der Offset
	move.b	-(a1),-(a6)	; ein Byte auf jeden Fall kopieren
.dep_b:	move.b	-(a1),-(a6)	; mehr Bytes kopieren
	dbf	d4,.dep_b 	; und noch ein Mal
	bra	.normal_bytes	; Jetzt kommen wieder normale Bytes


.direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001	; Anzahl 1-Bits
	dc.l     270-1,	15-1,	 8-1,	 5-1,	 2-1	; Anz. Bytes

.length_tab:
	dc.b 9,1,0,-1,-1		; Bits lesen
	dc.b 8,4,2,1,0		; Standard-LÑnge - 2 (!!!)

.more_offset:
	dc.b	  11,   4,   7,  0	; Bits lesen
	dc.w	$11f,  -1, $1f	; Standard Offset

puffer:		ds.l 1
		ds.b 500
stackend: 	ds.b 20
