         TTL      Racing Score File Creation - 25 Jul 90

         INCLUDE  'A:TOS.ASM'

         BRA      START

RSCORES  
BSTLAP   DS.L    6      Minutes/Sec/Cent - Best Lap
         DC.B    -1
         DS.B    7
         DC.B    -1
         DS.B    7
         DC.B    -1
         DS.B    7
         DC.B    -1
         DS.B    7
         DC.B    -1
         DS.B    7
         DC.B    -1
         DS.B    7

TOTLAP   DS.L    6      Minutes/Sec/cent - Best Total Time
         DC.B    -1
         DS.B    7
         DC.B    -1
         DS.B    7
         DC.B    -1
         DS.B    7
         DC.B    -1
         DS.B    7
         DC.B    -1
         DS.B    7
         DC.B    -1
         DS.B    7
 
TOTPNT   DC.W    0     Best Total Points
         DC.B    -1
         DS.B    7

* Write Back to INT File (IMAGE.NEO)

START    MOVE.W   #0,-(A7)        Create INT File
         MOVE.L   #INTFIL,-(A7)   .
         TOS      CREATE,1
         ADDQ.L   #8,A7
         MOVE     D0,INTHDL       Save Handle
         MOVE.L   #RSCORES,-(A7)  Write File
         MOVE.L   #154,-(A7)      154 Bytes long
         MOVE     INTHDL,-(A7)    .
         TOS      WRITE,1         .
         ADD.L    #12,SP          Restore Stack
         TST      D0              Test for Error
         BMI      ERR             If MI, Error
         MOVE     INTHDL,-(A7)    Close INT File
         TOS      CLOSE,1         .
         ADDQ.L   #4,A7           .
         TST      D0              Test for Error
         BMI      ERR             if MI, Error
         TOS      TERM,1          Terminate
ERR      NOP
         NOP
         TOS      TERM,1

INTFIL
         DC.B     'A:RACING.DAT'
         DC.B     0
         CNOP     0,2
INTHDL   DC.W     1

         END
