;*********************************
;* zeichenroutine (c) 1994-1996
;*********************************

; version 6.0 (w) 31. mai 1996
; - versionen fuer verschiedene line_offsets

; version 5.0 (w) 12. april 1996
; - alles nach mike's schema optimiert - jetzt ist
;   nichts mehr rauszuholen ...

; version 3.0 (w) symposium 1996
; - paint_full optimiert (mike's version)

; version 2.0 (w) 1. april 1996
; - paint_double_x optimiert (meine version)


paint320
                tst.w   dsp_error_flag
                beq.s   dsp_data_ok320
no_paint320:
                movea.l play_dat_ptr,A6
                move.w  pd_width(A6),pd_width_last(A6)
                move.w  pd_heigth(A6),pd_heigth_last(A6)
                move.w  pd_x_flag(A6),pd_x_flag_last(A6)

                rts

dsp_data_ok320:
                tst.w   karte_flag
                bne.s   no_paint320

                movea.l play_dat_ptr,A6

                lea     dsp_puffer,A0
                movea.l screen_1(PC),A1
                adda.w  pd_paint_x_offi(A6),A1

;berechnet wird die y-zeile, wo das bild anfaengt ...

                move.w  pd_heigth_last(A6),D0
                move.w  ywindow_max,D1
                sub.w   D0,D1
                bpl.s   yoffi_ok320
                moveq   #0,D1
yoffi_ok320:       lsr.w   #1,D1
                mulu    #320,D1
                adda.l  D1,A1

                move.w  pd_x_flag_last(A6),D0
                move.w  pd_x_flag(A6),pd_x_flag_last(A6)
                btst    #0,D0
                bne     paint_double_x320
               
;**************************************
;* full detail
;**************************************
              
paint_full320:
                move.w  pd_width_last(A6),D0
                move.w  D0,D1
                add.w   D1,D1
                move.w  xwindow_max,D2
                sub.w   D0,D2
                add.w   D2,D1
                adda.w  D1,A1
                move.l  A1,screen


; normale texturen ********************

                subq.w  #1,D0                     ;schleifenzaehler (anzahl strahlen)

		lea	truecolor_tab,a3
		lea	dith_data,a6

paint_loop320:
                subq.l  #2,A1                     ;naechster strahl

strahl_loop320:
                move.l  (A0)+,D1                  ;anzahl zu zeichnender pixel holen
                cmpi.w  #$FFFF,D1                 ;wenn negativ, dann ist dieser
                beq	next_full_go_on320           ;strahl fertig, ab zum naechsten

                movea.l A1,A2
                adda.l  (A0)+,A2                  ;y-offset screenadresse (strahlenweise)
		movea.l	a6,a4
                adda.l  (A0)+,A4                  ;textur-offset
                move.l  (A0)+,D4                  ;zoomfaktor (HI=vork./LOW=nachk.)
                move.l  (A0)+,D5                  ;zoom-offset (anfangsnachkomma) im LOW
		movea.l	a3,a5
                adda.l  (A0)+,A5                  ;truec_offset


		move.w	d1,d2
		lsr.w	#3,d2
		beq	scan_textur_max8320

		andi.w	#$0007,d1

		subq.w	#1,d2

		add.w	d4,d5
                swap    D5                        ;anfangsnachkomma ins HI
                swap    D4                        ;vor-/nachkomma vertauschen

scan_textur_8320
                move.w  0(a4,d5.w*2),d7
		addx.l	d4,d5
                move.w  0(a5,d7.w*2),(a2)


offset		set	-320
		rept	7
                move.w  0(a4,d5.w*2),d7
		addx.l	d4,d5
                move.w  0(a5,d7.w*2),offset(a2)
offset		set	offset-320
		endr

		lea	-8*320(a2),a2

		dbra	d2,scan_textur_8320

scan_textur320
                move.w  0(a4,d5.w*2),d7
		addx.l	d4,d5
                move.w  0(a5,d7.w*2),(a2)
                lea     -320(A2),A2
		dbra    D1,scan_textur320

                bra	strahl_loop320               ;und zur naechsten textur des strahls

next_full_go_on320:
                dbra    D0,paint_loop320             ;zum naechsten strahl
		bra	paint_full_boden320

scan_textur_max8320
		add.w	d4,d5
                swap    D5                        ;anfangsnachkomma ins HI
                swap    D4                        ;vor-/nachkomma vertauschen

scan_textur_max8_loop320
                move.w  0(a4,d5.w*2),d7
		addx.l	d4,d5
                move.w  0(a5,d7.w*2),(a2)
                lea     -320(A2),A2
		dbra    D1,scan_textur_max8_loop320

                bra	strahl_loop320               ;und zur naechsten textur des strahls
                dbra    D0,paint_loop320             ;zum naechsten strahl

; boden und decke *********************

paint_full_boden320

		movea.l	play_dat_ptr,a6
                move.w  pd_width_last(A6),D0
                subq.w  #1,D0                     ;d0 ist wieder der schleifenzaehler

                movea.l screen,A1             	  ;screenadresse des ersten strahls
                movea.l boden_col_ptr,A3

paint_boden_loop320:
                subq.l  #2,A1

strahl_boden_loop320:
                move.l  (A0)+,D1                  ;anzahl zu zeichnender pixel
                cmpi.w  #$FFFF,D1                 ;wenn negativ, ... (wie bekannt)
                beq.s   next_full_go_on_boden320

                movea.l A1,A2

                adda.l  (A0)+,A2                  ;y-offset screenadresse (strahlenweise)
                move.l  (A0)+,D3                  ;farbwert
                move.w  0(A3,D3.w*4),D5
		move.w	d1,d2
		lsr.w	#3,d2
		beq	scan_boden320

		subq.w	#1,d2

scan_boden_8320
		move.w	d5,(a2)
		move.w	d5,-320(a2)
		move.w	d5,-2*320(a2)
		move.w	d5,-3*320(a2)
		move.w	d5,-4*320(a2)
		move.w	d5,-5*320(a2)
		move.w	d5,-6*320(a2)
		move.w	d5,-7*320(a2)
		lea	-8*320(a2),a2
		dbra	d2,scan_boden_8320

		andi.w	#%111,d1
scan_boden320:
                move.w  D5,(A2)
                lea     -320(A2),A2

                dbra    D1,scan_boden320

                bra.s   strahl_boden_loop320

next_full_go_on_boden320:
                dbra    D0,paint_boden_loop320


; maskierte texturen ******************

		movea.l	play_dat_ptr,a6
                move.w  pd_width_last(A6),D0
                subq.w  #1,D0

                movea.l screen,A1

		lea	dith_data,a6
		lea	truecolor_tab,a3

paint_mask_loop320
                subq.l  #2,A1

strahl_loop_m320
                move.l  (A0)+,D1
                cmpi.w  #$FFFF,D1
                beq	next_mask_go_on_m320

                movea.l A1,A2
                adda.l  (A0)+,A2
		movea.l	a6,a4
                adda.l  (A0)+,A4
                move.l  (A0)+,D4
                move.l  (A0)+,D5
                movea.l	a3,a5
                adda.l  (A0)+,A5


		move.w	d1,d2
		lsr.w	#3,d2
		beq	scan_textur_max8_m320

		andi.w	#$0007,d1

		subq.w	#1,d2

		add.w	d4,d5
                swap    D5                        ;anfangsnachkomma ins HI
                swap    D4                        ;vor-/nachkomma vertauschen

scan_textur_8_m320
                move.w  0(a4,d5.w*2),d7
		beq.s	*+6
                move.w  0(a5,d7.w*2),(a2)
		addx.l	d4,d5

offset		set	-320
		rept	7
                move.w  0(a4,d5.w*2),d7
		beq.s	*+8
                move.w  0(a5,d7.w*2),offset(a2)
		addx.l	d4,d5
offset		set	offset-320
		endr

		lea	-8*320(a2),a2

		dbra	d2,scan_textur_8_m320

scan_textur_m320
                move.w  0(a4,d5.w*2),d7
		beq.s	*+6
                move.w  0(a5,d7.w*2),(a2)
		addx.l	d4,d5
                lea     -320(A2),A2

		dbra    D1,scan_textur_m320

                bra	strahl_loop_m320            ;und zur naechsten textur des strahls

next_mask_go_on_m320
                dbra    D0,paint_mask_loop320
		bra	paint_mask_end320

scan_textur_max8_m320
		add.w	d4,d5
                swap    D5                        ;anfangsnachkomma ins HI
                swap    D4                        ;vor-/nachkomma vertauschen

scan_textur_max8_loop_m320
                move.w  0(a4,d5.w*2),d7
		beq.s	*+6
                move.w  0(a5,d7.w*2),(a2)
		addx.l	d4,d5
                lea     -320(A2),A2
		dbra    D1,scan_textur_max8_loop_m320

                bra	strahl_loop_m320             ;und zur naechsten textur des strahls

paint_mask_end320

		movea.l	play_dat_ptr,a6
                move.w  pd_width(A6),pd_width_last(A6)
                move.w  pd_heigth(A6),pd_heigth_last(A6)

                rts


;**************************************
;**************************************
;**************************************
;**************************************

paint_double_x320
                move.w  pd_width_last(A6),D0
                move.w  D0,D1
                add.w   D1,D1
                move.w  xwindow_max,D2
                sub.w   D0,D2
                add.w   D2,D1
                adda.w  D1,A1
                move.l  A1,screen_x


; normale texturen ********************

		lsr.w	#1,d0
                subq.w  #1,d0                     ;schleifenzaehler (anzahl strahlen)

		lea	truecolor_tab,a3
		lea	dith_data,a6

paint_loop_x320
                subq.l  #4,A1                     ;naechster strahl

strahl_loop_x320
                move.l  (A0)+,D1                  ;anzahl zu zeichnender pixel holen
                cmpi.w  #$FFFF,D1                 ;wenn negativ, dann ist dieser
                beq	next_full_go_on_x320         ;strahl fertig, ab zum naechsten

                movea.l A1,A2
                adda.l  (A0)+,A2                  ;y-offset screenadresse (strahlenweise)
		movea.l	a6,a4
                adda.l  (A0)+,A4                  ;textur-offset
                move.l  (A0)+,D4                  ;zoomfaktor (HI=vork./LOW=nachk.)
                move.l  (A0)+,D5                  ;zoom-offset (anfangsnachkomma) im LOW
                movea.l	a3,a5
                adda.l  (A0)+,A5                  ;truec_offset


		move.w	d1,d2
		lsr.w	#3,d2
		beq	scan_textur_max8_x320

		andi.w	#$0007,d1

		subq.w	#1,d2

		add.w	d4,d5
                swap    D5                        ;anfangsnachkomma ins HI
                swap    D4                        ;vor-/nachkomma vertauschen

scan_textur_8_x320
                move.w  0(a4,d5.w*2),d7
		addx.l	d4,d5
                move.l  0(a5,d7.w*2),(a2)

offset		set	-320
		rept	7
                move.w  0(a4,d5.w*2),d7
		addx.l	d4,d5
                move.l  0(a5,d7.w*2),offset(a2)
offset		set	offset-320
		endr

		lea	-8*320(a2),a2

		dbra	d2,scan_textur_8_x320

scan_textur_x320
                move.w  0(a4,d5.w*2),d7
		addx.l	d4,d5
                move.l  0(a5,d7.w*2),(a2)
                lea     -320(A2),A2

		dbra    D1,scan_textur_x320

                bra	strahl_loop_x320             ;und zur naechsten textur des strahls

next_full_go_on_x320
                dbra    D0,paint_loop_x320           ;zum naechsten strahl
		bra	paint_full_boden_x320

scan_textur_max8_x320
		add.w	d4,d5
                swap    D5                        ;anfangsnachkomma ins HI
                swap    D4                        ;vor-/nachkomma vertauschen

scan_textur_max8_loop_x320
                move.w  0(a4,d5.w*2),d7
		addx.l	d4,d5
                move.l  0(a5,d7.w*2),(a2)
                lea     -320(A2),A2
		dbra    D1,scan_textur_max8_loop_x320

                bra	strahl_loop_x320             ;und zur naechsten textur des strahls
                dbra    D0,paint_loop_x320           ;zum naechsten strahl

; boden und decke *********************

paint_full_boden_x320

		movea.l	play_dat_ptr,a6
                move.w  pd_width_last(A6),D0
		lsr.w	#1,d0
                subq.w  #1,D0                     ;d0 ist wieder der schleifenzaehler

                movea.l screen_x,A1             	  ;screenadresse des ersten strahls
                movea.l boden_col_ptr,A3

paint_boden_loop_x320
                subq.l  #4,A1

strahl_boden_loop_x320
                move.l  (A0)+,D1                  ;anzahl zu zeichnender pixel
                cmpi.w  #$FFFF,D1                 ;wenn negativ, ... (wie bekannt)
                beq.s   next_full_go_on_boden_x320

                movea.l A1,A2

                adda.l  (A0)+,A2                  ;y-offset screenadresse (strahlenweise)
                move.l  (A0)+,D3                  ;farbwert

                move.l  0(A3,D3.w*4),D5

		move.w	d1,d2
		lsr.w	#3,d2
		beq	scan_boden_x320

		subq.w	#1,d2

scan_boden_8_x320
		move.l	d5,(a2)
		move.l	d5,-320(a2)
		move.l	d5,-2*320(a2)
		move.l	d5,-3*320(a2)
		move.l	d5,-4*320(a2)
		move.l	d5,-5*320(a2)
		move.l	d5,-6*320(a2)
		move.l	d5,-7*320(a2)
		lea	-8*320(a2),a2
		dbra	d2,scan_boden_8_x320

		andi.w	#%111,d1
scan_boden_x320
                move.l  D5,(A2)
                lea     -320(A2),A2

                dbra    D1,scan_boden_x320

                bra.s   strahl_boden_loop_x320

next_full_go_on_boden_x320
                dbra    D0,paint_boden_loop_x320


; maskierte texturen ******************

		ifne	time_debug
		move.l	timer_a_count,-(sp)
		endc

		movea.l	play_dat_ptr,a6
                move.w  pd_width_last(A6),D0
                lsr.w   #1,D0
                subq.w  #1,D0

                movea.l screen_x,A1

		lea	truecolor_tab,a3
		lea	dith_data,a6

paint_mask_loop_x320
                subq.l  #4,A1

strahl_loop_mx320
                move.l  (A0)+,D1
                cmpi.w  #$FFFF,D1
                beq	next_mask_go_on_x320

                movea.l A1,A2
                adda.l  (A0)+,A2
		movea.l	a6,a4
                adda.l  (A0)+,A4
                move.l  (A0)+,D4
                move.l  (A0)+,D5
                movea.l	a3,a5
                adda.l  (A0)+,A5                 

		move.w	d1,d2
		lsr.w	#3,d2
		beq	scan_textur_max8_mx320

		andi.w	#$0007,d1

		subq.w	#1,d2

		add.w	d4,d5
                swap    D5                        ;anfangsnachkomma ins HI
                swap    D4                        ;vor-/nachkomma vertauschen

scan_textur_8_mx320
                move.w  0(a4,d5.w*2),d7
		beq.s	*+6
                move.l  0(a5,d7.w*2),(a2)
		addx.l	d4,d5

offset		set	-320
		rept	7
                move.w  0(a4,d5.w*2),d7
		beq.s	*+8
                move.l  0(a5,d7.w*2),offset(a2)
		addx.l	d4,d5
offset		set	offset-320
		endr

		lea	-8*320(a2),a2

		dbra	d2,scan_textur_8_mx320

scan_textur_mx320
                move.w  0(a4,d5.w*2),d7
		beq.s	*+6
                move.l  0(a5,d7.w*2),(a2)
		addx.l	d4,d5
                lea     -320(A2),A2

		dbra    D1,scan_textur_mx320

                bra	strahl_loop_mx320            ;und zur naechsten textur des strahls

next_mask_go_on_x320
                dbra    D0,paint_mask_loop_x320
		bra	paint_double_mask_end320

scan_textur_max8_mx320
		add.w	d4,d5
                swap    D5                        ;anfangsnachkomma ins HI
                swap    D4                        ;vor-/nachkomma vertauschen

scan_textur_max8_loop_mx320
                move.w  0(a4,d5.w*2),d7
		beq.s	*+6
                move.l  0(a5,d7.w*2),(a2)
		addx.l	d4,d5
                lea     -320(A2),A2
		dbra    D1,scan_textur_max8_loop_mx320

                bra	strahl_loop_mx320             ;und zur naechsten textur des strahls

paint_double_mask_end320

		movea.l	play_dat_ptr,a6
                move.w  pd_width(A6),pd_width_last(A6)
                move.w  pd_heigth(A6),pd_heigth_last(A6)

                rts

