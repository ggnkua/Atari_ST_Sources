txtop        bsr platz              ;Datensatz frei ?
             bne topr
             bsr fenfrei
             bne topr
             bsr textlad
             bne topr               ;Abbruch oder Diskfehler
             lea neutxt,a2
             bsr suchfile           ;File auf Disk ?
             beq.s holtxt           ;Ja
             cmp.w #1,d0
             beq.s top              ;neuen Text einrichten
             bsr aktzeile
topr         move wiakt,wiarb
             move.l sel,psel
             rts
top          bsr holstart
             bsr neudoc
             bra docopn

holtxt       bsr holstart1
             bne.s txtr
             bsr openin
             bsr baumadress
             tst 898(a0)
             beq.s tfo0
             bsr eigen
             bne.s txtret1
             bra.s ht0
tfo0         tst 922(a0)
             beq.s tfo1
             bsr wplus
             bne.s txtret1
             bra.s ht0
tfo1         bsr asctxt
             bne.s txtret1
ht0          bsr closedisk
             bra docopn             ;Text darstellen

txtret1      bsr closedisk
             lea txtstart+4,a2      ;Speicher zurÅckgeben
             add.l psel,a2
             move.l (a2),a0
             move.l free,d0
             neg.l d0
             bsr transfer
             tst wiakt
             bmi.s txtr             ;kein Textfenster aktiv
             move.l sel,psel
             move wiakt,wiarb
             bsr txtopn             ;und neu zuteilen
             bsr aktzeile
txtr         rts

txtsi        bsr auswahl
             bne.s txtr
txsi         bsr txs
             pea (a0)
             bne.s ascitxt
             bsr beginn             ;Beginn und Ende holen
             bsr writ
txsend       move.l sel,psel
             bsr closedisk
             move.l (a7)+,a0
             tst autodat
             beq.s txtr
             bra autosich           ;in Verwaltungsdatei eintragen

txtsias      bsr auswahl            ;Text wÑhlen
             bne.s txtr
             move.l a1,a5           ;Adresse Namen
             bsr holtxtnam
             bne.s txtr
             bra.s txsi             ;speichern

ascitxt      bsr beginn
             clr 62(a2)             ;énderungsflag zurÅcksetzen
             pea (a6)
             lea 68(a2),a6
             moveq #1,d1
             bsr txtort1
             move.l a0,a5
             move.l d0,d6
             move.l (a7)+,a6
             bsr ascsi
             bra txsend          ;alles Åbertragen

prginfo      bsr mausf2
             lea info,a0
             bsr createfile
             bne lesef              ;Fehler beim ôffnen
             lea infst,a2
             move.l #txtdefvar,d2
             sub.l a2,d2
             bsr writefile
             bra closedisk

dislosch     lea filesel+63,a1
             bsr diskop0
             bne.s dlret
             move.l a1,a0
             bsr killfile
dlret        rts

datinf       lea filesel+126,a1
             bsr diskop0
             bne.s dlret
             pea (a1)
             move.l #32,baumnr
             lea dtinf,a1
             moveq #2,d2
             bsr txtin
             move.l (a7),a0
             bsr copy               ;name
             move.l (a7)+,a1
             lea nofile,a2
             bsr diskdat
             bne.s dlret
             moveq #3,d2
             bsr txtadr
             adda.l #7,a0
             move.l 26(a3),d0       ;grîûe
             bsr htaus
             moveq #4,d2
             bsr txtadr
             adda.l #5,a0
             bsr tag
             move.b #46,(a0)+       ;"."
             bsr monat
             move.b #46,(a0)+
             bsr jahr
             move.w #0,erstobj
             move.w #0,editobj
             bra formular

ordner       lea filesel+105,a1
             bsr diskop0
             bne.s oret
             pea (a1)
             move.w #57,-(a7)       ;mkdir
             trap #1
             addq.l #6,a7
oret         rts

renam        lea filesel+84,a1
             bsr diskop0
             bne.s oret
             pea (a1)
             lea nofile,a2
             bsr suchfile
             bne.s oret
             move.l #8,baumnr
             moveq #4,d2
             bsr txtadr
             adda.l #12,a0
             move.l (a7)+,a1
             exg.l a1,a0
             bsr copy
             move.w #0,erstobj
             move.w #5,editobj
             bsr formular
             bne.s oret
             moveq #5,d2
             bsr txtadr
             lea puffer,a1          ;Zwischenspeicher
             pea (a1)
             bsr formnam            ;Namen aufbereiten
             movea.l (a7)+,a0       ;Pufferadresse zurÅck
             lea datei,a1
             bra renamfile
;Unterprogramme
textlad      lea filesel,a1
             lea name+480,a5        ;keine Namensvorgabe
             moveq #0,d6            ;erste Extention
             bra diskopen           ;Namen holen

holtxtnam    lea filesel+42,a1
             moveq #0,d6
             bsr diskopen
             bne.s htn              ;Fehler
             pea (a5)
             bsr aktzeile
             move.l (a7)+,a0
             clr d0
htn          rts

txs          bsr nam_pfad           ;Namen aus Pfad isolieren
             pea (a1)               ;Zeiger auf Name
             bsr setpfad            ;Dateipfad setzen
             move.l (a7),a0
             lea puffer,a1
             bsr copy               ;Namen in Puffer schreiben
             move.b #"O",-1(a1)     ;"Alt"
             lea puffer,a1
             bsr sfile              ;Backup vorhanden ?
             bne.s tes0             ;nein
             lea puffer,a0
             bsr killfile
tes0         move.l (a7),a1         ;Namensadresse
             bsr sfile
             bne.s tes1             ;keine gleichnamige vorhanden
             lea puffer,a0
             move.l (a7),a1
             bsr renamfile          ;Datei umbenennen
tes1         move.l (a7),a0
             move.b #92,-1(a0)        ;\ wieder setzen
             bsr createfile         ;Datei einrichten
             bne openerr
             setdrv aktdisk
             chdir pfad
             bsr mausf2
             move.l (a7)+,a0
             tst ascsp
             rts

nam_pfad     bsr.s wortend          ;Pfadende
tes          cmp.b #92,-(a1)
             bne.s tes
             move.b #0,(a1)+
             rts

wortend      lea (a0),a1
we           tst.b (a1)+
             bne.s we
             subq.l #1,a1
             rts

setpfad      pea 2(a0)              ;Pfad
             move.b (a0),d0
             ext.w d0
             sub #65,d0
           setdrv d0                ;Disk
             move.l (a7)+,a0
           chdir (a0)               ;Pfad
             rts

writ         sub.l a2,d2            ;TextlÑnge
             clr 62(a2)             ;énderungsflag zurÅcksetzen
             moveq #6,d1
             moveq #0,d0
tes3         add.l (a2)+,d0         ;Kontrollsumme bilden
             dbra d1,tes3
             move.l d0,(a2)         ;und eintragen
             sub.l #28,a2           ;wieder Textanfang
             bra writefile          ;Text speichern

holstart1    movea.l dta,a0
             move.l 26(a0),d0
             add.l #2048,d0         ;DateilÑnge
             cmp.l free,d0
             bcs.s holstart
             bra txpfull
holstart     lea txtstart+4,a2      ;Ende des dem Text zugeordneten
                                    ;Speichers als Transferuntergrenze
             pea (a2)
             bsr txtcl              ;wenn nîtig Speicher freigeben
hs0          move.l (a7)+,a2
             adda.l psel,a2
hs1          movea.l (a2),a0
             move.l -4(a2),aktbeginn ;Beginn merken
             move.l -4(a2),a6
             lea 68(a6),a6
             move.l free,d0
             bsr transfer
             bra ok

eigen        bsr.s eigprÅf          ;stimmt Textart
             bne.s ei0              ;nein
             move.l aktbeginn,a1
             move.l diskpuff,a0
             move.l bytes,d0
             move.l rest,d1
             add.l d0,d1
             sub.l d1,free
             add.l a1,d1
             move.l d1,aktend
             bsr.s txtlies
             bsr txtzeiger
             bra adrneu
ei0          lea asclad,a2
             bsr formalert
             beq.s asctxt

eigprÅf      movea.l diskpuff,a0
             moveq #0,d6            ;Kontrollsumme
             moveq #6,d5            ;7 Layoutwerte
ep0          move.l (a0)+,d0
             add.l d0,d6            ;Summe bilden
             dbra d5,ep0
             move.l (a0)+,d0        ;Kontrollwert holen
             cmp.l d0,d6
eprt         rts

txtlies      bsr copy2              ;aus Diskpuff in Textspeicher Åbertr.
             move.l rest,d1
             beq.s eprt             ;alles eingelesen
             move.l a1,a0           ;Ablageort
             bra liesdisk           ;Rest direkt in Textspeicher

asctxt       move.l aktbeginn,a1
             lea seitenm,a0
             moveq #92,d0
             bsr copy1              ;Header bilden
             move.l a1,txtzg
             move.l diskpuff,filezg
             move #25,-18(a6)       ;erlaubte Breite vorbesetzen
             bsr ladeasc            ;Text laden & aufbereiten
             move -24(a6),d7        ;Zeilenzahl
             move -18(a6),d6        ;Linealbreite
             moveq #0,d0            ;lîschen
             lea 4(a6),a0
at7          move (a0)+,d0
             move d6,4(a0)          ;in Zeilen eintragen
             add.l d0,a0
             dbra d7,at7
at8          move.l txtzg,d0;aktend
             move.l d0,aktend
             sub.l aktbeginn,d0
             sub.l d0,free
             bsr txtzeilen
txtzeiger    bsr datnam
             moveq #18,d5
             moveq #26,d6
             bsr menchange1
             bra ok

wplus        move.l diskpuff,filezg
             move.l aktbeginn,txtzg
             bsr wpzeile            ;erste Zeile lesen
             cmp #15,d1
             bgt ei0                ;kein Word-Plus-Text
             addq.l #1,a4           ;'31' Åberlesen
             moveq #3,d0
             bsr wpsform            ;SeitenlÑnge
             bne ei0
             move.l d1,d5
             moveq #3,d7
wp           moveq #2,d0
             bsr wpsform            ;4 AbstÑnde Kopf/Fuû
             bne ei0
             sub.l d1,d5            ;TextlÑnge in Zeilen
             dbra d7,wp
             move.l txtzg,a1
             move.l #10,(a1)+       ;Rand links
             move.l #5,(a1)+        ;rechts
             addq.l #4,a1           ;Kontrollsumme
             lea txtdefvar,a0
             moveq #40,d0
             bsr copy1              ;Textvariablen Åbertragen
             move.l a1,txtzg
             bsr wpkopf             ;Kopfzeile &
             bsr wpkopf             ;Fuûzeile holen
             bsr.s wptxt            ;Text einfÅgen
             bra at8

wptxt        clr zeilhî             ;Byte 1 'Text',2 'Word-Plus'
             clr aktseite
wp1          move d5,d4
wp2          bsr wpzeile
             beq.s wp0
             subq #1,-24(a6)
             rts                    ;Fertig
wp0          cmp.b #31,(a4)
             beq wp9                ;Lineal oder Bild oder Fuûnote
             bsr wpinit             ;neue Zeile initialisieren
wp3          subq #1,d1
             bmi wp8
             move.b (a4)+,d0
             cmp.b #27,d0
             blt.s wp4              ;eintragen
             beq.s wp5              ;Steuerkommando
             cmp.b #31,d0
             bgt.s wp4
             move.b #32,d0          ;28-31 durch Space ersetzen
             bra.s wp40
wp4          cmp.b #25,d0           ;~ als Trennzeichen
             bne.s wp40
             move.b #45,d0
wp40         move.b d0,(a1)+
             addq #1,d7
             bra.s wp3              ;nÑchstes Zeichen
wp5          subq #1,d1
             move.b (a4)+,d6        ;Schriftkommando
             move.b zeilhî,d3       ;Schriftform in 'Text-Format'
             move.b zeilhî+1,d2     ;bisherige Schrift in 'Wplus'
             eor d6,d2              ;Unterschied feststellen
             btst #3,d2             ;Unterstreichen ?
             beq.s wp51
             addq #2,d7
             move.b #27,(a1)+
             move.b #1,(a1)+
             eori #8,d3
wp51         btst #0,d2             ;Fett ?
             beq.s wp52
             addq #2,d7
             move.b #27,(a1)+
             move.b #2,(a1)+
             eori #1,d3
wp52         btst #2,d2             ;Kursiv
             beq.s wp53
             addq #2,d7
             move.b #27,(a1)+
             move.b #3,(a1)+
             eori #4,d3
wp53         btst #4,d2             ;Hoch ?
             beq.s wp54
             addq #2,d7
             move.b #27,(a1)+
             move.b #4,(a1)+
             eori #128,d3
             move.b (a4),d0
             cmp.b #24,d0           ;Fuûnote ?
             bne.s wp54
             addq.l #4,a4
             subq #5,d1
wp6          move.b (a4)+,d0
             cmp.b #24,d0
             beq.s wp54             ;Fuûnote fertig
             move.b d0,(a1)+
             addq #1,d7
             bra.s wp6
wp54         btst #5,d2             ;Tief ?
             beq.s wp7
             addq #2,d7
             move.b #27,(a1)+
             move.b #5,(a1)+
             eori #64,d3
wp7          move.b d3,zeilhî
             move.b d6,zeilhî+1
             bra wp3
wp8          move.l txtzg,a0
             move aktseite,2(a0)    ;Steuerkommando - Schriftform
             move fenbr,6(a0)       ;Zeilenbreite
             move.b nzeile,8(a0)    ;Schriftart
             bsr zeilenend
             beq.s wp8a
             rts                    ;Abbrechen,da zu wenig Speicher
wp8a         move.b zeilhî,aktseite+1 ;Schriftform Beginn nÑchste Zeile
             addq #1,-24(a6)
             move.l a1,txtzg
             move.l filezg,a0
             cmp.b #12,(a0)         ;festes Seitenende ?
             beq.s wp8b
             subq #1,d4
             beq wp1                ;Seite ist fertig
             bra wp2
wp8b         addq.l #1,a0           ;'12' Åbergehen
             subq #1,d4
             move.l a0,filezg
             bra.s wp8d
wp8c         lea neuzeil,a0         ;d4 Leerzeilen einfÅgen
             moveq #10,d0
             bsr copy1
             move fenbr,-4(a1)
             addq #1,-24(a6)
wp8d         dbra d4,wp8c
             move.l a1,txtzg
             bra wp1
wp9          cmp.b #57,1(a4)
             bne wp2
             bsr wplineal
             bra wp2

neudoc       move.l aktbeginn,a1
             lea seitenm,a0
             moveq #102,d0
             bsr copy1
             move.l a1,aktend
             subi.l #102,free
             bsr txtzeilen
             bra txtzeiger

diskop0      lea name+480,a5
             moveq #12,d6
diskopen     move.l #28,baumnr
             clr erstobj
             moveq #18,d2
             bsr txtin              ;Art des Aufrufs
             move.l a5,a1
             moveq #35,d2
             bsr formtxt            ;Dateinamen
             bsr pfadnam
             lea extent+51,a3
             moveq #43,d2
dio0         move.l a3,a1
             bsr txtin
             addq.l #8,a3
             addq #1,d2
             cmp #46,d2
             bne.s dio0
             bsr rettsch
             clr erste
do           move aktdisk,d0
             addq #2,d0
             move #48,d1
             move #408,d2
             bsr setbut             ;Diskbutton setzen
             lea extnr,a2
             move.l (a2,d6.l),d0    ;d0=0,8,16,...
             lsr #3,d0
             add #37,d0
             move #37*24,d1
             move #45*24,d2
             bsr setbut             ;Extention Button setzen
             moveq #0,d7
             lea aktwort,a4
             lea extent+33,a2
             moveq #16,d2
             bsr suchdatei          ;Ordner suchen
             moveq #32,d2
             lea extent,a2
             lea extnr,a0
             add.l (a0,d6.l),a2
             addq #1,a2
             bsr suchdatei          ;Dateien suchen
             bsr baumadress
             move slh,d0
             move sly,d1
             cmp #9,d7
             ble.s do2
             move d0,d2
             mulu #9,d0
             divu d7,d0
             sub d0,d2
             mulu erste,d2
             move d7,d3
             subq #8,d3
             divu d3,d2
             add d2,d1
do2          move d0,598(a0)        ;Sliderhîhe &
             move d1,594(a0)        ;Sliderposition setzen
             lea aktwort,a4
             move erste,d0
             mulu #16,d0
             lea (a4,d0.l),a4       ;Adresse Dateinamen
             move d7,d4             ;Zahl der Dateien
             sub erste,d4
             lea 624(a0),a3
             moveq #8,d5
             moveq #26,d2
do3          move.l a4,a1
             subq #1,d4
             bpl.s do3a
             lea name+480,a1        ;lîschen
do3a         bsr txtin              ;Dateinamen eintragen
             lea 16(a4),a4
             addq #1,d2
             andi #$fffe,10(a3)     ;deselekt
             lea 24(a3),a3
             dbra d5,do3
             move #35,editobj
             bsr drawt
do0          bsr formdo0
             cmp #1,d2
             bgt.s dodi
             bsr obchange0
             moveq #35,d2
             bsr txtadr
             tst.b (a0)
             bne.s dio              ;kein Namen gewÑhlt
             bsr holsch
fehler       moveq #1,d0
             rts
dio          pea (a0)
             lea pfad,a0
             lea datei,a1
             move.l a1,a5
             move aktdisk,d0
             add #65,d0
             move.b d0,(a1)+        ;Disk
             move.b #":",(a1)+
             bsr copy               ;Pfad kopieren
             cmp.b #92,-1(a1)       ;Leerpfad ?
             beq.s ok1
             move.b #92,(a1)+       ;sonst "\" eintragen
ok1          move.l (a7)+,a0
             pea (a1)               ;Beginn eigentlicher Name
             bsr formnam            ;Namen anhÑngen
             bsr holsch
             move.l (a7)+,a1
ok           moveq #0,d0
             rts
dodi         cmp #17,d2
             bgt.s doext
             subq #2,d2             ;neue Disk
             move d2,aktdisk
do4          bsr pfadnam            ;in Formular schreiben
             move d2,erstobj
             bsr drawt              ;und zeigen
             moveq #35,d2
             bsr txtadr
             move.b #0,(a0)         ;Wahlfeld lîschen
             move d2,erstobj
             bsr drawt
             clr erste
             move #19,erstobj
             bra do
doext        cmp #37,d2
             blt.s dodat
             cmp #43,d2             ;neue Extention
             blt.s do6
             move d2,d0
             sub #43,d0
             mulu #8,d0
             lea extent+51,a1
             lea (a1,d0.l),a1
             bsr lies1              ;variable Extention lesen
             beq.s do6              ;Namen vorhanden
             bsr obchange0
             move d2,editobj
             move d2,erstobj
             bra do0
do6          sub #37,d2
             mulu #8,d2
             lea extnr,a0
             move.l d2,(a0,d6.l)    ;Extentionnummer speichern
             bra do4                ;Pfad zeigen
dodat        cmp #23,d2
             ble.s dopf
             bsr txtadr             ;Datei wurde gewÑhlt
             move.b (a0),d0
             beq do0                ;Leereintrag
             lea 2(a0),a1
             cmp.b #7,d0
             beq.s opord            ;Ordner îffnen
             moveq #35,d2
             bsr formtxt            ;Wahl Åbertragen
             move d2,erstobj
             bsr drawt              ;und zeigen
             bra do0
opord        lea pfad,a1
do7a         tst.b (a1)+            ;Ende suchen
             bne.s do7a
             move.b #"\",-1(a1)
             addq.l #2,a0
             bsr copy
do3c       chdir pfad               ;neuer aktueller Pfad setzen
             bra do4
dopf         bsr obchange0
             move erste,d0
             cmp #22,d2
             bgt.s doa
             blt.s dosc
doauf        subq #8,d0             ;''
             bpl.s do9a
             moveq #0,d0
do9a         move d0,erste
             move #19,erstobj
             bra do
doa          addq #8,d0             ;''
             move d7,d1
             subq #8,d1
             cmp d1,d0
             ble.s do9a
             move d1,d0
             bra.s do9a
dosc         cmp #21,d2
             bne.s docl
             bsr mkstate
             moveq #24,d2
             bsr oboffs             ;Y-Slider in d1
             move erste,d0
             move mausy1,d3         ;Mausposition
             cmp d1,d3
             ble doauf
             bra doa
docl         lea pfad,a1
             moveq #0,d0
doba         addq #1,d0
             tst.b (a1)+            ;ende suchen
             bne.s doba
dobb         subq #1,d0
             beq.s dobc
             cmp.b #"\",-(a1)
             bne.s dobb
             move.b #0,(a1)
             bra do3c
dobc         move.b #0,(a1)
             move.b #"\",-(a1)
             bra do3c

aktpfad      move aktdisk,d0
           setdrv d0
           getdir #0,pfad
             lea pfad,a1
             rts

pfadnam      moveq #47,d2
             bsr.s aktpfad
             bsr txtin              ;Pfadnamen
             lea extent,a0
             lea extnr,a2
             add.l (a2,d6.l),a0
             bra copy               ;+ Extention

suchdatei    bsr.s s_first
             bne ok
sdt          move.l dta,a0
             cmp.b #".",30(a0)
             beq.s sdt2
             move.b 21(a0),d0
             cmp.b d0,d2
             beq.s sdt0
             and #31,d2
             cmp.b d0,d2            ;Attribut richtig ?
             bne.s sdt2
sdt0         addq #1,d7             ;Anzahl Dateien
             move #$2020,(a4)
             cmp #16,d2
             bne.s sdt1
             move #$720,(a4)        ;Ordner
sdt1         lea 2(a4),a1           ;Namenspuffer
             lea 30(a0),a0          ;Namen im dta
             bsr copy
             lea 16(a4),a4          ;nÑchster Eintrag
sdt2       snext
             tst d0                 ;noch eine ?
             beq.s sdt              ;ja
             rts

s_first    getdta
             move.l d0,dta
           sfirst d2,(a2)
             tst d0
             rts

formnam      moveq #0,d0            ;Dateinamen Åbertragen,Space
fn           move.b (a0,d0.l),d1    ;entfernen und "." einfÅgen
             cmp.b #32,d1
             bne.s fn1
             moveq #8,d0
fn0          move.b #".",(a1)+
             bra.s fn
fn1          move.b d1,(a1)+
             beq.s fn2
             addq #1,d0
             cmp #8,d0
             beq.s fn0
             bra.s fn
fn2          subq.l #1,a1
fn3          move.b #0,(a1)
             cmp.b #"_",-(a1)
             beq.s fn3
             rts

formtxt      bsr txtadr
formtxt0     moveq #0,d1
ft           move.b (a1)+,d0
             beq.s ft2
             cmp.b #".",d0
             bne.s ft1
ft0          cmp #8,d1
             beq.s ft
             move.b #32,(a0)+
             addq #1,d1
             bra.s ft0
ft1          move.b d0,(a0)+
             addq #1,d1
             bra.s ft
ft2          move.b d0,(a0)
             rts

diskdat      bsr suchfile
             bne fehler
             move.w #47,-(a7)       ;get_dta
             trap #1
             addq.l #2,a7
             move.l d0,a3          ;dta
             bra ok

autosich     pea (a0)               ;Zeiger auf Textname
             lea puffer,a1          ;Namen in Puffer aufbereiten
             bsr namver
             lea puffer,a3
             bsr sort               ;Dateiplatz suchen
             lea puffer,a0
             move.l a4,a1
             moveq #11,d0
             bsr fin0               ;Namen in Datei
             lea leer,a0
             moveq #20,d0
             bsr fin0               ;Stichwort
             move.l a1,a4
             move.l (a7),a1
             bsr diskdat
             move.l a4,a0
             bsr tag
             bsr monat
             bsr jahr
             move.b #13,(a0)+
             move.b #10,(a0)+
             move 22(a3),d6         ;Zeit
             lsr #5,d6              ;Sekunden Åberlesen
             move d6,d0
             lsr #6,d0
             bsr zehn               ;Stunden
             move d6,d0
             and #63,d0
             bsr zehn               ;minuten
             move.b #13,(a0)+
             move.b #10,(a0)+
             move.l a0,a1
             lea name,a2
             move.l psel,d0
             mulu #15,d0
             add.l d0,a2
             move.b (a2),d0
             cmp.b #67,d0
             blt.s as3
             lea hardd,a0
             move.b (a2),8(a0)
             moveq #13,d0
             bsr copy1
             bra.s as4
as3          pea (a1)
             ext.w d0
             sub #65,d0
           setdrv d0
             moveq #8,d2
             lea extent+33,a2
             lea puffer,a4
             clr.l (a4)
             bsr suchdatei
             move.l (a7)+,a1
             bne.s as3a
             lea leer,a0
             moveq #11,d0
             bsr fin0
             bra.s as4
as3a         lea puffer+2,a0
             bsr namver
             move.b #13,(a1)+
             move.b #10,(a1)+
as4          move.l (a7),a0
             move.b #0,-(a0)        ;\ lîschen
             lea (a2),a0
             moveq #54,d0
             bsr fin0               ;Pfad
             move.l a1,a0
             move.l 26(a3),d0
             bsr mill               ;Dateigrîûe
             move.b #13,(a0)+
             move.b #10,(a0)+
             move.l a0,a1
             lea leer,a0
             moveq #47,d0
             bsr fin0
             moveq #60,d0
             lea leer,a0
             bsr fin0
             lea leer,a0
             moveq #60,d0
             bsr fin0
             move.l (a7)+,a0
             move.b #92,-(a0)
             rts

sfile        clr -(a7)
             pea (a1)
             move #$4e,-(a7)        ;Sfirst
             trap #1
             addq.l #8,a7
             tst d0
             rts

namver       moveq #0,d1
as           move.b (a0)+,d0
             cmp.b #".",d0
             beq.s as1
             addq #1,d1
             move.b d0,(a1)+
             bne.s as
             subq.l #1,a1
as0          cmp #12,d1
             beq.s as2
             addq #1,d1
             move.b #32,(a1)+
             bra.s as0
as1          cmp.b #8,d1
             beq.s as
             addq #1,d1
             move.b #32,(a1)+
             bra.s as1
as2          move.b #0,(a1)
             rts

ascsi        moveq #0,d4            ;Dateigrîûe
             move.l diskpuff,a4
ascsi0       add.l d6,a5
             move (a5)+,d6          ;Zeile
             cmp.l nxtstart,a5
             blt.s acs
             moveq #0,d2
             bra.s schreibe         ;Fertig Åbertragen
acs          bsr txtbeginn
ascsi1       move.b (a5,d2.l),d0
             beq.s zlend            ;Zeile ist fertig
             cmp.b #27,d0
             bne.s ascsi2
             addq #2,d2             ;Steuercode Åberlesen
             bra.s ascsi1           ;weiter Åbertragen
ascsi2       move.b d0,(a4)+
             addq #1,d2
             addq.l #1,d4
             cmp.l #32*1024-2,d4
             beq.s schreibe         ;Puffer ist voll
             bra.s ascsi1
zlend        move.b #13,(a4)+
             move.b #10,(a4)+
             addq #2,d4
             bra.s ascsi0           ;nÑchste Zeile
schreibe     move d2,-(a7)          ;als Zeiger retten
             move.l diskpuff,a2
             move.l d4,d2
             bsr writefile
             move (a7)+,d2
             bne.s assi
             rts
assi         moveq #0,d4
             move.l diskpuff,a4
             bra.s ascsi1           ;Noch nicht fertig

killfile     pea (a0)
             move #$41,-(a7)        ;Unlink
             trap #1
             addq.l #6,a7
             rts

renamfile    pea (a0)
             pea (a1)
             clr.w -(a7)
             move.w #86,-(a7)       ;rename
             trap #1
             adda.l #12,a7
             rts

createfile   clr -(a7)
             pea (a0)
             move #$3c,-(a7)        ;Create
             trap #1
             addq.l #8,a7
             move d0,diskhand
             bmi fehler
             bra ok

writefile    pea (a2)
             move.l d2,-(a7)
             move diskhand,-(a7)
             move #$40,-(a7)        ;Write
             trap #1
             lea 12(a7),a7
             rts

openerr      lea operr,a2
             bra formalert

jahr         lsr.w #4,d6
             move.w d6,d0
             and.w #127,d0
             add.w #80,d0         ;1980
             bra zehn

monat        lsr.w #5,d6
             move.w d6,d0
             and.l #15,d0
             bra zehn

tag          move.w 24(a3),d6       ;datum
             move.w d6,d0
             and.l #31,d0
             bra zehn

 end
 