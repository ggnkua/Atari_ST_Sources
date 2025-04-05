**************************************
*                                    *
*  RES_CHK.S ist PD-SOURCE-SOFTWARE  *
*                                    *
*         by G. Gerhardt             *
*            Siekhammer 34           *
*            4930  Detmold           *
*                                    *
**************************************

.TEXT

INSFLAG EQU $300
RAMTOP  EQU $304
CHECKSM EQU $30A

PEA     CHECKDSK
MOVE.W  #38,-(A7)               Supexec
TRAP    #14
ADDQ.L  #6,A7
MOVE.L  D0,A6
MOVE.W  #140,D7                 2 Sekunden warten
BSR     DISPMSG
CLR.W   -(A7)                   Programmende
TRAP    #1

CHECKDSK:
LEA     MSGNOT,A6
CMP.L   #$472E472E,INSFLAG
BNE     CHKX
LEA     MSGBAD,A6
CLR.L   D0                      PrÅfsumme
MOVE.L  $42E,A0                 der gesamten RESDISK berechnen
MOVE.L  RAMTOP,A1

NEWCHK:
MOVE.L  (A0)+,D1
EOR.L   D1,D0
CMP.L   A0,A1                   oberste RAM Adresse erreicht ?
BNE     NEWCHK                  nein
CMP.L   CHECKSM,D0              PrÅfsumme OK ?
BNE     CHKX
LEA     MSGOK,A6

CHKX:
MOVE.L  A6,D0
RTS

DISPMSG:
MOVE.B  (A6)+,D0                Zeichen holen
BEQ     WAIT
MOVE.W  D0,-(A7)
MOVE.W  #2,-(A7)                ausgeben durch
MOVE.W  #3,-(A7)                Bconout
TRAP    #13
ADDQ.L  #6,A7
BRA     DISPMSG                 nÑchstes Zeichen

WAIT:
MOVE.W  #37,-(A7)               Vsync = 1/70 Sekunde warten
TRAP    #14
ADDQ.L  #2,A7
DBF     D7,WAIT
RTS

MSGNOT:
DC.B 27,"E",10,"  RESDISK ist nicht installiert",0

MSGBAD:
DC.B 27,"E ",10,27,"p RESDISK-PrÅfsumme stimmt nicht! ",27,"q",0

MSGOK:
DC.B 27,"E",10,"  RESDISK-PrÅfsumme stimmt",0

