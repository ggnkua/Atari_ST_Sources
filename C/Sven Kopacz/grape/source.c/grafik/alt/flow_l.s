
;Lasur flow

; ** ROT **
	
; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			aend_red2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a0-a6,-(sp)
		move.l	a7,sav_sp

		move.l	d0,y_count_buf

		lea			div_tab,a1			;Divisions-Tabelle (x/255) in a1


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

.MACRO LS_FLOW_RED
		lea			mul_adr,a2			;Adressen der x*y-Tabellen
														;fr 255-x
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

		move.w	0(a3,d0*2.w),d4	;Mit Farbwert multiplizieren
		move.w	0(a3,d1*2.w),d5
		move.w	0(a3,d2*2.w),d6
		move.w	0(a3,d3*2.w),d7
		
		move.l	0(a2,d0*4.l),a7	;Tabelle fr (255-Intensit„t)
		move.l	0(a2,d1*4.l),a6	;Tabelle fr (255-Intensit„t)
		move.l	0(a2,d2*4.l),a5	;Tabelle fr (255-Intensit„t)
		move.l	0(a2,d3*4.l),a2	;Tabelle fr (255-Intensit„t)

		moveq		#0,d0
		moveq		#0,d1
		moveq		#0,d2
		moveq		#0,d3
		
		move.b	(a0),d0
		move.b	1(a0),d1
		move.b	2(a0),d2
		move.b	3(a0),d3
		
		add.w	0(a7,d0*2.w),d4
		add.w	0(a6,d1*2.w),d5
		add.w	0(a5,d2*2.w),d6
		add.w	0(a2,d3*2.w),d7

		move.b	0(a1,d4.l),(a0)+	;Quotient (/255) in vorhandenes Byte schreiben
		move.b	0(a1,d5.l),(a0)+	;Quotient (/255) in vorhandenes Byte schreiben
		move.b	0(a1,d6.l),(a0)+	;Quotient (/255) in vorhandenes Byte schreiben
		move.b	0(a1,d7.l),(a0)+	;Quotient (/255) in vorhandenes Byte schreiben
.ENDM
		
		LS_FLOW_RED
		LS_FLOW_RED



		subq.l	#1,x_count_buf
		bpl			ar2_bxploop
		
		add.l		planeachtdif_buf,a0		;Zeilenoffset fr Plane
		add.l		penachtdif_buf,a4			;Zeilenoffset fr Pinsel
		subq.l	#1,y_count_buf
		bpl			ar2_byploop
;end_red > 8
		move.l	sav_sp,a7
		movem.l	(sp)+,d0-d3/a0-a6
aend_red2:


; ** GELB **

		
; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			aend_yellow2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a0-a6,-(sp)
		move.l	a7,sav_sp

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
.MACRO LS_FLOW_YEL
		lea			mul_adr,a2			;Adressen der x*y-Tabellen
														;fr 255-x
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

		move.w	0(a3,d0*2.w),d4	;Mit Farbwert multiplizieren
		move.w	0(a3,d1*2.w),d5
		move.w	0(a3,d2*2.w),d6
		move.w	0(a3,d3*2.w),d7
		
		move.l	0(a2,d0*4.l),a7	;Tabelle fr (255-Intensit„t)
		move.l	0(a2,d1*4.l),a6	;Tabelle fr (255-Intensit„t)
		move.l	0(a2,d2*4.l),a4	;Tabelle fr (255-Intensit„t)
		move.l	0(a2,d3*4.l),a2	;Tabelle fr (255-Intensit„t)

		moveq		#0,d0
		moveq		#0,d1
		moveq		#0,d2
		moveq		#0,d3
		
		move.b	(a1),d0
		move.b	1(a1),d1
		move.b	2(a1),d2
		move.b	3(a1),d3
		
		add.w	0(a7,d0*2.w),d4
		add.w	0(a6,d1*2.w),d5
		add.w	0(a4,d2*2.w),d6
		add.w	0(a2,d3*2.w),d7

		move.b	0(a0,d4.l),(a1)+	;Quotient (/255) in vorhandenes Byte schreiben
		move.b	0(a0,d5.l),(a1)+	;Quotient (/255) in vorhandenes Byte schreiben
		move.b	0(a0,d6.l),(a1)+	;Quotient (/255) in vorhandenes Byte schreiben
		move.b	0(a0,d7.l),(a1)+	;Quotient (/255) in vorhandenes Byte schreiben
.ENDM
		
		LS_FLOW_YEL
		LS_FLOW_YEL

		subq.l	#1,x_count_buf
		bpl			ag2_bxploop
		
		add.l		planeachtdif_buf,a1		;Zeilenoffset fr Plane
		add.l		penachtdif_buf,a5			;Zeilenoffset fr Pinsel
		subq.l	#1,y_count_buf
		bpl			ag2_byploop
;end_yellow > 8
		move.l	sav_sp,a7
		movem.l	(sp)+,d0-d3/a0-a6
aend_yellow2:


; ** BLAU **


; Anteil > 8
		move.l	x_acht_buf,d4
		subq.l	#1,d4
		bmi			aend_blue2
		move.l	d4,x_acht_buf2
		
		movem.l	d0-d3/a0-a6,-(sp)
		move.l	a7,sav_sp

		move.l	d0,y_count_buf

		lea			div_tab,a1			;Divisions-Tabelle (x/255) in a1

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

.MACRO LS_FLOW_BLUE
		lea			mul_adr,a4			;Adressen der x*y-Tabellen
														;fr 255-x
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

		move.w	0(a3,d0*2.w),d4	;Mit Farbwert multiplizieren
		move.w	0(a3,d1*2.w),d5
		move.w	0(a3,d2*2.w),d6
		move.w	0(a3,d3*2.w),d7
		
		move.l	0(a4,d0*4.l),a7	;Tabelle fr (255-Intensit„t)
		move.l	0(a4,d1*4.l),a5	;Tabelle fr (255-Intensit„t)
		move.l	0(a4,d2*4.l),a0	;Tabelle fr (255-Intensit„t)
		move.l	0(a4,d3*4.l),a4	;Tabelle fr (255-Intensit„t)

		moveq		#0,d0
		moveq		#0,d1
		moveq		#0,d2
		moveq		#0,d3
		
		move.b	(a2),d0
		move.b	1(a2),d1
		move.b	2(a2),d2
		move.b	3(a2),d3
		
		add.w	0(a7,d0*2.w),d4
		add.w	0(a5,d1*2.w),d5
		add.w	0(a0,d2*2.w),d6
		add.w	0(a4,d3*2.w),d7

		move.b	0(a1,d4.l),(a2)+	;Quotient (/255) in vorhandenes Byte schreiben
		move.b	0(a1,d5.l),(a2)+	;Quotient (/255) in vorhandenes Byte schreiben
		move.b	0(a1,d6.l),(a2)+	;Quotient (/255) in vorhandenes Byte schreiben
		move.b	0(a1,d7.l),(a2)+	;Quotient (/255) in vorhandenes Byte schreiben
.ENDM
		
		LS_FLOW_BLUE
		LS_FLOW_BLUE


		subq.l	#1,x_count_buf
		bpl			ab2_bxploop
		
		add.l		planeachtdif_buf,a2		;Zeilenoffset fr Plane
		add.l		penachtdif_buf,a6			;Zeilenoffset fr Pinsel
		subq.l	#1,y_count_buf
		bpl			ab2_byploop
;end_blue > 8
		move.l		sav_sp,a7
		movem.l	(sp)+,d0-d3/a0-a6
aend_blue2:
		bra	d_dither


