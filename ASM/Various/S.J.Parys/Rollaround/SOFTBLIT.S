;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;PROCEDURENAME:  BCPYBLK
;DESCRIPTION:    COPIES A BLOCK OF DATA TO THE SCREEN
;AUTHOR:         ;!C YANKS
;
;MODIFIED:       COL 'THE BUTCHERER' BELL
;DATE:           11 MARCH 1988
;MODIFICATION:   CONVERTED FOR ST
;
;ENTER WITH:     A1 POINTING TO BLOCK OF DATA
;
;EXIT WITH:
;
;CORRUPTS:       D1 D2 D3 D5 A0 A1 A2 A3 
;
;SPECIAL NOTE:  THE DATA USED MUST BE MADE BY RUSS'S CAPTURE ROUTINE
;BECAUSE IT ALSO HOLDS OFFSET INTO SCREEN MEMORY,HEIGHT,WIDTH(WORDS)
;
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        XDEF    BCPYBLK

BCPYBLK
        MOVEQ.L #0,D0
        MOVEQ.L #0,D1
        MOVEQ.L #0,D2
        MOVE.W  (A1)+,A0                ;offset into screen memory
        ADD.L   SCRADR,A0               ;address of top left corner
        MOVE.B  (A1)+,D0                ;height
        SUBQ.W  #1,D0                   ;-1 for DBRA
        MOVE.B  (A1)+,D1                ;width in words
        SUBQ.W  #1,D1                   ;-1 for DBRA
        BEQ.S   DO_1_SPECIAL            ;

        CMP.W   #7,D1                   ;
        BEQ.S   DO_8_SPECIAL            ;

        CMP.W   #15,D1                  ;
        BEQ.S   DO_16_SPECIAL           ;

        CMP.W   #23,D1                  ;
        BEQ.S   DO_48_SPECIAL           ;

BLP0
        MOVE.L  A0,A2
        MOVE.W  D1,D2
BLP     
        MOVE.W  (A1)+,(A2)+
        DBRA    D2,BLP
        LEA     160(A0),A0
        DBRA    D0,BLP0
        RTS

DO_1_SPECIAL
        MOVE.W  (A1)+,(A0)
        LEA     160(A0),A0
        DBRA    D0,DO_1_SPECIAL
        RTS

DO_8_SPECIAL
        MOVEM.L (A1)+,D1/D2/D3/D4
        MOVEM.L D1/D2/D3/D4,(A0)
        LEA     160(A0),A0
        DBRA    D0,DO_8_SPECIAL
        RTS

DO_16_SPECIAL
        MOVEM.L (A1)+,D1/D2/D3/D4/D5/D6/D7/A2
        MOVEM.L D1/D2/D3/D4/D5/D6/D7/A2,(A0)
        LEA     160(A0),A0
        DBRA    D0,DO_16_SPECIAL
        RTS

DO_48_SPECIAL
        MOVEM.L (A1)+,D1/D2/D3/D4/D5/D6/D7/A2/A3/A4/A5/A6
        MOVEM.L D1/D2/D3/D4/D5/D6/D7/A2/A3/A4/A5/A6,(A0)
        LEA     160(A0),A0
        DBRA    D0,DO_48_SPECIAL
        RTS


