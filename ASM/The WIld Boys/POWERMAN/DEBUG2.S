*******************************************************************
*                                                                 *
* Published in the Ledgers Disk Magazine Volume 8                 *
*                                           Release Date : 1/2/92 *
*                                                                 *
*******************************************************************

* This source relaces some of the bomb error vectors with a rout which
* dumps all the register contents to the screen.  Only once this rout
* hasn't returned correctly to Devpac, but the error handling isn't
* as good as it could be.  The routine END should be where you replace
* all the system variables etc which you have changed.
* Call INSTALL to set up the new bomb error vectors.

D_FLAG		DC.W 0
INSTALL		MOVE.L #BUS,8
		MOVE.L #ADDRESS,12
		MOVE.L #ILLEGAL,16
		CLR.W D_FLAG
		RTS
MESSAGE1	DC.B "BUS ERROR",0
		EVEN
MESSAGE2	DC.B "ADDRESS ERROR",0
		EVEN
MESSAGE3	DC.B "ILLEGAL INSTRUCTION ERROR",0
		EVEN
MESSAGE		DS.L 1
BUS		MOVE.L #MESSAGE1,MESSAGE
		MOVE.W #1,D_FLAG
		JSR DEBUG
		JMP END
ADDRESS		MOVE.L #MESSAGE2,MESSAGE
		MOVE.W #1,D_FLAG
		JSR DEBUG
		JMP END
ILLEGAL		MOVE.L #MESSAGE3,MESSAGE
		MOVE.W #1,D_FLAG
		JSR DEBUG
		JMP END

WAITV		CMPI.B #129,$FFFF8207.W
		BLT WAITV
		RTS

REGS		DS.L 15
DEBUG		MOVE.W #$2700,SR
		CLR.B $FFFF8260.W
		BSR WAITV		
		MOVEM.L D0-A6,REGS
		MOVE.L $FFFF8200.W,D0
		LSL.W #8,D0
		MOVE.L D0,A0
		MOVE.W #0,$FFFF8240.W
		MOVE.W #$777,$FFFF8242.W
		MOVE.L A0,A1
		MOVE.W #32000/4-1,D0
.L1		MOVE.L #0,(A1)+		
		DBF D0,.L1
		MOVE.L A0,A1
		TST.W D_FLAG
		BEQ .LW
		MOVE.L MESSAGE,A0
		MOVEQ.W #1,D2
		MOVEQ.W #0,D3
		MOVEQ.W #0,D4
		MOVEQ.W #0,D5
		MOVEQ.W #0,D0
		MOVEQ.W #20,D1
		JSR TEXT	
		CLR.W D_FLAG
.LW		LEA DATA,A6
		MOVEQ.W #1,D2
		MOVEQ.W #0,D3
		MOVEQ.W #0,D4
		MOVEQ.W #0,D5
		MOVEQ.W #15-1,D7
		LEA REGS,A5
.L2		MOVE.W 2(A6),D0	
		MOVE.W 6(A6),D1
		MOVE.L 8(A6),A0
		JSR TEXT
		MOVEQ.W #4,D0
		MOVE.L (A5)+,D6
		LEA REG+8,A0
		REPT 8
		BSR GET_REG
		ENDR		
		LEA REG,A0
		MOVEQ.W #1,D2
		MOVEQ.W #0,D3
		MOVEQ.W #0,D4
		MOVEQ.W #0,D5
		JSR TEXT			
		ADD.L #12,A6
		DBF D7,.L2
		RTS

REG		DS.B 8
		DC.B 0,0

GET_REG		MOVE.L D6,D5
		ANDI.L #%1111,D5
		LSR.L #4,D6
		CMPI.L #9,D5
		BGT .L1
		ADD.B #'1'-1,D5
		MOVE.B D5,-(A0)
		RTS
.L1		ADD.B #65-10,D5
		MOVE.B D5,-(A0)
		RTS									

DATA		DC.L 0,0,D0,0,1,D1,0,2,D2,0,3,D3,0,4,D4,0,5,D5,0,6,D6,0,7,D7
		DC.L 0,8,A0,0,9,A1,0,10,A2,0,11,A3,0,12,A4,0,13,A5,0,14,A6
D0		DC.B "D0:",0
D1		DC.B "D1:",0
D2		DC.B "D2:",0
D3		DC.B "D3:",0
D4		DC.B "D4:",0
D5		DC.B "D5:",0
D6		DC.B "D6:",0
D7		DC.B "D7:",0
A0		DC.B "A0:",0
A1		DC.B "A1:",0
A2		DC.B "A2:",0
A3		DC.B "A3:",0
A4		DC.B "A4:",0
A5		DC.B "A5:",0
A6		DC.B "A6:",0
 
TEXT		MOVEM.L D0-A6,-(A7)
		MOVEQ.L #0,D6
		MOVEQ.L #0,D7
		MOVE.W D1,D6
		MULU #8,D6
		MULU #160,D6
		MOVE.W D0,D7
		BTST #0,D0
		BEQ .L1
		MOVEQ.W #1,D1
		BRA .L2
.L1		MOVEQ.W #0,D1
.L2		SUB.W D1,D7
		LSR.W #1,D7
		LSL.W #3,D7
		ADD.W D6,D7
		LEA (A1,D7.W),A1
		ADDA.W D1,A1
		LEA FONT8X8,A2
		MOVEQ.W #0,D7
.LOOP		MOVEQ.W #0,D0
		MOVE.B (A0)+,D0
		BEQ .EXIT
		CMPI.B #32,D0
		BLT .L4
		CMPI.B #97,D0
		BGE .L6
		BRA .L5
.L4		MOVEQ.W #32,D0
		BRA .L5
.L6		SUB.W #32,D0
.L5		SUB.W #32,D0
		LSL.W #3,D0
		LEA (A2,D0.W),A3
		MOVEA.L A3,A6
		MOVEA.L A1,A4
		ADD.W D1,A4
		MOVE.W D2,D0
		MOVEQ.W #0,D7
		BSR DRAW_CHAR
		MOVE.W D3,D0
		MOVEQ.W #2,D7
		BSR DRAW_CHAR
		MOVE.W D4,D0
		MOVEQ.W #4,D7
		BSR DRAW_CHAR
		MOVE.W D5,D0
		MOVEQ.W #6,D7
		BSR DRAW_CHAR
		TST.W D1
		BEQ .L3
		ADDQ.W #8,A1
		MOVEQ.W #0,D1
		BRA .LOOP
.L3		ADDQ.W #1,D1
		BRA .LOOP
.EXIT		MOVEM.L (A7)+,D0-A6
		RTS		

DRAW_CHAR	TST.W D0
		BEQ EXIT_ROUT
		MOVEA.L A6,A3
		LEA (A4,D7.W),A5
OFFSET		SET 0
		REPT 8
		MOVE.B (A3)+,OFFSET(A5)
OFFSET		SET OFFSET+160			
		ENDR
EXIT_ROUT	RTS
			
FONT8X8		INCBIN 8X8.DAT
