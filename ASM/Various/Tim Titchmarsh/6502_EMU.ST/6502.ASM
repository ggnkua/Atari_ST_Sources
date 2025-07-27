   TTL 6502 EMULATOR BY TIM TITCHMARSH V1.0

*********************************************************
*
*               6502 EMULATOR BY TIM TITCHMARSH
*
*                       JUNE 1987
*
*  HOPEFULLY IT WILL EMULATE ALL OF THE 6502 INSTRUCTIONS
*  AND AT A LATER DATE ALSO THE `NEWER` ADDITIONS
*
*
*
*
*     6502 FLAGS
*
*
*     FLAG     BIT
*
*     C        0
*     Z        1
*     I        2
*     D        3
*     B        4
*
*     V        6
*     N        7
*
*
*
*
*
*     68000 REGISTER USAGE AND NAMES USED
*
*
*
*     D0
*     D1    {TEMP}
*     D2    {CONDITION CODES} FLAGS
*     D3    {REGISTER A}      A
*     D4    {REGISTER X}      X
*     D5    {REGISTER Y}      Y
*     D6    {TEMP}
*     D7    {TEMP}


*     A0
*     A1
*     A2
*     A3    {TABLE OF FLAGS}
*     A4    {PROGRAM COUNTER} PRC   (CANT USE PC AS USED BY SYSTEM)
*     A5    {64K PAGE OFFSET} OFF
*     A6    {STACK POINTER}   STK   (CANT USE SP AS USED BY SYSTEM)
*     A7

 PAGE


*  DEFINE 6502 FLAG BIT POSITION  EQUATES

CB EQU 0
ZB EQU 1
IB EQU 2
DB EQU 3
BB EQU 4
VB EQU 6
NB EQU 7




*  DEFINE 6502 FLAG EQUATES

C EQU 1
V EQU 64
Z EQU 2
N EQU 128

* DEFINE 68000 X FLAG
XX EQU 16   ;CANT USE X AGAIN AS ALREADY DEFINED




* REDEFINE 6800 REGISTER SO THEY LOOK LIKE 6502 ONES

FLAGS EQUR D2      ;CCR FOR 6502
A EQUR D3          ;6502 REG A
X EQUR D4          ;6502 REG X
Y EQUR D5          ;6502 REG Y


PRC EQUR A4   ; PROGRAM COUNTER
OFF EQUR A5 ;GIVES A 64K PAGE OFFSET VALUE
STK EQUR A6    ;USED AS 6502 SP (LSB ONLY FOR 6502)






*  OK SO LETS DEFINE SOME USEFUL MACROS

*  SETFLAGS WILL UTILISE THE 68000 FLAGS SET BY THE INTRUCTION
*  PRECEDING IT AND WILL MODIFY THE 6502 FLAGS REGISTER (D2)
*  TO EMULATE THE CORRECT OPERATION. AS MOST OF THE 6502
*  INSTRUCTIONS EFFECT THE FLAGS IN A SIMILAR MANNER TO THE 68000
*  THIS ISNT TO BAD A JOB TO PERFORM, IT WORKS FOR MOST OF THE
*  INSTRUCTIONS.

SETFLAGS   MACRO
   MOVE SR,D1    ;ONLY INTERESTED IN THE CCR PART(PRIVILIGED ON THE 68010)
   ANDI.W #\1>>4+\2<<1+\3>>5+\4,D1    ;MASK IN N,Z,V,C EFFECTED FLAGS ONLY
   ANDI.B #255-(\1+\2+\3+\4),FLAGS   ;CLEAR FLAGS EFFECTED BY INSTRUCTION
   OR.B 0(A3,D1.W),FLAGS  ;OR IN FLAG CHANGES (VALUES TAKEN FROM FLAGTABLE)
   ENDM
                   




*  MACRO TEST1 WILL CHECK TO SEE IF CARRY IS SET OR NOT AS THERE IS NO
*  ADC OR SBC INSTRUCTION ON THE 6800 AND WILL ADD 1 TO COMPENSATE
*  IT WILL ALSO CHECK TO SEE IF WE ARE IN DECIMAL MODE AND IF SO WILL
*  CARRY OUT ABCD INSTRUCTIONS

TEST1   MACRO
   MOVE.W #%00000100,D0     ;SET Z FLAG POSITION IN D0
   BTST #CB,FLAGS
   BEQ.S 3$         ;NO CARRY TO ADD
   MOVE.W #%00010100,D0     ;68000 EXTEND BIT PLUS SET ZERO BIT
3$ BTST #DB,FLAGS
   BNE.S 2$       ;IN DECIMAL MODE
   ENDM


*  SAME AS ABOVE BUT FOR SBC OPCODES WHERE WE SUB THE CARRY INSTEAD
*  OF ADDING IT

TEST2   MACRO
   MOVE.W #%00010100,D0  ;XBIT PLUS ZERO BIT SET
   BTST #CB,FLAGS
   BEQ.S 3$
   MOVE.W #%00000100,D0    ;ONLY SET ZERO READY FOR ADDX
3$ BTST #DB,FLAGS
   BNE.S 2$       ;IN DECIMAL MODE
   ENDM


* THE FOLLOWING MACROS CREATE THE ADDRESSING MODES USED BY THE 6502
* WHERE ITS WORTH THE EFFORT TO DO SO.
* D6 OR D7 ARE USED TO POINT TO THE MEMORY LOCATION WE ARE INTERESTED IN
* WHICH WE ACCESS BY ADDING IN THE VALUE 'OFF' WHICH IS IN FACT
* ADDRESS 0 AS REGUARDS THE 6502


ZEROPAGE MACRO
   CLR.L D6
   MOVE.B 1(PRC,OFF.L),D6     ;PICK UP ZEROPAGE OFFSET
   ENDM

ZEROPAGEX MACRO
   ZEROPAGE       ; ZEROPAGE OFFSET
   ADD.B X,D6     ;ADD IN X OFFSET
   ENDM

ABS MACRO
   CLR.L D6
   MOVE.B 2(PRC,OFF.L),D6  ;PICK UP MSB OF ADDRESS
   ASL.W #8,D6       ;MOVE INTO MSB POSITION
   MOVE.B 1(PRC,OFF.L),D6  ;PICK UP LSB OF ADDRESS
   ENDM

ABSX MACRO
   ABS       ;ABSOLUTE ADDRESS
   ADD.W X,D6     ;ADD IN X OFFSET
   ENDM

ABSY MACRO
   ABS       ;ABSOLUTE ADDRESS
   ADD.W Y,D6     ;ADD IN Y OFFSET
   ENDM

INDIRECTX MACRO
   CLR.L D7
   ZEROPAGEX      ;PICK UP ZEROPAGE + X OFFSET IN D6
   MOVE.B 1(OFF,D6.L),D7   ;PICK UP MSB OF ADDRESS
   ASL.W #8,D7             ;MOVE UP TO MSB POSITION
   MOVE.B 0(OFF,D6.L),D7   ;PICK UP LSB OF ADDRESS
   ENDM

INDIRECTY MACRO
   CLR.L D7
   ZEROPAGE       ;PICK UP ZEROPAGE OFFSET IN D6
   MOVE.B 1(OFF,D6.L),D7   ;PICK UP MSB OF ADDRESS
   ASL.W #8,D7             ;MOVE INTO MSB POSITION
   MOVE.B 0(OFF,D6.L),D7   ;PICK UP LSB OF ADDRESS
   ADD.W Y,D7              ;ADD IN Y OFFSET
   ENDM


* THIS NEXT MACRO ADDS THE APPROPRIATE AMOUNT TO THE 6502 PC
* AND THEN DOES A RTS

RET MACRO
   ADDQ.W #\1,PRC    ;ADD IN THE ARGUMENT TO THE 6502 PC
   RTS
   ENDM

* THIS ONE SAVES TYPING SOME OF THE ASL CODE

ASL_ MACRO
   MOVE.B 0(OFF,D6.L),D7   ;BYTE TO BE SHIFTED AS CANT SHIFT BYTE IN MEMORY
   ASL.B #1,D7             ;SHIFT IT
   SETFLAGS N,Z,0,C
   MOVE.B D7,0(OFF,D6.L)   ;PUT SHIFTED BYTE INTO MEMORY (AFTER FLAG CHANGES)
   ENDM

* THIS ONE SAVES TYPING SOME OF THE LSR CODE

LSR_ MACRO
   MOVE.B 0(OFF,D6.L),D7   ;BYTE TO BE SHIFTED AS CANT SHIFT BYTE IN MEMORY
   LSR.B #1,D7             ;SHIFT IT
   SETFLAGS N,Z,0,C
   MOVE.B D7,0(OFF,D6.L)   ;PUT SHIFTED BYTE INTO MEMORY (AFTER FLAG CHANGES)
   ENDM

* BRANCH MACROS, ONLY THE CONDITION CHANGES SO MAKE THEM PARAMETERS


BRANCH MACRO
   ADDQ.W #2,PRC        ;UPDATE PC TO POINT TO NEXT INSTRUCTION
   BTST #\1,FLAGS       ;CHECK RELEVANT BIT
   \2.S 1$              ;WILL BE BEQ  OR BNE
   CLR.L D6
   MOVE.B -1(PRC,OFF.L),D6    ;PICK UP BRANCH OFFSET
   EXT.W D6             ;EXTEND TO GIVE FWD AND BACKWARD BRANCHES
   ADD.W D6,PRC         ;NEW PC VALUE
1$ RTS
   ENDM



************************************************************
*
*        CODE STARTS HERE FOLKS
*
************************************************************




START MOVE.L 4(SP),A0  ;BASE PAGE START
 MOVE.L A0,A6          ;SAVE BASE PAGE
 MOVE.L $C(A0),D0      ;LENGTH OF PROG AREA
 ADD.L $14(A0),D0      ;LENGTH OF DATA AREA
 ADD.L $1C(A0),D0      ;LENGTH OF BSS AREA
 ADD.L #$100,D0        ;ADD IN BASE PAGE LENGTH
 MOVE.L D0,-(SP)       ;LENGTH OF AREA TO BE RESERVED
 MOVE.L A0,-(SP)       ;START OF CODE
 CLR.W -(SP)           ;HAS TO BE THERE
 MOVE.W #$4A,-(SP)     ;RESERVE MEMORY
 TRAP #1
 LEA 12(SP),SP         ;TIDY STACK
 MOVE.L #$10000,-(SP)  ;ASK FOR 64K
 MOVE.W #$48,(SP)
 TRAP #1
 ADDQ.L #6,SP
 TST.L D0
 BPL.S OK              ;NO ERROR
 MOVE.L #NOROOMTEXT,-(SP)
 MOVE.W #9,-(SP)        ;PRINT ERROR STRING
 TRAP #1
 ADDQ.L #6,SP
 CLR.L D0
1$ SUBQ.L #1,D0
   BNE.S 1$    ;WAIT A BIT BEFORE EXIT
 CLR.W -(SP)
 TRAP #1       ;EXIT BACK TO DESKTOP

NOROOMTEXT DC.B 13,10,10,"******* OUT OF MEMORY!!  TERMINATING ******",0

 CNOP 0,2

   BSS
ZERO6502 DS.L 1
SAVESSP DS.L 1

   TEXT


OK  MOVE.L D0,ZERO6502        ;SAVE START ADDRESS OF 6502 ADDRESS 0

* LOAD CODE FROM DISK

 LEA 129(A6),A6      ;POINTER TO COMMAND TAIL,SHOULD BE A VALID FILENAME
 MOVE.L A6,D6
 MOVE.L ZERO6502,D7
 ADD.L #$8000,D7  ;WHERE THE CODE IS GOING
 BSR.S LDISK    ;LOAD PROG FROM DISK
 BRA CONT     ;CONTINUE WITH PROGRAM

LDISK MOVE.W #2,-(SP)   ;R/W ENABLE
 MOVE.L D6,-(SP) ;FILENAME
 MOVE.W #$3D,-(SP)
 TRAP #1           ;OPEN FILE
 ADDQ.L #8,SP  ;TIDY STACK
 TST.W D0
 BMI.S 1$        ;ERROR
 MOVE.L D7,-(SP) ;WHERE THE CODE IS GOING
 MOVE.L #$4000,-(SP) ;LENGTH OF CODE
 MOVE.W D0,-(SP)  ;HANDLE PASSED FROM 'OPEN FILE'
 MOVE.W #$3F,-(SP)   ;READ FILE
 TRAP #1
 ADD.L #12,SP  ;TIDY STACK
 TST.L D0
 BPL.S 2$     ;NO ERROR
1$ MOVE.L #FERROR,-(SP)
 MOVE.W #9,-(SP)
 TRAP #1       ;PRINT FILE ERROR STRING
 ADDQ.L #6,SP
 BRA EXIT  ;LEAVE
2$ RTS

FERROR DC.B 13,10,10,"******* FILE ERROR- TERMINATING  ******",0

   CNOP 0,2

TITLE DC.B "                   6502 EMULATOR BY TIM TITCHMARSH 1987",13,10,10,0

   CNOP 0,2


*  NOW SET UP SCREEN  BEFORE WE START


CONT MOVE.W #4,-(SP)
 TRAP #14      ;GET SCREEN RES
 ADDQ.L #2,SP  ;TIDY STACK
 MOVE.W D0,RES    ;SAVE RES
 MOVE.W #2,D1     ;OUTPUT DEVICE
 MOVE.W #ESC,D0
 BSR OUTCHAR   ;ESC CODE
 MOVE.W #"v",D0
 BSR OUTCHAR      ;SET LINE OVERFLOW ON
 MOVE.W #ESC,D0
 BSR OUTCHAR
 MOVE.W #"c",D0   ;BACKGROUND COLOUR
 BSR OUTCHAR
 MOVE.W #1,D0
 BSR OUTCHAR      ;PAPER BLACK
 MOVE.W #ESC,D0
 BSR OUTCHAR
 MOVE.W #"b",D0
 BSR OUTCHAR      ;SET INK
 MOVE.W #0,D0
 BSR OUTCHAR       ;INK WHITE
 MOVE.W #ESC,D0
 BSR OUTCHAR
 MOVE.W #"E",D0
 BSR OUTCHAR      ;CLS
 MOVE.W #ESC,D0
 BSR OUTCHAR
 MOVE.W #"e",D0
 BSR OUTCHAR      ;TURN ON CURSOR
 MOVE.L #TITLE,-(SP)
 MOVE.W #9,-(SP)
 TRAP #1       ;PRINT TITLE
 ADDQ.L #6,SP

* NOW SET REGISTERS

 MOVEQ.L #1,A      ;BBC BASIC REQUIRES A TO HOLD 1 ON CALLING $8000
 MOVEQ.L #0,X
 MOVEQ.L #0,Y
 MOVEQ.L #0,FLAGS
 MOVE.L #$8000,PRC      ;PC= START OF CODE
 MOVE.L ZERO6502,OFF      ;OFF = ZERO6502  USED AS BASE POINTER (ADDRESS 0 FOR 6502)
 MOVE.L #FLAGTAB,A3     ;FLAGTABLE (16 BYTES LONG)
 MOVE.L ZERO6502,STK
 ADD.L #$1FF,STK        ;STK = TOP OF PAGE1 IN 6502

*  NOW START EMULATING THE CODE


EMULATE LEA JMPTAB,A0
 SUB.L D0,D0      ;CLEAR D0
 MOVE.B 0(PRC,OFF.L),D0  ;PICK UP OP CODE
 ASL.W #2,D0      ;TIMES 4
 ADD.L D0,A0      ;ADD IN OFFSET
 MOVE.L (A0),A0
 JSR (A0)      ;SERVICE IT
 BRA.S EMULATE

EXIT MOVE.L ZERO6502,-(SP)   ;START OF MEMORY REQUESTED
 MOVE.W #$49,-(SP)
 TRAP #1             ;FREE MEMORY
 ADDQ.L #6,SP
 CLR.W -(SP)
 TRAP #1          ;BACK TO DESKTOP



*  FLAGTAB HOLDS THE 6502 EQUIVALENT OF THE 68000 FLAGS ARRANGED
*  IN A TABLE

*              NVXXXXZC


   DATA

FLAGTAB  DC.B %00000000
         DC.B %00000001
         DC.B %01000000
         DC.B %01000001
         DC.B %00000010
         DC.B %00000011
         DC.B %01000010
         DC.B %01000011
         DC.B %10000000
         DC.B %10000001
         DC.B %11000000
         DC.B %11000001
         DC.B %10000010
         DC.B %10000011
         DC.B %11000010
         DC.B %11000011



*  JUMP TABLE FOR EVERY 6502 INSTRUCTION EACH ENTRY IS 4 BYTES LONG
*  UNUSED OPCODES ARE DIRECTED TO A 'NOTUSED' ROUTINE



JMPTAB  DC.L BRK  0
   DC.L ORAIX     1
   DC.L NU        2
   DC.L NU        3
   DC.L NU        4
   DC.L ORZ       5
   DC.L ASLZ      6
   DC.L NU        7
   DC.L PHP       8
   DC.L ORAI      9
   DC.L ASLAC     0A
   DC.L NU        0B
   DC.L NU        0C
   DC.L ORA       0D
   DC.L ASLA      OE
   DC.L NU        OF
   DC.L BPLL      10
   DC.L ORAIY     11
   DC.L NU        12
   DC.L NU        13
   DC.L NU        14
   DC.L ORZX      15
   DC.L ASLZX     16
   DC.L NU        17
   DC.L CLC       18
   DC.L ORAAY     19
   DC.L NU        1A
   DC.L NU        1B
   DC.L NU        1C
   DC.L ORAX      1D
   DC.L ASLAX     1E
   DC.L NU        1F
   DC.L JSRR      20
   DC.L ANDIX     21
   DC.L NU        22
   DC.L NU        23
   DC.L BITZ      24
   DC.L ANDZ      25
   DC.L ROLZ      26
   DC.L NU        27
   DC.L PLP       28
   DC.L ANDII     29
   DC.L ROLAC     2A
   DC.L NU        2B
   DC.L BITA      2C
   DC.L ANDA      2D
   DC.L ROLA      2E
   DC.L NU        2F
   DC.L BMII      30
   DC.L ANDIY     31
   DC.L NU        32
   DC.L NU        33
   DC.L NU        34
   DC.L ANDZX     35
   DC.L ROLZX     36
   DC.L NU        37
   DC.L SEC       38
   DC.L ANDAY     39
   DC.L NU        3A
   DC.L NU        3B
   DC.L NU        3C
   DC.L ANDAX     3D
   DC.L ROLAX     3E
   DC.L NU        3F
   DC.L RTI       40
   DC.L EORIX     41
   DC.L NU        42
   DC.L NU        43
   DC.L NU        44
   DC.L EORZ      45
   DC.L LSRZ      46
   DC.L NU        47
   DC.L PHA       48
   DC.L EORII     49
   DC.L LSRAC     4A
   DC.L NU        4B
   DC.L JMPA      4C
   DC.L EORA      4D
   DC.L LSRA      4E
   DC.L NU        4F
   DC.L BVCC      50
   DC.L EORIY     51
   DC.L NU        52
   DC.L NU        53
   DC.L NU        54
   DC.L EORZX     55
   DC.L LSRZX     56
   DC.L NU        57
   DC.L CLI       58
   DC.L EORAY     59
   DC.L NU        5A
   DC.L NU        5B
   DC.L NU        5C
   DC.L EORAX     5D
   DC.L LSRAX     5E
   DC.L NU        5F
   DC.L RTSS      60
   DC.L 61
   DC.L NU        62
   DC.L NU        63
   DC.L NU        64
   DC.L ADCZ      65
   DC.L RORZ      66
   DC.L NU        67
   DC.L PLA       68
   DC.L ADCI      69
   DC.L RORAC     6A
   DC.L NU        6B
   DC.L JMPI      6C
   DC.L ADCA      6D
   DC.L RORA      6E
   DC.L NU        6F
   DC.L BVSS      70
   DC.L ADCIY     71
   DC.L NU        72
   DC.L NU        73
   DC.L NU        74
   DC.L ADCZX     75
   DC.L RORZX     76
   DC.L NU        77
   DC.L SEI       78
   DC.L ADCAY     79
   DC.L NU        7A
   DC.L NU        7B
   DC.L NU        7C
   DC.L ADCAX     7D
   DC.L RORAX     7E
   DC.L NU        7F
   DC.L NU        80
   DC.L STAIX     81
   DC.L NU        82
   DC.L NU        83
   DC.L STYZ      84
   DC.L STAZ      85
   DC.L STXZ      86
   DC.L NU        87
   DC.L DEY       88
   DC.L NU        89
   DC.L TXA       8A
   DC.L NU        8B
   DC.L STYA      8C
   DC.L STAA      8D
   DC.L STXA      8E
   DC.L NU        8F
   DC.L BCCC      90
   DC.L STAIY     91
   DC.L NU        92
   DC.L NU        93
   DC.L STYZX     94
   DC.L STAZX     95
   DC.L STXZY     96
   DC.L NU        97
   DC.L TYA       98
   DC.L STAAY     99
   DC.L TXS       9A
   DC.L NU        9B
   DC.L NU        9C
   DC.L STAAX     9D
   DC.L NU        9E
   DC.L NU        9F
   DC.L LDYI      A0
   DC.L LDAIX     A1
   DC.L LDXI      A2
   DC.L NU        A3
   DC.L LDYZ      A4
   DC.L LDAZ      A5
   DC.L LDXZ      A6
   DC.L NU        A7
   DC.L TAY       A8
   DC.L LDAI      A9
   DC.L TAX       AA
   DC.L NU        AB
   DC.L LDYA      AC
   DC.L LDAA      AD
   DC.L LDXA      AE
   DC.L NU        AF
   DC.L BCSS      B0
   DC.L LDAIY     B1
   DC.L NU        B2
   DC.L NU        B3
   DC.L LDYZX     B4
   DC.L LDAZX     B5
   DC.L LDXZY     B6
   DC.L NU        B7
   DC.L CLV       B8
   DC.L LDAAY     B9
   DC.L TSX       BA
   DC.L NU        BB
   DC.L LDYAX     BC
   DC.L LDAAX     BD
   DC.L LDXAY     BE
   DC.L NU        BF
   DC.L CPYI      C0
   DC.L CMPIX     C1
   DC.L NU        C2
   DC.L NU        C3
   DC.L CPYZ      C4
   DC.L CMPZ      C5
   DC.L DECZ      C6
   DC.L NU        C7
   DC.L INY       C8
   DC.L CMPII     C9
   DC.L DEX       CA
   DC.L NU        CB
   DC.L CPYA      CC
   DC.L CMPAA     CD
   DC.L DECA      CE
   DC.L NU        CF
   DC.L BNEE      D0
   DC.L CMPIY     D1
   DC.L NU        D2
   DC.L NU        D3
   DC.L NU        D4
   DC.L CMPZX     D5
   DC.L DECZX     D6
   DC.L NU        D7
   DC.L CLD       D8
   DC.L CMPAY     D9
   DC.L NU        DA
   DC.L NU        DB
   DC.L NU        DC
   DC.L CMPAX     DD
   DC.L DECAX     DE
   DC.L NU        DF
   DC.L CPXI      EO
   DC.L SBCIX     E1
   DC.L NU        E2
   DC.L NU        E3
   DC.L CPXZ      E4
   DC.L SBCZ      E5
   DC.L INCZ      E6
   DC.L NU        E7
   DC.L INX       E8
   DC.L SBCI      E9
   DC.L NOPP      EA
   DC.L NU        EB
   DC.L CPXA      EC
   DC.L SBCA      ED
   DC.L INCA      EE
   DC.L NU        EF
   DC.L BEQQ      FO
   DC.L SBCIY     F1
   DC.L NU        F2
   DC.L NU        F3
   DC.L NU        F4
   DC.L SBCZX     F5
   DC.L INCZX     F6
   DC.L NU        F7
   DC.L SED       F8
   DC.L SBCAY     F9
   DC.L NU        FA
   DC.L NU        FB
   DC.L NU        FC
   DC.L SBCAX     FD
   DC.L INCAX     FE
   DC.L NU        FF



   PAGE  ;PRINT NEW PAGE
   TEXT  ;CODE SECTION


**********  NOTUSED  **********************
*
* ALL OF THE UNUSED OPCODES ARE SENT HERE FOR NOW
* AND THE PC IS INCREMENTED ONCE. SHOULD NEVER GET HERE
* IF THE PROGRAM IS CORRECT



NU RET 1

*******************************************

***********  ADC IMMEDIATE $69  ***********

ADCI TEST1
 MOVE.B 1(PRC,OFF.L),D1   ;DATA TO BE ADDED
 MOVE.W D0,CCR    ;SET ZERO AND MAYBE X BITS
 ADDX.B D1,A         ;CAN ONLY USE DATA REGISTERS
 SETFLAGS N,Z,V,C
 RET 2

2$ MOVE.B 1(PRC,OFF.L),D1   ;DATA TO BE ADDED
 MOVE.W D0,CCR    ;SET ZERO AND MAYBE X BITS
 ABCD.B D1,A         ;CAN ONLY USE DATA REGISTERS
 SETFLAGS 0,Z,0,C    ;CANT FULLY EMULATE FLAGS HERE
 RET 2

*******************************************

**********  ADC ZEROPAGE  $65  ************

ADCZ TEST1
 ZEROPAGE
 MOVE.B 0(OFF,D6.L),D1    ;DATA TO BE ADDED
 MOVE.W D0,CCR
 ADDX.B D1,A
 SETFLAGS N,Z,V,C
 RET 2
                         
2$ ZEROPAGE
 MOVE.B 1(OFF,D6.L),D1   ;DATA TO BE ADDED
 MOVE.W D0,CCR    ;SET ZERO AND MAYBE X BITS
 ABCD.B D1,A         ;CAN ONLY USE DATA REGISTERS
 SETFLAGS 0,Z,0,C    ;CANT FULLY EMULATE FLAGS HERE
 RET 2

*******************************************

**********  ADC ZEROPAGE,X  $75  **********

ADCZX TEST1
 ZEROPAGEX
 MOVE.B 0(OFF,D6.L),D1    ;DATA TO BE ADDED
 MOVE.W D0,CCR
 ADDX.B D1,A
 SETFLAGS N,Z,V,C
 RET 2

2$ ZEROPAGEX
 MOVE.B 1(OFF,D6.L),D1   ;DATA TO BE ADDED
 MOVE.W D0,CCR    ;SET ZERO AND MAYBE X BITS
 ABCD.B D1,A         ;CAN ONLY USE DATA REGISTERS
 SETFLAGS 0,Z,0,C    ;CANT FULLY EMULATE FLAGS HERE
 RET 2

*******************************************

**********  ADC ABSOLUTE  $6D  ************

ADCA TEST1
 ABS
 MOVE.B 0(OFF,D6.L),D1      ;DATA TO BE ADDED
 MOVE.W D0,CCR
 ADDX.B D1,A
 SETFLAGS N,Z,V,C
 RET 3

2$ ABS
 MOVE.B 1(OFF,D6.L),D1   ;DATA TO BE ADDED
 MOVE.W D0,CCR    ;SET ZERO AND MAYBE X BITS
 ABCD.B D1,A         ;CAN ONLY USE DATA REGISTERS
 SETFLAGS 0,Z,0,C    ;CANT FULLY EMULATE FLAGS HERE
 RET 3

*******************************************

**********  ADC ABSOLUTE,X  $7D  **********

ADCAX TEST1
 ABSX
 MOVE.B 0(OFF,D6.L),D1    ;DATA TO BE ADDED
 MOVE.W D0,CCR
 ADDX.B D1,A
 SETFLAGS N,Z,V,C
 RET 3

2$ ABSX
 MOVE.B 1(OFF,D6.L),D1   ;DATA TO BE ADDED
 MOVE.W D0,CCR    ;SET ZERO AND MAYBE X BITS
 ABCD.B D1,A         ;CAN ONLY USE DATA REGISTERS
 SETFLAGS 0,Z,0,C    ;CANT FULLY EMULATE FLAGS HERE
 RET 3

*******************************************

**********  ADC ABSOLUTE,Y  $79  **********

ADCAY TEST1
 ABSY
 MOVE.B 0(OFF,D6.L),D1    ;DATA TO BE ADDED
 MOVE.W D0,CCR
 ADDX.B D1,A
 SETFLAGS N,Z,V,C
 RET 3

2$ ABSY
 MOVE.B 1(OFF,D6.L),D1   ;DATA TO BE ADDED
 MOVE.W D0,CCR    ;SET ZERO AND MAYBE X BITS
 ABCD.B D1,A         ;CAN ONLY USE DATA REGISTERS
 SETFLAGS 0,Z,0,C    ;CANT FULLY EMULATE FLAGS HERE
 RET 3

*******************************************

**********  ADC (INDIRECT ,X)  $61  *******

ADCIX TEST1
 INDIRECTX
 MOVE.B 0(OFF,D7.L),D1    ;DATA TO BE ADDED
 MOVE.W D0,CCR
 ADDX.B D1,A
 SETFLAGS N,Z,V,C
 RET 2

2$ INDIRECTX
 MOVE.B 1(OFF,D7.L),D1   ;DATA TO BE ADDED
 MOVE.W D0,CCR    ;SET ZERO AND MAYBE X BITS
 ABCD.B D1,A         ;CAN ONLY USE DATA REGISTERS
 SETFLAGS 0,Z,0,C    ;CANT FULLY EMULATE FLAGS HERE
 RET 2

*******************************************

**********  ADC (INDIRECT ),Y  $71  *******

ADCIY TEST1
 INDIRECTY
 MOVE.B 0(OFF,D7.L),D1    ;DATA TO BE ADDED
 MOVE.W D0,CCR
 ADDX.B D1,A
 SETFLAGS N,Z,V,C
 RET 2

2$ INDIRECTY
 MOVE.B 1(OFF,D7.L),D1   ;DATA TO BE ADDED
 MOVE.W D0,CCR    ;SET ZERO AND MAYBE X BITS
 ABCD.B D1,A         ;CAN ONLY USE DATA REGISTERS
 SETFLAGS 0,Z,0,C    ;CANT FULLY EMULATE FLAGS HERE
 RET 2

*******************************************

***********  AND IMMEDIATE $29  ***********

ANDII  AND.B 1(PRC,OFF.L),A   ;AND IN DATA
 SETFLAGS N,Z,0,0
 RET 2

*******************************************

**********  AND ZEROPAGE  $25  ************

ANDZ ZEROPAGE
 AND.B 0(OFF,D6.L),A    ;AND IN VALUE
 SETFLAGS N,Z,0,0
 RET 2

*******************************************

**********  AND ZEROPAGE,X  $35  **********

ANDZX ZEROPAGEX
 AND.B 0(OFF,D6.L),A    ;AND IN VALUE
 SETFLAGS N,Z,0,0
 RET 2

*******************************************

**********  AND ABSOLUTE  $2D  ************

ANDA ABS
 AND.B 0(OFF,D6.L),A      ;AND IN DATA
 SETFLAGS N,Z,0,0
 RET 3

*******************************************

**********  AND ABSOLUTE,X  $3D  **********

ANDAX ABSX
 AND.B 0(OFF,D6.L),A    ;AND IN VALUE
 SETFLAGS N,Z,0,0
 RET 3

*******************************************

**********  AND ABSOLUTE,Y  $39  **********

ANDAY ABSY
 AND.B 0(OFF,D6.L),A    ;AND IN VALUE
 SETFLAGS N,Z,0,0
 RET 3

*******************************************

**********  AND (INDIRECT ,X)  $21  *******

ANDIX INDIRECTX
 AND.B 0(OFF,D7.L),A    ;AND IN DATA
 SETFLAGS N,Z,0,0
 RET 2

********************************************

**********  AND (INDIRECT ),Y  $31  ********

ANDIY INDIRECTY
 AND.B 0(OFF,D7.L),A    ;AND IN VALUE
 SETFLAGS N,Z,0,0
 RET 2

********************************************

***********  CMP IMMEDIATE $C9  ************

CMPII  CMP.B 1(PRC,OFF.L),A   ;CMP DATA
 SETFLAGS N,Z,0,C
 EOR.B #C,FLAGS     ;TOGGLE CARRY AS OPPOSITE TO 68000 ACTION
 RET 2

********************************************

**********  CMP ZEROPAGE  $C5  *************

CMPZ ZEROPAGE
 CMP.B 0(OFF,D6.L),A    ;CMP  VALUE
 SETFLAGS N,Z,0,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY
 RET 2

********************************************

**********  CMP ZEROPAGE,X  $D5  ***********

CMPZX ZEROPAGEX
 CMP.B 0(OFF,D6.L),A    ;CMP VALUE
 SETFLAGS N,Z,0,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY
 RET 2

********************************************

**********  CMP ABSOLUTE  $CD  *************

CMPAA ABS
 CMP.B 0(OFF,D6.L),A      ;CMP DATA
 SETFLAGS N,Z,0,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY
 RET 3

********************************************

**********  CMP ABSOLUTE,X  $DD  ***********

CMPAX ABSX
 CMP.B 0(OFF,D6.L),A    ;CMP VALUE
 SETFLAGS N,Z,0,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY
 RET 3

********************************************

**********  CMP ABSOLUTE,Y  $D9  ***********

CMPAY ABSY
 CMP.B 0(OFF,D6.L),A    ;CMP VALUE
 SETFLAGS N,Z,0,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY
 RET 3

********************************************

**********  CMP (INDIRECT ,X)  $C1  ********

CMPIX INDIRECTX
 CMP.B 0(OFF,D7.L),A    ;CMP DATA
 SETFLAGS N,Z,0,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY
 RET 2

********************************************

**********  CMP (INDIRECT ),Y  $D1  ********

CMPIY INDIRECTY
 CMP.B 0(OFF,D7.L),A    ;CMP VALUE
 SETFLAGS N,Z,0,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY
 RET 2

********************************************

***********  EOR IMMEDIATE $49  ************

EORII  MOVE.B 1(PRC,OFF.L),D6   ;PICK UP DATA
 EOR.B D6,A    ;EOR BYTE        ;CAN ONLY EOR TO A DATA REG
 SETFLAGS N,Z,0,0
 RET 2

********************************************

**********  EOR ZEROPAGE  $45  *************

EORZ ZEROPAGE
 MOVE.B 0(OFF,D6.L),D6
 EOR.B D6,A       ;EOR BYTE
 SETFLAGS N,Z,0,0
 RET 2

********************************************

**********  EOR ZEROPAGE,X  $55  ***********

EORZX ZEROPAGEX
 MOVE.B 0(OFF,D6.L),D6    ;PICK UP BYTE
 EOR.B D6,A    ;EOR BYTE
 SETFLAGS N,Z,0,0
 RET 2

********************************************

**********  EOR ABSOLUTE  $4D  *************

EORA ABS
 MOVE.B 0(OFF,D6.L),D6
 EOR.B D6,A    ;EOR BYTE
 SETFLAGS N,Z,0,0
 RET 3

********************************************

**********  EOR ABSOLUTE,X  $5D  ***********

EORAX ABSX
 MOVE.B 0(OFF,D6.L),D6
 EOR.B D6,A    ;EOR BYTE
 SETFLAGS N,Z,0,0
 RET 3

********************************************

**********  EOR ABSOLUTE,Y  $59  ***********

EORAY ABSY
 MOVE.B 0(OFF,D6.L),D6
 EOR.B D6,A
 SETFLAGS N,Z,0,0
 RET 3

********************************************

**********  EOR (INDIRECT ,X)  $41  ********

EORIX INDIRECTX
 MOVE.B 0(OFF,D7.L),D6
 EOR.B D6,A               ;EOR IN DATA
 SETFLAGS N,Z,0,0
 RET 2

********************************************

**********  EOR (INDIRECT ),Y  $51  ********

EORIY INDIRECTY
 MOVE.B 0(OFF,D7.L),D6
 EOR.B D6,A    ;EOR IN VALUE
 SETFLAGS N,Z,0,0
 RET 2

********************************************

***********  LDA  IMMEDIATE $A9  ***********

LDAI  MOVE.B 1(PRC,OFF.L),A   ;LDA IN DATA
 SETFLAGS N,Z,0,0
 RET 2

********************************************

**********  LDA ZEROPAGE  $A5  *************

LDAZ ZEROPAGE
 MOVE.B 0(OFF,D6.L),A    ;LDA IN VALUE
 SETFLAGS N,Z,0,0
 RET 2

********************************************

**********  LDA ZEROPAGE,X  $B5  ***********

LDAZX ZEROPAGEX
 MOVE.B 0(OFF,D6.L),A    ;LDA WITH VALUE
 SETFLAGS N,Z,0,0
 RET 2

********************************************

**********  LDA ABSOLUTE  $AD  *************

LDAA ABS
 MOVE.B 0(OFF,D6.L),A      ;LDA WITH DATA
 SETFLAGS N,Z,0,0
 RET 3

********************************************

**********  LDA ABSOLUTE,X  $BD  ***********

LDAAX ABSX
 MOVE.B 0(OFF,D6.L),A    ;LDA WITH VALUE
 SETFLAGS N,Z,0,0
 RET 3

********************************************

**********  LDA ABSOLUTE,Y  $B9  ***********

LDAAY ABSY
 MOVE.B 0(OFF,D6.L),A    ;LDA WITH VALUE
 SETFLAGS N,Z,0,0
 RET 3

********************************************

**********  LDA (INDIRECT ,X)  $A1  ********

LDAIX INDIRECTX
 MOVE.B 0(OFF,D7.L),A    ;LDA WITH DATA
 SETFLAGS N,Z,0,0
 RET 2

********************************************

**********  LDA (INDIRECT ),Y  $B1  ********

LDAIY INDIRECTY
 MOVE.B 0(OFF,D7.L),A    ;LDA WITH VALUE
 SETFLAGS N,Z,0,0
 RET 2

********************************************

***********  ORA IMMEDIATE $9  *************

ORAI  OR.B 1(PRC,OFF.L),A   ;OR IN DATA
 SETFLAGS N,Z,0,0
 RET 2

********************************************

**********  OR ZEROPAGE  $5  ***************

ORZ ZEROPAGE
 OR.B 0(OFF,D6.L),A    ;OR IN VALUE
 SETFLAGS N,Z,0,0
 RET 2

********************************************

**********  OR ZEROPAGE,X  $15  ************


ORZX ZEROPAGEX
 OR.B 0(OFF,D6.L),A    ;OR IN VALUE
 SETFLAGS N,Z,0,0
 RET 2

********************************************

**********  OR ABSOLUTE  $D  ***************

ORA ABS
 OR.B 0(OFF,D6.L),A      ;OR IN DATA
 SETFLAGS N,Z,0,0
 RET 3

********************************************

**********  OR ABSOLUTE,X  $1D  ************

ORAX ABSX
 OR.B 0(OFF,D6.L),A    ;ORA IN VALUE
 SETFLAGS N,Z,0,0
 RET 3

********************************************

**********  ORA ABSOLUTE,Y  $19  ***********

ORAAY ABSY
 OR.B 0(OFF,D6.L),A    ;ORA IN VALUE
 SETFLAGS N,Z,0,0
 RET 3

********************************************

**********  ORA (INDIRECT ,X)  $1  *********

ORAIX INDIRECTX
 OR.B 0(OFF,D7.L),A    ;ORA IN DATA
 SETFLAGS N,Z,0,0
 RET 2

********************************************

**********  ORA (INDIRECT ),Y  $11  ********

ORAIY INDIRECTY
 OR.B 0(OFF,D7.L),A    ;ORA IN VALUE
 SETFLAGS N,Z,0,0
 RET 2

********************************************

***********  SBC IMMEDIATE $E9  ************

SBCI TEST2
 MOVE.B 1(PRC,OFF.L),D1   ;DATA TO BE SUB
 MOVE.W D0,CCR
 SUBX.B D1,A
 SETFLAGS N,Z,V,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY AS OPPOSITE TO 68000
 RET 2

2$ MOVE.B 1(PRC,OFF.L),D1   ;DATA TO BE SUB
 MOVE.W D0,CCR
 SBCD D1,A
 SETFLAGS 0,Z,0,C    ;CANT SET FLAGS PROPERLY
 EOR.B #C,FLAGS      ;TOGGLE CARRY AS OPPOSITE TO 68000
 RET 2

********************************************

**********  SBC ZEROPAGE  $E5  *************

SBCZ TEST2
 ZEROPAGE
 MOVE.B 0(OFF,D6.L),D1
 MOVE.W D0,CCR
 SUBX.B D1,A
 SETFLAGS N,Z,V,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY AS OPPOSITE TO 68000
 RET 2

2$ ZEROPAGE
 MOVE.B 0(OFF,D6.L),D1
 MOVE.W D0,CCR
 SBCD D1,A
 SETFLAGS 0,Z,0,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY AS OPPOSITE TO 68000
 RET 2

********************************************

**********  SBC ZEROPAGE,X  $F5  ***********

SBCZX TEST2
 ZEROPAGEX
 MOVE.B 0(OFF,D6.L),D1    ;SUB VALUE
 MOVE.W D0,CCR
 SUBX.B D1,A
 SETFLAGS N,Z,V,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY AS OPPOSITE TO 68000
 RET 2

2$ ZEROPAGEX
 MOVE.B 0(OFF,D6.L),D1
 MOVE.W D0,CCR
 SBCD D1,A
 SETFLAGS 0,Z,0,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY AS OPPOSITE TO 68000
 RET 2

********************************************

**********  SBC ABSOLUTE  $ED  *************

SBCA TEST2
 ABS
 MOVE.B 0(OFF,D6.L),D1
 MOVE.W D0,CCR
 SUBX.B D1,A
 SETFLAGS N,Z,V,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY AS OPPOSITE TO 68000
 RET 3

2$ ABS
 MOVE.B 0(OFF,D6.L),D1
 MOVE.W D0,CCR
 SBCD D1,A
 SETFLAGS 0,Z,0,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY AS OPPOSITE TO 68000
 RET 3

********************************************

**********  SBC ABSOLUTE,X  $FD  ***********

SBCAX TEST2
 ABSX
 MOVE.B 0(OFF,D6.L),D1    ;SUB VALUE
 MOVE.W D0,CCR
 SUBX.B D1,A
 SETFLAGS N,Z,V,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY AS OPPOSITE TO 68000
 RET 3

2$ ABSX
 MOVE.B 0(OFF,D6.L),D1
 MOVE.W D0,CCR
 SBCD D1,A
 SETFLAGS 0,Z,0,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY AS OPPOSITE TO 68000
 RET 3

********************************************

**********  SBC ABSOLUTE,Y  $F9  ***********

SBCAY TEST2
 ABSY
 MOVE.B 0(OFF,D6.L),D1    ; VALUE
 MOVE.W D0,CCR
 SUBX.B D1,A
 SETFLAGS N,Z,V,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY AS OPPOSITE TO 68000
 RET 3

2$ ABSY
 MOVE.B 0(OFF,D6.L),D1
 MOVE.W D0,CCR
 SBCD D1,A
 SETFLAGS 0,Z,0,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY AS OPPOSITE TO 68000
 RET 3

********************************************

**********  SBC (INDIRECT ,X)  $E1  ********

SBCIX TEST2
 INDIRECTX
 MOVE.B 0(OFF,D7.L),D1    ;SUB DATA
 MOVE.W D0,CCR
 SUBX.B D1,A
 SETFLAGS N,Z,V,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY AS OPPOSITE TO 68000
 RET 2

2$ INDIRECTX
 MOVE.B 0(OFF,D7.L),D1
 MOVE.W D0,CCR
 SBCD D1,A
 SETFLAGS 0,Z,0,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY AS OPPOSITE TO 68000
 RET 2

********************************************

**********  SBC (INDIRECT ),Y  $F1  ********

SBCIY TEST2
 INDIRECTY
 MOVE.B 0(OFF,D7.L),D1    ;SUB  VALUE
 MOVE.W D0,CCR
 SUBX.B D1,A
 SETFLAGS N,Z,V,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY AS OPPOSITE TO 68000
 RET 2

2$ INDIRECTY
 MOVE.B 0(OFF,D7.L),D1
 MOVE.W D0,CCR
 SBCD D1,A
 SETFLAGS 0,Z,0,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY AS OPPOSITE TO 68000
 RET 2

********************************************

**********  STA ZEROPAGE  $85  *************

STAZ ZEROPAGE
 MOVE.B A,0(OFF,D6.L)    ;STORE A
 RET 2

********************************************

**********  STA ZEROPAGE,X  $95  ***********

STAZX ZEROPAGEX
 MOVE.B A,0(OFF,D6.L)    ;STORE A
 RET 2

********************************************

**********  STA ABSOLUTE  $8D  *************

STAA ABS
 MOVE.B A,0(OFF,D6.L)      ;STORE A
 RET 3

********************************************

**********  STA ABSOLUTE,X  $9D  ***********

STAAX ABSX
 MOVE.B A,0(OFF,D6.L)    ;STORE A
 RET 3

********************************************

**********  STA ABSOLUTE,Y  $99  ***********

STAAY ABSY
 MOVE.B A,0(OFF,D6.L)    ;STORE A
 RET 3

********************************************

**********  STA (INDIRECT ,X)  $81  ********

STAIX INDIRECTX
 MOVE.B A,0(OFF,D7.L)    ;STORE A
 RET 2

********************************************

**********  STA (INDIRECT ),Y  $91  ********

STAIY INDIRECTY
 MOVE.B A,0(OFF,D7.L)    ;STORE A
 RET 2

********************************************

***********  ASL ACCUMULATOR $0A  *********

ASLAC  ASL.B #1,A   ;ASL A
 SETFLAGS N,Z,0,C
 RET 1

*******************************************

**********  ASL ZEROPAGE  $6  *************

ASLZ ZEROPAGE
 ASL_
 RET 2

*******************************************

**********  ASL ZEROPAGE,X  $16  **********

ASLZX ZEROPAGEX
 ASL_
 RET 2

*******************************************

**********  ASL ABSOLUTE  $E  *************

ASLA ABS
   ASL_
   RET 3

*******************************************

**********  ASL ABSOLUTE,X  $1E  **********

ASLAX ABSX
   ASL_
   RET 3

*******************************************

**********  BIT ZEROPAGE  $24  ************

BITZ ZEROPAGE
 MOVE.B 0(OFF,D6.L),D6    ;VALUE IN D6
 MOVE.B A,D7      ;SAVE A AS WE DONT CORRUPT IT WITH THE 'AND'
 AND.B D6,A      ;AND TO EFFECT ZERO FLAG
 BNE.S 1$
 BSET #ZB,FLAGS ;SET ZEROFLAG
 BRA.S 2$
1$ BCLR #ZB,FLAGS     ;CLEAR ZERO
2$ AND.B #N+V,D6      ;MASK IN N AND V BITS
 AND.B #$3F,FLAGS     ;MASK OUT N AND V FLAGS
 OR.B D6,FLAGS    ;COPY BIT 6 AND BIT 7 OF DATA INTO N AND V FLAGS
 MOVE.B D7,A      ;RESTORE A
 RET 2

*******************************************

**********  BIT  ABSOLUTE  $2C  ***********

BITA ABS
 MOVE.B 0(OFF,D6.L),D6      ;DATA IN D6
 MOVE.B A,D7      ;SAVE A AS WE DONT WANT TO CORRUPT
 AND.B D6,A      ;AND TO EFFECT ZERO FLAG
 BNE.S 1$
 BSET #ZB,FLAGS ;SET ZEROFLAG
 BRA.S 2$
1$ BCLR #ZB,FLAGS     ;CLEAR ZERO
2$ AND.B #N+V,D6      ;MASK IN N AND V FLAGS
 AND.B #$3F,FLAGS     ;MASK OUT N AND V FLAGS
 OR.B D6,FLAGS    ;COPY BIT 6 AND BIT 7 OF DATA INTO N AND V FLAGS
 MOVE.B D7,A      ;RESTORE A
 RET 3

*******************************************


**********  BRK  0  ***********************

* CONFIGURED AT THE MOMENT TO HANDLE BBC BREAK EFFECTS


BRK MOVE.L PRC,D6
 ROR.W #8,D6
 MOVE.B D6,(STK)  ;PUSH PCH
 SUBQ.W #1,STK    ;DEC SP
 ROR.W #8,D6      ;MOVE DOWN MSB
 MOVE.B D6,(STK)  ;PUSH PCL
 SUBQ.W #1,STK    ;DEC SP
 MOVE.B FLAGS,(STK)     ;PUSH FLAGS
 SUBQ.W #1,STK
 ADDQ.W #1,D6     ;POINT TO BYTE AFTER BRK
 MOVE.B D6,$FD(OFF)     ;PUT ADDRESS OF BYTE AFTER BRK INTO $FD,$FE
 ROR.W #8,D6      ;MOVE DOWN MSB INTO LSB
 MOVE.B D6,$FE(OFF)     ;STORE IN MSB
 ADDQ.W #2,PRC    ;ON THE BBC THE BRK IS TAKEN AS A TWO BYTE INSTRUCTION
 MOVE.B $203(OFF),D6    ;PICK UP MSB OF BREAK VECTOR
 ASL.W #8,D6      ;MOVE UP TO MSB
 MOVE.B $202(OFF),D6    ;PICK UP LSB OF VECTOR
 MOVE.L D6,PRC    ;PRC NOW POINTS TO BREAK ROUTINE
 RTS
 
*******************************************


**********  CLC  $18  *********************


CLC AND.B #%11111110,FLAGS    ;CLEAR CARRY
   RET 1

*******************************************


**********  CLD  $D8  *********************


CLD AND.B #%11110111,FLAGS    ;CLEAR DECIMAL
 RET 1

*******************************************

**********  CLI  $58  *********************

CLI AND.B #%11111011,FLAGS    ;CLEAR INTERRUPT MASK
 RET 1

*******************************************

**********  CLV  $B8  *********************

CLV AND.B #%10111111,FLAGS    ;CLEAR V FLAG
 RET 1

*******************************************

***********  CPX IMMEDIATE $EO  ***********

CPXI CMP.B 1(PRC,OFF.L),X   ;CMP DATA
 SETFLAGS N,Z,0,C
 EOR.B #C,FLAGS     ;TOGGLE CARRY AS OPPOSITE TO 68000 ACTION
 RET 2

*******************************************


**********  CPX ZEROPAGE  $E4  ************

CPXZ ZEROPAGE
 CMP.B 0(OFF,D6.L),X    ;CMP  VALUE
 SETFLAGS N,Z,0,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY
 RET 2

*******************************************

**********  CPX ABSOLUTE  $EC  ************

CPXA ABS
 CMP.B 0(OFF,D6.L),X      ;CMP DATA
 SETFLAGS N,Z,0,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY
 RET 3

*******************************************

***********  CPY IMMEDIATE $CO  ***********

CPYI CMP.B 1(PRC,OFF.L),Y   ;CMP DATA
 SETFLAGS N,Z,0,C
 EOR.B #C,FLAGS     ;TOGGLE CARRY AS OPPOSITE TO 68000 ACTION
 RET 2

*******************************************

**********  CPY ZEROPAGE  $C4  ************

CPYZ ZEROPAGE
 CMP.B 0(OFF,D6.L),Y    ;CMP  VALUE
 SETFLAGS N,Z,0,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY
 RET 2

*******************************************

**********  CPY ABSOLUTE  $CC  ************

CPYA ABS
 CMP.B 0(OFF,D6.L),Y      ;CMP DATA
 SETFLAGS N,Z,0,C
 EOR.B #C,FLAGS      ;TOGGLE CARRY
 RET 3

*******************************************

**********  DEC ZEROPAGE  $C6  ************

DECZ ZEROPAGE
 SUBQ.B #1,0(OFF,D6.L)    ;DEC BYTE
 SETFLAGS N,Z,0,0
 RET 2

********************************************

**********  DEC ZEROPAGE,X  $D6  ***********

DECZX ZEROPAGEX
 SUBQ.B #1,0(OFF,D6.L)    ;DEC BYTE
 SETFLAGS N,Z,0,0
 RET 2

*******************************************

**********  DEC ABSOLUTE  $CE  ************

DECA ABS
 SUBQ.B #1,0(OFF,D6.L)      ;DEC BYTE
 SETFLAGS N,Z,0,0
 RET 3

*******************************************

**********  DEC ABSOLUTE,X  $DE  **********


DECAX ABSX
 SUBQ.B #1,0(OFF,D6.L)    ;DEC BYTE
 SETFLAGS N,Z,0,0
 RET 3

*******************************************

**********  INC ZEROPAGE  $E6  ************

INCZ ZEROPAGE
 ADDQ.B #1,0(OFF,D6.L)    ;INC BYTE
 SETFLAGS N,Z,0,0
 RET 2

*******************************************

**********  INC ZEROPAGE,X  $F6  **********

INCZX ZEROPAGEX
 ADDQ.B #1,0(OFF,D6.L)    ;INC BYTE
 SETFLAGS N,Z,0,0
 RET 2

*******************************************

**********  INC ABSOLUTE  $EE  ************

INCA ABS
 ADDQ.B #1,0(OFF,D6.L)      ;INC BYTE
 SETFLAGS N,Z,0,0
 RET 3

*******************************************

**********  INC ABSOLUTE,X  $FE  **********

INCAX ABSX
 ADDQ.B #1,0(OFF,D6.L)    ;INC BYTE
 SETFLAGS N,Z,0,0
 RET 3

*******************************************

**********  DEX  $CA  *********************

DEX SUBQ.B #1,X      DEC X
 SETFLAGS N,Z,0,0
 RET 1

*******************************************

*********  DEY  $88  **********************

DEY SUBQ.B #1,Y      ;DEC Y
 SETFLAGS N,Z,0,0
 RET 1

*******************************************

**********  INX  $E8  *********************

INX ADDQ.B #1,X      INC X
 SETFLAGS N,Z,0,0
 RET 1

*******************************************

*********  INY  $C8  **********************

INY ADDQ.B #1,Y      ;INC Y
 SETFLAGS N,Z,0,0
 RET 1

*******************************************

***********  LDX  IMMEDIATE $A2  **********

LDXI  MOVE.B 1(PRC,OFF.L),X   ;LDX WITH DATA
 SETFLAGS N,Z,0,0
 RET 2

*******************************************

**********  LDX ZEROPAGE  $A6  ************

LDXZ ZEROPAGE
 MOVE.B 0(OFF,D6.L),X    ;LDX WITH VALUE
 SETFLAGS N,Z,0,0
 RET 2

*******************************************

**********  LDX ZEROPAGE,Y  $B6  **********

LDXZY ZEROPAGE
 ADD.B Y,D6
 MOVE.B 0(OFF,D6.L),X    ;LDX WITH VALUE
 SETFLAGS N,Z,0,0
 RET 2

*******************************************

**********  LDX ABSOLUTE  $AE  ************

LDXA ABS
 MOVE.B 0(OFF,D6.L),X      ;LDX WITH DATA
 SETFLAGS N,Z,0,0
 RET 3

*******************************************

**********  LDX ABSOLUTE,Y  $BE  **********

LDXAY ABS
 ADD.W Y,D6
 MOVE.B 0(OFF,D6.L),X    ;LDX WITH VALUE
 SETFLAGS N,Z,0,0
 RET 3

*******************************************

***********  LDY  IMMEDIATE $A0  **********

LDYI  MOVE.B 1(PRC,OFF.L),Y   ;LDY WITH DATA
 SETFLAGS N,Z,0,0
 RET 2

*******************************************

**********  LDY ZEROPAGE  $A4  ************

LDYZ ZEROPAGE
 MOVE.B 0(OFF,D6.L),Y    ;LDY WITH VALUE
 SETFLAGS N,Z,0,0
 RET 2

*******************************************

**********  LDY ZEROPAGE,X  $B4  **********

LDYZX ZEROPAGEX
 MOVE.B 0(OFF,D6.L),Y    ;LDY WITH VALUE
 SETFLAGS N,Z,0,0
 RET 2

*******************************************

**********  LDY ABSOLUTE  $AC  ************

LDYA ABS
 MOVE.B 0(OFF,D6.L),Y      ;LDY WITH DATA
 SETFLAGS N,Z,0,0
 RET 3

*******************************************

**********  LDY ABSOLUTE,X  $BC  **********

LDYAX ABSX
 MOVE.B 0(OFF,D6.L),Y    ;LDY WITH VALUE
 SETFLAGS N,Z,0,0
 RET 3

*******************************************

***********  LSR ACCUMULATOR $4A  *********


LSRAC  LSR.B #1,A   ;LSR A
 SETFLAGS N,Z,0,C
 RET 1

*******************************************

**********  LSR ZEROPAGE  $46  ************

LSRZ ZEROPAGE
   LSR_
   RET 2

*******************************************

**********  LSR ZEROPAGE,X  $56  ***********

LSRZX ZEROPAGEX
   LSR_
   RET 2

*******************************************

**********  LSR ABSOLUTE  $4E  ************

LSRA ABS
   LSR_
   RET 3

*******************************************


**********  LSR ABSOLUTE,X  $5E  **********

LSRAX ZEROPAGEX
   LSR_
   RET 3

*******************************************


********** NOP  $EA  **********************

NOPP RET 1     ;DO NOTHING

*******************************************

**********  PHA  $48  *********************

PHA MOVE.B A,(STK)     ;PUSH A ONTO STACK
 SUBQ.W #1,STK          ;DEC SP
 RET 1

*******************************************

**********  PHP  $8  **********************

PHP  MOVE.B FLAGS,(STK)   ;PUSH FLAGS ONTO STACK
 SUBQ.W #1,STK    ;DEC SP
 RET 1

*******************************************

**********  PLA  $68  *********************

PLA ADDQ.W #1,STK    ;INC SP
 MOVE.B (STK),A    ;PULL A
 SETFLAGS N,Z,0,0
 RET 1

*******************************************

**********  PLP  $28  *********************

PLP ADDQ.W #1,STK    ;INC SP
 MOVE.B (STK),FLAGS      ;PULL FLAGS
 RET 1

*******************************************

***********  ROL ACCUMULATOR $2A  *********

ROLAC BTST #CB,FLAGS     ;CHECK FOR CARRY SET
 BEQ.S 2$
 OR.B #XX,CCR      ;SET THE X BIT SO THAT WE CAN EMULATE ROL THRO CARRY
 ROXL.B #1,A      ;DO A ROL
 BRA.S 1$
2$  ASL.B #1,A   ;ASL A AS NO CARRY TO MOVE IN
1$ SETFLAGS N,Z,0,C
 RET 1

*******************************************

**********  ROL ZEROPAGE  $26  ************

ROLZ ZEROPAGE
 MOVE.B 0(OFF,D6.L),D7    ;PICK UP BYTE TO BE ROTATED

 BTST #CB,FLAGS
 BEQ.S 2$
 OR.B #XX,CCR ;SET X FLAG
 ROXL.B #1,D7
 BRA.S 1$
2$  ASL.B #1,D7      ;ASL BYTE
1$ SETFLAGS N,Z,0,C
 MOVE.B D7,0(OFF,D6.L)  ;STORE BACK ASL BYTE IN MEMORY(AFTER FLAGS SET)
 RET 2

*******************************************

********** ROL ZEROPAGE,X  $36  ***********

ROLZX ZEROPAGEX
 MOVE.B 0(OFF,D6.L),D7    ;PICK UP BYTE TO BE ROTATED
 BTST #CB,FLAGS ;CHECK FOR CARRY
 BEQ.S 2$
 OR.B #XX,CCR
 ROXL.B #1,D7
 BRA.S 1$
2$ ASL.B #1,D7
1$ SETFLAGS N,Z,0,C
 MOVE.B D7,0(OFF,D6.L)     ;STORE BACK ASL BYTE IN MEMORY
 RET 2

*******************************************

**********  ROL ABSOLUTE  $2E  ************

ROLA ABS
 MOVE.B 0(OFF,D6.L),D7      ;PICK UP BYTE TO BE ROTATED
 BTST #CB,FLAGS
 BEQ.S 2$
 OR.B #XX,CCR
 ROXL.B #1,D7
 BRA.S 1$
2$  ASL.B #1,D7
1$ SETFLAGS N,Z,0,C
 MOVE.B D7,0(OFF,D6.L)  ;STORE BACK BYTE
 RET 3

*******************************************

**********  ROL ABSOLUTE,X  $3E  **********

ROLAX ABSX
 MOVE.B 0(OFF,D6.L),D7    ;BYTE TO BE ROTATED
 BTST #CB,FLAGS    ;CHECK CARRY
 BEQ.S 2$
 OR.B #XX,CCR    ;SET X FLAG
 ROXL.B #1,D7
 BRA.S 1$
2$ ASL.B #1,D7
1$  SETFLAGS N,Z,0,C
 MOVE.B D7,0(OFF,D6.L)  ;STORE BACK BYTE
 RET 3

*******************************************

***********  ROR ACCUMULATOR $6A  *********

RORAC BTST #CB,FLAGS     ;CHECK FOR CARRY SET
 BEQ.S 2$
 OR.B #XX,CCR      ;SET THE X BIT SO THAT WE CAN EMULATE ROR THRO CARRY
 ROXR.B #1,A      ;DO A ROR
 BRA.S 1$
2$  LSR.B #1,A   ;LSR A AS NO CARRY TO MOVE IN
1$ SETFLAGS N,Z,0,C
 RET 1

*******************************************

**********  ROR ZEROPAGE  $66  ************

RORZ ZEROPAGE
 MOVE.B 0(OFF,D6.L),D7    ;PICK UP BYTE TO BE SHIFTED
 BTST #CB,FLAGS
 BEQ.S 2$
 OR.B #XX,CCR ;SET X FLAG
 ROXR.B #1,D7
 BRA.S 1$
2$  LSR.B #1,D7      ;ROTATE BYTE
1$ SETFLAGS N,Z,0,C
 MOVE.B D7,0(OFF,D6.L)  ;STORE BACK LSR BYTE IN MEMORY(AFTER FLAGS SET)
 RET 2

*******************************************

********** ROR ZEROPAGE,X  $76  ***********

RORZX ZEROPAGEX
 MOVE.B 0(OFF,D6.L),D7    ;PICK UP BYTE TO BE ROR
 BTST #CB,FLAGS ;CHECK FOR CARRY
 BEQ.S 2$
 OR.B #XX,CCR
 ROXR.B #1,D7
 BRA.S 1$
2$ LSR.B #1,D7
1$ SETFLAGS N,Z,0,C
 MOVE.B D7,0(OFF,D6.L)     ;STORE BACK LSR BYTE IN MEMORY
 RET 2

*******************************************

**********  ROR ABSOLUTE  $6E  ************

RORA ABS
 MOVE.B 0(OFF,D6.L),D7      ;PICK UP BYTE TO BE ROR
 BTST #CB,FLAGS
 BEQ.S 2$
 OR.B #XX,CCR
 ROXR.B #1,D7
 BRA.S 1$
2$  LSR.B #1,D7
1$ SETFLAGS N,Z,0,C
 MOVE.B D7,0(OFF,D6.L)  ;STORE BACK BYTE
 RET 3

*******************************************

**********  ROR ABSOLUTE,X  $7E  **********

RORAX ABSX
 MOVE.B 0(OFF,D6.L),D7    ;BYTE TO BE ROR
 BTST #CB,FLAGS    ;CHECK CARRY
 BEQ.S 2$
 OR.B #XX,CCR    ;SET X FLAG
 ROXR.B #1,D7
 BRA.S 1$
2$ LSR.B #1,D7
1$  SETFLAGS N,Z,0,C
 MOVE.B D7,0(OFF,D6.L)     ;PUT BACK BYTE
 RET 3


*******************************************

**********  RTI  $40  *********************

RTI SUB.L D6,D6
 ADDQ.W #1,STK    ;INC SP
 MOVE.B (STK),FLAGS    ;PULL FLAGS
 ADDQ.W #1,STK    ;INC SP
 MOVE.B (STK),D6      ;POP PC LSB
 ASL.W #8,D6            ;MOVE UP LSB
 ADDQ.W #1,STK    ;INC SP
 MOVE.B (STK),D6    ;PICK UP PC MSB
 ROR.W #8,D6         ;MOVE LSB/MSB INTO CORRECT POSITIONS
 MOVE.L D6,PRC
 RTS

*******************************************

********** RTS  $60  **********************

RTSS SUB.L D6,D6
 ADDQ.W #1,STK      ;INC SP
 MOVE.B (STK),D6   ;PULL PC LSB
 ASL.W #8,D6     ;MOVE UP LSB
 ADDQ.W #1,STK    ;INC SP
 MOVE.B (STK),D6    ;PICK UP MSB
 ROR.W #8,D6         ;PUT MSB/LSB IN CORRECT POSITIONS
 ADDQ.W #1,D6        ;POINT TO NEXT INSTRUCTION
 MOVE.L D6,PRC
 RTS


*******************************************

**********  SEC  $38  *********************

SEC OR.B #%00000001,FLAGS  ;SET CARRY
 RET 1

*******************************************

**********  SED  $F8  *********************

SED OR.B #%00001000,FLAGS     ;SET DECIMAL
 RET 1

*******************************************

**********   SEI  $78  ********************

SEI  OR.B #%00000100,FLAGS    ;SET INT FLAG
 RET 1

*******************************************

**********  STX ZEROPAGE  $86  ************

STXZ ZEROPAGE
 MOVE.B X,0(OFF,D6.L)    ;STORE X
 RET 2

*******************************************

**********  STX ZEROPAGE,Y  $96  **********

STXZY ZEROPAGE
 ADD.B Y,D6    ;ADD IN INDEX Y OFFSET
 MOVE.B X,0(OFF,D6.L)    ;STORE X
 RET 2

*******************************************

**********  STX ABSOLUTE  $8E  ************

STXA ABS
 MOVE.B X,0(OFF,D6.L)      ;STORE X
 RET 3

*******************************************

**********  STY ZEROPAGE  $84  ************

STYZ ZEROPAGE
 MOVE.B Y,0(OFF,D6.L)    ;STORE Y
 RET 2

*******************************************

**********  STY ZEROPAGE,X  $94  **********

STYZX ZEROPAGEX
 MOVE.B Y,0(OFF,D6.L)    ;STORE Y
 RET 2

*******************************************

**********  STY ABSOLUTE  $CE  ************

STYA ABS
 MOVE.B Y,0(OFF,D6.L)     ;STORE Y
 RET 3

*******************************************

**********  TAX  $AA  *********************

TAX MOVE.B A,X
 SETFLAGS N,Z,0,0
 RET 1

*******************************************

**********  TAY  $A8  *********************

TAY MOVE.B A,Y
 SETFLAGS N,Z,0,0
 RET 1

*******************************************

**********  TYA  $98  *********************

TYA MOVE.B Y,A
 SETFLAGS N,Z,0,0
 RET 1

*******************************************

**********  TSX  $BA  *********************


TSX MOVE.W STK,D6  ;MUST BE A WORD MOVE
 MOVE.B D6,X       ;BUT WE ARE ONLT INTERESTED IN THE BYTE PART
 SETFLAGS N,Z,0,0
 RET 1

*******************************************

**********  TXA  $8A  *********************

TXA MOVE.B X,A
 SETFLAGS N,Z,0,0
 RET 1

*******************************************

**********  TXS  $9A  *********************


TXS MOVE.L STK,D6
 MOVE.B X,D6         ;6502 STACK IS 8 BITS RESIDING AT PAGE 2
 MOVE.L D6,STK    ;UPDATE STACK
 RET 1

*******************************************

**********  BCC $90  **********************

BCCC BRANCH CB,BNE

*******************************************

**********  BCS $B0  **********************

BCSS BRANCH CB,BEQ

*******************************************

**********  BEQ  $F0  *********************

BEQQ BRANCH ZB,BEQ

*******************************************

**********  BNE $D0  **********************

BNEE BRANCH ZB,BNE

*******************************************

**********  BMI $30  **********************

BMII BRANCH NB,BEQ

*******************************************

**********  BPL $10  **********************

BPLL BRANCH NB,BNE

*******************************************

**********  BVC $50  **********************

BVCC BRANCH VB,BNE

*******************************************

**********  BVS $70  **********************

BVSS BRANCH VB,BEQ

*******************************************

**********  JMP  ABSOLUTE  $4C  ***********

JMPA SUB.L D6,D6
 MOVE.B 2(PRC,OFF.L),D6  ;PICK UP MSB
 ASL.W #8,D6     ;MOVE MSB UP
 MOVE.B 1(PRC,OFF.L),D6      ;PICK UP LSB
 MOVE.L D6,PRC    ;PC= JUMP ADDRESS
 BSR OSCALL    ;ARE WE JUMPING TO AN OS ROUTINE THAT WE CAN SERVICE?
 BEQ.S 1$      ;NOT AN OS CALL IF RETURN WITH ZERO SET
 JMP RTSS
1$ RTS

*******************************************

**********  JMP INDIRECT  $6C  ************

JMPI SUB.L D7,D7     ;CLEAR D7
 SUB.L D6,D6      ;CLEAR D6
 MOVE.B 2(PRC,OFF.L),D6    ;PICK UP MSB
 ASL.W #8,D6
 MOVE.B 1(PRC,OFF.L),D6    ;PICK UP LSB
 CMP.W #$20E,D6
 BNE.S 2$         ;NOT THE VECTOR ADDRESS FOR OSWRCH
 MOVE.L #$FFEE,PRC      ;POINT TO OSWRCH
 BRA.S 3$
2$ MOVE.B 1(OFF,D6.L),D7    ;PICK UP MSB OF JUMP ADDRESS
 ASL.W #8,D7
 MOVE.B 0(OFF,D6.L),D7    ;PICK UP LSB OF JUMP ADDRESS
 MOVE.L D7,PRC    PC= JUMP ADDRESS
3$ BSR.S OSCALL    ;IS IT A OS ADDRESS ?
 BEQ.S 1$      ;NOT AN OS CALL
 JMP RTSS      ;RETURN FROM ROUTINE
1$ RTS

*******************************************

********** JSR $20  ***********************

JSRR SUB.L D6,D6
 ADDQ.W #2,PRC    ;PC POINTS TO NEXT INSTRUCTION -1
 MOVE.W PRC,D6      ;TRANSFER TO D6 AS WE ARE WORKING IN BYTES
 ROR.W #8,D6      ;MOVE DOWN MSB
 MOVE.B D6,(STK)   ;PUSH PC MSB
 ROR.W #8,D6     ;MOVE UP MSB
 SUBQ.W #1,STK    ;DEC SP
 MOVE.B D6,(STK)    ;PUSH PC LSB
 SUBQ.W #1,STK    ;DEC SP
 MOVE.B 0(PRC,OFF.L),D6   ;PICK UP JSR ADDRESS MSB
 ASL.W #8,D6     ;MOVE UP TO MSB
 MOVE.B -1(PRC,OFF.L),D6   ;D6 NOW = SUB ROUTINE ADDRESS
 MOVE.L D6,PRC    PC=SUB ROUTINE ADDRESS
 BSR.S OSCALL       ;IS IT A OS CALL?
 BEQ.S 1$        ;NO OS CALL
 JMP RTSS         ;DO A RTS FROM ROUTINE
1$ RTS

*******************************************

*   OSCALL EMULATES THE BBC OPERATING SYSTEM


******************************************


LF EQU 10
CR EQU 13
ESC EQU 27
DEL EQU 127


OSCALL MOVE.L PRC,D1    ;PICK UP PC
 CMP.W #$FFB9,D1
 BLT.S NOTOS      ;NOT AN OS CALL
 BEQ OSRDRM       ;READ A BYTE FROM SIDEWAYS ROM
 CMP.W #$FFF4,D1
 BEQ OSBYTE    ;OSBYTE CALL
 CMP.W #$FFF1,D1
 BEQ OSWORD    ;OSWORD CALL
 CMP.W #$FFEE,D1
 BEQ OSWRCH    ;WRITE CHAR TO CURRENT STREAM
 CMP.W #$FFE0,D1
 BEQ OSRDCH    ;READ CHAR FROM CURRENT STREAM
 CMP.W #$FFE7,D1
 BEQ OSNEWL    ;DO A CRLF
 CMP.W #$FFE3,D1
 BEQ OSASCI    ;WRITE CHAR IF NOT CRLF ELSE CRLF
 CMP.W #$FFCB,D1
 BEQ NVWRCH    ;NON VECTORED WRITE CHAR
 CMP.W #$FFC8,D1
 BEQ NVRDCH    ;NON VECTORED READ CHAR
 MOVEQ #1,D0      ;SET FLAG TO ENSURE THAT A RTSS IS CARRIED OUT
 RTS

NOTOS SUB.L D0,D0    ;CLEAR FLAG TO ENSURE THAT A RTSS IS NOT PERFORMED
 RTS


********************************************


*  OSWRCH WRITES A CHAR IN A TO THE CURRENT STREAM SELECTED.
*  THE VALUE HELD IN $27C(OFF) IS THE FLAG BYTE THAT HOLDS THE STREAM
*  FLAGS AS FOLLOWS:

*           BIT 0  ENABLE RS232
*           BIT 1  DISABLE VDU DRIVER
*           BIT 3  ENABLE PRINTER
*

* A 1 IN A BIT POSITION SELECTS THAT OPTION


*  THE ASCII VALUES BELOW 32 ARE CONVERTED TO THOSE OF THE BBC WHERE POSSIBLE
*  ELSE THEY ARE IGNORED.  THE NEW VALUE IS FOUND IN A LOOK UP TABLE. EACH
*  ENTRY CONSISTS OF TWO BYTES, THE FIRST IS THE CONTROL CODE AND THE SECOND
*  IS THE NUMBER OF PARAMETERS THAT THE C CODE NEEDS, CAN BE ZERO.




OSWRCH MOVEM.L D0-D4/A0-A2,-(SP)   ;SAVE REG
 CLR.L D4
 MOVE.W PCOUNT,D0    ;PICK UP PARAMETER COUNT
 BNE PARM         ;YES ITS A PARAM
 CLR.L CCJUMP      ;ZERO OUT JUMP VECTOR FOR THE CONTROL CODE ROUTINE
 MOVE.B A,D4         ;SAVE A IN D4
 CMP.B #" ",D4
 BCC PCHAR     ;NOT A CONTROL CODE
 MOVE.L #CCTAB,A0   ;NEW CONTROL CODE TABLE
 SUB.L D2,D2
 MOVE.B D4,D2   ;PICK UP CONTROL CODE NUMBER
 ADD.W D2,D2   ;DOUBLE OFFSET
 MOVE.B 1(A0,D2.W),D4     ;PICK UP PARAM COUNT
 MOVE.W D4,PCOUNT    ;SAVE IT
 MOVE.B 0(A0,D2.W),D4      ;PICK UP NEW C CODE
 BEQ EX1    ;CANT PROCESS IF ZERO
 CMP.B #9,D4
 BEQ MR1    ;CURSOR RIGHT 1 PLACE
 CMP.B #12,D4
 BEQ CLS    ;CLS
 CMP.B #17,D4
 BEQ INK    ;SET THE INK COLOUR TO PARAMETER THAT FOLLOWS
 CMP.B #$1E,D4
 BEQ HOME      ;HOME CURSOR
 CMP.B #2,D4
 BEQ PON    ;ENABLE THE PRINTER
 CMP.B #3,D4
 BEQ POFF      ;DISABLE THE PRINTER
 CMP.B #$1F,D4
 BEQ TAB    ;TAB CURSOR SET BY NEXT 2 PARAMETERS
PCHAR MOVE.W D4,D0  ;CHAR TO BE OUPUT IN D0
 AND #$7F,D0   ;CONVERT TO ASCII ONLY
 BSR.S OUTCHAR    ;PRINT CHAR
 BRA.S EX1


PON BSET #3,$27C(OFF)      ;SET PRINTER ENABLE
 BRA.S EX1

POFF BCLR #3,$27C(OFF)     ;TURN OFF PRINTER
 BRA.S EX1


PARM SUBQ.W #1,PCOUNT      ;DEC PARAMETER COUNT
 MOVE.L CCJUMP,D0    ;PUT INTO DATA REG TO EFFECT FLAGS
 BEQ.S EX1     ;CANT SERVICE THIS C CODE ALTHOUGH ITS GOT PARAMETERS
 MOVE.L D0,A0
 JSR (A0)      ;ELSE SERVICE THE ROUTINE
 BRA.S EX1



OUTCHAR MOVEM.L D1/D4,-(SP)      ;SAVE REG
 MOVE.B $27C(OFF),D4    ;PICK UP STREAM SELECT BYTE
 BTST #0,D4
 BEQ.S 1$     ;RS232 OFF
 MOVE.W #1,D1     ;DEVICE NUMBER TO DRIVE 232
 BSR.S BCONOUT    ;WRITE CHAR
1$ BTST #1,D4
 BNE.S 2$      ;VDU OFF
 MOVE.W #2,D1     ;DEVICE NUMBER TO DRIVE VDU
 BSR.S BCONOUT    ;WRITE CHAR
2$ BTST #3,D4
 BEQ.S 3$      ;PRINTER OFF
 MOVE.W #0,D1     ;DEVICE NUMBER TO DRIVE PRINTER
 BSR.S BCONOUT    ;WRITE CHAR TO PRINTER
3$ MOVEM.L (SP)+,D1/D4
 RTS

BCONOUT MOVEM.L D0-D4/A2,-(SP)
 MOVE.W D0,-(SP)     ;CHAR TO BE PRINTED
 MOVE.W D1,-(SP)     ;DEVICE CODE
 MOVE.W #3,-(SP)     ;BCONOUT CODE
 TRAP #13
 ADDQ.L #6,SP     ;TIDY STACK
 MOVEM.L (SP)+,D0-D4/A2
 RTS

EX1 MOVEM.L (SP)+,D0-D4/A0-A2
 MOVEQ.L #1,D0    ;FLAG RTSS
 RTS



MR1 MOVE.W #ESC,D0
 BSR OUTCHAR     ;OUTPUT ESC
 MOVE.W #"C",D0      ;CURSOR RIGHT
 BSR.S OUTCHAR
 BRA.S EX1


CLS MOVE.W #ESC,D0   ;
 BSR.S OUTCHAR    ;OUTPUT ESC
 MOVE.W #"E",D0
 BSR.S OUTCHAR    ;CLS
 BRA.S EX1


HOME MOVE.W #ESC,D0
 BSR.S OUTCHAR    ;OUTPUT ESC
 MOVE.W #"H",D0
 BSR.S OUTCHAR    ;HOME CURSOR
 BRA.S EX1


INK MOVE.L #INKREENT,CCJUMP      ;SET REENTRY VECTOR
 BRA EX1

INKREENT MOVE.W RES,D0     ;PICK UP SCREEN RESOLUTION
 CMP.W #2,D0
 BNE.S 2$      ;NOT HIGH RES
 RTS     ;DONT CHANGE INK IN HIGH RES

2$ MOVE.W #ESC,D0
 BSR OUTCHAR
 MOVE.B #"b",D0   ;SET INK
 TST.B A
 BPL 3$     ;BIT 7 SET IF PAPER TO BE SET
 MOVE.B #"c",D0   ;SET PAPER
3$ BSR OUTCHAR
 MOVE.B A,D0
 AND #$7F,D0
 BSR OUTCHAR      ;SET COLOUR
 RTS


TAB MOVE.L #TABREENT,CCJUMP      ;REENTRY VECTOR
 MOVE.W #ESC,D0      ;ESC CODE
 BSR OUTCHAR
 MOVE.W #"Y",D0
 BSR OUTCHAR      ;TAB CURSOR
 BRA EX1

TABREENT MOVE.W PCOUNT,D0
 BEQ 1$     ;MUST BE Y POS IN A IF LAST PARAMTER
 MOVE.B A,XPOS    ;ELSE MUST BE X POS SO SAVE
 RTS

1$ MOVE.B A,D0
 ADD.B #32,D0     ;ADD 32 OFFSET AS ATARI REQUIRES IT
 BSR OUTCHAR
 MOVE.B XPOS,D0
 ADD.B #32,D0     ;AGAIN ADD OFFSET
 BSR OUTCHAR
 RTS



CCJUMP DC.L 0     ;REENTRY VECTOR
PCOUNT DC.W 0     ;PARAMETER COUNT
RES    DC.W 0     ;RESOLUTION STORE
XPOS   DC.B 0     ;TEMP X POS
YPOS   DC.B 0     ;TEMP Y POS


************* CONTROL CODE TABLE**************8

*  FIRST BYTE IS CONTROL CODE
*  SECOND BYTE IS PARAMETER COUNT

CCTAB DC.B 0,0    ;0 NU
 DC.B 0,1         ;1 NU
 DC.B 2,0         ;2 PRINTER ON
 DC.B 3,0         ;3 PRINTER OFF
 DC.B 0,0         ;4 NU
 DC.B 0,0         ;5 NU
 DC.B 0,0         ;6 NU
 DC.B 7,0         ;7 BELL
 DC.B 8,0         ;8 BS
 DC.B 9,0         ;9 CURSOR RIGHT
 DC.B 10,0        ;10 LF
 DC.B 11,0        ;11 CURSOR UP
 DC.B 12,0        ;12 CLS
 DC.B 13,0        ;13 CR
 DC.B 0,0         ;14 NU
 DC.B 0,0         ;15 NU
 DC.B 0,0         ;16 NU
 DC.B 17,1        ;17 INK
 DC.B 0,2         ;18 NU
 DC.B 0,0         ;19 NU
 DC.B 0,0         ;20 NU
 DC.B 0,0         ;21 NU
 DC.B 0,1         ;22 NU
 DC.B 0,9         ;23 NU
 DC.B 0,8         ;24 NU
 DC.B 0,5         ;25 NU
 DC.B 0,0         ;26 NU
 DC.B 27,1        ;27 ESC
 DC.B 0,4         ;28 NU
 DC.B 0,4         ;29 NU
 DC.B 30,0        ;30 HOME CURSOR
 DC.B 31,2        ;31 TAB



***************************************


*  OSRDCH READS CHAR INTO A FROM CURRENT STREAM
*  IN THIS CASE ONLY THE VDU FOR NOW

 CNOP 0,2   ;ALIGN TO EVEN ADDRESS


OSRDCH BSR.S RDCH
 MOVEQ #1,D0      ;SET RTSS FLAG
 RTS

RDCH MOVEM.L D2/A0-A2,-(SP)    ;SAVE REG
 MOVE.W #2,-(SP)  ;READ FROM KEYBOARD
 MOVE.W #2,-(SP)  ;CONIN
 TRAP #13
 ADDQ.L #4,SP  ;TIDY STACK
 MOVEM.L (SP)+,D2/A0-A2 ;POP REG
 MOVE.B D0,A      ;PUT BYTE INTO A
 CMP.B #ESC,D0
 BEQ.S 1$      ;ESC CODE
 AND.B #%11111110,FLAGS ;CLEAR CARRY MEANING A GOOD READ
 RTS

1$ OR.B #%00000001,FLAGS   ;TELL OS ESC PRESSED
 RTS



************************************

*  OSNEWL  DOES A CRLF



OSNEWL BSR.S NEWL
 MOVEQ #1,D0      ;FLAG RTSS
 RTS

NEWL MOVE.B #LF,A ;DO A LF
 BSR OSWRCH
 MOVE.B #CR,A     ;DO A CR
 BSR OSWRCH
 RTS


************************************

*  OSASCI  DOES A CRLF IF A=13 ELSE PRINTS CHAR


OSASCI BSR.S ASCI
 MOVEQ #1,D0      ;FLAG RTS
 RTS

ASCI CMP.B #CR,A     ;IS IT A CR?
 BEQ.S NEWL    ;YES
 BRA OSWRCH    ;ELSE JUST PRINT IT


***********************************

*  OSRDRM READS A BYTE FROM SIDEWAYS ROM
*  LOCATIONS $F6 $F7 HOLD ADDRESS
*  RETURN WITH BYTE IN A


OSRDRM BSR.S RDRM
 MOVEQ #1,D0      ;FLAG RTSS
 RTS

RDRM MOVE.B Y,D0     ;Y=ROM NUMBER
 BEQ.S 1$      ;WE ARE WORKING IN ROM 0 SO GIVE GOOD READ ELSE GIVE $FF
 MOVE.B #$FF,A    ;GIVE A DEFAULT VALUE
 RTS

1$ SUB.L D0,D0
 MOVE.W $F6(OFF),D0  ;PICK UP ADDRESS
 ROL.W #8,D0      ;CONVERT TO 6502 FORMAT
 MOVE.B 0(OFF,D0.L),A      ;PICK UP BYTE
 RTS


****************************************

*  OSBYTE CALLS ARE WITH THE CALL NUMBER IN A AND ANY
*  PARAMETERS IN X AND Y ,ONLY A SELECTION ARE IMPLEMENTED AT THE MO


OSBYTE BSR.S BYTE
 MOVEQ #1,D0      ;FLAG RTSS
 RTS

BYTE CMP.B #3,A
 BEQ OB3    ;SET O/P STREAM
 CMP.B #$13,A
 BEQ OB13      ;WAIT FOR SYNC
 CMP.B #$79,A
 BEQ OB79      ;K/B SCAN
 CMP.B #$81,A
 BEQ OB81      ;READ KEY WITH TIME LIMIT
 CMP.B #$83,A
 BEQ OB83      ;OSHWM
 CMP.B #$84,A
 BEQ OB84      ;HIMEM
 CMP.B #$7E,A
 BEQ OB7E      ;ACK ESC
 CMP.B #$86,A
 BEQ OB86      ;FETCH VPOS,XPOS
 CMP.B #$8E,A
 BEQ OB8E      ;ENTER LANGUAGE ROM
 CMP.B #$76,A
 BEQ OB76      ;CHECK FOR CNTL
 RTS           ;CANT SERVICE ANY MORE AT PRESENT SO LEAVE



****************************************

* SET OUTPUT STREAM

OB3 MOVE.B $27C(OFF),X    ; OLD STATUS IN X
 MOVE.B A,$27C(OFF)     ;INSERT NEW STATUS
 RTS

****************************************

* WAIT FOR SYNC

OB13 MOVEM.L D0-D2/A0-A2,-(SP)  ;SAVE REG
 MOVE.W #37,-(SP)
 TRAP #14      ;WAIT FOR SYNC
 ADDQ.L #2,SP
 MOVEM.L (SP)+,D0-D2/A0-A2      ;POP REG
 RTS


***************************************

* READ CHAR BUT DONT WAIT FOR IT

OB81 SUB.L D7,D7
4$ MOVE.W #$FF,-(SP)     ;READ K/B
 MOVE.W #6,-(SP)
 TRAP #1    ;FETCH KEY
 ADDQ.L #4,SP
 OR.B D0,D7    ;OR IN KEY PRESS
 BNE.S 5$      ;KEY PRESSED
 SUBQ.B #1,Y      ;LOOP FOR Y TIMES
 BNE.S 4$
5$ MOVE.B D7,D0
 CMP.B #ESC,D0
 BEQ.S 1$      ;ESC PRESSED
 TST.W D0
 BEQ.S 2$      ;NO KEY PRESSED
 MOVE.B D0,X   ;KEY IN X
 SUB.L Y,Y     ;CLEAR Y,MEANS CHAR READ,NOT ESC
 AND.B #%11111110,FLAGS    ;CLEAR C
 RTS

1$ MOVE.B D0,Y    ;ESC IN Y
3$ OR.B #$00000001,FLAGS      ;SET CARRY
 RTS

2$ MOVE.B #$FF,Y     ;NO KEY PRESSED
 BRA.S 3$


****************************************

*  FETCH OSHWM  SET TO $E00 ON BASIC BBC MACHINE

OB83 MOVE.B #$0E,Y      ;MSB IN Y
 MOVE.B #$0,X     ;LSB IN X
 RTS



***************************************

*  FETCH HIMEM  SET TO $7C00 ON  MODE 7 BBC

OB84 MOVE.B #$7C,Y      ;MSB IN Y
 MOVE.B #0,X      ;LSB IN X
 RTS


***************************************

*  ENTER LANGUAGE ROM, PUT COPYRIGHT MESSAGE POINTER IN $FD
*  MAKE A=1

OB8E SUB.L D0,D0
 MOVE.B $8007+ZERO6502,D0  ;PICK UP COPYRIGHT OFFSET FROM START OF ROM
 ADD.W #$8000,D0    ;D0 POINTS TO MESSAGE
 MOVE.B D0,$FD(OFF)     ;STORE IN $FD
 ROR.W #8,D0      ;MOVE DOWN MSB
 MOVE.B D0,$FE(OFF)  ;STORE IN $FE
 MOVE.B #1,A    ;A=1
 MOVE.B #3,(STK)     ;LSB OF ENTRY ADDRESS
 SUBQ.W #1,STK    ;DEC SP
 MOVE.B #$80,(STK)   ;MSB OF ENTRY ADDRESS
 SUBQ.W #1,STK    ;DEC SP
 RTS



***************************************

*   GET POS VPOS ,CANT SERVICE YET SO GIVE DEFAULT VALUES

OB86 MOVE.B #10,X    ;XPOS
 MOVE.B #10,Y     ;YPOS
 RTS


***************************************

*  KEY SCAN  ONLY INTERESTED IN SHIFT AT MOMENT

OB79 MOVE.W D2,-(SP) ;SAVE D2
 MOVE.W #-1,-(SP)    ;GET STATUS OF KEYS
 MOVE.W #11,-(SP)
 TRAP #13
 ADDQ.L #4,SP
 AND.B #3,D0      ;MASK OUT SHIFT KEYS
 BEQ.S 1$      ;NOT PRESSED
2$ MOVE.W (SP)+,D2  ;RESTORE D2
 RTS

1$ EOR.B #$80,X      ;RESET BIT 7 OF X,THUS TELLING OS KEY PRESSED
 BRA.S 2$



***************************************

* GET CNTL STATUS

OB76 MOVE.W D2,-(SP)    ;SAVE D2
 MOVE.W #-1,-(SP)    ;GET K/B STATUS
 MOVE.W #11,-(SP)
 TRAP #13
 ADDQ.L #4,SP
 AND.B #%00000100,D0 ;MASK IN CONTROL KEY
 BNE.S 1$      ;KEY PRESSED
 AND.B #%01111111,X     ;RESET BIT 7 IE NO CNTL
2$ MOVE.W (SP)+,D2      ;POP D2
 RTS

1$ OR.B #%10000000,X    ;SET BIT 7 OF X IE CNTL PRESSED
 BRA.S 2$


***************************************

*  ACK ESC PRESSED

OB7E MOVE.B #$FF,X      ;ACK ESC
 RTS

***************************************


OSWORD CMP.B #0,A
 BNE 1$      ;CANT SERVICE IT YET
 SUB.L D6,D6      ;CLEAR D6
 MOVE.B Y,D6      ;Y=MSB OF PARAMETER BLOCK ADDRESS
 ASL.W #8,D6      ;MOVE UP MSB
 MOVE.B X,D6      ;X=LSB OF PARAMETER BLOCK ADDRESS
 MOVE.L D6,A2     ;A2 POINTS TO PARAMTER BLOCK
 MOVE.B 1(OFF,A2.L),D6   ;PICK UP MSB OF BUFFER ADDRESS
 ASL.W #8,D6      ;MOVE UP TO MSB
 MOVE.B 0(OFF,A2.L),D6   ;PICK UP LSB OF BUFFER ADDRESS
 MOVE.L D6,A1     ;A1 POINTS TO BUFFER ADDRESS
 SUB.L Y,Y         ;Y=LINE LENGTH
2$ BSR OSRDCH       ;PICK UP CHAR FROM KEYBOARD IN A
 CMP.B #3,A     ;CONTROL C?
 BEQ EXIT      ;YES SO BACK TO DESKTOP
 CMP.B #ESC,A
 BEQ.S 1$           ;ESC PRESSED
 CMP.B #DEL,A     ;CHECK FOR DELETE
 BNE.S 3$      ;NOT A DELETE
 TST.B Y       ;CHECK LINE LENGTH NOT ZERO
 BEQ.S 2$      ;IF IT IS DONT DELETE CHAR AS BUFFER IS EMPTY
 MOVE.W #8,A
 BSR OSWRCH    ;BACK SPACE
 MOVE.W #" ",A
 BSR OSWRCH    ;DELETE CHAR
 MOVE.W #8,A
 BSR OSWRCH    ;BACK SPACE
 SUBQ.B #1,Y      ;DEC LINE LENGTH
 SUBQ.L #1,A1     ;DEC BUFFER
 BRA.S 2$
3$ CMP.B 2(OFF,A2.L),Y    ;CHECK TO SEE IF BUFFER FULL
 BNE.S 4$         ;IF EQUAL RING BELL AND LOOP BACK AND WAIT FOR ESC OR DEL
 MOVE.W #7,A
 BSR OSWRCH       ;SOUND BELL
 BRA.S 2$
4$ BSR OSASCI     ;PRINT CHAR
 MOVE.B A,0(OFF,A1.L)  ;STORE CHAR IN BUFFER
 ADDQ.B #1,Y         ;INC BUFFER LENGTH
 ADDQ.L #1,A1          ;INC BUFFER
 CMP.B #CR,A
 BNE.S 2$            ;LOOP BACK IF NOT CR IE END OF LINE
1$ MOVEQ #1,D0    ;SET RTSS FLAG
 RTS                 ;6502 CARRY SET IF LINE TERMINATED BY A ESC



***************************************


NVWRCH JMP OSWRCH


***************************************


NVRDCH JMP OSRDCH


***************************************

* OSCLI  NOT YET SERVICED

OSCLI MOVEQ #1,D0    ;FLAG RTSS
 RTS

***************************************


 END
