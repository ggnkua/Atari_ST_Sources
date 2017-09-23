;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
;**************************************************************************
;
;   ADPCM.ASM       Full-Duplex 32-kbit/s CCITT ADPCM Algorithm
;
; Version 1.0 - 1/27/89
;
; This program implements the algorithm defined in CCITT Recommendation
; G.721: "32 kbit/s Adaptive Differential Pulse Code Modulation" dated
; August 1986. This version passes all of the mu-law and A-law test
; sequences as defined in Appendix II of Recommendation G.721.
;
; Please refer to the file ADPCM.HLP for further information about
; this program.
;
;**************************************************************************

            OPT     CC,CEX                                                                         

START       EQU     $0040

            ORG     X:$0000

;******************** Encoder variables ***********************************
;   I = siii 0000 | 0000 0000 | 0000 0000 (ADPCM format)
I_T         DS      1               ;ADPCM codeword
;   DQ = siii iiii | iiii iii.0 | 0000 0000  (15SM)
DQ_T        DS      1               ;Quantized difference signal
;   Y = 0iii i.fff | ffff ff00 | 0000 0000  (13SM)
Y_T         DS      1               ;Quantizer scale factor
;   AP = 0ii.f ffff | fff0 0000 | 0000 0000  (10SM)
AP_T        DS      1               ;Unlimited speed control parameter
;   AL = 0i.ff ffff | 0000 0000 | 0000 0000  (7SM)
AL_T        DS      1               ;Limited speed control parameter

;******************** Decoder variables ***********************************
I_R         DS      1               ;ADPCM codeword
DQ_R        DS      1               ;Quantized difference signal
Y_R         DS      1               ;Quantizer scale factor
AP_R        DS      1               ;Unlimited speed control parameter
AL_R        DS      1               ;Limited speed control parameter
;   SP = psss qqqq | 0000 0000 | 0000 0000 (PCM log format)
SP_R        DS      1               ;PCM reconstructed signal

;******************** Temporary variables *********************************
;   IMAG = 0iii. 0000 | 0000 0000 | 0000 0000
IMAG        DS      1               ;|I|
;   PKS1 = sXXX XXXX | XXXX XXXX | 0000 0000  (1TC)
PKS1        DS      1               ;XOR of  PK0 & PK1
;   PKS2 = sXXX XXXX | XXXX XXXX | 0000 0000  (1TC)
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

;******************** Table used in COMPRESS ******************************

TAB         DS      8

;******************** Constants used by FMULT *****************************

CONST       DS      6

;******************** Encoder data buffer *********************************
; DQn (11FL) stored separately as exponent, mantissa, and sign
;    DQnEXP = 0000 0000 | 0000 0000 | 0000 eeee
;    DQnMANT = 01mm mmm0 | 0000 0000 | 0000 0000
;    DQnS = sXXX XXXX | XXXX XXXX | 0000 0000
; SRn in same format
DATA_T      DSM     24              ;24 word modulo buffer for data,
                                    ; R2 is used as pointer, DATAPTR_T
                                    ; points to start of buffer (DQ1EXP)
                                    ; at beginning of cycle
                                    ;DQ1EXP,DQ1MANT,DQ1S
                                    ;DQ2EXP,DQ2MANT,DQ2S
                                    ;DQ3EXP,DQ3MANT,DQ3S
                                    ;DQ4EXP,DQ4MANT,DQ4S
                                    ;DQ5EXP,DQ5MANT,DQ5S
                                    ;DQ6EXP,DQ6MANT,DQ6S
                                    ;SR1EXP,SR1MANT,SR1S
                                    ;SR2EXP,SR2MANT,SR2S

;******************** Encoder partial product buffer **********************
;   WBn = siii iiii | iiii iii.f | 0000 0000  (16TC)
;   WAn in same format
PP_T        DSM     8               ;8 word modulo buffer for partial
                                    ; products, R1 is used as pointer
                                    ;WB1
                                    ;WB2
                                    ;WB3
                                    ;WB4
                                    ;WB5
                                    ;WB6
                                    ;WA1
                                    ;WA2

;******************** Decoder data buffer *********************************
DATA_R      DSM     24              ;24 word modulo buffer for data
                                    ; (same format as DATA_T)

;******************** Decoder partial product buffer **********************
PP_R        DSM     8               ;8 word modulo buffer for partial products
                                    ; (same format as PP_T)
    

            ORG     Y:$0000
;******************** Encoder variables ***********************************
;   SE = siii iiii | iiii iii.0 | 0000 0000  (15TC)
SE_T        DS      1               ;Signal estimate
;   SEZ = siii iiii | iiii iii.0 | 0000 0000 (15TC)
SEZ_T       DS      1               ;Partial signal estimate
;   SR = siii iiii | iiii iiii. | 0000 0000  (16TC)
SR_T        DS      1               ;Reconstructed signal
;   PK0 = sXXX XXXX | XXXX XXXX | 0000 0000  (1TC)
PK0_T       DS      1               ;Sign of DQ + SEZ
;   PK1 = sXXX XXXX | XXXX XXXX | 0000 0000  (1TC)
PK1_T       DS      1               ;Delayed sign of DQ + SEZ
;   PK2 = sXXX XXXX | XXXX XXXX | 0000 0000  (1TC)
PK2_T       DS      1               ;Delayed sign of DQ + SEZ
;   DMS = 0iii. ffff | ffff f000 | 0000 0000  (12SM)
DMS_T       DS      1               ;Short term average of F(I)
;   DML = 0iii. ffff | ffff fff0 | 0000 0000  (14SM)
DML_T       DS      1               ;Long term average of F(I)
;   TDP = i000 0000 | 0000 0000 | 0000 0000  (1TC)
TDP_T       DS      1               ;Tone detect
;   TD = i000 0000 | 0000 0000 | 0000 0000  (1TC)
TD_T        DS      1               ;Delayed tone detect
;   YU =  0iii i.fff | ffff ff00 | 0000 0000  (13SM)
YU_T        DS      1               ;Fast quantizer scale factor
;   YL =  0iii i.fff | ffff ffff | ffff 0000  (19SM)
YL_T        DS      1               ;Slow quantizer scale factor
;   SIGPK = i000 0000 | 0000 0000 | 0000 0000  (1TC)
SIGPK_T     DS      1               ;Sgn[p(k)] flag
;   A2P = si.ff ffff | ffff ffff | 0000 0000 (16TC)
A2P_T       DS      1               ;Second order predictor coef
;   TR = i000 0000 | 0000 0000 | 0000 0000  (1TC)
TR_T        DS      1               ;Transition detect

;******************** Decoder variables ***********************************
SE_R        DS      1               ;Signal estimate
SEZ_R       DS      1               ;Partial signal estimate
SR_R        DS      1               ;Reconstructed signal
PK0_R       DS      1               ;Sign of DQ + SEZ
PK1_R       DS      1               ;Delayed sign of DQ + SEZ
PK2_R       DS      1               ;Delayed sign of DQ + SEZ
DMS_R       DS      1               ;Short term average of F(I)
DML_R       DS      1               ;Long term average of F(I)
TDP_R       DS      1               ;Tone detect
TD_R        DS      1               ;Delayed tone detect
YU_R        DS      1               ;Fast quantizer scale factor
YL_R        DS      1               ;Slow quantizer scale factor
SIGPK_R     DS      1               ;Sgn[p(k)] flag
A2P_R       DS      1               ;Second order predictor coef
TR_R        DS      1               ;Transition detect

;******************** Temporary variables *********************************
LAW         DS      1               ;Select A-law or mu-law
DQMAG       DS      1               ;|DQ|

;******************** Shift constant lookup table *************************
; Shift constants used for doing left or right shifts by multiplying by a
; power of 2.  For right shift, some routines use R5 as a base and N5 as
; and offset for lookup of shift constant.
RSHFT       DS      24
LSHFT

;******************** Misc. constants *************************************
CONST1      DS      3
CONST4      DS      4
CONST8      DS      9
CONST17     DS      16

;******************** Encoder coef. buffer ********************************
;   Bn = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;   An in same format
COEF_T      DSM     8               ;8 word modulo buffer for coefs.,
                                    ; R6 is used as pointer
                                    ;B1
                                    ;B2
                                    ;B3
                                    ;B4
                                    ;B5
                                    ;B6
                                    ;A1
                                    ;A2

;******************** Decoder coef. buffer ********************************
COEF_R      DSM     8               ;8 locations for coef. queue
                                    ; (same format as COEF_T)

            PAGE

            ORG     P:$0000
            JMP     START

            ORG     P:START

        CLR     A
        MOVEC   #$06,OMR            ;Enable internal ROM tables
        MOVEP   A,X:$FFFE           ;Set BCR for 0 wait states
        JSR     INIT

;**************************************************************************
;
;   Encoder
;
;**************************************************************************

ENCODE  MOVE    #PP_T,R1            ;Set partial product ptr to WB1
        MOVE    X:DATAPTR_T,R2      ;Set data pointer to DQ1EXP
        MOVE    #COEF_T,R6          ;Set coef pointer to B1
        MOVE    #CONST1,R7          ;Set pointer to misc constants

;**************************************************************************
;       FMULT
;
; Multiply predictor coefficients with corresponding
;   quantized difference signal or reconstructed signal
;
;   Data (DQn or SRn) is stored in 11FL format (separate),
;   & coefficient (Bn or An) is stored in 16TC format.
;
; Computes  [An(k-1) * SR(k-n)] or [Bn(k-1) * DQ(k-n)]
;
; Flow Description:
;   1. Convert 16TC An to 13SM AnMAG
;   2. Convert 13SM AnMAG to 10FL (AnEXP and AnMANT)
;   3. Add SRnEXP to AnEXP to get WAnEXP (5-bits)
;   4. Multiply SRnMANT with AnMANT, add '48', and truncate
;       to 8-bits to get WAnMANT
;   5. Convert 13FL (WAnEXP & WAnMANT) to 15SM WAnMAG
;   6. XOR AnS with SRnS to find WAnS
;   7. Convert 16SM (WAnMAG & WAnS) to 16TC WAn
;
; Input:
;   SRn = (11FL)
;    SRnEXP = X:(R2) = 0000 0000 | 0000 0000 | 0000 eeee
;    SRnMANT = X:(R2+1) = 01mm mmm0 | 0000 0000 | 0000 0000
;    SRnS = X:(R2+2) = sXXX XXXX | XXXX XXXX | 0000 0000
;       (DQ in same format as SR)
;
;   An = Y:(R6) = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;       (Bn in same format as An)
;
; Output:
;   WAn = X:(R1) = siii iiii | iiii iii.f | 0000 0000  (16TC)
;       (WBn in same format as WAn)
;
;**************************************************************************

        MOVE    #CONST,R0           ;Set pointer to FMULT constants
        MOVE    #0,Y1
        DO      #8,ACCUM_T          ;Execute mult 8 times

; 1. Convert 16TC An to 13SM AnMAG
        MOVE    X:(R0)+,X1  Y:(R6),A    ;Get An and mask KF1
        AND     X1,A    X:(R0)+,X1  ;Truncate An to 13 bits (An>>2),
                                    ; get mask KF2
        ABS     A       #$000D,R4   ;Find AnMAG, load
                                    ; exponent bias (13) into R4
        AND     X1,A    #<$7E,X1    ;Truncate any ovrflw, get mask
;   A1 = 0i.ff ffff | ffff ff00 | 0000 0000 (A2=A0=0)

; 2. Convert 13SM AnMAG to 10FL (AnEXP and AnMANT)
        JNE     <NORMAN_T           ;Test AnMAG
        MOVE    #<$40,A             ;If AnMAG=0, set AnMANT=1<<5,
        MOVE    #0,R4               ; and AnEXP=0
        JMP     <CONTIN_T
NORMAN_T    NORM    R4,A            ;If AnMAG!=0 do NORM iteration
        NORM    R4,A                ; 12 times to find MSB
        NORM    R4,A
        NORM    R4,A
        NORM    R4,A
        NORM    R4,A
        NORM    R4,A
        NORM    R4,A
        NORM    R4,A
        NORM    R4,A
        NORM    R4,A
        NORM    R4,A
;   A1 = 01?? ???? | ???? ??00 | 0000 0000 = AnMANT
;   R4 = 0000 0000 | 0000 eeee = AnEXP
CONTIN_T    AND     X1,A    R4,B    ;Truncate AnMANT to 6 bits,
                                    ; move AnEXP to B
;   A1 = 01mm mmm0 | 0000 0000 | 0000 0000 (A2=A0=0)
;   B1 = 0000 0000 | 0000 0000 | 0000 eeee (B2=B0=0)

; 3. Add SRnEXP to AnEXP to get WAnEXP (5-bits)
        MOVE    X:(R2)+,X1  A,Y0    ;Get SRnEXP
        ADD     X1,B    X:(R2)+,X1  ;Find WAnEXP=SRnEXP+AnEXP,
                                    ; get SRnMANT 
;   B1 = 0000 0000 | 0000 0000 | 000e eeee (B2=B0=0)

; 4. Multiply SRnMANT with AnMANT, add '48', and truncate
;       to 8-bits to get WAnMANT
;   Y0 = 01mm mmm0 | 0000 0000 | 0000 0000
;   X1 = 01mm mmm0 | 0000 0000 | 0000 0000
        MPY     Y0,X1,A     X:(R0)+,X0  ;Find WAnMANT, get '48' (KF3)
;   A1 = 0mmm mmmm | mmmm m000 | 0000 0000 (A2=A0=0)
;   X0 = 0000 0001 | 1000 0000 | 0000 0000 = '48'
        ADD     X0,A        X:(R0)+,X0  ;Add '48' to WAnMANT, get mask KF4
        AND     X0,A        X:(R0)+,X0  ;Truncate WAnMANT to 8 bits,
                                        ; get '26' (KF5)
;   A1 = 0mmm mmmm | m000 0000 | 0000 0000 (A2=A0=0)

; 5. Convert 13FL (WAnEXP & WAnMANT) to 15SM WAnMAG
;   X0 = 0000 0000 | 0000 0000 | 0001 1010 = '26'
;   B1 = 0000 0000 | 0000 0000 | 000e eeee (B2=B0=0) 
        SUB     X0,B    X:(R0)+,X0  ;Find shift offset (WAnEXP-26),
                                    ; get mask KF6
        JEQ     <TRUNC_T            ;If offset=26 no shift
        JMI     <RIGHT_T            ;If offset<26 do right shift
                                    ;Else offset>26, do left shift
        REP     B1                  ;Offset>26, shift WAnMANT
        LSL     A                   ; left up to 4 times
        JMP     <TRUNC_T
RIGHT_T ABS     B       #>$0F,Y0    ;Find |offset|, get '15'
        CMP     Y0,B    B1,N5       ;Compare |offset| to '15',
                                    ; load offset for shift
        TGE     Y1,A                ;If |offset|>=15 WAnMAG=0
        MOVE    A1,X1               ;Move WAnMANT for shift
        MOVE    Y:(R5+N5),Y0        ;Lookup shift constant
        MPY     Y0,X1,A             ;Shift WAnMANT right up to 14 times
;   A1 = ?mmm mmmm | mmmm mmmm | ???? ???? (A2=A0=0)
TRUNC_T AND     X0,A    X:(R2)+,X1  Y:(R6)+,B   ;Truncate WAnMAG to 15 bits,
                                    ; get SRnS & AnS
;   A1 = 0iii iiii | iiii iii.f | 0000 0000 (A2=A0=0)
        NEG     A   A1,X0           ;Find -WAnMAG, save WAnMAG

; 6. XOR AnS with SRnS to find WAnS
;   B1 = sXXX XXXX | XXXX XXXX | 0000 0000 (B2=sign ext, B0=0)
;   X1 = sXXX XXXX | XXXX XXXX | 0000 0000
        EOR     X1,B    #CONST,R0   ;Find WAnS (in MSB of B),
                                    ; update pointer to constants

; 7. Convert 16SM (WAnMAG & WAnS) to 16TC WAn
        TPL     X0,A                ;If WAnS=0 use WAnMAG, else use -WAnMAG
;   A1 = siii iiii | iiii iii.f | 0000 0000  (A2=sign ext, A0=0)
        MOVE    A1,X:(R1)+          ;Save WAn

;**************************************************************************
;       ACCUM
;
; Add predictor outputs to form the partial signal estimate
;   and the signal estimate
;
; SEZ(k) = [B1(k-1) * DQ(k-1)] + ... + [B6(k-1) * DQ(k-6)]
;        = WB1 + WB2 + ... + WB6
;
; SE(k) = SEZ(k) + [A1(k-1) * SR(k-1)] + [A2(k-1) * SR(k-2)]
;       = SEZ + WA1 + WA2
;
; Inputs:
;   WBn & WAn = X:(R1) = siii iiii | iiii iii.f | 0000 0000  (16TC)
;
; Outputs:
;   SEZ = siii iiii | iiii iii.0 | 0000 0000  (15TC)
;   SE = siii iiii | iiii iii.0 | 0000 0000  (15TC)
;
;**************************************************************************

ACCUM_T MOVE    X:(R1)+,A           ;Get WB1
        MOVE    X:(R1)+,X0          ;Get WB2
        ADD     X0,A    X:(R1)+,X0  ;Accumulate WB1&WB2, get WB3
        ADD     X0,A    X:(R1)+,X0  ;Accumulate WB3, get WB4
        ADD     X0,A    X:(R1)+,X0  ;Accumulate WB4, get WB5
        ADD     X0,A    X:(R1)+,X0  ;Accumulate WB5, get WB6
        ADD     X0,A    X:(R1)+,X0  ;Accumulate WB6 to get SEZI, get WA1
        TFR     A,B     Y:(R7)+,X1  ;Copy SEZI, get mask K1
        AND     X1,B    X:AP_T,Y0   ;Truncate SEZI, get AP
        ADD     X0,A    X:(R1)+,X0  ;Accumulate WA1, get WA2
        ADD     X0,A    B1,Y:SEZ_T  ;Accumulate WA2 to get SEI, save SEZ
        AND     X1,A    #<$20,X0    ;Truncate SEI, get '1'
        TFR     Y0,A    A1,Y:SE_T   ;Move AP, save SE

;**************************************************************************
;       LIMA
;
; Limit speed control parameter
;
; AL(k) = 1        if AP(k-1) > 1
;       = AP(k-1)  if AP(k-1) <= 1
;
; Inputs:
;   AP = 0ii.f ffff | fff0 0000 | 0000 0000  (10SM)
;
; Outputs:
;   AL = 0i.ff ffff | 0000 0000 | 0000 0000  (7SM)
;
;**************************************************************************

        CMP     X0,A    Y:YL_T,B    ;Test AP, get YL
        TGT     X0,A                ;If AP>'1' set AL='1'
        LSL     A       #<$7F,X0    ;Shift to align radix pt., get mask
        AND     X0,A    Y:(R7)+,X0  ;Truncate AL (AP>>2), get mask K2

;**************************************************************************
;       MIX
;
; Form linear combination of fast and slow quantizer
;   scale factors
;
; Y(k) = AL(k) * YU(k-1) + [1 - AL(k)] * YL(k-1)
;
; Inputs:
;   YL = 0iii i.fff | ffff ffff | ffff 0000  (19SM)
;   AL = 0i.ff ffff | 0000 0000 | 0000 0000  (7SM)
;   YU = 0iii i.fff | ffff ff00 | 0000 0000  (13SM)
;
; Outputs:
;   Y = 0iii i.fff | ffff ff00 | 0000 0000  (13SM)
;
;**************************************************************************

        AND     X0,B    A,X0    Y:YU_T,A    ;Truncate YL (YL>>6), get YU
        SUB     B,A     B,Y1    X0,X:AL_T   ;Find DIF=YU-YL, save YL, get AL
        ABS     A       A,B         ;Find DIFM=|DIF|, save DIFS
        MOVE    A1,Y0
        MPY     X0,Y0,A     Y:(R7)+,X0  ;Find DIFM*AL, get mask K3
        AND     X0,A                ;Truncate to find PRODM=(DIFM*AL)>>6
        NEG     A   A1,X0           ;Find -PRODM, save PRODM
        TST     B                   ;Check DIFS
        TPL     X0,A                ;If DIFS=0 PROD=PRODM,
                                    ; else PROD=-PRODM
        ASL     A   Y1,B            ;Line up radix point
        ADD     Y1,A                ;Find Y=PROD+(YL>>6)
        MOVE    A,X:Y_T             ;Save Y

;**************************************************************************
;
; Input PCM data (S) here. For simulation purposes the Input 
; Word from File subroutine on the 56001 ADS board is used.
;
;**************************************************************************

        MOVE    #1,X0               ;Input PCM word (S)
        JSR     $E002

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

        MOVE    A,X0    Y:(R7)+,Y1  ;Get shift constant K4
        MPY     X0,Y1,A     Y:(R7)+,X1  ;Shift S to 8 lsb's of A1, get K5
        AND     X1,A    Y:SE_T,B    ;Mask off sign of S, get SE
        ASR     B       A1,N3       ;sign extend SE, load |S| as offset
        CMPM    Y1,A                ;Check sign of S
        MOVE    X:(R3+N3),A         ;Lookup |SL| from ROM table
        JGE     <SUBTA_T            ;If S=0, SL=|SL|
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
;   SL = siii iiii | iiii ii.00 | 0000 0000  (14TC) 
;   SE = siii iiii | iiii iii.0 | 0000 0000  (15TC)
;
; Output:
;   D = siii iiii | iiii iiii. | 0000 0000  (16TC)
;**************************************************************************

SUBTA_T ASR     A       Y:(R7)+,X1  ;Sign extend SL, get mask K6
        ASR     A       #$000E,R0   ;Sign extend SE again, get exp bias (14)
        SUB     B,A     X:Y_T,B     ;Find D=SL-SE, get Y

;**************************************************************************
;       LOG
;
; Convert difference signal from the linear to the log
;   domain
;
; Input:
;   D = siii iiii | iiii iiii. | 0000 0000  (16TC)
;
; Outputs:
;   DL = 0iii i.fff | ffff 0000 | 0000 0000  (11SM)
;   DS = sXXX XXXX | XXXX XXXX | 0000 0000  (1TC)
;
;**************************************************************************

        ABS     A   A,Y1            ;Find DQM=|D|, save DS to Y1
        JNE     <NORMEXP_T          ;Check for DQM=0
        CLR     A       (R7)+       ;If DQM=0 set DL=0,
        MOVE    Y:(R7),X0           ; get mask K8,
        JMP     <SUBTB_T            ; and continue
NORMEXP_T   NORM    R0,A            ;If DQM!=0, do norm iteration
        NORM    R0,A                ; 14 times to find MSB of DQM
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
;   A1 = 01?? ???? | ???? ???? | 0000 0000 = normalized DQM  (A2=A0=0)
;   R0 = 0000 0000 | 0000 eeee = exponent of normalized DQM

;   Get rid of leading "1" in normalized DQM
;   Truncate mantissa to 7 bits and combine with exponent
        AND     X1,A    Y:LSHFT-19,X0   ;Truncate MANT, get EXP shift
;   A1 = 00mm mmmm | m000 0000 | 0000 0000 (A2=A0=0)
        MOVE    R0,X1               ;Move EXP to X1
        MPY     X0,X1,A     A,X1    Y:(R7)+,Y0 ;Shift EXP<<19, save MANT to X1,
                                    ; get mask K7
        MOVE    A0,A                ;Move EXP to A1
;   A1 = 0eee e000 | 0000 0000 | 0000 0000 (A2=A0=0)
        MAC     Y0,X1,A     Y:(R7),X0   ;Shift MANT>>3 & combine with EXP,
                                        ; get mask K8
;   A1 = 0eee e.mmm | mmmm 0000 | 0000 0000  (A2=A0=0)
;      = 0iii i.fff | ffff 0000 | 0000 0000  (A2=A0=0)

;**************************************************************************
;       SUBTB
;
; Scale log version of difference signal by subtracting
;   scale factor
;
; DLN = DL - Y
;
; Inputs:
;   DL = 0iii i.fff | ffff 0000 | 0000 0000  (11SM)
;   Y = 0iii i.fff | ffff ff00 | 0000 0000  (13SM)
;
; Output:
;   DLN = siii i.fff | ffff 0000 | 0000 0000 (12TC)
;
;**************************************************************************

SUBTB_T AND     X0,B    #QUANTAB,R0     ;Truncate Y to 11 bits (Y>>2),
                                        ; get quantization table base
        SUB     B,A     #>QUANTAB+2,X1  ;Find DLN=DL-Y,
                                        ; get offset for quan. conversion

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
;   DLN = siii i.fff | ffff 0000 | 0000 0000 (12TC)
;   DS = sXXX XXXX | XXXX XXXX | 0000 0000  (1TC)
;
; Output:
;   I = siii 0000 | 0000 0000 | 0000 0000 (ADPCM format)
;
;**************************************************************************

        MOVE    X:(R0)+,X0          ;Get quan table value
TSTDLN_T    CMP     X0,A    X:(R0)+,X0  ;Compare to DLN
        JGE     <TSTDLN_T           ;If value<DLN try next range
        MOVE    R0,A                ;When range found...
                                    ; subtract pointer from
        SUB     X1,A    Y:LSHFT-20,X0   ; base to get IMAG=|I|  
;   A1 = 0000 0000 | 0000 0000 | 0000 0iii (A2=A0=0)
        MOVE    A1,X1
        MPY     X0,X1,A     Y1,B    ;Shift IMAG <<20, result is
                                    ; in A0, move DS (from LOG) into B
        MOVE    A0,A
;   A1 = 0iii 0000 | 0000 0000 | 0000 0000 (A2=A0=0)
        MOVE    A1,X:IMAG           ;Save IMAG
        TST     A       #<$F0,X0    ;Check IMAG, get invert mask
        JEQ     <INVERT_T           ;If IMAG=0 invert bits
        TST     B                   ;If IMAG!=0, check DS
        JPL     <IOUT_T             ;If DS=1 don't invert IMAG
INVERT_T    EOR     X0,A            ;If DS=0 or IMAG=0,
                                    ; invert IMAG
IOUT_T  MOVE    A1,A                ;Adjust sign extension
        
;**************************************************************************
;
; Output ADPCM data (I) here. For simulation purposes the Output 
; Word to File subroutine on the 56001 ADS board is used.
;
;**************************************************************************

        MOVE    #1,X0               ;Output ADPCM word (I)
        JSR     $E004

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
;
;**************************************************************************

        MOVE    A,Y1    A,X:I_T     ;Save DQS (sign of I) to Y1
        MOVE    #IQUANTAB,R4        ;Set lookup table base
;   X1 = 0000 0000 | 0000 0000 | 0000 0iii = |I| (from QUAN)
        MOVE    X1,N4               ;Load |I| as offset
        MOVE    X:Y_T,B             ; into IQUAN table, get Y
        MOVE    X:(R4+N4),A         ;Lookup DQLN

;**************************************************************************
;       ADDA
;
; Add scale factor to log version of quantized difference
;   signal
;
; DQL = DQLN + Y
;
; Inputs:
;   Y = 0iii i.fff | ffff ff00 | 0000 0000  (13SM)
;   DQLN = siii i.fff | ffff 0000 | 0000 0000  (12TC)
;
; Output:
;   DQL = siii i.fff | ffff 0000 | 0000 0000  (12TC)
;
;**************************************************************************

        MOVE    Y:(R7)+,Y0          ;Get mask K8 for ADDA
        AND     Y0,B    Y:(R7)+,X0  ;Truncate Y to 11 bits (Y<<2),
                                    ; get mask K9
        ADD     B,A     #<$08,X1    ;Find DQL=DQLN+(Y<<2), get '1'
   
;**************************************************************************
;       ANTILOG
;
; Convert quantized difference signal from log to linear
;   domain
;
; Input:
;   DQL = siii i.fff | ffff 0000 | 0000 0000  (12TC)
;   DQS = sXXX 0000 | 0000 0000 | 0000 0000  (1TC)
;
; Outputs:
;   DQ = siii iiii | iiii iii.0 | 0000 0000  (15SM)
;
;**************************************************************************

        JPL     <CONVLOG_T          ;If DQL>=0 (DS=0) convert DQL,
                                    ; else DQL<0 (DS=1), set |DQ|=0
        TFR     Y1,A    #<$80,X0    ;Get DQS (MSB of I), get mask
        AND     X0,A    #0,B        ;Mask off DQS, set |DQ|=0
;   A1 = s000 0000 | 0000 0000 | 0000 0000  (A2=sign ext, A0=0)
        MOVE    B1,Y:DQMAG          ;Save DQMAG=|DQ|
        MOVE    (R7)+               ;Adjust constant pointer
        MOVE    (R7)+
        JMP     <SAVEDQ_T

CONVLOG_T   AND     X0,A    A,B     ;Find fractional part (DMN),
                                    ; save DS
;   A1 = 0000 0.fff | ffff 0000 | 0000 0000  (A2=A0=0)
        OR      X1,A    #<$78,X0    ;Add implied '1' to DMN to
                                    ; find DQT, get integer mask
;   A1 = 0000 1.fff | ffff 0000 | 0000 0000  (A2=A0=0)
        AND     X0,B    Y:RSHFT+19,Y0   ;Find integer part (DEX),
                                    ; get shift constant
;   B1 = 0iii i.000 | 0000 0000 | 0000 0000  (B2=B0=0)
        MOVE    B1,X0
        MPY     X0,Y0,B     Y:(R7)+,X0  ;Shift DEX>>19, get '10' (K10)
;   A1 = 0000 1.fff | ffff 0000 | 0000 0000  (A2=A0=0)
;   B1 = 0000 0000 | 0000 0000 | 0000 iiii.  (B2=B0=0)
        SUB     X0,B    Y:(R7)+,X0  ;Find DQT shift=DEX-'10',
                                    ; get mask K11
        JEQ     <TRUNCDQM_T         ;If DEX=10, no shift
        JLT     <SHFRDQ_T           ;If DEX<10, shift right
        REP     B1                  ;Else shift DQT left
        LSL     A                   ; up to 4 times
        JMP     <TRUNCDQM_T

SHFRDQ_T    NEG     B               ;Find 10-DEX
        MOVE    B1,N5               ;Use 10-DEX for shift lookup
        MOVE    A1,Y0
        MOVE    Y:(R5+N5),X1        ;Lookup shift constant
        MPY     X1,Y0,A             ;Shift DQT right up to 9 times
TRUNCDQM_T  AND     X0,A    #<$80,B ;Truncate to find DQMAG=|DQ|,
                                    ; get sign mask
;   A1 = 0iii iiii | iiii iii.0 | 0000 0000  (A2=A0=0)
        AND     Y1,B    A1,Y:DQMAG  ;Mask off DQS, save DQMAG           
;   B1 = s000 0000 | 0000 0000 | 0000 0000  (B2=?, B0=0)
        MOVE    B1,X0
        OR      X0,A                ;Add DQS to DQMAG to get DQ
;   A1 = siii iiii | iiii iii.0 | 0000 0000  (A2=?, A0=0)
SAVEDQ_T    MOVE    A1,X:DQ_T       ;Save DQ

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
;   YL = 0iii i.fff | ffff ffff | ffff 0000  (19SM)
;   DQ = siii iiii | iiii iii.0 | 0000 0000  (15SM)
;
; Output:
;   TR = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;
;**************************************************************************

        MOVE    Y:TD_T,A            ;Get TD
        TST     A   #0,A            ;Check TD, set TR=0
        JEQ     <SAVETR_T           ;If TD=0 save TR=0
                                    ; else test DQ and YL
        MOVE    Y:YL_T,A            ;Get YL
        TFR     A,B     Y:(R7)+,X0  ;Save YL, get mask K12
        AND     X0,A    #<$08,X0    ;Find YLFRAC (YL>>10), get '1'
        OR      X0,A    B,X1    Y:(R7)+,Y1  ;Add implied '1' to YLFRAC,
                                    ; get mask K13
        MPY     Y1,X1,B     Y:(R7)+,X0  ;Find YLINT=YL>>15, get '8' (K14)
        MOVE    B1,B                ;Adjust sign extension
        CMP     X0,B    Y:(R7)+,X0  ;Compare YLINT to '8', get '5' (K15)
        JGT     <MAXTHR_T           ;If YLINT>8 set maximum THR2
        SUB     X0,B                ;Find YLINT-5
        JEQ     <SETDQTHR_T         ;If YLINT=5 don't shift
        JLT     <RSHFT_T            ;If YLINT<5 shift right

        REP     B1                  ;Else shift YLFRAC left
        LSL     A                   ; up to 3 times to get THR1
        JMP     <SETDQTHR_T

MAXTHR_T    MOVE    #<$7C,A         ;Set maximum THR2 (31<<9)
        JMP     <SETDQTHR_T

RSHFT_T NEG     B                   ;Find 5-YLINT
        MOVE    B1,N5               ;Use 5-YLINT for shift lookup
        MOVE    A1,X0
        MOVE    Y:(R5+N5),X1        ;Lookup shift constant
        MPY     X0,X1,A             ;Shift YLFRAC right up to ? times
                                    ; to get THR1
SETDQTHR_T  TFR     A,B     Y:(R7)+,X0  ;Get mask K16
        LSR     B                   ;Find THR2>>1
        AND     X0,B                ;Truncate THR2>>1
        ADD     B,A     #0,X1       ;Find THR2+(THR2>>1)
        LSR     A                   ;Find (THR2+(THR2>>1)>>1
        AND     X0,A    Y:DQMAG,X0  ;Truncate to find DQTHR, get DQMAG
        CMP     X0,A    #<$80,A     ;Compare DQMAG to DQTHR, set TR=1
        TGT     X1,A                ;If DQMAG>DQTHR leave TR=1,
                                    ; else DQMAG<=DQTHR, set TR=0
SAVETR_T    MOVE    A1,Y:TR_T       ;Save TR

;**************************************************************************
;       ADDB
;
; Add quantized difference signal and signal estimate
;   to form reconstructed signal
;
; SR(k-n) = SE(k-n) + DQ(k-n)
;
; Inputs:
;   DQ = siii iiii | iiii iii.0 | 0000 0000  (15SM)
;   SE = siii iiii | iiii iii.0 | 0000 0000  (15TC)
;
; Output:
;   SR = siii iiii | iiii iiii. | 0000 0000  (16TC)
;
;**************************************************************************

        MOVE    Y:SE_T,B            ;Get SE
        ASR     B   X:DQ_T,A        ;Sign extend SE to get SEI, get DQS
        TST     A       Y:DQMAG,A   ;Check DQS, get DQMAG
        JPL     <SHFTDQ_T           ;If DQS=0 continue
        NEG     A                   ;Convert DQ to 2's comp
SHFTDQ_T    ASR     A               ;Sign extend DQ to get DQI
        ADD     A,B     #CONST17,R7 ;Find SR=DQ+SE, update const pointer

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
;   SEZ = siii iiii | iiii iii.0 | 0000 0000 (15TC)
;
; Output:
;   PK0 = sXXX XXXX | XXXX XXXX | 0000 0000  (1TC)
;   SIGPK = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;
;**************************************************************************

        MOVE    B1,Y:SR_T           ;Save SR
        MOVE    Y:SEZ_T,B           ;Get SEZ
        ASR     B                   ;Sign extend SEZ to SEZI
        ADD     B,A     #0,B        ;Find DQSEZ=DQ+SEZ,
                                    ; set SIGPK=0
        TST     A   #<$80,X0        ;Check DQSEZ, get '1'
        TEQ     X0,B                ;If DQSEZ=0, SIGPK=1,
                                    ; else SIGPK=0

        MOVE    Y:PK1_T,X0
        MOVE    X0,Y:PK2_T          ;Delay previous PK1
        MOVE    Y:PK0_T,X0
        MOVE    X0,Y:PK1_T          ;Delay previous PK0
        MOVE    A1,Y:PK0_T          ;Save new PK0
        MOVE    B1,Y:SIGPK_T        ;Save SIGPK
        EOR     X0,A    Y:PK2_T,X0  ;Find PKS1=PK0**PK1
                                    ; for UPA1 & UPA2
        MOVE    A1,X:PKS1           ;Save PKS1
        MOVE    Y:PK0_T,A
        EOR     X0,A    #3,N2       ;Find PKS2=PK0**PK2 for UPA2
        MOVE    A1,X:PKS2           ;Save PKS2
        MOVE    (R2)+               ;Adjust data buffer pointer so
        MOVE    (R2)+               ; that R2 points to DQ1S

;**************************************************************************
;       XOR
;
; Find one bit "exclusive or" of the sign of difference
;   signal and the sign of delayed difference signal.
;
; Un = sgn[DQ(k)] XOR sgn[DQ(k-n)]
;
; Inputs:
;   DQ = siii iiii | iiii iii.0 | 0000 0000 (15SM)
;   DQnS = X:(R2+n) sXXX XXXX | XXXX XXXX | 0000 0000
;
; Outputs:
;   Un = sXXX XXXX | XXXX XXXX | 0000 0000 (1TC)
;
;**************************************************************************
;**************************************************************************
;       UPB
;
; Update the coefficients of the sixth order predictor
;
; Bn(k) = [1-(2**-8)] * Bn(k-1)
;           + (2**-7) * sgn[DQ(k)] * sgn[DQ(k-n)]
;
; Inputs:
;   Bn = Y:(R6+n) = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;   DQ = siii iiii | iiii iii.0 | 0000 0000 (15SM)
;   Un = sXXX XXXX | XXXX XXXX | 0000 0000 (1TC)
;
; Outputs:
;   BnP = Y:(R6+n) = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;
;**************************************************************************

        MOVE    Y:DQMAG,A           ;Get DQMAG
        TST     A   X:DQ_T,Y0       ;Check DQMAG, get DQS
        JNE     <XORUPB_T           ;If DQMAG!=0 use section with XOR,
                                    ; else use section with no XOR
                                    ; (because UGBn=0 if DQMAG=0)

; UPB without XOR
        MOVE    Y:RSHFT+8,X1        ;Get shift constant
        MOVE    (R7)+               ;Adjust constant pointer
        MOVE    (R7)+
        MOVE    Y:(R7)+,X0          ;Get mask K19
        DO      #6,ENDLOOP_T        ;Do UPB for B1-B6
        MOVE    X:(R2)+N2,A     Y:(R6),Y1   ;Get Bn (& DQnS but don't use)
        MPY     X1,Y1,A             ;Find Bn>>8
        AND     X0,A                ;Truncate (Bn>>8)
        NEG     A                   ;Find UBn=ULBn=-(Bn>>8)
        ADD     Y1,A                ;Find BnP=Bn+UBn
        MOVE    A1,Y:(R6)+          ;Store BnP to Bn
ENDLOOP_T   JMP     <UPA2_T

; UPB with XOR
XORUPB_T    MOVE    Y:(R7)+,X0      ;Get +gain (K17)
        DO      #6,UPTR_T           ;Do UPB and XOR for B1-B6
        MOVE    X:(R2)+N2,A     Y:(R6),Y1   ;Get Bn & DQnS
        EOR     Y0,A    Y:(R7)+,X1  ;Find Un=DQS**DQnS (XOR),
                                    ; get -gain (K18)
        TPL     X0,A                ;If Un=0 set UGBn=+gain
        TMI     X1,A                ;If Un=1 set UGBn=-gain
        MOVE    Y:RSHFT+8,X1        ;Get shift constant
        MPY     X1,Y1,B     Y:(R7)-,X1  ;Shift Bn>>8, get mask K19
        AND     X1,B                ;Truncate (Bn>>8)
        NEG     B                   ;Find ULBn=-(Bn>>8)
        ADD     B,A                 ;Find UBn=UGBn+ULBn
        ADD     Y1,A                ;Find BnP=Bn+UBn
        MOVE    A1,Y:(R6)+          ;Store BnP to Bn
UPTR_T  MOVE    (R7)+               ;Adjust constant pointer
        MOVE    (R7)+

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
;   A1 = Y:(R6) = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;   A2 = Y:(R6+1) = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;   SIGPK = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;   PK0 = sXXX XXXX | XXXX XXXX | 0000 0000  (1TC)
;   PK1 = sXXX XXXX | XXXX XXXX | 0000 0000  (1TC)
;   PK2 = sXXX XXXX | XXXX XXXX | 0000 0000  (1TC)
;     (Note: PKS1 & PKS2 have been previously calculated)
;
; Outputs:
;   A2T = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;
;**************************************************************************

UPA2_T  MOVE    X:PKS2,A            ;Get PKS2=PK0**PK2
        TST     A   #<$10,Y0        ;Check PKS2, get '+1'
        MOVE    #<$F0,Y1            ;Get '-1'
        TPL     Y0,A                ;If PKS2=0, set UGA2A='+1'
        TMI     Y1,A                ;If PKS2=1, set UGA2A='-1'
        MOVE    A,X1    Y:(R6)+,A   ;Save UGA2A, get A1
        MOVE    Y:(R7)+,Y0          ;Get '+1.99' (K20)
        CMP     Y0,A    Y:(R7)+,Y1  ;Check A1, get '-1.99' (K21)
        TGT     Y0,A                ;If A1>=1/2, set FA1='1.99'
        CMP     Y1,A    X:PKS1,B    ;Check A1 again, get PKS1=PK0**PK1
        TLT     Y1,A                ;If A1<=-1/2, set FA1='-1.99'
        TST     B       #0,X0       ;Check PKS1
        JMI     <FINDSUM_T          ;If PKS1=1, FA=FA1
        NEG     A                   ; else PKS1=0, set FA=-FA1
FINDSUM_T   ADD     X1,A    Y:RSHFT+5,Y1    ;Find UGA2B=UGA2A+FA,
                                    ; get shift constant
        MOVE    A,X1
        MPY     X1,Y1,A     Y:(R7)+,X1  ;Find UGA2B>>7, get mask K22
        AND     X1,A    Y:SIGPK_T,B ;Truncate UGA2, get SIGPK
        TST     B   Y:(R6),Y0       ;Check SIGPK, get A2
        TMI     X0,A                ;If SIGPK=1, set UGA2=0
        MOVE    Y:RSHFT+7,X0        ;Get shift constant
        MPY     Y0,X0,B             ;Find A2>>7
        AND     X1,B                ;Truncate to find A2>>7
        NEG     B       #<$D0,X0    ;Find ULA2=-(A2>>7), get A2LL
        ADD     B,A     #<$30,X1    ;Find UA2=UGA2+ULA2, get A2UL
        ADD     Y0,A    Y:(R7)+,Y1  ;Find A2T=A2+UA2, get -gain (K23)

;**************************************************************************
;       LIMC
;
; Limit the A2 coefficient of the second order predictor.
;
;   |A2(k)| <= '0.75' 
;
; Inputs:
;   A2T = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;
; Outputs:
;   A2P = Y:(R6) = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;
;**************************************************************************

        CMP     X0,A    Y:(R7)+,Y0  ;Check A2P, get +gain (K24)
        TLT     X0,A                ;If A2P<-0.75, set A2P=-0.75
        CMP     X1,A    X:PKS1,B    ;Check A2P again, get PKS1=PK0**PK1
        TGT     X1,A                ;If A2P>0.75, set A2P=0.75
        MOVE    A,Y:A2P_T           ;Save A2P
        MOVE    A,Y:(R6)-           ;Save A2P to A2

;**************************************************************************
;       UPA1
;
; Update the A1 coefficient of the second order predictor.
;
; A1(k) = [1-(2**-8)] * A1(k-1)
;           + 3 * (2**-8) * sgn[P(k)] * sgn[P(k-1)]
;
; Inputs:
;   A1 = Y:(R6) = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;   SIGPK = Y:(R0) = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;   PK0 = sXXX XXXX | XXXX XXXX | 0000 0000  (1TC)
;   PK1 = sXXX XXXX | XXXX XXXX | 0000 0000  (1TC)
;     (Note: PKS1 has been previously calculated)
;
; Outputs:
;   A1T = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;
;**************************************************************************

        TST     B       Y:SIGPK_T,B ;Check PKS1, get SIGPK
        TPL     Y0,A                ;If PKS=0, set UGA1=+gain
        TMI     Y1,A                ;If PKS=1, set UGA1=-gain
        TST     B       #0,X0       ;Check SIGPK
        TMI     X0,A                ;If SIGPK=1, set UGA1=0
        MOVE    Y:(R6),X1           ;Get A1
        MOVE    Y:RSHFT+8,Y0        ;Get shift constant
        MPY     Y0,X1,B     Y:(R7)+,X0  ;Find A1>>8, get mask K25
        AND     X0,B                ;Truncate (A1>>8)
        NEG     B                   ;Find ULA1=-(A1>>8)
        ADD     B,A     #<$3C,B     ;Find UA1=UGA1+ULA1,
                                    ; get OME='1-(2**-4)'
        ADD     X1,A    Y:A2P_T,X0  ;Find A1T=A1+UA1, get A2P

;**************************************************************************
;       LIMD
;
; Limit the A1 coefficient of the second order predictor.
;
;   |A1(k)| <= [1-(2**-4)] - A2(k)
;
; Inputs:
;   A1T = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;   A2P = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;
; Outputs:
;   A1P = Y:(R6) = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;
;**************************************************************************

        SUB     X0,B                ;Find A1UL=OME-A2P
        CMP     B,A     B,X0        ;Check A1T
        TGT     X0,A                ;If A1T>A1UL, set A1P=A1UL
        NEG     B       (R2)+       ;Find A1LL=-A1UL=A2P-OME
        CMP     B,A     B,X0        ;Check A1T again
        TLT     X0,A                ;If A1T<A1LL, set A1P=A1LL
        MOVE    A1,Y:(R6)+          ;Store A1P to A1
        MOVE    (R6)+               ;Adjust coef pointer

;**************************************************************************
;       FLOATA
;
; Converts the quantized difference signal from 15-bit
;   signed magnitude to floating pt. format (11FL - sign,
;   exp, and mant stored separately)
;
; Inputs:
;   DQ = siii iiii | iiii iii.0 | 0000 0000 (15SM)
;
; Outputs:
;   DQ0 = (11FL)
;    DQ0EXP = X:(R2) = 0000 0000 | 0000 0000 | 0000 eeee
;    DQ0MANT = X:(R2+1) = 01mm mmm0 | 0000 0000 | 0000 0000
;    DQ0S = X:(R2+2) = sXXX XXXX | XXXX XXXX | 0000 0000
;
;**************************************************************************

        MOVE    X:DQ_T,Y0           ;Get DQS
        MOVE    Y:DQMAG,A           ;Get MAG=DQMAG
        TST     A   #$000E,R0       ;Check MAG, get exponent bias (14)
        JNE     <NORMDQ_T           ;Test MAG
        MOVE    #<$40,A             ;If MAG=0 set MANT=100000,
        MOVE    #0,R0               ; and EXP=0
        JMP     <TRUNCDQ_T
NORMDQ_T    NORM    R0,A            ;If MAG!=0 do NORM iteration 13
        NORM    R0,A                ; times to find MSB of MAG
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
;   A1 = 01?? ???? | ???? ???0 | 0000 0000 = normalized MAG (A2=A0=0)
;   R0 = 0000 0000 | 0000 eeee = exponent of normalized MAG

TRUNCDQ_T   MOVE    #<$7E,X0        ;Get mask
        AND     X0,A    R0,X:(R2)+  ;Truncate MANT to 6 bits,
                                    ; save EXP to DQ1EXP
;   A1 = 01mm mmm0 | 0000 0000 | 0000 0000  (A2=A0=0)
        MOVE    A1,X:(R2)+          ;Save MANT to DQ1MANT
        MOVE    Y0,X:(R2)+          ;Save DQ to DQ1S

;**************************************************************************
;       FLOATB
;
; Converts the reconstructed signal from 16-bit two's 
;   complement to floating pt. format (11FL - sign,
;   exp, and mant stored separately)
;
; Inputs:
;   SR = siii iiii | iiii iiii. | 0000 0000  (16TC)
;
; Outputs:
;   SR0 = (11FL)
;    SR0EXP = X:(R2) = 0000 0000 | 0000 0000 | 0000 eeee
;    SR0MANT = X:(R2+1) = 01mm mmm0 | 0000 0000 | 0000 0000
;    SR0S = X:(R2+2) = sXXX XXXX | XXXX XXXX | 0000 0000
;
;**************************************************************************

        MOVE    #15,N2
        MOVE    Y:SR_T,B            ;Get SR
        MOVE    (R2)+N2             ;Adjust data pointer
        ABS     B       B,Y0        ;Find MAG=|SR|, save SRS
        TST     B   #$000F,R0       ;Load exponent bias
        JNE     <NORMSR_T           ;Test MAG
        MOVE    #<$40,B             ;If MAG=0 set MANT=100000,
        MOVE    #0,R0               ; and EXP=0
        JMP     <TRUNCSR_T
NORMSR_T    NORM    R0,B            ;If MAG!=0 do NORM iteration 14
        NORM    R0,B                ; times to find MSB of MAG
        NORM    R0,B
        NORM    R0,B
        NORM    R0,B
        NORM    R0,B
        NORM    R0,B
        NORM    R0,B
        NORM    R0,B
        NORM    R0,B
        NORM    R0,B
        NORM    R0,B
        NORM    R0,B
        NORM    R0,B
;   A1 = 01?? ???? | ???? ???0 | 0000 0000  (A2=A0=0)
;   R0 = 0000 0000 | 0000 eeee = exponent of normalized MAG

TRUNCSR_T   AND     X0,B    R0,X:(R2)+  ;Truncate MANT to 6 bits,
                                    ; save EXP to SR1EXP
;   A1 = 01mm mmm0 | 0000 0000 | 0000 0000  (A2=A0=0)
        MOVE    B1,X:(R2)+          ;Save MANT to SR1MANT
        MOVE    Y0,X:(R2)+          ;Save SR to SR1S
        MOVE    #3,N2
        MOVE    Y:A2P_T,B           ;Get A2P
        MOVE    (R2)+N2             ;Adjust data pointer

;**************************************************************************
;       TONE
;
; Partial band signal detection
;
; TD(k) = 1 if A2(k) < -0.71875
;         0 otherwise
;
; Inputs:
;   A2P = si.ff ffff | ffff ffff | 0000 0000  (16TC)
;
; Output:
;   TDP = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;
;**************************************************************************

        CLR     A   #<$D2,X0        ;Get '-.71875', set TDP=0
        CMP     X0,B    #<$80,X1    ;Check A2P, get '1'
        TLT     X1,A                ;If A2P<-.71875 set TDP=1, else TDP=0
        MOVE    A1,Y:TDP_T          ;Save TDP
        MOVE    A1,Y:TD_T           ;Save TDP to TD

;**************************************************************************
;       TRIGB
;
; Predictor trigger block
;
; If TR(k) = 1, An(k)=Bn(k)=TD(k)=0
;
; Inputs:
;   TR = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;   BnP = si.ff ffff | ffff ffff | 0000 0000  (16TC)
;   AnP = si.ff ffff | ffff ffff | 0000 0000  (16TC)
;   TDP = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;
; Output:
;   BnR = si.ff ffff | ffff ffff | 0000 0000  (16TC)
;   AnR = si.ff ffff | ffff ffff | 0000 0000  (16TC)
;   TDR = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;
;**************************************************************************

        MOVE    Y:TR_T,B            ;Get TR
        TST     B       #0,A        ;Test TR
        JEQ     <FUNCTF_T           ;If TR=0 continue
        MOVE    A,Y:TD_T            ;If TR=1, set TDR=0,
        MOVE    A,Y:(R6)+           ; and B1-B6,A1,A2=0
        MOVE    A,Y:(R6)+
        MOVE    A,Y:(R6)+
        MOVE    A,Y:(R6)+
        MOVE    A,Y:(R6)+
        MOVE    A,Y:(R6)+
        MOVE    A,Y:(R6)+
        MOVE    A,Y:(R6)+

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
;   I = siii 0000 | 0000 0000 | 0000 0000
;
; Output:
;   FI = 0iii. 0000 | 0000 0000 | 0000 0000  (3SM)
;   IMAG
;
;**************************************************************************

FUNCTF_T    MOVE    #<$20,X0
        MOVE    X:IMAG,A            ;Get |I|
        CMP     X0,A    #<$50,X0    ;Test for |I|<=2
        JLE     <RANGE0_T
        CMP     X0,A    #<$60,X0    ;Test for 3<=|I|<=5
        JLE     <RANGE1_T
        CMP     X0,A                ;Test for |I|=6
        JEQ     <RANGE3_T
        MOVE    #<$70,A             ;|I|=7, set F[I]=7
        JMP     <FILTA_T
RANGE3_T    MOVE    #<$30,A         ;|I|=6, set F[I]=3
        JMP     <FILTA_T
RANGE1_T    MOVE    #<$10,A         ;|I|=3,4,or 5, set F[I]=1
        JMP     <FILTA_T
RANGE0_T    CLR     A               ;|I|=0,1,or 2, set F[I]=0

;**************************************************************************
;       FILTA
;
; Update short term average of F(I)
;
; DMS(k) = (1 - 2**(-5)) * DMS(k-1) + 2**(-5) * F[I(k)]
;
; Inputs:
;   FI = 0iii. 0000 | 0000 0000 | 0000 0000  (3SM)
;   DMS = 0iii. ffff | ffff f000 | 0000 0000  (12SM)
;
; Output:
;   DMSP = 0iii. ffff | ffff f000 | 0000 0000  (12SM)
;
;**************************************************************************

FILTA_T MOVE    Y:DMS_T,Y0          ;Get DMS
        SUB     Y0,A    A,B         ;Find DIF=FI-DMS, save FI
        MOVE    A,X0    Y:(R7)+,Y1  ;Save DIF, get mask K26
        MPY     X0,Y1,A Y:(R7)+,X0  ;Find DIFSX=DIF>>5, get mask K27
        AND     X0,A    Y:DML_T,Y1  ;Truncate DIFSX, get DML
        ADD     Y0,A    Y:RSHFT+7,X1    ;Find DMSP=DIFSX+DMS

;**************************************************************************
;       FILTB
;
; Update long term average of F(I)
;
; DML(k) = (1 - 2**(-7)) * DML(k-1) + 2**(-7) * F[I(k)]
;
; Inputs:
;   FI = 0iii. 0000 | 0000 0000 | 0000 0000  (3SM)
;   DML = 0iii. ffff | ffff fff0 | 0000 0000  (14SM)
;
; Output:
;   DMLP = 0iii. ffff | ffff fff0 | 0000 0000  (14SM)
;
;**************************************************************************

        SUB     Y1,B    A1,Y:DMS_T  ;Find DIF=FI-DML
        MOVE    B1,X0
        MPY     X0,X1,B Y:(R7)+,X0  ;Find DFISX=DIF>>7, get mask K28
        AND     X0,B                ;Truncate DIFSX
        ADD     Y1,B    Y:RSHFT+3,X1    ;Find DMLP=DIFSX+DML

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
;   Y = 0iii i.fff | ffff ff00 | 0000 0000  (13SM)
;   DMSP = 0iii. ffff | ffff f000 | 0000 0000  (12SM)
;   DMLP = 0iii. ffff | ffff fff0 | 0000 0000  (14SM)
;   TDP = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;
; Output:
;   AX = 0i0.0 0000 | 0000 0000 | 0000 0000  (1SM)
;
;**************************************************************************

        SUB     B,A     B1,Y:DML_T  ;Find DIF=DMSP-DMLP, save DML
        ABS     A       B1,Y0       ;Find DIFM=|DIF|
        MPY     X1,Y0,B     #<$18,Y0    ;Find DTHR=DMLP>>3, get '3'
        AND     X0,B    #<$40,X0    ;Truncate DTHR, get '1'
        CMP     B,A     #0,B        ;Compare DIFM & DTHR, set AX=0
        TGE     X0,B                ;If DIFM>=DTHR set AX=1
        MOVE    Y:TDP_T,A           ;Get TDP
        TST     A       X:Y_T,A     ;Check TDP, get Y
        TNE     X0,B                ;If TDP!=0 set AX=1
        CMP     Y0,A    X:AP_T,X1   ;Check for Y<"3", get AP
        TLT     X0,B                ;If Y<"3" set AX=1

;**************************************************************************
;       FILTC
;
; Low pass filter of speed control parameter
;
; AP(k) = (1-2**(-4)) * AP(k-1) + AX
;
; Inputs:
;   AX = 0i0.0 0000 | 0000 0000 | 0000 0000  (1SM)
;   AP = 0ii.f ffff | fff0 0000 | 0000 0000  (10SM)
;
; Outputs:
;   APP = 0ii.f ffff | fff0 0000 | 0000 0000  (10SM)
;
;**************************************************************************

        SUB     X1,B    Y:RSHFT+4,Y0    ;Find DIF=AX-AP
        MOVE    B1,X0
        MPY     X0,Y0,A     Y:(R7)+,X0  ;Find DIFSX=DIF>>4, get K29
        AND     X0,A    Y:TR_T,B    ;Truncate DIFSX, get TR
        ADD     X1,A    #<$20,X0    ;Find APP=DIFSX+AP, get '1'

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
;   APP = 0ii.f ffff | fff0 0000 | 0000 0000  (10SM)
;
; Outputs:
;   APR = 0ii.f ffff | fff0 0000 | 0000 0000  (10SM)
;
;**************************************************************************

        TST     B   X:IMAG,X1       ;Check TR, get IMAG
        TMI     X0,A                ;If TR=1 set APR=1, else APR=APP
        MOVE    A1,X:AP_T           ;Save APR to AP

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
;   I = siii. 0000 | 0000 0000 | 0000 0000  (ADPCM format)
;
; Outputs:
;   WI = siii iiii. | ffff 0000 | 0000 0000  (12TC)
;
;**************************************************************************

        MOVE    Y:RSHFT+20,X0       ;Get shift constant
        MPY     X0,X1,A     #WIBASE,R0  ;Shift IM=IMAG for lookup,
                                    ; load lookup table base
        MOVE    A1,N0               ;Load IM as offset
        MOVE    Y:RSHFT+3,X1        ;Get shift constant
        MOVE    X:Y_T,Y0            ;Get Y
        MPY     Y0,X1,B     X:(R0+N0),A ;Shift Y>>3,
                                    ; get WI from lookup table

;**************************************************************************
;       FILTD
;
; Update of fast quantizer scale factor
;
; YU(k) = (1 - 2**(-5)) * Y(k) + 2**(-5) * W[I(k)]
;
; Inputs:
;   WI =  siii iiii. | ffff 0000 | 0000 0000  (12TC)
;   Y = 0iii i.fff | ffff ff00 | 0000 0000  (13SM)
;
; Outputs:
;   YUT = 0iii i.fff | ffff ff00 | 0000 0000  (13SM)
;
;**************************************************************************

        SUB     B,A                 ;Find DIF=WI-Y
        ASR     A                   ;Find DIFSX=DIF>>5 (actually DIF>>2)
        ASR     A   Y:(R7)+,X0      ;Get mask K30
        AND     X0,A                ;Truncate DIFSX
        ADD     Y0,A    #<$50,X0    ;Find YUT=DIFSX+Y,
                                    ; get upper limit '10'

;**************************************************************************
;       LIMB
;
; Limit quantizer scale factor
;
; 1.06 <= YU(k) <= 10.00
;
; Inputs:
;   YUT = 0iii i.fff | ffff ff00 | 0000 0000  (13SM)
;
; Outputs:
;   YUP = 0iii i.fff | ffff ff00 | 0000 0000  (13SM)
;
;**************************************************************************

        CMP     X0,A    Y:(R7)+,X1  ;Check for YU>10,
                                    ; get lower limit '1.06' (K31)
        TGT     X0,A                ;If YU>10 set YU=10
        CMP     X1,A    Y:YL_T,Y1   ;Check for YU<1.06, get YL
        TLT     X1,A                ;If YU<1.06 set YU=1.06

;**************************************************************************
;       FILTE
;
; Update of slow quantizer scale factor
;
; YL(k) = (1 - 2**(-6)) * YL(k-1) + 2**(-6) * YU(k)
;
; Inputs:
;   YUP = 0iii i.fff | ffff ff00 | 0000 0000  (13SM)
;   YL = 0iii i.fff | ffff ffff | ffff 0000  (19SM)
;
; Outputs:
;   YLP = 0iii i.fff | ffff ffff | ffff 0000  (19SM)
;
;**************************************************************************

        TFR     Y1,B    A1,Y:YU_T   ;Move YL, save YUP
        NEG     B   Y:(R7)+,Y0      ;Find -YL, save YL, get mask K32
        AND     Y0,B                ;Truncate -YL (-YL>>6)
        ADD     B,A     Y:RSHFT+6,Y0    ;Find DIF=YUP+(-YL>>6)
        MOVE    A1,X1
        MPY     Y0,X1,A             ;Find DIFSX>>6
        ADD     Y1,A    R2,X:DATAPTR_T  ;Find YLP=DIFSX+YL,
                                    ; save transmit data pointer
        MOVE    A1,Y:YL_T           ;Save YL

;**************************************************************************
;
;   Decoder
;
;**************************************************************************

DECODE  MOVE    #PP_R,R1            ;Set partial product ptr to WB1
        MOVE    X:DATAPTR_R,R2      ;Set data pointer to DQ1EXP
        MOVE    #COEF_R,R6          ;Set coef pointer to B1
        MOVE    #CONST1,R7          ;Set pointer to misc constants

;**************************************************************************
;       FMULT
;
; Multiply predictor coefficients with corresponding
;   quantized difference signal or reconstructed signal
;
;   Data (DQn or SRn) is stored in 11FL format (separate),
;   & coefficient (Bn or An) is stored in 16TC format.
;
; Computes  [An(k-1) * SR(k-n)] or [Bn(k-1) * DQ(k-n)]
;
; Flow Description:
;   1. Convert 16TC An to 13SM AnMAG
;   2. Convert 13SM AnMAG to 10FL (AnEXP and AnMANT)
;   3. Add SRnEXP to AnEXP to get WAnEXP (5-bits)
;   4. Multiply SRnMANT with AnMANT, add '48', and truncate
;       to 8-bits to get WAnMANT
;   5. Convert 13FL (WAnEXP & WAnMANT) to 15SM WAnMAG
;   6. XOR AnS with SRnS to find WAnS
;   7. Convert 16SM (WAnMAG & WAnS) to 16TC WAn
;
; Input:
;   SRn = (11FL)
;    SRnEXP = X:(R2) = 0000 0000 | 0000 0000 | 0000 eeee
;    SRnMANT = X:(R2+1) = 01mm mmm0 | 0000 0000 | 0000 0000
;    SRnS = X:(R2+2) = sXXX XXXX | XXXX XXXX | 0000 0000
;       (DQ in same format as SR)
;
;   An = Y:(R6) = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;       (Bn in same format as An)
;
; Output:
;   WAn = X:(R1) = siii iiii | iiii iii.f | 0000 0000  (16TC)
;       (WBn in same format as WAn)
;
;**************************************************************************

        MOVE    #CONST,R0           ;Set pointer to FMULT constants
        MOVE    #0,Y1
        DO      #8,ACCUM_R          ;Execute mult 8 times

; 1. Convert 16TC An to 13SM AnMAG
        MOVE    X:(R0)+,X1  Y:(R6),A    ;Get An and mask KF1
        AND     X1,A    X:(R0)+,X1  ;Truncate An to 13 bits (An>>2),
                                    ; get mask KF2
        ABS     A       #$000D,R4   ;Find AnMAG, load
                                    ; exponent bias (13) into R4
        AND     X1,A    #<$7E,X1    ;Truncate any ovrflw, get mask
;   A1 = 0i.ff ffff | ffff ff00 | 0000 0000 (A2=A0=0)

; 2. Convert 13SM AnMAG to 10FL (AnEXP and AnMANT)
        JNE     <NORMAN_R           ;Test AnMAG
        MOVE    #<$40,A             ;If AnMAG=0, set AnMANT=1<<5,
        MOVE    #0,R4               ; and AnEXP=0
        JMP     <CONTIN_R
NORMAN_R    NORM    R4,A            ;If AnMAG!=0 do NORM iteration
        NORM    R4,A                ; 12 times to find MSB
        NORM    R4,A
        NORM    R4,A
        NORM    R4,A
        NORM    R4,A
        NORM    R4,A
        NORM    R4,A
        NORM    R4,A
        NORM    R4,A
        NORM    R4,A
        NORM    R4,A
;   A1 = 01?? ???? | ???? ??00 | 0000 0000 = AnMANT
;   R4 = 0000 0000 | 0000 eeee = AnEXP
CONTIN_R    AND     X1,A    R4,B    ;Truncate AnMANT to 6 bits,
                                    ; move AnEXP to B
;   A1 = 01mm mmm0 | 0000 0000 | 0000 0000 (A2=A0=0)
;   B1 = 0000 0000 | 0000 0000 | 0000 eeee (B2=B0=0)

; 3. Add SRnEXP to AnEXP to get WAnEXP (5-bits)
        MOVE    X:(R2)+,X1  A,Y0    ;Get SRnEXP
        ADD     X1,B    X:(R2)+,X1  ;Find WAnEXP=SRnEXP+AnEXP,
                                    ; get SRnMANT 
;   B1 = 0000 0000 | 0000 0000 | 000e eeee (B2=B0=0)

; 4. Multiply SRnMANT with AnMANT, add '48', and truncate
;       to 8-bits to get WAnMANT
;   Y0 = 01mm mmm0 | 0000 0000 | 0000 0000
;   X1 = 01mm mmm0 | 0000 0000 | 0000 0000
        MPY     Y0,X1,A     X:(R0)+,X0  ;Find WAnMANT, get '48' (KF3)
;   A1 = 0mmm mmmm | mmmm m000 | 0000 0000 (A2=A0=0)
;   X0 = 0000 0001 | 1000 0000 | 0000 0000 = '48'
        ADD     X0,A        X:(R0)+,X0  ;Add '48' to WAnMANT, get mask KF4
        AND     X0,A        X:(R0)+,X0  ;Truncate WAnMANT to 8 bits,
                                        ; get '26' (KF5)
;   A1 = 0mmm mmmm | m000 0000 | 0000 0000 (A2=A0=0)

; 5. Convert 13FL (WAnEXP & WAnMANT) to 15SM WAnMAG
;   X0 = 0000 0000 | 0000 0000 | 0001 1010 = '26'
;   B1 = 0000 0000 | 0000 0000 | 000e eeee (B2=B0=0) 
        SUB     X0,B    X:(R0)+,X0  ;Find shift offset (WAnEXP-26),
                                    ; get mask KF6
        JEQ     <TRUNC_R            ;If offset=26 no shift
        JMI     <RIGHT_R            ;If offset<26 do right shift
                                    ;Else offset>26, do left shift
        REP     B1                  ;Offset>26, shift WAnMANT
        LSL     A                   ; left up to 4 times
        JMP     <TRUNC_R
RIGHT_R ABS     B       #>$0F,Y0    ;Find |offset|, get '15'
        CMP     Y0,B    B1,N5       ;Compare |offset| to '15',
                                    ; load offset for shift
        TGE     Y1,A                ;If |offset|>=15 WAnMAG=0
        MOVE    A1,X1               ;Move WAnMANT for shift
        MOVE    Y:(R5+N5),Y0        ;Lookup shift constant
        MPY     Y0,X1,A             ;Shift WAnMANT right up to 14 times
;   A1 = ?mmm mmmm | mmmm mmmm | ???? ???? (A2=A0=0)
TRUNC_R AND     X0,A    X:(R2)+,X1  Y:(R6)+,B   ;Truncate WAnMAG to 15 bits,
                                    ; get SRnS & AnS
;   A1 = 0iii iiii | iiii iii.f | 0000 0000 (A2=A0=0)
        NEG     A   A1,X0           ;Find -WAnMAG, save WAnMAG

; 6. XOR AnS with SRnS to find WAnS
;   B1 = sXXX XXXX | XXXX XXXX | 0000 0000 (B2=sign ext, B0=0)
;   X1 = sXXX XXXX | XXXX XXXX | 0000 0000
        EOR     X1,B    #CONST,R0   ;Find WAnS (in MSB of B),
                                    ; update pointer to constants

; 7. Convert 16SM (WAnMAG & WAnS) to 16TC WAn
        TPL     X0,A                ;If WAnS=0 use WAnMAG, else use -WAnMAG
;   A1 = siii iiii | iiii iii.f | 0000 0000  (A2=sign ext, A0=0)
        MOVE    A1,X:(R1)+          ;Save WAn

;**************************************************************************
;       ACCUM
;
; Add predictor outputs to form the partial signal estimate
;   and the signal estimate
;
; SEZ(k) = [B1(k-1) * DQ(k-1)] + ... + [B6(k-1) * DQ(k-6)]
;        = WB1 + WB2 + ... + WB6
;
; SE(k) = SEZ(k) + [A1(k-1) * SR(k-1)] + [A2(k-1) * SR(k-2)]
;       = SEZ + WA1 + WA2
;
; Inputs:
;   WBn & WAn = X:(R1) = siii iiii | iiii iii.f | 0000 0000  (16TC)
;
; Outputs:
;   SEZ = siii iiii | iiii iii.0 | 0000 0000  (15TC)
;   SE = siii iiii | iiii iii.0 | 0000 0000  (15TC)
;
;**************************************************************************

ACCUM_R MOVE    X:(R1)+,A           ;Get WB1
        MOVE    X:(R1)+,X0          ;Get WB2
        ADD     X0,A    X:(R1)+,X0  ;Accumulate WB1&WB2, get WB3
        ADD     X0,A    X:(R1)+,X0  ;Accumulate WB3, get WB4
        ADD     X0,A    X:(R1)+,X0  ;Accumulate WB4, get WB5
        ADD     X0,A    X:(R1)+,X0  ;Accumulate WB5, get WB6
        ADD     X0,A    X:(R1)+,X0  ;Accumulate WB6 to get SEZI, get WA1
        TFR     A,B     Y:(R7)+,X1  ;Copy SEZI, get mask K1
        AND     X1,B    X:AP_R,Y0   ;Truncate SEZI, get AP
        ADD     X0,A    X:(R1)+,X0  ;Accumulate WA1, get WA2
        ADD     X0,A    B1,Y:SEZ_R  ;Accumulate WA2 to get SEI, save SEZ
        AND     X1,A    #<$20,X0    ;Truncate SEI, get '1'
        TFR     Y0,A    A1,Y:SE_R   ;Move AP, save SE

;**************************************************************************
;       LIMA
;
; Limit speed control parameter
;
; AL(k) = 1        if AP(k-1) > 1
;       = AP(k-1)  if AP(k-1) <= 1
;
; Inputs:
;   AP = 0ii.f ffff | fff0 0000 | 0000 0000  (10SM)
;
; Outputs:
;   AL = 0i.ff ffff | 0000 0000 | 0000 0000  (7SM)
;
;**************************************************************************

        CMP     X0,A    Y:YL_R,B    ;Test AP, get YL
        TGT     X0,A                ;If AP>'1' set AL='1'
        LSL     A       #<$7F,X0    ;Shift to align radix pt., get mask
        AND     X0,A    Y:(R7)+,X0  ;Truncate AL (AP>>2), get mask K2

;**************************************************************************
;       MIX
;
; Form linear combination of fast and slow quantizer
;   scale factors
;
; Y(k) = AL(k) * YU(k-1) + [1 - AL(k)] * YL(k-1)
;
; Inputs:
;   YL = 0iii i.fff | ffff ffff | ffff 0000  (19SM)
;   AL = 0i.ff ffff | 0000 0000 | 0000 0000  (7SM)
;   YU = 0iii i.fff | ffff ff00 | 0000 0000  (13SM)
;
; Outputs:
;   Y = 0iii i.fff | ffff ff00 | 0000 0000  (13SM)
;
;**************************************************************************

        AND     X0,B    A,X0    Y:YU_R,A    ;Truncate YL (YL>>6), get YU
        SUB     B,A     B,Y1    X0,X:AL_R   ;Find DIF=YU-YL, save YL, get AL
        ABS     A       A,B         ;Find DIFM=|DIF|, save DIFS
        MOVE    A1,Y0
        MPY     X0,Y0,A     Y:(R7)+,X0  ;Find DIFM*AL, get mask K3
        AND     X0,A                ;Truncate to find PRODM=(DIFM*AL)>>6
        NEG     A   A1,X0           ;Find -PRODM, save PRODM
        TST     B                   ;Check DIFS
        TPL     X0,A                ;If DIFS=0 PROD=PRODM,
                                    ; else PROD=-PRODM
        ASL     A   Y1,B            ;Line up radix point
        ADD     Y1,A                ;Find Y=PROD+(YL>>6)
        MOVE    A,X:Y_R             ;Save Y

;**************************************************************************
;
; Input ADPCM data (I) here. For simulation purposes the Input 
; Word from File subroutine on the 56001 ADS board is used.
;
;**************************************************************************

        MOVE    #2,X0               ;Input ADPCM word (I)
        JSR     $E002

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
;
;**************************************************************************

        MOVE    #<$F0,X1
        MOVE    A,Y1    A,X:I_R     ;Save DQS (sign of I) to Y1
        EOR     X1,A    Y:RSHFT+20,Y0   ;Invert bits of I
        TMI     Y1,A                ;If ^IS=1, use I, else use ^I
;   A1 = 0iii 0000 | 0000 0000 | 0000 0000 (A2=?, A0=0)
        MOVE    A1,X0
        MOVE    A1,X:IMAG           ;Save |I|
        MPY     X0,Y0,A     #IQUANTAB,R4    ;Shift IMAG>>20
;   A1 = 0000 0000 | 0000 0000 | 0000 0iii (A2=A0=0)
        MOVE    A1,N4               ;Load IMAG as offset
        MOVE    X:Y_R,B             ; into IQUAN table, get Y
        MOVE    #CONST8,R7          ;Adjust constant pointer
        MOVE    X:(R4+N4),A         ;Lookup DQLN

;**************************************************************************
;       ADDA
;
; Add scale factor to log version of quantized difference
;   signal
;
; DQL = DQLN + Y
;
; Inputs:
;   Y = 0iii i.fff | ffff ff00 | 0000 0000  (13SM)
;   DQLN = siii i.fff | ffff 0000 | 0000 0000  (12TC)
;
; Output:
;   DQL = siii i.fff | ffff 0000 | 0000 0000  (12TC)
;
;**************************************************************************

        MOVE    Y:(R7)+,Y0          ;Get mask K8 for ADDA
        AND     Y0,B    Y:(R7)+,X0  ;Truncate Y to 11 bits (Y<<2),
                                    ; get mask K9
        ADD     B,A     #<$08,X1    ;Find DQL=DQLN+(Y<<2), get '1'
   
;**************************************************************************
;       ANTILOG
;
; Convert quantized difference signal from log to linear
;   domain
;
; Input:
;   DQL = siii i.fff | ffff 0000 | 0000 0000  (12TC)
;   DQS = sXXX 0000 | 0000 0000 | 0000 0000  (1TC)
;
; Outputs:
;   DQ = siii iiii | iiii iii.0 | 0000 0000  (15SM)
;
;**************************************************************************

        JPL     <CONVLOG_R          ;If DQL>=0 (DS=0) convert DQL,
                                    ; else DQL<0 (DS=1), set |DQ|=0
        TFR     Y1,A    #<$80,X0    ;Get DQS (MSB of I), get mask
        AND     X0,A    #0,B        ;Mask off DQS, set |DQ|=0
;   A1 = s000 0000 | 0000 0000 | 0000 0000  (A2=sign ext, A0=0)
        MOVE    B1,Y:DQMAG          ;Save DQMAG=|DQ|
        MOVE    (R7)+               ;Adjust constant pointer
        MOVE    (R7)+
        JMP     <SAVEDQ_R

CONVLOG_R   AND     X0,A    A,B     ;Find fractional part (DMN),
                                    ; save DS
;   A1 = 0000 0.fff | ffff 0000 | 0000 0000  (A2=A0=0)
        OR      X1,A    #<$78,X0    ;Add implied '1' to DMN to
                                    ; find DQT, get integer mask
;   A1 = 0000 1.fff | ffff 0000 | 0000 0000  (A2=A0=0)
        AND     X0,B    Y:RSHFT+19,Y0   ;Find integer part (DEX),
                                    ; get shift constant
;   B1 = 0iii i.000 | 0000 0000 | 0000 0000  (B2=B0=0)
        MOVE    B1,X0
        MPY     X0,Y0,B     Y:(R7)+,X0  ;Shift DEX>>19, get '10' (K10)
;   A1 = 0000 1.fff | ffff 0000 | 0000 0000  (A2=A0=0)
;   B1 = 0000 0000 | 0000 0000 | 0000 iiii.  (B2=B0=0)
        SUB     X0,B    Y:(R7)+,X0  ;Find DQT shift=DEX-'10',
                                    ; get mask K11
        JEQ     <TRUNCDQM_R         ;If DEX=10, no shift
        JLT     <SHFRDQ_R           ;If DEX<10, shift right
        REP     B1                  ;Else shift DQT left
        LSL     A                   ; up to 4 times
        JMP     <TRUNCDQM_R

SHFRDQ_R    NEG     B               ;Find 10-DEX
        MOVE    B1,N5               ;Use 10-DEX for shift lookup
        MOVE    A1,Y0
        MOVE    Y:(R5+N5),X1        ;Lookup shift constant
        MPY     X1,Y0,A             ;Shift DQT right up to 9 times
TRUNCDQM_R  AND     X0,A    #<$80,B ;Truncate to find DQMAG=|DQ|,
                                    ; get sign mask
;   A1 = 0iii iiii | iiii iii.0 | 0000 0000  (A2=A0=0)
        AND     Y1,B    A1,Y:DQMAG  ;Mask off DQS, save DQMAG           
;   B1 = s000 0000 | 0000 0000 | 0000 0000  (B2=?, B0=0)
        MOVE    B1,X0
        OR      X0,A                ;Add DQS to DQMAG to get DQ
;   A1 = siii iiii | iiii iii.0 | 0000 0000  (A2=?, A0=0)
SAVEDQ_R    MOVE    A1,X:DQ_R       ;Save DQ

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
;   YL = 0iii i.fff | ffff ffff | ffff 0000  (19SM)
;   DQ = siii iiii | iiii iii.0 | 0000 0000  (15SM)
;
; Output:
;   TR = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;
;**************************************************************************

        MOVE    Y:TD_R,A            ;Get TD
        TST     A   #0,A            ;Check TD, set TR=0
        JEQ     <SAVETR_R           ;If TD=0 save TR=0
                                    ; else test DQ and YL
        MOVE    Y:YL_R,A            ;Get YL
        TFR     A,B     Y:(R7)+,X0  ;Save YL, get mask K12
        AND     X0,A    #<$08,X0    ;Find YLFRAC (YL>>10), get '1'
        OR      X0,A    B,X1    Y:(R7)+,Y1  ;Add implied '1' to YLFRAC,
                                    ; get mask K13
        MPY     Y1,X1,B     Y:(R7)+,X0  ;Find YLINT=YL>>15, get '8' (K14)
        MOVE    B1,B                ;Adjust sign extension
        CMP     X0,B    Y:(R7)+,X0  ;Compare YLINT to '8', get '5' (K15)
        JGT     <MAXTHR_R           ;If YLINT>8 set maximum THR2
        SUB     X0,B                ;Find YLINT-5
        JEQ     <SETDQTHR_R         ;If YLINT=5 don't shift
        JLT     <RSHFT_R            ;If YLINT<5 shift right

        REP     B1                  ;Else shift YLFRAC left
        LSL     A                   ; up to 3 times to get THR1
        JMP     <SETDQTHR_R

MAXTHR_R    MOVE    #<$7C,A         ;Set maximum THR2 (31<<9)
        JMP     <SETDQTHR_R

RSHFT_R NEG     B                   ;Find 5-YLINT
        MOVE    B1,N5               ;Use 5-YLINT for shift lookup
        MOVE    A1,X0
        MOVE    Y:(R5+N5),X1        ;Lookup shift constant
        MPY     X0,X1,A             ;Shift YLFRAC right up to ? times
                                    ; to get THR1
SETDQTHR_R  TFR     A,B     Y:(R7)+,X0  ;Get mask K16
        LSR     B                   ;Find THR2>>1
        AND     X0,B                ;Truncate THR2>>1
        ADD     B,A     #0,X1       ;Find THR2+(THR2>>1)
        LSR     A                   ;Find (THR2+(THR2>>1)>>1
        AND     X0,A    Y:DQMAG,X0  ;Truncate to find DQTHR, get DQMAG
        CMP     X0,A    #<$80,A     ;Compare DQMAG to DQTHR, set TR=1
        TGT     X1,A                ;If DQMAG>DQTHR leave TR=1,
                                    ; else DQMAG<=DQTHR, set TR=0
SAVETR_R    MOVE    A1,Y:TR_R       ;Save TR

;**************************************************************************
;       ADDB
;
; Add quantized difference signal and signal estimate
;   to form reconstructed signal
;
; SR(k-n) = SE(k-n) + DQ(k-n)
;
; Inputs:
;   DQ = siii iiii | iiii iii.0 | 0000 0000  (15SM)
;   SE = siii iiii | iiii iii.0 | 0000 0000  (15TC)
;
; Output:
;   SR = siii iiii | iiii iiii. | 0000 0000  (16TC)
;
;**************************************************************************

        MOVE    Y:SE_R,B            ;Get SE
        ASR     B   X:DQ_R,A        ;Sign extend SE to get SEI, get DQS
        TST     A       Y:DQMAG,A   ;Check DQS, get DQMAG
        JPL     <SHFTDQ_R           ;If DQS=0 continue
        NEG     A                   ;Convert DQ to 2's comp
SHFTDQ_R    ASR     A               ;Sign extend DQ to get DQI
        ADD     A,B     #CONST17,R7 ;Find SR=DQ+SE, update const pointer

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
;   SEZ = siii iiii | iiii iii.0 | 0000 0000 (15TC)
;
; Output:
;   PK0 = sXXX XXXX | XXXX XXXX | 0000 0000  (1TC)
;   SIGPK = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;
;**************************************************************************

        MOVE    B1,Y:SR_R           ;Save SR
        MOVE    Y:SEZ_R,B           ;Get SEZ
        ASR     B                   ;Sign extend SEZ to SEZI
        ADD     B,A     #0,B        ;Find DQSEZ=DQ+SEZ,
                                    ; set SIGPK=0
        TST     A   #<$80,X0        ;Check DQSEZ, get '1'
        TEQ     X0,B                ;If DQSEZ=0, SIGPK=1,
                                    ; else SIGPK=0

        MOVE    Y:PK1_R,X0
        MOVE    X0,Y:PK2_R          ;Delay previous PK1
        MOVE    Y:PK0_R,X0
        MOVE    X0,Y:PK1_R          ;Delay previous PK0
        MOVE    A1,Y:PK0_R          ;Save new PK0
        MOVE    B1,Y:SIGPK_R        ;Save SIGPK
        EOR     X0,A    Y:PK2_R,X0  ;Find PKS1=PK0**PK1
                                    ; for UPA1 & UPA2
        MOVE    A1,X:PKS1           ;Save PKS1
        MOVE    Y:PK0_R,A
        EOR     X0,A    #3,N2       ;Find PKS2=PK0**PK2 for UPA2
        MOVE    A1,X:PKS2           ;Save PKS2
        MOVE    (R2)+               ;Adjust data buffer pointer so
        MOVE    (R2)+               ; that R2 points to DQ1S

;**************************************************************************
;       XOR
;
; Find one bit "exclusive or" of the sign of difference
;   signal and the sign of delayed difference signal.
;
; Un = sgn[DQ(k)] XOR sgn[DQ(k-n)]
;
; Inputs:
;   DQ = siii iiii | iiii iii.0 | 0000 0000 (15SM)
;   DQnS = X:(R2+n) sXXX XXXX | XXXX XXXX | 0000 0000
;
; Outputs:
;   Un = sXXX XXXX | XXXX XXXX | 0000 0000 (1TC)
;
;**************************************************************************
;**************************************************************************
;       UPB
;
; Update the coefficients of the sixth order predictor
;
; Bn(k) = [1-(2**-8)] * Bn(k-1)
;           + (2**-7) * sgn[DQ(k)] * sgn[DQ(k-n)]
;
; Inputs:
;   Bn = Y:(R6+n) = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;   DQ = siii iiii | iiii iii.0 | 0000 0000 (15SM)
;   Un = sXXX XXXX | XXXX XXXX | 0000 0000 (1TC)
;
; Outputs:
;   BnP = Y:(R6+n) = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;
;**************************************************************************

        MOVE    Y:DQMAG,A           ;Get DQMAG
        TST     A   X:DQ_R,Y0       ;Check DQMAG, get DQS
        JNE     <XORUPB_R           ;If DQMAG!=0 use section with XOR,
                                    ; else use section with no XOR
                                    ; (because UGBn=0 if DQMAG=0)

; UPB without XOR
        MOVE    Y:RSHFT+8,X1        ;Get shift constant
        MOVE    (R7)+               ;Adjust constant pointer
        MOVE    (R7)+
        MOVE    Y:(R7)+,X0          ;Get mask K19
        DO      #6,ENDLOOP_R        ;Do UPB for B1-B6
        MOVE    X:(R2)+N2,A     Y:(R6),Y1   ;Get Bn (& DQnS but don't use)
        MPY     X1,Y1,A             ;Find Bn>>8
        AND     X0,A                ;Truncate (Bn>>8)
        NEG     A                   ;Find UBn=ULBn=-(Bn>>8)
        ADD     Y1,A                ;Find BnP=Bn+UBn
        MOVE    A1,Y:(R6)+          ;Store BnP to Bn
ENDLOOP_R   JMP     <UPA2_R

; UPB with XOR
XORUPB_R    MOVE    Y:(R7)+,X0      ;Get +gain (K17)
        DO      #6,UPTR_R           ;Do UPB and XOR for B1-B6
        MOVE    X:(R2)+N2,A     Y:(R6),Y1   ;Get Bn & DQnS
        EOR     Y0,A    Y:(R7)+,X1  ;Find Un=DQS**DQnS (XOR),
                                    ; get -gain (K18)
        TPL     X0,A                ;If Un=0 set UGBn=+gain
        TMI     X1,A                ;If Un=1 set UGBn=-gain
        MOVE    Y:RSHFT+8,X1        ;Get shift constant
        MPY     X1,Y1,B     Y:(R7)-,X1  ;Shift Bn>>8, get mask K19
        AND     X1,B                ;Truncate (Bn>>8)
        NEG     B                   ;Find ULBn=-(Bn>>8)
        ADD     B,A                 ;Find UBn=UGBn+ULBn
        ADD     Y1,A                ;Find BnP=Bn+UBn
        MOVE    A1,Y:(R6)+          ;Store BnP to Bn
UPTR_R  MOVE    (R7)+               ;Adjust constant pointer
        MOVE    (R7)+

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
;   A1 = Y:(R6) = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;   A2 = Y:(R6+1) = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;   SIGPK = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;   PK0 = sXXX XXXX | XXXX XXXX | 0000 0000  (1TC)
;   PK1 = sXXX XXXX | XXXX XXXX | 0000 0000  (1TC)
;   PK2 = sXXX XXXX | XXXX XXXX | 0000 0000  (1TC)
;     (Note: PKS1 & PKS2 have been previously calculated)
;
; Outputs:
;   A2T = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;
;**************************************************************************

UPA2_R  MOVE    X:PKS2,A            ;Get PKS2=PK0**PK2
        TST     A   #<$10,Y0        ;Check PKS2, get '+1'
        MOVE    #<$F0,Y1            ;Get '-1'
        TPL     Y0,A                ;If PKS2=0, set UGA2A='+1'
        TMI     Y1,A                ;If PKS2=1, set UGA2A='-1'
        MOVE    A,X1    Y:(R6)+,A   ;Save UGA2A, get A1
        MOVE    Y:(R7)+,Y0          ;Get '+1.99' (K20)
        CMP     Y0,A    Y:(R7)+,Y1  ;Check A1, get '-1.99' (K21)
        TGT     Y0,A                ;If A1>=1/2, set FA1='1.99'
        CMP     Y1,A    X:PKS1,B    ;Check A1 again, get PKS1=PK0**PK1
        TLT     Y1,A                ;If A1<=-1/2, set FA1='-1.99'
        TST     B       #0,X0       ;Check PKS1
        JMI     <FINDSUM_R          ;If PKS1=1, FA=FA1
        NEG     A                   ; else PKS1=0, set FA=-FA1
FINDSUM_R   ADD     X1,A    Y:RSHFT+5,Y1    ;Find UGA2B=UGA2A+FA,
                                    ; get shift constant
        MOVE    A,X1
        MPY     X1,Y1,A     Y:(R7)+,X1  ;Find UGA2B>>7, get mask K22
        AND     X1,A    Y:SIGPK_R,B ;Truncate UGA2, get SIGPK
        TST     B   Y:(R6),Y0       ;Check SIGPK, get A2
        TMI     X0,A                ;If SIGPK=1, set UGA2=0
        MOVE    Y:RSHFT+7,X0        ;Get shift constant
        MPY     Y0,X0,B             ;Find A2>>7
        AND     X1,B                ;Truncate to find A2>>7
        NEG     B       #<$D0,X0    ;Find ULA2=-(A2>>7), get A2LL
        ADD     B,A     #<$30,X1    ;Find UA2=UGA2+ULA2, get A2UL
        ADD     Y0,A    Y:(R7)+,Y1  ;Find A2T=A2+UA2, get -gain (K23)

;**************************************************************************
;       LIMC
;
; Limit the A2 coefficient of the second order predictor.
;
;   |A2(k)| <= '0.75' 
;
; Inputs:
;   A2T = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;
; Outputs:
;   A2P = Y:(R6) = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;
;**************************************************************************

        CMP     X0,A    Y:(R7)+,Y0  ;Check A2P, get +gain (K24)
        TLT     X0,A                ;If A2P<-0.75, set A2P=-0.75
        CMP     X1,A    X:PKS1,B    ;Check A2P again, get PKS1=PK0**PK1
        TGT     X1,A                ;If A2P>0.75, set A2P=0.75
        MOVE    A,Y:A2P_R           ;Save A2P
        MOVE    A,Y:(R6)-           ;Save A2P to A2

;**************************************************************************
;       UPA1
;
; Update the A1 coefficient of the second order predictor.
;
; A1(k) = [1-(2**-8)] * A1(k-1)
;           + 3 * (2**-8) * sgn[P(k)] * sgn[P(k-1)]
;
; Inputs:
;   A1 = Y:(R6) = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;   SIGPK = Y:(R0) = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;   PK0 = sXXX XXXX | XXXX XXXX | 0000 0000  (1TC)
;   PK1 = sXXX XXXX | XXXX XXXX | 0000 0000  (1TC)
;     (Note: PKS1 has been previously calculated)
;
; Outputs:
;   A1T = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;
;**************************************************************************

        TST     B       Y:SIGPK_R,B ;Check PKS1, get SIGPK
        TPL     Y0,A                ;If PKS=0, set UGA1=+gain
        TMI     Y1,A                ;If PKS=1, set UGA1=-gain
        TST     B       #0,X0       ;Check SIGPK
        TMI     X0,A                ;If SIGPK=1, set UGA1=0
        MOVE    Y:(R6),X1           ;Get A1
        MOVE    Y:RSHFT+8,Y0        ;Get shift constant
        MPY     Y0,X1,B     Y:(R7)+,X0  ;Find A1>>8, get mask K25
        AND     X0,B                ;Truncate (A1>>8)
        NEG     B                   ;Find ULA1=-(A1>>8)
        ADD     B,A     #<$3C,B     ;Find UA1=UGA1+ULA1,
                                    ; get OME='1-(2**-4)'
        ADD     X1,A    Y:A2P_R,X0  ;Find A1T=A1+UA1, get A2P

;**************************************************************************
;       LIMD
;
; Limit the A1 coefficient of the second order predictor.
;
;   |A1(k)| <= [1-(2**-4)] - A2(k)
;
; Inputs:
;   A1T = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;   A2P = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;
; Outputs:
;   A1P = Y:(R6) = si.ff ffff | ffff ffff | 0000 0000 (16TC)
;
;**************************************************************************

        SUB     X0,B                ;Find A1UL=OME-A2P
        CMP     B,A     B,X0        ;Check A1T
        TGT     X0,A                ;If A1T>A1UL, set A1P=A1UL
        NEG     B       (R2)+       ;Find A1LL=-A1UL=A2P-OME
        CMP     B,A     B,X0        ;Check A1T again
        TLT     X0,A                ;If A1T<A1LL, set A1P=A1LL
        MOVE    A1,Y:(R6)+          ;Store A1P to A1
        MOVE    (R6)+               ;Adjust coef pointer

;**************************************************************************
;       FLOATA
;
; Converts the quantized difference signal from 15-bit
;   signed magnitude to floating pt. format (11FL - sign,
;   exp, and mant stored separately)
;
; Inputs:
;   DQ = siii iiii | iiii iii.0 | 0000 0000 (15SM)
;
; Outputs:
;   DQ0 = (11FL)
;    DQ0EXP = X:(R2) = 0000 0000 | 0000 0000 | 0000 eeee
;    DQ0MANT = X:(R2+1) = 01mm mmm0 | 0000 0000 | 0000 0000
;    DQ0S = X:(R2+2) = sXXX XXXX | XXXX XXXX | 0000 0000
;
;**************************************************************************

        MOVE    X:DQ_R,Y0           ;Get DQS
        MOVE    Y:DQMAG,A           ;Get MAG=DQMAG
        TST     A   #$000E,R0       ;Check MAG, get exponent bias (14)
        JNE     <NORMDQ_R           ;Test MAG
        MOVE    #<$40,A             ;If MAG=0 set MANT=100000,
        MOVE    #0,R0               ; and EXP=0
        JMP     <TRUNCDQ_R
NORMDQ_R    NORM    R0,A            ;If MAG!=0 do NORM iteration 13
        NORM    R0,A                ; times to find MSB of MAG
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
;   A1 = 01?? ???? | ???? ???0 | 0000 0000 = normalized MAG (A2=A0=0)
;   R0 = 0000 0000 | 0000 eeee = exponent of normalized MAG

TRUNCDQ_R   MOVE    #<$7E,X0        ;Get mask
        AND     X0,A    R0,X:(R2)+  ;Truncate MANT to 6 bits,
                                    ; save EXP to DQ1EXP
;   A1 = 01mm mmm0 | 0000 0000 | 0000 0000  (A2=A0=0)
        MOVE    A1,X:(R2)+          ;Save MANT to DQ1MANT
        MOVE    Y0,X:(R2)+          ;Save DQ to DQ1S

;**************************************************************************
;       FLOATB
;
; Converts the reconstructed signal from 16-bit two's 
;   complement to floating pt. format (11FL - sign,
;   exp, and mant stored separately)
;
; Inputs:
;   SR = siii iiii | iiii iiii. | 0000 0000  (16TC)
;
; Outputs:
;   SR0 = (11FL)
;    SR0EXP = X:(R2) = 0000 0000 | 0000 0000 | 0000 eeee
;    SR0MANT = X:(R2+1) = 01mm mmm0 | 0000 0000 | 0000 0000
;    SR0S = X:(R2+2) = sXXX XXXX | XXXX XXXX | 0000 0000
;
;**************************************************************************

        MOVE    #15,N2
        MOVE    Y:SR_R,B            ;Get SR
        MOVE    (R2)+N2             ;Adjust data pointer
        ABS     B       B,Y0        ;Find MAG=|SR|, save SRS
        TST     B   #$000F,R0       ;Load exponent bias
        JNE     <NORMSR_R           ;Test MAG
        MOVE    #<$40,B             ;If MAG=0 set MANT=100000,
        MOVE    #0,R0               ; and EXP=0
        JMP     <TRUNCSR_R
NORMSR_R    NORM    R0,B            ;If MAG!=0 do NORM iteration 14
        NORM    R0,B                ; times to find MSB of MAG
        NORM    R0,B
        NORM    R0,B
        NORM    R0,B
        NORM    R0,B
        NORM    R0,B
        NORM    R0,B
        NORM    R0,B
        NORM    R0,B
        NORM    R0,B
        NORM    R0,B
        NORM    R0,B
        NORM    R0,B
;   A1 = 01?? ???? | ???? ???0 | 0000 0000 = normalized MAG (A2=A0=0)
;   R0 = 0000 0000 | 0000 eeee = exponent of normalized MAG

TRUNCSR_R   AND     X0,B    R0,X:(R2)+  ;Truncate MANT to 6 bits,
                                    ; save EXP to SR1EXP
;   A1 = 01mm mmm0 | 0000 0000 | 0000 0000  (A2=A0=0)
        MOVE    B1,X:(R2)+          ;Save MANT to SR1MANT
        MOVE    Y0,X:(R2)+          ;Save SR to SR1S
        MOVE    #3,N2
        MOVE    Y:A2P_R,B           ;Get A2P
        MOVE    (R2)+N2             ;Adjust data pointer

;**************************************************************************
;       TONE
;
; Partial band signal detection
;
; TD(k) = 1 if A2(k) < -0.71875
;         0 otherwise
;
; Inputs:
;   A2P = si.ff ffff | ffff ffff | 0000 0000  (16TC)
;
; Output:
;   TDP = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;
;**************************************************************************

        CLR     A   #<$D2,X0        ;Get '-.71875', set TDP=0
        CMP     X0,B    #<$80,X1    ;Check A2P, get '1'
        TLT     X1,A                ;If A2P<-.71875 set TDP=1, else TDP=0
        MOVE    A1,Y:TDP_R          ;Save TDP
        MOVE    A1,Y:TD_R           ;Save TDP to TD

;**************************************************************************
;       TRIGB
;
; Predictor trigger block
;
; If TR(k) = 1, An(k)=Bn(k)=TD(k)=0
;
; Inputs:
;   TR = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;   BnP = si.ff ffff | ffff ffff | 0000 0000  (16TC)
;   AnP = si.ff ffff | ffff ffff | 0000 0000  (16TC)
;   TDP = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;
; Output:
;   BnR = si.ff ffff | ffff ffff | 0000 0000  (16TC)
;   AnR = si.ff ffff | ffff ffff | 0000 0000  (16TC)
;   TDR = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;
;**************************************************************************

        MOVE    Y:TR_R,B            ;Get TR
        TST     B       #0,A        ;Test TR
        JEQ     <FUNCTF_R           ;If TR=0 continue
        MOVE    A,Y:TD_R            ;If TR=1, set TDR=0,
        MOVE    A,Y:(R6)+           ; and B1-B6,A1,A2=0
        MOVE    A,Y:(R6)+
        MOVE    A,Y:(R6)+
        MOVE    A,Y:(R6)+
        MOVE    A,Y:(R6)+
        MOVE    A,Y:(R6)+
        MOVE    A,Y:(R6)+
        MOVE    A,Y:(R6)+

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
;   I = siii 0000 | 0000 0000 | 0000 0000
;
; Output:
;   FI = 0iii. 0000 | 0000 0000 | 0000 0000  (3SM)
;   IMAG
;
;**************************************************************************

FUNCTF_R    MOVE    #<$20,X0
        MOVE    X:IMAG,A            ;Get |I|
        CMP     X0,A    #<$50,X0    ;Test for |I|<=2
        JLE     <RANGE0_R
        CMP     X0,A    #<$60,X0    ;Test for 3<=|I|<=5
        JLE     <RANGE1_R
        CMP     X0,A                ;Test for |I|=6
        JEQ     <RANGE3_R
        MOVE    #<$70,A             ;|I|=7, set F[I]=7
        JMP     <FILTA_R
RANGE3_R    MOVE    #<$30,A         ;|I|=6, set F[I]=3
        JMP     <FILTA_R
RANGE1_R    MOVE    #<$10,A         ;|I|=3,4,or 5, set F[I]=1
        JMP     <FILTA_R
RANGE0_R    CLR     A               ;|I|=0,1,or 2, set F[I]=0

;**************************************************************************
;       FILTA
;
; Update short term average of F(I)
;
; DMS(k) = (1 - 2**(-5)) * DMS(k-1) + 2**(-5) * F[I(k)]
;
; Inputs:
;   FI = 0iii. 0000 | 0000 0000 | 0000 0000  (3SM)
;   DMS = 0iii. ffff | ffff f000 | 0000 0000  (12SM)
;
; Output:
;   DMSP = 0iii. ffff | ffff f000 | 0000 0000  (12SM)
;
;**************************************************************************

FILTA_R MOVE    Y:DMS_R,Y0          ;Get DMS
        SUB     Y0,A    A,B         ;Find DIF=FI-DMS, save FI
        MOVE    A,X0    Y:(R7)+,Y1  ;Save DIF, get mask K26
        MPY     X0,Y1,A Y:(R7)+,X0  ;Find DIFSX=DIF>>5, get mask K27
        AND     X0,A    Y:DML_R,Y1  ;Truncate DIFSX, get DML
        ADD     Y0,A    Y:RSHFT+7,X1    ;Find DMSP=DIFSX+DMS

;**************************************************************************
;       FILTB
;
; Update long term average of F(I)
;
; DML(k) = (1 - 2**(-7)) * DML(k-1) + 2**(-7) * F[I(k)]
;
; Inputs:
;   FI = 0iii. 0000 | 0000 0000 | 0000 0000  (3SM)
;   DML = 0iii. ffff | ffff fff0 | 0000 0000  (14SM)
;
; Output:
;   DMLP = 0iii. ffff | ffff fff0 | 0000 0000  (14SM)
;
;**************************************************************************

        SUB     Y1,B    A1,Y:DMS_R  ;Find DIF=FI-DML
        MOVE    B1,X0
        MPY     X0,X1,B Y:(R7)+,X0  ;Find DFISX=DIF>>7, get mask K28
        AND     X0,B                ;Truncate DIFSX
        ADD     Y1,B    Y:RSHFT+3,X1    ;Find DMLP=DIFSX+DML

;**************************************************************************
;       SUBTC
;
; Compute magnitude of the difference of short and long
;  term functions of quantizer output sequence and then
;  perform threshold comparison for quantizing speed control
;  parameter.
;
; AX = 1  if Y>=3, TDP=1, & |DMSP-DMLP|>(2**-3)*DMLP
;    = 0  otherwise
;
; Input:
;   Y = 0iii i.fff | ffff ff00 | 0000 0000  (13SM)
;   DMSP = 0iii. ffff | ffff f000 | 0000 0000  (12SM)
;   DMLP = 0iii. ffff | ffff fff0 | 0000 0000  (14SM)
;   TDP = i000 0000 | 0000 0000 | 0000 0000  (1TC)
;
; Output:
;   AX = 0i0.0 0000 | 0000 0000 | 0000 0000  (1SM)
;
;**************************************************************************

        SUB     B,A     B1,Y:DML_R  ;Find DIF=DMSP-DMLP, save DML
        ABS     A       B1,Y0       ;Find DIFM=|DIF|
        MPY     X1,Y0,B     #<$18,Y0    ;Find DTHR=DMLP>>3, get '3'
        AND     X0,B    #<$40,X0    ;Truncate DTHR, get '1'
        CMP     B,A     #0,B        ;Compare DIFM & DTHR, set AX=0
        TGE     X0,B                ;If DIFM>=DTHR set AX=1
        MOVE    Y:TDP_R,A           ;Get TDP
        TST     A       X:Y_R,A     ;Check TDP, get Y
        TNE     X0,B                ;If TDP!=0 set AX=1
        CMP     Y0,A    X:AP_R,X1   ;Check for Y<"3", get AP
        TLT     X0,B                ;If Y<"3" set AX=1

;**************************************************************************
;       FILTC
;
; Low pass filter of speed control parameter
;
; AP(k) = (1-2**(-4)) * AP(k-1) + AX
;
; Inputs:
;   AX = 0i0.0 0000 | 0000 0000 | 0000 0000  (1SM)
;   AP = 0ii.f ffff | fff0 0000 | 0000 0000  (10SM)
;
; Outputs:
;   APP = 0ii.f ffff | fff0 0000 | 0000 0000  (10SM)
;
;**************************************************************************

        SUB     X1,B    Y:RSHFT+4,Y0    ;Find DIF=AX-AP
        MOVE    B1,X0
        MPY     X0,Y0,A     Y:(R7)+,X0  ;Find DIFSX=DIF>>4, get K29
        AND     X0,A    Y:TR_R,B    ;Truncate DIFSX, get TR
        ADD     X1,A    #<$20,X0    ;Find APP=DIFSX+AP, get '1'

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
;   APP = 0ii.f ffff | fff0 0000 | 0000 0000  (10SM)
;
; Outputs:
;   APR = 0ii.f ffff | fff0 0000 | 0000 0000  (10SM)
;
;**************************************************************************

        TST     B   X:IMAG,X1       ;Check TR, get IMAG
        TMI     X0,A                ;If TR=1 set APR=1, else APR=APP
        MOVE    A1,X:AP_R           ;Save APR to AP

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
;   I = siii. 0000 | 0000 0000 | 0000 0000  (ADPCM format)
;
; Outputs:
;   WI = siii iiii. | ffff 0000 | 0000 0000  (12TC)
;
;**************************************************************************

        MOVE    Y:RSHFT+20,X0       ;Get shift constant
        MPY     X0,X1,A     #WIBASE,R0  ;Shift IM=IMAG for lookup,
                                    ; load lookup table base
        MOVE    A1,N0               ;Load IM as offset
        MOVE    Y:RSHFT+3,X1        ;Get shift constant
        MOVE    X:Y_R,Y0            ;Get Y
        MPY     Y0,X1,B     X:(R0+N0),A ;Shift Y>>3,
                                    ; get WI from lookup table

;**************************************************************************
;       FILTD
;
; Update of fast quantizer scale factor
;
; YU(k) = (1 - 2**(-5)) * Y(k) + 2**(-5) * W[I(k)]
;
; Inputs:
;   WI =  siii iiii. | ffff 0000 | 0000 0000  (12TC)
;   Y = 0iii i.fff | ffff ff00 | 0000 0000  (13SM)
;
; Outputs:
;   YUT = 0iii i.fff | ffff ff00 | 0000 0000  (13SM)
;
;**************************************************************************

        SUB     B,A                 ;Find DIF=WI-Y
        ASR     A                   ;Find DIFSX=DIF>>5 (actually DIF>>2)
        ASR     A   Y:(R7)+,X0      ;Get mask K30
        AND     X0,A                ;Truncate DIFSX
        ADD     Y0,A    #<$50,X0    ;Find YUT=DIFSX+Y,
                                    ; get upper limit '10'

;**************************************************************************
;       LIMB
;
; Limit quantizer scale factor
;
; 1.06 <= YU(k) <= 10.00
;
; Inputs:
;   YUT = 0iii i.fff | ffff ff00 | 0000 0000  (13SM)
;
; Outputs:
;   YUP = 0iii i.fff | ffff ff00 | 0000 0000  (13SM)
;
;**************************************************************************

        CMP     X0,A    Y:(R7)+,X1  ;Check for YU>10,
                                    ; get lower limit '1.06' (K31)
        TGT     X0,A                ;If YU>10 set YU=10
        CMP     X1,A    Y:YL_R,Y1   ;Check for YU<1.06, get YL
        TLT     X1,A                ;If YU<1.06 set YU=1.06

;**************************************************************************
;       FILTE
;
; Update of slow quantizer scale factor
;
; YL(k) = (1 - 2**(-6)) * YL(k-1) + 2**(-6) * YU(k)
;
; Inputs:
;   YUP = 0iii i.fff | ffff ff00 | 0000 0000  (13SM)
;   YL = 0iii i.fff | ffff ffff | ffff 0000  (19SM)
;
; Outputs:
;   YLP = 0iii i.fff | ffff ffff | ffff 0000  (19SM)
;
;**************************************************************************

        TFR     Y1,B    A1,Y:YU_R   ;Move YL, save YUP
        NEG     B   Y:(R7)+,Y0      ;Find -YL, save YL, get mask K32
        AND     Y0,B    #CONST4,R7  ;Truncate -YL (-YL>>6),
                                    ; adjust constant pointer
        ADD     B,A     Y:RSHFT+6,Y0    ;Find DIF=YUP+(-YL>>6)
        MOVE    A1,X1
        MPY     Y0,X1,A     #$002100,Y0     ;Find DIFSX>>6, get bias
        ADD     Y1,A    Y:LAW,B     ;Find YLP=DIFSX+YL
        MOVE    A1,Y:YL_R           ;Save YL

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

        TST     B       Y:SR_R,A    ;Adjust constant pointer
        JNE     <ALAW_R

; Linear to log routine for mu-law
        ABS     A       A,B         ;Find |SR|, save sign
        ADD     Y0,A                ;Add bias
        ASL     A   #TAB+7,R0       ;Shift << 2, get seg ptr
        ASL     A   X:TAB+3,X0      ; and get max. word
        TES     X0,A                ;If overflow in extension
                                    ; set the maximum PCM word
        NORM    R0,A                ;Find MSB of data
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        ASL     A       #<$20,Y0
        LSL     B       A1,X0
        MPY     X0,Y0,A     X:(R0),X1
        AND     X1,A
        ROR     A
        NOT     A       #<$FF,X0
        AND     X0,A
        MOVE    A1,A
        JMP     <SAVESP_R

; Linear to log routine for A-law
ALAW_R  ABS     A       A,B         ;Find |SR|, save sign
        TST     B       #$000100,X0
        JPL     <NOSUB_R
        SUB     X0,A
NOSUB_R MOVE    #$7FFE00,X0
        AND     X0,A
        ASL     A   #TAB+7,R0       ;Shift << 2, get seg ptr
        ASL     A   X:TAB+3,X0      ; and get max. word
        TES     X0,A                ;If overflow in extension
                                    ; set the maximum PCM word
        NORM    R0,A                ;Find MSB of data
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        JNR     <SEGOK_R
        MOVE    (R0)-
SEGOK_R LSL     A       #<$20,Y0
        LSL     B       A1,X0
        MPY     X0,Y0,A     X:(R0),X1
        AND     X1,A
        ROR     A       #<$D5,Y1
        EOR     Y1,A    #<$FF,X0    ;Invert even bits & sign
        AND     X0,A
        MOVE    A1,A
SAVESP_R    MOVE    A1,X:SP_R

;**************************************************************************
;       EXPAND
;
; Convert A-law or mu-law PCM to uniform PCM (according to
;   Recommendation G.711). For further details see Motorola
;   application bulletin "Logarithmic/Linear Conversion
;   Routines for DSP56000/1".
;
; Input:
;   SP = psss qqqq | 0000 0000 | 0000 0000 (PCM log format)
;
; Output:
;   SLX = siii iiii | iiii ii.00 | 0000 0000  (14TC)
;
;**************************************************************************

        MOVE    A,X0        Y:(R7)+,Y1  ;Get shift constant K4
        MPY     X0,Y1,A     Y:(R7)+,X1  ;Shift S to 8 lsb's of A1, get K5
        AND     X1,A    Y:SE_R,B    ;Mask off sign of S, get SE
        ASR     B       A1,N3       ;Sign extend SE, load |S| as offset
        CMPM    Y1,A                ;Check sign of S
        MOVE    X:(R3+N3),A         ;Lookup |SLX| from ROM table
        JGE     <SUBTA_R            ;If S=0, SLX=|SLX|
        NEG     A                   ;If S=1, SLX=-|SLX|

;**************************************************************************
;       SUBTA
;
; Compute difference signal by subtracting signal estimate
;       from input signal
;
;   DX(k) = SLX(k) - SE(k)
;
; Inputs:
;   SLX = siii iiii | iiii ii.00 | 0000 0000  (14TC) 
;   SE = siii iiii | iiii iii.0 | 0000 0000  (15TC)
;
; Output:
;   DX = siii iiii | iiii iiii. | 0000 0000  (16TC)
;**************************************************************************

SUBTA_R ASR     A       Y:(R7)+,X1  ;Sign extend SLX, get mask K6
        ASR     A       #$000E,R0   ;Sign extend SE again, get exp bias (14)
        SUB     B,A     X:Y_R,B     ;Find DX=SLX-SE, get Y

;**************************************************************************
;       LOG
;
; Convert difference signal from the linear to the log
;   domain
;
; Input:
;   DX = siii iiii | iiii iiii. | 0000 0000  (16TC)
;
; Outputs:
;   DLX = 0iii i.fff | ffff 0000 | 0000 0000  (11SM)
;   DSX = sXXX XXXX | XXXX XXXX | 0000 0000  (1TC)
;
;**************************************************************************

        ABS     A   A,Y1            ;Find DQM=|D|, save DSX to Y1
        JNE     <NORMEXP_R          ;Check for DQM=0
        CLR     A       (R7)+       ;If DQM=0 set DL=0,
        MOVE    Y:(R7),X0           ; get mask K8,
        JMP     <SUBTB_R            ; and continue
NORMEXP_R   NORM    R0,A            ;If DQM!=0, do norm iteration
        NORM    R0,A                ; 14 times to find MSB of DQM
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
        NORM    R0,A
;   A1 = 01?? ???? | ???? ???? | 0000 0000 = normalized DQM  (A2=A0=0)
;   R0 = 0000 0000 | 0000 eeee = exponent of normalized DQM

;   Get rid of leading "1" in normalized DQM
;   Truncate mantissa to 7 bits and combine with exponent
        AND     X1,A    Y:LSHFT-19,X0   ;Truncate MANT, get EXP shift
;   A1 = 00mm mmmm | m000 0000 | 0000 0000 (A2=A0=0)
        MOVE    R0,X1               ;Move EXP to X1
        MPY     X0,X1,A     A,X1    Y:(R7)+,Y0 ;Shift EXP<<19, save MANT to X1,
                                    ; get mask K7
        MOVE    A0,A                ;Move EXP to A1
;   A1 = 0eee e000 | 0000 0000 | 0000 0000 (A2=A0=0)
        MAC     Y0,X1,A     Y:(R7),X0   ;Shift MANT>>3 & combine with EXP,
                                        ; get mask K8
;   A1 = 0eee e.mmm | mmmm 0000 | 0000 0000  (A2=A0=0)
;      = 0iii i.fff | ffff 0000 | 0000 0000  (A2=A0=0)

;**************************************************************************
;       SUBTB
;
; Scale log version of difference signal by subtracting
;   scale factor
;
; DLNX = DLX - Y
;
; Inputs:
;   DLX = 0iii i.fff | ffff 0000 | 0000 0000  (11SM)
;   Y = 0iii i.fff | ffff ff00 | 0000 0000  (13SM)
;
; Output:
;   DLNX = siii i.fff | ffff 0000 | 0000 0000 (12TC)
;
;**************************************************************************

SUBTB_R AND     X0,B    #QUANTAB,R0     ;Truncate Y to 11 bits (Y>>2),
                                        ; get quantization table base
        SUB     B,A     #>QUANTAB+2,X1  ;Find DLNX=DLX-Y

;**************************************************************************
;       SYNC
;
; Re-encode output PCM sample in decoder for synchronous
;   tandem coding
;
; Inputs:
;   I = siii 0000 | 0000 0000 | 0000 0000 (ADPCM format)
;   SP = psss qqqq | 0000 0000 | 0000 0000 (PCM log format)
;   DLNX = siii i.fff | ffff 0000 | 0000 0000 (12TC)
;   DSX = sXXX XXXX | XXXX XXXX | 0000 0000  (1TC)
;
; Output:
;   SD = psss qqqq | 0000 0000 | 0000 0000 (PCM log format)
;
;**************************************************************************

        MOVE    X:(R0)+,X0          ;Get quan table value
TSTDLN_R    CMP     X0,A    X:(R0)+,X0  ;Compare to DLNX
        JGE     <TSTDLN_R           ;If value<DLNX try next range
        MOVE    R0,A                ;When range found...
                                    ; subtract pointer from
        SUB     X1,A    Y:LSHFT-19,X0   ; base to get |ID|  
;   A1 = 0000 0000 | 0000 0000 | 0000 0iii (A2=A0=0)
        MOVE    A1,X1
        MPY     X0,X1,A     Y1,B    ;Shift |ID|<<19, result is
                                    ; in A0, move DSX into B
;   A0 = 00ii i000 | 0000 0000 | 0000 0000
        MOVE    A0,A
;   A1 = 00ii i000 | 0000 0000 | 0000 0000 (A2=A0=0)
        TST     A       #<$78,X0    ;Check |ID|, get invert mask
        JEQ     <INVERT_R           ;If |ID|=0 invert bits
        TST     B                   ;If |ID|!=0, check DSX
        JPL     <IOUT_R             ;If DSX=1 don't invert |ID|
INVERT_R    EOR     X0,A            ;If DSX=0 or |ID|=0,
                                    ; invert |ID|
IOUT_R  MOVE    #<$40,X0
        EOR     X0,A    X:I_R,B     ;Invert MSB of ID, get I
        TST     B       A1,A        ;Adjust sign extension, check IS

        JMI     <ANDW7_R            ;If IS=1, AND with 7
        MOVE    #<$80,X0            ;If IS=0,
        EOR     X0,B                ; find IM=I+8
        JMP     <FIXS_R
ANDW7_R MOVE    #<$70,X0
        AND     X0,B                ;Find IM=I&7

FIXS_R  LSR     B
        MOVE    B1,B
;   A1 = 0iii i000 | 0000 0000 | 0000 0000 (A2=A0=0)
;   B1 = 0iii i000 | 0000 0000 | 0000 0000 (B2=B0=0)
        SUB     B,A     Y:LAW,B
        TST     B
        JNE     <ALAWDEC_R

        TST     A       X:SP_R,A    ;Compare ID and IM, get SP
        JEQ     <SAVESD_R           ;If ID=IM, SD=SP
        JLT     <SPPLUS_R           ;If ID<IM, SD=SP+
                                    ;Else ID>IM, SD=SP-
        TST     A       #<$80,X0
        JEQ     <SAVESD_R           ;If SP=0, SP-=SP
        CMP     X0,A    #<$FF,X0
        JEQ     <INCSP_R            ;If SP=$80, SP-=SP+1
        CMP     X0,A    #<$7F,X0
        JEQ     <SETNEG1_R          ;If SP=$FF, SP-=$7E
        CMP     X0,A
        JEQ     <DECSP_R            ;If SP=$7F, SP-=SP-1
        TST     A
        JPL     <DECSP_R            ;Else if SPS=1, SP-=SP-1
        JMP     <INCSP_R            ;Else SPS=0, SP-=SP+1

SPPLUS_R    TST     A       #<$80,X0
        JEQ     <INCSP_R            ;If SP=0, SP+=SP+1
        CMP     X0,A    #<$FF,X0
        JEQ     <SAVESD_R               ;If SP=$80, SP+=SP
        CMP     X0,A    #<$7F,X0
        JEQ     <DECSP_R            ;If SP=$FF, SP+=SP-1
        CMP     X0,A
        JEQ     <SET1_R             ;If SP=$7F, SP+=$FE
        TST     A
        JPL     <INCSP_R            ;Else if SPS=1, SP+=SP+1
        JMP     <DECSP_R            ;Else SPS=0, SP+=SP-1

INCSP_R MOVE    #<$01,X0
        ADD     X0,A                ;Find SD=SP+1
        JMP     <SAVESD_R
DECSP_R MOVE    #<$01,X0
        SUB     X0,A                ;Find SD=SP-1
        JMP     <SAVESD_R
SET1_R  MOVE    #<$FE,A             ;Find SD=$FE
        JMP     <SAVESD_R
SETNEG1_R   MOVE    #<$7E,A             ;Find SD=$7E
        JMP     <SAVESD_R


ALAWDEC_R   MOVE    A,B
        MOVE    X:SP_R,A                    ;Get SP
        MOVE    #<$55,X0
        EOR     X0,A
        TST     B
        JEQ     <INVEVEN_R          ;If ID=IM, SD=SP
        JLT     <SPPLUSA_R          ;If ID<IM, SD=SP+
                                    ;Else ID>IM, SD=SP-
        TST     A       #<$80,X0
        JEQ     <INCSPA_R           ;If SP=0, SP-=SP+1
        CMP     X0,A    #<$FF,X0
        JEQ     <SETNEG0_R          ;If SP=$80, SP-=0
        CMP     X0,A    #<$7F,X0
        JEQ     <DECSPA_R               ;If SP=$FF, SP-=SP-1
        CMP     X0,A
        JEQ     <INVEVEN_R          ;If SP=$7F, SP-=SP
        TST     A
        JMI     <DECSPA_R           ;Else if SPS=0, SP-=SP-1
        JMP     <INCSPA_R           ;Else SPS=1, SP-=SP+1

SPPLUSA_R   TST     A       #<$80,X0
        JEQ     <SET0_R             ;If SP=0, SP+=$80
        CMP     X0,A    #<$FF,X0
        JEQ     <INCSPA_R           ;If SP=$80, SP+=SP+1
        CMP     X0,A    #<$7F,X0
        JEQ     <INVEVEN_R          ;If SP=$FF, SP+=SP
        CMP     X0,A
        JEQ     <DECSPA_R           ;If SP=$7F, SP+=SP-1
        TST     A
        JMI     <INCSPA_R           ;Else if SPS=0, SP+=SP+1
        JMP     <DECSPA_R           ;Else SPS=1, SP+=SP-1

INCSPA_R    MOVE    #<$01,X0
        ADD     X0,A                ;Find SD=SP+1
        JMP     <INVEVEN_R
DECSPA_R    MOVE    #<$01,X0
        SUB     X0,A                ;Find SD=SP-1
        JMP     <INVEVEN_R
SET0_R  MOVE    #<$80,A             ;Find SD=$80
        JMP     <INVEVEN_R
SETNEG0_R   CLR     A                   ;Find SD=0
INVEVEN_R   MOVE    #<$55,X0
        EOR     X0,A
    
SAVESD_R    MOVE    #2,X0
        JSR     $E004

        MOVE    R2,X:DATAPTR_R

        JMP     <ENCODE

;**************************************************************************
;       INIT
;
; Initialize program variables, transfer data tables to X and Y
; memory, and set up registers
;
;**************************************************************************

INIT    MOVE    #0,R0
        MOVE    #0,R4
        REP     #$7F
        MOVE    A,X:(R0)+   A,Y:(R4)+   ;Clear X & Y internal RAM

; X memory initialization

        MOVE    #$3E2000,X0
        MOVE    X0,X:AP_T           ;Initialize AP_T & AP_R
        MOVE    A0,X:AP_R
        MOVE    #DATA_T,A0          ;Set transmit data pointer
        MOVE    A0,X:DATAPTR_T      ; to start of transmit data buffer
        MOVE    #DATA_R,A0          ;Set receive data pointer
        MOVE    A0,X:DATAPTR_R      ; to start of receive data buffer
        MOVE    #VARINIT,R0
        MOVE    #QUANTAB,R3
        DO      #38,XTABLES
        MOVE    P:(R0)+,X0          ;Transfer constant tables
        MOVE    X0,X:(R3)+          ; into X memory
XTABLES
        MOVE    #DATA_T+1,R3
        MOVE    #<$4,X0
        MOVE    #<$8,X1
        DO      #6,XBUFFER1
        MOVE    X0,X:(R3)+          ;Initialize SRnMANT and SRnS vars
        MOVE    X1,X:(R3)+          ; in the transmit data buffer
        MOVE    (R3)+
XBUFFER1
        MOVE    X0,X:(R3)+          ;Initialize SR1MANT (transmit)
        MOVE    (R3)+
        MOVE    (R3)+
        MOVE    X0,X:(R3)+          ;Initialize SR2MANT (transmit)
        MOVE    #DATA_R+1,R3
        DO      #6,XBUFFER2
        MOVE    X0,X:(R3)+          ;Initialize SRnMANT and SRnS vars
        MOVE    X1,X:(R3)+          ; in the receive data buffer
        MOVE    (R3)+
XBUFFER2
        MOVE    X0,X:(R3)+          ;Initialize SR1MANT (receive)
        MOVE    (R3)+
        MOVE    (R3)+
        MOVE    X0,X:(R3)+          ;Initialize SR2MANT (receive)

; Y memory initialization

        MOVE    #$088000,X0
        MOVE    X0,Y:YU_T           ;Initialize YU_T,
        MOVE    X0,Y:YL_T           ; & YL_T
        MOVE    X0,Y:YU_R           ;Initialize YU_R,
        MOVE    X0,Y:YL_R           ; & YL_R
        MOVE    #RSHFT,R3
        DO      #56,YTABLES
        MOVE    P:(R0)+,X0          ;Transfer constant tables
        MOVE    X0,Y:(R3)+          ; into Y memory
YTABLES

; Address register initialization

        MOVEC   #7,M1               ;Set partial product buffer for mod(7)
        MOVEC   #23,M2              ;Set data buffer for mod(23)
        MOVEC   #7,M6               ;Set coef buffer for mod(7)
        MOVEC   #$7F,M3             ;Set PCM table for mod(127)
        MOVE    #0,A                ;Select mu-law or A-law,
        MOVE    A,Y:LAW             ; for mu-law set LAW=0 (default),
                                    ; for A-law set LAW!=0
        TST     A       #$100,R3    ;If LAW=0 select mu-law table
        JEQ     <SETR5              ; base (in X ROM), otherwise
        MOVE    #$180,R3            ; select A-law table base
SETR5   MOVE    #RSHFT,R5           ;Set right shift table base
        RTS

;QUANTAB
VARINIT     DC      $F84000         ;-0.98
            DC      $050000         ;0.62
            DC      $0B2000         ;1.38
            DC      $0F6000         ;1.91
            DC      $12C000         ;2.34
            DC      $15D000         ;2.72
            DC      $190000         ;3.12
            DC      $7FFFFF         ;15.99
;IQUANTAB
            DC      $800000         ;-16    |I|=0
            DC      $004000         ;0.031  |I|=1
            DC      $087000         ;1.05   |I|=2
            DC      $0D5000         ;1.66   |I|=3
            DC      $111000         ;2.13   |I|=4
            DC      $143000         ;2.52   |I|=5
            DC      $175000         ;2.91   |I|=6
            DC      $1A9000         ;3.32   |I|=7
;WIBASE
            DC      $FF4000         ;-0.75  |I|=0
            DC      $012000         ;1.13   |I|=1
            DC      $029000         ;2.56   |I|=2
            DC      $040000         ;4.00   |I|=3
            DC      $070000         ;7.00   |I|=4
            DC      $0C6000         ;12.38  |I|=5
            DC      $163000         ;22.19  |I|=6
            DC      $462000         ;70.13  |I|=7
;TAB
            DC      $1E0000
            DC      $3E0000
            DC      $5E0000
            DC      $7E0000
            DC      $9E0000
            DC      $BE0000
            DC      $DE0000
            DC      $FE0000
;CONST - constants used in FMULT
            DC      $FFFC00         ;KF1 = trunc mask
            DC      $7FFC00         ;KF2 = trunc mask
            DC      $018000         ;KF3 = '48'
            DC      $7F8000         ;KF4 = trunc mask
            DC      $00001A         ;KF5 = '26'
            DC      $7FFF00         ;KF6 = trunc mask

;RSHFT
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
;CONST1
            DC      $FFFE00         ;K1 = trunc mask (ACCUM)
            DC      $7FFC00         ;K2 = trunc mask (MIX)
            DC      $7FFE00         ;K3 = trunc mask (MIX)
            DC      $000080         ;K4 = shift const (EXPAND)
            DC      $00007F         ;K5 = sign mask (EXPAND)
            DC      $3F8000         ;K6 = trunc mask (LOG)
            DC      $100000         ;K7 = shift const (LOG)
            DC      $7FF000         ;K8 = trunc mask (SUBTB & ADDA)
            DC      $07F000         ;K9 = sign mask (ANTILOG)
            DC      $00000A         ;K10 = '10' (ANTILOG)
            DC      $7FFE00         ;K11 = trunc mask (ANTILOG)
            DC      $07C000         ;K12 = trunc mask (TRANS)
            DC      $000010         ;K13 = shift const (TRANS)
            DC      $000008         ;K14 = '8' (TRANS)
            DC      $000005         ;K15 = '5' (TRANS)
            DC      $7FFE00         ;K16 = trunc mask (TRANS)
            DC      $008000         ;K17 = +gain (UPB)
            DC      $FF8000         ;K18 = -gain (UPB)
            DC      $FFFF00         ;K19 = trunc mask (UPB)
            DC      $1FFF00         ;K20 = '+1.99' (UPA2)
            DC      $E00100         ;K21 = '-1.99' (UPA2)
            DC      $FFFF00         ;K22 = trunc mask (UPA2)
            DC      $FF4000         ;K23 = -gain (UPA1)
            DC      $00C000         ;K24 = +gain (UPA1)
            DC      $FFFF00         ;K25 = trunc mask (UPA1)
            DC      $040000         ;K26 = shift const (FILTA)
            DC      $FFF800         ;K27 = trunc mask (FILTA)
            DC      $FFFE00         ;K28 = trunc mask (FILTB)
            DC      $FFE000         ;K29 = trunc mask (FILTC)
            DC      $FFFC00         ;K30 = trunc mask (FILTD)
            DC      $088000         ;K31 = '1.06' (LIMB)
            DC      $FFFC00         ;K32 = trunc mask (FILTE)
