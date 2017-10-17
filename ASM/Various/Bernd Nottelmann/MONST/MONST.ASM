********************************************************
*                                                      *
*                      ST-Monitor                      *
*          Copyright 1988 by Bernd Nottelmann          *
*                                                      *
********************************************************



          SECTION   TEXT

* Konstanten
GEMDOS    equ       1                   ; GEMDOS-Aufruf
BIOS      equ       13                  ; BIOS-Aufruf
XBIOS     equ       14                  ; XBIOS-Aufruf

TERM      equ       $00                 ; GEMDOS-Funktionen
SUPER     equ       $20
KEEP      equ       $31
MALLOC    equ       $48
MFREE     equ       $49
SETBLOCK  equ       $4A
EXEC      equ       $4B

bin       equ       0                   ; Kennziffern fÅr die Zahlenformate
dec       equ       1
hex       equ       2
str       equ       3

illegal   equ       $4AFC               ; Opcode fÅr Breakpoint

init      equ       $A000
mouse_on  equ       $A009
mouse_off equ       $A00A
vec00     equ       $000
vecFF     equ       $3FC
* Ende der Konstantendefinition


          bra       moninit

          INCLUDE   MONST1.INC          ; Fullscreen-Editor
          INCLUDE   MONST2.INC          ; Spezifische Tools
          INCLUDE   MONST3.INC          ; Assembler
          INCLUDE   MONST4.INC          ; Disassembler

moninit   movea.l   4(SP),A1            ; Initialisierung des Monitors
          move.l    #$100,D0            ; BasepagelÑnge
          add.l     12(A1),D0           ; TextsegmentlÑnge
          add.l     20(A1),D0           ; DatensegmentlÑnge
          add.l     28(A1),D0           ; BlocksegmentlÑnge
          add.l     #1024,D0            ; Stackgrîûe
          and.l     #$FFFFFE,D0         ; Gerade machen
          movea.l   A1,A2               ; Endadresse berechnen
          adda.l    D0,A2
          movea.l   A2,SP               ; Neuer Stack
          lea       startaddr(PC),A3    ; Start-und Endadresse merken
          move.l    A1,(A3)
          lea       endaddr(PC),A3      ; Endadresse plus 1
          move.l    A2,(A3)
          move.l    D0,-(SP)            ; Grîûe des Programmbereichs
          pea       (A1)                ; Startadresse des zu reservieren-
          clr.w     -(SP)               ; den Bereichs
          move.w    #SETBLOCK,-(SP)
          trap      #GEMDOS
          adda.w    #12,SP
          dc.w      init
          lea       base(PC),A0
          move.l    D0,(A0)
          lea       fonts(PC),A0
          move.l    A1,(A0)
          bsr       mcur_off            ; Mauscursor aus
          bsr       initfpbuf
          bpl.s     noifpberr           ; Kein Fehler
          bsr       mcur_on
          bra       quit2
noifpberr bsr       initscr             ; Bildschirm initialisieren
          bpl.s     noiserr             ; Kein Fehler
          bsr       mcur_on
          bra       quit1
noiserr   bsr       poffsbr             ; Druckerbetrieb ausschalten
          bsr       initdom             ; Disassembler initialisieren
          lea       pexecstrt(PC),A3    ; Kein Pexec(4)
          clr.l     (A3)
          lea       title(PC),A1        ; Anzeige des Titels
          bsr       comtxtout
          bsr       infout
          bsr       point2
          bsr       cret
          bsr       mcur_on             ; Mauscursor an
          lea       excbuf(PC),A3       ; Puffer fÅr die Exceptions
          lea       buserror(PC),A1     ; Bus-Fehler
          move.w    #$02,D1
          bsr       sexec
          move.l    D0,(A3)+
          lea       adrerror(PC),A1     ; Adress-Fehler
          move.w    #$03,D1
          bsr       sexec
          move.l    D0,(A3)+
          lea       brkentry(PC),A1     ; Illegaler Befehl (Breakpoint)
          move.w    #$04,D1
          bsr       sexec
          move.l    D0,(A3)+
          lea       divbyzero(PC),A1    ; Division durch Null
          move.w    #$05,D1
          bsr       sexec
          move.l    D0,(A3)+
          lea       chkexc(PC),A1       ; CHK-Befehl
          move.w    #$06,D1
          bsr       sexec
          move.l    D0,(A3)+
          lea       overflow(PC),A1     ; TRAPV-Befehl
          move.w    #$07,D1
          bsr       sexec
          move.l    D0,(A3)+
          lea       privileg(PC),A1     ; Privilegverletzung
          move.w    #$08,D1
          bsr       sexec
          move.l    D0,(A3)+
          lea       TRACE(PC),A1        ; TRACE
          move.w    #$09,D1
          bsr       sexec
          move.l    D0,(A3)+
          lea       quitinit(PC),A4     ; quitbuf initialisieren
          st        (A4)
          lea       regflag(PC),A4      ; Registerausgabe bei BRK
          st        (A4)
          lea       dasmflag(PC),A4     ; Disassemblieren bei A-Befehl
          sf        (A4)
          lea       gbflag(PC),A4       ; Grafikpufferung bei Exception
          sf        (A4)
brkent    dc.w      illegal             ; Zum BREAK-ENTRY
          lea       excbuf(PC),A3
          movea.l   (A3)+,A1            ; Bus-Fehler
          move.w    #$02,D1
          bsr       sexec
          movea.l   (A3)+,A1            ; Adress-Fehler
          move.w    #$03,D1
          bsr       sexec
          movea.l   (A3)+,A1            ; Illegaler Befehl
          move.w    #$04,D1
          bsr       sexec
          movea.l   (A3)+,A1            ; Division durch Null
          move.w    #$05,D1
          bsr       sexec
          movea.l   (A3)+,A1            ; CHK-Befehl
          move.w    #$06,D1
          bsr       sexec
          movea.l   (A3)+,A1            ; TRAPV-Befehl
          move.w    #$07,D1
          bsr       sexec
          movea.l   (A3)+,A1            ; Privilegverletzung
          move.w    #$08,D1
          bsr       sexec
          movea.l   (A3)+,A1            ; TRACE
          move.w    #$09,D1
          bsr       sexec
          bsr       delscr              ; Bildschirmspeicher freigeben
quit1     bsr       delfpbuf            ; Sektorpuffer freigeben
quit2     move.w    #TERM,-(SP)         ; ZurÅck zum Desktop
          trap      #GEMDOS
exitmon   clr.w     -(SP)               ; Kein Fehler ist aufgetreten
          move.l    endaddr(PC),D0      ; LÑnge des Programms berechnen
          sub.l     startaddr(PC),D0
          move.l    D0,-(SP)
          move.w    #KEEP,-(SP)         ; ZurÅck zum Desktop, aber Pro-
          trap      #GEMDOS             ; gramm bleibt erhalten

grsav     movem.l   D0-D2/A0-A2,-(SP)   ; Grafikbildschirm puffern und
          dc.w      mouse_off           ; Maus ausschalten
          bsr       cur_off             ; Cursor ausschalten
          move.b    gbflag(PC),D0       ; Grafikbildschirm retten?
          beq.s     grsavend            ; Nein
          lea       gbflag2(PC),A2
          st        (A2)                ; Grafikpuffer wird genutzt
          move.l    logbs(PC),A0        ; Logischer Bildschirm
          move.l    grbuf(PC),A1        ; Grafikpuffer
          move.w    #1999,D1            ; 2000 mal
loop102   move.l    (A0)+,(A1)+         ; 16 Bytes Åbertragen
          move.l    (A0)+,(A1)+
          move.l    (A0)+,(A1)+
          move.l    (A0)+,(A1)+
          dbra      D1,loop102
grsavend  movem.l   (SP)+,D0-D2/A0-A2
          rts

* Exceptions und Exceptionprozedur
exc1      addq.l    #2,2(SP)            ; Exception-Prozedur
exc2      pea       (A6)                ; Alle Register retten
          lea       reg(PC),A6          ; In den Puffer schreiben
          movem.l   D0-D7/A0-A5,(A6)
          lea       56(A6),A6
          move.l    (SP)+,(A6)+         ; Altes A6
          move.l    USP,A5              ; Userstackpointer
          move.l    A5,(A6)+
          clr.w     (A6)+
          move.w    (SP),(A6)+          ; Statusregister
          move.l    2(SP),(A6)+         ; Programcounter
          move.l    SP,(A6)             ; Supervisorstackpointer
          addq.l    #6,(A6)             ; FÅr die Registeranzeige
          move.w    #%0010001100000000,SR
          lea       quitinit(PC),A3
          tst.b     (A3)                ; Puffer fÅr Quit initialisieren?
          beq.s     noqinit
          lea       quitbuf(PC),A4      ; Puffer fÅr Quit-Funktion
          move.l    A5,(A4)+            ; USP
          clr.w     (A4)+
          move.w    (SP),(A4)+          ; SR
          move.l    2(SP),(A4)+         ; PC
          move.l    SP,(A4)             ; SSP
          bsr       CLReg               ; öbrigens: alle Register lîschen!
          sf        (A3)                ; Keine Initialisierung mehr
noqinit   bsr       cur_on              ; Cursor einschalten
          movea.l   exctext(PC),A1      ; Meldung ausgeben
          bsr       comtxtout
          lea       regflag(PC),A3
          tst.b     (A3)                ; Registerausgabe?
          beq.s     norout
          bsr       regout
norout    bsr       point2
          lea       execute(PC),A1      ; BefehlsausfÅhrungsroutine
          bsr       getkey
          bsr       mcur_on             ; Mauszeiger an
          tst.l     D1                  ; Quit oder Exit?
          beq.s     go
          lea       quitbuf(PC),A4      ; Quit-Funktion
          adda.w    #12,A4              ; Register wiederherstellen
          movea.l   (A4),SP             ; SSP
          move.l    -(A4),2(SP)         ; PC
          move.w    -(A4),(SP)          ; SR
          subq.l    #2,A4
          movea.l   -(A4),A5            ; USP
          move.l    A5,USP
          tst.l     D1                  ; Exit?
          bmi.s     excend              ; Nein
          lea       exitmon(PC),A4      ; Exit-Funktion
          move.l    A4,2(SP)            ; PC zeigt auf KEEP-Ende
          bra.s     excend
go        lea       reg(PC),A6          ; Go-Funktion
          adda.w    #72,A6
          subq.l    #6,(A6)             ; Korrektur des SSP-Puffers
          movea.l   (A6),SP             ; SSP
          move.l    -(A6),2(SP)         ; PC
          move.w    -(A6),(SP)          ; SR
          subq.l    #2,A6
          movea.l   -(A6),A5            ; USP
          move.l    A5,USP
          movem.l   reg(PC),D0-D7/A0-A6 ; Alle Åbrigen Register
excend    rte

busadrerr movem.l   D1-D5/A1,-(SP)      ; Super-Statuswort ausgeben
          lea       text13(PC),A1       ; Function Code ausgeben
          bsr       textout
          move.w    24(SP),D1
          moveq     #3,D2
          moveq     #bin,D3
          sf        D4
          sf        D5
          bsr       wrtval
          lea       text14(PC),A1       ; Gruppenzugehîrigkeitsflag
          bsr       textout             ; ausgeben
          lsr.w     #3,D1
          moveq     #1,D2
          bsr       wrtval
          lea       text15(PC),A1       ; Lese-/Schreibzyklus-Flag
          bsr       textout             ; ausgeben
          lsr.w     #1,D1
          bsr       wrtval
          lea       text16(PC),A1
          bsr       textout
          lea       exctext(PC),A1      ; Nullbyte
          pea       text17(PC)
          move.l    (SP)+,(A1)
          movem.l   (SP)+,D1-D5/A1
          addq.l    #8,SP               ; Stack-Korrektur
          bra       exc2                ; Ohne PC-Korrektur

buserror  bsr       grsav               ; Bus-Fehler
          pea       (A1)
          lea       text08(PC),A1       ; 'Bus error'
          bsr       comtxtout
          movea.l   (SP)+,A1
          bra       busadrerr

adrerror  bsr       grsav               ; Adress-Fehler
          pea       (A1)
          lea       text09(PC),A1       ; 'Address error'
          bsr       comtxtout
          movea.l   (SP)+,A1
          bra       busadrerr

brkentry  bsr       grsav               ; Breakentry
          pea       (A0)
          lea       exctext(PC),A0
          pea       text03(PC)          ; 'Break'
          move.l    (SP)+,(A0)
          movea.l   (SP)+,A0
          bra       exc1                ; Mit PC-Korrektur

divbyzero bsr       grsav               ; Division durch Null
          pea       (A0)
          lea       exctext(PC),A0
          pea       text11(PC)          ; 'Division by zero'
          move.l    (SP)+,(A0)
          movea.l   (SP)+,A0
          bra       exc2

chkexc    bsr       grsav               ; CHK-Exception
          pea       (A0)
          lea       exctext(PC),A0
          pea       text12(PC)          ; 'Out of range'
          move.l    (SP)+,(A0)
          movea.l   (SP)+,A0
          bra       exc2

overflow  bsr       grsav               ; TRAPV
          pea       (A0)
          lea       exctext(PC),A0
          pea       text18(PC)          ; 'Overflow'
          move.l    (SP)+,(A0)
          movea.l   (SP)+,A0
          bra       exc2

privileg  bsr       grsav               ; Privilegverletzung
          pea       (A0)
          lea       exctext(PC),A0
          pea       text10(PC)          ; 'Violation of privileg'
          move.l    (SP)+,(A0)
          movea.l   (SP)+,A0
          bra       exc2

TRACE     rte
* Ende Exceptions

execute   move.l    lnstart(PC),A1      ; Monitorbefehl ausfÅhren
          move.l    lnend(PC),A0
getchr1   move.b    (A1)+,D1            ; Zeichen holen
          cmp.b     #'.',D1             ; Zeichen ist Punkt?
          beq.s     break               ; Ja, dann Abbruchbedingung prÅfen
          cmp.b     #' ',D1             ; Zeichen ist Blank?
          bne.s     getchr2
break     cmpa.l    A0,A1               ; Zeilenende Åberschritten?
          bls       getchr1             ; Nein, dann nÑchster Durchlauf
          bra       point1              ; Ja, dann Ende
getchr2   subq.l    #1,A1
          lea       inschr(PC),A2       ; ZulÑssige Zeichen
          bsr       getwrd
          beq.s     err00               ; Fehler
          lea       instab(PC),A3       ; Befehlstabelle
          bsr       tstwrd
          bne.s     xec                 ; Kein Fehler
err00     lea       errmsg00(PC),A1     ; Fehlermeldung ausgeben
          bsr       errorout
          bra       point1
xec       subq.w    #1,D1
          lsl.w     #2,D1
          jsr       insadr(PC,D1.w)     ; Befehl ausfÅhren
          bra       point1

insadr    bra       A                   ; Sprungtabelle fÅr die Monitor-
          bra       ADD                 ; funktionen
          bra       AND
          bra       AUX
          bra       BOFF
          bra       BON
          bra       C
          bra       CD
          bra       CLB
          bra       CLReg
          bra       COnt
          bra       D
          bra       DB
          bra       DIR
          bra       DIV
          bra       DMsk
          bra       DOFF
          bra       DON
          bra       DRV
          bra       EOR
          bra       ERA
          bra       EXB
          bra       EXecprg
          bra       F
          bra       G
          bra       H
          bra       HS
          bra       I
          bra       INF
          bra       K
          bra       L
          bra       LST
          bra       M
          bra       MD
          bra       MOD
          bra       MUL
          bra       OR
          bra       PHB
          bra       PLB
          bra       POFF
          bra       PON
          bra       Q
          bra       R
          bra       REN
          bra       RMD
          bra       ROFF
          bra       RON
          bra       RS
          bra       S
          bra       SIDE
          bra       SUB
          bra       T
          bra       V
          bra       W
          bra       WB
          bra       WS
          bra       X
          bra       hexins
          bra       poke
          bra       pokereg
          bra       pokevec
          bra       pokefbuf
          bra       rem

* Monitorfunktionen
A         bsr       getadr              ; Assemblieren
          beq       Aend
          bsr       tsteven             ; Gerade Adresse?
          bcs       Aend
          bsr       smchrtst
          bcs.s     Agmi
          lea       dasmflag(PC),A3     ; Disassemblieren?
          tst.b     (A3)
          beq.s     Aend
          lea       text19(PC),A1       ; Ganze Befehlszeile ausgeben
          bsr       textout
          move.l    A4,D1
          moveq     #6,D2
          moveq     #hex,D3
          sf        D4
          sf        D5
          bsr       wrtval              ; Adresse
          moveq     #4,D7
          bsr       spcn
          movea.l   A4,A3
          lea       mnembuf(PC),A4
          bsr       wrtmcins
          movea.l   A4,A1
          bsr       textout             ; Befehl
          moveq     #5,D1               ; Rest der Zeile lîschen
          bsr       chrout
          lea       text20(PC),A1
          bsr       textout
          bra.s     Anolf
Agmi      movea.l   A4,A6
          bsr       getmcins            ; Assemblerbefehl holen
          bne.s     Aend
          subq.w    #1,D6               ; Code in Speicher Åbertragen
loop64    move.b    (A3)+,(A6)+
          dbra      D6,loop64
          bsr       point2              ; NÑchste Zeile
          moveq     #'A',D1
          bsr       chrout
          bsr       spc
          move.l    A6,D1
          moveq     #6,D2
          moveq     #hex,D3
          sf        D4
          sf        D5
          bsr       wrtval
          moveq     #4,D7
          bsr       spcn
          moveq     #0,D0
Anolf     addq.l    #4,SP               ; Keine neue Zeile
Aend      rts

ADD       lea       addsbr(PC),A3       ; Addition
          bra       op
addsbr    add.l     D1,D5
          rts

AND       lea       andsbr(PC),A3       ; Und-VerknÅpfung
          bra       op
andsbr    and.l     D1,D5
          rts

AUX       lea       lstaux(PC),A3       ; Drucker lÑuft seriell
          sf        (A3)
          rts

BOFF      lea       gbflag(PC),A3       ; Grafikpuffer wieder freigeben
          tst.b     (A3)                ; Grafikpuffer vorhanden?
          beq.s     BOFFend             ; Nein
          sf        (A3)                ; Flag lîschen
          move.l    grbuf(PC),-(SP)     ; Startadresse des Puffers
          move.w    #MFREE,-(SP)        ; Speicher freigeben
          trap      #GEMDOS
          addq.l    #6,SP
BOFFend   rts

BON       lea       gbflag(PC),A3       ; Grafikpuffer einrichten
          tst.b     (A3)                ; Grafikpuffer schon vorhanden?
          bne.s     BONend              ; Ja
          move.l    #32000,-(SP)        ; 32000 Bytes reservieren
          move.w    #MALLOC,-(SP)
          trap      #GEMDOS
          addq.l    #6,SP
          tst.l     D0                  ; Fehler?
          bmi.s     BONerr              ; Ja
          st        (A3)                ; Flag setzen
          lea       gbflag2(PC),A3
          sf        (A3)                ; Grafikpuffer ist neu
          lea       grbuf(PC),A3
          move.l    D0,(A3)             ; Startadresse Åbertragen
          bra.s     BONend
BONerr    lea       errmsg97(PC),A1     ; 'MALLOC error'
          bra       errorout
BONend    rts

C         bsr       setprm              ; Umrechnen von Zahlen
          st        -9(A2)              ; Strings zulassen
          bsr       rdval
          beq.s     Cend
          bsr       com
          st        D4                  ; Formatkennzeichen ausgeben
          sf        D5                  ; Keine negative Hexadezimalzahl
          moveq     #hex,D3             ; Hexadezimalzahl ausgeben
          moveq     #8,D2               ; Achtstellig
          bsr       wrtval
          bsr       eq
          moveq     #bin,D3             ; BinÑrzahl ausgeben
          moveq     #32,D2              ; 32 stellig
          bsr       wrtval
          bsr       eq
          st        D5                  ; Negative Dezimalzahl mîglich
          moveq     #dec,D3             ; Dezimalzahl ausgeben
          moveq     #0,D2               ; Mindestens eine Stelle
          bra       wrtvalln
Cend      rts

CD        moveq     #77,D4              ; Pfadnamen fÅr Directory Ñndern
          bsr       rdfname
          beq.s     CDend
          bra       changedir
CDend     rts

CLB       movea.l   flopbuf(PC),A4      ; Sektorpuffer lîschen
          move.w    #127,D0
loop88    clr.l     (A4)+
          dbra      D0,loop88
          rts

CLReg     lea       reg(PC),A1          ; Register lîschen (D0-D7/A0-A6)
          move.w    #14,D0
loop4     clr.l     (A1)+
          dbra      D0,loop4
          clr.b     7(A1)               ; CCR lîschen
          rts

COnt      lea       reg(PC),A2          ; Fortsetzen von Maschinensprache-
          movea.l   68(A2),A4           ; programmen mit Restaurierung
          bsr       smchrtst            ; des Grafikbildschirms
          bcc.s     nga2
          bsr       getadr
          beq.s     COntend             ; Fehler
nga2      bsr       tsteven             ; Adresse gerade?
          bcs.s     COntend
          lea       reg(PC),A2
          move.l    A4,68(A2)
          lea       gbflag(PC),A3
          tst.b     (A3)                ; Grafikpuffer vorhanden?
          beq.s     nogrld              ; Nein
          lea       gbflag2(PC),A3
          tst.b     (A3)                ; Grafikpuffer ist neu?
          beq.s     nogrld
          bsr       cur_off             ; Cursor aus
          move.l    grbuf(PC),A2        ; Grafikpuffer
          move.l    logbs(PC),A4        ; Logischer Bildschirm
          move.w    #1999,D1            ; 2000 mal
loop103   move.l    (A2)+,(A4)+         ; 16 Bytes
          move.l    (A2)+,(A4)+
          move.l    (A2)+,(A4)+
          move.l    (A2)+,(A4)+
          dbra      D1,loop103
nogrld    move.l    #exitconst,D0
          moveq     #0,D1               ; D1 markiert Go-Funktion
          addq.l    #4,SP
COntend   rts

D         bsr       getadr              ; Disassembler
          beq       Dend
          bsr       tsteven             ; Gerade Adresse?
          bcs       Dend
          movea.l   A4,A5
          lea       dcflag(PC),A2       ; Keine DC.W-Ausgabe zu Anfang
          sf        (A2)
          bsr       komtst              ; Komma?
          bcc       nokm4
          bsr       getadr
          beq       Dend
          bsr       tsteven
          bcs       Dend
          bsr       komtst              ; Auf Diskette disassemblieren?
          bcc       nokm4
          moveq     #74,D4              ; Filename holen
          bsr       rdfname
          beq       Dend
          lea       hbflag(PC),A2       ; Hexbyte-Ausgabe wird zunÑchst
          st        (A2)                ; angenommen
          lea       appendda(PC),A2     ; File mit demselben Namen wird
          sf        (A2)                ; normalerweise Åberschrieben
          bsr       komtst              ; Hexbyteflag holen?
          bcc.s     nokm5
          bsr       setprm
          sf        -12(A2)             ; Keine BinÑrzahlen
          sf        -10(A2)             ; Keine Hexadezimalzahlen
          move.b    #dec,-8(A2)         ; Normalformat Dezimal
          move.b    #1,-4(A2)           ; Hîchststellenzahl Dezimal
          bsr       rdval
          beq.s     Dend
          cmp.w     #1,D1
          bhi.s     Derr
          bne.s     Dkt1
          lea       hbflag(PC),A2       ; Keine Hexbyte-Ausgabe
          sf        (A2)
Dkt1      bsr       komtst              ; AnhÑng-Flag einlesen?
          bcc.s     nokm5
          bsr       rdval
          beq.s     Dend
          cmp.w     #1,D1
          bhi.s     Derr
          bne.s     Dkt2
          lea       appendda(PC),A2     ; File anhÑngen
          st        (A2)
Dkt2      bsr       komtst              ; DC.W-Ausgabe-Flag einlesen?
          bcc.s     nokm5
          bsr       rdval
          beq.s     Dend
          cmp.w     #2,D1
          bhi.s     Derr2
          beq.s     Ddclout
          tst.w     D1
          beq.s     nokm5
          lea       dcflag(PC),A2       ; Bei Wert 1 nur DC.W-Ausgabe
          st        (A2)
          bra.s     Ddcout
Ddclout   lea       dcflag(PC),A2       ; Bei 2 DC.L-Ausgabe
          move.b    #$7F,(A2)
Ddcout    lea       dcbrk(PC),A2        ; Bei der Endadresse hîrt die DC-
          move.l    A4,(A2)             ; Ausgabe auf
          addq.l    #2,(A2)
nokm5     bsr       savedasm            ; Ausgabe auf Diskette
          bra.s     Dend
nokm4     lea       dlnout(PC),A3       ; Ausgabe auf dem Bildschirm
          bsr       wait
          bra.s     Dend
Derr      lea       errmsg83(PC),A1     ; '0..1 expected'
          bra       errorout
Derr2     lea       errmsg96(PC),A1     ; '0..2 expected'
          bra       errorout
Dend      lea       dcflag(PC),A2       ; Keine DC-Ausgabe mehr
          sf        (A2)
          rts

DB        movea.l   #$000,A5            ; Anzeige eines Sektors
          movea.l   #$1F0,A4
          bsr       smchrtst
          bcc.s     nordseca
          bsr       getadr
          beq.s     DBend
          bsr       mkeven
          cmpa.l    #$200,A4
          bcc.s     DBerr
          movea.l   A4,A5
          bsr       komtst
          bcc.s     nordseca
          bsr       getadr
          beq.s     DBend
          bsr       mkeven
          cmpa.l    #$200,A4
          bcc.s     DBerr
nordseca  moveq     #hex,D3
          sf        D4
          sf        D5
          lea       lfillchar(PC),A3    ; Punkt ersetzt bestimmten ASCII-
          move.b    #'.',(A3)           ; Bereich beim Drucker
          lea       fmlnout(PC),A3
          bra       wait
DBerr     lea       errmsg87(PC),A1
          bra       errorout
DBend     rts

DIR       bsr       smchrtst            ; Disketteninhaltsverzeichnis
          bcc.s     nofname             ; ausgeben
          moveq     #5,D4
          bsr       rdfname
          beq.s     DIRend
          bra.s     dirout
nofname   lea       strbuf(PC),A3
          move.b    #'*',(A3)
          move.b    #'.',1(A3)
          move.b    #'*',2(A3)
          clr.b     3(A3)
dirout    lea       attribute(PC),A1
          move.w    #$16,(A1)           ; Einschlieûlich der Ordner, der
          bsr       sdta                ; System-Files und der verborgenen
          bne.s     DIRend              ; Dateien
          move.b    printer(PC),D1      ; Drucker gegebenenfalls
          lea       prton(PC),A6        ; einschalten
          tst.b     D1
          sne       (A6)
          bsr       wrtfname
          lea       dirlnout(PC),A3
          bra       wait
DIRend    rts

DIV       lea       divsbr(PC),A3       ; Division
          bra       op
divsbr    move.l    D5,D2
          move.l    D5,D0               ; Divident
          bpl.s     nomi3               ; Positiv
          neg.l     D0
nomi3     move.l    D1,D3               ; Teiler
          bpl.s     nomi4               ; Positiv
          neg.l     D3
nomi4     bsr       div32
          move.l    D0,D5               ; Quotient
          eor.l     D1,D2               ; Vorzeichen des Quotienten
          bpl.s     DIVend              ; Nicht vorzeichenbehaftet
          neg.l     D5
DIVend    rts

DMsk      lea       prm(PC),A2          ; Disassembler Output Mask einlesen
          st        (A2)                ; Nur BinÑrzahlen zulassen
          sf        1(A2)
          sf        2(A2)
          sf        3(A2)
          move.b    #bin,4(A2)
          move.b    #1,5(A2)            ; Nur Zahlen mit bis zu 11 Stellen
          move.b    #11,6(A2)           ; werden akzeptiert
          bsr       rdval               ; Maske einlesen
          beq.s     DMskend
          lea       daoutmsk(PC),A3     ; Wert Åbertragen
          move.w    D1,(A3)
DMskend   rts

DOFF      lea       dasmflag(PC),A3     ; Automatisches Disassemblieren beim
          sf        (A3)                ; A-Befehl ausschalten
          rts

DON       lea       dasmflag(PC),A3     ; Automatisches Disassemblieren beim
          st        (A3)                ; A-Befehl einschalten
          rts

DRV       bsr       smchrtst            ; Laufwerk bestimmen
          bcc.s     DRVerr
          bsr       getchrbuf
          cmp.b     #'A',D1
          bcs.s     DRVerr
          cmp.b     #'Z',D1
          bhi.s     DRVerr
          cmpa.l    A0,A1               ; Zeilenende Åberschritten?
          bhi.s     DRVerr
          cmpi.b    #':',(A1)
          bne.s     DRVerr
          sub.w     #65,D1
          bra       setdrive            ; Laufwerk bestimmen
DRVerr    lea       errmsg82(PC),A1
          bra       errorout

EOR       lea       eorsbr(PC),A3       ; Exklusiv-Oder-VerknÅpfung
          bra       op
eorsbr    eor.l     D1,D5
          rts

ERA       moveq     #76,D4              ; File lîschen
          bsr       rdfname
          beq.s     ERAend
          bra       kill
ERAend    rts

EXB       movea.l   flopbuf(PC),A4      ; Sektorpuffer vertauschen
          movea.l   flopbuf2(PC),A5
          moveq     #127,D0
loop76    move.l    (A4),D1
          move.l    (A5),(A4)+
          move.l    D1,(A5)+
          dbra      D0,loop76
          rts

EXecprg   bsr       smchrtst            ; File ausfÅhren
          bcs.s     pexec03
          move.l    pexecstrt(PC),D2    ; AusfÅhrbares Programm im Speicher?
          beq       EXerr2              ; Nein
          movea.l   D2,A5               ; Startadresse nach A5
          suba.l    A4,A4               ; A4 und
          suba.l    A6,A6               ; A6 lîschen
          moveq     #4,D5               ; Go-Option
          bra       startex2
pexec03   moveq     #77,D4
          bsr       rdfname             ; Programmfilename einlesen
          beq       EXerrend
          lea       80(A3),A4
loop106   move.b    0(A3,D2.w),-(A4)    ; String an das hintere Ende des
          dbra      D2,loop106          ; Puffers Åbertragen
          movea.l   A4,A5
          clr.b     -(A5)               ; ZunÑchst kein Kommando
          suba.l    A6,A6               ; und kein Environment (0L)
          moveq     #0,D5               ; Mode 0 (laden und starten)
          bsr       komtst
          bcc.s     startex1
          move.b    #73,11(A2)          ; Hîchstzeichenzahl
          bsr       rdval               ; Kommando einlesen
          beq       EXerrend            ; Fehler
          tst.b     (A3)                ; Nullstring?
          beq.s     rdmode
          movea.l   A4,A5
          move.w    D2,D1
          subq.w    #1,D1
loop107   move.b    0(A3,D1.w),-(A5)    ; String Åbertragen
          dbra      D1,loop107
          move.b    D2,-(A5)            ; LÑnge des Strings
rdmode    bsr       komtst
          bcc.s     startex1
          st        1(A2)               ; Nur noch Dezimalzahlen zulassen
          sf        3(A2)               ; Strings sperren
          move.b    #dec,4(A2)          ; Normalformat
          move.b    #1,7(A2)            ; Mindeststellenzahl
          move.b    #1,8(A2)            ; Hîchststellenzahl
          bsr       rdval               ; Mode einlesen
          beq       EXerrend
          tst.l     D1                  ; Nur 0 und 3 sind erlaubt
          beq.s     alwd03
          cmp.l     #3,D1
          bne       EXerr1
alwd03    move.w    D1,D5
startex1  move.l    pexecstrt(PC),D2    ; Falls Programm schon geladen,
          beq.s     startex2            ; reservierten Speicherplatz wieder
          move.l    D2,-(SP)            ; freigeben
          move.w    #MFREE,-(SP)
          trap      #GEMDOS
          addq.l    #6,SP
startex2  movea.l   A4,A3               ; Filename
          movea.l   A5,A4               ; Command
          movea.l   A6,A5               ; Environment
          move.w    D5,D1               ; Mode
          bsr       rstkeys
          bsr       pexec
          bsr       initkeys
          tst.l     D0
          bmi.s     EXend
          tst.w     D1                  ; Load and go?
          beq.s     EXend
          cmp.w     #4,D1               ; Go?
          beq.s     EXend
          lea       pexecstrt(PC),A4    ; Startadresse merken
          move.l    D0,(A4)
          moveq     #6,D2               ; Stellenzahl
          moveq     #hex,D3             ; Hexadezimalzahl
          sf        D4                  ; Ohne Dollar-Zeichen
          sf        D5                  ; Keine negative Zahl
          lea       text21(PC),A1       ; Bereiche, die das Programm
          bsr       comtxtout           ; belegt, ausgeben
          move.l    D0,D1               ; Startadresse Basepage
          bsr       wrtvalln
          lea       text22(PC),A1
          bsr       comtxtout
          movea.l   D0,A4
          move.l    8(A4),D1            ; Text-Segment
          bsr       wrtvalln
          lea       text23(PC),A1
          bsr       comtxtout
          move.l    16(A4),D1           ; Data-Segment
          bsr       wrtvalln
          lea       text24(PC),A1
          bsr       comtxtout
          move.l    24(A4),D1           ; BSS-Segment ...
          bsr       wrtvalln
          lea       text25(PC),A1
          bsr       comtxtout
          add.l     28(A4),D1           ; ... plus BSS-LÑnge gleich
          bra       wrtvalln            ; Endadresse
EXerr1    lea       errmsg98(PC),A1
          bra       errorout
EXerr2    lea       errmsg99(PC),A1
          bra       errorout
EXend     lea       pexecstrt(PC),A1    ; Kein Pexec(4) mehr mîglich
          clr.l     (A1)                ; nach Pexec(0) und Pexec(4)
EXerrend  rts

F         bsr       getadr              ; FÅllen von Speicherbereichen
          beq.s     Fend                ; Fehler
          movea.l   A4,A3
          bsr       komtsterr           ; Komma?
          bcc.s     Fend                ; Fehler
          bsr       getadr              ; Endadresse
          beq.s     Fend
          movea.l   A4,A5
          movea.l   A3,A4
          bsr       komtsterr
          bcc.s     Fend
          st        -9(A2)              ; Strings zulassen
          move.b    #2,-3(A2)           ; Mindeststellenzahl Hexadezimal
          move.b    #2,-2(A2)           ; Hîchststellenzahl
          move.b    #75,-1(A2)          ; Hîchstzeichenzahl
          sf        (A2)+               ; Keine Komma-öberprÅfung
          move.b    #1,(A2)+            ; Mindestzahl der Bytes
          move.b    #75,(A2)            ; Hîchstzahl
          bsr       rdlnval
          beq.s     Fend                ; Fehler
          bra       fill
Fend      rts

G         lea       reg(PC),A2          ; Starten von Maschinensprache-
          movea.l   68(A2),A4           ; programmen
          bsr       smchrtst
          bcc.s     nga
          bsr       getadr
          beq.s     Gend                ; Fehler
nga       bsr       tsteven             ; Adresse gerade?
          bcs.s     Gend
          lea       reg(PC),A2
          move.l    A4,68(A2)
          move.l    #exitconst,D0
          moveq     #0,D1               ; D1 markiert Go-Funktion
          addq.l    #4,SP
Gend      rts

H         bsr       getadr              ; Suchen in Speicherbereichen
          beq.s     Hend                ; Fehler
          movea.l   A4,A5
          bsr       komtsterr           ; Komma?
          bcc.s     Hend                ; Fehler
          bsr       getadr              ; Endadresse
          beq.s     Hend
          bsr       komtsterr
          bcc.s     Hend
          st        -9(A2)              ; Strings zulassen
          move.b    #2,-3(A2)           ; Mindeststellenzahl Hexadezimal
          move.b    #2,-2(A2)           ; Hîchststellenzahl
          move.b    #75,-1(A2)          ; Hîchstzeichenzahl
          sf        (A2)+               ; Keine Komma-öberprÅfung
          move.b    #1,(A2)+            ; Mindestzahl der Bytes
          move.b    #75,(A2)            ; Hîchstzahl
          bsr       rdlnval
          beq.s     Hend                ; Fehler
          movea.l   A3,A0
          lea       hlnout(PC),A3
          bra       wait
Hend      rts

HS        bsr       gettrksec           ; Suchen in Sektoren
          beq       HSend
          bsr       komtsterr
          bcc       HSend
          bsr       getadr
          beq       HSerr
          cmpa.l    #$200,A4
          bcc       HSerr
          move.l    D1,D3
          move.l    D2,D5
          movea.l   A4,A5
          bsr       komtsterr
          bcc.s     HSend
          bsr       gettrksec
          beq.s     HSend
          bsr       komtsterr
          bcc.s     HSend
          bsr       getadr
          beq.s     HSerr
          cmpa.l    #$200,A4
          bcc.s     HSerr
          move.l    D1,D6
          move.l    D2,D7
          bsr       komtsterr
          bcc.s     HSend
          st        -9(A2)              ; Strings zulassen
          move.b    #2,-3(A2)           ; Mindeststellenzahl Hexadezimal
          move.b    #2,-2(A2)           ; Hîchststellenzahl
          move.b    #65,-1(A2)          ; Hîchstzeichenzahl
          sf        (A2)+               ; Keine Komma-öberprÅfung
          move.b    #1,(A2)+            ; Mindestzahl der Bytes
          move.b    #65,(A2)            ; Hîchstzahl
          bsr       rdlnval
          beq.s     HSend               ; Fehler
          movea.l   A3,A0
          movea.l   flopbuf3(PC),A6
          move.w    #0,D1               ; Bootsektor einlesen
          move.w    #1,D2
          bsr       flprd
          bmi.s     HSend
          lea       spt(PC),A1          ; Sektoren pro Track merken
          clr.w     (A1)
          move.b    24(A6),1(A1)
          lea       hslnout(PC),A3
          bra       wait
HSerr     lea       errmsg87(PC),A1
          bra       errorout
HSend     rts

I         rts

INF                                     ; Ausgabe der Start- und Endadresse
infout    moveq     #6,D2               ; Stellenzahl
          moveq     #hex,D3             ; Hexadezimalzahl
          sf        D4                  ; Ohne Dollar-Zeichen
          sf        D5                  ; Keine negative Zahl
          lea       text04(PC),A1
          bsr       comtxtout
          move.l    startaddr(PC),D1    ; Startadresse des Monitors
          bsr       wrtvalln
          lea       text06(PC),A1
          bsr       comtxtout
          movea.l   flopbuf(PC),A4      ; Startadresse der Sektorenpuffer
          move.l    A4,D1
          bsr       wrtvalln
          lea       text05(PC),A1
          bsr       comtxtout
          movea.l   screen(PC),A4       ; Startadresse des Bildschirm-
          move.l    A4,D1               ; speichers
          bsr       wrtvalln
          lea       text01(PC),A1
          bsr       comtxtout
          move.l    endofscr(PC),D1     ; Endadresse des Bildschirm-
          subq.l    #1,D1               ; speichers
          bsr       wrtvalln
          lea       gbflag(PC),A4       ; Grafikpuffer-Flag
          tst.b     (A4)                ; Grafikpuffer vorhanden?
          beq.s     infoutend           ; Nein
          lea       text00(PC),A1
          bsr       comtxtout
          move.l    grbuf(PC),D1        ; Startadresse des Grafikpuffers
          bsr       wrtval
          moveq     #'-',D1
          bsr       chrout
          move.l    grbuf(PC),D1        ; Startadresse
          add.l     #32000,D1           ; plus 32000
          bra       wrtvalln
infoutend rts

K         rts

L         moveq     #75,D4              ; Datei laden
          bsr       rdfname
          beq.s     Lend
          bsr       komtsterr
          bcc.s     Lend
          bsr       getadr
          beq.s     Lend
          moveq     #0,D2
          bsr       komtst
          bcc.s     ldfile
          movea.l   A4,A5
          bsr       getadr
          beq.s     Lend
          move.l    A4,D2
          movea.l   A5,A4
ldfile    bsr       load
          bmi.s     Lend
          lea       text07(PC),A1       ; Endadresse ausgeben
          bsr       comtxtout
          move.l    A4,D1
          add.l     D2,D1
          subq.l    #1,D1
          moveq     #6,D2
          moveq     #hex,D3
          sf        D4
          sf        D5
          bra       wrtvalln
Lend      rts

LST       lea       lstaux(PC),A3       ; Drucker lÑuft parallel
          st        (A3)
          rts

M         bsr       getadr              ; Memory-Dump
          beq.s     Mend
          bsr       mkeven              ; Adresse gerade machen
          movea.l   A4,A5               ; Erste Adresse retten
          bsr       komtst              ; Komma?
          bcc.s     nokm3
          bsr       getadr
          beq.s     Mend
          bsr       mkeven
nokm3     moveq     #hex,D3             ; Hexadezimalzahlen
          sf        D4                  ; Ohne Dollar-Zeichen
          sf        D5                  ; Keine negativen Zahlen
          lea       lfillchar(PC),A3    ; Punkt ersetzt bestimmten ASCII-
          move.b    #'.',(A3)           ; Bereich beim Drucker
          lea       mlnout(PC),A3
          bra       wait
Mend      rts

MD        moveq     #77,D4              ; Subdirectory erzeugen
          bsr       rdfname
          beq.s     MDend
          bra       makedir
MDend     rts

MOD       lea       modsbr(PC),A3       ; Modulo-Berechnung
          bra       op
modsbr    move.l    D5,D2
          move.l    D5,D0               ; Divident
          bpl.s     nomi1               ; Positiv
          neg.l     D0
nomi1     move.l    D1,D3               ; Teiler
          bpl.s     nomi2               ; Positiv
          neg.l     D3
nomi2     bsr       div32
          move.l    D4,D5               ; Rest
          tst.l     D2                  ; Vorzeichen des Rests
          bpl.s     MODend
          neg.l     D5
MODend    rts

MUL       lea       mulsbr(PC),A3       ; Multiplikation
          bra       op
mulsbr    move.l    D5,D2
          move.l    D5,D0               ; Erster Faktor
          bpl.s     nomi5               ; Positiv
          neg.l     D0
nomi5     move.l    D1,D3               ; Zweiter Faktor
          bpl.s     nomi6               ; Positiv
          neg.l     D3
nomi6     bsr       mul32
          move.l    D0,D5               ; Produkt
          eor.l     D1,D2               ; Vorzeichen des Produktes
          bpl.s     MULend              ; Nicht vorzeichenbehaftet
          neg.l     D5
MULend    rts

OR        lea       orsbr(PC),A3        ; Oder-VerknÅpfung
          bra       op
orsbr     or.l      D1,D5
          rts

PHB       movea.l   flopbuf(PC),A4      ; Sektordaten retten
          movea.l   #$1FF,A5
          adda.l    A4,A5
          movea.l   flopbuf2(PC),A6
          bra       transfer

PLB       movea.l   flopbuf2(PC),A4     ; Alte Sektordaten holen
          movea.l   #$1FF,A5
          adda.l    A4,A5
          movea.l   flopbuf(PC),A6
          bra       transfer

POFF                                    ; Drucker-Betrieb abschalten
poffsbr   lea       printer(PC),A3
          sf        (A3)
          lea       prton(PC),A3
          sf        (A3)
          lea       lstaux(PC),A3
          st        (A3)                ; Parallele Druckerschnittstelle
          lea       lfillchar(PC),A3    ; wird zunÑchst angenommen
          clr.b     (A3)
          rts

PON       bsr       prttst              ; Drucker-Betrieb einschalten
          bne.s     setprt              ; Ja, dann Drucker-Flag setzen
          lea       errmsg50(PC),A1
          bra       errorout
setprt    lea       printer(PC),A3
          st        (A3)
          lea       prton(PC),A3
          st        (A3)
          bsr       prtcr
          sf        (A3)
          rts

Q         move.l    #exitconst,D0       ; RÅckkehr zum Desktop
          moveq     #-1,D1              ; D1 markiert Quit-Funktion
          addq.l    #4,SP
          rts

R                                       ; Anzeige der Prozessorregister
regout    lea       regtab1(PC),A3
          moveq     #0,D1
          lea       radrtab(PC),A5
          lea       reg(PC),A6
          move.w    #7,D6
          sf        D4
          sf        D5
loop23    bsr       sem
          bsr       rout
          bsr       spc
          bsr       rout
          bsr       cret
          dbra      D6,loop23
          move.w    #1,D6
loop25    bsr       sem
          move.w    #15,D7
          bsr       spcn
          bsr       rout
          bsr       cret
          dbra      D6,loop25
          lea       srflags(PC),A1
          bsr       textout
          bsr       cret
          bsr       sem
          bsr       spc
          addq.l    #1,D1
          moveq     #5,D3
          bsr       wrtwrd
          move.b    (A5)+,D7
          ext.w     D7
          move.l    0(A6,D7.w),D1
          moveq     #16,D2
          moveq     #bin,D3
          bra       wrtvalln

REN       moveq     #73,D4              ; File umbenennen
          bsr       rdfname
          beq.s     RENend
          lea       80(A3),A4
loop58    move.b    0(A3,D2.w),-(A4)    ; String an das hintere Ende des
          dbra      D2,loop58           ; Puffers Åbertragen
          bsr       komtsterr
          bcc.s     RENend
          bsr       rdfname
          beq.s     RENend
          bra       rname
RENend    rts

RMD       moveq     #76,D4              ; Subdirectory lîschen
          bsr       rdfname
          beq.s     RMDend
          bra       relmoddir
RMDend    rts

ROFF      lea       regflag(PC),A3      ; Registerausgabe bei BRK aus-
          sf        (A3)                ; schalten
          rts

RON       lea       regflag(PC),A3      ; Registerausgabe bei BRK ein-
          st        (A3)                ; schalten
          rts

RS        bsr       gettrksec           ; Sektor von Diskette einlesen
          beq.s     RSecend
          movea.l   flopbuf(PC),A6
          bra       flprd
RSecend   rts

S         moveq     #73,D4              ; Speicherbereich auf Diskette
          bsr       rdfname             ; schreiben
          beq.s     Send
          bsr       komtsterr
          bcc.s     Send
          bsr       getadr              ; Startadresse holen
          beq.s     Send
          movea.l   A4,A5
          bsr       komtsterr
          bcc.s     Send
          bsr       getadr              ; Endadresse holen
          beq.s     Send
          bra       save
Send      rts

SIDE      bsr       setprm              ; Diskettenseite bestimmen
          sf        -12(A2)             ; Keine BinÑrzahlen
          sf        -10(A2)             ; Keine Hexadezimalzahlen
          move.b    #dec,-8(A2)         ; Normalformat Dezimal
          move.b    #1,-4(A2)           ; Hîchststellenzahl Dezimal
          bsr       rdval               ; Seitennummer einlesen
          beq.s     SIDEend
          cmp.w     #1,D1
          bhi.s     SIDEerr
          lea       diskside(PC),A1
          move.w    D1,(A1)
          bra.s     SIDEend
SIDEerr   lea       errmsg83(PC),A1
          bra       errorout
SIDEend   rts

SUB       lea       subsbr(PC),A3       ; Subtraktion
          bra       op
subsbr    sub.l     D1,D5
          rts

T         bsr       getadr              ; Verschieben von Speicherbereichen
          beq.s     Tend                ; Fehler
          movea.l   A4,A3
          bsr       komtsterr           ; Komma?
          bcc.s     Tend                ; Fehler
          bsr       getadr              ; Endadresse
          beq.s     Tend
          movea.l   A4,A5
          bsr       komtsterr
          bcc.s     Tend
          bsr       getadr              ; Zieladresse
          beq.s     Tend
          movea.l   A4,A6
          movea.l   A3,A4
          bra       transfer
Tend      rts

V         moveq     #$00,D6             ; Anzeige der Exception-Vektoren
          movea.l   #vec00,A5           ; Erster Vektor
          movea.l   #vecFF,A4           ; Letzter Vektor
          bsr       smchrtst
          bcc.s     nordvec
          bsr       getvec              ; Ersten Vektor einlesen
          beq.s     Vend                ; Fehler
          move.b    D1,D6
          movea.l   A4,A5
          bsr       komtst              ; Noch ein Vektor?
          bcc.s     nordvec
          bsr       getvec              ; Zweiten Vektor holen
          beq.s     Vend
nordvec   moveq     #hex,D3             ; Hexadezimalzahlen
          sf        D5                  ; Keine negativen Zahlen
          lea       vlnout(PC),A3
          bra       wait
Vend      rts

W         bsr       getadr              ; Bytes und Texte in den Speicher
          beq.s     Wend                ; schreiben
          st        -9(A2)              ; Strings zulassen
          move.b    #2,-3(A2)           ; Mindeststellenzahl Hexadezimal
          move.b    #2,-2(A2)           ; Hîchststellenzahl
          move.b    #77,-1(A2)          ; Hîchstzeichenzahl
          sf        (A2)+               ; Keine Komma-öberprÅfung
          move.b    #0,(A2)+            ; Mindestzahl der Bytes
          move.b    #77,(A2)            ; Hîchstzahl
          bsr       rdlnval
          beq.s     Wend                ; Fehler
          subq.w    #1,D4
loop37    move.b    (A3)+,(A4)+         ; Byte in Speicher Åbertragen
          dbra      D4,loop37
          bsr       point2              ; NÑchste Zeile
          moveq     #'W',D1
          bsr       chrout
          bsr       spc
          move.l    A4,D1
          moveq     #6,D2
          moveq     #hex,D3
          sf        D4
          sf        D5
          bsr       wrtval
          moveq     #4,D7
          bsr       spcn
          moveq     #0,D0
          addq.l    #4,SP               ; Keine neue Zeile
Wend      rts

WB        bsr       getadr              ; Sektormanipulation
          beq.s     WBend
          cmpa.l    #$200,A4            ; Adresse zu groû?
          bcc.s     WBerr
          st        -9(A2)              ; Strings zulassen
          move.b    #2,-3(A2)           ; Mindeststellenzahl Hexadezimal
          move.b    #2,-2(A2)           ; Hîchststellenzahl
          move.b    #77,-1(A2)          ; Hîchstzeichenzahl
          sf        (A2)+               ; Keine Komma-öberprÅfung
          move.b    #0,(A2)+            ; Mindestzahl der Bytes
          move.b    #77,(A2)            ; Hîchstzahl
          bsr       rdlnval
          beq.s     WBend               ; Fehler
          movea.l   flopbuf(PC),A5
          subq.w    #1,D4
loop56    move.b    (A3)+,0(A5,A4.l)    ; Byte in Speicher Åbertragen
          addq.l    #1,A4
          cmpa.l    #$200,A4
          dbcc      D4,loop56
          bra.s     WBend
WBerr     lea       errmsg87(PC),A1
          bra       errorout
WBend     rts

WS        bsr       gettrksec           ; Sektor auf Diskette schreiben
          beq.s     WSend
          movea.l   flopbuf(PC),A6
          bra       flpwr
WSend     rts

X         move.l    #exitconst,D0       ; RÅckkehr zum Desktop
          move.l    #$7FFFFFFF,D1       ; D1 markiert Exit-Funktion
          addq.l    #4,SP
          rts

hexins    bsr       getadr              ; Maschinensprache hexadezimal
          beq       hexinsend           ; einlesen
          bsr       tsteven             ; Adresse gerade?
          bcs       hexinsend
          movea.l   A4,A5               ; Adresse merken
          sf        -11(A2)             ; Keine Dezimalzahlen
          move.b    #4,-3(A2)           ; Mindeststellenzahl
          move.b    #4,-2(A2)           ; Hîchststellenzahl
          move.w    #4,D4               ; Hîchstens 10 Bytes einlesen
          lea       valbuf(PC),A3       ; Puffer fÅr den Hexcode
loop94    bsr       readval
          move.w    D1,(A3)+            ; Wert in den Puffer
          tst.w     D2                  ; Fehler?
          dbeq      D4,loop94
          bne.s     hexinswmi           ; Kein Fehler
          cmp.w     #4,D4               ; Noch kein Wort eingelesen?
          beq.s     hexinsre            ; Dann wird Fehler ausgegeben
hexinswmi addq.w    #1,D4               ; Zahl der eingelesenen Bytes
          sub.w     #5,D4               ; berechnen
          neg.w     D4
          add.w     D4,D4
          move.w    D4,-(SP)            ; Zahl der Bytes retten
          lea       valbuf(PC),A3
          move.b    dcflag(PC),D0
          bsr       disasm              ; Puffer disassemblieren
          cmp.w     (SP)+,D6            ; Genug Bytes eingelesen?
          bhi.s     hexinserr
          subq.w    #1,D6
loop95    move.b    (A3)+,(A4)+         ; Puffer an die angegebene Adresse
          dbra      D6,loop95           ; Åbertragen
          movea.l   A5,A3               ; Puffer vollstÑndig disassemblieren
          lea       mnembuf(PC),A4
          bsr       wrtmcins
          move.w    #1,D1               ; Neue disassemblierte Zeile aus-
          bsr       chrout              ; geben
          bsr       wrtdislin
          moveq     #5,D1               ; Rest der Zeile lîschen
          bsr       chrout
          bsr       cret
          add.l     D6,A3               ; NÑchste Zeile ausgeben
          bsr       wrtmcins
          bsr       wrtdislin
          lea       text20(PC),A1
          bsr       textout
          addq.l    #4,SP               ; Keinen Punkt ausgeben
hexinsend rts
hexinsre  add.w     D1,D1               ; Fehlerausgabe fÅr readval
          jmp       hexinsetb(PC,D1.w)
hexinsetb bra.s     hexinse1
          bra.s     hexinse2
          bra.s     hexinse3
          rts
          bra.s     hexinse5
          bra.s     hexinse6
hexinse1  lea       errmsg01(PC),A1
          bra.s     hexinseo
hexinse2  lea       errmsg02(PC),A1
          bra.s     hexinseo
hexinse3  lea       errmsg03(PC),A1
          bra.s     hexinseo
hexinse5  lea       errmsg05(PC),A1
          bra.s     hexinseo
hexinse6  lea       errmsg06(PC),A1
          bra.s     hexinseo
hexinserr lea       errmsg30(PC),A1     ; 'Not enough Bytes'
hexinseo  bra       errorout

poke      bsr       getadr              ; Speichermanipulation
          beq.s     pokeend
          bsr       tsteven             ; Gerade Adresse?
          bcs.s     pokeend
          move.b    #4,-3(A2)           ; Mindeststellenzahl Hexadezimal
          move.b    #4,-2(A2)           ; Hîchststellenzahl
          sf        (A2)+               ; Keine Komma-öberprÅfung
          move.b    #2,(A2)+            ; Mindestzahl der Bytes
          move.b    #16,(A2)            ; Hîchstzahl
          bsr       rdlnval
          beq.s     pokeend             ; Fehler
          subq.w    #1,D4
loop22    move.b    (A3)+,(A4)+         ; Wertepuffer Åbertragen
          dbra      D4,loop22
pokeend   rts

pokereg   lea       radrtab(PC),A6      ; Registermanipulation
          bsr       setprm
          sf        -12(A2)             ; Keine BinÑrzahlen
          sf        -11(A2)             ; Keine Dezimalzahlen
          move.b    #16,-7(A2)          ; BinÑrzahl nur mit 16 Stellen
          move.b    #16,-6(A2)
loop34    lea       regchr1(PC),A2
          bsr       getwrd
          beq.s     prerr
          lea       regtab1(PC),A3
          bsr       tstwrd
          beq.s     prerr
          subq.l    #1,D1
          move.b    0(A6,D1.w),D7       ; Offset fÅr den Registerpuffer
          ext.w     D7
          lea       prm(PC),A2          ; Parameterliste fÅr rdval
          cmp.w     #64,D7              ; Statusregister?
          bne.s     rv
          st        0(A2)               ; BinÑrzahlen
          sf        2(A2)               ; Keine Hexadezimalzahlen
          move.b    #bin,4(A2)          ; Normalformat BinÑr
rv        bsr       rdval
          beq.s     prend               ; Fehler
          lea       reg(PC),A4          ; Registerpuffer
          move.l    D1,0(A4,D7.w)
          sf        0(A2)               ; Keine BinÑrzahlen
          st        2(A2)               ; Hexadezimalzahlen
          move.b    #hex,4(A2)          ; Normalformat Hexadezimal
          bsr       smchrtst
          bcs       loop34
prend     rts
prerr     lea       errmsg60(PC),A1
          bra       errorout

pokevec   bsr       getvec              ; Vektormanipulation
          beq.s     pvend               ; Fehler
          move.b    #8,-3(A2)           ; Nur achtstellige Hexadezimal-
          move.b    #8,-2(A2)           ; zahlen
          bsr       rdval
          beq.s     pvend
          move.l    D1,(A4)
pvend     rts

pokefbuf  bsr       getadr              ; Sektormanipulation
          beq.s     pbend
          bsr       tsteven             ; Gerade Adresse?
          bcs.s     pbend
          cmpa.l    #$200,A4            ; Adresse zu groû?
          bcc.s     pberr
          move.b    #4,-3(A2)           ; Mindeststellenzahl Hexadezimal
          move.b    #4,-2(A2)           ; Hîchststellenzahl
          sf        (A2)+               ; Keine Komma-öberprÅfung
          move.b    #2,(A2)+            ; Mindestzahl der Bytes
          move.b    #16,(A2)            ; Hîchstzahl
          bsr       rdlnval
          beq.s     pbend               ; Fehler
          movea.l   flopbuf(PC),A5
          subq.w    #1,D4
loop54    move.b    (A3)+,0(A5,A4.l)    ; Wertepuffer Åbertragen
          addq.l    #1,A4
          cmpa.l    #$200,A4
          dbcc      D4,loop54
          bra.s     pbend
pberr     lea       errmsg87(PC),A1
          bra       errorout
pbend     rts

rem       rts
* Ende der Monitorfunktionen


          SECTION   DATA

          INCLUDE   MONST1.DTA
          INCLUDE   MONST2.DTA
          INCLUDE   MONST3.DTA
          INCLUDE   MONST4.DTA

* Tabellen
inschr:   dc.b      1,'AZ,:;>-\',0      ; ZulÑssige Zeichen fÅr
                                        ; die Monitorbefehle
instab:   dc.b      'A ADD AND AUX '    ; Tabelle aller Monitorbefehle
          dc.b      'BOFF BON C CD CLB CLR '
          dc.b      'CO D DB DIR DIV DM '
          dc.b      'DOFF DON DRV EOR '
          dc.b      'ERA EXB EX F G '
          dc.b      'H HS I INF K L '
          dc.b      'LST M MD MOD '
          dc.b      'MUL OR PHB PLB '
          dc.b      'POFF PON Q '
          dc.b      'R REN RMD ROFF RON '
          dc.b      'RS S SIDE '
          dc.b      'SUB T V W WB WS X '
          dc.b      ', : '
          dc.b      '; > - \'
          dc.b      0

regchr1:  dc.b      1,'07ACDPRSU:',0    ; ZulÑssige Zeichen fÅr die
                                        ; Registernamen
regtab1:  dc.b      'D0: A0: '          ; Erste Tabelle der Registernamen
          dc.b      'D1: A1: '          ; (fÅr die Registermanipulation)
          dc.b      'D2: A2: '
          dc.b      'D3: A3: '
          dc.b      'D4: A4: '
          dc.b      'D5: A5: '
          dc.b      'D6: A6: '
          dc.b      'D7: SSP: '
          dc.b      'USP: '
          dc.b      'PC: '
          dc.b      'SR: '
          dc.b      'A7: SP:'           ; Andere Namen fÅr den SSP
          dc.b      0

srflags:  dc.b      '.\      '          ; Namen der Flags des SR
          dc.b      'T-S--III---XNZVC'

radrtab:  dc.b      00,32,04,36         ; Offset-Adressen der Register im
          dc.b      08,40,12,44         ; Registerpuffer
          dc.b      16,48,20,52
          dc.b      24,56,28,72
          dc.b      60,68,64,72
          dc.b      72

errmsg00: dc.b      'Unknown',0
errmsg50: dc.b      'Printer not ready',0
errmsg60: dc.b      'Registername expected',0
errmsg82: dc.b      'Drivename expected',0
errmsg83: dc.b      '0..1 expected',0
errmsg87: dc.b      'Address not allowed',0
errmsg96: dc.b      '0..2 expected',0
errmsg97: dc.b      'MALLOC error',0
errmsg98: dc.b      '0 or 3 expected',0
errmsg99: dc.b      'No program in memory',0

title:    dc.b      '*** ST Monitor V1.2  '
          dc.b      'Copyright (C) 1988 '
          dc.b      'by Bernd Nottelmann '
          dc.b      '***',13,'.',13,0

text00:   dc.b      'Graphics Buffer          : ',0
text01:   dc.b      'End                      : ',0
text02:   dc.b      'Found  ',0
text03:   dc.b      'Break',13,0
text04:   dc.b      'Basepage, Program & Data : ',0
text05:   dc.b      'Screen                   : ',0
text06:   dc.b      'Sectorbuffers            : ',0
text07:   dc.b      'End: ',0
text08:   dc.b      'Bus error    ',0
text09:   dc.b      'Address error',0
text10:   dc.b      'Violation of privileg',13,0
text11:   dc.b      'Division by zero',13,0
text12:   dc.b      'Out of range',13,0
text13:   dc.b      '  Function Code=',0
text14:   dc.b      '  B/E=',0
text15:   dc.b      '  R/W=',0
text16:   dc.b      13,1,0
text17:   dc.b      13,0
text18:   dc.b      'Overflow',13,0
text19:   dc.b      1,'.A ',0
text20:   dc.b      13,1,9,9,9,9,0
text21:   dc.b      'Basepage : ',0
text22:   dc.b      'Text     : ',0
text23:   dc.b      'Data     : ',0
text24:   dc.b      'BSS      : ',0
text25:   dc.b      'End      : ',0


          SECTION   BSS

          INCLUDE   MONST1.BSS
          INCLUDE   MONST2.BSS
          INCLUDE   MONST3.BSS
          INCLUDE   MONST4.BSS

* Variablen und Puffer
startaddr:ds.l      1                   ; Startadresse des Monitors
endaddr:  ds.l      1                   ; Endadresse des Monitors

grbuf:    ds.l      1                   ; Adresse des Grafikpuffers

excbuf:   ds.l      8                   ; Zwischenspeicher fÅr Exceptions

quitinit: ds.b      1                   ; Flag fÅr quitbuf
regflag:  ds.b      1                   ; Flag fÅr Registerausgabe bei BRK
dasmflag: ds.b      1                   ; Flag fÅr automatisches Disassem-
                                        ; blieren beim A-Befehl
gbflag:   ds.b      1                   ; Flag fÅr automatisches Retten
                                        ; des Grafikbildschirmspeichers
                                        ; bei einer Exception
gbflag2:  ds.b      1                   ; Flag, daû Grafikpuffer noch nicht
                                        ; genutzt wurde

reg:      ds.l      19                  ; Registerspeicher
                                        ; Struktur: D0-D7,A0-A6,
                                        ;           USP,SR,PC,SSP
quitbuf:  ds.l      4                   ; Puffer fÅr Quit-Funktion

pexecstrt:ds.l      1                   ; Basepage-Startadresse fÅr Pexec(4)

base:     ds.l      1                   ; Line-A-Parameterfeld-Adresse
fonts:    ds.l      1                   ; Adresse des Font-Zeigerfelds

exctext:  ds.l      1                   ; Textausgabe bei Exceptions

          end

