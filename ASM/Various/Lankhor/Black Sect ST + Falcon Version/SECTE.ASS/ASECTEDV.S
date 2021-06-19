***************************************************************************
***                                                                     ***
***                    MAUPITI ISLAND: assembleur                       ***
***                    --------------------------                       ***
***              Charge BOOT_ST.MAU en BASLOAD (routines de lecture)    ***
***                     PRGMUS.MAU  en PRGMUS  (musique)                ***
***                     MAUPASS.MAU en ASSMAUP (assembleur complet)     ***
***                                                                     ***
***************************************************************************

   xdef     PEEK,PEEKW,POKE,POKEW,MEMLIB,MEMRES,DECOMP,GROSSI,SAVMEM
   xdef     VBLSYNC,INITMOUSE,CHNGMOUSE,HIDEMOUSE,SHOWMOUSE,BOITE
   xdef     MOVBLK,CLRBLK,PAROLE,POKEL,PEEKL,ADSAUV
   xdef     AFMEN,AFTEXT,TRACLIGN,EFFETS,DPB,AFMARK
   xdef     LOADLIEU,LOADOBJT,LOADPERS,GNON,LOADSUIV
   xdef     RESETANI,INITANI,EXITANI,CHNGANI,MLOUPE,VERIF
   xdef     DOMORT,REMAPEC,PALJNF,PALJN,COUPSON,SURIM,POURCENT
   xdef     DEPADR,ADEPLONW,ADEPLONB,TAILTA,BRUI,COUPRI,STOPANI
   xdef     LOADFIC,COUPSO4,TESTLOAD,PAMB,HAZARD,ADEC,DAMB,APRIO
   xdef     CHARGE,SAUVE
   xdef     BLOCANI,ALERTE,INITDEMO,CONFIGSYS
   xdef     INITADR,AFFICHE,PEEKB
   xdef     HIDEMOUF,SHOWMOUF,COORDMOUS,INITPAL,BRUIERGO
   xdef     TEMPRIO,MODAMB,INIMUS,FINI,MUSIQUE
   xdef     LOADASS,GOTOXY,LIFIC,FINJEU,ANIHALT,ANISHOW

PRGMUS    EQU   $2a0000
BASLOAD   EQU   $2a0000-40000-10000
ASSMAUP   EQU   $2a0000-40000
*
LIFIC
   move.l   12(a7),d1              * adresse tampon
   move.l   8(a7),d2               * longueur
   move.l   4(a7),d3               * handle
   move.l   d1,-(sp)
   move.l   d2,-(sp)
   move.w   d3,-(sp)
   move.w   #$3f,-(sp)
   trap     #1
   add.l    #12,sp
   move.l   (a7),12(a7)
   add.l    #12,a7
   rts
*
GOTOXY
   MOVEM.L  D0-D7/A0-A6,-(A7)
   MOVE.L   60+8(A7),D0
   ADD.B    #' ',D0
   MOVE.B   D0,TABSTR+3
   MOVE.L   60+4(A7),D0
   ADD.B    #' ',D0
   MOVE.B   D0,TABSTR+2
   PEA      TABSTR
   MOVE     #$9,-(A7)
   TRAP     #1
   ADDQ     #6,A7
   MOVEM.L  (A7)+,D0-D7/A0-A6
   MOVE.L   (A7),8(A7)
   ADDQ     #8,A7
   RTS

TABSTR: DC.B    27,'Y',0,0,0,0  
*
PEEK  
        MOVE.L  ASSMAUP+00,A0
        JMP     (A0)
        RTS
PEEKW
        MOVE.L  ASSMAUP+04,A0
        JMP     (A0)
        RTS
POKE
        MOVE.L  ASSMAUP+08,A0
        JMP     (A0)
        RTS
POKEW
        MOVE.L  ASSMAUP+12,A0
        JMP     (A0)
        RTS
MEMLIB
        MOVE.L  ASSMAUP+16,A0
        JMP     (A0)
        RTS
MEMRES
        MOVE.L  ASSMAUP+20,A0
        JMP     (A0)
        RTS
DECOMP
        MOVE.L  ASSMAUP+24,A0
        JMP     (A0)
        RTS
GROSSI
        MOVE.L  ASSMAUP+28,A0
        JMP     (A0)
        RTS
SAVMEM
        MOVE.L  ASSMAUP+32,A0
        JMP     (A0)
        RTS
VBLSYNC
        MOVE.L  ASSMAUP+36,A0
        JMP     (A0)
        RTS
INITMOUSE
        MOVE.L  ASSMAUP+40,A0
        JMP     (A0)
        RTS
CHNGMOUSE
        MOVE.L  ASSMAUP+44,A0
        JMP     (A0)
        RTS
HIDEMOUSE
        MOVE.L  ASSMAUP+48,A0
        JMP     (A0)
        RTS
SHOWMOUSE
        MOVE.L  ASSMAUP+52,A0
        JMP     (A0)
        RTS
BOITE
        MOVE.L  ASSMAUP+56,A0
        JMP     (A0)
        RTS
MOVBLK
        MOVE.L  ASSMAUP+60,A0
        JMP     (A0)
        RTS
CLRBLK
        MOVE.L  ASSMAUP+64,A0
        JMP     (A0)
        RTS
PAROLE
        MOVE.L  ASSMAUP+68,A0
        JMP     (A0)
        RTS
POKEL
        MOVE.L  ASSMAUP+72,A0
        JMP     (A0)
        RTS
PEEKL
        MOVE.L  ASSMAUP+76,A0
        JMP     (A0)
        RTS
ADSAUV
        MOVE.L  ASSMAUP+80,A0
        MOVE.L  #ADSAUV,D0      ;POUR ADRESSE DEBUT DE RECHERCHE
        SUB.L   #10000,D0
        JMP     (A0)
        RTS
AFMEN
        MOVE.L  ASSMAUP+84,A0
        JMP     (A0)
        RTS
AFTEXT
        MOVE.L  ASSMAUP+88,A0
        JMP     (A0)
        RTS
TRACLIGN
        MOVE.L  ASSMAUP+92,A0
        JMP     (A0)
        RTS
EFFETS
        MOVE.L  ASSMAUP+96,A0
        JMP     (A0)
        RTS
DPB
        MOVE.L  ASSMAUP+100,A0
        JMP     (A0)
        RTS
AFMARK
        MOVE.L  ASSMAUP+104,A0
        JMP     (A0)
        RTS
LOADLIEU
        MOVE.L  ASSMAUP+108,A0
        JMP     (A0)
        RTS
LOADOBJT
        MOVE.L  ASSMAUP+112,A0
        JMP     (A0)
        RTS
LOADPERS
        MOVE.L  ASSMAUP+116,A0
        JMP     (A0)
        RTS
GNON
        MOVE.L  ASSMAUP+120,A0
        JMP     (A0)
        RTS
LOADSUIV
        MOVE.L  ASSMAUP+124,A0
        JMP     (A0)
        RTS
RESETANI
        MOVE.L  ASSMAUP+128,A0
        JMP     (A0)
        RTS
INITANI
        MOVE.L  ASSMAUP+132,A0
        JMP     (A0)
        RTS
EXITANI
        MOVE.L  ASSMAUP+136,A0
        JMP     (A0)
        RTS
CHNGANI
        MOVE.L  ASSMAUP+140,A0
        JMP     (A0)
        RTS
MLOUPE
        MOVE.L  ASSMAUP+144,A0
        JMP     (A0)
        RTS
VERIF
        MOVE.L  ASSMAUP+148,A0
        JMP     (A0)
        RTS
DOMORT
        MOVE.L  ASSMAUP+152,A0
        JMP     (A0)
        RTS
REMAPEC
        MOVE.L  ASSMAUP+156,A0
        JMP     (A0)
        RTS
PALJNF
        MOVE.L  ASSMAUP+160,A0
        JMP     (A0)
        RTS
PALJN
        MOVE.L  ASSMAUP+164,A0
        JMP     (A0)
        RTS
COUPSON
        MOVE.L  ASSMAUP+168,A0
        JMP     (A0)
        RTS
SURIM
        MOVE.L  ASSMAUP+172,A0
        JMP     (A0)
        RTS
POURCENT
        MOVE.L  ASSMAUP+176,A0
        JMP     (A0)
        RTS
DEPADR
        MOVE.L  ASSMAUP+180,A0
        JMP     (A0)
        RTS
ADEPLONW
        MOVE.L  ASSMAUP+184,A0
        JMP     (A0)
        RTS
ADEPLONB
        MOVE.L  ASSMAUP+188,A0
        JMP     (A0)
        RTS
TAILTA
        MOVE.L  ASSMAUP+192,A0
        JMP     (A0)
        RTS
BRUI
        MOVE.L  ASSMAUP+196,A0
        JMP     (A0)                ;appelle SURIMP
        RTS
COUPRI
        MOVE.L  ASSMAUP+200,A0
        JMP     (A0)
        RTS
STOPANI
        MOVE.L  ASSMAUP+204,A0
        JMP     (A0)
        RTS
LOADFIC
        MOVE.L  ASSMAUP+208,A0
        JMP     (A0)
        RTS
BRUIERGO
        MOVE.L  ASSMAUP+332,A0
        JMP     (A0)
        RTS
COUPSO4
        MOVE.L  ASSMAUP+212,A0
        JMP     (A0)
        RTS
TESTLOAD
        MOVE.L  ASSMAUP+216,A0
        JMP     (A0)
        RTS
PAMB
        MOVE.L  ASSMAUP+220,A0
        JMP     (A0)
        RTS
HAZARD
        MOVE.L  ASSMAUP+224,A0
        JMP     (A0)
        RTS
ADEC
        MOVE.L  ASSMAUP+228,A0
        JMP     (A0)
        RTS
TEMPRIO
        MOVE.L  ASSMAUP+308,A0
        JMP     (A0)
        RTS
DAMB
        MOVE.L  ASSMAUP+232,A0
        JMP     (A0)
        RTS
MODAMB
        MOVE.L  ASSMAUP+312,A0
        JMP     (A0)
        RTS
INIMUS
        MOVE.L  ASSMAUP+320,A0
        JMP     (A0)
        RTS
FINI
        MOVE.L  ASSMAUP+324,A0
        JMP     (A0)
        RTS
MUSIQUE
        MOVE.L  ASSMAUP+328,A0
        JMP     (A0)
        RTS
APRIO
        MOVE.L  ASSMAUP+236,A0
        JMP     (A0)
        RTS
CHARGE
        MOVE.L  ASSMAUP+240,A0
        JMP     (A0)
        RTS
SAUVE
        MOVE.L  ASSMAUP+244,A0
        JMP     (A0)
        RTS
BLOCANI
        MOVE.L  ASSMAUP+248,A0
        JMP     (A0)
        RTS
ALERTE
        MOVE.L  ASSMAUP+252,A0
        JMP     (A0)
        RTS
INITADR
        MOVE.L  ASSMAUP+276,A0
        JMP     (A0)
        RTS
AFFICHE
        MOVE.L  ASSMAUP+280,A0
        JMP     (A0)
        RTS
PEEKB
        MOVE.L  ASSMAUP+284,A0
        JMP     (A0)
        RTS
HIDEMOUF
        MOVE.L  ASSMAUP+288,A0
        JMP     (A0)
        RTS
SHOWMOUF
        MOVE.L  ASSMAUP+292,A0
        JMP     (A0)
        RTS
COORDMOUS
        MOVE.L  ASSMAUP+296,A0
        JMP     (A0)
        RTS
INITPAL
        MOVE.L  ASSMAUP+300,A0
        JMP     (A0)
        RTS
ANIHALT
        MOVE.L  ASSMAUP+344,A0
        JMP     (A0)
        RTS
ANISHOW
        MOVE.L  ASSMAUP+348,A0
        JMP     (A0)
        RTS
FINJEU:
        MOVE.L  ASSMAUP+272,A0      ;REMET INTERRUPTIONS STANDARD
        JSR     (A0)

        LEA     $FF8240,A0
        LEA     SAVEPAL(PC),A1
        MOVE    #7,D0
PAL0:   MOVE.L  (A1)+,(A0)+
        DBF     D0,PAL0

        MOVE    #1,-(A7)            ;MOYENNE RESOLUTION
        PEA     -1
        PEA     -1
        MOVE    #5,-(A7)
        TRAP    #14
        LEA     12(A7),A7

        MOVE.L  OLDPILE,D0          ;MODE UTILISATEUR
        MOVE.L  A7,OLDPILE
        MOVE.L  D0,-(A7)
        MOVE    #$20,-(A7)
        TRAP    #1
        ADDQ    #6,A7
        MOVE.L  OLDPILE,A7

        RTS

LOADASS:
        CLR     -(A7)               ;BASSE RESOLUTION
        PEA     -1
        PEA     -1
        MOVE    #5,-(A7)
        TRAP    #14
        LEA     12(A7),A7

        MOVE.L  A7,OLDPILE          ;SUPERVISEUR
        CLR.L   -(A7)
        MOVE    #$20,-(A7)
        TRAP    #1
        MOVE.L  OLDPILE,A7
        MOVE.L  D0,OLDPILE

        LEA     $FF8240,A0
        LEA     SAVEPAL(PC),A1
        MOVE    #7,D0
PAL1:   MOVE.L  (A0)+,(A1)+
        DBF     D0,PAL1

        MOVE.L  #NOM1,src_name      ;assembleur principal
        MOVE.L  #ASSMAUP,adr_cur
        BSR     TLOAD

        MOVE.L  #NOM2,src_name      ;routines de chargement
        MOVE.L  #BASLOAD,adr_cur
        BSR     TLOAD

        CMPI.L  #$400000,$42e
        BLT.S   PASMEM
        MOVE.L  #NOM3,src_name      ;musique et son
        MOVE.L  #PRGMUS,adr_cur
        BSR     TLOAD
        TST     D0
        BNE.S   PASMEM
        MOVE.L  ASSMAUP+304,A0
        MOVE    #1,(A0)
PASMEM: RTS
SAVEPAL:       DS.W    16

NOM1:   DC.B    'D:\SECTE.SEK\SECTASS.O',0
NOM2:   DC.B    'D:\SECTE.SEK\BOOT_ST.O',0
NOM3:   DC.B    'E:\BANDESON.EDI\MUSSECTE.O',0
        EVEN
INITDEMO:
        MOVE.L  ASSMAUP+256,A0
        JMP     (A0)

CONFIGSYS:
        MOVE.L  ASSMAUP+260,A0
        JMP     (A0)

TLOAD:
        
        MOVEM.L D1-D7/A0-A6,-(A7)
        CLR.W   -(A7)               ; Ouvre en lecture
        MOVE.L  src_name,-(A7)
        MOVE.W  #$3D,-(A7)
        TRAP    #1
        ADDQ    #8,A7
        MOVE.W  D0,src_hdl
        BGE.S   OKLOAD
        MOVEQ   #1,D0
        BRA     FINLOAD
OKLOAD:
        MOVE.W  #2,-(A7)            ; Taille fichier
        MOVE.W  src_hdl,-(A7)
        CLR.L   -(A7)
        MOVE.W  #$42,-(A7)
        TRAP    #1
        LEA     10(A7),A7
        MOVE.L  D0,src_len

LSEEK:
        CLR.W   -(A7)               ; Et repositionne a l'offset demande
        MOVE.W  src_hdl,-(A7)
        CLR.L   -(A7)
        MOVE.W  #$42,-(A7)
        TRAP    #1
        LEA     10(A7),A7

        MOVE.L  adr_cur,-(A7)       ; Lecture a l'adresse pointee
        MOVE.L  src_len,-(A7)       ; par adr_cur
        MOVE.W  src_hdl,-(A7)
        MOVE.W  #$3F,-(A7)
        TRAP    #1
        LEA     12(A7),A7

        MOVE.W  src_hdl,-(A7)      ; Fermeture fichier
        MOVE.W  #$3E,-(A7)
        TRAP    #1
        ADDQ    #4,A7
        MOVEQ   #0,D0
FINLOAD:
        MOVEM.L (A7)+,D1-D7/A0-A6
        RTS

src_name:   dc.l    0
src_hdl:    dc.l    0
src_len:    dc.l    0
adr_cur:    dc.l    0
OLDPILE:    DC.L    0
        END

