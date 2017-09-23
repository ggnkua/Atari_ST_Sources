;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
;**************************************************************************
;
;   ADPCMNS.ASM       Full-Duplex 32-kbit/s Nonstandard CCITT ADPCM
;
; Version 1.0 - 8/9/90
;
; This program implements the algorithm defined in CCITT Recommendation
; G.721: "32 kbit/s Adaptive Differential Pulse Code Modulation" dated
; August 1986.  This code contains a real-time I/O interface for a
; hardware platform consisting of two DSP56000ADS boards, each connected
; to an MC145503 codec.
;
; Please refer to the file ADPCMNS.HLP for further information about
; this program.  Also refer to Motorola Application Report APR9/D for
; complete documentation.
;
;**************************************************************************

            OPT     CC,CEX
                                                                         
START       EQU     $0020
PBDDR       EQU     $FFE2
PBD         EQU     $FFE4
PCC         EQU     $FFE1
CRA         EQU     $FFEC
CRB         EQU     $FFED
SSISR       EQU     $FFEE
SSIRX       EQU     $FFEF
SSITX       EQU     $FFEF
BCR         EQU     $FFFE

            ORG     X:$0000

;******************** Encoder variables ***********************************
;   I = siii 0000 | 0000 0000 | 0000 0000 (ADPCM format)
I_T         DS      1               ;ADPCM codeword
;   DQ = siii iiii | iiii iii.f | ffff ffff  (24SM)
DQ_T        DS      1               ;Quantized difference signal
;   Y = 0iii i.fff | ffff ffff | ffff ffff  (23SM)
Y_T         DS      1               ;Quantizer scale factor
;   AP = 0ii.f ffff | ffff ffff | ffff ffff  (23SM)
AP_T        DS      1               ;Unlimited speed control parameter
;   AL = 0i.ff ffff | ffff ffff | ffff ffff  (23SM)
AL_T        DS      1               ;Limited speed control parameter

;******************** Decoder variables ***********************************
I_R         DS      1               ;ADPCM codeword
DQ_R        DS      1               ;Quantized difference signal
Y_R         DS      1               ;Quantizer scale factor
AP_R        DS      1               ;Unlimited speed control parameter
AL_R        DS      1               ;Limited speed control parameter

;******************** Temporary variables *********************************
;   IMAG = 0000 0000 | 0000 0000 | 0000 0iii.
IMAG        DS      1               ;|I|
;   PKS1 = sXXX XXXX | XXXX XXXX | XXXX XXXX  (1TC)
PKS1        DS      1               ;XOR of  PK0 & PK1
;   PKS2 = sXXX XXXX | XXXX XXXX | XXXX XXXX  (1TC)
PKS2        DS      1               ;XOR of  PK0 & PK2
DATAPTR_T   DS      1               ;Transmit data buffer pointer
DATAPTR_R   DS      1               ;Receive data buffer pointer

;******************** Table for quantizing DLN ****************************
; Used in QUAN routine

QUANTAB     DS      8

;******************** Table for unquantizing I ****************************
; Used in RECONST

IQUANTAB    DS      8

;******************** W(I) lookup table ***********************************
; Used in FUNCTW routine

WIBASE      DS      8

;******************** F(I) lookup table ***********************************
; Used in FUNCTF routine

FIBASE      DS      8

;******************** Table used in COMPRESS ******************************

TAB         DS      8

;******************** Encoder data buffer *********************************
;   DQ = siii iiii | iiii iiii. | ffff ffff  (24TC)
;   SRn in same format

DATA_T      DSM     8                   ;8 word modulo buffer for data,
                                        ; R2 is used as pointer, DATAPTR_T
                                        ; points to start of buffer (DQ1)
                                        ; at beginning of cycle

;******************** Decoder data buffer *********************************

DATA_R      DSM     8                   ;8 word modulo buffer for data
                                        ; (same format as DATA_T)


            ORG     Y:$0000
;******************** Encoder variables ***********************************
;   SE = siii iiii | iiii iiii. | ffff ffff  (24TC)
SE_T        DS      1               ;Signal estimate
;   SEZ = siii iiii | iiii iiii. | ffff ffff (24TC)
SEZ_T       DS      1               ;Partial signal estimate
;   SR = siii iiii | iiii iiii. | ffff ffff  (24TC)
SR_T        DS      1               ;Reconstructed signal
;   PK0 = sXXX XXXX | XXXX XXXX | XXXX XXXX  (1TC)
PK0_T       DS      1               ;Sign of DQ + SEZ
;   PK1 = sXXX XXXX | XXXX XXXX | XXXX XXXX  (1TC)
PK1_T       DS      1               ;Delayed sign of DQ + SEZ
;   DMS = 0iii. ffff | ffff ffff | ffff ffff  (23SM)
DMS_T       DS      1               ;Short term average of F(I)
;   DML = 0iii. ffff | ffff ffff | ffff ffff  (23SM)
DML_T       DS      1               ;Long term average of F(I)
;   TDP = i000 0000 | 0000 0000 | 0000 0000  (1TC)
TDP_T       DS      1               ;Tone detect
;   TD = i000 0000 | 0000 0000 | 0000 0000  (1TC)
TD_T        DS      1               ;Delayed tone detect
;   YU =  0iii i.fff | ffff ffff | ffff ffff  (23SM)
YU_T        DS      1               ;Fast quantizer scale factor
;   YL =  0iii i.fff | ffff ffff | ffff ffff  (23SM)
YL_T        DS      1               ;Slow quantizer scale factor
;   SIGPK = i000 0000 | 0000 0000 | 0000 0000  (1TC)
SIGPK_T     DS      1               ;Sgn[p(k)] flag
;   A2P = si.ff ffff | ffff ffff | ffff ffff (24TC)
A2P_T       DS      1               ;Second order predictor coef
;   TR = i000 0000 | 0000 0000 | 0000 0000  (1TC)
TR_T        DS      1               ;Transition detect
;   S = psss qqqq | 0000 0000 | 0000 0000 (PCM log format)
S_T         DS      1               ;Input PCM signal

;******************** Decoder variables ***********************************
SE_R        DS      1               ;Signal estimate
SEZ_R       DS      1               ;Partial signal estimate
SR_R        DS      1               ;Reconstructed signal
PK0_R       DS      1               ;Sign of DQ + SEZ
PK1_R       DS      1               ;Delayed sign of DQ + SEZ
DMS_R       DS      1               ;Short term average of F(I)
DML_R       DS      1               ;Long term average of F(I)
TDP_R       DS      1               ;Tone detect
TD_R        DS      1               ;Delayed tone detect
YU_R        DS      1               ;Fast quantizer scale factor
YL_R        DS      1               ;Slow quantizer scale factor
SIGPK_R     DS      1               ;Sgn[p(k)] flag
A2P_R       DS      1               ;Second order predictor coef
TR_R        DS      1               ;Transition detect
SP_R        DS      1               ;Output PCM signal

;******************** Temporary variables *********************************
DQMAG       DS      1               ;|DQ|
SL_T        DS      1               ;PCM input for encoder
LAW         DS      1               ;PCM mode select

;******************** Shift constant lookup table *************************
; Shift constants used for doing left or right shifts by multiplying by a
; power of 2.

RSHFT       DS      24
LSHFT

;******************** Encoder coef. buffer ********************************
;   Bn = si.ff ffff | ffff ffff | ffff ffff (24TC)
;   An in same format
                                    ;8 word modulo buffer for coefs.,
                                    ; R6 is used as pointer
COEF_T      DSM     8               ;B1
                                    ;B2
                                    ;B3
                                    ;B4
                                    ;B5
                                    ;B6
                                    ;A1
                                    ;A2

;******************** Decoder coef. buffer ********************************
                                    ;8 locations for coef. queue
                                    ; (same format as COEF_T)
COEF_R      DSM     8               ;B1
                                    ;B2
                                    ;B3
                                    ;B4
                                    ;B5
                                    ;B6
                                    ;A1
                                    ;A2

            PAGE

            ORG     P:$0000
            JMP     START

            ORG     P:START

        MOVEC   #$06,OMR            ;Set DE=1
        CLR     A
        MOVEP   A,X:BCR             ;Set BCR for 0 wait states
        JSR     INIT

;**************************************************************************
;
; Poll SSI for receiver data available.  Note that the SSI transmit and
; receive are synchronous.
;
;**************************************************************************

IOWAIT  JCLR    #7,X:SSISR,IOWAIT   ;Wait for SSIRX full
        MOVE    Y:SP_R,A            ;Get decoder output
        MOVEP   A,X:SSITX           ;Send PCM output to CODEC
        MOVEP   X:SSIRX,A           ;Get input sample
        MOVE    A,Y:S_T             ;Save PCM input for encoder

;**************************************************************************
;
;   Encoder
;
;**************************************************************************

ENCODE  MOVE    X:DATAPTR_T,R2      ;Set data pointer to DQ1EXP
        MOVE    #COEF_T,R6          ;Set coef pointer to B1
        JSR     <PRDICT             ;(FMULT,ACCUM)
        MOVE    B,Y:SEZ_T
        MOVE    A,Y:SE_T

        MOVE    X:AP_T,A
        MOVE    Y:YL_T,Y1
        MOVE    Y:YU_T,Y0
        JSR     <LIMAMIX            ;(LIMA,MIX)
        MOVE    X1,X:AL_T
        MOVE    A,X:Y_T

;********************************************
; Get encoder input (PCM data)

        MOVE    Y:S_T,A

;********************************************

        MOVE    Y:SE_T,B
        MOVE    X:Y_T,Y0
        JSR     <CONVERT            ;(EXPAND,SUBTA,LOG,SUBTB,QUAN)
        MOVE    A,X:I_T
        
;********************************************
; Output ADPCM word

        MOVE    A,X1    Y:RSHFT+20,Y0
        MPY     Y0,X1,A             ;Shift ADPCM word to LSB's
        MOVEP   A1,X:PBD            ;Put output on PB0..3
        MOVE    X:I_T,A

;********************************************

        MOVE    X:Y_T,B
        JSR     <IQUAN              ;(RECONST,ADDA,ANTILOG)
        MOVE    A1,X:DQ_T

        MOVE    Y:TD_T,A
        MOVE    Y:YL_T,B
        JSR     <TRANS              ;(TRANS)
        MOVE    A1,Y:TR_T

        MOVE    Y:SE_T,B
        MOVE    X:DQ_T,A
        MOVE    Y:SEZ_T,X0
        MOVE    #PK1_T,R0
        JSR     <ADDBC              ;(ADDB,ADDC)
        MOVE    X1,Y:SR_T
        MOVE    B1,Y:SIGPK_T

        MOVE    X:DQ_T,Y0
        JSR     <UPB                ;(XOR,UPB)

        MOVE    Y:SIGPK_T,X0
        JSR     <UPA2               ;(UPA2,LIMC)
        MOVE    A,Y:A2P_T
        MOVE    A,Y:(R6)-           ;Save A2P to A2

        MOVE    Y:SIGPK_T,X1
        MOVE    Y:A2P_T,X0
        JSR     <UPA1               ;(UPA1,LIMD)

        MOVE    X:DQ_T,A
        MOVE    Y:SR_T,B
        JSR     <FLOAT              ;(FLOATA,FLOATB)

        MOVE    Y:A2P_T,B
        MOVE    Y:TR_T,Y0
        JSR     <TONE               ;(TONE,TRIGB)
        MOVE    Y1,Y:TDP_T
        MOVE    A,Y:TD_T

        MOVE    Y:DMS_T,Y0
        MOVE    Y:DML_T,Y1
        JSR     <FUNCTF             ;(FUNCTF,FILTA,FILTB)
        MOVE    A,Y:DMS_T
        MOVE    B,Y:DML_T

        MOVE    Y:TDP_T,X1
        MOVE    X:Y_T,Y1
        JSR     <SUBTC              ;(SUBTC)

        MOVE    X:AP_T,X1
        MOVE    Y:TR_T,Y1
        JSR     <FILTC              ;(FILTC,TRIGA)
        MOVE    A1,X:AP_T

        MOVE    X:Y_T,Y0
        MOVE    Y:YL_T,Y1
        JSR     <FUNCTW             ;(FUNCTW,FILTD,LIMB,FILTE)
        MOVE    X0,Y:YU_T
        MOVE    A1,Y:YL_T

        MOVE    R2,X:DATAPTR_T      ;Save transmit data pointer

;**************************************************************************
;
;   Decoder
;
;**************************************************************************

DECODE  MOVE    X:DATAPTR_R,R2      ;Set data pointer to DQ1EXP
        MOVE    #COEF_R,R6          ;Set coef pointer to B1
        JSR     <PRDICT             ;(FMULT,ACCUM)
        MOVE    B,Y:SEZ_R
        MOVE    A,Y:SE_R

        MOVE    X:AP_R,A
        MOVE    Y:YL_R,Y1
        MOVE    Y:YU_R,Y0
        JSR     <LIMAMIX            ;(LIMA,MIX)
        MOVE    X1,X:AL_R
        MOVE    A,X:Y_R

;********************************************
; Get decoder ADPCM input

        MOVEP   X:PBD,X1
        MOVE    Y:LSHFT-16,Y0
        MPY     X1,Y0,A     #<$F0,X0    ;Shift to MSB's of A0
        MOVE    A0,A
        AND     X0,A                ;ADPCM bits in MSB's of A1
        MOVE    A,X:I_R             ;Save decoder input

;********************************************

        MOVE    X:Y_R,B
        JSR     <IQUAN              ;(RECONST,ADDA,ANTILOG)
        MOVE    A1,X:DQ_R

        MOVE    Y:TD_R,A
        MOVE    Y:YL_R,B
        JSR     <TRANS              ;(TRANS)
        MOVE    A1,Y:TR_R

        MOVE    Y:SE_R,B
        MOVE    X:DQ_R,A
        MOVE    Y:SEZ_R,X0
        MOVE    #PK1_R,R0
        JSR     <ADDBC              ;(ADDB,ADDC)
        MOVE    B1,Y:SIGPK_R
        MOVE    X1,Y:SR_R

        MOVE    Y:LAW,B
        JSR     <COMPRESS           ;(COMPRESS)

;********************************************
; Save PCM decoder output (reconstructed signal)

        MOVE    A1,Y:SP_R

;********************************************

        MOVE    X:DQ_R,Y0
        JSR     <UPB                ;(XOR,UPB)

        MOVE    Y:SIGPK_R,X0
        JSR     <UPA2               ;(UPA2,LIMC)
        MOVE    A,Y:A2P_R
        MOVE    A,Y:(R6)-

        MOVE    Y:SIGPK_R,X1
        MOVE    Y:A2P_R,X0
        JSR     <UPA1               ;(UPA1,LIMD)

        MOVE    X:DQ_R,A
        MOVE    Y:SR_R,B
        JSR     <FLOAT              ;(FLOATA,FLOATB)

        MOVE    Y:A2P_R,B
        MOVE    Y:TR_R,Y0
        JSR     <TONE               ;(TONE,TRIGB)
        MOVE    Y1,Y:TDP_R
        MOVE    A,Y:TD_R

        MOVE    Y:DMS_R,Y0
        MOVE    Y:DML_R,Y1
        JSR     <FUNCTF             ;(FUNCTF,FILTA,FILTB)
        MOVE    A,Y:DMS_R
        MOVE    B,Y:DML_R

        MOVE    Y:TDP_R,X1
        MOVE    X:Y_R,Y1
        JSR     <SUBTC              ;(SUBTC)

        MOVE    X:AP_R,X1
        MOVE    Y:TR_R,Y1
        JSR     <FILTC              ;(FILTC,TRIGA)
        MOVE    A1,X:AP_R

        MOVE    X:Y_R,Y0
        MOVE    Y:YL_R,Y1
        JSR     <FUNCTW             ;(FUNCTW,FILTD,LIMB,FILTE)
        MOVE    X0,Y:YU_R
        MOVE    A1,Y:YL_R

        MOVE    R2,X:DATAPTR_R

        JMP     <IOWAIT

;**************************************************************************
;       FMULT/ACCUM
;
; Perform adaptive prediction filter using 24-bit fixed point
; multiply and 56-bit accumulate
;
; SEZ(k) = [B1(k-1) * DQ(k-1)] + ... + [B6(k-1) * DQ(k-6)]
;        = WB1 + WB2 + ... + WB6
;
; SE(k) = SEZ(k) + [A1(k-1) * SR(k-1)] + [A2(k-1) * SR(k-2)]
;       = SEZ + WA1 + WA2
;
; Inputs:
;   SRn = X:(R2) = siii iiii | iiii iiii. | ffff ffff  (24TC)
;       (DQ in same format as SR)
;
;   An = Y:(R6) = si.ff ffff | ffff ffff | ffff ffff (24TC)
;       (Bn in same format as An)
;
; Outputs:
;   SEZ = siii iiii | iiii iiii. | ffff ffff  (24TC)
;   SE = siii iiii | iiii iiii. | ffff ffff  (24TC)
;
;**************************************************************************

PRDICT  CLR     A       X:(R2)+,X0  Y:(R6)+,Y0  ;Get DQ1 & B1
        REP     #6
        MAC     X0,Y0,A X:(R2)+,X0  Y:(R6)+,Y0  ;Find SEZ
        TFR     A,B                             ;Copy SEZ
        ASL     B                               ;Adjust radix pt.
        MAC     X0,Y0,A X:(R2)+,X0  Y:(R6)+,Y0  ;Accum, get SR2 & A2
        MAC     X0,Y0,A                         ;Find SE
        ASL     A                               ;Adjust radix pt.
        RTS

;**************************************************************************
;       LIMA
;
; Limit speed control parameter
;
; AL(k) = 1        if AP(k-1) > 1
;       = AP(k-1)  if AP(k-1) <= 1
;
; Inputs:
;   AP = 0ii.f ffff | ffff ffff | ffff ffff  (23SM)
;
; Outputs:
;   AL = 0i.ff ffff | ffff ffff | ffff ffff  (23SM)
;
;**************************************************************************

LIMAMIX MOVE    #<$20,X0            ;Get '1'
        CMP     X0,A                ;Test AP
        TGT     X0,A                ;If AP>'1' set AL='1'
        ASL     A                   ;Shift to align radix pt.

;**************************************************************************
;       MIX
;
; Form linear combination of fast and slow quantizer
;   scale factors
;
; Y(k) = AL(k) * YU(k-1) + [1 - AL(k)] * YL(k-1)
;
; Inputs:
;   YL = 0iii i.fff | ffff ffff | ffff ffff  (23SM)
;   AL = 0i.ff ffff | ffff ffff | ffff ffff  (23SM)
;   YU = 0iii i.fff | ffff ffff | ffff ffff  (23SM)
;
; Outputs:
;   Y = 0iii i.fff | ffff ffff | ffff ffff  (23SM)
;
;**************************************************************************

        TFR     Y0,A    A,X1        ;Swap YU and AL
        SUB     Y1,A                ;Find YU-YL
        ABS     A       A,B         ;Find |YU-YL|, save sign
        MOVE    A,Y0
        MPY     X1,Y0,A             ;Find PRODM=|YU-YL|*AL
        NEG     A   A,X0            ;Find -PRODM, save PRODM
        TST     B   Y1,B            ;Check sign
        TPL     X0,A                ;If sign=0 PROD=PRODM,
                                    ; else PROD=-PRODM
        ADDL    B,A                 ;Find Y=PROD+YL
        RTS

;**************************************************************************
;       EXPAND
;
; Convert A-law or mu-law PCM to uniform PCM (according to
;   Recommendation G.711). For further details see Motorola
;   application bulletin "Logarithmic/Linear Conversion
;   Routines for DSP56000/1".
;
; Input:
;   S = psss qqqq | 0000 0000 | 0000 0000 (PCM log format)
;
; Output:
;   SL = siii iiii | iiii ii.00 | 0000 0000  (14TC)
;
;**************************************************************************

CONVERT MOVE    A,X0    #>$80,Y1    ;Get shift constant
        MPY     X0,Y1,A     #>$7F,X1    ;Shift S to 8 lsb's of A1
        AND     X1,A                ;Mask off sign of S
        MOVE    A1,N3               ;Load |S| as offset
        CMPM    Y1,A                ;Check sign of S
        MOVE    X:(R3+N3),A         ;Lookup |SL| from ROM table
        JGE     <SUBTA              ;If S=0, SL=|SL|
        NEG     A                   ;If S=1, SL=-|SL|

;**************************************************************************
;       SUBTA
;
; Compute difference signal by subtracting signal estimate
;       from input signal
;
;   D(k) = SL(k) - SE(k)
;
; Inputs:
;   SL = siii iiii | iiii ii.00 | 0000 0000  (16TC) 
;   SE = siii iiii | iiii iiii. | ffff ffff  (24TC)
;
; Output:
;   D = siii iiii | iiii iiii. | ffff ffff  (24TC)
;**************************************************************************

SUBTA   ASR     A                       ;Sign extend SL and
        SUBR    B,A                     ; find D=SL-SE

;**************************************************************************
;       LOG
;
; Convert difference signal from the linear to the log
;   domain.  Use approximation LOG2[1 + x] = x
;
; Input:
;   D = siii iiii | iiii iiii. | ffff ffff  (24TC)
;
; Outputs:
;   DL = 0iii i.fff | ffff ffff | ffff ffff  (23SM)
;   DS = sXXX XXXX | XXXX XXXX | XXXX XXXX  (1TC)
;
;**************************************************************************

        ABS     A   A,Y1                ;Find DQM=|D|, save DS to Y1
        MOVE    Y:RSHFT+15,X0           ;Get '1'
        CMP     X0,A    #<$40,X1        ;Check for DQM<1
        JGE     <NORMEXP
        CLR     A                       ;If DQM<1 set DL=0
        JMP     <SUBTB                  ; and continue
NORMEXP
        MOVE    #$000E,R0               ;Get exp bias (14)
        REP     #14                     ;If DQM!=0, do norm iteration
        NORM    R0,A                    ; 14 times to find MSB of DQM
        EOR     X1,A    Y:LSHFT-19,X0   ;Zero MSB of MANT, get EXP shift
        MOVE    R0,X1                   ;Move EXP to X1
        MPY     X0,X1,A     A,X1        ;Shift EXP<<19, save MANT to X1
        MOVE    Y:RSHFT+3,X0            ;Get shift
        MOVE    A0,A                    ;Move EXP to A1
        MAC     X0,X1,A                 ;Shift MANT>>3 & combine with EXP

;**************************************************************************
;       SUBTB
;
; Scale log version of difference signal by subtracting
;   scale factor
;
; DLN(k) = DL(k) - Y(k)
;
; Inputs:
;   DL = 0iii i.fff | ffff ffff | ffff ffff  (23SM)
;   Y = 0iii i.fff | ffff ffff | ffff ffff  (23SM)
;
; Output:
;   DLN = siii i.fff | ffff ffff | ffff ffff  (24TC)
;
;**************************************************************************

SUBTB   SUB     Y0,A                    ;Find DLN=DL-Y

;**************************************************************************
;       QUAN
;
; Quantize difference signal in log domain
;
;    log2|D(k)| - Y(k) | |I(k)|
;    ------------------+--------
;      [3.12, + inf)   |   7
;      [2.72, 3.12)    |   6
;      [2.34, 2.72)    |   5
;      [1.91, 2.34)    |   4
;      [1.38, 1.91)    |   3
;      [0.62, 1.38)    |   2
;      [-0.98, 0.62)   |   1
;      (- inf, -0.98)  |   0
;
; Inputs:
;   DLN = siii i.fff | ffff ffff | ffff ffff  (24TC)
;   DS = sXXX XXXX | XXXX XXXX | XXXX XXXX  (1TC)
;
; Output:
;   I = siii 0000 | 0000 0000 | 0000 0000 (ADPCM format)
;
;**************************************************************************

        MOVE    #QUANTAB,R0         ;Get quantization table base
        MOVE    #>QUANTAB+2,X1      ;Get offset for quan conversion
        MOVE    X:(R0)+,X0          ;Get quan table value
TSTDLN  CMP     X0,A    X:(R0)+,X0  ;Compare to DLN
        JGE     <TSTDLN             ;If value<DLN try next range
        MOVE    R0,A                ;When range found...
                                    ; subtract pointer from
        SUB     X1,A    Y:LSHFT-20,X0   ; base to get IMAG=|I|  
        MOVE    A1,X1
        MPY     X0,X1,A     Y1,B    ;Shift IMAG <<20, result is
                                    ; in A0, move DS (from LOG) into B
        MOVE    A0,A
        TST     A       #<$F0,X0    ;Check IMAG, get invert mask
        JEQ     <INVERT             ;If IMAG=0 invert bits
        TST     B                   ;If IMAG!=0, check DS
        JPL     <IOUT               ;If DS=1 don't invert IMAG
INVERT  EOR     X0,A                ;If DS=0 or IMAG=0 invert IMAG
IOUT    MOVE    A1,A                ;Adjust sign extension
        RTS

;**************************************************************************
;       RECONST
;
; Reconstruct quantized difference signal in the log domain
;
;     |I(k)| | log2|DQ(k)| - Y(k)
;    --------+-------------------
;       7    |      3.32
;       6    |      2.91
;       5    |      2.52
;       4    |      2.13
;       3    |      1.66
;       2    |      1.05
;       1    |      0.031
;       0    |      - inf
;
; Inputs:
;   I = iiii 0000 | 0000 0000 | 0000 0000  (ADPCM format)
;
; Output:
;   DQLN = siii i.fff | ffff 0000 | 0000 0000  (12TC)
;   DQS = sXXX 0000 | 0000 0000 | 0000 0000  (1TC)
;   IMAG = 0000 0000 | 0000 0000 | 0000 0iii.
;
;**************************************************************************

IQUAN   MOVE    A,Y1                ;Save DQS (sign of I) to Y1
        MOVE    #<$F0,X1
        EOR     X1,A    Y:RSHFT+20,Y0   ;Invert bits of I
        TMI     Y1,A                ;If ^IS=1, use I, else use ^I
        MOVE    A1,X0
        MPY     X0,Y0,A     #IQUANTAB,R0    ;Shift IMAG>>20
        MOVE    A1,N0               ;Load IMAG as offset into IQUAN table
        MOVE    A1,X:IMAG           ;Save |I|
        MOVE    X:(R0+N0),A         ;Lookup DQLN

;**************************************************************************
;       ADDA
;
; Add scale factor to log version of quantized difference
;   signal
;
; DQL(k) = DQLN(k) + Y(k)
;
; Inputs:
;   Y = 0iii i.fff | ffff ffff | ffff ffff  (23SM)
;   DQLN = siii i.fff | ffff 0000 | 0000 0000  (12TC)
;
; Output:
;   DQL = siii i.fff | ffff ffff | ffff ffff  (24TC)
;
;**************************************************************************

        ADD     B,A                 ;Find DQL=DQLN+Y
   
;**************************************************************************
;       ANTILOG
;
; Convert quantized difference signal from log to linear
;   domain. Use approximation 2**(x) = 1 + x
;
; Input:
;   DQL = siii i.fff | ffff ffff | ffff ffff  (24TC)
;   DQS = sXXX 0000 | 0000 0000 | 0000 0000  (1TC)
;
; Outputs:
;   DQ = siii iiii | iiii iii.f | ffff ffff  (24SM)
;
;**************************************************************************

        JPL     <CONVLOG            ;If DQL>=0 convert DQL,
                                    ; else DQL<0, set |DQ|=0
        TFR     Y1,A    #<$80,X0    ;Get DQS (MSB of I), get mask
        AND     X0,A    #0,B        ;Mask off DQS, set |DQ|=0
        MOVE    B1,Y:DQMAG          ;Save DQMAG=|DQ|
        JMP     <SAVEDQ

CONVLOG
        TFR     A,B     #$07FFFF,X0 ;Get mask
        AND     X0,A    #<$08,X1    ;Find fractional part (DMN), get '1'
        OR      X1,A    #<$78,X0    ;Add '1' to DMN to find DQT,
                                    ; get integer mask
        AND     X0,B    Y:RSHFT+19,Y0   ;Find integer part (DEX),
                                    ; get shift constant
        MOVE    B1,X0
        MPY     X0,Y0,B     #>$0A,X0    ;Shift DEX>>19, get '10'
        SUB     X0,B        #$7FFFFF,X0 ;Find DQT shift=DEX-10
        JEQ     <TRUNCDQM           ;If DEX=10, no shift
        JLT     <SHFRDQ             ;If DEX<10, shift right
        REP     B1                  ;Else shift DQT left
        LSL     A                   ; up to 4 times
        JMP     <TRUNCDQM

SHFRDQ  NEG     B       #RSHFT,R0   ;Find 10-DEX
        MOVE    B1,N0               ;Use 10-DEX for shift lookup
        MOVE    A1,Y0
        MOVE    Y:(R0+N0),X1        ;Lookup shift constant
        MPY     X1,Y0,A             ;Shift DQT right up to 9 times
TRUNCDQM    AND X0,A    #<$80,B     ;Truncate to find DQMAG=|DQ|,
                                    ; get sign mask
        AND     Y1,B    A1,Y:DQMAG  ;Mask off DQS, save DQMAG           
        MOVE    B1,X0
        OR      X0,A                ;Add DQS to DQMAG to get DQ
                                    ;Note: result in A1, not A
SAVEDQ  RTS

;**************************************************************************
;       TRANS
;
; Transition detector
;
; TR(k) = 1 if TD(k)=1 and |DQ(k)|> 24 x 2**(YL(k))
;         0 otherwise
;
; Inputs:
;   TD = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;   YL = 0iii i.fff | ffff ffff | ffff ffff  (23SM)
;   DQ = siii iiii | iiii iii.f | ffff ffff  (24SM)
;
; Output:
;   TR = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;
;**************************************************************************

TRANS   TST     A   #0,A            ;Check TD, set TR=0
        JEQ     <SAVETR             ;If TD=0 save TR=0
                                    ; else test DQ and YL
        TFR     B,A     #$07FFFF,X0 ;Save YL, get mask
        AND     X0,A    #<$08,X0    ;Find YLFRAC (YL>>10), get '1'
        OR      X0,A    B,X1        ;Add implied '1' to YLFRAC,
        MOVE    Y:RSHFT+19,Y1       ;Get shift const
        MPY     Y1,X1,B     #>$08,X0    ;Find YLINT=YL>>19, get '8'
        MOVE    B1,B                ;Clear fractional portion
        CMP     X0,B    #>$05,X0    ;Compare YLINT to '8', get '5'
        JGT     <MAXTHR             ;If YLINT>8 set maximum THR2
        SUB     X0,B                ;Find YLINT-5
        JEQ     <SETDQTHR           ;If YLINT=5 don't shift
        JLT     <RSHIFT             ;If YLINT<5 shift right

        REP     B1                  ;Else shift YLFRAC left
        LSL     A                   ; up to 3 times to get THR1
        JMP     <SETDQTHR

MAXTHR  MOVE    #<$7C,A             ;Set maximum THR1
        JMP     <SETDQTHR

RSHIFT  NEG     B       #RSHFT,R0   ;Find 5-YLINT
        MOVE    B1,N0               ;Use 5-YLINT for shift lookup
        MOVE    A1,X0
        MOVE    Y:(R0+N0),X1        ;Lookup shift constant
        MPY     X0,X1,A             ;Shift YLFRAC right up to 5 times
                                    ; to get THR1
SETDQTHR    TFR     A,B             ;Copy THR1=2**(YL)
        ADDR    B,A     #0,X1
        ASR     A       Y:DQMAG,X0  ;Find DQTHR='24' x 2**(YL)
        CMP     X0,A    #<$80,A     ;Compare DQMAG to DQTHR, set TR=1
        TGT     X1,A                ;If DQMAG>DQTHR leave TR=1,
                                    ; else DQMAG<=DQTHR, set TR=0
SAVETR  RTS

;**************************************************************************
;       ADDB
;
; Add quantized difference signal and signal estimate
;   to form reconstructed signal
;
; SR(k-n) = SE(k-n) + DQ(k-n)
;
; Inputs:
;   DQ = siii iiii | iiii iii.f | ffff ffff  (24SM)
;   SE = siii iiii | iiii iiii. | ffff ffff  (24TC)
;
; Output:
;   SR = siii iiii | iiii iiii. | ffff ffff  (24TC)
;
;**************************************************************************

ADDBC   TST     A       Y:DQMAG,A   ;Check DQS, get DQMAG
        JPL     <SHFTDQ             ;If DQS=0 continue
        NEG     A                   ;Convert DQ to 2's comp
SHFTDQ  ADDR    B,A     A,B         ;Find SR=DQ+SE, save DQ
        TFR     B,A     A,X1        ;Swap DQ and SR

;**************************************************************************
;       ADDC
;
; Obtain sign of addition of the quantized difference
;   signal and the partial signal estimate
;
; P(k) = DQ(k) + SEZ(k)
; PK0 = sign of P(k)
;
; Inputs:
;   DQ = siii iiii | iiii iii.0 | 0000 0000  (15SM)
;   SEZ = siii iiii | iiii iiii. | ffff ffff (24TC)
;
; Output:
;   PK0 = sXXX XXXX | XXXX XXXX | XXXX XXXX  (1TC)
;   SIGPK = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;
;**************************************************************************

        ADD     X0,A    #0,B        ;Find DQSEZ=DQ+SEZ,
                                    ; set SIGPK=0
        TST     A   #<$80,X0        ;Check DQSEZ, get '1'
        TEQ     X0,B                ;If DQSEZ=0, SIGPK=1,
                                    ; else SIGPK=0
        MOVE    Y:(R0)-,Y1          ;Get PK1
        MOVE    Y:(R0)+,X0          ;Get PK0
        MOVE    X0,Y:(R0)-          ;Delay previous PK0
        EOR     X0,A    A1,Y:(R0)   ;Save new PK0, find PKS1=PK0**PK1
                                    ; for UPA1 & UPA2
        MOVE    A1,X:PKS1           ;Save PKS1
        MOVE    Y:(R0),A
        EOR     Y1,A                ;Find PKS2=PK0**PK2 for UPA2
        MOVE    A1,X:PKS2           ;Save PKS2
        RTS

;**************************************************************************
;       XOR/UPB
;
; Update the coefficients of the sixth order predictor
;
; Bn(k) = [1-(2**-8)] * Bn(k-1)
;           + (2**-7) * sgn[DQ(k)] * sgn[DQ(k-n)]
; Un = sgn[DQ(k)] XOR sgn[DQ(k-n)]
;
; Inputs:
;   Bn = Y:(R6+n) = si.ff ffff | ffff ffff | ffff ffff (24TC)
;   DQ = siii iiii | iiii iii.f | ffff ffff (24SM)
;
; Outputs:
;   BnP = Y:(R6+n) = si.ff ffff | ffff ffff | ffff ffff (24TC)
;
;**************************************************************************

UPB     MOVE    Y:DQMAG,B
        MOVE    #$008000,X0         ;Get +gain
        DO      #6,ENDUPB           ;Do UPB and XOR for B1-B6
        MOVE    X:(R2)+,A       Y:(R6),Y1   ;Get Bn & DQnS
        EOR     Y0,A    #$FF8000,X1 ;Find Un=DQS**DQnS (XOR),
                                    ; get -gain
        TPL     X0,A                ;If Un=0 set UGBn=+gain
        TMI     X1,A                ;If Un=1 set UGBn=-gain
        TST     B       #0,X1       ;Test for |DQ|=0
        TEQ     X1,A                ;If |DQ|=0, Then UGBn=0
        MOVE    Y:RSHFT+8,X1        ;Get shift constant
        MAC     -X1,Y1,A            ;Find UBn=UGBn-(Bn>>8)
        ADD     Y1,A                ;Find BnP=Bn+UBn
        MOVE    A1,Y:(R6)+          ;Store BnP to Bn
ENDUPB  RTS

;**************************************************************************
;       UPA2
;
; Update the A2 coefficient of the second order predictor.
;
; A2(k) = [1-(2**-7)] * A2(k-1)
;           + (2**-7) * { sgn[P(k)] * sgn[P(k-2)]
;               - F[A1(k-1)] * sgn[P(k)] * sgn[P(k-1)] }
;
; F[A1(k)] = 4 * A1       if |A1|<=(2**-1)
;          = 2 * sgn(A1)  if |A1|>(2**-1)
;
; Inputs:
;   A1 = Y:(R6) = si.ff ffff | ffff ffff | ffff ffff (24TC)
;   A2 = Y:(R6+1) = si.ff ffff | ffff ffff | ffff ffff (24TC)
;   SIGPK = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;   PK0 = sXXX XXXX | XXXX XXXX | XXXX XXXX  (1TC)
;   PK1 = sXXX XXXX | XXXX XXXX | XXXX XXXX  (1TC)
;   PK2 = sXXX XXXX | XXXX XXXX | XXXX XXXX  (1TC)
;     (Note: PKS1 & PKS2 have been previously calculated)
;
; Outputs:
;   A2T = si.ff ffff | ffff ffff | ffff ffff (24TC)
;
;**************************************************************************

UPA2    MOVE    X:PKS2,A            ;Get PKS2=PK0**PK2
        MOVE    #<$10,Y0            ;Get '+1'
        TST     A   #<$F0,Y1        ;Check PKS2, get '-1'
        TPL     Y0,A                ;If PKS2=0, set UGA2A='+1'
        TMI     Y1,A                ;If PKS2=1, set UGA2A='-1'
        MOVE    A,X1    Y:(R6)+,A   ;Save UGA2A, get A1
        MOVE    #$1FFF00,Y0         ;Get '+1.99'
        CMP     Y0,A    #$E00100,Y1 ;Check A1, get '-1.99'
        TGT     Y0,A                ;If A1>=1/2, set FA1='1.99'
        CMP     Y1,A    X:PKS1,B    ;Check A1 again, get PKS1=PK0**PK1
        TLT     Y1,A                ;If A1<=-1/2, set FA1='-1.99'
        TST     B                   ;Check PKS1
        JMI     <FINDSUM            ;If PKS1=1, FA=FA1
        NEG     A                   ; else PKS1=0, set FA=-FA1
FINDSUM ADD     X1,A    Y:RSHFT+5,Y1    ;Find UGA2B=UGA2A+FA
        TFR     X0,B    A,X1
        MPY     X1,Y1,A     #0,X0   ;Find UGA2B>>7
        TST     B   Y:(R6),Y0       ;Check SIGPK, get A2
        TMI     X0,A                ;If SIGPK=1, set UGA2=0
        MOVE    Y:RSHFT+7,X0        ;Get shift constant
        MAC     -Y0,X0,A            ;Find UA2=UGA2-(A2>>7)
        ADD     Y0,A                ;Find A2T=A2+UA2

;**************************************************************************
;       LIMC
;
; Limit the A2 coefficient of the second order predictor.
;
;   |A2(k)| <= '0.75' 
;
; Inputs:
;   A2T = si.ff ffff | ffff ffff | ffff ffff (24TC)
;
; Outputs:
;   A2P = Y:(R6) = si.ff ffff | ffff ffff | ffff ffff (24TC)
;
;**************************************************************************

        MOVE    #<$D0,X0            ;Get A2LL
        CMP     X0,A    #<$30,X1    ;Check A2P, get A2UL
        TLT     X0,A                ;If A2P<-0.75, set A2P=-0.75
        CMP     X1,A                ;Check A2P again
        TGT     X1,A                ;If A2P>0.75, set A2P=0.75
        RTS

;**************************************************************************
;       UPA1
;
; Update the A1 coefficient of the second order predictor.
;
; A1(k) = [1-(2**-8)] * A1(k-1)
;           + 3 * (2**-8) * sgn[P(k)] * sgn[P(k-1)]
;
; Inputs:
;   A1 = Y:(R6) = si.ff ffff | ffff ffff | ffff ffff (24TC)
;   SIGPK = Y:(R0) = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;   PK0 = sXXX XXXX | XXXX XXXX | XXXX XXXX  (1TC)
;   PK1 = sXXX XXXX | XXXX XXXX | XXXX XXXX  (1TC)
;     (Note: PKS1 has been previously calculated)
;
; Outputs:
;   A1T = si.ff ffff | ffff ffff | ffff ffff (24TC)
;
;**************************************************************************

UPA1    MOVE    #$00C000,Y0         ;Get +gain
        MOVE    X:PKS1,B            ;Get PKS1=PK0**PK1
        TST     B       #$FF4000,Y1 ;Check PKS1, get -gain
        TPL     Y0,A                ;If PKS=0, set UGA1=+gain
        TMI     Y1,A                ;If PKS=1, set UGA1=-gain
        MOVE    X1,B
        TST     B       #0,X1       ;Check SIGPK
        TMI     X1,A                ;If SIGPK=1, set UGA1=0
        MOVE    Y:(R6),X1           ;Get A1
        MOVE    Y:RSHFT+8,Y0        ;Get shift constant
        MAC     -Y0,X1,A            ;Find UA1=UGA1-(A1>>8)
        ADD     X1,A                ;Find A1T=A1+UA1

;**************************************************************************
;       LIMD
;
; Limit the A1 coefficient of the second order predictor.
;
;   |A1(k)| <= [1-(2**-4)] - A2(k)
;
; Inputs:
;   A1T = si.ff ffff | ffff ffff | ffff ffff (24TC)
;   A2P = si.ff ffff | ffff ffff | ffff ffff (24TC)
;
; Outputs:
;   A1P = Y:(R6) = si.ff ffff | ffff ffff | ffff ffff (24TC)
;
;**************************************************************************

        MOVE    #<$3C,B             ;Get OME='1-(2**-4)'
        SUB     X0,B                ;Find A1UL=OME-A2P
        CMP     B,A     B,X0        ;Check A1T
        TGT     X0,A                ;If A1T>A1UL, set A1P=A1UL
        NEG     B       #2,N6       ;Find A1LL=-A1UL=A2P-OME
        CMP     B,A     B,X0        ;Check A1T again
        TLT     X0,A                ;If A1T<A1LL, set A1P=A1LL
        MOVE    A1,Y:(R6)+N6        ;Store A1P to A1
        RTS

;**************************************************************************
;       FLOATA
;
; Convert the quantized difference signal from signed magnitude
;   to two's complement and save to the data buffer.
;
; Inputs:
;   DQ = siii iiii | iiii iii.f | ffff ffff (24SM)
;
; Outputs:
;   DQ = X:(R2) = siii iiii | iiii iiii. | ffff ffff (24TC)
;
;**************************************************************************

FLOAT   TST     A       #2,N2       ;Test sign of DQ
        JPL     <TRUNCDQ
        MOVE    Y:DQMAG,A           ;If DQ<0,
        NEG     A                   ; negate magnitude of DQ
TRUNCDQ ASR     A       (R2)+       ;Sign extend to 16TC
        MOVE    A,X:(R2)-N2

;**************************************************************************
;       FLOATB
;
; Save the reconstructed signal to the data buffer.
;
; Inputs:
;   SR = siii iiii | iiii iiii. | ffff ffff  (24TC)
;
; Outputs:
;   SR = X:(R2) = siii iiii | iiii iiii. | ffff ffff  (24TC)
;
;**************************************************************************

        MOVE    B,X:(R2)+N2
        RTS

;**************************************************************************
;       TONE
;
; Partial band signal detection
;
; TD(k) = 1 if A2(k) < -0.71875
;         0 otherwise
;
; Inputs:
;   A2P = si.ff ffff | ffff ffff | ffff ffff  (24TC)
;
; Output:
;   TDP = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;
;**************************************************************************

TONE    CLR     A   #<$D2,X0        ;Get '-.71875', set TDP=0
        CMP     X0,B    #<$80,X1    ;Check A2P, get '1'
        TLT     X1,A                ;If A2P<-.71875 set TDP=1, else TDP=0

;**************************************************************************
;       TRIGB
;
; Predictor trigger block
;
; If TR(k) = 1, An(k)=Bn(k)=TD(k)=0
;
; Inputs:
;   TR = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;   BnP = si.ff ffff | ffff ffff | ffff ffff  (24TC)
;   AnP = si.ff ffff | ffff ffff | ffff ffff  (24TC)
;   TDP = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;
; Output:
;   BnR = si.ff ffff | ffff ffff | ffff ffff  (24TC)
;   AnR = si.ff ffff | ffff ffff | ffff ffff  (24TC)
;   TDR = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;
;**************************************************************************

        MOVE    Y0,B
        TST     B       A,Y1        ;Test TR
        JEQ     <ENDTRIG
        CLR     A                   ;If TR=1, set TDR=0,
        REP     #8                  ; and B1-B6,A1,A2=0
        MOVE    A,Y:(R6)+
ENDTRIG RTS

;**************************************************************************
;       FUNCTF
;
; Maps quantizer output I into F(I) function
;
;  |I(k)|  | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
; ---------+---+---+---+---+---+---+---+---+
;  F[I(k)] | 7 | 3 | 1 | 1 | 1 | 0 | 0 | 0 |
;
; Inputs:
;   I = siii. 0000 | 0000 0000 | 0000 0000
;
; Output:
;   FI = 0iii. 0000 | 0000 0000 | 0000 0000  (3SM)
;
;**************************************************************************

FUNCTF  MOVE    #FIBASE,R0          ;Load lookup table base
        MOVE    X:IMAG,N0           ;Load IMAG as offset
        NOP
        MOVE    X:(R0+N0),A         ;Get FI from lookup table

;**************************************************************************
;       FILTA
;
; Update short term average of F(I)
;
; DMS(k) = (1 - 2**(-5)) * DMS(k-1) + 2**(-5) * F[I(k)]
;
; Inputs:
;   FI = 0iii. 0000 | 0000 0000 | 0000 0000  (3SM)
;   DMS = 0iii. ffff | ffff ffff | ffff ffff  (23SM)
;
; Output:
;   DMSP = 0iii. ffff | ffff ffff | ffff ffff  (23SM)
;
;**************************************************************************

        SUB     Y0,A    A,B         ;Find DIF=FI-DMS, save FI
        TFR     Y0,A    A,X0        ;Move DIF and DMS
        MOVE    Y:RSHFT+5,X1        ;Get mask
        MAC     X0,X1,A             ;Find DMSP=(DIF>>5)+DMS

;**************************************************************************
;       FILTB
;
; Update long term average of F(I)
;
; DML(k) = (1 - 2**(-7)) * DML(k-1) + 2**(-7) * F[I(k)]
;
; Inputs:
;   FI = 0iii. 0000 | 0000 0000 | 0000 0000  (3SM)
;   DML = 0iii. ffff | ffff ffff | ffff ffff  (23SM)
;
; Output:
;   DMLP = 0iii. ffff | ffff ffff | ffff ffff  (23SM)
;
;**************************************************************************

        SUB     Y1,B    Y:RSHFT+7,X1    ;Find DIF=FI-DML
        TFR     Y1,B    B,X0
        MAC     X0,X1,B             ;Find DMLP=(DIF>>7)+DML
        RTS

;**************************************************************************
;       SUBTC
;
; Compute magnitude of the difference of short and long
;  term functions of quantizer output sequence and then
;  perform threshold comparison for quantizing speed control
;  parameter.
;
; AX = 1  if Y(k)>=3, TD(k)=1, & |DMS(k)-DML(k)|>(2**-3)*DML(k)
;    = 0  otherwise
;
; Input:
;   Y = 0iii i.fff | ffff ffff | ffff ffff  (23SM)
;   DMSP = 0iii. ffff | ffff ffff | ffff ffff  (23SM)
;   DMLP = 0iii. ffff | ffff ffff | ffff ffff  (23SM)
;   TDP = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;
; Output:
;   AX = 0i0.0 0000 | 0000 0000 | 0000 0000  (1SM)
;
;**************************************************************************

SUBTC   SUB     B,A     Y:RSHFT+3,X0    ;Find DIF=DMSP-DMLP
        ABS     A       B,Y0        ;Find DIFM=|DIF|
        MPY     X0,Y0,B     #<$40,X0    ;Find DTHR=DMLP>>3, get '1'
        CMP     B,A     #0,B        ;Compare DIFM & DTHR, set AX=0
        TGE     X0,B                ;If DIFM>=DTHR set AX=1
        MOVE    X1,A                ;Get TDP
        TST     A       #<$18,Y0    ;Check TDP, get '3'
        TNE     X0,B                ;If TDP!=0 set AX=1
        MOVE    Y1,A
        CMP     Y0,A                ;Check for Y<"3"
        TLT     X0,B                ;If Y<"3" set AX=1
        RTS

;**************************************************************************
;       FILTC
;
; Low pass filter of speed control parameter
;
; AP(k) = (1-2**(-4)) * AP(k-1) + AX
;
; Inputs:
;   AX = 0i0.0 0000 | 0000 0000 | 0000 0000  (1SM)
;   AP = 0ii.f ffff | ffff ffff | ffff ffff  (23SM)
;
; Outputs:
;   APP = 0ii.f ffff | ffff ffff | ffff ffff  (23SM)
;
;**************************************************************************

FILTC   SUB     X1,B    Y:RSHFT+4,Y0    ;Find DIF=AX-AP
        TFR     X1,A    B,X0
        MAC     X0,Y0,A                 ;Find APP=(DIF>>4)+AP

;**************************************************************************
;       TRIGA
;
; Speed control trigger block
;
; AP(k) = AP(k) if TR(k)=0
;       =  1    if TR(k)=1
;
; Inputs:
;   TR = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;   APP = 0ii.f ffff | ffff ffff | ffff ffff  (23SM)
;
; Outputs:
;   APR = 0ii.f ffff | ffff ffff | ffff ffff  (23SM)
;
;**************************************************************************

        MOVE    Y1,B
        TST     B       #<$20,X0    ;Check TR, get '1'
        TMI     X0,A                ;If TR=1 set APR=1, else APR=APP
        RTS

;**************************************************************************
;       FUNCTW
;
; Map quantizer output into logarithmic version of scale
;  factor multiplier
;
;  |I(k)|  |  7  |  6  |  5  |  4  |  3  |  2  |  1  |  0  |
; ---------+-----+-----+-----+-----+-----+-----+-----+-----+
;   W(I)   |70.13|22.19|12.38| 7.00| 4.00| 2.56| 1.13|-0.75|
;
; Inputs:
;   I = siii. 0000 | 0000 0000 | 0000 0000
;
; Outputs:
;   WI = siii iiii. | ffff 0000 | 0000 0000  (12TC)
;
;**************************************************************************

FUNCTW  MOVE    #WIBASE,R0          ;Load lookup table base
        MOVE    X:IMAG,N0           ;Load IMAG as offset
        NOP
        MOVE    X:(R0+N0),A         ;Get WI from lookup table

;**************************************************************************
;       FILTD
;
; Update of fast quantizer scale factor
;
; YU(k) = (1 - 2**(-5)) * Y(k) + 2**(-5) * W[I(k)]
;
; Inputs:
;   WI =  siii iiii. | ffff 0000 | 0000 0000  (12TC)
;   Y = 0iii i.fff | ffff ffff | ffff ffff  (23SM)
;
; Outputs:
;   YUT = 0iii i.fff | ffff ffff | ffff ffff  (23SM)
;
;**************************************************************************

        MOVE    Y:RSHFT+3,X1        ;Get shift constant
        MAC     -Y0,X1,A    Y0,B    ;Find DIF=WI-(Y>>3)
        ASR     A
        ADDR    B,A                 ;Find YUT=(DIF>>5)+Y (actually DIF>>2)

;**************************************************************************
;       LIMB
;
; Limit quantizer scale factor
;
; 1.06 <= YU(k) <= 10.00
;
; Inputs:
;   YUT = 0iii i.fff | ffff ffff | ffff ffff  (23SM)
;
; Outputs:
;   YUP = 0iii i.fff | ffff ffff | ffff ffff  (23SM)
;
;**************************************************************************

        MOVE    #<$50,X0            ;Get upper limit '10'
        CMP     X0,A    #$088000,X1 ;Check for YU>10,
                                    ; get lower limit '1.06'
        TGT     X0,A                ;If YU>10 set YU=10
        CMP     X1,A                ;Check for YU<1.06
        TLT     X1,A                ;If YU<1.06 set YU=1.06
        MOVE    A,X0                ;Save YUP

;**************************************************************************
;       FILTE
;
; Update of slow quantizer scale factor
;
; YL(k) = (1 - 2**(-6)) * YL(k-1) + 2**(-6) * YU(k)
;
; Inputs:
;   YUP = 0iii i.fff | ffff ffff | ffff ffff  (23SM)
;   YL = 0iii i.fff | ffff ffff | ffff ffff  (23SM)
;
; Outputs:
;   YLP = 0iii i.fff | ffff ffff | ffff ffff  (23SM)
;
;**************************************************************************

        MOVE    Y1,B
        SUB     B,A     Y:RSHFT+6,Y0    ;Find DIF=YUP-YL
        TFR     B,A     A,X1
        MAC     Y0,X1,A                 ;Find YLP=(DIFSX>>6)+YL
        RTS

;**************************************************************************
;       COMPRESS
;
; Convert from uniform PCM to A-law or mu-law PCM (according to
;   Recommendation G.711). For further details see Motorola
;   application bulletin "Logarithmic/Linear Conversion
;   Routines for DSP56000/1".
;
; Input:
;   SR = siii iiii | iiii iiii. | 0000 0000  (16TC)
;
; Output:
;   SP = psss qqqq | 0000 0000 | 0000 0000 (PCM log format)
;
;**************************************************************************

COMPRESS
        MOVE    #$002100,Y0         ;Get bias
        TST     B       X1,A
        JNE     <ALAW

; Linear to log routine for mu-law
        ABS     A       A,B         ;Find |SR|, save sign
        ADD     Y0,A                ;Add bias
        ASL     A   #TAB+7,R0       ;Shift << 2, get seg ptr
        ASL     A   X:TAB+3,X0      ; and get max. word
        TES     X0,A                ;If overflow in extension
                                    ; set the maximum PCM word
        REP     #7                  ;Find MSB of data
        NORM    R0,A
        ASL     A       #<$20,Y0
        LSL     B       A1,X0
        MPY     X0,Y0,A     X:(R0),X1
        AND     X1,A
        ROR     A
        NOT     A       #<$FF,X0
        AND     X0,A
        MOVE    A1,A
        JMP     <SAVESP

; Linear to log routine for A-law
ALAW    MOVE    #$FFFF00,X0
        AND     X0,A
        ABS     A       A,B         ;Find |SR|, save sign
        TST     B       #$000100,X0
        JPL     <NOSUB
        SUB     X0,A
NOSUB   MOVE    #$7FFE00,X0
        AND     X0,A
        ASL     A   #TAB+7,R0       ;Shift << 2, get seg ptr
        ASL     A   X:TAB+3,X0      ; and get max. word
        TES     X0,A                ;If overflow in extension
                                    ; set the maximum PCM word
        REP     #6                  ;Find MSB of data
        NORM    R0,A
        JNR     <SEGOK
        MOVE    (R0)-
SEGOK   LSL     A       #<$20,Y0
        LSL     B       A1,X0
        MPY     X0,Y0,A     X:(R0),X1
        AND     X1,A
        ROR     A       #<$D5,Y1
        EOR     Y1,A    #<$FF,X0    ;Invert even bits & sign
        AND     X0,A
        MOVE    A1,A
SAVESP  RTS

;**************************************************************************
;       INIT
;
; Initialize program variables, transfer data tables to X and Y
; memory, and set up registers
;
;**************************************************************************

INIT    MOVE    A,R0
        REP     #$7F                ;Clear internal data RAM
        MOVE    A,L:(R0)+

; X memory initialization

        MOVE    #DATA_T,A0          ;Set transmit data pointer
        MOVE    A0,X:DATAPTR_T      ; to start of transmit data buffer
        MOVE    #DATA_R,A0          ;Set receive data pointer
        MOVE    A0,X:DATAPTR_R      ; to start of receive data buffer

        MOVE    #$3E2000,X0
        MOVE    X0,X:AP_T           ;Initialize speed control parameters
        MOVE    X0,X:AP_R

        MOVE    #VARINIT,R0         ;Copy constant tables into
        MOVE    #QUANTAB,R3         ; X memory
        DO      #40,XTABLES
        MOVE    P:(R0)+,X0
        MOVE    X0,X:(R3)+
XTABLES

; Y memory initialization

        MOVE    #$088000,X0
        MOVE    X0,Y:YU_T           ;Initialize quantizer scale factors
        MOVE    X0,Y:YL_T
        MOVE    X0,Y:YU_R
        MOVE    X0,Y:YL_R

        MOVE    #RSHFT,R3           ;Copy shift constant table into
        DO      #24,YTABLES         ; Y memory
        MOVE    P:(R0)+,X0
        MOVE    X0,Y:(R3)+
YTABLES

        MOVEC   #7,M2               ;Set data buffer for mod(7)
        MOVEC   #7,M6               ;Set coef buffer for mod(7)
        MOVEC   #$7F,M3             ;Set PCM table for mod(127)
        MOVE    #0,A                ;Select mu-law or A-law,
        MOVE    A,Y:LAW             ; for mu-law set LAW=0 (default),
                                    ; for A-law set LAW!=0
        TST     A       #$100,R3    ;If LAW=0 select mu-law table
        JEQ     <IOINIT             ; base (in X ROM), otherwise
        MOVE    #$180,R3            ; select A-law table base

IOINIT  MOVEP   #$00000F,X:PBD      ;Initialize PB0..3
        MOVEP   #$00000F,X:PBDDR    ;Set PB0..3 for outputs

        MOVEP   #$003200,X:CRB      ;Set up SSI mode
        MOVEP   #$000000,X:CRA      ;Set up SSI rate
        MOVEP   #$0001E0,X:PCC      ;Enable SSI output pins
        MOVEP   #0,X:SSITX          ;Dummy write to SSI transmitter
        RTS

; QUANTAB
VARINIT     DC      $F84000         ;-0.98
            DC      $050000         ;0.62
            DC      $0B2000         ;1.38
            DC      $0F6000         ;1.91
            DC      $12C000         ;2.34
            DC      $15D000         ;2.72
            DC      $190000         ;3.12
            DC      $7FFFFF         ;15.99

; IQUANTAB
            DC      $800000         ;-16    |I|=0
            DC      $004000         ;0.031  |I|=1
            DC      $087000         ;1.05   |I|=2
            DC      $0D5000         ;1.66   |I|=3
            DC      $111000         ;2.13   |I|=4
            DC      $143000         ;2.52   |I|=5
            DC      $175000         ;2.91   |I|=6
            DC      $1A9000         ;3.32   |I|=7

; WIBASE
            DC      $FF4000         ;-0.75  |I|=0
            DC      $012000         ;1.13   |I|=1
            DC      $029000         ;2.56   |I|=2
            DC      $040000         ;4.00   |I|=3
            DC      $070000         ;7.00   |I|=4
            DC      $0C6000         ;12.38  |I|=5
            DC      $163000         ;22.19  |I|=6
            DC      $462000         ;70.13  |I|=7

; FIBASE
            DC      $000000         ;0  |I|=0
            DC      $000000         ;0  |I|=1
            DC      $000000         ;0  |I|=2
            DC      $100000         ;1  |I|=3
            DC      $100000         ;1  |I|=4
            DC      $100000         ;1  |I|=5
            DC      $300000         ;3  |I|=6
            DC      $700000         ;7  |I|=7

; TAB
            DC      $1E0000
            DC      $3E0000
            DC      $5E0000
            DC      $7E0000
            DC      $9E0000
            DC      $BE0000
            DC      $DE0000
            DC      $FE0000

; RSHFT
            DC      $800000
            DC      $400000         ;>>1    <<23
            DC      $200000         ;>>2    <<22
            DC      $100000         ;>>3    <<21
            DC      $080000         ;>>4    <<20
            DC      $040000         ;>>5    <<19
            DC      $020000         ;>>6    <<18
            DC      $010000         ;>>7    <<17
            DC      $008000         ;>>8    <<16
            DC      $004000         ;>>9    <<15
            DC      $002000         ;>>10   <<14
            DC      $001000         ;>>11   <<13
            DC      $000800         ;>>12   <<12
            DC      $000400         ;>>13   <<11
            DC      $000200         ;>>14   <<10
            DC      $000100         ;>>15   <<9
            DC      $000080         ;>>16   <<8
            DC      $000040         ;>>17   <<7
            DC      $000020         ;>>18   <<6
            DC      $000010         ;>>19   <<5
            DC      $000008         ;>>20   <<4
            DC      $000004         ;>>21   <<3
            DC      $000002         ;>>22   <<2
            DC      $000001         ;>>23   <<1
