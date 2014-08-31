;Tabulatorgrîûe:	3
;Kommentare:																;ab Spalte 60


PX_1COMP				EQU	$01000000										;Pixel besteht aus einer benutzten Komponente: Farbindex
PX_3COMP				EQU	$03000000										;Pixel besteht aus drei benutzten Komponenten, z.B. RGB
PX_4COMP				EQU	$04000000										;Pixel besteht aus vier benutzten Komponenten, z.B. CMYK

PX_REVERSED			EQU	$00800000										;Pixel wird in umgekehrter Bytreihenfolge ausgegeben
PX_xFIRST			EQU	$00400000										;unbenutzte Bits liegen vor den benutzen (im Motorola-Format betrachtet)
PX_ALPHA				EQU	$00200000										;Alphakanal
PX_aFIRST			EQU	$00100000										;Alphakanal liegen vor den Farbbits (im Motorola-Format betrachtet)

PX_PACKED			EQU	$00020000										;Bits sind aufeinanderfolgend abgelegt
PX_PLANES			EQU	$00010000										;Bits sind auf mehrere Ebenen verteilt (Reihenfolge: 0, 1, ..., n)
PX_IPLANES			EQU	$00000000										;Bits sind auf mehrere Worte verteilt (Reihenfolge: 0, 1, ..., n)

PX_USES1				EQU	$00000100										;1 Bit des Pixels wird benutzt
PX_USES2				EQU	$00000200										;2 Bit des Pixels werden benutzt
PX_USES3				EQU	$00000300										;3 Bit des Pixels werden benutzt
PX_USES4				EQU	$00000400										;4 Bit des Pixels werden benutzt
PX_USES8				EQU	$00000800										;8 Bit des Pixels werden benutzt
PX_USES15			EQU	$00000f00										;15 Bit des Pixels werden benutzt
PX_USES16			EQU	$00001000										;16 Bit des Pixels werden benutzt
PX_USES24			EQU	$00001800										;24 Bit des Pixels werden benutzt
PX_USES32			EQU	$00002000										;32 Bit des Pixels werden benutzt
PX_USES48			EQU	$00002000										;48 Bit des Pixels werden benutzt

PX_1BIT				EQU	$00000001										;Pixel besteht aus 1 Bit
PX_2BIT				EQU	$00000002										;Pixel besteht aus 2 Bit
PX_3BIT				EQU	$00000003										;Pixel besteht aus 3 Bit
PX_4BIT				EQU	$00000004										;Pixel besteht aus 4 Bit
PX_8BIT				EQU	$00000008										;Pixel besteht aus 8 Bit
PX_16BIT				EQU	$00000010										;Pixel besteht aus 16 Bit
PX_24BIT				EQU	$00000018										;Pixel besteht aus 24 Bit
PX_32BIT				EQU	$00000020										;Pixel besteht aus 32 Bit
PX_48BIT				EQU	$00000030										;Pixel besteht aus 48 Bit

PX_CMPNTS			EQU	$0f000000										;Maske fÅr Anzahl der Pixelkomponenten
PX_FLAGS				EQU	$00f00000										;Maske fÅr diverse Flags
PX_PACKING			EQU	$00030000										;Maske fÅr Pixelformat
PX_USED				EQU	$00003f00										;Maske fÅr Anzahl der benutzten Bits
PX_BITS				EQU	$0000003f										;Maske fÅr Anzahl der Bits pro Pixel

PX_REVERSED_BIT	EQU	23
PX_xFIRST_BIT		EQU	22
PX_ALPHA_BIT		EQU	21
PX_aFIRST_BIT		EQU	20

						EXPORT	init_transform8
						EXPORT	transform8
						EXPORT	transform32

						TEXT

;int16	transform8( int32 dx, int32 dy, int32 dst_format, void *src, void *dst, int32 src_width, int32 dst_width );
;d0.l Breite in Pixeln - 1
;d1.l Hîhe in Zeilen - 1
;d2.l Zielformat
;a0.l Quelladresse
;a1.l Zieladresse
;4(sp).l Bytes pro Quellzeile
;8(sp).l Bytes pro Zielzeile
;Ausgaben:
;d0.w
transform8:			movem.l	d3-d7/a2-a6,-(sp)						;10 Register
						movea.l	44(sp),a2
						movea.l	48(sp),a3
						
						moveq		#PX_BITS,d3
						and.w		d2,d3										;Bit pro Pixel
						cmp.w		#8,d3										;mehr als 8 Bit pro Pixel?
						bhi.s		transform8_err

 						add.w		d3,d3
 						
						move.l	d2,d4
						swap		d4
						and.w		#(PX_PACKING>>16),d4
						add.w		d4,d4
						add.w		tr8_offset(pc,d4.w),d3				;Abstand der Tabelle
						
						move.w	tr8ip_tab(pc,d3.w),d3
						beq.s		transform8_err
						
						jsr		tr8ip_tab(pc,d3.w)

						movem.l	(sp)+,d3-d7/a2-a6
						moveq		#1,d0										;alles in Ordnung
						rts

transform8_err:	movem.l	(sp)+,d3-d7/a2-a6
						moveq		#0,d0										;Fehler: nicht unterstÅtztes Format
						rts

tr8_offset:			DC.w		tr8ip_tab-tr8ip_tab					;0
						DC.w		tr8pl_tab-tr8ip_tab					;1
						DC.w		tr8pp_tab-tr8ip_tab					;2

;Tabelle fÅr Wandlung in Interleaved Planes
tr8ip_tab:			DC.w		0
						DC.w		t8pp1-tr8ip_tab						;1
						DC.w		0,0
						DC.w		t8ip4-tr8ip_tab						;4
						DC.w		0,0,0
						DC.w		t8ip8-tr8ip_tab						;8

;Tabelle fÅr Wandlung in Planes
tr8pl_tab:			DC.w		0
						DC.w		t8pp1-tr8ip_tab						;1
						DC.w		0
						DC.w		t8pl3-tr8ip_tab						;3
						DC.w		t8pl4-tr8ip_tab						;4
						DC.w		0,0,0,0
						
;Tabelle fÅr Wandlung in Packed Pixels
tr8pp_tab:			DC.w		0
						DC.w		t8pp1-tr8ip_tab						;1
						DC.w		0,0
						DC.w		t8pp4-tr8ip_tab						;4
						DC.w		0,0,0
						DC.w		t8pp8-tr8ip_tab						;8

;Byte mit 1 signifikanten Bit in 1 Bit-Packed-Pixels umwandeln
;Vorgaben:
;Register d0-d7/a0-a5 kînnen verÑndert werden
;Eingaben:
;d0.l Breite in Pixeln - 1
;d1.l Hîhe in Zeilen - 1
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Bytes pro Quellzeile
;a3.l Bytes pro Zielzeile
;Ausgaben:
;-
t8pp1:				moveq		#8,d2
						add.l		d0,d2										;ggf. auf nÑchste 8er-Grenze aufrunden
						moveq		#$fffffff8,d0
						and.l		d2,d0
						suba.l	d0,a2										;Abstand zur nÑchsten Quellzeile
						lsr.l		#3,d0
						suba.l	d0,a3										;Abstand zur nÑchsten Zielzeile
						subq.l	#1,d0

t8pp1_line:			move.w	d0,d2										;( Breite / 8 ) - 1

t8pp1_loop:			REPT		8
						move.b	(a0)+,d3
						lsr.w		#1,d3
						addx.w	d4,d4
						ENDM
						move.b	d4,(a1)+
						
						dbra		d2,t8pp1_loop
						
						adda.l	a2,a0										;nÑchste Quellzeile
						adda.l	a3,a1										;nÑchste Zielzeile
						
						dbra		d1,t8pp1_line

						rts


;Byte mit 4 signifikanten Bits in 4 Bit-Packed-Pixels umwandeln
;Vorgaben:
;Register d0-d7/a0-a5 kînnen verÑndert werden
;Eingaben:
;d0.l Breite in Pixeln - 1
;d1.l Hîhe in Zeilen - 1
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Bytes pro Quellzeile
;a3.l Bytes pro Zielzeile
;Ausgaben:
;-
t8pp4:				moveq		#16,d2
						add.w		d0,d2										;ggf. auf nÑchste 16er-Grenze aufrunden
						moveq		#$fffffff0,d0
						and.l		d2,d0
						suba.l	d0,a2										;Abstand zur nÑchsten Quellzeile
						lsr.l		#1,d0
						suba.l	d0,a3										;Abstand zur nÑchsten Zielzeile
						lsr.l		#3,d0
						subq.l	#1,d0

t8pp4_line:			move.w	d0,d2										;( Breite / 16 ) - 1

t8pp4_loop:			move.l	(a0)+,d4									;x0x1x2x3
						move.l	(a0)+,d5
						move.l	(a0)+,d6
						move.l	(a0)+,d7

						lsl.b		#4,d4										;x0x1x23_
						lsl.b		#4,d5
						lsl.b		#4,d6
						lsl.b		#4,d7

						lsl.w		#4,d4										;x0x123__
						lsl.w		#4,d5
						lsl.w		#4,d6
						lsl.w		#4,d7
						
						swap		d4											;23__x0x1
						swap		d5
						swap		d6
						swap		d7

						lsl.b		#4,d4										;23__x01_
						lsl.b		#4,d5
						lsl.b		#4,d6
						lsl.b		#4,d7
						
						lsr.w		#4,d4										;23___x01
						lsr.w		#4,d5
						lsr.w		#4,d6
						lsr.w		#4,d7
						
						ror.l		#8,d4										;0123___x
						rol.l		#8,d5										;___x0123
						ror.l		#8,d6
						rol.l		#8,d7
						
						move.w	d5,d4
						move.w	d7,d6
						
						move.l	d4,(a1)+
						move.l	d6,(a1)+

						dbra		d2,t8pp4_loop
						
						adda.l	a2,a0										;nÑchste Quellzeile
						adda.l	a3,a1										;nÑchste Zielzeile
						
						dbra		d1,t8pp4_line
						
						rts

;Byte mit 8 signifikanten Bits in 8 Bit-Packed-Pixels umwandeln (kopieren)
;Vorgaben:
;Register d0-d7/a0-a5 kînnen verÑndert werden
;Eingaben:
;d0.l Breite in Pixeln - 1
;d1.l Hîhe in Zeilen - 1
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Bytes pro Quellzeile
;a3.l Bytes pro Zielzeile
;Ausgaben:
;-
t8pp8:				cmpa.l	a0,a1										;gleiche Adresse, nicht kopieren?
						beq.s		t8pp8_exit

						moveq		#16,d2
						add.w		d0,d2										;ggf. auf nÑchste 16er-Grenze aufrunden
						moveq		#$fffffff0,d0
						and.l		d2,d0
						suba.l	d0,a2										;Abstand zur nÑchsten Quellzeile
						suba.l	d0,a3										;Abstand zur nÑchsten Zielzeile
						lsr.l		#4,d0
						subq.l	#1,d0

t8pp8_line:			move.w	d0,d2										;( Breite / 16 ) - 1

t8pp8_loop:			move.l	(a0)+,(a1)+
						move.l	(a0)+,(a1)+
						move.l	(a0)+,(a1)+
						move.l	(a0)+,(a1)+
						dbra		d2,t8pp8_loop
						
						adda.l	a2,a0										;nÑchste Quellzeile
						adda.l	a3,a1										;nÑchste Zielzeile
						
						dbra		d1,t8pp8_line
						
t8pp8_exit:			rts


;Byte mit 4 signifikanten Bits in 4 Interleaved Planes umwandeln
;Vorgaben:
;Register d0-d7/a0-a5 kînnen verÑndert werden
;Eingaben:
;d0.l Breite in Pixeln - 1
;d1.l Hîhe in Zeilen - 1
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Bytes pro Quellzeile
;a3.l Bytes pro Zielzeile
;Ausgaben:
;-
t8ip4:				moveq		#16,d2
						add.w		d0,d2										;ggf. auf nÑchste 16er-Grenze aufrunden
						moveq		#$fffffff0,d0
						and.l		d2,d0
						suba.l	d0,a2										;Abstand zur nÑchsten Quellzeile
						lsr.l		#1,d0
						suba.l	d0,a3										;Abstand zur nÑchsten Zielzeile
						lsr.l		#3,d0
						subq.l	#1,d0

						lea		t8ip4_tab,a4

t8ip4_line:			move.w	d0,d2										;( Breite / 16 ) - 1

t8ip4_loop:			moveq		#7,d3										;8 Pixel einlesen und konvertieren
						moveq		#0,d5

t8ip4_byte1:		moveq		#0,d4
						add.l		d5,d5
						move.b	(a0)+,d4
						add.w		d4,d4
						add.w		d4,d4
						or.l		0(a4,d4.w),d5							;Byte 1 von Ebenen 0-3
						dbra		d3,t8ip4_byte1
						
						moveq		#7,d3										;8 Pixel einlesen und konvertieren
						moveq		#0,d6

t8ip4_byte2:		moveq		#0,d4
						add.l		d6,d6
						move.b	(a0)+,d4
						add.w		d4,d4
						add.w		d4,d4
						or.l		0(a4,d4.w),d6							;Byte 2 von Ebenen 0-3
						dbra		d3,t8ip4_byte2
						
						movep.l	d5,0(a1)									;00__ 11__ 22__ 33__
						movep.l	d6,1(a1)									;__00 __11 __22 __33
						addq.l	#8,a1
						
						dbra		d2,t8ip4_loop
						
						adda.l	a2,a0										;nÑchste Quellzeile
						adda.l	a3,a1										;nÑchste Zielzeile
						
						dbra		d1,t8ip4_line

						rts


;Byte mit 4 signifikanten Bits in 4 Interleaved Planes umwandeln, am Bitmapende mit der Wandlung beginnen
;Vorgaben:
;Register d0-d7/a0-a5 kînnen verÑndert werden
;Eingaben:
;d0.l Breite in Pixeln - 1
;d1.l Hîhe in Zeilen - 1
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Bytes pro Quellzeile
;a3.l Bytes pro Zielzeile
;Ausgaben:
;-
t8ipb4:				moveq		#16,d2
						add.w		d0,d2										;ggf. auf nÑchste 16er-Grenze aufrunden
						moveq		#$fffffff0,d0
						and.l		d2,d0
						
						move.l	a2,d2
						mulu		d1,d2
						adda.l	d2,a0
						adda.l	d0,a0										;Zeiger hinter das letzte benutzte Pixel der letzten Zeile
						suba.l	d0,a2										;Abstand zur nÑchsten Quellzeile

						lsr.l		#1,d0
						move.l	a3,d3
						mulu		d1,d3
						adda.l	d3,a1
						adda.l	d0,a1										;Zeiger hinter das letzte benutzte Pixel der letzten Zeile		
						suba.l	d0,a3										;Abstand zur nÑchsten Zielzeile

						lsr.l		#3,d0
						subq.l	#1,d0

						lea		t8ip4_tab,a4

t8ipb4_line:		move.w	d0,d2										;( Breite / 16 ) - 1

t8ipb4_loop:		lea		-16(a0),a0
						subq.l	#8,a1

						moveq		#7,d3										;8 Pixel einlesen und konvertieren
						moveq		#0,d5

t8ipb4_byte1:		moveq		#0,d4
						add.l		d5,d5
						move.b	(a0)+,d4
						add.w		d4,d4
						add.w		d4,d4
						or.l		0(a4,d4.w),d5							;Byte 1 von Ebenen 0-3
						dbra		d3,t8ipb4_byte1
						
						moveq		#7,d3										;8 Pixel einlesen und konvertieren
						moveq		#0,d6

t8ipb4_byte2:		moveq		#0,d4
						add.l		d6,d6
						move.b	(a0)+,d4
						add.w		d4,d4
						add.w		d4,d4
						or.l		0(a4,d4.w),d6							;Byte 2 von Ebenen 0-3
						dbra		d3,t8ipb4_byte2

						lea		-16(a0),a0
						movep.l	d5,0(a1)									;00__ 11__ 22__ 33__
						movep.l	d6,1(a1)									;__00 __11 __22 __33
						
						dbra		d2,t8ipb4_loop
						
						suba.l	a2,a0										;nÑchste Quellzeile
						suba.l	a3,a1										;nÑchste Zielzeile
						
						dbra		d1,t8ipb4_line

						rts


;Byte mit 8 signifikanten Bits in 8 Interleaved Planes umwandeln
;Vorgaben:
;Register d0-d7/a0-a5 kînnen verÑndert werden
;Eingaben:
;d0.l Breite in Pixeln - 1
;d1.l Hîhe in Zeilen - 1
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Bytes pro Quellzeile
;a3.l Bytes pro Zielzeile
;Ausgaben:
;-
t8ip8:				moveq		#16,d2
						add.w		d0,d2										;ggf. auf nÑchste 16er-Grenze aufrunden
						moveq		#$fffffff0,d0
						and.l		d2,d0
						suba.l	d0,a2										;Abstand zur nÑchsten Quellzeile
						suba.l	d0,a3										;Abstand zur nÑchsten Zielzeile
						lsr.l		#4,d0
						subq.l	#1,d0
						move.l	d0,-(sp)
												
						lea		t8ip8_tab,a4

t8ip8_line:			move.l	(sp),d0									;( Breite / 16 ) - 1


t8ip8_loop:			moveq		#7,d3										;8 Pixel einlesen und konvertieren
						moveq		#0,d4
						moveq		#0,d5

t8ip8_byte1:		moveq		#0,d2
						add.l		d4,d4
						add.l		d5,d5
						move.b	(a0)+,d2
						lsl.w		#3,d2
						lea		0(a4,d2.w),a5
						or.l		(a5)+,d4									;Byte 1 von Ebenen 0-3
						or.l		(a5)+,d5									;Byte 1 von Ebenen 4-7
						dbra		d3,t8ip8_byte1
						
						moveq		#7,d3										;8 Pixel einlesen und konvertieren
						moveq		#0,d6
						moveq		#0,d7

t8ip8_byte2:		moveq		#0,d2
						add.l		d6,d6
						add.l		d7,d7
						move.b	(a0)+,d2
						lsl.w		#3,d2
						lea		0(a4,d2.w),a5
						or.l		(a5)+,d6									;Byte 2 von Ebenen 0-3
						or.l		(a5)+,d7									;Byte 2 von Ebenen 4-7
						dbra		d3,t8ip8_byte2
						
						movep.l	d4,0(a1)									;00__ 11__ 22__ 33__
						movep.l	d6,1(a1)									;__00 __11 __22 __33
						addq.l	#8,a1
						movep.l	d5,0(a1)									;44__ 55__ 66__ 77__
						movep.l	d7,1(a1)									;__44 __55 __66 __77
						addq.l	#8,a1
						
						dbra		d0,t8ip8_loop
						
						adda.l	a2,a0										;nÑchste Quellzeile
						adda.l	a3,a1										;nÑchste Zielzeile
						
						dbra		d1,t8ip8_line
						addq.l	#4,sp										;Stack korrigieren
						rts


;Byte mit 3 signifikanten Bits in 3 aufeinanderfolgende Ebenen umwandeln
;Vorgaben:
;Register d0-d7/a0-a5 kînnen verÑndert werden
;Eingaben:
;d0.l Breite in Pixeln - 1
;d1.l Hîhe in Zeilen - 1
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Bytes pro Quellzeile
;a3.l Bytes pro Zielzeile
;Ausgaben:
;-
t8pl3:				move.l	a3,d3
						divu		#3,d3										;Breite einer Zielzeile pro Ebene
						moveq		#0,d4
						move.w	d3,d4
						lsl.l		#2,d4
						movea.l	d4,a3										;Breite einer Zielzeile mit 4 Bit pro Pixel
																				;die Umwandlung erfolgt in der Routine fÅr 4 Bit

;Byte mit 4 signifikanten Bits in 4 aufeinanderfolgende Ebenen umwandeln
;Vorgaben:
;Register d0-d7/a0-a5 kînnen verÑndert werden
;Eingaben:
;d0.l Breite in Pixeln - 1
;d1.l Hîhe in Zeilen - 1
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Bytes pro Quellzeile
;a3.l Bytes pro Zielzeile
;Ausgaben:
;-
t8pl4:				move.l	a6,-(sp)
						
						cmpa.l	a0,a1										;gleiche Bitmapadresse?
						beq.s		t8pl4_same
						
						moveq		#16,d2
						add.w		d0,d2										;ggf. auf nÑchste 16er-Grenze aufrunden
						moveq		#$fffffff0,d0
						and.l		d2,d0
						suba.l	d0,a2										;Abstand zur nÑchsten Quellzeile
						
						move.l	a3,d2
						asr.l		#2,d2
						movea.l	d2,a3										;Bytes pro Ebene einer Zielzeile
						lsr.l		#3,d0
						suba.l	d0,a3										;Abstand zur nÑchsten Zielzeile
						lsr.l		#1,d0
						subq.l	#1,d0
						move.l	d0,-(sp)
						
						move.l	d1,d3
						addq.l	#1,d3
						mulu		d3,d2										;LÑnge einer Ebene
						lea		0(a1,d2.l),a4							;Ebene 1
						lea		0(a4,d2.l),a5							;Ebene 2
						lea		0(a5,d2.l),a6							;Ebene 3
						
t8pl4_line:			move.l	(sp),d0									;( Breite / 16 ) - 1

t8pl4_loop:			moveq		#15,d3									;16 Pixel einlesen und konvertieren

t8pl4_byte:			move.b	(a0)+,d2
						lsr.w		#1,d2
						addx.w	d4,d4
						lsr.w		#1,d2
						addx.w	d5,d5
						lsr.w		#1,d2
						addx.w	d6,d6
						lsr.w		#1,d2
						addx.w	d7,d7
						dbra		d3,t8pl4_byte

						move.w	d4,(a1)+
						move.w	d5,(a4)+
						move.w	d6,(a5)+
						move.w	d7,(a6)+
						dbra		d0,t8pl4_loop
						
						adda.l	a2,a0										;nÑchste Quellzeile
						adda.l	a3,a1										;nÑchste Zielzeile, Ebene 0
						adda.l	a3,a4										;nÑchste Zielzeile, Ebene 1
						adda.l	a3,a5										;nÑchste Zielzeile, Ebene 2
						adda.l	a3,a6										;nÑchste Zielzeile, Ebene 3
						
						dbra		d1,t8pl4_line
						addq.l	#4,sp
						movea.l	(sp)+,a6
						rts

;Quell- und Zieladresse sind gleich
t8pl4_same:			movem.l	d0-d1/a0-a3,-(sp)
						
						move.l	d1,d4
						addq.l	#1,d4										;Anzahl der Zeilen
						move.l	a2,d2
						move.l	a3,d3
						mulu		d4,d2
						mulu		d4,d3
						sub.l		d3,d2
						adda.l	d2,a1
						
						bsr		t8ipb4									;in Interleaved Planes umwandeln
						movem.l	(sp)+,d0-d1/a0-a3

						move.l	d1,d4
						addq.l	#1,d4
						move.l	a2,d2
						mulu		d4,d2
						adda.l	d2,a0
						suba.l	a3,a0										;Adresse der letzten Zeile im Interleaved Plane-Format

						move.l	a3,d2										;Zielbreite wird zur Quellbreite
						move.l	a3,d3										;Zielbreite wird zur Quellbreite
						move.l	d1,d4
						asr.l		#2,d3										;Bytes pro Ebene einer Zielzeile
						mulu		d3,d4										;Abstand zur letzten Zielzeile, Ebene 0
						adda.l	d4,a1

						add.l		d3,d4										;LÑnge einer Ebene
						lea		0(a1,d4.l),a4							;letzte Zeile von Ebene 1
						lea		0(a4,d4.l),a5							;letzte Zeile von Ebene 2
						lea		0(a5,d4.l),a6							;letzte Zeile von Ebene 3

						neg.l		d2
						neg.l		d3
						movea.l	d2,a2
						movea.l	d3,a3

						moveq		#16,d2
						add.w		d0,d2										;ggf. auf nÑchste 16er-Grenze aufrunden
						moveq		#$fffffff0,d0
						and.l		d2,d0

						asr.l		#1,d0
						suba.l	d0,a2										;Abstand zur nÑchsten Quellzeile
						asr.l		#2,d0
						suba.l	d0,a3										;Abstand zur nÑchsten Zielzeile
						asr.l		#1,d0
						subq.l	#1,d0
						
t8pl4s_line:		move.w	d0,d2										;( Breite / 16 ) - 1

t8pl4s_loop:		move.w	(a0)+,(a1)+
						move.w	(a0)+,(a4)+
						move.w	(a0)+,(a5)+
						move.w	(a0)+,(a6)+
						dbra		d2,t8pl4s_loop
						
						adda.l	a2,a0										;nÑchste Quellzeile
						adda.l	a3,a1										;nÑchste Zielzeile, Ebene 0
						adda.l	a3,a4										;nÑchste Zielzeile, Ebene 1
						adda.l	a3,a5										;nÑchste Zielzeile, Ebene 2
						adda.l	a3,a6										;nÑchste Zielzeile, Ebene 3
						
						dbra		d1,t8pl4s_line
						movea.l	(sp)+,a6
						rts



;int16	transform32( int32 dx, int32 dy, int32 dst_format, void *src, void *dst, int32 src_width, int32 dst_width );
;d0.l Breite in Pixeln - 1
;d1.l Hîhe in Zeilen - 1
;d2.l Zielformat
;a0.l Quelladresse
;a1.l Zieladresse
;4(sp).l Bytes pro Quellzeile
;8(sp).l Bytes pro Zielzeile
;Ausgaben:
;d0.w
transform32:		movem.l	d3-d7/a2-a6,-(sp)						;10 Register
						movea.l	44(sp),a2
						movea.l	48(sp),a3
						
						moveq		#PX_BITS,d3
						and.w		d2,d3										;Bits pro Pixel
						subi.w	#16,d3
						cmp.w		#32-16,d3								;mehr als 32 Bit?
						bhi.s		transform32_err
 						add.w		d3,d3
						
						lea		tr32_tab(pc),a4
						btst		#PX_REVERSED_BIT,d2					;gedrehte Bytereihenfolge?
						beq.s		transform32_off						;nein
						lea		tr32i_tab(pc),a4

transform32_off:	move.w	0(a4,d3.w),d3
						beq.s		transform32_err						

 						jsr		0(a4,d3.w)

						movem.l	(sp)+,d3-d7/a2-a6
						moveq		#1,d0										;alles in Ordnung
						rts

transform32_err:	movem.l	(sp)+,d3-d7/a2-a6
						moveq		#0,d0										;Fehler: nicht unterstÅtztes Format
						rts

tr32_tab:			DC.w		t32pp16-tr32_tab						;16
						DCB.w		7,0										;17-23
						DC.w		t32pp24-tr32_tab						;24
						DCB.w		7,0										;25-31
						DC.w		t32pp32-tr32_tab						;32

tr32i_tab:			DC.w		t32pp16i-tr32i_tab					;16
						DCB.w		7,0										;17-23
						DC.w		t32pp24i-tr32i_tab					;24
						DCB.w		7,0										;25-31
						DC.w		t32pp32i-tr32i_tab					;32


;32 Bit xRGB in 16 Bit rrrr rggg gggb bbbb umwandeln
;Vorgaben:
;Register d0-d7/a0-a5 kînnen verÑndert werden
;Eingaben:
;d0.l Breite in Pixeln - 1
;d1.l Hîhe in Zeilen - 1
;d2.l Zielformat
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Bytes pro Quellzeile
;a3.l Bytes pro Zielzeile
;Ausgaben:
;-
t32pp16:				lsr.w		#8,d2
						cmp.w		#15,d2									;15 benutzte Bits?
						beq.s		t32pp15

						move.l	d0,d2
						addq.l	#1,d2
						add.l		d2,d2
						suba.l	d2,a3										;Abstand zur nÑchsten Zielzeile
						add.l		d2,d2
						suba.l	d2,a2										;Abstand zur nÑchsten Quellzeile

t32pp16_line:		move.w	d0,d2

t32pp16_loop:		move.l	(a0)+,d4
						lsr.l		#2,d4										;.... .... ..rr rrrr rrgg gggg ggbb bbbb
						lsl.b		#2,d4										;.... .... ..rr rrrr rrgg gggg bbbb bb..
						lsr.l		#1,d4										;.... .... ...r rrrr rrrg gggg gbbb bbb.
						lsl.w		#3,d4										;.... .... ...r rrrr gggg ggbb bbbb ....
						lsr.l		#5,d4										;.... .... .... .... rrrr rggg gggb bbbb
						move.w	d4,(a1)+
						dbra		d2,t32pp16_loop
						
						adda.l	a2,a0										;nÑchste Quellzeile
						adda.l	a3,a1										;nÑchste Zielzeile
						
						dbra		d1,t32pp16_line
						rts
						
;32 Bit xRGB in 16 Bit .rrr rrgg gggb bbbb umwandeln
;Vorgaben:
;Register d0-d7/a0-a5 kînnen verÑndert werden
;Eingaben:
;d0.l Breite in Pixeln - 1
;d1.l Hîhe in Zeilen - 1
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Bytes pro Quellzeile
;a3.l Bytes pro Zielzeile
;Ausgaben:
;-
t32pp15:				move.l	d0,d2
						addq.l	#1,d2
						add.l		d2,d2
						suba.l	d2,a3										;Abstand zur nÑchsten Zielzeile
						add.l		d2,d2
						suba.l	d2,a2										;Abstand zur nÑchsten Quellzeile

t32pp15_line:		move.w	d0,d2

t32pp15_loop:		move.l	(a0)+,d4
						lsr.l		#3,d4										;.... .... ...r rrrr rrrg gggg gggb bbbb
						lsl.b		#3,d4										;.... .... ...r rrrr rrrg gggg bbbb b...
						lsl.w		#3,d4										;.... .... ...r rrrr gggg gbbb bb.. ....
						lsr.l		#6,d4										;.... .... .... .... .rrr rrgg gggb bbbb
						move.w	d4,(a1)+
						dbra		d2,t32pp15_loop
						
						adda.l	a2,a0										;nÑchste Quellzeile
						adda.l	a3,a1										;nÑchste Zielzeile
						
						dbra		d1,t32pp15_line
						rts

						
;32 Bit xRGB in 24 Bit RGB umwandeln
;Vorgaben:
;Register d0-d7/a0-a5 kînnen verÑndert werden
;Eingaben:
;d0.l Breite in Pixeln - 1
;d1.l Hîhe in Zeilen - 1
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Bytes pro Quellzeile
;a3.l Bytes pro Zielzeile
;Ausgaben:
;-
t32pp24:				move.l	d0,d2
						addq.l	#1,d2
						suba.l	d2,a3
						add.l		d2,d2
						suba.l	d2,a3										;Abstand zur nÑchsten Zielzeile
						add.l		d2,d2
						suba.l	d2,a2										;Abstand zur nÑchsten Quellzeile

t32pp24_line:		move.w	d0,d2

t32pp24_loop:		move.l	(a0)+,d4
						swap		d4
						move.b	d4,(a1)+									;R
						rol.l		#8,d4
						move.b	d4,(a1)+									;G
						rol.l		#8,d4
						move.b	d4,(a1)+									;G
						dbra		d2,t32pp24_loop
						
						adda.l	a2,a0										;nÑchste Quellzeile
						adda.l	a3,a1										;nÑchste Zielzeile
						
						dbra		d1,t32pp24_line
						rts

						
;32 Bit xRGB in 32 Bit xRGB umwandeln (kopieren)
;Vorgaben:
;Register d0-d7/a0-a5 kînnen verÑndert werden
;Eingaben:
;d0.l Breite in Pixeln - 1
;d1.l Hîhe in Zeilen - 1
;d2.l Zielformat
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Bytes pro Quellzeile
;a3.l Bytes pro Zielzeile
;Ausgaben:
;-
t32pp32:				move.l	#PX_xFIRST+PX_aFIRST,d3
						and.l		d2,d3										;xRGB oder aRGB?
						beq.s		t32pp32x									;nein, RGBx oder RGBa
						
t32pp32_addr:		cmpa.l	a0,a1										;gleiche Adresse, nicht kopieren?
						beq.s		t32pp32_exit

						moveq		#4,d2
						add.w		d0,d2										;ggf. auf nÑchste 4er-Grenze aufrunden
						moveq		#$fffffffc,d0
						and.l		d2,d0
						move.l	d0,d2
						add.l		d2,d2
						add.l		d2,d2
						suba.l	d2,a2										;Abstand zur nÑchsten Quellzeile
						suba.l	d2,a3										;Abstand zur nÑchsten Zielzeile
						lsr.l		#2,d0
						subq.l	#1,d0

t32pp32_line:		move.w	d0,d2										;( Breite / 4 ) - 1

t32pp32_loop:		move.l	(a0)+,(a1)+
						move.l	(a0)+,(a1)+
						move.l	(a0)+,(a1)+
						move.l	(a0)+,(a1)+
						dbra		d2,t32pp32_loop
						
						adda.l	a2,a0										;nÑchste Quellzeile
						adda.l	a3,a1										;nÑchste Zielzeile
						
						dbra		d1,t32pp32_line
t32pp32_exit:		rts


;32 Bit xRGB in 32 Bit RGBx (verschobenes X-Byte) umwandeln
;Vorgaben:
;Register d0-d7/a0-a5 kînnen verÑndert werden
;Eingaben:
;d0.l Breite in Pixeln - 1
;d1.l Hîhe in Zeilen - 1
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Bytes pro Quellzeile
;a3.l Bytes pro Zielzeile
;Ausgaben:
;-
t32pp32x:			move.l	d0,d2
						addq.l	#1,d2
						add.l		d2,d2
						add.l		d2,d2
						suba.l	d2,a2										;Abstand zur nÑchsten Quellzeile
						suba.l	d2,a3										;Abstand zur nÑchsten Zielzeile

t32pp32x_line:		move.w	d0,d2

t32pp32x_loop:		move.l	(a0)+,d4
						rol.l		#8,d4										;RGBx
						move.l	d4,(a1)+
						dbra		d2,t32pp32x_loop
						
						adda.l	a2,a0										;nÑchste Quellzeile
						adda.l	a3,a1										;nÑchste Zielzeile
						
						dbra		d1,t32pp32x_line
						rts


;32 Bit xRGB in 16 Bit gggb bbbb rrrr rggg umwandeln
;Vorgaben:
;Register d0-d7/a0-a5 kînnen verÑndert werden
;Eingaben:
;d0.l Breite in Pixeln - 1
;d1.l Hîhe in Zeilen - 1
;d2.l Zielformat
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Bytes pro Quellzeile
;a3.l Bytes pro Zielzeile
;Ausgaben:
;-
t32pp16i:			lsr.w		#8,d2
						cmp.w		#15,d2									;15 benutzte Bits?
						beq.s		t32pp15i

						move.l	d0,d2
						addq.l	#1,d2
						add.l		d2,d2
						suba.l	d2,a3										;Abstand zur nÑchsten Zielzeile
						add.l		d2,d2
						suba.l	d2,a2										;Abstand zur nÑchsten Quellzeile

t32pp16i_line:		move.w	d0,d2

t32pp16i_loop:		move.l	(a0)+,d4
						lsr.l		#2,d4										;.... .... ..rr rrrr rrgg gggg ggbb bbbb
						lsl.b		#2,d4										;.... .... ..rr rrrr rrgg gggg bbbb bb..
						lsr.l		#1,d4										;.... .... ...r rrrr rrrg gggg gbbb bbb.
						lsl.w		#3,d4										;.... .... ...r rrrr gggg ggbb bbbb ....
						lsr.l		#5,d4										;.... .... .... .... rrrr rggg gggb bbbb
						rol.w		#8,d4										;.... .... .... .... gggb bbbb rrrr rggg
						move.w	d4,(a1)+
						dbra		d2,t32pp16i_loop
						
						adda.l	a2,a0										;nÑchste Quellzeile
						adda.l	a3,a1										;nÑchste Zielzeile
						
						dbra		d1,t32pp16i_line
						rts


;32 Bit xRGB in 16 Bit gggb bbbb .rrr rrgg umwandeln
;Vorgaben:
;Register d0-d7/a0-a5 kînnen verÑndert werden
;Eingaben:
;d0.l Breite in Pixeln - 1
;d1.l Hîhe in Zeilen - 1
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Bytes pro Quellzeile
;a3.l Bytes pro Zielzeile
;Ausgaben:
;-
t32pp15i:			move.l	d0,d2
						addq.l	#1,d2
						add.l		d2,d2
						suba.l	d2,a3										;Abstand zur nÑchsten Zielzeile
						add.l		d2,d2
						suba.l	d2,a2										;Abstand zur nÑchsten Quellzeile

t32pp15i_line:		move.w	d0,d2

t32pp15i_loop:		move.l	(a0)+,d4
						lsr.l		#3,d4										;.... .... ...r rrrr rrrg gggg gggb bbbb
						lsl.b		#3,d4										;.... .... ...r rrrr rrrg gggg bbbb b...
						lsl.w		#3,d4										;.... .... ...r rrrr gggg gbbb bb.. ....
						lsr.l		#6,d4										;.... .... .... .... .rrr rrgg gggb bbbb
						rol.w		#8,d4										;.... .... .... .... gggb bbbb .rrr rrgg
						move.w	d4,(a1)+
						dbra		d2,t32pp15i_loop
						
						adda.l	a2,a0										;nÑchste Quellzeile
						adda.l	a3,a1										;nÑchste Zielzeile
						
						dbra		d1,t32pp15i_line
						rts
						

;32 Bit xRGB in 24 Bit BGR umwandeln
;Vorgaben:
;Register d0-d7/a0-a5 kînnen verÑndert werden
;Eingaben:
;d0.l Breite in Pixeln - 1
;d1.l Hîhe in Zeilen - 1
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Bytes pro Quellzeile
;a3.l Bytes pro Zielzeile
;Ausgaben:
;-
t32pp24i:			move.l	d0,d2
						addq.l	#1,d2
						suba.l	d2,a3
						add.l		d2,d2
						suba.l	d2,a3										;Abstand zur nÑchsten Zielzeile
						add.l		d2,d2
						suba.l	d2,a2										;Abstand zur nÑchsten Quellzeile

t32pp24i_line:		move.w	d0,d2

t32pp24i_loop:		move.l	(a0)+,d4
						move.b	d4,(a1)+									;B
						lsr.w		#8,d4
						move.b	d4,(a1)+									;G
						swap		d4
						move.b	d4,(a1)+									;R
						dbra		d2,t32pp24i_loop
						
						adda.l	a2,a0										;nÑchste Quellzeile
						adda.l	a3,a1										;nÑchste Zielzeile
						
						dbra		d1,t32pp24i_line
						rts


;32 Bit xRGB in 32 Bit BGRx (gedehte Bytes) umwandeln
;Vorgaben:
;Register d0-d7/a0-a5 kînnen verÑndert werden
;Eingaben:
;d0.l Breite in Pixeln - 1
;d1.l Hîhe in Zeilen - 1
;a0.l Quelladresse
;a1.l Zieladresse
;a2.l Bytes pro Quellzeile
;a3.l Bytes pro Zielzeile
;Ausgaben:
;-
t32pp32i:			move.l	d0,d2
						addq.l	#1,d2
						add.l		d2,d2
						add.l		d2,d2
						suba.l	d2,a2										;Abstand zur nÑchsten Quellzeile
						suba.l	d2,a3										;Abstand zur nÑchsten Zielzeile

t32pp32i_line:		move.w	d0,d2

t32pp32i_loop:		move.l	(a0)+,d4
						rol.w		#8,d4										;xRBG
						swap		d4											;BGxr
						rol.w		#8,d4										;BGRx
						move.l	d4,(a1)+
						dbra		d2,t32pp32i_loop
						
						adda.l	a2,a0										;nÑchste Quellzeile
						adda.l	a3,a1										;nÑchste Zielzeile
						
						dbra		d1,t32pp32i_line
						rts

init_transform8:	bsr.s		init_ip4_tab
						bra.s		init_ip8_tab


;Tabelle fÅr 4 Inverleaved Planes aufbauen
init_ip4_tab:		moveq		#0,d0
						lea		t8ip4_tab,a0
						
init_ip4_loop:		move.w	d0,d1

						REPT		4
						moveq		#0,d2
						lsr.w		#1,d1
						addx.w	d2,d2
						move.b	d2,(a0)+
						ENDM
						
						addq.w	#1,d0
						cmpi.w	#16,d0
						blt.s		init_ip4_loop
						
						rts

;Tabelle fÅr 8 Inverleaved Planes aufbauen
init_ip8_tab:		moveq		#0,d0
						lea		t8ip8_tab,a0

init_ip8_loop:		move.w	d0,d1

						REPT		8
						moveq		#0,d2
						lsr.w		#1,d1
						addx		d2,d2
						move.b	d2,(a0)+
						ENDM
						
						addq.w	#1,d0
						cmpi.w	#256,d0
						blt.s		init_ip8_loop
						
						rts
						
						BSS

;Anmerkung:
;Wer dieses Modul unter Pure Pascal benutzen mîchte, muû die beiden Felder
;t8ip4_tab und t8ip8_tab im Pascal-Programm anlegen und die Felder
;in diesem Modul mit
;
;	IMPORT	t8ip4_tab
;	IMPORT	t8ip8_tab
;
;importieren. Die beiden folgenden Zeilen mÅssen dann gelîscht werden.

						
t8ip4_tab:			DS.l	16												;Format: %.... ...0 .... ...1 .... ...2 .... ...3
t8ip8_tab:			DS.l	2*256											;Format: %.... ...0 .... ...1 .... ...2 .... ...3
																				;			 .... ...4 .... ...5 .... ...6 .... ...7
						END
					

