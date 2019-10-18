		OPT	D+,C+

		BSR	START
* A5 now points to the screen base.
* Your code goes here:







* (End of your code.)
* Terminate:
		LEA	Variables(PC),A5
wait		BSR.S	Get_Key
		BEQ.S	wait		no key
		CMP.B	#13,D0		return?
		BNE.S	wait		no
* Return to Desktop:
		MOVE.L	#$4C0000,-(A7)
		TRAP	#1			ciao
*
* Remove flashing cursor:
START		MOVE	#27,-(A7)
		MOVE.L	#$30002,-(A7)
		TRAP	#13
		MOVE	#"f",4(A7)
		MOVE.L	#$30002,(A7)
		TRAP	#13
		ADDQ.L	#6,A7
*
		LEA	Variables(PC),A5
* Read current physical screen base address:
		MOVE	#2,-(A7)
		TRAP	#14
		ADDQ.L	#2,A7
		MOVE.L	D0,(A5)
		MOVEA.L	D0,A5
		RTS
*
* Routine to read a key. Returns Z set if no key else key code in D0.
Get_Key		MOVE.L	#$10002,-(A7)
		TRAP	#13
		ADDQ.L	#4,A7
		TST	D0		key available?
		BEQ.S	key_done		no
		MOVE.L	#$20002,-(A7)
		TRAP	#13
		ADDQ.L	#4,A7
		MOVEQ	#1,D1		clear Z
key_done		RTS
*
Variables	DS.L	1	ptr to physical screen
