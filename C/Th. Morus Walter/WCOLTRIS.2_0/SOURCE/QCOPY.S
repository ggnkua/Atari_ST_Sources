tet_buffer_width	EQU		20		; in byte
col_buffer_width	EQU		16		; in byte

	XREF	screen_width	; word

	XDEF	copy_tet
	XDEF	copy_col
	XDEF	dr_tetris
	XDEF	dr_columns1,dr_columns2

tet_width	equ		28
col_width	equ		40

copy_tet:	; a0 ziel
			; a1 quelle
			; d0 lines
			; BREITE: 160 pixel = 20 byte = 5 long
		MOVEM.L	D3-D5,-(SP)
.loop:	MOVEM.L (A1)+,D1-D5
		ADD.W	#20,A0
		MOVEM.L	D1-D5,-(A0)
		ADD.W	screen_width,A0
		DBRA	D0,.loop
		MOVEM.L	(SP)+,D3-D5
		RTS

copy_col:	; a0 ziel
			; a1 quelle
			; d0 lines
			; BREITE: 120 pixel = 15 byte = 3 long 3 byte
			; breite der quelle 20 byte
		MOVEM.L	D3,-(SP)
.loop:	MOVEM.L (A1)+,D1-D3
		ADD.W	#12,A0
		MOVEM.L D1-D3,-(A0)
		MOVE.W  (A1)+,D1
		MOVE.W	D1,12(A0)
		MOVE.B  (A1)+,D1
		MOVE.B	D1,14(A0)
		ADDQ.W	#1,A1
		ADDA.W	screen_width,A0
		DBRA	D0,.loop
		MOVEM.L	(SP)+,D3
		RTS

dr_tetris:	; a0: ziel-addresse 
			; a1: quell-addresse
		MOVE.W	(A1),(A0)
		ADDA.W	#tet_width,A1
		ADDA.W	#tet_buffer_width,A0
		MOVE.W	(A1),(A0)
		ADDA.W	#tet_width,A1
		ADDA.W	#tet_buffer_width,A0
		MOVE.W	(A1),(A0)
		ADDA.W	#tet_width,A1
		ADDA.W	#tet_buffer_width,A0
		MOVE.W	(A1),(A0)
		ADDA.W	#tet_width,A1
		ADDA.W	#tet_buffer_width,A0
		MOVE.W	(A1),(A0)
		ADDA.W	#tet_width,A1
		ADDA.W	#tet_buffer_width,A0
		MOVE.W	(A1),(A0)
		ADDA.W	#tet_width,A1
		ADDA.W	#tet_buffer_width,A0
		MOVE.W	(A1),(A0)
		ADDA.W	#tet_width,A1
		ADDA.W	#tet_buffer_width,A0
		MOVE.W	(A1),(A0)
		ADDA.W	#tet_width,A1
		ADDA.W	#tet_buffer_width,A0
		MOVE.W	(A1),(A0)
		ADDA.W	#tet_width,A1
		ADDA.W	#tet_buffer_width,A0
		MOVE.W	(A1),(A0)
		ADDA.W	#tet_width,A1
		ADDA.W	#tet_buffer_width,A0
		MOVE.W	(A1),(A0)
		ADDA.W	#tet_width,A1
		ADDA.W	#tet_buffer_width,A0
		MOVE.W	(A1),(A0)
		ADDA.W	#tet_width,A1
		ADDA.W	#tet_buffer_width,A0
		MOVE.W	(A1),(A0)
		ADDA.W	#tet_width,A1
		ADDA.W	#tet_buffer_width,A0
		MOVE.W	(A1),(A0)
		ADDA.W	#tet_width,A1
		ADDA.W	#tet_buffer_width,A0
		MOVE.W	(A1),(A0)
		ADDA.W	#tet_width,A1
		ADDA.W	#tet_buffer_width,A0
		MOVE.W	(A1),(A0)
		RTS

dr_columns1:; a0: ziel-addresse 
			; a1: quell-addresse
		MOVE.B	#$F0,D0

		AND.B	D0,(A0)
		MOVE.B	(A1),D1
		OR.B	D1,(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,(A0)
		MOVE.B	(A1),D1
		OR.B	D1,(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,(A0)
		MOVE.B	(A1),D1
		OR.B	D1,(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,(A0)
		MOVE.B	(A1),D1
		OR.B	D1,(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,(A0)
		MOVE.B	(A1),D1
		OR.B	D1,(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,(A0)
		MOVE.B	(A1),D1
		OR.B	D1,(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,(A0)
		MOVE.B	(A1),D1
		OR.B	D1,(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,(A0)
		MOVE.B	(A1),D1
		OR.B	D1,(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,(A0)
		MOVE.B	(A1),D1
		OR.B	D1,(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,(A0)
		MOVE.B	(A1),D1
		OR.B	D1,(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,(A0)
		MOVE.B	(A1),D1
		OR.B	D1,(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,(A0)
		MOVE.B	(A1),D1
		OR.B	D1,(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,(A0)
		MOVE.B	(A1),D1
		OR.B	D1,(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,(A0)
		MOVE.B	(A1),D1
		OR.B	D1,(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,(A0)
		MOVE.B	(A1),D1
		OR.B	D1,(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,(A0)
		MOVE.B	(A1),D1
		OR.B	D1,(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,(A0)
		MOVE.B	(A1),D1
		OR.B	D1,(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,(A0)
		MOVE.B	(A1),D1
		OR.B	D1,(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,(A0)
		MOVE.B	(A1),D1
		OR.B	D1,(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,(A0)
		MOVE.B	(A1),D1
		OR.B	D1,(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),2(A0)

		RTS

dr_columns2:; a0: ziel-addresse 
			; a1: quell-addresse
		MOVE.B	#$0F,D0

		AND.B	D0,2(A0)
		MOVE.B	(A1),(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),D1
		OR.B	D1,2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,2(A0)
		MOVE.B	(A1),(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),D1
		OR.B	D1,2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,2(A0)
		MOVE.B	(A1),(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),D1
		OR.B	D1,2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,2(A0)
		MOVE.B	(A1),(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),D1
		OR.B	D1,2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,2(A0)
		MOVE.B	(A1),(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),D1
		OR.B	D1,2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,2(A0)
		MOVE.B	(A1),(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),D1
		OR.B	D1,2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,2(A0)
		MOVE.B	(A1),(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),D1
		OR.B	D1,2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,2(A0)
		MOVE.B	(A1),(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),D1
		OR.B	D1,2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,2(A0)
		MOVE.B	(A1),(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),D1
		OR.B	D1,2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,2(A0)
		MOVE.B	(A1),(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),D1
		OR.B	D1,2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,2(A0)
		MOVE.B	(A1),(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),D1
		OR.B	D1,2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,2(A0)
		MOVE.B	(A1),(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),D1
		OR.B	D1,2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,2(A0)
		MOVE.B	(A1),(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),D1
		OR.B	D1,2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,2(A0)
		MOVE.B	(A1),(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),D1
		OR.B	D1,2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,2(A0)
		MOVE.B	(A1),(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),D1
		OR.B	D1,2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,2(A0)
		MOVE.B	(A1),(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),D1
		OR.B	D1,2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,2(A0)
		MOVE.B	(A1),(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),D1
		OR.B	D1,2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,2(A0)
		MOVE.B	(A1),(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),D1
		OR.B	D1,2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,2(A0)
		MOVE.B	(A1),(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),D1
		OR.B	D1,2(A0)
		ADDA.W	#col_width,A1
		ADDA.W	#col_buffer_width,A0

		AND.B	D0,2(A0)
		MOVE.B	(A1),(A0)
		MOVE.B	1(A1),1(A0)
		MOVE.B	2(A1),D1
		OR.B	D1,2(A0)

		RTS
