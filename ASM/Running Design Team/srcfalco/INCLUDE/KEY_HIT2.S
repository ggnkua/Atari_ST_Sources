;**************************************
;* key_hit
;**************************************

key_hit

                tst.b   keytable+$21
		beq.s	kh_no_21
                bsr	change_full_screen
kh_no_21

		tst.b	keytable+$2e
		beq.s	kh_no_2e
		bsr	change_cinemascope
kh_no_2e

		tst.b	keytable+$32
		beq.s	kh_no_32
		bsr	screenshot
kh_no_32

		tst.b	keytable+$20
		beq.s	kh_no_20
		clr.b	keytable+$20

		move.w	#1,clear_it_flag		
		move.w	pl_display_flag,d0
		bchg	#1,d0
		move.w	d0,pl_display_flag
kh_no_20

		tst.b	keytable+$26
		beq.s	kh_no_26

		clr.l	ml_connect_addr
		bsr	make_laptop

kh_no_26

		tst.b	keytable+$14
		beq.s	kh_no_11
		clr.b	keytable+$14
		not.w	wide_screen
		bsr	install_si_routine
kh_no_11

		tst.b	keytable+$13
		beq.s	kh_no_13
		clr.b	keytable+$13

		movea.l	play_dat_ptr,a6
		bchg	#0,pd_cursor_flag+1(a6)
kh_no_13

                lea     keytable,A0
                tst.b   $003C(A0)
                bne     full_detail
kh_full_ok      lea     keytable,A0
		tst.b   $003D(A0)
                bne     low_detail
kh_low_ok
                lea     keytable,A0
                tst.b   $003E(A0)
                bne     compress_screen
                tst.b   $003F(A0)
                bne     expand_screen

                tst.b   $0063(A0)
                bne     compress_screen_x
                tst.b   $0064(A0)
                bne     expand_screen_x
                tst.b   $0065(A0)
                bne     compress_screen_y
                tst.b   $0066(A0)
                bne     expand_screen_y

                rts

;---------------

change_full_screen

		tst.w	menue_flag
		beq.s	cfs_ok
		cmpi.b	#2,keytable+$21
		beq.s	cfs_ok
		clr.b	keytable+$21
		bra	cfs_out
cfs_ok
                clr.b   keytable+$21

                tst.w   karte_flag
                bne     cfs_out
                tst.w   vga_monitor
                bne     cfs_out

                movea.l play_dat_ptr,A1
		move.w	#1,pd_things_flag(a1)
                move.w  #1,clear_it_flag
                move.w  #2,dont_change_scr
	

		tst.w	double_scan
                beq     cfs_make_double_scan

	; double_scan soll jetzt ausgeschaltet werden ...

		tst.w	cinemascope
		beq	cfs_320x240

                move.w  pd_width(A1),screen_x_cifu
                move.w  pd_heigth(A1),screen_y_cifu

		bsr	screen_256x200

cfs_out
		rts

cfs_320x240
                move.w  pd_width(A1),screen_x_full
                move.w  pd_heigth(A1),screen_y_full


		bsr	screen_320x240

		rts

	; double_scan soll eingeschaltet werden ...

cfs_make_double_scan

		tst.w	cinemascope
		beq	cfs_320x120

                move.w  pd_width(A1),screen_x_cine
                move.w  pd_heigth(A1),screen_y_cine
		move.w	pd_x_flag(a1),screen_flag_cine

		bsr	screen_256x120

		rts

cfs_320x120
                move.w  pd_width(A1),screen_x_norm
                move.w  pd_heigth(A1),screen_y_norm
		move.w	pd_x_flag(a1),screen_flag_norm

		bsr	screen_320x120

		rts

;---------------

change_cinemascope

		tst.w	menue_flag
		beq.s	ccc_ok
		cmpi.b	#2,keytable+$2e
		beq.s	ccc_ok
		clr.b	keytable+$2e
		bra	ccc_out
ccc_ok
                clr.b   keytable+$2e

                tst.w   karte_flag
                bne     ccc_out
;                tst.w   vga_monitor
;                bne     ccc_out

                movea.l play_dat_ptr,A1
		move.w	#1,pd_things_flag(a1)
		move.w	#1,dsp_error_flag	
                move.w  #1,clear_it_flag
                move.w  #2,dont_change_scr
	

		tst.w	cinemascope
                beq     ccc_make_cine

	; cinemascope soll jetzt ausgeschaltet werden ...

		tst.w	double_scan
		beq	ccc_320x240

                move.w  pd_width(A1),screen_x_cifu
                move.w  pd_heigth(A1),screen_y_cifu

		bsr	screen_320x120

ccc_out
		rts

ccc_320x240
                move.w  pd_width(A1),screen_x_cine
                move.w  pd_heigth(A1),screen_y_cine
		move.w	pd_x_flag(a1),screen_flag_cine

		bsr	screen_320x240

		rts

	; cinemascope soll eingeschaltet werden ...

ccc_make_cine

		tst.w	double_scan
		beq	ccc_256x200

                move.w  pd_width(A1),screen_x_full
                move.w  pd_heigth(A1),screen_y_full

		bsr	screen_256x120

		rts

ccc_256x200
                move.w  pd_width(A1),screen_x_norm
                move.w  pd_heigth(A1),screen_y_norm
		move.w	pd_x_flag(a1),screen_flag_norm

		bsr	screen_256x200

		rts

;---------------

screen_320x240

		move.l	#si_320x240,d0
		move.l	#per_rgb,d1
		tst.w	wide_screen
		beq.s	s3224_no_wide
		move.l	#si_320x240wide,d0
		move.l	#per_rgb*5/4,d1
s3224_no_wide
		tst.w	vga_monitor
		beq.s	s3224_no_vga
		move.l	#si_320x240vga,d0
		move.l	#per_vga,d1
s3224_no_vga	move.l	d0,screen_init_rout_ptr
		move.l	d1,per_factor

                move.w  #96,xwindow_min
                move.w  #320,xwindow_max
                move.w  #60,ywindow_min
                move.w  #200,ywindow_max

                move.w  screen_x_norm,pd_width(A1)
                move.w  screen_y_norm,pd_heigth(A1)
		move.w	screen_flag_norm,pd_x_flag(a1)
		clr.w	pd_full_screen(a1)

                movea.l big_sector_ptr,A0
                movea.l lev_init_data(A0),A0
                move.l  #$00010000,sky_zoom(A0)

                jsr     dsp_s_init_data
                jsr     dsp_s_table

                clr.w   cinemascope
		clr.w	double_scan
		move.l	#640,true_offi

                rts

;---------------

screen_320x120

		move.l	#si_320x120,screen_init_rout_ptr

                move.w  #96,xwindow_min
                move.w  #320,xwindow_max
                move.w  #30,ywindow_min
                move.w  #120,ywindow_max

                move.w  screen_x_full,pd_width(A1)
                move.w  screen_y_full,pd_heigth(A1)
		move.w	#1,pd_x_flag(a1)
		move.w	#1,pd_full_screen(a1)

                move.l  #per_rgb/2,per_factor

                movea.l big_sector_ptr,A0
                movea.l lev_init_data(A0),A0
                move.l  #$00010000*2,sky_zoom(A0)

                jsr     dsp_s_init_data
                jsr     dsp_s_table

                clr.w   cinemascope
		move.w	#1,double_scan
		move.l	#640,true_offi

                rts

;---------------

screen_256x200

		tst.w	vga_monitor
		beq.s	s2520_rgb

		move.l	#si_160x200vga,screen_init_rout_ptr

                move.w  #64,xwindow_min
                move.w  #160,xwindow_max

                move.w  screen_x_cine,pd_width(A1)
                move.w  screen_y_cine,pd_heigth(A1)
		move.w	screen_flag_cine,pd_x_flag(a1)

                move.l  #per_vga*2,per_factor
		move.l	#320,true_offi
		bra.s	s2520_all_moni

s2520_rgb
		move.l	#si_256x200,screen_init_rout_ptr

                move.w  #80,xwindow_min
                move.w  #256,xwindow_max

                move.w  screen_x_cine,pd_width(A1)
                move.w  screen_y_cine,pd_heigth(A1)
		move.w	screen_flag_cine,pd_x_flag(a1)

                move.l  #per_rgb*5/4,per_factor
		move.l	#512,true_offi

s2520_all_moni
                move.w  #60,ywindow_min
                move.w  #200,ywindow_max
		clr.w	pd_full_screen(a1)

                movea.l big_sector_ptr,A0
                movea.l lev_init_data(A0),A0
                move.l  #$00010000,sky_zoom(A0)

                jsr     dsp_s_init_data
                jsr     dsp_s_table

                clr.w   double_scan
		move.w	#1,cinemascope

                rts

;---------------

screen_256x120

		move.l	#si_256x120,screen_init_rout_ptr

                move.w  #80,xwindow_min
                move.w  #256,xwindow_max
                move.w  #30,ywindow_min
                move.w  #120,ywindow_max

                move.w  screen_x_cifu,pd_width(A1)
                move.w  screen_y_cifu,pd_heigth(A1)
		move.w	#1,pd_x_flag(a1)
		move.w	#1,pd_full_screen(a1)

                move.l  #per_rgb*5/4/2,per_factor

                movea.l big_sector_ptr,A0
                movea.l lev_init_data(A0),A0
                move.l  #$00010000*2,sky_zoom(A0)

                jsr     dsp_s_init_data
                jsr     dsp_s_table

                move.w	#1,double_scan
		move.w	#1,cinemascope
		move.l	#512,true_offi

                rts

;---------------

si_320x240wide

* Screenblaster III, 1993/94 by Christian Cartus & Manuel Hermann
* Monitor: RGB/TV
* 320*240, True Color, 50.0 Hz, 15625 Hz

		move.l   #$c70098,$ffff8282.w
		move.l   #$2102b9,$ffff8286.w
		move.l   #$9800aa,$ffff828a.w
		move.l   #$271022f,$ffff82a2.w
		move.l   #$4f004f,$ffff82a6.w
		move.l   #$22f0263,$ffff82aa.w
		move.w   #$200,$ffff820a.w
		move.w   #$86,$ffff82c0.w
		clr.w    $ffff8266.w
		move.w   #$100,$ffff8266.w
		move.w   #$0,$ffff82c2.w
		move.w   #$140,$ffff8210.w

		rts

;---------------

si_320x240

; Monitor: RGB/TV
; 320*240, True Colour, 50.0 Hz, 15625 Hz

        MOVE.L   #$FE009A,$FFFF8282.W
        MOVE.L   #$5A0039,$FFFF8286.W
        MOVE.L   #$9A00D9,$FFFF828A.W
        MOVE.L   #$2710239,$FFFF82A2.W
        MOVE.L   #$590059,$FFFF82A6.W
        MOVE.L   #$239026B,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$181,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.W   #$100,$FFFF8266.W
        MOVE.W   #$0,$FFFF82C2.W
        MOVE.W   #$140,$FFFF8210.W

	rts

si_320x120

; Monitor: RGB/TV
; 320*120, True Colour, 50.0 Hz, 15625 Hz

        MOVE.L   #$FE009A,$FFFF8282.W
        MOVE.L   #$5A0039,$FFFF8286.W
        MOVE.L   #$9A00D9,$FFFF828A.W
        MOVE.L   #$2710239,$FFFF82A2.W
        MOVE.L   #$590059,$FFFF82A6.W
        MOVE.L   #$239026B,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$181,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.W   #$100,$FFFF8266.W
        MOVE.W   #$1,$FFFF82C2.W
        MOVE.W   #$140,$FFFF8210.W

	rts

si_256x200

; Monitor: RGB/TV
; 256*200 Cinemascope, True Colour, 50.0 Hz, 15625 Hz

        MOVE.L   #$C7007A,$FFFF8282.W
        MOVE.L   #$430022,$FFFF8286.W
        MOVE.L   #$7A00AB,$FFFF828A.W
        MOVE.L   #$2710211,$FFFF82A2.W
        MOVE.L   #$810081,$FFFF82A6.W
        MOVE.L   #$211026B,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$185,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.W   #$100,$FFFF8266.W
        MOVE.W   #$0,$FFFF82C2.W
        MOVE.W   #$100,$FFFF8210.W

	rts

si_256x120

; Monitor: RGB/TV
; 256*120 Cinemascope, True Colour, 50.0 Hz, 15625 Hz

        MOVE.L   #$C7007A,$FFFF8282.W
        MOVE.L   #$430022,$FFFF8286.W
        MOVE.L   #$7A00AB,$FFFF828A.W
        MOVE.L   #$2710239,$FFFF82A2.W
        MOVE.L   #$590059,$FFFF82A6.W
        MOVE.L   #$239026B,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$185,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.W   #$100,$FFFF8266.W
        MOVE.W   #$1,$FFFF82C2.W
        MOVE.W   #$100,$FFFF8210.W

	rts

;---------------

si_320x240vga

* Screenblaster III, 1993/94 by Christian Cartus & Manuel Hermann
* Monitor: VGA
* 320*240, True Color, 60.0 Hz, 31470 Hz

		move.l   #$c6008d,$ffff8282.w
		move.l   #$1502ac,$ffff8286.w
		move.l   #$8d0096,$ffff828a.w
		move.l   #$41903fd,$ffff82a2.w
		move.l   #$3d003d,$ffff82a6.w
		move.l   #$3fd0415,$ffff82aa.w
		move.w   #$200,$ffff820a.w
		move.w   #$186,$ffff82c0.w
		clr.w    $ffff8266.w
		move.w   #$100,$ffff8266.w
		move.w   #$5,$ffff82c2.w
		move.w   #$140,$ffff8210.w

		rts

;---------------

si_160x200vga

* Screenblaster III, 1993/94 by Christian Cartus & Manuel Hermann
* Monitor: VGA
* 160*200, True Color, 60.0 Hz, 31470 Hz

		move.l   #$620046,$ffff8282.w
		move.l   #$a024d,$ffff8286.w
		move.l   #$46004b,$ffff828a.w
		move.l   #$41903a9,$ffff82a2.w
		move.l   #$890089,$ffff82a6.w
		move.l   #$3a90415,$ffff82aa.w
		move.w   #$200,$ffff820a.w
		move.w   #$186,$ffff82c0.w
		clr.w    $ffff8266.w
		move.w   #$100,$ffff8266.w
		move.w   #$1,$ffff82c2.w
		move.w   #$A0,$ffff8210.w

		rts

;---------------

si_320x200

; Monitor: RGB/TV
; 320*200, True Colour, 50.0 Hz, 15625 Hz

        MOVE.L   #$FE009A,$FFFF8282.W
        MOVE.L   #$5A0039,$FFFF8286.W
        MOVE.L   #$9A00D9,$FFFF828A.W
        MOVE.L   #$2710211,$FFFF82A2.W
        MOVE.L   #$810081,$FFFF82A6.W
        MOVE.L   #$211026B,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$181,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.W   #$100,$FFFF8266.W
        MOVE.W   #$0,$FFFF82C2.W
        MOVE.W   #$140,$FFFF8210.W

	rts

;---------------

si_320x200vga

; Monitor: VGA
; 320*200, True Colour, 60.0 Hz, 31470 Hz

        MOVE.L   #$C6008B,$FFFF8282.W
        MOVE.L   #$1302AA,$FFFF8286.W
        MOVE.L   #$8B0097,$FFFF828A.W
        MOVE.L   #$41903AF,$FFFF82A2.W
        MOVE.L   #$8F008D,$FFFF82A6.W
        MOVE.L   #$3AD0415,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$186,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.W   #$100,$FFFF8266.W
        MOVE.W   #$5,$FFFF82C2.W
        MOVE.W   #$140,$FFFF8210.W

	rts

;---------------

full_detail:
                movea.l play_dat_ptr,A6
                clr.w   pd_x_flag(A6)
                jsr     dsp_s_table
                bra	kh_full_ok

low_detail:
                movea.l play_dat_ptr,A6
                move.w  #1,pd_x_flag(A6)
                jsr     dsp_s_table
                bra	kh_low_ok

;---------------

compress_screen:
                movea.l play_dat_ptr,A6
                move.w  pd_width(A6),D0
                cmp.w   xwindow_min,D0
                ble.s   compress_out
                move.w  pd_heigth(A6),D0
                cmp.w   ywindow_min,D0
                ble.s   compress_out
                moveq   #8,D0
                moveq   #5,D1
                tst.w   double_scan
                beq.s   cs_no_double
                moveq   #16,D0
                moveq   #6,D1
cs_no_double:   sub.w   D0,pd_width(A6)
                sub.w   D1,pd_heigth(A6)
                jsr     dsp_s_table
                move.w  #1,clear_it_flag
compress_out:   rts

compress_screen_x:
                movea.l play_dat_ptr,A6
                move.w  pd_width(A6),D0
                cmp.w   xwindow_min,D0
                ble.s   compress_x_out
                subi.w  #8,pd_width(A6)
                jsr     dsp_s_table
                move.w  #1,clear_it_flag
compress_x_out: rts

compress_screen_y:
                movea.l play_dat_ptr,A6
                move.w  pd_heigth(A6),D0
                cmp.w   ywindow_min,D0
                ble.s   compress_y_out
                subi.w  #5,pd_heigth(A6)
                jsr     dsp_s_table
                move.w  #1,clear_it_flag
compress_y_out: rts

;--------------

expand_screen:
                movea.l play_dat_ptr,A6
                move.w  pd_width(A6),D0
                cmp.w   xwindow_max,D0
                bge.s   expand_out
                move.w  pd_heigth(A6),D0
                cmp.w   ywindow_max,D0
                bge.s   expand_out
                moveq   #8,D0
                moveq   #5,D1
                tst.w   double_scan
                beq.s   es_no_double
                moveq   #16,D0
                moveq   #6,D1
es_no_double:   add.w   D0,pd_width(A6)
                add.w   D1,pd_heigth(A6)
                jsr     dsp_s_table
                move.w  #1,clear_it_flag
expand_out:     rts

expand_screen_x:
                movea.l play_dat_ptr,A6
                move.w  pd_width(A6),D0
                addq.w  #8,D0
                cmp.w   xwindow_max,D0
                blt.s   expand_x_skip
                move.w  xwindow_max,D0
expand_x_skip:  move.w  D0,pd_width(A6)
                bsr     dsp_s_table
                move.w  #1,clear_it_flag
                rts

expand_screen_y:
                movea.l play_dat_ptr,A6
                move.w  pd_heigth(A6),D0
                addq.w  #5,D0
                cmp.w   ywindow_max,D0
                blt.s   expand_y_skip
                move.w  ywindow_max,D0
expand_y_skip:  move.w  D0,pd_heigth(A6)
                bsr     dsp_s_table
                move.w  #1,clear_it_flag
expand_y_out:   rts

;---------------

; benutzt wird der speicherplatz fuer tos_thing (256 bytes)

screenshot
		clr.b	keytable+$32

	; screenshot nur in der aufloesung 320x240 erlaubt ...

		tst.w	double_scan
		bne	sshot_out
		tst.w	cinemascope
		bne	sshot_out

	; filenamen (nummer zweistellig) fuer screenshot erstellen ...

		lea	ssf_modify(pc),a0
		move.w	sshot_number(pc),d0
		ext.l	d0
		divu	#10,d0
		moveq	#$30,d1
		add.b	d1,d0
		move.b	d0,(a0)
		swap	d0
		add.b	d1,d0
		move.b	d0,1(a0)

	; original tpi-header einladen ...

		move.l	#sshot_header,file_name_ptr
		move.l	#tos_thing,file_buf_ptr
		move.l	#128,file_size
		jsr	load_file

	; tpi-header abspeichern ...

		clr.w	-(sp)
		pea	sshot_file
		move.w	#60,-(sp)	; fcreate
		trap	#1
		addq.l	#8,sp
		move.w	d0,d7		; handle
		bmi.s	sshot_error

		pea	tos_thing
		move.l	#128,-(sp)
		move.w	d7,-(sp)
		move.w	#64,-(sp)	; fwrite
		trap	#1
		lea	12(sp),sp
		tst.l	d0
		bmi.s	sshot_error

	; und physikalischen screen speichern ...

		move.l	screen_2,-(sp)
		move.l	#320*240*2,d6
		move.l	d6,-(sp)
		move.w	d7,-(sp)
		move.w	#64,-(sp)	; fwrite
		trap	#1
		lea	12(sp),sp
		cmp.l	d6,d0
		bne.s	sshot_error		

	; abschliessend file wieder schliessen ...

		move.w	d7,-(sp)
		move.w	#62,-(sp)
		trap	#1
		addq.l	#4,sp
		tst.w	d0
		bmi.s	sshot_error

		lea	sshot_message1(pc),a0
		bsr	install_message

	; und nummer um eins erh”hen

		lea	sshot_number(pc),a0
		move.w	(a0),d0
		addq.w	#1,d0
		cmpi.w	#100,d0
		blt.s	sshot_num_ok
		moveq	#0,d0
sshot_num_ok	move.w	d0,(a0)

		rts

;---

sshot_error
		lea	sshot_message2(pc),a0
		bsr	install_message

sshot_out
		rts



sshot_number	dc.w	0

sshot_header	dc.b	"data\misc\tpiheade.dat",0
sshot_file	dc.b	"runpic"
ssf_modify	dc.b	"00.tpi",0

sshot_message1	dc.b	"PICTURE SAVED",0
sshot_message2	dc.b	"ERROR WHILE SAVING SCREENSHOT",0
		even





