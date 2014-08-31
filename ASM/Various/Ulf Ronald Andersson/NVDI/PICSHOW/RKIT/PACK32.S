;Tabulatorgr”že:	3
;Kommentare:																;ab Spalte 60

.OFFSET

																				;typedef struct																/* Farbtabelle */
																				;{
CTAB_magic:			DS.l	1												;	int32	magic;															/* 'ctab' */
CTAB_length:		DS.l	1												;	int32	length;
CTAB_format:		DS.l	1												;	int32	format;															/* Format (0) */
CTAB_reserved:		DS.l	1												;	int32	reserved;
																				;	
CTAB_map_id:		DS.l	1												;	int32	map_id;															/* Kennung der Farbtabelle */
CTAB_color_space:	DS.l	1												;	int32	color_space;													/* Farbraum */
CTAB_flags:			DS.l	1												;	int32	flags;															/* interne Flags */
CTAB_no_colors:	DS.l	1												;	int32	no_colors;														/* Anzahl der Farbeintr„ge */
																				;
CTAB_non_system_colors:	DS.l	1										;	int32	non_system_colors;
CTAB_reserved2:	DS.l	1												;	int32	reserved2;
CTAB_reserved3:	DS.l	1												;	int32	reserved3;
CTAB_reserved4:	DS.l	1												;	int32	reserved4;
																				;
CTAB_colors:																;	COLOR_ENTRY	colors[];
sizeof_CTAB:																;} COLOR_TAB;

						TEXT

						EXPORT	packed2packed32

pixel_cnt			SET	d5
tmp0_addr			SET	a5
ctab_entries		SET	a6

;int32	plane2packed32( int32 word_cnt, int32 dummy, int16 no_planes, void *src, void *dst, CTAB_REF src_ctab ); 
;Standardformat in Packed Pixel wandeln
;Vorgaben:
;Register d0-d7/a0-a6 k”nnen ver„ndert werden
;Eingaben:
;d0.l Anzahl der zu wandelnden Langworte (4 Bytes)
;d1.l L„nge einer Ebene in Bytes
;d2.w Anzahl der Ebenen des Quellrasters
;a0.l Quellraster im Standardformat
;a1.l Zielraster
;4(sp) Zeiger auf die Farbtabelle der Quelle
;Ausgaben:
;d0.w 0: Raster kann nicht gewandelt werden 1: Raster wurde gewandelt
packed2packed32:	movem.l	d3-d7/a2-a6,-(sp)

						movea.l	44(sp),ctab_entries					;Zeiger auf die Farbtabelle
						lea		CTAB_colors(ctab_entries),ctab_entries	;Zeiger auf die Farbeintr„ge

						move.l	d0,d4
						subq.l	#1,d4										;Anzahl	der Worte - 1
						move.l	d1,d6
						add.l		d6,d6
						add.l		d6,d6										;L„nge von 4 Quellebenen in Bytes

						movea.l	a1,a4										;Zeiger auf das Zielraster
						lea		(a0,d1.l),a1							;Zeiger auf Quellebene 1
						lea		(a1,d1.l),a2							;Zeiger auf Quellebene 2
						lea		(a2,d1.l),a3							;Zeiger auf Quellebene 3

						lea		not_supported(pc),tmp0_addr

						cmpi.w	#8,d2
						bhi.s		.transform

						lea		.table(pc),tmp0_addr
						add.w		d2,d2
						adda.w	0(tmp0_addr,d2.w),tmp0_addr
.transform:			jsr		(tmp0_addr)								;Wandlungsroutine aufrufen

						movem.l	(sp)+,d3-d7/a2-a6
						rts

.table:				DC.w	not_supported-.table
						DC.w	not_supported-.table						;1 Bit
						DC.w	pp_2_to_32-.table							;2 Bit
						DC.w	not_supported-.table
						DC.w	pp_4_to_32-.table							;4 Bit
						DC.w	not_supported-.table
						DC.w	not_supported-.table
						DC.w	not_supported-.table
						DC.w	pp_8_to_32-.table							;8 Bit


not_supported:		moveq		#0,d0
						rts

;1 Ebenen im Standardformat zu 1 Bit mit Packed Pixels wandeln
;Eingaben:
;d4.l Anzahl der Worte - 1
;a0.l Zeiger auf Quellebene 0
;a4.l Zeiger auf das Zielraster
;a6.l Zeiger auf die Farbtabelleneintr„ge
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
;a6.l Zeiger auf die Farbtabelleneintr„ge
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_2_to_32:
.bloop:				move.l	(a0)+,d0
						rol.l		#3,d0

						moveq		#15,pixel_cnt

.loop:				moveq		#$18,d1									;Maske
						rol.l		#2,d0
						and.l		d0,d1

						lea		2(ctab_entries,d1.l),tmp0_addr
						clr.b		(a4)+										;x
						move.b	(tmp0_addr),(a4)+						;R
						move.b	2(tmp0_addr),(a4)+					;G
						move.b	4(tmp0_addr),(a4)+					;B

						dbra		pixel_cnt,.loop

						subq.l	#1,d4
						bpl.b		.bloop
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
;a6.l Zeiger auf die Farbtabelleneintr„ge
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_4_to_32:			
.bloop:				move.l	(a0)+,d0
						rol.l		#3,d0

						moveq		#7,pixel_cnt

.loop:				moveq		#$78,d1									;Maske
						rol.l		#4,d0
						and.l		d0,d1

						lea		2(ctab_entries,d1.l),tmp0_addr
						clr.b		(a4)+										;x
						move.b	(tmp0_addr),(a4)+						;R
						move.b	2(tmp0_addr),(a4)+					;G
						move.b	4(tmp0_addr),(a4)+					;B

						dbra		pixel_cnt,.loop

						subq.l	#1,d4
						bpl.b		.bloop
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
;a6.l Zeiger auf die Farbtabelleneintr„ge
;Ausgaben:
;d0.w 1: Raster wurde gewandelt
pp_8_to_32:
.bloop:				move.l	(a0)+,d0

						moveq		#3,pixel_cnt

.loop:				moveq		#0,d1
						rol.l		#8,d0
						move.b	d0,d1

						lsl.l		#3,d1						
						lea		2(ctab_entries,d1.l),tmp0_addr
						clr.b		(a4)+										;x
						move.b	(tmp0_addr),(a4)+						;R
						move.b	2(tmp0_addr),(a4)+					;G
						move.b	4(tmp0_addr),(a4)+					;B
						
						dbra		pixel_cnt,.loop

						subq.l	#1,d4
						bpl.b		.bloop
						moveq		#1,d0										;Raster wurde gewandelt
						rts

						END
