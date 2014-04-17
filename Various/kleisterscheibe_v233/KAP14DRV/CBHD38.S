**************************************************
* CBHD V3.8 - Treiber fÅr ATARI-kompatible Platten
* Grundlage: AHDI1.7; auseinandergenommen und
* krÑftig erweitert von Claus Brod
*
* Aus dem SCHEIBENKLEISTER, dem etwas anderen
* Floppy- und Harddiskbuch
*
* 1.8: Booten von AUTO-Ordner und ACCs von anderen Partitionen
* 2.0: Erweiterter Rootsektor (12 Partitionen), 2 GerÑte pro Target
* 2.1: Reihenfolge der zusÑtzlichen Partitionen geÑndert
*      Schreibschutz fÅr einzelne Partitionen (wrprot)
* 2.2: Ausgabe der schreibgeschÅtzten Laufwerke beim Booten
*      prÅft auf FLEXDISK1.3; Erweiterung des GEMDOS-Puffers auch bei TOS1.2
*      Timeouts sauberer Åber hz_200, Meldung auch beim Booten von Disk
* 2.3: selektiert Drive A, Seite 0 beim Booten (hemmt Nachlaufen)
*      Kennzeichen fÅr erweiterten Rootsektor geÑndert (wegen neuem HDX)
* 2.4: Anpassung an TURBODOS (do_rw) - TROTZDEM FINGER WEG!
*      bufl-Listen werden korrekt terminiert, neue Nachlauf-Hemm-Routine
* 2.5: Anpassung an SH204 (Unit-1-Problem, erkennt jetzt auch im
*      Normalbetrieb mehr Fehler als AHDI)
*      Parameter 'bootdrv' und 'folders' jetzt offiziell
* 2.6: Treiber heiût CBHD.SYS, verwaltet maximal 30 Laufwerke
*      pool_ins verbessert; neuer Parameter 'drvmask' zum
*      Ausmaskieren von Laufwerken
*      Gibt aktive Laufwerke aus; in 'folders' steht jetzt die "echte"
*      Anzahl von Ordnern (jeder Ordner belegt 2 DCBs!)
* 2.7: Schafft auch Vortex-Format (8 Partitionen pro Platte, IDs
*      ab Offset $186 im Rootsektor)! VORSICHT: Unbenutzte Part-IDs
*      ungÅltig machen! Fehler in pool_ins behoben
* 2.8: bufl-Patch raus; folders=0: Nichts wird reserviert
*      Treiber-Info-Struktur kann Åber $516 gefunden werden:
*      Drvadr = Lpeek(Lpeek(&516)-16), wenn bei Lpeek(Lpeek(&516-12)) der
*      String "XBRACBHD" steht. Drvadr zeigt dann auf folgende Struktur:
*      struct cbhdhdr {
*                     char gehtdichnixan[20];
*                     WORD bootload;     /* Auto-Boot (0=nein) */
*                     char *baseaddr;    /* Zeiger auf Treiberstart */
*                     char version;      /* Version in ASCII */
*                     char revision;     /* 2. Stelle */
*                     ULONG wrprot;      /* Schreibschutzmaske */
*                     ULONG drvmask;     /* Laufwerksmaske */
*                     WORD bootdrv;      /* Default-Bootlaufwerk */
*                     WORD folders;      /* zusÑtzliche Ordner */
*                     int  reserved[8];  /* reserviert */
*                     };
* 2.9: Versionsnummer im Header auf char korrigiert, drvmask wird im
*      Verteiler korrekt abgefragt, VBL-Routine an TOS1.0 angepaût,
*      altes RAM-TOS wird angemeckert
*      zusÑtzliche inoffizielle Kennung hi_anton nach drvheader-Struktur
*      Ordner-Erweiterung auch bei TOS1.4
* 3.0: SHIFT beim Booten: Platten kînnen einzeln ausgewÑhlt werden
*      erstes zu vergebendes Laufwerk kann eingestellt werden
* 3.1: VBL-Routine wird jetzt immer durchlaufen (auûer wenn FLEXDISK
*      in Betrieb); dadurch wird Hibyte von bootdev wieder gelîscht
*      jetzt voll ICD/SUPRA-kompabeatle; Bootmsg in nicht-flÅchtigen
*      Teil verschoben
* 3.2: Experimente
* 3.3: Anpassung an STE/TT: Trap-2-Vektor statt Line-F, ROM-Abfrage
*      korrigiert; Anpassung an Wechselplatte; pun-Struktur kompatibel
*      zu AHDI 3.x - nicht aber Partitionenformat!
*      DESKTOP.INF wird bei 'Arbeit sichern' auf das aktive Laufwerk
*      abgespeichert, richtiges Fenster wird aktualisiert
* 3.4: Virustest bei Autoboot (VerÑnderungen der hdv-Vektoren werden
*      erkannt); check_dev im physikalischen Modus korrigiert
*      Ordnererweiterung auch bei RAM-TOS vom 6.2.86 und Exotenversion
*      vom 1.6.86; Anpassung der DESKTOP.INF-Routine an BlitterTOS,
*      Unterscheidung zwischen DESKTOP.INF-Kopieren und -Anlegen
* 3.5: Experimente, Tests; Fehler in do_rw eliminiert,
*      PATH stimmt wieder; im AUTO-Ordner installierte Laufwerke
*      werden nicht mehr versehentlich abgemeldet (kam durch Umstellung
*      auf STE); jetzt wieder max. 14 statt 12 Partitionen insgesamt
*      (blîder Bug seit V3.3)
* 3.6: Neues Konfigwort punmask steuert, welche Targets/GerÑte Åberhaupt
*      betrachtet werden
* 3.7: Neue Methode fÅrs ACC-Booten, sollte sich noch viel besser mit
*      allem vertragen (auch mit STE, GDOS...)
*      execos wird wieder restauriert, wenn Auto-Ordner-Programme
*      sich per XBRA installieren; VBL-Liste darf im Autoordner
*      verschoben werden; nach Virusmeldung wird nicht mehr gewartet
*      Anpassung fÅr MIDI-Tastatur eingebaut (bedingte Assemblierung,
*      gesteuert durch Flag 'midi')
*      Bit 1 im R/W-Flag (Rwabs) wird unterstÅtzt, Wechselmeldungen noch
*      mehr an Diskhandler angepaût (Wechsel nach Schreiben eines Bootsektors
*      wird erst beim nÑchsten Zugriff gemeldet) => TUNEUP meldet keinen
*      Fehler mehr; neuer Nachlaufhemmer (tnx JÅrgen)
*      Bootlaufwerk fÅr Autoordner und ACCs/DESKTOP.INF jetzt getrennt
*      wÑhlbar (2 TastendrÅcke), neue (inoffizielle) Variable accboot
*      DESKTOP.INF wird auf bootdev geschrieben
* 3.8: Anpassung an MegaSTE (Abspeichern von NEWDESK.INF)
*
* Bekannte Fehler und EinschrÑnkungen:
*  - bei blockiertem DMA-Bus lÑngere Wartezeit beim Booten
*  - mîglicherweise Probleme mit uralten RAM-TOS-Versionen (vor 6.2.86)
* Last update: 9.1.90, 21:15
****************************************

midi        = 0                 ; MIDI-Flag
vortex      = 0					; Vortex-Flag

drvbits     = $4C2              ; Laufwerks-Bitmap
dskbufp     = $4C6              ; -> TOS-Diskpuffer
bootdev     = $446              ; Bootdevice
nflops      = $4A6              ; Anzahl der Laufwerke
bufl        = $4B2              ; zwei Zeiger auf BCBs
hz_200      = $4BA              ; 200-Hz-ZÑhler
daccess     = $FFFF8604         ; DMA-Fensterregister
dmodus      = $FFFF8606         ; DMA-Modusregister
gpip        = $FFFFFA01         ; MFP-GPIP

magic       = "CBHD"            ; magische Langwort-Konstante
version     = "3"               ; Versionsnummer
revision    = "8"               ; Versionsnummer, 2. Stelle
maxunits    = 14                ; maximal 14 Laufwerke werden unterstÅtzt
maxsecs     = 17*14             ; maximale Anzahl von Sektoren, die auf
                                ; einen Schlag Åbertragen werden
medtime     = 400               ; wie lange Mediachange ohne ReqSense?

************************
* Das Bootprogramm im Bootsektor springt direkt nach
* auto; dort wird das Autobootflag gesetzt
* In a2 wird die Startadresse des Treibers Åbergeben
* (Start des Vorspanns)
************************
i_cbhd:
    bra     i_cbhd1             ; normaler Einsprung

* Einsprung vom Plattenbooter aus
auto:
    st      bootload            ; Autobootflag setzen
    move.l  a2,baseaddr         ; Startadresse des Treibers
    bra     i_cbhd1             ; zum Hauptteil

********************
* drvheader-Struktur
********************
bootload: dc.w    0             ; Autobootflag
baseaddr: dc.l    0             ; fÅr Startadresse des Treibers
release:  dc.b version,revision ; Versionsnummer
wrprot:   dc.l    0             ; Langwort fÅr Schreibschutzbits
drvmask:  dc.l    $FFFFFFFF     ; Maske fÅr erlaubte Laufwerke
bootdrv:  dc.w    2             ; Default-Bootlaufwerk
folders:  dc.w    50            ; Erweiterung des internen GEMDOS-Speichers
                                ; (in "Ordnern")
firstdrv: dc.w    "C"-65        ; erste zu vergebende Kennung
punmask:  dc.w    %1111111111111111
                                ; Bitmaske fÅr zu beachtende Targets
                                ; Bitposition(Target, GerÑt) = Target*2+Geraet
accboot:  dc.w    2             ; woher sollen ACCs und DESKTOP.INF kommen?
reserved: dc.w    0,0,0,0,0     ; 5 reservierte Worte
hi_anton: dc.l    magic         ; undokumentierte Kennung

******************
* Anfang der neuen hdv_bpb-Routine
******************
    dc.b    "XBRA"              ; XBRA-Kennung
    dc.l    magic               ; "CBHD"
o_bpb:
    dc.l    0                   ; alter BPB-Vektor
hbpb:
    move.w  4(a7),d0            ; Laufwerksnummer
    clr.w   d1                  ; d1=0 (keine physikalische Operation)
    movea.l o_bpb(pc),a0        ; alte BPB-Adresse
    lea     cbhd_bpb(pc),a1     ; Adresse der neuen BPB-Routine
    bra.s   check_dev           ; zum Verteiler

*******************
* Anfang der neuen hdv_rw-Routine
*******************
    dc.b    "XBRA"              ; XBRA-Kennung
    dc.l    magic               ; "CBHD"
o_rw:
    dc.l    0                   ; alter RWABS-Vektor
hrw:
    move.w  14(a7),d0           ; Laufwerksnummer
    move.w  4(a7),d1            ; R/W-Flag
    movea.l o_rw(pc),a0         ; alte RWABS-Routine
    lea     cbhd_rw(pc),a1      ; neue RWABS-Routine
    bra.s   check_dev           ; zum Verteiler

*********************
* Anfang der neuen hdv_media-Routine
*********************
    dc.b    "XBRA"              ; XBRA-Kennung
    dc.l    magic               ; "CBHD"
o_med:
    dc.l    0                   ; alter MEDIACH-Vektor
hmedia:
    move.w  4(a7),d0            ; Laufwerksnummer
    clr.w   d1                  ; d1=0, keine physikalische Operation
    move.l  o_med(pc),a0        ; alte Mediachange-Routine
    lea     cbhd_me(pc),a1      ; neue Media-Routine

*****************************
* Verteiler
* IN: A1 Treiberroutinenadresse
*     A0 alte Adresse
*     D0 Laufwerksnummer
*     D1 Flags (Bit 3 gesetzt: physikalische Op., sonst logisch)
*               Bit 2 gesetzt: Mit Retry arbeiten)
*****************************
check_dev:
    btst.l  #3,d1               ; Bit 3 von d1 gesetzt?
    beq.s   chkd_a              ; nein, logische Operation
    subq.w  #2,d0               ; Drivenummer - 2
    bmi.s   chkd_f              ; keine Partition
    move.l  a0,-(sp)            ; a0 retten
    lea     _pun(pc),a0         ; -> pun-Tabelle
    add.w   firstdrv(pc),a0     ; + Nummer des ersten Laufwerks
    move.b  (a0),d1
    move.l  (sp)+,a0
    and.w   #$0f,d1             ; unterste Targetnummer ermitteln
    add.w   puns(pc),d1         ; + Anzahl der phys. Laufwerke
    cmp.w   d1,d0               ; mit "Drivenummer" vergleichen
    bge.s   chkd_f              ; grîûergleich: Fehler
    bra.s   chkd_s              ; ansonsten Treiberroutine anspringen

chkd_a:
    move.l  drvmask(pc),d1      ; Laufwerksmaske holen
    btst    d0,d1               ; geht uns das Laufwerk was an?
    beq.s   chkd_f              ; wir halten uns raus

    lea     _pun(pc),a2         ; Anfang der Physical-Unit-Tabelle
    tst.b   0(a2,d0)            ; Existiert das Laufwerk?
    bmi.s   chkd_f              ; nie und nimmer!

chkd_s:
    movea.l a1,a0               ; neue Routine verwenden
chkd_f:
    jmp     (a0)                ; zur Routine springen

*****************
* neue BPB-Routine
*****************
cbhd_bpb:
    move.w  4(a7),d0            ; Laufwerksnummer
    lea     chgtab(pc),a0       ; -> Wechseltabelle
    tst.b   0(a0,d0)            ; Medium gewechselt?
    beq.s   wie_gehabt          ; nein
    bsr     neueinlesen         ; ganze Partitionenstruktur neu lesen
    move.w  4(a7),d0            ; Laufwerksnummer
    lea     chgtab(pc),a0       ; -> Wechseltabelle
    clr.b   0(a0,d0)            ; Wechsel auf diesem Laufwerk lîschen
wie_gehabt:
    mulu    #18,d0              ; mal 18 (Grîûe des BPB in Bytes)
    add.l   #bpbtab,d0          ; + Startadresse des BPB-Bereichs
    rts                         ; Adresse in d0 zurÅck und raus

*********************
* neue RWABS-Routine
*********************
cbhd_rw:
    link    a6,#0               ; lokaler Stack
    clr.w   chgflag
cbrw1:
    move.w  14(a6),d2           ; Sektoranzahl nach d2
    beq     cbrw6               ; 0: Ende ohne Fehlermeldung

    move.l  10(a6),d1           ; Pufferadresse
    bne.s   nochange
    move.w  18(a6),d0           ; Laufwerksnummer
    lea     chgtab(pc),a0       ; ->Wechseltabelle
    move.b  d2,0(a0,d0)         ; neuen Wechselstatus eintragen
    bra     cbrw6

nochange:
    cmpi.w  #maxsecs,d2         ; mehr als maxsecs Sektoren?
    ble.s   cbrw2               ; nein, weiter

    move.w  #maxsecs,d2         ; maximale Sektorzahl = maxsecs

cbrw2:
    btst.b  #0,13(a6)           ; Pufferadresse ungerade?
    beq.s   cbrw4               ; nein, weiter
* Ist die Pufferadresse ungerade, arbeitet der Treiber mit dem
* TOS-internen Disk-Puffer als Zwischenlîsung, da der DMA-Chip
* nur auf gerade Adressen zugreifen kann

    cmpi.w  #2,d2               ; mehr als 2 Sektoren?
    ble.s   cbrw3               ; nein, paût in internen Puffer
    moveq.l #2,d2               ; Sektorzahl = 2
cbrw3:
    move.l  dskbufp,d1          ; dskbufp, Zeiger auf internen Puffer
    btst.b  #0,9(a6)            ; R/W-Flag: Lesen oder Schreiben?
    beq.s   cbrw4               ; Bit gelîscht, also lesen

    movea.l d1,a1               ; Pufferadresse (Ziel)
    movea.l 10(a6),a2           ; Anwenderpuffer (Quelle)
    bsr     smove               ; d2 Sektoren vom a2- zum a1-Bereich

cbrw4:
    move.w  d2,-(a7)            ; Sektoranzahl retten
    move.w  18(a6),d0           ; Laufwerksnummer holen
    lea     chgtab(pc),a0       ; -> Wechseltabelle
    tst.b   0(a0,d0)            ; gewechselt?
    bne     cbchg               ; ja, raus hier

    move.w  18(a6),-(a7)        ; logisches Laufwerk
    move.w  16(a6),d0           ; Sektornummer
    move.w  d0,-(a7)
    move.w  d2,-(a7)            ; Sektoranzahl
    move.l  d1,-(a7)            ; Pufferadresse
    move.w  8(a6),d1            ; R/W-Flag
    move.w  d1,-(a7)
    btst    #0,d1               ; lesen oder schreiben?
    beq.s   nunmachmal
    tst.w   d0                  ; Bootsektor wird beschrieben?
    bne.s   nunmachmal          ; aber nicht doch
    st      chgflag             ; ja!
nunmachmal:
    bsr     _do_rw              ; Sektoren lesen/schreiben
    lea     12(a7),a7           ; Stack sÑubern
    move.w  (a7)+,d2            ; Sektorzahl zurÅckholen
    tst.l   d0                  ; Fehler passiert?
    beq.s   fehlerfrei          ; nein
    cmp.b   #-14,d0             ; Medium gewechselt?
    bne.s   cbrw7               ; nein, einfach raus

    btst    #1,9(a6)            ; Medienwechsel ignorieren?
    bne.s   cbrw4               ; ja, nochmal lesen/schreiben

    moveq.l #2,d0               ; definitiv gewechselt
    move.w  18(a6),d1           ; Laufwerksnr
    bsr.s   eintragen           ; Wechsel in Tabellen eintragen
    bra.s   cbchg               ; und raus hier

fehlerfrei:
    btst.b  #0,13(a6)           ; ungerade Pufferadresse?
    beq.s   cbrw5               ; nein, weiter
* Wenn die Pufferadresse ungerade war, wurde in den Diskpuffer/vom
* Diskpuffer aus transferiert

    btst.b  #0,9(a6)            ; R/W-Flag: Lesen oder Schreiben?
    bne.s   cbrw5               ; Schreiben, dann weiter
    movea.l 10(a6),a1           ; Pufferadresse
    movea.l dskbufp,a2          ; dskbufp
    bsr.s   smove               ; Inhalt von dskbufp nach Anwenderpuffer

cbrw5:
    move.w  d2,d0               ; Sektorzahl
    ext.l   d0                  ; vorzeichenrichtig erweitern
    asl.l   #8,d0               ; mal 256
    add.l   d0,d0               ; mal 2 (also insgesamt mal 512)
    add.l   d0,10(a6)           ; plus Pufferstart
    add.w   d2,16(a6)           ; Sektorzahl plus Startsektor
    sub.w   d2,14(a6)           ; von Sektoranzahl abziehen
    bne     cbrw1               ; noch was zu lesen/schreiben?

cbrw6:
    moveq.l #0,d0
    tst.w   chgflag             ; wurde Bootsektor beschrieben?
    beq.s   cbrw7               ; nein, weiter

    moveq.l #2,d0               ; definitiv gewechselt
    move.w  18(a6),d1           ; Laufwerksnr
    bsr.s   eintragen           ; Wechsel in Tabellen eintragen
    moveq.l #0,d0               ; jetzt noch keinen Wechsel melden
    bra.s   cbrw7               ; weiter

cbchg:
    moveq.l #-14,d0             ; d0=-14 (Wechsel)
    btst.b  #1,9(a6)            ; Bit 1 gesetzt (Mediachange ignorieren)?
    beq.s   cbrw7               ; nein, weiter
    moveq.l #0,d0
cbrw7:
    unlk  a6                    ; lokalen Stack aufrÑumen
    rts                         ; raus hier

*******************
* Kopiert d2 Sektoren vom a2-Bereich in den a1-Bereich
* wird nur bei ungeraden Pufferadressen gebraucht
*******************
smove:
    move.w  d2,d0               ; Sektoranzahl
    asl.w   #6,d0               ; mal 64
    subq.w  #1,d0               ; minus 1 wegen dbf
smove1:
    move.b  (a2)+,(a1)+         ; 8 Bytes kopieren
    move.b  (a2)+,(a1)+
    move.b  (a2)+,(a1)+
    move.b  (a2)+,(a1)+
    move.b  (a2)+,(a1)+
    move.b  (a2)+,(a1)+
    move.b  (a2)+,(a1)+
    move.b  (a2)+,(a1)+
    dbf     d0,smove1           ; nÑchstes Byte
    rts                         ; und raus

*************************
* eintragen: TrÑgt Wechsel in die
* zugehîrige(n) Tabelle(n) ein
* IN: d1 Laufwerksnummer
*     d0 Wechselstatus (1 oder 2)
*************************
eintragen:
    move.l  d2,-(sp)            ; Register retten
    lea     chgtab(pc),a0       ; -> Wechseltabelle

    move.w  firstdrv(pc),d2     ; ab erstem Laufwerk
eloop:
    move.b  d0,0(a0,d2)         ; Wechselstatus schreiben
    addq.w  #1,d2               ; nÑchstes Laufwerk
    cmp.w   #maxunits+2,d2      ; schon durch?
    bne.s   eloop               ; nein, weiter

    move.l  (sp)+,d2
    rts

*************************
* _do_rw: Sektoren lesen/schreiben
* ParameterÅbergabe auf dem Stack
* 4(a7) R/W-Flag
* 6(a7) Pufferadresse
* $A(a7) Sektorzahl
* $C(a7) Sektornummer
* $E(a7) logisches Laufwerk
*************************
_do_rw:
    movem.l d3/d4,-(a7)         ; d3/d4 retten

sasrw0:
    btst.b  #0,13(a7)           ; Lesen oder schreiben?
    beq.s   nurlesen            ; nur lesen
    move.w  22(a7),d0           ; logisches Laufwerk
    move.l  wrprot(pc),d3       ; Schreibschutzmaske holen
    btst    d0,d3               ; Laufwerk schreibgeschÅtzt?
    beq.s   nurlesen            ; nein, dann weiter
protected:
    moveq.l #-13,d0             ; WRITEPROT
    bra     sasrwerr

nurlesen:
    move.w  _retries(pc),retrycnt   ; Retry-ZÑhler vorbesetzen
    move.w  12(a7),d3           ; R/W-Flag nach d3.w
    btst.l  #2,d3               ; Retry-Bit gesetzt?
    beq.s   sasrw1              ; nein, weiter
    clr.w   retrycnt            ; kein Retry
sasrw1:
    move.l  lastrwtm(pc),d0     ; HZ-200-ZÑhler fÅr den letzten Zugriff
sasrw8:
    cmp.l   hz_200,d0           ; HZ_200
    bcc.s   sasrw8              ; warten
sasrwx:
    move.l  hz_200,d0           ; HZ_200 holen
    addq.l  #1,d0               ; +1 (deswegen auch das Warten gerade)
    move.l  d0,lastrwtm         ; und ablegen
* Diese letzten Zeilen bewirken, daû zwischen zwei Aufrufen
* mindestens 1/200 Sekunde vergehen muû

    lea     8(a7),a1            ; neue Basisadresse nach a1
* 4(a1) R/W-Flag
* 6(a1) Pufferadresse
* 10(a1) Sektorzahl
* 12(a1) Sektornummer
* 14(a1) logisches Laufwerk

    moveq.l #0,d0               ; d0 lîschen
    move.w  12(a1),d0           ; Sektornummer holen
    move.w  4(a1),d3            ; R/W-Flag

sasrw2:
    clr.w   d2                  ; d2.w lîschen
    move.w  14(a1),d1           ; Nummer des logischen Laufwerks holen
    lea     _pun(pc),a2         ; Adresse der Physical-Unit-Tabelle
    move.b  0(a2,d1),d2         ; Targetnummer holen
    move.w  d2,d4               ; nach d4 kopieren
    and.w   #$0F,d2             ; Targetnummer ausmaskieren
    and.w   #$F0,d4             ; Devicenummer ausmaskieren
    lsl.w   #1,d4               ; mal 2 (pun-Tabellen-Format -> ACSI-Format)
    move.w  d2,-(a7)            ; Targetnummer
    move.w  d4,-(a7)            ; GerÑtenummer

    lea     lastacc(pc),a0      ; -> Tabelle der letzten Zugriffszeiten
    lsl.w   #3,d2               ; Targetnummer mal 8
    add.w   d2,a0
    tst.w   d4                  ; GerÑtenummer 0 oder 1?
    beq.s   schreibacc          ; Null
    add.w   #4,a0               ; Eins
schreibacc:
    move.l  hz_200,(a0)
    add.l   #medtime,(a0)       ; medtime ticks addieren

    move.l  6(a1),-(a7)         ; Pufferadresse
    move.w  10(a1),-(a7)        ; Sektorzahl
    btst.l  #3,d3               ; Bit 3 des R/W-Flags
    bne.s   sasrw4              ; gesetzt, dann weiter (physikalischer Zugriff)

* beim physikalischen Zugriff gibt die Laufwerksnummer beim RWABS-Aufruf
* die Nummer eines Laufwerks in der _pun-Liste an
* Die Sektornummern beziehen sich auf den Start der physikalischen
* Einheit, auf der sich die Partition befindet

    asl.w   #2,d1               ; Laufwerksnummer mal 4
    lea     pstart(pc),a2       ; Tabelle mit Partitions-Startsektoren
    add.l   0(a2,d1),d0         ; Sektornummer addieren

sasrw4:
    move.l  d0,-(a7)            ; resultierende Sektornummer
    btst.l  #0,d3               ; lesen oder schreiben?
    bne.s   sasrw5              ; schreiben
    bsr     _hread              ; physikalischen Sektor lesen
    bra.s   sasrw6              ; weiter

sasrw5:
    bsr     _hwrite             ; phys. Sektor schreiben
sasrw6:
    lea     14(a7),a7           ; Stack sÑubern
    tst.l   d0                  ; Fehler?
    beq.s   sasrwr              ; nein, weiter

    bsr     reqsense            ; mal sehen, was los ist
    bmi.s   do_it_again_sam
    cmp.b   #$27,d0             ; Medium schreibgeschÅtzt?
    beq     protected           ; ja
    cmp.b   #4,d0               ; Laufwerk nicht bereit?
    bne.s   rwchged
    moveq.l #1,d0               ; mîglicherweise gewechselt
    move.w  14(a1),d1           ; Laufwerksnummer
    bsr     eintragen
    moveq.l #-2,d0              ; Laufwerk nicht bereit
    bra.s   sasrwr
rwchged:
    cmp.b   #$28,d0             ; Medium gewechselt?
    bne.s   do_it_again_sam     ; nein, weiter
    moveq.l #-14,d0             ; Wechselfehler
    bra.s   sasrwr              ; nach oben melden

do_it_again_sam:
    subq.w  #1,retrycnt         ; Retry-ZÑhler um eins vermindern
    bpl     sasrw1              ; noch einmal probieren

    move.w  4(a1),d1            ; R/W-Flag, zu oft schiefgegangen
    moveq   #$F5,d0             ; Default-Fehler -11 (Lesefehler)
    btst.l  #0,d1               ; lesen oder schreiben?
    beq.s   sasrw7              ; lesen, dann weiter
    moveq   #$F6,d0             ; Fehler -10 (Schreibfehler)

sasrw7:
    btst.l  #2,d1               ; Bit 2 des R/W-Flags (retry)
    bne.s   sasrwr              ; gesetzt, dann weiter
sasrwerr:
    move.w  22(a7),-(a7)        ; GerÑtenummer
    move.w  d0,-(a7)            ; Fehlernummer
    moveq.l #-1,d0              ; KompatibilitÑt
    movea.l $404,a0             ; -> Critical-Error-Handler
    jsr     (a0)                ; ausfÅhren
    addq.l  #4,a7               ; Stack sÑubern
    cmpi.l  #$10000,d0          ; nochmal probieren?
    beq     sasrw0              ; ja, dann von vorne
    move.w  -4(a7),d0           ; Fehlernummer holen
sasrwr:
    movem.l (a7)+,d3/d4         ; d3+d4 zurÅckholen
    rts                         ; raus

*******************
* neue Mediachange-Routine
*******************
cbhd_me:
    move.w  4(a7),d0
    lea     _pun(pc),a0
    move.b  0(a0,d0),d0         ; Target/GerÑtenummer
    move.b  d0,d1
    and.w   #$0f,d0             ; Targetnummer ausfiltern
    and.w   #$f0,d1             ; GerÑtenummer

    lea     lastacc(pc),a0      ; Tabelle der Zugriffszeiten
    asl.w   #3,d0               ; Targetnummer zurechtbiegen
    add.w   d0,a0
    tst.w   d1                  ; GerÑt 0 oder 1?
    beq.s   holezeit
    add.w   #4,a0               ; nÑchstes Langwort
holezeit:
    move.l  hz_200,d1
    cmp.l   (a0),d1             ; wie lange schon kein Zugriff mehr?
    blo.s   lassmal

    move.l  d1,(a0)
    add.l   #400,(a0)

    moveq.l #15,d1              ; mit Bitnummer 15 (=T7G1) beginnen
mreqlp:
    move.w  punbits(pc),d0
    btst    d1,d0               ; war GerÑt schon mal da?
    beq.s   mnextone
    move.w  d1,d0               ; d1 kopieren
    clr.w   device
    bclr    #0,d0               ; Bit 0 ausmaskieren
    beq.s   mger0
    move.w  #32,device
mger0:
    asl.w   #4,d0               ; Targetnummer zurechtschieben
    move.w  d0,act_pun

    move.w  d1,-(sp)
    bsr     reqsense            ; mal nach Wechsel schauen
    move.w  (sp)+,d1
    cmp.b   #$28,d0             ; Wechsel?
    beq.s   medchged            ; ja, weiter
    cmp.b   #4,d0               ; GerÑt nicht bereit?
    beq.s   mnotrdy
mnextone:
    dbf     d1,mreqlp
    bra.s   lassmal

mnotrdy:
    moveq.l #1,d0               ; vielleicht gewechselt
    bra.s   tabneu
medchged:
    moveq.l #2,d0               ; definitiv gewechselt
tabneu:
    move.w  4(a7),d1            ; Laufwerksnummer holen
    bsr     eintragen           ; Wechsel in Tabellen eintragen

lassmal:
    move.w  4(a7),d1            ; Laufwerksnummer holen
    lea     chgtab(pc),a0       ; Zeiger auf Wechseltabelle
    moveq.l #0,d0
    move.b  0(a0,d1),d0         ; Wechselstatus holen
    rts                         ; und raus

*******************
* Timeout-Routine fÅr Busprotokoll
*******************
_fdone:
    move.l  #2000,d0            ; groûer Timeout
    bra.s   qd0                 ; zur Warteschleife

_qdone:
    moveq.l #7,d0               ; kleiner Timeout
qd0:
    add.l   hz_200,d0
qd1:
    cmp.l   hz_200,d0           ; schon fertig?
    bmi.s   qdq                 ; ja, raus hier
    btst.b  #5,gpip             ; IRQ da?
    bne     qd1                 ; nein, weiter warten
    moveq   #0,d0               ; kein Fehler
    rts                         ; raus
qdq:
    moveq   #-1,d0              ; Fehler durch Timeout
    rts                         ; raus

* auf Kommandoende warten
_endcmd:
    move.w  d0,d1               ; d0 retten
    bsr.s   _fdone              ; langer Timeout
    bmi.s   endce               ; Fehler, dann raus
    move.w  d1,dmodus           ; Bus selektieren
    nop
    move.w  daccess,d0          ; Status holen (bei der SH204 immer 0)
    and.l   #$FF,d0             ; unteres Byte ausmaskieren
endce:
    rts                         ; raus hier

*****************************
* Sektoren lesen
* Parameter auf dem Stack:
* 4(a7) Sektornummer
* 8(a7) Sektoranzahl
* 10(a7) Pufferadresse
* 14(a7) GerÑt (0*32, 1*32...)
* 16(a7) Target
*****************************
_hread:
    lea     daccess,a0          ; Adresse von daccess nach a0
    st      $43E                ; flock setzen
    move.w  #$88,2(a0)          ; Bus im Horchzustand
    moveq.l #0,d0               ; d0=0
    move.w  16(a7),d0           ; Targetnummer
    asl.w   #5,d0               ; mal 32
    move.w  d0,act_pun
    swap    d0                  ; in High-Word
    ori.l   #$8008A,d0          ; Read-Befehl einkodieren
    move.l  d0,(a0)             ; und auf Bus legen
    move.l  10(a7),-(a7)        ; Pufferadresse
    move.l  (a7),dmastart       ; DMA-Startadresse
    bsr     _setdma             ; DMA setzen
    addq.l  #4,a7               ; Stack sÑubern
    move.w  14(a7),device       ; GerÑtenummer holen
    bsr     _setss              ; Sektorparameter auf Bus
    bmi     _hto                ; Fehler?
    move.w  #$190,2(a0)         ; DMA-Status lîschen
    nop
    move.w  #$90,2(a0)          ; DMA-SektorzÑhler selektieren
    nop
    move.w  8(a7),(a0)          ; Sektoranzahl an DMA-Chip
    nop
    move.w  #$8A,2(a0)          ; Bus selektieren
    nop
    move.l  #0,(a0)             ; öbertragung starten
    move.w  #$8A,d0             ; Moduswort fÅr 'Status lesen'
    bsr     _endcmd             ; auf Ende warten und Status holen
hrx:
    tst.l   d0                  ; Fehler?
    bne     _hdone              ; ja, eh nix mehr zu retten
    bsr.s   getdma              ; aktuelle DMA-Adresse holen
    sub.l   dmastart(pc),d0     ; mit Startadresse vergleichen
    and.l   #$00ffffff,d0
    cmp.l   #512,d0             ; nichts Åbertragen?
    bmi.s   hfehler             ; ja, dann Fehler
    moveq.l #0,d0               ; nein, dann kein Fehler
    bra     _hdone              ; Bus deselektieren und raus
hfehler:
    moveq.l #-1,d0              ; Fehler passiert
    bra     _hdone              ; Bus deselektieren und raus

dmastart:
    dc.l   0                    ; Puffer fÅr DMA-Startadresse

************************
* getdma: Holt aktuelle DMA-Adresse nach d0.l
************************
getdma:
    moveq.l #0,d0               ; d0 lîschen
    move.b  $ffff8609,d0        ; DMA-ZÑhler, Highbyte
    asl.l   #8,d0               ; um ein Byte shiften
    move.b  $ffff860b,d0        ; DMA-ZÑhler, Midbyte
    asl.l   #8,d0               ; um ein Byte shiften
    move.b  $ffff860d,d0        ; DMA-ZÑhler, Lowbyte
    rts

************************
* hwrite: Sektoren schreiben
* Parameter wie hread
************************
_hwrite:
    lea     daccess,a0          ; daccess-Adresse
    st      $43E                ; flock setzen
    move.l  10(a7),-(a7)        ; Pufferadresse
    move.l  (a7),dmastart       ; DMA-Startadresse merken
    bsr.s   _setdma             ; als DMA-Adresse
    addq.l  #4,a7               ; Stack sÑubern
    move.w  #$88,2(a0)          ; Bus auf Horchstation (...pping...pping...)
    moveq.l #0,d0               ; d0.l lîschen
    move.w  16(a7),d0           ; Targetnummer
    asl.w   #5,d0               ; mal 32
    move.w  d0,act_pun          ; Targetnummer merken
    swap    d0                  ; WorthÑlften tauschen
    ori.l   #$A008A,d0          ; Write-Befehl und Moduswort
    move.l  d0,(a0)             ; auf Bus
    move.w  14(a7),device       ; GerÑtenummer holen
    bsr.s   _setss              ; Sektorparameter auf Bus
    bmi     _hto                ; Fehler?
    move.w  #$90,2(a0)          ; DMA-Status lîschen
    nop
    move.w  #$190,2(a0)         ; DMA-SektorzÑhler
    nop
    move.w  8(a7),(a0)          ; Sektoranzahl
    nop
    move.w  #$18A,2(a0)         ; Bus selektieren
    nop
    move.l  #$100,(a0)          ; öbertragung starten
    move.w  #$18A,d0            ; Moduswort fÅr Status
    bsr     _endcmd             ; auf Kommandoende warten
hwx:
    bra     hrx                 ; abschlieûen wie beim Lesen

****************
* setdma: DMA setzen
* IN: 4(a7).L   DMA-Startadresse
****************
_setdma:
    move.b  7(a7),$FFFF860D     ; dmalow
    move.b  6(a7),$FFFF860B     ; dmamid
    move.b  5(a7),$FFFF8609     ; dmahigh
    rts                         ; raus

*****************
* setss: Sektorparameter auf ACSI-Bus
* IN: 8(a7).L   Blocknummer
*     12(a7).W  Sektoranzahl
*****************
_setss:
    move.w  #$8A,2(a0)          ; Bus selektieren
    bsr     _qdone              ; kurzer Timeout
    bmi.s   setsse              ; Fehler?
    move.b  9(a7),d0            ; Sektornummer High
    or.w    device(pc),d0       ; GerÑtenummer einkopieren
    swap    d0                  ; WorthÑlften tauschen
    move.w  #$8A,d0             ; Moduswort
    move.l  d0,(a0)             ; auf Bus damit
    bsr     _qdone              ; kurzer Timeout
    bmi.s   setsse              ; Fehler?
    move.b  10(a7),d0           ; Sektornummer Mid
    swap    d0                  ; WorthÑlften tauschen
    move.w  #$8A,d0             ; Moduswort
    move.l  d0,(a0)             ; auf Bus legen
    bsr     _qdone              ; kurzer Timeout
    bmi.s   setsse              ; Fehler?
    move.b  11(a7),d0           ; Sektornr. Low
    swap    d0                  ; WorthÑlften tauschen
    move.w  #$8A,d0             ; Moduswort
    move.l  d0,(a0)             ; auf Bus legen
    bsr     _qdone              ; kurzer Timeout
    bmi.s   setsse              ; Fehler?
    move.w  12(a7),d0           ; Sektoranzahl
    swap    d0                  ; WorthÑlften tauschen
    move.w  #$8A,d0             ; Moduswort
    move.l  d0,(a0)             ; auf Bus legen
    bsr     _qdone              ; kurzer Timeout
setsse:
    rts                         ; raus hier!

device:
    dc.w    0                   ; Puffer fÅr GerÑtenummer
act_pun:
    dc.w    0                   ; Puffer fÅr Targetnummer

****************
* _hto: Timeout!
****************
_hto:
    moveq   #-1,d0              ; Fehler -1
****************
* _hdone: Bus deselektieren und raus
****************
_hdone:
    move.w  #$80,dmodus         ; FDC selektieren
    nop
    tst.w   daccess
    clr.w   $43E                ; flock lîschen
    rts                         ; und raus

**************************
* reqsense
**************************
reqsense:
if vortex
	moveq   #0,d0
	rts
else
    st      $43e                ; flock setzen
    movem.l d2/d6,-(a7)         ; Register retten

    lea     daccess,a0
    moveq.l #3,d6               ; ZÑhler fÅr 4 DurchlÑufe

    move.w  #$198,2(a0)
    nop
    move.w #$98,2(a0)

    move.w  #1,(a0)             ; Blockanzahl in SektorzÑhler

    clr.l   lbuf+12             ; Fehlermeldung lîschen
    pea     lbuf(pc)            ; Startadresse des Statuspuffers
    move.l  (a7),dmastart       ; DMA-Start merken
    bsr     _setdma             ; in DMA-ZÑhlerregister
    addq.l  #4,sp

rqlp:
    move.w  #$8a,d1             ; Moduswort $8A
    move.w  #$88,2(a0)          ; Bus horch!
    moveq.l #3,d0               ; Request Sense
    or.w    act_pun(pc),d0      ; Targetnummer eincodieren
    swap    d0
    move.w  d1,d0
    move.l  d0,(a0)             ; Request Sense
    bsr     _qdone
    bmi.s   reqerr

    move.w  #16,-(sp)           ; LÑnge der öbertragung in Bytes
    clr.l   -(sp)               ; "Sektornummer" 0
    clr.l   -(sp)               ; Dummy zur Stackanpassung
    bsr     _setss
    lea     10(sp),sp
    bmi.s   reqerr              ; Fehler?

    move.l  #$0a,(a0)           ; letztes Kommandobyte, DMA starten
    move.w  d1,d0               ; Moduswort $8a
    bsr     _endcmd             ; Kommando beenden
    bmi.s   reqerr
    btst    #1,d0               ; Fehler?
    bne.s   reqerr              ; jawohl

    move.l  hz_200,d2           ; Systemzeit holen
    addq.l  #2,d2               ; 2 Ticks warten
as_time_goes_by:
    cmp.l   hz_200,d2           ; zwei Ticks weiter?
    bne.s   as_time_goes_by     ; nein, warten

    dbf     d6,rqlp             ; next one

reqerr:
    move.w  d1,2(a0)            ; Bus selektieren
    nop
    move.w  2(a0),d0            ; Status holen (bei der SH204 immer 0)
    btst    #0,d0               ; DMA-Bit testen
    bne.s   no_err
    bsr     _hdone              ; beenden
    bra.s   reqex2
no_err:
    bsr     getdma              ; aktuelle DMA-Adresse holen
    sub.l   dmastart(pc),d0     ; mit Startadresse vergleichen
    cmp.l   #16,d0              ; nichts Åbertragen?
    bmi.s   reqex2              ; ja, dann Fehler
    bsr     _hdone              ; Bus deselektieren und beenden

    lea     lbuf(pc),a0
    moveq.l #0,d0
    move.b  12(a0),d0           ; Fehlernummer holen
    bra.s   reqexit
reqex2:
    moveq.l #-1,d0
reqexit:
    movem.l (a7)+,d2/d6
    rts
endif

****************************
* my_gemdos: Neuer Traphandler fÅr
* den Gemdos-Trap
* Inspiration und Vorbild ist eine Routine
* von JÅrgen Lock - herzlichen Dank!
****************************
                DC.B "XBRA"
                DC.L magic
o_gemdos:
                DC.L 0          ; alter GEMDOS-Vektor
my_gemdos:
                movea.l $04F2,A0        ; sysbase
                movea.l 8(A0),A0        ; OS-Start
                cmpa.l  2(SP),A0        ; mit Aufrufadresse vergleichen
                bhi     g_cont          ; nicht aus TOS
                adda.l  #192*1024,A0    ; TOS-Ende berechnen (nur gÅltig bis TOS 1.04)
                cmpi.w  #$0106,tosvs    ; TOS 1.06 oder was?
                bmi.s   g_oldend
                adda.l  #64*1024,A0     ; 256-KB-ROMs
g_oldend:
                cmpa.l  2(SP),A0        ; mit Aufrufadresse berechnen
                blo     g_cont
                move    USP,A0
                btst    #13-8,(SP)      ; aus Supervisormodus aufgerufen?
                beq.s   g_user          ; nein, Usermodus
                lea     6(SP),A0        ; Pointer korrigieren
g_user:
                addq.l  #1,gcount       ; ZÑhler mitlaufen lassen
                cmpi.w  #60,(A0)        ; Fcreate-Aufruf?
                beq.s   g_creat
                cmpi.w  #14,(A0)        ; Dsetdrv?
                bne.s   g_cont
                move.l  gcount(PC),dcount ; "Zeitpunkt" merken
                bra.s   g_cont

g_creat:
                move.l  gcount(PC),D0
                sub.l   dcount(PC),D0   ; Wann war das letzte Dsetdrv?
                subq.l  #3,D0           ; lÑnger als 2 Aufrufe her?
                bpl.s   g_cont          ; ja, alles Quatsch

                move.l  A1,-(SP)        ; Register retten
                movea.l 2(A0),A1        ; Zeiger auf Dateiname
                move.l  A0,-(SP)        ; a0 auch retten
                cmpi.w  #$0104,tosvs    ; altes TOS oder BlitterTOS?
                bmi.s   vergleichen
                adda.w  #3,A1           ; Zeiger korrigieren
vergleichen:
                lea     dinfname(PC),A0 ; Zeiger auf "DESKTOP.INF"
                cmpi.w  #$0200,tosvs    ; TOS 2.0 oder hîher?
                bmi.s   g_compare       ; nein, weiter
                lea     dinfnameneu(PC),A0 ; Zeiger auf "NEWDESK.INF"
g_compare:
                moveq   #11,D0          ; LÑnge des Namens
g_lp:
                cmpm.b  (A1)+,(A0)+     ; Namen gleich?
                dbne    D0,g_lp
                bne.s   noinfo          ; nein, weiter

                move.w  bootdev.w,D0    ; Bootlaufwerk holen
                add.b   #'A',D0         ; in ASCII wandeln
                movea.l (SP),A0         ; Zeiger auf Stackframe holen
                movea.l 2(A0),A1        ; Zeiger auf Dateiname
                cmpi.w  #$0104,tosvs    ; TOS1.4 (mit Laufwerkskennung)?
                bpl.s   wrkennung       ; ja, weiter
                lea     dinfdrv(PC),A1  ; Zeiger auf Laufwerkskennung
wrkennung:
                move.b  D0,(A1)         ; Kennung schreiben
                move.l  A1,2(A0)        ; Filenamen-Zeiger neu ausrichten
noinfo:
                movem.l (SP)+,A0-A1
g_cont:
                movea.l o_gemdos(PC),A0
                jmp     (A0)

gcount:
                DC.L 0
dcount:
                DC.L 0
dinfdrv:
                DC.B 0,':\\'
dinfname:
                DC.B "DESKTOP.INF",0
dinfnameneu:
                DC.B "NEWDESK.INF",0
    even

****************************
* xbralook: Sucht in einer Vektorkette
* nach einem Eintrag
* IN: A0.L Vektoradresse
*     D0.L Magic
* OUT: A0.L Startadresse der gesuchten Routine oder -1L oder 0L
*      A1.L Zeiger auf VorgÑnger in der Vektorkette oder -1L
*           A0.L = 0L
*           A1.L = -1L: Kette brach mit Nullzeiger ab, Magic nicht gefunden
*
*           A0.L = -1L
*           A1.L = -1L: Kette ist nicht vollstÑndig xbraisiert, Magic
*                       nicht gefunden
* USES: A0, D0, A1
****************************
xbralook:
    movea.w #-1,a1              ; prev = -1
    move.l  (a0),a0             ; erster Zeiger
xwhile:
    cmp.l   #0,a0               ; 0?
    beq.s   xbraout
    cmp.l   #"XBRA",-12(a0)     ; nach XBRA suchen
    bne.s   xbranfnd
    cmp.l   -8(a0),d0           ; Magic?
    beq.s   xbraout
    move.l  a0,a1
    move.l  -4(a0),a0           ; VorgÑnger holen
    bra     xwhile
xbranfnd:
    move.w  #-1,a1
    move.l  a1,a0               ; nichts gefunden
xbraout:
    rts

****************************
* i_cbhd5: CBHD-Installation, Teil II
****************************
i_cbhd5:
    bsr     outwrprt            ; schreibgschÅtzte Laufwerke melden

* Diese Sequenz soll verhindern, daû das Laufwerk A beim Booten von
* Platte endlos nachlÑuft - wie es das beim normalen AHDI nach einem
* Reset tut. Hallo Alex, hallo JÅrgen!
    move.w  nflops,d0           ; Anzahl der Disklaufwerke
    sub.w   #2,d0               ; 2 StÅck?
    bhs.s   ungehemmt           ; ja, weiter
    move    sr,-(sp)            ; Status retten
    or.w    #$700,sr            ; IRQs aus
    move.b  #14,$ffff8800       ; Port A selektieren
    move.b  $ffff8800,d0        ; aktuellen Wert holen
    bset    #2,d0               ; B: deselektieren
    bne.s   sel_ok              ; war schon deselektiert? Dann weiter
    bclr    #1,d0               ; A: selektieren
    move.b  d0,$ffff8802        ; und zurÅckschreiben
sel_ok:
    move    (sp)+,sr            ; IRQs wieder an
ungehemmt:
    bsr     pool_ins            ; GEMDOS-Speicher erweitern
    add.l   #dcbpool-i_cbhd+256,d0
                                ; + TreiberlÑnge (inkl. Basepage)

    move.l  $84,o_gemdos
    move.l  #my_gemdos,$84      ; eigenen Trap-1-Handler installieren

    tst.w   bootload            ; von Platte gebootet?
    beq     nboot2              ; nein, weiter

    move.l  d0,-(a7)            ; TreiberlÑnge+Pool auf Stack
    move.w  bootdrv(pc),d3      ; Default-Wert fÅr Bootdevice
    move.w  accboot(pc),d4
    
    bsr     zeichenda
if midi
    bne.s   normkey             ; ja, normale Tastatur prÅfen
    move.w  #3,-(sp)            ; MIDI
    move.w  #1,-(sp)            ; Bconstat
    trap    #13
    addq.l  #4,sp
    tst.w   d0
    beq.s   nochar              ; nein, dann weiter

    bsr     misdrive
    bpl.s   nochar
    move.w  bootdrv(pc),d3
    bra.s   nochar
else
    beq.s   nochar
endif

normkey:
    bsr     isdrive             ; ist das ein Laufwerk?
    bmi.s   nochar

    move.w  d0,d3
    move.w  d0,d4
nochar:
    move.w  d4,btdrv2           ; ACC-Bootlaufwerk schon mal merken
    move.w  d3,btdrv1
    move.w  d3,bootdev          ; Bootdevice
    move.b  d3,bootdev          ; wegen Fehler im ROM!

    move.w  d3,-(sp)            ; Bootlaufwerk
    move.w  #14,-(sp)           ; Dsetdrv
    trap    #1                  ; GEMDOS
    addq.l  #4,sp               ; SP korrigieren

    bsr     zeichenda           ; Zeichen da?
    beq.s   aufraeumen          ; nein, weiter

    bsr     isdrive             ; gÅltige Kennung?
    bmi.s   aufraeumen          ; nein, weiter
    move.w  d0,btdrv2
    move.w  d0,d4

* (TreiberlÑnge + Pool liegt noch auf Stack)
aufraeumen:
if midi
    move.w  btdrv2(pc),d3
    move.w  #3,-(sp)            ; MIDI
    move.w  #1,-(sp)            ; Bconstat
    trap    #13
    addq.l  #4,sp
    tst.w   d0
    beq.s   no2ndchar           ; nein, dann weiter

    bsr     misdrive
    bpl.s   no2ndchar
    move.w  btdrv2(pc),d3
no2ndchar:
    move.w  d3,btdrv2
endif

    move.w  btdrv2(pc),d0
    add.b   #'A',d0             ; in ASCII wandeln
    move.b  d0,protstr3+1       ; in String schreiben
    move.w  btdrv1(pc),d0
    add.b   #'A',d0             ; in ASCII wandeln
    move.b  d0,protstr2+1       ; in String schreiben
    lea     bootmsg(pc),a0      ; -> Bootmessage
    bsr     strout              ; ausgeben
    bsr     crlf
    lea     boot2msg(pc),a0     ; -> Bootmessage 2
    bsr     strout
    move.l  baseaddr(pc),-(a7)  ; Anfang des Treibers
    clr.w   -(a7)               ; Dummy
    move.w  #74,-(a7)           ; Mshrink
    trap    #1                  ; GEMDOS
    lea     12(a7),a7           ; Stack sÑubern
* jetzt ist alles ab poolbuf verschwunden

    cmp.l   #'ALEX',$600        ; alte Flexdisk drin?
    beq.s   cbhd_exit           ; ja, dann fertig
    cmp.l   #'ALEX',$5f8        ; neue Flexdisk da?
if midi
    bne.s   instboot
else
    bne.s   instboot            ; nein, dann normal
endif
    move.l  $5fc,a0             ; Zeiger auf FLEXDISK-Struktur
    move.b  bootdev+1,$218(a0)  ; bootdev holen und in FLEXDISK setzen
    bra.s   cbhd_exit

instboot:
    move.l  $4fe,o_execos       ; exec_os retten
    move.l  #vbl,$4fe           ; neu ausrichten
cbhd_exit:
    tst.w   bootload            ; von Platte gebootet?
    bne.s   supexit             ; ja, weiter
    move.l  savssp(pc),a0       ; SSP zurÅckholen

*********************
* super: Zwischen Super- und Usermodus wechseln
* IN: A0   SP
* OUT: D0  alter SP
**********************
super:
    move.l  a0,-(a7)            ; SP auf Stack
    move.w  #32,-(a7)           ; SUPER
    trap    #1                  ; GEMDOS
    addq.l  #6,a7               ; SP korrigieren
supexit:
    rts                         ; raus

**********************
* zeichenda: Prueft auf Zeichen im Tastaturpuffer
**********************
zeichenda:
    move.w  #11,-(sp)           ; Cconis
    trap    #1                  ; Zeichen da?
    addq.l  #2,sp
    tst.w   d0
    rts

if midi
**********************
* misdrive: Holt MIDI-Zeichen und prÅft auf Kennung
* OUT: MI-Flag, wenn ungÅltige Kennung
*      D3.W  Kennung
**********************
misdrive:
    move.w  #3,-(sp)            ; MIDI
    move.w  #2,-(sp)            ; Bconin
    trap    #13
    addq.l  #4,sp

    lea     scancodes(pc),a0    ; -> Scancodetabelle
    moveq.l #15,d3
scanlp:
    cmp.b   0(a0,d3),d0         ; unser Scancode?
    beq.s   scanfd              ; ja
    dbf     d3,scanlp
scanfd:
    rts

scancodes:
    dc.b    30,48,46,32,18,33,34,35,23
    dc.b    36,37,38,50,49,24,25
endif

**********************
* isdrive: Holt Zeichen und prÅft auf Buchstabe
* OUT: MI-Flag, wenn kein Buchstabe
*      D0.W  Nummer des Laufwerks
**********************
isdrive:
    move.w  #8,-(sp)            ; Cnecin
    trap    #1                  ; Zeichen holen
    addq.l  #2,sp

    sub.w   #'A',d0             ; 65 abziehen
    bmi.s   gewandelt           ; ungÅltiges Zeichen
    cmp.w   #'Z'-'A'+1,d0       ; grîûer Z?
    ble.s   gewandelt           ; nein, dann sind wir fertig
    sub.w   #32,d0              ; 32 abziehen
gewandelt:
    rts


*****************
* nboot2: Wird angesprungen,
* wenn nicht von Platte gebootet wurde
*****************
nboot2:
    clr.w   -(a7)               ; Statusmeldung an Eltern (0=alles klar)
    move.l  d0,-(a7)            ; Grîûe des Treibers + GEMDOS-Pool
    move.w  #49,-(a7)           ; Ptermres
    trap    #1                  ; GEMDOS

******************
* vbl: Installiert VBL-Routine fÅr ACC-Boot
* Ist kein VBL-Eintrag mehr frei (fast unmîglich),
* wird kein Fehler gemeldet, aber auch keine Routine
* installiert. Folge: ACCs werden doch von C:
* gebootet - Schicksal...
******************
    dc.b    "XBRA"              ; XBRA-Header
    dc.l    magic
o_execos:
    dc.l    0
vbl:
    suba.l  a0,a0
    bsr     super               ; in den Supervisormodus
    move.l  d0,-(sp)

    move.w  $454,d0             ; Anzahl der VBL-Routinen
    lsl.w   #2,d0               ; mal 4
    movea.l $456,a0             ; Adresse der VBL-Queue
    moveq.l #0,d1
suche:
    addq.w  #4,d1               ; nÑchster Eintrag
    tst.l   0(a0,d1)            ; schon ein Eintrag da?
    beq.s   gefunden            ; nein, dann eintragen
    cmp.w   d0,d1               ; schon am Ende?
    bne.s   suche               ; nein, weitersuchen
    move.l  (sp)+,a0
    bsr     super
    move.l  o_execos(pc),a0
    jmp     (a0)

act_pd:   dc.l 0                ; -> Zeiger auf aktuelle Basepage
etv_tim:  dc.l 0                ; fÅr etv_tim-Vektor
o_bits:   dc.l 0                ; fÅr alten drvbits-Wert

gefunden:
    lea     0(a0,d1),a1         ; Slotadresse
    move.l  #vbl2start,(a1)     ; ->eigentliche VBL-Routine
    move.l  $400,etv_tim        ; alter etv_tim-Vektor

* getactpd: Je nach TOS-Version richtigen
* Zeiger auf act_pd liefern
getactpd:
    move.l  $4f2,a0             ; sysbase
    move.w  2(a0),d1            ; TOS-Version
    move.l  #$602C,d0           ; act_pd bei TOS1.0
    cmp.w   #$102,d1            ; schon BlitterTOS?
    bmi.s   getapexit           ; nein
    move.l  $28(a0),d0          ; act_pd-Adresse holen
getapexit:
    move.l  d0,act_pd           ; merken

; das AES ist da - C: abmelden
abmelden:
    move.w  btdrv2(pc),d0       ; Bootlaufwerk als
    bsr     setdrv              ; aktuelles Laufwerk im act_pd setzen
    move.w  d0,bootdev
    move.w  d0,-(sp)
    move.w  #14,-(sp)           ; Dsetdrv
    trap    #1
    addq.l  #4,sp

    move.l  drvbits,o_bits      ; drvbits
    andi.l  #-1-4,drvbits       ; Laufwerk C abmelden

    lea     $4fe,a0             ; execos-Kette durchsuchen
    move.l  #magic,d0           ; nach dem CBHD-Magic
    bsr     xbralook
    move.l  a0,d0               ; was gefunden?
    bmi.s   eosnfnd
    beq.s   eosnfnd
    move.l  a1,d0               ; gibt es einen VorgÑnger?
    bmi.s   eosnfnd             ; nein
    move.l  o_execos(pc),-4(a1) ; alten Kettenzustand wiederherstellen
    bra.s   eosexit
eosnfnd:
    move.l  o_execos(pc),a0
    move.l  a0,$4fe

eosexit:
    move.l  (sp)+,a0
    bsr     super
    move.l  o_execos(pc),a0
    jmp     (a0)

* Teil 2 der VBL-Routine
    dc.b    "XBRA"              ; noch ein XBRA-Header
    dc.l    magic
    dc.l    0
vbl2start:
    move.l  $400,d0             ; aktuellen etv_tim-Vektor holen
    cmp.l   etv_tim(pc),d0      ; hat sich was getan?
    beq.s   vblexit             ; nein
    move.l  o_bits(pc),d0       ; alter drvbits-Vektor
    and.l   #4,d0               ; Bit fÅr Laufwerk C: ausmaskieren
    or.l    d0,drvbits          ; evt. C: wieder anmelden
    move.w  btdrv2(pc),d0       ; Bootlaufwerk als
    bsr.s   setdrv              ; aktuelles Laufwerk im act_pd setzen

    move.l  $456,a0             ; vblqueue
    move.w  $454,d0             ; nvbls
    lsl.w   #2,d0               ; mal 4
vblweg:
    subq.w  #4,d0
    bmi.s   vblexit
    lea     0(a0,d0),a1
    cmp.l   #vbl2start,(a1)     ; sind wir's?
    bne.s   vblweg              ; nein
    clr.l   (a1)                ; Slot wieder lîschen
vblexit:
    rts

* aktuelles Laufwerk im act_pd setzen
* IN: D0.W  gewÅnschte Laufwerksnummer
setdrv:
    move.l  act_pd(pc),a0       ; ->Zeiger auf aktuelle Basepage
    move.l  (a0),a0             ; Zeiger auf aktuelle Basepage
    move.b  d0,$37(a0)          ; aktuelles Laufwerk setzen
    rts

*********************
* GEMDOS-Puffer erweitern
*********************
pool_ins:
    movea.l $4F2,a3             ; Sysbase
    move.l  32(a3),a2           ; mifl-Zeiger aus Header holen
    cmp.w   #$100,2(a3)         ; TOS 1.0?
    bne.s   pin_0
    movea.w #$56FA,a2           ; mifl-Adresse fÅr TOS1.0
    cmp.l   #$6011986,18(a3)    ; TOS vom 1.6.1986?
    bne.s   pin_0
    movea.w #$7e0a,a2           ; mifl-Adresse fÅr irgendein Exoten-TOS
pin_0:
    lea     16(a2),a2           ; mifl[4]-Adresse berechnen
    lea     dcbpool(pc),a0      ; ->DCB-Pool
    move.w  folders(pc),d0      ; Anzahl der neuen Ordner
    beq.s   bdrom2              ; 0: nix reservieren
    lsl.w   #1,d0               ; mal 2 (1 Ordner belegt 2 DCBs)
    subq.w  #1,d0               ; minus 1 fÅr dbf

pin_1:
    lea     66(a0),a1           ; Adresse des nÑchsten DCB
    move.l  a1,(a0)             ; als Next-Zeiger in den aktuellen DCB
    move.w  #4,-2(a0)           ; DCB-Grîûe in Paragraphen (4*16=64 Bytes)
    movea.l a1,a0               ; nÑchster DCB
    dbf     d0,pin_1            ; 'folders'-mal bitteschîn
    move.l  (a2),-66(a0)        ; letzter DCB deutet auf alte Freiliste
    move.l  #dcbpool,(a2)       ; mifl[4] deutet auf neue Freiliste
    moveq.l #0,d0               ; d0.l lîschen
    move.w  folders(pc),d0      ; Anzahl der Ordner
    lsl.w   #1,d0               ; mal 2 (1 Ordner belegt 2 DCBs)
    mulu    #66,d0              ; mal 66
    rts                         ; und zurÅck

bdrom2:
    moveq   #0,d0               ; d0 = LÑnge des reservierten Speichers
    rts

***************************
* pun-Struktur
***************************
          dc.l    i_cbhd        ; ->Treiber-Start im Speicher
          dc.b    "XBRA"        ; XBRA-Header
          dc.l    magic
o_pun:    dc.l    0             ; alter punptr
puns:     dc.w    0             ; Anzahl physikalischer Laufwerke
_pun:     dcb.b  maxunits+2,$FF ; maxunits+2 Bytes
pstart:   dcb.l   maxunits+2,0  ; Startsektoren der Partitionen
p_cookie: dc.b    "AHDI"        ; Kennzeichen fÅr Cache-Prgs etc.
p_ckptr:  dc.l    p_cookie      ; Zeiger auf p_cookie
p_vers:   dc.b    1,7           ; Versionsnummer des emulierten AHDI
p_maxsec: dc.w    512           ; maximale Sektorgrîûe

bpbtab:   dcb.b   (maxunits+2)*18,0 ; je 18 Bytes fÅr die Partitionen-BPBs
chgtab:   dcb.b   maxunits+2,0  ; Tabelle fÅr Wechselstatus

retrycnt: dc.w    1             ; RetryzÑhler
_retries: dc.w    3             ; maximale Anzahl von Retries
lastrwtm: dc.l    0             ; letzte Schreib/Lesezeit in Ticks
antiboot: dc.w    0             ; Flag fÅr Bootphase
chgflag:  dc.w    0             ; Flag in cbhd_rw
lastacc:  dc.l    0,0,0,0,0,0,0,0   ; Tabelle der letzten
          dc.l    0,0,0,0,0,0,0,0   ; Zugriffszeiten
punbits:  dc.w    0
tosvs:    dc.w    0             ; TOS-Version

btdrv1:   dc.w    2             ; Bootlaufwerk fÅr AUTO-Ordner
btdrv2:   dc.w    2             ; Bootlaufwerk fÅr ACCs und DESKTOP.INF

protstr0: dc.b    'Protected drives:',0
bootmsg:  dc.b    'AUTO folder     :'
protstr2: dc.b    ' A',0
boot2msg: dc.b    'ACCs/DESKTOP.INF:'
protstr3: dc.b    ' A'
ret:      dc.b    13,10,0

.even
***************************
* i_cbhd1: Init-Routine
*          wird als erste groûe Routine angesprungen
***************************
i_cbhd1:
    lea     msg_load(pc),a0     ; Bootmeldung
    bsr     strout              ; ausgeben
    tst.w   bootload            ; Autobootflag gesetzt?
    beq.s   von_disk            ; nein, weiter
    move.l  $472,d0             ; BPB-Vektor holen
    and.l   $476,d0             ; Vektoren verknÅpfen
    and.l   $47e,d0
    move.l  $4f2,a0             ; sysbase
    sub.l   8(a0),d0            ; minus OS-Anfang
    bpl.s   schaumal            ; grîûer sysbase, kein Virus
    cmp.l   #$020000,d0         ; kleiner sysbase + 128 KB?
    blo.s   schaumal            ; nein, kein Virus
    lea     virus(pc),a0        ; -> Virus-Meldung
    bsr     strout              ; ausgeben
    bra.s   schaumal
von_disk:
    suba.l  a0,a0               ; a0 lîschen
    bsr     super               ; in den Supervisormodus
    move.l  d0,savssp           ; SSP retten
schaumal:
    move.l  $4f2,a0             ; sysbase
    move.w  2(a0),tosvs         ; TOS-Version merken
    bsr.s   nboot3              ; DMA-Bus untersuchen

    bsr     crlf                ; CR+LF ausgeben
    tst.w   puns                ; Åberhaupt was gefunden?
    beq.s   isase               ; nein, bloû raus hier

    move.l  $472,o_bpb          ; alten BPB-Vektor retten
    move.l  $476,o_rw           ; alten RWABS-Vektor retten
    move.l  $47E,o_med          ; alten MEDIA-Vektor retten
    move.l  $516,o_pun          ; alter punptr
    move.l  #hbpb,$472          ; neue BPB-Routine
    move.l  #hrw,$476           ; neue RWABS-Routine
    move.l  #hmedia,$47E        ; neue MEDIACH-Routine
    move.l  #puns,$516          ; Zeiger auf pun-Tabelle
    bra     i_cbhd5             ; weiter installieren

* Routinen fÅr erfolgloses Ende
isase:
    tst.w   bootload            ; von Platte gebootet?
    bne.s   isaseb              ; ja, weiter
    move.l  savssp(pc),a0       ; SSP
    bsr     super               ; zurÅck in den Usermodus
    pea     $004cffff           ; Pterm mit Return-Code -1
    trap    #1                  ; GEMDOS

isaseb:
    move.l  baseaddr(pc),-(a7)  ; Basepageadresse
    move.w  #73,-(a7)           ; Mfree
    trap    #1                  ; GEMDOS
    addq.l  #6,a7
    move.b  #$E0,d7             ; DMA-Bootroutine abbrechen
    rts                         ; und raus hier

*******************
* nboot3: Analysiert die Partitionenstruktur
* auf allen ACSI-GerÑten
*******************
neueinlesen:
nboot3:
    movem.l d0-a6,-(sp)         ; Register retten
    move.w  firstdrv(pc),d0     ; erste Laufwerksnummer
    move.w  d0,clun
    moveq.l #0,d1               ; d1 lîschen
    bset    d0,d1               ; entsprechendes Bit setzen
    move.l  d1,cdbit            ; Drive-Bit setzen
    clr.w   cpun                ; aktuelle Unitnummer = 0
    clr.w   puns                ; keine puns bisher gefunden
    moveq.l #maxunits+2-1,d0
    lea     _pun(pc),a0         ; pun-Tabelle initialisieren
clrpun:
    move.b  #$ff,(a0)+
    dbf     d0,clrpun

    pea     $000bffff           ; kbshift
    trap    #13                 ; BIOS
    addq.l  #4,sp               ; SP korrigieren
    and.w   #3,d0               ; SHIFT gedrÅckt?
    move.w  d0,physmode         ; SHIFT-Modus merken

* In der _pun-Tabelle werden alle existenten logischen Laufwerke vermerkt,
* die der Treiber verwaltet. Struktur der Tabelle:
* Unit0 Unit1 Unit2.... Unit(maxunits+2-1)
* Jedes Unit belegt ein Byte, das auf -1 gesetzt wird, wenn das Unit nicht
* vorhanden ist. Ansonsten steht in diesem Byte die Kennung der phys.
* Einheit (= Nummer des Targets und der LUN), auf der das Unit gefunden
* wurde. Vor der Tabelle steht ein Wort, in dem die Anzahl der phys.
* Einheiten vermerkt ist. Nach dem Booten mit CBHD zeigt der Systemvektor
* $516 auf diese Anzahl.
* CBHD verwendet die _pun-Tabelle auch, um die GerÑtenummer innerhalb
* der jeweiligen Targetnummer zu speichern. Format der Unit-Bytes jetzt:
* 0GGG 0TTT  (G=GerÑtenummer, 3 Bits; T=Targetnummer, 3 Bits)

i_cbhd3:
    clr.w   cunit               ; aktuelles GerÑt
gtroot:
    moveq.l #0,d1               ; d1 lîschen
    move.w  cpun(pc),d0
    add.w   d0,d0
    add.w   cunit(pc),d0        ; + GerÑtenummer
    bset    d0,d1               ; Bit d0 setzen
    and.w   punmask(pc),d1      ; in pun-Maske gesetzt?
    beq.s   nextunit            ; nein, weiter

    move.w  cpun(pc),-(a7)      ; aktuelles Target
    move.w  cunit(pc),-(a7)     ; GerÑt
    pea     pbuf(pc)            ; ->Puffer fÅr Rootsektor
    move.w  #1,-(a7)            ; 1 Sektor
    clr.l   -(a7)               ; Block 0 lesen
    bsr.s   pread
    lea     14(a7),a7
    tst.w   d0                  ; Rootsektor gefunden?
    bne.s   i_cbhdt             ; nein, dann weiter

    tst.w   physmode            ; physikalischer Modus?
    beq.s   nextpun             ; nein, weiter
    tst.w   antiboot            ; sind wir wirklich beim ersten Booten?
    bne.s   nextpun             ; nein
    bsr     includeit           ; diese Platte berÅcksichtigen?
    cmp.b   #'y',d0             ; 'y' oder 'Y'?
    bne.s   nextunit            ; nein, weiter
nextpun:
    moveq.l #0,d1
    move.w  cpun(pc),d0         ; aktuelle Targetnr
    add.w   d0,d0               ; mal 2
    add.w   cunit(pc),d0        ; + GerÑtenummer
    bset    d0,d1
    or.w    d1,punbits          ; GerÑt ist da!
    addq.w  #1,puns             ; ja, dann eine phys. Einheit mehr
    bsr     ppu                 ; Partitionen holen
nextunit:
    addq.w  #1,cunit            ; nÑchstes GerÑt
    cmpi.w  #2,cunit            ; schon bei Nr. 2?
    bne     gtroot              ; nein, weiter

i_cbhdt:
    addq.w  #1,cpun             ; ZÑhler fÅr physikalische Einheiten
    cmpi.w  #8,cpun             ; schon gleich 8?
    bne     i_cbhd3             ; nein, weitermachen
    st      antiboot            ; Booten ist nun vorbei
    movem.l (sp)+,d0-a6         ; Register holen
    rts

************************
* pread: physical read
* liest physikalischen Sektor von der Platte
* IN: 4(a7)   Sektornummer
*     8(a7)   Sektoranzahl
*     A(a7)   Pufferadresse
*     E(a7)   aktuelle Unitnummer (0 der 1)
*     $10(a7) Targetnummer
* OUT: d0.w   0=Target gefunden
************************
pread:
    move.w  _retries(pc),retrycnt   ; Retry-ZÑhler initialisieren
pread1:
    lea     4(a7),a0            ; Zeiger auf Stackparameter

* 0(a0)   Sektornummer,   4(a0)   Sektoranzahl
* 6(a0)   Pufferadresse,  10(a0)  Unitnummer, 12(a0) Targetnummer
    move.w  12(a0),-(a7)        ; Targetnummer
    move.w  10(a0),d0           ; Unitnummer holen
    lsl.w   #5,d0               ; mal 32
    move.w  d0,-(a7)            ; auf Stack
    move.l  6(a0),-(a7)         ; Pufferadresse
    move.w  4(a0),-(a7)         ; Sektoranzahl
    move.l  (a0),-(a7)          ; Sektornummer
    bsr     _hread              ; Sektor lesen
    lea     14(a7),a7           ; Stack sÑubern
    tst.w   d0                  ; Fehler?
    bmi.s   pread8              ; Timeout - Target gibt's nicht
    beq.s   pread9              ; nein, weiter
    bsr     reqsense            ; Request Sense
    cmp.b   #$28,d0             ; Wechsel?
    beq.s   pread1              ; ja, nochmal

    subq.w  #1,retrycnt         ; noch ein Versuch
    bpl.s   pread1              ; aber maximal 3

pread8:
    moveq   #$FF,d0             ; mit Fehlermeldung -1
    rts                         ; abschlieûen

pread9:
    move.l  hz_200,d0           ; HZ_200-Wert holen
    addq.l  #8,d0               ; 8 Ticks warten
preada:
    cmp.l   hz_200,d0           ; schon fertig
    bne.s   preada
    moveq.l #0,d0               ; ohne Fehler
    rts                         ; beenden

************************
* ppu: Partitionen suchen
* Wenn im Rootsektor eine Plattengrîûe von 0
* notiert ist, springt die Routine sofort
* zurÅck. Erkennt altes ATARI-Format, Vortex-
* und CBHD-Format.
************************
ppu:
    clr.w   npart               ; PartitionenzÑhler=0
    lea     pbuf+$1C2,a0        ; ->Partitionsinfo im Rootsektor
    tst.l   (a0)+               ; Hd_size
    beq.s   ppu3                ; gleich 0 -> Fehler

    lea     pbuf+$1C6,a0        ; normaler ID-Block
    bsr.s   ppuid               ; nach IDs suchen

    lea     pbuf+$156,a0        ; Zeiger auf erweiterte ID-Blîcke
    bsr.s   ppuid               ; in der ersten HÑlfte suchen lassen
    lea     pbuf+$186,a0        ; Zeiger auf erweiterte ID-Blîcke,
                                ; zweite HÑlfte
    bsr.s   ppuid               ; in der zweiten HÑlfte suchen
    tst.w   npart               ; Partitionen gefunden?
    bne.s   ppu9                ; ja, dann raus

* Wenn keine Partitionen gefunden wurden, wird das GerÑt als eigene
* 20 MB groûe Partition angemeldet
ppu3:
    bsr     nxtdrv              ; nÑchstes GerÑt
    move.w  cpun(pc),d0         ; aktuelle physikalische Einheit
    move.w  device(pc),d1       ; Unitnummer
    asr.w   #1,d1               ; auf Nibblegrenze
    or.w    d1,d0               ; einkopieren
    move.b  d0,(a0)             ; in pun-Tabelle
    clr.w   (a1)                ; Startsektor = 0
    lea     thebpb(pc),a1       ; Zeiger auf 20MB-BPB
    moveq   #17,d0              ; LÑnge des BPB - 1
ppu4:
    move.b  (a1)+,(a2)+         ; kopieren
    dbf     d0,ppu4
    addq.w  #1,clun             ; ein Laufwerk mehr
ppu9:
    rts

**********************
* ppuid: Sucht nach Partitions-IDs
* im Rootsektor
* IN: A0 Zeiger auf Anfang einer Einheit von
* 4 ID-Blîcken
**********************
ppuid:
    moveq   #3,d1               ; max. 4 ID-Blîcke
ppu1:
    movem.l d1/a0,-(a7)         ; Register retten
    tst.b   (a0)                ; Partition gÅltig?
    beq.s   ppu2                ; nein

    addq.w  #1,npart            ; ja, eine Partition mehr
    move.l  (a0)+,d1
    and.l   #$00FFFFFF,d1       ; Kennung ausmaskieren
    cmp.l   #"GEM",d1           ; "GEM"?
    bne.s   ppu2                ; nein, weiter
    tst.l   4(a0)               ; Partitionsgrîûe
    beq.s   ppu2                ; 0: nicht gÅltig
    move.l  (a0),-(a7)          ; Startsektor
    bsr.s   nxtdrv              ; nÑchstes Laufwerk
    move.l  (a7)+,d1            ; Startsektor holen
    tst.w   d0                  ; GerÑtenummer akzeptiert?
    bmi.s   ppu2                ; nein

    movem.l d1/a0-a1,-(a7)      ; Register retten
    move.l  d1,-(a7)            ; Startsektor
    bsr     getbpb              ; BPB aufbauen
    addq.l  #4,a7				; Stack sÑubern
    movem.l (a7)+,d1/a0-a1      ; Register holen
    tst.w   d0                  ; Partition gÅltig?
    bne.s   ppu2                ; nein
    move.w  cpun(pc),d0         ; aktuelle phys. Einheit
    move.w  device(pc),d2       ; Unitnummer holen
    asr.w   #1,d2               ; Devicenummer auf Nibblegrenze
    or.w    d2,d0               ; Devicenummer einkopieren
                                ; wurde in _hread (setss) gesetzt
    move.b  d0,(a0)             ; d0 in pun-Tabelle
    move.l  d1,(a1)             ; Startsektor in Tabelle
    addq.w  #1,clun             ; ein logisches Laufwerk mehr

ppu2:
    movem.l (a7)+,d1/a0         ; Register holen
    lea     12(a0),a0           ; nÑchste Partitionsinfo aus Rootsektor
    dbf     d1,ppu1             ; von vorne das ganze
    rts

*********************
* nxtdrv: nÑchste Partition
*********************
nxtdrv:
    cmpi.w  #maxunits+2,clun    ; Anzahl mit maxunits vergleichen
    bge.s   nxtd9               ; grîûer: Fehler

    move.l  cdbit(pc),d1        ; Drivebitmuster holen
    move.l  drvmask(pc),d0      ; Drive-Maske holen
    and.l   d1,d0               ; Bit gesetzt?
    beq.s   nxtd8               ; nein, dann Fehler

    or.l    d1,drvbits
    lea     protstr2(pc),a0     ; ->Drive-String
    move.w  clun(pc),d0
    add.w   #'A',d0
    move.b  d0,1(a0)
    tst.w   antiboot            ; sind wir noch beim Booten?
    bne.s   nxtd8               ; aber nein
    bsr     strout              ; ausgeben
nxtd8:
    asl.l   #1,d1               ; nÑchstes Drivebit
    move.l  d1,cdbit            ; ablegen

    move.w  clun(pc),d0         ; Devicenummer
    lea     _pun(pc),a0         ; pun-Tabelle
    adda.w  d0,a0               ; plus GerÑtenummer
    lea     pstart(pc),a1       ; Partitionen-Startsektor-Tabelle
    move.w  d0,d1               ; GerÑtenummer
    asl.w   #2,d1               ; mal 4
    adda.w  d1,a1               ; + Anfang der Startsektor-Tabelle
    lea     bpbtab(pc),a2       ; BPB-Tabelle
    move.w  d0,d1               ; GerÑtenummer
    mulu    #18,d1              ; mal 18 (Grîûe des BPB in Bytes)
    adda.w  d1,a2               ; plus Basisadresse
    rts                         ; raus hier

nxtd9:
    moveq   #$FF,d0             ; mit Fehlermeldung -1
    rts                         ; raus

**************************
* getbpb: Holt BPB vom Laufwerk
* und baut ihn im Speicher auf
* IN: a2.l Zeiger auf aktuellen BPB
*     12(a7)  Startsektor der aktuellen Partition
**************************
getbpb:
    move.l  a2,-(a7)            ; ->aktueller BPB
    move.w  cpun(pc),-(a7)      ; aktuelles GerÑt
    move.w  cunit(pc),-(a7)     ; aktuelles Device
    pea     lbuf(pc)            ; Pufferadresse fÅr Bootsektor
    move.w  #1,-(a7)            ; Anzahl der Sektoren (1)
    move.l  18(a7),-(a7)        ; phys. Sektornummer
    bsr     pread               ; Sektor lesen
    lea     14(a7),a7           ; Stack sÑubern
    movea.l (a7)+,a2            ; Zeiger auf aktuellen BPB
    tst.w   d0                  ; Fehler beim Lesen?
    bmi.s   getb9               ; ja, dann BPB ungÅltig
    lea     lbuf(pc),a3         ; Zeiger auf Bootsektor-Puffer
    moveq.l #11,d0              ; d0 = 11
    bsr.s   getlhw              ; 8086 -> 68000
    move.w  d0,(a2)+            ; Bytes/Sektor
    move.w  d0,d1               ; aufheben
    clr.w   d0                  ; d0.w lîschen
    move.b  13(a3),d0           ; spc
    move.w  d0,(a2)+            ; = Sektoren/Cluster
    mulu    d1,d0               ; mal Bytes/Sektor
    move.w  d0,(a2)+            ; = Bytes/Cluster
    moveq.l #17,d0              ; Rootdir-EintrÑge holen
    bsr.s   getlhw              ; 8086 -> 68000
    lsl.l   #5,d0               ; mal 32
    divu    d1,d0               ; durch Bytes/Sektor
    move.l  d0,d1               ; ergibt Anzahl der Rootdir-Sektoren
    swap    d1                  ; Highword (Rest der Division) holen
    tst.w   d1                  ; gesetzt?
    beq.s   getb1               ; nein, weiter
    addq.w  #1,d0               ; aufrunden
getb1:
    move.w  d0,(a2)+            ; rdlen ablegen
    move.w  d0,d2               ; und aufheben
    moveq.l #22,d0              ; d0 = 22, fatlen
    bsr.s   getlhw              ; 8086 -> 68000
    move.w  d0,(a2)+            ; LÑnge der FAT ablegen
    move.w  d0,d1               ; und aufheben
    moveq.l #14,d0              ; d0 = 14, reservierte Sektoren
    bsr.s   getlhw              ; 8086 -> 68000
    add.w   d1,d0               ; plus FAT-LÑnge
    move.w  d0,(a2)+            ; = Start der 2. FAT
    add.w   d1,d0               ; plus FAT-Grîûe
    add.w   d2,d0               ; plus rdlen
    move.w  d0,(a2)+            ; = Datenbeginn
    move.w  d0,d2               ; aufheben
    moveq.l #19,d0              ; d0 = 19, Sektoren auf Laufwerk
    bsr.s   getlhw              ; 8086 -> 68000
    sub.w   d2,d0               ; minus Verwaltungssektoren
    moveq.l #0,d1               ; d1.l = 0
    move.w  d0,d1               ; nutzbare Sektoren
    clr.w   d0                  ; d0.w = 0
    move.b  13(a3),d0           ; Sektoren/Cluster
    divu    d0,d1               ; nutzbare Sektoren / spc
    move.w  d1,(a2)+            ; = Clusteranzahl
    move.w  #1,(a2)             ; BFLAGS, 16-Bit-FAT
    moveq.l #0,d0               ; ohne Fehler
getb9:
    rts                         ; raus hier

********************
* getlhw: Holt High- und Lowbyte eines 8086-Wortes
* und wandelt es in 68000-Format
* IN: a3   Zeiger auf Bereich
*     d0   Offset im Bereich
* OUT: d0.w Wert im 68000-Format
********************
getlhw:
    move.w  d1,-(a7)            ; d1 retten
    move.b  1(a3,d0),d1         ; Highbyte
    lsl.w   #8,d1               ; mal 256
    move.b  0(a3,d0),d1         ; Lowbyte
    move.w  d1,d0               ; nach d0
    move.w  (a7)+,d1            ; Register holen
getexit:
    rts                         ; und raus

**********************
* includeit: Platte wirklich einbinden?
**********************
includeit:
    move.w  cpun(pc),d0         ; Targetnummer
    add.b   #'0',d0             ; in ASCII wandeln
    lea     cstring(pc),a0
    move.b  d0,2(a0)
    move.w  cunit(pc),d0        ; GerÑtenummer
    add.b   #'0',d0             ; in ASCII wandeln
    move.b  d0,4(a0)
    bsr.s   strout              ; String ausgeben

* getkey: Holt Taste
getkey:
    pea     $00020002           ; Bconin, auf Taste warten
    trap    #13                 ; BIOS
    addq.l  #4,sp
    or.w    #32,d0              ; in Kleinbuchstaben wandeln
    rts

cstring:    dc.b    " T0G0",0

**********************
* outwrprt: Gibt Kennungen der schreibgeschÅtzten
* Laufwerke aus
**********************
outwrprt:
    tst.l   wrprot              ; Åberhaupt Laufwerke geschÅtzt?
    beq     getexit             ; nein, raus hier

    lea     protstr0(pc),a0     ; "Protected drives"
    bsr.s   strout

    move.l  wrprot(pc),d3       ; WRPROT-Vektor holen

**********************
* outdrives: Gibt Laufwerkskennungen
* anhand einer Maske aus
* IN: d3.l Bitmaske; ist in der Maske ein Bit gesetzt,
*          wird die korrespondierende Kennung ausgegeben; öbersetzung
*          von Bits in Kennungen wie bei drvbits
**********************
outdrives:
    moveq.l #0,d4               ; ZÑhler lîschen
outcheck:
    btst    d4,d3               ; Laufwerk da?
    beq.s   nextwr              ; nein, dann weiter
    move.l  d4,d0
    add.l   #'A',d0             ; ZÑhler in ASCII wandeln
    move.b  d0,protstr2+1       ; in String schreiben
    lea     protstr2(pc),a0     ; Adresse des Strings
    bsr.s   strout
nextwr:
    addq.l  #1,d4               ; ZÑhler erhîhen
    cmp.l   #32,d4              ; schon alle durch?
    bne     outcheck            ; nein, weiter
crlf:
    lea     ret(pc),a0          ; CR+LF ausgeben

strout:
    move.l  a0,-(a7)            ; a0 auf Stack
    move.w  #9,-(sp)            ; Cconws
    trap    #1                  ; GEMDOS
    addq.l  #6,a7               ; SP korrigieren
    rts

virus:
    dc.b    13,10,'*** ATTENTION: HDV vectors changed -',13,10,7
    dc.b    '*** there might be a virus!',13,10,0

msg_load:
    dc.b    13,10
    dc.b    '-----------------------------------------',13,10
    dc.b    '* CBHD',version,'.',revision
    dc.b    ' (AHDI improved by Claus Brod) *',13,10
    dc.b    '*   Press key to choose boot partition  *',13,10
    dc.b    '-----------------------------------------',13,10
    dc.b    'Active drives:',0

thebpb:
    dc.w    512,002,1024,032,081,082,195,20710,001
* Proto-BPB BPS SPC BPC  DIR SPF FAT DAT NUMCL BFLAGS
* 512 Bytes/Sektor, 2 Sektoren/Cluster, 1024 Bytes/Cluster,
* 32 Rootdir-Sektoren, 81 FAT-Sektoren, FAT 2 ab Sektor 82,
* erster Datensektor 195, 20710 Cluster, 16-Bit-FAT


savssp:   dc.l    0             ; SSP-Puffer
clun:     dc.w    0             ; log. Laufwerksnummer
cpun:     dc.w    0             ; phys. GerÑtenummer
cunit:    dc.w    0             ; aktuelles Unit
cdbit:    dc.l    0             ; Drivebits
npart:    dc.w    0             ; Anzahl der Partitionen
physmode: dc.w    0             ; Flag

ende:
pbuf      = ende
lbuf      = ende+512
poolbuf   = lbuf+512
dcbpool   = poolbuf+2

          end

