
;-------------------------------------------------------------------------------
clear_screens:  >PART
                movea.l screen0,A0
                move.l  #32000,D0
                bsr     memclr
                movea.l screen1,A0
                move.l  #32000,D0
                bsr     memclr
                rts
                ENDPART
;-------------------------------------------------------------------------------
; A0
clear_screen:   >PART
                move.l  #32000,D0
                bsr     memclr
                rts
                ENDPART
;-------------------------------------------------------------------------------
; A0-->A1 , D0 length
memcpy:         >PART

                movem.l D0-D6/A0-A3,-(SP)

                divu    #4*32,D0
                bra.s   mcpy0_
mcpy0:
                movem.l (A0)+,D1-D6/A2-A3 ; 8*4 = 32
                movem.l D1-D6/A2-A3,(A1)
                movem.l (A0)+,D1-D6/A2-A3 ; 8*4 = 32
                movem.l D1-D6/A2-A3,1*32(A1)
                movem.l (A0)+,D1-D6/A2-A3 ; 8*4 = 32
                movem.l D1-D6/A2-A3,2*32(A1)
                movem.l (A0)+,D1-D6/A2-A3 ; 8*4 = 32
                movem.l D1-D6/A2-A3,3*32(A1)
                lea     4*32(A1),A1
mcpy0_:         dbra    D0,mcpy0

                clr.w   D0
                swap    D0
                divu    #4,D0
                bra.s   mcpy1_
mcpy1:
                move.l  (A0)+,(A1)+
mcpy1_:         dbra    D0,mcpy1

                swap    D0
                bra.s   mcpy2_
mcpy2:
                move.b  (A0)+,(A1)+
mcpy2_:         dbra    D0,mcpy2

                movem.l (SP)+,D0-D6/A0-A3

                rts
                ENDPART
;-------------------------------------------------------------------------------
memclr_a0_a1:   >PART
                movem.l D0/A0-A1,-(SP)
                move.l  A1,D0           ; end
                sub.l   A0,D0           ; length
                bsr.s   memclr
                movem.l (SP)+,D0/A0-A1
                rts
                ENDPART
;-------------------------------------------------------------------------------
; A0, D0 length
memclr:         >PART

                movem.l D0-D6/A0-A3,-(SP)

                adda.l  D0,A0

                movem.l zero(PC),D1-D6/A1-A3

                divu    #8*36,D0
                bra.s   _mc0
mc0:
                movem.l D1-D6/A1-A3,-(A0) ; 9*4 = 36
                movem.l D1-D6/A1-A3,-(A0) ; 9*4 = 36
                movem.l D1-D6/A1-A3,-(A0) ; 9*4 = 36
                movem.l D1-D6/A1-A3,-(A0) ; 9*4 = 36
                movem.l D1-D6/A1-A3,-(A0) ; 9*4 = 36
                movem.l D1-D6/A1-A3,-(A0) ; 9*4 = 36
                movem.l D1-D6/A1-A3,-(A0) ; 9*4 = 36
                movem.l D1-D6/A1-A3,-(A0) ; 9*4 = 36
_mc0:           dbra    D0,mc0

                clr.w   D0
                swap    D0
                divu    #4,D0
                bra.s   _mcl1
mcl1:
                move.l  D1,-(A0)
_mcl1:          dbra    D0,mcl1

                swap    D0
                bra.s   _mcl2
mcl2:           move.b  D1,-(A0)
_mcl2:          dbra    D0,mcl2

                movem.l (SP)+,D0-D6/A0-A3
                rts
                ENDPART
;-------------------------------------------------------------------------------
black:
zero:           DS.L 16
;-------------------------------------------------------------------------------


