***********************
*  Fullscreen-Editor  *
*                     *
*   Copyright 1988    *
* by Bernd Nottelmann *
***********************


CONOUT    equ       $02                 ; GEMDOS-Routinen
AUXOUT    equ       $04
PRINTOUT  equ       $05
DIRCONIN  equ       $07
PLINE     equ       $09
CONSTAT   equ       $0B
PRTOUTST  equ       $11
AUXOUTST  equ       $13

BCONOUT   equ       3                   ; BIOS-Routine

PHYSBASE  equ       2                   ; XBIOS-Routinen
LOGBASE   equ       3
GETREZ    equ       4
SETSCREEN equ       5
IOREC     equ       14
KEYTBL    equ       16
CURSOR    equ       21
BIOSKEYS  equ       24

CON       equ       2                   ; Device-Nummer

exitconst equ       $12345678           ; Markiert Ende des Programms


*************************************************************************
* Steuercodes:                                                          *
*                                                                       *
* Taste           Funktion            SCAN-Code  ASCII-Code  bei Shift  *
* ====================================================================  *
* [Return]        ZeilenrÅcklauf          28         13          13     *
* [Backspace]     Vorderes Zeichen        14          8           8     *
*                 lîschen                                               *
* [Delete]        Zeichen unter Cur-      83        127          12     *
*                 sor/Zeile lîschen                                     *
* [Insert]        Blank/Zeile einfÅgen    82         10          11     *
* [Clr Home]      Cursor in die linke     71          6           7     *
*                 obere Ecke/Bildschirm                                 *
*                 lîschen                                               *
* [Cursor left]   Cursor nach links       75          4           4     *
* [Cursor right]  Cursor nach rechts      77          3           3     *
* [Cursor up]     Cursor nach oben        72          1           1     *
* [Cursor down]   Cursor nach unten       80          2           2     *
* [Undo]          Rest einer Zeile        97          5          15     *
*                 lîschen/4000-Zeichen                                  *
*                 ausschalten                                           *
* [Tab]           Zur nÑchsten Tabula-    15          9           9     *
*                 torspalte springen                                    *
* [Help]          Bildschirmspeicher      98         14          16     *
*                 ausgeben/4000 Zeichen-                                *
*                 Modus einschalten                                     *
*************************************************************************


* Unterprogramme
cout      movem.l   D0-D2/A0-A2,-(SP)   ; Gibt Zeichen aus
          move.w    D1,-(SP)            ; D1: Zeichen
          move.w    #CON,-(SP)
          move.w    #BCONOUT,-(SP)
          trap      #BIOS
          addq.l    #6,SP
          movem.l   (SP)+,D0-D2/A0-A2
          rts

cout2     move.l    D0,-(SP)            ; Gibt Zeichen Åber GEMDOS aus
          move.w    D1,-(SP)            ; D1: Zeichen
          move.w    #CONOUT,-(SP)
          trap      #GEMDOS
          addq.l    #4,SP
          move.l    (SP)+,D0
          rts

conoutesc move.l    D0,-(SP)            ; Gibt Steuerzeichen aus
          move.w    #27,-(SP)           ; D1: Zeichen
          move.w    #CONOUT,-(SP)
          trap      #GEMDOS
          move.w    D1,2(SP)
          trap      #1
          addq.l    #4,SP
          move.l    (SP)+,D0
          rts

homexy    pea       (A0)
          lea       xpos(PC),A0
          clr.w     (A0)
          lea       ypos(PC),A0
          clr.w     (A0)
          movea.l   (SP)+,A0
          rts

scrlen    move.w    columns+2(PC),D1    ; BildschirmspeicherlÑnge berechnen
          mulu      lines+2(PC),D1
          rts                           ; D1: LÑnge

clrscr    movem.l   D1/A0,-(SP)         ; Lîscht den Textbildschirm
          moveq     #69,D1
          bsr       conoutesc
          bsr       scrlen
          subq.l    #1,D1
          movea.l   screen(PC),A0       ; Anfangsadresse
loop1     move.b    #' ',(A0)+          ; Mit Blanks auffÅllen
          dbra      D1,loop1
          bsr       homexy
          movem.l   (SP)+,D1/A0
          rts

calcpos   movem.l   D1-D2,-(SP)         ; Berechnung der Pufferadresse
          move.w    ypos(PC),D2
          mulu      columns+2(PC),D2    ; A0=Pufferbasis+x+y*80
          move.w    xpos(PC),D1
          ext.l     D1
          add.l     D2,D1
          movea.l   screen(PC),A0
          adda.l    D1,A0
          movem.l   (SP)+,D1-D2
          rts                           ; A0: Cursorposition

scroll_up movem.l   D1/A0-A1,-(SP)      ; Scrollt Zeichenpuffer nach oben
          bsr       scrlen
          sub.w     columns+2(PC),D1
          subq.w    #1,D1
          movea.l   screen(PC),A0       ; Anfangsadresse des Puffers
          movea.l   A0,A1
          adda.w    columns+2(PC),A1    ; Anfangsadresse der zweiten Zeile
loop2     move.b    (A1)+,(A0)+
          dbra      D1,loop2
          move.w    columns+2(PC),D1    ; Unterste Zeile mit Blanks fÅllen
          subq.w    #1,D1
loop3     move.b    #32,(A0)+
          dbra      D1,loop3
          movem.l   (SP)+,D1/A0-A1
          rts

chroutbuf movem.l   D2/A0-A1,-(SP)      ; Gibt ein Zeichen (kein Steuer-
          bsr       cout                ; zeichen!) aus mit VerÑnderung
          bsr       calcpos             ; des Zeichenpuffers
          move.b    D1,(A0)             ; Zeichen in den Puffer
          lea       xpos(PC),A0
          lea       ypos(PC),A1
          addq.w    #1,(A0)
          move.w    columns+2(PC),D2
          cmp.w     (A0),D2             ; x>79?
          bhi.s     nil                 ; Nein, dann nichts machen
          clr.w     (A0)
          addq.w    #1,(A1)
          move.w    lines+2(PC),D2
          cmp.w     (A1),D2             ; y>24?
          bhi.s     nil                 ; Nein, dann kein Scrolling
          subq.w    #1,D2
          move.w    D2,(A1)
          bsr       scroll_up
nil       movem.l   (SP)+,D2/A0-A1
          rts

wrap_on   move.w    D1,-(SP)            ; Aktiviert automatischen Zeilen-
          move.w    #118,D1             ; Åberlauf
          bsr       conoutesc
          move.w    (SP)+,D1
          rts

wrap_off  move.w    D1,-(SP)            ; Desaktiviert automatischen
          move.w    #119,D1             ; ZeilenÅberlauf
          bsr       conoutesc
          move.w    (SP)+,D1
          rts

cur_on    move.w    D1,-(SP)            ; Cursor einschalten
          move.w    #101,D1
          bsr       conoutesc
          move.w    (SP)+,D1
          rts

cur_off   move.w    D1,-(SP)            ; Cursor ausschalten
          move.w    #102,D1
          bsr       conoutesc
          move.w    (SP)+,D1
          rts

rev_on    move.w    D1,-(SP)            ; Inverse Schrift an
          move.w    #112,D1
          bsr       conoutesc
          move.w    (SP)+,D1
          rts

rev_off   move.w    D1,-(SP)            ; Inverse Schrift aus
          move.w    #113,D1
          bsr       conoutesc
          move.w    (SP)+,D1
          rts

gotoxy    move.w    D1,-(SP)            ; Cursorpositionierung
          move.w    #89,D1
          bsr       conoutesc
          move.w    ypos(PC),D1
          add.w     #32,D1
          bsr       cout2
          move.w    xpos(PC),D1
          add.w     #32,D1
          bsr       cout2
          move.w    (SP)+,D1
          rts

calceol   pea       (A2)                ; Zeilenende ermitteln
          bsr       calcpos             ; Berechnung der Cursorposition
          move.l    A0,A1
          lea       xpos(PC),A2
          move.w    (A2),-(SP)          ; x retten
          move.w    columns+2(PC),(A2)
          subq.w    #1,(A2)
          bsr       calcpos             ; Adresse des Zeilenendes berechnen
          move.w    (SP)+,(A2)          ; x wiederherstellen
          movea.l   (SP)+,A2            ; A1: Cursorposition
          rts                           ; A0: Zeilenende

scrbyte   movem.l   D0-D1/A1,-(SP)      ; Startbyte eines Zeichens
          movea.l   base(PC),A0         ; berechnen
          moveq     #0,D2
          move.w    2(A0),D2            ; Bytes pro Videozeile
          moveq     #0,D3
          move.w    (A0),D3
          add.w     D3,D3
          subq.w    #1,D3               ; 2 * Bitplanes - 1
          move.w    ypos(PC),D0         ; y * Zeichenhîhe * Zeilenbreite (B)
          mulu      chrheight(PC),D0
          mulu      2(A0),D0
          move.w    xpos(PC),D1
          ror.w     #1,D1               ; Bit 0 ins X-Flag retten
          add.w     D1,D1
          mulu      (A0),D1             ; x div 2 * Planes + X-Flag
          roxr.w    #1,D1
          rol.w     #1,D1
          add.l     D0,D1
          movea.l   logbs(PC),A2
          movea.l   D2,A0               ; Zeilenbreite
          adda.l    A2,A0
          adda.l    D0,A0               ; D2: Bytes pro Videozeile
          adda.l    D1,A2               ; D3: 2 * Bitplanes - 1
          movem.l   (SP)+,D0-D1/A1      ; A2: Startbyte des Zeichens
          rts                           ; A0: Endbyte einer Zeile

chrdel    movem.l   D0-D3/A0-A3,-(SP)   ; Lîscht ein Zeichen
          bsr       calceol             ; Berechnung der Cursorposition
          movea.l   A1,A2
          lea       1(A1),A3
loop5     cmpa.l    A0,A3
          bhi.s     exit1
          move.b    (A3)+,(A2)+
          bra       loop5
exit1     move.b    #' ',(A2)           ; Blank rÅckt nach
          bsr       cur_off
          bsr       scrbyte
          neg.w     D3
          move.w    chrheight(PC),D0
          subq.w    #1,D0
loop69    movea.l   A2,A1
          move.w    A2,D1
          lsr.w     #1,D1               ; Gerade oder ungerade Startadresse?
          bcc.s     cd_odd              ; Gerade
          suba.w    D3,A1               ; Startadresse + 2 * Bitplanes - 1
loop70    cmpa.l    A0,A1
          bcc.s     exit3
          lea       0(A1,D3.w),A3
          cmpa.l    A2,A3
          bcs.s     cd_odd
          move.b    (A1),(A3)
cd_odd    addq.w    #1,A1
          cmpa.l    A0,A1
          bcc.s     exit3
          move.b    (A1)+,-2(A1)
          bra       loop70
exit3     move.w    D3,D1
          neg.w     D1
          lsr.w     #1,D1
loop71    clr.b     -(A1)               ; Blank rÅckt nach
          subq.w    #1,A1
          dbra      D1,loop71
          adda.w    D2,A2
          adda.w    D2,A0
          dbra      D0,loop69
          bsr       cur_on
          movem.l   (SP)+,D0-D3/A0-A3
          rts

chrins    movem.l   D0/D2-D3/A0-A3,-(SP); FÅgt ein Blank ein
          bsr       calceol
          movea.l   A0,A2
          lea       1(A0),A3
loop6     cmpa.l    A1,A2
          bls.s     exit2
          move.b    -(A2),-(A3)
          bra       loop6
exit2     move.b    #' ',(A2)           ; Blank wird eingefÅgt
          bsr       cur_off
          bsr       scrbyte
          move.w    chrheight(PC),D0
          subq.w    #1,D0
loop72    lea       -1(A0),A1
loop73    cmpa.l    A2,A1
          bls.s     exit4
          move.b    -(A1),1(A1)
          cmpa.l    A2,A1
          bls.s     exit4
          subq.w    #1,A1
          lea       0(A1,D3.w),A3
          cmpa.l    A0,A3
          bcc.s     loop73
          move.b    (A1),(A3)
          bra       loop73
exit4     move.w    D3,D1
          lsr.w     #1,D1
loop74    clr.b     (A1)                ; Blank wird eingefÅgt
          addq.w    #2,A1
          dbra      D1,loop74
          adda.w    D2,A2
          adda.w    D2,A0
          dbra      D0,loop72
          bsr       cur_on
          movem.l   (SP)+,D0/D2-D3/A0-A3
          rts

linedata  movem.l   A0-A2,-(SP)         ; Zeilenanfang und-ende ermitteln
          lea       xpos(PC),A2
          move.w    (A2),-(SP)          ; x retten
          clr.w     (A2)
          bsr       calceol             ; Anfang und Ende berechnen
          move.w    (SP)+,(A2)          ; x wiederherstellen
          lea       lnstart(PC),A2
          move.l    A1,(A2)
          lea       lnend(PC),A2
          move.l    A0,(A2)
          movem.l   (SP)+,A0-A2
          rts

linedel   movem.l   D1-D2/A0/A2,-(SP)   ; Zeile lîschen
          bsr       linedata
          move.w    columns+2(PC),D2
          move.w    D2,D1
          subq.w    #1,D2
          mulu      lines+2(PC),D1      ; Endadresse des Bildschirms
          add.l     screen(PC),D1       ; berechnen
          movea.l   lnend(PC),A0
          addq.l    #1,A0
          sub.l     A0,D1
          beq.s     loop66
          subq.w    #1,D1
          movea.l   lnstart(PC),A2
loop65    move.b    (A0)+,(A2)+
          dbra      D1,loop65
loop66    move.b    #' ',-(A0)
          dbra      D2,loop66
          lea       xpos(PC),A2
          clr.w     (A2)                ; Cursor steht am Zeilenanfang
          moveq     #77,D1
          bsr       conoutesc
          movem.l   (SP)+,D1-D2/A0/A2
          rts

lineins   movem.l   D1-D2/A0/A2,-(SP)   ; Zeile einfÅgen
          bsr       linedata
          move.l    columns(PC),D2
          move.w    D2,D1
          mulu      lines+2(PC),D1      ; Endadresse des Bildschirms
          movea.l   screen(PC),A2       ; berechnen
          adda.l    D1,A2
          movea.l   A2,A0
          suba.l    D2,A0
          subq.w    #1,D2
          move.l    A0,D1
          sub.l     lnstart(PC),D1
          beq.s     loop68
          subq.w    #1,D1
loop67    move.b    -(A0),-(A2)
          dbra      D1,loop67
loop68    move.b    #' ',(A0)+
          dbra      D2,loop68
          lea       xpos(PC),A2
          clr.w     (A2)                ; Cursor steht am Zeilenanfang
          moveq     #76,D1
          bsr       conoutesc
          movem.l   (SP)+,D1-D2/A0/A2
          rts

donothing rts

cur_left  movem.l   D1/A0-A1,-(SP)      ; Cursor nach links
          lea       xpos(PC),A0
          lea       ypos(PC),A1
          tst.w     (A0)                ; x=0?
          bne.s     dec_x               ; Nein, dann x einfach erniedrigen
          tst.w     (A1)                ; y=0?
          beq.s     clend               ; Ja, dann nichts machen
          move.w    columns+2(PC),(A0)  ; x:=79
          subq.w    #1,(A0)
          subq.w    #1,(A1)             ; y:=y-1
          bsr       gotoxy
          bra.s     clend
dec_x     subq.w    #1,(A0)             ; x:=x-1
          moveq     #8,D1
          bsr       cout2
clend     movem.l   (SP)+,D1/A0-A1
          rts

cur_right movem.l   D1/A0-A1,-(SP)      ; Cursor nach rechts
          lea       xpos(PC),A0
          lea       ypos(PC),A1
          move.w    columns+2(PC),D1
          subq.w    #1,D1
          cmp.w     (A0),D1             ; x=79?
          bne.s     inc_x               ; Nein, dann x einfach erhîhen
          move.w    lines+2(PC),D1
          subq.w    #1,D1
          cmp.w     (A1),D1             ; y=24?
          bne.s     noscr               ; Nein, dann nicht scrollen
          bsr       scroll_up
          subq.w    #1,(A1)             ; y:=y-1
noscr     clr.w     (A0)                ; x:=0
          addq.w    #1,(A1)             ; y:=y+1
          moveq     #13,D1
          bsr       cout2
          moveq     #10,D1
          bsr       cout2
          bra.s     crend
inc_x     addq.w    #1,(A0)             ; x:=x+1
          moveq     #67,D1
          bsr       conoutesc
crend     movem.l   (SP)+,D1/A0-A1
          rts

cur_up    movem.l   D1/A0,-(SP)         ; Cursor nach oben
          lea       ypos(PC),A0
          tst.w     (A0)                ; y=0?
          beq.s     cuend               ; Ja, dann nichts tun
          subq.w    #1,(A0)             ; y:=y-1
          moveq     #65,D1
          bsr       conoutesc
cuend     movem.l   (SP)+,D1/A0
          rts

cur_down  movem.l   D1/A0-A1,-(SP)      ; Cursor nach unten
          lea       ypos(PC),A0
          move.w    lines+2(PC),D1
          subq.w    #1,D1
          cmp.w     (A0),D1             ; y=24?
          bne.s     inc_y               ; Nein, dann y erhîhen
          bsr       scroll_up           ; Puffer nach oben scrollen
          lea       lnstart(PC),A1      ; Zeilendaten eine Zeile hoch
          move.l    (A1),D1
          subq.l    #1,D1
          move.l    D1,4(A1)            ; Neues Zeilenende
          sub.l     columns(PC),D1
          addq.l    #1,D1
          move.l    D1,(A1)             ; Neuer Zeilenanfang
          bra.s     cdown
inc_y     addq.w    #1,(A0)             ; y:=y+1
cdown     moveq     #10,D1
          bsr       cout2
          movem.l   (SP)+,D1/A0-A1
          rts

return    movem.l   D1/A0,-(SP)         ; Return ausgeben
          bsr       cur_down
          lea       xpos(PC),A0
          clr.w     (A0)                ; x:=0
          moveq     #13,D1
          bsr       cout2
          movem.l   (SP)+,D1/A0
          rts

backspace move.w    D1,-(SP)            ; Zeichen links vom Cursor lîschen
          move.w    xpos(PC),D1
          bne.s     back                ; Nein, dann lîschen
          move.w    ypos(PC),D1
          beq.s     backend             ; Ja, dann nichts tun
back      bsr       cur_left
          bsr       chrdel
backend   move.w    (SP)+,D1
          rts

delete    bra       chrdel              ; Zeichen unter dem Cursor lîschen

clreol    movem.l   D1/A0-A1,-(SP)      ; Zeile von der Cursorposition bis
          bsr       calceol             ; zum Ende lîschen
loop60    move.b    #' ',(A1)+
          cmpa.l    A0,A1
          bls       loop60
          moveq     #75,D1
          bsr       conoutesc
          movem.l   (SP)+,D1/A0-A1
          rts

insert    bra       chrins              ; Zeichen einfÅgen

clr       bra       clrscr              ; Bildschirm lîschen

home      bsr       homexy              ; Cursor in linke obere Ecke setzen
          bra       gotoxy

tabout    movem.l   D1/A2,-(SP)
          move.w    xpos(PC),D1         ; Zur nÑchsten Tabulatorposition
          lea       tablist(PC),A2      ; gehen
loop48    cmp.b     (A2)+,D1
          bcs.s     brklp48
          subq.l    #1,A2
          cmpm.b    (A2)+,(A2)+
          bls.s     brklp48
          subq.l    #1,A2
          bra       loop48
brklp48   moveq     #0,D1
          move.b    -(A2),D1
          divu      columns+2(PC),D1    ; Spaltenzahl darf 80 nicht Åber-
          swap      D1                  ; schreiten
loop49    bsr       cur_right
          cmp.w     xpos(PC),D1         ; Position erreicht?
          bne       loop49
          movem.l   (SP)+,D1/A2
          rts

repscr    movem.l   D0-D2/A0/A2-A3,-(SP); Bildschirmspeicher ausgeben
          movea.l   screen(PC),A2
          movea.l   A2,A3
          bsr       scrlen
          adda.l    D1,A3
          clr.w     D2
          move.b    -(A3),D2            ; Letztes Zeichen retten
          clr.b     (A3)
          bsr       cur_off
          moveq     #72,D1              ; Cursor in die linke obere Ecke
          bsr       conoutesc
          pea       (A2)
          move.w    #PLINE,-(SP)
          trap      #GEMDOS
          addq.l    #6,SP
          bsr       wrap_off
          move.b    D2,(A3)
          move.w    D2,D1               ; Letztes Zeichen ausgeben
          bsr       cout
          bsr       gotoxy              ; ZurÅck auf die alte Position
          bsr       wrap_on
          bsr       cur_on
          movem.l   (SP)+,D0-D2/A0/A2-A3
          rts

setfont   lea       $2934,A4            ; Zeichensatzdaten initialisieren
          movea.l   $4F2,A2
          cmpi.w    #$1987,$1A(A2)      ; TOS vom 18.07.1985 oder 06.02.1986?
          bcs.s     no_1987             ; Ja
          lea       $60(A4),A4          ; Wenn von 1987, dann andere Basis
          cmpi.w    #$1989,$1A(A2)      ; Sogar von 1989?
          bcs.s     no_1987             ; Nein
          lea       $142(A4),A4         ; Noch 'ne andere Basis
no_1987   move.w    82(A0),D0           ; A0: Adresse des Fontheaders
          move.w    D0,-40(A4)          ; Hîhe der Zeichen
          moveq     #80,D1              ; Anzahl Bytes pro Bildschirmzeile
          mulu      D0,D1               ; mal Hîhe eines Zeichens
          move.w    D1,-34(A4)          ; ergibt Bytes pro Charakterzeile
          move.l    #400,D1             ; Bildschirmhîhe
          divu      D0,D1               ; durch Fonthîhe
          lea       lines+2(PC),A2      ; ergibt Zeilenzahl
          move.w    D1,(A2)
          subq.w    #1,D1               ; minus 1
          move.w    D1,-36(A4)          ; ergibt maximale Cursorzeile
          move.l    #640,D1             ; Bildschirmbreite
          divu      52(A0),D1           ; durch maximale Zeichenbreite
          lea       columns+2(PC),A2    ; ergibt Zeilenzahl
          move.w    D1,(A2)
          subq.w    #1,D1               ; minus 1
          move.w    D1,-38(A4)          ; ergibt maximale Cursorspalte
          move.w    80(A0),-8(A4)       ; Breite des Fonts
          move.w    36(A0),-10(A4)      ; Kleinster ASCII-Code
          move.w    38(A0),-12(A4)      ; Grîûter ASCII-Code
          move.l    76(A0),-16(A4)      ; Zeiger auf Fontdaten
          move.l    72(A0),-4(A4)       ; Zeiger auf Offsetdaten
          lea       chrwidth(PC),A2     ; Zeichenbreite und -hîhe ermitteln
          move.w    52(A0),(A2)
          lea       chrheight(PC),A2
          move.w    D0,(A2)
          lea       xpos(PC),A2         ; Cursor nach links oben
          clr.w     (A2)
          lea       ypos(PC),A2
          clr.w     (A2)
          moveq     #69,D1              ; Bildschirm lîschen
          bra       conoutesc

setlow    movem.l   D0-D1/A0/A2/A4,-(SP); 2000 Zeichen-Modus setzen
          move.w    res(PC),D0
          cmp.w     #2,D0               ; Hohe Auflîsung?
          bne.s     slend
          move.w    lines+2(PC),D0
          cmp.w     #50,D0              ; 4000 Zeichen-Modus?
          bne.s     slend
          move.l    fonts(PC),A2        ; Adresse der Zeichenfontzeiger
          move.l    8(A2),A0            ; 8*16 System Font
          bsr       setfont             ; Fontdaten initialisieren
          bsr       repscr              ; Bildschirminhalt wieder
slend     movem.l   (SP)+,D0-D1/A0/A2/A4; herstellen
          rts

sethigh   movem.l   D0-D1/A0/A2/A4,-(SP); 4000 Zeichen-Modus setzen
          move.w    res(PC),D0
          cmp.w     #2,D0               ; Hohe Auflîsung?
          bne.s     shend
          move.w    lines+2(PC),D0
          cmp.w     #50,D0              ; 4000 Zeichen-Modus?
          beq.s     shend
          move.l    fonts(PC),A2        ; Adresse der Zeichenfontzeiger
          move.l    4(A2),A0            ; 8*8 System Font
          bsr       setfont
          lea       lines+2(PC),A2
          move.w    #25,(A2)            ; 2000 Zeichen ausgeben
          bsr       repscr              ; Alten Bildschirminhalt wieder
          move.w    #50,(A2)            ; herstellen
          move.l    screen(PC),A2       ; Der untere Teil des Bildschirm-
          adda.w    #2000,A2            ; puffers wird gelîscht
          move.w    #1999,D0
loop87    move.b    #' ',(A2)+
          dbra      D0,loop87
shend     movem.l   (SP)+,D0-D1/A0/A2/A4
          rts

prttst    lea       lstaux(PC),A3       ; Drucker-Status ÅberprÅfen
          tst.b     (A3)                ; Centronics oder RS232?
          beq.s     rs232_1
          move.w    #PRTOUTST,-(SP)
          bra.s     prtst
rs232_1   move.w    #AUXOUTST,-(SP)
prtst     trap      #GEMDOS
          addq.l    #2,SP
          tst.l     D0                  ; Z gesetzt: Drucker nicht bereit
          rts

prtout    movem.l   D0/A3,-(SP)         ; Zeichen auf dem Drucker ausgeben
          lea       printer(PC),A3      ; D1: ASCII-Code
          tst.b     (A3)
          beq.s     poend
          lea       prton(PC),A3
          tst.b     (A3)
          beq.s     poend
          clr.w     -(SP)
          move.b    D1,1(SP)
          lea       lstaux(PC),A3       ; Centronics oder RS232?
          tst.b     (A3)
          beq.s     rs232_2
          move.w    #PRINTOUT,-(SP)
          bra.s     prto
rs232_2   move.w    #AUXOUT,-(SP)
prto      trap      #GEMDOS
          addq.l    #4,SP
          tst.w     D0
          bne.s     poend
          lea       prton(PC),A3
          sf        (A3)
poend     movem.l   (SP)+,D0/A3
          rts

chrout    movem.l   D1/A2,-(SP)         ; Zeichen (einschlieûlich Steuer-
          and.w     #$00FF,D1           ; codes) mit VerÑnderung des Zei-
          beq       choend              ; chenpuffers ausgeben
          cmp.w     #16,D1              ; D1: ASCII-Code des Zeichens
          bhi.s     chbd
          subq.w    #1,D1
          lsl.w     #2,D1
          jsr       chotab(PC,D1.w)
          lsr.w     #2,D1
          addq.w    #1,D1
          bra.s     chroutprt
chotab    bra       cur_up
          bra       cur_down
          bra       cur_right
          bra       cur_left
          bra       clreol
          bra       home
          bra       clr
          bra       backspace
          bra       tabout
          bra       insert
          bra       lineins
          bra       linedel
          bra       return
          bra       repscr
          bra       setlow
          bra       sethigh
chbd      cmp.w     #127,D1
          bne.s     chb
          bsr       delete
          bra.s     lfc
chb       cmp.w     #32,D1
          bcs.s     choend
          bsr       chroutbuf
chroutprt lea       prton(PC),A2        ; Druckerflag gesetzt?
          tst.b     (A2)
          beq.s     choend
          cmp.w     #13,D1              ; ZeilenrÅcklauf?
          beq.s     prtreturn
          cmp.w     #32,D1
          bcs.s     choend
          cmp.w     #126,D1
          bls.s     chop
          cmp.w     #160,D1
          bcc.s     chop
lfc       move.b    lfillchar(PC),D1
          beq.s     choend
chop      bsr       prtout
          bra.s     choend
prtreturn move.w    #13,D1              ; ZeilenrÅcklauf und Linefeed
          bsr       prtout              ; ausgeben
          move.w    #10,D1
          bsr       prtout
choend    movem.l   (SP)+,D1/A2
          rts                           ; Kein gÅltiger ASCII-Code

initscr   movem.l   D1/A0-A2,-(SP)      ; Initialisierung des Bildschirms
          move.w    #PHYSBASE,-(SP)     ; Physikalische Bildschirmadresse
          trap      #XBIOS              ; ermitteln und merken
          addq.l    #2,SP
          lea       physbsbuf(PC),A2
          move.l    D0,(A2)
          move.w    #LOGBASE,-(SP)      ; Logische Bildschirmadresse
          trap      #XBIOS              ; ermitteln
          addq.l    #2,SP
          lea       logbs(PC),A2
          move.l    D0,(A2)
          move.w    #GETREZ,-(SP)       ; Auflîsung ermitteln
          trap      #XBIOS
          addq.l    #2,SP
          lea       resbuf(PC),A2
          move.w    D0,(A2)
          tst.w     D0                  ; Niedrigste Auflîsung?
          bne.s     medhires
          move.w    #1,D0               ; Mittlere Auflîsung
medhires  lea       res(PC),A2
          move.w    D0,(A2)
          lea       columns(PC),A2      ; Spalten- und Zeilenzahl setzen
          move.l    #80,(A2)
          lea       lines(PC),A2
          move.l    #25,(A2)
          lea       chrwidth(PC),A0     ; Zeichenbreite
          move.w    #8,(A0)
          lea       restab(PC),A2       ; Zeichenhîhe ermitteln
          lsl.w     #1,D0
          move.w    -2(A2,D0.w),D0
          and.l     #$FFFF,D0
          divu      lines+2(PC),D0
          lea       chrheight(PC),A0
          move.w    D0,(A0)
          move.w    res(PC),-(SP)       ; Nur mittlere und hohe Auflîsung
          move.l    logbs(PC),-(SP)     ; Logischer und physikalischer
          move.l    #-1,-(SP)           ; Bildschirm decken sich
          move.w    #SETSCREEN,-(SP)
          trap      #XBIOS
          adda.w    #12,SP
          bsr       scrlen              ; Platz fÅr den Bildschirmspeicher
          lea       res(PC),A2          ; schaffen
          cmp.w     #2,(A2)             ; Hohe Auflîsung?
          bne.s     nohiscr
          asl.l     #1,D1               ; Bildschirmspeicher ist bei hoher
nohiscr   move.l    D1,-(SP)            ; Auflîsung doppelt so groû (fÅr
          move.w    #MALLOC,-(SP)       ; 4000 Zeichen maximal)
          trap      #GEMDOS
          addq.l    #6,SP
          tst.l     D0
          bmi.s     isend
          lea       screen(PC),A2       ; Bildschirmstartadresse merken
          move.l    D0,(A2)
          lea       endofscr(PC),A2     ; Endadresse des Bildschirm-
          add.l     D0,D1               ; speichers berechnen
          move.l    D1,(A2)
          move.w    #113,D1             ; Keine inverse Schrift
          bsr       conoutesc
          bsr       wrap_on             ; Automatischer ZeilenÅberlauf
          bsr       clr                 ; Bildschirm lîschen
isend     movem.l   (SP)+,D1/A0-A2
          tst.l     D0
          rts

delscr    move.l    screen(PC),-(SP)    ; Bildschirmspeicherbereich wieder
          move.w    #MFREE,-(SP)        ; freigeben
          trap      #GEMDOS
          addq.l    #6,SP
          move.w    resbuf(PC),-(SP)    ; UrsprÅnglichen Bildschirm wieder
          move.l    physbsbuf(PC),-(SP) ; installieren
          move.l    logbs(PC),-(SP)
          move.w    #SETSCREEN,-(SP)
          trap      #XBIOS
          adda.w    #12,SP
          rts

initkeys  movem.l   D0-D2/A0-A2,-(SP)   ; Tastatur und Cursor installieren
          bsr       cur_on
          move.w    #30,-(SP)           ; Blinkfrequenz des Cursors ein-
          move.w    #4,-(SP)            ; stellen
          move.w    #CURSOR,-(SP)
          trap      #XBIOS
          addq.l    #6,SP
          move.l    #-1,-(SP)           ; Zeiger auf alte Tastaturtabellen
          move.l    #-1,-(SP)           ; retten
          move.l    #-1,-(SP)
          move.w    #KEYTBL,-(SP)
          trap      #14
          adda.w    #14,SP
          movea.l   D0,A0
          lea       oldkeytbl(PC),A1
          move.l    (A0)+,(A1)+
          move.l    (A0)+,(A1)+
          move.l    (A0),(A1)
          pea       keytab3(PC)         ; Eigene Tastaturtabellen anmelden
          pea       keytab2(PC)
          pea       keytab1(PC)
          move.w    #KEYTBL,-(SP)
          trap      #XBIOS
          adda.w    #14,SP
          move.w    #1,-(SP)            ; Puffer fÅr die Tastatur ermitteln
          move.w    #IOREC,-(SP)
          trap      #XBIOS
          addq.l    #4,SP
          lea       ibuf(PC),A0         ; Zeiger auf den Eingabepuffer
          move.l    D0,(A0)
          lea       ibufsiz(PC),A0      ; Puffergrîûe
          addq.l    #4,D0
          move.l    D0,(A0)
          lea       ibufhd(PC),A0       ; Head-Index
          addq.l    #2,D0
          move.l    D0,(A0)
          lea       ibuftl(PC),A0       ; Tail-Index
          addq.l    #2,D0
          move.l    D0,(A0)
          movem.l   (SP)+,D0-D2/A0-A2
          rts

rstkeys   movem.l   D0-D2/A0-A2,-(SP)   ; UrsprÅngliche Tastaturbelegung
          bsr       cur_off             ; wiederherstellen
loop75    move.w    #CONSTAT,-(SP)      ; Tastaturpuffer auslesen
          trap      #GEMDOS
          addq.l    #2,SP
          tst.l     D0
          beq.s     lpend75
          move.w    #DIRCONIN,-(SP)
          trap      #GEMDOS
          addq.l    #2,SP
          bra       loop75
lpend75   lea       oldkeytbl(PC),A1    ; Alte Tastaturtabellen
          adda.w    #12,A1
          move.l    -(A1),-(SP)
          move.l    -(A1),-(SP)
          move.l    -(A1),-(SP)
          move.w    #KEYTBL,-(SP)
          trap      #XBIOS
          adda.w    #14,SP
          movem.l   (SP)+,D0-D2/A0-A2
          rts

readkey   movem.l   D0/A0-A4,-(SP)      ; Taste einlesen
          movea.l   ibuf(PC),A0
          movea.l   ibufsiz(PC),A1
          movea.l   ibufhd(PC),A2
          movea.l   ibuftl(PC),A3
          move.w    (A3),(A2)           ; Tastaturpuffer lîschen
          move.w    (A2),D0
rkloop    cmp.w     (A3),D0             ; Taste gedrÅckt?
          beq       rkloop
          addq.w    #4,D0               ; ibufhd zeigt auf nÑchste Taste
          cmp.w     (A1),D0             ; Maximaler Index erreicht?
          bne.s     nomaxind
          clr.w     D0
nomaxind  move.w    D0,(A2)
          movea.l   (A0),A4             ; Adresse des Eingabepuffers
          adda.w    D0,A4               ; Head-Index hinzuaddieren
          move.l    (A4),D1             ; SCAN- und ASCII-Code nach D1
          movem.l   (SP)+,D0/A0-A4
          rts                           ; D1: SCAN- und ASCII-Code

* Eingabeschleife
getkey    lea       get(PC),A2          ; A1: Verarbeitungsroutine
          move.l    A1,(A2)
          lea       rbuffer(PC),A6
          bsr       initkeys
getloop   bsr       readkey
          bsr       linedata            ; Zeilenanfang und -ende ermitteln
          bsr       chrout
          cmp.w     #13,D1              ; Return gedrÅckt?
          bne       getloop             ; Nein, dann nÑchste Taste abwarten
          lea       rbuffer(PC),A6      ; Register wiederherstellen
          movem.l   (A6),D0-D7/A0-A5
          move.l    get(PC),A6
          jsr       (A6)                ; Verarbeitungsroutine
          lea       rbuffer(PC),A6      ; Register retten
          movem.l   D0-D7/A0-A5,(A6)
          cmp.l     #exitconst,D0       ; RÅckkehr zum Desktop?
          bne       getloop             ; Nein, dann zur Warteschleife
          bra       rstkeys

textout   movem.l   D1/A1,-(SP)         ; Text ausgeben
loop8     move.b    (A1)+,D1            ; Zeichen holen
          beq.s     toend               ; Wenn ASCII-Code Null, abbrechen
          bsr       chrout
          bra       loop8
toend     movem.l   (SP)+,D1/A1
          rts

* Ende Fullscreen-Editor

