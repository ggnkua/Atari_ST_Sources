;**************************************
;* init routines ...
;**************************************

double_vbl_test

		move.l	$68.w,-(sp)
		move.l	$70.w,-(sp)

		move	#$2700,sr
		move.l	#dv_hbl,$68.w
		move.l	#dv_vbl,$70.w
		move	#$2100,sr

		clr.l	dv_hbl_cnt

		bsr	vsync_466
		bsr	vsync_466
		move.l	d7,d1

		bsr	vsync_466
		sub.l	d7,d1
		addq.l	#2,d1

		moveq	#0,d0
		cmpi.l	#4,d1
		bls.s	dvt_vbl_ok
		moveq	#1,d0
dvt_vbl_ok	move.w	d0,dv_flag

		move	#$2700,sr
		move.l	(sp)+,$70.w
		move.l	(sp)+,$68.w
		move	#$2100,sr

		rts

;---

dv_flag		dc.w	0

;---------------

dv_hbl
		addq.l	#1,dv_hbl_cnt
		rte

;---

dv_vbl
		move.l	dv_hbl_cnt,d7
		clr.l	dv_hbl_cnt
		addq.l	#1,$466.w
		rte

;-----------------------

screen_save

	; alle hardwareregister retten ...

		bsr	save_video_system

	; falcon testen: welcher monitor?

		bsr	test_falcon

	; physikalische screenadresse bestimmen (st-routine)

		move.w	#2,-(sp)
		trap	#14
		addq.l	#2,sp
		move.l	d0,old_screen

	; aufloesung bestimmen (st-routine)

		move.w	#-1,-(sp)
		move.w	#$58,-(sp)
		trap	#14
		addq.l	#4,sp
		move.w	d0,old_res

	; neue screenadressen berechnen ...

		ifeq mxalloc_flag
		move.l	#screen_mem,d0
		clr.b	d0
		move.l	d0,screen_1
		addi.l	#153600+256,d0
		move.l	d0,screen_2
		endc

		rts


;**************************************
;* screen_init 27/10/97
;**************************************

screen_init

	; -------------------
	; beide screens sind physikalisch
	; vorhanden (entweder im bss oder
	; per mxalloc angefordert)

	; screens loeschen

		movea.l	screen_1(pc),a0
		jsr	clear_black_240
		movea.l	screen_2(pc),a0
		jsr	clear_black_240

	; -------------------
	; original falcon-initialisierung (truecolor)

		move.w	#%100,-(sp)
		move.w	#3,-(sp)
		movea.l	screen_1(pc),a0
		move.l	a0,-(sp)
		move.l	a0,-(sp)
		move.w	#5,-(sp)
		trap	#14
		lea	14(sp),sp		

	; -------------------
	; spezialfall fuer 
	; rgb-monitor und tv

		tst.w	vga_monitor
		bne	si_no_vga	

                move.w  #$0140,$FFFF8210.w        ;line width
                move.w  #$0100,$FFFF8266.w        ;falcon shift mode

                move.w  #$00FE,hht
                move.w  #$008F,hbb                ;(rechte Aust.-luecke)
                move.w  #$004F,hbe                ;(linke Aust.-luecke)
                move.w  #$002E,hdb
                move.w  #$008F,hde
                move.w  #$00D8,hss

                move.w  #$0271,vft
                move.w  #$022F,vbb                ;(untere Aust.-luecke)
                move.w  #$004F,vbe                ;(obere Aust.-luecke)
                move.w  #$004F,vdb
                move.w  #$022F,vde
                move.w  #$026B,vss

                move.w  #$0181,$FFFF82C0.w        ;video control (hi and low)
                move.w  #$0000,$FFFF82C2.w        ;video mode (hi and low)

si_no_vga

		tst.w	vga_monitor
		beq.s	si_rgb

		move.w	#1,dont_change_scr
		move.l	#si_320x240vga,screen_init_rout_ptr

		bra.s	si_out

si_rgb
		move.w	#1,dont_change_scr
		move.l	#si_320x240,screen_init_rout_ptr


si_out

	; -------------------
	; bildschirmadresse
	; physikalisch eintragen

		move.l	screen_1(pc),d0
		lsr.l	#8,d0
		move.b	d0,$ffff8203.w
		lsr.w	#8,d0
		move.b	d0,$ffff8201.w

                rts

;---------------

screen_restore

		move.w	old_res,-(sp)
		move.w	#3,-(sp)
		move.l	old_screen,-(sp)
		move.l	old_screen,-(sp)
		move.w	#5,-(sp)
		trap	#14
		lea	14(sp),sp

		bsr	restore_video_system

		rts


;--------------------------------------

save_video_system:

		lea	video_data,a1

		move.l	$ffff8282.w,(a1)+
		move.l	$ffff8286.w,(a1)+
		move.l	$ffff828a.w,(a1)+
		move.l	$ffff82a2.w,(a1)+
		move.l	$ffff82a6.w,(a1)+
		move.l	$ffff82aa.w,(a1)+
		move.w	$ffff820a.w,(a1)+
		move.w	$ffff82c0.w,(a1)+
		move.w	$ffff8266.w,(a1)+
		move.w	$ffff82c2.w,(a1)+
		move.w	$ffff8210.w,(a1)+

		rts		


;---------------

restore_video_system:

		bsr	vsync_466

		lea	video_data,a1

		move.l	(a1)+,$ffff8282.w
		move.l	(a1)+,$ffff8286.w
		move.l	(a1)+,$ffff828a.w
		move.l	(a1)+,$ffff82a2.w
		move.l	(a1)+,$ffff82a6.w
		move.l	(a1)+,$ffff82aa.w
		move.w	(a1)+,$ffff820a.w
		move.w	(a1)+,$ffff82c0.w
		clr.w	$ffff8266.w
		move.w	(a1)+,$ffff8266.w
		move.w	(a1)+,$ffff82c2.w
		move.w	(a1)+,$ffff8210.w

		rts


;**************************************

swap_me:        

                tst.w   dont_change_scr
                bne.s   swap_me_not

swap_me_now:
                lea     screen_1(PC),A0
                move.l  (A0),D0
                move.l  4(A0),(A0)
                move.l  D0,4(A0)
                lsr.l   #8,D0
                move.b  D0,$FFFF8203.w
                lsr.w   #8,D0
                move.b  D0,$FFFF8201.w

                rts

swap_me_not:
            	subq.w	#1,dont_change_scr
		beq.s	smn_down
		rts

smn_down
		move.w	#2,clear_it_flag
		move.l	screen_init_rout_ptr,d0
		beq.s	smnd_out
	
		movem.l	d0/a0,-(sp)

		bsr	vsync
		movem.l	(sp)+,d0/a0

		movea.l	d0,a0
		jsr	(a0)
		clr.l	screen_init_rout_ptr

smnd_out
		bra	swap_me_now
	
;---

screen_init_rout_ptr

		dc.l	0

;---------------

screen_ausfaden

		moveq	#15,d0
sa_loop
		bsr.s	sa_8240
		bsr.s	sa_9800

		move.w	d0,-(sp)
		moveq	#24,d7
sa_wait_loop	bsr	vsync_466
		dbra	d7,sa_wait_loop
		move.w	(sp)+,d0

		dbra	d0,sa_loop

		rts

;---

sa_8240

		moveq	#15,d1
		lea	$ffff8240.w,a0
sa8240_loop
		move.w	(a0),d2
		move.w	d2,d3
		move.w	d2,d4
		andi.w	#%111100000000,d2	; rot
		andi.w	#%000011110000,d3	; gruen
		andi.w	#%000000001111,d4	; blau
		lsr.w	#8,d2
		lsr.w	#4,d3

		subq.w	#1,d2
		bpl.s	sa8240_red_ok
		moveq	#0,d2
sa8240_red_ok
		subq.w	#1,d3
		bpl.s	sa8240_green_ok
		moveq	#0,d3
sa8240_green_ok
		subq.w	#1,d4
		bpl.s	sa8240_blue_ok
		moveq	#0,d4
sa8240_blue_ok
		lsl.w	#8,d2
		lsl.w	#4,d3
		add.w	d2,d3
		add.w	d3,d4

		move.w	d4,(a0)+		

		dbra	d1,sa8240_loop

		rts

;---

sa_9800
		move.w	#255,d1
		lea	$ffff9800.w,a0
sa9800_loop
		move.b	(a0),d2
		move.b	1(a0),d3
		move.b	3(a0),d4

		moveq	#16,d5
		sub.w	d5,d2
		bpl.s	sa9800_red_ok
		moveq	#0,d2
sa9800_red_ok
		sub.w	d5,d3
		bpl.s	sa9800_green_ok
		moveq	#0,d3
sa9800_green_ok
		sub.w	d5,d4
		bpl.s	sa9800_blue_ok
		moveq	#0,d4
sa9800_blue_ok
		move.b	d4,3(a0)
		move.b	d3,1(a0)
		move.b	d2,(a0)

		addq.w	#4,a0	

		dbra	d1,sa9800_loop

		rts

;---------------

clear_bss
                lea     bss_start,A0
                lea     bss_end,A1
cherry:         clr.b	-(A1)
                cmpa.l  A0,A1
                bne.s   cherry

		ifne mxalloc_flag
		movea.l	screen_1,a0
		move.w	#319,d0
		move.w	#239,d1
		bsr	cb_xy
		movea.l	screen_2,a0
		move.w	#319,d0
		move.w	#239,d1
		bsr	cb_xy
		rts

cb_xy		move.w	d1,d2
cb_loop1	move.w	d2,d1
cb_loop2	clr.b	(a0)+
		dbra	d1,cb_loop2
		dbra	d0,cb_loop1
		rts

		endc

                rts

;---------------
     
send_ikbd
		lea	$fffffc00.w,a0
sik_waitkey	btst	#1,(a0)
		beq.s	sik_waitkey
		move.b	d0,2(a0)
		rts

;---------------
                
vsync:          
                lea     vbl_count(PC),A0
                move.l  (A0),D0
wait:           cmp.l   (A0),D0
                beq.s   wait
                rts

;---------------

wait_50_vbl:
                moveq   #50,D7
after_wait:     bsr.s   vsync
                dbra    D7,after_wait

                rts

;---------------

vsync_466
		lea	$466.w,a0
		move.l	(a0),d0
wait_466	cmp.l	(a0),d0
		beq.s	wait_466
		rts

;---------------

cursor_off	pea	cursor_off_seq
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp

		rts

cursor_off_seq	dc.b	27,"f",0
		even

;---------------
                
mouse_off:      
                moveq   #$12,D0                   ; maus aus
                bsr.s   send_ikbd

                rts
                
;---------------

joystick_on:    
                moveq   #$14,D0
                bsr.s   send_ikbd

                rts
                

;**************************************
;* install_system
;**************************************

install_system: 
                DC.W $A00A

                clr.w	$ffff893a.w		; lautstaerke

                move.l  $00000070.w,old_vbl
                move.l  #my_vbl,$00000070.w

                lea     save_system,A1

                move.b  $FFFF820A.w,(A1)
                move.b  $FFFF8260.w,1(A1)
                movem.l $FFFF8240.w,D0-D7
                movem.l D0-D7,2(A1)

                movem.l black,D0-D7
                movem.l D0-D7,$FFFF8240.w

                bsr     vsync
                bsr.s   mouse_off

                bsr     vsync

                bsr     vsync
                move.b  #2,$FFFF820A.w            ; 50 Hz

                bsr     vsync
                bsr.s   init_mfp

                rts
                

;**************************************
;* restore_system
;**************************************

restore_system: 
                bsr     restore_mfp

                bsr     vsync

                lea     save_system,A1

                move.b  (A1)+,$FFFF820A.w
                move.b  (A1)+,$FFFF8260.w
                movem.l (A1)+,D0-D7
                movem.l D0-D7,$FFFF8240.w

                moveq   #$08,D0
                bsr     send_ikbd

                bsr     vsync
                move.l  old_vbl(PC),$00000070.w

                rts


;**************************************
;* init_mfp
;**************************************

init_mfp:       
                move    SR,-(SP)
                move    #$2700,SR

                lea     save_mfp,A1
                move.l  $00000118.w,(A1)+
                move.l  $00000120.w,(A1)+
                move.l  $00000068.w,(A1)+

                lea     $FFFFFA00.w,A0            ; MFP
                move.b  $0007(A0),(A1)+
                move.b  $0009(A0),(A1)+
                move.b  $0011(A0),(A1)+
                move.b  $0013(A0),(A1)+
                move.b  $0015(A0),(A1)+
                move.b  $0017(A0),(A1)+
                move.b  $001B(A0),(A1)+
                move.b  $0021(A0),(A1)+

                clr.b   $0007(A0)                 ; alles aus
                clr.b   $0009(A0)
                clr.b   $0013(A0)
                clr.b   $0015(A0)

                bclr    #3,$0017(A0)              ; automatic an

                bset    #6,$0009(A0)              ; keys an
                bset    #6,$0015(A0)

                move.l  #new_key,$00000118.w
                move.l  #midi_nothing,midi_rout_ptr

                move.b  #$03,$FFFFFC00.w          ; acia init
                move.b  #$96,$FFFFFC00.w

;                move.b  #$03,$FFFFFC04.w
;                move.b  #$95,$FFFFFC04.w

                move    (SP)+,SR

                rts


;**************************************
;* restore_mfp
;**************************************


restore_mfp:    
                move    SR,-(SP)
                move    #$2700,SR

                lea     save_mfp,A1
                move.l  (A1)+,$00000118.w
                move.l  (A1)+,$00000120.w
                move.l  (A1)+,$00000068.w
                lea     $FFFFFA00.w,A0            ; MFP
                move.b  (A1)+,$0007(A0)
                move.b  (A1)+,$0009(A0)
                move.b  (A1)+,$0011(A0)
                move.b  (A1)+,$0013(A0)
                move.b  (A1)+,$0015(A0)
                move.b  (A1)+,$0017(A0)
                move.b  (A1)+,$001B(A0)
                move.b  (A1)+,$0021(A0)

                move.b  #$03,$FFFFFC00.w          ; ACIA-Init
                move.b  #$96,$FFFFFC00.w

                move    (SP)+,SR

                rts

;**************************************

init_directories

		; pfad richtig setzen (fuer debugging)

		ifeq final
		move.w	#laufwerk,-(sp)	
		move.w	#14,-(sp)
		trap	#1
		addq.l	#4,sp
		pea	standard_path
		move.w	#59,-(sp)
		trap	#1
		addq.l	#6,sp
		endc

		; temp-verzeichnis erstellen

		pea	temppath
		move	#57,-(sp)
		trap	#1		; d_create
		addq.l	#6,sp

		; save-verzeichnis erstellen

		pea	savepath
		move	#57,-(sp)
		trap	#1		; d_create
		addq.l	#6,sp

		rts	

;---

temppath	dc.b	"temp",0
		even
savepath	dc.b	"save",0
		even


;**************************************
;* init_stuff
;**************************************

init_stuff:     
		lea	jagpad_routs,a1
		moveq	#0,d0
		movea.l	d0,a0
		jsr	(a1)			; jagpad initialisieren ...

                rts

;---


		ifeq	final
standard_path	dc.b	"\running",0
		even
		endc

;**************************************
;* init_stuff_2
;**************************************

init_stuff_2:  

		bsr	clear_bss

                bsr     install_system

                move.l  #per_vga,per_factor       ;fuer vga-monitor
                tst.w   vga_monitor
                bne.s   per_no_vga
                move.l  #per_rgb,per_factor
per_no_vga:

                bsr     make_walk_data

                bsr     swap_me

                rts

;**************************************
;* test_falcon
;**************************************

test_falcon

		move.b	$ffff8006.w,d0
		lsr.w	#6,d0
		andi.w	#%11,d0
		beq.s	tf_sm124

		cmpi.b	#%10,d0
		beq.s	tf_vga

		cmpi.b	#%01,d0
		beq.s	tf_rgb

tf_tv
                move.w  #1,tv_monitor
                clr.w   rgb_monitor
                clr.w   vga_monitor

                rts

tf_rgb
                move.w  #1,rgb_monitor
                clr.w   vga_monitor
                clr.w   tv_monitor

                rts

tf_vga
                move.w  #1,vga_monitor
                clr.w   rgb_monitor
                clr.w   tv_monitor

                rts

tf_sm124
                pea     sm124_text(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP

                move.w  #1,-(SP)
                trap    #1
                addq.l  #2,SP

                jmp	out


sm124_text	dc.b	13,10,13,10
		dc.b	"RUNNING Engine (C) 1995-1997 by RDT",13,10
		dc.b	13,10
		dc.b	"Initializing failed!",13,10
		dc.b	"RUNNING only runs on a ATARI Falcon 030,",13,10
		dc.b	"connected to a TV, RGB- or VGA-monitor.",13,10
		dc.b	13,10,0
		even

;---------------

vga_monitor	dc.w	0
rgb_monitor	dc.w	0
tv_monitor	dc.w	0

;**************************************
;* load_lev_files
;**************************************

load_lev_files

		movea.l	big_sector_ptr(pc),a0
		movea.l	lev_files(a0),a6
		lea	dith_data,a5

	; zuerst die grafik-files laden ...

load_lev_loop
		move.l	(a6)+,file_name_ptr
		beq.s	load_gfx_out
		move.l	(a6)+,file_size
		move.l	a5,file_buf_ptr
		movem.l	a5-a6,-(sp)
		bsr	load_file
		movem.l	(sp)+,a5-a6
		adda.l	#131072,a5
		bra.s	load_lev_loop
load_gfx_out

	; ... und danach die sample-files fuer den level

		ifeq mxalloc_flag
		lea	samples_data,a5
		else
		movea.l	samples_data,a5
		endc

		lea	lev_samples,a4
load_sam_loop
		move.l	(a6)+,file_name_ptr
		beq.s	load_sam_out
		move.l	#500000,file_size
		move.l	a5,file_buf_ptr
		movem.l	a4-a6,-(sp)
		bsr	load_file	; d6 = tatsaechlich geladen
		movem.l	(sp)+,a4-a6

		move.l	a5,(a4)+	; pointer sample
		move.l	d6,(a4)+	; laenge sample
		move.l	(a6)+,(a4)+	; frequenzzahl sample
		adda.l	d6,a5
                bra.s   load_sam_loop
load_sam_out

		clr.l	(a4)		; pointer ende level-samples

		ifne mxalloc_flag
		move.l	#intsam_file,file_name_ptr
		move.l	samples,file_buf_ptr
		move.l	#mx_intsam_len,file_size
		jsr	load_file
		endc

	; nun die richtige pistole ...

		movea.l	play_dat_ptr,a6
		move.w	pd_mun_type(a6),d0
		bsr	load_pistol_data
		jsr	calc_paint_pistol_immediate

                rts


;---------------

; d0: nummer der waffe (0-4)

load_pistol_data

		move.l	#pistol_data,file_buf_ptr
		move.l	#70320,file_size
		movea.l	big_sector_ptr,a0
		movea.l	lev_pistol(a0),a0
		movea.l	pistol_files(a0),a0
		move.l	(a0,d0.w*4),file_name_ptr
		bsr	load_file
		jsr	pistol_helligkeit_anpassen
		clr.w	pp_data_ok
		rts

;---------------

init_make_modulo
		move.l	a6,d0
		sub.l	screen_2,d0
		divu	#640,d0
		mulu	#640,d0
		addi.l	#init_txt_offset,d0
		add.l	screen_2,d0
		movea.l	d0,a6
		
		rts

;**************************************

; a0: pointer auf liste

; listenformat:		dc.w	anzahl-1
;			dc.l	pointer filename  
;			dc.l	laenge            
;			dc.l	pointer buffer    

load_file_list
		move.w	(a0)+,d7
		beq.s	lfl_out

lfl_loop
		move.l	(a0)+,file_name_ptr
		move.l	(a0)+,file_size
		move.l	(a0)+,file_buf_ptr
		movem.l	d7-a0,-(sp)
		bsr	load_file
		movem.l	(sp)+,d7-a0
		dbra	d7,lfl_loop

lfl_out
		rts


;**************************************
;* load_file & save_file
;**************************************

; wenn ein file nicht geladen werden kann, so system anhalten ...

; rueckgabe: d6: anzahl tatsaechlich geladener bytes

load_file
		clr.w	-(sp)
		move.l	file_name_ptr(pc),-(sp)
		move.w	#61,-(sp)
		trap	#1
		addq.l	#8,sp
		tst.w	d0		
		bmi.s	fopen_error
		move.w	d0,d7

		move.l	file_buf_ptr(pc),-(sp)
		move.l	file_size(pc),-(sp)
		move.w	d7,-(sp)	
		move.w	#63,-(sp)
		trap	#1
		lea	12(sp),sp
		move.l	d0,d6
		bmi.s	fread_error
		
		move.w	d7,-(sp)	
		move.w	#62,-(sp)
		trap	#1
		addq.l	#4,sp
		tst.w	d0
		bmi.s	fclose_error

		rts

;---

fopen_error
		move.l	file_name_ptr(pc),sst_message
		move.w	#2,sst_code
		bsr	stop_system
		rts

;---

fcreate_error
		move.l	file_name_ptr(pc),sst_message
		move.w	#6,sst_code
		bsr	stop_system
		rts

;---

fread_error
		move.l	file_name_ptr(pc),sst_message
		move.w	#3,sst_code
		bsr	stop_system
		rts

;---

fwrite_error
		move.l	file_name_ptr(pc),sst_message
		move.w	#5,sst_code
		bsr	stop_system
		rts

;---

fclose_error
		move.l	file_name_ptr(pc),sst_message
		move.w	#4,sst_code
		bsr	stop_system
		rts


;--------------------------------------

save_file
		clr.w	-(sp)
		move.l	file_name_ptr,-(sp)
		move.w	#60,-(sp)
		trap	#1
		addq.l	#8,sp
		tst.w	d0
		bmi.s	fcreate_error
		move.w	d0,d7

		move.l	file_buf_ptr,-(sp)
		move.l	file_size,-(sp)
		move.w	d7,-(sp)
		move.w	#64,-(sp)
		trap	#1
		lea	12(sp),sp
		tst.l	d0
		bmi.s	fwrite_error

		move.w	d7,-(sp)
		move.w	#62,-(sp)
		trap	#1
		addq.l	#4,sp
		tst.w	d0
		bmi.s	fclose_error
		
		rts


;**************************************
;* install_dsp
;**************************************

install_dsp

; d0: 0 = running engine
;     1 = module player

		move.w	d0,-(sp)

		move.l	#dsp_inl_file,file_name_ptr
		move.l	#816,file_size
		move.l	#truecolor_tab,file_buf_ptr
		bsr	load_file

		lea	truecolor_tab,a0
		jsr	(a0)

		move.l	#dsp_ads_file,d1
		move.w	(sp)+,d0
		beq.s	idsp_running
		move.l	#dsp_mads_file,d1
idsp_running	move.l	d1,file_name_ptr
		move.l	#20000,file_size
		move.l	#truecolor_tab+1024,file_buf_ptr
		bsr	load_file

		lea	truecolor_tab,a1
		lea	1024(a1),a0
		addq.l	#4,a1
		jsr	(a1)

		rts

;---------------

close_dsp
		move.w	#$69,-(sp)
		trap	#14
		addq.l	#2,sp

		rts

		