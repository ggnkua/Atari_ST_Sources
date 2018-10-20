byploop1:
		move.l	dif_x,d1
		move.w	start_x, curr_x
bxploop1:
;Undo
		tst.b		undo_ok
		beq			op_0
		tst.b		undo_on
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
		add.b		c_yellow,d4		;Tabellenindex
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
		tst.b		undo_on
		beq			end_paint1
		
		addq.w	#2,undo_size	;Undo-Puffer beenden
		move.l	undo_end,a0
		move.w	undo_size,(a0)
		addq.l	#2,undo_end

end_paint1:
		movem.l	(sp)+,d0-d7/a0-a6
		rts
