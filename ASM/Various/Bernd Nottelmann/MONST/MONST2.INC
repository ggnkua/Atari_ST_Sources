*******************************
*  Monitor-Bibliothek Teil 1  *
*                             *
*       Copyright 1988        *
*     by Bernd Nottelmann     *
*******************************


SETDRV    equ       $0E                 ; GEMDOS-Routinen
CURRENT   equ       $19
SETDTA    equ       $1A
MKDIR     equ       $39
RMDIR     equ       $3A
CHDIR     equ       $3B
CREATE    equ       $3C
OPEN      equ       $3D
CLOSE     equ       $3E
READ      equ       $3F
WRITE     equ       $40
UNLINK    equ       $41
LSEEK     equ       $42
GETDIR    equ       $47
SFIRST    equ       $4E
SNEXT     equ       $4F
RENAME    equ       $56

SETEXEC   equ       5                   ; BIOS-Routine

FLOPRD    equ       8                   ; XBIOS-Routinen
FLOPWR    equ       9


* Unterprogramme
spc       move.w    D1,-(SP)            ; Blank ausgeben
          move.b    #' ',D1
          bsr       chrout
          move.w    (SP)+,D1
          rts

spcn      move.w    D7,-(SP)            ; n Blanks ausgeben
          subq.w    #1,D7               ; D7: n
loop24    bsr       spc
          dbra      D7,loop24
          move.w    (SP)+,D7
          rts
          
point1    moveq     #0,D0               ; Punkt ausgeben
point2    move.w    D1,-(SP)
          move.w    #'.',D1
          bsr       chrout
          move.w    (SP)+,D1
          rts

sem       bsr       point2              ; Semikolon ausgeben
          move.w    D1,-(SP)
          move.b    #';',D1
          bsr       chrout
          move.w    (SP)+,D1
          rts

com       bsr       point2              ; Kommentarzeichen ausgeben
          move.w    D1,-(SP) 
          move.b    #'\',D1
          bsr       chrout
          move.w    (SP)+,D1
          bra       spc

eq        move.w    D1,-(SP)            ; Gleichheitszeichen ausgeben
          move.w    #'=',D1
          bsr       chrout
          move.w    (SP)+,D1
          rts

prtcr     move.w    D1,-(SP)            ; CR auf Drucker ausgeben
          move.w    #13,D1
          bsr       prtout
          move.w    #10,D1
          bsr       prtout
          move.w    (SP)+,D1
          rts

cret      move.w    D1,-(SP)            ; CR ausgeben
          move.w    #13,D1
          bsr       chrout
          move.w    (SP)+,D1
          rts

comtxtout bsr       com                 ; Text mit Kommentarzeichen
          bra       textout             ; ausgeben

errorout  bsr       comtxtout           ; Fehlermeldung ausgeben
          bra       cret

getchrbuf clr.w     D1                  ; Zeichen aus Puffer holen
          move.b    (A1)+,D1
          cmp.b     #'a',D1             ; Test, ob Kleinbuchstabe
          bcs.s     gcend               ; Kein Kleinbuchstabe
          cmp.b     #'z',D1
          bhi.s     gcend
          sub.b     #32,D1              ; In Groûbuchstaben verwandeln
gcend     rts

smchrtst                                ; PrÅft, ob Zeichen vorhanden ist
loop15    cmpa.l    A0,A1               ; Zeilenende Åberschritten?
          bhi.s     sctend              ; Wenn ein Zeichen vorhanden ist,
          cmpi.b    #' ',(A1)+          ; dann ist C=1
          beq       loop15
          subq.l    #1,A1               ; Zeichen ist gefunden worden
          ori.b     #%00001,CCR         ; Setzen des Carry-Flags
sctend    rts

komtst    bsr       smchrtst            ; PrÅft, ob Komma vorhanden ist
          bcc.s     nokom
          cmpi.b    #',',(A1)           ; Komma vorhanden?
          bne.s     nokom
          addq.l    #1,A1
          ori.b     #%00001,CCR         ; Komma ist vorhanden
          rts
nokom     andi.b    #%11110,CCR         ; Kein Komma ist gefunden worden
          rts

komtsterr bsr       komtst              ; KommaprÅfung mit Fehlerausgabe
          bcc.s     err20
          rts
err20     lea       errmsg20(PC),A1
          bsr       errorout
          andi.b    #%11110,CCR         ; Fehler
          rts

mul32     movem.l   D5-D6,-(SP)         ; 32-Bit-Multiplikation
          moveq     #31,D6              ; D0: Erster Faktor
          moveq     #0,D5               ; D3: Zweiter Faktor
loop13    ror.l     #1,D3
          bcc.s     noadd
          add.l     D0,D5
noadd     add.l     D0,D0
          dbra      D6,loop13
          move.l    D5,D0
          movem.l   (SP)+,D5-D6
          rts                           ; D0: Produkt

div32     move.l    D6,-(SP)            ; 32-Bit-Division
          moveq     #31,D6              ; D0: Divident
          moveq     #0,D4               ; D3: Teiler
loop16    add.l     D0,D0
          addx.l    D4,D4
          cmp.l     D3,D4               ; D4<D3?
          bcs.s     nosub               ; Ja, dann keine Subtraktion
          sub.l     D3,D4
          addq.w    #1,D0
nosub     dbra      D6,loop16
          move.l    (SP)+,D6            ; D0: Quotient
          rts                           ; D4: Rest

tstchr    movem.l   D5/A2,-(SP)         ; Zeichen prÅfen
          clr.w     D5                  ; D1: Zeichen
          move.b    (A2)+,D5            ; A2: Tabelle der erlaubten Zeichen
          tst.w     D5
          beq.s     ctst
          subq.w    #1,D5
loop27    cmp.b     (A2)+,D1            ; Niedrigster Zeichencode
          bcs.s     lpend27
          cmp.b     (A2),D1             ; Hîchster Zeichencode
          bls.s     alwdchr
lpend27   addq.l    #1,A2
          dbra      D5,loop27
ctst      tst.b     (A2)                ; Ende der Tabelle?
          beq.s     nalwdchr
          cmp.b     (A2)+,D1            ; Zeichen zulÑssig?
          bne       ctst
alwdchr   move      #%00100,CCR         ; Erlaubtes Zeichen
          bra.s     tcend
nalwdchr  move      #%00000,CCR         ; UnzulÑssiges Zeichen
tcend     movem.l   (SP)+,D5/A2         ; Z=1: Zeichen erlaubt
          rts                           ; Z=0: Zeichen nicht erlaubt

getwrd    move.l    D0,-(SP)            ; Wort holen
          move.l    #'    ',D0          ; A2: Tabelle aller zulÑssigen
          moveq     #0,D2               ;     Zeichen
          st        D3
          bsr       smchrtst
          bcc.s     gwend               ; Zeilenende Åberschritten
          lea       strbuf(PC),A4
          movea.l   A4,A5
          sf        D3
loop26    bsr       getchrbuf
          bsr       tstchr
          bne.s     gwend
          addq.l    #1,D2               ; Ein Zeichen mehr
          cmp.b     #4,D2
          bhi.s     nshft
          lsl.l     #8,D0
          move.b    D1,D0
nshft     move.b    D1,(A5)+
          cmpa.l    A0,A1               ; Zeilenende Åberschritten?
          bls       loop26
          addq.l    #1,A1
gwend     subq.l    #1,A1
          subq.l    #1,A5               ; D1: Erste vier Zeichen
          move.l    D0,D1               ; D2: LÑnge/Fehler-Flag
          move.l    (SP)+,D0            ; D3: Fehlertyp ($00: 03; $FF: 04)
          tst.l     D2                  ; A4: Wortanfang
          rts                           ; A5: Wortende

tstwrd    movem.l   D2-D4/A2-A3,-(SP)   ; Wort prÅfen
          moveq     #0,D1               ; A3: Worttabelle
loop28    addq.l    #1,D1               ; A4: Wortanfang
          movea.l   A4,A2               ; A5: Wortende
whlspc1   cmpi.b    #' ',(A3)
          bne.s     loop29
          addq.l    #1,A3
          bra       whlspc1
loop29    tst.b     (A3)                ; Ende der Worttabelle?
          seq       D2
          cmpi.b    #' ',(A3)
          seq       D3
          cmpa.l    A5,A2               ; Wortende Åberschritten?
          shi       D4
          tst.b     D2
          bne.s     brklp29
          tst.b     D3
          bne.s     brklp29
          tst.b     D4
          bne.s     brklp29
          cmpm.b    (A2)+,(A3)+
          beq       loop29
          subq.l    #1,A3
brklp29   tst.b     D4                  ; Wortende Åberschritten?
          bne.s     wrdend
          tst.b     D2                  ; Ende der Worttabelle?
          beq.s     loop30
          bra.s     twerr               ; Fehler ist aufgetreten
wrdend    tst.b     D2                  ; Ende der Worttabelle?
          bne.s     brklp28
          tst.b     D3                  ; Blank?
          bne.s     brklp28
loop30    tst.b     (A3)
          beq.s     twerr
          cmpi.b    #' ',(A3)+
          bne       loop30
          bra       loop28
twerr     moveq     #0,D1
brklp28   movem.l   (SP)+,D2-D4/A2-A3
          tst.l     D1
          rts                           ; D1: Wortnummer/Fehler-Flag

wrtwrd    movem.l   D1/D3-D4/A3,-(SP)   ; Wort aus Worttabelle schreiben
          move.w    D1,D4               ; D1: Wortnummer
          subq.w    #1,D4               ; D3: WortlÑnge
loop31    moveq     #0,D2
          tst.b     (A3)                ; Ende der Worttabelle?
          beq.s     wwend
whlspc2   cmpi.b    #' ',(A3)
          bne.s     wsend2
          addq.l    #1,A3
          bra       whlspc2
wsend2    tst.b     (A3)
          beq.s     wwend
loop32    move.b    (A3)+,D1
          addq.l    #1,D2
          tst.w     D4                  ; Ausgabe?
          bne.s     noout
          bsr       chrout
noout     tst.w     D3                  ; Beliebig viele Zeichen?
          beq.s     tsteow
          cmp.w     D3,D2
          beq.s     lpend32
tsteow    tst.b     (A3)                ; Ende?
          beq.s     lpend32
          cmpi.b    #' ',(A3)
          bne       loop32
lpend32   dbra      D4,loop31
          sub.w     D2,D3
          bls.s     wwend
          subq.w    #1,D3
loop33    bsr       spc
          dbra      D3,loop33
wwend     movem.l   (SP)+,D1/D3-D4/A3
          rts                           ; D2: LÑnge/Fehler-Flag

tststr    movem.l   D0/A3-A4,-(SP)      ; String testen
          moveq     #0,D0               ; A2: Tabelle der erlaubten Zeichen
          bsr       smchrtst            ; A3: Stringtabelle
          movea.l   A1,A4               ; Anfangsposition merken
          bcc       tsend
loop41    movea.l   A4,A1               ; NÑchster Vergleich
          addq.l    #1,D0               ; Nummer des nÑchsten Strings
loop42    cmpi.b    #' ',(A3)+          ; NÑchsten String suchen
          beq       loop42
          subq.l    #2,A3
          tst.b     1(A3)               ; Ende der Stringtabelle?
          beq.s     tserr               ; Ja, dann Fehler markieren
loop43    addq.l    #1,A3
          cmpi.b    #'*',(A3)
          bne.s     nostar
loop44    cmpa.l    A0,A1               ; Zeilenende Åberschritten?
          bhi.s     loop46
star      cmpi.b    #'*',(A3)+
          beq       star
          subq.l    #1,A3
          tst.b     (A3)                ; Ende der Stringtabelle?
          beq.s     tsend
          cmp.b     #' ',(A3)           ; Ende des Tabellenstrings?
          beq.s     tsend
loop45    cmpa.l    A0,A1               ; Zeilenende Åberschritten?
          bhi.s     brklp43
          bsr       getchrbuf
          cmp.b     #' ',D1             ; Ende des zu testenden Strings?
          beq.s     brklp43
          cmp.b     (A3),D1             ; Zeichen gefunden?
          beq.s     brklp43
          bsr       tstchr              ; Zeichen erlaubt?
          beq       loop45
loop46    tst.b     (A3)                ; Ende des Tabellenstrings suchen
          beq.s     tserr
          cmpi.b    #' ',(A3)+
          beq       loop41              ; Zum nÑchsten Vergleich
          bra       loop46
nostar    cmpa.l    A0,A1               ; Zeilenende Åberschritten?
          bls.s     nolnovfl
          tst.b     (A3)                ; Ende der Stringtabelle?
          beq.s     tsend
          cmpi.b    #' ',(A3)           ; Ende des Tabellenstrings?
          beq.s     tsend
          bra       loop46
nolnovfl  bsr       getchrbuf
brklp43   cmpi.b    #' ',(A3)           ; Ende des Tabellenstrings?
          beq.s     tsend               ; Ja, dann stimmt Vergleichsstring
          tst.b     (A3)                ; Ende der Stringtabelle?
          beq.s     tsend
          cmp.b     #' ',D1
          beq       loop46
          cmpi.b    #'?',(A3)           ; Joker?
          bne.s     nojoker
          bsr       tstchr
          beq       loop43
nojoker   cmp.b     (A3),D1             ; Beide Zeichen sind gleich?
          beq       loop43
          bra       loop46
tserr     moveq     #0,D0               ; Null markiert Fehler
tsend     move.l    D0,D1
          movea.l   A4,A1               ; Anfangsadresse wiederherstellen
          movem.l   (SP)+,D0/A3-A4
          tst.l     D1
          rts                           ; D1: Stringnummer/Fehler

wrtstrbuf movem.l   D1/A2-A4,-(SP)      ; String in Puffer schreiben
          moveq     #0,D2               ; A2: FÅllzeichentabelle
          tst.l     D1                  ; A3: Stringtabelle
          beq.s     wsbend              ; A4: Puffer
          subq.l    #1,D1               ; D1: Stringnummer
loop77    tst.b     (A3)                ; D3: Maximale LÑnge
          beq.s     wsbend              ; NÑchsten String suchen
          cmpi.b    #' ',(A3)
          bne.s     lpend77
          addq.l    #1,A3
          bra       loop77
lpend77   tst.l     D1                  ; String erreicht?
          beq.s     loop79
loop78    tst.b     (A3)                ; String Åberspringen
          beq.s     wsbend
          cmpi.b    #' ',(A3)+
          bne       loop78
          subq.l    #1,D1
          bra       loop77
loop79    tst.l     D3                  ; HîchststringlÑnge vorhanden?
          beq.s     nomaxl1
          cmp.l     D3,D2               ; HîchststringlÑnge erreicht?
          beq.s     wsbend
nomaxl1   tst.b     (A3)                ; Ende des Strings?
          beq.s     wsbend
          cmpi.b    #' ',(A3)
          beq.s     wsbend
          addq.l    #1,D2
          cmpi.b    #'?',(A3)
          beq.s     wsbjoker
          cmpi.b    #'*',(A3)
          beq.s     loop80
          move.b    (A3)+,(A4)+
          bra       loop79
wsbjoker  tst.b     (A2)                ; Einzelnes FÅllzeichen Åbertragen
          beq.s     lpend79
          move.b    (A2)+,(A4)+
          addq.l    #1,A3
          bra       loop79
lpend79   subq.l    #1,D2
          bra.s     wsbend
loop80    tst.b     (A2)                ; FÅllstring Åbertragen
          beq.s     lpend80
          move.b    (A2)+,(A4)+
          tst.l     D3                  ; HîchststringlÑnge vorhanden?
          beq.s     nomaxl2
          cmp.l     D3,D2               ; HîchststringlÑnge erreicht?
          beq.s     wsbend
nomaxl2   addq.l    #1,D2
          bra       loop80
lpend80   addq.l    #1,A2
          subq.l    #1,D2
          addq.l    #1,A3
          bra       nomaxl1
wsbend    clr.b     (A4)
          movem.l   (SP)+,D1/A2-A4
          tst.l     D2
          rts                           ; D2: LÑnge/Fehler

readval   movem.l   D0/D4-D7/A2-A4,-(SP); String in beliebigem Format ein-
          moveq     #0,D0               ; lesen
          moveq     #0,D2
          sf        D7                  ; Keine negative Zahl
loop9     cmpa.l    A0,A1               ; Zeilenende Åberschritten?
          bhi       rverr4
          movea.l   A1,A4               ; Anfangsposition retten
          bsr       getchrbuf
          cmp.b     #' ',D1
          beq       loop9
          lea       prm(PC),A2          ; Basisadresse der Parameter
          cmp.b     #'-',D1             ; Negative Zahl?
          bne.s     dgtctrl
          st        D7                  ; Negativflag setzen
          cmpa.l    A0,A1               ; Zeilenende Åberschritten?
          bhi       rverr4
          bsr       getchrbuf
dgtctrl   cmp.b     #'0',D1             ; ASCII-Code ist grîûer als 48?
          bcs.s     seektype            ; Nein, dann stelle Format fest
          subq.l    #1,A1               ; Ein Zeichen zurÅck
          moveq     #0,D6
          move.b    4(A2),D6            ; Normaltyp
          cmp.w     #3,D6               ; Normaltyp vorhanden?
          bne.s     settype             ; Ja, dann Typ setzen
          bra       rverr5
seektype  moveq     #0,D6               ; Erster Parameter
          lea       frmchr(PC),A3
loop10    cmp.b     0(A3,D6.w),D1       ; Formatmarke gefunden?
          beq.s     frmalwd             ; Ja, dann teste, ob Format erlaubt
          addq.w    #1,D6               ; NÑchster Parameter
          cmp.w     #2,D6               ; Offset>2?
          bls       loop10              ; Nein, dann weitersuchen
          tst.b     D7                  ; Minuszeichen eingelesen?
          bne       rverr3              ; Kein gÅltiges Zeichen
          cmp.b     #39,D1              ; Hochkomma?
          beq.s     rdstr               ; Ja, dann String einlesen
          bra       rverr3              ; Kein gÅltiges Zeichen
frmalwd   tst.b     0(A2,D6.w)          ; Format zugelassen?
          beq       rverr6
settype   lea       frm(PC),A3
          moveq     #0,D3
          move.b    0(A3,D6.w),D3       ; Formatkennzahl
          add.w     D6,D6               ; Stellenzahlen
          adda.l    D6,A2
          addq.l    #5,A2
          move.b    (A2)+,D4            ; Niedrigste Stellenzahl
          move.b    (A2),D5             ; Hîchste Stellenzahl
          bra.s     loop12              ; Zahl einlesen
rdstr     move.b    0(A2,D6.w),D1       ; Einlesen von Strings
          tst.b     D1                  ; Stringformat zugelassen?
          beq       rverr6
          moveq     #1,D3               ; Formatkennzahl
          lea       strbuf(PC),A2
loop11    cmpa.l    A0,A1               ; Zeilenende Åberschritten?
          bhi.s     rsend               ; Ja, dann beenden
          move.b    (A1)+,D1            ; Zeichen holen
          cmp.b     #39,D1              ; Zeichen ist Hochkomma?
          bne.s     sbuf                ; Nein, dann Zeichen in Puffer
rsend     clr.b     (A2)                ; Stringende markieren
          tst.w     D2                  ; Zeichen im Puffer?
          bne.s     tl                  ; Ja, dann nichts tun
          moveq     #1,D2               ; Mindestens ein Zeichen im Puffer
          bra       noerr
tl        lea       prm(PC),A3
          cmp.b     11(A3),D2           ; String zu lang?
          bls.s     noerr
          bra.s     rverr2
sbuf      addq.w    #1,D2               ; Ein Zeichen mehr
          move.b    D1,(A2)+
          cmp.w     #5,D2               ; Weniger als fÅnf Zeichen?
          bcc       loop11
          lsl.l     #8,D0
          move.b    D1,D0
          bra       loop11
loop12    cmpa.l    A0,A1               ; Einlesen von Zahlen 
          bhi.s     nd2
          bsr       getchrbuf
          cmp.b     #'A',D1             ; Zeichen ist Buchstabe?
          bcs.s     nmb                 ; Nein, dann nicht verringern
          subq.b    #7,D1               ; ASCII-Code-7
          bra.s     dgt
nmb       cmp.b     #'9',D1             ; UnzulÑssiges Zeichen?
          bhi.s     rverr3
          cmp.b     #'0',D1             ; Ziffer?
          bcs.s     nd1                 ; Nein, dann Zahl prÅfen
dgt       sub.b     #48,D1              ; Wert der Ziffer
          cmp.b     D3,D1               ; GÅltige Ziffer?
          bcc.s     nd1                 ; Nein, dann Zahl prÅfen
          addq.w    #1,D2               ; Eine Ziffer mehr
          bsr       mul32               ; D0 := D0 * D3
          ext.l     D1
          add.l     D1,D0               ; Ziffer dazu addieren
          cmp.b     D5,D2               ; Genug Ziffern?
          beq.s     noerr               ; Ja, dann Einlesevorgang beenden
          bra       loop12
nd1       subq.l    #1,A1               ; Ein Zeichen zurÅck
          tst.w     D2                  ; Ziffern vorhanden?
          bne.s     mindgt              ; Ja, dann nÑchste PrÅfung
          bra.s     rverr3
nd2       tst.w     D2
          beq.s     rverr1
mindgt    cmp.b     D4,D2               ; Zu wenig Stellen?
          bcc.s     noerr
rverr1    moveq     #0,D1               ; Nicht genug Stellen
          bra.s     rverr
rverr2    moveq     #1,D1               ; Der String ist zu lang
          bra.s     rverr
rverr3    moveq     #2,D1               ; Unerlaubte Zeichen
          bra.s     rverr
rverr4    moveq     #3,D1               ; Zahl oder String erwartet
          bra.s     rverr
rverr5    moveq     #4,D1               ; Unbekanntes Format
          bra.s     rverr
rverr6    moveq     #5,D1               ; Unerlaubtes Format
rverr     moveq     #0,D2               ; Fehler
          movea.l   A4,A1               ; Anfangsposition wiederherstellen
          bra.s     rvend
noerr     tst.b     D7                  ; Negativflag gesetzt?
          beq.s     noneg
          neg.l     D0
noneg     move.l    D0,D1
rvend     movem.l   (SP)+,D0/D4-D7/A2-A4; D1: String
          tst.w     D2                  ; D2: Zahl der eingelesenen Zeichen
          rts                           ; D3: Format des Strings

rdval     bsr       readval             ; String in beliebigem Format ein-
          bne.s     rverend             ; lesen (mit Fehlerausgabe)
          mulu      #6,D1
          jmp       err(PC,D1.w)
err       lea       errmsg01(PC),A1
          bra.s     errout
          lea       errmsg02(PC),A1
          bra.s     errout
          lea       errmsg03(PC),A1
          bra.s     errout
          lea       errmsg04(PC),A1
          bra.s     errout
          lea       errmsg05(PC),A1
          bra.s     errout
          lea       errmsg06(PC),A1
errout    bsr       errorout
          tst.w     D2
rverend   rts

changeval movem.l   D0-D5/A2,-(SP)      ; Erzeugung eines Zahlenstrings
          move.l    D1,D0               ; D1: Wert
          lea       nmbstrbuf(PC),A4    ; D2: LÑnge
          movea.l   A4,A5               ; D3: Format
          cmp.b     #str,D3             ; D4: Formatmarker-Flag
          beq.s     wrtstr              ; D5: Negativflag
          tst.b     D5                  ; Negative Zahl ausgeben?
          beq.s     nong
          tst.l     D0                  ; Zahl negativ?
          bpl.s     nong
          neg.l     D0
          move.b    #'-',(A5)+          ; Minuszeichen ausgeben
nong      tst.b     D4
          beq.s     nomrk
          lea       frmchr(PC),A2
          move.b    0(A2,D3.w),(A5)+
nomrk     lea       frm(PC),A2
          move.b    0(A2,D3.w),D3
          ext.w     D3
          ext.l     D3
          clr.w     -(SP)               ; Ende des Zahlenstrings
          lea       digits(PC),A2       ; Zahlzeichentabelle
loop14    bsr       div32               ; Zahlzeichen ermitteln
          move.b    0(A2,D4.w),D1       ; D4 ist der Rest von D0 div 10
          move.w    D1,-(SP)
          tst.w     D2                  ; D2=0?
          beq.s     zrtst
          subq.w    #1,D2               ; Nein, dann bestimmte Zahl von
          and.w     #31,D2              ; Stellen ausgeben (modulo 32)
          bne       loop14
          bra.s     nmbout
zrtst     tst.l     D0                  ; Zahl ist Null?
          bne       loop14
nmbout    move.w    (SP)+,D1            ; Zeichen in umgekehrter Reihen-
          move.b    D1,(A5)+            ; folge ausgeben
          tst.w     (SP)                ; Ende?
          bne       nmbout
          addq.l    #2,SP               ; SP wiederherstellen
          bra.s     cvend
wrtstr    tst.b     D4                  ; Hochkomma ausgeben?
          beq.s     nokm
          move.b    #39,(A5)+
nokm      rol.l     #8,D0               ; Zeichen an Ende von D0
          move.b    D0,(A5)+
          subq.w    #1,D2
          bne       nokm
          tst.b     D4                  ; Hochkomma ausgeben?
          beq.s     cvend
          move.b    #39,(A5)+
cvend     clr.b     (A5)                ; Der String endet mit Null
          movem.l   (SP)+,D0-D5/A2      ; A4: Stringanfang
          rts                           ; A5: Stringende

wrtval    movem.l   A1/A4-A5,-(SP)      ; Ausgabe eines Zahlenstrings
          bsr       changeval
          movea.l   A4,A1
          bsr       textout
          movem.l   (SP)+,A1/A4-A5
          rts

wrtvalln  bsr       wrtval              ; Ausgabe eines Zahlenstrings mit
          bra       cret                ; mit anschlieûendem CR

setprm                                  ; Setzen einiger Parameter
          lea       prm(PC),A2          ; Basisadresse der Parameterliste
          st        (A2)+               ; BinÑrzahlen
          st        (A2)+               ; Dezimalzahlen
          st        (A2)+               ; Hexadezimalzahlen
          sf        (A2)+               ; Keine Strings
          move.b    #hex,(A2)+          ; Normalformat
          move.b    #1,(A2)+            ; Mindeststellenzahl BinÑr
          move.b    #32,(A2)+           ; Hîchststellenzahl BinÑr
          move.b    #1,(A2)+            ; Mindeststellenzahl Dezimal
          move.b    #10,(A2)+           ; Hîchststellenzahl Dezimal
          move.b    #1,(A2)+            ; Mindeststellenzahl Hexadezimal
          move.b    #8,(A2)+            ; Hîchststellenzahl Hexadezimal
          move.b    #4,(A2)+            ; Hîchstzeichenzahl
          rts

rdlnval   movem.l   D0/A2/A4,-(SP)      ; Liest mehrere Werte ein
          moveq     #0,D4               ; Anzahl der eingelesenen Bytes
          lea       prm(PC),A2
          sf        (A2)                ; Keine BinÑrzahlen
          sf        1(A2)               ; Keine Dezimalzahlen
          move.b    #hex,4(A2)          ; Normalformat
          lea       valbuf(PC),A3
          bsr       smchrtst
          bcc.s     errtst
          lea       strbuf(PC),A4
          clr.l     (A4)
loop17    bsr       rdval
          beq.s     rlverr              ; Falls Fehler
          cmp.b     #1,D3               ; Stringformat?
          bne.s     nos
          lea       strbuf(PC),A4
          subq.w    #1,D2
loop18    move.b    (A4)+,(A3)+         ; String Åbertragen
          addq.b    #1,D4
          dbra      D2,loop18
          bra.s     lim
nos       cmp.b     #2,D2               ; Bytegrîûe?
          bhi.s     nob
          move.b    D1,(A3)+            ; Byte in den Puffer
          addq.b    #1,D4
          bra.s     lim
nob       move.l    A3,D0               ; Ungerade Adresse?
          ror.l     #1,D0
          bcc.s     evenadr             ; Gerade Adresse
          clr.b     (A3)+               ; Ungerade AdrurÛe + 1
          addq.b    #1,D4
evenadr   cmp.b     #4,D2               ; Wortgrîûe?
          bhi.s     now
          move.w    D1,(A3)+            ; Wort in den Puffer
          addq.b    #2,D4
          bra.s     lim
now       move.l    D1,(A3)+            ; Langwort in den Puffer
          addq.l    #4,D4
lim       cmp.b     14(A2),D4           ; Hîchstzahl erreicht?
          bcc.s     rlvend
          tst.b     12(A2)              ; Komma-Flag nicht gesetzt
          beq.s     nokmf               ; Ja, dann keine Komma-öberprÅfung
          bsr       komtst              ; Komma vorhanden?
          bcs       loop17              ; Ja, dann nÑchsten Wert einlesen
          bcc.s     errtst
nokmf     bsr       smchrtst            ; Noch ein Zeichen vorhanden?
          bcs       loop17              ; Ja, dann nÑchsten Wert einlesen
errtst    cmp.b     13(A2),D4           ; Mindestzahl unterschritten?
          bcc.s     rlvend
          lea       errmsg30(PC),A1
          bsr       errorout
rlverr    moveq     #0,D4               ; Fehler
rlvend    lea       valbuf(PC),A3
          movem.l   (SP)+,D0/A2/A4
          tst.l     D4
          rts                           ; D4: Zahl der eingelesenen Bytes

getadr    movem.l   D1/D3,-(SP)         ; Holen einer Adresse nach A4
          bsr       setprm
          sf        -12(A2)             ; Keine BinÑrzahlen
          bsr       rdval
          movea.l   D1,A4
          movem.l   (SP)+,D1/D3
          tst.w     D2                  ; D2: Fehler-Flag
          rts                           ; A4: Adresse

tsteven   movem.l   D0/A1,-(SP)         ; PrÅfung, ob Adresse gerade ist
          move.w    A4,D0               ; A4: Adresse
          ror.w     #1,D0
          bcc.s     todend
          lea       errmsg40(PC),A1
          bsr       errorout
          ori.b     #%00001,CCR         ; Carry-Flag setzen
todend    movem.l   (SP)+,D0/A1
          rts                           ; Wenn Adresse gerade, dann C=0

mkeven    move.l    D0,-(SP)            ; Adresse gerade machen
          move.l    A4,D0               ; A4: Adresse
          bclr      #0,D0
          movea.l   D0,A4
          move.l    (SP)+,D0
          rts

getvec    move.l    D3,-(SP)            ; Vektor holen
          bsr       setprm
          sf        -12(A2)             ; Keine BinÑrzahlen
          sf        -11(A2)             ; Keine Dezimalzahlen
          move.b    #1,-3(A2)           ; Hîchstens zweistellig
          move.b    #2,-2(A2)
          bsr       rdval
          lsl.l     #2,D1               ; Vektoradresse=4*Vektornummer
          movea.l   D1,A4
          lsr.l     #2,D1
          move.l    (SP)+,D3
          tst.w     D2                  ; D1: Vektornummer
          rts                           ; A4: Vektoradresse

gettrksec bsr       setprm              ; Track-und Sektornummer holen
          sf        -12(A2)             ; Keine BinÑrzahlen
          move.b    #dec,-8(A2)         ; Normalformat Dezimal
          move.b    #5,-4(A2)           ; Hîchststellenzahl Dezimal
          move.b    #4,-2(A2)           ; Hîchststellenzahl Hexadezimal
          bsr       rdval               ; Track einlesen
          beq.s     gtserr
          moveq     #0,D4
          move.w    D1,D4
          bsr       komtsterr
          bcc.s     gtserr
          bsr       rdval               ; Sektor einlesen
          beq.s     gtserr
          exg       D1,D4
          moveq     #0,D2
          move.w    D4,D2
          bra.s     gtsend
gtserr    moveq     #0,D3
gtsend    tst.l     D3                  ; D1: Tracknummer
          rts                           ; D2: Sektornummer

wait      move.b    printer(PC),D1      ; Zeilenausgabe tastaturgesteuert
          lea       prton(PC),A6        ; A3: Ausgaberoutine
          tst.b     D1
          sne       (A6)
          move.l    lines(PC),D1        ; Erste 23 Zeilen ausgeben
          subq.l    #3,D1
loop19    move.w    D1,-(SP)
          jsr       (A3)                ; Zeile ausgeben
          move.w    (SP)+,D1
          tst.b     D0                  ; Abbruchbedingung erfÅllt?
          bne.s     brk
          lea       prton(PC),A6
          tst.b     (A6)                ; Ausdruck?
          bne       loop19
          dbra      D1,loop19
waitkey   move.w    #DIRCONIN,-(SP)
          trap      #GEMDOS
          addq.l    #2,SP
          cmp.b     #13,D0              ; Return gedrÅckt?
          bne.s     noret
          move.w    #0,D1               ; Nur eine Zeile
          bra       loop19
noret     cmp.b     #27,D0              ; Esc gedrÅckt?
          beq.s     brk
          cmp.b     #32,D0              ; Space-Taste gedrÅckt?
          bne       waitkey
          move.l    lines(PC),D1        ; Eine Seite (23 Zeilen)
          subq.l    #3,D1
          bra       loop19
brk       moveq     #'.',D1
          bsr       prtout
          bsr       prtcr
          lea       prton(PC),A6
          sf        (A6)                ; Kein Druckerbetrieb mehr
          rts

hlnout                                  ; Zeilenausgabe Suchfunktion
loop39    cmpa.l    A4,A5               ; Endadresse Åberschritten?
          bhi.s     hloend
          move.l    D4,D2               ; LÑnge des Suchstrings
          movea.l   A0,A2               ; Adresse des Suchstrings
          movea.l   A5,A6
          addq.l    #1,A5
loop40    cmpm.b    (A2)+,(A6)+
          bne       loop39
          subq.l    #1,D2
          bne       loop40
          lea       text02(PC),A1
          bsr       comtxtout
          move.l    A5,D1
          subq.l    #1,D1
          moveq     #6,D2
          moveq     #hex,D3
          move.l    D4,-(SP)
          sf        D4
          sf        D5
          bsr       wrtvalln
          move.l    (SP)+,D4
          cmpa.l    A4,A5
hloend    shi       D0                  ; Abbruchbedingung
          rts

hslnout   st        D0
          rts

mlnout    bsr       point2              ; Zeilenausgabe Speicheranzeige
          moveq     #':',D1
          bsr       chrout
          bsr       spc
          moveq     #6,D2               ; Langwort
          move.l    A5,D1               ; Adresse ausgeben
          bsr       wrtval
          moveq     #3,D7
          bsr       spcn
          lea       strbuf(PC),A6
          moveq     #4,D2               ; Worte
          moveq     #7,D6               ; Acht StÅck
loop20    bsr       spc
          move.w    (A5)+,D1
          move.w    D1,(A6)+
          bsr       wrtval
          dbra      D6,loop20
          move.w    #6,D7
          bsr       spcn
          lea       strbuf(PC),A6
          bsr       rev_on              ; Zeichencodes ausgeben
          moveq     #15,D6              ; 16 Zeichen
loop21    move.b    (A6)+,D1
          cmp.b     #32,D1              ; Kein Zeichencode?
          bcs.s     pt
          cmp.b     #127,D1
          bne.s     cho
pt        moveq     #'.',D1
cho       bsr       chrout
          dbra      D6,loop21
          bsr       rev_off
          bsr       cret
          cmpa.l    A4,A5
          shi       D0                  ; Abbruchbedingung
          rts

vlnout    bsr       point2              ; Zeilenausgabe Vektorenauflistung
          moveq     #'>',D1
          bsr       chrout
          bsr       spc
          move.b    D6,D1
          moveq     #2,D2               ; Vektornummer ausgeben
          sf        D4
          bsr       wrtval
          moveq     #3,D7
          bsr       spcn
          move.l    D1,D6
          move.l    (A5)+,D1            ; Vektor ausgeben
          moveq     #8,D2
          sf        D4                  ; Ohne Dollar-Zeichen
          bsr       wrtvalln
          addq.b    #1,D6
          cmpa.l    A4,A5
          shi       D0                  ; Abbruchbedingung
          rts

wrtdabuf  movem.l   D1-D7/A3-A5,-(SP)   ; Disassemblierte Zeile in den Puffer
          lea       disasmbuf(PC),A1    ; schreiben
          move.l    A3,D1               ; A3: Befehlsadresse
          moveq     #6,D2               ; D6: BefehlslÑnge
          moveq     #hex,D3             ; D0: Hexbyte-Ausgabe-Flag
          sf        D4
          sf        D5
          bsr       changeval
loop96    move.b    (A4)+,(A1)+         ; Adresse in den Puffer Åbertragen
          cmpa.l    A5,A4
          bcs       loop96
          moveq     #3,D7
loop97    move.b    #' ',(A1)+
          dbra      D7,loop97
          tst.b     D0                  ; Hexbyte-Ausgabe?
          beq.s     nohexbyte
          moveq     #2,D2               ; Befehl zunÑchst hexadezimal
          move.w    D6,D7               ; ausgeben
          subq.w    #1,D7
loop93    move.b    (A3)+,D1
          bsr       changeval
loop98    move.b    (A4)+,(A1)+         ; Hexbyte in den Puffer Åbertragen
          cmpa.l    A5,A4
          bcs       loop98
          dbra      D7,loop93
          moveq     #24,D7              ; Zwischenraum zwischen Hexcode
          add.w     D6,D6               ; und Befehlswort berechnen
          sub.w     D6,D7
loop99    move.b    #' ',(A1)+
          dbra      D7,loop99
nohexbyte lea       mnembuf(PC),A4      ; Befehlsstring ausgeben
loop100   move.b    (A4)+,(A1)+
          bne       loop100
          move.l    A1,D0               ; LÑnge berechnen
          lea       disasmbuf(PC),A1
          sub.l     A1,D0
          subq.l    #1,D0
          movem.l   (SP)+,D1-D7/A3-A5   ; A1: Pufferadresse
          rts                           ; D0: LÑnge

wrtdislin movem.l   D0-D1/A1,-(SP)      ; Disassemblierte Zeile ausgeben
          bsr       point2              ; A3: Befehlsadresse
          moveq     #',',D1             ; D6: BefehlslÑnge
          bsr       chrout
          bsr       spc
          st        D0                  ; Hexbytes ausgeben
          bsr       wrtdabuf
          bsr       textout
          movem.l   (SP)+,D0-D1/A1
          rts

dlnout    exg       A5,A3               ; Zeilenausgabe Disassembler
          movea.l   A4,A6
          lea       mnembuf(PC),A4      ; Stringpuffer
          bsr       wrtmcins            ; Befehlsstring in den Puffer
          bsr       wrtdislin
          bsr       cret
          add.l     D6,A3               ; NÑchste Befehlsadresse
          exg       A3,A5
          movea.l   A6,A4               ; Endadresse zurÅckholen
          cmpa.l    A4,A5
          shi       D0                  ; Abbruchbedingung
          rts

op        bsr       setprm              ; VerknÅpfung zweier Zahlen
          bsr       rdval               ; Einlesen der ersten Zahl
          beq.s     opend
          move.l    D1,D5               ; Zahl retten
          bsr       komtsterr
          bcc.s     opend               ; Fehler
          bsr       rdval               ; Einlesen der zweiten Zahl
          beq.s     opend
          jsr       (A3)                ; Zahlen verknÅpfen
          bsr       point2              ; In A3 steht die Adresse der Ver-
          moveq     #'C',D1             ; knÅpfung
          bsr       chrout
          bsr       spc
          move.l    D5,D1
          moveq     #8,D2
          moveq     #hex,D3
          st        D4
          st        D5                  ; Negative Zahlen
          bra       wrtvalln
opend     rts

rout      bsr       spc                 ; Register anzeigen
          addq.l    #1,D1               ; Registernamen ausgeben
          moveq     #5,D3
          bsr       wrtwrd
          move.b    (A5)+,D7            ; Adresse im Registerpuffer
          ext.w     D7
          move.l    D1,-(SP)
          move.l    0(A6,D7.w),D1
          moveq     #8,D2
          moveq     #hex,D3
          bsr       wrtval
          move.l    (SP)+,D1
          rts

transfer  movem.l   A4-A6,-(SP)         ; Block byteweise verschieben
          cmpa.l    A4,A6               ; A4: Startadresse des Blocks
          bls.s     loop36              ; A5: Endadresse
          addq.l    #1,A5               ; A6: Zieladresse
          adda.l    A5,A6
          suba.l    A4,A6
loop35    cmpa.l    A4,A5               ; Startadresse erreicht?
          bls.s     tfend
          move.b    -(A5),-(A6)
          bra       loop35
loop36    cmpa.l    A5,A4               ; Endadresse erreicht?
          bhi.s     tfend
          move.b    (A4)+,(A6)+
          bra       loop36
tfend     movem.l   (SP)+,A4-A6
          rts

fill      movem.l   D2/A2/A4,-(SP)      ; FÅllen von Speicherbereichen
          clr.w     D2                  ; D4: LÑnge des FÅllwerts
loop38    cmpa.l    A4,A5               ; A3: FÅllwert
          bcs.s     flend               ; A4: Startadresse des Bereichs
          tst.w     D2                  ; A5: Endadresse
          bne.s     nrtbv
          move.w    D4,D2
          movea.l   A3,A2
nrtbv     move.b    (A2)+,(A4)+
          subq.w    #1,D2
          bra       loop38
flend     movem.l   (SP)+,D2/A2/A4
          rts

sexec     pea       (A1)                ; Exception-Vektor setzen
          move.w    D1,-(SP)            ; A1: Exception-Routine
          move.w    #SETEXEC,-(SP)      ; D1: Vektornummer
          trap      #BIOS
          addq.l    #8,SP
          rts                           ; D0: Alte Exception-Routine

brkinter  move.b    monflag(PC),D0      ; Unterbrechungsroutine
          beq.s     brkintend
          movea.l   ibuf(PC),A0         ; Tastaturpufferadressen laden
          movea.l   ibufsiz(PC),A1
          movea.l   ibufhd(PC),A2
          movea.l   ibuftl(PC),A3
          move.w    (A2),D0
          cmp.w     (A3),D0             ; Taste gedrÅckt?
          beq.s     brkintend
          movea.l   (A0),A4             ; Pufferadresse laden
          move.l    4(A4,D0.w),D1       ; SCAN- und ASCII-Code der Taste
          cmp.w     #3,D1               ; Ctrl-C?
          bne.s     brkintend
          addq.w    #4,D0               ; Tastencodes lîschen
          cmp.w     (A1),D0             ; Hîchster Index?
          bne.s     bi
          clr.w     D0
bi        move.w    D0,(A2)
brkintend rts

mcur_on   movem.l   D0-D2/A0-A2,-(SP)   ; Mauszeiger einschalten
          bsr       cur_off
          movea.l   base(PC),A0         ; Line-A-Parameterfeld-Basis
          movea.l   4(A0),A1            ; Control-Array
          move.w    #0,2(A1)
          move.w    #1,6(A1)
          movea.l   8(A0),A1            ; Intin-Array
          move.w    #0,(A1)             ; Mauszeiger sofort einschalten
          dc.w      mouse_on
          movem.l   (SP)+,D0-D2/A0-A2
          rts

mcur_off  movem.l   D0-D2/A0-A2,-(SP)   ; Mauszeiger ausschalten
          dc.w      mouse_off
          bsr       cur_on
          movem.l   (SP)+,D0-D2/A0-A2
          rts

rdfname   lea       prm(PC),A2          ; Filenamen einlesen
          move.b    D4,11(A2)           ; D4: Hîchstzeichenzahl
          sf        (A2)                ; Keine BinÑrzahlen
          sf        1(A2)               ; Keine Dezimalzahlen
          sf        2(A2)               ; Keine Hexadezimalzahlen
          st        3(A2)               ; Strings zulassen
          bsr       rdval               ; Filenamen einlesen
          beq.s     rfnend              ; Fehler
          lea       strbuf(PC),A3
          tst.b     (A3)                ; Leerstring?
          bne.s     rfnend
          lea       errmsg70(PC),A1
          bsr       errorout
          moveq     #0,D2               ; Fehler markieren
rfnend    tst.w     D2                  ; A3: Filename
          rts                           ; D2: LÑnge/Fehler

dskerrout movem.l   D0/A1,-(SP)         ; Ausgabe einer Diskettenfehler-
          bsr       mcur_off            ; meldung
          lea       dskerrtab(PC),A1
          tst.l     D0                  ; D0: Fehler
          bpl.s     deoend              ; Kein Fehler
          neg.l     D0
          adda.l    D0,A1               ; Fehlernummer ist Offset
          moveq     #0,D0
          move.b    (A1),D0             ; Nummer der Fehlermeldung
          beq.s     deoend              ; Kein Fehler
          subq.w    #1,D0
          mulu      #6,D0
          jmp       dskerr(PC,D0.l)
dskerr    lea       errmsg71(PC),A1     ; 'Drive not ready'
          bra.s     deo
          lea       errmsg72(PC),A1     ; 'Write error'
          bra.s     deo
          lea       errmsg73(PC),A1     ; 'Read error'
          bra.s     deo
          lea       errmsg74(PC),A1     ; 'Disk is write protected'
          bra.s     deo
          lea       errmsg75(PC),A1     ; 'Disk was changed'
          bra.s     deo
          lea       errmsg76(PC),A1     ; 'No disk in drive'
          bra.s     deo
          lea       errmsg77(PC),A1     ; 'File not found'
          bra.s     deo
          lea       errmsg78(PC),A1     ; 'Pathname not found'
          bra.s     deo
          lea       errmsg79(PC),A1     ; 'Access not possible'
          bra.s     deo
          lea       errmsg80(PC),A1     ; 'Invalid drivename'
          bra.s     deo
          lea       errmsg84(PC),A1     ; 'General error'
          bra.s     deo
          lea       errmsg85(PC),A1     ; 'Track not found'
          bra.s     deo
          lea       errmsg86(PC),A1     ; 'Sector not found'
          bra.s     deo
          lea       errmsg88(PC),A1     ; 'File not executable'
deo       bsr       errorout
deoend    movem.l   (SP)+,D0/A1
          tst.l     D0
          rts

closefile move.w    D1,-(SP)            ; Datei schlieûen
          move.w    #CLOSE,-(SP)        ; D1: Handle-Nummer
          trap      #GEMDOS
          addq.l    #4,SP
          rts

setdrive  move.w    D1,-(SP)            ; Laufwerksbestimmung
          move.w    #SETDRV,-(SP)       ; D1: Laufwerk
          trap      #GEMDOS
          addq.l    #4,SP
          rts

curdisk   move.w    #CURRENT,-(SP)      ; Ermittlung des aktuellen
          trap      #GEMDOS             ; Laufwerks
          addq.l    #2,SP
          rts                           ; D0: Laufwerksnummer

save      bsr       mcur_on             ; Datei auf Diskette schreiben
          movem.l   D1/A4,-(SP)         ; A3: Filename
          move.w    #%0000,-(SP)        ; A5: Startadresse
          pea       (A3)                ; A4: Endadresse
          move.w    #CREATE,-(SP)
          trap      #GEMDOS
          addq.l    #8,SP
          move.l    D0,D1               ; Handle-Nummer merken
          bmi.s     sverr               ; Fehler
          pea       (A5)
          addq.l    #1,A4               ; LÑnge des Speicherbereichs
          suba.l    A5,A4               ; berechnen
          pea       (A4)
          move.w    D1,-(SP)            ; Handle-Nummer
          move.w    #WRITE,-(SP)
          trap      #GEMDOS
          adda.w    #12,SP
          tst.l     D0
          bmi.s     sverr               ; Fehler
          bsr       closefile
sverr     movem.l   (SP)+,D1/A4
          bra       dskerrout           ; D0: Fehlercode

load      bsr       mcur_on             ; Datei laden
          move.l    D1,-(SP)            ; A3: Filename
          move.w    #0,-(SP)            ; A4: Startadresse
          pea       (A3)                ; D2: LÑnge
          move.w    #OPEN,-(SP)
          trap      #GEMDOS
          addq.l    #8,SP
          move.l    D0,D1               ; Handle-Nummer merken
          bmi.s     lderr
          tst.l     D2
          bne.s     readfile
          move.w    #2,-(SP)            ; LÑnge der Datei ermitteln
          move.w    D1,-(SP)
          move.l    #0,-(SP)
          move.w    #LSEEK,-(SP)
          trap      #GEMDOS
          adda.w    #10,SP
          move.l    D0,D2
          bmi.s     lderr
          move.w    #0,-(SP)
          move.w    D1,-(SP)
          move.l    #0,-(SP)
          move.w    #LSEEK,-(SP)
          trap      #GEMDOS
          adda.w    #10,SP
          tst.l     D0
          bmi.s     lderr
readfile  pea       (A4)
          move.l    D2,-(SP)
          move.w    D1,-(SP)
          move.w    #READ,-(SP)
          trap      #GEMDOS
          adda.w    #12,SP
          tst.l     D0
          bmi.s     lderr
          bsr       closefile
lderr     move.l    (SP)+,D1
          bra       dskerrout           ; D2: LÑnge der Datei

pexec     bsr       mcur_on             ; Programm laden und starten (optional)
          movem.l   D1/A1-A2/A6,-(SP)   ; A3: Filename
          move      USP,A2              ; A4: Kommando
          move      USP,A6              ; A5: Environment
          lea       reg(PC),A1          ; D1: Mode
          adda.w    #72,A1
loop109   move.w    (SP)+,-(A2)         ; Supervisorstackdaten, die seit
          cmpa.l    (A1),SP             ; Eintritt der Exception enstanden
          bne       loop109             ; sind, auf den Userstack retten
          andi.w    #$DFFF,SR           ; In den User-Mode
          movea.l   A2,SP               ; Neuer USP
          pea       (A5)                ; Environment
          pea       (A4)                ; Command
          pea       (A3)                ; File
          move.w    D1,-(SP)            ; Mode
          move.w    #EXEC,-(SP)
          trap      #GEMDOS
          add.w     #16,SP
          move.l    D0,-(SP)            ; Fehler/Programmstartadresse retten
          movea.l   SP,A2               ; A2 aktualisieren
          move.l    (A1),-(SP)          ; Alter SSP
          move.w    #SUPER,-(SP)
          trap      #GEMDOS
          move.l    (A2)+,D0            ; Fehler/Programmstartadresse holen
loop110   move.w    (A2)+,-(SP)         ; Alte Supervisorstackdaten zurÅck-
          cmpa.l    A6,A2               ; holen
          bne       loop110
          move      A2,USP              ; USP aktualisieren
          movem.l   (SP)+,D1/A1-A2/A6
          bra       dskerrout

kill      bsr       mcur_on             ; Lîschen einer Datei
          pea       (A3)                ; A3: Filename
          move.w    #UNLINK,-(SP)
          trap      #GEMDOS
          addq.l    #6,SP
          bra       dskerrout

savedasm  bsr       mcur_on             ; Disassemblierten Maschinencode
          movem.l   D1/A3/A5-A6,-(SP)   ; auf Diskette schreiben
          move.b    appendda(PC),D0     ; A3: Filename
          beq.s     noappend            ; A5: Startadresse
          move.w    #1,-(SP)            ; A4: Endadresse
          pea       (A3)
          move.w    #OPEN,-(SP)
          trap      #GEMDOS
          addq.l    #8,SP
          move.l    D0,D1
          bpl.s     noopenerr
          cmp.l     #-33,D0             ; File nicht gefunden?
          bne.s     svdaerr
noappend  move.w    #%0000,-(SP)        ; Neue Datei einrichten
          pea       (A3)
          move.w    #CREATE,-(SP)
          trap      #GEMDOS
          addq.l    #8,SP
          move.l    D0,D1
          bmi.s     svdaerr
          bra.s     loop101
noopenerr move.w    #2,-(SP)            ; Ans Ende der Datei springen
          move.w    D1,-(SP)
          move.l    #0,-(SP)
          move.w    #LSEEK,-(SP)
          trap      #GEMDOS
          adda.w    #10,SP
          tst.l     D0
          bmi.s     svdaerr
loop101   cmpa.l    A4,A5               ; Endadresse erreicht?
          bhi.s     brklp101
          move.w    D1,-(SP)            ; Handlenummer retten
          movea.l   A5,A3
          movea.l   A4,A6               ; Endadresse retten
          lea       mnembuf(PC),A4      ; Stringpuffer
          bsr       wrtmcins            ; Befehlsstring in den Puffer
          move.b    hbflag(PC),D0       ; Hexbyte-Ausgabe-Flag
          bsr       wrtdabuf
          move.b    #13,0(A1,D0.l)      ; CR beendet die Zeile
          move.b    #10,1(A1,D0.l)
          addq.l    #2,D0
          movea.l   A6,A4               ; Endadresse wieder zurÅckholen
          move.w    (SP)+,D1            ; Handlenummer ist auch wieder da
          pea       (A1)                ; Ab auf die Disk!
          move.l    D0,-(SP)
          move.w    D1,-(SP)
          move.w    #WRITE,-(SP)
          trap      #GEMDOS
          adda.w    #12,SP
          tst.l     D0
          bmi.s     svdaerr
          adda.l    D6,A5               ; Auf zur nÑchsten Adresse!
          bra       loop101
brklp101  bsr       closefile
svdaerr   movem.l   (SP)+,D1/A3/A5-A6
          bra       dskerrout

sdta      bsr       mcur_on             ; Setzen der Directory-Eintrag-
          lea       dirbuf(PC),A1       ; Adresse
          pea       (A1)                ; A3: Maske
          move.w    #SETDTA,-(SP)
          trap      #GEMDOS
          addq.l    #6,SP
          move.w    attribute(PC),-(SP)
          pea       (A3)
          move.w    #SFIRST,-(SP)
          trap      #GEMDOS
          addq.l    #8,SP
          bra       dskerrout

wrtfname  lea       dirbuf(PC),A1       ; Directory-Eintrag ausgeben
          bsr       point2
          moveq     #'\',D1
          bsr       chrout
          btst      #4,21(A1)           ; Ordner?
          beq.s     sysmrk
          moveq     #'*',D1
          bra.s     mrkfile             ; Markiere Eintrag
sysmrk    btst      #2,21(A1)           ; Verborgener System-Eintrag?
          beq.s     hidmrk
          moveq     #'$',D1
          bra.s     mrkfile
hidmrk    btst      #1,21(A1)           ; Verborgene Datei?
          beq.s     wfsp
          moveq     #'#',D1
mrkfile   bsr       chrout
          bra.s     fnout
wfsp      bsr       spc
fnout     lea       30(A1),A1
          bsr       textout
          movea.l   A1,A2               ; LÑnge des Filenamens ausrechnen
          lea       16(A1),A4
loop59    tst.b     (A2)+
          bne       loop59
          suba.l    A2,A4
          move.l    A4,D7
          bsr       spcn
          move.l    -(A1),D1            ; Ausgabe der Filegrîûe
          moveq     #0,D2
          moveq     #dec,D3
          sf        D4
          sf        D5
          bsr       changeval
          lea       8(A4),A2
          suba.l    A5,A2
          move.l    A2,D7
          bsr       spcn
          exg       A4,A1
          bsr       textout
          moveq     #2,D7
          bsr       spcn
          movea.l   A4,A1
          move.l    -(A1),D6            ; Ausgabe von Datum und Uhrzeit
          moveq     #2,D2
          move.l    D6,D1               ; Tag
          and.l     #%11111,D1
          bsr       wrtval
          moveq     #'-',D1
          bsr       chrout
          move.l    D6,D1               ; Monat
          lsr.l     #5,D1
          and.l     #%1111,D1
          bsr       wrtval
          moveq     #'-',D1
          bsr       chrout
          move.l    D6,D1               ; Jahr
          lsr.l     #8,D1
          lsr.l     #1,D1
          and.l     #%1111111,D1
          add.l     #80,D1
          divu      #100,D1
          swap      D1
          and.l     #$FFFF,D1
          bsr       wrtval
          moveq     #2,D7
          bsr       spcn
          swap      D6
          move.l    D6,D1               ; Stunde
          lsr.l     #8,D1
          lsr.l     #3,D1
          and.l     #%11111,D1
          bsr       wrtval
          moveq     #':',D1
          bsr       chrout
          move.l    D6,D1               ; Minute
          lsr.l     #5,D1
          and.l     #%111111,D1
          bsr       wrtval
          moveq     #':',D1
          bsr       chrout
          move.l    D6,D1               ; Sekunde
          and.l     #%11111,D1
          add.l     D1,D1
          bra       wrtvalln
          rts

dirlnout  bsr       mcur_on             ; Zeilenausgabe Directory
          move.w    #SNEXT,-(SP)
          trap      #GEMDOS
          addq.l    #2,SP
          tst.l     D0                  ; Kein Eintrag mehr vorhanden?
          bne.s     dloend
          bsr       mcur_off
          bsr       wrtfname
dloend    bsr       dskerrout
          sne       D0
          rts

makedir   bsr       mcur_on             ; Neuen Ordner einrichten
          pea       (A3)                ; A3: Ordnername
          move.w    #MKDIR,-(SP)
          trap      #GEMDOS
          addq.l    #6,SP
          bra       dskerrout

changedir bsr       mcur_on             ; Aktuelles Directory Ñndern
          pea       (A3)                ; A3: Ordnername
          move.w    #CHDIR,-(SP)
          trap      #GEMDOS
          addq.l    #6,SP
          bra       dskerrout

deldir    pea       (A3)                ; Ordner und Files darin lîschen
          move.w    #CHDIR,-(SP)        ; A3: Ordnername
          trap      #GEMDOS             ; A1: DTA
          addq.l    #6,SP               ; A2: Puffer fÅr Maske und Pfad
          tst.l     D0                  ; Fehler?
          bmi       deldirend
loop104a  move.b    #'*',(A2)           ; Setzen der Maske
          move.b    #'.',1(A2)
          move.b    #'*',2(A2)
          clr.b     3(A2)
loop104b  move.w    #$16,-(SP)          ; Alle Dateien und Ordner
          pea       (A2)
          move.w    #SFIRST,-(SP)
          trap      #GEMDOS
          addq.l    #8,SP
          move.w    #SNEXT,-(SP)        ; Erste zwei EintrÑge Åberspringen
          trap      #GEMDOS
          trap      #GEMDOS
          addq.l    #2,SP
          tst.l     D0                  ; Keine Datei gefunden?
          bmi.s     ddret               ; Nein
          btst      #4,21(A1)           ; Ordner im Ordner?
          beq.s     delfile
          lea       30(A1),A3           ; Ordnername nach A3
          bsr       deldir              ; Rekursiver Aufruf von deldir
          bmi.s     deldirend           ; Fehler
          bra       loop104a
delfile   pea       30(A1)              ; Dateiname
          move.w    #UNLINK,-(SP)       ; Datei lîschen
          trap      #GEMDOS
          addq.l    #6,SP
          tst.l     D0                  ; Disk schreibgeschÅtzt?
          bpl       loop104b            ; Nein
ddret     pea       (A2)                ; Zum Åbergeordneten Subdirectory
          clr.w     -(SP)               ; Aktuelles Laufwerk
          pea       (A2)
          move.w    #GETDIR,-(SP)       ; Pfad holen
          trap      #GEMDOS
          addq.l    #8,SP
loop105   tst.b     (A2)                ; Ende des Strings?
          beq.s     brklp105            ; Dann Schleife abbrechen
          cmpi.b    #'\',(A2)+          ; Querbalken?
          bne.s     loop105             ; Nein
          movea.l   A2,A3               ; Adresse merken
          bra       loop105
brklp105  move.b    (A3),D1             ; Erstes Zeichen retten
          clr.b     (A3)                ; Letzter Ordnername wird abgeschnitten
          move.l    (SP)+,A2            ; Alter Inhalt von A2
          pea       (A2)                ; Pfad zum Åbergeordneten Folder
          move.w    #CHDIR,-(SP)
          trap      #GEMDOS
          addq.l    #6,SP
          move.b    D1,(A3)             ; Letzten Ordner berÅcksichtigen
          pea       (A2)                ; Jetzt erst Ordner lîschen
          move.w    #RMDIR,-(SP)
          trap      #GEMDOS
          addq.l    #6,SP
          tst.l     D0                  ; Fehler?
deldirend rts                           ; D0: Fehlernummer, falls Fehler

relmoddir bsr       mcur_on             ; Ordner lîschen
          movem.l   D1/A1-A3,-(SP)      ; A3: Ordnername
          lea       dirbuf(PC),A1
          pea       (A1)                ; Disk Transfer Address
          move.w    #SETDTA,-(SP)       ; setzen
          trap      #GEMDOS
          addq.l    #6,SP
          lea       strbuf(PC),A2
          bsr       deldir
          movem.l   (SP)+,D1/A1-A3
          bra       dskerrout

flprd     bsr       mcur_on             ; Lesen eines Sektors
          movem.l   D1-D2/A0-A2,-(SP)   ; D1: Track
          move.w    #1,-(SP)            ; D2: Sektor
          move.w    diskside(PC),-(SP)  ; A6: Puffer
          move.w    D1,-(SP)
          move.w    D2,-(SP)
          bsr       curdisk
          move.w    D0,-(SP)
          clr.l     -(SP)
          pea       (A6)
          move.w    #FLOPRD,-(SP)
          trap      #XBIOS
          adda.w    #20,SP
          movem.l   (SP)+,D1-D2/A0-A2
          bra       dskerrout

flpwr     bsr       mcur_on             ; Schreiben eines Sektors
          movem.l   D1-D2/A0-A2,-(SP)   ; D1: Track
          move.w    #1,-(SP)            ; D2: Sektor
          move.w    diskside(PC),-(SP)  ; A6: Puffer
          move.w    D1,-(SP)
          move.w    D2,-(SP)
          bsr       curdisk
          move.w    D0,-(SP)
          clr.l     -(SP)
          pea       (A6)
          move.w    #FLOPWR,-(SP)
          trap      #XBIOS
          adda.w    #20,SP
          movem.l   (SP)+,D1-D2/A0-A2
          bra       dskerrout

fmlnout   bsr       point2              ; Zeilenausgabe Sektorenanzeige
          moveq     #'-',D1
          bsr       chrout
          bsr       spc
          moveq     #3,D2
          move.l    A5,D1               ; Adresse ausgeben
          bsr       wrtval
          bsr       spc
          lea       strbuf(PC),A6
          moveq     #4,D2               ; Worte
          moveq     #7,D6               ; Acht StÅck
loop52    bsr       spc
          movea.l   flopbuf(PC),A2
          move.w    0(A2,A5.l),D1
          addq.l    #2,A5
          move.w    D1,(A6)+
          bsr       wrtval
          cmpa.l    #$200,A5
          dbcc      D6,loop52
          subq.w    #1,D6
          tst.w     D6
          bpl.s     nocho
          move.w    #6,D7
          bsr       spcn
          lea       strbuf(PC),A6
          bsr       rev_on              ; Zeichencodes ausgeben
          moveq     #15,D6              ; 16 Zeichen
loop53    move.b    (A6)+,D1
          cmp.b     #32,D1              ; Kein Zeichencode?
          bcs.s     pt2
          cmp.b     #127,D1
          bne.s     cho2
pt2       moveq     #'.',D1
cho2      bsr       chrout
          dbra      D6,loop53
          bsr       rev_off
nocho     bsr       cret
          cmpa.l    A4,A5
          shi       D0                  ; Abbruchbedingung
          rts

initfpbuf movem.l   D1-D2/A2,-(SP)      ; Sektorpuffer einrichten
          move.l    #$600,-(SP)
          move.w    #MALLOC,-(SP)
          trap      #GEMDOS
          addq.l    #6,SP
          lea       flopbuf(PC),A2
          move.l    D0,(A2)
          bmi.s     ifbend              ; Fehler
          lea       flopbuf2(PC),A2
          move.l    D0,D1
          add.l     #$200,D1
          move.l    D1,(A2)
          lea       flopbuf3(PC),A2
          add.l     #$200,D1
          move.l    D1,(A2)
          movea.l   D0,A2               ; Sektorpuffer lîschen
          move.w    #$5FF,D2            ; 1536 Bytes
loop55    clr.b     (A2)+
          dbra      D2,loop55
          lea       diskside(PC),A2
          move.w    #0,(A2)
          movem.l   (SP)+,D1-D2/A2
          tst.l     D0
ifbend    rts

delfpbuf  move.l    flopbuf(PC),-(SP)   ; Sektorpuffer wieder freigeben
          move.w    #MFREE,-(SP)
          trap      #GEMDOS
          addq.l    #6,SP
          rts

rname     bsr       mcur_on             ; File umbenennen
          pea       (A3)                ; A4: Alter Filename
          pea       (A4)                ; A3: Neuer Name
          clr.w     -(SP)
          move.w    #RENAME,-(SP)
          trap      #GEMDOS
          adda.w    #12,SP
          bra       dskerrout

* Ende der Bibliothek Teil 1

