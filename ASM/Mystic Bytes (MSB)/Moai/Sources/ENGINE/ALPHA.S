; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------

init_alpha_tables:

; gouraud
		lea	m3d_palettes,a2
		lea	m3d_colortabs,a3
		moveq	#M3D_SCENES-1,d0
		
.gouraud_loop:	move.w	background_colour,d4		; fade from this colour
		clr.w	d5				; src -> base colour
		moveq	#64,d6				; shades
		move.l	#256,d7				; colours
		movea.l	(a2)+,a0			; src palette
		movea.l	(a3)+,a1			; dst buffer
		
		movem.l	d0/a2-a3,-(sp)
		bsr.w	generate_shadetab
		movem.l	(sp)+,d0/a2-a3
		
		dbra	d0,.gouraud_loop
		
; dsp alpha tables
		lea	dsp_alpha_tables,a0
		moveq	#DSP_ALPHA_TEXTURES-1,d7
		
.alloc_loop:	move.l	a0,-(sp)
		move.w	d7,-(sp)

		move.w	#3,-(sp)			; mxalloc()
		move.l	#256*64*2+65536,-(sp)
		move.w	#$44,-(sp)			;
		trap	#1				;
		addq.l	#8,sp				;
		
		move.w	(sp)+,d7
		movea.l	(sp)+,a0

		tst.l	d0				; ramcheck
		bne.b	.ok				; ok
		move.l	#exit_noram_text,error_adr	; error message
		bra.w	exit				;
		
.ok:		addi.l	#65536,d0
		clr.w	d0
		move.l	d0,(a0)+
		
		dbra	d7,.alloc_loop
		
		lea	dsp_alpha_textures,a2
		lea	dsp_alpha_tables,a3
		moveq	#DSP_ALPHA_TEXTURES-1,d0
		
.dsp_loop:	move.w	background_colour,d4		; fade from this colour
		clr.w	d5				; src -> base colour
		move.w	#64,d6				; shades
		move.l	#256,d7				; colours
		movea.l	(a2)+,a0
		addq.l	#8,a0				; skip header
		movea.l	(a3)+,a1			; dst buffer

		movem.l	d0/a2-a3,-(sp)
		bsr.w	generate_shadetab
		movem.l	(sp)+,d0/a2-a3

		dbra	d0,.dsp_loop
		
		bsr.w	pic_show_box
		rts
		
init_alpha_textures:
		lea	cpu_textures,a2
		lea	alpha_textures,a3
		moveq	#CPU_TEXTURES-1,d0
		
.loop:		move.w	background_colour,d4		; fade from this colour
		clr.w	d5				; background -> base colours
		move.w	#64,d6				; shades
		move.l	#128*128,d7			; colours
		movea.l	(a2)+,a0			; src palette
		movea.l	(a3)+,a1			; dst buffer

		movem.l	d0/a2-a3,-(sp)
		bsr.w	generate_shadetab
		movem.l	(sp)+,d0/a2-a3
		
		bsr.w	pic_show_box
		
		dbra	d0,.loop
		rts
		
; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------