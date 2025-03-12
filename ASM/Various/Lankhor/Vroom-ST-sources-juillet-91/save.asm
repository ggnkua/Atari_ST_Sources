         TTL      Save Total Creation - 22 Jul 90

         INCLUDE  'A:TOS.ASM'

         BRA      START

SAVGAM   
         DC.B    17,14,12,00,08,13,-1,-1        Me (Romain)
         DC.B    -1,-1,-1,-1,-1,-1,-1,-1        Him
DRVTOT   DC.W    06,03,00,00,04,00,05,00,00,01,02,00,00,00,00,09,-1 GP #1
         DC.W    09,05,00,00,06,02,00,00,00,04,00,00,00,00,01,03,-1 GP #2
         DC.W    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 GP #3
         DC.W    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 GP #4
         DC.W    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 GP #5
         DC.W    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 GP #6
         DC.W    15,08,00,00,10,02,05,00,00,05,02,00,00,00,01,12,-1 Total
         DC.W    4                              End of Circuit # 2
 
* Write Back to File 

START    MOVE.W   #0,-(A7)        Create File
         MOVE.L   #INTFIL,-(A7)   .
         TOS      CREATE,1
         ADDQ.L   #8,A7
         MOVE     D0,INTHDL       Save Handle
         MOVE.L   #SAVGAM,-(A7)   Write File
         MOVE.L   #2+16+(17*14),-(A7) 2+16+(17*14) Bytes long
         MOVE     INTHDL,-(A7)    .
         TOS      WRITE,1         .
         ADD.L    #12,SP          Restore Stack
         TST      D0              Test for Error
         BMI      ERR             If MI, Error
         MOVE     INTHDL,-(A7)    Close File
         TOS      CLOSE,1         .
         ADDQ.L   #4,A7           .
         TST      D0              Test for Error
         BMI      ERR             if MI, Error
         TOS      TERM,1          Terminate
ERR      NOP
         NOP
         TOS      TERM,1

INTFIL
         DC.B     'A:SAVE.DAT'
         DC.B     0
         CNOP     0,2
INTHDL   DC.W     1

         END
