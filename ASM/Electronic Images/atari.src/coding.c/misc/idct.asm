		org	p:$40

fast_idct:	MOVE  #<0,R0
		MOVEC	#$1f,m0
		MOVE  #<4,N0
		MOVE  #>2,R1
		MOVE  #<4,N1
		MOVE  #>$20,R2
		MOVE  #IDCTXCoef3,R3
		MOVEC #<4,M3
		MOVE  #>1,R4
		MOVE  #<4,N4
		MOVE  #>3,R5
		MOVE  #<4,N5
		MOVE  #<4,N6
		MOVE  #IDCTXCoef7,R7
		MOVEC #<4,M7
		DO    #2,lp2
		DO    #4,lp1
 		MOVE  X:(R0),X0   Y:(R7)+,Y0
		MPY   Y0,X0,A     X:(R1),X1   Y:(R7)+,Y1
		MACR  Y1,X1,A
		MPY   X0,Y1,A     A,X:(R0)
		MACR  -X1,Y0,A    X:(R4),X0   Y:(R3)+,Y0
		MPY   Y0,X0,A     A,X:(R1)
		MOVE  X:(R5),X1   Y:(R3)+,Y1
		MACR  Y1,X1,A
		MPY   X0,Y1,A     A,X:(R4)
 		MACR  -X1,Y0,A    X:(R3)+,X0  Y:(R4),Y0
		MPY   Y0,X0,A     A,X:(R5)
		MOVE  X:(R7)+,X1  Y:(R1),Y1
		MACR  Y1,X1,A
		MPY   X1,Y0,A     X:(R0),B    A,Y:(R4)
		MACR  -X0,Y1,A    Y:(R0),Y0
		TFR   B,A   X:(R4),B    A,Y:(R1)
		ADD   A,B   Y:(R4),X0
		SUBL  B,A   B,X:(R0)    X0,B
		TFR   Y0,A  A,X:(R4)
		ADD   A,B   X:(R1),Y1
		SUBL  B,A   X:(R5),B    B,Y:(R0)
		TFR   Y1,A  A,Y:(R4)
		ADD   A,B   Y:(R5),X0
		SUBL  B,A   B,X:(R1)
		TFR   X0,A  A,X:(R5)    Y:(R1),B
		ADD   A,B   Y:(R0),Y0
		SUBL  B,A   B,Y:(R5)
		MOVE  X:(R7)+,X0  A,Y:(R1)
		MPY   Y0,X0,A     X:(R3)+,X1  Y:(R5),Y1
		MACR  Y1,X1,A
		MPY   X1,Y0,A     A,Y:(R0)
		MACR  -X0,Y1,A    X:(R3)+,X0  Y:(R4),Y0
		MPY   Y0,X0,A     A,Y:(R5)
		MOVE  X:(R7)+,X1  Y:(R1),Y1
		MACR  Y1,X1,A
		MPY   X1,Y0,A     A,Y:(R4)
		MACR  -X0,Y1,A    R2,R6
		MOVE  A,Y:(R1)
		MOVE  L:(R0)+N0,AB
		ADD   A,B
		SUBL  B,A   B,X:(R6)+N6
		MOVE  A,X0
		MOVE  L:(R1)+N1,AB
		ADD   A,B
		SUBL  B,A   B,X:(R6)+N6
 		MOVE  X:(R5),A    A,Y1
		MOVE  Y:(R4),B
		ADD   A,B
		SUBL  B,A   B,X:(R6)+N6
		MOVE  X:(R4)+N4,A A,Y0
		MOVE  Y:(R5)+N5,B
		ADD   A,B
		SUBL  B,A   B,X:(R6)+N6
		MOVE  A,X:(R6)+N6
		MOVE  Y0,X:(R6)+N6
		MOVE  Y1,X:(R6)+N6
		MOVE  X0,X:(R6)+N6
		MOVE  X:(R0),X0   Y:(R7)+,Y0
		MPY   Y0,X0,A     X:(R1),X1   Y:(R7)+,Y1
		MACR  Y1,X1,A
		MPY   X0,Y1,A     A,X:(R0)
		MACR  -X1,Y0,A    X:(R4),X0   Y:(R3)+,Y0
		MPY   Y0,X0,A     A,X:(R1)
 		MOVE  X:(R5),X1   Y:(R3)+,Y1
		MACR  Y1,X1,A
		MPY   X0,Y1,A     A,X:(R4)
		MACR  -X1,Y0,A    X:(R3)+,X0  Y:(R4),Y0
		MPY   Y0,X0,A     A,X:(R5)
		MOVE  X:(R7)+,X1  Y:(R1),Y1
		MACR  Y1,X1,A
		MPY   X1,Y0,A     X:(R0),B    A,Y:(R4)
		MACR  -X0,Y1,A    Y:(R0),Y0
		TFR   B,A   X:(R4),B    A,Y:(R1)
		ADD   A,B   Y:(R4),X0
		SUBL  B,A   B,X:(R0)    X0,B
		TFR   Y0,A  A,X:(R4)
		ADD   A,B   X:(R1),Y1
		SUBL  B,A   X:(R5),B    B,Y:(R0)
		TFR   Y1,A  A,Y:(R4)
		ADD   A,B   Y:(R5),X0
		SUBL  B,A   B,X:(R1)
		TFR   X0,A  A,X:(R5)    Y:(R1),B
		ADD   A,B   Y:(R0),Y0
		SUBL  B,A   B,Y:(R5)
		MOVE  X:(R7)+,X0  A,Y:(R1)
		MPY   Y0,X0,A     X:(R3)+,X1  Y:(R5),Y1
		MACR  Y1,X1,A
		MPY   X1,Y0,A     A,Y:(R0)
		MACR  -X0,Y1,A    X:(R3)+,X0  Y:(R4),Y0
		MPY   Y0,X0,A     A,Y:(R5)
		MOVE  X:(R7)+,X1  Y:(R1),Y1
		MACR  Y1,X1,A
		MPY   X1,Y0,A     A,Y:(R4)
		MACR  -X0,Y1,A    R2,R6
		MOVE  A,Y:(R1)
		MOVE  L:(R0)+N0,AB
		ADD   A,B
		SUBL  B,A   B,Y:(R6)+N6
		MOVE  A,X0
		MOVE  L:(R1)+N1,AB
		ADD   A,B
 		SUBL  B,A   B,Y:(R6)+N6
		MOVE  X:(R5),A    A,Y1
		MOVE  Y:(R4),B
		ADD   A,B
		SUBL  B,A   B,Y:(R6)+N6
		MOVE  X:(R4)+N4,A A,Y0
 		MOVE  Y:(R5)+N5,B
		ADD   A,B   (R2)+
		SUBL  B,A   B,Y:(R6)+N6
		MOVE  A,Y:(R6)+N6
		MOVE  Y0,Y:(R6)+N6
		MOVE  Y1,Y:(R6)+N6
		MOVE  X0,Y:(R6)+N6
lp1
		MOVE  #>$20,R0
		MOVE  #>$21,R4
		MOVE  #>$22,R1
		MOVE  #>$23,R5
		MOVE  #>0,R2
lp2
		RTS

	org	x:$00C0

IDCTXCoef3	dc	$000000
		dc	$000000
		dc	$5A827A
		dc	$0C7C5C
		dc	$238E76

		org	x:$00C8

IDCTXCoef7	dc	$000000
		dc	$000000
		dc	$5A827A
		dc	$3EC530
		dc	$3536CC
	
		org	y:$00C0

IDCTYCoef3	dc	$3B20D8
		dc	$187DE3
		dc	$000000
		dc	$000000
		dc	$000000

		org	y:$00C8

IDCTYCoef7	dc	$2D413D
		dc	$2D413D
		dc	$000000
		dc	$000000
		dc	$000000

		end
