****************************************
* Mono monitor normal/inverse selector *
*          By John Cunningham	       *
*       (c) Atari ST User, Oct/89      *
*  Press both SHIFT keys at same time  *
****************************************

	PEA vect(PC)
	MOVE #38,-(A7)			Set vector in supervisor mode
	TRAP #14
	ADDQ.L #6,A7			Tidy stack
	MOVE #0,-(A7)
	MOVE.L #$200,-(A7)		Save $200 bytes
	MOVE #$31,-(A7)			Terminate and stay resident
	TRAP #1
vect	LEA tr13(PC),A0
	MOVE.L $B4,(A0)			Save TRAP #13 vector
	LEA mycode(PC),A0
	MOVE.L A0,$B4			Redirect TRAP #13 vector
	RTS

mycode	MOVEM.L D0-D2/A0-A3,-(A7)	Save registers
	LEA flag(PC),A3
	BSET #2,(A3)			Set self disable bit
	BNE end				End if self disabled
	MOVE #-1,-(A7)
	MOVE #11,-(A7)			Kbshift
	TRAP #13
	ADDQ.L #4,A7
	ANDI.B #3,D0			Get Shift status
	CMP.B #3,D0
	BEQ pressed			Branch if both Shifts pressed
	BCLR #0,(A3)			Clear 'pressed' flag
fin	BCLR #2,(A3)			Clear self disable bit
end	MOVEM.L (A7)+,D0-D2/A0-A3	Restore registers
	MOVE.L tr13(PC),A1
	JMP (A1)			Jump to old TRAP #13 routine

pressed	BSET #0,(A3)			Set 'pressed' flag
	BNE fin				Branch if already set
change	MOVE #1,D0			Set D0 for normal video
	BCLR #1,(A3)			Clear 'inverse' flag
	BNE normal			Branch if already set
	BSET #1,(A3)			Set 'inverse' flag
	MOVE #0,D0			Set D0 for inverse video
normal	MOVE D0,-(A7)			Hi-res inverse set by bit 0...
	MOVE #0,-(A7)			...in colour 0
	MOVE #7,-(A7)			Set colour
	TRAP #14
	ADDQ.L #6,A7			Tidy stack
	BRA fin				End routine

tr13	DC.L 0
flag	DC.B 0

	EVEN
