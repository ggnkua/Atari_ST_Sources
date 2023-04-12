;*------------------------------------------------------------------------*
;*  QuaST Magazyn IX (C) 28.12.1975 QuaST Club / dysk #C - procedury *.S  *
;*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*
;|																		  |
;|					Overscan II - usuniecie bocznych ramek		  	  	  |
;|  																	  |
;| autor: ???		    											      |
;| uwagi: -																  |
;*------------------------------------------------------------------------*

                PEA             0
                MOVE.W          #$0020,-(A7)
                TRAP            #1
                ADDQ.L          #6,A7

                MOVE.W          #0,$FFFF8240
                MOVE.W          #$0C4A,$FFFF8242
                MOVE.W          #$00F4,$FFFF8246

                MOVE.W          #0,-(A7)
                PEA             $000F8000
                PEA             $000F8000
                MOVE.W          #5,-(A7)
                TRAP            #14
                LEA             12(A7),A7

                MOVE.W          #$0000,$00FF8240+0*2
                MOVE.W          #$0010,$00FF8240+1*2
                MOVE.W          #$0020,$00FF8240+2*2
                MOVE.W          #$0030,$00FF8240+3*2
                MOVE.W          #$0040,$00FF8240+4*2
                MOVE.W          #$0050,$00FF8240+5*2
                MOVE.W          #$0060,$00FF8240+6*2
                MOVE.W          #$0070,$00FF8240+7*2
                MOVE.W          #$0000,$00FF8240+8*2
                MOVE.W          #$0000,$00FF8240+9*2
                MOVE.W          #$0000,$00FF8240+10*2
                MOVE.W          #$0000,$00FF8240+11*2
                MOVE.W          #$0000,$00FF8240+12*2
                MOVE.W          #$0000,$00FF8240+13*2
                MOVE.W          #$0000,$00FF8240+14*2
                MOVE.W          #$0000,$00FF8240+15*2

                LEA             $000F8000,A0
                LEA             160(A0),A0
                MOVE.W          #199,D0
DO:             REPT 26/2
                MOVE.W          #%0101010110101010,(A0)+
                MOVE.W          #%0011001111001100,(A0)+
                MOVE.W          #%0000111111110000,(A0)+
                MOVE.W          #%0000000000000000,(A0)+
                MOVE.W          #0,(A0)+
                MOVE.W          #0,(A0)+
                MOVE.W          #0,(A0)+
                MOVE.W          #0,(A0)+
                ENDR
                LEA             2*8+6(A0),A0
                DBRA            D0,DO


                MOVEQ           #0,D3

                LEA             SAVEMFP(PC),A1
                LEA             $FFFFFA00,A0
                MOVE.B          $0007(A0),(A1)+
                MOVE.B          $0009(A0),(A1)+
                MOVE.B          $0011(A0),(A1)+
                MOVE.B          $0013(A0),(A1)+
                MOVE.B          $0015(A0),(A1)+
                MOVE.B          $0017(A0),(A1)+
                MOVE.B          $001B(A0),(A1)+
                MOVE.B          $0021(A0),(A1)+
                CLR.B           $0007(A0)
                CLR.B           $0009(A0)
                CLR.B           $0013(A0)
                CLR.B           $0015(A0)
                BSET            #0,$0007(A0)
                BSET            #0,$0013(A0)
                BCLR            #3,$0017(A0)
                MOVE.L          $00000070,OLDVBL
                MOVE.L          #VBL,$00000070

KEY:            CMPI.B          #$39,$00FFFC02
                BNE.S           KEY

                LEA             SAVEMFP(PC),A1
                LEA             $FFFFFA00,A0
                MOVE.B          (A1)+,$0007(A0)
                MOVE.B          (A1)+,$0009(A0)
                MOVE.B          (A1)+,$0011(A0)
                MOVE.B          (A1)+,$0013(A0)
                MOVE.B          (A1)+,$0015(A0)
                MOVE.B          (A1)+,$0017(A0)
                MOVE.B          (A1)+,$001B(A0)
                MOVE.B          (A1)+,$0021(A0)
                MOVE.L          OLDVBL(PC),$00000070

                CLR.L           -(A7)
                TRAP            #1

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

VBL:            MOVE.W          #$0FFF,$00FF8240
                LEA             RASTRY+2(PC),A2
                ADDQ.L          #2,D3
                CMP.L           #2*200,D3
                BNE             DAL
                MOVEQ           #0,D3
DAL:            ADDA.L          D3,A2

                LEA             $00FF8240,A3
                LEA             $FFFF820A,A0
                LEA             $FFFF8260,A1
                MOVEQ           #0,D0

                MOVE.W          #0,$00FF8240

LOOP:           MOVE.B          $FFFF8209,D0
                BEQ             LOOP
                NOT.B           D0
                LSL.B           D0,D0

                REPT 70
                NOP
                ENDR

                MOVE.W          #199,D7

LINES:          NOP
                MOVE.W          A1,(A1)
                NOP
                MOVE.B          D0,(A1)

                MOVE.W          (A2)+,(A3)
                REPT 86
                NOP
                ENDR

                MOVE.B          D0,(A0)
                MOVE.W          A0,(A0)

                REPT 13
                NOP
                ENDR

                MOVE.W          A1,(A1)
                NOP
                MOVE.B          D0,(A1)

                REPT 8
                NOP
                ENDR

                DBRA            D7,LINES

                MOVE.W          #$0000,$00FF8240
                RTE
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SAVEMFP:        DS.B 8
OLDVBL:         DS.L 0
RASTRY:
                REPT 14
                DC.W $0008,$0001,$0009,$0002,$000A,$0003,$000B,$0004,$000C,$0005
                DC.W $000D,$0006,$000E,$0007,$000F,$0007,$000E,$0006,$000D,$0005
                DC.W $000C,$0004,$000B,$0003,$000A,$0002,$0009,$0001,$0008,$0000
                DC.W $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
                ENDR
                DS.W 200
                END
