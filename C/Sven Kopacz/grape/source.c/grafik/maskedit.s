; MASKPEN
; StiftflÑche in Maskenebene kopieren unter berÅcksichtigung einer Maske

		.MC68030

.EXPORT mask_edit_it
		
.IMPORT mask_paint_it

.IMPORT	p_red, p_yellow, p_blue, p_screen, p_width
.IMPORT c_red, c_yellow, c_blue, c_mask, c_lasur, c_add
.IMPORT c_qopt, c_plusminus, c_solo, c_layers
.IMPORT	pen_r, pen_g, pen_b
.IMPORT start_x, rel_start_x, start_y, rel_start_y, end_x, end_y
.IMPORT r_table, g_table, b_table
.IMPORT paint_it, intensity, pen_width, screen_width
.IMPORT r_dither_table, g_dither_table, b_dither_table
.IMPORT d_dither
.IMPORT	table_offset, screen_offset
.IMPORT undo_start, undo_end, undo_buf, undo_maxend
.IMPORT undo_ok, undo_on, undo_id
.IMPORT red_list, yellow_list, blue_list, type_list
.IMPORT test1, test2
.IMPORT mul_tab, div_tab, mul_adr
.IMPORT typ0_dither_pre
.IMPORT p_mask, mask_activ, p_edmask, mask_edit

.IMPORT scr_buf,ydif_buf,xdif_buf,x_acht_buf,x_acht_buf2,x_rest_buf
.IMPORT x_addacht_buf,planedif_buf,planeachtdif_buf,pendif_buf
.IMPORT penachtdif_buf,x_count_buf,y_count_buf,buffer,zen,savreg
.IMPORT sav_sp,dif_y,dif_x,add_screen
.IMPORT temp_red,temp_yellow,temp_blue,temp_line
.IMPORT temp_r,temp_g,temp_b,t_col
.IMPORT curr_y,curr_x
.IMPORT undo_width,undo_size

mask_edit_it:
		movem.l	d0-d7/a0-a6,-(sp)
		tst.b		undo_ok
		beq			init
		tst.b		undo_on
		beq			init
;Undo Init:
		move.w	#10,undo_size
		move.l	undo_end,a0
		move.w	undo_id,(a0)+		;Layer in UndoPuffer schreiben
		move.w	start_x,(a0)+
		move.w	start_y,(a0)+
		move.w	end_x,d0
		sub.w		start_x,d0
		addq.w	#1,d0
		move.w	d0,(a0)+
;		mulu.w	#3,d0					;Mal drei, wegen RGB-Bytes ! entfÑllt !
		move.w	d0,undo_width
		tst.b		undo_ok
		bne			ok_h
		move.w	#0,undo_width	;undo_width lîschen fÅr schnelle Erkennung ob an oder aus
ok_h:
		move.w	end_y,d0
		sub.w		start_y,d0
		addq.w	#1,d0
		move.w	d0,(a0)+
		move.l	a0,undo_end
		
;Planes
init:
		move.l	p_edmask,a0
;Pen-Frames
		move.l	pen_r, a4
		
		
		sub.l		d0,d0		;Zeilen-ZÑhler
		sub.l		d1,d1		;Spalten-ZÑhler
		sub.l		d2,d2		;Planes Zeilendiff
		sub.l		d3,d3		;Pen Zeilendiff
		move.l	p_screen,d6		;Offset fÅr Screen

		
		move.w	start_y, curr_y
;Aus sy und ey Differenz bilden:
		move.w	end_y,d0
		sub.w		start_y,d0
		move.l	d0,dif_y
;Aus sx und ey Differenz bilden:
		move.w	end_x,d0
		sub.w		start_x,d0
		move.l	d0,dif_x
;Zu addierende Zeilendifferenz berechnen
		move.l	p_width,d0
		sub.l		dif_x,d0
		sub.l		#1,d0
		move.l	d0,d2
		move.l	d2,planedif_buf
		move.l	d2,planeachtdif_buf
;und fÅr Pinsel
		move.l	pen_width,d0
		sub.l		dif_x,d0
		sub.l		#1,d0
		move.l	d0,d3
		move.l	d3,pendif_buf
		move.l	d3,penachtdif_buf
;und fÅr Screen
		move.l	screen_width,d0
		sub.l		dif_x,d0
		sub.l		#1,d0
		move.l	d0,add_screen

		move.l	p_width,d1		
		move.l	screen_width,d4

;Startzeilenoffset holen
		sub.l		d0,d0							;Leeren
		move.l	table_offset,a3		;Tabellenadresse
		move.w	start_y,d0				;Offset-Zeilen
		lsl.l		#2,d0							;Mal vier wegen Langwort-Tabelle
		move.l	0(a3,d0.l),d1			;Summe holen
		adda.l	d1,a0							;und Åberall aufrechnen
		
		sub.l		d0,d0
		lea			screen_offset,a3	;Tabellenadresse
		move.w	rel_start_y,d0		;Offset-Zeilen auf Screen
		lsl.l		#2,d0							;Mal vier wegen Langwort-Tabelle
		move.l	0(a3,d0.l),d1
		add.l		d1,d6

		sub.l		d0,d0
		move.w	start_x,d0
		adda.l	d0,a0
		move.w	rel_start_x,d0
		add.l		d0,d6

		move.l	d6,scr_buf
		move.l	dif_x,d0
		addq.l	#1,d0
		move.l	d0,d1
		andi.l	#7,d0						;8-er Rest
		move.l	d0,x_rest_buf
		add.l		d0,planeachtdif_buf
		add.l		d0,penachtdif_buf
		lsr.l		#3,d1						; durch 8
		move.l	d1,x_acht_buf
		lsl.l		#3,d1
		move.l	d1,x_addacht_buf	;Anteil der fÅr Zeilenoffset im < 8-Teil addiert werden muû
		move.l	dif_y,d0

; ***************
; Undo
; ***************

		tst.b		undo_ok
		beq			end_undo
		tst.b		undo_on
		beq			end_undo

		movem.l	d0/a0,-(sp)
		
		move.w	undo_width,d4
		move.w	undo_size,d5
		move.l	undo_end,a3


u_byploop:
		move.l	dif_x,d1
u_bxploop:
;Undo
		move.b	(a0)+,(a3)+
;X-Schleife
		dbra		d1,u_bxploop
;Y-Schleife		
		adda.l	d2,a0
		add.w		d4,d5
		dbra		d0,u_byploop
;Fertig
		move.l	a3,undo_end
		move.w	d5,undo_size

		addq.w	#4,undo_size	;Undopuffer beenden
		move.l	undo_end,a0
		move.w	#0,(a0)+
		move.w	undo_size,(a0)
		addq.l	#4,undo_end
		
		movem.l	(sp)+,d0/a0
end_undo:

		tst.w		c_plusminus	;Aufhellen oder Abdunkeln?
		bne			plu_min			;Ja->AusfÅhren
		
		tst.b		c_lasur		;Lasur zeichnen?
		beq			opaque		;Nein->andere Routine




; ***************
; LASUR FLOW
; ***************



		tst.b		c_add				;Addierend zeichnen?
		beq			las_no_add	;Nein->normale Lasur

;Lasur FLOW

; ** MASK **


;Anteil < 8
		move.l	x_rest_buf,d4
		beq			aend_red
		subq.l	#1,d4
		move.l	d4,x_count_buf
		movem.l	d0-d3/a0-a6,-(sp)
		add.l		x_addacht_buf,d2
		add.l		x_addacht_buf,d3
		
		lea			div_tab,a1			;Divisions-Tabelle (x/255) in a1

		lea			mul_adr,a2			;Adressen der x*y-Tabellen
														;fÅr 255-x

		lea			mul_tab,a3					;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_mask,d5				;Zeichenfarbe
		lsl.l		#8,d5						;mul*255-Tabelle fÅr diese Farbe
		lsl.l		#1,d5						;berechnen
		adda.l	d5,a3						;und in a3

ar_byploop:
		move.l	x_count_buf,d1
ar_bxploop:

		moveq.l	#0,d4
		moveq.l	#0,d5
		move.b	(a4)+,d4				;IntensitÑt
		move.w	0(a3,d4*2.w),d5	;Mit Farbwert multipliziert
		move.l	0(a2,d4*4.l),a5	;Tabelle fÅr (255-IntensitÑt)

		moveq		#0,d4
		move.b	(a0),d4					;Planewert holen
		move.w	0(a5,d4*2.w),d4	;mit (255-IntensitÑt) multiplizieren
		add.w		d5,d4						;Addieren
		move.b	0(a1,d4.l),d5		;Endwert holen
		cmp.b		(a0)+,d5					;Mit Plane vergleichen
		bls			ar_las_0				;Zu groû->
		move.b	d5,-1(a0)					;Sonst Quotient (/255) in vorhandenes Byte schreiben
ar_las_0:
		dbra		d1,ar_bxploop
		
		adda.l	d2,a0						;Zeilenoffset fÅr Plane
		adda.l	d3,a4						;Zeilenoffset fÅr Pinsel
		dbra		d0,ar_byploop
;end_red < 8
		movem.l	(sp)+,d0-d3/a0-a6
aend_red:
		
; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			aend_red2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a0-a6,-(sp)

		move.l	d0,y_count_buf

		lea			div_tab,a1			;Divisions-Tabelle (x/255) in a1

		lea			mul_adr,a2			;Adressen der x*y-Tabellen
														;fÅr 255-x

		lea			mul_tab,a3					;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_mask,d5				;Zeichenfarbe
		lsl.l		#8,d5						;mul*255-Tabelle fÅr diese Farbe
		lsl.l		#1,d5						;berechnen
		adda.l	d5,a3						;und in a3

		add.l		x_rest_buf,a4
		add.l		x_rest_buf,a0

ar2_byploop:
		move.l	x_acht_buf2,x_count_buf
ar2_bxploop:
		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		moveq.l	#0,d4
		moveq.l	#0,d5
		moveq.l	#0,d6
		moveq.l	#0,d7

		move.b	(a4)+,d0				;IntensitÑten holen
		move.b	(a4)+,d1				;IntensitÑten holen
		move.b	(a4)+,d2				;IntensitÑten holen
		move.b	(a4)+,d3				;IntensitÑten holen
		move.b	(a4)+,d4				;IntensitÑten holen
		move.b	(a4)+,d5				;IntensitÑten holen
		move.b	(a4)+,d6				;IntensitÑten holen

.MACRO FLOW_LAS_R dn
.LOCAL	ar_las_00
		move.w	0(a3,dn*2.w),d7	;Mit Farbwert multipliziert
		move.l	0(a2,dn*4.l),a5	;Tabelle fÅr (255-IntensitÑt)
		moveq		#0,dn
		move.b	(a0),dn					;Planewert holen
		move.w	0(a5,dn*2.w),dn	;mit (255-IntensitÑt) multiplizieren
		add.w		d7,dn						;Addieren
		move.b	0(a1,dn.l),d7		;Endwert holen
		cmp.b		(a0)+,d7				;Mit Plane vergleichen
		bls			ar_las_00				;Zu groû->
		move.b	d7,-1(a0)				;Sonst Quotient (/255) in vorhandenes Byte schreiben
ar_las_00:
.ENDM

		FLOW_LAS_R d0
		FLOW_LAS_R d1
		FLOW_LAS_R d2
		FLOW_LAS_R d3
		FLOW_LAS_R d4
		FLOW_LAS_R d5
		FLOW_LAS_R d6
;und achten Wert:
		moveq		#0,d6
		move.b	(a4)+,d6
		FLOW_LAS_R d6


		subq.l	#1,x_count_buf
		bpl			ar2_bxploop
		
		add.l		planeachtdif_buf,a0		;Zeilenoffset fÅr Plane
		add.l		penachtdif_buf,a4			;Zeilenoffset fÅr Pinsel
		subq.l	#1,y_count_buf
		bpl			ar2_byploop
;end_red > 8
		movem.l	(sp)+,d0-d3/a0-a6
aend_red2:
		bra			d_dither



;**********************
; LASUR NORMAL
;**********************



las_no_add:
;Lasur nicht addierend

; ** ROT **

		moveq.l	#0,d4
		lea			intensity,a3		;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_mask,d5				;Zeichenfarbe
		lsl.w		#8,d5						;Tabelle fÅr diese Farbe
		adda.l	d5,a3						;berechnen

;Anteil < 8
		move.l	x_rest_buf,d4
		beq			end_red
		subq.l	#1,d4
		move.l	d4,x_count_buf
		movem.l	d0-d3,-(sp)
		move.l	a0,-(sp)
		move.l	a4,-(sp)
		
		add.l		x_addacht_buf,d2
		add.l		x_addacht_buf,d3
		
r_byploop:
		move.l	x_count_buf,d1
r_bxploop:
		move.b	(a4)+,d4				;Pinseldurchlaû
		move.b	0(a3,d4.l),d4		;Farbwert holen
		cmp.b		(a0)+,d4					;Farbwert zu groû?
		bls			las_0
		move.b	d4,-1(a0)					;In vorhandenes Byte schreiben
las_0:
		dbra		d1,r_bxploop
		
		adda.l	d2,a0						;Zeilenoffset fÅr Plane
		adda.l	d3,a4						;Zeilenoffset fÅr Pinsel
		dbra		d0,r_byploop
;end_red < 8
		move.l	(sp)+,a4
		move.l	(sp)+,a0
		movem.l	(sp)+,d0-d3
end_red:
		
; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			end_red2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a0,-(sp)

		move.l	d0,y_count_buf
		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		moveq.l	#0,d4
		moveq.l	#0,d5
		moveq.l	#0,d6
		moveq.l	#0,d7
		add.l		x_rest_buf,a4
		add.l		x_rest_buf,a0

r2_byploop:
		move.l	x_acht_buf2,x_count_buf
r2_bxploop:
		move.b	(a4)+,d0				;Pinseldurchlaû
		move.b	(a4)+,d1
		move.b	(a4)+,d2
		move.b	(a4)+,d3
		move.b	(a4)+,d4
		move.b	(a4)+,d5
		move.b	(a4)+,d6
		move.b	(a4)+,d7

		move.b	0(a3,d0.w),d0		;Farbwert holen
		move.b	0(a3,d1.w),d1
		move.b	0(a3,d2.w),d2
		move.b	0(a3,d3.w),d3
		move.b	0(a3,d4.w),d4
		move.b	0(a3,d5.w),d5
		move.b	0(a3,d6.w),d6
		move.b	0(a3,d7.w),d7

.MACRO M_LAS_R_NORM dn
.LOCAL las_r2_0
		cmp.b		(a0)+,dn					;Farbwert zu groû?
		bls			las_r2_0
		move.b	dn,-1(a0)					;In vorhandenes Byte schreiben
las_r2_0:
.ENDM

		M_LAS_R_NORM d0
		M_LAS_R_NORM d1
		M_LAS_R_NORM d2
		M_LAS_R_NORM d3
		M_LAS_R_NORM d4
		M_LAS_R_NORM d5
		M_LAS_R_NORM d6
		M_LAS_R_NORM d7


		subq.l	#1,x_count_buf
		bpl			r2_bxploop
		
		add.l		planeachtdif_buf,a0		;Zeilenoffset fÅr Plane
		add.l		penachtdif_buf,a4			;Zeilenoffset fÅr Pinsel
		subq.l	#1,y_count_buf
		bpl			r2_byploop
;end_red > 8
		movem.l	(sp)+,d0-d3/a0
end_red2:
		bra			d_dither



; *************
; OPAQUE
; *************


opaque:

		tst.w		c_add				;Addierend?
		beq			op_no_add		;Nein->normal deckend

;Deckend addierend (OPAQUE FLOW)

; ** ROT **


;Anteil < 8
		move.l	x_rest_buf,d4
		beq			oaend_red
		subq.l	#1,d4
		move.l	d4,x_count_buf
		movem.l	d0-d3/a0-a6,-(sp)
		add.l		x_addacht_buf,d2
		add.l		x_addacht_buf,d3
		
		lea			div_tab,a1			;Divisions-Tabelle (x/255) in a1

		lea			mul_adr,a2			;Adressen der x*y-Tabellen
														;fÅr 255-x

		lea			mul_tab,a3					;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_mask,d5				;Zeichenfarbe
		lsl.l		#8,d5						;mul*255-Tabelle fÅr diese Farbe
		lsl.l		#1,d5						;berechnen
		adda.l	d5,a3						;und in a3

oar_byploop:
		move.l	x_count_buf,d1
oar_bxploop:

		moveq.l	#0,d4
		moveq.l	#0,d5
		move.b	(a4)+,d4				;IntensitÑt
		move.w	0(a3,d4*2.w),d5	;Mit Farbwert multipliziert
		move.l	0(a2,d4*4.l),a5	;Tabelle fÅr (255-IntensitÑt)

		moveq		#0,d4
		move.b	(a0),d4					;Planewert holen
		move.w	0(a5,d4*2.w),d4	;mit (255-IntensitÑt) multiplizieren
		add.w		d5,d4						;Addieren
		move.b	0(a1,d4.l),(a0)+;Quotient (/255) in vorhandenes Byte schreiben

		dbra		d1,oar_bxploop
		
		adda.l	d2,a0						;Zeilenoffset fÅr Plane
		adda.l	d3,a4						;Zeilenoffset fÅr Pinsel
		dbra		d0,oar_byploop
;end_red < 8
		movem.l	(sp)+,d0-d3/a0-a6
oaend_red:
		
; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			oaend_red2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a0-a6,-(sp)

		move.l	d0,y_count_buf

		lea			div_tab,a1			;Divisions-Tabelle (x/255) in a1

		lea			mul_adr,a2			;Adressen der x*y-Tabellen
														;fÅr 255-x

		lea			mul_tab,a3					;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_mask,d5				;Zeichenfarbe
		lsl.l		#8,d5						;mul*255-Tabelle fÅr diese Farbe
		lsl.l		#1,d5						;berechnen
		adda.l	d5,a3						;und in a3

		add.l		x_rest_buf,a4
		add.l		x_rest_buf,a0
		
oar2_byploop:
		move.l	x_acht_buf2,x_count_buf
oar2_bxploop:
		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		moveq.l	#0,d4
		moveq.l	#0,d5
		moveq.l	#0,d6
		moveq.l	#0,d7

		move.b	(a4)+,d0				;IntensitÑten holen
		move.b	(a4)+,d1				;IntensitÑten holen
		move.b	(a4)+,d2				;IntensitÑten holen
		move.b	(a4)+,d3				;IntensitÑten holen

		move.b	(a4)+,d4				;IntensitÑten holen
		move.b	(a4)+,d5				;IntensitÑten holen
		move.b	(a4)+,d6				;IntensitÑten holen

.MACRO FLOW_OPQ_R dn
		move.w	0(a3,dn*2.w),d7	;Mit Farbwert multipliziert
		move.l	0(a2,dn*4.l),a5	;Tabelle fÅr (255-IntensitÑt)
		moveq		#0,dn
		move.b	(a0),dn					;Planewert holen
		move.w	0(a5,dn*2.w),dn	;mit (255-IntensitÑt) multiplizieren
		add.w		d7,dn						;Addieren
		move.b	0(a1,dn.l),(a0)+;Quotient (/255) in vorhandenes Byte schreiben
.ENDM

		FLOW_OPQ_R d0
		FLOW_OPQ_R d1
		FLOW_OPQ_R d2
		FLOW_OPQ_R d3
		FLOW_OPQ_R d4
		FLOW_OPQ_R d5
		FLOW_OPQ_R d6
;und achten Wert:
		moveq		#0,d6
		move.b	(a4)+,d6
		FLOW_OPQ_R d6


		subq.l	#1,x_count_buf
		bpl			oar2_bxploop
		
		add.l		planeachtdif_buf,a0		;Zeilenoffset fÅr Plane
		add.l		penachtdif_buf,a4			;Zeilenoffset fÅr Pinsel
		subq.l	#1,y_count_buf
		bpl			oar2_byploop
;end_red > 8
		movem.l	(sp)+,d0-d3/a0-a6
oaend_red2:
		bra			d_dither




;*****************
;OPAQUE NORMAL
;*****************



op_no_add:
		tst.w		c_qopt
		bne			q_opaque
;Normal deckend zeichnen

; ** ROT **

		moveq.l	#0,d4
		lea			intensity,a3		;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_mask,d5				;Zeichenfarbe
		lsl.w		#8,d5						;Tabelle fÅr diese Farbe
		adda.l	d5,a3						;berechnen

;Anteil < 8
		move.l	x_rest_buf,d4
		beq			qoend_red
		subq.l	#1,d4
		move.l	d4,x_count_buf
		movem.l	d0-d3,-(sp)
		move.l	a0,-(sp)
		move.l	a4,-(sp)
		
		add.l		x_addacht_buf,d2
		add.l		x_addacht_buf,d3
		
qor_byploop:
		move.l	x_count_buf,d1
qor_bxploop:
		move.b	(a4)+,d4				;Pinseldurchlaû
		beq			next_ored				;Kein Durchlaû->Nix machen
		move.b	0(a3,d4.l),(a0)	;Farbwert holen & schreiben
next_ored:
		addq.l	#1,a0
		dbra		d1,qor_bxploop
		
		adda.l	d2,a0						;Zeilenoffset fÅr Plane
		adda.l	d3,a4						;Zeilenoffset fÅr Pinsel
		dbra		d0,qor_byploop
;end_red < 8
		move.l	(sp)+,a4
		move.l	(sp)+,a0
		movem.l	(sp)+,d0-d3
qoend_red:
		
; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			qoend_red2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a0,-(sp)
		
		move.l	d0,y_count_buf
		moveq.l	#0,d0
		add.l		x_rest_buf,a4
		add.l		x_rest_buf,a0
		
qor2_byploop:
		move.l	x_acht_buf2,x_count_buf
qor2_bxploop:

.MACRO	q_opaq_r
.LOCAL	quor_r
		move.b	(a4)+,d0				;Pinseldurchlaû
		beq			quor_r
		move.b	0(a3,d0.w),(a0)	;Farbwert holen
quor_r:
		addq.l	#1,a0
.ENDM		

		q_opaq_r
		q_opaq_r
		q_opaq_r
		q_opaq_r
		q_opaq_r
		q_opaq_r
		q_opaq_r
		q_opaq_r
		
		subq.l	#1,x_count_buf
		bpl			qor2_bxploop
		
		add.l		planeachtdif_buf,a0		;Zeilenoffset fÅr Plane
		add.l		penachtdif_buf,a4			;Zeilenoffset fÅr Pinsel
		subq.l	#1,y_count_buf
		bpl			qor2_byploop
;end_red > 8
		movem.l	(sp)+,d0-d3/a0
qoend_red2:
		bra			d_dither
	

;******************
;OPAQUE Q-OPTIMIERT
;******************

q_opaque:
;FÅr quadratische Pinsel optimiert
;Einfach Åberschreiben

; ** ROT **

		moveq.l	#0,d4
		lea			intensity,a3		;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_mask,d5				;Zeichenfarbe
		lsl.w		#8,d5						;Tabelle fÅr diese Farbe
		adda.l	d5,a3						;berechnen

;Anteil < 8
		move.l	x_rest_buf,d4
		beq			oend_red
		subq.l	#1,d4
		move.l	d4,x_count_buf
		movem.l	d0-d3,-(sp)
		move.l	a0,-(sp)
		move.l	a4,-(sp)
		
		add.l		x_addacht_buf,d2
		add.l		x_addacht_buf,d3
		
or_byploop:
		move.l	x_count_buf,d1
or_bxploop:
		move.b	(a4)+,d4				;Pinseldurchlaû
		move.b	0(a3,d4.l),(a0)+;Farbwert holen & schreiben
		dbra		d1,or_bxploop
		
		adda.l	d2,a0						;Zeilenoffset fÅr Plane
		adda.l	d3,a4						;Zeilenoffset fÅr Pinsel
		dbra		d0,or_byploop
;end_red < 8
		move.l	(sp)+,a4
		move.l	(sp)+,a0
		movem.l	(sp)+,d0-d3
oend_red:
		
; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			oend_red2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a0,-(sp)

		move.l	d0,y_count_buf
		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		moveq.l	#0,d4
		moveq.l	#0,d5
		moveq.l	#0,d6
		moveq.l	#0,d7
		add.l		x_rest_buf,a4
		add.l		x_rest_buf,a0
		
or2_byploop:
		move.l	x_acht_buf2,x_count_buf
or2_bxploop:
		move.b	(a4)+,d0				;Pinseldurchlaû
		move.b	(a4)+,d1
		move.b	(a4)+,d2
		move.b	(a4)+,d3
		move.b	(a4)+,d4
		move.b	(a4)+,d5
		move.b	(a4)+,d6
		move.b	(a4)+,d7
		
		move.b	0(a3,d0.w),(a0)+		;Farbwert holen & schreiben
		move.b	0(a3,d1.w),(a0)+
		move.b	0(a3,d2.w),(a0)+
		move.b	0(a3,d3.w),(a0)+
		move.b	0(a3,d4.w),(a0)+
		move.b	0(a3,d5.w),(a0)+
		move.b	0(a3,d6.w),(a0)+
		move.b	0(a3,d7.w),(a0)+

		subq.l	#1,x_count_buf
		bpl			or2_bxploop
		
		add.l		planeachtdif_buf,a0		;Zeilenoffset fÅr Plane
		add.l		penachtdif_buf,a4			;Zeilenoffset fÅr Pinsel
		subq.l	#1,y_count_buf
		bpl			or2_byploop
;end_red > 8
		movem.l	(sp)+,d0-d3/a0
oend_red2:
		bra			d_dither



;*****************
;ADD/SUB
;*****************
;Aufhellen und abdunkeln
plu_min:

		cmp.w		#2,c_plusminus	;ADD?
		bne			pm_sub					;Nein->SUB


;*************
;Abdunkeln
;*************
; ** ROT **

		moveq.l	#0,d4
		lea			intensity,a3		;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_mask,d5				;Zeichenfarbe
		lsl.w		#8,d5						;Tabelle fÅr diese Farbe
		adda.l	d5,a3						;berechnen

;Anteil < 8
		move.l	x_rest_buf,d4
		beq			adend_red
		subq.l	#1,d4
		move.l	d4,x_count_buf
		movem.l	d0-d3,-(sp)
		move.l	a0,-(sp)
		move.l	a4,-(sp)
		
		add.l		x_addacht_buf,d2
		add.l		x_addacht_buf,d3
		
adr_byploop:
		move.l	x_count_buf,d1
adr_bxploop:
		move.b	(a4)+,d4					;Pinseldurchlaû
		move.b	0(a3,d4.l),d4			;Farbwert holen
		add.b		d4,(a0)+						;& addieren
		bcc			next_adred				;Bei öberlauf..
		move.b	#255,-1(a0)					;..Maximalwert schreiben
next_adred:
		dbra		d1,adr_bxploop
		
		adda.l	d2,a0						;Zeilenoffset fÅr Plane
		adda.l	d3,a4						;Zeilenoffset fÅr Pinsel
		dbra		d0,adr_byploop
;end_red < 8
		move.l	(sp)+,a4
		move.l	(sp)+,a0
		movem.l	(sp)+,d0-d3
adend_red:
		
; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			adend_red2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a0,-(sp)
		
		move.l	d0,y_count_buf
		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		moveq.l	#0,d4
		moveq.l	#0,d5
		moveq.l	#0,d6
		moveq.l	#0,d7
		add.l		x_rest_buf,a4
		add.l		x_rest_buf,a0
		
adr2_byploop:
		move.l	x_acht_buf2,x_count_buf
adr2_bxploop:

		move.b	(a4)+,d0				;Pinseldurchlaû
		move.b	(a4)+,d1				
		move.b	(a4)+,d2				
		move.b	(a4)+,d3				
		move.b	(a4)+,d4				
		move.b	(a4)+,d5				
		move.b	(a4)+,d6				
		move.b	(a4)+,d7				

		move.b	0(a3,d0.w),d0		;Farbwert holen
		move.b	0(a3,d1.w),d1
		move.b	0(a3,d2.w),d2
		move.b	0(a3,d3.w),d3
		move.b	0(a3,d4.w),d4
		move.b	0(a3,d5.w),d5
		move.b	0(a3,d6.w),d6
		move.b	0(a3,d7.w),d7

.MACRO	ad_r_8	dn
.LOCAL	ad_r_0
		add.b		dn,(a0)+				;Farbwert addieren
		bcc			ad_r_0					;Falls öberlauf..
		move.b	#255,-1(a0)			;..Maxwert setzen
ad_r_0:

.ENDM		

		ad_r_8	d0
		ad_r_8	d1
		ad_r_8	d2
		ad_r_8	d3
		ad_r_8	d4
		ad_r_8	d5
		ad_r_8	d6
		ad_r_8	d7
		
		subq.l	#1,x_count_buf
		bpl			adr2_bxploop
		
		add.l		planeachtdif_buf,a0		;Zeilenoffset fÅr Plane
		add.l		penachtdif_buf,a4			;Zeilenoffset fÅr Pinsel
		subq.l	#1,y_count_buf
		bpl			adr2_byploop
;end_red > 8
		movem.l	(sp)+,d0-d3/a0
adend_red2:
		bra			d_dither
	



;*************
;Aufhellen
;*************



pm_sub:
; ** ROT **

		moveq.l	#0,d4
		lea			intensity,a3		;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_mask,d5				;Zeichenfarbe
		lsl.w		#8,d5						;Tabelle fÅr diese Farbe
		adda.l	d5,a3						;berechnen

;Anteil < 8
		move.l	x_rest_buf,d4
		beq			sbend_red
		subq.l	#1,d4
		move.l	d4,x_count_buf
		movem.l	d0-d3,-(sp)
		move.l	a0,-(sp)
		move.l	a4,-(sp)
		
		add.l		x_addacht_buf,d2
		add.l		x_addacht_buf,d3
		
sbr_byploop:
		move.l	x_count_buf,d1
sbr_bxploop:
		move.b	(a4)+,d4					;Pinseldurchlaû
		move.b	0(a3,d4.l),d4			;Farbwert holen
		sub.b		d4,(a0)+					;& abziehen
		bcc			next_sbred				;Bei öberlauf..
		move.b	#0,-1(a0)					;..Minimalwert schreiben
next_sbred:
		dbra		d1,sbr_bxploop
		
		adda.l	d2,a0						;Zeilenoffset fÅr Plane
		adda.l	d3,a4						;Zeilenoffset fÅr Pinsel
		dbra		d0,sbr_byploop
;end_red < 8
		move.l	(sp)+,a4
		move.l	(sp)+,a0
		movem.l	(sp)+,d0-d3
sbend_red:
		
; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			sbend_red2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a0,-(sp)

		move.l	d0,y_count_buf
		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		moveq.l	#0,d4
		moveq.l	#0,d5
		moveq.l	#0,d6
		moveq.l	#0,d7
		add.l		x_rest_buf,a4
		add.l		x_rest_buf,a0
		
sbr2_byploop:
		move.l	x_acht_buf2,x_count_buf
sbr2_bxploop:

		move.b	(a4)+,d0				;Pinseldurchlaû
		move.b	(a4)+,d1				
		move.b	(a4)+,d2				
		move.b	(a4)+,d3				
		move.b	(a4)+,d4				
		move.b	(a4)+,d5				
		move.b	(a4)+,d6				
		move.b	(a4)+,d7				

		move.b	0(a3,d0.w),d0		;Farbwert holen
		move.b	0(a3,d1.w),d1
		move.b	0(a3,d2.w),d2
		move.b	0(a3,d3.w),d3
		move.b	0(a3,d4.w),d4
		move.b	0(a3,d5.w),d5
		move.b	0(a3,d6.w),d6
		move.b	0(a3,d7.w),d7

.MACRO	sb_r_8	dn
.LOCAL	sb_r_0
		sub.b		dn,(a0)+				;Farbwert abziehen
		bcc			sb_r_0					;Falls öberlauf..
		move.b	#0,-1(a0)				;..Minwert setzen
sb_r_0:

.ENDM		

		sb_r_8	d0
		sb_r_8	d1
		sb_r_8	d2
		sb_r_8	d3
		sb_r_8	d4
		sb_r_8	d5
		sb_r_8	d6
		sb_r_8	d7
		
		subq.l	#1,x_count_buf
		bpl			sbr2_bxploop
		
		add.l		planeachtdif_buf,a0		;Zeilenoffset fÅr Plane
		add.l		penachtdif_buf,a4			;Zeilenoffset fÅr Pinsel
		subq.l	#1,y_count_buf
		bpl			sbr2_byploop
;end_red > 8
		movem.l	(sp)+,d0-d3/a0
sbend_red2:
		bra			d_dither


