DSP_JUMPTREE	EQU	1				; 1: use jumptree in texturemapper
DSP_SYNC	EQU	0

; ------------------------------------------------------
		section	text
; ------------------------------------------------------

; =====================
; == Sprite drawing ===
; =====================

draw_sprite:	move.w	(a0),d6				; d6: y
		move.w	(a0),d5				; d5: x
		movea.l	screen_buffer,a2
		adda.l	(mul_y.l,pc,d6.l*4),a2
		move.w	#$ffff,(a2,d5.l*2)
		rts

; ====================
; === Line drawing ===
; ====================

draw_line:	move.w	d7,-(sp)

		read_w	d1				; y1
		move.w	(a0),d0				; x1
		move.w	(a0),d3				; y2
		move.w	(a0),d2				; x2
		move.w	(a0),d4				; d4.w: number of material (color)
		movea.l	scene_pal,a2
		move.w	(a2,d4.l*2),d4			; d4.w: hicolor word
		bsr.w	tc_line
		
		move.w	(sp)+,d7
		rts

; ============================
; === Flat polygon drawing ===
; ============================

draw_flat:	read_w	d6				; d6: dy
		dble	d6,.ok1				; dy-- & jump
		rts

.ok1:		move.w	(a0),d5				; top y
		movea.l	screen_buffer,a2
		adda.l	(mul_y.l,pc,d5.l*4),a2
		
		move.w	(a0),d2				; d2.w: number of material (color)
		movea.l	scene_pal,a3
		move.w	(a3,d2.l*2),d2			; d2.w: hicolor word

.next_span:	read_w	d5				; dx // sync
		bgt.b	.ok2
		dbra	d6,.next_span
		rts

.ok2:		move.w	(a0),d3				; pixel offset from previous position
		adda.l	d3,a2				; update pointer

		moveq	#$1f,d4				; mask for REPT (32)
		and.l	d5,d4				; 0-31
		neg.l	d4
		lsr.w	#5,d5				; dx/32
		jmp	.jump_in(pc,d4.l*2)

.inloop:	REPT	32
		move.w	d2,(a2)+
		ENDR
.jump_in:	dbra	d5,.inloop

 		dbra	d6,.next_span
		rts
		
; ======================================
; === Gouraud shaded polygon drawing ===
; ======================================

draw_gouraud:	read_w	d6				; d6: dy
		dble	d6,.ok1				; dy-- & jump
		rts

.ok1:		move.w	(a0),d5				; top y
		;read_w	d5
		movea.l	screen_buffer,a2
		adda.l	(mul_y.l,pc,d5.l*4),a2
		movea.l	scene_colortab,a3
		
.next_span:	read_w	d5				; dx // sync
		dble	d5,.ok2				; dx-- & jump
		dbra	d6,.next_span
		rts

.ok2:		move.w	(a0),d4				; pixel offset from previous position
		;read_w	d4
		adda.l	d4,a2				; update pointer

.inloop:	move.w	(a0),d4				; d4.w: $SSCC
		;read_w	d4
		move.w	(a3,d4.l*2),(a2)+
		dbra	d5,.inloop

 		dbra	d6,.next_span
		rts

; ==================================
; === Offset based texturemapper ===
; ==================================

draw_offset_texture:
		move.l	(current_cpu_textures.l,pc,d5.l*4),d4	; get texture address
		IFNE	DSP_SYNC
		moveq	#1,d2
		ENDC
		
		read_w	d6				; d6: dy
		dble	d6,.ok1				; dy-- & jump
		rts

.ok1:		move.w	(a0),d5				; top y
		movea.l	screen_buffer,a2
		adda.l	(mul_y.l,pc,d5.l*4),a2
		
.next_span:	read_w	d5				; dx // sync
		dble	d5,.ok2
		dbra	d6,.next_span
		rts
.ok2:
		move.w	(a0),d3				; pixel offset from previous position
		adda.l	d3,a2				; update pointer

		IFNE	DSP_SYNC
		and.b	d2,(a1)
		beq.b	*-2
		ENDC

.inloop:	move.w	(a0),d4				; u:v << 1
		movea.l	d4,a4
		move.w	(a4),(a2)+
		dbra	d5,.inloop

		dbra	d6,.next_span
		rts

; ===============================
; === DSP based texturemapper ===
; ===============================

draw_dsp_texture:
		IFNE	DSP_SYNC
		moveq	#1,d2
		ENDC
		
		read_w	d6				; d6: dy
		dble	d6,.ok1				; dy-- & jump
		rts

.ok1:		move.w	(a0),d5				; top y
		;read_w	d5
		movea.l	screen_buffer,a2
		adda.l	(mul_y.l,pc,d5.l*4),a2

.next_span:	read_w	d5				; dx // sync

		IFNE	DSP_JUMPTREE
		bgt.b	.ok2
		ELSE
		dble	d5,.ok2				; dx-- & jump
		ENDC
		dbra	d6,.next_span
		rts

.ok2:		move.w	(a0),d3				; pixel offset from previous position
		;read_w	d3
		adda.l	d3,a2				; update pointer

		IFNE	DSP_SYNC
		and.b	d2,(a1)
		beq.b	*-2
		ENDC

		IFNE	DSP_JUMPTREE
		moveq	#$1f,d4				; mask for REPT (32)
		and.l	d5,d4				; 0-31
		neg.l	d4
		lsr.w	#5,d5				; dx/32
		jmp	.jump_in(pc,d4.l*2)
		ENDC

		IFNE	DSP_JUMPTREE
.inloop:	REPT	32
		move.w	(a0),(a2)+
		ENDR
.jump_in:
		ELSE
.inloop:	move.w	(a0),(a2)+
		;read_w	(a2)+
		ENDC
		dbra	d5,.inloop

		dbra	d6,.next_span
		rts
		
; ===================================
; === Alphatexture polygon filler ===
; ===================================

draw_alpha_texture:
		andi.w	#$000f,d5
		move.l	(current_alpha_textures.l,pc,d5.l*4),a4	; get texture address
		lea	$ffffa204.w,a3

		;IFNE	DSP_SYNC
		moveq	#1,d2
		;ENDC
			
		read_w	d6				; d6: dy
		dble	d6,.ok1				; dy-- & jump
		rts

.ok1:		move.w	(a0),d5				; top y
		;read_w	d5
		movea.l	screen_buffer,a2
		adda.l	(mul_y.l,pc,d5.l*4),a2
		
.next_span:	read_w	d5				; dx // sync
		dble	d5,.ok2
		dbra	d6,.next_span
		rts
.ok2:
		move.w	(a0),d3				; pixel offset from previous position
		;read_w	d3
		adda.l	d3,a2				; update pointer

		;IFNE	DSP_SYNC
		and.b	d2,(a1)
		beq.b	*-2
		;ENDC

.inloop:	move.l	(a3),d4				; d4.l: S:V:U
		move.w	(a4,d4.l*2),(a2)+
		dbra	d5,.inloop

		dbra	d6,.next_span
		rts
		
; =============================================
; === DSP based alphatexture polygon filler ===
; =============================================

draw_dsp_alpha:
		andi.w	#$000f,d5
		move.l	(dsp_current_alpha_tables.l,pc,d5.l*4),d4
		;movea.l	(alpha_tables.l,pc,d5.l*4),a4

		;IFNE	DSP_SYNC
		moveq	#1,d2
		;ENDC
		
		read_w	d6				; d6: dy
		dble	d6,.ok1				; dy-- & jump
		rts

.ok1:		move.w	(a0),d5				; top y
		;read_w	d5
		movea.l	screen_buffer,a2
		adda.l	(mul_y.l,pc,d5.l*4),a2
		
.next_span:	read_w	d5				; dx // sync
		dble	d5,.ok2
		dbra	d6,.next_span
		rts
.ok2:
		move.w	(a0),d3				; pixel offset from previous position
		;read_w	d3
		adda.l	d3,a2				; update pointer

		;IFNE	DSP_SYNC
		and.b	d2,(a1)
		beq.b	*-2
		;ENDC

.inloop:	move.w	(a0),d4				; shade:pixel << 1
		;read_w	d4
		movea.l	d4,a4
		move.w	(a4),(a2)+
		;move.w	(a0),d4
		;move.w	(a4,d4.l*2),(a2)+
		dbra	d5,.inloop

		dbra	d6,.next_span
		rts

; ------------------------------------------------------
		section	text
; ------------------------------------------------------

		include	"engine\tc_line.s"