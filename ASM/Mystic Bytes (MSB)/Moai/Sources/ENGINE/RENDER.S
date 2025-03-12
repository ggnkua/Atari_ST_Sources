read_w		MACRO 
		;moveq	#%00000001,\1			; bit #0 
		;and.b	\1,(a1) 
		and.b	d0,(a1) 
		beq.b	*-2 
		move.w	(a0),\1 
		ENDM 
		
write_w		MACRO 
		moveq	#%00000010,\1			; bit #1 
		and.b	\1,(a1) 
		beq.b	*-2 
		move.w	\1,(a0) 
		ENDM 

; ------------------------------------------------------
		section	text 
; ------------------------------------------------------

; init registers for rendering process
; input: a0: screen buffer
; return: d7.w: <0 = nothing to render

rendering_init:	move.l	a0,screen_buffer

		moveq	#%00000001,d0			; prepare for read_w
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5
				
		lea	$ffffa206.w,a0			; for word DSP transfer
		lea	$ffffa202.w,a1			; DSP status

		read_w	d7				; d7: no of faces
		subq.w	#1,d7
		rts
		
rendering_main:

.next_face:	read_w	d5				; d5: command number // sync
		bpl.b	.ok				; isn't out of screen?
		dbra	d7,.next_face
		rts

.ok:		movea.l	(paintmode_tab.l,pc,d5.l*4),a2
		jsr	(a2)

		moveq	#%00000001,d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5
		dbra	d7,.next_face
		rts

						
; ------------------------------------------------------
		section	data
; ------------------------------------------------------

		EVEN
		;IFNE	*&2
		;ds.w	1
		;ENDC

paintmode_tab:
		REPT	16
		dc.l	draw_offset_texture		; texture 0-15
		ENDR
		REPT	16
		dc.l	draw_alpha_texture		; alpha texture 0-15
		ENDR
		dc.l	draw_dsp_alpha			; dsp alpha texture 0
		dc.l	draw_dsp_alpha			; dsp alpha texture 1
		dc.l	draw_dsp_texture		; dsp textured polygon
		dc.l	draw_gouraud			; gouraud shaded polygon
		dc.l	draw_flat			; flat polygon
		dc.l	draw_sprite			; sprite
		dc.l	draw_line			; line
		
; ------------------------------------------------------
		section	bss
; ------------------------------------------------------

		EVEN
		;IFNE	*&2
		;ds.w	1
		;ENDC

mul_y:		ds.l	SCR_H
screen_buffer:	ds.l	1

; ------------------------------------------------------
		section	text 
; ------------------------------------------------------

		include	"engine\painters.s"