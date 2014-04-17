*****************************************************
* ***** LOCKSLEY, der Befreier des Lesekopfes ***** *
*     Direkter Zugriff auf den Floppycontroller     *
* Mit Schnittstelle nach auûen fÅr den Anschluû an  *
*           TED, BITTE EIN BIT und andere           *
*                                                   *
* Written & Ω 1987,1988 by Claus Brod,              *
*     Am Felsenkeller 2, 8772 Marktheidenfeld       *
* Doku: SCHEIBENKLEISTER, Kapitel 9                 *
* Version 1.8                                       *
*   6.6.87 alles noch mal von vorne                 *
*   7.6.87 die Hauptarbeit                          *
*   8.-11.6.87 Entwanzen                            *
*   12.6.87 ein paar Unterroutinen                  *
*   13.6.87 #@!?% Read Adr.                         *
*   14.-16.6.87 aufgerÑumt                          *
*   13.9.87 Rdadr wartet auf Index-IRQ              *
*   30.9.87 Experimente mit DRQ                     *
*   1.-5.10. RdAdr verbessert                       *
*   9.10. RdAdr liest jetzt von Trackanfang bis     *
*   Trackende; DMA-Puffer wird mit 3 RdAdrs geleert *
*   30.10. RdAdr zeigt erstes ungÅltiges ID-Feld mit*
*   gelîschtem Statusfeld an                        *
*   1.11 (V1.5): RdAdr prÅft Geschwindigkeit, um    *
*   sich ans Laufwerk anzupassen                    *
*   27.12. (V1.6): Abbruchbedingung in warten_auf...*
*   geÑndert; Kommentare ediert                     *
*   12.1.88: RdAdr schreibt ZÑhler ins Statusfeld   *
*   Struktur des Statusfeldes:                      *
*   ZÑhler.W    LÑnge einer Umdrehung               *
*   Status.W    Status fÅr erstes ID-Feld           *
*   ZÑhler.W    ZÑhler bei erstem ID-Feld           *
*     .                                             *
*     .                                             *
*     .                                             *
*   ZÑhler.W    ZÑhler bei letztem ID-Feld          *
*   00.W        Abschluûkennzeichen                 *
*   15.2.88: FORCE IRQ nach allen DMA-Operationen   *
*   26.12.88 (V1.8): Optimierungen, Select mit ein- *
*   gebunden; Read/write multiple von Read/Write    *
*   getrennt; viele kleine Verbesserungen           *
*   (herzlichen Dank an JÅrgen Stessun!)            *
*   V1.9: Kritische Zeitschleife entfernt           *
*   Umgestellt auf MADMAC                           *
*****************************************************

*************************
* Ein paar Definitionen fÅr den langen Weg
*************************

mfp             EQU $FFFFFA01   ; Adresse des MFP68901 fÅrs Polling

daccess         EQU $FFFF8604   ; DMA-Controller, FDC-Zugriff oder SektorzÑhler
dmodus          EQU $FFFF8606   ; DMA-Controller, Modus einstellen
dlow            EQU $FFFF860D   ; DMA-Controller, öbertragungsstart Lowbyte
dmid            EQU $FFFF860B   ; DMA-Controller, Åbertragungsstart Midbyte
dhigh           EQU $FFFF8609   ; DMA-Controller, Åbertragungsstart Highbyte
time            EQU 400         ; Timeout-Konstante
snd             EQU $FFFF8800   ; Soundchip
sndwrt          EQU $FFFF8802   ; Output-Register

hz_200          EQU $04BA
*************************
* Der Sprung ins Ungewisse
*************************
start:
                bra.s   main            ; Sprung zum Programmanfang

*************************
* Ein/Ausgabefeld zur ParameterÅbergabe
*************************

opcode:         DC.W 0          ; Opcode des Controllerbefehls  2(a6)
track:          DC.W 0          ; Tracknummer                   4(a6)
sector:         DC.W 0          ; Sektornummer                  6(a6)
count:          DC.W 0          ; in:zu Åbertragende Bytes/ID-Felder etc.
*                                 out:Åbertragene Bytes         8(a6)
buffer1:        DC.L 0          ; Adresse des ersten Puffers fÅr
*                                 Track-, Sektor-, ID-Daten    10(a6)
buffer2:        DC.L 0          ; Adresse des Reservepuffers   14(a6)
fst:            DC.W 0          ; Status des Controllers       18(a6)
dst:            DC.W 0          ; Status der DMA-öbertragung   20(a6)
dstart:         DC.L 0          ; Start der DMA-öbertragung    22(a6)
dend:           DC.L 0          ; Ende der DMA-öbertragung     26(a6)
timeout:        DC.W 0          ; Timeoutflag                  30(a6)
stk:            DC.L 0          ; Puffer fÅr Stackpointer      32(a6)
dflag:          DC.W 0          ; DMA-Flag                     36(a6)
laufwerk:       DC.W 8          ; Laufwerk+Seite/Extended Mode 38(a6)
parm:           DC.L 0          ; Reservefeld fÅr Extended Mode 40(a6)
temp:           DC.L 0          ; Reservefeld                  44(a6)
modus:          DC.L 0          ; Modus-Langwort               48(a6)
*                               ; reserviert, auf 0 setzen!

***************************
* Hauptverteilerroutine
***************************

main:
                movem.l D0-A6,-(SP)     ; Register verschwinden lassen
                moveq   #0,D0           ; Userstack wird Supervisorstack
                bsr.s   super           ; Supervisormodus an
                lea     start(PC),A6    ; a6->Prg-Anfang
                move.l  D0,32(A6)       ; Stackpointer retten

                st      $043E.w         ; Floppy-VBL sperren
                cmpi.w  #8,38(A6)       ; Extended Mode?
                bmi.s   noextmode       ; nein
                bsr.s   select          ; zur Select-Routine
                bra.s   main3           ; und raus
noextmode:
                tst.w   38(A6)          ; Laufwerk vorgegeben?
                bne.s   main2           ; wenn ja, dann weiter
                bsr.s   deselect        ; sonst Laufwerke ausschalten
                bra.s   main3           ; und raus

main2:
                bsr.s   select          ; Laufwerk selektieren
                move.w  opcode(PC),D6   ; FDC-Befehl holen
                clr.w   36(A6)          ; DMA-Flag initialisieren
                clr.w   30(A6)          ; Timeout-Flag initialisieren
                bsr     analyze         ; Befehl analysieren und ausfÅhren
main3:
                sf      $043E.w         ; Floppy-VBL wieder erlauben
                move.l  32(A6),D0       ; Stackpointer holen
                bsr.s   super           ; Supervisormodus aus (schaaade...)
                movem.l (SP)+,D0-A6     ; Register wieder holen
                rts                     ; und raus (ade!)

*****************************
* super: Schaltet vom Usermode
* in der Supervisormode und umgekehrt
* öbergabe des Stackpointers in d0
*****************************
super:
                move.l  D0,-(SP)        ; Stackpointer auf Stack
                move.w  #$20,-(SP)      ; SUPER
                trap    #1              ; im GEMDOS
                addq.l  #6,SP           ; Stack korrigieren
                rts

**********************
* deselect: Selektierroutine
**********************
deselect:
                move.w  #$80,dmodus.w   ; Statusregister auswÑhlen
motor:
                move.w  daccess.w,D1    ; Status lesen
                btst    #7,D1           ; lÑuft der Motor noch?
                bne.s   motor           ; ja, dann warten
select:
                move.w  laufwerk(PC),D7 ; Laufwerksnummer holen
                cmp.b   #8,D7           ; Laufwerkscode grîûer als 7?
                bge     extend          ; ja, extended mode
                eori.b  #7,D7           ; Bits invertieren
                and.b   #7,D7           ; und ausmaskieren
                move    SR,-(SP)        ; Status retten
                ori     #$0700,SR       ; IRQs aus
                move.b  #14,snd.w       ; Port A wÑhlen
                move.b  snd.w,D0        ; Port A lesen
                and.b   #$F8,D0         ; ausmaskieren
                or.b    D0,D7           ; neue Seite/neues Laufwerk setzen
                move.b  D7,sndwrt.w     ; in Port A schreiben
                move    (SP)+,SR        ; Status restaurieren
                rts                     ; und raus

******************************
* wrfdc: Byte in d7 an den Controller
* schicken
******************************
wrfdc:
                bsr.s   waitl           ; kurz warten
                move.w  D7,daccess.w    ; d7 ins Access-Register des DMA-Chips
                bra.s   waitl           ; kurz warten

******************************
* rdfdc: Controller auslesen nach d7
******************************
rdfdc:
                bsr.s   waitl           ; kurz warten
                move.w  daccess.w,D7

waitl:
                move.l  D1,-(SP)        ; d1 retten
                moveq   #25,D1          ; kurze Wartezeit
                bsr.s   as_time_goes_by
                move.l  (SP)+,D1
                rts

as_time_goes_by:
                dbra    D1,as_time_goes_by
                rts

******************************
* warten_auf_godot : Wartet auf das IRQ-Signal
* des FDC
******************************
warten_auf_godot:
                move.w  daccess.w,D7
                btst    #0,D7           ; BUSY gesetzt?
                beq.s   warten_auf_godot ; nein, Moment noch

                move.l  #time,D7        ; Konstante fÅr Timeout
                add.l   hz_200.w,D7
poll:
                btst    #5,mfp.w        ; IRQ am MFP?
                beq.s   fix_und_fertig  ; jawoll, Kommando ist ausgefÅhrt
                cmp.l   hz_200.w,D7     ; ZÑhler schon soweit?
                beq.s   fix_und_fertig  ; nein, weiter
                tst.w   36(A6)          ; DMA aktiv?
                beq.s   poll            ; nein, zum Polling
                bsr.s   getdma          ; DMA-Adresse nach d0 holen
                sub.l   dend(PC),D0     ; Endadresse abziehen
                bmi.s   poll            ; Noch nicht erreicht, weiter testen

fix_und_fertig:
                clr.w   36(A6)          ; DMA-Flag lîschen
                move.w  daccess.w,18(A6) ; Controllerstatus retten
                bra     resetfdc        ; FDC-Reset auslîsen

***************************
* Timeout-Konstante ist abgelaufen
***************************
game_over:
                move.w  #1,30(A6)       ; Timeout-Flag setzen
                bra.s   fix_und_fertig  ; Status lesen, in fst ablegen und FDC-Reset

***************************
* status: Status und Bytezahl lesen
***************************
status:
                move.w  D3,dmodus.w     ; SektorzÑhler selektieren
                move.w  dmodus.w,20(A6) ; DMA-Status lesen
                bsr.s   getdma          ; DMA-Adresse nach d0 holen
                move.l  D0,26(A6)       ; Endadresse
                sub.l   dstart(PC),D0   ; minus Start
                move.w  D0,8(A6)        ; =Anzahl der Åbertragenen Bytes
                rts

****************************
* getdma: DMA-Adresse nach d0 lesen
****************************
getdma:
                moveq   #0,D0           ; d0 lîschen
                move.b  dhigh.w,D0      ; DMA-High holen
                lsl.l   #8,D0           ; um ein Byte schieben
                move.b  dmid.w,D0       ; DMA-Mid
                lsl.l   #8,D0           ; um ein Byte schieben
                move.b  dlow.w,D0       ; DMA-Low
                rts

****************************
* dma: dma setzen (Spiegelbild zu status)
****************************
dma:
                move.l  D7,22(A6)       ; Startadresse ablegen
                move.b  D7,dlow.w       ; Lowbyte
                lsr.l   #8,D7           ; um ein Byte schieben
                move.b  D7,dmid.w       ; Midbyte
                lsr.l   #8,D7           ; um ein Byte schieben
                move.b  D7,dhigh.w      ; Highbyte
                move.l  dstart(PC),D7   ; Startadresse holen
                moveq   #0,D0           ; d0 lîschen
                move.w  count(PC),D0    ; Bytecounter nach d0
                add.l   D0,D7           ; Addieren
                move.l  D7,26(A6)       ; Endadresse ablegen
                rts

*****************************
* analyze: Analysiert grob, welche Art von
* Befehl vorliegt
* und verteilt entsprechend
* in: d6.w Opcode
*****************************
analyze:
                move.w  D6,D7           ; Opcode retten
                move.w  D6,D5           ; gleich nochmal
                btst    #7,D6           ; Bit 7 testen
                bne.s   typii           ; kein Typ-I-Befehl
                and.b   #$F0,D6         ; obere 4 Bits ausmaskieren
                cmp.b   #16,D6          ; SEEK-Befehl?
                beq     such_hasso      ; jawoll
                bne     step_dance      ; kein Seek, aber Typ-I

typii:
                btst    #6,D6           ; Bit 6 testen
                bne.s   typiii          ; kein Typ-II-Befehl
                btst    #5,D6           ; Bit 5 testen
                beq.s   rdsector        ; gelîscht, also Read-Sector-Befehl
                bne.s   wrsector        ; Write-Sector-Befehl

typiii:
                and.b   #$F0,D6         ; obere 4 Bits ausmaskieren
                cmp.b   #$C0,D6         ; Read Adress?
                beq     rdadr           ; jawoll
                cmp.b   #$E0,D6         ; Read Track?
                beq.s   rdtrk           ; jawoll
                cmp.b   #$F0,D6         ; Write Track?
                beq.s   wrtrk           ; jawoll
*                               * alles andere ist Force Interrupt

**************************
* irq: Unterbricht den Controller
**************************
irq:
                bsr     wrfdc           ; d7 an den Controller
                move.w  #250,D1         ; 250 SchleifendurchlÑufe
                bra     as_time_goes_by ; kurz warten
resetfdc:
                move.b  #$D0,D7         ; FORCE IRQ
                bra.s   irq             ; FDC zurÅcksetzen

*****************************
* rdsector: Liest einen Sektor oder
* gleich einen ganzen Haufen davon
*****************************
rdsector:
                bsr.s   rdinit          ; DMA initialisieren
                btst    #4,D5           ; Read Multiple?
                bne.s   rdmultiple      ; jawoll
                clr.w   36(A6)          ; DMA-Flag lîschen (???)
                move.w  #1,D7           ; 1 Sektor
                bsr     wrfdc           ; in DMA-SektorzÑhler schreiben
rdmultiple:
                move.w  #$84,dmodus.w   ; Sektorregister
                move.w  sector(PC),D7   ; Sektor schreiben
                bsr     wrfdc           ; d7 an FDC
exe1:
                move.w  #$80,dmodus.w   ; Kommandoregister
exe:
                move.w  D5,D7           ; Kommando von d5 nach d7
                bsr     wrfdc           ; d7 an FDC
                bsr     warten_auf_godot ; Ende des Kommandos abwarten
                bra     status          ; Status lesen

*****************************
* rdtrk: Track lesen
*****************************
rdtrk:
                bsr.s   rdinit          ; DMA initialisieren
                bra.s   exe1

*****************************
* wrsector: Sektor schreiben
*****************************
wrsector:
                bsr.s   wrinit          ; DMA initialisieren
                btst    #4,D5           ; Write multiple?
                bne.s   wrmultiple      ; jawoll
                clr.w   36(A6)          ; DMA-Flag lîschen (???)
                move.w  #1,D7           ; 1 Sektor
                bsr     wrfdc           ; in DMA-SektorzÑhler schreiben
wrmultiple:
                move.w  #$0184,dmodus.w ; Sektorregister
                move.w  sector(PC),D7   ; Sektor in d7
                bsr     wrfdc           ; an Controller
                bra.s   wrtrack2        ; wann geht's weiter? Gleich geht's weiter!

*****************************
* wrtrk: Track schreiben
*****************************
wrtrk:
                bsr.s   wrinit          ; DMA initialisieren
wrtrack2:
                move.w  #$0180,dmodus.w ; Kommandoregister
                bra.s   exe             ; Befehl ausfÅhren

*****************************
* rdinit: Bereitet DMA zum Lesen vor
*****************************
rdinit:
                bsr.s   fillbuf         ; DMA-Adresse setzen
                bsr.s   toggle          ; DMA-Status lîschen
                bra.s   wrinit2         ; Sektorregister

fillbuf:
                move.l  buffer1(PC),D7  ; Pufferadresse in d7
                bsr     dma             ; als DMA-Adresse
                move.w  #1,36(A6)       ; DMA-Flag setzen
                rts

*****************************
* wrinit: DMA fÅr Schreiben vorbereiten
*****************************
wrinit:
                bsr.s   fillbuf         ; DMA-Adresse setzen
                move.w  #$0190,D3       ; d3 vorbereiten
                move.w  D3,dmodus.w     ; Status lîschen
                move.w  #$90,dmodus.w
                move.w  D3,dmodus.w
wrinit2:
                move.w  #31,D7          ; maximal 31 Blîcke
                bra     wrfdc           ; in DMA-Sektorregister schreiben

*****************************
* step_dance: einheitliche Routine fÅr step,
* step-in, step-out, restore
*****************************
step_dance:
                bra.s   exe1            ; Befehl ausfÅhren

*****************************
* such_hasso: Seek-Befehl
*****************************
such_hasso:
                move.w  #$86,dmodus.w   ; Datenregister auswÑhlen
                move.w  track(PC),D7    ; Tracknummer holen
                bsr     wrfdc           ; Byte in d7 an FDC
                bra     exe1            ; Befehl ausfÅhren

*****************************
* toggle: DMA-Status lîschen
*****************************
toggle:
                move.w  #$90,D3         ; d3 vorbereiten
                move.w  D3,dmodus.w     ; DMA-Status lîschen
                move.w  #$0190,dmodus.w
                move.w  D3,dmodus.w     ; DMA-Sektorregister selektieren
                rts

*****************************
* rdadr: Adreûfeld lesen
*****************************
rdadr:
                clr.w   36(A6)          ; DMA-Flag lîschen
                move.l  buffer1(PC),D7  ; Adresse des Puffers holen
                movea.l buffer2(PC),A3  ; Adresse des Reservepuffers
                bsr     dma             ; DMA initialisieren
                bsr.s   toggle          ; Status lîschen
                moveq   #1,D7           ; Maximal 1 Sektor
                bsr     wrfdc           ; d7 an FDC (DMA)
                move.w  count(PC),D2    ; Wieviele ID-Felder?

                move    SR,-(SP)        ; Status retten
                ori     #$0700,SR       ; IRQs aus

                move.w  #$80,dmodus.w   ; Kommandoregister

                moveq   #4,D1           ; 5mal (minus eins fÅr dbra)
umlauf:
                bsr.s   sendirq
index:
                btst    #5,mfp.w        ; IRQ?
                bne.s   index           ; nein
                dbra    D1,umlauf       ; weiter auf Touren bringen

                bsr.s   sendirq
                moveq   #0,D1           ; ZÑhler initialisieren
index2:
                addq.w  #1,D1           ; ZÑhler plus eins
                beq.s   schluss         ; nur fÅr Timing
                btst    #5,mfp.w
                bne.s   index2

                move.w  D1,(A3)+        ; Gesamt-Timer
nochnid:
                move.w  D5,daccess.w    ; eigentliches Kommando schreiben
                subq.w  #1,D1
                beq.s   schluss

id:
                subq.w  #1,D1           ; ZÑhler kleiner
                beq.s   schluss         ; gleich 0, dann Schluû
                btst    #5,mfp.w
                bne.s   id

                move.w  daccess.w,(A3)+ ; Status schreiben
                move.w  D1,(A3)+        ; ZÑhler schreiben
                subq.w  #1,D1           ; ZÑhler minus eins
                beq.s   schluss         ; abgelaufen, dann Ende
                dbra    D2,nochnid      ; noch ein Adreûfeld

schluss:
                bsr     resetfdc        ; FORCE IRQ

                move.w  #2,D1           ; Schleife dreimal durchlaufen
                move.l  #0,(A3)+        ; Ende der gÅltigen Adreûfelder

emptydma:
                move.w  #$C0,D7         ; Rd Adress
                bsr     wrfdc           ; an FDC schicken
emptylp:
                btst    #5,mfp.w        ; Kommando beendet?
                bne.s   emptylp         ; nein, warten
                move.l  #0,(A3)+        ; Status und ZÑhler
                dbra    D1,emptydma     ; nÑchster Dummy-Read

                bsr     resetfdc        ; FORCE IRQ

                move    (SP)+,SR        ; Prozessorstatus holen
                bra     status          ; und zum Status

****************************
* sendirq: Schickt Indexirq, liest Status
****************************
sendirq:
                move.w  #$D4,D7         ; Index-IRQ
                bsr     wrfdc           ; abschicken
                move.w  daccess.w,D0    ; Status lesen und IRQ lîschen
                nop
                nop
                rts

********************************
* Extended-Teil
********************************
extend:
                lea     main3(PC),A0    ; hier geht's spÑter weiter
                move.l  A0,(SP)         ; auf den Stack damit
                cmp.b   #8,D7           ; Register lesen?
                beq.s   regread         ; jawoll
                cmp.b   #9,D7           ; Register schreiben?
                beq.s   regwrite        ; jawoll
                cmp.b   #10,D7          ; DMA-Status lesen?
                bne.s   raus            ; nein, dann ohne Ergebnis raus

**************************
* dmastatus: DMA-Status lesen
**************************
dmastatus:
                move.w  #$90,dmodus.w   ; DMA-Sektorregister anwÑhlen
                move.w  dmodus.w,44(A6) ; DMA-Status nach temp retten
raus:
                rts                     ; raus hier

**************************
* regread: In parm angegebenes Register
* lesen und in temp ablegen
**************************
regread:
                move.w  parm(PC),dmodus.w ; Register wÑhlen
                bsr     rdfdc           ; FDC/DMA-Register lesen
                move.w  D7,44(A6)       ; Registerinhalt in temp schreiben
                rts

***************************
* regwrite: In parm angegebenes Register
* mit dem Wert aus temp beschreiben
***************************
regwrite:
                move.w  temp(PC),D7     ; Wert holen
                and.w   #$FF,D7         ; nur unteres Byte beachten
                move.w  parm(PC),dmodus.w ; Register auswÑhlen
                bra     wrfdc           ; d7 zum FDC schicken
                END
