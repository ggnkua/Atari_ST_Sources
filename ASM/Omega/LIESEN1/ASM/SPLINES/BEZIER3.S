s:              lea     s(pc),a6
                move.w  #2,-(a7)
                pea     -1
                pea     -1
                move.w  #5,-(a7)
                trap    #14
                lea     12(a7),a7


                move.w  #2,-(a7)
                trap    #14
                addq.l  #2,a7
                move.l  d0,_Screen-s(a6)
                movea.l d0,a5

                moveq   #$7F,d0
loop:
                move.w  d0,-(a7)
                lea     _PointsX(pc),a0
                bsr.s   Bezier3
                move.w  d7,-(a7)
                lea     _PointsY(pc),a0
                bsr.s   Bezier3
                move.w  d7,d1
                move.w  (a7)+,d0
                bsr.s   PlotHi

                move.w  (a7)+,d0
                dbra    d0,loop

                clr.w   -(a7)
                trap    #1



PlotHi:         >PART 'Plot HiRez'
* d0=x
* d1=y
* screen address in A5
* destroys a0,d2
                mulu    #80,d1
                move.w  d0,d2
                eori.w  #$0007,d2
                lsr.w   #3,d0
                add.w   d0,d1
                bset    d2,0(a5,d1.w)
                rts
                endpart


Bezier3:        >PART 'Three point's BEZIER'
* A0 address to points (words *$7f) (gives a range of 0-$1ff)
* D0  Roh (0-$7F)

                moveq   #$7F,d1
                sub.l   d0,d1           ; d1=1-roh

                move.l  d1,d7
                mulu    d7,d7
                mulu    (a0),d7
                lsr.l   #7,d7

                move.l  d0,d6
                mulu    d1,d6
                mulu    2(a0),d6
                lsr.l   #7,d6
                add.w   d6,d6

                move.l  d0,d5
                mulu    d5,d5
                mulu    4(a0),d5
                lsr.l   #7,d5

                add.l   d6,d7
                add.l   d5,d7

                lsr.l   #7,d7

                rts
                endpart


_PointsX:       dc.w 0,400,400
_PointsY:       dc.w 0,100,400


_Screen:        ds.l 1
                end
