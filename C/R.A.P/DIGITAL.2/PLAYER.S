*****************************************************************************
*
*        #==================================================#
*        # TOS PLAYER V1.00, Copyright (C) TOS Magazin 1991 #
*        #==================================================#
*
* Code: R.A.P.
*
* Entwickelt mit >>> TurboAss <<< (was sonst?) von Sigma-Soft!
*
* Vorgesehen zum Linken mit Programmen in C
*
* Dieses Programm dient zur schnellen Ausgabe von 8 Bit Samplen auf STs.
* Waehrend der Ausgabe des Samples wird der Timer C kurzzeitig abgeschaltet
* (Timer C ist verantwortlich fuer die Systemuhr 200 Hz, Tastenrepeat, ...).
* Speziell auf STE-Rechnern wird die Initialisierung des MICROWIRE-Interface
* unterstÅtzt indem die Hoehen etwas abgesenkt werden.)
*
* Achtung OMIKRON.Basic-Programmierer: OM.Basic ruft alle Programme
* immer im SUPERVISOR-Modus auf, das mag der Player nicht.
*
* Da die Ausgabe von Samples moeglichst wenig Zeit in Anspruch nehmen soll,
* war bei diesem Programm die Geschwindigkeit wichtiger als die Lesbarkeit.
* Insbesondere modifiziert der Code sich selbst, indem Samplewerte zu
* Sprungweiten umgerechnet werden. Natuerlich geht es noch ein paar Prozent
* schneller, aber ich denke diese Routine ist schon ein guter Kompromiss.
* Die eigentlichen Staerken dieser Routine werden erst im naechsten Teil der
* Serie richtig klar, lassen Sie sich da mal ueberraschen!
*
* Bei 12.5 kHz werden etwa 41% Rechenzeit verbraucht.
*
* Das Modul erlaubt folgende Aufrufe von C aus:
*
* - init_sam()
* - play_sam(...)
* - play_off()
* - volume(...)
*
* Globals: Die meisten C Compiler stellen externen Variablen einen
* Underscore "_" voran!
*
*****************************************************************************

                OPT D+
                GLOBAL _init_sam,_play_sam,_play_off,_volume

******************************************************************************
* volt: DIE BESTE TABELLE VON ALLEN!
******************************************************************************

volt:
; Lautstaerkewerte im Wort 00 R8 R9 RA:
                DC.W $0000,$0200,$0210,$0310,$0410,$0510,$0600,$0610,$0630,$0710,$0720,$0731
                DC.W $0741,$0810,$0820,$0831,$0841,$0900,$0910,$0930,$0940,$0950,$0951,$0953
                DC.W $0962,$0963,$0A10,$0A30,$0A31,$0A50,$0A52,$0A53,$0A62,$0A70,$0A72,$0B10
                DC.W $0B30,$0B31,$0B41,$0B51,$0B53,$0B62,$0B63,$0B72,$0B74,$0B80,$0B81,$0B83
                DC.W $0B84,$0B85,$0B91,$0B93,$0B94,$0C20,$0C21,$0C41,$0C51,$0C53,$0C62,$0C70
                DC.W $0C72,$0C74,$0C75,$0C82,$0C84,$0C85,$0C90,$0C92,$0C94,$0C95,$0C96,$0C97
                DC.W $0C97,$0CA0,$0CA3,$0D20,$0D31,$0D50,$0D52,$0D61,$0D70,$0D72,$0D74,$0D75
                DC.W $0D82,$0D84,$0D90,$0D91,$0D94,$0D95,$0D96,$0D97,$0DA0,$0DA0,$0DA3,$0DA5
                DC.W $0DA6,$0DA7,$0DA8,$0DA8,$0DA8,$0DB1,$0DB4,$0DB6,$0DB7,$0DB7,$0DB8,$0DB8
                DC.W $0DB9,$0DB9,$0DB9,$0DBA,$0DBA,$0DBA,$0DBA,$0DBA,$0DC2,$0DC5,$0DC6,$0E00
                DC.W $0E31,$0E52,$0E62,$0E72,$0E75,$0E81,$0E85,$0E90,$0E93,$0E96,$0E97,$0E98
                DC.W $0E98,$0EA2,$0EA6,$0EA7,$0EA8,$0EA9,$0EA9,$0EA9,$0EB3,$0EB7,$0EB8,$0EB9
                DC.W $0EB9,$0EBA,$0EBA,$0EBA,$0EBA,$0EC0,$0EC0,$0EC0,$0EC7,$0EC7,$0EC8,$0EC8
                DC.W $0EC9,$0ECA,$0ECA,$0ECA,$0ECA,$0ECB,$0ECB,$0ECB,$0ED0,$0ED0,$0ED0,$0ED7
                DC.W $0ED7,$0ED7,$0ED9,$0ED9,$0ED9,$0EDA,$0EDA,$0EDA,$0EDB,$0EDB,$0EDB,$0F00
                DC.W $0F00,$0F00,$0F70,$0F70,$0F90,$0F90,$0F90,$0FA0,$0FA0,$0FA9,$0FB0,$0FB0
                DC.W $0FB0,$0FBA,$0FBA,$0FC0,$0FC0,$0FC9,$0FC9,$0FCA,$0FCA,$0FCA,$0FCB,$0FCB
                DC.W $0FCB,$0FCC,$0FCC,$0FCC,$0FD0,$0FD0,$0FD0,$0FD0,$0FD0,$0FD0,$0FD0,$0FDB
                DC.W $0FDB,$0FDB,$0FDB,$0FDB,$0FDB,$0FDB,$0FDC,$0FDC,$0FDC,$0FDC,$0FDC,$0FDC
                DC.W $0FDD,$0FDD,$0FDD,$0FDD,$0FDD,$0FDD,$0FE0,$0FE0,$0FE0,$0FE0,$0FE0,$0FE0
                DC.W $0FE0,$0FE0,$0FE0,$0FEC,$0FEC,$0FEC,$0FEC,$0FEC,$0FEC,$0FED,$0FED,$0FED
                DC.W $0FED,$0FED,$0FED,$0FED

******************************************************************************
* die Variablen...
******************************************************************************

size:                                   ; Wiviele Daten noch ausgeben?
                DC.L -1
adr:                                    ; Ab welcher Adresse?
                DC.L -1
buf1:                                   ; Buffer 1
                DC.L -1
buf2:                                   ; Buffer 2
                DC.L -1
tdata:                                  ; Timer A Teiler
                DC.W -1

******************************************************************************
*
* C: char** play_sam(char* start,long len,int timer)
*    Sample abspielen, Werte ab *start, Laenge len, Timerwert timer
*    Die Frequenz des Samples in Hz: 614400/timer (Bsp. 49: 12.54kHz).
*    play_sam liefert in A0.L/D0.L einen Zeiger auf die aktuelle
*    Adresse des gerade abgespielten Bereichs.
*    Wichtig: Vor Aufruf von play_sam evtl. Tastenklick abschalten!
*
*    timer sollte nicht unter 30 und darf nicht ueber 255 liegen!!!
*        Der Rechenzeitverbrauch ist etwa 2025/timer in Prozent.
*
******************************************************************************

_play_sam::                             ; Aufruf im C-Format (A0/D0 frei)
                lea     (SP),A0         ; SP in A0 merken
                movem.l D1-D7/A1-A6,-(SP) ; Registers->Stack

                pea     (A0)
                bsr     sound_off       ; Erstmal alles Abschalten
                movea.l (SP)+,A0

                move.l  4(A0),adr       ;       Size
                move.l  8(A0),size      ;
                move.w  12(A0),tdata    ;

                move.l  buf2(PC),e_sm2+2 ; buf2 zuerst spielen, daher:
                bsr     fill_b2         ; buf2 selbst fuellen
                bsr     fill_b2         ; ja: buf2 nochmal fuellen
                bsr     sound_on
                movem.l (SP)+,D1-D7/A1-A6 ; Stack->Registers
                lea     adr(PC),A0
                move.l  A0,D0
                rts

******************************************************************************
*
* C: play_off():  Sofort aufhoeren: Sound abschalten
*
******************************************************************************

_play_off::
                movem.l D1-D7/A1-A6,-(SP) ; Registers->Stack

                bsr     sound_off       ; Erstmal alles Abschalten

                movem.l (SP)+,D1-D7/A1-A6 ; Stack->Registers
                rts

******************************************************************************
*
* C: init_sam(): zuerst 1 mal aufruf., im USER Mode (!!! OM.Basic !!!)
*    Schaltet Tastaturklick aus und setzt Volume auf 1024 (100%)
*
******************************************************************************

_init_sam::
                movem.l D1-D7/A1-A6,-(SP) ; Registers->Stack

;       * TRAP #15 initialisieren:
                pea     initrap(PC)     ; Umstaendlicher
                move.w  #38,-(SP)       ; Aufruf im SUPERVISOR
                trap    #14             ; via XBIOS
                addq.l  #6,SP           ; (Aber nur einmal!)

;       * 256 fast gleiche Routinen (spart Platz) erzeugen...
                lea     out_1(PC),A1    ; Destin-Code
                move.w  #254,D1         ; 254 mal kopieren
ini_1:          lea     out_0(PC),A0    ; Source-Code
                move.w  #25,D0          ; 26 Bytes
ini_2:          move.b  (A0)+,(A1)+     ; 1 Byte kopieren
                dbra    D0,ini_2        ; das ganze 26 mal
                dbra    D1,ini_1        ; und das dann 255 mal

;       * ...einziger Unterschied: die Registerwerte (aus volt)
                lea     volt(PC),A0     ; Da sind die Daten...
                lea     out_0(PC),A1    ; Dort der Code
                move.w  #255,D0         ; 256 mal...
ini_3:          move.w  (A0)+,D1        ; D1: 00.R8 R9.RA

                move.w  D1,D2           ; D2 zum Arbeiten
                andi.w  #$0F00,D2       ; D2: R8.00 00.00
                move.w  D2,4(A1)        ; Register 8 eintragen

                move.w  D1,D2           ; D2 ...
                lsl.w   #4,D2
                andi.w  #$0F00,D2       ; D2: R9.00 00.00
                move.w  D2,4+8(A1)      ; Register 9

                move.w  D1,D2           ; D2 ...
                ror.w   #8,D2
                andi.w  #$0F00,D2       ; D2: RA.00 00.00
                move.w  D2,4+16(A1)     ; Register 10 eintragen

                lea     26(A1),A1       ; Auf naechsten Tabellenwert
                dbra    D0,ini_3        ; 256 mal...

;       * Einige Variablen muessen initialisiert werden...
                lea     bothbuf(PC),A0  ; Adresse des Buffers
                move.l  A0,D0           ; muss auf einer 512-Byte Grenze beg!
                ori.w   #511,D0
                addq.l  #1,D0           ; so!
                move.l  D0,buf1         ; Das ist dann Buffer 1
                add.l   #512+2,D0       ; 256 Words + fillbuf-Branch
                move.l  D0,buf2         ; dahinter liegt Buffer 2

                move.w  #1024,-(SP)     ; Volume 100%
                bsr     _volume         ; Tabelle setzen
                addq.w  #2,SP           ;

                bsr.s   mwini           ; MICROWIRE (STE) initialisieren

                movem.l (SP)+,D1-D7/A1-A6 ; Stack->Registers
                rts

******************************************************************************
* mwini: Initialisiert MICROWIRE (Klangregler) Interface auf STE.
* Hat auf ST keine Wirkung
******************************************************************************

mwini:
                trap    #15             ; SUPERVISOR
                move    #$2700,SR       ; Voller Error
                move.l  #imret,$00000060.w ; Unechte Unterbrechung abfangen
                movem.l D0-A7,steregs   ; Ohne Stack, aber Stack merken
                move    USP,A0          ; UStack auch...
                move.l  A0,steusp
                move.l  $00000008.w,obusf ; Alle Fehler abfangen
                move.l  $0000000C.w,oadrf ; BUS und Adresse
                lea     merr(PC),A0
                move.l  A0,$00000008.w  ; Bus- und Adress-fehler ?
                move.l  A0,$0000000C.w  ; Kein Problem!

                movea.l #$FFFF8924,A0   ; A0: Mmask
                movea.l #$FFFF8922,A1   ; A1: Mdata
                lea     mwdata(PC),A2   ; A2: *Daten
                move.l  #2047,(A0)
                bsr.s   w100
mnext:          move.w  (A2)+,D0
                beq.s   merr
                move.w  D0,(A1)
                bsr.s   w100
                bra.s   mnext

merr:           move    #$2700,SR       ; Alles Stoppen
                move.l  obusf(PC),$00000008.w
                move.l  oadrf(PC),$0000000C.w
                movea.l steusp(PC),A0
                move    A0,USP
                movem.l steregs(PC),D0-A7
                move    #$0300,SR       ; USER Mode
                rts

w100:           move.w  #200,D0
wx1:            dbra    D0,wx1
                rts

steregs:        DS.L 16
steusp:         DC.L -1
obusf:          DC.L -1
oadrf:          DC.L -1

;       * Diese Daten werden an das MICROWIRE gesendet:
;       * Hoehen: - 3 dB, sonst volle Pulle
mwdata:         DC.W 1256,1363,1300,1164,1094,1025,0

******************************************************************************
*
* C: volume(int vol): Steuert die Lautstaerke (1024 = 100%)
*    Darf auch geaendert werden, solange Sample noch gespielt wird!
*
******************************************************************************

_volume::
                lea     (SP),A0
                movem.l D1-D7/A1-A6,-(SP) ; Registers->Stack
                move.w  4(A0),D2        ; D2: Volume-Wert
                ext.l   D2
                lsl.l   #6,D2           ; D2: 00 01 00 00
                moveq   #0,D3           ; D3: Summation

;       * conv_tab enthaelt die Branches zu den einzelnen Volume-Werten
                lea     conv_tab(PC),A0
                move.w  #255,D0         ; 256 Schleifen
vo_1:           swap    D3              ; Highword holen
                move.w  D3,D4
                swap    D3
                cmp.w   #255,D4
                ble.s   vo_2            ; Darf nur Leiser werden!
                move.w  #255,D4
vo_2:           mulu    #26,D4
                addq.w  #2,D4           ; Branch ist immer 2 Bytes weiter
                move.w  D4,(A0)+        ; Offset als Index eintragen...
                add.l   D2,D3           ; Naechster Schritt
                dbra    D0,vo_1         ; That's it!

                movem.l (SP)+,D1-D7/A1-A6 ; Stack->Registers
                rts

* initrap: installiert den TRAP #15 um schneller in den SUPERVISOR zu gelangen
*          und schaltet Tastenklick aus
initrap:                                ; Aufruf im SUPERVISOR
                lea     trap15(PC),A0
                move.l  A0,$000000BC.w

                bclr    #0,$00000484.w  ; Und Tastenklick OFF

                rts

trap15:         ori.w   #$2000,(SP)     ; USER->SUPERVISOR
                rte

******************************************************************************
* sound_on: Routine gibt den Sound aus, dazu muss er aber vorher abgesch.
*        worden sein (s_off)! Aufruf im USER Mode
******************************************************************************

sound_on:
                trap    #15
                move    #$2500,SR       ; Nur noch MFP

                move.b  #64,$FFFFFA17.w ; AEOI
                move.l  #$07007F00,$FFFF8800.w ;

                lea     entry(PC),A0    ; Timer A Vektor
                move.l  A0,$00000134.w  ; eintragen
                move.b  tdata+1(PC),$FFFFFA1F.w ; Timer A Data
                move.b  #1,$FFFFFA19.w  ; Timer A Control
                bset    #5,$FFFFFA07.w  ; Timer A Int. enable
                bset    #5,$FFFFFA13.w  ; Timer A Int. mask

                bclr    #5,$FFFFFA09.w  ; Timer C Int. disablen

                move    #$0300,SR       ; Interrupts AN->SOUND
                rts

******************************************************************************
* sound_off: Sound vorzeitig abschalten, Aufruf im USER Mode
******************************************************************************

sound_off:
                trap    #15             ; SUPERVISOR
                bsr.s   s_off

                movem.l buf1(PC),A0-A1  ; Bufferadressen holen
                move.w  #BR_FILL,512(A0) ; bra fill_buffer an's Ende
                move.w  #BR_FILL,512(A1) ; dto.

                move    #$0300,SR       ; USER,  IPL-Status 3
                rts

* s_off: Unabhaengige Subroutine, SUPERVISOR
s_off:
                move    #$2700,SR       ; Alles sperren
                move.l  #imret,$00000134.w
                clr.b   $FFFFFA19.w     ; Timer A Stop

                bset    #5,$FFFFFA09.w  ; Timer C Int. enable

                rts

imret:          rte                     ; evtl. kommt noch ein Interr.!

******************************************************************************
* done: Das war's, jetzt kannste den Sample abschalten
*       Aufruf aus INTERRUPT (Rte)!
******************************************************************************

done:           bsr.s   s_off           ; Alles aus
                rte

******************************************************************************
* fill_buf: Diese Routine schreibt 256 Words in den Ausgabepuffer
*           Aufruf aus INTERRUPT (Rte)!
******************************************************************************

fill_buf:
                move.l  buf1(PC),e_sm2+2 ; Den Buffer wechseln!

;       * Timing halten: Interrupt emulieren (Trick 17)
                pea     fi_1(PC)        ; Pseudo RÅcksprungadresse
                move.w  #$2500,-(SP)    ; Pseudo SR Register: Sub-Interrupt
                bra.s   entry
fi_1:
                movem.l D0-D1/A0-A2,-(SP) ; Register sichern (wg. Interrupt)
fi_2:           bsr.s   fill_b2         ; nach buf2 Fuellen
                movem.l (SP)+,D0-D1/A0-A2 ; Register wieder holen

                rte                     ; Sub-Interrupt fertig!

;       * Den Bereich buf2 fuellen waehrend buf1 (evtl.) gespielt wird
fill_b2:
                movem.l buf1(PC),A0-A1  ; A0/A1: BUF1/2
                exg     A0,A1
                movem.l A0-A1,buf1      ; A0(/A1): BUF2(/1)

                movea.l adr(PC),A1      ; A1: von hier die Samplewerte
                lea     conv_tab(PC),A2 ; A2: Liste der Branches

                move.l  size(PC),D1
                bmi.s   fi_4            ; <0: Da kommt nichts mehr, Ignor.!
                move.w  #255,D0         ; 256 Words in Tabelle
                sub.l   #256,D1
                move.l  D1,size         ; Noch zu spielende Anzahl merken
                bgt.s   fi_3            ; Noch was uebrig? -> Naechstes Mal
                add.w   #256,D1         ; D1 muss >= 0 sein!
                move.w  D1,D0
                add.w   D1,D1
                move.w  #BR_DINE,0(A0,D1.w) ; An's Ende einen Branch (ENDE)
                subq.w  #1,D0
                bmi.s   fi_4            ; <0: Da ist nix mehr!
;       * Fuellschleife: Rechnet Daten in Code (Branches um)
;       * etwa  52 Zyklen pro Byte
fi_3:           clr.w   D1              ; [4]
                move.b  (A1)+,D1        ; [8] Samplewert holen (8 Bit)
                add.w   D1,D1           ; [4] *2 = Tabellenindex bilden
                move.w  0(A2,D1.w),(A0)+ ;[20] Branch eintragen!
                dbra    D0,fi_3         ; [16] 256 mal
                move.l  A1,adr          ; Neuer Pointer merken
fi_4:           rts

******************************************************************************
* entry: wird vom Timer-A Interrupt aufgerufen. ACHTUNG: Selbstmodifizierender
*        Code! Der branch muss immer WORD sein!
*        Die Codeteile ab out_0 werden nur durch RAM-MODIFIKATION erreicht
*        und bewirken die Ausgabe eines einzelnen D-A-Wertes:
*        Ausgabe eines Wertes kostet ca. 188 Zyklen (ohne Berechnung)
******************************************************************************

entry:
e_sm2:          move.w  $FFFFFFFF,e_sm1+2 ; [28] Branch holen und patchen
                addq.w  #2,e_sm2+4      ; [12] Bytes weiter im Speicher!
e_sm1:          bra     *+1234          ; [12] Normalerweise: Buffer fuellen

out_0:
                move.l  #$08000000,$FFFF8800.w ; [24] Sound-Register 1
                move.l  #$09000000,$FFFF8800.w ; [24] Sound-Register 2
                move.l  #$0A000000,$FFFF8800.w ; [24] Sound-Register 3
                rte                     ; [64] Erledigt!

* Ab out_1: Uninitialisierte Daten

out_1:
;   hier wird der Code out0-1 noch 255 mal wiederholt (von initialisieren)
                DS.B 255*26
out_256:

conv_tab:
;   Anhand dieser Liste werden die Codeadressen der 256 Routinen berechnet
                DS.W 256

bothbuf:
;   Die Ausgabe-Buffer koennten sich ueberlappen (Word-Grenze!)
                DS.W 256*3+4            ; Bufferbereiche

BR_FILL         EQU fill_buf-2-e_sm1    ; Branch um Buffer zu fuellen
BR_DINE         EQU done-2-e_sm1        ; Branch wenn alles fertig

ende:
                END
