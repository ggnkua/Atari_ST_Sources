txtwahl      bsr fenfrei
             bne.s twret
             bsr auswahl
             bne.s twret
             cmp.l sel,d1
             beq.s twret              ;aktueller Text wurde gewÑhlt
             moveq #1,d0
             lea wiop+4,a0
tw0          cmp.l (a0)+,d1
             beq.s tw
             addq #1,d0
             cmp #5,d0
             beq.s tw2
             bra.s tw0
tw           move d0,wiarb          ;Text ist bereits in Fenster
             add d0,d0
             lea wihand,a0
             move (a0,d0.l),akthand
             bsr topped
             bra.s twret
tw2          bsr txtcl
             bsr txtopn
             bsr docopn
             btst #6,flag
             beq.s twret
             move.l sel,d0
             cmp.l blsel,d0
             bne.s twret
             bra ble3
twret        rts

txtlay       bsr neuformat
             bra verposit

txtpic       lea filesel+21,a1
             moveq #8,d6
             lea name+480,a5
             bsr diskopen           ;Namen holen
             bne.s twret
             lea nograf,a2
             bsr suchfile           ;auf Disk ?
             bne.s twret
             bsr openin             ;laden
             bne.s twret
             move.l bytes,d0
             add.l rest,d0
             add.l #1024,d0
             cmp.l free,d0
             bge txpfull0           ;zu wenig Speicher
             move.l diskpuff,a0
             move 4(a0),d0
             eori #3,d0
             cmp rez,d0
             beq.s txp
             lea auflî,a2
             bsr formalert          ;falsche Auflîsung
             bsr aktzeile
             bra txpret
txp          move 12(a0),d6         ;Bildbreite
             move 14(a0),d7         ;Hîhe
             bsr mausf0
             bsr pian               ;Anpassungsformular
             bne txpret
             bsr mausf2
             move.l bytes,d0
             add.l rest,d0
             addq.l #5,d0           ;Platzbedarf fÅr Bild
             and #$fffe,d0          ;geradzahliger Wert
             move.l d0,-(a7)
txps         move.l a6,a0
             bsr ltrans             ;Platz besorgen
           lseek #0,diskhand,#0     ;Filezeiger auf Dateianfang
             tst d0
             beq.s txp0
             addq.l #4,a7
             bsr lesef
             bra txpret
txp0         lea 4(a6),a0
             move.l (a7)+,d1
             subq.l #4,d1
             move.l d1,(a6)         ;Bildgrîûe
             bsr liesdisk
             move.l (a6),4(a6)
             move -32(a6),d1
             move d1,10(a6)         ;Nummer des Bildes
             addq #1,d1
             move d1,-32(a6)
             move grkl,12(a6)       ;Auflîsung
             move d5,14(a6)         ;Pixelzeilen/Textzeile
             move 16(a6),d0         ;Bildbreite in Byte umrechnen
             addq #7,d0
             lsr #3,d0
             move d0,16(a6)         ;und wieder speichern
             move d0,bytes
             bsr grakopf
             move grazeil+20,d1
             addq #1,d1
             move d1,-(a7)          ;Zeilenzahl des Bildes
             lea 20(a6),a0          ;Beginn Bilddaten
             move d5,-(a7)
             bsr pzadr
             move (a7)+,d5
             pea (a1)               ;LÑnge Adressbereich
             move.l (a6),d1
             add.l a1,d1            ;Bildspeichergrîûe korrigieren
             move.l d1,(a6)         ;und speichern
             lea 4(a6),a0
             add.l (a0),a0
             move.l a1,d0
             pea (a0)
             bsr ltrans             ;Platz schaffen
             move.l (a7)+,a1        ;Ziel
             move.l (a7)+,d0        ;Grîûe
             move.l diskpuff,a0
             bsr copy1              ;Adressen speichern
             lea puffer,a4
             move (a7)+,8(a4)       ;Zeilenzahl
             bsr txtort
             move.l diskpuff,a1     ;Ziel
             subq.l #2,a0
             move.l a0,(a4)
txp1         move.l a0,4(a4)
             cmp.b #28,9(a0)
             bne.s txp3
             bsr bildein            ;geÑnderte Zeile eintragen
             subq #1,8(a4)
             bne.s txp1
txp2         move.l a0,d1           ;Transferbeginn erhalten
             sub.l (a4),d1          ;grîûe alter Block
             move.l a1,d0
             sub.l diskpuff,d0      ;grîûe neuer Block
             move d0,-(a7)
             sub.l d1,d0
             bsr ltrans             ;Platz besorgen
             move.l diskpuff,a0
             move (a7)+,d0
             move.l (a4),a1
             bsr copy1              ;neuen Block eintragen
             move #1,-6(a6)
             bsr neuscreen          ;zeigen
txpret       bra closedisk
txp3         move 8(a4),d1
             add d1,-24(a6)
             bra.s txp5
txp4         lea grazeil,a0
             moveq #26,d0
             bsr copy1              ;Leerzeile mit Bild
             addq #1,-8(a0)         ;Zeilennummer
txp5         dbra d1,txp4
             move.l 4(a4),a0
             bra.s txp2

txpfull0     bsr closedisk
txpfull      lea voll,a2
             bra formalert

suchrep      move.l #16,baumnr
             bsr baumadress
             move 130(a0),grkl
             move 202(a0),idfl
             clr allfl
             move -14(a6),d0
             cmp -24(a6),d0
             beq tsret
             addq #1,-14(a6)
             bra.s tsuf

txtsuch      move.l #16,baumnr
             clr erstobj
             move #4,editobj
             bsr formular
             bne tsret
             bsr baumadress
             move 130(a0),grkl
             move 202(a0),idfl
             move 226(a0),allfl
tsuf         pea (a0)               ;Baumadresse auf Stack
             clr.l bytes
             moveq #4,d2
             bsr txtadr
             move.l a0,suchadr
             bsr wlÑnge
             move d0,bytes
             moveq #7,d2
             bsr txtadr
             move.l a0,ersadr
             bsr wlÑnge
             move d0,bytes+2
             move.l -4(a6),rest     ;momentane Textvariablen sichern
             move -10(a6),txtzg
             move -14(a6),txtzg+2
             bsr txtort
             move.l a0,a5
             move.l d0,d5
             move -14(a6),d6        ;aktuelle Zeile
             move.l (a7),a0         ;Baumadresse
             tst 298(a0)            ;aufwÑrts ?
             beq.s tsu1             ;Nein
tsuup        bsr tbg0
             lea (a5,d2.l),a0
             moveq #0,d2
tsuup0       bsr suche
             beq.s tsuup1
             subq #1,d6
             cmp #1,d6
             beq.s tsuaret
             move d6,d1
             bsr txtort1
             move.l a0,a5
             bra.s tsuup
tsuup1       bsr find
             beq.s tsuup0
             bra.s tsuret
tsu1         bsr tbg0               ;Textbeginn in Zeile holen
             lea (a5,d2.l),a0       ;und in a0 speichern
             moveq #0,d2
tsu10        bsr suche
             beq.s tsu2             ;gefunden
             addq #1,d6
             cmp -24(a6),d6
             bgt.s tsuaret          ;alles durchsucht
             add.l d5,a5
             move (a5)+,d5
             bra.s tsu1
tsu2         bsr find
             beq.s tsu10
             bra tsuret
tsuaret      lea suchend,a2
             bsr formalert
             tst allfl
             beq.s tsuret
             move.l rest,-4(a6)     ;Textvariablen restaurieren
             move txtzg,-10(a6)
             move txtzg+2,-14(a6)
             bsr neuscreen
tsuret       addq.l #4,a7
tsret        rts

txtdruck     btst #3,flag
             bne.s tdr
tdr0         lea notreib,a2         ;Treiber fehlt
             bsr formalert
             bra tdret              ;Abbruch
tdr          bsr auswahl            ;welcher Text
             bne tdret
             pea (a6)
             bsr beginn             ;Textbeginn holen (a2)
             lea 68(a2),a6
             move.l #20,baumnr
             moveq #1,d5
             move #6,inindex
             move #2,stellen
             bsr binin
             addq #1,inindex
             move -30(a6),d4
             ext.l d4
             divu schrhî,d4
             bsr suchseite          ;letzte Seite
             bsr binin
             bsr druform            ;Einstellformular rufen & auswerten
             bne tdrt2
             bsr mausf2
             lea -68(a6),a2
             bsr prtres             ;Voreinstellungen
td           move erste,aktseite
td4          tst zweis
             beq.s td5
             bset #2,flag           ;Vorderseite wird gedruckt
td5          bsr prtkopf            ;Seitenkopf
             bsr printstart         ;Adresse der ersten Druckzeile
             bne td9                ;Adresse > als Textende
             bsr prtseite           ;Eine Seite drucken
             tst d0
             bmi tdrt1              ;abbrechen
             beq.s td9              ;Text ist fertig
             move aktseite,d0
             addq #1,d0
             add zweis,d0
             move d0,aktseite
             cmp letzte,d0
             bhi.s td9              ;Vorder- RÅckseite fertig
             tst einzel
             beq.s td5              ;endlos
             pea (a2)
             lea neublatt,a2
             bsr formalert          ;'Neues Papier einfÅhren'
             move.l (a7)+,a2
             bra.s td5
td9          tst zweis
             beq.s tda              ;nur einseitig drucken
             btst #2,flag
             beq.s tda              ;war bereits RÅckseite
             bclr #2,flag
             move erste,d0
             addq #1,d0
             move d0,aktseite
             pea (a2)
             lea wenden,a2
             bsr formalert          ;Meldung 'Papier wenden'
             move.l (a7)+,a2
             move 26(a2),raza
             bra td5
tda          subq #1,exemp
             bne td
tdrt1        bsr mausf0
tdrt2        move.l (a7)+,a6
tdret        move sel,psel
txdr         rts

txtzeilab    move.l #36,baumnr
             clr.l erstobj
             bsr formular
             bne.s txdr
             moveq #82,d1
             bsr selindex
             moveq #4,d7           ;button in abstand umrechnen
             sub d0,d7
             move d7,2(a5)         ;abstand eintragen
             bsr baumadress
             tst 178(a0)
             beq.s tza1            ;Abstand nicht Åbernehmen
             bsr txtort
             move -14(a6),d6
tza0         cmp.b #28,7(a0)
             beq.s tza2             ;in grafik keine Ñnderung
             move d7,2(a0)          ;Abstand eintragen
tza2         cmp -24(a6),d6
             beq.s tza1
             add.l d0,a0
             move (a0)+,d0
             addq #1,d6
             bra.s tza0
tza1         bsr zeilÅber
             move #1,-6(a6)
             bra neuscreen

txtklsei     lea kills,a2
             bsr formalert
             bne tktret
             moveq #2,d1
             bsr txtort1
             moveq #2,d1
tks          move.l a0,suchadr      ;Seitenbeginn
             move d1,idfl           ;Nummer erste Zeile
             move -30(a6),d7        ;SeitenlÑnge
tks1         move 2(a0),d2
             mulu schrhî,d2
             cmp d2,d7
             blt.s tks              ;neue Seite
             cmp -14(a6),d1
             beq.s tks2             ;Seite ist gefunden,Ende suchen
             addq #1,d1
             sub d2,d7
             add.l d0,a0            ;Adresse nÑchste Zeile
             move (a0)+,d0
             bra.s tks1
tks2         addq #1,d1
             sub d2,d7
             ble.s tks3
             cmp -24(a6),d1
             bgt.s tks3
             add.l d0,a0
             move (a0)+,d0
             move 2(a0),d2
             mulu schrhî,d2
             bra.s tks2
tks3         add.l d0,a0
             move idfl,d0
             sub d0,d1
             sub d1,-24(a6)
             move d0,-14(a6)
             subq #2,d0
             cmp #2,d0
             bge.s tks4
             moveq #2,d0
tks4         move d0,-10(a6)
             move.l a0,d0
             addq.l #2,d0
             sub.l suchadr,d0
             neg.l d0
             bsr ltrans
             move.l blsel,d0
             cmp.l sel,d0
             bne.s tks5
             move idfl,d0
             cmp blen,d0
             bgt.s tks5
             bsr demark
             move #1,-6(a6)
tks5         bra neuscreen

txtkltxt     lea killtxt,a2
             bsr formalert
             bne tktret
             lea txtstart+4,a2
             move.l sel,d0
             add.l d0,a2
             move.l (a2),a0
             move.l a0,d0
             sub.l -4(a2),d0
             move.l d0,free
             neg.l d0
             bsr transfer
             move wiakt,d0
             mulu #2,d0
             lea wihand,a0
             move (a0,d0.l),akthand
             lea name,a0
             move.l sel,d0
             move.l d0,-(a7)
             lsl #2,d0
             clr (a0,d0.l)          ;Namen lîschen
             clr opnfl
             moveq #28,d5
             moveq #74,d6
             bsr menchange0
             bsr sch1
             move.l (a7)+,d0
             cmp.l blsel,d0
             bne.s tkkl
             bsr demark
tkkl         lea txtstart,a0
             moveq #0,d1
tkt          move.l (a0)+,a1
             addq #1,d1
             cmp.l (a0),a1
             bne.s tkt2
tkt1         cmp #8,d1
             bne.s tkt
             moveq #18,d5
             moveq #26,d6
             bsr menchange0
tkt2         tst (a1)               ;Text ?
             bne.s tkt1             ;nein
tktret       rts

txtkltab     move -2(a6),d3         ;kpos
             move -14(a6),d4        ;aktuelle Zeile
             bsr grafik             ;Kursor auf Grafik ?
             bne.s tktret           ;nein
             bsr invert             ;Grafik invertieren
             lea diegraf,a2
             bsr formalert
             beq.s kta
             bra invert
kta          move 11(a5,d2.l),d3    ;ZeilenzÑhler
             move 13(a5,d2.l),d5    ;Bildnummer
             move -14(a6),zeile
             move 9(a5,d2.l),d0     ;Grafikzeilennummer
             sub d0,-14(a6)         ;erste Zeile dieser Grafik
             bsr killbild
             bsr bildnr
             lea (a3,d0.l),a0
             addq.l #4,d0
             neg.l d0
             add.l d0,-36(a6)
             bsr ltrans
             move zeile,-14(a6)
             move #1,-6(a6)
             bsr vollschirm
             bra kursor
;Subroutinen
maûin        divu grkl,d5
             cmp.l #$ffff,d5
             blt.s min
             addq #1,d5
             and.l #$ffff,d5
min          bra binin

pian         btst #3,flag           ;Treiber ?
             bne.s piaf             ;ja
             move #80,grkl          ;sonst Dichte 80 verwenden
             addq #7,d6             ;aufrunden
             lsr #3,d6              ;durch 8 teilen
             and.l #$ffff,d6        ;Highword ausblenden
             move d6,d0
             bra pia0
piaf         move.l #52,baumnr
             clr.l erstobj
             move #2,stellen
             bsr rettsch
pia          move #6*24+10,d1
             bsr selindex
             add d0,d0
             lea gradicht,a0
             move (a0,d0.l),grkl   ;gewÑhlte Auflîsung
             move d6,d5
             mulu #10,d5
             move #19,inindex
             bsr maûin             ;Breite in Byte eintragen
             move #20,inindex
             move d7,d5
             mulu #6,d5
             bsr maûin             ;Hîhe in Zeilen
             bsr drawt
             bsr formdo0
             move #18,erstobj
             cmp #2,d2
             bhi.s pia
             bsr obchange0
             bsr holsch
             cmp #1,d2
             beq.s pia1
             bsr aktzeile           ;Abbruch
             bra fehler
pia1         move #19,inindex
             bsr binout
             move d0,d6             ;vorgegebene Breite in Buchst.
             move #3,inindex
             bsr binout
             tst d0                 ;Eingabe
             bne.s pia0
             move d6,d0
pia0         move grkl,d5           ;Dichte
             mulu d6,d5             ; * berechnete Breite
             move d0,d6             ;gewÑhlte Breite nach d6
             mulu #6,d0
             divu d0,d5             ; / gewÅnschte Breite*6
             and.l #$ffff,d5        ;ergibt Pixel/Druckzeile
             bra ok

grakopf      lea grazeil+14,a1      ;header fÅr Grafik bilden
             move -2(a6),(a1)+      ;kpos
             move d6,(a1)+          ;Breite
             clr (a1)+              ;Zeilennummer
             move d7,d0             ;Hîhe
             divu d5,d0
             cmp.l #$ffff,d0        ;Divisionsrest ?
             bgt.s gk
             subq #1,d0
gk           move d0,(a1)+          ;Nr letze Zeile
             move 10(a6),(a1)+      ;Bildnummer
             rts

killbild     move.l diskpuff,a1
             bsr txtort
             subq.l #2,a0
             move.l a0,suchadr
kta0         move.l a1,a4
             addq #2,d0
             bsr copy1
             moveq #9,d2
kta1         cmp 13(a4,d2.l),d5
             beq.s kta2
             add.l 1(a4,d2.l),d2
             bra.s kta1
kta2         lea 16(a4,d2.l),a0
             move (a4),d0
             lea 2(a4,d0.l),a1
             moveq #-16,d0
             bsr transfer1
             sub #16,(a4)
             addq #1,-14(a6)
             bsr txtort
             subq.l #2,a0
             dbra d3,kta0
             move.l a1,d0
             sub.l diskpuff,d0
             move.l d0,-(a7)
             sub.l a0,d0
             add.l suchadr,d0
             bsr ltrans
             move.l diskpuff,a0
             move.l suchadr,a1
             move.l (a7)+,d0
             bra copy1

find         move d6,-14(a6)        ;aktuelle Zeile
             move d4,-2(a6)
             tst bytes+2
             beq.s tsuz             ;nur suchen
             tst allfl
             bne.s tsu6             ;alle ersetzen
tsuz         bsr zeigfund           ;zeigen
             tst bytes+2
             beq.s tsu5             ;war nur suchen
             lea ersetze,a2
             pea (a0)
             bsr formalert
             move.l (a7)+,a0
             cmp #2,d0
             bgt fehler             ;Abbruch
             beq ok                 ;nicht ersetzen
tsu6         bsr ersetzen
             bra ok
tsu5         pea (a0)
             lea suchweit,a2
             bsr formalert          ;weiter suchen ?
             move.l (a7)+,a0
             cmp #1,d0
             beq ok
             bra fehler

wlÑnge       moveq #0,d0
             cmp.b #64,(a0)
             beq.s wlret
wl           addq #1,d0
             tst.b (a0)+
             bne.s wl
             subq #1,d0
wlret        rts

suche        move.l suchadr,a1
             tst grkl
             beq.s nogr             ;Schreibweise nicht beachten
sut0         move.l a1,a2
             move.l d2,d4           ;Zeiger Wortanfang
             lea -1(a0),a3          ;1 Buchstabe vor Anfang
su1          move.b (a2)+,d1
             bne.s su2
             tst idfl
             beq ok
             bsr ident
             beq ok
             bra.s sut0
su2          move.b (a0)+,d0
             beq fehler             ;nicht in Zeile
             cmp.b #27,d0
             bne.s su3
             addq.l #1,a0
             bra.s su2
su3          addq #1,d2
             cmp.b #63,d1
             beq.s su1              ;Joker
             cmp.b d0,d1
             beq.s su1
             bra.s sut0
nogr         move.b #32,d3          ;fÅr Umwandlung in Kleinbuchst.
su4          move.l a1,a2
             move d2,d4
             lea -1(a0),a3
su5          move.b (a2)+,d1
             bne.s su6
             tst idfl
             beq ok
             bsr.s ident
             beq ok
             bra.s su4
su6          move.b (a0)+,d0
             beq fehler
             cmp.b #27,d0
             bne.s su7
             addq.l #1,a0
             bra.s su6
su7          addq #1,d2
             cmp.b #63,d1
             beq.s su5
             cmp.b #65,d1
             blt.s su8
             cmp.b #90,d1
             bgt.s su8
             add.b d3,d1
su8          cmp.b #65,d0
             blt.s su9
             cmp.b #90,d0
             bgt.s su9
             add.b d3,d0
su9          cmp.b d0,d1
             beq.s su5
             bra.s su4

ident        pea (a0)               ;Zeiger in Zeile retten
             tst d4
             beq.s idt              ;Zeilenanfang
             move.b (a3),d0
             lea trennzei,a0
             bsr suchbyt
             bne.s idrt1            ;Wort ist Teil eines anderen
             move.l (a7),a0         ;Zeiger zurÅck
idt          move.b (a0),d0
             beq.s idrt             ;Zeilenende
             lea trennzei,a0
             bsr suchbyt
             bne.s idrt1
idrt         move.l (a7)+,a0
             bra ok
idrt1        move.l (a7)+,a0
             bra fehler

zeigfund     move d6,d0
             subq #2,d0
             cmp #2,d0
             bge.s tsu3
             moveq #2,d0
tsu3         move d0,-10(a6)        ;erste Zeile
             pea (a0)               ;Adresse in Zeile
             pea (a5)               ;Zeilenadresse
             move.l d5,-(a7)        ;ZeilenlÑnge
             move.l d2,-(a7)        ;Position in Zeile
             move d6,-(a7)          ;Zeilennummer
             bsr neuscreen          ;Zeigen
             move (a7)+,d6
             move.l (a7)+,d2
             move.l (a7)+,d5
             move.l (a7)+,a5
             move.l (a7)+,a0
             rts

ersetzen     pea (a0)
             move.l ersadr,a0
             move.b (a0),d4
             move.l d5,d0           ;LÑnge und
             move.l a5,a0           ;Adresse sichern
             lea aktwort,a1
             move.l a1,a3
             bsr copy1              ;Zeile öbertragen
             move -2(a6),d3         ;kpos
             move.l a3,a0
             moveq #7,d1
ers          move.b (a0,d1.l),d0
             cmp.b #28,d0
             bne.s ers1
             add.l 1(a0,d1.l),d1
             bra.s ers
ers1         move.b (a0,d1.l),d0
             cmp.b #27,d0
             bne.s ers2
             addq #2,d1
             bra.s ers1
ers2         subq #1,d3
             bmi.s ers3             ;gefunden
             addq #1,d1
             bra.s ers1
ers3         move bytes,d0
             pea (a0,d1.l)          ;Wortbeginn
             add d0,d1              ;Wortende
             lea (a0,d1.l),a0       ;Beginn Transfer
             cmp.b #11,d4;92,d4;95,d4
             beq.s ers4             ;Wort lîschen
             sub bytes+2,d0
             beq.s ers5             ;Wîrter sind gleichgroû
ers4         ext.l d0
             neg.l d0
             lea (a0,d5.l),a1       ;Ende transfer
             add.l d0,d5            ;neue ZeilenlÑnge
             bsr transfer1
ers5         move.l (a7)+,a1        ;Wortbeginn
             move.l ersadr,a0       ;Ersatzwort
             cmp.b #11,d4;92,d4
             beq.s ers6
             move bytes+2,d0
             bsr copy1               ;Ersatz eintragen
ers6         btst #0,d5
             beq.s ers8
             tst.b -2(a3,d5.l)
             bne.s ers7
             subq #1,d5
             bra.s ers8
ers7         move.b #0,(a3,d5.l)
             addq #1,d5
ers8         move -2(a5),d0         ;alte ZeilenlÑnge
             move d5,-2(a5)         ;neue eintragen
             ext.l d0
             lea (a5,d0.l),a0       ;Beginn nÑchste Zeile
             sub.l d5,d0
             beq.s ers9             ;keine LÑngenÑnderung
             neg.l d0
             bsr ltrans             ;Platz schaffen
ers9         move.l a3,a0
             move.l a5,a1
             move d5,d0
             bsr copy1              ;Korrigierte Zeile zurÅckschreiben
             move.l (a7)+,a0
             rts

druform      move.l #20,baumnr      ;Druckformular
             move #0,erstobj
             move #6,editobj
             bsr formular
             bne fehler
auswert      bsr baumadress
             move 82(a0),nlq        ;Flag 'Normal-NLQ'
             lsl nlq
             move 298(a0),einzel    ;Flag 'Einzelblatt-endlos'
             move 346(a0),zweis     ;Flag 'ein- zweiseitig drucken'
             moveq #6,d2
             bsr binout1
             tst d0
             bgt.s td0
             moveq #1,d0
td0          move d0,erste          ;Erste Druckseite
             moveq #7,d2
             bsr binout1
             move erste,d1
             cmp d0,d1
             blt.s td1
             move d1,d0
td1          move d0,letzte         ;letzte Druckseite
             moveq #9,d2
             bsr binout1
             tst d0
             bhi.s td2
             moveq #1,d0
td2          move d0,exemp          ;Exemplarzahl

drucker      clr -(a7)
             move #8,-(a7)          ;bcostat
             trap #13
             addq.l #4,a7
             move d0,prt
             bne ok
             lea nodruck,a2
             bsr formalert
             beq.s drucker
             bra fehler


prtres       moveq #0,d1
             bsr txtort1
             lea kopfz,a5
             bsr head               ;Kopfzeile bilden
             moveq #1,d1
             bsr txtort1
             lea fuûz,a5
             bsr head               ;Fuûzeile
             moveq #81,d6
             bsr prtsteu0           ;Druckerreset
             moveq #85,d6           ;Papierendesensor aus
             tst einzel
             bne.s td3
             moveq #86,d6           ;Sensor ein
td3          bsr prtsteu0
             move 22(a2),raza       ;Rand links
             moveq #10,d6
             bsr prtsteu0           ;WagenrÅcklauf
             moveq #12,d6
             bsr prtsteu0
             move.l -68(a6),d4
             bra lprint

prtseite     move slen,d0
td6          move 2(a5),d1
             mulu schrhî,d1
             sub d1,d0
             bmi.s td7              ;Seite ist fertig
             move d0,slen
             bsr prtzeile           ;Zeile ausgeben
             bsr druckstop          ;Drucken abbrechen ?
             beq.s td6a             ;nein
             moveq #-1,d0
             bra.s pseret
td6a         move.l druckad,a5      ;Adresse korrigieren
             move.l druckl,d0
             add.l d0,a5
             move (a5)+,d0
             cmpa.l nxtstart,a5
             blt.s td60             ;noch eine Zeile
             moveq #2,d3
             bsr setvs
tde0         move slen,d0
             sub zlabst,d0
             bmi.s tde1
             move d0,slen
             bsr newl0
             bra.s tde0
tde1         add zlabst,d0
             bsr.s seitenend
             moveq #0,d0
             bra.s pseret
td60         move.l a5,druckad      ;und wieder speichern
             move.l d0,druckl
             move slen,d0
             bra.s td6              ;nÑchste Zeile
td7          add d1,d0
             bsr.s seitenend        ;Ausgleichsvorschub und Fuûzeile
             moveq #1,d0
pseret       rts

prtkopf      moveq #2,d3            ;Vorschub auf 6 Zeilen/Zoll
             bsr setvs
             move -30(a6),slen
             move.l -64(a6),d7      ;Rand oben
             bsr vrs1
             lea kopfz,a5
             tst.l -60(a6)
             bne.s prk
             rts
prk          bsr headout
             move.l -60(a6),d7
             bra vrs1

seitenend    beq.s td8
             ext.l d0
             divu schrhî,d0
             move d0,d3
             bsr vsch               ;Ausgleichsvorschub
td8          moveq #2,d3
             bsr setvs
             move.l -56(a6),d7
             bsr vrs1
             tst.l -52(a6)
             bne.s see
             rts
see          lea fuûz,a5
             bsr headout
             moveq #11,d6           ;'Form-Feed'
             bsr prtsteu0
             moveq #10,d6           ;'CR'
             bra prtsteu0

printstart   bsr.s seite
             bne fehler
             bsr txtort1
             move.l a0,a5
             move.l a5,druckad      ;Adresse und LÑnge der 1.
             move.l d0,druckl       ;Druckzeile speichern
             bra ok

seite        move aktseite,d2
             moveq #2,d1            ;Zeile
             bsr txtort1
             move.l a0,a5
             moveq #2,d1
             bra.s pst2
pst0         move -30(a6),d3        ;SeitenlÑnge
pst1         move 2(a5),d4
             mulu schrhî,d4
             sub d4,d3
             bmi.s pst2             ;Seitenende
             addq #1,d1
             add.l d0,a5
             cmpa.l nxtstart,a5
             bge fehler
             move (a5)+,d0
             bra.s pst1
pst2         subq #1,d2
             bne.s pst0             ;noch eine Seite
             bra ok

schrift      bsr.s streset          ;Pica,Elite,..
             moveq #1,d5
             move.b 1(a5),d2        ;Fett,Kursiv usw
sft0         move.b -1(a3,d5.l),d0
             and.b d2,d0
             beq.s sft1             ;nicht schalten
             bsr.s setschr
sft1         addq #1,d5             ;nÑchste Schriftform
             cmp #6,d5
             bne.s sft0
             rts

setschr      moveq #0,d6
             move.b 8(a3,d5.l),d6
             add.b (a4,d5.l),d6     ;ein- oder ausschalten
             add nlq,d6
             eori.b #1,(a4,d5.l)    ;umschalten
             bra prtsteu0           ;Schriftkommando ausgeben

streset      lea steuer0,a3
             lea futas+10,a4
             moveq #0,d6
             clr.l (a4)
             clr 4(a4)              ;Flags lîschen
             move.b 6(a5),d0
             and.l #15,d0
             move.b 8(a3,d0.l),d6
             add nlq,d6
             bra prtsteu0

headout      bsr rand
             bsr.s streset
             move (a5),d5
             beq.s ho0              ;keine Numerierung
             ext.l d5
             lea (a5,d5.l),a0       ;Ort der Numerierung
             move 4(a5),d5
             pea 1(a0,d5.l)
             move d5,stellen
             move 2(a5),d0          ;erste Nummer
             add aktseite,d0
             subq #1,d0
             ext.l d0
             bsr formzahl1          ;Nummer eintragen
             move.l (a7)+,a0        ;Nullbyte öberschreiben
             move.b #32,(a0)
ho0          moveq #7,d2
             bra druckzeil          ;Zeile ausgeben

head         clr (a5)               ;keine Numerierung
             moveq #7,d5            ;ZÑhler Ort
             move.b 6(a0),6(a5)     ;Pica,...
             lea 7(a0),a0           ;Anfang Text
hd0          move.b (a0)+,d0        ;Buchstabe holen
             beq.s hdfert           ;fertig
             cmp.b #35,d0
             beq.s hd1
             move.b d0,(a5,d5.l)    ;eintragen
             addq #1,d5
             bra.s hd0
hd1          move d5,(a5)           ;Ort eintragen
             move.l a0,d4
             bsr dezbin             ;Zahl holen
             tst d2
             bne.s hd2
             move.b #35,(a5,d5.l)   ;es folgte keine Zahl
             clr (a5)
             addq #1,d5
             bra.s hd0              ;weiter Åbertragen
hd2          sub.l a0,d4
             neg.l d4
             add d4,d5
             subq.l #1,a0           ;Ende Zahl
             subq #1,d4
             move d0,2(a5)          ;Nummer eintragen
             move d4,4(a5)          ;ebenso Stellenzahl
             bra.s hd0
hdfert       move.b d0,(a5,d5.l)    ;zwei Endemarken,da durch
             move.b d0,1(a5,d5.l)   ;Numerierung eine Åberschrieben
             rts                    ;werden kann

   end
 