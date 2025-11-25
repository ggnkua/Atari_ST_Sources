;in A4_GRAF benutzte Assembler-Unterroutinen:
;Programmautor: JÅrgen Luers (Copyright 1990)
;diese Routinen leisten die Komprimierung und Dekomprimierung
;in bzw. von '.IMG'-Dateien in monochromer Darstellung
;so mÅssen Sie diese Routinen nicht selbst schreiben

                >PART 'img_bild'
;***************************************************
;* IMG-Dekomprimierung:   (c) 1990 by JÅrgen Luers *
;***************************************************
;Dekomprimiert IMG-File in Zielbild und gibt Fehlercode zurÅck

;GFA-BASIC-Syntax:
;=================
;error%=C:img_bild%(L:load_adr%,L:pic_adr%,W:rb&,W:rh&)

;Assembler-Syntax:
;=================
;move.w rh,-(sp)       <=> Rasterhîhe des Zielbildschirmes in Pixel
;move.w rb,-(sp)       <=> Rasterbreite des Zielbildschirmes in Pixel
;move.l pic_adr,-(sp)  <=> Adr. des Zielbildschirmes
;move.l load_adr,-(sp) <=> Adr. des IMG-Files (Adr. des IMG-Kopfes)
;bsr    img_bild       <=> Sprung zur Routine
;adda.w #12,SP         <=> Stack korrigieren
;in D0.L <=> RÅckgabe des Fehlercodes
;             0, falls kein Fehler
;            -1, falls kein IMG
;            -2, falls nicht monochrom
;            -3, falls Bild zu breit oder zu hoch

;Quellbild- und IMG-Bereich dÅrfen sich Åberlagern. Der IMG-Bereich
;wird von vorne nach hinten bearbeitet. Deûhalb muû bei einer öber-
;lagerung beider Bereiche der IMG-Bereich die hîhere Adr. erhalten.
;fÅr die Adressen muû bei öberlagerung gelten:
;  !!!!!  end_adr-pic_adr > rb/8*rh+rh*2+16+3+rb/8  !!!!!!!
;wobei end_adr die Adr. des vom IMG letzten benutzten Bytes ist.
;Beispiel: 640x400 Punkte Bild ==> end_adr-pic_adr > 32899

img_bild:       movem.l D1-A6,-(SP)     ;Register sichern
;A2/D1 frei fÅr kurze Zwischenrechnungen etc.
                movea.l 4+14*4(SP),A0   ;Adr. IMG-Kopf
                movea.l 8+14*4(SP),A1   ;Adr. Zielbildschirm
                clr.l   D7
                move.w  12+14*4(SP),D7
                lsr.w   #3,D7
                clr.l   D3
                move.w  14+14*4(SP),D3
                clr.l   D0
                clr.l   D1
                move.b  12(A0),D1
                lsl.w   #8,D1
                move.b  13(A0),D1
                tst.w   D1
                bgt.s   img_bild01
                move.l  #-1,D0
                bra     img_bild55
img_bild01:     divu    #8,D1
                swap    D1
                tst.w   D1
                beq.s   img_bild02
                swap    D1
                addq.w  #1,D1
                bra.s   img_bild03
img_bild02:     swap    D1
img_bild03:     lea     img_bild56(PC),A2
                move.w  D1,(A2)
                cmp.w   D7,D1
                ble.s   img_bild04
                move.l  #-3,D0
                bra     img_bild55
img_bild04:     clr.l   D1
                move.b  14(A0),D1
                lsl.w   #8,D1
                move.b  15(A0),D1
                tst.w   D1
                bgt.s   img_bild05
                move.l  #-1,D0
                bra     img_bild55
img_bild05:     cmp.w   D3,D1
                ble.s   img_bild06
                move.l  #-3,D0
                bra     img_bild55
img_bild06:     move.w  D1,D3
                lea     img_bild57(PC),A2
                move.w  D3,(A2)
                clr.l   D1
                move.b  6(A0),D1
                lsl.w   #8,D1
                move.b  7(A0),D1
                tst.w   D1
                bgt.s   img_bild07
                move.l  #-1,D0
                bra     img_bild55
img_bild07:     clr.l   D3
                move.w  D1,D3
                clr.l   D1
                move.b  4(A0),D1
                lsl.w   #8,D1
                move.b  5(A0),D1
                cmpi.w  #1,D1
                beq.s   img_bild08
                move.l  #-2,D0
                bra     img_bild55
img_bild08:     clr.l   D1
                move.b  2(A0),D1
                lsl.w   #8,D1
                move.b  3(A0),D1
                cmpi.w  #8,D1
                bge.s   img_bild09
                move.l  #-1,D0
                bra     img_bild55
img_bild09:     lsl.l   #1,D1
                adda.l  D1,A0
                lea     img_bild58(PC),A2
                move.l  D0,(A2)
img_bild10:     suba.l  A5,A5
img_bild11:
                suba.l  A6,A6
                clr.l   D4
img_bild12:     tst.b   (A0)
                bne.s   img_bild13
                tst.b   1(A0)
                bne.s   img_bild13
                cmpi.b  #$FF,2(A0)
                bne.s   img_bild13
                move.b  3(A0),D4
                addq.l  #4,A0
                bra.s   img_bild14
img_bild13:     move.b  #1,D4
img_bild14:     move.w  D4,D1
                mulu    D7,D1
                movea.l D1,A3
                adda.l  A1,A3
                subq.w  #1,D4
img_bild15:     cmpa.w  img_bild57(PC),A5
                bge     img_bild53
                cmpa.w  img_bild56(PC),A6
                bge     img_bild53
img_bild16:     cmpi.b  #$80,(A0)
                bne.s   img_bild24
                addq.l  #1,A0
                clr.l   D6
                move.b  (A0)+,D6
                adda.w  D6,A6
img_bild17:     tst.w   D4
                bne.s   img_bild19
                movea.l A1,A2
                move.w  D6,D1
                move.l  A0,-(SP)
img_bild18:     move.b  (A0)+,(A2)+
                subq.w  #1,D1
                bgt.s   img_bild18
                movea.l (SP)+,A0
                bra.s   img_bild23
img_bild19:     move.w  D4,D1
                muls    D7,D1
                movea.l D1,A4
img_bild20:     movea.l A4,A2
                adda.l  A1,A2
                move.w  D6,D1
                move.l  A0,-(SP)
img_bild21:     move.b  (A0)+,(A2)+
                subq.w  #1,D1
                bgt.s   img_bild21
                movea.l (SP)+,A0
                suba.l  D7,A4
img_bild22:     move.l  A4,D1
                bpl.s   img_bild20
img_bild23:     ext.l   D6
                adda.l  D6,A1
                adda.l  D6,A0
                bra     img_bild52
img_bild24:     tst.b   (A0)
                bne.s   img_bild36
                addq.l  #1,A0
                clr.l   D6
                move.b  (A0)+,D6
                move.w  D6,D1
                lsl.w   #1,D1
                adda.w  D1,A6
img_bild25:
img_bild26:     tst.w   D4
                bne.s   img_bild28
                movea.l A1,A2
                move.w  D3,D1
                move.l  A0,-(SP)
img_bild27:     move.b  (A0)+,(A2)+
                subq.w  #1,D1
                bgt.s   img_bild27
                movea.l (SP)+,A0
                bra.s   img_bild32
img_bild28:     move.w  D7,D1
                muls    D4,D1
                movea.l D1,A4
img_bild29:     movea.l A4,A2
                adda.l  A1,A2
                move.w  D3,D1
                move.l  A0,-(SP)
img_bild30:     move.b  (A0)+,(A2)+
                subq.w  #1,D1
                bgt.s   img_bild30
                movea.l (SP)+,A0
                suba.l  D7,A4
img_bild31:     move.l  A4,D1
                bpl.s   img_bild29
img_bild32:     adda.l  D3,A1
                subq.w  #1,D6
img_bild33:     bgt.s   img_bild25
img_bild34:     tst.w   D6
                bge.s   img_bild35
                lea     img_bild58(PC),A2
                move.l  #-1,(A2)
                movea.w img_bild57(PC),A5
img_bild35:     adda.l  D3,A0
                bra.s   img_bild52
img_bild36:     clr.l   D5
                move.b  (A0)+,D5
                move.l  D5,D2
                andi.b  #$80,D2
                move.l  D5,D6
                andi.b  #$7F,D6
                adda.w  D6,A6
img_bild37:     tst.w   D4
                bne.s   img_bild43
img_bild38:     tst.b   D2
                beq.s   img_bild40
                movea.l A1,A2
                movem.l D6-D7,-(SP)
                move.b  #$FF,D7
img_bild39:     move.b  D7,(A2)+
                subq.w  #1,D6
                bgt.s   img_bild39
                movem.l (SP)+,D6-D7
                bra.s   img_bild42
img_bild40:     movea.l A1,A2
                move.l  D6,-(SP)
img_bild41:     clr.b   (A2)+
                subq.w  #1,D6
                bgt.s   img_bild41
                move.l  (SP)+,D6
img_bild42:     bra.s   img_bild51
img_bild43:     move.w  D7,D1
                muls    D4,D1
                movea.l D1,A4
img_bild44:
img_bild45:     tst.b   D2
                beq.s   img_bild47
                movea.l A4,A2
                adda.l  A1,A2
                movem.l D6-D7,-(SP)
                move.b  #$FF,D7
img_bild46:     move.b  D7,(A2)+
                subq.w  #1,D6
                bgt.s   img_bild46
                movem.l (SP)+,D6-D7
                bra.s   img_bild49
img_bild47:     movea.l A4,A2
                adda.l  A1,A2
                move.l  D6,-(SP)
img_bild48:     clr.b   (A2)+
                subq.w  #1,D6
                bgt.s   img_bild48
                move.l  (SP)+,D6
img_bild49:     suba.l  D7,A4
img_bild50:     move.l  A4,D1
                bpl.s   img_bild44
img_bild51:     ext.l   D6
                adda.l  D6,A1
img_bild52:     bra     img_bild15
img_bild53:     movea.l A3,A1
                addq.w  #1,A5
                adda.w  D4,A5
img_bild54:     cmpa.w  img_bild57(PC),A5
                blt     img_bild11
                clr.l   D0
                move.l  img_bild58(PC),D0
img_bild55:     movem.l (SP)+,D1-A6
                rts

img_bild56:     DS.W 1
img_bild57:     DS.W 1
img_bild58:     DS.L 1
                ENDPART

                >PART 'bild_img'
;************************************************
;* IMG-Komprimierung:  (c) 1990 by JÅrgen Luers *
;************************************************
;Komprimiert Bild in IMG-Format und gibt Anfangsadr. des IMG zurÅck

;GFA-BASIC-Aufruf:
;=================
;img_adr%=C:bild_img%(L:pic_adr%,W:rb&,W:bb&,W:rh&,L:end_adr%)

;Assembler-Aufruf:
;=================
;move.l end_adr,-(SP) <=> Endadr. d. IMG (Adr. des ersten nicht-benutzten Bytes)
;move.w rh,-(SP)      <=> Hîhe des Quellbildes in Pixel
;move.w bb,-(SP)      <=> Breite des Quellbildes in Pixel
;move.w rb,-(SP)      <=> Rasterbreite des Quellbildes in Pixel
;move.l pic_adr,-(SP) <=> Adr. des zu komprimierenden Quellbildes
;bsr    bild_img      <=> Aufruf der Routine
;adda.w #14,SP        <=> Stack-Korrektur
;D0.L   <=> RÅckgabe der Anfangsadr. des IMG (Adr. des ersten benutzten Bytes)
;Bem.: falls Fehler auftritt wird #-1 zurÅck gegeben

;Quellbild- und IMG-Bereich dÅrfen sich Åberlagern. Der IMG-Bereich
;wird von hîheren zu tieferen Adressen verÑndert. Deûhalb muû bei einer
;öberlagerung beider Bereiche der IMG-Bereich die hîhere Adr. erhalten.
;fÅr die Adressen muû bei öberlagerung gelten:
;  !!!!!  end_adr-pic_adr > rb/8*rh+rh*2+16+3+rb/8  !!!!!!!
;Beispiel: 640x400 Punkte Bild ==> end_adr-pic_adr > 32899

bild_img:       movem.l D1-A6,-(SP)     ;Register sichern
                move.l  #-1,D0          ;Fehler aufgetreten als Default
                movea.l 4+14*4(SP),A6   ;Quellbildadr.
                clr.l   D1
                move.w  8+14*4(SP),D1   ;Rasterbreite...
                lsr.w   #3,D1           ;...in Bytes umrechnen
                lea     bild_img64(PC),A2
                move.w  D1,(A2)         ;und merken
                clr.l   D2
                move.w  10+14*4(SP),D2  ;Bildbreite...
                tst.w   D2
                ble     bild_img63
                lea     bild_img65(PC),A2 ;und merken
                move.w  D2,(A2)
                divu    #8,D2           ;...in Bytes umrechnen...
                swap    D2              ;Rest unten in Register
                tst.w   D2              ;Rest vorhanden ?
                beq.s   bild_img01      ;Sprung, falls nein !
                swap    D2
                addq.w  #1,D2
                bra.s   bild_img02
bild_img01:     swap    D2
bild_img02:     suba.l  A5,A5
                movea.w D2,A5           ;Bildbreite in Bytes ok
                clr.l   D2
                move.w  12+14*4(SP),D2  ;Bildhîhe...
                lea     bild_img66(PC),A2 ;und merken...
                move.w  D2,(A2)
                subq.w  #1,D2           ;prÅfen und in Offset wandeln
                blt     bild_img63
                mulu    D1,D2           ;Offset fÅr letzte Bildzeile
                lea     0(A6,D2.l),A0   ;Zeiger auf letzte Bildzeile
                movea.l 14+14*4(SP),A1  ;IMG-Endadr.
bild_img03:     cmpa.l  A6,A0           ;Bildanfang Åberschritten ?
                blt     bild_img62      ;Sprung, falls ja !
                clr.w   D4              ;ZeilenwiederholungszÑhler
                movea.l A0,A4           ;Adr. der akt. Zeile
                move.w  A5,D3           ;Bildbreite zum Vergleich in D3
                move.w  bild_img64(PC),D0 ;Rasterbreite in D0
bild_img04:     cmpi.w  #$FF,D4         ;max. Zeilenwiederholung erreicht ?
                bge.s   bild_img08      ;Sprung, falls ja !
                cmpa.l  A6,A0           ;Bildanfang Åberschritten ?
                blt.s   bild_img08      ;Sprung, falls ja !
                suba.w  D0,A0           ;nÑchste Bildzeile
                addq.w  #1,D4           ;mitzÑhlen
                clr.w   D7              ;SchleifenzÑhler zum Zeilenvergleich
                move.l  A0,D1           ;1. Adr. merken
                move.l  A4,D2           ;2. Adr. merken
bild_img05:     cmpm.b  (A0)+,(A4)+     ;Byte vergleichen
                bne.s   bild_img07      ;Sprung aus Schleifen, falls ungleich
                addq.w  #1,D7           ;Byte zÑhlen
bild_img06:     cmp.w   D3,D7           ;Zeilenende erreicht ?
                ble.s   bild_img05      ;Sprung, falls nein !
                movea.l D1,A0           ;1. Adr. restaurieren
                movea.l D2,A4           ;2. Adr. restaurieren
                bra.s   bild_img04      ;Sprung an Schleifenanfang
bild_img07:     movea.l D1,A0           ;1. Adr. restaurieren
                movea.l D2,A4           ;2. Adr. restaurieren
bild_img08:     move.w  D3,D6           ;(D3 noch Bildbreite!)
                subq.w  #1,D6           ;Bildbreite-1 (horiz. Offset auf Byte)
                clr.w   D0              ;ZÑhler fÅr Wiederholung leerer Bytes
                clr.w   D1              ;ZÑhler fÅr Wiederholung voller Bytes
                clr.w   D2              ;ZÑhler fÅr Musterwiederholung
                clr.w   D3              ;ZÑhler fÅr nicht-komprimierbare Bytes
                clr.w   D5              ;'Wiederholung gefunden' = FALSE
bild_img09:     tst.w   D6              ;Zeilenanfang erreicht ?
                blt     bild_img55      ;Sprung, falls ja !
bild_img10:     tst.w   D5              ;Wiederholung schon gefunden ?
                bne.s   bild_img16      ;Sprung, falls ja !
                clr.w   D0              ;'leere Bytes'-ZÑhler auf Null
                lea     0(A4,D6.w),A2   ;A2%=A4%+D6& (Zeiger auf akt. Byte)
bild_img11:     cmpi.w  #127,D0         ;max. Byte-Wiederholung erreicht ?
                bge.s   bild_img12      ;Sprung, falls ja !
                tst.w   D6              ;Zeilenanfang erreicht ?
                blt.s   bild_img12      ;Sprung, falls ja !
                tst.b   (A2)            ;leeres Byte ?
                bne.s   bild_img12      ;Sprung, falls nein !
                subq.w  #1,D6           ;Offset auf nÑchstes Byte
                subq.l  #1,A2           ;Zeiger ebenso
                addq.w  #1,D0           ;leeres Byte zÑhlen
                bra.s   bild_img11      ;Schleife fortsetzen
bild_img12:
bild_img13:     cmpi.w  #1,D0           ;Wiederholung gefunden ?
                ble.s   bild_img14      ;Sprung, falls nein !
                move.w  #-1,D5          ;'Wiederholung gefunden' = TRUE
                bra.s   bild_img15      ;weiter
bild_img14:     add.w   D0,D6           ;Offset wieder auf akt. Byte
bild_img15:
bild_img16:
bild_img17:     tst.w   D5              ;Wiederholung schon gefunden ?
                bne.s   bild_img23      ;Sprung, falls ja !
                clr.w   D1              ;'volle Bytes'-ZÑhler auf Null
                lea     0(A4,D6.w),A2   ;A2%=A4%+D6& (Zeiger auf akt. Byte)
bild_img18:     cmpi.w  #127,D1         ;max. Byte-Wiederholung erreicht ?
                bge.s   bild_img19      ;Sprung, falls ja !
                tst.w   D6              ;Zeilenanfang erreicht ?
                blt.s   bild_img19      ;Sprung, falls ja !
                cmpi.b  #$FF,(A2)       ;volles Byte ?
                bne.s   bild_img19      ;Sprung, falls nein !
                subq.w  #1,D6           ;Offset auf nÑchstes Byte
                subq.l  #1,A2           ;Zeiger ebenso
                addq.w  #1,D1           ;leeres Byte zÑhlen
                bra.s   bild_img18      ;Schleife fortsetzen
bild_img19:
bild_img20:     cmpi.w  #1,D1           ;Wiederholung gefunden ?
                ble.s   bild_img21      ;Sprung, falls nein !
                move.w  #-1,D5          ;'Wiederholung gefunden' = TRUE
                bra.s   bild_img22      ;weiter
bild_img21:     add.w   D1,D6           ;Offset wieder auf akt. Byte
bild_img22:
bild_img23:
bild_img24:     tst.w   D5              ;Wiederholung schon gefunden ?
                bne.s   bild_img31      ;Sprung, falls ja !
                clr.w   D2              ;Muster-ZÑhler auf Null
                subq.w  #1,D6           ;Zeiger auf nÑchstes Byte
                lea     0(A4,D6.w),A2   ;A2%=A4%+D6& (Zeiger auf akt. 2 Bytes)
                move.b  (A2),D7         ;Muster lesen...
                lsl.w   #8,D7
                move.b  1(A2),D7
                movea.w D7,A3           ;Muster merken
bild_img25:     cmpi.w  #255,D2         ;max. Muster-Wiederholung erreicht ?
                bge.s   bild_img27      ;Sprung, falls ja !
                tst.w   D6              ;Zeilenanfang erreicht ?
                blt.s   bild_img27      ;Sprung, falls ja !
                subq.w  #2,D6           ;nÑchsten 2 Bytes
                subq.l  #2,A2           ;Zeiger ebenso
                move.b  (A2),D7         ;Muster lesen...
                lsl.w   #8,D7
                move.b  1(A2),D7
                addq.w  #1,D2           ;Muster zÑhlen
bild_img26:     cmpa.w  D7,A3           ;Muster gleich ?
                beq.s   bild_img25      ;Sprung, falls ja !
bild_img27:     addq.w  #1,D6           ;Offset auf akt. Byte korrigieren
bild_img28:     cmpi.w  #1,D2           ;Wiederholung gefunden ?
                ble.s   bild_img29      ;Sprung, falls nein !
                move.w  #-1,D5          ;'Wiederholung gefunden' = TRUE
                bra.s   bild_img30      ;weiter
bild_img29:     move.w  D2,D7           ;WiederholungszÑhler*2 ...
                lsl.w   #1,D7
                add.w   D7,D6           ;Offset wieder auf akt. Byte
bild_img30:
bild_img31:
bild_img32:     tst.w   D5              ;Wiederholung gefunden ?
                bne.s   bild_img37      ;Sprung, falls ja !
                subq.w  #1,D6           ;nicht-komprimierbares Byte Åberspringen
                addq.w  #1,D3           ;nicht-komprimierbares Byte zÑhlen
bild_img33:     cmpi.w  #254,D3         ;max. mîgliche Anzahl erreicht ?
                ble.s   bild_img36      ;Sprung, falls nein !
                suba.w  D3,A1
                lea     0(A4,D6.w),A2   ;A2%=A4%+D6&
;bmove(A2.L,A1.L,D3.W)
                move.w  D3,D7
                beq.s   bild_img35
                movem.l A1-A2,-(SP)
bild_img34:     move.b  (A2)+,(A1)+
                subq.w  #1,D7
                bgt.s   bild_img34
                movem.l (SP)+,A1-A2
bild_img35:     move.b  D3,-(A1)
                move.b  #128,-(A1)
                clr.w   D3
bild_img36:     bra     bild_img54
bild_img37:
bild_img38:     tst.w   D3              ;nicht-komprimierbare Bytes vorhanden ?
                beq.s   bild_img49      ;Sprung, falls nein !
                lea     1(A4,D6.w),A2   ;A2%=A4%+D6&+1 (Quelladr. berechnen)
bild_img39:     cmpi.w  #1,D2           ;Musterwiederholungen vorhanden ?
                ble.s   bild_img42      ;Sprung, falls nein !
                suba.w  D3,A1
                move.w  D2,D7
                lsl.w   #1,D7
                lea     0(A2,D7.w),A2   ;ADD A2%,D7&
;bmove(A2.L,A1.L,D3.W)
                move.w  D3,D7
                beq.s   bild_img41
                movem.l A1-A2,-(SP)
bild_img40:     move.b  (A2)+,(A1)+
                subq.w  #1,D7
                bgt.s   bild_img40
                movem.l (SP)+,A1-A2
bild_img41:     move.b  D3,-(A1)
                move.b  #128,-(A1)
                bra.s   bild_img48
bild_img42:     cmpi.w  #1,D0           ;'leere Byte'-Wiederholungen vorhanden
                ble.s   bild_img45      ;Sprung, falls nein !
                suba.w  D3,A1
                lea     0(A2,D0.w),A2   ;ADD A2%,D0&
;bmove(A2.L,A1.L,D3.W)
                move.w  D3,D7
                beq.s   bild_img44
                movem.l A1-A2,-(SP)
bild_img43:     move.b  (A2)+,(A1)+
                subq.w  #1,D7
                bgt.s   bild_img43
                movem.l (SP)+,A1-A2
bild_img44:     move.b  D3,-(A1)
                move.b  #128,-(A1)
                bra.s   bild_img48
bild_img45:     cmpi.w  #1,D1           ;'volle Byte'-Wiederholungen vorhanden
                ble.s   bild_img48      ;Sprung, falls nein !
                suba.w  D3,A1
                lea     0(A2,D1.w),A2   ;ADD A2%,D1&
;bmove(A2.L,A1.L,D3.W)
                move.w  D3,D7
                beq.s   bild_img47
                movem.l A1-A2,-(SP)
bild_img46:     move.b  (A2)+,(A1)+
                subq.w  #1,D7
                bgt.s   bild_img46
                movem.l (SP)+,A1-A2
bild_img47:     move.b  D3,-(A1)
                move.b  #128,-(A1)
bild_img48:     clr.w   D3
bild_img49:
bild_img50:     cmpi.w  #1,D0           ;'leere Byte'-Wiederholungen eintragen ?
                ble.s   bild_img51      ;Sprung, falls nein !
                move.b  D0,-(A1)
                bra.s   bild_img53
bild_img51:     cmpi.w  #1,D1           ;'volle Byte'-Wiederholungen eintragen ?
                ble.s   bild_img52      ;Sprung, falls nein !
                move.w  D1,D7
                addi.w  #128,D7
                move.b  D7,-(A1)
                bra.s   bild_img53
bild_img52:     cmpi.w  #1,D2           ;Musterwiederholungen eintragen ?
                ble.s   bild_img53      ;Sprung, falls nein !
                move.w  A3,D7
                move.b  D7,-(A1)
                lsr.w   #8,D7
                move.b  D7,-(A1)
                move.b  D2,-(A1)
                clr.b   -(A1)
bild_img53:     clr.w   D5              ;'Wiederholung' = FALSE
bild_img54:
                bra     bild_img09
bild_img55:
bild_img56:     tst.w   D3              ;nicht-komprimierte Bytes eintragen ?
                beq.s   bild_img59      ;Sprung, falls nein !
                suba.w  D3,A1
;bmove(A4.L,A1.L,D3.W)
                move.w  D3,D7
                beq.s   bild_img58
                movem.l A1/A4,-(SP)
bild_img57:     move.b  (A4)+,(A1)+
                subq.w  #1,D7
                bgt.s   bild_img57
                movem.l (SP)+,A1/A4
bild_img58:     move.b  D3,-(A1)
                move.b  #128,-(A1)
                clr.w   D3
bild_img59:
bild_img60:     cmpi.w  #1,D4           ;Zeilenwiederholungeintragen ?
                ble.s   bild_img61
                move.b  D4,-(A1)
                move.b  #255,-(A1)
                clr.b   -(A1)
                clr.b   -(A1)
bild_img61:
                bra     bild_img03
bild_img62:     move.b  bild_img66+1(PC),-(A1) ;Bildhîhe eintragen...
                move.b  bild_img66(PC),-(A1)
                move.b  bild_img65+1(PC),-(A1) ;Bildbreite eintragen...
                move.b  bild_img65(PC),-(A1)
                move.b  #141,-(A1)      ;Pixelhîhe in um eintragen...
                clr.b   -(A1)
                move.b  #141,-(A1)      ;Pixelbreite in um eintragen...
                clr.b   -(A1)
                move.b  #2,-(A1)        ;MusterlÑnge eintragen...
                clr.b   -(A1)
                move.b  #1,-(A1)        ;Planeanzahl eintragen...
                clr.b   -(A1)
                move.b  #8,-(A1)        ;KopflÑnge in Worten eintragen...
                clr.b   -(A1)
                clr.b   -(A1)           ;Versionsnummer eintragen...
                clr.b   -(A1)
                move.l  A1,D0           ;IMG-Adr. zur RÅckgabe
bild_img63:     movem.l (SP)+,D1-A6
                rts
bild_img64:     DS.W 1          ;Quell-Rasterbreite in Bytes
bild_img65:     DS.W 1          ;Quell-Bildbreite in Pixel
bild_img66:     DS.W 1          ;Quell-Bildhîhe in Pixel
                ENDPART

