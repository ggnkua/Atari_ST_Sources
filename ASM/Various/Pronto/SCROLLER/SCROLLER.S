		FORMAT	0-,1-,2-
		LIST
			
       	  ********************************************************
	  *	            FASTISH  SCROLLER ROUT 		 *
	  *						         *
	  *			   BY PRONTO		         *
	  *							 *
	  *		    FONT BY CHARON OF NATO		 *
	  *							 *
	  *		       FEBUARY 23rd 1992     		 *
	  ********************************************************
	
		NOLIST

***********************************************************************************

SET_UP:	
		MOVE.W		#4,-(SP)		;STORE REZ
		TRAP		#14
		ADDQ.L		#2,SP
		MOVE.W		D0,OLD_REZ	
		CMPI.W		#2,D0			;CHECK REZ
		BNE		C			;NOT HIGH, CARRY ON

		CLR.W		-(SP)			;NO,EXIT.
		TRAP		#1

C:		DC.W		$A00A			;MOUSE OFF
	
		MOVE.W		#3,-(SP)		;FIND DE SCREEN
		TRAP		#14
		ADDQ.L		#2,SP
		MOVE.L		D0,SCR_ADDR

		CLR.L		-(SP)			;SV MODE
		MOVE.W		#$20,-(SP)
		TRAP		#1
		ADDQ.L		#6,SP
		MOVE.L		D0,OLD_SP	
	
		MOVE.W		#5,-(SP)		;EXCEPTIONS OFF
		MOVE.W		#26,-(SP)
		TRAP		#14
		ADDQ.L		#4,SP
		
		PEA		MOUSE			;TURN OFF KEYBOARD,ETC
		MOVE.W		#1,-(SP)
		MOVE.W		#25,-(SP)
		TRAP		#14
		ADDQ.L		#8,SP
		
		CLR.W		-(SP)			;LOW_RES PLEASE
		MOVE.L		#-1,-(SP)
		MOVE.L		#-1,-(SP)
		MOVE.W		#5,-(SP)
		TRAP		#14
		LEA		12(SP),SP

		MOVEM.W		$FF8240,D0-D7		;STORE OLD PAL
		MOVEM.W		D0-D7,OLD_PAL		

FADE:		CMP.W		#$000,$FF8240		;FADE SCREEN
		BEQ		C_O

		MOVE.L		$462.W,D1		
C_VBL:		CMP.L		$462.W,D1		;WAIT VBL
		BEQ.S		C_VBL
	

		SUB.W		#$111,$FF8240		;FADE IT
		BRA		FADE			;NEXT FADE

C_O:		MOVEM.L		NEW_PAL,D0-D7		;INSTALL NEW PAL
		MOVEM.L 	D0-D7,$FF8240
		


		MOVE.W		#$2700,SR		;INSTALL NEW VBL
		MOVE.L		$70,OVBL
		MOVE.L		#VBL,$70
		MOVE.W		#$2300,SR

***********************************************************************************
		
		
CHECK_LOOP:	CMP.B		#0,(FLAG)		;SEE IF END VBL
		BEQ		CHECK_LOOP		;NO,CHECK_LOOP
		MOVE.B		#0,(FLAG)		;YES, CARRY ON
	
		CMP.B		#$39,$FFFC02		;SPACE PRESSED
		BNE		CHECK_LOOP		;NO THEN AGAIN
		
***********************************************************************************

EXIT:		MOVE.W		#$2700,SR		;RESTORE VBL
		MOVE.L		OVBL,$70
		MOVE.W		#$2300,SR

		MOVEM.L		OLD_PAL,D0-D7		;INSTALL OLD PAL
		MOVEM.L		D0-D7,$FF8240

		MOVE.W		#5,-(SP)		;EXCEPTIONS ON
		MOVE.W		#27,-(SP)
		TRAP		#14
		ADDQ.L		#4,SP
			
		PEA		MOUSE+2			;TURN ON KEYBOARD
		MOVE.W		#1,-(SP)		;YOU SEXY THING
		MOVE.W		#25,-(SP)
		TRAP		#14
		ADDQ.L		#8,SP
			
		MOVE.W		OLD_REZ,-(SP)		;OLD_RES PLEASE
		MOVE.L		#-1,-(SP)
		MOVE.L		#-1,-(SP)
		MOVE.W		#5,-(SP)
		TRAP		#14
		LEA		12(SP),SP
		
		MOVE.L		OLD_SP,-(SP)		;RESTORE OLD STACK	
		MOVE.W		#$20,-(SP)		;USER MODE
		TRAP		#1
		ADDQ.L		#6,SP	

		MOVE.W		#$4C,-(SP)		;EXIT
		TRAP		#1
		
***********************************************************************************
		
VBL:		MOVE.W		#$700,$FFF8240		;TIMER TO RED	
							;RED IS SPEED
		
		JSR		SCROLLER		;DO SCROLLER

		MOVE.W		#$000,$FFF8240		;TIMER TO BLACK

		MOVE.B		#1,(FLAG)		;SET VBL FLAG

		RTE					;RETURN

***********************************************************************************

SCROLLER:	CMPI.B		#1,(FLAG2)		;SEE WHICH FLAG
		BNE		SCROLL			;FLAG SET,SCROLL
		MOVE.L		#0,(FLAG2)		;UN-SET

GET_AGAIN:	MOVE.L		(TPOS),A2		;GET DE CHARACTER
		MOVEQ.L		#0,D0
		MOVE.B		(A2),D0

 		CMPI.B		#0,(A2)			;SEE IF WRAP
		BNE		N_CH
		MOVE.L		#TEXT,(TPOS)		;YES, WRAP
		BRA		GET_AGAIN		;START AGAIN

N_CH:		CMPI.B		#65,D0			;SEE IF LETTER
		BGE		LETTERS			;YES, THEN LETTERS

* BELOW IS A SLOW WAY OF FINDING THE OD CHARACTERS COORDS
* BUT I CANT BE BOTHERED TO CHANGE IT.  I'LL PROBABLY DO IT IN THE FUTURE		

SPACE:		CMPI.B		#32,D0			;SEE IF SPACE
		BNE		_1
		MOVE.W		#0,D0			;SET OFFSETS
		MOVE.W		#10240,D1		;FOR X,Y
		BRA		ADD_POS	

_1:		CMPI.B		#49,D0			;SEE IF 1
		BNE		_2
		MOVE.W		#128,D0			;SET OFFSETS
		MOVE.W		#2880,D1		;FOR X,Y
		BRA		ADD_POS	

_2:		CMPI.B		#50,D0			;SEE IF 2
		BNE		_3
		MOVE.W		#136,D0			;SET OFFSETS 
		MOVE.W		#2880,D1		;FOR X,Y
		BRA		ADD_POS	

_3:		CMPI.B		#51,D0			;ETC
		BNE		_4
		MOVE.W		#144,D0
		MOVE.W		#2880,D1
		BRA		ADD_POS	

_4:		CMPI.B		#52,D0
		BNE		_5
		MOVE.W		#152,D0
		MOVE.W		#2880,D1
		BRA		ADD_POS	

_5:		CMPI.B		#53,D0
		BNE		_6
		MOVE.W		#0,D0
		MOVE.W		#5760,D1
		BRA		ADD_POS	

_6:		CMPI.B		#54,D0
		BNE		_7
		MOVE.W		#8,D0
		MOVE.W		#5760,D1
		BRA		ADD_POS	

_7:		CMPI.B		#55,D0
		BNE		_8
		MOVE.W		#16,D0
		MOVE.W		#5760,D1
		BRA		ADD_POS	

_8:		CMPI.B		#56,D0
		BNE		_9
		MOVE.W		#24,D0
		MOVE.W		#5760,D1
		BRA		ADD_POS	

_9:		CMPI.B		#57,D0
		BNE		_0
		MOVE.W		#32,D0
		MOVE.W		#5760,D1
		BRA		ADD_POS	

_0:		CMPI.B		#48,D0
		BNE		_EXPLA
		MOVE.W		#40,D0
		MOVE.W		#5760,D1
		BRA		ADD_POS	

_EXPLA:		CMPI.B		#33,D0			;! MARK
		BNE		_COLON
		MOVE.W		#96,D0
		MOVE.W		#2880,D1
		BRA		ADD_POS	

_COLON:		CMPI.B		#58,D0			; COLON
		BNE		_MINUS
		MOVE.W		#64,D0
		MOVE.W		#2880,D1
		BRA		ADD_POS	

_MINUS:		CMPI.B		#45,D0			; -
		BNE		_O_BRACK
		MOVE.W		#72,D0
		MOVE.W		#2880,D1
		BRA		ADD_POS	

_O_BRACK:	CMPI.B		#40,D0			; (
		BNE		_C_BRACK
		MOVE.W		#80,D0
		MOVE.W		#2880,D1
		BRA		ADD_POS	

_C_BRACK:	CMPI.B		#41,D0			; )
		BNE		_QUEST	
		MOVE.W		#88,D0
		MOVE.W		#2880,D1
		BRA		ADD_POS	

_QUEST:		CMPI.B		#63,D0			; ?
		BNE		_SLASH
		MOVE.W		#104,D0
		MOVE.W		#2880,D1
		BRA		ADD_POS	

_SLASH:		CMPI.B		#47,D0			; /
		BNE		_COMMA
		MOVE.W		#112,D0
		MOVE.W		#2880,D1
		BRA		ADD_POS	

_COMMA:		CMPI.B		#46,D0			; .
		BNE		_STOP
		MOVE.W		#48,D0
		MOVE.W		#2880,D1
		BRA		ADD_POS	

_STOP:		CMPI.B		#44,D0			; ,
		BNE		LETTERS
		MOVE.W		#56,D0
		MOVE.W		#2880,D1
		BRA		ADD_POS	

LETTERS:	SUB.B		#65,D0			;MINUS 65 
		ADD.B		D0,D0			;AND DOUBLE
							;TO WORK WHERE 
							;ON COORD LIST
		MOVE.L		(C_ORDS),A1		;GET COORD
		ADD.L		D0,A1
		MOVEQ.L		#0,D0
		MOVEQ.L		#0,D1
		MOVE.B		(A1)+,d0		;GET X COORD
		MOVE.B		(A1),d1			;GET Y COORD

		MULU		#16,D1			;MULTI BY 160
		MULU		#10,D1
			
ADD_POS:	LEA		FNT+34,A0		;LOAD IN FONT SCR.
		ADD.W		D0,A0			;ADD X COORD
		ADD.W		D1,A0			;ADD Y COORD
		
		LEA		SCR_PAD,A1		;COPY LETTER
		LEA		160(A1),A1		;TO SCRATCH
		MOVE.L		#17,D6			;PAD
		JSR		COPY

		ADDQ.L		#1,(TPOS)		;GOTO TO NEXT 
							;LETTER FOR NEXT 
							;TIME
									
SCROLL:		MOVE.L		#17,D7			;AND SCROLL
		LEA		SCR_PAD,A0
SCROLL_LOOP:  
*		REPT		4			;TO SPEED IT UP 
							;COMMENT. 2,4,8
							;WORK.
		ROXL		160(A0)			;LOADSA ROXLs
		ROXL		152(A0)			;TO SCROLL THE
		ROXL		144(A0)			;SCREEN LEFT
		ROXL		136(A0)			;LINE BY LINE
		ROXL		128(A0)
		ROXL		120(A0)
		ROXL		112(A0)
		ROXL		104(A0)
		ROXL		96(A0)
		ROXL		88(A0)
		ROXL		80(A0)
		ROXL		72(A0)
		ROXL		64(A0)
		ROXL		56(A0)
		ROXL		48(A0)
		ROXL		40(A0)
		ROXL		32(A0)
		ROXL		24(A0)
		ROXL		16(A0)
		ROXL		8(A0)
		ROXL		(A0)
*		ENDR					;ALSO REMOVE 
							;COMMENT TO SPEED
							;UP.

		LEA		168(A0),A0		;GOTO NEXT LINE
		DBF		D7,SCROLL_LOOP		;SCROLL AGAIN

		MOVE.L		SCR_ADDR,A1		;COPY TO 
		LEA		28000(A1),A1		;OFFSET
		LEA 		SCR_PAD,A0		;COPY FROM
		MOVE.L		#17,D6			;TIMES
		JSR		COPY_2			;COPY TO SCREEN

		ADDQ.B		#1,WAIT			;ADD TO TIMES LOOP

*16 IS REPT TIMES(1) DEVIDED BY 16.

		CMPI.B		#16,WAIT			;SEE IF TIME FOR 
		BNE		CARRY			;NEXT LETTER
		MOVE.B		#1,(FLAG2)		;YES SET FLAG						
		MOVE.L		#0,WAIT			;RESET WAIT

CARRY:		RTS					;RETURN

		
*******************************************************************************

COPY:		MOVE.L		(A0),(A1)		;COPY TYPE 1
		LEA		160(A0),A0		;FOR LETTER
		LEA		168(A1),A1		;TO S_P
		DBF		D6,COPY
		RTS		

COPY_2:		REPT		4 			;COPY TYPE 2
		MOVE.L		(A0)+,(A1)+
		MOVE.L		(A0)+,(A1)+		;FOR S_P TP SCR
		MOVE.L		(A0)+,(A1)+
		MOVE.L		(A0)+,(A1)+
		MOVE.L		(A0)+,(A1)+
		MOVE.L		(A0)+,(A1)+
		MOVE.L		(A0)+,(A1)+
		MOVE.L		(A0)+,(A1)+
		MOVE.L		(A0)+,(A1)+
		MOVE.L		(A0)+,(A1)+
		ENDR		
		LEA		8(A0),A0		;GOTO NEXT LINE
		DBF		D6,COPY_2		;BRANCH UNTIL -1
		RTS					;RETURN
		
		
***********************************************************************************

FLAG:		DC.B		0			;VBL FLAG
MOUSE:		DC.B		$12,$1A,$14,8		;MOUSE STUFF

* MESSAGE LIST BELOW
TEXT:		DC.B		'HELLO, AND WELCOME TO THIS COOL SCROLLER !!            IT'
		DC.B		' IS BY PRONTO, AND WAS COMPLETED ON THE 23/2/1992.  IT TOOK ROUGHLY 8-9 HOURS TO FINISH....                   I HOPE YOU LIKE IT, AND FIND IT '
		DC.B		'EASY TO UNDERSTAND, CAUSE ITS TOUGH LOOK IF YOU DONT !!                    OVER AND OUT, AND LETS...............WRAP !!                                                ',0

* CO-ORDINATES LIST FOR POSITION OF FONTS
COORDS:		DC.B		0,0,8,0,16,0,24,0,32,0,40,0,48,0,56,0,64,0,72,0,80,0,88,0,96,0,104,0,112,0,120,0,128,0,136,0,144,0,152,0      
		DC.B		0,18,8,18,16,18,24,18,32,18,40,18

* YOUR PALETTE
NEW_PAL:	DC.W		$000,$777,$000,$000,$000,$000,$000,$000
		DC.W		$000,$000,$000,$000,$000,$000,$000,$000		

OVBL		DC.L		0			;OLD VBL
TPOS:		DC.L		TEXT			;POS. IN TEXT
C_ORDS:		DC.L		COORDS			;POS IN COORDS
FLAG2:		DC.L		0			;SCROLLER FLAG
WAIT:	 	DC.L		0			;WAIT TIMER

FNT:		INCBIN		NATO1.PI1		;FONTS

		SECTION	BSS
SCR_PAD:	DS.B		168*18			;SCROLLER STORE
OLD_PAL:	DS.W		16			;OLD PALETTE
OLD_REZ:	DS.W		1			;OLD RESOLUTION
OLD_SP:		DS.L		1			;OLD STACK
SCR_ADDR:	DS.L		1			;SCREEN ADDRESS
		END					;END OF CODE

***********************************************************************************
