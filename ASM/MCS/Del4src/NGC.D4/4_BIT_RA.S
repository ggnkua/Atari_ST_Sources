	nop
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

m_4_bit1	nop
	nop
	nop
	nop
	nop		
	
	movem.l	a1-a3,-(sp)		;8 
	movem.l	(a0),d0-d6/a1-a4	;25
	movem.l	d0-d6/a1-a4,230(a0)	;25
	movem.l	d0-d6/a1-a3,460(a0)	;23
	
	nop
							 
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a6)	; 50 hz	
	
	movem.l	a4,500(a0)		;5
	movem.l	44(a0),d0-d1	;8
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	movem.l	52(a0),d2-d5	;12
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

m_4_bit2	nop
	nop
	nop
	nop
	nop		
	
	movem.l	68(a0),d6/a1-a4	;14
	movem.l	d0-d6/a1-a4,274(a0)	;25
	movem.l	d0-d6/a1-a4,504(a0)	;25
	movem.l	88(a0),d0-d6	;18
							 
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a6)	; 50 hz	
	
	movem.l	116(a0),a1-a4	;12
	nop
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	movem.l	d0-d3,318(a0)	;11
	nop
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

m_4_bit3	nop
	nop
	nop
	nop
	nop		
	
	movem.l	d4-d6/a1-a4,334(a0)	;17
	movem.l	d0-d6/a1-a4,548(a0)	;25
	movem.l	132(a0),d0-d6/a1-a4	;26
	movem.l	d0-d4,362(a0)	;13
	
	nop
							 
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a6)	; 50 hz	
	
	movem.l	d5-d6/a1-a3,382(a0)	;13
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	move.l	a4,402(a0)		;4
	move.l	d0,592(a0)
	move.l	d1,596(a0)		;8
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

m_4_bit4	nop
	nop
	nop
	nop
	nop		
	
	movem.l	d2-d6/a1-a4,600(a0)	;21
	movem.l	176(a0),d0-d6/a1-a4	;26
	movem.l	d0-d6/a1-a4,406(a0)	;25
	movem.l	d0-d2,636(a0)	;9
	
	nop
							 
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a6)	; 50 hz	
	
	movem.l	d3-d6/a1,648(a0)	;13
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	movem.l	a2-a4,668(a0)	;9
	nop
	nop
	nop
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

m_4_bit5	nop
	nop
	nop
	nop
	nop		
	
	movem.l	220(a0),d0-d1	;8
	movem.l	d0-d1,450(a0)	;7
	movem.l	d0-d1,680(a0)	;7
	movem.l	(sp)+,a1-a3		;9
	lea	460(a0),a0		;2  
	
	nop			;49
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
							 
	move.b	d7,(a6)	; 60 hz	
	move.w	a5,(a6)	; 50 hz	
	
	nop		; 13 nops
	nop		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	
	move.w	a5,(a5)	; haute resolution
	nop
	move.b	d7,(a5)	; basse resolution

	nop		; 5 nops
	nop		
	nop
	nop
	nop

