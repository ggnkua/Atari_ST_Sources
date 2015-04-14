bloanf       cmp.b #28,7(a5)        ;Grafik ?
             beq.s keinbl
             bsr blintxt            ;Block in diesem Text ?
bla0         move #64,fen
             bsr mencheck1          ;Anfang gesetzt
             move -14(a6),d0
             cmp #2,d0
             bge.s bla1
             move #2,d0
bla1         move d0,blan           ;Zeilennummer merken
             move -2(a6),blanx      ;Kursorposition
bla2         tst blen
             bpl.s ble0             ;Ende ist bereits gesetzt
             moveq #0,d5
             moveq #2,d6            ;Gehe Blockanfang und Lîsche
blret        bra menchange1         ;Marken freigeben

keinbl       lea nobl,a2
             bra formalert          ;kein Block in Grafik

blintxt      move.l blsel,d0
             bmi.s blinrt           ;kein Block
             cmp.l sel,d0
             beq.s blinrt           ;Block ist in diesem Text
             move.l #-1,blsel
             bsr bldemark           ;alten Block demarkieren
blinrt       rts

bloend       cmp.b #28,7(a5)
             beq.s keinbl
             bsr.s blintxt
bled         move #65,fen
             bsr mencheck1          ;HÑkchen setzen
             move -14(a6),d0
             cmp #2,d0
             bge.s ble01
             moveq #2,d0
ble01        move d0,blen           ;Ende notieren
             move -2(a6),blenx
             tst blan
             bpl.s ble0
             moveq #2,d5
             moveq #4,d6
             bra menchange1         ;gehe Ende + demarkieren
ble0         bset #6,flag
             move.l sel,blsel
             bsr anfend
             bsr vollschirm
             bsr kursor
ble3         moveq #0,d5
             moveq #16,d6
             bra menchange1         ;Blockoper. frei

blolad       cmp.b #28,7(a5)
             beq keinbl             ;nicht in Grafik laden
             bsr textlad            ;Fileselektor
             bne.s blaret
             lea nofile,a2
             bsr suchfile
             bne.s blaret           ;nicht auf disk
             bsr openin
             bsr baumadress
             tst 898(a0)            ;eigener Text ?
             beq.s bll0
             bsr eigblo
             bra.s blcl
bll0         tst 922(a0)            ;Wordplus ?
             beq.s bll1
             bsr wpblo
             bra.s blcl
bll1         bsr ascblo
blcl         bclr #6,flag           ;kein Block
             beq.s bll
             bsr bldm               ;demarkieren
bll          move #1,-6(a6)
             bsr neuscreen          ;zeigen
blaret       bra closedisk

blosich      bsr kopffuû
             lea name+128,a5
             bsr holtxtnam          ;Fileselektor
             bne blvret             ;Abbruch
             bsr txs
             bne.s blosiasc
             moveq #2,d1
             bsr txtort1
             subq.l #2,a0
             move.l a0,d0
             lea -68(a6),a0
             sub.l a0,d0
             move.l diskpuff,a1
             move.l a1,a2
             bsr copy1              ;Kopf
             move.l a1,d2
             moveq #2,d0
             add blen,d0
             sub blan,d0
             move d0,44(a2)         ;Zeilenzahl notieren
             bsr writ               ;Kopf Åbertragen
             move.l fuû,a2
             move.l kopf,a0
             move (a0)+,d2
             ext.l d2
             add.l a0,d2
             sub.l a2,d2
             bsr writefile          ;Text
             bra closedisk

blosiasc     move.l kopf,a0
             move (a0)+,d0
             ext.l d0
             add.l a0,d0
             move.l d0,nxtstart     ;Blockende
             move blan,d1
             subq #1,d1
             bsr txtort1
             move.l a0,a5           ;Blockanfang
             move.l d0,d6
             bsr ascsi
             bra closedisk

blodruck     btst #3,flag
             beq tdr0
             btst #6,flag
             beq blvret
             move.l sel,d0
             cmp.l blsel,d0
             bne blvret
bldr0        bsr druform            ;Einstellformular rufen
             bne.s bldrret          ;Abbruch, kein Drucker usw
             bsr mausf2
             lea -68(a6),a2         ;absoluter Textstart
             bsr prtres             ;Voreinstellungen
bldr1        move #1,aktseite
             move blan,d1
             bsr txtort1
             move.l a0,druckad
             move.l d0,druckl
             move blen,d1
             bsr txtort1
             add.l d0,a0
             move.l a0,nxtstart     ;Blockende
bldr2        bsr prtkopf            ;Seitenkopf
             move.l druckad,a5
             bsr prtseite           ;Seite ausgeben
             addq #1,aktseite
             tst d0
             bmi.s bldrret          ;Abbruch
             beq.s bldr3
             tst einzel
             beq.s bldr2
             pea (a2)
             lea neublatt,a2
             bsr formalert          ;Einzelblatt
             move.l (a7)+,a2
             bra.s bldr2
bldr3        subq #1,exemp
             bne.s bldr1            ;noch ein Exemplar
bldrret      bra mausf0

bloord       move blen,d1
             bsr txtort1
             bset #6,(a0)           ;letzte Zeile markieren
             clr zeile
             bsr mausf2
             move blan,-14(a6)      ;Blockanfang=aktuelle Zeile
bo           bsr ordne
             bne.s bo4
             bclr #6,(a5)
             beq.s bo               ;Block ist nicht fertig
             subq #1,-14(a6)
bo4          bsr txtort
             bclr #6,(a0)           ;Endemarke lîschen
             move #1,-6(a6)
blort        bsr mausf0
             move -14(a6),d0
             cmp #4,d0
             blt.s blor
             subq #2,d0
blor         move d0,-10(a6)
             bra bldemark

blover       cmp.b #28,7(a5)
             beq keinbl
             btst #6,flag
             beq.s blvret
             move.l sel,d0
             cmp.l blsel,d0
             bne.s blvret
             bsr inblo
             beq.s blv0
blvs         lea schiebe,a2
             bsr formalert
blvret       rts
blv0         bsr kopffuû
             move.l kopf,d0
             sub.l fuû,d0
             cmp.l #$fc00,d0
             bgt blzugr
             bsr zeilzahl
             tst d7
             bne.s blv1
             move -14(a6),d0
             cmp blan,d0
             bne.s blv1
             bsr vinzeile
             bra blv3
blv1         bsr blkop
             bsr blkill
             move -14(a6),d0
             cmp blan,d0
             blt.s blv2
             sub d7,-14(a6)
blv2         bsr tragein
             move -14(a6),d0
             cmp -10(a6),d0
             bge.s blv3
             move d0,-10(a6)
blv3         move #1,-6(a6)
             bra bldemark

blzugr       lea blgr,a2
             bra formalert

blokop       cmp.b #28,7(a5)
             beq keinbl
             btst #6,flag
             beq blvret
             bsr kopffuû
             move.l kopf,d0
             sub.l fuû,d0
             cmp.l #$fc00,d0
             bgt.s blzugr
             bsr workspace
             bne blvret
             bsr zeilzahl
             bsr blkop
             bsr tragein
             move.l blsel,d0
             cmp.l sel,d0
             bne bll                ;in fremdblock position nicht Ñndern
             bsr inblo
             bne.s blok0            ;block wurde in sich kopiert
             move blan,d0
             cmp -14(a6),d0
             blt bll                ;kopierort liegt hinter dem block
             bne.s blok1
             move blenx,d0          ;in kursorzeile,aber vor block kop.
             sub -2(a6),d0
             bmi bll                ;doch hinter block
             move blan,d1
             cmp blen,d1
             bne blok2
             add -2(a6),d0          ;blockende liegt in gleicher zeile
             sub blanx,d0
             add d0,blenx
blok2        add d0,blanx
blok1        add d7,blan
             add d7,blen
             bra bll
blok0        move -14(a6),d0
             move d0,blan
             add grkl,d0
             move d0,blen
             move -2(a6),d0
             move blenx,d1
             sub blanx,d1
             move d0,blanx
             add d1,d0
             tst grkl
             beq.s blok
             move idfl,d0
blok         move d0,blenx
             bra bll

bllosch      btst #6,flag
             beq blvret
             bsr kopffuû
             bsr zeilzahl
             bsr blkill
             move blan,d0
             move d0,-14(a6)
             cmp #4,d0
             blt.s blk1
             subq #2,d0
blk1         move d0,-10(a6)

bldemark     bsr bldm
             bclr #6,flag
             bsr neuscreen
             moveq #0,d5
             moveq #16,d6
             bra menchange0

gozeil       lea abzeil,a1
             bsr goformu
             beq fehler
             addq #1,d0
             cmp -24(a6),d0
             bge.s bgs1
             move d0,-14(a6)
             bra.s blg

blgosei      lea abseit,a1
             bsr goformu
             beq fehler
bgs0         move d0,aktseite
             move.l aktend,nxtstart
             bsr seite              ;Seitenbeginn holen
             bne.s bgs1
             move d1,-14(a6)
             bra.s blg
bgs1         move -24(a6),-14(a6)
             bra.s blg

blgoblan     move blan,-14(a6)
             move blanx,-2(a6)
             bra.s blg

blgoend      move blen,-14(a6)
             move blenx,-2(a6)
blg          clr -4(a6)
             move -14(a6),d0
             subq #2,d0
             cmp #2,d0
             bge.s blg0
             moveq #2,d0
blg0         move d0,-10(a6)
             bra neuscreen

kopffuû      pea (a6)
             move.l blsel,d0
             lea txtstart,a0
             move.l (a0,d0.l),a6
             lea 68(a6),a6
             move blan,d1
             bsr txtort1
             move.l a0,suchadr      ;Blockbeginn
             subq.l #2,a0           ;ZeilenlÑnge
             move.l a0,fuû
             move blen,d1
             bsr txtort1
             subq.l #2,a0
             move.l a0,kopf         ;Beginn letzte Blockzeile
             move.l (a7)+,a6
             rts

bldm         move.l #-1,blan
             move.l #-1,blsel
             move #64,fen
             bsr mencheck0
             move #65,fen
             bra mencheck0

eigblo       bsr eigprÅf
             bne.s eblret             ;falsches Format
             bsr txtort
             sub.l #2,a0            ;Speicherort
             move.l diskpuff,a3
             lea 68(a3),a3
             move -24(a3),d1        ;Zeilenzahl
             move.l (a3)+,d0        ;Grafik ?
             bne.s nografs          ;Ja
             move (a3)+,d0
             add.l d0,a3            ;Kopf- und Fuûzeile
             sub.l d0,bytes         ;nicht lesen
             move (a3)+,d0
             add.l d0,a3            ;Beginn Text
             sub.l d0,bytes
             sub.l #76,bytes        ;Header
             move.l bytes,d0
             add.l rest,d0
             cmp.l free,d0
             bge.s keinpl
             subq #1,d1             ;Anzahl Textzeilen
             add d1,-24(a6)         ;Gesamtzahl Textzeilen
             pea (a0)               ;Zeiger auf Speicherplatz retten
             bsr ltrans             ;Platz fÅr Block schaffen
             move.l (a7)+,a1
             move.l a3,a0
             bra txtlies

nografs      lea ohngraf,a2
             bra formalert

eblret       lea asclad,a2
             bsr formalert
             beq.s ascblo
eblrt        rts

keinpl       add.l d0,free
             bra txpfull

ascblo       bsr.s holpla
             bsr ladeasc
             addq #1,-24(a6)
             bra.s gibpla

holpla       bsr txtort
             subq.l #2,a0
             move.l a0,txtzg        ;hier wird Block eingefÅgt
             move.l aktend,a1
             move.l free,d0
             add.l d0,aktend
             move.l a0,nxtstart
             add.l d0,nxtstart      ;hier beginnt Textrest
             bsr ltransfer          ;Platz schaffen
             move.l diskpuff,filezg
             rts

gibpla       move.l nxtstart,a0
             move.l a0,d0
             sub.l txtzg,d0
             move.l d0,free
             move.l aktend,a1
             sub.l d0,aktend
             neg.l d0
             bra ltransfer          ;Textrest wieder nach unten

wpblo        moveq #0,d7
             move.l diskpuff,a0
wpb          addq #1,d7
             cmp.b #13,(a0)+
             beq.s wpb0
             cmp #15,d7
             bgt eblret           ;kein Wordplus Text
             bra.s wpb
wpb0         addq #1,d7
             bsr holpla
             sub.l d7,bytes
             add.l d7,filezg
             bsr wptxt
             addq #1,-24(a6)
             bra.s gibpla

workspace    move.l kopf,d6
             sub.l fuû,d6
             move.l free,d0
             sub.l #1024,d0
             cmp.l d0,d6
             blt ok
             lea voll,a2
             bra formalert

vinzeile     lea 7(a5),a0
             lea puffer,a1
             move -2(a6),d0
             cmp blanx,d0
             bgt.s vz1
             tst d0
             beq.s vz
             subq #1,d0
             bsr bringe             ;bis kpos
vz           pea (a0)
             move blanx,d0
             sub -2(a6),d0
             move d0,-(a7)
             bsr kurstelle
             move blenx,d0
             sub blanx,d0
             bsr bringe             ;Block
             move.l a0,a3
             move (a7)+,d0 
             subq #1,d0
             move.l (a7)+,a0
             bsr bringe             ;zwischen kpos und blanx
             move.l a3,a0
             move #255,d0
             bsr bringe             ;Zeilenrest
             bra.s vz3
vz1          move blanx,d0
             subq #1,d0
             bsr bringe             ;bis Block
             pea (a0)
             move blenx,d0
             sub blanx,d0
             move d0,-(a7)
             addq #1,d0
             bsr kurstelle          ;Block Åberlesen
             move -2(a6),d0
             sub blenx,d0
             subq #2,d0
             bsr bringe             ;bis kpos
             move.l a0,a3
             move (a7)+,d0
             move.l (a7)+,a0
             bsr bringe             ;Block
             move #255,d0
             move.l a3,a0
             bsr bringe             ;Zeilenrest
vz3          lea puffer,a0
             lea 7(a5),a1
             move #255,d0
             bsr bringe
vzx          bra zeilÅber

blkill       move.l suchadr,a0
             moveq #7,d0
             lea fuûz,a1
             bsr copy1              ;Zeilenkopf retten
             move blanx,d0
             beq.s blk
             subq #1,d0
             bsr bringe             ;Zeile bis blanx retten
blk          move.l kopf,a0
             lea 9(a0),a0
             move blenx,d0
             addq #1,d0
             bsr kurstelle          ;bis hinter blenx Åberlesen
             move #255,d0
             bsr bringe             ;Zeilenrest an fuûz anhÑngen
             move.b #0,(a1)+
             sub.l #fuûz,a1
             addq #3,a1
             move.l a1,d1
             and #$fffe,d1
             move.l d1,-(a7);pea (a1)
             move.l kopf,a0
             move (a0)+,d0
             ext.l d0
             add.l d0,a0            ;Beginn erste Zeile nach Block
             move.l fuû,d0
             sub.l a0,d0
             cmp #10,d1
             beq.s blk00
             add.l d1,d0
blk00        bsr ltrans             ;lîschen
             move.l (a7),d0
             cmp.l #10,d0          ;8
             bne.s blk0
             addq #1,d7
             sub d7,-24(a6)
             addq.l #4,a7
             rts
blk0         sub d7,-24(a6)
             move.l fuû,a1
             lea fuûz,a0
             move.l (a7)+,d0
             subq #2,d0;addq #1,d0
             move d0,(a1)+
             bra copy1

zeilzahl     move blen,d7
             sub blan,d7
             rts

tragein      bsr txtort
             subq.l #2,a0
             pea (a0)
             move.l ersadr,d1
             sub.l d0,d1
             move.l d1,d0
             subq.l #2,d0
             bsr ltrans
             move.l (a7)+,a1
             move.l diskpuff,a0
             move.l ersadr,d0
             bsr copy2
             move grkl,d0
             add d0,-24(a6)
             rts
inblo        move -14(a6),d0
             cmp blan,d0
             blt ok
             bne.s blv
             move -2(a6),d0
             cmp blanx,d0
             blt ok
             cmp blenx,d0
             bgt ok
             bra fehler
blv          cmp blen,d0
             bgt ok
             bne fehler
             move -2(a6),d0
             cmp blanx,d0
             blt ok
             cmp blenx,d0
             bgt ok
             bra fehler

ordne        bsr graf_leer
             bne fehler;bo4                ;nur Leer- oder Grafikzeilen
             move -18(a6),4(a0)     ;ZeilenlÑnge Åbernehmen
             move.l a5,a1
             moveq #7,d0
             bsr copy1              ;Zeilenvariablen Åbertragen
             bsr einrÅck            ;EinrÅckung ausfÅhren
             addq.l #7,d4
             bsr zeianf
bo0          clr ascrest
             clr idfl
             move -18(a6),d7
             btst #4,(a5)           ;Zeile zentriert ?
             beq.s bo0a             ;nein
             sub d6,d7
             ble.s bo1              ;Zeile ist zu groû
             lsr #1,d7
             sub einrÅ,d7
             bmi.s bo0b             ;EinrÅckung zu groû
             moveq #7,d2
             bsr fb0
bo0b         bsr zeilÅ
             addq #1,-14(a6)
             bra.s ordne
bo0a         cmp d6,d7
             blt.s bo1              ;Umbruch notwendig
             beq.s bo2
             move.b (a5),d0
             cmp.b #63,d0
             bhi.s bo2              ;Absatz oder Blockende
             move -14(a6),d1
             addq #1,d1
             bsr txtort1
             cmp #8,-2(a0)
             beq.s bo2              ;nÑchste ist Leerzeile
             cmp.b #28,7(a0)
             beq.s bo2              ;nÑchste ist Grafik
             btst #4,(a0)
             bne.s bo2              ;nÑchste ist zu zentrieren
             bsr nochz              ;noch eine Zeile anhÑngen
             bra.s bo0
bo1          bsr langwrap
bo2          bsr formatiere
             tst ascrest
             beq.s bo3
             bsr nÑchstz
             bra.s bo0
bo3          rts

graf_leer    bsr txtort
gl           cmp.b #28,7(a0)        ;grafik ?
             beq.s gl1              ;ja
             cmp #8,-2(a0)          ;Leerzeile
             bne ok                 ;nein
gl1          move grkl,d1
             btst d1,(a0)           ;letzte Zeile ?
             bne fehler             ;Ja
             add.l d0,a0            ;nÑchste Zeile
             move (a0)+,d0
             addq #1,-14(a6)
             bra.s gl

blkop        move.l diskpuff,a1
             move d7,grkl           ;Zeilenzahl sichern
             pea (a1)
             addq.l #2,a1           ;Platz fÅr ZeilenlÑnge
             bsr tbg0
             move.l a5,a0
             move d2,d0
             bsr copy1              ;Zeilenkopf
             move.l a0,a3
             move -2(a6),d0
             beq.s blc
             subq #1,d0
             bsr bringe             ;bis kpos Åbertragen
             move.l a0,a3           ;Beginn 2. Zeilenteil
blc          move.l suchadr,a0
             lea 7(a0),a0
             move blanx,d0
             beq.s blko
             bsr kurstelle          ;bis Blockanfang Åberlesen
blko         move blenx,d0
             sub blanx,d0
             tst d7
             beq.s blko0
             move #255,d0
blko0        bsr bringe             ;Blockzeilenrest Åbertragen
             tst d7
             bne.s blko1
             move.l (a7)+,a4
             bra.s einzeil
blko1        move.b #0,(a1)+
             move.l a1,d0
             sub.l (a7),d0
             btst #0,d0
             beq.s blko2
             addq.l #1,d0
             move.b #0,(a1)+
blko2        move.l (a7)+,a0
             subq #2,d0
             move d0,(a0)           ;Zeilengrîûe
             move.l fuû,a0
             move (a0)+,d0
             add.l d0,a0
blko3        subq #1,d7
             beq.s blkl
             move (a0)+,d0
             move d0,(a1)+
             bsr copy2
             bra.s blko3
blkl         move.l a1,a4           ;Ort ZeilenlÑnge
             moveq #9,d0
             bsr copy1              ;Header letzte Blockzeile
             move blenx,d0
             bsr bringe             ;Blockrest
             move d2,idfl
einzeil      move.l a3,a0
             move #255,d0
             bsr bringe             ;Rest aktuelle Zeile
             move.b #0,(a1)+
             move.l a1,d0
             sub.l a4,d0
             subq #2,d0
             btst #0,d0
             beq.s blkl0
             addq #1,d0
             move.b #0,(a1)+
blkl0        move d0,(a4)
             sub.l diskpuff,a1
             move.l a1,ersadr      ;Blockgrîûe
             move grkl,d7
             rts

bringe       moveq #0,d2
bri1         move.b (a0)+,(a1)+
             beq.s bri0
             cmp.b #27,-1(a0)
             bne.s bri
             move.b (a0)+,(a1)+
             bra.s bringe
bri          addq #1,d2
             subq #1,d0
             bpl.s bri1
             rts
bri0         subq.l #1,a1
             rts

kurstelle    cmp.b #27,(a0)+
             bne.s ks0
             addq.l #1,a0
             bra.s kurstelle
ks0          cmp.b #0,-1(a0)
             beq.s bri0
             subq #1,d0
             bne.s kurstelle
             rts

goformu      move.l #40,baumnr
             clr erstobj
             moveq #4,d2
             move d2,editobj
             bsr tempadr
             exg a0,a1
             bsr copy
             move.b #":",(a1)
             bsr formular
             bne ok
             moveq #4,d2
             bsr binout1            ;Eingabe holen
             tst d0
             rts
;MenÅpunkt 'Hilfen'
hilpix       move #36,fen
             move schrhî,d1
             eori #14,d1            ;Schrifthîhe wandeln
             move d1,schrhî
             bsr zgschr
             tst wiakt
             bpl.s hp1
             rts
hp1          bsr fenmaû             ;neue Fenstermaûe
             bsr txtzeilen
             bsr clrwind            ;lîschen
             bsr adrneu             ;Bildadressen neu berechnen
             bsr zeigposit
             bsr scrver1
             bsr vollschirm         ;neu zeichnen
             bsr scrhor
             bra kursor

hilpuf       eori #1,tstpu
tstrep       tst tstpu
             bne.s hpu1
             move #-1,-(a7)
             move #64,-(a7)         ;Blitter ?
             trap #14
             addq.l #4,a7
             moveq #6,d1
             cmp #3,d0
             beq.s hpu              ;vorhanden
             moveq #9,d1
hpu        kbrate d1,#8
             bra mencheck0
hpu1       kbrate #2,#8
             bra mencheck1

hilkopf      move #34,fen
             move firstzei,d1
             eori #2,d1
             move d1,firstzei
             bne.s hk0              ;Kopf- Fuûzeile sind fertig
             lea moment,a0
             move -10(a6),(a0)+     ;Momentane Werte sichern
             move -14(a6),(a0)+
             move.l -4(a6),(a0)
             clr -10(a6)
             clr -14(a6)
             clr.l -4(a6)
             bsr mencheck1
             bra.s hk1
hk0          lea moment,a0
             move (a0)+,-10(a6)     ;Werte restaurieren
             move (a0)+,-14(a6)
             move.l (a0),-4(a6)
             bsr mencheck0
hk1          bra neuscreen

extrenn      eori #1,trenn
             beq mencheck0
             bra mencheck1

txtasc       eori #1,ascsp
             beq mencheck0
             bra mencheck1

hileinf      move #41,fen
             moveq #12,d2
             bchg #0,flag
             bne.s he0
             bsr mencheck1
             moveq #1,d1
             bra.s he1
he0          bsr mencheck0
             moveq #0,d1
he1          bra deskchange

hilabs       eori #1,abs
             beq mencheck0
             bra mencheck1

hilrzei      eori #1,rzeil
             beq mencheck0
             bra mencheck1

hilzenz      bsr kursor
             bsr kuranf
             bset #4,(a5)
             bsr killend
             move.l d7,lentxt
             bsr erstzeich          ;eigentlicher zeilenbeginn
             tst d0
             beq.s hz1
             sub.l d0,lentxt
             sub d0,lenasc
             neg.l d0
             subq.l #1,a0
             lea (a5,d7.l),a1
             bsr transfer1
hz1          move 4(a5),d7          ;erlaubte ZeilenlÑnge
             sub lenasc,d7
             lsr #1,d7              ;halbieren
hz2          beq zeige1
             ext.l d7
             bsr fb0                ;Zentrieren
             bsr clrline
             bsr kurpos
             bsr zeilÅber
             move -4(a6),d7
             bra zeige1

hilord       bsr mausf2
hio          bsr ordne
hio0         move -14(a6),d0
             cmp #4,d0
             blt.s hio1
             subq #2,d0
hio1         move d0,-10(a6)
             bsr mausf0
             bra neuscreen

hileinr      btst #1,flag
             bne.s heret
             tst zentr
             bne.s heret
             move #45,fen
             move -2(a6),d0
einra        move d0,einrÅ
             move #3,stellen
             lea einr+13,a0
             bsr formzahl1
             lea einr,a2
             bsr mentxt
heret        rts

einraus      moveq #0,d0
             move #45,fen
             bra.s einra

hillink      bchg #1,flag
             bne mencheck0
             bsr mencheck1
             bra.s einraus

hilzent      eori #1,zentr
             beq mencheck0
             bsr mencheck1
             move #48,fen
             move #0,blocks
             bsr mencheck0          ;Blocksatz aus
             bra.s einraus

hilblo       eori #1,blocks
             beq mencheck0
             bsr mencheck1
             move #47,fen
             move #0,zentr
             bra mencheck0

hilein       bsr.s kuranf           ;Kursor an Zeilenbeginn
             bsr erstzeich          ;Textanfang
             move d0,d5
             bsr tabsuch
             move.l d5,d7
             sub.l d0,d7
             bra hz2

erstzeich    moveq #-1,d0
             lea (a5,d2.l),a0
hz0          cmp.b #27,(a0)
             bne.s ez
             addq.l #2,a0
             bra.s hz0
ez           addq.l #1,d0
             cmp.b #32,(a0)+
             ble.s hz0
             rts

kuranf       bsr txtbeginn
             clr -2(a6)             ;kpos korrigieren
             move.l d2,kptxt
             move xstart,xkur
             rts

neuscreen    bsr scrver
             bsr vollschirm
             bsr scrhor
             bra kursor

zgschr       lea schr8,a2           ;"Kleinschrift"
             moveq #6,d0
             add d1,d1
             move d1,zlabst         ;*2 als Zeilenabstand
             cmp #12,d1
             beq.s hp0
             moveq #13,d0           ;es ist Groûschrift
             lea schr16,a2
hp0          move d0,txth
             bra mentxt             ;MenÅeintrag Ñndern

adrneu       move.l a6,a2
an           move.l (a2)+,ersadr
             bne.s an1
             rts
an1          bsr neuadr
             add.l -4(a2),a2
             bra.s an

  end
 