;
; Cut out cubes from screen
;
; Data is 2048 long ( $800 )
;
go	
	lea	picture,a0
	lea	cube_out,a1
	moveq	#0,d0
	moveq	#16-1,d7
.loop	
	move.l	d0,(a1)+
	move.l	(a0),(a1)+
	move.l	d0,(a1)+
	move.l	1*$a0(a0),(a1)+
	move.l	d0,(a1)+
	move.l	2*$a0(a0),(a1)+
	move.l	d0,(a1)+
	move.l	3*$a0(a0),(a1)+
	move.l	d0,(a1)+
	move.l	4*$a0(a0),(a1)+
	move.l	d0,(a1)+
	move.l	5*$a0(a0),(a1)+
	move.l	d0,(a1)+
	move.l	6*$a0(a0),(a1)+
	move.l	d0,(a1)+
	move.l	7*$a0(a0),(a1)+
	move.l	d0,(a1)+
	move.l	8*$a0(a0),(a1)+
	move.l	d0,(a1)+
	move.l	9*$a0(a0),(a1)+
	move.l	d0,(a1)+
	move.l	10*$a0(a0),(a1)+
	move.l	d0,(a1)+
	move.l	11*$a0(a0),(a1)+
	move.l	d0,(a1)+
	move.l	12*$a0(a0),(a1)+
	move.l	d0,(a1)+
	move.l	13*$a0(a0),(a1)+
	move.l	d0,(a1)+
	move.l	14*$a0(a0),(a1)+
	move.l	d0,(a1)+
	move.l	15*$a0(a0),(a1)+
	lea	8(a0),a0
	dbf	d7,.loop

	clr	-(a7)
	trap	#1
	

pic	incbin	cubespin.pi1	
picture	equ	pic+34

cube_out	ds.w	2048
	
	
	
	