*********************************************
* This program activates the interrupts and *
* returns to desktop with REPLAY running.   *
*********************************************
*
*  This daft little programme plays data through the REPLAY cartridge
*  while you work. It has no real use, it is simply a demo programme
*  which slows GEM down so much that you can watch it in action!
*  REPLAY must be connected to an amplifier to hear anything !!
*  The sound quality is poor for 2 reasons. Firstly the frequency is
*  only 10KHz. Secondly, all of the system interrupts are in use at
*  the same time, note the effect of the mouse on the quality !
*  The only way to remove this programme once running, is by resetting
*  the computer. You might like to try it at 20 KHz (data $01 & $1F ).
*
*	SET MFP EQUATES

MFP	EQU	$FFFA00
ISRA	EQU	MFP+$0F

*	SET BDOS EQUATES

XBTIMER	EQU	31

*	SET UP INTERRUPT ROUTINE EQUATES

INPUT	EQU	$FB0001
OUTPUT	EQU	$FA0000

*	SET UP TIMER A INTERRUPTS

START	PEA	ISR		INTERRUPT SERVICE ROUTINE
	MOVE.W	#$05,-(SP)	SET TO APPROX 10 KHz (20k = $01)
	MOVE.W	#$04,-(SP)	(20k = $1F)
	MOVE.W	#0,-(SP)
	MOVE.W	#XBTIMER,-(SP)	SET XBTIMER
	TRAP	#14
	ADDA.L	#12,SP
*
*	SAVE PROGRAM SPACE AND GO BACK TO DESKTOP
*
RETURN	MOVE.W	#$0,-(SP)	CLEAR ERROR
	MOVE.L	#$200,-(SP)	SAVE 512 BYTES
	MOVE.W	#$31,-(SP)
	TRAP	#1		GO HOME

*********************************************************

ISR 
	MOVE.W	#$2700,SR	DISABLE ALL OTHERS (?)
	MOVEM.L	D0-D1/A0-A1,-(SP) SAVE REGISTERS
	MOVE.L	#INPUT,A0	SET UP REPLAY PORT
	MOVE.L	#OUTPUT,A1
	CLR.W	D0 		CLEAR WORK SPACE
	MOVE.B	(A0),D0		READ PORT
	LSL.W	#1,D0		* 2
	MOVE.B	0(A1,D0.W),D1	WRITE DATA OUT
	MOVEM.L	(SP)+,A0-A1/D0-D1 RESTORE REGISTERS
	BCLR.B	#5,ISRA		ENABLE INTS. AGAIN

END	RTE			GO BACK
	
