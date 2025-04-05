**************************************
*                                    *
* RESDISKG.S ist PD-SOURCE-SOFTWARE  *
*                                    *
*         by G. Gerhardt             *
*            Siekhammer 34           *
*            4930  Detmold           *
*                                    *
**************************************

.TEXT

INSFLAG EQU $300
RAMTOP  EQU $304
DSKSIZE EQU $308
CHECKSM EQU $30A

BRA     INITDISK

HDV_BPB:
MOVE.W  DRIVENR,D0
CMP.W   4(A7),D0                RESDISK ?
BEQ     BPBN                    ja
MOVE.L  BPB_VEC,A0              alter hdv_bpb Vektor
JMP     (A0)

BPBN:
MOVE.L  #BPB,D0                 BPB Adresse
RTS

HDV_RW:
MOVE.W  DRIVENR,D0
CMP.W   14(A7),D0               RESDISK ?
BEQ     RWN                     ja
MOVE.L  RW_VEC,A0               alter hdv_rw Vektor
JMP     (A0)

RWN:
MOVE.L  6(A7),A0                Disk-Puffer
MOVE.W  12(A7),D0               Sektornummer
EXT.L   D0
MOVEQ   #9,D1                   2^9=512 Bytes pro Sektor
LSL.L   D1,D0
MOVE.L  RAMTOP,A1               Ramdisk Start
SUB.L   D0,A1                   Sektoradresse
MOVE.W  10(A7),D1               Sektorenanzahl
SUBQ.W  #1,D1
BTST    #0,5(A7)                rwflag
BEQ     READ
MOVEM.L D1/A1,-(A7)
BSR     CHKSUM                  PrÅfsumme Ñndern

WRITE:
MOVE.W  #511,D0                 512 Bytes kopieren

WRITE1:
MOVE.B  (A0)+,-(A1)
DBF     D0,WRITE1
DBF     D1,WRITE                nÑchster Sektor
MOVEM.L (A7)+,D1/A1
BSR     CHKSUM                  PrÅfsumme Ñndern
BRA     RWX

READ:
MOVE.W  #511,D0                 512 Bytes kopieren

READ1:
MOVE.B  -(A1),(A0)+
DBF     D0,READ1
DBF     D1,READ                 nÑchster Sektor

RWX:
CLR.L   D0                      Ok
RTS

HDV_MED:
MOVE.W  DRIVENR,D0
CMP.W   4(A7),D0                RESDISK ?
BEQ     MEDN                    ja
MOVE.L  MED_VEC,A0              alter hdv_mediach Vektor
JMP     (A0)

MEDN:
MOVE.L  MEDIACH,D0              Diskwechsel beim ersten Aufruf
CLR.L   MEDIACH                 danach definitiv nicht
RTS

CHKSUM:
MOVEM.L D0-D3/A1,-(A7)
MOVE.L  CHECKSM,D0              momentane PrÅfsumme holen

CHK1:
MOVEQ   #63,D2                  ein Sektor

CHK2:
MOVE.L  -(A1),D3                Daten xor verknÅpfen
EOR.L   D3,D0
MOVE.L  -(A1),D3
EOR.L   D3,D0
DBF     D2,CHK2
DBF     D1,CHK1                 nÑchster Sektor
MOVE.L  D0,CHECKSM              neue PrÅfsumme merken
MOVEM.L (A7)+,D0-D3/A1
RTS

BPB:
DC.W $0200,$0002                recsiz,clsiz
DC.W $0400,$0007                clsizb,rdlen
DC.W $0005,$0006                fsiz,fatrec
DC.W $0012,$FFFF                datrec,numcl wird richtig gesetzt
DC.W $0000,$0000                bflags,ntracks
DC.W $0000,$0000                nsides,dspc
DC.W $0000,$0000                dspt,dhidden
DC.W $0000,$0000                serialnr

BPB_VEC:
DC.L 0                          alte Vektoren

RW_VEC:
DC.L 0

MED_VEC:
DC.L 0

MEDIACH:
DC.L 1                          Diskwechsel

DRIVENR:
DC.W 3                          Drive D:

INITDISK:
LEA     MSGCPR,A6               Copyright-Text ausgeben
CLR.W   D7                      nicht warten
BSR     DISPMSG

MOVE.L  4(A7),A1                Base Page
MOVE.L  A1,BASEPAGE
MOVE.L  36(A1),A1               Parents Base Page
MOVE.L  124(A1),A1              geretteter SP bei EXEC
MOVE.L  54(A1),A1               Parameter Pfadname

FIND1:
MOVE.L  A1,A0                   Anfang Name merken

FIND2:
MOVE.B  (A1)+,D0
CMP.B   #":",D0
BEQ     FIND1                   Drivename Åberlesen
CMP.B   #"\",D0
BEQ     FIND1                   Ordnername Åberlesen
TST.B   D0                      Name zuende ?
BNE     FIND2                   nein

CLR.W   D0                      Size = 0K
CMP.B   #"R",(A0)+              Filename = "RES" ?
BNE     NAMBAD
CMP.B   #"E",(A0)+
BNE     NAMBAD
CMP.B   #"S",(A0)+
BNE     NAMBAD                  nein
MOVEQ   #2,D1                   3 Ziffern fÅr Size
LEA     KBYTE1,A1               Size in MSGOK
LEA     KBYTE2,A2               Size in MSGQUIT

GETSIZE:
MOVE.B  (A0)+,D2                Zeichen holen
MOVE.B  D2,(A1)+                kopieren
MOVE.B  D2,(A2)+
CMP.B   #"9",D2                 eine Ziffer ?
BGT     NAMBAD
SUB.B   #"0",D2
BLT     NAMBAD                  nein
MULU    #10,D0                  stellenrichtig
EXT.W   D2
ADD.W   D2,D0                   zu Size addieren
DBF     D1,GETSIZE
ADDQ.W  #2,D0                   +2K
MOVE.W  D0,RAMSIZE              merken

MOVE.B  (A0),D0                 Drive Buchstabe
MOVE.B  D0,DRIVE                in MSGOK kopieren
CMP.B   #"Z",D0                 zwischen C und Z ?
BGT     NAMBAD                  nein
SUB.B   #"C",D0
BGE     NAMOK                   ja

NAMBAD:
LEA     MSGINST,A6              Instruktions-Text ausgeben
MOVE.W  #350,D7                 5 Sekunden warten
BRA     QUIT                    Name ungÅltig

NAMOK:
EXT.W   D0
ADDQ.W  #2,D0
MOVE.W  D0,DRIVENR              Drive merken

PEA     TESTINST
MOVE.W  #38,-(A7)               Supexec
TRAP    #14
ADDQ.L  #6,A7
TST.L   D0                      schon installiert ?
BEQ     INSTDISK                nein

LEA     MSGOK,A6                Ok-Text ausgeben
SUBQ.W  #1,D0                   PrÅfsumme ok ?
BEQ     TERM                    ja
CLR.W   D7
BSR     DISPMSG
LEA     MSGCHK,A6               Fehler-Text ausgeben

TERM:
MOVE.W  #140,D7                 2 Sekunden warten
BSR     DISPMSG
MOVE.L  #INITDISK,D0            Initialisierungs-Routinen
SUB.L   BASEPAGE,D0             werden nicht mehr gebraucht
CLR.W   -(A7)
MOVE.L  D0,-(A7)
MOVE.W  #$31,-(A7)              Ptermres
TRAP    #1

INSTDISK:
PEA     INSTALL                 Installation versuchen
MOVE.W  #38,-(A7)               Supexec
TRAP    #14
ADDQ.L  #6,A7                   hat nicht geklappt

LEA     MSGQUIT,A6              Quit-Text ausgeben
MOVE.W  #140,D7                 2 Sekunden warten

QUIT:
BSR     DISPMSG
CLR.W   -(A7)                   Programmende
TRAP    #1

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

TESTINST:
CMP.L   #$472E472E,INSFLAG      Install Flag gesetzt ?
BNE     ISNT                    nein
MOVE.W  RAMSIZE,D0              geforderte Grîûe
CMP.W   DSKSIZE,D0              gleich alte Grîûe ?
BEQ     ISINST                  ja

ISNT:
CLR.L   D0                      noch nicht installiert
RTS

ISINST:
MOVE.W  DSKSIZE,BPB+14          numcl setzen
LEA     $472,A0                 Vektoren setzen
MOVE.L  (A0),BPB_VEC            hdv_bpb
MOVE.L  #HDV_BPB,(A0)+
MOVE.L  (A0),RW_VEC             hdv_rw
MOVE.L  #HDV_RW,(A0)+
ADDQ.L  #4,A0
MOVE.L  (A0),MED_VEC            hdv_mediach
MOVE.L  #HDV_MED,(A0)
MOVEQ   #1,D0
MOVE.W  DRIVENR,D1              Drive bekannt machen
LSL.L   D1,D0
OR.L    D0,$4C2                 _drvbits
MOVEQ   #1,D0
MOVE.L  CHECKSM,D2              PrÅfsumme
MOVE.L  RAMTOP,A1               der alten RESDISK
MOVE.W  DSKSIZE,D1
ADD.W   D1,D1
ADD.W   #17,D1
BSR     CHKSUM                  testen
TST.L   CHECKSM
BEQ     ISOK
MOVEQ   #2,D0                   Fehler

ISOK:
MOVE.L  D2,CHECKSM
RTS

INSTALL:
MOVE.L  #$472E472E,D6           Flag merken
MOVE.L  $42E,A5                 phystop merken
MOVE.W  RAMSIZE,D0              geforderte Grîûe
EXT.L   D0
MOVEQ   #10,D1                  *2^10
LSL.L   D1,D0                   Disksize in Bytes
CMP.L   INSFLAG,D6              war RESDISK schon installiert ?
BNE     INSNEW                  nein
MOVE.L  RAMTOP,A1
LEA     -512(A1),A1             FAT Anfang
MOVE.L  A1,A4
LEA     -5*512(A1),A2           FAT Ende

LASTUSED:
MOVE.L  A1,A3                   letzten belegten Cluster finden

TESTUSED:
TST.B   -(A1)
BNE     LASTUSED
CMP.L   A1,A2                   schon FAT Ende ?
BNE     TESTUSED                nein
SUB.L   A3,A4
MOVE.L  A4,D1                   Position
ADD.L   D1,D1                   *2
DIVU    #3,D1                   /3
CMP.W   RAMSIZE,D1              geforderte Grîûe zu klein ?
BGT     BADSIZE                 ja
MOVE.L  RAMTOP,D1               alter phystop
BRA     INSOLD

INSNEW:
MOVE.L  A5,D1                   phystop

INSOLD:
SUB.L   D0,D1
SUB.L   #18*512,D1              -18 Sektoren
MOVE.L  D1,RAMDISK              Anfangsadresse der neuen RESDISK
MOVE.L  BASEPAGE,A0
MOVE.L  A0,D0
ADD.L   12(A0),D0               +Text Segment
ADD.L   #100*1024,D0            min. 100K frei lassen
CMP.L   D1,D0                   RESDISK zu groû ?
BLT     FITS                    nein

BADSIZE:
RTS

FITS:
LEA     MSGRES,A6               Reset-Text ausgeben
MOVE.W  #70,D7                  1 Sekunde warten
BSR     DISPMSG
SUBQ.W  #1,$452                 vblsem
MOVE.W  RAMSIZE,DSKSIZE         Disksize merken
MOVE.L  #BADSIZE,A7             neuen Stackpointer benutzen, der alte
MOVE.L  A7,USP                  kînnte im Bereich der RESDISK liegen
CMP.L   INSFLAG,D6              war RESDISK schon installiert ?
BEQ     INSBOOT                 ja

MOVE.L  D6,INSFLAG              Install Flag setzen
MOVE.L  A5,RAMTOP               phystop merken
MOVE.L  A5,A0                   Boot Sektor, FATs und Directory
MOVE.W  #$08FF,D0               $2400 Bytes=18 Sektoren
CLRRAM:
CLR.L   -(A0)                   lîschen
DBF     D0,CLRRAM

INSBOOT:
MOVE.W  RAMSIZE,D0
ADD.W   #9,D0                   +9 Cluster
LSL.W   #1,D0                   =Sektoren der RESDISK
LEA     BOOTSEK+8,A0            SEC setzen
MOVE.B  D0,(A0)+                Low Byte
LSR.W   #8,D0
MOVE.B  D0,(A0)                 High Byte

MOVE.L  RAMTOP,A0               Boot Sektor erzeugen
LEA     -11(A0),A0
LEA     BOOTSEK,A1
MOVEQ   #18,D0                  19 Bytes
COPYBS:
MOVE.B  (A1)+,-(A0)             kopieren
DBF     D0,COPYBS

CLR.L   D0                      PrÅfsumme
MOVE.L  RAMDISK,A0              der gesamten RESDISK neu berechnen
MOVE.L  RAMTOP,A1

NEWCHK:
MOVE.L  -(A1),D1
EOR.L   D1,D0
CMP.L   A0,A1                   oberste RAM Adresse erreicht ?
BNE     NEWCHK                  nein
MOVE.L  D0,CHECKSM              PrÅfsumme merken

MOVE.L  RAMDISK,$42E            RESDISK Anfang merken
MOVE.L  $4,A0
JMP     (A0)                    RESET,dieses Programm muû jetzt nochmal gestartet werden

BASEPAGE:
DC.L 0                          Basepage Adresse

RAMDISK:
DC.L 0                          RESDISK Startadresse

RAMSIZE:
DC.W 500                        500K RESDISK

BOOTSEK:
DC.B $00,$02                    BPS
DC.B $02                        SPC
DC.B $01,$00                    RES
DC.B $02                        FAT
DC.B $70,$00                    DIR
DC.B $FF,$FF                    SEC wird richtig gesetzt
DC.B $00                        MEDIA
DC.B $05,$00                    SPF
DC.B $09,$00                    SPT
DC.B $01,$00                    SIDE
DC.B $00,$00                    HID

MSGCPR:
DC.B 27,"E",10,"  ???K RESDISK (C) 1987 by G. Gerhardt",13,10,10,0

MSGOK:
DC.B "  "
KBYTE1:
DC.B "   K RESDISK als Drive "
DRIVE:
DC.B "  installiert",13,10,10,0

MSGQUIT:
DC.B "  ",27,"p  "
KBYTE2:
DC.B "   K RESDISK nicht installierbar  ",27,"q",0

MSGINST:
DC.B "  éndere den Namen z.B. in RES500D.PRG",13,10,10
DC.B "   fÅr eine 500K RESDISK als Drive D",0

MSGRES:
DC.B "               ",27,"p  RESET!  ",27,"q",0

MSGCHK:
DC.B "     ",27,"p  RESDISK-Inhalt fehlerhaft!  ",27,"q",0

