	TEXT
ROTO_INIT
	MOVE.W	D0,SCREENX
	MOVE.W	D1,SCREENY
	MOVE.L	A0,MY_BUF
	MOVEQ	#0,D0
	MOVE.L	D0,D1
	MOVE.L	D0,D2
	MOVE.L	D0,D3
	MOVE.L	D0,D4
	MOVE.L	D0,D5
	MOVE.L	D0,D6
	MOVE.L	D0,D7
	
	MOVE.W	#0,Y
	move.l	ptr_load_tab_zoom,A5
	move.l	ptr_fin_tab_zoom,a4
	
	MOVEM.L	D0-D7/A0-A6,PARAM
	RTS

ROTO_INIT_256
	MOVE.W	D0,SCREENX
	MOVE.W	D1,SCREENY
	MOVE.L	A0,BUF_256
	MOVE.L	A1,MY_BUF
	MOVEQ	#0,D0
	MOVE.L	D0,D1
	MOVE.L	D0,D2
	MOVE.L	D0,D3
	MOVE.L	D0,D4
	MOVE.L	D0,D5
	MOVE.L	D0,D6
	MOVE.L	D0,D7
	
	MOVE.W	#0,Y
	move.l	ptr_load_tab_zoom,A5
	move.l	ptr_fin_tab_zoom,a4
	
	MOVEM.L	D0-D7/A0-A6,PARAM
	RTS

	
ROTOZOOM
	MOVEM.L	PARAM,D0-D7/A0-A6
	MOVE.L	(A5)+,INCX	* .L -> INCX & INCY  
	CMP.L	A4,A5
	BNE.S	NOT_FIN_TABLE
	move.l	ptr_load_tab_zoom,A5
NOT_FIN_TABLE
	MOVE.L	MY_BUF,A1
	move.l	ptr_load_map_TC,a0
	add.l	#128*512,a0
	
	MOVE.W	INCX,D6
	MOVE.W	SCREENX,D1
	MULS.W	D6,D1
	
	MOVE.W	D1,POSX	* POSX= (SCREENX/2)*INCX
	
	MOVE.W	INCY,D7
	MOVE.W	SCREENY,D1
	MULS.W	D7,D1
	NEG.W	D1
	
	MOVE.W	D1,POSY	* POSY= -(SCREENY/2)*INCY

	ADD.W	D7,D7
	ADD.W	D6,D6
	
	MOVE.W	SCREENY,D5
	SUBQ	#1,D5
	MOVE.W	#0,A6
	

MAP_LOOP
	MOVE.W	SCREENX,D0
	SUBQ	#1,D0
	MOVE.L	INCX,D1	* D1=[INCX|INCY]
	MOVE.L	POSX,D2	* D2=[POSX|POSY]
	ADD.L	D1,D1
		
X_LOOP	
	ADD.L	D1,D2

	MOVE.L	D2,D3
	ROL.L	#8,D3
	MOVE.W	D2,D4
	MOVE.B	D3,D4

	MOVE.W	(A0,D4.W*2),(A1)+

	DBRA	D0,X_LOOP
	
	ADD.W	D7,POSX
	SUB.W	D6,POSY
	ADDQ.W	#1,A6
	DBRA	D5,MAP_LOOP

	MOVEM.L	D0-D7/A0-A6,PARAM
	RTS
	
	
ROTOZOOM_256
	MOVEM.L	PARAM,D0-D7/A0-A6
	MOVE.L	(A5)+,INCX	* .L -> INCX & INCY  
	CMP.L	A4,A5
	BNE.S	NOT_FIN_TABLE_256
	move.l	ptr_load_tab_zoom,A5
NOT_FIN_TABLE_256
	MOVE.L	MY_BUF,A1
	move.l	ptr_load_map_256,a0
	add.l	#128*256,a0
	
	MOVE.W	INCX,D6
	MOVE.W	SCREENX,D1
	MULS.W	D6,D1
	
	MOVE.W	D1,POSX	* POSX= (SCREENX/2)*INCX
	
	MOVE.W	INCY,D7
	MOVE.W	SCREENY,D1
	MULS.W	D7,D1
	NEG.W	D1
	
	MOVE.W	D1,POSY	* POSY= -(SCREENY/2)*INCY

	ADD.W	D7,D7
	ADD.W	D6,D6
	
	MOVE.W	SCREENY,D5
	SUBQ	#1,D5
	MOVE.W	#0,A6
	

MAP_LOOP_256
	MOVE.W	SCREENX,D0
	SUBQ	#1,D0
	MOVE.L	INCX,D1	* D1=[INCX|INCY]
	MOVE.L	POSX,D2	* D2=[POSX|POSY]
	ADD.L	D1,D1
		
X_LOOP_256	
	ADD.L	D1,D2

	MOVE.L	D2,D3
	ROL.L	#8,D3
	MOVE.W	D2,D4
	MOVE.B	D3,D4

	MOVE.B	(A0,D4.W),(A1)+

	DBRA	D0,X_LOOP_256
	
	ADD.W	D7,POSX
	SUB.W	D6,POSY
	ADDQ.W	#1,A6
	DBRA	D5,MAP_LOOP_256

	MOVEM.L	D0-D7/A0-A6,PARAM
	BSR.S	DEBUT8P
	RTS
	
DEBUT8P:	moveq	#0,d2
	move.l	MY_BUF,a0
	MOVE.L	BUF_256,a1
	lea	pal8explose,a2
	moveq	#0,d5
	move.l	#$7FFF9,d2	; magique ! 7.w|-7.w
	
	move.w	SCREENY,d1
	subq.w	#1,d1
.ligne
	move.w	SCREENX,d0
	lsr.w	#3,d0
	subq.w	#1,d0
.groupe8
	move.l	(a0)+,d3		; 4 premiers pixels
	moveq.l	#0,d6
	moveq.l	#0,d7
	move.w	#4-1,d4		
.b1	
	rol.l	#8,d3
	move.b	d3,d5
	lea	(a2,d5*8),a3
	lsl.l	#1,d7
	or.l	(a3)+,d7		; word haut
	lsl.l	#1,d6
	or.l	(a3),d6		; word bas
	dbra	d4,.b1

	move.l	(a0)+,d3		; 4 pixels suivants
	move.w	#4-1,d4		
.b2	
	rol.l	#8,d3
	move.b	d3,d5
	lea	(a2,d5*8),a3
	lsl.l	#1,d7
	or.l	(a3)+,d7
	lsl.l	#1,d6
	or.l	(a3),d6
	dbra	d4,.b2
	
	movep.l	d7,(a1)
	addq.w	#8,a1
	movep.l	d6,(a1)
	adda.w	d2,a1
	swap	d2
	
	dbra	d0,.groupe8
	dbra	d1,.ligne
	
	rts

;------------------------------------------------------------------------------

 DATA
 even
pal8explose
n	set	0
	rept	256
	dc.b	(n>>0)&1
	dc.b	(n>>1)&1
	dc.b	(n>>2)&1
	dc.b	(n>>3)&1
	dc.b	(n>>4)&1
	dc.b	(n>>5)&1
	dc.b	(n>>6)&1
	dc.b	(n>>7)&1
n	set	n+1
	endr

;------------------------------------------------------------------------------
 BSS
 even

MY_BUF	DS.L	1	
BUF_256	DS.L	1
PARAM	DS.L	32
POSX	DS.W	1
POSY	DS.W	1
Y	DS.W	1
INCX	DS.W	1
INCY	DS.W	1
SCREENX	DS.W	1
SCREENY	DS.W	1

 TEXT
