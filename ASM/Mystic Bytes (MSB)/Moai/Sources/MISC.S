DSP_ALPHA_TEXTURES	EQU	5
DSP_ENV_TEXTURES	EQU	2
CPU_TEXTURES		EQU	4

; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------

realloc_mod:	clr.w	-(sp)				; Mxalloc()
		move.l	#34988,-(sp)			; size of module
		move.w	#$44,-(sp)			;
		trap	#1				;
		addq.l	#8,sp				;

		tst.l	d0				; ramcheck
		bne.b	.ok			; ok
		move.l	#exit_nostram_text,error_adr	; error message
		bra.w	exit				;
		
.ok:		lea	mod_fastram,a0
		movea.l	d0,a1
		move.l	d0,mod_stram
		move.w	#34988/4-1,d7

.loop:		move.l	(a0)+,(a1)+
		dbra	d7,.loop
		rts

realloc_tex:	lea	cpu_textures,a0
		moveq	#CPU_TEXTURES-1,d7

.loop1:		movea.l	(a0)+,a1
		lea	8(a1),a2
		
		move.w	#128*128*2/4-1,d6
.loop2:		move.l	(a2)+,(a1)+
		dbra	d6,.loop2

		dbra	d7,.loop1
		rts
		
set_hires_screen:
		IFEQ	debug
	
		tst.w	monitor
		beq.b	.vga
		lea	hc_rgb_300x200,a0
		bra.b	.set_res
.vga:		lea	hc_vga_300x200,a0
.set_res:	bra.w	set_res_scp
		rts
		
set_lowres_screen:
		tst.w	monitor
		beq.b	.vga
		lea	hc_rgb_300x100,a0
		bra.b	.set_res
.vga:		lea	hc_vga_300x100,a0
.set_res:	bra.w	set_res_scp
		rts

		ENDC

set_cache:	cmpi.l	#030,cpu_type
		bhi.b	.not_030
		movec	cacr,d0
		bset	#0,d0				; i cache on
		bset	#4,d0				; i burst on
		bclr	#8,d0				; d cache off
		bclr	#12,d0				; d burst off
		movec	d0,cacr
.not_030:	rts

; ------------------------------------------------------
		SECTION	DATA
; ------------------------------------------------------

mod_fastram:	incbin	"blur.mod"

alpha_textures:	dc.l	alpha_tex0
		dc.l	alpha_tex1
		dc.l	alpha_tex2
		dc.l	alpha_tex3

dsp_alpha_textures:
		dc.l	dsp_alpha_tex0
		dc.l	dsp_alpha_tex1
		dc.l	dsp_alpha_tex2
		dc.l	dsp_alpha_tex3
		dc.l	dsp_alpha_tex4
		
dsp_env_textures:
		dc.l	dsp_env_tex0
		dc.l	dsp_env_tex1
		
cpu_textures:	dc.l	cpu_tex0
		dc.l	cpu_tex1
		dc.l	cpu_tex2
		dc.l	cpu_tex3
		
dsp_env_tex0:	incbin	"trp\t_env1.trp"
dsp_env_tex1:	incbin	"trp\t_env3.trp"

		ifne	0
dsp_alpha_tex0:	incbin	"d:\textures\96k\t_kamen1.256"
dsp_alpha_tex1:	incbin	"d:\textures\96k\t_trava1.256"
dsp_alpha_tex2:	incbin	"d:\textures\96k\t_kamen2.256"
dsp_alpha_tex3:	incbin	"d:\textures\96k\t_trava2.256"
dsp_alpha_tex4:	incbin	"d:\textures\96k\t_okno1.256"

cpu_tex0:	incbin	"D:\textures\96k\t_drevo1.trp"
cpu_tex1:	incbin	"D:\textures\96k\t_stena1.trp"
cpu_tex2:	incbin	"D:\textures\96k\t_stena2.trp"
cpu_tex3:	incbin	"D:\textures\96k\t_tehla1.trp"
		endc

		IFNE	DSP_OS
dsp_engine:	incbin	'engine\engine.p56'
dsp_engine_end:
		even
		ENDC
		
current_alpha_textures:
		REPT	CPU_TEXTURES
		ds.l	1
		ENDR
		dc.l	alpha_tex0			; OVERFLOW PATCH!!!
		
; ------------------------------------------------------
		SECTION	BSS
; ------------------------------------------------------

mod_stram:	ds.l	1

dsp_alpha_tables:
		ds.l	16

dsp_current_alpha_tables:
		ds.l	16
		
current_cpu_textures:
		ds.l	16

alpha_tex0:	ds.w	128*128*64			; u x v x s
alpha_tex1:	ds.w	128*128*64			; u x v x s
alpha_tex2:	ds.w	128*128*64			; u x v x s
alpha_tex3:	ds.w	128*128*64			; u x v x s

		ifne	1
dsp_alpha_tex0:	ds.b	64*64+512+8
dsp_alpha_tex1:	ds.b	64*64+512+8
dsp_alpha_tex2:	ds.b	64*64+512+8
dsp_alpha_tex3:	ds.b	64*64+512+8
dsp_alpha_tex4:	ds.b	64*64+512+8

cpu_tex0:	ds.b	128*128*2+8
cpu_tex1:	ds.b	128*128*2+8
cpu_tex2:	ds.b	128*128*2+8
cpu_tex3:	ds.b	128*128*2+8
		endc

; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------