;********************************************* Unpackroutine von FIRE-PACK
; Eingabe: a0 = Adresse gepackter Daten
; Ausgabe: a1 = Adresse entpackter Daten
; a2 und a3 sind wÑhrend der Packroutine unbelegt
fire_decrunch:
	movem.l	d0-a6,-(sp)
	bsr.s	.getinfo		; Kenn-Langwort holen
	cmp.l	#'FIRE',d0	; Kennung gefunden?
	bne.s	.not_packed	; nein: nicht gepackt
	bsr.s	.getinfo		; Kenn-Langwort holen
	lea	-8(a0,d0.l),a5	; a5 = Ende aller Daten
	bsr.s	.getinfo		; LÑnge holen
	move.l	d0,(sp)		; OriginallÑnge: spÑter nach d0
	move.l	a1,a4
	move.l	a1,a6
	add.l	d0,a6		; a6 = neues Ende
				; a5 = Ende von Byte-Daten
	move.b	-(a5),d7		; erstes Informationslangwort
	lea	.tabellen(pc),a3	; a3 = Zeiger auf Datenbereich
	moveq	#1,d6
	swap	d6		; d6 = $10000
	moveq	#0,d5		; d5 = 0 (oberes Wort: immer 0!)

.normal_bytes:
	bsr.s	.get_1_bit
	bcc.s	.test_if_end	; Bit %0: keine Daten
	moveq	#0,d1		; falls zu .copy_direkt
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt	 ; Bitfolge: %10: 1 Byte direkt kop.
;	lea.l	.direkt_tab+16-.tabellen(a3),a0 ; ...siehe nÑchste Zeile
	move.l	a3,a0
	moveq	#3,d3
.nextgb:	move.l	-(a0),d0		; d0.w Bytes lesen
	bsr.s	.get_d0_bits
	swap	d0
	cmp.w	d0,d1		; alle gelesenen Bits gesetzt?
	dbne	d3,.nextgb	; ja: dann weiter Bits lesen
.no_more: add.l	16(a0),d1 	; Anzahl der zu Åbertragenen Bytes
.copy_direkt:
	move.b	-(a5),-(a6)	; Daten direkt kopieren
	dbf	d1,.copy_direkt	; noch ein Byte
.test_if_end:
	cmp.l	a4,a6		; Fertig?
	bgt.s	.strings		; Weiter wenn Ende nicht erreicht
.not_packed:
	movem.l	(sp)+,d0-a6
	rts

;************************** Unterroutinen: wegen Optimierung nicht am Schluû
.getinfo:
	moveq	#3,d1
.glw:	rol.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,.glw
	rts


.get_1_bit:
	add.b	d7,d7		; hole ein Bit
	beq.s	.no_bit_found
	rts
.no_bit_found:
	move.b	-(a5),d7
	addx.b	d7,d7
	rts

.get_d0_bits:
	moveq	#0,d1		; Ergebnisfeld vorbereiten
.hole_bit_loop:
	add.b	d7,d7		; hole ein Bit
	beq.s	.not_found	; quellfeld leer
.on_d0:	addx.w	d1,d1		; und Åbernimm es
	dbf	d0,.hole_bit_loop	; bis alle Bits geholt wurden
	rts

.not_found:
	move.b	-(a5),d7		; hole sonst ein weiteres Longword
	addx.b	d7,d7		; hole ein Bit
	bra.s	.on_d0

;************************************ Ende der Unterroutinen


.strings:
	moveq	#1,d0		; 2 Bits lesen
	bsr.s	.get_d0_bits
	subq.w	#1,d1
	bmi.s	.gleich_morestring	; %00
	beq.s	.length_2 	; %01
	subq.w	#1,d1
	beq.s	.length_3 	; %10
	bsr.s	.get_1_bit
	bcc.s	.bitset		; %110
	bsr.s	.get_1_bit
	bcc.s	.length_4 	; %1110
	bra.s	.length_5 	; %1111

.get_short_offset:
	moveq	#1,d0
	bsr.s	.get_d0_bits	; d1:  0,  1,  2,  3
	subq.w	#1,d1
	bpl.s	.contoffs
	moveq	#0,d0		; Sonderfall
	rts

.get_long_offset:
	moveq	#1,d0		; 2 Bits lesen
	bsr.s	.get_d0_bits	; d1:  0,  1,  2,  3
.contoffs: add.w	d1,d1		; d1:  0,  2,  4,  6
	add.w	d1,d1		; d1:  0,  4,  8, 12
	movem.w	.offset_table-.tabellen(a3,d1),d0/d5
	bsr.s	.get_d0_bits	; 4, 8, 12 oder 16 Bits lesen
	add.l	d5,d1
	rts


.gleich_morestring: 		; %00
	moveq	#1,d0		; 2 Bits lesen
	bsr.s	.get_d0_bits	; d1:  0,  1,  2,  3
	subq.w	#1,d1
	bmi.s	.gleich_string	; %0000

	add.w	d1,d1		; d1:	 0,  2,  4
	add.w	d1,d1		; d1:	 0,  4,  8
	movem.w	.more_table-.tabellen(a3,d1),d0/d2
	bsr.s	.get_d0_bits
	add.w	d1,d2		; d2 = StringlÑnge
	bsr.s	.get_long_offset
	move.w	d2,d0		; d0 = StringlÑnge
	bra.s	.copy_longstring

.bitset:	moveq	#2,d0		; %110
	bsr.s	.get_d0_bits
	moveq	#0,d0
	bset	d1,d0
	bra.s	.put_d0

.length_2:
	moveq	#7,d0		; %01
	bsr.s	.get_d0_bits
	moveq	#2-2,d0
	bra.s	.copy_string

.length_3:
	bsr.s	.get_short_offset	; %10
	tst.w	d0
	beq	.put_d0		; 0 ablegen
	moveq	#3-2,d0
	bra.s	.copy_string

.length_4:
	bsr.s	.get_short_offset	; %1110
	tst.w	d0
	beq.s	.vorganger_kopieren
	moveq	#4-2,d0
	bra.s	.copy_string

.length_5:
	bsr.s	.get_short_offset	; %1111
	tst.w	d0
	beq.s	.put_ff
	moveq	#5-2,d0
	bra.s	.copy_string


.put_ff:	moveq	#-1,d0
	bra.s	.put_d0

.vorganger_kopieren:
	move.b	(a6),d0
;	bra.s	.put_d0

.put_d0:	move.b	d0,-(a6)
	bra.s	.backmain


.gleich_string:
	bsr.s	.get_long_offset	; Anzahl gleicher Bytes lesen
	beq.s	.backmain 	; 0: zurÅck
	move.b	(a6),d0
.copy_gl: move.b	d0,-(a6)
	dbf	d1,.copy_gl
	sub.l	d6,d1
	bmi.s	.backmain
	bra.s	.copy_gl

.copy_longstring:
	subq.w	#2,d0		; StringlÑnge - 2 (wegen dbf)
.copy_string:			; d1 = Offset, d0 = Anzahl Bytes -2
	lea.l	2(a6,d1.l),a0	; Hier stehen die Originaldaten
	add.w	d0,a0		; dazu die StringlÑnge-2
	move.b	-(a0),-(a6)	; ein Byte auf jeden Fall kopieren
.dep_b:	move.b	-(a0),-(a6)	; mehr Bytes kopieren
	dbf	d0,.dep_b 	; und noch ein Mal
.backmain: bra	.normal_bytes	; Jetzt kommen wieder normale Bytes


.direkt_tab:
	dc.l	$03ff0009,$00070002,$00030001,$00030001 ; Anzahl 1-Bits
.tabellen:	dc.l	    15-1,      8-1,      5-1,      2-1	; Anz. Bytes

.offset_table:
	dc.w	 3,	      0
	dc.w	 7,	   16+0
	dc.w	11,      256+16+0
	dc.w	15, 4096+256+16+0
.more_table:
	dc.w	3,       5
	dc.w	5,    16+5
	dc.w	7, 64+16+5
;*************************************************** Ende der Unpackroutine
