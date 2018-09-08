; JUNIOR.Q
; Assemblerquellcode zur Ansteuerung des Juniorprommers
; LageunabhÑngiges Assemblermodul zur Einbindung in Hochsprachen
; ParameterÅbergabe auf dem Stack nach C-Konventionen
; R.Hofmann 1/88

mfport  = $fffffa01

psgrd   = $ffff8800
psgwr   = $ffff8802
max_f   = 11

strobe  = %00100000

azb     = %00010000
lazb    = %01000000

bpe     = 82
; Indizies in die Typentabelle
; 82 Bytes/Eintrag
zkette  = 0
kapazi  = 30
seite   = 34
alg     = 38
i_zeit  = 40
m_zeit  = 42
trials  = 44
standby = 46
read    = 48
odis    = 50
program = 52
pr_ver  = 54
pr_inh  = 56
page_wr = 58
manufac = 60
devcode = 61
tsmask  = 62
frei3   = 63
frei1   = 64
frei2   = 66

m_a10   = 68
m_a11   = 70
m_a12   = 72
m_a13   = 74
m_a14   = 76
m_a15   = 78
m_a16   = 80

        text

funktion movem.l d1-d7/a0-a6,-(sp)      ; Hauptverteiler
        lea funktion(pc),a6             ; Relative Basisadresse
        lea 62(a7),a5                   ; Parameterbasis
        move.l a5,parbas(a6)            ; "
        clr.l -(sp)
        move.w #$20,-(sp)               ; SUPER
        trap #1                         ; GEMDOS
        addq.l #6,sp                    ; ab hier im Supervisormodus
        move.l d0,alt_ssp(a6)           ; SSP retten

        lea stopikb(a6),a0              ; IKBD:Stop
        move.l a0,-(sp)
        clr.w -(sp)
        move.w #25,-(sp)                
        trap #14
        addq.l #8,sp
        move sr,alt_sr(a6)              ; SR retten
        move.w #100,d0                  ; 0.01 s warten
        bsr zeit
        ori #$0700,sr                   ; IRQ's abschalten

        bsr direkt                      ; Funktion aufrufen
        move.l d0,-(sp)
        move alt_sr(a6),sr
        lea startikb(a6),a0             ; IKBD:Start
        move.l a0,-(sp)
        clr.w -(sp)
        move.w #25,-(sp)
        trap #14
        addq.l #8,sp

        move.l alt_ssp(a6),-(sp)
        move.w #$20,-(sp)
        trap #1
        addq.l #6,sp                    ; und im User-Modus zurÅckkehren
        move.l (sp)+,d0
        movem.l (sp)+,d1-d7/a0-a6
ende    rts


direkt  move.w -2(a5),d0                ; Funktionsnummer
        tst.w d0                        ; im legalen Bereich ?
        bmi.s ende
        cmp.w #max_f,d0
        bhi.s ende
        lsl.w #2,d0                     ; zu Zeiger
        move.l f_adr(pc,d0.w),a0        ; Funktionsadresse
        add.l a6,a0                     ; Offset
        jmp (a0)                        ; Funktion anspringen


; Zeiger auf Funktionen
f_adr   dc.l srx                        ; 0=SRX 
        dc.l srd                        ; 1=SRD
        dc.l az                         ; 2=AZ
        dc.l setzea                     ; 3=SETZEA
        dc.l lese                       ; 4=LESEN
        dc.l ltest                      ; 5=LTEST
        dc.l vergl                      ; 6=VERGL
        dc.l vtest                      ; 7=VTEST
        dc.l ipro                       ; 8=PROG
        dc.l tstest                     ; 9=TRTEST
        dc.l waltp                      ; 10=TYP
        dc.l init                       ; 11=INIT
  
sra     movem.l d0/d2,-(sp)
        moveq #2,d1
        or.b adrsra(a6),d0
        move.w d0,-(sp)
        bsr srxd                        ; Byte herausschieben
        move.w (sp),d0                  ; alter Wert
        move.b d0,d1
        and.b #%11100000,d0             ; Testen auf énderung
        move.b letzt_a2(a6),d2
        and.b #%11100000,d2
        cmp.b d0,d2
        beq.s ta15                      ; Alles gleich
        scs d2
        move.w #1000,d0                 ; 0.1s Verzîgerung
        tst.b d2
        bne.s zver
        move.w #8000,d0                 ; 0.8s Verzîgerung
zver    bsr zeit
ta15    and.b #1,d1                     ; A15 auf énderung testen
        move.b letzt_a2(a6),d0
        and.b #1,d0
        cmp.b d0,d1
        beq.s uspr                      ; Alles gleich
        moveq #50,d0                    ; 5 mS Verzîgerung
        bsr zeit
uspr    move.w (sp)+,d0                 ; Alter Vergleichswert
        move.b d0,letzt_a2(a6)          ; als Byte
        movem.l (sp)+,d0/d2
        move.b d0,letzt_a(a6)
        rts

srb     moveq #4,d1                     ; Taktbit
        move.b d0,letzt_b(a6)
        or.b adrsrb(a6),d0              ; Adressen
        eori.b #%01000000,d0            ; A13 invers
        bra.s srxd

src     moveq #8,d1                     ; Datenschieberegister
        bra.s srxd

srx     move.w (a5),d0                  ; Daten
        moveq #1,d1
decoder lsl.w #1,d1
        subq.w #1,2(a5)                 ; Takt
        bne.s decoder

; Bedient Schieberegister SRA bis SRC
srxd    movem.l d2-d3/a0,-(sp)
        lea psgwr,a0
        move.b #15,-2(a0)               ; Portb
        move.w rwstat(a6),d3
        move.w d3,d2                    ; 1.Bit
        roxl.b #1,d0
        roxr.b #1,d2
        move.b d2,(a0)
        or.b d1,d2
        move.b d2,(a0)
        move.w d3,d2                    ; 2.Bit
        roxl.b #1,d0
        roxr.b #1,d2
        move.b d2,(a0)
        or.b d1,d2
        move.b d2,(a0)
        move.w d3,d2                    ; 3.Bit
        roxl.b #1,d0
        roxr.b #1,d2
        move.b d2,(a0)
        or.b d1,d2
        move.b d2,(a0)
        move.w d3,d2                    ; 4.Bit
        roxl.b #1,d0
        roxr.b #1,d2
        move.b d2,(a0)
        or.b d1,d2
        move.b d2,(a0)
        move.w d3,d2                    ; 5.Bit
        roxl.b #1,d0
        roxr.b #1,d2
        move.b d2,(a0)
        or.b d1,d2
        move.b d2,(a0)
        move.w d3,d2                    ; 6.Bit
        roxl.b #1,d0
        roxr.b #1,d2
        move.b d2,(a0)
        or.b d1,d2
        move.b d2,(a0)
        move.w d3,d2                    ; 7.Bit
        roxl.b #1,d0
        roxr.b #1,d2
        move.b d2,(a0)
        or.b d1,d2
        move.b d2,(a0)
        move.w d3,d2                    ; 8.Bit
        roxl.b #1,d0
        roxr.b #1,d2
        move.b d2,(a0)
        or.b d1,d2
        move.b d2,(a0)

        move.b #14,-2(a0)               ; Port a
        move.b -2(a0),d2
        or.b #strobe,d2                 ; Strobe =1
        move.b d2,(a0)
        and.b #255-strobe,d2            ; Strobe = 0
        move.b d2,(a0)
        movem.l (sp)+,d2-d3/a0
        rts

srd:           

; Bedient srd
srdd    movem.l d3-d4/a1-a2,-(sp)       ; Eingangsschieberegister lesen
        lea psgwr,a1
        move.b #14,-2(a1)               ; Psg Port A
        move.b (a1),d3                  ; Strobeimpuls geben
        or.b #strobe,d3
        move.b d3,(a1)
        lea mfport-1,a2
        and.b #255-strobe,d3
        move.b d3,(a1)
        moveq #32,d3                    ; Register vorbesetzen
        moveq #0,d4
        moveq #0,d0
        move.b #15,-2(a1)               ; Psg Port B

        roxr.w (a2)
        move.b d3,(a1)
        addx.w d0,d0
        move.b d4,(a1)

        roxr.w (a2)
        move.b d3,(a1)
        addx.w d0,d0
        move.b d4,(a1)

        roxr.w (a2)
        move.b d3,(a1)
        addx.w d0,d0
        move.b d4,(a1)

        roxr.w (a2)
        move.b d3,(a1)
        addx.w d0,d0
        move.b d4,(a1)

        roxr.w (a2)
        move.b d3,(a1)
        addx.w d0,d0
        move.b d4,(a1)

        roxr.w (a2)
        move.b d3,(a1)
        addx.w d0,d0
        move.b d4,(a1)

        roxr.w (a2)
        move.b d3,(a1)
        addx.w d0,d0
        move.b d4,(a1)

        roxr.w (a2)
        move.b d3,(a1)
        addx.w d0,d0

        not.b d0                        ; Datenwort invertieren
        movem.l (sp)+,d3-d4/a1-a2
        rts

        
az      tst.w (a5)                      ; AdresszÑhler inkrement./lîschen
        beq lazd

; AdresszÑhler erhîhen
azd     move.b #15,psgrd                ; Psg port B
        move.w rwstat(a6),d0
        lsr.w #1,d0
        ori.b #azb,d0
        move.b d0,psgwr
        and.b #255-azb,d0
        move.b d0,psgwr
        rts
; AdresszÑhler lîschen
lazd    move.b #15,psgrd                ; Psg Port B
        move.w rwstat(a6),d0
        lsr.w #1,d0
        or.b #lazb,d0
        move.b d0,psgwr
        and.b #255-lazb,d0
        move.b d0,psgwr
        rts

setzea  move.w (a5),d0                  ; Eingabe / Ausgabestatus setzen
        and.w #1,d0

; setzt E/A Status
setzead move.b #15,psgrd
        move.b d0,psgwr
        lsl.w #1,d0
        move.w d0,rwstat(a6)
        rts

; setzt Adresse in d0 auf den virtuellen Speicher
setzadr movem.l d1-d4/a0/a1,-(sp)
        move.l d0,d2
        move.l typzeig(a6),a1
wdh     cmp.l istadr(a6),d2
        beq.s stimmt
        bhi.s gr
        clr.l istadr(a6)
        bsr lazd
        bra nerh
gr      addq.l #1,istadr(a6)            ; Adresse erhîhen
        bsr azd                         ; AdresszÑhler auch
nerh    move.l istadr(a6),d1
        lsr.l #8,d1
        lsr.l #2,d1
        cmp.l letzta10(a6),d1           ; gleiche Adresse ??
        beq.s wdh                       ; Ja,dann unnîtig
        tst.l seite(a1)                 ; gebankter Speicher
        beq.s kbea
        move.l istadr(a6),d3
        divu seite+2(a1),d3             ; Seite errechnen
        cmp.w aseite(a6),d3             ; gleich der Bisherigen ?
        beq.s kbea
        move.w d3,aseite(a6)
        bsr seitesz
kbea    move.l d1,letzta10(a6)          ; jetzt gleich
        move.l a1,a0
        add.w #m_a10,a0
        moveq #6,d0                     ; maximal 7 Adresspins
        clr.w d3
        clr.w d4
setzax  lsr.w #1,d1                     ; Adresse
        bcc.s axnull
        or.b (a0),d3                    ; SRA
        or.b 1(a0),d4                   ; SRB
axnull  addq.l #2,a0
        dbra d0,setzax
        move.b d3,adrsra(a6)            ; Oder-Adressen
        move.b d4,adrsrb(a6)
        move.b letzt_a(a6),d0           ; Adresse aktualisieren
        bsr sra
        move.b letzt_b(a6),d0
        bsr srb
        bra wdh
stimmt  movem.l (sp)+,d1-d4/a0/a1
        rts

seitesz: movem.l d0-d3/a0-a1,-(sp)
        move.l typzeig(a6),a1
        move.w aseite(a6),d0            ; Aktuelle Speicherbank
        bsr src                         ; Auf den Datenbus
        moveq #1,d0
        bsr setzead                     ; Schreiben
        move.b letzt_a(a6),d2           ; SRA
        move.b letzt_b(a6),d3           ; SRB
        move.b d2,d0
        andi.b #%11100111,d0            ; evtl. Progammiersp. ausschalten
        bsr sra
        move.w #100,d0
        bsr zeit                        ; 10 mS Warten
        move.b odis+1(a1),d0
        bsr srb
        move.b page_wr+1(a1),d0
        bsr srb
        move.b odis+1(a1),d0
        bsr srb
        move.b d2,d0
        bsr sra
        move.b d3,d0
        bsr srb
        move.w #20,d0
        bsr zeit                        ; 2mS Warten
        moveq #0,d0
        bsr setzead
        movem.l (sp)+,d0-d3/a0-a1
        rts

sraus   move.b d2,d0
        bsr sra
        move.b d3,d0
        bra srb

; Legt KontrollzustÑnde bei A0 an den virtuellen Speicher
setzst: move.l a0,-(sp)
        move.b (a0)+,d0
        cmp.b letzt_a(a6),d0
        beq.s ubf1
        bsr sra                         ; Schieberegister a
ubf1    move.b (a0)+,d0
        cmp.b letzt_b(a6),d0
        beq.s ubf2
        bsr srb
ubf2    move.l (sp)+,a0
        rts

; Zeitverzîgerung
zeit:   beq.s nullzt
        mulu #40,d0                     ; in 0.1ms Schritten
        sub.l #38,d0
schleif subq.l #1,d0                    ; 12 Takte
        bne.s schleif                   ; 8 Takte
nullzt  rts


; Aktiviert den Speicher und lîscht die Adresse
einsch: clr.l adrsra(a6)
        clr.l letzta10(a6)
        clr.w letzt_a(a6)
        clr.w letzt_a2(a6)
        clr.w letzt_b(a6)
        clr.w aseite(a6)
        moveq #0,d0                     ; Ausgangsschieberegister aus
        bsr setzead
        move.l typzeig(a6),a0           ; Aktuelles EPROM
        add.w #odis,a0                  ; Betriebszustand
        bsr setzst
        bsr seitesz                     ; Falls nîtig, Seite lîschen
        clr.l d0                        ; Adresse zurÅcksetzen
        bra setzadr

; Inaktiviert den Speicher und lîscht die Adresse
aussch: moveq #0,d0
        bsr setzead
        move.l typzeig(a6),a0
        add.w #standby,a0
        bsr setzst
        clr.l d0
        bra setzadr

; Liest den Speicher in den des Rechners
; Parameter : 0/Adresse.l,4/Epromstart,8/Epromende
lese:   move.l (a5),a2                  ; Speicheradresse
        move.l 4(a5),d3                 ; Epromstart
        move.l 8(a5),d4                 ; Epromende
        bsr einsch                      ; Speicher aktivieren
        move.l typzeig(a6),a0
        add.w #read,a0
        bsr setzst
lesesc: move.l d3,d0
        bsr setzadr                     ; Adresse setzen
        bsr srd                         ; Datenwort reischieben
        move.b d0,(a2)+
        addq.l #1,d3
        cmp.l d3,d4
        bcc.s lesesc
        bsr aussch
        moveq #0,d0
        rts

; Macht Leertest des Speichers
; Parameter : 0/Epromstart,4/Epromende
ltest:  move.l 0(a5),d3                 ; Epromstart
        move.l 4(a5),d4                 ; Epromende
        bsr einsch                      ; Speicher aktivieren
        move.l typzeig(a6),a0
        add.w #read,a0
        bsr setzst
ltsc:   move.l d3,d0
        bsr setzadr                     ; Adresse setzen
        bsr srd                         ; Datenwort reischieben
        cmp.b #$ff,d0                   ; Leertest
        bne.s ltf
        addq.l #1,d3
        cmp.l d3,d4
        bcc.s ltsc
        bsr aussch
        move.l d3,d0
        subq.l #1,d0
        rts
ltf:    bsr aussch
        move.l d3,d0
        subq.l #1,d0
        bset #31,d0
        rts

; Vergleicht den Speicher mit dem des Rechners
; Parameter : 0/Adresse.l,4/Epromstart,8/Epromende
vergl:  move.l (a5),a2                  ; Speicheradresse
        move.l 4(a5),d3                 ; Epromstart
        move.l 8(a5),d4                 ; Epromende
        bsr einsch                      ; Speicher aktivieren
        move.l typzeig(a6),a0
        add.w #read,a0
        bsr setzst
vgsc:   move.l d3,d0
        bsr setzadr                     ; Adresse setzen
        bsr srd                         ; Datenwort reischieben
        cmp.b (a2)+,d0
        bne.s vgf
        addq.l #1,d3
        cmp.l d3,d4
        bcc.s vgsc
        bsr aussch
        move.l d3,d0
        subq.l #1,d0
        rts
vgf:    bsr aussch
        move.l d3,d0
        subq.l #1,d0
        bset #31,d0
        rts

; FÅrht einen VertrÑglichkeitstest der Daten aus
; Parameter : 0/Adresse.l,4/Epromstart,8/Epromende
vtest:  move.l (a5),a2                  ; Speicheradresse
        move.l 4(a5),d3                 ; Epromstart
        move.l 8(a5),d4                 ; Epromende
        bsr einsch                      ; Speicher aktivieren
        move.l typzeig(a6),a0
        add.w #read,a0
        bsr setzst
vtsc:   move.l d3,d0
        bsr setzadr                     ; Adresse setzen
        bsr srd                         ; Datenwort reischieben
        not.b d0                        ; invertieren
        and.b (a0)+,d0
        bne.s vtf
        addq.l #1,d3
        cmp.l d3,d4
        bcc.s vtsc
        bsr aussch
        move.l d3,d0
        subq.l #1,d0
        rts
vtf:    bsr aussch
        move.l d3,d0
        subq.l #1,d0
        bset #31,d0
        rts

; Programmierroutine
ipro:   move.l (a5),a3                  ; Speicheradresse
        move.l 4(a5),d3                 ; Epromstartadresse
        move.l 8(a5),d4                 ; Epromendadresse
        move.w 12(a5),d5                ; $ff-Flagge
        bsr einsch                      ; Speicher aktivieren
        move.l typzeig(a6),a4
progby:
        move.l d3,d0
        bsr setzadr                     ; Adresse
        move.b (a3),d0
        tst.w d5                        ; $FF Åberspringen ??
        bne.s uff
        cmpi.b #$ff,d0
        beq ladr
uff:    bsr src                         ; An das Eprom
        clr.w d2                        ; VersuchszÑhler
ippuls:
        lea pr_inh(a4),a0
        bsr setzst
        moveq #1,d0
        bsr setzead
        lea program(a4),a0
        bsr setzst                      ; Programmierpuls
        move.w i_zeit(a4),d0
        bsr zeit                        ; Verzîgerung
        lea pr_inh(a4),a0
        bsr setzst                      ; aus
        addq.w #1,d2                    ; VersuchszÑhler
        cmp.w trials(a4),d2             ; Vergleichen
        beq.s lpuls
        moveq #0,d0
        bsr setzead
        lea pr_ver(a4),a0               ; Daten Vergleichen
        bsr setzst
        bsr srd
        cmp.b (a3),d0
        bne.s ippuls                    ; Nochmal
lpuls:  tst.w m_zeit(a4)                ; Multiplikationsfaktor
        beq.s nichts
        lea pr_inh(a4),a0
        bsr setzst
        moveq #1,d0
        bsr setzead
        lea program(a4),a0              ; 2. Programmierpuls
        bsr setzst
        move.w d2,d0
        mulu m_zeit(a4),d0              ; Multiplikationsfaktor
        bsr zeit
        lea pr_inh(a4),a0
        bsr setzst
nichts: cmp.w trials(a4),d2             ; Maximalzeit ?
        bne.s ladr
        moveq #0,d0
        bsr setzead                      ; Daten einlesen
        lea pr_ver(a4),a0
        bsr setzst
        bsr srd
        cmp.b (a3),d0
        bne pfeh
ladr:
        addq.l #1,d3                    ; Epromadresse
        addq.l #1,a3                    ; Speicheradresse
        cmp.l d3,d4
        bcc progby                      ; Bis zur Epromendadresse
        bsr aussch                      ; Speicher abschalten
        move.l d3,d0
        subq.l #1,d0
        rts
pfeh:   bsr aussch
        move.l d3,d0
        subq.l #1,d0
        bset #31,d0
        rts

waltp:  move.l (a5),typzeig(a6)         ; Typenzeiger setzen
        bsr einsch
        bra aussch

; PrÅft die TreiberfÑhigkeit des eingesetzten Speichers
tstest: bsr einsch                      ; Aktivieren
        move.l typzeig(a6),a4
        clr.l d0
        bsr setzadr
        lea read(a4),a0                 ; Lesestatus
        bsr tstbd
        cmp.b d3,d4
        bne.s fehl
        lea odis(a4),a0
        bsr tstbd
        cmp.b d3,d4
        beq.s fehl
        bsr aussch
        moveq #0,d0
        rts
fehl:
        bsr aussch
        moveq #-1,d0
        rts


tstbd:  move.l a0,-(sp)
        bclr #1,(a0)
        bsr setzst
        bsr srd
        btst #7,d0
        seq d3
        move.l (sp)+,a0
        bset #1,(a0)
        bsr setzst
        bsr srd
        btst #7,d0
        seq d4
        rts


init    clr.l letzta10(a6)
        clr.l adrsra(a6)
        clr.l letzt_a(a6)
        clr.w letzt_b(a6)
        lea inaktiv(a6),a0
        bsr setzst
        clr.l d0
        bra setzadr

inaktiv dc.b 0
        dc.b 0
        
stopikb dc.b $13
startikb dc.b $11

        align.w

; globale Variable

parbas  dc.l $23334440
ergebnis dc.l $23443333
alt_ssp dc.l $23334440
alt_sr  dc.l $0
rwstat  dc.w $2323
aseite  dc.w 0

istadr  dc.l $44444444
typzeig dc.l $44444444
adrsra  dc.w 0
adrsrb  dc.w 0
letzt_a dc.w 0
letzt_a2 dc.w 0
letzt_b dc.w 0

letzta10 dc.l 1

        end

