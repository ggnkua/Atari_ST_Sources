; *************************************
; ** EUTANASIA "INTRO"
; ** By Martin Liesen 1991
; *************************************
                OPT P-
                >PART 'CALL SUPER PART'
                pea     begin(PC)
                move.w  #38,-(A7)
                trap    #14
                addq.l  #6,A7
                rts
                ENDPART
begin:          >PART 'SAVE REGISTERS'
****************************************
**   S A V E    R E G I S T E R S
****************************************
                lea     savetab(PC),A6
                move.l  A7,(A6)+
                move.l  $00000070.w,(A6)+
                move.l  $00000120.w,(A6)+
                move.b  $FFFFFA07.w,(A6)+
                move.b  $FFFFFA09.w,(A6)+
                move.b  $FFFFFA0F.w,(A6)+
                move.b  $FFFFFA11.w,(A6)+
                move.b  $FFFFFA13.w,(A6)+
                move.b  $FFFFFA15.w,(A6)+
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
                bra.s   startup
                ENDPART
back:           >PART 'RESTORE AND RTS'
******************************************
*** R E S T O R E   E V E R Y T H I N G
******************************************
                move    #$2700,SR
                lea     savetab(PC),A6
                movea.l (A6)+,A7
                move.l  (A6)+,$00000070.w
                move.l  (A6)+,$00000120.w
                move.b  (A6)+,$FFFFFA07.w
                move.b  (A6)+,$FFFFFA09.w
                move.b  (A6)+,$FFFFFA0F.w
                move.b  (A6)+,$FFFFFA11.w
                move.b  (A6)+,$FFFFFA13.w
                move.b  (A6)+,$FFFFFA15.w
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

startup:        >PART 'Init'

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
                move    #$2300,SR

                move.b  #0,$FFFF8260.w
                bsr     Vsync
                move.b  #0,$FFFF820A.w
                bsr     Vsync
                bsr     Vsync
                move.b  #2,$FFFF820A.w

                ENDPART

                >PART 'Screen get .."'
                move.l  #scr1,D0
                and.l   #$FFFFFF00,D0
                move.l  D0,screen1
                move.l  #scr2,D0
                and.l   #$FFFFFF00,D0
                move.l  D0,screen2

                move.w  #2,-(A7)
                trap    #14
                addq.l  #2,A7
                move.l  D0,_Screen-s(A6)
                movea.l D0,A5

                movea.l A5,A0
                move.w  #$7FFF,D0
.rensa:         clr.l   (A0)+
                dbra    D0,.rensa

                clr.b   $FFFFFA1B.w
                move.w  #-1,$FFFF8242.w
                move.w  #0,$FFFF8240.w

                ENDPART


MainLoop:       >PART 'Main Loop'

                clr.w   $FFFF8240.w
                move.b  _Screen+1(PC),$FFFF8201.w
                move.b  _Screen+2(PC),$FFFF8203.w
                bsr.s   Vsync
                bsr.s   Switch

                movea.l _Screen(PC),A0
                moveq   #0,D1
                move.w  #999,D0
.bl„:           move.l  D1,(A0)+
                move.l  D1,(A0)+
                move.l  D1,(A0)+
                move.l  D1,(A0)+
                move.l  D1,(A0)+
                move.l  D1,(A0)+
                move.l  D1,(A0)+
                move.l  D1,(A0)+
                dbra    D0,.bl„

                move.w  #$0102,$FFFF8240.w
                bsr.s   Do_All
                bsr     flytta
                bra.s   MainLoop

                ENDPART
Vsync:          >PART 'Vsync'
                clr.w   VblFlag-s(A6)
.VsyncL:        tst.w   VblFlag-s(A6)
                beq.s   .VsyncL
                rts
                ENDPART

Switch:         >PART 'Switcha Screen'
                not.w   _switch
                beq.s   .other
                movea.l screen1(PC),A0
                bra.s   .join
.other:         movea.l screen2(PC),A0
.join:          move.l  A0,_Screen
                movea.l A0,A5
                rts
                ENDPART

Do_All:         >PART 'Do All Beziers'

                lea     _PointsX(PC),A0
                lea     _PointsY(PC),A1
                lea     _BPoints(PC),A2

                moveq   #3,D6
                move.w  D6,D7
.Tolle:
                addq.l  #2,A0
                addq.l  #2,A1

                move.w  (A0),D1
                move.w  D1,D0
                move.w  D1,D2
                sub.w   -2(A0),D0
                sub.w   2(A0),D2
                asr.w   #1,D0
                asr.w   #1,D2
                add.w   -2(A0),D0
                add.w   2(A0),D2

                tst.w   D7
                bne.s   .notnull
                move.w  2(A0),D2
.notnull:       cmp.w   D6,D7
                bne.s   .notmax
                move.w  -2(A0),D0
.notmax:

                move.w  D0,(A2)
                move.w  D1,2(A2)
                move.w  D2,4(A2)

                move.w  (A1),D1
                move.w  D1,D0
                move.w  D1,D2
                sub.w   -2(A1),D0
                sub.w   2(A1),D2
                asr.w   #1,D0
                asr.w   #1,D2
                add.w   -2(A1),D0
                add.w   2(A1),D2

                move.w  D0,6(A2)
                move.w  D1,8(A2)
                move.w  D2,10(A2)

                movem.l D6-A2,-(A7)
                bsr.s   MakeBezier
                movem.l (A7)+,D6-A2
                dbra    D7,.Tolle

                rts
                ENDPART
MakeBezier:     >PART 'Draw BezierHalf'

                lea     _BPoints(PC),A1
                moveq   #$7D,D0
.loop:
                movea.l A1,A0
                bsr.s   Bezier3
                move.w  D7,-(A7)
                bsr.s   Bezier3
                move.w  (A7)+,D6
                bsr.s   PlotLow

                subq.w  #2,D0
                bpl.s   .loop
                rts
                ENDPART
Bezier3:        >PART 'Three point's BEZIER'
* A0 address to points (words *$7f) (gives a range of 0-$1ff)
* D0  Roh (0-$7F)

* destroys d1,d6,d7,a0

                moveq   #$7F,D1
                sub.w   D0,D1           ; d1=1-roh

                move.w  D1,D7
                mulu    D7,D7
                mulu    (A0)+,D7

                add.w   D1,D1
                mulu    D0,D1
                mulu    (A0)+,D1

                move.w  D0,D6           ; D0 oskadad ist„llet!
                mulu    D6,D6
                mulu    (A0)+,D6

                add.l   D6,D7
                add.l   D1,D7
                lsl.l   #2,D7
                swap    D7

                rts
                ENDPART

PlotHi:         >PART 'Plot HiRez'
* d6=x
* d7=y
* screen address in A5
* destroys d5
                mulu    #80,D7
                move.w  D6,D5
                eori.w  #$0007,D5
                lsr.w   #3,D6
                add.w   D6,D7
                bset    D5,0(A5,D7.w)
                rts
                ENDPART
PlotLow:        >PART 'Plot LowRez'
* d6=x
* d7=y
* screen address in A5
* destroys d5
                mulu    #160,D7
                move.w  D6,D5
                and.w   #$000F,D5
                sub.w   D5,D6
                eori.w  #$000F,D5
                lsr.w   #1,D6
                add.w   D6,D7
                moveq   #0,D6
                bset    D5,D6
                or.w    D6,0(A5,D7.w)
*                eor.w   D6,0(A5,D7.w)
                rts
                ENDPART


flytta:         >PART 'Flytta pixlarna'
                lea     _PointsX(PC),A0
                lea     _SpeedX(PC),A1
                lea     _PointsY(PC),A2
                lea     _SpeedY(PC),A3

                moveq   #5,D1

.doall:         move.w  (A1),D0
                add.w   D0,(A0)
                bpl.s   .n1
                clr.w   (A0)
                neg.w   (A1)
.n1:            cmpi.w  #319,(A0)
                ble.s   .n2
                move.w  #319,(A0)
                neg.w   (A1)
.n2:            addq.l  #2,A0
                addq.l  #2,A1

                move.w  (A3),D0
                add.w   D0,(A2)
                bpl.s   .n3
                clr.w   (A2)
                neg.w   (A3)
.n3:            cmpi.w  #199,(A2)
                ble.s   .n4
                move.w  #199,(A2)
                neg.w   (A3)
.n4:            addq.l  #2,A2
                addq.l  #2,A3

                dbra    D1,.doall
                rts

                ENDPART

TimerB:         >PART 'Raster Irq'
                eori.w  #$0630,$FFFF8240.w
                bclr    #0,$FFFFFA0F.w
                rte
                ENDPART
Vbl:            >PART 'VBL Irq'
                addq.w  #1,VblFlag-s(A6)
                cmpi.b  #$39,$FFFFFC02.w
                beq     back
                rte
                ENDPART


VblFlag:        DS.W 1
savetab:        DS.L 64

_Screen:        DS.L 1

_PointsX:       DC.W 0,319,319,0,0,160
_PointsY:       DC.W 0,0,199,199,0,100

_BPoints:       DS.W 6

_SpeedX:        DC.W 1,2,3,-1,-2,-3
_SpeedY:        DC.W -3,-2,-1,1,2,3
screen1:        DS.L 1
screen2:        DS.L 1
_switch:        DS.W 1

                BSS
                DS.B 256
scr1:           DS.B 32000
scr2:           DS.B 32000

                END
