**************************************
* Ultra-Fast Prime Number Generator! *
*    68000 version  by James Smith   *
*       Atari ST User  May 1988	 *
**************************************

********** Print Character ***********
printc	MACRO
	MOVE \1,-(A7)
	MOVE #2,-(A7)
	TRAP #1		   C_CONOUT
	ADDQ.L #4,A7
	ENDM
	
* Execute routine in supervisor mode *
super	MACRO
	PEA \1(PC)
	MOVE #38,-(A7)
	TRAP #14		     SUPERX
	ADDQ.L #2,A7
	ENDM
	
********** Print a string ************
sprint	MACRO
	PEA \1(PC)     String address
	MOVE #9,-(A7)
	TRAP #1		    C_CONWS
	ADDQ.L #6,A7
	ENDM

********** Start of program **********
 LEA variables(PC),A6   A6-> variables
 sprint prompt1	        Print prompt
 JSR input		   D4=range
 MOVE.L D4,0(A6)		      Store
 SUBQ.L #1,D4
 LSR.L #1,D4	     D4=(D4-1) DIV 2
 MOVE.L D4,10(A6)		      Store
 sprint secs1
 super zclock		 Zero clock
 JSR getq	 D6=(SQR D4-1) DIV 2
 JSR primes
 super gtime	  Time in 100ths sec
 JSR ptime		 Print time
 sprint prompt2	        Print prompt
 JSR waitkey	   Wait for keypress
 JSR prprime	    Print out primes
 sprint prompt2
 JSR waitkey
 CLR -(A7)	   Return to desktop
 TRAP #1			 P_TERM_OLD

**************************************
* Print out prime mumbers
**************************************
prprime
 printc #27
 printc #'v'
 MOVE.L #1,D7
 LEA p(PC),A5		  A5->array
priloop
 TST.B 0(A5,D7)	  IF >0 GOTO prinext
 BNE prinext
 MOVE.L D7,D0
 ADD.L D7,D0
 ADDQ.L #1,D0
 JSR printn
 printc #32
 printc #32
prinext
 ADDQ.L #1,D7
 CMP.L 10(A6),D7
 BLE priloop
 RTS

**************************************
* Calculate primes
**************************************
primes
 MOVE.L #1,D7
 MOVE.L 10(A6),D3
 LEA p(PC),A5		  A5->array
prloop
 TST.B 0(A5,D7)	   IF >0 GOTO prnext
 BNE.S prnext
 MOVE.L D7,D5
 ADD D7,D5
 ADDQ #1,D5
 MOVE.L D7,D4
 MULU D5,D4
 ADD D7,D4
prloop1
 TAS 0(A5,D4)
 ADD D5,D4
 CMP D3,D4
 BLE.S prloop1
prnext
 ADDQ #1,D7
 CMP D7,D6
 BGE.S prloop
 RTS

**************************************
getq
 MOVE.L 0(A6),D7
 MOVE.L D7,D6
 LSR.S #2,D6		D6=D7 DIV 4
 BTST #12,D7	    very big number?
 BEQ.S notbig
 LSR.L #2,D6		D6=D6 DIV 4
notbig
 MOVE.L D6,D5		      D5=D6
gloop
 LSR.L #1,D5		D5=D5 DIV 2
 MOVE.L D6,D0
 MULU D6,D0		  D6*D6>D7?
 CMP.L D7,D0
 BEQ.S gdone
 BGT.S toobig
 ADD.L D5,D6		   D6=D6+D5
 BRA.S gun1
toobig
 SUB.L D5,D6		   D6=D6-D5
gun1
 CMPI.L #1,D5		 UNTIL D5=1
 BGT.S gloop
 MOVE.L D6,D0
 MULU D6,D0
 CMP.L D7,D0
 BGT.S tbig
gloop1
 ADDQ.L #1,D6
 MOVE.L D6,D0
 MULU D6,D0
 CMP.L D0,D7
 BGE.S gloop1
 SUBQ.L #1,D6
 BRA.S gdone
tbig
 SUBQ.L #1,D6
 MOVE.L D6,D0
 MULU D6,D0
 CMP.L D0,D7
 BLE.S tbig
gdone
 SUBQ.L #1,D6
 LSR.L #1,D6
 RTS		 D6=(SQR D7-1) DIV 2

**************************************
* Print time in D0.L
**************************************
ptime
 MOVE.L #100,D1
 DIVU D1,D0	      D0=secs/100ths
 MOVE.L D0,D5
 ANDI.L #$FFFF,D0
 JSR printn	       Print seconds
 printc #'.'	 Print decimal point
 CLR D5
 SWAP D5
 CMPI #9,D5	     Double figures?
 BGT pok
 printc #'0'	Print 1 leading zero
pok
 MOVE.L D5,D0
 JSR printn	       Prints 100ths
 sprint secs2
 RTS
 
**************************************
* Wait for a keypress
**************************************
waitkey
 MOVE #8,-(A7)
 TRAP #1			    C_NECIN
 ADDQ.L #2,A7
 RTS

**************************************
* Print decimal number in D0.L
**************************************
printn
 CLR 4(A6)
 MOVE.L #10000,D1
 JSR digit
 MOVE.L #1000,D1
 JSR digit
 MOVE.L #100,D1
 JSR digit
 MOVE.L #10,D1
 JSR digit
 BRA lastdi		 Last digit
digit
 DIVU D1,D0      D0=remainder/quotient
 BNE dinz
 TST 4(A6)	       Leading zero?
 BEQ diskip
dinz
 MOVE.L D0,D4
lastdi
 ADDI #'0',D0
 printc D0
 TAS 4(A6)	 Can print zeros now
 MOVE.L D4,D0	 Put remainder in D0
 CLR D0
diskip
 SWAP D0
 RTS

**************************************
* Supervisor mode clock routines
**************************************
gtime
 MOVE.L $4BA,D0	    200Hz tick count
 LSR.L #1,D0	      100ths seconds
 RTS

zclock
 CLR.L $4BA	    Zero 200Hz clock
 RTS

**************************************
* Input number
**************************************
input
 CLR.L D4		D4=result=0
inloop
 MOVE #1,-(A7)		  Get digit
 TRAP #1			    C_CONIN
 ADDQ.L #2,A7
 CMPI #'0',D0	    End if not digit
 BLT endin
 CMPI #'9',D0
 BGT endin
 MOVE.L #10,D1	    result=result*10
 MULU D1,D4
 SUBI #'0',D0
 ADD D0,D4	 Add digit to result
 BRA inloop
endin
 RTS

variables
 DC.L 0
 DC.W 0
 DC.L 0
 DC.L 0
prompt1
 DC.B 13,10
 DC.B 'Input largest number:',0
prompt2
 DC.B 13,10,10,'Press a key: ',0
secs1
 DC.B 13,10,10,'Time taken = ',0
secs2
 DC.B ' seconds',0
 EVEN
p
 DS.B 1024*50

**** END ****