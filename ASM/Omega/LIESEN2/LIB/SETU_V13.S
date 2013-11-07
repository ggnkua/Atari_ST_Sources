; *************************************
; **
; ** By Martin Liesen 1992
; *************************************
                OPT P-
                >PART 'CALL SUPER PART'
                pea     Begin(PC)
                move.w  #38,-(A7)
                trap    #14
                addq.l  #6,A7
                clr.w   -(A7)
                trap    #1
                ENDPART
Begin:          >PART 'SAVE REGISTERS'
****************************************
**   S A V E    R E G I S T E R S
****************************************
                lea     _SaveTab(PC),A6
                move.l  A7,(A6)+
                move.l  $00000070.w,(A6)+
                move.l  $00000120.w,(A6)+
                move.b  $FFFFFA07.w,(A6)+
                move.b  $FFFFFA09.w,(A6)+
                move.b  $FFFFFA0F.w,(A6)+
                move.b  $FFFFFA11.w,(A6)+
                move.b  $FFFFFA13.w,(A6)+
                move.b  $FFFFFA15.w,(A6)+
                move.b  $FFFFFA17.w,(A6)+
                addq.w  #1,A6
                move.l  $00000068.w,(A6)+
                move.l  $00000070.w,(A6)+
                move.l  $00000118.w,(A6)+
                move.l  $00000120.w,(A6)+
                move.w  #4,-(A7)
                trap    #14
                move.w  D0,(A6)+
                move.w  #2,-(A7)
                trap    #14
                move.l  D0,(A6)+
                movem.l $FFFF8240.w,D0-D7
                movem.l D0-D7,(A6)
                lea     32(A6),A6
                bra.s   Startup
                ENDPART
Back:           >PART 'RESTORE AND RTS'
******************************************
*** R E S T O R E   E V E R Y T H I N G
******************************************
                move    #$2700,SR
                lea     _SaveTab(PC),A6
                movea.l (A6)+,A7
                move.l  (A6)+,$00000070.w
                move.l  (A6)+,$00000120.w
                move.b  (A6)+,$FFFFFA07.w
                move.b  (A6)+,$FFFFFA09.w
                move.b  (A6)+,$FFFFFA0F.w
                move.b  (A6)+,$FFFFFA11.w
                move.b  (A6)+,$FFFFFA13.w
                move.b  (A6)+,$FFFFFA15.w
                move.b  (A6)+,$FFFFFA17.w
                addq.w  #1,A6
                move.l  (A6)+,$00000068.w
                move.l  (A6)+,$00000070.w
                move.l  (A6)+,$00000118.w
                move.l  (A6)+,$00000120.w
                move.w  (A6)+,-(A7)
                move.l  (A6),-(A7)
                move.l  (A6)+,-(A7)
                move.w  #5,-(A7)
                trap    #14
                lea     12(A7),A7
                movem.l (A6)+,D0-D7
                movem.l D0-D7,$FFFF8240.w
                rts
                ENDPART

Startup:        >PART 'Init'

s:              lea     s(PC),A6
                move    #$2700,SR
                lea     Vbl(PC),A0
                move.l  A0,$00000070.w
                lea     TimerB(PC),A0
                move.l  A0,$00000120.w
                move.b  #0,$FFFFFA07.w
                move.b  #0,$FFFFFA09.w
                move.b  #0,$FFFFFA13.w
                move.b  #0,$FFFFFA15.w
                move.b  #1,$FFFFFA13.w
                move.b  #1,$FFFFFA07.w
                bclr    #3,$FFFFFA17.w
                move    #$2300,SR

                move.b  #0,$FFFF8260.w
                bsr.s   Vsync
                move.b  #0,$FFFF820A.w
                bsr.s   Vsync
                bsr.s   Vsync
                move.b  #2,$FFFF820A.w

                ENDPART

MainLoop:       >PART 'Main Loop'

                bsr.s   Vsync
                clr.w   $FFFF8240.w
                clr.b   $FFFFFA1B.w
                move.b  #1,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
                bra.s   MainLoop

                ENDPART

Vsync:          >PART 'Vsync'
                tst.w   _VblFlag-s(A6)
                beq.s   Vsync
                clr.w   _VblFlag-s(A6)
                rts
                ENDPART

TimerB:         >PART 'Raster Irq'
                eori.w  #$FFFF,$FFFF8240.w
                rte
                ENDPART
Vbl:            >PART 'VBL Irq'
                addq.w  #1,_VblFlag-s(A6)
                cmpi.b  #$39,$FFFFFC02.w
                beq     Back
                rte
                ENDPART


_VblFlag:       DS.W 1
_SaveTab:       DS.L 64
                END
