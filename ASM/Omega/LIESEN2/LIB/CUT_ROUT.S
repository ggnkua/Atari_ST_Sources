                opt P+
                lea     Cut(PC),A0
                lea     _s+128(PC),A1
                move.l  A1,2(A0)            ; Source
                lea     _d(PC),A1
                move.l  A1,6(A0)            ; Dest
                move.w  #3,10(A0)           ; Width
                move.w  #39,12(A0)          ; Hight
                move.w  #1,14(A0)           ; BitPlanes
                move.w  #30,16(A0)          ; Number of cells

                jsr     (A0)
                lea     Cut(PC),A0
                movea.l 26(A0),A1
                lea     _d(PC),A0
                illegal

                movea.l A0,A6
                move.w  #2,-(A7)
                trap    #14
                addq.l  #2,A7
                movea.l D0,A5

                move.w  #399,D0
.draw:          move.l  (A6)+,(A5)+
                move.w  (A6)+,(A5)+
                lea     80-6(A5),A5
                dbra    D0,.draw
                illegal

Cut:            >PART 'CutCell Rout'
                bra.s   .Start
*************************************************************************
_Source:        ds.l 1                      ; 2  Addr to Picture
_Dest:          ds.l 1                      ; 6  Addr to destenation buffert
_Width:         ds.w 1                      ; 10 Width in words
_Hight:         ds.w 1                      ; 12 Hight of a cell
_BitPlanes:     ds.w 1                      ; 14 Bitplanes to include, bit 0-3
_NrCells:       ds.w 1                      ; 16 Nr of cells

_CellsX:        ds.w 1                      ; 18 - Cells on one line -1
_Width2:        ds.w 1                      ; 20 - Width -1
_Hight2:        ds.w 1                      ; 22 - Hight -1
_BytesX:        ds.w 1                      ; 24 - Cell Width in Screen Bytes
_EndBuf:        ds.l 1                      ; 26 - Last address of dest.
*************************************************************************
.Start:         movem.l D0-A6,-(A7)
                lea     Cut(PC),A6
                move.w  _Width(PC),D7
                subq.w  #1,D7
                move.w  D7,_Width2-Cut(A6)
                move.w  _Hight(PC),D7
                subq.w  #1,D7
                move.w  D7,_Hight2-Cut(A6)

                moveq   #20,D7
                divu    _Width(PC),D7
                subq.w  #1,D7
                move.w  D7,_CellsX-Cut(A6)

                move.w  _Width(PC),D7
                lsl.w   #3,D7
                move.w  D7,_BytesX-Cut(A6)

                movea.l _Dest(PC),A0
                movea.l _Source(PC),A1

                move.w  _NrCells(PC),D7
                subq.w  #1,D7
                bmi.s   .Cute

.YLoop:         movea.l A1,A2
                move.w  _Hight(PC),D6
                mulu    #160,D6
                adda.w  D6,A1
                move.w  _CellsX(PC),D6
.XLoop:
                move.w  _BitPlanes(PC),D5
                move.w  _Hight2(PC),D4
                movea.l A2,A3
                adda.w  _BytesX(PC),A2
.CellYLoop:     movea.l A3,A4
                lea     160(A3),A3
                move.w  _Width2(PC),D3
.CellXLoop:     btst    #0,D5
                beq.s   .NotBP0
                move.w  (A4),(A0)+
*                not.w   (A4)
.NotBP0:        btst    #1,D5
                beq.s   .NotBP1
                move.w  2(A4),(A0)+
*                not.w   2(A4)
.NotBP1:        btst    #2,D5
                beq.s   .NotBP2
                move.w  4(A4),(A0)+
*                not.w   4(A4)
.NotBP2:        btst    #3,D5
                beq.s   .NotBP3
                move.w  6(A4),(A0)+
*                not.w   6(A4)
.NotBP3:        addq.l  #8,A4
                dbra    D3,.CellXLoop
                dbra    D4,.CellYLoop

                subq.w  #1,D7
                bmi.s   .Cute
                dbra    D6,.XLoop
                bra.s   .YLoop

.Cute:          move.l  A0,_EndBuf-Cut(A6)
                movem.l (A7)+,D0-A6
                rts
                endpart


_s:             ibytes 'FONT1.NEO'
_d:             ds.b 32*1024
                end
