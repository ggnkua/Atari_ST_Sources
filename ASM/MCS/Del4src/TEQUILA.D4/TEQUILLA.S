
                TEXT

ECRAN           EQU $068000

	MOVE.W	#$2700,SR

                movem.l NILL(PC),D0-D7
                movem.l D0-D7,$FFFF8240.w

	CLR.B	$FFFF8260.W

	MOVE.B	#$6,$FFFF8201.W
	MOVE.B	#$80,$FFFF8203.W

                lea     $060000,A1
                moveq   #0,D0
                move.w  #60*2-1,D1
EFF_LIG:
                move.l  D0,(A1)+
                dbra    D1,EFF_LIG

                lea     TAB_COL,A0
                lea     TAB_COL+512,A1
                move.w  #221,D6
ROX_RST:
                movem.w (A0),D0-D5/A2-A3
                movem.w D0-D5/A2,2(A1)
                move.w  A3,(A1)
                lea     16(A0),A0
                lea     16(A1),A1
                dbra    D6,ROX_RST

                movea.l #DEFORM,A0
                lea     RSTCORD,A1
                lea     DEFRST,A2
                move.w  #3199,D7
CALC_DEF:
                moveq   #0,D0
                moveq   #0,D2
                move.w  (A0)+,D0
                move.w  (A2)+,D2
                divu    #256,D2
                lsr.w   #2,D0
                add.w   D2,D0
                and.w   #$07,D0
                mulu    #512,D0
                move.w  D0,(A1)+
                cmpa.l  #FRST2,A2
                bne.s   MAG_02
                movea.l #DEFRST,A2
MAG_02:
                dbra    D7,CALC_DEF

                lea     SAVE,A0
                move.l  $70.w,(A0)+
                move.l  $0120.w,(A0)+
                move.b  $FFFFFA07.w,(A0)+
                move.b  $FFFFFA09.w,(A0)+
                move.b  $FFFFFA13.w,(A0)+
                move.b  $FFFFFA17.w,(A0)+
                move.b  $FFFA1B,(A0)+
                move.b  $FFFA21,(A0)+
                move    #$2300,SR

                movea.l #ZIK,A0
                movea.l #$056000,A1
                move.w  #$08B9,D0
REL:            move.l  (A0)+,(A1)+
                dbra    D0,REL
                jsr     $056604

                bsr     INTRO

                movem.l PAL,D0-D7
                movem.l D0-D7,$FFFF8240.w

                move.b  #4,$FFFF820F.w

                lea     TAB_COR,A0
                lea     64(A0),A1
                moveq   #0,D0
                move.w  #29,D7
LOOP01:
                moveq   #15,D6
LOOP02:
                move.w  (A0)+,D0
                move.w  (A0)+,D1
                add.w   #8,D0
                move.w  D0,(A1)+
                move.w  D1,(A1)+
                dbra    D6,LOOP02
                dbra    D7,LOOP01

                movem.l FOND,D0-D1
                lea     $068004-240,A0
                lea     $068004+240*400,A1
AFF_FOND:
                movem.l D0-D1,(A0)
                lea     8(A0),A0
                cmpa.l  A0,A1
                bgt.s   AFF_FOND

                movea.l #$068000+116+240*30,A1
                lea     IMG,A0
                move.w  #322,D2
ONE_LIG:
                move.w  #33,D1
AFF_IMG:
                move.l  (A0)+,(A1)+
                dbra    D1,AFF_IMG
                lea     24(A1),A1
                lea     80(A1),A1
                dbra    D2,ONE_LIG

                move    #$2700,SR
                move.l  #VBL,$70.w
                move.b  #1,$FFFFFA07.w
                clr.b   $FFFFFA09.w
                move.b  #1,$FFFFFA13.w
                bclr    #3,$FFFFFA17.w
                move    #$2300,SR

WAIT:
                bra.s   WAIT

FIN:
                move    #$2700,SR
                movem.l NILL,D0-D7
                movem.l D0-D7,$FFFF8240.w
                lea     SAVE,A0
                move.l  (A0)+,$70.w
                move.l  (A0)+,$0120.w
                move.b  (A0)+,$FFFFFA07.w
                move.b  (A0)+,$FFFFFA09.w
                move.b  (A0)+,$FFFFFA13.w
                move.b  (A0)+,$FFFFFA17.w
                move.b  (A0)+,$FFFFFA1B.w
                move.b  (A0)+,$FFFFFA21.w

                move.w  #5000,D1
BC_NOP:
                divu    #1,D1
                dbra    D1,BC_NOP

                move.b  #0,$FFFF820F.w
                move.b  #0,$FFFF8265.w

	ILLEGAL


********** RESTE 1500 NOPS ***********

VBL:
                cmpi.b  #$39,$FFFC02
                beq.s   FIN

                clr.b   $FFFA1B
                move.b  #100,$FFFA21
                move.b  #4,$FFFA1B
                move.l  #HBL_INIT,$0120.w

                jsr     $056600
                addi.l  #6,PEK_DEF+2
                cmpi.l  #DEFORM+3200,PEK_DEF+2
                blt.s   PEK_ADR
                move.l  #DEFORM,PEK_DEF+2
PEK_ADR:
                movea.l #TAB_CORD,A0
                move.l  (A0)+,D0
                move.w  (A0)+,D1
                lea     $068000+240,A0
                adda.l  D0,A0
                move.l  A0,PEK_ECR+2
                add.w   D1,D1
                add.w   D1,D1
                move.w  D1,PEK_ADD1+2
                move.w  D1,PEK_ADD2+2
                move.w  D1,PEK_ADD3+2
                move.w  D1,PEK_ADD4+2

                addi.l  #6,PEK_ADR+2
                cmpi.l  #F_ADR,PEK_ADR+2
                bne.s   PAS_FIN_A
                move.l  #TAB_CORD,PEK_ADR+2
PAS_FIN_A:
                movea.l #RSTCORD,A0
                moveq   #0,D1
                move.w  (A0),D1
                movea.l #TAB_COL,A1
                adda.l  D1,A1
                move.l  A1,PEKCOL+2
                addq.l  #6,PAS_FIN_A+2
                cmpi.l  #FCORDRST,PAS_FIN_A+2
                blt.s   PAS_FRST
                move.l  #RSTCORD,PAS_FIN_A+2
PAS_FRST:
                movea.l PAS_FIN_A+2,A1
                move.l  A1,PEKRST+2
                move.l  PEKRS2+2,D0
                add.l   #16*2,D0
                and.w   #511,D0
                move.l  D0,PEKRS2+2
                move.w  #$00,$FFFF8240.w
                rte


***************  HBL ********************

***** REGISTRES LIBRES :D3/D5/D6/A3/A6 *****

HBL_INIT:
                stop    #$2100
                stop    #$2100
                move    #$2700,SR

                lea     $FFFF820A.w,A0
                lea     $FFFF8260.w,A1
                lea     $FFFF8209.w,A3

                moveq   #0,D0
                moveq   #0,D2

                DCB.W 73,$4E71

                move.b  D0,(A0)
                DCB.W 10,$4E71
                move.w  A0,(A0)
                DCB.W 26,$4E71

                nop
                sub.b   (A3),D2
                lsl.l   D2,D2

                clr.b   $FFFFFA1B.w

                move.b  #$06,$FFFF8201.w
                move.b  #$00,$FFFF8203.w
                move.b  #$00,$FFFF8209.w
PEKCOL:
                movea.l #TAB_COL,A2
PEKRS2:
                movea.l #0,A6
PEK_DEF:
                lea     DEFORM,A3
PEK_ECR:
                lea     $068000+240,A4
                lea     TAB_COR,A5
                lea     238(A4),A4

                REPT 38
                nop
                ENDR

                move.w  #227,D7
LIG:
                move.w  A0,(A1)
                nop
                nop
                move.b  D0,(A1)

                move    A4,USP

                moveq   #0,D1
                moveq   #0,D2
                move.w  (A3)+,D1

PEK_ADD1:
                add.w   #$FFFF,D1

                move.l  0(A5,D1.w),D1
                swap    D1
                adda.w  D1,A4

                move.l  A4,-(SP)

                move.b  1(SP),D2
                swap    D2
                move.b  2(SP),D2
                swap    D2
                move.b  3(SP),D4

                addq.l  #4,SP

                move    USP,A4

                lea     240(A4),A4

************* THE RASTERS *****************

                move    A6,USP          * 1
                movem.l 0(A2,A6.w),D3/D5-D6/A6 ; 12 NOPS
                movem.l D3/D5-D6/A6,$FFFF8250.w ; 12 NOPS
                move    USP,A6          * 1
                lea     16(A6),A6       * 2
                move.w  A6,D3           * 1
                and.w   #511,D3         * 2
                movea.w D3,A6           * 1

                move    A5,USP          * 1
PEKRST:
                movea.l #RSTCORD,A5     * 3
                move.w  (A5)+,D3        * 2
                movea.l #TAB_COL,A2     * 3
                adda.w  D3,A2           * 2
                move.l  A5,PEKRST+2     * 5
                move.l  A5,PEKRST2+2    * 5
                move    USP,A5          * 1

********* TOTAL = 32 NOPS ******************

                nop

                move.b  D0,(A0)
                swap    D1
                move.w  A0,(A0)

                DCB.W 2,$4E71

                move.b  D2,$FFFF8205.w
                swap    D2
                move.b  D2,$FFFF8207.w
                move.b  D4,$FFFF8209.w

                move.w  A0,(A1)
                nop
                move.b  D0,(A1)

                move.b  D1,$FFFF8265.w
                DCB.W 4,$4E71

                subq.w  #1,D7
                bne     LIG


************* border bas ***********

                move.w  A0,(A1)
                nop
                nop
                move.b  D0,(A1)

                move    A4,USP

                moveq   #0,D1
                moveq   #0,D2
                move.w  (A3)+,D1

PEK_ADD2:
                add.w   #$FFFF,D1

                move.l  0(A5,D1.w),D1
                swap    D1
                adda.w  D1,A4

                move.l  A4,-(SP)

                move.b  1(SP),D2
                swap    D2
                move.b  2(SP),D2
                swap    D2
                move.b  3(SP),D4

                addq.l  #4,SP

                move    USP,A4
                lea     240(A4),A4

                move    A6,USP          * 1
                movem.l 0(A2,A6.w),D3/D5-D6/A6 ; 12 NOPS
                movem.l D3/D5-D6/A6,$FFFF8250.w ; 12 NOPS
                move    USP,A6          * 1
                lea     16(A6),A6       * 2
                move.w  A6,D3           * 1
                and.w   #511,D3         * 2
                movea.w D3,A6           * 1

                move    A5,USP          * 1
PEKRST2:
                movea.l #RSTCORD,A5     * 3
                move.w  (A5)+,D3        * 2
                movea.l #TAB_COL,A2     * 3
                adda.w  D3,A2           * 2
                move.l  A5,PEKRST3+2    * 5
                move    USP,A5          * 1

                DCB.W 6,$4E71

                move.b  D0,(A0)
                swap    D1
                move.w  A0,(A0)

                DCB.W 2,$4E71

                move.b  D2,$FFFF8205.w
                swap    D2
                move.b  D2,$FFFF8207.w
                move.b  D4,$FFFF8209.w

                move.w  D0,(A0)
                move.w  A0,(A1)
                move.b  D0,(A1)

                move.b  D1,$FFFF8265.w
                DCB.W 7,$4E71

************ new line *************

                move.w  A0,(A1)
                move.w  A0,(A0)
                move.b  D0,(A1)

                move    A4,USP

                moveq   #0,D1
                moveq   #0,D2
                move.w  (A3)+,D1

PEK_ADD3:
                add.w   #$FFFF,D1

                move.l  0(A5,D1.w),D1
                swap    D1

                adda.w  D1,A4

                move.l  A4,-(SP)

                move.b  1(SP),D2
                swap    D2
                move.b  2(SP),D2
                swap    D2
                move.b  3(SP),D4

                addq.l  #4,SP

                move    USP,A4

                lea     240(A4),A4

                move    A6,USP          * 1
                movem.l 0(A2,A6.w),D3/D5-D6/A6 ; 12 NOPS
                movem.l D3/D5-D6/A6,$FFFF8250.w ; 12 NOPS
                move    USP,A6          * 1
                lea     16(A6),A6       * 2
                move.w  A6,D3           * 1
                and.w   #511,D3         * 2
                movea.w D3,A6           * 1

                move    A5,USP          * 1
PEKRST3:
                movea.l #RSTCORD,A5     * 3
                move.w  (A5)+,D3        * 2
                movea.l #TAB_COL,A2     * 3
                adda.w  D3,A2           * 2
                move.l  A5,PEKRST4+2    * 5
                move    USP,A5          * 1

                DCB.W 6,$4E71

                move.b  D0,(A0)
                swap    D1
                move.w  A0,(A0)

                DCB.W 2,$4E71
                move.b  D2,$FFFF8205.w
                swap    D2
                move.b  D2,$FFFF8207.w
                move.b  D4,$FFFF8209.w

                move.w  A0,(A1)
                nop
                move.b  D0,(A1)

                move.b  D1,$FFFF8265.w
                moveq   #43,D7
                DCB.W 7,$4E71

LIG2:
                move.w  A0,(A1)
                nop
                nop
                move.b  D0,(A1)

                move    A4,USP

                moveq   #0,D1
                moveq   #0,D2
                move.w  (A3)+,D1

PEK_ADD4:
                add.w   #$FFFF,D1

                move.l  0(A5,D1.w),D1
                swap    D1

                adda.w  D1,A4

                move.l  A4,-(SP)

                move.b  1(SP),D2
                swap    D2
                move.b  2(SP),D2
                swap    D2
                move.b  3(SP),D4

                addq.l  #4,SP

                move    USP,A4
                lea     240(A4),A4

                move    A6,USP          * 1
                movem.l 0(A2,A6.w),D3/D5-D6/A6 ; 12 NOPS
                movem.l D3/D5-D6/A6,$FFFF8250.w ; 12 NOPS
                move    USP,A6          * 1
                lea     16(A6),A6       * 2
                move.w  A6,D3           * 1
                and.w   #511,D3         * 2
                movea.w D3,A6           * 1

                move    A5,USP          * 1
PEKRST4:
                movea.l #RSTCORD,A5     * 3
                move.w  (A5)+,D3        * 2
                movea.l #TAB_COL,A2     * 3
                adda.w  D3,A2           * 2
                move.l  A5,PEKRST4+2    * 5
                move    USP,A5          * 1

                DCB.W 6,$4E71

                move.b  D0,(A0)
                swap    D1
                move.w  A0,(A0)

                DCB.W 2,$4E71
                move.b  D2,$FFFF8205.w
                swap    D2
                move.b  D2,$FFFF8207.w
                move.b  D4,$FFFF8209.w

                move.w  A0,(A1)
                nop
                move.b  D0,(A1)

                move.b  D1,$FFFF8265.w
                DCB.W 5,$4E71

                dbra    D7,LIG2

                move.b  #0,$FFFF8265.w

                move.w  #0,$FFFF8240.w

                clr.b   $FFFA1B
                move.b  #1,$FFFA21
                move.b  #8,$FFFA1B
                move.l  #NULL,$0120.w
                move    #$2300,SR
NULL:
                rte

INTRO:
                move.b  #0,$FFFF820F.w
                lea     PRESENT,A0
                lea     ECRAN,A1
                move.w  #199,D1
AFF_PRES:
                REPT 20
                move.w  (A0)+,(A1)
                addq.l  #8,A1
                ENDR
                lea     8(A1),A1
                dbra    D1,AFF_PRES

                move    #$2700,SR
                move.l  #VBL_INTRO,$70.w
                move.b  #1,$FFFFFA07.w
                move.b  #1,$FFFFFA13.w
                move.b  #0,$FFFFFA09.w
                bclr    #3,$FFFA17
                move    #$2300,SR
WAIT_TOUCHE:
                cmpi.b  #$39,$FFFC02
                bne.s   WAIT_TOUCHE
WAIT_REL:
                cmpi.b  #$39,$FFFC02
                beq.s   WAIT_REL
                movem.l NILL,D0-D7
                movem.l D0-D7,$FFFF8240.w
                move    #$2700,SR
                clr.b   $FFFA1B
                move.l  #VBL_NULL,$70.w
                move.l  #NULL,$0120.w
                move    #$2300,SR
                rts
VBL_NULL:
                movem.l D0-A7,-(SP)
                jsr     $056600
                movem.l (SP)+,D0-A7
                rte

VBL_INTRO:
                move    #$2700,SR
                clr.b   $FFFA1B
                move.b  #3,$FFFA21
                move.b  #8,$FFFA1B
                move.l  #HBL_INTRO1,$0120.w
                lea     RST_INTRO(PC),A6
                addq.l  #8,PEK_MCS1+2
                cmpi.l  #F_DEFINTRO,PEK_MCS1+2
                blt.s   PAS_MCS1
                move.l  #DEF_INTRO,PEK_MCS1+2
PAS_MCS1:
                jsr     $056600
                move    #$2300,SR
                rte
HBL_INTRO1:
                clr.b   $FFFFFA1B.w
                move.b  #1,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
                move.l  #HBL_INTRO,$0120.w
PEK_MCS1:
                movea.l #DEF_INTRO,A5
                move.w  (A5)+,D7
                rte
HBL_INTRO:
                move.b  D7,$FFFF8265.w
                move.w  (A6)+,$FFFF8242.w
                cmpa.l  #PAL,A6
                bne.s   PAS_MCS2
                movea.l #RST_INTRO,A6
PAS_MCS2:
                cmpa.l  #F_DEFINTRO,A5
                blt.s   F_01
                movea.l #DEF_INTRO,A5
F_01:
                move.w  (A5)+,D7
                addq.l  #4,A5
F_HBLINTRO:
                rte
NILL:
                DS.W 16
RST_INTRO:
                DC.W $0222,$0333,$0444,$0555,$0666,$0777
PAL:
                DC.W $00,$0F30,$30,$0FED,$0FFF,$0CCC,$0333,$00
PAL2:
                DC.W $0777,$0666,$0555,$0444,$0333,$0222,$0111
                DC.W $0FFF
DEF_INTRO:
                INCBIN 'INTRO.DEF'
F_DEFINTRO:
IMG:
                INCBIN 'COPYB8.IMG'
                INCBIN 'COPYB9.IMG'
ZIK:
                INCBIN 'MINE.MUS'
TAB_CORD:
                INCBIN 'COORDS.MCS'
F_ADR:
DEFRST:
                INCBIN 'RST.ADR'
FRST2:
DEFORM:
                DCB.W 400,400
                INCBIN 'DEF2.MAG'
                DCB.W 400,400
                INCBIN 'DEF2.MAG'
TAB_COR:
                DC.W 0,1
                DC.W 0,1
                DC.W 0,2,0,3,0,4,0,5,0,6,0,7,0,8,0,9,0,10,0,11
                DC.W 0,12,0,13,0,14,0,15
                DS.W 64*100
PRESENT:
                INCBIN 'PRES.BIN'
                EVEN
SAVE:
                DS.L 5
FOND:
                INCBIN 'COPYB7.IMG'
RSTCORD:
                DS.W 1600
FCORDRST:
                DS.W 1600
TAB_COL:
                DC.W 0,0,$0CCC,$0CCC,$0CCC,$00,$00,$00
                DC.W $00,$0FFF,$0DDD,$0DDD,$0CCC,$0CCC,0,0
                DC.W $0FFF,$0FFF,$0FFF,$0DDD,$0CCC,$0FFF,$0CCC,0
                DC.W $0FFF,$0FFF,$0FFF,$0DDD,$0CCC,$0DDD,$0CCC,0
                DC.W $0FFF,$0FFF,$0FFF,$0DDD,$0CCC,$0DDD,$0CCC,0
                DC.W 0,$0FFF,$0DDD,$0CCC,$0CCC,$0CCC,0,0
                DC.W 0,0,$0CCC,$0CCC,$0CCC,$00,$00,$00
                DS.W 8

                DC.W 0,0,$0C00,$0C00,$0C00,$00,$00,$00
                DC.W $00,$0F00,$0D00,$0D00,$0C00,$0C00,0,0
                DC.W $0F00,$0F00,$0F00,$0D00,$0C00,$0F00,$0C00,0
                DC.W $0F00,$0F00,$0F00,$0D00,$0C00,$0D00,$0C00,0
                DC.W $0F00,$0F00,$0F00,$0D00,$0C00,$0D00,$0C00,0
                DC.W 0,$0F00,$0D00,$0C00,$0C00,$0C00,0,0
                DC.W 0,0,$0C00,$0C00,$0C00,$00,$00,$00
                DS.W 8

                DC.W 0,0,$C0,$C0,$C0,$00,$00,$00
                DC.W $00,$F0,$D0,$D0,$C0,$C0,0,0
                DC.W $F0,$F0,$F0,$D0,$C0,$F0,$C0,0
                DC.W $F0,$F0,$F0,$D0,$C0,$D0,$C0,0
                DC.W $F0,$F0,$F0,$D0,$C0,$D0,$C0,0
                DC.W 0,$F0,$D0,$C0,$C0,$C0,0,0
                DC.W 0,0,$C0,$C0,$C0,$00,$00,$00
                DS.W 8

                DC.W 0,0,$0CC0,$0CC0,$0CC0,$00,$00,$00
                DC.W $00,$0FF0,$0DD0,$0DD0,$0CC0,$0CC0,0,0
                DC.W $0FF0,$0FF0,$0FF0,$0DD0,$0CC0,$0FF0,$0CC0,0
                DC.W $0FF0,$0FF0,$0FF0,$0DD0,$0CC0,$0DD0,$0CC0,0
                DC.W $0FF0,$0FF0,$0FF0,$0DD0,$0CC0,$0DD0,$0CC0,0
                DC.W 0,$0FF0,$0DD0,$0CC0,$0CC0,$0CC0,0,0
                DC.W 0,0,$0CC0,$0CC0,$0CC0,$00,$00,$00
                DS.W 8

                DS.W 256*8
                END
