;********************************************* Unpackroutine von ICE-PACK
; Eingabe: a0 = Adresse gepackter Daten
ice_decrunch_3:
	link	a3,#-120
	movem.l	d0-a6,-(sp)
	move.l	a0,a1
	move.l	a0,a4		; a4 = Anfang entpackte Daten
	move.l	a0,a6		; a6 = Ende entpackte Daten
	bsr.s	.getinfo
	cmpi.l	#'ICE!',d0	; Kennung gefunden?
	bne	.not_packed
	bsr.s	.getinfo		; gepackte L�nge holen
	moveq	#119,d1		; 120 Bytes vor gepackten Daten
.save:	move.b	-(a1),-(a3)	; in sicheren Bereich sichern
	dbf	d1,.save
	move.l	a1,a2		; Anfang der gepackten Daten
	lea.l	-8(a1,d0.l),a5	; a5 = Ende der gepackten Daten
.move	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	.move
	move.l	a2,a0
	bsr.s	.getinfo		; ungepackte L�nge holen (original)
	move.l	d0,(sp)		; Originall�nge: sp�ter nach d0
	adda.l	d0,a6		; a6 = Ende entpackte Daten
	move.l	a6,a3		; merken f�r Picture decrunch
	move.b	-(a5),d7		; erstes Informationsbyte
	bsr.s	.normal_bytes

	bsr.s	.get_1_bit	;; Picture decrunch!
	bcc.s	.no_picture	;; These marked lines may be
	move.w	#$0f9f,d7 	;; removed in your own sources
.ice_00:	moveq	#3,d6		;; if you do not use the
.ice_01:	move.w	-(a3),d4		;; additional algorithm.
	moveq	#3,d5		;;
.ice_02:	add.w	d4,d4		;;
	addx.w	d0,d0		;;
	add.w	d4,d4		;;
	addx.w	d1,d1		;;
	add.w	d4,d4		;;
	addx.w	d2,d2		;;
	add.w	d4,d4		;;
	addx.w	d3,d3		;;
	dbra	d5,.ice_02	;;
	dbra	d6,.ice_01	;;
	movem.w	d0-d3,(a3)	;;
	dbra	d7,.ice_00	;;
.no_picture

	movem.l	(sp),d0-a3	; hole n�tige Register
	moveq	#119,d0		; um �berschriebenen Bereich
.rest	move.b	-(a3),-(a4)	; wieder herzustellen
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
.no_more: add.l	20(a1),d1 	; Anzahl der zu �bertragenen Bytes
.copy_direkt:	
	move.b	-(a5),-(a6)	; Daten direkt kopieren
	dbf	d1,.copy_direkt	; noch ein Byte
.test_if_end:	
	cmpa.l	a4,a6		; Fertig?
	bgt.s	.strings		; Weiter wenn Ende nicht erreicht
	rts	

;************************** Unterroutinen: wegen Optimierung nicht am Schlu�

.get_1_bit:add.b	d7,d7		; hole ein bit
	bne.s	.bitfound 	; quellfeld leer
	move.b	-(a5),d7		; hole Informationsbyte
	addx.b	d7,d7
.bitfound:	rts	

.get_d0_bits:	
	moveq.l	#0,d1		; ergebnisfeld vorbereiten
.hole_bit_loop:	
	add.b	d7,d7		; hole ein bit
	bne.s	.on_d0		; in d7 steht noch Information
	move.b	-(a5),d7		; hole Informationsbyte
	addx.b	d7,d7
.on_d0:	addx.w	d1,d1		; und �bernimm es
	dbf	d0,.hole_bit_loop	; bis alle Bits geholt wurden
	rts	

;************************************ Ende der Unterroutinen


.strings: lea.l	.length_tab(pc),a1	; a1 = Zeiger auf Tabelle
	moveq.l	#3,d2		; d2 = Zeiger in Tabelle
.get_length_bit:	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit	; n�chstes Bit holen
.no_length_bit:	
	moveq.l	#0,d4		; d4 = �berschu�-L�nge
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0	; d2: zw. -1 und 3; d3+1: Bits lesen
	ext.w	d0		; als Wort behandeln
	bmi.s	.no_�ber		; kein �berschu� n�tig
.get_�ber: bsr.s	.get_d0_bits
.no_�ber: move.b	6(a1,d2.w),d4	; Standard-L�nge zu �berschu� add.
	add.w	d1,d4		; d4 = String-L�nge-2
	beq.s	.get_offset_2	; L�nge = 2: Spezielle Offset-Routine


	lea.l	.more_offset(pc),a1 ; a1 = Zeiger auf Tabelle
	moveq.l	#1,d2
.getoffs: bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.l	#0,d1		; Offset-�berschu�
	move.b	1(a1,d2.w),d0	; request d0 Bits
	ext.w	d0		; als Wort
	bsr.s	.get_d0_bits
	add.w	d2,d2		; ab jetzt: Pointer auf Worte
	add.w	6(a1,d2.w),d1	; Standard-Offset zu �berschu� add.
	bpl.s	.depack_bytes	; keine gleiche Bytes: String kop.
	sub.w	d4,d1		; gleiche Bytes
	bra.s	.depack_bytes


.get_offset_2:	
	moveq.l	#0,d1		; �berschu�-Offset auf 0 setzen
	moveq.l	#5,d0		; standard: 6 Bits holen
	moveq.l	#-1,d2		; Standard-Offset auf -1
	bsr.s	.get_1_bit
	bcc.s	.less_40		; Bit = %0
	moveq.l	#8,d0		; quenty fourty: 9 Bits holen
	moveq.l	#$3f,d2		; Standard-Offset: $3f
.less_40: bsr.s	.get_d0_bits
	add.w	d2,d1		; Standard-Offset + �ber-Offset

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
	dc.b 8,4,2,1,0		; Standard-L�nge - 2 (!!!)

.more_offset:
	dc.b	  11,   4,   7,  0	; Bits lesen
	dc.w	$11f,  -1, $1f	; Standard Offset

ende_ice_decrunch_3:
;*************************************************** Ende der Unpackroutine
