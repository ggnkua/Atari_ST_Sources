export	block_it

	TEXT
; **** Macht den "Nadeldreher": Aufruf: 
; **** block_it( *dest, *src, bweite, offset, bytes_per_spalte )
block_it:
	MOVEM.L	A2/D2-D6,-(A7)
	SUBQ	#1,	D0
	SUBQ	#1,	D2
loop1:	; i-loop
	MOVEQ	#7,	D3
loop2:	; j-loop
	MOVE.W	D2,	D4	; Wie viele Bytes?
	MOVEA.L	A1,	A2
loop3:	; k-loop
	MOVEQ	#0,	D6
	BTST	D3, 	(A2)
	BEQ	ns0
	BSET	#7,	D6
ns0:	ADDA.L	D1,	A2
	BTST	D3, 	(A2)
	BEQ	ns1
	BSET	#6,	D6
ns1:	ADDA.L	D1,	A2
	BTST	D3, 	(A2)
	BEQ	ns2
	BSET	#5,	D6
ns2:	ADDA.L	D1,	A2
	BTST	D3, 	(A2)
	BEQ	ns3
	BSET	#4,	D6
ns3:	ADDA.L	D1,	A2
	BTST	D3, 	(A2)
	BEQ	ns4
	BSET	#3,	D6
ns4:	ADDA.L	D1,	A2
	BTST	D3, 	(A2)
	BEQ	ns5
	BSET	#2,	D6
ns5:	ADDA.L	D1,	A2
	BTST	D3, 	(A2)
	BEQ	ns6
	BSET	#1,	D6
ns6:	ADDA.L	D1,	A2
	BTST	D3, 	(A2)
	BEQ	ns7
	BSET	#0,	D6
ns7:	ADDA.L	D1,	A2
	MOVE.B	D6,	(A0)+
	DBF	D4,	loop3
;
	DBF	D3,	loop2
;
	ADDQ.L	#1,	A1
	DBF	D0,	loop1
	MOVEM.L	(A7)+,	A2/D2-D6
	RTS
