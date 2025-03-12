;*----------------------------------------------*
;*                                              *
;*           TIMESET-Bootsektorroutine          *
;*                                              *
;* Fragt bei Kaltstart die Uhrzeit ab und setzt *
;* nach jedem Warmstart die GEMDOS-Uhr mit der  *
;* Zeit des Tastaturchips (IKBD), denn der wird *
;* bei einem RESET nicht gelîscht. Des weiteren *
;* wird die Betriebssystemdruckereinstellung    *
;* auf EPSON gesetzt (wichtig fÅr ALT-HELP).    *
;*                                              *
;* Keine EingabenÅberprÅfung.                   *
;*                                              *
;*----------------------------------------------*
;* Programmiersprache: ASSEMBLER (TurboAss)     *
;*----------------------------------------------*
;*            Ω JÅrgen Fischer 1990             *
;*----------------------------------------------*


; XBIOS-Konstanten
XBIOS           EQU 14          ; TRAP-Nummer
SetTime         EQU 22
GetTime         EQU 23
SetPrt          EQU 33

; GEMDOS-Konstanten
GEMDOS          EQU 1           ; TRAP-Nummer
CConWS          EQU 9
CConRS          EQU 10
TSetDate        EQU 43
TSetTime        EQU 45

; Einstellwert der IKBD-Uhr (nach Kaltstart)
InitialTime     EQU $60000000

; Druckereinstellung (EPSON-kompatibel)
InitPrt         EQU %100

; EingabepufferlÑnge
strlen          EQU 10

; Bitbelegung bei Zeit-Formaten
; (in den beiden GEMDOS-Worten)
Jahr            EQU 9
Monat           EQU 5

Stunde          EQU 11
Minute          EQU 5


; Registerverwendung
; D0.L          Zeit fÅr XBIOS-Aufrufe
; D1.W          Arbeitsregister beim Bitshiften
; D6.W          Zeit fÅr GEMDOS-Aufrufe
; D7.W          Datum fÅr GEMDOS-Aufrufe

                TEXT

                pea     Info(PC)
                move.w  #CConWS,-(SP)
                trap    #GEMDOS
                addq.l  #6,SP

; Drucker initialisieren
                move.w  #InitPrt,-(SP)
                move.w  #SetPrt,-(SP)
                trap    #XBIOS
                addq.l  #4,SP

; IKBD-Uhrzeit holen
                move.w  #GetTime,-(SP)
                trap    #XBIOS
                addq.l  #2,SP

; Kaltstart ?
                cmpi.l  #InitialTime,D0
                beq.s   SetIKBD


; Zeit und Datum teilen (fÅr's GEMDOS)
                move.w  D0,D6
                swap    D0
                move.w  D0,D7

; GEMDOS-Uhr stellen
SetGEMDOS:      ; Zeit setzen
                move.w  D6,-(SP)       
                move.w  #TSetTime,-(SP)
                trap    #GEMDOS
                addq.l  #4,SP

; Datum setzen
                move.w  D7,-(SP)
                move.w  #TSetDate,-(SP)
                trap    #GEMDOS
                addq.l  #4,SP

; Meldung ausgeben
                pea     DateSetMsg(PC)
                move.w  #CConWS,-(SP)
                trap    #GEMDOS
                addq.l  #6,SP

; Bootroutine beenden
                rts

; Wenn's in den AUTO-Ordner soll:
; 'rts' (oben) lîschen und die nÑchsten 2 Zeilen 
; aktivieren
;
;                clr.w   -(SP)
;                trap    #GEMDOS

; Datum und Zeit einlesen
SetIKBD:        ; Max. StringlÑnge festlegen
                move.b  #strlen,(A0) 
                lea     Buffer(PC),A0

; 'Datum :' ausgeben
                pea     DatePrompt(PC)
                move.w  #CConWS,-(SP)
                trap    #GEMDOS
                addq.l  #6,SP

; String einlesen
                pea     Buffer(PC)
                move.w  #CConRS,-(SP)
                trap    #GEMDOS
                addq.l  #6,SP

Date:           ; Datum lîschen
                clr.w   D7             

; Stringadresse holen
                lea     String(PC),A0

; Tag holen und eintragen
                bsr.s   Dezimal        
                add.w   D0,D7          

; Monat holen und eintrage
                bsr.s   Dezimal
                lsl.w   #Monat,D0
                add.w   D0,D7          

; Jahr holen und eintragen
; (Offset 1980 abziehen)
                bsr.s   Dezimal
                subi.w  #80,D0
                move.w  #Jahr,D1
                lsl.w   D1,D0
                add.w   D0,D7

; 'Zeit :' ausgeben
                pea     TimePrompt(PC)
                move.w  #CConWS,-(SP)
                trap    #GEMDOS
                addq.l  #6,SP

; String einlesen
                pea     Buffer(PC)
                move.w  #CConRS,-(SP)
                trap    #GEMDOS
                addq.l  #6,SP

Zeit:

; Zeit lîschen
                clr.w   D6

; Stringadresse holen
                lea     String(PC),A0

; Stunde holen und eintragen
                bsr.s   Dezimal
                move.w  #Stunde,D1
                lsl.w   D1,D0
                add.w   D0,D6

; Minute holen und eintragen
                bsr.s   Dezimal
                lsl.w   #Minute,D0
                add.w   D0,D6

; Datum und Zeit fÅr XBIOS vorbereiten
                move.w  D7,D0
                swap    D0
                move.w  D6,D0

; IKBD-Uhr stellen
                move.l  D0,-(SP)
                move.w  #SetTime,-(SP)
                trap    #XBIOS
                addq.l  #6,SP

; und nun die GEMDOS-Uhr stellen
                bra     SetGEMDOS

; Liest zwei Zeichen aus dem Eingabepuffer und
; interpretiert sie als zweistellige Dezimalzahl.
; Der gebildete Wert wird in D0 abgelegt. 
; A0 enthÑlt einen Zeiger auf das aktuelle
; Zeichen im Eingabepuffer.
Dezimal:        clr.w   D0
                clr.w   D1

; Zehnerstelle holen
                move.b  (A0)+,D1
                subi.w  #'0',D1
                add.w   D1,D0

                mulu    #10,D0

                clr.w   D1
; Einerstelle holen
                move.b  (A0)+,D1
                subi.w  #'0',D1
                add.w   D1,D0
                rts

                DATA
; Cursor einschalten, solange Eingaben laufen
Info:           DC.B 'TIMESET --- '
                DC.B 'Ω JÅrgen Fischer 1990',0
DateSetMsg:     DC.B 13,10,
                DC.B 27,'fDrucker & Zeit '
                DC.B 'gestellt.',13,10,0
DatePrompt:     DC.B 13,10,27,
                DC.B 'eDatum (ttmmjj) : ',0
TimePrompt:     DC.B 13,10,'Zeit    (ssmm) : ',0

                EVEN
                BSS
Buffer:         DS.B 1
Len:            DS.B 1
String:         DS.B strlen
                END
