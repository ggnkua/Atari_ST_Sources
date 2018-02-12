;
;    Laufschrift im Bildschirmrahmen
;
;    (c)  By   Christian Rduch
; 
;    fÅr die ST Assemblerecke im
;
;    ATARI-Magazin
;
;    Die Routine lÑuft natÅrlich
;    nur bei niedriger Auflîsung!
;
start:                ;
move.l #0,-(sp)       ;Supervisormodus
move.w #$20,-(sp)     ;einschalten
trap #1               ;
addq.l #6,sp          ;
                      ;
move.w #2,-(sp)       ;Open-File
move.l #file1,-(sp)   ;(Filename kann
move.w #$3d,-(sp)     ; geaendert
trap #1               ; werden; hier :
addq.l #8,sp          ; CHARS.PI1)
move.w d0,handle      ;
move.l #colours,-(sp) ;Read-File
move.l #34,-(sp)      ;Farben des 
move.w handle,-(sp)   ;Zeichensatzes
move.w #$3f,-(sp)     ;laden
trap #1               ;
add.l #12,sp          ;
move.l screen,-(sp)   ;Read-File
move.l #32000,-(sp)   ;Zeichensatz-
move.w handle,-(sp)   ;Grafik laden
move.w #$3f,-(sp)     ;
trap #1               ;
add.l #12,sp          ;
move.w handle,-(sp)   ;Close-File
move.w #$3e,-(sp)     ;
trap #1               ;
addq.l #4,sp          ;
                      ;Als naechstes
                      ;werden die
                      ;16*16 Zeichen
                      ;aus der Bitmap
                      ;in Tabelle1
                      ;kopiert.
move.l screen,a0      ;Start Bitmap
move.l #tabelle1,a1   ;Start Tabelle1
move.w #1,d0          ;2 Zeilen mit
maketab1:             ;jeweils
move.w #19,d1         ;20 Zeichen.
maketab2:             ;
move.w #15,d2         ;16 Zeilen pro
maketab3:             ;Zeichen.
move.l (a0)+,(a1)+    ;16 Pixel in
move.l (a0)+,(a1)+    ;Tabelle1
add.l #152,a0         ;naechste Zeile
addq.l #8,a1          ;In Tabelle1 
                      ;noch fuer 16
                      ;weitere Pixel
                      ;Platz schaffen,
                      ;damit die 
                      ;Zeichen spaeter
                      ;rotiert werden
                      ;koennen.
dbra d2,maketab3      ;
sub.l #2560-8,a0      ;Start des 
dbra d1,maketab2      ;naechsten Zeich.
add.l #2400,a0        ;Start der 
dbra d0,maketab1      ;naechsten Zeile
                      ;
                      ;Jetzt werden
                      ;die Zeichen aus
                      ;Tabelle1 um
                      ;2 bis 14 Pixel
                      ;verschoben.
move.l #tabelle2,a1   ;Start Tabelle2
move.w #2,d7          ;2 Pixel versch.
verschiebe1:          ;
move.l #tabelle1,a0   ;Start Tabelle1
move.w #5119,d6       ;5120 Words rot.
verschiebe2:          ;
moveq #0,d0           ;(wichtig!)
move.w (a0)+,d0       ;Original-Wort
ror.l d7,d0           ;Rotieren
or.w d0,(a1)+         ;mit OR in Tab.
swap d0               ;herausgesch.
move.w d0,6(a1)       ;Teil in nÑchstes
                      ;Wort derselben
                      ;Bitmap (8 Bytes
dbra d6,verschiebe2   ;spaeter)
addq.w #2,d7          ;2 Pixel mehr 
cmp.w #16,d7          ;rotieren. Schon
blt verschiebe1       ;fertig ? 
                      ;
                      ;Nun wird der
                      ;Text vom ASCII
                      ;Code in den
                      ;Scroll-Code
                      ;umgewandelt.
move.l #text,a0       ;Textbeginn
maketext:             ;
cmp.b #96,(a0)        ;Code grîûer 96?
blt nochar            ;
sub.b #96,(a0)+       ;Dann 96 abziehen
bra test              ;(Buchstabe)
nochar:               ;
cmp.b #48,(a0)        ;Code grîûer 48?
blt nodigit           ;
sub.b #21,(a0)+       ;Dann 21 abziehen
bra test              ;(Ziffer)
nodigit:              ;
move.b #0,(a0)+       ;Sonst gleich
test:                 ;null (Space)
cmp.l #textende,a0    ;Fertig?
blt maketext          ;
                      ;
move.w #2,-(sp)       ;Open-File
move.l #file2,-(sp)   ;File2 enthÑlt
move.w #$3d,-(sp)     ;irgendein
trap #1               ;beliebiges
addq.l #8,sp          ;Degas-Elite-Bild
move.w d0,handle      ;
move.l #colours2,-(sp);Farben laden
move.l #34,-(sp)      ;
move.w handle,-(sp)   ;
move.w #$3f,-(sp)     ;
trap #1               ;
add.l #12,sp          ;
move.l screen,-(sp)   ;Bitmap laden
move.l #32000,-(sp)   ;
move.w handle,-(sp)   ;
move.w #$3f,-(sp)     ;
trap #1               ;
add.l #12,sp          ;
move.w handle,-(sp)   ;Close-File
move.w #$3e,-(sp)     ;
trap #1               ;
addq.l #4,sp          ;
                      ;
move.b screen+1,$ff8201;Startadresse
move.b screen+2,$ff8203;der Bitmap in
                      ;den Videochip
and.b #$df,$fffa09    ;Timer C stoppen
and.b #$fe,$fffa07    ;Timer B stoppen
move.l #raster,$120   ;Pointer fuer
move.l #vbl,$70       ;die Interrupts
move.l #tastatur,$118 ;
or.b #1,$fffa07       ;Timer B kann
or.b #1,$fffa13       ;wieder starten
                      ;
ende: bra ende        ;Hauptprogramm
                      ;(tut nichts)
tastatur:             ;Tastatur-Irq
move.w #$2600,sr      ;darf nichts
rte                   ;verzoegern.
                      ;
vbl:                  ;50 Hz-Irq
move.b #0,$fffa1b     ;Timer B stoppen
move.b #199,$fffa21   ;Rasterinterrupt
                      ;in Zeile 199
move.b #8,$fffa1b     ;Timer B starten
move.l #colours2+2,a0 ;Farben des
move.l #$ff8240,a1    ;angezeigten
move.w #7,d0          ;Bildes in die
col1:                 ;Farbregister
move.l (a0)+,(a1)+    ;kopieren.
dbra d0,col1          ;
bsr scroll            ;Bildschirm neu
                      ;aufbauen.
subq.w #1,scrollphase ;nÑchste Phase
cmp.w #-1,scrollphase ;(2 Pixel weiter)
beq newchar           ;
rte                   ;
newchar:              ;
move.w #7,scrollphase ;nÑchstes Zeichen
addq.l #1,charpos     ;
cmp.l #textende,charpos;schon durch?
beq vonvorne          ;
rte                   ;
vonvorne:             ;Dann wieder 
move.l #text,charpos  ;von vorne.
rte                   ;
                      ;
scroll:               ;Bildschirmaufbau
move.l screen,a1      ;Start Bitmap
add.l #33600,a1       ;plus 33600
                      ;(Laufschrift ab
                      ;Zeile 210)
move.l #tabelle1,a0   ;Startadresse
move.w scrollphase,d0 ;der benîtigten
mulu #10240,d0        ;Tabelle berech-
add.l d0,a0           ;nen.
move.l charpos,a2     ;Startadresse des
                      ;Textes
subq.l #1,a2          ;Rest vom
                      ;vorherigen Z.
moveq #0,d2           ;Startadresse
move.b (a2)+,d2       ;des Zeichens
lsl.w #8,d2           ;berechnen
move.l a0,a3          ;
add.w d2,a3           ;
move.w #15,d1         ;16 Zeilen
scroll0:              ;
addq.l #8,a3          ;nur die letzen
move.l (a3)+,(a1)+    ;Pixel (2.Wort)
move.l (a3)+,(a1)+    ;kopieren
add.l #152,a1         ;nÑchste Zeile
dbra d1,scroll0       ;
sub.l #2560,a1        ;wieder zum Start
                      ;
weiter:               ;insgesamt 9 mal
move.w #8,d0          ;2 Zeichen kop.
scroll1:              ;
moveq #0,d2           ;Startadresse
move.b (a2)+,d2       ;des 1. Zeichens
lsl.w #8,d2           ;in a3
move.l a0,a3          ;
add.w d2,a3           ;
moveq #0,d2           ;Startadresse 
move.b (a2)+,d2       ;des 2. Zeichens
lsl.w #8,d2           ;in a4
move.l a0,a4          ;
add.w d2,a4           ;
move.w #15,d1         ;16 Zeilen
scroll2:              ;
move.l (a3)+,d2       ;erste 16 Pixel
move.l (a3)+,d3       ;mit dem Rest aus
or.l d2,(a1)+         ;vorherigem Zei-
or.l d3,(a1)+         ;chen verknÅpfen
move.l (a3)+,d2       ;zweite 16 Pixel
move.l (a3)+,d3       ;des 1. Zeichens
or.l (a4)+,d2         ;mit ersten 16
or.l (a4)+,d3         ;Pix. des 2. Zei-
move.l d2,(a1)+       ;chens verknÅpfen
move.l d3,(a1)+       ;
move.l (a4)+,(a1)+    ;zweite 16 Pixel
move.l (a4)+,(a1)+    ;des 2.Zeichens
add.l #136,a1         ;nÑchste Zeile
dbra d1,scroll2       ;
sub.l #2560-16,a1     ;nÑchste 2 
dbra d0,scroll1       ;Zeichen.
                      ;
moveq #0,d2           ;Startadresse
move.b (a2)+,d2       ;1. Zeichen
lsl.w #8,d2           ;in a3
move.l a0,a3          ;
add.w d2,a3           ;
moveq #0,d2           ;Startadresse
move.b (a2)+,d2       ;2.Zeichen
lsl.w #8,d2           ;in a4
move.l a0,a4          ;
add.w d2,a4           ;
move.w #15,d1         ;
scroll4:              ;
move.l (a3)+,d2       ;s.o.
move.l (a3)+,d3       ;
or.l d2,(a1)+         ;
or.l d3,(a1)+         ;
move.l (a3)+,d2       ;
move.l (a3)+,d3       ;
or.l (a4)+,d2         ;
or.l (a4)+,d3         ;
move.l d2,(a1)+       ;
move.l d3,(a1)+       ;
addq.l #8,a4          ;allerdings die
                      ;2. 16 Pixel des
                      ;2. Zeichens
                      ;nicht mehr 
add.l #144,a1         ;kopieren, da
dbra d1,scroll4       ;Zeilenende
endscroll:            ;erreicht!
rts                   ;
                      ;
                      ;
raster:               ;Rasterinterrupt
clr.b $fffa1b         ;Timer B stoppen
movem.l d0/a0,-(sp)   ;d0+a0 retten
move.w #$fffa21,a0    ;
move.b #39,(a0)       ;nÑchsten Raster-
                      ;irq in 39 Zeilen
move.b #8,$fffa1b     ;Timer B starten
move.b (a0),d0        ;Auf Ende der
waitend:              ;Rasterzeile
cmp.b (a0),d0         ;warten.
beq waitend           ;
clr.b $fff820a        ;kurz auf 60 HZ
moveq #3,d0           ;umschalten
nops:                 ;einige Takte
nop                   ;lang warten.
dbra d0,nops          ;
move.b #2,$fff820a    ;wieder auf 50Hz
                      ;schalten.
move.l #colours+2,a0  ;Farben des
move.l #$ff8240,a1    ;Zeichensatzes
move.w #7,d0          ;in Farbregister
col2:                 ;kopieren.
move.l (a0)+,(a1)+    ;
dbra d0,col2          ;
move.l #raster2,$120  ;Pointer auf 2.
                      ;Raster-Irq.
movem.l (sp)+,d0/a0   ;d0+a0 holen
bclr#0,$fffa0f        ;Irq freigeben
rte                   ;
                      ;
raster2:              ;Rasterinterrupt
clr.b $fffa1b         ;Timer B stoppen
move.b #200,$fffa21   ;nÑchsten in
                      ;200 Zeilen (nie)
move.b #8,$fffa1b     ;Timer B starten
move.l #raster,$120   ;Pointer auf Irq1
bclr#0,$fffa0f        ;Irq freigeben
move.l #$ff8240,a0    ;Alle Farben
move.w #7,d0          ;auf schwarz
schwarz:              ;setzen
move.l #0,(a0)+       ;(passiert in
dbra d0,schwarz       ; Zeile 240)
rte                   ;
                      ;Hier kann ihr
                      ;eigener Text
                      ;stehen (LÑnge
                      ;beliebig)
                      ;Achtung: keine
                      ;Grossbuchstaben!
text:blk.b22,0        ;
dc.b"copyright 1989 by christian rduch"
dc.b" fuer die st assemblerecke im"
dc.b" atari-magazin              "
dc.b"vielen dank an  the exceptions"
dc.b" eure routine war sicherer als "
dc.b"meine                       "
dc.b"dafuer benoetigt diese lauf"
dc.b"schrift weniger rechenzeit "
textende:blk.b22,0    ;
even                  ;
charpos:dc.ltext      ;
scrollphase:dc.w0     ;
colours:blk.b34,0     ;
colours2:blk.b34,0    ;
screen:dc.lscreen0    ;
file1:dc.b"chars.pi1",0;(zeichensatz)
even                  ;
file2:dc.b"dino.pi1",0;(beliebiges 
even                  ;Bild)
handle:dc.w0          ;
tabelle1:             ;(Tabellen)
blk.b10240,0          ;nicht verschoben
tabelle2:             ;
blk.b10240,0          ;2 Pixel versch.
tabelle3:             ;
blk.b10240,0          ;4 Pixel versch.
tabelle4:             ;
blk.b10240,0          ;...
tabelle5:             ;
blk.b10240,0          ;
tabelle6:             ;
blk.b10240,0          ;
tabelle7:             ;
blk.b10240,0          ;
tabelle8:             ;
blk.b10240,0          ;
                      ;
org$70000             ;Start des
screen0:              ;Bildschirms.
