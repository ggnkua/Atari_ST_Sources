********************************************************************************
**                          MEM_XXXX.PRG                                      **
**                                                                            **
** (C) 1991 Armin Hierstetter, ICP Verlag - TOS Magazin 11/91                 **
**                                                                            **
** Entwickelt mit TurboAss von Markus Fritze - was sonst?                     **
**                                                                            **
** Verkleinert den Speicher auf den fr XXXX im Dateinamen                    **
** angegebenen Wert (in KByte).                                               **
**                                                                            **
********************************************************************************

                OUTPUT 'C:\AUTO\MEM_0512.PRG'
                OPT F+

;
; Speichergr”že         Wert fr "XXXX"
; --------------------------------------
;  0.5 MByte             0512
;  1.0 MByte             1024
;  1.5 MByte             1536
;  2.0 MByte             2048
;  2.5 MByte             2560

; Konstanten

magic           EQU $752019F3   ; Diese magischen Nummern sorgen dafr,
magic2          EQU $237698AA   ; daž beim  Reset nur ein Warmstart erfolgt,
magic3          EQU $5555AAAA   ; also der neue Speicherwert erhalten bleibt

busfehler       EQU $08         ; Vektor fr Busfehler-Routine
_sysbase        EQU $04F2       ; Zeiger auf Betriebssystemheader-Struktur
_hz_200         EQU $04BA       ; 200 Hz-Z„hler

memvalid        EQU $0420       ; \
memval2         EQU $043A       ;  - Enthalten die >>magischen Werte<<
memval3         EQU $051A       ; /

phystop         EQU $042E       ; Zeigt hinter das Ende des physikal. Speichers
memtop          EQU $043A       ; Zeigt auf Ende des freien Speichers

; Hauptprogramm:
; Zun„chst auf <ALTERNATE> prfen (fr Konfiguration)
; DTA einrichten und Datei ber Fsfirst() suchen

                pea     dta(PC)         ; DTA setzen
                move.w  #$1A,-(SP)      ; Fsetdta();
                trap    #1              ; GEMDOS
                addq.l  #6,SP           ; Stack aufr„umen

                clr.w   -(SP)           ; Dateiattribut
                pea     file(PC)        ; gesuchter Dateiname "MEM_*.PRG"
                move.w  #$4E,-(SP)      ; Fsfirst();
                trap    #1              ; GEMDOS
                addq.l  #8,SP           ; Stack aufr„umen

                tst.w   D0              ; Datei gefunden ?
                beq.s   test_alt        ; los geht's

                lea     error1(PC),A0   ; "\AUTO\MEM_XXXX.PRG nicht gefunden !"
                bsr     print           ; Fehlermeldung ausgeben
                bra     exit            ; und Programm beenden

test_alt:       move.w  #-1,-(SP)       ; Modus: Tastaturstatus holen
                move.w  #11,-(SP)       ; Kbshift()
                trap    #13             ; Bios
                addq.l  #4,SP           ; Stack aufr„umen

                btst    #3,D0           ; Auf Alternate testen
                beq.s   start           ; Wenn nicht gedrckt, gleich loslegen

                lea     setup(PC),A0    ; "Neue Speichergr”že: "
                bsr     print           ; Text ausgeben

                pea     buffer(PC)      ; Adresse des Puffers
                move.w  #10,-(SP)       ; Cconrs();
                trap    #1              ; GEMDOS
                addq.l  #6,SP           ; Stack aufr„umen

                cmpi.b  #4,buffer+1     ; Anzahl der Zeichen muž vier sein
                beq.s   change_mem      ;

                lea     error4(PC),A0   ; "MEM_XXXX: Alter Wert bleibt ..."
                bsr     print           ; Text ausgeben

                bra.s   exit            ; und Schluž

change_mem:     lea     new_mem+4(PC),A0 ; eingegebene Zahl
                bsr     konvert         ; konvertieren

                tst.l   D7              ; Fehler in der Konvertierung ?
                beq.s   exit            ; dann raus

                move.l  (A0),new_file+10 ; neuen Wert in Filenamen eintragen
                move.l  d_fname+4(PC),file+10 ; >>????<< durch alten Wert ersetzen

                pea     new_file(PC)    ; Dateiname mit neuem Wert
                pea     file(PC)        ; hier steht der alte Dateiname+Pfad
                clr.w   -(SP)           ;
                move.w  #$56,-(SP)      ; Frename()
                trap    #1              ; GEMDOS
                lea     12(SP),SP       ; Stack aufr„umen

                move.l  new_file+10(PC),d_fname+4 ; neuen Filenamen eintragen

                bra.s   do_it           ; jetzt geht's endltig los

start:          lea     d_fname+8(PC),A0 ; Zahl in Dateinamen
                bsr     konvert         ; konvertieren

                tst.l   D7              ; D7 auf Fehler testen
                beq.s   exit            ; wenn Null, dann raus

do_it:          pea     super(PC)       ; Routine im Supervisor-Mode
                move.w  #38,-(SP)       ; Superexec
                trap    #14             ; XBios-Trap
                addq.l  #6,SP           ; Stack aufr„umen

                move.l  d_fname+4(PC),memory ; Speichergr”že in Text bernehmen

                lea     message(PC),A0  ; "MEM_XXXX.PRG installiert (...)"
                bsr     print           ; Text ausgeben

exit:           clr.w   -(SP)           ; Pterm0()
                trap    #1              ; und Schluž

; Prft aktuelle Speichergr”že und stellt neuen Gr”že bei Bedarf ein

super:          movea.l mem(PC),A0      ; Speicherkonfiguration holen
                cmpa.l  $042E.w,A0      ; und mit Systemwert vergeichen
                bne.s   set_memory      ; wenn ungleich, neuen Wert setzen
                rts                     ; Speicher bereits verkleinert

; Neue Speichergr”že einstellen

set_memory:     move.l  busfehler.w,save_bus_error ; Alten Vektor sichern
                move.l  #new_bus,busfehler.w ; neue Routine installieren

                move.b  #'T',-1(A0)     ; Gibt's dort Speicher ??

; Tritt beim Schreibzugriff auf -1(A0) ein Busfehler auf, beendet
; die eigene Busfehlerroutine (new_bus) das Programm mit einer Fehlermeldung

                move.l  save_bus_error(PC),busfehler.w ; Vektor restaurieren

install:        move.l  A0,phystop.w    ; phystop auf neuen Wert
                move.l  A0,memtop.w     ; mem_top auf neuen Wert
                move.l  #magic,memvalid.w ; Magiv Number I
                move.l  #magic2,memval2.w ; Magic Number II
                move.l  #magic3,memval3.w ; Magic Number III

                lea     message1(PC),A0 ; "System-Reset"
                bsr.s   print           ; Text ausgeben

                moveq   #2,D1           ; 2 Sekunden Lesezeit
                bsr.s   wait            ; warten

                movea.l _sysbase.w,A0   ; Zeiger auf OS-Header nach A0
                movea.l 4(A0),A0        ; Startadresse des Betriebssystems
                jmp     (A0)            ; ... und tschss

konvert:        clr.l   D7              ; Hauptz„hler = 0
                moveq   #1,D3           ; Stellenwert (1,10,100,1000)
                moveq   #3,D1           ; 4 Ziffern konvertieren

loop:           clr.l   D2              ;
                move.b  -(A0),D2        ; Ziffer holen

                cmpi.b  #'0',D2         ; Mit 0 vergleichen
                blt.s   error           ; wenn kleiner -> Fehlermeldung

                cmpi.b  #'9',D2         ; Mit 9 vergleichen
                bgt.s   error           ; wenn gr”žer -> Fehlermeldung

                subi.b  #'0',D2         ; ASCII-Wert >>0<< abziehen
                mulu    D3,D2           ; mit Stellenwert multiplizieren
                add.l   D2,D7           ; und auf Hauptz„hler addieren
                mulu    #10,D3          ; n„chster Stellenwert
                dbra    D1,loop         ;

                asl.l   #8,D7           ; mit 1024 multiplizieren
                asl.l   #2,D7           ;

                move.l  D7,mem          ; Speichergr”že sichern

                rts                     ; zurck zum Hauptprogramm

error:          clr.l   D7              ; d7 l”schen = Fehler
                lea     error2(PC),A0   ; "Falscher Wert bei MEM_XXXX.PRG"

print:          move.l  A0,-(SP)        ; Adresse des Textes auf Stack
                move.w  #9,-(SP)        ; Cconws()
                trap    #1              ; GEMDOS
                addq.l  #6,SP           ; Stack aufr„umen

                rts                     ; zurck zur Hauptroutine

wait:           move.l  _hz_200.w,D0    ; Aktuellen Z„hlerwert nach d0
                mulu    #200,D1         ; Wartezeit steht in d1 (in Sekunden)
                add.l   D1,D0           ;
w_loop:         cmp.l   _hz_200.w,D0    ; Zeit verstrichen ?
                bne.s   w_loop          ; nein, warten
                rts

; Eigene Busfehlerroutine

new_bus:        move.l  save_bus_error(PC),busfehler.w ; Vektor restaurieren

                lea     error3(PC),A0   ; "Speichergrenze unterhalb (...)"
                bsr.s   print           ; Fehlermeldung ausgeben

                moveq   #3,D1           ; 3 Sekunden Lesezeit
                bsr.s   wait            ; warten
                bra     exit            ; und Ende

                DATA

file:           DC.B '\AUTO\MEM_????.PRG',0 ; Nach eigenem Programm suchen
                EVEN
new_file:       DC.B '\AUTO\MEM_XXXX.PRG',0 ; Kopie des Dateinamens fr Konfiguration

                EVEN
setup:          DC.B 13,10
                DC.B 'Neue Speichergr”že (in Kbyte): ',0
                EVEN

buffer:         DC.B 4,0
new_mem:        DC.B 'xxxx',0
                EVEN

message:        DC.B 13,10
                DC.B 'MEM_XXXX von A.Hierstetter',13,10
                DC.B '½ 1991 ICP Verlag, TOS-Magazin',13,10
memory:         DC.B 'xxxx KByte Speicherplatz',13,10,0
                EVEN

message1:       DC.B 13,10
                DC.B 'Neuer Speicherwert - Reset!',0

error1:         DC.B 13,10,'\AUTO\MEM_XXXX.PRG nicht gefunden !',13,10,0
                EVEN

error2:         DC.B 13,10,'Falscher Wert bei MEM_XXXX.PRG',13,10,0
                EVEN

error3:         DC.B 13,10,'MEM_XXXX: Speichergrenze liegt',13,10
                DC.B 'unterhalb des angegebenen Werts.  ',13,10
                DC.B 'Speichergr”že wurde nicht ver„ndert!',13,10,0

error4:         DC.B 13,10,'MEM_XXXX: Wert bleibt unver„ndert!',0

                BSS

save_bus_error: DS.L 1          ;
mem:            DS.L 1          ; Gewnschte Speichergr”že gem„ž Dateiname
dta:            DS.B 21         ; d_reserved  (Fr GEMDOS reserviert)
                DS.B 1          ; d_attrib    (Datei-Attribut)
                DS.W 1          ; d_time      (Uhrzeit)
                DS.W 1          ; d_date      (Datum)
                DS.L 1          ; d_length    (Dateil„nge)
d_fname:        DS.B 14         ; d_fname     (Dateiname)

                END
