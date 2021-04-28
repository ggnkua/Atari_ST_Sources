****************************
*   Desk accessory shell   *
*      by Sam Cherian      *
*  Atari ST User Oct 1989  *
****************************

 MOVE.L #STCKEND,A7   		*initialise SP
 MOVE.L #APPLINIT,ZC 		*appl_init
 BSR AES
 MOVE.W INTOUT,APID 		*ap_id in intout
 MOVE.W APID,INTIN
 MOVE.L #MENSTRING,ADDRIN
 MOVE.L #MENREG,ZC 		*register
 BSR AES           		* + get
 MOVE.W INTOUT,MENID  		*menu-id
LOOP:
 MOVE.L #MESGPIPE,ADDRIN 	*mess_buf
 MOVE.W #16,INTIN  		*type of event
 MOVE.W #1,INTIN+2
 MOVE.W #1,INTIN+4
 MOVE.W #1,INTIN+6
 LEA INTIN,A3
 ADDA.L #8,A3
 MOVE.W #11,D4
LIN:
 MOVE.W #0,(A3)+
 DBRA D4,LIN
 MOVE.L #EVNTMULTI,ZC 		*event_multi
 BSR AES
 MOVE.W INTOUT,D3 		*message?
 CMP.W #16,D3
 BNE LOOP  			*no? - back to waiting
 LEA MESGPIPE,A4 		*yes?- look at mesg-buf
 MOVE.W (A4),D4
 CMP.W #40,D4 			*open accessory?
 BEQ ACOP 			*check acc id
 BRA LOOP 			*no?- more waiting!
ACOP:
 MOVE.W 8(A4),D6 		*check id
 MOVE.W MENID,D5 		*open accessory
 CMP.W D6,D5
 BEQ ACOPEN 			*open accessory
 BRA LOOP   			*no? Still more waiting
ACOPEN:
 MOVE.W #3,-(SP)    *YOUR CODE
 TRAP #14           *GOES HERE
 ADDQ.L #2,SP       *  . . .
 MOVE.L D0,SCREEN   *  . . .
 MOVE.L #BUFFER,A3  *  . . .
 MOVE.L SCREEN,A4   *  . . .
 BSR RESCRN         *  . . .
 BSR ZELOP          *  . . .
 MOVE.L #MES,-(SP)  *  . . .	
 MOVE.W #9,-(SP)    *  . . .
 TRAP #1            *  . . .
 ADDQ.L #6,SP       *  . . .
 MOVE.L #CUR,-(SP)  *  . . .
 MOVE.W #9,-(SP)    *  . . .
 TRAP #1            *  . . .
 ADDQ.L #6,SP       *  . . .
 MOVE.W #7,-(SP)    *  . . .
 TRAP #1            *  . . .
 ADDQ.L #2,SP       *  . . .
 BSR ZELOP          *  . . .
 MOVE.L #BUFFER,A4  *  . . .
 MOVE.L SCREEN,A3   *  . . .
 BSR RESCRN         * TO HERE
 BRA LOOP  			*Back to more waiting
RESCRN:
 MOVE.W #799,D4     		*Count-1 in D4
SCLOOP:
 MOVE.W (A4)+,(A3)+ 		*Move 800 words
 DBRA D4,SCLOOP 		*of screen to buffer
 RTS
ZELOP:
 MOVE.L SCREEN,A4 		*Blank 10 lines
 MOVE.W #799,D4   		*by vriting 0s to
ZLOOP:
 MOVE.W #0,(A4)+  		*video ram
 DBRA D4,ZLOOP
 RTS
AES:
 MOVE.L #ZC,D1   		*Call aes
 MOVE.L #200,D0
 TRAP #2
 RTS

STACK:     DS.L 250  		*set up stack
STCKEND:   DS.L 1

APPLINIT:  DC.W 10,0,1,0,0  	*Aes
MENREG:    DC.W 35,1,1,1,0 	*routines
EVNTMULTI: DC.W 25,16,7,1,0
CONTROL:   DC.W 5  		*AES arrays
ADDROUT:   DS.L 1
ADDRIN:    DS.L 1
INTOUT:    DS.W 25
INTIN:     DS.W 25
GLOBAL:    DS.W 16

ZC:        DC.L CONTROL,GLOBAL,INTIN
           DC.L INTOUT,ADDRIN,ADDROUT

MESGPIPE:  DS.W 8 			*message buffer
MENID:     DS.W 1
APID:      DS.W 1
SCREEN:    DS.L 1   			*screen address
BUFFER:    DS.W 800 			*buffer for menu
MES:       DC.B 'ACCESSORY DEMO by '
           DC.B 'S.CHERIAN. ANY KEY'
           DC.B ' EXITS',0
CUR:       DC.B 27,'H',0 		*cursor home
MENSTRING: DC.B '  ACCDEMO',0 		*name
END


