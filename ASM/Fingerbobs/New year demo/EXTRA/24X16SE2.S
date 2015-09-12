*
*
* OBERJE'S 24X16 CHARACTER SET GENERATOR
*
* 11/07/89 - 1:37AM
*
* ( JESUS! THATS A BIT LATE! )
*
* TAKES DEGAS PIC AND PRODUCES CONTINUES SINGLE BIT PLANE
* CHARACTER SET, EACH CHARACTER ( 3*16 ) BYTES OF BIT IMAGE
*
*
* USE BINARY SAVE FROM MONST2 TO SAVE SET.
*
*

		section	text

		lea	char_data,a1
		lea	picture,a0
		
		move.w	#5-1,d2		4 Rows
		
ugga		move.w	#16-1,d1	16 lines per row

ooga		move.l	a0,a3
		move.l	a1,a2
		move.w	#6-1,d0		13 chars a line ( 12 in loop )

round		move.b	(a0),(a1)
		move.b	1(a0),1(a1)
		move.b	8(a0),2(a1)
		adda.l	#(3*16),a1
		move.b	9(a0),(a1)
		move.b	16(a0),1(a1)
		move.b	17(a0),2(a1)
		adda.l	#(3*16),a1
		adda.l	#24,a0
		dbra	d0,round
		
		move.b	(a0),(a1)
		move.b	1(a0),1(a1)
		move.b	8(a0),2(a1)
				
		move.l	a2,a1
		add.l	#3,a1
		
		move.l	a3,a0
		adda.l	#$a0,a0
		
		dbra	d1,ooga
		
		adda.l	#576,a1
		
		dbra	d2,ugga
		
		
		move.w	#0,-(a7)
		move.l	#-1,-(a7)
		move.l	#-1,-(a7)
		move.w	#5,-(a7)
		trap	#14
		add.l	#12,a7
		
		
		
		move.l	#(5*13)-1,d2
		move.l	#"A"-"A",d3

again		move.l	d3,d0
		mulu	#(3*16),d0

test		lea	char_data,a0
		adda.l	d0,a0
		lea	$78000+6,a1	WE WANT TO SHOW IN BLUE
		move.w	#15,d1
loope		move.b	(a0)+,(a1)
		move.b	(a0)+,1(a1)
		move.b	(a0)+,8(a1)
		adda.l	#$a0,a1
		dbra	d1,loope
		
		move.w	#8,-(a7)
		trap	#1
		addq.l	#2,a7
		
		
		addq.l	#1,d3
		dbra	d2,again
			
			
		move.w	#1,-(a7)
		move.l	#-1,-(a7)
		move.l	#-1,-(a7)
		move.w	#5,-(a7)
		trap	#14
		add.l	#12,a7
			
		clr.w	-(a7)
		trap	#1
		rts
		
		section	data
		
pic		incbin	"nyd_set1.pi1"

picture		equ	pic+34

piccols		equ	pic+2

		section	bss
		
char_data	ds.b	(4*13*16*3)

end_data	equ	*

