; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			aend_red2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a0-a5,-(sp)

		move.l	d0,y_count_buf

		lea			div_tab,a1			;Divisions-Tabelle (x/255) in a1

		lea			mul_adr,a2			;Adressen der x*y-Tabellen
														;fr 255-x

		lea			mul_tab,a3					;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_red,d5				;Zeichenfarbe
		lsl.l		#8,d5						;mul*255-Tabelle fr diese Farbe
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

		move.b	(a4)+,d0				;Intensit„ten holen
		move.b	(a4)+,d1				;Intensit„ten holen
		move.b	(a4)+,d2				;Intensit„ten holen
		move.b	(a4)+,d3				;Intensit„ten holen

		move.b	(a4)+,d4				;Intensit„ten holen
		move.b	(a4)+,d5				;Intensit„ten holen
		move.b	(a4)+,d6				;Intensit„ten holen

.MACRO FLOW_LAS dn
		move.w	0(a3,dn*2.w),d7	;Mit Farbwert multipliziert
		move.l	0(a2,dn*4.l),a5	;Tabelle fr (255-Intensit„t)
		moveq		#0,dn
		move.b	(a0),dn					;Planewert holen
		move.w	0(a5,dn*2.w),dn	;mit (255-Intensit„t) multiplizieren
		add.w		d7,dn						;Addieren
		move.b	0(a1,dn.l),(a0)+	;Quotient (/255) in vorhandenes Byte schreiben
.ENDM

		FLOW_LAS d0
		FLOW_LAS d1
		FLOW_LAS d2
		FLOW_LAS d3
		FLOW_LAS d4
		FLOW_LAS d5
		FLOW_LAS d6
;und achten Wert:
		moveq		#0,d6
		move.b	(a4)+,d6
		FLOW_LAS d6


		subq.l	#1,x_count_buf
		bpl			ar2_bxploop
		
		add.l		planeachtdif_buf,a0		;Zeilenoffset fr Plane
		add.l		penachtdif_buf,a4			;Zeilenoffset fr Pinsel
		subq.l	#1,y_count_buf
		bpl			ar2_byploop
;end_red > 8
		movem.l	(sp)+,d0-d3/a0-a5
aend_red2:



;*****************************************************
;Gelb
; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			aend_yellow2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a0-a5,-(sp)

		move.l	d0,y_count_buf

		lea			div_tab,a0			;Divisions-Tabelle (x/255) in a1

		lea			mul_adr,a2			;Adressen der x*y-Tabellen
														;fr 255-x

		lea			mul_tab,a3			;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_yellow,d5			;Zeichenfarbe
		lsl.l		#8,d5						;mul*255-Tabelle fr diese Farbe
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

		move.b	(a5)+,d0				;Intensit„ten holen
		move.b	(a5)+,d1				;Intensit„ten holen
		move.b	(a5)+,d2				;Intensit„ten holen
		move.b	(a5)+,d3				;Intensit„ten holen
		move.b	(a5)+,d4				;Intensit„ten holen
		move.b	(a5)+,d5				;Intensit„ten holen
		move.b	(a5)+,d6				;Intensit„ten holen

.MACRO FLOW_LAS_Y dn
		moveq		#0,d7
		move.w	0(a3,dn*2.w),d7	;Mit Farbwert multipliziert
		move.l	0(a2,dn*4.l),a4	;Tabelle fr (255-Intensit„t)
		moveq		#0,dn
		move.b	(a1),dn					;Planewert holen
		move.w	0(a4,dn*2.w),dn	;mit (255-Intensit„t) multiplizieren
		add.w		d7,dn						;Addieren
		move.b	0(a0,dn.l),(a1)+	;Quotient (/255) in vorhandenes Byte schreiben
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
		
		add.l		planeachtdif_buf,a1		;Zeilenoffset fr Plane
		add.l		penachtdif_buf,a5			;Zeilenoffset fr Pinsel
		subq.l	#1,y_count_buf
		bpl			ag2_byploop
;end_yellow > 8
		movem.l	(sp)+,d0-d3/a0-a5
aend_yellow2:

;*****************************************************
;Blau

; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			aend_blue2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a0-a5,-(sp)

		move.l	d0,y_count_buf

		lea			div_tab,a1			;Divisions-Tabelle (x/255) in a1

		lea			mul_adr,a4			;Adressen der x*y-Tabellen
														;fr 255-x

		lea			mul_tab,a3					;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_blue,d5				;Zeichenfarbe
		lsl.l		#8,d5						;mul*255-Tabelle fr diese Farbe
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

		move.b	(a6)+,d0				;Intensit„ten holen
		move.b	(a6)+,d1				;Intensit„ten holen
		move.b	(a6)+,d2				;Intensit„ten holen
		move.b	(a6)+,d3				;Intensit„ten holen
		move.b	(a6)+,d4				;Intensit„ten holen
		move.b	(a6)+,d5				;Intensit„ten holen
		move.b	(a6)+,d6				;Intensit„ten holen

.MACRO FLOW_LAS_B dn
		moveq		#0,d7
		move.w	0(a3,dn*2.w),d7	;Mit Farbwert multipliziert
		move.l	0(a4,dn*4.l),a5	;Tabelle fr (255-Intensit„t)
		moveq		#0,dn
		move.b	(a2),dn					;Planewert holen
		move.w	0(a5,dn*2.w),dn	;mit (255-Intensit„t) multiplizieren
		add.w		d7,dn						;Addieren
		move.b	0(a1,dn.l),(a2)+	;Quotient (/255) in vorhandenes Byte schreiben
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
		
		add.l		planeachtdif_buf,a2		;Zeilenoffset fr Plane
		add.l		penachtdif_buf,a6			;Zeilenoffset fr Pinsel
		subq.l	#1,y_count_buf
		bpl			ab2_byploop
;end_blue > 8
		movem.l	(sp)+,d0-d3/a0-a5
aend_blue2:
		bra	d_dither

