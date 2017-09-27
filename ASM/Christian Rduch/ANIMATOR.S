;
;  Animations-Demo
;
;  (c) 1988 by
;  Christian Rduch  
;  ST-Assemblerecke
;  ATARI-Magazin
;
;
;  Die Animationsphasen m≈ssen
;  in Shape1 bis Shape8 eingetragen
;  werden.
;

start:
clr.l -(sp)             ;Supervisormode
move.w #32,-(sp)        ;einschalten
trap #1
addq.l #6,sp
move.l #key,-(sp)       ;Joystickmeldung
move.w #1,-(sp)         ;von der 
move.w #25,-(sp)        ;Tastatur an.
trap #14
addq.l #8,sp
move.w #34,-(sp)        ;Joystick-
trap #14                ;vektor verbie-
addq.l #2,sp            ;gen.
move.l a1,a0
add.l #24,a0
move.l #joyvec,(a0)
bsr hintergrundholen    ;vorab einen
                        ;Hintergrund
                        ;retten.
move.l #irq,$70         ;neuer VBL-Irq.

ende:                   ;immer im Kreis
bra ende

joyvec:                 ;Joystickwerte
move.w (a0)+,joystick   ;in Variable
rts

irq:
cmp.w #0,bewegtflag     ;Figur schon im
bne bewegung            ;Schritt ?
move.b joystick+1,d0    ;Nein,dann
and.b #12,d0            ;Joystick-
cmp.b #4,d0             ;abfrage.
beq links
cmp.w #8,d0
beq rechts
bra weiter      
links:                  ;Linksbewegung
move.w #1,bewegtflag    ;initialisieren
move.w #0,phase
bra bewegung
rechts:                 ;Rechtsbewegung
move.w #2,bewegtflag    ;initialisieren
move.w #0,phase
bewegung:
cmp.w #1,bewegtflag     ;Welche Richtung
bne rechtsbewegen
linksbewegen:
subq.w #1,x             ;nach links
addq.w #1,zaehler       ;nur jedes 4.
cmp.w #4,zaehler        ;mal eine Phase
blt weiter              ;weiter
move.w #0,zaehler
addq.w #4,phase
cmp.w #32,phase         ;alle Phasen         
beq bewegungende        ;durch ?
move.w phase,d0         ;Shapezeiger
move.l #schrittlinks,a0 ;berechnen und
add.w d0,a0             ;eintragen
move.l (a0),shape
bra weiter
rechtsbewegen:          ;nach rechts
addq.w #1,x             ;
addq.w #1,zaehler       ;nur jedes 4.
cmp.w #4,zaehler        ;mal eine Phase
blt weiter              ;weiter
move.w #0,zaehler
addq.w #4,phase
cmp.w #32,phase         ;alle Phasen
beq bewegungende        ;durch?
move.w phase,d0         ;Shapezeiger
move.l #schrittrechts,a0;berechnen und
add.w d0,a0             ;eintragen
move.l (a0),shape
bra weiter
bewegungende:
move.w #0,bewegtflag    ;Bewegung zuende

weiter:
bsr hintergrundschreiben;alten Hinter-
                        ;grund zur≈ck
bsr hintergrundholen    ;neuen Hinter-
                        ;grund holen
bsr shape16             ;Shape setzen.

rte                     ;Ende des Irq.


hintergrundholen:       ;Hintergrund
                        ;retten.
move.w x,d0             ;Startadresse
move.w y,d1             ;des Shapes be-
mulu #160,d1            ;rechnen.
lsr.w #4,d0
lsl.w #3,d0
move.l #screen,a0
add.w d0,a0
add.w d1,a0
move.l #buffer,a1       ;Startadresse in
move.l a0,(a1)+         ;Buffer spei-
                        ;chern.
move.w #31,d0           ;32 Zeilen
loop0:
move.l (a0)+,(a1)+      ;jeweils 16
move.l (a0)+,(a1)+      ;Bytes 
move.l (a0)+,(a1)+      ;(2 BlÓcke)
move.l (a0)+,(a1)+      ;retten.
add.l #144,a0           ;n—chste Zeile
dbra d0,loop0
rts                     ;Ende

hintergrundschreiben:   ;Hintergrund
                        ;wiederherstel.
move.l #buffer,a0       ;alte Adresse
move.l (a0)+,a1         ;holen
move.w #31,d0           ;32 Zeilen
loop1:
move.l (a0)+,(a1)+      ;jeweils 16
move.l (a0)+,(a1)+      ;Bytes zur≈ck-
move.l (a0)+,(a1)+      ;schreiben.
move.l (a0)+,(a1)+
add.l #144,a1           ;n—chste Zeile
dbra d0,loop1
rts                     ;Ende

shape16:                ;16Pixel Shape
                        ;setzen
move.l #buffer,a0       ;Startadresse
move.l (a0),a1          ;holen
move.l shape,a0         ;Zeiger auf
                        ;Shapedaten
move.w x,d0             ;X-Rotation der
and.w #15,d0            ;BlÓcke ber.
move.w #31,d1           ;32 Zeilen
loop2:
moveq #0,d2             
move.w (a0)+,d2         ;Maske berechen
or.w (a0)+,d2           ;in der alle
or.w (a0)+,d2           ;Bits gesetzt
or.w (a0)+,d2           ;sind, die 
subq.l #8,a0            ;im Shape 
ror.l d0,d2             ;gelÓscht sind.
not.l d2
and.w d2,(a1)+          ;Maske mit
and.w d2,(a1)+          ;Hintergrund
and.w d2,(a1)+          ;verkn≈pfen
and.w d2,(a1)+
swap d2
and.w d2,(a1)+
and.w d2,(a1)+
and.w d2,(a1)+
and.w d2,(a1)+
sub.l #16,a1
moveq #0,d2
moveq #0,d3
moveq #0,d4
moveq #0,d5
move.w (a0)+,d2         ;Shapedaten
move.w (a0)+,d3         ;in Register
move.w (a0)+,d4         ;und danach
move.w (a0)+,d5         ;rotieren
ror.l d0,d2
ror.l d0,d3
ror.l d0,d4
ror.l d0,d5
or.w d2,(a1)+           ;jetzt in HG
or.w d3,(a1)+           ;verkn≈pfen
or.w d4,(a1)+
or.w d5,(a1)+
swap d2
swap d3
swap d4
swap d5
or.w d2,(a1)+
or.w d3,(a1)+
or.w d4,(a1)+
or.w d5,(a1)+
add.l #144,a1           ;neue Zeile
dbra d1,loop2
rts                     ;Ende

key:dc.b$14,$14
bewegtflag:dc.w0
phase:dc.w0
zaehler:dc.w0
joystick:dc.w0
x:dc.w100
y:dc.w100
shape:dc.lshape1
schrittlinks:
dc.lshape1,shape2,shape3,shape4
dc.lshape5,shape6,shape7,shape8
schrittrechts:
dc.lshape8,shape7,shape6,shape5
dc.lshape4,shape3,shape2,shape1

buffer:
blk.b516,0
;
;   jetzt kommen die 8 Phasen
;
shape1:
blk.b256,255
shape2:
blk.b256,255
shape3:
blk.b256,255
shape4:
blk.b256,255
shape5:
blk.b256,255
shape6:
blk.b256,255
shape7:
blk.b256,255
shape8:
blk.b256,255

;    den Wert eventuell auf 
;    $78000 anpassen (512 KB)
org $f8000
screen:

