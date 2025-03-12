; ------------------------------------------------------
		section	text
; ------------------------------------------------------


; handle user keyboard inputs
; which change some rendering params

handle_keyboard:
		cmp.b	#$48,$fffffc02.w
		bne.b	.x1
		addi.w	#3,cam_pos_y
.x1:		cmp.b	#$50,$fffffc02.w
		bne.b	.x2
		subi.w	#3,cam_pos_y
.x2:		cmp.b	#$4b,$fffffc02.w
		bne.b	.x3
		subi.w	#3,cam_pos_x
.x3:		cmp.b	#$4d,$fffffc02.w
		bne.b	.x4
		addi.w	#3,cam_pos_x
.x4:		cmp.b	#$52,$fffffc02.w
		bne.b	.x5
		subi.w	#3,cam_pos_z
		;addq.w	#3,focus_dist_z
.x5:		cmp.b	#$47,$fffffc02.w
		bne.b	.x6
		addi.w	#3,cam_pos_z
		;subq.w	#3,focus_dist_z

.x6:		lea	cam_angles,a0
		cmp.b	#$10,$fffffc02.w		; q
		bne.b	.x7
		addq.w	#3,4(a0)
		andi.w	#sincos_entries-1,4(a0)
.x7:		cmp.b	#$12,$fffffc02.w		; e
		bne.b	.x8
		subq.w	#3,4(a0)
		andi.w	#sincos_entries-1,4(a0)
.x8:		cmp.b	#$11,$fffffc02.w		; w
		bne.b	.x9
		addq.w	#3,(a0)
		andi.w	#sincos_entries-1,(a0)
.x9:		cmp.b	#$1f,$fffffc02.w		; s
		bne.b	.xa
		subq.w	#3,(a0)
		andi.w	#sincos_entries-1,(a0)
.xa:		cmp.b	#$1e,$fffffc02.w		; a
		bne.b	.xb
		addq.w	#3,2(a0)
		andi.w	#sincos_entries-1,2(a0)
.xb:		cmp.b	#$20,$fffffc02.w		; d
		bne.b	.xc
		subq.w	#3,2(a0)
		andi.w	#sincos_entries-1,2(a0)
.xc:
		rts

; ------------------------------------------------------
		section	text
; ------------------------------------------------------
