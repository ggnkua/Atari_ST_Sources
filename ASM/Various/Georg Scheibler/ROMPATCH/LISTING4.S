; Patch-Routinen fÅr das TOS 1.4 vom 6.4.1989
; Ω Georg Scheibler, Fillekuhle 7, 4920 Lemgo
; den einzelnen Routinen sind jeweils drei Langworte
; vorangestellt
; 1. die LÑnge der Routine, die ersetzt werden soll
; 2. die LÑnge der neuen Routine.
; 3. die Adresse der Routine relativ zum Dateianfang
; die einzelnen Routinen werden von einem Basicprogramm
; in die ROM-Datei geschrieben.
; Ist die neue Routine kÅrzer als die alte, so wird der
; freie Speicherplatz auf $FF gesetzt.

; stehen mehrere Patch-Routinen in einer Datei, so steht
; als erstes die Anzahl der Routinen als negatives Langwort

        DC.L  -10 ;Anzahl der Routinen

;************ hier beginnt der Patch 1 *************
;Vorschub um 7/72 (NEC P6: 7/60) Zoll (alt: $1B31FF00)
        DC.L 4
        DC.L 4
        DC.L $282BB
        DC.L $1B4107FF  ;ESC A <7>

;************ hier beginnt der Patch 2 *************
;Internes DESKTOP.INF, Druckerparameter 960 Punkte/Zeile
        DC.L 8
        DC.L 8
        DC.L $2FA48
        DC.B '#b000100'

;************ hier beginnt der Patch 3 *************
;Patch fÅr die Auswertung des DESKTOP.INF
;damit auch die EintrÑge #a, #b, #c und #U
;ausgewertet werden

desk_tab EQU  $FEFE00

;Anpassung der Verzweigungsroutine an die
;neue Adresse und an die neue Obergrenze
        DC.L  $14
        DC.L  desk_e-desk_a
        DC.L  $1537E            ;$FD537E

; nur zwei Befehle geÑndert, Rest original
; D0 enthÑlt (Erkennungbuchstaben - #$43)
desk_a: CMPI.W  #(desk_tab_E-T_desk_a)/4-1,D0 ;geÑndert
        BHI.S   desk_e
        ASL.W   #2,D0
        MOVEA.W D0,A0
        ADDA.L  #desk_tab,A0    ;geÑndert
        MOVE.L  (A0),A0
        JMP     (A0)
desk_e:

;************ hier beginnt der Patch 4 *************
;beim Sprung durch die Tabelle steht A4 auf auf das Zeichen
;die Register D5-D7 und A3-A5 wurden vorher gesichert.
;die Routinen enden mit einem Sprung nach $FD5392
        DC.L  $FF0000-desk_tab
        DC.L  T_desk_e-T_desk_a
        DC.L  desk_tab-$FC0000
nv equ  $FD5392
T_desk_a: ;Sprungtabelle , am Anfang die alten Adressen
        DC.L  $FD5188,$FD51AA,$FD52F4,$FD51AA ;C,D,E,F
        DC.L  $FD51AA,nv,nv,nv,nv,nv,$FD5192 ;G,H,I,J,K,L,M
        DC.L  nv,nv,$FD51AA,nv,nv,nv,$FD5192 ;N,O,P,Q,R,S,T
        DC.L  desk_uhr+desk_tab-T_desk_a  ;U
        DC.L  nv,$FD51CC,nv,nv,$FD5176 ;V,W,X,Y,Z
        DC.L  nv,nv,nv,nv,nv,nv  ;[,\,],^,_,` (FÅlladdresse)
        DC.L  RSC232+desk_tab-T_desk_a        ;a
        DC.L  Printer+desk_tab-T_desk_a       ;b
        DC.L  key+desk_tab-T_desk_a           ;c
desk_tab_E:

;das setzen der RSC232 Åber Xbios 15 funktioniert an dieser
;Stelle nicht. Vermutlich ist der Superstack zu klein.
;die folgende Routine orientiert sich an der Originalroutine
;(beim Setzen der Parameter, nicht beim Ermitteln derselben)
RSC232: MOVE.W  SR,-(A7)
        ORI.W   #$700,SR   ;Interrupt sperren
        MOVE.B  4(A4),D0   ;Bit pro Zeichen
        AND.W   #3,D0
        LSL.W   #5,D0      ;Bits an die richtige Stelle
        MOVE.B  3(A4),D1   ;ParitÑt dazumischen
        ANDI.W  #3,D1
        BEQ.S   RSCnp      ;keine ParitÑt
        CMPI.W  #3,D1
        BEQ.S   RSCnp
        ADDQ.W  #1,D1
        ADD.W   D1,D1
        ADD.W   D1,D0
RSCnp:  LEA     $FFFFFA01,A1 ;MFP-Basisadresse
        MOVE.B  $28(A1),D1   ;USART-Register
        ANDI.W  #$99,D1
        OR.B    D0,D1        ;Bit pro Zeichen und ParitÑt
        MOVE.B  D1,$28(A1)   ;setzen

        MOVE.B  2(A4),D0     ;Bautrate
        ANDI.W  #$F,D0
        MOVE.B  RSC_tab(PC,D0.W),D1
        EXT.W   D1
        MOVE.W  D1,$A6E      ;Kopie speichern
        MOVEQ   #0,D0
                             ;Timer entsprechend setzen
        MOVE.B  D0,$2A(A1)   ;Receiver- und
        MOVE.B  D0,$2C(A1)   ;Transmitter-Status lîschen
        LEA     $FC3ACC,A0   ;Tabelle fÅr Vorteiler
        MOVE.B  0(A0,D1.W),D0
        LEA     $FC3ADC,A0   ;Tabelle fÅr Timer-DATA
        MOVE.B  0(A0,D1.W),D2
        MOVE.L  D0,D1
        MOVEQ   #3,D0
        JSR     $FC36AC      ;Unterprg. der Orginalroutine
        MOVEQ   #1,D0        ;zum setzen des Timers
        MOVE.B  D0,$2A(A1)
        MOVE.B  D0,$2C(A1)

        MOVE.W  5(A4),D0   ;flowctl speichern
        ANDI.W  #3,D0
        CMPI.W  #3,D0
        BHI.S   rsc_nf
        BEQ.S   rsc_f
        MOVEQ   #1,D0
rsc_f:  MOVE.B  D0,$C90    ;hier steht die Variable
rsc_nf: ADDQ.L  #7,A4      ;Register hinter die Parameter
        MOVE.W  (A7)+,SR
        BRA.S   return
;Tabelle zur Umwandlung der Kennzahl fÅr die Bautrate
RSC_tab:DC.B    1,2,7,9,0,3,4,5,6,8,10,11,12,13,14,15

;Auswertung von '#Ux' (Erweiterung des 'DESKTOP.INF') zum
;Ein- bzw. Ausschalten der Uhr
desk_uhr:ADDQ.L #1,A4
        CMPI.B  #$31,(A4)+ ;'1' = aus, sonst ein
        SNE     $425
        BRA.S   return

Printer:ADDQ.L  #1,A4      ;Printerparameter setzen
        MOVEQ   #5,D0
        MOVEQ   #0,D5
Pr_L:   CMPI.B  #$31,(A4)+ ;Die BinÑrzahl auswerten
        BNE.S   Pr_2
        BSET    D0,D5
Pr_2:   DBF     D0,Pr_L
        MOVE.W  D5,-(A7)   ;Parameter setzen
        MOVE.W  #$21,-(A7)
        TRAP    #14
        ADDQ.L  #4,A7
return: JMP     nv         ;zurÅck in die schleife

;Farben und Tastaturparameter setzen. An die VDI-Routine
;wird der Pointer auf das INTIN-Array Åbergeben
key:    ADDQ.L  #1,A4
        LINK    A6,#-8
        MOVEQ   #15,D6    ;16 Farben
        LEA     -8(A6),A5 ;mein 'INTIN-Array'
        MOVE.L  A5,A0
        CLR.W   (A5)+     ;Nr. der Farbe
key1:   MOVEQ   #2,D1     ;je 3 Grundfarben
key2:   MOVE.B  (A4)+,D0
        ANDI.W  #7,D0     ;von XBIOS-Format (bis 7)
        MULU    #125,D0   ;umrechnen fÅr GEM (bis 1000)
        ADD.W   #62,D0    ;fÅr Rundung
        MOVE.W  D0,(A5)+
        DBF     D1,key2
        MOVE.L  A0,A5
        JSR     $FD1D34   ;Teil der VDI-Routine vs_color
        MOVE.L  A5,A0
        ADDQ.W  #1,(A5)+  ;Nr. der Farbe
        DBF     D6,key1

        MOVE.B  (A4)+,D0  ;Geschwindigkeit fÅr Doppelclick
        ANDI.W  #7,D0
        CLR.W   -(A7)
        MOVE.W  D0,-(A7)
        DC.W    $F090     ;Teil der AES-Routine evnt_dclick

        MOVEQ   #2,D0     ;Klick bei Tastendruck
        BSR.S   key_bit
        MOVEQ   #0,D0     ;Glocke
        BSR.S   key_bit

        BSR.S   key_zahl
        MOVE.W  D0,(A7)   ;(a7) mîglich durch LINK A6,#-8
        BSR.S   key_zahl
        MOVE.W  D0,2(A7)
        MOVE.W  #35,-(A7) ;Kbrate
        TRAP    #14
        UNLK    A6        ;mit Stackkorrektur fÅr Unterprg.
        BRA.S   return
key_zahl:MOVE.B (A4)+,D1  ;zweistellige Dezimalzahl von
        ANDI.W  #$F,D1    ;ASCII in Zahl wandeln
        MULU    #10,D1
        MOVE.B  (A4)+,D0
        ANDI.W  #$F,D0
        ADD.W   D1,D0
        RTS
key_bit:BSET    D0,$484    ;erst mal einschalten
        CMPI.B  #$30,(A4)+ 
        BNE.S   key_b_E
        BCLR    D0,$484
key_b_E:RTS
T_desk_e:

;************ hier beginnt der Patch 5 *************
;Korrektur der Werte fÅr RSC232 Timer
;Vorteiler fÅr 75 und 50 Baud auf 3 statt 2
        DC.L 2
        DC.L 2
        DC.L $3ADA
        DC.W $303

;************ hier beginnt der Patch 6 *************
;Test-Routine ob die MEGA-Uhr vorhanden ist
;diese Routien zerstîrt die Alarmregister nicht
        DC.L  $52
        DC.L  LFC1FC2-a
        DC.L  $1F70
a:      MOVE.W  #8,A1      ;A1 auf Busfehlervektor
        MOVEA.W #$FC20,A0  ;Basisaddresse der Uhr ($FFFFFC20)
        MOVE.L  (A1),D2    ;Vektor fÅr Busfehler
        MOVEA.L A7,A2
        MOVE.L  #adr_err-a+$FC1F70,(A1) ;neuer Vektor
        ORI.B   #9,$1B(A0) ;Bank 1,Uhr ein
        MOVE.L  D2,(A1)    ;alter Vektor fÅr Busfehler
        MOVEP.W 5(A0),D1   ;alten Inhalt der Register lesen
        MOVE.W  #$A06,D0   ;Testwert, keine gÅltige Min.
        MOVEP.W D0,5(A0)   ;schreiben
        MOVEP.W 5(A0),D2   ;und wieder lesen
        MOVEP.W D1,5(A0)   ;alten Wert zurÅckschreiben
        ANDI.W  #$F0F,D2   ;Uhr hat nur 4 Bit-Daten
        CMP.W   D0,D2      ;korrekt zurÅckgelesen
        BNE.S   err        ;nein, dann keine Uhr vorhanden
        MOVE.B  #1,1(A0)   ;Clock Out (wie im Orginal)
        BCLR    #0,$1B(A0) ;Bank 0
        CLR.B   $1D(A0)    ;zur Sicherheit Schnellauf aus
        RTS
adr_err:MOVEA.L A2,A7      ;Stack korrigieren
        MOVE.L  D2,(A1)    ;alter Vektor fÅr Busfehler
err:    ORI.B   #1,CCR     ;Carry-bit setzen
        RTS
LFC1FC2:

;************ hier beginnt der Patch 7 *************
;diese Routine setzt die Megauhr (Teil von XBIOS 22)
        DC.L $E0              ;alte LÑnge 
        DC.L LFC215C-LFC207C  ;neue LÑnge
        DC.L $207C            ;Pos. relativ zum Dateianfang
; in dieser Routine steht A0 auf der Adresse $FFFFFC20
LFC207C:  ;Bezugsadresse fÅr ROM-Label auûerhalb der Routine
        MOVEQ   #-1,D0    ;gehîrt zur vorhergehenden Routien
        RTS
;hier beginnt die Routine zum setzen der Hardwareuhr
        BSR     LFC207C-$10C  ;$FC1F70 ;Test auf Megauhr
        BCS.S   LFC207C
        LEA     $A54,A1    ;Zeiger auf Zwischenpuffer
        MOVE.L  4(A7),-(A7)
        BSR.S   wandle     ;Wandlung als Unterprg. damit
        ADDQ.L  #4,A7      ;auch von Uhranzeige benutzbar
        ANDI.B  #3,D2      ;statt divu #4,d2 und  swap d2
        MOVE.B  #2,$1F(A0) ;interne Register der Uhr auf 0
        BSET    #0,$1B(A0) ;nur Bank 1 einschalten
        MOVE.B  #1,$15(A0) ;24 std.-modus
        MOVE.B  D2,$17(A0) ;Schaltjahr
        BCLR    #0,$1B(A0) ;nur Bank 0 einschalten
        MOVEQ   #$C,D0
        MOVEQ   #1,D1      ;nun noch die Register kopieren
LFC2148:MOVE.B  -(A1),0(A0,D1.W)
        ADDQ.W  #2,D1
        DBF     D0,LFC2148
        MOVEQ   #0,D0      ;RÅckmeldung: alles OK
        RTS
wandle: MOVE.W  4(A7),D1   ;Datum
        MOVE.W  D1,D0
        LSR.W   #1,D0
        LSR.W   #8,D0
        MOVE.W  D0,D2      ;Jahreszahl merken
        BSR.S   einWert
        MOVE.W  D1,D0      ;Monat
        LSR.W   #5,D0
        AND.W   #$F,D0
        BSR.S   einWert
        MOVE.W  D1,D0      ;Tag
        AND.W   #$1F,D0
        BSR.S   einWert
        LSR.W   #5,D1
        ANDI.W  #$F,D1     ;Monat
        ADDQ.W  #1,D1      ;+1
        MOVE.W  D2,D0
        CMPI.W  #3,D1      ;(Monat+1) kleiner 4 ?
        BHI.S   W1
        ADD.W   #12,D1     ;dann Monat +12
        SUBQ.W  #1,D0      ;und Jahr -1
W1:     MULU    #26,D1
        DIVU    #10,D1     ;mal 2.6 (2.6= 30.6 mod 7)
        ADD.W   D0,D1      ;+ Jahr
        LSR.W   #2,D0
        ADD.W   D0,D1      ;+ Jahr/4 (--> *(365.25 mod 7)
        MOVE.W  4(A7),D0   ;Tag
        ANDI.W  #$1F,D0
        ADD.W   D0,D1
        ADDQ.W  #2,D1      ;korrektur fÅr Jahr-1980
        EXT.L   D1
        DIVU    #7,D1      ;mod 7
        SWAP    D1
        MOVE.B  D1,(A1)+   ;Wochentag (SO=0, MO=1 etc.)

        MOVE.W  6(A7),D1   ;Zeit umwandeln
        MOVE.W  D1,D0      ;Stunden
        LSR.W   #8,D0
        LSR.W   #3,D0
        BSR.S   einWert
        MOVE.W  D1,D0      ;Minuten
        LSR.W   #5,D0
        BSR.S   Wert60
        MOVE.W  D1,D0      ;Sekunden
        ADD.W   D0,D0      ;erst addieren, dann AND
Wert60: AND.W   #$3F,D0
einWert:EXT.L   D0         ;Dezimalstellen teilen und
        DIVU    #$A,D0
        MOVE.B  D0,(A1)+   ;speichern
        SWAP    D0
        MOVE.B  D0,(A1)+
        RTS
LFC215C:

;************ hier beginnt der Patch 8 *************
;in GEM-vbl-Routine den ersten Befehl (TST.W $2886.L)
;durch jsr Uhrroutine ersetzen. Der ersetzte Befehl
;muû in der Uhrroutine als letztes vor dem RTS
;ausgefÅhrt werden.
Uhr equ $FEFC80
        DC.L    6  ;alte LÑnge 
        DC.L    vektor_E-vektor
        DC.L    $10AE6    ;Pos. des Befehls ($FD0AE6)
vektor: JSR     Uhr       ;identisch mit do_uhr, aber die
vektor_E:                 ;Routinen werden getrennt

;************ hier beginnt der Patch 9 *************
;diese Routine sorgt dafÅr, daû die Uhr bei jedem Reset
;eingeschaltet wird. (BEVOR DESKTOP.INF ausgewertet wird)
        DC.L    12
        DC.L    uhr_ein_E-uhr_ein
        DC.L    $13BCC
uhr_ein:MOVE.L  A0,$6E28 ;zwei Adressen von abs.L in abs.w 
        MOVE.L  $4C2,D0  ;bringt vier Byte fÅr zusÑtzlichen
        ST      $425     ;Befehl Uhr fÅr DESKTOP einschalten
uhr_ein_E:

;************ hier beginnt der Patch 10 *************
        DC.L    $FEFE00-Uhr ;max. LÑnge 
        DC.L    last-do_uhr ;neu LÑnge
        DC.L    Uhr-$FC0000 ;Anfangsadresse
; es ist nicht notwendig, die Register zu retten, da dies
; vorher bereits erledigt wurde
do_uhr: TST.B   $425      ;UHRFLAG
        BEQ.S   no_uhr    ;keine Uhranzeige
        BMI.S   cnt_uhr
        BSR     undo_uhr  ;Anzeige lîschen
        BRA.S   no_uhr
cnt_uhr:ADDQ.B  #2,$425   ;IN ZWEIERSCHRITTEN, DA NOT(-1)=0
        BMI.S   no_uhr
        MOVEQ   #-20,D0   ;ZÑhler neu setzen
        MOVE.B  D0,$425
        link    A6,#-16   ;Puffer fÅr Wandlung reservieren
        BSR.S   wrt_uhr
        unlk    A6
no_uhr: TST.W   $2886    ;dieser Befehl wurde ersetzt um
        RTS              ;diese Routine mit JSR einzuhÑngen
wrt_uhr:DC.W    $A000          ;Line_A_Init
        LEA     -16(A6),A1    ;Pufferadresse Åbergeben
        MOVE.W  $378A,-(A7)   ;GEMDOS-Zeit
        MOVE.W  $60BE,-(A7)   ;GEMDOS-Datum
; eigene Routine zum Umrechnen der Zeit (wandle, s.o.)
;    (Bestandteil der neuen Xbios-routien settime)
        JSR     $FC207C+wandle-LFC207C
        ADDQ.L  #4,A7
        CMPI.W  #1000,$2B88 ;1/1000-tel Sekunden von GEMDOS
        BLT.S   even
        ADDQ.B  #1,-1(A1)   ;Sekunde um 1 erhîhen
even:   MOVE.L  #$FE8EF8,A2 ;Beginn d. 8*8 Zeichensatzes
;jetzt zeigt A0 auf die Line_A-Variablen
;A1 hinter die Uhrzeit und A2 auf den Zeichensatz
        MOVE.L  76(A2),A3   ;Beginn d. Zeichensatz-Pixel
        MOVE.W  80(A2),D2   ;dessen Breite
        MOVE.W  82(A2),D5   ;dessen Hîhe
        SUBQ.W  #1,D5       ;wegen DBF erniedirgen
        MOVE.W  2(A0),D7    ;Byte pro Zeile (aus LINE_A)
        MOVE.W  (A0),D3     ;Anzahl der Bildschirmebenen
        EXT.L   D7
        MOVE.L  D7,D6
        ADD.W   D6,D6
        ADD.W   D3,D3       ;Offset zur nÑchsten Ebene
        SUBQ.W  #1,D3       ;minus 1
        EXT.L   D3
        CMPI.W  #1,D3       ;hohe Auflîsung
        BHI.S   zeit
        LSL.W   #2,D6       ;mal 4 = insgesamt mal 8
        ADD.W   D7,D6       ;also 8 Zeilen tiefer
        ADD.W   D7,D6
        BSR.S   zeit        ;die Uhrzeit ausgeben
        SUBQ.L  #1,A1       ;Wochentag zunÑchst ignorieren
        MOVE.L  -4(A1),D0   ;Monat und Tag vertauschen
        SWAP    D0
        MOVE.L  D0,-4(A1)
        MOVEQ   #0,D0
        MOVE.L  D7,D6
        ADD.L   D7,D6
        SUBQ.L  #1,D6
        ADD.L   $44E,D6     ;Anfangsadresse des Bildschirms
        BSR.S   zahl        ;Monat-Einer
        BSR.S   zahl        ;Monat-Zehner
        MOVEQ   #$2E,D0     ;'.' Schreiben
        BSR.S   zeichen
        BSR.S   zahl        ;Tag-Einer
        BSR.S   zahl        ;Tag-Zehner
        MOVEQ   #$20,D0 
        BSR.S   zeichen     ;' ' ausgeben
        MOVE.B  4(A1),D0    ;Kennzahl fÅr Wochentag
        ANDI.W  #7,D0       ;zur Sicherheit
        ADD.W   D0,D0
        LEA     tage(PC,D0.W),a1 ;Wochentag ausgeben
        MOVE.B  1(A1),D0
        BSR.S   zeichen
        MOVE.B  (A1),D0
        BSR.S   zeichen
        RTS
tage:   DC.B    'SOMODIMIDOFRSAer' ;er fÅr ERROR

zeit:   SUBQ.W  #1,D6
        ADD.L   $44E,D6    ;Anfangsadresse des Bildschirms
        MOVEQ   #0,D0
        BSR.S   zahl       ;Sekunden-Einer
        BSR.S   zahl       ;Sekunden-Zehner
        MOVEQ   #$3A,D0
        BSR.S   zeichen    ;':' Ausgeben
        BSR.S   zahl       ;Minuten-Einer
        BSR.S   zahl       ;Minuten-Zehner
        MOVEQ   #$3A,D0
        BSR.S   zeichen
        BSR.S   zahl       ;Stunde-Einer
        NOP            ;erforderlich, da sonst BRA-Offset 0
zahl:   MOVE.B  -(A1),D0   ;Zahl aus Puffer holen
        ORI.B   #$30,D0    ;in ASCII umwandeln
zeichen:MOVEA.L D6,A4      ;Pos des Zeichens auf dem
        MOVE.W  D5,D4         ;Bildschirm
        MOVEA.L A3,A5
        CMPI.W  #1,D3      ;welche Auflîsung ?
        BEQ.S   Z_1        ;verzweige wenn hires
        BTST    #0,D6      ;gerade Byteposition ?
        BEQ.S   ZPG
Z_1:    SUBQ.L  #1,D6      ;bei ungeraden Adressen nur das
Z_L:    MOVE.B  0(A5,D0.W),(A4) ;Zeichen in den Bildschirm
        ADDA.W  D7,A4      ;nÑchste Zeile im Bildschrim
        ADDA.W  D2,A5      ;nÑchste Zeile im Zeichensatz
        DBF     D4,Z_L
        RTS
ZPG:    SUB.L   D3,D6       ;bei geraden Byte-Pos. auch die
Z_L2:   MOVE.B  0(A5,D0.W),(A4) ;anderen Ebenen fÅllen
        MOVE.W  (A4),-2(A4) ;Wort fÅr zweite Ebene kopieren
        CMPI.W  #3,D3       ;mittlere Aufflîsung
        BEQ.S   Z_Lw
        MOVE.L  -2(A4),-6(A4) ;2 weitere Ebenen kopieren
Z_Lw:   ADDA.W  D7,A4
        ADDA.W  D2,A5
        DBF     D4,Z_L2
        RTS

; Uhr im Bildschirm lîschen
undo_uhr:CLR.B  $425        ;Flag lîschen
        DC.W    $A000
        MOVE.W  2(A0),D7    ;Byte pro Zeile
        MOVE.W  (A0),D3     ;Anzahl der Bildschirmebenen
        EXT.L   D7
        MOVEQ   #0,D0
        MOVEQ   #7,D1    ;8 Zeilen lîschen (midres, lowres)
        SUBQ.W  #1,D3
        BNE.S   cu_hi
        MOVEQ   #15,D1      ;in hoher Auflîsung 16 Zeilen
cu_hi:  MOVE.L  D7,D6
        ADD.W   D6,D6
        ADD.L   $44E,D6     ;Bildschirmanfang
cu_z:   MOVEA.L D6,A0
        ADD.L   D7,D6       ;Ende der nÑchsten Zeile
        MOVE.W  D3,D2       ;anzahl der Ebenen
cu_l:   MOVE.L  D0,-(A0)
        MOVE.L  D0,-(A0)
        DBF     D2,cu_l
        DBF     D1,cu_z
        RTS
last:
