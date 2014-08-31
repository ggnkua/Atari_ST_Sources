; File name:   MAXFLOAT.S         Revised:  1990.10.19
; Creator:     U. R. Andersson    Created:  1990.10.18
; File type:   ASSEMPRO source code
; Purpose:     Numeric analysis package
; Copyright:   Released to public domain by U. R. Andersson
;
;
;         SUBROUTINE LIST:
;
; Note:   In this list (A0) or (A1) refers to an entire MAXFLOAT number
;         which the address register points to. R0 and R1 similarily
;         refer to the numbers in the two main MAXFLOAT registers,
;         actually defined as M_R0 and M_R1.
;         All user locations or registers altered by a routine are
;         shown in this list, but M_INIT also initializes the
;         internal MAXFLOAT parameters, and the math routines are free
;         to thrash the internal registers M_R2 - M_R5 at will.
;
;         The following meta-symbols are used in the list:
; Symbol: Meaning:
; n=>t    Calling the routine "n" causes what's described in "t"
; x==y    States that value of "x" is identical to value of "y"
; x!=y    States that value of "x" differs from value of "y"
; x=y     Assigns the value of "y" to storage area "x"
; x->y    States that value of "x" is address of storage area "y"
;
;----- Program init/reinit
; M_INIT  D0=Mantissa length => D0=limited length  A0->M_R0
;
;----- Number moves
; M_LDR0  => R0=(A0)  \
; M_LDR1  => R1=(A0)   |
; M_STR0  => (A1)=R0   |  After each of these A0->source & A1->dest
; M_STR1  => (A1)=R1    > whether user_supplied or implied by call.
; M_STR0R1=> R1=R0     |  D0=Exponent & signs of the moved number.
; M_STR1R0=> R0=R1     |
; M_MOVE  => (A1)=(A0)/
;
;----- Number swaps
; M_EXR0  => EXG R0,(A1)  \  After each of these A0->primary area &
; M_EXR1  => EXG R1,(A1)   \ A1->secondary area, whether supplied or
; M_EXR0R1=> EXG R0,R1     / implied.  D0=Exponent & signs of the old
; M_EXCH  => EXG (A0),(A1)/  secondary number = new primary number.
;
;----- Number comparisons
; M_CPR0R1=> CCR flags R0-R1    \ These are similar to the above, except
; M_CPR0  => CCR flags R0-(A1)   >that CCR flags primary-secondary arg.
; M_COMP  => CCR flags (A0)-(A1)/ GT,GE,EQ,NE,LE,LT are then valid.
;
;----- Main math                  (but not HI,HS,VS,VC,LS,LO)
; M_CLR   => R0=0 (exp zeroed) \
; M_CLRMAN=> R0=0 (all zeroed)  |
; M_UNIT  => R0=1               |
; M_NEG   => R0=-R0             |
; M_ABS   => R0=abs(R0)         |
; M_TST   => CCR flags N,Z?     |  After all main math routines A0->R0
; M_SUB   => R0=R0-R1            > with any overflow both flagged as VS
; M_ADD   => R0=R0+R1           |  and accumulated into OFLOFLAG (OR'ed)
; M_DIV   => R0=R0/R1           |  D0=sign and exponent of R0 with flags
; M_MUL   => R0=R0*R1           |  N and Z having their usual meaning,
; M_INV   => R0=1/R0            |  unless invalidated by overflow.
; M_POW2  => R0=R0^2            |
; M_POW4  => R0=R0^4            |
; M_POW8  => R0=R0^8            |
; M_ROOT2 => R0=R0^0.5          |
; M_NORM  => R0 normalized     /
;
;----- Hybrid math
; M_I_DIVU=> R0=R0/(unsigned D0)\
; M_I_DIVS=> R0=R0/(signed D0)   |
; M_I_MULU=> R0=R0*(unsigned D0) | These are operations of D0.W on
; M_I_MULS=> R0=R0*(signed D0)    >the main MAXFLOAT register, results
; M_I_POWU=> R0=R0^(unsigned D0) | flagged and handled as above
; M_I_POWS=> R0=R0^(signed D0)  /
; M_L_POWU=> R0=R0^(unsigned long D0) \ These 2 are like the above but
; M_L_POWS=> R0=R0^(signed long D0)   / use D0.L
;
;----- Hybrid conversions
; M_I_CONU=> R0=MAXFLOAT(unsigned word D0)
; M_I_CONS=> R0=MAXFLOAT(signed word D0)
; M_L_CONU=> R0=MAXFLOAT(unsigned long D0)
; M_L_CONS=> R0=MAXFLOAT(signed long D0)
; A_M_DEXP=> D0.L=decimal ascii exponent ('-999' - '+999') unless VS
;   cont...  R0=Reduced so mantissa suits decimal exponent unless VS
;   cont...  A0->R0
; A_M_SIGN=> D0.L=spaced ascii sign(R0) (' +0.' or ' 00.' or ' -0.')
; A_M_DIGS=> D0.L=next 4 ascii digits(R0), R0 reduced *10000, A0->R0
;
;----- Overflow detection
; M_CLROFL=>OFLOFLAG==0, CCR flags VC       \ also => A0->R0
; M_SETOFL=>OFLOFLAG!=0, CCR flags VS        >        D0=R0 exponent
; M_TSTOFL=>CCR flags VS unless OFLOFLAG==0 / but doesn't test them
;
;----- Pure mantissa arithmetic
; M_ADDMAN=>(A0)=(A0)+(A1)   \  These operations affect entire mantissa
; M_ADDXMN=>(A0)=(A0)+(A1)+X  \ but ignore exponents & signs.
; M_SUBMAN=>(A0)=(A0)-(A1)    / CCR is the only CPU reg affected.
; M_SUBXMN=>(A0)=(A0)-(A1)-X /  A0 & A1 ->Numbers (incl ignored exp)
; M_CMPMAN=>CCR flags (A0)-(A1) mantissa only. Doesn't alter data.
; of these 5 all give valid C, but only CMPMAN valid Z & invalid X flags
;
;----- Pure mantissa shifts
; M_ASL   \
; M_LSL    |
; M_ROXL   |
; M_ROL     \ These affect entire mantissa like CPU shifts,
; M_ASR     / except that even ROR & ROL affect X.
; M_LSR    |  A0->Number (incl ignored exp)
; M_ROXR   |  CCR is the only CPU reg affected.
; M_ROR   /   Only X & C flags are reliably valid.
;
;
ZERO      =    0
MAXMLEN   =    1024     ;WORDS = 16384 BIT MANTISSA = 4932 DECIMAL DIGITS
ULTIMAX   =    4095     ;LIMIT = 65520 BIT MANTISSA = 19723 DECIMAL DIGITS
;
;
M_R0      DS.W 3+MAXMLEN          ;Main reg 0 + EXTRA WORD
M_R1      DS.W 2+MAXMLEN          ;Main reg 1 (always preserved)
M_R2      DS.W 2+MAXMLEN      ;Internal reg GENERAL USES
M_R3      DS.W 2+MAXMLEN      ;Internal reg MUL, DIV & higher func's
M_R4      DS.W 2+MAXMLEN      ;Internal reg ROOT2 & powers & higher func's
M_R5      DS.W 2+MAXMLEN      ;Internal reg ROOT2 & powers & higher func's
M_R6      DS.W 2+MAXMLEN      ;Internal reg DEXP
;
;
OFLOFLAG  DC.W ZERO     ;Flag for accumulated errors (cleared by user)
WDMANLEN  DC.W ZERO     ;Mantissa size in words
BYMANLEN  DC.W ZERO     ;Mantissa size in bytes
BIMANLEN  DC.W ZERO     ;Mantissa size in bits
WDMLENM1  DC.W ZERO     ;Mantissa size in words -1
BYMLENM1  DC.W ZERO     ;Mantissa size in bytes -1
BIMLENM1  DC.W ZERO     ;Mantissa size in bits -1
WDMLENPX  DC.W ZERO     ;Number length in words
BYMLENPX  DC.W ZERO     ;Number length in bytes
WDMLPXM1  DC.W ZERO     ;Number length in words -1
BYMLPXM1  DC.W ZERO     ;Number length in bytes -1
ROOTNEED  DC.W ZERO     ;Loop need for precision square roots
;
M_INIT:   ;D0=Mantissa length (words)
; =>      ;D0=limited length  A0->M_R0
  LEA     M_R0,A0
  CMP     #MAXMLEN,D0
  BLS.S   \L1
  MOVE    #MAXMLEN,D0
\L1:
  MOVE    D0,WDMANLEN-M_R0(A0)
  SUBQ    #1,D0
  MOVE    D0,WDMLENM1-M_R0(A0)
  ADDQ    #3,D0
  MOVE    D0,WDMLENPX-M_R0(A0)
  SUBQ    #1,D0
  MOVE    D0,WDMLPXM1-M_R0(A0)
  SUBQ    #1,D0
  ASL     #1,D0
  MOVE    D0,BYMANLEN-M_R0(A0)
  SUBQ    #1,D0
  MOVE    D0,BYMLENM1-M_R0(A0)
  ADDQ    #5,D0
  MOVE    D0,BYMLENPX-M_R0(A0)
  SUBQ    #1,D0
  MOVE    D0,BYMLPXM1-M_R0(A0)
  SUBQ    #3,D0
  ASL     #3,D0
  MOVE    D0,BIMANLEN-M_R0(A0)
  SUBQ    #1,D0
  MOVE    D0,BIMLENM1-M_R0(A0)
  MOVE    WDMANLEN,D0
  MOVEM.L D1,-(SP)
  LEA     ROOTFIXT,A1
  MOVEQ   #2,D1
\L2:
  ADDQ    #2,D1
  CMP     0(A1,D1),D0
  BHI.S   \L2
  LSR     #1,D1
  MOVE    D1,ROOTNEED-M_R0(A0)
  MOVEM.L (SP)+,D1/A1
  RTS
;
;
ROOTFIXT:
  DC.W    ZERO,ZERO,$001,$002     ;0, 0, 16, 32 BITS
  DC.W    $004,$008,$010,$020     ;64, 128, 256, 512 BITS
  DC.W    $040,$080,$100,$200     ;1024, 2048, 4096, 8192 BITS
  DC.W    $400,$800,$FFF          ;16384, 32768, 65520 BITS
;
;
M_LDR0:
  LEA     M_R0,A1
  BRA.S   M_MOVE
;
M_LDR1:
  LEA     M_R1,A1
  BRA.S   M_MOVE
;
M_STR0R1:
  LEA     M_R1,A1
M_STR0:
  LEA     M_R0,A0
  BRA.S   M_MOVE
;
M_STR1R0:
  LEA     M_R0,A1
M_STR1:
  LEA     M_R1,A0
M_MOVE:
  MOVE.L  A0,D0
  BTST    #0,D0
  BNE.S   \L2
  MOVE.L  A1,D0
  BTST    #0,D0
  BNE.S   \L2
  ADDA    BYMLENPX,A0
  ADDA    BYMLENPX,A1
  MOVE    WDMLPXM1,D0
\L1:
  MOVE    -(A0),-(A1)
  DBRA    D0,\L1
  MOVE.L  (A0),D0
\L2:
  RTS
;
;
EXR0R1:
  LEA     M_R1,A1
M_EXR0:
  LEA     M_R0,A0
  BRA.S   M_EXCH
;
M_EXR1:
  LEA     M_R1,A0
M_EXCH:
  MOVE.L  A0,D0
  BTST    #0,D0
  BNE.S   \L2
  MOVE.L  A1,D0
  BTST    #0,D0
  BNE.S   \L2
  ADDA    BYMLENPX,A0
  ADDA    BYMLENPX,A1
  MOVE    D1,-(SP)
  MOVE    WDMLPXM1,D1
\L1:
  MOVE    -(A1),D0
  MOVE    -(A0),(A1)
  MOVE    D0,(A0)
  DBRA    D1,\L1
  MOVE    (SP)+,D1
  TST     D0
\L2:
  RTS
;
;
M_POPCLR:
  MOVEM.L (SP)+,D1-D3/A1
M_CLR:
  LEA     M_R0,A0
  CLR     D0
  CLR     (A0)
  RTS
;
;
M_CLRMAN:
  LEA     M_R0,A0
  ADDA    BYMLENPX,A0
  MOVE    WDMLPXM1,D0
\L1:
  CLR     -(A0)
  DBRA    D0,\L1
  CLR     D0
  RTS
;
;
M_UNIT:
  BSR     M_CLRMAN
  MOVE    #$8000,4(A0)
  MOVE.L  #$40000001,D0
  MOVE.L  D0,(A0)
  RTS
;
;
M_NEG:
  LEA     M_R0,A0
  MOVE.L  (A0),D0
  BEQ.S   \L1
  BCHG    #31,D0
  MOVE.L  D0,(A0)
\L1:
  RTS
;
;
M_ABS:
  LEA     M_R0,A0
  BCLR    #7,(A0)
M_TST:
  LEA     M_R0,A0
  MOVE.L  (A0),D0
  RTS
;
;
M_SUB:
  MOVEM.L D1-D3/A1,-(SP)
  LEA     M_R2,A1
  BSR     M_STR1
  MOVE.L  (A1),D0
  BEQ.S   \L1
  BCHG    #31,D0
  MOVE.L  D0,(A1)
\L1:
  BRA.S   ADDSUB1
;
M_ADD:
  MOVEM.L D1-D3/A1,-(SP)
  LEA     M_R2,A1
  BSR     M_STR1
ADDSUB1:
  LEA     M_R0,A0
  MOVE.L  (A0),D0
  MOVE.L  (A1),D1
  MOVE.L  D0,D2
  MOVE.L  D1,D3
  BCLR    #31,D2
  BCLR    #31,D3
  SUB.L   D2,D3
  MOVE.L  D0,D2
  EOR.L   D1,D2
  TST.L   D3
  BLT.S   ADDSUB4
  BEQ.S   ADDSUB3
ADDSUB2:
  LEA     M_R0,A0
  LEA     M_R2,A1
  BSR     M_EXCH
  BRA.S   ADDSUB1
;
ADDSUB3:
  ADDQ    #4,A0
  ADDQ    #4,A1
  MOVE    WDMLENM1,D1
\L1:
  CMPM    (A0)+,(A1)+
  BHI.S   ADDSUB2
  DBLO    D1,\L1
  LEA     M_R0,A0
  LEA     M_R2,A1
ADDSUB4:  ;Here R2 needs alignment by -D3 steps
  NEG.L   D3
  BEQ.S   ADDSUB5
  CMP.L   BIMANLEN,D3
  BHI     ADDSUBOK
  TST.L   (A1)
  BEQ     ADDSUBOK
  EXG     A0,A1
\L1:
  BSR     M_LSR
  DBRA    D3,\L1
  EXG     A0,A1
ADDSUB5:  ;Here R0 & R2 are aligned, with R2 having the lowest magnitude
  TST.L   D2            ;Signs identical ?
  BMI.S   ADDSUB6
  BSR     M_ADDXMN      ;adds rounded R2 to R0 with non_zero sum
  BCC.S   ADDSUBOK      ;if CC then old normalization still valid
  BSR     M_ROXR        ;else single shift will fix it
  ADDQ.L  #1,D0         ;but needs exponent fix too
  MOVE.L  D0,(A0)
  BVS     M_POPOFL      ;with possible overflow
  BCS     M_POPOFL      ;for values > 10^323228496 !!!
  CLR.L   (A0)
ADDSUBOK:
  MOVE.L  (A0),D0
  MOVEM.L (SP)+,D1-D3/A1
  RTS
;
ADDSUB6:
  BSR     M_SUBXMN      ;subtracts R2 from R0 with positive result
  MOVE.L  D0,(A0)
  MOVEM.L (SP)+,D1-D3/A1
M_NORM:
  LEA     M_R0,A0
  TST.B   4(A0)
  BMI.S   \L2
  MOVE    BIMLENM1,D0
\L1:
  BSR     M_LSL
  TST.B   4(A0)
  DBMI    D0,\L1
  BPL     M_CLR
  NEG     D0
  ADD     BIMANLEN,D0
  EXT.L   D0
  SUB.L   D0,(A0)
  BVS     M_CLR
  BCS     M_CLR
\L2:
  MOVE.L  (A0),D0
  RTS
;
;
M_INV:
  MOVEM.L D1-D3/A1,-(SP)
  LEA     M_R2,A1
  BSR     M_STR0
  BSR     M_UNIT
  BRA.S   DIVIDE1
;
M_DIV:
  MOVEM.L D1-D3/A1,-(SP)
  LEA     M_R2,A1
  BSR     M_STR1
DIVIDE1:
  LEA     M_R0,A0
  MOVE.L  (A0),D0
  BEQ     DIVIDEOK
  MOVE.L  (A1),D1
  BEQ     M_POPOFL
  MOVE.L  D0,D2
  EOR.L   D1,D2
  ASL.L   #1,D0
  ASL.L   #1,D1
  BCHG    #31,D0
  BCHG    #31,D1
  SUB.L   D1,D0
  BVS     M_EXPOFL
  ADDQ.L  #2,D0
  BVS     M_POPOFL
  BCHG    #31,D0
  ASL.L   #1,D2
  ROXR.L  #1,D0
  MOVE.L  D0,(A0)
  LEA     M_R3,A1
  BSR     M_STR0
  LEA     M_R3,A0
  LEA     M_R2,A1
  MOVE    BIMLENM1,D3
DIVIDELP:
  BCS.S   \L3
  ADDQ    #4,A0
  ADDQ    #4,A1
  MOVE    WDMLENM1,D2
\L1:
  CMPM    (A0)+,(A1)+
  DBNE    D2,\L1
  LEA     M_R2,A1
  BLO.S   \L2
  MOVEQ   #-1,D2
  ADD     D2,D2
  BRA.S   \L3
;
\L2:
  ADD     #ZERO,D2
\L3:
  SCS     D2
  LEA     M_R0,A0
  BSR     M_ROXL
  LEA     M_R3,A0
  TST.B   D2
  BEQ.S   \L4
  BSR     M_SUBMAN
\L4:
  BSR     M_ASL
  DBRA    D3,DIVIDELP
  LEA     M_R0,A0
  TST.B   4(A0)
  BPL.S   DIVIDEFX
DIVIDEOK:
  MOVEM.L (SP)+,D1-D3/A1
  TST.L   D0
  RTS
;
DIVIDEFX:
  SCS     D2
  SUBQ.L  #1,D0
  BCS     M_POPCLR
  BVS     M_POPCLR
  MOVE.L  D0,(A0)
  LEA     M_R3,A0
  CLR     D3
  ASL.B   #1,D2
  BRA.S   DIVIDELP
;
;
M_POW8:
  BSR     M_POW2
M_POW4:
  BSR     M_POW2
M_POW2:
  MOVEM.L D1-D3/A1,-(SP)
  LEA     M_R2,A1
  BSR     M_STR1
  BRA.S   MULPLY1
;
M_MUL:
  MOVEM.L D1-D3/A1,-(SP)
  LEA     M_R2,A1
  BSR     M_STR1
MULPLY1:
  LEA     M_R0,A0
  MOVE.L  (A0),D0
  BEQ.S   MULPLYOK
  MOVE.L  (A1),D1
  BEQ     M_POPOFL
  MOVE.L  D0,D2
  EOR.L   D1,D2
  ASL.L   #1,D0
  ASL.L   #1,D1
  BCHG    #31,D0
  BCHG    #31,D1
  ADD.L   D1,D0
  BVS     M_EXPOFL
  BCHG    #31,D0
  ASL.L   #1,D2
  ROXR.L  #1,D0
  MOVE.L  D0,(A0)
  LEA     M_R3,A1
  BSR     M_STR0
  BSR     M_CLRMAN
  MOVE.L  (A1),D0
  MOVE.L  D0,(A0)
  LEA     M_R2,A1
  MOVE    BIMLENM1,D3
MULPLYLP:
  LEA     M_R3,A0
  BSR     M_ROXR
  BCC     \L1
  LEA     M_R0,A0
  BSR     M_ADDMAN
\L1:
  BSR     M_ROXR
  DBRA    D3,MULPLYLP
  TST.B   4(A0)
  BMI.S   MULPLYOK
  BSR     M_ROXL
  SUBQ.L  #1,D0
  BVS     M_POPCLR
  BCS     M_POPCLR
MULPLYOK:
  MOVEM.L (SP)+,D1-D3/A1
  TST.L   D0
  RTS
;
;
M_ROOT2:
  MOVE.L  M_R0,D0
  BGT     ROOTER1
  BMI     M_SETOFL
  RTS
;
ROOTER1:
  MOVEM.L D1-D3/A1,-(SP)
  LEA     M_R5,A1
  BSR     M_STR1
  LEA     M_R4,A1
  BSR     M_STR0
  SUB.L   #$40000000,D0
  ASR.L   #1,D0
  SCS     D2
  ADD.L   #$40000000,D0
  MOVE.L  D0,(A0)
  BSR     M_STR0R1
  BSR     M_UNIT
  MOVE.L  (A1),D0
  MOVE.L  D0,(A0)
  SUBQ.L  #1,D0
  TST.B   D2
  BEQ.S   ROOTER2
  BTST    #6,(A0)
  BNE     ROOTER3
  MOVE.L  D0,(A0)
ROOTER2:
  MOVE.L  D0,(A1)
ROOTER3:
  BSR     M_ADD
  MOVE    ROOTNEED,D2
ROOTERLP:
  BSR     M_STR0R1
  LEA     M_R4,A0
  BSR     M_LDR0
  BSR     M_DIV
  BSR     M_ADD
  SUBQ.L  #1,D0
  MOVE.L  D0,(A0)
  DBRA    D2,ROOTERLP
ROOTEROK:
  LEA     M_R5,A0
  BSR     M_LDR1
  LEA     M_R0,A0
  MOVE.L  (A0),D0
  MOVEM.L (SP)+,D1-D3/A1
  RTS
;
;
M_I_CONS:
  EXT.L   D0
M_L_CONS:
  TST.L   D0
  BPL.S   M_L_CONU
  NEG.L   D0
  BSR.S   M_L_CONU
  BSET    #31,D0
  MOVE.L  D0,(A0)
  RTS
;
M_I_CONU:
  AND.L   #$FFFF,D0
M_L_CONU:
  TST.L   D0
  BEQ     M_CLR
  MOVE    D1,-(SP)
  MOVE.L  D0,D1
  BSR     M_UNIT
  MOVE    #$20,D0
  TST.L   D1
  BMI.S   \L2
  SUBQ    #1,D0
\L1:
  ASL.L   #1,D1
  DBMI    D0,\L1
\L2:
  MOVE.L  D1,4(A0)
  MOVE.L  D0,(A0)
  MOVEM   (SP)+,D1
  RTS
;
;
M_I_DIVS:
  TST     D0
  BPL.S   M_I_DIVU
  BSR.S   M_I_DIVU
  BVS     M_SETOFL
  BRA     M_NEG
;
M_I_DIVU:
  TST     D0
  BEQ     M_SETOFL
  MOVEM.L D1-D3/A1,-(SP)
  LEA     M_R0,A0
  MOVE    D0,D1
  MOVE.L  (A0)+,D0
  BEQ     M_POPCLR
  MOVE    WDMLENM1,D2
  CLR.L   D0
MIDIVLP:
  MOVE.W  (A0),D0
  DIVU    D1,D0
  MOVE.W  D0,(A0)+
  DBRA    D2,MIDIVLP
  LEA     M_R0,A0
  MOVE.L  D0,D1
MIMULDIV:
  MOVE.L  (A0),D0
  TST.B   4(A0)
  BMI.S   MIDIVOK
  MOVE    #16-1,D2
MIDIVLP2:
  SUBQ.L  #1,D0
  BVS     M_POPCLR
  BCS     M_POPCLR
  ASL.L   #1,D1
  BSR     M_ROXL
  TST.B   4(A0)
  DBMI    D2,MIDIVLP2
MIDIVOK:
  MOVE.L  D0,(A0)
  MOVEM.L (SP)+,D1-D3/A1
  RTS
;
;
M_I_MULS:
  TST     D0
  BPL.S   M_I_MULU
  BSR.S   M_I_MULU
  BVS     M_SETOFL
  BRA     M_NEG
;
M_I_MULU:
  TST     D0
  BEQ     M_CLR
  MOVEM.L D1-D3/A1,-(SP)
  LEA     M_R0,A0
  MOVE    D0,D1
  MOVE.L  (A0)+,D0
  BEQ     M_POPCLR
  ADDA    WDMANLEN,A0
  MOVE    WDMLENM1,D2
  CLR.L   D3
MIMUL_LP:
  MOVE    -(A0),D0
  MULU    D1,D0
  ADD.L   D3,D0
  MOVE    D0,4(A0)
  SWAP    D0
  MOVE    D0,D3
  DBRA    D2,MIMUL_LP
  MOVE    D3,2(A0)
  LEA     M_R0,A0
  MOVE    WDMLENPX,D1
  MOVE    (A0,D1),D1
  SWAP    D1
  BRA.S   MIMULDIV
;
;
M_I_POWS:
  EXT.L   D0
M_L_POWS:
  TST.L   D0
  BPL.S   M_L_POWU
  NEG.L   D0
  BSR.S   M_L_POWU
  BVS     M_SETOFL
  BRA     M_INV
;
M_I_POWU:
  AND.L   #$FFFF,D0
M_L_POWU:
  TST.L   D0
  BEQ     M_UNIT
  MOVEM.L D1-D3/A1,-(SP)
  MOVE.L  D0,D1
  LEA     M_R5,A1
  BSR     M_STR1
  LEA     M_R4,A1
  BSR     M_STR0
  BSR     M_UNIT
  BRA.S   MLPOWLPE
;
MLPOWLP1:
  LEA     M_R4,A1
  BSR     M_EXR0
  BSR     M_POW2
  BVS.S   MLPOWOFL
  LEA     M_R4,A1
  BSR     M_EXR0
MLPOWLPE:
  LSR.L   #1,D1
  BCC.S   MLPOWLP1
  LEA     M_R4,A0
  BSR     M_LDR1
  MOVE.L  A0,A1
  BSR     M_STR0
  BSR     M_MUL
  BVS.S   MLPOWOFL
  TST.L   D1
  BNE.S   MLPOWLP1
MLPOWOK:
  LEA     M_R5,A0
  BSR     M_LDR1
  LEA     M_R0,A1
  MOVE.L  (A0),D0
  MOVEM.L (SP)+,D1-D3/A1
  RTS
;
;
MLPOWOFL:
  LEA     M_R5,A0
  BSR     M_LDR1
  BRA     M_POPOFL
;
;
A_M_DEXP: ;D0.L=Ascii sign and digits of decimal exponent unless VS
  MOVEM.L D1-D3/A1,-(SP)
  LEA     M_R0,A0
  MOVE.L  (A0),D0
  BCLR    #31,D0
  SUB.L   #$40000000,D0
  CMP.L   #3322,D0      ;D0 > 4+int(log2(10^(+999))) ?
  BGT     M_POPOFL      ;means: value certainly too large
  BPL.S   AM_DEXP2
  NEG.L   D0
  CMP.L   #3322,D0      ;D0 < 4+int(log2(10^(+999))) ?
  BLO.S   AM_DEXP2      ;means: value maybe not too small
AM_DEXP1:
  BSR     M_CLR
  MOVE.L  #'0000',D0
  BRA     AM_DEXPD
;
;
AM_DEXP2:
  MULU    #30103,D0     ;D0*=LOG10(2)*100000 WITH 7.8-DIGIT ACCURACY
  DIVU    #1000,D0
  DIVU    #100,D0       ;D0=LOG10(2)*BINARY_EXP = APPX DECIMAL EXP
  MOVE    D0,D1
  LEA     M_R6,A1
  BSR     M_STR1
  BSR     M_STR0R1
  BSR     M_CLR
  MOVE.L  #$40000004,(A0)         ;Exponent of 10
  MOVE.B  #$A0,4(A0)              ;Mantissa of 10
  MOVE    D1,D0
  BSR     M_I_POWU      ;R0 = 10 ^ APPX DECIMAL EXP
  MOVE.B  (A0),D0
  NEG     D1            ;Assume negative exponent
  BTST    #6,D0         ;Original R0 >=1  or <1 ?
  BEQ.S   AM_DEXP3      ;If <1 go multiply by power of 10
  BSR     M_INV         ;else multiply by inverted power
  NEG     D1            ;and negate d1 to be positive
AM_DEXP3:
  BSR     M_MUL
  LEA     4+M_R1,A1
  MOVE    WDMLENM1,D2
AM_DEXP4:
  CLR.W   (A1)+
  DBRA    D2,AM_DEXP4   ;Loop to clear R1
  LEA     M_R1,A1
  MOVE.L  #$40000004,(A1)
  MOVE.B  #$A0,(A1)     ;Here R1=10
AM_DEXP5:
  BTST    #30,D0        ;RESULT < 1 ?
  BNE.S   AM_DEXP6      ;then don't lower it further
  ADDQ    #1,D1         ;else raise decimal power
  BSR     M_DIV         ;and divide R0 by 10
  BRA.S   AM_DEXP5      ;Repeat until low enough
;
AM_DEXP6: ;Here R0<1 with D1.W=decimal power but still needing checks
  CMP     #-3,D0        ;Exponent legal (-3 - 0) ?
  BGE.S   AM_DEXP8      ;If legal, don't raise it here
AM_DEXP7:
  SUBQ    #1,D1         ;Lower decimal power
  BSR     M_MUL         ;and multiply R0 by 10
  BRA.S   AM_DEXP6      ;Repeat until high enough
;
AM_DEXP8: ;Here R0 is within legal range unless 1 <= 16*R0 < 1.6
  BGT.S   AM_DEXPA      ;If exponent > -3, R0 > 1/8 and so legal
  MOVE    #$CCCC,D3     ;else compare mantissa to 1/10
  ADDQ    #4,A0
  MOVE    WDMLENM1,D2
AM_DEXP9:
  CMP     (A0)+,D3
  DBNE    D2,AM_DEXP9   ;Loop until different or all done
  BHS.S   AM_DEXP7      ;If R0<=0.1 go make final correction
AM_DEXPA: ;Here 0.1 <= abs(R0) < 1, with D1 = decimal exponent
  CMP     #999,D1
  BGT.S   AMDEXOFL
  CMP     #-999,D1
  BGE.S   AM_DEXPB
  BSR     M_CLR
  CLR     D1
AM_DEXPB:
  MOVE.L  #'0000',D2
  MOVE    D1,D0
  BEQ.S   AM_DEXPC
  MOVE.L  #'+000',D2
  TST     D0
  BPL.S   AM_DEXPC
  NEG     D0
  MOVE.L  #'-000',D2
AM_DEXPC:
  DIVU    #10,D0
  SWAP    D0
  OR      D0,D2
  CLR     D0
  SWAP    D0
  DIVU    #10,D0
  SWAP    D0
  LSL     #8,D0
  OR.L    D2,D0
  LEA     M_R6,A0
  BSR     M_LDR1
AM_DEXPD:
  LEA     M_R0,A0
  TST.L   D0
  MOVEM.L (SP)+,D1-D3/A1
  RTS
;
AMDEXOFL:
  LEA     M_R6,A0
  BSR     M_LDR1
  BRA     M_POPOFL
;
;
;
A_M_SIGN: ;D0.L=spaced ascii sign(R0) (' -0.' or '  0.' or ' +0.')
  MOVE.L  M_R0,D0
  BEQ.S   \L1
  BPL     \L2
  MOVE.L  #' -0.',D0
  RTS
;
\L1:
  MOVE.L  #' 00.',D0
  RTS
;
\L2:
  MOVE.L  #' +0.',D0
  RTS
;
;
A_M_DIGS:
;PATCH
  RTS
;
;
M_CLROFL:
  LEA     M_R0,A0
  SF      OFLOFLAG-M_R0(A0)
  MOVE.L  (A0),D0       ;GET VALUE AND SET VC
  RTS
;
M_EXPOFL:
  BPL     M_POPCLR
M_POPOFL:
  MOVEM.L (SP)+,D1-D3/A1
M_SETOFL:
  LEA     M_R0,A0
  ST      OFLOFLAG-M_R0(A0)
M_TSTOFL:
  LEA     M_R0,A0
  TST.B   OFLOFLAG-M_R0(A0)       ;SET VC
  BEQ.S   \L1
  MOVEQ   #$7F,D0
  ADD.B   D0,D0         ;SET VS
\L1:
  MOVEM.L (A0),D0       ;GET VALUE BUT KEEP VC/VS
  RTS
;
;
M_ADDMAN:
  ADD     #0,D2
M_ADDXMN:
  MOVEM.L D2/A0/A1,-(SP)
  ADDA    BYMLENPX,A0
  ADDA    BYMLENPX,A1
  MOVE    WDMLENM1,D2
\L1:
  ADDX    -(A1),-(A0)
  DBRA    D2,\L1
  MOVEM.L (SP)+,D2/A0/A1
  RTS
;
;
M_SUBMAN:
  ADD     #0,D2
M_SUBXMN:
  MOVEM.L D2/A0/A1,-(SP)
  ADDA    BYMLENPX,A0
  ADDA    BYMLENPX,A1
  MOVE    WDMLENM1,D2
\L1:
  SUBX    -(A1),-(A0)
  DBRA    D2,\L1
  MOVEM.L (SP)+,D2/A0/A1
  RTS
;
;
M_CPR0R1:
  LEA     M_R1,A1
M_CPR0:
  LEA     M_R0,A0
M_COMP:
  MOVEM.L D2/A0/A1,-(SP)
  MOVE.L  (A0),D0
  MOVE.L  (A1),D2
  BEQ.S   SIMPCOMP
  TST.L   D0
  BMI.S   COMPNEG
  CMP.L   D2,D0
  BNE.S   CMPMAN1
  MOVEM.L (SP)+,D2/A0/A1
  RTS
;
COMPNEG:
  TST.L   D2
  BMI.S   COMPNGNG
SIMPCOMP:
  CMP.L   D2,D0
  MOVEM.L (SP)+,D2/A0/A1
  RTS
;
COMPNGNG:
  CMP.L   D1,D2
  BNE.S   COMPNGOK
  ADDQ    #4,A0
  ADDQ    #4,A1
  MOVE    WDMLENM1,D2
\L1:
  CMPM    (A0)+,(A1)+
  DBNE    D2,\L1
COMPNGOK:
  MOVEM.L (SP)+,D2/A0/A1
  RTS
;
M_CMPMAN:
  MOVEM.L D2/A0/A1,-(SP)
CMPMAN1:
  ADDQ    #4,A0
  ADDQ    #4,A1
  MOVE    WDMLENM1,D2
\L1:
  CMPM    (A1)+,(A0)+
  DBNE    D2,\L1
  MOVEM.L (SP)+,D2/A0/A1
  RTS
;
;
M_ASL:
M_LSL:
  ADD     #ZERO,D2
M_ROXL:
  MOVEM.L D2/A0,-(SP)
  ADDA    BYMLENPX,A0
  MOVE    WDMLENM1,D2
\L1:
  ROXL    -(A0)
  DBRA    D2,\L1
  MOVEM.L (SP)+,D2/A0
  RTS
;
;
M_ROL:
  MOVEM.L D2/A0,-(SP)
  ADDA    BYMLENPX,A0
  MOVE    WDMLENM1,D2
  ADD     #ZERO,D2
\L1:
  ROXL    -(A0)
  DBRA    D2,\L1
  CLR     D2
  ROXL.B  #1,D2
  ADDA    BYMLENM1,A0
  OR.B    D2,(A0)
  ROXR.B  #1,D2
  MOVEM.L (SP)+,D2/A0
  RTS
;
;
M_ASR:
  MOVE    D2,-(SP)
  MOVE.B  4(A0),D2
  LSL.B   #1,D2
  MOVE    (SP)+,D2
  BRA.S   M_ROXR
;
M_LSR:
  ADD     #ZERO,D2
M_ROXR:
  MOVEM.L D2/A0,-(SP)
  ADDA    #4,A0
  MOVE    WDMLENM1,D2
\L1:
  ROXR    (A0)+
  DBRA    D2,\L1
  MOVEM.L (SP)+,D2/A0
  RTS
;
;
M_ROR:
  MOVEM.L D2/A0,-(SP)
  ADDA    #4,A0
  MOVE    WDMLENM1,D2
  ADD     #ZERO,D2
\L1:
  ROXR    (A0)+
  DBRA    D2,\L1
  CLR     D2
  ROXR.B  #1,D2
  SUBA    BYMLENM1,A0
  OR.B    D2,(A0)
  ROXL.B  #1,D2
  MOVEM.L (SP)+,D2/A0
  RTS
;
;
S_FLOAT:
  MOVEQ   #$60,D1
  TST.L   D0
  BEQ     \FLOAT_EX
  BPL     \FLOAT_LP
  NEG.L   D0
  BSET    #7,D1
\FLOAT_LP:
  SUBQ.B  #1,D1
  ASL.L   #1,D0
  BVC.S   \FLOAT_LP
  MOVE.B  D1,D0
\FLOAT_EX:
  RTS
;
;
  END     ;OF  MAXFLOAT.S

 