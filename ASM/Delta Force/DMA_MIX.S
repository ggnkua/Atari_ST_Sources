;--------------------------------------------------------------------;
;                Digisynth - NoiseTracker V1.1 replay                ;
;                          by Wiz 24. May '90                        ;
; STE COMP. BY WIZZCAT
; STFM BY ANIMAL MINE
;--------------------------------------------------------------------;
                BRA.S   start
                EVEN
flag1:          DC.W 0          ; Channle x (0 -->  on)
flag2:          DC.W 1          ;  "   "    (1 --> off)
flag3:          DC.W 1          ;  "   "
flag4:          DC.W 1          ;  "   "
                EVEN

start:          PEA     stack
                MOVE.W  #$20,-(SP)
                TRAP    #1              ; Supervisor mode on
                ADDQ.W  #6,SP
                MOVE.L  D0,-(SP)

                LEA     song,A0
                LEA     vset,A1
                MOVEQ   #0,D0
                JSR     s

                BSR     vol             ; Calculate volume tables
                JSR     incrcal         ; Calculate tonetables

                JSR     INIT_MUSIC      ; Initialize music
                BSR     INTon           ; Install interrupts

waitspc:        BTST    #0,$FFFFFC00.w
                BEQ.S   waitspc
                CMPI.B  #$B9,$FFFFFC02.w ; Wait for SPACE
                BNE.S   waitspc
                JSR     END_MUSIC       ; Turn off music

                BSR     INToff          ; Remove those interrupts

                MOVE.W  #$20,-(SP)      ; Supervisor mode off
                TRAP    #1
                ADDQ.W  #6,SP

                CLR.L   -(SP)           ; Terminate
                TRAP    #1

;------------------- Interrupts on/off ------------------
INTon:          MOVE    #$2700,SR

                MOVE.B  $FFFFFA07.w,s07 ; Save MFP registers
                MOVE.B  $FFFFFA09.w,s09
                MOVE.B  $FFFFFA13.w,s13
                MOVE.B  $FFFFFA15.w,s15

                MOVE.B  #$20,$FFFFFA07.w
                MOVE.B  #$20,$FFFFFA13.w
                CLR.B   $FFFFFA09.w
                CLR.B   $FFFFFA15.w

                BCLR    #3,$FFFFFA17.w  ; Autovectors

                CLR.B   $FFFFFA19.w
                MOVE.B  #1,$FFFFFA1F.w
                MOVE.B  #8,$FFFFFA19.w

                MOVE.L  $70.w,oldVBL
                MOVE.L  $0134.w,oldTimA
                MOVE.L  #VBL,$70.w
                MOVE.L  #STEREO,$0134.w

                MOVE.B  #%10,$FFFF8921.w ;  Stereo 25033hz

                MOVE.L  #sample1,D0     ; Start
                LEA     $FFFF8907.w,A0  ; Framestartadresse Low Byte
                MOVE.B  D0,(A0)
                LSR.L   #8,D0
                MOVEP.W D0,-4(A0)       ; ab ins High Bytes

                MOVE.L  #sample1+500,D0 ;  End
                MOVE.B  D0,12(A0)
                LSR.L   #8,D0
                MOVEP.W D0,8(A0)        ; Frame-end adresse Mid Byte

                MOVE.B  #%11,$FFFF8901.w ;  Play sample

                MOVE.L  #sample2,D0     ;  Start
                LEA     $FFFF8907.w,A0
                MOVE.B  D0,(A0)
                LSR.L   #8,D0
                MOVEP.W D0,-4(A0)

                MOVE.L  #sample2+500,D0 ; End
                MOVE.B  D0,12(A0)
                LSR.L   #8,D0
                MOVEP.W D0,8(A0)

                MOVE    #$2500,SR
                RTS

INToff:         MOVE    #$2700,SR

                CLR.B   $FFFFFA19.w     ; Stop timers
                CLR.B   $FFFFFA1B.w

                MOVE.L  oldTimA(PC),$0134.w ; Restore everything
                MOVE.L  oldVBL(PC),$70.w

                MOVE.B  s07(PC),$FFFFFA07.w
                MOVE.B  s09(PC),$FFFFFA09.w
                MOVE.B  s13(PC),$FFFFFA13.w
                MOVE.B  s15(PC),$FFFFFA15.w

                MOVE.B  #0,$FFFF8901.w  *  Stop DMA

                BSET    #3,$FFFFFA17.w  ; Softvectors
                MOVE    #$2300,SR

                RTS

s07:            DC.B 0
s09:            DC.B 0
s13:            DC.B 0
s15:            DC.B 0

oldTimA:        DC.L 0
oldVBL:         DC.L 0

                DS.L 100
stack:          DS.W 3

;----------------------- Volume table -----------------------
vol:            MOVEQ   #64,D0
                LEA     vtabend(PC),A0

.ploop:         MOVE.W  #255,D1
.mloop:         MOVE.W  D1,D2
                EXT.W   D2
                MULS    D0,D2
                DIVS    #$80,D2         *  <---- Master volume
                MOVE.B  D2,-(A0)
                DBRA    D1,.mloop
                DBRA    D0,.ploop

                RTS

vtab:           DS.B 65*256
vtabend:

;----------------------- Increment-table -----------------------
incrcal:        LEA     stab(PC),A0
                MOVE.W  #$71,D1
                MOVE.W  #$06B0-$71,D0
                MOVE.L  #$8EFE3B,D2     ; 3579546/12517*65536,d1 ==> 12517=frequency

recalc:         SWAP    D2
                MOVEQ   #0,D3
                MOVE.W  D2,D3
                DIVU    D1,D3
                MOVE.W  D3,D4
                SWAP    D4

                SWAP    D2
                MOVE.W  D2,D3
                DIVU    D1,D3
                MOVE.W  D3,D4
                MOVE.L  D4,(A0)+

                ADDQ.W  #1,D1
                DBRA    D0,recalc
                RTS

itab:           DS.L $71
stab:           DS.L $06B1-$71

;----------------------------- VBL -----------------------------
VBL:
                MOVEM.L D0-A6,-(SP)
                JSR     s+8
                MOVEM.L (SP)+,D0-A6
                RTE

bit:            DC.W 1

;---------------------- Samplecalculating -----------------------
STEREO:         MOVEM.L D0-D4/A0-A5,-(SP)
                NOT.W   $FFFF8240.w
                MOVE    #$2300,SR

                MOVE.L  samp2(PC),D0    *    Start
                LEA     $FFFF8907.w,A0
                MOVE.B  D0,(A0)
                LSR.W   #8,D0
                MOVE.L  D0,-5(A0)

                MOVE.L  samp2(PC),D0    *    End
                ADD.L   #500,D0
                MOVE.B  D0,12(A0)
                LSR.W   #8,D0
                MOVE.L  D0,7(A0)

                NEG.W   bit
                BMI     WZ_nch4

                JSR     PLAY            ; Music!

                MOVE.W  DMActrl,D0
                MOVEQ   #0,D1

                BTST    #0,D0           ;-------------------
                BEQ.S   WZ_nch1         ;

                MOVE.W  AUD1LEN(PC),D1  ;
                ADD.W   D1,D1           ;
                MOVE.L  AUD1LC(PC),D2   ;
                ADD.L   D1,D2           ;
                MOVE.L  D2,WIZ1LC       ;
                NEG.W   D1              ;
                MOVE.W  D1,WIZ1LEN      ;

                MOVE.W  AUD1LE2(PC),D1  ;
                BMI.S   .noloop
                ADD.W   D1,D1           ;
                MOVE.L  AUD1LC2(PC),D2  ;
                ADD.L   D1,D2           ;
                MOVE.L  D2,WIZ1LC2      ;
                NEG.W   D1              ;
                MOVE.W  D1,WIZ1LE2      ;

                MOVE.L  #-1,AUD1LC2
                MOVE.W  #-1,AUD1LE2

                BRA.S   WZ_nch1

.noloop:        MOVE.L  WIZ1LC,WIZ1LC2
                MOVE.W  WIZ1LEN,WIZ1LE2

WZ_nch1:        BTST    #1,D0           ;
                BEQ.S   WZ_nch2         ;

                MOVE.W  AUD2LEN(PC),D1  ;
                ADD.W   D1,D1           ;
                MOVE.L  AUD2LC(PC),D2   ;
                ADD.L   D1,D2           ;
                MOVE.L  D2,WIZ2LC       ;
                NEG.W   D1              ;
                MOVE.W  D1,WIZ2LEN      ;

                MOVE.W  AUD2LE2(PC),D1  ;
                BMI.S   .noloopX
                ADD.W   D1,D1           ;
                MOVE.L  AUD2LC2(PC),D2  ;
                ADD.L   D1,D2           ;
                MOVE.L  D2,WIZ2LC2      ;
                NEG.W   D1              ;
                MOVE.W  D1,WIZ2LE2      ;

                MOVE.L  #-1,AUD2LC2
                MOVE.W  #-1,AUD2LE2

                BRA.S   WZ_nch2

.noloopX:       MOVE.L  WIZ2LC,WIZ2LC2
                MOVE.W  WIZ2LEN,WIZ2LE2

WZ_nch2:        BTST    #2,D0           ;
                BEQ.S   WZ_nch3         ;

                MOVE.W  AUD3LEN(PC),D1  ;
                ADD.W   D1,D1           ;
                MOVE.L  AUD3LC(PC),D2   ;
                ADD.L   D1,D2           ;
                MOVE.L  D2,WIZ3LC       ;
                NEG.W   D1              ;
                MOVE.W  D1,WIZ3LEN      ;

                MOVE.W  AUD3LE2(PC),D1  ;
                BMI.S   .noloopY
                ADD.W   D1,D1           ;
                MOVE.L  AUD3LC2(PC),D2  ;
                ADD.L   D1,D2           ;
                MOVE.L  D2,WIZ3LC2      ;
                NEG.W   D1              ;
                MOVE.W  D1,WIZ3LE2      ;

                MOVE.L  #-1,AUD3LC2
                MOVE.W  #-1,AUD3LE2

                BRA.S   WZ_nch3

.noloopY:       MOVE.L  WIZ3LC,WIZ3LC2
                MOVE.W  WIZ3LEN,WIZ3LE2


WZ_nch3:        BTST    #3,D0           ;
                BEQ.S   WZ_nch4         ;

                MOVE.W  AUD4LEN(PC),D1  ;
                ADD.W   D1,D1           ;
                MOVE.L  AUD4LC(PC),D2   ;
                ADD.L   D1,D2           ;
                MOVE.L  D2,WIZ4LC       ;
                NEG.W   D1              ;
                MOVE.W  D1,WIZ4LEN      ;


                MOVE.W  AUD4LE2(PC),D1  ;
                BMI.S   .noloopZ
                ADD.W   D1,D1           ;
                MOVE.L  AUD4LC2(PC),D2  ;
                ADD.L   D1,D2           ;
                MOVE.L  D2,WIZ4LC2      ;
                NEG.W   D1              ;
                MOVE.W  D1,WIZ4LE2      ;

                MOVE.L  #-1,AUD4LC2
                MOVE.W  #-1,AUD4LE2

                BRA.S   WZ_nch4

.noloopZ:       MOVE.L  WIZ4LC,WIZ4LC2
                MOVE.W  WIZ4LEN,WIZ4LE2

WZ_nch4:        MOVE.L  samp2(PC),D0
                MOVE.L  samp1(PC),samp2
                MOVE.L  D0,samp1

                LEA     itab(PC),A2     *   8
                LEA     vtab(PC),A4     *   12


voice1:         MOVEA.L WIZ1LC(PC),A0   *      16
                MOVEA.L WIZ1LC2(PC),A5  *    16

                MOVE.W  WIZ1LEN(PC),D1  *    12      int
                MOVE.W  WIZ1FRC(PC),D0  *    12      frac

                MOVE.W  AUD1PER(PC),D4  *    12
                ADD.W   D4,D4           *    4
                ADD.W   D4,D4           *    4
                MOVE.W  0(A2,D4.w),D3   *    14      int
                MOVE.W  2(A2,D4.w),D2   *    14      frac

                MOVE.W  AUD1VOL(PC),D4  *    12
                ASL.W   #8,D4           *    22
                LEA     0(A4,D4.w),A1   *    12

                MOVEA.L samp1(PC),A3    *    16
                MOVEQ   #0,D4           *    4       = 170

                TST.W   flag1
                BNE     nix1

                MOVEA.L A3,A4
                REPT 250
                ADD.W   D2,D0           *  4
                ADDX.W  D3,D1           *          4
                DC.W $6B0A      *  12
                MOVE.W  WIZ1LE2(PC),D1  *       12
                MOVEA.L A5,A0           *       4
                CLR.W   (A3)+           *     12
                DC.W $600A      *     12      = 56
                MOVE.B  0(A0,D1.w),D4   *      16
                MOVE.B  0(A1,D4.w),D4   *     16
                MOVE.W  D4,(A3)+        *    8       = 60
                ENDR

                REPT 250
                MOVE.W  (A4),D4
                ADD.W   D4,(A4)+
                ENDR

nix1:           MOVE.W  D1,WIZ1LEN      *    16      int
                MOVE.W  D0,WIZ1FRC      *    16      frac
                MOVE.L  A0,WIZ1LC       *    20              = 52

voice4:         MOVEA.L WIZ4LC(PC),A0   *     16
                MOVEA.L WIZ4LC2(PC),A5  *     16

                MOVE.W  WIZ4LEN(PC),D1  *    12      int
                MOVE.W  WIZ4FRC(PC),D0  *    12      frac

                MOVE.W  AUD4PER(PC),D4  *    12
                ADD.W   D4,D4           *    4
                ADD.W   D4,D4           *    4
                MOVE.W  0(A2,D4.w),D3   *    14      int
                MOVE.W  2(A2,D4.w),D2   *    14      frac

                MOVE.W  AUD4VOL(PC),D4  *    12
                ASL.W   #8,D4           *    22
                LEA     0(A4,D4.w),A1   *    12

                MOVEA.L samp1(PC),A3    *    16
                MOVEQ   #0,D4           *    4       = 170

                TST.W   flag4
                BNE     nix4

                MOVEA.L A3,A4
                REPT 250
                ADD.W   D2,D0           *   4
                ADDX.W  D3,D1           *           4
                DC.W $6B0A      *   12
                MOVE.W  WIZ4LE2(PC),D1  *        12
                MOVEA.L A5,A0           *        4
                ADDQ.W  #2,A3           *        8
                DC.W $600A      *      12      = 52
                MOVE.B  0(A0,D1.w),D4   *       16
                MOVE.B  0(A1,D4.w),D4   *       16
                ADD.W   D4,(A3)+        *    12      = 64
                ENDR

                REPT 250
                MOVE.W  (A4),D4
                ADD.W   D4,(A4)+
                ENDR

nix4:           MOVE.W  D1,WIZ4LEN      *     16      int
                MOVE.W  D0,WIZ4FRC      *     16      frac
                MOVE.L  A0,WIZ4LC       *     20              = 52

voice2:         MOVEA.L WIZ2LC(PC),A0   *       16
                MOVEA.L WIZ2LC2(PC),A5  *   16

                MOVE.W  WIZ2LEN(PC),D1  *   12      int
                MOVE.W  WIZ2FRC(PC),D0  *   12      frac

                MOVE.W  AUD2PER(PC),D4  *   12
                ADD.W   D4,D4           *   4
                ADD.W   D4,D4           *   4
                MOVE.W  0(A2,D4.w),D3   *   14      int
                MOVE.W  2(A2,D4.w),D2   *   14      frac

                MOVE.W  AUD2VOL(PC),D4  *   12
                ASL.W   #8,D4           *   22
                LEA     0(A4,D4.w),A1   *   12

                MOVEA.L samp1(PC),A3    *   16
                MOVEQ   #0,D4           *   4       = 170

                TST.W   flag2
                BNE     nix2
                REPT 250
                ADD.W   D2,D0           *  4
                ADDX.W  D3,D1           *          4
                DC.W $6B0C      *  12
                MOVE.W  WIZ2LE2(PC),D1  *        12
                MOVEA.L A5,A0           *        4
                CLR.B   (A3)            *  12
                ADDQ.W  #2,A3           *          8
                DC.W $600A      *  12      = 64
                MOVE.B  0(A0,D1.w),D4   *          16
                MOVE.B  0(A1,D4.w),(A3) *      20
                ADDQ.W  #2,A3           *      8       = 64
                ENDR

nix2:           MOVE.W  D1,WIZ2LEN      *     16      int
                MOVE.W  D0,WIZ2FRC      *     16      frac
                MOVE.L  A0,WIZ2LC       *     20              = 52

voice3:         MOVEA.L WIZ3LC(PC),A0   *      16
                MOVEA.L WIZ3LC2(PC),A5  *  16

                MOVE.W  WIZ3LEN(PC),D1  *  12      int
                MOVE.W  WIZ3FRC(PC),D0  *  12      frac

                MOVE.W  AUD3PER(PC),D4  *  12
                ADD.W   D4,D4           *  4
                ADD.W   D4,D4           *  4
                MOVE.W  0(A2,D4.w),D3   *  14      int
                MOVE.W  2(A2,D4.w),D2   *  14      frac

                MOVE.W  AUD3VOL(PC),D4  *  12
                ASL.W   #8,D4           *  22
                LEA     0(A4,D4.w),A1   *  12

                MOVEA.L samp1(PC),A3    *  16
                MOVEQ   #0,D4           *  4       = 170

                TST.W   flag3
                BNE     nix3
                REPT 250
                ADD.W   D2,D0           * 4
                ADDX.W  D3,D1           *         4
                DC.W $6B0A      *   12
                MOVE.W  WIZ3LE2(PC),D1  *     12
                MOVEA.L A5,A0           *     4
                ADDQ.W  #2,A3           *     8
                DC.W $600C      *    12      = 52
                MOVE.B  0(A0,D1.w),D4   *      16
                MOVE.B  0(A1,D4.w),D4   *      16
                ADD.B   D4,(A3)         *     12
                ADDQ.W  #2,A3           *            8       = 72
                ENDR

nix3:           MOVE.W  D1,WIZ3LEN      *    16      int
                MOVE.W  D0,WIZ3FRC      *    16      frac
                MOVE.L  A0,WIZ3LC       *    20              = 52

                MOVEM.L (SP)+,D0-D4/A0-A5
                NOT.W   $FFFF8240.w
                RTE

;-------------------- Hardware-registers & data ----------------

WIZ1LC:         DC.L sample1
WIZ1LEN:        DC.W 0
WIZ1LC2:        DC.L sample1
WIZ1LE2:        DC.W 0
WIZ1FRC:        DC.W 0

WIZ2LC:         DC.L sample1
WIZ2LEN:        DC.W 0
WIZ2LC2:        DC.L sample1
WIZ2LE2:        DC.W 0
WIZ2FRC:        DC.W 0

WIZ3LC:         DC.L sample1
WIZ3LEN:        DC.W 0
WIZ3LC2:        DC.L sample1
WIZ3LE2:        DC.W 0
WIZ3FRC:        DC.W 0

WIZ4LC:         DC.L sample1
WIZ4LEN:        DC.W 0
WIZ4LC2:        DC.L sample1
WIZ4LE2:        DC.W 0
WIZ4FRC:        DC.W 0

samp1:          DC.L sample1
samp2:          DC.L sample2

sample1:        DS.W 250
sample2:        DS.W 250


AUD1LC:         DC.L 0
AUD1LEN:        DC.W 0
AUD1PER:        DC.W 0
AUD1VOL:        DC.W 0

AUD1LC2:        DC.L -1
AUD1LE2:        DC.W -1

AUD2LC:         DC.L 0
AUD2LEN:        DC.W 0
AUD2PER:        DC.W 0
AUD2VOL:        DC.W 0

AUD2LC2:        DC.L -1
AUD2LE2:        DC.W -1

AUD3LC:         DC.L 0
AUD3LEN:        DC.W 0
AUD3PER:        DC.W 0
AUD3VOL:        DC.W 0

AUD3LC2:        DC.L -1
AUD3LE2:        DC.W -1

AUD4LC:         DC.L 0
AUD4LEN:        DC.W 0
AUD4PER:        DC.W 0
AUD4VOL:        DC.W 0

AUD4LC2:        DC.L -1
AUD4LE2:        DC.W -1

DMActrl:        DC.W 0
FILTER:         DC.W 0

;============================== EMULATOR END ==============================

***************************************************************
**  Amiga FUTURE COMPOSER V1.0 / 1.2 / 1.3   Replay routine  **
***************************************************************

                OPT O+

END_MUSIC:      CLR.W   onoff
                CLR.L   AUD1PER
                CLR.L   AUD2PER
                CLR.L   AUD3PER
                CLR.L   AUD4PER
                MOVE.W  #$0F,DMActrl
                BCLR    #1,FILTER
                RTS

INIT_MUSIC:     MOVE.W  #1,onoff
                BSET    #1,FILTER

                LEA     MODULE,A0
                LEA     100(A0),A1
                MOVE.L  A1,SEQpoint     ; Sequenz Pointer in + 100
                MOVEA.L A0,A1
                ADDA.L  8(A0),A1        ; Pattern Pointer in + 108
                MOVE.L  A1,PATpoint
                MOVEA.L A0,A1
                ADDA.L  16(A0),A1
                MOVE.L  A1,FRQpoint
                MOVEA.L A0,A1
                ADDA.L  24(A0),A1
                MOVE.L  A1,VOLpoint
                MOVE.L  4(A0),D0
                DIVU    #13,D0
                LEA     40(A0),A1

                LEA     SOUNDINFO+4(PC),A2 ; Samples eintragen
                MOVEQ   #10-1,D1
initloop:       MOVE.W  (A1)+,(A2)+
                MOVE.L  (A1)+,(A2)+
                ADDQ.W  #4,A2
                DBRA    D1,initloop

                MOVEQ   #0,D2
                MOVE.L  A0,D1
                ADD.L   32(A0),D1
                SUB.L   #WAVEFORMS,D1
                LEA     SOUNDINFO(PC),A0
                MOVE.L  D1,(A0)+
                MOVEQ   #9-1,D3
initloop1:
                MOVE.W  (A0),D2
                ADD.L   D2,D1
                ADD.L   D2,D1
                ADDQ.W  #6,A0
                MOVE.L  D1,(A0)+
                DBRA    D3,initloop1

                MOVEA.L SEQpoint(PC),A0
                MOVEQ   #0,D2
                MOVE.B  12(A0),D2       ;Get replay speed
                BNE.S   speedok
                MOVE.B  #3,D2           ;Set default speed

speedok:        MOVE.W  D2,respcnt      ;Init repspeed counter
                MOVE.W  D2,repspd

INIT2:          CLR.W   audtemp
                MOVE.W  #$0F,DMActrl    ;Disable audio DMA
                MOVEQ   #0,D7
                MULU    #13,D0
                MOVEQ   #4-1,D6         ;Number of soundchannels-1
                LEA     V1data(PC),A0   ;Point to 1st voice data area
                LEA     SILENT(PC),A1   ;silent(PC),A1
                LEA     o4a0c8(PC),A2

initloop2:      MOVE.L  A1,10(A0)
                MOVE.L  A1,18(A0)
                CLR.L   14(A0)
                CLR.B   45(A0)
                CLR.B   47(A0)
                CLR.W   8(A0)
                CLR.L   48(A0)
                MOVE.B  #$01,23(A0)
                MOVE.B  #$01,24(A0)
                CLR.B   25(A0)
                CLR.L   26(A0)
                CLR.W   30(A0)
                MOVEQ   #$00,D3
                MOVE.W  (A2)+,D1
                MOVE.W  (A2)+,D3
                DIVU    #$03,D3
                MOVE.B  D3,32(A0)
                MULU    #$03,D3
                AND.L   #$FF,D3
                AND.L   #$FF,D1
                ADD.L   #AUD1LC,D1
                MOVEA.L D1,A6
                MOVE.L  #$00,(A6)
                MOVE.W  #$0100,4(A6)
                MOVE.W  #$00,6(A6)
                MOVE.W  #$00,8(A6)
                MOVE.L  D1,60(A0)
                CLR.W   64(A0)
                MOVE.L  SEQpoint(PC),(A0)
                MOVE.L  SEQpoint(PC),52(A0)
                ADD.L   D0,52(A0)
                ADD.L   D3,52(A0)
                ADD.L   D7,(A0)
                ADD.L   D3,(A0)
                MOVE.W  #$0D,6(A0)
                MOVEA.L (A0),A3
                MOVE.B  (A3),D1
                AND.L   #$FF,D1
                LSL.W   #6,D1
                MOVEA.L PATpoint(PC),A4
                ADDA.W  D1,A4
                MOVE.L  A4,34(A0)
                CLR.L   38(A0)
                MOVE.B  #$01,33(A0)
                MOVE.B  #$02,42(A0)
                MOVE.B  1(A3),44(A0)
                MOVE.B  2(A3),22(A0)
                CLR.B   43(A0)
                CLR.B   45(A0)
                CLR.W   56(A0)
                ADDA.W  #$4A,A0         ;Point to next voice's data area
                DBRA    D6,initloop2
                RTS


PLAY:           LEA     pervol(PC),A6
                TST.W   onoff
                BNE.S   music_on
                RTS

music_on:       SUBQ.W  #1,respcnt      ;Decrease replayspeed counter
                BNE.S   nonewnote
                MOVE.W  repspd(PC),respcnt ;Restore replayspeed counter

                TST.W   flag1
                BNE.S   c2
                LEA     V1data(PC),A0   ;Point to voice1 data area
                BSR     NEW_NOTE
c2:             TST.W   flag2
                BNE.S   c3
                LEA     V2data(PC),A0   ;Point to voice2 data area
                BSR     NEW_NOTE
c3:             TST.W   flag3
                BNE.S   c4
                LEA     V3data(PC),A0   ;Point to voice3 data area
                BSR     NEW_NOTE
c4:             TST.W   flag4
                BNE.S   nonewnote

                LEA     V4data(PC),A0   ;Point to voice4 data area
                BSR     NEW_NOTE

nonewnote:      CLR.W   audtemp

                TST.W   flag1
                BNE.S   ch2

                LEA     V1data(PC),A0
                BSR     EFFECTS
                MOVE.W  D0,(A6)+
                MOVE.W  D1,(A6)+

ch2:            TST.W   flag2
                BNE.S   ch3

                LEA     V2data(PC),A0
                BSR     EFFECTS
                MOVE.W  D0,(A6)+
                MOVE.W  D1,(A6)+

ch3:            TST.W   flag3
                BNE.S   ch4

                LEA     V3data(PC),A0
                BSR     EFFECTS
                MOVE.W  D0,(A6)+
                MOVE.W  D1,(A6)+

ch4:            TST.W   flag4
                BNE.S   fin

                LEA     V4data(PC),A0
                BSR     EFFECTS
                MOVE.W  D0,(A6)+
                MOVE.W  D1,(A6)+

fin:            LEA     pervol(PC),A6
                MOVE.W  audtemp(PC),D0
                OR.W    #$8000,D0       ;Set/clr bit = 1
                MOVE.W  D0,-(SP)

                MOVEQ   #0,D1
                MOVE.L  start1(PC),D2   ;Get samplepointers
                MOVE.W  offset1(PC),D1  ;Get offset
                ADD.L   D1,D2           ;Add offset
                MOVE.L  start2(PC),D3
                MOVE.W  offset2(PC),D1
                ADD.L   D1,D3
                MOVE.L  start3(PC),D4
                MOVE.W  offset3(PC),D1
                ADD.L   D1,D4
                MOVE.L  start4(PC),D5
                MOVE.W  offset4(PC),D1
                ADD.L   D1,D5

                MOVE.W  ssize1(PC),D0   ;Get sound lengths
                MOVE.W  ssize2(PC),D1
                MOVE.W  ssize3(PC),D6
                MOVE.W  ssize4(PC),D7
                MOVE.W  (SP)+,DMActrl   ;Enable audio DMA

chan1:          TST.W   flag1
                BNE.S   chan2

                LEA     V1data(PC),A0
                TST.W   72(A0)
                BEQ.S   chan2
                SUBQ.W  #1,72(A0)
                CMPI.W  #1,72(A0)
                BNE.S   chan2
                CLR.W   72(A0)
                MOVE.L  D2,AUD1LC       ;Set soundstart
                MOVE.W  D0,AUD1LEN      ;Set soundlength

chan2:          TST.W   flag2
                BNE.S   chan3

                LEA     V2data(PC),A0
                TST.W   72(A0)
                BEQ.S   chan3
                SUBQ.W  #1,72(A0)
                CMPI.W  #1,72(A0)
                BNE.S   chan3
                CLR.W   72(A0)
                MOVE.L  D3,AUD2LC
                MOVE.W  D1,AUD2LEN

chan3:          TST.W   flag3
                BNE.S   chan4

                LEA     V3data(PC),A0
                TST.W   72(A0)
                BEQ.S   chan4
                SUBQ.W  #1,72(A0)
                CMPI.W  #1,72(A0)
                BNE.S   chan4
                CLR.W   72(A0)
                MOVE.L  D4,AUD3LC
                MOVE.W  D6,AUD3LEN

chan4:          TST.W   flag4
                BNE.S   setpervol

                LEA     V4data(PC),A0
                TST.W   72(A0)
                BEQ.S   setpervol
                SUBQ.W  #1,72(A0)
                CMPI.W  #1,72(A0)
                BNE.S   setpervol
                CLR.W   72(A0)
                MOVE.L  D5,AUD4LC
                MOVE.W  D7,AUD4LEN


setpervol:      LEA     AUD1PER,A5
                MOVE.W  (A6)+,(A5)      ;Set period
                MOVE.W  (A6)+,2(A5)     ;Set volume
                MOVE.W  (A6)+,16(A5)
                MOVE.W  (A6)+,18(A5)
                MOVE.W  (A6)+,32(A5)
                MOVE.W  (A6)+,34(A5)
                MOVE.W  (A6)+,48(A5)
                MOVE.W  (A6)+,50(A5)
                RTS


NEW_NOTE:       MOVEQ   #0,D5
                MOVEA.L 34(A0),A1
                ADDA.W  40(A0),A1
                CMPI.W  #64,40(A0)
                BNE.S   samepat
                MOVEA.L (A0),A2
                ADDA.W  6(A0),A2        ;Point to next sequence row
                CMPA.L  52(A0),A2       ;Is it the end?
                BNE.S   notend
                MOVE.W  D5,6(A0)        ;yes!
                MOVEA.L (A0),A2         ;Point to first sequence

notend:         MOVEQ   #0,D1
                ADDQ.B  #1,spdtemp
                CMPI.B  #4,spdtemp
                BNE.S   nonewspd
                MOVE.B  D5,spdtemp
                MOVE.B  -1(A1),D1       ;Get new replay speed
                BEQ.S   nonewspd
                MOVE.W  D1,respcnt      ;store in counter
                MOVE.W  D1,repspd

nonewspd:       MOVE.B  (A2),D1         ;Pattern to play
                MOVE.B  1(A2),44(A0)    ;Transpose value
                MOVE.B  2(A2),22(A0)    ;Soundtranspose value

                MOVE.W  D5,40(A0)
                LSL.W   #6,D1
                ADD.L   PATpoint(PC),D1 ;Get pattern pointer
                MOVE.L  D1,34(A0)
                ADDI.W  #$0D,6(A0)
                MOVEA.L D1,A1

samepat:        MOVE.B  1(A1),D1        ;Get info byte
                MOVE.B  (A1)+,D0        ;Get note
                BNE.S   ww1
                AND.W   #%11000000,D1
                BEQ.S   noport
                BRA.S   ww11

ww1:            MOVE.W  D5,56(A0)
ww11:           MOVE.B  D5,47(A0)
                MOVE.B  (A1),31(A0)

;31(a0) = PORTAMENTO/INSTR. info
;Bit 7 = portamento on
;Bit 6 = portamento off
;Bit 5-0 = instrument number

;47(a0) = portamento value
;Bit 7-5 = always zero
;Bit 4 = up/down
;Bit 3-0 = value

t_porton:       BTST    #7,D1
                BEQ.S   noport
                MOVE.B  2(A1),47(A0)

noport:         AND.W   #$7F,D0
                BEQ.S   nxtnote
                MOVE.B  D0,8(A0)
                MOVE.B  (A1),9(A0)
                MOVE.B  32(A0),D2
                MOVEQ   #0,D3
                BSET    D2,D3
                OR.W    D3,audtemp
                MOVE.W  D3,DMActrl
                MOVE.B  (A1),D1
                AND.W   #$3F,D1         ;Max 64 instruments
                ADD.B   22(A0),D1
                MOVEA.L VOLpoint(PC),A2
                LSL.W   #6,D1
                ADDA.W  D1,A2
                MOVE.W  D5,16(A0)
                MOVE.B  (A2),23(A0)
                MOVE.B  (A2)+,24(A0)
                MOVE.B  (A2)+,D1
                AND.W   #$FF,D1
                MOVE.B  (A2)+,27(A0)
                MOVE.B  #$40,46(A0)
                MOVE.B  (A2)+,D0
                MOVE.B  D0,28(A0)
                MOVE.B  D0,29(A0)
                MOVE.B  (A2)+,30(A0)
                MOVE.L  A2,10(A0)
                MOVEA.L FRQpoint(PC),A2
                LSL.W   #6,D1
                ADDA.W  D1,A2
                MOVE.L  A2,18(A0)
                MOVE.W  D5,50(A0)
                MOVE.B  D5,26(A0)
                MOVE.B  D5,25(A0)
nxtnote:        ADDQ.W  #2,40(A0)
                RTS

EFFECTS:        MOVEQ   #0,D7

testsustain:    TST.B   26(A0)          ;Is sustain counter = 0
                BEQ.S   sustzero
                SUBQ.B  #1,26(A0)       ;if no, decrease counter
                BRA     VOLUfx
sustzero:                               ;Next part of effect sequence
                MOVEA.L 18(A0),A1       ;can be executed now.
                ADDA.W  50(A0),A1

testeffects:    CMPI.B  #$E1,(A1)       ;E1 = end of FREQseq sequence
                BEQ     VOLUfx
                CMPI.B  #$E0,(A1)       ;E0 = loop to other part of sequence
                BNE.S   testnewsound
                MOVE.B  1(A1),D0        ;loop to start of sequence + 1(a1)
                AND.W   #$3F,D0
                MOVE.W  D0,50(A0)
                MOVEA.L 18(A0),A1
                ADDA.W  D0,A1

testnewsound:   CMPI.B  #$E2,(A1)       ;E2 = set waveform
                BNE.S   o49c64
                MOVEQ   #0,D0
                MOVEQ   #0,D1
                MOVE.B  32(A0),D1
                BSET    D1,D0
                OR.W    D0,audtemp
                MOVE.W  D0,DMActrl
                MOVE.B  1(A1),D0        ; Instrument Number
                AND.W   #$FF,D0         ;
                LEA     SOUNDINFO(PC),A4
                ADD.W   D0,D0
                MOVE.W  D0,D1
                ADD.W   D1,D1
                ADD.W   D1,D1
                ADD.W   D1,D0
                ADDA.W  D0,A4
                MOVEA.L 60(A0),A3
                MOVE.L  (A4),D1
                ADD.L   #WAVEFORMS,D1
                MOVE.L  D1,(A3)
                MOVE.L  D1,68(A0)
                MOVE.W  4(A4),4(A3)
                MOVE.L  6(A4),64(A0)
                SWAP    D1
                MOVE.W  #$03,72(A0)
                TST.W   D1
                BNE.S   o49c52
                MOVE.W  #$02,72(A0)

o49c52:         CLR.W   16(A0)
                MOVE.B  #$01,23(A0)
                ADDQ.W  #2,50(A0)
                BRA     o49d02

o49c64:         CMPI.B  #$E4,(A1)
                BNE.S   testpatjmp
                MOVE.B  1(A1),D0
                AND.W   #$FF,D0
                LEA     SOUNDINFO(PC),A4
                ADD.W   D0,D0
                MOVE.W  D0,D1
                ADD.W   D1,D1
                ADD.W   D1,D1
                ADD.W   D1,D0
                ADDA.W  D0,A4
                MOVEA.L 60(A0),A3
                MOVE.L  (A4),D1
                ADD.L   #WAVEFORMS,D1
                MOVE.L  D1,(A3)
                MOVE.L  D1,68(A0)
                MOVE.W  4(A4),4(A3)
                MOVE.L  6(A4),64(A0)

                SWAP    D1
                MOVE.W  #$03,72(A0)
                TST.W   D1
                BNE.S   o49cae
                MOVE.W  #$02,72(A0)

o49cae:         ADDQ.W  #2,50(A0)
                BRA.S   o49d02

testpatjmp:     CMPI.B  #$E7,(A1)
                BNE.S   testnewsustain
                MOVE.B  1(A1),D0
                AND.W   #$FF,D0
                LSL.W   #6,D0
                MOVEA.L FRQpoint(PC),A1
                ADDA.W  D0,A1
                MOVE.L  A1,18(A0)
                MOVE.W  D7,50(A0)
                BRA     testeffects

testnewsustain: CMPI.B  #$E8,(A1)       ;E8 = set sustain time
                BNE.S   o49cea
                MOVE.B  1(A1),26(A0)
                ADDQ.W  #2,50(A0)
                BRA     testsustain

o49cea:         CMPI.B  #$E3,(A1)
                BNE.S   o49d02
                ADDQ.W  #3,50(A0)
                MOVE.B  1(A1),27(A0)
                MOVE.B  2(A1),28(A0)

o49d02:         MOVEA.L 18(A0),A1
                ADDA.W  50(A0),A1
                MOVE.B  (A1),43(A0)
                ADDQ.W  #1,50(A0)

VOLUfx:         TST.B   25(A0)
                BEQ.S   o49d1e
                SUBQ.B  #1,25(A0)
                BRA.S   o49d70

o49d1e:         SUBQ.B  #1,23(A0)
                BNE.S   o49d70
                MOVE.B  24(A0),23(A0)

o49d2a:         MOVEA.L 10(A0),A1
                ADDA.W  16(A0),A1
                MOVE.B  (A1),D0
                CMP.B   #$E8,D0
                BNE.S   o49d4a
                ADDQ.W  #2,16(A0)
                MOVE.B  1(A1),25(A0)
                BRA.S   VOLUfx

o49d4a:         CMP.B   #$E1,D0
                BEQ.S   o49d70
                CMP.B   #$E0,D0
                BNE.S   o49d68
                MOVE.B  1(A1),D0
                AND.L   #$3F,D0
                SUBQ.B  #5,D0
                MOVE.W  D0,16(A0)
                BRA.S   o49d2a

o49d68:         MOVE.B  (A1),45(A0)
                ADDQ.W  #1,16(A0)

o49d70:         MOVE.B  43(A0),D0
                BMI.S   o49d7e
                ADD.B   8(A0),D0
                ADD.B   44(A0),D0

o49d7e:         AND.W   #$7F,D0
                LEA     PERIODS(PC),A1
                ADD.W   D0,D0
                MOVE.W  D0,D1
                ADDA.W  D0,A1
                MOVE.W  (A1),D0
                MOVE.B  46(A0),D7
                TST.B   30(A0)
                BEQ.S   o49d9e
                SUBQ.B  #1,30(A0)

                BRA.S   o49df4

o49d9e:         MOVE.B  D1,D5
                MOVE.B  28(A0),D4
                ADD.B   D4,D4
                MOVE.B  29(A0),D1
                TST.B   D7
                BPL.S   o49db4
                BTST    #0,D7
                BNE.S   o49dda

o49db4:         BTST    #5,D7
                BNE.S   o49dc8
                SUB.B   27(A0),D1
                BCC.S   o49dd6
                BSET    #5,D7
                MOVEQ   #0,D1
                BRA.S   o49dd6

o49dc8:         ADD.B   27(A0),D1
                CMP.B   D4,D1
                BCS.S   o49dd6
                BCLR    #5,D7
                MOVE.B  D4,D1

o49dd6:         MOVE.B  D1,29(A0)

o49dda:         LSR.B   #1,D4
                SUB.B   D4,D1
                BCC.S   o49de4
                SUB.W   #$0100,D1

o49de4:         ADD.B   #$A0,D5
                BCS.S   o49df2

o49dea:         ADD.W   D1,D1
                ADD.B   #$18,D5
                BCC.S   o49dea

o49df2:         ADD.W   D1,D0

o49df4:         EORI.B  #$01,D7
                MOVE.B  D7,46(A0)

; DO THE PORTAMENTO THING
                MOVEQ   #0,D1
                MOVE.B  47(A0),D1       ;get portavalue
                BEQ.S   a56d0           ;0=no portamento
                CMP.B   #$1F,D1
                BLS.S   portaup

portadown:      AND.W   #$1F,D1
                NEG.W   D1
portaup:        SUB.W   D1,56(A0)
a56d0:          ADD.W   56(A0),D0
o49e3e:         CMP.W   #$70,D0
                BHI.S   nn1
                MOVE.W  #$71,D0
nn1:            CMP.W   #$06B0,D0
                BLS.S   nn2
                MOVE.W  #$06B0,D0
nn2:            MOVEQ   #0,D1
                MOVE.B  45(A0),D1
                RTS



pervol:         DS.B 16         ;Periods & Volumes temp. store
respcnt:        DC.W 0          ;Replay speed counter
repspd:         DC.W 0          ;Replay speed counter temp
onoff:          DC.W 0          ;Music on/off flag.
firseq:         DC.W 0          ;First sequence
lasseq:         DC.W 0          ;Last sequence
audtemp:        DC.W 0
spdtemp:        DC.W 0

V1data:         DS.B 64         ;Voice 1 data area
offset1:        DS.B 2          ;Is added to start of sound
ssize1:         DS.B 2          ;Length of sound
start1:         DS.B 6          ;Start of sound

V2data:         DS.B 64         ;Voice 2 data area
offset2:        DS.B 2
ssize2:         DS.B 2
start2:         DS.B 6

V3data:         DS.B 64         ;Voice 3 data area
offset3:        DS.B 2
ssize3:         DS.B 2
start3:         DS.B 6

V4data:         DS.B 64         ;Voice 4 data area
offset4:        DS.B 2
ssize4:         DS.B 2
start4:         DS.B 6

o4a0c8:         DC.L $00,$100003,$200006,$300009
SEQpoint:       DC.L 0
PATpoint:       DC.L 0
FRQpoint:       DC.L 0
VOLpoint:       DC.L 0

                EVEN

SILENT:         DC.W $0100,$00,$00,$E1

PERIODS:        DC.W $06B0,$0650,$05F4,$05A0,$054C,$0500,$04B8,$0474
                DC.W $0434,$03F8,$03C0,$038A,$0358,$0328,$02FA,$02D0
                DC.W $02A6,$0280,$025C,$023A,$021A,$01FC,$01E0,$01C5
                DC.W $01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D
                DC.W $010D,$FE,$F0,$E2,$D6,$CA,$BE,$B4
                DC.W $AA,$A0,$97,$8F,$87,$7F,$78,$71
                DC.W $71,$71,$71,$71,$71,$71,$71,$71
                DC.W $71,$71,$71,$71,$0D60,$0CA0,$0BE8,$0B40
                DC.W $0A98,$0A00,$0970,$08E8,$0868,$07F0,$0780,$0714
                DC.W $1AC0,$1940,$17D0,$1680,$1530,$1400,$12E0,$11D0
                DC.W $10D0,$0FE0,$0F00,$0E28

SOUNDINFO:
;Offset.l , Sound-length.w , Start-offset.w , Repeat-length.w

;Reserved for samples
                DC.W $00,$00,$00,$00,$01
                DC.W $00,$00,$00,$00,$01
                DC.W $00,$00,$00,$00,$01
                DC.W $00,$00,$00,$00,$01
                DC.W $00,$00,$00,$00,$01
                DC.W $00,$00,$00,$00,$01
                DC.W $00,$00,$00,$00,$01
                DC.W $00,$00,$00,$00,$01
                DC.W $00,$00,$00,$00,$01
                DC.W $00,$00,$00,$00,$01
;Reserved for synth sounds
                DC.W $00,$00,$10,$00,$10
                DC.W $00,$20,$10,$00,$10
                DC.W $00,$40,$10,$00,$10
                DC.W $00,$60,$10,$00,$10
                DC.W $00,$80,$10,$00,$10
                DC.W $00,$A0,$10,$00,$10
                DC.W $00,$C0,$10,$00,$10
                DC.W $00,$E0,$10,$00,$10
                DC.W $00,$0100,$10,$00,$10
                DC.W $00,$0120,$10,$00,$10
                DC.W $00,$0140,$10,$00,$10
                DC.W $00,$0160,$10,$00,$10
                DC.W $00,$0180,$10,$00,$10
                DC.W $00,$01A0,$10,$00,$10
                DC.W $00,$01C0,$10,$00,$10
                DC.W $00,$01E0,$10,$00,$10
                DC.W $00,$0200,$10,$00,$10
                DC.W $00,$0220,$10,$00,$10
                DC.W $00,$0240,$10,$00,$10
                DC.W $00,$0260,$10,$00,$10
                DC.W $00,$0280,$10,$00,$10
                DC.W $00,$02A0,$10,$00,$10
                DC.W $00,$02C0,$10,$00,$10
                DC.W $00,$02E0,$10,$00,$10
                DC.W $00,$0300,$10,$00,$10
                DC.W $00,$0320,$10,$00,$10
                DC.W $00,$0340,$10,$00,$10
                DC.W $00,$0360,$10,$00,$10
                DC.W $00,$0380,$10,$00,$10
                DC.W $00,$03A0,$10,$00,$10
                DC.W $00,$03C0,$10,$00,$10
                DC.W $00,$03E0,$10,$00,$10
                DC.W $00,$0400,$08,$00,$08
                DC.W $00,$0410,$08,$00,$08
                DC.W $00,$0420,$08,$00,$08
                DC.W $00,$0430,$08,$00,$08
                DC.W $00,$0440,$08,$00,$08
                DC.W $00,$0450,$08,$00,$08
                DC.W $00,$0460,$08,$00,$08
                DC.W $00,$0470,$08,$00,$08
                DC.W $00,$0480,$10,$00,$10
                DC.W $00,$04A0,$08,$00,$08
                DC.W $00,$04B0,$10,$00,$10
                DC.W $00,$04D0,$10,$00,$10
                DC.W $00,$04F0,$08,$00,$08
                DC.W $00,$0500,$08,$00,$08
                DC.W $00,$0510,$18,$00,$18


WAVEFORMS:      DC.W $C0C0,$D0D8,$E0E8,$F0F8,$F8,$F0E8,$E0D8,$D0C8
                DC.W $3F37,$2F27,$1F17,$0F07,$FF07,$0F17,$1F27,$2F37
                DC.W $C0C0,$D0D8,$E0E8,$F0F8,$F8,$F0E8,$E0D8,$D0C8
                DC.W $C037,$2F27,$1F17,$0F07,$FF07,$0F17,$1F27,$2F37
                DC.W $C0C0,$D0D8,$E0E8,$F0F8,$F8,$F0E8,$E0D8,$D0C8
                DC.W $C0B8,$2F27,$1F17,$0F07,$FF07,$0F17,$1F27,$2F37
                DC.W $C0C0,$D0D8,$E0E8,$F0F8,$F8,$F0E8,$E0D8,$D0C8
                DC.W $C0B8,$B027,$1F17,$0F07,$FF07,$0F17,$1F27,$2F37
                DC.W $C0C0,$D0D8,$E0E8,$F0F8,$F8,$F0E8,$E0D8,$D0C8
                DC.W $C0B8,$B0A8,$1F17,$0F07,$FF07,$0F17,$1F27,$2F37
                DC.W $C0C0,$D0D8,$E0E8,$F0F8,$F8,$F0E8,$E0D8,$D0C8
                DC.W $C0B8,$B0A8,$A017,$0F07,$FF07,$0F17,$1F27,$2F37
                DC.W $C0C0,$D0D8,$E0E8,$F0F8,$F8,$F0E8,$E0D8,$D0C8
                DC.W $C0B8,$B0A8,$A098,$0F07,$FF07,$0F17,$1F27,$2F37
                DC.W $C0C0,$D0D8,$E0E8,$F0F8,$F8,$F0E8,$E0D8,$D0C8
                DC.W $C0B8,$B0A8,$A098,$9007,$FF07,$0F17,$1F27,$2F37
                DC.W $C0C0,$D0D8,$E0E8,$F0F8,$F8,$F0E8,$E0D8,$D0C8
                DC.W $C0B8,$B0A8,$A098,$9088,$FF07,$0F17,$1F27,$2F37
                DC.W $C0C0,$D0D8,$E0E8,$F0F8,$F8,$F0E8,$E0D8,$D0C8
                DC.W $C0B8,$B0A8,$A098,$9088,$8007,$0F17,$1F27,$2F37
                DC.W $C0C0,$D0D8,$E0E8,$F0F8,$F8,$F0E8,$E0D8,$D0C8
                DC.W $C0B8,$B0A8,$A098,$9088,$8088,$0F17,$1F27,$2F37
                DC.W $C0C0,$D0D8,$E0E8,$F0F8,$F8,$F0E8,$E0D8,$D0C8
                DC.W $C0B8,$B0A8,$A098,$9088,$8088,$9017,$1F27,$2F37
                DC.W $C0C0,$D0D8,$E0E8,$F0F8,$F8,$F0E8,$E0D8,$D0C8
                DC.W $C0B8,$B0A8,$A098,$9088,$8088,$9098,$1F27,$2F37
                DC.W $C0C0,$D0D8,$E0E8,$F0F8,$F8,$F0E8,$E0D8,$D0C8
                DC.W $C0B8,$B0A8,$A098,$9088,$8088,$9098,$A027,$2F37
                DC.W $C0C0,$D0D8,$E0E8,$F0F8,$F8,$F0E8,$E0D8,$D0C8
                DC.W $C0B8,$B0A8,$A098,$9088,$8088,$9098,$A0A8,$2F37
                DC.W $C0C0,$D0D8,$E0E8,$F0F8,$F8,$F0E8,$E0D8,$D0C8
                DC.W $C0B8,$B0A8,$A098,$9088,$8088,$9098,$A0A8,$B037
                DC.W $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                DC.W $7F7F,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F
                DC.W $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                DC.W $817F,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F
                DC.W $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                DC.W $8181,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F
                DC.W $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                DC.W $8181,$817F,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F
                DC.W $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                DC.W $8181,$8181,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F
                DC.W $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                DC.W $8181,$8181,$817F,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F
                DC.W $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                DC.W $8181,$8181,$8181,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F
                DC.W $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                DC.W $8181,$8181,$8181,$817F,$7F7F,$7F7F,$7F7F,$7F7F
                DC.W $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                DC.W $8181,$8181,$8181,$8181,$7F7F,$7F7F,$7F7F,$7F7F
                DC.W $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                DC.W $8181,$8181,$8181,$8181,$817F,$7F7F,$7F7F,$7F7F
                DC.W $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                DC.W $8181,$8181,$8181,$8181,$8181,$7F7F,$7F7F,$7F7F
                DC.W $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                DC.W $8181,$8181,$8181,$8181,$8181,$817F,$7F7F,$7F7F
                DC.W $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                DC.W $8181,$8181,$8181,$8181,$8181,$8181,$7F7F,$7F7F
                DC.W $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
                DC.W $8181,$8181,$8181,$8181,$8181,$8181,$817F,$7F7F
                DC.W $8080,$8080,$8080,$8080,$8080,$8080,$8080,$8080
                DC.W $8080,$8080,$8080,$8080,$8080,$8080,$8080,$7F7F
                DC.W $8080,$8080,$8080,$8080,$8080,$8080,$8080,$8080
                DC.W $8080,$8080,$8080,$8080,$8080,$8080,$8080,$807F
                DC.W $8080,$8080,$8080,$8080,$7F7F,$7F7F,$7F7F,$7F7F
                DC.W $8080,$8080,$8080,$807F,$7F7F,$7F7F,$7F7F,$7F7F
                DC.W $8080,$8080,$8080,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F
                DC.W $8080,$8080,$807F,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F
                DC.W $8080,$8080,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F
                DC.W $8080,$807F,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F
                DC.W $8080,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F
                DC.W $8080,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F,$7F7F
                DC.W $8080,$9098,$A0A8,$B0B8,$C0C8,$D0D8,$E0E8,$F0F8
                DC.W $08,$1018,$2028,$3038,$4048,$5058,$6068,$707F
                DC.W $8080,$A0B0,$C0D0,$E0F0,$10,$2030,$4050,$6070
                DC.W $4545,$797D,$7A77,$7066,$6158,$534D,$2C20,$1812
                DC.W $04DB,$D3CD,$C6BC,$B5AE,$A8A3,$9D99,$938E,$8B8A
                DC.W $4545,$797D,$7A77,$7066,$5B4B,$4337,$2C20,$1812
                DC.W $04F8,$E8DB,$CFC6,$BEB0,$A8A4,$9E9A,$9594,$8D83
                DC.W $00,$4060,$7F60,$4020,$E0,$C0A0,$80A0,$C0E0
                DC.W $00,$4060,$7F60,$4020,$E0,$C0A0,$80A0,$C0E0
                DC.W $8080,$9098,$A0A8,$B0B8,$C0C8,$D0D8,$E0E8,$F0F8
                DC.W $08,$1018,$2028,$3038,$4048,$5058,$6068,$707F
                DC.W $8080,$A0B0,$C0D0,$E0F0,$10,$2030,$4050,$6070
                EVEN
                PATH 'D:\FUTCOMP.FUT\'
MODULE:         IBYTES 'FC19.FUT'
                EVEN
                PATH 'D:\'
song:           IBYTES '*.TRI'
vset:           IBYTES 'SONG_DMA.TVS'
                EVEN
                PATH 'D:\SIDSOUND.V25\'
s:              IBYTES 'PLAY_3_1.BIN'
                END
