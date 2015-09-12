; save/restore mfp, palette, etc..

	ifne	DESK
	
	rsreset

old_vbi			rs.l	1
old_kybd		rs.l	1

old_intena		rs.w	1
old_intenb		rs.w	1
old_intmaskb	rs.w	1

old_palette:	rs.w	16
old_res:		rs.w	1
old_screen:		rs.l	1
old_stack:		rs.l	1

desk_vars_size	rs.w	1
desk_vars		ds.b	desk_vars_size

				ds.l	200
desk_stack:		ds.l	1

desk_start	macro	
		lea		desk_vars,a6

		clr.l	-(a7)
		move.w	#$20,-(a7)
		trap	#1
		addq.l	#6,a7
		
		move.l	d0,old_stack(a6)
		move.l	#desk_stack,a7

		move.w	#4,-(a7)
		trap	#14
		addq.l	#2,a7
		move.w	d0,old_res(a6)

		move.w	#2,-(a7)
		trap	#14
		addq.l	#2,a7
		move.l	d0,old_screen(a6)

		clr	-(a7)
		pea	-1
		move.l	(a7),-(a7)
		move.w	#5,-(a7)
		trap	#14
		lea	12(a7),a7

		movem.l	Colour00.w,d0-d7
		movem.l	d0-d7,old_palette(a6)

		move.w	#$2700,sr
		move.l	VectorVBL.w,old_vbi(a6)
		move.l	VectorKybdMidi.w,old_kybd(a6)

		move.b	IntEnableA.w,old_intena(a6)
		move.b	IntEnableB.w,old_intenb(a6)
		move.b	IntMaskB.w,old_intmaskb(a6)
		move.w	#$2300,sr

	endm
	
desk_stop	macro	
		lea		desk_vars,a6

		movem.l	old_palette(a6),d0-d7
		movem.l	d0-d7,Colour00.w

		move.w	#$2700,sr
		move.b	old_intena(a6),IntEnableA.w
		move.b	old_intenb(a6),IntEnableB.w
		move.b	old_intmaskb(a6),IntMaskB.w
		move.l	old_vbi(a6),VectorVBL.w
		move.l	old_kybd(a6),VectorKybdMidi.w
		move.w	#$2300,sr

		move.w	old_res(a6),-(a7)
		move.l	old_screen(a6),-(a7)
		move.l	(a7),-(a7)
		move.w	#5,-(a7)
		trap	#14
		lea		12(a7),a7

		move.l	old_stack(a6),-(a7)
		move.w	#$20,-(a7)
		trap	#1
		addq.l	#6,a7

		clr		-(a7)
		trap	#1
	endm
	
	endc

