* Mandelbrot Generator V2
* Coded by Martin Griffiths 
* (C) MAY 1990.

ystart	EQU -$1200
xstart	EQU -$1B00
yinc		EQU $16*2
xinc		EQU $E*2

* Numbers in following format
* 16bit(one word) structure
*  15   14 13 12   11 10 9....0
* sign   integer	   fraction

		CLR.W -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVEM.L pal(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVE #2,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		MOVE.L D0,A1
cls		MOVE.L A1,A0
		MOVE #1999,D0
		MOVEQ #0,D1
clslp		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,clslp

		MOVE #$2700,SR
		MOVE.L A1,A0
		MOVE.L #$4000000,A4
		MOVE #200,d2
		MOVE #ystart,A3
y_lp		MOVE #xstart,A2
		MOVEQ #19,D1
xchunk_lp	MOVEQ #15,D4
xpixel_lp	MOVEQ #0,D5
		MOVEQ #0,D6
		MOVEQ #0,D0
		MOVE.L D5,A6
		MOVEQ #50,D3
iterate_lp	SUB.L D0,A6		; x2-y2
		MOVE.L A6,D7
		ASL.L #4,D7
		SWAP D7
		ADD.W A2,D7		; x=x2-y2+u	
		MULS D5,D6		; y*x
		ASL.L #5,D6		; *2
		SWAP D6
		ADD.W A3,D6		; y=(2*x*y)+v
		MOVE D7,D5		
		MULS D7,D7		; x*x
		MOVE.L D7,A6	; x2=x*x
		MOVE D6,D0
		MULS D0,D0		; y*y
		ADD.L D0,D7		; x2+y2
		CMP.L A4,D7		; >=4
		DBHI D3,iterate_lp
plot		LSR #1,D3
		ROXL (A0)+
		LSR #1,D3
		ROXL (A0)+
		LSR #1,D3
		ROXL (A0)+
		LSR #1,D3
		ROXL (A0)
		SUBQ.L #6,A0
		LEA xinc(A2),A2
		DBF D4,xpixel_lp
		ADDQ.L #8,A0
		DBF D1,xchunk_lp
		LEA yinc(A3),A3
		DBF D2,y_lp
		MOVE #$2300,SR
		MOVE #7,-(SP)
		TRAP #1
		ADDQ.L #2,SP
		CLR -(SP)
		TRAP #1

pal		DC.W $000,$110,$220,$330,$440,$550,$660,$770
		DC.W $771,$772,$773,$774,$776,$776,$777,$000
