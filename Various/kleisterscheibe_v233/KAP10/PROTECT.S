*************************
* PROTECT.S: Kopierschutz auf Spur 41
* Aus SCHEIBENKLEISTER, dem etwas anderen Floppybuch
* (C) 1988 by Claus Brod, Am Felsenkeller 2,
*             D-8772 Marktheidenfeld, 09391-3206
*
* 24.6.91: Angepaût an Turboass
*          Seek jetzt mit Verify-Bit
**************************

mfp             EQU $FFFFFA01   ; GPIP-Adresse
daccess         EQU $FFFF8604   ; DMA-Fensterregister
dmode           EQU $FFFF8606   ; DMA-Modusregister
dlow            EQU $FFFF860D   ; DMA-Startadresse, Lowbyte
dmid            EQU $FFFF860B   ; DMA-Startadresse, Midbyte
dhigh           EQU $FFFF8609   ; DMA-Startadresse, Highbyte
time            EQU 400         ; Timeout-Konstante
snd             EQU $FFFF8800   ; Auswahlregister des Soundchips
sndwrt          EQU $FFFF8802   ; I/O-Register des Soundchips

hz_200          EQU $04BA

*************************
* Sprung ins Ungewisse...
*************************
                bra.s   main            ; zum Programmanfang springen

*************************
* Parameterfeld fÅr Ein/Ausgabe
*************************
mode:           DC.L 0          ; 0 = Track 41 lesen, 1 = schreiben
buf:            DC.L 0          ; Pufferadresse

***************************
* main: Delegiert die Verantwortung
***************************
main:
                movem.l D0-A6,-(SP)
                clr.l   -(SP)           ; Supervisormodus an
                move.w  #32,-(SP)       ; SUPER
                trap    #1
                addq.l  #6,SP
                move.l  D0,-(SP)        ; SP gleich retten

                move.l  mode(PC),D6     ; Modus holen
                st      $043E.w         ; Floppy-VBL abblocken
                tst.l   D6              ; read track?
                beq     rdtrack         ; jawohl
                cmp.l   #1,D6           ; write track?
                beq     wrtrack         ; bitte sehr bitte gleich

exitus:
                sf      $043E.w         ; Floppy-VBL freigeben
                move.w  #32,-(SP)       ; SUPER: zurÅck in Usermodus
                trap    #1
                addq.l  #6,SP
                movem.l (SP)+,D0-A6     ; Register holen
                rts                     ; adios amor

******************************
* wrfdc: d7.b an Controller schicken
******************************
wrfdc:
                move.w  #30,D1          ; ZÑhler=30
                bsr.s   as_time_goes_by ; wie doch die Zeit vergeht...
                move.w  D7,daccess.w    ; d7 ins DMA-Fensterregister
                move.w  #30,D1          ; ZÑhler=30

******************************
* as_time_goes_by: d1.w Schleifen drehen
******************************
as_time_goes_by:
                dbra    D1,as_time_goes_by ; Looping (huiii...)
                rts                     ; zurÅck in die Zukunft
; (wo wir hinfahren, brauchen wir keine...
;  Straûen...)
******************************
* wait_until_dawn : auf FDC-IRQ warten
******************************
wait_until_dawn:
                move.w  daccess.w,D1
                btst    #0,D1
                beq.s   wait_until_dawn

                move.l  #time,D1        ; Timeout-Konstante
                add.l   hz_200.w,D1
poll:
                btst    #5,mfp.w        ; IRQ am MFP gemeldet?
                beq.s   ready           ; ja, Kommando beendet
                cmp.l   hz_200.w,D1
                bne.s   poll
; weiter zum IRQ

**************************
* irq: FDC abwÅrgen
**************************
irq:
                move.b  #$D0,D7         ; FORCE IRQ
                bsr.s   wrfdc           ; d7 an FDC
                move.w  #250,D1         ; 250 DurchlÑufe
                bra.s   as_time_goes_by ; Geduld, Dam'n'Herrn!

***************************
* ready: DMA-Transfer oder FDC fertig
***************************
ready:
                move.w  #$0180,dmode.w  ; Kommandoregister
                move.w  #30,D1          ; kurz warten
                bsr.s   as_time_goes_by
                move.w  daccess.w,D0    ; FDC-Status holen
                move.w  #30,D1          ; kurz warten
                bra.s   as_time_goes_by

****************************
* dma: DMA-Startadresse setzen; IN: d7 Startadresse
****************************
dma:
                move.b  D7,dlow.w       ; Lowbyte
                lsr.l   #8,D7           ; ein Byte weitershiften
                move.b  D7,dmid.w       ; Midbyte
                lsr.l   #8,D7           ; ein Byte weitershiften
                move.b  D7,dhigh.w      ; Highbyte
                rts

*****************************
* rdtrack: Liest Spur 41 ein (Laufwerk A, Seite 0)
*****************************
rdtrack:
                moveq   #2,D4           ; Laufwerk A, Seite 0
                bsr     do_select       ; selektieren
                move.w  #41,D4          ; Track 41
                bsr.s   seek_it         ; suchen
                bsr.s   rdtrk           ; und einlesen
                clr.w   D4              ; Laufwerk deselektieren
                bsr     do_select
                bra     exitus          ; heim zu Mami

*****************************
* rdtrk: Track einlesen
*****************************
rdtrk:
                move.l  buf(PC),D7      ; Adresse des Trackpuffers
                bsr.s   dma             ; DMA-Start setzen
                bsr.s   toggle          ; DMA-Status lîschen
                move.w  #14,D7          ; 14 Sektoren
                bsr     wrfdc           ; d7 an FDC
                move.w  #$80,dmode.w    ; Kommandoregister

                move.w  #$E0,D7         ; RdTrack-Befehl
ab_und_aus:
                bsr     wrfdc           ; d7 an FDC
                bra     wait_until_dawn ; auf Kommandoende warten

*****************************
* wrtrack: Track 41 schreiben (Laufwerk A, Seite 0)
*****************************
wrtrack:
                moveq   #2,D4           ; Laufwerk A, Seite 0
                bsr.s   do_select       ; selektieren
                move.w  #41,D4          ; Track 41
                bsr.s   seek_it         ; suchen

                bsr.s   wrtrk           ; und schreiben
                clr.w   D4              ; Laufwerk deselektieren
                bsr.s   do_select
                bra     exitus          ; don't leave me this way...

*****************************
* wrtrk: Track schreiben
*****************************
wrtrk:
                move.l  buf(PC),D7      ; Trackpuffer-Adresse nach d7
                bsr.s   dma             ; DMA-Start setzen

                move.w  #$0190,dmode.w  ; R/W-Klapperstorch lîscht DMA-Status
                move.w  #$90,dmode.w    ; und DMA-Puffer und stÑrkt Herz und Kreislauf
                move.w  #$0190,dmode.w  ; DMA-SektorzÑhler selektieren
                move.w  #$1F,D7         ; 31 Sektoren (schîn wÑr's)
                bsr     wrfdc           ; d7 an FDC
                move.w  #$0180,dmode.w  ; Kommandoregister auswÑhlen

                move.w  #$F0,D7         ; WriteTrack-Befehl
                bra.s   ab_und_aus      ; d7 an FDC, auf Ende warten

*****************************
* seek_it: Track in d4 suchen
*****************************
seek_it:
                move.w  #$86,dmode.w    ; Datenregister auswÑhlen
                move.w  D4,D7           ; Tracknummer
                bsr     wrfdc           ; d7 an FDC
                move.w  #$80,dmode.w    ; Kommandoregister
                move.w  #$15,D7         ; Seek-Befehl
                bra.s   ab_und_aus      ; d7 an FDC, auf Ende warten

****************************
* toggle: R/W-Klappern, lîscht DMA-Status
*         und DMA-Puffer
****************************
toggle:
                move.w  #$90,dmode.w
                move.w  #$0190,dmode.w
                move.w  #$90,dmode.w    ; DMA-SektorzÑhler selektieren
                rts

*****************************
* do_select; IN: d4 Laufwerksnummer (2=A, 4=B, Seitennummer in Bit 0)
*****************************
do_select:
                movem.l D0-A6,-(SP)     ; Register retten
                move.w  D4,D7           ; Laufwerksnummer
                bne.s   mach_mal        ; gleich 0?
                move.w  #$80,dmode.w    ; Statusregister
motor:
                move.w  daccess.w,D1    ; FDC-Status holen
                btst    #7,D1           ; Motor noch an?
                bne.s   motor           ; yessir
mach_mal:
                eori.b  #7,D7           ; Bits invertieren
                and.b   #7,D7           ; und ausmaskieren
                move    SR,-(SP)        ; Prozessorstatus retten
                ori     #$0700,SR       ; IRQs aus
                move.b  #14,snd.w       ; Port A auswÑhlen
                move.b  snd.w,D0        ; Port A lesen
                and.b   #$F8,D0         ; unterste 3 Bits ausmaskieren
                or.b    D0,D7           ; neue Selektion
                move.b  D7,sndwrt.w     ; in Port A schreiben
                move    (SP)+,SR        ; Prozessorstatus holen
                movem.l (SP)+,D0-A6     ; Register holen
                rts                     ; laû mich in Ruhe...
                END
