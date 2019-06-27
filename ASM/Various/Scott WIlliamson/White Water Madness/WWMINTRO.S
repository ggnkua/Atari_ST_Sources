VBASEHI =       $FFFF8201
VBASEMI =       $FFFF8203
VBASELO =       $FFFF820D ; VIDEO BASE ADRESS

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
SNDDMAC =       $FF8900

MICRODATA =     $FF8922 ; MICROWIRE? INTERFACE DATA REG
MICROMASK =     $FF8924 ; MICROWIRE? INTERFACE MASK REG

HPALETTE        EQU     $FF8240 ; PALETTE HARDWARE REG

        DATA
        ALIGN
ENV:
COM     DC.L    0
EOREYES IBYTES  'D:\ASSEMPRO\WWM\EOR_EYES.IMG'
SAMPLE  IBYTES  'D:\REPLAY\SAMPLES\WWMSTE.SPL'
SAMPEND:
PICTURE IBYTES  'D:\ARTPROGS\DEGAS\PICTURES\TITL2WWM.PC1'
FILE    DC.B    'A:WWM_SCRN.PRG',0

        BSS
        ALIGN
BRIGHTNESS:
        DS.W 1
SCREEN:
        DS.B    32000
        DS.B    $400   ; 1 K STACK
STACK:

        TEXT
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
        MOVE #$20,-(SP)
        TRAP #1
        ADDQ.L #6,SP

;               ***** VIDEO INIT *****
        DC.W    $A00A           ; HIDE MOUSE
        MOVE    #0,$FF8260      ; LOW REZ

        LEA     PICTURE+2,A0    ; LOAD RIG PALETTE ADR
        LEA     HPALETTE,A1     ; & DEST PAL ADRESS
        MOVE    #16,D0          ; SET ALL COLORS TO WHITE
        JSR     WHITER          ; FADE

        LEA     SCREEN,A6       ; DECOMPRESS PICTURE
        LEA     PICTURE+34,A0
        JSR     DECOMPRESS

        MOVE.L  #SCREEN,D0      ; DISPLAY SCREEN
        SWAP    D0
        MOVE.B  D0,VBASEHI
        ROL.L   #8,D0
        MOVE.B  D0,VBASEMI
        ROL.L   #8,D0
        MOVE.B  D0,VBASELO

;               ***** DIGITIZED SOUND INIT ****
; FIRST WE MUST SIGN THE DATA (REPLAY DATA IS UNSIGNED)
        LEA     SAMPLE,A0
SIGNING SUB.B   #128,(A0)+
        CMP.L   #SAMPEND+1,A0
        BNE     SIGNING
; SECONDLY WE SET UP OUR LMC1992 MIXING VIA THE MICOWIRE? INTERFACE
        MOVE    #%11111111111,MICROMASK ; 2 BITS ADRESS 9 BITS DATA
        MOVE    #%10011101000,MICRODATA ; -40DB VOLUME
MICROWIREWAIT:
        CMP     #%11111111111,MICROMASK ; WAIT FOR TRANSMITION
        BNE     MICROWIREWAIT
        MOVE    #%10000000001,MICRODATA ; MIX GI WITH SAMPLES
; THIRD WE SIMPLY MUST DESCRIBE THE SAMPLE TO THE DAC
        MOVE.L  #SAMPLE,D0      ; BASE ADRESS (START)
        LEA     FBASEHI-1,A0
        MOVEP.L D0,0(A0)
        MOVE.L  #SAMPEND,D0     ; END ADRESS  (END+1)
        LSL.L   #8,D0
        LEA     FENDHI+1,A0
        MOVEP.L D0,0(A0)
        MOVE    #$80,SNDMODE    ; MONO, 6258HZ
        MOVE    #3,SNDDMAC      ; PLAY FOREVER

        JSR     WHITEIN         ; FADE IMAGE IN

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
        JSR     DELAY

        JSR     BLINK

        MOVE    #90-1,D7        ; WAIT 3/2 SECOND
        JSR     DELAY
        JMP     L
;               ***** SUBROUTINES *****
FADER:  ; GIVEN THE ORIGINAL PALETTE ADR IN A0, THE NEW ONE IN A1
        ; AND A VALUE FROM 0-15 IN D0 FADER WILL FILL THE NEW PALETTE
        ; 0 BEING NORMAL & 15 BEING BLACK
        MOVE    #16-1,D1        ; 16 COLOR REGS
NEXTCOLOR:
        MOVE    (A0)+,D2        ; GET COLOR
        MOVE    #3-1,D6         ; 3 BEAMS
        CLR     D5              ; WORK REG
        CLR     D4              ; ROT REG
NEXTBEAM:
        MOVE.B  D2,D3           ; GET BYTE
        AND.B   #$F,D3          ; MASK OFF OTHER COL
        LSL.B   #1,D3           ; ACCOUNT FOR SCREWED UP COLOUR BIT
        BTST    #4,D3
        BEQ     NOLOWCOLBIT1
        BSET    #0,D3
NOLOWCOLBIT1:
        AND     #$F,D3
        SUB.B   D0,D3           ; SUBTRACT D0
        BGE     NOTNEG
        CLR.B   D3              ; IF NEGATIVE MAKE 0
NOTNEG:
        MOVE    #0,CCR          ; FIX FOR SCREWED UP COLOR REG
        LSR.B   #1,D3
        BCC     NOLOWCOLBIT2
        BSET    #3,D3
NOLOWCOLBIT2:
        LSL     D4,D3           ; PUT BACK INTO POSITION
        OR      D3,D5           ; OR INTO DESTINATION WORD
        LSR     #4,D2           ; NEXT BEAM
        ADD     #4,D4           ; NEXT ROT POSITION
        DBRA    D6,NEXTBEAM
        MOVE    D5,(A1)+
        DBRA    D1,NEXTCOLOR
        RTS

FADEIN:
        MOVE    #15,BRIGHTNESS
FI:
        LEA     PICTURE+2,A0    ; LOAD RIG PALETTE ADR
        LEA     HPALETTE,A1      ; & DEST PAL ADRESS
        MOVE    BRIGHTNESS,D0
        JSR     FADER           ; FADE

        MOVE    #2-1,D7         ; WAIT 2 VBL'S
        JSR     DELAY

        SUBQ    #1,BRIGHTNESS
        BGE     FI
        RTS

FADEOUT:
        MOVE    #0,BRIGHTNESS
FO:
        LEA     PICTURE+2,A0    ; LOAD RIG PALETTE ADR
        LEA     HPALETTE,A1      ; & DEST PAL ADRESS
        MOVE    BRIGHTNESS,D0
        JSR     FADER           ; FADE

        MOVE    #2-1,D7         ; WAIT 2 VBL'S
        JSR     DELAY

        ADDQ    #1,BRIGHTNESS
        CMP     #16,BRIGHTNESS
        BNE     FO
        RTS

WHITER: ; GIVEN THE ORIGINAL PALETTE ADR IN A0, THE NEW ONE IN A1
        ; AND A VALUE FROM 0-15 IN D0 WHITER WILL FILL THE NEW PALETTE
        ; 0 BEING NORMAL & 15 BEING WHITE
        MOVE    #16-1,D1        ; 16 COLOR REGS
NEXTCOLOR1:
        MOVE    (A0)+,D2        ; GET COLOR
        MOVE    #3-1,D6         ; 3 BEAMS
        CLR     D5              ; WORK REG
        CLR     D4              ; ROT REG
NEXTBEAM1:
        MOVE.B  D2,D3           ; GET BYTE
        AND.B   #$F,D3          ; MASK OFF OTHER COL
        LSL.B   #1,D3           ; ACCOUNT FOR SCREWED UP COLOUR BIT
        BTST    #4,D3
        BEQ     NOLOWCOLBIT3
        BSET    #0,D3
NOLOWCOLBIT3:
        AND     #$F,D3
        ADD.B   D0,D3           ; SUBTRACT D0
        CMP     #$F,D3
        BLE     NOTOVER
        MOVE.B  #$F,D3          ; IF NEGATIVE MAKE 0
NOTOVER:
        MOVE    #0,CCR          ; FIX FOR SCREWED UP COLOR REG
        LSR.B   #1,D3
        BCC     NOLOWCOLBIT4
        BSET    #3,D3
NOLOWCOLBIT4:
        LSL     D4,D3           ; PUT BACK INTO POSITION
        OR      D3,D5           ; OR INTO DESTINATION WORD
        LSR     #4,D2           ; NEXT BEAM
        ADD     #4,D4           ; NEXT ROT POSITION
        DBRA    D6,NEXTBEAM1
        MOVE    D5,(A1)+
        DBRA    D1,NEXTCOLOR1
        RTS

WHITEIN:
        MOVE    #15,BRIGHTNESS
WI:
        LEA     PICTURE+2,A0    ; LOAD RIG PALETTE ADR
        LEA     HPALETTE,A1      ; & DEST PAL ADRESS
        MOVE    BRIGHTNESS,D0
        JSR     WHITER           ; FADE

        MOVE    #2-1,D7         ; WAIT 2 VBL'S
        JSR     DELAY

        SUBQ    #1,BRIGHTNESS
        BGE     WI
        RTS

WHITEOUT:
        MOVE    #0,BRIGHTNESS
WO:
        LEA     PICTURE+2,A0    ; LOAD RIG PALETTE ADR
        LEA     HPALETTE,A1      ; & DEST PAL ADRESS
        MOVE    BRIGHTNESS,D0
        JSR     WHITER           ; FADE

        MOVE    #2-1,D7
        JSR     DELAY

        ADDQ    #1,BRIGHTNESS
        CMP     #16,BRIGHTNESS
        BNE     WO
        RTS

DELAY:
        MOVE    #37,-(SP)       ; WVBL
        TRAP    #14
        ADDQ.L  #2,SP
        DBRA    D7,DELAY
        RTS

BLINK:
        JSR     DRAWEYES        ; CLOSE EYES
        MOVE    #4-1,D7         ; WAIT 4/60THS OF A SECOND
        JSR     DELAY
        JSR     DRAWEYES        ; OPEN EYES
        MOVE    #20-1,D7        ; WAIT 1/3 OF A SECOND
        JSR     DELAY
        RTS

;       DRAWEYES        TOGLES EYES
DRAWEYES:
        LEA     EOREYES,A1
        LEA     SCREEN+(44*160)+(5*8),a0
        move    #71-44-1,d1       ; COPY & DISPLAY EYES
copy1:
        move    #((14-5)*2)-1,d0
copy:
        MOVE.L  (A1)+,D3
        EOR.L   D3,(A0)+
        dbra    d0,copy
        add.l   #(160-((14-5)*8)),a0
        dbra    d1,copy1
        RTS

DECOMPRESS:
;                               ***** DECOMPRESS PICTUERS
;       A0 - SOURCE     A6 - DEST
  CLR.L d6              ; screen length in bytes
  move.l #40,d5         ; line length 1 bpl
  move.l #4,d4          ; bpl counter
  MOVE.L #2,D3          ; WORD
READCOMMAND:

  MOVE.B (A0)+,D0
  CMP.B #-128,D0
  BEQ READCOMMAND       ; IGNORE -128
  CMP.B #0,D0
  BGE COPYNEXTBYTES     ; D0 >=0 COPY NEXT D0+1 BYTES LITERALLY

COPYNEXTBYTE:           ;    OTHERWISE
  NEG.B D0              ; D0 <0 COPY NEXT BYTE -D0+1 TIMES
  EXT.W D0
  EXT.L D0              ; NEGATE D0 & MAKE IT A LONG WORD

PUTBYTE:
  MOVE.B (A0),(A6,D6.L) ; PUT BYTE IN SCREEN BUFFER
  ADDQ.L #1,D6          ; INC SCREEN ADR
  SUBQ.L #1,D5          ; LINE LENGTH
  SUBQ.L #1,D3          ; BYTES PER WORD
  BNE WORDOK
  ADDQ.L #6,D6          ; SKIP OTHER BPL'S
  MOVE.L #2,D3
WORDOK:
  DBRA D0,PUTBYTE
        ADDQ.L  #1,A0
  BRA PROCEND

COPYNEXTBYTES:
  EXT.W D0
  EXT.L D0              ; MAKE D0 A LONG WORD
PUTBYTE2:
  MOVE.B (A0)+,(A6,D6.L) ; PUT BYTE IN SCREEN BUFFER
  ADDQ.L #1,D6          ; INC SCREEN ADR
  SUBQ.L #1,D5          ; LINE LENGTH
  SUBQ.L #1,D3          ; BYTES PER WORD
  BNE WORDOK2
  ADDQ.L #6,D6          ; SKIP OTHER BPL'S
  MOVE.L #2,D3
WORDOK2:
  DBRA D0,PUTBYTE2

PROCEND:
  CMP.L #0,D5           ; END OF LINE?
  BNE READCOMMAND       ; NO KEEP READING
  MOVE.L #40,D5         ; EOL - RESET LINE BYTE COUNER
  SUBQ.L #1,D4          ; LAST BPL ?
  BEQ NEXTLINE          ; YES
  SUB.L #158,D6         ; NO - NEXT BPL CURRENT LINE
  BRA READCOMMAND
NEXTLINE:               ; NEW LINE
  SUBQ.L #6,D6          ; RESET TO BPL 0 NEXT LINE
  MOVE.L #4,D4          ; RESET BPL COUNTER
  CMP.L #32000,D6       ; END OF SCREEN ?
  BEQ DONECOMPRESSED
        BRA READCOMMAND
DONECOMPRESSED:
        RTS
        END
 