* START UPP RUTIN

PROG    PEA     INITUNE
        MOVE.W  #$26,-(A7)
        TRAP    #14
        ADDQ.L  #6,A7

        CLR.L   -(SP)
        MOVE.W  #$20,-(SP)
        TRAP    #1
        ADDQ.L  #6,SP
        MOVE.L  D0,SAVE_USP

        BCLR    #0,$484
        BCLR    #1,$484

        JSR     CREAT_VBI

IGEN
	MOVE.W  #7,-(SP)
        TRAP    #1
        ADDQ.L  #2,SP

        CMP.W   #$20,D0
        BNE     IGEN
                 
        BSR     YMOFF

        BSET    #0,$484
        BSET    #1,$484
        MOVE.W  #$2700,SR
        MOVE.L  SAVE_VBI,A0
        MOVE.L  #$0,(A0)
        MOVE.W  #$2300,SR
        
        MOVE.L  SAVE_USP,-(A7)
        MOVE.W  #$20,-(SP)
        TRAP    #1
        ADDQ.L  #6,SP

        CLR.W   -(SP)
        TRAP    #1
        ADDQ.L  #2,SP

CREAT_VBI
        LEA     MUSIC50,A0
        MOVE.L  A0,D1
        MOVEA.L $456.W,A0
LABEL1  TST.L   (A0)
        BEQ     LABEL2
        ADDA.W  #4,A0
        BRA     LABEL1
LABEL2  MOVE.L  A0,SAVE_VBI
        MOVE.L  D1,(A0)
        RTS

* Reset All YM-2149 Registers And turn off channels

YMOFF
        LEA     $FF8800,A6
        MOVE.W  #13,D0
        MOVE.B  #7,(A6)
        MOVE.B  #$FF,2(A6)
INITLOOP
        MOVE.B  D0,(A6)
        MOVE.B  #0,2(A6)
        DBRA    D0,INITLOOP
        MOVE.B  #6,(A6)
        MOVE.B  #50,2(A6)
        MOVE.B  #7,(A6)
        MOVE.B  #216,2(A6)
        RTS

SAVE_VBI
        DS.L    1
SAVE_USP        
        DS.L    1


* MUSIK RUTINER

INITUNE CLR.B   MONOFF
        LEA     STADS,A0
        LEA     CHAN_A,A1
        MOVEQ   #2,D7
INITIAL MOVE.B  #1,$1B(A1)
        CLR.B   0(A1)
        CLR.B   $2C(A1)
        MOVEA.L (A0)+,A2
        MOVE.L  A2,6(A1)
        MOVE.L  #4,$A(A1)
        MOVE.L  (A2),2(A1)
        ADDA.L  #$2E,A1
        DBF     D7,INITIAL
        MOVE.B  #1,NO_TT
        MOVE.B  #1,MONOFF
        RTS
VSET    LEA     MUSIC50,A0
        MOVEA.L $456,A1
        ADDA.W  #4,A1
        MOVE.L  A0,(A1)
        RTS


* DATA TABLE

CHAN_A  DC.B    0	* KONTROL REGISTER
	DC.B	0
	DC.L	0	* DEL MELODI PEKARE (A1PX)
	DC.L	0	* MELODI PEKARE (TUNEA1)
	DC.L	0
	DC.W	0
	DC.L	0
	DC.L	0
	DC.B	0
	DC.B	0
	DC.B	0
	DC.B	0
	DC.B	0
	DC.B	0
	DC.B	0	* VOLUME
	DC.B	0
	DC.L	0
	DC.L	0
	DC.B	0
	DC.B	0
	DC.B	0
	DC.B	0
	DC.B	0
	DC.B	9	* BRUS KANAL 

CHAN_B  DC.B    0
	DC.B	0
	DC.L	0	
	DC.L	0	
	DC.L	0
	DC.W	0
	DC.L	0
	DC.L	0
	DC.B	0
	DC.B	0
	DC.B	0
	DC.B	0
	DC.B	0
	DC.B	0
	DC.B	0	
	DC.B	0
	DC.L	0
	DC.L	0
	DC.B	0
	DC.B	0
	DC.B	0
	DC.B	0
	DC.B	0
	DC.B	$12

CHAN_C  DC.B    0
	DC.B	0
	DC.L	0
	DC.L	0
	DC.L	0
	DC.W	0
	DC.L	0
	DC.L	0
	DC.B	0
	DC.B	0
	DC.B	0
	DC.B	0
	DC.B	0
	DC.B	0
	DC.B	0
	DC.B	0
	DC.L	0
	DC.L	0
	DC.B	0
	DC.B	0
	DC.B	0
	DC.B	0
	DC.B	0
	DC.B	$24

NO_TT   DC.B    0
NO_T    DC.B    0
NZ_F    DC.B    0
NZ_FT   DC.B    0		* BRUS KANEL FREKVENS
REG_7   DC.B    $FF
FINET   DC.B    6		* VBI COUNTER

RET     RTS			* RETURN FROM SUB-RUTIN

MUSIC50 BTST    #1,$FF820A	* 50 ELLER 60 Hz
        BNE     NOT60
        SUBQ.B  #1,FINET
        BNE     NOT60
        MOVE.B  #6,FINET
        BRA     RET

NOT60   TST.B   MONOFF		* 1 = LÜt pÜ, 0 = LÜt av
        BEQ     RET
        MOVE.B  NZ_F,NZ_FT
        SUBQ.B  #1,NO_TT
        BNE     WALBOL
        LEA     CHAN_A,A0
        BSR     MZ_CH
        LEA     CHAN_B,A0
        BSR     MZ_CH
        LEA     CHAN_C,A0
        BSR     MZ_CH
        MOVE.B  NO_T,NO_TT

WALBOL  LEA     CHAN_A,A0	* D0 = Tone, D1 = Volume
        BSR     MZ_50
        MOVE.W  D0,TEMPD0
        MOVE.B  D0,REGS
        MOVE.B  TEMPD0,(REGS+1)
        MOVE.B  D1,(REGS+8)

        LEA     CHAN_B,A0	* D0 = Tone, D1 = Volume
        BSR     MZ_50
        MOVE.W  D0,TEMPD0
        MOVE.B  D0,(REGS+2)
        MOVE.B  TEMPD0,(REGS+3)
        MOVE.B  D1,(REGS+9)

        LEA     CHAN_C,A0	* D0 = Tone, D1 = Volume
        BSR     MZ_50
        MOVE.W  D0,TEMPD0
        MOVE.B  D0,(REGS+4)
        MOVE.B  TEMPD0,(REGS+5)
        MOVE.B  D1,(REGS+10)

        MOVE.B  NZ_FT,(REGS+6)	* BRUS FREKVENSEN


* SKRIVER UT DATA FRèN REGS Pè LJUDCHIP

MZ_OUT  MOVE.B  #7,$FF8800	
        MOVE.B  $FF8800,D0
        ANDI.B  #$C0,D0
        ANDI.B  #$3F,(REGS+7)
        OR.B    D0,(REGS+7)
        LEA     FREGS,A0
        MOVE.W  #$C,D0
OUTER   MOVE.B  D0,$FF8800
        MOVE.B  -(A0),$FF8802
        DBF     D0,OUTER
        BRA     RET


TURNOFF CLR.B   MONOFF
CLR_REG MOVE.B  #7,$FF8800
        MOVE.B  $FF8800,D1
        ORI.B   #$3F,D1
        MOVE.W  #$C,D0
CLR_LP  MOVE.B  D0,$FF8800
        MOVE.B  #0,$FF8802
        DBF     D0,CLR_LP
        MOVE.B  #7,$FF8800
        MOVE.B  D1,$FF8802
        RTS


TOKE_TAB
        DC.L    PAUSE,VIBE_0
        DC.L    VIBE_1,VIBE_2
        DC.L    SLIDE,GL_DN
        DC.L    GL_UP,ENDING
        DC.L    VIBE_SET,NZ_FREQ
        DC.L    SQUARE,NOISE
        DC.L    BOTH,TOGGLE
        DC.L    CUTT


CUTT    ADDQ.L  #4,A7
        BRA     TURNOFF

ENDING  MOVE.L  $A(A0),D0
        MOVEA.L 6(A0),A2
        ADDA.L  D0,A2
        ADDQ.L  #4,D0
        MOVEA.L (A2),A1
        TST.L   (A2)
        BNE     SET_MEM
        MOVEA.L 6(A0),A2
        MOVEQ   #4,D0
        MOVEA.L (A2),A1

SET_MEM MOVE.L  D0,$A(A0)
        BRA     READ

NOISE   MOVE.B  $2D(A0),D0
        MOVE.B  D0,D1
        ANDI.B  #7,D0
        MOVE.B  REG_7,D2
        EOR.B   D2,D0
        AND.B   D1,D0
        EOR.B   D2,D0
        MOVE.B  D0,REG_7
        BRA     READ

SQUARE  MOVE.B  $2D(A0),D0
        MOVE.B  D0,D1
        ANDI.B  #$38,D0
        MOVE.B  REG_7,D2
        EOR.B   D2,D0
        AND.B   D1,D0
        EOR.B   D2,D0
        MOVE.B  D0,REG_7
        BRA     READ

BOTH    MOVE.B  $2D(A0),D0
        EORI.B  #$FF,D0
        MOVE.B  REG_7,D2
        AND.B   D2,D0
        AND.B   D0,REG_7
        BRA     READ

SLIDE   CLR.W   $E(A0)
        BSET    #2,0(A0)
        MOVE.B  (A1)+,$18(A0)
        MOVE.B  (A1)+,$19(A0)
        BRA     READ

NZ_FREQ MOVE.B  (A1)+,NZ_F
        BRA     READ

VIBE_SET
        MOVE.B  (A1)+,$2A(A0)
        MOVE.B  (A1),$29(A0)
        MOVE.B  (A1)+,$2B(A0)
        BRA     READ

GL_UP   BSET    #7,0(A0)

GL_DN   BSET    #3,0(A0)
        BRA     READ

VIBE_0  CLR.B   $2C(A0)
        BRA     READ

VIBE_1  MOVE.B  #$40,$2C(A0)
        BRA     READ

VIBE_2  MOVE.B  #$C0,$2C(A0)
        BRA     READ

TOGGLE  BSET    #1,0(A0)
        BRA     READ

PAUSE   CLR.B   $1E(A0)
        BRA     VALUED

MZ_CH   SUBQ.B  #1,$1B(A0)
        BNE     GLISS_IT
        CLR.B   0(A0)
        MOVEA.L 2(A0),A1

READ    MOVEQ   #0,D0
        MOVE.B  (A1)+,D0
        BMI     EXTEND
        MOVE.B  D0,$1D(A0)
        MOVEA.L $24(A0),A2
        MOVE.L  A2,$20(A0)
        MOVE.B  (A2),$28(A0)
        MOVE.B  (A2),$1E(A0)
        MOVE.B  $1A(A0),$1F(A0)
        BSET    #5,0(A0)

VALUED  MOVE.B  $1C(A0),$1B(A0)
        MOVE.L  A1,2(A0)
        RTS

GLISS_IT
        BTST    #3,0(A0)
        RTS
        BTST    #7,0(A0)
        BEQ     GL_DOWN
        ADDQ.B  #1,$1D(A0)
        RTS

GL_DOWN SUBQ.B  #1,$1D(A0)
        RTS

EXTEND  CMP.B   #$B8,D0
        BCS     TOKENS
        ADDI.B  #$20,D0
        BCS     LENGTH
        ADDI.B  #$10,D0
        BCS     ENVS
        ADDI.B  #$10,D0
        BCC     TEMPS
        ASL.B   #2,D0
        LEA     CH_TAB,A2
        ADDA.L  D0,A2
        MOVE.L  (A2),$14(A0)
        MOVE.L  (A2),$10(A0)
        BRA     READ

TEMPS   ADDI.B  #9,D0
        MOVE.B  D0,NO_T
        BRA     READ

LENGTH  ADDQ.B  #1,D0
        MOVE.B  D0,$1C(A0)
        BRA     READ

ENVS    ASL.W   #2,D0
        LEA     EV_TAB,A2
        MOVEA.L 0(A2,D0.W),A2
        MOVE.L  A2,$24(A0)
        MOVE.B  -1(A2),$1A(A0)
        BRA     READ

TOKENS  ANDI.W  #$7F,D0		* HOPPAR TILL TOKENS-RUTINER
        ASL.W   #2,D0
        LEA     TOKE_TAB,A2
        MOVEA.L 0(A2,D0.W),A2
        JMP     (A2)


MZ_50   MOVEQ   #0,D7
        MOVE.B  0(A0),D7
        BTST    #5,D7
        BEQ     FORM
        SUBQ.B  #1,$1F(A0)
        BCC     EV_DELAY
        MOVE.B  $1A(A0),$1F(A0)
        MOVEA.L $20(A0),A2
        CMPI.B  #$87,1(A2)
        BEQ     EV_DELAY
        ADDQ.L  #1,$20(A0)
        MOVE.B  1(A2),$28(A0)

EV_DELAY
        MOVE.B  $28(A0),$1E(A0)
        BNE     FORM

FORM    MOVE.B  $1D(A0),D0
        MOVEA.L $14(A0),A1
        MOVE.B  (A1),D1
        CMP.B   #$87,D1
        BNE     CH_CALC
        MOVEA.L $10(A0),A1
        MOVE.B  (A1),D1

CH_CALC ADDQ.L  #1,A1
        MOVE.L  A1,$14(A0)
        ADD.B   D1,D0

PRODUCE LEA     NOTE_TAB,A1
        ADD.B   D0,D0
        MOVEQ   #0,D1
        MOVE.B  D0,D1
        ADDA.L  D1,A1
        MOVE.W  (A1),D0
        MOVE.B  $2C(A0),D6
        BTST    #6,D6
        BEQ     TWIGGLE
        MOVE.B  D1,D5
        MOVE.B  $29(A0),D4
        LSL.B   #1,D4
        MOVE.B  $2B(A0),D1
        BTST    #7,D6
        BEQ     VB_NOW
        BTST    #0,D7
        BNE     VB_SAME

VB_NOW  BTST    #5,D6
        BNE     VB_UP
        SUB.B   $2A(A0),D1
        BCC     VB_REACH
        BSET    #5,$2C(A0)
        MOVEQ   #0,D1
        BRA     VB_REACH

VB_UP   ADD.B   $2A(A0),D1
        CMP.B   D4,D1
        BCS     VB_REACH
        BCLR    #5,$2C(A0)
        MOVE.B  D4,D1

VB_REACH
        MOVE.B  D1,$2B(A0)

VB_SAME LSR.B   #1,D4
        SUB.B   D4,D1
        BCC     WARBLE
        SUBI.W  #$100,D1

WARBLE  ADDI.B  #$A0,D5
        BCS     HI_VB

SHIFT_VB
        LSL.W   #1,D1
        ADDI.B  #$18,D5
        BCC     SHIFT_VB

HI_VB   ADD.W   D1,D0

TWIGGLE EORI.B  #1,D7
        MOVE.B  D7,0(A0)
        BTST    #2,D7
        BEQ     TG_FORM
        MOVE.B  $19(A0),D4
        SUBQ.B  #1,D4
        BNE     SL_CNT
        CLR.W   D6
        MOVE.B  $18(A0),D6
        BPL     SL_UP
        ADDI.W  #$FF00,D6

SL_UP   ADD.W   $E(A0),D6
        MOVE.W  D6,$E(A0)
        ADD.W   D6,D0
        BRA     TG_FORM

SL_CNT  MOVE.B  D4,$19(A0)

TG_FORM EORI.B  #$FF,D7
        MOVE.B  REG_7,D3
        ANDI.B  #3,D7
        BNE     SET_7
        MOVE.B  NZ_F,D3
        EORI.B  #8,D3
        MOVE.B  D3,NZ_FT
        MOVE.B  #7,D3

SET_7   MOVE.B  (REGS+7),D2	* SéTTER BRUS KANALER
        EOR.B   D2,D3
        AND.B   $2D(A0),D3
        EOR.B   D3,(REGS+7)
        MOVE.B  $1E(A0),D1	* SéTTER VOLUME
        RTS                             


* LJUDCHIP DATA

REGS    DC.B    0	* Channel A fine tune	
	DC.B	0	* Channel A course tune
	DC.B	0	* Channel B fine tune
	DC.B	0	* Channel B couse tune
	DC.B	0	* Channel C fine tune
	DC.B	0	* Channel C course tune
	DC.B	0	* Noise generator control
	DC.B	$3F	* Mixer control, I/O enable
        DC.B    15	* Channel A amplitude
	DC.B	15	* Channel B amplitude
	DC.B	15	* Channel C amplitude
	DC.B	0	* Envelope period tine tune
	DC.B	0 	* Envelope period course tune
FREGS   DC.B    0	* Envelope shape


* FREKVENS TABELL

NOTE_TAB
        DC.W    $EEE,$E17,$D4D,$C8E
        DC.W    $BD9,$B2F,$A8E,$9F7
        DC.W    $967,$8E0,$861,$7E8
        DC.W    $777,$70B,$6A6,$647
        DC.W    $5EC,$597,$547,$4FB
        DC.W    $4B3,$470,$430,$3F4
        DC.W    $3BB,$385,$353,$323
        DC.W    $2F6,$2CB,$2A3,$27D
        DC.W    $259,$238,$218,$1FA
        DC.W    $1DD,$1C2,$1A9,$191
        DC.W    $17B,$165,$151,$13E
        DC.W    $12C,$11C,$10C,$FD
        DC.W    $EE,$E1,$D4,$C8
        DC.W    $BD,$B2,$A8,$9F
        DC.W    $96,$8E,$86,$7E
        DC.W    $77,$70,$6A,$64
        DC.W    $5E,$59,$54,$4F
        DC.W    $4B,$47,$43,$3F
        DC.W    $3B,$38,$35,$32
        DC.W    $2F,$2C,$2A,$27
        DC.W    $25,$23,$21,$1F
        DC.W    $1D,$1C,$1A,$19
        DC.W    $17,$16,$15,$13
        DC.W    $12,$11,$10,$F


* CHANGE DATA

CH_TAB  DC.L    CH_0,CH_1,CH_2,CH_3
CH_0    DC.B    0,$87
CH_1    DC.B    0,2,7,$87
CH_2    DC.B    0,3,7,$87
CH_3	DC.B	0,5,7,$87

* ENVELOPE DATA

EV_TAB  DC.L    EV_0		* Envelope Channel A
	DC.L	EV_1		* Envelope Channel B
        DC.L    EV_2 		* Envelope Channel C
        DC.L	EV_3		* Envelope Channel C
	DC.B    1
EV_0    DC.B    15,14,13,12,11,10,$87,6
EV_1    DC.B    14,13,12,11,10,9,$87,6
EV_2    DC.B    15,14,13,12,11,10,$87,6
EV_3    DC.B    15,14,13,12,11,10,14
        DC.B    13,9,12,10,8,11,$87,0
EV_4    DC.B    0,$87			* STéNG AV KANAL

MONOFF  DC.B    0,0	* 1 = MELODI Pè, 0 = MELODI AV
TEMPD0  DC.B    0,0    


* MELODI DATA
*	KANAL:	A      B      C	 

STADS   DC.L	TUNEA1,TUNEA2,TUNEA3

TUNEA1	DC.L	A1P1
	DC.L	0

TUNEA2	DC.L	A2P1,A2P1,A2P2,A2P1,A2P3
        DC.L    0

TUNEA3	DC.L	A3P1,A3P1,A3P2,A3P1,A3P3
	DC.L	0

* NOT DATA

A1P1	DC.B	$D0,$C2,$8A
	DC.B	$E3,$8B,$89,20,0
	DC.B	$E3,$8A,$84,15,5,48
	DC.B	$E1,$8C,$89,10,$84,15,5,60
	DC.B	$E5,$8A,$84,15,5,48
	DC.B	$E3,$8C,$89,20,$84,15,5,48
	DC.B	$E1,$8A,$84,15,5,48
	DC.B	$E1,$84,15,5,48
	DC.B	$E3,$8C,$89,10,$84,15,5,60
	DC.B	$E1,$89,20,$84,15,5,48
	DC.B	$E1,$84,15,5,48
	DC.B	$E3,$84,15,5,48
	DC.B	$E1,$8A,$84,15,5,48
	DC.B	$E1,$84,15,5,48
	DC.B	$E3,$8C,$89,10,$84,15,5,60
	DC.B	$E1,$89,20,$84,15,5,48
	DC.B	$E5,$84,15,5,48
	DC.B	$C0,$E0,$84,40,1,$85,$89,10,$8C,70
	DC.B	$E0,$84,40,1,$85,$89,10,$8C,70
	DC.B	$E0,$84,40,1,$85,$89,10,$8C,70
	DC.B	$E0,$84,40,1,$85,$89,10,$8C,70
	DC.B	$E0,$84,40,1,$85,$89,10,$8C,60
	DC.B	$E0,$84,40,1,$85,$89,10,$8C,60
	DC.B	$E0,$84,40,1,$85,$89,10,$8C,60
	DC.B	$E0,$84,40,1,$85,$89,10,$8C,60
	DC.B	$E0,$84,40,1,$85,$89,10,$8C,50
	DC.B	$E0,$84,40,1,$85,$89,10,$8C,50
	DC.B	$E0,$84,40,1,$85,$89,10,$8C,50
	DC.B	$E0,$84,40,1,$85,$89,10,$8C,50
	DC.B	$87

********

A2P1	DC.B	$D1,$C0,$8A
	DC.B	$E3,24,36,24,36,24,36,24,36
	DC.B	20,32,20,32,19,31,19,31
	DC.B	$E3,24,36,24,36,24,36,24,36
	DC.B	20,32,20,32,22,34,22,34
	DC.B	17,29,17,29,17,29,17,29
	DC.B	20,32,20,32,20,32,20,32
	DC.B	19,31,19,31,19,31,19,31
	DC.B	20,32,20,32,22,34,22,34
	DC.B	$87

A2P2	DC.B	24,36,24,36,24,36,24,36
	DC.B	20,32,20,32,22,34,22,34
	DC.B	24,36,24,36,24,36,24,36
	DC.B	20,32,20,32,22,34,22,34
	DC.B	24,36,24,36,24,36,24,36
	DC.B	20,32,20,32,22,34,22,34
	DC.B	24,36,24,36,24,36,24,36
	DC.B	20,32,20,32,22,34,22,34
	DC.B	$87

A2P3	DC.B	17,29,17,29,17,29,17,29
	DC.B	20,32,20,32,20,32,20,32
	DC.B	24,36,24,36,24,36,24,36
	DC.B	24,36,24,36,24,36,24,36
	DC.B	17,29,17,29,17,29,17,29
	DC.B	19,31,19,31,19,31,19,31
	DC.B	$87
********

A3P1	DC.B	$BA,$D2,$C0,$8A,$82,$88,3,2
	DC.B	$E3,$80,48,$E1,46,$E5,48,$E7,51,48,$E3
	DC.B	46,48,48,$E1,46,$E5,$84,2,1,$85,48,$EB,$80
	DC.B	$E3,$80,48,$E1,46,$E5,48,$E7,51,48,$E3
	DC.B	51,53,53,$E1,51,$E5,$84,2,1,$85,55,$EB,$80
	DC.B	$E3,$80,48,$E1,46,$E5,48,$E7,51,48,$E3
	DC.B	46,48,48,$E1,46,$E5,$84,2,1,$85,48,$EB,$80
	DC.B	$E3,$80,48,$E1,46,$E5,48,$E7,51,48,$E3
	DC.B	51,53,53,$E1,51,$E5,$84,2,1,$85,55,$EB,$80
	DC.B	$87

A3P2	DC.B	$C2,$E3,48,48,48,$E1,$C1,48,$C2,48,$EF,$80
	DC.B	$C2,$E3,48,48,48,$E1,$C1,48,48,$EF,$80
	DC.B	$C2,$E3,48,48,48,$E1,$C1,48,$C2,48,$EF,$80
	DC.B	$C2,$E3,48,$C3,48,48,$E1,$C2,48,$C3,48,$EF,$80
	DC.B	$C2,$E3,48,48,48,$E1,$C1,48,$C2,48,$EF,$80
	DC.B	$C2,$E3,48,48,48,$E1,$C1,48,48,$EF,$80
	DC.B	$C2,$E3,48,48,48,$E1,$C1,48,$C2,48,$EF,$80
	DC.B	$C2,$E3,48,$C3,48,48,$E1,$C2,48,$C3,48,$EF,$80
	DC.B	$87

A3P3	DC.B	$C0
	DC.B	$E3,48,46,48,$E7,51
	DC.B	$E3,48,51,53
	DC.B	$E1,53,51,53,55,53,51,48,46
	DC.B	48,51,53,55,53,51,48,51
	DC.B	$EF,60
	DC.B	$84,2,1,$85,60
	DC.B	$80
	DC.B	$80
	DC.B	$E3,48,46,48,$E7,51
	DC.B	$E3,48,51,53
	DC.B	$E1,53,51,53,55,53,51,48,46
	DC.B	48,51,53,55,53,51,48,51
	DC.B	$87