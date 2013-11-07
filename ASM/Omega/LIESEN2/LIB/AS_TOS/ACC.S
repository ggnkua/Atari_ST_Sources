		LEA STACK,A7
		BRA.L ACCINIT
****************************************
**	ACC SELECTED,    YOUR PROGRAM GOES HERE
****************************************
ACC_SELECTED:	MOVE.W #52,CONTRL	; ALLERT BOX
		MOVE.W #1,CONTRL+2
		MOVE.W #1,CONTRL+4
		MOVE.W #1,CONTRL+6
		MOVE.W #0,CONTRL+8
		MOVE.W #0,INTIN
		MOVE.L #TEXT,ADDRIN
		BSR.L AES
		RTS
************************
TEXT:		DC.B "[3][THIS ALERT BOX WILL POP UP|"
		DC.B "WHEN YOU PRESS THE RIGHT|"
		DC.B "ACCESORY.| |"
		DC.B "THAT'S THE WAY IT IS !!]"
		DC.B "[SO VERY|INTERESTING]",0 
		EVEN
**********************************************
***	ACC INIT & AES START
**********************************************
ACCINIT:	BSR INITGEM
WAITLOOP:	BSR.S EVENT
		CMP.W #40,MSGBUFF
		BNE.S LOOP
		MOVE.W MSGBUFF+8,D0
		CMP.W ACCNR,D0
		BNE.S LOOP
		BSR.L ACCSELECTED
		BRA.S WAITLOOP
***********************
EVENT:		MOVE.W #25,CONTRL
		MOVE.W #16,SINTIN
		MOVE.W #7,SINTOUT
		MOVE.W #1,SADDRIN
		MOVE.L #MSGBUFF,ADDRIN
		LEA TABLE,A1
		LEA INTIN,A2
		MOVEQ #7,D0
LOP1:		MOVE.L (A1)+,(A2)+
		DBF D0,LOP1
		BSR.L AES
		RTS
******************************************
** INIT GEM ROUTINE
******************************************
INITGEM:	MOVE.W #10,OPCODE		; APPL_INIT
		CLR.W SINTIN
		MOVE.W #1,SINTOUT
		CLR.W SADDRIN
		CLR.W SADDROUT
		BSR.S AES
		MOVE.W INTOUT,APPID
		
		MOVE.W #77,OPCODE		; GRAF_HANDLE
		CLR.W SINTIN
		MOVE.W #5,SINTOUT
		CLR.W SADDRIN
		CLR.W SADDROUT
		BSR.S AES
		MOVE.W INTOUT,GRHANDLE

		MOVE.W #35,CONTRL		; ACC INIT
		MOVE.W #1,SINTIN
		MOVE.W #1,SINTOUT
		MOVE.W #1,SADDRIN
		MOVE.W APPID,INTIN
		MOVE.L #ACCNAME,ADDRIN
		BSR.L AES
		MOVE.W INTOUT,ACCNR
		RTS
**********************************************
***	GEM RUTINS
**********************************************
AES:		MOVE.L #AESPB,D1
		MOVE.W #$C8,D0
		TRAP #2
		RTS
VDI:		MOVE.L #VDIPB,D1
		MOVEQ #$73,D0
		TRAP #2
		RTS
**********************************************
***	GEM DATA
**********************************************
AESPB:		DC.L CONTRL,GLOBAL,INTIN,INTOUT,ADDRIN,ADDROUT
VDIPB:		DC.L CONTRL,INTIN,PTSIN,INTOUT,PTSOUT
***********************************************
***	ALLMŽN DATA
***********************************************
TABLE:		DC.W $13,1,1,1
		BLK.W 12,0
ACCNAME:	DC.B " OMEGA'S ACC ROUT ",0
**************************************
**	GEM NOLL DATA
**************************************
CONTRL:
OPCODE:		DC.W 0
SINTIN:		DC.W 0
SINTOUT:	DC.W 0
SADDRIN:	DC.W 0
SADDROUT:	DC.L 0
		BLK.W 5
GLOBAL:
APVERSION:	DC.W 0
APCOUNT:	DC.W 0
APID:		DC.W 0
APPRIVATE:	DC.L 0
AP1RESV:	DC.L 0
AP2RESV:	DC.L 0
AP3RESV:	DC.L 0
AP4RESV:	DC.L 0
INTIN:		BLK.W 128
PTSIN:		BLK.W 128
INTOUT:		BLK.W 128
PTSOUT:		BLK.W 128
ADDRIN:		BLK.W 128
ADDROUT:	BLK.W 128
GRHANDLE:	DC.W 0
**************************************
**	ALLMŽN NOLL DATA
**************************************
ACCNR:		DC.W 0
APPID:		DC.W 0
MSGBUFF:	BLK.L 8
		BLK.L 128
STACK:
