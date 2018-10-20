; PENCOPY
; StiftflÑche in Zielpuffer kopieren

		.MC68030
;C-Teil Import/Export		
.EXPORT	p_red, p_yellow, p_blue, p_screen, p_width
.EXPORT c_red, c_yellow, c_blue, c_mask, c_lasur, c_add
.EXPORT c_qopt, c_plusminus, c_solo, c_layers
.EXPORT	pen_r, pen_g, pen_b
.EXPORT start_x, rel_start_x, start_y, rel_start_y, end_x, end_y
.EXPORT r_table, g_table, b_table
.EXPORT paint_it, intensity, pen_width, screen_width
.EXPORT r_dither_table, g_dither_table, b_dither_table
.EXPORT	table_offset, screen_offset
.EXPORT undo_start, undo_end, undo_buf, undo_maxend
.EXPORT undo_ok, undo_on, undo_id
.EXPORT do_dither, do_harmless, typ0_dither, d_dither
.EXPORT red_list, yellow_list, blue_list, type_list
.EXPORT test1, test2
.EXPORT mul_tab, div_tab, mul_adr
.EXPORT p_mask, mask_activ, p_edmask, mask_edit
.EXPORT lsb_c,lsb_m,lsb_y
.EXPORT lsb_used, lsb_offset
.EXPORT ls_width, ls_dif
.EXPORT ls_start_x, ls_start_y,ls_end_x, ls_end_y
.EXPORT ls_table, ls_entry
.EXPORT no_dither
.EXPORT off8_x, off8_y

; und fÅr andere Assemblermodule:
.EXPORT scr_buf,ydif_buf,xdif_buf,x_acht_buf,x_acht_buf2,x_rest_buf
.EXPORT x_addacht_buf,planedif_buf,planeachtdif_buf,pendif_buf
.EXPORT penachtdif_buf,x_count_buf,y_count_buf,buffer,zen,savreg
.EXPORT sav_sp,dif_y,dif_x,add_screen
.EXPORT temp_red,temp_yellow,temp_blue,temp_line
.EXPORT temp_r,temp_g,temp_b,t_col
.EXPORT curr_y,curr_x
.EXPORT undo_width,undo_size
.EXPORT typ0_dither_pre

.IMPORT mask_paint_it, mask_edit_it

.IMPORT dst_lines, dst_width, dst_red, dst_blue, dst_yellow
.IMPORT dst_2width
.IMPORT src_offset, src_red, src_blue, src_yellow
.IMPORT layeradd_mode, layer_add
.IMPORT grey_dither
.IMPORT zoomout, zoomin, first_zix, first_ziy, col_or_grey
.IMPORT add_x, add_y, harmless

paint_it:
		tst.w		mask_edit
		bne			mask_edit_it
		tst.w		mask_activ
		bne			mask_paint_it
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
		mulu.w	#3,d0					;Mal drei, wegen RGB-Bytes
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
		move.l	p_red,a0
		move.l	p_yellow,a1
		move.l	p_blue,a2
;Pen-Frames
		move.l	pen_r, a4
		move.l	pen_g, a5
		move.l	pen_b, a6
		
		
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
		adda.l	d1,a1
		adda.l	d1,a2
		
		sub.l		d0,d0
		lea			screen_offset,a3	;Tabellenadresse
		move.w	rel_start_y,d0		;Offset-Zeilen auf Screen
		lsl.l		#2,d0							;Mal vier wegen Langwort-Tabelle
		move.l	0(a3,d0.l),d1
		add.l		d1,d6

		sub.l		d0,d0
		move.w	start_x,d0
		adda.l	d0,a0
		adda.l	d0,a1
		adda.l	d0,a2
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

		movem.l	d0/a0-a2,-(sp)
		
		move.w	undo_width,d4
		move.w	undo_size,d5
		move.l	undo_end,a3


u_byploop:
		move.l	dif_x,d1
u_bxploop:
;Undo
		move.b	(a0)+,(a3)+
		move.b	(a1)+,(a3)+
		move.b	(a2)+,(a3)+
;X-Schleife
		dbra		d1,u_bxploop
;Y-Schleife		
		adda.l	d2,a0
		adda.l	d2,a1
		adda.l	d2,a2
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
		
		movem.l	(sp)+,d0/a0-a2
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

; ** ROT **


;Anteil < 8
		move.l	x_rest_buf,d4
		beq			aend_red
		subq.l	#1,d4
		move.l	d4,x_count_buf
		movem.l	d0-d3/a0-a5,-(sp)
		add.l		x_addacht_buf,d2
		add.l		x_addacht_buf,d3
		
		lea			div_tab,a1			;Divisions-Tabelle (x/255) in a1

		lea			mul_adr,a2			;Adressen der x*y-Tabellen
														;fÅr 255-x

		lea			mul_tab,a3					;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_red,d5				;Zeichenfarbe
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
		cmp.b		(a0)+,d5				;Mit Plane vergleichen
		bls			ar_las_0				;Zu groû->
		move.b	d5,-1(a0)				;Sonst Quotient (/255) in vorhandenes Byte schreiben
ar_las_0:
		dbra		d1,ar_bxploop
		
		adda.l	d2,a0						;Zeilenoffset fÅr Plane
		adda.l	d3,a4						;Zeilenoffset fÅr Pinsel
		dbra		d0,ar_byploop
;end_red < 8
		movem.l	(sp)+,d0-d3/a0-a5
aend_red:
		
; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			aend_red2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a0-a5,-(sp)

		move.l	d0,y_count_buf

		lea			div_tab,a1			;Divisions-Tabelle (x/255) in a1

		lea			mul_adr,a2			;Adressen der x*y-Tabellen
														;fÅr 255-x

		lea			mul_tab,a3					;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_red,d5				;Zeichenfarbe
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
		movem.l	(sp)+,d0-d3/a0-a5
aend_red2:


; ** GELB **

;Anteil < 8
		move.l	x_rest_buf,d4
		beq			aend_yellow
		subq.l	#1,d4
		move.l	d4,x_count_buf
		movem.l	d0-d3/a0-a5,-(sp)
		add.l		x_addacht_buf,d2
		add.l		x_addacht_buf,d3
		
		lea			div_tab,a0			;Divisions-Tabelle (x/255) in a1

		lea			mul_adr,a2			;Adressen der x*y-Tabellen
														;fÅr 255-x

		lea			mul_tab,a3					;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_yellow,d5				;Zeichenfarbe
		lsl.l		#8,d5						;mul*255-Tabelle fÅr diese Farbe
		lsl.l		#1,d5						;berechnen
		adda.l	d5,a3						;und in a3
		
ag_byploop:
		move.l	x_count_buf,d1
ag_bxploop:
		moveq.l	#0,d4
		moveq.l	#0,d5
		move.b	(a5)+,d4				;IntensitÑt
		move.w	0(a3,d4*2.w),d5	;Mit Farbwert multipliziert
		move.l	0(a2,d4*4.l),a4	;Tabelle fÅr (255-IntensitÑt)

		moveq		#0,d4
		move.b	(a1),d4					;Planewert holen
		move.w	0(a4,d4*2.w),d4	;mit (255-IntensitÑt) multiplizieren
		add.w		d5,d4						;Addieren
		move.b	0(a0,d4.l),d5		;Endwert holen
		cmp.b		(a1)+,d5				;Mit Plane vergleichen
		bls			ay_las_0				;Zu groû->
		move.b	d5,-1(a1)				;Sonst Quotient (/255) in vorhandenes Byte schreiben
ay_las_0:
		dbra		d1,ag_bxploop
		
		adda.l	d2,a1						;Zeilenoffset fÅr Plane
		adda.l	d3,a5						;Zeilenoffset fÅr Pinsel
		dbra		d0,ag_byploop
;end_yellow < 8
		movem.l	(sp)+,d0-d3/a0-a5
aend_yellow:
		
; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			aend_yellow2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a0-a5,-(sp)

		move.l	d0,y_count_buf

		lea			div_tab,a0			;Divisions-Tabelle (x/255) in a1

		lea			mul_adr,a2			;Adressen der x*y-Tabellen
														;fÅr 255-x

		lea			mul_tab,a3			;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_yellow,d5			;Zeichenfarbe
		lsl.l		#8,d5						;mul*255-Tabelle fÅr diese Farbe
		lsl.l		#1,d5						;berechnen
		adda.l	d5,a3						;und in a3
		
		add.l		x_rest_buf,a5
		add.l		x_rest_buf,a1
ag2_byploop:
		move.l	x_acht_buf2,x_count_buf
ag2_bxploop:

		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		moveq.l	#0,d4
		moveq.l	#0,d5
		moveq.l	#0,d6
		moveq.l	#0,d7

		move.b	(a5)+,d0				;IntensitÑten holen
		move.b	(a5)+,d1				;IntensitÑten holen
		move.b	(a5)+,d2				;IntensitÑten holen
		move.b	(a5)+,d3				;IntensitÑten holen
		move.b	(a5)+,d4				;IntensitÑten holen
		move.b	(a5)+,d5				;IntensitÑten holen
		move.b	(a5)+,d6				;IntensitÑten holen

.MACRO FLOW_LAS_Y dn
.LOCAL	ay_las_00
		moveq		#0,d7
		move.w	0(a3,dn*2.w),d7	;Mit Farbwert multipliziert
		move.l	0(a2,dn*4.l),a4	;Tabelle fÅr (255-IntensitÑt)
		moveq		#0,dn
		move.b	(a1),dn					;Planewert holen
		move.w	0(a4,dn*2.w),dn	;mit (255-IntensitÑt) multiplizieren
		add.w		d7,dn						;Addieren
		move.b	0(a0,dn.l),d7		;Endwert holen
		cmp.b		(a1)+,d7				;Mit Plane vergleichen
		bls			ay_las_00
		move.b	d7,-1(a1)				;Sonst Quotient (/255) in vorhandenes Byte schreiben
ay_las_00:

.ENDM

		FLOW_LAS_Y d0
		FLOW_LAS_Y d1
		FLOW_LAS_Y d2
		FLOW_LAS_Y d3
		FLOW_LAS_Y d4
		FLOW_LAS_Y d5
		FLOW_LAS_Y d6
;und achten Wert:
		moveq		#0,d6
		move.b	(a5)+,d6
		FLOW_LAS_Y d6

		subq.l	#1,x_count_buf
		bpl			ag2_bxploop
		
		add.l		planeachtdif_buf,a1		;Zeilenoffset fÅr Plane
		add.l		penachtdif_buf,a5			;Zeilenoffset fÅr Pinsel
		subq.l	#1,y_count_buf
		bpl			ag2_byploop
;end_yellow > 8
		movem.l	(sp)+,d0-d3/a0-a5
aend_yellow2:


; ** BLAU **


;Anteil < 8
		move.l	x_rest_buf,d4
		beq			aend_blue
		subq.l	#1,d4
		move.l	d4,x_count_buf
		movem.l	d0-d3/a1-a6,-(sp)
		
		add.l		x_addacht_buf,d2
		add.l		x_addacht_buf,d3

		lea			div_tab,a1			;Divisions-Tabelle (x/255) in a1

		lea			mul_adr,a4			;Adressen der x*y-Tabellen
														;fÅr 255-x

		lea			mul_tab,a3					;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_blue,d5				;Zeichenfarbe
		lsl.l		#8,d5						;mul*255-Tabelle fÅr diese Farbe
		lsl.l		#1,d5						;berechnen
		adda.l	d5,a3						;und in a3
		
ab_byploop:
		move.l	x_count_buf,d1
ab_bxploop:
		moveq.l	#0,d4
		moveq.l	#0,d5

		move.b	(a6)+,d4				;IntensitÑt
		move.w	0(a3,d4*2.w),d5	;Mit Farbwert multipliziert
		move.l	0(a4,d4*4.l),a5	;Tabelle fÅr (255-IntensitÑt)

		moveq		#0,d4
		move.b	(a2),d4					;Planewert holen
		move.w	0(a5,d4*2.w),d4	;mit (255-IntensitÑt) multiplizieren
		add.w		d5,d4						;Addieren
		move.b	0(a1,d4.l),d5		;Endwert holen
		cmp.b		(a2)+,d5				;Mit Plane vergleichen
		bls			ab_las_0				;Zu groû->
		move.b	d5,-1(a2)				;Sonst Quotient (/255) in vorhandenes Byte schreiben
ab_las_0:
		dbra		d1,ab_bxploop

		adda.l	d2,a2						;Zeilenoffset fÅr Plane
		adda.l	d3,a6						;Zeilenoffset fÅr Pinsel
		dbra		d0,ab_byploop
;end_blue < 8
		movem.l	(sp)+,d0-d3/a1-a6
aend_blue:
; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			aend_blue2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a0-a5,-(sp)

		move.l	d0,y_count_buf

		lea			div_tab,a1			;Divisions-Tabelle (x/255) in a1

		lea			mul_adr,a4			;Adressen der x*y-Tabellen
														;fÅr 255-x

		lea			mul_tab,a3					;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_blue,d5				;Zeichenfarbe
		lsl.l		#8,d5						;mul*255-Tabelle fÅr diese Farbe
		lsl.l		#1,d5						;berechnen
		adda.l	d5,a3						;und in a3
		
		add.l		x_rest_buf,a6
		add.l		x_rest_buf,a2
ab2_byploop:
		move.l	x_acht_buf2,x_count_buf
ab2_bxploop:

		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		moveq.l	#0,d4
		moveq.l	#0,d5
		moveq.l	#0,d6
		moveq.l	#0,d7

		move.b	(a6)+,d0				;IntensitÑten holen
		move.b	(a6)+,d1				;IntensitÑten holen
		move.b	(a6)+,d2				;IntensitÑten holen
		move.b	(a6)+,d3				;IntensitÑten holen
		move.b	(a6)+,d4				;IntensitÑten holen
		move.b	(a6)+,d5				;IntensitÑten holen
		move.b	(a6)+,d6				;IntensitÑten holen

.MACRO FLOW_LAS_B dn
.LOCAL ab_las_00
		moveq		#0,d7
		move.w	0(a3,dn*2.w),d7	;Mit Farbwert multipliziert
		move.l	0(a4,dn*4.l),a5	;Tabelle fÅr (255-IntensitÑt)
		moveq		#0,dn
		move.b	(a2),dn					;Planewert holen
		move.w	0(a5,dn*2.w),dn	;mit (255-IntensitÑt) multiplizieren
		add.w		d7,dn						;Addieren
		move.b	0(a1,dn.l),d7		;Endwert holen
		cmp.b		(a2)+,d7				;Mit Plane vergleichen
		bls			ab_las_00				;Zu groû->
		move.b	d7,-1(a2)				;Sonst Quotient (/255) in vorhandenes Byte schreiben
ab_las_00:
.ENDM

		FLOW_LAS_B d0
		FLOW_LAS_B d1
		FLOW_LAS_B d2
		FLOW_LAS_B d3
		FLOW_LAS_B d4
		FLOW_LAS_B d5
		FLOW_LAS_B d6
		
;und achten Wert:
		moveq		#0,d6
		move.b	(a6)+,d6
		FLOW_LAS_B d6

		subq.l	#1,x_count_buf
		bpl			ab2_bxploop
		
		add.l		planeachtdif_buf,a2		;Zeilenoffset fÅr Plane
		add.l		penachtdif_buf,a6			;Zeilenoffset fÅr Pinsel
		subq.l	#1,y_count_buf
		bpl			ab2_byploop
;end_blue > 8
		movem.l	(sp)+,d0-d3/a0-a5
aend_blue2:
		bra	d_dither



;**********************
; LASUR NORMAL
;**********************



las_no_add:
;Lasur nicht addierend

; ** ROT **

		moveq.l	#0,d4
		lea			intensity,a3		;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_red,d5				;Zeichenfarbe
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
		cmp.b		(a0)+,d4				;Farbwert zu groû?
		bls			las_0
		move.b	d4,-1(a0)				;In vorhandenes Byte schreiben
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

		cmp.b		(a0)+,d0				;Farbwert zu groû?
		bls			las_r2_0
		move.b	d0,-1(a0)				;In vorhandenes Byte schreiben
las_r2_0:
		cmp.b		(a0)+,d1
		bls			las_r2_1
		move.b	d1,-1(a0)
las_r2_1:
		cmp.b		(a0)+,d2
		bls			las_r2_2
		move.b	d2,-1(a0)
las_r2_2:
		cmp.b		(a0)+,d3
		bls			las_r2_3
		move.b	d3,-1(a0)
las_r2_3:
		cmp.b		(a0)+,d4
		bls			las_r2_4
		move.b	d4,-1(a0)
las_r2_4:
		cmp.b		(a0)+,d5
		bls			las_r2_5
		move.b	d5,-1(a0)
las_r2_5:
		cmp.b		(a0)+,d6
		bls			las_r2_6
		move.b	d6,-1(a0)
las_r2_6:
		cmp.b		(a0)+,d7
		bls			las_r2_7
		move.b	d7,-1(a0)
las_r2_7:

		subq.l	#1,x_count_buf
		bpl			r2_bxploop
		
		add.l		planeachtdif_buf,a0		;Zeilenoffset fÅr Plane
		add.l		penachtdif_buf,a4			;Zeilenoffset fÅr Pinsel
		subq.l	#1,y_count_buf
		bpl			r2_byploop
;end_red > 8
		movem.l	(sp)+,d0-d3/a0
end_red2:


; ** GELB **

		moveq.l	#0,d4
		lea			intensity,a3		;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_yellow,d5			;Zeichenfarbe
		lsl.w		#8,d5						;Tabelle fÅr diese Farbe
		adda.l	d5,a3						;berechnen

;Anteil < 8
		move.l	x_rest_buf,d4
		beq			end_yellow
		subq.l	#1,d4
		move.l	d4,x_count_buf
		movem.l	d0-d3,-(sp)
		move.l	a1,-(sp)
		move.l	a5,-(sp)
		
		add.l		x_addacht_buf,d2
		add.l		x_addacht_buf,d3
		
g_byploop:
		move.l	x_count_buf,d1
g_bxploop:
		move.b	(a5)+,d4				;Pinseldurchlaû
		move.b	0(a3,d4.l),d4		;Farbwert holen
		cmp.b		(a1)+,d4				;Farbwert zu groû?
		bls			las_1
		move.b	d4,-1(a1)				;In vorhandenes Byte schreiben
las_1:
		dbra		d1,g_bxploop
		
		adda.l	d2,a1						;Zeilenoffset fÅr Plane
		adda.l	d3,a5						;Zeilenoffset fÅr Pinsel
		dbra		d0,g_byploop
;end_yellow < 8
		move.l	(sp)+,a5
		move.l	(sp)+,a1
		movem.l	(sp)+,d0-d3
end_yellow:
		
; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			end_yellow2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a1,-(sp)

		move.l	d0,y_count_buf
		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		moveq.l	#0,d4
		moveq.l	#0,d5
		moveq.l	#0,d6
		moveq.l	#0,d7
		add.l		x_rest_buf,a5
		add.l		x_rest_buf,a1
g2_byploop:
		move.l	x_acht_buf2,x_count_buf
g2_bxploop:
		move.b	(a5)+,d0				;Pinseldurchlaû
		move.b	(a5)+,d1
		move.b	(a5)+,d2
		move.b	(a5)+,d3
		move.b	(a5)+,d4
		move.b	(a5)+,d5
		move.b	(a5)+,d6
		move.b	(a5)+,d7

		move.b	0(a3,d0.w),d0		;Farbwert holen
		move.b	0(a3,d1.w),d1
		move.b	0(a3,d2.w),d2
		move.b	0(a3,d3.w),d3
		move.b	0(a3,d4.w),d4
		move.b	0(a3,d5.w),d5
		move.b	0(a3,d6.w),d6
		move.b	0(a3,d7.w),d7

		cmp.b		(a1)+,d0				;Farbwert zu groû?
		bls			las_g2_0
		move.b	d0,-1(a1)				;In vorhandenes Byte schreiben
las_g2_0:
		cmp.b		(a1)+,d1
		bls			las_g2_1
		move.b	d1,-1(a1)
las_g2_1:
		cmp.b		(a1)+,d2
		bls			las_g2_2
		move.b	d2,-1(a1)
las_g2_2:
		cmp.b		(a1)+,d3
		bls			las_g2_3
		move.b	d3,-1(a1)
las_g2_3:
		cmp.b		(a1)+,d4
		bls			las_g2_4
		move.b	d4,-1(a1)
las_g2_4:
		cmp.b		(a1)+,d5
		bls			las_g2_5
		move.b	d5,-1(a1)
las_g2_5:
		cmp.b		(a1)+,d6
		bls			las_g2_6
		move.b	d6,-1(a1)
las_g2_6:
		cmp.b		(a1)+,d7
		bls			las_g2_7
		move.b	d7,-1(a1)
las_g2_7:

		subq.l	#1,x_count_buf
		bpl			g2_bxploop
		
		add.l		planeachtdif_buf,a1		;Zeilenoffset fÅr Plane
		add.l		penachtdif_buf,a5			;Zeilenoffset fÅr Pinsel
		subq.l	#1,y_count_buf
		bpl			g2_byploop
;end_yellow > 8
		movem.l	(sp)+,d0-d3/a1
end_yellow2:


; ** BLAU **

		moveq.l	#0,d4
		lea			intensity,a3		;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_blue,d5				;Zeichenfarbe
		lsl.w		#8,d5						;Tabelle fÅr diese Farbe
		adda.l	d5,a3						;berechnen

;Anteil < 8
		move.l	x_rest_buf,d4
		beq			end_blue
		subq.l	#1,d4
		move.l	d4,x_count_buf
		movem.l	d0-d3,-(sp)
		move.l	a2,-(sp)
		move.l	a6,-(sp)
		
		add.l		x_addacht_buf,d2
		add.l		x_addacht_buf,d3
		
b_byploop:
		move.l	x_count_buf,d1
b_bxploop:
		move.b	(a6)+,d4				;Pinseldurchlaû
		move.b	0(a3,d4.l),d4		;Farbwert holen
		cmp.b		(a2)+,d4				;Farbwert zu groû?
		bls			las_2
		move.b	d4,-1(a2)				;In vorhandenes Byte schreiben
las_2:
		dbra		d1,b_bxploop
		
		adda.l	d2,a2						;Zeilenoffset fÅr Plane
		adda.l	d3,a6						;Zeilenoffset fÅr Pinsel
		dbra		d0,b_byploop
;end_blue < 8
		move.l	(sp)+,a6
		move.l	(sp)+,a2
		movem.l	(sp)+,d0-d3
end_blue:
; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			end_blue2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a2,-(sp)

		move.l	d0,y_count_buf
		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		moveq.l	#0,d4
		moveq.l	#0,d5
		moveq.l	#0,d6
		moveq.l	#0,d7
		add.l		x_rest_buf,a6
		add.l		x_rest_buf,a2
b2_byploop:
		move.l	x_acht_buf2,x_count_buf
b2_bxploop:
		move.b	(a6)+,d0				;Pinseldurchlaû
		move.b	(a6)+,d1
		move.b	(a6)+,d2
		move.b	(a6)+,d3
		move.b	(a6)+,d4
		move.b	(a6)+,d5
		move.b	(a6)+,d6
		move.b	(a6)+,d7

		move.b	0(a3,d0.w),d0		;Farbwert holen
		move.b	0(a3,d1.w),d1
		move.b	0(a3,d2.w),d2
		move.b	0(a3,d3.w),d3
		move.b	0(a3,d4.w),d4
		move.b	0(a3,d5.w),d5
		move.b	0(a3,d6.w),d6
		move.b	0(a3,d7.w),d7

		cmp.b		(a2)+,d0				;Farbwert zu groû?
		bls			las_b2_0
		move.b	d0,-1(a2)				;In vorhandenes Byte schreiben
las_b2_0:
		cmp.b		(a2)+,d1
		bls			las_b2_1
		move.b	d1,-1(a2)
las_b2_1:
		cmp.b		(a2)+,d2
		bls			las_b2_2
		move.b	d2,-1(a2)
las_b2_2:
		cmp.b		(a2)+,d3
		bls			las_b2_3
		move.b	d3,-1(a2)
las_b2_3:
		cmp.b		(a2)+,d4
		bls			las_b2_4
		move.b	d4,-1(a2)
las_b2_4:
		cmp.b		(a2)+,d5
		bls			las_b2_5
		move.b	d5,-1(a2)
las_b2_5:
		cmp.b		(a2)+,d6
		bls			las_b2_6
		move.b	d6,-1(a2)
las_b2_6:
		cmp.b		(a2)+,d7
		bls			las_b2_7
		move.b	d7,-1(a2)
las_b2_7:

		subq.l	#1,x_count_buf
		bpl			b2_bxploop
		
		add.l		planeachtdif_buf,a2		;Zeilenoffset fÅr Plane
		add.l		penachtdif_buf,a6			;Zeilenoffset fÅr Pinsel
		subq.l	#1,y_count_buf
		bpl			b2_byploop
;end_blue > 8
		movem.l	(sp)+,d0-d3/a2
end_blue2:




;**************
;*** DITHER ***
;**************



d_dither:		
		tst.w		no_dither	;Bildschirmdarstellung abgeschaltet?
		bne			nix_dither;Ja->Ende
		tst.w		c_solo		;SOLO-Mode on?
		beq			typ0_dither_pre	;Nein->
		tst.w		mask_edit
		beq			db_dither
;Solo ist an und Maske wird editiert->d.h. Maske ist nicht
;sichtbar, also Ñndert sich nix am Screen
nix_dither:
		movem.l	(sp)+,d0-d7/a0-a6
		rts
		
db_dither:
		move.w	#0,harmless
		tst.b		col_or_grey				;Graustufen-Dither?
		bne			grey_dither				;Ja->
		
		tst.w		zoomout						;Zoom an?
		bne			zo_db_dither			;Ja->
		tst.w		zoomin						;Zoom an?
		bne			zi_db_dither			;Ja->
		
		move.l	scr_buf,a6				;Screenadresse
		moveq.l	#16,d3

		lea			r_dither_table,a3
		lea			g_dither_table,a4
		lea			b_dither_table,a5
		
		moveq.l	#0,d5
		moveq.l	#0,d4
		
		move.w	start_x,d6	;X-Pos holen
		and.l		#7,d6				;Nur 8er-Pos interessant
		move.l	a7,sav_sp
		
d_yloop:
		move.l	dif_x,d1
		move.w	curr_y,d5		;Momentane Zeile holen
		and.l		#7,d5				;Nur 8er-Pos interessant
		lsl.w		#3,d5				;Mal 8 (ist Zeile)
		jmp ([jmp_tab,d6*4])

jmp_tab:
		DC.L dither_7   ; Zeiger auf Start mit acht durchgÑngen
		DC.L dither_6
		DC.L dither_5
		DC.L dither_4
		DC.L dither_3
		DC.L dither_2
		DC.L dither_1
		DC.L dither_0

d_xloop:
.MACRO dither_x x
.LOCAL no_store
		move.b	(a0)+,d4							;Rot-Wert holen
		move.l	(a3,d4*4), a7					;Zeiger auf Raster
		move.b	x(a7,d5),d7						;Wert aus Raster

		move.b	(a1)+,d4							;GrÅn-Wert holen
		move.l	(a4, d4*4), a7
		add.b		x(a7,d5),d7

		move.b	(a2)+,d4							;Blau-Wert holen
		move.l	(a5, d4*4), a7
		add.b		x(a7, d5),d7
		add.b		d3,d7				;d3=16, Farboffset
		move.b	d7,(a6)+		;Und ab in den Screen
		subq.l	#1,d1
.ENDM

dither_7: 
		dither_x 7
		bmi			d_end_x
dither_6:
		dither_x 6
		bmi			d_end_x
dither_5:
		dither_x 5
		bmi			d_end_x
dither_4:
		dither_x 4
		bmi			d_end_x
dither_3:
		dither_x 3
		bmi			d_end_x
dither_2:
		dither_x 2
		bmi			d_end_x
dither_1:
		dither_x 1
		bmi			d_end_x
dither_0:
		dither_x 0
		bpl			d_xloop

d_end_x:
		adda.l	d2,a0
		adda.l	d2,a1
		adda.l	d2,a2
		adda.l	add_screen,a6
		addq.w	#1,curr_y
		dbra		d0,d_yloop
d_end_all:
		move.l	sav_sp,a7
		movem.l	(sp)+,d0-d7/a0-a6
		rts


;***************
;Zoom-Out Dither
;***************
zo_db_dither:
;Werte Ñndern:
;d0=ZeilenzÑhler -> /=(zoomout+1)
;dif_x=zu dithernde Zeilenbreite-1 -> /=(zoomout+1)
;d2=Planes Zeilendiff -> =word_width-(dif_x+1)*(zoomout+1)(Zeilenrest)
;													+word_width*zoomout             (Leerzeilen)
;add_screen=Screen Zeilendiff -> +=dif_x-dif_x/(zoomout+1)
		moveq.l	#0,d4
		move.w	zoomout,d4
		addq.w	#1,d4				;d4=zoomout+1

		divu.w	d4,d0				;d0/=(zoomout+1)

		move.l	dif_x,d5		;d5=dif_x
		move.l	d5,d1				;Merken fÅr nachher
		divu.w	d4,d5				;d5/=(zoomout+1)
		andi.l	#$0000ffff,d5	;Rest ausmakieren
		move.l	d5,dif_x		;dif_x neu

		sub.w		d5,d1				;d1=old_dif-new_dif
		add.l		d1,add_screen	;add_screen+=d1
		
		move.l	p_width,d2	;d2=plane_width
		move.l	dif_x,d5		;d5=dif_x
		addq.l	#1,d5				;d5++
		mulu.w	d4,d5				;d5=dif_x*(zoomout+1)
		sub.l		d5,d2				;d2=Zeilenrest

		move.l	p_width,d5	;d5=plane_width
		subq.w	#1,d4				;d4=zoomout
		mulu.w	d4,d5				;d5=plane_width*zoomout
		add.l		d5,d2				;d2+=plane_width*zoomout



		move.l	scr_buf,a6				;Screenadresse
		clr.l		d3
		move.w	zoomout,d3

		lea			r_dither_table,a3
		lea			g_dither_table,a4
		lea			b_dither_table,a5
		
		moveq.l	#0,d5
		moveq.l	#0,d4
		
		move.w	start_x,d6	;X-Pos holen
		and.l		#7,d6				;Nur 8er-Pos interessant
		move.l	a7,sav_sp
		
zo_d_yloop:
		move.l	dif_x,d1
		move.w	curr_y,d5		;Momentane Zeile holen
		and.l		#7,d5				;Nur 8er-Pos interessant
		lsl.w		#3,d5				;Mal 8 (ist Zeile)
		jmp ([zo_jmp_tab,d6*4])

zo_jmp_tab:
		DC.L zo_dither_7   ; Zeiger auf Start mit acht durchgÑngen
		DC.L zo_dither_6
		DC.L zo_dither_5
		DC.L zo_dither_4
		DC.L zo_dither_3
		DC.L zo_dither_2
		DC.L zo_dither_1
		DC.L zo_dither_0

zo_d_xloop:
.MACRO zo_dither_x x
		move.b	(a0)+,d4							;Rot-Wert holen
		move.l	(a3,d4*4), a7					;Zeiger auf Raster
		move.b	x(a7,d5),d7						;Wert aus Raster

		move.b	(a1)+,d4							;GrÅn-Wert holen
		move.l	(a4, d4*4), a7
		add.b		x(a7,d5),d7

		move.b	(a2)+,d4							;Blau-Wert holen
		move.l	(a5, d4*4), a7
		add.b		x(a7, d5),d7
		add.b		#16,d7				;Farboffset
		move.b	d7,(a6)+		;Und ab in den Screen
		adda.l	d3,a0				;Zoomverschiebung
		adda.l	d3,a1
		adda.l	d3,a2
		subq.l	#1,d1
.ENDM

zo_dither_7: 
		zo_dither_x 7
		bmi			zo_d_end_x
zo_dither_6:
		zo_dither_x 6
		bmi			zo_d_end_x
zo_dither_5:
		zo_dither_x 5
		bmi			zo_d_end_x
zo_dither_4:
		zo_dither_x 4
		bmi			zo_d_end_x
zo_dither_3:
		zo_dither_x 3
		bmi			zo_d_end_x
zo_dither_2:
		zo_dither_x 2
		bmi			zo_d_end_x
zo_dither_1:
		zo_dither_x 1
		bmi			zo_d_end_x
zo_dither_0:
		zo_dither_x 0
		bpl			zo_d_xloop

zo_d_end_x:
		adda.l	d2,a0
		adda.l	d2,a1
		adda.l	d2,a2
		adda.l	add_screen,a6
		addq.w	#1,curr_y
		dbra		d0,zo_d_yloop
zo_d_end_all:
		move.l	sav_sp,a7
		movem.l	(sp)+,d0-d7/a0-a6
		rts


;***************
;Zoom-Out Dither
;***************
zi_db_dither:
;Werte Ñndern:
;d0=ZeilenzÑhler -> *=(zoomin+1) +=add_y
;dif_x=zu dithernde Zeilenbreite-1 -> *=(zoomin+1)
;d2=Planes Zeilendiff -> =word_width (weil in x-loop nix addiert wird)
;add_screen=Screen Zeilendiff -> =screen_width-dif_x
		moveq.l	#0,d4
		move.w	zoomin,d4
		addq.w	#1,d4				;d4=zoomin+1

		mulu.w	d4,d0				;d0*=(zoomin+1)
		add.w		add_y,d0
		
		move.l	dif_x,d5		;d5=dif_x
		mulu.w	d4,d5				;d5*=(zoomin+1)
		add.w		add_x,d5
		move.l	d5,dif_x		;dif_x neu

		move.l	screen_width,d1
		sub.l		d5,d1				;d1=screen_width-new_dif
		subq.l	#1,d1
		move.l	d1,add_screen	;add_screen=d1
		
		move.l	p_width,d2	;d2=plane_width


		move.l	scr_buf,a6				;Screenadresse

		lea			r_dither_table,a3
		lea			g_dither_table,a4
		lea			b_dither_table,a5
		
		moveq.l	#0,d5
		moveq.l	#0,d4
		
		move.w	off8_y,curr_y
		move.w	off8_x,d6	;X-Pos holen
		and.l		#7,d6				;Nur 8er-Pos interessant
		move.l	a7,sav_sp
		
		move.w	first_ziy,d3
		swap		d3
zi_d_yloop:
		move.w	first_zix,d3
		swap		d0
		move.w	#0,d0
		move.l	dif_x,d1
		move.w	curr_y,d5		;Momentane Zeile holen
		and.l		#7,d5				;Nur 8er-Pos interessant
		lsl.w		#3,d5				;Mal 8 (ist Zeile)
		jmp ([zi_jmp_tab,d6*4])

zi_jmp_tab:
		DC.L zi_dither_7   ; Zeiger auf Start mit acht durchgÑngen
		DC.L zi_dither_6
		DC.L zi_dither_5
		DC.L zi_dither_4
		DC.L zi_dither_3
		DC.L zi_dither_2
		DC.L zi_dither_1
		DC.L zi_dither_0

zi_d_xloop:
.MACRO zi_dither_x x
.LOCAL zi_cont_x
		move.b	(a0,d0.w),d4							;Rot-Wert holen
		move.l	(a3,d4*4), a7					;Zeiger auf Raster
		move.b	x(a7,d5),d7						;Wert aus Raster

		move.b	(a1,d0.w),d4							;GrÅn-Wert holen
		move.l	(a4, d4*4), a7
		add.b		x(a7,d5),d7

		move.b	(a2,d0.w),d4							;Blau-Wert holen
		move.l	(a5, d4*4), a7
		add.b		x(a7, d5),d7
		add.b		#16,d7				;Farboffset
		move.b	d7,(a6)+		;Und ab in den Screen

		dbra		d3,zi_cont_x		;Zoomverschiebung?
		addq.w	#1,d0						;Zoomverschiebung
		move.w	zoomin,d3
zi_cont_x:
		subq.l	#1,d1
.ENDM

zi_dither_7: 
		zi_dither_x 7
		bmi			zi_d_end_x
zi_dither_6:
		zi_dither_x 6
		bmi			zi_d_end_x
zi_dither_5:
		zi_dither_x 5
		bmi			zi_d_end_x
zi_dither_4:
		zi_dither_x 4
		bmi			zi_d_end_x
zi_dither_3:
		zi_dither_x 3
		bmi			zi_d_end_x
zi_dither_2:
		zi_dither_x 2
		bmi			zi_d_end_x
zi_dither_1:
		zi_dither_x 1
		bmi			zi_d_end_x
zi_dither_0:
		zi_dither_x 0
		bpl			zi_d_xloop

zi_d_end_x:
		swap		d3
		dbra		d3,zi_cont_y	;Zoomverschiebung?
		adda.l	d2,a0					;Ja
		adda.l	d2,a1
		adda.l	d2,a2
		move.w	zoomin,d3
zi_cont_y:
		swap		d3

		adda.l	add_screen,a6
		addq.w	#1,curr_y
		swap		d0
		dbra		d0,zi_d_yloop
zi_d_end_all:
		move.l	sav_sp,a7
		movem.l	(sp)+,d0-d7/a0-a6
		rts



; *** GLEICHE DITHER-ROUTINE ***
; In 'harmloser' Version, d.h. a7 wird nicht
; benutzt. Wichtig fÅr Userdef's, weil hier offenbar
; irgendjemand unterbricht und dann a7 als Stack miûbraucht
; (ist aber der Zeiger auf die Ditherfelder!)

do_harmless:
		movem.l	d0-d7/a0-a6,-(sp)
		move.w	#1,harmless
;Planes
		move.l	p_red,a0
		move.l	p_yellow,a1
		move.l	p_blue,a2

		
		
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
		adda.l	d1,a1
		adda.l	d1,a2
		
		sub.l		d0,d0
		lea			screen_offset,a3	;Tabellenadresse
		move.w	rel_start_y,d0		;Offset-Zeilen auf Screen
		lsl.l		#2,d0							;Mal vier wegen Langwort-Tabelle
		move.l	0(a3,d0.l),d1
		add.l		d1,d6

		sub.l		d0,d0
		move.w	start_x,d0
		adda.l	d0,a0
		adda.l	d0,a1
		adda.l	d0,a2
		move.w	rel_start_x,d0
		add.l		d0,d6
		move.l	d6,scr_buf
		move.l	dif_y,d0

		tst.b		col_or_grey				;Graustufen-Dither?
		bne			grey_dither				;Ja->

d_byploop:
		move.l	dif_x,d1
		move.w	start_x, curr_x
d_bxploop:

;In Zielplane schreiben

;Orderd-Dither
		sub.l		d4,d4
		sub.l		d5,d5
;Offset fÅr Dithertabellen:
		move.w	curr_y,d4		;Momentane Zeile holen
		and.w		#7,d4				;Nur 8er-Pos interessant
		lsl.w		#3,d4				;Mal 8 (ist Zeile)
		move.w	curr_x,d5				;X-Pos holen
		and.w		#7,d5				;Nur 8er-Pos interessant
		add.w		d4,d5				;Ditheroffset in d5
		
		sub.w		d4,d4
		move.b	(a0)+,d4		;Rot-Wert
		lsl.w		#2,d4
		lea			r_dither_table,a3
		move.l	0(a3,d4.w),a3		;Zeiger auf Ditherraster f. Rotwert
		move.b	0(a3,d5.w),d7		;Erster Farbwert
		
		sub.w		d4,d4
		move.b	(a1)+,d4		;GrÅn-Wert
		lsl.w		#2,d4
		lea			g_dither_table,a3
		move.l	0(a3,d4.w),a3		;Zeiger auf Ditherraster f. GrÅn
		add.b		0(a3,d5.w),d7		;Farbwert addieren
		
		sub.w		d4,d4
		move.b	(a2)+,d4		;Blau-Wert
		lsl.w		#2,d4
		lea			b_dither_table,a3
		move.l	0(a3,d4.w),a3		;Zeiger auf Ditherraster f. Blau
		add.b		0(a3,d5.w),d7		;Farbwert addieren
		
		add.b		#16,d7					;Tabellenoffset addieren
		move.l	d6,a3						;Screenpufferadresse holen
		move.b	d7,(a3)					;und Pixel ablegen
		

		addq.l	#1,d6
		addq.w	#1,curr_x
		dbra		d1,d_bxploop
		
		adda.l	d2,a0
		adda.l	d2,a1
		adda.l	d2,a2
		add.l		add_screen,d6
		addq.w	#1,curr_y
		dbra		d0,d_byploop

end_paint:
		movem.l	(sp)+,d0-d7/a0-a6
		rts



;**************************
; 8-Bit Dither Vorbereitung
;**************************



do_dither:
		movem.l	d0-d7/a0-a6,-(sp)
		
;Planes
		move.l	p_red,a0
		move.l	p_yellow,a1
		move.l	p_blue,a2

		
		
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
		adda.l	d1,a1
		adda.l	d1,a2
		
		sub.l		d0,d0
		lea			screen_offset,a3	;Tabellenadresse
		move.w	rel_start_y,d0		;Offset-Zeilen auf Screen
		lsl.l		#2,d0							;Mal vier wegen Langwort-Tabelle
		move.l	0(a3,d0.l),d1
		add.l		d1,d6

		sub.l		d0,d0
		move.w	start_x,d0
		adda.l	d0,a0
		adda.l	d0,a1
		adda.l	d0,a2
		move.w	rel_start_x,d0
		add.l		d0,d6
		move.l	d6,scr_buf
		move.l	dif_y,d0

		bra			db_dither





;*******************
;Typ0 Dither, d.h. alle Ebenen in den Listen werden berÅcksichtigt
;
;*******************

typ0_dither_pre:
;Kommt vom Zeichnen: Stack leeren
		movem.l	(sp)+,d0-d7/a0-a6
		tst.w		c_layers		;Steht Åberhaupt was an?
		bne			typ0_dither
		rts
		
typ0_dither:
		movem.l	d0-d1/a0-a3,-(sp)
;Buffer lîschen		
		move.l	lsb_used,d0
		
		move.l	d0,d1
		move.l	dst_blue,a0
cl_c:
		move.w	#0,(a0)+
		subq.l	#1,d1
		bne			cl_c

		move.l	d0,d1
		move.l	dst_red,a0
cl_m:
		move.w	#0,(a0)+
		subq.l	#1,d1
		bne			cl_m

		move.l	d0,d1
		move.l	dst_yellow,a0
cl_y:
		move.w	#0,(a0)+
		subq.l	#1,d1
		bne			cl_y
		
;Planes
		move.l	red_list,a0
		move.l	yellow_list,a1
		move.l	blue_list,a2
		move.l	type_list,a3
		
		move.l	lsb_offset,d0
		
;Durchkopieren
typ0_copy:
		move.w	(a3)+,layeradd_mode
		bmi			typ0_finish
		move.l	(a0)+,d1
		beq			no_radd
		add.l		d0,d1
no_radd:
		move.l	d1,src_red
		move.l	(a1)+,d1
		beq			no_yadd
		add.l		d0,d1
no_yadd:
		move.l	d1,src_yellow
		move.l	(a2)+,d1
		beq			no_badd
		add.l		d0,d1
no_badd:
		move.l	d1,src_blue
		jsr			layer_add
		bra			typ0_copy

typ0_finish:
;Zielebenendaten retten
		move.l	p_red, ls_pbred
		move.l	p_yellow, ls_pbyellow
		move.l	p_blue, ls_pbblue
		move.l	p_width, ls_pbwidth
		move.w	start_x, ls_pbstart_x
		move.w	start_y, ls_pbstart_y
		move.w	end_x, ls_pbend_x
		move.w	end_y, ls_pbend_y
;Pufferebenendaten eintragen
		move.l	ls_dif,a0
		move.l	dst_red, a1
		suba.l	a0,a1
		move.l	a1,p_red
		move.l	dst_blue, a1
		suba.l	a0,a1
		move.l	a1,p_blue
		move.l	dst_yellow,a1
		suba.l	a0,a1
		move.l	a1,p_yellow
		move.l	ls_width, p_width
		move.w	ls_start_x,start_x
		move.w	ls_start_y,start_y
		move.w	ls_end_x, end_x
		move.w	ls_end_y,	end_y

		move.l	ls_table,a0
		move.l	(a0),ls_pbentry
		move.l	ls_entry,(a0)
		
		movem.l	(sp)+,d0-d1/a0-a3
		bsr			do_dither
;Zielebenendaten zurÅck
		move.l	ls_pbred, p_red
		move.l	ls_pbyellow, p_yellow
		move.l	ls_pbblue, p_blue
		move.l	ls_pbwidth, p_width
		move.w	ls_pbstart_x, start_x
		move.w	ls_pbstart_y, start_y
		move.w	ls_pbend_x, end_x
		move.w	ls_pbend_y, end_y
		move.l	a0,-(sp)
		move.l	ls_table,a0
		move.l	ls_pbentry,(a0)
		move.l	(sp)+,a0
		rts


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
		movem.l	d0-d3/a0-a5,-(sp)
		add.l		x_addacht_buf,d2
		add.l		x_addacht_buf,d3
		
		lea			div_tab,a1			;Divisions-Tabelle (x/255) in a1

		lea			mul_adr,a2			;Adressen der x*y-Tabellen
														;fÅr 255-x

		lea			mul_tab,a3					;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_red,d5				;Zeichenfarbe
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
		movem.l	(sp)+,d0-d3/a0-a5
oaend_red:
		
; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			oaend_red2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a0-a5,-(sp)

		move.l	d0,y_count_buf

		lea			div_tab,a1			;Divisions-Tabelle (x/255) in a1

		lea			mul_adr,a2			;Adressen der x*y-Tabellen
														;fÅr 255-x

		lea			mul_tab,a3					;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_red,d5				;Zeichenfarbe
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
		move.b	0(a1,dn.l),(a0)+	;Quotient (/255) in vorhandenes Byte schreiben
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
		movem.l	(sp)+,d0-d3/a0-a5
oaend_red2:


; ** GELB **

;Anteil < 8
		move.l	x_rest_buf,d4
		beq			oaend_yellow
		subq.l	#1,d4
		move.l	d4,x_count_buf
		movem.l	d0-d3/a0-a5,-(sp)
		add.l		x_addacht_buf,d2
		add.l		x_addacht_buf,d3
		
		lea			div_tab,a0			;Divisions-Tabelle (x/255) in a1

		lea			mul_adr,a2			;Adressen der x*y-Tabellen
														;fÅr 255-x

		lea			mul_tab,a3					;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_yellow,d5				;Zeichenfarbe
		lsl.l		#8,d5						;mul*255-Tabelle fÅr diese Farbe
		lsl.l		#1,d5						;berechnen
		adda.l	d5,a3						;und in a3
		
oag_byploop:
		move.l	x_count_buf,d1
oag_bxploop:
		moveq.l	#0,d4
		moveq.l	#0,d5
		move.b	(a5)+,d4				;IntensitÑt
		move.w	0(a3,d4*2.w),d5	;Mit Farbwert multipliziert
		move.l	0(a2,d4*4.l),a4	;Tabelle fÅr (255-IntensitÑt)

		moveq		#0,d4
		move.b	(a1),d4					;Planewert holen
		move.w	0(a4,d4*2.w),d4	;mit (255-IntensitÑt) multiplizieren
		add.w		d5,d4						;Addieren
		move.b	0(a0,d4.l),(a1)+;Quotient (/255) in vorhandenes Byte schreiben

		dbra		d1,oag_bxploop
		
		adda.l	d2,a1						;Zeilenoffset fÅr Plane
		adda.l	d3,a5						;Zeilenoffset fÅr Pinsel
		dbra		d0,oag_byploop
;end_yellow < 8
		movem.l	(sp)+,d0-d3/a0-a5
oaend_yellow:
		
; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			oaend_yellow2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a0-a5,-(sp)

		move.l	d0,y_count_buf

		lea			div_tab,a0			;Divisions-Tabelle (x/255) in a1

		lea			mul_adr,a2			;Adressen der x*y-Tabellen
														;fÅr 255-x

		lea			mul_tab,a3			;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_yellow,d5			;Zeichenfarbe
		lsl.l		#8,d5						;mul*255-Tabelle fÅr diese Farbe
		lsl.l		#1,d5						;berechnen
		adda.l	d5,a3						;und in a3
		
		add.l		x_rest_buf,a5
		add.l		x_rest_buf,a1
oag2_byploop:
		move.l	x_acht_buf2,x_count_buf
oag2_bxploop:

		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		moveq.l	#0,d4
		moveq.l	#0,d5
		moveq.l	#0,d6
		moveq.l	#0,d7

		move.b	(a5)+,d0				;IntensitÑten holen
		move.b	(a5)+,d1				;IntensitÑten holen
		move.b	(a5)+,d2				;IntensitÑten holen
		move.b	(a5)+,d3				;IntensitÑten holen
		move.b	(a5)+,d4				;IntensitÑten holen
		move.b	(a5)+,d5				;IntensitÑten holen
		move.b	(a5)+,d6				;IntensitÑten holen

.MACRO FLOW_OPQ_Y dn
		moveq		#0,d7
		move.w	0(a3,dn*2.w),d7	;Mit Farbwert multipliziert
		move.l	0(a2,dn*4.l),a4	;Tabelle fÅr (255-IntensitÑt)
		moveq		#0,dn
		move.b	(a1),dn					;Planewert holen
		move.w	0(a4,dn*2.w),dn	;mit (255-IntensitÑt) multiplizieren
		add.w		d7,dn						;Addieren
		move.b	0(a0,dn.l),(a1)+	;Quotient (/255) in vorhandenes Byte schreiben
.ENDM

		FLOW_OPQ_Y d0
		FLOW_OPQ_Y d1
		FLOW_OPQ_Y d2
		FLOW_OPQ_Y d3
		FLOW_OPQ_Y d4
		FLOW_OPQ_Y d5
		FLOW_OPQ_Y d6
;und achten Wert:
		moveq		#0,d6
		move.b	(a5)+,d6
		FLOW_OPQ_Y d6

		subq.l	#1,x_count_buf
		bpl			oag2_bxploop
		
		add.l		planeachtdif_buf,a1		;Zeilenoffset fÅr Plane
		add.l		penachtdif_buf,a5			;Zeilenoffset fÅr Pinsel
		subq.l	#1,y_count_buf
		bpl			oag2_byploop
;end_yellow > 8
		movem.l	(sp)+,d0-d3/a0-a5
oaend_yellow2:


; ** BLAU **

		
;Anteil < 8
		move.l	x_rest_buf,d4
		beq			oaend_blue
		subq.l	#1,d4
		move.l	d4,x_count_buf
		movem.l	d0-d3/a1-a6,-(sp)
		
		add.l		x_addacht_buf,d2
		add.l		x_addacht_buf,d3

		lea			div_tab,a1			;Divisions-Tabelle (x/255) in a1

		lea			mul_adr,a4			;Adressen der x*y-Tabellen
														;fÅr 255-x

		lea			mul_tab,a3					;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_blue,d5				;Zeichenfarbe
		lsl.l		#8,d5						;mul*255-Tabelle fÅr diese Farbe
		lsl.l		#1,d5						;berechnen
		adda.l	d5,a3						;und in a3
		
oab_byploop:
		move.l	x_count_buf,d1
oab_bxploop:
		moveq.l	#0,d4
		moveq.l	#0,d5

		move.b	(a6)+,d4				;IntensitÑt
		move.w	0(a3,d4*2.w),d5	;Mit Farbwert multipliziert
		move.l	0(a4,d4*4.l),a5	;Tabelle fÅr (255-IntensitÑt)

		moveq		#0,d4
		move.b	(a2),d4					;Planewert holen
		move.w	0(a5,d4*2.w),d4	;mit (255-IntensitÑt) multiplizieren
		add.w		d5,d4						;Addieren
		move.b	0(a1,d4.l),(a2)+;Quotient (/255) in vorhandenes Byte schreiben

		dbra		d1,oab_bxploop

		adda.l	d2,a2						;Zeilenoffset fÅr Plane
		adda.l	d3,a6						;Zeilenoffset fÅr Pinsel
		dbra		d0,oab_byploop
;end_blue < 8
		movem.l	(sp)+,d0-d3/a1-a6
oaend_blue:
; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			oaend_blue2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a0-a5,-(sp)

		move.l	d0,y_count_buf

		lea			div_tab,a1			;Divisions-Tabelle (x/255) in a1

		lea			mul_adr,a4			;Adressen der x*y-Tabellen
														;fÅr 255-x

		lea			mul_tab,a3					;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_blue,d5				;Zeichenfarbe
		lsl.l		#8,d5						;mul*255-Tabelle fÅr diese Farbe
		lsl.l		#1,d5						;berechnen
		adda.l	d5,a3						;und in a3
		
		add.l		x_rest_buf,a6
		add.l		x_rest_buf,a2
oab2_byploop:
		move.l	x_acht_buf2,x_count_buf
oab2_bxploop:

		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		moveq.l	#0,d4
		moveq.l	#0,d5
		moveq.l	#0,d6
		moveq.l	#0,d7

		move.b	(a6)+,d0				;IntensitÑten holen
		move.b	(a6)+,d1				;IntensitÑten holen
		move.b	(a6)+,d2				;IntensitÑten holen
		move.b	(a6)+,d3				;IntensitÑten holen
		move.b	(a6)+,d4				;IntensitÑten holen
		move.b	(a6)+,d5				;IntensitÑten holen
		move.b	(a6)+,d6				;IntensitÑten holen

.MACRO FLOW_OPQ_B dn
		moveq		#0,d7
		move.w	0(a3,dn*2.w),d7	;Mit Farbwert multipliziert
		move.l	0(a4,dn*4.l),a5	;Tabelle fÅr (255-IntensitÑt)
		moveq		#0,dn
		move.b	(a2),dn					;Planewert holen
		move.w	0(a5,dn*2.w),dn	;mit (255-IntensitÑt) multiplizieren
		add.w		d7,dn						;Addieren
		move.b	0(a1,dn.l),(a2)+	;Quotient (/255) in vorhandenes Byte schreiben
.ENDM

		FLOW_OPQ_B d0
		FLOW_OPQ_B d1
		FLOW_OPQ_B d2
		FLOW_OPQ_B d3
		FLOW_OPQ_B d4
		FLOW_OPQ_B d5
		FLOW_OPQ_B d6
		
;und achten Wert:
		moveq		#0,d6
		move.b	(a6)+,d6
		FLOW_OPQ_B d6

		subq.l	#1,x_count_buf
		bpl			oab2_bxploop
		
		add.l		planeachtdif_buf,a2		;Zeilenoffset fÅr Plane
		add.l		penachtdif_buf,a6			;Zeilenoffset fÅr Pinsel
		subq.l	#1,y_count_buf
		bpl			oab2_byploop
;end_blue > 8
		movem.l	(sp)+,d0-d3/a0-a5
oaend_blue2:
		bra	d_dither




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
		move.b	c_red,d5				;Zeichenfarbe
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


; ** GELB **

		moveq.l	#0,d4
		lea			intensity,a3		;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_yellow,d5			;Zeichenfarbe
		lsl.w		#8,d5						;Tabelle fÅr diese Farbe
		adda.l	d5,a3						;berechnen

;Anteil < 8
		move.l	x_rest_buf,d4
		beq			qoend_yellow
		subq.l	#1,d4
		move.l	d4,x_count_buf
		movem.l	d0-d3,-(sp)
		move.l	a1,-(sp)
		move.l	a5,-(sp)
		
		add.l		x_addacht_buf,d2
		add.l		x_addacht_buf,d3
		
qog_byploop:
		move.l	x_count_buf,d1
qog_bxploop:
		move.b	(a5)+,d4				;Pinseldurchlaû
		beq			next_oyel
		move.b	0(a3,d4.l),(a1)		;Farbwert holen & schreiben
next_oyel:
		addq.l	#1,a1
		dbra		d1,qog_bxploop
		
		adda.l	d2,a1						;Zeilenoffset fÅr Plane
		adda.l	d3,a5						;Zeilenoffset fÅr Pinsel
		dbra		d0,qog_byploop
;end_yellow < 8
		move.l	(sp)+,a5
		move.l	(sp)+,a1
		movem.l	(sp)+,d0-d3
qoend_yellow:
		
; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			qoend_yellow2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a1,-(sp)

		move.l	d0,y_count_buf
		moveq.l	#0,d0
		add.l		x_rest_buf,a5
		add.l		x_rest_buf,a1
qog2_byploop:
		move.l	x_acht_buf2,x_count_buf
qog2_bxploop:

.MACRO	q_opaq_y
.LOCAL	quor_y
		move.b	(a5)+,d0				;Pinseldurchlaû
		beq			quor_y
		move.b	0(a3,d0.w),(a1)	;Farbwert holen
quor_y:
		addq.l	#1,a1
.ENDM		

		q_opaq_y
		q_opaq_y
		q_opaq_y
		q_opaq_y
		q_opaq_y
		q_opaq_y
		q_opaq_y
		q_opaq_y

		subq.l	#1,x_count_buf
		bpl			qog2_bxploop
		
		add.l		planeachtdif_buf,a1		;Zeilenoffset fÅr Plane
		add.l		penachtdif_buf,a5			;Zeilenoffset fÅr Pinsel
		subq.l	#1,y_count_buf
		bpl			qog2_byploop
;end_yellow > 8
		movem.l	(sp)+,d0-d3/a1
qoend_yellow2:


; ** BLAU **

		moveq.l	#0,d4
		lea			intensity,a3		;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_blue,d5				;Zeichenfarbe
		lsl.w		#8,d5						;Tabelle fÅr diese Farbe
		adda.l	d5,a3						;berechnen

;Anteil < 8
		move.l	x_rest_buf,d4
		beq			qoend_blue
		subq.l	#1,d4
		move.l	d4,x_count_buf
		movem.l	d0-d3,-(sp)
		move.l	a2,-(sp)
		move.l	a6,-(sp)
		
		add.l		x_addacht_buf,d2
		add.l		x_addacht_buf,d3
		
qob_byploop:
		move.l	x_count_buf,d1
qob_bxploop:
		move.b	(a6)+,d4				;Pinseldurchlaû
		beq			next_oblue
		move.b	0(a3,d4.l),(a2)		;Farbwert holen und schreiben
next_oblue:
		addq.l	#1,a2
		dbra		d1,qob_bxploop
		
		adda.l	d2,a2						;Zeilenoffset fÅr Plane
		adda.l	d3,a6						;Zeilenoffset fÅr Pinsel
		dbra		d0,qob_byploop
;end_blue < 8
		move.l	(sp)+,a6
		move.l	(sp)+,a2
		movem.l	(sp)+,d0-d3
qoend_blue:
; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			qoend_blue2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a2,-(sp)

		move.l	d0,y_count_buf
		moveq.l	#0,d0
		add.l		x_rest_buf,a6
		add.l		x_rest_buf,a2
qob2_byploop:
		move.l	x_acht_buf2,x_count_buf
qob2_bxploop:

.MACRO	q_opaq_b
.LOCAL	quor_b
		move.b	(a6)+,d0				;Pinseldurchlaû
		beq			quor_b
		move.b	0(a3,d0.w),(a2)	;Farbwert holen
quor_b:
		addq.l	#1,a2
.ENDM		

		q_opaq_b
		q_opaq_b
		q_opaq_b
		q_opaq_b
		q_opaq_b
		q_opaq_b
		q_opaq_b
		q_opaq_b

		subq.l	#1,x_count_buf
		bpl			qob2_bxploop
		
		add.l		planeachtdif_buf,a2		;Zeilenoffset fÅr Plane
		add.l		penachtdif_buf,a6			;Zeilenoffset fÅr Pinsel
		subq.l	#1,y_count_buf
		bpl			qob2_byploop
;end_blue > 8
		movem.l	(sp)+,d0-d3/a2
qoend_blue2:
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
		move.b	c_red,d5				;Zeichenfarbe
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
		move.b	0(a3,d4.l),(a0)+	;Farbwert holen & schreiben
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


; ** GELB **

		moveq.l	#0,d4
		lea			intensity,a3		;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_yellow,d5			;Zeichenfarbe
		lsl.w		#8,d5						;Tabelle fÅr diese Farbe
		adda.l	d5,a3						;berechnen

;Anteil < 8
		move.l	x_rest_buf,d4
		beq			oend_yellow
		subq.l	#1,d4
		move.l	d4,x_count_buf
		movem.l	d0-d3,-(sp)
		move.l	a1,-(sp)
		move.l	a5,-(sp)
		
		add.l		x_addacht_buf,d2
		add.l		x_addacht_buf,d3
		
og_byploop:
		move.l	x_count_buf,d1
og_bxploop:
		move.b	(a5)+,d4				;Pinseldurchlaû
		move.b	0(a3,d4.l),(a1)+		;Farbwert holen & schreiben
		dbra		d1,og_bxploop
		
		adda.l	d2,a1						;Zeilenoffset fÅr Plane
		adda.l	d3,a5						;Zeilenoffset fÅr Pinsel
		dbra		d0,og_byploop
;end_yellow < 8
		move.l	(sp)+,a5
		move.l	(sp)+,a1
		movem.l	(sp)+,d0-d3
oend_yellow:
		
; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			oend_yellow2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a1,-(sp)

		move.l	d0,y_count_buf
		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		moveq.l	#0,d4
		moveq.l	#0,d5
		moveq.l	#0,d6
		moveq.l	#0,d7
		add.l		x_rest_buf,a5
		add.l		x_rest_buf,a1
og2_byploop:
		move.l	x_acht_buf2,x_count_buf
og2_bxploop:
		move.b	(a5)+,d0				;Pinseldurchlaû
		move.b	(a5)+,d1
		move.b	(a5)+,d2
		move.b	(a5)+,d3
		move.b	(a5)+,d4
		move.b	(a5)+,d5
		move.b	(a5)+,d6
		move.b	(a5)+,d7

		move.b	0(a3,d0.w),(a1)+		;Farbwert holen
		move.b	0(a3,d1.w),(a1)+
		move.b	0(a3,d2.w),(a1)+
		move.b	0(a3,d3.w),(a1)+
		move.b	0(a3,d4.w),(a1)+
		move.b	0(a3,d5.w),(a1)+
		move.b	0(a3,d6.w),(a1)+
		move.b	0(a3,d7.w),(a1)+

		subq.l	#1,x_count_buf
		bpl			og2_bxploop
		
		add.l		planeachtdif_buf,a1		;Zeilenoffset fÅr Plane
		add.l		penachtdif_buf,a5			;Zeilenoffset fÅr Pinsel
		subq.l	#1,y_count_buf
		bpl			og2_byploop
;end_yellow > 8
		movem.l	(sp)+,d0-d3/a1
oend_yellow2:


; ** BLAU **

		moveq.l	#0,d4
		lea			intensity,a3		;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_blue,d5				;Zeichenfarbe
		lsl.w		#8,d5						;Tabelle fÅr diese Farbe
		adda.l	d5,a3						;berechnen

;Anteil < 8
		move.l	x_rest_buf,d4
		beq			oend_blue
		subq.l	#1,d4
		move.l	d4,x_count_buf
		movem.l	d0-d3,-(sp)
		move.l	a2,-(sp)
		move.l	a6,-(sp)
		
		add.l		x_addacht_buf,d2
		add.l		x_addacht_buf,d3
		
ob_byploop:
		move.l	x_count_buf,d1
ob_bxploop:
		move.b	(a6)+,d4				;Pinseldurchlaû
		move.b	0(a3,d4.l),(a2)+		;Farbwert holen und schreiben
		dbra		d1,ob_bxploop
		
		adda.l	d2,a2						;Zeilenoffset fÅr Plane
		adda.l	d3,a6						;Zeilenoffset fÅr Pinsel
		dbra		d0,ob_byploop
;end_blue < 8
		move.l	(sp)+,a6
		move.l	(sp)+,a2
		movem.l	(sp)+,d0-d3
oend_blue:
; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			oend_blue2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a2,-(sp)

		move.l	d0,y_count_buf
		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		moveq.l	#0,d4
		moveq.l	#0,d5
		moveq.l	#0,d6
		moveq.l	#0,d7
		add.l		x_rest_buf,a6
		add.l		x_rest_buf,a2
ob2_byploop:
		move.l	x_acht_buf2,x_count_buf
ob2_bxploop:
		move.b	(a6)+,d0				;Pinseldurchlaû
		move.b	(a6)+,d1
		move.b	(a6)+,d2
		move.b	(a6)+,d3
		move.b	(a6)+,d4
		move.b	(a6)+,d5
		move.b	(a6)+,d6
		move.b	(a6)+,d7

		move.b	0(a3,d0.w),(a2)+		;Farbwert holen
		move.b	0(a3,d1.w),(a2)+
		move.b	0(a3,d2.w),(a2)+
		move.b	0(a3,d3.w),(a2)+
		move.b	0(a3,d4.w),(a2)+
		move.b	0(a3,d5.w),(a2)+
		move.b	0(a3,d6.w),(a2)+
		move.b	0(a3,d7.w),(a2)+

		subq.l	#1,x_count_buf
		bpl			ob2_bxploop
		
		add.l		planeachtdif_buf,a2		;Zeilenoffset fÅr Plane
		add.l		penachtdif_buf,a6			;Zeilenoffset fÅr Pinsel
		subq.l	#1,y_count_buf
		bpl			ob2_byploop
;end_blue > 8
		movem.l	(sp)+,d0-d3/a2
oend_blue2:
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
		move.b	c_red,d5				;Zeichenfarbe
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
		add.b		d4,(a0)+					;& addieren
		bcc			next_adred				;Bei öberlauf..
		move.b	#255,-1(a0)				;..Maximalwert schreiben
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


; ** GELB **

		moveq.l	#0,d4
		lea			intensity,a3		;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_yellow,d5			;Zeichenfarbe
		lsl.w		#8,d5						;Tabelle fÅr diese Farbe
		adda.l	d5,a3						;berechnen

;Anteil < 8
		move.l	x_rest_buf,d4
		beq			adend_yellow
		subq.l	#1,d4
		move.l	d4,x_count_buf
		movem.l	d0-d3,-(sp)
		move.l	a1,-(sp)
		move.l	a5,-(sp)
		
		add.l		x_addacht_buf,d2
		add.l		x_addacht_buf,d3
		
adg_byploop:
		move.l	x_count_buf,d1
adg_bxploop:
		move.b	(a5)+,d4				;Pinseldurchlaû
		move.b	0(a3,d4.l),d4		;Farbwert holen 
		add.b		d4,(a1)+				;& schreiben
		bcc			next_adyel			;Falls öberlauf..
		move.b	#255,-1(a1)			;..Maxwert schreiben
next_adyel:
		dbra		d1,adg_bxploop
		
		adda.l	d2,a1						;Zeilenoffset fÅr Plane
		adda.l	d3,a5						;Zeilenoffset fÅr Pinsel
		dbra		d0,adg_byploop
;end_yellow < 8
		move.l	(sp)+,a5
		move.l	(sp)+,a1
		movem.l	(sp)+,d0-d3
adend_yellow:
		
; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			adend_yellow2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a1,-(sp)

		move.l	d0,y_count_buf
		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		moveq.l	#0,d4
		moveq.l	#0,d5
		moveq.l	#0,d6
		moveq.l	#0,d7
		add.l		x_rest_buf,a5
		add.l		x_rest_buf,a1
adg2_byploop:
		move.l	x_acht_buf2,x_count_buf
adg2_bxploop:

		move.b	(a5)+,d0				;Pinseldurchlaû
		move.b	(a5)+,d1				
		move.b	(a5)+,d2				
		move.b	(a5)+,d3				
		move.b	(a5)+,d4				
		move.b	(a5)+,d5				
		move.b	(a5)+,d6				
		move.b	(a5)+,d7				

		move.b	0(a3,d0.w),d0		;Farbwert holen
		move.b	0(a3,d1.w),d1
		move.b	0(a3,d2.w),d2
		move.b	0(a3,d3.w),d3
		move.b	0(a3,d4.w),d4
		move.b	0(a3,d5.w),d5
		move.b	0(a3,d6.w),d6
		move.b	0(a3,d7.w),d7

.MACRO	ad_y_8 dn
.LOCAL	ad_y_0
		add.b		dn,(a1)+				;Auf Ziel addieren
		bcc			ad_y_0					;Falls öberlauf..
		move.b	#255,-1(a1)			;..Maximalwert schreiben
ad_y_0:
.ENDM		

		ad_y_8	d0
		ad_y_8	d1
		ad_y_8	d2
		ad_y_8	d3
		ad_y_8	d4
		ad_y_8	d5
		ad_y_8	d6
		ad_y_8	d7

		subq.l	#1,x_count_buf
		bpl			adg2_bxploop
		
		add.l		planeachtdif_buf,a1		;Zeilenoffset fÅr Plane
		add.l		penachtdif_buf,a5			;Zeilenoffset fÅr Pinsel
		subq.l	#1,y_count_buf
		bpl			adg2_byploop
;end_yellow > 8
		movem.l	(sp)+,d0-d3/a1
adend_yellow2:


; ** BLAU **

		moveq.l	#0,d4
		lea			intensity,a3		;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_blue,d5				;Zeichenfarbe
		lsl.w		#8,d5						;Tabelle fÅr diese Farbe
		adda.l	d5,a3						;berechnen

;Anteil < 8
		move.l	x_rest_buf,d4
		beq			adend_blue
		subq.l	#1,d4
		move.l	d4,x_count_buf
		movem.l	d0-d3,-(sp)
		move.l	a2,-(sp)
		move.l	a6,-(sp)
		
		add.l		x_addacht_buf,d2
		add.l		x_addacht_buf,d3
		
adb_byploop:
		move.l	x_count_buf,d1
adb_bxploop:
		move.b	(a6)+,d4				;Pinseldurchlaû
		move.b	0(a3,d4.l),d4		;Farbwert holen
		add.b		d4,(a2)+				;und addieren
		bcc			next_adblue			;Falls öberlauf..
		move.b	#255,-1(a2)			;..Maxwert schreiben
next_adblue:
		dbra		d1,adb_bxploop
		
		adda.l	d2,a2						;Zeilenoffset fÅr Plane
		adda.l	d3,a6						;Zeilenoffset fÅr Pinsel
		dbra		d0,adb_byploop
;end_blue < 8
		move.l	(sp)+,a6
		move.l	(sp)+,a2
		movem.l	(sp)+,d0-d3
adend_blue:

; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			adend_blue2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a2,-(sp)

		move.l	d0,y_count_buf
		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		moveq.l	#0,d4
		moveq.l	#0,d5
		moveq.l	#0,d6
		moveq.l	#0,d7
		add.l		x_rest_buf,a6
		add.l		x_rest_buf,a2
adb2_byploop:
		move.l	x_acht_buf2,x_count_buf
adb2_bxploop:

		move.b	(a6)+,d0				;Pinseldurchlaû
		move.b	(a6)+,d1				
		move.b	(a6)+,d2				
		move.b	(a6)+,d3				
		move.b	(a6)+,d4				
		move.b	(a6)+,d5				
		move.b	(a6)+,d6				
		move.b	(a6)+,d7				

		move.b	0(a3,d0.w),d0		;Farbwert holen
		move.b	0(a3,d1.w),d1
		move.b	0(a3,d2.w),d2
		move.b	0(a3,d3.w),d3
		move.b	0(a3,d4.w),d4
		move.b	0(a3,d5.w),d5
		move.b	0(a3,d6.w),d6
		move.b	0(a3,d7.w),d7

.MACRO	ad_b_8	dn
.LOCAL	ad_b_0
		add.b		dn,(a2)+				;Farbwert addieren
		bcc			ad_b_0					;Bei öberlauf..
		move.b	#255,-1(a2)			;..Maxwert schreiben
ad_b_0:
.ENDM		

		ad_b_8	d0
		ad_b_8	d1
		ad_b_8	d2
		ad_b_8	d3
		ad_b_8	d4
		ad_b_8	d5
		ad_b_8	d6
		ad_b_8	d7

		subq.l	#1,x_count_buf
		bpl			adb2_bxploop
		
		add.l		planeachtdif_buf,a2		;Zeilenoffset fÅr Plane
		add.l		penachtdif_buf,a6			;Zeilenoffset fÅr Pinsel
		subq.l	#1,y_count_buf
		bpl			adb2_byploop
;end_blue > 8
		movem.l	(sp)+,d0-d3/a2
adend_blue2:
		bra			d_dither
	



;*************
;Aufhellen
;*************



pm_sub:
; ** ROT **

		moveq.l	#0,d4
		lea			intensity,a3		;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_red,d5				;Zeichenfarbe
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


; ** GELB **

		moveq.l	#0,d4
		lea			intensity,a3		;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_yellow,d5			;Zeichenfarbe
		lsl.w		#8,d5						;Tabelle fÅr diese Farbe
		adda.l	d5,a3						;berechnen

;Anteil < 8
		move.l	x_rest_buf,d4
		beq			sbend_yellow
		subq.l	#1,d4
		move.l	d4,x_count_buf
		movem.l	d0-d3,-(sp)
		move.l	a1,-(sp)
		move.l	a5,-(sp)
		
		add.l		x_addacht_buf,d2
		add.l		x_addacht_buf,d3
		
sbg_byploop:
		move.l	x_count_buf,d1
sbg_bxploop:
		move.b	(a5)+,d4				;Pinseldurchlaû
		move.b	0(a3,d4.l),d4		;Farbwert holen 
		sub.b		d4,(a1)+				;& schreiben
		bcc			next_sbyel			;Falls öberlauf..
		move.b	#0,-1(a1)				;..Minwert schreiben
next_sbyel:
		dbra		d1,sbg_bxploop
		
		adda.l	d2,a1						;Zeilenoffset fÅr Plane
		adda.l	d3,a5						;Zeilenoffset fÅr Pinsel
		dbra		d0,sbg_byploop
;end_yellow < 8
		move.l	(sp)+,a5
		move.l	(sp)+,a1
		movem.l	(sp)+,d0-d3
sbend_yellow:
		
; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			sbend_yellow2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a1,-(sp)

		move.l	d0,y_count_buf
		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		moveq.l	#0,d4
		moveq.l	#0,d5
		moveq.l	#0,d6
		moveq.l	#0,d7
		add.l		x_rest_buf,a5
		add.l		x_rest_buf,a1
sbg2_byploop:
		move.l	x_acht_buf2,x_count_buf
sbg2_bxploop:

		move.b	(a5)+,d0				;Pinseldurchlaû
		move.b	(a5)+,d1				
		move.b	(a5)+,d2				
		move.b	(a5)+,d3				
		move.b	(a5)+,d4				
		move.b	(a5)+,d5				
		move.b	(a5)+,d6				
		move.b	(a5)+,d7				

		move.b	0(a3,d0.w),d0		;Farbwert holen
		move.b	0(a3,d1.w),d1
		move.b	0(a3,d2.w),d2
		move.b	0(a3,d3.w),d3
		move.b	0(a3,d4.w),d4
		move.b	0(a3,d5.w),d5
		move.b	0(a3,d6.w),d6
		move.b	0(a3,d7.w),d7

.MACRO	sb_y_8 dn
.LOCAL	sb_y_0
		sub.b		dn,(a1)+				;Abziehen
		bcc			sb_y_0					;Falls öberlauf..
		move.b	#0,-1(a1)				;..Minimalwert schreiben
sb_y_0:
.ENDM		

		sb_y_8	d0
		sb_y_8	d1
		sb_y_8	d2
		sb_y_8	d3
		sb_y_8	d4
		sb_y_8	d5
		sb_y_8	d6
		sb_y_8	d7

		subq.l	#1,x_count_buf
		bpl			sbg2_bxploop
		
		add.l		planeachtdif_buf,a1		;Zeilenoffset fÅr Plane
		add.l		penachtdif_buf,a5			;Zeilenoffset fÅr Pinsel
		subq.l	#1,y_count_buf
		bpl			sbg2_byploop
;end_yellow > 8
		movem.l	(sp)+,d0-d3/a1
sbend_yellow2:


; ** BLAU **

		moveq.l	#0,d4
		lea			intensity,a3		;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_blue,d5				;Zeichenfarbe
		lsl.w		#8,d5						;Tabelle fÅr diese Farbe
		adda.l	d5,a3						;berechnen

;Anteil < 8
		move.l	x_rest_buf,d4
		beq			sbend_blue
		subq.l	#1,d4
		move.l	d4,x_count_buf
		movem.l	d0-d3,-(sp)
		move.l	a2,-(sp)
		move.l	a6,-(sp)
		
		add.l		x_addacht_buf,d2
		add.l		x_addacht_buf,d3
		
sbb_byploop:
		move.l	x_count_buf,d1
sbb_bxploop:
		move.b	(a6)+,d4				;Pinseldurchlaû
		move.b	0(a3,d4.l),d4		;Farbwert holen
		sub.b		d4,(a2)+				;und abziehen
		bcc			next_sbblue			;Falls öberlauf..
		move.b	#0,-1(a2)				;..Minwert schreiben
next_sbblue:
		dbra		d1,sbb_bxploop
		
		adda.l	d2,a2						;Zeilenoffset fÅr Plane
		adda.l	d3,a6						;Zeilenoffset fÅr Pinsel
		dbra		d0,sbb_byploop
;end_blue < 8
		move.l	(sp)+,a6
		move.l	(sp)+,a2
		movem.l	(sp)+,d0-d3
sbend_blue:

; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			sbend_blue2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a2,-(sp)

		move.l	d0,y_count_buf
		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		moveq.l	#0,d4
		moveq.l	#0,d5
		moveq.l	#0,d6
		moveq.l	#0,d7
		add.l		x_rest_buf,a6
		add.l		x_rest_buf,a2
sbb2_byploop:
		move.l	x_acht_buf2,x_count_buf
sbb2_bxploop:

		move.b	(a6)+,d0				;Pinseldurchlaû
		move.b	(a6)+,d1				
		move.b	(a6)+,d2				
		move.b	(a6)+,d3				
		move.b	(a6)+,d4				
		move.b	(a6)+,d5				
		move.b	(a6)+,d6				
		move.b	(a6)+,d7				

		move.b	0(a3,d0.w),d0		;Farbwert holen
		move.b	0(a3,d1.w),d1
		move.b	0(a3,d2.w),d2
		move.b	0(a3,d3.w),d3
		move.b	0(a3,d4.w),d4
		move.b	0(a3,d5.w),d5
		move.b	0(a3,d6.w),d6
		move.b	0(a3,d7.w),d7

.MACRO	sb_b_8	dn
.LOCAL	sb_b_0
		sub.b		dn,(a2)+				;Farbwert abziehen
		bcc			sb_b_0					;Bei öberlauf..
		move.b	#0,-1(a2)				;..Minwert schreiben
sb_b_0:
.ENDM		

		sb_b_8	d0
		sb_b_8	d1
		sb_b_8	d2
		sb_b_8	d3
		sb_b_8	d4
		sb_b_8	d5
		sb_b_8	d6
		sb_b_8	d7

		subq.l	#1,x_count_buf
		bpl			sbb2_bxploop
		
		add.l		planeachtdif_buf,a2		;Zeilenoffset fÅr Plane
		add.l		penachtdif_buf,a6			;Zeilenoffset fÅr Pinsel
		subq.l	#1,y_count_buf
		bpl			sbb2_byploop
;end_blue > 8
		movem.l	(sp)+,d0-d3/a2
sbend_blue2:
		bra			d_dither











;*******************************************
;Proxi-Dither
		sub.l		d4,d4
		sub.l		d5,d5
		move.b	0(a2,d6.l),d5
		lea			b_table, a3
		move.b	0(a3,d5.w),d4
		move.b	0(a1,d6.l),d5
		lea			g_table, a3
		add.b		0(a3,d5.w),d4
		move.b	0(a0,d6.l),d5
		lea			r_table, a3
		add.b		0(a3,d5.w),d4
		add.b		#16,d4
		move.l	p_screen,a3
		move.b	d4,0(a3,d6.l)
;********************************************




		move.l	d0,savreg
		clr.l		d0
		move.b	d4,d0
		bsr			printreg
		move.l	savreg,d0

printreg:
		movem.l	d0-d4/a0,-(sp)
		clr.l			d2
		move.w	d0,d2
		move		#10000,d1
		move	#4,d3
		clr	d4
		lea	buffer,a0
		bra	bd3
bd1:
		divs	#10,d1
		bd2:	swap d2
		bd3:	ext.l	d2
		divs	d1,d2
		add.b	#48,d2
		move.b	d2,(a0)+
		dbra	d3,bd1
		move.b	#10,(a0)+
		move.b	#13,(a0)+
		move.b	#0,(a0)
		
		pea	buffer
		move	#9,-(sp)
		trap	#1
		addq.l	#6,sp
		movem.l	(sp)+,d0-d4/a0
		rts
		
		.BSS
scr_buf:
	.DS.L	1
ydif_buf:
	.DS.L	1
xdif_buf:
	.DS.L	1
x_acht_buf:
	.DS.L	1
x_acht_buf2:
	.DS.L	1
x_rest_buf:
	.DS.L	1
x_addacht_buf:
	.DS.L 1
planedif_buf:
	.DS.L	1
planeachtdif_buf:
	.DS.L	1
pendif_buf:
	.DS.L	1
penachtdif_buf:
	.DS.L	1
x_count_buf:
	.DS.L 1
y_count_buf:
	.DS.L 1


buffer:
	.DS.L 4
zen:
	.DS.W 1
savreg:
	.DS.L 1
sav_sp:
	.DS.L	1

dif_y:
	.DS.L 1
dif_x:
	.DS.L	1
add_screen:
	.DS.L	1
p_red:
	.DS.L	1
p_yellow:
	.DS.L 1
p_blue:
	.DS.L	1
p_screen:
	.DS.L 1
p_mask:
	.DS.L 1
p_edmask:
	.DS.L 1
pen_r:
	.DS.L 1
pen_g:
	.DS.L	1
pen_b:
	.DS.L 1
p_width:
	.DS.L	1
pen_width:
	.DS.L 1
screen_width:
	.DS.L	1


red_list:
	.DS.L	1
yellow_list:
	.DS.L	1
blue_list:
	.DS.L	1
type_list:
	.DS.L	1
	
temp_red:
	.DS.W 1
temp_yellow:
	.DS.W	1
temp_blue:
	.DS.W 1
temp_line:
	.DS.L	1
c_red:
	.DS.B 1
	.EVEN
c_yellow:
	.DS.B 1
	.EVEN
c_blue:
	.DS.B 1
	.EVEN
c_mask:
	.DS.B 1
	.EVEN
	
c_lasur:
  .DS.W 1
c_add:
	.DS.W	1
c_plusminus:
	.DS.W	1
c_qopt:
	.DS.W	1

no_dither:
	.DS.W 1
c_solo:
	.DS.W	1
c_layers:
	.DS.W	1
temp_r:
	.DS.L	1
temp_g:
	.DS.L	1
temp_b:
	.DS.L	2
t_col:
	.DS.W 1
start_x:
	.DS.W 1
start_y:
	.DS.W 1
rel_start_y:
	.DS.W	1
rel_start_x:
	.DS.W	1
end_x:
	.DS.W 1
end_y:
	.DS.W 1
curr_y:
	.DS.W	1
curr_x:
	.DS.W 1
off8_x:
	.DS.W 1
off8_y:
	.DS.W 1

r_table:
	.DS.B	256
g_table:
	.DS.B	256
b_table:
	.DS.B	256
r_dither_table:
	.DS.L	256	
g_dither_table:
	.DS.L	256
b_dither_table:
	.DS.L	256
intensity:
	.DS.B	65536
mul_tab:
	.DS.W	65536
div_tab:
	.DS.B	65536*2
mul_adr:
	.DS.L	256
table_offset:
	.DS.L	1
screen_offset:
	.DS.L	2000
undo_width:
	.DS.W	1
undo_size:
	.DS.W 1
undo_start:
	.DS.L 1
undo_end:
	.DS.L 1
undo_maxend:
	.DS.L	1
undo_ok:
	.DS.W 1
undo_on:
	.DS.W	1
undo_id:
	.DS.W	1

mask_activ:
	.DS.W	1
mask_edit:
	.DS.W 1
	.EVEN	
	
test1:
	.DS.L	1
test2:
	.DS.L	1
	
lsb_c:
	.DS.L 1
lsb_m:
	.DS.L 1
lsb_y:
	.DS.L 1
lsb_used:
	.DS.L 1
lsb_offset:
	.DS.L 1
	
ls_width:
	.DS.L 1
ls_dif:
	.DS.L 1
ls_start_x:
	.DS.W 1
ls_start_y:
	.DS.W 1
ls_end_x:
	.DS.W 1
ls_end_y:
	.DS.W 1	

ls_table:
	.DS.L 1
ls_entry:
	.DS.L 1
	
ls_pbred:
	.DS.L 1
ls_pbyellow:
	.DS.L 1
ls_pbblue:
	.DS.L 1
ls_pbwidth:
	.DS.L 1
ls_pbstart_x:
	.DS.W 1
ls_pbstart_y:
	.DS.W 1
ls_pbend_x:
	.DS.W 1
ls_pbend_y:
	.DS.W 1
ls_pbentry:
	.DS.L 1
