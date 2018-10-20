; PENCOPY
; StiftflÑche in Zielpuffer kopieren

		.MC68030
		
.EXPORT	p_red, p_green, p_blue, p_screen, p_width
.EXPORT c_red, c_green, c_blue, c_lasur
.EXPORT	pen_r, pen_g, pen_b
.EXPORT start_x, rel_start_x, start_y, rel_start_y, end_x, end_y
.EXPORT r_table, g_table, b_table
.EXPORT paint_it, intensity, pen_width, screen_width
.EXPORT r_dither_table, g_dither_table, b_dither_table
.EXPORT	table_offset, screen_offset
.EXPORT undo_start, undo_end, undo_buf, undo_maxend
.EXPORT undo_ok
.EXPORT do_dither

paint_it:
		movem.l	d0-d7/a0-a6,-(sp)
		tst.b		undo_ok
		beq			init
;Undo Init:
		move.w	#10,undo_size
		move.l	undo_end,a0
		move.w	#1,(a0)+		;Layer in UndoPuffer schreiben
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
		move.w	#0,undo_width	;undo_width lîschen fÅr Erkennung
ok_h:
		move.w	end_y,d0
		sub.w		start_y,d0
		addq.w	#1,d0
		move.w	d0,(a0)+
		move.l	a0,undo_end
		
;Planes
init:
		move.l	p_red,a0
		move.l	p_green,a1
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
		lea			table_offset,a3		;Tabellenadresse
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
		tst.b		c_lasur		;Lasur zeichnen?
		beq			opaque		;Nein->andere Routine


; ***************
; Undo
; ***************

		tst.b		undo_ok
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

		addq.w	#2,undo_size	;Undopuffer beenden
		move.l	undo_end,a0
		move.w	undo_size,(a0)
		addq.l	#2,undo_end
		
		movem.l	(sp)+,d0/a0-a2
end_undo:
; ***************
; Lasur
; ***************

; ** ROT **

;Anteil < 8
		tst.l		x_rest_buf
		beq			end_red
		movem.l	d0-d3,-(sp)
		move.l	a0,-(sp)
		move.l	a4,-(sp)
		
		add.l		x_addacht_buf,d2
		add.l		x_addacht_buf,d3

		moveq.l	#0,d4
		lea			intensity,a3		;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_red,d5				;Zeichenfarbe
		lsl.w		#8,d5						;Tabelle fÅr diese Farbe
		adda.l	d5,a3						;berechnen
		
r_byploop:
		move.l	x_rest_buf,d1
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
		tst.l		x_acht_buf
		beq			end_red2
;bra	end_red2

		movem.l	d0-d3/a0-a2,-(sp)	;a1=SpaltenzÑhler, a2=ZeilenzÑhler

		move.l	d0,a2
		add.l		x_rest_buf,a4
		add.l		x_rest_buf,a0
r2_byploop:
		move.l	x_acht_buf,a1
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

		subq.l	#1,a1
		bpl			r2_bxploop
		
		add.l		planeachtdif_buf,a0		;Zeilenoffset fÅr Plane
		add.l		penachtdif_buf,a4			;Zeilenoffset fÅr Pinsel
		subq.l	#1,a2
		bpl			r2_byploop
;end_red < 8
		movem.l	(sp)+,d0-d3/a0-a2
end_red2:


; ** GRöN **

		move.l	d0,-(sp)
		move.l	a1,-(sp)

		moveq.l	#0,d4
		lea			intensity,a3		;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_green,d5			;Zeichenfarbe
		lsl.w		#8,d5						;Tabelle fÅr diese Farbe
		adda.l	d5,a3						;berechnen
		
g_byploop:
		move.l	dif_x,d1
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
;end_green
		move.l	(sp)+,a1
		move.l	(sp)+,d0


; ** BLAU **

		move.l	d0,-(sp)
		move.l	a2,-(sp)

		moveq.l	#0,d4
		lea			intensity,a3		;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_blue,d5			;Zeichenfarbe
		lsl.w		#8,d5						;Tabelle fÅr diese Farbe
		adda.l	d5,a3						;berechnen
		
b_byploop:
		move.l	dif_x,d1
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
;end_blue
		move.l	(sp)+,a2
		move.l	(sp)+,d0


;*** DITHER ***
d_dither:

		move.l	scr_buf,a6				;Screenadresse
		moveq.l	#16,d3

		lea			r_dither_table,a3
		lea			g_dither_table,a4
		lea			b_dither_table,a5
		
		moveq.l	#0,d5
		moveq.l	#0,d4
		
		move.w	start_x,d6	;X-Pos holen
		and.w		#7,d6				;Nur 8er-Pos interessant
		move.l	a7,sav_sp
		
d_yloop:
		move.l	dif_x,d1
		move.w	curr_y,d5		;Momentane Zeile holen
		and.w		#7,d5				;Nur 8er-Pos interessant
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
dither_7:
		move.b	(a0)+,d4							;Rot-Wert holen
		move.l	(a3,d4*4), a7
		move.b	7(a7,d5),d7
;		move.b	([a3,d4*4],7,d5) ,d7		;Aus Ditherraster holen
		move.b	(a1)+,d4							;GrÅn-Wert holen
		move.l	(a4, d4*4), a7
		add.b		7(a7,d5),d7
;		add.b		([a4,d4*4],7,d5),d7		;Aus Ditherraster holen
		move.b	(a2)+,d4							;Blau-Wert holen
		move.l	(a5, d4*4), a7
		add.b		7(a7, d5),d7
;		add.b		([a5,d4*4],7,d5),d7		;Aus Ditherraster holen
		add.b		d3,d7				;d3=16, Farboffset
		move.b	d7,(a6)+		;Und ab in den Screen
		subq.l	#1,d1
		bmi			d_end_x
dither_6:
		move.b	(a0)+,d4							;Rot-Wert holen
		move.l	(a3,d4*4), a7
		move.b	6(a7,d5),d7
;		move.b	([a3,d4*4],6,d5) ,d7		;Aus Ditherraster holen
		move.b	(a1)+,d4							;GrÅn-Wert holen
		move.l	(a4, d4*4), a7
		add.b		6(a7,d5),d7
;		add.b		([a4,d4*4],6,d5),d7		;Aus Ditherraster holen
		move.b	(a2)+,d4							;Blau-Wert holen
		move.l	(a5, d4*4), a7
		add.b		6(a7, d5),d7
;		add.b		([a5,d4*4],6,d5),d7		;Aus Ditherraster holen
		add.b		d3,d7				;d3=16, Farboffset
		move.b	d7,(a6)+		;Und ab in den Screen
		subq.l	#1,d1
		bmi			d_end_x
dither_5:
		move.b	(a0)+,d4							;Rot-Wert holen
		move.l	(a3,d4*4), a7
		move.b	5(a7,d5),d7
;		move.b	([a3,d4*4],5,d5) ,d7		;Aus Ditherraster holen
		move.b	(a1)+,d4							;GrÅn-Wert holen
		move.l	(a4, d4*4), a7
		add.b		5(a7,d5),d7
;		add.b		([a4,d4*4],5,d5),d7		;Aus Ditherraster holen
		move.b	(a2)+,d4							;Blau-Wert holen
		move.l	(a5, d4*4), a7
		add.b		5(a7, d5),d7
;		add.b		([a5,d4*4],5,d5),d7		;Aus Ditherraster holen
		add.b		d3,d7				;d3=16, Farboffset
		move.b	d7,(a6)+		;Und ab in den Screen
		subq.l	#1,d1
		bmi			d_end_x
dither_4:
		move.b	(a0)+,d4							;Rot-Wert holen
		move.l	(a3,d4*4), a7
		move.b	4(a7,d5),d7
;		move.b	([a3,d4*4],4,d5) ,d7		;Aus Ditherraster holen
		move.b	(a1)+,d4							;GrÅn-Wert holen
		move.l	(a4, d4*4), a7
		add.b		4(a7,d5),d7
;		add.b		([a4,d4*4],4,d5),d7		;Aus Ditherraster holen
		move.b	(a2)+,d4							;Blau-Wert holen
		move.l	(a5, d4*4), a7
		add.b		4(a7, d5),d7
;		add.b		([a5,d4*4],4,d5),d7		;Aus Ditherraster holen
		add.b		d3,d7				;d3=16, Farboffset
		move.b	d7,(a6)+		;Und ab in den Screen
		subq.l	#1,d1
		bmi			d_end_x
dither_3:
		move.b	(a0)+,d4							;Rot-Wert holen
		move.l	(a3,d4*4), a7
		move.b	3(a7,d5),d7
;		move.b	([a3,d4*4],3,d5) ,d7		;Aus Ditherraster holen
		move.b	(a1)+,d4							;GrÅn-Wert holen
		move.l	(a4, d4*4), a7
		add.b		3(a7,d5),d7
;		add.b		([a4,d4*4],3,d5),d7		;Aus Ditherraster holen
		move.b	(a2)+,d4							;Blau-Wert holen
		move.l	(a5, d4*4), a7
		add.b		3(a7, d5),d7
;		add.b		([a5,d4*4],3,d5),d7		;Aus Ditherraster holen
		add.b		d3,d7				;d3=16, Farboffset
		move.b	d7,(a6)+		;Und ab in den Screen
		subq.l	#1,d1
		bmi			d_end_x
dither_2:
		move.b	(a0)+,d4							;Rot-Wert holen
		move.l	(a3,d4*4), a7
		move.b	2(a7,d5),d7
;		move.b	([a3,d4*4],2,d5) ,d7		;Aus Ditherraster holen
		move.b	(a1)+,d4							;GrÅn-Wert holen
		move.l	(a4, d4*4), a7
		add.b		2(a7,d5),d7
;		add.b		([a4,d4*4],2,d5),d7		;Aus Ditherraster holen
		move.b	(a2)+,d4							;Blau-Wert holen
		move.l	(a5, d4*4), a7
		add.b		2(a7, d5),d7
;		add.b		([a5,d4*4],2,d5),d7		;Aus Ditherraster holen
		add.b		d3,d7				;d3=16, Farboffset
		move.b	d7,(a6)+		;Und ab in den Screen
		subq.l	#1,d1
		bmi			d_end_x
dither_1:
		move.b	(a0)+,d4							;Rot-Wert holen
		move.l	(a3,d4*4), a7
		move.b	1(a7,d5),d7
;		move.b	([a3,d4*4],1,d5) ,d7		;Aus Ditherraster holen
		move.b	(a1)+,d4							;GrÅn-Wert holen
		move.l	(a4, d4*4), a7
		add.b		1(a7,d5),d7
;		add.b		([a4,d4*4],1,d5),d7		;Aus Ditherraster holen
		move.b	(a2)+,d4							;Blau-Wert holen
		move.l	(a5, d4*4), a7
		add.b		1(a7, d5),d7
;		add.b		([a5,d4*4],1,d5),d7		;Aus Ditherraster holen
		add.b		d3,d7				;d3=16, Farboffset
		move.b	d7,(a6)+		;Und ab in den Screen
		subq.l	#1,d1
		bmi			d_end_x
dither_0:
		move.b	(a0)+,d4							;Rot-Wert holen
		move.l	(a3,d4*4), a7
		move.b	(a7,d5),d7
;		move.b	([a3,d4*4],d5) ,d7		;Aus Ditherraster holen
		move.b	(a1)+,d4							;GrÅn-Wert holen
		move.l	(a4, d4*4), a7
		add.b		(a7,d5),d7
;		add.b		([a4,d4*4],d5),d7		;Aus Ditherraster holen
		move.b	(a2)+,d4							;Blau-Wert holen
		move.l	(a5, d4*4), a7
		add.b		(a7, d5),d7
;		add.b		([a5,d4*4],d5),d7		;Aus Ditherraster holen
		add.b		d3,d7				;d3=16, Farboffset
		move.b	d7,(a6)+		;Und ab in den Screen
		subq.l	#1,d1
		bpl			d_xloop

d_end_x:
		adda.l	d2,a0
		adda.l	d2,a1
		adda.l	d2,a2
		adda.l	add_screen,a6
		addq.w	#1,curr_y
		dbra		d0,d_yloop

		move.l	sav_sp,a7
d_end_all:
		movem.l	(sp)+,d0-d7/a0-a6
		rts









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

; *************
; Opaque
; *************
opaque:
byploop1:
		move.l	dif_x,d1
		move.w	start_x, curr_x
bxploop1:
;Undo
		tst.b		undo_ok
		beq			op_0
		move.l	undo_end,a3
		move.b	(a0),(a3)+
		move.b	(a1),(a3)+
		move.b	(a2),(a3)+
		move.l	a3,undo_end
op_0:
;Opaque
		lea			intensity,a3
		sub.l		d4,d4
		move.b	(a4)+,d4				;Pinsel-Rot durchlaû
		beq			op1
		lsl.w		#8,d4					;Tabellennummer
		add.b		c_red,d4			;Tabellenindex
		move.b	0(a3,d4.l),(a0)		;Farbwert holen & schreiben

op1:
		sub.l		d4,d4
		move.b	(a5)+,d4				;Pinsel-GrÅn durchlaû
		beq			op2
		lsl.w		#8,d4					;Tabellennummer
		add.b		c_green,d4		;Tabellenindex
		move.b	0(a3,d4.l),(a1)		;Farbwert holen & schreiben

op2:	
		sub.l		d4,d4
		move.b	(a6)+,d4				;Pinsel-Blau durchlaû
		beq			op3
		lsl.w		#8,d4					;Tabellennummer
		add.b		c_blue,d4			;Tabellenindex
		move.b	0(a3,d4.l),(a2)		;Farbwert holen & schreiben
op3:		
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
		dbra		d1,bxploop1

		adda.l	d2,a0
		adda.l	d2,a1
		adda.l	d2,a2
		adda.l	d3,a4
		adda.l	d3,a5
		adda.l	d3,a6
		move.w	undo_width,d4
		beq			undo_cont1
		add.w		d4,undo_size
undo_cont1:
		add.l		add_screen,d6
		addq.w	#1,curr_y
		dbra		d0,byploop1

		tst.b		undo_ok
		beq			end_paint1

		addq.w	#2,undo_size	;Undo-Puffer beenden
		move.l	undo_end,a0
		move.w	undo_size,(a0)
		addq.l	#2,undo_end

end_paint1:
		movem.l	(sp)+,d0-d7/a0-a6
		rts




;****************
; 8-Bit Dither
;****************

do_dither:
		movem.l	d0-d7/a0-a6,-(sp)
		
;Planes
		move.l	p_red,a0
		move.l	p_green,a1
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
;und fÅr Pinsel
		move.l	pen_width,d0
		sub.l		dif_x,d0
		sub.l		#1,d0
		move.l	d0,d3
;und fÅr Screen
		move.l	screen_width,d0
		sub.l		dif_x,d0
		sub.l		#1,d0
		move.l	d0,add_screen

		move.l	p_width,d1		
		move.l	screen_width,d4

;Startzeilenoffset holen
		sub.l		d0,d0							;Leeren
		lea			table_offset,a3		;Tabellenadresse
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
buf_count:
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
p_green:
	.DS.L 1
p_blue:
	.DS.L	1
p_screen:
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
c_red:
	.DS.L 1
c_green:
	.DS.L 1
c_blue:
	.DS.L 1
c_lasur:
  .DS.B 2
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
	.DS.L	65536
table_offset:
	.DS.L	32768
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
	.DS.B 1
	.DS.B 1