;*******************
;Typ0 Dither, d.h. alle Ebenen in den Listen werden bercksichtigt
;
;*******************

typ0_dither_pre:
;Kommt vom Zeichnen: Stack leeren
		movem.l	(sp)+,d0-d7/a0-a6
		tst.w		c_layers		;Steht berhaupt was an?
		bne			typ0_dither
		rts
		
typ0_dither:
		movem.l	d0-d7/a0-a6,-(sp)
		
;Planes
		move.l	red_list,a0
		move.l	yellow_list,a1
		move.l	blue_list,a2

		
		
		sub.l		d0,d0		;Zeilen-Z„hler
		sub.l		d1,d1		;Spalten-Z„hler
		sub.l		d2,d2		;Planes Zeilendiff
		move.l	p_screen,d6		;Offset fr Screen

		
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
		move.l	d0,temp_line
;und fr Screen
		move.l	screen_width,d0
		sub.l		dif_x,d0
		sub.l		#1,d0
		move.l	d0,add_screen

		move.l	p_width,d1		
		move.l	screen_width,d4

;Startzeilenoffset holen
		sub.l		d0,d0							;Leeren
		sub.l		d1,d1
		move.w	start_x,d1
		move.l	table_offset,a3		;Tabellenadresse
		move.w	start_y,d0				;Offset-Zeilen
		lsl.l		#2,d0							;Mal vier wegen Langwort-Tabelle
		add.l		0(a3,d0.l),d1			;Summe holen & zum x-Offset addieren

oad_red:
		add.l		d1,(a0)+					;und berall aufrechnen
		tst.l		(a0)
		bne			oad_red
oad_yellow:		
		add.l		d1,(a1)+
		tst.l		(a1)
		bne			oad_yellow
oad_blue:
		add.l		d1,(a2)+
		tst.l		(a2)
		bne			oad_blue


		sub.l		d0,d0
		lea			screen_offset,a3	;Tabellenadresse
		move.w	rel_start_y,d0		;Offset-Zeilen auf Screen
		lsl.l		#2,d0							;Mal vier wegen Langwort-Tabelle
		move.l	0(a3,d0.l),d1
		add.l		d1,d6

		sub.l		d0,d0
		move.w	rel_start_x,d0
		add.l		d0,d6
		move.l	d6,scr_buf
		move.l	dif_y,d0

;Dithern
		move.l	scr_buf,a6				;Screenadresse

		lea			r_dither_table,a3
		lea			g_dither_table,a4
		lea			b_dither_table,a5
		
		moveq.l	#0,d5
		moveq.l	#0,d4
		
		move.b	mask_color,d6	;Masken-Farbcode in oberem Word
		swap		d6
		move.w	start_x,d6	;X-Pos holen
		and.w		#7,d6				;Nur 8er-Pos interessant
		move.l	a7,sav_sp
		
t0d_yloop:
		move.l	dif_x,d1
		move.w	curr_y,d5		;Momentane Zeile holen
		and.l		#7,d5				;Nur 8er-Pos interessant
		lsl.w		#3,d5				;Mal 8 (ist Zeile)
		jmp ([t0jmp_tab,d6.w*4])

t0jmp_tab:
		DC.L t0dither_7   ; Zeiger auf Start mit acht durchg„ngen
		DC.L t0dither_6
		DC.L t0dither_5
		DC.L t0dither_4
		DC.L t0dither_3
		DC.L t0dither_2
		DC.L t0dither_1
		DC.L t0dither_0

t0d_xloop:
.MACRO t0dither_x x
.LOCAL tyellow, tblue
.LOCAL rcalc, ropc, rmas, ercalc
.LOCAL ylas, blas, store_all
.LOCAL ymas, bmas
;d7=Rot, d3=Gelb, d2=Blau
;Rot-Wert berechnen 
		moveq		#0,d7
		moveq		#0,d3
		moveq		#0,d2
		move.l	red_list,a0
		move.l	yellow_list,a1
		move.l	blue_list,a2
		move.l	type_list,a7
rcalc:
		tst.w		(a7)+
		bmi			rmas			;Maske
		bne			ropc			;Deckend
;Lasierend
		move.b	([a0]),d4		;Aus Plane holen
		cmp.b		d7,d4			;Mit vorhandenem Wert vergleichen
		bls			ylas			;Ist zu klein
		move.b	d4,d7			;Ist gr”žer->schreiben
ylas:
		move.b	([a1]),d4	;Aus Plane holen
		cmp.b		d3,d4
		bls			blas
		move.b	d4,d3
blas:
		move.b	([a2]),d4
		cmp.b		d2,d4
		bls			ercalc
		move.b	d4,d2
		bra			ercalc

rmas:
;Lasierend (aber nur bei d6-gesetzen Bits)
		btst		#16,d6		;Rot berhaupt sichtbar?
		beq			ymas			;Nein->Gelb prfen
		move.b	([a0]),d4		;Aus Plane holen
		cmp.b		d7,d4			;Mit vorhandenem Wert vergleichen
		bls			ymas			;Ist zu klein
		move.b	d4,d7			;Ist gr”žer->schreiben
ymas:
	  btst		#17,d6		;Gelb sichtbar?
	  beq			bmas			;Nein->blau?
		move.b	([a1]),d4	;Aus Plane holen
		cmp.b		d3,d4
		bls			bmas
		move.b	d4,d3
bmas:
		btst		#18,d6		;Blau sichtbar?
		beq			ercalc		;auch nicht->Ende
		move.b	([a2]),d4
		cmp.b		d2,d4
		bls			ercalc
		move.b	d4,d2
		bra			ercalc

ropc:
;Opaque
;Wenn eines != 0 ist, dann alle schreiben
		tst.b		([a0])		;Aus Plane holen
		bne			store_all	;Ist != 0
		tst.b		([a1])
		bne			store_all
		tst.b		([a2])
		beq			ercalc
store_all:
		move.b	([a0]),d7
		move.b	([a1]),d3
		move.b	([a2]),d2
ercalc:
		addq.l	#1,(a0)+	;Eins auf Adresse addieren
		addq.l	#1,(a1)+	;Eins auf Adresse addieren
		addq.l	#1,(a2)+	;Eins auf Adresse addieren
		tst.l		(a0)			;Ende der Liste?
		bne			rcalc

		move.b	d7,d4									;Rot-Wert holen
		beq			tyellow
		move.l	(a3,d4*4), a7					;Zeiger auf Raster
		move.b	x(a7,d5),d7						;Wert aus Raster
tyellow:
		move.b	d3,d4							;Gelb-Wert holen
		beq			tblue
		move.l	(a4, d4*4), a7
		add.b		x(a7,d5),d7
tblue:
		move.b	d2,d4							;Blau-Wert holen
		move.l	(a5, d4*4), a7
		add.b		x(a7, d5),d7
		addi.b	#16,d7				;d3=16, Farboffset
		move.b	d7,(a6)
		addq.l	#1,a6
		subq.l	#1,d1
.ENDM

t0dither_7: 
		t0dither_x 7
		bmi			t0d_end_x
t0dither_6:
		t0dither_x 6
		bmi			t0d_end_x
t0dither_5:
		t0dither_x 5
		bmi			t0d_end_x
t0dither_4:
		t0dither_x 4
		bmi			t0d_end_x
t0dither_3:
		t0dither_x 3
		bmi			t0d_end_x
t0dither_2:
		t0dither_x 2
		bmi			t0d_end_x
t0dither_1:
		t0dither_x 1
		bmi			t0d_end_x
t0dither_0:
		t0dither_x 0
		bpl			t0d_xloop

t0d_end_x:
		move.l	red_list,a0
		move.l	yellow_list,a1
		move.l	blue_list,a2
		move.l	temp_line,d2
ad_red_:
		add.l		d2,(a0)+
		add.l		d2,(a1)+
		add.l		d2,(a2)+
		tst.l		(a0)
		bne			ad_red_
		
		adda.l	add_screen,a6
		addq.w	#1,curr_y
		dbra		d0,t0d_yloop
t0d_end_all:
		move.l	sav_sp,a7
		movem.l	(sp)+,d0-d7/a0-a6
		rts
