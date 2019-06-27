;*******START OF INITIALIZED DATA
;
 DATA
        ALIGN
;
; DEFINED DATA GOES HERE
;
BBTIMER1:
 DC.L 0
BBMOVEMENT:
 DC.W $FFFE,2,2,$FFFE
 DC.W $FFFE,$FFFE,2,2
BBXINC1:
 DC.W 0
BBYINC1:
 DC.W 0
;  SHIP SHOT VARIABLES

SHOTX:
    DC.W      0,0,0,0,0,0
    DC.W      0,0,0,0,0,0
SHOTTBL:
    DC.W      $0000,$0004,$0004,$0008,$0008,$0008,$0004,$0004 ;X
    DC.W      $0000,$FFFC,$FFFC,$FFF8,$FFF8,$FFF8,$FFFC,$FFFC
    DC.W      $FFF8,$FFF8,$FFFC,$FFFC,$0000,$0004,$0004,$0008 ;Y
    DC.W      $0008,$0008,$0004,$0004,$0000,$FFFC,$FFFC,$FFF8
;
SMASHTMR:
        DC.L    0

        ALIGN
SPFLAGS:
SHIPFLG: DC.B 1  ;SHIP ACTIVE FLAG
BBFLG1:  DC.B 0  ;BALL BLASTER ACTIVE FLAG
FOUNTFLG1: DC.B 0  ;FOUNTAIN ACTIVE FLAG
FOUNTFLG2: DC.B 0  ;FOUNTAIN ACTIVE FLAG
FOUNTFLG3: DC.B 0  ;FOUNTAIN ACTIVE FLAG
FOUNTFLG4: DC.B 0  ;FOUNTAIN ACTIVE FLAG
FOUNTFLG5: DC.B 0  ;FOUNTAIN ACTIVE FLAG
FOUNTFLG6: DC.B 0  ;FOUNTAIN ACTIVE FLAG
FOUNTFLG7: DC.B 0  ;FOUNTAIN ACTIVE FLAG
FOUNTFLG8: DC.B 0  ;FOUNTAIN ACTIVE FLAG
EXPFLG1:        DC.B 0
SHOTFLG1: 
    DC.B      0
SHOTFLG2:
    DC.B      0
SHOTFLG3:
    DC.B      0
SHOTFLG4:
    DC.B      0
SHOTFLG5:
    DC.B      0
SHOTFLG6:
    DC.B      0
MINEFLG1:
        DC.B    0
SMASHFLG1:
        DC.B    0


;                 *****  NOT ACTIVE  *****
CAVEFLG1: DC.B 0  ;CAVEMAN ACTIVE FLAG
THROWFLG1: DC.B 0  ;CAVEMAN THROWING ACTIVE FLAG
ROCKFLG1: DC.B 0  ;ROCK ACTIVE FLAG
RETURNFLG1: DC.B 0  ;CAVEMAN RETURNING ACTIVE FLAG
; SHIP SHOT ACTIVE FLAGS (4) SHOTS

;
        ALIGN
;
;    SPRITE XCORD (PIXELS)                W    0
;    SPRITE YCORD (PIXELS)                W    2
;    SPRITE WIDTH (WORDS)                W    4
;    SPRITE LENGTH (LINES -1)            W    6
;    TOTAL SIZE OF SPRITE IN BYTES            W    8
;    SPRITE ANIMATION SEQUENCE # (0 BASED)        B    10
;    TOTAL # OF ANIMATIONS   B 11
;    BASE ADDRESS OF SPRITE DATA            L    12-15

SPPARM:
;SHIP    (16) SEQ (DIRECTIONS)
SHIPPARM:
        DC.W    80        ;XCORD
        DC.W    $140        ;YCORD
        DC.W    1        ;WIDTH
        DC.W    15        ;SPRITE LENGTH (LINES -1)
        DC.W    128        ;SIZE OF SPRITE (BYTES)
        DC.B    0        ;CURRENT SPRITE ANIMATION SEQUENCE #
        DC.B 16 ;TOTAL ANIMATIONS
        DC.L    SHIP        ;SPRITE DATA BASE ADR

BBPARM1:
        DC.W    0        ;XCORD
        DC.W    0        ;YCORD
        DC.W    1        ;WIDTH
        DC.W    15        ;SPRITE LENGTH (LINES -1)
        DC.W    128        ;SIZE OF SPRITE (BYTES)
        DC.B    0        ;CURRENT SPRITE ANIMATION SEQUENCE #
        DC.B 16 ;TOTAL ANIMATIONS
        DC.L    BALLB       ;SPRITE DATA BASE ADR
FOUNTPARM1:
        DC.W    0        ;XCORD
        DC.W    0        ;YCORD
        DC.W    1        ;WIDTH
        DC.W    1        ;SPRITE LENGTH (LINES -1)
        DC.W    16        ;SIZE OF SPRITE (BYTES)
        DC.B    0        ;CURRENT SPRITE ANIMATION SEQUENCE #
        DC.B 1        ;TOTAL ANIMATIONS
        DC.L    FOUNT1   ;SPRITE DATA BASE ADR

        DC.W    0        ;XCORD
        DC.W    0        ;YCORD
        DC.W    1        ;WIDTH
        DC.W    1        ;SPRITE LENGTH (LINES -1)
        DC.W    16        ;SIZE OF SPRITE (BYTES)
        DC.B    0        ;CURRENT SPRITE ANIMATION SEQUENCE #
        DC.B 1        ;TOTAL ANIMATIONS
        DC.L    FOUNT1   ;SPRITE DATA BASE ADR

        DC.W    0        ;XCORD
        DC.W    0        ;YCORD
        DC.W    1        ;WIDTH
        DC.W    1        ;SPRITE LENGTH (LINES -1)
        DC.W    16        ;SIZE OF SPRITE (BYTES)
        DC.B    0        ;CURRENT SPRITE ANIMATION SEQUENCE #
        DC.B 1        ;TOTAL ANIMATIONS
        DC.L    FOUNT1   ;SPRITE DATA BASE ADR

        DC.W    0        ;XCORD
        DC.W    0        ;YCORD
        DC.W    1        ;WIDTH
        DC.W    1        ;SPRITE LENGTH (LINES -1)
        DC.W    16       ;SIZE OF SPRITE (BYTES)
        DC.B    0        ;CURRENT SPRITE ANIMATION SEQUENCE #
        DC.B 1        ;TOTAL ANIMATIONS
        DC.L    FOUNT1   ;SPRITE DATA BASE ADR

        DC.W    0        ;XCORD
        DC.W    0        ;YCORD
        DC.W    1        ;WIDTH
        DC.W    1        ;SPRITE LENGTH (LINES -1)
        DC.W    16       ;SIZE OF SPRITE (BYTES)
        DC.B    0        ;CURRENT SPRITE ANIMATION SEQUENCE #
        DC.B 1        ;TOTAL ANIMATIONS
        DC.L    FOUNT1   ;SPRITE DATA BASE ADR

        DC.W    0        ;XCORD
        DC.W    0        ;YCORD
        DC.W    1        ;WIDTH
        DC.W    1        ;SPRITE LENGTH (LINES -1)
        DC.W    16       ;SIZE OF SPRITE (BYTES)
        DC.B    0        ;CURRENT SPRITE ANIMATION SEQUENCE #
        DC.B 1        ;TOTAL ANIMATIONS
        DC.L    FOUNT1   ;SPRITE DATA BASE ADR

        DC.W    0        ;XCORD
        DC.W    0        ;YCORD
        DC.W    1        ;WIDTH
        DC.W    1        ;SPRITE LENGTH (LINES -1)
        DC.W    16       ;SIZE OF SPRITE (BYTES)
        DC.B    0        ;CURRENT SPRITE ANIMATION SEQUENCE #
        DC.B 1        ;TOTAL ANIMATIONS
        DC.L    FOUNT1   ;SPRITE DATA BASE ADR

        DC.W    0        ;XCORD
        DC.W    0        ;YCORD
        DC.W    1        ;WIDTH
        DC.W    1        ;SPRITE LENGTH (LINES -1)
        DC.W    16       ;SIZE OF SPRITE (BYTES)
        DC.B    0        ;CURRENT SPRITE ANIMATION SEQUENCE #
        DC.B 1        ;TOTAL ANIMATIONS
        DC.L    FOUNT1   ;SPRITE DATA BASE ADR

EXPLPARM1:
        DC.W    0        ;XCORD
        DC.W    0        ;YCORD
        DC.W    1        ;WIDTH
        DC.W    15       ;SPRITE LENGTH (LINES -1)
        DC.W    128      ;SIZE OF SPRITE (BYTES)
        DC.B    0        ;CURRENT SPRITE ANIMATION SEQUENCE #
        DC.B 5        ;TOTAL ANIMATIONS
        DC.L    EXPL1    ;SPRITE DATA BASE ADR
SHOTPARM:
        DC.W    0        ;XCORD
        DC.W    0        ;YCORD
        DC.W    1        ;WIDTH
        DC.W    2        ;SPRITE LENGTH (LINES -1)
        DC.W    24       ;SIZE OF SPRITE (BYTES)
        DC.B    0        ;CURRENT SPRITE ANIMATION SEQUENCE #
        DC.B 1        ;TOTAL ANIMATIONS
        DC.L    SHOTDAT  ;SPRITE DATA BASE ADR

        DC.W    0        ;XCORD
        DC.W    0        ;YCORD
        DC.W    1        ;WIDTH
        DC.W    2        ;SPRITE LENGTH (LINES -1)
        DC.W    24       ;SIZE OF SPRITE (BYTES)
        DC.B    0        ;CURRENT SPRITE ANIMATION SEQUENCE #
        DC.B 1        ;TOTAL ANIMATIONS
        DC.L    SHOTDAT  ;SPRITE DATA BASE ADR

        DC.W    0        ;XCORD
        DC.W    0        ;YCORD
        DC.W    1        ;WIDTH
        DC.W    2        ;SPRITE LENGTH (LINES -1)
        DC.W    24       ;SIZE OF SPRITE (BYTES)
        DC.B    0        ;CURRENT SPRITE ANIMATION SEQUENCE #
        DC.B 1        ;TOTAL ANIMATIONS
        DC.L    SHOTDAT  ;SPRITE DATA BASE ADR

        DC.W    0        ;XCORD
        DC.W    0        ;YCORD
        DC.W    1        ;WIDTH
        DC.W    2        ;SPRITE LENGTH (LINES -1)
        DC.W    24       ;SIZE OF SPRITE (BYTES)
        DC.B    0        ;CURRENT SPRITE ANIMATION SEQUENCE #
        DC.B 1        ;TOTAL ANIMATIONS
        DC.L    SHOTDAT  ;SPRITE DATA BASE ADR

        DC.W    0        ;XCORD
        DC.W    0        ;YCORD
        DC.W    1        ;WIDTH
        DC.W    2        ;SPRITE LENGTH (LINES -1)
        DC.W    24       ;SIZE OF SPRITE (BYTES)
        DC.B    0        ;CURRENT SPRITE ANIMATION SEQUENCE #
        DC.B 1        ;TOTAL ANIMATIONS
        DC.L    SHOTDAT  ;SPRITE DATA BASE ADR

        DC.W    0        ;XCORD
        DC.W    0        ;YCORD
        DC.W    1        ;WIDTH
        DC.W    2        ;SPRITE LENGTH (LINES -1)
        DC.W    24       ;SIZE OF SPRITE (BYTES)
        DC.B    0        ;CURRENT SPRITE ANIMATION SEQUENCE #
        DC.B 1        ;TOTAL ANIMATIONS
        DC.L    SHOTDAT  ;SPRITE DATA BASE ADR

MINEPARM1:
        DC.W    0        ;XCORD
        DC.W    0        ;YCORD
        DC.W    1        ;WIDTH
        DC.W    15       ;SPRITE LENGTH (LINES -1)
        DC.W    128      ;SIZE OF SPRITE (BYTES)
        DC.B    0        ;CURRENT SPRITE ANIMATION SEQUENCE #
        DC.B    3        ;TOTAL ANIMATIONS
        DC.L    MINEDATA ;SPRITE DATA BASE ADR
SMASHPARM:
        DC.W    0        ;XCORD
        DC.W    0        ;YCORD
        DC.W    1        ;WIDTH
        DC.W    15       ;SPRITE LENGTH (LINES -1)
        DC.W    128      ;SIZE OF SPRITE (BYTES)
        DC.B    0        ;CURRENT SPRITE ANIMATION SEQUENCE #
        DC.B    5        ;TOTAL ANIMATIONS
        DC.L    SMASHDATA    ;SPRITE DATA BASE ADR

 END
 