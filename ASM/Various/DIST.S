*DETTA PROGRAM "DISTAR" ETT GRAFICBLOCK, SOM LADDAS
*FRAN EN NEOCHROME BILD
*AV JAN LUNDEQUIST 

*************************************************
*VARIABEL INITIERING,INLADDNING
*************************************************

	MOVE.L #$F8000,SCREEN
             move.w #0,-(sp)
             move.l SCREEN,-(sp)
             move.l SCREEN,-(sp)
             move.w #5,-(sp)
             trap #14
             add.l #12,sp

	ADD.L #16000,SCREEN


	JSR LADDA

	move.l #GRAFBUFF,d0
	add.l #4,d0
	move.l d0,-(sp)
	move.w #6,-(sp)
	trap #14
	add.l #6,sp
	MOVE.L #0,ANTSTEG
	MOVE.L #GRAFBUFF,ADDR
	MOVE.L #BUFFER,ROTBUFF
	ADD.L #128,ADDR
	MOVE.L #32,HOJD
	SUB.L #1,HOJD
	MOVE.L #128,D0
	DIVU #8,D0
	SUB.L #1,D0
	MOVE.L D0,BREDD
	MOVE.L #3,PIXPLAN
	MOVE.L #DATA,DATAPOS
	MOVE.L #256,DATAEND
	MOVE.L #4,DATAADD
	MOVE.L #4,FARTFACT

	JSR MK16ROT

	MOVE.L #BUFFER,ROTBUFF
	SUB.L #8,ROTBUFF

	MOVE.L DATAADD,D0
	MOVE.L FARTFACT,D1
	MULU D1,D0
	MOVE.L D0,DATAADD

	MOVE.L DATAEND,D0
	DIVU D1,D0
	MOVE.L D0,DATAEND

************************************************
MAIN
************************************************

	JSR DIST

	MOVE.W #37,-(SP)
	TRAP #14
	ADD.L #2,SP

	MOVE.W #$B,-(SP)
	TRAP #1
	ADD.L #2,SP

	CMP.B #0,D0
	BEQ MAIN

	BRA SLUT

*************************************************
*DENNA RUTIN LASER FARDIG FUNCTION OCH LAGGER UT
*DATA
DIST
*************************************************
	
	MOVE.L DATAPOS,A3
	MOVE.L #0,ROW
	MOVE.L HOJD,D7
	MOVE.L ROTBUFF,A0
	MOVE.L SCREEN,A1

DISTA:	MOVE.L (A3),D0
	ADD.L DATAADD,A3
	
	ADD.L #8,D0
	MULU #4352,D0
	MOVE.L ROW,D1
	MULU #136,D1
	ADD.L D1,D0
	ADD.L D0,A0

	MOVEM.L (A0),D0-D6/A4-A6
	MOVEM.L D0-D6/A4-A6,(A1)

	MOVEM.L 40(A0),D0-D6/A4-A6
	MOVEM.L D0-D6/A4-A6,40(A1)
	
	MOVEM.L 80(A0),D0-D6/A4-A6
	MOVEM.L D0-D6/A4-A6,80(A1)

	MOVEM.L 120(A0),D0-D3
	MOVEM.L D0-D3,120(A1)

	MOVE.L ROTBUFF,A0
             ADD.L #160,A1
	ADD.L #1,ROW

	DBRA D7,DISTA

	MOVE.L DATAADD,D0
	ADD.L D0,DATAPOS
	ADD.L #1,DATARAKN
	MOVE.L DATARAKN,D0

	CMP.L DATAEND,D0
	BNE ATER
	MOVE.L #0,DATARAKN
	MOVE.L #DATA,DATAPOS

ATER:	RTS

	
*************************************************
*DENNA RUTIN ROTERAR DET UTVALDA GRAFIKBLOCKET
MK16ROT
*************************************************

	MOVE.L ADDR,A0
	MOVE.L A0,A5
	MOVE.L ROTBUFF,A1
	MOVE.L HOJD,D7
	MOVE.L BREDD,D6
	MOVE.L ANTSTEG,D5
	MOVE.L PIXPLAN,D4
	CLR.L D0

LOOP	MOVE.W (A0)+,D0

	LSL.L D5,D0	
	SWAP D0
	OR.W D0,-8(A1)
	SWAP D0 
             MOVE.W D0,(A1)+

	CLR.L D0
	
	DBRA D4,LOOP

	MOVE.L PIXPLAN,D4

	DBRA D6,LOOP
	
	MOVE.L BREDD,D6

	ADD.L #8,A1
	ADD.L #160,A5
	MOVE.L A5,A0		;NASTA RAD

	DBRA D7,LOOP

	ADD.L #4352,ROTBUFF

	ADD.L #1,ANTSTEG
	CMPI.L #16,ANTSTEG
	BNE MK16ROT

	RTS



*************************************************
LADDA
*************************************************

             MOVE.L #FILNAME,D5
             MOVE.L #GRAFBUFF,D6
             MOVE.L #32128,D4
             JSR LADD

             RTS


LADD:        CLR.W -(SP)
             MOVE.L D5,-(SP)
             MOVE.W #$3D,-(SP)
             TRAP #1
             ADDQ.L #8,SP
	TST.W D0
	BMI ERROR
             MOVE.W D0,HANDLE
              
                
             MOVE.L D6,-(SP)
             MOVE.L D4,-(SP)
             MOVE.W HANDLE,-(SP)
             MOVE.W #$3F,-(SP)
             TRAP #1
             ADD.L #12,SP
              
                
             MOVE.W HANDLE,-(SP)
             MOVE.W #$3E,-(SP)
             TRAP #1
             ADDQ.L #4,SP

ERROR:
             RTS



*************************************************
SLUT:
*************************************************

             move.w #1,-(sp)
             move.l SCREEN,-(sp)
             move.l SCREEN,-(sp)
             move.w #5,-(sp)
             trap #14
             add.l #12,sp

	clr.w -(sp)
	trap #1

*************************************************
*VARIABLER
*************************************************

GRAFBUFF	DS.B 33000
BUFFER	DS.B 75000
SCREEN	DS.L 1
HOJD	DS.L 1
BREDD	DS.L 1
PIXPLAN	DS.L 1
ADDR	DS.L 1
HANDLE	DS.L 1
PIC	DS.L 1
ANTSTEG	DS.L 1
ROTBUFF	DS.L 1
ROW	DS.L 1
DATARAKN	DS.L 1
DATAPOS	DS.L 1
DATAADD	DS.L 1
DATAEND	DS.L 1
FARTFACT	DS.L 1

FILNAME	DC.B "E:\INTROPIC.NEO",0



DATA:        DC.L 0,0,0,0,0,0,1,1,1,1,1,2,2,2
             DC.L 2,2,3,3,3,3,3,3,4,4,4,4,4,4
             DC.L 5,5,5,5,5,5,5,6,6,6,6,6,6,6
             DC.L 6,6,7,7,7,7,7,7,7,7,7,7,7,7
             DC.L 7,7,7,7,7,7,7,7,7,7,7,7,7,7
             DC.L 7,7,7,7,7,7,7,7,7,7,7,7,7,7
             DC.L 7,6,6,6,6,6,6,6,6,6,5,5,5,5
             DC.L 5,5,5,4,4,4,4,4,4,3,3,3,3,3
             DC.L 3,2,2,2,2,2,1,1,1,1,1,0,0,0
             DC.L 0,0,-1,-1,-1,-1,-1,-1,-2,-2,-2,-2,-2,-3
             DC.L -3,-3,-3,-3,-4,-4,-4,-4,-4,-4,-5,-5,-5,-5
             DC.L -5,-5,-6,-6,-6,-6,-6,-6,-6,-7,-7,-7,-7,-7
             DC.L -7,-7,-7,-7,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8
             DC.L -8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8
             DC.L -8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8
             DC.L -8,-8,-8,-7,-7,-7,-7,-7,-7,-7,-7,-7,-6,-6
             DC.L -6,-6,-6,-6,-6,-5,-5,-5,-5,-5,-5,-4,-4,-4
             DC.L -4,-4,-4,-3,-3,-3,-3,-3,-2,-2,-2,-2,-2,-1
             DC.L -1,-1,-1,-1,0,0,0,0,0,0,1,1,1,1
             DC.L 1,2,2,2,2,2,3,3,3,3,3,3,4,4
             DC.L 4,4,4,4,5,5,5,5,5,5,5,6,6,6
             DC.L 6,6,6,6,6,6,7,7,7,7,7,7,7,7
             DC.L 7,7,7,7,7,7,7,7,7,7,7,7,7,7
             DC.L 7,7,7,7,7,7,7,7,7,7,7,7,7,7
             DC.L 7,7,7,7,7,6,6,6,6,6,6,6,6,6
             DC.L 5,5,5,5,5,5,5,4,4,4,4,4,4,3
             DC.L 3,3,3,3,3,2,2,2,2,2,1,1,1,1
             DC.L 1,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-2,-2
             DC.L -2,-2,-2,-3,-3,-3,-3,-3,-4,-4,-4,-4,-4,-4
             DC.L -5,-5,-5,-5,-5,-5,-6,-6,-6,-6,-6,-6,-6,-7
             DC.L -7,-7,-7,-7,-7,-7,-7,-7,-8,-8,-8,-8,-8,-8
             DC.L -8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8
             DC.L -8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8
             DC.L -8,-8,-8,-8,-8,-8,-8,-7,-7,-7,-7,-7,-7,-7
             DC.L -7,-7,-6,-6,-6,-6,-6,-6,-6,-5,-5,-5,-5,-5
             DC.L -5,-4,-4,-4,-4,-4,-4,-3,-3,-3,-3,-3,-2,-2
             DC.L -2,-2,-2,-1,-1,-1,-1,-1

