 *21.8.89-----------------*
 *  Spring Maus           *
 *  8/89 Ralf Stachs      *
 *------------------------*
 *Ralf Stachs             *
 *Lad. Winterstein-Ring 18*
 *6234 Hattersheim        *
 *------------------------*

 *TRAPS
 GEMDOS   equ 1
 BIOS     equ 13
 XBIOS    equ 14

 *Daten der neuen Mausroutine
 resi_anfang:
 bra INSTALL
                  dc.b 0          *FÅller
 maus_aus:        dc.b 0          *schaltet Spring Maus an/aus
 dc.b "XBRA"                      *XBRA Protokoll
 dc.b "RS_1"                      *eigene Kennung
 old_vec: dc.l 0                  *alter Vektor

                  *neue Mausroutine
 new_mouse:       *neue Routine eingeschaltet
                  tst.b maus_aus  *neue Routine ausgeschaltet
                  bne aus         *ja

                  movem.l d0-d1/a0-a3,-(sp)
                                  *Register retten

                  *Maus Header ?
                  move.b (a0),d0  *Header Kopf in d0
                  cmp.b #$f8,d0   *kleiner $f8
                  blt end         *ja
                  cmp.b #$fb,d0   *grîûer $fb
                  bgt end         *ja

                  *Maus aus
                  move.l tos_aus,a1
                  *Flag fÅr Maus aus (MOUSE_FLAG)
                  tst.b (a1)      *Maus aus
                  bne end         *ja dann Ende

                  *neues GCURY berechnen
                  move.b 2(a0),d1 *Wert header_y nach d1
                  move.l A_GCURY,a2
                  *Adresse A_GCURY nach a2
                  move.w (a2),d0  *Wert GCURY nach d0
                  ext.w d1        *header_y Vorzeichenrichtig auf .w
                  add.w d1,d0     *header_y zu A_GCURY addieren

                  *Maus an min. Grenze
                  cmp.w min,d0    *GCURY <min (MenÅleiste)
                  bgt sp_6        *nein
                  tst.w (a2)      *GCURY = 0
                  bne sp_5        *nein
                  move.b #0,2(a0) *k. y Bewegung
                  bra sp_6        *Taste abfragen

                  *Mausbewegung bis min. Wert
 sp_5:            move.b min+1,d1 *min. Wert GCURY nach d1
                  move.b 1(a2),d0 *alter GCURY Wert nach d0
                  sub.b d0,d1     *neue Mausbewegung nach oben
                  move.b d1,2(a0) *header_y noch bis min. Wert

                  *rechte Maustaste ?
 sp_6:            lea r_taste,a1  *Adr. r_taste nach a1
                  cmp.b #$f9,(a0) *rechte Maustaste gedrÅckt
                  bne sp_3        *nein

                  *rechte Taste weitergeben
                  tst.b r_weiter  *rechte Taste weitergeben
                  bne sp_2        *weitergeben
                  and.b #%11111110,(a0)
                  *Bit rechte Maustaste lîschen

 sp_2:            tst.b (a1)      *rechte Taste
                  *beim letzten mal gedrÅckt
                  bne end         *ja

                  *Maus nach oben
                  move.b #1,r_taste
                  *Flag setzen Taste gedrÅckt
                  move.w (a2),merk_y
                  *GCURY speichern
                  and.b #%11111110,(a0)
                  *Bit rechte Maustaste lîschen
 sp_7:            move.l old_vec,a3
                  *Adresse Mausroutine
                  move.b #-127,2(a0)
                  *Maus nach oben
                  jsr (a3)        *alte Routine
                  move.l A_GCURY,a3
                  *Adresse von GCURY
                  tst.w (a3)      *GCURY gleich 0
                  beq sp_10       *ende
                  bra sp_7        *nochmal

 sp_3:            *Maus in Pull Down
                  tst.b (a1)      *rechte Taste letztes Mal
                                  *nicht gedrÅckt
                  beq end         *ja
                  move.b #0,(a1)  *Flag lîschen
                  tst.b spring    *spring zu alter Position
                  bne sp_9        *ja
                  move.b pull_down,2(a0)
                  *Maus in Pull Down
                  bra end         *alte Position
                                  *Åberspringen
 sp_9:            *Maus alte Position
                  lea merk_y,a1   *Adresse von merk_y nach a1
                  move.b 1(a1),2(a0)
                  *Wert beim letztem Aufruf
                  move.w #127,d0  *max. Wert in d0
                  sub.w d0,(a1)   *altes GCURY-127
                  bmi end         *k. Aufruf mehr GCURY <127
                  move.l old_vec,a3
                  *Adresse Mausroutine
                  move.b #127,2(a0)
                  *max. Wert in Header schreiben
                  jsr (a3)        *alte Routine
                  bra sp_9

                  *rechte Taste weitergeben ?
 sp_10:           tst.b r_weiter  *rechte Taste weitergeben
                  beq sp_11       *n. weitergeben
                  or.b #%00000001,(a0)
                  *Bit rechte Maustaste setzen
 sp_11:           move.b #0,1(a0) *Maus n. bewegen
                  move.b #0,2(a0) *Maus n. bewegen
                  move.l old_vec,a3
                  *Adresse Mausroutine
                  jsr (a3)        *alte Routine

 end:             *alte Mausroutine anspringen
                  movem.l (sp)+,d0-d1/a0-a3
                  *Register zurÅckschreiben
 aus:             move.l old_vec,-(sp)
                  *alte Mausroutine
                  rts             *anspringen

                  *VBL-Routine bei Start aus AUTO-Ordner
 neu_vbl: move.l kbdv_addr,a0     *kdbv_addr->a0
                  lea 16(a0),a1   *Adr. Vektor a1
                  cmp.l #new_mouse,(a1)
                  *Merker noch da
                  beq sp_20       *ja

                  *vbl-Slot lîschen
                  move.l vbl_slot,a0
                  move.l #0,(a0)

                  move.l (a1),old_vec
                  *alten Mausvektor sichern
                  move.l #new_mouse,(a1)
                  *neue Mausroutine init
 sp_20:           rts


 *Flags
 *r_taste         0=rechte Taste nicht gedrÅckt
 *                1=rechte Taste gedrÅckt
 *r_weiter        0=rechte Taste nicht weitergeben an Origi. Mausroutine
 *                1=rechte Taste weitergeben an Origi. Mausroutine
 *maus_aus        0=neue Mausroutine eingeschaltet
 *                1=neue Mausroutine ausschalten
 *spring          0=spring in Pull Down
 *                1=spring zur alten Position
 r_taste:         dc.b 0
 r_weiter:        dc.b 0
 spring:  dc.b 1

 *Variablen
 *merk_y  =merkt sich maus_y
 *min     =min. y Wert von maus_y  20-Mono  11-Farbe
 *tos_aus =Adresse von Flag TOS
 *       0=Maus wird angezeigt
 *       1=Maus wird nicht angezeigt
 *kbdv_addr       =Adresse der kbdv Tabelle
 *old_vec =Zeiger auf Original Mausroutine
 *vbl_slot        =Adresse des VBL-Slot
 *A_GCURY =Adresse von GCURY
 *pull_down =Wert nach unten bei Pull Down
  EVEN
 merk_y:  dc.w 0
 tos_aus:         dc.l 0
 kbdv_addr:       dc.l 0
 vbl_slot:        dc.l 0
 A_GCURY: dc.l 0
 min:             dc.w 0
 pull_down:       dc.b 0
 resi_ende:

  TEXT
                  *installierung von Spring Maus
                  *gesamt-PRG Speicher belegen
  EVEN
 INSTALL: move.l  sp,a6           *Adr. BASEPAGE
                  lea     USTACK,sp  *neuer Stack

                  move.l  4(a6),a6
                  *Speicher belegen
                  move.l  $c(a6),a4
                  adda.l  $14(a6),a4
                  adda.l  $1c(a6),a4

                  pea             256(a4)
                  pea             (a6)
                  clr.w   -(sp)
                  move.w  #74,-(sp)
                  *Mshrink aufrufen
                  trap #GEMDOS
                  lea 12(sp),sp

                  *Adresse KBDVECS holen
                  move #34,-(a7)  *Kbdvbase rufen
                  trap #XBIOS
                  addq.l #2,a7
                  move.l d0,kbdv_addr *Adresse der Vektortabelle sichern

                  *Spring Maus schon installiert
                  move.l kbdv_addr,a1 *Adresse der Vektortabelle nach a1
                  move.l 16(a1),a2
                  *Adresse von mausvektor in a2
                  lea  (a2),a0
                  *Adresse der mausroutine
                  cmpi.l #"RS_1",-8(a0)
                  *vergleichen
                  bne sp_50       *Spring Maus installieren

                  *Spring Maus ein oder ausschalten
                  not.b -13(a0)   *maus_aus invertieren
                  bne sp_55
                  pea string5     *Spring Maus einschalten
                  move.w  #9,-(sp)
                  trap #GEMDOS
                  addq.l #6,sp
                  bra sp_56
 sp_55:           pea string6     *Spring Maus auschalten
                  move.w  #9,-(sp)
                  trap #GEMDOS
                  addq.l #6,sp
                  *PRG beenden
 sp_56:           clr.w  -(sp)
                  trap #GEMDOS

 sp_50:           *alten Vektor sichern
                  lea old_vec,a0
                  move.l a2,(a0)

                  *AES-anmelden
                  move.w #10,d0   *Applikation anmelden
                  bsr aes_init    *AES aufrufen
                  tst.w aes_global
                  *starten aus AUTO-Ordner
                  beq sp_52       *j,k.ap_version

                  *Vom Desktop starten
                  *maus installieren
                  lea desktop,a0  *Adr.v. Desktop nach a0
                  pea     (a0)
                  move.w #38,-(sp)  *Supexec
                  trap #XBIOS
                  addq.l #6,sp
                  bra sp_51

 sp_52:           *Aus AUTO-Ordner starten
                  *AUTO Ordner îfnen
                  pea path        *AUTO Ordner
                  move.w #$3b,-(sp)    *Dsetpath
                  trap #1
                  addq.l #6,sp

                  *Unterprogramm im Supervisor-Modus ausfÅhren
                  lea auto,a0     *Adresse von auto nach a0
                  pea     (a0)
                  move.w #$26,-(sp)  *Supexec
                  trap #XBIOS
                  addq.l #6,sp

 sp_51:           *Bildschirmauflîsung einstellen
                  *                Farbe |  Mono
                  *min             11    |  20
                  move.w #4,-(sp) *Getrez aufrufen
                  trap #XBIOS
                  addq.l #2,sp

                  *Farbe
                  move.w #11,min  *MenÅleiste
                  cmp.b #1,d0     *Farbe
                  ble sp_61       *ja

                  *Mono
                  move.w #20,min  *MenÅleiste

 sp_61:           *Filename holen
                  pea buf         *Puffer DTA
                  move.w #$1a,-(sp)
                  *Fsetdta aufrufen
                  trap #GEMDOS
                  addq.l #6,sp
                  move.w #0,-(sp) *normale Datei
                  pea     fspec   *Suchname (SMAUS_??.PRG)
                  move.w #$4e,-(sp)  *Fsfirst
                  trap #GEMDOS
                  addq.l #8,sp

                  *0   ->alte Position
                  *1-9 ->Pull Down
                  cmp.b #"A",buf+36 *alte Pos.
                  beq sp_53       *ja

                  *Wert fÅr Pull Down berechnen
                  move.b #0,spring   *Pull Down
                  clr.l d0        *d0 lîschen
                  move.b buf+36,d0   *Faktor
                  sub.w #"1",d0   *Faktor in d0

                  cmp.w #20,min   *Mono
                  beq sp_62       *ja

                  *Farbe
                  mulu.w #8,d0    *Wert f.PullDown
                  add.w min,d0    *add MenÅleiste
                  add.w #5,d0     *und Zeilenmitte
                  bra sp_63       *Mono Åberjumpen

 sp_62:           *Mono
                  mulu.w #16,d0   *Wert f.PullDown
                  add.w min,d0    *add MenÅleiste
                  add.w #10,d0    *und Zeilenmitte

 sp_63:           *max. und min prÅfen
                  cmp.w #127,d0   *kleiner als 127
                  blt sp_60       *ja
                  move.b #127,d0  *max. Wert
 sp_60:           cmp.w min,d0    *grîûer als MenÅleiste
                  bgt sp_59       *ja
                  move.w min,d0   *min. Wert
 sp_59:           move.b d0,pull_down  *speichern

 sp_53:           *rechte Maus-Taste ein oder aus
                  cmp.b #"A",buf+37 *r. Taste aus
                  beq sp_54       *ja
                  move.b #1,r_weiter*r. Taste an

 sp_54:           *tos_aus holen
                  dc.w $a000      *Adr.neg.Line-A
                  sub.l #$153,a0  *Adr.MAUSFLAG
                  move.l a0,tos_aus *und merken

                  *Adresse von GCURY speichern
                  move.l d0,a0    *Adr.neg.Line-A
                  sub.l #$258,a0  *Adresse GCURY
                  move.l a0,A_GCURY *und merken

                  *initialisierung i.o.
 fertig:          pea string2
                  move.w  #9,-(sp)
                  trap #GEMDOS
                  addq.l #6,sp

                  *Speicherplatz fÅr Mausroutine
                  clr.w -(sp)
                  pea resi_ende-resi_anfang+256
                  move.w #49,-(a7)   *Ptermres
                  trap #GEMDOS

                  *PRG im Supervisor mausroutine installieren
 auto:            *starten aus AUTO Ordner
                  *neuen Vektor setzen
                  move.l kbdv_addr,a0
                  *Keyboardadresse nach a0
                  move.l #new_mouse,16(a0)
                  *Merker setzen
                  *VBL installieren
                  move.w $454,d0  *Anzahl VBL Routinen (nvbls)
                  lsl #2,d0       *Anzahl*4
                  move.l $456,a0  *Zeiger auf VBL (_vblqueue)
                  clr d1          *ZÑhler
 weiter:          tst.l 4(a0,d1)  *VBL Slot frei
                  beq frei        *ja
                  add #4,d1       *next Pointer
                  cmp.l d0,d1     *alle abgefragt
                  bne weiter

                  *Spring Maus nicht initialisieren
                  pea string3     *Alle besetzt
                  move.w  #9,-(sp)
                  trap #GEMDOS
                  addq.l #6,sp
                  *PRG beenden
                  clr.w  -(sp)
                  trap #GEMDOS

 frei:            lea 4(a0,d1),a2 *Adr. Slot in a2
                  lea neu_vbl,a1  *Adr.neue Rout.
                  move.l a1,(a2)  *neue Routine einhÑngen
                  lea vbl_slot,a1 *Slot Adresse
                  move.l a2,(a1)  *sichern
                  rts

 desktop: *Starten vom Desktop
                  move.l kbdv_addr,a0
                  *Keyboardadresse nach a0
                  lea new_mouse,a1
                  *Adresse neue Mausroutine
                  move.l a1,16(a0)
                  *neuen Vektor setzen
                  rts

 aes_init:        *AES aufrufen
                  lea contrl,a0   *Adr.contrl->a0
                  move.w d0,(a0)+ *Opcode
                  clr.w (a0)+     *eintr. int_in
                  move.w #1,(a0)  *eintr. int_out
                  clr.w (a0)+     *eintr. addr_in
                  clr.w (a0)      *eintr. addr_out

                  move.l #aes_data,d1
                  *Adresse AES-Array
                  move.w #$c8,d0  *AES_Aufruf
                  trap #2
                  rts

  DATA
 string2: dc.b 13,10,"+---------------------+"
           dc.b 13,10,"+   Spring MAUS 3.3   +"
           dc.b 13,10,"+   9/89 Ralf Stachs  +"
           dc.b 13,10,"+  (c) MAXON Computer +"
           dc.b 13,10,"+---------------------+"
           dc.b 13,10,"SMAUS_xy.PRG"
           dc.b 13,10,"-x"
           dc.b 13,10,"A  ->Alte Position"
           dc.b 13,10,"1-9->In Pull Down"
           dc.b 13,10,"-y"
           dc.b 13,10,"E->Rechte Maustaste ein"
           dc.b 13,10,"A->Rechte Maustaste aus",0
 string3: dc.b 13,10,"Alle VBL-Slots besetzt",0
 string5: dc.b 13,10,"SPRING MAUS EIN",0
 string6: dc.b 13,10,"SPRING MAUS AUS",0
 fspec:    dc.b "SMAUS_??.PRG",0
 path:     dc.b "\auto\",0

  EVEN
 aes_data:        dc.l contrl
                  dc.l aes_global
                  dc.l init_in
                  dc.l init_out
                  dc.l addr_in
                  dc.l addr_out

  BSS
 aes_global:      ds.w 15
 contrl:     ds.w 10
 init_in: ds.w 128
 init_out:        ds.w 128
 addr_in: ds.l 128
 addr_out:        ds.l 128

 buf:     ds.b 100
          ds.b 256
 USTACK:  ds.w 0

