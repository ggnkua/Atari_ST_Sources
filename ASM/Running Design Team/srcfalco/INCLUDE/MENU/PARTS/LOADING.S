***** Data Loading ********


DATAload:

* Kugel
	lea	FILEkugel(pc),a0
	lea	kugl_anim,a1
	move.l	BYTESkugel(pc),d0
	bsr	load

	bsr	fix_kugel_anim

* Text
	lea	FILEtxt(pc),a0
	lea	txt,a1
	move.l	BYTEStxt(pc),d0
	bsr	load

* Haupt Menu
	lea	FILEtitel1(pc),a0
	lea	fade_buffer_2,a1
	move.l	BYTEStitel1(pc),d0
	bsr	load

* Module
	lea	FILEmodule(pc),a0
	lea	module,a1
	move.l	BYTESmodule(pc),d0
	bsr	load

		ifeq menuedata_load

		lea	FILEcolor_tables(pc),a0
		lea	color_tables,a1
		move.l	BYTEScolor_tables(pc),d0
		bsr	load

		lea	FILEobject(pc),a0
		lea	object,a1
		move.l	BYTESobject(pc),d0
		bsr	load

		lea	FILEflach_info(pc),a0
		lea	flach_info,a1
		move.l	BYTESflach_info(pc),d0
		bsr	load

		lea	FILEsin_tab(pc),a0
		lea	sin_tab,a1
		move.l	BYTESsin_tab(pc),d0
		bsr	load

		lea	FILEcos_tab(pc),a0
		lea	cos_tab,a1
		move.l	BYTEScos_tab(pc),d0
		bsr	load

	; module player

		lea	FILEa_arp(pc),a0
		lea	a_arp,a1
		move.l	BYTESa_arp(pc),d0
		bsr	load

		lea	FILEtempo_tab(pc),a0
		lea	Tempo_tab,a1
		move.l	BYTEStempo_tab(pc),d0
		bsr	load

		endc

	rts


; d0: bytes
; a0: filename
; a1: destination (buffer)

load
		movem.l	d0-a6,-(sp)

		move.l	d0,file_size
		move.l	a0,file_name_ptr
		move.l	a1,file_buf_ptr
		jsr	load_file

		movem.l	(sp)+,d0-a6

		cmpa.l	#FILEtitel1,a0
		bne.s	load_out

		ifne	registry_flag
		lea	sm_registry,a0
		lea	fade_buffer_2,a6
		adda.l	#640*230+10*8*2+128,a6
		jsr	paint_text
		endc

load_out
		rts

;---------------

fix_kugel_anim
		lea	kugl_anim+128,a1
		move.w	#319,d0
fka_loop1	moveq	#15,d1
fka_loop2	move.w	(a1)+,d2
		cmpi.w	#%0000000000100000,d2
		bne.s	fka_skip
		moveq	#0,d2
fka_skip	move.w	d2,-2(a1)
		dbra	d1,fka_loop2
		dbra	d0,fka_loop1		

		rts

;---------------

		ifne menuedata_save

DATAsave
		lea	FILEcolor_tables(pc),a0
		lea	color_tables,a1
		move.l	#color_tables_end-color_tables,d0
		bsr	mnuSave

		lea	FILEobject(pc),a0
		lea	object,a1
		move.l	#object_end-object,d0
		bsr	mnuSave

		lea	FILEflach_info(pc),a0
		lea	flach_info,a1
		move.l	#flach_info_end-flach_info,d0
		bsr	mnuSave

		lea	FILEsin_tab(pc),a0
		lea	sin_tab,a1
		move.l	#sin_tab_end-sin_tab,d0
		bsr	mnuSave

		lea	FILEcos_tab(pc),a0
		lea	cos_tab,a1
		move.l	#cos_tab_end-cos_tab,d0
		bsr	mnuSave

	; module player

		lea	FILEa_arp(pc),a0
		lea	a_arp,a1
		move.l	#a_arp_end-a_arp,d0
		bsr	mnuSave

		rts

;---

mnuSave
		move.l	a0,file_name_ptr
		move.l	a1,file_buf_ptr
		move.l	d0,file_size

		jsr	save_file

		rts

		endc
