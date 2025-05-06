            text
gemdos      equ      1
xbios       equ      14

init:       move.w   #2,-(sp)
            trap     #xbios               ;Bildschirmstartadresse holen
            addq.l   #2,sp
            move.l   d0,screenbase        ;Adresse merken

            move.w   #1,d0                ;X-Koordinate
            move.w   #17,d1               ;Y-Koordinate
            bsr      draw_graph

            move.w   #7,-(sp)
            trap     #gemdos              ;Warten auf Tastendruck
            addq.l   #2,sp

            clr.w    -(sp)                ;Term
            trap     #gemdos

draw_graph: move.l   screenbase,a0
            mulu.w   #80,d1               ;Startadresse berechnen
            add.w    d1,a0
            add.w    d0,a0                ;Startadresse in A0

            lea.l    daten,a1             ;Startadresse Daten holen
            move.w   #31,d0               ;32 Zeilen
scline:     move.w   #3,d1                ;4 Bytes pro Zeile
loop:       move.b   (a1)+,(a0)+          ;auf Bildschirm ausgeben
            dbra     d1,loop              ;naechstes Byte
            add.l    #76,a0               ;naechste Zeile
            dbra     d0,scline
            rts

            data
daten:
            dc.w     $0000,$0000,$0000,$0000,$FFFF,$FFFE,$8000,$0003
            dc.w     $BFFF,$FFF3,$A400,$011B,$A403,$015B,$A5E7,$9D5B
            dc.w     $A40C,$C15B,$A40C,$C11B,$A5EF,$DD1B,$A40C,$C11B
            dc.w     $A40C,$C11B,$A5EC,$DD1B,$A400,$011B,$A400,$011B
            dc.w     $A3FF,$FE1B,$A000,$001B,$A000,$001B,$A1FF,$FF1B
            dc.w     $A1FF,$F09B,$A187,$F09B,$A187,$F09B,$A187,$F09B
            dc.w     $A187,$F09B,$A187,$F09B,$9187,$F09B,$8987,$F09B
            dc.w     $85FF,$F09B,$83FF,$FFFB,$8000,$0003,$FFFF,$FFFF

            bss
screenbase: ds.l     1
            end

