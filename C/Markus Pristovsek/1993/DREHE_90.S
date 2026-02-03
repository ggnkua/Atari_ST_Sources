
EXPORT	drehe_90

; * Bitmap zeilenweise um 90 Grad drehen:
; *
; * drehe_90( char *quelle, char *ziel, long qweite, long zweite, long x );
	TEXT
drehe_90:
	MOVEM.L	D3-D6,	-(A7)
	MOVE.L	D2,	D4
	LSR	#3,	D2
	ADD.L	D2,	A0

	ANDI	#7,	D4
	MOVEQ	#7,	D3
	SUB	D4,	D3	; x = 7-(x%8)

	ADD.L	D1,	A1
	ADDQ.L	#1,	A1	; ziel += zweite+1

next_byte:
	MOVEQ	#0,	D4	; data = 0
	MOVEQ	#7,	D5	; i=7
	MOVEQ	#0,	D6	; j=0
bit_test:			; je Durchlauf ein Bit drehen
	ADD.L	D0,	A0	; quelle += qweite
	BTST	D3,	(A0)	; Bit x bei *quelle gesetzt?
	BEQ	neq
	BSET	D6,	D4	; Wenn nicht, bei data Bit j setzen
neq:	ADDQ	#1,	D6
	DBF	D5,	bit_test; while( i-->0 )

	MOVE.B	D4,	-(A1)	; *--ziel = data
	DBF	D1,	next_byte; while( q-->0  )

	MOVEM.L	(A7)+,	D3-D6
	RTS

