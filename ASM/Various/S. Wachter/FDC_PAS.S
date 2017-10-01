* N≈tzliche Routinen zur direkten Programmierung des FDC von S. Wachter
*
* Pascal-Version

* Initialisierung und Beendigung des Moduls durch:

         xdef     INITDISK          * Diskettenzugriff vorbereiten
         xdef     EXITDISK          * Zugriffe beenden

* Momentan implementiere FDC-Befehle:

         xdef     READSECT          * Lese Sektor
         xdef     WRITSECT          * Schreibe Sektor
         xdef     READTRAK          * Lese komplette Spur ein
         xdef     WRITTRAK          * Formatiere eine Spur

* Routine zum Setzen des Laufwerks

         xdef     LAUFWERK          * Laufwerk setzen

mxtrklen equ      13*512            * Maximal 6656 Bytes auf einer Spur

flock    equ      $43e              * Zum Sperren der Floppy-VBL-Routine

fdc_reg  equ      $ff8604           * Registerzugriff
dma_mode equ      $ff8606           * DMA Modus-Register
dma_low  equ      $ff860d           * DMA Adress-Register
dma_mid  equ      $ff860b           * "   "
dma_hig  equ      $ff8609           * "   "
psg_rsel equ      $ff8800           * Sound-Chip Registerauswahl
psg_read equ      $ff8800           * Register auslesen
psg_writ equ      $ff8802           * Register beschreiben
gpip     equ      $fffa01           * MFP Parallelport

         .text

INITDISK bsr      initdisk
         rts
EXITDISK bsr      exitdisk
         rts
READSECT move.l   (sp)+,a3          * Returnadresse merken
         move.l   (sp)+,a2          * Adresse der Pascalvariablen 'count'
         move.l   (sp)+,a1          * Adresse der Pascalvariablen 'status'
         move.l   (sp)+,a0          * Pufferadresse
         move.w   (sp)+,d2          * Sektor
         move.w   (sp)+,d1          * Spur
         move.w   (sp)+,d0          * Seite
         move.l   a3,-(sp)          * Returnadresse auf Stack legen
         movem.l  a1-a2,-(sp)
         bsr      readsect          * Floppyroutine aufrufen
         movem.l  (sp)+,a1-a2
         move.w   d0,(a1)           * Status in Pascalvariable ≈bertragen
         move.w   d1,(a2)           * Count  in Pascalvariable ≈bertragen
         rts                        * Zur≈ck ins Pascalprogramm
WRITSECT move.l   (sp)+,a3          * Alles wie bei READSECT
         move.l   (sp)+,a2
         move.l   (sp)+,a1
         move.l   (sp)+,a0
         move.w   (sp)+,d2
         move.w   (sp)+,d1
         move.w   (sp)+,d0
         move.l   a3,-(sp)
         movem.l  a1-a2,-(sp)
         bsr      writsect
         movem.l  (sp)+,a1-a2
         move.w   d0,(a1)
         move.w   d1,(a2)
         rts
READTRAK move.l   (sp)+,a3          * Alles wie oben nur keine Sektornummer
         move.l   (sp)+,a2
         move.l   (sp)+,a1
         move.l   (sp)+,a0
         move.w   (sp)+,d1
         move.w   (sp)+,d0
         move.l   a3,-(sp)
         movem.l  a1-a2,-(sp)
         bsr      readtrak
         movem.l  (sp)+,a1-a2
         move.w   d0,(a1)
         move.w   d1,(a2)
         rts
WRITTRAK move.l   (sp)+,a3          * Alles wie bei READTRAK
         move.l   (sp)+,a2
         move.l   (sp)+,a1
         move.l   (sp)+,a0
         move.w   (sp)+,d1
         move.w   (sp)+,d0
         move.l   a3,-(sp)
         movem.l  a1-a2,-(sp)
         bsr      writtrak
         movem.l  (sp)+,a1-a2
         move.w   d0,(a1)
         move.w   d1,(a2)
         rts
LAUFWERK move.l   (sp)+,a0          * Returnadresse merken
         move.w   (sp)+,d0          * Laufwerksnummer vom Stack holen
         move.b   d0,laufwerk       *  und eintragen
         move.l   a0,-(sp)          * Returnadresse auf Stack legen
         rts                        *  und zur≈ck

readsect bsr      service1          * Floppyoperation vorbereiten
         moveq    #3,d0             * Maximal 3*512 Bytes ≈bertragen
         bsr      pdmaread          * DMA-Controller f≈r Lesen programmieren
         move.w   #$84,dma_mode     * FDC-Sektorregister w—hlen
         move.w   sektor,fdc_reg    * Sektornummer eintragen
         move.w   #$80,dma_mode     * FDC-Befehlsregister w—hlen
         move.w   #$80,fdc_reg      * Befehl geben
         bsr      service2          * Floppyoperation beenden
         rts

writsect bsr      service1          * Floppyoperation vorbereiten
         moveq    #3,d0             * Maximal 3*512 Bytes ≈bertragen
         bsr      pdmawrit          * DMA-Controller f≈r Schreiben progr.
         move.w   #$184,dma_mode    * FDC-Sektorregister w—hlen
         move.w   sektor,fdc_reg    * Sektornummer eintragen
         move.w   #$180,dma_mode    * FDC-Befehlsregister w—hlen
         move.w   #$a0,fdc_reg      * Befehl geben
         bsr      service2          * Floppyoperation beenden
         rts

readtrak bsr      service1          * Floppyoperation vorbereiten
         moveq    #mxtrklen/512,d0  * Maximale Trackl—nge
         bsr      pdmaread          * DMA-Controller f≈r Lesen programmieren
         move.w   #$80,dma_mode     * FDC-Befehlsregister w—hlen
         move.w   #$e0,fdc_reg      * Befehl geben
         bsr      service2          * Floppyoperation beenden
         rts

writtrak bsr      service1          * Floppyoperation vorbereiten
         moveq    #mxtrklen/512,d0  * Maximale Trackl—nge
         bsr      pdmawrit          * DMA-Controller f≈r Schreiben progr.
         move.w   #$180,dma_mode    * FDC-Befehlsregister w—hlen
         move.w   #$f0,fdc_reg      * Befehl geben
         bsr      service2          * Floppyoperation beenden
         rts

* Kopf auf gew≈nschte Spur r≈cken

seek_spr move.w   #$86,dma_mode     * FDC-Datenregister w—hlen
         move.w   spur,fdc_reg      * Spurnummer eintragen
         move.l   dctadr,a0         * Adresse der DCT1
         tst.b    laufwerk          * Die Eintragung f≈r das Laufwerk B
         beq      seek_sp1          *  beginnt 4 Bytes nach der Eintragung
         addq.l   #4,a0             *  f≈r das Laufwerk A
seek_sp1 move.w   #$82,dma_mode     * FDC-Spurregister w—hlen
         move.w   (a0),fdc_reg      * Momentane Spurnummer an FDC geben
         move.w   spur,(a0)         * Zielspurnummer in DCTx eintragen
         move.w   #$80,dma_mode     * FDC-Befehlsregister w—hlen
         tst.w    spur              * Soll auf Spur 0 ger≈ckt werden?
         beq      seekspr0          * Ja, dann ist ein "Restore" besser
         move.w   #$10,fdc_reg      * Kommando "Seek ohne Verify" geben
         bsr      wready            * Warte bis FDC fertig ist
         rts
seekspr0 clr.w    fdc_reg           * Kommando "Restore" geben
         bsr      wready            * Warte bis FDC fertig ist
         rts

* Warte bis FDC fertig ist

wready   move.l   #$60000,d0        * Timeoutz—hler
wready1  btst     #5,gpip           * Interrupt angefordert?
         beq      wready2           * Ja, FDC ist fertig
         subq.l   #1,d0
         bne      wready1           * Timeout noch nicht erreicht
         move.w   #$80,dma_mode     * Force Interrupt bei Timeout
         move.w   #$d0,fdc_reg
         move.w   #-1,fdc_stat      * Timeout-Status
         rts
wready2  move.w   #$80,dma_mode     * Fertig, FDC-Statusregister w—hlen
         move.w   fdc_reg,d0
         and.w    #$0078,d0         * Nur die Fehlerbits sind interessant
         move.w   d0,fdc_stat
         rts

service1 move.w   d0,seite          * ˆbergebene Parameter ablegen
         move.w   d1,spur
         move.w   d2,sektor
         move.l   a0,pufadr
         bsr      super_on          * Supervisor-Modus einschalten
         move.w   #1,flock          * Es findet gerade Floppyzugriff statt
         bsr      sel_drv           * Laufwerk und Seite selektieren
         bsr      seek_spr          * Kopf auf gew—hlte Spur r≈cken
         rts 

service2 bsr      wready            * Warte bis FDC fertig ist
         bsr      calcanz           * Anzahl der ≈bertragenen Bytes berechnen
         clr.w    flock             * Es findet kein Floppyzugriff mehr statt
         bsr      super_of          * Supervisor-Modus ausschalten
         move.w   fdc_stat,d0       * FDC-Status und Anzahl der ≈bertragenen
         move.w   bytcount,d1       *  Bytes zur≈ckliefern
         rts

* Gew—hltes Laufwerk und Seite selektieren

sel_drv  move.w   sr,-(sp)          * Alle Interrupts ausschalten
         or.w     #$700,sr          *  (Sie kÓnnten dazwischenfunken)
         move.b   #14,psg_rsel      * PSG-Register 14 (Port-A) ausw—hlen
         move.b   psg_read,d0       * Port-A auslesen
         bclr     #1,d0             * Laufwerk A soll selektiert werden
         bset     #2,d0
         tst.b    laufwerk
         beq      drive_ok
         eor.b    #$06,d0           * Doch Laufwerk B
drive_ok bset     #0,d0             * Seite 0 soll selektiert werden
         tst.w    seite
         beq      seite_ok
         bclr     #0,d0             * Doch Seite 1
seite_ok move.b   d0,psg_writ       * Port-A beschreiben
         move.w   (sp)+,sr          * Interrupts wieder anschalten
         rts

* Disketten-VBL einklinken, Modul an Betriebssystemversion anpassen

initdisk bsr      super_on          * Supervisor-Modus einschalten
         move.l   #$a06,dctadr      * Drive-Configuration-Table-Adr. ermitteln
         cmp.w    #$0100,$fc0002    * Rom-Version 1.0
         beq      versi_ok
         move.l   #$a4c,dctadr
         cmp.w    #$0102,$fc0002    * Rom-Version 1.2
         beq      versi_ok
         pea      warntext          * Warnung ausgeben und
         move.w   #9,-(sp)
         trap     #1
         addq.l   #6,sp
         move.w   #8,-(sp)          *  auf Taste warten
         trap     #1
         addq.l   #2,sp
versi_ok move.l   $456,a0           * Eigene VBL-Routine einklinken
         move.w   #7,d0
initvbl1 tst.l    (a0)+
         beq      initvbl2          * Freier Eintrag wurde gefunden
         dbf      d0,initvbl1
         bsr      super_of          * Kein Eintrag mehr frei
         rts                        *  (sollte eigentlich nicht vorkommen)
initvbl2 move.l   #vbldisk,-(a0)    * Routinen-Adresse in Liste eintragen
         bsr      super_of
         rts

* Disketten-VBL ausklinken

exitdisk btst     #0,motorflg       * Hat VBL Laufwerk schon deselektiert?
         bne      exitdisk          * Nein, Motor l—uft noch
         bsr      super_on
         move.l   $456,a0
         moveq    #7,d0
clrvbl1  cmp.l    #vbldisk,(a0)+
         beq      clrvbl2           * Adresse der VBL-Routine wurde gefunden
         dbf      d0,clrvbl1
         bsr      super_of
         rts 
clrvbl2  clr.l    -(a0)             * Routinen-Adresse aus Liste lÓschen
         bsr      super_of
         rts

* Disketten-VBL-Routine

vbldisk  bset     #0,motorflg       * Motor-ist-an-Flag setzen
         tst.w    flock
         bne      vblend            * Floppyzugriff findet gerade statt
         move.w   #$80,dma_mode     * FDC-Statusregister w—hlen
         move.w   fdc_reg,d0
         btst     #7,d0
         bne      vblend            * Motor ist wirklich noch an
         move.w   sr,-(sp)          * Alle Interrupts ausschalten
         or.w     #$700,sr
         move.b   #14,psg_rsel      * PSG-Register 14 (Port-A) ausw—hlen
         move.b   psg_read,d0       * Port-A auslesen
         or.b     #6,d0             * Laufwerk A und B deselektieren
         move.b   d0,psg_writ       * Port-A beschreiben
         move.w   (sp)+,sr          * Interrupts wieder anschalten
         bclr     #0,motorflg       * Motor-ist-an-Flag lÓschen
vblend   rts

* DMA-Controller programmieren

pdmaread bclr     #0,rewr_flg       * Es findet Lesezugriff statt
         move.w   #$90,dma_mode     * DMA Puffer lÓschen
         move.w   #$190,dma_mode
         move.w   #$90,dma_mode
         bra      pdma
pdmawrit bset     #0,rewr_flg       * Es findet Schreibzugriff statt
         move.w   #$190,dma_mode    * DMA Puffer lÓschen
         move.w   #$90,dma_mode
         move.w   #$190,dma_mode
pdma     lea      pufadr,a0         * DMA Basis-Adresse setzen
         move.b   3(a0),dma_low
         move.b   2(a0),dma_mid
         move.b   1(a0),dma_hig
         move.w   d0,fdc_reg        * Sector-Count-Register setzen
         rts

* Anzahl der durch DMA ≈bertragenen Bytes berechnen

calcanz  move.b   dma_mid,d0        * Nur die unteren 16 Bit sind f≈r die
         lsl.w    #8,d0             *  Berechnung interessant, da mehr als
         move.b   dma_low,d0        *  65536 Bytes wohl nie ≈bertragen werden
         sub.l    pufadr,d0         * Startadresse der ˆbertragung abziehen
         btst     #0,rewr_flg       * Fand Schreib- oder Lesezugriff statt?
         beq      calcanz1          * Bei Lesezugriff alles in Ordnung
         sub.w    #32,d0            * Bei Schreibzugriff 32 abziehen
calcanz1 move.w   d0,bytcount       * Anzahl f≈r die Parameterr≈ckgabe merken
         rts

super_on clr.l    -(sp)             * Supervisor-Modus einschalten
         move.w   #$20,-(sp)
         trap     #1
         addq.l   #6,sp
         move.l   d0,save_ssp       * Supervisor-Stackpointer merken
         rts

super_of move.l   save_ssp,-(sp)    * Supervisor-Modus ausschalten
         move.w   #$20,-(sp)
         trap     #1
         addq.l   #6,sp
         rts

         .data

warntext dc.b     13,10,'Achtung: Programm ist f≈r Rom-Versionen 1.0 und'
         dc.b     ' 1.2 ausgelegt!',13,13,10,'Dr≈cke <Space>...',0

laufwerk dc.b     0        * 0-> Laufwerk A, <>0-> Laufwerk B
motorflg dc.b     0        * 0-> Motor ist aus, 1-> Motor ist an

         .bss

dctadr   ds.l     1        * Adresse der Drive-Control-Table
rewr_flg ds.b     1        * 0-> Lesezugriff, 1-> Schreibzugriff

seite    ds.w     1        * Seite,
spur     ds.w     1        * Spur und
sektor   ds.w     1        * Sektor auf die der Zugriff stattfinden soll
pufadr   ds.l     1        * Adresse des Datenpuffers

fdc_stat ds.w     1        * FDC-Status (-1 -> Timeout)
bytcount ds.w     1        * Anzahl der ≈bertragenen Bytes

save_ssp ds.l     1        * Supervisor-Stackpointer

         .end

