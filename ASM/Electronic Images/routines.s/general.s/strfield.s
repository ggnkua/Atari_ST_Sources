* Starfield with 9 planes (C) APRIL 1989 Martin Griffiths. 
* 570 stars maximum!

		clr -(sp)
		pea -1.w
		pea -1.w
		move #5,-(sp)
		trap #14
		lea 12(sp),sp

		LEA mystack,SP		setup local stack
		BSR.S Main			jump to prog
all_done	MOVE #$000,-(SP)	
		MOVE #1,-(SP)	
		MOVE #7,-(SP)				
		TRAP #14
		ADDQ.L #6,SP
		MOVE #$777,-(SP)	
		MOVE #0,-(SP)
		MOVE #7,-(SP)
		TRAP #14
		ADDQ.L #6,SP
		CLR -(SP)			return
		TRAP #1			to whatever

Main		DC.W $A00A
		MOVE #2,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		MOVE.L D0,logbase
		SUB.L #32000,D0
		MOVE.L D0,phybase
		BSR sw_clr
colors  	MOVE #$777,-(SP)	
		MOVE #1,-(SP)	
		MOVE #7,-(SP)				
		TRAP #14
		ADDQ.L #6,SP
		MOVE #$000,-(SP)	
		MOVE #0,-(SP)
		MOVE #7,-(SP)
		TRAP #14
		ADDQ.L #6,SP
	
		LEA stars(PC),A3
		MOVE #nostars,D4
rloop		MOVE #320,D1
		BSR.S Random
		MOVE D0,(A3)+
ystar		MOVE #200,D1
		BSR.S Random
		MULU #160,D0
		MOVE D0,(A3)+
step		MOVEQ #5,D1
		BSR.S Random
		ADDQ #1,D0
		MOVE D0,(A3)+
		DBRA D4,rloop

frame		MOVE.L logbase(PC),A0	screenbase
		LEA stars(PC),A1		star co-ords
		MOVE #nostars,D5		no of stars
framec	MOVE.W (A1)+,D0		x co-ord
		MOVE.W (A1)+,D1		y co-ord 
		ADD (A1)+,D0		step
		CMP #319,D0			off screen?	
		BLE.S not_off		yes then wrap!
wrap		MOVEQ #0,D0			x=0
		ADD -2(A1),D0		plus step
not_off	MOVE D0,-6(A1)		move new x back
quplot	MOVE D0,D3			
		LSR #1,D0
		AND #$FFF8,D0
		ADD D1,D0			
		AND #15,D3			plot a point
		MOVE #$8000,D2		in first bitplane
		LSR.W D3,D2			e.g white 'star'
		OR D2,0(A0,D0.W)
		DBRA D5,framec		do all stars
		BSR.S sw_clr		clear frame and swap screens etc
Get_Key	MOVE.L #$10002,-(SP)
		TRAP #13
		ADDQ.L #4,SP
		TST D0		      key pressed
		BEQ.S	frame		      no
		RTS				yep

* Generate a psuedo random number
* between 0 and D1.W in D0.W
* D0/A0 smashed.

Random	LEA seed(PC),A0
		MOVEQ #0,D0
		MOVE (A0),D0		get the seed
		ROL #1,D0			with the number!
		EOR #54321,D0
		SUBQ #1,D0		
		MOVE D0,(A0)		new seed!
		DIVU D1,D0			d0=d0 mod d1					
		SWAP D0			remainder in d0
		RTS

sw_clr  	MOVE.L logbase(PC),D0
		MOVE.L phybase(PC),D1	
		MOVE.L D1,logbase		swap screens
		MOVE.L D0,phybase
		MOVE #-1,-(SP)
		MOVE.L D0,-(SP)
		MOVE.L D1,-(SP)
		MOVE #5,-(SP)		now set the
		TRAP #14			new screens
		LEA 12(SP),SP
		MOVE #37,-(SP)		
		TRAP #14			wait VBL
		ADDQ.L #2,SP
clearscreen	MOVE.L logbase(PC),A0
		LEA 32000(A0),A0
		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVEQ #0,D2
		MOVEQ #0,D3
		MOVEQ #0,D4
		MOVEQ #0,D5
		MOVEQ #0,D6
		MOVEA.L D1,A1
		MOVEA.L D1,A2
		MOVEA.L D1,A3
		MOVEA.L D1,A4
		MOVEA.L D1,A5
		MOVEA.L D1,A6
		MOVEQ #99,D7	
cl_loop	MOVEM.L D0-D6/A1-A6,-(A0)	52
		MOVEM.L D0-D6/A1-A6,-(A0)	52
		MOVEM.L D0-D6/A1-A6,-(A0)	52
		MOVEM.L D0-D6/A1-A6,-(A0)	52
		MOVEM.L D0-D6/A1-A6,-(A0)	52
		MOVEM.L D0-D6/A1-A6,-(A0)	52
		MOVE.L D0,-(A0)			4
		MOVE.L D0,-(A0)			4
		DBRA D7,cl_loop
		RTS

seed		DC.W $1234	
logbase 	DS.L 1
phybase 	DS.L 1
nostars	EQU 550
stars 	DS.W (nostars+1)*3
		DS.L 99
mystack	DS.L 1
