         TTL       BCK.DAT FILE CREATION - 16 SEP 89

         INCLUDE  "TOS.ASM"
         INCLUDE  "EQU.ASM"

* Start of Program

START

* Read NEO File

         LEA.L    NEOFIL,A0      Read NEO File
         MOVE.L   #NEOPAL,A1     Palette
         MOVE.L   #NEOBUF,A2     Image
         MOVE.L   #128,D1        .
         MOVE.L   #160*(4*H2BCKEQU+8*H1BCKEQU),D2      
         MOVE.L   #0,D3          .
         JSR      RDFILE         .
         BMI      ERR

* Write Back BCK File

         MOVE     #0,-(A7)       Create DAT File
         LEA.L    BCKFIL,A0
         MOVE.L   A0,-(A7)       .
         TOS      CREATE,1
         ADDQ.L   #8,A7
         LEA.L    HDL,A0
         MOVE     D0,(A0)        Save Handle
         LEA.L    NEOPAL,A0      Write Palette+BCK
         MOVE.L   A0,-(A7)       .
         MOVE.L   #128+160*(4*H2BCKEQU+8*H1BCKEQU),-(A7)   
         LEA.L    HDL,A0         .
         MOVE     (A0),-(A7)     .
         TOS      WRITE,1        .
         ADDA.L   #12,A7         Restore Stack
         LEA.L    HDL,A0         Close DAT File
         MOVE     (A0),-(A7)     .
         TOS      CLOSE,1        .
         ADDQ.L   #4,A7          .

FIN
ERR
         TOS      TERM,1

* RDFILE - Open-Read File in 3 Steps-Close
* Input: A0 points to File
*        A1 points to 1st Zone Buffer
*        D1 Length
*        A2 points to 2nd Zone Buffer
*        D2 Length (0 = Skip)
*        A3 points to 3rd Zone Buffer
*        D3 Length (0 = Skip)

RDFILE   MOVE     #$2,-(A7)      Open  File
         MOVE.L   A0,-(A7)       in Read Mode
         TOS      OPEN,1         .
         ADDQ.L   #8,A7          Restore Stack
         TST      D0             Test for Error
         BMI      RDFILF            If MI, Error
         MOVE     D0,HDL         Save Handle
         MOVE.L   A1,-(A7)       Read 1st part
         MOVE.L   D1,-(A7)       .
         MOVE     HDL,-(A7)      .
         TOS      READ,1         .
         ADDA.L   #12,A7         Restore Stack
         TST      D0             Test for Error
         BMI      RDFILF            If MI, Error
         MOVE.L   A2,-(A7)       Read 2nd Part
         MOVE.L   D2,-(A7)       .
         BEQ.S    RDFIL1
         MOVE     HDL,-(A7)
         TOS      READ,1         .
         ADDA.L   #4,A7          .
RDFIL1   ADDA.L   #8,A7          Restore Stack
         TST      D0             Test for Error
         BMI      RDFILF            If MI, Error
         MOVE.L   A3,-(A7)       Read 3rd Part
         MOVE.L   D3,-(A7)       .
         BEQ.S    RDFIL2
         MOVE     HDL,-(A7)
         TOS      READ,1         .
         ADDA.L   #4,A7          .
RDFIL2   ADDA.L   #8,A7          Restore Stack
         TST      D0             Test for Error
         BMI      RDFILF            If MI, Error
         MOVE     HDL,-(A7)
         TOS      CLOSE,1        .
         ADDQ.L   #4,A7          .
         TST      D0
RDFILF   RTS                     If MI, Error
HDL      DC.W     0

NEOFIL   DC.B     'CRC.NEO'
         DC.B     0
         CNOP     0,2

BCKFIL   DC.B     'BCK.DAT'
         DC.B     0
         CNOP     0,2

NEOPAL   DS.B     128
NEOBUF   
BCLBUF   DS.B     160*(4*H2BCKEQU+8*H1BCKEQU)

         END

