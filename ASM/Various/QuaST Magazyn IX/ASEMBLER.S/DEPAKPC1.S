;*------------------------------------------------------------------------*
;*  QuaST Magazyn IX (C) 28.12.1975 QuaST Club / dysk #C - procedury *.S  *
;*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*
;|																		  |
;|			  PC1 depaker - depakowanie rysunku w formacie PC1			  |
;|  																	  |
;| autor: ???    														  |
;| uwagi: Adres rysunku do rozpakowanie powinien sie znajdowac w		  |
;|        rejestrze A0, dane rozpakuja sie do adresu podanego w A1    	  |
;*------------------------------------------------------------------------*

 		moveq 	#0,D2
 		movem.l A0-A1,-(sp)
gb1: 	moveq 	#0,D1
 		move.b 	(A0)+,D1  	; get byte
 		tst.b 	D1
 		bpl 	cd1

 		neg.b 	D1  		; copy batch
		add 	D1,D2
		addq 	#1,D2
 		move.b 	(A0)+,D0
cbl1: 	move.b 	D0,(A1)+
 		dbra 	D1,cbl1
 		bra 	echk1

cd1: 	add 	D1,D2  		; copy direct
 		addq 	#1,D2
cdl1: 	move.b 	(A0)+,(A1)+
 		dbra 	D1,cdl1

echk1: 	cmp 	#32000,D2
 		bpl 	gb1
 		movem.l (sp)+,A0-A1
 		move 	#199,temp2  ;200 lines
crscr2: move 	#4,temp
 		move.l 	A1,A2
crscr1: movem.w (A2),D0/D2/D4/D6
 		swap 	D0
 		swap 	D2
 		swap 	D4
 		swap 	D6
 		move 	40(A2),D0   ;then plane 2
 		move 	42(A2),D2
 		move 	44(A2),D4
 		move 	46(A2),D6
 		movem.w 80(A2),D1/D3/D5/D7
 		swap 	D1
 		swap 	D3
 		swap 	D5
 		swap 	D7
 		move 	120(A2),D1  ; then plane 4
 		move 	122(A2),D3
 		move 	124(A2),D5
 		move 	126(A2),D7
 		movem.l D0-D7,(A0)
 		lea 	32(A0),A0
 		lea 	8(A2),A2
 		subq 	#1,temp
 		bcc 	crscr1
 		lea 	160(A1),A1
 		subq 	#1,temp2
 		bcc 	crscr2
 		rts

temp: 	dc.w 0
temp2: 	dc.w 0

