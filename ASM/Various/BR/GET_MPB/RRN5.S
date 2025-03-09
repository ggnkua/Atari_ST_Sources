***************************************************************
************************* LUFTSCHLOSS *************************
*              Resetfeste, bootfÑhige RAM-Disk                *
*                  Written & Ω 1988/1989 by                   *
*          Lutz Preûler (Ahornweg 11, 2904 Hatten)            *
*   &  Claus Brod (Am Felsenkeller 2, 8772 Marktheidenfeld)   *
***************************************************************
* V1.0 (CB): WINZRAM - Demo-RAM-Disk zum Lernen               *
* V1.8 (LP): Resetfest + bootfÑhig - herzlichen Dank an Lutz  *
*      Preûler fÅr diese Version sowie an Alex Esser fÅr seine*
*      Tips und seine tolle GEMDOS-Serie                      *
* V1.9 (CB): BootfÑhigkeit abschaltbar; Transfer bis zum      *
*      Gehtnichtmehr (13.5 MBit/s) optimiert, Bootsektor vir- *
*      tuell (BIOS-Fehler -7 beim Lesen/Beschreiben des Boot- *
*      sektors), ACCs von anderen Laufwerken als C: bootbar   *
* V2.0 (CB): Anpassung an die chaotische Screen-Plazierung in *
*      GFABASIC (grrrr...): memtop immer auf 512-Byte-Grenzen *
*      GFABASIC2.02 reserviert sich beim Start den grîûten    *
*      Speicherblock bis auf 16K (liegt meistens am Ende der  *
*      TPA und schlieût mit dem Bildschirm ab); die logische  *
*      Bildschirmadresse wird dann nach der Formel            *
*      "Speicherblockstart+SpeicherblocklÑnge-32768" gesetzt  *
*      Das geht schief, wenn memtop nicht auf einer Pagegrenze*
*      steht, und wahrscheinlich nicht nur dann!              *
* V2.1 (CB): 16-Bit-FAT (beschleunigt GEMDOS!), neue Nachlauf-*
*      routine; XBRA-Kennung von "Winz" auf "WINZ" geÑndert,  *
*      nicht bootbares LUFTSCHLOSS wird durch CAPS LOCK beim  *
*      Reset doch noch bootbar                                *
* V2.2 (LP+CB): Nur noch eine FAT, die andere virtuell (spart *
*      Speicher); Anpassungen an TOS1.0 und ROM-TOS 1.4       *
* V2.3 (br 2/90) VersionsabhÑngigen Teil in alloc_mem ersetzt *
*      ASCII-Ausgaben gestrafft -> unter 2KB gebracht         *
* V2.4 (br 1/91) wegen ungÅltiger MDs jetzt mehrere Versuche! *
*      startup code verkÅrzt s.o., source neu formatiert      *
*      Ballast abgeworfen, einige winzige Optimierungen       *
***************************************************************

kennung   equ "RSt-"        ; ID-Kennungen der RAM-Disk
kennung2  equ "WINZ"        ; zweite Kennung (u.a. fÅr XBRA)

version   equ "2"           ; Versionsnummer
rev       equ "5"           ; Versionsnummer, 2. Stelle

membot          =   $432
memtop          =   $436
themd           =   $48E
hdv_bpb         equ $472    ; BPB-Vektor
hdv_rw          equ $476    ; RWABS-Vektor
hdv_mediach     equ $47e    ; MEDIACH-Vektor
drvbits         equ $4c2    ; drvbits (angemeldete Laufwerke)
bootdev         equ $446    ; Bootlaufwerk

groekb          equ 500     ; Default-Grîûe in KB
                            ; entsprechenden String in zahlstr eintragen!
* --------------------------------------------------------------------------
        .TEXT
start:  lea     mystack,a0      ;get SP
        move.l  a0,d0
        andi.b  #$FC,d0         ;long align
        movea.l d0,sp           ;set SP
        lea   start-$100(pc),a5 ;a5 -> basepage ! used in getgroesse
        sub.l   a5,a0           ;prglen
        move.l  a0,-(sp)        ;size
        move.l  a5,-(sp)        ;start
        clr.w   -(sp)           ;filler
        move.w  #$4a,-(sp)      ;Mshrink
        trap    #1              ;GEMDOS
        lea     12(sp),sp

        clr.l   -(sp)           ; stack
        move    #$20,-(sp)      ; Super
        trap    #1
        addq    #6,sp
        move.l  d0,-(sp)        ; alten SP gleich retten

        bsr.s   initall         ; installieren

        move    #$20,-(sp)      ; zurÅck in Usermodus
        trap    #1
        addq    #6,sp

        clr     -(sp)           ; Pterm0
        trap    #1              ; fini!
* --------------------------------------------------------------------------
* Initialisierungskram muû im Supervisormodus laufen

initall:
        bsr     checkrdsk       ; RAM-Disk schon installiert?
        tst.b   d2
        beq.s   install         ; nein, dann los!
        rts                     ; ja, dann ohne Meldung beenden

install:
        bsr     getgroesse      ; Grîûe und evtl. Kennung holen

        moveq   #0,d0
        move    numcl(pc),d0    ; Disk-Grîûe in Clustern

        move.l  d0,d1           ; Cluster-Anzahl kopieren
        add.l   d0,d1           ; Clusterzahl mal 2
        addq.l  #4,d1           ; plus 4 Bytes (Verwaltungsbytes)

        lsr.l   #8,d1           ; durch 256
        lsr.l   #1,d1           ; durch 2 (insgesamt also durch 512)
        addq    #1,d1           ; +1 zur Sicherheit
        move    d1,fat          ; FAT-Grîûe in Sektoren abspeichern
        addq    #1,d1           ; +1 (virtueller Bootsektor)
        move    d1,fat2         ; Beginn der zweiten FAT
        add     fat(pc),d1      ; +LÑnge einer FAT
        add     rdlen(pc),d1    ; +LÑnge des Wurzelverzeichnisses
        move    d1,datrec       ; ergibt ersten Datensektor

        subq    #1,d1           ; minus eins (Bootsektor nur virtuell)
        sub     fat(pc),d1      ; minus FAT-Grîûe (eine FAT nur virtuell)

        mulu    spc(pc),d0      ; Clusterzahl in Sektoren wandeln (mal SPC)
        add.l   d1,d0           ; + Verwaltungssektoren
        lsl.l   #8,d0           ; mal 256
        add.l   d0,d0           ; mal 2 (--> *512)
        move.l  d0,groesse      ; Gesamt-Grîûe der RAM-Disk in Bytes

        tst     driveno         ; Kennung im Namen?
        bge.s   sbootdev        ; ja, weiter

        move.l  drvbits,d0      ; nein, freies Laufwerk finden
        moveq   #2,d1           ; mit 'D' beginnen
fdlp:
        addq    #1,d1           ; nÑchstes Laufwerk
        cmpi    #16,d1          ; schon 'Q' erreicht?
        beq     error           ; ja: Fehler
        btst    d1,d0           ; Laufwerk vorhanden?
        bne.s   fdlp            ; ja: nÑchstes Laufwerk
        bset    d1,d0           ; Laufwerk anmelden
        move.l  d0,drvbits      ; Systemvar. aktualisieren
        move    d1,driveno      ; Laufwerk fÅr RD-Rout. abspeichern
        addi.b  #65,d1          ; in String schreiben
        move.b  d1,instlw

sbootdev:
        move.b  bootdev+1,d0    ; Bootdevice holen
        ext     d0
        move    d0,oriboot      ; und heftig merken
        move    d0,resoboot

        move.l  #routend,d1     ; Routinenende bestimmen
        subi.l  #(routstart-512),d1  ; Routinengrîûe einschl. PÑckchen berechnen
        move.l  d1,routgroesse  ; und ablegen

        add.l   groesse(pc),d1  ; +'Diskgrîûe'
        bsr     alloc_mem       ; d1 Bytes unter memtop reservieren
        tst.l   d0              ; Fehler aufgetreten?
        bne.s   genugsp         ; nein, weiter
        move.l  drvbits,d0      ; ja, Laufwerk wieder abmelden
        move    driveno(pc),d1
        bclr    d1,d0
        move.l  d0,drvbits
        bra     error           ; Programm abbrechen

genugsp:
        move.l  $436,mtop       ; neues memtop absp.
        move.l  $436,resmtop
        move.l  d1,resmlen      ; LÑnge (tatsÑchlich reserviert) abspeichern

        movea.l d0,a5           ; Adresse der Reset-("PÑckchen")-Routine
        move.l  d0,puffer       ; als Pufferadresse
        move.l  routgroesse(pc),d1  ; plus Routinengrîûe
        add.l   d1,puffer
        addi.l  #512,d0         ; PÑckchen Åberspringen
        move.l  d0,resadr       ; Adresse speichern

        move    driveno(pc),resdrive    ; Laufwerkskennung abspeichern

        move.l  a5,resproc+4    ; eigene Adr. eintragen
        lea     resproc(pc),a6  ; Start der Reset-Routine
        movea.l a5,a3           ; Zieladr. nach a3
        move.l  #resend,d0      ; LÑnge berechnen...
        sub.l   a6,d0
        lsr.l   #1,d0           ; durch 2 dividieren
        subq.l  #1,d0           ; und - 1 wegen dbra-Schleife
loop1:
        move    (a6)+,(a5)+     ; Reset-Routine kopieren
        dbra    d0,loop1

        moveq   #0,d1           ; Reg. lîschen
        move    #254,d2         ; 255 Worte addieren
loop2:
        add     (a3)+,d1        ; PrÅfsumme bilden
        dbra    d2,loop2
        move    #$5678,d2       ; Summe von magic abziehen
        sub     d1,d2
        move    d2,(a3)         ; Ausgleichssumme eintragen

        movea.l resadr(pc),a5   ; Zieladresse
        lea    routstart(pc),a6 ; Startadresse
        move.l  #routend,d0     ; LÑnge berechnen
        sub.l   a6,d0
        lsr.l   #1,d0           ; (/2)-1 wegen fÅr Kopierschleife
        subq.l  #1,d0
loop3:
        move    (a6)+,(a5)+     ; Residente Routinen kopieren
        dbra    d0,loop3

        ; RAM-Disk-Verwaltungssektoren lîschen
        movea.l puffer(pc),a0   ; 'Diskadresse'
        moveq   #0,d0
        move    datrec(pc),d0   ; Erster Datensektor
        subq    #1,d0           ; Bootsektor nur virtuell
        sub     fat(pc),d0      ; minus FAT-Grîûe (eine FAT nur virtuell)
        lsl.l   #7,d0           ; mal 128
        subq.l  #1,d0           ; und minus eins fÅr dbra
clearit:
        clr.l   (a0)+           ; Verwaltungssektoren lîschen
        dbra    d0,clearit

        st      d7              ; Flag setzen
        movea.l resadr(pc),a0   ; Routinen ausfÅhren
        jmp     (a0)            ; und danach zum Programmende
* --------------------------------------------------------------------------
* Fehlerbehandlung

error:  lea.l   fehler(pc),a6   ; Meldung ausgeben
        bsr     message
        move    #7,-(sp)        ; Auf Tastendruck warten
        trap    #1
        addq    #2,sp
        rts                     ; und Programmende
* --------------------------------------------------------------------------
* Grîûe in KB und Kennung aus Basepage/Namen lesen. IN: a5 -> basepage

getgroesse:
        tst.b   128(a5)         ; Kommandozeile leer?
        beq.s   s_dname         ; ja, weiter
        lea.l   129(a5),a0      ; Stringadr. fÅr Auswertung
        bra.s   analyse         ; und auswerten

s_dname:
        clr     -(sp)           ; Prg-Datei suchen
        pea     filename(pc)    ; ->'RR*.PRG'
        move.l  36(a5),a5       ; PD-Adresse der Eltern
        move.l  36(a5),a5       ; PD-Adresse der Groûeltern
        tst.l   36(a5)          ; gleich 0 (dann sind wir im AUTO-Ordner)
        bne.s   noauto          ; nein, weiter
        subq.l  #6,(sp)         ; sonst: '\AUTO\RR*.PRG' (+ 6 byte!)
noauto:
        move    #$4e,-(sp)      ; FSFirst
        trap    #1              ; GEMDOS
        addq    #8,sp
        tst     d0              ; Datei gefunden?
        bne     eingende        ; nicht gefunden -> Default-Werte

        move    #$2f,-(sp)      ; Fgetdta, DTA-Adresse holen
        trap    #1              ; GEMDOS
        addq    #2,sp
        addi.l  #30+2,d0        ; Zeiger auf Dateiname (nach 'RR')
        movea.l d0,a0           ; in a0
analyse:
        move.b  (a0)+,ramboot   ; von RAM-Disk booten?
        moveq   #4,d0           ; hîchstens vier Bytes
        moveq   #0,d1           ; Register lîschen (Grîûe)
        clr     d2              ; (Byteinhalt)
        lea.l   zahlstr(pc),a1  ; Ausgabe-String
eingloop:
        move.b  (a0),d2         ; Byte auslesen
        cmpi.b  #'0',d2         ; < '0' ?
        blt.s   keineziff
        cmpi.b  #'9',d2         ; > '9' ?
        bgt.s   keineziff
        addq    #1,a0           ; Adr. erhîhen
        mulu    #10,d1          ; akt. Wert * 10
        add.l   d2,d1           ; + neue Ziffer
        subi.l  #'0',d1
        cmpi.b  #'0',d2         ; Ziffer '0'?
        bne.s   znicht0
        tst     d1              ; fÅhrende 0 ? (Wert noch 0)
        beq.s   erste0
znicht0:
        move.b  d2,(a1)+        ; nein: Ziffer in String speichern
erste0: dbra    d0,eingloop     ; nÑchste Ziffer

keineziff:
        tst     d1              ; nichts bzw. 0 als Grîûe?
        beq.s   kenneing        ; ja, weiter
        move    d1,numcl        ; sonst: Clusterzahl in BPB eintr.
        clr.b   (a1)            ; Nullbyte an String anhÑngen
kenneing:
        clr     d2
        move.b  (a0),d2         ; Byte auslesen
        cmpi.b  #'C',d2         ; < 'C' ?
        blt.s   eingende
        cmpi.b  #'P',d2         ; > 'P' ?
        bgt.s   eingende
        move.b  d2,instlw       ; Kennung (als Buchst.) abspeichern
        subi    #65,d2          ; in Zahl konvertieren
        move.l  drvbits,d0      ; Laufwerk schon vorhanden?
        btst    d2,d0
        bne.s   eingende        ; ja: spÑter freies LW finden
        bset    d2,d0           ; nein: Laufwerk anmelden
        move.l  d0,drvbits
        move    d2,driveno      ; Kennung abspeichern
eingende:
        rts                     ; zurÅck zum Hauptprogramm
* --------------------------------------------------------------------------
* RAM-Disk schon installiert? OUT: d2.b <>0: RAM-Disk schon da

checkrdsk:
        clr.b   d2              ; Reg. lîschen
        movea.l $42e,a0         ; von phystop abwÑrts untersuchen
chloop: lea     -$200(a0),a0    ; minus 512
        cmpa.l  #$400,a0        ; schon Systemvar. erreicht?
        beq.s   chexit
        cmpi.l  #$12123456,(a0) ; magic?
        bne     chloop
        cmpa.l  4(a0),a0        ; eigene Adresse?
        bne     chloop
        cmpi.l  #kennung,10(a0) ; Kennung richtig?
        bne     chloop
        cmpi.l #kennung2,14(a0) ; Kennung richtig?
        bne     chloop
        clr     d0
        movea.l a0,a1
        move    #255,d1         ; Åber 256-1 Worte
chaloop:
        add     (a1)+,d0        ; PrÅfsumme bilden
        dbra    d1,chaloop
        cmpi    #$5678,d0       ; Magic?
        bne     chloop          ; nein, weitersuchen
        st      d2              ; ja, wir haben's; Flag setzen
chexit: rts
* --------------------------------------------------------------------------
* Reset-Routine ("PÑckchen") liegt vor den eigentlichen Routinen
* im reservierten Bereich an einer 512-Byte-Adresse

resproc:
        dc.l $12123456          ; Magic
        dc.l 0                  ; Platz fÅr die eigene Adresse

        bra.s   resstart        ; Kennung Åberspringen

        dc.l kennung,kennung2   ; Kennung der Reset-Routine

resmlen:
        dc.l 0                  ; LÑnge des reserv. Speichers
resdrive:
        dc.w 0                  ; RAM-Disk-Handle
resoboot:
        dc.w 0                  ; Original-Bootdevice
resmtop:
        dc.l 0                  ; neues memtop

resstart:
        movem.l d0-d7/a0-a6,-(sp)       ; Register retten
        movea.l resadr(pc),a0   ; Routinenadr. holen
        sf      d7              ; Flag lîschen
        jsr     (a0)
        movem.l (sp)+,d0-d7/a0-a6       ; Register zurÅck
        rts                     ; weiter im Reset

resadr: dc.l   0
resend:
* --------------------------------------------------------------------------
* Anfang der residenten Routinen; wird in den reservierten Bereich kopiert

routstart:
        tst.b   d7              ; erste Initialisierung?
        bne.s   rinst1
                                ; Speicher reservieren
        move.l  $436,d1         ; memtop
        sub.l   mtop(pc),d1     ; minus altes memtop
        move.l  groesse(pc),d2  ; Grîûe der RAM-Disk in Bytes
        add.l   routgroesse(pc),d2      ; + ProgrammlÑnge
        cmp.l   d2,d1           ; zu groû?
        blt     ierror          ; ja, Fehler! Jemand hat memtop manipuliert!
        bsr     alloc_mem       ; Speicher reservieren
        tst.l   d0              ; Fehler?
        beq     ierror          ; ja = rts
rinst1:
        lea.l   o_bpb(pc),a0    ; Vektoren umbiegen
        move.l  hdv_bpb,(a0)
        lea.l   mybpb(pc),a0
        move.l  a0,hdv_bpb

        lea.l   o_rw(pc),a0
        move.l  hdv_rw,(a0)
        lea.l   myrwabs(pc),a0
        move.l  a0,hdv_rw

        lea.l   o_media(pc),a0
        move.l  hdv_mediach,(a0)
        lea.l   mymedia(pc),a0
        move.l  a0,hdv_mediach

        move.l  drvbits,d0      ; Laufmerk anmelden
        move    driveno(pc),d1
        bset    d1,d0
        move.l  d0,drvbits

        tst.b   d7              ; erste Initialisierung?
        bne.s   rinst2

* Diese Sequenz soll verhindern, daû das Laufwerk A beim Booten von
* der RAM-Disk endlos nachlÑuft.
        move    sr,-(sp)        ; Status retten
        or      #$700,sr        ; IRQs aus
        move.b  #14,$ffff8800   ; Port A selektieren
        move.b  $ffff8800,d0    ; aktuellen Wert holen
        and.b   #$f8,d0
        or.b    #5,d0           ; Laufwerk A, Seite 0
        move.b  d0,$ffff8802    ; in Port A zurÅckschreiben
        move    (sp)+,sr        ; IRQs wieder an

rinst2:
        lea.l   vorspann(pc),a6 ; Grîûe der RAM-Disk
        bsr     message         ; ausgeben
        lea.l   insttext(pc),a6 ; und das restliche Gelaber
        bsr     message         ; auch

        tst.b   d7              ; erste Initialisierung?
        bne     rinst3

        move    #-1,-(sp)       ; Tastenstatus holen
        move    #11,-(sp)       ; KbShift
        trap    #13             ; BIOS
        addq    #4,sp

        lea     ramboot(pc),a0
        cmp.b   #'D',(a0)       ; Default: Von RAM-Disk booten?
        beq.s   wirbeamen       ; ja

        btst    #4,d0           ; CAPS LOCK gedrÅckt?
        beq     noboot          ; sonst: nicht booten
        bsr     capsback        ; CAPS LOCK zurÅcksetzen
        bra.s   ausderluft      ; und aus dem LUFTSCHLOSS booten

wirbeamen:
        btst    #4,d0           ; CAPS LOCK gedrÅckt?
        bne     noboot          ; ja: nicht booten

ausderluft:
        move    driveno(pc),-(sp)       ; RAM-Disk ist aktuelles Laufwerk
        move    #14,-(sp)       ; Dsetdrv
        trap    #1              ; GEMDOS
        addq    #4,sp

*        move.b  driveno+1(pc),bootdev   ; Hi- UND Low-Byte
        move.b  driveno+1(pc),bootdev+1 ; setzen (wegen BIOS-Fehler)
* --------------------------------------------------------------------------
* Installiert VBL-Routine fÅr Accessory-Boot. Wenn kein VBL-Eintrag frei ist
* (fast unmîglich), wird kein Fehler gemeldet, aber auch nichts installiert.
* Folge: Accessories werden doch wieder von C: gebootet - Schicksal...

vbl:    move    $454,d1         ; Anzahl der VBL-Routinen
        lsl     #2,d1           ; mal 4
        movea.l $456,a0         ; Adresse der VBL-Queue
        subq    #4,d1           ; beim letzten Eintrag anfangen
suche:
        tst.l   0(a0,d1)        ; schon ein Eintrag da?
        beq.s   vblfrei         ; nein, dann eintragen
        subq    #4,d1           ; ja, nÑchster Eintrag
        bne.s   suche           ; noch nicht am Ende, weiter
        lea.l   instboot(pc),a6 ; fÅr Ausgabe v. Boot-Text
        bra     continit        ; weiter im Text

vblfrei:
        lea     0(a0,d1),a1     ; Slotadresse
        lea     vblstart(pc),a0
        move.l  a0,(a1)         ; Startadresse der eigentlichen Routine
        lea     slotaddr(pc),a0
        move.l  a1,(a0)+        ; Slotadresse merken
        move.l  $2C,(a0)        ; alten Line-F-Vektor merken

* getactpd: Je nach TOS-Version richtigen Zeiger auf act_pd liefern

getactpd:
        move.l  $4F2,a0         ; sysbase
        move    2(a0),d1        ; TOS-Version
        move.l  #$602C,d0       ; act_pd bei alten Versionen als Default
        cmp     #$102,d1        ; schon BlitterTOS?
        bmi.s   getapexit       ; nein
        move.l  $28(a0),d0      ; act_pd-Adresse holen
getapexit:
        lea     act_pd(pc),a0
        move.l  d0,(a0)         ; merken
        lea.l   instboot(pc),a6 ; fÅr Ausgabe v. Boot-Text
        bra     continit        ; weiter im Text

slotaddr: dc.l 0                ; VBL-Slotadresse
oldlinef: dc.l 0                ; Puffer fÅr Line-F-Vektor
                                ; in dieser Reihenfolge zwingend!

act_pd:   dc.l 0                ; -> Zeiger auf aktuelle Basepage
etv_tim:  dc.l 0                ; Puffer fÅr etv_tim-Vektor
* --------------------------------------------------------------------------
* Start der eigentlichen VBL-Routine

vblstart:
        move.l  $2C,d0          ; LINE-F-Vektor holen
        cmp.l   oldlinef(pc),d0 ; was geÑndert?
        beq.s   vblexit         ; nein, raus hier

* das AES ist da - C: abmelden, wenn vorhanden
        move.l  $4c2,d0         ; drvbits
        btst    #2,d0           ; C: da?
        bne.s   abmelden        ; ja, weiter
        moveq   #0,d0           ; nein: VBL-Routine ausklinken
        bra.s   setvbl
abmelden:
        clr.b   $446            ; alles wegen dieses ROM-Fehlers

        bsr.s   setdrv          ; aktuelles Laufwerk im act_pd setzen
        move.l  $4C2,d0         ; drvbits
        andi    #$FFFB,d0       ; Laufwerk C abmelden
        move.l  d0,$4C2         ; drvbits schreiben
        lea     etv_tim(pc),a0
        move.l  $400,(a0)       ; etv_timer merken
        lea     vbl2start(pc),a0
        move.l  a0,d0           ; neue VBL-Slotadresse
        bra.s   setvbl          ; setzen

* Teil 2 der VBL-Routine
vbl2start:
        move.l  $400,d0         ; aktuellen etv_tim-Vektor holen
        cmp.l   etv_tim(pc),d0  ; hat sich was getan?
        beq.s   vblexit         ; nein

        ori.l   #4,$4c2         ; Laufwerk C wieder anmelden
        bsr.s   setdrv          ; aktuelles Laufwerk im act_pd setzen
        moveq   #0,d0           ; VBL-Routine ausklinken

* Setzt VBL-Adresse um. IN: D0 neue Slotadresse
setvbl:
        move.l  slotaddr(pc),a1 ; Slotadresse holen
        move.l  d0,(a1)         ; VBL-Routine neu setzen
vblexit:
        rts

* aktuelles Laufwerk im act_pd setzen
setdrv:
        move    $446,d0         ; Bootdevice holen
        move.l  act_pd(pc),a0   ; Adresse des Zeigers auf aktuelle Basepage
        move.l  (a0),a0         ; Zeiger auf aktuelle Basepage
        move.b  d0,$37(a0)      ; aktuelles Laufwerk setzen
        rts

capsback:
        bclr    #4,d0           ; CAPS LOCK
        move    d0,-(sp)        ; wieder zurÅcksetzen
        move    #11,-(sp)       ; KbShift
        trap    #13
        addq    #4,sp
        rts

noboot:                         ; Original-Bootlaufwerk anmelden
        bsr.s   capsback        ; CAPS LOCK zurÅcksetzen
        move.b  bootdev+1,d2    ; altes Bootlaufwerk
        ext     d2
        cmp     driveno(pc),d2  ; bootdev = eigene Kennung?
        bne.s   setdrive
        move    oriboot(pc),d2  ; ja: Kennung holen
setdrive:
        move    d2,-(sp)
        move    #14,-(sp)       ; Dsetdrv
        trap    #1
        addq    #4,sp
        move.b  d2,bootdev
        move.b  d2,bootdev+1    ; wegen BIOS-Fehler

rinst3: lea.l   instcopyrt(pc),a6 ; Copyright ausgeben

continit: bsr.s   message

ierror: rts                     ; zurÅck zur PÑckchenroutine
* --------------------------------------------------------------------------
* IN:  a6 Stringadresse

message:  move.l  a6,-(sp) ; Stringadresse
          move    #9,-(sp) ; Cconws
          trap    #1       ; GEMDOS
          addq    #6,sp
          rts
* --------------------------------------------------------------------------
* Ab hier folgende die eigentlichen RAM-Disk-Routinen (CB)
* --------------------------------------------------------------------------
* mybpb: Eigene GETBPB-Routine

        dc.b   "XBRA"           ; XBRA-Struktur
        dc.l   kennung2
o_bpb:  dc.l 0                  ; ursprÅngliche Adresse
mybpb:
        move    driveno(pc),d0
        cmp     4(sp),d0        ; RAM-Disk gemeint?
        beq.s   newbpb          ; ja: an die Arbeit...
        movea.l o_bpb(pc),a0    ; Original-Routine aufrufen
        jmp     (a0)

newbpb:
        lea.l   protobpb(pc),a0 ; Zeiger zurÅckgeben
        move.l  a0,d0
        rts                     ; das war's
* --------------------------------------------------------------------------
* myrwabs: Eigene RWABS-Routine

        dc.b   "XBRA"           ; XBRA-Struktur
        dc.l   kennung2
o_rw:   dc.l 0                  ; ursprÅngliche Adresse
myrwabs:
        move    driveno(pc),d0
        cmp     14(sp),d0       ; RAM-Disk gemeint?
        beq.s   newrw           ; ja: an die Arbeit...
        movea.l o_rw(pc),a0     ; Original-Routine aufrufen
        jmp     (a0)

newrw:                          ; RWABS-Routine
        move    12(sp),d0       ; Ab welchem Sektor?
        ext.l   d0
        bne.s   nobootsec       ; kein Bootsektor gemeint
        moveq   #-7,d0          ; Unknown Media - Bootsektor nicht lesbar
        rts                     ; und raus

nobootsec:
        move    10(sp),d1       ; Sektoranzahl
        move.l  6(sp),a0        ; Pufferadresse holen
        beq     newmedia        ; keine Pufferadresse
        move.l  d0,d2           ; Sektornummer
        add.l   d1,d2           ; plus Anzahl
        lea.l   fat2(pc),a2
        cmp     (a2),d2         ; letzter Sektor vor FAT2?
        ble.s   rw_rout
        sub     -2(a2),d0       ; Sektornummer minus FAT-LÑnge
        cmp     #1,d0           ; Zugriff auf FAT1 und FAT2?
        bge.s   rw_rout         ; nein

        movem.l d0-d2/a0/a1,-(sp)       ; Register retten
        move    24(sp),-(sp)    ; fÅr erneuten Aufruf -- 4(sp)
; im ersten Durchgang bis FAT1-Ende kopieren
        moveq   #1,d1
        sub.l   d0,d1           ; Anzahl der Sektoren
        move.l  d1,d2
        subq.l  #1,d2
        swap    d2
        lsr.l   #7,d2
        move.l  d2,a2           ; in Bytes fÅr Adreûdifferenz
        add.l   fat(pc),d0      ; + FAT-LÑnge
        subq.l  #1,d0           ; Startsektor
        bsr.s   rw_rout         ; ans Werk
        addq    #2,sp           ; Stack korrigieren
        movem.l (sp)+,d0-d2/a0/a1       ; Register zurÅck
; zweiter Durchgang: Ab FAT2 (=FAT1) kopieren
        add.l   d0,d1
        subq.l  #1,d1           ; Anzahl der Sektoren
        moveq   #1,d0           ; Startsektor = 1
        add.l   a2,a0           ; Pufferadresse korrigieren

rw_rout:
        subq    #1,d0           ; Sektornummer minus eins (Bootsektor
                                ; ist virtuell!)
        swap    d0
        lsr.l   #7,d0           ; mal 512
                                ; schneller als "lsl.l #8,d0 - add.l d0,d0"

        movea.l puffer(pc),a1   ; 'Diskadresse'
        adda.l  d0,a1           ; plus Offset
        moveq   #0,d2           ; Bitnummer 0
        btst    d2,5(sp)        ; R/W-Flag testen
        beq.s   copysec         ; Lesen
        exg.l   a0,a1           ; Schreiben: Adressen vertauschen
copysec:
        move.l  a0,d0           ; Adresse gerade?
        btst    d2,d0           ; Bit 0 gesetzt?
        bne.s   ungerade        ; ja, dann ungerade Adresse
        move.l  a1,d0           ; Adresse gerade?
        btst    d2,d0           ; Bit 0 gesetzt?
        beq.s   gerade          ; nein, dann gerade

ungerade:
        subq.l  #1,d1           ; -1 wegen dbra
u1:     moveq   #63,d0          ; 64*8 Bytes kopieren

cplp:
        move.b  (a1)+,(a0)+
        move.b  (a1)+,(a0)+
        move.b  (a1)+,(a0)+
        move.b  (a1)+,(a0)+
        move.b  (a1)+,(a0)+
        move.b  (a1)+,(a0)+
        move.b  (a1)+,(a0)+
        move.b  (a1)+,(a0)+
        dbra    d0,cplp         ; die nÑchsten 8 Bytes
        dbra    d1,u1           ; nÑchster Sektor
        bra.s   newmedia        ; ohne Fehler raus

* folgende Verschiebeschleife ist 13.51 MBit/s schnell - wer schafft mehr?

gerade: movem.l d2-d7/a2-a6,-(sp)       ; Register retten
        move    d1,-(sp)                ; ZÑhler auf Stack

cpeven: movem.l (a1)+,d0-d7/a2-a6       ; 52 Bytes holen
        movem.l d0-d7/a2-a6,(a0)        ; und schreiben
        movem.l (a1)+,d0-d7/a2-a6       ; 52 Bytes holen
        movem.l d0-d7/a2-a6,52(a0)      ; und schreiben
        movem.l (a1)+,d0-d7/a2-a6       ; 52 Bytes holen
        movem.l d0-d7/a2-a6,104(a0)     ; und schreiben
        movem.l (a1)+,d0-d7/a2-a6       ; 52 Bytes holen
        movem.l d0-d7/a2-a6,156(a0)     ; und schreiben
        movem.l (a1)+,d0-d7/a2-a6       ; 52 Bytes holen
        movem.l d0-d7/a2-a6,208(a0)     ; und schreiben
        movem.l (a1)+,d0-d7/a2-a6       ; 52 Bytes holen
        movem.l d0-d7/a2-a6,260(a0)     ; und schreiben
        movem.l (a1)+,d0-d7/a2-a6       ; 52 Bytes holen
        movem.l d0-d7/a2-a6,312(a0)     ; und schreiben
        movem.l (a1)+,d0-d7/a2-a6       ; 52 Bytes holen
        movem.l d0-d7/a2-a6,364(a0)     ; und schreiben
        movem.l (a1)+,d0-d7/a2-a6       ; 52 Bytes holen
        movem.l d0-d7/a2-a6,416(a0)     ; und schreiben
        movem.l (a1)+,d0-d7/a2-a4       ; 44 Bytes holen
        movem.l d0-d7/a2-a4,468(a0)     ; und schreiben
        lea     512(a0),a0
        subq    #1,(sp)                 ; ZÑhler auf Stack dekrementieren
        bne     cpeven                  ; nÑchster Sektor

        addq    #2,sp                   ; Stack justieren (ZÑhler!)
        movem.l (sp)+,d2-d7/a2-a6       ; Register zurÅckholen

newmedia:
        moveq     #0,d0         ; kein Fehler
                                ; dient auch als neue Mediachange-Routine
                                ; (0=kein Wechsel)
        rts                     ; und raus
* --------------------------------------------------------------------------
* mymedia: Eigene Mediachange-Routine

        dc.b   "XBRA"           ; XBRA-Struktur
        dc.l   kennung2
o_media:
        dc.l 0                  ; ursprÅngliche Adresse
mymedia:
        move    driveno(pc),d0
        cmp     4(sp),d0        ; RAM-Disk gemeint?
        beq.s   newmedia        ; ja: an die Arbeit...
        movea.l o_media(pc),a0  ; Original-Routine aufrufen
        jmp     (a0)
* --------------------------------------------------------------------------
* alloc_mem: GEMDOS-Speicherverwaltung manipulieren
*           (Dank an Alex Esser, siehe auch ST-Computer-Sonderheft Nr.2)
* IN:  d1.l Grîûe des zu reservierenden Speicherblocks
*           Die Routine rundet die Startadresse auf die nÑchstgelegene
*           512-Byte-Grenze unterhalb der eigentlich erforderlichen Grenze
*      d1.l = 0: Nur Grîûe des obersten SpeicherhÑppchens holen
* OUT: d0.l Startadresse/neues memtop
*           oder: Grîûe des obersten SpeicherstÅcks (wenn d1.l=0)
*           oder: 0L (Fehler)
* --------------------------------------------------------------------------
alloc_mem:
*        movea.l $4f2,a0         ; sysbase
*        move    2(a0),d0        ; Versionsnummer aus TOS-Header holen
*        lea     tosversion(pc),a0
*        move    d0,(a0)         ; TOS-Version merken
*        cmpi    #256,d0         ; TOS 1.0 (bis ROM-TOS 6.2.86) ?
*        bne.s   tv102
*        lea.l   $56ec,a0        ; MPB-Adresse fÅr TOS1.0
*        bra.s   alloc_st
*tv102:  cmpi    #258,d0         ; TOS 1.2 (Blitter-TOS) ?
*        bne.s   tv104
*        lea.l   $7e8e,a0        ; MPB-Adresse fÅr TOS1.2
*        bra.s   alloc_st
*tv104:  cmpi    #260,d0         ; TOS 1.4 (ganz neu) ?
*        bne.s   err
*        lea.l   $5328,a0        ; MPB-Adresse fÅr TOS1.4 (ROM-Version)
* --------------------------------------------------------------------------
* VersionsabhÑngigen Teil ersetzt, lÑuft damit auf allen RAM- (ab 20.11.85)
* & ROM-TOS-Versionen - inkl. STE-TOS 1.6 vom 29.7.89 & TT-TOS 3.01 br 2/90
* AusfÅhrliche Diskussion der Methode im Text zu "get_mpb (the real one!)".
* --------------------------------------------------------------------------
* IN: nothing, OUT: a0 -> MPB, USES: a1, d0, d2, (PRESERVES d1)
* --------------------------------------------------------------------------
          lea       $48E,a1     ;themd
          move.l    $436,d2     ;memtop
          move.l    $432,d0     ;Suchende = membot
          sub.l     d0,d2       ;freien Speicher berechnen
          cmp.l     8(a1),d2    ;themd->m_length==memtop-membot ?
          bne.s     loop_1      ;fehlt schon etwas

          lea       $4000,a0    ;Suchbeginn fÅr mp_mfl
t_loop:   addq      #2,a0       ;nur gerade Adressen
          cmp.l     a0,d0       ;membot erreicht?
          bls       err
          cmp.l     (a0),a1     ;Zeiger gefunden?
          bne       t_loop      ;weiter suchen
          bra.s     alloc_st    ;das war's

loop_1:   move.l    d0,a0       ;Suchbeginn = membot
          moveq     #0,d2       ;VersuchszÑhler
loop_2:   subq      #2,a0       ;nur gerade Adressen
          cmpa.l    #$2000,a0   ;Endadresse erreicht?
          bls.s     stuck       ;war leider nichts!

          cmpa.l    (a0),a1     ;Zeiger gefunden?
          bne       loop_2      ;weiter suchen

* PlausibilitÑts-Tests fÅr MD's, falls (a0) = mp_mal - kritisch!

          btst      #0,15(a0)   ;m_own gerade? (!)
          bne       loop_2      ;weiter testen
          btst      #0,7(a0)    ;m_start gerade? (!)
          bne       loop_2      ;weiter testen
          btst      #0,11(a0)   ;m_length gerade? (!)
          bne       loop_2      ;weiter testen

          movea.l   a0,a1       ;evtl. neuer MD
          tst.l     12(a0)      ;m_own leer, kein Besitzer? (!)
          bne       loop_1      ;nÑchsten Zeiger suchen

          subq      #4,a0       ;Adresse des MPB (!!!)
          bra.s     alloc_st    ;gotcha

stuck:    addq      #1,d2       ;# Versuche hochzÑhlen
          move.l    a1,a0       ;ab hier weitersuchen
          move.l    (a1),a1     ;wieder alten Zeiger nehmen
          cmp       #10,d2      ;max. Anzahl der Versuche = 11
          bls       loop_2      ;nochmal versuchen!
          bra.s     err         ;Fehler
* --------------------------------------------------------------------------
alloc_st:
        move.l  (a0),d0         ; Zeiger auf mfl-Beginn
        beq.s   err             ; mfl leer!
src_fr1:
        movea.l d0,a0
        move.l  (a0),d0         ; Zeiger auf nÑchsten MD holen
        bne.s   src_fr1         ; noch nicht letzter Block, dann weiter
        move.l  $436,d0         ; memtop, alte Obergrenze holen
        sub.l   4(a0),d0        ; minus M_START = freier Speicher
        cmp.l   8(a0),d0        ; M_LENGTH, sollte gleich sein
        bhi.s   err             ; ungleich, Speicherverwaltung durcheinander
        tst.l   d1              ; reservieren oder nur abfragen?
        beq.s   ok              ; nur abfragen
        cmp.l   d1,d0           ; genug Speicher frei?
        blt.s   err             ; nein, dann Fehler
        move.l  $436,d0         ; memtop, alte Obergrenze
        sub.l   d1,d0           ; minus LÑnge = neues Speicherende

        move.l  d0,d2           ; d0.l merken
        and.l   #$01ff,d2
        beq.s   reservieren     ; war schon auf 512-Byte-Grenze?
        add.l   d2,d1           ; reservierte Grîûe entsprechend erhîhen
        and     #$FE00,d0       ; untere 9 Bits lîschen

reservieren:
        move.l  d0,$436         ; in memtop ablegen
        movea.l d0,a1           ; neues Speicherende ins Adreûregister
        suba.l  4(a0),a1        ; minus M_START = LÑnge des neuen Blocks
        move.l  a1,8(a0)        ; M_LENGTH, neue LÑnge im mfl-Block merken
ok:     rts                     ; alles roger
err:    moveq   #0,d0           ; Fehler!
        rts
* --------------------------------------------------------------------------
puffer:   dc.l 0                ; Adresse der RAM-Disk-Daten
protobpb: dc.w 512
spc:      dc.w 2,1024
rdlen:    dc.w 7
fat:      dc.w 5
fat2:     dc.w 6
datrec:   dc.w 18               ; BPB der RAM-Disk
numcl:    dc.w groekb
bflags:   dc.w 1                ; 16-Bit-FAT
          dc.l 0

driveno:  dc.w -1               ; Laufwerksnummer der RAM-Disk
ramboot:  dc.b 'D',0            ; RAM-Boot-Flag (oberes Byte wird benutzt)
oriboot:  dc.w 0
groesse:  dc.l 0
routgroesse:   dc.l 0
mtop:     dc.l 0

vorspann:   dc.b 13,10," LUFTSCHLOSS V",version,".",rev,' br     '
zahlstr:    dc.b "500",0,0,0
insttext:   dc.b " KB, "
instlw:     dc.b "X:",13,10,0
instboot:   dc.b " Boote vom LUFTSCHLOSS...",13,10,10,0
instcopyrt: dc.b " Ω 1988 by Lutz Preûler & Claus Brod",13,10,10,0
* --------------------------------------------------------------------------
*          bis hier wird in den reservierten Bereich kopiert
routend:
fehler:   dc.b "!FEHLER!",7,13,10,0
fname2:   dc.b "\\AUTO\\"
filename: dc.b "RR*.PRG",0
* --------------------------------------------------------------------------
          .BSS
          ds.l      $100      ;stack
mystack:
* --------------------------------------------------------------------------
