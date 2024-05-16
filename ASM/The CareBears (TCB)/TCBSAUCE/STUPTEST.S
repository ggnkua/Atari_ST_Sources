
            BRA      MAIN






VSYNH:      MOVEM.L     D0/A0-A1,-(SP)

            MOVE.L      #1,READ
            MOVE.L     #PALETTE1,A0
            MOVE.L     #$FF8240,A1
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
;            MOVE.L      #COLTAB,A6
            MOVEM.L     (SP)+,D0/A0-A1
            RTS

VSYNC:      JSR      VSYNH
            RTE




RETINTS:    MOVE.W      #$2700,SR
            MOVE.L      OLDVS,$70
            MOVE.B      MFPIEA,$FFFA07
            MOVE.B      MFPIEB,$FFFA09
            MOVE.B      MFPTAC,$FFFA19
            MOVE.B      MFPTAD,$FFFA1F
            MOVE.L      OLDTIMA,$134
            MOVE.B      MFPTBD,$FFFA21
            MOVE.B      MFPTBC,$FFFA1B
            MOVE.L      OLDTIMB,$120
            MOVE.W      #$2300,SR
            RTS

HSYN:       MOVE.L      (A6)+,$FF8240
            BCLR        #0,$FFFA0F
            RTE





SETINTS:    MOVE.W      #37,-(SP)
            TRAP        #14
            ADDQ.L      #2,SP
            MOVE.W      #$2700,SR
            MOVE.L      $70,OLDVS
            MOVE.L      #VSYNC,$70
            MOVE.B      $FFFA07,MFPIEA
            MOVE.B      $FFFA09,MFPIEB
            MOVE.B      $FFFA19,MFPTAC
            MOVE.B      $FFFA1F,MFPTAD
            MOVE.L      $134,OLDTIMA
            MOVE.B      $FFFA21,MFPTBD
            MOVE.B      $FFFA1B,MFPTBC
            MOVE.L      $120,OLDTIMB

;            MOVE.B      #0,$FFFA07
;            MOVE.B      #0,$FFFA09

;            MOVE.L      #HSYN,-(SP)
;            MOVE.W      #2,-(SP)
;            MOVE.W      #8,-(SP)
;            MOVE.W      #1,-(SP)
;            MOVE.W      #31,-(SP)
;            TRAP        #14
;            ADDA.L      #12,SP
;            MOVE.L      #COLTAB,A6


            MOVE.W      #$2300,SR
            MOVE.B      $FF8209,D0
OMSI1:      CMP.B       $FF8209,D0
            BEQ         OMSI1
            MOVE.L      #50,D0
OMSI2:      DBRA        D0,OMSI2
            MOVE.W      #$2300,SR
            RTS


SCPOSTAB:   DC.L        0,40960,81920,122880

TAB400:     DC.L        0,400,800,1200

SCRLIN:     MOVE.L      NEWCHARPOS,D0
            MOVE.L      D0,D1
            AND.B       #3,D0
            MOVE.L      D0,WINDNR
            AND.W       #$FFFC,D1
            LSL.L       #1,D1
            LSL.L       #2,D0

            MOVE.L     #SCPOSTAB,A3
            ADD.L       0(A3,D0.W),D1
            MOVE.L      D1,A1
            MOVE.L      D1,WINDPOS
            


            TST.L       WINDNR
            BNE         FORBIS4
            MOVE.L      CHARPOSL,D1
            ADDQ.L      #1,D1
            CMP         #3,D1
            BLT         FORBIT1
            MOVEQ     #0,D1

            MOVE.L      CHARPOSH,D0
            ADDQ        #1,D0
            ADD.L       #1,ROTTP
            MOVE.L      TEXTLEN,D2
            CMP         D2,D0
            BLT         FORBIS3
            MOVEQ       #0,D0
FORBIS3:    MOVE.L      D0,CHARPOSH
FORBIT1:    MOVE.L      D1,CHARPOSL
FORBIS4:

            MOVE.L     CHARPOSH,A0

            ADD.L       #TEXTSCROLL,A0
            MOVEQ       #0,D1
            MOVE.B      (A0),D1
 
            MOVE.L      D1,D7
            ADD.L       D7,D1
            ADD.L       D7,D1

            ADD.L       CHARPOSL,D1

            MULU        #400,D1

            MOVE.L     D1,A0

            ADD.L       #BLOCKS,A1
            ADD.L       #FONT,A0
            MOVE.L      #50,D0
            MOVE.L      WINDNR,D1
            LSL         #2,D1
            MOVE        D1,D7
            MOVE.L      ROTTP,D2
            move.l      #0,d2
            LSL.L       #6,D2
            AND.L       #255,D2
            MOVE.L     A1,A2

           
OMS3:       MOVE.L     #TAB320,A1
            MOVE.L     (A1,D2.W),A1
            ADDA.L      A2,A1
            ADDQ.L      #4,D2
            AND.L       #255,D2

            CLR.L       D1
            MOVE.W      (A0),D1
            LSL.L       D7,D1
            MOVE.W      D1,8(A1)
            MOVE.W      D1,168(A1)
            SWAP        D1
            OR.W        D1,(A1)
            OR.W        D1,160(A1)
            
            CLR.L       D1
            MOVE.W      2(A0),D1
            LSL.L       D7,D1
            MOVE.W      D1,10(A1)
            MOVE.W      D1,170(A1)
            SWAP        D1
            OR.W        D1,2(A1)
            OR.W        D1,162(A1)
            
            CLR.L       D1
            MOVE.W      4(A0),D1
            LSL.L       D7,D1
            MOVE.W      D1,12(A1)
            MOVE.W      D1,172(A1)
            SWAP        D1
            OR.W        D1,4(A1)
            OR.W        D1,164(A1)
                        
            CLR.L       D1
            MOVE.W      6(A0),D1
            LSL.L       D7,D1
            MOVE.W      D1,14(A1)
            MOVE.W      D1,174(A1)
            SWAP        D1
            OR.W        D1,6(A1)
            OR.W        D1,166(A1)
            
            ADDA.L      #8,A0
            DBRA        D0,OMS3

            MOVE.L      #13,D0
            MOVE.L     #TAB320,A0
            MOVEM.L     TOM,D1/D3

OMSL2:
            MOVE.L     (A0,D2.W),A1
            ADDA.L      A2,A1
            ADDQ.L      #4,D2
            AND.L       #255,D2
            MOVEM.L     D1/D3,8(A1)
            MOVEM.L     D1/D3,168(A1)
            DBRA        D0,OMSL2


           

            MOVE.L      WINDPOS,A0
            ADD.L       #BLOCKS,A0
            MOVE.L      A0,SOURCEADD
            MOVE.L     CURRPICADD,A1
            ADDA.L      #23840,A1
            MOVE.L      A1,A2
            MOVE.L      #49,D3
            MOVE.L      #0,D0
            MOVE.L      #0,D2
;            SUB.L       #17,ROTP2
            MOVE.L       #0,A4
            
OMS4:
;            MOVEA.L     #ROTTAB,A0
;            MOVE.L      (A0,D0.W),D1
;            ADD.L       #4,D0
;            ADD.L       ROTP2,D1
;            LSR.L       #3,D1
;            AND.L       #63,D1
;            LSL.L       #2,D1
;            MOVEA.L     #TAB320,A0
            MOVE.L      A4,A0
            ADD.L       #320,A4
;            MOVEA.L     (A0,D1.W),A0
            ADDA.L      SOURCEADD,A0
 

            moveq       #19,d4
            move.l      a0,a2
            move.l      a1,a3
oms7:       move.l      (a2)+,(a3)+
            move.l      (a2)+,(a3)+
            lea         -160(a3),a3
            dbra        d4,oms7


;            MOVEM.L      16(A0),D0-D7/A3
;            MOVEM.L      D0-D7/A3,8(A1)
;            MOVEM.L      52(A0),D0-D7/A3
;            MOVEM.L      D0-D7/A3,44(A1)
;            MOVEM.L      88(A0),D0-D7/A3
;            MOVEM.L      D0-D7/A3,80(A1)
;            MOVEM.L      124(A0),D0-D7/A3
;            MOVEM.L      D0-D7/A3,116(A1)
;            MOVEM.L     (SP)+,D0/D3
           
            ADDA         #160,A1
            DBRA        D3,OMS4

            
            MOVE.L      NEWCHARPOS,D0
            ADDQ        #1,D0
            CMP         #80,D0
            BLT         FORBIS2
            MOVEQ       #0,D0
FORBIS2:    MOVE.L      D0,NEWCHARPOS

            RTS
            


dist2:
        move.l  currpicadd,a1
        lea     19200(a1),a1
        move.l  #shifteddistblocks,a0
        lea     4000(a0),a0
        lea     disttab(pc),a2
        moveq   #24,d1
omd21:  
        add.l   (a2)+,a0
        move.l  a0,a3
        move.l  a1,a4
        lea     -160(a1),a1
        moveq   #19,d0
omd22:  move.l  (a3)+,(a4)+
        move.l  (a3)+,(a4)+
        lea     -160(a4),a4
        dbra    d0,omd22
        dbra    d1,omd21


;
;       add.l   (a2)+,a0
;       movem.l 120(a0),d0-d7/a3-a4
;       movem.l d0-d7/a3-a4,-(a1)
;       movem.l 80(a0),d0-d7/a3-a4
;       movem.l d0-d7/a3-a4,-(a1)
;       movem.l 40(a0),d0-d7/a3-a4
;       movem.l d0-d7/a3-a4,-(a1)
;       movem.l (a0),d0-d7/a3-a4
;       movem.l d0-d7/a3-a4,-(a1)

        rts        



dist:

        move.l  currpicadd,a1
        lea     19200(a1),a1
        move.l  #shifteddistblocks,a0
        lea     1568(a0),a0
        lea     disttab(pc),a2


        move.l  a0,a3
        add.l   (a2),a3
        move.l  a1,a4
        lea     -160(a1),a1
        moveq   #6,d0
        lea     bendtab(pc),a5
        moveq   #0,d2
omd3:   
        add.l   (a5)+,a4
        move.b  d2,(a4)
        move.b  d2,2(a4)
        move.b  d2,4(a4)
        add.l   (a5)+,a4
        move.b  d2,-3(a4)
        move.b  d2,-1(a4)
        move.b  d2,1(a4)
        dbra    d0,omd3





        moveq   #27,d1
omd1:   
        add.l   (a2)+,a0
        move.l  a0,a3
        move.l  a1,a4
        lea     -160(a1),a1
;       moveq   #6,d0
        lea     bendtab(pc),a5
omd2:   
        add.l   (a5)+,a4
        move.b  (a3),(a4)
        move.b  2(a3),2(a4)
        move.b  4(a3),4(a4)
        add.l   (a5)+,a4
        move.b  1(a3),-3(a4)
        move.b  3(a3),-1(a4)
        move.b  5(a3),1(a4)
        add.l   (a5)+,a4
        move.b  8(a3),(a4)
        move.b  10(a3),2(a4)
        move.b  12(a3),4(a4)
        add.l   (a5)+,a4
        move.b  9(a3),-3(a4)
        move.b  11(a3),-1(a4)
        move.b  13(a3),1(a4)
        add.l   (a5)+,a4
        move.b  16(a3),(a4)
        move.b  18(a3),2(a4)
        move.b  20(a3),4(a4)
        add.l   (a5)+,a4
        move.b  17(a3),-3(a4)
        move.b  19(a3),-1(a4)
        move.b  21(a3),1(a4)
        add.l   (a5)+,a4
        move.b  24(a3),(a4)
        move.b  26(a3),2(a4)
        move.b  28(a3),4(a4)
        add.l   (a5)+,a4
        move.b  25(a3),-3(a4)
        move.b  27(a3),-1(a4)
        move.b  29(a3),1(a4)
        add.l   (a5)+,a4
        move.b  32(a3),(a4)
        move.b  34(a3),2(a4)
        move.b  36(a3),4(a4)
        add.l   (a5)+,a4
        move.b  33(a3),-3(a4)
        move.b  35(a3),-1(a4)
        move.b  37(a3),1(a4)
        add.l   (a5)+,a4
        move.b  40(a3),(a4)
        move.b  42(a3),2(a4)
        move.b  44(a3),4(a4)
        add.l   (a5)+,a4
        move.b  41(a3),-3(a4)
        move.b  43(a3),-1(a4)
        move.b  45(a3),1(a4)
        add.l   (a5)+,a4
        move.b  48(a3),(a4)
        move.b  50(a3),2(a4)
        move.b  52(a3),4(a4)
        add.l   (a5)+,a4
        move.b  49(a3),-3(a4)
        move.b  51(a3),-1(a4)
        move.b  53(a3),1(a4)

        lea     56(a3),a3
        dbra    d1,omd1


        add.l   -4(a2),a0
        move.l  a0,a3
        move.l  a1,a4
        lea     -160(a1),a1
        moveq   #6,d0
        lea     bendtab(pc),a5
        moveq   #0,d2
omd4:   
        add.l   (a5)+,a4
        move.b  d2,(a4)
        move.b  d2,2(a4)
        move.b  d2,4(a4)
        add.l   (a5)+,a4
        move.b  d2,-3(a4)
        move.b  d2,-1(a4)
        move.b  d2,1(a4)
        dbra    d0,omd4


        rts        




distyit2:
        lea     bendtab(pc),a0
        lea     80(a0),a0
        moveq   #4,d0
omdiy1: move.l  16(a0),20(a0)
        move.l  12(a0),16(a0)
        move.l  8(a0),12(a0)
        move.l  4(a0),8(a0)
        move.l  (a0),4(a0)
        lea     -20(a0),a0
        dbra    d0,omdiy1
        lea     bendtab(pc),a0

        move.w  distypos(pc),d0
        addq.w  #1,d0
        cmp.w   #50,d0
        blt     forbidiy2
        moveq   #0,d0
forbidiy2:
        move.w  d0,distypos
        lea     disttaby(pc),a1
        lsl.w   #1,d0
        move.w  (a1,d0.w),d0
        mulu    #160,d0
        move.l  d0,(a0)+
        sub.l   d0,(a0)
        add.l   #4,(a0)
        rts


distyit:
        lea     disttaby(pc),a0
        lea     bendtab(pc),a1
        lea     tab160(pc),a2
        move.l  distypos,d0
        add.l   #3,d0
        cmp.l   #128,d0
        blt     forbidi31
        sub.l   #128,d0
forbidi31:
        move.l  d0,distypos
        lsl.l   #1,d0
        move.l  #0,d2
        moveq   #14,d1
omdi31: move.w  (a0,d0.w),d3
        lsr.l   #2,d3
        move.w  d3,d4
        sub.w   d2,d3
        move.w  d4,d2
        add.l   #13,d3
        lsl.l   #2,d3
        move.l  (a2,d3.w),d3
        sub.l   #2076,d3
        move.l  d3,(a1)+
        add.l   #16,d0
        and.l   #255,d0
        dbra    d1,omdi31
        sub.l   #4,bendtab
        rts

distypos:       dc.l    0
disttaby:
        dc.w    12,12,13,13,14,14,15,15
        dc.w    16,16,17,17,18,18,19,19
        dc.w    20,20,20,21,21,21,22,22
        dc.w    22,22,23,23,23,23,23,23
        dc.w    23,23,23,23,23,23,23,22
        dc.w    22,22,22,21,21,21,20,20
        dc.w    20,19,19,18,18,17,17,16
        dc.w    16,15,15,14,14,13,13,12
        dc.w    12,11,10,10, 9, 9, 8, 8
        dc.w     7, 7, 6, 6, 5, 5, 4, 4
        dc.w     4, 3, 3, 2, 2, 2, 1, 1
        dc.w     1, 1, 0, 0, 0, 0, 0, 0
        dc.w     0, 0, 0, 0, 0, 0, 0, 1
        dc.w     1, 1, 1, 2, 2, 2, 3, 3
        dc.w     3, 4, 4, 5, 5, 6, 6, 7
        dc.w     7, 8, 8, 9, 9,10,10,11
        

        dc.w    12,13,14,16,17,18,19,20,21,22
        dc.w    22,23,23,23,23,22,22,21,20,19
        dc.w    18,17,16,14,13,12,10, 9, 7, 6
        dc.w     5, 4, 3, 2, 1, 1, 0, 0, 0, 0
        dc.w     1, 1, 2, 3, 4, 5, 6, 7, 9,10

        dc.w    12,13,14,16,17,18,19,20,21,22
        dc.w    22,23,23,23,23,22,22,21,20,19
        dc.w    18,17,16,14,13,12,10, 9, 7, 6
        dc.w     5, 4, 3, 2, 1, 1, 0, 0, 0, 0
        dc.w     1, 1, 2, 3, 4, 5, 6, 7, 9,10

        dc.w    0,1,2,3,4,5,6,7,8,9
        dc.w    10,11,12,13,14,15,16,17,18,19
        dc.w    20,21,22,23,24,24,23,22,21,20
        dc.w    19,18,17,16,15,14,13,12,11,10
        dc.w    9,8,7,6,5,4,3,2,1,0


bendtab:        dc.l    0
                dc.l    -156
                dc.l    -156
                dc.l    4
                dc.l    -156
                dc.l    4
                dc.l    4
                dc.l    4
                dc.l    164
                dc.l    4
                dc.l    164
                dc.l    164
                dc.l    324
                dc.l    164

                blk.l   200,-156

tab56:  blk.l   200,0


distit:
        lea     disttab(pc),a0
        lea     80(a0),a0
        moveq   #4,d0
omdi1:  move.l  16(a0),20(a0)
        move.l  12(a0),16(a0)
        move.l  8(a0),12(a0)
        move.l  4(a0),8(a0)
        move.l  (a0),4(a0)
        lea     -20(a0),a0
        dbra    d0,omdi1
        lea     disttab(pc),a0
        move.w  distpos(pc),d0
        addq.w  #1,d0
        cmp.w   #50,d0
        blt     forbidi2
        moveq   #0,d0
        addq.w  #1,distsortpos
        and.w   #15,distsortpos
        move.w  distsortpos,d1
        lsl.w   #1,d1
        lea     distsorttab(pc),a1
        move.w  (a1,d1.w),d1
        move.w  d1,distsort
forbidi2:
        move.w  d0,distpos
        add.w   distsort(pc),d0
        lea     disttabx(pc),a1
        lsl.w   #1,d0
        move.w  (a1,d0.w),d0
        mulu    #1568,d0
        sub.l   #56,d0
        move.l  d0,(a0)+
        sub.l   d0,(a0)
        sub.l   #56,(a0)
        rts



disttab:        dc.l    0
                blk.l   30,-56
distpos:        dc.w    0
distsortpos:    dc.w    0
distsorttab:    dc.w    0,0,0,0,50,50,50,50,50,50,50,50,100,100,100,100
distsort:       dc.w    0       

disttabx:

        dc.w     5, 5, 5, 5, 5, 5, 5, 5, 5, 5
        dc.w     5, 5, 5, 5, 5, 5, 5, 5, 5, 5
        dc.w     5, 5, 5, 5, 5, 5, 5, 5, 5, 5
        dc.w     5, 5, 5, 5, 5, 5, 5, 5, 5, 5
        dc.w     5, 5, 5, 5, 5, 5, 5, 5, 5, 5

        dc.w     6, 6, 7, 8, 8, 9, 9,10,10,10
        dc.w    11,11,11,11,11,11,10,10,10, 9
        dc.w     9, 8, 8, 7, 6, 6, 5, 4, 3, 3
        dc.w     2, 2, 1, 1, 1, 0, 0, 0, 0, 0
        dc.w     0, 1, 1, 1, 2, 2, 3, 3, 4, 5

        dc.w     6, 7, 8, 9, 9,10,10,10,10, 9
        dc.w     8, 7, 6, 5, 4, 3, 2, 1, 1, 1
        dc.w     1, 2, 2, 3, 4, 6, 7, 8, 9, 9
        dc.w    10,10,10,10, 9, 8, 7, 6, 5, 4
        dc.w     3, 2, 1, 1, 1, 1, 2, 2, 3, 4
       



;        dc.w     7, 8, 9,10,11,12,13,13,14,14
;        dc.w    15,15,15,15,15,15,14,14,13,13
;        dc.w    12,11,10, 9, 8, 8, 7, 6, 5, 4
;        dc.w     3, 2, 2, 1, 1, 0, 0, 0, 0, 0
;        dc.w     0, 1, 1, 2, 2, 3, 4, 5, 6, 7

;        dc.w     7, 8, 9,10,11,12,12,12,12,11
;        dc.w    10, 9, 8, 6, 5, 4, 3, 2, 2, 2
;        dc.w     2, 3, 4, 5, 6, 7, 8, 9,10,11
;        dc.w    12,12,12,12,11,10, 9, 8, 6, 5
;        dc.w     4, 3, 2, 2, 2, 2, 3, 4, 5, 6

;       dc.w     4, 4, 4, 5, 5, 6, 6, 6, 6, 7
;       dc.w     7, 7, 7, 7, 7, 7, 7, 6, 6, 6
;       dc.w     6, 5, 5, 4, 4, 4, 3, 3, 2, 2
;       dc.w     1, 1, 1, 1, 0, 0, 0, 0, 0, 0
;       dc.w     0, 0, 1, 1, 1, 1, 2, 2, 3, 3


;       dc.w     7, 8,10,11,12,13,13,13,12,12
;       dc.w    11, 9, 8, 6, 5, 3, 2, 2, 1, 1
;       dc.w     1, 2, 3, 4, 6, 7, 8,10,11,12
;       dc.w    13,13,13,12,12,11, 9, 8, 6, 5
;       dc.w     3, 2, 2, 1, 1, 1, 2, 3, 4, 6

;       dc.w     7, 9,11,13,14,15,15,15,14,13
;       dc.w    12,10, 8, 7, 5, 3, 2, 1, 0, 0
;       dc.w     0, 1, 2, 4, 6, 7, 9,11,13,14
;       dc.w    15,15,15,14,13,12,10, 8, 7, 5
;       dc.w     3, 2, 1, 0, 0, 0, 1, 2, 4, 6







shiftdistblocks:
        lea     shifteddistblocks,a1
        moveq   #15,d7
omsdb1: move.l  d7,-(sp)
        moveq   #15,d0
        sub.l   d7,d0
        lea     unshifteddistblock(pc),a0
        moveq   #27,d1
omsdb2:
        moveq   #5,d2
        moveq   #0,d3
        moveq   #0,d4
omsdb3:
        moveq   #0,d5
        move.w  (a0)+,d5
        ror.l   d0,d5
        or.w    d3,d5
        move.w  d5,(a1)+
        swap    d5
        move.w  d5,d3
        swap    d3

        moveq   #0,d5
        move.w  (a0)+,d5
        ror.l   d0,d5
        or.w    d3,d5
        move.w  d5,(a1)+
        swap    d5
        move.w  d5,d3
        swap    d3

        moveq   #0,d5
        move.w  (a0)+,D5
        swap    d5
        lsr.l   d0,d5
        move.w  d5,d6
        swap    d5
        or.w    d4,d5
        move.w  d6,d4
        swap    d4
        move.w  d5,(a1)+

        moveq   #0,d5
        move.w  (a0)+,d5
        swap    d5
        lsr.l   d0,d5
        move.w  d5,d6
        swap    d5
        or.w    d4,d5
        move.w  d6,d4
        swap    d4
        move.w  d5,(a1)+

        dbra    d2,omsdb3
        move.w  d3,(a1)+
        swap    d3
        move.w  d3,(a1)+
        move.w  d4,(a1)+
        swap    d4
        move.w  d4,(a1)+
        dbra    d1,omsdb2
        move.l  (sp)+,d7
        dbra    d7,omsdb1
        rts


;palette:       dc.w    $0000,$0310,$0421,$0532,$0643,$0754,$0407,$0707
;               dc.w    $0007,$0117,$0227,$0337,$0447,$0557,$0667,$0777



LOADFIL:    MOVE.W      #0,-(SP)
            MOVE.L      D0,-(SP)
            MOVE.W      #$3D,-(SP)
            TRAP      #1
            ADDQ.L      #8,SP
            MOVE.W      D0,HANDLE
            MOVE.L      D1,-(SP)
            MOVE.L      D2,-(SP)
            MOVE.W      HANDLE,-(SP)
            MOVE.W      #$3F,-(SP)
            TRAP      #1
            ADD.L      #12,SP
            MOVE.W      HANDLE,-(SP)
            MOVE.W      #$3E,-(SP)
            TRAP      #1
            ADDQ.L      #4,SP
            RTS

LOADFILS:   MOVE.L      #FONTNAME,D0
            MOVE.L      #FONT,D1
            MOVE.L      #84000,D2
            JSR         LOADFIL
            RTS

MAKCOLTAB:  MOVE.L     #COLTAB,A1
            MOVE.L      #73,D0
OMMCT1:     MOVE.L      #0,(A1)+
            DBRA        D0,OMMCT1
            MOVE.L     #TUBCOL,A0
            MOVE.L      #25,D0
OMMCT2:     MOVE.W      (A0)+,(A1)+
            MOVE.W      #0,(A1)+
            DBRA        D0,OMMCT2
            RTS

     
INITVARS:   
;       JSR         MAKCOLTAB
            MOVE.L      #0,D0
            MOVE.L     #TAB320,A0
            MOVE.L     #TAB160,A1
        move.l  #tab56,a2
            MOVE.L      #0,D1
        moveq   #0,d3
            MOVE.L      #199,D2
OMIV1:      MOVE.L      D0,(A0)+
            MOVE.L      D1,(A1)+
        move.l  d3,(a2)+
            ADD.L       #320,D0
            ADD.L       #160,D1
        add.l   #56,d3
            DBRA        D2,OMIV1
            RTS
            

MAIN:       CLR.L       -(SP)
            MOVE.W      #32,-(SP)
            TRAP        #1
            ADDQ.L      #6,SP
            MOVE.L      D0,SAVSTK

            MOVE.W      #0,-(SP)
            MOVE.L      #-1,-(SP)
            MOVE.L      #-1,-(SP)
            MOVE.W      #5,-(SP)
            TRAP        #14
            ADD.L       #12,SP
            MOVE.L     #OLDPAL,A1
            MOVE.L     #$FF8240,A0
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+

            JSR         INITVARS
                bsr     shiftdistblocks

            MOVE.L      #EMD,D0
            SUB.L       #SAMPLIN,D0
            MOVE.L      D0,SAMPLEN

;            JSR         LOADFILS
            MOVE.W      #3,-(SP)
            TRAP        #14
            ADDQ.L      #2,SP
            MOVE.L      D0,CURRPICADD

            JSR         SETINTS


            MOVE.L      #5000,D0

OM1:        MOVE.L      D0,-(SP)
        move.l  #5000,d0
om72:   dbra    d0,om72
        move.w  #$200,$ffff8240
;            JSR         SCRLIN
        bsr     distit
        bsr     distyit
        bsr     dist
        move.w  #$000,$ffff8240

OM15:       CMP.L       #1,READ
            BNE         OM15
            MOVE.L      #0,READ



            MOVE.L      (SP)+,D0
            cmp.b       #185,$fffc02
            beq         ut19
            DBRA        D0,OM1
ut19:       JSR         RETINTS

            MOVE.L     #$FF8240,A1
            MOVE.L     #OLDPAL,A0
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.L      (A0)+,(A1)+
            MOVE.W      #1,-(SP)
            MOVE.L      #-1,-(SP)
            MOVE.L      #-1,-(SP)
            MOVE.W      #5,-(SP)
            TRAP        #14
            ADD.L       #12,SP


            MOVE.L      SAVSTK,-(SP)
            MOVE.W      #32,-(SP)
            TRAP        #1
            ADDQ.L      #6,SP


            RTS

SAVSTK:     Dc.L      1
IGLOGSCR:   Dc.L      1
OLDPAL:     blk.W      16
ROTTP:      Dc.L      1
PICSADD:    Dc.L      1
PIC1ADD:    Dc.L      1
PIC2ADD:    Dc.L      1
PIC3ADD:    Dc.L      1
PIC4ADD:    Dc.L      1
ENDDISSAMP: Dc.L      1
OLDVS:      Dc.L      1
MFPTAD:     Dc.W        1
MFPTAC:     Dc.W        1
MFPTBD:     Dc.W        1
MFPTBC:     Dc.W        1
MFPIEA:     Dc.W        1
MFPIEB:     Dc.W        1
OLDTIMA:    Dc.L        1
OLDTIMB:    Dc.L        1
ROTP2:      Dc.L      1
TARGPICADD: Dc.L      1
TARGPICLIN: Dc.L      1
PICSBAS256: Dc.L      1
TARGETLIN:  Dc.L      1
SOURCELIN:  Dc.L      1
SOURCEADD:  Dc.L      1
TARGETADD:  Dc.L      1
CURRPICADD: Dc.L      1
WINDNR:     Dc.L      1
WINDPOS:    Dc.L      1
CHARPOSH:   Dc.L      1
CHARPOSL:   Dc.L      1
SCRLINOFS:  Dc.L      1
HANDLE:     Dc.L      1
SAMPLEN:    Dc.L      1
COLTAB:     blk.L      100
NEWCHARPOS: Dc.L      1
TAB320:     blk.L      200
TAB160:     blk.L      200
TOM:        blk.L      16
PALETTE1:   
                dc.w    $0000,$0310,$0420,$0430,$0530,$0540,$0650,$0770
                dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0777
;               DC.W      $000,$111,$111,$222,$222,$333,$333,$444,$444
;               DC.W      $555,$555,$666,$666,$777,$777,$777
;       dc.w    $0000,$0760,$0750,$0640,$0530,$0420,$0310,$0003
;       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0777

SAMPDAT:

ROTTAB:     DC.L        0,47,66,81,94,106,117,126,136,144
            DC.L        157,161,169,176,184,191,198,205,212,219
            DC.L        226,233,239,246,253,259,266,273,279,286
            DC.L        293,300,307,314,321,328,336,343,351,359
            DC.L        368,376,386,395,406,418,431,446,465,512

TUBCOL:     DC.W        $001,$002,$003,$004,$005,$006,$007,$117
            DC.W        $227,$337,$447,$557
            DC.W        $557,$447,$337,$227
            DC.W        $117,$007,$006,$005,$004,$003,$002,$001
            DC.W        $000

READ:        Dc.L      1
TEXTLEN:    DC.L      29
TEXTSCROLL: DC.B      42,18,02,17,14,11,11
            DC.B      08,13,06,18,42,00,17,04,42,00,11,22,00,24,18,42,06
            DC.B      17,04,00,19,42,42
            blk.L      200
FONTNAME:   DC.B      "ATAFNTC",0
PICNAME:    DC.B      "PIC.NEO",0
SAMPNAME:   DC.B      "BEATDIS.SPL",0
BPIC:       blk.B      128
PIC:        Dc.L      1
BLOCKS:     EQU       PIC+32000
FONT:       EQU       PIC+195850
SAMPLIN:    EQU       PIC+285850

ENDSAMP:    EQU       $D1000
EMD:        EQU       ENDSAMP
ENDCOMP:    EQU       $100000





unshifteddistblock:
;
;  NEOchrome cut buffer contents (left justified):
;
;    pixels/scanline    = $0060 (bytes/scanline: $0030)
;  # scanlines (height) = $001C
;
;  Hardware color pallet  (color 0 to 15):
;
;      $0000,$0310,$0420,$0430,$0530,$0540,$0650,$0770
;      $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0777
;
;
        dc.w    $FFF0,$FFFF,$FFFF,$0000,$7FFF,$FFFF,$FFFF,$0000
        dc.w    $87F8,$07FF,$87FF,$0000,$1FF8,$FFF8,$FFF8,$0000
        dc.w    $E7F8,$FFFF,$FFFF,$0000,$1FF8,$FFF8,$FFF8,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$FFFF,$FFFE,$FFFF,$0000
        dc.w    $BFFF,$3FFF,$3FFF,$0000,$FFFA,$FFFC,$FFFE,$0000
        dc.w    $FFFF,$FFFF,$FFFF,$0000,$FFF8,$FFFE,$FFFC,$0000
        dc.w    $ECBD,$E3C1,$DFFE,$0000,$FC03,$FC3E,$03FE,$0000
        dc.w    $FCBD,$7BC1,$7FFE,$0000,$FC07,$FC39,$03FE,$0001
        dc.w    $ECBD,$E3C1,$DFFE,$0000,$FC05,$FC3A,$03FC,$0000
        dc.w    $CFBB,$C7C3,$FFFC,$0000,$DAE3,$D81E,$27FE,$0000
        dc.w    $EFBB,$E7C3,$FFFC,$0000,$DAE1,$D81F,$27FE,$0000
        dc.w    $CFBB,$C7C3,$FFFC,$0000,$DAE3,$D81E,$27FC,$0000
        dc.w    $D733,$CFC3,$FFFC,$0000,$C7C7,$C03E,$3FFE,$0000
        dc.w    $D733,$CFC3,$FFFC,$0000,$C7C7,$C03F,$3FFE,$0000
        dc.w    $D733,$CFC3,$FFFC,$0000,$C7C5,$C03E,$3FFE,$0000
        dc.w    $DE7F,$FF8F,$FFF0,$0000,$4597,$027E,$FFFE,$0000
        dc.w    $DE7F,$FF8F,$FFF0,$0000,$4596,$027F,$FFFE,$0000
        dc.w    $DE7F,$FF8F,$FFF0,$0000,$4597,$027E,$FFFE,$0000
        dc.w    $FFCF,$FE0E,$FFF1,$0000,$781F,$07FE,$FFFE,$0000
        dc.w    $FFCF,$FE0E,$FFF1,$0000,$781E,$07FF,$FFFE,$0000
        dc.w    $FFCF,$FE0E,$FFF1,$0000,$781F,$07FE,$FFFE,$0000
        dc.w    $F9DC,$FE5C,$FFA3,$0000,$F97F,$07FE,$FFFE,$0000
        dc.w    $F9DC,$FE5C,$FFA3,$0000,$F97F,$07FE,$FFFE,$0000
        dc.w    $F9DC,$FE5C,$FFA3,$0000,$F979,$07FE,$FFFE,$0000
        dc.w    $FFFF,$8000,$C00F,$0000,$CFFF,$3000,$F000,$0000
        dc.w    $E77F,$F840,$FF80,$0000,$FFFF,$01FE,$01FE,$0000
        dc.w    $E70F,$F870,$FF80,$0000,$F9F1,$07FA,$01FE,$0000
        dc.w    $FFFF,$0008,$801F,$0000,$DFFF,$3000,$F000,$0000
        dc.w    $5CFF,$E080,$FF00,$0000,$FF3F,$01FE,$02FE,$0000
        dc.w    $DC40,$E0BF,$FF7F,$0000,$3BF9,$FFF0,$FCFE,$0000
        dc.w    $001E,$0019,$001F,$0000,$7C00,$F000,$F000,$0000
        dc.w    $53E0,$E380,$FC00,$0000,$03FF,$0200,$0100,$0000
        dc.w    $D39F,$E3FF,$FC7F,$0000,$F3E5,$FFF0,$FFFE,$0000
        dc.w    $0018,$001F,$001F,$0000,$3C00,$F000,$F000,$0000
        dc.w    $66E0,$C680,$F900,$0000,$03FF,$0000,$0200,$0000
        dc.w    $66D0,$C68F,$F97F,$0000,$3F89,$FFFA,$FFF4,$0000
        dc.w    $0018,$001F,$001F,$0000,$FC00,$F000,$F000,$0000
        dc.w    $6D60,$CD00,$F280,$0000,$0000,$0000,$0000,$0000
        dc.w    $6D50,$CD0F,$F2FF,$0000,$FE3F,$FFCC,$FFF0,$0000
        dc.w    $001D,$001F,$001F,$0000,$FC00,$F000,$F000,$0000
        dc.w    $5960,$D800,$E780,$0000,$0000,$0000,$0000,$0000
        dc.w    $5945,$D83F,$E7FF,$0000,$FF6E,$FF80,$FFF0,$0000
        dc.w    $001F,$001F,$001F,$0000,$FC00,$F000,$F000,$0000
        dc.w    $64E0,$E000,$DF80,$0000,$0000,$0000,$0000,$0000
        dc.w    $648F,$E07F,$DFFF,$0000,$F19E,$FE10,$FFE8,$0000
        dc.w    $000F,$001F,$001F,$0000,$FC00,$F000,$F000,$0000
        dc.w    $EE60,$E180,$DF80,$0000,$0000,$0000,$0000,$0000
        dc.w    $6E0F,$E1FF,$DFFF,$0000,$F6E3,$F8E4,$FF1C,$0000
        dc.w    $000F,$001F,$001F,$0000,$CC00,$F000,$F000,$0000
        dc.w    $E840,$C7A0,$FF80,$0000,$03FF,$03FF,$03FF,$0000
        dc.w    $683F,$C7FF,$FFFF,$0000,$8CC5,$F0C2,$FF3C,$0000
        dc.w    $000F,$001F,$001F,$0000,$1C00,$E000,$F000,$0000
        dc.w    $F220,$CFE0,$FF80,$0000,$03FF,$03FE,$03FF,$0000
        dc.w    $727F,$CF80,$FF80,$0000,$FFFB,$01E6,$001C,$0000
        dc.w    $000F,$001F,$001F,$0000,$9C00,$E000,$F000,$0000
        dc.w    $E3F7,$DFCF,$FFBF,$0000,$FF03,$FF3E,$FFFE,$0000
        dc.w    $E3EC,$DF9F,$FFFF,$0000,$03C5,$FCDC,$FF3E,$0000
        dc.w    $0019,$001F,$001F,$0000,$7C00,$8000,$F000,$0000
        dc.w    $CFEF,$FFDF,$FFFF,$0000,$FFE3,$FF1E,$FEFE,$0000
        dc.w    $CFF7,$FFCF,$FFFF,$0000,$FF0D,$F91E,$FEFE,$0000
        dc.w    $001D,$001E,$001F,$0000,$EC00,$0000,$F000,$0000
        dc.w    $EFF5,$DFFE,$FFFF,$0000,$E73B,$0706,$F8FE,$0000
        dc.w    $EFF7,$DFFC,$FFFF,$0000,$CE79,$0E1E,$F1FE,$0000
        dc.w    $0019,$001E,$001F,$0000,$EC00,$2000,$D000,$0000
        dc.w    $FFE9,$FFFE,$FFFF,$0000,$E8E7,$281E,$D7FE,$0000
        dc.w    $FFEB,$FFFC,$FFFF,$0000,$D1C7,$503E,$AFFE,$0000
        dc.w    $001A,$001C,$001F,$0000,$1C00,$1000,$E000,$0000
        dc.w    $FFC2,$FFFC,$FFFF,$0000,$196D,$18BE,$E7FE,$0000
        dc.w    $FFC2,$FFFC,$FFFF,$0000,$196D,$18BE,$E7FE,$0000
        dc.w    $0018,$0018,$001F,$0000,$3C00,$3000,$C000,$0000
        dc.w    $DF18,$FFE0,$FFFF,$0000,$33B9,$307E,$CFFE,$0000
        dc.w    $FF18,$FFE0,$FFFF,$0000,$33B9,$307E,$CFFE,$0000
        dc.w    $0018,$0018,$001F,$0000,$4C00,$4000,$B000,$0000
        dc.w    $3070,$DF80,$FFFF,$0000,$46EF,$4170,$BFFC,$0000
        dc.w    $F070,$FF80,$FFFF,$0000,$46EF,$4170,$BFFC,$0000
        dc.w    $0019,$0019,$001E,$0000,$1C00,$0000,$F000,$0000
        dc.w    $70A1,$0F41,$77FE,$0000,$102F,$03F0,$FFF0,$0000
        dc.w    $E8A1,$FF41,$FFFE,$0000,$102E,$03F0,$FFF0,$0000
        dc.w    $001F,$0010,$0018,$0000,$FC00,$0000,$0000,$0000
        dc.w    $21FF,$1E00,$2000,$0000,$FFFE,$0000,$0000,$0000
        dc.w    $FFFF,$8000,$C000,$0000,$FFFC,$0000,$0000,$0000
        dc.w    $001F,$0000,$0010,$0000,$FC00,$0000,$0000,$0000
        dc.w    $03FF,$0400,$0000,$0000,$FFF0,$0000,$0000,$0000
        dc.w    $FFFF,$0000,$8000,$0000,$FFF0,$0000,$0000,$0000


shifteddistblocks:      dc.l    0

