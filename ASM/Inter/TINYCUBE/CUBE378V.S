******************************************************************************
**                                                                          **
**              tiny cube II                                                **
**              ------------                                                **
**                                                                          **
**              org code                size opts                           **
**              lost/inter              lost/inter, sebastian/spirits       **
**                                                                          **
**              size                    machine                             **
**              346 bytes code (!)      falcon/motorola mc 68030            **
**              378 f�r's TOS                                               **
**                                                                          **
**              Final changes july 16th 1996                                **
**              Version for VGA-Monitors with manual linedoubling           **
**                                                                          **
******************************************************************************

                mc68030

                moveq   #5,d7

                lea     screen(pc),a6   ;Bildschirmadresse und
                pea     $00030024       ;aufl�sung setzen
                pea     (a6)
                pea     (a6)
                move.w  d7,-(sp)
                trap    #14

                clr.l   -(sp)           ;In Supervisor-Modus
                move.w  #32,-(sp)
                trap    #1

                ori     #$0700,sr       ;Alle irq's aus

                move.b  d7,$ffff82c3.w  ;Zeilenverdopplung an

loop:           clr.l   (a6)+           ;Bildschirm schwarz
                addq.w  #1,(sp)
                bne.s   loop

                clr.l   $ffff9800.w     ;Border schwarz

;             ; "sinus"-tabelle berechnen

                lea     sin(pc),a4
                lea     128*2(a4),a0
                movea.l a0,a6
                moveq   #-1,d0
                lsr.w   #1,d0
                moveq   #1,d2
sin16r1:
                sub.w   d2,d0
                move.w  d0,-(a0)
                move.w  d0,(a6)+
                addq.w  #4,d2
                cmp.w   #512+1,d2
                bne.s   sin16r1
                sub.w   d0,d2
sin16r2:        move.w  (a0)+,(a6)
                neg.w   (a6)+
                subq.w  #1,d2
                bne.s   sin16r2

;             ; farbpalette berechnen

                movea.l a6,a3
col_gen0:       move.w  d2,(a6)+        ;scharz .. rot
                add.w   #$0800,d2
                bpl.s   col_gen0
col_gen1:       move.w  d2,(a6)+        ;rot .. gelb
                add.w   #$0840,d2
                bcc.s   col_gen1

;             ; feuer darstellen
;             ; ab hier endlosschleife !

fire_loop:      movea.l a6,a0
                lea     screen+120+20*320*2(pc),a2

                moveq   #100-1,d2
draw0:          moveq   #100-1,d1
draw1:          move.b  (a0),d0         ;vier pixel summieren : oben
                lea     99(a0),a1
                add.b   (a1)+,d0        ;links unten
                add.b   (a1)+,d0        ;mitte unten
                add.b   (a1),d0         ;rechts unten
                beq.s   draw2
                subq.b  #1,d0           ;abdunkeln, aber nur wenn erlaubt
draw2:          lsr.b   #2,d0           ;durchschnitt bilden
                move.b  d0,(a0)+        ;neuen wert speichern
                move.l  (a3,d0.w*2),d3
                move.l	d3,320*2(a2)
                move.l	d3,(a2)+
                dbra    d1,draw1
                lea     240+320*2(a2),a2
                dbra    d2,draw0

;             ; drehwinkel �ndern

                lsr.w   #7,d2           ;modulo-maske 511 f�r winkelz�hler !
                addq.w  #2,-(a4)        ;winkel-inc um alpha-achse
                addq.w  #3,-(a4)        ;dito f�r beta-achse
                movea.l a4,a2
                move.l  (a4)+,d1        ;Alpha in d1.hi, Beta in d1.lo

;             ; rotation der acht eckpunke

                moveq   #8-1,d7         ;8 Eckpunkte

rotate0:        move.w  d7,d0           ;trick : die koordinaten der eckpunkte
                moveq   #30,d4          ;sind ja d,d,d / d,d,-d / d,-d,d /
                asr.w   #1,d0           ;d,-d,-d etc. und lassen sich damit
                bcc.s   rotate1         ;wunderbar aus dem schleifenz�hler
                neg.w   d4              ;herleiten ! (abstand d = 31)

rotate1:        movea.w d3,a1

                moveq   #30,d3
                asr.w   #1,d0
                bcc.s   rotate2
                neg.w   d3

rotate2:        move.w  d3,d5           ;hier die rotationsberechnung
                move.w  d4,d6
                and.w   d2,d1
                lea     (a4,d1.w*2),a0
                muls    256(a0),d3
                muls    256(a0),d4
                muls    (a0),d5
                muls    (a0),d6
                swap    d1
                sub.l   d6,d3           ;cos*x - sin*y
                add.l   d5,d4           ;sin*x + cos*y

                moveq   #15,d6          ;werte normalisieren
                asr.l   d6,d3
                asr.l   d6,d4           ;wegen der zwei achsen ...
                not.b   (sp)            ;oberstes byte auf dem stack
                bne.s   rotate1         ;als schleifenz�hler missbraucht

                add.w   #256/2-31,d4    ;Projektion (2 durchl�ufe)

project:        muls    d4,d3

                asr.w   #7,d3
                add.w   #50,d3          ;zentrieren
                move.w  d3,-(a2)
                move.w  a1,d3

                not.b   (sp)            ;wegen der zwei projektionen x+y
                bne.s   project         ;stack als schleifenz�hler benutzen

                subq.l  #1,d7           ;genauso lang wie dbra, der bfextu
                bcc.s   rotate0         ;braucht aber d7 als langwort !

;             ; linien zeichen

lines_loop:     bfextu (a2){d7:3},d0    ;Punkt A holen
                movem.w (a2,d0.w*4),d0-d1 ;und dessen Koordinaten
                subq.w  #3,d7

                bfextu (a2){d7:3},d2    ;Punkt B holen
                beq     fire_loop
                movem.w (a2,d2.w*4),d2-d3 ;und dessen Koordinaten
                subq.w  #3,d7

                lea     (a6,d0.w),a0    ;Christians Linienroutine
                moveq   #1,d4           ;Motto : Langsam aber sicher ...
                sub.w   d0,d2
                bpl.s   lines0
                neg.w   d2
                neg.w   d4
lines0:         moveq   #100,d5
                sub.w   d1,d3
                bpl.s   lines1
                neg.w   d3
                neg.w   d5
lines1:         muls    #100,d1
                adda.l  d1,a0
                moveq   #31,d1          ;Linienfarbe
                cmp.w   d2,d3
                bgt.s   lines3
                bne.s   lines2
                add.w   d5,d4
lines2:         exg     d2,d3
                exg     d4,d5
lines3:         divu.l  d3,d2:d2        ;klappt ... :-)
lines4:         move.b  d1,(a0)
                adda.w  d5,a0
                add.l   d2,d6
                bcc.s   lines5
                adda.w  d4,a0
lines5:         dbra    d3,lines4
                bra.s   lines_loop

;Zu verbindende Punkte in 3-bit, um 2 bit nach rechts verschoben und in
;umgedrehter Reihenfolge ... (da Anfang beim -1ten Bit ab "Lines")

                dc.b $00,$37,$9b,$db,$3b,$ca,$98,$13,$41,$92
lines:
                bss

pts_rot:        ds.w 2*8                ;
rot3dangle:     ds.w 2                  ; \  m�ssen nur aufeinander folgen
sin:            ds.w 512/4              ;  \ die labels selbst werden nicht
cos:            ds.w 512                ;  / alle benutzt !
                ds.w 2
feuer_col:      ds.w 32                 ; /
feuer_buffer:   ds.b 100*101
screen:         ds.l 65535
                ds.l 1

                end
