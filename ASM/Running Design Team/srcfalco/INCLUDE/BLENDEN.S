
; Ueberblendmodi:
;
;  0 : links nach rechts
;  1 : oben nach unten
;  2 : links nach rechts (jeden 2.), rechts nach links (jeden 2.)
;  3 : links nach rechts (jeden 2.), rechts nach links (jeden 2.) (kariert)
;  4 : oben nach unten (endergebnis kariert)
;  5 : von oben unten fallend

;**************************************

; uebergabeparameter:
; d0: blend-modus

make_blenden
		bsr	calc_xy_pixel

		movea.l	screen_1,a0
		movea.l	screen_2,a1

		lea	make_blenden_routs(pc),a2
		movea.l	(a2,d0.w*4),a2
		jsr	(a2)

		rts

;---

make_blenden_routs
		dc.l	make_blenden_mode_0
		dc.l	make_blenden_mode_1
		dc.l	make_blenden_mode_2
		dc.l	make_blenden_mode_3
		dc.l	make_blenden_mode_4
		dc.l	make_blenden_mode_5


;**************************************
;* make_blenden_mode_0
;**************************************

make_blenden_mode_0

		move.w	screen_x_pixel,d7
		subq.w	#1,d7
		move.w	screen_y_pixel,d6
		subq.w	#1,d6

		moveq	#2,d1
		bsr	make_blenden_mode_0_now

		rts


;**************************************
;* make_blenden_mode_1
;**************************************

make_blenden_mode_1

		move.w	screen_x_pixel,d6
		subq.w	#1,d6
		move.w	screen_y_pixel,d7
		subq.w	#1,d7

		move.w	d7,d3
		lsr.w	#5,d3

		moveq	#0,d2
		move.l	true_offi,d5
mb1_loop
		movea.l	a0,a2
		movea.l	a1,a3
		move.w	d6,d4
mb1_inner_loop
		move.w	(a2)+,(a3)+
		dbra	d4,mb1_inner_loop

		adda.l	d5,a0
		adda.l	d5,a1

		addq.w	#1,d2
		cmp.w	d3,d2
		bne.s	mb1_no_wait
		moveq	#0,d2
		move.l	a0,-(sp)
		bsr	vsync
		movea.l	(sp)+,a0
mb1_no_wait
		dbra	d7,mb1_loop
		
		rts


;**************************************
;* make_blenden_mode_2
;**************************************

make_blenden_mode_2

		move.w	screen_x_pixel,d7
		lsr.w	#1,d7
		subq.w	#1,d7
		move.w	screen_y_pixel,d6
		subq.w	#1,d6

		moveq	#4,d1
		movem.w	d6-d7,-(sp)
		bsr	make_blenden_mode_0_now
		movem.w	(sp)+,d6-d7

		subq.l	#2,a0
		subq.l	#2,a1
		moveq	#-4,d1
		bsr	make_blenden_mode_0_now

		rts


;**************************************
;* make_blenden_mode_3
;**************************************

make_blenden_mode_3

		move.w	screen_x_pixel,d7
		lsr.w	#1,d7
		subq.w	#1,d7
		move.w	screen_y_pixel,d6
		subq.w	#1,d6

		moveq	#4,d1
		movem.w	d6-d7,-(sp)
		moveq	#0,d0
		bsr.s	make_blenden_mode_3_now
		movem.w	(sp)+,d6-d7

		subq.l	#4,a0
		subq.l	#4,a1
		moveq	#-4,d1
		moveq	#1,d0
		bsr.s	make_blenden_mode_3_now

		rts

;---

; a0: screen 1
; a1: screen 2
; d7: anzahl x
; d6: anzahl y
; d1: offset screen
; d0:

make_blenden_mode_3_now

		move.w	d7,d3
		lsr.w	#5,d3
		lsr.w	#1,d6

		moveq	#0,d2
		move.l	true_offi,d5
mb3_loop
		movea.l	a0,a2
		movea.l	a1,a3
		move.w	d6,d4

		tst.w	d0
		beq.s	mb3_mode0

mb3_inner_loop1
		move.w	2(a2),2(a3)
		adda.l	d5,a2
		adda.l	d5,a3
		move.w	(a2),(a3)
		adda.l	d5,a2
		adda.l	d5,a3
		dbra	d4,mb3_inner_loop1
		bra	mb3_mode_made

mb3_mode0
mb3_inner_loop
		move.w	(a2),(a3)
		adda.l	d5,a2
		adda.l	d5,a3
		move.w	2(a2),2(a3)
		adda.l	d5,a2
		adda.l	d5,a3
		dbra	d4,mb3_inner_loop
mb3_mode_made
		adda.w	d1,a0
		adda.w	d1,a1

		addq.w	#1,d2
		cmp.w	d3,d2
		bne.s	mb3_no_wait
		moveq	#0,d2
		movem.l	d0/a0,-(sp)
		bsr	vsync
		movem.l	(sp)+,a0/d0
mb3_no_wait
		dbra	d7,mb3_loop
		
		rts


;---

; a0: screen 1
; a1: screen 2
; d7: anzahl x
; d6: anzahl y
; d1: offset screen

make_blenden_mode_0_now

		move.w	d7,d3
		lsr.w	#5,d3

		moveq	#0,d2
		move.l	true_offi,d5
mb2_loop
		movea.l	a0,a2
		movea.l	a1,a3
		move.w	d6,d4
mb2_inner_loop
		move.w	(a2),(a3)
		adda.l	d5,a2
		adda.l	d5,a3
		dbra	d4,mb2_inner_loop

		adda.w	d1,a0
		adda.w	d1,a1

		addq.w	#1,d2
		cmp.w	d3,d2
		bne.s	mb2_no_wait
		moveq	#0,d2
		move.l	a0,-(sp)
		bsr	vsync
		movea.l	(sp)+,a0
mb2_no_wait
		dbra	d7,mb2_loop
		
		rts


;**************************************
;* make_blenden_mode_4
;**************************************

make_blenden_mode_4

		move.w	screen_x_pixel,d6
		lsr.w	#1,d6
		subq.w	#1,d6
		move.w	screen_y_pixel,d7
		subq.w	#1,d7

		move.w	d7,d3
		lsr.w	#5,d3

		move.l	#$ffff0000,d1
		moveq	#0,d2
		move.l	true_offi,d5
mb4_loop
		movea.l	a0,a2
		movea.l	a1,a3
		move.w	d6,d4
mb4_inner_loop
		move.l	(a2)+,d0
		and.l	d1,d0
		move.l	d0,(a3)+
		dbra	d4,mb4_inner_loop

		adda.l	d5,a0
		adda.l	d5,a1

		addq.w	#1,d2
		cmp.w	d3,d2
		bne.s	mb4_no_wait
		moveq	#0,d2
		move.l	a0,-(sp)
		bsr	vsync
		movea.l	(sp)+,a0
mb4_no_wait
		not.l	d1
		dbra	d7,mb4_loop
		
		rts



;---------------

; bestimmt die physikalische bildschirmaufloesung

calc_xy_pixel
		lea	screen_x_pixel,a0
		tst.w	vga_monitor
		beq.s	cxyp_rgb

	; haben vga_monitor

		tst.w	cinemascope
		beq.s	cxypv_no_cine

		move.w	#160,(a0)
		move.w	#240,2(a0)
		bra.s	cxyp_out

cxypv_no_cine
		move.w	#320,(a0)
		move.w	#240,2(a0)
		bra.s	cxyp_out

cxyp_rgb
		tst.w	cinemascope
		beq.s	cxypr_no_cine

		move.w	#256,(a0)
		tst.w	double_scan
		beq.s	cxyprc_no_double
		
		move.w	#120,2(a0)
		bra.s	cxyp_out
cxyprc_no_double
		move.w	#200,2(a0)
		bra.s	cxyp_out

cxypr_no_cine
		move.w	#320,(a0)
		tst.w	double_scan
		beq.s	cxypr_no_double

		move.w	#120,2(a0)
		bra.s	cxyp_out
cxypr_no_double
		move.w	#240,2(a0)

cxyp_out
		rts


;---------------

screen_x_pixel	dc.w	0
screen_y_pixel	dc.w	0



;**************************************
;* make_blenden_mode_5
;**************************************

make_blenden_mode_5

		jsr	init_vbl_time

		moveq	#0,d0
mbm5_loop	move.w	d0,mbm5_time

		moveq	#3,d7
		movea.l	screen_2,a2
		adda.l	#640*10+10,a2
		jsr	paint_hex

		jsr	vsync
;		bsr.s	mbm5_now

		jsr	find_vbl_time

		move.w	mbm5_time(pc),d0
;		add.w	vbl_time,d0
		addq.w	#1,d0

		cmpi.w	#150,d0
		blt.s	mbm5_loop

		rts

;-----------------------

mbm5_now
		bsr	mbm5_calc_y_start

		move.w	mbm5_y_start(pc),d0
		move.w	mbm5_y_end(pc),d1
		move.w	#-239,d2
		move.w	#239,d3

	; --------------
	; case 1:
	;   nichts ist sichtbar
	; case 2:
	;   ragt oben hinaus
	; case 3:
	;   voll sichtbar
	; case 4:
	;   ragt unten darueber hinaus

		cmp.w	d2,d0
		blt.s	mbm5_c1
		cmp.w	d3,d0
		bgt.s	mbm5_c1
		tst.w	d0
		beq.s	mbm5_c3
		bmi.s	mbm5_c2
		bra.s	mbm5_c4

;-----------------------

mbm5_c1
		movea.l	screen_2,a0
		jsr	clear_black_240

		rts

;-----------------------

mbm5_c2
		add.w	d0,d3
		move.w	d3,d1
		neg.w	d0
		moveq	#0,d2
		bsr	mbm5_paint

		rts

;-----------------------

mbm5_c3
		moveq	#0,d0
		move.w	#239,d1
		moveq	#0,d2
		bsr	mbm5_paint		
		
		rts

;-----------------------

mbm5_c4
		movem.w	d0-d3,-(sp)
		subq.w	#1,d0
		bsr	mbm5_clear
		movem.w	(sp)+,d0-a3

		sub.w	d0,d3
		move.w	d3,d1
		move.w	d0,d2
		moveq	#0,d0
		bsr	mbm5_paint

		rts

;-----------------------

; d0 = anzahl zu loeschender zeilen

mbm5_clear
		movea.l	screen_2,a6
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5
		moveq	#0,d6
		moveq	#0,d7
		suba.l	a0,a0
		suba.l	a1,a1
		suba.l	a2,a2
		suba.l	a3,a3
		suba.l	a4,a4
		suba.l	a5,a5
mbm5c_loop
		movem.l	d1-d7/a0-a5,(a6)
		movem.l	d1-d7/a0-a5,52(a6)
		movem.l	d1-d7/a0-a5,104(a6)
		movem.l	d1-d7/a0-a5,156(a6)
		movem.l	d1-d7/a0-a5,208(a6)
		movem.l	d1-d7/a0-a5,260(a6)
		movem.l	d1-d7/a0-a5,312(a6)
		movem.l	d1-d7/a0-a5,364(a6)
		movem.l	d1-d7/a0-a5,416(a6)
		movem.l	d1-d7/a0-a5,468(a6)
		movem.l	d1-d7/a0-a5,520(a6)
		movem.l	d1-d7/a0-a5,572(a6)
		movem.l	d1-d4,624(a6)

		adda.l	#640,a6
		dbra	d0,mbm5c_loop

		rts

;-----------------------

; d0 = anfangszeile der originalgrafik
; d1 = anzahl (-1) zeilen zu zeichnen
; d2 = anfangszeile bildschirm

mbm5_paint
		movea.l	screen_2,a6
		mulu	#640,d2
		adda.l	d2,a6
		movea.l	screen_1,a5
		mulu	#640,d0
		adda.l	d0,a5
		move.w	d1,d0
mbm5p_loop
		movem.l	(a5),d1-d7/a0-a4
		movem.l	d1-d7/a0-a4,(a6)		
		movem.l	48(a5),d1-d7/a0-a4
		movem.l	d1-d7/a0-a4,48(a6)		
		movem.l	96(a5),d1-d7/a0-a4
		movem.l	d1-d7/a0-a4,96(a6)		
		movem.l	144(a5),d1-d7/a0-a4
		movem.l	d1-d7/a0-a4,144(a6)		
		movem.l	192(a5),d1-d7/a0-a4
		movem.l	d1-d7/a0-a4,192(a6)		
		movem.l	240(a5),d1-d7/a0-a4
		movem.l	d1-d7/a0-a4,240(a6)		
		movem.l	288(a5),d1-d7/a0-a4
		movem.l	d1-d7/a0-a4,288(a6)		
		movem.l	336(a5),d1-d7/a0-a4
		movem.l	d1-d7/a0-a4,336(a6)		
		movem.l	384(a5),d1-d7/a0-a4
		movem.l	d1-d7/a0-a4,384(a6)		
		movem.l	432(a5),d1-d7/a0-a4
		movem.l	d1-d7/a0-a4,432(a6)		
		movem.l	480(a5),d1-d7/a0-a4
		movem.l	d1-d7/a0-a4,480(a6)		
		movem.l	528(a5),d1-d7/a0-a4
		movem.l	d1-d7/a0-a4,528(a6)		
		movem.l	576(a5),d1-d7/a0-a4
		movem.l	d1-d7/a0-a4,576(a6)		
		movem.l	624(a5),d1-d4
		movem.l	d1-d4,624(a6)		

		adda.l	#640,a5
		adda.l	#640,a6
		dbra	d0,mbm5p_loop

		rts

;-----------------------

mbm5_calc_y_start

		move.w	#150,d0
		sub.w	mbm5_time(pc),d0
		cmpi.w	#50,d0
		blt	mbm5cys_cosinus

mbm5cys_parabel
		subi.w	#50,d0
		move.w	d0,d1
		mulu	d1,d0
		lsr.l	#5,d0
		subi.w	#50,d0
		bra	mbm5cys_both

mbm5cys_cosinus
		ext.l	d0
		lsl.l	#7,d0
		divu	#50,d0
		lea	sinus_256_tab,a0
		addi.b	#$40,d0
		move.w	(a0,d0.w*2),d0
		muls	#25,d0
		lsl.l	#2,d0
		swap	d0
		subi.w	#25,d0

mbm5cys_both
		neg.w	d0
		move.w	d0,mbm5_y_start
		move.w	d0,d1
		addi.w	#239,d1
		move.w	d1,mbm5_y_end
		
		rts

;---------------

mbm5_time	dc.w	0
mbm5_y_start	dc.w	0
mbm5_y_end	dc.w	0