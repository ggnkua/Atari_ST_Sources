******************************************
*  THIS IS THE INTRO OF THE DELIRIOUS 4  *
*  CODED THE 16/07/91 BY MAGNUM OF M.C.S *
*       (FRENCH ALLIANCE)                *
******************************************

DEB:
	MOVE.L	#0,-(SP)		;SYS
	MOVE.W	#$20,-(SP)	;SYS
	TRAP	#1		;SYS
	ADDQ.L	#6,SP		;SYS
	
	MOVE.W	#$2700,SR
	BRA	DEBUT

ECRAN           EQU $070000
ECRAN2           EQU $078000

                DC.B "HELLO LAMERS !!!    IF YOU WANNA RIP THIS CODE"
                DC.B " YOU'RE NOT LOOKING AT THE RIGHT ADRESSES."
                DC.B " AND IF YOU TRACE THIS PROGRAM, YOUR MONITOR MAY EXPLODE,"
                DC.B " YOUR DISC DRIVE COULD BE ENDOMMAGED, AND YOUR MMU"
                DC.B " COULD HAVE SOME STRANGE SYMPTOMS."
                DC.B "   HEY OVR YOU'RE TOO LAME TO UNDERSTAND THIS CODE."
                DC.B " (C) MAGNUM 1991  (MCS/FRENCH ALLIANCE)    "

                EVEN

***************************************************

DEBUT:                                  * DEBUT DU PROGRAMME

                clr.b   $FFFF8260.w
                move.b  #$07,$FF8201
                move.b  #0,$FF8203

                movem.l NILL,D0-D7  * ALL BLACKS
                movem.l D0-D7,$FFFF8240.w


                move.b  #$12,$FFFC02    * NO MOUSE

                lea     SAVE,A0
                move.l  $70.w,(A0)+
	      MOVE.L  $118.W,(A0)+
                move.l  $0120.w,(A0)+
                move.l  $0134.w,(A0)+
                move.b  $FFFFFA07.w,(A0)+
                move.b  $FFFFFA09.w,(A0)+
                move.b  $FFFFFA13.w,(A0)+
                move.b  $FFFFFA17.w,(A0)+
                move.b  $FFFFFA19.w,(A0)+
                move.b  $FFFFFA1F.w,(A0)+

                move.b  #1,$FFFFFA07.w
                move.b  #1,$FFFFFA13.w
                move.b  #$40,$FFFA09
                move.b  #$40,$FFFA15
                bclr    #3,$FFFFFA17.w
                move.l  #NEW_VBL,$70.w
                move.l  #HBL,$0120.w
                bsr     INIT_MOUSE
                move    #$2300,SR

                move.w  #$0777,$FFFF8242.w
                lea     BOMBES,A0
                lea     ECRAN+160*92,A1
                moveq   #15,D1
AFF_BOMBES:
                move.w  (A0)+,D2
                move.w  D2,(A1)
                move.w  D2,8(A1)
                move.w  D2,16(A1)
                move.w  D2,24(A1)
                move.w  D2,32(A1)
                move.w  D2,40(A1)
                move.w  D2,48(A1)
                move.w  D2,56(A1)
                move.w  D2,64(A1)
                move.w  D2,72(A1)
                move.w  D2,80(A1)
                move.w  D2,88(A1)
                move.w  D2,96(A1)
                move.w  D2,104(A1)
                move.w  D2,112(A1)
                move.w  D2,120(A1)
                lea     160(A1),A1
                dbra    D1,AFF_BOMBES

                moveq   #10,D7
CLIGNOTE:
                moveq   #2,D0
                bsr     WAIT_SECONDS

                move.b  #14,$FF8800     * ALLUME LED
                move.b  #13,$FF8802

                moveq   #2,D0
                bsr     WAIT_SECONDS

                move.b  #14,$FF8800
                move.b  #14,$FF8802

                dbra    D7,CLIGNOTE

                movem.l DESKTOP+2,D0-D7
                movem.l D0-D7,$FFFF8240.w

                bsr     DECAL

                lea     DESKTOP+34,A0
                lea     ECRAN,A1
                move.w  #40*11-1,D1
AFF_DESKTOP1:
                move.l  (A0)+,(A1)+
                dbra    D1,AFF_DESKTOP1

                lea     DESKTOP+34+12*160+88,A0
                lea     ECRAN+11*160,A1
                move.w  #20*189-1,D1
AFF_DESKTOP2:

                move.l  (A0),(A1)
                move.l  4(A0),4(A1)
                lea     8(A1),A1
                dbra    D1,AFF_DESKTOP2
                move.l  #AFF_MOUSE,PEK_MOUSE+2

                lea     DESKTOP+34+12*160,A0
                lea     ECRAN+12*160,A1
                move.w  #188-1,D1
AFF_DESKTOP3:
                movem.l (A0),D2-D5
                movem.l D2-D5,(A1)
                movem.l 16(A0),D2-D5
                movem.l D2-D5,16(A1)
                lea     160(A0),A0
                lea     160(A1),A1
                dbra    D1,AFF_DESKTOP3
WAIT_SPACE:
                cmpi.b  #4,BOUTON
                bne.s   WAIT_SPACE
                cmpi.w  #71,XMOUSE
                bgt.s   WAIT_SPACE
                cmpi.w  #13,YMOUSE
                blt.s   WAIT_SPACE
                cmpi.w  #50,YMOUSE
                bgt.s   WAIT_SPACE

                bsr     INVERT_DRVA

                moveq   #3,D0
                bsr     WAIT_SECONDS

                move.w  #0,CPT_VBL
WAIT_SPACE2:
                cmpi.b  #4,BOUTON
                bne.s   WAIT_SPACE2
                cmpi.w  #71,XMOUSE
                bgt.s   PAS_DRVA
                cmpi.w  #13,YMOUSE
                blt.s   PAS_DRVA
                cmpi.w  #50,YMOUSE
                bgt.s   PAS_DRVA
                cmpi.w  #15,CPT_VBL
                ble.s   DOUBLE_CLICK
PAS_DRVA:
                move.w  #0,CPT_VBL
                bsr     DRVA_NORMAL
                moveq   #10,D0
                bsr     WAIT_SECONDS
                bra.s   WAIT_SPACE
DOUBLE_CLICK:
                move    #$2700,SR
                move.l  #NULL_IT,$0118.w
                move.l  #VBL2,$70.w
                move    #$2300,SR
                bsr     EFF_MOUSE
                move.w  XMOUSE,D0
                move.w  YMOUSE,D1
                mulu    #160,D1
                lea     SPR2+64*19,A0   * +64*19
                lea     ECRAN,A1
                adda.l  D1,A1
                move.w  D0,D1
                and.w   #$0F,D0
                and.w   #-4,D0
                add.w   D0,D0
                add.w   D0,D0

                adda.w  D0,A0
                and.w   #$FFF0,D1

                lsr.w   #1,D1
                adda.w  D1,A1

                move.l  A1,BUF_ECRAN
                bsr     AFF_ABEILLE

                lea     TAB_MOUSE,A2
                lea     TAB_SPRM,A3
TEST:
                bsr     WAIT_VBL
                bsr     EFF_MOUSE2
                movea.l BUF_ECRAN,A1
                movea.l (A3)+,A0
                adda.w  (A2)+,A0
                adda.w  (A2)+,A1
                movea.l A0,A6
                move.l  A1,BUF2
                bsr     AFF_ABEILLE
                cmpa.l  #FTAB_MOUSE,A2
                beq.s   FIN_AFF_MOUSE
                cmpa.l  #FTAB_SPRM,A3
                bne.s   PAS_F_SPM
                lea     TAB_SPRM,A3
PAS_F_SPM:
                dbra    D6,TEST

FIN_AFF_MOUSE:
                bsr     EFF_MOUSE2
                bsr     STOCK_THIS

                movea.l BUF2,A1
                movea.l A6,A0
                bsr     AFF_ABEILLE

                lea     TAPETTE,A0
                lea     ECRAN+160*126+48,A1
                bsr     AFFICH_TAP

                bsr     WAIT_VBL

                bsr     REST_THIS

                movea.l BUF2,A1
                movea.l A6,A0
                bsr     AFF_ABEILLE

                lea     TAPETTE2,A0
                lea     ECRAN+160*126+48,A1
                bsr     AFFICH_TAP

                bsr     WAIT_VBL

                bsr     REST_THIS

                movea.l BUF2,A1
                movea.l A6,A0
                bsr     AFF_ABEILLE

                lea     TAPETTE3,A0
                lea     ECRAN+160*126+48,A1
                bsr     AFFICH_TAP

                bsr     WAIT_VBL

                bsr     REST_THIS

                movea.l BUF2,A1
                movea.l A6,A0
                bsr     AFF_ABEILLE

                lea     TAPETTE4,A0
                lea     ECRAN+160*126+48,A1
                bsr     AFFICH_TAP

                bsr     WAIT_VBL

                moveq   #4,D5
ECRASE:
                bsr     WAIT_VBL
                move.l  D5,-(SP)
                bsr     REST_THIS

PEK_SP3:        movea.l #SPR3,A0
                movea.l BUF2,A1
                bsr     AFF_UNDER

                lea     TAPETTE4,A0
                lea     ECRAN+160*126+48,A1
                bsr     AFFICH_TAP
                addi.w  #24*16,PEK_SP3+4
                move.l  (SP)+,D5
                dbra    D5,ECRASE

                move.w  #50,D0
                bsr     WAIT_SECONDS

                lea     DESKTOP+2,A0
                bsr     FADE_OUT

                bsr     CLEAR_SCREEN

                lea     FIRST_TXT,A0
                bsr     AFF_TEXTE

                moveq   #10,D0
                bsr     WAIT_SECONDS

                lea     FONTE+2,A0
                bsr     FADE_IN

                moveq   #10,D0
                bsr     WAIT_SECONDS

                bsr     FONTE_OUT

                lea     THERE_WAS,A0
                bsr     AFF_TEXTE

                moveq   #10,D0
                bsr     WAIT_SECONDS

                lea     FONTE+2,A0
                bsr     FADE_IN

                moveq   #10,D0
                bsr     WAIT_SECONDS

                bsr     FONTE_OUT

                lea     OVR+34,A0
                lea     ECRAN,A1
                move.w  #7999,D1
AFF_OVR:
                move.l  (A0)+,(A1)+
                dbra    D1,AFF_OVR

                moveq   #20,D0
                bsr     WAIT_SECONDS

                lea     OVR+2,A0
                bsr     FADE_IN

                moveq   #20,D0
                bsr     WAIT_SECONDS

                lea     OVR+2,A0
                bsr     FADE_OUT

                bsr     CLEAR_SCREEN

                lea     NOW,A0
                bsr     AFF_TEXTE

                moveq   #10,D0
                bsr     WAIT_SECONDS

                lea     FONTE+2,A0
                bsr     FADE_IN

                moveq   #10,D0
                bsr     WAIT_SECONDS

                bsr     FONTE_OUT

                	bsr     AFF_ALLIANCE

		MOVE.W	#196,D5
LIG_MAGNUM
          	bsr	WAIT_VBL
          	ADDQ.W	#1,LIG_Y
		DBRA	D5,LIG_MAGNUM

		MOVE.W	#200,D5
WAIT_MAUD
		BSR	WAIT_VBL
		DBRA	D5,WAIT_MAUD

		MOVE.W	#196,D5
LIG_MAGNUM2
          	bsr     WAIT_VBL
          	SUBQ.W	#1,LIG_Y
		DBRA	D5,LIG_MAGNUM2

                lea     $FF8240,A6
                REPT 8
                move.l  #0,(A6)+
                ENDR

                move    #$2700,SR
                move.l  #VBL2,$70.w
                move.l  #HBL,$0120.w
                move    #$2300,SR

                bsr     CLEAR_SCREEN

                lea     PRESENT,A0
                bsr     AFF_TEXTE

                moveq   #10,D0
                bsr     WAIT_SECONDS

                lea     FONTE+2,A0
                bsr     FADE_IN

                moveq   #10,D0
                bsr     WAIT_SECONDS

                bsr     FONTE_OUT

                bsr     CLEAR_SCREEN

                lea     _A,A0
                bsr     AFF_TEXTE

                moveq   #10,D0
                bsr     WAIT_SECONDS

                lea     FONTE+2,A0
                bsr     FADE_IN

                moveq   #10,D0
                bsr     WAIT_SECONDS

                bsr     FONTE_OUT

                bsr     CLEAR_SCREEN

                lea     MCS_LOGO,A0
                lea     ECRAN+160*76+40,A1
                move.w  #47,D1
LIG_MCS_LOGO:
                move.w  #19,D2
COL_MCS_LOGO:
                move.l  (A0)+,(A1)+
                dbra    D2,COL_MCS_LOGO
                lea     80(A1),A1
                dbra    D1,LIG_MCS_LOGO

                lea     PAL_LOG_MCS,A0
                bsr     FADE_IN

                move.w  #100,D0
                bsr     WAIT_SECONDS

                lea     PAL_LOG_MCS,A0
                bsr     FADE_OUT

                bsr     CLEAR_SCREEN

                lea     PRODUCT,A0
                bsr     AFF_TEXTE

                lea     FONTE+2,A0
                bsr     FADE_IN

                moveq   #10,D0
                bsr     WAIT_SECONDS

                bsr     FONTE_OUT

                bsr     CLEAR_SCREEN

                lea     THE,A0
                bsr     AFF_TEXTE

                moveq   #10,D0
                bsr     WAIT_SECONDS

                lea     FONTE+2,A0
                bsr     FADE_IN

                moveq   #10,D0
                bsr     WAIT_SECONDS

                bsr     FONTE_OUT

                bsr     CLEAR_SCREEN
                MOVEM.L	NILL,D0-D7
                MOVEM.L	D0-D7,$FFFF8240.W
	      MOVEM.L	D0-D7,PAL_NUL

MAGNUM:
	MOVE.B	#$7,$FFFF8201.W
	MOVE.B	#$80,$FFFF8203.W

                lea     LEMMING,A0
                lea     ECRAN+40,A1

                move.w  #199,D1
LIG_LEM:
                move.w  #17,D2
COL_LEM:
                move.l  (A0)+,(A1)+
                dbra    D2,COL_LEM
                lea     88(A1),A1
                dbra    D1,LIG_LEM

                lea     OEIL,A0
                bsr     AFF_OEIL

                lea     PIED,A0
                bsr     AFF_PIED

                lea     ECRAN2,A0
                lea     DEL4+34,A1
                move.w  #7999,D1
AFF_DEL4:
                move.l  (A1)+,(A0)+
                dbra    D1,AFF_DEL4

	MOVEM.L	DEL4+2,D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W

                lea     STCONNEXION,A0
                lea     MUSIC,A1
                move.l  A1,12(A0)
                move.w  #0,16(A0)
                bsr     STCONNEXION

	MOVE.W	#$2700,SR
          move.l  #VBL,$70.w
          move.b  #33,$FFFFFA07.w
          move.b  #33,$FFFFFA13.w
          move.b  #1,$FFFFFA19.w
          move.b  #FRQ_DATA,$FFFFFA1F.w
          lea     SOUNDCHIP,A0
          move.l  A0,$0134.w
          move    #$2300,SR

WAIT_1:
          tst.w   VBL_FLAG
          beq.s   WAIT_1
          move.w  #0,VBL_FLAG
          cmpi.l  #$05,INSTR2
          bne.s   WAIT_1

                movem.l PAL,D0-D7
                movem.l D0-D7,$FFFF8240.w

                move.b  #$07,$FF8201
                move.b  #$00,$FF8203
	MOVE.L	#HBL_SCROL1,PEK_HBL_SCROL+2
	MOVE.L	#SCROLL_VBL,PEK_SCROL+2
WAIT:
                cmpi.l  #$01,INSTR1
                bne.s   PAS_ESC1
                move.l  #RP1,PEK_PIED+2
PAS_ESC1:
                cmpi.l  #$01,INSTR2
                bne.s   PAS_ESC2
                move.l  #RP1,PEK_PIED+2
PAS_ESC2:
                cmpi.l  #$01,INSTR3
                bne.s   PAS_ESC3
                move.l  #RP1,PEK_PIED+2
PAS_ESC3:
                cmpi.l  #$01,INSTR4
                bne.s   PAS_ESC4
                move.l  #RP1,PEK_PIED+2
PAS_ESC4:
                cmpi.l  #$06,INSTR1
                bne.s   PAS_NO1
                move.l  #RO1,PEK_OEIL+2
PAS_NO1:
                cmpi.l  #$06,INSTR2
                bne.s   PAS_NO2
                move.l  #RO1,PEK_OEIL+2
PAS_NO2:
                cmpi.l  #$06,INSTR3
                bne.s   PAS_NO3
                move.l  #RO1,PEK_OEIL+2
PAS_NO3:
                cmpi.l  #$06,INSTR4
                bne.s   PAS_NO4
                move.l  #RO1,PEK_OEIL+2
PAS_NO4:
                cmpi.l  #$05,INSTR1
                bne.s   PAS_NO5
                move.l  #RO1,PEK_OEIL+2
PAS_NO5:
                cmpi.l  #$05,INSTR2
                bne.s   PAS_NO6
                move.l  #RO1,PEK_OEIL+2
PAS_NO6:
                cmpi.l  #$05,INSTR3
                bne.s   PAS_NO7
                move.l  #RO1,PEK_OEIL+2
PAS_NO7:
                cmpi.l  #$05,INSTR4
                bne.s   PAS_NO8
                move.l  #RO1,PEK_OEIL+2
PAS_NO8:
          bra     	WAIT

SCROLL_VBL
PEKM
	MOVE.L	#MESS,A0
PEK_SCREEN
	MOVE.L	#$70000,A1
	LEA	TAB_FNT3,A2
	MOVEQ	#0,D1
	
	MOVE.B	(A0),D1
	BEQ	WAIT_TIME
	CMP.B	#1,D1
	BEQ	FIN_TEXTE
	SUB.B	#' ',D1
	ADD.W	D1,D1
	ADD.W	D1,D1
	MOVE.L	(A2,D1.W),A3
M	SET	0
	REPT	8
	MOVE.B	M(A3),M(A1)
	MOVE.B	M+2(A3),M+2(A1)
	MOVE.B	M+4(A3),M+4(A1)
	MOVE.B	M+6(A3),M+6(A1)
	MOVE.B	#$FF,M+1(A1)
	MOVE.B	#$FF,M+3(A1)
	MOVE.B	#$FF,M+5(A1)
	MOVE.B	#$FF,M+7(A1)
M	SET	M+160
	ENDR

	MOVE.B	1(A0),D1
	BEQ	WAIT_TIME
	CMP.B	#1,D1
	BEQ	FIN_TEXTE
	SUB.B	#' ',D1
	ADD.W	D1,D1
	ADD.W	D1,D1
	MOVE.L	(A2,D1.W),A3
M	SET	0
	REPT	8
	MOVE.B	M(A3),M+1(A1)
	MOVE.B	M+2(A3),M+3(A1)
	MOVE.B	M+4(A3),M+5(A1)
	MOVE.B	M+6(A3),M+7(A1)
	MOVE.B	#$FF,M+8(A1)
	MOVE.B	#$FF,M+10(A1)
	MOVE.B	#$FF,M+12(A1)
	MOVE.B	#$FF,M+14(A1)
M	SET	M+160
	ENDR

	ADD.L	#2,PEKM+2
	ADD.L	#8,PEK_SCREEN+2
	MOVE.L	#VBL_MAG_MCS_2,PEK_SCROL+2
	RTS

WAIT_TIME
	MOVEQ	#0,D0
M	SET	0
	REPT	8
	MOVE.B	D0,M(A1)
	MOVE.B	D0,M+2(A1)
	MOVE.B	D0,M+4(A1)
	MOVE.B	D0,M+6(A1)
M	SET	M+160
	ENDR
	MOVE.L	#$70000,PEK_SCREEN+2
	ADDQ.L	#1,PEKM+2
	MOVE.L	#VBL_MAG_MCS,PEK_SCROL+2
	RTS
FIN_TEXTE
	MOVE.L	#$70000,PEK_SCREEN+2
	MOVE.L	#MESS,PEKM+2
	MOVE.L	#VBL_MAG_MCS,PEK_SCROL+2
	RTS
VBL_MAG_MCS
	SUBQ.W	#1,CNT_VBL
	TST.W	CNT_VBL
	BNE.S	PAS_MAUD
	MOVE.W	#100,CNT_VBL
	MOVE.L	#SCROLL_VBL,PEK_SCROL+2
PAS_MAUD
	RTS
VBL_MAG_MCS_2
	SUBQ.W	#1,CNT_VBL2
	TST.W	CNT_VBL2
	BNE.S	PAS_CLOTILDE
	MOVE.W	#2,CNT_VBL2
	MOVE.L	#SCROLL_VBL,PEK_SCROL+2
PAS_CLOTILDE
	RTS
CNT_VBL
	DC.W	100
CNT_VBL2
	DC.W	2
VBL:
	CLR.B	$FFFFFA1B.W
	MOVE.B	#1,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
PEK_HBL_SCROL
	MOVE.L	#HBN,$120.W

                clr.b   $FFFF8260.w
                cmpi.b  #$39,$FFFC02
                beq     FIN

                bsr     STCONNEXION+8
PEK_PIED:
                jsr     NULL
PEK_OEIL:
                jsr     NULL
                bsr     EQUA
PEK_SCROL
	JSR	NULL
                move.w  #1,VBL_FLAG
HBN
                rte

HBL_SCROL1
	MOVE.L	#$0440550,$FFFF8242.W
	MOVE.L	#$0660770,$FFFF8246.W
	CLR.B	$FFFFFA1B.W
	MOVE.B	#8,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	MOVE.L	#HBL_SCROL2,$120.W
	RTE
HBL_SCROL2
	MOVEM.L	D0-D7,-(SP)
	MOVEM.L	PAL,D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W
	MOVEM.L	(SP)+,D0-D7
	CLR.B	$FFFFFA1B.W
	RTE

AFF_ALLIANCE
	MOVE.L	#SPEC+32000,PALETTE	* FIXE ADRESSE PALETTE

	LEA	SPEC,A1
	LEA	$70000,A0
	MOVE.W	#7999,D1
AFF_SPEC
	MOVE.L	(A1)+,(A0)+
	DBRA	D1,AFF_SPEC

	MOVE.L	#SPEC_VBL,$70.W
	RTS

LIG_Y	DC.W	1

SPEC_VBL:				* ROUTINE DES 512 COULEURS
	CLR.B	$FFFFFA1B.W
	MOVE.L	D5,-(SP)
      	MOVE	SR,-(A7)		* SAUVE SR
      	ORI.W	#$700,SR		* DISABLE INTERRUPTS
      	LEA     	$FFFF8240.W,A4	* A4=COULEURS
      	LEA     	$FFFF8209.W,A5	* A5=ECRAN
      	LEA     	(A4),A0		* A0=A4
      	LEA     	(A4),A1		* A1=A4
      	LEA     	(A4),A2		* A2=A4
      	LEA     	SYNC(PC),A6	* SYNC = ROUTINE
      	MOVE.L  	PALETTE,A3	* A3 = PALETTE
      	LEA     	32(A3),A3		* A3=A3+32 (1 PALETTE)
      	MOVE.W  	LIG_Y,D7		* NOMBRE DE LIGNES
      	MOVEQ   	#0,D0		* D0=0
STABILISE:
	TST.B   	(A5)		* SYNCRO 1ERE LIGNE
      	BEQ.S   	STABILISE
      	
      	MOVE.B  	(A5),D0		* ADR ECRAN
      	ADDA.L  	D0,A6		* +ROUTINE
      	JMP     	(A6)		* GO FOR IT...
SYNC: 				* ON SAUTE DANS LES NOPS POUR
	REPT	120		* STABILISER LE BORDEL HE.HE.
	NOP
	ENDR

LIG_512_COLOR

	NOP			* 1
      	NOP			* 1

      	LEA	(A4),A0		* 1
	LEA     	(A4),A1 		* 1
      	LEA	(A4),A2 		* 1

	REPT	8
      	MOVE.L  (A3)+,(A0)+		* 8*5 = 40
	ENDR

	REPT	8
      	MOVE.L	(A3)+,(A1)+ 	* 40
	ENDR

	REPT	8
      	MOVE.L	(A3)+,(A2)+ 	* 40
	ENDR

      	DBF	D7,LIG_512_COLOR	* 3	TOTAL = 128 NOPS

      	NOP 

      	LEA     	(A4),A0 
      	LEA     	(A4),A1 
      	LEA     	(A4),A2 

	REPT	8
      	MOVE.L  	(A3)+,(A0)+ 
	ENDR

	REPT	8
      	MOVE.L  	(A3)+,(A1)+ 
	ENDR

	REPT	8
      	MOVE.L  	(A3)+,(A2)+ 
	ENDR

      	LEA     	(A4),A0 
      	LEA     	(A4),A1 
      	LEA     	(A4),A2 
      	LEA     	-19040(A3),A4 

      	NOP
      	NOP 
      	NOP 

	REPT	8
      	MOVE.L  	(A3)+,(A0)+ 
	ENDR

	REPT	8
      	MOVE.L  	(A3)+,(A1)+ 
	ENDR

	REPT	8
      	MOVE.L  	(A3)+,(A2)+ 
	ENDR


	LEA	$FFFF8240.W,A0
	MOVEQ	#0,D5
	REPT	8
	MOVE.L	D5,(A0)+
	ENDR

      	MOVE    	(A7)+,SR
	MOVE.L	(SP)+,D5
	MOVE.W	#1,VBL_FLAG
      	RTE


WAIT_VBL:
          tst.w   VBL_FLAG
          beq.s   WAIT_VBL
          move.w  #0,VBL_FLAG
NULL:
          rts

EQUA:
                move.l  #$E00E1FFE,D3
                move.l  #$FFFEFFFE,D4
                moveq   #0,D5
                moveq   #0,D6
                move.w  VOLV1,D0
                tst.w   D0
                beq.s   VOL_NUL
                subi.w  #1,VOLV1
VOL_NUL:
                move.w  #$20,D1
                sub.w   D0,D1
                lea     ECRAN,A0
                lea     ECRAN+128,A3
                move.w  #160*199,D2
AFFV1:
                move.l  D3,0(A0,D2.w)
                move.l  D4,4(A0,D2.w)
                move.l  D3,0(A3,D2.w)
                move.l  D4,4(A3,D2.w)
                sub.w   #160,D2
                dbra    D0,AFFV1
EFFV1:
                move.l  D5,0(A0,D2.w)
                move.l  D6,4(A0,D2.w)
                move.l  D5,0(A3,D2.w)
                move.l  D6,4(A3,D2.w)
                sub.w   #160,D2
                dbra    D1,EFFV1

                move.w  VOLV2,D0
                tst.w   D0
                beq.s   VOL2_NUL
                subi.w  #1,VOLV2
VOL2_NUL:
                move.w  #$20,D1
                sub.w   D0,D1
                move.w  #160*199,D2
AFFV2:
                move.l  D3,8(A0,D2.w)
                move.l  D4,12(A0,D2.w)
                move.l  D3,8(A3,D2.w)
                move.l  D4,12(A3,D2.w)
                sub.w   #160,D2
                dbra    D0,AFFV2
EFFV2:
                move.l  D5,8(A0,D2.w)
                move.l  D6,12(A0,D2.w)
                move.l  D5,8(A3,D2.w)
                move.l  D6,12(A3,D2.w)
                sub.w   #160,D2
                dbra    D1,EFFV2

                move.w  VOLV3,D0
                tst.w   D0
                beq.s   VOL3_NUL
                subi.w  #1,VOLV3
VOL3_NUL:
                move.w  #$20,D1
                sub.w   D0,D1
                move.w  #160*199,D2
AFFV3:
                move.l  D3,16(A0,D2.w)
                move.l  D4,20(A0,D2.w)
                move.l  D3,16(A3,D2.w)
                move.l  D4,20(A3,D2.w)
                sub.w   #160,D2
                dbra    D0,AFFV3
EFFV3:
                move.l  D5,16(A0,D2.w)
                move.l  D6,20(A0,D2.w)
                move.l  D5,16(A3,D2.w)
                move.l  D6,20(A3,D2.w)
                sub.w   #160,D2
                dbra    D1,EFFV3

                move.w  VOLV4,D0
                tst.w   D0
                beq.s   VOL4_NUL
                subi.w  #1,VOLV4
VOL4_NUL:
                move.w  #$20,D1
                sub.w   D0,D1
                move.w  #160*199,D2
AFFV4:
                move.l  D3,24(A0,D2.w)
                move.l  D4,28(A0,D2.w)
                move.l  D3,24(A3,D2.w)
                move.l  D4,28(A3,D2.w)
                sub.w   #160,D2
                dbra    D0,AFFV4
EFFV4:
                move.l  D5,24(A0,D2.w)
                move.l  D6,28(A0,D2.w)
                move.l  D5,24(A3,D2.w)
                move.l  D6,28(A3,D2.w)
                sub.w   #160,D2
                dbra    D1,EFFV4
                rts
RP1:
                lea     PIED+32*44,A0
                bsr     AFF_PIED
                move.l  #RP12,PEK_PIED+2
                rts
RP12:
                move.l  #RP2,PEK_PIED+2
                rts
RP2:
                lea     PIED+32*88,A0
                bsr     AFF_PIED
                move.l  #RP22,PEK_PIED+2
                rts
RP22:
                move.l  #RP3,PEK_PIED+2
                rts
RP3:
                lea     PIED+32*132,A0
                bsr     AFF_PIED
                move.l  #RP32,PEK_PIED+2
                rts
RP32:
                move.l  #RP4,PEK_PIED+2
                rts
RP4:
                lea     PIED+32*88,A0
                bsr     AFF_PIED
                move.l  #RP42,PEK_PIED+2
                rts
RP42:
                move.l  #RP5,PEK_PIED+2
                rts
RP5:
                lea     PIED+32*44,A0
                bsr     AFF_PIED
                move.l  #RP52,PEK_PIED+2
                rts
RP52:
                move.l  #RP6,PEK_PIED+2
                rts
RP6:
                lea     PIED,A0
                bsr     AFF_PIED
                move.l  #NULL,PEK_PIED+2
                rts

AFF_PIED:
                lea     ECRAN+40+160*156,A1
                move.w  #43,D0
LIG_PIED:
                movem.l (A0)+,D1-D4
                movem.l D1-D4,(A1)
                movem.l (A0)+,D1-D4
                movem.l D1-D4,16(A1)
                lea     160(A1),A1
                dbra    D0,LIG_PIED
                rts

RO1:
                lea     OEIL+128,A0
                bsr     AFF_OEIL
                move.l  #RO11,PEK_OEIL+2
                rts
RO11:
                move.l  #RO2,PEK_OEIL+2
                rts
RO2:
                lea     OEIL+128*2,A0
                bsr     AFF_OEIL
                move.l  #RO21,PEK_OEIL+2
                rts
RO21:
                move.l  #RO3,PEK_OEIL+2
                rts
RO3:
                lea     OEIL+128*3,A0
                bsr     AFF_OEIL
                move.l  #RO31,PEK_OEIL+2
                rts
RO31:
                move.l  #RO4,PEK_OEIL+2
                rts
RO4:
                lea     OEIL+128*2,A0
                bsr     AFF_OEIL
                move.l  #RO41,PEK_OEIL+2
                rts
RO41:
                move.l  #RO5,PEK_OEIL+2
                rts
RO5:
                lea     OEIL+128,A0
                bsr     AFF_OEIL
                move.l  #RO51,PEK_OEIL+2
                rts
RO51:
                move.l  #RO6,PEK_OEIL+2
                rts
RO6:
                lea     OEIL,A0
                bsr     AFF_OEIL
                move.l  #NULL,PEK_OEIL+2
                rts

AFF_OEIL:
                lea     ECRAN+72+84*160,A1
                move.w  #15,D0
LIG_OEIL:
                movem.l (A0)+,D1-D2
                movem.l D1-D2,(A1)
                lea     160(A1),A1
                dbra    D0,LIG_OEIL
                rts


****************************************************

FONTE_OUT:
                movem.l FONTE+2,D0-D7
                movem.l D0-D7,-(SP)
                lea     FONTE+2,A0
                bsr     FADE_OUT
                movem.l (SP)+,D0-D7
                movem.l D0-D7,FONTE+2
                rts

****************************************************

INVERT_DRVA:
                bsr     OFF_MOUSE
                lea     DESKTOP+160*12+48+34,A1
                lea     ECRAN+12*160,A0
                move.w  #42,D1
AFF_DRVA:
                movem.l (A1),D2-D5
                movem.l D2-D5,(A0)
                movem.l 16(A1),D2-D5
                movem.l D2-D5,16(A0)
                lea     160(A1),A1
                lea     160(A0),A0
                dbra    D1,AFF_DRVA
                bsr     ON_MOUSE
                rts

*****************************************

DRVA_NORMAL:
                bsr   OFF_MOUSE
                lea     DESKTOP+160*12+34,A1
                lea     ECRAN+12*160,A0
                move.w  #42,D1
AFF_DRVA_2:
                movem.l (A1),D2-D5
                movem.l D2-D5,(A0)
                movem.l 16(A1),D2-D5
                movem.l D2-D5,16(A0)
                lea     160(A1),A1
                lea     160(A0),A0
                dbra    D1,AFF_DRVA_2
                bsr   ON_MOUSE
                rts

******************************************
FIN:
                move    #$2700,SR
                lea     SAVE,A0
                move.l  (A0)+,$70.w
	      MOVE.L  (A0)+,$118.W
                move.l  (A0)+,$0120.w
                move.l  (A0)+,$0134.w
                move.b  (A0)+,$FFFFFA07.w
                move.b  (A0)+,$FFFFFA09.w
                move.b  (A0)+,$FFFFFA13.w
                move.b  (A0)+,$FFFFFA17.w
                move.b  (A0)+,$FFFFFA19.w
                move.b  (A0)+,$FFFFFA1F.w

	      MOVE.B  #$12,$FFFC02

	      ILLEGAL
******************************************

OFF_MOUSE:
                move.l  #NULL,PEK_MOUSE+2
WAIT_VB1:
                tst.w   VBL_FLAG
                beq.s   WAIT_VB1
                move.w  #0,VBL_FLAG
                bsr     EFF_MOUSE
                rts

*******************************************

ON_MOUSE:
                move.l  #ECRAN+160*200,BUF
                move.l  #AFF_MOUSE,PEK_MOUSE+2
                rts

********************************************

**************************************
*  fade in : palette finale  dans a0 *
**************************************

FADE_IN:
                lea     BUF_COL,A1
                movea.l A0,A2
                moveq   #15,D7
PREP_FADE:
                moveq   #0,D0
                moveq   #0,D1
                move.w  (A0)+,D0
                move.w  D0,D1
                and.w   #$0F00,D1
                move.w  D1,(A1)+
                move.w  D0,D1
                and.w   #$F0,D1
                move.w  D1,(A1)+
                and.w   #$0F,D0
                move.w  D0,(A1)+
                dbra    D7,PREP_FADE

DO_FA_IN:
                moveq   #3,D0
                bsr     WAIT_SECONDS

                movem.l PAL_NUL,D0-D7
                movem.l D0-D7,$FFFF8240.w
                moveq   #0,D6
                lea     PAL_NUL,A1
                lea     BUF_COL,A0
                moveq   #15,D7
FADE_01:
                movem.w (A0)+,D2-D4
                move.w  (A1),D0
                move.w  D0,D1
                and.w   #$0F00,D1
                cmp.w   D1,D2
                beq     PAS_ADD1
                moveq   #1,D6
                add.w   #$0100,D1
PAS_ADD1:
                move.w  D1,D5
                move.w  D0,D1
                and.w   #$F0,D1
                cmp.w   D1,D3
                beq     PAS_ADD2
                add.w   #$10,D1
                moveq   #1,D6
PAS_ADD2:
                add.w   D1,D5
                move.w  D0,D1
                and.w   #$0F,D1
                cmp.w   D1,D4
                beq.s   PAS_ADD3
                addq.w  #1,D1
                moveq   #1,D6
PAS_ADD3:
                add.w   D1,D5
                move.w  D5,(A1)+
                dbra    D7,FADE_01
                tst.w   D6
                bne     DO_FA_IN
                movem.l NILL,D0-D7
                movem.l D0-D7,PAL_NUL
                rts

*******************************************

***************************************
* FADE OUT : PALETTE INITIALE DANS A0 *
***************************************

FADE_OUT:
                movea.l A0,A6

ALL_COLORS:
                movea.l A6,A0
                movem.l (A0),D0-D7
                movem.l D0-D7,$FFFF8240.w

                moveq   #3,D0
                bsr     WAIT_SECONDS

                moveq   #0,D6
                movea.l A6,A0
                move.w  #15,D7
DO_FADE:
                moveq   #0,D0
                moveq   #0,D5
                move.w  (A0),D0
                move.l  D0,D1
                and.w   #$0F,D1
                tst.w   D1
                beq.s   PAS_SUB1
                subq.w  #1,D1
                moveq   #1,D6
PAS_SUB1:
                move.w  D1,D5
                move.l  D0,D1
                and.w   #$F0,D1
                tst.w   D1
                beq.s   PAS_SUB2
                sub.w   #$10,D1
                moveq   #1,D6
PAS_SUB2:
                add.w   D1,D5
                move.l  D0,D1
                and.w   #$0F00,D1
                tst.w   D1
                beq.s   PAS_SUB3
                moveq   #1,D6
                sub.w   #$0100,D1
PAS_SUB3:
                add.w   D1,D5
                move.w  D5,(A0)
NEXT_COLOR:
                lea     2(A0),A0
                dbra    D7,DO_FADE
                tst.w   D6
                bne.s   ALL_COLORS
                rts

**************************************

CLEAR_SCREEN:
                lea     ECRAN,A0
                moveq   #0,D0
                move.w  #7999,D1
EFF_SCREEN:
                move.l  D0,(A0)+
                dbra    D1,EFF_SCREEN
                rts

***************************************

EFF_MOUSE2:
                lea     BUF,A1
                movea.l (A1)+,A0
                move.w  #17,D7
REST_DESK2:
                movem.l (A1)+,D0-D5
                movem.l D0-D5,(A0)
                lea     160(A0),A0
                dbra    D7,REST_DESK2
                rts

***************************************************
* AFFICHAGE D'UN MESSAGE : ADRESSE DU TXT DANS A0 *
***************************************************

AFF_TEXTE:
                movea.l #ECRAN+80*160,A2
                movea.l A2,A5
LOOP_TXT:
                movea.l A2,A1
                moveq   #0,D0
                move.b  (A0)+,D0
                beq.s   END_MESS
                cmp.b   #1,D0
                beq.s   NEXT_LINE
                sub.b   #' ',D0
                add.w   D0,D0
                add.w   D0,D0
                lea     TAB_FNT,A3
                movea.l 0(A3,D0.w),A4
                move.w  #31,D7
AFF_LETTRE:
                movem.l (A4),D0-D3
                movem.l D0-D3,(A1)
                lea     160(A4),A4
                lea     160(A1),A1
                dbra    D7,AFF_LETTRE
                adda.l  #16,A2
                bra.s   LOOP_TXT
NEXT_LINE:
                adda.w  #160*32,A5
                movea.l A5,A2
                bra.s   LOOP_TXT
END_MESS:
                rts

*********************************************

AFF_ABEILLE:
                lea     BUF,A4
                move.l  A1,(A4)+
                moveq   #17,D7
SPR_ABEILLE:
                movem.l (A1),D0-D5
                movem.l D0-D5,(A4)
                lea     24(A4),A4
                move.w  (A0),D0
                or.w    2(A0),D0
                or.w    4(A0),D0
                or.w    6(A0),D0
                not.w   D0
                and.w   D0,(A1)
                and.w   D0,2(A1)
                and.w   D0,4(A1)
                and.w   D0,6(A1)
                movem.l (A0),D0-D1
                or.l    D0,(A1)
                or.l    D1,4(A1)
                move.w  8(A0),D0
                or.w    10(A0),D0
                or.w    12(A0),D0
                or.w    14(A0),D0
                not.w   D0
                and.w   D0,8(A1)
                and.w   D0,10(A1)
                and.w   D0,12(A1)
                and.w   D0,14(A1)
                movem.l 8(A0),D0-D1
                or.l    D0,8(A1)
                or.l    D1,12(A1)
                lea     160(A1),A1
                lea     64(A0),A0
                dbra    D7,SPR_ABEILLE
                rts

******************************************
******************************************

AFF_UNDER:
                moveq   #23,D7
AFF_UND02:
                moveq   #1,D6
AFF_UND01:
                move.w  (A0),D0
                or.w    2(A0),D0
                or.w    4(A0),D0
                or.w    6(A0),D0
                not.w   D0
                and.w   D0,(A1)
                and.w   D0,2(A1)
                and.w   D0,6(A1)
                movem.l (A0)+,D0-D1
                or.l    D0,(A1)
                or.l    D1,4(A1)
                lea     8(A1),A1
                dbra    D6,AFF_UND01
                lea     160-16(A1),A1
                dbra    D7,AFF_UND02
                rts

*****************************************
DECAL:
                lea     SPR_MOUSE,A2
                lea     SPR_MOUSE+768,A3
                move.w  #14,D7
ROT_0:
                movea.l A2,A0
                movea.l A3,A1
                move.w  #191,D1
COP_SPR:
                move.l  (A0)+,(A1)+
                dbra    D1,COP_SPR
                movea.l A3,A1
                move.w  #31,D6
ROT_1:
                move    #0,CCR
                roxr.w  (A1)
                roxr.w  8(A1)
                roxr.w  16(A1)
                roxr.w  2(A1)
                roxr.w  10(A1)
                roxr.w  18(A1)
                roxr.w  4(A1)
                roxr.w  12(A1)
                roxr.w  20(A1)
                roxr.w  6(A1)
                roxr.w  14(A1)
                roxr.w  22(A1)

                lea     24(A1),A1
                dbra    D6,ROT_1
                lea     768(A2),A2
                lea     768(A3),A3
                dbra    D7,ROT_0
                rts

********************************************

INIT_MOUSE:
                lea     MOUSEABS(PC),A0
                moveq   #4,D7
                bsr.s   WRITE_CLAV
                lea     INIT_CORDS(PC),A0
                moveq   #5,D7
                bsr.s   WRITE_CLAV
                move    #$2700,SR
                move.l  #MOUSE_IT,$0118.w
                move    #$2300,SR
                rts

*********************************************

WRITE_CLAV:
                lea     $FFFC00,A1
DO_CLAVIER:
                move.b  (A1),D2
                btst    #1,D2
                beq.s   DO_CLAVIER
                move.b  (A0)+,2(A1)
                dbra    D7,DO_CLAVIER
                rts

********************************************

MOUSEABS:
                DC.B $09
                DC.B $01,$3F
                DC.B $00,$C7
INIT_CORDS:
                DC.B $0E,$00,$00,$98,$00,$58
                EVEN

**********************************************

WAIT_SECONDS:
                tst.w   VBL_FLAG
                beq.s   WAIT_SECONDS
                move.w  #0,VBL_FLAG
                dbra    D0,WAIT_SECONDS
                rts

**********************************************

NEW_VBL:
                clr.b   $FFFF8260.w
                movem.l D0-A6,-(SP)
                move.b  #$0D,$FFFC02
PEK_MOUSE:
                jsr     NULL
                cmpi.b  #$39,KEY
                beq     FIN
                move.w  #1,VBL_FLAG
                addq.w  #1,CPT_VBL
                movem.l (SP)+,D0-A6
                rte

***********************************************

CPT_VBL:
                DC.W 0

***********************************************

VBL2:
                clr.b   $FFFF8260.w
                move    #$2700,SR
                clr.b   $FFFF8260.w
                move.w  #1,VBL_FLAG
                cmpi.b  #$39,$FFFC02
                beq     FIN
                move    #$2300,SR
                rte

************************************************

HBL:
                rte

************************************************

STOCK_THIS:
                lea     DESKTOP+34,A0
                lea     ECRAN+160*128+48,A1
                move.w  #54,D7
STOCK_COL:
                move.w  #15,D6
STOCK_LIG:
                move.l  (A1)+,(A0)+
                dbra    D6,STOCK_LIG
                lea     160-64(A1),A1
                dbra    D7,STOCK_COL
                rts

*************************************************

REST_THIS:
                lea     DESKTOP+34,A1
                lea     ECRAN+160*126+48,A0
                move.w  #54,D7
REST_COL:
                move.w  #15,D6
REST_LIG:
                move.l  (A1)+,(A0)+
                dbra    D6,REST_LIG
                lea     160-64(A0),A0
                dbra    D7,REST_COL
                rts


*********************************************

AFFICH_TAP:
                move.w  #54,D7
AFF_TAPETTE:
                move.w  #7,D6
LIG_TAP:
                move.w  (A0),D0
                or.w    2(A0),D0
                or.w    4(A0),D0
                or.w    6(A0),D0
                not.w   D0
                and.w   D0,(A1)
                and.w   D0,2(A1)
                and.w   D0,4(A1)
                and.w   D0,6(A1)
                movem.l (A0)+,D0-D1
                or.l    D0,(A1)
                or.l    D1,4(A1)
                lea     8(A1),A1
                dbra    D6,LIG_TAP

                lea     160-64(A1),A1
                dbra    D7,AFF_TAPETTE
                rts


**********************************************

MOUSE_IT:
                move    #$2700,SR
                cmpi.b  #$F7,$FFFC02
                beq.s   MOUSE_2
                move.b  $FFFC02,KEY
*                move.l  #MOUSE_IT,$0118.w
                move    #$2300,SR
                rte
MOUSE_2:
                move.l  #MOUSE_3,$0118.w
                move    #$2300,SR
                rte
MOUSE_3:
                move    #$2700,SR
                move.b  $FFFC02,BOUTON
                move.l  #MOUSE_4,$0118.w
                move    #$2300,SR
                rte
MOUSE_4:
                move    #$2700,SR
                move.b  $FFFC02,XMOUSE
                move.l  #MOUSE_5,$0118.w
                move    #$2300,SR
                rte
MOUSE_5:
                move    #$2700,SR
                move.b  $FFFC02,XMOUSE+1
                move.l  #MOUSE_6,$0118.w
                move    #$2300,SR
                rte
MOUSE_6:
                move    #$2700,SR
                move.b  $FFFC02,YMOUSE
                move.l  #MOUSE_7,$0118.w
                move    #$2300,SR
                rte
MOUSE_7:
                move    #$2700,SR
                move.b  $FFFC02,YMOUSE+1
                move.l  #MOUSE_IT,$0118
                move    #$2300,SR
NULL_IT:
                rte

**********************************************

EFF_MOUSE:
                lea     BUF,A1
                movea.l (A1)+,A0
                move.w  #31,D7
REST_DESK:
                movem.l (A1)+,D0-D5
                movem.l D0-D5,(A0)
                lea     160(A0),A0
                dbra    D7,REST_DESK
                rts

*********************************************

AFF_MOUSE:
                bsr.s   EFF_MOUSE
                moveq   #0,D0
                moveq   #0,D1
                moveq   #0,D5
                move.w  #$FFFF,D4
                move.w  XMOUSE,D0
                move.w  YMOUSE,D1
                mulu    #160,D1
                lea     ECRAN,A0
                lea     DESKTOP+34,A4
                lea     BUF,A6
                adda.w  D1,A0
                adda.w  D1,A4
                lea     160(A4),A4
                movea.l A0,A3
                lea     160(A3),A3
                cmp.w   #304,D0
                blt.s   INF_304
                moveq   #1,D5
INF_304:
                add.w   D0,D0
                add.w   D0,D0
                lea     TAB_PUT,A1
                adda.w  0(A1,D0.w),A0
                move.w  2(A1,D0.w),D0
                move.l  A0,(A6)+
                lea     SPR_MOUSE,A1
                adda.w  D0,A1
                move.w  #31,D7
AFF_PTR:
                moveq   #2,D6
AFF_PT1:
                move.l  (A0),(A6)+
                move.l  4(A0),(A6)+
                move.w  (A1),D0
                or.w    2(A1),D0
                or.w    4(A1),D0
                or.w    6(A1),D0
                not.w   D0
                and.w   D0,(A0)
                and.w   D0,2(A0)
                and.w   D0,4(A0)
                and.w   D0,6(A0)
                movem.l (A1)+,D0-D1
                or.l    D0,(A0)
                or.l    D1,4(A0)
                lea     8(A0),A0
                dbra    D6,AFF_PT1
                lea     160-24(A0),A0
                tst.w   D5
                beq.s   OK_MOUSE
                movem.l (A4),D0-D1
                movem.l D0-D1,(A3)
OK_MOUSE:
                lea     160(A3),A3
                lea     160(A4),A4
                dbra    D7,AFF_PTR
                rts

STCONNEXION:

ST_CONNEXION:   bra     INIT
                bra     _END
                bra     PLAY
                DC.L 0
                DC.W 0


INIT:           movem.l D0-A6,-(SP)
;adresse musique
                lea     ST_CONNEXION(PC),A0
                movea.l 12(A0),A0
                lea     OFFSET(PC),A1
                move.w  #$01D8,POS(A1)
                move.w  #$0258,PATT(A1)
                move.w  #$0F,NBR(A1)
;module du type 31 instruments ?
                cmpi.l  #'M.K.',$0438(A0)
                bne.s   NO_NEW_MODULES
                move.w  #$03B8,POS(A1)
                move.w  #$043C,PATT(A1)
                move.w  #$1F,NBR(A1)
NO_NEW_MODULES:
                lea     ST_CONNEXION(PC),A0
                movea.l 12(A0),A0
                lea     OFFSET(PC),A1
                adda.w  POS(A1),A0
                moveq   #$7F,D0
                moveq   #0,D1
;nombre de patterns
.LOOP1:         move.l  D1,D2
                subq.w  #1,D0
.LOOP2:         move.b  (A0)+,D1
                cmp.b   D2,D1
                bgt.s   .LOOP1
                dbra    D0,.LOOP2
                addq.b  #1,D2
                swap    D2
                lsr.l   #6,D2
                lea     ST_CONNEXION(PC),A0
                movea.l 12(A0),A0
                add.l   A0,D2
                lea     $14(A0),A0
                lea     OFFSET(PC),A1
                move.w  NBR(A1),D7
                add.w   PATT(A1),D2
                movea.l D2,A2
                lea     SAMPLESTARTS(PC),A1
                lea     (A1),A3
                moveq   #$1E,D6
.LOOP3:         clr.l   (A3)+
                dbra    D6,.LOOP3
                subq.w  #1,D7
.LOOP4:         clr.l   (A2)
;adresse de debut des samples
                move.l  A2,(A1)+
                moveq   #0,D1
                move.w  22(A0),D1
                lsl.l   #1,D1
                movea.l A2,A5
                adda.l  D1,A2
                move.l  A2,(A1)
                lea     (A2),A6
                move.w  22(A0),D6
                beq.s   .NO_REVERSE
                subq.w  #1,D6
;inverse les samples en memoire
.LOOP5:         move.b  (A5),D2
                move.b  -1(A6),D3
;met les samples au format non signes
                eori.b  #$80,D2
                eori.b  #$80,D3
                move.b  D3,(A5)+
                move.b  D2,-(A6)
                dbra    D6,.LOOP5
.NO_REVERSE:
                cmpi.w  #$01,28(A0)
                bne.s   .LOOP6
                clr.w   28(A0)
.LOOP6:         lea     $1E(A0),A0
                dbra    D7,.LOOP4
                lea     CHIP(PC),A0
                lea     NO_INS(PC),A1
                moveq   #$07,D0
.LOOP7:         move.l  A1,(A0)+
                clr.l   (A0)+
                clr.l   (A0)+
                dbra    D0,.LOOP7
                lea     VOICES(PC),A0
                moveq   #$1C-1,D0
.LOOP11:        clr.l   (A0)+
                dbra    D0,.LOOP11
;initialise quelques datas...
                lea     OFFSET(PC),A0
                move.b  #$06,SPEED(A0)
                clr.b   SONGPOS(A0)
                clr.b   COUNTER(A0)
                clr.w   PATTPOS(A0)
                lea     DIGIT_SWAP(PC),A0
                lea     (DIGIT+1000)(PC),A1
                move.l  A1,(A0)
                lea     DIGIT(PC),A1
                move.l  A1,4(A0)
                move.w  #1000-1,D0
.LOOP8:         move.w  #$0400,(A1)+
                dbra    D0,.LOOP8
                lea     YET(PC),A0
                cmpi.l  #'CNX',(A0)
                beq.s   .NO_CHANGE
                lea     SOUND(PC),A0
                move.w  #255,D0
.LOOP9:         move.b  5(A0),6(A0)
                move.b  5(A0),7(A0)
                move.b  4(A0),5(A0)
                lea     8(A0),A0
                dbra    D0,.LOOP9
                lea     VOLUME(PC),A0
                move.w  #$3FFF,D0
.LOOP10:        move.b  (A0),D1
;transformation de la table de volume
;en donnees 6 bits
                lsr.b   #2,D1
                move.b  D1,(A0)+
                dbra    D0,.LOOP10
                lea     YET(PC),A0
                move.l  #'CNX',(A0)
.NO_CHANGE:

;yamaha reset
                move.l  #$00,$FFFF8800.w
                move.l  #$01010000,$FFFF8800.w
                move.l  #$02020000,$FFFF8800.w
                move.l  #$03030000,$FFFF8800.w
                move.l  #$04040000,$FFFF8800.w
                move.l  #$05050000,$FFFF8800.w
                move.l  #$06060000,$FFFF8800.w
                move.l  #$0707FFFF,$FFFF8800.w
                move.l  #$08080000,$FFFF8800.w
                move.l  #$09090000,$FFFF8800.w
                move.l  #$0A0A0000,$FFFF8800.w
SOUND_CHIP:
                movem.l (SP)+,D0-A6
                rts

;zone de sauvegarde du contexte du st
STORE_INTERRUPTS:DCB.W 8


_END:           movem.l D0-A6,-(SP)
                movem.l (SP)+,D0-A6
                rts

PLAY:           move    #$2700,SR
                movem.l D0/A0,-(SP)
;permutation des deux buffers
;de digit  de travail
                lea     DIGIT_SWAP(PC),A0
                move.l  4(A0),D0
                move.l  (A0),4(A0)
                move.l  D0,(A0)
                lea     GRRR(PC),A0
                move.l  D0,2(A0)
                movem.l (SP)+,D0/A0
                move    #$2300,SR
;lit la partition et produit
;les effets sonores
                bsr     PLAYER
;calcule la digit a jouer
;a la prochaine vbl
                bsr     PRECALC_DIGIT
                rts

PLAYER:         movem.l D0-A6,-(SP)
                lea     OFFSET(PC),A4
                addq.b  #$01,COUNTER(A4)
                move.b  COUNTER(A4),D0
;effets sonore ou nouvelle
;lecture de la partition ?
                cmp.b   SPEED(A4),D0
                blt.s   NONEW
                clr.b   COUNTER(A4)
                bra.s   READ_PATTERN

;produit les effets sonores
;sur les 4 voies
;commandes:0,1,2,3,4,A
NONEW:
                bra     END_OF_PLAYER

;lit la partition pour les 4 voies
READ_PATTERN:
                lea     ST_CONNEXION(PC),A0
                movea.l 12(A0),A0
                lea     $0C(A0),A3
                lea     (A0),A2
                adda.w  POS(A4),A2
                adda.w  PATT(A4),A0

                moveq   #0,D0
                moveq   #0,D1
                move.b  SONGPOS(A4),D0
                move.b  0(A2,D0.w),D1
                swap    D1
                lsr.l   #$06,D1
                add.w   PATTPOS(A4),D1

                lea     CHIP1(PC),A5
                lea     VOICE1(PC),A6
                lea     INSTR1,A2
                bsr.s   PLAYVOICE
                lea     CHIP2(PC),A5
                lea     VOICE2(PC),A6
                lea     INSTR2,A2
                bsr.s   PLAYVOICE
                lea     INSTR3,A2
                lea     CHIP3(PC),A5
                lea     VOICE3(PC),A6
                bsr.s   PLAYVOICE
                lea     INSTR4,A2
                lea     CHIP4(PC),A5
                lea     VOICE4(PC),A6
                bsr.s   PLAYVOICE
                bra     SET_REPEAT

;routine qui traite une voie
PLAYVOICE:
                move.l  0(A0,D1.l),(A6)
                addq.l  #4,D1
                moveq   #0,D2
                move.b  $02(A6),D2
                and.b   #$F0,D2
                lsr.b   #4,D2
                move.l  D2,(A2)
                move.b  (A6),D0
                and.b   #$F0,D0
                or.b    D0,D2
                tst.b   D2
                beq.s   SET_REGS
                move.w  #$20,4(A2)
                moveq   #0,D3
                lea     SAMPLESTARTS(PC),A1
                move.l  D2,D4
                subq.l  #$01,D2
                add.w   D2,D2
                add.w   D2,D2
                mulu    #$1E,D4
                move.l  0(A1,D2.l),$04(A6)
                move.w  0(A3,D4.l),$08(A6)
                move.w  $02(A3,D4.l),$12(A6)
                move.w  $04(A3,D4.l),D3
                bra.s   NO_LOOP
                move.l  $04(A1,D2.l),$04(A6)
                add.w   $06(A3,D4.l),D3
                move.w  D3,$08(A6)
                add.w   D3,D3
                sub.l   D3,$04(A6)
                move.l  $04(A6),$0A(A6)
                moveq   #0,D3
                move.w  $06(A3,D4.l),D3
                move.w  D3,$0E(A6)
                move.w  $12(A6),$08(A5)
                bra.s   SET_REGS
NO_LOOP:
                move.l  $04(A6),$0A(A6)
                move.w  $06(A3,D4.l),$0E(A6)
                move.w  $12(A6),$08(A5)
SET_REGS:
                move.w  (A6),D0
                and.w   #$0FFF,D0
                beq     CHECK_COMMAND_2
                move.b  $02(A6),D0
                and.b   #$0F,D0
                cmp.b   #$03,D0
                bne.s   SETPERIOD
                bsr     SET_PORTAMENTO_TONE
                bra     CHECK_COMMAND_2
SETPERIOD:
                move.w  (A6),$10(A6)
                andi.w  #$0FFF,$10(A6)
                clr.b   $1B(A6)

                move.l  $04(A6),(A5)
                moveq   #0,D0
                move.w  $08(A6),D0
                add.w   D0,D0
                move.l  D0,$04(A5)
                move.w  $10(A6),$0A(A5)
                bra     CHECK_COMMAND_2

;active les repeat des 4 voies
SET_REPEAT:
                moveq   #0,D0
                lea     CHIP1(PC),A5
                lea     VOICE1(PC),A6
                move.l  $0A(A6),$0C(A5)
                move.w  $0E(A6),D0
                add.w   D0,D0
                move.l  D0,$10(A5)
                lea     CHIP2(PC),A5
                lea     VOICE2(PC),A6
                move.l  $0A(A6),$0C(A5)
                move.w  $0E(A6),D0
                add.w   D0,D0
                move.l  D0,$10(A5)
                lea     CHIP3(PC),A5
                lea     VOICE3(PC),A6
                move.l  $0A(A6),$0C(A5)
                move.w  $0E(A6),D0
                add.w   D0,D0
                move.l  D0,$10(A5)
                lea     CHIP4(PC),A5
                lea     VOICE4(PC),A6
                move.l  $0A(A6),$0C(A5)
                move.w  $0E(A6),D0
                add.w   D0,D0
                move.l  D0,$10(A5)

                addi.w  #$10,PATTPOS(A4)
;nouveau pattern?
                cmpi.w  #$0400,PATTPOS(A4)
                bne.s   END_OF_PLAYER
NEXT_PATT:
                clr.w   PATTPOS(A4)
                clr.b   BREAK(A4)
                addq.b  #1,SONGPOS(A4)
                andi.b  #$7F,SONGPOS(A4)
                move.b  SONGPOS(A4),D1
                lea     ST_CONNEXION(PC),A0
                movea.l 12(A0),A0
                adda.w  POS(A4),A0
                cmp.b   -2(A0),D1
                bne.s   END_OF_PLAYER
                clr.b   SONGPOS(A4)
END_OF_PLAYER:
                tst.b   BREAK(A4)
                bne.s   NEXT_PATT
                movem.l (SP)+,D0-A6
                rts

;effets sonores qui se produisent
;lorsqu'il ne faut pas lire la partition
CHECK_COMMAND:
                rts

;met en place le portamento tone
SET_PORTAMENTO_TONE:
                move.w  (A6),D2
                and.w   #$0FFF,D2
                move.w  D2,$18(A6)
                move.w  $10(A6),D0
                clr.b   $16(A6)
                cmp.w   D0,D2
                beq.s   CLR_PORTAMENTO_TONE
                bge.s   OK_RTS
                move.b  #$01,$16(A6)
                rts
CLR_PORTAMENTO_TONE:
                clr.w   $18(A6)
OK_RTS:
                rts
;commandes qui peuvent etre effectuees
;lors de la lecture de la partition
CHECK_COMMAND_2:
                move.b  $02(A6),D0
                and.b   #$0F,D0
                cmp.b   #$0B,D0
                beq.s   POSITION_JUMP
                cmp.b   #$0D,D0
                beq.s   PATTERN_BREAK
; pas de commande
                rts

;commande $B: postion jump
POSITION_JUMP:
                move.b  $03(A6),D0
                subq.b  #$01,D0
                move.b  D0,SONGPOS(A4)
                not.b   BREAK(A4)
                rts

;commande $C: set volume
SET_VOLUME:
                cmpi.b  #$40,$03(A6)
                ble.s   VOLUME_OK
                move.b  #$40,$03(A6)
VOLUME_OK:
                move.b  $03(A6),$09(A5)
                rts

;commande $D: pattern break
PATTERN_BREAK:
                not.b   BREAK(A4)
                rts

;commande $E: filter
;il n'est pas implemente ici
SET_FILTER:
                rts

;commande $F: set speed
SET_SPEED:
                move.b  $03(A6),D0
                and.w   #$1F,D0
                beq.s   NO_CHANGE_SPEED
                clr.b   COUNTER(A4)
                move.b  D0,SPEED(A4)
NO_CHANGE_SPEED:
                rts


;precalcule la digit qui sera jouee
;lors de la prochaine vbl
PRECALC_DIGIT:
                movem.l D0-A6,-(SP)
                lea     VOLUME(PC),A3
                lea     FRQ(PC),A4
                lea     MEGABUFFER(PC),A5
                lea     CHIP1(PC),A6
                bsr.s   CALC_VOICE
                lea     MEGABUFFER+500(PC),A5
                lea     CHIP2(PC),A6
                bsr.s   CALC_VOICE
                lea     MEGABUFFER+1000(PC),A5
                lea     CHIP3(PC),A6
                bsr.s   CALC_VOICE
                lea     MEGABUFFER+1500(PC),A5
                lea     CHIP4(PC),A6
                bsr.s   CALC_VOICE

                lea     MEGABUFFER(PC),A0
                lea     500(A0),A1
                lea     500(A1),A2
                lea     500(A2),A3
                lea     DIGIT_SWAP(PC),A4
                movea.l 4(A4),A4
                bsr     MIX_ALL_VOICES
                movem.l (SP)+,D0-A6
                rts

;calcul la digit pour une voie
CALC_VOICE:
;adresse ins
                movea.l $00(A6),A0
;valeur decimale du pointeur
                moveq   #0,D1
;longueur du sample
                move.l  $04(A6),D3
;volume
                move.w  $08(A6),D4
                beq.s   .VOLUME_NUL
                subq.w  #1,D4
                lsl.w   #$08,D4
.VOLUME_NUL:

;repeat lenght
                move.l  $10(A6),D6
;periode
                move.w  $0A(A6),D7
;*2
                add.w   D7,D7
;*2
                add.w   D7,D7
;periode.l
                move.l  0(A4,D7.w),D7
;.w bas de la periode
                move.w  D7,D0
                swap    D7
                moveq   #0,D2
;.w haut de la periode
                move.w  D7,D2
                swap    D7
;repeat?
                tst.l   D6
                nop
;pas repeat -> frq=0
                moveq   #0,D7
;adresse loop
.0:             movea.l $0C(A6),A2

                moveq   #FRQ_LOOP,D5
.PAULA:
;partie decimale de la frequence
                sub.w   D0,D1
;partie entiere de la frequence
;+retenue(s'il y a lieu)
                subx.w  D2,D3
;fin du sample ?
                bcs.s   .R1
.RR1:
;charge le sample
                move.b  0(A0,D3.l),D4
                move.b  0(A3,D4.w),(A5)+
                sub.w   D0,D1
                subx.w  D2,D3
                bcs.s   .R2
.RR2:           move.b  0(A0,D3.l),D4
                move.b  0(A3,D4.w),(A5)+
                sub.w   D0,D1
                subx.w  D2,D3
                bcs.s   .R3
.RR3:           move.b  0(A0,D3.l),D4
                move.b  0(A3,D4.w),(A5)+
;la meme routine est executee 3 fois
;cela permet d'eviter 2 dbra
                dbra    D5,.PAULA
                bra.s   END_OF_CALC_A_VOICE

.R1:            move.l  D6,D3
                move.w  D7,D0
                swap    D7
                move.w  D7,D2
                swap    D7
                movea.l A2,A0
                bra.s   .RR1
.R2:            move.l  D6,D3
                move.w  D7,D0
                swap    D7
                move.w  D7,D2
                swap    D7
                movea.l A2,A0
                bra.s   .RR2
.R3:            move.l  D6,D3
                move.w  D7,D0
                swap    D7
                move.w  D7,D2
                swap    D7
                movea.l A2,A0
                bra.s   .RR3
END_OF_CALC_A_VOICE:
;adresse du sample a sauver
                move.l  A0,$00(A6)
;position dans le sample a sauver
                move.l  D3,$04(A6)
                rts

;mixe les 4 voies
MIX_ALL_VOICES:
                moveq   #FRQ_LOOP,D1
.LOOP:          moveq   #0,D0
;v1
                move.b  (A0)+,D0
;v1+v2
                add.b   (A1)+,D0
;v1+v2+v3
                add.b   (A2)+,D0
;v1+v2+v3+v4
                add.b   (A3)+,D0
;multiplie par 8                        * a optimiser
                lsl.w   #3,D0
;sauve le resultat pour etre execute
;la vbl d'apres
                move.w  D0,(A4)+
                moveq   #0,D0
                move.b  (A0)+,D0
                add.b   (A1)+,D0
                add.b   (A2)+,D0
                add.b   (A3)+,D0
                lsl.w   #3,D0
                move.w  D0,(A4)+
                moveq   #0,D0
                move.b  (A0)+,D0
                add.b   (A1)+,D0
                add.b   (A2)+,D0
                add.b   (A3)+,D0
                lsl.w   #3,D0
                move.w  D0,(A4)+
;la meme routine est executee 3 fois
;cela permet d'eviter 2 dbra
                dbra    D1,.LOOP
                move.w  D0,(A4)+
                move.w  D0,(A4)+
                move.w  D0,(A4)+
                rts

;gestion yamaha 2149
SOUNDCHIP:
                movem.l D0/A0,-(SP)
GRRR:           lea     DIGIT,A0
;lit le mot de digit
                move.w  (A0),D0
                lea     (GRRR+4)(PC),A0
;incremente adresse du buffer
                addq.w  #2,(A0)
;pointe sur la valeur de la table
;st replay pour le soundchip
                lea     SOUND(PC,D0.w),A0
                move.l  (A0)+,D0
                move.l  (A0),$FFFF8800.w
                lea     $FFFF8800.w,A0
                movep.l D0,0(A0)
                movem.l (SP)+,D0/A0
                rte

                DATA
;table st replay
;copyright 2-bit systems      microdeal
SOUND:          DC.W $080E,$090D,$0A0C,0,$080F,$0903,$0A00,0
                DC.W $080F,$0903,$0A00,0,$080F,$0903,$0A00,0
                DC.W $080F,$0903,$0A00,0,$080F,$0903,$0A00,0
                DC.W $080F,$0903,$0A00,0,$080E,$090D,$0A0B,0
                DC.W $080E,$090D,$0A0B,0,$080E,$090D,$0A0B,0
                DC.W $080E,$090D,$0A0B,0,$080E,$090D,$0A0B,0
                DC.W $080E,$090D,$0A0B,0,$080E,$090D,$0A0B,0
                DC.W $080E,$090D,$0A0A,0,$080E,$090D,$0A0A,0
                DC.W $080E,$090D,$0A0A,0,$080E,$090D,$0A0A,0
                DC.W $080E,$090C,$0A0C,0,$080E,$090D,$0A00,0
                DC.W $080D,$090D,$0A0D,0,$080D,$090D,$0A0D,0
                DC.W $080D,$090D,$0A0D,0,$080D,$090D,$0A0D,0
                DC.W $080D,$090D,$0A0D,0,$080D,$090D,$0A0D,0
                DC.W $080E,$090C,$0A0B,0,$080E,$090C,$0A0B,0
                DC.W $080E,$090C,$0A0B,0,$080E,$090C,$0A0B,0
                DC.W $080E,$090C,$0A0B,0,$080E,$090C,$0A0B,0
                DC.W $080E,$090C,$0A0B,0,$080E,$090C,$0A0B,0
                DC.W $080E,$090C,$0A0A,0,$080E,$090C,$0A0A,0
                DC.W $080E,$090C,$0A0A,0,$080E,$090C,$0A0A,0
                DC.W $080D,$090D,$0A0C,0,$080D,$090D,$0A0C,0
                DC.W $080E,$090C,$0A09,0,$080E,$090C,$0A09,0
                DC.W $080E,$090C,$0A05,0,$080E,$090C,$0A00,0
                DC.W $080E,$090C,$0A00,0,$080E,$090B,$0A0B,0
                DC.W $080E,$090B,$0A0B,0,$080E,$090B,$0A0B,0
                DC.W $080E,$090B,$0A0B,0,$080E,$090B,$0A0A,0
                DC.W $080E,$090B,$0A0A,0,$080E,$090B,$0A0A,0
                DC.W $080D,$090D,$0A0B,0,$080D,$090D,$0A0B,0
                DC.W $080D,$090D,$0A0B,0,$080E,$090B,$0A09,0
                DC.W $080E,$090B,$0A09,0,$080E,$090B,$0A09,0
                DC.W $080D,$090C,$0A0C,0,$080D,$090D,$0A0A,0
                DC.W $080E,$090B,$0A07,0,$080E,$090B,$0A00,0
                DC.W $080E,$090B,$0A00,0,$080D,$090D,$0A09,0
                DC.W $080D,$090D,$0A09,0,$080E,$090A,$0A09,0
                DC.W $080D,$090D,$0A08,0,$080D,$090D,$0A07,0
                DC.W $080D,$090D,$0A04,0,$080D,$090D,$0A00,0
                DC.W $080E,$090A,$0A04,0,$080E,$0909,$0A09,0
                DC.W $080E,$0909,$0A09,0,$080D,$090C,$0A0B,0
                DC.W $080E,$0909,$0A08,0,$080E,$0909,$0A08,0
                DC.W $080E,$0909,$0A07,0,$080E,$0908,$0A08,0
                DC.W $080E,$0909,$0A01,0,$080C,$090C,$0A0C,0
                DC.W $080D,$090C,$0A0A,0,$080E,$0908,$0A06,0
                DC.W $080E,$0907,$0A07,0,$080E,$0908,$0A00,0
                DC.W $080E,$0907,$0A05,0,$080E,$0906,$0A06,0
                DC.W $080D,$090C,$0A09,0,$080E,$0905,$0A05,0
                DC.W $080E,$0904,$0A04,0,$080D,$090C,$0A08,0
                DC.W $080D,$090B,$0A0B,0,$080E,$0900,$0A00,0
                DC.W $080D,$090C,$0A06,0,$080D,$090C,$0A05,0
                DC.W $080D,$090C,$0A02,0,$080C,$090C,$0A0B,0
                DC.W $080C,$090C,$0A0B,0,$080D,$090B,$0A0A,0
                DC.W $080D,$090B,$0A0A,0,$080D,$090B,$0A0A,0
                DC.W $080D,$090B,$0A0A,0,$080C,$090C,$0A0A,0
                DC.W $080C,$090C,$0A0A,0,$080C,$090C,$0A0A,0
                DC.W $080D,$090B,$0A09,0,$080D,$090B,$0A09,0
                DC.W $080D,$090A,$0A0A,0,$080D,$090A,$0A0A,0
                DC.W $080D,$090A,$0A0A,0,$080C,$090C,$0A09,0
                DC.W $080C,$090C,$0A09,0,$080C,$090C,$0A09,0
                DC.W $080D,$090B,$0A06,0,$080C,$090B,$0A0B,0
                DC.W $080C,$090C,$0A08,0,$080D,$090B,$0A00,0
                DC.W $080D,$090B,$0A00,0,$080C,$090C,$0A07,0
                DC.W $080C,$090C,$0A06,0,$080C,$090C,$0A05,0
                DC.W $080C,$090C,$0A03,0,$080C,$090C,$0A01,0
                DC.W $080C,$090B,$0A0A,0,$080D,$090A,$0A05,0
                DC.W $080D,$090A,$0A04,0,$080D,$090A,$0A02,0
                DC.W $080D,$0909,$0A08,0,$080D,$0909,$0A08,0
                DC.W $080C,$090B,$0A09,0,$080C,$090B,$0A09,0
                DC.W $080D,$0908,$0A08,0,$080B,$090B,$0A0B,0
                DC.W $080D,$0909,$0A05,0,$080C,$090B,$0A08,0
                DC.W $080D,$0909,$0A02,0,$080D,$0908,$0A06,0
                DC.W $080C,$090B,$0A07,0,$080D,$0907,$0A07,0
                DC.W $080C,$090B,$0A06,0,$080C,$090A,$0A09,0
                DC.W $080B,$090B,$0A0A,0,$080C,$090B,$0A02,0
                DC.W $080C,$090B,$0A00,0,$080C,$090A,$0A08,0
                DC.W $080D,$0906,$0A04,0,$080D,$0905,$0A05,0
                DC.W $080D,$0905,$0A04,0,$080C,$0909,$0A09,0
                DC.W $080D,$0904,$0A03,0,$080B,$090B,$0A09,0
                DC.W $080C,$090A,$0A05,0,$080B,$090A,$0A0A,0
                DC.W $080C,$0909,$0A08,0,$080B,$090B,$0A08,0
                DC.W $080C,$090A,$0A00,0,$080C,$090A,$0A00,0
                DC.W $080C,$0909,$0A07,0,$080B,$090B,$0A07,0
                DC.W $080C,$0909,$0A06,0,$080B,$090B,$0A06,0
                DC.W $080B,$090A,$0A09,0,$080B,$090B,$0A05,0
                DC.W $080A,$090A,$0A0A,0,$080B,$090B,$0A02,0
                DC.W $080B,$090A,$0A08,0,$080C,$0907,$0A07,0
                DC.W $080C,$0908,$0A04,0,$080C,$0907,$0A06,0
                DC.W $080B,$0909,$0A09,0,$080C,$0906,$0A06,0
                DC.W $080A,$090A,$0A09,0,$080C,$0907,$0A03,0
                DC.W $080B,$090A,$0A05,0,$080B,$0909,$0A08,0
                DC.W $080B,$090A,$0A03,0,$080A,$090A,$0A08,0
                DC.W $080B,$090A,$0A00,0,$080B,$0909,$0A07,0
                DC.W $080B,$0908,$0A08,0,$080A,$090A,$0A07,0
                DC.W $080A,$0909,$0A09,0,$080C,$0901,$0A01,0
                DC.W $080A,$090A,$0A06,0,$080B,$0908,$0A07,0
                DC.W $080A,$090A,$0A05,0,$080A,$0909,$0A08,0
                DC.W $080A,$090A,$0A02,0,$080A,$090A,$0A01,0
                DC.W $080A,$090A,$0A00,0,$0809,$0909,$0A09,0
                DC.W $080A,$0908,$0A08,0,$080B,$0908,$0A01,0
                DC.W $080A,$0909,$0A06,0,$080B,$0907,$0A04,0
                DC.W $080A,$0909,$0A05,0,$0809,$0909,$0A08,0
                DC.W $080A,$0909,$0A03,0,$080A,$0908,$0A06,0
                DC.W $080A,$0909,$0A00,0,$0809,$0909,$0A07,0
                DC.W $0809,$0908,$0A08,0,$080A,$0908,$0A04,0
                DC.W $0809,$0909,$0A06,0,$080A,$0908,$0A01,0
                DC.W $0809,$0909,$0A05,0,$0809,$0908,$0A07,0
                DC.W $0808,$0908,$0A08,0,$0809,$0909,$0A02,0
                DC.W $0809,$0908,$0A06,0,$0809,$0909,$0A00,0
                DC.W $0809,$0907,$0A07,0,$0808,$0908,$0A07,0
                DC.W $0809,$0907,$0A06,0,$0809,$0908,$0A02,0
                DC.W $0808,$0908,$0A06,0,$0809,$0906,$0A06,0
                DC.W $0808,$0907,$0A07,0,$0808,$0908,$0A04,0
                DC.W $0808,$0907,$0A06,0,$0808,$0908,$0A02,0
                DC.W $0807,$0907,$0A07,0,$0808,$0906,$0A06,0
                DC.W $0808,$0907,$0A04,0,$0807,$0907,$0A06,0
                DC.W $0808,$0906,$0A05,0,$0808,$0906,$0A04,0
                DC.W $0807,$0906,$0A06,0,$0807,$0907,$0A04,0
                DC.W $0808,$0905,$0A04,0,$0806,$0906,$0A06,0
                DC.W $0807,$0906,$0A04,0,$0807,$0905,$0A05,0
                DC.W $0806,$0906,$0A05,0,$0806,$0906,$0A04,0
                DC.W $0806,$0905,$0A05,0,$0806,$0906,$0A02,0
                DC.W $0806,$0905,$0A04,0,$0805,$0905,$0A05,0
                DC.W $0806,$0905,$0A02,0,$0805,$0905,$0A04,0
                DC.W $0805,$0904,$0A04,0,$0805,$0905,$0A02,0
                DC.W $0804,$0904,$0A04,0,$0804,$0904,$0A03,0
                DC.W $0804,$0904,$0A02,0,$0804,$0903,$0A03,0
                DC.W $0803,$0903,$0A03,0,$0803,$0903,$0A02,0
                DC.W $0803,$0902,$0A02,0,$0802,$0902,$0A02,0
                DC.W $0802,$0902,$0A01,0,$0801,$0901,$0A01,0
                DC.W $0802,$0901,$0A00,0,$0801,$0901,$0A00,0
                DC.W $0801,$0900,$0A00,0,$0800,$0900,$0A00,0
;table pour le vibrato
SINUS:
                DC.B $00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
                DC.B $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1,$8D,$78,$61,$4A,$31,$18
;table pour l'arpeggio
PERIODS:
                DC.W $0358,$0328,$02FA,$02D0,$02A6,$0280,$025C,$023A,$021A,$01FC,$01E0
                DC.W $01C5,$01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$FE
                DC.W $F0,$E2,$D6,$CA,$BE,$B4,$AA,$A0,$97,$8F,$87
                DC.W $7F,$78,$71,$00,$00
OFFSET:         DCB.W $06
SPEED           EQU $00
SONGPOS         EQU $01
PATTPOS         EQU $02
COUNTER         EQU $04
BREAK           EQU $05
POS             EQU $06
PATT            EQU $08
NBR             EQU $0A
SAMPLESTARTS:   DCB.L $20
VOICES:         DCB.L $1C
VOICE1          EQU VOICES
VOICE2          EQU VOICES+$1C
VOICE3          EQU VOICES+$38
VOICE4          EQU VOICES+$54
CHIP:           DCB.L $18
CHIP1           EQU CHIP
CHIP2           EQU CHIP+$18
CHIP3           EQU CHIP+$30
CHIP4           EQU CHIP+$48
NO_INS:         DC.W $8080
MEGABUFFER:     DCB.L 500
DIGIT:          DCB.W 500*2
DIGIT_SWAP:     DCB.L 2
FRQ_LOOP        EQU 66
FRQ_DATA        EQU 61
;Voici les valeurs pour changer de frequence
;Frequences 14Khz  12.3Khz  10.1Khz  8.5Khz  7.5Khz
;Frq_data   44     50       61       72      82
;Frq_loop   92     81       66       56      49
FRQ:            DC.L 0
                INCBIN '10_KHZ.FRQ' ;table cr‚‚e par 14_khz.gfa
;pour les autres fr‚quences
;changer les valeurs a%(Timer
;A Control Register) et b%
;(Timer A Data Register).
YET:            DC.L 0
VOLUME:         INCBIN 'VOLUME.BIN'
MUSIC:
                INCBIN 'LEM*.MOD'
VBL_FLAG:
                DC.W 0
PAL:
                DC.W $00,$0777,$0744,$0755,$0766,$03,$04,$05
                DC.W $06,$07,$0347,$0457,$0567,$30,$40,$50
PIED:
                INCBIN 'PIED.IMG'
OEIL:
                INCBIN 'OEIL.IMG'
LEMMING:
                INCBIN 'LEMMING.IMG'
DEL4:
                INCBIN 'DEL4.PI1'
SAVE:
                DS.L 8
INSTR1:
                DS.L 1
VOLV1:
                DS.W 1
INSTR2:
                DS.L 1
VOLV2:
                DS.W 1
INSTR3:
                DS.L 1
VOLV3:
                DS.W 1
INSTR4:
                DS.L 1
VOLV4:
                DS.W 1

***********************************************
*          DATAS (YES IT'S HERE) !!!!         *
***********************************************
PAL_ALL:
                DC.W $00,$0222,$0333,$0444,$0555,$0666,$0777
                DC.W $0740,$0750,$0760,$0400,$0610,$0620
PAL_LOG_MCS:
                DC.W 0,$0700,$00,$0740,$0320,$0333,$0444,$0555
                DC.W $0666,$0777,$0222,$05,$07,$04,$00,$00
FIRST_TXT:
                DC.B '  FIRST  ',0
THERE_WAS:
                DC.B '  THERE',1
                DC.B '   WAS',0
NOW:
                DC.B ' NOW THE ',0
PRESENT:
                DC.B ' PRESENT',0
_A:
                DC.B '    A',0
PRODUCT:
                DC.B ' PRODUCT',0
THE:
                DC.B '   THE',0
                EVEN
PAL_NUL:
                DS.W 16
BUF_COL:
                DS.W 48
BUF:
                DC.L ECRAN+200*160
                DS.B 768
NILL:
                REPT 16
                DC.W 0
                ENDR
MCS_LOGO:
                INCBIN 'LOGOMCS.IMG'
TAPETTE:
                INCBIN 'COPYB8.IMG'
TAPETTE2:
                INCBIN 'COPYB8.IMG'
TAPETTE3:
                INCBIN 'COPYB8.IMG'
TAPETTE4:
                INCBIN 'COPYB8.IMG'
SPR3:
                INCBIN 'COPYB8.IMG'
TAB_MOUSE:
                INCBIN 'MOUSE.TAB'
FTAB_MOUSE:
SPR2:
                INCBIN 'COPYB2.IMG'
OVR:
                INCBIN 'OVR.PI1'
DESKTOP:
                INCBIN 'DESKTOP.PI1'
FONTE:
                INCBIN 'FNT.PI1'

KEY:            DC.B 0
BOUTON:
                DC.B 0
XMOUSE:         DC.W 0
YMOUSE:         DC.W 0
                EVEN
TAB_SPRM:
                DC.L SPR2+64*19,SPR2+64*19
                DC.L SPR2+64*38,SPR2+64*38
                DC.L SPR2+64*57,SPR2+64*57
                DC.L SPR2+64*38,SPR2+64*38
FTAB_SPRM:
BUF2:
                DS.L 1
BUF_ECRAN:
                DC.L 0
BOMBES:
                DC.W $0600,$2900,$80,$4840
                DC.W $11F0,$01F0,$07FC,$0FFE
                DC.W $0FFE,$1FFF,$1FEF,$0FEE
                DC.W $0FDE,$07FC,$03F8,$E0
TAB_PUT:
M	SET	0
	REPT	20
	DC.W	M,0
	DC.W	M,768
	DC.W	M,768*2
	DC.W	M,768*3
	DC.W	M,768*4
	DC.W	M,768*5
	DC.W	M,768*6
	DC.W	M,768*7
	DC.W	M,768*8
	DC.W	M,768*9
	DC.W	M,768*10
	DC.W	M,768*11
	DC.W	M,768*12
	DC.W	M,768*13
	DC.W	M,768*14
	DC.W	M,768*15
M	SET	M+8
	ENDR
FNT             EQU FONTE+34

K               EQU 160*32

TAB_FNT:
* 1ERE LIGNE

                DC.L FNT
                DC.L FNT+16
                DC.L FNT+32
                DC.L FNT+48
                DC.L FNT+64
                DC.L FNT+80
                DC.L FNT+96
                DC.L FNT+112
                DC.L FNT+128
                DC.L FNT+144

* 2EME LIGNE

                DC.L FNT+K
                DC.L FNT+16+K
                DC.L FNT+32+K
                DC.L FNT+48+K
                DC.L FNT+64+K
                DC.L FNT+80+K
                DC.L FNT+96+K
                DC.L FNT+112+K
                DC.L FNT+128+K
                DC.L FNT+144+K


                DC.L FNT+K*2
                DC.L FNT+16+K*2
                DC.L FNT+32+K*2
                DC.L FNT+48+K*2
                DC.L FNT+64+K*2
                DC.L FNT+80+K*2
                DC.L FNT+96+K*2
                DC.L FNT+112+K*2
                DC.L FNT+128+K*2
                DC.L FNT+144+K*2

                DC.L FNT+K*3
                DC.L FNT+16+K*3
                DC.L FNT+32+K*3
                DC.L FNT+48+K*3
                DC.L FNT+64+K*3
                DC.L FNT+80+K*3
                DC.L FNT+96+K*3
                DC.L FNT+112+K*3
                DC.L FNT+128+K*3
                DC.L FNT+144+K*3

                DC.L FNT+K*4
                DC.L FNT+16+K*4
                DC.L FNT+32+K*4
                DC.L FNT+48+K*4
                DC.L FNT+64+K*4
                DC.L FNT+80+K*4
                DC.L FNT+96+K*4
                DC.L FNT+112+K*4
                DC.L FNT+128+K*4
                DC.L FNT+144+K*4

                DC.L FNT+K*5
                DC.L FNT+16+K*5
                DC.L FNT+32+K*5
                DC.L FNT+48+K*5
                DC.L FNT+64+K*5
                DC.L FNT+80+K*5
                DC.L FNT+96+K*5
                DC.L FNT+112+K*5
                DC.L FNT+128+K*5
                DC.L FNT+144+K*5
CL
	DC.W	0
MESS
	DC.B	"               OH NO !!!!             ",0
	DC.B	"            YOU DON'T DREAM.          ",0
	DC.B	"     THE M.C.S. STRIKES BACK WITH :   ",0
	DC.B	"     THE DELIRIOUS DEMO CHAPTER 4.    ",0
	DC.B	" THIS TIME OUR CREW IS BIGGER THAN FOR",0
	DC.B	"           THE CHAPTER 3.             ",0
	DC.B	"    CREDITS FOR THIS MEGA DELIRIUM..  ",0
	DC.B	"                 BOOT :               ",0
	DC.B	"     CODE AND GFX BY THE DREAMER      ",0
	DC.B	"      ( GREAT WORK MY FRIEND )        ",0
	DC.B	"                 INTRO :              ",0
	DC.B	"           CODE BY MAGNUM             ",0
	DC.B	"         ALL GFX BY ZORGLUB           ",0
	DC.B	"    LEMMING'S RAP BY SOUND AESTESIS.  ",0
	DC.B	"     (YES WE NOW HAVE A MUSICIAN)     ",0
	DC.B	"                LOADER :              ",0
	DC.B	"     CODE BY AXEL FOLLET AND MAGNUM   ",0
	DC.B	"              GFX BY ALF              ",0
	DC.B	"                 MENU :               ",0
	DC.B	"          CODE BY THE DREAMER !       ",0
	DC.B	"             GFX BY ZORGLUB.          ",0
	DC.B	"        MAP BY ALL MEMBERS OF MCS.    ",0
	DC.B	"               RESET DEMO :           ",0
	DC.B	"     CODE BY XERCES (GNS) AND MAGNUM  ",0
	DC.B	"        GFX BY MAGNUM AND ZORGLUB.    ",0
	DC.B	"              MUSIC BY LAP            ",0
	DC.B	"            90 DEGRES SCREEN :        ",0
	DC.B	"         CODE AND IDEA BY MAGNUM      ",0
	DC.B	"      GFX BY ZORGLUB, MARIO, MAGNUM.  ",0
	DC.B	"            MUSIC BY MAD MAX          ",0
	DC.B	"               HLM SCREEN :           ",0
	DC.B	"  CODE BY THE DREAMER, GFX FROM AMIGA ",0
	DC.B	"            MUSIC BY MAD MAX          ",0
	DC.B	"               WIGGLE IT :            ",0
	DC.B	"          CODE BY THE HOOLIGAN        ",0
	DC.B	"             GFX BY ZORGLUB           ",0
	DC.B	"        LEVELS BY A LOT OF PEOPLE     ",0
	DC.B	"                COLUMNS :             ",0
	DC.B	"             CODE BY MAGNUM           ",0
	DC.B	"      GFX BY MAGNUM AND JUDGE DEATH   ",0
	DC.B	"              BIG SPRITE :            ",0
	DC.B	"             CODE BY MAGNUM           ",0
	DC.B	"             GFX BY ZORGLUB           ",0
	DC.B	"             LEMMINGS FUCK :          ",0
	DC.B	"             CODE BY MAGNUM           ",0
	DC.B	"              IDEA BY DUB'S           ",0
	DC.B	"                PUSH IT :             ",0
	DC.B	"             CODE BY MAGNUM           ",0
	DC.B	"             GFX BY ZORGLUB           ",0
	DC.B	"         LEVELS BY THE WHOLE TEAM     ",0
	DC.B	"          PHILOSOPHYCAL DEMO :        ",0
	DC.B	"         CODE BY THE HOOLIGAN         ",0
	DC.B	"        BULLSHITS BY EVERYBODY        ",0
	DC.B	"    GFX BY ZORGLUB AND THE NEWLIGAN   ",0
	DC.B	"                 THRUD :              ",0
	DC.B	"           CODE BY AXEL FOLLET        ",0
	DC.B	"          SCANNED GFX BY ZORGLUB      ",0
	DC.B	"        SAMPLES BY DUB'S AND BUDDY    ",0
	DC.B	"              PAUSE DEMO :            ",0
	DC.B	"      CODE BY MAGNUM AND AXEL FOLLET  ",0
	DC.B	"              GFX BY MARIO            ",0
	DC.B	"                VODKA :               ",0
	DC.B	"             CODE BY MAGNUM           ",0
	DC.B	"             GFX BY ZORGLUB           ",0
	DC.B	"            MUSIC BY MAD MAX          ",0
	DC.B	"               FX 7000 G :            ",0
	DC.B	"           CODE BY THE DREAMER        ",0
	DC.B	"            AND THE CHOOLIGAN         ",0
	DC.B	"             GFX BY ZORGLUB           ",0
	DC.B	"            AND THE BOOLIGAN          ",0
	DC.B	"              COPY PROGRAM :          ",0
	DC.B	"             CODE BY ALTAIR           ",0
	DC.B	" PROTECTION, PACKER AND PUTTING FILES ",0
	DC.B	"            TOGETHER BY ALTAIR        ",0
	DC.B	"      MONOCHROME CODING BY GADGET.    ",0
	DC.B	"   NOW THE GUEST SCREENS ...          ",0
	DC.B	"      PUTAIN J'ME TAPERAIS BIEN UN... ",0
	DC.B	"          CODE BY THE BLACK CATS      ",0
	DC.B	"          GFX BY THE BLACK CATS       ",0
	DC.B	"            MUSIC BY MAD MAX          ",0
	DC.B	"                CROMAX :              ",0
	DC.B	"           CODE BY IKI OF TSB         ",0
	DC.B	"           GFX BY JUDGE DREDD         ",0
	DC.B	"            MUSIC BY MAD MAX          ",0
	DC.B	"             NO SCROLL DEMO :         ",0
	DC.B	"         CODE BY RED DEVIL (PDK)      ",0
	DC.B	"               GFX BY PDK             ",0
	DC.B	"           MUSIC BY COUNT ZERO        ",0
	
             ;DC.B	"                 TRON :               ",0
	;DC.B	"             CODE BY GENUWAX          ",0
	;DC.B	"              GFX BY GENUWAX          ",0
	
	DC.B	"             GENUMAX SCREEN :         ",0
	DC.B	"             CODE BY GENUWAX          ",0
	DC.B	"              GFX BY GENUWAX          ",0
	DC.B	"            MUSIC BY MAD MAX          ",0
	DC.B	"               NGC SCREEN :           ",0
	DC.B	"           CODE AND GFX BY NGC        ",0
	DC.B	" AND NOW THE PRESENTATION OF THE WHOLE",0
	DC.B	"                CREW......            ",0
	DC.B	" ALTAIR                          CODER",0
	DC.B	" AXEL FOLLET             CODER-SLEEPER",0
	DC.B	" BUDDY                        PC CODER",0
	DC.B	" DUB'S                        PC CODER",0
	DC.B	" GADGET         CODER-PUBLIC RELATIONS",0
	DC.B	" GALAHAD                HARDWARE-CODER",0
	DC.B	" GROUMPHY                     GRAPHIST",0
	DC.B	" JUDGE DEATH                   PAINTER",0
	DC.B	" MAGNUM                  CODER-DRINKER",0
	DC.B	" MARIO                   CODER-PAINTER",0
	DC.B	" P.F.                    CODER-DRINKER",0
	DC.B	" SOUND AESTESIS               MUSICIAN",0
	DC.B	" THE DREAMER                FULL CODER",0
	DC.B	" THE HOOLIGAN         CODER-CRITICIZER",0
	DC.B	" ZORGLUB                  LAZY PAINTER",0
	DC.B	" THANX TO PSYGNOSYS FOR THIS NICE GAME",0
	DC.B	"             CALLED LEMMINGS...       ",0
	DC.B	"            HELLO GOES TO :           ",0
	DC.B	"  MIT (I KNOW THAT YOU LOVE LEMMINGS) ",0
	DC.B	"  GENESIS (XERCES, MICHAEL MAYERS..)  ",0
	DC.B	"  THE BLACK CATS (DOCPROF, CONAN,...) ",0
	DC.B	"    EQUINOX (STARLION, RENKER, EDY)   ",0
	DC.B	" THE STORM BROTHERS (IKI,JUDGE DREDD) ",0
	DC.B	"     THE CYBERNETICS (FUNNY GUYS)     ",0
	DC.B	"                FASHION               ",0
	DC.B	"     THE MISFITS (JOKER, DOCTOR J)    ",0
	DC.B	"            NGC (ALL MEMBERS)         ",0
	DC.B	"            ABCS 85 (CENTAUR)         ",0
	DC.B	"       AND LAST : JOHN COURAGE        ",0
	DC.B	"       AND LAST : GEORGE KILLIANS     ",0
	DC.B	"       AND LAST : PELFORTH            ",0
	DC.B	1,1,1,1
FTEXT
	EVEN
FNT3
	INCBIN	FNT.IMG
FIN_FNT3

SPACE	EQU	FNT3+153
TAB_FNT3
	DC.L	FNT3+153
	DC.L	FNT3+160*8+9
	DC.L	FNT3+160*8+24
	DC.L	SPACE
	DC.L	SPACE
	DC.L	SPACE
	DC.L	SPACE
	DC.L	FNT3+160*8+17
	DC.L	FNT3+18*8
	DC.L	FNT3+18*8+1
	DC.L	SPACE
	DC.L	SPACE
	DC.L	FNT3+160*8+16
	DC.L	SPACE
	DC.L	FNT3+160*8
	DC.L	SPACE
M	SET	0
	REPT	5
	DC.L	FNT3+8*13+M	* 0 A 9
	DC.L	FNT3+8*13+M+1
M	SET	M+8
	ENDR
	DC.L	FNT3+8*19		* :
	DC.L	FNT3+160*8+8
	DC.L	SPACE
	DC.L	SPACE
	DC.L	SPACE
	DC.L	FNT3+160*8+1	* ?
	DC.L	SPACE
M	SET	0
	REPT	13
	DC.L	FNT3+M
	DC.L	FNT3+M+1
M	SET	M+8
	ENDR
PALETTE
	DS.L	1
SPEC
	INCBIN	ALLIANCE.SPU
SPR_MOUSE:
          INCBIN 'COPYB1.IMG'
                END