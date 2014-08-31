;Tabulatorgr”že:	3
;Kommentare:																;ab Spalte 60

						TEXT

						EXPORT	plane2packed

;int32	plane2packed( int32 no_words, int32 plane_length, int16 no_planes, void *src, void *dst ); 
;Standardformat in Packed Pixel wandeln
;Vorgaben:
;Register d0-d7/a0-a6 k”nnen ver„ndert werden
;Eingaben:
;d0.l Anzahl der zu wandelnden Worte (pro Ebene)
;d1.l L„nge einer Ebene in Bytes
;d2.w Anzahl der Ebenen des Quellrasters
;a0.l Quellraster im Standardformat
;a1.l Zielraster
;Ausgaben:
;d0.w 0: Raster kann nicht gewandelt werden 1: Raster wurde gewandelt
plane2packed:		movem.l	d3-d7/a2-a6,-(sp)

						move.l	d0,d4
						subq.l	#1,d4										;Anzahl	der Worte - 1
						move.l	d1,d6
						add.l		d6,d6
						add.l		d6,d6										;L„nge von 4 Quellebenen in Bytes

						movea.l	a1,a4										;Zeiger auf das Zielraster
						lea		(a0,d1.l),a1							;Zeiger auf Quellebene 1
						lea		(a1,d1.l),a2							;Zeiger auf Quellebene 2
						lea		(a2,d1.l),a3							;Zeiger auf Quellebene 3

						lea		not_supported(pc),a5

						cmpi.w	#8,d2
						bhi.s		.transform

						lea		.table(pc),a5
						add.w		d2,d2
						adda.w	0(a5,d2.w),a5
.transform:			jsr		(a5)										;Wandlungsroutine aufrufen

						movem.l	(sp)+,d3-d7/a2-a6
						rts

.table:				DC.w	not_supported-.table
						DC.w	pp_1_to_1-.table							;1 Bit
						DC.w	pp_2_to_2-.table							;2 Bit
						DC.w	pp_3_to_4-.table
						DC.w	pp_4_to_4-.table							;4 Bit
						DC.w	pp_5_to_8-.table
						DC.w	pp_6_to_8-.table
						DC.w	pp_7_to_8-.table
						DC.w	pp_8_to_8-.table							;8 Bit


not_supported:		moveq		#0,d0
						rts

;1 Ebenen im Standardformat zu 1 Bit mit Packed Pixels wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;a0.l Zeiger auf Quellebene 0
;a4.l Zeiger auf das Zielraster
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_1_to_1:			move.w	(a0)+,(a4)+								;Quellebene 0
						subq.l	#1,d4
						bpl.b		pp_1_to_1
						moveq		#1,d0										;Raster wurde gewandelt
						rts


;2 Ebenen im Standardformat zu 2 Bit mit Packed Pixels wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a4.l Zeiger auf das Zielraster
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_2_to_2:			move.w	(a0)+,d0									;Quellebene 0
						move.w	(a1)+,d1									;Quellebene 1

						moveq		#15,d5
						moveq		#0,d6

pp_2_to_2_exp:		add.w		d1,d1
						addx.l	d6,d6
						add.w		d0,d0
						addx.l	d6,d6
						dbra		d5,pp_2_to_2_exp

						move.l	d6,(a4)+

						subq.l	#1,d4
						bpl.b		pp_2_to_2
						moveq		#1,d0										;Raster wurde gewandelt
						rts


;3 Ebenen im Standardformat zu 4 Bit mit Packed Pixels wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a4.l Zeiger auf das Zielraster
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_3_to_4:			move.w	(a0)+,d0									;Quellebene 0
						move.w	(a1)+,d1									;Quellebene 1
						move.w	(a2)+,d2									;Quellebene 2

						moveq		#15,d5
pp_3_to_4_exp:		moveq		#0,d6
						add.w		d2,d2
						addx.w	d6,d6
						add.w		d1,d1
						addx.w	d6,d6
						add.w		d0,d0
						addx.w	d6,d6
						btst		#0,d5										;oberes oder unteres Nibble?
						beq.b		pp_3_to_4_or
						lsl.l		#4,d6
						move.b	d6,(a4)									;oberes Nibble setzen und unteres l”schen
						bra.b		pp_3_to_4_next
pp_3_to_4_or:		or.b		d6,(a4)+									;unteres Nibble setzen und ein Byte weiter
pp_3_to_4_next:	dbra		d5,pp_3_to_4_exp

						subq.l	#1,d4
						bpl.b		pp_3_to_4
						moveq		#1,d0										;Raster wurde gewandelt
						rts

;4 Ebenen im Standardformat zu 4 Bit mit Packed Pixels wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a3.l Zeiger auf Quellebene 3
;a4.l Zeiger auf das Zielraster
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_4_to_4:			move.w	(a0)+,d0									;Quellebene 0
						move.w	(a1)+,d1									;Quellebene 1
						move.w	(a2)+,d2									;Quellebene 2
						move.w	(a3)+,d3									;Quellebene 3

						moveq		#15,d5
pp_4_to_4_exp:		moveq		#0,d6
						add.w		d3,d3
						addx.w	d6,d6
						add.w		d2,d2
						addx.w	d6,d6
						add.w		d1,d1
						addx.w	d6,d6
						add.w		d0,d0
						addx.w	d6,d6
						btst		#0,d5										;oberes oder unteres Nibble?
						beq.b		pp_4_to_4_or
						lsl.l		#4,d6
						move.b	d6,(a4)									;oberes Nibble setzen und unteres l”schen
						bra.b		pp_4_to_4_next
pp_4_to_4_or:		or.b		d6,(a4)+									;unteres Nibble setzen und ein Byte weiter
pp_4_to_4_next:	dbra		d5,pp_4_to_4_exp

						subq.l	#1,d4
						bpl.b		pp_4_to_4
						moveq		#1,d0										;Raster wurde gewandelt
						rts


;5 Ebenen im Standardformat zu 8 Bit mit Packed Pixels wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;d6.l L„nge von 4 Quellebenen in Bytes
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a3.l Zeiger auf Quellebene 3
;a4.l Zeiger auf das Zielraster
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_5_to_8:			move.l	d4,-(sp)
						move.l	d6,-(sp)

						move.w	(a0)+,d0									;Quellebene 0
						move.w	(a1)+,d1									;Quellebene 1
						move.w	(a2)+,d2									;Quellebene 2
						move.w	(a3)+,d3									;Quellebene 3
						move.w	-2(a0,d6.l),d4							;Quellebene 4

						swap		d0
						swap		d5
						move.w	#15,d5
pp_5_to_8_exp:		swap		d5
						clr.w		d0
						add.w		d4,d4
						addx.w	d0,d0
						add.w		d3,d3
						addx.w	d0,d0
						add.w		d2,d2
						addx.w	d0,d0
						add.w		d1,d1
						addx.w	d0,d0
						swap		d0
						add.w		d0,d0
						swap		d0
						addx.w	d0,d0
						move.b	d0,(a4)+
						swap		d5
						dbra		d5,pp_5_to_8_exp

						move.l	(sp)+,d6
						move.l	(sp)+,d4
						subq.l	#1,d4
						bpl.b		pp_5_to_8
						moveq		#1,d0										;Raster wurde gewandelt
						rts

;6 Ebenen im Standardformat zu 8 Bit mit Packed Pixels wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;d6.l L„nge von 4 Quellebenen in Bytes
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a3.l Zeiger auf Quellebene 3
;a4.l Zeiger auf das Zielraster
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_6_to_8:			move.l	d4,-(sp)
						move.l	d6,-(sp)

						move.w	(a0)+,d0									;Quellebene 0
						move.w	(a1)+,d1									;Quellebene 1
						move.w	(a2)+,d2									;Quellebene 2
						move.w	(a3)+,d3									;Quellebene 3
						move.w	-2(a0,d6.l),d4							;Quellebene 4
						move.w	-2(a1,d6.l),d5							;Quellebene 5

						swap		d0
						swap		d5
						move.w	#15,d5
pp_6_to_8_exp:		swap		d5
						clr.w		d0
						add.w		d5,d5
						addx.w	d0,d0
						add.w		d4,d4
						addx.w	d0,d0
						add.w		d3,d3
						addx.w	d0,d0
						add.w		d2,d2
						addx.w	d0,d0
						add.w		d1,d1
						addx.w	d0,d0
						swap		d0
						add.w		d0,d0
						swap		d0
						addx.w	d0,d0
						move.b	d0,(a4)+
						swap		d5
						dbra		d5,pp_6_to_8_exp

						move.l	(sp)+,d6
						move.l	(sp)+,d4
						subq.l	#1,d4
						bpl.b		pp_6_to_8
						moveq		#1,d0										;Raster wurde gewandelt
						rts

;7 Ebenen im Standardformat zu 8 Bit mit Packed Pixels wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;d6.l L„nge von 4 Quellebenen in Bytes
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a3.l Zeiger auf Quellebene 3
;a4.l Zeiger auf das Zielraster
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_7_to_8:			move.l	d4,-(sp)
						move.l	d6,-(sp)

						move.w	(a0)+,d0									;Quellebene 0
						move.w	(a1)+,d1									;Quellebene 1
						move.w	(a2)+,d2									;Quellebene 2
						move.w	(a3)+,d3									;Quellebene 3
						move.w	-2(a0,d6.l),d4							;Quellebene 4
						move.w	-2(a1,d6.l),d5							;Quellebene 5
						move.w	-2(a2,d6.l),d6							;Quellebene 6

						swap		d0
						swap		d5
						move.w	#15,d5
pp_7_to_8_exp:		swap		d5
						clr.w		d0
						add.w		d6,d6
						addx.w	d0,d0
						add.w		d5,d5
						addx.w	d0,d0
						add.w		d4,d4
						addx.w	d0,d0
						add.w		d3,d3
						addx.w	d0,d0
						add.w		d2,d2
						addx.w	d0,d0
						add.w		d1,d1
						addx.w	d0,d0
						swap		d0
						add.w		d0,d0
						swap		d0
						addx.w	d0,d0
						move.b	d0,(a4)+
						swap		d5
						dbra		d5,pp_7_to_8_exp

						move.l	(sp)+,d6
						move.l	(sp)+,d4
						subq.l	#1,d4
						bpl.b		pp_7_to_8
						moveq		#1,d0										;Raster wurde gewandelt
						rts

;8 Ebenen im Standardformat zu 8 Bit mit Packed Pixels wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;d6.l L„nge von 4 Quellebenen in Bytes
;a0.l Zeiger auf Quellebene 0
;a1.l Zeiger auf Quellebene 1
;a2.l Zeiger auf Quellebene 2
;a3.l Zeiger auf Quellebene 3
;a4.l Zeiger auf das Zielraster
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_8_to_8:			move.l	d4,-(sp)
						move.l	d6,-(sp)

						move.w	(a0)+,d0									;Quellebene 0
						move.w	(a1)+,d1									;Quellebene 1
						move.w	(a2)+,d2									;Quellebene 2
						move.w	(a3)+,d3									;Quellebene 3
						move.w	-2(a0,d6.l),d4							;Quellebene 4
						move.w	-2(a1,d6.l),d5							;Quellebene 5
						move.w	-2(a3,d6.l),d7							;Quellebene 7
						move.w	-2(a2,d6.l),d6							;Quellebene 6

						swap		d0
						swap		d5
						move.w	#15,d5
pp_8_to_8_exp:		swap		d5
						clr.w		d0
						add.w		d7,d7
						addx.w	d0,d0
						add.w		d6,d6
						addx.w	d0,d0
						add.w		d5,d5
						addx.w	d0,d0
						add.w		d4,d4
						addx.w	d0,d0
						add.w		d3,d3
						addx.w	d0,d0
						add.w		d2,d2
						addx.w	d0,d0
						add.w		d1,d1
						addx.w	d0,d0
						swap		d0
						add.w		d0,d0
						swap		d0
						addx.w	d0,d0
						move.b	d0,(a4)+
						swap		d5
						dbra		d5,pp_8_to_8_exp

						move.l	(sp)+,d6
						move.l	(sp)+,d4
						subq.l	#1,d4
						bpl.b		pp_8_to_8
						moveq		#1,d0										;Raster wurde gewandelt
						rts

						END
