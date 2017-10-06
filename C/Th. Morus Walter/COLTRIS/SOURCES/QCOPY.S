tet_buffer_width	EQU		20		; in byte
col_buffer_width	EQU		16		; in byte

	XREF	screen_width	; word, bildschirmbreite in byte
	XREF	buffer_width	; word, pufferbreite in byte
	XREF	source_width	; word, quellbreite in byte

	XDEF	copy_160		; tetris 16 *
	XDEF	copy_200		; tetris 20 *
		;   --------		; tetris 22 (geht nicht)
	XDEF	copy_120		; columns 20 *
	XDEF	copy_144		; columns 24 *
	XDEF	copy_168		; columns 28

	XDEF	xcopy16
	XDEF	xxcopy32

tet_width	equ		28
col_width	equ		40

copy_160:	; a0 ziel
			; a1 quelle
			; d0 lines-1
			; BREITE: 160 pixel = 20 byte = 5 long
		MOVEM.L	D3-D5,-(SP)
.loop:	MOVEM.L (A1)+,D1-D5
		ADD.W	#20,A0
		MOVEM.L	D1-D5,-(A0)
		ADD.W	screen_width,A0
		DBRA	D0,.loop
		MOVEM.L	(SP)+,D3-D5
		RTS

copy_200:	; a0 ziel
			; a1 quelle
			; d0 lines-1
			; BREITE: 200 pixel = 25 byte = 6 long + 1 byte
		MOVEM.L	D3-D6,-(SP)
.loop:	MOVEM.L (A1)+,D1-D6
		ADD.W	#24,A0
		MOVEM.L	D1-D6,-(A0)
		MOVE.B  (A1)+,D1
		MOVE.B	D1,24(A0)
		ADDQ.W	#1,A1
		ADD.W	screen_width,A0
		DBRA	D0,.loop
		MOVEM.L	(SP)+,D3-D6
		RTS

copy_120:	; a0 ziel
			; a1 quelle
			; d0 lines-1
			; BREITE: 120 pixel = 15 byte = 3 long 3 byte
			; breite der quelle 16 byte
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

copy_144:	; a0 ziel
			; a1 quelle
			; d0 lines-1
			; BREITE: 144 pixel = 18 byte = 4 long 2 byte
			; breite der quelle 18 byte
		MOVEM.L	D3-D4,-(SP)
.loop:	MOVEM.L (A1)+,D1-D4
		ADD.W	#16,A0
		MOVEM.L D1-D4,-(A0)
		MOVE.W  (A1)+,D1
		MOVE.W	D1,16(A0)
		ADDA.W	screen_width,A0
		DBRA	D0,.loop
		MOVEM.L	(SP)+,D3-D4
		RTS

copy_168:	; a0 ziel
			; a1 quelle
			; d0 lines-1
			; BREITE: 168 pixel = 21 byte = 5 long 1byte
			; breite der quelle 22 byte
		MOVEM.L	D3-D5,-(SP)
.loop:	MOVEM.L (A1)+,D1-D5
		ADD.W	#20,A0
		MOVEM.L D1-D5,-(A0)
		MOVE.B  (A1)+,D1
		MOVE.B	D1,20(A0)
		ADDQ.W	#1,A1
		ADDA.W	screen_width,A0
		DBRA	D0,.loop
		MOVEM.L	(SP)+,D3-D5
		RTS

xcopy16:	; a0 ziel
			; a1 quelle
			; d0 lines-1
.loop:	MOVE.W	(A1),(A0)
		ADD.W	buffer_width,A0
		ADD.W	source_width,A1
		DBRA	D0,.loop
		RTS

xxcopy32:	;	xxcopy32(void *ziel,void *quelle,int lines,long maske)
			; a0 ziel
			; a1 quelle
			; d0 lines-1
			; d1 maske

.loop:	AND.L	D1,(A0)				; zu setzende bits ausmaskieren
		MOVE.L	(A1),D2				; quelle nach D2
		OR.L	D2,(A0)				; bits setzen
		ADD.W	buffer_width,A0
		ADD.W	source_width,A1
		DBRA	D0,.loop
		RTS


