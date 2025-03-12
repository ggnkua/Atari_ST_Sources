         TTL      Arcade Score File Creation - 21 JUL 91

         INCLUDE  'A:TOS.ASM'

         BRA      START

SCORES   DC.L    18000 
         DC.L    16000
         DC.L    14000
         DC.L    12000
         DC.L    10000
         DC.L     8000
         DC.L     6000
         DC.L     4000
         DC.L     2000

STAGES   DC.W     6        9
         DC.W     6
         DC.W     5
         DC.W     5
         DC.W     4
         DC.W     4
         DC.W     3
         DC.W     2
         DC.W     1

PLAYERS  DC.W     0        AAA
         DC.W     0
         DC.W     0

         DC.W     1        BBB
         DC.W     1
         DC.W     1

         DC.W     2        CCC
         DC.W     2
         DC.W     2 

         DC.W     3        DDD
         DC.W     3        
         DC.W     3        

         DC.W     4        EEE
         DC.W     4
         DC.W     4

         DC.W     5        FFF
         DC.W     5
         DC.W     5

         DC.W     6        GGG
         DC.W     6
         DC.W     6

         DC.W     7        HHH
         DC.W     7
         DC.W     7

         DC.W     8        III
         DC.W     8
         DC.W     8

* Write Back to INT File (IMAGE.NEO)

START    MOVE.W   #0,-(A7)        Create INT File
         MOVE.L   #INTFIL,-(A7)   .
         TOS      CREATE,1
         ADDQ.L   #8,A7
         MOVE     D0,INTHDL       Save Handle
         MOVE.L   #SCORES,-(A7)   Write File
         MOVE.L   #108,-(A7)      108 Bytes long
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
         DC.B     'ARCADE.DAT'
         DC.B     0
         CNOP     0,2
INTHDL   DC.W     1

         END
