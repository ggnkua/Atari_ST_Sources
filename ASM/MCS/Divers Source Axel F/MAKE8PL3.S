

        BSR     PASS1		* GENERE LE CODE
	BSR	WRITE_TO_DISK
	CLR.L	-(A7)
	TRAP	#1

*************** ROUTINE DE GENERATION DES SPRITES ******************
***************   POUR ECRAN 8 PLANS AVEC MASK    ******************
***************           PREDECALAGE             ******************
***************      SANS GENERATION DE CODE      ******************

PASS1:		MOVE.L	DEPART,A0
		LEA	ROUTINE,A1
		LEA	TAB_ROUT,A2
                move.l  A0,SOURCE
                move.l  A0,SOURCE2

                move.w  X,D0
                *move.w  X,D7		* LARGEUR EN POINT
                *and.w   #$FFF0,D7
                *lsr.w   #1,D7
                *move.w  D7,X_OCT        * LARGEUR EN OCTETS
                
                and.w   #$FFF0,D0
                lsr.w   #4,D0
                *subq.w  #1,D0
                move.w  D0,LARG         * NOMBRE DE FOIS 8 PLANS

                subq.w  #1,Y            * HAUTEUR-1

                MOVEQ	#15,D2		* 16 POSITIONS
SEIZE_POS:
                move.w  #0,OFFSET       * DEPART A 0
                movea.l SOURCE2,A0
                move.l  A0,SOURCE
                MOVE.L	A1,(A2)
                SUB.L	#ROUTINE,(A2)
                LEA	4(A2),A2
                MOVE.W	Y,D1
                
CALC_IT:	movea.w OFFSET,A5
                moveq   #0,D0
                move.w  LARG,D0
                
                
CALC_LIG:       move.w  (A0),D7
                or.w    2(A0),D7
                or.w    4(A0),D7
                or.w    6(A0),D7
                or.w    8(A0),D7
                or.w    10(A0),D7
                or.w    12(A0),D7
                or.w    14(A0),D7

                not.w   D7              * D7=MASQUE
                
                MOVE.W	D7,(A1)+
                MOVE.W	D7,(A1)+
                MOVE.W	(A0),(A1)+
                MOVE.W	2(A0),(A1)+
                MOVE.W	4(A0),(A1)+
                MOVE.W	6(A0),(A1)+
                MOVE.W	8(A0),(A1)+
                MOVE.W	10(A0),(A1)+
                MOVE.W	12(A0),(A1)+
                MOVE.W	14(A0),(A1)+
                
                

*--------------------------------------------------------------------------
*--------------------------------------------------------------------------
FIN_TEST:	LEA	16(A0),A0
                ADD.W	#16,OFFSET
                DBRA	D0,CALC_LIG

                movea.l SOURCE,A0
                moveq   #0,D7
                move.w  LEN,D7
                adda.l  D7,A0
                move.l  A0,SOURCE
                adda.W	LONG,A5			* LEN OF A SCAN LINE
                move.w  A5,OFFSET
                dbra    D1,CALC_IT

                movem.l D0-A6,-(SP)
                BSR.S     ROX_GFX
                movem.l (SP)+,D0-A6

                DBRA	D2,SEIZE_POS
                SUB.L	#ROUTINE,A1
                MOVE.L	A1,LEN_CODE
                RTS
*--------------------------------------------------------------------------
ROX_GFX:
                movea.l SOURCE2,A0
                movea.l A0,A1
                move.w  Y,D1
                
COL_ROX:        move    #0,CCR
                move.w  LARG,D0
                
LIG_ROX1:       roxr.w  (A0)
                lea     16(A0),A0
                dbra    D0,LIG_ROX1

                movea.l A1,A0
                move    #0,CCR
                move.w  LARG,D0
                
LIG_ROX2:       roxr.w  2(A0)
                lea     16(A0),A0
                dbra    D0,LIG_ROX2

                movea.l A1,A0
                move    #0,CCR
                move.w  LARG,D0
                
LIG_ROX3:       roxr.w  4(A0)
                lea     16(A0),A0
                dbra    D0,LIG_ROX3

                movea.l A1,A0
                move    #0,CCR
                move.w  LARG,D0
                
LIG_ROX4:       roxr.w  6(A0)
                lea     16(A0),A0
                dbra    D0,LIG_ROX4
                
                movea.l A1,A0
                move    #0,CCR
                move.w  LARG,D0
                
LIG_ROX5:       roxr.w  8(A0)
                lea     16(A0),A0
                dbra    D0,LIG_ROX5
                
                movea.l A1,A0
                move    #0,CCR
                move.w  LARG,D0
                
LIG_ROX6:       roxr.w  10(A0)
                lea     16(A0),A0
                dbra    D0,LIG_ROX6
                
                movea.l A1,A0
                move    #0,CCR
                move.w  LARG,D0
                
LIG_ROX7:       roxr.w  12(A0)
                lea     16(A0),A0
                dbra    D0,LIG_ROX7

                movea.l A1,A0
                move    #0,CCR
                move.w  LARG,D0
                
LIG_ROX8:       roxr.w  14(A0)
                lea     16(A0),A0
                dbra    D0,LIG_ROX8

                adda.w  LEN,A1		* LEN OF A SPRITE LINE
                movea.l A1,A0
                dbra    D1,COL_ROX
                rts
***************************************************************************
WRITE_TO_DISK
	MOVE.W	#0,-(A7)
	PEA	FILENAME
	MOVE.W	#$3C,-(A7)
	TRAP	#1
	ADD.W	#8,A7
	MOVE.L	D0,D7
	
	MOVE.L	LEN_CODE,D2
	ADD.L	#$66,D2
	PEA	BUFFER
	MOVE.L	D2,-(A7)
	MOVE.W	D7,-(A7)
	MOVE.W	#$40,-(A7)
	TRAP	#1
	ADD.W	#12,A7
	
	MOVE.W	D7,-(A7)
	MOVE.W	#$3E,-(A7)
	TRAP	#1
	ADDQ.W	#4,A7
	RTS
	
FILENAME	DC.B	'SPR256_3.BIN',0
***************************************************************************
	EVEN
X	DC.W	32
Y	DC.W	32
LEN	DC.W	320
LONG	DC.W	320
LARG	DC.W	0
DEPART	DC.L	ECRAN+1664

SOURCE:   DC.L 0
SOURCE2:  DC.L 0
OFFSET:	  DC.W 0
LEN_CODE	DC.L	0


ECRAN:		INCBIN	D:\DESSIN\TRUEPAIN.T\DRAG256.TPI

***************************************************************************
*	BUFFER+4	RELOCATION DE LA ROUTINE
*	BUFFER		AFFICHAGE DU SPRITE 32*32
*			A0 : ADD ECRAN OU AFFICHER + OFFSET POSITION XY

BUFFER		BRA	AFF
		BRA	PREPAR
TAB_ROUT:       REPT 16
                DC.L 0
                ENDR
PREPAR		LEA	TAB_ROUT(PC),A0
		LEA	ROUTINE(PC),A1
		MOVE.L	A1,D1
		MOVEQ	#15,D0
ICI		ADD.L	D1,(A0)+
		DBF	D0,ICI
		RTS
AFF		LEA	TAB_ROUT(PC),A1
		MOVE.L	(A1,D0.W*4),A1
		MOVEQ	#31,D0
SPR32_32	MOVEM.L	(A1)+,D1-D7			* D1 = MASK
		AND.L	D1,(A0)				* D2 = PLAN 1 ET 2
		AND.L	D1,4(A0)			* D3 = PLAN 3 ET 4
		AND.L	D1,8(A0)			* D4 = PLAN 5 ET 6
		AND.L	D1,12(A0)			* D5 = PLAN 7 ET 8
		OR.L	D2,(A0)
		OR.L	D3,4(A0)			* D6 = MASK
		OR.L	D4,8(A0)			* D7 = PLAN 1 ET 2
		OR.L	D5,12(A0)
		
		MOVEM.L	(A1)+,D1-D7			* D1 = PLAN 3 ET 4
		AND.L	D6,16(A0)			* D2 = PLAN 5 ET 6
		AND.L	D6,20(A0)			* D3 = PLAN 7 ET 8
		AND.L	D6,24(A0)
		AND.L	D6,28(A0)			* D4 = MASK
		OR.L	D7,16(A0) 			* D5 = PLAN 1 ET 2
		OR.L	D1,20(A0)			* D6 = PLAN 3 ET 4
		OR.L	D2,24(A0)			* D7 = PLAN 5 ET 6
		OR.L	D3,28(A0)
		
		MOVE.L	(A1)+,D1			* D1 = PLAN 7 ET 8
		AND.L	D4,32(A0)
		AND.L	D4,36(A0)
		AND.L	D4,40(A0)
		AND.L	D4,44(A0)
		OR.L	D5,32(A0)
		OR.L	D6,36(A0)
		OR.L	D7,40(A0)
		OR.L	D1,44(A0)
		
		LEA	320(A0),A0
		DBF	D0,SPR32_32
		RTS
ROUTINE:	
		