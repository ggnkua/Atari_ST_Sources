         TTL      DRWCRC - 15 Sep 87

         INCLUDE  "TOS.ASM"
         INCLUDE  "EQU.ASM"

         XREF     CDRW

* Start of Program

START

* Read CR File Top Half

         MOVE     #$2,-(A7)       Open CR File
         MOVE.L   #CRFIL,-(A7)   in Read/Write Mode
         TOS      OPEN,1          .
         ADDQ.L   #8,A7           Restore Stack
         TST      D0              Test for Error
         BMI      ERR             If MI, Error
         MOVE     D0,CRHDL
         MOVE.L   #PALETTE,-(A7)  Read Palette
         MOVE.L   #128,-(A7)      .
         MOVE     CRHDL,-(A7)
         TOS      READ,1          .
         ADD.L    #12,SP          Restore Stack
         MOVE.L   #$70000,-(A7)   Read CR File in Alt Video RAM
         MOVE.L   #32000,-(A7)    .
         MOVE     CRHDL,-(A7)
         TOS      READ,1          .
         ADD.L    #12,SP          Restore Stack
         TST      D0              Test for Error
         BMI      ERR             If MI, Error
         MOVE     CRHDL,-(A7)    Close IN1 File
         TOS      CLOSE,1         .
         ADDQ.L   #4,A7           .
         TST      D0              Test for Error
         BMI      ERR             if MI, Error



* Set F1 Palette

         LEA.L    PAL0,A0        Set F1 Palette
         MOVE.L   A0,-(A7)       .
         TOS      SETPALETTE,14  .
         ADDQ.L   #6,A7          .

* Set Low resolution

         MOVE     #0,-(A7)
         MOVE.L   #-1,-(A7)
         MOVE.L   #-1,-(A7)
         TOS      SETSCREEN,14
         ADD.L    #10,A7

* Change Screen Address to F1 in Low Resolution

         MOVE     #-1,-(A7)
         MOVE.L   #$70000,-(A7)
         MOVE.L   #$70000,-(A7)
         TOS      SETSCREEN,14
         ADD.L    #10,A7

* Draw Circuit in Circuit Window
         LEA.L    CDRW,A1
         CLR      D1
         CLR.L    D2
LOOP     MOVE.L   #$70000,A0
         CLR.L    D0
         MOVE     0(A1,D1),D0    Get CDRW Entry
         BLT      FIN
         ADDA.L   D0,A0          Point to Screen line
         MOVE     2(A1,D1),D0    Get Pixel position in Line
         MOVE     D0,D2
         LSR      #4,D2          Get 4*W Pointer
         MOVE     D2,D3          .
         LSL      #3,D2          .
         ADDA.L   D2,A0          Point to Word on Screen
         LSL      #4,D3
         SUB      D3,D0          Get Word Mask (0 to 15)
         SUB      #15,D0
         NEG      D0
         MOVE     #1,D3          .
         LSL      D0,D3          .
         OR.W     D3,(A0)        White Point
         NOT      D3
         AND.W    D3,2(A0)       White Point
         ADDQ     #4,D1
         BRA      LOOP
FIN

* Write Back to OUT File

         MOVE.W   #0,-(A7)        Create OUT File
         MOVE.L   #OUTFIL,-(A7)   .
         TOS      CREATE,1
         ADDQ.L   #8,A7
         TST      D0              Test for Error
         BMI      ERR             If MI, Yes
         MOVE     D0,OUTHDL       Save Handle
         MOVE.L   #PALETTE,-(A7)  Write Palette Back
         MOVE.L   #128,-(A7)      .
         MOVE     OUTHDL,-(A7)    .
         TOS      WRITE,1         .
         ADD.L    #12,SP          Restore Stack
         MOVE.L   #$70000,-(A7)   Write Video RAM to OUT File
         MOVE.L   #32000,-(A7)    .
         MOVE     OUTHDL,-(A7)
         TOS      WRITE,1         .
         ADD.L    #12,SP          Restore Stack
         TST      D0              Test for Error
         BMI      ERR             If MI, Error
         MOVE     OUTHDL,-(A7)    Close OUT File
         TOS      CLOSE,1         .
         ADDQ.L   #4,A7           .
         TST      D0              Test for Error
         BMI      ERR             if MI, Error
LOO      BRA      LOO             Terminate
ERR      NOP
         NOP
         TOS      TERM,1

* FILES

CRFIL
         DC.B     'A:CR.NEO'
         DC.B     0
         CNOP     0,2
CRHDL   DC.W     1

OUTFIL
         DC.B     'A:OUT.NEO'
         DC.B     0
         CNOP     0,2
OUTHDL   DC.W     1
PALETTE  DS.B     4
PAL0     DS.B     124
         END

