
**************************************
*          90 DEGRES SCREEN          *
*          ----------------          *
*         (C) MAGNUM OF MCS          *
*             05/09/91               *
*                                    *
*       LA DELIRIOUS 4 VAINCRA       *
*                                    *
**************************************

                TEXT

TEST	EQU	1
FINAL           EQU 1

ECRAN           EQU $070000

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	MOVE.W	#$2700,SR

                movem.l NILL,D0-D7
                movem.l D0-D7,$FFFF8240.w
                movem.l D0-D7,PAL

	CLR.B	$FFFF8260.W

	MOVE.B	#$7,$FFFF8201.W
	MOVE.B	#$0,$FFFF8203.W
	

                moveq   #1,D0
                jsr     ZIK

                lea     SAVE,A0
                move.l  $70.w,(A0)+
                move.l  $0120.w,(A0)+
                move.b  $FFFFFA07.w,(A0)+
                move.b  $FFFFFA09.w,(A0)+
                move.b  $FFFFFA13.w,(A0)+
                move.b  $FFFFFA17.w,(A0)+
                move.b  $FFFFFA1B.w,(A0)+
                move.b  $FFFFFA21.w,(A0)+

                move.b  #1,$FFFA07
                move.b  #1,$FFFA13
                clr.b   $FFFA09
                bclr    #3,$FFFA17

                move.l  #NULL,$70.w     * VBL NULLE
                move.l  #NULL,$0120.w   * HBL NULLE
                move    #$2300,SR

                IFEQ FINAL

                lea     ECRAN,A0
                lea     BOUTEILLE+34,A1
                move.w  #7999,D1
AFF_BOUT:
                move.l  (A1)+,(A0)+
                dbra    D1,AFF_BOUT

                move    #$2700,SR
                move.l  #VBL_01,$70.w
                move    #$2300,SR

WAIT_01:
                tst.w   VBL_FLAG
                beq.s   WAIT_01
                movem.l BOUTEILLE+2,D0-D7
                movem.l D0-D7,PAL
WAIT:
                tst.w   SYNC_1
                beq.s   WAIT

                move    #$2700,SR
                move.l  #VBL2,$70.w
                move.l  #NULL,$0120.w
                move    #$2300,SR

                move.w  #0,VBL_FLAG
                moveq   #100,D7
WAIT_SEC:
                tst.w   VBL_FLAG
                beq.s   WAIT_SEC
                move.w  #0,VBL_FLAG
                dbra    D7,WAIT_SEC

                move    #$2700,SR
                move.l  #VBL3,$70.w
                move    #$2300,SR

                move.w  #0,SYNC_1
WAIT_3:
                tst.w   SYNC_1
                beq.s   WAIT_3

                move    #$2700,SR
                move.l  #VBL2,$70.w
                move    #$2300,SR

                movem.l NILL,D0-D7
                movem.l D0-D7,$FFFF8240.w

                lea     ECRAN,A0
                moveq   #0,D0
                move.w  #7999,D1
EFF_SCR1:
                move.l  D0,(A0)+
                dbra    D1,EFF_SCR1

                movem.l PAL_FNT,D0-D7
                movem.l D0-D7,$FFFF8240.w
PEKM:
                lea     MESS,A0
PEKECR:
                lea     ECRAN,A2
LIG:
                tst.w   AFF_FLAG
                bne     FUCK_YOU
                movea.l A2,A4
                moveq   #0,D0
                move.b  (A0)+,D0
                beq     SUITE_01
                cmp.b   #1,D0
                beq     NEXT_LINE
                cmp.b   #2,D0
                beq     NEXT_PAGE
                sub.b   #' ',D0
                add.w   D0,D0
                add.w   D0,D0
                lea     TAB_FNT,A3
                movea.l 0(A3,D0.w),A1
                move.w  #1,AFF_FLAG
                movea.l #MSK,A6
                move.l  A1,AFF_LET+2
                move.l  A2,PEK_MCS+2
                bra     LIG
NEXT_LET:
                adda.l  #8,A2
                bra     LIG
FUCK_YOU:
                bsr     AFF_LET
                cmpa.l  #FIN_MSK,A6
                bne.s   PISS_OFF
                move.w  #0,AFF_FLAG
                bra     NEXT_LET
PISS_OFF:
                tst.w   VBL_FLAG
                beq.s   PISS_OFF
                move.w  #0,VBL_FLAG
                bra     LIG
AFF_FLAG:
                DC.W 0

NEXT_LINE:
                addi.l  #160*16,PEKECR+2
                bra     PEKECR
NEXT_PAGE:
                move.l  #ECRAN,PEKECR+2
                moveq   #50,D7
WAIT_02:
                tst.w   VBL_FLAG
                beq.s   WAIT_02
                move.w  #0,VBL_FLAG
                dbra    D7,WAIT_02

                lea     ECRAN,A6
                moveq   #0,D0
                move.w  #199,D6
EFF_03:
                move.w  #39,D7
EFF_02:
                move.l  D0,(A6)+
                dbra    D7,EFF_02
                move.w  #0,VBL_FLAG
WAIT_03:
                tst.w   VBL_FLAG
                beq.s   WAIT_03
                dbra    D6,EFF_03

                bra     PEKECR
                ENDC

SUITE_01:
                movea.l SCREEN,A0
                movea.l SCREEN+4,A1
                moveq   #0,D0
                move.w  #40*325-1,D1
EFF_04:
                move.l  D0,(A0)+
                move.l  D0,(A1)+
                dbra    D1,EFF_04

                move.w  #32,D0
                move.w  #15,D1
                movea.l #SPRITE,A0
                movea.l #ROUT_D,A1
                movea.l #TAB_D,A2
                bsr     CALC_SPRITE

                move.w  #32,D0
                move.w  #14,D1
                movea.l #SPRITE+16*15,A0
                movea.l A6,A1
                lea     TAB_E,A2
                bsr     CALC_SPRITE

                move.w  #32,D0
                move.w  #14,D1
                movea.l #SPRITE+16*29,A0
                movea.l A6,A1
                lea     TAB_L,A2
                bsr     CALC_SPRITE

                move.w  #32,D0
                move.w  #14,D1
                movea.l #SPRITE+16*43,A0
                movea.l A6,A1
                lea     TAB_4,A2
                bsr     CALC_SPRITE

                movea.l SCREEN,A0
                movea.l SCREEN+4,A1
	LEA	32(A0),A0
	LEA	32(A1),A1
                move.w  #$FFFF,D0
                moveq   #1,D2
                move.w  #79,D1
AFF_BANDE:
                move.w  D0,(A0)
                move.w  D0,2(A0)
                move.w  D0,4(A0)
                move.w  D2,6(A0)
                move.w  D0,160(A0)
                move.w  D0,162(A0)
                move.w  D0,164(A0)
                move.w  D2,166(A0)
                move.w  D0,320(A0)
                move.w  D0,322(A0)
                move.w  D0,324(A0)
                move.w  D2,326(A0)
                move.w  D0,(A1)
                move.w  D0,2(A1)
                move.w  D0,4(A1)
                move.w  D2,6(A1)
                move.w  D0,160(A1)
                move.w  D0,162(A1)
                move.w  D0,164(A1)
                move.w  D2,166(A1)
                move.w  D0,320(A1)
                move.w  D0,322(A1)
                move.w  D0,324(A1)
                move.w  D2,326(A1)
                lea     640(A0),A0
                lea     640(A1),A1
                dbra    D1,AFF_BANDE

	MOVEM.L	SCREEN,A0/A1
	MOVE.W	#$FFFF,D0
	LEA	72(A0),A0
	LEA	72(A1),A1
	MOVE.W	#319,D4
AFF_RST
	MOVE.W	D0,(A0)
	MOVE.W	D0,6(A0)
	MOVE.W	D0,8(A0)
	MOVE.W	D0,14(A0)
	MOVE.W	D0,16(A0)
	MOVE.W	D0,22(A0)
	MOVE.W	D0,(A1)
	MOVE.W	D0,6(A1)
	MOVE.W	D0,8(A1)
	MOVE.W	D0,14(A1)
	MOVE.W	D0,16(A1)
	MOVE.W	D0,22(A1)
	LEA	160(A0),A0
	LEA	160(A1),A1
	DBRA	D4,AFF_RST

                movem.l PAL_IMG,D0-D7
                movem.l D0-D7,$FFFF8240.w

                lea     ECRAN+104,A0
                movea.l SCREEN+4,A2
	ADD.L	#104,A2
                lea     FOND,A1
                move.w  #318,D7
AFF:
                move.w  #21,D6
AFF_2:
                move.l  (A1),(A0)+
                move.l  (A1)+,(A2)+
                dbra    D6,AFF_2
                lea     160-88(A0),A0
                lea     160-88(A2),A2
                dbra    D7,AFF

                move    #$2700,SR
                move.l  #VBL_DEMO,$70.w
                move    #$2300,SR

WAIT_KEY:
                bra.s   WAIT_KEY

AFF_LET:
                movea.l #$12345678,A1
PEK_MCS:
                movea.l #$12345678,A4
                move.w  #15,D7
LIG_LET:
                movem.l (A1),D0-D1
                move.w  (A6)+,D2
                swap    D0
                and.w   D2,D0
                swap    D0
                and.w   D2,D0
                swap    D1
                and.w   D2,D1
                swap    D1
                and.w   D2,D1
                movem.l D0-D1,(A4)
                lea     160(A1),A1
                lea     160(A4),A4
                dbra    D7,LIG_LET
                rts

FIN_DEMO:
                lea     SAVE,A0
                move.l  (A0)+,$70.w
                move.l  (A0)+,$0120.w
                move.b  (A0)+,$FFFFFA07.w
                move.b  (A0)+,$FFFFFA09.w
                move.b  (A0)+,$FFFFFA13.w
                move.b  (A0)+,$FFFFFA17.w
                move.b  (A0)+,$FFFFFA1B.w
                move.b  (A0)+,$FFFFFA21.w

	ILLEGAL

NULL:
                rte
	IFEQ	FINAL
VBL_01:
	MOVE.B	#0,$FFFF8260.W
                move    #$2700,SR
                clr.w   SYNC_1
                lea     RASTERS01,A0
                lea     $FFFF8240.w,A1
                move.b  POSY,D0
                clr.b   $FFFA1B
                move.b  D0,$FFFA21
                move.b  #8,$FFFA1B
                move.l  #HBL01,$0120.w
                movem.l PAL,D0-D7
                movem.l D0-D7,$FFFF8240.w
                addq.b  #1,POSY
                cmpi.b  #197,POSY
                bne.s   PAS_F01
                move.w  #1,SYNC_1
                move.l  #NULL,$0120.w
PAS_F01:
VBL2:
                movem.l D0-A6,-(SP)
                jsr     ZIK+8
                movem.l (SP)+,D0-A6
                move.w  #1,VBL_FLAG
                move    #$2300,SR
                rte
VBL3:
	MOVE.B	#0,$FFFF8260.W
                move    #$2700,SR
                clr.w   SYNC_1
                lea     RASTERS01,A0
                lea     $FFFF8240.w,A1
                move.b  POSY,D0
                clr.b   $FFFA1B
                move.b  D0,$FFFA21
                move.b  #8,$FFFA1B
                move.l  #HBL01,$0120.w
                movem.l BOUTEILLE+2,D0-D7
                movem.l D0-D7,$FFFF8240.w
                subq.b  #1,POSY
                tst.b   POSY
                bne.s   PAS_F012
                move.w  #1,SYNC_1
                move.l  #NULL,$0120.w
PAS_F012:
                move.w  #1,VBL_FLAG
                movem.l D0-A6,-(SP)
                jsr     ZIK+8
                movem.l (SP)+,D0-A6
                move    #$2300,SR
                rte
	ENDC
HBL01:
                move    #$2700,SR
                movem.l (A0)+,D0-D7
                movem.l D0-D7,(A1)
                clr.b   $FFFA1B
                move.b  #2,$FFFA21
                move.b  #8,$FFFA1B
                move.l  #HBL012,$0120.w
                move    #$2300,SR
                rte
HBL012:
                movem.l (A0)+,D0-D7
                movem.l D0-D7,(A1)
                move.l  #HBL013,$0120.w
                rte
HBL013:
                movem.l (A0)+,D0-D7
                movem.l D0-D7,(A1)
                move.l  #HBL014,$0120.w
                rte
HBL014:
                movem.l (A0)+,D0-D7
                movem.l D0-D7,(A1)
                move.l  #HBL015,$0120.w
                rte
HBL015:
                movem.l (A0)+,D0-D7
                movem.l D0-D7,(A1)
                move.l  #HBL016,$0120.w
                rte
HBL016:
                movem.l (A0)+,D0-D7
                movem.l D0-D7,(A1)
                move.l  #HBL017,$0120.w
                rte
HBL017:
                movem.l (A0)+,D0-D7
                movem.l D0-D7,(A1)
                move.l  #HBL018,$0120.w
                rte
HBL018:
                movem.l (A0)+,D0-D7
                movem.l D0-D7,(A1)
                move.l  #HBL019,$0120.w
                rte

HBL019:
                movem.l (A0)+,D0-D7
                movem.l D0-D7,(A1)
                clr.b   $FFFA1B
                move.b  #100,$FFFA21
                move.b  #8,$FFFA1B
                move.l  #NULL,$0120.w
                rte


*************** ROUTINE DE GENERATION DES SPRITES ******************

CALC_SPRITE:
                move.l  A0,SOURCE
                move.l  A0,SOURCE2
                move.l  A2,TAB_ROUT
                move.w  D0,D7
                and.w   #$FFF0,D7
                lsr.w   #1,D7
                move.w  D7,MAGNUM       * LARGEUR EN OCTETS

                and.w   #$FFF0,D0
                lsr.w   #4,D0
                subq.w  #1,D0
                move.w  D0,LARG         * NOMBRE DE FOIS 4 PLANS

                subq.w  #1,D1           * HAUTEUR-1
                move.w  D1,HAUT

                move.w  #15,D7          * 16 POSITIONS
SEIZE_POS:
                move.w  #0,OFFSET       * DEPART A 0
                movea.w D7,A4
                movea.l SOURCE2,A0
                move.l  A0,SOURCE
                move.l  A1,(A2)+
                move.l  #0,(A2)+
                move.w  HAUT,D1
CALC_IT:
                movea.w OFFSET,A5
                moveq   #0,D0
                move.w  LARG,D0
CALC_LIG:
                move.w  (A0),D3         * PLAN 1
                move.w  2(A0),D4        * PLAN 2
                move.w  4(A0),D5        * PLAN 3
                move.w  6(A0),D6        * PLAN 4

                move.w  D3,D7
                or.w    D4,D7
                or.w    D5,D7
                or.w    D6,D7

                not.w   D7              * D7=MASQUE
                tst.w   D7
                beq     MOVES

                cmp.w   #$FFFF,D7       * MASK=$FFFF ??
                beq     MAG_02          * PAS DE AND

                movea.w OFFSET,A6

                move.w  #$02A8,(A1)+    * AND.L D7
                move.w  D7,(A1)+
                move.w  D7,(A1)+
                move.w  A6,(A1)+

                addq.w  #4,A6

                move.w  #$02A8,(A1)+    * AND.L D7
                move.w  D7,(A1)+
                move.w  D7,(A1)+
                move.w  A6,(A1)+

                movea.w OFFSET,A6

                tst.w   D3
                beq.s   D3_NUL
                tst.w   D4
                beq.s   ORW_D3

                move.w  #$A8,(A1)+
                move.w  D3,(A1)+
                move.w  D4,(A1)+
                move.w  A6,(A1)+
                bra.s   D4_NUL
ORW_D3:
                move.w  #$68,(A1)+
                move.w  D3,(A1)+
                move.w  A6,(A1)+
D3_NUL:

                movea.w OFFSET,A6
                addq.w  #2,A6
                tst.w   D4
                beq.s   D4_NUL

                move.w  #$68,(A1)+
                move.w  D4,(A1)+
                move.w  A6,(A1)+
D4_NUL:
                movea.w OFFSET,A6
                addq.w  #4,A6
                tst.w   D5
                beq.s   D5_NUL
                tst.w   D6
                beq.s   ORW_D5

                move.w  #$A8,(A1)+
                move.w  D5,(A1)+
                move.w  D6,(A1)+
                move.w  A6,(A1)+
                bra     D6_NUL
ORW_D5:
                move.w  #$68,(A1)+
                move.w  D5,(A1)+
                move.w  A6,(A1)+
D5_NUL:
                movea.w OFFSET,A6
                addq.w  #6,A6
                tst.w   D6
                beq.s   D6_NUL

                move.w  #$68,(A1)+
                move.w  D6,(A1)+
                move.w  A6,(A1)+
D6_NUL:
                bra     MAG_02
MOVES:
                movea.w OFFSET,A6
                move.w  #$217C,(A1)+
                move.w  D3,(A1)+
                move.w  D4,(A1)+
                move.w  A6,(A1)+
                addq.w  #4,A6
                move.w  #$217C,(A1)+
                move.w  D5,(A1)+
                move.w  D6,(A1)+
                move.w  A6,(A1)+

MAG_02:
                lea     8(A0),A0
                addi.w  #8,OFFSET
                dbra    D0,CALC_LIG

                movea.l SOURCE,A0
                moveq   #0,D7
                move.w  MAGNUM,D7
                adda.l  D7,A0
                move.l  A0,SOURCE
                adda.l  #160,A5
                move.w  A5,OFFSET
                dbra    D1,CALC_IT
                move.w  #$4E75,(A1)+    * RTS

                movem.l D0-A6,-(SP)
                bsr     ROX_GFX
                movem.l (SP)+,D0-A6

                move.w  A4,D7
                dbra    D7,SEIZE_POS

                movea.l A1,A6           * A6=FIN DES ROUTINES

                bsr     CALC_TABLE
                rts

CALC_TABLE:
                movea.l TAB_ROUT,A0
                lea     128(A0),A1
                move.w  #303,D7
CALC_TAB:
                movea.l (A0)+,A2
                move.l  (A0)+,D1
                addq.l  #8,D1
                move.l  A2,(A1)+
                move.l  D1,(A1)+
                dbra    D7,CALC_TAB
                rts

ROX_GFX:
                movea.l SOURCE2,A0
                movea.l A0,A1
                move.w  HAUT,D1
COL_ROX:
                move    #0,CCR
                move.w  LARG,D0
LIG_ROX1:
                roxr.w  (A0)
                lea     8(A0),A0
                dbra    D0,LIG_ROX1

                movea.l A1,A0
                move    #0,CCR
                move.w  LARG,D0
LIG_ROX2:
                roxr.w  2(A0)
                lea     8(A0),A0
                dbra    D0,LIG_ROX2

                movea.l A1,A0
                move    #0,CCR
                move.w  LARG,D0
LIG_ROX3:
                roxr.w  4(A0)
                lea     8(A0),A0
                dbra    D0,LIG_ROX3

                movea.l A1,A0
                move    #0,CCR
                move.w  LARG,D0
LIG_ROX4:
                roxr.w  6(A0)
                lea     8(A0),A0
                dbra    D0,LIG_ROX4

                adda.w  MAGNUM,A1
                movea.l A1,A0
                dbra    D1,COL_ROX
                rts

VBL_DEMO:
                MOVE.b   #0,$FFFF8260.w
                clr.b   $FFFA1B
                move.b  #100,$FFFA21
                move.b  #4,$FFFA1B
                move.l  #OVR_HAUT,$0120.w
                cmpi.b  #$39,$FFFC02
                beq     FIN_DEMO
	MOVE.L	#TAB_RST,PEK_TAB+2
	BSR	CALC_TABRST
                bsr     EFF_SPR
                bsr     STAR
                bsr     EQUA
                bsr     SCROLL
                bsr     DO_SPRITE
                jsr     ZIK+8
                move.l  SCREEN,D0
                move.l  SCREEN+4,D1
                move.l  D1,SCREEN
                move.l  D0,SCREEN+4
                move.l  BUF_SPRD,D0
                move.l  BUF_SPRD+4,D1
                move.l  D0,BUF_SPRD+4
                move.l  D1,BUF_SPRD
                move.l  BUF_SPRE,D0
                move.l  BUF_SPRE+4,D1
                move.l  D0,BUF_SPRE+4
                move.l  D1,BUF_SPRE
                move.l  BUF_SPRL,D0
                move.l  BUF_SPRL+4,D1
                move.l  D0,BUF_SPRL+4
                move.l  D1,BUF_SPRL
                move.l  BUF_SPR4,D0
                move.l  BUF_SPR4+4,D1
                move.l  D0,BUF_SPR4+4
                move.l  D1,BUF_SPR4
                move.l  BUF,D0
                move.l  BUF+4,D1
                move.l  D0,BUF+4
                move.l  D1,BUF
		MOVE.L	HARD_ECR,D0
		MOVE.L	HARD_ECR+4,D1
		MOVE.L	D1,HARD_ECR
		MOVE.L	D0,HARD_ECR+4
                bsr     HARD_GST
                move.b  ECR+1,$FF8201
                move.b  ECR+2,$FF8203
	IFEQ	TEST
	NOT.W	$FFFF8240.W
	ENDC
                rte
CALC_TABRST
	LEA	TAB_RST,A0
	LEA	RST1,A1
	MOVE.L	A0,A2
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVE.W	#69,D1
EFF_TABRST
	MOVEM.L	D2-D3,(A0)
	ADDQ.L	#8,A0
	DBRA	D1,EFF_TABRST
	MOVE.L	A2,A0
	LEA	V_RST,A3
	MOVEQ	#31,D7
TEST_RST
	MOVEM.W	(A3),D4-D5
	MOVEM.L	(A1)+,D0-D3
	MOVEM.L	D0-D3,(A0,D4.W)
	ADD.W	D5,D4
	CMP.W	#560,D4
	BLE.S	PAS_Y280
	MOVE.W	#0,D4
PAS_Y280
	MOVE.W	D4,(A3)
	ADDQ.L	#4,A3
	DBRA	D7,TEST_RST
	RTS

V_RST
	DC.W	0,2,70,2,140,2,210,2,280,2,350,2,420,2,490,2
	DC.W	0,4,70,4,140,4,210,4,280,4,350,4,420,4,490,4
	DC.W	0,6,70,6,140,6,210,6,280,6,350,6,420,6,490,6
	DC.W	0,8,70,8,140,8,210,8,280,8,350,8,420,8,490,8

DO_SPRITE:
                movea.l #TAB_CORD,A1
                movea.l A1,A5
                movea.l BUF_SPR4,A3
                lea     TAB_4,A2
                move.w  (A1)+,D0
                move.l  (A1)+,D1
                movea.l SCREEN,A0
                LEA	32(A0),A0
                adda.l  D1,A0
                movea.l 0(A2,D0.w),A1
                adda.l  4(A2,D0.w),A0
                movea.l A0,A4
                move.l  A0,(A3)+
                REPT 14
                movem.l (A0),D0-D3
                movem.l D0-D3,(A3)
                lea     16(A3),A3
                lea     160(A0),A0
                ENDR
                movea.l A4,A0
                jsr     (A1)
                movea.l A5,A1
                lea     120(A1),A1
                movea.l A1,A5
                movea.l BUF_SPRL,A3
                lea     TAB_L,A2
                move.w  (A1)+,D0
                move.l  (A1)+,D1
                movea.l SCREEN,A0
                LEA	32(A0),A0
                adda.l  D1,A0
                movea.l 0(A2,D0.w),A1
                adda.l  4(A2,D0.w),A0
                movea.l A0,A4
                move.l  A0,(A3)+
                REPT 14
                movem.l (A0),D0-D3
                movem.l D0-D3,(A3)
                lea     16(A3),A3
                lea     160(A0),A0
                ENDR
                movea.l A4,A0
                jsr     (A1)

                movea.l A5,A1
                lea     120(A1),A1
                movea.l A1,A5
                movea.l BUF_SPRE,A3
                lea     TAB_E,A2
                move.w  (A1)+,D0
                move.l  (A1)+,D1
                movea.l SCREEN,A0
                LEA	32(A0),A0
                adda.l  D1,A0
                movea.l 0(A2,D0.w),A1
                adda.l  4(A2,D0.w),A0
                movea.l A0,A4
                move.l  A0,(A3)+
                REPT 14
                movem.l (A0),D0-D3
                movem.l D0-D3,(A3)
                lea     16(A3),A3
                lea     160(A0),A0
                ENDR
                movea.l A4,A0
                jsr     (A1)
                movea.l A5,A1
                lea     120(A1),A1
                movea.l BUF_SPRD,A3
                lea     TAB_D,A2
                move.w  (A1)+,D0
                move.l  (A1)+,D1
                movea.l SCREEN,A0
                LEA	32(A0),A0
                adda.l  D1,A0
                movea.l 0(A2,D0.w),A1
                adda.l  4(A2,D0.w),A0
                movea.l A0,A4
                move.l  A0,(A3)+
                REPT 15
                movem.l (A0),D0-D3
                movem.l D0-D3,(A3)
                lea     16(A3),A3
                lea     160(A0),A0
                ENDR
                movea.l A4,A0
                jsr     (A1)
                addi.l  #18,DO_SPRITE+2
                cmpi.l  #FCORD,DO_SPRITE+2
                bne.s   PAS_FCORD
                move.l  #TAB_CORD,DO_SPRITE+2
PAS_FCORD:
                rts
EFF_SPR:
                movea.l BUF_SPRD,A1
                movea.l (A1)+,A0
                REPT 15
                movem.l (A1)+,D0-D3
                movem.l D0-D3,(A0)
                lea     160(A0),A0
                ENDR
                movea.l BUF_SPRE,A1
                movea.l (A1)+,A0
                REPT 14
                movem.l (A1)+,D0-D3
                movem.l D0-D3,(A0)
                lea     160(A0),A0
                ENDR
                movea.l BUF_SPRL,A1
                movea.l (A1)+,A0
                REPT 14
                movem.l (A1)+,D0-D3
                movem.l D0-D3,(A0)
                lea     160(A0),A0
                ENDR
                movea.l BUF_SPR4,A1
                movea.l (A1)+,A0
                REPT 14
                movem.l (A1)+,D0-D3
                movem.l D0-D3,(A0)
                lea     160(A0),A0
                ENDR
                rts

******** OFFSET=>230;256;204;186;160;54;0 ********

L_230:          move.b  D1,(A1)         ;GAUCHE
                nop
                nop
                move.b  D0,(A1)

                REPT 89
                nop
                ENDR

                move.b  D0,(A0)         ;DROITE ;A0
                nop
                move.b  D1,(A0)

                REPT 12
                nop
                ENDR

                move.b  D1,(A1)         ;A1
                nop
                move.b  D0,(A1)         ;A1

                REPT 2
                nop
                ENDR
                rts

L_204:          REPT 95
                nop
                ENDR

                move.b  D0,(A0)         ;DROITE ;A0
                nop
                move.b  D1,(A0)

                REPT 12
                nop
                ENDR

                move.b  D1,(A1)         ;A1
                nop
                nop
                move.b  D0,(A1)         ;A1

                REPT 1
                nop
                ENDR
                rts


L_158:          REPT 89+2+4-3
                nop
                ENDR

                move.b  D0,(A0)         ;DROITE ;A0
                nop
                move.b  D1,(A0)

                REPT 12
                nop
                ENDR

                nop
                nop
                nop
                nop
                nop

                REPT 2+3
                nop
                ENDR
                rts

L_186:          move.b  D1,(A1)         ;GAUCHE
                nop
                nop
                move.b  D0,(A1)

                REPT 113
                nop
                ENDR
                rts

L_160:          REPT 119
                nop
                ENDR
                rts

L_054:          REPT 41
                nop
                ENDR

                move.b  D1,(A1)         ;GAUCHE
                nop
                nop
                move.b  D0,(A1)

                REPT 72
                nop
                ENDR
                rts

L_000:          REPT 8
                nop
                ENDR

                move.b  D1,(A1)
                nop
                move.b  D0,(A1)

                REPT 106
                nop
                ENDR
                rts

*************** GESTION DU HARD *************
HARD_GST:
	MOVE.L	#TAB_H,A0
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVE.W	(A0)+,D2
	MOVE.L	(A0)+,D1
	MOVE.W	D2,D3
	DIVU	#26,D3
	MOVE.L	D1,D4
	DIVU	#160,D4
	ADD.L	D3,D4
	ADD.L	D4,D4
	ADD.L	D4,D4
	MOVE.L	#RASTERS02,A1
	SUB.L	D4,A1
	MOVE.L	A1,PEK_RST+2

	CMP.L	#FIN_TABH,A0
	BNE.S	PAS_FTABH
	MOVE.L	#TAB_H,A0
PAS_FTABH
	MOVE.L	A0,HARD_GST+2


                lea     C000,A1         ;AUTOMODIFIE POUR VERTICAL(C000;C160;C320 ECT...)
                adda.w  D2,A1

                move.l  (A1)+,L1+2
                move.l  (A1)+,L2+2
                move.l  (A1)+,L3+2
                move.l  (A1)+,L4+2
                move.l  (A1)+,L5+2
                move.l  (A1)+,L6+2

                move.l  HARD_ECR+4,D6
	SUB.L	#3*256,D6
                add.w   (A1)+,D6
                sub.l   D1,D6
                move.l  D6,ECR

NOK:            rts

BUF_SPRD:
                DC.L BUFD1,BUFD2
BUFD1:
                DC.L ECRAN-160*16
                DS.B 256
BUFD2:
                DC.L ECRAN-160*16
                DS.B 256
BUF_SPRE:
                DC.L BUFE1,BUFE2
BUFE1:
                DC.L ECRAN-160*16
                DS.B 256
BUFE2:
                DC.L ECRAN-160*16
                DS.B 256
BUF_SPRL:
                DC.L BUFL1,BUFL2
BUFL1:
                DC.L ECRAN-160*16
                DS.B 256
BUFL2:
                DC.L ECRAN-160*16
                DS.B 256
BUF_SPR4:
                DC.L BUF41,BUF42
BUF41:
                DC.L ECRAN-160*16
                DS.B 256
BUF42:
                DC.L ECRAN-160*16
                DS.B 256
EQUA:
                movea.l #VOLTAB,A0
                clr.l   D1
                clr.l   D0
                move.b  #0,$FF8800
                move.b  $FF8800,D1
                lsl.w   #4,D1
                move.b  #1,$FF8800
                add.b   $FF8800,D1
                and.w   #$0FFF,D1
                divu    #51,D1
                move.b  #8,$FF8800
                move.b  $FF8800,D0
                and.w   #$0F,D0
                tst.b   D0
                bne.s   SEQ1
                move.b  #1,D0
SEQ1:           move.b  D0,0(A0,D1.w)
                clr.l   D1
                clr.l   D0
                move.b  #2,$FF8800
                move.b  $FF8800,D1
                lsl.w   #4,D1
                move.b  #3,$FF8800
                add.b   $FF8800,D1
                and.w   #$0FFF,D1
                divu    #51,D1
                move.b  #9,$FF8800
                move.b  $FF8800,D0
                and.w   #$0F,D0
                tst.b   D0
                bne     SEQ2
                move.b  #1,D0
SEQ2:           move.b  D0,0(A0,D1.w)
                clr.l   D1
                clr.l   D0
                move.b  #4,$FF8800
                move.b  $FF8800,D1
                lsl.w   #4,D1
                move.b  #5,$FF8800
                add.b   $FF8800,D1
                and.w   #$0FFF,D1
                divu    #51,D1
                move.b  #10,$FF8800
                move.b  $FF8800,D0
                and.w   #$0F,D0
                tst.b   D0
                bne     SEQ3
                move.b  #1,D0
SEQ3:           move.b  D0,0(A0,D1.w)
                lea     VOLTAB,A0
                lea     TAB_VOL,A2
                movea.l SCREEN,A1
                LEA	38(A1),A1
                move.w  #79,D7
AFF_EQUA:
                moveq   #0,D1
                moveq   #0,D2
                move.b  (A0),D1
                beq.s   NEXT
                move.b  D1,D2
                add.w   D2,D2
                move.w  0(A2,D2.w),D2
                move.w  D2,(A1)
                move.w  D2,160(A1)
                move.w  D2,320(A1)
                subq.b  #1,D1
                move.b  D1,(A0)
NEXT:
                addq.w  #1,A0
                lea     640(A1),A1
                dbra    D7,AFF_EQUA
                rts

NBSTAR          EQU 53

STAR:
                movea.l BUF,A0
                lea     52*6(A0),A0
                movea.l SCREEN,A1
                lea     104(A1),A1
                moveq   #0,D0
                move.w  #NBSTAR-1,D6
EFF_STAR:
                move.l  (A0),D2
                move.w  4(A0),D0
                move.w  D0,0(A1,D2.l)
                subq.l  #6,A0
                dbra    D6,EFF_STAR

                lea     TAB_POS,A0
                movea.l SCREEN,A1
                lea     104(A1),A1
                movea.l BUF,A2
                move.w  #NBSTAR-1,D6
NB_STAR:
                move.w  (A0),D0
                move.l  2(A0),D1
                move.l  6(A0),D2
	MOVE.L	D1,D3
	AND.W	#$FFF8,D3
                move.w  0(A1,D3.l),D5
	OR.W	2(A1,D3.L),D5
	OR.W	4(A1,D3.L),D5
	OR.W	6(A1,D3.L),D5
                not.w   D5
                and.w   D0,D5
                move.w  0(A1,D1.l),D7
                or.w    D5,0(A1,D1.l)
                move.l  D1,(A2)+
                move.w  D7,(A2)+
                add.l   D2,D1
                cmp.l   #320*160,D1
                blt.s   INF_295
                sub.l   #320*160,D1
INF_295:
                move.l  D1,2(A0)
                lea     10(A0),A0
                dbra    D6,NB_STAR
                rts
CPTR2:
                DC.W 1

SCROLL:
                subq.w  #1,CPTR2
                bne.s   SUITE_SCROLL
                move.w  #8,CPTR2
                bsr     NEW_LET
SUITE_SCROLL:
                bsr     ADD_LET
                rts
NEW_LET:
                movea.l #MESS2,A0
                moveq   #0,D0
                move.b  (A0),D0
                beq.s   FIN_MESS
                sub.b   #' ',D0
                add.w   D0,D0
                add.w   D0,D0
                lea     TABLET,A0
                movea.l 0(A0,D0.w),A1
                lea	    40*15(a1),A1
                move.l  A1,PEKLET+2
                addq.l  #1,NEW_LET+2
                rts
FIN_MESS:
                move.l  #MESS2,NEW_LET+2
                bra.s   NEW_LET
ADD_LET:
                movea.l #TAB_DEF,A4
                movea.l SCREEN,A0
                adda.l  #56+318*160,A0
                movea.l SCREEN+4,A2
                adda.l  #56+318*160,A2
PEKLET:
                movea.l #$12345678,A1
                moveq  #79,D7
DECAL:
                move.L  -320(A2),(A0)
                move.L  -312(A2),8(A0)
                move.L  -480(A2),-160(A0)
                move.L  -472(A2),-152(A0)
                move.L  -640(A2),-320(A0)
                move.L  -632(A2),-312(A0)
                move.L  -800(A2),-480(A0)
                move.L  -792(A2),-472(A0)
                lea     -640(A0),A0
                lea     -640(A2),A2
                dbra    D7,DECAL
                movea.l SCREEN,A0
                lea     56(A0),A0
                moveq   #0,D1
                move.w  (A4)+,D1
                moveq   #0,D0
                move.w  (A1),D0
                swap    D0
                lsr.l   D1,D0
                move.w  D0,168(A0)
                MOVE.W  D0,170(A0)
                swap    D0
                move.w  D0,160(A0)
                move.w  D0,162(A0)
                moveq   #0,D0
                moveq   #0,D1
                move.w  (A4)+,D1
                move.w  -40(A1),D0
                swap    D0
                lsr.l   D1,D0
                move.w  D0,8(A0)
                move.w  D0,10(A0)
                swap    D0
                move.w  D0,(A0)
                move.w  D0,2(A0)
                subi.l  #80,PEKLET+2
                addi.l  #4,ADD_LET+2
                cmpi.l  #FIN_DEF,ADD_LET+2
                bne.s   PAS_FDEF
                move.l  #TAB_DEF,ADD_LET+2
PAS_FDEF:
                rts

OVR_HAUT:
                stop    #$2100
                stop    #$2100
                move    #$2700,SR

	MOVEM.L	D0-D2/A0-A1/A3,-(SP)	* 14

                lea     $FFFF820A.w,A0
                lea     $FFFF8260.w,A1
		LEA $FFFF8240.W,A3
                moveq   #0,D0
                moveq   #0,D2
	REPT	8
	MOVE.L	D0,(A3)+	* 8*3=24
	ENDR
                DCB.W 62-24,$4E71
                move.b  D0,(A0)
                DCB.W 10,$4E71
                move.w  A0,(A0)
                DCB.W 20,$4E71
                lea     $FFFF8209.w,A3		*2
                sub.b   (A3),D2
                lsl.l   D2,D2
                clr.b   $FFFFFA1B.w
                moveq   #2,D1

                DCB.W 63,$4E71

L1:             jsr     L_054
L2:             jsr     L_054
L3:             jsr     L_158
L4:             jsr     L_158
L5:             jsr     L_186
L6:             jsr     L_158

                clr.b   $FFFA1B
                move.b  #1,$FFFA21
                move.b  #8,$FFFA1B
                move.l  #HBL_03,$0120.w
                move.l  A6,-(SP)
PEK_RST
                MOVE.L	#RASTERS02,A6
                move    A6,USP
                movea.l (SP)+,A6
	MOVEM.L	(SP)+,D0-D2/A0-A1/A3
	MOVEM.L	D0-D7,-(SP)
	MOVEM.L	PAL_IMG,D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W
	MOVEM.L	(SP)+,D0-D7
                move    #$2300,SR
                rte
HBL_03:
                move.l  A6,-(SP)
PEK_TAB
	MOVE.L	#TAB_RST,A6
	MOVE.W	(A6)+,$FFFF8252.W
	MOVE.L	A6,PEK_TAB+2
                move    USP,A6
                move.w  (A6)+,$FFFF825E.w
                move.w  (A6)+,$FFFF8246.w
                move    A6,USP
                move.l (SP)+,A6
                addq.w  #1,CPTR
                cmpi.w  #219,CPTR
                beq.s   FIN_HBL
                rte
FIN_HBL:
                clr.b   $FFFA1B
                move.b  #2,$FFFA21
                move.b  #8,$FFFA1B
                move.l  #HBL_02,$0120.w
                move.w  #0,CPTR
	MOVE.L	PEK_TAB+2,PEK_TAB2+2
                rte
CPTR:
                DC.W 0
HBL_02:
timer2
	move.w	#$2700,sr
	MOVEM.L	D0/A0,-(SP)
          move.l  A6,-(SP)
          move    USP,A6
          move.w  (A6)+,$FFFF825E.w
                move.w  (A6)+,$FFFF8246.w
          move    A6,USP
          movea.l (SP)+,A6

	lea	$fffffa21.w,a0
	move.b	(a0),d0
sync	cmp.b	(a0),d0
	beq.s	sync
	bclr	#1,$ff820a
	rept	10
	nop
	endr
	bset	#1,$ff820a
          move.l  A6,-(SP)
          move    USP,A6
          move.w  (A6)+,$FFFF825E.w
                move.w  (A6)+,$FFFF8246.w
          move    A6,USP
          movea.l (SP)+,A6
	movem.l	(sp)+,d0/a0
	clr.b	$fffffa1b
	MOVE.B 	#1,$FFFA21
	MOVE.B	#8,$FFFA1B
	MOVE.L	#HBL_04,$120.W
	rte
HBL_04:
                move.l  A6,-(SP)
PEK_TAB2
	MOVE.L	#TAB_RST,A6
	MOVE.W	(A6)+,$FFFF8252.W
	MOVE.L	A6,PEK_TAB2+2
                move    USP,A6
                move.w  (A6)+,$FFFF825E.w
                move.w  (A6)+,$FFFF8246.w
                move    A6,USP
                moveM.l (SP)+,A6
                rte

                DATA

                IFEQ FINAL
MSK:
                DC.W $00,$00,$00,$00,$00,$0380,$07C0,$07C0
                DC.W $07C0,$0380,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$03C0,$07E0,$0FF0,$0FF0
                DC.W $0FF0,$0FF0,$07E0,$03C0,$00,$00,$00,$00
                DC.W $00,$00,$00,$03C0,$0FF0,$0FF0,$1FF8,$1FF8
                DC.W $1FF8,$1FF8,$0FF0,$0FF0,$03C0,$00,$00,$00
                DC.W $00,$00,$07E0,$0FF0,$1FF8,$3FFC,$3FFC,$3FFC
                DC.W $3FFC,$3FFC,$3FFC,$1FF8,$0FF0,$07E0,$00,$00
                DC.W $00,$07E0,$0FF0,$1FF8,$3FFC,$7FFE,$7FFE,$7FFE
                DC.W $7FFE,$7FFE,$7FFE,$3FFC,$1FF8,$0FF0,$07E0,$00
                DC.W $07E0,$1FF8,$3FFC,$7FFE,$7FFE,$FFFF,$FFFF,$FFFF
                DC.W $FFFF,$FFFF,$FFFF,$7FFE,$7FFE,$3FFC,$1FF8,$07E0
                DC.W $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
                DC.W $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
FIN_MSK:
                ENDC
SCREEN:
                DC.L ECRAN,$080000
SPRITE:
                INCBIN 'SPRIT.IMG'
                DS.W 500
                IFEQ FINAL
MESS:
                DC.B ' OH YEAAH MAGNUM IS ',1
                DC.B '   BACK WITH A NEW  ',1
                DC.B '       SCREEN !!!   ',1,1
                DC.B '  IT WAS CODED BY : ',1
                DC.B '       MAGNUM       ',1
                DC.B '   GFX BY ZORGLUB   ',1
                DC.B '   IDEA BY MAGNUM   ',1
                DC.B '   MUSAX BY MADMAX  ',1
                DC.B '    HELLO TO MIT !! ',2

                DC.B ' IN THIS SCREEN YOU ',1
                DC.B '      WILL SEE :    ',1
                DC.B 'SOME RIGHT AND LEFT ',1
                DC.B 'OVERSCAN, VERTICAL  ',1
                DC.B 'RASTERS, A ONE PIXEL',1
                DC.B 'HARDSCROLL WITH ONLY',1
                DC.B 'ONE SCREEN. A DEFORM',1
                DC.B '   IN Y (ONE PIXEL) ',1
                DC.B '      AND LOTSA     ',1
                DC.B 'IMPRESSIVE THINGS ! ',1
                DC.B '   ( AHAHAHAH !)    ',2,0
                ENDC
                EVEN
MESS2:
                DC.B "      GNARF GNARF GNARF    I GOT YOU FUCKING BASTARDS...    "
                DC.B "  NOW WE'RE WATCHING A MOVIE CALLED 'SPLASH' (NOT BEURGHHH AS ZORGLUB SAID)"
                DC.B " IT IS EXACTLY 21:24:07 AND I'VE NOT DRINKED A BEER SINCE FIVE HOURS SO I DONT'T KNOW "
                DC.B "WHAT TO WRITE. I THINK I'M GOING TO TELL YOU ABOUT TURBO-PASCAL..."
                DC.B "IT'S A  SHIT. I MUST WRITE A PROGRAMM FOR SOMEBODY IN THIS LANGUAGE, BUT"
                DC.B " I'D PREFER DO IT IN C.. I'M TOTALLY OUT OF IDEA. IT'S HORRIBLE..."
                DC.B " I'M GOING TO SPEAK ABOUT A NEW FRIEND OF M.C.S. : MIT (YES MIT FROM NEXT !!!)."
                DC.B "    HE'S A VERY COOL GUY AND COMES EVERY WEEKEND TO SEE US (HUM HUM TO SEE BENEDICTE !!) "
                DC.B " (BY THE WAY BENEDICTE IS MIT'S GIRLFRIEND).  HE'S NOT HAPPY COZ OTHER MEMBERS"
                DC.B " OF NEXT CAN'T GO OUT WITH HIM TO DRINK AND TO SEE MANY GIRLS. "
                DC.B "  WE CAN SAY WE ARE THE BEST IN THE WHOLE UNIVERSE. THE BEST IN MAKING PARTY, DRINKING, AND JOKING, ETC."
                DC.B " NOT LIKE THESE FUCKING OVERSUCKERS !! "
                DC.B " FUCK TO ST CONNECTION FOR GIVING THE FULLSCREEN SOURCE IN ST-MAG. "
                DC.B " FUCK TO PENDRAGONS COZ THEY HAVEN'T FINISH TO RIP THE CODE FOR MAKING THE MENU OF THE TRANSBEAUCE 2 DISK 1."
                DC.B "  FUCK TO DOGUE DE MAUVE FOR MAKING A SO BAD MENU FOR THE TRANSBEAUCE 2 DISK 2"
                DC.B " (I COULD HAVE DONE IT WITH D.C.K.  PERHAPS HAVE YOU DONE IT IN STOS ??? OR IN GFA ???). "
                DC.B " HELLO AND GREETINGS TO : NEXT , THE BLACK CATS, GENESIS (I HAVEN'T HEARD OF YOU SINCE THE TRANS 2.) , "
                DC.B " THE MISFITS (ARE YOU ALWAYS SO BOURRIN ??) , T.S.B. (IKI,JUDGE DREDD) , FASHION , MICRO VIDEO (THE VECTORBALL WAS FIRSTLY NAMED"
                DC.B " : T.M.V (THANX MICRO VIDEO)). OK YOU HAVE PERHAPS NOTICED THAT I NEVER GREET "
                DC.B "CREWS LIKE DELTA FORCE, TCB, ETC. BUT WE DON'T KNOW THEM PERSONNALY"
                DC.B " SO THEY DON'T CARE OF OUR GREETINGS...  "
                DC.B " I'M A LITLLE TIRED SO I GIVE THE KEYBOARD TO ZORGLUB (THE LAZIEST GFX MAN IN THE WORLD). "
                DC.B " ZORG ON THE KEYBOARD!! FIRST OF ALL:I'M NOT THE LAZIEST GFX MAN ON THE WORLD:I AM THE SECOND AFTER "
                DC.B " KRAZY REX(KRAJY RECHE) OF THE ST-CORNICHONS ..WELL WELL!! WHAT COULD I SAY?"
                DC.B " HERE ARE THE SUBNAMES WE FOUND FOR THE DEL 4:'OBJECTIF 0 (THE WORST DEMO SO FAR)'"
                DC.B " OR L'ADEL SCOTT OR 'WHAT CRAPAUD DEV. CAN'T DO' OR '..............(TYPE IN THE NAME YOU WANT)'"
                DC.B " LET'S GO FOR A DELIRIOUS SCROLL AS EVER IF YOU READ THE OTHERS....LET ME TELL YOU"
                DC.B " ABOUT OUR  LAST FRIDAY AND SATURDAY NIGHTS (OUH LA LA)...FIRST FRIDAY,20TH OF SEPTEMBER 1991"
                DC.B " :WE WERE AT A PARTY ORGANIZED BY A FRIEND FOR HIS BIRTHDAY,IT WAS IN THOUARE"
                DC.B " (WE LOVE THIS TOWN!!).FIRST WE PAID 40FRS TO ENTER BUT THEN WE HAD DRINKS AS MUCH AS WE WANTED"
                DC.B " (AND YOU KNOW THAT TO LET US ALCOOL IS A BIG MADNESS !! ESPECIALLY WHEN MAGNUM AND PF ARE WITH US)"
                DC.B " ANOTHER THING:WE WAITED FOR GADGET A COUPLE OF HOURS BEFORE HE ARRIVED:HE DROVE 70 KM BEFORE FINDING THE PARTY!!"
                DC.B " AND IT WAS AT ONLY 20 KM FROM HIS HOME !! ARF ARF! THE BETTER AND THE WORST THING THAT ARRIVED US"
                DC.B " THIS NIGHT WAS THAT THE DREAMER WAS DRUNK (REALLY DRUNK,NOT AS MAGNUM AT THE TRANS 2) FOR THE FIRST TIME"
                DC.B " YES FOR THE FIRST TIME:NOW HE HIS REALLY A MEMBER OF MCS..HE DRUNK SO MUCH THAT MAGNUM AND PF HAD TO SUPPORT HIM. THEN SOME "
                DC.B "PEOPLE LAUGHED AT THE DREAMER AND MAGNUM DIDN'T LIKED THAT. SO HE WANTED TO HIT EVERYBODY THERE "
                DC.B " AND WE HAD TO LEAVE THE PARTY BEFORE A GENERAL FIGHT BEGAN. THEN WE PUT HIM IN A BED AND WE SLEPT."
                DC.B " THE SATURDAY MORNING, THE DREAMER SPEWED FOUR TIME. THE HE WAKED UP AT 3:00 PM."
                DC.B "  HE SAID : I'LL NEVER DRINK SO MUCH AGAIN."
                DC.B " NOW THE SATURDAY NIGHT : IT WAS ZORGLUB'S NIGHT.. HE TRIED WITH TWO GIRLS, AND NONE OF THEM WANTED..."
                DC.B "P.F. DRUNK A LOT. MAGNUM TOO. THE DREAMER DRUNK COKE (AS THE HOOLIGAN). MIT DRUNK PASSOA (2 BOTTLES) "
                DC.B "AND ZORGLUB MADE TEN PIXELS.. IT FINISHED AT 5:00 AM. THE DAY AFTER MIT HAD A BIG HANGOVER (AS BENEDICTE"
                DC.B " WHO WAS COMPLETLY DRUNK). AXEL FOLLET'S BROTHER WENT TO BED WITH TWO GIRLS (AXEL F. WAS ANGRY)"
                DC.B ". AND WE DO IT AGAIN NEXT WEEK.. YOU CAN IMAGINE HOW OUR NIGHTS ARE !!!"
                DC.B "   OK NOW SOME BULLSHIT... "
                DC.B "  LOTSA PEOPLE THOUGHT WE WERE LAMERS..  I HOPE THAT THIS DEMO SHOW YOU THE CONTRARY.."
                DC.B "    HAVE YOU READ ALL THE SCROLLTEXT OF THE BIGSCROLL ?? IF YES YOU KNOW WHERE THE HIDDEN SCREEN IS ..."
                DC.B "  OK I'VE WRITTEN SO MUCH SCROLL THESE LAST DAYS THAT I'VE NO MORE IDEAS OF WHAT TO WRITE...  "
                DC.B " OK I STOP HERE FOR NOW !!! OK SEE YOU LETTER AND FUCK TO OVERLANDERS....          LET'S WRAPPPPPPPPPPPPPPPPPPPPPPPPPPPPP"
                EVEN
                IFEQ FINAL
BOUTEILLE:
                INCBIN '90DEG.PI1'
RASTERS01:
                DC.W 0,$0111,$0222,$0333,$0444,$0555,$0666,$0777,$37,$27,$17
                DC.W $06,$05,$67,$07,$0606

                DC.W 0,$00,$0111,$0222,$0333,$0444,$0555,$0666,$26,$16,$07
                DC.W $05,$04,$56,$06,$0505

                DC.W 0,$00,$00,$0111,$0222,$0333,$0444,$0555,$15,$05,$06
                DC.W $04,$03,$45,$05,$0404

                DC.W 0,$00,$00,$00,$0111,$0222,$0333,$0444,$04,$04,$05
                DC.W $03,$02,$34,$04,$0303

                DC.W 0,$00,$00,$00,$00,$0111,$0222,$0333,$03,$03,$04
                DC.W $02,$01,$23,$03,$0202

                DC.W 0,$00,$00,$00,$00,$00,$0111,$0222,$02,$02,$03
                DC.W $01,$00,$12,$02,$0101

                DC.W 0,$00,$00,$00,$00,$00,$00,$0111,$01,$01,$02
                DC.W $00,$00,$01,$01,$00

                DC.W 0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
                DC.W $00,$00,$00,$00,$00

                DS.W 16
                ENDC

RST_MAG
	INCBIN	RST2.HBL

RASTERS02:	EQU	RST_MAG+400

TAB_RST
	DCB.W	300,$0
PAL_FNT:
                DC.W $00,$0300,$0400,$0510,$0520,$0630,$0640,$0FD0
                DC.W $0111,$0222,$0333,$0444,$0555,$70,$07,$0F
RST1
	DC.W	$110,$220,$330,$440,$440,$330,$220,$110
	DC.W	$110,$220,$330,$440,$440,$330,$220,$110
	DC.W	$110,$220,$330,$440,$440,$330,$220,$110
	DC.W	$110,$220,$330,$440,$440,$330,$220,$110
	DC.W	$110,$220,$330,$440,$440,$330,$220,$110
	DC.W	$110,$220,$330,$440,$440,$330,$220,$110
	DC.W	$110,$220,$330,$440,$440,$330,$220,$110
	DC.W	$110,$220,$330,$440,$440,$330,$220,$110

	DC.W	$10,$20,$30,$40,$40,$30,$20,$10
	DC.W	$10,$20,$30,$40,$40,$30,$20,$10
	DC.W	$10,$20,$30,$40,$40,$30,$20,$10
	DC.W	$10,$20,$30,$40,$40,$30,$20,$10
	DC.W	$10,$20,$30,$40,$40,$30,$20,$10
	DC.W	$10,$20,$30,$40,$40,$30,$20,$10
	DC.W	$10,$20,$30,$40,$40,$30,$20,$10
	DC.W	$10,$20,$30,$40,$40,$30,$20,$10

	DC.W	$100,$200,$300,$400,$400,$300,$200,$100
	DC.W	$100,$200,$300,$400,$400,$300,$200,$100
	DC.W	$100,$200,$300,$400,$400,$300,$200,$100
	DC.W	$100,$200,$300,$400,$400,$300,$200,$100
	DC.W	$100,$200,$300,$400,$400,$300,$200,$100
	DC.W	$100,$200,$300,$400,$400,$300,$200,$100
	DC.W	$100,$200,$300,$400,$400,$300,$200,$100
	DC.W	$100,$200,$300,$400,$400,$300,$200,$100

	DC.W	$101,$202,$303,$404,$404,$303,$202,$101
	DC.W	$101,$202,$303,$404,$404,$303,$202,$101
	DC.W	$101,$202,$303,$404,$404,$303,$202,$101
	DC.W	$101,$202,$303,$404,$404,$303,$202,$101
	DC.W	$101,$202,$303,$404,$404,$303,$202,$101
	DC.W	$101,$202,$303,$404,$404,$303,$202,$101
	DC.W	$101,$202,$303,$404,$404,$303,$202,$101
	DC.W	$101,$202,$303,$404,$404,$303,$202,$101
PAL:
                DS.W 16
                IFEQ FINAL
FNT2:
                INCBIN 'FNT.IMG'
SPACE           EQU FNT2+160*16*2+8*6

TAB_FNT:
                DC.L SPACE
                DC.L FNT2+160*16+8*6
                DC.L FNT2+160*16+8*7
                DC.L SPACE
                DC.L SPACE,SPACE,SPACE
                DC.L FNT2+160*16+8*8
                DC.L FNT2+160*16+8*10
                DC.L FNT2+160*16+8*11
                DC.L SPACE,SPACE
                DC.L FNT2+160*16+8*12
                DC.L FNT2+160*16+8*9
                DC.L FNT2+160*16+8*13
                DC.L SPACE
                DC.L SPACE+160*16+8*16
                DC.L SPACE+160*16+8*17
                DC.L SPACE+160*16+8*18
                DC.L SPACE+160*16+8*19
                DC.L FNT2+160*16*2
                DC.L FNT2+160*16*2+8
                DC.L FNT2+160*16*2+8*2
                DC.L FNT2+160*16*2+8*3
                DC.L FNT2+160*16*2+8*4
                DC.L FNT2+160*16*2+8*5
                DC.L FNT2+160*16+8*14
                DC.L SPACE
                DC.L SPACE,SPACE,SPACE
                DC.L FNT2+160*16+8*15
                DC.L SPACE
                DC.L FNT2,FNT2+8,FNT2+8*2,FNT2+8*3,FNT2+8*4
                DC.L FNT2+8*5,FNT2+8*6,FNT2+8*7,FNT2+8*8,FNT2+8*9
                DC.L FNT2+8*10,FNT2+8*11,FNT2+8*12,FNT2+8*13,FNT2+8*14
                DC.L FNT2+8*15,FNT2+8*16,FNT2+8*17,FNT2+8*18,FNT2+8*19
                DC.L FNT2+160*16
                DC.L FNT2+160*16+8
                DC.L FNT2+160*16+8*2
                DC.L FNT2+160*16+8*3
                DC.L FNT2+160*16+8*4
                DC.L FNT2+160*16+8*5
                ENDC
TAB_VOL:
                DC.W %0
                DC.W %1
                DC.W %11
                DC.W %111
                DC.W %1111,%11111,%111111
                DC.W %1111111
                DC.W %11111111
                DC.W %111111111
                DC.W %1111111111
                DC.W %11111111111
                DC.W %111111111111
                DC.W %1111111111111
                DC.W %11111111111111
                DC.W %111111111111111
                DC.W %1111111111111111
FOND:
                INCBIN 'COPYB2.IMG'
                INCBIN 'COPYB4.IMG'
BUF:
                DC.L BUF1,BUF2
TAB_POS:
                DC.W 32768
                DC.L 6,3*160
                DC.W 8192
                DC.L 80*160+2,4*160
                DC.W 2048
                DC.L 4+160*160,5*160
                DC.W 512
                DC.L 4+160*20,160*4
                DC.W 128
                DC.L 160*50,160*9
                DC.W 32
                DC.L 6+160*150,160*11
                DC.W 8
                DC.L 2+160*80,160*7
                DC.W 2
                DC.L 4+160*200,160*13
                DC.W 1
                DC.L 2+160*140,160*3
                DC.W 32768
                DC.L 8+160*128,160*5
                DC.W 8192
                DC.L 10,160*10
                DC.W 2048
                DC.L 14+160*90,160*9
                DC.W 512
                DC.L 14+160*198,160*3
                DC.W 128
                DC.L 12+160*100,160*4
                DC.W 32
                DC.L 8+160*174,160*6
                DC.W 8
                DC.L 14+160*76,160*7
                DC.W 2
                DC.L 10+160*80,160*6
                DC.W 1
                DC.L 12+160*180,160*12
                DC.W 32768
                DC.L 20+160*200,160*3
                DC.W 8192
                DC.L 16+160*150,160*3
                DC.W 2048
                DC.L 22+160*30,160*4
                DC.W 512
                DC.L 18+160*146,160*6
                DC.W 128
                DC.L 20+160*122,160*3
                DC.W 32
                DC.L 18+160*242,160*6
                DC.W 8
                DC.L 16+160*154,160*10
                DC.W 2
                DC.L 18+160*256,160*2
                DC.W 1
                DC.L 22+160*88,160*11
                DC.W 32768
                DC.L 30+160*68,160*4
                DC.W 8192
                DC.L 28+160*256,160*9
                DC.W 2048
                DC.L 24+160*94,160*4
                DC.W 512
                DC.L 30+160*76,160*10
                DC.W 128
                DC.L 26+160*80,160*3
                DC.W 32
                DC.L 28+160*180,160*4
                DC.W 8
                DC.L 26+160*200,160*5
                DC.W 2
                DC.L 24+160*150,160*4
                DC.W 1
                DC.L 26+160*30,160*9
                DC.W 32768
                DC.L 40+160*146,160*11
                DC.W 8192
                DC.L 40+160*122,160*7
                DC.W 2048
                DC.L 36+160*242,160*13
                DC.W 512
                DC.L 32+160*12,160*3
                DC.W 128
                DC.L 34+160*216,160*5
                DC.W 32
                DC.L 36+160*88,160*10
                DC.W 8
                DC.L 34+160*68,160*9
                DC.W 2
                DC.L 32+160*256,160*3
                DC.W 1
                DC.L 34+160*94,160*4
                DC.W 32768
                DC.L 46,160*4
                DC.W 8192
                DC.L 46+160*80,160*6
                DC.W 2048
                DC.L 44+160*160,160*3
                DC.W 512
                DC.L 40+160*20,160*4
                DC.W 128
                DC.L 46+160*50,160*5
                DC.W 32
                DC.L 42+160*150,160*4
                DC.W 8
                DC.L 44+160*60,160*9
                DC.W 2
                DC.L 42+160*200,160*11
PAL_IMG:
	dc.w	$0000,$0012,$0023,$0700,$0003,$0004,$0005,$000E
	dc.w	$0007,$077,$0045,$0222,$0333,$0444,$0034,$0FFF


FNT:
                DC.W $7FF0,$79E0,$F0F0,$07F0,$F6F0,$F600,$F7E0,$FFF0
                DC.W $F8F8,$7FE0,$8010,$F0,$FFF0,$FFF0,$7FE0,$7F00
                DC.W $7FA0,$7F00,$F3E0,$00,$FFF0,$FFF0,$F0F0,$0FF0
                DC.W $F6F0,$F600,$F7F0,$FFF0,$F8F8,$7FF0,$C030,$F0
                DC.W $FFF0,$FFF0,$FFF0,$FF80,$FF70,$FF80,$F7F0,$00
                DC.W $FFF0,$FFF0,$F0F0,$1FF0,$F6F0,$F600,$F7F0,$FFF0
                DC.W $F8F8,$7FF8,$E070,$F0,$FFF0,$FFF0,$FFF0,$FF80
                DC.W $FEE0,$FF80,$F7F0,$00,$FFF0,$EF70,$F0F0,$3EF0
                DC.W $F6F0,$F600,$F6F0,$FFF0,$F8F8,$7FF8,$F0F0,$F0
                DC.W $FFF0,$FFF0,$FFF0,$FF80,$FDD0,$FF90,$F6F0,$00
                DC.W $F380,$EF70,$F0F0,$7CF0,$F6F0,$F600,$F6F0,$0F00
                DC.W $F8F8,$7878,$F9F0,$F0,$7C00,$03F0,$F9F0,$F780
                DC.W $F9B0,$F7B0,$F6F0,$00,$FB80,$EF70,$F0F0,$F8F0
                DC.W $F6F0,$F600,$F6F0,$0F00,$FFF8,$7878,$FFE0,$F0
                DC.W $3E00,$07E0,$F9F0,$F780,$F970,$F7F0,$F6F0,$00
                DC.W $7F80,$EF70,$F0F0,$F0F0,$F6F0,$F600,$F6F0,$0F00
                DC.W $FFF8,$7878,$7FC0,$F0,$1F00,$0FC0,$F9F0,$F780
                DC.W $F8F0,$F7F0,$F6F0,$00,$3F80,$EF70,$F0F0,$F0F0
                DC.W $F6F0,$F600,$F6F0,$0F00,$FFF8,$7878,$3F80,$F0
                DC.W $0F80,$1F80,$F9F0,$F780,$F9F0,$F7E0,$F6F0,$00
                DC.W $1F80,$EF70,$F0F0,$F0F0,$F6F0,$F600,$F6F0,$0F00
                DC.W $FFF8,$7878,$1F00,$F0,$1F00,$3F00,$F9F0,$F780
                DC.W $F9F0,$F7C0,$F6F0,$00,$0F80,$EF70,$F0F0,$F0F0
                DC.W $F6F0,$F600,$F6F0,$0F00,$FFF8,$7878,$0F00,$F0
                DC.W $3E00,$7E00,$F9F0,$F780,$F9F0,$F780,$F6F0,$00
                DC.W $07C0,$EF70,$F0F0,$F0F0,$F6F0,$F600,$F0F0,$0F00
                DC.W $F8F8,$7878,$0F00,$F0,$7C00,$FC00,$F9F0,$F780
                DC.W $F9F0,$F780,$F6F0,$00,$03E0,$FFF0,$FFF0,$FFF0
                DC.W $FFF0,$FFF0,$FFF0,$FFF0,$F8F8,$7878,$FFF0,$FFF0
                DC.W $FFF0,$FFF0,$FFF0,$FFF0,$FFF0,$FFF0,$FEF0,$00
                DC.W $01F0,$FFF0,$FFF0,$FFF0,$FFF0,$FFF0,$FFF0,$FFF0
                DC.W $F8F8,$7878,$FFF0,$FFF0,$FFF0,$FFF0,$FFF0,$FFF0
                DC.W $FFF0,$FFF0,$FEF0,$00,$F0,$FFF0,$FFF0,$FFF0
                DC.W $FFF0,$FFF0,$FFF0,$FFF0,$F8F8,$7878,$FFF0,$FFF0
                DC.W $FFF0,$FFF0,$FFF0,$FFF0,$FFF0,$FFF0,$FEF0,$00
                DC.W $70,$FFF0,$7FE0,$FFF0,$7FE0,$7FF0,$7FE0,$FFF0
                DC.W $F8F8,$7878,$FFF0,$FFF0,$FFF0,$FFF0,$7FE0,$FFF0
                DC.W $7FE0,$FFF0,$7CF0,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $F000,$FFE0,$FFE0,$FFF0,$8010,$8000,$F0F0,$FFF0
                DC.W $7CF0,$7FE0,$0380,$F3E0,$F3E0,$FFF0,$79E0,$7FE0
                DC.W $00,$00,$0F00,$00,$F000,$FFF0,$FFF0,$FFF0
                DC.W $C030,$C000,$F8F0,$FFF0,$FEF0,$FFF8,$0380,$F7F0
                DC.W $F7F0,$FFF0,$FFF0,$FFF0,$00,$00,$0F00,$00
                DC.W $F000,$FFF0,$FFF0,$FFF0,$E070,$E000,$FCF0,$FFF0
                DC.W $FEF0,$FFF8,$0380,$F7F0,$F7F0,$FFF0,$FFF0,$FFF0
                DC.W $00,$00,$0F00,$00,$F000,$FFF0,$FFF0,$FFF0
                DC.W $F0F0,$F000,$FEF0,$FFF0,$FEF0,$FFF8,$0380,$F6F0
                DC.W $F6F0,$FFF0,$EF70,$FFF0,$00,$00,$0F00,$00
                DC.W $F000,$F0,$01F0,$03E0,$F9F0,$F800,$FFF0,$F000
                DC.W $F6F0,$F6F8,$3FF0,$F6F0,$F6F0,$F380,$EF70,$F6F0
                DC.W $F0F0,$3FC0,$0F00,$00,$FFF0,$F0,$03E0,$07C0
                DC.W $FFF0,$FC00,$FFF0,$F000,$F6F0,$F6F8,$3FF0,$F6F0
                DC.W $F6F0,$F380,$EF70,$F6F0,$F0F0,$7FE0,$0F00,$00
                DC.W $FFF0,$F0,$07C0,$0F80,$7FE0,$7E00,$FFF0,$F000
                DC.W $F6F0,$F6F8,$3FF0,$F6F0,$F6F0,$F380,$EF70,$F6F0
                DC.W $F0F0,$FFF0,$0F00,$00,$FFF0,$F0,$0F80,$1F00
                DC.W $3FC0,$3F00,$FFF0,$F800,$F6F0,$F6F8,$3FF0,$F6F0
                DC.W $F6F0,$F380,$EF70,$F6F0,$FFF0,$FFF0,$0F00,$00
                DC.W $FFF0,$F0,$1F00,$0F80,$1F80,$3F80,$FFF0,$7C00
                DC.W $F6F0,$F6F8,$0380,$F6F0,$F6F0,$F380,$EF70,$F6F0
                DC.W $FFF0,$F0F0,$0F00,$00,$FFF0,$F0,$3E00,$07C0
                DC.W $3FC0,$7FC0,$FFF0,$3E00,$F6F0,$F6F8,$0380,$F6F0
                DC.W $F6F0,$F000,$EF70,$F6F0,$7FE0,$F0F0,$0F00,$00
                DC.W $F000,$F0,$7C00,$03E0,$7FE0,$FFE0,$FFF0,$1E00
                DC.W $F6F0,$F6F8,$0380,$F6F0,$F6F0,$F000,$EF70,$F6F0
                DC.W $3FC0,$F0F0,$0F00,$00,$F000,$FFF0,$F800,$FFF0
                DC.W $FFF0,$FFF0,$F7F0,$0E00,$F6F0,$F6F8,$FF80,$FEF0
                DC.W $FFF0,$F000,$FFF0,$F6F0,$00,$00,$0F00,$00
                DC.W $F000,$FFF0,$F000,$FFF0,$F9F0,$F9F0,$F3F0,$0600
                DC.W $F7F0,$F6F8,$FF80,$FEF0,$FFF0,$F000,$FFF0,$FEF0
                DC.W $00,$00,$0F00,$00,$F000,$FFF0,$E000,$FFF0
                DC.W $F0F0,$F0F0,$F1F0,$0200,$F7F0,$F6F8,$FF80,$FEF0
                DC.W $FFF0,$F000,$FFF0,$FEF0,$00,$00,$0F00,$00
                DC.W $F000,$FFE0,$C000,$FFF0,$E070,$E000,$F0F0,$00
                DC.W $F3E0,$F6F0,$FF80,$7CF0,$7FE0,$F000,$79E0,$7CF0
                DC.W $00,$00,$0F00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$7F00,$3330,$00
                DC.W $00,$7FE0,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$FF80,$3330,$02E0,$00,$8010,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$FF80,$CCC0,$02A0
                DC.W $00,$8010,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $8000,$FF80,$CCC0,$03A0,$00,$FCF0,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $60,$1860,$6300,$78C0,$C000,$F380,$3330,$00
                DC.W $0C00,$85F0,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$F0,$3CF0,$F780,$FDE0
                DC.W $E000,$F3F0,$3330,$0220,$1E00,$85F0,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $F0,$3CF0,$F780,$FDE0,$F000,$F3F0,$CCC0,$0220
                DC.W $1E00,$85F0,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$60,$1860,$60C0,$78C0
                DC.W $7000,$F3F0,$CCC0,$01C0,$0300,$85F0,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$40,$00,$3000,$F1F0,$3330,$00
                DC.W $0100,$85F0,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$20,$00
                DC.W $1000,$F000,$3330,$03E0,$80,$8510,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$FC00,$CCC0,$0100
                DC.W $00,$8510,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$FC00,$CCC0,$80,$00,$FCF0,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$FC00,$3330,$0100
                DC.W $00,$8010,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$7C00,$3330,$03E0,$00,$8010,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$CCC0,$00
                DC.W $00,$7FE0,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,$00

TABLET:
                DC.L FNT+40*32+28
                DC.L FNT+40*32+6
                DC.L FNT+40*32+28
                DC.L FNT+40*32+18
                DC.L FNT+40*32+20
                DC.L FNT+40*32+22
                DC.L FNT+40*32+24
                DC.L FNT+40*32+8
                DC.L FNT+40*16+32
                DC.L FNT+40*16+34
                DC.L FNT+40*32+26
                DC.L FNT+40*32+28
                DC.L FNT+40*32+16
                DC.L FNT+40*16+36
                DC.L FNT+40*32
                DC.L FNT+40*32+28
                DC.L FNT+28
                DC.L FNT+40*16+14
                DC.L FNT+40*16+16
                DC.L FNT+40*16+18
                DC.L FNT+40*16+20
                DC.L FNT+40*16+22
                DC.L FNT+40*16+24
                DC.L FNT+40*16+26
                DC.L FNT+40*16+28
                DC.L FNT+40*16+30
                DC.L FNT+40*32+2
                DC.L FNT+40*32+4
                DC.L FNT+40*32+12
                DC.L FNT+40*32+14
                DC.L FNT+40*32+28
                DC.L FNT+40*32+10
                DC.L FNT+40*32+28
                DC.L FNT
                DC.L FNT+2
                DC.L FNT+4
                DC.L FNT+6
                DC.L FNT+8
                DC.L FNT+10
                DC.L FNT+12
                DC.L FNT+14
                DC.L FNT+16
                DC.L FNT+18
                DC.L FNT+20
                DC.L FNT+22
                DC.L FNT+24
                DC.L FNT+26
                DC.L FNT+28
                DC.L FNT+30
                DC.L FNT+32
                DC.L FNT+34
                DC.L FNT+36
                DC.L FNT+40*16
                DC.L FNT+40*16+2
                DC.L FNT+40*16+4
                DC.L FNT+40*16+6
                DC.L FNT+40*16+8
                DC.L FNT+40*16+10
                DC.L FNT+40*16+12
TAB_DEF:
                INCBIN 'DEF.DAT'
FIN_DEF:
                DC.W 15
TAB_CORD:
                INCBIN 'COORD.SPR'
FCORD:
                INCBIN 'COORD.SPR'
ZIK:
                INCBIN 'SYNTAX1.MUS'
DEB_DAT:
SOURCE:         DC.L 0
SOURCE2:        DC.L 0
LARG:           DC.W 0
HAUT:           DC.W 0
MAGNUM:         DC.W 0
TAB_ROUT:       DC.L 0
OFFSET:         DC.W 0
SYNC_1:         DC.W 0
VBL_FLAG:       DC.W 0
POSY:           DC.W 0
NILL:           DS.W 16
SAVE:           DS.L 5
VOLTAB:         DS.B 90
BUF1:           DS.B NBSTAR*6
BUF2:           DS.B NBSTAR*6
TAB_D:          DS.B 320*8
TAB_E:          DS.B 640*4
TAB_L:          DS.B 640*4
TAB_4:          DS.B 640*4
	DS.W	100 
HARD_ECR
	DC.L	ECRAN+160*72,$80000+160*72
ECR:            DC.L $70000
                EVEN
TAB_H
	INCBIN	HARD.DAT
FIN_TABH

C000:           DC.L L_054,L_054,L_158,L_158,L_186,L_158 ;C00
                DC.W -3*256

C160:           DC.L L_158,L_158,L_158,L_186,L_230,L_230 ;C12
                DC.W -4*256-256

C320:           DC.L L_160,L_160,L_160,L_160,L_160,L_160 ;C24
                DC.W -3*256-512

C480:           DC.L L_054,L_054,L_054,L_204,L_204,L_230 ;C04
                DC.W -3*256-512

C640:           DC.L L_054,L_054,L_054,L_158,L_160,L_160 ;C16
                DC.W -2*256-768

C800:           DC.L L_054,L_054,L_054,L_158,L_186,L_230 ;C28-768
                DC.W -2*256-1024

C960:           DC.L L_054,L_054,L_158,L_158,L_204,L_204 ;C08
                DC.W -3*256-1024

C1120:          DC.L L_054,L_158,L_186,L_186,L_186,L_158 ;C20
                DC.W -3*256-1280
ROUT_D:

                END
