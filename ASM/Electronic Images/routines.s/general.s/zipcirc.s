* Test the circle rout

Test		LEA plot_masks(PC),A0
		MOVEQ #19,D0
		MOVE #$8000,D1
		MOVEQ #0,D2
masklp	REPT 16
		MOVE D1,(A0)+
		MOVE D2,(A0)+
		ROR #1,D1
		ENDR
		ADDQ.L #8,D2
		DBF D0,masklp

		MOVE #3,-(SP)
		TRAP #14
		LEA log_base(PC),A0
		MOVE.L D0,(A0)
		MOVE #160,D0
		MOVEQ #100,D1
		MOVEQ #15,D2
		MOVEQ #100,D3
tst_lp	MOVEM.W D0-D3,-(SP)
		BSR.S Qcircle
		MOVEM.W (SP)+,D0-D3
		DBRA D3,tst_lp
		CLR -(SP)  			
		TRAP #1

**********************************
* 	 Quick Circle routine 	   *
*   Written By Griff June 1989   *
*   Using my integer method...   *
*   Octant method of drawing..   *
* D0 - xo co-ord D1 - xo co-ord. *
* D2 - Colour.   D3 - Radius.	   *
* D0-D7/A0-A4 smashed.		   *
**********************************

Qcircle	MOVE.L log_base(PC),A2
		LEA col0(PC),A0		point to
		LEA plot_masks(PC),A3
		LEA Plot(PC),A4
		LSL #3,D2			specific
		ADDA D2,A0 			colour routine
		LEA write(PC),A1
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+	
		MOVE D3,D4			X=R
		MOVEQ #0,D5			Y=0
circ_lp	MOVEA D3,A1			preserve radius
		MOVE D0,D6			preserve XO+YO
		MOVE D1,D7
		ADD D4,D0			xo+x			
		ADD D5,D1			yo+y
		JSR (A4)			
		ADD D5,D0			xo-y			
		ADD D4,D1			yo+x
		JSR (A4)
		SUB D5,D0			xo-y		
		ADD D4,D1			yo+x
		JSR (A4)	
		SUB D4,D0			xo-x			
		ADD D5,D1			yo+y
		JSR (A4)		
		SUB D4,D0			xo-x			
		SUB D5,D1			yo-y
		JSR (A4)
		SUB D5,D0			xo-y			
		SUB D4,D1			yo-x
		JSR (A4)
		ADD D5,D0			xo+y			
		SUB D4,D1			yo-x
		JSR (A4)
		ADD D4,D0			xo+x			
		SUB D5,D1 			yo-y
		JSR (A4)
		MOVE A1,D3			restore radius
		ADD D5,D3			Y=Y+R
		ADD D5,D3			Y=Y+R
		BMI.S neg_rad 		negative yet?
		SUB D4,D3			SUB X,R
		SUB D4,D3			SUB X,R
		SUBQ #1,D4			SUB X,1
neg_rad	ADDQ #1,D5			ADD Y,1
		CMP D4,D5			all circle done?
		BLE.S circ_lp		no,then loop
		RTS				yep,finished

Plot		MOVE.L A2,A0
		ADD D0,D0
		ADD D0,D0
		MOVE.L (A3,D0),D0
		ADD D1,D1
		ADD mul_160(PC,D1),D0
		ADDA D0,A0
		SWAP D0
		MOVE D0,D1
		NOT D0			plane mask
write		DS.W 4	
point_off	MOVE D6,D0			restore XO		
		MOVE D7,D1			and YO
		RTS
i		SET 0
mul_160	REPT 200
		DC.W i
i		SET i+160
		ENDR
plot_masks	DS.L 320

col0		AND D0,(A0)+
		AND D0,(A0)+
		AND D0,(A0)+
		AND D0,(A0)+
col1		OR D1,(A0)+
		AND D0,(A0)+
		AND D0,(A0)+
		AND D0,(A0)
col2		AND D0,(A0)+
		OR D1,(A0)+
		AND D0,(A0)+
		AND D0,(A0)
col3		OR D1,(A0)+
		OR D1,(A0)+
		AND D0,(A0)+
		AND D0,(A0)
col4		AND D0,(A0)+
		AND D0,(A0)+
		OR D1,(A0)+
		AND D0,(A0)
col5		OR D1,(A0)+
		AND D0,(A0)+
		OR D1,(A0)+
		AND D0,(A0)
col6		AND D0,(A0)+
		OR D1,(A0)+
		OR D1,(A0)+
		AND D0,(A0)
col7		OR D1,(A0)+
		OR D1,(A0)+
		OR D1,(A0)+
		AND D0,(A0)
col8		AND D0,(A0)+
		AND D0,(A0)+
		AND D0,(A0)+
		OR D1,(A0)
col9		OR D1,(A0)+
		AND D0,(A0)+
		AND D0,(A0)+
		OR D1,(A0)
col10		AND D0,(A0)+
		OR D1,(A0)+
		AND D0,(A0)+
		OR D1,(A0)
col11		OR D1,(A0)+
		OR D1,(A0)+
		AND D0,(A0)+
		OR D1,(A0)
col12		AND D0,(A0)+
		AND D0,(A0)+
		OR D1,(A0)+
		OR D1,(A0)
col13		OR D1,(A0)+
		AND D0,(A0)+
		OR D1,(A0)+
		OR D1,(A0)
col14		AND D0,(A0)+
		OR D1,(A0)+
		OR D1,(A0)+
		OR D1,(A0)
col15		OR D1,(A0)+
		OR D1,(A0)+
		OR D1,(A0)+
		OR D1,(A0)
log_base	DS.L 1