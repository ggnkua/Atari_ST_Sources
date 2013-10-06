; -------------------------
;  DTM Modplayer Interface
; -------------------------

TEMPS		equ	0

Boot_dsp	MACRO
		move.w	#113,-(sp)
		trap	#14
		addq.l	#2,sp

		move.w	d0,-(sp)
		move.l	\1,-(sp)
		move.l	\2,-(sp)
		move.w	#110,-(sp)
		trap	#14
		lea	12(sp),sp

		ENDM

;---------------

MODULEstop	
		jsr	jouepas

		rts

;---------------

MODULEdsp
		tst.w	qs_music
		bne.s	no_MODULEdsp

		lea	FILEdsp_buff(pc),a0
		lea	dsp_buff,a1
		move.l	BYTESdsp_buff(pc),d0
		bsr	load

		Boot_dsp #(dsp_buff_end-dsp_buff)/3,#dsp_buff

no_MODULEdsp
		rts

;---------------

MODULErun
		jsr	do_note

		jsr	paint_init_point
		jsr	init_adc
		jsr	paint_init_point
		jsr	Init_all

		jsr	paint_init_point
		lea	module,a0
		jsr	Init_module
		tst.b	d0
		bne.s	FIN

		jsr	paint_init_point
		jsr	joue

FIN
		rts

;---------------

		include	"include\menu\parts\load_dtm.s"

;--------------------------------------

		ifne menuedata_load

dsp_buff	incbin	"data\menudata\digidsp2.out"
dsp_buff_end
		endc


p_end		dc.l	module_buffer

;--------------------------------------







