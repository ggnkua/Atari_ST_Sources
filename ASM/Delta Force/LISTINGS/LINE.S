********************************************************************************
**                                                                            **
**  LINE ROUTINE                                                              **
**  ~~~~~~~~~~~~                                                              **
**                                                                            **
**  AUTHOR(S)   : Felix Brandt (Flix/Delta Force)                             **
**                Jahnstr. 51                                                 **
**                W-8130 Starnberg                                            **
**                                                                            **
**  STARTED ON  : 04/26/1992                                                  **
**  LAST CHANGE : 10/09/1992                                                  **
**                                                                            **
**  Supposed to be that fastest line routine possible on MC68000 using ST-    **
**  hardware                                                                  **
**                                                                            **
********************************************************************************
**                                                                            **
**               TRY THE CURSOR AND 2,4,6,8 (KEYPAD) KEYS !!!                 **
**                                                                            **
********************************************************************************

resolution      EQU 0           ; Bildschirmaufl”sung (0=gering, 1=mittel, 2=hoch)

; In der mittleren und hohen Aufl”sung kann der obere Teil der Linie bei dem
; Testprogramm verdeckt sein, da keine zwei Bildschirme fr flimmerfreie Aus-
; gabe verwendet werden. Die Linienroutine funktioniert!

                >PART 'Aufl”sungsteil'

                IF resolution=0
pixels          SET 320
bytes           SET 160
words           SET 20
lines           SET 200
planes          SET 8
                ENDC

                IF resolution=1
pixels          SET 640
bytes           SET 160
words           SET 40
lines           SET 200
planes          SET 4
                ENDC

                IF resolution=2
pixels          SET 640
bytes           SET 80
words           SET 40
lines           SET 400
planes          SET 2
                ENDC

                ENDPART

spd             EQU 1

                OPT X+          ; Symboltabelle an
                DEFAULT 1       ; Debugger ist default

                TEXT

                pea     start(PC)
                move.w  #38,-(A7)            ; Supexec
                trap    #14
                addq.l  #6,A7

                clr.w   -(A7)
                trap    #1

;------------------------------------------------------------------------------

start:          >PART 'Clear BSS segment'
                lea     bss_start,A0
                lea     bss_end,A1
                moveq   #0,D0
clear_bss:      move.l  D0,(A0)+
                cmpa.l  A0,A1
                bge.s   clear_bss
                ENDPART

                move.l  A7,oldstack
                move    SR,old_sr

                ori     #$0700,SR            ; IRQ aus

                lea     stack,A7             ; Stack setzen

                jsr     install_all

                move.l  #vbl,$70.w           ; Neuer VBL

                movem.l palette,D0-D7        ; Palette setzen
                movem.l D0-D7,$ffff8240.w

                >PART '65536/XD-Tabelle'

                lea     divtab,A0            ; Divisionstabelle anlegen
                moveq   #0,D0
divit:          move.l  #65536,D1
                divu    D0,D1
                move.l  D1,(A0)+
                addq.w  #1,D0
                cmp.w   #pixels,D0
                blt.s   divit

                ENDPART

                >PART 'Y-Tabelle'

                lea     ytab,A0              ; Y-Tabelle anlegen
                moveq   #0,D0
yit:            move.w  D0,D1
                mulu    #bytes,D1
                move.w  D1,(A0)+
                addq.w  #1,D0
                cmp.w   #lines,D0
                blt.s   yit

                ENDPART

                movea.l screen_1,A0          ; Bildschirmadresse
                moveq   #0,D0                ; Koordinaten
                moveq   #0,D1
                move.w  #pixels-1,D2
                move.w  #lines-1,D3

loopy:          jsr     vsync                ; Auf VBL warten

                bsr     clearline            ; Linien l”schen

                move.b  $fffffc02.w,D7       ; Tasten abfragen
                cmp.b   #$48,D7
                bne.s   noup1
                tst.w   D1
                beq.s   noup1
                sub.w   #spd,D1
noup1:          cmp.b   #$50,D7
                bne.s   nodown1
                cmp.w   #lines-1,D1
                beq.s   nodown1
                add.w   #spd,D1
nodown1:        cmp.b   #$4b,D7
                bne.s   noleft1
                tst.w   D0
                beq.s   noleft1
                sub.w   #spd,D0
noleft1:        cmp.b   #$4d,D7
                bne.s   noright1
                cmp.w   #pixels-1,D0
                beq.s   noright1
                add.w   #spd,D0
noright1:       cmp.b   #$68,D7
                bne.s   noup2
                tst.w   D3
                beq.s   noup2
                sub.w   #spd,D3
noup2:          cmp.b   #$6e,D7
                bne.s   nodown2
                cmp.w   #lines-1,D3
                beq.s   nodown2
                add.w   #spd,D3
nodown2:        cmp.b   #$6a,D7
                bne.s   noleft2
                tst.w   D2
                beq.s   noleft2
                sub.w   #spd,D2
noleft2:        cmp.b   #$6c,D7
                bne.s   noright2
                cmp.w   #pixels-1,D2
                beq.s   noright2
                add.w   #spd,D2
noright2:

                move.w  #$0700,$ffff8240.w
                bsr.s   line                 ; Linien zeichnen!
                clr.w   $ffff8240.w

                cmpi.b  #$39,D7
                bne     loopy

quit:           jsr     restore_all

                movea.l oldstack,A7          ; Alter Stack
                move    old_sr,SR

                rts

;-----------------------------------------------------------------------------
; *** Subroutines

                >PART 'Linienroutine'

; *** Die verdammt schnellste Linienroutine, die auf einem MC 68000 mit ST-
; *** Hardware m”glich ist!

line:           movem.l D0-A3,-(A7)

                cmp.w   D0,D2                ; Immer von links nach rechts
                bge.s   xok
                exg     D0,D2                ; Koordinaten vertauschen
                exg     D1,D3

xok:            move.w  D2,D4
                move.w  D3,D5
                move.w  D2,D7                ; X-Ende fr sp„ter speichern

                sub.w   D0,D4                ; X-L„nge
                bge.s   itsok1
                neg.w   D4
itsok1:         sub.w   D1,D5                ; Y-L„nge
                bge.s   itsok2
                neg.w   D5

itsok2:         movea.l #bytes,A2            ; Von oben nach unten
                cmp.w   D1,D3
                bge.s   updown
                movea.l #-bytes,A2           ; Von unten nach oben

updown:         lea     ytab,A1              ; Y
                add.w   D1,D1
                adda.w  0(A1,D1.w),A0

                move.w  D0,D3                ; X-Start fr sp„ter

                move.w  D0,D2                ; X
                andi.w  #65535-15,D2         ; Unteren 4 Bits raus
                sub.w   D2,D0
                lsr.w   #resolution+1,D2
                adda.w  D2,A0

                cmp.w   D5,D4                ; 2. Linientyp ("V-Linien")
                blt     line2
                beq.s   bugfix

                btst    #3,D0                ; Nibble addieren
                beq.s   nibble
                addq.w  #1,A0

nibble:         lea     divtab,A1            ; Offset berechnen
                add.w   D4,D4
                add.w   D4,D4
                move.l  0(A1,D4.w),D1

                mulu    D5,D1                ; Leider nicht zu vermeiden (Long-Mulu)
                movea.w D1,A3

bugjump:        move.w  D3,D0                ; Anfangspunkt bercksichtigen
                andi.w  #65535-15,D3
                sub.w   D3,D0
                lsl.w   #3,D0

                move.w  D7,D1
                sub.w   D3,D1

                andi.w  #65535-15,D1         ; Untersten 4 Bit raus
                lsr.w   #4,D1                ; D0 -> Wort
                lea     tab2,A1              ; 16*8+2 = 130 (19-D0)
                add.w   D1,D1                ; *2
                add.w   0(A1,D1.w),D0

                move.w  D7,D1
                andi.w  #65535-15,D1         ; Untersten 4 Bit raus
                sub.w   D1,D7

                add.w   D7,D7                ; *4
                add.w   D7,D7
                lea     tab1,A1
                movea.l 0(A1,D7.w),A1

                adda.w  D0,A1

                moveq   #128,D7              ; Werte zum Bit-Setzen
                moveq   #64,D6
                moveq   #32,D5
                moveq   #16,D4
                moveq   #8,D3
                moveq   #4,D2
                moveq   #1,D1

                move.w  #32768,D0            ; Bei der H„lfte beginnen

                jsr     (A1)                 ; Linie zeichnen

                movem.l (A7)+,D0-A3
                rts

bugfix:         btst    #3,D0                ; Nibble addieren
                beq.s   nibble2
                addq.w  #1,A0

nibble2:        movea.w #65535,A3            ; Wert fr diagonale Linien
                bra.s   bugjump

;----

line2:          move.w  #lines-1,D0
                sub.w   D5,D0                ; L„nge sichern

                lea     divtab,A1            ; Offset berechnen
                add.w   D5,D5
                add.w   D5,D5
                move.l  0(A1,D5.w),D1

                mulu    D4,D1
                movea.w D1,A3

                lea     tab3,A1              ; Tabelle fr 14er-Produkte
                add.w   D0,D0
                move.w  0(A1,D0.w),D0
                lea     linecode,A1
                adda.w  D0,A1

                move.w  D3,D1
                andi.w  #65535-15,D3         ; Unteren 4 Bits rausschmeissen
                sub.w   D3,D1
                move.w  #15,D3
                sub.w   D1,D3
                moveq   #1,D1
                lsl.w   D3,D1                ; Bit-Wert berechnen

                moveq   #1,D2                ; 1 zum rotieren

                move.w  #32768,D0            ; Bei der H„lfte beginnen

                jsr     (A1)                 ; Linie zeichnen

                movem.l (A7)+,D0-A3
                rts

;------------------------------------------------------------------------------

; Die Routine zum L”schen der Linien ist sehr langsam, da sie kaum optimiert
; ist. Hier kann man sehen, wie die frhen Versionen meiner LineRout aussahen.

clearline:      movem.l D0-A3,-(A7)

                cmp.w   D0,D2                ; Immer von links nach rechts
                bge.s   xok0
                exg     D0,D2
                exg     D1,D3

xok0:           move.w  D2,D4
                move.w  D3,D5

                sub.w   D0,D4                ; X-L„nge
                bge.s   itsok10
                neg.w   D4
itsok10:        sub.w   D1,D5                ; Y-L„nge
                bge.s   itsok20
                neg.w   D5

itsok20:        move.l  #bytes,D6            ; Von oben nach unten
                cmp.w   D1,D3
                bge.s   updown0
                move.l  #-bytes,D6           ; Von unten nach oben

updown0:        lea     ytab,A1              ; Y
                add.w   D1,D1
                adda.w  0(A1,D1.w),A0

                move.w  D0,D3                ; X-Start fr sp„ter

                move.w  D0,D2                ; X
                andi.w  #65535-15,D2         ; Unteren 4 Bits raus
                sub.w   D2,D0
                lsr.w   #resolution+1,D2
                adda.w  D2,A0

                moveq   #15,D7
                sub.w   D0,D7

                cmp.w   D5,D4                ; 2. Linientyp ("V"-Linien)
                blt.s   line20
                beq.s   bugfix0

                move.w  D4,D0                ; L„nge

                lea     divtab,A1            ; Offset berechnen
                add.w   D4,D4
                add.w   D4,D4
                move.l  0(A1,D4.w),D1

                mulu    D5,D1                ; Leider nicht zu vermeiden (Long-Mulu)
                movea.w D1,A3

bugjump0:       moveq   #1,D3
                lsl.w   D7,D3

                move.w  #32768,D4            ; Bei der Mitte geht's los

draw_line0:     clr.w   (A0)
                dbra    D0,go_on0

line_done0:     movem.l (A7)+,D0-A3
                rts

go_on0:         ror.w   #1,D3                ; N„chstes Bit
                bcc.s   next_bit0

                addq.w  #planes,A0           ; N„chtes Wort

next_bit0:      add.w   A3,D4
                bcc.s   draw_line0
                adda.w  D6,A0                ; N„chstes Y

                bra.s   draw_line0

bugfix0:        move.w  D4,D0                ; L„nge
                movea.w #65535,A3
                bra.s   bugjump0

;----

line20:         move.w  D5,D0                ; L„nge

                lea     divtab,A1            ; Offset berechnen
                add.w   D5,D5
                add.w   D5,D5
                move.l  0(A1,D5.w),D1

                mulu    D4,D1
                movea.w D1,A3

                move.w  #32768,D4

                moveq   #1,D3
                lsl.w   D7,D3

draw_line20:    clr.w   (A0)

                dbra    D0,go_on20

                bra     line_done0

go_on20:        adda.w  D6,A0                ; N„chstes Y

                add.w   A3,D4
                bcc.s   draw_line20

                ror.w   #1,D3                ; N„chstes Bit
                bcc.s   draw_line20
                addq.w  #planes,A0           ; N„chtes Wort

                bra.s   draw_line20

;------------------------------------------------------------------------------

; Hier kommen die beiden Code-Tabellen. Natrlich h„tte man, um Speicher zu
; sparen, die Tabellen vom Programm erzeugen lassen k”nnen, aber die Tabellen
; werden von jedem Packer "weggepackt".

; 8 Bytes pro Pixel

linecode1:

                REPT words-1

                or.b    D7,(A0)              ; [12]  15. Bit setzen  {2}
                add.w   A3,D0                ; [4]                   {2}
                bcc.s   *+2                  ;                       {2}
                adda.w  A2,A0                ; [8]   N„chstes Y      {2}

;                                              ----                  ----
;                                              [24]                  {8}

                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)+             ; 8. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D7,(A0)              ; 7. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 6. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 5. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 4. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 3. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 2. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 1. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)              ; 0. Bit setzen
                addq.w  #planes-1,A0         ; N„chstes Wort
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                ENDR
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)+             ; 8. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D7,(A0)              ; 7. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 6. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 5. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 4. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 3. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 2. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 1. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)              ; 0. Bit setzen
                rts

linecode2:      REPT words-1
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)+             ; 8. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D7,(A0)              ; 7. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 6. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 5. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 4. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 3. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 2. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 1. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)              ; 0. Bit setzen
                addq.w  #planes-1,A0         ; N„chstes Wort
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                ENDR
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)+             ; 8. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D7,(A0)              ; 7. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 6. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 5. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 4. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 3. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 2. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 1. Bit setzen
                rts

linecode3:      REPT words-1
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)+             ; 8. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D7,(A0)              ; 7. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 6. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 5. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 4. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 3. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 2. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 1. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)              ; 0. Bit setzen
                addq.w  #planes-1,A0         ; N„chstes Wort
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                ENDR
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)+             ; 8. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D7,(A0)              ; 7. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 6. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 5. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 4. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 3. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 2. Bit setzen
                rts

linecode4:      REPT words-1
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)+             ; 8. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D7,(A0)              ; 7. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 6. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 5. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 4. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 3. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 2. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 1. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)              ; 0. Bit setzen
                addq.w  #planes-1,A0         ; N„chstes Wort
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                ENDR
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)+             ; 8. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D7,(A0)              ; 7. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 6. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 5. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 4. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 3. Bit setzen
                rts

linecode5:      REPT words-1
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)+             ; 8. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D7,(A0)              ; 7. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 6. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 5. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 4. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 3. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 2. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 1. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)              ; 0. Bit setzen
                addq.w  #planes-1,A0         ; N„chstes Wort
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                ENDR
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)+             ; 8. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D7,(A0)              ; 7. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 6. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 5. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 4. Bit setzen
                rts

linecode6:      REPT words-1
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)+             ; 8. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D7,(A0)              ; 7. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 6. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 5. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 4. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 3. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 2. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 1. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)              ; 0. Bit setzen
                addq.w  #planes-1,A0         ; N„chstes Wort
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                ENDR
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)+             ; 8. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D7,(A0)              ; 7. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 6. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 5. Bit setzen
                rts

linecode7:      REPT words-1
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)+             ; 8. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D7,(A0)              ; 7. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 6. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 5. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 4. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 3. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 2. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 1. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)              ; 0. Bit setzen
                addq.w  #planes-1,A0         ; N„chstes Wort
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                ENDR
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)+             ; 8. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D7,(A0)              ; 7. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 6. Bit setzen
                rts

linecode8:      REPT words-1
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)+             ; 8. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D7,(A0)              ; 7. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 6. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 5. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 4. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 3. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 2. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 1. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)              ; 0. Bit setzen
                addq.w  #planes-1,A0         ; N„chstes Wort
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                ENDR
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)+             ; 8. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D7,(A0)              ; 7. Bit setzen
                rts

linecode9:      REPT words-1
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)+             ; 8. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D7,(A0)              ; 7. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 6. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 5. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 4. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 3. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 2. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 1. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)              ; 0. Bit setzen
                addq.w  #planes-1,A0         ; N„chstes Wort
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                ENDR
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)              ; 8. Bit setzen
                rts

linecode10:     REPT words-1
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)+             ; 8. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D7,(A0)              ; 7. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 6. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 5. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 4. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 3. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 2. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 1. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)              ; 0. Bit setzen
                addq.w  #planes-1,A0         ; N„chstes Wort
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                ENDR
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                rts

linecode11:     REPT words-1
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)+             ; 8. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D7,(A0)              ; 7. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 6. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 5. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 4. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 3. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 2. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 1. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)              ; 0. Bit setzen
                addq.w  #planes-1,A0         ; N„chstes Wort
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                ENDR
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                rts

linecode12:     REPT words-1
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)+             ; 8. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D7,(A0)              ; 7. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 6. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 5. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 4. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 3. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 2. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 1. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)              ; 0. Bit setzen
                addq.w  #planes-1,A0         ; N„chstes Wort
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                ENDR
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                rts

linecode13:     REPT words-1
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)+             ; 8. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D7,(A0)              ; 7. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 6. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 5. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 4. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 3. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 2. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 1. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)              ; 0. Bit setzen
                addq.w  #planes-1,A0         ; N„chstes Wort
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                ENDR
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                rts

linecode14:     REPT words-1
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)+             ; 8. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D7,(A0)              ; 7. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 6. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 5. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 4. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 3. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 2. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 1. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)              ; 0. Bit setzen
                addq.w  #planes-1,A0         ; N„chstes Wort
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                ENDR
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                rts

linecode15:     REPT words-1
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)+             ; 8. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D7,(A0)              ; 7. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 6. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 5. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 4. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 3. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 2. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 1. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)              ; 0. Bit setzen
                addq.w  #planes-1,A0         ; N„chstes Wort
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                ENDR
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                rts

linecode16:     REPT words-1
                or.b    D7,(A0)              ; 15. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 14. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 13. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 12. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 11. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 10. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 9. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)+             ; 8. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D7,(A0)              ; 7. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D6,(A0)              ; 6. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D5,(A0)              ; 5. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D4,(A0)              ; 4. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D3,(A0)              ; 3. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D2,(A0)              ; 2. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                bset    D1,(A0)              ; 1. Bit setzen
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                or.b    D1,(A0)              ; 0. Bit setzen
                addq.w  #planes-1,A0         ; N„chstes Wort
                add.w   A3,D0
                bcc.s   *+2
                adda.w  A2,A0                ; N„chstes Y
                ENDR
                or.b    D7,(A0)              ; 15. Bit setzen
                rts

linecode:

; 14 Bytes pro Pixel

                REPT lines-1

                or.w    D1,(A0)              ; [12]  Bit setzen  {2}
                add.w   A3,D0                ; [4]               {2}
                bcc.s   *+6                  ;                   {2}

                ror.w   D2,D1                ; N„chstes X        {2}
                bcc.s   *+2                  ;                   {2}
                addq.w  #planes,A0           ;                   {2}

                adda.w  A2,A0                ; N„chstes Y        {2}

                ENDR

                or.w    D1,(A0)              ; [12]  Bit setzen  {2}

                rts

; Tabellen

tab1:           DC.L linecode16,linecode15,linecode14,linecode13,linecode12,linecode11,linecode10,linecode9
                DC.L linecode8,linecode7,linecode6,linecode5,linecode4,linecode3,linecode2,linecode1

tab2:
c               SET words-1
                REPT words
                DC.W c*130
c               SET c-1
                ENDR

tab3:
c               SET 0
                REPT lines
                DC.W c*14
c               SET c+1
                ENDR

                ENDPART

;-----------------------------------------------------------------------------
; *** Routines for hardware installation/deinstallation

                >PART 'Install all'


install_all:
; saves and installs all hardware registers

                move.b  $ffff820a.w,oldsync  ; save syncmode and resolution
                move.b  $ffff8260.w,oldres

                movem.l $ffff8240.w,D0-D7    ; save old palette
                movem.l D0-D7,oldpalette

                bsr     clear_palette

                lea     $ffff8201.w,A0       ; get old screenpointer
                movep.w 0(A0),D0
                move.w  D0,oldscreen

                move.l  #screen_base,D0
                clr.b   D0                   ; remove lowword in screenpointer
                move.l  D0,screen_1
                add.l   #200*160,D0          ; pointer for second screen
                move.l  D0,screen_2

                move.l  screen_1(PC),D0      ; set the first screen
                bsr     set_screen

                bsr     init_mfp

                bsr     init_soundchip

                move    #$2300,SR            ; allow IRQ's

                bsr     vsync
                bset    #1,$ffff820a.w       ; 50 Hz

                bsr     vsync
                IF resolution=0
                clr.b   $ffff8260.w          ; Lowres
                ENDC
                IF resolution=1
                move.b  #1,$ffff8260.w       ; Medres
                ENDC
                IF resolution=2
                move.b  #2,$ffff8260.w       ; Hires
                ENDC

                bsr     init_keyboard        ; install keyboard

                rts

                ENDPART

                >PART 'Restore' ; alles zurcksetzen

restore_all:
; set back all hardware registers like they were before

                move.l  #start_vbl,$70.w     ; dummy VBL

                bsr     vsync

                bsr     clear_palette

                bsr     vsync
                bset    #1,$ffff820a.w       ; 50 hz
                bsr     vsync
                bclr    #1,$ffff820a.w       ; 60 hz (to remove syncerrors)
                bsr     vsync
                move.b  oldsync,$ffff820a.w  ; restore sync and resolution
                move.b  oldres,$ffff8260.w

                bsr     restore_mfp

                bsr     restore_keyboard

                bsr     restore_soundchip

                move.w  oldscreen,D0
                lea     $ffff8201.w,A0
                movep.w D0,0(A0)             ; alte Screenadresse setzen

                movem.l oldpalette,D0-D7
                movem.l D0-D7,$ffff8240.w

                rts
                ENDPART

                >PART 'Clear palette'

clear_palette:
; sets palette to black
                lea     $ffff8240.w,A0
                moveq   #7,D0                ; clear 8 longs=16 colours
clrpal:         clr.l   (A0)+
                dbra    D0,clrpal
                rts

                ENDPART

                >PART 'Set-Screen'
set_screen:
; in d0 = screenadress

                lsr.l   #8,D0
                lea     $ffff8201.w,A0
                movep.w D0,0(A0)             ; set mid and highbyte
                rts

                ENDPART

                >PART 'Vsync'
vsync:
; wait until vbl has been done
                lea     vsync_count,A6
                move.l  (A6),D7
wait_sync:      cmp.l   (A6),D7
                beq.s   wait_sync
                rts
                ENDPART

                >PART 'MFP-Install+DeInstall'
init_mfp:
; saves all MFP registers and IRQ's and inits them

                move    SR,-(A7)
                ori     #$0700,SR            ; Lock all IRQ's

                lea     $fffffa00.w,A0       ; MFP-Baseregister
                lea     $03(A0),A1           ; Start at MFP Reg $03
                lea     mfp_registers,A2
                moveq   #3,D0                ; Get all registers
save_mfp_loop:  movep.l 0(A1),D1             ; get 4 registers once
                move.l  D1,(A2)+             ; store them
                addq.l  #8,A1                ; next 4 registers
                dbra    D0,save_mfp_loop

                lea     $60.w,A1             ; First Autovector-IRQ
                lea     auto_vec_save,A2     ; Store the 8 Autovectors here
                lea     dummy_IRQ_routine(PC),A3
                moveq   #7,D0                ; 8 pointers
save_avc_loop:  move.l  (A1),D1              ; get old pointer
                move.l  A3,(A1)+             ; let it point on RTE routine
                move.l  D1,(A2)+
                dbra    D0,save_avc_loop

                lea     $0100.w,A1           ; First MFP-Irq
                lea     mfp_vec_save,A2      ; Store the 16 MFP-Pointers here
                moveq   #15,D0               ; 16 pointers
save_irq_loop:  move.l  (A1),D1              ; get old pointer
                move.l  A3,(A1)+             ; let it point on RTE routine
                move.l  D1,(A2)+
                dbra    D0,save_irq_loop

                move.l  #newkey,$0118.w      ; new keyboard IRQ routine
                move.l  #start_vbl,$70.w     ; new VBL (dummy)

                move.b  #$04,$03(A0)         ; Set Active Edge Register
                clr.b   $05(A0)              ; All ports on Input
                move.b  #%1,$07(A0)          ; Allow Timer B (IRQ-Enab. A)
                move.b  #%1000000,$09(A0)    ; Allow Keyb.IRQ (IRQ-Enab. B)
                move.b  #%1,$13(A0)          ; Allow Timer B (IRQ-Mask A)
                move.b  #%1000000,$15(A0)    ; Allow Keyb.IRQ (IRQ-Mask B)
                clr.b   $0b(A0)              ; Clear IRQ Pending A
                clr.b   $0d(A0)              ; Clear IRQ Pending B
                clr.b   $0f(A0)              ; Clear IRQ-In Service A
                clr.b   $11(A0)              ; Clear IRQ-In Service B
                move.b  #%1000000,$17(A0)    ; IRQ Vector Register (Softw. EOI)
                clr.b   $19(A0)              ; Stop Timer A (Timer A Control)
                clr.b   $1b(A0)              ; Stop Timer B (Timer B Control)
                clr.b   $1d(A0)              ; Stop Timer C+D (T. C+D Contr.)
                clr.b   $1f(A0)              ; Timer A Data = 0
                clr.b   $21(A0)              ; Timer B Data = 0
                clr.b   $23(A0)              ; Timer C Data = 0
                clr.b   $25(A0)              ; Timer D Data = 0

                move    (A7)+,SR
                rts

restore_mfp:
; restores all MFP registers and IRQ's

                move    SR,-(A7)
                ori     #$0700,SR            ; Lock all IRQ's

                lea     $fffffa03.w,A1       ; MFP
                lea     mfp_registers,A2
                moveq   #3,D0                ; Get all registers
rest_mfp_loop:  move.l  (A2)+,D1             ; get 4 registers once
                movep.l D1,0(A1)             ; restore them
                addq.l  #8,A1                ; next 4 registers
                dbra    D0,rest_mfp_loop

                lea     $60.w,A1             ; First Autovector-IRQ
                lea     auto_vec_save,A2     ; Store the 8 Autovectors here
                moveq   #7,D0                ; 8 pointers
rest_avc_loop:  move.l  (A2)+,(A1)+          ; restore old pointer
                dbra    D0,rest_avc_loop

                lea     $0100.w,A1           ; First MFP-Irq
                lea     mfp_vec_save,A2      ; Store the 16 MFP-Pointers here
                moveq   #15,D0               ; 16 pointers
rest_irq_loop:  move.l  (A2)+,(A1)+          ; restore old pointer
                dbra    D0,rest_irq_loop

                move    (A7)+,SR
                rts


start_vbl:
; first dummy VBL
                addq.l  #1,vsync_count
                rte


dummy_IRQ_routine:
; just to switch off all not needed IRQ's
                rte

                ENDPART

                >PART 'Keyboard-Install+DeInstall'

init_keyboard:
; saves the keyboard status and installs everything necessary.

                move    SR,-(A7)
                ori     #$0700,SR            ; lock all IRQ's

                lea     keyboard_save,A1     ; put in values here
                lea     $fffffc00.w,A2       ; keyboard base address
                lea     keystatlist(PC),A3
get_keyb_stats: move.b  (A3)+,D0             ; get status inquiry reg
                bmi.s   keystatready         ; -1 is last value
                add.w   #$80,D0              ; +$80 -> status inquiry
                bsr     send_ikbd            ; send status inquiry
                moveq   #7,D1                ; get 8 values
get_packet_lp:  btst    #0,(A2)              ; Receive reg. full?
                beq.s   get_packet_lp
                move.b  2(A2),(A1)+          ; store value from packet
                dbra    D1,get_packet_lp
                bra.s   get_keyb_stats
keystatready:

                moveq   #$12,D0              ; disable mouse
                bsr     send_ikbd

                moveq   #$1a,D0              ; disable joysticks
                bsr     send_ikbd

                move    (A7)+,SR
                rts

restore_keyboard:
; restores all the IKBD status
                move    SR,-(A7)
                ori     #$0700,SR            ; lock all IRQ's

                lea     keyboard_save,A0
                moveq   #12,D1               ; 13 status values to restore
restore_ikbd_l: addq.l  #1,A0                ; skip first value
                moveq   #6,D2                ; 7 values
rest_ik_l2:     move.b  (A0)+,D0             ; send all the status bytes
                bsr     send_ikbd
                dbra    D2,rest_ik_l2
                dbra    D1,restore_ikbd_l


                move    (A7)+,SR
                rts


send_ikbd:
; sends byte in d0 to keyboardprocessor
                move.l  A0,-(A7)
                lea     $fffffc00.w,A0
waitkeyready:   btst    #1,(A0)              ; wait until Transm. Data reg empty
                beq.s   waitkeyready
                move.b  D0,2(A0)
                movea.l (A7)+,A0
                rts


keystatlist:
; list for all keyboard stats to restore/save (13 values)
                DC.B $19,$15,$14,$10,$0f,$0c,$0b,$0a,$09,$08,$07,$12,$1a,-1


                ENDPART

                >PART 'Soundchip-Install+DeInstall'

init_soundchip:
; saves all soundchip values and inits the soundchip

                lea     $ffff8800.w,A0
                lea     sound_save,A1
                moveq   #15,D0               ; save soundchip
save_sound:     move.b  D0,(A0)              ; select port
                move.b  (A0),(A1)+           ; get register
                dbra    D0,save_sound

                move.b  #8,(A0)              ; soundchip off (voulume a+b+c)
                clr.b   2(A0)
                move.b  #9,(A0)
                clr.b   2(A0)
                move.b  #10,(A0)
                clr.b   2(A0)
                rts

restore_soundchip:
; restores the soundchip status

                lea     sound_save,A0
                lea     $ffff8800.w,A1
                moveq   #15,D0               ; restore soundchip
restore_sound:  move.b  D0,(A1)              ; select port
                move.b  (A0)+,2(A1)
                dbra    D0,restore_sound
                rts

                ENDPART

;------------------------------------------------------------------------------
; all IRQ routines

vbl:            addq.l  #1,vsync_count
                rte

                >PART 'Keyboard IRQ'
newkey:
                move.w  D0,-(A7)
                move.b  $fffffc00.w,D0       ; get status
                btst    #7,D0                ; IRQ-request?
                beq.s   endkey               ; no -> out here
                move.b  $fffffc02.w,key      ; save keyboard value
endkey:         move.w  (A7)+,D0
                rte

                ENDPART

;------------------------------------------------------------------------------

                DATA

screen_1:       DC.L 0
screen_2:       DC.L 0
key:            DC.W 0

palette:        DC.W $00,$0777,$0730,$0750,$0770,$0470,$70,$75
                DC.W $77,$57,$27,$07,$0507,$0707,$0704,$0777

;------------------------------------------------------------------------------


                BSS

bss_start:      >PART 'Saveregs'

mfp_registers:  DS.L 4
auto_vec_save:  DS.L 8
mfp_vec_save:   DS.L 16

oldres:         DS.B 1
oldsync:        DS.B 1
oldpalette:     DS.L 8
oldscreen:      DS.W 1

oldstack:       DS.L 1
old_sr:         DS.W 1

sound_save:     DS.B 16
keyboard_save:  DS.B 13*8
vsync_count:    DS.L 1
                ENDPART

                >PART 'Stack'
                DS.B 512        ; 512 bytes stack
stack:
                ENDPART

                >PART 'Screens'
                DS.B 256        ; because of screen lowbyte reserve 256 more
screen_base:    DS.B 32000*2    ; space for two screens
                ENDPART

divtab:         DS.L pixels     ; 1280 Bytes Tabelle (Lo-Res)
ytab:           DS.W lines      ;  400 Bytes Tabelle (Lo-Res)

bss_end:

; see you on Falcon 030...

                END
