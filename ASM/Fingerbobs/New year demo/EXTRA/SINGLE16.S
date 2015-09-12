*
* Create 16x16 Single plane character set
* from .pi1 file
*
* By Oberje' for Fingerbobs New Year Demo '89/90
*
* 
* Binary Save  fname, CHAR_SET,CHAR_SET+$780
*

start	lea	char_set,a1
	lea	picture,a0
	
	move.w	#4-1,d7		;4 rows
nxt_row
	move.w	#20-1,d6	;20 Chars on each
nxt_char	
	move.w	0*$a0(a0),(a1)+
	move.w	1*$a0(a0),(a1)+
	move.w	2*$a0(a0),(a1)+
	move.w	3*$a0(a0),(a1)+
	move.w	4*$a0(a0),(a1)+
	move.w	5*$a0(a0),(a1)+
	move.w	6*$a0(a0),(a1)+
	move.w	7*$a0(a0),(a1)+
	move.w	8*$a0(a0),(a1)+
	move.w	9*$a0(a0),(a1)+
	move.w	10*$a0(a0),(a1)+
	move.w	11*$a0(a0),(a1)+
	move.w	12*$a0(a0),(a1)+
	move.w	13*$a0(a0),(a1)+
	move.w	14*$a0(a0),(a1)+
	move.w	15*$a0(a0),(a1)+

	addq.l	#8,a0	;Next char on line	
	dbf	d6,nxt_char
	
	adda.l	#15*$a0,a0
	dbf	d7,nxt_row
		
	
	move.w	#80,d1
	move.w	#0,d5	
		
test	lea	char_set,a0
	lea	$78000,a1
	move.l	d5,d0
	addq.l	#1,d5		
	asl.l	#5,d0
	add.l	d0,a0
	move.w	#16-1,d2
disp	move.w	(a0)+,(a1)
	add.l	#$a0,a1
	dbra	d2,disp
	move.w	#8,-(a7)
	trap	#1
	addq.l	#2,a7
	dbra	d1,test
	clr	-(a7)
	trap	#1
				
		even
		
		
pic		incbin	"\16x16.pi1"

picture		equ	pic+34

piccols		equ	pic+2

		even

char_start	ds.w	16
		
char_set	ds.b	32128


