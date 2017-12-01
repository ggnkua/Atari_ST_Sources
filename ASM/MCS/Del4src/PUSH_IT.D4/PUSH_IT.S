ECRAN           EQU $070000
                TEXT
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	MOVE.W	#$2700,SR

                clr.b   $FFFF8260.w

                move.b  #$07,$FFFF8201.w
                move.b  #$00,$FFFF8203.w

                movem.l $FF8240,D0-D7   * SAVE OLD PALETTE
                movem.l D0-D7,OLD_PAL

                movem.l NILL,D0-D7      * TOUT EN NOIR
                movem.l D0-D7,$FFFF8240.w

                bsr     AFF_PAGE_MENU

                move.b  #1,JOY_FLAG     * DRAPEAU A 1

                movea.l #SAVE,A0
                move.l  $70,(A0)+
                move.l  $0118,(A0)+
                move.l  $0120,(A0)+
                move.b  $FFFA07,(A0)+
                move.b  $FFFA09,(A0)+
                move.b  $FFFA13,(A0)+
                move.b  $FFFA17,(A0)+
                move.b  $FFFA1B,(A0)+
                move.b  $FFFA21,(A0)+
                move.l  #VBL_PRES,$70
                move.l  #MOUSEIT,$0118
                bclr    #3,$FFFA17
                clr.b   $FFFA07
                ori.b   #1,$FFFA07
                clr.b   $FFFA13
                ori.b   #1,$FFFA13
                clr.b   $FFFA1B
                move.b  #$40,$FFFA09
                move    #$2300,SR

WAIT_MENU:
                tst.b   BOUTON
                beq.s   WAIT_MENU
                move.b  #0,JOY_PARAM
                moveq   #0,D1
                move.w  OPTI,D1
                lea     TAB_OPT,A0
                movea.l 0(A0,D1.w),A0
                jmp     (A0)

PLAY:
                move.l  #OBJETS,PEK_OBJET+2
                move.w  #0,SCORE

                moveq   #$17,D0         * INIT LA MUSIC
                jsr     ZIK

                move    #$2700,SR
                move.l  #VBL,$70.w
                move    #$2300,SR

UN_AUTRE_OBJET:

                lea     FOND+34,A0      * AFFICHE LE FOND
                lea     ECRAN,A1
                move.w  #7999,D1
AFF_FOND:
                move.l  (A0)+,(A1)+
                dbra    D1,AFF_FOND

                move.w  SCORE,D0
                lea     ECRAN+2*160+128,A0
                bsr     AFF_CHIFFRE

PEK_OBJET:
                movea.l #OBJETS,A0      * ADRESSE OBJET
                movea.l #MATRICE,A1     * MATRICE MELANGEE
                movea.l #TAB_BLK,A2
                movea.l #PAL_BLK,A3
                lea     6(A0),A0
                move.w  (A0)+,D0
                move.l  0(A2,D0.w),BLOCK

                lsl.w   #3,D0
                movem.l 0(A3,D0.w),D0-D7
                movem.l D0-D7,PALETTE

                move.w  (A0)+,TIME_SECOND

                move.w  #44,D1          * COPIE L'OBJET DANS LA MATRICE
COP_OBJET:
                move.l  (A0)+,(A1)+
                dbra    D1,COP_OBJET

                lea     PASSWORD,A1
                move.b  (A0)+,(A1)+
                move.b  (A0)+,(A1)+
                move.b  (A0)+,(A1)+
                move.b  (A0)+,(A1)+
                move.b  (A0)+,(A1)+
                move.b  (A0)+,(A1)+

                bsr     OFF_MOUSE

                bsr     COP_MATRICE     * COPIE LA MATRICE DANS SOLUTION

                bsr     AFF_MATRICE     * AFFICHE LA MATRICE

.WAIT_BOUT:
                move.b  JOY_PARAM,D7
                btst    #7,D7
                beq.s   .WAIT_BOUT

                bsr     REMP_MAT        * MELANGE LA MATRICE

                bsr     STOCK_FOND

                bsr     ON_MOUSE

                move.l  #DEC_TIME,PEK_DEC+2

WAIT:
                bsr     WAIT_MOUSE
                tst.w   TIME_SECOND     * TEMP ECOULE ?
                ble     PERDU

	TST.W	CHEAT_ON
	BEQ.S	CHEAT_OFF

                cmpi.b  #$3B,KEY        * F1= CHANGE LEVEL
                beq     GAGNE
CHEAT_OFF

                cmpi.b  #$62,KEY        * HELP WAS PRESSED ?
                bne.s   PAS_HLP

                bsr     OFF_MOUSE

                bsr     AFF_SOLUT       * AFFICHE LA SOLUTION
PAS_HLP_RELACHEE:
                cmpi.b  #$62,KEY
                beq.s   PAS_HLP_RELACHEE
                bsr     AFF_MATRICE

                bsr     ON_MOUSE
PAS_HLP:
                cmpi.w  #1,ESC_FLAG
                beq     RET_MENU
                lea     SOLUTION,A0     * TEST SI MATRICE=SOLUTION
                lea     MATRICE,A1
                move.w  #44,D1
TST_SI_OK:
                cmpm.l  (A0)+,(A1)+
                bne.s   PAS_BON
                dbra    D1,TST_SI_OK
                bra     GAGNE
PAS_BON:
                tst.b   BOUTON          * BOUTON APPUYE ?
                beq     WAIT

                bsr     WAIT_MOUSE
                movea.l #MATRICE,A0
                move.w  NBLK,D1
                move.w  D1,NBLK2
                tst.b   0(A0,D1.w)      * BLOCK VIDE ?
                beq     WAIT

                move.b  #0,0(A0,D1.w)   * PREND LE BLOCK
* JUSQUE LA PAS DE PROBLEME

                bsr     EFF_MOUSE
                bsr     CALC_RELAT
                bsr     EFF_BLOCK2      * BUG !!!!!
                bsr     STOCK_FOND      * RE BUG !!!!!

                move.l  #AFF_MOUSE2,PEK_MOUSE+2
                move.l  #GERE_JOY4,GERE_JOY1+2

WAIT_BOUTON_RELACHE:
                tst.b   BOUTON          * BOUTON RELACHE ?
                bne.s   WAIT_BOUTON_RELACHE

                bsr     WAIT_MOUSE
                move.w  NBLK,D1
                lea     MATRICE,A0
                move.b  #1,0(A0,D1.w)   * POSE LE BLOCK
                bsr     AFF_BLOCK
                bsr     STOCK_FOND
                move.l  #AFF_MOUSE,PEK_MOUSE+2
                move.l  #GERE_JOY2,GERE_JOY1+2
                bra     WAIT
                bra     FIN

GAGNE:
                move.l  #NULL,PEK_DEC+2
                moveq   #0,D0
                move.w  TIME_SECOND,D0
                lsr.w   #3,D0
                add.w   D0,SCORE
                addi.l  #190,PEK_OBJET+2 * OBJET SUIVANT
                cmpi.l  #FIN_OBJETS,PEK_OBJET+2
                beq.s   PLUS_DOBJETS    * TRES FORT

                move    #$2700,SR
                move.l  #VBL_NULL,$70.w
                move    #$2300,SR

                bsr     CLEAR_SCR

                movem.l PALETTE_12,D0-D7
                movem.l D0-D7,$FFFF8240.w

                lea     WELL_DONE,A0
                bsr     AFF_MESS

                bsr     CLEAR_SCR

                move    #$2700,SR
                move.l  #VBL,$70.w
                move    #$2300,SR

                bra     UN_AUTRE_OBJET

PLUS_DOBJETS:                           * FIN DU JEU
                move    #$2700,SR
                move.l  #VBL_NULL,$70.w
                move    #$2300,SR

                bsr     CLEAR_SCR

                movem.l PALETTE_12,D0-D7
                movem.l D0-D7,$FFFF8240.w

                bsr     CLEAR_SCR
                lea     WON_TXT,A0
                bsr     AFF_MESS2

                bra     MCS_01
PERDU:
                move    #$2700,SR
                move.l  #VBL_NULL,$70.w
                move    #$2300,SR

                bsr     CLEAR_SCR

                movem.l PALETTE_12,D0-D7
                movem.l D0-D7,$FFFF8240.w

                bsr     CLEAR_SCR
                lea     YOU_LOST,A0
                bsr     AFF_MESS2

                move.w  SCORE,D0
                lea     ECRAN+160*48+72,A0
                bsr     AFF_CHIFFRE

MCS_01:
                moveq   #0,D1
                lea     TAB_SCORES,A0
                move.w  SCORE,D1

TEST_NEXT_SCORE:
                move.w  8(A0),D4        * SCORE

                cmp.w   D1,D4
                blt.s   SCORE_SUP

                lea     10(A0),A0
                cmpa.l  #FIN_SCORE,A0
                bne.s   TEST_NEXT_SCORE

                lea     FIRE_WORK,A0
                bsr     AFF_MESS
                bra     RET_MENU
SCORE_SUP:
                lea     FIN_SCORE,A1
NEXT_DECAL:
                movem.l (A1),D0-D1      * NOM
                move.w  8(A1),D2        * SCORE
                movem.l D0-D1,10(A1)
                move.w  D2,18(A1)

                lea     -10(A1),A1
                cmpa.l  A1,A0
                ble.s   NEXT_DECAL

                move.l  A0,-(SP)

                lea     YEAHHH,A0
                bsr     AFF_MESS2

                lea     NAME,A6
                moveq   #8,D4
                lea     ECRAN+16376,A4
                bsr     INPUT

                movea.l (SP)+,A0

                lea     NAME,A6
                movem.l (A6),D0-D1
                movem.l D0-D1,(A0)
                move.w  SCORE,8(A0)

                lea     FIRE_WORK,A0
                bsr     AFF_MESS

RET_MENU:
                move    #$2700,SR
                bsr     AFF_PAGE_MENU
                move.l  #VBL_PRES,$70
                move    #$2300,SR
                move.w  #0,ESC_FLAG
                moveq   #0,D0
                jsr     ZIK
                bra     WAIT_MENU
FIN:
                movem.l OLD_PAL,D0-D7   * REMET LA PALETTE
                movem.l D0-D7,$FFFF8240.w

                move    #$2700,SR       * LES INTERS
                movea.l #SAVE,A0
                move.l  (A0)+,$70
                move.l  (A0)+,$0118
                move.l  (A0)+,$0120.w
                move.b  (A0)+,$FFFA07
                move.b  (A0)+,$FFFA09
                move.b  (A0)+,$FFFA13
                move.b  (A0)+,$FFFA17
                move.b  (A0)+,$FFFA1B
                move.b  (A0)+,$FFFA21

                move.b  #8,$FFFC02      * LA SOURIS
                DC.W $A009

                moveq   #0,D0           * COUPE LA MUSIC
                jsr     ZIK

	ILLEGAL

AFF_PAGE_MENU:
                bsr     CLEAR_SCR
                lea     PUSH_IT,A0
                lea     ECRAN+24,A1
                move.w  #52,D2
AFF_PUSH:
                move.w  #29,D1
LIG_PUSH:
                move.l  (A0)+,(A1)+
                dbra    D1,LIG_PUSH
                lea     40(A1),A1
                dbra    D2,AFF_PUSH

                lea     MENU,A0
                lea     ECRAN+160*59,A1
                move.w  #160*40-1,D2
AFF_MENU:
                move.l  (A0)+,(A1)+
                dbra    D2,AFF_MENU
                rts

CLEAR_SCR:
                moveq   #0,D0
                lea     ECRAN,A0
                move.w  #7999,D1
EFF_SCR:
                move.l  D0,(A0)+
                dbra    D1,EFF_SCR
                rts
***************************************************
*  ATTENDS QUE LA GESTION DU JOYSTICK SOIT FAITE  *
***************************************************

WAIT_MOUSE:
                tst.w   VBL_FLAG
                beq.s   WAIT_MOUSE
                move.w  #0,VBL_FLAG
                rts

*************************************************
*         COUPE L'INTERRUPTION SOURIS           *
*************************************************

OFF_MOUSE:
                move.l  PEK_MOUSE+2,BUF_AFF
                move.l  #NULL,PEK_MOUSE+2
                rts

*************************************************
*         REMET L'INTERRUPTION SOURIS           *
*************************************************

ON_MOUSE:
                move.l  BUF_AFF,PEK_MOUSE+2
                rts

*************************************************
*              VBL DE PRESENTATION              *
*************************************************

VBL_PRES:
                clr.b   $FFFF8260.w
                movem.l D0-A6,-(SP)
                clr.b   $FFFA1B
                move.b  #58,$FFFA21
                move.b  #8,$FFFA1B
                move.l  #HBL_PRES,$0120.w
                movem.l PAL_PUSH,D0-D7
                movem.l D0-D7,$FFFF8240.w
PEK_PRES:
                jsr     GERE_JOY_PRES
                movem.l (SP)+,D0-A6
                rte

GERE_JOY_PRES:
                move.l  #GERE_PRES1,PEK_PRES+2
                rts

GERE_PRES1:
                move.l  #GERE_PRES2,PEK_PRES+2
                rts

GERE_PRES2:
                bsr     AFF_PTR1
                move.b  JOY_PARAM,D7
                btst    #0,D7
                bne.s   HAUT_PRES
                btst    #1,D7
                bne.s   BAS_PRES
                btst    #7,D7
                bne.s   BOUT_PRES
                move.b  #0,BOUTON
                clr.b   JOY_PARAM
                move.l  #GERE_JOY_PRES,PEK_PRES+2
                rts
HAUT_PRES:
                tst.w   OPTI
                beq.s   FHAUT
                subi.w  #29*160,POS_PTR
                subq.w  #4,OPTI
FHAUT:
                move.l  #GERE_JOY_PRES,PEK_PRES+2
                rts
BAS_PRES:
                cmpi.w  #16,OPTI
                beq.s   FBAS
                addi.w  #29*160,POS_PTR
                addq.w  #4,OPTI
FBAS:
                move.l  #GERE_JOY_PRES,PEK_PRES+2
                rts
BOUT_PRES:
                move.b  #1,BOUTON
                move.l  #GERE_JOY_PRES,PEK_PRES+2
                rts
TAB_OPT:
                DC.L INFOS,HISCORE,PLAY,FIN,PASSWD
HISCORE:
                move    #$2700,SR
                move.l  #HBL_NULL,$70.w
                move    #$2300,SR

                bsr     CLEAR_SCR

                movem.l PALETTE_12,D0-D7
                movem.l D0-D7,$FFFF8240.w

                lea     TAB_SCORES,A0
                lea     ECRAN+8*16,A1
                lea     BUF_NAM,A2

                moveq   #9,D7           * 10 HISCORES
COP_HSCORE:
                movem.l (A0),D0-D1      * NAMES
                movem.l D0-D1,(A2)
                lea     10(A0),A0
                lea     20(A2),A2
                dbra    D7,COP_HSCORE

                movem.l D0-A6,-(SP)
                lea     BUF_NAM,A0
                bsr     AFF_MESS2
                movem.l (SP)+,D0-A6

                lea     TAB_SCORES,A6
                moveq   #9,D7
AFF_SCORES:
                move.w  8(A6),D0
                movea.l A1,A0
                movem.l D0-A6,-(SP)
                bsr     AFF_CHIFFRE
                movem.l (SP)+,D0-A6

                adda.l  #160*17,A1
                lea     10(A6),A6
                dbra    D7,AFF_SCORES

                lea     FIRE_WORK,A0
                bsr     AFF_MESS
                bra     FIN_TEST_PASS
PASSWD:
WAIT_REL_INP:
                move.b  JOY_PARAM,D7
                btst    #7,D7
                bne.s   WAIT_REL_INP

                move    #$2700,SR
                move.l  #HBL_NULL,$70.w
                move    #$2300,SR

                bsr     CLEAR_SCR

                movem.l PALETTE_12,D0-D7
                movem.l D0-D7,$FFFF8240.w

                lea     TXT_PASS,A0
                bsr     AFF_MESS2

                lea     INP_PASS,A6
                move.w  #6,D4
                lea     ECRAN+160*33+8,A4

                bsr     INPUT

WAIT_REL_INP2:
                move.b  JOY_PARAM,D7
                btst    #7,D7
                bne.s   WAIT_REL_INP2

                lea     OBJETS,A0
                lea     INP_PASS,A6
                move.l  (A6)+,D1
                move.w  (A6)+,D0
TEST_ANOTHER_PASS:
                cmp.l   (A0),D1
                bne.s   NEX_PASS
                cmp.w   4(A0),D0
                bne.s   NEX_PASS
OK_PASS:
                move.l  A0,PLAY+2
                bra     FIN_TEST_PASS
NEX_PASS:
                lea     190(A0),A0
                cmpa.l  #FIN_OBJETS,A0
                bne.s   TEST_ANOTHER_PASS

                lea     BAD_PASS,A0
                bsr     AFF_MESS

FIN_TEST_PASS:
                move.b  JOY_PARAM,D7
                btst    #7,D7
                bne.s   FIN_TEST_PASS

                move.b  #0,BOUTON
                move.b  #0,JOY_PARAM

                move    #$2700,SR
                move.l  #VBL_PRES,$70.w
                move    #$2300,SR

                bsr     AFF_PAGE_MENU
                bra     WAIT_MENU

INP_PASS:
                DS.W 10

*****************************************
* INPUT : ZONE DANS A6 ET NBLET DANS D4 *
*        ADRESSE ECRAN DANS A4          *
*****************************************

INPUT:
                moveq   #0,D6
                lea     TAB_SCAN,A0
                movea.l A4,A2
                lea     TAB_FNT,A3
BAD_KEY:
                moveq   #0,D1
                moveq   #0,D7
                move.b  KEY,D7          * SCAN CODE
                move.b  0(A0,D7.w),D1   * ASCII IN D1
                beq.s   BAD_KEY         * IF 0 NO LETTER
                cmp.b   #$FF,D1         * RETURN OU ENTER
                beq.s   FIN_INPUT_RETURN
                move.b  D1,(A6)+        * STOCK THE LETTER
                sub.b   #' ',D1
                add.w   D1,D1           * MUL BY 4 (LIKE DEL)
                add.w   D1,D1
                movea.l 0(A3,D1.w),A1
                moveq   #15,D5
AFF_LET_INP:
                move.l  (A1),(A2)
                move.l  4(A1),4(A2)
                lea     160(A2),A2
                lea     160(A1),A1
                dbra    D5,AFF_LET_INP
                lea     8(A4),A4
                movea.l A4,A2
                addq.w  #1,D6
                cmp.w   D6,D4
                beq.s   FIN_INPUT
WAIT_RELEASE:
                cmp.b   KEY,D7
                beq.s   WAIT_RELEASE
                bra     BAD_KEY
FIN_INPUT_RETURN:
                move.b  #' ',(A6)+
                addq.w  #1,D6
                cmp.w   D6,D4
                bne.s   FIN_INPUT_RETURN
FIN_INPUT:
                rts

HBL_PRES:
                move    #$2700,SR
                movem.l D0-D7,-(SP)
                movem.l PAL_MENU,D0-D7
                movem.l D0-D7,$FFFF8240.w
                movem.l (SP)+,D0-D7
                move    #$2300,SR
                move.l  #HBL_NULL,$0120.w
                rte

AFF_PTR1:
                moveq   #0,D0
                move.w  OLD_POS_PTR,D0
                lea     ECRAN+8,A0
                adda.w  D0,A0
                lea     MENU+8,A1
                sub.w   #160*59,D0
                adda.w  D0,A1
                move.w  #15,D5
RES_PTRPRE:
                move.l  (A1),(A0)
                move.l  4(A1),4(A0)
                lea     160(A1),A1
                lea     160(A0),A0
                dbra    D5,RES_PTRPRE
                lea     ECRAN+8,A0
                move.w  POS_PTR,D0
                adda.w  D0,A0
                lea     PTR_PRES,A1
                move.w  #15,D5
AFF_PTRPRE:
                move.l  (A1)+,(A0)
                move.l  (A1)+,4(A0)
                lea     160(A0),A0
                dbra    D5,AFF_PTRPRE
                move.w  D0,OLD_POS_PTR
                rts

*************************************************
*   VERTICAL BLANK INTERRUPT (ALSO CALLED VBL)  *
*************************************************

VBL_NULL:
                clr.b   $FFFF8260.w
                move    #$2700,SR
                movem.l D0-A6,-(SP)
                jsr     ZIK+6
                movem.l (SP)+,D0-A6
                move    #$2300,SR
                rte

VBL:
                clr.b   $FFFF8260.w
                move    #$2700,SR

                clr.b   $FFFA1B
                move.b  #20,$FFFA21
                move.b  #8,$FFFA1B
                move.l  #HBL,$0120.w

                movem.l D0-A6,-(SP)

                movem.l PALETTE_2,D0-D3
                movem.l D0-D3,$FFFF8250.w

	LEA	CHEAT_CODE,A1
	MOVE.W	PTR_CHEAT,D7
	CMP.W	#F_CHEAT-PTR_CHEAT,D7
	BEQ.S	PAS_CHEAT
	MOVE.B	$FFFC02,D0
	CMP.B	(A1,D7.W),D0
	BNE.S	PAS_CHEAT
	ADDQ.W	#1,D7
	MOVE.W	D7,PTR_CHEAT
	CMP.W	#F_CHEAT-CHEAT_CODE,D7
	BNE.S	PAS_CHEAT
	MOVE.W	#1,CHEAT_ON
PAS_CHEAT
                cmpi.b  #$61,$FFFC02    * UNDO ?
                bne.s   PEK_MOUSE
                move.w  #1,ESC_FLAG
PEK_MOUSE:
                jsr     AFF_MOUSE       * AFFICHE LE PTR SOURIS

PEK_DEC:
                jsr     NULL            * DECREMENTE LE TEMPS

PEK_JOY:
                jsr     GERE_JOYSTICK   * GESTION JOYSTICK

                jsr     ZIK+6

                move.w  #1,VBL_FLAG
                movem.l (SP)+,D0-A6
                move    #$2300,SR
                rte
VBL_FLAG:
                DC.W 0
ESC_FLAG:
                DC.W 0
HBL:
                move    #$2700,SR
                movem.l D0-D7,-(SP)
                movem.l PALETTE,D0-D7
                movem.l D0-D7,$FFFF8240.w
                movem.l (SP)+,D0-D7
                move    #$2300,SR
                clr.b   $FFFA1B
                move.b  #100,$FFFA21
                move.b  #8,$FFFA1B
                move.l  #HBL_NULL,$0120.w
HBL_NULL:
                rte

***************************************************
*    DECREMENTATION DU TEMPS TOUTE LES 50 VBL     *
***************************************************

DEC_TIME:
                subi.w  #1,SYNCHRO
                tst.w   SYNCHRO
                bne.s   FIN_DEC_TIME
                move.w  #50,SYNCHRO
                subi.w  #1,TIME_SECOND
                move.w  TIME_SECOND,D0
                lea     ECRAN+160*2+48,A0
                bsr     AFF_CHIFFRE
FIN_DEC_TIME:
NULL:
                rts

********************************************
*          GESTION DU JOYSTICK             *
********************************************

GERE_JOYSTICK:                          * 1ERE GESTION
                move.l  #GERE_JOY1,PEK_JOY+2
                rts

GERE_JOY1:                              * 2EME GESTION
                move.l  #GERE_JOY2,PEK_JOY+2
                rts

GERE_JOY4:                              * GESTION AVEC TEST DE BLOCKS
                lea     MATRICE,A0
                move.w  NBLK,D0
                move.b  JOY_PARAM,D7    * PARAM $118
                btst    #0,D7           * HAUT ?
                beq.s   PAS_DIR_12
                cmpi.w  #160*30,YMOUSE
                ble     PAS_DIR_12
                tst.b   -18(A0,D0.w)    * BLOCK AU DESSUS ?
                bne.s   PAS_DIR_12
                subi.w  #160*16,YMOUSE  * EVITE LES MULU #160
                subi.w  #18,NBLK        * NBL=NBLK-18
                bra     PAS_DIR_42
PAS_DIR_12:

                btst    #1,D7           * BAS ?
                beq.s   PAS_DIR_22
                cmpi.w  #160*158,YMOUSE
                bge     PAS_DIR_22
                tst.b   18(A0,D0.w)
                bne.s   PAS_DIR_22
                addi.w  #160*16,YMOUSE
                addi.w  #18,NBLK
                bra     PAS_DIR_42

PAS_DIR_22:
                btst    #2,D7           * GAUCHE ?
                beq.s   PAS_DIR_32
                cmpi.w  #8,XMOUSE
                beq     PAS_DIR_32
                tst.b   -1(A0,D0.w)
                bne.s   PAS_DIR_32
                subi.w  #8,XMOUSE
                subi.w  #1,NBLK
                bra     PAS_DIR_42
PAS_DIR_32:

                btst    #3,D7           * DROITE ?
                beq.s   PAS_DIR_42
                cmpi.w  #8*18,XMOUSE
                beq     PAS_DIR_42
                tst.b   1(A0,D0.w)
                bne.s   PAS_DIR_42
                addi.w  #8,XMOUSE
                addi.w  #1,NBLK

PAS_DIR_42:
                btst    #7,D7           * BOUTON ?
                beq.s   PAS_BOUTON2
                move.b  #1,BOUTON
                bra.s   FIN_ROUT_JOY2

PAS_BOUTON2:
                move.b  #0,BOUTON
FIN_ROUT_JOY2:                          * FIN ROUTINE
                move.l  #GERE_JOYSTICK,PEK_JOY+2
                rts

**********************************************
*  ROUTINE JOYSTICK SANS GESTION DES BLOCKS  *
**********************************************

GERE_JOY2:
                move.b  JOY_PARAM,D7
                btst    #0,D7
                beq.s   PAS_DIR_1
                cmpi.w  #160*30,YMOUSE
                ble     PAS_DIR_1
                subi.w  #160*16,YMOUSE
                subi.w  #18,NBLK
                bra     PAS_DIR_4
PAS_DIR_1:
                btst    #1,D7
                beq.s   PAS_DIR_2
                cmpi.w  #160*158,YMOUSE
                bge     PAS_DIR_2
                addi.w  #160*16,YMOUSE
                addi.w  #18,NBLK
                bra     PAS_DIR_4
PAS_DIR_2:
                btst    #2,D7
                beq.s   PAS_DIR_3
                cmpi.w  #8,XMOUSE
                beq     PAS_DIR_3
                subi.w  #8,XMOUSE
                subi.w  #1,NBLK
                bra     PAS_DIR_4
PAS_DIR_3:
                btst    #3,D7
                beq.s   PAS_DIR_4
                cmpi.w  #8*18,XMOUSE
                beq     PAS_DIR_4
                addi.w  #8,XMOUSE
                addi.w  #1,NBLK
PAS_DIR_4:
                btst    #7,D7
                beq.s   PAS_BOUTON
                move.b  #1,BOUTON
                bra.s   FIN_ROUT_JOY
PAS_BOUTON:
                move.b  #0,BOUTON
FIN_ROUT_JOY:
                move.l  #GERE_JOYSTICK,PEK_JOY+2
                rts

****************************************************
*  RECOPIE DE LA MATRICE DANS LA MATRICE SOLUTION  *
****************************************************

COP_MATRICE:
                lea     MATRICE,A0
                lea     SOLUTION,A1
                move.w  #44,D1
RECOPIE:
                move.l  (A0)+,(A1)+
                dbra    D1,RECOPIE
                rts

***************************************************
*            AFFICHAGE DE LA MATRICE            *
***************************************************

AFF_MATRICE:
                lea     MATRICE,A0
                lea     ECRAN+160*30+8,A3
                lea     FOND+34+160*30+8,A5

                move.w  #9,D2
LIG_MAT:
                movea.l A3,A4
                move.w  #17,D1
COL_MAT:
                movea.l A4,A2
                tst.b   (A0)+
                beq.s   DO_FOND
                movea.l BLOCK,A1
                move.w  #15,D3
AFF_BLK:
                move.w  (A1),D0
                or.w    2(A1),D0
                or.w    4(A1),D0
                or.w    6(A1),D0
                not.w   D0
                and.w   D0,(A2)
                and.w   D0,2(A2)
                and.w   D0,4(A2)
                and.w   D0,6(A2)
                move.l  (A1)+,D0
                move.l  (A1)+,D5
                or.l    D0,(A2)
                or.l    D5,4(A2)
                lea     160(A2),A2
                dbra    D3,AFF_BLK
                bra.s   SUITE
DO_FOND:
                movea.l A5,A6
                move.w  #15,D3
AFF_FOND_MAT:
                move.l  (A6),(A2)
                move.l  4(A6),4(A2)
                lea     160(A6),A6
                lea     160(A2),A2
                dbra    D3,AFF_FOND_MAT
SUITE:
                lea     8(A4),A4
                lea     8(A5),A5
                dbra    D1,COL_MAT
                lea     160*16(A3),A3
                lea     151*16(A5),A5
                dbra    D2,LIG_MAT
                rts

***************************************************
*           EFFACAGE DU BLOCK NBLK                *
***************************************************

EFF_BLOCK:
                lea     ECRAN+160*30+8,A3
                lea     FOND+34+160*30+8,A2
                move.w  RELAT_POS,D1
                sub.w   #160*16+8,D1
                adda.w  D1,A3
                adda.w  D1,A2
                move.w  #15,D1
EFF_BLOK_LINE:
                move.l  (A2),(A3)
                move.l  4(A2),4(A3)
                lea     160(A3),A3
                lea     160(A2),A2
                dbra    D1,EFF_BLOK_LINE
                rts

EFF_BLOCK2:
                lea     ECRAN+160*30+8,A3
                lea     FOND+34+160*30+8,A2
                move.w  RELAT_POS2,D1
                sub.w   #160*16+8,D1
                adda.w  D1,A3
                adda.w  D1,A2
                move.w  #15,D1
EFF_BLOK_LINE2:
                move.l  (A2),(A3)
                move.l  4(A2),4(A3)
                lea     160(A3),A3
                lea     160(A2),A2
                dbra    D1,EFF_BLOK_LINE2
                rts

AFF_BLOCK:
                lea     ECRAN+160*30+8,A3
                movea.l BLOCK,A1
                move.w  RELAT_POS,D1
                sub.w   #160*16+8,D1
                adda.w  D1,A3
                move.w  #15,D1
AFF_BLOK_LINE:
                move.w  (A1),D0
                or.w    2(A1),D0
                or.w    4(A1),D0
                or.w    6(A1),D0
                not.w   D0
                and.w   D0,(A3)
                and.w   D0,2(A3)
                and.w   D0,4(A3)
                and.w   D0,6(A3)
                move.l  (A1)+,D0
                move.l  (A1)+,D5
                or.l    D0,(A3)
                or.l    D5,4(A3)
                lea     160(A3),A3
                dbra    D1,AFF_BLOK_LINE
                rts

**************************************************
*   STOCKAGE D'UN FOND BIDON POUR LE JOYSTICK    *
**************************************************

STOCK_FOND:
                move.l  #ECRAN+200*160,BUF_MOUSE
                rts

***************************************************
*        AFFICHAGE DE LA MATRICE SOLUTION         *
***************************************************

AFF_SOLUT:
                lea     SOLUTION,A0
                lea     ECRAN+160*30+8,A3
                lea     FOND+34+160*30+8,A5

                move.w  #9,D2
LIG_MAT_HLP:
                movea.l A3,A4
                move.w  #17,D1
COL_MAT_HLP:
                movea.l A4,A2
                tst.b   (A0)+
                beq.s   DO_FOND_HLP
                movea.l BLOCK,A1
                move.w  #15,D3
AFF_BLK_HLP:
*       MOVE.L  (A1)+,(A2)
*       MOVE.L  (A1)+,4(A2)
                move.w  (A1),D0
                or.w    2(A1),D0
                or.w    4(A1),D0
                or.w    6(A1),D0
                not.w   D0
                and.w   D0,(A2)
                and.w   D0,2(A2)
                and.w   D0,4(A2)
                and.w   D0,6(A2)
                movem.l (A1)+,D0/D5
                or.l    D0,(A2)
                or.l    D5,4(A2)
                lea     160(A2),A2
                dbra    D3,AFF_BLK_HLP
                bra.s   SUITE_HLP
DO_FOND_HLP:
                movea.l A5,A6
                move.w  #15,D3
AFF_FOND_MAT_HLP:
                move.l  (A6),(A2)
                move.l  4(A6),4(A2)
                lea     160(A6),A6
                lea     160(A2),A2
                dbra    D3,AFF_FOND_MAT_HLP
SUITE_HLP:
                lea     8(A4),A4
                lea     8(A5),A5
                dbra    D1,COL_MAT_HLP
                lea     160*16(A3),A3
                lea     151*16(A5),A5
                dbra    D2,LIG_MAT_HLP
                rts

************************************************
*  REMPLISSAGE PSEUDO ALEATOIRE DE LA MATRICE  *
************************************************

REMP_MAT:
                lea     MATRICE,A0
                move.w  #199,D1

DO_IT:
                bsr     WAIT_MOUSE

                movem.l D1-A6,-(SP)
                bsr     RANDOM
                movem.l (SP)+,D1-A6

                and.l   #$FF,D0
                cmp.l   #180,D0
                blt.s   INF_180
                sub.w   #180,D0
INF_180:
                move.w  D0,D2

                movem.l D1-A6,-(SP)
                bsr     RANDOM
                movem.l (SP)+,D1-A6

                and.l   #$FF,D0
                cmp.l   #180,D0
                blt.s   INF_180_BIS
                sub.w   #180,D0
INF_180_BIS:
                move.b  0(A0,D0.w),D3
                move.b  0(A0,D2.w),D4
                move.b  D4,0(A0,D0.w)
                move.b  D3,0(A0,D2.w)
                movem.l D0-A6,-(SP)
*       BSR     AFF_MATRICE
                bsr     SWAP_BLOCK
                movem.l (SP)+,D0-A6
                dbra    D1,DO_IT
                rts

CALC_RELAT:
                move.w  NBLK2,D0
                moveq   #0,D1
                moveq   #0,D3
                moveq   #0,D4

                move.w  D0,D1
                move.w  D1,D3
                divu    #18,D1
                move.w  D1,D4
                mulu    #18,D4
                sub.w   D4,D3
                mulu    #8,D3
                move.w  D3,RELAT_POS2
                mulu    #160*16,D1
                add.w   D1,RELAT_POS2
                addi.w  #160*16+8,RELAT_POS2
                rts

SWAP_BLOCK:
*       MOVE.W  D0,NBLK

                moveq   #0,D1
                moveq   #0,D3
                moveq   #0,D4

                move.w  D0,D1
                move.w  D1,D3
                divu    #18,D1
                move.w  D1,D4
                mulu    #18,D4
                sub.w   D4,D3
                mulu    #8,D3
                move.w  D3,RELAT_POS
                mulu    #160*16,D1
                add.w   D1,RELAT_POS
                addi.w  #160*16+8,RELAT_POS
                lea     MATRICE,A0
                tst.b   0(A0,D0.w)
                beq.s   PAS_BLK_ICI
                movem.l D0-A6,-(SP)
                bsr     AFF_BLOCK
                movem.l (SP)+,D0-A6
                bra.s   TEST_BLK2
PAS_BLK_ICI:
                movem.l D0-A6,-(SP)
                bsr     EFF_BLOCK
                movem.l (SP)+,D0-A6
TEST_BLK2:
*       MOVE.W  D2,NBLK
                moveq   #0,D1
                moveq   #0,D3
                moveq   #0,D4
                move.w  D2,D1
                move.w  D1,D3
                divu    #18,D1
                move.w  D1,D4
                mulu    #18,D4
                sub.w   D4,D3
                mulu    #8,D3
                move.w  D3,RELAT_POS
                mulu    #160*16,D1
                add.w   D1,RELAT_POS
                addi.w  #160*16+8,RELAT_POS
                tst.b   0(A0,D2.w)
                beq.s   PAS_BLK_ICI2
                movem.l D0-A6,-(SP)
                bsr     AFF_BLOCK
                movem.l (SP)+,D0-A6
                bra.s   FIN_TEST_SWAP
PAS_BLK_ICI2:
                movem.l D0-A6,-(SP)
                bsr     EFF_BLOCK
                movem.l (SP)+,D0-A6
FIN_TEST_SWAP:
                rts

**********************************************
*    RANDOM : NBRE ALEATOIRE (HUM) DANS D0   *
**********************************************

RANDOM:
                tst.l   OLD_NB
                bne.s   PAS_NUL
                move.l  $FFFA20,D0
                moveq   #16,D1
                asl.l   D1,D0
                or.l    $FFFA20,D0
                move.l  D0,OLD_NB
PAS_NUL:
                move.l  #3141592621,D2
                move.l  OLD_NB,D3
                mulu    D2,D3
                move.l  D3,D0
                addq.l  #1,D0
                move.l  D0,OLD_NB
                asr.l   #8,D0
                and.l   #$FFFFFF,D0
                rts

OLD_NB:
                DC.L 0

**********************************************
*          INTERRUPTION JOYSTICK             *
**********************************************

MOUSEIT:
                cmpi.b  #$FF,$FFFC02
                beq.s   MAGNUM_01
                move.b  $FFFC02,KEY
                clr.b   JOY_PARAM
                rte
MAGNUM_01:
                move.l  #MAGNUM_02,$0118
                clr.b   JOY_PARAM
                rte
MAGNUM_02:
                move.b  $FFFC02,JOY_PARAM
                move.l  #MOUSEIT,$0118
                rte

JOY_FLAG:
                DC.W 0
**********************************************
*        AFFICHAGE DU POINTEUR JOYSTICK      *
**********************************************

AFF_MOUSE:
                jsr     EFF_MOUSE       * EFFACE L'ANCIEN

                lea     ECRAN+160*14,A0
                lea     BUF_MOUSE,A1

                move.w  XMOUSE,D0
                move.w  YMOUSE,D1

                add.w   D0,D1
                move.w  D1,RELAT_POS
                adda.w  D1,A0
                move.l  A0,(A1)+

                move.l  (A0),(A1)+
                move.l  4(A0),(A1)+
                move.l  #$FFFF0000,(A0)
                move.l  #0,4(A0)
                lea     160(A0),A0
                move.w  #%1000000000000001,D0
                move.w  #%111111111111110,D1
                move.w  #13,D3
LIG_PP:
                move.l  (A0),(A1)+
                move.l  4(A0),(A1)+
                or.w    D0,(A0)
                and.w   D1,2(A0)
                and.w   D1,4(A0)
                and.w   D1,6(A0)
                lea     160(A0),A0
                dbra    D3,LIG_PP
                move.l  (A0),(A1)+
                move.l  4(A0),(A1)+
                move.l  #$FFFF0000,(A0)
                move.l  #0,4(A0)
                rts

AFF_MOUSE2:                             * ROUTINE DE POINTEUR BLOCK
                jsr     EFF_MOUSE

                lea     ECRAN+160*14,A0
                lea     BUF_MOUSE,A1
                movea.l BLOCK,A2

                move.w  XMOUSE,D0
                move.w  YMOUSE,D1

                add.w   D0,D1
                move.w  D1,RELAT_POS
                adda.w  D1,A0
                move.l  A0,(A1)+
                move.w  #15,D1
AFF_PTR2:
                move.l  (A0),(A1)+
                move.l  4(A0),(A1)+
*       MOVE.L  (A2)+,(A0)
*       MOVE.L  (A2)+,4(A0)

                move.w  (A2),D0
                or.w    2(A2),D0
                or.w    4(A2),D0
                or.w    6(A2),D0
                not.w   D0
                and.w   D0,(A0)
                and.w   D0,2(A0)
                and.w   D0,4(A0)
                and.w   D0,6(A0)
                movem.l (A2)+,D0/D5
                or.l    D0,(A0)
                or.l    D5,4(A0)
                lea     160(A0),A0
                dbra    D1,AFF_PTR2
                rts

******************************************
*     EFFACEMENT DE L'ANCIEN POINTEUR    *
******************************************

EFF_MOUSE:
                movea.l #BUF_MOUSE,A1
                movea.l (A1)+,A0
                move.l  (A1)+,(A0)
                move.l  (A1)+,4(A0)
                lea     160(A0),A0
                move.w  #13,D1
REST_MOUSE:
                move.l  (A1)+,(A0)
                move.l  (A1)+,4(A0)
                lea     160(A0),A0
                dbra    D1,REST_MOUSE
                move.l  (A1)+,(A0)
                move.l  (A1)+,4(A0)
                rts

*********************************************
*         AFFICHAGE D'UN CHIFFRE            *
*********************************************

* PARAMETRES : ADRESSE ECRAN DANS A0
*              CHIFFRE DANS D0 (EN .W)

AFF_CHIFFRE:
                movea.l A0,A6
                moveq   #0,D1
                moveq   #0,D6
                moveq   #0,D7

                move.w  D0,D1
                divu    #100,D1
                move.w  D1,D7
                add.w   D1,D1
                add.w   D1,D1
                lea     TAB_CHIFFRE,A2
                movea.l 0(A2,D1.w),A1
                bsr     AFF_NUMBER
                lea     8(A0),A6
                moveq   #0,D1
                moveq   #0,D6
                move.w  D0,D1
                mulu    #100,D7
                sub.w   D7,D1
                divu    #10,D1
                move.w  D1,D6
                mulu    #10,D6
                add.w   D6,D7
                add.w   D1,D1
                add.w   D1,D1
                movea.l 0(A2,D1.w),A1
                bsr     AFF_NUMBER
                lea     16(A0),A6
                moveq   #0,D1
                move.w  D0,D1
                sub.w   D7,D1
                add.w   D1,D1
                add.w   D1,D1
                movea.l 0(A2,D1.w),A1
                bsr     AFF_NUMBER
                rts

*********************************************
*       AFFICHAGE D'UN NOMBRE 0-9           *
*********************************************

*  A6=ADR ECRAN
*  A1=ADR FONTE

AFF_NUMBER:
                move.w  #15,D4
AFF_LE_NOMBRE:
                move.l  (A1),(A6)
                move.l  4(A1),4(A6)
                lea     160(A1),A1
                lea     160(A6),A6
                dbra    D4,AFF_LE_NOMBRE
                rts

INFOS:
                move    #$2700,SR
                move.l  #HBL_NULL,$70.w
                move    #$2300,SR

                bsr     CLEAR_SCR

                movem.l PALETTE_12,D0-D7
                movem.l D0-D7,$FFFF8240.w

                lea     TXT_INFO,A0
                bsr     AFF_MESS

                move    #$2700,SR
                move.l  #VBL_PRES,$70.w
                move    #$2300,SR

                bsr     AFF_PAGE_MENU
                bra     WAIT_MENU

AFF_MESS:
                lea     TAB_FNT,A6
                lea     ECRAN,A2

                moveq   #0,D6
                moveq   #0,D3

DEB_TXT:
                move.w  D6,D1
                moveq   #0,D0
                move.b  (A0)+,D0
                beq.s   NEXT_LIG
                cmp.b   #1,D0
                beq.s   NEXT_PAGE
                cmp.b   #$FF,D0
                beq.s   FIN_INFOS
                sub.b   #' ',D0
                add.w   D0,D0
                add.w   D0,D0
                movea.l 0(A6,D0.w),A1
                moveq   #15,D7
AFF_LETTRE:
                move.l  (A1),0(A2,D1.w)
                move.l  4(A1),4(A2,D1.w)
                lea     160(A1),A1
                add.w   #160,D1
                dbra    D7,AFF_LETTRE
                add.w   #8,D6
                bra     DEB_TXT
NEXT_LIG:
                add.w   #160*17,D3
                move.w  D3,D6
                bra     DEB_TXT

NEXT_PAGE:
                btst    #7,JOY_PARAM
                beq.s   NEXT_PAGE
WAIT_SPAC:
                btst    #7,JOY_PARAM
                bne.s   WAIT_SPAC

                move.b  #0,BOUTON
                move.b  #0,JOY_PARAM

                movem.l D0-A6,-(SP)
                bsr     CLEAR_SCR
                movem.l (SP)+,D0-A6
                moveq   #0,D6
                moveq   #0,D3
                bra     DEB_TXT

FIN_INFOS:
                btst    #7,JOY_PARAM
                beq.s   FIN_INFOS
WAIT_SPAC2:
                btst    #7,JOY_PARAM
                bne.s   WAIT_SPAC2

                move.b  #0,BOUTON
                move.b  #0,JOY_PARAM

                moveq   #0,D6
                moveq   #0,D3
                rts

AFF_MESS2:
                lea     TAB_FNT,A6
                lea     ECRAN,A2

                moveq   #0,D6
                moveq   #0,D3

DEB_TXT2:
                move.w  D6,D1
                moveq   #0,D0
                move.b  (A0)+,D0
                beq.s   NEXT_LIG2
                cmp.b   #1,D0
                beq.s   NEXT_PAGE2
                cmp.b   #$FF,D0
                beq.s   FIN_INFOS2
                sub.b   #' ',D0
                add.w   D0,D0
                add.w   D0,D0
                movea.l 0(A6,D0.w),A1
                moveq   #15,D7
AFF_LETTRE2:
                move.l  (A1),0(A2,D1.w)
                move.l  4(A1),4(A2,D1.w)
                lea     160(A1),A1
                add.w   #160,D1
                dbra    D7,AFF_LETTRE2
                add.w   #8,D6
                bra     DEB_TXT2
NEXT_LIG2:
                add.w   #160*17,D3
                move.w  D3,D6
                bra     DEB_TXT2

NEXT_PAGE2:
                moveq   #0,D6
                moveq   #0,D3
                bra     DEB_TXT2

FIN_INFOS2:
                moveq   #0,D6
                moveq   #0,D3
                rts

*********************************************
*            ZONE DE DONNEES                *
*********************************************
                DATA

POS_PTR:
                DC.W 160*69
OLD_POS_PTR:
                DC.W 160*69
OPTI:
                DC.W 0
PAL_PUSH:
                DC.W $00,$04,$05,$06,$07,$0444,$0555,$0666,$0777
                DC.W $0400,$0500,$0600,$0700,$0760,$0773,$0777
PAL_MENU:
                DC.W $00,$15,$0310,$0410,$0520,$0630,$0731,$0741,$0760
                DC.W $0666,$0222,$0333,$0444,$0555,$0666,$0777

OLD_PAL:                                * ANCIENNE PALETTE
                DS.W 16
NILL:                                   * PALETTE NOIRE
                DCB.W 16

PALETTE:                                * PALETTE DU FOND
                DC.W $00,$0111,$0222,$0333,$0444,$0555,$0666,$0777
                DC.W $0127,$27,$17,$07,$06,$05,$04,$77

PALETTE_12:
                DC.W $00,$0111,$0222,$0333,$0444,$0555,$0666,$0777
PALETTE_2:
                DC.W $0310,$0410,$0520,$0630,$0741,$0751,$0760,$0777

BLOCK:                                  * BLOCK N. 1
                DC.L BLK
TAB_BLK:
A               EQU 16*8
                DC.L BLK+A*8
                DC.L BLK+A*5
                DC.L BLK+A*4
                DC.L BLK+A*10
                DC.L BLK+A
                DC.L BLK
                DC.L BLK+A*3
                DC.L BLK+A*9
                DC.L BLK+A*2
                DC.L BLK+A*6
                DC.L BLK+A*7

PAL_BLK:
                DC.W $00,$0707,$0222,$0333,$0444,$0555,$0666,$0777
                DC.W $0444,$0555,$0410,$0521,$0632,$00,$0333,$00

                DC.W $00,$0770,$0222,$0333,$0444,$0555,$0666,$0777
                DC.W $0410,$0521,$0500,$0600,$30,$40,$0300,$00

                DC.W $00,$77,$0222,$0333,$0444,$0555,$0666,$0777
                DC.W $06,$07,$0333,$0444,$00,$00,$05,$00

                DC.W $00,$07,$0220,$0330,$0440,$0550,$0660,$0770
                DC.W $00,$00,$00,$0444,$0666,$00,$00,$00

                DC.W $00,$70,$0200,$0300,$0400,$0500,$0600,$0700
                DC.W $0222,$0333,$0444,$0555,$0666,$0777,$0111,$00

                DC.W $00,$0770,$02,$03,$04,$05,$06,$07
                DC.W $30,$40,$0420,$0521,$0222,$0333,$0444,$0606

                DC.W $00,$0777,$0202,$0303,$0404,$0505,$0606,$0707
                DC.W $0457,$00,$00,$00,$00,$00,$0347,$00

                DC.W $00,$77,$0222,$0333,$0444,$0555,$0666,$0FFF
                DC.W $00,$0750,$00,$0600,$0700,$0730,$00,$0740

                DC.W $00,$0700,$0222,$0333,$0444,$0555,$0666,$0FFF
                DC.W $0410,$0520,$30,$40,$00,$00,$0300,$00

                DC.W $00,$0707,$0222,$0333,$0444,$0555,$0666,$0FFF
                DC.W $0444,$0555,$0666,$0777,$0500,$0600,$0333,$0700

                DC.W $00,$0770,$0222,$0333,$0444,$0555,$0666,$0FFF
                DC.W $0457,$0567,$0555,$0666,$0777,$0740,$0347,$0750


OBJETS:                                 * OBJETS
	INCLUDE	LISTE.S
FIN_OBJETS:                             * FIN DES OBJETS

MATRICE:                                * MATRICE MELANGEE
                DS.B 180
SOLUTION:                               * MATRICE SOLUTION
                DS.B 180
SAVE:                                   * ZONE DE SAUVEGARDE DES INTERS
                DS.L 5
KEY:                                    * TOUCHE APPUYEE
                DC.B 0
JOY_PARAM:                              * PARAM JOYSTICK ($118)
                DC.B 0
BOUTON:                                 * BOUTON (0 OU 1)
                DC.B 0
                EVEN
XMOUSE:                                 * X JOYSTICK
                DC.W 8
YMOUSE:                                 * Y JOYSTICK
                DC.W 16*160
BUF_MOUSE:                              * BUFFER DE SAUV. POUR LE POINTEUR
                DC.L $070000+160*230
                DS.B 16*8
TIME_SECOND:                            * TEMPS LIMITE
                DS.W 1
SCORE:
                DS.W 1
SYNCHRO:                                * COMPTEUR INTERNE
                DC.W 50
NBLK:                                   * NUMERO DU BLOCK ACTUEL
                DC.W 0
NBLK2:
                DC.W 0
BUF_AFF:                                * BUFFER
                DC.L 0
RELAT_POS:                              * POSITION RELATIVE DU PTR JOY
                DC.W 0
RELAT_POS2:
                DC.W 0
NAME:
                DS.B 8
FOND:                                   * TEXTURE DE FOND
                INCBIN 'FOND.PI1'
FNT:
                INCBIN 'FNT.IMG'
BARRE:
                INCBIN 'BARRE.IMG'
PTR_PRES:
                INCBIN 'COPYB1.IMG'
MENU:
                INCBIN 'MENU.IMG'
PUSH_IT:
                INCBIN 'PUSH.IMG'
BLK:
                INCBIN 'BLOCKS.IMG'
Z               EQU FNT+160*16+6*8
TAB_CHIFFRE:
                DC.L Z+9*8
M               SET 0
                REPT 9
                DC.L Z+M
M               SET M+8
                ENDR

SPA             EQU FNT+16*160*2+5*8
K               EQU 160*16
TAB_FNT:
                DC.L SPA
                DC.L SPA-8*2
                DC.L FNT+K+8*16
                DC.L SPA
                DC.L SPA
                DC.L SPA
                DC.L SPA        * &
                DC.L SPA        * '
                DC.L FNT+K*2+8
                DC.L FNT+K*2+16
                DC.L SPA,SPA    * * +
                DC.L FNT+K+8*19 * ,
                DC.L SPA
                DC.L FNT+K*2
                DC.L SPA
                DC.L FNT+K+8*15 * 0
                DC.L FNT+K+8*6
                DC.L FNT+K+8*7
                DC.L FNT+K+8*8
                DC.L FNT+K+8*9
                DC.L FNT+K+8*10
                DC.L FNT+K+8*11
                DC.L FNT+K+8*12
                DC.L FNT+K+8*13
                DC.L FNT+K+8*14
                DC.L FNT+K+8*17 * :
                DC.L FNT+K+8*18 * ;
                DC.L SPA,SPA,SPA
                DC.L SPA-8
                DC.L SPA
                DC.L FNT,FNT+8,FNT+8*2,FNT+8*3,FNT+8*4
                DC.L FNT+8*5,FNT+8*6,FNT+8*7,FNT+8*8,FNT+8*9
                DC.L FNT+8*10,FNT+8*11,FNT+8*12,FNT+8*13,FNT+8*14
                DC.L FNT+8*15,FNT+8*16,FNT+8*17,FNT+8*18,FNT+8*19
                DC.L FNT+K,FNT+K+8,FNT+K+8*2,FNT+K+8*3 * X
                DC.L FNT+K+8*4,FNT+K+8*5

TXT_INFO:
                DC.B '       PUSH IT      ',0
                DC.B 0
                DC.B '  THE NEW MCS GAME  ',0
                DC.B '  CODED BY MAGNUM   ',0
                DC.B 'IDEA TAKEN FROM THE ',0
                DC.B 'C64. (THANX GADGET).',0
                DC.B '  GFX BY ZORGLUB.   ',0
                DC.B ' SPONSORED BY :',0
                DC.B '  GEORGES KILLIANS',0
                DC.B ' HELLO TO EQUINOX ',0
                DC.B '....................',0
                DC.B 1
                DC.B '    HOW TO PLAY ?   ',0
                DC.B '....................',0
                DC.B 'USE THE JOYSTICK TO',0
                DC.B 'MOVE THE CURSOR.',0
                DC.B 'WHEN ON A BLOCK ;',0
                DC.B 'PRESS  FIRE TO TAKE',0
                DC.B 'IT. RELEASE FIRE TO',0
                DC.B 'PUT IT. THE AIM OF',0
                DC.B 'THIS GAME IS TO MAKE',0
                DC.B 'SOME FORMS.',0,1

                DC.B 'THE FORM APPEARS,',0
                DC.B 'THEN PRESS FIRE AND',0
                DC.B 'THE GAME BEGINS.',0
                DC.B 'PRESS HELP AND THE',0
                DC.B 'FORM IS SHOWN AGAIN',0
                DC.B 'BUT TIME IS NOT ',0
                DC.B 'STOPPED...',1

                DC.B ' WHEN A FORM IS MADE',0
                DC.B ' THE TIME LEFT IS',0
                DC.B 'ADDED TO THE SCORE.',0
                DC.B 'PRESS UNDO TO QUIT',0
                DC.B 'THE GAME. FOR EACH',0
                DC.B 'LEVEL, A PASSWORD',0
                DC.B 'IS GIVEN. YOU CAN',0
                DC.B 'BEGIN AT ANY LEVEL',0
                DC.B 'BY ENTERING THE',0
                DC.B ' RIGHT PASSWORD..',1

                DC.B ' HIGHSCORES ARE',0
                DC.B 'SAVED TO DISK SO',0
                DC.B ' REMOVE THE DISK',0
                DC.B 'PROTECTION....',0
                DC.B '....................',0
                DC.B 'HELLO TO DELTA FORCE',0
                DC.B '  (NICE MATCH IT).  ',0
                DC.B 0
                DC.B ' AND REMEMBER :',0
                DC.B 'THE FRENCH ALLIANCE',0
                DC.B 'WILL LIVE FOREVER...',0
                DC.B $FF
WELL_DONE:
                DC.B 0,0
                DC.B '      WELL DONE     ',0
                DC.B 0
                DC.B '   LEVEL COMPLETED  ',0
                DC.B 'PASSWORD IS : '
PASSWORD:
                DC.B 'AAAAAA',0
                DC.B 0,0
                DC.B 'PRESS FIRE TO GO ON.',0
                DC.B '....................',$FF
                EVEN
TXT_PASS:
                DC.B ' ENTER PASSWORD',0,0
                DC.B ' ......',$FF
                EVEN
BAD_PASS:
                DC.B 0,0,0,0
                DC.B 0,0,0
                DC.B '   BAD PASSWORD',0
                DC.B '    PRESS FIRE',$FF
                EVEN
YOU_LOST:
                DC.B '      TIME OUT !    ',0
                DC.B '....................',0,0
                DC.B ' YOUR SCORE IS : ',$FF
                EVEN
FIRE_WORK:
                DC.B 0,0,0,0,0,0,0,0,0,0
                DC.B ' PRESS FIRE ',$FF
                EVEN
YEAHHH:
                DC.B 0,0,0
                DC.B 'YOU HAVE A HIGH',0
                DC.B 'SCORE !!!',0
                DC.B ' PLEASE ENTER YOUR ',0
                DC.B 'NAME : ........',$FF
                EVEN
WON_TXT:                                * TEXTE BIDON POUR L'INSTANT

                DC.B 'WELL DONE !!!',0
                DC.B ' YOU WON...',$FF
                EVEN
TAB_SCORES:
                DC.B 'MAGNUM  '
                DC.W 753
                DC.B 'AXEL F. '
                DC.W 120
                DC.B 'GADGET  '
                DC.W 80
                DC.B 'DREAMER '
                DC.W 75
                DC.B 'HOOLIGAN'
                DC.W 60
                DC.B 'ZORGLUB '
                DC.W 45
                DC.B 'ALTAIR  '
                DC.W 40
                DC.B 'MARIO   '
                DC.W 30
                DC.B 'P.F.    '
                DC.W 25
                DC.B 'GALAHAD '
                DC.W 19
FIN_SCORE:
                DS.B 10
FTAB_SCORE:
                DS.B 10
                EVEN
BUF_NAM:
                DC.B '                   ',0
                DC.B '                   ',0
                DC.B '                   ',0
                DC.B '                   ',0
                DC.B '                   ',0
                DC.B '                   ',0
                DC.B '                   ',0
                DC.B '                   ',0
                DC.B '                   ',0
                DC.B '                   ',$FF
                EVEN
TAB_SCAN:
                DC.B 0
                DC.B 0
                DC.B '1234567890',0,0,0,0,'AZERTYUIOP',0,0 * 1B
                DC.B $FF,0,'QSDFGHJKLM',0 * 28
                DC.B 0,0,0,'WXCVBN,;:',0 * 35
                DC.B 0,0,38,' ',0,0,0,0,0,0,0,0,0,0,0 * 44
                DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 * 55
                DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,'()' * 64
                DC.B 0,0,'7894561230.',$FF
                DS.B 300
                EVEN
PTR_CHEAT
	DC.W	0
CHEAT_ON
	DC.W	0
CHEAT_CODE
	INCBIN	CHEAT.BIN
F_CHEAT
	EVEN
ZIK:                                    * MUSIQUE
                INCBIN 'KILGAM.MUS'
SAVD0:
                END
