**********************************************************************
*
* FIREWORK
*
* Background screensaver with firework animation
* This is an example to demonstrate the symbol capabilities of
* the symbol driver and TempleMon. It runs only with TempleMon!
* The animation is a modified reassembly of the EDISON utility.
*
*********************************************************************
* Assembled with EASYRIDER assembler.
*
               OPT Y+,X+,K+,H+

codelen        = 12
datalen        = 20
bsslen         = 28

_hz_200        =  $4BA
XBIOS          =  14
_v_mfp5        =  $114
_v_xbios       =  $B8
_longframe     =  $59E
_v_rez_hz      = -$C
_v_rez_vt      = -$4
GCURX          = -$25A
GCURY          = -$258
DELY           = 4
DELX           = 4

*****************************************

;VARS           =    A6
;LINE           =    A4

;/*** Allgemeine Konstanten ***/
;/* Begrenzung der Bildschirmgroesse */
MAXSCRW        =    2000
MAXSCRH        =    2000
;/* Neue Rakete, falls random( RANDOM1) >= RANDOM2 */
RANDOM1        =    2500
RANDOM2        =    2400

;/*** Animationskonstanten ***/
ATYPE          =    $0000
ALIFETIME      =    $01F4
AX1            =    $03E8
AY1            =    $05DC
AX2            =    $07D0
AY2            =    $09C4
AVX            =    $0BB8
AVY            =    $0DAC

;/*** Berechnete Konstanten ***/
SCRX           =    $0FA0
SCRY           =    $0FA2
SCRW           =    $0FA4
SCRH           =    $0FA6
YSTRETCH       =    $0FA8
ACTIONS        =    $0FAA     * Anzahl Raketen/Explosionen
ROCKETY        =    $0FAC
ROCKETX        =    $0FAE
ROCKETXOFFSR   =    $0FB0
ROCKETVXMAX    =    $0FB2
ROCKETVXOFFSR  =    $0FB4
ROCKETVYMAX    =    $0FB6
ROCKETVYOFFSR  =    $0FB8
RLIFETIME      =    $0FBA
ELIFETIMEMAX   =    $0FBC
ELIFETIMEOFFSR =    $0FBE
EPOWER         =    $0FC0
EGRAVITY       =    $0FC2

*****************************************
TEXT
*****************************************

           BRA.W   fw_init
*****************************************
* void fw_action( int w, int h, int ystretch, int x, int y);
* Initialisiert Feuerwerk; Startet die Animation und startet eine Rakete
* ystretch <=> (pixelw * 32) / pixelh;

fw_action:     
          MOVE.L  A7,A0                   *
          MOVEM.L D3-D7/A2-A6,-(A7)       *

          LEA     fw_globals,A6           *
          MOVE.W  $0004(A0),SCRX(A6)      *
          MOVE.W  $0006(A0),SCRY(A6)      *

          MOVE.W  D2,YSTRETCH(A6)         *

          CMP.W   #MAXSCRW,D0             *
          BCS.B   fw_act1                 *
          MOVE.W  #MAXSCRW,D0             *
fw_act1:  CLR.L   D2                      *
          MOVE.W  D0,D2                   *
          SUBQ.W  #1,D0                   *
          MOVE.W  D0,SCRW(A6)             *

          CMP.W   #MAXSCRH,D1             *
          BCS.B   fw_act2                 *
          MOVE.W  #MAXSCRH,D1             *
fw_act2:  CLR.L   D3                      *
          MOVE.W  D1,D3                   *
          SUBQ.W  #1,D1                   *
          MOVE.W  D1,SCRH(A6)             *

          LSL.W   #5,D1                   *
          MOVE.W  D1,ROCKETY(A6)          * scrh32

          MOVE.W  #$000B,D0               *
          MULU.W  D3,D0                   *
          DIVU.W  #$0190,D0               *
          CMP.W   #$000B,D0               *
          BCS.B   fw_act3                 *
          MOVE.W  #$000B,D0               *
fw_act3:  MOVE.W  D0,EGRAVITY(A6)         *

          MOVE.L  D2,D0                   *
          LSL.W   #5,D0                   *
;         MOVE.W  D0,D1                   *
;         LSR.W   #3,D0                   * D0 = scrw32 * 1/8
;         LSR.W   #1,D1                   * D1 = scrw32 * 4/8
;         SUB.W   D0,D1                   *
;         MOVE.W  D1,ROCKETX(A6)          * scrw32 * 3/8
;         MOVE.W  D1,ROCKETXOFFSR(A6)     * -"-
          LSR.W   #1,D0                   *
          MOVE.W  D0,ROCKETXOFFSR(A6)     * scrw32 * 1/2
          LSR.W   #1,D0                   *
          MOVE.W  D0,ROCKETX(A6)          * scrw32 * 1/4

          MOVE.L  D3,D0                   *
          DIVU.W  #$0023,D0               *
          CMP.W   #$000C,D0               *
          BCS.B   fw_act4                 *
          MOVE.W  #$000C,D0               *
fw_act4:  CMP.W   #$0002,D0               *
          BCC.B   fw_act5                 *
          MOVE.W  #$0002,D0               *
fw_act5:  LSL.W   #5,D0                   *
          MOVE.W  D0,ROCKETVYMAX(A6)      *

          MOVE.W  D0,D1                   *
          LSR.W   #1,D1                   *
          MOVE.W  D1,ROCKETVYOFFSR(A6)    *

          MOVE.L  D3,D1                   * rocketlifetime =
          LSL.W   #5,D1                   *   (scrh32 * 5/6)
          MULU.W  #$0005,D1               *   / rocketvymax
          DIVU.W  #$0006,D1               *
          AND.L   #$0000FFFF,D1           *
          DIVU.W  D0,D1                   *
          MOVE.W  D1,RLIFETIME(A6)        *

          MOVE.L  D2,D0                   *
          LSL.W   #3,D0                   *
          DIVU.W  RLIFETIME(A6),D0        *
          MOVE.W  D0,ROCKETVXMAX(A6)      *

          LSL.W   #1,D0                   *
          MOVE.W  D0,ROCKETVXOFFSR(A6)    *

          MOVE.W  #$0032,ELIFETIMEMAX(A6) *

          MOVE.W  #$001E,ELIFETIMEOFFSR(A6) *

          MOVE.L  D2,D0                   *
          LSL.L   #5,D0                   *
          DIVU.W  #$0258,D0               *
          MOVE.W  D0,EPOWER(A6)           * scrw32/600

          CLR.W   ACTIONS(A6)             * Anzahl Raketen/Explosionen

          MOVE.W  #$00F9,D0               * Geradenspeicher
          MOVE.L  A6,A0                   * komplett loeschen
fw_act6:  CLR.W   (A0)+                   *
          DBF.W   D0,fw_act6              *

          LEA     fw_register,A0
          ADDA.W  #15*4,A0
          MOVE.L  A0,fw_stack

          BSR.W   fw_nexttime             *

          BSR     fw_show2                *

          MOVEM.L (A7)+,D3-D7/A2-A6       *
          RTS                             *

*****************************************
*
* Eigentlicher Funktionsbeginn von fw_show()

fw_show1: MOVE.W  #RANDOM1,D0             *
          BSR.W   fw_random               *
          CMP.W   #RANDOM2,D0             *
          BCS.B   fw_show3                *

fw_show2: BSR.W   fw_rocket               *

fw_show3: MOVE.W  #$00F9,D7               *

          MOVE.L  A6,A4                   *

fw_nextwait:
          TST.B   background
          BNE     fw_show_e
          TST.W   fw_control
          BNE     fw_do_play
fw_show_e:
          MOVE.L  fw_stack,A0
          MOVEM.L D0-D7/A0-A6,-(A0)
          RTS

fw_play:  LEA     fw_register,A0
          MOVEM.L (A0)+,D0-D7/A0-A6
          MOVE.L  A0,fw_stack

fw_do_play:
          MOVE.L  fw_endtime,D0           *
          CMP.L   fw_acttime,D0           *
          BCC     fw_nextwait             *
          BSR     fw_nexttime             *

fw_show4: TST.W   (A4)                    *
          BEQ.B   fw_show7                *

          BSR     fw_drawline             *

          MOVE.W  AX1(A4),AX2(A4)         *
          MOVE.W  AY1(A4),AY2(A4)         *
          TST.W   (A4)                    *
          BMI.B   fw_show5                *

          MOVE.W  AVX(A4),D0              *
          ASR.W   #3,D0                   *
          SUB.W   D0,AVX(A4)              *

          MOVE.W  AVY(A4),D0              *
          ASR.W   #3,D0                   *
          SUB.W   D0,AVY(A4)              *

          MOVE.W  AVY(A4),D0              *
          SUB.W   EGRAVITY(A6),D0         *
          MOVE.W  D0,AVY(A4)              *

fw_show5: MOVE.W  AX1(A4),D0              *
          ADD.W   AVX(A4),D0              *
          MOVE.W  D0,AX1(A4)              *

          MOVE.W  AY1(A4),D0              *
          SUB.W   AVY(A4),D0              *
          MOVE.W  D0,AY1(A4)              *

          BSR     fw_drawline             *

          SUBQ.W  #1,ALIFETIME(A4)        *
          BPL.B   fw_show7                *

          BSR     fw_drawline             *

          CMPI.W  #-$0001,(A4)            *
          BNE.B   fw_show6                *

          BSR.W   fw_explosion            *

          SUBQ.W  #1,ACTIONS(A6)          *

fw_show6: CLR.W   (A4)                    *

fw_show7: ADDQ.L  #2,A4                   *
          DBF.W   D7,fw_show4             *

          BRA     fw_show1

*****************************************
* fw_drawline
* ->A6: globale Variablen  ->A4: Beschreibung der Geraden

fw_drawline:    MOVEM.L D0-D7/A0-A5,-(SP)
                MOVEQ   #0,D0
                MOVE.W  AX1(A4),D0            *
                LSR.W   #5,D0                 *
                BNE     fw_d_x1
                MOVEQ   #1,D0
fw_d_x1:        CMP.W   SCRW(A6),D0           *
                BHI     ~T17BFE               *
                ADD.W   SCRX(A6),D0           *
                MOVE.L  D0,A1

                MOVE.W  AY1(A4),D0            *
                LSR.W   #5,D0                 *
                BNE     fw_d_x2
                MOVEQ   #1,D0
fw_d_x2:        CMP.W   SCRH(A6),D0           *
                BHI     ~T17BFE               *
                ADD.W   SCRY(A6),D0           *
                MOVE.L  D0,A2

                MOVE.W  AX2(A4),D0            *
                LSR.W   #5,D0                 *
                BNE     fw_d_x3
                MOVEQ   #1,D0
fw_d_x3:        CMP.W   SCRW(A6),D0           *
                BHI     ~T17BFE               *
                ADD.W   SCRX(A6),D0           *
                MOVE.L  D0,A3

                MOVE.W  AY2(A4),D0            *
                LSR.W   #5,D0                 *
                BNE     fw_d_x4
                MOVEQ   #1,D0
fw_d_x4:        CMP.W   SCRH(A6),D0           *
                BHI     ~T17BFE               *
                ADD.W   SCRY(A6),D0           *
                MOVE.L  D0,A5

Draw_Line:                                 * Bresenham Line Algorithmus;
                                           * nicht schîn, dafÅr selten und
                                           * relativ schnell implementiert
                MOVE.L  Screen,A0
                MOVE.L  A1,D0              ; dx berechnen
                SUB.L   A3,D0
                BGE.S   li10               ; ist positiv
                NEG.L   D0                 ; positiv machen
li10:           MOVE.L  A2,D1              ; dy berechnen
                SUB.L   A5,D1
                BGE.S   li20               ; ist positiv
                NEG.L   D1                 ; positiv machen
li20:           MOVE.L  D1,D4              ; incr2 = dy
                SUB.L   D0,D4              ;            - dx
                BGT     sort
                MOVE.L  D4,D5              ; d = dy - dx
                ADD.L   D4,D4              ; incr2 << 1
                ADD.L   D1,D5              ; d = dy - dx + dy
                MOVE.L  D1,D3              ; incr1 = dy
                ADD.L   D1,D3              ;            + dy
                MOVE.L  A3,D6              ; x = x2
                CMP.L   A1,D6              ; if (x1 > x2)
                BGE.S   li30               ; Not the case
                MOVE.L  A5,D7              ; y = y2
                MOVE.L  A1,D2              ; xend = x1
                MOVE.L  A2,D0
                MOVEA.L A5,A2
                MOVEA.L D0,A5
                BRA.S   li40               ; branch around next
li30:           MOVE.L  A1,D6              ; x = x1
                MOVE.L  A2,D7              ; y = y2
                MOVE.L  A3,D2              ; xend = x1
li40:           MOVE.L  D6,D0              ; pixel(x,
                MOVE.L  D7,D1              ;         y)
                BSR     pixel              ; do it
                MOVE.L  A2,D1              ; dy berechnen
                SUB.L   A5,D1
                BGE.S   li81               ; ist positiv
                BRA.S   li80               ; use inverted loop

li50:           ADDQ.L  #1,D6              ; x++
                TST.L   D5                 ; if (d < 0)
                BGE.S   li60               ; it isn't
                ADD.L   D3,D5              ; d+= incr1
                BRA.S   li70               ; skip next
li60:           ADDQ.L  #1,D7              ; y++
                ADD.L   D4,D5              ; d += incr2
li70:           MOVE.L  D6,D0              ; pixel(x,
                MOVE.L  D7,D1              ;         y)
                BSR     pixel              ; do it
li80:           CMP.L   D6,D2              ; while (x < xend)
                BGE.S   li50               ; xend >= x
                BRA     ~T17BFE

li51:           ADDQ.L  #1,D6              ; x++
                TST.L   D5                 ; if (d < 0)
                BGE.S   li61               ; it isn't
                ADD.L   D3,D5              ; d+= incr1
                BRA.S   li71               ; skip next
li61:           SUBQ.L  #1,D7              ; y--
                ADD.L   D4,D5              ; d += incr2
li71:           MOVE.L  D6,D0              ; pixel(x,
                MOVE.L  D7,D1              ;         y)
                BSR     pixel              ; do it
li81:           CMP.L   D6,D2              ; while (x < xend)
                BGE.S   li51               ; xend >= x
                BRA     ~T17BFE

sort:           MOVE.L  D1,D4              ; dx und dy vertauschen
                MOVE.L  D0,D1
                MOVE.L  D4,D0
                MOVE.L  A1,D4              ; x1 y1 vertauschen
                MOVEA.L A2,A1
                MOVEA.L D4,A2
                MOVE.L  A3,D4              ; x2 y2 vertauschen
                MOVEA.L A5,A3
                MOVEA.L D4,A5
li25:           MOVE.L  D1,D4              ; incr2 = dy
                SUB.L   D0,D4              ;            - dx
                MOVE.L  D4,D5              ; d = dy - dx
                ADD.L   D4,D4              ; incr2 << 1
                ADD.L   D1,D5              ; d = dy - dx + dy
                MOVE.L  D1,D3              ; incr1 = dy
                ADD.L   D1,D3              ;            + dy
                MOVE.L  A3,D6              ; x = x2
                CMP.L   A1,D6              ; if (x1 > x2)
                BGE.S   li35               ; Not the case
                MOVE.L  A5,D7              ; y = y2
                MOVE.L  A1,D2              ; xend = x1
                MOVE.L  A2,D0
                MOVEA.L A5,A2
                MOVEA.L D0,A5
                BRA.S   li45               ; branch around next
li35:           MOVE.L  A1,D6              ; x = x1
                MOVE.L  A2,D7              ; y = y2
                MOVE.L  A3,D2              ; xend = x1
li45:           MOVE.L  D6,D1              ; pixel(x,
                MOVE.L  D7,D0              ;         y)
                BSR.S   pixel              ; do it
                MOVE.L  A2,D1              ; dy berechnen
                SUB.L   A5,D1
                BGE.S   li86               ; ist positiv
                BRA.S   li85               ; use inverted loop

li55:           ADDQ.L  #1,D6              ; x++
                TST.L   D5                 ; if (d < 0)
                BGE.S   li65               ; it isn't
                ADD.L   D3,D5              ; d+= incr1
                BRA.S   li75               ; skip next
li65:           ADDQ.L  #1,D7              ; y++
                ADD.L   D4,D5              ; d += incr2
li75:           MOVE.L  D6,D1              ; pixel(x,
                MOVE.L  D7,D0              ;         y)
                BSR.S   pixel              ; do it
li85:           CMP.L   D6,D2              ; while (x < xend)
                BGE.S   li55               ; xend >= x
                BRA     ~T17BFE

li56:           ADDQ.L  #1,D6              ; x++
                TST.L   D5                 ; if (d < 0)
                BGE.S   li66               ; it isn't
                ADD.L   D3,D5              ; d+= incr1
                BRA.S   li76               ; skip next
li66:           SUBQ.L  #1,D7              ; y--
                ADD.L   D4,D5              ; d += incr2
li76:           MOVE.L  D6,D1              ; pixel(x,
                MOVE.L  D7,D0              ;         y)
                BSR.S   pixel              ; do it
li86:           CMP.L   D6,D2              ; while (x < xend)
                BGE.S   li56               ; xend >= x


~T17BFE:        MOVEM.L (SP)+,D0-D7/A0-A5
                RTS                             *

pixel:          MOVE.L  D2,-(SP)
                MOVE.L  D1,D2
                LSL.L   #6,D1
                LSL.L   #4,D2
                ADD.L   D2,D1
                TST.B   TT_Hoch
                BNE     pixel_1280
                TST.B   color
                BEQ     pixel_640
pixel_color:    LSL.L   #1,D1           ; 4 Farben Auflîsung 640 x 200
                MOVE.L  D0,D2
                LSR.L   #2,D2
                BCLR    #0,D2
                BCLR    #1,D2
                ADD.L   D2,D1
                ANDI.L  #$F,D0
                MOVEQ   #$F,D2
                SUB.L   D0,D2
                BCLR    #3,D2
                BNE     pixel_col
                ADDQ.L  #1,D1
pixel_col:      BCHG    D2,0(A0,D1.L)
                MOVE.L  (SP)+,D2
                RTS
pixel_1280:     LSL.L   #1,D1           ; Monochrome Auflîsung 1280 x 960
pixel_640:      MOVE.L  D0,D2           ; Monochrome Auflîsung  640 x 400
                LSR.L   #3,D2
pixel_bit:      ADD.L   D2,D1
                ANDI.L  #7,D0
                MOVEQ   #7,D2
                SUB.L   D0,D2
                BCHG    D2,0(A0,D1.L)
                MOVE.L  (SP)+,D2
                RTS

*****************************************
* fw_rocket
* Erzeugt Startpunkt und Bewegungsvektor fuer eine Rakete

fw_rocket:      MOVE.W  ACTIONS(A6),D0          *
                CMP.W   #$0007,D0               *
                BCC.B   fw_rock2                *

                MOVE.W  #$00F9,D0               *
                MOVE.L  A6,A4                   *
fw_rock1:       TST.W   (A4)+                   *
                DBEQ.W  D0,fw_rock1             *
                TST.W   D0                      *
                BMI.B   fw_rock2                *
                SUBQ.L  #2,A4                   *

                MOVE.W  RLIFETIME(A6),ALIFETIME(A4) *

                MOVE.W  ROCKETXOFFSR(A6),D0     *
                BSR.W   fw_random               *
                ADD.W   ROCKETX(A6),D0          *
                MOVE.W  D0,AX1(A4)              *
                MOVE.W  D0,AX2(A4)              *

                MOVE.W  ROCKETY(A6),AY1(A4)     *
                MOVE.W  ROCKETY(A6),AY2(A4)     *

                MOVE.W  ROCKETVXOFFSR(A6),D0    *
                BSR.W   fw_random               *
                MOVE.W  ROCKETVXMAX(A6),AVX(A4) *
                SUB.W   D0,AVX(A4)              *

                MOVE.W  ROCKETVYOFFSR(A6),D0    *
                BSR.W   fw_random               *
                MOVE.W  ROCKETVYMAX(A6),AVY(A4) *
                SUB.W   D0,AVY(A4)              *

                MOVE.W  #$FFFF,(A4)             *

                ADDQ.W  #1,ACTIONS(A6)          *

                BSR.W   fw_drawline             *

fw_rock2:       RTS                             *

*****************************************
* fw_explosion
* Erzeugt Startpunkte und Bewegungsvektoren fuer alle Punkte
* einer Explosion aus dem Endpunkt einer Rakete (in A4).

fw_explosion:   MOVEM.L D3-D6/A3-A4,-(A7)       *

fw_expl_r:      MOVEQ   #$F,D0                  *
                TST.B   TT_Hoch
                BEQ     fw_expl_r1
                MOVEQ   #$D,D0
fw_expl_r1:     BSR.W   fw_random               *
                TST.W   D0                      *
                BNE.B   fw_expl1                *

                MOVEQ   #$1F,D0                 *
                TST.B   TT_Hoch
                BEQ     fw_expl1
                MOVEQ   #$E,D0

fw_expl1:       ADDQ.W  #1,D0                   *
                MULU.W  EPOWER(A6),D0           *
                MOVE.W  D0,D5                   *

                MOVE.W  D0,D6                   *
                MULU.W  YSTRETCH(A6),D6         *
                ASR.L   #5,D6                   *
                NEG.W   D6                      *

                MOVE.W  #$0005,D0               *
                BSR.W   fw_random               *
                ASL.W   #2,D0                   *
                LEA     fw_pictures,A3          *
                MOVE.L  $00(A3,D0.W),A3         *

                MOVE.L  A4,D3                   *

                MOVE.L  A6,A4                   *
                MOVE.W  #$00F9,D4               *
fw_expl2:       TST.B   (A3)                    *
                BNE.B   fw_expl3                *
                TST.B   $0001(A3)               *
                BEQ.B   fw_expl4                *
fw_expl3:       TST.W   (A4)+                   *
                DBEQ.W  D4,fw_expl3             *
                TST.W   D4                      *
                BMI.B   fw_expl4                *
                SUBQ.L  #2,A4                   *

                MOVE.W  #$0001,(A4)             *

                MOVE.W  ELIFETIMEOFFSR(A6),D0   *
                BSR.W   fw_random               *
                MOVE.W  ELIFETIMEMAX(A6),ALIFETIME(A4) *
                SUB.W   D0,ALIFETIME(A4)        *

                MOVE.L  D3,A0                   *
                MOVE.W  AX2(A0),AX1(A4)         *
                MOVE.W  AY2(A0),AY1(A4)         *
                MOVE.W  AX2(A0),AX2(A4)         *
                MOVE.W  AY2(A0),AY2(A4)         *

                MOVE.B  (A3)+,D0                *
                EXT.W   D0                      *
                MULS.W  D5,D0                   *
                ASR.L   #5,D0                   *
                ADD.W   AVX(A0),D0              *
                MOVE.W  D0,AVX(A4)              *

                MOVE.B  (A3)+,D0                *
                EXT.W   D0                      *
                MULS.W  D6,D0                   *
                ASR.L   #5,D0                   *
                ADD.W   AVY(A0),D0              *
                MOVE.W  D0,AVY(A4)              *

                BSR.W   fw_drawline             *

                BRA.B   fw_expl2                *

fw_expl4:       MOVEM.L (A7)+,D3-D6/A3-A4       *
                RTS                             *

*****************************************
* fw_supexec
* Fuehrt die Routine A0 im Supervisormode aus

fw_supexec:     MOVE.L  A0,-(A7)                *
                MOVE.W  #$26,-(A7)              * Supexec
                TRAP    #XBIOS                  *
                ADDQ.L  #6,A7                   *
                RTS                             *

*****************************************
* search_Cookie
* Cookie suchen und in D0 Langwort hinter Cookie liefern

search_Cookie:  MOVEA.L $05A0.W,A0
                TST.L   $05A0.W
                BEQ     search_abort
                TST.L   (A0)
                BEQ     search_abort
search:         CMP.L   (A0),D0
                BEQ     search_ok
                ADDQ.L  #8,A0
                TST.L   (A0)
                BNE.S   search
search_abort:   MOVEQ   #0,D0
                RTS
search_ok:      MOVE.L  4(A0),D0
                RTS

*****************************************
* fw_set
* Initialisiert die Vektoren

fw_set:         MOVE.W  #34,-(SP)               * kbdvbase
                TRAP    #XBIOS
                ADDQ.L  #2,SP
                MOVE.L  D0,_kbdv_base
                MOVE.L  D0,A0
                LEA     32(A0),A0
                MOVE.L  A0,_v_ikbd

                DC.W    $A000
                MOVE.L  A0,_line_a

                LEA     _fw_set(PC),A0          *
                BSR     fw_supexec              *
                MOVE.L  TMon,D0                 * wichtig zum Test auf Abbruch
fw_set_abort:   RTS                             *

*****************************************
* _fw_set
* Supervisorroutine von fw_set(). Setzt die Vektoren um.

_fw_set:        SF      MSTE
                MOVE.L  #'_MCH',D0
                BSR     search_Cookie
                CMPI.L  #$00010010,D0
                BNE     _fw_set_0
                ST      MSTE
_fw_set_0:      SF      TT
                SF      STE
                MOVE.L  #'_VDO',D0              * Videoart untersuchen
                BSR     search_Cookie
                SWAP    D0
                TST.W   D0
                BEQ     _fw_set1
                CMPI.W  #3,D0
                BCC     _fw_set1
                ST      STE
                CMPI.W  #1,D0
                BEQ     _fw_set1
                ST      TT

_fw_set1:       MOVE.L  #'TMon',D0              * TempleMon suchen
                BSR     search_Cookie
                MOVE.L  D0,TMon
                BEQ     _fw_set_abort
                MOVE.L  D0,A3
                MOVEQ   #4,D0
                JSR     (A3)
                MOVE.L  A0,Screen
                MOVE.L  A0,TScreen
                MOVE.L  D1,ScreenSize
                CMPI.L  #32768,D1
                SCC     TT_Hoch
                MOVEQ   #1,D0                   * TempleMon Version erfragen
                JSR     (A3)
                CMPI.W  #$0202,D0               * Version 2.02 oder grîûer?
                BCS     _fw_set_abort           * nein, dann Abbruch!
                

_fw_set2:       MOVE.W  SR,-(A7)                *
                ORI.W   #$0700,SR               *

                ST      fw_in_Timer             ; Timer Interrupt erstmal
                                                ; blockieren
                MOVE.W  #-1,fw_control          *

                MOVE.L  _hz_200.W,D0            *
                MOVE.W  D0,fw_random_val        *
                LSL.L   #1,D0                   *
                MOVE.L  D0,fw_acttime           *

                LEA     fw_mfp5_1(PC),A0        *
                LEA     fw_mfp5(PC),A1          *
                MOVE.L  _v_mfp5.W,(A0)          *
                MOVE.L  A1,_v_mfp5.W            *

                LEA     fw_ikbd(PC),A1          *
                MOVE.L  _v_ikbd,A0
                BSR     _fw_set_XBRA
                MOVE.L  A2,o_ikbd

                LEA     fw_xbios(PC),A1          *
                LEA     _v_xbios.W,A0
                BSR     _fw_set_XBRA
                MOVE.L  A2,o_xbios

                MOVE.W  (A7)+,SR                *

_fw_set_abort:  RTS                             *

_fw_set_XBRA:   MOVEA.L A0,A2
                MOVEA.L (A0),A0
_fw_set_XBRAl:  CMPI.L  #'XBRA',-12(A0)
                BNE     _fw_set_XBRA1
                MOVEA.L A0,A2
                MOVEA.L -4(A0),A0
                BRA     _fw_set_XBRAl
_fw_set_XBRA1:  CMPI.L  #'XBRA',-12(A2)
                BNE     _fw_set_XBRA2
                MOVE.L  -4(A2),-4(A1)
                MOVE.L  A1,-4(A2)
                RTS
_fw_set_XBRA2:  MOVE.L  (A2),-4(A1)
                MOVE.L  A1,(A2)
                RTS


*****************************************
* fw_reset
* Setzt Feuerwerk zurueck

fw_reset:       LEA     _fw_reset(PC),A0        *
                BSR.W   fw_supexec              *
                RTS                             *

*****************************************
* _fw_reset
* Supervisorroutine von fw_reset(). Setzt die Vektoren zurueck.

_fw_reset:      MOVE.W  SR,-(A7)                *
                ORI.W   #$0700,SR               *

                MOVE.L  fw_mfp5_1(PC),_v_mfp5.W *

                MOVE.L  o_ikbd,A0               *
                MOVE.L  fw_ikbd_1(PC),(A0)      *

                MOVE.L  o_xbios,A0              *
                MOVE.L  fw_xbios_1(PC),(A0)     *

                MOVE.W  (A7)+,SR                *
                RTS                             *

*****************************************
* fw_random
* Liefert Zufallzahl <-D0.W im Bereich [0.W ->D0.W[

fw_random:      LEA     fw_random_val,A0        *
                TST.W   (A0)                    *
                BNE.B   fw_rand1                *

                MOVE.W  fw_acttime+2,D1         *
                ASL.L   #8,D1                   *
                OR.W    fw_acttime+2,D1         *
                MOVE.W  D1,(A0)                 *

fw_rand1:       MOVE.W  #$7AB7,D1               *
                MULU.W  (A0),D1                 *
                ADDQ.W  #1,D1                   *
                MOVE.W  D1,(A0)                 *

                MULU.W  D1,D0                   *
                SWAP.W  D0                      *
                RTS                             *

*****************************************
* fw_nexttime

fw_nexttime:    MOVE.L  fw_acttime,D0           *
                ADD.L   fw_timeintervall,D0     *
                MOVE.L  D0,fw_endtime           *
                RTS                             *

*****************************************
* fw_wait

fw_wait:        MOVE.L  fw_endtime,D0           *
fw_wait1:       CMP.L   fw_acttime,D0           *
                BCC.B   fw_wait1                *
                BRA.B   fw_nexttime             *

*****************************************
* fw_tstscreen

fw_tstscreen:   LEA     $FFFF8200.W,A0
                MOVEQ   #0,D0
                MOVEP.W 1(A0),D0
                LSL.L   #8,D0
                MOVE.B  $D(A0),D0
                CMP.L   TScreen,D0         ; TempleMon Bildschirm sichtbar?
                RTS

*****************************************
* fw_setscreen

fw_setscreen:   moveq   #26,D0
                moveq   #-1,D1
                movea.l TMon,A0
                jsr     (A0)
                move.w  D0,D1
                subq.w  #1,D1
                sne     color
                rts

*****************************************
* fw_resetscreen

fw_resetscreen: moveq   #26,D0
                moveq   #1,D1
                movea.l TMon,a0
                jsr     (a0)
                rts

*****************************************
* fw_clearscreen

fw_clearscreen: MOVEM.L D0-D7/A0-A1,-(SP)
                MOVEA.L Screen,A0
                MOVEA.L A0,A1
                ADDA.L  ScreenSize,A1
                MOVEQ   #0,D0
                TST.B   TT
                BEQ     fw_clearscreen2
                MOVE.W  $8262.W,D1
                ANDI.W  #$0700,D1
                CMPI.W  #$0600,D1
                BNE     fw_clearscreen2
                MOVEQ   #-1,D0
fw_clearscreen2:
                MOVE.L  D0,D1
                MOVE.L  D0,D2
                MOVE.L  D0,D3
                MOVE.L  D0,D4
                MOVE.L  D0,D5
                MOVE.L  D0,D6
                MOVE.L  D0,D7
fw_clear_loop:  MOVEM.L D0-D7,-(A1)
                CMPA.L  A0,A1
                BHI.S   fw_clear_loop
                MOVEM.L (SP)+,D0-D7/A0-A1
                RTS

*****************************************
* fw_mfp5  Timer

                DC.L    'XBRA'
                DC.L    'FWJH'
fw_mfp5_1:      DC.L    0
fw_mfp5:        MOVE.L  D0,-(SP)
                MOVE.L  fw_timeincrement,D0
                ADD.L   D0,fw_acttime        ; stÑndiger ZÑhler
                MOVE.L  (SP)+,D0
;                BTST    #3,fw_flags
;                BEQ     fw_mfp5_int3
;                BTST    #5,(SP)
;                BNE     fw_mfp5_end
fw_mfp5_int3:   BTST    #0,fw_flags
                BEQ     fw_mfp5_int0
                BTST    #4,$FFFFFA0B         ; Interrupt Pending RCV Buffer full,
                                             ; ST MFP?
                BNE     fw_mfp5_end
                BTST    #4,$FFFFFA0F         ; Interrupt In Service RCV Buf. full,
                                             ; ST MFP?
                BNE     fw_mfp5_end
fw_mfp5_int0:   TST.B   MSTE
                BNE     fw_mfp5_int1
                TST.B   TT
                BEQ     fw_mfp5_0
fw_mfp5_int1:   BTST.B  #1,fw_flags
                BEQ     fw_mfp5_int2
                BTST    #5,$FFFF8E01         ; SCU: Int. Mask SCC?
                BEQ     fw_mfp5_int2
                BTST    #5,$FFFF8E03         ; SCU: Int. von SCC?
                BNE     fw_mfp5_end
fw_mfp5_int2:   TST.B   TT
                BEQ     fw_mfp5_0
                BTST.B  #2,fw_flags
                BEQ     fw_mfp5_0
                BTST.B  #4,$FFFFFA8B         ; Interrupt Pending RCV Buffer full,
                                             ; TT MFP?
                BNE     fw_mfp5_end
                BTST.B  #4,$FFFFFA8F         ; Interrupt In Service RCV Buf. full,
                                             ; TT MFP?
fw_mfp5_0:      TAS     fw_in_Timer          ; zur Zeit in Timerroutine?
                BNE     fw_mfp5_end          ; ja: dann nix tun
                MOVE.L  SP,save_SP           ; SP sichen
                LEA     new_SP,SP            ; neuen Stapel einrichten
                MOVE.L  A0,-(SP)             ; A0 sichern
                MOVE.L  save_SP,A0           ; alter SP nach A0
                MOVE.W  D0,-(SP)             ; D0 sichern
                MOVE.W  (A0),D0              ; alten SR holen;
                                             ; diese Konstruktion stimmt
                                             ; immer, egal welcher der drei
                                             ; Stacks gerade benutzt wurde
                TST.W   _longframe.W         ; RTE Stackframe aufbauen
                BEQ     fw_mfp5_2
                CLR.W   -(SP)                ; Stackframeword des Default
                                             ; Exeption Stack Frame Formates
fw_mfp5_2:      PEA     fw_mfp5_ret(PC)      ; Pseudoreturnadresse
                                             ; in Stackframe
                BSET    #13,D0               ; S Bit in Pseudo SR setzen
                BCLR    #12,D0               ; M Bit ist immer gelîscht
                BCLR    #14,D0               ; T0 lîschen
                BCLR    #15,D0               ; T1 lîschen
                MOVE.W  D0,-(SP)             ; Pseudo SR in Stackframe
fw_mfp5_end:    MOVE.L  fw_mfp5_1(PC),-(SP)  ; alten MFP5 anspringen
                RTS
fw_mfp5_ret:    MOVE.W  (SP)+,D0             ; D0 wieder herstellen
                TST.B   fw_status            ; was war als letztes los?
                BNE     fw_playing           ; zum aktiven Feuerwerk

                MOVEM.L D0/D1/A0,-(SP)
                MOVEA.L _line_a,A0           ; auf Maus Position in Ecken
                MOVEQ   #0,D1
                MOVE.B  fw_corners,D1
                ANDI.B  #$F,D1
                MOVE.W  GCURX(A0),D0
                BTST    #7,fw_corners
                BEQ     fw_mouse1
                ADD.W   D1,D0
                SUBQ.W  #1,D0
                SUB.W   _v_rez_hz(A0),D0
                BMI     fw_mousey
                BRA     fw_mouse15
fw_mouse1:      CMP.W   D1,D0
                BCC     fw_mousey
fw_mouse15:     MOVE.W  GCURY(A0),D0
                BTST    #6,fw_corners
                BEQ     fw_mouse2
                ADD.W   D1,D0
                SUBQ.W  #1,D0
                SUB.W   _v_rez_vt(A0),D0
                BMI     fw_mousey
                BRA     fw_mouse_plus
fw_mouse2:      CMP.W   D1,D0
                BCS     fw_mouse_plus
fw_mousey:      MOVE.W  GCURX(A0),D0
                BTST    #5,fw_corners
                BEQ     fw_mouse3
                ADD.W   D1,D0
                SUBQ.W  #1,D0
                SUB.W   _v_rez_hz(A0),D0
                BMI     fw_mouse_e
                BRA     fw_mouse35
fw_mouse3:      CMP.W   D1,D0
                BCC     fw_mouse_e
fw_mouse35:     MOVE.W  GCURY(A0),D0
                BTST    #4,fw_corners
                BEQ     fw_mouse4
                ADD.W   D1,D0
                SUBQ.W  #1,D0
                SUB.W   _v_rez_vt(A0),D0
                BMI     fw_mouse_e
                BRA     fw_mouse_min
fw_mouse4:      CMP.W   D1,D0
                BCS     fw_mouse_min
                BRA     fw_mouse_e

                MOVE.W  _v_rez_vt(A0),D0     ; Maus am unteren Ende?
                SUBQ.W  #1,D0
                SUBQ.W  #DELY,D0
                CMP.W   GCURY(A0),D0
                BCC     fw_mouse_e           ; nein, dann nix mehr
                MOVE.W  #DELX,D0
                CMP.W   GCURX(A0),D0         ; Maus am linken Ende?
                BCS     fw_mouse_xmax        ; nein, dann zum Test 'rechts'

fw_mouse_plus:  ST      fw_control
                MOVE.L  #200,D0              ; ja: in einer Sekunde Bildschirm
                CMP.L   fw_time_counter,D0
                BCC     fw_mouse_e
                MOVE.L  D0,fw_time_counter   ; abdunkeln
                BRA     fw_mouse_e

fw_mouse_xmax:  MOVE.W  _v_rez_hz(A0),D0     ; Maus am rechten Ende?
                SUBQ.W  #1,D0
                SUBQ.W  #DELX,D0
                CMP.W   GCURX(A0),D0
                BCC     fw_mouse_e

fw_mouse_min:   ST      ScreenNotOff
                BRA     fw_mouse_ee
fw_mouse_e:     SF      ScreenNotOff
fw_mouse_ee:    MOVEM.L (SP)+,D0/D1/A0


fw_is_off:      TST.B   ScreenNotOff         ; Bildschirm ist auszuschalten?
                BNE     fw_exep_end          ; nein, dann kein Timeout
                SUBQ.L  #1,fw_time_counter   ; Feuerwerk ist aus: Timeout
                BNE     fw_exep_end          ; ZÑhler kontrollieren
fw_timeout:                                  ; TimeoutzÑhler zurÅcksetzen
                MOVE.L  fw_time_counter_max,fw_time_counter
                MOVEM.L D0-D7/A1-A6,-(SP)    ; Registersicherung
                BSR     fw_tstscreen         ; Bildschirmseite aktiv?
                BEQ     fw_abort             ; ja: dann Abbruch
                ST      fw_status            ; Feuerwerk einschalten
                ST      fw_control           ; Kontrollwort fÅr Abbruch
                BSR     fw_clearscreen       ; Bildschirm lîschen
                BSR     fw_setscreen         ; Feuerwerk anzeigen
                MOVE.L  TMon,A0
                MOVEQ   #7,D0
                JSR     (A0)
                MOVE.W  #639,D0              ; Bildschirmbreite
                MOVE.W  #199,D1              ; und Hîhe in Pixel berechnen
                MOVEQ   #16,D2               ; ystretch
                TST.B   color
                BNE     fw_mfp5_action
                MOVE.W  #399,D1
                MOVEQ   #32,D2
                TST.B   TT_Hoch
                BEQ     fw_mfp5_action
                MOVE.W  #1279,D0
                MOVE.W  #959,D1
fw_mfp5_action: CLR.L   -(SP)                ; zwei Null Parameter!
                BSR     fw_action            ; Feuerwerk loslegen
                ADDQ.L  #4,SP                ; die zwei Parameter vom Stack
                                             ; Zeitscheibe initialisieren
                MOVE.W  fw_zeitscheibe_max,fw_zeitscheibe
                TST.W   fw_control
                BEQ     fw_stop_play1
                BRA     fw_abort             ; und fÅr dieses Mal Ende!

;----------------------------      Feuerwerk um ein Objekt weiterschalten
fw_playing:     TST.W   fw_control           ; Inzwischen Abbruch?
                BEQ     fw_stop_play         ; ja: dann Stop
                SUBQ.W  #1,fw_zeitscheibe    ; Zeitscheibe kontrollieren
                BNE     fw_exep_end          ; wir sind noch nicht dran
                                             ; Zeitscheibe neu initialisieren
                MOVE.W  fw_zeitscheibe_max,fw_zeitscheibe
                MOVEM.L D0-D7/A1-A6,-(SP)    ; Arbeitsregister sichern
                BSR     fw_play              ; und ein Objekt weiter malen
                TST.W   fw_control           ; Inzwischen Abbruch?
                BNE     fw_abort             ; nein: normles Ende
                BRA.S   fw_stop_play1        ; ja  : dann jetzt Stop
fw_stop_play:   MOVEM.L D0-D7/A1-A6,-(SP)    ; Arbeitsregister sichern
fw_stop_play1:  ST      fw_control
                BSR     fw_resetscreen       ; Bildschirmanzeige zurÅck
                                             ; TimeoutzÑhler zurÅcksetzen
                MOVE.L  fw_time_counter_max,fw_time_counter
                SF      fw_status            ; Status zurÅcksetzen
fw_abort:       MOVEM.L (SP)+,D0-D7/A1-A6    ; Arbeitsregister restaurieren
fw_exep_end:    MOVE.L  (SP)+,A0             ; A0 restaurieren
                MOVE.L  save_SP,SP           ; Stapelpointer wiederherstellen
                SF      fw_in_Timer          ; Timerroutine freigeben
                RTE                          ; und ab nach Hause

*****************************************
* fw_ikbd Ueberwacht Maus und Tastatur

                DC.L    'XBRA'
                DC.L    'FWJH'
fw_ikbd_1:      DC.L    0
fw_ikbd:        CLR.W   fw_control           ; Feuerwerk Abbruch signalsieren
                MOVE.L  fw_time_counter_max,fw_time_counter
fw_ikbd_old:    MOVE.L  fw_ikbd_1(PC),-(SP)  ; zum alten IKBDSYS
                RTS

*****************************************
* fw_xbios  Ueberwacht XBIOS Funktion 5 SetScreen

                DC.L    'XBRA'
                DC.L    'FWJH'
fw_xbios_1:     DC.L    0
fw_xbios:       MOVE.L  A0,-(SP)
                MOVE.L  USP,A0
                BTST    #5,4(SP)              ; Supervisormodus?
                BEQ     fw_xbios_f
                MOVE.L  SP,A0
                LEA     6+4(SP),A0
                TST.W   _longframe.W
                BEQ     fw_xbios_f
                ADDQ.L  #2,A0
fw_xbios_f:     CMPI.W  #5,(A0)              ; Funktionsnummer SetScreen?
                BNE     OLD_TRAP
                CMPI.L  #-1,2(A0)            ; ohne physkalische Adresse?
                BEQ     OLD_TRAP             ; ja, dann nix mehr
                MOVE.L  2(A0),OldScreen      ; Adresse als die alte merken
                LEA     fw_time_counter,A0   ; TimeoutzÑhler zurÅcksetzen
                MOVE.L  fw_time_counter_max,(A0)
                ST      fw_control           ; Status zurÅcksetzen
                SF      fw_status            ; den Rest macht TOS
OLD_TRAP:       MOVE.L  (SP)+,A0
                MOVE.L  fw_xbios_1(PC),-(SP)
                RTS

Double:         MOVE.L   #'FWJH',D0            ; doppel Installation?
                BSR      search_Cookie
                TST.L    D0
                SNE      fw_control
                RTS

*****************************************
* fw_init  Installation

fw_init:       MOVE.L   4(A7),A5              ; Basepagepointer holen
               LEA      inst_sp,A7            ; eigenen Stapel setzen
               MOVE.L   $2C(A5),-(SP)         ; Envionment freigeben
               MOVE.W   #$49,-(SP)            ; Mfree
               TRAP     #1
               ADDQ.L   #6,SP
               MOVE.L   codelen(A5),D0        ; Speicherplatz berechnen
               ADDI.L   #256,D0               ; base page
               ADD.L    datalen(A5),D0
               ADD.L    bsslen(A5),D0
               MOVE.L   D0,-(SP)              ; New Size
               MOVE.L   A5,-(SP)              ; Basepage
               CLR.W    -(SP)
               MOVE.W   #$4A,-(SP)            ; Mshrink
               TRAP     #1
               LEA      $C(SP),SP
               LEA      Double(PC),A0
               BSR      fw_supexec
               TST.B    fw_control
               BNE      is_installed
               LEA      InstallCookie(PC),A0
               BSR      fw_supexec
               TST.B    fw_control
               BNE      no_mem
               MOVE.W   fw_zeitscheibe_max,D0 ; ZÑhler initialisieren
               MOVE.W   D0,fw_zeitscheibe
               MOVE.L   fw_time_counter_max,D0
               MOVE.L   D0,fw_time_counter
               BSR      fw_set
               BNE      fw_init1
               PEA      Abbruch
               BRA.S    output
               BRA.S    output
no_mem:        PEA      Abbruch2
               BRA.S    output
is_installed:  PEA      Abbruch1
output:        MOVE.W   #9,-(SP)
               TRAP     #1
               ADDQ.L   #6,SP
               MOVE.W   #-1,-(SP)
               MOVE.W   #$4C,-(SP)
               TRAP     #1
               ADDQ.L   #6,SP
               BRA      fw_very_bad           ; hierher darf die CPU nicht
                                              ; kommen

fw_init1:
               PEA      Meldung
               MOVE.W   #9,-(SP)
               TRAP     #1
               ADDQ.L   #6,SP
               SF       fw_status
               SF       fw_in_Timer           ; Timer Routine freigeben
               MOVE.L   codelen(A5),D0        ; Speicherplatz berechnen
               ADDI.L   #256,D0               ; base page
               ADD.L    datalen(A5),D0
               ADD.L    bsslen(A5),D0
               CLR.W    -(SP)                 ; Returncode 0
               MOVE.L   D0,-(SP)
               MOVE.W   #$31,-(SP)            ; Ptermres
               TRAP     #1
               ADDQ.L   #8,SP
fw_lock_timer: TAS      fw_in_Timer           ; Timer Routine blockieren
               BEQ      fw_lock_timer         ; Endlosschleife, falls hier
                                              ; ein Busproblem auftaucht
               BSR      fw_reset              ; Vektoren zurÅck
               PEA      Error                 ; Fehlermeldung ausgeben
               MOVE.W   #9,-(SP)
               TRAP     #1
               ADDQ.L   #6,SP
               MOVE.W   #-1,-(SP)             ; Pterm, Returncode -1
               MOVE.W   #$4C,-(SP)
               TRAP     #1
               ADDQ.L   #4,SP
fw_very_bad:   PEA      Bad
               MOVE.W   #9,-(SP)
               TRAP     #1
               ADDQ.L   #6,SP
               LEA      fw_stop_all(PC),A0
               BRA      fw_supexec
fw_stop_all:   STOP     #$2700                ; bis zum nÑchsten Interrupt
                                              ; schlafen gehen
               MOVE.W   #-1,-(SP)             ; Pterm, nÑchster Versuch
               MOVE.W   #$4C,-(SP)
               TRAP     #1
               ADDQ.L   #4,SP
               BRA.S    fw_stop_all

;*****************************************************************

valsave:  DC.L    0
          DC.L    'XBRA'
          DC.L    'FWJH'
vecsave:  DC.L    0
CookieReset:
          CLR.L   $5A0.W
          MOVE.L  vecsave(PC),$42A.W
          MOVE.L  valsave(PC),$426.W
          JMP     (A6)

;*****************************************************************

InstallCookie:                     ;(* eigenes Cookie installieren *)
          MOVEA.L $5A0.W,A0
          CMPA.L  #0,A0
          BEQ     ICookieEnde
          MOVE.L  #'TMon',D0
          BSR     search_Cookie
          TST.L   D0
          BEQ     ICookieEnde
          MOVEQ   #1,D1
          BRA.S   CoTest
CoLoop:   ADDQ.L  #1,D1
          LEA     8(A0),A0
CoTest:   TST.L   (A0)
          BNE.S   CoLoop
          CMP.L   4(A0),D1
          BGE     CopyCookie
          MOVE.L  4(A0),D1
          CLR.L   8(A0)
          MOVE.L  D1,12(A0)
          LEA     fw_control,A1
          MOVE.L  A1,4(A0)
          MOVE.L  #'FWJH',(A0)+
          BRA     ICookieEnde
NoCookie:
          MOVEQ   #8*8,D0
          BSR     GetMem
          BEQ     ICookieAbort
          MOVE.L  D0,A0
          MOVE.L  A0,$5A0.W
          MOVE.L  #'FWJH',(A0)+
          LEA     fw_control,A1
          MOVE.L  A1,(A0)+
          CLR.L   (A0)+
          MOVE.L  #8,(A0)
          MOVE.L  $426.W,valsave
          MOVE.L  $42A.W,vecsave
          LEA     CookieReset(PC),A0
          MOVE.L  A0,$42A.W
          MOVE.L  #$31415926,$426.W
          BRA     ICookieEnde
CopyCookie:
          MOVE.L  D1,D2
          ASL.L   #3,D2       ; mal 8; pro Eintrag 8 Bytes
          ADD.L   D2,D0
          ADDI.L  #8*8,D0     ; 8 neue EintrÑge fÅr den CookieJar
          BSR     GetMem
          BEQ     ICookieAbort
          MOVE.L  D0,A1       ; A0 zeigt auf MaxCookie
          MOVE.L  $5A0.W,A2
          MOVE.L  A1,$5A0.W
          ADDQ.L  #8,D1
CopyCookieLoop:
          MOVE.L  (A2)+,(A1)+
          MOVE.L  (A2)+,(A1)+
          CMPA.L  A2,A0
          BNE.S   CopyCookieLoop
          LEA     fw_control,A0
          MOVE.L  #'FWJH',(A1)+
          MOVE.L  A0,(A1)+
          CLR.L   (A1)+       ; MaxCookie anlegen
          MOVE.L  D1,(A1)+
InitCookieLoop:
          CMPA.L  D0,A1
          BCC     ICookieEnde
          CLR.L   (A1)+
          BRA.S   InitCookieLoop
ICookieEnde:
          SF      fw_control
          RTS
ICookieAbort:
          ST      fw_control
          RTS

;*****************************************************************

GetMem:   MOVEM.L D1/D2/A0-A2,-(SP)
          MOVE.L  D0,-(SP)
          MOVE.W  #$48,-(SP)
          TRAP    #1
          ADDQ.L  #6,SP
          MOVEM.L (SP)+,D1/D2/A0-A2
          TST.L   D0
          RTS

*****************************************
                DATA
*****************************************

Meldung:        DC.B    13,10,27,'p','             FIREWORK                 ',27,'q'
                DC.B    13,10,'TempleMon screensaver by Johannes Hill'
                DC.B    13,10,'Fireworkanimation  (c)  Kniss Software'
                DC.B    13,10,0
Abbruch:        DC.B    7,13,10,'First install TempleMon!',13,10
                DC.B    'FIREWORK installation aborted.',13,10,0
Abbruch1:       DC.B    7,13,10,'I do NOT install me twice!',13,10
                DC.B    'FIREWORK installation aborted.',13,10,0
Abbruch2:       DC.B    7,13,10,'I need more memory!',13,10
                DC.B    'FIREWORK installation aborted.',13,10,0
Error:          DC.B    7,13,10,'Error during resident termination.',13,10
                DC.B    'FIREWORK installation removed.'
                DC.B    13,10,0
Bad:            DC.B    7,13,10,'Worse error during termination.',13,10
                DC.B    'FIREWORK can NOT be terminated.'
                DC.B    13,10,0
                EVEN
fw_pictures:    DC.L    fw_atari
                DC.L    fw_ball2
                DC.L    fw_ball1
                DC.L    fw_edison
                DC.L    fw_ball3
                DC.L    fw_nopic
fw_atari:       DC.W    $F0DF,$00DF,$10DF,$000F
                DC.W    $00FF,$00EF,$F0CF,$00CF
                DC.W    $10CF,$F0BF,$00BF,$10BF
                DC.W    $E8EF,$E0FF,$D007,$C00F
                DC.W    $18EF,$3007,$20FF,$400F
                DC.W    $F0B1,$00AF,$10AF,$0000
fw_edison:      DC.W    $FCD3,$F7D8,$01D8,$0CDB
                DC.W    $18E0,$20E8,$28F8,$2800
                DC.W    $2808,$2018,$1820,$1028
                DC.W    $0838,$0840,$0848,$F0F8
                DC.W    $F801,$01F8,$0800,$10F8
                DC.W    $F838,$0038,$0050,$F850
                DC.W    $F048,$F040,$F038,$E828
                DC.W    $E020,$D818,$D008,$D000
                DC.W    $D0F8,$D8E8,$E0E0,$ECDB
                DC.W    $D4F0,$24F0,$D410,$2410
                DC.W    $EC30,$0C30,$E800,$0000
fw_ball1:       DC.W    $00F1,$12FD,$0F12,$F315
                DC.W    $E703,$EEE6,$00DE,$26E0
                DC.W    $31FC,$3221,$1C38,$ED39
                DC.W    $CC26,$C401,$D4D7,$06C2
                DC.W    $1FC6,$39D9,$45FB,$4821
                DC.W    $3548,$0B53,$E756,$A92E
                DC.W    $ABF8,$BCDA,$EAB1,$02AD
                DC.W    $27B3,$44D1,$4EEF,$5C3C
                DC.W    $475D,$EF5C,$C953,$B0ED
                DC.W    $B5C0,$D7A4,$F89A,$2E9B
                DC.W    $50B4,$5FDE,$670D,$5F49
                DC.W    $0000
fw_ball2:       DC.W    $02E6,$0F03,$F821,$E708
                DC.W    $EBEA,$23D4,$3C15,$0747
                DC.W    $C939,$CCEF,$01BD,$38C5
                DC.W    $46E8,$4312,$3133,$0A47
                DC.W    $D53A,$AE1C,$B0EF,$D6CC
                DC.W    $07C3,$2ED9,$45FC,$3029
                DC.W    $0838,$9C03,$9CBD,$BFA2
                DC.W    $FBA3,$48BF,$5CE5,$4B10
                DC.W    $253D,$C13B,$C6EB,$DACC
                DC.W    $0AB4,$30AB,$43BB,$4DF2
                DC.W    $5338,$2D57,$D342,$C51A
                DC.W    $DAE8,$FBCB,$25D1,$34FC
                DC.W    $1225,$E026,$0000
fw_ball3:       DC.W    $00DD,$1CFB,$FD2D,$D421
                DC.W    $DBF2,$EFE7,$F307,$2128
                DC.W    $3006,$28E4,$0ABD,$DDB6
                DC.W    $BAD9,$BF11,$E253,$1156
                DC.W    $3E45,$531C,$53F6,$3FCA
                DC.W    $0FA1,$B335,$DAD2,$F9B4
                DC.W    $1DB8,$39D8,$4A14,$2A3D
                DC.W    $F747,$CF3C,$AC0C,$B3E1
                DC.W    $CBBB,$0000
fw_nopic:       DC.W    $0000
fw_random_val:  DC.W    $0000

                     DC.B     'FIREWORK Cookie:'
fw_control:          DC.W     -1
fw_in_Timer:         DC.B     -1
fw_status:           DC.B     0
fw_time_counter_max: DC.L     120*200
fw_zeitscheibe_max:  DC.W     1
background:          DC.B     -1
ScreenNotOff:        DC.B     0
fw_timeintervall:    DC.L     $12
fw_timeincrement:    DC.L     $2
fw_corners:          DC.B     %01111000
fw_flags:            DC.B     15

*****************************************
                     BSS
*****************************************

fw_globals:          DS.B     $0FC4
fw_endtime:          DS.L     1
fw_acttime:          DS.L     1

_kbdv_base:          DS.L     1
_line_a:             DS.L     1
fw_stack:            DS.L     1
fw_register:         DS.L     16
invalidMCH:          DS.B     1
TT_Hoch:             DS.B     1
STE:                 DS.B     1
MSTE:                DS.B     1
TT:                  DS.B     1
color:               DS.B     1
fw_time_counter:     DS.L     1
fw_zeitscheibe:      DS.W     1
Screen:              DS.L     1
TScreen:             DS.L     1
ScreenSize:          DS.L     1
OldScreen:           DS.L     1
TMon:                DS.L     1
_v_ikbd:             DS.L     1
o_ikbd:              DS.L     1
o_xbios:             DS.L     1
                     DS.B     $0800
inst_sp:             DS.B     $0800
new_SP:              DS.L     1
save_SP:             DS.L     1
*****************************************
END
*****************************************
