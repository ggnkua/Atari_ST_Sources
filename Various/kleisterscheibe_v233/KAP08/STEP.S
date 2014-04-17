******************************
* STEPxy.PRG: éndert Steprate fÅr einzelne Laufwerke
* Ω1989 Claus Brod
* Aus dem SCHEIBENKLEISTER, dem etwas anderen Floppybuch
* V1.0: 12/87
* V2.0 (2/88): Sucht im aktuellen Verzeichnis nach
*       Dateinamen, der Stepraten enthalten kann:
*       STEPXY.PRG
*           ||
*           |----- Steprate fÅr B:
*           |
*           ------ Steprate fÅr A:
* V3.0 (9/88): Umstellung auf MADMAC
* V3.1 (1/89): Anpassung an TOS1.4
* V3.2 (10/89): Verwendet neue XBIOS-Fn Floprate (ab TOS 1.4)
* V3.3 (1/91): Anpassung an TurboAss und neue
*              Schreibweise der TOS-Versionen
*              bessere Methode zum Feststellen, ob man aus
*              dem AUTO-Ordner gestartet wurde
*******************************

                OPT F+

def0            EQU 3           ; Voreinstellung fÅr Laufwerk A
def1            EQU 1           ; Voreinstellung fÅr Laufwerk B

*****************
* Routine zum Reservieren von Speicherplatz
*****************
                movea.l 4(SP),A6        ; Basepage-Start

                lea     header(PC),A5   ; Adresse der Intro-Msg
                bsr     prnmsg          ; ausgeben

                bsr     seekfile        ; File suchen
                lea     $80(A6),A6      ; Offset auf commandline
                clr.w   D0              ; d0 lîschen
                move.b  (A6),D0         ; LÑnge der commandline
                beq.s   standard        ; gleich 0, dann Standard (A=3ms, B=12ms)
                bsr     getrates        ; Raten aus Kommandozeile holen

standard:
                clr.l   -(SP)           ; Userstack wird Supervisorstack
                move.w  #32,-(SP)       ; SUPER
                trap    #1              ; im GEMDOS
                addq.l  #6,SP           ; ab jetzt alles im Supervisormode
                move.l  D0,-(SP)        ; Supervisorstackpointer retten
                move.w  #32,-(SP)       ; SUPER

                move.w  D4,$0440.w      ; Steprate fÅr A in Systemvariable
                movea.l $04F2.w,A1      ; sysbase
                move.w  2(A1),D7        ; TOS-Versionsnummer
                cmp.w   #$0104,D7       ; TOS 1.04?
                blo.s   altes_tos       ; nein
                move.w  D4,-(SP)        ; Steprate
                clr.w   -(SP)           ; fÅr Laufwerk A:
                move.w  #41,-(SP)       ; Floprate (neu ab TOS 1.04!)
                trap    #14             ; XBIOS
                move.w  D5,-(SP)        ; Steprate (-1: Steprate erfragen)
                move.w  #1,-(SP)        ; fÅr Laufwerk B:
                move.w  #41,-(SP)       ; Floprate
                trap    #14             ; XBIOS
                lea     12(SP),SP       ; SP korrigieren
                bra.s   beenden

altes_tos:
                lea     $0A06.w,A0      ; DSB0 fÅr ROM/RAM-TOS vom 6.2.86
                cmp.w   #$0102,D7       ; BlitterTOS?
                blt.s   oldversion      ; nein, alte Version
                lea     $0A4C.w,A0      ; DSB0 fÅr BlitterTOS/TOS1.04
oldversion:
                move.w  D4,2(A0)        ; Steprate fÅr Laufwerk A
                move.w  D5,6(A0)        ; Steprate fÅr Laufwerk B

beenden:
                bsr     prnstatus       ; Einstellung ausgeben
                move.w  D7,D0           ; kopieren
                and.b   #7,D0
                add.b   #'0',D0         ; in ASCII wandeln
                move.b  D0,tos1+3       ; und in String schreiben
                move.w  D7,D0
                lsr.w   #4,D0
                and.b   #7,D0
                add.b   #'0',D0
                move.b  D0,tos1+2
                lsr.w   #8,D7           ; Versionsnummer holen
                add.b   #'0',D7         ; in ASCII wandeln
                move.b  D7,tos1         ; in String schreiben
                lea     tosvs(PC),A5    ; 'TOS-Version ...'
                bsr     prnmsg          ; TOS-Version melden

                tst.w   autoflag        ; Programm aus Autoordner gestartet?
                bne.s   exitus          ; ja, nicht mehr auf Taste warten

                move.w  #1,-(SP)        ; auf Taste warten
                trap    #1              ; GEMDOS
                addq.l  #2,SP

exitus:
                trap    #1              ; SUPER ($20 und SSP noch auf Stack)
                addq.l  #6,SP           ; Stack sÑubern
                clr.w   -(SP)           ; TERM
                trap    #1              ; TschÅsseken

**************************
* getrates: Stepraten aus Commandline holen
* IN: a6 Zeiger auf Beginn der Commandline
*     d0 maximale LÑnge des Strings
*     d4, d5 Defaults fÅr Stepraten
* OUT: d4 Steprate A, d5 Steprate B
**************************
getrates:
                subq.l  #1,D0           ; LÑnge minus 1 wegen dbf

getloop:
                addq.l  #1,A6           ; Ab eigentlichem String anfangen
                move.b  (A6),D1         ; Byte holen
                tst.b   D1              ; gleich 0?
                beq.s   schluss         ; ja, Schluû
                or.w    #32,D1          ; in Kleinbuchstaben wandeln
                cmp.b   #'a',D1         ; gleich 'a'?
                beq.s   geta            ; ja, Steprate fÅr A holen
                cmp.b   #'b',D1         ; gleich 'b'?
                beq.s   getb            ; ja, Steprate fÅr B holen
                dbra    D0,getloop      ; nein, weitersuchen

getb:
                addq.l  #1,A6           ; Zeiger erhîhen
                move.b  (A6),D1         ; Steprate holen
                sub.b   #'0',D1         ; ASCII nach Zahl
                move.b  D1,D5           ; als Steprate B merken
                dbra    D0,getloop      ; String zu Ende?
schluss:
                rts                     ; ja, raus

geta:
                addq.l  #1,A6           ; Zeiger erhîhen
                move.b  (A6),D1         ; Steprate holen
                sub.b   #'0',D1         ; ASCII nach Zahl
                move.b  D1,D4           ; als Steprate A merken
                dbra    D0,getloop      ; String zu Ende?
                rts                     ; ja, raus

**************************
* prnstatus: Stepraten ausgeben
* IN: d4 Step A, d5 Step B
**************************
prnstatus:
                lea     stepa(PC),A5    ; String 'Steprate A:'
                bsr.s   prnmsg          ; ausgeben
                add.b   #'0',D4         ; Steprate in Zahl wandeln
                move.b  D4,zahl         ; und ablegen
                lea     zahl(PC),A5     ; Adresse des Zahlenstrings
                bsr.s   prnmsg          ; ausgeben
                lea     stepb(PC),A5    ; String 'Steprate B:'
                bsr.s   prnmsg          ; ausgeben
                add.b   #'0',D5         ; Steprate in Zahl wandeln
                move.b  D5,zahl         ; und ablegen
                lea     zahl(PC),A5     ; Adresse des Zahlenstrings

**************************
* prnmsg: Gibt String ab Adresse in a5 aus
**************************
prnmsg:
                move.l  A5,-(SP)        ; Stringadresse auf Stack
                move.w  #9,-(SP)        ; PRINTLINE

                trap    #1              ; GEMDOS
                addq.l  #6,SP           ; Stack sÑubern
                rts                     ; byebye

*************************
* seekfile: nach Filenamen suchen
* und eventuell Stepraten setzen
*************************
seekfile:
                pea     dta(PC)         ; neue DTA-Adresse
                move.w  #$1A,-(SP)      ; Fsetdta
                trap    #1              ; GEMDOS
                addq.l  #6,SP           ; Stack sÑubern

                clr.w   -(SP)           ; normale Datei
                pea     filename(PC)    ; Zeiger auf Suchmuster

                move.w  #$C9,D0         ; appl_yield
                trap    #2
                tst.w   D0
                beq.s   noauto
                st      autoflag        ; Auto-Ordner-Flag setzen
                move.l  #fname2,(SP)    ; sonst: '\AUTO\STEP*.PRG'
noauto:
                move.w  #$4E,-(SP)      ; Fsfirst
                trap    #1              ; GEMDOS
                addq.l  #8,SP           ; Stack sÑubern

                moveq   #def0,D4        ; d4 vorbelegen
                moveq   #def1,D5        ; d5 vorbelegen

                tst.w   D0              ; File gefunden?
                bne.s   error           ; nein, dann Fehler
gefunden:
                lea     dta(PC),A0      ; -> DTA-Puffer
                lea     30+4(A0),A0     ; auf Filenamen positionieren
                clr.w   D0
                move.b  (A0),D0         ; Steprate fÅr Laufwerk A
                sub.w   #'0',D0         ; ASCII nach Zahl
                bmi.s   fdrvb
                cmp.w   #4,D0           ; erlaubte Steprate?
                bcc.s   fdrvb           ; nein, weiter
                move.w  D0,D4           ; Steprate Laufwerk A
fdrvb:
                move.b  1(A0),D0        ; Steprate fÅr Laufwerk B
                sub.w   #'0',D0         ; ASCII nach Zahl
                bmi.s   error
                cmp.w   #4,D0           ; erlaubte Steprate?
                bcc.s   error           ; nein, weiter
                move.w  D0,D5           ; Steprate Laufwerk B
error:
                rts                     ; und raus hier

header:
                DC.B 13,10,10
                DC.B 27,'p    Meister Stepper    ',27,'q',13,10
                DC.B 27,'p  Ω1991 by Claus Brod  ',27,'q',13,10
                DC.B 'Aus SCHEIBENKLEISTER, dem etwas anderen Floppybuch',13,10,10
                DC.B 'Usage: stepxy [{a|A}{0|1|2|3}] [{b|B}{0|1|2|3}]...'
                DC.B 13,10,0

stepa:          DC.B 13,10,'Steprate A: ',0
stepb:          DC.B ', B: ',0
zahl:           DC.B ' ',0
tosvs:          DC.B ', TOS '
tos1:           DC.B '1.00',13,10,10,0

                EVEN
autoflag:       DC.W 0
fname2:         DC.B "\AUTO\"
filename:       DC.B "STEP*.PRG",0

                BSS
dta:            DS.B 44
                END
