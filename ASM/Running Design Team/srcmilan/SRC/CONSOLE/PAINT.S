
CONSOLEPAINT	equ	0



		text


; ---------------------------------------------------------
; zeichnet die console auf den screen.
; aktionen wie tastendruecke und das herunterzaehlen von
; zeitlimits ist anderswo implementiert.
; ---------------------------------------------------------
;paintConsole
		tst.w	consoleFlag		; console eingeblendet (egal, welcher modus)?
		beq.s	pcOut			; nein -> danke und tschuess
		tst.w	consoleMode		; console hat welchen modus?
		bne	pcSmall			; kleine version -> entsprechende routine

pcFull
		; die volle console ist sichtbar

;		bsr	plCopyConsole

;		tst.w	menueFlag
;		bne.s	pcAlways

;		bsr	pl_keys			; ok
;		bsr	pl_things
;		bsr	pl_energy
;		bsr	pl_shield
;		bsr	pl_ammo
;		bsr	pl_time_limit
;		bsr	pl_left_action
;		bra.s	pl_always

		bra	pcAlways


pcSmall
		; auf 3d-fenster gezeichnete console

;		tst.w	pl_display_flag
;		beq.s	plsv_skip
;		tst.w	menue_flag
;		bne.s	plsv_skip

;		bsr	pl_keys
;		bsr	pl_small_thing
;		bsr	pl_small_energy
;		bsr	pl_small_shield
;		bsr	pl_small_ammo
;		bsr	pl_left_action

pcAlways

pcOut
		rts



		ifne CONSOLEPAINT
;**************************************
;* paint_leiste
;**************************************

paint_leiste
		tst.w	double_scan
		bne.s	pl_small_version
		tst.w	cinemascope
		bne.s	pl_small_version

pl_full_version

	; -------------------
	; die volle console ist sichtbar

		bsr	pl_copy_console		; ok

		tst.w	menue_flag
		bne.s	pl_always

		bsr	pl_keys			; ok
		bsr	pl_things
		bsr	pl_energy
		bsr	pl_shield
		bsr	pl_ammo
		bsr	pl_time_limit
		bsr	pl_left_action
		bra.s	pl_always

pl_small_version

	; -------------------
	; einblenden einer light-version

		tst.w	pl_display_flag
		beq.s	plsv_skip
		tst.w	menue_flag
		bne.s	plsv_skip

		bsr	pl_keys
		bsr	pl_small_thing
		bsr	pl_small_energy
		bsr	pl_small_shield
		bsr	pl_small_ammo
		bsr	pl_left_action
plsv_skip


pl_always

	; -------------------
	; diese routinen werden immer ausgefuehrt,
	; egal, ob volle oder light console,
	; egal, ob console sichtbar oder nicht
	
		bsr	pl_time
		bsr	pl_info

                rts


;**************************************
;* pl_time_limit
;**************************************

; pd_time_flag: 0.b = gerade aktiv oder nicht
;               1.b = im vorherigen durchgang aktiv oder nicht

pl_time_limit
		movea.l	play_dat_ptr,a6
		move.b	pd_time_flag(a6),d0
		cmp.b	pd_time_flag+1(a6),d0	
		beq	pltl_no_change

	; -------------------
	; time_limit ein- oder 
	; ausgeschaltet worden

		tst.b	d0
		beq.s	pltl_ausgeschaltet

	; -------------------
	; time_limit ist 
	; eingeschaltet worden

pltl_eingeschaltet

		move.w	#$0101,pd_time_flag(a6)

	; -------------------
	; also die zahlen fÅr 
	; die zeit jetzt malen

		lea	leiste_gfx+128+640*59+255*2,a0
		movea.l	screen_1,a1
		movea.l	screen_2,a2
		move.l	#640*230+281*2,d6
		adda.l	d6,a1
		adda.l	d6,a2

		move.w	pd_time_limit1(a6),d0
		moveq	#0,d1
		bsr	pltl_number
		move.b	d0,pd_time_limit1+1(a6)

		move.w	pd_time_limit2(a6),d0
		moveq	#5*2,d1
		bsr	pltl_number
		move.b	d0,pd_time_limit2+1(a6)

		move.w	pd_time_limit3(a6),d0
		moveq	#12*2,d1
		bsr	pltl_number
		move.b	d0,pd_time_limit3+1(a6)

		move.w	pd_time_limit4(a6),d0
		moveq	#17*2,d1
		bsr	pltl_number
		move.b	d0,pd_time_limit4+1(a6)

		move.w	2(a0),d0
		move.w	d0,11*2+640(a1)
		move.w	d0,11*2+640(a2)
		move.w	d0,11*2+640*3(a1)
		move.w	d0,11*2+640*3(a2)

		bra	pltl_out


pltl_ausgeschaltet

		clr.w	pd_time_flag(a6)

	; -------------------
	; zeitanzeige loeschen

		lea	leiste_gfx+128+640*38+281*2,a0
		movea.l	screen_1,a1
		movea.l	screen_2,a2
		move.l	#640*229+281*2,d6
		adda.l	d6,a1
		adda.l	d6,a2

	; -------------------
	; bereich ist 23x7 pixel

		move.w	#true,d6		; 640
		moveq	#6,d7
pltla_gfx_loop	movem.l	(a0),d0-d5/a3-a5
		movem.l	d0-d5/a3-a5,(a1)
		movem.l	d0-d5/a3-a5,(a2)
		movem.l	18*2(a0),d0-d2
		movem.l	d0-d2,18*2(a1)
		movem.l	d0-d2,18*2(a2)
		adda.w	d6,a0
		adda.w	d6,a1
		adda.w	d6,a2
		dbra	d7,pltla_gfx_loop

		bra.s	pltl_out


pltl_no_change

	; -------------------
	; zeitlimit ist weder ein- 
	; noch ausgeschaltet worden.
	; wenn jetzt aktiv, dann zeichnen

		tst.b	d0
		bne	pltl_eingeschaltet

pltl_out
		rts


;**************************************
;* pltl_number
;**************************************

; zeichnet eine ziffer

; d0: ziffer (vorherige und aktuelle)
; d1: x-offset screen

; a0: grafik ziffern
; a1: position screen_1
; a2: position screen_2
; a6: reserviert

pltl_number
		move.w	d0,d2
		andi.w	#$ff,d2
		lsr.w	#8,d0
		cmp.w	d0,d2
		beq.s	pltln_out

	; -------------------
	; vorherige und aktuelle sind unterschiedlich,
	; also muss die ziffer gezeichnet werden

	; d0 ist fertig fuer die rueckgabe, darf
	; in dieser routine nicht mehr verwendet werden

	; ziffer jetzt einfach zeichnen ...

		move.w	d0,d2
		lsl.w	#2,d2
		add.w	d0,d2
		lea	(a0,d2.w*2),a3

		lea	(a1,d1.w),a4
		lea	(a2,d1.w),a5

		moveq	#4,d7		; 5 zeilen
		move.w	#true,d6
pltln_gfx_loop
		movem.w	(a3),d1-d5
		movem.w	d1-d5,(a4)
		movem.w	d1-d5,(a5)
		adda.w	d6,a3
		adda.w	d6,a4
		adda.w	d6,a5
		dbra	d7,pltln_gfx_loop

pltln_out
		rts


;**************************************
;* pl_info (04/10/97)
;**************************************

pl_info
		move.w	pli_gfx_pos(pc),d0	; ist was zu tun?
		bmi	pli_out			; nein -> raus

		move.w	d0,d1
		add.w	vbl_time,d1
		move.w	d1,pli_gfx_pos
		move.w	pli_per_vbl(pc),d2
		mulu	d2,d0
		mulu	d2,d1
		subq.w	#1,d1

		cmpi.w	#386,d1
		ble.s	pli_no_end

		move.w	#386,d1
		move.w	#-1,pli_gfx_pos

pli_no_end
		cmpi.w	#386,d0
		ble.s	pli_anf_ok

		move.w	#-1,pli_gfx_pos
		bra	pli_out

pli_anf_ok
		sub.w	d0,d1

		lea	ueber_1_tab,a0
		lea	(a0,d0.w*2),a0

		movea.l	pli_gfx_ptr(pc),a1	; grafikquelle
		movea.l	screen_1(pc),a2
		movea.l	screen_2(pc),a3
		move.l	#640*228+28*2,d2
		adda.l	d2,a2
		adda.l	d2,a3
pli_loop
		move.w	(a0)+,d0
		move.w	(a1,d0.w),d2
		move.w	d2,(a2,d0.w)
		move.w	d2,(a3,d0.w)
		dbra	d1,pli_loop

pli_out
		rts

	; -----------------
	; pl_install_info

	; a0 = pointer grafix

pl_install_info
		move.l	a0,pli_gfx_ptr
		clr.w	pli_gfx_pos

		rts

	; -----------------
	; pl_clear_info

pl_clear_info
		move.l	#leiste_gfx+128+640*37+28*2,pli_gfx_ptr
		clr.w	pli_gfx_pos

		rts

; ---------------------------
; benoetigte variablen

pli_gfx_ptr	dc.l	0
pli_gfx_pos	dc.w	-1
pli_per_vbl	dc.w	3


;**************************************
;* pl_copy_console (04/10/97)
;**************************************

; kopiert die 9 consolen-zeilen in den logischen screen

pl_copy_console

		movea.l	play_dat_ptr,a6		; zeilen kopieren, wenn
		move.w	pd_heigth_last(a6),d0	; 3d bild entsprechend
		cmpi.w	#182,d0			; gross ist
		bge.s	plcc_now

		move.w	pl_must_copy,d1		; oder wenn das flag
		beq.s	plcc_out		; zum zeichnen
		subq.w	#1,d1			; gesetzt ist
		move.w	d1,pl_must_copy		; flag dann um eins erniedrigen

plcc_now

	; -------------------
	; consolen zeilen jetzt kopieren
	; achtung: plcc_now ist die
	;	   einsprungadresse fuer
	; 	   make_terminal

		movea.l	screen_1(pc),a6
		adda.l	#640*200,a6
		lea	leiste_gfx+128+640*9,a5
		move.w	#9*320-1,d0
		moveq	#2,d2

plcc_loop
		move.w	-(a5),d1
		beq.s	plcc_no_pixel
		move.w	d1,-(a6)
		dbra	d0,plcc_loop
		bra.s	plcc_out
plcc_no_pixel	sub.l	d2,a6
		dbra	d0,plcc_loop

plcc_out
		rts		


;**************************************
;* pl_geiger
;**************************************

pl_geiger
		tst.w	double_scan
		bne.s	plg_out
		tst.w	cinemascope
		bne.s	plg_out

		bsr	plg_remove
		bsr	plg_scan
		bsr	plg_ausschlag

plg_out
		rts


;-----------------------

plg_remove
		movea.l	screen_1(pc),a1
		adda.l	#640*194+24*2,a1
		lea	leiste_gfx+128+640*60+0*2,a0

		moveq	#25,d7
plg_rem_loop	movem.l	(a0)+,d0-d6/a3-a6
		movem.l	d0-d6/a3-a6,(a1)
		movem.l	(a0)+,d0-d6/a3-a6
		movem.l	d0-d6/a3-a6,44(a1)
		movem.w	(a0)+,d0-d6
		movem.w	d0-d6,88(a1)
		lea	640-51*2(a0),a0
		lea	640(a1),a1
		dbra	d7,plg_rem_loop

		rts
		

;-----------------------

plg_ausschlag
		moveq	#0,d0				; anfangs ausschlag auf null
		movea.l	play_dat_ptr,a6
		movea.l	pd_in_akt_ss_ptr(a6),a0		; aktuelles sector field
		moveq	#0,d1
		move.b	sf_need_act(a0),d1		; benoetigter gegenstand
		beq.s	plga_nothing
		cmpi.w	#th_radsuit,d1			; schutzanzug noetig
		bne.s	plga_nothing			; nein -> ausschlag null lassen
		move.w	sf_need_staerke(a0),d0
		addq.w	#1,d0
		lsl.w	#4,d0

plga_nothing
		lea	plg_real_pos,a0
		move.w	d0,(a0)				; plg_real_pos

		movem.w	2(a0),d0-d1			; plg_act_pos und plg_to_pos
		move.w	vbl_time,d2
		cmp.w	d0,d1				; wert erreicht
		beq.s	plga_new_value			; wenn ja -> neuen ausschlag best.
		bgt.s	plga_addieren

plga_subtrahieren
		sub.w	d2,d0
		cmp.w	d1,d0
		bgt.s	plgas_ok
		move.w	d1,d0
plgas_ok	bra	plga_now

plga_addieren
		add.w	d2,d0
		cmp.w	d1,d0
		blt.s	plgaa_ok
		move.w	d1,d0
plgaa_ok	bra	plga_now

plga_new_value
		jsr	get_zufall_256
		ext.w	d1
		asr.w	#4,d1
		add.w	(a0),d1				; plg_real_pos
		bpl.s	plganv_pos
		moveq	#0,d1
plganv_pos	cmpi.w	#127,d1
		blt.s	plganv_ok
		move.w	#127,d1
plganv_ok	move.w	d1,4(a0)			; plg_to_pos
		move.w	2(a0),d0		

		
plga_now
		move.w	d0,2(a0)			; plg_act_pos
		move.w	#%1100011000011000,d7
		bsr	plg_linie
		rts


;-----------------------

plg_scan
		move.l	paint_links_oben,d0
		addi.l	#2*2,d0
		move.w	true_offi+2,d1
		add.w	d1,d1
		add.w	d1,d1
		ext.l	d1
		add.l	d1,d0
		move.l	d0,paint_lo_left

		clr.w	pl_small
		bra	pls_make_scan


;**************************************
;* plg_linie
;**************************************

; d0 = winkel (0..127)
; d7 = farbe

plg_linie
		tst.w	d0
		bpl.s	plgl_ok2
		moveq	#0,d0
plgl_ok2	moveq	#127,d1
		sub.w	d0,d1
		bpl.s	plgl_ok
		moveq	#0,d1
plgl_ok		lea	sinus_256_tab,a4
		move.w	(a4,d1.w*2),d4		; sinus
		addi.w	#$40,d1
		andi.w	#$ff,d1
		move.w	(a4,d1.w*2),d5		; cosinus
		muls	#25,d4
		muls	#25,d5
		lsl.l	#2,d4
		lsl.l	#2,d5
		swap	d4
		swap	d5
		move.w	#49,d0
		move.w	d0,d2
		move.w	#219,d1
		move.w	d1,d3
		add.w	d5,d2
		sub.w	d4,d3
		move.l	true_offi,d4
		movea.l	screen_1,a0
		bsr	linie_now

		rts


;**************************************
;* pl_scanner
;**************************************

pl_scanner
		tst.w	double_scan
		bne.s	pls_small_scanner
		tst.w	cinemascope
		bne.s	pls_small_scanner

		clr.w	pl_small

		moveq	#0,d0			; flag nur diesen screen loeschen
		bsr	pls_remove

		tst.w	cameraview_flag
		bne	pls_out

		bsr	pls_make_scan
		bsr	pls_monsters
		bra	pls_out

pls_small_scanner

		cmpi.w	#2,pl_display_flag
		bne.s	pls_out
		tst.w	cameraview_flag
		bne.s	pls_out

		bsr	pls_small_lines

		move.w	#1,pl_small
		bsr	pls_make_scan
		bsr	pls_monsters
pls_out
                rts


;-----------------------

pls_small_lines

	; -------------------
	; zeichnen der
	; koordinatenachsen

		move.l	paint_links_oben,d0
		addi.l	#2*2,d0
		move.w	true_offi+2,d1
		add.w	d1,d1
		add.w	d1,d1
		ext.l	d1
		add.l	d1,d0
		move.l	d0,paint_lo_left

		movea.l	d0,a0

		moveq	#1+0,d0
		moveq	#1+51,d2
		moveq	#1+25,d1
		move.w	d1,d3
		move.w	true_offi+2,d4
		move.w	#%0000001111000000,d7

		movem.w	d0-d1/d4/d7,-(sp)
		bsr	linie_now
		movem.w	(sp)+,d0-d1/d4/d7

		moveq	#1+0,d3
		moveq	#1+25,d0
		move.w	d0,d2
		bsr	linie_now

		rts


;-----------------------

pls_monsters

                movea.l mon_buf2_ptr(PC),A0
                move.w  mon_buf2_anz,D7
                bmi     pls_monst_out

                movea.l play_dat_ptr,A6
                move.l  pd_sx(A6),D0
                move.l  pd_sy(A6),D1

                move.w  #$0100,D2
                sub.w   pd_alpha+2(A6),D2
                addi.w  #$0040,D2
                andi.w  #$00FF,D2
                lea     sinus_256_tab(PC),A4
                lsl.w   #1,D2
                move.w  0(A4,D2.w),D4             ; sinus
                addi.w  #$0080,D2
                andi.w  #$01FF,D2
                move.w  0(A4,D2.w),D5             ; cosinus

pls_monst_loop:
                movea.l (A0)+,A1
                movem.l mon_line(A1),D2-D3
                sub.l   D0,D2
                sub.l   D1,D3
                lsl.l   #7,D2
                lsl.l   #7,D3
                swap    D2
                swap    D3

                move.w  D7,-(SP)

                move.w  D2,D6
                muls    D5,D6                     ; cos a * x
                move.w  D3,D7
                muls    D4,D7                     ; sin a * y
                sub.l   D7,D6
                lsl.l   #2,D6
                swap    D6                        ; d6 = x

                muls    D4,D2                     ; sin a * x
                muls    D5,D3                     ; cos a * y
                add.l   D2,D3
                lsl.l   #2,D3
                swap    D3
                move.w  D6,D2

                move.w  (SP)+,D7

                cmpi.w  #25,D2
                bgt	pls_xy_out
                cmpi.w  #-25,D2
                blt.s   pls_xy_out

                cmpi.w  #25,D3
                bgt.s   pls_xy_out
                tst.w	D3
                bmi.s   pls_xy_out

		tst.w	pl_small
		bne.s	plsm_small
		movea.l	screen_1(pc),a4
                addi.w  #49,D2
                move.w  #219,D6			; y_mitte
                sub.w   D3,D6
                mulu    #640,D6
                adda.w  D2,A4
                adda.w  D2,A4
                adda.l  D6,A4

	; -------------------
	; farbe des gegner-
	; punktes festsetzen

		move.w	#%1010110101010101,d6	; normale farbe
		tst.w	mon_a_shoot(a1)		; andere fuer schiessend
		beq.s	plsm_no_shoot
		move.w	#%0000010101000000,d6
plsm_no_shoot	tst.w	mon_a_died(a1)		; andere fuer gestorben
		beq.s	plsm_mon_alive
		move.w	#%1010100000000000,d6
plsm_mon_alive	move.w	d6,(a4)			; pixel setzen

		bra.s	pls_xy_out		; -> und raus

plsm_small
		movea.l	paint_lo_left,a4
		addi.w	#26,d2
		add.w	d2,d2
		adda.w	d2,a4
		move.w	#26,d6
		sub.w	d3,d6
		mulu	true_offi+2,d6
		adda.l	d6,a4

		move.w	#%1010110101010101,d6	; normale farbe
		tst.w	mon_a_shoot(a1)		; andere fuer schiessend
		beq.s	plsm_no_shoot2
		move.w	#%0000010101000000,d6
plsm_no_shoot2	tst.w	mon_a_died(a1)		; andere fuer gestorben
		beq.s	plsm_mon_alive2
		move.w	#%1010100000000000,d6
plsm_mon_alive2	move.w	d6,(a4)

pls_xy_out
                dbra    D7,pls_monst_loop

pls_monst_out:
		
                rts


;-----------------------

pls_make_scan:
                move.w  pl_scan_radius,D1
                add.w   vbl_time(PC),D1
                cmpi.w  #100,D1
                blt.s   pls_rad_ok_1
                moveq   #0,D1
pls_rad_ok_1:   move.w  D1,pl_scan_radius
                lsr.w   #2,D1
                bne.s   pls_rad_ok_2
                moveq   #1,D1
pls_rad_ok_2:   move.w  #%0111100100000100,D4
                cmpi.w  #20,D1
                bgt.s   pls_farbe_ok
 		move.w	#%0011001001100100,d4
pls_farbe_ok:   tst.w	pl_small
		bne.s	pls_make_scan_small
		movea.l	screen_1,a1
                adda.l  #640*219+49*2,A1

                bsr     kreis_scan

                rts

pls_make_scan_small

		movea.l	paint_lo_left,a1
		move.w	#26,d6
		mulu	true_offi+2,d6
		adda.l	d6,a1
		adda.w	#26*2,a1

		bsr	kreis_scan

		rts


;-----------------------

pls_remove

		tst.w	d0
		beq	pls_remove_one_screen

pls_remove_two_screens

                movea.l screen_1(PC),A1
                movea.l screen_2(PC),A2
                lea     leiste_gfx+128+640*3+23*2,A0
                adda.l  #640*194+23*2,A1
                adda.l  #640*194+23*2,A2

                moveq   #25,D7
pls_rem_loop2
		movem.l	(a0)+,d0-d6/a3-a6
		movem.l	d0-d6/a3-a6,(a1)
		movem.l	d0-d6/a3-a6,(a2)
		movem.l	(a0)+,d0-d6/a3-a6
		movem.l	d0-d6/a3-a6,44(a1)
		movem.l	d0-d6/a3-a6,44(a2)
		movem.l	(a0)+,d0-d4
		movem.l	d0-d4,88(a1)
		movem.l	d0-d4,88(a2)
		
                lea     640-54*2(A0),A0
                lea     640(A1),A1
                lea     640(A2),A2

                dbra    D7,pls_rem_loop2

                rts

;---

pls_remove_one_screen

                movea.l screen_1(PC),A1
                lea     leiste_gfx+128+640*3+23*2,A0
                adda.l  #640*194+23*2,A1

                moveq   #25,D7
pls_rem_loop1:
		movem.l	(a0)+,d0-d6/a3-a6
		movem.l	d0-d6/a3-a6,(a1)
		movem.l	(a0)+,d0-d6/a3-a6
		movem.l	d0-d6/a3-a6,44(a1)
		movem.l	(a0)+,d0-d4
		movem.l	d0-d4,88(a1)
		
                lea     640-54*2(A0),A0
                lea     640(A1),A1

                dbra    D7,pls_rem_loop1

                rts



;**************************************
;* pl_time (04/10/97)
;**************************************

; diese routine ist fuer aktivierte
; gegenstaende, die ein zeitlimit haben

pl_time
		tst.w	menue_flag		; wenn menue aktiv, dann
		bne	pltm_out		; zaehlt auch keine zeit herunten

		moveq	#0,d0
		movea.l	play_dat_ptr,a6
		movea.l	pd_things_ptr(a6),a5
		lea	th_time_speed,a4
		lea	pl_leiste_act,a3
		lea	pl_deaction_routs,a2

plt_loop
		tst.w	(a3,d0.w*2)		; aktiviert?
		beq.s	plt_skip		; nein -> auslassen

	; -------------------
	; gegenstand ist aktiviert

		move.w	2(a5,d0.w*4),d7		; time_limit
		bmi.s	plt_skip

	; -------------------
	; gegenstand ist aktiviert
	; und hat ein zeitlimit

		move.w	d7,d6
		move.w	vbl_time,d5
		move.w	(a4,d0.w*2),d4		; th_time_speed
		lsl.w	d4,d5
		sub.w	d5,d6
		bpl.s	plt_time_ok

	; -------------------
	; die zeit fuer den gegenstand 
	; ist abgelaufen

		move.w	#1,plf_things		; flag fuer update

		clr.w	(a5,d0.w*4)		; gegenstand loeschen
		move.w	#-1,2(a5,d0.w*4)	; und kein limit setzen
		move.l	(a2,d0.w*4),d4		; th_time_up_routines
		beq.s	plt_skip
		movea.l	d4,a1
		movem.l	d0/a2-a6,-(sp)
		jsr	(a1)
		movem.l	(sp)+,d0/a2-a6
		bra.s	plt_skip		
		
plt_time_ok

	; -------------------
	; die zeit nur einfach
	; herunterzaehlen

		move.w	d6,d5
		move.w	#$f000,d4
		and.w	d4,d6
		and.w	d4,d7
		cmp.w	d6,d7
		beq.s	plt_no_change
		move.w	#1,plf_things
plt_no_change	move.w	d5,2(a5,d0.w*4)

plt_skip
		addq.w	#1,d0
		cmpi.w	#things_max-1,d0
		blt	plt_loop

pltm_out
		rts


;**************************************
;* pl_keys (04/10/97)
;**************************************

pl_keys

		tst.w	terminal_flag
		bne	plk_out
		tst.w	cameraview_flag
		bne	plk_out
		tst.w	menue_flag		; menue aktiv?
		bne	plk_out			; ja -> raus
		movea.l	play_dat_ptr,a1		; spieler bereits
		tst.w	pd_health(a1)		; gestorbern?
		bmi	plk_out			; ja -> raus

	; -------------------
	; taste links

		lea	keytable(pc),a0		; taste help gedrueckt?
		tst.b	$62(a0)
		beq.s	plk_no_left		; nein -> ueberspringen

		clr.b	$62(a0)			; tastendruck loeschen
		movea.l	play_dat_ptr,a1
		move.w	pd_things_pos(a1),d0	; angezeigter mittlerer gegenstand
		movea.l	pd_things_ptr(a1),a2	; pointer fuer gegenstaende
		move.w	d0,d7
plk_left_loop	subq.w	#1,d0			; den aufgenommenen gegenstand
		bpl.s	plk_left_ok		; mit der naechst kleineren
		move.w	d7,d0			; nummer suchen (wenn moeglich)
		bra.s	plk_left_out
plk_left_ok	tst.w	(a2,d0.w*4)		; gegenstand vorhanden
		beq.s	plk_left_loop		; nein -> loopen
plk_left_out	move.w	d0,pd_things_pos(a1)	; gegenstandsposition eintragen
		move.w	#1,pd_things_flag(a1)	; und flag zum update (neuzeichnen)
		move.w	#1,plf_things		; der console setzen ...
plk_no_left

	; -------------------
	; taste rechts

		tst.b	$61(a0)			; taste undo gedrueckt
		beq.s	plk_no_right		; nein -> ueberspringen

		clr.b	$61(a0)			; tastendruck loeschen
		movea.l	play_dat_ptr,a1
		move.w	pd_things_pos(a1),d0	; aktuelle position holen
		movea.l	pd_things_ptr(a1),a2	; pointer fuer gegenstaende
		move.w	d0,d7

		tst.w	(a2,d0.w*4)		; naechst hoeheren gegenstand
		bne.s	plk_right_loop		; suchen, denn dieser ist
plk_r1_loop	addq.w	#1,d0			; der, der eigentlich in der
		cmpi.w	#things_max,d0		; console angezeigt wird
		blt.s	plk_r1_ok
		move.w	d7,d0
		bra.s	plk_right_out		; erst danach den dann
plk_r1_ok	tst.w	(a2,d0.w*4)		; (wiederum) naechsthoeheren
		beq.s	plk_r1_loop		; suchen ...

plk_right_loop	addq.w	#1,d0
		cmpi.w	#things_max,d0
		blt.s	plk_right_ok
		move.w	d7,d0
		bra.s	plk_right_out
plk_right_ok	tst.w	(a2,d0.w*4)
		beq.s	plk_right_loop
plk_right_out	move.w	d0,pd_things_pos(a1)
		move.w	#1,pd_things_flag(a1)
		move.w	#1,plf_things
plk_no_right

	; -------------------
	; taste enter

		tst.b	$1c(a0)			; taste enter gedrueckt?
		beq.s	plk_no_enter		; nein -> raus

		clr.b	$1c(a0)			; tastendruck loeschen
		movea.l	play_dat_ptr,a1
		move.w	pd_things_pos(a1),d0
		movea.l	pd_things_ptr(a1),a2
		tst.w	(a2,d0.w*4)
		bne.s	plk_enter_found
		move.w	d0,d7
plk_enter_loop	addq.w	#1,d0
		cmpi.w	#things_max,d0
		blt.s	plk_enter_ok
		move.w	d7,d0
		bra.s	plk_no_enter
plk_enter_ok	tst.w	(a2,d0.w*4)
                beq.s	plk_enter_loop
plk_enter_found

		move.w	#1,plf_things		; flag fuer update console

	; -------------------
	; herausfinden, ob der gegenstand aktiviert
	; oder deaktiviert werden soll
	; d0 = gegenstandsnummer

		lea	pl_leiste_act,a1	; gegenstand
		tst.w	(a1,d0.w*2)		; aktiviert?
		beq.s	plk_activate		; nein -> dann aktivieren

	; -------------------
	; gegenstand deaktivieren

		lea	pl_deaction_routs,a1
		move.l	(a1,d0.w*4),d2
		beq.s	plk_no_enter		; keine routine da -> nullpointer

		movea.l	d2,a1
		movem.l	d0/a0,-(sp)
		jsr	(a1)
		movem.l	(sp)+,d0/a0
		bra.s	plk_no_enter

	; -------------------
	; gegenstand aktivieren

plk_activate

		lea	pl_action_routs,a1
		move.l	(a1,d0.w*4),d2
		beq.s	plk_no_enter
		movea.l	d2,a1
		movem.l	d0/a0,-(sp)
		jsr	(a1)
		movem.l	(sp)+,d0/a0

plk_no_enter


plk_out
                rts


;**************************************
;* pl_left_action (04/10/97) 
;**************************************

pl_left_action

		move.w	pl_left_nb,d0
		bmi.s	plla_out

		lea	pl_left_routines,a2
		move.l	(a2,d0.w*8),d0
		beq.s	plla_out
		movea.l	d0,a0
		jsr	(a0)

plla_out
		rts


;**************************************
;* pl_shield (04/10/97)
;**************************************

pl_shield
		lea	plf_shield(pc),a0	; ist das flag fuer
		move.w	(a0),d0			; ein update des shield-wertes
		clr.w	(a0)			; gesetzt?
		tst.w	d0			
		beq	plsh_out		; nein -> dann auch nichts machen

		movea.l	play_dat_ptr(pc),a6
		move.w	pd_armor(a6),d0		; 0*256..100*256
		asr.w	#8,d0			; auf niveau 0..100 bringen
		bpl.s	plsh_positiv
		moveq	#0,d0
plsh_positiv	cmpi.w	#100,d0
		blt.s	plsh_in_range
		moveq	#100,d0
plsh_in_range

		mulu	#22,d0			; wert von niveau 0..100
		divu	#100,d0			; auf 0..22 bringen
		subq.w	#1,d0			; (fuer dbra)
	
		move.l	#640*228+220*2,d1
		lea	leiste_gfx+128+640*37+220*2,a0
		lea	leiste_gfx+128+640*70+135*2,a1
		bsr	ple_paint_energy

plsh_out
                rts


;**************************************
;* pl_energy (04/10/97)
;**************************************

pl_energy
		lea	plf_energy(pc),a0	; ist das flag fuer
		move.w	(a0),d0			; ein update des energy-wertes
		clr.w	(a0)			; gesetzt?
		tst.w	d0			
		beq	ple_out			; nein -> dann auch nichts machen

		movea.l	play_dat_ptr(pc),a6
		move.w	pd_health(a6),d0	; 0*256..100*256
		asr.w	#8,d0			; auf niveau 0..100 bringen
		bpl.s	ple_positiv
		moveq	#0,d0
ple_positiv	cmpi.w	#100,d0
		blt.s	ple_in_range
		moveq	#100,d0
ple_in_range

		mulu	#22,d0			; wert von niveau 0..100
		divu	#100,d0			; auf 0..22 bringen
		subq.w	#1,d0			; (fuer dbra)
	
		move.l	#640*228+193*2,d1
		lea	leiste_gfx+128+640*37+193*2,a0
		lea	leiste_gfx+128+640*70+119*2,a1

		bsr	ple_paint_energy

ple_out
                rts


;**************************************
;* ple_paint_energy (04/10/97)
;**************************************

; zeichnet einen balken (fuer energy oder shield)
; d0 = anzahl lines
; d1 = screen_offset (linke untere startecke)
; a0 = leeres feld in leiste_gfx (linke untere ecke)
; a1 = volles feld in leiste_gfx (linke untere ecke)

ple_paint_energy

		movem.l	screen_1(pc),a2-a3	; screen_1 und screen_2
		adda.l	d1,a2
		adda.l	d1,a3

	; -------------------
	; leeren hintergrund zeichnen

		movem.l	a2-a3,-(sp)
		moveq	#21,d1
plepe_clear	movem.l	(a0),d2-d7/a5-a6
		movem.l	d2-d7/a5-a6,(a2)
		movem.l	d2-d7/a5-a6,(a3)
		lea	-640(a0),a0
		lea	-640(a2),a2
		lea	-640(a3),a3
		dbra	d1,plepe_clear
		movem.l	(sp)+,a2-a3

	; -------------------
	; wert testen

		tst.w	d0
		bmi.s	plepe_out

	; -------------------
	; balken entspr. wert zeichnen


plepe_loop	movem.l	(a1),d2-d7/a5-a6
		movem.l	d2-d7/a5-a6,(a2)
		movem.l	d2-d7/a5-a6,(a3)
		lea	-640(a1),a1
		lea	-640(a2),a2
		lea	-640(a3),a3
		dbra	d0,plepe_loop

plepe_out
		rts


;**************************************
;* pl_convert_deci
;**************************************

; konvertiert die 16-bit binaerzahl in d0
; in eine 3-stellige ascii-zahl (pointer a0).
; fuehrende nullen werden zu leerzeichen ($20).

pl_convert_deci

                lea     pl_txt,A0
                ext.l   D0
                divu    #100,D0
                addi.b  #$30,D0
                cmpi.b  #$30,D0
                bne.s   plcd_no_1
                move.b  #" ",D0
plcd_no_1:      move.b  D0,(A0)
                clr.w   D0
                swap    D0
                divu    #10,D0
                addi.b  #$30,D0
                move.b  D0,1(A0)
                clr.w   D0
                swap    D0
                addi.b  #$30,D0
                move.b  D0,2(A0)

                cmpi.b  #" ",(A0)
                bne.s   plcd_out
                cmpi.b  #$30,1(A0)
                bne.s   plcd_out
                move.b  #" ",1(A0)
plcd_out:
                rts


;**************************************
;* pl_small_ammo
;**************************************

pl_small_ammo

	; -------------------
	; zuerst das 
	; hintergrundkaestchen ...

		movea.l	screen_1(pc),a2
		bsr.s	plsa_get_screen_offset
		adda.l	d0,a2
		subq.l	#2*2,a2			; und 
		move.w	true_offi+2,d0		; etwas
		add.w	d0,d0			; korri-
		suba.w	d0,a2			; gieren ...

		lea	leiste_gfx+128+640*72+302*2,a1
		move.w	true_offi+2,d6
		moveq	#8,d7					; hoehe
plsah_loop
		movem.l	(a1),d0-d5/a3-a5		; 9*2 = 18 pixel
		movem.l	d0-d5/a3-a5,(a2)
		lea	640(a1),a1
		adda.w	d6,a2
		dbra	d7,plsah_loop
	
	; -------------------
	; jetzt die zahlen ...

		movea.l	play_dat_ptr,a6
		move.w	pd_mun_type(a6),d0
		beq.s	plsa_fuss

		lea	pd_mun0_anz(a6),a5
		move.w	-2(a5,d0.w*2),d1		; vorhandene munition
		lea	pla_numbers(pc),a2		
		ext.l	d1
		divu	#100,d1
		move.w	d1,(a2)+
		swap	d1
		divu	#10,d1
		move.w	d1,(a2)+
		swap	d1
		move.w	d1,(a2)
		bra.s	plsa_zahlen

plsa_fuss
		lea	pla_numbers(pc),a0
		moveq	#10,d0
		move.w	d0,(a0)+
		move.w	d0,(a0)+
		move.w	d0,(a0)+

plsa_zahlen
		movea.l	screen_1(pc),a2
		bsr.s	plsa_get_screen_offset
		adda.l	d0,a2

		moveq	#2,d7
		lea	pla_numbers(pc),a0
		bsr	paint_smun_deci

plsa_out
		rts


;**************************************
;* plsa_get_screen_offset
;**************************************

; benutzte register: d1-d2
; rueckgabe: d0.l

plsa_get_screen_offset

		move.w	#189,d0
		tst.w	double_scan
		beq.s	plsaz_no_double
		move.w	#110,d0
plsaz_no_double	move.l	#68*2,d1
		move.w	true_offi+2,d2
		cmpi.w	#160*2,d2
		bne.s	plsaz_no_320
		lsr.w	#1,d1
plsaz_no_320	mulu	d2,d0
		add.l	d1,d0

		rts


;**************************************
;* paint_smun_deci
;**************************************

; a0: zeiger auf zahlen
; a2: zeiger auf screen
; a3: zeiger auf screen
; d7: anzahl an ziffern (-1)

paint_smun_deci
		lea	plaf_mun_off(pc),a1
		move.l	true_offi,d3
psmd_loop
		move.w	(a0)+,d0
		lea	plaf_mun_off(pc),a1
		lea	leiste_gfx+128,a4
		adda.l	0(a1,d0.w*4),a4

		movea.l	a2,a5
		
		moveq	#4,d0		
psmd_gfx_loop
		movem.l	(a4),d1-d2
		movem.l	d1-d2,(a2)
		adda.l	d3,a2
		lea	640(a4),a4
		dbra	d0,psmd_gfx_loop

		movea.l	a5,a2
		lea	5*2(a2),a2

		dbra	d7,psmd_loop

		rts


;**************************************
;* pl_ammo
;**************************************

pl_ammo
		lea	plf_weapon(pc),a0
		tst.w	(a0)
		beq.s	pla_no_wpncng

		clr.w	(a0)
		bsr	pla_big_icon
		bsr	pla_big_charges	
		bsr	pla_typenleuchte

		moveq	#1,d1
		moveq	#1,d2
		moveq	#1,d3
		moveq	#1,d4
		movem.w	d1-d4,plf_ammo1

pla_no_wpncng

	; -------------------
	; jetzt nacheinander
	; die einzelnen plf_ammx
	; flags testen und
	; die charges zeichnen

		lea	plf_ammo1(pc),a0
		moveq	#3,d7
pla_mun_loop	tst.w	(a0,d7.w*2)
		beq.s	plaml_no_flag
		clr.w	(a0,d7.w*2)
		movem.l	d7-a0,-(sp)
		bsr	pla_charges
		movem.l	(sp)+,d7-a0
plaml_no_flag	dbra	d7,pla_mun_loop

		rts


;**************************************
;* pla_big_icon
;**************************************		


pla_big_icon

	; -------------------
	; zeichnen des grossen
	; icons

		movea.l	play_dat_ptr(pc),a6
		move.w	pd_mun_type(a6),d0
		lea	leiste_gfx+128,a0
		lea	plabi_mun0_off(pc),a1
		adda.l	(a1,d0.w*4),a0
		movem.l	screen_1,a1-a2
		move.l	plabi_soff(pc),d1
		adda.l	d1,a1
		adda.l	d1,a2

		moveq	#20,d0
plabi_loop	movem.l	(a0),d1-d7/a3-a5
		movem.l	d1-d7/a3-a5,(a1)
		movem.l	d1-d7/a3-a5,(a2)
		move.w	40(a0),d1
		move.w	d1,40(a1)
		move.w	d1,40(a2)
		lea	640(a0),a0
		lea	640(a1),a1
		lea	640(a2),a2
		dbra	d0,plabi_loop

plabi_out
		rts

;---

plabi_soff	dc.l	640*200+252*2

plabi_mun0_off	dc.l	640*9+252*2
plabi_mun1_off	dc.l	640*49+77*2
plabi_mun2_off	dc.l	640*49+98*2
plabi_mun3_off	dc.l	640*49+164*2
plabi_mun4_off	dc.l	640*49+185*2



;**************************************
;* pla_big_charges
;**************************************

pla_big_charges		
		movea.l	play_dat_ptr,a6
		lea	pla_numbers(pc),a2		
		move.w	pd_mun_type(a6),d0
		beq	plabc_fuss
		lea	pd_mun0_anz(a6),a5
		move.w	-2(a5,d0.w*2),d1

		ext.l	d1
		divu	#100,d1
		move.w	d1,(a2)+
		swap	d1
		divu	#10,d1
		move.w	d1,(a2)+
		swap	d1
		move.w	d1,(a2)
		bra.s	plabc_now

plabc_fuss
		moveq	#10,d0
		move.w	d0,(a0)+
		move.w	d0,(a0)+
		move.w	d0,(a0)+

plabc_now
		movem.l	screen_1(pc),a2-a3
		move.l	#640*225+252*2,d0
		adda.l	d0,a2
		adda.l	d0,a3
		moveq	#2,d7
		lea	pla_numbers(pc),a0
		bsr	paint_mun_deci

plabc_out
		rts



;**************************************
;* paint_mun_deci
;**************************************

; zeichnen der grossen vorratsanzeige

; a0 = zeiger auf zahlen
; a2 = zeiger auf screen
; a3 = zeiger auf screen
; d7 = anzahl an ziffern (-1)

paint_mun_deci

pmd_loop
		move.w	(a0)+,d0
		lea	pla_mun_off(pc),a1
		lea	leiste_gfx+128,a4
		adda.l	0(a1,d0.w*4),a4

		movea.l	a2,a5
		movea.l	a3,a1		; zwischenspeichern

		moveq	#10,d0		; hoehe = 11
pmd_gfx_loop
		movem.w	(a4),a6/d1-d6
		movem.w	a6/d1-d6,(a2)
		movem.w	a6/d1-d6,(a3)
		lea	640(a2),a2
		lea	640(a3),a3
		lea	640(a4),a4
		dbra	d0,pmd_gfx_loop

		movea.l	a5,a2
		movea.l	a1,a3
		lea	7*2(a2),a2
		lea	7*2(a3),a3

		dbra	d7,pmd_loop

		rts

;---

pla_numbers	dc.w	0,0,0

pla_mun_off	dc.l	640*49+70*2	; 0
		dc.l	640*49+7*2	; 1
		dc.l	640*49+14*2	; 2
		dc.l	640*49+21*2	; 3
		dc.l	640*49+28*2	; 4
		dc.l	640*49+35*2	; 5
		dc.l	640*49+42*2	; 6
		dc.l	640*49+49*2	; 7
		dc.l	640*49+56*2	; 8
		dc.l	640*49+63*2	; 9
		dc.l	640*49		; leer


;**************************************
;* pla_typenleuchte
;**************************************

pla_typenleuchte

	; -------------------
	; zuerst alle
	; felder loeschen

		lea	leiste_gfx+128+640*9+278*2,a0
		movem.l	screen_1(pc),a4-a5
		lea	pl_munl_soffs,a1

		moveq	#3,d0
		move.l	#640,d5
plat_loop	move.l	(a1,d0.w*4),d1
		movea.l	a4,a2
		movea.l	a5,a3
		adda.l	d1,a2
		adda.l	d1,a3
		moveq	#5,d1
plat_gfx_loop	movem.l	(a0),d2-d4
		movem.l	d2-d4,(a2)
		movem.l	d2-d4,(a3)
		adda.l	d5,a0
		adda.l	d5,a2
		adda.l	d5,a3
		dbra	d1,plat_gfx_loop

		dbra	d0,plat_loop

	; -------------------
	; jetzt das richtige
	; erleuchtete

		movea.l	play_dat_ptr(pc),a6
		move.w	pd_mun_type(a6),d0
		beq.s	plat_out

		lea	leiste_gfx+128+640*56+157*2,a0
		movem.l	screen_1(pc),a2-a3
		move.l	-4(a1,d0.w*4),d1
		adda.l	d1,a2
		adda.l	d1,a3
		moveq	#5,d1
plat_gfx_loop2	movem.l	(a0),d2-d4
		movem.l	d2-d4,(a2)
		movem.l	d2-d4,(a3)
		adda.l	d5,a0
		adda.l	d5,a2
		adda.l	d5,a3
		dbra	d1,plat_gfx_loop2

plat_out
		rts


;**************************************
;* pla_charges
;**************************************

; d7 = mun_type 0..3

pla_charges

		movea.l	play_dat_ptr(pc),a6
		move.w	pd_mun_type(a6),d6
		beq.s	plac_now
		subq.w	#1,d6
		cmp.w	d6,d7
		bne.s	plac_now

		move.w	d7,-(sp)
		bsr	pla_big_charges
		move.w	(sp)+,d7

plac_now
		lea	pl_mun_soffs(pc),a5
		movea.l	play_dat_ptr(pc),a6
		lea	pd_mun0_anz(a6),a4

	; -------------------
	; a4 = pointer auf munitionsanzahlen
	; a5 = pointer auf screen-offsets

		movem.l	screen_1(pc),a2-a3
		move.l	(a5,d7.w*4),d2
		adda.l	d2,a2
		adda.l	d2,a3
		move.w	(a4,d7.w*2),d0
		
		lea	plaf_numbers(pc),a0
		ext.l	d0
		divu	#100,d0
		move.w	d0,(a0)
		swap	d0
		divu	#10,d0
		move.w	d0,2(a0)
		swap	d0
		move.w	d0,4(a0)

		lea	pd_pistol1(a6),a1
		lea	plaf_mun_off(pc),a4
		tst.w	(a1,d7.w*2)
		bne.s	plac_waffe_vorh
		lea	plaf_mun_off2(pc),a4
plac_waffe_vorh	moveq	#2,d0
		bsr	paint_muns_deci

                rts


;**************************************
;* paint_muns_deci
;**************************************

; a0 = zeiger auf zahlen
; a2 = zeiger auf screen
; a3 = zeiger auf screen
; a4 = plaf_mun_off 
; d0 = anzahl an ziffern (-1)

paint_muns_deci

		moveq	#10,d7
pmfd_loop
		move.w	(a0)+,d1
		move.l	(a4,d1.w*4),a5
		adda.l	#leiste_gfx+128,a5
		movea.l	a2,a1
		movea.l	a3,a6
		move.l	#640,d6
		moveq	#4,d5		; hoehe = 5
pmfd_gfx_loop	movem.w	(a5),d1-d4
		movem.w	d1-d4,(a1)
		movem.w	d1-d4,(a6)
		adda.l	d6,a1
		adda.l	d6,a6
		adda.l	d6,a5
		dbra	d5,pmfd_gfx_loop
		adda.l	d7,a2
		adda.l	d7,a3
		dbra	d0,pmfd_loop

		rts

;---

plaf_numbers	dc.w	0,0,0

plaf_mun_off	dc.l	640*50+212*2	; 0
		dc.l	640*50+217*2	; 1
		dc.l	640*50+222*2	; 2
		dc.l	640*50+227*2	; 3
		dc.l	640*50+232*2	; 4
		dc.l	640*50+237*2	; 5
		dc.l	640*50+242*2	; 6
		dc.l	640*50+247*2	; 7
		dc.l	640*50+252*2	; 8
		dc.l	640*50+257*2	; 9
		dc.l	640*50+207*2	; leer

plaf_mun_off2	dc.l	640*66+265*2+10		; 0
		dc.l	640*66+265*2+20		; 1
		dc.l	640*66+265*2+30		; 2
		dc.l	640*66+265*2+40		; 3
		dc.l	640*66+265*2+50		; 4
		dc.l	640*66+265*2+60		; 5
		dc.l	640*66+265*2+70		; 6
		dc.l	640*66+265*2+80		; 7
		dc.l	640*66+265*2+90		; 8
		dc.l	640*66+265*2+100	; 9
		dc.l	640*66+265*2		; leer



;**************************************
;* pl_small_thing
;**************************************


pl_small_thing

		movea.l	play_dat_ptr,a6

	; -------------------
	; screen offset berechnen

		lea	plst_soffs(pc),a1
		move.w	true_offi+2,d5
		move.w	d5,d7
		move.w	#165,d6
		tst.w	double_scan
		beq.s	plst_no_double
		move.w	#100,d6
plst_no_double	mulu	d6,d7
		moveq	#8*2,d0
		cmpi.w	#320,d5
		bne.s	plst_no_320
		lsr.w	#1,d0
plst_no_320	add.l	d0,d7
		move.l	d7,(a1)

		movea.l	pd_things_ptr(a6),a0	; pointer auf things
		move.w	pd_things_pos(a6),d0	; position in things-liste
				
		moveq	#1,d1			; pot_direction
		bsr	pl_one_small_thing

plst_out
                rts

;---

plst_soffs	dc.l	0


;**************************************
;* pl_things
;**************************************

pl_things
		lea	plf_things(pc),a0
		tst.w	(a0)
		beq.s	plt_out

		clr.w	(a0)
		movea.l	play_dat_ptr(pc),a6
		movea.l	pd_things_ptr(a6),a0
		move.w	pd_things_pos(a6),d0
		lea	pl_thg_soffs(pc),a1

		move.w	d0,-(sp)
		moveq	#1,d1
		bsr.s	pl_one_thing
		bsr.s	pl_one_thing
		bsr.s	pl_one_thing
		move.w	(sp)+,d0

		subq.w	#1,d0
		moveq	#-1,d1
		bsr.s	pl_one_thing
		bsr.s	pl_one_thing

plt_out
		rts


;**************************************
;* pl_one_thing
;**************************************

; d0 = aktuelle position in things
; d1 = pot_direction
; a0 = pointer auf things
; a1 = pl_thg_soffs

; rueckgabe:

; d0 = position in things +(-) 1
; d1 = pot_direction
; a0 = pointer auf things
; a1 = pl_thg_soffs + 4


pl_one_thing
		move.w	d0,plottb_save

plot_loop
		tst.w	(a0,d0.w*4)
		bne.s	plot_thing_found
		add.w	d1,d0
		bpl.s	plot_not_neg
		moveq	#-1,d0
		bra	plot_thing_black
plot_not_neg	cmpi.w	#things_max,d0
		blt.s	plot_loop

		bra	plot_thing_black


plot_thing_found

	; -------------------
	; gegenstand wurde gefunden (d0)

		tst.w	d0
		bmi	plot_thing_black

		lea	pl_thg_offs,a4
		movea.l	pl_thg_gfx_ptr,a2
		adda.l	(a4,d0.w*4),a2
		movem.l	screen_1(pc),a3-a4
		adda.l	(a1),a3
		adda.l	(a1)+,a4

	; -------------------
	; zuerst das entsprechende
	; symbol (icon) zeichnen

		moveq	#15,d7
pltf_loop	movem.l	(a2)+,d2-d5
		movem.l	d2-d5,(a3)
		movem.l	d2-d5,(a4)
		movem.l	(a2)+,d2-d5
		movem.l	d2-d5,16(a3)
		movem.l	d2-d5,16(a4)
		lea	640-32(a2),a2
		lea	640(a3),a3
		lea	640(a4),a4		
		dbra	d7,pltf_loop

	; -------------------
	; jetzt testen, ob der gegenstand
	; aktiviert worden ist
	; ist er nicht aktiviert worden,
	; so ein leeres lichtfeld zeichnen

	; d0 = gegenstandsnummer
	; a0 = pd_thing_ptr

		lea	pl_leiste_act,a2
		tst.w	(a2,d0.w*2)		; gegenstand aktiviert?
		bne	pltf_activated		; ja -> raus

	; -------------------
	; gegenstand ist nicht aktiviert,
	; also ein leeres lichtfeld

		lea	leiste_gfx+128+640*42+94*2,a2
		lea	640*5+1*2(a3),a3
		lea	640*5+1*2(a4),a4

		movem.w	d0-d1,-(sp)
		move.l	#640,d0
		moveq	#6,d7
pltfnl_loop	movem.l	(a2),d1-d6
		movem.l	d1-d6,(a3)
		movem.l	d1-d6,(a4)
		move.w	24(a2),d1
		move.w	d1,24(a3)
		move.w	d1,24(a4)
		adda.l	d0,a2
		adda.l	d0,a3
		adda.l	d0,a4
		dbra	d7,pltfnl_loop
		movem.w	(sp)+,d0-d1

		bra	pltf_out


pltf_activated

	; -------------------
	; gegenstand ist aktiviert
	; zeitlimit ja oder nein?

		move.w	2(a0,d0.w*4),d4		; time_limit
		bmi	pltf_light

	; -------------------
	; gegenstand ist aktiviert
	; und hat ein zeitlimit
	; also ein leeres lichtfeld
	; und danach die zustandsanzeige
		
		movem.l	d0-d1/d4/a3-a4,-(sp)
		lea	leiste_gfx+128+640*42+94*2,a2
		lea	640*5+1*2(a3),a3
		lea	640*5+1*2(a4),a4
		move.l	#640,d0
		moveq	#6,d7
pltfnl_loop2	movem.l	(a2),d1-d6
		movem.l	d1-d6,(a3)
		movem.l	d1-d6,(a4)
		move.w	24(a2),d1
		move.w	d1,24(a3)
		move.w	d1,24(a4)	
		adda.l	d0,a2
		adda.l	d0,a3
		adda.l	d0,a4
		dbra	d7,pltfnl_loop2
		movem.l	(sp)+,d0-d1/d4/a3-a4

		lsl.l	#4,d4
		swap	d4
		andi.w	#$0007,d4
		move.w	d4,d3
		lea	pl_thg_color(pc),a2
		lea	640*6+4*2(a3),a3
		lea	640*6+4*2(a4),a4
pltf_time_loop	move.w	(a2)+,d2
		move.w	d2,1920(a3)
		move.w	d2,1920(a4)
		move.w	d2,1280(a3)
		move.w	d2,1280(a4)
		move.w	d2,640(a3)
		move.w	d2,640(a4)
		move.w	d2,(a3)+
		move.w	d2,(a4)+
		dbra	d4,pltf_time_loop

		moveq	#7,d4
		sub.w	d3,d4
		beq	pltf_out
		subq.w	#1,d4
		moveq	#0,d2
pltf_time_loop2	move.w	d2,1920(a3)
		move.w	d2,1920(a4)
		move.w	d2,1280(a3)
		move.w	d2,1280(a4)
		move.w	d2,640(a3)
		move.w	d2,640(a4)
		move.w	d2,(a3)+
		move.w	d2,(a4)+
		dbra	d4,pltf_time_loop2

		bra	pltf_out

pltf_light

	; -------------------
	; gegenstand ist aktiviert und
	; hat kein zeitlimit, also
	; ein erleuchtetes lichtfeld zeichnen

		lea	leiste_gfx+128+640*49+151*2,a2
		lea	640*5+1*2(a3),a3
		lea	640*5+1*2(a4),a4

		movem.w	d0-d1,-(sp)
		move.l	#640,d0	
		moveq	#6,d7
pltfnl_loop3	movem.l	(a2),d1-d6
		movem.l	d1-d6,(a3)
		movem.l	d1-d6,(a4)
		move.w	24(a2),d1
		move.w	d1,24(a3)
		move.w	d1,24(a4)
		adda.l	d0,a2
		adda.l	d0,a3
		adda.l	d0,a4
		dbra	d7,pltfnl_loop3
		movem.w	(sp)+,d0-d1

pltf_out
		add.w	d1,d0

		rts


plot_thing_black

	; -------------------
	; ein leeres gegenstandsicon
	; zeichnen

		move.l	(a1)+,d2
		movem.l	screen_1(pc),a3-a4
		adda.l	d2,a3
		adda.l	d2,a4

		movem.w	d0-d1,-(sp)
		lea	leiste_gfx+128+640*21+93*2,a2
		move.l	#640,d0
		moveq	#15,d7
pltfb_loop	movem.l	(a2),d1-d6/a5-a6
		movem.l	d1-d6/a5-a6,(a3)
		movem.l	d1-d6/a5-a6,(a4)
		adda.l	d0,a2
		adda.l	d0,a3
		adda.l	d0,a4
		dbra	d7,pltfb_loop

		lea	leiste_gfx+128+640*42+94*2,a2
		lea	640*5+1*2(a3),a3
		lea	640*5+1*2(a4),a4
	
		moveq	#6,d7
pltfnl_loop4	movem.l	(a2),d1-d6
		movem.l	d1-d6,(a3)
		movem.l	d1-d6,(a4)
		move.w	24(a2),d1
		move.w	d1,24(a3)
		move.w	d1,24(a4)
		adda.l	d0,a2
		adda.l	d0,a3
		adda.l	d0,a4
		dbra	d7,pltfnl_loop4

		movem.w	(sp)+,d0-d1
		move.w	plottb_save(pc),d0

                rts

plottb_save	dc.w	0

;**************************************
;* pl_small_energy
;**************************************

pl_small_energy
		move.w	#195,d0		; y-zeile bestimmen
		tst.w	double_scan
		beq.s	plse_no_double
		move.w	#116,d0
plse_no_double	mulu	true_offi+2,d0
		movea.l	screen_1,a1
		adda.l	d0,a1
		moveq	#30*2,d0	; x-spalte bestimmen
		cmpi.w	#320,true_offi+2
		bne.s	plse_no_320
		lsr.w	#1,d0
plse_no_320	adda.w	d0,a1

		lea	leiste_gfx+128+640*70+121*2,a0

		movea.l	play_dat_ptr,a6
		move.w	pd_health(a6),d0
		asr.w	#8,d0
		bmi.s	plse_zero
		mulu	#22,d0
		divu	#100,d0
		beq.s	plse_zero
		subq.w	#1,d0

plse_zero		
		bsr	pl_small_balken
		
		rts


;**************************************
;* pl_small_shield
;**************************************


pl_small_shield

		move.w	#195,d0
		tst.w	double_scan
		beq.s	plss_no_double
		move.w	#116,d0
plss_no_double	mulu	true_offi+2,d0
		movea.l	screen_1,a1
		adda.l	d0,a1
		moveq	#48*2,d0
		cmpi.w	#320,true_offi+2
		bne.s	plss_no_320
		lsr.w	#1,d0
plss_no_320	adda.w	d0,a1

		lea	leiste_gfx+128+640*70+137*2,a0

		movea.l	play_dat_ptr,a6
		move.w	pd_armor(a6),d0
		asr.w	#8,d0
		bmi.s	plss_zero
		mulu	#22,d0
		divu	#100,d0
		beq.s	plss_zero
		subq.w	#1,d0
plss_zero		
		bsr	pl_small_balken
		
		rts


;**************************************
;* pl_small_balken
;**************************************

; a0 = adresse grafik
; a1 = adresse screen
; d0 = wert (0..21 oder negativ)

pl_small_balken

		move.w	true_offi+2,d6
		cmpi.w	#320,d6
		beq	plsb_320
		tst.w	double_scan
		bne.s	plsb_640double

	; -------------------
	; version fuer 512 und 640
	; ohne double_scan

		move.w	d0,d1			; zwischenspeichern
		bpl.s	plsb_i640
		moveq	#21,d0
		bra.s	plsb_only640
plsb_i640	movem.l	(a0),d2-d5/a2-a4
		movem.l	d2-d5/a2-a4,(a1)
		lea	-640(a0),a0
		sub.w	d6,a1
		dbra	d0,plsb_i640

		moveq	#21,d0
		sub.w	d1,d0
		beq.s	plsb_out640
		subq.w	#1,d0
plsb_only640	moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5
		movea.l	d5,a2
		movea.l	d5,a3
plsb_c640	movem.l	d1-d5/a2-a3,(a1)
		sub.w	d6,a1
		dbra	d0,plsb_c640

plsb_out640
		rts

;--

plsb_640double
		; version fuer 512 und 640 mit double_scan

		addq.w	#1,d0
		lsr.w	#1,d0		
		beq.s	plsb_640d_ok
		subq.w	#1,d0
plsb_640d_ok	move.w	d0,d1		; zwischenspeichern
		bpl.s	plsb_i640d
		moveq	#11,d0
		bra.s	plsb_only640d
plsb_i640d	movem.l	(a0),d2-d5/a2-a4
		movem.l	d2-d5/a2-a4,(a1)
		lea	-640*2(a0),a0
		sub.w	d6,a1
		dbra	d0,plsb_i640d

		moveq	#10,d0
		sub.w	d1,d0
		beq.s	plsb_out640d
		subq.w	#1,d0
plsb_only640d	moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5
		movea.l	d5,a2
		movea.l	d5,a3
plsb_c640d	movem.l	d1-d5/a2-a3,(a1)
		sub.w	d6,a1
		dbra	d0,plsb_c640d

plsb_out640d
		rts

;--

plsb_320
		; version fuer 320 (ohne double_scan)

		move.w	d0,d1		; zwischenspeichern
		bpl.s	plsb_i320
		moveq	#21,d0
		bra.s	plsb_only320
plsb_i320	movem.l	(a0),d2-d5/a2-a4
		movem.w	d2-d5/a2-a4,(a1)
		lea	-640(a0),a0
		sub.w	d6,a1
		dbra	d0,plsb_i320

		moveq	#21,d0
		sub.w	d1,d0
		beq.s	plsb_out320
		subq.w	#1,d0
plsb_only320	moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5
		movea.l	d5,a2
		movea.l	d5,a3
plsb_c320	movem.w	d1-d5/a2-a3,(a1)
		sub.w	d6,a1
		dbra	d0,plsb_c320

plsb_out320
		rts


;**************************************
;* pl_one_small_thing
;**************************************

; d0 = aktuelle position in things
; d1 = pot_direction
; a0 = pointer auf things
; a1 = pl_thg_soffs

; rueckgabe:

; d0 = position in things +(-) 1
; d1 = pot_direction
; a0 = pointer auf things
; a1 = pl_thg_soffs + 4

; zeichnet nur auf den logischen bildschirm


pl_one_small_thing

		move.w	d0,plottb_save

plost_loop
		tst.w	(a0,d0.w*4)
		bne.s	plost_thing_found
		add.w	d1,d0
		bpl.s	plost_pot_not_neg
		moveq	#-1,d0
		bra	plost_one_small_thing_black

plost_pot_not_neg
		cmpi.w	#things_max,d0
		blt.s	plost_loop
		bra	plost_one_small_thing_black

plost_thing_found

	; -------------------
	; gegenstand wurde gefunden

		tst.w	d0				; nochmaliger sicherheitstest
		bmi	plost_one_small_thing_black	; nichts -> raus

		lea	pl_thg_offs,a4
		movea.l	pl_thg_gfx_ptr,a2
		adda.l	(a4,d0.w*4),a2
		movea.l	screen_1(pc),a3
		adda.l	(a1),a3

	; -------------------
	; jetzt geht es in die unterschiedlichen
	; routinen rein fuer verschiedene true_offi's

		cmpi.w	#320,true_offi+2
		beq	plost_now_320			; version fuer vga

	; -------------------
	; version fuer 
	; true_offi 640 und 512

plost_now_640

		tst.w	double_scan
		bne	plost_now_640double	; version fuer double_scan (rgb)

		move.w	true_offi+2,d6

	; -------------------
	; jetzt 3 zeilen ueber dem icon

		move.w	d1,-(sp)
		move.l	a2,-(sp)
		lea	leiste_gfx+128+18*640+129*2,a2
		moveq	#2,d7
plost_i640	movem.l	(a2),d1-d5/a4-a6
		movem.l	d1-d5/a4-a6,(a3)
		adda.w	d6,a3
		lea	640(a2),a2
		dbra	d7,plost_i640
		movea.l	(sp)+,a2

	; -------------------
	; jetzt das icon selbst (16 zeilen)

		moveq	#15,d7
plost_16i640	movem.l	(a2),d1-d5/a4-a6
		movem.l	d1-d5/a4-a6,(a3)
		lea	640(a2),a2
		adda.w	d6,a3
		dbra	d7,plost_16i640

	; -------------------
	; jetzt wieder 3 zeilen 
	; unter dem icon

		lea	leiste_gfx+128+37*640+129*2,a2
		moveq	#2,d7
plost_3i640	movem.l	(a2),d1-d5/a4-a6
		movem.l	d1-d5/a4-a6,(a3)
		adda.w	d6,a3
		lea	640(a2),a2
		dbra	d7,plost_3i640

		lea	leiste_gfx+128+640*41+129*2,a2

	; -------------------
	; eine zeile freilassen

		adda.w	d6,a3				

		movea.l	a3,a6			; zwischenspeichern
		move.l	a6,-(sp)
		moveq	#7,d7
plost_leli640	movem.l	(a2),d1-d5/a4-a6
		movem.l	d1-d5/a4-a6,(a3)
		lea	640(a2),a2
		adda.w	d6,a3
		dbra	d7,plost_leli640	
		movea.l	(sp)+,a6

		move.w	(sp)+,d1

		lea	pl_leiste_act,a2
		tst.w	(a2,d0.w*2)		; gegenstand aktiviert?
		beq	plost_out		; nicht aktiviert -> raus

	; -------------------
	; gegenstand ist aktiviert,
	; jetzt entweder mit oder 
	; ohne time_limit

		move.w	2(a0,d0.w*4),d1		; time_limit
		bmi	plosta_nolim640

		move.w	d1,-(sp)
		lsl.l	#4,d1
		swap	d1
		andi.w	#%111,d1
		move.w	d1,d7

		lea	pl_thg_color(pc),a2
		move.w	d6,d5			; d6 = 1 * true_offi
		add.w	d5,d5
		move.w	d5,d4			; d4 = 2 * true_offi
		add.w	d6,d5
		move.w	d5,d3			; d3 = 3 * true_offi
		move.w	d4,d5
		addi.w	#4*2,d5			; true_offi * 2 + 4 * 2
		adda.w	d5,a6
	

plost_atl640	move.w	(a2)+,d2
		move.w	d2,(a6,d3.w)
		move.w	d2,(a6,d4.w)
		move.w	d2,(a6,d6.w)
		move.w	d2,(a6)+
		dbra	d1,plost_atl640

		move.w	(sp)+,d1

		moveq	#7,d5
		sub.w	d7,d5
		beq	plost_out		; ganz raus
		subq.w	#1,d5
plost_atb640	clr.w	(a6,d3.w)
		clr.w	(a6,d4.w)
		clr.w	(a6,d6.w)
		clr.w	(a6)+
		dbra	d5,plost_atb640

		bra	plost_out		; und ganz raus

plosta_nolim640

	; -------------------
	; gegenstand ist aktiviert, hat
	; aber kein time limit, also
	; ein erleuchtetes lichtfeld zeichnen

		lea	leiste_gfx+128+640*49+151*2,a2
		addq.l	#1*2,a6
		adda.w	d6,a6		; a6 = a6 + 640 * 1 + 1 * 2

		move.w	d1,-(sp)
		moveq	#6,d7
plosta_nl640	movem.l	(a2),d1-d5/a3
		movem.l	d1-d5/a3,(a6)
		move.w	24(a2),24(a6)
		lea	640(a2),a2
		adda.w	d6,a6
		dbra	d7,plosta_nl640
		move.w	(sp)+,d1

		bra	plost_out



plost_now_640double

	; -------------------
	; version fuer 640 und 512
	; mit double_scan

		move.w	true_offi+2,d6

	; -------------------
	; jetzt 2 zeilen ueber dem icon

		move.w	d1,-(sp)
		move.l	a2,-(sp)
		lea	leiste_gfx+128+18*640+129*2,a2
		moveq	#1,d7
plost_i640d	movem.l	(a2),d1-d5/a4-a6
		movem.l	d1-d5/a4-a6,(a3)
		adda.w	d6,a3
		lea	640*2(a2),a2
		dbra	d7,plost_i640d
		movea.l	(sp)+,a2

	; -------------------
	; jetzt das icon selbst (8 zeilen)

		moveq	#7,d7
plost_16i640d	movem.l	(a2),d1-d5/a4-a6
		movem.l	d1-d5/a4-a6,(a3)
		lea	640*2(a2),a2
		adda.w	d6,a3
		dbra	d7,plost_16i640d

	; -------------------
	; jetzt wieder 2 zeilen unter dem icon

		lea	leiste_gfx+128+37*640+129*2,a2
		moveq	#1,d7
plost_3i640d	movem.l	(a2),d1-d5/a4-a6
		movem.l	d1-d5/a4-a6,(a3)
		adda.w	d6,a3
		lea	640*2(a2),a2
		dbra	d7,plost_3i640d

		lea	leiste_gfx+128+640*41+129*2,a2
		adda.w	d6,a3

		movea.l	a3,a6
		move.l	a6,-(sp)
		moveq	#3,d7
plost_leli640d	movem.l	(a2),d1-d5/a4-a6
		movem.l	d1-d5/a4-a6,(a3)
		lea	640*2(a2),a2
		adda.w	d6,a3
		dbra	d7,plost_leli640d
		movea.l	(sp)+,a6
		move.w	(sp)+,d1

		lea	pl_leiste_act,a2
		tst.w	(a2,d0.w*2)		; gegenstand aktiviert?
		beq	plost_out		; wenn nicht aktiviert -> raus

	; -------------------
	; gegenstand ist aktiviert,
	; jetzt entweder mit oder ohne time_limit

		move.w	2(a0,d0.w*4),d1		; time_limit
		bmi	plosta_nolim640d

		move.w	d1,-(sp)
		lsl.l	#4,d1
		swap	d1
		andi.w	#%111,d1
		move.w	d1,d7

		lea	pl_thg_color(pc),a2
		move.w	d6,d5			; d6 = 1 * true_offi
		adda.w	d6,a6	
		adda.w	#4*2,a6			; true_offi * 1 + 4 * 2

plost_atl640d	move.w	(a2)+,d2
		move.w	d2,(a6,d6.w)
		move.w	d2,(a6)+
		dbra	d1,plost_atl640d
		move.w	(sp)+,d1

		moveq	#7,d5
		sub.w	d7,d5
		beq	plost_out		; ganz raus
		subq.w	#1,d5
plost_atb640d	clr.w	(a6,d6.w)
		clr.w	(a6)+
		dbra	d5,plost_atb640d

		bra	plost_out		; und ganz raus


plosta_nolim640d

	; -------------------
	; gegenstand ist aktiviert, hat
	; aber kein time limit, also
	; ein erleuchtetes lichtfeld zeichnen

		lea	leiste_gfx+128+640*51+151*2,a2
		addq.l	#1*2,a6
		adda.w	d6,a6			; a6 = a6 + 640 * 1 + 1 * 2

		move.w	d1,-(sp)
		moveq	#2,d7
plosta_nl640d	movem.l	(a2),d1-d5/a3
		movem.l	d1-d5/a3,(a6)
		move.w	24(a2),24(a6)
		lea	640*2(a2),a2
		adda.w	d6,a6
		dbra	d7,plosta_nl640d
		move.w	(sp)+,d1

		bra	plost_out



plost_now_320

	; -------------------
	; version fuer
	; vga 320

	; jetzt 3 zeilen ueber dem icon

		move.w	d1,-(sp)
		lea	leiste_gfx+128+18*640+129*2,a4
		moveq	#2,d7
plost_i320	movem.l	(a4),d1-d6/a5-a6
		movem.w	d1-d6/a5-a6,(a3)
		lea	320(a3),a3
		lea	640(a4),a4
		dbra	d7,plost_i320

	; -------------------
	; jetzt das icon selbst (16 zeilen)

		moveq	#15,d7
plost_16i320	movem.l	(a2),d1-d6/a5-a6
		movem.w	d1-d6/a5-a6,(a3)
		lea	640(a2),a2
		lea	320(a3),a3
		dbra	d7,plost_16i320

	; -------------------
	; jetzt wieder 3 zeilen unter dem icon

		lea	leiste_gfx+128+37*640+129*2,a4
		moveq	#2,d7
plost_3i320	movem.l	(a4),d1-d6/a5-a6
		movem.w	d1-d6/a5-a6,(a3)
		lea	320(a3),a3
		lea	640(a4),a4
		dbra	d7,plost_3i320

		lea	leiste_gfx+128+640*41+129*2,a2
		lea	320(a3),a3		; eine zeile freilassen

		movea.l	a3,a6			; zwischenspeichern
		moveq	#7,d7
plost_leli320	movem.l	(a2),d1-d6/a4-a5
		movem.w	d1-d6/a4-a5,(a3)
		lea	640(a2),a2
		lea	320(a3),a3
		dbra	d7,plost_leli320	
		move.w	(sp)+,d1

		lea	pl_leiste_act,a2
		tst.w	(a2,d0.w*2)		; gegenstand aktiviert?
		beq	plost_out		; wenn nicht aktiviert -> raus

	; -------------------
	; gegenstand ist aktiviert,
	; jetzt entweder mit oder ohne time_limit

		move.w	2(a0,d0.w*4),d1		; time_limit
		bmi	plosta_nolim320

		move.w	d1,-(sp)
		lsl.l	#3,d1
		swap	d1
		andi.w	#%11,d1
		move.w	d1,d3

		lea	pl_thg_color(pc),a2
		lea	320*3+2*2(a6),a6
plost_atl320	move.w	(a2),d2
		move.w	d2,960(a6)
		move.w	d2,640(a6)
		move.w	d2,320(a6)
		move.w	d2,(a6)+
		addq.l	#4,a2
		dbra	d1,plost_atl320
		move.w	(sp)+,d1

		moveq	#3,d4
		sub.w	d3,d4
		beq	plost_out		; ganz raus
		subq.w	#1,d4
plost_atb320	clr.w	960(a6)
		clr.w	640(a6)
		clr.w	320(a6)
		clr.w	(a6)+
		dbra	d4,plost_atb320

		bra	plost_out		; und ganz raus

plosta_nolim320

	; -------------------
	; gegenstand ist aktiviert, hat
	; aber kein time limit, also
	; ein erleuchtetes lichtfeld zeichnen

		lea	leiste_gfx+128+640*49+151*2,a2
		lea	320*1+1*2(a6),a6

		moveq	#6,d7
plosta_nl320	movem.l	(a2),d2-d6/a3
		movem.w	d2-d6/a3,(a6)
		lea	640(a2),a2
		lea	320(a6),a6	
		dbra	d7,plosta_nl320


plost_out
		add.w	d1,d0

		rts


;---

plost_one_small_thing_black

		movea.l	screen_1(pc),a3
		adda.l	(a1)+,a3

		lea	leiste_gfx+128+640*18+129*2,a2

		; es gibt jetzt die moeglichkeiten
		; rgb: 640 double_scan
		;      512
		;      512 double_scan
		; vga: 320

		cmpi.w	#320,true_offi+2
		beq	plostb_320
		tst.w	double_scan
		beq	plostb_512

plostb_56

	; -------------------
	; version fÅr 512 und 
	; 640 mit double_scan

		move.w	d1,-(sp)
		move.w	true_offi+2,d6
		moveq	#11,d7
plostb_i56	movem.l	(a2),d1-d5/a4-a6
		movem.l	d1-d5/a4-a6,(a3)
		lea	640*2(a2),a2
		adda.w	d6,a3
		dbra	d7,plostb_i56

		lea	640(a2),a2
		lea	512(a3),a3

		moveq	#3,d7
plostb_leli56	movem.l	(a2),d1-d5/a4-a6
		movem.l	d1-d5/a4-a6,(a3)
		lea	640*2(a2),a2
		adda.w	d6,a3
		dbra	d7,plostb_leli56
		move.w	(sp)+,d1

		bra.s	plostb_out

;---

plostb_512

	; -------------------
	; version fÅr 512 (ohne double_scan)

		move.w	d1,-(sp)
		moveq	#21,d7
plostb_i512	movem.l	(a2),d1-d6/a5-a6
		movem.l	d1-d6/a5-a6,(a3)
		lea	640(a2),a2
		lea	512(a3),a3
		dbra	d7,plostb_i512

		lea	640(a2),a2
		lea	512(a3),a3

		moveq	#7,d7
plostb_leli512	movem.l	(a2),d1-d6/a5-a6
		movem.l	d1-d6/a5-a6,(a3)
		lea	640(a2),a2
		lea	512(a3),a3
		dbra	d7,plostb_leli512
		move.w	(sp)+,d1

           	bra.s	plostb_out


;---

plostb_320

	; -------------------
	; version fÅr 320

		move.w	d1,-(sp)
		moveq	#21,d7
plostb_i320	movem.l	(a2),d1-d6/a5-a6
		movem.w	d1-d6/a5-a6,(a3)
		lea	640(a2),a2
		lea	320(a3),a3
		dbra	d7,plostb_i320

		lea	640(a2),a2
		lea	320(a3),a3

		moveq	#7,d7
plostb_leli320	movem.l	(a2),d1-d6/a5-a6
		movem.w	d1-d6/a5-a6,(a3)
		lea	640(a2),a2
		lea	320(a3),a3
		dbra	d7,plostb_leli320
		move.w	(sp)+,d1


plostb_out

		move.w	plottb_save,d0

                rts



;**************************************
;* flags zum update der console
;**************************************

plf_things	dc.w	0
plf_energy	dc.w	0
plf_shield	dc.w	0
plf_weapon	dc.w	0
plf_ammo1	dc.w	0
plf_ammo2	dc.w	0
plf_ammo3	dc.w	0
plf_ammo4	dc.w	0
plf_time_limit	dc.w	0


		endc





		data

; flags zum update bestimmer consolenbereich
plWeaponFlag	dc.w	0
plAmmoFlag	dc.w	0		; aenderung an aktueller munitionsanzahl
plThingsFlag	dc.w	0
plEnergyFlag	dc.w	0
plShieldFlag	dc.w	0


		bss

consoleMode	ds.w	1		; 0 = volle console, 1 = kleine console im 3d-fenster





