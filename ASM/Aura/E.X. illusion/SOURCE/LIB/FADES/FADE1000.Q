; ============================================================================
; Farbverlaufsberechnung zwischen zwei Farben, inkl. Fade-in, Fade-out und
; konvertierung in passende Farbformate (VDI/Falcon-Palette/STE-Palette).

; Autor:	Jochen Knaus, BDCannibal/AURA
; Date:	09.07.1994
; Update:	09.08.1994
; Bugfix:	27.12.1994
; Version:	1.12
; Format:	PMOD, as ever.
; ============================================================================

	MODUL	"f:\lib\calc_col.inc"
	MC68030
	ORG	0
	OPT	D-,O+

	IFND	TRUE
TRUE	EQU	1
FALSE	EQU	0
	ENDIF

	bra.w	calc_palette	; Palettenberechnung (linear) 9.7.94
	bra.w	calc_fade_in	; Fade in					   10.7.94
	bra.w	calc_fade_out	; Fade out				   10.7.94
	bra.w	vdi_xga	; VDI->High Colour			9.7.94
	bra.w	vdi_9800	; VDI->Falcon-palette		   10.7.94
	bra.w	vdi_8240	; VDI->ST/STE-palette		   10.7.94
	bra.w	calc_pals	; mehrere Paletten berechnen  8.8.94
	bra.w	conv_pals	; mehrere Paletten konvert.   9.8.94

	DC.B	'PMOD'
	DC.B	'VDI->XGA/98/824',0
	DC.B	'J.Knaus / AURA.',0
	DC.B	'079407940112'
	DC.B	'00------------'

; ============================================================================
; Berechnet  Farbverlauf in <Steps> Schritten zwischen zwei Farben <Startwert>
; und <Endwert>. Ergebnis getrennt RGB im VDI-Format im <Palettenbuffer>.
; Grundroutine, wird auch vom Einfaden und Ausfaden benutzt.

; a0.l - Startwert (RGB: R.w, G.w, B.w, VDI-Format: 0-1000)
; a1.l - Endwert 		"
; a2.l - Palettenbuffer (VDI-Format)
; d7.w - Steps
; ============================================================================
calc_palette:	movem.l	d0-a3,-(sp)

	tst.w	d7
	ble.s	error

	movea.l	a2,a3
	moveq	#3-1,d6	; 3 Farbanteile
calc_element:	move.w	(a0)+,d0	; Startwert
	move.w	(a1)+,d1	; Endwert
	movea.l	a3,a2

	sub.w	d0,d1	; dc
	swap	d1	; Steigung (16-Bit Fixkomma ber-
	clr.w	d1	; echnen).
	divs.l	d7,d1
	swap	d0	; Vorkomma ins High-Word !
	move.w	#$8000,d0
	
	move.w	d7,d5
	subq.w	#1,d5
	bmi.s	error
calc_basic:	swap	d0
	move.w	d0,(a2)
	swap	d0
	add.l	d1,d0
	addq.l	#6,a2
	dbra	d5,calc_basic

	addq.l	#2,a3
	dbra	d6,calc_element

no_error:	moveq	#TRUE,d0	; Z-Bit lîschen
	movem.l	(sp)+,d0-a3
	rts

error:	moveq	#FALSE,d0	; Z-Bit setzen
	movem.l	(sp)+,d0-a3
	rts

; ============================================================================
; Berechnet Fadein von scharz nach Endfarbe <steps> Schritten.

; a0.l - Endfarbe
; a2.l - Zielpalette
; d7.w - Anzahl Schritte
; ============================================================================
calc_fade_in:	pea	(a1)
	move.l	a0,a1
	lea	nullos(pc),a0
	bsr.w	calc_palette
	move.l	(sp)+,a1
	rts

; ============================================================================
; Berechnet Fadeout von Startfarbe nach schwarz in <steps> Schritten.

; a0.l - Startfarbe
; a2.l - Zielpalette
; d7.w - Anzahl Schritte
; ============================================================================
calc_fade_out:
	pea	(a1)
	lea	nullos(pc),a1
	bsr.w	calc_palette
	move.l	(sp)+,a1
	rts

; ============================================================================
; a0.l - Farbliste
; a1.l - Farbbuffer
; a2.l - Pointerliste (auf abgelegte Farbtabellen)
; d0.w - Modus (<0: Fade out, >0: Fade in, =0 Faden zwischen...
; d1.w - Steps
; d2.w - Anzahl Farben (bzw. Paletten)
; ============================================================================
calc_pals:	movem.l	d0-a6,-(sp)

	move.l	a0,a4
	move.l	a1,a5
	move.l	a2,a6

	move.w	d1,d7
	move.w	d1,d6
	mulu.w	#6,d6	; Grîûe einer Palette in Bytes
	subq.w	#1,d2	; Schleifenloop
	bmi.s	_rts

	tst.w	d0	; Modus: 0 = Zwischen zwei Farben
	blt.s	pal_f_o	;	  <0 = Ausfaden
	bgt.s	pal_f_i	;	  >0 = Einfaden

; Paletten zwischen zwei Farben faden.
fade_pal:	move.l	a4,a0	; &Startwert
	addq.l	#6,a4
	move.l	a4,a1	; &Endwert
	addq.l	#6,a4
	move.l	a5,a2	; Buffer
	move.l	a5,(a6)+	; Palettenadresse sichern.
	adda.l	d6,a5
	bsr.w	calc_palette
	dbra	d2,fade_pal

_rts:	movem.l	(sp)+,d0-a6
	rts

; Ausfadende Paletten berechnen.
pal_f_o:	move.l	a4,a0
	addq.l	#6,a4
	move.l	a5,a2
	move.l	a5,(a6)+
	adda.l	d6,a5
	bsr.w	calc_fade_out	
	dbra	d2,pal_f_o
	bra.s	_rts

; Einfadende Paletten berechnen.
pal_f_i:	move.l	a4,a0
	move.l	a5,a2
	move.l	a5,(a6)+
	adda.l	d6,a5
	addq.l	#6,a4
	bsr.w	calc_fade_in
	dbra	d2,pal_f_o
	bra.s	_rts

; ============================================================================
; Konvertiert VDI-Palette (oder Farbverlauf) ins High-Colour Format.

; a0.l - VDI-Palette
; a1.l - XGA-Palette (5:6:5): 2 Bytes / Farbe
; d7.w - Anzahl Farbwerte
; ============================================================================
vdi_xga:	movem.l	d0-a2,-(sp)

	moveq	#11,d3	; Shift fÅr rot
	move.w	#1000,d4	; Shift fÅr grÅn
	moveq	#$1f,d5
	moveq	#$3f,d6

	subq.w	#1,d7
	bmi.w	error

reduce_xga:	movem.w	(a0)+,d0-d2	; RGB-holen
	asl.w	#5,d0	; R*32 (2^5)
	asl.w	#6,d1	; G*64 (2^6)
	asl.w	#5,d2	; B*32
	divu.w	d4,d0	; R/1000
	beq.s	*+4	; Eh null ?
	subq.w	#1,d0	; -1 : 0-31
	divu.w	d4,d1
	beq.s	*+4
	subq.w	#1,d1
	divu.w	d4,d2
	beq.s	*+4
	subq.w	#1,d2
	and.w	d5,d0	
	and.w	d6,d1	
	and.w	d5,d2
	lsl.w	d3,d0	; An richtige Stelle shiften
	lsl.w	#5,d1
	or.w	d0,d1
	or.w	d1,d2	; R|G|B
	move.w	d2,(a1)+	; High-Colour Wert sichern
	dbra	d7,reduce_xga

	moveq	#TRUE,d1
	movem.l	(sp)+,d0-a2
	rts

; ============================================================================
; Konvertiert VDI-Palette (oder Farbverlauf) ins Falcon Palettenformat.

; a0.l - VDI-Palette
; a1.l - Palette im Falcon-Format (R.b-G.b-0.b-B.b): 4 Bytes / Farbe.
; d7.w - Anzahl Farbwerte
; ============================================================================
vdi_9800:	movem.l	d0-a2,-(sp)

	move.w	#1000,d4
	move.w	#$00ff,d5

	subq.w	#1,d7
	bmi.w	error

reduce_9800:	movem.w	(a0)+,d0-d2	; RGB-holen
	asl.l	#8,d0	; *256
	asl.l	#8,d1
	asl.l	#8,d2
	divu.w	d4,d0	; Dok. s.o.
	beq.s	*+4
	subq.w	#1,d0
	divu.w	d4,d1
	beq.s	*+4
	subq.w	#1,d1
	divu.w	d4,d2
	beq.s	*+4
	subq.w	#1,d2
	and.w	d5,d0	
	and.w	d5,d1	
	and.w	d5,d2
	move.b	d0,(a1)+	; rot
	move.b	d1,(a1)+	; grÅn
	clr.b	(a1)+
	move.b	d2,(a1)+	; blau
	dbra	d7,reduce_9800

	moveq	#TRUE,d1
	movem.l	(sp)+,d0-a2
	rts

; ============================================================================
; Konvertiert VDI-Palette ins STE-Format (ST-kompatibel).

; a0.l - VDI-Palette
; a1.l - Palette im STE-Format: 2 Bytes / Farbe.
; d7.w - Anzahl Farbwerte
; ============================================================================
vdi_8240:	movem.l	d0-a2,-(sp)

	move.w	#1000,d4
	moveq	#$0f,d5

	subq.w	#1,d7
	bmi.w	error

reduce_8240:	movem.w	(a0)+,d0-d2
	asl.w	#4,d0	; *16
	asl.w	#4,d1
	asl.w	#4,d2
	divu.w	d4,d0
	beq.s	*+4
	subq.w	#1,d0
	divu.w	d4,d1
	beq.s	*+4
	subq.w	#1,d1
	divu.w	d4,d2
	beq.s	*+4
	subq.w	#1,d2
	and.w	d5,d0	
	and.w	d5,d1	
	and.w	d5,d2
	asr.w	#1,d0	; Niederstes Bit gesetzt ?
	bcc.s	*+6
	bset	#3,d0	; ja->nach Bit 3 kopieren (STE)
	asr.w	#1,d1
	bcc.s	*+6
	bset	#3,d1
	asr.w	#1,d2
	bcc.s	*+6
	bset	#3,d2
	lsl.w	#8,d0	; Rot ins dritte Nibble
	lsl.w	#4,d1	; GrÅn ins zweite Nibble
	or.w	d0,d1
	or.w	d1,d2
	move.w	d2,(a1)+
	dbra	d7,reduce_8240
	
	moveq	#TRUE,d1
	movem.l	(sp)+,d0-a2
	rts

; ============================================================================
; Konvertiert mehrere Paletten in bestimmtes Format.

; a0.l - Pointerliste auf Farbpaletten
; a1.l - Bufferarray
; a2.l - Pointerliste auf neu erzeugte Tabellen
; d2.w - Anzahl Farbpaletten
; d1.w - Anzahl Steps in Paletten
; d0.w - Mode	(0 - vdi_xga, 1 - vdi_9800, 2 - vdi_8240
; ============================================================================
conv_pals:	movem.l	d0-a6,-(sp)
	move.l	a0,a4
	move.l	a1,a5
	move.l	a2,a6
	move.w	d2,d4
	subq.w	#1,d4	; Anzahl Paletten
	bmi.s	__rts
	move.w	d0,d5	; Mode < 0 ?
	bmi.s	__rts
	subq.w	#2,d0	; Mode > 2 ?
	bgt.s	__rts
conv_pals_lp:	move.l	(a4)+,a0	; VDI-Palette
	move.l	a5,a1	; Buffer
	move.l	a5,(a6)+	; Palettenpointer sichern
	move.w	d1,d7	; Steps
	move.w	(conv_tab.b,pc,d5.w*2),d2
	jsr	(conv_tab.b,pc,d2.w)

	move.w	(conv_lens.b,pc,d5.w*2),d2
	mulu.w	d1,d2	; Grîûe der Zielpalette
	adda.l	d2,a5
	dbra	d4,conv_pals_lp

	moveq	#1,d0	; N,Z lîschen
__rts:	movem.l	(sp)+,d0-a6	; Bei Fehler: N-Bit gesetzt
	rts

conv_tab:	DC.W	vdi_xga-conv_tab	; Jumptabelle fÅr Umwandlung
	DC.W	vdi_9800-conv_tab
	DC.W	vdi_8240-conv_tab

conv_lens:	DC.W	2	; XGA: 2 Bytes pro Farbe
	DC.W	4	; 9800: 4 StÅck
	DC.W	2	; 8240: 2 Bytes

nullos:	DC.W	0,0,0	; Schwarz (VDI-Format)