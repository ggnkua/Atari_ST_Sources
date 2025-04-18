VBASEHI =       $FFFF8201
VBASEMI =       $FFFF8203
VBASELO =       $FFFF820D ; VIDEO BASE ADRESS

FBASEHI =       $FF8903   ;FRAME BASE
FBASEMI =       $FF8905
FBASELO =       $FF8907

FCNTHI  =       $FF8909 ; FRAME ADRESS COUNTER
FCNTMI  =       $FF890B
FCNTLO  =       $FF890D

FENDHI  =       $FF890F ; FRAME END
FENDMI  =       $FF8911
FENDLO  =       $FF8913

SNDMODE =       $FF8920
SNDDMAC =       $FF8900

MICRODATA =     $FF8922 ; MICROWIRE? INTERFACE DATA REG
MICROMASK =     $FF8924 ; MICROWIRE? INTERFACE MASK REG

HPALETTE        EQU     $FF8240 ; PALETTE HARDWARE REG


AER     = $FFFFA03
IPRA    = $FFFFA0B
IPRB    = $FFFFA0D
IERA    = $FFFFA07
IERB    = $FFFFA09
IMRA    = $FFFFA13
IMRB    = $FFFFA15
ISRA    = $FFFFA0F
ISRB    = $FFFFA11
VR      = $FFFFA17
TADAT   = $FFFFA1F      ; TIMER A DATA
TACTL   = $FFFFA19      ; TIMER A CONTROL
TAVEC   = $134

        DATA
        ALIGN
SAMPLE  IBYTES  'D:\REPLAY\SAMPLES\WWMSTE.SPL'
SAMPEND:

        BSS
        ALIGN
SONGPTR DS.L 1
        DS.B    $400   ; 1 K STACK
STACK:
CTR     DS.B    1

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

;               ***** DIGITIZED SOUND INIT ****
; FIRST WE MUST SIGN THE DATA (REPLAY DATA IS UNSIGNED)
        LEA     SAMPLE,A0
SIGNING SUB.B   #128,(A0)+
        CMP.L   #SAMPEND,A0
        BNE     SIGNING

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
        MOVE.L  #SAMPLE,D0      ; BASE ADRESS (START)
        LEA     FBASEHI-2,A0
        MOVEP.L D0,0(A0)
        MOVE.L  #SAMPLE+12472,D0 ; END ADRESS  (END+1)
        LSL.L   #8,D0
        LEA     FENDHI,A0
        MOVEP.L D0,0(A0)
        MOVE    #$80,SNDMODE    ; MONO, 6258HZ
        CLR.L   SONGPTR

        MOVE    #$2700,SR
        MOVE.L  #TIMERA,$100+(15*4)
        BCLR    #3,VR
        ORI.B   #$80,IERA
        ORI.B   #$80,IMRA
        BSET    #7,AER
        MOVE    #$2500,SR       ; LET GO
        MOVE.B  #1,CTR
        MOVE    #3,SNDDMAC      ; PLAY FOREVER

LOOP:
        MOVE.B  CTR,D0
        JSR     SHOWD0
        JMP     LOOP

showd0:
  movem.l d0-d7/a0-a6,-(sp)
  move.l d0,d2          ; display long word in d0
  jsr hex2asci
  move.b d0,adr+7
  move.b d1,adr+6
  asr.l #8,d2
  move.l d2,d0
  jsr hex2asci
  move.b d0,adr+5
  move.b d1,adr+4
  asr.l #8,d2
  move.l d2,d0
  jsr hex2asci
  move.b d0,adr+3
  move.b d1,adr+2
  asr.l #8,d2
  move.l d2,d0
  jsr hex2asci
  move.b d0,adr+1
  move.b d1,adr
        MOVE.L  #STR,-(SP)
        MOVE    #9,-(SP)
        TRAP    #1
        ADD.L   #6,SP
  movem.l (sp)+,d0-d7/a0-a6
  rts

hex2asci:               ; hex in d0 to ascii in d0(low) d1(high)
  move.b d0,d1
  and.b #$f,d0
  cmp.b #$a,d0
  blt lta1
  add.b #'A'-'0'-$a,d0
lta1:
  add.b #'0',d0
  lsr #4,d1
  and.b #$f,d1
  cmp.b #$a,d1
  blt lta2
  add.b #'A'-'0'-$a,d1
lta2:
  add.b #'0',d1
  rts
MICROSEND:      ;       ***** MICROWIRE SEND ROUTINE *****
        CMP     #%11111111111,MICROMASK ; WAIT FOR TRANSMITION
        BNE.S   MICROSEND
        MOVE    D0,MICRODATA            ; SEND DATA
        RTS

TIMERA:
        SUBQ.B  #1,CTR
        BNE NORPT
        MOVEM.L D0-D1/A0,-(SP)

TOPOFSONG:
        ADDQ.L  #4,SONGPTR
        MOVE.L  SONGPTR,D0
        LEA     SONG,A0
        MOVE.L  0(A0,D0.L),D0   ; FETCH BLOCK & REPEAT DATA
        BNE     NOTDONE
        CLR.L   SONGPTR         ; NEGATIVE? START OVER
        BRA     TOPOFSONG
NOTDONE:
        MOVE.B  D0,CTR          ; STORE REPS
        SWAP    D0              ; FETCH TABLE INDEX
        LSL     #2,D0           ; LONGWORD ALIGNMENT
        LEA     BLOCKTAB,A0

        MOVE.L  0(A0,D0.W),D1   ; BEGINNING
        ADD.L   #SAMPLE,D1
        SWAP    D1
        MOVE.B  D1,FBASEHI
        ROL.L   #8,D1
        MOVE.B  D1,FBASEMI
        ROL.L   #8,D1
        MOVE.B  D1,FBASELO       ; STORE BASE

        MOVE.L  4(A0,D0.W),D1   ; END
        ADD.L   #SAMPLE,D1
        SWAP    D1
        MOVE.B  D1,FENDHI
        ROL.L   #8,D1
        MOVE.B  D1,FENDMI
        ROL.L   #8,D1
        MOVE.B  D1,FENDLO       ; STORE END

        MOVEM.L (SP)+,D0-D1/A0
NORPT:
        RTE

        DATA
        ALIGN
STR:
        DC.B 27,'H'
ADR     DC.B '00000000 ',0
        ALIGN
BLOCKTAB:
        DC.L    0,12472,24880,37182,49700,61936,74246
        DC.L    86363,98646,110762
;       0 INTRO DRUM ROLL
;       1 INTR0 DRUMS
;       2 INTRO BASS
;       3 INTRO GUITINT
;       4 GUITAR
;       5 GUITAR 2
;       6 SCALES 1
;       7 SCALES 2
;       8 SCALES 3
SONG:
        DC.W    0,1,1,2,2,3,3,1,4,2,5,1,6,1,7,1,8,1,7,1,6,1,4,1,2,2
        DC.L    0
        END
 