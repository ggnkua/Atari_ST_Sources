; Spectrum 512/4096 template
; 320x199 image resolution, 48 colours per scanline
; First scanline trashed due to hardsync setup
;
; Double buffered screens
;
; September 4, 2011

		section	text

spec512_init:
		rts

spec512_runtime_init:
		run_once				;Macro to ensure the runtime init only run once
		jsr	black_pal
		jsr	clear_screens
		bsr	spec512_copy_pic
		bsr	spec512_code_copy
		rts


spec512_vbl:
		move.l  screen_adr,d0			;Set screenaddress
		lsr.w	#8,d0				;
		move.l	d0,$ffff8200.w			;

		move.l	screen_adr,d0			;Swap screens
		move.l	screen_adr2,screen_adr		;
		move.l	d0,screen_adr2			;
		rts

spec512_main:
		rts

spec512_ta:
		do_hardsync				;Macro to syncronize into exact cycle

		;inits
		dcb.w	35,$4e71			;Zzz..

		lea	spec512_picture+32000,a0	;3 Palette data
		lea	$ffff8240.w,a1			;2
		move.l	a1,a2				;1

		jsr	codebuf				;Run generated code
		move.w	#$2300,sr
		rts


spec512_begin:
		rept	8
		move.l	(a0)+,(a2)+			;5*8
		endr

		dcb.w	5,$4e71

		move.l	a1,a2				;1
		move.l	a1,a3				;1
		move.l	a1,a4				;1

		rept	8
		move.l	(a0)+,(a3)+			;5*8
		endr

		rept	8
		move.l	(a0)+,(a4)+			;5*8
		endr
spec512_end:



spec512_copy_pic:
		;Copy picture to both workscreens
		move.l	screen_adr,a0
		move.l	screen_adr2,a1
		lea	spec512_picture,a2

		move.w	#200-1,d7
.y:		move.w	#320/2/4-1,d6
.x:
		move.l	(a2)+,d0
		move.l	d0,(a0)+
		move.l	d0,(a1)+

		dbra	d6,.x
		dbra	d7,.y
		rts


spec512_code_copy:
		;Copy code to the code buffer
		jsr	code_copy_reset			;Reset code copier variables

		move.l	#spec512_begin,d0		;Copy all Spec512 scanlines
		move.l	#spec512_end,d1			;
		move.w	#199,d2				;
		jsr	code_copy			;

		jsr	code_copy_rts			;Make sure the code buffer does rts :)
		rts


		section	data

spec512_picture:
		incbin	'spec512/pic.spu'		;Spectrum 512/4096 unpacked image
		even

		section	text

