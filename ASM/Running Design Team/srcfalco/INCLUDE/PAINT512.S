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


paint512
                tst.w   dsp_error_flag
                beq.s   dsp_data_ok512
no_paint512:
                movea.l play_dat_ptr,A6
                move.w  pd_width(A6),pd_width_last(A6)
                move.w  pd_heigth(A6),pd_heigth_last(A6)
                move.w  pd_x_flag(A6),pd_x_flag_last(A6)

                rts

dsp_data_ok512:
                tst.w   karte_flag
                bne.s   no_paint512

                movea.l play_dat_ptr,A6

                lea     dsp_puffer,A0
                movea.l screen_1(PC),A1
                adda.w  pd_paint_x_offi(A6),A1

;berechnet wird die y-zeile, wo das bild anfaengt ...

                move.w  pd_heigth_last(A6),D0
                move.w  ywindow_max,D1
                sub.w   D0,D1
                bpl.s   yoffi_ok512
                moveq   #0,D1
yoffi_ok512:       lsr.w   #1,D1
                mulu    #512,D1
                adda.l  D1,A1

                move.w  pd_x_flag_last(A6),D0
                move.w  pd_x_flag(A6),pd_x_flag_last(A6)
                btst    #0,D0
                bne     paint_double_x512
               
;**************************************
;* full detail
;**************************************
              
paint_full512:
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

paint_loop512:
                subq.l  #2,A1                     ;naechster strahl

strahl_loop512:
                move.l  (A0)+,D1                  ;anzahl zu zeichnender pixel holen
                cmpi.w  #$FFFF,D1                 ;wenn negativ, dann ist dieser
                beq	next_full_go_on512           ;strahl fertig, ab zum naechsten

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
		beq	scan_textur_max8512

		andi.w	#$0007,d1

		subq.w	#1,d2

		add.w	d4,d5
                swap    D5                        ;anfangsnachkomma ins HI
                swap    D4                        ;vor-/nachkomma vertauschen

scan_textur_8512
                move.w  0(a4,d5.w*2),d7
		addx.l	d4,d5
                move.w  0(a5,d7.w*2),(a2)


offset		set	-512
		rept	7
                move.w  0(a4,d5.w*2),d7
		addx.l	d4,d5
                move.w  0(a5,d7.w*2),offset(a2)
offset		set	offset-512
		endr

		lea	-8*512(a2),a2

		dbra	d2,scan_textur_8512

scan_textur512
                move.w  0(a4,d5.w*2),d7
		addx.l	d4,d5
                move.w  0(a5,d7.w*2),(a2)
                lea     -512(A2),A2
		dbra    D1,scan_textur512

                bra	strahl_loop512               ;und zur naechsten textur des strahls

next_full_go_on512:
                dbra    D0,paint_loop512             ;zum naechsten strahl
		bra	paint_full_boden512

scan_textur_max8512
		add.w	d4,d5
                swap    D5                        ;anfangsnachkomma ins HI
                swap    D4                        ;vor-/nachkomma vertauschen

scan_textur_max8_loop512
                move.w  0(a4,d5.w*2),d7
		addx.l	d4,d5
                move.w  0(a5,d7.w*2),(a2)
                lea     -512(A2),A2
		dbra    D1,scan_textur_max8_loop512

                bra	strahl_loop512               ;und zur naechsten textur des strahls
                dbra    D0,paint_loop512             ;zum naechsten strahl

; boden und decke *********************

paint_full_boden512

		movea.l	play_dat_ptr,a6
                move.w  pd_width_last(A6),D0
                subq.w  #1,D0                     ;d0 ist wieder der schleifenzaehler

                movea.l screen,A1             	  ;screenadresse des ersten strahls
                movea.l boden_col_ptr,A3

paint_boden_loop512:
                subq.l  #2,A1

strahl_boden_loop512:
                move.l  (A0)+,D1                  ;anzahl zu zeichnender pixel
                cmpi.w  #$FFFF,D1                 ;wenn negativ, ... (wie bekannt)
                beq.s   next_full_go_on_boden512

                movea.l A1,A2

                adda.l  (A0)+,A2                  ;y-offset screenadresse (strahlenweise)
                move.l  (A0)+,D3                  ;farbwert
                move.w  0(A3,D3.w*4),D5
		move.w	d1,d2
		lsr.w	#3,d2
		beq	scan_boden512

		subq.w	#1,d2

scan_boden_8512
		move.w	d5,(a2)
		move.w	d5,-512(a2)
		move.w	d5,-2*512(a2)
		move.w	d5,-3*512(a2)
		move.w	d5,-4*512(a2)
		move.w	d5,-5*512(a2)
		move.w	d5,-6*512(a2)
		move.w	d5,-7*512(a2)
		lea	-8*512(a2),a2
		dbra	d2,scan_boden_8512

		andi.w	#%111,d1
scan_boden512:
                move.w  D5,(A2)
                lea     -512(A2),A2

                dbra    D1,scan_boden512

                bra.s   strahl_boden_loop512

next_full_go_on_boden512:
                dbra    D0,paint_boden_loop512


; maskierte texturen ******************

		movea.l	play_dat_ptr,a6
                move.w  pd_width_last(A6),D0
                subq.w  #1,D0

                movea.l screen,A1

		lea	dith_data,a6
		lea	truecolor_tab,a3

paint_mask_loop512
                subq.l  #2,A1

strahl_loop_m512
                move.l  (A0)+,D1
                cmpi.w  #$FFFF,D1
                beq	next_mask_go_on_m512

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
		beq	scan_textur_max8_m512

		andi.w	#$0007,d1

		subq.w	#1,d2

		add.w	d4,d5
                swap    D5                        ;anfangsnachkomma ins HI
                swap    D4                        ;vor-/nachkomma vertauschen

scan_textur_8_m512
                move.w  0(a4,d5.w*2),d7
		beq.s	*+6
                move.w  0(a5,d7.w*2),(a2)
		addx.l	d4,d5

offset		set	-512
		rept	7
                move.w  0(a4,d5.w*2),d7
		beq.s	*+8
                move.w  0(a5,d7.w*2),offset(a2)
		addx.l	d4,d5
offset		set	offset-512
		endr

		lea	-8*512(a2),a2

		dbra	d2,scan_textur_8_m512

scan_textur_m512
                move.w  0(a4,d5.w*2),d7
		beq.s	*+6
                move.w  0(a5,d7.w*2),(a2)
		addx.l	d4,d5
                lea     -512(A2),A2

		dbra    D1,scan_textur_m512

                bra	strahl_loop_m512            ;und zur naechsten textur des strahls

next_mask_go_on_m512
                dbra    D0,paint_mask_loop512
		bra	paint_mask_end512

scan_textur_max8_m512
		add.w	d4,d5
                swap    D5                        ;anfangsnachkomma ins HI
                swap    D4                        ;vor-/nachkomma vertauschen

scan_textur_max8_loop_m512
                move.w  0(a4,d5.w*2),d7
		beq.s	*+6
                move.w  0(a5,d7.w*2),(a2)
		addx.l	d4,d5
                lea     -512(A2),A2
		dbra    D1,scan_textur_max8_loop_m512

                bra	strahl_loop_m512             ;und zur naechsten textur des strahls

paint_mask_end512

		movea.l	play_dat_ptr,a6
                move.w  pd_width(A6),pd_width_last(A6)
                move.w  pd_heigth(A6),pd_heigth_last(A6)

                rts


;**************************************
;**************************************
;**************************************
;**************************************

paint_double_x512
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

paint_loop_x512
                subq.l  #4,A1                     ;naechster strahl

strahl_loop_x512
                move.l  (A0)+,D1                  ;anzahl zu zeichnender pixel holen
                cmpi.w  #$FFFF,D1                 ;wenn negativ, dann ist dieser
                beq	next_full_go_on_x512         ;strahl fertig, ab zum naechsten

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
		beq	scan_textur_max8_x512

		andi.w	#$0007,d1

		subq.w	#1,d2

		add.w	d4,d5
                swap    D5                        ;anfangsnachkomma ins HI
                swap    D4                        ;vor-/nachkomma vertauschen

scan_textur_8_x512
                move.w  0(a4,d5.w*2),d7
		addx.l	d4,d5
                move.l  0(a5,d7.w*2),(a2)

offset		set	-512
		rept	7
                move.w  0(a4,d5.w*2),d7
		addx.l	d4,d5
                move.l  0(a5,d7.w*2),offset(a2)
offset		set	offset-512
		endr

		lea	-8*512(a2),a2

		dbra	d2,scan_textur_8_x512

scan_textur_x512
                move.w  0(a4,d5.w*2),d7
		addx.l	d4,d5
                move.l  0(a5,d7.w*2),(a2)
                lea     -512(A2),A2

		dbra    D1,scan_textur_x512

                bra	strahl_loop_x512             ;und zur naechsten textur des strahls

next_full_go_on_x512
                dbra    D0,paint_loop_x512           ;zum naechsten strahl
		bra	paint_full_boden_x512

scan_textur_max8_x512
		add.w	d4,d5
                swap    D5                        ;anfangsnachkomma ins HI
                swap    D4                        ;vor-/nachkomma vertauschen

scan_textur_max8_loop_x512
                move.w  0(a4,d5.w*2),d7
		addx.l	d4,d5
                move.l  0(a5,d7.w*2),(a2)
                lea     -512(A2),A2
		dbra    D1,scan_textur_max8_loop_x512

                bra	strahl_loop_x512             ;und zur naechsten textur des strahls
                dbra    D0,paint_loop_x512           ;zum naechsten strahl

; boden und decke *********************

paint_full_boden_x512

		movea.l	play_dat_ptr,a6
                move.w  pd_width_last(A6),D0
		lsr.w	#1,d0
                subq.w  #1,D0                     ;d0 ist wieder der schleifenzaehler

                movea.l screen_x,A1             	  ;screenadresse des ersten strahls
                movea.l boden_col_ptr,A3

paint_boden_loop_x512
                subq.l  #4,A1

strahl_boden_loop_x512
                move.l  (A0)+,D1                  ;anzahl zu zeichnender pixel
                cmpi.w  #$FFFF,D1                 ;wenn negativ, ... (wie bekannt)
                beq.s   next_full_go_on_boden_x512

                movea.l A1,A2

                adda.l  (A0)+,A2                  ;y-offset screenadresse (strahlenweise)
                move.l  (A0)+,D3                  ;farbwert

                move.l  0(A3,D3.w*4),D5

		move.w	d1,d2
		lsr.w	#3,d2
		beq	scan_boden_x512

		subq.w	#1,d2

scan_boden_8_x512
		move.l	d5,(a2)
		move.l	d5,-512(a2)
		move.l	d5,-2*512(a2)
		move.l	d5,-3*512(a2)
		move.l	d5,-4*512(a2)
		move.l	d5,-5*512(a2)
		move.l	d5,-6*512(a2)
		move.l	d5,-7*512(a2)
		lea	-8*512(a2),a2
		dbra	d2,scan_boden_8_x512

		andi.w	#%111,d1
scan_boden_x512
                move.l  D5,(A2)
                lea     -512(A2),A2

                dbra    D1,scan_boden_x512

                bra.s   strahl_boden_loop_x512

next_full_go_on_boden_x512
                dbra    D0,paint_boden_loop_x512


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

paint_mask_loop_x512
                subq.l  #4,A1

strahl_loop_mx512
                move.l  (A0)+,D1
                cmpi.w  #$FFFF,D1
                beq	next_mask_go_on_x512

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
		beq	scan_textur_max8_mx512

		andi.w	#$0007,d1

		subq.w	#1,d2

		add.w	d4,d5
                swap    D5                        ;anfangsnachkomma ins HI
                swap    D4                        ;vor-/nachkomma vertauschen

scan_textur_8_mx512
                move.w  0(a4,d5.w*2),d7
		beq.s	*+6
                move.l  0(a5,d7.w*2),(a2)
		addx.l	d4,d5

offset		set	-512
		rept	7
                move.w  0(a4,d5.w*2),d7
		beq.s	*+8
                move.l  0(a5,d7.w*2),offset(a2)
		addx.l	d4,d5
offset		set	offset-512
		endr

		lea	-8*512(a2),a2

		dbra	d2,scan_textur_8_mx512

scan_textur_mx512
                move.w  0(a4,d5.w*2),d7
		beq.s	*+6
                move.l  0(a5,d7.w*2),(a2)
		addx.l	d4,d5
                lea     -512(A2),A2

		dbra    D1,scan_textur_mx512

                bra	strahl_loop_mx512            ;und zur naechsten textur des strahls

next_mask_go_on_x512
                dbra    D0,paint_mask_loop_x512
		bra	paint_double_mask_end512

scan_textur_max8_mx512
		add.w	d4,d5
                swap    D5                        ;anfangsnachkomma ins HI
                swap    D4                        ;vor-/nachkomma vertauschen

scan_textur_max8_loop_mx512
                move.w  0(a4,d5.w*2),d7
		beq.s	*+6
                move.l  0(a5,d7.w*2),(a2)
		addx.l	d4,d5
                lea     -512(A2),A2
		dbra    D1,scan_textur_max8_loop_mx512

                bra	strahl_loop_mx512             ;und zur naechsten textur des strahls

paint_double_mask_end512

		movea.l	play_dat_ptr,a6
                move.w  pd_width(A6),pd_width_last(A6)
                move.w  pd_heigth(A6),pd_heigth_last(A6)

                rts

