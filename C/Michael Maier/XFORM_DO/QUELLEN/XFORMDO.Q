* -------------------------------------------------- *
*
*                 XFORMDO.LIB Version 1.2
*
*            geschrieben von Michael Maier 1991
*
* -------------------------------------------------- *

* -------------------------------------------------- *
* Modul: XFORMDO.Q
* Version: 1.2
* Datum: 27.9.1991
* -------------------------------------------------- *

        PATH    include   kann geÑndert werden!

**************************************************************************
*
* Include-Anweisungen
*
**************************************************************************
        include types.i
        include gem.i
        include rscobj.i
        include xobjects.i              
        include xform.i

**************************************************************************
*
* Konstanten
*
**************************************************************************
ED_INIT EQU     1
ED_CHAR EQU     2
ED_END  EQU     3

MU_KEYBD          EQU     $0001
MU_BUTTON         EQU     $0002
MU_M1             EQU     $0004
MU_WAIT           EQU     (MU_KEYBD|MU_BUTTON|MU_M1)

***************************************************************************
*
* Initialisierung:
* ----------------
* IN    A0.l    Zeiger auf Baum
*       D0.w    gewÅnschtes Objekt, daû aktiviert werden soll
*       A6.l    Basisregister
*
***************************************************************************
        LOCAL
init_xform:
        movem.l A0/D1-D4,-(SP)       Register retten

        moveq.l #0,D1               Index fÅr Baum
        moveq.l #0,D4               INDDEFAULT-Objekt
        move.w  #FAIL,gl_default(A6) kein Default
        move.w  #FAIL,ed_obj(A6)    kein EDITABLE

.search:
        lea     ob_size(A0),A0      nÑchstes Objekt
        addq.l  #1,D1               Index + 1

        move.w  ob_flags(A0),D2     Ist es Default-Objekt?
        btst    #1,D2
        beq     .nodefault          nein -> weiter
        tst.w   gl_default(A6)      Schon eins vorhanden?
        bpl     .error              ja -> Fehlermeldung ausgeben
        move.w  D1,gl_default(A6)   Nummer merken
        bra     .weiter             weitersuchen
.error:
        move.w  D0,D3               Objekt merken
        move.w  #ALERT1,D0          Meldung
        bsr     do_alert            ausgeben
        move.w  D3,D0               alter Wert
        bra     .weiter             weitersuchen

.nodefault:
        btst    #3,D2               Ist es EDITABLE?
        beq     .weiter             nein -> weiter
        move.w  ob_flags(A0),D3     Ist INDDEFAULT gesetzt?
        and.w   #INDDEFAULT,D3
        beq     .nodep              nein -> weitermachen

        move.w  D1,D4               Nummer merken

.nodep:
        
        tst.w   ed_obj(A6)          Schon eins da?
        bpl     .wunsch             ja -> Ist es der Wunsch?
        move.w  D1,ed_obj(A6)       sonst -> merken
        bra     .weiter             weitersuchen

.wunsch:
        cmp.w   D1,D0               Ist es der Wunsch?
        bne     .weiter             nein -> weitersuchen
        move.w  D0,ed_obj(A6)       sonst -> merken

.weiter:
        bsr     .structur           Struktur ok?

        and.w   #LASTOB,D2          Letztes Objekt?
        beq     .search             nein -> weitersuchen

        move.w  ed_obj(A6),D0       Objekt
        bmi     .return

        bsr     sel_edit            Objekt aktivieren

        tst.w   D4                  INDDEFAULT gefunden?
        beq     .return             nein -> zurÅck

        move.l  A5,A0               Zeiger auf Baum
        mulu    #ob_size,D4         Offset addieren
        add.l   D4,A0               Zeiger auf Objekt
        bsr     test_inddefault

.return:
        movem.l (SP)+,A0/D1-D4      Register laden
        rts

.structur:
        movem.l A0/D0/D1,-(SP)      Arbeitsregister

        move.w  ob_type(A0),D1      Typ ist...
        cmp.w   #G_CHK,D1           G_CHK?
        beq     .gettext            ja -> weiteruntersuchen
        cmp.w   #G_RB,D1            G_RB
        beq     .gettext            ja -> weiteruntersuchen
.ende:
        movem.l (SP)+,A0/D0/D1      Arbeitsregister vom Stack
        rts

.gettext:
        move.w  ob_next(A0),D0      nÑchstes Objekt
        mulu    #ob_size,D0         ermitteln
        move.l  A5,A0
        add.l   D0,A0
        move.w  ob_type(A0),D1      muû Text sein!
        cmp.w   #G_TEXT,D1          Entweder G_TEXT,
        beq     .getind
        cmp.w   #G_BOXTEXT,D1       G_BOXTEXT,
        beq     .getind
        cmp.w   #G_STRING,D1        G_STRING,
        beq     .getind
        cmp.w   #G_FTEXT,D1         G_FTEXT oder
        beq     .getind
        cmp.w   #G_FBOXTEXT,D1      G_FBOXTEXT
        beq     .getind

        move.w  #ALERT2A,D0         ansonsten: Fehlermeldung ausgeben
        cmp.w   #G_RB,D1
        bne     .showerror
        move.w  #ALERT3A,D0
.showerror:
        bsr     do_alert
        bra     .ende

.getind:
        move.w  ob_head(A0),D0      Kind ermitteln
        mulu    #ob_size,D0
        move.l  A5,A0
        add.l   D0,A0
        move.w  ob_type(A0),D1
        cmp.w   #G_IND,D1           Muû G_IND sein!
        beq     .ende

        move.w  #ALERT2B,D0         Fehlermeldung ausgeben!
        cmp.w   #G_RB,D1
        bne     .showerror
        move.w  #ALERT3B,D0
        bra     .showerror

***************************************************************************
*
* xform_do
*
* => A0.l Zeiger auf Baum
*    D0.w Nummer des EDITABLE - Objekt, das aktiviert werden soll
* <= D0.w Nummer des gewÑhlten Objektes
*
***************************************************************************
        LOCAL
        GLOBL   xform_do
xform_do:
        movem.l #CREGS,-(SP)        ; Register retten

        IFD     DR                  ; Parameter lesen
        move.l  60(SP),A0
        move.l  64(SP),A1
        move.w  68(SP),D0
        ENDIF

        lea     basis,A6            ; Basisregister
        move.l  A0,A5               ; und Baum
        move.l  A1,gl_dinfo(A6)     ;

        bsr     init_xformdo        ; Initialisieren

***
* Wo ist die Maus?
***
        move.l  #graf_mkstate,D0    ;
        bsr     aes                 ; Koordinaten holen
        move.w  gl_intout+2(A6),gl_intin+4(A6)

        move.w  #0,gl_moflags(A6)   ; Verlassen "wurde" gemeldet
        clr.w   gl_intin(A6)        ; von Anfang an
        move.w  #7,gl_intin+2(A6)   ; Tiefe 0
        move.l  A5,gl_addrin(A6)    ; Baum nicht vergessen
        move.l  #objc_find,D0       ; AES-Funktion
        bsr     aes                 ; aufrufen
        bmi     .mausdrauûen        ; jawoll!
        move.w  #1,gl_moflags(A6)   ; Betreten "wurde" gemeldet

.mausdrauûen:

        bsr     mouse_event         ; Ereignis melden

.loop:
        lea     gl_intin(A6),A1     ; Evnt_Multi vorbereiten
        move.w  #MU_WAIT,(A1)+      ;
        move.w  #$0002,(A1)+        ; max. 2 Klicks
        move.l  #$00010001,(A1)+    ; Maske und BState

        move.w  gl_moflags(A6),(A1)+ ; Verlassen melden
        move.l  ob_x(A5),(A1)+      ; Rechteck angeben
        move.l  ob_width(A5),(A1)+  ;

        add.l   #10,A1              ; + 10
        clr.l   (A1)+               ; Timer egal

        move.l  #evnt_multi,D0      ;
        bsr     aes                 ; auf Nachricht warten...

        lea     mutab(PC),A0        ; Ereigbnisse
        lea     jmptab(PC),A1       ; Sprungtabelle
        moveq   #2,D3               ; Anzahl der Funktionen

.loop2:
        move.w  D0,D1               ; Ereibnis
        move.w  (A0)+,D2            ;
        and.w   D2,D1               ; Vergleichen
        beq.s   .nojump             ;
        movem.l D0/D3/A1/A0,-(SP)   ; Register merken
        move.l  (A1),A1             ;
        jsr     (A1)                ;
        beq     .ende
        movem.l (SP)+,D0/D3/A1/A0   ; nÑchstes Ereigbis
.nojump:
        addq.l  #4,A1               ; nÑchste Adresse
        dbra    D3,.loop2           ;
        bra     .loop               ;

.ende:
        tst.w   ed_obj(A6)          ; EDITABLE-Objekt aktiv?
        bmi     .noedit             ; nein!
        bsr     edit_off            ; ausschalten

.noedit:

        lea     16(SP),SP           ; 4 Register
        movem.l (SP)+,#CREGS        ; Register laden
        rts                         ; und zurÅck

jmptab:           dc.l    klickobj,keyboard,mouse_event
mutab:            dc.w    MU_BUTTON,MU_KEYBD,MU_M1


***************************************************************************
*
* Tastaturereignis:
* -----------------
* IN    A6.l    Basisregister
*       A5.l    Zeiger auf Baum
*
***************************************************************************
        LOCAL
keyboard:
        move.w  gl_intout+10(A6),D0 Scancode
        move.w  gl_intout+8(A6),D1  Tastenstatus

        bsr     key_handler          an Key-Handler Åbergeben

        cmp.w   #FAIL,D0              Exit?
        beq     .return   nein -> nur zurÅck
        clr.l   D1                    Returncode
        rts

.return:
        moveq   #1,D1     Returncode
        rts

***************************************************************************
*
* Mausereignis: Maustaste:
* ------------------------
* IN    A6.l    Basisregister
*       A5.l    Zeiger auf Baum
*
***************************************************************************
        LOCAL
klickobj:
        move.l  gl_intout+2(A6),gl_intin+4(A6)  Position
        move.w  gl_intout+12(A6),D2         Anzahl d. Klicks
        clr.w   gl_intin(A6)                            von Anfang an
        move.w  #8,gl_intin+2(A6)           Tiefe 8
        move.l  A5,gl_addrin(A6)            Baum
        move.l  #objc_find,D0               AES-Funktion
        bsr     aes                         aufrufen
        bmi     .return                     nichts gefunden -> zurÅck

        move.w  D0,D1     Objekt
        bsr     objekt_handler  an den Objekt-Handler damit
        cmp.w   #FAIL,D0              Exit?
        beq     .return   nein -> nur zurÅck
        clr.l   D1                    Returncode
        rts

.return:
        moveq   #1,D1     Returncode
        rts

***************************************************************************
*
* Mausereignis:
* -------------
* IN    A6.l    Basisregister
*
***************************************************************************
        LOCAL
mouse_event:
        tst.w   gl_moflags(A6)      ; Betreten wurde gemeldet? 
        bne     .mouse2             ; nein -> verlassen
        move.w  #1,gl_moflags(A6)   ;
        clr.w   gl_intin(A6)                    ; Pfeil
.jjf:
        move.l  #graf_mouse,D0      ; AES-Funktion
        bsr     aes                 ;
        moveq   #1,D0               ; nicht abbrechen
        rts                         ; und zurÅck

.mouse2:
        clr.w   gl_moflags(A6)      ;
        move.w  #2,gl_intin(A6)     ; BUSYBEE
        bra     .jjf                ;

**************************************************************************
*
* Key-Handler                                                     8.6.1991
* IN    A5.l    Zeiger auf Baum
*       A6.l    Basis
*       D0.w    Scancode
*       D1.w    Tastenzustand
*
* OUT   D0.w    FAIL kein EXIT
*       D0.w    Objektnummer
*
**************************************************************************
        LOCAL

SCANHELP          EQU     98
SCANUNDO          EQU     97

key_handler:

        move.w  D0,D2               Scancode
        lsr.w   #8,D2
        cmp.w   #SCANHELP,D2                    HELP-Taste gedrÅckt?
        bne     .nohelp             nein -> weiter
        bsr     do_help             ja -> neue Kombination ermitteln
        bra     .fail               FAIL zurÅck

.nohelp:

        cmp.w   #28,D2       Return?
        bne     .noreturn
        tst.w   gl_default(A6)      Default-Button?
        bmi     .noreturn                       nein -> raus hier
        move.w  gl_default(A6),D1   Objektnummer
        bra     .obj                und zurÅck

.noreturn:

        move.w  D1,D3               SHIFT ausblenden
        and.w   #$FFFC,D3
        cmp.w   gl_aktivkom(A6),D3  Aktivierungskombination?
        bne     .nohotkey                       nein -> kein HOTKEY
        bsr     is_hotkey                       HOTKEY suchen
        bmi     .nohotkey                       nicht gefunden -> weiter

.obj:
        moveq.l #4,D2               HOTKEY-Kennzeichen
        move.w  gl_intout+8(A6),D0  Wurde die SHIFT gedrÅckt?
        and.w   #3,D0
        beq     .jumptohandler      nein -> springen
        bset    #1,D2               Doppelklick

.jumptohandler:

        bsr     objekt_handler      Handler aufrufen
        bra     .return             Ergebnis zurÅck

.nohotkey:

        tst.w   ed_obj(A6)                      Gibt es ein EDITABLE-Objekt
        bmi     .fail               nein -> FAIL zurÅck


        bsr     cursor_handler      Handler aufrufen
        bmi     .fail               Returncode == FAIL!

        cmp.w   #SCANUNDO,D2                    War es die UNDO-Taste?
        bne     .noundo             nein -> weiter
        bsr     do_undo             ja -> UNDO
        bra     .inddefault                       und FAIL zurÅck

.noundo:

        move.w  ed_obj(A6),gl_intin(A6)         Objekt
        move.w  D0,gl_intin+2(A6)           eingegebenes Zeichen
        move.w  ed_index(A6),gl_intin+4(A6)     Index
        move.w  #ED_CHAR,gl_intin+6(A6)         Zeichen verarbeiten
        move.l  A5,gl_addrin(A6)            Baum
        move.l  #objc_edit,D0               AES-Funktion
        bsr     aes                         aufrufen
        move.w  gl_intout+2(A6),ed_index(A6)    neue Position

.inddefault:

        move.l  ed_objptr(A6),A0            Zeiger auf Objekt
        move.w  ob_flags(A0),D0             Ist es
        and.w   #INDDEFAULT,D0              INDDEFAULT?
        beq     .fail                       nein -> FAIL zurÅck

test_inddefault:

        move.l  A5,A2                       Zeiger auf Default holen
        move.w  gl_default(A6),D0           Offset
        mulu    #ob_size,D0                             addieren
        add.l   D0,A2                       Zeiger auf Default-Button

        move.w  ob_state(A2),D1             Status
        bclr    #3,D1                       DISABLED aus
        move.l  ob_spec(A0),A1              Zeiger auf TEDINFO
        move.l  te_ptext(A1),A1             Zeiger auf Text
        tst.b   (A1)                        LÑnge == 0?
        bne     .disabled                               ja -> Objekt aus
        bset    #3,D1                       nein -> Objekt ein

.disabled:

        cmp.w   ob_state(A2),D1             Status verÑndert?
        beq     .fail                       nein -> FAIL zurÅck
        move.w  D1,ob_state(A2)             neuer Status
        move.w  gl_default(A6),gl_intin(A6)     Objekt
        move.w  #1,gl_intin+2(A6)           Tiefe
        clr.l   gl_intin+4(A6)              Clip-
        move.l  gl_max_w(A6),gl_intin+8(A6)     Bereich
        move.l  A5,gl_addrin(A6)            Baum
        move.l  #objc_draw,D0               AES-Funktion
        bsr     aes                         aufrufen

.fail:

        moveq.l #-1,D0                      Kennzeichnen

.return:

        rts

**************************************************************************
*
* Cursor-Handler                                                   8.6.1991
* IN    A5.l    Zeiger auf Baum
*       A6.l    Basis
*       D2.w    Scancode
*       D1.w    Tastenzustand
*
* OUT   D0.w    FAIL kein EXIT
*       D0.w    Objektnummer
*
**************************************************************************
        LOCAL

SCANUP            EQU     72
SCANDOWN          EQU     80
SCANLEFT          EQU     75
SCANRIGHT       EQU     77
SCANTAB           EQU     15
SCANENTER       EQU     114

cursor_handler:
        movem.l A0/A1/D0/D1,-(SP)   Arbeitsregister

        lea     curfuncs(PC),A0     Zeiger auf Tabellen
        lea     curkeys(PC),A1
        and.w   #$0003,D1                       Shifttaste?
        beq     .noshift                        nein
        lea     shcurfuncs(PC),A0   Funktiontabelle
        lea     shcurkeys(PC),A1    Tastentabelle

.noshift:

        moveq.l #3,D0               4 Funktionen

.loop:
        cmp.b   (A1)+,D2                        Scancode gleich?
        bne     .nojump             nein
        move.l  (A0),A0             Adresse holen
        jsr     (A0)                Funktion aufrufen
        moveq.l #-1,D0              keine weitere Untersuchung!

        movem.l (SP)+,A0/A1/D0/D1   Arbeitsregister
        rts

.nojump:
        addq.l  #4,A0               nÑchste Adresse
        dbra    D0,.loop                        Schleife
        moveq.l #0,D0               nichts gefunden!

        movem.l (SP)+,A0/A1/D0/D1   Arbeitsregister
        rts

curkeys:          dc.b    SCANUP,SCANDOWN,SCANTAB,SCANENTER
shcurkeys:      dc.b    SCANUP,SCANDOWN,SCANLEFT,SCANRIGHT

curfuncs:       dc.l    prev_edit,next_edit,next_edit,next_edit
shcurfuncs:     dc.l    first_edit,last_edit,left_edit,right_edit

***************************************************************************
*
* aktives EDITABLE-Objekt ausschalten
* IN    A5.l    Zeiger auf Baum
*       A6.l    Basisregister
*
***************************************************************************
        LOCAL
edit_off:
        move.l  D0,-(SP)                                ; Arbeitsregister
        move.w  ed_obj(A6),gl_intin(A6)         ; Objektnummer
        clr.w   gl_intin+2(A6)              ; kein Zeichen
        move.w  ed_index(A6),gl_intin+4(A6)     ; Index
        move.w  #ED_END,gl_intin+6(A6)                  ; Befehl
        move.l  A5,gl_addrin(A6)            ; Baum
        move.l  #objc_edit,D0               ; AES-Funktion
        bsr     aes                         ; ausrufen
        move.l  (SP)+,D0                                ;
        rts                                 ; und zurÅck

***************************************************************************
*
* aktives EDITABLE-Objekt einschalten
* IN    A5.l    Zeiger auf Baum
*       A6.l    Basisregister
*
***************************************************************************
        LOCAL
edit_on:
        move.l  D0,-(SP)                                ; Arbeitsregister
        move.w  ed_obj(A6),gl_intin(A6)         ; Objektnummer
        clr.w   gl_intin+2(A6)              ; kein Zeichen
        move.w  ed_index(A6),gl_intin+4(A6)     ; Index
        move.w  #ED_INIT,gl_intin+6(A6)         ; Befehl
        move.l  A5,gl_addrin(A6)            ; Baum
        move.l  #objc_edit,D0               ; AES-Funktion
        bsr     aes                         ; ausrufen
        move.w  gl_intout+2(A6),ed_index(A6)    ; neuer Index



        move.l  (SP)+,D0                                ;
        rts                                 ; und zurÅck
       
***************************************************************************
*
* EDITABLE-Objekt aktivieren
* IN    A5.l    Zeiger auf Baum
*       A6.l    Basisregister
*       D0.w    Objektnummer
*
***************************************************************************
        LOCAL
sel_edit:
        movem.l A0/A1,-(SP)                     Arbeitsregister
        move.w  D0,ed_obj(A6)       Nummer merken
        move.l  A5,A0               Zeiger ermitteln
        mulu    #ob_size,D0
        add.l   D0,A0
        move.l  A0,ed_objptr(A6)

        move.l  ob_spec(A0),A0      Zeiger auf TEDINFO
        move.l  te_ptext(A0),A0     Zeiger auf Text
        lea     gl_undobuff(A6),A1  Undobuffer == Ziel

.loop:
        move.b  (A0)+,(A1)+                     Zeichen fÅr Zeichen
        bne     .loop               bis Ende

        bsr     edit_on             Objekt einschalten

        movem.l (SP)+,A0/A1                     Register laden
        rts                         

***************************************************************************
*
* 1. EDITABLE-Objekt suchen und aktivieren:
* -----------------------------------------
* IN    A5.l    Zeiger auf Baum
*       A6.l    Basisregister
*
***************************************************************************
        LOCAL
first_edit:
        movem.l A0/D0-D1,-(SP)  Arbeitsregister retten

        move.l  A5,A0     Baum
        moveq.l #0,D0     Index

.search:
        lea     ob_size(A0),A0  nÑchstes Objekt
        addq.l  #1,D0     Index + 1
        move.w  ob_flags(A0),D1 Flags untersuchen
        btst    #3,D1     EDITABLE?
        beq     .last     nein -> nichts machen
        bsr     edit_off              Objekt ausschalten
        bsr     sel_edit              Objekt aktivieren
        bra     .ende     und fertig
.last:
        and.w   #LASTOB,D1            letztes Objekt?
        beq     .search   nein -> weitersuchen

.ende:
        movem.l (SP)+,A0/D0-D1  Register vom Stack
        rts


***************************************************************************
*
* l. EDITABLE-Objekt suchen und aktivieren:
* -----------------------------------------
* IN    A5.l    Zeiger auf Baum
*       A6.l    Basisregister
*
***************************************************************************
        LOCAL
last_edit:
        movem.l A0/D0-D2,-(SP)  Arbeitsregister retten

        move.l  A5,A0     Baum
        moveq.l #0,D0     Index

.search:
        lea     ob_size(A0),A0  nÑchstes Objekt
        addq.l  #1,D0     Index + 1
        move.w  ob_flags(A0),D1 Flags untersuchen
        btst    #3,D1     EDITABLE?
        beq     .last     nein -> nichts machen
        move.w  D0,D2     nur merken!

.last:
        and.w   #LASTOB,D1            letztes Objekt?
        beq     .search   nein -> weitersuchen

        move.w  D2,D0     letztes Objekt
        bsr     edit_off              Objekt ausschalten
        bsr     sel_edit              Objekt aktivieren

        movem.l (SP)+,A0/D0-D2  Register vom Stack
        rts

***************************************************************************
*
* nÑchstes EDITABLE-Objekt suchen und aktivieren:
* -----------------------------------------------
* IN    A5.l    Zeiger auf Baum
*       A6.l    Basisregister
*
***************************************************************************
        LOCAL
next_edit:
        movem.l A0/D0-D2,-(SP)  Arbeitsregister retten

        move.l  ed_objptr(A6),A0
        move.w  ed_obj(A6),D0

.search:
        lea     ob_size(A0),A0  nÑchstes Objekt
        addq.l  #1,D0     Index + 1
        move.w  ob_flags(A0),D1 Flags untersuchen
        btst    #3,D1     EDITABLE?
        beq     .last     nein -> nichts machen
        bsr     edit_off              Objekt ausschalten
        bsr     sel_edit              Objekt aktivieren 
        bra     .ende     und fertig
.last:
        and.w   #LASTOB,D1            letztes Objekt?
        beq     .search   nein -> weitersuchen

.ende:
        movem.l (SP)+,A0/D0-D2  Register vom Stack
        rts

***************************************************************************
*
* vorheriges EDITABLE-Objekt suchen und aktivieren:
* -------------------------------------------------
* IN    A5.l    Zeiger auf Baum
*       A6.l    Basisregister
*
***************************************************************************
        LOCAL
prev_edit:
        movem.l A0/D0-D2,-(SP)  Arbeitsregister retten

        move.l  ed_objptr(A6),A0
        move.w  ed_obj(A6),D0

.search:
        lea     -ob_size(A0),A0 nÑchstes Objekt
        subq.l  #1,D0     Index + 1
        beq     .ende     nicht gefunden -> zurÅck
        move.w  ob_flags(A0),D1 Flags untersuchen
        btst    #3,D1     EDITABLE?
        beq     .search    nein -> nichts machen

        bsr     edit_off              Objekt ausschalten
        bsr     sel_edit              Objekt aktivieren 

.ende:
        movem.l (SP)+,A0/D0-D2  Register vom Stack
        rts

***************************************************************************
*
* Cursor ans Ende bewegen:
* ------------------------
* IN    A5.l    Zeiger auf Baum
*       A6.l    Basisregister
*
***************************************************************************
        LOCAL
right_edit:
        bsr     edit_off              Objekt ausschalten
        bsr     edit_on   Objekt einschalten
        rts
        
***************************************************************************
*
* Cursor zum Anfang spring:
* -------------------------
* IN    A5.l    Zeiger auf Baum
*       A6.l    Basisregister
*
***************************************************************************
        LOCAL
left_edit:
        bsr     edit_off                        Objekt ausschalten
        move.l  ed_objptr(A6),A0    Zeiger auf Objekt
        move.l  ob_spec(A0),A0      Zeiger auf TEDINFO
        move.l  te_ptext(A0),A0     Zeiger auf Text
        move.b  (A0),D0             Zeichen merken
        clr.b   (A0)                Ende markieren
        bsr     edit_on             Objekt einschalten
        move.b  D0,(A0)             altes Zeichen
        rts

***************************************************************************
*
* HOTKEY suchen
* -------------
* IN    A5.l    Zeiger auf Baum
*       A6.l    Basisregister
*       D0.w    Eingabe
*       D2.w    Scancode
*       D1.w    Tastenstatus
* OUT   D1.w    Objektnummer oder CC MI fÅr nicht gefunden!
*
***************************************************************************
        LOCAL

SCANRET EQU 28

is_hotkey:
        movem.l  D0/D2/D3/A0/A1,-(SP)           Arbeitsregister

        bsr     get_ascii                       nach ASCII wandeln

        move.l  A5,A0               Zeiger auf Baum
        moveq   #0,D0               Index

.search:
        lea     ob_size(A0),A0      nÑchstes Objekt
        addq.l  #1,D0               Index + 1

        move.w  ob_type(A0),D3      Typ untersuchen
        cmp.w   #G_HOTKEY,D3                    normaler HOTKEY?
        beq     .gethotkey                      ja -> testen
        cmp.w   #G_CHK,D3                       CHECKBOX?
        beq     .getcheck                       ja -> testen
        cmp.w   #G_RB,D3                        RUNDERBUTTON
        beq     .getcheck                       ja -> testen

.weiter:

        move.w  ob_flags(A0),D3
        and.w   #LASTOB,D3                      letztes Objekt?
        beq     .search             nein -> weitersuchen
        moveq.l #-1,D0              Conditioncode MI setzen
        bra     .ende

***
* HOTKEY gefunden
***
.gethotkey:
        cmp.w   ob_height(A0),D2    Zeichen gleich?
        bne     .weiter             nein -> weitersuchen

        move.w  ob_next(A0),D1      Index
        bra     .ende

***
* CHECKBOX gefunden
***
.getcheck:
        move.w  ob_next(A0),D3      nÑchstes Objekt
        bsr     .getpointer                     Zeiger ermitteln

        move.w  ob_head(A1),D3      G_INDHOTKEY
        bsr     .getpointer                     Zeiger ermitteln
        cmp.w   ob_height(A1),D2    Zeichen gleich?
        bne     .weiter             nein -> weitersuchen
        move.w  D0,D1               gefunden

.ende:

        movem.l (SP)+,A0/A1/D0/D2/D3            Register vom Stack
        rts

.getpointer:
        move.l  A5,A1               Zeiger auf Baum
        mulu    #ob_size,D3                     Offset
        add.l   D3,A1               addieren
        rts

***************************************************************************
*
* Scancode umwandeln:
* -------------------
* IN    D0.w  Scancode
*       D1.w    Tastaturzustand
* OUT   D0.b  Asciiwert (geshiftet)
*
***************************************************************************
        LOCAL
get_ascii:
        move.w  D0,D2               ;

        tst.w   D1                              ; SHIFT usw ?
        beq.s   .shiften                        ; nein

        lsr.w   #8,D2               ; nur den SCANCODE 
        cmp.w   #120,D2             ; Scancode zwischen
        blt     .nooffset                       ; 120 und 131?
        cmp.w   #131,D2             ;
        bgt     .nooffset                       ;
        sub.w   #118,D2             ; ja -> 118 abziehen

.nooffset:

        move.w  D1,D0               ; SHIFT-Belegung
        clr.w   D3                              ; OFFSET lîschen
        and.w   #3,D0               ; SHIFT gedrÅckt?
        beq     .noshft             ; nein
        moveq   #4,D3               ; OFFSET

.noshft:

        move.l  gl_keytab(A6),A0    ; Umwandlungstabelle
        move.l  0(A0,D3.w),A0       ;
        move.b  0(A0,D2.w),D2       ; Buchstabe

.shiften:
        and.w   #$00FF,D2                       ;
        cmp.w   #'a',D2             ; SHIFTEN
        blt     .noshift                        ;
        cmp.w   #'z',D2             ;
        bgt     .umlaute                        ;
        sub.b   #32,D2              ;
.noshift:
        rts                         ; und zurÅck

.umlaute:
        lea     .umliste,A0                     ; Test auf ÑîÅ
        moveq   #2,D0               ; 3 Zeichen
.loop:
        cmp.b   (A0),D2             ; gefunden?
        beq     .shift              ; ja -> Zeichen holen
        addq    #2,A0               ; nein -> nÑchstes Paar
        dbra    D0,.loop                        ; nur 3 mal
        bra     .noshift                        ;
.shift:
        move.b  1(A0),D2                        ; Letter
        bra     .noshift                        ; und zurÅck

.umliste:       dc.b    "ÑéîôÅö"

**************************************************************************
*
* Objekt-Handler                                        7.6.1991
* IN    A5.l    Zeiger auf Baum
*       A6.l    Basis
*       D1.w    Objektnummer
*       D2.w    Bit 3: HOTKEY, sonst Anzahl der Klicks
*
* OUT   D0.w    FAIL kein EXIT
*       D0.w    Objektnummer
*
**************************************************************************
        LOCAL
objekt_handler:
        movem.l D1-D6/A0/A1,-(SP)   Arbeitsregister

        move.l  A5,A0               Zeiger auf Objekt ermitteln
        move.w  D1,D0               Nummer
        mulu    #ob_size,D0                     mal LÑnge
        add.l   D0,A0               = Offset

        move.w  ob_flags(A0),D3     ob_flags
        move.w  ob_state(A0),D4     ob_state

        btst    #3,D3               EDITABLE?
        beq     .noedit             nein -> weiter
        bsr     edit_off                        altes Objekt ausschalten
        move.w  D1,D0               Objektnummer
        bsr     sel_edit                        Objekt aktivieren
        bra     .fail               FAIL zurÅck

.noedit:

        btst    #3,D4               Ist DISABLED gesetzt?
        bne     .fail               ja -> FAIL zurÅck

        move.w  ob_type(A0),D0      Ist es das FLY-Objekt?
        cmp.w   #G_FLY,D0
        bne     .nofly              nein -> weiter
        bsr     do_fly              sonst fliegen
        bra     .fail               und FAIL zurÅck

.nofly:

        btst    #6,D3               Ist TOUCHEXIT gesetzt?
        bne     .objekt             ja -> Objekt zurÅck

        btst    #0,D3               Ist SELECTABLE gesetzt?
        beq     .fail               nein -> FAIL zurÅck

        btst    #4,D3               Ist RBUTTON gesetzt?
        beq     .noradio1                       nein -> weiter
        btst    #0,D4               Ist SELECTED gesetzt?
        bne     .fail               ja -> FAIL zurÅck

.noradio1:

        bchg    #0,D4               Bit kippen

        btst    #2,D2               HOTKEY-Ereignis?
        beq     .graf_watchbox      nein -> Maus
        
        move.w  D4,ob_state(A0)     eintragen
        move.w  D1,D6               Objektnummer muû hier stehen
        bsr     .show_objekt                    Objekt zeichnen
        bra     .weiter             und weiter...

.graf_watchbox:

        move.w  D1,gl_intin+2(A6)   Objekt
        move.w  D4,gl_intin+4(A6)   gr_winstate
        move.w  ob_state(A0),gl_intin+6(A6) gr_woutstate
        move.l  A5,gl_addrin(A6)    Baum
        move.l  #graf_watchbox,D0   AES-Funktion
        bsr     aes                 aufrufen

        beq     .fail               nichts passiert

        move.w  ob_state(A0),D4     neuer Status...

.weiter:

        btst    #0,D4               Ist SELECTED gesetzt?
        beq     .fail               nein -> FAIL zurÅck

        btst    #4,D3               Ist es ein RADIO?
        beq     .noradio2                       nein -> weiter
        bsr     .do_radio                       ja -> andere Radios ausschalten

.noradio2:

        btst    #2,D3               Ist EXIT gesetzt?
        beq     .fail               nein -> FAIL zurÅck

.objekt:

        move.w  D1,D0               Objektnummer
        btst    #1,D2               Doppelklick?
        beq     .nobit              nein -> kein 15. Bit setzten
        or.w    #$8000,D0                       ja -> 15. Bit setzen

.nobit:

        movem.l (SP)+,D1-D6/A0-A1   Arbeitsregister vom Stack
        rts

.fail:
        move.w  #FAIL,D0                        Fail zurÅck
        bra     .nobit

* --- Unterfunktion: Radioschalter ausschalten ----

.do_radio:
        move.l  A0,A1               Kopie
        move.w  D1,D6

.search:

        move.w  D6,D5               letzten Sohn merken

        move.w  ob_next(A1),D0      nÑchsten Sohn

.getson:

        move.w  D0,D6               merken
        mulu    #ob_size,D0                     Offset
        move.l  A5,A1               Baum
        add.l   D0,A1               Zeiger auf Objekt
        
        cmp.w   ob_tail(A1),D5      Zeigt Objekt auf letzten Sohn?
        bne     .nofather                       nein -> kein Vater
        move.w  ob_head(A1),D0      Zeiger auf 1. Kind
        move.w  D6,D5               Vater
        bra     .getson             Sohn holen 

.nofather:

        cmp.w   D6,D1               Objekt gefunden?
        beq     .return             ja -> Abbruch
        move.w  ob_state(A1),D0     Status
        btst    #0,D0               SELECTED?
        beq     .search             nein -> weitersuchen
        bclr    #0,D0               
        move.w  D0,ob_state(A1)     Speichern

.show_objekt:

        move.w  D6,gl_intin(A6)     Objekt
        move.w  #1,gl_intin+2(A6)   Tiefe
        clr.l   gl_intin+4(A6)      Clip
        move.l  gl_max_w(A6),gl_intin+8(A6)
        move.l  A5,gl_addrin(A6)    Baum
        move.l  #objc_draw,D0       AES-Funktion
        bsr     aes                 Aufrufen

.return:

        rts

**************************************************************************
*
* Fehlermeldung ausgeben
* => D0.w Fehlernummer
*
**************************************************************************
        LOCAL
        GLOBL   do_alert
do_alert:
        move.w  #$0005,gl_intin(A6)         ; String suchen
        move.w  D0,gl_intin+2(A6)           ; Index
        move.l  #rsrc_gaddr,D0              ; AES-Funktion
        bsr     aes                         ; suchen
        move.l  gl_addrout(A6),gl_addrin(A6)    ; Adresse
        move.w  #$0001,gl_intin(A6)         ; 1. Schalter
        move.l  #form_alert,D0              ; AES-Funktion
        bsr     aes                         ; ausgeben
        rts                                 ; und zurÅck

**************************************************************************
*
* Aktivierungstaste verÑndern...
*
**************************************************************************
        LOCAL
do_help:
        move.w  #$0005,gl_intin(A6)         ; String suchen
        move.w  #HELP,gl_intin+2(A6)                    ; Index
        move.l  #rsrc_gaddr,D0              ;
        bsr     aes                         ; suchen
        move.l  gl_addrout(A6),gl_addrin(A6)    ;
        move.w  #$0001,gl_intin(A6)         ; 1. Schalter
        move.l  #form_alert,D0              ;
        bsr     aes                         ; ausgeben

        clr.w   gl_aktivkom(A6)             ;
        cmp.w   #$0001,D0                               ; ALT?
        bne.w   .contrl                     ; nein -> keine
        move.w  #$0008,gl_aktivkom(A6)                  ;
        bra     .ende                       ;

.contrl:
        cmp.w   #$0002,D0                       ; Control?
        bne.w   .ende               ; nein -> keine
        move.w  #$0004,gl_aktivkom(A6)          ;

.ende:
        rts                         ; und zurÅck

***************************************************************************
*
* UNDO-Taste wurde gedrÅckt...
* ----------------------------
* IN    A5.l    Zeiger auf Baum
*       A6.l    Basis
*
***************************************************************************
        LOCAL
do_undo:
        move.l  ed_objptr(A6),A1    ; Zeiger auf Objekt ermitteln
        move.l  ob_spec(A1),A1      ;
        move.l  te_ptext(A1),A1     ; Zeiger auf Text...

        bsr     edit_off                        ; Objekt ausschalten

        lea     gl_undobuff(A6),A0  ; Quelle
.loop:
        move.b  (A0)+,(A1)+                     ; Zeichen
        bne.s   .loop               ; bis Ende

        move.w  ed_obj(A6),gl_intin(A6) ;
        move.w  #1,gl_intin+2(A6)   ; Tiefe
        move.l  ob_x(A5),gl_intin+4(A6) ; Clip-
        move.l  ob_width(A5),gl_intin+8(A6) ; Bereich
        move.l  #objc_draw,D0       ;
        move.l  A5,gl_addrin(A6)    ; Baum
        bsr     aes                 ;

        bsr     edit_on             ; Objekt einschalten
        rts                         ; und zurÅck


**************************************************************************
*
* Dialogbox fliegen lassen...
* ---------------------------
* IN    A5.l    Zeiger auf Baum
*       A6.l    Basis
*
**************************************************************************K
        LOCAL
do_fly:
        movem.l A1-A5,-(SP)                     ; Arbeitsregister retten

        move.w  #256,gl_intin(A6)   ;
        move.l  #graf_mouse,D0      ;
        bsr     aes                 ; Maus aus

        clr.w   gl_intin(A6)                            ; Clippen aus
        move.l  #$00810002,gl_contrl(A6)        ;
        move.l  #$00000001,gl_contrl+4(A6)      ;
        clr.w    gl_contrl+8(A6)            ;
        bsr     vdi                         ; vs_clip

        link    A4,#-2*fd_size      ; Lokaler Speicher
        lea     fd_size(SP),A3      ; Quelle ist Bildschirm
        clr.l   fd_addr(A3)                     ;

        move.l  SP,A2               ; Ziel fÅr Maske

        move.l  gl_dinfo(A6),A1     ;
        move.l  di_length(A1),D7    ;
        movem.l A1-A6,-(SP)                     ; Arbeitsregister retten
        move.l  #-1,-(SP)                       ; Wieviel ist frei?
        move.w  #$48,-(SP)                      ; Malloc()
        trap    #GEMDOS             ;

        sub.l   D7,D0               ; - LÑnge
        sub.l   #8*1024,D0                      ; - 8k fÅrs OS
        bmi     .error              ;

        move.l  D7,2(SP)                        ; Speicher allozieren
        trap    #GEMDOS             ; Malloc
        bra     .gÑhn               ;

.error:
        clr.l   D0                              ; Fehler markieren
.gÑhn:
        addq.l  #6,SP               ;
        movem.l (SP)+,A1-A6                     ;
        move.l  D0,fd_addr(A2)      ; Adresse merken
        beq     .konventionelle     ; = 0? ja -> Dialog aufbauen

        move.l  fd_w(A1),fd_w(A2)           ; Parameter bleiben gleich!
        move.l  fd_wdwidth(A1),fd_wdwidth(A2)   ;
        move.w  fd_nplanes(A1),fd_nplanes(A2)   ; Ebene

        move.l  ob_x(A5),D0                     ;
        sub.l   #$00030003,D0       ;
        move.l  D0,gl_ptsin(A6)     ; 1. Punkt der Quelle
        add.l   ob_width(A5),D0     ;
        add.l   #$00050005,D0       ;
        move.l  D0,gl_ptsin+4(A6)   ; 2. Punkt der Quelle
        clr.l   gl_ptsin+8(A6)      ; 1. Punkt des Ziels
        move.l  ob_width(A5),D0     ;
        add.l   #$00050005,D0       ;
        move.l  D0,gl_ptsin+12(A6)  ; 2. Punkt des Ziels
        move.w  #$0003,gl_intin(A6) ; E = Q
        move.l  A3,gl_contrl+14(A6) ; Quelle = Bildschirm
        move.l  A2,gl_contrl+18(A6) ; Ziel = Maske
        bsr     vro_cpyfm                       ; Bereich kopieren

.konventionell:
        clr.l   gl_ptsin(A6)                    ; 1. Punkt der Quelle
        move.l  ob_width(A5),D0     ;
        add.l   #$00050005,D0       ;
        move.l  D0,gl_ptsin+4(A6)   ; 2. Punkt der Quelle
        move.l  ob_x(A5),D0                     ;
        sub.l   #$00030003,D0       ;
        move.l  D0,gl_ptsin+8(A6)   ; 1. Punkt des Ziels
        add.l   ob_width(A5),D0     ;
        add.l   #$00050005,D0       ;
        move.l  D0,gl_ptsin+12(A6)  ; 2. Punkt des Ziels

        move.w  #$0003,gl_intin(A6) ; E = Q
        move.l  A1,gl_contrl+14(A6) ; Quelle = Hintergrund
        move.l  A3,gl_contrl+18(A6) ; Ziel = Bildschirm
        bsr     vro_cpyfm                       ; Bereich kopieren

        move.w  #257,gl_intin(A6)   ;
        move.l  #graf_mouse,D0      ;
        bsr     aes                 ; Maus ein!
        move.w  #$0004,gl_intin(A6) ; Hand
        move.l  #graf_mouse,D0      ;
        bsr     aes                 ;

        move.l  ob_width(A5),D0     ;
        add.l   #$00050005,D0       ;
        move.l  D0,gl_intin(A6)     ; Maûe des Rechtecks
        move.l  ob_x(A5),D0                     ;
        sub.l   #$00030003,D0       ;
        move.l  D0,gl_intin+4(A6)   ; Anfangskoordinaten
        move.l  #$00060006,gl_intin+8(A6)        ;
        move.l  gl_max_w(A6),D0     ;
        sub.l   #$00050005,D0       ;
        move.l  D0,gl_intin+12(A6)  ; Bildschirm
        move.l  #graf_dragbox,D0    ;
        bsr     aes                 ;

        clr.w   gl_intin(A6)                    ; Wieder Pfeil!
        move.l  #graf_mouse,D0      ;
        bsr     aes                 ;

        beq     .error1                     ; Fehler -> nichts machen
        move.l  gl_intout+2(A6),ob_x(A5)        ; neue Koordinaten

.error1:
        move.w  #256,gl_intin(A6)   ;
        move.l  #graf_mouse,D0      ;
        bsr     aes                 ; Maus aus!

        move.l  ob_x(A5),D0                     ;
        sub.l   #$00030003,D0       ;
        move.l  D0,gl_ptsin(A6)     ; 1. Punkt der Quelle
        add.l   ob_width(A5),D0     ;
        add.l   #$00050005,D0       ;
        move.l  D0,gl_ptsin+4(A6)   ; 2. Punkt der Quelle
        clr.l   gl_ptsin+8(A6)      ; 1. Punkt des Ziels
        move.l  ob_width(A5),D0     ;
        add.l   #$00050005,D0       ;
        move.l  D0,gl_ptsin+12(A6)  ; 2. Punkt des Ziels
        move.w  #$0003,gl_intin(A6) ; E = Q
        move.l  A3,gl_contrl+14(A6) ; Quelle = Bildschirm
        move.l  A1,gl_contrl+18(A6) ; Ziel = Hintergrund
        bsr     vro_cpyfm                       ; Bereich kopieren

        tst.l   fd_addr(A2)                     ; Konnte Vordergrund kopiert werden?
        beq     .no                 ; nein -> normal aufbauen

        clr.l   gl_ptsin(A6)                    ; 1. Punkt der Quelle
        move.l  ob_width(A5),D0     ;
        add.l   #$00050005,D0       ;
        move.l  D0,gl_ptsin+4(A6)   ; 2. Punkt der Quelle
        move.l  ob_x(A5),D0                     ;
        sub.l   #$00030003,D0       ;
        move.l  D0,gl_ptsin+8(A6)   ; 1. Punkt des Ziels
        add.l   ob_width(A5),D0     ;
        add.l   #$00050005,D0       ;
        move.l  D0,gl_ptsin+12(A6)  ; 2. Punkt des Ziels

        move.w  #$0003,gl_intin(A6) ; E = Q
        move.l  A2,gl_contrl+14(A6) ; Quelle = Hintergrund
        move.l  A3,gl_contrl+18(A6) ; Ziel = Bildschirm
        bsr     vro_cpyfm                       ; Bereich kopieren

        move.w  #257,gl_intin(A6)   ;
        move.l  #graf_mouse,D0      ;
        bsr     aes                 ; Maus ein!
        bra     .ende               ; und zurÅck

.no:
        move.w  #257,gl_intin(A6)      ;
        move.l  #graf_mouse,D0      ;
        bsr     aes                 ; Maus ein!

        tst.w   ed_obj(A6)                      ; EDITABLE Objekt aktiv?
        bmi     .noedits                        ;
        bsr     edit_off                        ;

.noedits:
        clr.w   gl_intin(A6)                    ; Start beim 1. Objekt
        move.w  #$0008,gl_intin+2(A6)           ; Tiefe
        clr.l   gl_intin+4(A6)      ;
        move.l  gl_max_w(A6),gl_intin+8(A6)           ;
        move.l  A5,gl_addrin(A6)    ; Zeiger auf Baum
        move.l  #objc_draw,D0       ;
        bsr     aes                 ; und zeichnen

        tst.w   ed_obj(A6)                      ;
        bmi     .ende               ;
        bsr     edit_on             ;

.ende:
        unlk    A4                              ; lokaler Bereich
        movem.l (SP)+,A1-A5                     ; Register
        rts                         ; und zurÅck

vro_cpyfm:
        move.l  #$006D0004,gl_contrl(A6)       ; Contrl-Werte...
        move.l  #$00000001,gl_contrl+4(A6)     ;
        clr.w   gl_contrl+8(A6)            ;
        bra     vdi                 ; und aufrufen

;
; AES-Aufrufe
;
evnt_multi      EQU     $19100701
objc_draw       EQU     $2A060101
objc_find       EQU     $2B040101
graf_mkstate    EQU     $4F000500
objc_edit       EQU     $2E040201
rsrc_gaddr      EQU     $70020100
form_alert      EQU     $34010101
graf_mouse      EQU     $4E010101
graf_dragbox    EQU     $47080300
graf_watchbox   EQU     $4B040101
        END

