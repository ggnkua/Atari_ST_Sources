;*------------------------------------------------------------------------*
;*  QuaST Magazyn IX (C) 28.12.1975 QuaST Club / dysk #C - procedury *.S  *
;*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*
;|																		  |
;|				Poly II - wypelnianie zamkinietych przestrzeni 			  |
;|  																	  |
;| autor: ???										    				  |	
;| uwagi: -																  |
;*------------------------------------------------------------------------*

MFP             EQU $FFFFFA00
MFPIERA         EQU MFP+$0007
MFPIERB         EQU MFP+$0009
MFPISRA         EQU MFP+$000F
MFPISRB         EQU MFP+$0011
MFPIMRA         EQU MFP+$0013
MFPIMRB         EQU MFP+$0015
MFPVR           EQU MFP+$0017
MFPTACR         EQU MFP+$0019
MFPTBCR         EQU MFP+$001B
MFPTADR         EQU MFP+$001F
MFPTBDR         EQU MFP+$0021


                CLR.L           -(A7)
                MOVE.W          #$0020,-(A7)
                TRAP            #1
                ADDQ.L          #6,A7

                BSR.S           SAVE_STATE
                BSR	           INSTALL_INTER
                BSR             SPE_INITS

WAIT_SPACE:
                CMPI.B          #$39,$FFFFFC02.w
                BNE.S           WAIT_SPACE

WAIT_NO_SPACE:
                CMPI.B          #$0039+$0080,$FFFFFC02.w
                BNE.S           WAIT_NO_SPACE

                MOVE            #$2700,SR

                BSR             RESTORE_STATE

                MOVE            #$2300,SR

                PEA             0.w
                TRAP            #1

SAVE_STATE:
                LEA             $FFFF8200.w,A6
                LEA             OLD_SHIFTER(PC),A5
                MOVE.L          (A6),D0
                MOVE.L          D0,(A5)+

                MOVEM.L         $0040(A6),D0-D7
                MOVEM.L         D0-D7,(A5)
                LEA             32(A5),A5

                MOVE.W          $0060(A6),(A5)

                MOVE.L          $00000070,OLD_VBL
                MOVE.L          $00000118,OLD_KBD
                MOVE.B          MFPIERA,OLD_MFP
                MOVE.B          MFPIERB,OLD_MFP+1
                MOVE.B          MFPIMRA,OLD_MFP+2
                MOVE.B          MFPIMRB,OLD_MFP+3

                RTS

INSTALL_INTER:
                MOVE.B          #$12,$FFFFFC02.w
                DC.W $A00A

*                MOVE.W          #0,-(A7)
*                PEA             $000F8000
*                PEA             $000F8000
*                MOVE.W          #5,-(A7)
*                TRAP            #14
*                ADDA.L          #12,A7
*                MOVE.L          #$000F8000,ADR_SCR

                CLR.B           MFPIERA
                MOVE.B          #$40,MFPIERB
                MOVE.B          #$40,MFPIMRB

                MOVE.L          #VBL_RET,$00000070.w
                STOP            #$2300


                CLR.B           $0060(A6)

*                LEA             PALETTE,A0
*                MOVEM.L         (A0),D0-D7
*                MOVEM.L         D0-D7,$0040(A6)

                MOVE.L          #SCREEN+256,D0
                CLR.B           D0
                MOVE.L          D0,ADR_SCR
                LSR.L           #8,D0
                MOVEP.W         D0,$0001(A6)

                RTS

RESTORE_STATE:
                MOVE.L          #VBL_RET,$00000070.w
                STOP            #$2300
                MOVE            #$2700,SR

                MOVE.B          OLD_MFP(PC),MFPIERA
                MOVE.B          OLD_MFP+1(PC),MFPIERB
                MOVE.B          OLD_MFP+2(PC),MFPIMRA
                MOVE.B          OLD_MFP+3(PC),MFPIMRB 

                LEA             $FFFF8200.w,A6
                LEA             OLD_SHIFTER(PC),A5
                MOVE.L          (A5)+,D0
                MOVE.L          D0,(A6)
                MOVEM.L         (A5),D0-D7
                MOVEM.L         D0-D7,$0040(A6)
                LEA             32(A5),A5
                MOVE.W          (A5),$0060(A6)

                MOVE.L          OLD_KBD(PC),$00000118.w
                MOVE.L          OLD_VBL(PC),$00000070.w

TEST_KEY:
                BTST            #0,$FFFFFC00.w
                BEQ.S           NO_KEY
                MOVE.B          $FFFFFC02.w,D0
                BRA.S           TEST_KEY
NO_KEY:
                DC.W $A009
                MOVE.B          #8,$FFFFFC02.w
                RTS

SPE_INITS:
                LEA             TAB_LINE_ADR(PC),A0
                MOVEA.L         ADR_SCR(PC),A1
                MOVE.W          #199,D0
.MK_TAB:
                MOVE.L          A1,(A0)+
                LEA             160(A1),A1
                DBRA            D0,.MK_TAB

MK_ROUT:
                LEA             TAB_AFF(PC),A2
                MOVE.W          #$C440,D0
                MOVE.W          #$8168,D1
                MOVE.W          #$8568,D2
                MOVE.W          #$3141,D3

.ROUT1:
                MOVEA.L         (A2)+,A1
                MOVE.W          D0,(A1)+

                MOVE.W          D2,(A1)+
                MOVE.W          #0,(A1)+
                MOVE.W          #$4E75,(A1)+

.ROUT2:
                MOVEA.L         (A2)+,A1
                MOVE.W          D1,(A1)+
                MOVE.W          #0,(A1)+
                MOVE.W          D2,(A1)+
                MOVE.W          #8,(A1)+
                MOVE.W          #$4E75,(A1)+

                MOVE.W          #18,D7
                MOVEQ           #0,D6

.ALL_ROUT:
                MOVE.W          D6,D0
                MOVEA.L         (A2)+,A1
                MOVE.W          D1,(A1)+
                MOVE.W          #0,(A1)+
                MOVE.W          #8,D5
.NBR_BLK:
                MOVE.W          D3,(A1)+
                MOVE.W          D5,(A1)+
                ADDQ.W          #8,D5
                DBRA            D0,.NBR_BLK
                MOVE.W          D2,(A1)+
                MOVE.W          D5,(A1)+
                MOVE.W          #$4E75,(A1)+
                ADDQ.W          #1,D6

                DBRA            D7,.ALL_ROUT

MK_TAB_X:
                LEA             TAB_X(PC),A1
                LEA             MASK(PC),A0
                MOVEQ           #0,D0
                MOVE.W          #19,D1
.MK_TAB1:
                REPT 16
                MOVE.W          (A0),(A1)+
                MOVE.W          D0,(A1)+
                ADDQ.W          #4,A0
                ENDR
                LEA             MASK(PC),A0
                ADDQ.W          #8,D0
                DBRA            D1,.MK_TAB1

MK_TAB_X2:
                LEA             TAB_X2(PC),A1
                LEA             MASK+2(PC),A0
                MOVE.W          #19,D0
.MK_TAB3:
                REPT 16
                MOVE.W          (A0),(A1)+
                ADDQ.W          #4,A0
                ENDR
                LEA             MASK+2(PC),A0
                DBRA            D0,.MK_TAB3

                MOVE.L          #INSTAL_VBL,$00000070.w

                RTS

INSTAL_VBL:
                MOVE.L          #VBL_PLAY,$00000070.w
VBL_RET:
                RTE

VBL_PLAY:

                MOVE.W          #$000F,$FFFF8240.w

                LEA             OBJECT_1(PC),A0

                MOVE.W          (A0)+,D7

.MK_ALL_POLY:
                MOVE.W          (A0)+,D6
                MOVE.W          D6,NB_POINT
                LEA             CO_POINT(PC),A1

.MK_ONE_POLY:
                MOVE.W          (A0)+,(A1)+
                MOVE.W          (A0)+,(A1)+
                DBRA            D6,.MK_ONE_POLY

                MOVEM.L         D7-A0,-(A7)
                BSR.S           POLYGONE
                MOVEM.L         (A7)+,D7-A0

                DBRA            D7,.MK_ALL_POLY

                MOVE.W          #$0FFF,$00FF8240
                RTE

POLYGONE:

                LEA             CO_POINT+2(PC),A0
                MOVE.W          (A0),D0
                MOVE.W          D0,D1
                MOVE.W          D0,D2
                ADDQ.L          #4,A0

                MOVE.W          NB_POINT(PC),D3
                SUBQ.W          #1,D3
.YMINMAX:
                MOVE.W          (A0),D0
                CMP.W           D1,D0
                BGT.S           .MAX
                MOVE.W          D0,D1
                ADDQ.W          #4,A0
                DBRA            D3,.YMINMAX
                BRA.S           .FINI
.MAX:
                CMP.W           D2,D0
                BLT.S           .AGAIN
                MOVE.W          D0,D2
.AGAIN:
                ADDQ.W          #4,A0
                DBRA            D3,.YMINMAX
.FINI:

                TST.W           D1
                BGE.S           .OK
                MOVEQ           #0,D1
                BRA.S           .YMAX
.OK:
                CMPI.W          #199,D1
                BGT             NO_POLY
.YMAX:
                CMPI.W          #199,D2
                BLE.S           .OKOK
                MOVE.W          #199,D2
                BRA.S           .CBON
.OKOK:
                TST.W           D2
                BLT             NO_POLY
.CBON:
                MOVE.W          D1,YMIN
                MOVE.W          D2,YMAX

                MOVE.W          NB_POINT(PC),D0
                MOVE.W          D0,D7
                LEA             CO_POINT(PC),A6
                ADDQ.W          #1,D0
                LSL.W           #2,D0
                MOVE.L          (A6),0(A6,D0.w)

                LEA             XMIN(PC),A0
                LEA             XMAX(PC),A1
MK_LINE:
                MOVEM.W         (A6),D0-D3
                ADDQ.W          #4,A6
                JSR             LINE(PC)
                DBRA            D7,MK_LINE

                LEA             TAB_LINE_ADR(PC),A6
                MOVE.W          YMIN(PC),D3
                MOVE.W          D3,D2
                LSL.W           #2,D2
                ADDA.W          D2,A6

                MOVE.W          YMAX(PC),D7
                SUB.W           D3,D7
                SUBQ.W          #1,D7
                MOVE.W          #$FFFF,D1

                LEA             XMIN(PC),A1
                LEA             XMAX(PC),A2
                ADD.W           D3,D3
                ADD.W           D3,D1
                ADDA.W          D3,A2

                LEA             TAB_X(PC),A3
                LEA             TAB_X2(PC),A4
                LEA             TAB_AFF(PC),A5
                MOVE.W          #$FFF0,D5

FILL:
                LEA             TAB_AFF(PC),A5
                MOVEA.L         (A6)+,A0
                MOVE.W          (A1)+,D0
                MOVE.W          (A2)+,D2

                MOVE.W          D0,D3
                MOVE.W          D2,D6
                LSL.W           #2,D0
                ADDA.W          2(A3,D0.w),A0
                MOVE.W          0(A3,D0.w),D0
                ADD.W           D2,D2
                MOVE.W          0(A4,D2.w),D2

                AND.W           D5,D3
                AND.W           D5,D6
                SUB.W           D3,D6
                LSR.W           #2,D6
                MOVEA.L         0(A5,D6.w),A5
                MOVE.W          #$FFFF,D1
                JSR             (A5)
                DBRA            D7,FILL

NO_POLY:        RTS

NB_POINT:       DS.W 1
CO_POINT:       DS.L 50
YMIN:           DS.W 1
YMAX:           DS.W 1
TAB_LINE_ADR:   DS.L 200
TAB_X:          DS.L 320
TAB_X2:         DS.L 320
AFF1:           DS.W 4
AFF2:           DS.W 5
AFF3:           DS.W 7
AFF4:           DS.W 9
AFF5:           DS.W 11
AFF6:           DS.W 13
AFF7:           DS.W 15
AFF8:           DS.W 17
AFF9:           DS.W 19
AFF10:          DS.W 21
AFF11:          DS.W 23
AFF12:          DS.W 25
AFF13:          DS.W 27
AFF14:          DS.W 29
AFF15:          DS.W 31
AFF16:          DS.W 33
AFF17:          DS.W 35
AFF18:          DS.W 37
AFF19:          DS.W 39
AFF20:          DS.W 41
AFF21:          DS.W 43
TAB_AFF:        DC.L AFF1,AFF2,AFF3,AFF4,AFF5,AFF6,AFF7,AFF8,AFF9,AFF10,AFF11
                DC.L AFF12,AFF13,AFF14,AFF15,AFF16,AFF17,AFF18,AFF19,AFF20,AFF21
XMIN:           DS.W 200
XMAX:           DS.W 200

LINE:
                MOVEA.L         A1,A3
                MOVE.W          D3,D4
                SUB.W           D1,D4
                BEQ.S           .HORIZ
                BPL.S           .TAB_MAX
                MOVEA.L         A0,A3
                EXG             D1,D3
                EXG             D0,D2
                NEG.W           D4
.TAB_MAX:
                MOVE.W          D2,D5
                SUB.W           D0,D5
                BEQ.S           .VERTI
                ADD.W           D1,D1
                ADDA.W          D1,A3
                EXT.L           D5
                ASL.L           #7,D5
                DIVS            D4,D5
                EXT.L           D5
                SWAP            D5
                ASR.L           #7,D5
                SWAP            D5
                SUBQ.W          #1,D4
.MK_LINE1:
                MOVE.W          D0,(A3)+
                ADDX.L          D5,D0
                DBRA            D4,.MK_LINE1
                RTS
.VERTI:
                ADD.W           D1,D1
                ADDA.W          D1,A3
.MK_VERT:
                MOVE.W          D0,(A3)+
                DBRA            D4,.MK_VERT
                RTS
.HORIZ:
                ADD.W           D1,D1
                CMP.W           D0,D2
                BGE.S           .HORIZ_NO_SWAP
                EXG             D0,D2
.HORIZ_NO_SWAP:
                MOVE.W          D0,0(A0,D1.w)
                MOVE.W          D2,0(A1,D1.w)
                RTS
OLD_SHIFTER:    DS.L 100
OLD_VBL:        DS.L 1
OLD_KBD:        DS.L 1
OLD_MFP:        DS.L 10
ADR_SCR:        DS.L 1
MASK:
                DC.W %1111111111111111,%1000000000000000
                DC.W %0111111111111111,%1100000000000000
                DC.W %0011111111111111,%1110000000000000
                DC.W %0001111111111111,%1111000000000000
                DC.W %0000111111111111,%1111100000000000
                DC.W %0000011111111111,%1111110000000000
                DC.W %0000001111111111,%1111111000000000
                DC.W %0000000111111111,%1111111100000000
                DC.W %0000000011111111,%1111111110000000
                DC.W %0000000001111111,%1111111111000000
                DC.W %0000000000111111,%1111111111100000
                DC.W %0000000000011111,%1111111111110000
                DC.W %0000000000001111,%1111111111111000
                DC.W %0000000000000111,%1111111111111100
                DC.W %0000000000000011,%1111111111111110
                DC.W %0000000000000001,%1111111111111111

                DS.W 20
                EVEN

OBJECT_1:       DC.W 0          ; ile polygon'ow-1
                DC.W 3          ; ile wierzcholkow 1 polygon'a-1
                DC.W 160,0,319,100,160,199,0,100

SCREEN:         DS.B 40000
                EVEN
PALETTE:        DC.W $0FFF,$0000,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF
                DC.W $0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF,$0FFF

                END
