 ; WWM SCROLLING SCREEN DRIVER
DRAWSCREEN:             ; FILL SCREEN BUFFER WITH GRAPHICS FROM
                        ; THE CHARACTER MAP.
                        ; PARAMETERS    A1 - SCREENBASE
                        ;               WINDX & WINDY IN PIXELS
        LEA     MAP,A0  ; MAP BASE IN A0

        MOVE    WINDX,D0 ; WINDX/16*2 = MAPX IN WORDS
        AND     #$FFF0,D0
        LSR     #3,D0
        ADD     D0,A0   ; MAP BASE + MAPX IN WORDS

        MOVE    WINDY,D0 ; WINDY/16*2*MAPW = MAPY AS OFFSET
        AND     #$FFF0,D0       ; WINDY /16*16*5
        MULU    #5,D0           ; WINDY IN WORDS
        ADD.L   D0,A0           ; A0 IS NOW CURRENT MAP POINTER

        LEA     CHARBASE,A2     ; A2 IS POINTER TO CHARACTER SET

        MOVE    #(WINDH+1)-1,D4 ; LOOP WINDH+1 CHARACTER LINES
NEXTROW:
        MOVE    #(WINDW+1)-1,D3 ; CHARACTERS PER LINE
NEXTCOL:
        CLR.L   D0
        MOVE    (A0)+,D0        ; FETCH CHARACTER #
        LSL.L   #7,D0           ; AND MULT BY 128 (CHARLEN IN BYTES)
        CLR     D1
        MOVE    #16-1,D2        ; 16 LINES PER CHR
DRAWCHR:
        MOVE.L  0(A2,D0.L),0(A1,D1.W) ; COPY 1 LINE IN TOP AREA
        MOVE.L  4(A2,D0.L),4(A1,D1.W)

        ADD.L   #8,D0           ; NEXT CHR LINE
        ADD     #(WINDW+1)*8,D1 ; NEXT SCREEN LINE
        DBRA    D2,DRAWCHR

        ADD.L   #8,A1           ; NEXT CHR TO THE RIGHT ON THE SCREEN
        DBRA    D3,NEXTCOL

        ADD.L   #(MAPW-(WINDW+1))*2,A0
        ADD.L   #((WINDW+1)*8*15),A1    ; NEXT ROW
        DBRA    D4,NEXTROW

;                       ***** SPRITE DRAW GOES HERE *****
        SUB.L   #((WINDW+1)*8)*((WINDH+1)*16),A1         ; FIX SCR PTR

        MOVE    #NUMSP-1,D7
DRAWALLSP:                     ; DRAW ALL THE SPRITES
        MOVE    D7,-(SP)
        CLR.L   D0
        MOVE    D7,D0
        JSR     DRAWSP
        MOVE    (SP)+,D7
        DBRA    D7,DRAWALLSP

        MOVE.B  WINDY+1,D0
        AND     #$F,D0          ; GET VERT ROT VAL
        MULU    #8*(WINDW+1),D0 ; * LINEW
        ADD     D0,A1

        MOVE    WINDX,D0        ; SET HSCROLL SHADOW
        AND     #$F,D0

        EOR.B   #1,SCRFLIP      ; FLAG SCREEN FLIP
        MOVE    #$2500,SR       ; KILL VBLS
        MOVE.B  D0,SHSCROLL     ; JAM SHADOWS
        MOVE.L  A1,SCREENA      ; AND DISP AT NEXT VBL
        MOVE    #$2300,SR       ; RESTORE VBLS
        RTS
 