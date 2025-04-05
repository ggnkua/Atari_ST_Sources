; ----------------------------------------------------------------------------
;
;               432 bytes cube
;               --------------
;
;               org code                size opts
;               lost/inter              lost/inter, sebastian
;
;               size                    machine
;               400 bytes code          falcon/motorola mc 68030
;               432 fÅr's TOS
;
; ----------------------------------------------------------------------------

short           equ 1                   ;Kurze (Xbios-)Version

                ifne short
                default 2
                else
                default 1
                endc

                PART 'Start'
                if short=1

                moveq   #5,d7

                lea     screen(pc),a6   ;Bildschirmadresse und
                pea     $00030024       ;auflîsung setzen
                pea     (a6)
                pea     (a6)
                move.w  d7,-(sp)
                trap    #14

                clr.l   -(sp)           ;In Supervisor-Modus
                move.w  #32,-(sp)
                trap    #1

                ori     #$0700,sr       ;Alle irq's aus

                move.b  d7,$ffff82c3.w  ;Zeilenverdopplung an
                moveq   #-1,d0          ;Bildschirm schwarz
l0:             clr.l   (a6)+
                dbra    d0,l0
                clr.l   $ffff9800.w     ;Border schwarz

;----------------------

                else
                clr.l   -(sp)           ;In Supervisor-Modus
                move.w  #32,-(sp)
                trap    #1
                lea     $ffff820c.w,a0
                lea     screen(pc),a1
                move.l  a1,d0
                ror.l   #8,d0
                movep.w d0,-$000b(a0)
                move.w  a1,(a0)
                lea     $ffff8282.w,a0
                move.l  #$00fe0056,(a0)+
                move.l  #$008e006d,(a0)+
                move.l  #$005600d3,(a0)+
                lea     $ffff82a2.w,a0
                move.l  #$0271020d,(a0)+
                move.l  #$007d007d,(a0)+
                move.l  #$020d026b,(a0)+
                move.w  #$0200,$ffff820a.w
                move.w  #$0100,$ffff8266.w
                move.l  #$01820001,$ffff82c0.w
                move.w  #$00c8,$ffff8210.w
                endc
                endpart

;             ; sinustabelle berechnen, mittels taylor-reihe :
;             ; sin(x) = x - (x^3)/3! + (x^5)/5! - (x^7)/7! + (x^9)/9!
;             ; diese routine berechnet 512 werte im signed-15-format,
;             ; an die tabelle sind nochmal 128 werte fÅr einfacheres
;             ; cosinus-handling angehÑngt. alle werte sind genau
;             ; passend fÅr [ muls <sin>,d0 / add.l d0,d0 / swap d0 ]
;             ; 1=$7fff, -1=$8001

sin_gen:        lea     sin(pc),a0      ;
                movea.l a0,a1           ;
                movea.l a0,a4           ;
                lea     512+2(a0),a6    ;
                moveq   #0,d6           ;winkelzÑhler x

sin_gen1:       move.l  d6,d5           ;anfangswert fÅr sin(x) auf x setzen
                moveq   #8,d2           ;schleifenzÑhler : bis x^(8+1)

sin_gen2:       move.l  d2,d1           ;Ñuûere akkumulationsschleife
                move.l  d2,d0           ;berechnung eines sinuswertes
                addq.w  #1,d0           ;
                move.l  d6,d3           ;

sin_gen3:       mulu.l  d6,d4:d3        ;innerste potenzierungssschleife
                move.w  d4,d3           ;berechnen von x^n in d3
                swap    d3              ;
                mulu.l  d1,d0           ;berechnen von n! in d0
                subq.w  #1,d1           ;
                bne.s   sin_gen3        ;
                divu.l  d0,d3           ;x^n durch n! teilen
                btst    #1,d2           ;im fall x^3 und x^7 subtrahieren
                beq.s   sin_gen4        ;
                neg.l   d3              ;
sin_gen4:       add.l   d3,d5           ;im fall x^5 und x^9 addieren
                subq.w  #2,d2           ;
                bne.s   sin_gen2        ;

                asr.l   #1,d5           ;ins 15-bit format bringen

                move.w  d5,(a0)+        ;werte sichern
                move.w  d5,-(a6)        ;da sin(x)=sin(180-x)

                add.l   #$00000324,d6   ;nÑchster winkel (2*pi*65536/512)

                addq.w  #4,d5           ;bis ein viertelkreis berechnet ist
                bpl.s   sin_gen1        ;
                move.w  #$7fff,-(a6)    ;scheitelpunkt "genau" 1 !
                lea     512/2(a6),a6    ;bereich von 180¯-540¯ spiegeln
sin_gen5:       move.w  (a1)+,(a6)      ;
                neg.w   (a6)+           ;
                cmp.w   (a1),d5         ;
                bne.s   sin_gen5        ;

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
                if short=1
                lea     screen+120(pc),a2
                else
                lea     screen(pc),a2
                endc

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
                move.l  0(a3,d0.w*2),(a2)+ ;pixel auf bildschirm
                dbra    d1,draw1
                if short=1
                lea     240(a2),a2
                endc
                dbra    d2,draw0

;             ; drehwinkel Ñndern

                lsr.w   #7,d2           ;modulo-maske 511 fÅr winkelzÑhler !
                addq.w  #2,-(a4)        ;winkel-inc um alpha-achse
                addq.w  #3,-(a4)        ;dito fÅr beta-achse
                movea.l a4,a2
                move.l  (a4)+,d1        ;Alpha in d1.hi, Beta in d1.lo

;             ; rotation der acht eckpunke

                moveq   #8-1,d7         ;8 Eckpunkte

rotate0:        move.w  d7,d0           ;trick : die koordinaten der eckpunkte
                moveq   #31,d4          ;sind ja d,d,d / d,d,-d / d,-d,d /
                asr.w   #1,d0           ;d,-d,-d etc. und lassen sich damit
                bcc.s   rotate1         ;wunderbar aus dem schleifenzÑhler
                neg.w   d4              ;herleiten ! (abstand d = 31)

rotate1:        movea.w d3,a1

                moveq   #31,d3
                asr.w   #1,d0
                bcc.s   rotate2
                neg.w   d3

rotate2:        move.w  d3,d5           ;hier die rotationsberechnung
                move.w  d4,d6
                and.w   d2,d1
                lea     0(a4,d1.w*2),a0
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
                bne.s   rotate1         ;als schleifenzÑhler missbraucht

                add.w   #256/2-31,d4    ;Projektion (2 durchlÑufe)

project:        muls    d4,d3

                asr.w   #7,d3
                add.w   #50,d3          ;zentrieren
                move.w  d3,-(a2)
                move.w  a1,d3

                not.b   (sp)            ;wegen der zwei projektionen x+y
                bne.s   project         ;stack als schleifenzÑhler benutzen

                subq.l  #1,d7           ;genauso lang wie dbra, der bfextu
                bcc.s   rotate0         ;braucht aber d7 als langwort !

;             ; linien zeichen

lines_loop:
                dc.l $e9d209c3          ;Punkt A holen
;               bfextu (a2){d7:3},d0
                movem.w 0(a2,d0.w*4),d0-d1 ;und dessen Koordinaten
                subq.w  #3,d7

                dc.l $e9d229c3          ;Punkt B holen
;               bfextu (a2){d7:3},d2
                beq     fire_loop
                movem.w 0(a2,d2.w*4),d2-d3 ;und dessen Koordinaten
                subq.w  #3,d7

                lea     0(a6,d0.w),a0

                moveq   #1,d4
                sub.w   d0,d2
                bpl.s   lines0
                neg.w   d2
                neg.w   d4
lines0:         moveq   #100,d5
                sub.w   d1,d3
                bpl.s   lines1
                neg.w   d3
                neg.w   d5
lines1:         mulu    #100,d1
                adda.l  d1,a0
                moveq   #31,d1          ;Linienfarbe
                cmp.w   d2,d3
                bgt.s   lines3
                bne.s   lines2
                add.w   d5,d4
lines2:         exg     d2,d3
                exg     d4,d5
lines3:         divu.l  d3,d2:d2        ;klappt ...
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
;
                bss
pts_rot:        ds.w 2*8                ;
rot3dangle:     ds.w 2                  ; \  mÅssen aufeinander folgen
sin:            ds.w 512/4              ;  \ die labels selbst werden nicht
cos:            ds.w 512                ;  / alle benutzt
feuer_col:      ds.w 32                 ; /
feuer_buffer:   ds.b 100*101
screen:         ds.l 65535
                ds.l 1

                end
