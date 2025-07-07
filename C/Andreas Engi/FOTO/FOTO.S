*---------------------------------------------------------------*
*---------------------------------------------------------------*
* Dieses Programm wird in den Auto-Folder gestellt.             *
*    Wird beim Bootvorgang die Frage mit 'J' oder 'j' be-       *
*    antwortet, so wird das Programm aktiviert.                 *
*                                                               *
* CTRL-F speichert den aktuellen Bildschirm in eine zweite      *
*    Speicherseite. Dabei ist es voellig egal ob man sich in    *
*    einem Programm, auf dem Desktop oder unter TOS-Kontrolle   *
*    befindet                                                   *
* CTRL-A schaltet zwischen Arbeitsbildschirm und 'fotografier-  *
*    tem Bild um. Einmal im FOTOschirm sorgt das Betaetigen     *
*    einer beliebigen Taste fuer eine Rueckkehr auf den         *
*    Anwendungsbildschirm.                                      *
* ************************************************************* *
*   (c)  0586 ct/glasi                                          *
* ************************************************************* *
*---------------------------------------------------------------*

*---------------------------------------------------------------*
*                       GEMDOS                                  *
*---------------------------------------------------------------*
PRTS    EQU     $09             * Print String
KEEP    EQU     $31             * Terminieren und resident halten
GEMDOS  EQU     1               * Trap #1
*---------------------------------------------------------------*
*                       XBIOS                                   *
*---------------------------------------------------------------*
PBASE   EQU     2               * Bildschirmbasis
SETSCR  EQU     5               * Neue Bildschirmbasis
XBIOS   EQU     14              * Trap #14
*---------------------------------------------------------------*
*                       BIOS                                    *
*---------------------------------------------------------------*
CONIN   EQU      2              * Zeichen einlesen
CON     EQU      2              * Konsole
SETEXP  EQU      5              * Interruptvektor festst./aendern
BIOS    EQU     13              * Trap #13
*---------------------------------------------------------------*
*                       Symbole                                 *
*---------------------------------------------------------------*
SSIZE   EQU     $8000/4         * Bildschirmspeicher
BILD    EQU     32000/4         * aktuelle Bildgroesse
T13V    EQU     45              * Vectornummer fuer Bios

DISKEY  EQU     1               * CTRL-A FOTO anzeigen
FOTKEY  EQU     6               * CTRL-F Schirm fotgrafieren
SAVPTR  EQU     $4A2            * Supervisor Savearea
        TEXT
*---------------------------------------------------------------*
*   Programmgroesse feststellen                                 *
*---------------------------------------------------------------*
INIT    MOVE.L  4(SP),A0        * Programmbeginn
        MOVE.L  #$100,D6        * + Basepage
        ADD.L   12(A0),D6       * + Programmlaenge
        ADD.L   20(A0),D6       * + DATA
        ADD.L   28(A0),D6       * + BSS  = Gesamtspeicher
*---------------------------------------------------------------*
*   TEST, ob bereits resident                                   *
*---------------------------------------------------------------*
CHECK   MOVE.L  #-1,-(SP)       * BIOS Vektor holen
        MOVE    #T13V,-(SP)     * Vektor Nr 45
        MOVE    #SETEXP,-(SP)
        TRAP    #BIOS
        ADDQ.L  #8,SP
        MOVE.L  D0,A0           * Adressierbar machen
        CMP.L   #$12344321,2(A0)
        BEQ.S   RTERM           * BEREITS RESIDENT
*---------------------------------------------------------------*
*   Frage, ob Resident halten                                   *
*---------------------------------------------------------------*
ASK     LEA     AMSG(PC),A0     * Meldung --> A0
        BSR     PMSG(PC)        * Ausgeben
        BSR.S   YN(PC)          * Auf 'J' oder 'N' warten
        BNE.S   TERM0           * wenn nein, ende
*---------------------------------------------------------------*
*      Primaer- und FOTOschirm festlegen                        *
*---------------------------------------------------------------*
GETSCR1 MOVE.L  #-1,-(SP)       * aktuelle Bildadresse
        MOVE    #PBASE,-(SP)    * per physbase() Aufruf
        TRAP    #XBIOS          * feststellen
        ADDQ.L  #6,SP
        MOVE.L  D0,SCR1         * und retten
SETSCR2 MOVE.L  #SCREEN,D0      * Anfang fuer FOTOschirm auf
        ADD.L   #$100,D0        * Seitenanfang legen
        AND.L   #$FFFFFF00,D0   *
        MOVE.L  D0,SCR2
*---------------------------------------------------------------*
*   Consolvektor errechnen und Bios-Vektor umlenken             *
*---------------------------------------------------------------*
SETVEC  MOVE.L  #T13NEW,-(SP)   * Neuer Vektor
        MOVE    #T13V,-(SP)     * Vektor Nr 45
        MOVE    #SETEXP,-(SP)   * umlenken
        TRAP    #BIOS
        ADDQ.L  #8,SP
        MOVE.L  D0,TSAVE        * alten Vektor retten
        MOVE.L  D0,A0           * Consoleadresse errechnen
        ADD     2(A0),A0        * Beginn der Biostabelle
        ADD     #12,A0          * + 12 = CONIN
        MOVE.L  (A0),CONSOLE    * Adresse ablegen
*---------------------------------------------------------------*
*       Programm beenden und resident halten                    *
*---------------------------------------------------------------*
TERM    CLR     -(SP)           * Nullwort (muss sein)
        MOVE.L  D6,-(SP)        * Programmgroesse
        MOVE    #KEEP,-(SP)     * an TOS weitermelden
        TRAP    #GEMDOS
*---------------------------------------------------------------*
*       Programm beenden und entfernen                          *
*---------------------------------------------------------------*
RTERM   LEA     RMSG(PC),A0     * Meldung ausgeben
        BSR.S   PMSG(PC)
TERM0   CLR.L   (SP)            * Terminieren
        MOVE    #0,-(SP)
        TRAP    #GEMDOS
*---------------------------------------------------------------*
*       Ein Zeichen lesen, wenn 'J' oder 'j' --> D0 = 0         *
*---------------------------------------------------------------*
YN:     MOVE.W  #1,-(SP)        * CONIN
        TRAP    #GEMDOS
        ADDQ.L  #2,SP
        OR      #$20,D0
        CMP.B   #'j',D0         * ist es 'J'
        BNE.S   NO
YES:    CLR.W   D0              * NULL zurueckgeben
NO:     RTS
*---------------------------------------------------------------*
*       Meldung auf der Konsole ausgeben, String in A0          *
*---------------------------------------------------------------*
PMSG    MOVE.L  A0,-(SP)
        MOVE    #9,-(SP)
        TRAP    #GEMDOS
        ADDQ.L  #6,SP
        RTS
*---------------------------------------------------------------*
*   Die neue BIOS Routine                                       *
*                                                               *
* Mit der Kennung $12344321 hat es eine besondere Bewandnis:    *
*    Das Programm selbst prueft mit Hilfe der Kennung, ob es    *
*    bereits geladen wurde (Siehe CHECK).                       *
*    Des weiteren kann ein anderes Programm nach der Kennung    *
*    suchen und ein gespeichertes Bild zwecks Weiterver-        *
*    arbeitung auf Diskette speichern (z.B. FOTOFIX.PRG         *
*---------------------------------------------------------------*
T13NEW: BRA.S   GOON            * Kennung umschiffen
        DC.L    $12344321       * Kennung
SCR2    DS.L    1               * Adresse des Fotoschirms
LEVEL   DC.B    'glasi 180486'
GOON    MOVE.L  SP,A2           * Wenn Aufruf aus Supervisor
        BTST    #5,(SP)         * modus,
        BNE.S   SUPV            * Supervisostack, sonst
        MOVE.L  USP,A2          * Userstack benutzen
        SUBQ    #6,A2
SUPV    CMP     #CONIN,6(A2)    * CONIN Aufruf ?
        BNE.S   NORMAL          * nein, normale Routine benutzen
        CMP     #CON,8(A2)      * Device = Konsole ?
        BNE.S   NORMAL          * nein, normale Routine benutzen
        MOVE.L  SAVPTR,A1       * Savearea adressieren
        MOVE    (SP)+,D0        * Status --> D0 und
        MOVE    D0,-(A1)        * retten
        MOVE.L  (SP)+,-(A1)     * Returnadresse retten
        MOVEM.L D3-D7/A3-A7,-(A1) * Register retten
        MOVE.L  A1,SAVPTR       * Savearea aktualisieren
        BTST    #13,D0
        BNE.S   SSUP
        MOVE.L  USP,SP          * korrekten Stackpointer laden
SSUP    MOVE.W  (SP)+,D0
*---------------------------------------------------------------*
*    Ein Zeichen einlesen und auf FOTO-Tasten testen            *
*---------------------------------------------------------------*
GETCH   MOVE.L  CONSOLE,A0      * Adresse der Consolroutine
        SUB.L   A5,A5           * A5 MUSS geloescht sein
        JSR     (A0)            * Zeichen lesen
        CMP.B   #DISKEY,D0      * FOTO anzeigen ?
        BEQ.S   DISPL           * ja, also los
        CMP.B   #FOTKEY,D0      * Schirm fotografieren ?
        BEQ.S   FOTO            * ja....
BACK    MOVE.L  SAVPTR,A1       * Savearea adressieren
        MOVEM.L (A1)+,D3-D7/A3-A7 * Register zurueckladen
        MOVE.L  (A1)+,-(SP)     * Returnadresse und
        MOVE    (A1)+,-(SP)     * Status
        MOVE.L  A1,SAVPTR       * Savearea aktualisieren
        RTE                     * Return from Expection
NORMAL  MOVE.L  TSAVE,A0        * Kein CONIN, also koennen wir
        JMP     (A0)            * das BIOS benutzen
*---------------------------------------------------------------*
*   Aktuellen Bildschrirm fotografieren....                     *
*---------------------------------------------------------------*
FOTO    MOVE.L  SCR1,A3         * Bildschirmadresse -> A3
        MOVE.L  SCR2,A4         * FOTOscreen -> A4
        MOVE.L  #BILD,D3        * Schirmgroesse als Zaehler
FLOOP   MOVE.L  (A3)+,(A4)+     * und los gehts
        DBF     D3,FLOOP
FBAK    MOVE    #$0,D0          * Zeichen unterdruecken
        BRA.S   BACK            * und zurueck.
*---------------------------------------------------------------*
*   FOTOschirm anzeigen                                         *
*---------------------------------------------------------------*
DISPL   LEA     SCR2(PC),A0     * Physbase = FOTOSCREEN
        BSR.S   SWITCH(PC)
        MOVE    #CONIN,-(SP)
        MOVE    #CON,-(SP)
        TRAP    #BIOS
        ADDQ.L  #4,SP
NOSAV   LEA     SCR1(PC),A0     * PHYSBASE = NORMALSCREEN
        BSR.S   SWITCH(PC)
        BRA.S   FBAK
*---------------------------------------------------------------*
*   Bildschirme umschalten                                      *
*---------------------------------------------------------------*
SWITCH  MOVE    #-1,-(SP)       * Logbase unveraendert
        MOVE.L  (A0),-(SP)      * Physbase = Bildschirm
        MOVE.L  #-1,-(SP)       * und umschalten
        MOVE    #SETSCR,-(SP)
        TRAP    #XBIOS
        ADD.L   #12,A7
        RTS
*---------------------------------------------------------------*
*  Daten und Meldungen                                          *
*---------------------------------------------------------------*
TSAVE   DS.L    1               * Alter BIOS-Vektor
CONSOLE DS.L    1               * Alter Consolevektor
SCR1    DS.L    1               * Arbeitsbildschirm
AMSG    DC.B    $1B,'E','FOTO geladen, Resident halten (J/N) ?',0
RMSG    DC.B    $1B,'E','FOTO bereits resident !!',0
*---------------------------------------------------------------*
* Bildschirmspeicher                                            *
*---------------------------------------------------------------*
        BSS
SCREEN  DS.L    SSIZE
        END
