;**************************************
;* paint_pistol
;**************************************

paint_pistol
		tst.w	karte_flag		; karte aktiv?
		bne	pp_out			; ja -> raus
		tst.w	pp_flag			; pistole nicht vorhanden?
		bne	pp_out			; ja -> raus
		tst.w	pp_data_ok		; pistolendaten nicht ok?
		bne	pp_out			; ja -> raus
		tst.w	cameraview_flag		; camera aktiv?
		bne	pp_out			; ja -> raus
		tst.w	terminal_flag		; terminal aktiv?
		bne	pp_out			; ja -> raus

		ifeq	final
		lea	keytable,a0
		tst.b	$19(a0)
		bne	pp_out
		endc
		
		movea.l	play_dat_ptr,a0		; keine anzeige mehr,
		tst.w	pd_health(a0)		; wenn spieler bereits
		bmi	pp_out			; gestorben

	; check  animstufe 2 (schuss)

		tst.w	pd_hat_gesch(a0)
		beq.s	pp_no_shoot
		move.w	pp_anim2_time+2,d0
		cmpi.w	#4,pd_mun_type(a0)
		bne.s	ppc2_no
		lsr.w	#2,d0
ppc2_no		move.w	d0,pp_anim2_time

pp_no_shoot

		move.w	pp_anim2_time,d0	; keine animation, wenn
		beq	pp_anim2_end		; flag gleich null
		sub.w	vbl_time,d0
		beq.s	pp_a2_time_not
		bpl.s	pp_a2_time_ok
pp_a2_time_not	moveq	#0,d0
		move.w	pp_anim3_time+2,d1
		cmpi.w	#4,pd_mun_type(a0)
		bne.s	ppc3_no
		lsr.w	#2,d1
ppc3_no		move.w	d1,pp_anim3_time	; naechste animationsphase starten
pp_a2_time_ok	move.w	#1,pp_animstufe			; zeige phase 1 (0..3) an
		move.w	d0,pp_anim2_time
		bra	pp_now				; zur routine verzweigen
pp_anim2_end
		
	; check animstufe 3 (rueckstoss)

		move.w	pp_anim3_time,d0
		beq.s	pp_anim3_end
		sub.w	vbl_time,d0
		beq.s	pp_a3_time_not
		bpl.s	pp_a3_time_ok
pp_a3_time_not	moveq	#0,d0
		move.w	pp_anim4_time+2,d1
		cmpi.w	#4,pd_mun_type(a0)
		bne.s	ppc4_no
		lsr.w	#2,d1
ppc4_no		move.w	d1,pp_anim4_time
pp_a3_time_ok	move.w	#2,pp_animstufe
		move.w	d0,pp_anim3_time
		bra	pp_now
pp_anim3_end


	; check animstufe 4 (reload)

		move.w	pp_anim4_time,d0
		beq.s	pp_anim4_end
		sub.w	vbl_time,d0
		bpl.s	pp_a4_time_ok
		moveq	#0,d0
pp_a4_time_ok	move.w	#3,pp_animstufe
		move.w	d0,pp_anim4_time
		bra	pp_now
pp_anim4_end


		clr.w	pp_animstufe

pp_now
		bsr	paint_pistol_now
	

pp_out:
		rts

;---------------

paint_pistol_now

		lea	pistol_data+pis_dat_dat1,a0
		move.w	pp_animstufe,d0
		tst.w	pis_dat_breite(a0,d0.w*8)
		beq	ppn_out

		bsr	calc_paint_pistol

		movea.l	screen_1,a5
		adda.l	pp_startyline,a5
		move.w	pp_yoffset,d0
		mulu	true_offi+2,d0
		adda.l	d0,a5
		move.w	pp_xoffset,d0
		add.w	d0,d0
		adda.w	d0,a5
		
		move.w	pp_animstufe,d7
		lea	pistol_data,a0
		lea	pis_dat_data(a0),a1	; begin grafix
		move.w	d7,d6
		subq.w	#1,d6
		bmi.s	ppn_no_offi
		adda.l	0(a0,d6.w*4),a1
ppn_no_offi:

		lea	pistol_lines,a4
		move.w	d7,d6
		ext.l	d6
		swap	d6
		lsr.l	#7,d6
		adda.l	d6,a4			; pistol_lines

		move.w	pis_dat_dat1+pis_dat_sxoffi(a0,d7.w*8),d4

		mulu	true_offi+2,d4		; anpassen auf
		divu	#640,d4			; true_offi

		move.w	true_offi+2,d3
		lsr.w	#2,d3		
		sub.w	d3,d4			; anpassen auf
		ext.l	d4			; fenstergroesse
		moveq	#12,d2
		lsl.l	d2,d4
		divs	pp_zoom_12,d4
		add.w	d3,d4
		add.w	d4,d4
		adda.w	d4,a5

		move.l	pp_zoomx,d2
		move.w	d2,d3		; d3 = vorkomma
		clr.w	d2		; d2 = nachkomma

		move.w	pp_breite_z,d5
		move.w	pp_hoehe_z,d6

ppn_gfx_loop
		move.w	d5,d4
		movea.l	a5,a6

		cmpa.l	pp_screen_end,a5
		bge	ppn_out

		movea.l	a1,a3
		move.l	(a4)+,d0	; offset
		bmi	ppn_out
		adda.l	d0,a3

		moveq	#0,d1
ppn_gfx_line_loop
		move.w	0(a3,d1.w*2),d0
		beq.s	ppngl_no_pixel
		add.l	d2,d1
		addx.w	d3,d1
		move.w	d0,(a6)+
		dbra	d4,ppn_gfx_line_loop
		adda.l	true_offi,a5
		dbra	d6,ppn_gfx_loop
		rts

ppngl_no_pixel
		add.l	d2,d1
		addx.w	d3,d1
		addq.l	#2,a6
		dbra	d4,ppn_gfx_line_loop
		adda.l	true_offi,a5
		cmpa.l	pp_screen_end,a5
		bge	ppn_out
		dbra	d6,ppn_gfx_loop
ppn_out		rts

;---------------

calc_paint_pistol_immediate

		movea.l	play_dat_ptr,a0
		move.w	pd_width(a0),pp_last_width
		move.w	pd_heigth(a0),pp_last_heigth
		bra	cpp_immediate

;---

calc_paint_pistol

		movea.l	play_dat_ptr,a0		; pointer spielerdaten
		move.w	pd_width_last(a0),d0	; bildschirmbreite
		cmp.w	pp_last_width,d0	; mit der vorherigen vergleichen
		bne.s	cpp_must_calc		; wenn ungleich -> neu berechnen
		move.w	pd_heigth_last(a0),d1	; dito mit der bildschirmhoehe
		cmp.w	pp_last_heigth,d1
		beq.s	cpp_no_calc_nec

cpp_must_calc
		move.w	d0,pp_last_width
		move.w	d1,pp_last_heigth

cpp_immediate
		bsr	calc_pp_zoom
		bsr	calc_pp_lines
;		bsr	calc_pp_offsets
;		bsr	calc_pp_pixel


cpp_no_calc_nec:

		; die folgenden berechnungen muessen immer gemacht werden

		bsr	calc_breite_hoehe
		bsr	calc_pp_startyline
		bsr	calc_pp_offset
		bsr	calc_pp_screen_end

		rts

cpp_calc_flag	dc.w	0

;---------------

calc_pp_screen_end:

		movea.l	play_dat_ptr,a6
                move.w  pd_heigth_last(A6),D0
                move.w  ywindow_max,D1
                sub.w   D0,D1
                bpl.s   cppse_yoffi_ok
                moveq   #0,D1
cppse_yoffi_ok: lsr.w   #1,D1
		add.w	pd_heigth_last(a6),d1
                mulu    true_offi+2,D1
		movea.l	screen_1,a1
                adda.l	d1,a1
		move.l	a1,pp_screen_end

		rts

;---------------

calc_breite_hoehe:

		lea	pistol_data+pis_dat_dat1,a0
		move.w	pp_animstufe,d0
		move.w	pis_dat_breite(a0,d0.w*8),d1

		mulu	true_offi+2,d1		; anpassen auf
		divu	#640,d1			; true_offi

		move.w	pis_dat_hoehe(a0,d0.w*8),d2

		ext.l	d1
		ext.l	d2
		swap	d1
		swap	d2
		lsr.l	#4,d1
		lsr.l	#4,d2
		move.w	pp_zoom_12,d0
		divu	d0,d1
		divu	d0,d2
		subq.w	#1,d1
		subq.w	#1,d2
		move.w	d1,pp_breite_z
		move.w	d2,pp_hoehe_z

		rts

;---------------

calc_pp_startyline:

		tst.w	double_scan
		beq	cpps_no_double

cpps_double:
		movea.l	play_dat_ptr,a0
		move.w	pd_width_last(a0),d2
		move.w	d2,d3
		lsr.w	#2,d3
		cmp.w	pd_heigth_last(a0),d3
		blt.s	cpps_d_normal

		move.w	#120,d0
		sub.w	d3,d0
		lsr.w	#1,d0
		add.w	d3,d0
		move.w	pp_hoehe_z,d1
		lsr.w	#1,d1
		sub.w	d1,d0	
		mulu	true_offi+2,d0
;		mulu	#640,d0
		move.l	d0,pp_startyline

		rts

cpps_d_normal:
		move.w	#120,d0
		sub.w	pd_heigth_last(a0),d0
		lsr.w	#1,d0
		add.w	pd_heigth_last(a0),d0
		move.w	pp_hoehe_z,d1
		lsr.w	#1,d1
		sub.w	d1,d0	
		mulu	true_offi+2,d0
;		mulu	#640,d0
		move.l	d0,pp_startyline

		rts

cpps_no_double:
		movea.l	play_dat_ptr,a0
		move.w	pd_width_last(a0),d2
		move.w	d2,d3
		lsr.w	#1,d3
		cmp.w	pd_heigth_last(a0),d3
		blt.s	cpps_nd_normal

		move.w	#200,d0
		sub.w	d3,d0
		lsr.w	#1,d0
		add.w	d3,d0
		sub.w	pp_hoehe_z,d0
		mulu	true_offi+2,d0
;		mulu	#640,d0
		move.l	d0,pp_startyline

		rts


cpps_nd_normal:
		move.w	#200,d0
		sub.w	pd_heigth_last(a0),d0
		lsr.w	#1,d0
		add.w	pd_heigth_last(a0),d0
		sub.w	pp_hoehe_z,d0
		mulu	true_offi+2,d0
;		mulu	#640,d0
		move.l	d0,pp_startyline

		rts

;---------------

calc_pp_lines
		lea	pistol_data+pis_dat_dat1,a0	; pointer auf breite, hoehe, sxoffi, flags
		lea	pistol_data+pis_dat_data,a1	; pointer auf reine grafikdaten
		lea	pistol_lines,a2			; hier eintragen
		lea	pistol_data,a3

		moveq	#3,d7				; wir haben 3 phasen
cpp_lines_loop
		movem.l	d7/a0/a2-a3,-(sp)
		bsr	cpp_lines_animstufe
		movem.l	(sp)+,d7/a0/a2-a3

		addq.l	#8,a0				; pointer erhoehen (breite, hoehe, ...)

		lea	pistol_data+pis_dat_data,a1	; pointer erhoehen (grafikdaten)
		moveq	#3,d6
		sub.w	d7,d6
		adda.l	(a3)+,a1
;		adda.l	0(a0,d6.w*4),a1		; gfx

		lea	512(a2),a2		; lines

		dbra	d7,cpp_lines_loop

		rts

;---

; a0: pistol_data_datx
; a1: pistol_data (gfx)
; a2: pistol_lines

cpp_lines_animstufe

		move.w	pis_dat_hoehe(a0),d0	; heigth ( = anzahl lines max.)
		beq	cppla_out
		
		movea.l	a2,a3			; zwischenspeichern

		move.l	pp_zoom,d3
		tst.w	double_scan
		beq.s	cppla_no_double
		add.l	d3,d3
cppla_no_double:
		move.w	d3,d4		; d4.w = vorkomma, d3.l = nachkomma
		clr.w	d3
		moveq	#0,d5

cppla_loop:
		cmp.w	d0,d5
		bge.s	cppla_end_found

		move.l	d5,d6
		ext.l	d6
		move.l	d6,(a2)+
		add.l	d3,d5
		addx.w	d4,d5
		bra.s	cppla_loop

cppla_end_found

		move.l	#-1,(a2)	; ende markierung

		; jetzt aus den liniendaten die 
		; screen_offsets berechnen

		movea.l	a3,a2
		move.w	pis_dat_breite(a0),d0		
		add.w	d0,d0

cppla2_loop:
		move.l	(a2),d2
		bmi.s	cppla_out

		mulu	d0,d2
		move.l	d2,(a2)+

		bra.s	cppla2_loop

cppla_out:
		rts


;---------------

calc_pp_offset:
		tst.w	has_moved
		bne.s	cppo_moved

		move.w	has_turned,pp_xoffset
		clr.w	pp_yoffset

		move.w	#-1,pp_pos

		rts

;---

cppo_moved:
		move.w	has_turned,pp_xoffset


		move.w	pp_pos,d1
		bpl.s	cppo_normal_circle

		lea	pistol_data+pis_dat_dat1,a6
		move.w	pp_animstufe,d6

		sub.w	vbl_time,d1
		move.w	d1,d2
		cmpi.w	#-8,d1
		bgt.s	cppo_slide_ok
		moveq	#$20,d1
		move.w	#-8,d2
cppo_slide_ok:	move.w	d1,pp_pos
		neg.w	d2
		swap	d2
		clr.w	d2
		lsr.l	#4,d2
		divu	pp_zoom_12,d2
		
		btst	#1,pis_dat_flags+1(a6,d6.w*8)
		bne.s	cppo_sx_ok
		moveq	#0,d2
cppo_sx_ok:	move.w	d2,pp_yoffset

		rts

;---

cppo_normal_circle:

		lea	pistol_data+pis_dat_dat1,a6
		move.w	pp_animstufe,d6

		move.w	pp_pos,d0
		add.w	vbl_time,d0
		andi.w	#$3f,d0
		move.w	d0,pp_pos
		lea	sinus_256_tab,a4
		move.w	0(a4,d0.w*8),d1
		ext.l	d1
		lsl.l	#1,d1
		divs	pp_zoom_12,d1
		btst	#0,pis_dat_flags+1(a6,d6.w*8)
		bne.s	cppo_x_ok
		moveq	#0,d1
cppo_x_ok:	add.w	has_turned,d1
		move.w	d1,pp_xoffset

		addi.w	#$10,d0
		andi.w	#$3f,d0
		move.w	0(a4,d0.w*8),d1
		bpl.s	ppyo_ok
		neg.w	d1
ppyo_ok:	ext.l	d1
		lsl.l	#1,d1
		divu	pp_zoom_12,d1
		btst	#1,pis_dat_flags+1(a6,d6.w*8)
		bne.s	cppo_y_ok
		moveq	#0,d1
cppo_y_ok:	move.w	has_turned,d2
		beq.s	cppoy_no_add
		rol.w	#1,d2
		andi.w	#$1,d2
		add.w	d2,d1
cppoy_no_add	move.w	d1,pp_yoffset

		rts

;---------------

calc_pp_zoom

	; zuerst ganz normal den zoom
	; bestimmen fuer verhaeltnis 1:1

		move.l	true_offi,d0
		swap	d0
		lsr.l	#5,d0
;		move.l	#320*4096,d0
		divu	pp_last_width,d0
		move.w	d0,pp_zoom_12
		ext.l	d0
		lsl.l	#4,d0
		swap	d0
		move.l	d0,pp_zoom

	; jetzt brauche ich noch den
	; zoomfaktor nur in x-richtung
		
		move.l	true_offi,d0
		swap	d0
		lsr.l	#5,d0
;		move.l	#320*4096,d0

		move.w	pp_last_width,d1
		mulu	true_offi+2,d1
		divu	#640,d1
		divu	d1,d0
		ext.l	d0
		lsl.l	#4,d0
		swap	d0
		move.l	d0,pp_zoomx

		rts

;-----------------------

pistol_helligkeit_anpassen

		movem.l	d0-a6,-(sp)

		jsr	get_sc_with_priority
		move.w	d0,d2

		lea	pistol_data,a0
		move.l	pid_length(a0),d0
		lsr.l	#1,d0
		subq.l	#1,d0
		lea	pid_data(a0),a0
		movea.l	play_dat_ptr,a1
		move.w	pd_mun_type(a1),d1
		movea.l	big_sector_ptr,a1
		movea.l	lev_pistol(a1),a1
		movea.l	pistol_info(a1),a1
		movea.l	(a1,d1.w*4),a1
		move.w	pistol_hellig(a1),d1
		move.w	#%11111,d5
		move.w	#%11111100000,d6
		move.w	#%1111100000000000,d7

		lea	pha_routs(pc),a1
		movea.l	(a1,d2.w*4),a1

		jsr	(a1)

		movem.l	(sp)+,d0-a6
		rts

pha_routs	dc.l	pha_r0
		dc.l	pha_r1
		dc.l	pha_r2
		dc.l	pha_r3
		dc.l	pha_r4
		dc.l	pha_r4
		dc.l	pha_r4
		dc.l	pha_r4

;**************************************
;* pha_routs
;**************************************

; a0 = pistol_data (reine grafikdaten)
; d0 = anzahl an pixel (-1) !!!
; d1 = helligkeit (0..256)
; d7..d5 = binaermasken fuer farbanteile rot, gruen, blau

pha_r0		move.w	(a0),d2
		move.w	d2,d4
		and.w	d5,d4
		move.w	d2,d3
		and.w	d6,d3
		and.w	d7,d2
		mulu	d1,d2
		mulu	d1,d3
		mulu	d1,d4
		lsr.l	#8,d2
		lsr.l	#8,d3
		lsr.l	#8,d4
		and.w	d6,d3
		and.w	d7,d2
		add.w	d4,d3
		add.w	d3,d2
		move.w	d2,(a0)+
		dbra	d0,pha_r0
		rts

pha_r1		move.w	(a0),d2
		and.w	d6,d2
		mulu	d1,d2
		lsr.l	#8,d2
		and.w	d6,d2
		move.w	d2,(a0)+
		dbra	d0,pha_r1
		rts

pha_r2		move.w	(a0),d2
		and.w	d7,d2
		mulu	d1,d2
		lsr.l	#8,d2
		and.w	d7,d2
		move.w	d2,(a0)+
		dbra	d0,pha_r2
		rts

pha_r3		move.w	(a0),d2
		move.w	d2,d4
		and.w	d5,d4
		move.w	d2,d3
		and.w	d6,d3
		and.w	d7,d2
		mulu	d1,d2
		mulu	d1,d3
		mulu	d1,d4
		lsr.l	#8,d2
		lsr.l	#8,d3
		lsr.l	#8,d4
		and.w	d6,d3
		and.w	d7,d2
		add.w	d4,d3
		add.w	d3,d2
		move.w	d2,(a0)+
		dbra	d0,pha_r3
		rts

pha_r4		move.w	(a0),d2
		move.w	d2,d4
		and.w	d5,d4
		move.w	d2,d3
		and.w	d6,d3
		and.w	d7,d2
		mulu	d1,d2
		mulu	d1,d3
		mulu	d1,d4
		lsr.l	#8,d2
		lsr.l	#8,d3
		lsr.l	#8,d4
		lsr.l	#1,d2
		lsr.l	#1,d3
		lsr.l	#1,d4
		and.w	d6,d3
		and.w	d7,d2
		add.w	d4,d3
		add.w	d3,d2
		move.w	d2,(a0)+
		dbra	d0,pha_r4
		rts



