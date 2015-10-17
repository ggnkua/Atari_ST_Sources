

        BSR     PASS1		* GENERE LE CODE
	BSR	WRITE_TO_DISK
	CLR.L	-(A7)
	TRAP	#1

*************** ROUTINE DE GENERATION DES SPRITES ******************
***************        POUR ECRAN 8 PLANS         ******************
***************        AVEC MASK  8 PLANS         ******************

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
                tst.w   D7
                beq     MOVES

                cmp.w   #$FFFF,D7       * MASK=$FFFF ??
                beq     FIN_TEST	* PAS DE AND

                movea.w OFFSET,A6

		MOVE.W	#$203C,(A1)+	* MOVE.L #XXXXXXXX,D0
		MOVE.W	D7,(A1)+
		MOVE.W	D7,(A1)+
		
                move.w  #$C1A8,(A1)+    * AND.L D0,XX(A0)
                move.w  A6,(A1)+
                addq.w  #4,A6

                move.w  #$C1A8,(A1)+    * AND.L D0,XX(A0)
                move.w  A6,(A1)+
                addq.w  #4,A6
                
                move.w  #$C1A8,(A1)+    * AND.L D0,XX(A0)
                move.w  A6,(A1)+
                addq.w  #4,A6
                
                move.w  #$C1A8,(A1)+    * AND.L D0,XX(A0)
                move.w  A6,(A1)+
                
                movea.w OFFSET,A6

                tst.w   (A0)
                beq.s   TEST_PLAN2
                tst.w   2(A0)
                beq.s   ORW_PLAN1

ORL_PLAN1_2	move.w  #$A8,(A1)+	* OR.L	#XXXXXXXX,XX(A0)
                move.w  (A0),(A1)+
                move.w  2(A0),(A1)+
                move.w  A6,(A1)+
                bra.s   TEST_PLAN3
                
ORW_PLAN1:      move.w  #$68,(A1)+	* OR.W	#XXXXXXXX,XX(A0)
                move.w  (A0),(A1)+
                move.w  A6,(A1)+
                bra.s   TEST_PLAN3
                
TEST_PLAN2:	movea.w OFFSET,A6
                addq.w  #2,A6
                tst.w   2(A0)
                beq.s   TEST_PLAN3
		TST.W	4(A0)
		BEQ.S	ORW_PLAN2
		
ORL_PLAN2_3	move.w  #$A8,(A1)+
                move.w  2(A0),(A1)+
		MOVE.W	4(A0),(A1)+
                MOVE.W  A6,(A1)+
                BRA.S	TEST_PLAN4
                
ORW_PLAN2	MOVE.W	#$68,(A1)+
		MOVE.W	2(A0),(A1)+
                MOVE.W	A6,(A1)+
                BRA.S	TEST_PLAN4
		                
                
TEST_PLAN3	movea.w OFFSET,A6
                addq.w  #4,A6
                tst.w   4(A0)
                beq.s   TEST_PLAN4
                tst.w   6(A0)
                beq.s   ORW_PLAN3

ORL_PLAN3_4     move.w  #$A8,(A1)+
                move.w  4(A0),(A1)+
                move.w  6(A0),(A1)+
                move.w  A6,(A1)+
                bra.S   TEST_PLAN5
                
ORW_PLAN3:      move.w  #$68,(A1)+
                move.w  4(A0),(A1)+
                move.w  A6,(A1)+
                bra.S   TEST_PLAN5
                
TEST_PLAN4	movea.w OFFSET,A6
                addq.w  #6,A6
                tst.w   6(A0)
                beq.s   TEST_PLAN5
                TST.W	8(A0)
                BEQ.S	ORW_PLAN4

ORL_PLAN4_5	move.w  #$A8,(A1)+
                move.w  6(A0),(A1)+
                MOVE.W	8(A0),(A1)+
                move.w  A6,(A1)+
                BRA	TEST_PLAN6
                
ORW_PLAN4	MOVE.W	#$68,(A1)+                
                move.w  6(A0),(A1)+
                move.w  A6,(A1)+
                BRA	TEST_PLAN6

TEST_PLAN5	movea.w OFFSET,A6
                addq.w  #8,A6
                tst.w   8(A0)
                BEQ	TEST_PLAN6
                TST	10(A0)
                BEQ	ORW_PLAN5
                
ORL_PLAN5_6     MOVE.W	#$A8,(A1)+
		MOVE.W	8(A0),(A1)+
		MOVE.W	10(A0),(A1)+
                move.w  A6,(A1)+
                BRA	TEST_PLAN7
                
ORW_PLAN5	MOVE.W	#$68,(A1)+
		MOVE.W	8(A0),(A1)+
                move.w  A6,(A1)+
                BRA	TEST_PLAN7
                
TEST_PLAN6	movea.w OFFSET,A6
		ADD.W	#10,A6
		TST.W	10(A0)
		BEQ	TEST_PLAN7
		TST.W	12(A0)
		BEQ	ORW_PLAN6
		
ORL_PLAN6_7	MOVE.W	#$A8,(A1)+
		MOVE.W	10(A0),(A1)+
		MOVE.W	12(A0),(A1)+
		MOVE.W	A6,(A1)+
		BRA	TEST_PLAN8
		
ORW_PLAN6	MOVE.W	#$68,(A1)+
		MOVE.W	10(A0),(A1)+
		MOVE.W	A6,(A1)+
		BRA	TEST_PLAN8
		
TEST_PLAN7	MOVE.W	OFFSET,A6
		ADD.W	#12,A6
		TST.W	12(A0)
		BEQ	FIN_TEST
		TST	14(A0)
		BEQ	ORW_PLAN7
		
ORL_PLAN7_8	MOVE.W	#$A8,(A1)+
		MOVE.W	12(A0),(A1)+
		MOVE.W	14(A0),(A1)+
		MOVE.W	A6,(A1)+
		BRA	FIN_TEST
		
ORW_PLAN7	MOVE.W	#$68,(A1)+
		MOVE.W	12(A0),(A1)+						
		MOVE.W	A6,(A1)+
		BRA	FIN_TEST
		
TEST_PLAN8	TST	14(A0)
		BEQ	FIN_TEST
		MOVE.W	OFFSET,A6
		ADD.W	#12,A6

ORW_PLAN8	MOVE.W	#$68,(A1)+
		MOVE.W	14(A0),(A1)+
		MOVE.W	A6,(A1)+
		BRA.S	FIN_TEST

MOVES:          movea.w OFFSET,A6
                move.w  #$217C,(A1)+
                move.w  (A0),(A1)+
                move.w  2(A0),(A1)+
                move.w  A6,(A1)+
                addq.w  #4,A6
                move.w  #$217C,(A1)+
                move.w  4(A0),(A1)+
                move.w  6(A0),(A1)+
                move.w  A6,(A1)+
                addq.w  #4,A6
		move.w  #$217C,(A1)+
                move.w  8(A0),(A1)+
                move.w  10(A0),(A1)+
                move.w  A6,(A1)+
                addq.w  #4,A6
                move.w  #$217C,(A1)+
                move.w  12(A0),(A1)+
                move.w  14(A0),(A1)+
                move.w  A6,(A1)+                

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
                move.w  #$4E75,(A1)+		* RTS

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
	
FILENAME	DC.B	'SPR256.BIN',0
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


ECRAN:		INCBIN	D:\DESSIN\TRUEPAIN.T\DRAGON.TPI

***************************************************************************
*	BUFFER+4	RELOCATION DE LA ROUTINE
*	BUFFER		AFFICHAGE DU SPRITE
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
		JMP	(A1)
ROUTINE:	
		