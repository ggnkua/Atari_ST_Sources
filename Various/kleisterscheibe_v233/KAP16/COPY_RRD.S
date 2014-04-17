*************************************************************************
******************************** COPY RRD *******************************
*              Auto-Kopierprogramm fÅr das LUFTSCHLOSS/RRD              *
*                           Written & Ω 1989 by                         *
*                 Lutz Preûler (Ahornweg 11, 2904 Hatten)               *
*************************************************************************
* V1.1 (12.2.89): Protokollkommando ($) eingebaut                       *
* V1.2 (22.3.89): CopyAll-Kommando: Kopieren eines ganzen (Teil-)Baumes *
*                 -> COPY umgekrempelt (ruft sich jetzt rekursiv auf)   *
*                 Name- und Delete-Kommando drin, versch. énderungen    *
* V1.3 (24.3.89): SCANINF geÑndert (Sprungtabelle)                      *
*                 Delete kann jetzt auch leere Ordner lîschen, bei      *
*                 CopyAll kînnen diese ebenfalls wieder gelîscht werden *
*************************************************************************

; Versionsnummer
vers        = '1'
rev         = '3'
; Protokollausgabe immer? (1)
PROTOK      = 0

            .TEXT
Start:

; Speicherinitialisierung
            movea.l   4(sp),a5     ; Basepageadr. in a5
            move.l    $c(a5),d0    ; TEXT-LÑnge
            add.l     $14(a5),d0   ; + DATA-LÑnge
            add.l     $1c(a5),d0   ; + BSS-LÑnge
            addi.l    #4000,d0     ; + Basepage + Stack
            move.l    d0,d1
            add.l     a5,d1        ; + Basepage-Adr.
            andi.l    #-2,d1       ; gerade machen
            movea.l   d1,sp        ; Stackpointer neu setzen
            move.l    d0,-(sp)     ; genÅgend Speicher
            move.l    a5,-(sp)     ; ab Basepage
            clr.w     -(sp)        ; per
            move.w    #$4a,-(sp)   ; GEMDOS-MShrink
            trap      #1           ; reservieren (bzw. Rest freigeben)
            lea.l     12(sp),sp

; Copyright ausgeben
            lea.l     CopyRt,a6
            bsr       message

; Steuerdatei einlesen
            bsr.s     READINF
            tst.w     d0           ; Fehler?
            bne.s     INFError
            movea.l   a0,a4        ; INF-Adresse retten

; (fast) den gesamten Speicher als Kopierpuffer reservieren
            move.l    #-1,-(sp)
            move.w    #72,-(sp)    ; Malloc
            trap      #1           ; GEMDOS
            addq.l    #6,sp
            subi.l    #10000,d0
            move.l    d0,CBufLen   ; LÑnge speichern
            move.l    d0,-(sp)
            move.w    #72,-(sp)    ; Malloc
            trap      #1           ; GEMDOS
            addq.l    #6,sp
            tst.l     d0           ; Fehler?
            ble.s     Error
            move.l    d0,CBufAdr   ; Adresse speichern

; jetzt kommt's...
            lea.l     bearb,a6
            bsr       message
            bsr       SCANINF      ; Steuerdatei abarbeiten
            bra.s     Ok

INFError:   lea.l     INFName,a6
            bsr       message
            lea.l     INFErrM,a6
            bra.s     ErrMessage
Error:      lea.l     ErrM,a6
ErrMessage: bsr       message

Ok:         clr.w     -(sp)        ; und
            trap      #1           ; Schluû!


*************************
* Daten fÅr Hauptprogramm
*************************
            .DATA
CopyRt:     DC.b 13,10,'Auto-Kopierprogramm V',vers,'.',rev,13,10
            DC.b 'Ω 1989 by Lutz Preûler, 2904 Hatten'
cr:         DC.b 13,10,0
bearb:      DC.b 'Bearbeite Kommandos...',13,10,0

INFName:    DC.b 'COPY_RRD.INF',0
INFErrM:    DC.b ' fehlt!',13,10,7,0

ErrM:       DC.b 'Fehler!',13,10,7,0
            .EVEN

            .TEXT



*************************
* READINF: Steuerdatei einlesen
*
* IN:  #INFName: Dateiname
* OUT: a0: Adresse der Steuerdaten
*          Endkennz.: 3*$FF.b
*      d0<>0: Fehler
*************************
READINF:
            movem.l   d1-d4/a1-a3,-(sp)    ; Regs retten

; Datei îffnen
            move.w    #0,-(sp)     ; read-only
            pea       INFName      ; Dateiname
            move.w    #61,-(sp)    ; Fopen
            trap      #1           ; GEMDOS
            addq.l    #8,sp
            tst.w     d0           ; Fehler?
            bmi.s     RErr
            move.w    d0,d3        ; Dateihandle -> d3

            bsr       FLength      ; DateilÑnge bestimmen -> d4

; Speicher reservieren
            move.l    d4,-(sp)     ; DateilÑnge
            addq.l    #4,(sp)      ; + 4 Bytes
            move.w    #72,-(sp)    ; Malloc
            trap      #1           ; GEMDOS
            addq.l    #6,sp
            tst.l     d0           ; Fehler?
            bmi.s     RErr
            movea.l   d0,a3        ; Startadr. -> a3

; Datei einlesen
            move.l    a3,-(sp)     ; Puffer-Adr.
            move.l    d4,-(sp)     ; DateilÑnge
            move.w    d3,-(sp)     ; Handle
            move.w    #63,-(sp)    ; Fread
            trap      #1           ; GEMDOS
            lea.l     12(sp),sp
            cmp.l     d4,d0        ; alles eingelesen?
            bne.s     RErr

; Datei in Groûschrift konvertieren
            move.l    d4,d1
            movea.l   a3,a0
            subq.l    #1,d1
ConvL:      cmpi.b    #'a',(a0)
            blt.s     ConvLE
            cmpi.b    #'z',(a0)
            bgt.s     ConvLE
            subi.b    #32,(a0)
ConvLE:     addq.l    #1,a0
            dbra      d1,ConvL
; 3*$FF.b anhÑngen
            st        (a0)+
            st        (a0)+
            st        (a0)

; Pufferadr. zurÅckgeben
            movea.l   a3,a0
            clr.l     d0           ; kein Fehler
            bra.s     REx

RErr:       moveq.l   #1,d0        ; Fehler aufgetr.

REx:        movem.l   (sp)+,d1-d4/a1-a3    ; Regs zurÅck
            rts                    ; bye, bye...


*************************
* SCANINF: Steuerdatei abarbeiten
*
* IN:  a4: Anfangsadresse
*************************
SCANINF:
            movem.l   d1-d7/a1-a6,-(sp)    ; Regs retten

ScLoop:
            lea.l     ARGBuff,a5   ; Paramter-Puffer

            cmpi.b    #' ',1(a4)   ; zweites Byte Leerzeichen?
            bne.s     Sungueltig
            move.b    (a4),d3      ; Kommandozeichen

            addq.l    #2,a4        ; ab drittem Byte...
; ...in #ARGBuff kopieren
SLoop1:     move.b    (a4)+,d0
            move.b    d0,(a5)+
            cmpi.b    #-1,d0
            beq.s     ScExit
            cmpi.b    #13,d0
            bne       SLoop1
            addq.l    #1,a4
            clr.b     -1(a5)

; Dispatcher...
;-----------------------------
            lea.l     ComTAB,a5    ; Kommandotabelle
ComLoop:    lea.l     Start,a3     ; Basisadresse
            move.b    (a5),d0      ; Kommandozeichen
            beq.s     ComEx        ; schon am Ende?
            addq.l    #6,a5        ; nÑchster Eintrag
            cmp.b     d0,d3        ; richtiges Kommando?
            bne       ComLoop      ; nein: weiter
            move.w    -2(a5),d0    ; Protokolltext
            beq.s     ComNoPr      ; 0: kein Protokoll
            lea.l     0(a3,d0.w),a6
            bsr       Proto1       ; evtl. Protokoll
ComNoPr:    move.w    -4(a5),d0    ; Routine
            lea.l     0(a3,d0.w),a3
            jsr       (a3)         ; ausfÅhren
ComEx:      bra       ScLoop       ; weiter im Text

;- - - - - - - - - - - - - - -
Sungueltig:           ; Zeile Åberlesen
SuLoop:     cmpi.b    #-1,(a4)
            beq.s     ScExit
            cmpi.b    #13,(a4)+
            bne       SuLoop
            addq.l    #1,a4
            bra       ScLoop

ScExit:
            movem.l   (sp)+,d1-d7/a1-a6    ; Regs zurÅck
            rts                    ; und fini!

*** Daten ***
*** KOMMANDOTABELLE ***
; Aufbau: dc.b Zeichen,0
;         dc.w Routine-Start,Protokoll-Start
; Ende:   dc.w 0
ComTAB:
            DC.b 'C',0             ; Datei(en) kopieren   > Copy
            DC.w CCOPY-Start,pCOPY-Start
            DC.b 'A',0             ; Baum kopieren        > CopyAll
            DC.w ACOPY-Start,pCOPYALL-Start
            DC.b 'M',0             ; Ordner anlegen       > Make
            DC.w MAKE-Start,pMAKE-Start
            DC.b 'T',0             ; Laufwerk 'testen'    > Test
            DC.w TEST-Start,pTEST-Start
            DC.b '$',0             ; Protokoll ein/aus
            DC.w PROTOKOLL-Start,0
            DC.b 'N',0             ; Datei umbenennen     > Name
            DC.w NAME-Start,pNAME-Start
            DC.b 'D',0             ; Datei(en) lîschen    > Delete
            DC.w DELETE-Start,pDELETE-Start
            DC.w 0

            .EVEN
prtk:       DC.b PROTOK,0          ; Flag fÅr Protokollausg.
            .BSS
ARGBuff:    DS.b 150
TRENNK:     DS.w 1
            .TEXT


*************************
* COPY: Datei(en) kopieren
*
* IN:  a3:  Zeiger auf Quellpfad
*      d3:  Zeiger auf Zielpfad
*      #CBufAdr: Pufferadresse
*      #CBufLen: PufferlÑnge
* OUT: d0.w<0: Fehler aufgetr.
*      d0.w=1: keine Datei kopiert
*************************
ACOPY:                ; *** Aufruf von SCANINF fÅr CopyAll
            st        COPYALL
            bra.s     XCOPY
CCOPY:                ; *** Aufruf von SCANINF fÅr Copy
            sf        COPYALL
XCOPY:
            lea.l     ARGBuff,a3
            bsr       Get2ndParam  ; zweiten Parameter best.
            bne       COPYEx       ; nicht vorhanden
            move.l    a0,d3

COPY:
            link      a4,#-204     ; Stackbereich fÅr lokale
; Variablen aufbauen (rekursiver Aufruf von COPY)
; Offsets der lokalen Variablen:
QName       = -204    ; Quellpfad (80 Bytes)
ZName       = -124    ; Zielpfad (80 Bytes)
DTA         = -44     ; lokale DTA (44 Bytes)
DTAAttr     = -23     ; Offset in DTA: Attribut
DTAName     = -14     ; Offset in DTA: Dateiname

            movem.l   d1-d7/a0-a3/a5/a6,-(sp)     ; Regs retten
; DTA setzen
            pea       DTA(a4)
            move.w    #$1a,-(sp)   ; Fsetdta
            trap      #1           ; GEMDOS
            addq.l    #6,sp

            movea.l   d3,a2        ; Zielpfad

; Quellpfad speichern
            movea.l   a3,a0
            lea.l     QName(a4),a5
            movea.l   a5,a1
CLoop1:     move.b    (a0)+,(a5)+
            bne       CLoop1

            bsr       LastBackSl   ; letzen Backslash im Pfad best.

; Zielpfad speichern
            lea.l     ZName(a4),a1
CLoop3:     move.b    (a2)+,(a1)+
            bne       CLoop3
            subq.l    #1,a1
            move.l    a1,d7        ; d7: Zeiger auf 1.Byte nach Zielpfad


; Passende Dateien bestimmen
            moveq.l   #1,d6        ; RÅckgabewert
; erste Datei
            move.w    #39,-(sp)    ; nur Dateien
            move.l    a3,-(sp)     ; Quellpfad
            move.w    #78,-(sp)    ; Fsfirst
            trap      #1           ; GEMDOS
            addq.l    #8,sp
            bra.s     CopyTst
DLoop:
            move.w    #79,-(sp)    ; Fsnext
            trap      #1           ; GEMDOS
            addq.l    #2,sp
CopyTst:    tst.w     d0
            bmi       CLExit       ; Datei nicht vorhanden

; Dateiname an Pfade anhÑngen

            lea.l     DTAName(a4),a0       ; Dateiname in DTA
            movea.l   a5,a1        ; Quellpfad
            movea.l   d7,a2        ; Zielpfad
CNLoop:     move.b    (a0),(a1)+   ; kopieren
            move.b    (a0)+,(a2)+
            bne       CNLoop

; wenn Protokoll, Dateinamen anzeigen
            tst.w     prtk
            beq.s     copyfile
            lea.l     QName(a4),a6
            bsr       message
            lea.l     pfeil,a6
            bsr       message
            lea.l     ZName(a4),a6
            bsr       message
            move.w    #32,d0       ; Leerzeichen
            bsr       Cconout

** Datei kopieren **
copyfile:

; Quelldatei îffnen
            move.w    #0,-(sp)     ; read-only
            pea       QName(a4)    ; Dateiname
            move.w    #61,-(sp)    ; Fopen
            trap      #1           ; GEMDOS
            addq.l    #8,sp
            tst.w     d0           ; Fehler?
            bmi       DLoopE
            move.w    d0,d2        ; Dateihandle -> d2

            move.w    d2,d3
            bsr       FLength      ; DateilÑnge best. -> d4

; Zieldatei erstellen
            clr.w     -(sp)        ; norm. Datei
            pea       ZName(a4)    ; Dateiname
            move.w    #60,-(sp)    ; Fcreate
            trap      #1           ; GEMDOS
            addq.l    #8,sp
            tst.w     d0           ; Fehler?
            bmi       CErr3
            move.w    d0,d3        ; Dateihandle -> d3

CopL:
            move.l    d4,d5
            cmp.l     CBufLen,d4   ; DateilÑnge >= Pufferl.?
            ble.s     CRest
            move.l    CBufLen,d5   ; nur Pufferl. einlesen
CRest:      sub.l     CBufLen,d4

; der eigentliche Kopiervorgang
            move.l    CBufAdr,-(sp)        ; Puffer
            move.l    d5,-(sp)     ; LÑnge
            move.w    d2,-(sp)     ; Handle
            move.w    #63,-(sp)    ; Fread
            trap      #1           ; GEMDOS
            lea.l     12(sp),sp
            cmp.l     d0,d5        ; alles eingelesen?
            bne       CErr2        ; nein: Fehler
            move.l    CBufAdr,-(sp)        ; Puffer
            move.l    d5,-(sp)     ; LÑnge
            move.w    d3,-(sp)     ; Handle
            move.w    #64,-(sp)    ; Fwrite
            trap      #1           ; GEMDOS
            lea.l     12(sp),sp
            cmp.l     d0,d5        ; alles geschrieben?
            bne       CErr2        ; nein: Fehler (Disk voll?!?)

            tst.w     prtk         ; Wenn Protokoll:
            beq.s     CPLbl
            move.w    #'.',d0      ; '.' ausgeben
            bsr       Cconout

CPLbl:      tst.l     d4           ; schon alles kopiert?
            bgt       CopL         ; nein: nÑchster 'Block'...


; Datum/Zeit der Quelldatei auf Zieldatei Åbertragen
; und beide Dateien schlieûen

            clr.w     -(sp)        ; Datum/Zeit lesen
            move.w    d2,-(sp)     ; Handle
            pea       DatTime      ; DOSTIME-Struktur
            move.w    #87,-(sp)    ; Fdatime
            trap      #1           ; GEMDOS
            lea.l     10(sp),sp

            move.w    d2,-(sp)     ; Quelldatei
            move.w    #62,-(sp)    ; Fclose
            trap      #1           ; GEMDOS
            addq.l    #4,sp

            move.w    d3,-(sp)     ; Zieldatei
            move.w    #62,-(sp)    ; Fclose
            trap      #1           ; GEMDOS
            addq.l    #4,sp

            move.w    #1,-(sp)     ; write-only
            pea       ZName(a4)    ; Zieldatei
            move.w    #61,-(sp)    ; Fopen
            trap      #1           ; GEMDOS
            addq.l    #8,sp
            move.l    d0,d3        ; Handle
            bmi.s     DLoopE

            move.w    #1,-(sp)     ; Datum/Zeit setzen
            move.w    d3,-(sp)     ; Handle
            pea       DatTime      ; DOSTIME-Struktur
            move.w    #87,-(sp)    ; Fdatime
            trap      #1           ; GEMDOS
            lea.l     10(sp),sp

            move.w    d3,-(sp)     ; Zieldatei
            move.w    #62,-(sp)    ; Fclose
            trap      #1           ; GEMDOS
            addq.l    #4,sp
            clr.w     d6           ; RÅckgabewert

DLoopE:     tst.w     prtk         ; Wenn Protokoll:
            beq       DLoop
            lea.l     cr,a6        ; cr ausgeben
            bsr       message
            bra       DLoop        ; weitere Dateien?

CErr2:                ; Zieldatei schlieûen und lîschen
            move.w    d3,-(sp)     ; Zieldatei
            move.w    #62,-(sp)    ; Fclose
            trap      #1           ; GEMDOS
            addq.l    #4,sp

            pea       ZName(a4)    ; Zieldatei
            move.w    #65,-(sp)    ; Fdelete
            trap      #1           ; GEMDOS
            addq.l    #6,sp
CErr3:                ; Quelldatei schlieûen
            move.w    d2,-(sp)     ; Quelldatei
            move.w    #62,-(sp)    ; Fclose
            trap      #1           ; GEMDOS
            addq.l    #4,sp

            lea.l     ZName(a4),a5
            bsr       Fehler

            move.w    #-1,d0       ; Fehler!
            bra       CExit2

CLExit:     tst.b     COPYALL      ; Baum kopieren?
            beq       CExit        ; nein: Ende

; Ordner anlegen und Inhalt kopieren (rekursiv)

; alle Ordner ('...*.*' an Quellpfad)
            move.b    #'*',0(a5)
            move.b    #'.',1(a5)
            move.b    #'*',2(a5)
            clr.b     3(a5)
; erste Datei suchen
            move.w    #16,-(sp)    ; Ordner
            pea       QName(a4)    ; Quellpfad
            move.w    #78,-(sp)    ; Fsfirst
            trap      #1           ; GEMDOS
            addq.l    #8,sp
            bra.s     CopyTst2
OLoop:                ; weitere Dateien
            move.w    #79,-(sp)    ; Fsnext
            trap      #1           ; GEMDOS
            addq.l    #2,sp
CopyTst2:   tst.w     d0
            bmi       CExit        ; Datei nicht vorhanden: raus
            btst      #4,DTAAttr(a4)       ; wirklich Ordner?
            beq       OLoop        ; nein: weitersuchen
            cmpi.b    #'.',DTAName(a4)     ; '.' oder '..' ? ja: weitersuchen
            bne.s     OrdnerOK
            cmpi.b    #'.',DTAName+1(a4)
            beq       OLoop
            tst.b     DTAName+1(a4)
            beq       OLoop

OrdnerOK:
; Ordnername an Pfade anhÑngen
            lea.l     DTAName(a4),a0       ; Dateiname in DTA
            movea.l   d7,a2        ; Zielpfad
            movea.l   a5,a1        ; Quellpfad
CNLoop2:    move.b    (a0),(a2)+
            move.b    (a0)+,(a1)+
            bne       CNLoop2
            movea.l   a2,a6        ; Zielpfadende zwischenspeichern
            move.b    #'\\',-1(a1) ; '\' an Quellpfad anhÑngen  ('\\':MADMAC)
; Quelldateiname (evtl. Wildcards) wieder an Quellpfad anhÑngen
            move.l    a5,d0
            lea.l     QName(a4),a0
            sub.l     a0,d0
CNLoop3:    addq.w    #1,d0
            move.b    -1(a3,d0.w),(a1)+
            bne       CNLoop3

; Ordner erzeugen
            pea       ZName(a4)    ; neuer Ordner
            move.w    #57,-(sp)    ; Dcreate
            trap      #1           ; GEMDOS
            addq.l    #6,sp

; '\' an Zielpfad anhÑngen
            move.b    #'\\',-1(a6) ; ('\\':MADMAC)
            clr.b     (a6)

; und COPY rekursiv aufrufen...
            movem.l   d3/a3,-(sp)  ; öbergaberegs sichern
            lea.l     QName(a4),a3 ; Quellpfad
            lea.l     ZName(a4),a0 ; Zielpfad
            move.l    a0,d3
            bsr       COPY         ; ab in die Tiefen des Baumes
            movem.l   (sp)+,d3/a3  ; Regs zurÅck
; Fehler aufgetreten?
            tst.w     d0
            blt.s     CExit2       ; ja: Abbruch
            bgt.s     CDelSub      ; wurde was kopiert?
            clr.w     d6           ; ja: RÅckgabewert
            bra.s     CDTA
CDelSub:    tst.b     TRENNK       ; Ordner wieder lîschen?
            beq.s     CDTA         ; (Komma als Trennzeichen)  -> nein
            clr.b     -1(a6)       ; '\' wieder entfernen
            pea       ZName(a4)    ; Pfad
            move.w    #58,-(sp)    ; Ddelete
            trap      #1           ; GEMDOS
            trap      #1           ; second turn (TOS-Fehler?!)
            addq.l    #6,sp
CDTA:                 ; DTA aktualisieren
            pea       DTA(a4)
            move.w    #$1a,-(sp)   ; Fsetdta
            trap      #1           ; GEMDOS
            addq.l    #6,sp

; weitere Ordner auf dieser Ebene?
            bra       OLoop

; hier bin ich fertig
CExit:      move.l    d6,d0        ; kein Fehler
CExit2:     movem.l   (sp)+,d1-d7/a0-a3/a5/a6     ; Regs zurÅck
            unlk      a4           ; Stack aufrÑumen
COPYEx:     rts                    ; das wÑr's...

******* Daten *******
            .DATA
pfeil:      DC.b ' -> ',0          ; fÅr Protokoll
            .BSS
; Puffer fÅr Datum/Zeit
DatTime:    DS.w 2
; Flag
COPYALL:    DS.w 1
; öbergabeparameter
CBufLen:    DS.l 1
CBufAdr:    DS.l 1
            .TEXT

*************************
* MAKE: Ordner anlegen
*************************
MAKE:
            lea.l     ARGBuff,a5
            move.l    a5,-(sp)     ; neuer Ordner
            move.w    #57,-(sp)    ; Dcreate
            trap      #1           ; GEMDOS
            addq.l    #6,sp
            tst.w     d0           ; kein Fehler?
            bge.s     MAKEEx
            cmpi.w    #-36,d0      ; Ordner schon da?
            beq.s     MAKEEx
            bsr       Fehler1      ; Fehlermeldung
MAKEEx:     rts

*************************
* TEST: Laufwerk 'testen'
*************************
TEST:
            move.b    ARGBuff,DumPath
            move.b    ARGBuff,testabbr
            move.w    #55,-(sp)    ; Dateien + Ordner
            pea       DumPath      ; 'X:\*.*'
            move.w    #78,-(sp)    ; Fsfirst
            trap      #1           ; GEMDOS
            addq.l    #8,sp
            tst.w     d0           ; Datei(en) vorhanden?
            bne.s     TESTEx       ; nein: weiter geht's

            lea.l     testabbr,a6
            bsr       message
            addq.l    #4,sp        ; radikal
            bra       ScExit       ; abbrechen
TESTEx:     rts

******* Daten *******
            .DATA                  ; ('\\':MADMAC)
DumPath:    DC.b 'X:\\*.*',0
testabbr:   DC.b 'X: nicht leer - Abbruch',13,10,0
            .TEXT

*************************
* PROTOKOLL(kommando)
*************************
PROTOKOLL:
            .IF PROTOK=0
            cmpi.b    #'+',ARGBuff ; einschalten?
            seq       prtk
            .ENDIF
            rts

*************************
* NAME: Datei umbenennen
*************************
NAME:
            lea.l     ARGBuff,a3
            bsr       Get2ndParam  ; zweiten Parameter best.
            bne.s     NAMEEx       ; nicht vorhanden

            move.l    a0,-(sp)     ; neuer Name
            move.l    a3,-(sp)     ; alter Name
            clr.w     -(sp)
            move.w    #86,-(sp)    ; Frename
            trap      #1           ; GEMDOS
            lea.l     12(sp),sp
NAMEEx:     rts

*************************
* DELETE: Datei(en) und (leere) Ordner lîschen
*************************
DELETE:
; DTA setzen
            pea       eDTA
            move.w    #$1a,-(sp)   ; Fsetdta
            trap      #1           ; GEMDOS
            addq.l    #6,sp

; Quellpfad speichern
            lea.l     ARGBuff,a3
            movea.l   a3,a0
            lea.l     Pfad,a5
            move.l    a5,d4
DLoop1:     move.b    (a0)+,(a5)+
            bne       DLoop1

            bsr.s     LastBackSl   ; letzen Backslash im Pfad best.

; Passende Dateien bestimmen
; erste Datei
            move.w    #54,-(sp)    ; Dateien und Ordner (nicht schreibgesch.)
            move.l    a3,-(sp)     ; Quellpfad
            move.w    #78,-(sp)    ; Fsfirst
            trap      #1           ; GEMDOS
            addq.l    #8,sp
            bra.s     DelTst
DDLoop:
            move.w    #79,-(sp)    ; Fsnext
            trap      #1           ; GEMDOS
            addq.l    #2,sp
DelTst:     tst.w     d0
            bmi.s     DExit        ; Datei nicht vorhanden

; Dateiname an Pfad anhÑngen
            lea.l     eDTAName,a0  ; Dateiname in DTA
            movea.l   a5,a2        ; Quellpfad
DNLoop:     move.b    (a0)+,(a2)+  ; kopieren
            bne       DNLoop

; Datei bzw. Ordner lîschen
            move.l    d4,-(sp)     ; Pfad auf Stack

            btst      #4,eDTAAttr  ; Ordner?
            bne.s     DelSubdir    ; ja

            move.w    #65,-(sp)    ; Fdelete
            trap      #1           ; GEMDOS
            addq.l    #6,sp
            bra       DDLoop       ; weitere Dateien?

DelSubdir:  move.w    #58,-(sp)    ; Ddelete
            trap      #1           ; GEMDOS
            trap      #1           ; noch mal (sonst trat Fehler -36 auf)
            addq.l    #6,sp
            bra       DDLoop       ; weitere Dateien?

DExit:      rts

******* Daten *******
            .BSS
eDTA:       DS.b 21   ; eigene DTA
eDTAAttr:   DS.b 9    ; Attribut in DTA
eDTAName:   DS.b 14   ; Dateiname in DTA
Pfad:       DS.b 80
            .TEXT

*************************
* Cconout: GEMDOS-Zeichenausg.
*
* IN:   d0.w: Zeichen
* USES: d0-d2/a0-a2
*************************
Cconout:
            move.w    d0,-(sp)
            move.w    #2,-(sp)
            trap      #1
            addq.l    #4,sp
            rts

*************************
* LastBackSl: Zeiger auf Dateiname best.
*
* IN:  a0: Pfadanfang
*      a5: Pfadende
* OUT: a5: Zeiger auf Dateiname
*************************
LastBackSl:
PfLoop:     cmpi.b    #'\\',-(a5)  ; ('\\':MADMAC)
            beq.s     PfEnde
            cmpi.b    #':',(a5)
            beq.s     PfEnde
            cmpa.l    a1,a5
            bge       PfLoop
PfEnde:     addq.w    #1,a5
            rts

*************************
* Get2ndParam: zweiten Parameter bestimmen
*
* IN:  a3: Parameteradr.
* OUT: a0: Parameter 2
*      d0.w<>0: nicht vorhanden
*************************
Get2ndParam:
            movea.l   a3,a0
G2ndLoop:   tst.b     (a0)+
            beq.s     G2ndErr
            cmpi.b    #',',-1(a0)
            beq.s     G2ndFound
            cmpi.b    #' ',-1(a0)
            bne       G2ndLoop
G2ndFound:  move.b    -1(a0),TRENNK
            subi.b    #' ',TRENNK  ; TRENNK<>0 wenn ','
            clr.b     -1(a0)
            clr.w     d0
            rts
G2ndErr:    moveq.l   #1,d0
            rts


*************************
* FLength: DateilÑnge bestimmen
*
* IN:   d3.w: Dateihandle
* OUT:  d4.l: DateilÑnge
* USES: d0-d2/a0-a2
*************************
FLength:
            move.w    #2,-(sp)     ; ab Dateiende
            move.w    d3,-(sp)     ; Handle
            clr.l     -(sp)        ; 0 Bytes
            move.w    #66,-(sp)    ; Fseek
            trap      #1           ; GEMDOS
            lea.l     10(sp),sp
            move.l    d0,d4        ; DateilÑnge -> d4
            clr.w     -(sp)        ; zurÅck zum Anfang
            move.w    d3,-(sp)     ; Handle
            clr.l     -(sp)        ; 0 Bytes
            move.w    #66,-(sp)    ; Fseek
            trap      #1           ; GEMDOS
            lea.l     10(sp),sp
            rts


*************************
* Fehler: Fehlermeldung
*
* IN:   a5: Dateiname/Pfad
* USES: d0-d2/a0-a2/a6
*************************
Fehler:
            lea.l     fehlerbpr,a6
            tst.w     prtk
            bne.s     FehlerM
Fehler1:    lea.l     fehlerbei,a6
FehlerM:    bsr.s     message
            movea.l   a5,a6
            bsr.s     message
            lea.l     fehler2,a6
*************************
* message: Gibt Text aus
*
* IN:   a6: Stringadresse
* USES: d0-d2/a0-a2
*************************
message:
            move.l    a6,-(sp)     ; Stringadresse
            move.w    #9,-(sp)     ; Cconws
            trap      #1           ; GEMDOS
            addq.l    #6,sp
noProto:
            rts

            .DATA
fehlerbpr:  DC.b 13,10
fehlerbei:  DC.b 'Fehler bei ',0
fehler2:    DC.b ' !!!',13,10,0
            .TEXT


*************************
* Proto1: Protokollausg.
*
* IN:   a6: Stringadr.
* USES: d0-d2/a0-a2
*************************
Proto1:
            tst.w     prtk
            beq.s     noProto
            bsr       message
            lea.l     ARGBuff,a6
            bsr       message
            lea.l     cr,a6
            bra       message

pCOPY:      DC.b 'Copy ',0
pCOPYALL:   DC.b 'CopyAll ',0
pMAKE:      DC.b 'Make ',0
pTEST:      DC.b 'Test ',0
pNAME:      DC.b 'Name ',0
pDELETE:    DC.b 'Delete ',0

