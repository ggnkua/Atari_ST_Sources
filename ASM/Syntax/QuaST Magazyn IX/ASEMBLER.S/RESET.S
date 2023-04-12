;*------------------------------------------------------------------------*
;*  QuaST Magazyn IX (C) 28.12.1975 QuaST Club / dysk #C - procedury *.S  *
;*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*
;|																		  |
;|		Reset - po zresetowaniu komputera, zostanie wyswietlony rysunek	  |
;|  																	  |
;| autor: ???? 								    				  		  |	
;| uwagi: -																  |
;*------------------------------------------------------------------------*
	
		SECTION TEXT
	
		clr.l 	-(sp)
		move.w 	#32,-(sp)
		trap 	#1
		addq.w 	#6,sp
	
		move.l 	#$31415926,$426.w
		move.l 	#reset,$42a.w
	
		clr.w 	-(sp)
		trap 	#1
	
RESET:	move.l 	#$60000,sp				ustawienie stosu
		move.b 	#$0f,$ffff8201.w		adres ekranu f8000
		move.b 	#$80,$ffff8203.w
		move.b 	#2,$ffff820a.w			50 Hz
		lea 	rys+2,a0
		lea 	$ffff8240.w,a1
		movem.l (a0),d0-d7
		movem.l d0-d7,(a1)

		lea 	rys+34,a0
		lea 	$f8000,a1
		move.w 	#7999,d0
pic:	move.l (a0)+,(a1)+
		dbf 	d0,pic

w_kolo:	cmpi.b 	#57,$fffffc02.w
		bne.s 	w_kolo
		move.b 	#0,$ffff820a.w
		bra.s 	w_kolo
	
rozjasnij:
		move.l	#RYS+2,a0		* procedura rozjasniajaca rysunek
		movea.l	#$ffff8240,a1
		MOVEQ	#6,D4
		MOVE.w	#0,D7
Q1425B6	MOVEQ	#0,D0
Q1425B8	MOVE.W	0(A1,D0.W),D1
		move.w	0(a0,d0.w),d5
		move.w	d5,d6
		move.w	d6,qd7
		MOVE.W	D1,D2
		MOVE.W	D2,D3
		ANDI.W	#7,D1
		addQ.W	#1,D1
		andi.w	#7,d5
		cmp.w	d5,d1
		bcs.S	Q1425CA
		MOVE.w	d5,D1
Q1425CA	ANDI.W	#$70,D2
		addI.W	#$10,D2
		andi.w	#$70,d6
		cmp.w	d6,d2
		bcs.S	Q1425D6
		MOVE.w	d6,D2
Q1425D6	ANDI.W	#$700,D3
		addI.W	#$100,D3
		andi.w	#$700,qd7
		cmp.w	qd7,d3	
		bcs.S	Q1425E2
		MOVE.w	qd7,D3
Q1425E2	OR.W	D2,D1
		OR.W	D3,D1
      	MOVE.W	D1,0(A1,D0.W)
		ADDQ.W	#1,D7
		BTST	#0,D7
		BEQ.S	Q1425FC
		BTST	#1,D7
		BEQ.S	Q1425FC
		btst	#2,d7
		beq.s	Q1425FC
		BSR	Q426D4
Q1425FC	ADDQ.W	#2,D0
		CMPI.W	#$20,D0
		BMI.S	Q1425B8
		DBF	D4,Q1425B6
		rts

Q426D4	MOVE.L	D0,-(A7)
		MOVE.L	$466.W,D0
Q426DA	CMP.L	$466.W,D0
		BEQ.S	Q426DA
		MOVE.L	$466.W,D0
Q426DA1	CMP.L	$466.W,D0
		BEQ.S	Q426DA1
		MOVE.L	(A7)+,D0
		RTS
	
		SECTION DATA

rys:	incbin "\asembler.s\dane.dat\*.pi1
		even	

		SECTION BSS
qd7:	ds.l 1