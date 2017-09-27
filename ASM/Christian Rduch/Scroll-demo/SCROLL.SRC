;
;       Scroll-Demo 
;
;       ST Assemblerecke
; 
;       (c) 1988  By 
;
;       Christian Rduch 
;
start:

move.w #2,-(sp)         ;Open File
move.l #file,-(sp)      ;(Filename
move.w #$3d,-(sp)       ;kann ge—ndert
trap #1                 ;werden)
addq.l #8,sp
tst.w d0
bmi start               ;Fehler ?
move.w d0,handle                
move.l #buffer,-(sp)    ;Read Degas
move.l #32034,-(sp)     ;Bild
move.w handle,-(sp)     ;(Farben und
move.w #$3f,-(sp)       ;Bitmap)
trap #1
add.l #12,sp
tst.l d0
bmi start               ;Fehler?
move.w handle,-(sp)
move.w #$3e,-(sp)       ;Close File
trap #1
addq.l #4,sp
tst.w d0
bmi start

super:                  ;umschalten
move.l #0,-(sp)         ;in den
move.w #32,-(sp)        ;Supervisor-
trap #1                 ;modus
addq.l #6,sp


colours:                ;Farben aus
move.l #buffer+2,a0     ;dem Buffer
move.l #$ff8240,a1      ;in die
move.w #7,d0            ;Farbregister
colours1:               ;kopieren.
move.l (a0)+,(a1)+
dbra d0,colours1

makeblocks:             ;eine Reihe
move.l #buffer+34,a0    ;mit 10 BlÓcken
move.l #tabelle1,a2     ;(32*32) Pixel
move.w #9,d0            ;aus dem Buffer
makeblocks1:            ;in die
move.l a0,a1            ;Blocktabelle
move.w #31,d1           ;kopieren.
makeblocks2:
move.l (a1)+,(a2)+      ;(je 16 Bytes
move.l (a1)+,(a2)+      ;pro Zeile)
move.l (a1)+,(a2)+
move.l (a1)+,(a2)+
add.l #144,a1
dbra d1,makeblocks2
add.l #16,a0
dbra d0,makeblocks1

move.l #tabelle2,a0     ;Tabelle 2
move.b #0,d0            ;(Playfield)
move.w #599,d1          ;mit den 
maketab2:               ;Blocknummern
move.b d0,(a0)+         ;0 bis 6
addq.b #1,d0            ;auffuellen
cmp.b #7,d0
blt maketab2a
move.b #0,d0
maketab2a:
dbra d1,maketab2


aa:
move.l #irq,$70         ;neuer VBL-
                        ;Interrupt

ende:bra ende           ;Immer im Kreis

irq:                    ;VBL-Irq-Beginn
addq.w #3,yphase        ;Verschiebewert
                        ;um 3 erhÓhen
                        ;(das Tempo
                        ;kann aber
                        ;noch grÓ˚er
                        ;sein !!)
cmp.w #32,yphase        ;grÓ˚er 31 ?
                        ;nein, dann
blt scrolling           ;weiter
sub.w #32,yphase        ;sonst minus 32
subq.l #6,position      ;und im
                        ;Playfield eine
                        ;Spalte
                        ;runter.
cmp.l #tabelle2+6,position;Ende des
bgt scrolling           ;Playfields
move.l #tabelle2+540,position;wieder
                        ;nach unten
scrolling:
bsr scroll              ;Bildaufbau
move.b screen+1,$ff8201 ;Bitmap-Adresse
move.b screen+2,$ff8203 ;ver—ndern
cmp.l #screen0,screen   ;logische
beq now1                ;Bitmap-Adresse
move.l #screen0,screen  ;umschalten.
bra endirq
now1:
move.l #screen1,screen
endirq:                 ;Irq zu Ende
rte

scroll:                 ;
move.l position,a0      ;Position in
                        ;Playfield
move.l screen,a1        ;Bildschirm-
                        ;adresse
cmp.w #0,yphase         ;'glatter'
                        ;Blockbeginn ?
                        ;ja, dann 1.
                        ;Teil ≈ber-
beq teil2               ;springen.
teil1:                  ;
subq.l #6,a0            ;eine Zeile
                        ;weiter oben
                        ;Anfangen.
move.w #5,d7            ;6 Bloecke
teil1a:                 ;
moveq #0,d1             ;
move.b (a0)+,d1         ;Blocknummer
mulu #512,d1            ;mal 512 (Block
                        ;l—nge)
move.l #tabelle1,a2     ;Blocktabelle+
add.l d1,a2             ;Offset=
                        ;Blockstart
move.l a1,a3            ;a3 zum kopieren
                        ;nehmen.
move.w #32,d0           ;Erst ab der
sub.w yphase,d0         ;32-yphase
                        ;Zeile den
lsl.w #4,d0             ;Block kopieren
add.w d0,a2             ;
move.w yphase,d6        ;yphase-Zeilen
subq.w #1,d6            ;kopieren.
teil1b:                 ;
move.l (a2)+,(a3)+      ;eine Block-
move.l (a2)+,(a3)+      ;zeile mit
move.l (a2)+,(a3)+      ;16 Bytes
move.l (a2)+,(a3)+      ;kopieren
add.l #144,a3           ;
dbra d6,teil1b          ;
add.l #16,a1            ;n—chster Block
                        ;beginnt 16
                        ;Bytes sp—ter.
dbra d7,teil1a          ;

teil2:                  ;
move.l screen,a1        ;Berechnen, bis
move.w yphase,d0        ;wohin die
mulu #160,d0            ;Bitmap schon
add.w d0,a1             ;gef≈llt ist.
move.w #4,d7            ;5 Zeilen
teil2a:                 ;zu je
move.w #5,d6            ;6 BlÓcken 
teil2b:                 ;
moveq #0,d1             ;
move.b (a0)+,d1         ;aktuellen
mulu #512,d1            ;Blockanfang
                        ;berechnen
move.l #tabelle1,a2     ;
add.l d1,a2
move.l a1,a3
move.w #31,d5           ;jetzt alle 32
teil2c:                 ;Zeilen der
move.l (a2)+,(a3)+      ;BlÓcke 
move.l (a2)+,(a3)+      ;kopieren.
move.l (a2)+,(a3)+
move.l (a2)+,(a3)+
add.l #144,a3 
dbra d5,teil2c
add.l #16,a1
dbra d6,teil2b
add.l #5024,a1          ;n—chste Block-
                        ;zeile ist
                        ;32 Zeilen
                        ;minus 96 Bytes
                        ;weiter unten.
dbra d7,teil2a
teil3:                  ;letzte Bild-
                        ;schirmzeilen
move.w #5,d7            ;f≈llen
teil3a:
moveq #0,d1
move.b (a0)+,d1
mulu #512,d1
move.l #tabelle1,a2
add.l d1,a2
move.l a1,a3
move.w #31,d6           ;nur noch
sub.w yphase,d6         ;32-yphase
teil3b:                 ;Zeilen
move.l (a2)+,(a3)+      ;kopieren
move.l (a2)+,(a3)+
move.l (a2)+,(a3)+
move.l (a2)+,(a3)+
add.l #144,a3
dbra d6,teil3b
add.l #16,a1
dbra d7,teil3a
endscroll:              ;Schluss
rts





screen:dc.lscreen0      ;Screenadresse
yphase:dc.w0            ;Verschiebewert
position:dc.ltabelle2+540;Position im
                        ;Playfield
handle:dc.w0
file:dc.b"bloecke1.pi1",0;kann ge—ndert
                        ;werden
even
buffer:blk.b32034,0     ;Buffer f≈r
                        ;Degas-Bild
tabelle2:               ;Playfield
blk.b600,0
tabelle1:               ;Blocktabelle
blk.b5120,0

org$70000               ;erster Screen
screen0:

org$78000               ;zweiter Screen
screen1:

