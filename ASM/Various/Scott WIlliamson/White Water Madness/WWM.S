; ********************************************************************
; WHITE WATER MADNESS   WIP                             7-27-89
; ********************************************************************

; ********************************************************************
;                       MASTER EQUATES
; ********************************************************************
;                       ***** RIVER EQUATES *****
MAPW    = 40            ; MAP WIDTH IN CHRS
MAPL    = 132           ; MAP LENGTH
WINDW   = 20            ; SCREEN WINDOW WIDTH IN CHRS
WINDH   = 10            ; SCREEN WINDOW HEIGHT
RAPIDSP = 2             ; RAPIDS SPEED
IMPACT  = 4             ; KICKBACK ON SHIP WHEN HITING SHORE
NUMSP   = 19            ; # OF SPRITES
HBUF    = 2             ; HORIZONTAL BUFFER SIZE FOR SPRITE OVER RUN
VBUF    = 2             ; VERTICAL BUFFER SIZE

;                       ***** HARDWARE EQUATES *****
VBASEHI = $FF8201       ; VIDEO BASE REG
VBASEMI = $FF8203
VBASELO = $FF820D
VCTRHI  = $FF8205       ; VIDEO COUNTER
VCTRMI  = $FF8207
VCTRLO  = $FF8209
WRAP    = $FF820F       ; LINE WRAP
HSCROLL = $FF8265       ; HSCROLL
RES     = $FF8260       ; RESOLUTION
HPALETTE =$FF8240       ; PALETTE HARDWARE REG
                        ; MFP68901
IERA    = $FFFA07       ; INTEREUPT ENABLE REG A
IERB    = $FFFA09       ; INTEREUPT ENABLE REG B
IPRA    = $FFFA0B       ; INTERUPT PENDING REG A
IPRB    = $FFFA0D       ; INTERUPT PENDING REG B
IMRA    = $FFFA13       ; INTEREUPT MASK REG A
IMRB    = $FFFA15       ; INTEREUPT MASK REG B
RANDOM  = $FFFA23       ; TIMER C DATA REG
VR      = $FFFA17       ; VECTOR GENERATION REG
ACIACTL = $FFFC00       ; KEYBOARD ACIA
ACIADAT = $FFFC02
;                       ***** SPRITE EQUATES *****
;
XCORD   EQU 0          ;X COORDINATE
YCORD   EQU 2          ;Y COORDINATE
SPWIDTH EQU 4          ;WIDTH
SPLENGTH EQU 6         ;LENGTH -1
SPSIZE  EQU 8          ;SIZE IN BYTES
ANIMSEQ EQU 10         ;CURRENT ANIMATION #
ANIMNUM EQU 11         ;TOTAL # OF ANIMATIONS
SPADR   EQU 12         ;SPRITE DATA ADDRESS

;                       ***** SCORE BOX EQUATES *****
ENERGYA  = 34*160+11*8  ; SCREN (&COLOR) ADRESS OFFSETS TO EACH FIELD
SCOREA   = 25*160+4*8
LIFEA    = 22*160+11*8
STUNSA   = 10*160+11*8

;                       ***** DIGITIZED SOUND EQUATES *****
SNDDMAC =       $FF8900 ; SOUND DMA CONTROLL
FBASEHI =       $FF8902 ; FRAME BASE
FBASEMI =       $FF8904
FBASELO =       $FF8906
FCNTHI  =       $FF8908 ; FRAME ADRESS COUNTER
FCNTMI  =       $FF890A
FCNTLO  =       $FF890C
FENDHI  =       $FF890E ; FRAME END
FENDMI  =       $FF8910
FENDLO  =       $FF8912
SNDMODE =       $FF8920
MICRODATA =     $FF8922 ; MICROWIRE? INTERFACE DATA REG
MICROMASK =     $FF8924 ; MICROWIRE? INTERFACE MASK REG

; ********************************************************************
;                       DATA SECTION
; ********************************************************************
  DATA
;                       ***** TITLE SCREEN DATA *****
        ALIGN
EOREYES IBYTES  'D:\ASSEMPRO\WWM\EOR_EYES.IMG'
PICTURE IBYTES  'D:\ARTPROGS\DEGAS\PICTURES\TITL2WWM.PC1'
        ALIGN
;                       ***** RIVER DATA *****
MAP:                    ; RIVER MAP
        IBYTES 'D:\ASSEMPRO\WWM\MAP2.CHR'
        ALIGN
CHARBASE:               ; CHARACTERS
        IBYTES 'D:\ASSEMPRO\WWM\CHR2.CHR'
        ALIGN
MAP_PALETTE:
        IBYTES  'D:\ASSEMPRO\WWM\CHARACTR.PAL',32

;                       ***** SPRITE DATA *****

        INCLUDE 'D:\ASSEMPRO\WWM\SPDATA.S' ; PARAMETER TABLES
        INCLUDE 'D:\ASSEMPRO\WWM\SHIPDAT.S' ; SHIP DATA
        INCLUDE 'D:\ASSEMPRO\WWM\BALLB.S' ; BALLBUSTER DATA

;                       ***** SCORE BOX DATA *****
        ALIGN
DISPDGTS:
  IBYTES 'D:\ASSEMPRO\WWM\DIGITS.B'
        ALIGN
DISPBAR:
  IBYTES 'D:\ASSEMPRO\WWM\BAR.B'
        ALIGN
SCORE_PALETTE:
        IBYTES  'D:\ASSEMPRO\WWM\SCORE.PAL'
        DC.L    0,0     ; TO KILL JITTER
        ALIGN
SCOREBOXIMG:
        IBYTES  'D:\ASSEMPRO\WWM\WWMSCORE.IMG'
ONE:
  DC.B 0,0,0,0,1

;                       ***** DIGITIZED SOUND DATA *****
        ALIGN.W
EXPLO   IBYTES 'D:\REPLAY\SAMPLES\EXPLO12.SPL'
EXPLOEND:
TITLESONG:
        IBYTES  'D:\REPLAY\SAMPLES\WWMSTE.SPL',1024
TITLEEND:
        ALIGN.W

; ********************************************************************
;              BLOCK STORAGE SECTION - UNINITIALIZED DATA
; ********************************************************************
  BSS
;                       ***** TITLE SCREEN BSS *****
        ALIGN
BRIGHTNESS:             ; BRIGHTNESS FOR FADERS
        DS.W 1
        DS.B    $400    ; 1 K PROGRAM STACK
STACK:
        ALIGN
;                       ***** RIVER BLOCK STORAGE *****
SCREEN1BASE:
        DS.B    (WINDW+1+(HBUF*2))*8*(VBUF*16) ; UPPER SPRITE BUFFER
SCREEN1:
        DS.B    ((WINDW+1+(HBUF*2))*8)*((WINDH+1)*16)
SCREEN2BASE:
        DS.B    (WINDW+1+(HBUF*2))*8*(VBUF*16) ; MIDDLE (SHARED) SPRITE BUFFER
SCREEN2:
        DS.B    ((WINDW+1+(HBUF*2))*8)*((WINDH+1)*16)
SCREENBOT:
        DS.B    (WINDW+1+(HBUF*2))*8*(VBUF*16) ; LOWER SPRITE BUFFER
RIVERPAL DS.W   16      ; RIVER PALETTE
SCRFLIP DS.B    1       ; SCREEN FLIP FLAG              2 BYTES TO
SHSCROLL DS.B   1       ; HSCROLL SHADOW            MAINTAIN ALIGNMENT

SCREENA DS.L    1       ; SCREEN ADDRESS FOR VBL REFRESH
WINDX   DS.W    1       ; WINDOW X IN PIXELS IN MAP
WINDY:  DS.W    1       ; WINDOW Y IN PIXELS

;                       ***** SCORE BOX BLOCK STORAGE *****
SCOREBOXA DS.L 1        ; SCREEN ADRESS POINTER
SCORE    DS.L 2         ; VARIABEL AREAS
ENERGY   DS.W 1
LIFE     DS.W 1
STUNS    DS.W 1
NVBLS    DS.L 1         ; VERTICAL BLANK COUNT
STIMER  DS.L    1       ; MAINLINE LOOP COUNT
RTIMING DS.B    1       ; RIVER TIMING REG
SCOREY  DS.B    1       ; Y OF SCORE BOX
        DS.B    1       ; TO MAINTAIN ALIGNMENT
SBHI    DS.B    1       ; SCORE BOX ADRESS
SBMI    DS.B    1
SBLO    DS.B    1

;                       ***** SPRITE HANDLER BSS *****
SHIPX   DS.W    1       ; SHIP COORDS
SHIPY   DS.W    1
SHIPVX  DS.W    1       ; ship velocity
SHIPVY  DS.W    1
SHIPDIR DS.W    1       ; SHIP DIRECTION

; ********************************************************************
;                       CODE SECTION
; ********************************************************************
  text
  align
; ********************************************************************
;              SYSTEM INITIALIZATION   (EXECUTED ONCE)
; ********************************************************************
;                       ***** INITIALIZATION *****
        MOVE.L  4(SP),A0        ; SIZE UP TPA
        MOVE.L  $C(A0),D0       ; PRG LEN
        ADD.L   $14(A0),D0      ; DATA LEN
        ADD.L   $1C(A0),D0      ; BSS LEN
        ADD.L   #$100,D0        ; BASEPAGE LEN
        LEA     STACK,SP        ; LOAD OUR OWN STACK
        MOVE.L  D0,-(SP)        ; LEN
        MOVE.L  A0,-(SP)        ; BASEPAGE
        CLR     -(SP)
        MOVE    #$4A,-(SP)
        TRAP    #1
        ADD.L   #12,SP
        CLR.L   -(SP)           ; SUPER
        MOVE    #$20,-(SP)
        TRAP    #1
        ADDQ.L  #6,SP
        CLR     RES             ; SET LOW REZ

        MOVE.L  #BUSSERROR,8    ; SET ERROR REGS
        MOVE.L  #ADRERROR,$C

;                       ***** INIT SCORE BOX CONSTANTS *****
        MOVE.L  #SCOREBOXIMG,D0
        MOVE.B  D0,SBLO         ; MOVE SCORE BOX ADRESS
        LSR.L   #8,D0
        MOVE.B  D0,SBMI
        LSR     #8,D0
        MOVE.B  D0,SBHI
        MOVE.L  #SCOREBOXIMG,SCOREBOXA  ; & SCORE BOX

;                       ***** INIT JOY HANDLER *****
WAITXMT1:
        BTST    #1,ACIACTL      ; READY TO XMT?
        BEQ     WAITXMT1
        MOVE.B  #$15,ACIADAT    ; KILL CONST. JOY PKG

;                       ***** INIT MFP68901 *****
        MOVE    #$2700,SR
        MOVE.L  #TIMERB,$120
        move.b  #$01,IMRA       ; set imra  enable only
        move.b  #$00,IMRB       ; set imrb    timer B
        move.b  #$01,IERA       ; ierA
        move.b  #$00,IERB       ; ierb
        BCLR    #3,VR
        MOVE    #$2300,SR

; FIRST WE MUST SIGN THE DATA (REPLAY DATA IS UNSIGNED) EXPLOSION
        MOVE    #EXPLOEND-EXPLO-1,D0
        LEA     EXPLO,A0
ESIGNING SUB.B   #128,(A0)+
        DBRA    D0,ESIGNING
; FIRST WE MUST SIGN THE DATA (REPLAY DATA IS UNSIGNED) TITLE SONG
        LEA     TITLESONG,A0
TSIGNING SUB.B   #128,(A0)+
        CMP.L   #TITLEEND,A0
        BNE     TSIGNING
        CLR.B   WARPFLAG        ; CLEAR FADER/WARP FLAG

; ********************************************************************
;                  TITLE SCREEN DISPLAY
; ********************************************************************
TITLEINIT:
        LEA     PICTURE+2,A0    ; LOAD RIG PALETTE ADR
        LEA     HPALETTE,A1     ; & DEST PAL ADRESS
        MOVE    #16,D0          ; SET ALL COLORS TO WHITE
        JSR     WHITER          ; FADE
        BRA     DECOMPPIC
TITLEINIT2:
DECOMPPIC:
        LEA     SCREEN1BASE,A6       ; DECOMPRESS PICTURE
        LEA     PICTURE+34,A0
        JSR     DECOMPRESS

        MOVE.L  #SCREEN1BASE,D0      ; DISPLAY SCREEN
        SWAP    D0
        MOVE.B  D0,VBASEHI
        ROL.L   #8,D0
        MOVE.B  D0,VBASEMI
        ROL.L   #8,D0
        MOVE.B  D0,VBASELO
        MOVE    #$2700,SR
        MOVE.B  #%0,$FFFA1B     ; STOP TIMER B
        MOVE.L  #TITLEVBL,$70   ; INSTALL TITLE VBL
        MOVE    #$2300,SR

;               ***** DIGITIZED SOUND INIT ****
; SECONDLY WE SET UP OUR LMC1992 MIXING VIA THE MICOWIRE? INTERFACE
        MOVE    #%11111111111,MICROMASK ; 2 BITS ADRESS 9 BITS DATA
        MOVE    #%10011101000,D0        ; -0 dB VOLUME
        JSR     MICROSEND
        MOVE    #%10101010100,D0        ; -0 dB VOLUME LEFT
        JSR     MICROSEND
        MOVE    #%10100010100,D0        ; -0 dB VOLUME RIGHT
        JSR     MICROSEND
        MOVE    #%10010000110,D0        ; 0dB TREBLE
        JSR     MICROSEND
        MOVE    #%10001000110,D0        ; 0dB BASS
        JSR     MICROSEND
        MOVE    #%10000000001,D0        ; MIX GI WITH SAMPLES
        JSR     MICROSEND
; THIRD WE SIMPLY MUST DESCRIBE THE SAMPLE TO THE DAC
        MOVE.L  #TITLESONG,D0      ; BASE ADRESS (START)
        LEA     FBASEHI-1,A0
        MOVEP.L D0,0(A0)
        MOVE.L  #TITLEEND,D0     ; END ADRESS  (END+1)
        LSL.L   #8,D0
        LEA     FENDHI+1,A0
        MOVEP.L D0,0(A0)
        MOVE    #$80,SNDMODE    ; MONO, 6258HZ
        MOVE    #3,SNDDMAC      ; PLAY FOREVER

        PEA     PICTURE+2       ; LOAD SOURCE PALETTE ADR
        PEA     HPALETTE        ; DEST
        JSR     WHITEIN         ; ONE TIME WHITE IMAGE IN
AFTERINITWI:
        ADDQ.L  #8,SP
        MOVE.L  #FADEIN,AFTERINITWI-4   ; AND THEN ALLWAYS FADE IT IN

;       ***** ACTIVE PORTION OF INTRO *****

        MOVE    #120-1,D7       ; WAIT 4 SECONDS
        JSR     DELAY

        JSR     DRAWEYES        ; OPEN EYES

        MOVE    #60-1,D7        ; WAIT 1 SECOND
        JSR     DELAY

;       ***** REPEATING PORTION OF INTRO *****

L       JSR     BLINK
        JSR     BLINK

        MOVE    #60-1,D7        ; WAIT 1 SECOND
        JSR     DELAYINTRO

        JSR     BLINK

        MOVE    #90-1,D7        ; WAIT 3/2 SECOND
        JSR     DELAYINTRO
        JMP     L

; ********************************************************************
;                  RIVER INITIALIZATION PRYOR TO PLAY
; ********************************************************************
STARTGAME:
        PEA     PICTURE+2       ; SOURCE
        PEA     HPALETTE        ; DEST
        JSR     FADEOUT         ; FADE TO BLACK
        ADDQ.L  #8,SP

        MOVE    #7,D0           ; KILL RIVER PALETTE
        LEA     RIVERPAL,A0
BLACKRIVER:
        CLR.L   (A0)+
        DBRA    D0,BLACKRIVER

;                       ***** INIT SCROLLING RIVER *****
        MOVE    #144,WINDX           ; INTSCREENS
        CLR     WINDY
        CLR.B   SCRFLIP
        LEA     SCREEN2,A1
        JSR     DRAWSCREEN
;                       ***** INIT SCORE BOX *****
WWMRESET:
        MOVE.L  #0,SCORE         ; CLEAR SCORE
        MOVE.B  #0,SCORE+4
        CLR.L   NVBLS            ; CLEAR VBL COUNTER
        CLR.B   RTIMING
        MOVE    #127,STUNS      ; INIT FULL STUNS & LIFE
        MOVE    #127,LIFE
        MOVE.B  #200,SCOREY     ; PUT SCORE BOX AT BOTTOM OF SCREEN
;                       ***** INIT SPRITE COORDS *****
        MOVE    #19*16-8,SHIPX     ; INITIALIZE SHIP POSITION
        MOVE    #5*16,SHIPY
        CLR.L   STIMER          ; CLEAR MAINLINE ITERATION LOOP
;                       ***** INIT LINE COUNTER INTERUPT *****
        MOVE    #$2300,SR
;                       ***** INIT VBL *****
        MOVE.L  #VBL,$70        ; INSTALL VBL
        MOVE    #$2300,SR
LIFTSCORE:
        SUB.B   #1,SCOREY       ; LIFT SCORE BOX
        CMP.B   #160,SCOREY
        BEQ     SCOREINPLACE
        MOVE.L  #3,D7
        JSR     DELAY
        BRA     LIFTSCORE
SCOREINPLACE:

;                       ***** DIGITIZED SOUND INIT *****

; THEN WE SIMPLY MUST DESCRIBE THE SAMPLE TO THE DAC
        MOVE.L  #EXPLO,D0      ; BASE ADRESS (START)
        LEA     FBASEHI-1,A0
        MOVEP.L D0,0(A0)

        MOVE.L  #EXPLOEND,D0     ; END ADRESS  (END+1)
        LSL.L   #8,D0
        LEA     FENDHI+1,A0
        MOVEP.L D0,0(A0)

        MOVE    #$81,SNDMODE    ; MONO, 12517HZ
        MOVE    #1,SNDDMAC      ; PLAY ONCE

; THEN WE SET UP OUR LMC1992 MIXING VIA THE MICOWIRE? INTERFACE
        MOVE    #%11111111111,MICROMASK ; 2 BITS ADRESS 9 BITS DATA

        MOVE    #%10011101000,D0        ; -0 dB VOLUME
        JSR     MICROSEND
        MOVE    #%10101010100,D0        ; -0 dB VOLUME LEFT
        JSR     MICROSEND
        MOVE    #%10100010100,D0        ; -0 dB VOLUME RIGHT
        JSR     MICROSEND
        MOVE    #%10010001100,D0        ; +12dB TREBLE
        JSR     MICROSEND
        MOVE    #%10001001100,D0        ; 0dB BASS
        JSR     MICROSEND
        MOVE    #%10000000001,D0        ; MIX GI WITH SAMPLES
        JSR     MICROSEND

        PEA     MAP_PALETTE     ; SOURCE
        PEA     RIVERPAL        ; DEST
        JSR     FADEIN
        ADDQ.L  #8,SP
; ********************************************************************
;                       MAINLINE RIVER PLAY LOOP
; ********************************************************************
MAINLINE:               ; ***** MAINLINE LOOP *****
        ADD.L   #1,STIMER       ; INCREMENT
        JSR     JOY     ; READ JOYSTICKS
        JSR     ABSJOY

        CMP.B   #6,RTIMING      ; ADVANCE RIVER EVERY 6 VBLS
        BLT     NOADVRIVER
        CLR.B   RTIMING
        ADDQ    #1,SHIPY        ; MOVE SHIP DOWN RIVER
        ADDQ    #1,WINDY        ; MOVE RIVER DOWN RIVER
        CMP     #2144,WINDY     ; END OF RIVER?
        BNE     NOTATEND
        SUB     #2144,WINDY     ; YES RESET SHIP & RIVER Y'S
        SUB     #2144,SHIPY
NOTATEND:
NOADVRIVER:

        MOVE    SHIPX,D0        ; ADJUST HORIZ ALIGNMENT OF WINDOW
        SUB     #320/2-8,D0     ; CENTER SHIP
        BGE     WINDMINOK       ; MAKE SURE NOT OFF LEFT SIDE
        CLR     D0
WINDMINOK:
        CMP     #MAPW*16-320,D0 ; MAKE SURE NOT OFF RIGHT SIDE

        BLE     WINDMAXOK
        MOVE    #MAPW*16-320,D0
WINDMAXOK:
        MOVE    D0,WINDX        ; STORE

        LEA SCORE+5,A0      ; INCREMENT SCORE
        LEA ONE+5,A1
        MOVE #0,CCR
        ABCD.B -(A1),-(A0)
        ABCD.B -(A1),-(A0)
        ABCD.B -(A1),-(A0)
        ABCD.B -(A1),-(A0)

        ADDQ #2,ENERGY


        LEA     SPPARM,A0       ; SET SPRITE0 PARMS FOR SHIP
        MOVE    SHIPX,XCORD(A0)
        MOVE    SHIPY,YCORD(A0)
        MOVE.B  SHIPDIR+1,ANIMSEQ(A0)


;       ***** DRAW WINDOW *****
        MOVE.L  #SCREEN1BASE,A1      ; FLIP SCREEN ADRESS
        TST.B   SCRFLIP
        BEQ     DRAWSCR
        MOVE.L  #SCREEN2BASE,A1
DRAWSCR:
        JSR     DRAWSCREEN      ; DRAW OTHER SCREEN

;       ***** DRAW SCORE BAR *****
        MOVE.L #SCORE,A1     ; POINT A1 TO SCORE
        MOVE.L SCOREBOXA,A0   ; GET SCREEN ADRESS
        ADD.L #SCOREA,A0      ; ADD INDEX TO SCORE
        JSR DISPDGTS          ; DISP SCORE

        MOVE ENERGY,D0        ; DISP ENERGY BAR
        MOVE.L SCOREBOXA,A0
        ADD.L #ENERGYA,A0
        JSR DISPBAR

        CMP     #128,LIFE
        BCS     DSPLIFE
        CLR     LIFE
DSPLIFE:
        MOVE LIFE,D0         ; DISP LIFE BAR
        MOVE.L SCOREBOXA,A0
        ADD.L #LIFEA,A0
        JSR DISPBAR

        MOVE STUNS,D0        ; DISP STUNS BAR
        MOVE.L SCOREBOXA,A0
        ADD.L #STUNSA,A0
        JSR DISPBAR

;       ***** AFTER DISPLAY ROUTINES PROCESSING *****

        TST     LIFE            ; ARE WE STILL ALIVE?
        BGT     NOTDEAD
        PEA     MAP_PALETTE     ; NO - WHITEOUT
        PEA     RIVERPAL
        JSR     FADEOUT
        ADDQ.L  #8,SP
DROPSCORE:
        ADDQ.B  #1,SCOREY       ; PUSH CONSOLE OFF SCREEN
        CMP.B   #200,SCOREY
        BEQ     TITLEINIT2
        MOVE.L  #1,D7
        JSR     DELAY
        BRA     DROPSCORE
NOTDEAD:

        JSR     COLDETCT        ; DO SHIP COLLISION DETECTION

        JMP MAINLINE         ; AND KEEP LOOPING

; ********************************************************************
;                       SUBROUTINES
; ********************************************************************
; WWM SCROLLING SCREEN DRIVER
DRAWSCREEN:             ; FILL SCREEN BUFFER WITH GRAPHICS FROM
                        ; THE CHARACTER MAP.
                        ; PARAMETERS    A1 - SCREENBASE?
                        ;               WINDX & WINDY IN PIXELS
                ; A1 TO PT TO VISIBLE SCREEN
        MOVE.L  A1,A3           ; SAVE SCREENBASE
        ADD.L   #((WINDW+1+(2*HBUF))*VBUF*128)+(HBUF*8),A1

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
        ADD     #(WINDW+1+(HBUF*2))*8,D1 ; NEXT SCREEN LINE
        DBRA    D2,DRAWCHR

        ADD.L   #8,A1           ; NEXT CHR TO THE RIGHT ON THE SCREEN
        DBRA    D3,NEXTCOL

        ADD.L   #(MAPW-(WINDW+1))*2,A0  ; NEXT ROW IN MAP
        ADD.L   #((WINDW+1+(HBUF*2))*8*15)+(2*HBUF*8),A1 ; NEXT ROW ON SCREEN
        DBRA    D4,NEXTROW

        MOVE.L  A3,-(SP)
        JSR     EXPLOSION
        JSR     SMASH
;        JSR     BBMOVE1         ; BALLBUSTER
        JSR     FOUNTAIN
        JSR     SHOTMOVE
        JSR     SHOTINIT
        JSR     MINEINIT

;                       ***** SPRITE DRAW IS HERE *****

        MOVE.L  (SP)+,A1   ; RESTORE SCREEN BASE
        MOVE    #NUMSP-1,D7
DRAWALLSP:                     ; DRAW ALL THE SPRITES
        MOVE    D7,-(SP)
        CLR.L   D0
        MOVE    D7,D0
        JSR     DRAWSP
        MOVE    (SP)+,D7
        DBRA    D7,DRAWALLSP

                ; A1 TO PT TO VISIBLE SCREEN
        ADD.L   #((WINDW+1+(HBUF*2))*VBUF*128)+(HBUF*8),A1

        MOVE.B  WINDY+1,D0
        AND     #$F,D0          ; GET VERT ROT VAL
        MULU    #8*(WINDW+1+(HBUF*2)),D0 ; * LINEW
        ADD     D0,A1

        MOVE    WINDX,D0        ; SET HSCROLL SHADOW
        AND     #$F,D0

        EOR.B   #1,SCRFLIP      ; FLAG SCREEN FLIP
 
        MOVE    #$2500,SR       ; KILL VBLS
        MOVE.B  D0,SHSCROLL     ; JAM SHADOWS
        MOVE.L  A1,SCREENA      ; AND DISP AT NEXT VBL
        MOVE    #$2300,SR       ; RESTORE VBLS
        RTS

;                       ***** JOY HANDLER (ACIA) *****
        INCLUDE 'D:\ASSEMPRO\WWM\JOYKBD.S'

;                       ***** ABSOLUTE POSITION JOY HANDLER *****
        INCLUDE 'D:\ASSEMPRO\WWM\ABSJOY.S'

MICROSEND:      ;       ***** MICROWIRE SEND ROUTINE *****
        CMP     #%11111111111,MICROMASK ; WAIT FOR TRANSMITION
        BNE.S   MICROSEND
        MOVE    D0,MICRODATA            ; SEND DATA
        RTS

;       ***** WARP ROUTINE *****
        INCLUDE 'D:\ASSEMPRO\WWM\WWM_WARP.S'

;       ***** SHIP COLISION DETECTION ROUTINES *****
        INCLUDE 'D:\ASSEMPRO\WWM\COLDETCT.S'

;       ***** D~ED'S SPRITE HANDLER *****
        INCLUDE 'D:\ASSEMPRO\WWM\SPRITE5.S'
        INCLUDE 'D:\ASSEMPRO\WWM\SPUTIL.S'
        INCLUDE 'D:\ASSEMPRO\WWM\BLAST.S'
        INCLUDE 'D:\ASSEMPRO\WWM\SHOOT.S'
        INCLUDE 'D:\ASSEMPRO\WWM\MINE.S'
        INCLUDE 'D:\ASSEMPRO\WWM\SMASH.S'

;       ***** TITLE SUBROUTINES *****
        INCLUDE 'D:\ASSEMPRO\WWM\EYES.S'     ; BLINKING EYES
        INCLUDE 'D:\ASSEMPRO\WWM\FADERS.S'   ; FADING EFFECTS
        INCLUDE 'D:\ASSEMPRO\WWM\DECMPRES.S' ; DEGAS DECOMPRESSION
DELAY:
        ADD.L   NVBLS,D7        ; WVBL
DEL1    CMP.L   NVBLS,D7
        BNE     DEL1
        RTS

DELAYINTRO:
        ADD.L   NVBLS,D7        ; WVBL
DEL2:
        JSR     JOY
        TST.B   JOY1
        BEQ     NOSTART
        ADDQ.L  #4,SP   ; FIX STACK FOR JSR
        JMP     STARTGAME
NOSTART:
        CMP.L   NVBLS,D7
        BGE     DEL2
        RTS

; ********************************************************************
;                       INTERUPT ROUTINES
; ********************************************************************
TIMERB:
        NOP
        MOVE.B  SBLO,VCTRLO       ; DISPLAY SCORE/STATUS BOX
        MOVE.B  SBMI,VCTRMI
        MOVE.B  SBHI,VCTRHI
        CLR.B   HSCROLL
        CLR.B   WRAP       
 
        MOVE.B  #%0,$FFFA1B     ; STOP TIMER B
        MOVE.L  SCORE_PALETTE,$FF8240   ; SET SCORE COLORS
        MOVE.L  SCORE_PALETTE+4,$FF8244
        MOVE.L  SCORE_PALETTE+8,$FF8248
        MOVE.L  SCORE_PALETTE+12,$FF824C
        MOVE.L  SCORE_PALETTE+16,$FF8250
        MOVE.L  SCORE_PALETTE+20,$FF8254
        MOVE.L  SCORE_PALETTE+24,$FF8258
        MOVE.L  SCORE_PALETTE+28,$FF825C
        rte

VBL:
        MOVE.L  D0,-(SP)
        ADDQ.L  #1,NVBLS        ; INC VBL COUNT
        ADDQ.B  #1,RTIMING      ; INC RIVER TIMING REG
        MOVE.B  SCOREY,$FFFA21     ; TIMER B DATA
        MOVE.B  #%1000,$FFFA1B  ; TIMER B CONTROL

        MOVE.L  SCREENA,D0      ; DISPLAY CURRENT SCREEN
        MOVE.B  D0,VCTRLO
        LSR.L   #8,D0
        MOVE.B  D0,VCTRMI
        LSR     #8,D0
        MOVE.B  D0,VCTRHI

        MOVE.L  #SCOREBOXIMG,SBHI-1     ; SET BASE FOR SCORE BOX
        MOVE.B  #((1+(2*HBUF))*4),WRAP  ; SET WRAP FOR MAP
        TST.B   SHSCROLL                ; TEST HSCROLL SHADOW
        BEQ     WRAPOK
        SUBQ.B  #4,WRAP
        SUBQ.L  #8,SBHI-1                ; FIX SCORE BOX ALIGNMENT
WRAPOK  MOVE.B  SHSCROLL,HSCROLL              ; STORE HSCROLL

        MOVE.L  RIVERPAL,$FF8240     ; SET MAP COLORS
        MOVE.L  RIVERPAL+4,$FF8244
        MOVE.L  RIVERPAL+8,$FF8248
        MOVE.L  RIVERPAL+12,$FF824C
        MOVE.L  RIVERPAL+16,$FF8250
        MOVE.L  RIVERPAL+20,$FF8254
        MOVE.L  RIVERPAL+24,$FF8258
        MOVE.L  RIVERPAL+28,$FF825C
        MOVE.B  NVBLS+3,D0              ; ROTATE COLORS
        AND.B   #3,D0                   ; EVERY 4 VBLS
        BNE     NOCOLROT
        MOVE.W  RIVERPAL+14,D0
        MOVE.W  RIVERPAL+12,RIVERPAL+14
        MOVE.W  RIVERPAL+10,RIVERPAL+12
        MOVE.W  D0,RIVERPAL+10
NOCOLROT:
        MOVE.L  (SP)+,D0
        RTE

BUSSERROR:
        MOVE  #$700,HPALETTE  ; RED MEANS BUSS ERROR
        JMP     BUSSERROR
ADRERROR:
        MOVE  #$70,HPALETTE   ; GREEN MEANS ADRESS ERROR
        JMP     ADRERROR
TITLEVBL:
        ADD.L   #1,NVBLS
        CLR.B   HSCROLL
        CLR.B   WRAP
        RTE
  END

 