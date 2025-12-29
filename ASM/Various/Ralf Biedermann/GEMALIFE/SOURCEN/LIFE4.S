; LIFE version 2 von RBsoft, Ralf Biedermann, Ortfeld 3, 2815 Langwedel
; initialisieren einer Tabelle die die Berechnung sehr stark beschleunigt
; die Tabelle enth„lt folgende Eintr„ge:
; 1. Bildschirmpointer fr Zelle .L
; 2. AND Maske zum l”schen       .B
; 3. Z„hler fr Nachbarn         .B
; 4. 2*OR Maske zum setzen    2* .B
; 5. Bildschirmpointer fr Zelle .L
; 6. Pointer auf Nachbarn     8* .L
                OPT O+
                OPT F+
                OUTPUT 'LIFE4.PRG'
                >PART 'anfang'
; zuerst berprfen ob die Rechnerkonfiguration reicht
                movea.l $0004(SP),A0    ;(Basepage) -> A0
                move.l  $000C(A0),D3    ;L„nge des Text-Segments -> D3
                add.l   $0014(A0),D3    ;D3 + L„nge des Data-Segmentes -> D3
                add.l   $001C(A0),D3    ;D3 + L„nge des Bss-Segmentes  -> D3
                add.l   #$00000100,D3   ;D3 + L„nge der Basepage       -> D3
                add.l   #1048,D3        ;sicherheitshalber
                move.l  D3,-(SP)        ;restlichen Speicher freigeben
                move.l  A0,-(SP)
                move.w  #0,-(SP)
                move.w  #$004A,-(SP)
                trap    #1
                lea     $000C(SP),SP    ;schneller und krzer als add.l #$0C,SP
                tst.l   D0              ;Fehler ?
                bne.s   ende            ;ja, dann --> ende

                move.w  #4,-(SP)        ; getrez
                trap    #14             ; get resolution
                addq.l  #2,SP
                cmp.b   #2,D0           ; 640*400 ?
                bne.s   ende            ; ja
                clr.l   -(SP)           ; supervisormode
                move.w  #$0020,-(SP)
                trap    #1
                addq.l  #6,SP
                move.l  $0000042E,-(SP) ; phystop
                move.l  D0,-(SP)        ; usermode
                move.w  #$0020,-(SP)
                trap    #1
                addq.l  #6,SP
                move.l  (SP)+,D1
                cmp.l   #$000FFFFF,D1   ; 1 MB Ram mindestens
                bhi.s   start1
ende:           pea     errort(PC)      ; Fehlermeldung ausgeben
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                move.w  #7,-(SP)        ; auf Taste warten
                trap    #1
                addq.l  #2,SP
                clr.w   -(SP)           ; zurck wohin auch immer
                trap    #1
                ENDPART
                >PART 'initialisierung'
; bis jetzt ist alles in Ordnung
start1:         pea     tag(PC)         ; Begrssung ausgeben
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                lea     control(PC),A0  ; appl init
                move.w  #10,(A0)+
                clr.w   (A0)+
                move.w  #1,(A0)+
                clr.w   (A0)+
                clr.w   (A0)+
                bsr     aes
                DC.W $A000              ; line A
                DC.W $A00A              ; hidemouse
                move.l  D0,linea
                move.w  #$0019,-(SP)
                trap    #1
                addq.l  #2,SP
                add.b   #'A',D0
                lea     pbuf(PC),A0
                move.b  D0,(A0)+
                move.b  #':',(A0)+
                clr.w   -(SP)
                move.l  A0,-(SP)
                move.w  #$0047,-(SP)
                trap    #1
                addq.l  #8,SP
                lea     pbuf(PC),A0
tstl:           move.b  (A0)+,D0
                bne.s   tstl
                move.b  #'\',-1(A0)
                move.b  #'*',(A0)+
                move.b  #'.',(A0)+
                move.b  #'F',(A0)+
                move.b  #'L',(A0)+
                move.b  #'D',(A0)+
                clr.b   (A0)+
                lea     space(PC),A0    ; platz fr tabelle
                adda.l  #96*160*44,A0   ; 96 Zeilen, 160 Spalten mit 44 Byte
                move.l  A0,list         ; Liste fr aktive Zellen
                adda.l  #96*160*4,A0    ; puffer fuer diskoperationen
                move.l  A0,fbuf
                clr.w   count           ; keine lebenden Zellen
                move.w  #2,-(SP)        ; physbase
                trap    #14             ; bildschirmadresse suchen
                addq.l  #2,SP
                movea.l D0,A6
                adda.l  #16*80,A6       ; ersten 12 Zeilen auslassen
                move.l  A6,screen
                movea.l A6,A1
                lea     space(PC),A0    ; start tabelle
                move.l  #$000060F0,D0   ; OR Maske
                moveq   #95,D7          ; Anzahl der Spalten / 2
init1:          moveq   #79,D6          ; Anzahl der Zeilen
init2:          moveq   #1,D5           ; 2 Punkte pro Spalte
                moveq   #15,D1          ; AND Maske
init3:          move.l  A1,(A0)+        ; Bildschirmpointer eintragen
                move.b  D1,(A0)+        ; AND Maske
                move.b  #$F4,(A0)+      ; Z„hler -1 wegen BEQ.S
                move.w  D0,(A0)+        ; OR Maske
                move.l  A1,(A0)+        ; Bildschirmpointer
                moveq   #95,D4
                sub.l   D7,D4           ; Y-Koordinate
                moveq   #79,D3
                sub.l   D6,D3           ; X-Koordinate
                lsl.l   #1,D3
                addq.l  #1,D3
                sub.l   D5,D3
                movem.l D3-D4,-(SP)     ; Nachbar links oben
                subq.l  #1,D3
                subq.l  #1,D4
                bsr     eintrag
                movem.l (SP),D3-D4      ; Nachbar oben
                subq.l  #1,D4
                bsr     eintrag
                movem.l (SP),D3-D4      ; Nachbar rechts oben
                addq.l  #1,D3
                subq.l  #1,D4
                bsr     eintrag
                movem.l (SP),D3-D4      ; Nachbar links
                subq.l  #1,D3
                bsr     eintrag
                movem.l (SP),D3-D4      ; Nachbar rechts
                addq.l  #1,D3
                bsr     eintrag
                movem.l (SP),D3-D4      ; Nachbar links unten
                subq.l  #1,D3
                addq.l  #1,D4
                bsr     eintrag
                movem.l (SP),D3-D4      ; Nachbar unten
                addq.l  #1,D4
                bsr     eintrag
                movem.l (SP),D3-D4      ; Nachbar rechts unten
                addq.l  #1,D3
                addq.l  #1,D4
                bsr     eintrag
                addq.l  #8,SP
                ror.l   #4,D0           ; OR Maske auf n„chste Spalte
                ror.b   #4,D1           ; AND Maske auf n„chste Spalte
                dbra    D5,init3
                rol.l   #8,D0           ; OR Maske wiederherstellen
                addq.l  #1,A1           ; n„chste Bildschirmposition
                dbra    D6,init2
                lea     240(A1),A1      ; Bildschirmposition n„chste Zeile
                dbra    D7,init1
                pea     clr(PC)         ; Bildschirm l”schen
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP           ; Stack korigieren
                ENDPART
                >PART 'hauptschleife'
mloop:          moveq   #0,D6           ; X-Position
                moveq   #0,D7           ; Y-Position
                movea.l screen(PC),A6   ; Bildschirmadress
                cmpi.b  #255,mode
                bne.s   mloopr
                pea     menut(PC)       ; Menu ausgeben
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP           ; Stack korigieren
                bra.s   mloop0
mloopr:         pea     menur(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
mloop0:         movea.l linea(PC),A0
                move.l  D6,D0
                lsl.l   #2,D0
                move.w  D0,-$025A(A0)
                move.l  D7,D0
                lsl.l   #2,D0
                move.w  D0,-$0258(A0)
                bsr     invers          ; Punkt invertieren
mloop0a:        movea.l linea(PC),A0    ; line a pointer holen
                move.l  -$025A(A0),D5   ; position
                moveq   #0,D0
                moveq   #0,D1
                move.w  -$025A(A0),D0   ; maus x
                lsr.w   #2,D0
                move.w  -$0258(A0),D1   ; maus y
                lsr.w   #2,D1
                cmp.l   #96,D1
                blt.s   mausok
                moveq   #95,D1
mausok:         cmp.l   D0,D6
                bne.s   maus0
                cmp.l   D1,D7
                beq.s   mloop0b
maus0:          movem.l D0-D1,-(SP)
                bsr     invers
                movem.l (SP)+,D0-D1
                movea.l linea(PC),A0
                move.l  D0,D6
                move.l  D1,D7
                bsr     invers
mloop0b:        movea.l linea(PC),A0    ; status
                cmp.l   -$025A(A0),D5
                bne.s   mloop0a
                move.b  -$015C(A0),D0
                and.b   #$03,D0         ; maustasten
                beq.s   maus2
                cmp.b   #1,D0           ; links
                bne.s   maus1
                bsr     invers
                bsr     setzea
                bsr     invers
                bra.s   mloop0b
maus1:          cmp.b   #2,D0           ; rechts
                bne.s   maus2
                bsr     invers
                bsr     setzeb
                bsr     invers
                bra.s   mloop0b
maus2:          cmp.b   #3,D0           ; beide
                bne.s   maus3
                bsr     invers
                bra.s   mgo
maus3:          move.w  #11,-(SP)       ; Tastaturstatus
                trap    #1
                addq.l  #2,SP
                tst.w   D0
                beq.s   mloop0b         ; keine
                bsr     invers          ; Punkt invertieren
                move.w  #7,-(SP)
                trap    #1              ; Zeichen von Tastatur holen
                addq.l  #2,SP           ; Stack korigieren
                swap    D0              ; scancode
                cmp.b   #$3B,D0         ; F1
                bne.s   mloop1
                bsr     setze           ; Punkt setzen oder l”schen
                bra     mloop0
mloop1:         cmp.b   #$3C,D0         ; F2
                bne.s   mloop2
                bsr     clear           ; alles l”schen
                bra     mloop
mloop2:         cmp.b   #$3D,D0         ; F3
                bne.s   mloop3
mgo:            clr.l   -(SP)           ; supervisormode
                move.w  #$0020,-(SP)
                trap    #1
                addq.l  #6,SP
                move.l  D0,super
                move.w  $00000452,-(SP)
                clr.w   $00000452
                move.b  $00FFFA1D,D0    ; timer ein bischen zurckdrehen
                move.w  D0,-(SP)
                and.b   #$0F,D0
                or.b    #$70,D0
                move.b  D0,$00FFFA1D
                movea.l linea(PC),A0
mausl1:         move.b  -$015C(A0),D0
                and.b   #3,D0
                bne.s   mausl1
                bsr     go              ; generieren
                move.w  (SP)+,D0
                move.b  D0,$00FFFA1D
                move.w  (SP)+,$00000452
                move.l  super(PC),-(SP) ; usermode
                move.w  #$0020,-(SP)
                trap    #1
                addq.l  #6,SP
                bra     mloop
mloop3:         cmp.b   #$3E,D0         ; F4
                bne.s   mloop4
                bsr     single
                bra     mloop
mloop4:         cmp.b   #$3F,D0         ; F5
                bne.s   mloop5
                bsr     random          ; Zufallsgeneration
                bra     mloop0
mloop5:         cmp.b   #$40,D0         ; F6
                bne.s   mloop6
                bsr     load            ; Generation laden
                bra     mloop
mloop6:         cmp.b   #$41,D0         ; F7
                bne.s   mloop7
                bsr     save            ; Generation speichern
                bra     mloop
mloop7:         cmp.b   #$42,D0         ; F8
                bne.s   mloop10
                bsr     geben
                bra     mloop
mloop10:        cmp.b   #$44,D0         ; F10
                bne.s   help
                pea     etext(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                move.l  #2000000,D7
endel:          subq.l  #1,D7
                bne.s   endel
                move.w  #19,control
                bsr     aes
                DC.W $A009              ;show mouse
                clr.w   -(SP)
                trap    #1
help:           cmp.b   #$62,D0         ; help
                bne.s   eins
                bsr     ghelp
                bra     mloop
eins:           cmp.b   #$6D,D0         ; 1
                bne.s   zwei
                bsr     gleiter         ; Gleiter zeichenen
                bra     mloop0
zwei:           cmp.b   #$6E,D0         ; 2
                bne.s   drei
                bsr     kanone          ; Gleiterkanone zeichnen
                bra     mloop0
drei:           cmp.b   #$6F,D0         ; 3
                bne.s   null
                bsr     fi3             ; eine weitere Figur zeichnen
                bra     mloop0
null:           cmp.b   #$70,D0         ; 0
                bne.s   vier
                movem.l D6-D7,-(SP)
                moveq   #0,D6
null1:          moveq   #10,D7
null2:          bsr     gleiter
                addq.l  #5,D7
                cmp.l   #70,D7
                bne.s   null2
                addq.l  #5,D6
                cmp.l   #125,D6
                bne.s   null1
                movem.l (SP)+,D6-D7
                bra     mloop0
vier:           cmp.b   #$6A,D0
                bne.s   fuenf
                bsr     fi4
                bra     mloop0
fuenf:          cmp.b   #$6B,D0
                bne.s   rechts
                bsr     fi5
                bra     mloop0
rechts:         cmp.b   #$4D,D0         ; rechte Cursortaste
                bne.s   links
                addq.l  #1,D6
                bra.s   emloop
links:          cmp.b   #$4B,D0         ; linke Cursortaste
                bne.s   oben
                subq.l  #1,D6
                bra.s   emloop
oben:           cmp.b   #$48,D0         ; Cursortaste hoch
                bne.s   unten
                subq.l  #1,D7
                bra.s   emloop
unten:          cmp.b   #$50,D0         ; Cursortaste runter
                bne.s   tr
                addq.l  #1,D7
emloop:         cmp.l   #160,D6         ; rechter Rand
                bne.s   emloop1
                clr.l   D6
                bra     mloop0
emloop1:        cmp.l   #-1,D6          ; linker Rand
                bne.s   emloop2
                move.l  #159,D6
                bra     mloop0
emloop2:        cmp.l   #96,D7          ; unterer Rand
                bne.s   emloop3
                clr.l   D7
                bra     mloop0
emloop3:        cmp.l   #-1,D7          ; oberer Rand
                bne     mloop0
                moveq   #95,D7
                bra     mloop0
tr:             cmp.b   #$13,D0         ; R
                bne.s   tt
                bsr     initr
                bra     mloop
tt:             cmp.b   #$14,D0         ; T
                bne.s   tg
                bsr.s   initt
                bra     mloop
tg:             cmp.b   #$22,D0         ; G
                bne     mloop0
                bsr.s   grid
                bra     mloop
                ENDPART
                >PART 'gitter auf bildschirm'
;GRID zeichnen
grid:           movea.l screen(PC),A0
                moveq   #95,D0
                move.l  #$88888888,D2
                move.l  #240,D3
grl1:           REPT 20
                or.l    D2,(A0)+
                ENDR
                adda.l  D3,A0
                dbra    D0,grl1
                rts
                ENDPART
                >PART 'aes'
; aes aufrufen
aes:            lea     aesbp(PC),A0
                move.l  A0,D1
                move.w  #200,D0
                trap    #2
                rts
                ENDPART
                >PART 'tabellen fr torus,rechteck'
; fuer torus vorbereiten
initt:          cmpi.b  #255,mode
                beq     einitt
                pea     atext(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                lea     space(PC),A0    ; start tabelle
                moveq   #95,D7          ; Anzahl der Spalten / 2
initt1:         moveq   #79,D6          ; Anzahl der Zeilen
initt2:         moveq   #1,D5           ; 2 Punkte pro Spalte
initt3:         lea     12(A0),A0       ; nur pointer auf nachbarn veraendern
                moveq   #95,D4
                sub.l   D7,D4           ; Y-Koordinate
                moveq   #79,D3
                sub.l   D6,D3           ; X-Koordinate
                lsl.l   #1,D3
                addq.l  #1,D3
                sub.l   D5,D3
                movem.l D3-D4,-(SP)     ; Nachbar links oben
                subq.l  #1,D3
                subq.l  #1,D4
                bsr     eintrag
                movem.l (SP),D3-D4      ; Nachbar oben
                subq.l  #1,D4
                bsr     eintrag
                movem.l (SP),D3-D4      ; Nachbar rechts oben
                addq.l  #1,D3
                subq.l  #1,D4
                bsr     eintrag
                movem.l (SP),D3-D4      ; Nachbar links
                subq.l  #1,D3
                bsr     eintrag
                movem.l (SP),D3-D4      ; Nachbar rechts
                addq.l  #1,D3
                bsr     eintrag
                movem.l (SP),D3-D4      ; Nachbar links unten
                subq.l  #1,D3
                addq.l  #1,D4
                bsr     eintrag
                movem.l (SP),D3-D4      ; Nachbar unten
                addq.l  #1,D4
                bsr     eintrag
                movem.l (SP)+,D3-D4     ; Nachbar rechts unten
                addq.l  #1,D3
                addq.l  #1,D4
                bsr     eintrag
                dbra    D5,initt3
                dbra    D6,initt2
                dbra    D7,initt1
                move.b  #255,mode
einitt:         rts

; fuer recht vorbereiten
initr:          cmpi.b  #254,mode
                beq     einitr
                pea     atext(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                lea     space(PC),A0    ; start tabelle
                moveq   #95,D7          ; Anzahl der Spalten / 2
initr1:         moveq   #79,D6          ; Anzahl der Zeilen
initr2:         moveq   #1,D5           ; 2 Punkte pro Spalte
initr3:         lea     12(A0),A0       ; nur pointer auf nachbarn veraendern
                moveq   #95,D4
                sub.l   D7,D4           ; Y-Koordinate
                moveq   #79,D3
                sub.l   D6,D3           ; X-Koordinate
                lsl.l   #1,D3
                addq.l  #1,D3
                sub.l   D5,D3
                movem.l D3-D4,-(SP)     ; Nachbar links oben
                subq.l  #1,D3
                subq.l  #1,D4
                bsr     eintrag1
                movem.l (SP),D3-D4      ; Nachbar oben
                subq.l  #1,D4
                bsr     eintrag1
                movem.l (SP),D3-D4      ; Nachbar rechts oben
                addq.l  #1,D3
                subq.l  #1,D4
                bsr.s   eintrag1
                movem.l (SP),D3-D4      ; Nachbar links
                subq.l  #1,D3
                bsr.s   eintrag1
                movem.l (SP),D3-D4      ; Nachbar rechts
                addq.l  #1,D3
                bsr.s   eintrag1
                movem.l (SP),D3-D4      ; Nachbar links unten
                subq.l  #1,D3
                addq.l  #1,D4
                bsr.s   eintrag1
                movem.l (SP),D3-D4      ; Nachbar unten
                addq.l  #1,D4
                bsr.s   eintrag1
                movem.l (SP)+,D3-D4     ; Nachbar rechts unten
                addq.l  #1,D3
                addq.l  #1,D4
                bsr.s   eintrag1
                dbra    D5,initr3
                dbra    D6,initr2
                dbra    D7,initr1
                move.b  #254,mode
einitr:         rts

; Routine um Pointer auf Nachbarn eintragen
eintrag:        lea     space(PC),A2    ; Pointer auf Tabelle
                tst.l   D3              ; linker Rand
                bpl.s   ein1
                move.l  #159,D3
                bra.s   ein2
ein1:           cmp.w   #160,D3         ; rechter Rand
                blt.s   ein2
                clr.l   D3
ein2:           tst.l   D4              ; oberer Rand
                bpl.s   ein3
                moveq   #95,D4
                bra.s   ein4
ein3:           cmp.l   #96,D4          ; unterer Rand
                blt.s   ein4
                clr.l   D4
ein4:           mulu    #160,D4         ; 160 Eintr„ge pro Zeile
                add.w   D3,D4           ; Tabelleposition
                mulu    #44,D4          ; 44 Byte pro Eintrag
                adda.l  D4,A2           ; Adresse der Tabelle
                addq.l  #5,A2           ; Pointer auf Z„hler
                move.l  A2,(A0)+
                rts

; Routine um Pointer auf Nachbarn eintragen
eintrag1:       lea     space(PC),A2    ; Pointer auf Tabelle
                cmp.w   #159,D3
                bhi.s   eindum
                cmp.w   #95,D4
                bhi.s   eindum
                mulu    #160,D4         ; 160 Eintr„ge pro Zeile
                add.w   D3,D4           ; Tabelleposition
                mulu    #44,D4          ; 44 Byte pro Eintrag
                adda.l  D4,A2           ; Adresse der Tabelle
                addq.l  #5,A2           ; Pointer auf Z„hler
                move.l  A2,(A0)+
                rts
eindum:         lea     dummy(PC),A2
                move.l  A2,(A0)+
                rts
                ENDPART
                >PART 'cursor invertieren'
; Cursorposition invertieren
invers:         movem.l D6-D7,-(SP)     ; Position sichern
                moveq   #15,D0          ; Maske zum invertieren
                btst    #0,D6           ; ungerade Adresse
                bne.s   invers1
                lsl.b   #4,D0           ; gerade Adresse
invers1:        mulu    #320,D7         ; Startadresse der Zeile
                lsr.l   #1,D6           ; nur Byteweise
                add.l   D6,D7
                lea     0(A6,D7.l),A0   ; Bildschirmadresse
                eor.b   D0,(A0)         ; Punkt invertieren
                eor.b   D0,80(A0)
                eor.b   D0,160(A0)
                eor.b   D0,240(A0)
                movem.l (SP)+,D6-D7
                rts
                ENDPART
                >PART 'zelle setzen oder l”schen'
; Zelle setzen oder l”schen
setze:          movem.l D6-D7,-(SP)     ; position retten
                lea     space+5(PC),A0  ; Start der Tabelle, 1. Z„hler
                mulu    #160,D7         ; 160 Zellen pro Zeile
                add.l   D6,D7           ; Position in Tabelle
                mulu    #44,D7          ; 44 Byte pro Eintrag
                adda.l  D7,A0
                movea.l 3(A0),A1        ; Pointer auf Bildschirm
                lea     count(PC),A2    ; Pointer auf Anzahl der Zellen
                movea.l list(PC),A3     ; Start des Zellenstacks
                move.w  (A2),D2         ; Anzahl der lebenden Zellen
                lsl.w   #2,D2           ; 4 Byte pro Pointer
                adda.w  D2,A3           ; Ende des Zellenstacks
                tst.b   (A0)            ; lebt Zelle
                bmi.s   setze2          ; nein
                move.b  #$F4,(A0)       ; lebende Zelle stirbt
                subq.w  #1,(A2)         ; eine lebende Zelle weniger
                move.b  -1(A0),D0       ; AND Maske holen
                and.b   D0,(A1)         ; 1. Zeile l”schen
                and.b   D0,80(A1)       ; 2. Zeile l”schen
                and.b   D0,160(A1)      ; 3. Zeile l”schen
                move.w  (A2),D0         ; Anzahl der Zellen
                subq.w  #1,D0           ; fr DBRA
                bpl.s   setze0
                movem.l (SP)+,D6-D7
                rts
setze0:         movea.l list(PC),A1     ; Zellenstack
                movea.l list(PC),A2     ; Zellenstack
setze1:         cmpa.l  (A1),A0         ; gesuchter Eintrag ?
                bne.s   esetze1         ; nein
                addq.l  #4,A1           ; entfernen
esetze1:        move.l  (A1)+,(A2)+     ; Eintrag kopieren
                dbra    D0,setze1
                movem.l (SP)+,D6-D7
                rts
setze2:         move.l  A0,(A3)         ; Pointer eintragen
                move.b  #96,(A0)+       ; Zelle zum Leben erwecken
                addq.w  #1,(A2)         ; eine Zelle mehr
                move.b  (A0)+,D0        ; erste OR Maske
                move.b  (A0),D1         ; zweite OR Maske
                or.b    D0,(A1)         ; 1. Zeile eintragen
                or.b    D1,80(A1)       ; 2. Zeile eintragen
                or.b    D0,160(A1)      ; 3. Zeile eintragen
                movem.l (SP)+,D6-D7
                rts
                ENDPART
                >PART 'zelle setzen'
; Zelle setzen
setzea:         movem.l D6-D7,-(SP)     ; position retten
                lea     space+5(PC),A0  ; Start der Tabelle, 1. Z„hler
                mulu    #160,D7         ; 160 Zellen pro Zeile
                add.l   D6,D7           ; Position in Tabelle
                mulu    #44,D7          ; 44 Byte pro Eintrag
                adda.l  D7,A0
                movea.l 3(A0),A1        ; Pointer auf Bildschirm
                lea     count(PC),A2    ; Pointer auf Anzahl der Zellen
                movea.l list(PC),A3     ; Start des Zellenstacks
                move.w  (A2),D2         ; Anzahl der lebenden Zellen
                lsl.w   #2,D2           ; 4 Byte pro Pointer
                adda.w  D2,A3           ; Ende des Zellenstacks
                tst.b   (A0)            ; lebt Zelle
                bmi.s   setze2a         ; nein
                movem.l (SP)+,D6-D7
                rts
setze2a:        move.l  A0,(A3)         ; Pointer eintragen
                move.b  #96,(A0)+       ; Zelle zum Leben erwecken
                addq.w  #1,(A2)         ; eine Zelle mehr
                move.b  (A0)+,D0        ; erste OR Maske
                move.b  (A0),D1         ; zweite OR Maske
                or.b    D0,(A1)         ; 1. Zeile eintragen
                or.b    D1,80(A1)       ; 2. Zeile eintragen
                or.b    D0,160(A1)      ; 3. Zeile eintragen
                movem.l (SP)+,D6-D7
                rts
                ENDPART
                >PART 'Zellen l”schen'
; Zelle l”schen
setzeb:         movem.l D6-D7,-(SP)     ; position retten
                lea     space+5(PC),A0  ; Start der Tabelle, 1. Z„hler
                mulu    #160,D7         ; 160 Zellen pro Zeile
                add.l   D6,D7           ; Position in Tabelle
                mulu    #44,D7          ; 44 Byte pro Eintrag
                adda.l  D7,A0
                movea.l 3(A0),A1        ; Pointer auf Bildschirm
                lea     count(PC),A2    ; Pointer auf Anzahl der Zellen
                movea.l list(PC),A3     ; Start des Zellenstacks
                move.w  (A2),D2         ; Anzahl der lebenden Zellen
                lsl.w   #2,D2           ; 4 Byte pro Pointer
                adda.w  D2,A3           ; Ende des Zellenstacks
                tst.b   (A0)            ; lebt Zelle
                bmi.s   setze2b         ; nein
                move.b  #$F4,(A0)       ; lebende Zelle stirbt
                subq.w  #1,(A2)         ; eine lebende Zelle weniger
                move.b  -1(A0),D0       ; AND Maske holen
                and.b   D0,(A1)         ; 1. Zeile l”schen
                and.b   D0,80(A1)       ; 2. Zeile l”schen
                and.b   D0,160(A1)      ; 3. Zeile l”schen
                move.w  (A2),D0         ; Anzahl der Zellen
                subq.w  #1,D0           ; fr DBRA
                bpl.s   setze0b
                movem.l (SP)+,D6-D7
                rts
setze0b:        movea.l list(PC),A1     ; Zellenstack
                movea.l list(PC),A2     ; Zellenstack

                cmpa.l  (A1),A0         ; gesuchter Eintrag ?
                bne.s   esetze1b        ; nein
                addq.l  #4,A1           ; entfernen
esetze1b:       move.l  (A1)+,(A2)+     ; Eintrag kopieren
                dbra    D0,setze1
setze2b:        movem.l (SP)+,D6-D7
                rts
                ENDPART
                >PART 'tabellen l”schen'
; Alle Zellen l”schen
clear:          lea     space+5(PC),A0  ; Pointer auf ersten Z„hler
                move.w  #160*96-1,D7    ; maximale Anzahl der Zellen
clearl:         move.b  #$F4,(A0)
                lea     44(A0),A0
                dbra    D7,clearl
                clr.w   count           ; keine Zelle mehr
                clr.l   gener           ; 0. Generation
                pea     clr(PC)         ; Bildschirm l”schen
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                rts
                ENDPART
                >PART 'permanente berechnung'
; neue Generationen berechnen und anzeigen
go:             pea     got(PC)         ; Text anzeigen
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
; neue Generationen berechnen
                move.l  gener(PC),-(SP)
                move.l  list(PC),-(SP)  ; Anfang der Liste
                move.w  count(PC),D7
                moveq   #0,D0
                move.w  D7,D0
                beq     err_gen
                lsl.w   #2,D0           ; 4 Byte pro Eintrag
                movea.l (SP),A1
                adda.l  D0,A1           ; Ende der Liste
                clr.l   $000004BA
                clr.l   zw
; Tastatur und Maus prfen
gol:            moveq   #-12,D2         ; Konstante Zelle=Tot
                moveq   #96,D3          ; Konstante Zelle=Lebendig
                moveq   #12,D4
                movea.l linea(PC),A0
                move.b  -$015C(A0),D0   ; status
                and.b   #3,D0
                bne.s   egol
                move.w  #11,-(SP)
                trap    #1
                addq.l  #2,SP
                tst.w   D0
                beq.s   go1
                move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP
egol:           move.l  4(SP),D0        ; Gesamtzahl der Generationen
                add.l   gener(PC),D0
                move.l  D0,gener
                lea     8(SP),SP
                move.w  D7,count
                rts
; Generation berechnen und anzeigen
go1:            subq.w  #1,D7
                addq.l  #1,4(SP)
                movea.l (SP),A0         ; Anfang der Liste
; durch Addition n„chste Generation bestimmen
genl0:          movea.l (A0)+,A2        ; Pointer auf Zelle
                addq.l  #7,A2           ; Pointer auf Nachbarn
                movem.l (A2)+,A3-A6     ; ersten 4 Nachbarn
                add.b   D4,(A3)         ; Z„hler erh”hen
                bne.s   genl1
                move.l  A3,(A1)+        ; Pointer eintragen
genl1:          add.b   D4,(A4)
                bne.s   genl2
                move.l  A4,(A1)+
genl2:          add.b   D4,(A5)
                bne.s   genl3
                move.l  A5,(A1)+
genl3:          add.b   D4,(A6)
                bne.s   genl4
                move.l  A6,(A1)+
genl4:          movem.l (A2),A3-A6      ; n„chsten 4 Nachbarn
                add.b   D4,(A3)         ; Z„hler erh”hen
                bne.s   genl5
                move.l  A3,(A1)+        ; Pointer eintragen
genl5:          add.b   D4,(A4)
                bne.s   genl6
                move.l  A4,(A1)+
genl6:          add.b   D4,(A5)
                bne.s   genl7
                move.l  A5,(A1)+
genl7:          add.b   D4,(A6)
                bne.s   genl8
                move.l  A6,(A1)+
genl8:          dbra    D7,genl0
; Anzahl der Eintr„ge in Liste bestimmen
                lea     leer(PC),A0
                move.l  A0,(A1)
                movea.l (SP),A0
                movea.l A0,A1
                moveq   #0,D5
                moveq   #0,D6
                lea     notot1a(PC),A6
; neue Generation darstellen
                movea.l (A0)+,A2        ; Pointer auf Eintrag
                move.b  (A2),D0         ; Z„hler holen
                jmp     0(A6,D0.w)      ; springen
atot:           addq.w  #1,D5           ; eine lebende Zelle mehr
                move.l  A2,(A1)+        ; Pointer eintragen
                move.b  D3,(A2)+        ; Zelle wird lebendig
                move.b  (A2)+,D0        ; 1. OR Maske
                move.b  (A2)+,D1        ; 2. OR Maske
                movea.l (A2)+,A3        ; Pointer auf Bildschirm
                or.b    D0,(A3)         ; 1. Zeile
                or.b    D1,80(A3)       ; 2. Zeile
                or.b    D0,160(A3)      ; 3. Zeile
                movea.l (A0)+,A2        ; Pointer auf Eintrag
                move.b  (A2),D0         ; Z„hler holen
                jmp     0(A6,D0.w)      ; springen

notot1a:        move.b  D2,(A2)
                movea.l (A0)+,A2        ; Pointer auf Eintrag
                move.b  (A2),D0         ; Z„hler holen
                jmp     0(A6,D0.w)      ; springen
                DS.B 2
                move.b  D2,(A2)
                movea.l (A0)+,A2        ; Pointer auf Eintrag
                move.b  (A2),D0         ; Z„hler holen
                jmp     0(A6,D0.w)      ; springen
                DS.B 2
                bra.s   atot
                DS.B 10
                move.b  D2,(A2)
                movea.l (A0)+,A2        ; Pointer auf Eintrag
                move.b  (A2),D0         ; Z„hler holen
                jmp     0(A6,D0.w)      ; springen
                DS.B 2
                move.b  D2,(A2)
                movea.l (A0)+,A2        ; Pointer auf Eintrag
                move.b  (A2),D0         ; Z„hler holen
                jmp     0(A6,D0.w)      ; springen
                DS.B 2
                move.b  D2,(A2)
                movea.l (A0)+,A2        ; Pointer auf Eintrag
                move.b  (A2),D0         ; Z„hler holen
                jmp     0(A6,D0.w)      ; springen
                DS.B 2
                move.b  D2,(A2)
                movea.l (A0)+,A2        ; Pointer auf Eintrag
                move.b  (A2),D0         ; Z„hler holen
                jmp     0(A6,D0.w)      ; springen
                DS.B 2
                move.b  D2,(A2)
                movea.l (A0)+,A2        ; Pointer auf Eintrag
                move.b  (A2),D0         ; Z„hler holen
                jmp     0(A6,D0.w)      ; springen
                DS.B 2
                bra.s   alife
                DS.B 10
                bra.s   alife
                DS.B 10
                move.b  D3,(A2)
                move.l  A2,(A1)+
                movea.l (A0)+,A2        ; Pointer auf Eintrag
                move.b  (A2),D0         ; Z„hler holen
                jmp     0(A6,D0.w)      ; springen
                move.b  D3,(A2)
                move.l  A2,(A1)+
                movea.l (A0)+,A2        ; Pointer auf Eintrag
                move.b  (A2),D0         ; Z„hler holen
                jmp     0(A6,D0.w)      ; springen
                bra.s   alife
                DS.B 10
                bra.s   alife
                DS.B 10
                bra.s   alife
                DS.B 10
                bra.s   alife
                DS.B 10
                bra.s   alife
                DS.B 10
                bra.s   ego
; bei Fehler piepen
err_gen:        move.w  #7,-(SP)        ; bell
                move.w  #2,-(SP)        ; conout
                trap    #1
                lea     12(SP),SP
                rts

alife:          addq.w  #1,D6           ; eine lebende Zelle weniger
                move.b  D2,(A2)         ; Zelle ist gestorben
                move.b  -(A2),D0        ; AND Maske
                movea.l -(A2),A3        ; Pointer auf Bildschirm
                and.b   D0,(A3)         ; 1. Zeile
                and.b   D0,80(A3)       ; 2. Zeile
                and.b   D0,160(A3)      ; 3. Zeile
                movea.l (A0)+,A2        ; Pointer auf Eintrag
                move.b  (A2),D0         ; Z„hler holen
                jmp     0(A6,D0.w)      ; springen

ego:            move.l  A1,D7           ; Anzahl der lebenden Zellen bestimmen
                sub.l   (SP),D7
                lsr.l   #2,D7
                beq.s   err_gen
                cmpi.l  #64,$000004BA
                blt     go1
                movem.l D7/A1,-(SP)
                move.l  12(SP),D0       ; Generation
                lea     text1(PC),A0
                moveq   #5,D2
                bsr     dez
                move.w  D7,D0           ; Anzahl der Zellen
                and.l   #$0000FFFF,D0
                lea     text2(PC),A0
                moveq   #4,D2
                bsr     dez
                move.w  D5,D0           ; Anzahl der neuen Zellen
                and.l   #$0000FFFF,D0
                lea     text3(PC),A0
                moveq   #4,D2
                bsr     dez
                move.w  D6,D0           ; Anzahl der gestorbenen Zellen
                and.l   #$0000FFFF,D0
                lea     text4(PC),A0
                moveq   #4,D2
                bsr     dez
                move.l  12(SP),D0       ; Generationen pro Sekunde
                sub.l   zw(PC),D0
                move.l  12(SP),zw
                lea     text5(PC),A0
                moveq   #3,D2
                bsr     dez
                pea     goz(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                clr.l   $000004BA
                movem.l (SP)+,D7/A1
                bra     gol
                ENDPART
                >PART 'einzelschritt'
; Einzelschrittbetrieb
; neue Generationen berechnen
single:         pea     got(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
single1:        movem.l D6-D7,-(SP)
                move.l  list(PC),-(SP)  ; Anfang der Liste
                addq.l  #1,gener
                move.w  count(PC),D7
                moveq   #0,D0
                move.w  D7,D0
                lsl.w   #2,D0           ; 4 Byte pro Eintrag
                movea.l (SP),A1
                adda.l  D0,A1           ; Ende der Liste
                moveq   #-12,D2         ; Konstante Zelle=Tot
                moveq   #96,D3          ; Konstante Zelle=Lebendig
                moveq   #0,D0
                clr.l   zw
; Generation berechnen und anzeigen
                subq.w  #1,D7
                bpl.s   calc10
                addq.l  #4,SP
                movem.l (SP)+,D6-D7
                rts
calc10:         movea.l (SP),A0         ; Anfang der Liste
                moveq   #12,D4
; durch Addition n„chste Generation bestimmen
genl10:         movea.l (A0)+,A2        ; Pointer auf Zelle
                addq.l  #7,A2           ; Pointer auf Nachbarn
                movem.l (A2)+,A3-A6     ; ersten 4 Nachbarn
                add.b   D4,(A3)         ; Z„hler erh”hen
                bne.s   genl11
                move.l  A3,(A1)+        ; Pointer eintragen
genl11:         add.b   D4,(A4)
                bne.s   genl12
                move.l  A4,(A1)+
genl12:         add.b   D4,(A5)
                bne.s   genl13
                move.l  A5,(A1)+
genl13:         add.b   D4,(A6)
                bne.s   genl14
                move.l  A6,(A1)+
genl14:         movem.l (A2)+,A3-A6     ; n„chsten 4 Nachbarn
                add.b   D4,(A3)         ; Z„hler erh”hen
                bne.s   genl15
                move.l  A3,(A1)+        ; Pointer eintragen
genl15:         add.b   D4,(A4)
                bne.s   genl16
                move.l  A4,(A1)+
genl16:         add.b   D4,(A5)
                bne.s   genl17
                move.l  A5,(A1)+
genl17:         add.b   D4,(A6)
                bne.s   genl18
                move.l  A6,(A1)+
genl18:         dbra    D7,genl10
; Anzahl der Eintr„ge in Liste bestimmen
                lea     leer(PC),A0
                move.l  A0,(A1)
                movea.l (SP),A0
                movea.l A0,A1
                moveq   #0,D5
                moveq   #0,D6
                lea     notot1b(PC),A6
; neue Generation darstellen
                movea.l (A0)+,A2        ; Pointer auf Eintrag
                move.b  (A2),D0         ; Z„hler holen
                jmp     0(A6,D0.w)      ; springen
notot1b:        move.b  D2,(A2)
                movea.l (A0)+,A2        ; Pointer auf Eintrag
                move.b  (A2),D0         ; Z„hler holen
                jmp     0(A6,D0.w)      ; springen
                DS.B 2
                move.b  D2,(A2)
                movea.l (A0)+,A2        ; Pointer auf Eintrag
                move.b  (A2),D0         ; Z„hler holen
                jmp     0(A6,D0.w)      ; springen
                DS.B 2
                bra     atot1
                DS.B 8
                move.b  D2,(A2)
                movea.l (A0)+,A2        ; Pointer auf Eintrag
                move.b  (A2),D0         ; Z„hler holen
                jmp     0(A6,D0.w)      ; springen
                DS.B 2
                move.b  D2,(A2)
                movea.l (A0)+,A2        ; Pointer auf Eintrag
                move.b  (A2),D0         ; Z„hler holen
                jmp     0(A6,D0.w)      ; springen
                DS.B 2
                move.b  D2,(A2)
                movea.l (A0)+,A2        ; Pointer auf Eintrag
                move.b  (A2),D0         ; Z„hler holen
                jmp     0(A6,D0.w)      ; springen
                DS.B 2
                move.b  D2,(A2)
                movea.l (A0)+,A2        ; Pointer auf Eintrag
                move.b  (A2),D0         ; Z„hler holen
                jmp     0(A6,D0.w)      ; springen
                DS.B 2
                move.b  D2,(A2)
                movea.l (A0)+,A2        ; Pointer auf Eintrag
                move.b  (A2),D0         ; Z„hler holen
                jmp     0(A6,D0.w)      ; springen
                DS.B 2
                bra.s   alife1
                DS.B 10
                bra.s   alife1
                DS.B 10
                move.b  D3,(A2)
                move.l  A2,(A1)+
                movea.l (A0)+,A2        ; Pointer auf Eintrag
                move.b  (A2),D0         ; Z„hler holen
                jmp     0(A6,D0.w)      ; springen
                move.b  D3,(A2)
                move.l  A2,(A1)+
                movea.l (A0)+,A2        ; Pointer auf Eintrag
                move.b  (A2),D0         ; Z„hler holen
                jmp     0(A6,D0.w)      ; springen
                bra.s   alife1
                DS.B 10
                bra.s   alife1
                DS.B 10
                bra.s   alife1
                DS.B 10
                bra.s   alife1
                DS.B 10
                bra.s   alife1
                DS.B 10
                bra.s   esin
alife1:         addq.w  #1,D6           ; eine lebende Zelle weniger
                move.b  D2,(A2)         ; Zelle ist gestorben
                move.b  -(A2),D0        ; AND Maske
                movea.l -(A2),A3        ; Pointer auf Bildschirm
                and.b   D0,(A3)         ; 1. Zeile
                and.b   D0,80(A3)       ; 2. Zeile
                and.b   D0,160(A3)      ; 3. Zeile
                movea.l (A0)+,A2        ; Pointer auf Eintrag
                move.b  (A2),D0         ; Z„hler holen
                jmp     0(A6,D0.w)      ; springen
atot1:          addq.w  #1,D5           ; eine lebende Zelle mehr
                move.l  A2,(A1)+        ; Pointer eintragen
                move.b  D3,(A2)+        ; Zelle wird lebendig
                move.b  (A2)+,D0        ; 1. OR Maske
                move.b  (A2)+,D1        ; 2. OR Maske
                movea.l (A2)+,A3        ; Pointer auf Bildschirm
                or.b    D0,(A3)         ; 1. Zeile
                or.b    D1,80(A3)       ; 2. Zeile
                or.b    D0,160(A3)      ; 3. Zeile
                movea.l (A0)+,A2        ; Pointer auf Eintrag
                move.b  (A2),D0         ; Z„hler holen
                jmp     0(A6,D0.w)      ; springen
esin:           move.l  A1,D7           ; Anzahl der lebenden Zellen bestimmen
                sub.l   (SP),D7
                lsr.l   #2,D7
                move.w  D7,count
                move.l  gener(PC),D0    ; Generation
                lea     text1(PC),A0
                moveq   #5,D2
                bsr     dez
                move.w  D7,D0           ; Anzahl der Zellen
                and.l   #$0000FFFF,D0
                lea     text2(PC),A0
                moveq   #4,D2
                bsr     dez
                move.w  D5,D0           ; Anzahl der neuen Zellen
                and.l   #$0000FFFF,D0
                lea     text3(PC),A0
                moveq   #4,D2
                bsr     dez
                move.w  D6,D0           ; Anzahl der gestorbenen Zellen
                and.l   #$0000FFFF,D0
                lea     text4(PC),A0
                moveq   #4,D2
                bsr     dez
                moveq   #0,D0
                lea     text5(PC),A0
                moveq   #3,D2
                bsr     dez
                pea     goz(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                move.w  #8191,D7
sinl1:          move.w  #11,-(SP)
                trap    #1
                addq.l  #2,SP
                tst.w   D0
                dbne    D7,sinl1
                beq.s   exsin
                addq.l  #4,SP
                movem.l (SP)+,D6-D7
                move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP
                swap    D0
                cmp.b   #$3E,D0
                bne.s   rtssin
sinl2:          move.w  #11,-(SP)
                trap    #1
                addq.l  #2,SP
                tst.w   D0
                beq     single1
                move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP
                bra.s   sinl2
rtssin:         rts
exsin:          addq.l  #4,SP
                movem.l (SP)+,D6-D7
                rts
                ENDPART
                >PART 'zufallsgeneration'
; Zufallsgeneration erzeugen 1000 Zellen
random:         movem.l D6-D7,-(SP)
ranl:           move.w  #17,-(SP)
                trap    #14
                addq.l  #2,SP
                move.l  D0,D6
                lsr.l   #8,D6
                divu    #160,D6
                clr.w   D6
                swap    D6
                move.w  #17,-(SP)
                trap    #14
                addq.l  #2,SP
                move.l  D0,D7
                lsr.l   #8,D7
                divu    #96,D7
                clr.w   D7
                swap    D7
                bsr     setze
                move.w  #11,-(SP)
                trap    #1
                addq.l  #2,SP
                tst.w   D0
                beq.s   ranl
                movem.l (SP)+,D6-D7
                rts
                ENDPART
                >PART 'feste figuren'
;folgende figuren sind direkt ber ziffernblock zu erreichen
; Gleiter eintragen
gleiter:        lea     muster1(PC),A5  ; Pointer auf Figur
                bsr.s   figure          ; Figur eintragen
                rts

; Gleiterkanone eintragen
kanone:         lea     muster2(PC),A5
                bsr.s   figure
                rts

; Noch eine Figur zeichnen
fi3:            lea     muster3(PC),A5
                bsr.s   figure
                rts

;
fi4:            lea     muster4(PC),A5
                bsr.s   figure
                rts

;
fi5:            lea     muster5(PC),A5
                bsr.s   figure
                rts

; Figur eintragen
figure:         movem.l D6-D7,-(SP)
                move.w  (A5)+,D5        ; Anzahl der Punkte
                subq.w  #1,D5
figurl:         movem.l (SP),D6-D7
                move.w  (A5)+,D0
                ext.l   D0
                move.w  (A5)+,D1
                ext.l   D1
                add.l   D0,D6
                add.l   D1,D7
                tst.l   D6              ; linker Rand
                bpl.s   fig1
                add.l   #160,D6
                bra.s   fig2
fig1:           cmp.w   #159,D6         ; rechter Rand
                blt.s   fig2
                sub.l   #160,D6
fig2:           tst.l   D7              ; oberer Rand
                bpl.s   fig3
                add.l   #96,D7
                bra.s   fig4
fig3:           cmp.l   #96,D7          ; unterer Rand
                blt.s   fig4
                sub.l   #96,D7
fig4:           bsr     setze
                dbra    D5,figurl
                movem.l (SP)+,D6-D7
                rts
                ENDPART
                >PART 'hilfe'
; Hilfetext ausgeben und generation neu zeichnen
ghelp:          movem.l D6-D7,-(SP)
                pea     helpt(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP
                movem.l (SP)+,D6-D7
; Generation wiederherstellen
draw:           pea     clr(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                movem.l D6-D7,-(SP)
                move.w  #96*160-1,D7
                lea     space+5(PC),A1
hl1:            tst.b   (A1)
                bpl.s   hlife
                move.b  -1(A1),D0
                movea.l 3(A1),A2
                and.b   D0,(A2)
                and.b   D0,80(A2)
                and.b   D0,160(A2)
                bra.s   ehl1
hlife:          move.b  1(A1),D0
                move.b  2(A1),D1
                movea.l 3(A1),A2
                or.b    D0,(A2)
                or.b    D1,80(A2)
                or.b    D0,160(A2)
ehl1:           lea     44(A1),A1
                dbra    D7,hl1
                movem.l (SP)+,D6-D7
                rts
                ENDPART
                >PART 'hilfsroutinen'
; Umwandlung eines Langwortes in ASCII
dez:            divu    #10,D0          ; Wert durch 10 teilen
                swap    D0              ; Rest nehmen
                add.b   #'0',D0         ; in ASCII umwandeln
                move.b  D0,-(A0)        ; in String eintragen
                clr.w   D0              ; Rest l”schen
                swap    D0
                dbra    D2,dez
                rts

alert:          move.w  #52,control
                move.w  #1,control+2
                move.w  #1,control+4
                move.w  #1,control+6
                clr.w   control+8
                move.w  #1,intin
                move.l  A0,adrin
                bsr     aes
                rts

                ENDPART
                >PART 'dateioperationen'
; Dateioperationen
load:           bsr     gname
                tst.w   intout
                beq.s   load1
                tst.w   intout+2
                beq.s   load1
                bsr.s   get
load1:          rts

save:           bsr     gname
                tst.w   intout
                beq.s   save1
                tst.w   intout+2
                beq.s   save1
                bsr     nehmen
                bsr.s   zput
save1:          rts

get:            bsr.s   testov
                tst.w   D0
                bne.s   nvorhd
                bsr.s   open
                tst.w   D0
                bmi.s   error
                lea     handle(PC),A0
                move.w  D0,(A0)
                bsr     read
                bsr.s   close
                bsr     geben
                rts

zput:           bsr     create
                bmi.s   vorhd
                lea     handle(PC),A0
                move.w  D0,(A0)
                bsr     write
                bsr.s   close
                rts

error:          lea     text12(PC),A0
                bra     alert

nvorhd:         lea     text13(PC),A0
                bra     alert

vorhd:          lea     text14(PC),A0
                bra     alert

open:           move.w  #2,-(SP)
                lea     name(PC),A0
                move.l  A0,-(SP)
                move.w  #$003D,-(SP)
                trap    #1
                addq.l  #8,SP
                lea     handle(PC),A0
                rts

close:          move.w  handle(PC),-(SP)
                move.w  #$003E,-(SP)
                trap    #1
                addq.l  #4,SP
                rts

testov:         move.w  #0,-(SP)
                lea     name(PC),A0
                move.l  A0,-(SP)
                move.w  #$004E,-(SP)
                trap    #1
                addq.l  #8,SP
                move.l  D0,-(SP)
                move.w  #$002F,-(SP)
                trap    #1
                addq.l  #2,SP
                movea.l D0,A0
                move.l  (SP)+,D0
                move.l  26(A0),laenge
                tst.l   D0
                rts

read:           move.l  fbuf(PC),-(SP)
                move.l  laenge(PC),-(SP)
                move.w  handle(PC),-(SP)
                move.w  #$003F,-(SP)
                trap    #1
                adda.l  #12,SP
                rts

create:         move.w  #0,-(SP)
                lea     name(PC),A0
                move.l  A0,-(SP)
                move.w  #$003C,-(SP)
                trap    #1
                addq.l  #8,SP
                lea     handle(PC),A0
                move.w  D0,(A0)
                tst.w   D0
                rts

write:          move.l  fbuf(PC),-(SP)
                moveq   #0,D0
                move.w  count(PC),D0
                lsl.l   #1,D0
                addq.l  #2,D0
                move.l  D0,-(SP)
                move.w  handle(PC),-(SP)
                move.w  #$0040,-(SP)
                trap    #1
                adda.l  #12,SP
                tst.l   D0
                rts

gname:          DC.W $A009              ; showmouse
                movea.l linea(PC),A0
                move.w  #$FFFF,$006A(A0)
                lea     control(PC),A0
                move.w  #90,(A0)+
                clr.w   (A0)+
                move.w  #2,(A0)+
                move.w  #2,(A0)+
                clr.w   (A0)
                lea     pbuf(PC),A0
                move.l  A0,adrin
                lea     nbuf(PC),A0
                move.l  A0,adrin+4
                bsr     aes
                lea     name(PC),A0
                lea     pbuf(PC),A1
gnl1:           move.b  (A1)+,D0
                move.b  D0,(A0)+
                bne.s   gnl1
gnl2:           move.b  -(A0),D0
                cmp.b   #'\',D0
                bne.s   gnl2
                lea     nbuf(PC),A1
                addq.l  #1,A0
gnl3:           move.b  (A1)+,D0
                move.b  D0,(A0)+
                bne.s   gnl3
                DC.W $A00A              ; hide
                bsr     draw
                rts

geben:          move.l  laenge(PC),D5
                lsr.l   #1,D5
                subq.l  #2,D5
                bmi.s   egeben
                moveq   #0,D6
                moveq   #0,D7
                movea.l fbuf(PC),A4
gebenl:         move.b  (A4)+,D6
                move.b  (A4)+,D7
                bsr     setzea
                dbra    D5,gebenl
                cmpi.b  #255,1(A4)
                bne.s   geben1
                bsr     initt
egeben:         rts
geben1:         bsr     initr
                rts

nehmen:         movea.l fbuf(PC),A0
                move.w  count(PC),D7
                lea     space+5(PC),A1
                subq.w  #1,D7
                bmi.s   enehmen
                move.w  #95,D7
nl1:            move.w  #159,D6
nl2:            tst.b   (A1)
                bmi.s   enl2
                move.w  #159,D0
                sub.w   D6,D0
                move.b  D0,(A0)+
                move.w  #95,D0
                sub.w   D7,D0
                move.b  D0,(A0)+
enl2:           lea     44(A1),A1
                dbra    D6,nl2
                dbra    D7,nl1
enehmen:        move.b  #255,(A0)+
                move.b  mode(PC),(A0)+
                rts
                ENDPART

                >PART 'Daten'
                DATA
                DC.B ' \'
pbuf:           DS.B 100
text12:         DC.B '[1][Dateifehler][verstanden]',0
                EVEN
text13:         DC.B '[1][Name noch nicht vorhanden][verstanden]',0
                EVEN
text14:         DC.B '[1][Name schon vorhanden][verstanden]',0
                EVEN

; kleiner Text zur Begrssung
tag:            DC.B 27,'E'
                DC.B 'RBsoft	wnscht	viel Spaž mit LIFE',13,10
                DC.B 'Bitte habt etwas Geduld, denn es wird eine Tabelle aufgebaut.',0
                EVEN

clr:            DC.B 27,'E',27,'f',0    ; Bildschirm l”schen und Cursor aus
                EVEN

; kleiner Text zur Verabschiedung
etext:          DC.B 27,'E'
                DC.B 'RBsoft, Ralf Biedermann, Ortfeld 3, 2815 Langwedel, W-Germany',13,10
                DC.B 'Ich hoffe diese kleine	Demonstration der Leistungsf„higkeit von',13,10
                DC.B 'reiner	Maschinensprache hat euch beeindruckt. Falls jemand eine',13,10
                DC.B 'schnellere Version kennt m”ge er sich bitte bei mir melden.',13,10
                DC.B "Falls Ihr mal ein vernnftiges Betriebssystem fr einen 68000'er",13,10
                DC.B 'sehen wollt fragt mal nach SINCLAIR QL: LONG LIVE QDOS	!',13,10
                DC.B 'Diese Meldung verschwindet automatisch	nach einiger Zeit.'
                DC.B 0
                EVEN


atext:          DC.B 27,'Y',32,32,27,'KTabelle wird angepasst.',0
                EVEN

; Text fr Hauptmenu
menut:          DC.B 27,'Y',32,32,27,'K','RBsoft'
                DC.B 27,'Y',32,39,'F1:Set'
                DC.B 27,'Y',32,46,'F2:Clear'
                DC.B 27,'Y',32,55,'F3:Go'
                DC.B 27,'Y',32,62,'F4:Single'
                DC.B 27,'Y',32,72,'F5:Random'
                DC.B 27,'Y',32,82,'F6:Load'
                DC.B 27,'Y',32,90,'F7:Save'
                DC.B 27,'Y',32,98,'F10:End'
                DC.B 27,'Y',32,106,'Torus'
                DC.B 0
                EVEN

menur:          DC.B 27,'Y',32,32,27,'K','RBsoft'
                DC.B 27,'Y',32,39,'F1:Set'
                DC.B 27,'Y',32,46,'F2:Clear'
                DC.B 27,'Y',32,55,'F3:Go'
                DC.B 27,'Y',32,62,'F4:Single'
                DC.B 27,'Y',32,72,'F5:Random'
                DC.B 27,'Y',32,82,'F6:Load'
                DC.B 27,'Y',32,90,'F7:Save'
                DC.B 27,'Y',32,98,'F10:End'
                DC.B 27,'Y',32,106,'Recht'
                DC.B 0
                EVEN

; Text fr das generieren
got:            DC.B 27,'Y',32,32,13,'RBsoft'
                DC.B 27,'Y',32,39,' Generation:000000'
                DC.B '  Zellen:00000'
                DC.B '  +:00000'
                DC.B '  -:00000'
                DC.B '  Gen/Sek:0000'
                DC.B '     LIFE',0
                EVEN

goz:            DC.B 27,'Y',32,51,'000000'
text1:          DC.B 27,'Y',32,66,'00000'
text2:          DC.B 27,'Y',32,75,'00000'
text3:          DC.B 27,'Y',32,84,'00000'
text4:          DC.B 27,'Y',32,99,'0000'
text5:          DC.B 0
                EVEN

; fr GEM
aesbp:          DC.L control
                DC.L global
                DC.L intin
                DC.L intout
                DC.L adrin
                DC.L adrout


errort:         DC.B 27,'E'
                DC.B 'Schade	!',13,10
                DC.B 'Dieser	Rechner	hat entweder zuwenig RAM oder',13,10
                DC.B 'der Monitor ist nicht der sch”ne Monochrome.',13,10
                DC.B 'Bitte eine Taste drcken.'
                DC.B 0
                EVEN

; hilfetext
helpt:          DC.B 27,'E'
                DC.B 'RBsoft, Ralf Biedermann, Ortfeld 3, 2815 Langwedel, W-Germany',13,10
                DC.B 'Ich werde in diesen Zeilen kurz die Bedienung dieses Superprogrammes erkl„ren.',13,10
                DC.B 'Nach Start des	Programmes befindet man	sich in	einer Editorumgebung.',13,10
                DC.B 'In dieser Umgebung gibt es folgende M”glichkeiten:',13,10
                DC.B 'Cursortasten und Mausbewegungen bewegen den Grafikcursor',13,10
                DC.B 'F1 setzt oder l”scht die Zelle	unter dem Cursor',13,10
                DC.B 'Linke Maustaste setzt und rechte Maustaste l”scht die Zelle unter dem Cursor',13,10
                DC.B 'F2 l”scht die gesamte aktive Fl„che von LIFE',13,10
                DC.B 'F3 oder beide Maustasten gleichzeitig starten die Berechnung',13,10
                DC.B 'F4 berechnet nur die n„chste Generation',13,10
                DC.B 'F5 erzeugt solange zuf„llig Zellen bis	eine weitere Taste gedrckt wird',13,10
                DC.B 'F6 erlaubt es eine Generation zu laden',13,10
                DC.B 'F7 erlaubt es eine Generation abzuspeichern',13,10
                DC.B 'F8 zeichnet die zuletzt geladene Datei	oder l”scht alles',13,10
                DC.B 'F10 erlaubt es	sogar das Programm zu verlassen',13,10
                DC.B 'Die tasten 0..5 auf dem Ziffernblock erzeugen vordefinierte Figuren',13,10
                DC.B 'Mit T)orus bzw. R)echteck kann	man die	Feldform ver„ndern',13,10
                DC.B 'Mit G)rid kann	man ein	Gitter einblenden, um die Spuren.',13,10
                DC.B 'Die automatische Berechnung (F3) wird durch eine Taste	(auch Maus)',13,10
                DC.B 'unterbrochen, dies kann etwas dauern, da die Tastatur nur einmal in der',13,10
                DC.B 'Sekunde abgefragt wird, also keep cool. Dieses	Programm ist Freeware und',13,10
                DC.B 'und darf bzw. sollte unver„ndert kopiert werden.',13,10
                DC.B 'Falls euch das	Programm gef„llt bitte ich um eine kleine Spende,',13,10
                DC.B 'aber nicht fr	mich, sondern fr einen	Tierschutzverein eurer Wahl',13,10
                DC.B 'Falls Du alles	gelesen	hast drcke eine Taste'
                DC.B 0
                EVEN
leer:           DC.B 204,0
dummy:          DC.W -1
mode:           DC.W $FFFF
                EVEN

muster1:        DC.W 5                  ; gleiter 5 punkte
                DC.W 0,0                ; 1. Punkt
                DC.W 1,0
                DC.W 2,0
                DC.W 0,-1
                DC.W 1,-2
                EVEN
muster2:        DC.W 45
                DC.W 0,0
                DC.W 1,0
                DC.W 0,1
                DC.W 1,1
                DC.W 11,0
                DC.W 11,1
                DC.W 11,-1
                DC.W 12,-2
                DC.W 13,-3
                DC.W 14,-2
                DC.W 15,-1
                DC.W 16,-1
                DC.W 12,2
                DC.W 13,3
                DC.W 14,2
                DC.W 15,1
                DC.W 16,1
                DC.W 15,0
                DC.W 16,0
                DC.W 21,1
                DC.W 21,2
                DC.W 21,3
                DC.W 22,3
                DC.W 23,3
                DC.W 24,3
                DC.W 22,4
                DC.W 23,4
                DC.W 24,4
                DC.W 25,4
                DC.W 25,5
                DC.W 24,2
                DC.W 24,1
                DC.W 23,1
                DC.W 22,1
                DC.W 22,0
                DC.W 23,0
                DC.W 24,0
                DC.W 25,0
                DC.W 25,-1
                DC.W 30,0
                DC.W 30,1
                DC.W 34,2
                DC.W 35,2
                DC.W 34,3
                DC.W 35,3

muster3:        DC.W 6
                DC.W 0,0
                DC.W 0,-1
                DC.W 1,0
                DC.W 1,1
                DC.W 2,0
                DC.W 2,-1

muster4:        DC.W 12
                DC.W 0,0
                DC.W 1,0
                DC.W 2,1
                DC.W 2,-1
                DC.W 3,0
                DC.W 4,0
                DC.W 5,0
                DC.W 6,0
                DC.W 7,1
                DC.W 7,-1
                DC.W 8,0
                DC.W 9,0

muster5:        DC.W 8
                DC.W 0,0
                DC.W 1,1
                DC.W 2,1
                DC.W 3,1
                DC.W 4,1
                DC.W 4,0
                DC.W 4,-1
                DC.W 3,-2
                ENDPART
                >PART 'BSS'
                BSS
list:           DS.L 1
fbuf:           DS.L 1
count:          DS.W 1
gener:          DS.L 1
zw:             DS.L 1
super:          DS.L 1
screen:         DS.L 1
linea:          DS.L 1
control:        DS.W 5
global:         DS.W 15
intin:          DS.W 16
intout:         DS.W 7
adrin:          DS.L 2
adrout:         DS.L 1
handle:         DS.L 1
laenge:         DS.L 1
name:           DS.B 100
nbuf:           DS.B 20
space:          DS.B 96*160*48
                ENDPART
                END
