Draw_Logo:
		MOVE.L	Logic,A0
		LEA	Logo,A1
		MOVEQ	#5-1,D0
.loop1:		MOVEQ	#(32)-1,D1
.loop2:
		MOVE.W	(A1)+,D2
		OR.W	D2,(A0)+
		DBF	D1,.loop2
		LEA	BytesPerLine-32*2(A0),A0
		DBF	D0,.loop1
		RTS





Draw_Hex_Number:
		moveq	#8-1,d7
.hexloop:	
		rol.l	#4,d0
		move.l	d7,-(a7)
		bsr	Draw_Hex_Byte
		move.l	(a7)+,d7
		dbf	d7,.hexloop
		rts


Draw_Hex_Byte:
		movem.l	d0/d1/d2,-(a7)
		and.w	#$f,d0

		mulu.w	#BytesPerLine*6,d2
		move.l	logic,a0
		add.l	d2,a0
		lea	(a0,d1.w*2),a0

		mulu.w	#3*5*2,d0
		lea	(Numbers_Data.l,d0.l),a1

		bsr	draw_3x5

		movem.l	(a7)+,d0/d1/d2
		addq.w	#4,d1			;x coord
		rts

draw_3x5:
		MOVEQ	#5-1,D0
.loop1:		MOVEQ	#3-1,D1
.loop2:		MOVE.W	(A1)+,D2
		EOR.W	D2,(A0)+
		DBF	D1,.loop2
		LEA	BytesPerLine-3*2(A0),A0
		DBF	D0,.loop1
		RTS


Draw_Info:
		lea	info_list,a0
.info_loop:
		movem.l	(a0)+,d0/d1/d2
		tst.l	d0
		bmi.s	.done

		move.l	d0,a1
		move.l	(a1),d0

		pea	(a0)
		bsr	Draw_Hex_Number
		move.l	(a7)+,a0
		bra	.info_loop
.done:		rts

info_list:
		dc.l	Viewer_X,$0000,$0001
		dc.l	Viewer_Y,$0000,$0002
		dc.l	Viewer_Z,$0000,$0003

		dc.l	Viewer_Distance,$0000,$0005

		dc.l	Rotation_X,$0000,$0006
		dc.l	Rotation_Y,$0000,$0007
		dc.l	Rotation_Z,$0000,$0008
		dc.l	-1

		section	data
Numbers_Data:	INCLUDE	F:\SOURCE\TDF\3d2\3dsys\NUMBER.S
		EVEN
Logo:		EQU	*+6
		INCBIN	'F:\Data\Tdf\Gfx\Avena.God'

		section	text
